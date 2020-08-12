subroutine summaries
    ! subroutine that summarizes landscape per model grids
    

    use params
    implicit none
    
    ! local variables
    integer :: i                                                    ! iterator
    integer :: c                                                    ! local compartment ID variable
    integer :: g                                                    ! local grid ID variable
   
    do i = 1,ndem
        
        g = dem_grid(i)
        c = dem_comp(i)
        
!        dem_lndtyp(i)
!        dem_z(i)

        

!        
!        grid_pct_water(g)
!        grid_pct_flt(g)
!        grid_pct_bare(g)
!        grid_pct_upland_dry(g)
!        grid_pct_upland_wet(g)
!        grid_bed_z(g)
!        grid_land_z(g)
!
!        grid_pct_edge(g)
!          
!
!        comp_water_z(c)
!        comp_wetland_z(c)
!        comp_edge_area(c)
!        comp_pct_water(c)
!        comp_pct_upland(c)
    
    end do
    
    grid_pct_vg_land = 1.0 - grid_pct_water - grid_pct_bare - grid_pct_upland - grid_pct_flt
    
    return

end