clc;
%------------------------- open data file ----------------------------
[filename0, pathname] = uigetfile( ...
    {'*.txt','data Files';...
    '*.*','All Files' },...
    'Select Data File',...
    '../RTD_data/result');
if isequal(filename0,0)
   disp('User selected Cancel')
   return;
else
   filename= fullfile(pathname, filename0);
end
figure;
d=load(filename);
fprintf('Period:%.18f\n',d(1));
s = sprintf('Period:%.18f',d(1));
plot(d(2:length(d)));
title(s)