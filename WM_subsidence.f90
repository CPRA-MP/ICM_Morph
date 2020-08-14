subroutine subsidence
    ! global arrays updated by subroutine:
    !      dem_z
    !
    use params
    implicit none
    
    ! local variables
    integer :: i                                                    ! iterator
    integer :: c                                                    ! local compartment ID variable
    integer :: g                                                    ! local grid cell ID variable

    do i = 1,ndem
        ! set local copies of grid and compartment numbers
        c = dem_comp(i)
    end do
        
    return

end