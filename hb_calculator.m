% ====================================================================================
%                               HB-Calculator
%                    MIT License, D. Perez Trias, 2024
% ====================================================================================

%% MAIN
function hb_calculator
    version = '2024-09-17';

    fig = uifigure('Name', sprintf('HB-Calculator (version %s)', version), 'Position', [100, 100, 1000, 620]);
    
    tabGroup = uitabgroup(fig, 'Position', [0, 0, 1000, 620]);
    tabLoadCalculator = uitab(tabGroup, 'Title', 'Load Calculator');
    tabBearingDesigner = uitab(tabGroup, 'Title', 'Bearing Designer');

    % ============================= Load Calculator ======================================
    %% Input Data
    HB = HydraulicBearing;
    pnlGeometry = uipanel(tabLoadCalculator,'Title','Bearing Data', 'BackgroundColor','white', 'Position', [50, 330, 250, 250]);

    lblLength = uilabel(pnlGeometry, 'Text', 'Length (mm):', 'Position', [10, 194, 100, 26]);
    txtLength = uieditfield(pnlGeometry, 'numeric', 'Position', [135, 194, 100, 26]);
    txtLength.Value = HB.geom.length;
    txtLength.ValueChangedFcn = @(txt, event) set_length(HB, txt.Value);

    lblRadius = uilabel(pnlGeometry, 'Text', 'Radius (mm):', 'Position', [10, 148, 100, 26]);
    txtRadius = uieditfield(pnlGeometry, 'numeric', 'Position', [135, 148, 100, 26]);
    txtRadius.Value = HB.geom.radius;
    txtRadius.ValueChangedFcn = @(txt, event) set_radius(HB, txt.Value);

    lblShaft_Radius = uilabel(pnlGeometry, 'Text', 'Shaft radius (mm):', 'Position', [10, 102, 100, 26]);
    txtShaft_Radius = uieditfield(pnlGeometry, 'numeric', 'Position', [135, 102, 100, 26]);
    txtShaft_Radius.Value = HB.geom.shaft_radius;
    txtShaft_Radius.ValueChangedFcn = @(txt, event) set_shaft_radius(HB, txt.Value);

    lblExcentricity = uilabel(pnlGeometry, 'Text', 'Excentricity (mm):', 'Position', [10, 56, 100, 26]);
    txtExcentricity = uieditfield(pnlGeometry, 'numeric', 'Position', [135, 56, 100, 26]);
    txtExcentricity.Value = HB.geom.excentricity;
    txtExcentricity.ValueChangedFcn = @(txt, event) set_excentricity(HB, txt.Value);

    lblSpeed = uilabel(pnlGeometry, 'Text', 'Rotation speed (rpm):', 'Position', [10, 10, 120, 26]);
    txtSpeed = uieditfield(pnlGeometry, 'numeric', 'Position', [135, 10, 100, 26]);
    txtSpeed.Value = HB.geom.speed;
    txtSpeed.ValueChangedFcn = @(txt, event) set_speed(HB, txt.Value);

    pnlFluid = uipanel(tabLoadCalculator, 'Title', 'Fluid Data', 'BackgroundColor','white', 'Position', [50, 185, 250, 150]);

    lblViscosity = uilabel(pnlFluid, 'Text', 'Fluid viscosity (mPa s):', 'Position', [10, 90, 130, 26]);
    txtViscosity = uieditfield(pnlFluid, 'numeric', 'Position', [135, 90, 100, 26]);
    txtViscosity.Value = HB.fluid.viscosity;
    txtViscosity.ValueChangedFcn = @(txt, event) set_viscosity(HB, txt.Value);
    
    lblReference_Pressure = uilabel(pnlFluid, 'Text', 'External pressure (Pa):', 'Position', [10, 10, 135, 26]);
    txtReference_Pressure = uieditfield(pnlFluid, 'numeric', 'Position', [135, 10, 100, 26]);
    txtReference_Pressure.Value = HB.fluid.reference_pressure;
    txtReference_Pressure.ValueChangedFcn = @(txt, event) set_Reference_Pressure(HB, txt.Value);

    lblBoundary_Condition = uilabel(pnlFluid, 'Text', 'Boundary condition:', 'Position', [10, 50, 150, 26]);
    btgBoundary_Condition = uibuttongroup(pnlFluid, 'Position', [135, 40, 100, 45], 'SelectionChangedFcn', @(bg, event) changeBoundaryCondition(HB, bg, lblReference_Pressure));
    rbtOpen_Bearing = uiradiobutton(btgBoundary_Condition, 'Text', 'Open bearing', 'Position', [0, 25, 135, 15]);
    rbtSealed_Bearing = uiradiobutton(btgBoundary_Condition, 'Text', 'Sealed bearing', 'Position', [0, 5, 135, 15]);

    pnlNumerical = uipanel(tabLoadCalculator, 'Title', 'Numerical Settings', 'BackgroundColor','white', 'Position', [50, 80, 250, 110]);

    lblNodesx = uilabel(pnlNumerical, 'Text', 'Axial nodes:', 'Position', [10, 55, 100, 26]);
    txtNodesx = uieditfield(pnlNumerical, 'numeric', 'Position', [135, 55, 100, 26]);
    txtNodesx.Value = HB.numerical.Nx;
    txtNodesx.ValueChangedFcn = @(txt, event) set_nodesx(HB, txt.Value);

    lblNodestheta = uilabel(pnlNumerical, 'Text', 'Radial nodes:', 'Position', [10, 10, 100, 26]);
    txtNodestheta = uieditfield(pnlNumerical, 'numeric', 'Position', [135, 10, 100, 26]);
    txtNodestheta.Value = HB.numerical.Ntheta;
    txtNodestheta.ValueChangedFcn = @(txt, event) set_nodestheta(HB, txt.Value);

    %% Solve 
    axsPressure = uiaxes(tabLoadCalculator, 'Position', [350, 190, 600, 400]);  
    
    pnlResults = uipanel(tabLoadCalculator, 'Title', 'Results', 'BackgroundColor','white', 'Position', [360, 100, 250, 80]);
    lblLoad = uilabel(pnlResults, 'Text', 'Load (N):', 'Position', [10, 30, 230, 25]);
    lblMinPressure = uilabel(pnlResults, 'Text', 'Minumum pressure (Pa):', 'Position', [10, 10, 230, 25]);

    btnCalculate = uibutton(tabLoadCalculator, 'Text', 'Calculate', 'Position', [50, 30, 250, 30], 'BackgroundColor', [0.9, 0.3, 0.3], ...
        'ButtonPushedFcn', @(btnCalculate, event) calculateBottonPushed(HB, axsPressure, lblLoad, lblMinPressure));

    % ============================== Bearing Designer ====================================
    %% Input Data
    BD = BearingDesigner;
    pnlParameters = uipanel(tabBearingDesigner,'Title','Dimensionless Parameters', 'BackgroundColor','white', 'Position', [50, 330, 250, 250]);

    lblElongation = uilabel(pnlParameters, 'Text', 'Elongation:', 'Position', [10, 194, 100, 26]);
    txtElongation = uieditfield(pnlParameters, 'numeric', 'Position', [135, 194, 100, 26]);
    txtElongation.Value = BD.parameters.elongation;
    txtElongation.ValueChangedFcn = @(txt, event) set_elongation(BD, txt.Value);

    lblExcentricity = uilabel(pnlParameters, 'Text', 'Excentricity:', 'Position', [10, 148, 100, 26]);
    txtExcentricity = uieditfield(pnlParameters, 'numeric', 'Position', [135, 148, 100, 26]);
    txtExcentricity.Value = BD.parameters.excentricity;
    txtExcentricity.ValueChangedFcn = @(txt, event) set_excentricity(BD, txt.Value);
