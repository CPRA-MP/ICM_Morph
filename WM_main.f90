!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!                                                  
!       ICM Wetland Morphology Model               
!                                                  
!                                                  
!   Fortran version of ICM-Morph developed         
!   for 2023 Coastal Master Plan - LA CPRA         
!                                                  
!   original model: Couvillion et al., 2012        
!   revised model: White et al., 2017              
!   current model: TBD                                               
!                                                  
!   Questions: eric.white@la.gov                   
!   last update: 8/16/2020                          
!                                                     
!   project site: https://github.com/CPRA-MP      
!   documentation: http://coastal.la.gov/our-plan  
!                                                  
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
program main
    
    use params
    implicit none

    ! local variables
!    integer :: tp                                   ! local variable for time period to use for calculation (1-12=month; 13=current year annual; 14=previous year annual)
    integer,dimension(8) :: dtvalues                ! variable to store date time values
    
    call date_and_time(VALUES=dtvalues)             ! grab simulation start time
    call set_io     

    open(unit=000, file=morph_log_file)             ! open log file for writing
    
    write(  *,*)
    write(  *,*) '*************************************************************'
    write(  *,*) '****                                                     ****'
    write(  *,*) '****    ****    STARTING ICM-MORPH SIMULATION    ****    ****'
    write(  *,*) '****                                                     ****'
    write(  *,*) '*************************************************************'
    write(  *,*)
    write(  *,8888) ' Started ICM-Morph simulation at: ',dtvalues(1),dtvalues(2),dtvalues(3),dtvalues(5),':',dtvalues(6),':',dtvalues(7)
    write(  *,*)

    write(000,*)
    write(000,*) '*************************************************************'
    write(000,*) '****                                                     ****'
    write(000,*) '****    ****    STARTING ICM-MORPH SIMULATION    ****    ****'
    write(000,*) '****                                                     ****'
    write(000,*) '*************************************************************'    
    write(000,*)
    write(000,8888) ' Started ICM-Morph simulation at: ',dtvalues(1),dtvalues(2),dtvalues(3),dtvalues(5),':',dtvalues(6),':',dtvalues(7)
    write(000,*)

    
    call params_alloc
    call preprocessing

    dem_inun_dep  = 0.0                               ! initialize arrays to 0
    comp_ndem_wet =   0                               ! initialize arrays to 0
    grid_ndem_wet =   0                               ! initialize arrays to 0

    do tp = 1,14
        call inundation_depths
    end do
    
    call edge_delineation
    call mineral_deposition
    call organic_accretion
    
    lnd_change_flag = 0                             ! initialize land change flag for each DEM pixel to zero  
    
    call flotant
    call edge_erosion
    call map_bareground
    call inundation_thresholds
    call update_elevation
    call update_landtype
    call inundation_HSI_bins
    call summaries
    call write_output_summaries
    call write_output_rasters
    call date_and_time(VALUES=dtvalues)             ! grab simulation end time

    
    write(  *,*)
    write(  *,8888) ' Ended ICM-Morph simulation at: ',dtvalues(1),dtvalues(2),dtvalues(3),dtvalues(5),':',dtvalues(6),':',dtvalues(7)
    write(  *,*)
    
    write(000,*)
    write(000,8888) ' Ended ICM-Morph simulation at: ',dtvalues(1),dtvalues(2),dtvalues(3),dtvalues(5),':',dtvalues(6),':',dtvalues(7)
    write(000,*)
    close(000)


8888    format(a,I4.4,I2.2,I2.2,1x,I2.2,a,I2.2,a,I2.2)

    
end program