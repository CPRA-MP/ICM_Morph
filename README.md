# ICM_Morph v24.0.0 Release Notes

This release, v24.0.0, made the following updates to ICM-Morph v23.3.1:<br>
1. Previously, when determining whether a given marsh edge pixel was eligible for edge erosion during a given model year, a `CEILING` function was used when converting the annual edge erosion rate (meters/year) to the model year in which that rate would result in an eroded pixel. For example, an edge retreat rate of 4.9 m/yr would require 6.12 years to erode one 30-meter pixel of marsh edge. The `CEILING` function would result in edge erosion of that pixel to occur in model year 7. This update, now uses `NINT` (Fortran's intrinsic rounding function) for this calculation, instead of `CEILING`. Therefore, for the same example, the pixel will now be lost due to edge erosion in model year 6, instead of model year 7.
2. Previously, the surface elevation of eroded edge pixel was lowered by a set amount the year in which it was eroded. The magnitude of this lowering was passed into the model via **input_params.csv** as the variable `me_lowerDepth_m` (a value of 0.25-m was used for all simulations conducted for the 2023 Coastal Master Plan). This code update, instead of using a pre-set value, now updates the elevation of an eroded pixel to be equal to the elevation of the nearest water body bottom. This change was implemented due to an analysis in which it was seen that previously eroded edge pixels were set higher than nearby water bodies (e.g., the original depth was noticeably greater than the 0.25-m value used). This would result in the occasional edge pixel to pop-up as land gain in later years due to an unreasbonably shallow depth assumption. <br>


### References

Reed, D., Wang, Y., & White, E.D. (2024). *2029 Coastal Master Plan: Task 5.1: Marsh Edge Erosion Sensitivity Tests. Version 1.* (pp. 21). Baton Rouge, Louisiana: Coastal Protection and Restoration Authority.

---

# ICM_Morph v23.3.1 Release Notes

ICMv23.3.1 was the official, final, version of ICM-Morph (coded in Fortran) used for the 2023 Coastal Master Plan simulations. Refer to Foster-Martinez, et al., (2023) for the technical documentation for ICM-Morph v23.2.1. Refer to Couvillion et al., (2008) for the theoretical documentation and White et al., (2017) for the conceptual framework of ICM-Morph.

### References

Couvillion B., Steyer, G., Wang, H., Beck, H., and Rybczyk, J. (2013). [Forecasting the effects of coastal protection and restoration projects on wetland morphology in coastal Louisiana under multiple environmental uncertainty scenarios.](https://www.jstor.org/stable/23486535) In: Peyronnin, N.S. and Reed D.J. (eds.), Louisiana’s 2012 Coastal Master Plan Technical Analysis. *Journal of Coastal Research*, 67, 29-50.

Foster-Martinez, M., White, E., Jarrell, E., Reed, D., & Visser, J. (2023). [*2023 Coastal Master Plan: Attachment C8: Modeling Wetland Vegetation and Morphology: ICM-LAVegMod and ICM-Morph.*](https://coastal.la.gov/wp-content/uploads/2024/02/C8_ICM-LAVegModICM-Morph_v2.pdf) Version 2. (p. 59). Baton Rouge, Louisiana: Coastal Protection and Restoration Authority.

White, E.D., Meselhe, E, McCorquodale, A, Couvillion, B, Dong, Z, Duke-Sylvester, S.M., & Wang, Y. (2017). [*2017 Coastal Master Plan: Attachment C2-22: Integrated Compartment Model (ICM) Development.*](https://coastal.la.gov/wp-content/uploads/2017/04/Attachment-C3-22_FINAL_03.07.2017.pdf) Version Final. (pp. 1-49). Baton Rouge, Louisiana: Coastal Protection and Restoration Authority.
