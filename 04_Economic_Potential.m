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
% Dear reader, this is the code used for the economic analysis of onshore
% wind in Indonesia. The code generates Figures 6, 8, and 9 of the paper.

clear all
clc
close all
tic

%% LCOE calculation

onshore_sites = readtable('Onshore_Sites_Electricity_v2.0.csv','VariableNamingRule','preserve');

% load wind turbine information from manufacturer datasheets

power_curves = readmatrix('Power_Curves_Onshore.csv','VariableNamingRule','preserve');
power_curves(1,:) = [];
power_curves_specs = readmatrix('Power_Curves_Onshore_Specs.csv','VariableNamingRule','preserve');

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

elec_gen_2030 = [445.096 292.345 84.949 27.042 24.754 16.006];

% change to onshore_sites.GWA_100m >= 4 for Figure 7 (LCOE map)
sites_LCOE = onshore_sites(onshore_sites.GWA_100m >= 2, :);

[onshore_sites_floored, onshore_sites_sub] = floor_wind_farm(sites_LCOE,dist_vert,dist_hor,rotor_diameter);

[LCOE_qlow, LCOE_med, LCOE_qup] = LCOE_calc(onshore_sites_sub,power_curves_specs,dist_vert,dist_hor,height);

onshore_sites_sub = [onshore_sites_sub LCOE_qlow LCOE_med LCOE_qup];

figure()

scatter(onshore_sites_sub(:,3),onshore_sites_sub(:,33),5,'filled','MarkerFaceAlpha',0.15,'MarkerEdgeAlpha',0);
box on
xlim([0 10]);
ylim([0 150]);
xline(2);
xlabel('Weighted Average 100 m GWA Wind Speed [m/s]')
ylabel('Median LCOE [US$(2021)/kWh]')

print(gcf,'Figure_6_LCOE_vs_Subareas_v2.0.png','-dpng','-r300');

%% FIGURE 8: Cost-Supply Curve

land_type = 5;
colours = {'#0a21fc','#ff8f00','#26b902','#c529f2'};
figure

for type = 1:4
    land_type = land_type - 1;
    
    sites_cost_supply = onshore_sites(onshore_sites.Land_Type <= land_type & onshore_sites.GWA_100m >= 4, :);
    
    [onshore_sites_floored, onshore_sites_sub, onshore_sites_sub_short] = floor_wind_farm(sites_cost_supply,dist_vert,dist_hor,rotor_diameter);
    
    [LCOE_qlow, LCOE_med, LCOE_qup] = LCOE_calc(onshore_sites_sub,power_curves_specs,dist_vert,dist_hor,height);
    onshore_sites_sub_short = [onshore_sites_sub_short LCOE_qlow LCOE_med LCOE_qup];  
   
    LCOE_qlow = sortrows(onshore_sites_sub_short,7,'ascend');
    LCOE_qlow(isnan(LCOE_qlow(:,7)),:) = [];
    LCOE_med = sortrows(onshore_sites_sub_short,8,'ascend');
    LCOE_med(isnan(LCOE_med(:,8)),:) = [];
    LCOE_qup = sortrows(onshore_sites_sub_short,9,'ascend');
    LCOE_qup(isnan(LCOE_qup(:,9)),:) = [];
   
    tech_qlow = cumsum(LCOE_qlow(:,4),'omitnan')/1000000;
    tech_med = cumsum(LCOE_med(:,5),'omitnan')/1000000;
    tech_qup = cumsum(LCOE_qup(:,6),'omitnan')/1000000;
    
    hold on 
    x2 = [tech_qlow' fliplr(tech_qup')];
    inBetween = [LCOE_qup(:,9)', fliplr(LCOE_qlow(:,7)')];

    box on
    f = fill(x2, inBetween,'g');
    set(f,'facecolor',colours{type});
    set(f,'facealpha',0.15);
    set(f,'edgecolor','none');

    f_test = fill(0, 0,'k');
    set(f_test,'facecolor','#bababa');
    set(f_test,'facealpha',1);
    set(f_test,'edgecolor','none');

    p(type) = plot(tech_med,LCOE_med(:,8),'-','LineWidth',1,'Color',colours{type}); 
