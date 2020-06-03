subroutine params_alloc
    
    use params
    implicit none 
    
    ndem = 1048575              ! number of DEM pixels - will be an array dimension for all DEM-level data
    ncomp = 946                 ! number of ICM-Hydro compartments - will be an array dimension for all compartment-level data

    ! allocate memory for variables read in from xyzc file
    allocate(dem_x(ndem))
    allocate(dem_y(ndem))
    allocate(dem_z(ndem))
    allocate(dem_comp(ndem))
    
    ! allocate memory for variables read in from compartment_out Hydro summary file
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
   
    ! allocate memory for variables calculated within code
    allocate(dem_inun_dep(ndem))
    allocate(comp_ndem_all(ncomp))
    allocate(comp_ndem_wet(ncomp))
    
    
    return
    
end