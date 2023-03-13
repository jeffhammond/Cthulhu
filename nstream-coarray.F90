program main
  use, intrinsic :: iso_fortran_env
  use prk
  use nski
  implicit none
  integer :: me, np
  integer :: err
  ! problem definition
  integer(kind=INT32) :: iterations
  integer(kind=INT64) :: length, offset
  real(kind=REAL64), allocatable ::  A(:)[:]
  real(kind=REAL64), allocatable ::  B(:)[:]
  real(kind=REAL64), allocatable ::  C(:)[:]
  real(kind=REAL64) :: scalar
  integer(kind=INT64) :: bytes
  ! runtime variables
  integer(kind=INT64) :: i
  integer(kind=INT32) :: k
  real(kind=REAL64) ::  asum, ar, br, cr
  real(kind=REAL64) ::  t0, t1, nstream_time, avgtime
  real(kind=REAL64), parameter ::  epsilon=1.D-8

  me = this_image()
  np = num_images()

  ! ********************************************************************
  ! read and test input parameters
  ! ********************************************************************

  if (me.eq.1) then
    write(*,'(a25)') 'Parallel Research Kernels'
    write(*,'(a48)') 'Fortran coarray STREAM triad: A = B + scalar * C'
    call prk_get_arguments('nstream',iterations=iterations,length=length,offset=offset)
    write(*,'(a23,i12)') 'Number of images     = ', np
    write(*,'(a23,i12)') 'Number of iterations = ', iterations
    write(*,'(a23,i12)') 'Vector length        = ', length
    write(*,'(a23,i12)') 'Offset               = ', offset
  endif

  call co_broadcast(iterations,1)
  call co_broadcast(length,1)

  ! ********************************************************************
  ! ** Allocate space and perform the computation
  ! ********************************************************************

  allocate( A(length)[*], B(length)[*], C(length)[*], stat=err)
  if (err .ne. 0) then
    write(*,'(a,i3)') 'allocation returned ',err
    error stop 1
  endif

  do concurrent (i=1:length)
    A(i) = 0
    B(i) = 2
    C(i) = 2
  enddo
  sync all

  scalar = 3

  t0 = 0

  do k=0,iterations
    if (k.eq.1) then
      sync all
      t0 = prk_get_wtime()
    endif

    !do concurrent (i=1:length)
    !  A(i) = A(i) + B(i) + scalar * C(i)
    !enddo
    !call nstream_length(length,scalar,A,B,C)
    !call nstream_star(length,scalar,A,B,C)
    call nstream_colon_trampoline(length,scalar,A,B,C)

  enddo

  sync all
  t1 = prk_get_wtime()

  nstream_time = t1 - t0

  ! ********************************************************************
  ! ** Analyze and output results.
  ! ********************************************************************

  ar  = 0
  br  = 2
  cr  = 2
  do k=0,iterations
      ar = ar + br + scalar * cr;
  enddo

  asum = 0
  do concurrent (i=1:length)
    asum = asum + abs(A(i)-ar)
  enddo

  call co_sum(asum)

  deallocate( B,C )

  if (abs(asum) .gt. epsilon) then
    if (me.eq.1) then
      write(*,'(a35)') 'Failed Validation on output array'
      write(*,'(a30,f30.15)') '       Expected value: ', ar
      write(*,'(a30,f30.15)') '       Observed value: ', A(1)
      write(*,'(a35)')  'ERROR: solution did not validate'
      error stop 1
    endif
  else
    if (me.eq.1) write(*,'(a17)') 'Solution validates'
    avgtime = nstream_time/iterations;
    bytes = 4 * np * length * storage_size(A)/8
    if (me.eq.1) then
      write(*,'(a12,f15.3,1x,a12,e15.6)')    &
              'Rate (MB/s): ', 1.d-6*bytes/avgtime, &
              'Avg time (s): ', avgtime
    endif
  endif

  deallocate(A)

end program main

