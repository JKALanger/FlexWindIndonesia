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
% Dear reader, this is the code used for the analysis of the technical
% potential i.e. Figures 3, 4, and 5.

clear all
clc
close all
tic

%% Figure 3: Technical potential vs. site-property-flexible criteria

onshore_sites = readtable('Onshore_Sites_Electricity_v2.0.csv');
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

tech_pot_wind = zeros(10,32);
range_wind = [0 1 2 3 4 5 6 7 8 9];

tech_pot_ele = zeros(10,32);
range_ele = [0 200 400 600 800 1000 1200 1400 1600 1800 2000];

tech_pot_ele = zeros(10,32);
range_ele = [0 200 400 600 800 1000 1200 1400 1600 1800 2000];

tech_pot_slope = zeros(10,32);
range_slope = [0 3 6 9 12 15 18 21 24 27 30];

for i = 1:size(range_wind,2)
    onshore_sites_mod = onshore_sites;
    tech_pot_wind(i,1) = range_wind(i);
    onshore_sites_mod(onshore_sites_mod.GWA_100m < range_wind(i), :) = [];
    onshore_sites_floored = floor_wind_farm(onshore_sites_mod,dist_vert,dist_hor,rotor_diameter);
    tech_pot_wind(i, 2:29) = round(sum(onshore_sites_mod{:,25:52},'omitnan')/1000000,3);
    tech_pot_wind(i, 30) = prctile(tech_pot_wind(i,2:29),25);
    tech_pot_wind(i, 31) = prctile(tech_pot_wind(i,2:29),50);
    tech_pot_wind(i, 32) = prctile(tech_pot_wind(i,2:29),75);
end

for i = 1:size(range_ele,2)
    onshore_sites_mod = onshore_sites;
    tech_pot_ele(i,1) = range_ele(i);
    onshore_sites_mod = onshore_sites(onshore_sites.Elevation < range_ele(i), :);
    onshore_sites_floored = floor_wind_farm(onshore_sites_mod,dist_vert,dist_hor,rotor_diameter);
    tech_pot_ele(i, 2:29) = round(sum(onshore_sites_mod{:,25:52},'omitnan')/1000000,3);
    tech_pot_ele(i, 30) = prctile(tech_pot_ele(i,2:29),25);
    tech_pot_ele(i, 31) = prctile(tech_pot_ele(i,2:29),50);
    tech_pot_ele(i, 32) = prctile(tech_pot_ele(i,2:29),75);
end

for i = 1:size(range_slope,2)
    onshore_sites_mod = onshore_sites;
    tech_pot_slope(i,1) = range_slope(i);
    onshore_sites_mod = onshore_sites(onshore_sites.Slope < range_slope(i), :);
    onshore_sites_floored = floor_wind_farm(onshore_sites_mod,dist_vert,dist_hor,rotor_diameter);
    tech_pot_slope(i, 2:29) = round(sum(onshore_sites_mod{:,25:52},'omitnan')/1000000,3);
    tech_pot_slope(i, 30) = prctile(tech_pot_slope(i,2:29),25);
    tech_pot_slope(i, 31) = prctile(tech_pot_slope(i,2:29),50);
    tech_pot_slope(i, 32) = prctile(tech_pot_slope(i,2:29),75);
end

figure2=figure('Position', [50, 50, 1200, 320]);
subplot(1,3,1)
hold on
box on
plot(tech_pot_wind(:,1),tech_pot_wind(:,31))
x2 = [tech_pot_wind(:,1)' fliplr(tech_pot_wind(:,1)')];
inBetween = [tech_pot_wind(:,30)', fliplr(tech_pot_wind(:,32)')];
f = fill(x2, inBetween,'g');
ax = gca;
ax.YAxis.TickLabelFormat = '%,.0f';
set(f,'facecolor','#4e79f5');
set(f,'facealpha',0.15);
set(f,'edgecolor','none');
title('(a)');
xlabel('Minimum Average Wind Speed [m/s]');
ylabel('Technical Potential [TWh/year]');

