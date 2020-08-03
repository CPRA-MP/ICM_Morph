subroutine write_output
    ! subroutine that writes output files
    

    use params
    implicit none
    
    ! local variables
    integer :: i                                                    ! iterator
 
    ! write end-of-year grid summary file
    open(unit=900, file=grid_summary_eoy_file)
    write(  *,*) " - writing end-of-year grid summary file"
    write(000,*) " - writing end-of-year grid summary file"
    
    write(900,*) 'gridID,pct_water,pct_flotant,pct_land_veg,pct_land_bare,pct_land_upland_dry,pct_land_upland_wet,pct_vglnd_BLHF,pct_vglnd_SWF,pct_vglnd_FM,pct_vglnd_IM,pct_vglnd_BM,pct_vglnd_SM,FIBS_score'
    do i = 1,ngrid
        write(900,1111) i,                          &
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
    end do
    
1111    format(I0,12(',',F0.4),',',F0.2)
        
        
    return

end