!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!                                                  
!       ICM Wetland Morphology Model               
!                                                  
!                                                  
!   Fortran version of ICM-Morph developed         
!   for 2023 Coastal Master Plan - LA CPRA         
!                                                  
!   original model: Couvillion et al., 2012        
!   updated model: White et al., 2017              
!                                                  
!                                                  
!   Questions: eric.white@la.gov                   
!   last update: 8/11/2020                          
!                                                     
!   project site: https://github.com/CPRA-MP      
!   documentation: http://coastal.la.gov/our-plan  
!                                                  
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
program main
    
    use params
    implicit none
    
    ! local variables
    integer :: tp                       ! local variable for time period to use for calculation (1-12=month; 13=current year annual; 14=previous year annual)
    integer,dimension(8) :: dtvalues    ! variable to store date time values
    
    ! set file names and directories for I/O files       
    
    !  input files
    morph_log_file =            '_ICM-Morph_runlog.log'
    dem_file =                  'xyzc_1.csv'                       !'.\data\xyzc_1.csv'
    hydro_comp_out_file =       'compartment_out.csv'              !'.\hydro\compartment_out.csv'
    prv_hydro_comp_out_file =   'compartment_out.csv'     
    veg_out_file =              'MPM2017_S04_G300_C000_U00_V00_SLA_O_01_01_V_vegty.csv'    
    monthly_mean_stage_file =   'compartment_monthly_mean_stage.csv'
    monthly_max_stage_file =    'compartment_monthly_max_stage.csv'
    monthly_ow_sed_dep_file =   'compartment_monthly_sed_dep_wat.csv'
    monthly_mi_sed_dep_file =   'compartment_monthly_sed_dep_interior.csv'
    monthly_me_sed_dep_file =   'compartment_monthly_sed_sed_edge.csv'
    !  output files
    grid_summary_eoy_file =     'grid_summary_eoy_2015.csv'
    grid_data_file =            'grid_data_500m_2015.csv'
    grid_depth_file_Gdw =       'GadwallDepths_cm_2015.csv'
    grid_depth_file_GwT =       'GWTealDepths_cm_2015.csv'
    grid_depth_file_MtD =       'MotDuckDepths_cm_2015.csv'
    grid_pct_edge_file =        'MPM2017_S01_G300_C000_U00_V00_SLA_N_01_01_W_pedge.csv'
    comp_elev_file =            'compelevs_end_2015.csv'
    comp_wat_file =             'PctWater_2015.csv'
    comp_upl_file =             'PctUpland_2015.csv'
    
    
    
    dem_res = 30        ! XY resolution of DEM (meters)
    
    ! open log file and print simulation start time
    call date_and_time(VALUES=dtvalues)
    open(unit=000, file=morph_log_file)   ! open log file for writing
    write(000,*)
    write(000,'(a,I4.4,I2.2,I2.2,1x,I2.2,a,I2.2,a,I2.2)') "Started ICM-Morph simulation at: ",dtvalues(1),dtvalues(2),dtvalues(3),dtvalues(5),":",dtvalues(6),":",dtvalues(7)
    write(000,*)
    

    
    ! allocate memory for global parameters included in params    
    call params_alloc
    
    ! read in various datasets from file and save to arrays
    call preprocessing

      
    ! calculate monthly and annual inundation
    ! initialize 2-d arrays that will store monthly and annual inundation depths and count of wet pixels in each comp/grid
    dem_inun_dep = 0
    comp_ndem_wet = 0
    grid_ndem_wet = 0

    do tp = 1,14
        call inundation_depths(tp) 
    end do
    
    ! determine land change conditions 
    
    ! lnd_change_flag - array updated by several subroutines that will flag various land/change criteria
    !        0 = no change; 
    !       -2 = loss of flotant marsh; 
    !       -1 = loss of vegetated land to open water; 
    !        1 = gain of land (from open water) that will be eligible for vegetation
    
    ! initialize land change flag for each DEM pixel to zero 
    lnd_change_flag = 0             
    call flotant
    call inundation_thresholds
    
    
    call inundation_HSI_bins
    call summaries
    call write_output
    
    ! print simulation end time and close log file
    call date_and_time(VALUES=dtvalues)
    write(000,*)
    write(000,'(a,I4.4,I2.2,I2.2,1x,I2.2,a,I2.2,a,I2.2)') "Ended ICM-Morph simulation at: ",dtvalues(1),dtvalues(2),dtvalues(3),dtvalues(5),":",dtvalues(6),":",dtvalues(7)
    write(000,*)
    close(000)
    
end program