subplot(1,3,2)
hold on
box on
plot(tech_pot_ele(:,1),tech_pot_ele(:,31))
x2 = [tech_pot_ele(:,1)' fliplr(tech_pot_ele(:,1)')];
inBetween = [tech_pot_ele(:,30)', fliplr(tech_pot_ele(:,32)')];
f = fill(x2, inBetween,'g');
ax = gca;
ax.YAxis.TickLabelFormat = '%,.0f';
ax.XAxis.TickLabelFormat = '%,.0f';
set(f,'facecolor','#4e79f5');
set(f,'facealpha',0.15);
set(f,'edgecolor','none');
title('(b)');
xlabel('Elevation [m]');
ylabel('Technical Potential [TWh/year]');

subplot(1,3,3)
hold on
box on
plot(tech_pot_slope(:,1),tech_pot_slope(:,31))
x2 = [tech_pot_slope(:,1)' fliplr(tech_pot_slope(:,1)')];
inBetween = [tech_pot_slope(:,30)', fliplr(tech_pot_slope(:,32)')];
f = fill(x2, inBetween,'g');
ax = gca;
ax.YAxis.TickLabelFormat = '%,.0f';
set(f,'facecolor','#4e79f5');
set(f,'facealpha',0.15);
set(f,'edgecolor','none');
title('(c)');
xlabel('Slope [°]');
ylabel('Technical Potential [TWh/year]');

print(gcf,'Figure_3_Impact_Flexible_Thresholds_v2.0.png','-dpng','-r300');

%% Figure 4 Demand Cover per Land Type

location = ["Indonesia","JavaBali","Sumatera","Kalimantan","Sulawesi","East"];
location_figure = ["Indonesia","Java & Bali","Sumatera","Kalimantan","Sulawesi","Nusa Tenggara, Maluku, and Papua"];

area_per_island =  [1890077 138249 476307 535330 185665 554528];
elec_gen_2030 = [445.096 292.345 84.949 27.042 24.754 16.006];
 
tech_pot_location_median = zeros(2,size(location,1)); 

% discussion of capacity factors in paper

