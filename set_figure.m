% Font settings
font = 'Verdana';
fontSize = 12;
fontWeight = 'normal';

% Labels
%{
xLabel = 'base pairs';
xlabel(xLabel);
yLabel = 'time, t.u.';
ylabel(yLabel);
% zLabel = 'r_n-R_0, angstrom'; % r_n-R_0, angstrom \phi_n-\theta_0, rad
% zlabel(zLabel);
%}

% Axis and grid settings
%{
grid off;
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
c.Label.String = 'r_n-R_0, angstrom'; % r_n-R_0, angstrom \phi_n-\theta_0, rad
%}

% Title
% title('MCF-7 with BMK');

box on;

set(gca,'FontName',font,'FontSize',fontSize,'FontWeight',fontWeight);