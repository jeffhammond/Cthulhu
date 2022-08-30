program main
  use, intrinsic :: iso_fortran_env
  use prk
  use tki
  implicit none
  ! for argument parsing
  integer :: err
  integer :: arglen
  character(len=32) :: argtmp
  integer :: me, np
  logical :: printer
  ! problem definition
  integer(kind=INT32) ::  iterations                ! number of times to do the transpose
  integer(kind=INT32) ::  order                     ! order of a the matrix
  real(kind=REAL64), allocatable ::  A(:,:)[:]      ! buffer to hold original matrix
  real(kind=REAL64), allocatable ::  B(:,:)[:]      ! buffer to hold transposed matrix
  real(kind=REAL64), allocatable ::  TA(:,:)        ! temporary to hold tile
  real(kind=REAL64), allocatable ::  TB(:,:)        ! temporary to hold tile
  integer(kind=INT64) ::  bytes                     ! combined size of matrices
  ! distributed data helpers
  integer(kind=INT32) :: block_order                ! columns per PE = order/np
  integer(kind=INT32) :: col_start, row_start
  ! runtime variables
  integer(kind=INT32) ::  i, j, k, p, q
  real(kind=REAL64) ::  abserr, addit, temp         ! squared error
  real(kind=REAL64) ::  t0, t1, trans_time, avgtime ! timing parameters
  real(kind=REAL64), parameter ::  epsilon=1.D-8    ! error tolerance

  me   = this_image()-1 ! use 0-based indexing of PEs
  np = num_images()
  printer = (me.eq.0)

  ! ********************************************************************
  ! read and test input parameters
  ! ********************************************************************

  if (printer) then
    write(6,'(a25)') 'Parallel Research Kernels'
    write(6,'(a41)') 'Fortran coarray Matrix transpose: B = A^T'
  endif

  if (command_argument_count().lt.2) then
    if (printer) then
      write(*,'(a17,i1)') 'argument count = ', command_argument_count()
      write(6,'(a62)')    'Usage: ./transpose <# iterations> <matrix order>'
    endif
    stop 1
  endif

  iterations = 1
  call get_command_argument(1,argtmp,arglen,err)
  if (err.eq.0) read(argtmp,'(i32)') iterations
  if (iterations .lt. 1) then
    if (printer) then
      write(6,'(a35,i5)') 'ERROR: iterations must be >= 1 : ', iterations
    endif
    stop 1
  endif

  order = 1
  call get_command_argument(2,argtmp,arglen,err)
  if (err.eq.0) read(argtmp,'(i32)') order
  if (order .lt. 1) then
    if (printer) then
      write(6,'(a30,i5)') 'ERROR: order must be >= 1 : ', order
    endif
    stop 1
  endif
  if (modulo(order,np).gt.0) then
    if (printer) then
      write(6,'(a20,i5,a35,i5)') 'ERROR: matrix order ',order,&
                        ' should be divisible by # images ',np
    endif
    stop 1
  endif
  block_order = order/np

  ! ********************************************************************
  ! ** Allocate space for the input and transpose matrix
  ! ********************************************************************

  allocate( A(order,block_order)[*], B(order,block_order)[*], &
            TA(block_order,block_order), TB(block_order,block_order), stat=err)
  if (err .ne. 0) then
    write(6,'(a20,i3,a10,i5)') 'allocation returned ',err,' at image ',me
    stop 1
  endif

  if (printer) then
    write(6,'(a23,i8)') 'Number of images     = ', np
    write(6,'(a23,i8)') 'Number of iterations = ', iterations
    write(6,'(a23,i8)') 'Matrix order         = ', order
  endif

  ! initialization
  ! local column index j corresponds to global column index block_order*me+j
  do concurrent (j=1:block_order)
    do i=1,order
      A(i,j) = real(order,REAL64) * real(block_order*me+j-1,REAL64) + real(i-1,REAL64)
      B(i,j) = 0.0
    enddo
  enddo
  sync all ! barrier to ensure initialization is finished at all PEs

  t0 = 0

  do k=0,iterations

    if (k.eq.1) then
      sync all
      t0 = prk_get_wtime()
    endif

    ! we shift the loop range from [0,np-1] to [me,me+np-1]
    ! to balance communication.  if everyone starts at 0, they will
    ! take turns blasting each image in the system with get operations.
    ! side note: this trick is used extensively in NWChem.
    do q=me,me+np-1
      p = modulo(q,np)
      row_start = me*block_order
      col_start = p*block_order
      ! Step 1: Gather A tile from remote image
      TA(:,:) = A(row_start+1:row_start+block_order,:)[p+1]
      ! Step 2: Transpose tile into B matrix
      !do j=1,block_order
      !  do i=1,block_order
      !    B(col_start+i,j) = B(col_start+i,j) + TA(j,i)
      !  enddo
      !enddo
      TB(:,:) = B(col_start+1:col_start+block_order,1:block_order)
      call transpose_colon_trampoline(block_order,TA,TB)
      B(col_start+1:col_start+block_order,1:block_order) = TB(:,:)
    enddo
    sync all
    ! Step 3: Update A matrix
    do j=1,block_order
      do i=1,order
        A(i,j) = A(i,j) + 1.0
      enddo
    enddo
    sync all

  enddo ! iterations

  t1 = prk_get_wtime()
  trans_time = t1 - t0

  deallocate( TA, TB )

  ! ********************************************************************
  ! ** Analyze and output results.
  ! ********************************************************************

  abserr = 0.0;
  addit = (0.5*iterations) * (iterations+1.0)
  do j=1,block_order
    do i=1,order
      temp = ((real(order,REAL64)*real(i-1,REAL64))+real(block_order*me+j-1,REAL64)) &
           * real(iterations+1,REAL64) + addit
      abserr = abserr + abs(B(i,j) - temp)
    enddo
  enddo

  deallocate( B )

  if (abserr .lt. (epsilon/np)) then
    if (printer) then
      write(6,'(a)') 'Solution validates'
      avgtime = trans_time/iterations
      bytes = 2 * int(order,INT64) * int(order,INT64) * storage_size(A(1,1))/8
      write(6,'(a12,f13.6,a17,f10.6)') 'Rate (MB/s): ',&
              (1.d-6*bytes/avgtime),' Avg time (s): ', avgtime
    endif
  else
    if (printer) then
      write(6,'(a30,f13.6,a18,f13.6)') 'ERROR: Aggregate squared error ', &
              abserr,' exceeds threshold ',(epsilon/np)
    endif
    stop 1
  endif

  deallocate( A )

end program main
