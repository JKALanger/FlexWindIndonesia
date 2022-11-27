% Code used for the paper "Introducing site selection flexibility to technical and economic onshore wind potential assessments: new method with application to Indonesia"
% Authors: Jannis Langer1, Michiel Zaaijer2, Jaco Quist1, Kornelis Blok1
% 
% 1Delft University of Technology, Faculty of Technology, Policy and Management, Department of Engineering Systems and Services
% Jaffalaan 5 
% 2628 BX Delft
% The Netherlands
% 
% 2Delft University of Technology, Faculty of Aerospace Engineering
% Kluyverweg 1
% 2629 HS Delft
% The Netherlands
% 
% Corresponding author: Jannis Langer
% Contact: j.k.a.langer@tudelft.nl
% 
% Jaffalaan 5 
% 2628 BX Delft
% The Netherlands
%
% Corresponding author: Jannis Langer, j.k.a.langer@tudelft.nl
% 
% Dear reader, this is the code used to combine the chunked wind speed profiles from the "ERA5_nc_to_mat_conversion" code into one .mat file. 

clc

% Load the four chunked wind profile files

wind_a = load('[path]\ERA5_2001-2005_100m_Onshore.mat');
wind_b = load('[path]\ERA5_2006-2010_100m_Onshore.mat');
wind_c = load('[path]\ERA5_2011-2015_100m_Onshore.mat');
wind_d = load('[path]\ERA5_2016-2020_100m_Onshore.mat');

ERA5_points = readmatrix('[path]\Site_Reducer_ERA5_Onshore','VariableNamingRule','preserve');

A = table2array(wind_a.prof_100m);
B = table2array(wind_b.prof_100m);
C = table2array(wind_c.prof_100m);
D = table2array(wind_d.prof_100m);

E = [A; B; C; D];

timestamp = [datetime(2001,01,01,0,0,0):hours(1):datetime(2021,01,01,0,0,0)]';
timestamp(end) = [];

ERA5_data.time = timestamp;

means = mean(ERA5_data.profiles(61345:149016,:));

ERA5_data.means_for_GWA = means';

ERA5_points(:,4) = means';

writematrix(ERA5_points,'Site_Reducer_ERA5_Onshore_with_Averages.csv');

save('ERA5_Profiles.mat','ERA5_data', '-v7.3');

