function SRMakeStimuliTest
% Generates stimulus displays for the Contextual Cueing Experiment
numberOfBlocks = 5; %total blocks
practiceBlock = 1;
displaysPerBlock = 20;
displaysPerPracticeBlock = 5;
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

%numberOfDisplays = repeatedDisplays + numberOfBlocks*(displaysPerBlock - repeatedDisplays);

for set = 1:numberOfBlocks
    for d = (1 + (displaysPerBlock*(set-1))):(displaysPerBlock + (displaysPerBlock*(set-1)))
        x = zeros(numberOfObjects);
        y = zeros(numberOfObjects);
        type = zeros(numberOfObjects);
        filename = sprintf('display%03d.txt', d);
        dfile = fopen(filename, 'wt');
        if dfile == 0
            display(['Can''t open file ' filename ' for writing.']);
            break;
        end

        % now let's generate the objects!
        % all objects are targets now
        arr = zeros(32, 3);
        for object = 1:(displaysPerBlock - (numberOfBlocks*(set-1)))
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
            type(object) = 1 + floor(1.999*rand);
            arr(object,:) = [x(object), y(object), type(object)];
        end
        for object = ((displaysPerBlock - (numberOfBlocks*(set-1)))+ 1):numberOfObjects
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
            type(object) = 3 + floor(3.999*rand);
            arr(object,:) = [x(object), y(object), type(object)];
        end
        arrSort = sortrows(arr,3);
        for i = 1:numberOfObjects
            fprintf(dfile, '%d\t%d\t%d\n', arrSort(i, :));
        end
        
        fclose(dfile);
    end
end