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
    integer :: i                                                    ! iterator
    integer :: c                                                    ! local compartment ID variable
    integer :: g                                                    ! local grid cell ID variable
    integer :: er                                                   ! local ecoregion ID variable
    real(sp) :: dz                                                  ! change in elevation for DEM pixel during current year (cm)
    real(sp) :: dz_lndtyp                                           ! land-type specific elevation change (e.g. lowering old bareground) (cm)
    
    write(  *,*) ' - updating elevation at end of current year'
    write(000,*) ' - updating elevation at end of current year'
    
    ! convert subsidence arrays from mm/yr (which is input file format) to cm/yr
    er_shsb = er_shsb/10.0
    dem_dpsb = dem_dpsb/10.0

    
    do i = 1,ndem
        c = dem_comp(i)
        er = comp_eco(c)
        if (dem_to_bidem(i) == dem_NoDataVal) then                      ! if pixel is not within barrier island domain            

            dz_lndtyp = 0.0                                             
            
            if (dem_bg_flag(i) == 1) then                               ! lower old bareground pixels
                dz_lndtyp = -5.0
            else if (lnd_change_flag(i) == -2) then                     ! lower dead flotant pixels to 25 cm below mean water level
                dz_lndtyp = (dem_z(i) - (stg_av_yr(c)-0.25) )/100.0     
            else if (lnd_change_flag(i) == -3) then                     ! lower eroded edge pixels to  25 cm below mean water level
                dz_lndtyp = (dem_z(i) - (stg_av_yr(c)-0.25) )/100.0     
            end if            
            
            
            
            if (dem_lndtyp(i) == 1) then
                if (dem_pldr(i) == 1) then                              ! poldered vegetated land dZ = f(deep)
                    dz = 0.0 - dem_dpsb(i) + dz_lndtyp
                else                                                    ! non-polder vegetated land dZ = f(organic, mineral, deep, shallow),
                    dz = org_accr_cm(i) + min_accr_cm(i) - dem_dpsb(i) - er_shsb(er) + dz_lndtyp
                end if
            
            else if (dem_lndtyp(i) == 2) then                           ! water bottom dZ = f(mineral, deep)
                dz = min_accr_cm(i) - dem_dpsb(i) + dz_lndtyp
            
            else if (dem_lndtyp(i) == 3) then                           ! nonvegetated wetland dZ = f(mineral, deep, shallow)

                dz = min_accr_cm(i) - dem_dpsb(i) - er_shsb(er)  + dz_lndtyp
            
            else if (dem_lndtyp(i) == 4) then                           ! upland/developed dZ = f(deep)
                dz = 0.0 - dem_dpsb(i) + dz_lndtyp
            else                                                        ! flotant dZ = 0
                dz = 0.0
            end if 
            
            dem_z(i) = dem_z(i) + dz/100.0                              ! dz is in cm, DEM is in meters
            dem_dz_cm(i) = dz                                           ! update dZ array for writing output file
        
        else        
            dem_z(i) = dem_z_bi(dem_to_bidem(i))                        ! if in BI-DEM domain,, use ICM-BI-DEM elevation as final elevation
        end if
    end do
    
    return
end