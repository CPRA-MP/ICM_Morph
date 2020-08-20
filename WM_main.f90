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
    integer,dimension(8) :: dtvalues                ! variable to store date time values
    character*15 :: dtstr
    
    call date_and_time(VALUES=dtvalues)             ! grab simulation start time
    write(dtstr,8888) dtvalues(1),dtvalues(2),dtvalues(3),'_',dtvalues(5),dtvalues(6),dtvalues(7)
    open(unit=000, file=trim(adjustL('_ICM-Morph_runlog_')//dtstr//trim('.log')))
    
    write(  *,*)
    write(  *,*) '*************************************************************'
    write(  *,*) '****                                                     ****'
    write(  *,*) '****    ****    STARTING ICM-MORPH SIMULATION    ****    ****'
    write(  *,*) '****                                                     ****'
    write(  *,*) '*************************************************************'
    write(  *,*)
    write(  *,*) ' Started ICM-Morph simulation at: ',dtstr
    write(  *,*)

    write(000,*)
    write(000,*) '*************************************************************'
    write(000,*) '****                                                     ****'
    write(000,*) '****    ****    STARTING ICM-MORPH SIMULATION    ****    ****'
    write(000,*) '****                                                     ****'
    write(000,*) '*************************************************************'    
    write(000,*)
    write(000,*) ' Started ICM-Morph simulation at: ',dtstr
    write(000,*)

    call set_io                                     ! input/output settings - must be run BEFORE parameter allocation   
    call params_alloc
    call preprocessing

    do tp = 1,14
        dem_inun_dep(:,tp)  = 0.0                       ! initialize arrays for tp to 0
        comp_ndem_wet(:,tp) =   0                       ! initialize arrays for tp to 0
        grid_ndem_wet(:,tp) =   0                       ! initialize arrays for tp to 0
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
    write(dtstr,8888) dtvalues(1),dtvalues(2),dtvalues(3),'_',dtvalues(5),dtvalues(6),dtvalues(7)

    
    write(  *,*)
    write(  *,*) ' Ended ICM-Morph simulation at: ',dtstr
    write(  *,*)
    
    write(000,*)
    write(000,*) ' Ended ICM-Morph simulation at: ',dtstr
    write(000,*)
    close(000)


8888    format(I4.4,I2.2,I2.2,a,I2.2,I2.2,I2.2)

    
end program