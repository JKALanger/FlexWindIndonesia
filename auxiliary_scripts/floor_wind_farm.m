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
% Dear reader, this is one of the key functions of our analysis. When
% calculating the annual electricity production per finely subdivided
% polygon, we calculate the number of turbines fitting into the polygon
% area as a float. However, when those floats are aggregated per meshed
% polygon, they should result in an integer for the number of turbines. To
% ensure this, we use a floor function to calculate a correction factor
% that rounds the float number of turbines and their electricity production
% to the nearest integer.

% The main usefulness of this function is to filter out sites that fall
% below the minimum area to be considered for further analysis. For
% example, if most of a polygon falls inside an urban area (buffer), then
% this function removes the entire remaining polygon. The correction
% factors are usually not very big, so they don't influence the results
% a lot.

function [onshore_sites_floored, onshore_sites_sub, onshore_sites_sub_short] = ...
                    floor_wind_farm(onshore_sites,dist_vert,dist_hor,rotor_diameter)
                                                
        % When making the onshore_sites file, we have not considered the floor
        % function yet that limits the numbers of turbines within an area. We have
        % to do it now. 
        
        prod_unfloored = onshore_sites{:,25:52};
        prod_floored = zeros(size(prod_unfloored));
        onshore_sites_floored = onshore_sites;
        
        % for LCOE calculations, we aggregate the finely subdivided
        % polygons back to gridded ones
                
        [GC,GR] = groupcounts(onshore_sites{:,5});
        
        sub_area_new = zeros(size(GC,1),1);
        sub_prod_floored = zeros(size(GC,1),28);
        sub_GWA_100m = zeros(size(GC,1),1);
        

        row = 1;
        for i = 1:size(GC,1)                      
            if GC(i) == 1
                area = sum(onshore_sites{row,10});
                corr_fact = floor(area./(dist_vert*dist_hor*(rotor_diameter/1000).^2)).*(dist_vert*dist_hor*(rotor_diameter/1000).^2)./area;
                prod_floored(row,:) = round(prod_unfloored(row,:).*corr_fact,3);
                sub_prod_floored(i,:) = prod_floored(row,:);
                sub_GWA_100m(i,:) = mean(onshore_sites{row,11});
            else
                area = sum(onshore_sites{row:(row+GC(i)-1),10});
                corr_fact = floor(area./(dist_vert*dist_hor*(rotor_diameter/1000).^2)).*(dist_vert*dist_hor*(rotor_diameter/1000).^2)./area;
                prod_floored(row:(row+GC(i)-1),:) = round(prod_unfloored(row:(row+GC(i)-1),:).*corr_fact,3);
                sub_prod_floored(i,:) = sum(prod_floored(row:(row+GC(i)-1),:));
                sub_GWA_100m(i,:) = sum(onshore_sites{row:(row+GC(i)-1),11}.*(onshore_sites{row:(row+GC(i)-1),10}/area));
            end
                       
            sub_area_new(i,1) = area;          
            row = row + GC(i,1);
        end
        
        sub_prod_med = median(sub_prod_floored,2); % median elec gen
        sub_prod_qlow = prctile(sub_prod_floored,25,2); %25th percentile elec gen
        sub_prod_qup = prctile(sub_prod_floored,75,2); % 75th percentile elec gen
        
        onshore_sites_floored{:,25:52} = prod_floored;
        
        onshore_sites_sub = [GR sub_area_new sub_GWA_100m sub_prod_floored];
        onshore_sites_sub_short = [GR sub_area_new sub_GWA_100m sub_prod_qlow sub_prod_med sub_prod_qup];
             
end