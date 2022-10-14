ext = 'tiff';

path = [uigetdir '\'];

files = dir(path);
files = files(3:end);
n_files = length(files);

for n_file = 1:n_files
  [~,~,extention] = fileparts([path '\' files(n_file).name]);
  if strcmp(extention, '.fig')
    openfig([path '\' files(n_file).name]);
    set_figure;
    if strcmp(ext,'eps')
      print('-depsc',[path files(n_file).name(1:end-4)]);
    else
%       saveas(gcf,[path files(n_file).name(1:end-3) ext]);
      print([path files(n_file).name(1:end-4)],['-d' ext],'-r1000');
    end    
    close all;
  end
end

function set_figure
% Функция для настройки внешнего вида графиков.

% Font settings
font = 'Times New Roman';
fontSize = 14;
fontWeight = 'normal';

box on;

% Labels
%
xLabel = 'log(t)';
xlabel(xLabel);
yLabel = 'log(F)';
ylabel(yLabel);
%}

% Axis and grid settings
%{
grid on;
axis xy;
axis tight;
%}

% Axis limits
%{
% xlim([0 600]);
ylim([0.1 0.17]);
%}

%{
colormap('jet');
c = colorbar;
c.Label.String = 'log_{10}(|A(u,v)|)';
%}

% Title
% title('MCF-7 with BMK');

set(gca,'FontName',font,'FontSize',fontSize,'FontWeight',fontWeight);
end