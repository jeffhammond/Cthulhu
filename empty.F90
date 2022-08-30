subroutine transpose_order(order,A,B) bind(C)
    use, intrinsic :: iso_fortran_env
    integer(kind=REAL64), value :: order
    real(kind=REAL64), value :: scalar
    real(kind=REAL64), dimension(order,order) :: A,B
    do concurrent (i=1:order)
    enddo
end subroutine transpose_order
