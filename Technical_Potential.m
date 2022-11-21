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
% Dear reader, this is the code used to calculate the technical potential
% of onshore wind power as annual electricity generation.

clear all
clc
close all
tic

%% Step 1: Calculate technical potential (i.e. electricity production)

% This code is used for the main analysis in section 3.2 of the paper and
% for the sensitivity analysis in section 3.4. For the latter, we adjust
% the studied inputs by +/- 20% and re-run the code below.

% load the wind speed profiles processed with the code "Wind_Profile_Struct.m"

load('ERA5_Profiles.mat');

% load the finely subdivided wind farm polygons (methods in sections 2.1
% and 2.2)

onshore_sites = readtable('Onshore_Sites_v2.0.csv', 'VariableNamingRule','preserve');

% load wind turbine information from manufacturer datasheets

power_curves = readmatrix('Power_Curves_Onshore.csv','VariableNamingRule','preserve');
power_curves(1,:) = [];
power_curves_specs = readmatrix('Power_Curves_Onshore_Specs.csv','VariableNamingRule','preserve');

elec_prod_sites = zeros(size(onshore_sites,1),size(power_curves,2)-1);

% turbine height and reference height of the ERA5 dataset (100 m)

height_ref = 100; %m
height = 100; %m

% Wind farm properties
rated_power = power_curves_specs(:,3)'; % kW
rotor_diameter = power_curves_specs(:,4)'; % m
drivetrain = power_curves_specs(:,8)';

dist_vert = 5; % vertical distance between turbines
dist_hor = 10; % horizontal distance between turbines

% Transmission, availability and wind farm efficiency
eff_farm = 0.88; % Bosch PhD Thesis
eff_avail = 0.97; % Bosch PhD Thesis
eff_total = eff_farm*eff_avail;

% here we loop through all polygons to calculate the annual electricity
% production. Depending on the size of the studied region, this can take
% several hours, so we advice to use a virtual machine.

for index_site = 1
%     :size(onshore_sites,1)
    
    if mod(index_site,10000) == 0   
       clc
       toc
       text = '%d percent complete (%d out of %d)';
       sprintf(text,round(index_site/size(onshore_sites,1)*100),index_site,size(onshore_sites,1))
    end
     
        alf = log(onshore_sites{index_site,11}/onshore_sites{index_site,12})/log(height_ref/50); %m
      
        v_ref = ERA5_data.profiles(:,onshore_sites{index_site,17}).*onshore_sites{index_site,14};
        v_ref(v_ref(:,1) < 0, :) = 0;       
        v = round(v_ref.*((height/height_ref)^alf),1);
        % Extract the unique values occuring in the series
        [GC,GR] = groupcounts(v);

        GR(GR(:,1) > 25, :) = [];

        % number of turbines inside finely subdivided polygon

        nb_turbines = onshore_sites{index_site,10}./(dist_vert.*rotor_diameter.*dist_hor.*rotor_diameter/1000/1000); % conversion from m2 to km2

        % modelling turbine power curves

        power_curves_interp = [GR interp1(power_curves(:,1),power_curves(:,2:end),GR)];

        elec_prod = zeros(1,size(power_curves_interp,2)-1);

        for x = 1:size(GR,1)
            elec_prod = elec_prod + GC(x).*power_curves_interp(x,2:end);
        end

        % annual electricity generation in MWh/year

        elec_prod_sites(index_site,:) = round(elec_prod/size(v,1).*nb_turbines*eff_total*8760/1000,3);
          
end

toc

elec_prod_sites = array2table(elec_prod_sites);
onshore_sites = [onshore_sites elec_prod_sites];

writetable(onshore_sites,'Onshore_Sites_Electricity_v2.0.csv');