% nb_turbs = onshore_sites_floored{:,10}./(dist_vert*dist_hor*(power_curves_specs(:,4)'.^2)/1000000);
% max_power = power_curves_specs(:,3)'/1000*8760.*nb_turbs;
% cf = round(onshore_sites_floored{:,25:end}./max_power,3);
% cf_median = median(cf,2);

fig = figure('Position',[1000 540 674 798]);

for i = 1:size(location,2)

    if i > 1
          sites_all = onshore_sites(strcmp(onshore_sites.Island, location(i)),:);
          sites_all_floored = floor_wind_farm(sites_all,dist_vert,dist_hor,rotor_diameter);
          sites_open = onshore_sites(strcmp(onshore_sites.Island, location(i)) & onshore_sites.Land_Type == 1,:);
          sites_open_floored = floor_wind_farm(sites_open,dist_vert,dist_hor,rotor_diameter);
    else
          sites_all = onshore_sites;
          sites_all_floored = floor_wind_farm(sites_all,dist_vert,dist_hor,rotor_diameter);
          sites_open = onshore_sites(onshore_sites.Land_Type == 1,:);
          sites_open_floored = floor_wind_farm(sites_open,dist_vert,dist_hor,rotor_diameter);
    end
    
    sites_all_floored = sortrows(sites_all_floored,'GWA_100m','descend');
    sites_open_floored = sortrows(sites_open_floored,'GWA_100m','descend');

    sites_all_qlow = prctile(cumsum(sites_all_floored{:,25:end},'omitnan'),25,2)/1000000;
    sites_all_median = median(cumsum(sites_all_floored{:,25:end},'omitnan'),2)/1000000;
    sites_all_qup = prctile(cumsum(sites_all_floored{:,25:end},'omitnan'),75,2)/1000000;
    
    tech_pot_location_median(1,i) = sites_all_median(end,1);
    
    sites_open_qlow = prctile(cumsum(sites_open_floored{:,25:end},'omitnan'),25,2)/1000000;
    sites_open_median = median(cumsum(sites_open_floored{:,25:end},'omitnan'),2)/1000000;
    sites_open_qup = prctile(cumsum(sites_open_floored{:,25:end},'omitnan'),75,2)/1000000;
    
    tech_pot_location_median(2,i) = sites_open_median(end,1);
     
    if i == 2
        sites_all_qlow(sites_all_qlow > elec_gen_2030(i)/2,:) = [];
        sites_all_median(sites_all_median > elec_gen_2030(i)/2,:) = [];
        sites_all_qup(sites_all_qup > elec_gen_2030(i)/2,:) = [];
    else
        sites_all_qlow(sites_all_qlow > elec_gen_2030(i),:) = [];
        sites_all_median(sites_all_median > elec_gen_2030(i),:) = [];
        sites_all_qup(sites_all_qup > elec_gen_2030(i),:) = [];
    end
    
    sites_all_floored(size(sites_all_median,1):end,:) = [];
    sites_all_floored = sortrows(sites_all_floored,'Land_Type');
    sites_all_qlow = prctile(cumsum(sites_all_floored{:,25:end},'omitnan'),25,2)/1000000;
    sites_all_median = median(cumsum(sites_all_floored{:,25:end},'omitnan'),2)/1000000;
    sites_all_qup = prctile(cumsum(sites_all_floored{:,25:end},'omitnan'),75,2)/1000000;
      
    sites_all_qup(size(sites_all_qup,1):size(sites_all_qlow,1),:) = sites_all_qup(size(sites_all_qup,1),1);
    
    sites_open_qlow(sites_open_qlow > elec_gen_2030(i),:) = [];  
    sites_open_median(sites_open_median > elec_gen_2030(i),:) = [];
    sites_open_qup(sites_open_qup > elec_gen_2030(i),:) = [];
    sites_open_qup(size(sites_open_qup,1):size(sites_open_qlow,1),:) = sites_open_qup(size(sites_open_qup,1),1);
    
    area_all_local = cumsum(sites_all_floored{1:size(sites_all_median,1),10},'omitnan')/area_per_island(i)*100;
    area_open_local = cumsum(sites_open_floored{1:size(sites_open_median,1),10},'omitnan')/area_per_island(i)*100;
    
    ax(i) = subplot(4,2,i);
    hold on
    box on
    h1(i) = plot(ax(i),area_all_local,sites_all_median,'-','LineWidth',1,'Color','#0a21fc'); 
    h2(i) = plot(ax(i),area_open_local,sites_open_median,'-','LineWidth',1,'Color','g'); 
    x2 = [area_all_local' fliplr(area_all_local')];
    inBetween = [sites_all_qlow(1:size(sites_all_median,1))', fliplr(sites_all_qup(1:size(sites_all_median,1))')];   
    f = fill(x2, inBetween,'g');
    set(f,'facecolor','#4e79f5');
    set(f,'facealpha',0.15);
    set(f,'edgecolor','none');
    
    x2_open = [area_open_local' fliplr(area_open_local')];
    inBetween_open = [sites_open_qlow(1:size(sites_open_median,1))', fliplr(sites_open_qup(1:size(sites_open_median,1))')];   
    f_open = fill(x2_open, inBetween_open,'g');
    set(f_open,'facecolor','#11df24');
    set(f_open,'facealpha',0.15);
    set(f_open,'edgecolor','none');
    
    title(location_figure(i));
    
    y_100 = yline(elec_gen_2030(i),'-','LineWidth',1,'Color','#6d0416');
    y_50 = yline(elec_gen_2030(i)/2,'-.','LineWidth',1,'Color','#9f2f42');
    y_25 = yline(elec_gen_2030(i)/4,':','LineWidth',1,'Color','#df687c');
       
    x_line_1 = sum(sites_all_floored{sites_all_floored.Land_Type < 2, 10});
    x_line_2 = sum(sites_all_floored{sites_all_floored.Land_Type < 3, 10});
    x_line_3 = sum(sites_all_floored{sites_all_floored.Land_Type < 4, 10});
    xl1 = xline(x_line_1/area_per_island(i)*100,'-','LineWidth',0.5,'Label','Open Land','Fontsize',7);
    if i == 1 || i == 2 || i == 3 || i == 5
        xl1.LabelHorizontalAlignment = 'center';
    else
        xl1.LabelHorizontalAlignment = 'left';
    end
    
    xl2 = xline(x_line_2/area_per_island(i)*100,'-','LineWidth',0.5,'Label','Agriculture','Fontsize',7);
    xl2.LabelHorizontalAlignment = 'left';
    xl3 = xline(x_line_3/area_per_island(i)*100,'-','LineWidth',0.5,'Label','Forestry','Fontsize',7);
    xl3.LabelHorizontalAlignment = 'left';
    xl4 = xline(sum(sites_all_floored{:,10})/area_per_island(i)*100,'-','LineWidth',0.5,'Label','Rest','Fontsize',7);
    xl4.LabelHorizontalAlignment = 'left';
    if i == 4 || i == 5 
        xl4.LabelHorizontalAlignment = 'center';
    else
        xl4.LabelHorizontalAlignment = 'left';
    end
    if max(sites_all_qup) > elec_gen_2030(i)
        ylim([0 max(sites_all_qup)*1.5]);
    else
        ylim([0 elec_gen_2030(i)*1.5]);
    end
        
    if i == 5 || i == 6
        xlabel('Percentage of Regional Land Area [%]')
    end
    
    if i == 3
        ylabel('Technical Potential [TWh/year]')
    end
    
