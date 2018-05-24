function [targetTilt] = CCDrawDisplay(w, xOffset, yOffset, number, radius)
% draws a CC search display from display file 'display<number>.txt'
% returns tilt of target

cData = load('config.txt');
if cData == 0
    error('Can''t read config file.');
end
T = cData(7);

clicksI = 32;
filename = sprintf('display%03d.txt', number);
field = load(filename);
[objects, columns] = size(field);
Screen('TextFont',w, 'Times');
Screen('TextSize',w, 30);
Screen('FillRect', w, [128 128 128]); %test color: 50 50 50
tic;
timer = 0;
arr = zeros(32, 3);
arr0 = zeros(33, 2);
objectF = 1;
for object = 1:objects
    centerX = field(object, 1) + xOffset;
    centerY = field(object, 2) + yOffset;
    type    = field(object, 3);
    arr(object, 1) = centerX;
    arr(object, 2) = centerY;
    arr(object, 3) = type;
end

intB = 1;
typeI = 0;
rowI = 0;
while(timer ~= T)
    timer = round(toc);
    printT = T - timer;
    for object = 1:objects
        CCAddObject(w, arr(object, 1), arr(object, 2), arr(object, 3), radius);
    end
    for object = 1:objects+1
        CCAddNotObject(w, arr0(object, 1), arr0(object, 2)); 
    end
%     centerX1 = 72 + xOffset; test coords on display01.txt
%     centerY1 = 81 + yOffset;
    [mX, mY, button] = GetMouse(w);
    if(button(1))
      for object = 1:objects
        if((arr(object, 1)-25 <= mX) && (mX <= arr(object, 1)+26) && (arr(object, 2)-25 <= mY) && (mY <= arr(object, 2)+26))
            if((rowI ~= object) && (typeI == arr(object, 3)))
                clicksI = clicksI - 1;
                objectF = objectF + 1;
                arr0(objectF, :) = [arr(object, 1), arr(object, 2)];
                for i = 1:objects+1
                    if(arr0(i, 1) == arr(rowI, 1) && arr0(i, 2) == arr(rowI, 2))
                        intB = 0;
                    end
                end
                if(intB == 1)
                    clicksI = clicksI - 1;
                    objectF = objectF + 1;
                    arr0(objectF, :) = [arr(rowI, 1), arr(rowI, 2)];
                end
            end
            typeI = arr(object, 3);
            rowI = object;
            intB = 1;
        end
      end
    end
    messageTCount = sprintf('Time: %d ', printT);
    messageI = sprintf('Images Remaining: %d ', clicksI); 
    DrawFormattedText(w, messageTCount, xOffset, yOffset, WhiteIndex(w));
    DrawFormattedText(w, messageI, xOffset+435, yOffset, WhiteIndex(w));   
    targetTilt = (field(1, 3) == 2); % return tilt of target (0 = leftward, 1 = rigthward)
    Screen('Flip', w);
    [down, secs, keyCode] = KbCheck(6);
    if keyCode(KbName('space'))
        FlushEvents('keyDown');
        timer = T;
    end
end
