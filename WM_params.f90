module params
    
!! module to define parameter types for all global variables    
    
    implicit none
      
    !determine single precision kind value
    integer,parameter :: sp=selected_real_kind(p=6)     
    !determine double precision kind value
    integer,parameter :: dp=selected_real_kind(p=13)
    
    integer :: n30
    
    integer, allocatable :: x(:), y(:)
    
    real(sp), allocatable :: z(:)
  
    
end module params