clc;
%------------------------- open data file ----------------------------
[filename0, pathname] = uigetfile( ...
    {'*.txt','data Files';...
    '*.*','All Files' },...
    'Select Data File',...
    '../data/result');
if isequal(filename0,0)
   disp('User selected Cancel')
   return;
else
   filename= fullfile(pathname, filename0);
end
figure;
d=load(filename);
d(1)
plot(d(2:length(d)));
