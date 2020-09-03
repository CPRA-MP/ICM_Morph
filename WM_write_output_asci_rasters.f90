subroutine write_output_asci_rasters
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
    ! write(800,'(A)') 'X    Y   Edge'                              ! no header neededin XYZ raster format
 
    do i = 1,ndem
        if (dem_lndtyp(i) /= dem_NoDataVal) then
            rasval_int = dem_edge(i)    
        else
            rasval_int = dem_NoDataVal
        end if
        write(800,1800) dem_x(i), dem_y(i),rasval_int
    end do
    close(800)
    
    write(  *,*) ' - writing output raster XYZ file for topobathy DEM'
    write(000,*) ' - writing output raster XYZ file for topobathy DEM'
    
    open(unit=801, file = trim(adjustL(dem_eoy_xyz_file) ))
    ! write headers
    ! write(800,'(A)') 'X    Y   Z'                                 ! no header neededin XYZ raster format
 
    do i = 1,ndem
        if (dem_z(i) /= dem_NoDataVal) then
            rasval_int = dem_z(i)    
        else
            rasval_int = dem_NoDataVal
        end if
        write(801,1801) dem_x(i), dem_y(i),rasval_flt
    end do
    close(801)
    
        
    write(  *,*) ' - writing output raster XYZ file for landchange flag'
    write(000,*) ' - writing output raster XYZ file for landchange flag'
    
    open(unit=802, file = trim(adjustL(lndchng_eoy_xyz_file) ))
    ! write headers
    ! write(800,'(A)') 'X    Y   lndchange_flg'                    ! no header neededin XYZ raster format
 
    do i = 1,ndem
        if (dem_z(i) /= dem_NoDataVal) then
            rasval_int = lnd_change_flag(i)    
        else
            rasval_int = dem_NoDataVal
        end if
        write(802,1800) dem_x(i), dem_y(i),rasval_int
    end do
    close(802)
    
    write(  *,*) ' - writing output raster XYZ file for land type'
    write(000,*) ' - writing output raster XYZ file for land type'
    
    open(unit=803, file = trim(adjustL(lndtyp_eoy_xyz_file) ))
    ! write headers
    ! write(800,'(A)') 'X    Y   lndchange_flg'                    ! no header neededin XYZ raster format
 
    do i = 1,ndem
        if (dem_z(i) /= dem_NoDataVal) then
            rasval_int = dem_lndtyp(i)    
        else
            rasval_int = dem_NoDataVal
        end if
        write(803,1800) dem_x(i), dem_y(i),rasval_int
    end do
    close(803)    
    
    
    
    write(  *,*) ' - writing output raster XYZ file for elevation change'
    write(000,*) ' - writing output raster XYZ file for elevation change'
    
    open(unit=804, file = trim(adjustL(dz_eoy_xyz_file) ))
    ! write headers
    ! write(800,'(A)') 'X    Y   dZ_cm'                    ! no header neededin XYZ raster format
 
    do i = 1,ndem
        if (dem_z(i) /= dem_NoDataVal) then
            rasval_int = dem_dz_cm(i)    
        else
            rasval_int = dem_NoDataVal
        end if
        write(804,1801) dem_x(i), dem_y(i),rasval_flt
    end do
    close(804)    
    
     

    
    
1800    format(I0,2(4x,I0))
1801    format(I0,2(4x,F0.4))      
    return
end