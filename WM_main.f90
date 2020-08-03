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
!   last update: 8/1/2020                          
!                                                     
!   project site: https://github.com/CPRA-MP      
!   documentation: http://coastal.la.gov/our-plan  
!                                                  
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
program main
    
    use params
    implicit none
    
    ! local variables
    integer :: tp                       ! local variable for time period to use for calculation
    integer,dimension(8) :: dtvalues    ! variable to store date time values
    
    ! set file names and directories for I/O files       
    !  input files
    morph_log_file = '_ICM-Morph_runlog.log'
    dem_file = 'xyzc_1.csv'                                                !'.\data\xyzc_1.csv'
    hydro_comp_out_file= 'compartment_out.csv'                              !'.\hydro\compartment_out.csv'
    veg_out_file = 'MPM2017_S04_G300_C000_U00_V00_SLA_O_01_01_V_vegty.csv'    
    !  output files
    grid_summary_eoy_file = 'grid_summary_eoy.csv'

    
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

    do tp = 1,13
        call inundation(tp) 
    end do
    
    ! update dem_lndtyp for dead flotant marsh - will only convert dem_lndtyp values of 3 (flotant) to 2 (water)
    call flotant
    
    
    do i = 1,ndem
    tabulate land type of pixels for each compartment and grid
    then divide by grid_ndem_all and comp_ndem_all to get percentages
    end do
    grid_pct_vg_land = 1.0 - grid_pct_water - grid_pct_bare - grid_pct_upland - grid_pct_flt
    
    call write_output
    
    ! print simulation end time and close log file
    call date_and_time(VALUES=dtvalues)
    write(000,*)
    write(000,'(a,I4.4,I2.2,I2.2,1x,I2.2,a,I2.2,a,I2.2)') "Ended ICM-Morph simulation at: ",dtvalues(1),dtvalues(2),dtvalues(3),dtvalues(5),":",dtvalues(6),":",dtvalues(7)
    write(000,*)
    close(000)
    
end program