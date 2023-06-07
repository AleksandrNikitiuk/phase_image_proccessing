function [filt_signals] = filter_trackdiagram(tdg,dt,filter_threshold)
% Функция для фильтрации сигналов трэк-диаграммы

% Проверка входных данных
if nargin < 3
  filter_threshold = .1;
end

if nargin < 2
  dt = 0.0302;
end

% Фильтрация с помощью 1D непрерывного вейвлет-преобразования
tdg_size = size(tdg);

filt_signals = zeros(tdg_size);

for s = 1:tdg_size(1)
    row_signal = tdg(s,:);
    [z,f] = cwt(row_signal, 'amor', 1/dt);
    f = f';
    k = find(f >= filter_threshold);
    z((k(end)+1):end,:) = 0+0i;
    filt_signals(s,:) = real(icwt(z))';
end

end

