import arcpy, sys, os, time, math, string, datetime
from arcpy import env
from arcpy.sa import *
import numpy as np
import csv

arcpy.CheckOutExtension("Spatial")
arcpy.CheckOutExtension("3D")
env.overwriteOutput = True
env.pyramid = "NONE"

def CreateWorkSpaces(parentFolder, tempFolder, tempGDBName, intermediateFolder, intermediateGDBName, deliverableFolder):
    ##PURPOSE: creates the folder structure and geodatabases to hold derived data (temp, intermediate, final)
    try:
        msg0 = "CREATING WORKSPACES"
        print msg0
#        arcpy.AddMessage(msg0)
        s = time.clock()
        
        if arcpy.Exists(parentFolder):
            arcpy.Delete_management(parentFolder)
            
        # check if temp workspace exists...
        if not arcpy.Exists(parentFolder):
            # create folder if it doesn't exist...
            os.makedirs(parentFolder) 
            tempFolder = r"%s\\%s" % (parentFolder, tempFolder)
            os.makedirs(tempFolder)
            intermediateFolder = r"%s\\%s" % (parentFolder, intermediateFolder)
            os.makedirs(intermediateFolder)
            deliverableFolder = r"%s\\%s" % (parentFolder, deliverableFolder)
            os.makedirs(deliverableFolder)
            
        # create the GDBs
        arcpy.CreateFileGDB_management(tempFolder, tempGDBName)
        arcpy.CreateFileGDB_management(intermediateFolder, intermediateGDBName)

        e = time.clock()
        ProcTimeMin = round((e-s)/60,2)
        msg0 = "--workspace generation runtime: %s minutes\n" % (ProcTimeMin)
        print msg0
#        arcpy.AddMessage(msg0)
        
    except Exception, e:
        # If an error occurred, print line number and error message
        import traceback, sys
        tb = sys.exc_info()[2]
        msg1 = "Line %i" % tb.tb_lineno
        msg2 = e.message
#        arcpy.AddWarning(msg1)
#        arcpy.AddWarning(msg2)
        print msg1
        print msg2
        print "UNABLE TO DELETE TEMPORARY DATA FOLDER: '%s'" % parentFolder
#        arcpy.AddWarning("UNABLE TO CREATE TEMPORARY DATA FOLDER: '%s'" % parentFolder)
        return()

def ImportEcohydroResults(CurrentYear,ecohydro_dir,EHtemp_path,Ecohydro_table_grid,Ecohydro_table_gridID_Field,Ecohydro_table_compartment,Ecohydro_table_compartmentID_Field,GridPoly,GridPolyID_Field,CompartmentPoly,CompartmentPolyID_Field):
    ##PURPOSE: imports results from Ecohydro Model and generate spatial coverages of the data
    try:
        s = time.clock()
        arcpy.env.workspace = Intermediate_Files_GDB
        arcpy.env.scratchWorkspace = Temp_Files_Path
        arcpy.env.scratchFolder
        arcpy.env.scratchGDB
        
                
        print "\nIMPORTING HYDROLOGY MODEL RESULTS FOR %s" % CurrentYear
        # Import Ecohydro results into geodatabase
        print "--importing Ecohydro Model output tables into temporary working geodatabase"

        
        Ecohydro_path_table_grid = os.path.normpath(EHtemp_path + '\\' + Ecohydro_table_grid)
        arcpy.TableToGeodatabase_conversion(Ecohydro_path_table_grid, Intermediate_Files_GDB)
        
        Ecohydro_path_table_poly = os.path.normpath(EHtemp_path + '\\' + Ecohydro_table_compartment)
        arcpy.TableToGeodatabase_conversion(Ecohydro_path_table_poly, Intermediate_Files_GDB)

        # copy polygons for grid and compartments to Intermediate Files Geodatabase
        print "--creating working copy of Ecohydro compartment and grid shapefiles"
        arcpy.env.workspace = Input_GDB
                
        new_grid_poly = Intermediate_Files_GDB + '\\' + GridPoly
        arcpy.CopyFeatures_management(GridPoly,new_grid_poly)
        
        new_comp_poly = Intermediate_Files_GDB + '\\' + CompartmentPoly
        arcpy.CopyFeatures_management(CompartmentPoly,new_comp_poly)

        arcpy.env.workspace = Intermediate_Files_GDB
        
        print "--joining Hydro Model output to 500m grid polygons"
        inFeatures = GridPoly
        inField = GridPolyID_Field 
        joinTable = str.split(Ecohydro_table_grid,'.')[0]
        joinField = Ecohydro_table_gridID_Field
        # field_list MUST match the headers written to 'grid_output_500m.out' written by the Ecohydro Fortran code (end of main.f subroutine)
        field_list = ['compartment_ave_salinity_ppt','IDW_ave_salinity_ppt','compartment_ave_summer_salinity_ppt','IDW_ave_summer_salinity_ppt','compartment_max_2wk_summer_salinity_ppt','IDW_max_2wk_summer_salinity_ppt','bed_pct_sand','compartment_ave_temp','IDW_ave_temp','compartment_ave_summer_temp','IDW_ave_summer_temp','stage_ave','stage_summer_ave','var_stage_summer','ave_depth_summer','ave_depth']
        try:
            arcpy.JoinField_management(inFeatures,inField,joinTable,joinField,field_list)
        except:
            print ' *****ERROR**** Join failed - retrying.'
            arcpy.JoinField_management(inFeatures,inField,joinTable,joinField,field_list)
        
        print "--joining Hydro Model output to hydro compartment polygons"
        inFeatures2 =  CompartmentPoly
        inField2 =  CompartmentPolyID_Field 
        joinTable2 = str.split(Ecohydro_table_compartment,'.')[0]
        joinField2 = Ecohydro_table_compartmentID_Field
        field_list2 = ['max_annual_stage','ave_annual_stage','ave_stage_summer','var_stage_summer','ave_annual_salinity','ave_salinity_summer','sal_2wk_max','ave_tmp','ave_tmp_summer','openwater_sed_accum','marsh_int_sed_accum','marsh_edge_sed_accum','tidal_prism_ave','ave_sepmar_stage','ave_octapr_stage','marsh_edge_erosion_rate','ave_annual_tss','stdev_annual_tss','totalland_m2']
        # field_list2 MUST match the headers written to 'compartment_ICMoutput.out' written by the Ecohydro Fortran code (end of main.f subroutine)
        try:
            arcpy.JoinField_management(inFeatures2,inField2,joinTable2,joinField2,field_list2)
        except:
            print ' *****ERROR**** Join failed - retrying.'
            arcpy.JoinField_management(inFeatures2,inField2,joinTable2,joinField2,field_list2)
            
        e = time.clock()
        ProcTimeMin = round((e-s)/60,2)
        msg0 = "--Hydro import runtime: %s minutes" % (ProcTimeMin)
        msg1 = "COMPLETED IMPORTING HYDROLOGY MODEL RESULTS."
        print msg0
        print msg1

        
    except Exception, e:
        # If an error occurred, print line number and error message
        import traceback, sys
        tb = sys.exc_info()[2]
        msg1 = "Line %i" % tb.tb_lineno
        msg2 = e.message
#        arcpy.AddWarning(msg1)
#        arcpy.AddWarning(msg2)
        print msg1
        print msg2
        print "UNABLE TO IMPORT AND JOIN HYDRO MODEL RESULTS"
        return()


def ImportVegResults(CurrentYear,vegetation_dir,veg_output_file,veg_deadfloat_file,veg_ascii_grid,VegLULC_lookup,n500grid,nrows,ncols,veg_ascii_header,nvegtype,InitCond_proj,CurrentLW,NoUpdateMask,elapsedyear,StartingLULC):
    try:
        s = time.clock()
        
        print "\nIMPORTING VEGETATION MODEL RESULTS FOR %s" % CurrentYear
        # Import Vegetation results into new LULC raster in geodatabase

        arcpy.env.workspace = InitCond_GDB
        arcpy.env.scratchWorkspace = Temp_Files_Path
        arcpy.env.scratchFolder
        arcpy.env.scratchGDB
        
        # read in Veg output file for ICM year
        # read in first column of Veg output file - skip first 362 rows
        veg_results_file = os.path.normpath(vegetation_dir + '\\' + veg_output_file)
        veg_grid_ascii_file = os.path.normpath(vegetation_dir + '\\' + veg_ascii_grid)
        
        print "--reading in Vegetation Model output file"
        
        # skipvalue is the number of rows contained in the header and the grid array located at the start of the Veg output file
        skipvalue = nrows + 7
        vegcolumns = nvegtype + 1   #veg columns is the number of vegetation types modeled plus one for the grid ID column
        
        new_veg = np.zeros((n500grid,vegcolumns))
        veg_missing = 0
        
        # open Vegetation output file
        with open(veg_results_file,'r') as vegfile:
        
        # skip ASCII header rows and ASCII grid at start of output file
            for n in range(0,skipvalue-1):
                dump=vegfile.readline()
        
        # read in header of Vegetation output at bottom of ASCII grid    
            vegtypenames = vegfile.readline().split(',')

        # remove any leading or trailing spaces in veg types
            for n in range(0,len(vegtypenames)):
                vegtypenames[n] = vegtypenames[n].lstrip().rstrip()
        
        # loop through rest of Vegetation file    
            for nn in range(0,n500grid):
        
        # split each line of file based on ", " delimiter
                vline = vegfile.readline().split(", ")
        
        # if all columns have data in output file, assign veg output to veg_ratios array
                if (len(vline) == vegcolumns):
                    for nnn in range(0,len(vline)):
                            new_veg[nn,nnn]=float(vline[nnn].lstrip().rstrip())
        # if there are missing columns in line, set first column equal to grid cell, and set all other columns equal to 0.
                else:
                    for nnn in range(1,vegcolumns):
                        new_veg[nn,0]=nn+1
                        new_veg[nn,nnn] = 0.0
                    veg_missing += 1
        
        if (veg_missing > 0):
            print  '  **some Vegetation output was not written correctly to Veg output file.'
            print  '       %s 500m grid cells did not have complete results in Veg Output file.' % veg_missing
            print  '       the species coverages for these cells were all set to zero and will be classified as WATER.'
        
        print "--reclassifying Vegetation Model output into LULC types"
        
        ## LULC codes used by morph model
        ## LULC 1 = Fresh Forested
        ## LULC 2 = Fresh Herbaceous
        ## LULC 3 = Intermediate Herbaceous
        ## LULC 4 = Brackish Herbaceous
        ## LULC 5 = Salt Herbaceous
        ## LULC 6 = Water
        ## LULC 7 = Upland
        ## LULC 8 = Floatant
        ## LULC 9 = Bare Ground
        
#        LULCnonwater = [1,2,3,4,5,7]
        LULCall = [1,2,3,4,5,6,7,8,9]
        # generate array of zeroes that is the number of grid cells by the number of LULC types - to be used to save the reclassed LULC area for each grid cell
               
        # generate empty dictionary which will save max LULC type for each grid cell (key is gridID imported into new_veg column 0)
        newLULCdict={}

        for n in range(0,len(new_veg)):            
            # make blank list for accumulating reclassed coverage percentages
#            newLULC_water = 0
#            newLULC_nonwater=[0,0,0,0,0,0]                  # size of this list must equal LULCnonwater list initialized above
            newLULC = [0,0,0,0,0,0,0,0,0] 						# size of this list must equal LULCall list initialized above
            # loop through Veg Types modeled - use dictionary keys instead of columns in case Veg output column orders ever change
            for k in VegLULC_lookup.keys():                 # k is veg type as dictionary key in VegLULC_lookup
                vc = vegtypenames.index(k)                  # vc is column in new_veg array that matches veg type, k
                nlulc = int(VegLULC_lookup[k])              # nlulc is new LULC number to assign veg type,k
                nlin = LULCall.index(nlulc)             # determine which location in list to add Veg species percent cover to
                newLULC[nlin] += new_veg[n,vc]        # add percentage species coverage to appropriate LULC location in newLULC list
            
            # determine LULC with largest coverage for grid cell
            maxLU = max(newLULC)
            maxLU_index = newLULC.index(maxLU)
            
            # check if max LULC is upland - only use if area is more than 75% of cell
            # if Bare Ground and Upland are greater than 99%, set to upland
            if (newLULC[8] + newLULC[6]) >= 0.99:
                maxLU_index = 6
            # otherwise determine largest non-upland new LULC
            else:
                maxLU = max(newLULC[0],newLULC[1],newLULC[2],newLULC[3],newLULC[4],newLULC[5],newLULC[7])
                if maxLU > 0.0:
                    maxLU_index = newLULC.index(maxLU)
                else:
                    maxLU_index = 6

            # check if max LULC is water
            if maxLU_index == 5:  # water is the 5th index in newLULC
            # if water, only set new LULC to water if 99.9999% of cell is water
                if newLULC[5] >= 0.999999:
                    maxLU_index = 5    
           # otherwise determine largest non-water, non-upland new LULC
                else:                        
                    maxLU = max(newLULC[0],newLULC[1],newLULC[2],newLULC[3],newLULC[4],newLULC[7])
                    if maxLU > 0.0:
                # Calculate index of non water max land type
                        maxLU_index = newLULC.index(maxLU)
                # if cell is all zeros AND not classified as water, total area is not calculated correctly - convert to upland LULC (so as to not overly estimate land loss by treating as water)
                    else:
                        maxLU_index = 6


            # update new LULC for grid cell to maximum LULC
            newLULCdict[new_veg[n,0]] = LULCall[maxLU_index] # update new LULC dictionary - key is grid ID from new_veg array, value is LULC value of maxLU

        print '--reading in Vegetation Model ASCII grid.'
        # map new max LULC values for each gridID to the grid file format used in ASCII rasters (same format as Veg input files)
        Veg_grid_lookup=np.genfromtxt(veg_grid_ascii_file,delimiter=' ',skiprows=6)
        
        print '--mapping reclassified Vegetation Model output to ASCII grid'
        # prepare zero array in same shape of original Veg output ASCII grid
        newLULCgrid=np.zeros([nrows,ncols])
                        
        # loop through zeros grid and lookup CELLID - reassign to the new LULC value - if nodata - keep as nodata - if missing classify as water (LULC=6)
        keyerrflag = 0
        for m in range(0,nrows):
            for n in range(0,ncols):
                cellID = Veg_grid_lookup[m][n]
                if cellID == -9999:
                    newLULCgrid[m][n] = -9999
                else:
                    try: 
                        newLULCgrid[m][n] = newLULCdict[cellID]
                    except:   # if cellID is not a key in the newLULCdictionay - assign cell to NoData
                        newLULCgrid[m][n] = -9999
                        keyerrflag += 1
                     
        if keyerrflag > 0:
            nodataArea = keyerrflag*0.5*0.5 # total area converted to NoData (500x500 m -> sq km)
            print '-- ********ERROR**********'
            print '--GridIDs in %s do not match GridIDs printed to the Vegetation output file: %s' % (veg_grid_ascii_file,veg_results_file)
            print '--%s cells did not have Veg output and were converted to NoData.' % keyerrflag
            print '--Total change in LULC area as a result of these new NoData cells: %s sq. km' % nodataArea
    
            print "--saving new LULC raster at 500-m resolution"
        # save formatted LULC grid to ascii file with appropriate ASCII raster header
        newLULC_asc = r'%s\\%svLULC.asc' % (Temp_Files_Path,nprefix)
        np.savetxt(newLULC_asc,newLULCgrid,fmt='%i',delimiter=' ',header=veg_ascii_header,comments='')
        
        # convert ascii grid to raster and save in initial conditions GDB
        NewLULC500 = '%s\\vg500' % (Temp_Files_GDB) 
        arcpy.ASCIIToRaster_conversion(newLULC_asc,NewLULC500,'INTEGER')
        
        # define projection of new LULC raster
        arcpy.DefineProjection_management(NewLULC500,InitCond_proj)
        
        print "--resampling 500-m LULC raster to 30-m resolution"
        NewLULC = r'%s\\%svg030' % (Temp_Files_GDB,nprefix) 
        
        # resample 500-m LULC raster to the 30-m resolution used by the rest of the morphology routines
        arcpy.Resample_management(NewLULC500,NewLULC,"30","NEAREST")
                
        # reclassify 30-m veg output LULC for areas that are considered water in the current LandWater Raster
        print "--updating reclassed 30-m version of Veg Output to incorporate 30-m Land/Water and developed areas data"
        
        rLW = Raster(CurrentLW)
        rNewLULC = Raster(NewLULC)

        #rLULC_LW = Con((rLW == 2),6,7)
        
        # NoUpdateMask is a mask that sets the LULC to Upland/Developed, regardless of Veg output
        rNoUpdate = Raster(NoUpdateMask)
        rLULC_LW = Con((rLW == 2),6,Con((rLW == 5), 8, Con((rNoUpdate == 1), 7, rNewLULC)))

        NewLULC_wat= r"%s\\%s" % (InitCond_GDB,StartingLULC)
        NewLW_veg = CurrentLW
                
        #import dead floatant marsh data from Veg output
        print "--importing dead floatant marsh data from Veg Model"
        if veg_deadfloat_file == 'NONE':
            print " --dead floatant marsh output file was not generated for this model year, see Veg input file"
            print " --saving veg output (with 30-m water data) to Initial Conditions GDB"
            rLULC_LW.save(NewLULC_wat)
     
                          
        else:            
            print "--there is a dead floatant marsh output file for this year - importing now"
            print "--saving version of veg output before dead floatant removed (with 30-m water data) in Intermediate GDB"
           
            NewLULC_noDeadF =r"%s\\%svg_before_deadf" % (Intermediate_Files_GDB,nprefix)
            rLULC_LW.save(NewLULC_noDeadF)
            
            veg_results_deadf_file = os.path.normpath(vegetation_dir + '\\' + veg_deadfloat_file)
            
            ascihead = 'ncols         20879\nnrows         8929\nxllcorner     393285\nyllcorner     3164656\ncellsize      30\nNODATA_value  -9999'


            skipvalue = 6
            ncols30 = 20879
            nrows30 = 8929

            vegfilelist = os.listdir(vegetation_dir)
            year_of_fltct_file = 0
            for ff in vegfilelist:
                if ff.endswith('fltct.csv'):
                    year_of_fltct_file = max(year_of_fltct_file,int(ff.split('_')[8]))
            print '--latest year with floatant marsh counts is %d - this file will be used to update dead floatant marsh.' % year_of_fltct_file
                                        
            flt_initial_count = os.path.normpath(vegetation_dir + '\\%s_N_%02d_%02d_V_fltct.csv' % (SG,year_of_fltct_file,year_of_fltct_file))
            flt_updated_count = os.path.normpath(vegetation_dir + '\\%s_N_%02d_%02d_V_fltct.csv' % (SG,elapsedyear,elapsedyear))
            flt_init_gridID_asc = os.path.normpath(vegetation_dir + '\\%s_I_00_00_V_fltID.asc' % SG)
            flt_updated_asc = os.path.normpath(vegetation_dir + '\\%s_N_%02d_%02d_V_fltnt.asc' % (SG,elapsedyear,elapsedyear))
            
            n_float_starting = {}
            n_float_pct_lost = {}
            n_float_remaining = {}
            
            with open(flt_initial_count,mode='rb') as start_float_file:
                lineno = 1
                for line in start_float_file:
                    if lineno > 1:
                        ins = line.split(',')
                        grid = int(ins[0])
                        fl = int(ins[1])
                        n_float_starting[grid] = fl
                    lineno += 1
            

            print '--reading in dead floatant file from Veg model output.'
            veg_results_deadf_file = os.path.normpath(vegetation_dir + '\\' + veg_deadfloat_file)
            with open (veg_results_deadf_file, mode = 'rb') as dead_float:
                lineno = 1
                for line in dead_float:
                    if lineno > skipvalue:
                        row = lineno - 7
                        fline = line.split(' ')
                        for col in range(0,ncols):
                            dead_flt_amt = float(fline[col])
                            grid500ID = Veg_grid_lookup[row][col]
                            n_float_pct_lost[grid500ID] = max(dead_flt_amt,0.0) # if no data, sets -9999 values to 0 #

                    lineno += 1
            
            print '--determining how many 30-m floatant pixels need to be removed within each 500-m Veg grid.'
            with open(flt_updated_count,mode='wb') as outf:
                outf.write('grid,floatant_cells\n')
                for g500 in range(1,n500grid+1):
                    n_float_remaining[g500] = max(int(n_float_starting[g500]*(1-n_float_pct_lost[g500])), 0)
                    outf.write('%d,%d\n' % (g500,n_float_remaining[g500]))
            
            # initialize counter for each 500-m grid cell - this will increase until the amount of floatant marsh required is left.\
            flt_counter = {}
            for g500 in range(1,n500grid+1):
                flt_counter[g500] = 0
            
            new_float = np.zeros([nrows30,ncols30])
            
            # cycle through all 30-m pixels - look up grid cell ID from input asc file, and determine how many 30-m pixels of floatant are required
            # starting at the top left of each 500-m grid - the 30-m pixels with floatant are cycled through and will be set to 1 until the flt_counter reaches the number of floatant pixels that are remaining
            # after this, the original floatant pixel will now be set to 0 - reducing the number of 30-m floatant pixels within each 500-m grid to equal the amount left over after the dead floatant is removed
            print '--building new 30-m ASCII file of updated floatant marsh.'
            with open (flt_init_gridID_asc, mode = 'rb') as float_y0:
                lineno = 1
                for line in float_y0:
                    if lineno > skipvalue:
                        row = lineno - 7
                        fline = line.split(' ')
                        for col in range(0,ncols30):
                            grid = int(fline[col])
                            if grid > 0:
                                flt_counter[grid] += 1
                                if flt_counter[grid] <= n_float_remaining[grid]:
                                    new_float[row][col] = 1
                                else:
                                    new_float[row][col] = 0
                            else:
                                new_float[row][col] = 0
                    lineno += 1
            
            np.savetxt(flt_updated_asc,new_float,delimiter=' ',fmt='%d',header=ascihead,comments='')
            
	    print '--saving new 30-m raster version of updated floatant marsh.'            
            UpdatedFloat = r"%s\\%sflt30" % (Intermediate_Files_GDB,nprefix)
            # save updated floatant as integer raster values of 1 is floatant, values of 0 are not
            arcpy.ASCIIToRaster_conversion(flt_updated_asc,UpdatedFloat,'INTEGER')

            
            rNewF = Raster(UpdatedFloat)
            tempLU = Con(rLW == 5, Con(rNewF == 1,8,6), rLULC_LW)
            
            print "--saving LULC with dead marsh and 30 m water data to Initial Conditions GDB"
            tempLU.save(NewLULC_wat)            
            
            print "--updating LW to incorporate dead floatant marsh areas."
            tempLW = Con(rLW == 5, Con(rNewF == 1, 5, 2), rLW)
            NewLW_veg = r"%s\\%slw_df" % (Intermediate_Files_GDB,nprefix)
            tempLW.save(NewLW_veg)
            
            try:
                del rNewF,tempLW, tempLU
            except:
                print ' Failed to cleanup some temp rasters'


              
        e = time.clock()
        ProcTimeMin = round((e-s)/60,2)
        msg0 = "--Veg import runtime: %s minutes" % (ProcTimeMin)
        msg1 = "COMPLETED IMPORTING VEGETATION MODEL RESULTS"
        print msg0
        print msg1
#        arcpy.AddMessage(msg0)
        return([NewLULC_wat,NewLW_veg])
        
        
    except Exception, e:
        # If an error occurred, print line number and error message
        import traceback, sys
        tb = sys.exc_info()[2]
        msg1 = "Line %i" % tb.tb_lineno
        msg2 = e.message
#        arcpy.AddWarning(msg1)
#        arcpy.AddWarning(msg2)
        print msg1
        print msg2
        print "UNABLE TO IMPORT AND JOIN VEGETATION MODEL RESULTS"
        return()


