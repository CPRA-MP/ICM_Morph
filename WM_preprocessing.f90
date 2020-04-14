subroutine preprocessing
    
    use params
    implicit none
    
    integer :: i
    
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
    
    return

end