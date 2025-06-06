subroutine map_forested
    ! global arrays updated by subroutine:
    !      dem_lndtyp
    !      dem_for_flag
    !
    ! Subroutine that maps forested areas to the highst elevated land pixels within each ICM-LAVegMod grid cell
    ! This algorithm is run before the inundation thresholds, so that mapped forested areas will not be subjected to inundation thresholds.
    ! Those are elevation-based criteria, so they do not need to have an elevation assigned.
    !
    !
    !
    !
    ! *************************
    ! *
    ! * This subroutine could be optimized by putting a sort algorithm (e.g., heapsort, mergesort, etc.) in the maximum elevation
    ! * check. Currently, each grid cell has an array with a list of pixel index values and an array with the respective elevation.
    ! * These elevation arrays are used to find the maxval elevation of each array on a series of loops.
    ! * The array is looped over to find maxval for the number bareground pixels in the grid cell.
    ! * Once an elevation has been identified as a maxval on one loop, that pixel index is cataloged, and then the temporary elevation in the 
    ! * grid array is set to a min value that will not be identified as the maxval in subsequent loops.
    ! * While this works, the array size never gets smaller as maxvals are identified, they are just re-set to default low values.
    ! * A smarter sort algorithm could reduce the array as maxvals are cataloged and ultimately reduce the number of iterations.
    ! * Regardless, these loops are set to stop as soon as enough pixels have been identified to meet the number required 
    ! * as defined by the percent forested values in the grid cell. 
    ! * 
    ! * Also, the loops are never entered if a grid cell does not have any forested to start with.
    ! *
    ! *************************
    

    use params
    implicit none
    
    ! local variables
    integer :: i                                                                    ! iterator
    integer :: gi                                                                   ! iterator
    integer :: bg                                                                   ! iterator
    integer :: gin                                                                  ! iterator
    integer ::gc                                                                    ! counter that is updated to track index of land pixels in each grid cell
    integer :: g                                                                    ! local grid ID variable
    integer :: dem_i                                                                ! local DEM pixel index
    real(sp) :: grid_pct_for                                                        ! local value of total percent forested land within grid cell
    integer,dimension(:),allocatable :: grid_lnd_cntr                               ! local array to count number of land pixels per grid cell
    integer,dimension(:,:),allocatable :: grid_lnd_i                                ! local array to store DEM index for land pixels within each grid cell
    real(sp),dimension(:,:),allocatable :: grid_lnd_z                               ! local array to store DEM elevation for land pixels within each grid cell            
    integer :: grid_n_forested                                                      ! local number of pixels of forested wetland in each grid cell (calculated from input percentages)
    
    
    allocate(grid_lnd_cntr(ngrid))
    allocate(grid_lnd_i(ngrid,grid_ndem_mx))
    allocate(grid_lnd_z(ngrid,grid_ndem_mx))
    
   
    write(  *,*) ' - mapping forested pixels within each ICM-LAVegMod grid cell'
    write(000,*) ' - mapping forested pixels within each ICM-LAVegMod grid cell'
    
    dem_for_flag = 0                                                                ! initialize forested flag to 0 (0 = not forested; 1 = forested)
    
    ! first, convert any bare ground in initial lnd_type to vegetated land
    do i = 1,ndem
        if (dem_lndtyp(i) == 3) then
            dem_lndtyp(i) = 1    
        end if
    end do

    grid_lnd_cntr = 0                                                               ! initialize grid counter
    grid_lnd_i =  0!-9999                                                           ! initialize grid pixel index
    grid_lnd_z = -9999                                                              ! initialize elev array to -9999 so NoData z is always smaller

    ! loop through vegetated land pixels and append DEM index and elevation to an array for each grid cell that will be looped over
    do i = 1,ndem
        g = dem_grid(i)
        if (g /= dem_NoDataVal) then
            gc = grid_lnd_cntr(g)
            if (dem_lndtyp(i) == 1) then
                grid_lnd_cntr(g) = min(gc + 1,grid_ndem_mx)                         ! determine array location for grid cell to append index and elevation to
                grid_lnd_i(g,gc+1) = i                                              ! populate array with DEM pixel index for all vegetated wetland pixels in grid cell
                grid_lnd_z(g,gc+1) = dem_z(i)                                       ! populate array with DEM pixel elevation for all vegetated wetland pixels in grid cell
            end if
        end if
    end do
    
    
    
    ! Map forested pixels to highest elevation vegetated wetland pixels in each grid cell.
    ! Loop is only entered if the cell has forested area located in it.
    ! Loop will stop once all forested area in grid cell has been assigned an elevation and location.
    ! Elevation array is same size for every loop and the maxval function operates on the entire array, 
    ! even if pixel's elevation has already been id'd as a maximum, the array is not truncated, rather
    ! the elevation is re-set to a low value so it won't be flagged as the maximum more than once.
    ! This could be optimized with a sorting function (e.g., heapsort) instead of this default low re-set.
    
    
    
    do gi = 1,ngrid                                                                 ! loop over grid cells
        grid_pct_for = grid_pct_vglnd_BLHF(gi) + grid_pct_vglnd_SWF(gi)             ! total percent forest coverage in grid ecell
        if (grid_pct_for > 0.0) then                                                ! if there is non-zero forested coverage percent in grid cell
            grid_n_forested = int(grid_pct_for*grid_ndem_all(gi))                   ! set number of pixels in grid that are forested from percentage
            do bg = 1,grid_n_forested                                               ! loop over the number of forested pixels in grid cell               
                do gin = 1, grid_lnd_cntr(gi)                                       ! loop over all land pixels in grid cell 
                    if (grid_lnd_z(gi,gin) == maxval(grid_lnd_z(gi,:))) then        ! find the pixel with highest elevation
                        grid_lnd_z(gi,gin) = -9999                                  ! set current elevation to negative NoData so it won't be a maxval in next loop
                        dem_i = grid_lnd_i(gi,gin)                                  ! find DEM pixel index for highest land pixel
                        dem_for_flag(dem_i) = 1                                     ! set bareground flag for pixel to old bareground (1)
                    end if
                end do
            end do
        end if
    end do
        
    return

end