def UpdateDEM(CurrentTOPO,BMprof_forWMfile,CurrentYear,InitCond_proj):
    ## This routine takes the XYZ profile text files from BIMODE and burns them into the existing topobathy DEM
    ## This will mosaic the new DEM *into* the topobathy DEM saved in the initial conditions gdb
    ## IT WILL NOT SAVE A COPY OF THE INITIAL CONDITONS DEM - it updates the existing raster
    try:
        print "\nINCORPORATING NEW DEM FROM BIMODE"
        arcpy.env.extent = CurrentTOPO

        s = time.clock()

        arcpy.env.workspace = Intermediate_Files_GDB
        arcpy.env.scratchWorkspace = Temp_Files_Path
        arcpy.env.scratchFolder
        arcpy.env.scratchGDB
        
        rTOPO = Raster(CurrentTOPO)
        
        BIMODE_profiles_ASCI = r"%s\\%sBIMODEprofiles" % (Intermediate_Files_GDB,nprefix)
        
        BIMODE_DEM = r"%s\\%sBIMODE_DEM" % (Temp_Files_GDB,nprefix)
        
        BIMODE_DEMclip = r"%s\\%sBIMODE_DEM_clipped" % (Intermediate_Files_GDB,nprefix)
        
        
        print '--Importing BIMODE cross-shore profiles'      
        arcpy.ASCII3DToFeatureClass_3d(BMprof_forWMfile,"XYZ", BIMODE_profiles_ASCI, "POINT", "1", InitCond_proj, "", "", "DECIMAL_POINT")

        # Add Z Information to new ASCII profiles
        arcpy.AddZInformation_3d(BIMODE_profiles_ASCI, "Z", "NO_FILTER")        

        ## Interpolate profile elevation points to a 30-m raster
        print '--Interpolating BIMODE cross-shore profiles into 30-m DEM.'    
        arcpy.Idw_3d(BIMODE_profiles_ASCI, "Z", BIMODE_DEM, "30", "2", "VARIABLE 12 150", "#")

        ## Make copy of Initial Topo raster that will be used in mosaic        
        print '--Copying Initial DEM into working geodatabase'
        NewTOPO = r"%s\\%sbidem" % (Intermediate_Files_GDB, nprefix)
#        arcpy.CopyRaster_management(rTOPO, NewTOPO)

        print '--Incorporate BIMODE DEM into initial topobathy DEM'
        ## Mosaic BIMODE DEM into CurrentTOPO - CurrentTOPO is the target, and by default is assigned a raster value of "FIRST", therefore BIMODE_DEM is considered "LAST"
        ## setting of "LAST" will have BIMODE_DEM override existing elevation value in CurrentTOPO raster
#        arcpy.Mosaic_management(BIMODE_DEM,NewTOPO,"LAST","#","#","#","NONE","0","NONE")
#        rUpdatedTOPO = Rater(NewTOPO)

        rBI_DEM = Raster(BIMODE_DEM)
        
        # remove portion of BIMODE DEM that overlays Freemason Islands (behind the Chandeleurs)
        try:
            clip_rect = Extent(894525,3306000,898030,3320000)
            rBI_DEMclip = arcpy.sa.ExtractByRectangle(rBI_DEM,clip_rect,"OUTSIDE")
        
            rBI_DEMclip.save(BIMODE_DEMclip)
    
            rNewBI_DEM = Raster(BIMODE_DEMclip)
    
            # combine topobathy with new barrier island elevation profiles
            rNewTOPO = Con(IsNull(rNewBI_DEM), rTOPO, rNewBI_DEM)        
        # if clip fails, use unclipped DEM
        except:
            rNewTOPO = Con(IsNull(rBI_DEM), rTOPO, rBI_DEM)        
            print ' ***Check clipping routine for Freemasons Islands - it failed.***'
        
        rNewTOPO.save(NewTOPO)
        
        e = time.clock()
        ProcTimeMin = round((e-s)/60,2)
        
        print "--total runtime: %s minutes" % (ProcTimeMin)
        print "COMPLETED BIMODE DEM INCORPORATION"
        
        
        return([NewTOPO])

    except Exception, e:
        # If an error occurred, print line number and error message
        import traceback, sys
        tb = sys.exc_info()[2]
        print "Line %i" % tb.tb_lineno
        print e.message

        return()

#EDW def Preprocessing(HydroData, AvgAcc, AvgSal, AvgStage, MaxStage, Land_Sed, Edge_Sed, Water_Sed, Subsidence, SubsidField, BasinMarshType, \
#EDW #                  OM_AVG_BMTField, BD_AVG_BMTField, MarshZones, MarshZoneField, CurrentLULC, \
#EDW #                  HurrSed, HurrSedField, CellSize,GridPoly,CompartmentPoly):

##PURPOSE: data conversion to prepare inputs for model runs. 
##includes vector to raster conversion salinity, stage, max stage, sediment load(accretion)

#def Preprocessing(Subsidence,SubsidField,BasinMarshType,Organic_In,OM_AVG_BMTField,BD_AVG_BMTField,MarshZones,MarshZoneField,CurrentLULC,CurrentEdge,CellSize,CompartmentPoly,GridPoly,InitCond_proj,elapsedyear):
def Preprocessing(Subsidence,SubsidField,CurrentLULC,CurrentEdge,CellSize,CompartmentPoly,GridPoly,InitCond_proj,Basins,HistoricMarshZones,BDWaterVal,OMWaterVal,BDOM_Lookup,BDOM_ZoneField,BD_NewValField,OM_NewValField,ShorelineProtProjects,ShorelineProtProjects_MEE_Mult,elapsedyear):

    try:
        msg0 = "\nDATA PREPROCESSING"
        arcpy.env.extent = "DEFAULT"
        print msg0
#        arcpy.AddMessage(msg0)
        s = time.clock()
        
        ##------------------------------------------------------------------------
        #SET OUTPUT FILENAMES, RASTERIZE HYDRO DATA, OUTPUT TO INTERMEDIATE WS
        arcpy.env.workspace = Intermediate_Files_GDB
        arcpy.env.scratchWorkspace = Temp_Files_Path
        arcpy.env.scratchFolder
        arcpy.env.scratchGDB
        
        #rasterize subsidence, only one needed
        msg0 = "--building subsidence raster"
        print msg0
        outName = "%ssubsd" % iprefix
        arcpy.PolygonToRaster_conversion(Subsidence, SubsidField, outName, "CELL_CENTER", "#", CellSize)
        subras = r"%s\\%s" % (Intermediate_Files_GDB,outName)
        
        
        #rasterize average marsh zone by basin/marsh type, only one needed
        msg0 = "--building new marsh types by basin raster"
        print msg0
        outName = "%smzone" % iprefix
        rLULC = Raster(CurrentLULC)
        rZones = Raster(Basins)
        
        # generate combined basin/LULC raster to match BDOM_Lookup table
        MZ = rZones*10 + rLULC
        MZ.save(outName)
        rMarshZone = Raster(outName)

        # reclassify marsh zone raster to generate bulk density in by marsh zone raster
        msg0 = "--building new bulk density raster for reclassed Veg output"
        print msg0
        NewBD = r"%s\\%sbdini" % (Intermediate_Files_GDB,nprefix)
        rOutBDmgcc = ReclassByTable(rMarshZone,BDOM_Lookup,BDOM_ZoneField,BDOM_ZoneField,BD_NewValField)
        rOutBDgcc = Float(rOutBDmgcc/1000.0)        #this is arcpy raster calculator function "Float"
        rBDnew = Con(rLULC == 6, BDWaterVal,rOutBDgcc)
        arcpy.CopyRaster_management(rBDnew, NewBD, "#", "#", "#", "#", "NONE", "32_BIT_FLOAT", "#", "#")

        # reclassify marsh zone raster to generate organic in by marsh zone raster        
        msg0 = "--building new organic matter raster for reclassed Veg output"
        print msg0
        NewOM = r"%s\\%somini" % (Intermediate_Files_GDB,nprefix)
        rOutOM = ReclassByTable(rMarshZone,BDOM_Lookup,BDOM_ZoneField,BDOM_ZoneField,OM_NewValField)
        rOMnew = Con(rLULC == 6, OMWaterVal, rOutOM)
        arcpy.CopyRaster_management(rOMnew, NewOM, "#", "#", "#", "#", "NONE", "32_BIT_FLOAT", "#", "#")

        rHistoricMarshZones = Raster(HistoricMarshZones)
        
        # create raster of average bulk density for historic marsh zones (for new land areas)
        msg0 = "--creating average bulk density raster to use for newly built land"
        print msg0
        AveBulkDensity_In = r"%s\\%sbdave" % (Intermediate_Files_GDB,nprefix)
        rAveBDmgcc = ReclassByTable(rHistoricMarshZones,BDOM_Lookup,BDOM_ZoneField,BDOM_ZoneField,BD_NewValField)
        rAveBDgcc = Float(rAveBDmgcc/1000.0)        #this is arcpy raster calculator function "Float"
        arcpy.CopyRaster_management(rAveBDgcc, AveBulkDensity_In, "#", "#", "#", "#", "NONE", "32_BIT_FLOAT", "#", "#")

        # create raster of average organic in for historic marsh zones (for new land areas)
        msg0 = "--creating average organic in raster to use for newly built land"
        print msg0
        AveOrganic_In = r"%s\\%sorgin" % (Intermediate_Files_GDB,nprefix)
        rAveOM = ReclassByTable(rHistoricMarshZones,BDOM_Lookup,BDOM_ZoneField,BDOM_ZoneField,OM_NewValField)
        arcpy.CopyRaster_management(rAveOM, AveOrganic_In, "#", "#", "#", "#", "NONE", "32_BIT_FLOAT", "#", "#")

        del rZones,MZ,rOutBDmgcc,rOutBDgcc,rBDnew,rOutOM,rOMnew,rMarshZone,rHistoricMarshZones,rAveBDmgcc,rAveBDgcc,rAveOM
        
        #rasterize mean water level, only one needed
        msg0 = "--building mean water level raster"
        print msg0
        vField = 'ave_annual_stage' #this value must match output headers generated by in main.f subroutine of hydro.exe
        NewMWL = r"%s\\%smwl_ave" % (Intermediate_Files_GDB, nprefix)
        arcpy.PolygonToRaster_conversion(CompartmentPoly, vField, NewMWL, "CELL_CENTER", "#", CellSize)
        
        #rasterize mean October-April water level - needed for Gadwall HSI
        msg0 = "--building mean water level raster for October-April"
        print msg0
        vField = 'ave_octapr_stage' #this value must match output headers generated by in main.f subroutine of hydro.exe
        OctAprMWL = r"%s\\%smwl_octapr" % (Intermediate_Files_GDB, nprefix)
        arcpy.PolygonToRaster_conversion(CompartmentPoly, vField, OctAprMWL, "CELL_CENTER", "#", CellSize)
        
        #rasterize mean September-March water level - needed for Green-winged Teal HSI
        msg0 = "--building mean water level raster for September-March"
        print msg0
        vField = 'ave_sepmar_stage'  #this value must match output headers generated by in main.f subroutine of hydro.exe
        SepMarMWL = r"%s\\%smwl_sepmar" % (Intermediate_Files_GDB, nprefix)
        arcpy.PolygonToRaster_conversion(CompartmentPoly, vField, SepMarMWL, "CELL_CENTER", "#", CellSize)
                
        #rename LULC to match new name
        msg0 = "--importing initial LULC raster from Initial Conditions database"
        print msg0
        NewLULC = r"%s\\%svgtyp" % (Intermediate_Files_GDB, nprefix)
        arcpy.CopyRaster_management(CurrentLULC, NewLULC)

        curYear = CurrentYear
        TwoDigitYr = str(curYear)[2:4]
        
        #salinity
        msg0 = "--building max salinity raster %s" % (curYear)
        print msg0
        vField = 'IDW_max_2wk_summer_salinity_ppt' #this value must match output headers generated by in main.f subroutine of hydro.exe
        outName = r"%ssal14" % nprefix
        salras = r"%s\\%s" % (Intermediate_Files_GDB, outName)
        arcpy.PolygonToRaster_conversion(GridPoly, vField, outName, "CELL_CENTER", "#", CellSize)

        
        #average salinity
        msg0 = "--building mean salinity raster %s" % (curYear)
        print msg0
        vField = 'IDW_ave_salinity_ppt'	#this value must match output headers generated by in main.f subroutine of hydro.exe
        outName = r"%ssalav" % nprefix
        avesalras = r"%s\\%s" % (Intermediate_Files_GDB, outName)
        arcpy.PolygonToRaster_conversion(GridPoly, vField, outName, "CELL_CENTER", "#", CellSize)



        #max stage
        msg0 = "--building max stage raster %s" % (curYear)
        print msg0
        vField = 'max_annual_stage'  #this value must match output headers generated by in main.f subroutine of hydro.exe
        outName = r"%sstgmx" % nprefix
        arcpy.PolygonToRaster_conversion(CompartmentPoly, vField, outName, "CELL_CENTER", "#", CellSize)
        stgmaxras = r"%s\\%s" % (Intermediate_Files_GDB, outName)

        #land sediment
        msg0 = "--building land sediment load raster %s" % (curYear)
        print msg0
        vField = 'marsh_int_sed_accum' #this value must match output headers generated by in main.f subroutine of hydro.exe
        outName = r"%ssedin" % nprefix
        temp = r"%s\\%s" % (Temp_Files_GDB, outName)
        landsedras = r"%s\\%s" % (Intermediate_Files_GDB, outName)
        arcpy.PolygonToRaster_conversion(CompartmentPoly, vField, temp, "CELL_CENTER", "#", CellSize)

        rSedLoad = Raster(temp)
        newRas = Con(rSedLoad < 0, 0, rSedLoad)
        newRas.save(landsedras)

        #edge sediment
        msg0 = "--building edge sediment load raster %s" % (curYear)
        print msg0
        vField = 'marsh_edge_sed_accum' #this value must match output headers generated by in main.f subroutine of hydro.exe
        outName = r"%sseded" % nprefix
        temp = r"%s\\%s" % (Temp_Files_GDB, outName)
        edgesedras = r"%s\\%s" % (Intermediate_Files_GDB, outName)
        arcpy.PolygonToRaster_conversion(CompartmentPoly, vField, temp, "CELL_CENTER", "#", CellSize)

        rSedLoad = Raster(temp)
        newRas = Con(rSedLoad < 0, 0, rSedLoad)
        newRas.save(edgesedras)            

        #water sediment
        msg0 = "--building water sediment load raster %s" % (curYear)
        print msg0
        vField = 'openwater_sed_accum' #this value must match output headers generated by in main.f subroutine of hydro.exe             
        outName = r"%ssedow" % nprefix
        temp = r"%s\\%s" % (Temp_Files_GDB, outName)
        owsedras = r"%s\\%s" % (Intermediate_Files_GDB, outName)
        arcpy.PolygonToRaster_conversion(CompartmentPoly, vField, temp, "CELL_CENTER", "#", CellSize)

        rSedLoad = Raster(temp)
#        newRas = Con(rSedLoad < 0, 0, rSedLoad)
#        newRas.save(outName)            
        rSedLoad.save(owsedras)
                
#use mee_rates raster from GDB#        #marsh edge erosion flag raster ,value of 1 is pixel that will be converted from land to water
#use mee_rates raster from GDB#        msg0 = "--creating marsh edge erosion raster %s" % (curYear)
#use mee_rates raster from GDB#        print msg0        
#use mee_rates raster from GDB#        vField = 'marsh_edge_erosion_rate' #this value must match output headers generated by in main.f subroutine of hydro.exe
#use mee_rates raster from GDB#        tempName = r"%smeert" % nprefix
#use mee_rates raster from GDB#        temp = r"%s\\%s" % (Temp_Files_GDB, tempName)
#use mee_rates raster from GDB#        arcpy.PolygonToRaster_conversion(CompartmentPoly, vField, temp, "CELL_CENTER", "#", CellSize)
#use mee_rates raster from GDB#        rMEErate = Raster(temp)

        msg0 = "--reading marsh edge erosion raster %s" % (curYear)
        print msg0        
        spatialMEE = r"%s\\mee_rates" % Input_GDB
        rMEErateOrig = Raster(spatialMEE)
        
        if ShorelineProtProjects <> 'NONE':
            arcpy.env.extent = rMEErateOrig
            print '--Shoreline Protection project is being implemented.'
            MultRaster = "%s\\IP_ShorelineProtection_%s" % (Intermediate_Files_GDB, CurrentYear)
            arcpy.PolygonToRaster_conversion(ShorelineProtProjects, ShorelineProtProjects_MEE_Mult, MultRaster, "CELL_CENTER", "#", 30)
            print '--reducing Edge Erosion raster to account for project impacts'
            rMEEmult = Raster(MultRaster)
            rMEErateNew = Con(IsNull(rMEEmult),rMEErateOrig,rMEErateOrig*(100-rMEEmult)/100.0)
            newMEE = "%s\\mee_rates_projects_%s" % (Intermediate_Files_GDB, CurrentYear)
            rMEErateNew.save(newMEE)
            
            rMEErate = Raster(newMEE)
            
        else:
            rMEErate = Raster(spatialMEE)
        
        
        rEdge = Raster(CurrentEdge)
        # Set NoData values in edge raster to 0, otherwise keep edge value of 1
        Edge0 = Con((IsNull(rEdge)==1),0,rEdge)
        
        
        # Create flag raster where value of 0 is no marsh edge erosion and value of 1 is pixel that was eroded during current year
        # (CellSize/rMEErate) = years needed for one pixel to retreat
        # elapsedyear/(CellSize/rMEErate) = total pixel retreat since start of model run (can be greater than 1)
        # Int(elapsedyear/(CellSize/rMEErate)) = whole number portion of total pixel retreat since start of model run (0 for less than one pixel, can be greater than 1)
        # Int(Int(elapsedyear/(CellSize/rMEErate))/elapsedyear) =  if whole number portion of pixel retreat is divisible by elapsed number of years, set flag to 1
        #MEEtrim = Edge0*Int(Int(elapsedyear/(CellSize/rMEErate))/elapsedyear)
        rPixelYears = Int(CellSize/rMEErate)
        rTotalRetreat = Float(elapsedyear/Float(rPixelYears))
        rTotalRetreatWhole = Float(RoundDown(rTotalRetreat))
        MEEtrim = Con((rTotalRetreat - rTotalRetreatWhole) == 0,1,0)
        
        # if MEErate was zero, MEEtrim will be NoData, fill these NoDatas with Zero
        MEEtrim0 = Con((IsNull(MEEtrim)==1),0,MEEtrim)
        MEEflag = r"%smeefl" % nprefix
        MEEtrim0.save(MEEflag)
                       
        del rSedLoad,newRas,Edge0,rMEErate,MEEtrim,MEEtrim0,rPixelYears,rTotalRetreat,rTotalRetreatWhole
        
        e = time.clock()
        ProcTimeMin = round((e-s)/60,2)
        
        msg0 = "--total runtime: %s minutes" % (ProcTimeMin)
        msg1 = "COMPLETED DATA PREPROCESSING"
        print msg0
        print msg1
        
        return([NewLULC, NewMWL,MEEflag,NewBD,NewOM,AveOrganic_In,AveBulkDensity_In,subras,landsedras,edgesedras,owsedras,stgmaxras,salras,avesalras,OctAprMWL,SepMarMWL])

    except Exception, e:
        # If an error occurred, print line number and error message
        import traceback, sys
        tb = sys.exc_info()[2]
        msg1 = "Line %i" % tb.tb_lineno
        msg2 = e.message
        print msg1
        print msg2
        return()
    
def IncorporateProjects(ProjectType, ProjectFeatures, RasValueField, RasValueField2, RasValueField3, RasValueField4, LandWater, TopoBathy, tMarshCreation,elapsedyear):
    ##PURPOSE: incorporates shoreline protection, marsh creation, levees, canals into land/water and topo data
    ##-occurs on time0 + 1 day
    try:

        msg0 = "\nIncorporating %s" % (ProjectType)
        print msg0
#        arcpy.AddMessage(msg0)
        
        s = time.clock()

        ##------------------------------------------------------------------------
        #SET OUTPUT FILENAMES 
        IP_Project = "IP_%s_%s" % (ProjectType, CurrentYear)
        IP_LW_1234 = r"%s\\%sIP_LW_%s_vals1234" % (Intermediate_Files_GDB, nprefix, ProjectType)
        IP_LandWater = r"%s\\%sIP_LW_%s" % (Intermediate_Files_GDB, nprefix, ProjectType)
        IP_Topo = r"%s\\%sIP_TOPO_%s" % (Temp_Files_GDB, nprefix, ProjectType)
        ##------------------------------------------------------------------------
        
        ##------------------------------------------------------------------------
        #CREATE THE PROJECT RASTER
        #
        arcpy.env.workspace = Temp_Files_GDB
        arcpy.env.scratchWorkspace = Temp_Files_Path
        arcpy.env.scratchFolder
        arcpy.env.scratchGDB
        arcpy.env.snapRaster = LandWater
        arcpy.env.extent = LandWater
        #desc = arcpy.Describe(LandWater)
        #zoneCellSize = desc.meanCellHeight
        zoneCellSize = ProcessingCellSize

        landGainValue = 4 
        landLossValue = 3
        #tMarshCreation = -1.524
        
        if ProjectType == "Levees":
            #buffer for crest, then slope
            IP_Levee_Crest = "IP_Levee_Crest%s" % (CurrentYear)
            arcpy.Buffer_analysis(ProjectFeatures, IP_Levee_Crest, RasValueField2)
            
            IP_Levee_Slope = "IP_Levee_Slope%s" % (CurrentYear)
            arcpy.Buffer_analysis(IP_Levee_Crest, IP_Levee_Slope, RasValueField3, "OUTSIDE_ONLY")

            #rasterize polys then mosaic result
            IP_Levee_CrestRas = "IP_Levee_Crest_%s_raster" % (CurrentYear)
            arcpy.PolygonToRaster_conversion(IP_Levee_Crest, RasValueField, IP_Levee_CrestRas, "CELL_CENTER", "#", zoneCellSize)
            
            IP_Levee_SlopeRas = "IP_Levee_Slope_%s_raster" % (CurrentYear)
            arcpy.PolygonToRaster_conversion(IP_Levee_Slope, RasValueField4, IP_Levee_SlopeRas, "CELL_CENTER", "#", zoneCellSize)

            rIP_Levee_CrestRas = Raster(IP_Levee_CrestRas)
            rIP_Levee_SlopeRas = Raster(IP_Levee_SlopeRas)
            outCellStats = CellStatistics([IP_Levee_CrestRas, IP_Levee_SlopeRas], "MAXIMUM", "DATA")
            outCellStats.save(IP_Project)

            #cleanup
            del rIP_Levee_CrestRas, rIP_Levee_SlopeRas

        else:            
            arcpy.PolygonToRaster_conversion(ProjectFeatures, RasValueField, IP_Project, "CELL_CENTER", "#", zoneCellSize)
        #            
        ##------------------------------------------------------------------------
        
        ##------------------------------------------------------------------------
        #UPDATE THE LANDWATER, TOPO
        rProject = Raster(IP_Project)
        rTopoRaster = Raster(TopoBathy)
        rLandWater = Raster(LandWater)
        
        #        
        #SHORELINE PROTECTION, LEVEE CREST, LEVEE SLOPE (LAND GAIN)
