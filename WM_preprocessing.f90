subroutine preprocessing
    
    use params
    implicit none
    
    integer :: i        ! iterator
    real(sp) :: dump    ! variable to read unused data into
    
    ! read xyz file into arrays
    ! 1st column of xyz is x (integer)
    ! 2nd column is y (integer)
    ! 3rd column is z (single precision variable)
    ! 4th column is ICM Hydro compartment (integer)
    
    open(unit=111, file='.\data\xyzc_1.csv')
    read(111,*) skip_header
    do i = 1,n30
        read(111,*) g30_x(i), g30_y(i), g30_z(i), g30_comp(i)
    end do
    
    close(111)
    
    write(*,*)
    write(*,*) '...check memory usage now'
    pause
    
    
    ! read ICM-Hydro compartment output file into arrays
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
        write(*,*) i
    end do
    
    return

end