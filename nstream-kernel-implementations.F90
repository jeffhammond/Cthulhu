subroutine nstream_length(length,scalar,A,B,C) bind(C)
    use, intrinsic :: iso_fortran_env
    integer(kind=REAL64), value :: length
    real(kind=REAL64), value :: scalar
    real(kind=REAL64), dimension(length) :: A,B,C
    do concurrent (i=1:length)
      A(i) = A(i) + B(i) + scalar * C(i)
    enddo
end subroutine nstream_length

subroutine nstream_star(length,scalar,A,B,C) bind(C)
    use, intrinsic :: iso_fortran_env
    integer(kind=REAL64), value :: length
    real(kind=REAL64), value :: scalar
    real(kind=REAL64), dimension(*) :: A,B,C
    do concurrent (i=1:length)
      A(i) = A(i) + B(i) + scalar * C(i)
    enddo
end subroutine nstream_star

subroutine nstream_colon(length,scalar,A,B,C) bind(C)
    use, intrinsic :: iso_fortran_env
    integer(kind=REAL64), value :: length
    real(kind=REAL64), value :: scalar
    real(kind=REAL64), dimension(:) :: A,B,C
    do concurrent (i=1:length)
      A(i) = A(i) + B(i) + scalar * C(i)
    enddo
end subroutine nstream_colon