end

xlabel('Technical Potential [TWh/year]')
ylabel('LCOE [US¢(2021)/kWh]')

x_100 = xline(elec_gen_2030(1),'-','100% E_{gen,2030}','fontsize',8,'LineWidth',1,'Color','#6d0416');
x_50 = xline(elec_gen_2030(1)/2,'-.','50% E_{gen,2030}','fontsize',8,'LineWidth',1,'Color','#6d0416');
x_25 = xline(elec_gen_2030(1)/4,':','25% E_{gen,2030}','fontsize',8,'LineWidth',1,'Color','#9f2f42');
% 
l = legend([p(1), p(2), p(3), p(4), f_test],{'All Land Types', 'Open Land + Agriculture + Forest', 'Open Land + Agriculture', 'Only Open Land', '25^{th}-75^{th} Percentile'},'Fontsize',8,'Location','Southeast');
% 

print(gcf,'Figure_8_Cost_Supply_Curve_v2.0.png','-dpng','-r300');

%% FIGURE 9: Economic Potential vs. Carbon Tax

% the variables onshore_sites and onshore_sites_open below were prepared
% manually. These datasets list all relevant meshed polygons and their
% median annual electricity production, LCOE, regional BPP, and receivable
% tariff after adding the carbon tax from Supplementary Data 1.

onshore_sites = readtable('Onshore_Sites_Sub_Area_Carbon_Tax_v2.0.csv','VariableNamingRule','preserve');
onshore_sites_open = readtable('Onshore_Sites_Sub_Area_Carbon_Tax_Open_Land_v2.0.csv','VariableNamingRule','preserve');
currency = readmatrix('Currency_Conversion.csv','VariableNamingRule','preserve');

location = ["Indonesia","JavaBali","Sumatera","Kalimantan","Sulawesi","Rest"];
location_figure = ["Indonesia","Java & Bali","Sumatera","Kalimantan","Sulawesi","Nusa Tenggara, Maluku, and Papua"];

carbon_tax = [0 25 50 75 100 125 150];
price_hike = [0 2.55 5.1 7.65 10.2 12.75 15.3]; %see supplementary file 1, reflects carbon tax of [0 25 50 75 100 125 150] US$/tCO2eq

carb_tax_table = zeros(size(price_hike,2),size(location,2)+1);
carb_tax_table(:,1) = carbon_tax';

carb_tax_table_capped = carb_tax_table;

for tax = 1:size(price_hike,2)
    onshore_sites.FIT = (onshore_sites.BPP + price_hike(tax))*0.85*currency(2,3);
    eco_pot = onshore_sites(onshore_sites.LCOE_med <= onshore_sites.FIT,:);
    carb_tax_table(tax,2) = sum(eco_pot.Tech_Pot_med);
    for island = 2:(size(location,2))
        carb_tax_table(tax,island+1) = sum(eco_pot{strcmp(eco_pot.Island_Group, location(island)), 4});
        if sum(eco_pot{strcmp(eco_pot.Island_Group, location(island)), 4}) > elec_gen_2030(island)
            carb_tax_table_capped(tax,island+1) = elec_gen_2030(island);
        else
            carb_tax_table_capped(tax,island+1) = sum(eco_pot{strcmp(eco_pot.Island_Group, location(island)), 4});
        end
    end
end

carb_tax_table_open = zeros(size(price_hike,2),size(location,2)+1);
carb_tax_table_open(:,1) = carbon_tax';

carb_tax_table_capped_open = carb_tax_table_open;

