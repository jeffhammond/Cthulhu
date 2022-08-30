subroutine transpose_order(order,block_order,col_start,T,B) bind(C)
    use, intrinsic :: iso_fortran_env
    integer(kind=INT32), value :: block_order,col_start
    real(kind=REAL64), dimension(block_order,block_order) :: T
    real(kind=REAL64), dimension(order,block_order) :: B
    do concurrent (j=1:block_order, i=1:block_order)
      B(col_start+i,j) = B(col_start+i,j) + T(j,i)
    enddo
end subroutine transpose_order

subroutine transpose_colon(order,block_order,col_start,T,B) bind(C)
    use, intrinsic :: iso_fortran_env
    integer(kind=INT32), value :: block_order,col_start
    real(kind=REAL64), dimension(block_order,block_order) :: T
    real(kind=REAL64), dimension(order,block_order) :: B
#if 0
    print*,'transpose_colon:',block_order,col_start
    print*,'transpose_colon: CONTIGUOUS:',is_contiguous(T)
    print*,'transpose_colon: CONTIGUOUS:',is_contiguous(B)
    print*,'transpose_colon: S',size(T,1)
    print*,'transpose_colon: S',size(T,2)
    print*,'transpose_colon: S',size(B,1)
    print*,'transpose_colon: S',size(B,2)
    print*,'transpose_colon: L',lbound(T,1)
    print*,'transpose_colon: L',lbound(T,2)
    print*,'transpose_colon: L',lbound(B,1)
    print*,'transpose_colon: L',lbound(B,2)
    print*,'transpose_colon: U',ubound(T,1)
    print*,'transpose_colon: U',ubound(T,2)
    print*,'transpose_colon: U',ubound(B,1)
    print*,'transpose_colon: U',ubound(B,2)
    print*,'transpose_colon: ',T(1),T(order)
    print*,'transpose_colon: ',B(1),B(order)
#endif
    do concurrent (j=1:block_order, i=1:block_order)
      B(col_start+i,j) = B(col_start+i,j) + T(j,i)
    enddo
end subroutine transpose_colon
