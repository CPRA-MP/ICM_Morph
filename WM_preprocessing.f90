subroutine preprocessing
    
    use params
    implicit none
    
    ! local variables
    integer :: i        ! iterator
    real(sp) :: dump    ! variable to read unused data into
    
    ! read xyz file into arrays
        ! 1st column of xyz is x (integer)
        ! 2nd column is y (integer)
        ! 3rd column is z (single precision variable)
        ! 4th column is ICM Hydro compartment (integer)
    
    write(  *,*) ' - reading in DEM data for: ','xyzc_1'
    write(000,*) ' - reading in DEM data for: ','xyzc_1'
    
    open(unit=111, file='.\data\xyzc_1.csv')
    read(111,*) skip_header
    do i = 1,ndem
        read(111,*) dem_x(i), dem_y(i), dem_z(i), dem_comp(i)
    end do
    
    close(111)

    
    ! read ICM-Hydro compartment output file into arrays
    
    write(  *,*) ' - reading in ICM-Hydro compartment-level output'
    write(000,*) ' - reading in ICM-Hydro compartment-level output'
        
    open(unit=112, file='.\hydro\compartment_out.csv')
    read(112,*) skip_header
    do i = 1,ncomp
        read(112,*) dump,                   &
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
    return

end