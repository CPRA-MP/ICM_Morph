subroutine write_output_binary_rasters
    ! subroutine that writes output rasters to binary files
    

    use params
    implicit none
    
    ! local variables
    
    
    write(  *,*) ' - writing output raster binary file for Edge'
    write(000,*) ' - writing output raster binary file for Edge'
    open(unit=800, file = trim(adjustL(edge_eoy_xyz_file))//'.b',form='unformatted')
    write(800) dem_edge
    close(800)
    
    write(  *,*) ' - writing output raster binary file for topobathy DEM'
    write(000,*) ' - writing output raster binary file for topobathy DEM'
    open(unit=801, file = trim(adjustL(dem_eoy_xyz_file))//'.b',form='unformatted')
    write(801) dem_z    
    close(801)
    
    write(  *,*) ' - writing output raster binary file for landchange flag'
    write(000,*) ' - writing output raster binary file for landchange flag'
    open(unit=802, file = trim(adjustL(lndchng_eoy_xyz_file))//'.b',form='unformatted')
    write(802) lnd_change_flag
    close(802)
    
    write(  *,*) ' - writing output raster binary file for land type'
    write(000,*) ' - writing output raster binary file for land type'
    open(unit=803, file = trim(adjustL(lndtyp_eoy_xyz_file))//'.b',form='unformatted')
    write(803) dem_lndtyp
    close(803)    
     
    write(  *,*) ' - writing output raster binary file for elevation change'
    write(000,*) ' - writing output raster binary file for elevation change'
    open(unit=804, file = trim(adjustL(dz_eoy_xyz_file))//'.b',form='unformatted')
    write(804) dem_dz_cm
    close(804)    

    if (elapsed_year == 1) then
    
        write(  *,*) ' - writing output raster binary file for X-coordinate'
        write(000,*) ' - writing output raster binary file for X-coordinate'
        open(unit=805, file = trim(adjustL('geomorph/output/raster_x_coord.b')),form='unformatted')
        write(805) dem_x
        close(805)  
        
        write(  *,*) ' - writing output raster binary file for Y-coordinate'
        write(000,*) ' - writing output raster binary file for Y-coordinate'
        open(unit=806, file = trim(adjustL('geomorph/output/raster_y_coord.b')),form='unformatted')
        write(806) dem_y
        close(806)  
        
        write(  *,*) ' - writing output raster binary file for compartment map'
        write(000,*) ' - writing output raster binary file for compartment map'
        open(unit=807, file=trim(adjustL(comp_file))//'.b',form='unformatted')
        write(807) dem_comp
        close(807)
        
        write(  *,*) ' - writing output raster binary file for grid map'
        write(000,*) ' - writing output raster binary file for grid map'
        open(unit=808, file=trim(adjustL(grid_file))//'.b',form='unformatted')
        write(808) dem_grid
        close(808)

        write(  *,*) ' - writing output raster binary file for marsh edge erosion rate'
        write(000,*) ' - writing output raster binary file for marsh edge erosion rate'
        open(unit=809, file=trim(adjustL(meer_file))//'.b',form='unformatted')
        write(809) dem_meer
        close(809)
        
        write(  *,*) ' - writing output raster binary file for polder areas'
        write(000,*) ' - writing output raster binary file for polder areas'
        open(unit=810, file=trim(adjustL(pldr_file))//'.b',form='unformatted')
        write(810) dem_pldr
        close(810)
        
        write(  *,*) ' - writing output raster binary file for polder areas'
        write(000,*) ' - writing output raster binary file for polder areas'
        open(unit=811, file=trim(adjustL(dsub_file))//'.b',form='unformatted')
        write(811) dem_dpsb
        close(811)
    end if
    
    return
end