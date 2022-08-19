function [pdf, x, x2] = get_pdf(data, n)

min_value = min(data);
max_value = max(data);
len_data = length(data);
step = (max_value-min_value)/n;

pdf = zeros(n+1,1);
for i = 1:length(data)
  k = floor((data(i) - min_value) / step) + 1;
  pdf(k) = pdf(k) + 1;
end
pdf = pdf ./ (len_data*step);
pdf = pdf / max(pdf);
x = min_value + step/2 + (0:n).*step;
x2 = sign(x-mean(data)) .* ( (x-mean(data))./sqrt(var(data)) ).^2;

end