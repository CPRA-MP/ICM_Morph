module params
    
!! module to define parameter types for all global variables    
    
    implicit none

    ! generic variables used across all subroutines
    integer,parameter :: sp=selected_real_kind(p=6)                 ! determine single precision kind value   
    integer,parameter :: dp=selected_real_kind(p=13)                ! determine double precision kind value
    integer :: elapsed_year                                         ! elapsed year of model simulation
    integer :: dem_NoDataVal                                        ! value representing NoData in input XYZ rasters
    integer :: ndem                                                 ! number of DEM pixels in xyzc file
    integer :: ncomp                                                ! number of ICM-Hydro compartments
    integer :: ngrid                                                ! number of ICM-LAVegMod grid cells
    integer :: neco                                                 ! number of ecoregions used to summarize data
    integer :: dem_res                                              ! XY resolution of DEM (m)
    integer :: nlt                                                  ! number of landtype classification
                                                                    ! **** nlt must equal the number of classifications in dem_lndtyp variable defined below****

    
    character*3000 :: dump_txt                                      ! dummy variable to use for skipping lines in input files
    integer :: dump_int                                             ! dummy variable to use for data in input files
    real(sp) :: dump_flt                                            ! dummy variable to use for data in input files
    
    ! I/O files in subroutine: MAIN
    character*100 :: morph_log_file                                 ! file name of text file that logs all Morph print statements - no filepath will save this in executable directory
    character*100 :: dem_file                                       ! file name, with relative path, to DEM XYZ file
    character*100 :: lwf_file                                       ! file name, with relative path, to land/water file that is same resolution and structure as DEM XYZ
    character*100 :: meer_file                                      ! file name, with relative path, to marsh edge erosion rate file that is same resolution and structure as DEM XYZ
    character*100 :: pldr_file                                      ! file name, with relative path, to polder file that is same resolution and structure as DEM XYZ (0=non-poldered pixel; 1=pixel within a polder)
    character*100 :: grid_file                                      ! file name, with relative path, to ICM-LAVegMod grid map file that is same resolution and structure as DEM XYZ
    character*100 :: comp_file                                      ! file name, with relative path, to ICM-Hydro compartment map file that is same resolution and structure as DEM XYZ
    character*100 :: dsub_file                                      ! file name, with relative path, to deep subsidence rate map file that is same resolution and structure as DEM XYZ (mm/yr; positive values are for downward VLM)
    character*100 :: ssub_file                                      ! file name, with relative path, to shallow subsidence table with statistics by ecoregion (mm/yr; positive values are for downward VLM)
    character*100 :: act_del_file                                   ! file name, with relative path, to lookup table that identifies whether an ICM-Hydro compartment is assigned as an 'active delta' site for use with Fresh Marsh organic accretion
    character*100 :: comp_eco_file                                  ! file name, with relative path, to lookup table that assigns an ecoregion to each ICM-Hydro compartment    
    
    character*100 :: hydro_comp_out_file                            ! file name, with relative path, to compartment_out.csv file saved by ICM-Hydro
    character*100 :: prv_hydro_comp_out_file                        ! file name, with relative path, to compartment_out.csv file saved by ICM-Hydro for previous year
    character*100 :: monthly_mean_stage_file                        ! file name, with relative path, to compartment summary file with monthly mean water levels
    character*100 :: monthly_max_stage_file                         ! file name, with relative path, to compartment summary file with monthly maximum water levels 
    character*100 :: monthly_ow_sed_dep_file                        ! file name, with relative path, to compartment summary file with monthly sediment deposition in open water
    character*100 :: monthly_mi_sed_dep_file                        ! file name, with relative path, to compartment summary file with monthly sediment deposition on interior marsh
    character*100 :: monthly_me_sed_dep_file                        ! file name, with relative path, to compartment summary file with monthly sediment deposition on marsh edge
    character*100 :: veg_out_file                                   ! file name, with relative path, to *vegty.asc+ file saved by ICM-LAVegMod    
    character*100 :: edge_eoy_xyz_file                              ! file name, with relative path, to XYZ raster output file for edge pixels
    character*100 :: dem_eoy_xyz_file                               ! file name, with relative path, to XYZ raster output file for topobathy DEM
    character*100 :: lndtyp_eoy_xyz_file                            ! file name, with relative path, to XYZ raster output file for land type
    character*100 :: lndchng_eoy_xyz_file                           ! file name, with relative path, to XYZ raster output file for land change flag
    character*100 :: grid_summary_eoy_file                          ! file name, with relative path, to summary grid file for end-of-year landscape
    character*100 :: grid_data_file                                 ! file name, with relative path, to summary grid data file used internally by ICM
    character*100 :: grid_depth_file_Gdw                            ! file name, with relative path, to Gadwall depth grid data file used internally by ICM and HSI
    character*100 :: grid_depth_file_GwT                            ! file name, with relative path, to Greenwing Teal depth grid data file used internally by ICM and HSI
    character*100 :: grid_depth_file_MtD                            ! file name, with relative path, to Mottled Duck depth grid data file used internally by ICM and HSI 
    character*100 :: grid_pct_edge_file                             ! file name, with relative path, to percent edge grid data file used internally by ICM and HSI 
    
    character*100 :: comp_elev_file                                 ! file name, with relative path, to elevation summary compartment file used internally by ICM
    character*100 :: comp_wat_file                                  ! file name, with relative path, to percent water summary compartment file used internally by ICM
    character*100 :: comp_upl_file                                  ! file name, with relative path, to percent upland summary compartment file used internally by ICM 
    
    
    
    
    ! define variables read in or calculated from xyz files in subroutine: PREPROCESSING
    integer,dimension(:),allocatable ::  dem_x                       ! x-coordinate of DEM pixel (UTM m, zone 15N)
    integer,dimension(:),allocatable ::  dem_y                       ! y-coordinate of DEM pixel (UTM m, zone 15N)
    integer,dimension(:),allocatable ::  dem_comp                    ! ICM-Hydro compartment ID overlaying DEM pixel (-)
    integer,dimension(:),allocatable ::  dem_grid                    ! ICM-LAVegMod grid ID overlaying DEM pixel (-)
    real(sp),dimension(:),allocatable :: dem_z                       ! average elevation of DEM pixel (m NAVD88)
    real(sp),dimension(:),allocatable :: dem_meer                    ! marsh edge erosion rate of DEM pixel (m / yr)
    real(sp),dimension(:),allocatable :: dem_dpsb                    ! deep subsidence rate of DEM pixel (mm / yr; positive indicates downward VLM)
    real(sp),dimension(:),allocatable :: er_shsb                     ! shallow subsidence for ecoregion (mm/yr; positive indicates downward VLM)
    integer,dimension(:),allocatable ::  comp_eco                    ! ecoregion number of ICM-Hydro compartment
    integer,dimension(:),allocatable ::  comp_act_dlt                ! flag indicating whether ICM-Hydro compartment is considered an active delta for fresh marsh organic accretion (0=inactive; 1=active)
        
    
    integer :: dem_LLx                                              ! lower left X-coordinate of DEM grid
    integer :: dem_LLy                                              ! lower left Y-coordinate of DEM grid
    integer :: dem_URx                                              ! upper right X-coordinate of DEM grid
    integer :: dem_URy                                              ! upper right Y-coordinate of DEM grid
    integer,dimension(:),allocatable :: dem_col                     ! same as dem_x but use column number instead of X coordinate
    integer,dimension(:),allocatable :: dem_row                     ! same as dem_y but use column number instead of Y coordinate
    integer,dimension(:),allocatable :: comp_ndem_all               ! number of DEM pixels within each ICM-Hydro compartment (-)
    integer,dimension(:),allocatable :: grid_ndem_all               ! number of DEM pixels within each ICM-LAVegMod grid cell (-)                                                         
    integer,dimension(:),allocatable :: dem_lndtyp                  ! Land type classification of DEM pixel
                                                                    ! ****dem_lntyp must correspond with nlt variable defined above****
                                                                    !               1 = vegetated wetland
                                                                    !               2 = water
                                                                    !               3 = unvegetated wetland/new subaerial unvegetated mudflat (e.g., bare ground)
                                                                    !               4 = developed land/upland/etc. that are not modeled in ICM-LAVegMod
                                                                    !               5 = flotant marsh
    
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

    ! define variables read in from previous year's compartment_out Hydro summary file in subroutine: PREPROCESSING
    real(sp),dimension(:),allocatable :: stg_av_prev_yr             ! mean stage from previous year - annual (ppt)
    real(sp),dimension(:),allocatable :: sal_av_prev_yr             ! mean salinity from previous year - annual (ppt)
    
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
    
    ! define variables read in from monthly summary files  in subroutine: PREPROCESSING
    real(sp),dimension(:,:),allocatable :: stg_av_mons              ! monthly mean stage (m NAVD88) - second dimension (1-12) corresponds to month 
    real(sp),dimension(:,:),allocatable :: stg_mx_mons              ! monthly max stage (m NAVD88) - second dimension (1-12) corresponds to month 
    real(sp),dimension(:,:),allocatable :: sed_dp_ow_mons           ! monthly mineral sediment deposition - open water (g/m^2) - second dimension (1-12) corresponds to month 
    real(sp),dimension(:,:),allocatable :: sed_dp_mi_mons           ! monthly mineral sediment deposition - interior marsh (g/m^2) - second dimension (1-12) corresponds to month 
    real(sp),dimension(:,:),allocatable :: sed_dp_me_mons           ! monthly mineral sediment deposition - marsh edge (g/m^2) - second dimension (1-12) corresponds to month 

    ! define variables calculated in subroutine: EDGE_DELINEATION
    integer,dimension(:),allocatable :: dem_edge                    ! flag indicating whether DEM pixel is edge (0=non edge; 1=edge)
    
    ! define global variables calculated in subroutine: INUNDATION
    real(sp),dimension(:,:),allocatable :: dem_inun_dep             ! inundation depth at each DEM pixel from monthly and annual mean water levels (m)
    integer,dimension(:,:),allocatable :: comp_ndem_wet             ! number of inundated DEM pixels within each ICM-Hydro compartment from monthly and annual mean water levels (-)
    integer,dimension(:,:),allocatable :: grid_ndem_wet             ! number of inundated DEM pixels within each ICM-LAVegMod grid cell from monthly and annual mean water levels (-)
   
    ! define global variables calculated in subroutine: INUNDATION_THRESHOLDS
    integer,dimension(:),allocatable :: lnd_change_flag             ! flag indicating why a pixel changed land type classification during the year
                                                                    !               -1 = conversion from vegetated wetland to open water due to inundation
                                                                    !               -2 = conversion from flotant marsh mat to open water                                                          
                                                                    !               -3 = conversion from marsh edge to open water due to erosion
                                                                    !                0 = no change
                                                                    !                1 = conversion from open water to land eligible for vegetation


    
    
    ! define global variables that are used summarizing end-of-year landscape
    real(sp),dimension(:),allocatable :: grid_pct_upland_dry        ! percent of ICM-LAVegMod grid cell that is upland and is higher than any inundation that would be considered appropriate for wetlands
    real(sp),dimension(:),allocatable :: grid_pct_upland_wet        ! percent of ICM-LAVegMod grid cell that is upland but is within inundation range of wetlands
    real(sp),dimension(:),allocatable :: grid_pct_flt               ! percent of ICM-LAVegMod grid cell that is flotant marsh
    real(sp),dimension(:),allocatable :: grid_pct_edge              ! percent of ICM-LAVegMod grid cell that is edge
    real(sp),dimension(:),allocatable :: grid_bed_z                 ! mean elevation of water pixels within each ICM-LAVegMod grid cell
    real(sp),dimension(:),allocatable :: grid_land_z                ! mean elevation of land (including flotant) pixels within each ICM-LAVegMod grid cell
    integer,dimension(:,:),allocatable :: grid_gadwl_dep            ! area in each ICM-LAVegMod grid cell that is classified for each of the 14 depths used in the Gadwall HSI
    integer,dimension(:,:),allocatable :: grid_gwteal_dep           ! area in each ICM-LAVegMod grid cell that is classified for each of the 9 depths used in the Greenwinged Teal HSI
    integer,dimension(:,:),allocatable :: grid_motduck_dep          ! area in each ICM-LAVegMod grid cell that is classified for each of the 9 depths used in the Mottled Duck HSI
    
    
    real(sp),dimension(:),allocatable :: comp_pct_water             ! percent of ICM-Hydro compartment that is open water
    real(sp),dimension(:),allocatable :: comp_pct_wetland           ! percent of ICM-Hydro compartment that is wetland (attached vegetated + flotant_ + non-vegetated)
    real(sp),dimension(:),allocatable :: comp_pct_upland            ! percent of ICM-Hydro compartment that is upland (not modeled in ICM-LAVegMod)
    real(sp),dimension(:),allocatable :: comp_wetland_z             ! average elevation of wetland in ICM-Hydro compartment
    real(sp),dimension(:),allocatable :: comp_water_z               ! average elevation of water bottom in ICM-Hydro compartment
    integer,dimension(:),allocatable :: comp_edge_area              ! area of edge within each ICM-Hydro compartment (sq m)
    
    ! DEM mapping arrays that are allocated in their own allocation subroutine DEM_PARAMS_ALLOC
    integer :: n_dem_col                                            ! number of columns (e.g. range in X) in DEM when mapped
    integer :: n_dem_row                                            ! number of rows (e.g. range in Y) in DEM when mapped
    integer,dimension(:,:),allocatable :: dem_index_mapped          ! DEM grid IDs, mapped
    
end module params