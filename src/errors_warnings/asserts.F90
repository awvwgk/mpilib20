!> Module implementing assertions, emulating the C library macro `void assert`
module asserts
    use iso_fortran_env, only: error_unit
    implicit none
    private

    !> Error code to return to the invoking environment
    integer, parameter :: error_code_logical = -101

    !>  A generic interface for assertions
    interface assert
        module procedure assert_true
    end interface assert

    ! Pubically-visible interface 
    public :: assert

contains

    !> Terminate following a failed assertion 
    !>
    !> @todo Note, this kills ALL mpi processes. One may not want to do this 
    !> if the communicator has been split
    !> @todo Will need to preprocess for SERIAL 
    subroutine terminate()
        use mpi_bindings, only: MPI_COMM_WORLD, MPI_ABORT
        !> Dummy MPI error integer
        integer :: ierr 
        call MPI_ABORT(MPI_COMM_WORLD, error_code_logical, ierr) 
        !stop error_code_logical
    end subroutine terminate

    !> Assert if a logical condition is true
    !>
    !> If not compiled in DEBUG mode, the compiler is smart enough
    !> to remove the routine, which will be empty (i.e. no overhead) 
    !> @todo consider passing mpi_env to this routine (or overload)       
    subroutine assert_true(logical_condition, message)
        !> Condition to test
        logical, intent(in) :: logical_condition
        !> Optional message for termination
        character(len=*), intent(in), optional :: message
#ifdef USE_ASSERT
        if (.not. logical_condition) then
            if (present(message)) then
                write (error_unit, '(/,1x,a)') trim(adjustl(message))
            endif
            call terminate()
        end if
#endif
    end subroutine assert_true

end module asserts