module params
    
!! module to define parameter types for all global variables    
    
    implicit none

    ! generic variables used across all subroutines
    integer,parameter :: sp=selected_real_kind(p=6)                 ! determine single precision kind value   
    integer,parameter :: dp=selected_real_kind(p=13)                ! determine double precision kind value
    integer :: ndem                                                 ! number of DEM pixels in xyzc file
    integer :: ncomp                                                ! number of ICM-Hydro compartments
    integer :: ngrid                                                ! number of ICM-LAVegMod grid cells
    integer :: dem_res                                              ! XY resolution of DEM (m)
    character*3000 :: dump_txt                                      ! dummy variable to use for skipping lines in input files
    integer :: dump_int                                             ! dummy variable to use for data in input files
    real(sp) :: dump_flt                                            ! dummy variable to use for data in input files
    
    ! I/O files in subroutine: MAIN
    character*100 :: morph_log_file                                 ! file name of text file that logs all Morph print statements - no filepath will save this in executable directory
    character*100 :: dem_file                                       ! file name, with relative path, to DEM XYZ file
    character*100 :: hydro_comp_out_file                            ! file name, with relative path, to compartment_out.csv file saved by ICM-Hydro
    character*100 :: veg_out_file                                   ! file name, with relative path, to *vegty.asc+ file saved by ICM-LAVegMod    
    character*100 :: grid_summary_eoy_file                          ! file name, with relative path, to summary grid file for end-of-year landscape
    
    ! define variables read in or calculated from xyzc file in subroutine: PREPROCESSING
    integer,dimension(:),allocatable :: dem_x                       ! x-coordinate of DEM pixel (UTM m, zone 15N)
    integer,dimension(:),allocatable :: dem_y                       ! y-coordinate of DEM pixel (UTM m, zone 15N)
    real(sp),dimension(:),allocatable :: dem_z                      ! average elevation of DEM pixel (m NAVD88)
    integer,dimension(:),allocatable :: dem_comp                    ! ICM-Hydro compartment  ID overlaying DEM pixel (-)
    integer,dimension(:),allocatable :: dem_grid                    ! ICM-LAVegMod grid  ID overlaying DEM pixel (-)
    integer :: dem_LLx                                              ! lower left X-coordinate of DEM grid
    integer :: dem_LLy                                              ! lower left Y-coordinate of DEM grid
    integer :: dem_URx                                              ! upper right X-coordinate of DEM grid
    integer :: dem_URy                                              ! upper right Y-coordinate of DEM grid
    integer,dimension(:),allocatable :: dem_col                     ! same as dem_x but use column number instead of X coordinate
    integer,dimension(:),allocatable :: dem_row                     ! same as dem_y but use column number instead of Y coordinate
    integer,dimension(:),allocatable :: comp_ndem_all               ! number of DEM pixels within each ICM-Hydro compartment (-)
    integer,dimension(:),allocatable :: grid_ndem_all               ! number of DEM pixels within each ICM-LAVegMod grid cell (-)                                                         
    integer,dimension(:),allocatable :: dem_lndtyp                  ! Land type classification of DEM pixel
                                                                    !               1 = vegetated wetland
                                                                    !               2 = water
                                                                    !               3 = flotant marsh
                                                                    !               4 = unvegetated wetland/new subaerial unvegetated mudflat (e.g., bare ground)
                                                                    !               5 = developed land/upland/etc. that are not modeled in ICM-LAVegMod
    
    ! define variables read in or calculated from compartment_out Hydro summary file in subroutine: PREPROCESSING
    real(sp),dimension(:),allocatable :: stg_mx_yr                  ! max stage - annual (m NAVD88)
    real(sp),dimension(:),allocatable :: stg_av_yr                  ! mean stage - annual (m NAVD88)
    real(sp),dimension(:),allocatable :: stg_av_smr                 ! mean stage - summer (m NAVD88)
    real(sp),dimension(:),allocatable :: stg_sd_smr                 ! standard deviation of stage - summer - aka water level variability (m)
    real(sp),dimension(:),allocatable :: sal_av_yr                  ! mean salinity - annual (ppt)
    real(sp),dimension(:),allocatable :: sal_av_smr                 ! mean salinity - summer (ppt)
    real(sp),dimension(:),allocatable :: sal_mx_14d_yr              ! max 2wk mean salinity - annual (ppt)
    real(sp),dimension(:),allocatable :: tmp_av_yr                  ! mean temperature - annual (deg C)
    real(sp),dimension(:),allocatable :: tmp_av_smr                 ! mean temperature - summer (deg C)
    real(sp),dimension(:),allocatable :: sed_dp_ow_yr               ! mineral sediment deposition - open water (g/m^2)
    real(sp),dimension(:),allocatable :: sed_dp_mi_yr               ! mineral sediment deposition - interior marsh (g/m^2)
    real(sp),dimension(:),allocatable :: sed_dp_me_yr               ! mineral sediment deposition - marsh edge (g/m^2)
    real(sp),dimension(:),allocatable :: tidal_prism_ave            ! tidal prism volume - annual cumulative (m^3)
    real(sp),dimension(:),allocatable :: ave_sepmar_stage           ! mean stage - fall/winter for HSI (Jan,Feb,Mar,Sept,Oct,Nov,Mar) (m NAVD88)
    real(sp),dimension(:),allocatable :: ave_octapr_stage           ! mean stage - winter for HSI (Jan,Feb,Mar,Apr,Oct,Nov,Mar) (m NAVD88)
    real(sp),dimension(:),allocatable :: marsh_edge_erosion_rate    ! marsh edge erosion rate for ICM-Hydro compartment (m/yr)
    real(sp),dimension(:),allocatable :: ave_annual_tss             ! mean total suspended solids - annual (mg/L)
    real(sp),dimension(:),allocatable :: stdev_annual_tss           ! standard deviation of total suspended solids - annual (mg/L)
    real(sp),dimension(:),allocatable :: totalland_m2               ! land area in ICM-Hydro compartmnet (m^2)

    ! define variables read in or calculated from vegtype ICM-LAVegMod summary file in subroutine: PREPROCESSING
    real(sp),dimension(:),allocatable :: grid_pct_water             ! percent of ICM_LAVegMod grid cell that is water
    real(sp),dimension(:),allocatable :: grid_pct_upland            ! percent of ICM-LAVegMod grid cell that is upland/developed (e.g., NotMod) and is too high and dry for wetland vegetation
    real(sp),dimension(:),allocatable :: grid_pct_bare              ! percent of ICM-LAVegMod grid cell that is non-vegetated wetland (bare ground)
    real(sp),dimension(:),allocatable :: grid_pct_dead_flt          ! percent of ICM_LAVegMod grid cell that converted from flotant marsh to water during year
    real(sp),dimension(:),allocatable :: grid_pct_vglnd_BLHF        ! percent of vegetated land that is bottomland hardwood forest
    real(sp),dimension(:),allocatable :: grid_pct_vglnd_SWF         ! percent of vegetated land that is swamp forest
    real(sp),dimension(:),allocatable :: grid_pct_vglnd_FM          ! percent of vegetated land that is fresh (attached) marsh 
    real(sp),dimension(:),allocatable :: grid_pct_vglnd_IM          ! percent of vegetated land that is intermediate marsh
    real(sp),dimension(:),allocatable :: grid_pct_vglnd_BM          ! percent of vegetated land that is brackish marsh
    real(sp),dimension(:),allocatable :: grid_pct_vglnd_SM          ! percent of vegetated land that is saline marsh
    real(sp),dimension(:),allocatable :: grid_FIBS_score            ! weighted FIBS score of ICM-LAVegMod grid cell - used for accretion
    
    ! define global variables calculated in subroutine: INUNDATION
    real(sp),dimension(:,:),allocatable :: dem_inun_dep             ! inundation depth at each DEM pixel from monthly and annual mean water levels (m)
    integer,dimension(:,:),allocatable :: comp_ndem_wet             ! number of inundated DEM pixels within each ICM-Hydro compartment from monthly and annual mean water levels (-)
    integer,dimension(:,:),allocatable :: grid_ndem_wet             ! number of inundated DEM pixels within each ICM-LAVegMod grid cell from monthly and annual mean water levels (-)
   
    ! define global variables that are used summarizing end-of-year landscape per LAVegMod grid cell
    real(sp),dimension(:),allocatable :: grid_pct_vg_land           ! percent of ICM_LAVegMod grid cell that is vegetated land
    real(sp),dimension(:),allocatable :: grid_pct_flt               ! percent of ICM_LAVegMod grid cell that is flotant marsh
    
    real(sp),dimension(:),allocatable :: comp_pct_water             ! percent of ICM-Hydro compartment that is open water
    real(sp),dimension(:),allocatable :: comp_pct_wetland           ! percent of ICM-Hydro compartment that is wetland (attached vegetated + flotant_ + non-vegetated)
    real(sp),dimension(:),allocatable :: comp_pct_upland            ! percent of ICM-Hydro compartment that is upland (not modeled in ICM-LAVegMod)
    real(sp),dimension(:),allocatable :: comp_wetland_elev          ! average elevation of wetland in ICM-Hydro compartment
    real(sp),dimension(:),allocatable :: comp_water_elev            ! average elevation of water bottom in ICM-Hydro compartment
    
    ! DEM mapping arrays tha tare allocated in their own allocation subroutine DEM_PARAMS_ALLOC
    integer,dimension(:,:),allocatable :: dem_index_mapped          ! DEM grid IDs, mapped
    
end module params