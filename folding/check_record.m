clc;
%------------------------- open data file ----------------------------
[filename0, pathname] = uigetfile( ...
    {'*.mat','data Files';...
    '*.*','All Files' },...
    'Select Data File',...
    '../RTD_data/result');
if isequal(filename0,0)
   disp('User selected Cancel')
   return;
else
   filename= fullfile(pathname, filename0);
end

%d=load(filename);
load(filename);

fprintf('Estimated period is %.15f where i = %d\n',period_result,i_result);
fprintf('Obs_time(s): %.2f\n',obs_time);

figure;
plot(fold_result);grid;
title(period_result)
