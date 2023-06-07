% Решение системы Лоренца
dt = 0.01;
tMin = 0;
tMax = 1500 * dt;    
tSpan = tMin:dt:tMax;
initCond = [0; 1; 1.05];
s = 10; r = 28; b = 2.667;
[T,Y] = ode15s(@(t,y) get_rhs_lorentz_system(t,y,s,r,b), tSpan, initCond);

% Выделение сигнала
signal = Y(:,1);

% Расчет времени задержки
[autocorrelation_function, lags] = autocorr(signal,floor(length(signal)/2));
indices = islocalmin(autocorrelation_function);
local_min_taus = lags(indices);
solution_taus = (autocorrelation_function(1:end-1) > 0 & autocorrelation_function(2:end) < 0) |...
    (autocorrelation_function(1:end-1) < 0 & autocorrelation_function(2:end) > 0);
tau = min([local_min_taus(1) find(solution_taus == 1,1)]);

% Применение метода Грассбергера-Прокаччиа
tic;
[dim_embedding_space,dim_correlation,correlation_integral,eps] =...
  execute_gp_method(signal,15,tau);
toc;

% Визуализация результатов
figure;
plot(2:(length(dim_correlation))+1, dim_correlation,'ko-');
xlabel('embedding space dimention');
ylabel('correlation dimention');
grid on;set_figure;


%% Вспомогательные функции
function [ dydt ] = get_rhs_lorentz_system( t, y, s, r, b )
% Функция для расчета правых частей дифф. уравнений системы Лоренца.

if nargin < 5
  s = 10;
  r = 28;
  b = 2.667;
end

dydt = zeros(length(y),1);
dydt(1) = s*(y(2) - y(1));
dydt(2) = r*y(1) - y(2) - y(1)*y(3);
dydt(3) = y(1)*y(2) - b*y(3);

end