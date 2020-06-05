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
!   last update: 4/13/2020                          
!                                                     
!   project site: https://github.com/CPRA-MP      
!   documentation: http://coastal.la.gov/our-plan  
!                                                  
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
program main
    
    use params
    implicit none
    
    ! local variables
    integer :: i                    ! iterator
    integer :: comp                 ! local variable for 30-m pixel's corresponding ICM-Hydro compartment
    integer,dimension(8) :: dtvalues
    
     ! set file names and directories for I/O files       
    morph_log_file = '_ICM-Morph_runlog.log'
    dem_file = 'xyzc_1.csv'                                                !'.\data\xyzc_1.csv'
    hydro_comp_out_file= 'compartment_out.csv'                              !'.\hydro\compartment_out.csv'
    veg_file = 'MPM2017_S04_G300_C000_U00_V00_SLA_O_01_01_V_vegty.asc+'     !'.\veg\MPM2017_S04_G300_C000_U00_V00_SLA_O_01_01_V_vegty.asc+'   
    
    
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

    ! calculate inundation from the mean annual water surface elevation
    call inundation(13)
    
    ! print simulation end time and close log file
    call date_and_time(VALUES=dtvalues)
    write(000,*)
    write(000,'(a,I4.4,I2.2,I2.2,1x,I2.2,a,I2.2,a,I2.2)') "Ended ICM-Morph simulation at: ",dtvalues(1),dtvalues(2),dtvalues(3),dtvalues(5),":",dtvalues(6),":",dtvalues(7)
    write(000,*)
    close(000)
    
end program