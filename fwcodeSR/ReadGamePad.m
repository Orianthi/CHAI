function [buttonsPressed,padout] = ReadGamePad (padin,chkbuttons)
% read from USB Gamepad Controller using Psychtoolbox
%
% returns CPU time in sec (GetSecs) that any of the chkbuttons were pressed
% chkbuttons can be an array containing the button numbers to query.  As
% soon as any of these are pressed the program returns a CPU time.
%
% USAGE
% define padin.name (see below) and call [buttons,pad]=ReadGamePad(pad)
% someplace at the start of the program.  If padin.name is not defined, this
% call will have no effect. Otherwise it will look for the device named in
% padin.name.  
%
% EXAMPLE
% padin.name = 'Logitech Attack 3' (see numbers written on controller)
%               or
% padin.name = 'Microsoft¨ SideWinder¨ Plug & Play Game Pad'
%              (Button A =1; B=2; X=3; Y=4; Left Trigger = 5; Right Trigger = 6)
%
% To find padin.name of your gamepad call from the command line 
%       Gamepad('GetGamepadNamesFromIndices',1)
%
% RETURNS buttons = an array of CPU times when a given button was pressed. 
% CPU time is measured using GetSecs;  Elapsed time can be obtained by
% calling starttime = GetSecs 
%
% Each button takes about 0.0005 sec to query.
% 
% USAGE EXAMPLE
%
%       % ID the device and choose which buttons to watch
%       pad.name      = 'Logitech Attack 3';  % name of Gamepad
%       checkButtons = [1 3 7]; % report when  #1, #3 or #7 is pressed
%
%       % Initialize Gamepad
%       [buttons,pad] = ReadGamePad (pad,checkButtons);  
%
%       % Set up housekeeping
%       z       = zeros(size(checkButtons));
%       buttons = z;
% 
%       ... do other things here....
% 
%       % Find CPU Time Gamepad Buttons are Pressed
%       starttime = GetSecs;
%       while buttons==z; buttons = ReadGamePad (pad,checkButtons); end
% 
%       % Report Time and Button Number Pressed
%       buttonNumberPressed = checkButtons(logical(buttons))
%       elapsedtime         = buttons(logical(buttons))-starttime
%

% History
% 05/06/08 MHS wrote it

% do nothing if no pad defined
buttonsPressed = [];
if nargin<1 || isempty(padin); padout=[]; return; end


%-------------------
% Initialize Gamepad
%-------------------
if ~isempty(padin.name) && ~isfield(padin,'gamepadIndex')

    % Intialize Gamepad
    Gamepad('Unplug');
    padin.numGamepads = Gamepad('GetNumGamepads');
    padin.gamepadIndex = 0;

    for i=1:padin.numGamepads
        padin.gamepadName = char(Gamepad('GetGamepadNamesFromIndices', i));
        if strcmpi(padin.gamepadName,padin.name)
            padin.gamepadIndex = i;
            padin.name=padin.gamepadName;
            break
        end
    end
    if padin.gamepadIndex == 0
        disp(['ERROR: ReadGamePad: Gamepad not found: ',padNAME]);
        clear all
        abortthisbeast;
    else
    
    % fill in pad info
    padin.numButtons  = Gamepad('GetNumButtons',  padin.gamepadIndex);
    padin.numAxes     = Gamepad('GetNumAxes',     padin.gamepadIndex);
    padin.numBalls    = Gamepad('GetNumBalls',    padin.gamepadIndex);
    padin.numHats     = Gamepad('GetNumHats',     padin.gamepadIndex);

    end
    
else
    
    %-------------------
    % Read Gamepad State
    %-------------------
    buttonsPressed = zeros(size(chkbuttons));
    jp = 0;
    for j=chkbuttons
        jp = jp + 1;
        %Read gamepad states.
%       buttonsPressed(j) = Gamepad('GetButton', padin.gamepadIndex, j);

        % axisState = Gamepad('GetAxis', gamepadIndex, axisIndex)
        % [deltaX, deltaY]  = Gamepad('GetBall', gamepadIndex, ballIndex)
        % hatPosition = Gamepad('GetHat', gamepadIndex, hatIndex)
        %
        % %Retrieve low-level handles for fast raw access to elements.
        handles    = Gamepad('GetButtonRawMapping', padin.gamepadIndex, j);
        if PsychHID('RawState', handles(1), handles(2));
            buttonsPressed(jp) = GetSecs;  % return CPU time
        end
        % handles = Gamepad('GetAxisRawMapping', gamepadIndex, axisIndex)
        % handles = Gamepad('GetHatRawMapping', gamepadIndex, hatIndex)

    end
    
end
    
padout = padin;

return