end

hLegend = subplot(4,2,7.5);
posLegend = get(hLegend,'Position');

leg = legend(hLegend,[h1(1);h2(1);f;y_100;y_50;y_25],'Best Sites of All Land Types', 'Open Land','25^{th}-75^{th} Percentile','100% E_{gen,2030}','50% E_{gen,2030}','25% E_{gen,2030}','NumColumns',2);
axis(hLegend,'off');
set(leg,'Position',posLegend);

print(gcf,'Figure_4_Demand_Coverage_per_Land_v2.0.png','-dpng','-r300');

%% Figure 5: Impact Infrastructure on Potential

x_subs = categorical({'\leq 10 km','\leq 100 km','No restriction'});
x_subs = reordercats(x_subs,{'\leq 10 km','\leq 100 km','No restriction'});
sites_pot_norm = zeros(3,4);
colours = {'#98b3f5','#f5d798','#f4f598','#dc98f5'};

fig = figure('Position',[50 0 1000 798]);
tiledlayout(7,3);

for i = 1:size(location,2)
    for j = 1:size(x_subs,2)
        
        if i > 1
            sites = onshore_sites_floored(strcmp(onshore_sites.Island, location(i)),:);
        else
            sites = onshore_sites_floored;
        end
        
        norm = median(sum(sites{:,25:52},'omitnan'),2);        
        
        if j ~= size(x_subs,2)
            sites{:,25:52} = sites{:,25:52}.*(sites{:,20+j}./sites{:,10});
        end
               
        sites_pot_norm(j,:) = [median(sum(sites{find(sites.Land_Type == 1),25:52},'omitnan'),2),...
            median(sum(sites{find(sites.Land_Type == 2),25:52},'omitnan'),2),...
            median(sum(sites{find(sites.Land_Type == 3),25:52},'omitnan'),2),...
            median(sum(sites{find(sites.Land_Type == 4),25:52},'omitnan'),2)]./norm.*100;       
    end
    
    ax(i) = nexttile(i*3-2,[1 1]);
    h = barh(ax(i),x_subs,sites_pot_norm,'stacked');
    
    norm = norm/1000000;

    f = [1 2 3 4];
    x_100 = xline(elec_gen_2030(i)/norm*100,'-','LineWidth',1,'Color','#6d0416');
    v = [elec_gen_2030(i)/norm*100-1.25 0; elec_gen_2030(i)/norm*100+1.25 0; elec_gen_2030(i)/norm*100+1.25 3.5; elec_gen_2030(i)/norm*100-1.25 3.5];    
    patch('Faces',f,'Vertices',v,'FaceColor','white','FaceAlpha',0.8,'EdgeColor','none')
    x_50 = xline(elec_gen_2030(i)/2/norm*100,'-.','LineWidth',1,'Color','#6d0416');
    v = [elec_gen_2030(i)/2/norm*100-1.25 0; elec_gen_2030(i)/2/norm*100+1.25 0; elec_gen_2030(i)/2/norm*100+1.25 3.5; elec_gen_2030(i)/2/norm*100-1.25 3.5];    
    patch('Faces',f,'Vertices',v,'FaceColor','white','FaceAlpha',0.8,'EdgeColor','none')
    
    if i < 4
        x_25 = xline(elec_gen_2030(i)/4/norm*100,':','LineWidth',1,'Color','#6d0416');
        v = [elec_gen_2030(i)/4/norm*100-1.25 0; elec_gen_2030(i)/4/norm*100+1.25 0; elec_gen_2030(i)/4/norm*100+1.25 3.5; elec_gen_2030(i)/4/norm*100-1.25 3.5];    
        patch('Faces',f,'Vertices',v,'FaceColor','white','FaceAlpha',0.8,'EdgeColor','none')
    end
        
    if i == 1
        title({'(a) Maximum distance to next substation', ' ', append(location_figure(i), ', relative to ', num2str(round(norm)),' TWh/year')}, 'fontweight', 'bold');
    elseif i == 6
        title({location_figure(i); append('relative to ', num2str(round(norm)),' TWh/year')});
    else
        title(append(location_figure(i), ', relative to ', num2str(round(norm)),' TWh/year'));
    end
        
    xlim([0 100])        
  
    if i == 6
        xlabel('Normalised Technical Potential [%]')
    end
