% ====================================================================================
%                               HB-Calculator
%                    MIT License, D. Perez Trias, 2024
% ====================================================================================

classdef HydraulicBearing < handle
        
    properties
        geom = bearing_geom();
        fluid = fluid_properties();
        numerical = numerical_settings();
        pressure = eye(2);
        load = 0;
    end
    
    methods
        % Constructor
        function HB = HydraulicBearing()
            % Default
        end 

        function solve(HB)
            solve_dimensionless(HB);
            scaling(HB);
        end

        function plot(HB, ax_prs)
            plot_pressure(HB, ax_prs);
        end
        
    end
   
end

function G = bearing_geom()
    G.length = 500; % mm
    G.radius = 20; % mm
    G.shaft_radius = 10; % mm
    G.excentricity = 2;% mm
    G.speed = 3000; % rpm
end

function N = numerical_settings()
    N.Nx = 100;
    N.Ntheta = 100;
end

function F = fluid_properties()
    F.viscosity = 1; % mPa s
    F.reference_pressure = 101325; % Pa
    F.boundary_condition = 1; % 1-Open(Deafault) / 2-Sealed
end

function [phi, f] = solve_dimensionless(HB)
    Lambda = 2*HB.geom.length/HB.geom.radius;
    epsilon = HB.geom.excentricity/(HB.geom.radius-HB.geom.shaft_radius);
    n = HB.numerical.Ntheta;
    m = HB.numerical.Nx;
    d_theta = 2*pi/n; 
    d_eta = 2/m; 
    theta = linspace(-pi,pi,n+1);
    a = zeros((n/2-1)*m/2,(n/2-1)*m/2);
    b = zeros((n/2-1)*m/2,1);
    d_theta2 = d_theta*d_theta;
    d_eta2 = d_eta*d_eta;
    Lambda2 = Lambda*Lambda;
    % Dimensionless Pressure
    for i=1:n/2-1
        xi = 1+epsilon*cos(theta(i+1));
        xi2 = xi*xi;
        xi3 = xi2*xi;
        stht = sin(theta(i+1));
        A = xi3/(d_theta2)-3*epsilon*stht*xi2/(2*d_theta);
        B = xi3/(d_theta2)+3*epsilon*stht*xi2/(2*d_theta);
        C = xi3/(d_eta2*Lambda2);
        D = C;
        E = -2*xi3*(1/d_theta2+1/(d_eta2*Lambda2));
        F = -stht;
        for j=1:m/2
            idx = j+(i-1)*m/2;
            a(idx,idx) = E;
            if j>1    
                a(idx,idx-1) = D;
            end
            if j<m/2
                a(idx,idx+1) = C;
            end
            if j==m/2
                a(idx,idx-1) = D + C;
            end
            if i>1
                a(idx,idx-m/2) = B;
            end
            if i<n/2-1
                a(idx,idx+m/2) = A;
            end
            b(idx,1) = F;
        end
    end
    x = a\b; 
    phi = zeros(m+1,n+1); 
    phi1 = reshape(x,m/2,n/2-1);
    phi2 = [phi1(1:m/2-1,:);flipud(phi1)];
    phi3 = -1*fliplr(phi2);
    phi(2:m,2:n/2) = phi2;
    phi(2:m,(n/2+2):n) = phi3;
    HB.pressure = phi;
    % Dimensionless Load 
    I1 = zeros(m/2+1,1);
    for i=1:m/2+1
        for j=1:n/2
            I1(i) = I1(i) + d_theta*0.5*(phi(i,j)*sin(theta(j)) + phi(i,j+1)*sin(theta(j+1)));
        end
    end
    I2 = 0;
    for i=1:m/2
        I2 = I2 + d_eta*0.5*(I1(i)+I1(i+1));
    end
    f = 4*I2*epsilon;
    HB.load = f;
end

function scaling(HB)
    % Pressure
    mu = HB.fluid.viscosity*1e-3; % Pa s
    Omega = HB.geom.speed*2*pi/60; % rad/s
    R = HB.geom.radius*1e-3; % m
    R_I = HB.geom.shaft_radius*1e-3; % m
    HB.pressure = (6*mu*Omega*R^2*HB.geom.excentricity/(R-R_I)^2)*HB.pressure + HB.fluid.reference_pressure; % Pa
    % Load
    % TODO
    % HB.load = HB.load * 
end

function plot_pressure(HB, ax_p)
    imagesc(ax_p, HB.pressure)
    % clim(ax_p, [min(HB.pressure(:)),max(HB.pressure(:))])
    colorbar(ax_p)
    xlabel(ax_p, "\theta")
    xticks(ax_p, linspace(1,HB.numerical.Ntheta+1,5))
    xticklabels(ax_p, {"-\pi","-\pi/2","0","\pi/2","\pi"})
    xlim(ax_p,[1, HB.numerical.Ntheta+1])
    ylabel(ax_p, "x", "Rotation", 0)
    yticks(ax_p, linspace(1,HB.numerical.Nx+1,5))
    L = HB.geom.length;
    yticklabels(ax_p, {num2str(L/2),num2str(L/4),"0",num2str(-L/4),num2str(-L/2)})
    ylim(ax_p,[1, HB.numerical.Nx+1])
    title(ax_p, "Pressure distribution (Pa)")
end