subroutine build_projects
    ! global arrays updated by subroutine:

    !
    ! Subroutine updates the elevation and landtype for pixels
    ! that have a project implemented on the landscape for the year
    !
    ! 
    
    use params
    implicit none
    
    ! local variables
    integer :: i                                                        ! iterator
    integer :: imc                                                      ! iterator
    integer :: c                                                        ! local compartment ID variable
            
    character*fn_len :: prj_xyz_file                                    ! local variable to store filepath to project raster file
    integer :: prj_dem_x                                                ! local variable to store X-coordinates of project DEM
    integer :: prj_dem_y                                                ! local variable to store Y-coordinates of project DEM
    real(sp) :: design_elev                                             ! temporary variable to store the calculated design elevation for marsh creation projects to convert from MWL datum to NAVD88
    real(sp),dimension(:),allocatable :: prj_dem_z                      ! project design elevation of DEM pixel (m NAVD88) - for ridge/levee projects and meters above MWL for marsh creation projects

    
    allocate (prj_dem_z(ndem))
    prj_dem_z = 0
    
    write(  *,*) ' - implementing FWA projects'
    write(000,*) ' - implementing FWA projects'
 
    ! IMPLEMENT MARSH CREATION PROJECTS
    if (n_mc > 0) then
        write(  *,'(A,I,A)') '    - ',n_mc,' marsh creation projects being implemented'
        write(000,'(A,I,A)') '    - ',n_mc,' marsh creation projects being implemented'
        
        open(unit=401, file=trim(adjustL(project_list_MC_file)))
        read(401,*) dump_txt        ! dump header
        
        do imc = 1,n_mc
            prj_dem_z = 0               ! intialize project elevation raster to 0
            design_elev = -9999         ! initialize design elevation to NoData value
            
            read(401,*) prj_xyz_file                                                ! read filepath to XYZ raster
            write(  *,'(A,A)') '      - building from XYZ file:',prj_xyz_file
            write(000,'(A,A)') '      - building from XYZ file:',prj_xyz_file
            
            open(402,  file=trim(adjustL(prj_xyz_file)))                            ! open XYZ file for specific project element
            

            do i = 1,ndem                                                        ! read in project DEM
                read(402,*) prj_dem_x,prj_dem_y,prj_dem_z(i)
                    
                if (prj_dem_x /= dem_x(i)) then                                 ! check that coordinates of project DEM match the initial DEM used by the model - exit if they do not match structure
                    write(  *,'(A,I,A,I)') ' !!! EXITING !!! project XYZ file X value does not match input DEM structure, dem_x = ', dem_x(i), ', prj_dem_x = ', prj_dem_x
                    write(000,'(A,I,A,I)') ' !!! EXITING !!! project XYZ file X value does not match input DEM structure, dem_x = ', dem_x(i), ', prj_dem_x = ', prj_dem_x
                    stop
                end if
                if (prj_dem_y /= dem_y(i)) then
                    write(  *,'(A,I,A,I)') ' !!! EXITING !!! project XYZ file X value does not match input DEM structure, dem_x = ', dem_y(i), ', prj_dem_x = ', prj_dem_y
                    write(000,'(A,I,A,I)') ' !!! EXITING !!! project XYZ file X value does not match input DEM structure, dem_x = ', dem_y(i), ', prj_dem_x = ', prj_dem_y
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
            close(402)
                
            
            do i = 1,ndem

            end do
        
        end do        
        
        close(401)
    else
        write(  *,*) '    - no marsh creation projects in this run'
        write(100,*) '    - no marsh creation projects in this run'
    endif
    
    

    
    return
end
