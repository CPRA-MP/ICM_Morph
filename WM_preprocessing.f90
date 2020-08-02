subroutine preprocessing
    
    use params
    implicit none
    
    ! local variables
    integer :: i                    ! iterator
    
    ! read xyz file into arrays
    write(  *,*) ' - reading in DEM data for: ',trim(adjustL(dem_file))
    write(000,*) ' - reading in DEM data for: ',trim(adjustL(dem_file))
    open(unit=111, file=trim(adjustL(dem_file)))
    comp_ndem_all = 0                   ! before looping through all DEM pixels, initialize counter array to zero
    grid_ndem_all = 0                   ! before looping through all DEM pixels, initialize counter array to zero
    read(111,*) dump_txt
    do i = 1,ndem
        read(111,*) dem_x(i), dem_y(i), dem_z(i), dem_comp(i), dem_grid(i), dem_lndtyp(i)
        comp_ndem_all(dem_comp) =  comp_ndem_all(dem_comp) + 1  !count number of DEM pixels within each ICM-Hydro compartment
        grid_ndem_all(dem_grid) =  grid_ndem_all(dem_grid) + 1  !count number of DEM pixels within each ICM-LAVegMod grid cell
    end do
    close(111)

    
    ! read ICM-Hydro compartment output file into arrays
    write(  *,*) ' - reading in ICM-Hydro compartment-level output'
    write(000,*) ' - reading in ICM-Hydro compartment-level output'
    open(unit=112, file=trim(adjustL(hydro_comp_out_file)))
    read(112,*) dump_txt
    do i = 1,ncomp
        read(112,*) dump_txt,                   &
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
        read(113,*) dump_flt,dump_flt,dump_flt,dump_flt,dump_flt, &
   &                dump_flt,dump_flt,dump_flt,dump_flt,dump_flt, &
   &                dump_flt,dump_flt,dump_flt,dump_flt,dump_flt, &
   &                dump_flt,                                     &
   &                grid_pct_water(i),                            &
   &                dump_flt,dump_flt,dump_flt,                   & 
   &                grid_pct_upland(i),                           &
   &                dump_flt,dump_flt,dump_flt,dump_flt,dump_flt, &
   &                dump_flt,dump_flt,dump_flt,dump_flt,dump_flt, &
   &                dump_flt,dump_flt,dump_flt,                   &            
   &                grid_pct_bare(i),                             &
   &                dump_flt,dump_flt,dump_flt,dump_flt,dump_flt, &
   &                dump_flt,dump_flt,dump_flt,dump_flt,          &              
   &                grid_pct_dead_flt(i),                         &
   &                grid_FIBS_score(i)
        
    end do
    close(113)

        
    return
end