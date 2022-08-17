function [height,...
  diameterMin,...
  diameterMax,...
  perimeter,...
  area,...
  volume,...
  dry_mass,...
  surface_area,...
  phase_variance,...
  kurtosis,...
  skewness,...
  energy...
  ] = getMorphometricParameters(topogram,contour,pxlSize)

% ПРОВЕРКА ВХОДНЫХ ДАННЫХ

if (nargin < 3)
  pxlSize = 0.0658;
end

if (nargin < 2)
  contour = contourc(topogram,2);
  indexLowLevels = find(contour(1,:) == contour(1,1));
  i = find(contour(2,indexLowLevels) == max(contour(2,indexLowLevels)));
  contour = contour(:,indexLowLevels(i):indexLowLevels(i)+contour(2,indexLowLevels(i)));
end

if (nargin < 1)
  Error('Not enough input arguments.');
end

% РАССЧИТАТЬ ВЫСОТУ

hMin = contour(1,1);
hMax = max(max(topogram));
height = hMax - hMin;

% РАССЧИТАТЬ ДИАМЕТРЫ (МИНИМАЛЬНЫЙ И МАКСИМАЛЬНЫЙ)

nContourPoints = contour(2,1);
halfNContourPoints = fix(nContourPoints/2);
diameter = zeros(1,halfNContourPoints-1);
for i = 2:halfNContourPoints
  diameter(i-1) = ...
    sqrt( (contour(1,i+halfNContourPoints) - contour(1,i))^2 + ...
    (contour(2,i+halfNContourPoints) - contour(2,i))^2 );
end
diameterMin = min(diameter*pxlSize);
diameterMax = max(diameter*pxlSize);

% РАССЧИТАТЬ ПЕРИМЕТР

distanceBetweenPoints = diff(contour(:,2:end)');
perimeter = sum(sqrt(distanceBetweenPoints(:,1).^2 + distanceBetweenPoints(:,2).^2)) * pxlSize;

% РАССЧИТАТЬ ПЛОЩАДЬ

cell = topogram > hMin & topogram < hMax;
area = sum(sum(cell)) * pxlSize^2;

% РАССЧИТАТЬ ОБЪЕМ

cell = cell .* topogram ./ 10^3 .* pxlSize^2;
volume = sum(sum(cell));

% РАССЧИТАТЬ СУХУЮ МАССУ
lamda = 655; % nm
alpha = 0.18 * 10^9; % nm^3 / pg
integrated_phase_shifts = sum(sum(cell ./ pxlSize^2 .* 10^3)); % nm
dry_mass = (integrated_phase_shifts * lamda) / (2 * pi * alpha); % pg / nm

% РАССЧИТАТЬ ПЛОЩАДЬ ПОВЕРХНОСТИ КЛЕТКИ
[px,py] = gradient(cell / pxlSize^2);
gradient_map = px.^2 + py.^2;
gradient_map = 1 + gradient_map(gradient_map ~= 0);
surface_area = area + sum(sqrt(gradient_map),'all') * pxlSize;

% РАССЧИТАТЬ ДИСПЕРСИЮ ОПТИЧЕСКОЙ ТОЛЩИНЫ КЛЕТКИ
phase_variance = 1 / (sum(size(cell)) -1) * sum(((cell ./ pxlSize^2) - mean((cell ./ pxlSize^2), 'all')).^2,'all');

% РАССЧИТАТЬ КОЭФФИЦИЕНТ ЭКСЦЕССА
kurtosis = sum(((cell ./ pxlSize^2) - mean((cell ./ pxlSize^2), 'all')).^4 ./ phase_variance.^4,'all');

% РАССЧИТАТЬ КОЭФФИЦИЕНТ АССИМЕТРИИ
skewness = sum(((cell ./ pxlSize^2) - mean((cell ./ pxlSize^2), 'all')).^3 ./ phase_variance.^3,'all');

% РАССЧИТАТЬ ЭНЕРГИЮ (параметр характеризующий тексутру клетки)
energy = sum((cell ./ pxlSize^2).^2,'all');

end