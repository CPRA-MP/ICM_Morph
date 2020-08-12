subroutine inundation_thresholds
    ! global arrays updated by subroutine:
    !      lnd_change_flg
    !      grid_pct_upland_wet
    !      grid_pct_upland_dry
    !
    ! Subroutine determines inundation stressors as functions of salinity and depth for two years in a row.
    !
    ! Subroutine also determines whether, for the current year, an upland pixel is inundated enough to be eligible for wetland vegetation.
   
    use params
    implicit none
    
    ! local variables
    integer :: i                                                    ! iterator
    integer :: c                                                    ! local compartment ID variable
    integer :: g                                                    ! local grid cell ID variable
    real(sp) :: dep_yr                                              ! local variable for inundation depth over DEM pixel from current year mean stage
    real(sp) :: sal_yr                                              ! local variable for salinity at DEM pixel from current year mean salinity
    real(sp) :: dep_prev_yr                                         ! local variable for inundation depth over DEM pixel from previous year mean stage
    real(sp) :: sal_prev_yr                                         ! local variable for salinity at DEM pixel from previous year mean salinity
    real(sp) :: Z                                                   ! Z-value for quantile (Z=1.96 is 97.5th percentile)
    real(sp) :: B0                                                  ! coefficient from quantile regression on CRMS annual inundation-salinity data
    real(sp) :: B1                                                  ! coefficient from quantile regression on CRMS annual inundation-salinity data
    real(sp) :: B2                                                  ! coefficient from quantile regression on CRMS annual inundation-salinity data
    real(sp) :: B3                                                  ! coefficient from quantile regression on CRMS annual inundation-salinity data
    real(sp) :: B4                                                  ! coefficient from quantile regression on CRMS annual inundation-salinity data
    real(sp) :: MuDepth                                             ! mean depth for given salinity value from quantile regression - for current year      
    real(sp) :: SigmaDepth                                          ! st dev depth for given salinity value from quantile regression - for current year      
    real(sp) :: DepthThreshold_Wet                                  ! too wet for vegetation - depth threshold for given Z and given salinity value from quantile regression - for current year
    real(sp) :: DepthThreshold_Dry                                  ! too dry for vegetation - depth threshold for given Z and given salinity value from quantile regression - for current year
    real(sp) :: MuDepth_prv                                         ! mean depth for given salinity value from quantile regression - for previous year
    real(sp) :: SigmaDepth_prv                                      ! st dev depth for given salinity value from quantile regression - for previous year      
    real(sp) :: DepthThreshold_Wet_prv                              ! too wet for vegetation - depth threshold for given Z and given salinity value from quantile regression - for previous year
    real(sp) :: ht_abv_mwl_est                                      ! elevation (meters) , relative to annual mean water level, at which point vegetation can establish
    integer,dimension(:),allocatable :: grid_n_upland_wet           ! local count of number of upland pixels in ICM-LAVegMod grid cell that are wet enough for wetland vegetation
    integer,dimension(:),allocatable :: grid_n_upland_dry           ! local count of number of upland pixels in ICM-LAVegMod grid cell that too dry for wetland vegetation
    
    allocate(grid_n_upland_wet(ngrid))
    allocate(grid_n_upland_dry(ngrid))
    
    ! parameters from quantile fit of CRMS annual mean inundation and salinity depth
    ! see ICM-LAVegMod documentation from 2023 updates for analysis and theory
    Z = 1.96
    B0 = 0.0058
    B1 = -0.00207
    B2 = 0.0809
    B3 = 0.0892
    B4 = -0.19
    
    ! elevation (meters) , relative to annual mean water level, at which point vegetation can establish
    ! see ICM-LAVegMod documentation from 2023 updates for analysis and theory
    ht_abv_mwl_est = 0.10
    
    
    ! initialize upland wet/dry counting arrays to zero
    grid_n_upland_wet = 0
    grid_n_upland_dry = 0
    
    do i = 1,ndem
        ! set local copies of grid and compartment numbers
        c = dem_comp(i)
        g = dem_grid(i)
        
        ! reset local variables to zero for loop
        MuDepth = 0.0
        SigmaDepth = 0.0
        DepthThreshold_Wet = 0.0
        DepthThreshold_Dry = 0.0 
        dep_yr = 0.0
        sal_yr = 0.0
        MuDepth_prv = 0.0
        SigmaDepth_prv = 0.0
        DepthThreshold_Wet_prv = 0.0
        dep_prev_yr = 0.0
        sal_prev_yr = 0.0  
        
        ! set local copies of depth and salinity variable for current year
        dep_yr = dem_inun_dep(i,13)
        sal_yr = sal_av_yr(c)
        
        ! if vegetated land - check for inundation stress
        if (dem_lndtyp(i) == 1) then
            MuDepth = B0 + B1*sal_yr
            SigmaDepth = B2 + B3*exp(B4*sal_yr)
            DepthThreshold_Wet =  MuDepth  + Z*SigmaDepth
            
            ! if current year inundation is above threshold, check previous year            
            if (dep_yr >= DepthThreshold_Wet) then
                dep_prev_yr = dem_inun_dep(i,14)
                sal_prev_yr = sal_av_prev_yr(c)
                
                MuDepth_prv = B0 + B1*sal_prev_yr
                SigmaDepth_prv = B2 + B3*exp(B4*sal_prev_yr)
                DepthThreshold_Wet_prv =  MuDepth_prv  + Z*SigmaDepth_prv
                
                ! if both current year and previous year have inundation above threshold, set flag to collapse land
                if (dep_prev_yr >= DepthThreshold_Wet_prv) then
                    lnd_change_flag(i) = -1
                end if
            end if
        
        ! if water - check if current year elevation is above MWL by depth threshold defining whether vegetation can establish
        else if (dem_lndtyp(i) == 2) then
            if (dep_yr < ht_abv_mwl_est) then
                dep_prev_yr = dem_inun_dep(i,14)
                ! if both current year and previous year have elevation above threshold for establishment, convert water to land eligible for vegetation
                if (dep_prev_yr < ht_abv_mwl_est) then
                    lnd_change_flag(i) = 1
                end if
            end if
            
        ! if upland - check if inundation would allow for wetland vegetation to establish
        else if (dem_lndtyp(i) == 5) then
            MuDepth = B0 + B1*sal_yr
            SigmaDepth = B2 + B3*exp(B4*sal_yr)
            DepthThreshold_Dry =  MuDepth - Z*SigmaDepth
            
            if (dep_yr >= DepthThreshold_Dry) then
                grid_n_upland_wet(g) = grid_n_upland_wet(g) + 1 
            else
                grid_n_upland_dry(g) = grid_n_upland_dry(g) + 1
            end if
        end if
    end do        
    
    ! convert count of wet/dry upland pixels into percentage of grid cell
    grid_pct_upland_wet = 0.0
    grid_pct_upland_dry = 0.0

    grid_pct_upland_wet = float(grid_n_upland_wet)/float(grid_ndem_all)
    grid_pct_upland_dry = float(grid_n_upland_dry)/float(grid_ndem_all)
        
    return

end