end

hLegend = nexttile(19,[1 3]);
posLegend = get(hLegend,'Position');

leg = legend(hLegend,[h(1);h(2);h(3);h(4);x_100;x_50;x_25],'Open Land','Agriculture','Forestry','Rest','100% E_{gen,2030}','50% E_{gen,2030}','25% E_{gen,2030}','NumColumns',4);
axis(hLegend,'off');
set(leg,'Position',posLegend);

x_urb = categorical({'\geq 2.0 km','\geq 1.0 km','\geq 0.5 km'});
x_urb = reordercats(x_urb,{'\geq 2.0 km','\geq 1.0 km','\geq 0.5 km'});
sites_pot_norm = zeros(3,4);

for i = 1:size(location,2)
    for j = 1:size(x_urb,2)
        
        if i > 1
              sites = onshore_sites_floored(strcmp(onshore_sites_floored.Island, location(i)),:);
        else
              sites = onshore_sites_floored;
        end
        
        norm = median(sum(sites{:,25:52},'omitnan'),2);        
        
        if j ~= size(x_urb,2)
            sites{:,25:52} = sites{:,25:52}.*(sites{:,22+j}./sites{:,10});
        end
               
        sites_pot_norm(j,:) = [median(sum(sites{find(sites.Land_Type == 1),25:52},'omitnan'),2),...
            median(sum(sites{find(sites.Land_Type == 2),25:52},'omitnan'),2),...
            median(sum(sites{find(sites.Land_Type == 3),25:52},'omitnan'),2),...
            median(sum(sites{find(sites.Land_Type == 4),25:52},'omitnan'),2)]./norm.*100;        
    end
    
    ax(i) = nexttile(i*3-1);
    h = barh(ax(i),x_urb,sites_pot_norm,'stacked');
    
    norm = norm/1000000;

    f = [1 2 3 4];
    x_100 = xline(elec_gen_2030(i)/norm*100,'-','LineWidth',1,'Color','#6d0416');
    v = [elec_gen_2030(i)/norm*100-1.25 0; elec_gen_2030(i)/norm*100+1.25 0; elec_gen_2030(i)/norm*100+1.25 3.5; elec_gen_2030(i)/norm*100-1.25 3.5];    
    patch('Faces',f,'Vertices',v,'FaceColor','white','FaceAlpha',0.8,'EdgeColor','none')
    x_50 = xline(elec_gen_2030(i)/2/norm*100,'-.','LineWidth',1,'Color','#6d0416');
    v = [elec_gen_2030(i)/2/norm*100-1.25 0; elec_gen_2030(i)/2/norm*100+1.25 0; elec_gen_2030(i)/2/norm*100+1.25 3.5; elec_gen_2030(i)/2/norm*100-1.25 3.5];    
    patch('Faces',f,'Vertices',v,'FaceColor','white','FaceAlpha',0.8,'EdgeColor','none')
    if i < 4
        x_25 = xline(elec_gen_2030(i)/4/norm*100,':','LineWidth',1,'Color','#6d0416');
        v = [elec_gen_2030(i)/4/norm*100-1.25 0; elec_gen_2030(i)/4/norm*100+1.25 0; elec_gen_2030(i)/4/norm*100+1.25 3.5; elec_gen_2030(i)/4/norm*100-1.25 3.5];    
        patch('Faces',f,'Vertices',v,'FaceColor','white','FaceAlpha',0.8,'EdgeColor','none')
    end
    
    if i == 1
        title({'(b) Minimum distance from settlements', ' ',append(location_figure(i), ', relative to ', num2str(round(norm)),' TWh/year')}, 'fontweight', 'bold');
    elseif i == 6
        title({location_figure(i); append('relative to ', num2str(round(norm)),' TWh/year')});
    else
        title(append(location_figure(i), ', relative to ', num2str(round(norm)),' TWh/year'));
    end
    
    xlim([0 100])        
  
    if i == 6
        xlabel('Normalised Technical Potential [%]')
    end
