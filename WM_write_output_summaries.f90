subroutine write_output_summaries
    ! subroutine that writes output files
    

    use params
    implicit none
    
    ! local variables
    integer :: i                                                    ! iterator

! write end-of-year grid summary file    
    write(  *,*) ' - writing end-of-year grid summary files'
    write(000,*) ' - writing end-of-year grid summary files'
    

    open(unit=903, file = trim(adjustL(grid_depth_file_Gdw) ))
    
    ! write headers
    write(903,'(A)') 'GRID_ID,VALUE_0,VALUE_4,VALUE_8,VALUE_12,VALUE_18,VALUE_22,VALUE_28,VALUE_32,VALUE_36,VALUE_40,VALUE_44,VALUE_78,VALUE_150,VALUE_151'
 
    do i = 1,ngrid
        
        write(903,1903) i,                          &
   &                grid_gadwl_dep(i,1),            &
   &                grid_gadwl_dep(i,2),            &
   &                grid_gadwl_dep(i,3),            &
   &                grid_gadwl_dep(i,4),            &
   &                grid_gadwl_dep(i,5),            &
   &                grid_gadwl_dep(i,6),            &
   &                grid_gadwl_dep(i,7),            &
   &                grid_gadwl_dep(i,8),            &
   &                grid_gadwl_dep(i,9),            &
   &                grid_gadwl_dep(i,10),           &
   &                grid_gadwl_dep(i,11),           &
   &                grid_gadwl_dep(i,12),           &
   &                grid_gadwl_dep(i,13),           &
   &                grid_gadwl_dep(i,14)
    end do
    
    close(903)
 
    
1900    format(I0,',',I0,19(',',F0.4),',',F0.2)
1901    format(I0,2(',',F0.4),3(',',F0.2))
1902    format(I0,',',F0.2)  
1903    format(I0,14(',',I0))
1904    format(I0,9(',',I0))
1906    format(I0,2(',',F0.4),',',I0)
1907    format(I0,',',F0.4)  
1909    format(2(A,','),I,',',2(A,','),I)
    
    
        
        
    return

end
