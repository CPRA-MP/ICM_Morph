subroutine preprocessing
    
    use params
    implicit none
    
    ! local variables
    integer :: i                        ! iterator
    integer :: c                        ! local compartment ID variable
    integer :: g                        ! local ICM-LAVegMod grid ID variable
    integer :: i_col                    ! X-coordinate converted to column number of mapped DEM
    integer :: i_row                    ! Y-coordinate converted to row number of mapped DEM
    integer :: dem_x_bi                 ! local variable to read in X-coord of ICM-BI-DEM interpolated point
    integer :: dem_y_bi                 ! local variable to read in Y-coord of ICM-BI-DEM interpolated point
    integer :: col_lookup               ! local variable to find DEM pixel index corresponding to ICM-BI-DEM interpolated point
    integer :: row_lookup               ! local variable to find DEM pixel index corresponding to ICM-BI-DEM interpolated point
    integer :: dem_i                    ! local variable that determined DEM pixel index corresponding to ICM-BI-DEM pixel location
    integer :: en                       ! local variable of ecoregion number used for reading in ecoregion name codes
    
    
    
    ! read pixel-to-compartment mapping file into arrays
    write(  *,*) ' - reading in DEM-pixel-to-compartment map data'
    write(000,*) ' - reading in DEM-pixel-to-compartment map data'
   
    if (binary_in == 1) then
        write(  *,*) '   - using binary file'
        write(000,*) '   - using binary file'
        open(unit=1111, file=trim(adjustL(comp_file))//'.b',form='unformatted')
        read(1111) dem_comp
    else
        open(unit=1111, file=trim(adjustL((comp_file))))
!        read(1111,*) dump_txt        ! dump header
        do i = 1,ndem
            read(1111,*) dump_int,dump_int,dem_comp(i)
        end do
    end if
    close(1111)
 
    ! read pixel-to-grid mapping file into arrays
    write(  *,*) ' - reading in DEM-pixel-to-grid cell map data'
    write(000,*) ' - reading in DEM-pixel-to-grid cell map data'
    
    if (binary_in == 1) then
        write(  *,*) '   - using binary file'
        write(000,*) '   - using binary file'
        open(unit=1112, file=trim(adjustL(grid_file))//'.b',form='unformatted')
        read(1112) dem_grid
    else
        open(unit=1112, file=trim(adjustL(grid_file)))
    !    read(1112,*) dump_txt        ! dump header
        do i = 1,ndem    
            read(1112,*) dump_int,dump_int,dem_grid(i)
        end do
    end if
    close(1112)

    
!    ! read xyz file into arrays
!    write(  *,*) ' - reading in DEM data'
!    write(000,*) ' - reading in DEM data'
!    dem_x = 0
!    dem_y = 0
!    dem_z = 0.0
!    
    if (binary_in == 1) then
        write(  *,*) '   - using binary files'
        write(000,*) '   - using binary files'
        
        open(unit=11100, file=trim(adjustL('geomorph/output/raster_x_coord.b')),form='unformatted')         ! binary filename for x-coordinate is hard-set in WRITE_OUTPUT_RASTERS_BIN - it is not read in via SET_IO
        read(11100) dem_x
        close(11100) 
        
        open(unit=111000, file=trim(adjustL('geomorph/output/raster_y_coord.b')),form='unformatted')         ! binary filename for y-coordinate is hard-set in WRITE_OUTPUT_RASTERS_BIN - it is not read in via SET_IO
        read(111000) dem_y       
        close(111000)
        
        open(unit=1110, file=trim(adjustL(dem_file))//'.b',form='unformatted')
        read(1110) dem_z
    else   
        open(unit=1110, file=trim(adjustL(dem_file)))
        ! read(1110,*) dump_txt        ! dump header
        do i = 1,ndem
            read(1110,*) dem_x(i),dem_y(i),dem_z(i)
        end do
    end if

    close(1110)
    grid_ndem_all = 0                   ! before looping through all DEM pixels, initialize counter array to zero
    comp_ndem_all = 0                   ! before looping through all DEM pixels, initialize counter array to zero    


     
    
    ! read ICM-Hydro compartment output file into arrays
    write(  *,*) ' - reading in annual ICM-Hydro compartment-level output'
    write(000,*) ' - reading in annual ICM-Hydro compartment-level output'
    
    open(unit=112, file=trim(adjustL(hydro_comp_out_file)))
    
    read(112,*) dump_txt        ! dump header
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
    
    ! read previous year's ICM-Hydro compartment output file into arrays
    write(  *,*) ' - reading in previous year annual ICM-Hydro compartment-level output'
    write(000,*) ' - reading in previous year annual ICM-Hydro compartment-level output'
    
    open(unit=1120, file=trim(adjustL(prv_hydro_comp_out_file)))
    
    read(1120,*) dump_txt        ! dump header
    do i = 1,ncomp
        read(1120,*) dump_txt,               &
   &         dump_flt    ,                  &
   &         stg_av_prev_yr(i),             &
   &         dump_flt    ,                  &
   &         dump_flt    ,                  &
   &         sal_av_prev_yr(i),             &
   &         dump_flt    ,                  &
   &         dump_flt    ,                  &
   &         dump_flt    ,                  &
   &         dump_flt    ,                  &
   &         dump_flt    ,                  &
   &         dump_flt    ,                  &
   &         dump_flt    ,                  &
   &         dump_flt    ,                  &
   &         dump_flt    ,                  &
   &         dump_flt    ,                  &
   &         dump_flt    ,                  &
   &         dump_flt    ,                  &
   &         dump_flt    ,                  &
   &         dump_flt
    end do
    close(1120)

    ! read in monthly data for stage and sediment deposition (open water and marsh)    
    write(  *,*) ' - reading in monthly ICM-Hydro compartment-level output'
    write(000,*) ' - reading in monthly ICM-Hydro compartment-level output'

    open(unit=113, file=trim(adjustL(monthly_mean_stage_file)))

    read(113,*) dump_txt        ! dump header

    
    do i = 1,ncomp
        read(113,*) dump_int,                   &
   &         stg_av_mons(i,1),                  &
   &         stg_av_mons(i,2),                  &
   &         stg_av_mons(i,3),                  &
   &         stg_av_mons(i,4),                  &
   &         stg_av_mons(i,5),                  &
   &         stg_av_mons(i,6),                  &
   &         stg_av_mons(i,7),                  &
   &         stg_av_mons(i,8),                  &
   &         stg_av_mons(i,9),                  &
   &         stg_av_mons(i,10),                 &
   &         stg_av_mons(i,11),                 &
   &         stg_av_mons(i,12)

    end do
    
    close(113)


    
1234    format(A,53(',',A))
    
    return
end
