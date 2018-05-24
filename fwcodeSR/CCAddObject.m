function AddGalaxy(w, centerX, centerY, type, radius)
% adds an object to window w, centered at (centerX, centerY) in w.

relWidth = 0.3;         % bar width relative to object radius

maxEcc = radius/1.5;    % maximum eccentricity of object pixels in horizontal and vertical direction
width = relWidth*radius;

black = BlackIndex(w);  % Retrieves the CLUT color code for black.
white = WhiteIndex(w);  % Retrieves the CLUT color code for white.
margin = 12.0/180.0*pi;
wavelength = 10.0;
sigma = 10.0;

switch type
    case 1
        angle = 0.0;
    case 2
        angle = pi/2.0;
    case 3
        angle = (pi/2 - 2*margin) + margin; %rand had been multiplied to each "(pi/2 - 2*margin)" for cases 3-6
    case 4
        angle = (pi/2 - 2*margin) + margin;
    case 5
        angle = pi/2.0 + (pi/2 - 2*margin) + margin;
    case 6
        angle = pi/2.0 + (pi/2 - 2*margin) + margin;
end
sa = sin(angle);
ca = cos(angle);
[X, Y] = meshgrid(-25:25, -25:25);
map = exp((-X.*X - Y.*Y)/(2.0*sigma*sigma)).*sin((X.*sa + Y.*ca).*2.0*pi/wavelength)*100.0 + 128.0;
Screen('PutImage', w, map, [centerX-25, centerY-25, centerX+26, centerY+26]);

