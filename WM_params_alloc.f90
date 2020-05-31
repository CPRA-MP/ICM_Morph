subroutine params_alloc
    
    use params
    implicit none 
    
    n30 = 1048575
    ncomp = 946

    ! variables read in from xyzc file
    allocate(g30_x(n30))
    allocate(g30_y(n30))
    allocate(g30_z(n30))
    allocate(g30_comp(n30))
    
    ! variables rad in from compartment_out Hydro summary file
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
    
    return
    
end