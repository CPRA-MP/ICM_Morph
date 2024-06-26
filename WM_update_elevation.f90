subroutine update_elevation
    ! global arrays updated by subroutine:
    !      dem_z
    !      dem_dz_cm
    !      comp_sed_mass_loss
    !
    ! Subroutine updates elevation at each DEM pixel at end of year.
    ! Processes taken into account for dZ at each pixel depend on landtype classification.
    ! Additional elevation loss if land loss occurs at pixel
    !
    ! Subroutine also sums sediment mass of all land lost during the year within each ICM-Hydro compartment
    
    use params
    implicit none
    
    ! local variables
    integer :: i                                                        ! iterator
    integer :: c                                                        ! local compartment ID variable
    integer :: g                                                        ! local grid cell ID variable
    integer :: er                                                       ! local ecoregion ID variable
    real(sp) :: dz_cm                                                   ! change in elevation for DEM pixel during current year (cm)
    real(sp) :: dz_cm_lndtyp                                            ! land-type specific elevation change (e.g. lowering old bareground) (cm)
    
    write(  *,*) ' - updating elevation at end of current year'
    write(000,*) ' - updating elevation at end of current year'
    
    do i = 1,ndem
        dz_cm = 0.0
        dz_cm_lndtyp = 0.0
        
        if (dem_z(i) /= dem_NoDataVal) then
            c = dem_comp(i)
            if (c /= dem_NoDataVal) then
                if (dem_to_bidem(i) == dem_NoDataVal) then                                                                      ! if pixel is not within barrier island domain            
                    if (dem_bg_flag(i) == 1) then                                                                               
                        dz_cm_lndtyp = -1.0*bg_lowerZ_m*100.0
                    else 
                        if (lnd_change_flag(i) == -2) then                                                                      ! lower dead flotant pixels (lnd_change = -2) to a given depth below mean water level
                            dz_cm_lndtyp = min(0.00,-100.0*( dem_z(i) - (stg_av_yr(c) - flt_lowerDepth_m) ))                    ! if current elevation is already lower than this depth do not allow for elevation gain
                        else if (lnd_change_flag(i) == -3) then                                                                 ! lower eroded edge pixels (lnd_change = -3)
                            if (dem_edge_near_z(i) /= dem_NoDataVal) then
                                dz_cm_lndtyp = min(0.00,-100.0*( dem_z(i) - dem_edge_near_z(i) ) )                               ! lower eroded edge pixels to the elevation of the nearest water body bottom elevation (enforce only lowering - max will be no change)
                                !dz_cm_lndtyp = min(0.00,-100.0*( dem_z(i) - (stg_av_yr(c) - me_lowerDepth_m) ))                 ! lower eroded edge pixels by value set in input_params.csv
                            else
                                dz_cm_lndtyp = 0.0
                            end if
                        end if
                    end if
                
                    er = comp_eco(c)            
                    if (er /= dem_NoDataVal) then
                        !! vegetated land
                        if (dem_lndtyp(i) == 1) then
                            if (dem_pldr(i) == 1) then                                                                                  ! poldered vegetated land dz_cm = f(deep)
                                dz_cm = 0.0 - dem_dpsb(i)/10.0 + dz_cm_lndtyp                                                           ! convert subsidence from mm/yr to cm/yr
                            else if (lnd_change_flag(i) == 0) then                                                                      ! non-polder vegetated land with no land change dz_cm = f(organic, mineral, deep, shallow)
                                dz_cm = org_accr_cm(i) + min_accr_cm(i) - dem_dpsb(i)/10.0 - er_shsb(er,ssub_col)/10.0 + dz_cm_lndtyp   
                            else                                                                                                        ! non-polder vegetated land with land change (meaning was vegetated now water) - do not include organic accretion given land loss occurred, but still update for subsidence    
                                dz_cm = min_accr_cm(i) - dem_dpsb(i)/10.0 - er_shsb(er,ssub_col)/10.0 + dz_cm_lndtyp                
                            end if
                        !! water bottom
                        else if (dem_lndtyp(i) == 2) then                                                                               ! water bottom dz_cm = f(mineral, deep)
                            dz_cm = min_accr_cm(i) - dem_dpsb(i)/10.0 + dz_cm_lndtyp                                                    
                        !! bare ground
                        else if (dem_lndtyp(i) == 3) then                                                                               ! nonvegetated wetland dz_cm = f(mineral, deep, shallow)
                            dz_cm = min_accr_cm(i) - dem_dpsb(i)/10.0 - er_shsb(er,ssub_col)/10.0  + dz_cm_lndtyp                       
                        !! upland/developed
                        else if (dem_lndtyp(i) == 4) then                                                                               ! upland/developed dz_cm = f(deep)
                            dz_cm = 0.0 - dem_dpsb(i)/10.0 + dz_cm_lndtyp                                                               
                        !! flotant marsh
                        else if (dem_lndtyp(i) == 5) then                                                                               ! flotant marsh  dz_cm will only be non-zero if flotant is dead and converts to open water (lnd_change = -2) (value set above)
                            dz_cm = dz_cm_lndtyp                                                                                        
                        end if 
                    end if
                    
                    if (isnan(dz_cm) ) then
                        dz_cm = 0.0
                    end if
                    
                    dem_z(i) = dem_z(i) + dz_cm/100.0                                                                                   ! dz_cm is in cm, DEM is in meters
                    dem_dz_cm(i) = dz_cm                                                                                                ! update dZ array for writing output file
                    
                    !! check if pixel is located in a dredged/maintained channel
                    if (dem_dredge_z(i) /= dem_NoDataVal) then
                        dem_z(i) = dem_dredge_z(i)
                        dem_dz_cm(i) = 0.0
                    end if
                    
                else        
                    dem_z(i) = dem_z_bi(dem_to_bidem(i))                                                                                ! if in BI-DEM domain,, use ICM-BI-DEM elevation as final elevation
                end if
            end if
        end if
    end do
    


    
    return
end
