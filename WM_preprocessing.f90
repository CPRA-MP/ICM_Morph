subroutine preprocessing
    
    use params
    implicit none
    
    ! local variables
    integer :: i                    ! iterator
    integer :: n_dem_col            ! number of columns (e.g. range in X) in DEM when mapped
    integer :: n_dem_row            ! number of rows (e.g. range in Y) in DEM when mapped
    integer :: i_col                ! X-coordinate converted to column number of mapped DEM
    integer :: i_row                ! Y-coordinate converted to row number of mapped DEM


    ! read pixel-to-compartment mapping file into arrays
    write(  *,*) ' - reading in DEM-pixel-to-compartment map data'
    write(000,*) ' - reading in DEM-pixel-to-compartment map data'
   
    open(unit=1111, file=trim(adjustL(comp_file)))
!    read(1111,*) dump_txt        ! dump header
    do i = 1,ndem
        read(1111,*) dump_int,dump_int,dem_comp(i)
    end do
    close(1111)
 
    ! read pixel-to-grid mapping file into arrays
    write(  *,*) ' - reading in DEM-pixel-to-grid cell map data'
    write(000,*) ' - reading in DEM-pixel-to-grid cell map data'
  
    open(unit=1112, file=trim(adjustL(grid_file)))
!    read(1112,*) dump_txt        ! dump header
    do i = 1,ndem    
        read(1112,*) dump_int,dump_int,dem_grid(i)
    end do
    close(1112)

    
    ! read xyz file into arrays
    write(  *,*) ' - reading in DEM data'
    write(000,*) ' - reading in DEM data'

    grid_ndem_all = 0                   ! before looping through all DEM pixels, initialize counter array to zero
    comp_ndem_all = 0                   ! before looping through all DEM pixels, initialize counter array to zero    

    
    open(unit=1110, file=trim(adjustL(dem_file)))
   
!    read(1110,*) dump_txt        ! dump header
    do i = 1,ndem
        read(1110,*) dem_x(i),dem_y(i),dem_z(i)
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
        comp_ndem_all(dem_comp(i)) =  comp_ndem_all(dem_comp(i)) + 1
        grid_ndem_all(dem_grid(i)) =  grid_ndem_all(dem_grid(i)) + 1
    end do
    close(1110)
    
    ! calculate number of rows and columns in mapped DEM from X-Y ranges determined above
    n_dem_col = 1+(dem_URx - dem_LLx)/dem_res
    n_dem_row = 1+(dem_URy - dem_LLy)/dem_res
    
    ! allocate array for DEM map    
    call dem_params_alloc(n_dem_col,n_dem_row)
    
    ! initialize arrays to 0
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

    ! read LWF map file into arrays
    write(  *,*) ' - reading in land-water map data'
    write(000,*) ' - reading in land-water map data'
  
    open(unit=1113, file=trim(adjustL(lwf_file)))    
