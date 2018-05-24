function CCExperiment(subjectNumber)
% Contextual Cueing Experiment
% Version 1.0 on 06/30/2008 by Marc Pomplun (mpomplun@gmail.com)

%Screen('Preference', 'SkipSyncTests', 1);

use_gamepad = 0;                 % 0 = keyboard, 1 = gamepad
pad.name = 'Logitech Attack 3';  % type of gamepad for subject's response
checkButtons = [1 2 3 4 5];      % report when button #1...5 is pressed
left_button = 2;                 % response buttons for gamepad...
right_button = 3;
left_key = 'z';                  % and for keyboard.
right_key = 'm';

if use_gamepad == 1
    [ButtonCode, pad] = ReadGamePad(pad, checkButtons);  % intialize device
    z = zeros(size(checkButtons));
    ButtonCode = z;
end;

% prepare feedback sounds
cf = 800;                       % carrier frequency (Hz)
sf = 22050;                     % sample frequency (Hz)
d = 0.02;                       % duration (s)
n = sf*d;                       % number of samples
s = (1:n)/sf;                   % sound data preparation
corrSound = sin(2*pi*cf*s);     % sinusoidal modulation

cf = 400;                       % carrier frequency (Hz)
sf = 22050;                     % sample frequency (Hz)
d = 0.1;                        % duration (s)
n = sf*d;                       % number of samples
s = (1:n)/sf;                   % sound data preparation
incorrSound = sin(2*pi*cf*s);   % sinusoidal modulation

% Clear Matlab/Octave window:
clc;

% check for Opengl compatibility, abort otherwise:
AssertOpenGL;

% Check if required parameter given:
if nargin ~= 1
    error('Must provide required input parameter "subject_number!"');
end

% read config file to get number of trials etc.
cData = 0;
cData = load('config.txt');
if cData == 0
    error('Can''t read config file.');
end

numberOfBlocks = cData(1);
displaysPerBlock = cData(2);
repeatedDisplays = cData(3);
widthDisplay = cData(4);
heightDisplay = cData(5);
radius = cData(6);

% Reseed the random-number generator for each expt.
rand('state',sum(100*clock));

% Make sure keyboard mapping is the same on all supported operating systems
% Apple MacOS/X, MS-Windows and GNU/Linux:
KbName('UnifyKeyNames');

% Define filename of result file:
datafilename = strcat('ContextualCueing_', num2str(subjectNumber), '.txt'); % name of data file to write to
subjectNumber = str2num(subjectNumber);

% check for existing result file to prevent accidentally overwriting
% files from a previous subject/session (except for subject numbers > 99):
if subjectNumber < 99 & fopen(datafilename, 'rt') ~= -1
    fclose('all');
    error('Result data file already exists! Choose a different subject number.');
else
    datafilepointer = fopen(datafilename, 'wt'); % open ASCII file for writing
end

% write header for result file
fprintf(datafilepointer, 'subject\tblock\ttrial\tdisplay\ttilt\trepeated?\tresponse\tcorrect?\tRT\n');

