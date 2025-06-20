subroutine organic_accretion
    ! global arrays updated by subroutine:
    !      org_accr_cm
    !
    ! Subroutine determines annual organic accretion depth as a function of vegetation type (via FFIBS score)
    ! and input values for organic accumulation rates and organic 'self packing density' from
    ! the ideal mixing model (see 2023 Vegetation Model Improvement documentation)
    !
    ! A pixel must be land, have a FFIBS score assigned, and have been inundated at some point during the year to have a non-zero org. accretion.
    !
    ! OMAR values for marsh type are interpolated based on the central FFIBS value for each habitat type.
    
    
    use params
    implicit none
    
    ! local variables
    integer :: i                                                                                            ! iterator
    integer :: g                                                                                            ! local grid ID variable
    integer :: c                                                                                            ! local compartment ID variable
    integer :: e                                                                                            ! local ecoregion variable
    real(sp) :: FIBS                                                                                        ! local variable to store FIBS score of grid cell
    real(sp) :: omar_low                                                                                    ! local variable to store lower interpolation value for organic matter accumulation (g/cm2-yr)
    real(sp) :: omar_upr                                                                                    ! local variable to store upper interpolation value for organic matter accumulation (g/cm2-yr)
    real(sp) :: OMAR                                                                                        ! organic matter accumulation value for pixel derived from FIBS score (g/cm2-yr)
    real(sp) :: int_wgt                                                                                     ! weighting factor determined via interpolation on FIBS score
    real(sp) :: bd                                                                                          ! bulk density calculated locally

    
    
    org_accr_cm = 0.0                                                                                       ! initialize organic accretion array to 0

    if (OMAR_interp == 0) then                                                                              ! if flag=0 then use hard-coded equations OMAR=f(FFIBS)
        do i = 1,ndem
            if (dem_to_bidem(i) == dem_NoDataVal) then                                                      ! only proceed if pixel is not within barrier island domain
                if (dem_lndtyp(i) == 1) then                                                                ! if pixel is vegetated land, calculate organic accretion
                    g = dem_grid(i)
                    c = dem_comp(i)
                    if (c /= dem_NoDataVal) then
                        e = comp_eco(c)
                        if (e /= dem_NoDataVal) then
                            if (g /= dem_NoDataVal) then    
                                if (maxval(dem_inun_dep(i,:)) > 0) then                                     ! check that the pixel was inundated at some point during year
                                    FIBS = grid_FIBS_score(g)                                                   
                                    if (FIBS >= 0.0) then                                                   ! check that there is a FIBS score for grid cell
                                        if (comp_act_dlt(c) == 1) then                                      ! check if compartment is active delta and has at least some fresh and/or intermediate marsh present (based on FFIBS score)
                                            if (FIBS > FIBS_intvals(1)) then                                ! FRESH MARSH: FORESTED/FRESH MIX - FIBS_intvals(2) indicates start of fresh marsh range of FFIBS values
                                                if (FIBS < FIBS_intvals(4)) then                            ! FIBS_intvals(4) indicates *start* of brackish marsh range of FFIBS values
                                                    OMAR = er_omar(e,6)                                     ! use OMAR for fresh/int marsh in active deltas
                                                end if
                                            end if
                                        else
                                            if (comp_dlt_chnr(c) == 1) then                                 ! OMAR equation for Deltaic Plain
                                                FIBS = min(max(FIBS,0.258),24.000)                          ! the min/max value for FIBS in DP used to develop eqtns are 0.258 & 24.0, respectively
                                                OMAR = 0.084059081 - 0.001607118*FIBS + 0.000082767*FIBS**2                                                              
                                            else if (comp_dlt_chnr(c) == 2) then                            ! OMAR equation for Chenier Plain
                                                FIBS = min(max(FIBS,0.679),23.138)                          ! the min/max value for FIBS in CP used to develop eqtns are 0.679 & 23.138, respectively
                                                OMAR = 0.081149392 - 0.004957864*FIBS + 0.000214164*FIBS**2
                                            end if
                                        end if
                                        org_accr_cm(i) = OMAR / om_k1                                       ! OMAR [g/cm2] * k1 [g/cm3] = cm organic accretion
                                    end if  
                                end if
                            end if
                        end if
                    end if
                end if
            end if
        end do
    
    else if (OMAR_interp == 1) then                                                                             ! if flag=1 then linear interpolate between input values for OMAR by ecoregion
        do i = 1,ndem
            if (dem_to_bidem(i) == dem_NoDataVal) then                                                          ! only proceed if pixel is not within barrier island domain
                if (dem_lndtyp(i) == 1) then                                                                    ! if pixel is vegetated land, calculate organic accretion
                    g = dem_grid(i)
                    c = dem_comp(i)
                    if (c /= dem_NoDataVal) then
                        e = comp_eco(c)
                        if (e /= dem_NoDataVal) then
                            if (g /= dem_NoDataVal) then    
                                if (maxval(dem_inun_dep(i,:)) > 0) then                                                 ! check that the pixel was inundated at some point during year
                                    FIBS = grid_FIBS_score(g)
    
                                    if (FIBS >= 0.0) then                                                               ! check that there is a FIBS score for grid cell
                                        if (FIBS < FIBS_intvals(1)) then                                                ! FORESTED - FIBS_intvals(1) indicates *start* of forested wetland range of FFIBS values
                                            int_wgt = 0                                                                 ! no interpolation for lowest FIBS score (forested) - use lowest OMAR     
                                            omar_low = er_omar(e,1)
                                            omar_upr = er_omar(e,1)
                                        else if (FIBS < FIBS_intvals(2)) then                                           ! FRESH MARSH: FORESTED/FRESH MIX - FIBS_intvals(2) indicates start of fresh marsh range of FFIBS values
                                            int_wgt = (FIBS - FIBS_intvals(1)) / (FIBS_intvals(2) - FIBS_intvals(1))    
                                            if (comp_act_dlt(c) == 0) then                                              ! if compartment is not active delta
                                                omar_low = er_omar(e,1)                                                 ! use default fresh marsh OMAR
                                                omar_upr = er_omar(e,2)
                                            else                                                                        ! if compartment is flagged as active delta
                                                omar_low = er_omar(e,6)                                                 ! use OMAR for fresh/int marsh in active deltas
                                                omar_upr = er_omar(e,6)                                                 ! there is no interpolation on active delta OMAR so use same value
                                            end if
                                        else if (FIBS < FIBS_intvals(3)) then                                           ! FRESH MARSH: FRESH/INTERMEDIATE MIX- FIBS_intvals(3) indicates *start* of intermediate marsh range of FFIBS values
                                            int_wgt = (FIBS - FIBS_intvals(2)) / (FIBS_intvals(3) - FIBS_intvals(2))    
                                            if (comp_act_dlt(c) == 0) then                                              ! if compartment is not active delta
                                                omar_low = er_omar(e,2)                                                 ! use default int marsh OMAR
                                                omar_upr = er_omar(e,3)
                                            else
                                                omar_low = er_omar(e,6)                                                 ! use OMAR for fresh/int marsh in active deltas
                                                omar_upr = er_omar(e,6)                                                 ! there is no interpolation on active delta OMAR so use same value
                                            end if
                                        else if (FIBS < FIBS_intvals(4)) then                                           ! INTERMEDIATE MARSH: INTERMEDIATE/BRACKISH MIX - FIBS_intvals(4) indicates *start* of brackish marsh range of FFIBS values
                                            int_wgt = (FIBS - FIBS_intvals(3)) / (FIBS_intvals(4) - FIBS_intvals(3))    
                                            if (comp_act_dlt(c) == 0) then                                              ! if compartment is not active delta
                                                omar_low = er_omar(e,3)
                                                omar_upr = er_omar(e,4)
                                            else
                                                omar_low = er_omar(e,6)                                                 ! use OMAR for fresh/int marsh in active deltas
                                                omar_upr = er_omar(e,6)                                                 ! there is no interpolation on active delta OMAR so use same value
                                            end if
                                        else if (FIBS < FIBS_intvals(5)) then                                           ! BRACKISH MARSH: BRACKISH/SALINE MIX - FIBS_intvals(5) indicates *start* of saline marsh range of FFIBS values
                                            int_wgt = (FIBS - FIBS_intvals(4)) / (FIBS_intvals(5) - FIBS_intvals(4))
                                            omar_low = er_omar(e,4)
                                            omar_upr = er_omar(e,5)
                                        else                                                                            ! SALINE MARSH - no interpolation for highest FIBS score (saline) - use highest OMAR
                                            int_wgt = 0   
                                            omar_low = er_omar(e,5)
                                            omar_upr = er_omar(e,5)
                                        end if
                                    
                                        OMAR = omar_low + int_wgt*(omar_upr - omar_low)
                                        
                                        org_accr_cm(i) = OMAR / om_k1                                                   ! OMAR [g/cm2] * k1 [g/cm3] = cm organic accretion            
                                    end if
                                end if
                            end if
                        end if
                    end if
                end if
            end if
        end do
    end if
    
    
    
    return

end
