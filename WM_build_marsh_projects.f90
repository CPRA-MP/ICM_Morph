subroutine build_marsh_projects
    ! global arrays updated by subroutine:

    !
    ! Subroutine updates the elevation and landtype for pixels
    ! that have a marsh creation project implemented on the landscape for the year
    !
    ! 
    
    use params
    implicit none
    
    ! local variables
    integer :: i                                                        ! iterator
    integer :: imc                                                      ! iterator
    integer :: c                                                        ! local compartment ID variable
            
    character*fn_len :: prj_xyz_file                                    ! local variable to store filepath to project raster file
    integer :: ElementID                                         ! local variable to store ElementID string
    integer :: prj_dem_x                                                ! local variable to store X-coordinates of project DEM
    integer :: prj_dem_y                                                ! local variable to store Y-coordinates of project DEM
    real(sp) :: design_elev                                             ! temporary variable to store the calculated design elevation for marsh creation projects to convert from MWL datum to NAVD88
    real(sp),dimension(:),allocatable :: prj_dem_z                      ! project design elevation of DEM pixel (meters above MWL for marsh creation projects)
    real(sp) :: prj_dz_m                                                ! local variable to store the change in elevation (m) due to the project being implemented on a given pixel
    real(sp) :: depth                                                   ! local variable to store water depth (m) of local pixel
    real(sp) :: element_volume_m3                                       ! cumulative sediment volume needed to build current ElementID of project
    real(sp) :: element_footprint_m2                                    ! cumulative sediment volume needed to build current ElementID of project
    
    
    allocate (prj_dem_z(ndem))
    prj_dem_z = dem_NoDataVal           ! intialize project elevation raster to NoData
    
    write(  *,*) ' - implementing FWA marsh creation projects'
    write(000,*) ' - implementing FWA marsh creation projects'

    if (n_mc > 0) then
        write(  *,'(A,I0,A)') '    - ',n_mc,' marsh creation projects being implemented'
        write(000,'(A,I0,A)') '    - ',n_mc,' marsh creation projects being implemented'
        
        open(unit=401, file=trim(adjustL(project_list_MC_file)))
        read(401,*) dump_txt            ! dump header
        
        open(unit=402, file=trim(adjustL(project_list_MC_VA_file)))
        write(402,'(A)') 'ElementID,SedimentVolume_m3,ProjectFootprint_m2'
        
        do imc = 1,n_mc
            prj_dem_z = dem_NoDataVal           ! intialize project elevation raster to NoData
            design_elev = -9999                 ! initialize design elevation to NoData value used in project DEM files
            
            read(401,*) ElementID,prj_xyz_file  ! ElementID and filepath to XYZ raster
            
            write(  *,'(A,I0,A,A)') '      - building ',ElementID,' from XYZ file:',prj_xyz_file
            write(000,'(A,I0,A,A)') '      - building ',ElementID,' from XYZ file:',prj_xyz_file
            
            ! open XYZ file for specific project element
            open(403,  file=trim(adjustL('geomorph/input/'//prj_xyz_file)))
            
            ! read in project DEM
            do i = 1,ndem
                read(403,*) prj_dem_x,prj_dem_y,prj_dem_z(i)
                
                ! check that coordinates of project DEM match the initial DEM used by the model - exit if they do not match structure
                if (prj_dem_x /= dem_x(i)) then
                    write(  *,'(A,I0,A,I0)') ' !!! EXITING !!! project XYZ file X value does not match input DEM structure, dem_x = ', dem_x(i), ', prj_dem_x = ', prj_dem_x
                    write(000,'(A,I0,A,I0)') ' !!! EXITING !!! project XYZ file X value does not match input DEM structure, dem_x = ', dem_x(i), ', prj_dem_x = ', prj_dem_x
                    stop
                end if
                if (prj_dem_y /= dem_y(i)) then
                    write(  *,'(A,I0,A,I0)') ' !!! EXITING !!! project XYZ file X value does not match input DEM structure, dem_x = ', dem_y(i), ', prj_dem_x = ', prj_dem_y
                    write(000,'(A,I0,A,I0)') ' !!! EXITING !!! project XYZ file X value does not match input DEM structure, dem_x = ', dem_y(i), ', prj_dem_x = ', prj_dem_y
                    stop
                end if
                
                ! find correct elevation to build marsh creation project to (input data is defined as the height to build marsh to *above MWL*)
                if (prj_dem_z(i) /= dem_NoDataVal) then
                    if (design_elev == -9999) then      ! if design_elev doesn't equal -9999, it has already been set for this project element
                        c = dem_comp(i)
                        if (c /= dem_NoDataVal) then
                            design_elev = (stg_av_yr(c) + stg_av_prev_yr(c) )*0.5 + prj_dem_z(i)
                        end if
                    end if
                    if (design_elev /= -9999) then
                        prj_dem_z(i) = design_elev  ! update project elevation raster to use the design elevation rather than the height above mean water level
                    end if
                end if
            end do
            close(403)
            ! done reading in project DEM
            
            ! update elevation and land type for project footprint
            element_volume_m3 = 0.0
            element_footprint_m2 = 0.0
            do i = 1,ndem
                if (prj_dem_z(i) /= dem_NoDataVal) then
                    c = dem_comp(i)
                    if (c /= dem_NoDataVal) then
                        depth = ( stg_av_yr(c) - dem_z(i) )     ! negative depth values mean elevation is greater than mean water level
                    end if
                    if (depth <= mc_depth_threshold) then
                        
                        prj_dz_m = prj_dem_z(i) - dem_z(i)     ! calculate change in pixel elevation due to project
                        dem_dz_cm(i) = prj_dz_m*100.0           ! update dZ raster for project implementation *note that for pixels under a project, the dZ raster will be calculated from the end-of-year raster that already has subsidence and accretion update added for the year
                        
                        if (dem_lndtyp(i) == 2) then            ! if pixel originally water, set land change flag to new land
                            lnd_change_flag(i) = 1
                        end if
                        
                        dem_z(i) = prj_dem_z(i)                 ! set pixel elevation to project elevation
                        dem_lndtyp(i) = 3                       ! set pixel landtype to bare ground/unvegetated wetland
                        
                        element_volume_m3 = element_volume_m3 + prj_dz_m*dem_res*dem_res
                        element_footprint_m2 = element_footprint_m2 + dem_res*dem_res
                    end if
                end if
            end do
            ! write summary volumes and footprints to output file for MC projects
            write(402, '(I0,A,F0.4,A,F0.4)') ElementID,',',element_volume_m3,',',element_footprint_m2
        end do    
                
        close(402)
        close(401)
    else
        write(  *,*) '    - no marsh creation projects in this run'
        write(100,*) '    - no marsh creation projects in this run'
    endif
    
    

    
    return
end
