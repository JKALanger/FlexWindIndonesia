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
% Dear reader, this is the code used for the sensitivity analysis (Figure
% 10) of the paper.

% First, the tech pot, LCOE, and eco pot must be calculated repeatedly for
% all +/- 20% cases.

sens = readtable('Sensitivities_Onshore_v2.0.csv','VariableNamingRule','preserve');

data = zeros(6,3,2);
row = 1;
column = 2;
for group = 1:6
    for stack = 1:3
        for element = 1:2
            data(group,stack,element) = sens{row,column}*100;
            column = column + 1;
            if column == 8
                column = 2;
                row = row + 1;
            end
        end
    end
end

X = {'Wind Speed','Hub Height','BPP','CAPEX','Discount Rate','OPEX'};

% Code for stacked bar chart by Evan (2022). Plot Groups of Stacked Bars 
% https://www.mathworks.com/matlabcentral/fileexchange/32884-plot-groups-of-stacked-bars), 
% MATLAB Central File Exchange. Retrieved November 21, 2022. 

NumGroupsPerAxis = size(data, 1);
NumStacksPerGroup = size(data, 2);

% Count off the number of bins
groupBins = 1:NumGroupsPerAxis;
MaxGroupWidth = 0.65; % Fraction of 1. If 1, then we have all bars in groups touching
groupOffset = MaxGroupWidth/NumStacksPerGroup;
f = figure;
f.WindowState = 'maximized';
hold on; 
count = 1;
for i=1:NumStacksPerGroup

    Y = squeeze(data(:,i,:));
    
    % Center the bars:
    
    internalPosCount = i - ((NumStacksPerGroup+1) / 2);
    
    % Offset the group draw positions:
    groupDrawPos = (internalPosCount)* groupOffset + groupBins;
    
    h(i,:) = bar(Y, 'stacked');
    set(h(i,:),'BarWidth',groupOffset);
    set(h(i,:),'XData',groupDrawPos);
    if count == 1
        set(h(i,1),{'FaceColor'},{'#3d68f5'});
        set(h(i,2),{'FaceColor'},{'#9fb3f5'});
        set(h(i,1),{'EdgeColor'},{'k'});
        set(h(i,2),{'EdgeColor'},{'k'});
        set(h(i,1),{'LineWidth'},{1});
        set(h(i,2),{'LineStyle'},{'--'});
        count = count + 1;
    elseif count == 2
        set(h(i,1),{'FaceColor'},{'#b03ecb'});
        set(h(i,2),{'FaceColor'},{'#e7b4f3'});
        set(h(i,1),{'EdgeColor'},{'k'});
        set(h(i,2),{'EdgeColor'},{'k'});
        set(h(i,1),{'LineWidth'},{1});
        set(h(i,2),{'LineStyle'},{'--'});
        count = count + 1;
    else
        set(h(i,1),{'FaceColor'},{'#46bd2e'});
        set(h(i,2),{'FaceColor'},{'#b3efa7'});
        set(h(i,1),{'EdgeColor'},{'k'});
        set(h(i,2),{'EdgeColor'},{'k'});
        set(h(i,1),{'LineWidth'},{1});
        set(h(i,2),{'LineStyle'},{'--'});
        count = count + 1;
    end
end

box on;
set(gca,'XTickMode','manual');
set(gca,'XTick',1:NumGroupsPerAxis);
set(gca,'XTickLabelMode','manual');
set(gca,'XTickLabel',X,'FontSize',14);
ylabel('Sensitivity [%]');
legend({'LCOE after a change of -20%','LCOE after a change of +20%','Technical potential after a change of -20%' ...
    ,'Technical potential after a change of +20%','Economic potential after a change of -20%',...
    'Economic potential after a change of +20%'},'FontSize',12);

print(gcf,'Figure_10_Sensitivity_Analysis_v2.0.png','-dpng','-r300');