try
    screens=Screen('Screens');
    screenNumber= 1;%max(screens);

    % Hide the mouse cursor:
  %  HideCursor;

    % Returns as default the mean gray value of screen:
    black = BlackIndex(screenNumber);

    % Open a double buffered fullscreen window on the stimulation screen
    % 'screenNumber' and choose/draw a gray background. 'w' is the handle
    % used to direct all drawing commands to that window - the "Name" of
    % the window. 'wRect' is a rectangle defining the size of the window.
    % See "help PsychRects" for help on such rectangles and useful helper
    % functions:
    [w, wRect] = Screen('OpenWindow', screenNumber, black);
    xOffset = (wRect(3) - widthDisplay)/2;  % screen offset to center display
    yOffset = (wRect(4) - heightDisplay)/2;

    % Set text size (Most Screen functions must be called after
    % opening an onscreen window, as they only take window handles 'w' as
    % input:
    Screen('TextSize', w, 16);
    Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    % Do dummy calls to GetSecs, WaitSecs, KbCheck to make sure
    % they are loaded and ready when we need them - without delays
    % in the wrong moment:
    KbCheck;
    WaitSecs(0.1);
    GetSecs;

    % initialize KbCheck and variables to make sure they're
    % properly initialized/allocted by Matlab - this to avoid time
    % delays in the critical reaction time measurement part of the
    % script:
    [KeyIsDown, endrt, KeyCode] = KbCheck;


    %%%%%%%%%%%%%%%%%%%%%%
    % experiment
    %%%%%%%%%%%%%%%%%%%%%%

    newDisplays = numberOfBlocks*(displaysPerBlock - repeatedDisplays);
    newDisplayOrder = randperm(newDisplays); % order in which new (non-repeated) displays are picked
    newDisplayCounter = 1; % remember the number of the next new display to be picked

    for block = 1:numberOfBlocks
        trialOrder = randperm(displaysPerBlock);  % first determine order of displays to be shown in this block
        for i = 1:displaysPerBlock
            if trialOrder(i) > repeatedDisplays   % if it's not a repeated display...
                trialOrder(i) = newDisplayOrder(newDisplayCounter) + repeatedDisplays;   % ... pick a new one
                newDisplayCounter = newDisplayCounter + 1;
            end
        end

        if use_gamepad == 0
            message = sprintf('CC SEARCH TASK - BLOCK %d OUT OF %d\n\nPress "%c" or "%c" for target (letter T) pointing to the left or right, resp.\n\n\nPress mouse button to start experiment.', block, numberOfBlocks, left_key, right_key);
        else
            message = sprintf('CC SEARCH TASK - BLOCK %d OUT OF %d\n\nPress Button %d or Button %d for target (letter T) pointing to the left or right, resp.\n\n\nPress mouse button to start experiment.', block, numberOfBlocks, left_button, right_button);
        end
        DrawFormattedText(w, message, 'center', 'center', WhiteIndex(w));

        % Update the display to show the instruction text:
        Screen('Flip', w);

        % Wait for mouse click:
        GetClicks(w);

        % Clear screen to background color (our 'black' as set at the beginning):
        Screen('Flip', w);

        % Wait a second before starting trial
        WaitSecs(0.01);

        % loop through trials
        trial = 1;
        while trial <= displaysPerBlock
            
            expectedResponse = CCDrawDisplay(w, xOffset, yOffset, trial, radius); % returns tilt of target (0 = leftward, 1 = rigthward)
            % wait a bit between trials
            WaitSecs(.01);

            % Show stimulus on screen at next possible display refresh cycle,
            % and record stimulus onset time in 'startrt':
            [VBLTimestamp startrt] = Screen('Flip', w);
            %WaitSecs(duration);
            FlushEvents('keyDown');
            
            if use_gamepad == 0
                imageArray = Screen('GetImage', w, [0 0 1024 768]);

                %imwrite is a Matlab function, not a PTB-3 function
                filename = sprintf('image%03d.jpg', trial);
                imwrite(imageArray, filename)
                WaitSecs(.1);
%                 KeyCode = ' ';
%                 while KeyCode ~= left_key & KeyCode ~= right_key
%                     [KeyCode, endrt] = GetChar;
%                 end
            else
                ButtonCode = 0;
                while ButtonCode ~= left_button & ButtonCode ~= right_button
                    ButtonCode = ReadGamePad(pad, checkButtons);
                end
                endrt.secs = GetSecs;
                if ButtonCode == left_button  % simply translate button code into key code so we don't have to check for input device any more
                    KeyCode = left_key;
                else
                    KeyCode = right_key;
                end
            end

            % Clear screen to background after subjects response
            Screen('Flip', w);

            % compute response time
            rt = 1000;%round(1000*(endrt.secs - startrt));

            % compute accuracy
            if (KeyCode == left_key & expectedResponse == 0) | (KeyCode == right_key & expectedResponse == 1)
                correct_answer = 1;
                answerstring = 'right';
                %sound(corrSound, sf); %---> UNCOMMENT
            else
                correct_answer = 0;
                answerstring = 'wrong';
                %sound(incorrSound, sf); %---> UNCOMMENT
            end

            % Write trial result to file
            if (expectedResponse == 0)
                tiltString = 'left';
            else
                tiltString = 'right';
            end
            if (trialOrder(trial) <= repeatedDisplays)
                displayString = 'rep';
            else
                displayString = 'new';
            end
            fprintf(datafilepointer, '%02d\t%d\t%d\t%d\t%s\t%s\t%s\t%s\t%d\n', ...
                subjectNumber, block, trial, trialOrder(trial), displayString, tiltString, KeyCode, answerstring, rt);
            trial = trial + 1;
        end
    end

    % be polite
    message = 'Experiment completed.\n\n\nTHANK YOU VERY MUCH!';
    DrawFormattedText(w, message, 'center', 'center', WhiteIndex(w));
    Screen('Flip', w);
    
    WaitSecs(1.0);

    % Cleanup at end of experiment - Close window, show mouse cursor, close
    % result file, switch Matlab/Octave back to priority 0 -- normal
    % priority:
    CloseAll;
    return;
catch
    % catch error: This is executed in case something goes wrong in the
    % 'try' part due to programming error etc.:

    % Do same cleanup as at the end of a regular session...
    CloseAll;

    % Output the error message that describes the error:
    psychrethrow(psychlasterror);
end % try ... catch %
