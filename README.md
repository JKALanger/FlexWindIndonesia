# FlexWindIndonesia

Code and data underlying the paper "Introducing site selection flexibility to technical and economic onshore wind potential assessments: new method with application to Indonesia"

Authors: Jannis Langer1, Michiel Zaaijer2, Jaco Quist1, Kornelis Blok1

1Delft University of Technology, Faculty of Technology, Policy and Management, Department of Engineering Systems and Services
Jaffalaan 5 
2628 BX Delft
The Netherlands

2Delft University of Technology, Faculty of Aerospace Engineering
Kluyverweg 1
2629 HS Delft
The Netherlands

Corresponding author: Jannis Langer

Contact: j.k.a.langer@tudelft.nl

Jaffalaan 5 
2628 BX Delft
The Netherlands

Please note that we are not programmers, so please excuse inefficient or "dirty" code and feel free to contact us in case of bugs, mistakes, or suggestions for improvement. 

IMPORTANT: Due to upload limitations, not all original input data could be uploaded here. Please download the missing data from the 4TU repository under the DOI 10.4121/19625385 and link https://data.4tu.nl/articles/dataset/Data_underlying_the_paper_UNDER_REVIEW_Introducing_site_selection_flexibility_to_techno-economic_onshore_wind_potential_assessments_new_method_with_application_to_Indonesia_/19625385

The missing data are:
- ERA5_profiles.mat
- Onshore_Sites_v2.0.csv

++ Inventory of code and recommended work flow ++

The codes should be executed in the following order to obtain the technical and economic potential:

1. ERA5_nc_to_mat_conversion (ERA5 data from https://cds.climate.copernicus.eu/cdsapp#!/dataset/reanalysis-era5-single-levels?tab=overview)
2. Wind_Profile_Struct
3. Technical_Potential
4. Economic_Potential

From the folder auxiliary_scripts, the following functions must be called for the technical and economic potentials:
1. floor_wind_farm
2. cost_model_onshore
3. LCOE_calc

In the folder auxiliary_scripts, there are optional codes for data analysis and visualisation as shown in the paper:
1. Bias_Correction_Analysis
2. Check_for_Disproportional_Wind_Speeds
3. Analysis_Technical_Potential
4. Sensitivity_Analysis

In each code file, there are descriptions for used data, calculations and their underlying assumptions.
