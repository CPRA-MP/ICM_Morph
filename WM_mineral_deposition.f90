subroutine mineral_deposition
    ! global arrays updated by subroutine:
    !      min_accr_cm
    !
    ! Subroutine determines annual mineral sediment accretion depth as a function of monthly inundation extent
    ! and monthly mineral sediment deposition.
    ! 
    ! Subroutine will only calculate positive accretion on land surface, but open water area can either be 
    ! positive (net deposition) or negative (net erosion).
    !
    !
    
    
    use params
    implicit none
    
    ! local variables
    integer :: i                                                                    ! iterator
    integer :: ci                                                                   ! iterator
    integer :: mni                                                                  ! iterator
    integer :: g                                                                    ! local grid ID variable
    integer :: c                                                                    ! local compartment ID variable
    integer :: e                                                                    ! local ecoregion variable
    integer :: mn                                                                   ! local month variable
    real(sp) :: sed_dp_int                                                          ! local variable to sum annual interior sediment deposition at pixel from monthly inputs
    real(sp) :: sed_dp_edge                                                         ! local variable to sum annual edge sediment deposition at pixel from monthly inputs
    real(sp) :: sed_dp_wat                                                          ! local variable to sum annual open water sediment erosion/deposition at pixel from monthly inputs
    real(sp),dimension(:,:),allocatable :: sed_dp_mi_mons_corr                      ! local array storing monthly mineral sediment deposition per unit area - corrected for ratio of marsh that was inundated during each respective month
    
    allocate(sed_dp_mi_mons_corr(ncomp,12))

    min_accr_cm = 0.0                                                               ! initialize mineral depositional accretion array to 0
    
    sed_dp_mi_mons_corr = 0.0
    do ci = 1,ncomp                                                                 ! update mineral sediment deposition per unit area of interior marsh
        do mni = 1,12                                                               ! by the portion of the marsh that was inundated during each respective month
            if (comp_ndem_wet(ci,mni) /= 0 ) then    
                sed_dp_mi_mons_corr(ci,mni)  = sed_dp_mi_mons(ci,mni)!/(comp_ndem_wet(ci,mni)/comp_ndem_all(ci))
            end if
        end do
    end do
    
    do ci = 1,ncomp                                                                 ! update mineral sediment deposition per unit area of interior marsh
        do mni = 1,12
            write(*,6666 )  ci,mni,sed_dp_mi_mons(ci,mni),comp_ndem_wet(ci,mni),comp_ndem_all(ci),sed_dp_mi_mons_corr(ci,mni),sed_dp_me_mons(ci,mni),sed_dp_ow_mons(ci,mni)
        end do
    end do
6666 format(2(I0,','),F0.4,',',2(I0,','),2(F0.4,','),F0.4)

     
                
    do i = 1,ndem
        if (dem_to_bidem(i) == dem_NoDataVal) then                                  ! only proceed if pixel is not within barrier island domain        
            c = dem_comp(i)
            sed_dp_int  = 0.0
            sed_dp_edge = 0.0
            sed_dp_wat  = 0.0            
            if (c /= dem_NoDataVal) then                                            ! for pixels that have data for ICM-Hydro compartment ID
                do mn = 1,12                                                        ! sum monthly deposition for open water, edge and interior areas over entire year
                    sed_dp_int  = sed_dp_int  + sed_dp_mi_mons_corr(c,mn)/10000.0   ! mineral deposition is calculated in ICM-Hydro (and read in in PREPROCESSING) in g/m^2
                    sed_dp_edge = sed_dp_edge + sed_dp_me_mons(c,mn)/10000.0        ! use interior deposition corrected for inundation extents
                    sed_dp_wat  = sed_dp_wat  + sed_dp_ow_mons(c,mn)/10000.0        ! must convert to g/cm^2    ! [g/cm^2] = [g/m^2]*[m/100 cm]*[m/100 cm] = [g/m^2]/10000
                end do
                                                                                    ! convert sediment deposition mass per area to vertical accretion in cm        
                if (dem_lndtyp(i) < 4) then                                         ! skip if pixel is flotant marsh (lndtyp = 5) or upland/developed (lndtyp = 4)
                    if (dem_lndtyp(i) == 2) then                                    ! if pixel is water, calcuate open water deposition/erosion depth
                        min_accr_cm(i) = sed_dp_wat / ow_bd                         ! mineral depostion [g/cm2] / open water bed bulk density [g/cm3] = depth mineral deposition/erosion [cm]
                    else                                                            ! pixel is either vegetated or nonvegeted wetland (lndtyp = 1 or lndtyp = 3)
                        if (dem_edge(i) == 1) then                                  ! pixel is edge and receives deposition of larger particles (as calculated in ICM-Hydro)
                            min_accr_cm(i) = sed_dp_edge / mn_k2                    ! mineral depostion [g/cm2] / mineral self packing density [g/cm3] = depth mineral deposition/erosion [cm]
                        else                                                        ! pixel is marsh interior and recieves smaller particles only on portions inundated 
                            min_accr_cm(i) = sed_dp_int / mn_k2                     ! mineral depostion [g/cm2] / mineral self packing density [g/cm3] = depth mineral deposition/erosion [cm]
                        end if
                    end if
                end if
            end if
        end if
    end do
    
    
    
    return
end