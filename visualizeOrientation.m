% Author: Angelo G. Gaillet
% Release date: 31/07/2022
%
% This function displays a parallelepiped which has its orientation in space
% represented by the provided quaternions.

function visualizeOrientation(qx, qy, qz, qw)
    
    toolboxes = matlab.addons.installedAddons;
    if any(strcmp(toolboxes.Name, "Robotics System Toolbox"))
        R = quat2rotm([qw qx qy qz]);
    elseif any(strcmp(toolboxes.Name, "Aerospace Toolbox"))
        R = quat2dcm([qw qx qy qz]);
    else
        error("This function requires the Robotics System Toolbox or the Aerospace Toolbox");
    end
    
    A = R*[-1 -1 -.1]';
    B = R*[ 1 -1 -.1]';
    C = R*[ 1  1 -.1]';
    D = R*[-1  1 -.1]';
    E = R*[-1 -1 .1]';
    F = R*[ 1 -1 .1]';
    G = R*[ 1  1 .1]';
    H = R*[-1  1 .1]';
    
    vertices = [A';B';C';D';E';F';G';H'];
    xc = vertices(:,1);
    yc = vertices(:,2);
    zc = vertices(:,3);
    
    connections = [4 8 5 1 4;
                   1 5 6 2 1;
                   2 6 7 3 2; 
                   3 7 8 4 3; 
                   5 8 7 6 5; 
                   1 4 3 2 1]';
    
    colors = [0         0.4470  0.7410;
              0.8500    0.3250  0.0980;
              0.9290    0.6940  0.1250;
              0.4940    0.1840  0.5560;
              0.4660    0.6740  0.1880;
              0.3010    0.7450  0.9330];
    
    figure(1);
    delete(findobj('type', 'patch'));
    patch(xc(connections), yc(connections), zc(connections), 'r', 'facealpha', 1, 'FaceVertexCData', colors, 'FaceColor', 'Flat');
    hold on;
    plot3([-2 2], [0 0], [0 0], 'Color', 'blue'); % blue x
    plot3([0 0], [-2 2], [0 0], 'Color', 'magenta'); % orange y
    plot3([0 0], [0 0], [-2 2], 'Color', 'green'); % green z
    
    axis equal
    axis([-2 2 -2 2 -2 2]);
    view(0,0.1);
    drawnow
    
end