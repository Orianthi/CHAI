function CloseAll
% Cleanup at end of experiment - Close window, show mouse cursor, close
% result file, switch Matlab/Octave back to priority 0 -- normal
% priority:

Screen('CloseAll');
ShowCursor;
fclose('all');
Priority(0);
