subroutine params_alloc
    
    use params
    
    n30 = 1048575
    
    allocate(g30_x(n30))
    allocate(g30_y(n30))
    allocate(g30_z(n30))
    allocate(g30_comp(n30))
    
    return
    
end