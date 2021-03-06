clc;
clear;

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

K = input('Average number :');


while cho~=0
    k=k+cho;
    filename = [filename_base,int2str(k)];
    load(filename);fprintf('No. %d--Period:%.18f\n',k,p);
    s = sprintf('No. %d--Period:%.18f',k,p);
    [N,M]=size(fold_d);
    
    for i=1:N/K
        f(i) = 0;
        for j=1:K
            f(i) = f(i) + fold_d( (i-1)*K + j );
        end
    end
    plot( f-mean(f) );grid;title(s)
    cho=input('Pls input choice: 0(or none) for next;1 for previous;2 for exit:');
    if cho == 0
        cho = 1;
    elseif cho == 1
        cho = -1;
    elseif cho == 2
        cho = 0;
    else
        cho = 1;
    end
end