#EDW        if ProjectType == "ShorelineProtection" or ProjectType == "Levees":
#        if ProjectType == "ShorelineProtection":
#            # read in original MEE flag factor
#            rMEEorig = Raster(RasValueField2) 

        if ProjectType == "Levees":
            #update land/water
            #if Water(LW=2) AND Project Elevation > 0, then convert Water(2) to Land(1)
            #outRas1 = Con((rProject > 0), landGainValue, 0)
            #
            arcpy.env.extent = rLandWater
            outRasLW1 = Con((rLandWater == 2) & (rProject > 0), landGainValue, 0)
            outRasLW2 = Con(IsNull(outRasLW1), 0, outRasLW1)
            rIP_LW_1234 = Con((outRasLW2 > rLandWater), outRasLW2, rLandWater)
            
            #rIP_LW_1234.save(IP_LW_1234)
            updatedLWRaster = Reclassify(rIP_LW_1234, "VALUE", RemapValue([[1,1],[2,2],[3,2],[4,1],[5,5]]))
           #update relative elevation
            #if Project Elevation > RelativeElevation update to new elevation
            arcpy.env.extent = rTopoRaster
            outRasTOPO1 = Con((rProject > 0) & (rProject > rTopoRaster), rProject, rTopoRaster)
            rIP_Topo = Con(IsNull(outRasTOPO1), rTopoRaster, outRasTOPO1)
        #
        #MARSH CREATION (LAND GAIN)
        if ProjectType == "MarshCreation":
            #update land/water
            #if Water(LW=2) AND Project Elevation > 0, then convert Water(2) to Land(1)
            #
            arcpy.env.extent = rLandWater
            #outRasLW1 = Con((rLandWater == 2) & (rProject > 0) & (rTopoRaster > tMarshCreation), landGainValue, 0)
            outRasLW1 = Con((rProject > 0) & (rTopoRaster > tMarshCreation), landGainValue, 0)
            
            landgain = Con( (outRasLW1 == 4), 1, 0)
            
            outRasLW2 = Con(IsNull(outRasLW1), 0, outRasLW1)
            rIP_LW_1234 = Con((outRasLW2 > rLandWater), outRasLW2, rLandWater)
            #rIP_LW_1234.save(IP_LW_1234)
            updatedLWRaster = Reclassify(rIP_LW_1234, "VALUE", RemapValue([[1,1],[2,2],[3,2],[4,1],[5,5]]))     
            
            #
            #update relative elevation
            #if Project Elevation > RelativeElevation update to new elevation
            #
            arcpy.env.extent = rTopoRaster
            outRasTOPO1 = Con((rProject > 0) & (rProject > rTopoRaster) & (rTopoRaster > tMarshCreation), rProject, rTopoRaster)
            rIP_Topo = Con(IsNull(outRasTOPO1), rTopoRaster, outRasTOPO1)
            
            fillvol = Con((rProject > 0),30.0*30.0*(rIP_Topo - rTopoRaster),"")
            fillraster = r"%s\\%sMCvol" % (Temp_Files_GDB, nprefix)
            fillvol.save(fillraster)
              
           #arcpy.env.extent = rTopoRaster
            
            footprint = Con((fillvol>0),900,"")
            MCareas = r"%s\\%sMCprj" % (Temp_Files_GDB, nprefix)
            footprint.save(MCareas)
                      
            PTzones_id = 'Prj_PT_No'
            
            rMCareas = Raster(MCareas)
            rfillraster = Raster(fillraster)
            
            MC_areas_table = r"%s\\MarshCreation_areas_%02d" % (Temp_Files_GDB, elapsedyear)
            MC_a_csv = r"%s\\%sMCPTa.csv" % (Deliverable_Files_Path, oprefix)
            
            MC_volumes_table = r"%s\\MarshCreation_volumes_%02d" % (Temp_Files_GDB, elapsedyear)
            MC_v_csv = r"%s\\%sMCPTv.csv" % (Deliverable_Files_Path, oprefix)
            
            print "-- calculating marsh creation areas and volumes PT units"

            
            ZonalStatisticsAsTable(ProjectFeatures,PTzones_id,rMCareas,MC_areas_table,'DATA','SUM')
            MCfields = [str(PTzones_id),'SUM']
            MC_areatable = arcpy.da.TableToNumPyArray(MC_areas_table,MCfields)
            he_a = 'PrjNo_PTNo,project_area_m2'
            np.savetxt(MC_a_csv,MC_areatable,delimiter=',',fmt='%s,%f',header=he_a,comments='')
            
            ZonalStatisticsAsTable(ProjectFeatures,PTzones_id,rfillraster,MC_volumes_table,'DATA','SUM')
            MC_voltable = arcpy.da.TableToNumPyArray(MC_volumes_table,MCfields)
            he_v = 'PrjNo_PTNo,fill_volume_m3'
            np.savetxt(MC_v_csv,MC_voltable,delimiter=',',fmt='%s,%f',header=he_v,comments='')


            
#            print '--saving marsh creation project fill volumes in Deliverables folder.'
#            outFill = r"%s\\%sMCvol.img" % (Deliverable_Files_Path, oprefix)
#            arcpy.CopyRaster_management(fillraster, outFill)
            
        #CANALS (LAND LOSS)
        if ProjectType == "Canals":
            #update land/water
            #if Land(LW=1) AND Project Elevation > 0, then convert Land(1) to Water(2)
            arcpy.env.extent = rLandWater
            outRasLW1 = Con((rLandWater == 1) & (rProject > 0), landLossValue, 0)
            outRasLW2 = Con(IsNull(outRasLW1), 0, outRasLW1)
            rIP_LW_1234 = Con((outRasLW2 > rLandWater), outRasLW2, rLandWater)
            #rIP_LW_1234.save(IP_LW_1234)
            updatedLWRaster = Reclassify(rIP_LW_1234, "VALUE", RemapValue([[1,1],[2,2],[3,2],[4,1],[5,5]]))
            
            #update relative elevation
            #if Project Elevation > RelativeElevation update to new elevation
            #
            arcpy.env.extent = rTopoRaster
            outRasTOPO1 = Con((rProject < 0) & (rProject < rTopoRaster), rProject, rTopoRaster)
            rIP_Topo = Con(IsNull(outRasTOPO1), rTopoRaster, outRasTOPO1)

        #SAVE
        arcpy.env.extent = "DEFAULT"
        arcpy.CopyRaster_management(rIP_LW_1234, IP_LW_1234, "#", "#", "#", "#", "NONE", "4_BIT", "#", "#")
        arcpy.CopyRaster_management(updatedLWRaster, IP_LandWater, "#", "#", "#", "#", "NONE", "4_BIT", "#", "#")
        #updatedLWRaster.save(IP_LandWater)
        rIP_Topo.save(IP_Topo)
        #
        ##------------------------------------------------------------------------

        e = time.clock()
        ProcTimeMin = round((e-s)/60,2)
        msg0 = "--total runtime: %s minutes" % (ProcTimeMin)
        print msg0
#        arcpy.AddMessage(msg0)
        
        #cleanup
        del rProject, rTopoRaster, rLandWater, outRasLW1, outRasLW2, rIP_LW_1234, updatedLWRaster, outRasTOPO1, rIP_Topo
        
        return([IP_LandWater, IP_Topo, IP_LW_1234])

    except Exception, e:
        # If an error occurred, print line number and error message
        import traceback, sys
        tb = sys.exc_info()[2]
        msg1 = "Line %i" % tb.tb_lineno
        msg2 = e.message
#        arcpy.AddWarning(msg1)
#        arcpy.AddWarning(msg2)
        print msg1
        print msg2
        return()

def Update_BD_OM_LULC(LandWater1234,BulkDensity,BDWaterVal,OrganicMatter,OMWaterVal,LULC,HistoricMarshZones,Organic_In,BulkDensity_In,outPrefix):

    ##PURPOSE: updates organicIn, BD, LULC where land change occurred
    
    try:
        msg0 = "\nUPDATE BULK DENSITY, ORGANIC MATTER, AND LULC"
        print msg0
#        arcpy.AddMessage(msg0)
        
        s = time.clock()
        arcpy.env.extent = "DEFAULT"
        arcpy.env.workspace = Intermediate_Files_GDB
        arcpy.env.scratchWorkspace = Temp_Files_Path
        arcpy.env.scratchFolder
        arcpy.env.scratchGDB

        
        ##------------------------------------------------------------------------
        #SET OUTPUT FILENAMES 
        #
        NewBD = r"%s\\%s%s_bd" % (Intermediate_Files_GDB, nprefix, outPrefix)
        NewOM = r"%s\\%s%s_orgin" % (Intermediate_Files_GDB, nprefix, outPrefix)
        NewLULC = r"%s\\%s%s_LULC" % (Intermediate_Files_GDB, nprefix, outPrefix)
        #
        ##------------------------------------------------------------------------

        ##------------------------------------------------------------------------
        #make some rasters
        #
        rLW1234 = Raster(LandWater1234)
        rBD = Raster(BulkDensity)
        rOM = Raster(OrganicMatter)
        rLULC = Raster(LULC)
        rAvgBD = Raster(BulkDensity_In)
        rAvgOM = Raster(Organic_In)
        rMarshLookup = Raster(HistoricMarshZones)
        #
        ##------------------------------------------------------------------------

        ##------------------------------------------------------------------------
        #UPDATE BULK DENSITY
        #
        msg0 = '--updating bulk density'
        print msg0
        
        arcpy.env.extent = rBD
        # if land is lost (rLW1234=3) new BD is set to water BD, if land is gained (rLW1234=4) new OM is historic marsh type BD, if land/water doesn't change, use current BD
        rNewBD = Con((rLW1234 == 3), BDWaterVal, Con((rLW1234 == 4), rAvgBD, rBD))
        arcpy.CopyRaster_management(rNewBD, NewBD, "#", "#", "#", "#", "NONE", "32_BIT_FLOAT", "#", "#")
        #rNewBD.save(NewBD)
        #
        ##------------------------------------------------------------------------

        ##------------------------------------------------------------------------
        #UPDATE ORGANIC MATTER
        #
        msg0 = '--updating organic matter'
        print msg0
        
        arcpy.env.extent = rOM
        # if land is lost (rLW1234=3) new OM is set to water OM, if land is gained (rLW1234=4) new OM is historic marsh type OM, if land/water doesn't change, use current OM
        rNewOM = Con((rLW1234 == 3), OMWaterVal, Con((rLW1234 == 4), rAvgOM, rOM))
        arcpy.CopyRaster_management(rNewOM, NewOM, "#", "#", "#", "#", "NONE", "32_BIT_FLOAT", "#", "#")
        #rNewOM.save(NewOM)
        #
        ##------------------------------------------------------------------------

        ##------------------------------------------------------------------------
        #UPDATE LULC
        #
        msg0 = '--updating LULC'
        print msg0
        
        arcpy.env.extent = rLULC
        
        # Generate raster of LULC types from historic marsh zone raster
        # The last digit of the MarshLookup raster is the LULC code, only need the ones digit        
        rMarshLULC = Con(rMarshLookup > 100, rMarshLookup - 100,Con(rMarshLookup > 90, rMarshLookup - 90,Con(rMarshLookup > 80, rMarshLookup - 80,Con(rMarshLookup > 70, rMarshLookup - 70,Con(rMarshLookup > 60, rMarshLookup - 60,Con(rMarshLookup > 50, rMarshLookup - 50,Con(rMarshLookup > 40, rMarshLookup - 40,Con(rMarshLookup > 30, rMarshLookup - 30,Con(rMarshLookup > 20, rMarshLookup - 20, rMarshLookup - 10)))))))))
        
        # The Historic marsh zone raster had some areas that were classified as Type 6 - ignore these, have the model classify any new land built in these areas as LULC type 70
        rNewMarsh = Con(rMarshLULC == 6,7,rMarshLULC)
        
        # if land is lost (rLW1234=3) new LULC is 6 (water), if land is gained (rLW1234=4) new LULC is historic marsh type, if land/water doesn't change, use current LULC
        rNewLULC = Con((rLW1234 == 3), 6, Con((rLW1234 == 4), rNewMarsh, rLULC))
        arcpy.CopyRaster_management(rNewLULC, NewLULC, "#", "#", "#", "#", "NONE", "8_BIT_UNSIGNED", "#", "#")
        #
        ##------------------------------------------------------------------------
        
        #cleanup
        arcpy.env.extent = "DEFAULT"
        del rLW1234, rBD, rOM, rLULC, rAvgBD, rAvgOM, rMarshLookup, rMarshLULC, rNewMarsh, rNewBD, rNewOM, rNewLULC
        
        e = time.clock()
        ProcTimeMin = round((e-s)/60,2)
        msg0 = "--total runtime: %s minutes" % (ProcTimeMin)
        print msg0
        msg1 = "COMPLETED UPDATE BULK DENSITY, ORGANIC MATTER, AND LULC"
        print msg1
#        arcpy.AddMessage(msg0)
#        arcpy.AddMessage(msg1)
        
        return([NewBD, NewOM, NewLULC])
    
    except Exception, e:
        # If an error occurred, print line number and error message
        import traceback, sys
        tb = sys.exc_info()[2]
        msg1 = "Line %i" % tb.tb_lineno
        msg2 = e.message
#        arcpy.AddWarning(msg1)
#        arcpy.AddWarning(msg2)
        print msg1
        print msg2
        return()
    
def LossGain(zoneLayer, zoneField, GainField, LossField, LandWater, ProbSurface, MWLRaster, TopoBathy, RateMultiplier):
    ##PURPOSE: represents historical wetland loss rastes due to causal mechanisms other than inundation.
    ##
    ##Intermediate Outputs
    ##-LossGain_LW_1234_year (land, water, loss, gain)
    ##-LossGain_Topo_year (updated relative elevation)
    ##-LossGain_LW_12_year (land, water)
    ##
    
    try:
        msg0 = "\nBEGIN LOSS GAIN"
        print msg0
#        arcpy.AddMessage(msg0)
        
        s = time.clock()
        
        ##------------------------------------------------------------------------
        #SET OUTPUT FILENAMES 
        LossGain_LW_1234 = r"%s\\LossGain_LW_%s_vals1234" % (Intermediate_Files_GDB, CurrentYear)
        LossGain_LW_12 = r"%s\\LossGain_LW_%s_vals12" % (Intermediate_Files_GDB, CurrentYear)
        LossGain_Topo = r"%s\\LossGain_Topo_%s" % (Intermediate_Files_GDB, CurrentYear)     
        #
        ##------------------------------------------------------------------------
        
        desc = arcpy.Describe(LandWater)
        LWCellSize = desc.meanCellHeight
        
        TempWS = Temp_Files_GDB
        #desc = arcpy.Describe(ProbSurface)
        #zoneCellSize = desc.meanCellHeight
        zoneCellSize = ProcessingCellSize
        
        GainThreshold = 0
        ThresholdMet = "FALSE"
        if GainThreshold == 0:
            GainThreshold = 100000000000000
        else:
            GainThreshold = int(GainThreshold)

        #Set some env vars
        arcpy.env.extent = "DEFAULT"
        arcpy.env.snapRaster = LandWater
        arcpy.env.cellSize = LandWater
        arcpy.env.workspace = Temp_Files_GDB
        arcpy.env.scratchWorkspace = Temp_Files_Path    
        arcpy.env.scratchFolder
        arcpy.env.scratchGDB

        #list to hold zonal rasters
        lstZoneRas = []
        lstZoneRas.append(LandWater)

        ##------------------------------------------------------------------------
        #EXTRACT LAND AND WATER
        #1 = LAND, 2 = WATER
        msg0 = "EXTRACTING LAND/WATER PIXELS\n"
        print msg0
        #arcpy.AddMessage("EXTRACTING LAND/WATER PIXELS\n")
        rasLand = Reclassify(LandWater, "VALUE", RemapValue([[1,1],[2,0]]))
        rasWater = Reclassify(LandWater, "VALUE", RemapValue([[1,0],[2,1]]))
        ##------------------------------------------------------------------------

        ##------------------------------------------------------------------------
        #LOOP THROUGH ALL ZONES
        iCount = 0
        cur = arcpy.SearchCursor(zoneLayer)
        feat = cur.next()

        while feat:
            iCount = iCount + 1
            
            reqGAreaSqKm = int(RateMultiplier) * (feat.getValue(GainField))
            reqGPixelCount = abs((reqGAreaSqKm * 1000000) / (LWCellSize ** 2)) #900 = cellarea^2
            if reqGPixelCount < 1:
                reqGPixelCount = 0

            reqLAreaSqKm = int(RateMultiplier) * (feat.getValue(LossField))
            reqLPixelCount = abs((reqLAreaSqKm * 1000000) / (LWCellSize ** 2))
            if reqLPixelCount < 1:
                reqLPixelCount = 0
            
            zoneName = feat.getValue(zoneField)
            szoneName = "zone_%s" % (str(iCount))

            msg0 = "  \n--Processing zone: %s" % (zoneName)
#            arcpy.AddMessage(msg0)
            print msg0
            
            zoneRas = r"%s\\%s" % (TempWS, szoneName + "_ma")
            
            #Extract zone
            tempRas = r"%s\\%s" % (TempWS, szoneName)
            
            geometry = feat.getValue("Shape")
            xMin = geometry.extent.XMin
            xMax = geometry.extent.XMax
            yMin = geometry.extent.YMin
            yMax = geometry.extent.YMax
            env = """%s %s %s %s""" % (xMin, yMin, xMax, yMax)

            if reqLAreaSqKm == 0 and reqGAreaSqKm == 0:
                arcpy.Clip_management(LandWater, env, TempWS + szoneName + "_r.img", geometry, "", "ClippingGeometry")
                arcpy.BuildRasterAttributeTable_management(TempWS + szoneName + "_r.img", "OVERWRITE")
            else:
                arcpy.Clip_management(ProbSurface, env, tempRas, geometry, "", "ClippingGeometry")
                arcpy.BuildRasterAttributeTable_management(tempRas, "OVERWRITE")

                #Create reclass table
                dbfName = "remap"
                outDBF = r"%s\\%s" % (TempWS, dbfName)
                                      
                if arcpy.Exists(outDBF):
                    arcpy.Delete_management(outDBF)
                
                #gp.AddMessage(outDBF)
                arcpy.CreateTable_management(TempWS, dbfName)
                arcpy.AddField_management(outDBF, "FROMVAL", "SHORT")
                arcpy.AddField_management(outDBF, "TOVAL", "SHORT")
                arcpy.AddField_management(outDBF, "REMAP", "SHORT")

                #reset count
                totalPixelCount = 0
                numPixels = 0
                noMoreReqd = "FALSE"

            ##--PROCESS LOSS--##
        
            if abs(reqLAreaSqKm) > 0: #Vals should always be positive        

#                arcpy.AddMessage("   Land Loss:")
#                arcpy.AddMessage("     Area Required (sq. km): " + str(abs(reqLAreaSqKm)))
#                arcpy.AddMessage("     Pixels Required: " + str(int(reqLPixelCount)))
                print "   Land Loss:"
                print "     Area Required (sq. km): " + str(abs(reqLAreaSqKm))
                print "     Pixels Required: " + str(int(reqLPixelCount))
                
                #eliminate water pixels from consideration
                #arcpy.gp.Times_sa(tempRas, rasLand, zoneRas)
                zoneRas = tempRas * rasLand
                
                recs = arcpy.SearchCursor(zoneRas, "", "", "", "VALUE D")
                rec = recs.next()
                recs2 = arcpy.InsertCursor(outDBF)

                while rec:
                    previousVal = numPixels
                    theVal = rec.getValue("VALUE")
                    
                    if theVal == 0:
                        rec2 = recs2.newRow()
                        rec2.setValue("FROMVAL", theVal)
                        rec2.setValue("TOVAL", theVal)
                        rec2.setValue("REMAP", 0)
                        recs2.insertRow(rec2)
                    else:
                        numPixels = rec.getValue("COUNT")
                        currentVal = numPixels
                        theDiff = abs(reqLPixelCount - totalPixelCount)
                        possDiff = abs(totalPixelCount + currentVal) - reqLPixelCount

                        if (possDiff <= theDiff) and (noMoreReqd == "FALSE"): #continue to next pixel group
                       
                            totalPixelCount = totalPixelCount + numPixels

                            #add the val to remap dbf
                            rec2 = recs2.newRow()
                            rec2.setValue("FROMVAL", theVal)
                            rec2.setValue("TOVAL", theVal)
                            rec2.setValue("REMAP", 3)
                            recs2.insertRow(rec2)
                        else:
                            noMoreReqd = "TRUE"
                            #map rest vals to 0 in remap dbf
                            rec2 = recs2.newRow()
                            rec2.setValue("FROMVAL", theVal)
                            rec2.setValue("TOVAL", theVal)
                            rec2.setValue("REMAP", 0)
                            recs2.insertRow(rec2)                    
                            #break
                            
                    rec = recs.next()

                diffPixel = totalPixelCount - reqLPixelCount
                diffSQKM = diffPixel * 0.0009
                
#                arcpy.AddMessage("     Pixels Assigned: " + str(int(totalPixelCount)))
#                arcpy.AddMessage("     Area Difference (sq. km): " + str(diffSQKM))
                print "     Pixels Assigned: " + str(int(totalPixelCount))
                print "     Area Difference (sq. km): " + str(diffSQKM)
                
                #reclassify based on remap dbf
##                arcpy.gp.ReclassByTable_sa(zoneRas, outDBF, "FROMVAL", "TOVAL", "REMAP", TempWS + "\\" + szoneName + "_rL", "NODATA")
                outRaster = ReclassByTable(zoneRas, outDBF,"FROMVAL","TOVAL","REMAP","NODATA")
                outName = "%s_rL" % (szoneName)
                arcpy.CopyRaster_management(outRaster, outName, "#", "#", "#", "#", "NONE", "4_BIT", "#", "#")                
                del rec, recs, rec2, recs2

                #add new raster to list, needed to mosaic later
                #lstZoneRas.append(szoneName + "_rL") 
                lstZoneRas.append(outName)
                
            ##--PROCESS GAIN--##
                
            if abs(reqGAreaSqKm) > 0: #land gain(positive rate)

                #reset count
                totalPixelCount = 0
                numPixels = 0
                noMoreReqd = "FALSE"

                if arcpy.Exists(outDBF):
                    arcpy.Delete_management(outDBF)
                
                #gp.AddMessage(outDBF)
                arcpy.CreateTable_management(TempWS, dbfName)
                arcpy.AddField_management(outDBF, "FROMVAL", "SHORT")
                arcpy.AddField_management(outDBF, "TOVAL", "SHORT")
                arcpy.AddField_management(outDBF, "REMAP", "SHORT")
                
#                arcpy.AddMessage("   Land Gain:")
#                arcpy.AddMessage("     Area Required (sq. km): " + str(abs(reqGAreaSqKm)))
#                arcpy.AddMessage("     Pixels Required: " + str(int(reqGPixelCount)))
                print "   Land Gain:"
                print "     Area Required (sq. km): " + str(abs(reqGAreaSqKm))
                print "     Pixels Required: " + str(int(reqGPixelCount))
                
                #eliminate land pixels from consideration
                #arcpy.Times_sa(tempRas, rasWater, zoneRas)
                zoneRas = tempRas * rasWater
                
                recs = arcpy.SearchCursor(zoneRas, "", "", "", "VALUE A")
                rec = recs.next()
                recs2 = arcpy.InsertCursor(outDBF)

                while rec:
                    previousVal = numPixels
                    theVal = rec.getValue("VALUE")

                    if theVal == 0:
                        rec2 = recs2.newRow()
                        rec2.setValue("FROMVAL", theVal)
                        rec2.setValue("TOVAL", theVal)
                        rec2.setValue("REMAP", 0)
                        recs2.insertRow(rec2)
                    else:
                        numPixels = rec.getValue("COUNT")
                        currentVal = numPixels
                        theDiff = abs(reqGPixelCount - totalPixelCount)
                        possDiff = abs(totalPixelCount + currentVal) - reqGPixelCount

                        if (theVal > GainThreshold) and (noMoreReqd == "FALSE") :
                            noMoreReqd = "TRUE"
                            ThresholdMet = "TRUE"
                            
                        if (possDiff <= theDiff) and (noMoreReqd == "FALSE"): #continue
                       
                            totalPixelCount = totalPixelCount + numPixels

                            #add the val to remap dbf
                            rec2 = recs2.newRow()
                            rec2.setValue("FROMVAL", theVal)
                            rec2.setValue("TOVAL", theVal)
                            rec2.setValue("REMAP", 4)
                            recs2.insertRow(rec2)
                        else:
                            noMoreReqd = "TRUE"
                            #map rest vals to 0 in remap dbf
                            rec2 = recs2.newRow()
                            rec2.setValue("FROMVAL", theVal)
                            rec2.setValue("TOVAL", theVal)
                            rec2.setValue("REMAP", 0)
                            recs2.insertRow(rec2)                    
                            #break
                            
                    rec = recs.next()

                diffPixel = totalPixelCount - reqGPixelCount
                diffSQKM = diffPixel * 0.0009
                
#                arcpy.AddMessage("     Pixels Assigned: " + str(int(totalPixelCount)))
                print "     Pixels Assigned: " + str(int(totalPixelCount))
                if ThresholdMet == "FALSE":
#                    arcpy.AddMessage("     Area Difference (sq. km): " + str(diffSQKM))
                    print "     Area Difference (sq. km): " + str(diffSQKM) 
                else:
#                    arcpy.AddMessage("     Area Difference (sq. km): " + str(diffSQKM))
#                    arcpy.AddMessage("     ***GAIN THRESHOLD EXCEEDED****")
                    print "     Area Difference (sq. km): " + str(diffSQKM)
                    print "     ***GAIN THRESHOLD EXCEEDED****"
                
                #reclassify based on remap 
##                arcpy.gp.ReclassByTable_sa(zoneRas, outDBF, "FROMVAL", "TOVAL", "REMAP", TempWS + "\\" + szoneName + "_rG", "NODATA")
                outRaster = ReclassByTable(zoneRas, outDBF,"FROMVAL","TOVAL","REMAP","NODATA")
                outName = "%s_rG" % (szoneName)
                arcpy.CopyRaster_management(outRaster, outName, "#", "#", "#", "#", "NONE", "4_BIT", "#", "#")
                
                del rec, recs, rec2, recs2

                #add new raster to list, needed to mosaic later
                lstZoneRas.append(outName)
                #lstZoneRas.append(szoneName + "_rG")
                
            feat = cur.next()

        del feat, cur
        #
        ##------------------------------------------------------------------------
        
        ##------------------------------------------------------------------------
        #MOSAIC ZONAL LOSS AND ZONAL GAIN RASTERS WITH LW
        #1=land 2=water 3=land loss 4=land gain
        #
        msg0 = "\n--building loss/gain mosaic"
