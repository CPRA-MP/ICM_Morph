subroutine build_ridge_projects
    ! global arrays updated by subroutine:

    !
    ! Subroutine updates the elevation and landtype for pixels
    ! that have a ridge or levee project implemented on the landscape for the year
    !
    ! 
    
    use params
    implicit none
    
    ! local variables
    integer :: i                                                        ! iterator
    integer :: irr                                                      ! iterator
            
    character*fn_len :: prj_xyz_file                                    ! local variable to store filepath to project raster file
    integer :: ProjectID                                                ! local variable to store ProjectID integer
    integer :: prj_dem_x                                                ! local variable to store X-coordinates of project DEM
    integer :: prj_dem_y                                                ! local variable to store Y-coordinates of project DEM
    real(sp),dimension(:),allocatable :: prj_dem_z                      ! project design elevation of DEM pixel (m NAVD88 for ridge/levee projects)
    real(sp) :: prj_dz_m                                                ! local variable to store the change in elevation (m) due to the project being implemented on a given pixel
    
    
    allocate (prj_dem_z(ndem))
    prj_dem_z = dem_NoDataVal                                           ! intialize project elevation raster to NoData
    
    write(  *,*) ' - implementing FWA ridge (or levee) projects'
    write(000,*) ' - implementing FWA ridge (or levee) projects'

    if (n_rr > 0) then
        write(  *,'(A,I0,A)') '    - ',n_rr,' ridge (or levee) projects being implemented'
        write(000,'(A,I0,A)') '    - ',n_rr,' ridge (or levee) projects being implemented'
        
        open(unit=401, file=trim(adjustL(project_list_RR_file)))
        read(401,*) dump_txt            ! dump header
        
        do irr = 1,n_rr
            prj_dem_z = dem_NoDataVal           ! intialize project elevation raster to NoData
            
            read(401,*) ProjectID,prj_xyz_file  ! ProjectID and filepath to XYZ raster
            
            write(  *,'(A,I0,A,A)') '      - building ',ProjectID,' from XYZ file:',prj_xyz_file
            write(000,'(A,I0,A,A)') '      - building ',ProjectID,' from XYZ file:',prj_xyz_file
            
            ! open XYZ file for specific project 
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

            end do
            close(403)
            ! done reading in project DEM
            
            ! update elevation and land type for project footprint
            do i = 1,ndem
                if (prj_dem_z(i) /= dem_NoDataVal) then
                    prj_dz_m = prj_dem_z(i) - dem_z(i)     ! calculate change in pixel elevation due to project
                    dem_dz_cm(i) = prj_dz_m*100.0           ! update dZ raster for project implementation *note that for pixels under a project, the dZ raster will be calculated from the end-of-year raster that already has subsidence and accretion update added for the year
                        
                    if (dem_lndtyp(i) == 2) then            ! if pixel originally water, set land change flag to new land
                        lnd_change_flag(i) = 1
                    end if
                    
                    dem_z(i) = prj_dem_z(i)                 ! set pixel elevation to project elevation
                    dem_lndtyp(i) = 3                       ! set pixel landtype to bare ground/unvegetated wetland

                end if
            end do

        end do    
                
        close(401)
    else
        write(  *,*) '    - no ridge (or levee) projects in this run'
        write(100,*) '    - no ridge (or levee) projects in this run'
    endif
    
    

    
    return
end
