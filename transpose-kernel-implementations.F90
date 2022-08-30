subroutine transpose_colon(block_order,TA,TB) bind(C)
    use, intrinsic :: iso_fortran_env
    integer(kind=INT32), value :: block_order
    real(kind=REAL64), dimension(block_order,block_order) :: TA, TB
    integer(kind=INT32) :: i,j
#if 1
    print*,'transpose_colon:',block_order
    print*,'transpose_colon: CONTIGUOUS:',is_contiguous(TA)
    print*,'transpose_colon: CONTIGUOUS:',is_contiguous(TB)
    print*,'transpose_colon: S',size(TA,1)
    print*,'transpose_colon: S',size(TA,2)
    print*,'transpose_colon: S',size(TB,1)
    print*,'transpose_colon: S',size(TB,2)
    print*,'transpose_colon: L',lbound(TA,1)
    print*,'transpose_colon: L',lbound(TA,2)
    print*,'transpose_colon: L',lbound(TB,1)
    print*,'transpose_colon: L',lbound(TB,2)
    print*,'transpose_colon: U',ubound(TA,1)
    print*,'transpose_colon: U',ubound(TA,2)
    print*,'transpose_colon: U',ubound(TB,1)
    print*,'transpose_colon: U',ubound(TB,2)
    print*,'transpose_colon: ',TA(1,1)!,TA(block_order,block_order)
    print*,'transpose_colon: ',TB(1,1)!,TB(order,block_order)
#endif
    !do concurrent (j=1:block_order, i=1:block_order)
    !  TB(i,j) = TB(i,j) + TA(j,i)
    !enddo
    do j=1,block_order
      do i=1,block_order
        TB(i,j) = TB(i,j) + TA(j,i)
      enddo
    enddo
end subroutine transpose_colon
