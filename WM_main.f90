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
    character*300 :: skip_header

    call params_alloc
    
    
    ! read xyz file into arrays
    ! 1st column of xyz is x (integer)
    ! 2nd column is y (integer)
    ! 3rd column is z (single precision variable)
    ! 4th column is ICM Hydro compartment (integer)
    
    open(unit=111, file='.\data\xyzc_1.csv')
    read(111,*) skip_header
    do i = 1,n30
        read(111,*) g30_x(i), g30_y(i), g30_z(i), g30_comp(i)              
    end do
    
    write(*,*)
    write(*,*) '...check memory usage now'
    pause
    
    
    
end program