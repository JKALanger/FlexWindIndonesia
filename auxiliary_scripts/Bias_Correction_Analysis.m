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
% Dear reader, this is the code used to analyse the bias correction factors
% per finely subdivided and meshed wind farm polygon. This code produced
% Figure 2 in the paper.

clear all
clc
close all
tic


%% Step 2: Evaluation of bias correction factors (i.e. Figure 2 in paper)

% load the file containing the bias correction factors per meshed polygon
% (needs to be prepared manually with GIS software, e.g. with QGIS using
% Zonal Statistics and Distance Matrix tools)

onshore_sites = readtable('Onshore_Sites_Electricity_v2.0.csv');
onshore_sites_meshed = readtable('Onshore_Sites_Bias_Correction_Meshed_Area_v2.0.csv');

size_points = 2;

figure1=figure('Position', [50, 50, 1200, 720]);

subplot(2,3,1)
R1 = corrcoef(onshore_sites_meshed{:,7},onshore_sites_meshed{:,10});
R1_sq = R1(2)^2;
scatter(onshore_sites_meshed{:,7},onshore_sites_meshed{:,10},size_points,'filled','MarkerFaceAlpha',0.15,'MarkerEdgeAlpha',0);
annotation('textbox',[.135 .86 .055 .04],'String',append('R^{2}=',num2str(round(R1_sq,2))));
box on
xlim([0 2000])
ylim([0 8])
yline(1)
ax = gca;
ax.XAxis.TickLabelFormat = '%,.0f';
xlabel('Elevation [m]')
ylabel('Bias Correction Factor')

subplot(2,3,2)
R2 = corrcoef(onshore_sites_meshed{:,8},onshore_sites_meshed{:,10});
R2_sq = R2(2)^2;
scatter(onshore_sites_meshed{:,8},onshore_sites_meshed{:,10},size_points,'filled','MarkerFaceAlpha',0.15,'MarkerEdgeAlpha',0);
annotation('textbox',[.56 .86 .055 .04],'String',append('R^{2}=',num2str(round(R2_sq,2))));
box on
title('Bias Correction over Gridded Polygons (sample = 23,078 polygons)',' ')
xlabel('Slope [°]')
xlim([0 30])
ylim([0 8])
yline(1)
ylabel('Bias Correction Factor')

subplot(2,3,3)
R3 = corrcoef(onshore_sites_meshed{:,6},onshore_sites_meshed{:,10});
R3_sq = R3(2)^2;
scatter(onshore_sites_meshed{:,6},onshore_sites_meshed{:,10},size_points,'filled','MarkerFaceAlpha',0.15,'MarkerEdgeAlpha',0);
annotation('textbox',[.84 .86 .055 .04],'String',append('R^{2}=',num2str(round(R3_sq,2))));
box on
xlabel('GWA Wind Speed [m/s]')
ylabel('Bias Correction Factor')
ylim([0 8])
xlim([0 15])
yline(1)

subplot(2,3,4)
R1 = corrcoef(onshore_sites{:,16},onshore_sites{:,14});
R1_sq = R1(2)^2;
scatter(onshore_sites{:,16},onshore_sites{:,14},size_points,'filled','MarkerFaceAlpha',0.15,'MarkerEdgeAlpha',0);
annotation('textbox',[.135 .385 .055 .04],'String',append('R^{2}=',num2str(round(R1_sq,2))));
box on
xlim([0 2000])
ylim([0 8])
yline(1)
ax = gca;
ax.XAxis.TickLabelFormat = '%,.0f';
xlabel('Elevation [m]')
ylabel('Bias Correction Factor')

subplot(2,3,5)
R2 = corrcoef(onshore_sites{:,15},onshore_sites{:,14});
R2_sq = R2(2)^2;
scatter(onshore_sites{:,15},onshore_sites{:,14},size_points,'filled','MarkerFaceAlpha',0.15,'MarkerEdgeAlpha',0);
annotation('textbox',[.56 .385 .055 .04],'String',append('R^{2}=',num2str(round(R2_sq,2))));
box on
title('Bias Correction over Finely Subdivided Polygons (sample = 732,554 polygons)', ' ')
xlabel('Slope [°]')
xlim([0 30])
ylim([0 8])
yline(1)
ylabel('Bias Correction Factor')

subplot(2,3,6)
R3 = corrcoef(onshore_sites{:,11},onshore_sites{:,14});
R3_sq = R3(2)^2;
scatter(onshore_sites{:,11},onshore_sites{:,14},size_points,'filled','MarkerFaceAlpha',0.15,'MarkerEdgeAlpha',0);
annotation('textbox',[.84 .385 .055 .04],'String',append('R^{2}=',num2str(round(R3_sq,2))));
box on
ylim([0 8])
yline(1)
xlabel('GWA Wind Speed [m/s]')
ylabel('Bias Correction Factor')

print(gcf,'Figure_2_Bias_Correction_Factors_v2.0.png','-dpng','-r300');

