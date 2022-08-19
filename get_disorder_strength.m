function [disorder_strength,phase_fluctuations] = get_disorder_strength(phase_image,phase_image_displacement, average_refractive_index)
% Функция для расчета величины разупорядочения фазового изображения клетки.

if nargin < 3
  average_refractive_index = 1.378; % for MCF-7
end

% Расчет пространственной длины когерентности
[normalizedACF, lags] = autocorr(phase_image(:),'NumLags',30);
f = fit(lags,normalizedACF,'exp(a*x)');
coherence_length = 1 / exp(f.a);

% Осреднение по области 3х3
phase_image_variance = phase_image_displacement.^2;
average_phase_image_variance = medfilt2(phase_image_variance);
average_phase_image = medfilt2(phase_image);
phase_fluctuations = average_phase_image_variance ./ average_phase_image.^2;
phase_fluctuations(isnan(phase_fluctuations) | isinf(phase_fluctuations)) = 0;

% Определение маски
mask = zeros(size(phase_image));
mask(phase_image > ((max(phase_image(:)) - min(phase_image(:))) * 2 / 3)) = 1;
phase_fluctuations = phase_fluctuations .* mask;

% Расчет величины разупорядочения
disorder_strength = mean(phase_fluctuations,'all') * average_refractive_index * coherence_length;

end

function [average3x3_image] = get_average3x3_image(image)
average3x3_image = (...
  image(:,:)...
  + circshift(image,1,1)...
  + circshift(image,-1,1)...
  + circshift(image,1,2)...
  + circshift(image,-1,2)...
  + circshift(image,[1 1])...
  + circshift(image,[1 -1])...
  + circshift(image,[-1 1])...
  + circshift(image,[-1 -1])...
  ) / 9;
end

