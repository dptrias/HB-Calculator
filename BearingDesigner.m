% ====================================================================================
%                               HB-Calculator
%                    MIT License, D. Perez Trias, 2024
% ====================================================================================

classdef BearingDesigner < handle

    properties
        parameters = bearing_parameters();
        data_path = get_data_path();
    end

    methods 
        % Constructor
        function BD = BearingDesigner()
            % Defualt
        end

        function load(BD)
            if false
                load_excentricity(BD);
            elseif true
                load_elongation(BD);
            end
        end
    end

end

function P = bearing_parameters()
    P.elongation = 1;
    P.excentricity = 0.05;
    P.load = 3;
    P.last_updated = 'excentricity';
end

function path = get_data_path()
    currentFile = mfilename('fullpath');
    [currentPath,~,~] = fileparts(currentFile);
    path = fullfile(currentPath, 'data');
    addpath(path);
end

function load_excentricity(BD)
    
end

function load_elongation(BD)
    
end