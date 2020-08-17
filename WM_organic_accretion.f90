subroutine organic_accretion
    ! global arrays updated by subroutine:
    !      org_accr_cm
    !
    ! Subroutine determines annual organic accretion depth as a function of vegetation type (via FFIBS score)
    ! and input values for organic accumulation rates and organic 'self packing density' from
    ! the ideal mixing model (see 2023 Vegetation Model Improvement documentation)
    !
    !
    
    
    use params
    implicit none
    
    ! local variables
    integer :: i                                                                                    ! iterator
    integer :: g                                                                                    ! local grid ID variable
    integer :: c                                                                                    ! local compartment ID variable
    integer :: e                                                                                    ! local ecoregion variable
    real(sp) :: FIBS                                                                                ! local variable to store FIBS score of grid cell
    real(sp) :: omar_low                                                                            ! local variable to store lower interpolation value for organic matter accumulation (g/cm2-yr)
    real(sp) :: omar_upr                                                                            ! local variable to store upper interpolation value for organic matter accumulation (g/cm2-yr)
    real(sp) :: bd                                                                                  ! bulk density calculated locally
    real(sp) :: om_k1                                                                               ! organic matter self-packing density  of wetland soils (g/cm3)
    real(sp) :: OMAR                                                                                ! organic matter accumulation value for pixel derived from FIBS score (g/cm2-yr)
    real(sp) :: int_wgt                                                                             ! weighting factor determined via interpolation on FIBS score
    real(sp),dimension(:),allocatable :: FIBS_intvals                                               ! local array that stores FIBS values used to interpolate between

    
    allocate(FIBS_intvals(6))
    
    org_accr_cm = 0.0                                                                               ! initialize organic accretion array to 0
    
    FIBS_intvals(1) = 0.0                                                                           ! FIBS score that will serve as lower end for Fresh forested
    FIBS_intvals(2) = 0.15                                                                          ! FIBS score that will serve as lower end for Fresh marsh
    FIBS_intvals(3) = 1.5                                                                           ! FIBS score that will serve as lower end for Intermediate marsh
    FIBS_intvals(4) = 5                                                                             ! FIBS score that will serve as lower end for Brackish marsh
    FIBS_intvals(5) = 18                                                                            ! FIBS score that will serve as lower end for Saline marsh
    FIBS_intvals(6) = 24                                                                            ! FIBS score that will serve as lower end for Saline marsh
    
    om_k1 =  0.076                                                                                  ! organic matter self-packing density (g/cm3) from CRMS soil data (see 2023 Wetlands Model Improvement report)

    do i = 1,ndem
        if (dem_to_bidem(i) == dem_NoDataVal) then                                                  ! only proceed if pixel is not within barrier island domain
            if (dem_lndtyp(i) == 1) then                                                            ! if pixel is vegetated land, calculate organic accretion
                g = dem_grid(i)
                c = dem_comp(i)
                e = comp_eco(c)
                
                FIBS = grid_FIBS_score(g)
                if (FIBS >= 0.0) then                                                               ! check that there is a FIBS score for grid cell
                    
                    if (FIBS < FIBS_intvals(2)) then                                                ! FIBS indicates forested wetland
                        int_wgt = (FIBS - FIBS_intvals(1)) / (FIBS_intvals(2) - FIBS_intvals(1))
                        omar_low = er_omar(e,1)
                        omar_upr = er_omar(e,2)
                    else if (FIBS < FIBS_intvals(3)) then                                           ! FIBS indicates fresh marsh
                        int_wgt = (FIBS - FIBS_intvals(2)) / (FIBS_intvals(3) - FIBS_intvals(2))
                        if (comp_act_dlt(c) == 0) then                                              ! if compartment is not active delta
                            omar_low = er_omar(e,2)                                                 ! use default fresh marsh OMAR
                            omar_upr = er_omar(e,3)
                        else                                                                        ! if compartment is flagged as active delta
                            omar_low = er_omar(e,6)                                                 ! use OMAR for fresh marsh in active deltas
                            omar_low = er_omar(e,6)
                        end if
                    else if (FIBS < FIBS_intvals(4)) then                                           ! FIBS indicates intermediate marsh
                        int_wgt = (FIBS - FIBS_intvals(3)) / (FIBS_intvals(4) - FIBS_intvals(3))
                        omar_low = er_omar(e,3)
                        omar_upr = er_omar(e,4)
                    else if (FIBS < FIBS_intvals(5)) then                                           ! FIBS indicates brackish marsh
                        int_wgt = (FIBS - FIBS_intvals(4)) / (FIBS_intvals(5) - FIBS_intvals(4))
                        omar_low = er_omar(e,4)
                        omar_upr = er_omar(e,5)
                    else                                                                            ! FIBS indicates saline marsh
                        int_wgt = (FIBS - FIBS_intvals(5)) / (FIBS_intvals(6) - FIBS_intvals(5))       
                        omar_low = er_omar(e,5)
                        omar_upr = er_omar(e,5)
                    end if
                     
                    OMAR = omar_low + int_wgt*(omar_upr - omar_low)
                    org_accr_cm(i) = OMAR / om_k1                                                   ! OMAR [g/cm2] * k1 [g/cm3] = cm organic accretion
            
                end if    
            end if
        end if
    end do
    
    
    
    return

end