basefname = '../sample1/';  % where the snapshots are stored
range = [10,400];           % number range to examine
outfile = 'out.mat';        % where to store selection output
gridsize=[2,3];             % size of image grid for display

cellpicker(basefname,range,outfile,gridsize)

% right arrow - move to next set of FOVs
% left arrow - move to next set of FOVs
% mouse click - select or deselect cell
% q - quit and save (saving also happens automatically after each key press
% or mouse click)