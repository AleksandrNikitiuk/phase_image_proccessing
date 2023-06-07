%%
% Эта функция предназначена для обработки "сырой" топограммы.

function [ processTpg ] = ProcessRowPhaseImage( tpg,processType )

% КОНТРОЛЬ ВХОДНЫХ ДАННЫХ

if nargin < 2
  processType = 'sps';
end

if ~isnumeric(tpg)
  error('ProcessRowPhaseImage:valueIsNotNumeric',...
    'Value must be numeric');
end

% ВЫБОР МЕТОДА ОБРАБОТКИ

%
switch processType
  case 'ps' % удаление фазовых сдвигов
    processTpg = DeletePhaseShifts(tpg);
  case 'sps' % удаление фазовых сдвигов и наклона поверхности
    processTpg = DeleteSlope(DeletePhaseShifts(tpg));
  case 'pps' % удаление фазовых сдвигов и параболичности поверхности
    processTpg = DeleteParabolic(DeletePhaseShifts(tpg));
  case 'p5ps' % удаление фазовых сдвигов и поверхности 5 порядка
    processTpg = DeletePolynomial5(DeletePhaseShifts(tpg));
  case 'psps' % удаление фазовых сдвигов, наклона поверхности и параболичности
    processTpg = DeleteParabolic(DeleteSlope(DeletePhaseShifts(tpg)));
  case 'p5sps' % удаление фазовых сдвигов, наклона поверхности и поверхности 5 порядка
    processTpg = DeletePolynomial5(DeleteSlope(DeletePhaseShifts(tpg)));
  case 'nps' % удаление фазовых сдвигов и шума у трек-диаграмм
    processTpg = DeleteNoise(DeletePhaseShifts(tpg));
  case 'bps' % удаление фазовых сдвигов и фона
    processTpg = DeleteBackground( DeletePhaseShifts(tpg) );
  case 'bsps' % удаление фазовых сдвигов, наклона поверхности и фона
    processTpg = DeleteBackground( DeleteSlope(DeletePhaseShifts(tpg)) );
  case 'pbps' % удаление фазовых сдвигов, поверхности 5 порядка и фона
    processTpg = DeleteParabolic( DeleteBackground(DeletePhaseShifts(tpg)) );
  case 'p5bps' % удаление фазовых сдвигов, поверхности 5 порядка и фона
    processTpg = DeletePolynomial5( DeleteBackground(DeletePhaseShifts(tpg)) );
  case 'bp5bps' % удаление фазовых сдвигов, поверхности 5 порядка и фона
    processTpg = DeleteBackground( DeletePolynomial5( DeleteBackground(DeletePhaseShifts(tpg)) ) );
  case 'fsps'% удаление фазовых сдвигов, фона и сбойных точек
    processTpg = DeleteFailurePoints(DeleteSlope(DeletePhaseShifts(tpg)));
  otherwise
    processTpg = tpg;
end

end


%%
% Эта функция предназначена для удаления фазовых сдвигов "сырой" топограммы.

function [ phaseImage ] = DeletePhaseShifts( phaseImage, lambda )

% КОНТРОЛЬ ВХОДНЫХ ДАННЫХ

if (nargin < 2)
  lambda = 655;
end

threshold = .5 * lambda/2;

% УДАЛЕНИЕ ФАЗОВЫХ СДВИГОВ В НАПРАВЛЕНИИ СПРАВА НАЛЕВО

%
for i = 1:size(phaseImage,1)
  for j = size(phaseImage,2):-1:2
    
    d = phaseImage(i,j) - phaseImage(i,j-1);
    if ( abs(d) > threshold )
      if (d > 0 )
        phaseImage(i,j-1) = phaseImage(i,j-1) + lambda/2;
      else
        phaseImage(i,j-1) = phaseImage(i,j-1) - lambda/2;
      end
    end
    
  end
end
%}

% УДАЛЕНИЕ ФАЗОВЫХ СДВИГОВ В НАПРАВЛЕНИИ СЛЕВА НАПРАВО

%
for i = 1:size(phaseImage,1)
  for j = 1:size(phaseImage,2)-1
    
    d = phaseImage(i,j) - phaseImage(i,j+1);
    if ( abs(d) > threshold )
      if (d < 0 )
        phaseImage(i,j+1) = phaseImage(i,j+1) - lambda/2;
      else
        phaseImage(i,j+1) = phaseImage(i,j+1) + lambda/2;
      end
    end
    
  end
end
%}

% УДАЛЕНИЕ ФАЗОВЫХ СДВИГОВ В НАПРАВЛЕНИИ СВЕРХУ ВНИЗ

