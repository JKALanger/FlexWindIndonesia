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
% Dear reader, this is the code we used to convert the raw .nc files of the
% ERA5 dataset to a single MAT file. Due to memory limitations, we created
% four datasets covering the analysis period of 20 years. The chunks cover
% the periods 2001-2005, 2006-2010, 2011-2015, and 2016-2020. Therefore, you
% have to change the filename of the .mat file at the bottom of the code.
% 
% At the time of the study, the main author just started to use MATLAB, so
% the code is far from perfect in terms of performance.

clc;
clear;

% load the file storing the location of all relevant ERA5 data points (i.e. the points close to suitable onshore wind farm sites). 
% mat file 

filereducer = round(table2array(readtable('Site_Reducer_ERA5_Onshore.csv')),2);
titles = {};

% Store the longitude and latiude of all relevant ERA5 data points as
% titles for the table variable later (it would have been much better to
% use struct than tables)

for a = 1:size(filereducer,1)
    titles{a} = append('Long: ', num2str(filereducer(a,1)),' Lat: ',num2str(filereducer(a,2)));
end


%% Step 1: Creating 5-year wind profiles at 100m

tic

% change num_file for each chunk, don't forget to rename the output file's
% name too!

for num_file = 1

    time_origin = datetime(append('1900-01-01 00:00:00')); 
    % assuming that the ERA5 data is named ERA5_1.nc, ERA5_2.nc etc.
    windnc = append('ERA5_', num2str(num_file),'.nc');
    info = ncinfo(windnc); % change file name
    
    long = round(ncread(windnc,'longitude'),2);
    lat = round(ncread(windnc,'latitude'),2);
    
    timehours = ncread(windnc,'time');
    timestamp = time_origin+hours(timehours);    


    U100m = ncread(windnc,'u100'); 
    V100m = ncread(windnc,'v100');
    W100m = round(sqrt(U100m.^2+V100m.^2),2);
    
    % to avoid out-of-memory error, we remove the U and V components from
    % the workspace
    clear U100m;
    clear V100m;
        
    prof_100m = zeros(size(W100m,3),size(filereducer,1));    
       
    counter = 1;
    for i = 1:size(W100m,1)
        for j = 1:size(W100m,2)
           % Here we loop through all ERA5 profiles and check whether it is
           % relevant for our analysis later (i.e. whether the ERA5 data
           % point is close to an onshore wind farm site)
           coord = [long(i,1); lat(j,1)];

           for x = 1:size(filereducer,1)
               if abs(coord(1,1)-filereducer(x,1)) < 1E-3 && abs(coord(2,1)-filereducer(x,2)) < 1E-3
                   suitable = 1;
                   break;
               else
                   suitable = 0;
               end
           end
           if suitable == 0
               continue;
           else
               %Processing the remaining sites                              
               prof_100m(:,counter) = W100m(i,j,:);
               counter = counter + 1;               
           end
        end
    end       
toc
end

clear W100m;

%% Clean data from outliers using a two-weeks moving time window

for m = 1:size(filereducer,1)
    prof_100m(:,m) = round(filloutliers(prof_100m(:,m),'linear','movmedian',336),2);
end

prof_100m = array2table(prof_100m,'VariableNames',titles);
prof_100m.Time = timestamp;

% %IMPACT OF DATA CLEANING, JUST FOR THE PAPER
% for m = 1:size(filereducer,1)
%     prof_100m_interp(:,m) = round(filloutliers(prof_100m(:,m),'linear','movmedian',336),2);
% end

% count_off = 0;
% 
% for f = 1:size(prof_100m,1)
%     for g = 1:size(prof_100m,2)
%         if round(prof_100m(f,g),2) - prof_100m_interp(f,g) > 1E-3
% %             round(prof_100m(f,g),2)
% %             prof_100m_interp(f,g)
%             count_off = count_off + 1;
%         end
%     end
% end


% Save 5-year wind speed height profiles
save('ERA5_2001-2005_100m_Onshore.mat','prof_100m','-v7.3');
