subroutine params_alloc
    
    use params
    implicit none 
    
    ndem = 1048575              ! number of DEM pixels - will be an array dimension for all DEM-level data
    ncomp = 946                 ! number of ICM-Hydro compartments - will be an array dimension for all compartment-level data
    ngrid = 3813                ! number of ICM-LAVegMod grid cells - will be an array dimension for all gridd-level data
    
    ! allocate memory for variables read in or calculated from xyzc DEM file in subroutine: PREPROCESSING
    allocate(dem_x(ndem))
    allocate(dem_y(ndem))
    allocate(dem_z(ndem))
    allocate(dem_comp(ndem))
    allocate(dem_grid(ndem))
    allocate(dem_lndtyp(ndem))
    allocate(comp_ndem_all(ncomp))
    allocate(grid_ndem_all(ngrid))
    
    ! allocate memory for variables read in or calculated from compartment_out Hydro summary file in subroutine: PREPROCESSING
    allocate(stg_mx_yr(ncomp))
    allocate(stg_av_yr(ncomp))
    allocate(stg_av_smr(ncomp))
    allocate(stg_sd_smr(ncomp))
    allocate(sal_av_yr(ncomp))
    allocate(sal_av_smr(ncomp))
    allocate(sal_mx_14d_yr(ncomp))
    allocate(tmp_av_yr(ncomp))
    allocate(tmp_av_smr(ncomp))
    allocate(sed_dp_ow_yr(ncomp))
    allocate(sed_dp_mi_yr(ncomp))
    allocate(sed_dp_me_yr(ncomp))
    allocate(tidal_prism_ave(ncomp))
    allocate(ave_sepmar_stage(ncomp))
    allocate(ave_octapr_stage(ncomp))
    allocate(marsh_edge_erosion_rate(ncomp))
    allocate(ave_annual_tss(ncomp))
    allocate(stdev_annual_tss(ncomp))
    allocate(totalland_m2(ncomp))

    ! define variables read in or calculated from vegtype ICM-LAVegMod summary file in subroutine: PREPROCESSING
    allocate(grid_pct_land(ngrid))
    allocate(grid_pct_water(ngrid))
    allocate(grid_pct_bare(ngrid)) 
    allocate(grid_pct_upland(ngrid))
    allocate(grid_pct_flot(ngrid))
    allocate(grid_FIBS_score(ngrid))
    
    ! allocate memory for global variables calculated in subroutine: Inundation
    allocate(dem_inun_dep(ndem,13))
    allocate(comp_ndem_wet(ncomp,13))
    allocate(grid_ndem_wet(ncomp,13))
    return
    
end