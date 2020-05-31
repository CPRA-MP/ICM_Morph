module params
    
!! module to define parameter types for all global variables    
    
    implicit none

    integer,parameter :: sp=selected_real_kind(p=6)                 ! determine single precision kind value   
    integer,parameter :: dp=selected_real_kind(p=13)                ! determine double precision kind value
    
    integer :: n30                                                  ! number of 30-m grid cells in xyzc file
    integer :: ncomp                                                ! number of ICM-Hydro compartments
    
    character*3000 :: skip_header
    
    ! variables read in from xyzc file
    integer,dimension(:),allocatable :: g30_x                       ! x-coordinate of 30-m pixel (UTM m, zone 15N)
    integer,dimension(:),allocatable :: g30_y                       ! y-coordinate of 30-m pixel (UTM m, zone 15N)
    real(sp),dimension(:),allocatable :: g30_z                      ! average elevation of 30-m pixel (m NAVD88)
    integer,dimension(:),allocatable :: g30_comp                    ! ICM-Hydro compartment  ID overlaying 30-m pixel (-)
    
    ! variables rad in from compartment_out Hydro summary file
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

    
end module params