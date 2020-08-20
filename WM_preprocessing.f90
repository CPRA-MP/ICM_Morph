subroutine preprocessing
    
    use params
    implicit none
    
    ! local variables
    integer :: i                        ! iterator
    integer :: i_col                    ! X-coordinate converted to column number of mapped DEM
    integer :: i_row                    ! Y-coordinate converted to row number of mapped DEM
    integer :: dem_x_bi                 ! local variable to read in X-coord of ICM-BI-DEM interpolated point
    integer :: dem_y_bi                 ! local variable to read in Y-coord of ICM-BI-DEM interpolated point
    integer :: col_lookup               ! local variable to find DEM pixel index corresponding to ICM-BI-DEM interpolated point
    integer :: row_lookup               ! local variable to find DEM pixel index corresponding to ICM-BI-DEM interpolated point
    integer :: dem_i                    ! local variable that determined DEM pixel index corresponding to ICM-BI-DEM pixel location

    ! read pixel-to-compartment mapping file into arrays
    write(  *,*) ' - reading in DEM-pixel-to-compartment map data'
    write(000,*) ' - reading in DEM-pixel-to-compartment map data'
   

    open(unit=1111, file=trim(adjustL(('input/'//comp_file))))
!    read(1111,*) dump_txt        ! dump header
    do i = 1,ndem
        read(1111,*) dump_int,dump_int,dem_comp(i)
    end do
    close(1111)
 
    ! read pixel-to-grid mapping file into arrays
    write(  *,*) ' - reading in DEM-pixel-to-grid cell map data'
    write(000,*) ' - reading in DEM-pixel-to-grid cell map data'
  
    open(unit=1112, file=trim(adjustL('input/'//grid_file)))
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

    
    open(unit=1110, file=trim(adjustL('input/'//dem_file)))
   
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
    
    ! set variables that hold maximum count per grid/compartment for later array allocation sizes
    grid_ndem_mx = maxval(grid_ndem_all)
    comp_ndem_mx = maxval(comp_ndem_all)
    
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
  
    open(unit=1113, file=trim(adjustL('input/'//lwf_file)))    
!    read(1113,*) dump_txt        ! dump header
    do i = 1,ndem 
        read(1113,*) dump_int,dump_int,dem_lndtyp(i)
    end do
    close(1113)
   
    
    ! read marsh edge erosion rate map file into arrays
    write(  *,*) ' - reading in marsh edge erosion rate map data'
    write(000,*) ' - reading in marsh edge erosion rate map data'
  
    open(unit=1114, file=trim(adjustL('input/'//meer_file)))    
!    read(1114,*) dump_txt        ! dump header
    do i = 1,ndem 
        read(1114,*) dump_int,dump_int,dem_meer(i)
    end do
    close(1114)
    
    
    ! read in ecoregion-to-compartment map
    write(  *,*) ' - reading in ICM-Hydro compartment-to-ecoregion lookup table'
    write(000,*) ' - reading in ICM-Hydro compartment-to-ecoregion lookup table'
    
    ! initialize grid data arrays to 0.0
    comp_eco = 0.0
    
    open(unit=1115, file=trim(adjustL('input/'//comp_eco_file)))
    read(1115,*) dump_txt                            ! dump header
    do i = 1,neco
        read(1115,*) dump_int,               &       ! ICM-Hydro_comp
   &                 comp_eco(i),            &       ! ecoregion number 
   &                 dump_txt,               &       ! ecoregion code
   &                 dump_txt                        ! descriptive name
    end do
    close(1115)
  
    ! read in active delta compartment flags
    write(  *,*) ' - reading in ICM-Hydro compartment table assigning active deltaic locations'
    write(000,*) ' - reading in ICM-Hydro compartment table assigning active deltaic locations'
    
    ! initialize grid data arrays to 0.0
    comp_act_dlt = 0.0
    
    open(unit=1116, file=trim(adjustL('input/'//act_del_file)))
    read(1116,*) dump_txt                               ! dump header
    do i = 1,ncomp
        read(1116,*) dump_int,comp_act_dlt(i)           ! compartment ID, active delta flag
    end do
    close(1116)
    
    ! read in deep subsidence data
    write(  *,*) ' - reading in deep susidence rate map'
    write(000,*) ' - reading in deep susidence rate map'
    
    ! initialize grid data arrays to 0.0
    dem_dpsb = 0.0
    
    open(unit=1117, file=trim(adjustL('input/'//dsub_file)))
    !read(1117,*) dump_txt                               ! dump header
    do i = 1,ndem
        read(1117,*) dump_int,dump_int,dem_dpsb(i)      ! X, Y, deep subsidence
        if (dem_dpsb(i) == dem_NoDataVal) then          ! set to zero if no data
            dem_dpsb(i) = 0.0
        end if
    end do
    close(1117)
    
    ! read in shallow subsidence lookup table
    write(  *,*) ' - reading in shallow subsidence statistics by ecoregion'
    write(000,*) ' - reading in shallow subsidence statistics by ecoregion'
    
    ! initialize table to 0.0
    er_shsb = 0.0
    
    open(unit=1118, file=trim(adjustL('input/'//ssub_file)))
    read(1118,*) dump_txt                               ! dump header
    do i = 1,neco
        read(1118,*) dump_int,                  &       ! ecoregion number
   &                dump_txt,                   &       ! ecoregion abbreviation
   &                dump_txt,                   &        ! 25th %ile shallow subsidence rate (mm/yr) - positive is downward
   &                dump_flt,                   &       ! 50th %ile shallow subsidence rate (mm/yr) - positive is downward
   &                er_shsb(i),                 &       ! 75th %ile shallow subsidence rate (mm/yr) - positive is downward
   &                dump_flt,                   &       ! 25th %ile shallow subsidence rate (mm/yr) - positive is downward
   &                dump_txt                            ! notes
    end do
    close(1118) 

    ! read polder area map file into arrays
    write(  *,*) ' - reading in polder map data'
    write(000,*) ' - reading in polder map data'
  
    open(unit=1119, file=trim(adjustL('input/'//pldr_file)))    
!    read(1119,*) dump_txt        ! dump header
    do i = 1,ndem 
        read(1119,*) dump_int,dump_int,dem_pldr(i)
    end do
    close(1119)    
     
    
    ! read ICM-Hydro compartment output file into arrays
    write(  *,*) ' - reading in annual ICM-Hydro compartment-level output'
    write(000,*) ' - reading in annual ICM-Hydro compartment-level output'
    
    open(unit=112, file=trim(adjustL('input/'//hydro_comp_out_file)))
    
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
    
    open(unit=1120, file=trim(adjustL('input/'//prv_hydro_comp_out_file)))
    
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

    open(unit=113, file=trim(adjustL('input/'//monthly_mean_stage_file)))
    open(unit=114, file=trim(adjustL('input/'//monthly_max_stage_file)))
    open(unit=115, file=trim(adjustL('input/'//monthly_ow_sed_dep_file)))
    open(unit=116, file=trim(adjustL('input/'//monthly_mi_sed_dep_file)))
    open(unit=117, file=trim(adjustL('input/'//monthly_me_sed_dep_file)))
    
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
    grid_pct_bare_old = 0.0
    grid_pct_bare_new = 0.0
    grid_pct_dead_flt = 0.0
    grid_bed_z = 0.0
    grid_land_z = 0.0
    
    open(unit=118, file=trim(adjustL('input/'//veg_out_file)))
    do i = 1,622
        read(118,*) dump_txt        ! dump header
    end do
    do i = 1,ngrid
        read(118,*) dump_flt,                                       &      ! CELLID, 
   &                dump_flt,                                       &      ! NYAQ2, 
   &                dump_flt,                                       &      ! SANI, 
   &                dump_flt,                                       &      ! TADI2, 
   &                dump_flt,                                       &      ! ELBA2_Flt, 
   &                dump_flt,                                       &      ! PAHE2_Flt, 
   &                dump_flt,                                       &      ! PAHE2, 
   &                dump_flt,                                       &      ! BAREGRND_Flt,
   &                dump_flt,                                       &      ! DEAD_Flt, 
   &                dump_flt,                                       &      ! COES, 
   &                dump_flt,                                       &      ! MOCE2, 
   &                dump_flt,                                       &      ! SALA2, 
   &                dump_flt,                                       &      ! ZIMI, 
   &                dump_flt,                                       &      ! CLMA10, 
   &                dump_flt,                                       &      ! ELCE, 
   &                dump_flt,                                       &      ! POPU5, 
   &                dump_flt,                                       &      ! SALA, 
   &                dump_flt,                                       &      ! IVFR, 
   &                dump_flt,                                       &      ! PAVA, 
   &                dump_flt,                                       &      ! PHAU7, 
   &                dump_flt,                                       &      ! SCCA11, 
   &                dump_flt,                                       &      ! TYDO, 
   &                dump_flt,                                       &      ! SCAM6, 
   &                dump_flt,                                       &      ! SCRO5, 
   &                dump_flt,                                       &      ! SPPA, 
   &                dump_flt,                                       &      ! SPCY, 
   &                dump_flt,                                       &      ! DISP, 
   &                dump_flt,                                       &      ! JURO, 
   &                dump_flt,                                       &      ! AVGE, 
   &                dump_flt,                                       &      ! SPAL, 
   &                grid_pct_bare_old(i),                           &      ! BAREGRND_OLD,
   &                grid_pct_bare_new(i),                           &      ! BAREGRND_NEW,
   &                grid_pct_upland(i),                             &      ! NOTMOD, 
   &                grid_pct_water(i),                              &      ! WATER, 
   &                dump_flt,                                       &      ! SAV, 
   &                dump_flt,                                       &      ! QULA3, 
   &                dump_flt,                                       &      ! QULE, 
   &                dump_flt,                                       &      ! QUNI, 
   &                dump_flt,                                       &      ! QUTE, 
   &                dump_flt,                                       &      ! QUVI, 
   &                dump_flt,                                       &      ! ULAM, 
   &                dump_flt,                                       &      ! BAHABI, 
   &                dump_flt,                                       &      ! DISPBI, 
   &                dump_flt,                                       &      ! PAAM2, 
   &                dump_flt,                                       &      ! SOSE, 
   &                dump_flt,                                       &      ! SPPABI,                               
   &                dump_flt,                                       &      ! SPVI3,                               
   &                dump_flt,                                       &      ! STHE9,                               
   &                dump_flt,                                       &      ! UNPA,                                
   &                grid_FIBS_score(i),                             &      ! FFIBS, 
   &                grid_pct_vglnd_BLHF(i),                         &      ! pL_BF, 
   &                grid_pct_vglnd_SWF(i),                          &      ! pL_SF, 
   &                grid_pct_vglnd_FM(i),                           &      ! pL_FM, 
   &                grid_pct_vglnd_IM(i),                           &      ! pL_IM, 
   &                grid_pct_vglnd_BM(i),                           &      ! pL_BM, 
   &                grid_pct_vglnd_SM(i),                           &      ! pL_SM, 
   &                grid_pct_dead_flt(i)                                   ! Dead_Flt
    end do
    close(118)

    
    ! read ICM-LAVegMod grid output file into arrays
    write(  *,*) ' - reading in ecoregion orgranic accumulation tables'
    write(000,*) ' - reading in ecoregion orgranic accumulation tables'
    
    open(unit=119, file=trim(adjustL('input/'//eco_omar_file)))
    read(119,*) dump_txt        ! dump header
    
    do i=1,neco                               
        read(119,*) dump_int,                                       &      ! er_n,
   &                dump_txt,                                       &      ! er,
   &                dump_flt,                                       &      ! SwampOrgAccum_g_cm^-2_yr^-1_lower,
   &                er_omar(i,1),                                   &      ! SwampOrgAccum_g_cm^-2_yr^-1_median,
   &                dump_flt,                                       &      ! SwampOrgAccum_g_cm^-2_yr^-1_upper,
   &                dump_flt,                                       &      ! FreshOrgAccum_g_cm^-2_yr^-1_lower,
   &                er_omar(i,2),                                   &      ! FreshOrgAccum_g_cm^-2_yr^-1_median,
   &                dump_flt,                                       &      ! FreshOrgAccum_g_cm^-2_yr^-1_upper,
   &                dump_flt,                                       &      ! InterOrgAccum_g_cm^-2_yr^-1_lower,
   &                er_omar(i,3),                                   &      ! InterOrgAccum_g_cm^-2_yr^-1_median,
   &                dump_flt,                                       &      ! InterOrgAccum_g_cm^-2_yr^-1_upper,
   &                dump_flt,                                       &      ! BrackOrgAccum_g_cm^-2_yr^-1_lower,
   &                er_omar(i,4),                                   &      ! BrackOrgAccum_g_cm^-2_yr^-1_median,
   &                dump_flt,                                       &      ! BrackOrgAccum_g_cm^-2_yr^-1_upper,
   &                dump_flt,                                       &      ! SalineOrgAccum_g_cm^-2_yr^-1_lower,
   &                er_omar(i,5),                                   &      ! SalineOrgAccum_g_cm^-2_yr^-1_median,
   &                dump_flt,                                       &      ! SalineOrgAccum_g_cm^-2_yr^-1_upper,
   &                dump_flt,                                       &      ! ActiveFreshOrgAccum_g_cm^-2_yr^-1_lower,
   &                er_omar(i,6),                                   &      ! ActiveFreshOrgAccum_g_cm^-2_yr^-1_median,
   &                dump_flt                                               ! ActiveFreshOrgAccum_g_cm^-2_yr^-1_upper
    end do                                                                 
    close(119)                                                             
                                                                           
    ! read ICM-BI-DEM area map file into arrays
    write(  *,*) ' - reading in ICM-BI-DEM and mapping lookup to main DEM'
    write(000,*) ' - reading in ICM-BI-DEM and mapping lookup to main DEM'

    dem_to_bidem = dem_NoDataVal                                            ! initialize DEM-to-ICM-BI-DEM map lookup array to NoData

    open(unit=120, file=trim(adjustL('input/'//bi_dem_xyz_file)))    
!    read(120,*) dump_txt        ! dump header
    do i = 1,ndem_bi
        read(120,*) dem_x_bi, dem_y_bi, dem_z_bi(i)
   
        col_lookup = 1+(dem_x_bi - dem_LLx)/dem_res                         ! find column number in mapped DEM that corresponds to BI-DEM X-coord
        row_lookup = 1+(dem_y_bi - dem_LLy)/dem_res                         ! find row number in mapped DEM that corresponds to BI-DEM Y-coord
        dem_i = dem_index_mapped(col_lookup,row_lookup)                     ! find index number of DEM pixel that corresponds to BI-DEM XY-coordinates
        dem_to_bidem(dem_i) = i
    
    end do    
    close(120)    
    
    
    
    
    return
end