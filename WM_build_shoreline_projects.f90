subroutine build_shoreline_projects
    ! global arrays updated by subroutine:

    !
    ! Subroutine updates the marsh edge erosion rate for shoreline protection
    ! and bank stabilization projects implemented on the landscape for the year and all previous years
    !
    ! 
    
    use params
    implicit none
    
    ! local variables
    integer :: i                                                        ! iterator
    integer :: ibs                                                      ! iterator
            
    character*fn_len :: prj_xyz_file                                    ! local variable to store filepath to project raster file
    integer :: ProjectID                                                ! local variable to store ProjectID integer
    integer :: prj_dem_x                                                ! local variable to store X-coordinates of project DEM
    integer :: prj_dem_y                                                ! local variable to store Y-coordinates of project DEM
    real(sp),dimension(:),allocatable :: prj_dem_meem                   ! project multiplier on marsh edge erosion 
    
    
    allocate (prj_dem_meem(ndem))
    prj_dem_meem = 1.0                                                  ! intialize project elevation raster to NoData
    
    write(  *,*) ' - implementing shoreline protection/bank stabilization projects'
    write(000,*) ' - implementing shoreline protection/bank stabilization projects'

    if (n_bs > 0) then
        write(  *,'(A,I0,A)') '    - ',n_bs,' shoreline protection projects being implemented'
        write(000,'(A,I0,A)') '    - ',n_bs,' shoreline protection projects being implemented'
        
        open(unit=401, file=trim(adjustL(project_list_BS_file)))
        read(401,*) dump_txt            ! dump header
        
        do ibs = 1,n_bs
            prj_dem_meem = 1.0           ! intialize project MEE multiplier raster to 1.0
            
            read(401,*) ProjectID,prj_xyz_file  ! ProjectID and filepath to XYZ raster
            
            write(  *,'(A,I0,A,A)') '      - building ',ProjectID,' from XYZ file:',trim(adjustL(prj_xyz_file))
            write(000,'(A,I0,A,A)') '      - building ',ProjectID,' from XYZ file:',trim(adjustL(prj_xyz_file))
            
            ! open XYZ file for specific project 
            open(403,  file=trim(adjustL('geomorph/input/'//prj_xyz_file)))
            
            ! read in project DEM
            do i = 1,ndem
                read(403,*) prj_dem_x,prj_dem_y,prj_dem_meem(i)
                
                ! check that coordinates of project raster match the initial DEM used by the model - exit if they do not match structure
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
            ! done reading in project raster
            
            ! update marsh edge erosion rate
            do i = 1,ndem
                if (prj_dem_meem(i) /= dem_NoDataVal) then
                    dem_meer(i) = prj_dem_meem(i)*dem_meer(i)
                end if
            end do
        end do    
                
        close(401)
    else
        write(  *,*) '    - no shoreline protection projects in this run'
        write(100,*) '    - no shoreline protection projects in this run'
    endif
    
    

    
    return
end
