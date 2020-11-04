module params
    
!! module to define parameter types for all global variables    
    
    implicit none

    ! generic variables used across all subroutines
    integer,parameter :: sp=selected_real_kind(p=6)                 ! determine compiler KIND value for 4-byte (single precision) floating point real numbers
    integer,parameter :: dp=selected_real_kind(p=15)                ! determine compiler KIND value for 8-byte (double precision) floating point real numbers
    character*3000 :: dump_txt                                      ! dummy variable to use for skipping lines in input files
    integer :: dump_int                                             ! dummy variable to use for data in input files
    real(sp) :: dump_flt                                            ! dummy variable to use for data in input files
    integer :: tp                                                   ! flag to indicate which timeperiod to use for inundation calculations (1-12=month; 13 = annual)

    ! I/O settings in subroutine: SET_IO
    integer :: start_year                                           ! first year of model run
    integer :: elapsed_year                                         ! elapsed year of model simulation
    integer :: dem_res                                              ! XY resolution of DEM (meters)
    integer :: dem_NoDataVal                                        ! value representing NoData in input XYZ rasters
    integer :: ndem                                                 ! number of DEM pixels in master DEM
    integer :: ndem_bi                                              ! number of pixels in interpolated ICM-BI-DEM XYZ that overlap primary DEM
    integer :: ncomp                                                ! number of ICM-Hydro compartments
    integer :: ngrid                                                ! number of ICM-LAVegMod grid cells
    integer :: neco                                                 ! number of ecoregions used to summarize data
    integer :: grid_ndem_mx                                         ! maximum number of DEM pixels within a grid cell
    integer :: comp_ndem_mx                                         ! maximum number of DEM pixels within a ICM-Hydro compartment
    integer :: nlt                                                  ! number of landtype classification
    real(sp) :: ht_abv_mwl_est                                      ! elevation (meters) , relative to annual mean water level, at which point vegetation can establish
    real(sp) :: ptile_Z                                             ! Z-value for quantile (Z=1.96 is 97.5th percentile)
    real(sp) :: B0                                                  ! beta-0 coefficient from quantile regression on CRMS annual inundation-salinity data (see App. A of MP2023 Wetland Vegetation Model Improvement report)
    real(sp) :: B1                                                  ! beta-1 coefficient from quantile regression on CRMS annual inundation-salinity data (see App. A of MP2023 Wetland Vegetation Model Improvement report)
    real(sp) :: B2                                                  ! beta-2 coefficient from quantile regression on CRMS annual inundation-salinity data (see App. A of MP2023 Wetland Vegetation Model Improvement report)
    real(sp) :: B3                                                  ! beta-3 coefficient from quantile regression on CRMS annual inundation-salinity data (see App. A of MP2023 Wetland Vegetation Model Improvement report)
    real(sp) :: B4                                                  ! beta-4 coefficient from quantile regression on CRMS annual inundation-salinity data (see App. A of MP2023 Wetland Vegetation Model Improvement report)
    real(sp) :: ow_bd                                               ! bulk density of open water body bed material (g/cm3)
    real(sp) :: om_k1                                               ! organic matter self-packing density  of wetland soils (g/cm3)
    real(sp) :: mn_k2                                               ! mineral sediment self-packing density of wetland soils (g/cm3)
    real(sp),dimension(:),allocatable :: FIBS_intvals               ! local array that stores FIBS values used to interpolate between **allocated in SET_IO instead of PARAMS_ALLOC**
    real(sp) :: min_accretion_limit_cm                              ! upper limit to allowable mineral accretion on the marsh surface during any given year [cm]
    real(sp) :: ow_accretion_limit_cm                               ! upper limit to allowable accretion on the water bottom during any given year [cm]
    real(sp) :: ow_erosion_limit_cm                                 ! upper limit to allowable erosion of the water bottom during any given year [cm]
    real(sp) :: bg_lowerZ_m                                         ! height that bareground is lowered [m]
    real(sp) :: me_lowerDepth_m                                     ! depth to which eroded marsh edge is lowered to [m]
    real(sp) :: flt_lowerDepth_m                                    ! depth to which dead floating marsh is lowered to [m]
    real(sp) :: mc_depth_threshold                                  ! water depth threshold (meters) defining deep water area to be excluded from marsh creation projects footprint
    
    ! input files in subroutine: SET_IO
    integer :: binary_in                                            ! read input raster datas from binary files (1) or from ASCI XYZ files (0)
    integer :: binary_out                                           ! write raster datas to binary format only (1) or to ASCI XYZ files (0)
    character*100 :: dem_file                                       ! file name, with relative path, to DEM XYZ file
    character*100 :: lwf_file                                       ! file name, with relative path, to land/water file that is same resolution and structure as DEM XYZ
    character*100 :: meer_file                                      ! file name, with relative path, to marsh edge erosion rate file that is same resolution and structure as DEM XYZ
    character*100 :: pldr_file                                      ! file name, with relative path, to polder file that is same resolution and structure as DEM XYZ (0=non-poldered pixel; 1=pixel within a polder)
    character*100 :: comp_file                                      ! file name, with relative path, to ICM-Hydro compartment map file that is same resolution and structure as DEM XYZ
    character*100 :: grid_file                                      ! file name, with relative path, to ICM-LAVegMod grid map file that is same resolution and structure as DEM XYZ
    character*100 :: dsub_file                                      ! file name, with relative path, to deep subsidence rate map file that is same resolution and structure as DEM XYZ (mm/yr; positive values are for downward VLM)
    character*100 :: ssub_file                                      ! file name, with relative path, to shallow subsidence table with statistics by ecoregion (mm/yr; positive values are for downward VLM)
    character*100 :: act_del_file                                   ! file name, with relative path, to lookup table that identifies whether an ICM-Hydro compartment is assigned as an 'active delta' site for use with Fresh Marsh organic accretion
    character*100 :: eco_omar_file                                  ! file name, with relative path, to lookup table of organic accumulation rates by marsh type/ecoregion
    character*100 :: comp_eco_file                                  ! file name, with relative path, to lookup table that assigns an ecoregion to each ICM-Hydro compartment    
    character*100 :: hydro_comp_out_file                            ! file name, with relative path, to compartment_out.csv file saved by ICM-Hydro
    character*100 :: prv_hydro_comp_out_file                        ! file name, with relative path, to compartment_out.csv file saved by ICM-Hydro for previous year
    character*100 :: veg_out_file                                   ! file name, with relative path, to *vegty.asc+ file saved by ICM-LAVegMod    
    character*100 :: monthly_mean_stage_file                        ! file name, with relative path, to compartment summary file with monthly mean water levels
    character*100 :: monthly_max_stage_file                         ! file name, with relative path, to compartment summary file with monthly maximum water levels 
    character*100 :: monthly_ow_sed_dep_file                        ! file name, with relative path, to compartment summary file with monthly sediment deposition in open water
    character*100 :: monthly_mi_sed_dep_file                        ! file name, with relative path, to compartment summary file with monthly sediment deposition on interior marsh
    character*100 :: monthly_me_sed_dep_file                        ! file name, with relative path, to compartment summary file with monthly sediment deposition on marsh edge
    character*100 :: bi_dem_xyz_file                                ! file name, with relative path, to XYZ DEM file for ICM-BI-DEM model domain - XY resolution must be snapped to XY resolution of main DEM
    
    ! output files in subroutine: SET_IO
    character*100 :: morph_log_file                                 ! file name of text file that logs all Morph print statements - no filepath will save this in executable directory
    character*100 :: edge_eoy_xyz_file                              ! file name, with relative path, to XYZ raster output file for edge pixels
    character*100 :: dem_eoy_xyz_file                               ! file name, with relative path, to XYZ raster output file for topobathy DEM
    character*100 :: dz_eoy_xyz_file                                ! file name, with relative path, to XYZ raster output file for elevation change raster
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
    
    ! QAQC save point information in subroutine: SET_IO
    integer :: nqaqc                                                ! number of QAQC points for reporting - as listed in qaqc_site_list_file
    character*100 :: qaqc_site_list_file                            ! file name, with relative path, to percent upland summary compartment file used internally by ICM 
    character*100 :: fnc_tag                                        ! file naming convention tag
    
    ! define variables read in or calculated from xyz files in subroutine: PREPROCESSING
    integer,dimension(:),allocatable ::  dem_x                      ! x-coordinate of DEM pixel (UTM m, zone 15N)
    integer,dimension(:),allocatable ::  dem_y                      ! y-coordinate of DEM pixel (UTM m, zone 15N)
    integer,dimension(:),allocatable ::  dem_comp                   ! ICM-Hydro compartment ID overlaying DEM pixel (-)
    integer,dimension(:),allocatable ::  dem_grid                   ! ICM-LAVegMod grid ID overlaying DEM pixel (-)
    integer,dimension(:),allocatable ::  grid_comp                  ! ICM-Hydro compartment ID overlaying ICM-LAVegMod grid (-)
    real(sp),dimension(:),allocatable :: dem_z                      ! average elevation of DEM pixel (m NAVD88)
    real(sp),dimension(:),allocatable :: dem_meer                   ! marsh edge erosion rate of DEM pixel (m / yr)
    real(sp),dimension(:),allocatable :: dem_pldr                   ! polder flag of DEM pixel (1 = pixel is in polder; 0 = not in polder)
    real(sp),dimension(:),allocatable :: dem_dpsb                   ! deep subsidence rate of DEM pixel (mm / yr; positive indicates downward VLM)
    real(sp),dimension(:),allocatable :: er_shsb                    ! shallow subsidence for ecoregion (mm/yr; positive indicates downward VLM)
    integer,dimension(:),allocatable ::  comp_eco                   ! ecoregion number of ICM-Hydro compartment
    integer,dimension(:),allocatable ::  comp_act_dlt               ! flag indicating whether ICM-Hydro compartment is considered an active delta for fresh marsh organic accretion (0=inactive; 1=active)
    character*10,dimension(:),allocatable :: er_codes              ! array to store ecoregion name codes - array location will correspond to ecoregion number - mucst match 
    real(sp),dimension(:,:),allocatable :: er_omar                  ! organic matter accumulation rate by marsh type by ecoregion (g/cm^2/yr)
                                                                    ! value for second dimension of array indicates marsh type
                                                                    !               1 = fresh marsh
                                                                    !               2 = intermediate marsh
                                                                    !               3 = brackish marsh
                                                                    !               4 = saline marsh
                                                                    !               5 = swamp forest
                                                                    !               6 = fresh marsh in active delta regions
      
    integer :: dem_LLx                                              ! lower left X-coordinate of DEM grid
    integer :: dem_LLy                                              ! lower left Y-coordinate of DEM grid
    integer :: dem_URx                                              ! upper right X-coordinate of DEM grid
    integer :: dem_URy                                              ! upper right Y-coordinate of DEM grid
    integer,dimension(:),allocatable :: comp_ndem_all               ! number of DEM pixels within each ICM-Hydro compartment (-)
    integer,dimension(:),allocatable :: grid_ndem_all               ! number of DEM pixels within each ICM-LAVegMod grid cell (-)                                                         
    integer,dimension(:),allocatable :: dem_lndtyp                  ! Land type classification of DEM pixel
                                                                    ! ****dem_lntyp must correspond with nlt variable defined above****
                                                                    !               1 = vegetated wetland
                                                                    !               2 = water
                                                                    !               3 = unvegetated wetland/new subaerial unvegetated mudflat (e.g., bare ground)
                                                                    !               4 = developed land/upland/etc. that are not modeled in ICM-LAVegMod
                                                                    !               5 = flotant marsh
    integer,dimension(:),allocatable :: dem_bi_zone                 ! flag for DEM pixel identifying whether it is within the barrier island model domain
    integer,dimension(:),allocatable :: dem_bi_map                  ! if pixel is in BI model domain, map the interpolated BI-DEM raster to the corresponding DEM pixel index
    
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
    real(sp),dimension(:),allocatable :: grid_pct_bare_old          ! percent of ICM-LAVegMod grid cell that is non-vegetated wetland and was bare in previous year (old bare ground)
    real(sp),dimension(:),allocatable :: grid_pct_bare_new          ! percent of ICM-LAVegMod grid cell that is non-vegetated wetland and is newly bare during current year (new bare ground)
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

    ! define variables read in from sub-domain DEM file generated by ICM-BI-DEM in subroutine: PREPROCESSING
    integer,dimension(:),allocatable :: dem_to_bidem                ! lookup array that pulls a corresponding BI-DEM index from an input DEM pixel index
    integer,dimension(:),allocatable :: dem_z_bi                    ! elevation from ICM-BI-DEM that has been interpolated to same grid as DEM
    
    
    ! define variables calculated in subroutine: EDGE_DELINEATION
    integer,dimension(:),allocatable :: dem_edge                    ! flag indicating whether DEM pixel is edge (0=non edge; 1=edge)
    
    ! define global variables calculated in subroutine: INUNDATION
    real(sp),dimension(:,:),allocatable :: dem_inun_dep             ! inundation depth at each DEM pixel from monthly and annual mean water levels (m)
    integer,dimension(:,:),allocatable :: comp_ndem_wet             ! number of inundated DEM pixels within each ICM-Hydro compartment from monthly and annual mean water levels (-)
    integer,dimension(:,:),allocatable :: grid_ndem_wet             ! number of inundated DEM pixels within each ICM-LAVegMod grid cell from monthly and annual mean water levels (-)

    ! define global variables used in subroutine: MAP_BAREGROUND
    integer,dimension(:),allocatable :: dem_bg_flag                 ! Bareground type classification of pixel (0 = non bareground; 1 = old bareground; 2 = new bareground)

    ! define global variables used in subrtoue: ORGANIC_ACCRETION & MINERAL_ACCRETION
    real(sp),dimension(:),allocatable :: org_accr_cm                ! annual organic matter accretion (cm) for each DEM pixel
    real(sp),dimension(:),allocatable :: min_accr_cm                ! annual mineral sedmient accretion (cm) for each DEM pixel
    
    ! define global variables that are used summarizing end-of-year landscape
    real(sp),dimension(:),allocatable :: dem_dz_cm                  ! elevation change (cm) of pixel during current year
    integer,dimension(:),allocatable :: lnd_change_flag             ! flag indicating why a pixel changed land type classification during the year
                                                                    !               -1 = conversion from vegetated wetland to open water due to inundation
                                                                    !               -2 = conversion from flotant marsh mat to open water                                                          
                                                                    !               -3 = conversion from marsh edge to open water due to erosion
                                                                    !                0 = no change
                                                                    !                1 = conversion from open water to land eligible for vegetation
    real(sp),dimension(:),allocatable :: grid_pct_upland_dry        ! percent of ICM-LAVegMod grid cell that is upland and is higher than any inundation that would be considered appropriate for wetlands
    real(sp),dimension(:),allocatable :: grid_pct_upland_wet        ! percent of ICM-LAVegMod grid cell that is upland but is within inundation range of wetlands
    real(sp),dimension(:),allocatable :: grid_pct_bare              ! percent of ICM-LAVegMod grid cell that is non-vegetated wetland at end of year
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