#        arcpy.AddMessage(msg0)
        print msg0
        
        #assemble list of rasters
        rasterString = lstZoneRas.pop(0)
        desc = arcpy.Describe(LandWater)
        SR = desc.spatialReference
        zoneCellSize = desc.meanCellHeight
        arcpy.env.extent = LandWater
        for r in lstZoneRas:
            rasterString = """%s;%s""" % (rasterString, r)

        newMosaic = os.path.split(LossGain_LW_1234)[1]
        arcpy.MosaicToNewRaster_management(rasterString, Intermediate_Files_GDB, newMosaic, SR, "4_BIT", zoneCellSize, "1", "MAXIMUM", "#")
        arcpy.env.workspace = Intermediate_Files_GDB
        arcpy.BuildRasterAttributeTable_management(LossGain_LW_1234, "OVERWRITE")
        #
        ##------------------------------------------------------------------------

        ##------------------------------------------------------------------------
        #CREATE THE UPDATED LAND/WATER DATA (VALS 1,2)
        #
        msg0 = "--building updated land/water mosaic"
#        arcpy.AddMessage(msg0)
        print msg0

        updatedLWRaster = Reclassify(LossGain_LW_1234, "VALUE", RemapValue([[1,1],[2,2],[3,2],[4,1],[5,5]]))
        arcpy.CopyRaster_management(updatedLWRaster, LossGain_LW_12, "#", "#", "#", "#", "NONE", "4_BIT", "#", "#")
        #
        ##------------------------------------------------------------------------
        
        ##------------------------------------------------------------------------
        #UPDATE TOPOBATHY BASED ON LOSS/GAIN AREAS
        msg0 = "--building updated topobathymetric mosaic"
#        arcpy.AddMessage(msg0)
        print msg0
        #
        arcpy.env.workspace = Intermediate_Files_GDB
        arcpy.env.extent = "DEFAULT"
        #
        ##--PROCESS LOSS--##
        #if loss occurred, update topo whichever is less, mwl-0.25 or topo-0.25
        #
        rTopoRaster = Raster(TopoBathy)
        rMWLRaster = Raster(MWLRaster)
        rLossGain_LW_1234 = Raster(LossGain_LW_1234)
        #
        #determine Lowest val between MWL-.25 and topo-.25

        outRasT = ((rTopoRaster * 100) - 25) / 100 
        outRasM = ((rMWLRaster * 100) - 25) / 100 
        outRas1 = Con((rTopoRaster < rMWLRaster), outRasT, outRasM) 
        
        #outRas1 = Con(((rTopoRaster) < (rMWLRaster)), (rTopoRaster - 0.25), (rMWLRaster - 0.25)) #*
        arcpy.env.extent = rTopoRaster
        test1 = Con((rLossGain_LW_1234 == 3), outRas1, Con((rLossGain_LW_1234 == 4), (rMWLRaster + 0.25), rTopoRaster))
        test2 = Con(IsNull(test1), rTopoRaster, test1)
        arcpy.CopyRaster_management(test2, LossGain_Topo, "#", "#", "#", "#", "NONE", "32_BIT_FLOAT", "#", "#")
        arcpy.env.extent = "DEFAULT"
        del test1, test2

        #cleanup
        del rasLand, rasWater, zoneRas, updatedLWRaster, rTopoRaster, rMWLRaster, rLossGain_LW_1234, outRas1, outRasT, outRasM,
        #del TopoWithLoss, outRasGain, UpdatedTopoLossGain
        #
        #END UPDATE TOPOBATHY BASED ON LOSS/GAIN AREAS
        ##------------------------------------------------------------------------

        e = time.clock()
        ProcTimeMin = round((e-s)/60,2)
        
        msg0 = "--total runtime: %s minutes" % (ProcTimeMin)
        msg1 = "COMPLETED LOSS GAIN"
        print msg0
        print msg1
#        arcpy.AddMessage(msg0)
#        arcpy.AddMessage(msg1)
        
        return([LossGain_LW_12, LossGain_Topo, LossGain_LW_1234])
    
    except Exception, e:
        # If an error occurred, print line number and error message
        import traceback, sys
        tb = sys.exc_info()[2]
        msg1 = "Line %i" % tb.tb_lineno
        msg2 = e.message
#        arcpy.AddWarning(msg1)
#        arcpy.AddWarning(msg2)
        print msg1
        print msg2
        return()


#def SedimentDistribution(LandWater, TopoBathy, SubsidenceRas, OM, BD, LandSed, EdgeSed, WaterSed, HurrSed, AccMaxYr, StageMax, edgeWidthCells):
# no longer using separate hurricane sediment load - storms are in LandSed,EdgeSed,and WaterSed
def SedimentDistribution(LandWater, TopoBathy, CurrentEdge, SubsidenceRas, OM, BD, LandSed, EdgeSed, WaterSed, AccMaxYr, StageMax, edgeWidthCells,MEEflag,CompartmentPoly,CompartmentPolyID_Field,BDWaterVal,RegimeChan,elapsedyear):
    try:
        msg0 = "\nBEGIN SEDIMENT DISTRIBUTION & ACCUMULATION"
        print msg0
#        arcpy.AddMessage(msg0)
        
        s = time.clock()
        
        ##------------------------------------------------------------------------
        #SET OUTPUT FILENAMES 
        SED_TOPO = r"%s\\%sseddem" % (Intermediate_Files_GDB, nprefix)
        SED_TOPOclip = r"%s\\%sseddem_clip" % (Intermediate_Files_GDB, nprefix)
        SED_ACC = r"%s\\%ssed_accr_m" % (Intermediate_Files_GDB, nprefix)
        SED_ACC_I = r"%s\\%ssed_accr_I_m" % (Intermediate_Files_GDB, nprefix)
        SED_ACC_E = r"%s\\%ssed_accr_E_m" % (Intermediate_Files_GDB, nprefix)
        SED_ACC_L = r"%s\\%ssed_accr_L_m" % (Intermediate_Files_GDB, nprefix)
        SED_ACC_W = r"%s\\%ssed_accr_W_m" % (Intermediate_Files_GDB, nprefix)
        SED_I_Weight = r"%s\\%ssed_intwght" % (Intermediate_Files_GDB, nprefix)
        New_LW = r"%s\\%ssed_mee_LW" % (Intermediate_Files_GDB, nprefix)
        ##------------------------------------------------------------------------

        #Set some env vars
        arcpy.env.extent = "DEFAULT"
        arcpy.env.snapRaster = TopoBathy
        arcpy.env.workspace = Intermediate_Files_GDB
        arcpy.env.scratchWorkspace = Temp_Files_Path
        arcpy.env.scratchFolder
        arcpy.env.scratchGDB
        
        
        ##------------------------------------------------------------------------
        #MAKE SOME RASTERS
        rTOPO = Raster(TopoBathy)
        rLW = Raster(LandWater)
        rEdge = Raster(CurrentEdge)
        rSubsid = Raster(SubsidenceRas)
        rOM = Raster(OM)
        rBD = Raster(BD)
        rLandSed = Raster(LandSed)
        rEdgeSed = Raster(EdgeSed)
        rWaterSed = Raster(WaterSed)
        rStageMax = Raster(StageMax)
        rMEE = Raster(MEEflag)
        rRegimeCh = Raster(RegimeChan)
        #rHurrSed = Raster(HurrSed) # no longer using separate hurricane sediment load - storms are in LandSed,EdgeSed,and WaterSed
        #
        #-------------------------------------------------------------------------

        # Update LandWater for pixels where edge eroded during current year - this is applied after the LossGain routine - therefore if that routine converted edge to water, don't double count
        # rMEE = 0 for non-edge
        # rMEE = 1 for old edge that should be eroded during current year
        # if rLW1 is 1 and rMEE is 1, then this is a pixel that WAS edge AND should be eroded
        # if rLW1 is 2 and rMEE is 1, then this is a pixel that WAS edge THEN was converted to water in LossGain and will NOT be eroded


        ##------------------------------------------------------------------------
        #ISOLATE LAND, EDGE, WATER
        msg0 = "--isolating land, edge, water"
        print msg0
#        arcpy.AddMessage(msg0)
        outRas0 = Shrink(rLW, edgeWidthCells, 1)

        #Edge = Con((outRas0 + rLW == 3), 1, 0)
        #2=land, 3=edge, 4=water, 5=floatant
        # use original LW for pixels that border floatant marsh - these areas should not be considered edge and should not be updated as a function of marsh edge erosion but the are multipled by 2 to equal the 234 values
        outRasVals234_1 = Con( (outRas0 < 5), outRas0 + rLW, Con( (rLW == 5), 5, rLW*2) )

        msg0 = "--updating land/water for marsh edge erosion losses in year"
        print msg0 
# if edge and in a compartment with edge erosion for the year, convert to water
        outRasVals234 = Con((outRasVals234_1 == 3) & (rMEE == 1),4,outRasVals234_1)

        LWupdate = Con((outRasVals234 <= 3), 1, Con((outRasVals234 == 4), 2, 5))
        LWupdate.save(New_LW)

        ##------------------------------------------------------------------------

        ##------------------------------------------------------------------------
        #UPDATE LAND, EDGE, WATER WITH SEDIMENT LOADS
        #
        #sediment loads are yearly, so mulitply by the number of years represented by a model run
        
        # calculate portion of land in each hydro compartment that was inundated during the previous year
        # sediment load per unit area was calculated in Hydro by dividing by the total marsh interior area
        # when the sediment load is applied here, it only loads the sediment to the portion of marsh below the max high water of the year
        # therefore the sediment accumulation load for the interior of the marsh needs to be increased to account for the same mass of sediment
        # being delivered but to a smaller area
        msg0 = "--calculating weighting factor for marsh interior sediment load due to non-inundated marsh area"
        print msg0
        
        #raster of 1s where land elevation is below maximum stage during year
        rFloodedLand = Con( outRasVals234 == 2, Con( rTOPO <= rStageMax, 1, 0 ), 0 )
        
        #raster of 1s where land is marsh interior
        rNonEdgeLand = Con( outRasVals234 == 2, 1, 0 )
        zone = CompartmentPoly
        zone_field = CompartmentPolyID_Field 
        
        #raster where all 1s from flooded interior areas are summed
        rSumFlood = ZonalStatistics(zone, zone_field, rFloodedLand, "SUM", "DATA")
        #raster where all 1s from interior areas are summed
        rSumNonEdge = ZonalStatistics(zone, zone_field, rNonEdgeLand, "SUM", "DATA")
        #raster where value is the ratio of  total interior area over flooded interior area (value to multiply interior sediment load by)
        rLandSedWeight = rSumNonEdge/rSumFlood

        # develop constant raster of value 2.0
        rConstant2 = rLandSedWeight*2.0/rLandSedWeight


        rLandSedWeight.save(SED_I_Weight)

        msg0 = "--distributing sediment load"
        print msg0
#        arcpy.AddMessage(msg0)        
        rSedL_E_W = Con((outRasVals234 == 2), (rLandSed*rLandSedWeight * YearIncrement), Con((outRasVals234 == 3), (rEdgeSed * YearIncrement), (rWaterSed * YearIncrement * rRegimeCh)))

#EDW         # no longer using separate hurricane sediment load - storms are in LandSed,EdgeSed,and WaterSed
#EDW         #rSedL_E_W_H = (rHurrSed * YearIncrement) + rSedL_E_W
        ##------------------------------------------------------------------------
        
        ##------------------------------------------------------------------------
        #CALCULATE ACCRETION
        #-- accretion cm = (Sed + OM) / (10000 * BD), need to divide 100 to convert cm to m
        #
        #rAcc = ((rSedL_E_W + rOM) / (10000 * rBD)) / 100
        #rAcc = Con((rBD == 0), 0, (((rSedL_E_W + rOM) / (10000 * rBD)) / 100))
        msg0 = "--calculating accretion"
        print msg0
#        arcpy.AddMessage(msg0)

#EDW         # no longer using separate hurricane sediment load - storms are in LandSed,EdgeSed,and WaterSed
#EDW        rAcc_cm_year = Con((rBD == 0), 0, (((rSedL_E_W_H + rOM) / (10000 * rBD))))       
# if bulk density raster is 0, do not calculate accretion
# if raster is water do not add organic matter 
# if land, add organic matter and background accretion of 2 mm/year
        rAcc_cm_year = Con( (rBD == 0), 0, Con( rLW == 2, ( rSedL_E_W/(10000*BDWaterVal) ),( ( (rSedL_E_W + rOM)/(10000*rBD) ) + (rConstant2/10.0) ) ) )
        rAcc_m_year = (rAcc_cm_year / 100) * YearIncrement
        AccMaxInc = AccMaxYr * YearIncrement
        
        
        rAcc_m_yr_mod = Con(rAcc_m_year > AccMaxInc, AccMaxInc, rAcc_m_year)
        #mod to include max stage
        rAcc_m_yr_maxstg = Con(rTOPO > rStageMax, 0, rAcc_m_yr_mod)

        rAcc_m_yr_maxstg.save(SED_ACC)
        #
        ##------------------------------------------------------------------------

        ##------------------------------------------------------------------------
        #UPDATE TOPOBATHY WITH SUBSIDENCE AND ACCRETION
        #-- updatedTOPO = currentTOPO + Accretion - Subsidence
        #
        msg0 = "--updating existing topobathymetric raster"
        print msg0
        
        arcpy.env.extent = rTOPO
#EDW        updatedTOPO = rTOPO + rAcc_m_year - rSubsid
        updatedTOPO = rTOPO + rAcc_m_yr_maxstg - rSubsid
        updatedTOPO.save(SED_TOPOclip)
        newTOPOname = SED_TOPOclip
        try:
            rNewTOPO = Raster(SED_TOPOclip)
            arcpy.env.extent = rTOPO
            nnew = Con(IsNull(rNewTOPO), rTOPO, rNewTOPO)
            nnew.save(SED_TOPO)
            del rNewTOPO
            newTOPOname = SED_TOPO
        except:
            print 'extending TOPO did not work - current TOPO is clipped to LandWater extent'
        #test#rNewTOPO = Con(IsNull(updatedTOPO), rTOPO, updatedTOPO)
        #test#
        #test#SED_TOPO = r"%s\\%sseddem" % (Intermediate_Files_GDB, nprefix)
        #test#try:
        #test#    rNewTOPO.save(SED_TOPO)
        #test#except:
        #test#    print ' Saving SED_TOPO failed - trying CopyRaster'
        #test#    
        #test#    try:
        #test#        arcpy.CopyRaster_management(rNewTOPO, SED_TOPO)
        #test#    except:
        #test#        print ' CopyRaster failed - trying different name'
        #test#        try:
        #test#            SED_TOPO = 'DEM_sed'
        #test#            arcpy.CopyRaster_management(rNewTOPO, SED_TOPO)
        #test#            print ' CopyRaster worked with new name'                    
        #test#        except:
        #test#            print ' I have no clue. I quit.'
        #test#    
                            
        #cleanup
        del rTOPO, rLW, rSubsid, rOM, rBD, rLandSed, rEdgeSed, rWaterSed, outRas0, outRasVals234,outRasVals234_1
        del rSedL_E_W, rAcc_cm_year, rAcc_m_year, rAcc_m_yr_mod, updatedTOPO
       # del  rNewTOPO
        del rStageMax, rAcc_m_yr_maxstg
#skip        del rNonEdgeLW, rEdgeAccr, rIntAccr, rLandAccr, rWaterAccr
        del rFloodedLand, rNonEdgeLand,rSumFlood,rSumNonEdge,rLandSedWeight

#EDW         # no longer using separate hurricane sediment load - storms are in LandSed,EdgeSed,and WaterSed
#EDW	#del rSedL_E_W_H

        e = time.clock()
        ProcTimeMin = round((e-s)/60,2)

        msg0 = "--total runtime: %s minutes" % (ProcTimeMin)
        msg1 = "COMPLETED SEDIMENT DISTRIBUTION & ACCUMULATION"
        print msg0
        print msg1

        return([newTOPOname,New_LW])

    except Exception, e:
        # If an error occurred, print line number and error message
        import traceback, sys
        tb = sys.exc_info()[2]
        msg1 = "Line %i" % tb.tb_lineno
        msg2 = e.message
#       arcpy.AddWarning(msg1)
#       arcpy.AddWarning(msg2)
        print msg1
        print msg2
        return()

#EDW no longer using ChangeMWL in SLR calcs (this was remnant of 25-year version of WM.py)    
#EDW def SeaLevelRise(MWL, ChangeMWL, TopoBathy, LandWater, LULC, Salinity):
def SeaLevelRise(MWL,TopoBathy,LandWater,LULC,Salinity,PreviousMWL,PreviousLULC,elapsedyear,BI_Mask,NoUpdateMask,BareGroundCollapse,ASalinity):
    try:
        msg0 = "\nBEGIN SEA LEVEL RISE"
        print msg0
#        arcpy.AddMessage(msg0)
        
        s = time.clock()
        
        ##------------------------------------------------------------------------
        #SET OUTPUT FILENAMES 
        SLR_LW_1234 = r"%s\\%sSLR_LW_vals1234" % (Intermediate_Files_GDB, nprefix)
        SLR_LW_12 = r"%s\\%sSLR_LW_vals12" % (Intermediate_Files_GDB, nprefix)
#EDW        SLR_MWL = r"%s\\SLR_MWL_%s" % (Intermediate_Files_GDB, CurrentYear)
        #
        ##------------------------------------------------------------------------

        #Set some env vars
        arcpy.env.extent = "DEFAULT"
        arcpy.env.snapRaster = LandWater
        arcpy.env.workspace = Intermediate_Files_GDB
        arcpy.env.scratchWorkspace = Temp_Files_Path
        arcpy.env.scratchFolder
        arcpy.env.scratchGDB
        
        
        ##------------------------------------------------------------------------
        #MAKE SOME RASTERS
#EDW rMWL and rChangeMWL used to be used to calculate rUpdatedMWL
#EDW this SLR adjustment is now included in the Ecohydro output dataset and is no longer needed here
#EDW        rMWL = Raster(MWL)
#EDW        rChangeMWL = Raster(ChangeMWL)  #EDW no longer calculating change in MWL here
        rUpdatedMWL = Raster(MWL)
        rTopo = Raster(TopoBathy)
        rLW = Raster(LandWater)
        rLULC = Raster(LULC)
        rSalinity = Raster(Salinity)
        rAveSalinity = Raster(ASalinity)
        rBI = Raster(BI_Mask)
        #-------------------------------------------------------------------------
        
        #DEFINE INUNDATION THRESHOLD CONSTANTS
        Z = 1.96
        B0 = 0.0058
        B1 = -0.00207
        B2 = 0.0809
        B3 = 0.0892
        B4 = -0.19
        
        #COMPUTE RASTERS FOR NEW INUNDATIONS THRESHOLD
        rMuDepth = B0+B1*rAveSalinity
        rSigDepth = B2+B3*Exp(B4*rAveSalinity)
        rDepthThreshold = rMuDepth+Z*rSigDepth
        
#EDW no longer using ChangeMWL in SLR calcs (this was remnant of 25-year version of WM.py)    
        ##------------------------------------------------------------------------
        #UPDATE MEAN WATER LEVEL
        #
#EDW        msg0 = "--updating mean water level"
#EDW        print msg0
#EDW        arcpy.AddMessage(msg0)
#EDW        rUpdatedMWL = rMWL + rChangeMWL
#EDW        rUpdatedMWL.save(SLR_MWL)
        ##------------------------------------------------------------------------
    
        ##------------------------------------------------------------------------
        #MARSH COLLAPSE SALINITY STRESS (LAND LOSS)
        #
        msg0 = "--marsh collapse salinity stress"
        print msg0
#        arcpy.AddMessage(msg0)
        #if Land(LW=1) AND LULC=1 AND (Salinity > 5.5) AND (MWL >= RelativeElevation)
        # then land lost(change to water)
        outRas0 = Con((rLW == 1) & (rLULC == 1) & (rSalinity > tSalinity1) & (rUpdatedMWL >= rTopo), 3, 0)
##        n = r"%s\\SAL1_%s" % (Intermediate_Files_GDB, CurrentYear)
##        outRas0.save(n)
        #
        #if Land(LW=1) AND LULC=2 AND (Salinity > 7.0) AND MWL>=RelativeElevation
        # then land lost(change to water)
        #outRas1 = Con((rLW == 1) & (rLULC == 2) & (rSalinity > tSalinity2) & (rUpdatedMWL >= rTopo), 3, 0)
        #
        ##------------------------------------------------------------------------

        ##------------------------------------------------------------------------
        #MARSH COLLAPSE INUNDATION STRESS (LAND LOSS)
        #
        msg0 = "--marsh collapse inundation stress"
        print msg0		
        
        #if Land(LW=1) AND LULC=(2,3,4,5) AND ((MWL-0.3436) > RelativeElevation)
        # then land lost(change to water)
        # outRas1 = Con(((rLW == 1) & (rLULC in [2,3,4,5])) & ((rUpdatedMWL - rDepthThreshold) > rTopo), 3, 0)		
        # outRas1 = Con(((rLW == 1) & ((rLULC == 2) or (rLULC == 3) or (rLULC == 4) or (rLULC == 5))) & ((rUpdatedMWL - rDepthThreshold) > rTopo), 3, 0)	
        outRas1 = Con(((rLW == 1) & ((rLULC == 2) | (rLULC == 3) | (rLULC == 4) | (rLULC == 5))) & ((rUpdatedMWL - rDepthThreshold) > rTopo), 3, 0)
        
        if elapsedyear != 1:
            #msg0 = "--marsh collapse inundation stress"
            #print msg0
            rPrevMWL = Raster(PreviousMWL)

            #if Land(LW=1) AND LULC=3 AND ((MWL-0.3436) > RelativeElevation) - for both current and previous year
            # then land lost(change to water)
            #outRas2 = Con((rLW == 1) & (rLULC == 3) & ((rUpdatedMWL - tMWL3) > rTopo) & ((rPrevMWL - tMWL3) > rTopo), 3, 0)      

            #if Land(LW=1) AND LULC=4 AND ((MWL-0.2278) > RelativeElevation) - for both current and previous year
            # then land lost(change to water)
            #outRas3 = Con((rLW == 1) & (rLULC == 4) & ((rUpdatedMWL - tMWL4) > rTopo) & ((rPrevMWL - tMWL4) > rTopo), 3, 0)        

            #if Land(LW=1) AND LULC=5 AND ((MWL-0.2050) > RelativeElevation) - for both current and previous year
            # then land lost(change to water)
            #outRas4 = Con((rLW == 1) & (rLULC == 5) & ((rUpdatedMWL - tMWL5) > rTopo) & ((rPrevMWL - tMWL5) > rTopo), 3, 0)        

            ##------------------------------------------------------------------------
            
            ##------------------------------------------------------------------------
            #LAND BUILDING (LAND GAIN)
            #
            msg0 = "--land building"
            print msg0
#           arcpy.AddMessage(msg0)
            #if Water (LW=2) AND not in barrier island profile footprint (BI = 0) AND (RelativeElevation > (MWL + 0.1)) - for both current and previous year
            # then land built (change water to land)
            outRas5 = Con((rLW == 2) & (rBI <> 1) & (rTopo > (rUpdatedMWL + tMWL6)) & (rTopo > (rPrevMWL + tMWL6) ), 4, 0)

            if BareGroundCollapse <> -9999:
            # if Land(LW=1) AND is bare ground two years in a row, collapse it if it is inundated more than the threshold value provided in the input (BareGroundCollapse)
                rPrevLULC = Raster(PreviousLULC)
                rLULCmask = Raster(NoUpdateMask)
                outRas6 = Con((rLW == 1) & (rLULC == 7) & (rPrevLULC == 7) & (rLULCmask <> 1) & ((rUpdatedMWL - BareGroundCollapse) > rTopo), 3 ,0)

            #
            ##------------------------------------------------------------------------
            
            ##------------------------------------------------------------------------
            #ASSEMBLE LAND, WATER, LOSS, GAIN INTO A SINGLE RASTER
            # 1=land 2=water 3=land loss 4=land gain
        #
            msg0 = "--assembling output"
            print msg0
