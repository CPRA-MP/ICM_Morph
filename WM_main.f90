!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!                                                  
!       ICM Wetland Morphology Model               
!                                                  
!                                                  
!   Fortran version of ICM-Morph developed         
!   for 2023 Coastal Master Plan - LA CPRA         
!                                                  
!   original model: Couvillion et al., (2012)       
!   revised model: White et al., (2017)             
!   current model: Foster-Martinez et al., (in prep)                                               
!                                                  
!   Questions: eric.white@la.gov                   
!   last update: 11/22/2020                          
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
    
    character*17 :: dtstrf                          ! string to hold formatted datetime
    character*19 :: dtstr                           ! string to hold formatted datetime

    call date_and_time(VALUES=dtvalues)             ! grab simulation start time
    write(dtstrf,8888) dtvalues(1),dtvalues(2),dtvalues(3),'_',dtvalues(5),'.',dtvalues(6),'.',dtvalues(7)
    write(dtstr,8889) dtvalues(1),'-',dtvalues(2),'-',dtvalues(3),' ',dtvalues(5),':',dtvalues(6),':',dtvalues(7)
    open(unit=000, file=trim(adjustL('_ICM-Morph_runlog_')//dtstr//trim('.log')))
    
    write(  *,*)
    write(  *,*) '*************************************************************'
    write(  *,*) '****                                                     ****'
    write(  *,*) '****    ****    STARTING ICM-MORPH SIMULATION    ****    ****'
    write(  *,*) '****                                                     ****'
    write(  *,*) '*************************************************************'
    write(  *,*)
    write(  *,*) 'Started ICM-Morph simulation at: ',dtstr
    write(  *,*)

    write(000,*)
    write(000,*) '*************************************************************'
    write(000,*) '****                                                     ****'
    write(000,*) '****    ****    STARTING ICM-MORPH SIMULATION    ****    ****'
    write(000,*) '****                                                     ****'
    write(000,*) '*************************************************************'    
    write(000,*)
    write(000,*) 'Started ICM-Morph simulation at: ',dtstr
    write(000,*)

    call set_io                                     ! input/output settings - must be run BEFORE parameter allocation   
    call params_alloc
   
    call preprocessing
    call date_and_time(VALUES=dtvalues)
    write(dtstr,8889) dtvalues(1),'-',dtvalues(2),'-',dtvalues(3),'_',dtvalues(5),':',dtvalues(6),':',dtvalues(7)
    write(  *,*) 'Preprocessing subroutine ended at: ',dtstr
    write(000,*) 'Preprocessing subroutine ended at: ',dtstr

    
    do tp = 1,14
        dem_inun_dep(:,tp)  = 0.0                       ! initialize arrays for tp to 0
        comp_ndem_wet(:,tp) =   0                       ! initialize arrays for tp to 0
        grid_ndem_wet(:,tp) =   0                       ! initialize arrays for tp to 0
        call inundation_depths
    end do
    call date_and_time(VALUES=dtvalues)
    write(dtstr,8889) dtvalues(1),'-',dtvalues(2),'-',dtvalues(3),' ',dtvalues(5),':',dtvalues(6),':',dtvalues(7)
    write(  *,*) 'Inundation Depths subroutine ended at: ',dtstr
    write(000,*) 'Inundation Depths subroutine ended at: ',dtstr

   

    call inundation_HSI_bins
    call date_and_time(VALUES=dtvalues)
    write(dtstr,8889) dtvalues(1),'-',dtvalues(2),'-',dtvalues(3),' ',dtvalues(5),':',dtvalues(6),':',dtvalues(7)
    write(  *,*) 'HSI Inundation subroutine ended at: ',dtstr
    write(000,*) 'HSI Inundation subroutine ended at: ',dtstr    
    

    call summaries
    call date_and_time(VALUES=dtvalues)
    write(dtstr,8889) dtvalues(1),'-',dtvalues(2),'-',dtvalues(3),' ',dtvalues(5),':',dtvalues(6),':',dtvalues(7)
    write(  *,*) 'Summaries subroutine ended at: ',dtstr
    write(000,*) 'Summaries subroutine ended at: ',dtstr  
 

    call write_output_summaries
    call date_and_time(VALUES=dtvalues)
    write(dtstr,8889) dtvalues(1),'-',dtvalues(2),'-',dtvalues(3),' ',dtvalues(5),':',dtvalues(6),':',dtvalues(7)
    write(  *,*) 'Write Output subroutine ended at: ',dtstr
    write(000,*) 'Write Output subroutine ended at: ',dtstr    


    write(  *,*)
    write(  *,*) 'Ended ICM-Morph simulation at: ',dtstr
    write(  *,*)
    
    write(000,*)
    write(000,*) 'Ended ICM-Morph simulation at: ',dtstr
    write(000,*)
    close(000)


8888    format(I4.4,I2.2,I2.2,a,I2.2,a,I2.2,a,I2.2)
8889    format(I4.4,a,I2.2,a,I2.2,a,I2.2,a,I2.2,a,I2.2)
    
end program
