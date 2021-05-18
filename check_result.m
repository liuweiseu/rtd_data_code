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

[N,M]=size(filename);

i=M-4;
i1=M-4;

while isstrprop(filename(i),'digit')
    i=i-1;
end

filename_base=filename(1:i);

k=str2num(filename(i+1:i1));

k=k-1;

cho=1;
%figure;

while cho~=0
    k=k+cho;
    filename = [filename_base,int2str(k)];
    load(filename);fprintf('No. %d--Period:%.18f\n',k,p);
    s = sprintf('No. %d--Period:%.18f',k,p);plot(fold_d);grid;title(s)
    cho=input('Pls input choice: 1 for next;2 for previous;0 for exit:');
    if cho == 2
        cho = -1;
    end
end
