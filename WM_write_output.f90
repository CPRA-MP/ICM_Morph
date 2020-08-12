subroutine write_output
    ! subroutine that writes output files
    

    use params
    implicit none
    
    ! local variables
    integer :: i                                                    ! iterator
    real(sp) :: grid_pct_land_tot                                   ! calculation for output files
    real(sp) :: grid_pct_land_wetl                                  ! calculation for output files
    
    ! write end-of-year grid summary file    
    write(  *,*) " - writing end-of-year grid summary files"
    write(000,*) " - writing end-of-year grid summary files"
    
    open(unit=900, file = trim(adjustL(grid_summary_eoy_file) ))
    open(unit=901, file = trim(adjustL(grid_data_file) ))
    open(unit=902, file = trim(adjustL(grid_pct_edge_file) ))
    open(unit=903, file = trim(adjustL(grid_depth_file_Gdw) ))
    open(unit=904, file = trim(adjustL(grid_depth_file_GwT) ))
    open(unit=905, file = trim(adjustL(grid_depth_file_MtD) ))
    
    
    ! write headers
    write(900,*) 'gridID,pct_water,pct_flotant,pct_land_veg,pct_land_bare,pct_land_upland_dry,pct_land_upland_wet,pct_vglnd_BLHF,pct_vglnd_SWF,pct_vglnd_FM,pct_vglnd_IM,pct_vglnd_BM,pct_vglnd_SM,FIBS_score'
    write(901,*) 'GRID,MEAN_BED_ELEV,MEAN_LAND_ELEV,PERCENT_LAND,PERCENT_WETLAND,PERCENT_WATER'
    write(902,*) 'GRID,PERCENT_EDGE'
    write(903,*) 'GRID_ID,VALUE_0,VALUE_4,VALUE_8,VALUE_12,VALUE_18,VALUE_22,VALUE_28,VALUE_32,VALUE_36,VALUE_40,VALUE_44,VALUE_78,VALUE_150,VALUE_151'
    write(904,*) 'GRID_ID,VALUE_0,VALUE_6,VALUE_18,VALUE_22,VALUE_26,VALUE_30,VALUE_34,VALUE_100,VALUE_101'
    write(905,*) 'GRID_ID,VALUE_0,VALUE_8,VALUE_30,VALUE_36,VALUE_42,VALUE_46,VALUE_50,VALUE_56,VALUE_57'
    
    do i = 1,ngrid
        grid_pct_land_tot = 100.0 - grid_pct_water(i)
        grid_pct_land_wetl =  grid_pct_flt(i) + grid_pct_vg_land(i) + grid_pct_bare(i)
        
        write(900,1900) i,                          &
   &                grid_pct_water(i),              &
   &                grid_pct_flt(i),                &
   &                grid_pct_vg_land(i),            &
   &                grid_pct_bare(i),               &
   &                grid_pct_upland_dry(i),         &
   &                grid_pct_upland_wet(i),         &
   &                grid_pct_vglnd_BLHF(i),         &
   &                grid_pct_vglnd_SWF(i),          &
   &                grid_pct_vglnd_FM(i),           &
   &                grid_pct_vglnd_IM(i),           &
   &                grid_pct_vglnd_BM(i),           &
   &                grid_pct_vglnd_SM(i),           &
   &                grid_FIBS_score(i)
        
        write(901,1901) i,                          &
   &                grid_bed_z(i),                  &
   &                grid_land_z(i),                 &
   &                grid_pct_land_tot,              &
   &                grid_pct_land_wetl,             &
   &                grid_pct_water(i)
    
        write(902,1902) i,grid_pct_edge(i)
        
        write(903,1903) i,                          &
   &        grid_gadwl_dep(i,1),                    &
   &        grid_gadwl_dep(i,2),                    &
   &        grid_gadwl_dep(i,3),                    &
   &        grid_gadwl_dep(i,4),                    &
   &        grid_gadwl_dep(i,5),                    &
   &        grid_gadwl_dep(i,6),                    &
   &        grid_gadwl_dep(i,7),                    &
   &        grid_gadwl_dep(i,8),                    &
   &        grid_gadwl_dep(i,9),                    &
   &        grid_gadwl_dep(i,10),                   &
   &        grid_gadwl_dep(i,11),                   &
   &        grid_gadwl_dep(i,12),                   &
   &        grid_gadwl_dep(i,13),                   &
   &        grid_gadwl_dep(i,14)
        
        write(904,1904) i,                          &
   &        grid_gwteal_dep(i,1),                   &
   &        grid_gwteal_dep(i,2),                   &
   &        grid_gwteal_dep(i,3),                   &
   &        grid_gwteal_dep(i,4),                   &
   &        grid_gwteal_dep(i,5),                   &
   &        grid_gwteal_dep(i,6),                   &
   &        grid_gwteal_dep(i,7),                   &
   &        grid_gwteal_dep(i,8),                   &
   &        grid_gwteal_dep(i,9)
        
        write(905,1904) i,                          &
   &        grid_motduck_dep(i,1),                  &
   &        grid_motduck_dep(i,2),                  &
   &        grid_motduck_dep(i,3),                  &
   &        grid_motduck_dep(i,4),                  &
   &        grid_motduck_dep(i,5),                  &
   &        grid_motduck_dep(i,6),                  &
   &        grid_motduck_dep(i,7),                  &
   &        grid_motduck_dep(i,8),                  &
   &        grid_motduck_dep(i,9)
    
    end do
    
    close(900)
    close(901)
    close(902)
    close(903)
    close(904)
    close(905)

    ! write end-of-year ICM-Hydro compartment elevation data file    
    write(  *,*) " - writing end-of-year compartment data files"
    write(000,*) " - writing end-of-year compartment data files"
    
    open(unit=906, file = trim(adjustL(comp_elev_file) ))
    open(unit=907, file = trim(adjustL(comp_wat_file) ))
    open(unit=908, file = trim(adjustL(comp_upl_file) ))
    
    ! write headers
    write(906,*) 'ICM_ID,MEAN_BED_ELEV,MEAN_MARSH_ELEV,MARSH_EDGE_AREA'
    !write(907,*) 'there is no header for this file'
    !write(908,*) 'there is no header for this file'
    
    do i = 1,ncomp
        write(906,1906) i,comp_water_z(i),comp_wetland_z(i),comp_edge_area(i)
        write(907,1907) i,comp_pct_water(i)/100.0      ! comparment data files format % from 0-1
        write(908,1907) i,comp_pct_upland(i)/100.0     ! comparment data files format % from 0-1
    end do
    
    close(906)
    close(907)
    close(908)    
    
    
    
1900    format(I0,12(',',F0.4),',',F0.2)
1901    format(I0,2(',',F0.4),2(',',F0.2))
1902    format(I0,',',F0.2)  
1903    format(I0,14(',',I0))
1904    format(I0,9(',',I0))
1906    format(I0,2(',',F0.4),',',I0)
1907    format(I0,',',F0.4)  
    
    
        
        
    return

end