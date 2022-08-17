function [contour_dim] = get_contour_dim(topogram,cont,pxlSize)

[~, diameterMin, diameterMax, perimeter, area, ~] =...
  getMorphometricParameters(topogram,cont,pxlSize);

diameter_avr = (diameterMin+diameterMax) / 2;
radius_max = diameterMax/2;
radius_min = diameterMin/2;
P = 4*(pi*radius_max*radius_min+(radius_max-radius_min)^2)/diameter_avr;
S = pi*radius_max*radius_min;
if area==0
    contour_dim = 1;
else    
    contour_dim = 2*log(perimeter)/(2*log(P) - log(S) + log(area));
end

end

