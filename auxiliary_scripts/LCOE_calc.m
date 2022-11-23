function [LCOE_qlow, LCOE_med, LCOE_qup] = ...
                    LCOE_calc(onshore_sites_sub,power_curves_specs,dist_vert,dist_hor,height)


    capex = zeros(size(power_curves_specs,2),1);

    for i = 1:size(power_curves_specs,1)
        capex(i,1) = cost_model_onshore(power_curves_specs(i,3),1,power_curves_specs(i,4),height,1,power_curves_specs(i,9))/power_curves_specs(i,3);
    end

    lifetime = 20;
    disc_rate = 0.1;
    CRF = disc_rate*(1+disc_rate)^lifetime/((1+disc_rate)^lifetime-1);

    cap_dens = dist_vert*dist_hor*(power_curves_specs(:,4)/1000).^2;
    nb_turb = floor(onshore_sites_sub(:,2)./cap_dens');
    P_wind_farm = nb_turb.*power_curves_specs(:,3)';
   
    CAPEX = P_wind_farm.*capex';
    OPEX = 0.7126*1.48*(10.7*P_wind_farm + 0.020108*onshore_sites_sub(:,4:end)*1000); %conversion MWh to kWh

    LCOE = (CAPEX*CRF+OPEX)./onshore_sites_sub(:,4:end)/10; % conversion from USD/MWh to USc/kWh

    LCOE_med = round(median(LCOE,2,'omitnan'),2);
    LCOE_qlow = round(prctile(LCOE,25,2),2);
    LCOE_qup = round(prctile(LCOE,75,2),2);

end