for tax = 1:size(price_hike,2)
    onshore_sites_open.FIT = (onshore_sites_open.BPP + price_hike(tax))*0.85*currency(2,3);
    eco_pot_open = onshore_sites_open(onshore_sites_open.LCOE_med <= onshore_sites_open.FIT,:);
    carb_tax_table_open(tax,2) = sum(eco_pot_open.Tech_Pot_med);
    for island = 2:(size(location,2))
        carb_tax_table_open(tax,island+1) = sum(eco_pot_open{strcmp(eco_pot_open.Island_Group, location(island)), 4});
        if sum(eco_pot_open{strcmp(eco_pot_open.Island_Group, location(island)), 4}) > elec_gen_2030(island)
            carb_tax_table_capped_open(tax,island+1) = elec_gen_2030(island);
        else
            carb_tax_table_capped_open(tax,island+1) = sum(eco_pot_open{strcmp(eco_pot_open.Island_Group, location(island)), 4});
        end
    end
end

colour = {'#0a21fc','#ab0afc','#0afc24','#d1c205','#ec1402'};

figure9=figure('Position', [50, 50, 900, 700]);
box on

subplot(2,2,1)
area(carb_tax_table(:,1),carb_tax_table(:,3:end));

ylim([0 700])
title({'(a) Not Restricted by Elec. Demand', ' ', 'All Flexible Land'})
xlabel('Carbon Tax [US$(2021)/tCO_{2}e]')
ylabel({'Median Economic Potential', '[TWh/year]'})

f = [1 2 3 4];
y_100 = yline(elec_gen_2030(1),'-','LineWidth',1,'Color','#6d0416');
v = [carbon_tax(1) elec_gen_2030(1)-5;carbon_tax(end) elec_gen_2030(1)-5;carbon_tax(end) elec_gen_2030(1)+5;carbon_tax(1) elec_gen_2030(1)+5];    
patch('Faces',f,'Vertices',v,'FaceColor','white','FaceAlpha',0.8,'EdgeColor','none')
y_50 = yline(elec_gen_2030(1)/2,'-.','LineWidth',1,'Color','#6d0416');
v = [carbon_tax(1) elec_gen_2030(1)/2-5;carbon_tax(end) elec_gen_2030(1)/2-5;carbon_tax(end) elec_gen_2030(1)/2+5;carbon_tax(1) elec_gen_2030(1)/2+5];    
patch('Faces',f,'Vertices',v,'FaceColor','white','FaceAlpha',0.8,'EdgeColor','none')
y_25 = yline(elec_gen_2030(1)/4,':','LineWidth',1,'Color','#6d0416');
v = [carbon_tax(1) elec_gen_2030(1)/4-5;carbon_tax(end) elec_gen_2030(1)/4-5;carbon_tax(end) elec_gen_2030(1)/4+5;carbon_tax(1) elec_gen_2030(1)/4+5];    
patch('Faces',f,'Vertices',v,'FaceColor','white','FaceAlpha',0.8,'EdgeColor','none')

subplot(2,2,2)
area(carb_tax_table_capped(:,1),carb_tax_table_capped(:,3:end));

ylim([0 700])
title({'(b) Restricted by Elec. Demand', ' ', 'All Flexible Land'})
xlabel('Carbon Tax [US$(2021)/tCO_{2}e]')
ylabel({'Median Economic Potential', '[TWh/year]'})

f = [1 2 3 4];
y_100 = yline(elec_gen_2030(1),'-','100% E_{gen,2030}','fontsize',8,'LineWidth',1,'Color','#6d0416');
y_100.LabelHorizontalAlignment = 'left';
v = [carbon_tax(1) elec_gen_2030(1)-5;carbon_tax(end) elec_gen_2030(1)-5;carbon_tax(end) elec_gen_2030(1)+5;carbon_tax(1) elec_gen_2030(1)+5];    
patch('Faces',f,'Vertices',v,'FaceColor','white','FaceAlpha',0.8,'EdgeColor','none')
y_50 = yline(elec_gen_2030(1)/2,'-.','50% E_{gen,2030}','fontsize',8,'LineWidth',1,'Color','#6d0416');
y_50.LabelHorizontalAlignment = 'left';
v = [carbon_tax(1) elec_gen_2030(1)/2-5;carbon_tax(end) elec_gen_2030(1)/2-5;carbon_tax(end) elec_gen_2030(1)/2+5;carbon_tax(1) elec_gen_2030(1)/2+5];    
patch('Faces',f,'Vertices',v,'FaceColor','white','FaceAlpha',0.8,'EdgeColor','none')
y_25 = yline(elec_gen_2030(1)/4,':','25% E_{gen,2030}','fontsize',8,'LineWidth',1,'Color','#6d0416');
y_25.LabelHorizontalAlignment = 'left';
v = [carbon_tax(1) elec_gen_2030(1)/4-5;carbon_tax(end) elec_gen_2030(1)/4-5;carbon_tax(end) elec_gen_2030(1)/4+5;carbon_tax(1) elec_gen_2030(1)/4+5];    
patch('Faces',f,'Vertices',v,'FaceColor','white','FaceAlpha',0.8,'EdgeColor','none')

