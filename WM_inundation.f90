subroutine inundation(wse_to_use)
    ! subroutine that calculates inundation depth for each DEM pixel
    ! the inundation will be calculated from the DEM data and whichever water surface elevation array is passed into the subroutine
    ! the WSE array has one value for each ICM-Hydro compartment
    ! the WSE array must have values relative to the same vertical datum and use the same units as the DEM data
    

    use params
    implicit none
    
    ! local variables
    integer :: i                                     ! iterator
    integer :: c                                     ! local compartment variable
    integer :: wse_to_use                            ! flag to indicate which WSE value to use for inundation calculations (value provided later in code)
    real(sp) :: wse_by_comp(ncomp)                   ! local array with WSE data (one value for each ICM-Hydro compartment) to use in calculations 
    real(sp) :: z                                    ! local elevation variable
    real(sp) :: wse                                  ! local water surface elevation variable
    integer :: comp_ndem_all_start                   ! local variable to track number of all DEM pixels in each ICM-Hydro compartment
    integer :: comp_ndem_wet_start                   ! local variable to track number of wet DEM pixels in each ICM-Hydro compartment
    
    
    
    if (wse_to_use == 13) then
        write(  *,*) " - calculating inundation for year"
        write(000,*) " - calculating inundation for year"
        wse_by_comp = stg_av_yr
    else
        write(  *,*) " - calculating inundation for month: " , wse_to_use
        write(000,*) " - calculating inundation for month: " , wse_to_use
    end if
        
    write(*,*) wse_by_comp(1)
    
    comp_ndem_all = 0                   ! before looping through all DEM pixels, initialize counter arrays to zero
    comp_ndem_wet = 0                   ! before looping through all DEM pixels, initialize counter arrays to zero
    
    do i = 1,ndem
        z = dem_z(i)
        c = dem_comp(i)
        wse = wse_by_comp(c)            ! wse_by_comp is passed into this subroutine
        
        dem_inun_dep(i) = max(0.0,wse-z)
        
        comp_ndem_all_start = comp_ndem_all(c)
        comp_ndem_all(c) = comp_ndem_all_start + 1
        
        comp_ndem_wet_start = comp_ndem_wet(c)
        if (wse > z) then        
            comp_ndem_wet(c) = comp_ndem_wet_start + 1
        else
            comp_ndem_wet(c) = comp_ndem_wet_start
        end if
        
    end do
    
    return

end