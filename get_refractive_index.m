function [refractive_index] = get_refractive_index(phase_image,medium_refractive_index)
% Функция для получения среднего показателя преломления клетки по данным
% ЛИМ. ВАЖНО: у фазового изображения phase_image д.б. удален фон!

if nargin < 3
  medium_refractive_index = 1.335;
end

if nargin < 2
  optical_scheme_type = 2; % 1 - на просвет, 2 - на отражение
end

% Определение размеров клетки в предположении её сферичности
sizeTpg = size(phase_image);
[xo,yo,zo] = prepareSurfaceData(1:sizeTpg(2),1:sizeTpg(1),phase_image);
f = fit([xo,yo],zo, 'poly22'); %  '2 * (R^2 - (x - x0)^2 - (y - y0)^2)^(1/2)'
surface = feval(f,repmat(1:sizeTpg(2),sizeTpg(1),1),repmat(1:sizeTpg(1),sizeTpg(2),1)');

% Определение маски
mask = zeros(size(phase_image));
mask(phase_image ~= 0) = 1;

% Расчет показателя преломления
local_refractive_indices = (phase_image ./ surface) .* mask;
local_refractive_indices_without_zeros = local_refractive_indices(local_refractive_indices ~= 0);
refractive_index = mean(local_refractive_indices_without_zeros) * optical_scheme_type - medium_refractive_index;

end

