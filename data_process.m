clear;
clc;
close all;

global_para;

%---------------------Init global parameters--------------------------
InitGlobal();
%------------------------- open data file ----------------------------
[filename0, pathname] = uigetfile( ...
    {'*.dat','data Files';...
    '*.*','All Files' },...
    'Select Data File',...
    '../RTD_data');
if isequal(filename0,0)
   disp('User selected Cancel')
   return;
else
   filename= fullfile(pathname, filename0);
end

Num_acc = RTD_OpenFile(filename);
[pathstr,name,suffix]=fileparts(filename);

%---------- Search for the necessary patameters from the file---------
% We need to get the period from Pulsar_info.txt
s = strsplit(name,'_');
pulsar_name = s{1};
fprintf('Pulsar : %s\n', pulsar_name);
period = GetPeriod('Pulsar_info.txt',pulsar_name);
if(period > 0)
    fprintf('Period(s): %.18f\n',period);
else
    disp("The pulsar info can't be found!");
    fclose(fp);
    return;
end

%------------------------- cal parameters ----------------------------
Delta_time = Num_acc*2048;
FFT_Points = 4096;
Fs = 2.4*10^9;
dt = Num_acc * FFT_Points/Fs;

%---------------------------- Let's go -------------------------------
% We start to read data frame from the file.
% We will check the time info first, and get zeros, if we find frame loss.
i = 1;
while(1)
    [d,t] = RTD_ReadFrame();
    if(t<0)
        break;
    end
    time(i) = t;
    data(((i-1)*2048+1):(i*2048),1)=d(:,1);
    i = i + 1;
end
RTD_CloseFile();
% plot the time info and data
time_s = time*512/(300*10^6);
figure;
subplot(3,1,1);
plot(time_s,'r-*');
ylabel('t(s)');
title('Time Info');
subplot(3,1,2);
plot(diff(time)*512/(2.4*10^9)*1000,'g-*');
ylabel('t(ms)');
title('Diff of Time Info');
subplot(3,1,3);
t = (1:length(data))*dt;
plot(t,data,'b');
xlabel('t(s)');
title('data');

% Next is folding.
obs_time = max(t);
fprintf('Obs_time(s): %.2f\n',obs_time);
[p_range,dp] = CalDoppler(obs_time,0,period,dt);

p_range(1) = p_range(1) - 0.0001;
p_range(2) = p_range(2) + 0.0001;

cycle = floor((p_range(2) - p_range(1)) / dp);
disp('Period range is(s):')
fprintf('%.18f\n',p_range(1));
fprintf('%.18f\n',p_range(2));
fprintf('Delat_p(s): %.18f\n',dp);
disp(['Cycle:',int2str(cycle)]);


record_filename = [pathstr,'/record/',name,'_record','.txt'];

%creat folders for results
if exist([pathstr,'/result/'],'dir')==0
   mkdir([pathstr,'/result/']);
end

if exist([pathstr,'/record/'],'dir')==0
   mkdir([pathstr,'/record/']);
end

if exist([pathstr,'/result/',name,'/'],'dir')==0
   mkdir([pathstr,'/result/',name,'/']);
else
   delete([pathstr,'/result/',name,'/','*.txt']);
end

i = 1;
fp = fopen(record_filename,'w+');
fprintf(fp,'obs_time(s): %.2f\n',obs_time);
fclose(fp);

for p = p_range(1) : dp : p_range(2)
    fold_d = folding(data,p,dt);
    % write the data into a file for future analysis
    result_filename = [pathstr,'/result/',name,'/',name,'_result',int2str(i),'.txt'];
    WritetoFile(result_filename,fold_d,p);
    % check the data
    result(i) = DataAnalysis(fold_d);
    Record(record_filename,i,result(i));
    i = i + 1
end

figure;
plot(result);

    
