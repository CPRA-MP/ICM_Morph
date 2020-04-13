subroutine params_alloc
    
    use params
    
    n30 = 1048575
    
    allocate(x(n30))
    allocate(y(n30))
    allocate(z(n30))
    
    return
    
end