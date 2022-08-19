function [center_of_mass] = get_center_of_mass(phase_image,pxl_size)
% Функция для расчета центра масс фазового изображения клетки.

if nargin < 2
  pxl_size = 0.136950136950137;
end

phase_image_size = size(phase_image);
x = (1:phase_image_size(1)) * pxl_size;
y = (1:phase_image_size(2)) * pxl_size;

phase_delay_sum = sum(phase_image,'all');

center_of_mass_x = sum(phase_image .* x','all') / phase_delay_sum;
center_of_mass_y = sum(phase_image .* y,'all') / phase_delay_sum;

center_of_mass = [...
  center_of_mass_x;...
  center_of_mass_y;...
  10^-3 * phase_image(floor(center_of_mass_x / pxl_size),floor(center_of_mass_y / pxl_size))...
  ];

end

