function [shear_modulus] = get_shear_modulus(shear_stress,phase_image_1,phase_image_2,refractive_index,pxl_size,threshold)
% Функция для расчета модуля сдвига.

if nargin < 6
  threshold = (max(phase_image_2(:)) - min(phase_image_2(:)) ) / 2;
end

if nargin < 5
  pxl_size = 0.136950136950137;
end

if nargin < 4
  refractive_index_mcf7 = 1.378;
  refractive_index_PBS = 1.335; % Phosphate-buffered saline - Физиологический раствор с фосфатным буфером
  refractive_index =...
    refractive_index_mcf7...
    - refractive_index_PBS;
end

% Определение центров масс изображений
center_of_mass_1 = get_center_of_mass(phase_image_1,pxl_size);
center_of_mass_2 = get_center_of_mass(phase_image_2,pxl_size);
coor_center_of_mass_1 = floor(center_of_mass_1(1:2) ./ pxl_size);
coor_center_of_mass_2 = floor(center_of_mass_2(1:2) ./ pxl_size);

% Выделения профилей изображений в направлении смещения центра масс
if abs(coor_center_of_mass_1(1) - coor_center_of_mass_2(1)) == 0
  if abs(coor_center_of_mass_1(2) - coor_center_of_mass_2(2)) == 0
    phase_profiles = [...
      phase_image_1(:,coor_center_of_mass_1(2));...
      phase_image_2(:,coor_center_of_mass_2(2))...
      ];
  end
else
  if abs(coor_center_of_mass_1(2) - coor_center_of_mass_2(2)) == 0
    phase_profiles = [...
      phase_image_1(coor_center_of_mass_1(1),:);...
      phase_image_2(coor_center_of_mass_2(1),:)...
      ];
  else
    phase_profiles = [...
      diag(phase_image_1,coor_center_of_mass_1(2) - coor_center_of_mass_1(1));...
      diag(phase_image_2,coor_center_of_mass_2(2) - coor_center_of_mass_2(1))...
      ];
  end
end

% Расчет спроецированной высоты оценки
height_estimate = median(phase_profiles(phase_profiles > threshold)) / refractive_index * 10^-3;

% Вычисление модуля сдвига
shear_modulus = shear_stress...
  / sqrt(sum((center_of_mass_2(1:2) - center_of_mass_1(1:2)).^2))... % возможно надо по всем 3 индексам рассчитывать модуль вектора смещения центра масс
  * height_estimate;

end