%
for i = size(phaseImage,1):-1:2
  for j = 1:size(phaseImage,2)
    
    d = phaseImage(i,j) - phaseImage(i-1,j);
    if ( abs(d) > threshold )
      if (d > 0 )
        phaseImage(i-1,j) = phaseImage(i-1,j) + lambda/2;
      else
        phaseImage(i-1,j) = phaseImage(i-1,j) - lambda/2;
      end
    end
    
  end
end
%}

% УДАЛЕНИЕ ФАЗОВЫХ СДВИГОВ В НАПРАВЛЕНИИ СНИЗУ ВВЕРХ

%
for i = 1:size(phaseImage,1)-1
  for j = 1:size(phaseImage,2)
    
    d = phaseImage(i,j) - phaseImage(i+1,j);
    if ( abs(d) > threshold )
      if (d < 0 )
        phaseImage(i+1,j) = phaseImage(i+1,j) - lambda/2;
      else
        phaseImage(i+1,j) = phaseImage(i+1,j) + lambda/2;
      end
    end
    
  end
end
%}

phaseImage = phaseImage - min(min(phaseImage));

end

%%
% Эта функция предназначена для удаления наклона поверхности.

function [ tpgWithoutSlope ] = DeleteSlope( tpg )

sizeTpg = size(tpg);

% ОПРЕДЕЛЕНИЕ КОЭФФИЦИЕНТОВ ПЛОСКОСТИ АППРОКСИМИРУЮЩЕЙ ИСХОДНЫЕ ДАННЫЕ

[xo,yo,zo] = prepareSurfaceData(1:sizeTpg(2),1:sizeTpg(1),tpg);
f = fit([xo,yo],zo, 'poly11');

% ПОЛУЧЕНИЕ ПЛОСКОСТИ АППРОКСИМИРУЮЩЕЙ ИСХОДНЫЕ ДАННЫЕ

col1 = f.p00 + f.p10 * (1:sizeTpg(2));
mCol1 = repmat(col1,sizeTpg(1),1);
row1 = f.p01 * (1:sizeTpg(1))';
mRow1 = repmat(row1,1,sizeTpg(2));
plane = mCol1 + mRow1;

% УДАЛЕНИЕ НАКЛОНА ИСХОДНОЙ ПОВЕРХНОСТИ

tpgWithoutSlope = zeros(sizeTpg);
tpgWithoutSlope = tpg - plane;
tpgWithoutSlope = tpgWithoutSlope + abs(min(min(tpgWithoutSlope)));

end

%%
% Эта функция предназначена для удаления параболичности поверхности.

function [ tpgWithoutParabolic ] = DeleteParabolic( tpg )

sizeTpg = size(tpg);

% ОПРЕДЕЛЕНИЕ КОЭФФИЦИЕНТОВ ПЛОСКОСТИ АППРОКСИМИРУЮЩЕЙ ИСХОДНЫЕ ДАННЫЕ

[xo,yo,zo] = prepareSurfaceData(1:sizeTpg(2),1:sizeTpg(1),tpg);
f = fit([xo,yo],zo, 'poly22');

% ПОЛУЧЕНИЕ ПЛОСКОСТИ АППРОКСИМИРУЮЩЕЙ ИСХОДНЫЕ ДАННЫЕ