#            arcpy.AddMessage(msg0)
            if BareGroundCollapse <> -9999:
                rLossGain = CellStatistics([rLW, outRas0, outRas1, outRas5,outRas6], "MAXIMUM", "DATA")
            else:
                rLossGain = CellStatistics([rLW, outRas0, outRas1, outRas5], "MAXIMUM", "DATA")
        
        else:
            msg0 = "--skipping inundation stress and land building for first year"
            print msg0
            msg0 = "--assembling output"
            print msg0
#            arcpy.AddMessage(msg0)
            rLossGain = CellStatistics([rLW, outRas0, outRas1], "MAXIMUM", "DATA")
        
        
        #rLossGain.save(SLR_LW_1234)
        arcpy.CopyRaster_management(rLossGain, SLR_LW_1234, "#", "#", "#", "#", "NONE", "4_BIT", "#", "#")


        #                                  
        ##------------------------------------------------------------------------

        ##------------------------------------------------------------------------                                  
        #UPDATE LAND/WATER RASTER WITH LOSS/GAIN
        # 1=land 2=water
        #
        arcpy.env.extent = LandWater
        updatedLWRaster = Reclassify(SLR_LW_1234, "VALUE", RemapValue([[1,1],[2,2],[3,2],[4,1],[5,5]]))
        rNewLW = Con(IsNull(updatedLWRaster), rLW, updatedLWRaster)

        print '--updating land/water in barrier island region based on MWL instead of thresholds'
        #BIMODE_DEMclip = r"%s\\%sBIMODE_DEM_clipped" % (Intermediate_Files_GDB,nprefix)
        BIMODE_DEM_mask = r'%s\\bi_dem_mask' % (Input_GDB)
        always_water_mask = r'%s\\BH_prj_LWmsk' % (Input_GDB) 
        
        rBIMODE_mask = Raster(BIMODE_DEM_mask)
        rBIMODE_passes = Raster(always_water_mask)
        
        rNewLW_bi = Con(rBIMODE_mask == 0, rNewLW, Con(rBIMODE_passes == 1, 2, Con(rTopo > rUpdatedMWL, 1, 2))) 

        arcpy.CopyRaster_management(rNewLW_bi, SLR_LW_12, "#", "#", "#", "#", "NONE", "4_BIT", "#", "#")
        #updatedLWRaster.save(SLR_LW_12)
        arcpy.env.extent = "DEFAULT"
        #
        ##------------------------------------------------------------------------

        #cleanup
#EDW 	#no longer changing MWL in this function - remove from list, also rMWL is not rUpdatedMWL        
#EDW        del rMWL, rChangeMWL, rTopo, rLW, rLULC, rSalinity  
        del rUpdatedMWL, rTopo, rLW, rLULC, rSalinity
        del outRas0, outRas1, rLossGain, rNewLW 
        
        if elapsedyear != 1:
            del outRas5
        
        
        e = time.clock()
        ProcTimeMin = round((e-s)/60,2)
        
        msg0 = "--total runtime: %s minutes" % (ProcTimeMin)
        msg1 = "COMPLETED SEA LEVEL RISE"
        print msg0
        print msg1
#        arcpy.AddMessage(msg0)
#        arcpy.AddMessage(msg1)
        
#EDW        #updated land/water, updated mwl
        #updated land/water
        return([SLR_LW_12, SLR_LW_1234]) 

#EDW        return([SLR_LW_12, SLR_MWL, SLR_LW_1234]) #EDW no longer changing MWL in this function - remove from list
   
    except Exception, e:
        # If an error occurred, print line number and error message
        import traceback, sys
        tb = sys.exc_info()[2]
        msg1 = "Line %i" % tb.tb_lineno
        msg2 = e.message
#        arcpy.AddWarning(msg1)
#        arcpy.AddWarning(msg2)
        print msg1
        print msg2
        return()

def SaveUpdated_LandWater_TOPO(LandWater, TopoBathy, LULCType, CurrentMWL,CurrentSalinity,AveSalinity,extraText, outType, elapsedyear,summaryflag,zones,zonesID,outputmaskfine,outputmaskcourse):

    try:
        msg0 = "\nSAVING UPDATED LANDWATER AND TOPOBATHYMETRIC DATA"
        print msg0
 #       arcpy.AddMessage(msg0)
        
        s = time.clock()

        arcpy.env.workspace = Temp_Files_GDB
        arcpy.env.scratchWorkspace = Temp_Files_Path
        arcpy.env.scratchFolder
        arcpy.env.scratchGDB

        rOutMask = Raster(outputmaskfine)
        rOutMaskCourse = Raster(outputmaskcourse)
        rLW = Raster(LandWater)
        rLULC = Raster(LULCType)

        
        ##------------------------------------------------------------------------
        ## SUMMARIZE LAND/WATER AND LULC AREAS BY ZONES
        ##------------------------------------------------------------------------
        if summaryflag == 1:
            try:
                LandTable_zones = r"%s\\LandWaterFloatantArea_zones_%02d" % (Temp_Files_GDB, elapsedyear)
                LandTable_zones_csv =r"%s\\%sLWFzn.csv" % (Deliverable_Files_Path, nprefix)
            
                print "--calculating land,water,floatant areas for ecoregion/marsh type zones"
                arcpy.sa.TabulateArea(zones,zonesID,rLW,"VALUE",LandTable_zones,ProcessingCellSize)
                LWfields = [str(zonesID),'VALUE_1','VALUE_2','VALUE_5']
                LW_areatable = arcpy.da.TableToNumPyArray(LandTable_zones,LWfields)
            
                print "--saving land, water, floatant areas csv file to Deliverables folder"
                LWf = ['%s','%.2f','%.2f','%.2f']
                LWh = 'EcoRegion,LandArea_m2,WaterArea_m2,FloatantArea_m2'
                np.savetxt(LandTable_zones_csv,LW_areatable,delimiter=',',fmt=LWf,header=LWh,comments='')
            
                del LW_areatable
            
            except:
                print "--ERROR IN TABULATION OF LW AREAS BY ZONE"

            try:
                LULCTable_zones = r"%s\\LULC_Area_zones_%02d" % (Temp_Files_GDB, elapsedyear)
                LULCTable_zones_csv = r"%s\\%sVgTzn.csv" % (Deliverable_Files_Path, nprefix)
        
                print "--calculating LULC areas for ecoregion/marsh type zones"
                arcpy.sa.TabulateArea(zones,zonesID,rLULC,"VALUE",LULCTable_zones,ProcessingCellSize)
                LULCfields = [str(zonesID),'VALUE_1','VALUE_2','VALUE_3','VALUE_4','VALUE_5','VALUE_6','VALUE_7']
                LULC_areatable = arcpy.da.TableToNumPyArray(LULCTable_zones,LULCfields)
            
                print "--saving LULC areas csv file to Deliverables folder"
                LULCf = ['%s','%.2f','%.2f','%.2f','%.2f','%.2f','%.2f','%.2f']
                LULCh = 'EcoRegion,FreshForArea_m2,FreshHerbArea_m2,IntHerbArea_m2,BrackHerbArea_m2,SalHerbArea_m2,WaterArea_m2,UplandDevArea_m2'
                np.savetxt(LULCTable_zones_csv,LULC_areatable,delimiter=',',fmt=LULCf,header=LULCh,comments='')
            
                del LULC_areatable    
            
            except:
                msg0 = "--ERROR IN TABULATION OF LULC AREAS BY ZONE"
                print msg0   



        
        ##------------------------------------------------------------------------
        #set the out filename, and write output
        #
        TwoDigitYr = str(CurrentYear)[2:4]
        
        #Landwater
        msg0 = "--creating %s%slandw%s" % (oprefix, extraText, outType)
        print msg0
        OutLW = r"%s\\%s%slandw%s" % (Deliverable_Files_Path, oprefix, extraText,outType)
        rOutLW = rLW*rOutMask
        rOutLW.save(OutLW)

        #Vegetation type
        msg0 = "--creating %s%svgtyp%s" % (oprefix,  extraText,outType)
        print msg0
        OutVegType = r"%s\\%s%svgtyp%s" % (Deliverable_Files_Path, oprefix, extraText,outType)
        rOutVegType = rLULC*rOutMask
        rOutVegType.save(OutVegType)

        
#        arcpy.CopyRaster_management(LandWater, OutLW, "#", "#", "#", "#", "NONE", "8_BIT_UNSIGNED", "#", "#")

#do_not_save_topo#        #Topo
#do_not_save_topo#        msg0 = "--creating %s%sdem30%s" % (oprefix,  extraText,outType)
#do_not_save_topo#        print msg0
#do_not_save_topo#        OutTopo = r"%s\\%s%sdem30%s" % (Deliverable_Files_Path, oprefix, extraText, outType)
#do_not_save_topo#        rTOPO = Raster(TopoBathy)
#do_not_save_topo#        rOutTopo = rTOPO*rOutMask
#do_not_save_topo#        rOutTopo.save(OutTopo)
#do_not_save_topo#
#        arcpy.CopyRaster_management(TopoBathy, OutTopo)

        #Mean Water Level
        msg0 = "--creating %s%smwl%s" % (oprefix,  extraText,outType)
        print msg0
        OutMWL = r"%s\\%s%sMWL%s" % (Deliverable_Files_Path, oprefix, extraText, outType)
        rMWL = Raster(CurrentMWL)
        rOutMWL = rMWL*rOutMaskCourse
        rOutMWL.save(OutMWL)

        #Mean Salinity
        msg0 = "--creating %s%ssalav%s" % (oprefix,  extraText,outType)
        print msg0
        OutSalAv= r"%s\\%s%ssalav%s" % (Deliverable_Files_Path, oprefix, extraText, outType)
        rSalAv = Raster(AveSalinity)
        rOutSalAv = rSalAv*rOutMaskCourse
        rOutSalAv.save(OutSalAv)

        #Max Salinity
        msg0 = "--creating %s%ssalmx%s" % (oprefix,  extraText,outType)
        print msg0
        OutSalMax= r"%s\\%s%ssalmx%s" % (Deliverable_Files_Path, oprefix, extraText, outType)
        rSalMax = Raster(CurrentSalinity)
        rOutSalMax = rSalMax*rOutMaskCourse
        rOutSalMax.save(OutSalMax)

        #Accretion Raster
        msg0 = "--creating %s%saccmm%s" % (oprefix,  extraText,outType)
        print msg0
        OutAccr= r"%s\\%s%saccmm%s" % (Deliverable_Files_Path, oprefix, extraText, outType)
        
        SED_ACC = r"%s\\%ssed_accr_m" % (Intermediate_Files_GDB, nprefix)
        rAccr = Raster(SED_ACC)
        rAccr_int_mm = Int(Con(rOutMask == 1, Con(rAccr > 0, 1000*rAccr,0),""))
        arcpy.CopyRaster_management(rAccr_int_mm,OutAccr,"#", "#", "-9999", "NONE", "NONE", "16_BIT_SIGNED", "NONE", "NONE")
        
       
       
        e = time.clock()
        ProcTimeMin = round((e-s)/60,2)

        msg0 = "--total runtime: %s minutes" % (ProcTimeMin)
        msg1 = "COMPLETED SAVING UPDATED LANDWATER AND TOPOBATHYMETRIC DATA"
        print msg0
        print msg1
        
        return([LandWater,TopoBathy,LULCType])
#EDW    return()
    except Exception, e:
        # If an error occurred, print line number and error message
        import traceback, sys
        tb = sys.exc_info()[2]
        msg1 = "Line %i" % tb.tb_lineno
        msg2 = e.message
 #       arcpy.AddWarning(msg1)
 #       arcpy.AddWarning(msg2)
        print msg1
        print msg2
        return([LandWater,TopoBathy,LULCType])
#EDW    return()

def CreatePercentLand(LandWater, ZonalRaster, zoneField, zoneCellSize, processingCellsize, outType):

    try:

        msg0 = "\nCREATING PERCENT LAND"
        print msg0
#        arcpy.AddMessage(msg0)
        
        s = time.clock()
        arcpy.env.extent = ZonalRaster
        
        arcpy.env.workspace = Temp_Files_GDB
        arcpy.env.scratchWorkspace = Temp_Files_Path
        arcpy.env.scratchFolder
        arcpy.env.scratchGDB
        ##------------------------------------------------------------------------
        #set the out filename
        TwoDigitYr = str(CurrentYear)[2:4]
        outPCLRaster = r"%s\\%sPCL_500%s" % (Deliverable_Files_Path, nprefix, outType)
        #
        ##------------------------------------------------------------------------

        ##------------------------------------------------------------------------
        #
        msg0 = "--Processing %s" % (os.path.split(LandWater)[1])
 #       arcpy.AddMessage(msg0)
        print msg0        
        
        
        rLNW = Raster(LandWater)
        #outRas1 = Reclassify(rLNW, "VALUE", RemapValue([[1,1],[2,0]]))
        outRas1 = Con((rLNW == 1), 1, 0)
        
        rZonalRas = Raster(ZonalRaster)
        arcpy.env.cellSize = processingCellsize
        rPCL = ZonalStatistics(ZonalRaster, zoneField, outRas1, "SUM", "DATA") / 25

        #resample back to zonal grid resolution
        arcpy.env.snapRaster = ZonalRaster
        outTemp = r"%s\\PCL_RESAMPLE" % (Temp_Files_GDB)
        arcpy.Resample_management(rPCL, outTemp, zoneCellSize, "NEAREST")

        rTemp = Raster(outTemp)
        
        #be sure all cells from zonal have values
        arcpy.env.cellSize = zoneCellSize
        rPCL2 = Con((IsNull(rTemp)) & ~(IsNull(ZonalRaster)), 0, rTemp)
        rPCL2.save(outPCLRaster)
        #
        ##------------------------------------------------------------------------
        
        del rLNW, outRas1, rPCL, rTemp, rPCL2   
        
        e = time.clock()
        ProcTimeMin = round((e-s)/60,2)

        msg0 = "--total runtime: %s" % (ProcTimeMin)
        msg1 = "COMPLETED CREATING PERCENT LAND"
        print msg0
        print msg1
#        arcpy.AddMessage(msg0)
#        arcpy.AddMessage(msg1)
        
        return()
    
    except Exception, e:
        # If an error occurred, print line number and error message
        import traceback, sys
        tb = sys.exc_info()[2]
        msg1 = "Line %i" % tb.tb_lineno
        msg2 = e.message
#        arcpy.AddWarning(msg1)
#        arcpy.AddWarning(msg2)
        print msg1
        print msg2
        return()
    
def CreateAverageElevation(TopoBathy, ZonalRaster, zoneField, zoneCellSize, processingCellsize, outType):
    try:
        
        msg0 = "\nCREATING AVERAGE ELEVATION"
        print msg0
#        arcpy.AddMessage(msg0)
        
        s = time.clock()
        arcpy.env.cellSize = processingCellsize
        arcpy.env.extent = ZonalRaster
        arcpy.env.snapRaster = ZonalRaster
        arcpy.env.workspace = Temp_Files_GDB
        arcpy.env.scratchWorkspace = Temp_Files_Path
        arcpy.env.scratchFolder
        arcpy.env.scratchGDB
        ##------------------------------------------------------------------------
        #set the out filename
        TwoDigitYr = str(CurrentYear)[2:4]
        outELVRaster = r"%s\\%sELV_500%s" % (Deliverable_Files_Path, nprefix, outType)
        #
        ##------------------------------------------------------------------------

        ##------------------------------------------------------------------------
        #
        msg0 = "--Processing %s" % (os.path.split(TopoBathy)[1])
#        arcpy.AddMessage(msg0)
        print msg0
        
        rTOPO = Raster(TopoBathy)
        rZonal = Raster(ZonalRaster)
        rZS = ZonalStatistics(rZonal, zoneField, rTOPO, "MEAN", "DATA")

        #resample back to desired output
##        outTemp = r"%s\\PSW_RESAMPLE" % (Temp_Files_GDB)
        arcpy.Resample_management(rZS, outELVRaster, zoneCellSize, "NEAREST")

##        rTemp = Raster(outTemp)
##        #be sure all cells from zonal have values
##        arcpy.env.cellSize = zoneCellSize
##        rPSW2 = Con((IsNull(rTemp)) & ~(IsNull(ZonalRaster)), -99, rTemp)
##        rPSW2.save(outELVRaster)
        
        arcpy.env.cellSize = processingCellsize
        #
        ##------------------------------------------------------------------------
            
        #cleanup
        del rTOPO, rZonal, rZS
        
        e = time.clock()
        ProcTimeMin = round((e-s)/60,2)

        msg0 = "--total runtime: %s" % (ProcTimeMin)
        msg1 = "COMPLETED CREATING AVERAGE ELEVATION"
        print msg0
        print msg1
#        arcpy.AddMessage(msg0)
 #       arcpy.AddMessage(msg1)
        
        return()

    except Exception, e:
        # If an error occurred, print line number and error message
        import traceback, sys
        tb = sys.exc_info()[2]
        msg1 = "Line %i" % tb.tb_lineno
        msg2 = e.message
#        arcpy.AddWarning(msg1)
#        arcpy.AddWarning(msg2)
        print msg1
        print msg2
        return()

def CreatePercentShallowWater(LandWater, TopoBathy, MWL, ZonalRaster, zoneField, zoneCellSize, processingCellsize, lowWaterThreshold, outType):
    try:
        
        msg0 = "\nCREATING PERCENT SHALLOW WATER"
        print msg0
 #       arcpy.AddMessage(msg0)
        
        s = time.clock()
        oCellSize = arcpy.env.cellSize
        arcpy.env.cellSize = processingCellsize
        arcpy.env.extent = ZonalRaster
        arcpy.env.snapRaster = ZonalRaster
        arcpy.env.workspace = Temp_Files_GDB
        arcpy.env.scratchWorkspace = Temp_Files_Path
        arcpy.env.scratchFolder
        arcpy.env.scratchGDB
        ##------------------------------------------------------------------------
        #set the out filename
        TwoDigitYr = str(CurrentYear)[2:4]
        outPSWRaster = r"%s\\%sPSW_500%s" % (Deliverable_Files_Path, nprefix, outType)
        #
        ##------------------------------------------------------------------------

        ##------------------------------------------------------------------------
        
        msg0 = "--Processing %s" % (os.path.split(MWL)[1])
        print msg0
 #       arcpy.AddMessage(msg0)

        rLW = Raster(LandWater)
        rTOPO = Raster(TopoBathy)
        rMWL = Raster(MWL)

        outRas1 = Con((rLW == 2) & (rMWL - rTOPO < lowWaterThreshold), 1, 0)

        #calc area of PSW
        rZonalRas = Raster(ZonalRaster)
        arcpy.env.cellSize = processingCellsize
        rPSW = ZonalStatistics(rZonalRas, zoneField, outRas1, "SUM", "DATA") / 25

        #resample back to zonal grid resolution
        arcpy.env.snapRaster = ZonalRaster
        outTemp = r"%s\\PSW_RESAMPLE" % (Temp_Files_GDB)
        arcpy.Resample_management(rPSW, outTemp, zoneCellSize, "NEAREST")

        rTemp = Raster(outTemp)
        
        #be sure all cells from zonal have values
        arcpy.env.cellSize = zoneCellSize
        rPSW2 = Con((IsNull(rTemp)) & ~(IsNull(ZonalRaster)), 0, rTemp)
        rPSW2.save(outPSWRaster)
       
        ##------------------------------------------------------------------------

        del rLW, rTOPO, rMWL, outRas1, rZonalRas, rPSW, rPSW2
        
        
        e = time.clock()
        ProcTimeMin = round((e-s)/60,2)

        msg0 = "--total runtime: %s" % (ProcTimeMin)
        msg1 = "COMPLETED CREATING PERCENT SHALLOW WATER"
        print msg0
        print msg1

        
        return()

    except Exception, e:
        # If an error occurred, print line number and error message
        import traceback, sys
        tb = sys.exc_info()[2]
        msg1 = "Line %i" % tb.tb_lineno
        msg2 = e.message
        print msg1
        print msg2
        return()    

def CalculateEcohydroAttributes(CompartmentPoly,CompartmentPolyID_Field,GridPoly,GridPolyID_Field,CurrentTOPO,CurrentLULC,CurrentLW,CurrentYear,AssumedAreas,EHtemp_path,HSI_dir,ngrids,NavChan,NavChanID,elapsedyear):
## This function calculates various attributes needed by the Hydrology model.
## The LULC raster is then used to determine the percentage of each hydro compartment that is upland and water.
## The LULC raster and compartment polygons are used to clip the topobathy DEM in order to determine average marsh and water bed elevations.
## The Tabulate Area function will have results only for ICM compartments that within the spatial extents of the raster datasets
## The AssumedAreas array, which is generated from an input csv file MUST have data for ALL ICM copmartments (with values of 0 for compartments that are completely within the raster extents)
## The AssumedAreas array will add the constant area of upland and open water areas that lie outside of the LULC/LW raster data extents
## If a compartment ID is excluded from the table generated by ArcPY, the missing compartment ICM_ID will be added as a key with the default areas contained in the AssumedAreas array
##
#################################################################################
##        NOTE ON ELEVATION VALUES WHERE FLOATING MARSH IS PRESENT
#################################################################################
## Live floating marsh is added to the Fresh Herbaceous LULC type in this model.
## Dead floating marsh is added to Water LULC type in this model.
## Floating marsh is therefore included in the Marsh landtype/elevation data
## that is passed to the Hydro model. Water area/storage/volume underneath
## the floating marsh is not included in the water balance in Hydro.
##
##        # LULC 1 = Fresh Forested         
##        # LULC 2 = Fresh herbaceous       
##        # LULC 3 = Intermediate herbaceous
##        # LULC 4 = Brackish herbaceous    
##        # LULC 5 = Salt herbaceous        
##        # LULC 6 = Water                  
##        # LULC 7 = Upland          
#################################################################################
    try:
        s = time.clock()
        
        arcpy.env.workspace = Intermediate_Files_GDB
        arcpy.env.scratchWorkspace = Temp_Files_Path
        arcpy.env.scratchFolder
        arcpy.env.scratchGDB
        
        print "\nCALCULATING NEW ATTRIBUTES FOR HYDRO AND HSI ROUTINES."
        
        # set variable containing number of hydro compartments - this will match the number of ICM ID compartments in AssumedAreas
        ncomps = len(AssumedAreas)        
        
        print '--Generating updated Edge raster'
        rLW = Raster(CurrentLW)
        landvalue = 1 #value of Land in CurrentLW
        LandShrink = Shrink(rLW,1,landvalue)
        Edge_name = r"%s\\%sedge" % (Intermediate_Files_GDB,nprefix)
        Edge = Con((LandShrink + rLW == 3),1,0) #LandShrink+rLW results:  2=land (land in both,1+1), 3=edge(water that was land before shrink 2+1), 4=water (water that remained water, 2+2),6=flotant (land that bordered flotant, 1+5), 10=flotant(flotant that remained flotant,5+5)
        Edge.save(Edge_name)
                        
        # sum area of land and water in each ICM compartment and save to numpy array
        print '--Accumulating area of each LULC type per hydro compartment'
        zone = CompartmentPoly
        zone_field = CompartmentPolyID_Field 
        data = CurrentLULC
        data_field = 'Value'
        LULCtablename = 'Compartment_LULC_Areas'
        
        arcpy.sa.TabulateArea(zone,zone_field,data,data_field,LULCtablename,ProcessingCellSize)
        LULCfields = [str(zone_field),'Value_1','Value_2','Value_3','Value_4','Value_5','Value_6','Value_7']
        LULCtable = arcpy.da.TableToNumPyArray(LULCtablename,LULCfields)

        # sum area of flotant marsh in each ICM compartment and save to numpy array
        print '--Accumulating area of flotant marsh per hydro compartment'
        zone = CompartmentPoly
        zone_field = CompartmentPolyID_Field 
        data = CurrentLW
        data_field = 'Value'
        LWFtablename = 'LandWaterFlotant_Areas'

        arcpy.sa.TabulateArea(zone,zone_field,data,data_field,LWFtablename,ProcessingCellSize)
        LWFfields = [str(zone_field),'Value_1','Value_2','Value_5']
        LWFtable = arcpy.da.TableToNumPyArray(LWFtablename,LWFfields)



## create blank dictionaries for land, wetland and water areas
        WetlandAreaInExtent={}
        WaterAreaInExtent={}
        UplandAreaInExtent={}
        FlotantAreaInExtent={}
        WaterArea={}
        UplandArea={}
        WetlandArea={}
        FlotantArea={}