legend({'Java & Bali', 'Sumatera', 'Kalimantan', 'Sulawesi', ['Nusa Tenggara,' newline 'Maluku, and Papua']},'Location','Northeast')


subplot(2,2,3)
area(carb_tax_table_open(:,1),carb_tax_table_open(:,3:end));

ylim([0 75])
title('Only Open Land')
xlabel('Carbon Tax [US$(2021)/tCO_{2}e]')
ylabel({'Median Economic Potential', '[TWh/year]'})

f = [1 2 3 4];
y_25 = yline(elec_gen_2030(1)/4,':','LineWidth',1,'Color','#6d0416');
v = [carbon_tax(1) elec_gen_2030(1)/4-5;carbon_tax(end) elec_gen_2030(1)/4-5;carbon_tax(end) elec_gen_2030(1)/4+5;carbon_tax(1) elec_gen_2030(1)/4+5];    
patch('Faces',f,'Vertices',v,'FaceColor','white','FaceAlpha',0.8,'EdgeColor','none')

subplot(2,2,4)
area(carb_tax_table_capped_open(:,1),carb_tax_table_capped_open(:,3:end));

ylim([0 75])
title('Only Open Land')
xlabel('Carbon Tax [US$(2021)/tCO_{2}e]')
ylabel({'Median Economic Potential', '[TWh/year]'})

f = [1 2 3 4];
y_100 = yline(elec_gen_2030(1),'-','100% E_{gen,2030}','fontsize',8,'LineWidth',1,'Color','#6d0416');
y_100.LabelHorizontalAlignment = 'left';
v = [carbon_tax(1) elec_gen_2030(1)-5;carbon_tax(end) elec_gen_2030(1)-5;carbon_tax(end) elec_gen_2030(1)+5;carbon_tax(1) elec_gen_2030(1)+5];    
patch('Faces',f,'Vertices',v,'FaceColor','white','FaceAlpha',0.8,'EdgeColor','none')
y_50 = yline(elec_gen_2030(1)/2,'-.','50% E_{gen,2030}','fontsize',8,'LineWidth',1,'Color','#6d0416');
y_50.LabelHorizontalAlignment = 'left';
v = [carbon_tax(1) elec_gen_2030(1)/2-5;carbon_tax(end) elec_gen_2030(1)/2-5;carbon_tax(end) elec_gen_2030(1)/2+5;carbon_tax(1) elec_gen_2030(1)/2+5];    
patch('Faces',f,'Vertices',v,'FaceColor','white','FaceAlpha',0.8,'EdgeColor','none')
y_25 = yline(elec_gen_2030(1)/4,':','25% E_{gen,2030}','fontsize',8,'LineWidth',1,'Color','#6d0416');
y_25.LabelHorizontalAlignment = 'left';
v = [carbon_tax(1) elec_gen_2030(1)/4-5;carbon_tax(end) elec_gen_2030(1)/4-5;carbon_tax(end) elec_gen_2030(1)/4+5;carbon_tax(1) elec_gen_2030(1)/4+5];    
patch('Faces',f,'Vertices',v,'FaceColor','white','FaceAlpha',0.8,'EdgeColor','none')

print(gcf,'Figure_9_Economic_Potential_v2.0.png','-dpng','-r300');
