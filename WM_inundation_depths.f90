subroutine inundation_depths(tp)
    ! subroutine that calculates inundation depth for each DEM pixel
    ! global arrays updated by subroutine:
    !      dem_inun_dep
    !      comp_ndem_wet
    !      grid_ndem_wet
    
    !  
    !
    ! the inundation will be calculated from the DEM data and whichever water surface elevation array is passed into the subroutine
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
    
    
    ! tp=13 uses current year annual mean stage to calculate inundation    
    if (tp == 13) then
        write(  *,*) ' - calculating inundation for current year'
        write(000,*) ' - calculating inundation for current year'
        wse_by_comp = stg_av_yr
    ! tp=14 uses previous year annual mean stage to calculate inundation    
    else if (tp == 14) then
        write(  *,*) ' - calculating inundation for previous year'
        write(000,*) ' - calculating inundation for previous year'
        wse_by_comp = stg_av_prev_yr
    ! tp <= 12 uses monthly mean stage to calculate inundation for month tp
    else
        write(  *,*) ' - calculating inundation for current year, month: ' , tp
        write(000,*) ' - calculating inundation for current year, month: ' , tp
        wse_by_comp = stg_av_mons(1:ncomp,tp)
    end if
    
    do i = 1,ndem
        z = dem_z(i)
        c = dem_comp(i)
        g = dem_grid(i)
        wse = wse_by_comp(c)            ! wse_by_comp is passed into this subroutine
        
        dem_inun_dep(i,tp) = wse - z

        if (wse > z) then        
            comp_ndem_wet(c,tp) = comp_ndem_wet(c,tp) + 1
            grid_ndem_wet(g,tp) = grid_ndem_wet(g,tp) + 1
        end if
        
    end do

    return

end