## key for the Land and Water dictionaries will be the BoxID - there will only be keys for polygons that are within the geospatial extent of the LULC file
        for row in LULCtable:
            boxIDinExt = row[0] 
            WetlandAreaInExtent[boxIDinExt] = row[1]+row[2]+row[3]+row[4]+row[5]
            WaterAreaInExtent[boxIDinExt] = row[6]
            UplandAreaInExtent[boxIDinExt] = row[7]
## read in LWF table and update dictionary with any compartments that are within the LW extent but are outside of the LULC extent        
        for row in LWFtable:
            boxIDinExt = row[0]
            # check to see if Water Area is 0 in LULC table, if it is, add water area from LWF table
            if boxIDinExt in WaterAreaInExtent.keys():
                if WaterAreaInExtent[boxIDinExt] == 0:
                    WaterAreaInExtent[boxIDinExt] = row[2]
            else: # if boxID is in the LWF table but not the LULC table, it will assign all land as upland and a
                WaterAreaInExtent[boxIDinExt] = row[2]
                UplandAreaInExtent[boxIDinExt] = row[1]
            FlotantAreaInExtent[boxIDinExt] = row[3]
            
        print '--Reading any open water and upland areas outside of geospatial data domain'
        ## key for the WaterArea is ICM_ID value which is the first column in the AssumedAreas table read in
        ## this will have a value for all ICM boxes/comparements in input table used to generate AssumedAreas, not just those within the LW extent
        ## it is assumed that only water or upland can be outside of geospatial extent - all wetland area must be determined from LULC data
        for row in AssumedAreas:
            boxIDall = row[0]
            WaterArea[boxIDall] = row[1]
            UplandArea[boxIDall] = row[2]
            WetlandArea[boxIDall] = 0.0
            FlotantArea[boxIDall] = 0.0
        
        ## combine areas for compartments that have areas inside and outside of LULC extent
        for boxID in WaterAreaInExtent.keys():
            WaterArea[boxID] += WaterAreaInExtent[boxID]
        
        for boxID in WetlandAreaInExtent.keys():
            WetlandArea[boxID] += WetlandAreaInExtent[boxID]
        
        for boxID in UplandAreaInExtent.keys():
            UplandArea[boxID] += UplandAreaInExtent[boxID]
            
        for boxID in FlotantAreaInExtent.keys():
            FlotantArea[boxID] += FlotantAreaInExtent[boxID]
            
        print '--Calculating percent land and percent water in each compartment'
        ## create dictionaries for percent land and percent upland - key will be ICM_ID - fill with -9999 if area from above calculations equals 0

        PctWater={}     
        PctUpland={}
        for boxID in WaterArea.keys():
            area = WetlandArea[boxID]+UplandArea[boxID]+WaterArea[boxID]+FlotantArea[boxID]
            if area != 0:
                PctWater[boxID] = WaterArea[boxID]/area
                PctUpland[boxID] = UplandArea[boxID]/area
            else:
                PctWater[boxID] = -9999
                PctUpland[boxID] = -9999
                print '  -Area calculated as zero for compartment %s - set to -9999' % boxID            
        
        ## save PctWater with BoxIDs to csv file
        PctWaterFile = os.path.normpath(r'%s\\PctWater_%s.csv' % (EHtemp_path,CurrentYear)) # this must match name set in ICM (when Ecohydro is run) with the exception of CurrentYear here instead of (CurrentYear-1)
        with open(PctWaterFile,'w') as outfile:
            writer= csv.writer(outfile,lineterminator='\n')
            for key, value in PctWater.items():
                writer.writerow([key,value])
        
        ## save PctUpland with BoxIDs to csv file
        PctUplandFile = os.path.normpath(r'%s\\PctUpland_%s.csv' % (EHtemp_path,CurrentYear)) # this must match name set in ICM (when Ecohydro is run) with the exception of CurrentYear here instead of (CurrentYear-1)
        with open(PctUplandFile,'w') as outfile:
            writer= csv.writer(outfile,lineterminator='\n')
            for key, value in PctUpland.items():
                writer.writerow([key,value])
                
## Calculate new average elevations for compartments - split for OW and Marsh areas
## This uses the 7-class LULC data, which considers floating marsh as water
## *See note at start of function regarding floating marsh elevations.
        ## set filenames for data that is saved in Intermediate_Files_GDB (set with arcpy.env.workspace)
        OWelev = '%swelev' % nprefix
        Melev = '%smelev' % nprefix
        OWelevTable = '%s_tbl' % OWelev
        MelevTable = '%s_tbl' % Melev
        
        ## check LULC value and set elevation for water cells to CurrentTOPO, otherwise, elev set to NoData ("")
        print "--Creating open water bed elevation raster"
        Con(CurrentLULC,CurrentTOPO,"","VALUE = 6").save(OWelev)
        
        ## check LULC value and set elevation for all marsh-type cells to CurrentTOPO, otherwise, elev set to NoData ("") - LULC 7 = upland, LULC 6 = water
        print "--Creating marsh elevation raster"
        Con(CurrentLULC,CurrentTOPO,"","VALUE < 6").save(Melev)
        
        ## create table (in geodatabase) of mean bed elevation for each compartment
        print "--Calculating new average open water bed elevation in each hydro compartment"
        ZonalStatisticsAsTable(zone,zone_field,OWelev,OWelevTable,"DATA","MEAN")
        
        ## create table (in geodatabase) of mean land elevation for each compartment
        print "--Calculating new average marsh elevation in each hydro compartment"
        ZonalStatisticsAsTable(zone,zone_field,Melev,MelevTable,"DATA","MEAN")

        ## save bed elevation table as numpy array - first column is zone_field (e.g. compartment ID #)
        tblfnames = [zone_field,'MEAN']
        OWelevArr = arcpy.da.TableToNumPyArray(OWelevTable,tblfnames)
        
        ## convert bed elevation array to dictionary where compartment ID is the key
        OWelevdict = {}
        for nn in range(0,len(OWelevArr)):
            cmpt = OWelevArr[nn][0]
            OWelevdict[cmpt] = OWelevArr[nn][1]
            
        ## save land elevation table as numpy array - first column is zone_field (e.g. compartment ID #)
        MelevArr = arcpy.da.TableToNumPyArray(MelevTable,tblfnames)
        
        ## convert land elevation array to dictionary where compartment ID is the key
        Melevdict = {}
        for nn in range(0,len(MelevArr)):
            cmpt = MelevArr[nn][0]
            Melevdict[cmpt] = MelevArr[nn][1]
        
        ## create table (in geodatabase) of edge area in each compartment
        print "--Calculating new area of edge in each hydro compartment"
        zone = CompartmentPoly
        zone_field = CompartmentPolyID_Field 
        data = Edge_name
        data_field = 'Value'
        EdgeAreaTable = 'Compartment_Edge_Area'
        arcpy.sa.TabulateArea(zone,zone_field,data,data_field,EdgeAreaTable,ProcessingCellSize)
        tablecolnames = [str(zone_field),'VALUE_1']
        EdgeArea = arcpy.da.TableToNumPyArray(EdgeAreaTable,tablecolnames)
        
        ## convert Edge Area array to dictionary where compartment ID is the key
        EdgeAreaDict ={}
        for r in range(0,len(EdgeArea)):
            cmpt = EdgeArea[r][0]
            EdgeAreaDict[cmpt] = EdgeArea[r][1]
                
        print '--Saving new attributes for hydro compartments to CSV file saved in Hydro temporary directory'    
        ## generate array for all compartment and save bed and land elevations - if ICM_ID value doesn't exist as key, fill with -9999
        compelevCSV = np.zeros((ncomps,4))
        for n in range(0,ncomps):
            c = n+1
            compelevCSV[n][0] = c
            try:
                compelevCSV[n][1] = OWelevdict[c]
            except:
                compelevCSV[n][1] = -9999
        # apply filter such that average marsh elevation can never be lower than average open water bed elevation (this would result in instabilities in Hydro model)
            try:
                compelevCSV[n][2] = max(Melevdict[c],OWelevdict[c])
            except:
                compelevCSV[n][2] = -9999
                
            try:
                compelevCSV[n][3] = EdgeAreaDict[c]
            except:
                compelevCSV[n][3] = -9999
        
        ## save land and bed elevation file for compartments to csv file - with header row      
        compelevCSV_EH = os.path.normpath(r'%s\\compelevs_end_%s.csv' % (EHtemp_path,CurrentYear)) # this must match name set in ICM (when Ecohydro is run) with the exception of CurrentYear here instead of (CurrentYear-1) 
        hh = 'ICM_ID,MEAN_BED_ELEV,MEAN_MARSH_ELEV,MARSH_EDGE_AREA'
        ff = ['%i','%.4f','%.4f','%.4f']
        
        ## save land elevation table as csv file to pass to ICM (saved in Ecohydro temp folder)
        np.savetxt(compelevCSV_EH,compelevCSV,delimiter=',',comments='',header=hh,)

        ## calculate average bed elevation of water in navigation channels
        print "--Calculating new average open water bed elevation in navigation channels"
        NavElevTable = 'OW_elev_NavChan_%s_tbl' % CurrentYear
        NavTblNames = [NavChanID,'MEAN']
        ZonalStatisticsAsTable(NavChan,NavChanID,OWelev,NavElevTable,"DATA","MEAN")
        
        print "--Saving %sFNCel.csv in Deliverables folder." % oprefix
        NavElev = arcpy.da.TableToNumPyArray(NavElevTable,NavTblNames)
        NavElevCSV = '%s\\%sFNCel.csv' % (Deliverable_Files_Path, oprefix)
        NavH = 'ZONE,MEAN_BED_ELEV'
        NavFmt = ['%s','%.4f']
        np.savetxt(NavElevCSV,NavElev,delimiter=',',fmt=NavFmt,header=NavH,comments='')
        
        



        print "--Calculating area of edge in each 500-m grid cell"
        data = Edge_name
        data_field = 'Value'
        EdgeAreaGridTable = 'Edge_Area_grid_%s_tbl' % CurrentYear
        arcpy.sa.TabulateArea(GridPoly,GridPolyID_Field,data,data_field,EdgeAreaGridTable,ProcessingCellSize)
        
        tfnames = [GridPolyID_Field,'VALUE_1']
        EdgeAreaGrid = arcpy.da.TableToNumPyArray(EdgeAreaGridTable,tfnames)
        ## only grid cells that overlap edge raster will have an area calculated
        ## for each grid that has an edge area, save in dictionary with gridID as key a
        EdgeAreadict = {}
        for n in range(0,len(EdgeAreaGrid)):
            grID = EdgeAreaGrid[n][0]
            EdgeAreadict[grID] = EdgeAreaGrid[n][1]
        

## Calculate new average elevations for 500-m grids - split for OW and Marsh areas              
## *See note at start of function regarding floating marsh elevations.
        bedelevtable = 'OW_elev_grid_%s_tbl' % CurrentYear
        melevtable = 'marsh_elev_grid_%s_tbl' % CurrentYear
        tnames = [GridPolyID_Field,'MEAN']
        
                
        ## create table (in geodatabase) of mean bed elevation for each grid
        print "--Calculating new average open water bed elevation in each 500-m grid cell"
        ZonalStatisticsAsTable(GridPoly,GridPolyID_Field,OWelev,bedelevtable,"DATA","MEAN")
        
        ## convert bed elevation table to numpy array
        bedelev = arcpy.da.TableToNumPyArray(bedelevtable,tnames)
        
        ## only grid cells that overlap bed elevation raster will have a statistic calculated
        ## for each grid that has a bed elevation zonal statistic, save in dictionary with gridID as key
        bedelevdict = {}
        for n in range(0,len(bedelev)):
            gID = bedelev[n][0]
            bedelevdict[gID] = bedelev[n][1]
        
        ## create table (in geodatabase) of mean land elevation for each grid
        print "--Calculating new average land elevation in each 500-m grid cell"
        ZonalStatisticsAsTable(GridPoly,GridPolyID_Field,Melev,melevtable,"DATA","MEAN")    
        landelev = arcpy.da.TableToNumPyArray(melevtable,tnames)
        
        ## only grid cells that overlap land elevation raster will have a statistic calculated
        ## for each grid that has a land elevation zonal statistic, save in dictionary with gridID as key
        landelevdict ={}
        for n in range(0,len(landelev)):
            g = landelev[n][0]
            landelevdict[g] = landelev[n][1] 
        
        ## create table (in geodatabase) of percent land in each grid cell
        print "--Calculating new percent land value in each 500-m grid cell"
        
        data = CurrentLULC
        data_field = 'Value'
        LULCgrtablename = 'Grid_LULC_Areas'
        print '  -Accumulating area of land use types and water per grid cell'
        
        # sum area of land and water in each grid cell and save to numpy array
        arcpy.sa.TabulateArea(GridPoly,GridPolyID_Field,data,data_field,LULCgrtablename,ProcessingCellSize)
        LULCfields = [str(GridPolyID_Field),'VALUE_1','VALUE_2','VALUE_3','VALUE_4','VALUE_5','VALUE_6','VALUE_7']
        LULCgrtable = arcpy.da.TableToNumPyArray(LULCgrtablename,LULCfields)
        
        # sum area of flotant marsh in each grid cell and save to numpy array 
        print '  -Accumulating area of floatant marsh per grid cell'
        data = CurrentLW
        data_field = 'Value'
        LWFgrtablename = 'Grid_LandWaterFlotant_Areas'
        arcpy.sa.TabulateArea(GridPoly,GridPolyID_Field,data,data_field,LWFgrtablename,ProcessingCellSize)
        LWFfields = [str(GridPolyID_Field),'VALUE_1','VALUE_2','VALUE_5']
        LWFgrtable = arcpy.da.TableToNumPyArray(LWFgrtablename,LWFfields)

        ## Generate some blank dictionaries
        WetlandAreaGrid={}
        LandAreaGrid={}
        WaterAreaGrid={}
        UplandAreaGrid={}
        FlotantAreaGrid={}

## key for the Land and Water dictionaries will be the GridID - there will only be keys for Grid cells that are within the extent of the LULC file
## keys for compartments outside of extent are added later with -9999 values

        for row in LULCgrtable:
            ggrr = row[0]
            WetlandAreaGrid[ggrr] = row[1]+row[2]+row[3]+row[4]+row[5]
#            WaterAreaGrid[ggrr] = row[6]
            UplandAreaGrid[ggrr] = row[7]
        for row in LWFgrtable:
            ggrr = row[0]
            LandAreaGrid[ggrr] = row[1]
            WaterAreaGrid[ggrr] = row[2]
            FlotantAreaGrid[ggrr] = row[3]

        ## generate array for all grid cells and save elevations and land percentages - if GridID doesn't exist as key, fill with -9999
        griddataCSV = np.zeros((ngrids,6))
        gridedgeCSV = np.zeros((ngrids,2))
        
        grid_bed_flag = 0
        grid_land_flag = 0
        grid_pct_flag = 0
        grid_edge_flag = 0
        
        for n in range(0,ngrids):
            gg = n+1
            griddataCSV[n][0] = gg
            gridedgeCSV[n][0] = gg
            # save bed elevation to 2nd column in grid array that will be written to CSV
            try:
                griddataCSV[n][1] = bedelevdict[gg]
            except:
                griddataCSV[n][1] = -9999
                grid_bed_flag += 1
            
            # apply filter such that average marsh elevation can never be lower than average open water bed elevation (this would result in instabilities in Hydro model)
            # save marsh elevation to 3rd column in grid array that will be written to CSV
            try:
                griddataCSV[n][2] = max(landelevdict[gg],bedelevdict[gg])
            except:
                griddataCSV[n][2] = -9999
                grid_land_flag += 1
            # calculate percent land of each grid cell - save to 4th column in grid array that will be written to CSV
            # use 0-100 min/max filter, since areas calculated from 30x30 m LULC cells will not exactly equal area of 500x500 cells
            try:
                plandgrid = max(0,min(100*(LandAreaGrid[gg])/(500.0*500.0),100))
                griddataCSV[n][3] = plandgrid
            except:
                plandgrid = 0.0
                griddataCSV[n][3] = -9999
                grid_pct_flag += 1
           # calculate percent wetland of each grid cell - save to 5th column in grid array that will be written to CSV
           # use 0-percent land min/max filter, since areas calculated from 30x30 m LULC cells will not exactly equal area of 500x500 cells
            try:
                griddataCSV[n][4] = max(0,min(100*WetlandAreaGrid[n]/(500.0*500.0),plandgrid))
            except:
                griddataCSV[n][4] = -9999
                grid_pct_flag += 1
           # calculate percent water of each grid cell - save to 6th column in grid array that will be written to CSV
           # use 0-percent land min/max filter, since areas calculated from 30x30 m LULC cells will not exactly equal area of 500x500 cells
            try:
                pwatgrid = max(0,min(100*(WaterAreaGrid[gg])/(500.0*500.0),100))
                griddataCSV[n][5] = pwatgrid
            except:
                pwatgrid = 0.0
                griddataCSV[n][5] = -9999

            try:
                gridedgeCSV[n][1] = 100.0*EdgeAreadict[gg]/(500.0*500.0)
            except:
                gridedgeCSV[n][1] = 0
                grid_edge_flag += 1
        
        if grid_bed_flag > 0:
            print '  -%s grid cells did did not have a calculated bed elevation and were assigned -9999 values.' % grid_bed_flag
        if grid_land_flag > 0:
            print '  -%s grid cells did did not have a calculated land elevation and were assigned -9999 values.' % grid_land_flag
        if grid_pct_flag > 0:
            print '  -%s grid cells did did not have a calculated percent land and were assigned -9999 values.' % grid_pct_flag
        if grid_edge_flag > 0:
            print '  -%s grid cells did did not have a calculated edge area and were assigned 0 values.' % grid_edge_flag

        print '--Saving new attributes for grid to CSV file saved in Hydro temporary directory'    
        ## save land and bed elevation file for 500-m grids to csv file - with header row       
        griddataCSV_EH = os.path.normpath(r'%s\\grid_data_500m_end%s.csv' % (EHtemp_path,CurrentYear)) # this must match name set in ICM (when Ecohydro is run) with the exception of CurrentYear here instead of (CurrentYear-1) 
        h = 'GRID,MEAN_BED_ELEV,MEAN_MARSH_ELEV,PERCENT_LAND,PERCENT_WETLAND,PERCENT_WATER'
        f = ['%i','%.4f','%.4f','%.4f','%.4f','%.4f']
        
        np.savetxt(griddataCSV_EH,griddataCSV,delimiter=',',fmt=f,header=h,comments='')
        
        print '--Saving new percent edge for grid to CSV file saved in HSI temporary directory'
        gridedgeCSV_HSI = os.path.normpath(r'%s\\%spedge.csv'% (HSI_dir,nprefix)) #this must match name set in ICM (when HSIs are run) - used by HSI.HSI in the same year as it was generated
        he = 'GRID,PERCENT_EDGE'
        fe = ['%i','%.4f']
        
        np.savetxt(gridedgeCSV_HSI,gridedgeCSV,delimiter=',',fmt=fe,header=he,comments='')
        
        
        
        ## clean up temporary variables
        del(landelev,landelevdict,bedelev,bedelevdict,compelevCSV,compelevCSV_EH,griddataCSV,griddataCSV_EH)
        del(WetlandArea,WaterArea,UplandArea,WaterAreaInExtent,WetlandAreaInExtent,UplandAreaInExtent,WetlandAreaGrid,WaterAreaGrid,UplandAreaGrid)
        
        e = time.clock()
        ProcTimeMin = round((e-s)/60,2)
        
        msg0 = "--total runtime: %s minutes" % (ProcTimeMin)
        msg1 = "COMPLETED SAVING NEW HYDRO AND HSI MODEL ATTRIBUTES"
        print msg0
        print msg1
        return([Edge_name])

    except Exception, e:
    # If an error occurred, print line number and error message
        import traceback, sys
        tb = sys.exc_info()[2]
        msg0 = "\n*******ERROR IN HYDRO AND HSI ATTRIBUTE CALCULATIONS"
        msg1 = "Line %i" % tb.tb_lineno
        msg2 = e.message
 #       arcpy.AddWarning(msg1)
#        arcpy.AddWarning(msg2)
        print msg0
        print msg1
        print msg2
        return()

def HSIpelican(CurrentLULC,CurrentLW,HSI_dir,GridPoly,GridPolyID_Field,CurrentYear,HSIDepCellSize,ngrids,elapsedyear):
    try:
        s = time.clock()
        arcpy.env.workspace = Intermediate_Files_GDB
        arcpy.env.scratchWorkspace = Temp_Files_Path
        arcpy.env.scratchFolder
        arcpy.env.scratchGDB
        
        print "\nCALCULATING BROWN PELICAN HSI RASTERS."
        processing_cell_size = HSIDepCellSize
        rLW = Raster(CurrentLW)
        rLULC = Raster(CurrentLULC)
        # large islands (and main land) are defined as having area larger than 200 ha
        large_island_area = 2000000.0
        
        # isolate land
        print"--generating polygons of land areas to determine island size"
        rLand = Con(rLW == 1,1,"")
#        rLand = Con(rLULC <> 6,1,"")
        
        # generate polygons of land
        land_poly = r"%s\\land_poly" % Intermediate_Files_GDB
        arcpy.RasterToPolygon_conversion(rLand,land_poly,"NO_SIMPLIFY","VALUE")
        del rLand
        
        # generate raster of land with areas
        print "--generating raster of island sizes"
        island_area = r"%s\\land_areas" % Intermediate_Files_GDB
        arcpy.FeatureToRaster_conversion(land_poly,"Shape_Area",island_area,"30")

        rIslandSize = Raster(island_area)

        # isolate salt marsh areas in raster of island sizes
        print "--isolating islands with salt marsh in island size rasters"
        rSM_islTEMP = Con(rLULC == 5,rIslandSize,"")
        saltmarsh_island = r"%s\\salt_marsh_island_area" % Intermediate_Files_GDB
        rSM_islTEMP.save(saltmarsh_island)
        del rSM_islTEMP
        
        # remove large islands from salt marsh islands
        print "--isolating small islands (<200 ha) with salt marsh"
        rSM_isl = Raster(saltmarsh_island)
        rSM_isl_smallTEMP = Con(rSM_isl <= large_island_area,rSM_isl,"")
        small_salt_isl = r"%s\\small_salt_marsh_island_area" % Intermediate_Files_GDB
        rSM_isl_smallTEMP.save(small_salt_isl)
        del rSM_isl_smallTEMP

        rSM_isl_small = Raster(small_salt_isl)

        # generate distance buffers from main land and large islands
        print "--isolating large islands and main land"
        
        rLargeIslandTEMP = Con(rIslandSize > large_island_area,1,"")
        large_islands = r"%s\\large_islands" % Intermediate_Files_GDB
        rLargeIslandTEMP.save(large_islands)
        del rLargeIslandTEMP
        
        rLargeIsland = Raster(large_islands)
        
        # generate buffer around large island areas
        print "--determining 1.0 km buffer around large islands and main land"
        buffer_dist = 1000
        buffercells = int(buffer_dist/processing_cell_size)
        LargeIsland1000 = Expand(rLargeIsland,buffercells,1)
        buffer1000 = r"%s\\large_islands_1000m"  % Intermediate_Files_GDB
        LargeIsland1000.save(buffer1000)
        
        del LargeIsland1000
        
        rLargeIsland1000 = Raster(buffer1000)

        # generate sequentially larger buffers, each will increase by buffer_dist
        buffer_dist = 500
        buffercells = int(buffer_dist/processing_cell_size)
        
        print "--determining 1.5 km buffer around large islands and main land"
        rLargeIsland1500 = Expand(rLargeIsland1000, buffercells,1)
        buffer1500 = r"%s\\large_islands_1500m"  % Intermediate_Files_GDB
        rLargeIsland1500.save(buffer1500)
        

        print "--determining 2.0 km buffer around large islands and main land"
        rLargeIsland2000 = Expand(rLargeIsland1500, buffercells,1)
        buffer2000 = r"%s\\large_islands_2000m"  % Intermediate_Files_GDB
        rLargeIsland2000.save(buffer2000)
        
        
        print "--determining 2.5 km buffer around large islands and main land"
        rLargeIsland2500 = Expand(rLargeIsland2000, buffercells,1)
        buffer2500 = r"%s\\large_islands_2500m"  % Intermediate_Files_GDB
        rLargeIsland2500.save(buffer2500)
        
        
        print "--determining 3.0 km buffer around large islands and main land"
        rLargeIsland3000 = Expand(rLargeIsland2500, buffercells,1)
        buffer3000 = r"%s\\large_islands_3000m"  % Intermediate_Files_GDB
        rLargeIsland3000.save(buffer3000)

        print "--determining all areas further than 3.0 km from large islands and main land"
        rLargeIslandfar = Expand(rLargeIsland2500, buffercells,1)
        buffer3000 = r"%s\\large_islands_3000m"  % Intermediate_Files_GDB
        rLargeIsland3000.save(buffer3000)



        # remove islands that are less than 1km from main land and large islands
        print "--isolating small islands with salt marsh more than 1km from large islands and main land"
        rPelicanIslandSizes = Con( (IsNull(rLargeIsland1000) == 1),rSM_isl_small,"")
        PelicanIslands = r"%s\\pelican_island_areas"  % Intermediate_Files_GDB
        rPelicanIslandSizes.save(PelicanIslands)
        
        rPelicanFar = Con( (IsNull(rLargeIsland3000) == 1),1,"")
        
        # calculate multiplier based on distance from large islands and main land
        print "--generating distance multiplier for pelican appropriate islands"
        rPelicanDistMult = CellStatistics([rLargeIsland1000*0.0, rLargeIsland1500*0.2,rLargeIsland2000*0.4,rLargeIsland2500*0.6,rLargeIsland3000*0.8,rPelicanFar], "MINIMUM", "DATA")
        PelicanDistMult = r"%s\\pelican_island_dist_mult" % Intermediate_Files_GDB
        rPelicanDistMult.save(PelicanDistMult)
        
 
        ## create tables of Pelican HSI values for each grid cell
        print "--Mapping area of pelican appropriate islands to each 500-m grid cell"
        PelicanAreaTbl = "PelicanIslandArea_m"
        ZonalStatisticsAsTable(GridPoly,GridPolyID_Field,rPelicanIslandSizes,PelicanAreaTbl,"DATA","MINIMUM")    
        Pelfieldsmin = [str(GridPolyID_Field),"MIN"]
        PelArTbl = arcpy.da.TableToNumPyArray(PelicanAreaTbl,Pelfieldsmin)
        PelAreaGrid={}
        for row in PelArTbl:
            ggrr = row[0]
            PelAreaGrid[ggrr] = row[1]
            
        print "--Mapping distance multipliers for pelican appropriate islands to each 500-m grid cell"
        PelicanDistMultTbl = "PelicanIslandMult" 
        ZonalStatisticsAsTable(GridPoly,GridPolyID_Field,rPelicanDistMult,PelicanDistMultTbl,"DATA","MAXIMUM")
        Pelfieldsmax = [str(GridPolyID_Field),"MAX"]
        PelMultTbl = arcpy.da.TableToNumPyArray(PelicanDistMultTbl,Pelfieldsmax)
        PelMultGrid = {}
        for row in PelMultTbl:
            ggrr = row[0]
            PelMultGrid[ggrr] = row[1]

        PelicanCSV = np.zeros((ngrids,3))
        pelican_area_flag = 0
        pelican_mult_flag = 0

