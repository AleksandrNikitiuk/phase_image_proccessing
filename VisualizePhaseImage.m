% İòà ôóíêöèÿ sòğîèò ôàçîâîå èçîáğàæåíèå.

function VisualizePhaseImage( phaseImage, type, dimension, locationScanLine )

% ÊÎÍÒĞÎËÜ ÂÕÎÄÍÛÕ ÄÀÍÍÛÕ

if (nargin < 3)
  dimension = '2d';
end

if (nargin < 2)
  type = '';
end

% ÎÏĞÅÄÅËÅÍÈÅ ÕÀĞÀÊÒÅĞÈsÒÈÊ ÃĞÀÔÈÊÀ

font = 'Verdana';
fontSize = 12;
fontWeight = 'normal';

phaseImageSize = size(phaseImage);

dimCoef = [1 1];
xLabel = 'x';
yLabel = 'y';

if ( strcmp(type,'tpg') == 1)
  pxlSize = 0.055650834762521; % 0.136950136950137
  dimCoef = [pxlSize pxlSize];
  xLabel = 'x, \mum';
  yLabel = 'y, \mum';
end

if ( strcmp(type,'tdg') == 1)
  pxlSize = 0.136950136950137;
  if (strcmp(locationScanLine(1),'x') == 1)
    dimCoef = [0.1191 pxlSize];
    yLabel = 'y, \mum';
    xLabel = 't, s';
  end
  if (strcmp(locationScanLine(1),'y') == 1)
    dimCoef = [pxlSize 0.0302];
    yLabel = 'x, \mum';
    xLabel = 't, s';
    phaseImage = phaseImage';
    phaseImageSize = size(phaseImage);
  end
end

% ÂÈÇÓÀËÈÇÀÖÈß ÔÀÇÎÂÎÃÎ ÈÇÎÁĞÀÆÅÍÈß s ÇÀÄÀÍÍÛÌÈ ÏÀĞÀÌÅÒĞÀÌÈ

switch dimension
  case '2d'
    %
    %figure;
    imagesc((1:phaseImageSize(2))*dimCoef(2), (1:phaseImageSize(1))*dimCoef(1), phaseImage);
    axis xy;
    xlabel(xLabel);
    ylabel(yLabel);
    c = colorbar;
    c.Label.String = '\Delta\phi, nm';
    c.Label.FontSize = fontSize;
    colormap('jet');
    %{
    if  (nargin > 1)
      hold on;
      if (strcmp(locationScanLine(1),'x') == 1)
        plot(zeros(1,topogramSize(1))+str2double(locationScanLine(2:end))*pxlSize, (1:topogramSize(1))*pxlSize,'k','LineWidth',3);
      end
      if (strcmp(locationScanLine(1),'y') == 1)
        plot((1:topogramSize(2))*pxlSize, zeros(1,topogramSize(2))+str2double(locationScanLine(2:end))*pxlSize,'k','LineWidth',3);
      end
      axis tight;
      hold off;
    end
    %}
    set(gca,'FontName',font,'FontSize',fontSize,'FontWeight',fontWeight);
    %}
  case '3d'
    %
%     figure;
    surf((1:phaseImageSize(2))*dimCoef(2), (1:phaseImageSize(1))*dimCoef(1), phaseImage, 'LineStyle', 'none');
    xlabel(xLabel);
    ylabel(yLabel);
    zlabel('\Delta\phi, nm');
    colormap('jet');
    %ax = gca;
    %ax.Visible = 'off';
    grid off;
    axis tight;
    box on;
    view(30,65);
    set(gca,'FontName',font,'FontSize',fontSize,'FontWeight',fontWeight);
    %}
end

clear ax myColormap c pxlSize topogramSize topogram

end