end

function calculateBottonPushed(HB, axes_pressure, lbl_load, lbl_mprs)
    HB.solve();
    HB.plot(axes_pressure);
    updateResultsLabel(HB, lbl_load, lbl_mprs);
end

function updateResultsLabel(HB, lbl_load, lbl_mprs)
    lbl_load.Text = sprintf('%-45s %10.2f','Load (N):', HB.load);
    lbl_mprs.Text = sprintf('%-28s %10.2f','Minumum pressure (Pa):', min(HB.pressure(:)));
end

function changeBoundaryCondition(HB, btg_boundary_condition, lbl_ref_prs)
    if "Open bearing" == btg_boundary_condition.SelectedObject.Text 
        HB.fluid.boundary_condition = 1;
        lbl_ref_prs.Text = 'External pressure (Pa):';
    elseif "Sealed bearing" == btg_boundary_condition.SelectedObject.Text 
        HB.fluid.boundary_condition = 2;
        lbl_ref_prs.Text = 'Injection pressure (Pa):';
    end
end

%% Setters
function set_length(HB, txt)
    HB.geom.length = txt;
end

function set_radius(HB, txt)
    HB.geom.radius = txt;
end

function set_shaft_radius(HB, txt)
    HB.geom.shaft_radius = txt;
end

function set_excentricity(HB, txt)
    HB.geom.excentricity = txt;
end

function set_speed(HB, txt)
    HB.geom.speed = txt;
end

function set_viscosity(HB, txt)
    HB.fluid.viscosity = txt;
end

function set_Reference_Pressure(HB, txt)
    HB.fluid.reference_pressure = txt;
end

function set_nodesx(HB, txt)
    HB.numerical.Nx = txt;
end

function set_nodestheta(HB, txt)
    HB.numerical.Ntheta = txt;
end