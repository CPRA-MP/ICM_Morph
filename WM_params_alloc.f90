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
    allocate(dem_col(ndem))
    allocate(dem_row(ndem))    
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

    ! allocate memory for variables read in from previous year's compartment_out Hydro summary file in subroutine: PREPROCESSING
    allocate(stg_av_prev_yr(ncomp))
    allocate(sal_av_prev_yr(ncomp))
 
    
    ! define variables read in or calculated from vegtype ICM-LAVegMod summary file in subroutine: PREPROCESSING
    allocate(grid_pct_water(ngrid))
    allocate(grid_pct_upland(ngrid))
    allocate(grid_pct_bare(ngrid)) 
    allocate(grid_pct_dead_flt(ngrid))
    allocate(grid_pct_vglnd_BLHF(ngrid))
    allocate(grid_pct_vglnd_SWF(ngrid))
    allocate(grid_pct_vglnd_FM(ngrid))
    allocate(grid_pct_vglnd_IM(ngrid))
    allocate(grid_pct_vglnd_BM(ngrid))
    allocate(grid_pct_vglnd_SM(ngrid))
    allocate(grid_FIBS_score(ngrid))
    
    ! define variables read in from monthly summary files  in subroutine: PREPROCESSING
    allocate(stg_av_mons(ncomp,12))
    allocate(stg_mx_mons(ncomp,12))
    allocate(sed_dp_ow_mons(ncomp,12))
    allocate(sed_dp_mi_mons(ncomp,12))
    allocate(sed_dp_me_mons(ncomp,12))
    
    ! allocate memory for global variables calculated in subroutine: Inundation
    allocate(dem_inun_dep(ndem,14))
    allocate(comp_ndem_wet(ncomp,13))
    allocate(grid_ndem_wet(ncomp,13))
    
    ! allocate memory for global variables calculated in subroutine: INUNDATION_THRESHOLDS
    allocate(lnd_change_flag(ndem))

    
    ! allocate memory for variable used to write to output files
    ! some output variables are allocated elsewhere, but these are only used for summarizing output
    allocate(grid_pct_upland_dry(ngrid))
    allocate(grid_pct_upland_wet(ngrid))
    allocate(grid_pct_vg_land(ngrid))
    allocate(grid_pct_flt(ngrid))
    allocate(grid_bed_z(ngrid))
    allocate(grid_land_z(ngrid))
    allocate(grid_pct_edge(ngrid))
    allocate(grid_gadwl_dep(ngrid,14))  
    allocate(grid_gwteal_dep(ngrid,9)) 
    allocate(grid_motduck_dep(ngrid,9))
    
    allocate(comp_pct_water(ncomp))
    allocate(comp_pct_wetland(ncomp))
    allocate(comp_pct_upland(ncomp))
    allocate(comp_wetland_z(ncomp))
    allocate(comp_water_z(ncomp))
    allocate(comp_edge_area(ncomp))
    
    
    
    
    return
    
    end
    
subroutine dem_params_alloc(n_dem_col,n_dem_row)
    ! separate subroutine to allocate DEM grid due to the grid size not being known until DEM xyz file is preprocessed
    use params
    implicit none 
    
    integer :: n_dem_col
    integer :: n_dem_row
    
    allocate(dem_index_mapped(n_dem_col,n_dem_row))
    
    return
    
    end