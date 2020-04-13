module params
    
!! module to define parameter types for all global variables    
    
    implicit none
      

    integer,parameter :: sp=selected_real_kind(p=6)     ! determine single precision kind value   
    integer,parameter :: dp=selected_real_kind(p=13)    ! determine double precision kind value
    
    integer :: n30      ! number of 30-m grid cells in xyzc file
    
    ! variables read in from xyzc file
    integer,dimension(:),allocatable :: g30_x
    integer,dimension(:),allocatable :: g30_y
    real(sp),dimension(:),allocatable :: g30_z
    integer,dimension(:),allocatable :: g30_comp
    
end module params