end

x_road = categorical({'\geq 500 m','\geq 250 m','\geq 0 m'});
x_road = reordercats(x_road,{'\geq 500 m','\geq 250 m','\geq 0 m'});
sites_pot_norm = zeros(3,4);

for i = 1:size(location,2)
    for j = 1:size(x_road,2)
        
        if i > 1
              sites = onshore_sites_floored(strcmp(onshore_sites_floored.Island, location(i)),:);
        else
              sites = onshore_sites_floored;
        end
        
        norm = median(sum(sites{:,25:52},'omitnan'),2);        
        
        if j ~= size(x_road,2)
            sites{:,25:52} = sites{:,25:52}.*(sites{:,18+j}./sites{:,6});
        end
               
        sites_pot_norm(j,:) = [median(sum(sites{find(sites.Land_Type == 1),25:52},'omitnan'),2),...
            median(sum(sites{find(sites.Land_Type == 2),25:52},'omitnan'),2),...
            median(sum(sites{find(sites.Land_Type == 3),25:52},'omitnan'),2),...
            median(sum(sites{find(sites.Land_Type == 4),25:52},'omitnan'),2)]./norm.*100;      
    end
    
    ax(i) = nexttile(i*3);
    h = barh(ax(i),x_road,sites_pot_norm,'stacked');
    
    norm = norm/1000000;

    f = [1 2 3 4];
    x_100 = xline(elec_gen_2030(i)/norm*100,'-','LineWidth',1,'Color','#6d0416');
    v = [elec_gen_2030(i)/norm*100-1.25 0; elec_gen_2030(i)/norm*100+1.25 0; elec_gen_2030(i)/norm*100+1.25 3.5; elec_gen_2030(i)/norm*100-1.25 3.5];    
    patch('Faces',f,'Vertices',v,'FaceColor','white','FaceAlpha',0.8,'EdgeColor','none')
    x_50 = xline(elec_gen_2030(i)/2/norm*100,'-.','LineWidth',1,'Color','#6d0416');
    v = [elec_gen_2030(i)/2/norm*100-1.25 0; elec_gen_2030(i)/2/norm*100+1.25 0; elec_gen_2030(i)/2/norm*100+1.25 3.5; elec_gen_2030(i)/2/norm*100-1.25 3.5];    
    patch('Faces',f,'Vertices',v,'FaceColor','white','FaceAlpha',0.8,'EdgeColor','none')
    
    if i < 4
        x_25 = xline(elec_gen_2030(i)/4/norm*100,':','LineWidth',1,'Color','#6d0416');
        v = [elec_gen_2030(i)/4/norm*100-1.25 0; elec_gen_2030(i)/4/norm*100+1.25 0; elec_gen_2030(i)/4/norm*100+1.25 3.5; elec_gen_2030(i)/4/norm*100-1.25 3.5];    
        patch('Faces',f,'Vertices',v,'FaceColor','white','FaceAlpha',0.8,'EdgeColor','none')
    end
    
    if i == 1
        title({'(c) Minimum distance to major roads', ' ', append(location_figure(i), ', relative to ', num2str(round(norm)),' TWh/year')}, 'fontweight', 'bold');
    elseif i == 6
        title({location_figure(i); append('relative to ', num2str(round(norm)),' TWh/year')});
    else
        title(append(location_figure(i), ', relative to ', num2str(round(norm)),' TWh/year'));
    end
    
    xlim([0 100])        
  
    if i == 6
        xlabel('Normalised technical potential [%]')
    end
end

print(gcf,'Figure_5_Impact_Infrastructure_Potential_v2.0.png','-dpng','-r300');