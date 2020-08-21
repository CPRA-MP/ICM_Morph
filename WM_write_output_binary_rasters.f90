subroutine write_output_binary_rasters
    ! subroutine that writes output rasters to binary files
    

    use params
    implicit none
    
    ! local variables
    
    
    write(  *,*) ' - writing output raster binary file for Edge'
    write(000,*) ' - writing output raster binary file for Edge'
    open(unit=800, file = 'output/'//trim(adjustL(edge_eoy_xyz_file))//'.b',form='unformatted')
    write(800) dem_edge
    close(800)
    
    write(  *,*) ' - writing output raster binary file for topobathy DEM'
    write(000,*) ' - writing output raster binary file for topobathy DEM'
    open(unit=801, file = 'output/'//trim(adjustL(dem_eoy_xyz_file))//'.b',form='unformatted')
    write(801) dem_z    
    close(801)
    
    write(  *,*) ' - writing output raster binary file for landchange flag'
    write(000,*) ' - writing output raster binary file for landchange flag'
    open(unit=802, file = 'output/'//trim(adjustL(lndchng_eoy_xyz_file))//'.b',form='unformatted')
    write(802) lnd_change_flag
    close(802)
    
    write(  *,*) ' - writing output raster binary file for land type'
    write(000,*) ' - writing output raster binary file for land type'
    open(unit=803, file = 'output/'//trim(adjustL(lndtyp_eoy_xyz_file))//'.b',form='unformatted')
    write(803) dem_lndtyp
    close(803)    
     
    write(  *,*) ' - writing output raster binary file for elevation change'
    write(000,*) ' - writing output raster binary file for elevation change'
    open(unit=804, file = 'output/'//trim(adjustL(dz_eoy_xyz_file))//'.b',form='unformatted')
    write(804) dem_dz_cm
    close(804)    
    
    write(  *,*) ' - writing output raster binary file for X-coordinate'
    write(000,*) ' - writing output raster binary file for X-coordinate'
    open(unit=805, file = trim(adjustL('output/raster_x_coord.b'))//'.b',form='unformatted')
    write(805) dem_x
    close(805)  
    
    write(  *,*) ' - writing output raster binary file for Y-coordinate'
    write(000,*) ' - writing output raster binary file for Y-coordinate'
    open(unit=806, file = trim(adjustL('output/raster_x_coord.b') ),form='unformatted')
    write(806) dem_y
    close(806)  
    
    
    return
end