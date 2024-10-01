% ====================================================================================
%                               HB-Calculator
%                    MIT License, D. Perez Trias, 2024
% ====================================================================================

classdef BearingDesigner < handle

    properties
        parameters = bearing_parameters();
        data = get_data();
    end

    methods 
        % Constructor
        function BD = BearingDesigner()
            % Defualt
        end

        function load(BD)
            tol = 1e-8;
            if "excentricity" == BD.parameters.last_updated
                load_excentricity(BD, tol);
            elseif "elongation" == BD.parameters.last_updated
                load_elongation(BD, tol);
            end
        end
    end

end

function P = bearing_parameters()
    P.elongation = 0.1; %0.0199497487437186;
    P.excentricity = 0.001994974874372;
    P.load = 1.662403806113810e-06;
    P.last_updated = 'excentricity';
end

function data = get_data()
    currentFile = mfilename('fullpath');
    [currentPath,~,~] = fileparts(currentFile);
    path = fullfile(currentPath, 'data');
    addpath(path);
    data = load("e0001-0999_L001-100.mat");
end

function load_excentricity(BD, tol)
    exc_index = (abs(BD.data.epsilon(:) - BD.parameters.excentricity) < tol);
    if any(exc_index)
        f_index = (abs(BD.data.f(:, exc_index) - BD.parameters.load) < tol);
        if any(f_index)
            disp(f_index);
            BD.parameters.elongation = BD.data.Lambda(f_index);
        else
            disp('I did not find any value')
        end
    else
        disp('I did not find any value')
    end
end

function load_elongation(BD, tol)
    elo_index = (abs(BD.data.Lambda(:) - BD.parameters.elongation) < tol);
    if any(elo_index)
        f_index = (abs(BD.data.f(elo_index, :) - BD.parameters.load) < tol);
        if any(f_index)
            disp(f_index')
            BD.parameters.excentricity = BD.data.epsilon(f_index');
        else
            disp('I did not find any value')
        end
    else
        disp('I did not find any value')
    end
end