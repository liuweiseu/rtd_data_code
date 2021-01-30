clc;
%------------------------- open data file ----------------------------
[filename0, pathname] = uigetfile( ...
    {'*.txt','data Files';...
    '*.*','All Files' },...
    'Select Data File',...
    '');
if isequal(filename0,0)
   disp('User selected Cancel')
   return;
else
   filename= fullfile(pathname, filename0);
end
figure;
d=load(filename);
plot(d(2:length(d)));