# loop through zonal statistics tables (that are numpy arrays) and fill missing grid cells (e.g. did not overlap island rasters) with zeros        
        for n in range(0,ngrids):
            gg = n+1
            PelicanCSV[n][0] = gg
            try:
                PelicanCSV[n][1] = PelAreaGrid[gg]
            except:
                PelicanCSV[n][1] = 0
                pelican_area_flag += 1
            try:
                PelicanCSV[n][2] = PelMultGrid[gg]
            except:
                PelicanCSV[n][2] = 0
                pelican_mult_flag += 1


        print '--Saving island attributes for Pelican HSI in grid to CSV file saved in HSI directory'    
        PelicanCSV_HSI = os.path.normpath(r'%s\\BrownPelican_HSI_inputs_%02d.csv' % (HSI_dir,elapsedyear)) # this must match name set in ICM
        h = 'GRID,ISLAND_AREA,DISTANCE_MULTIPLIER'
        f = ['%i','%.4f','%.4f']

        np.savetxt(PelicanCSV_HSI,PelicanCSV,delimiter=',',fmt=f,header=h,comments='')


        del rLargeIsland1000,rLargeIsland1500,rLargeIsland2000,rLargeIsland2500,rLargeIsland3000
        del rPelicanIslandSizes,rPelicanDistMult
        
        
        e = time.clock()
        ProcTimeMin = round((e-s)/60,2)
        
        print "--total runtime: %s minutes" % (ProcTimeMin)
        print "COMPLETED GENERATING BROWN PELICAN HSI RASTERS."
                
        return()
        
    except Exception, e:
    # If an error occurred, print line number and error message
        import traceback, sys
        tb = sys.exc_info()[2]
        msg1 = "Line %i" % tb.tb_lineno
        msg2 = e.message
#        arcpy.AddWarning(msg1)
#        arcpy.AddWarning(msg2)
        print msg1
        print msg2
        return()  


def HSIreclass(HSIDepCellSize,HSI_dir,CurrentTOPO,CurrentMWL,OctAprMWL,SepMarMWL,GridPoly,GridPolyID_Field):
    try:
        s = time.clock()
        arcpy.env.workspace = Intermediate_Files_GDB
        arcpy.env.scratchWorkspace = Temp_Files_Path
        arcpy.env.scratchFolder
        arcpy.env.scratchGDB
                
        print "\nCALCULATING DEPTH RANGES USED IN BIRD HSI EQUATIONS."
        
        rJanDecMWL = Raster(CurrentMWL)
        rSepMarMWL = Raster(SepMarMWL)
        rOctAprMWL = Raster(OctAprMWL)
        rCurrentTOPO = Raster(CurrentTOPO)
        
        # determine depths from various average water levels    
        JanDecDep = Minus(rJanDecMWL,rCurrentTOPO)
        SepMarDep = rSepMarMWL - rCurrentTOPO
        OctAprDep = rOctAprMWL - rCurrentTOPO
        
        
        ##########################################
        ### Mottled Duck Depths
        ##########################################
               
        print '--Summarizing depths for Mottled Duck depth intervals'
        # Reclassify annual average depth into bins used by Mottled Duck HSI
        # Depth intervals (in meters) to calculate areas of for Mottled Duck HSI
        MDDm = [0,0.08,0.30,0.36,0.42,0.46,0.50,0.56]
        
        # Generate depths (in cm) and field names from from depth intervals (in m) provided above
        MDDcm =[]
        MotDuckDepFields = ['Value']
        for i in range(0,len(MDDm)):
            MDDcm.append(int(MDDm[i]*100))
            MotDuckDepFields.append('Value_%s' % int(MDDm[i]*100))
        MotDuckDepFields.append('Value_%s' %str(MDDcm[len(MDDcm)-1]+1))

        # Reclassify depth raster to depth intervals (in centimeters)
        MotDuckDep_cm = Con(JanDecDep <= MDDm[0],MDDcm[0],Con(JanDecDep <= MDDm[1],MDDcm[1],Con(JanDecDep <= MDDm[2],MDDcm[2],Con(JanDecDep <= MDDm[3],MDDcm[3],Con(JanDecDep <= MDDm[4],MDDcm[4],Con(JanDecDep <= MDDm[5],MDDcm[5],Con(JanDecDep <= MDDm[6],MDDcm[6],Con(JanDecDep <= MDDm[7],MDDcm[7],MDDcm[7]+1))))))))
       
        # File names used for depth summaries
        MotDuckDepSave = r"%s\\%sMotDuckDep_cm" % (Intermediate_Files_GDB, nprefix)
        MotDuckDepDBF = os.path.normpath("%s\\MotDuckDepths_cm.dbf" % HSI_dir) # This filename must match those used by HSI.py (imported via NumPy into specific HSI equations)
    
        print'--Saving Mottled Duck depth intervals raster.'
        MotDuckDep_cm.save(MotDuckDepSave)        
        
        print'--Tabulating area of depth intervals in each grid cell - saving as DBF file in HSI directory.'
        # Summarize depth intervals by grid cell and save to GDB table and CSV file in the HSI file directory for direct import into HSI.py
        arcpy.sa.TabulateArea(GridPoly,GridPolyID_Field,MotDuckDepSave,"Value",MotDuckDepDBF,HSIDepCellSize)

 
        ##########################################
        ### Green-winged Teal Depths
        ##########################################
        
        print '--Summarizing depths for Green-winged Teal depth intervals'
        # Reclassify annual average depth into bins used by Green-winged Teal HSI
        # Depth intervals (in meters) to calculate areas of for Green-winged Teal HSI
        GTDm = [0,0.06,0.18,0.22,0.26,0.30,0.34,1.0]
        
        # Generate depths (in cm) and field names from from depth intervals (in m) provided above
        GTDcm =[]
        GWTealDepFields = ['Value']
        for i in range(0,len(GTDm)):
            GTDcm.append(int(GTDm[i]*100))
            GWTealDepFields.append('Value_%s' % int(GTDm[i]*100))
        GWTealDepFields.append('Value_%s' %str(GTDcm[len(GTDcm)-1]+1))

        # Reclassify September-March depth raster to depth intervals (in centimeters)
        GWTealDep_cm = Con(SepMarDep <= GTDm[0],GTDcm[0],Con(SepMarDep <= GTDm[1],GTDcm[1],Con(SepMarDep <= GTDm[2],GTDcm[2],Con(SepMarDep <= GTDm[3],GTDcm[3],Con(SepMarDep <= GTDm[4],GTDcm[4],Con(SepMarDep <= GTDm[5],GTDcm[5],Con(SepMarDep <= GTDm[6],GTDcm[6],Con(SepMarDep <= GTDm[7],GTDcm[7],GTDcm[7]+1))))))))

        # File names used for depth summaries
        GWTealDepSave = r"%s\\%sGWTealDep_cm" % (Intermediate_Files_GDB, nprefix)
        GWTealDepDBF = os.path.normpath("%s\\GWTealDepths_cm.dbf" % HSI_dir)  # This filename must match those used by HSI.py (imported via NumPy into specific HSI equations)
        
        print'--Saving Green-winged Teal depth intervals raster.'
        GWTealDep_cm.save(GWTealDepSave) 
        
        print'--Tabulating area of depth intervals in each grid cell - saving as DBF file in HSI directory.'
        # Summarize depth intervals by grid cell and save to GDB table and CSV file in the HSI file directory for direct import into HSI.py
        arcpy.sa.TabulateArea(GridPoly,GridPolyID_Field,GWTealDepSave,"Value",GWTealDepDBF,HSIDepCellSize)


        ##########################################
        ### Gadwall Depths
        ##########################################
        
        print '--Summarizing depths for Gadwall depth intervals'
        # Reclassify annual average depth into bins used by Gadwall HSI
        # Depth intervals (in meters) to calculate areas of for Gadwall HSI
        GWDm = [0,0.04,0.08,0.12,0.18,0.22,0.28,0.32,0.36,0.40,0.44,0.78,1.50]

        # Generate depths (in cm) and field names from from depth intervals (in m) provided above
        GWDcm =[]
        GadwallDepFields = ['Value']
        for i in range(0,len(GWDm)):
            GWDcm.append(int(GWDm[i]*100))
            GadwallDepFields.append('Value_%s' % int(GWDm[i]*100))
        GadwallDepFields.append('Value_%s' %str(GWDcm[len(GWDcm)-1]+1))

        # Reclassify October-April depth raster to depth intervals (in centimeters)
        GadwallDep_cm = Con(OctAprDep <= GWDm[0],GWDcm[0],Con(OctAprDep <= GWDm[1],GWDcm[1],Con(OctAprDep <= GWDm[2],GWDcm[2],Con(OctAprDep <= GWDm[3],GWDcm[3],Con(OctAprDep <= GWDm[4],GWDcm[4],Con(OctAprDep <= GWDm[5],GWDcm[5],Con(OctAprDep <= GWDm[6],GWDcm[6],Con(OctAprDep <= GWDm[7],GWDcm[7],Con(OctAprDep <= GWDm[8],GWDcm[8],Con(OctAprDep <= GWDm[9],GWDcm[9],Con(OctAprDep <= GWDm[10],GWDcm[10],Con(OctAprDep <= GWDm[11],GWDcm[11],Con(OctAprDep <= GWDm[12],GWDcm[12],GWDcm[12]+1)))))))))))))

        # File names used for depth summaries
        GadwallDepSave = r"%s\\%sGadwallDep_cm" % (Intermediate_Files_GDB, nprefix)
        GadwallDepDBF = os.path.normpath("%s\\GadwallDepths_cm.dbf" % HSI_dir) # This filename must match those used by HSI.py (imported via NumPy into specific HSI equations)

        print'--Saving Gadwall depth intervals raster.'
        GadwallDep_cm.save(GadwallDepSave)
        
        print'--Tabulating area of depth intervals in each grid cell - saving as DBF file in HSI directory.'
        # Summarize depth intervals by grid cell and save to GDB table and CSV file in the HSI file directory for direct import into HSI.py
        arcpy.sa.TabulateArea(GridPoly,GridPolyID_Field,GadwallDepSave,"Value",GadwallDepDBF,HSIDepCellSize)

         
        # Delete arrays saved to text and tables and any temporary calculation rasters
        del(JanDecDep,SepMarDep,OctAprDep,MotDuckDep_cm,GWTealDep_cm,GadwallDep_cm)
        
        e = time.clock()
        ProcTimeMin = round((e-s)/60,2)
        
        print "--total runtime: %s minutes" % (ProcTimeMin)
        print "COMPLETED CALCULATING DEPTH RANGES USED IN BIRD HSI EQUATIONS"
                
        return()
        
    except Exception, e:
    # If an error occurred, print line number and error message
        import traceback, sys
        tb = sys.exc_info()[2]
        msg1 = "Line %i" % tb.tb_lineno
        msg2 = e.message
#        arcpy.AddWarning(msg1)
#        arcpy.AddWarning(msg2)
        print msg1
        print msg2
        return()

def SaveForNextInitConditions(wetland_morph_dir,elapsedyear,StartingTopo,CurrentTOPO,StartingLW,CurrentLW,StartingEdge,CurrentEdge,CurrentMWL,PreviousMWL_name):
    
    s=time.clock()
    print "\nCREATING GEODATABASE TO SAVE INITIAL CONDITIONS FOR NEXT MODEL YEAR"
    NextYear = elapsedyear+1

    IC_GDB_path = r"%s\\%sinitc.gdb" % (wetland_morph_dir,iprefixout)
        
    if os.path.exists(IC_GDB_path):
        NextInitCond_GDB = r"InitialConditions%s_error_backup.gdb" % NextYear
    ## if database already exists - still create a new one, just use a different name    
        msg00 = r"--Initial Conditions geodatabase for %s already exists." % NextYear
        msg01 = r"--The model will use the pre-existing Initial Conditions GDB for the next year."
        msg02 = r"--This current Initial Conditions GDB will be saved as %s, but won't be used." % NextInitCond_GDB
        print msg00
    else:
        NextInitCond_GDB = r"%sinitc.gdb" % iprefixout
        
    print "--creating %s geodatabase." % NextInitCond_GDB
    
    arcpy.CreateFileGDB_management(wetland_morph_dir,NextInitCond_GDB)
    
    e = time.clock()
    ProcTimeMin = round((e-s)/60,2)

    msg0 = "--total runtime: %s" % (ProcTimeMin)
    msg1 = "COMPLETED CREATING GEODATABASE FOR NEXT INITIAL CONDITIONS"
    print msg0
    print msg1
    
    try:
        arcpy.env.workspace = Intermediate_Files_GDB
        msg0 = "\nSAVING FINAL RASTERS AS INITIAL CONDITIONS FOR NEXT MODEL STEP"
        print msg0

        print "--saving Topo/Bathy raster"
        outTOPO = r"%s\\%s" % (NextInitCond_GDB,StartingTopo)
        arcpy.CopyRaster_management(CurrentTOPO, outTOPO)
        
        print "--saving LandWater raster"
        outLW = r"%s\\%s" % (NextInitCond_GDB,StartingLW)
        arcpy.CopyRaster_management(CurrentLW, outLW)
        
        print "--saving Edge raster"
        outLW = r"%s\\%s" % (NextInitCond_GDB,StartingEdge) 
        arcpy.CopyRaster_management(CurrentEdge, outLW)
        
        ##------------------------------------------------------------------------
        print "--saving mean water level raster"
        outMWL = r"%s\\%s" % (NextInitCond_GDB,PreviousMWL_name) 
        arcpy.CopyRaster_management(CurrentMWL, outMWL)
        
        e = time.clock()
        ProcTimeMin = round((e-s)/60,2)
        
        msg0 = "--total runtime: %s minutes" % (ProcTimeMin)
        msg1 = "COMPLETED SAVING FINAL RASTERS AS INITIAL CONDITIONS FOR NEXT TIMESTEP"
        print msg0
        print msg1

        return()

    except Exception, e:
    # If an error occurred, print line number and error message
        import traceback, sys
        tb = sys.exc_info()[2]
        msg1 = "Line %i" % tb.tb_lineno
        msg2 = e.message
#        arcpy.AddWarning(msg1)
#        arcpy.AddWarning(msg2)
        print msg1
        print msg2
        return()


def main(WM_params,ecohydro_dir,wetland_morph_dir,EHtemp_path,vegetation_dir,veg_output_file,veg_deadfloat_file,nvegtype,HSI_dir,BMprof_forWMfile,n500grid,n500rows,n500cols,yll500,xll500,n1000grid,elapsedyear):

    try:
        s = time.clock()

        ##########################################################################
        ##########################################################################
        ##########################################################################
        
        global CurrentYear
        global YearIncrement
        global NumModelRuns

        
        global iprefix
        global iprefixout
        global nprefix
        global oprefix
        
        
        global ProcessingCellSize
        ProcessingCellSize = 30

        global tSalinity1
        global tSalinity2
        global tMWL3
        global tMWL4
        global tMWL5
        global tMWL6
        global SG
        SG = WM_params[0].lstrip().rstrip()
        
        iprefix = r'%s_I_%02d_%02d_W_' % (SG,elapsedyear,elapsedyear)
        iprefixout = r'%s_I_%02d_%02d_W_' % (SG,elapsedyear+1,elapsedyear+1)
        nprefix = r'%s_N_%02d_%02d_W_' % (SG,elapsedyear,elapsedyear)
        oprefix = r'%s_O_%02d_%02d_W_' % (SG,elapsedyear,elapsedyear)
        prev_iprefix = r'%s_I_%02d_%02d_W_' % (SG,elapsedyear-1,elapsedyear-1)
        
        
        CurrentYear = int(WM_params[1].lstrip().rstrip())
        YearIncrement = 1
        NumModelRuns = 1
        Initialization_GDB = os.path.normpath(r'%s\\%s' % (wetland_morph_dir,WM_params[2].lstrip().rstrip()) )
        outputFolderNoYear = r'%s\\%s' % (wetland_morph_dir,WM_params[3].lstrip().rstrip())
        StartingLW = WM_params[4].lstrip().rstrip()
        StartingTopo = WM_params[5].lstrip().rstrip()
        StartingLULC = 'Initial_LULC'
        marsh_input = WM_params[6].lstrip().rstrip()
        if marsh_input <> 'NONE':
            MarshProjects = r'%s\\%s' % (Initialization_GDB,marsh_input)
        else:
            MarshProjects = marsh_input
        MarshProjects_Elev = WM_params[7].lstrip().rstrip()
        tMarshCreation = float(WM_params[8].lstrip().rstrip())
        
        shore_input = WM_params[9].lstrip().rstrip()
        if shore_input <> 'NONE':
            ShorelineProtProjects = r'%s\\%s' % (Initialization_GDB,shore_input)
        else:
            ShorelineProtProjects = shore_input
        ShorelineProtProjects_MEE_Mult = WM_params[10].lstrip().rstrip()
        
        canals_input = WM_params[11].lstrip().rstrip()
        if canals_input <> 'NONE':
            CanalProjects = r'%s\\%s' % (Initialization_GDB,canals_input)
        else:
            CanalProjects = canals_input
        CanalProjects_Elev = WM_params[12].lstrip().rstrip()
        
        levees_input = WM_params[13].lstrip().rstrip()       
        if levees_input <> 'NONE':
            LeveeProjects = r'%s\\%s' % (Initialization_GDB,levees_input)
        else:
            LeveeProjects = levees_input
        LeveeProjects_Crest_Width = WM_params[14].lstrip().rstrip()
        LeveeProjects_Elev = WM_params[15].lstrip().rstrip()
        LeveeProjects_Slope_Width = WM_params[16].lstrip().rstrip()
        LeveeSlope_Elev = WM_params[17].lstrip().rstrip()
        
        HistoricMarshZones = r'%s\\%s' % (Initialization_GDB,WM_params[18].lstrip().rstrip())
        BDOM_Lookup = r'%s\\%s' % (Initialization_GDB,WM_params[19].lstrip().rstrip())
        BDOM_ZoneField = WM_params[20].lstrip().rstrip()
        BD_NewValField = WM_params[21].lstrip().rstrip()
        OM_NewValField = WM_params[22].lstrip().rstrip()        
        zoneLayer = r'%s\\%s' % (Initialization_GDB,WM_params[23].lstrip().rstrip())
        zoneField = WM_params[24].lstrip().rstrip()
        LossField = WM_params[25].lstrip().rstrip()
        GainField = WM_params[26].lstrip().rstrip()
        LGProbSurface = r'%s\\%s' % (Initialization_GDB,WM_params[27].lstrip().rstrip())
        StartingEdge = WM_params[28].lstrip().rstrip()
        NoUpdateMask = r'%s\\%s' % (Initialization_GDB,WM_params[29].lstrip().rstrip())
        Basins = r'%s\\%s' % (Initialization_GDB,WM_params[30].lstrip().rstrip())
        BDWaterVal = float(WM_params[31].lstrip().rstrip())
#        StartingLULC = WM_params[32].lstrip().rstrip()
        LULC_Lookup =  r'%s\\%s' % (wetland_morph_dir,WM_params[32].lstrip().rstrip())      #this is used in HSI.py, if this changes here, be sure to change it there as well
        LULC_OldValField = WM_params[33].lstrip().rstrip()  #this is used in HSI.py, if this changes here, be sure to change it there as well
        LULC_NewValField = WM_params[34].lstrip().rstrip()  #this is used in HSI.py, if this changes here, be sure to change it there as well
        PreviousMWL_name = WM_params[35].lstrip().rstrip()
        OMWaterVal = 0 # OM value for water areas
        Subsidence = r'%s\\%s' % (Initialization_GDB,WM_params[36].lstrip().rstrip())
        SubsidField = WM_params[37].lstrip().rstrip()
        BI_Mask = r'%s\\%s' % (Initialization_GDB,WM_params[38].lstrip().rstrip())
        MaxAccretion = float(WM_params[39].lstrip().rstrip())
        tSalinity1 = float(WM_params[40].lstrip().rstrip())
        tSalinity2 = float(WM_params[41].lstrip().rstrip())
        tMWL3 = float(WM_params[42].lstrip().rstrip())
        tMWL4 = float(WM_params[43].lstrip().rstrip())
        tMWL5 = float(WM_params[44].lstrip().rstrip())
        tMWL6 = float(WM_params[45].lstrip().rstrip())
        ZonalGrid = r'%s\\%s' % (Initialization_GDB,WM_params[46].lstrip().rstrip())
        GridField = WM_params[47].lstrip().rstrip()
        lowWaterThreshold = float(WM_params[48].lstrip().rstrip())
        ElevDeliverable = WM_params[49].lstrip().rstrip()
        PLandDeliverable = WM_params[50].lstrip().rstrip()
        PShalDeliverable = WM_params[51].lstrip().rstrip()
        #EDW #new parameters reading in the 500m grid polygon file and the Ecohydro output file with gridded values
        GridPoly = WM_params[52].lstrip().rstrip()
        GridPolyID_Field = WM_params[53].lstrip().rstrip()
        Ecohydro_table_grid = WM_params[54].lstrip().rstrip()
        Ecohydro_table_gridID_Field = WM_params[55].lstrip().rstrip()
        CompartmentPoly = WM_params[56].lstrip().rstrip()
        CompartmentPolyID_Field = WM_params[57].lstrip().rstrip()
        Ecohydro_table_compartment = WM_params[58].lstrip().rstrip()
        Ecohydro_table_compartmentID_Field = WM_params[59].lstrip().rstrip()
        Area_out_of_extent_file = WM_params[60].lstrip().rstrip()
        veg_ascii_grid = WM_params[61].lstrip().rstrip()
        delete_temp = WM_params[62].lstrip().rstrip()
        summaryzonesPoly = WM_params[63].lstrip().rstrip()
        summaryzonesID = WM_params[64].lstrip().rstrip()
        outputmaskfine_raster = WM_params[65].lstrip().rstrip()
        outputmaskcourse_raster = WM_params[66].lstrip().rstrip()
        NavChannelsPoly = WM_params[67].lstrip().rstrip()
        NavChanID = WM_params[68].lstrip().rstrip()
        RegimeChannelRaster = WM_params[69].lstrip().rstrip()
        BareGroundCollapse = float(WM_params[70].lstrip().rstrip())
