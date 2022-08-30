module tki
    implicit none
    interface
        subroutine transpose_colon_trampoline(block_order,TA,TB) bind(C)
            use, intrinsic :: iso_fortran_env
            integer(kind=INT32), value :: block_order
            real(kind=REAL64), dimension(block_order,block_order) :: TA,TB
        end subroutine transpose_colon_trampoline
    end interface
end module tki
