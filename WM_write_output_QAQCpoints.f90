subroutine write_output_QAQC_points
    ! Subroutine that writes output files with data at QAQC points.
    ! There will be a separate file for each QAQC point
    ! The file will be opened in 'write' mode during the first year (which will overwrite)
    ! any pre-existing file.
    ! All subsequent years will be opened in 'append' mode so that a timeseries file is written.
    
    
    

    use params
    implicit none
    
    ! local variables
    integer :: i                                                    ! iterator
    integer :: site_no                  ! site number of QAQC point
    integer :: site_x                   ! local variable to read in X-coord of QAQC point
    integer :: site_y                   ! local variable to read in Y-coord of QAQC point
    character*300 :: qaqc_filetag       ! text tag to include in output file name for QAQC point
    character*300 :: qaqc_file          ! file name used to write QAQC point output data to
    character*4 :: site_no_text         ! formatted text string for site number
    
    integer :: i_col                    ! X-coordinate converted to column number of mapped DEM
    integer :: i_row                    ! Y-coordinate converted to row number of mapped DEM
    integer :: col_lookup               ! local variable to find DEM pixel index corresponding to QAQC point
    integer :: row_lookup               ! local variable to find DEM pixel index corresponding to QAQC point
    integer :: idem                     ! local variable that determined DEM pixel index corresponding to QAQC point pixel location

    real(sp) :: mwl                     ! local variable of mean water level - filtered for NoData
    real(sp) :: mdep                    ! local variable of mineral deposition - calculated from bulk density/self packing density and mineral accretion
    real(sp) :: omar                    ! local variable of mean water level - calculated from self packing density and organic accretion
    real(sp) :: FFIBS                   ! local variable of grid FFIBS score - filtered for NoData
    real(sp) :: grid_z_out              ! local variable of mean land elevation in grid cell - filtered for NoData
    real(sp) :: grid_bed_z_out          ! local variable of mean water bed elevation in grid cell - filtered for NoData
              
    ! write end-of-year data to QAQC file - one file per each point   
    write(  *,*) ' - writing end-of-year QAQC summary files'
    write(000,*) ' - writing end-of-year QAQC summary files'
    open(unit=42, file = trim(adjustL(qaqc_site_list_file)))
    
    read(42,*) dump_txt         ! skip header row
    
    do i = 1,nqaqc
        read(42,*) site_no,                          &
   &               site_x,                           &
   &               site_y,                           &
   &               qaqc_filetag
        write(site_no_text,'(I4.4)') site_no
        qaqc_file = trim(adjustL(fnc_tag))//"_QAQC_"//trim(adjustL(site_no_text))//"_"//trim(adjustL(qaqc_filetag))//'.csv'
        
        ! open site-specific QAQC file, if not first year then open in 'append' mode
        if (elapsed_year == 1) then
            open(unit=666, file = 'geomorph/output_qaqc/'//trim(adjustL(qaqc_file)))
            write(666,'(A)')'QAQC_site_no,X_UTMm,Y_UTMm,Hydro_compID,comp_mwl_NAVD88m,pixel_z_NAVD88m,annual_mean_inun_depth_m,pixel_lndtyp,pixel_mnrl_dep_g/cm2-yr,pixel_mnrl_accr_cm,pixel_org_accum_g/cm2-yr,pixel_org_accr_cm,LAVegMod_gridID,grid_FFIBS,grid_land_z_NAVD88m,grid_wat_z_NAVD88m'
        else   
            open(unit=666, file = 'geomorph/output_qaqc/'//trim(adjustL(qaqc_file)),position='append')
        end if
        
        col_lookup = 1+(site_x - dem_LLx)/dem_res                           ! find column number in mapped DEM that corresponds to QAQC pointX-coord
        row_lookup = 1+(site_y - dem_LLy)/dem_res                           ! find row number in mapped DEM that corresponds to QAQC point Y-coord
        idem = dem_index_mapped(col_lookup,row_lookup)                      ! find index number of DEM pixel that corresponds to QAQC point XY-coordinates

        if (dem_comp(idem) /= dem_NoDataVal) then                           ! since dem_comp is an array pointer, must check if NoData
            mwl = stg_av_yr(dem_comp(idem))
        else
            mwl = dem_NoDataVal
        end if
        
        if (dem_lndtyp(idem) == 2) then 
            mdep = min_accr_cm(idem)*ow_bd
        else
            mdep = min_accr_cm(idem)*mn_k2
        end if
                
        omar = org_accr_cm(idem)*om_k1
        
        if (dem_grid(idem) /= dem_NoDataVal) then                           ! since dem_grid is an array pointer, must check if NoData
            FFIBS = grid_FIBS_score(dem_grid(idem))
            grid_z_out = grid_land_z(dem_grid(idem))
            grid_bed_z_out = grid_bed_z(dem_grid(idem))
        else
            FFIBS = dem_NoDataVal
            grid_z_out = dem_NoDataVal
            grid_bed_z_out = dem_NoDataVal
        end if

        
        write(666,42666)site_no,site_x,site_y,  &       ! QAQC_site_no,X_UTMm,Y_UTMm
   &                    dem_comp(idem),         &       ! Hydro_compID
   &                    mwl,                    &       ! comp_mwl_NAVD88m
   &                    dem_z(idem),            &       ! pixel_z_NAVD88m
   &                    dem_inun_dep(idem,13),  &       ! annual_mean_inun_depth_m (tp=13 for annual mean)
   &                    dem_lndtyp(idem),       &       ! pixel_lndtyp
   &                    mdep,                   &       ! pixel_mnrl_dep_gcm^-2
   &                    min_accr_cm(idem),      &       ! pixel_mnrl_accr_cm
   &                    omar,                   &       ! pixel_org_accum_gcm^-3
   &                    org_accr_cm(idem),      &       ! pixel_org_accr_cm
   &                    dem_grid(idem),         &       ! LAVegMod_gridID
   &                    FFIBS,                  &       ! grid_FFIBS
   &                    grid_z_out,             &       ! grid_land_z_NAVD88m
   &                    grid_bed_z_out                  ! grid_wat_z_NAVD88m        
        close(666)
    
    end do
    close(42)

42666 format(4(I0,','),3(F0.2,','),I0,',',4(F0.2,','),2(I0,','),F0.2,',',F0.2) 
     
    
        
        
    return

end