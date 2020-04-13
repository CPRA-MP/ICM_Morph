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
    
    integer :: i
    
    pause
   
    
    write(*,*) 'sp kind = ',sp  
    write(*,*) 'dp kind = ',dp
    
    call params_alloc
    
    
    ! read xyz file into arrays
    open(unit=111, file='.\data\xyz_1.csv')
    read(111,*)                                                         ! skip header row of xyz file
    do i = 1,n30
        read(111,*) x(i), y(i), z(i)                                    ! 1st column is x (integer), 2nd column is y (integer), 3rd column is z (single precision variable)
    end do
    
    pause
    
    write(*,*) x(400),y(400),z(400)
    write(*,*) maxval(x), maxval(y), maxval(z)
    
    
end program