function [CAPEX, OPEX] = cost_model_onshore(rated_power,nb_turbines,rotor_diameter,hub_height,aep,drivetrain)

    %% Turbine characteristics (based on Fingersh et al. (2005)
%     clear  
%     clc
%     turb = 1;
%     rated_power = 2600; % kW
%     nb_turbines = 20;
%     rotor_diameter = 121.2; % m
%     hub_height = 90.1; % m
%     water_depth = 3.74; % m
%     dist_to_shore = 51.92; % km
%     aep = 9702576;
%     power_prod_ann{:,1};

    %% Currency conversion rate and NREL correction factor

    currency = readmatrix('Currency_Conversion.csv','VariableNamingRule','preserve');

    %% CAPEX Offshore Wind Farm

    % All costs are initially calculated for one turbine with a pre-defined
    % rated power. In the end, the CAPEX for the entire wind farm is calculated
    % by multiplying the turbine CAPEX with the number of turbines in the farm.

    % Turbine and Tower

    % Coefficient were adjusted using Stehly et al. (2019). A correction coefficient is
    % applied to all components to obtain a USD/kW similar to values from literature.

    coeff_corr = 0.593047;

    cp_blades = ((0.4019*(rotor_diameter/2)^3-955.24)+2.7445*(rotor_diameter/2)^2.5025)/(1-0.28)*3; % baseline design
    m_blades = (0.1452*(rotor_diameter/2)^2.9158)*3;
    m_hub = 0.954*m_blades/3+5680.3;
    cp_hub = m_hub*4.25;

    cp_pitch = 2.28*(0.2106*rotor_diameter^2.6578);

    m_cone = 18.5*rotor_diameter-520.5;
    cp_cone = m_cone*5.57;

    cp_low_speed_shaft = 0.1*rotor_diameter^2.887; % coefficient changed from 0.01 to 0.1 from NREL report

    m_bearing = (rotor_diameter*8/600-0.033)*0.0092*rotor_diameter^2.5;
    cp_bearing = 2*m_bearing*17.6;

    % ATTENTION FOR DIRECT DRIVE!
    
    if drivetrain == 1
        cp_gearbox = 0;
        cp_generator = rated_power*219.33;
        cp_mainframe = 1.96*627.28*rotor_diameter^0.85; % factor added due to discrepancies in NREL report
        m_mainframe = 1.96*1.228*rotor_diameter^1.953; % factor added due to discrepancies in NREL report
    else
        cp_gearbox = 16.45*rated_power^1.249;
        cp_generator = rated_power*65;
        cp_mainframe = 1.96*9.489*rotor_diameter^1.953; % factor added due to discrepancies in NREL report
        m_mainframe = 1.96*2.233*rotor_diameter^1.953; % factor added due to discrepancies in NREL report
    end

    cp_brake = 1.9894*rated_power-0.1141;
    
    cp_var_speed_elec = rated_power*79;

    cp_yaw = 2*(0.0339*rotor_diameter^2.964);

    m_platform = 0.125*m_mainframe;
    cp_platform = m_platform*8.7;

    cp_elec_connection = rated_power*40;

    cp_hydr_cooling = rated_power*12;

    cp_nacelle = rated_power*11.537+3849.7;

    cp_control_safety_monitoring = 35000;

    m_tower = 0.3973*pi()/4*rotor_diameter^2*hub_height-1414; % baseline design
    cp_tower = m_tower*1.5;

    % Here, the costs are converted to USD(2021), coeff_corr considers the
    % range of cost in literature.

    cp_turbine_tower = (cp_blades + cp_hub + cp_pitch + cp_cone + cp_low_speed_shaft + cp_bearing ...
        + cp_gearbox + cp_brake + cp_generator + cp_var_speed_elec + cp_yaw + cp_mainframe ...
        + cp_platform + cp_elec_connection + cp_hydr_cooling + cp_nacelle + cp_control_safety_monitoring + cp_tower)...
        *currency(20,3).*coeff_corr;

    cp_found = rated_power*59*currency(3,3); % adjusted using Stehly et al. (2020), conversion from USD(2019) to USD(2021)
    
    cp_staging = rated_power*44*currency(3,3); % replaces road and transport from NREL model
    %adjusted using Stehly et al. (2020), conversion from USD(2019) to USD(2021)
    
    cp_installation = rated_power*44*currency(3,3); % adjusted using Stehly et al. (2020), conversion from USD(2019) to USD(2021)
    
    cp_elec_interface = rated_power*145*currency(3,3); % adjusted using Stehly et al. (2020), conversion from USD(2019) to USD(2021)
    
    cp_engineering = rated_power*(16+18)*currency(3,3); % engineering and development
    %adjusted using Stehly et al. (2020), conversion from USD(2019) to USD(2021)
   
    cp_finance = rated_power*(34+86)*currency(3,3); % adjusted using Stehly et al. (2020), conversion from USD(2019) to USD(2021)
    
    % Total CAPEX for entire wind farm

    CAPEX = (cp_turbine_tower + cp_found + cp_staging  + cp_installation + cp_elec_interface + cp_engineering + cp_finance)*nb_turbines;
    capex = CAPEX/(rated_power*nb_turbines);
    
    % Calculate OPEX
    
    corr_op = 0.7126; 
    
    op_var = (0.007+0.00108).*aep*currency(20,3);
    op_fix = 10.7*rated_power*nb_turbines*currency(20,3);
    
    OPEX = (op_var + op_fix)*corr_op; 
end