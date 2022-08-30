module nski
    implicit none
    interface
        subroutine nstream_length(length,scalar,A,B,C) bind(C)
            use, intrinsic :: iso_fortran_env
            integer(kind=REAL64), value :: length
            real(kind=REAL64), value :: scalar
            real(kind=REAL64), dimension(length) :: A,B,C
        end subroutine nstream_length
    end interface
    interface
        subroutine nstream_star(length,scalar,A,B,C) bind(C)
            use, intrinsic :: iso_fortran_env
            integer(kind=REAL64), value :: length
            real(kind=REAL64), value :: scalar
            real(kind=REAL64), dimension(*) :: A,B,C
        end subroutine nstream_star
    end interface
    interface
        subroutine nstream_colon_trampoline(length,scalar,A,B,C) bind(C)
            use, intrinsic :: iso_fortran_env
            integer(kind=REAL64), value :: length
            real(kind=REAL64), value :: scalar
            real(kind=REAL64), dimension(:) :: A,B,C
        end subroutine nstream_colon_trampoline
    end interface
    interface
        subroutine nstream_dots_trampoline(length,scalar,A,B,C) bind(C)
            use, intrinsic :: iso_fortran_env
            integer(kind=REAL64), value :: length
            real(kind=REAL64), value :: scalar
            real(kind=REAL64), dimension(:) :: A,B,C
        end subroutine nstream_dots_trampoline
    end interface
    interface
        subroutine nstream_colon(length,scalar,A,B,C) bind(C)
            use, intrinsic :: iso_fortran_env
            integer(kind=REAL64), value :: length
            real(kind=REAL64), value :: scalar
            real(kind=REAL64), dimension(:) :: A,B,C
        end subroutine nstream_colon
    end interface
    interface
        subroutine nstream_dots(length,scalar,A,B,C) bind(C)
            use, intrinsic :: iso_fortran_env
            integer(kind=REAL64), value :: length
            real(kind=REAL64), value :: scalar
            real(kind=REAL64), dimension(..) :: A,B,C
        end subroutine nstream_dots
    end interface
end module nski