!    read(1113,*) dump_txt        ! dump header
    do i = 1,ndem 
        read(1113,*) dump_int,dump_int,dem_lndtyp(i)
    end do
    close(1113)
    
    
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
    open(unit=114, file=trim(adjustL(monthly_max_stage_file)))
    open(unit=115, file=trim(adjustL(monthly_ow_sed_dep_file)))
    open(unit=116, file=trim(adjustL(monthly_mi_sed_dep_file)))
    open(unit=117, file=trim(adjustL(monthly_me_sed_dep_file)))
    
    read(113,*) dump_txt        ! dump header
    read(114,*) dump_txt        ! dump header
    read(115,*) dump_txt        ! dump header
    read(116,*) dump_txt        ! dump header
    read(117,*) dump_txt        ! dump header
    
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
        
        read(114,*) dump_int,                   &
   &         stg_mx_mons(i,1),                  &
   &         stg_mx_mons(i,2),                  &
   &         stg_mx_mons(i,3),                  &
   &         stg_mx_mons(i,4),                  &
   &         stg_mx_mons(i,5),                  &
   &         stg_mx_mons(i,6),                  &
   &         stg_mx_mons(i,7),                  &
   &         stg_mx_mons(i,8),                  &
   &         stg_mx_mons(i,9),                  &
   &         stg_mx_mons(i,10),                 &
   &         stg_mx_mons(i,11),                 &
   &         stg_mx_mons(i,12)       
        
        read(115,*) dump_int,                   &
   &         sed_dp_ow_mons(i,1),               &
   &         sed_dp_ow_mons(i,2),               &
   &         sed_dp_ow_mons(i,3),               &
   &         sed_dp_ow_mons(i,4),               &
   &         sed_dp_ow_mons(i,5),               &
   &         sed_dp_ow_mons(i,6),               &
   &         sed_dp_ow_mons(i,7),               &
   &         sed_dp_ow_mons(i,8),               &
   &         sed_dp_ow_mons(i,9),               &
   &         sed_dp_ow_mons(i,10),              &
   &         sed_dp_ow_mons(i,11),              &
   &         sed_dp_ow_mons(i,12)        
        
        read(116,*) dump_int,                   &
   &         sed_dp_mi_mons(i,1),               &
   &         sed_dp_mi_mons(i,2),               &
   &         sed_dp_mi_mons(i,3),               &
   &         sed_dp_mi_mons(i,4),               &
   &         sed_dp_mi_mons(i,5),               &
   &         sed_dp_mi_mons(i,6),               &
   &         sed_dp_mi_mons(i,7),               &
   &         sed_dp_mi_mons(i,8),               &
   &         sed_dp_mi_mons(i,9),               &
   &         sed_dp_mi_mons(i,10),              &
   &         sed_dp_mi_mons(i,11),              &
   &         sed_dp_mi_mons(i,12)
        
        read(117,*) dump_int,                   &
   &         sed_dp_me_mons(i,1),               &
   &         sed_dp_me_mons(i,2),               &
   &         sed_dp_me_mons(i,3),               &
   &         sed_dp_me_mons(i,4),               &
   &         sed_dp_me_mons(i,5),               &
   &         sed_dp_me_mons(i,6),               &
   &         sed_dp_me_mons(i,7),               &
   &         sed_dp_me_mons(i,8),               &
   &         sed_dp_me_mons(i,9),               &
   &         sed_dp_me_mons(i,10),              &
   &         sed_dp_me_mons(i,11),              &
   &         sed_dp_me_mons(i,12)        
  
    end do
    
    close(113)
    close(114)
    close(115)
    close(116)            
    close(117)
    
    ! read ICM-LAVegMod grid output file into arrays
    write(  *,*) ' - reading in ICM-LAVegMod grid-level output'
    write(000,*) ' - reading in ICM-LAVegMod grid-level output'
    
    ! initialize grid data arrays to 0.0
    grid_pct_water = 0.0
    grid_pct_upland = 0.0
    grid_pct_bare = 0.0
    grid_pct_dead_flt = 0.0
    grid_bed_z = 0.0
    grid_land_z = 0.0
    
    open(unit=118, file=trim(adjustL(veg_out_file)))
    read(118,*) dump_txt        ! dump header
    do i = 1,ngrid
        read(118,*) dump_flt,                                       &      !  CELLID,
   &                dump_flt,                                       &      !  DISP, 
   &                dump_flt,                                       &      !  SPPA, 
   &                dump_flt,                                       &      !  PAAM2, 
   &                dump_flt,                                       &      !  TADI2, 
   &                dump_flt,                                       &      !  PAHE2_Flt, 
   &                dump_flt,                                       &      !  SPPABI, 
   &                dump_flt,                                       &      !  PAVA, 
   &                dump_flt,                                       &      !  HYUM, 
   &                dump_flt,                                       &      !  BAHABI, 
   &                dump_flt,                                       &      !  JURO, 
   &                dump_flt,                                       &      !  ELBA2, 
   &                dump_flt,                                       &      !  STHE9, 
   &                dump_flt,                                       &      !  CLMA10, 
   &                dump_flt,                                       &      !  SPVI3, 
   &                dump_flt,                                       &      !  SCCA11, 
   &                grid_pct_water(i),                              &      !  WATER, 
   &                dump_flt,                                       &      !  DISPBI, 
   &                dump_flt,                                       &      !  HYUM_Flt, 
   &                dump_flt,                                       &      !  SALA, 
   &                grid_pct_upland(i),                             &      !  NOTMOD, 
   &                dump_flt,                                       &      !  IVFR, 
   &                dump_flt,                                       &      !  PHAU7, 
   &                dump_flt,                                       &      !  QUNI, 
   &                dump_flt,                                       &      !  QULE, 
   &                dump_flt,                                       &      !  NYAQ2, 
   &                dump_flt,                                       &      !  SAV, 
   &                dump_flt,                                       &      !  SANI, 
   &                dump_flt,                                       &      !  ULAM, 
   &                dump_flt,                                       &      !  ZIMI, 
   &                dump_flt,                                       &      !  QULA3, 
   &                dump_flt,                                       &      !  TYDO, 
   &                dump_flt,                                       &      !  PAHE2, 
   &                dump_flt,                                       &      !  UNPA, 
   &                grid_pct_bare(i),                               &      !  BAREGRND, 
   &                dump_flt,                                       &      !  BAHA, 
   &                dump_flt,                                       &      !  QUVI, 
   &                dump_flt,                                       &      !  SPAL, 
   &                dump_flt,                                       &      !  MOCE2, 
   &                dump_flt,                                       &      !  ELBA2_Flt, 
   &                dump_flt,                                       &      !  SOSE, 
   &                dump_flt,                                       &      !  SALA2, 
   &                dump_flt,                                       &      !  QUTE, 
   &                dump_flt,                                       &      !  AVGE,
   &                grid_pct_dead_flt(i),                           &      !  DEAD_FLT,
   &                grid_pct_vglnd_BLHF(i),                         &      !  Bottomland Hardwood 
   &                grid_pct_vglnd_SWF(i),                          &      !  Swamp 
   &                grid_pct_vglnd_FM(i),                           &      !  Fresh
   &                grid_pct_vglnd_IM(i),                           &      !  Intermediate
   &                grid_pct_vglnd_BM(i),                           &      !  Brackish
   &                grid_pct_vglnd_SM(i),                           &      !  Saline 
   &                grid_FIBS_score(i)                                     !  FIBS
    end do
    close(118)

        
    return
end