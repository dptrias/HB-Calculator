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
            if "excentricity" == BD.parameters.last_updated
                load_excentricity(BD);
            elseif "elongation" == BD.parameters.last_updated
                load_elongation(BD);
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

function load_excentricity(BD)
    [~, exc_index] = min(abs(BD.data.epsilon(:) - BD.parameters.excentricity));
    BD.parameters.excentricity = BD.data.epsilon(exc_index);
    [~, f_index] = min(abs(BD.data.f(:, exc_index) - BD.parameters.load));
    BD.parameters.load = BD.data.f(f_index);
    BD.parameters.elongation = BD.data.Lambda(f_index);
    disp(BD.parameters)
    % exc_index = (abs(BD.data.epsilon(:) - BD.parameters.excentricity) < tol);
    % if any(exc_index)
    %     f_index = (abs(BD.data.f(:, exc_index) - BD.parameters.load) < tol);
    %     if any(f_index)
    %         disp(f_index);
    %         BD.parameters.elongation = BD.data.Lambda(f_index);
    %     else
    %         tol = tol + 5e-10;
    %         disp('I did not find any load value')
    %         load_excentricity(BD, tol)
    %     end
    % else
    %     tol = tol + 5e-10;
    %     disp('I did not find any epsilon value')
    %     load_excentricity(BD, tol)
    % end
end

function load_elongation(BD)
    [~, elo_index] = min(abs(BD.data.Lambda(:) - BD.parameters.elongation));
    BD.parameters.elongation = BD.data.Lambda(elo_index);
    [~, f_index] = min(abs(BD.data.f(elo_index, :) - BD.parameters.load));
    BD.parameters.load = BD.data.f(f_index);
    BD.parameters.excentricity = BD.data.epsilon(f_index');
    disp(BD.parameters)
    % elo_index = (abs(BD.data.Lambda(:) - BD.parameters.elongation) < tol);
    % if any(elo_index)
    %     f_index = (abs(BD.data.f(elo_index, :) - BD.parameters.load) < tol);
    %     if any(f_index)
    %         disp(f_index')
    %         BD.parameters.excentricity = BD.data.epsilon(f_index');
    %     else
    %         disp('I did not find any value')
    %     end
    % else
    %     disp('I did not find any value')
    % end
end