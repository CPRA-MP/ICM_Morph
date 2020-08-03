subroutine inundation(tp)
    ! subroutine that calculates inundation depth for each DEM pixel
    ! the inundation will be calculated from the DEM data and whichever water surface elevation array is passed into the subroutine
    ! the WSE array has one value for each ICM-Hydro compartment
    ! the WSE array must have values relative to the same vertical datum and use the same units as the DEM data
    

    use params
    implicit none
    
    ! local variables
    integer :: i                                    ! iterator
    integer :: c                                    ! local compartment ID variable
    integer :: g                                    ! local grid ID variable
    integer :: tp                                   ! flag to indicate which timeperiod to use for inundation calculations (1-12=month; 13 = annual)
    real(sp) :: wse_by_comp(ncomp)                  ! local array with WSE data (one value for each ICM-Hydro compartment) to use in calculations 
    real(sp) :: z                                   ! local elevation variable
    real(sp) :: wse                                 ! local water surface elevation variable
    
    
    
    if (tp == 13) then
        write(  *,*) " - calculating inundation for year"
        write(000,*) " - calculating inundation for year"
        wse_by_comp = stg_av_yr
    else
        wse_by_comp = stg_av_mons(1:ncomp,wse_to_use)
        write(  *,*) " - calculating inundation for month: " , tp
        write(000,*) " - calculating inundation for month: " , tp
    end if
    
    do i = 1,ndem
        z = dem_z(i)
        c = dem_comp(i)
        g = dem_grid(i)
        wse = wse_by_comp(c)            ! wse_by_comp is passed into this subroutine
        
        dem_inun_dep(i,wse_to_use) = wse - z

        if (wse > z) then        
            comp_ndem_wet(c,tp) = comp_ndem_wet(c,tp) + 1
            grid_ndem_wet(g,tp) = grid_ndem_wet(g,tp) + 1
        end if
        
    end do
    
    return

end