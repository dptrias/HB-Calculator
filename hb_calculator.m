% ====================================================================================
%                               HB-Calculator
%                    MIT License, D. Perez Trias, 2024
% ====================================================================================

%% MAIN
function hb_calculator 
    HB = HydraulicBearing;

    fig = uifigure('Name', sprintf('HB-Calculator (version %s)',HB.version), 'Position', [100, 100, 1000, 600]);
    
    %% Input Data
    pnlGeometry = uipanel(fig,'Title','Bearing Data', 'BackgroundColor','white', 'Position', [50, 330, 250, 250]);

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

    pnlFluid = uipanel(fig, "Title", "Fluid Data", 'BackgroundColor','white', 'Position', [50, 220, 250, 110]);

    lblViscosity = uilabel(pnlFluid, 'Text', 'Fluid viscosity (mPa s):', 'Position', [10, 55, 120, 26]);
    txtViscosity = uieditfield(pnlFluid, 'numeric', 'Position', [135, 55, 100, 26]);
    txtViscosity.Value = HB.fluid.viscosity;
    txtViscosity.ValueChangedFcn = @(txt, event) set_viscosity(HB, txt.Value);

    lblExternal_Pressure = uilabel(pnlFluid, 'Text', 'External pressure (Pa):', 'Position', [10, 10, 135, 26]);
    txtExternal_Pressure = uieditfield(pnlFluid, 'numeric', 'Position', [135, 10, 100, 26]);
    txtExternal_Pressure.Value = HB.fluid.external_pressure;
    txtExternal_Pressure.ValueChangedFcn = @(txt, event) set_external_pressure(HB, txt.Value);

    pnlNumerical = uipanel(fig, "Title", "Numerical Settings", 'BackgroundColor','white', 'Position', [50, 110, 250, 110]);

    lblNodesx = uilabel(pnlNumerical, 'Text', 'Axial nodes:', 'Position', [10, 55, 100, 26]);
    txtNodesx = uieditfield(pnlNumerical, 'numeric', 'Position', [135, 55, 100, 26]);
    txtNodesx.Value = HB.numerical.Nx;
    txtNodesx.ValueChangedFcn = @(txt, event) set_nodesx(HB, txt.Value);

    lblNodestheta = uilabel(pnlNumerical, 'Text', 'Radial nodes:', 'Position', [10, 10, 100, 26]);
    txtNodestheta = uieditfield(pnlNumerical, 'numeric', 'Position', [135, 10, 100, 26]);
    txtNodestheta.Value = HB.numerical.Ntheta;
    txtNodestheta.ValueChangedFcn = @(txt, event) set_nodestheta(HB, txt.Value);

    %% Solve 
    axsPressure = uiaxes(fig, 'Position', [350, 190, 600, 400]);  
    axsLoad = uiaxes(fig,'Position', [350, 30, 70, 70]);
    sldColorDensity = uislider(fig, 'Position', [350 180 200 3], 'Limits', [5 30],'Value', 10, 'ValueChangedFcn', @(src, event) updateColorDensity(HB, axsPressure, axsLoad, src.Value));
    btnCalculate = uibutton(fig, 'Text', 'Calculate', 'Position', [50, 60, 250, 30], 'BackgroundColor', [0.9, 0.3, 0.3], ...
        'ButtonPushedFcn', @(btnCalculate, event) calculateBottonPushed(HB, axsPressure, axsLoad, sldColorDensity.Value));

end

function calculateBottonPushed(HB, axes_pressure, axes_load, color_density)
    HB.solve();
    HB.plot(axes_pressure, axes_load, color_density);
end

function updateColorDensity(HB, axes_pressure, axes_load, color_density)
    HB.plot(axes_pressure, axes_load, color_density);
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

function set_external_pressure(HB, txt)
    HB.fluid.external_pressure = txt;
end

function set_nodesx(HB, txt)
    HB.numerical.Nx = txt;
end

function set_nodestheta(HB, txt)
    HB.numerical.Ntheta = txt;
end