##  Reads csv file into array that has the area, in sq. meters, of the Ecohydro compartments that have area outside of the extent of the LandWater/LULC spatial extents
        extra_area_file = os.path.normpath(wetland_morph_dir + '\\' + Area_out_of_extent_file)
        AssumedAreas = np.genfromtxt(extra_area_file,dtype='i,f12,f12',delimiter=',',names=True)

        outputFolder = r"%s_%02d" % (outputFolderNoYear,elapsedyear)

        Temp_Files_Folder = "Temporary"
        Intermediate_Files_Folder = "Intermediate"
        Deliverable_Files_Folder = "Deliverables"
        TempGDBName = "WM_TEMP_DATA"
        IntermediateGDBName = r"WM_INTERMEDIATE_DATA_%02d" % elapsedyear
        global Temp_Files_Path
        global Temp_Files_GDB
        global Intermediate_Files_Path
        global Intermediate_Files_GDB
        global Deliverable_Files_Path
        global Input_GDB
        global InitCond_GDB

        Temp_Files_Path = r"%s\\%s" % (outputFolder, Temp_Files_Folder)
        Temp_Files_GDB = r"%s\\%s\\%s.gdb" % (outputFolder, Temp_Files_Folder, TempGDBName)
        
        Intermediate_Files_Path = r"%s\\%s" % (outputFolder, Intermediate_Files_Folder)
        Intermediate_Files_GDB = r"%s\\%s\\%s.gdb" % (outputFolder, Intermediate_Files_Folder, IntermediateGDBName)

        Deliverable_Files_Path = r"%s\\%s" % (outputFolder, Deliverable_Files_Folder)

        Input_GDB = Initialization_GDB
        
        InitCond_GDB = os.path.normpath(r"%s\\%sinitc.gdb" % (wetland_morph_dir,iprefix))

        PrevInitCond_GDB = os.path.normpath(r"%s\\%sinitc.gdb" % (wetland_morph_dir,prev_iprefix))
       

        AvgAcc = "AVG_ACC_" #still needed?

        ##########################################################################

        outputmaskfine = os.path.normpath(r'%s\\%s' % (Input_GDB,outputmaskfine_raster))
        outputmaskcourse = os.path.normpath(r'%s\\%s' % (Input_GDB,outputmaskcourse_raster))
        NavChan = os.path.normpath(r'%s\\%s' % (Input_GDB,NavChannelsPoly))
        RegimeChan = os.path.normpath(r'%s\\%s' % (Input_GDB,RegimeChannelRaster))
        summaryzones = r"%s\\%s" % (Input_GDB,summaryzonesPoly)
        
        
        CurrentLW = os.path.normpath(r"%s\\%s" % (InitCond_GDB, StartingLW))
        CurrentTOPO = os.path.normpath(r"%s\\%s" % (InitCond_GDB,StartingTopo))
#        CurrentBD = os.path.normpath(r"%s\\%s" % (InitCond_GDB,StartingBulkDensity))
        CurrentEdge = os.path.normpath(r"%s\\%s" % (InitCond_GDB,StartingEdge))
#        CurrentOM = os.path.normpath(r"%s\\%s" % (InitCond_GDB,StartingOrganicMatter))   
        PreviousMWL = os.path.normpath(r"%s\\%s" % (InitCond_GDB,PreviousMWL_name))           
        PreviousLULC = os.path.normpath(r"%s\\%s" % (PrevInitCond_GDB,StartingLULC))
        
        msg0 = "------------------------------"
        msg1 = "-- WETLAND MORPHOLOGY MODEL --"
        msg2 = "------------------------------"

        print msg0
        print msg1
        print msg2
        msg3 = "start time: %s\n" % (datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
        print msg3
#        arcpy.AddMessage(msg0)
#        arcpy.AddMessage(msg1)
#        arcpy.AddMessage(msg2)
#        arcpy.AddMessage(msg3)
        
  
        
        ##--SUBROUTINE CALLS--
        ##   
        ##------------------------------------------------------------------------
        ##VALIDATION
        ##------------------------------------------------------------------------
        
        ##------------------------------------------------------------------------
        ##MAKE FOLDER STRUCTURE
        CreateWorkSpaces(outputFolder, Temp_Files_Folder, TempGDBName, Intermediate_Files_Folder, IntermediateGDBName, Deliverable_Files_Folder)
        ##------------------------------------------------------------------------

        
        ##------------------------------------------------------------------------
        ##READ IN ECOHYDRO OUTPUT
        ##------------------------------------------------------------------------
        ##PURPOSE:  Reads in output data generated by hydrology model - updates salinity, water elevation, and other files
        
        ImportEcohydroResults(CurrentYear,ecohydro_dir,EHtemp_path,Ecohydro_table_grid,Ecohydro_table_gridID_Field,Ecohydro_table_compartment,Ecohydro_table_compartmentID_Field,GridPoly,GridPolyID_Field,CompartmentPoly,CompartmentPolyID_Field)

        ##------------------------------------------------------------------------
        ##READ IN VEGETATION OUTPUT
        ##------------------------------------------------------------------------
        ##PURPOSE:  Reads in vegetation coverage data from Vegetation model output and generate a new LULC raster        
        
        # read lookup table into dictionary that converts output VegType to new LULC value
        VegLULC_lookup={}
        with open(LULC_Lookup, mode='r') as infile:
            for i,row in enumerate(infile):
                if i == 0:
                    hds = row.split(',')
                    for n in range(0,len(hds)):
                        hds[n] = hds[n].lstrip().rstrip()   #remove any leading or trailing spaces
                    old = hds.index(LULC_OldValField)
                    new = hds.index(LULC_NewValField)
                else:
                    VegLULC_lookup[row.split(',')[old].rstrip().lstrip()]=row.split(',')[new].rstrip().lstrip()


        veg_ascii_header='nrows %s \nncols %s \nyllcorner %s \nxllcorner %s \ncellsize 500.0 \nnodata_value -9999.00' % (n500rows,n500cols,yll500,xll500)
        # generate arcpy spatial reference object - use this projection for project rasters generated from ASCI grid files

        InitCond_proj=arcpy.Describe(CurrentLW).spatialReference
        lstReturns = ImportVegResults(CurrentYear,vegetation_dir,veg_output_file,veg_deadfloat_file,veg_ascii_grid,VegLULC_lookup,n500grid,n500rows,n500cols,veg_ascii_header,nvegtype,InitCond_proj,CurrentLW,NoUpdateMask,elapsedyear,StartingLULC)
        CurrentLULC = lstReturns[0]
        CurrentLW = lstReturns[1]

   
                                   

        ##------------------------------------------------------------------------
        ##PREPROCESSING
        ##------------------------------------------------------------------------
        ##PURPOSE: data conversion to prepare inputs for model runs.
        ##includes vector to raster conversion salinity, stage, max stage, sediment load(accretion), subsidence
#        lstReturns = Preprocessing(HydroData, AvgAcc, AvgSal, AvgStage, MaxStage, LandSed, EdgeSed, WaterSed, Subsidence, SubsidField, BasinMarshType, \
#                      OM_AVG_BMTField, BD_AVG_BMTField, MarshZones, MarshZoneField, CurrentLULC, LULC_Lookup, LULC_OldValField, LULC_NewValField, \
#                                   CurrentMWL, MWLField, HurricaneSed, HurricaneSedField, ProcessingCellSize,GridPoly,CompartmentPoly,InitMWL)
#        lstReturns = Preprocessing(Subsidence,SubsidField,BasinMarshType,Organic_In,OM_AVG_BMTField,BD_AVG_BMTField,MarshZones,MarshZoneField,CurrentLULC,CurrentEdge,ProcessingCellSize,CompartmentPoly,GridPoly,InitCond_proj,elapsedyear)

        lstReturns = Preprocessing(Subsidence,SubsidField,CurrentLULC,CurrentEdge,ProcessingCellSize,CompartmentPoly,GridPoly,InitCond_proj,Basins,HistoricMarshZones,BDWaterVal,OMWaterVal,BDOM_Lookup,BDOM_ZoneField,BD_NewValField,OM_NewValField,ShorelineProtProjects,ShorelineProtProjects_MEE_Mult,elapsedyear)
              

        # set LULC and MWL rasters to new rasters developed by processing Hydro and Veg output files
        CurrentLULC = lstReturns[0]
        CurrentMWL = lstReturns[1]

        # MEEflag is raster of 0s and 1s, value of 1 is for edge pixel that will be converted from land to water due to Marsh Edge Erosion
        MEEflag = lstReturns[2]
        CurrentBD = lstReturns[3]
        CurrentOM = lstReturns[4]
        Organic_In = lstReturns[5]
        BulkDensity_In = lstReturns[6]
        
        SubsidenceRas = lstReturns[7]
        CurrentLandSed = lstReturns[8]
        CurrentEdgeSed = lstReturns[9]
        CurrentWaterSed = lstReturns[10]
        CurrentStageMax = lstReturns[11]
        CurrentSalinity = lstReturns[12]
        AveSalinity = lstReturns[13]
        OctAprMWL = lstReturns[14]
        SepMarMWL = lstReturns[15]

        ##------------------------------------------------------------------------
        
        ##------------------------------------------------------------------------
        ##INCORPORATE PROJECTS
        #PARAMETERS: (ProjectType, ProjectFeatures, RasValueField, RasValueField2, RasValueField3, RasValueField4, LandWater, TopoBathy)
        #ProjectTypes[MarshProjects, ShorelineProtProjects, LeveeProjects, CanalProjects]
        #Occurs on Time0 + 1day
        #
        lstLW1234 = []
        if LeveeProjects <> "NONE":
            lstReturns = IncorporateProjects("Levees", LeveeProjects, LeveeProjects_Elev, LeveeProjects_Crest_Width, \
                                             LeveeProjects_Slope_Width, LeveeSlope_Elev, CurrentLW, CurrentTOPO, "#",elapsedyear)
            CurrentLW = str(lstReturns[0])
            CurrentTOPO = str(lstReturns[1])
            lstLW1234.append(str(lstReturns[2]))

        if MarshProjects <> "NONE":
            lstReturns = IncorporateProjects("MarshCreation", MarshProjects, MarshProjects_Elev, "#", "#", "#", CurrentLW, CurrentTOPO, tMarshCreation,elapsedyear)
            CurrentLW = str(lstReturns[0])
            CurrentTOPO = str(lstReturns[1])
            lstLW1234.append(str(lstReturns[2]))


#Shoreline Protection Projects are now implemented in Preprocessing and applied to the MEE rate raster there            
#        if ShorelineProtProjects <> "NONE":
#            lstReturns = IncorporateProjects("ShorelineProtection", ShorelineProtProjects, ShorelineProtProjects_MEE_Mult, MEEflag, "#", "#", CurrentLW, CurrentTOPO, "#",elapsedyear)
#            MEEflag = lstReturns[0]
                        
        if CanalProjects <> "NONE":
            lstReturns = IncorporateProjects("Canals", CanalProjects, CanalProjects_Elev, "#", "#", "#", CurrentLW, CurrentTOPO, "#",elapsedyear)
            CurrentLW = str(lstReturns[0])
            CurrentTOPO = str(lstReturns[1])
            lstLW1234.append(str(lstReturns[2]))

        if len(lstLW1234) > 0:
            #LW1234
            IP_LW_1234 = r"%s\\IP_LW_%s_ALLProjects_vals1234" % (Intermediate_Files_GDB, CurrentYear)
            routCellStats = CellStatistics([lstLW1234], "MAXIMUM", "DATA")
            arcpy.CopyRaster_management(routCellStats, IP_LW_1234, "#", "#", "#", "#", "NONE", "4_BIT", "#", "#")
            del routCellStats
            lstReturns = Update_BD_OM_LULC(IP_LW_1234, CurrentBD, BDWaterVal, CurrentOM, OMWaterVal, CurrentLULC,HistoricMarshZones,Organic_In,BulkDensity_In, "IP")

            CurrentBD = str(lstReturns[0])
            CurrentOM = str(lstReturns[1])
            CurrentLULC = str(lstReturns[2])
            lstLW1234 = []

#skipICM#            #send plus 1 day to the deliverables folder
#skipICM#            lstReturns = SaveUpdated_LandWater_TOPO(CurrentLW, CurrentTOPO, CurrentLULC, "with_projects_", ".img",elapsedyear,0,summaryzones,summaryzonesID)
#skipICM#            CurrentLW = lstReturns[0]
#skipICM#            CurrentTOPO = lstReturns[1]
#skipICM#            CurrentLULC = lstReturns[2]
            
        #
#EDW##------------------------------------------------------------------------------------------------------------------------------
#EDW##------------------------------------------------------------------------------------------------------------------------------
#EDW##--MODEL LOOP USED TO BEGIN HERE - IF FUNCTIONALITY IS DESIRED, RE-INDENT AND CHANGE PRE-PROCESSING ROUTINE TO INCORPORATE MULTIPLE YEARS OF HYDRO OUTPUT
#EDW##------------------------------------------------------------------------------------------------------------------------------
#EDW##------------------------------------------------------------------------------------------------------------------------------

        TwoDigitYr = str(CurrentYear)[2:4]
        
#EDW##        ##------------------------------------------------------------------------
#EDW##        ##LOSS GAIN
#EDW##        #
#EDW##        lstReturns = LossGain(zoneLayer, zoneField, GainField, LossField, CurrentLW, LGProbSurface, CurrentMWL, CurrentTOPO, YearIncrement)
#EDW##        CurrentLW = lstReturns[0]
#EDW##        CurrentTOPO = lstReturns[1]
#EDW##        lstLW1234.append(lstReturns[2])            
#EDW##        #
        ##------------------------------------------------------------------------

        ##------------------------------------------------------------------------
        ##SEDIMENT DISTRIBUTION AND ACCRETION
        #
        #Determine the sediment load rasters (land, edge, water) names
        #
        
#EDW # no longer using separate hurricane sediment load - storms are in LandSed,EdgeSed,and WaterSed   
#EDW		#NewHurrSed = r"%s\\S%s_G%s_V%s_H%sHURRSED" % (Intermediate_Files_GDB, Scenario, Group, Version, RegionCode)

#EDW # no longer using separate hurricane sediment load - storms are in LandSed,EdgeSed,and WaterSed               
#EDW 		#lstReturns = SedimentDistribution(CurrentLW, CurrentTOPO, SubsidenceRas, CurrentOM, CurrentBD, CurrentLandSed, CurrentEdgeSed, CurrentWaterSed, NewHurrSed, MaxAccretion, CurrentStageMax, 1)
        lstReturns = SedimentDistribution(CurrentLW, CurrentTOPO, CurrentEdge, SubsidenceRas, CurrentOM, CurrentBD, CurrentLandSed, CurrentEdgeSed, CurrentWaterSed, MaxAccretion, CurrentStageMax, 1, MEEflag,CompartmentPoly,CompartmentPolyID_Field,BDWaterVal,RegimeChan,elapsedyear)
        CurrentTOPO = lstReturns[0]
        CurrentLW = lstReturns[1]
        #
        ##------------------------------------------------------------------------

        ##------------------------------------------------------------------------
        ## UPDATE DEM FROM BIMODE CROSS SHORE UPDATES
        ##------------------------------------------------------------------------
        ##PURPOSE: Reads in ASCII XYZ text files generated by BIMODE and updates the Topo/Bathy DEM
        ## called after SedimentDistribution, because BIMODE separately applies subsidence rate
        ## therefore, TopoBathy must be updated with BIMODE profiles AFTER subsidence is applied in this model
#HMV#        lstReturns = UpdateDEM(CurrentTOPO,BMprof_forWMfile,CurrentYear,InitCond_proj)
#HMV#        CurrentTOPO = lstReturns[0]




        ##------------------------------------------------------------------------
        ##SEA LEVEL RISE
        #
        #Parameters:(CurrentMWL, ChangeMWL, TopoBathy, LandWater, LULC, Salinity

        #Determine the stage (change mwl) raster name
        #
#EDW no longer updating MWL in SeaLevelRise() - therefore do not need CurrentChangeMWL - this raster is no longer generated in this model
#EDW       CurrentChangeMWL = r"%s\\S%s_G%s_V%s_H%sSTG%s_CHG" % (Intermediate_Files_GDB, Scenario, Group, Version, RegionCode, TwoDigitYr)

            #
#EDW no longer update MWL in SeaLevelRise() - therefore do not pass it CurrentChangeMWL
#EDW        lstReturns = SeaLevelRise(CurrentMWL, CurrentChangeMWL, CurrentTOPO, CurrentLW, CurrentLULC, CurrentSalinity)



        lstReturns = SeaLevelRise(CurrentMWL, CurrentTOPO, CurrentLW, CurrentLULC, CurrentSalinity, PreviousMWL,PreviousLULC,elapsedyear,BI_Mask,NoUpdateMask,BareGroundCollapse,AveSalinity)
        CurrentLW = lstReturns[0]
#EDW        CurrentMWL = lstReturns[1]             #EDW - no longer returns updated MWL (this calc has been removed from WM)
        lstLW1234.append(lstReturns[1])
#            lstLW1234.append(lstReturns[2])        #EDW - no longer returns updated MWL (this calc has been removed from WM)
            #
            ##------------------------------------------------------------------------

            ##------------------------------------------------------------------------
            ##UPDATE BULK DENSITY, ORGANIC MATTER, LULC WHERE LOSS/GAIN OCCURRED
            ##IN LOSSGAIN MODULE OR SLR
            #Parameters:
        if len(lstLW1234) > 0:
            IP_LW_1234 = r"%s\\LGSLR_LW_%s_vals1234" % (Intermediate_Files_GDB, CurrentYear)
            routCellStats = CellStatistics([lstLW1234], "MAXIMUM", "DATA")
            arcpy.CopyRaster_management(routCellStats, IP_LW_1234, "#", "#", "#", "#", "NONE", "4_BIT", "#", "#")
            del routCellStats
            lstReturns = Update_BD_OM_LULC(IP_LW_1234, CurrentBD, BDWaterVal, CurrentOM, OMWaterVal, CurrentLULC, HistoricMarshZones,Organic_In,BulkDensity_In, "LGSLR")

            CurrentBD = lstReturns[0]
            CurrentOM = lstReturns[1]
            CurrentLULC = lstReturns[2]
            lstLW1234 = []
        #
        ##------------------------------------------------------------------------
        
#        ##------------------------------------------------------------------------
#moved_to_end#        #SEND THE UPDATED LANDWATER AND TOPO TO DELIVERABLES FOLDER
#moved_to_end#        #
#moved_to_end#        SaveUpdated_LandWater_TOPO(CurrentLW, CurrentTOPO, CurrentLULC,CurrentMWL,CurrentSalinity,AveSalinity, "", ".img", elapsedyear,1,summaryzones,summaryzonesID,outputmaskfine,outputmaskcourse)
        
        ##------------------------------------------------------------------------

        ##------------------------------------------------------------------------
        ##PREPARE DELIVERABLES DERIVED FROM LANDWATER AND TOPO
        #percent land, percent shallow water, percent edge, average elevation
        #

        
#EDW        #if "Average Elevation" in lstDeliverables:
#EDW            #CreateAverageElevation(TopoBathy, ZonalRaster, zoneField, zoneCellSize, processingCellsize, outType)
        if ElevDeliverable == "TRUE":
            CreateAverageElevation(CurrentTOPO, ZonalGrid, GridField, 500, 10, ".img")

#EDW        #if "Percent Land" in lstDeliverables:
#EDW            #CreatePercentLand(LandWater, ZonalRaster, zoneCellSize, processingCellsize, outType)
        if PLandDeliverable == "TRUE":
            CreatePercentLand(CurrentLW, ZonalGrid, GridField, 500, 10, ".img")
        
#EDW        #if "Percent Shallow Water" in lstDeliverables:
#EDW            #CreatePercentShallowWater(LandWater, TopoBathy, MWL, ZonalRaster, zoneField, zoneCellSize, processingCellsize, lowWaterThreshold, outType):
        if PShalDeliverable == "TRUE":
            CreatePercentShallowWater(CurrentLW, CurrentTOPO, CurrentMWL, ZonalGrid, GridField, 500, 10, lowWaterThreshold, ".img")
        
        ##-------------------------------------------------------------------------
        ## Update files used for Ecohydro input attributes
        ##-------------------------------------------------------------------------
        lstReturns = CalculateEcohydroAttributes(CompartmentPoly,CompartmentPolyID_Field,GridPoly,GridPolyID_Field,CurrentTOPO,CurrentLULC,CurrentLW,CurrentYear,AssumedAreas,EHtemp_path,HSI_dir,n500grid,NavChan,NavChanID,elapsedyear)
        CurrentEdge=lstReturns[0]
        
        ##-------------------------------------------------------------------------
        ## HSI data processing
        ##-------------------------------------------------------------------------
        ## Calculate various water depth calculations needed for HSIs
        HSIDepCellSize = 30
#HMV#        HSIreclass(HSIDepCellSize,HSI_dir,CurrentTOPO,CurrentMWL,OctAprMWL,SepMarMWL,GridPoly,GridPolyID_Field)

        HSIpelican(CurrentLULC,CurrentLW,HSI_dir,GridPoly,GridPolyID_Field,CurrentYear,HSIDepCellSize,n500grid,elapsedyear)
#EDW##------------------------------------------------------------------------------------------------------------------------------
#EDW##------------------------------------------------------------------------------------------------------------------------------        
#EDW    ##MODEL LOOP USED TO END HERE - EVERTHING BETWEEN HERE AND START OF MODEL LOOP USED TO BE INDENTED TO BE WITHIN THE FOR LOOP
#EDW##------------------------------------------------------------------------------------------------------------------------------
#EDW##------------------------------------------------------------------------------------------------------------------------------        

        ##------------------------------------------------------------------------
        
        ##------------------------------------------------------------------------        
        ##PREPARE INITIAL CONDITIONS GEODATABASE TO BE USED FOR NEXT CALL TO WETLAND MORPH MODEL
        ## Save final rasters to new geodatabase which will be used as initial conditions for next timestep
        SaveForNextInitConditions(wetland_morph_dir,elapsedyear,StartingTopo,CurrentTOPO,StartingLW,CurrentLW,StartingEdge,CurrentEdge,CurrentMWL,PreviousMWL_name)

        ##------------------------------------------------------------------------
        
        ##------------------------------------------------------------------------
        #SEND THE UPDATED LANDWATER AND TOPO TO DELIVERABLES FOLDER
        #
        SaveUpdated_LandWater_TOPO(CurrentLW, CurrentTOPO, CurrentLULC,CurrentMWL,CurrentSalinity,AveSalinity, "", ".img", elapsedyear,1,summaryzones,summaryzonesID,outputmaskfine,outputmaskcourse)
        
        
                                                            
        arcpy.Delete_management("in_memory")
        arcpy.Delete_management(Temp_Files_Path)
        
        if delete_temp == 'TRUE':
            arcpy.Delete_management(Intermediate_Files_Path)
            
        
        e = time.clock()
        ProcTimeMin = round((e-s)/60,2)
        msg0 = "\n----------------------------------------"
        msg1 = "--     MORPHOLOGY MODEL COMPLETED     --"
        msg2 = "----------------------------------------"
        msg3 = "--total runtime for  Morph model: %s minutes" % (ProcTimeMin)
            
        print msg0
        print msg1
        print msg2
        print msg3        
#        arcpy.AddMessage(msg0)
#        arcpy.AddMessage(msg1)
#        arcpy.AddMessage(msg2)
#        arcpy.AddMessage(msg3)
        
    except Exception, e:
        # If an error occurred, print line number and error message
        import traceback, sys
        tb = sys.exc_info()[2]
        msg1 = "Line %i" % tb.tb_lineno
        msg2 = e.message
#        arcpy.AddWarning(msg1)
#        arcpy.AddWarning(msg2)
        print msg1
        print msg2

if __name__ == "__main__":
    main()
    
