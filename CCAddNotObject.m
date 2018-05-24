function AddGalaxy(w, centerX, centerY)
% adds an object to window w, centered at (centerX, centerY) in w.
map = 128.0;
Screen('PutImage', w, map, [centerX-25, centerY-25, centerX+26, centerY+26]);