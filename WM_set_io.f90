subroutine set_io
    
    !  subroutine that reads in configuration file that contains input/output files and settings
    
    use params
    implicit none

    
    ! settings
    elapsed_year = 1            ! elapsed year of model run 
    dem_res = 30                ! XY resolution of DEM (meters)
    dem_NoDataVal = -9999       ! value representing nodata in input rasters and XYZ files
    
    ! input files
    dem_file =                  './input/morph_test_DEM30.xyz'
    lwf_file =                  './input/morph_test_LWF30.xyz'
    meer_file =                 './input/morph_test_MEE30.xyz'
    pldr_file =                 './input/morph_test_polders.xyz'
    comp_file =                 './input/morph_test_ICMcomp.xyz'
    grid_file =                 './input/morph_test_ICMgrid.xyz'
    dsub_file =                 './input/deep_subsidence_mm.xyz'
    ssub_file =                 './input/ecoregion_shallow_subsidence_mm.csv'        
    act_del_file =              './input/compartment_active_delta.csv'
    eco_omar_file =             './input/ecoregion_organic_matter_accum.csv'
    comp_eco_file =             './input/compartment_ecoregion.csv' 
    hydro_comp_out_file =       './input/compartment_out_2015.csv'
    prv_hydro_comp_out_file =   './input/compartment_out_2014.csv'     
    veg_out_file =              './input/MP2023_S04_G030_C000_U00_V00_SLA_O_01_01_V_vegty.asc+'    
    monthly_mean_stage_file =   './input/compartment_monthly_mean_stage.csv'
    monthly_max_stage_file =    './input/compartment_monthly_max_stage.csv'
    monthly_ow_sed_dep_file =   './input/compartment_monthly_sed_dep_wat.csv'
    monthly_mi_sed_dep_file =   './input/compartment_monthly_sed_dep_interior.csv'
    monthly_me_sed_dep_file =   './input/compartment_monthly_sed_dep_edge.csv'
    bi_dem_xyz_file =           './input/ICM_BI-DEM_TBDEM30.xyz'
                                 
    !  output files              
    morph_log_file =            './_ICM-Morph_runlog.log'
    edge_eoy_xyz_file =         './output/edge_eoy_2015.xyz'
    dem_eoy_xyz_file =          './output/tbdem_eoy_2015.xyz'
    dz_eoy_xyz_file =           './output/dz_cm_eoy_2015.xyz'
    lndtyp_eoy_xyz_file =       './output/lndtyp_eoy_2015.xyz'
    lndchng_eoy_xyz_file =      './output/lndchng_eoy_2015.xyz'
    grid_summary_eoy_file =     './output/grid_summary_eoy_2015.csv'
    grid_data_file =            './output/grid_data_500m_2015.csv'
    grid_depth_file_Gdw =       './output/GadwallDepths_cm_2015.csv'
    grid_depth_file_GwT =       './output/GWTealDepths_cm_2015.csv'
    grid_depth_file_MtD =       './output/MotDuckDepths_cm_2015.csv'
    grid_pct_edge_file =        './output/MPM2017_S01_G300_C000_U00_V00_SLA_N_01_01_W_pedge.csv'
    comp_elev_file =            './output/compelevs_end_2015.csv'
    comp_wat_file =             './output/PctWater_2015.csv'
    comp_upl_file =             './output/PctUpland_2015.csv'
    

 
    
    
    return
end