module tki
    implicit none
    interface
        subroutine transpose_order(order,block_order,col_start,T,B) bind(C)
            use, intrinsic :: iso_fortran_env
            integer(kind=INT32), value :: order,block_order,col_start
            real(kind=REAL64), dimension(block_order,block_order) :: T
            real(kind=REAL64), dimension(order,block_order) :: B
        end subroutine transpose_order
    end interface
    interface
        subroutine transpose_colon_trampoline(order,block_order,col_start,T,B) bind(C)
            use, intrinsic :: iso_fortran_env
            integer(kind=INT32), value :: order,block_order,col_start
            real(kind=REAL64), dimension(block_order,block_order) :: T
            real(kind=REAL64), dimension(order,block_order) :: B
        end subroutine transpose_colon_trampoline
    end interface
!    interface
!        subroutine transpose_colon(order,block_order,col_start,T,B) bind(C)
!            use, intrinsic :: iso_fortran_env
!            integer(kind=INT32), value :: block_order,col_start
!            real(kind=REAL64), dimension(block_order,block_order) :: T
!            real(kind=REAL64), dimension(order,block_order) :: B
!        end subroutine transpose_colon
!    end interface
end module tki
