subroutine preprocessing
    
    use params
    implicit none
    
    ! local variables
    integer :: i                    ! iterator
    integer :: n_dem_col            ! number of columns (e.g. range in X) in DEM when mapped
    integer :: n_dem_row            ! number of rows (e.g. range in Y) in DEM when mapped
    integer :: i_col                ! X-coordinate converted to column number of mapped DEM
    integer :: i_row                ! Y-coordinate converted to row number of mapped DEM
    ! read xyz file into arrays
    write(  *,*) ' - reading in DEM data for: ',trim(adjustL(dem_file))
    write(000,*) ' - reading in DEM data for: ',trim(adjustL(dem_file))

    comp_ndem_all = 0                   ! before looping through all DEM pixels, initialize counter array to zero
    grid_ndem_all = 0                   ! before looping through all DEM pixels, initialize counter array to zero
    
    open(unit=111, file=trim(adjustL(dem_file)))
   
    read(111,*) dump_txt
    do i = 1,ndem
        read(111,*) dem_x(i),               &
   &                dem_y(i),               &
   &                dem_z(i),               &
   &                dem_comp(i),            &
   &                dem_grid(i),            &
   &                dem_lndtyp(i)
        ! determine lower left and upper right corners of DEM grid
        if (i == 1) then
            dem_LLx = dem_x(i)
            dem_LLy = dem_y(i)
            dem_URx = dem_x(i)
            dem_URy = dem_y(i)
        else
            dem_LLx = min(dem_LLx,dem_x(i)) 
            dem_LLy = min(dem_LLy,dem_y(i))
            dem_URx = max(dem_URx,dem_y(i))
            dem_URy = max(dem_URy,dem_y(i))
        end if
        
        ! count number of DEM pixels within each ICM-Hydro compartment & ICM-LAVegMod grid cells
        comp_ndem_all(dem_comp) =  comp_ndem_all(dem_comp) + 1
        grid_ndem_all(dem_grid) =  grid_ndem_all(dem_grid) + 1
    end do
    close(111)

    ! calculate number of rows and columns in mapped DEM from X-Y ranges determined above
    n_dem_col = 1+(dem_URx - dem_LLx)/dem_res
    n_dem_row = 1+(dem_URy - dem_LLy)/dem_res
    
    ! allocate array for DEM map    
    call dem_params_alloc(n_dem_col,n_dem_row)
    
    ! initialze arrays to 0
    dem_index_mapped = 0
    dem_col = 0
    dem_row = 0
    
    ! loop through DEM and map pixel ID (i) to structured DEM map
    ! also save vector arrays that convert X and Y coordinate arrays into row and column arrays (searchable by DEM pixel ID, i)
    do i = 1,ndem
        i_col = 1+(dem_x(i) - dem_LLx)/dem_res
        i_row = 1+(dem_y(i) - dem_LLy)/dem_res
        dem_index_mapped(i_col,i_row) = i
        dem_col(i) = i_col
        dem_row(i) = i_row
    end do
    
    
    ! read ICM-Hydro compartment output file into arrays
    write(  *,*) ' - reading in annual ICM-Hydro compartment-level output'
    write(000,*) ' - reading in annual ICM-Hydro compartment-level output'
    
    open(unit=112, file=trim(adjustL(hydro_comp_out_file)))
    
    read(112,*) dump_txt
    do i = 1,ncomp
        read(112,*) dump_txt,               &
   &         stg_mx_yr(i),                  &
   &         stg_av_yr(i),                  &
   &         stg_av_smr(i),                 &
   &         stg_sd_smr(i),                 &
   &         sal_av_yr(i),                  &
   &         sal_av_smr(i),                 &
   &         sal_mx_14d_yr(i),              &
   &         tmp_av_yr(i),                  &
   &         tmp_av_smr(i),                 &
   &         sed_dp_ow_yr(i),               &
   &         sed_dp_mi_yr(i),               &
   &         sed_dp_me_yr(i),               &
   &         tidal_prism_ave(i),            &
   &         ave_sepmar_stage(i),           &
   &         ave_octapr_stage(i),           &
   &         marsh_edge_erosion_rate(i),    &
   &         ave_annual_tss(i),             &
   &         stdev_annual_tss(i),           &
   &         totalland_m2(i)
    end do
    close(112)
    
    write(  *,*) ' - reading in monthly ICM-Hydro compartment-level output'
    write(000,*) ' - reading in monthly ICM-Hydro compartment-level output'
!    read in monthly data for stage and sediment deposition (open water and marsh)
    
    
    ! read ICM-LAVegMod grid output file into arrays
    write(  *,*) ' - reading in ICM-LAVegMod grid-level output'
    write(000,*) ' - reading in ICM-LAVegMod grid-level output'
    
    ! initialize grid data arrays to 0.0
    grid_pct_water = 0.0
    grid_pct_upland = 0.0
    grid_pct_bare = 0.0
    grid_pct_dead_flt = 0.0
    
    open(unit=113, file=trim(adjustL(veg_out_file)))
    read(113,*) dump_txt
    do i = 1,ngrid
        read(113,*) dump_flt,dump_flt,dump_flt,dump_flt,dump_flt,   &
   &                dump_flt,dump_flt,dump_flt,dump_flt,dump_flt,   &
   &                dump_flt,dump_flt,dump_flt,dump_flt,dump_flt,   &
   &                dump_flt,                                       &
   &                grid_pct_water(i),                              &
   &                dump_flt,dump_flt,dump_flt,                     & 
   &                grid_pct_upland(i),                             &
   &                dump_flt,dump_flt,dump_flt,dump_flt,dump_flt,   &
   &                dump_flt,dump_flt,dump_flt,dump_flt,dump_flt,   &
   &                dump_flt,dump_flt,dump_flt,                     &              
   &                grid_pct_bare(i),                               &
   &                dump_flt,dump_flt,dump_flt,dump_flt,dump_flt,   &
   &                dump_flt,dump_flt,dump_flt,dump_flt,            &               
   &                grid_pct_dead_flt(i),                           &
   &                grid_pct_vglnd_BLHF(i),                         &
   &                grid_pct_vglnd_SWF(i),                          &
   &                grid_pct_vglnd_FM(i),                           &
   &                grid_pct_vglnd_IM(i),                           &
   &                grid_pct_vglnd_BM(i),                           &
   &                grid_pct_vglnd_SM(i),                           &
   &                grid_FIBS_score(i)
        
    end do
    close(113)

        
    return
end