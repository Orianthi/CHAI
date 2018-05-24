function CCMakeStimuli
% Generates stimulus displays for the Contextual Cueing Experiment
% Version 1.0 on 06/30/2008 by Marc Pomplun (mpomplun@gmail.com)

numberOfBlocks = 1;
displaysPerBlock = 500;
repeatedDisplays = 0;
widthDisplay = 700;      % size of stimulus area (centered on screen)
heightDisplay = 700;
numberOfObjects = 32;   % how many objects are in the display?
radius = 25;            % specifiy size of objects
mindist = 80;          % minimum distance between centers of neighboring objects

% write config file so parameters don't get mixed up
cfile = fopen('config.txt', 'wt');
if cfile == 0
    display('Can''t open file config file for writing.');
    exit;
end
fprintf(cfile, '%d\t%d\t%d\t%d\t%d\t%d\n', numberOfBlocks, displaysPerBlock, repeatedDisplays, widthDisplay, heightDisplay, radius);
fclose(cfile);

% Reseed the random-number generator
rand('state',sum(100*clock));

numberOfDisplays = repeatedDisplays + numberOfBlocks*(displaysPerBlock - repeatedDisplays);

for d = 1:numberOfDisplays
    % we need to store positions and sizes of all previously drawn objects
    % to prevent objects from overlapping.
    x = zeros(numberOfObjects);
    y = zeros(numberOfObjects);
    filename = sprintf('display%03d.txt', d);
    dfile = fopen(filename, 'wt');
    if dfile == 0
        display(['Can''t open file ' filename ' for writing.']);
        break;
    end

    % now let's generate the objects!
    % first object is always the target
    x(1) = floor(radius + 1 + rand*(widthDisplay - 2*(radius + 1)));
    y(1) = floor(radius + 1 + rand*(widthDisplay - 2*(radius + 1)));
    if mod(d, 2) == 0
        type = 1;  % target pointing left
    else
        type = 2;  % target pointing right
    end
    fprintf(dfile, '%d\t%d\t%d\n', x(1), y(1), type);
    
    type = 3 + floor(3.999*rand);   % next object type (L in 4 possible orientations, type 3...6)
    for object = 2:numberOfObjects
        okay = 0;  % check whether new object fits without overlapping
        while okay == 0
            x(object) = floor(radius + 1 + rand*(widthDisplay - 2*(radius + 1)));
            y(object) = floor(radius + 1 + rand*(widthDisplay - 2*(radius + 1)));
            okay = 1;
            for check = 1:object - 1 % now check if overlap with any previously drawn object
                if (x(check) - x(object))^2 + (y(check) - y(object))^2 <= mindist^2     
                    okay = 0; % if overlap, try new (x, y) coordinates for object
                    break;
                end
            end
        end
        % if object fits, add it to file
        fprintf(dfile, '%d\t%d\t%d\n', x(object), y(object), type);
        type = type + 1;  % switch type for next object
        if type > 6
            type = 3;
        end
    end
    fclose(dfile);
end
