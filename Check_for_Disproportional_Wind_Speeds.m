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
% Dear reader, with this code we analyse whether the bias correction of the
% ERA5 wind profiles resulted in disproportional wind speeds. This code
% produces Supplementary Figure 3.

clear all
clc
close all
tic

%% Disproportional wind speeds and supplementary figure 3

load('ERA5_Profiles.mat')
onshore_sites = readtable('Onshore_Sites_Electricity_v2.0.csv');

ERA5_data.max_v = max(ERA5_data.profiles)';

max_wind_corr = zeros(size(onshore_sites,1),6);

for i = 1:size(max_wind_corr)
    max_wind_corr(i,1:4) = [onshore_sites{i,7} onshore_sites{i,14}*ERA5_data.max_v(onshore_sites{i,17},1)...
                          onshore_sites{i,11} onshore_sites{i,14}];
    if max_wind_corr(i,3) >= 10
        max_wind_corr(i,5) = 70;
    elseif max_wind_corr(i,3) < 10 & max_wind_corr(i,3) >= 8.5
        max_wind_corr(i,5) = 59.5;
    elseif max_wind_corr(i,3) < 8.5 & max_wind_corr(i,3) >= 7.5
        max_wind_corr(i,5) = 52.5;
    else
        max_wind_corr(i,5) = 42;
    end
    if max_wind_corr(i,2) > max_wind_corr(i,5)
        max_wind_corr(i,6) = 1;
    else
        max_wind_corr(i,6) = 0;
    end
end

save('Max_Wind_Speeds_Corrected_v2.0.mat','max_wind_corr');

sum(max_wind_corr(:,6))

hold on
box on
h1 = histogram(ERA5_data.max_v,'Normalization','probability');
h1.BinEdges = [0:0.5:max(max_wind_corr(:,2))];
h2 = histogram(max_wind_corr(:,2),'Normalization','probability');
h2.BinEdges = [0:0.5:max(max_wind_corr(:,2))];
xlabel('Maximum Wind Speed [m/s]');
ylabel('Probability [%]');
ytix = get(gca, 'YTick');
set(gca, 'YTick',ytix, 'YTickLabel',ytix*100);

lgnd = legend('Uncorrected', 'Bias-Corrected');
% % 'Highest', 'Lowest', 

print(gcf,'Sup_Fig_2_v2.0.png','-dpng','-r300');
