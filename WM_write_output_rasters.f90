subroutine write_output_rasters
    ! subroutine that writes output rasters
    

    use params
    implicit none
    
    ! local variables
    integer :: i                                                    ! iterator
    integer :: rasval_int                                           ! local integer value to write out
    real(sp) :: rasval_flt                                          ! local integer value to write out     
    
    
    write(  *,*) ' - writing output raster XYZ file for Edge'
    write(000,*) ' - writing output raster XYZ file for Edge'
    
    open(unit=800, file = trim(adjustL(edge_eoy_xyz_file) ))
    ! write headers
    !write(800,'(A)') 'X    Y   Edge'       ! no header in XYZ raster format
 
    do i = 1,ndem
        if (dem_lndtyp(i) /= dem_NoDataVal) then
            rasval_int = dem_edge(i)    
        else
            rasval_int = dem_NoDataVal
        end if
        write(800,1800) dem_x(i), dem_y(i),rasval_int
    end do
    close(800)
     
1800    format(I0,2(',',I0))
       
    return
end