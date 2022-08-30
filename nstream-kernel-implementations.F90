subroutine nstream_length(length,scalar,A,B,C) bind(C)
    use, intrinsic :: iso_fortran_env
    integer(kind=INT64), value :: length
    real(kind=REAL64), value :: scalar
    real(kind=REAL64), dimension(length) :: A,B,C
    integer(kind=INT64) :: i
    do concurrent (i=1:length)
      A(i) = A(i) + B(i) + scalar * C(i)
    enddo
end subroutine nstream_length

subroutine nstream_star(length,scalar,A,B,C) bind(C)
    use, intrinsic :: iso_fortran_env
    integer(kind=INT64), value :: length
    real(kind=REAL64), value :: scalar
    real(kind=REAL64), dimension(*) :: A,B,C
    integer(kind=INT64) :: i
    do concurrent (i=1:length)
      A(i) = A(i) + B(i) + scalar * C(i)
    enddo
end subroutine nstream_star

subroutine nstream_colon(length,scalar,A,B,C) bind(C)
    use, intrinsic :: iso_fortran_env
    integer(kind=INT64), value :: length
    real(kind=REAL64), value :: scalar
    real(kind=REAL64), dimension(:) :: A,B,C
    integer(kind=INT64) :: i
#if 0
    print*,'nstream_colon:',length
    print*,'nstream_colon:',scalar
    print*,'nstream_colon: CONTIGUOUS:',is_contiguous(A)
    print*,'nstream_colon: CONTIGUOUS:',is_contiguous(B)
    print*,'nstream_colon: CONTIGUOUS:',is_contiguous(C)
    print*,'nstream_colon: S',size(A,1)
    print*,'nstream_colon: S',size(B,1)
    print*,'nstream_colon: S',size(C,1)
    print*,'nstream_colon: L',lbound(A,1)
    print*,'nstream_colon: L',lbound(B,1)
    print*,'nstream_colon: L',lbound(C,1)
    print*,'nstream_colon: U',ubound(A,1)
    print*,'nstream_colon: U',ubound(B,1)
    print*,'nstream_colon: U',ubound(C,1)
    print*,'nstream_colon: ',A(1),A(length)
    print*,'nstream_colon: ',B(1),B(length)
    print*,'nstream_colon: ',C(1),C(length)
#endif
    do concurrent (i=1:length)
      A(i) = A(i) + B(i) + scalar * C(i)
    enddo
end subroutine nstream_colon