surface = feval(f,repmat(1:sizeTpg(2),sizeTpg(1),1),repmat(1:sizeTpg(1),sizeTpg(2),1)');

% УДАЛЕНИЕ НАКЛОНА ИСХОДНОЙ ПОВЕРХНОСТИ

tpgWithoutParabolic = zeros(sizeTpg);
tpgWithoutParabolic = tpg - surface;
tpgWithoutParabolic = tpgWithoutParabolic + abs(min(min(tpgWithoutParabolic)));

end

%%
% Эта функция предназначена для удаления поверхности пятого порядка.

function [ tpgWithoutPolynomial5 ] = DeletePolynomial5( tpg )

sizeTpg = size(tpg);

% ОПРЕДЕЛЕНИЕ КОЭФФИЦИЕНТОВ ПЛОСКОСТИ АППРОКСИМИРУЮЩЕЙ ИСХОДНЫЕ ДАННЫЕ

[xo,yo,zo] = prepareSurfaceData(1:sizeTpg(2),1:sizeTpg(1),tpg);
f = fit([xo,yo],zo, 'poly55');

% ПОЛУЧЕНИЕ ПЛОСКОСТИ АППРОКСИМИРУЮЩЕЙ ИСХОДНЫЕ ДАННЫЕ

surface = feval(f,repmat(1:sizeTpg(2),sizeTpg(1),1),repmat(1:sizeTpg(1),sizeTpg(2),1)');

% УДАЛЕНИЕ НАКЛОНА ИСХОДНОЙ ПОВЕРХНОСТИ

tpgWithoutPolynomial5 = zeros(sizeTpg);
tpgWithoutPolynomial5 = tpg - surface;
tpgWithoutPolynomial5 = tpgWithoutPolynomial5 + abs(min(min(tpgWithoutPolynomial5)));
% mask = zeros(size(tpg));
% mask(tpg > ((max(tpg(:)) - min(tpg(:))) / 2)) = 1;
% tpgWithoutPolynomial5 = tpgWithoutPolynomial5 .* mask;

end

%%
% Эта функция выделяет фазовое изображение клетки, удаляя фон.

function [ phaseImageWithoutNoise ] = DeleteBackground( phaseImage,countourLevel )

% КОНТРОЛЬ ВХОДНЫХ ДАННЫХ

if (nargin < 2)
  countourLevel = 1;
end

% ВЫДЕЛЕНИЕ ФАЗОВОГО ИЗОБРАЖЕНИЯ КЛЕТКИ

c = contourc(phaseImage,countourLevel);
phaseImageWithoutNoise = phaseImage - c(1,1);
phaseImageWithoutNoise(phaseImageWithoutNoise<0) = 0;

end

%%
% Эта функция удаляет сбойные точки исходной топограммы.

function [ processTpg ] = DeleteFailurePoints( tpg, lambda )

% КОНТРОЛЬ ВХОДНЫХ ДАННЫХ

if (nargin < 2)
  lambda = 655;
end

threshold = .5 * lambda/2;

minimum = false;
repeat = true;
while (repeat == true)

  repeat = false;
  
  minPoint = min(min(tpg));
  
  [row,col] = find(tpg==minPoint(1));
  
  if (col(1) ~= 1 && col(1) ~= size(tpg,2))
    
    if ( abs(minPoint - tpg( row(1),col(1)-1 )) > threshold )
      tpg(row(1),col(1)) = tpg(row(1),col(1)-1);
      repeat = true;
      minimum = true;
    end
    if ( abs(minPoint - tpg( row(1),col(1)+1 )) > threshold )
      tpg(row(1),col(1)) = tpg(row(1),col(1)+1);
      repeat = true;
      minimum = true;
    end
    
  end
  
  if (row(1) ~= 1 && row(1) ~= size(tpg,1))
    
    if ( abs(minPoint - tpg( row(1)-1,col(1) )) > threshold )
      tpg(row(1),col(1)) = tpg(row(1)-1,col(1));
      repeat = true;
      minimum = true;
    end
    if ( abs(minPoint - tpg( row(1)+1,col(1) )) > threshold )
      tpg(row(1),col(1)) = tpg(row(1)+1,col(1));
      repeat = true;
      minimum = true;
    end
    
  end
  
end

repeat = true;
while (repeat == true)

  repeat = false;
  
  maxPoint = max(max(tpg));

  [row,col] = find(tpg==maxPoint(1));
  
  if (col(1) ~= 1 && col(1) ~= size(tpg,2))
    
    if ( abs(maxPoint - tpg( row(1),col(1)-1 )) > threshold )
      tpg(row(1),col(1)) = tpg(row(1),col(1)-1);
      repeat = true;
    end
    if ( abs(maxPoint - tpg( row(1),col(1)+1 )) > threshold )
      tpg(row(1),col(1)) = tpg(row(1),col(1)+1);
      repeat = true;
    end
    
  end
  
  if (row(1) ~= 1 && row(1) ~= size(tpg,1))
    
    if ( abs(maxPoint - tpg( row(1)-1,col(1) )) > threshold )
      tpg(row(1),col(1)) = tpg(row(1)-1,col(1));
      repeat = true;
    end
    if ( abs(maxPoint - tpg( row(1)+1,col(1) )) > threshold )
      tpg(row(1),col(1)) = tpg(row(1)+1,col(1));
      repeat = true;
    end
    
  end
  
end

if (minimum == true)
  processTpg = tpg - min(min(tpg));
else
  processTpg = tpg;
end

end

%%
% Эта функция предназначена для удаления наклона трек-диаграммы.

function [ phaseImage ] = DeleteNoise( phaseImage )

%   phaseImage = detrend(phaseImage,1);

phaseImageSize = size(phaseImage);
range = [1; phaseImageSize(1)];
for i = 1:phaseImageSize(2)
  p = polyfit(range, phaseImage(range, i),1);
  background_noise = polyval(p, 1:phaseImageSize(1));
  phaseImage(:,i) = phaseImage(:,i) - background_noise';
end
phaseImage = phaseImage + abs(min(min(phaseImage)));

end

