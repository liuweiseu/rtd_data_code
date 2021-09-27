clear;
clc;
close all;

% add the path of psf_rw
addpath(genpath('../rtd_rw'));

global_para;

%---------------------Init global parameters--------------------------
InitGlobal();
%------------------------- open data file ----------------------------
[filename0, pathname] = uigetfile( ...
    {'*.dat','data Files';...
    '*.*','All Files' },...
    'Select Data File',...
    '../../Yunnan_Data/J0835-4510_0');
if isequal(filename0,0)
   disp('User selected Cancel')
   return;
else
   filename= fullfile(pathname, filename0);
end

Num_acc = RTD_OpenFile(filename)
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
    RTD_CloseFile();
    return;
end
folding_start_time = input('Folding start at(raw time info, default means no data is skipped):');
folding_start_time = folding_start_time + 8;
%------------------------- cal parameters ----------------------------
Delta_time = Num_acc*2048;
FFT_Points = 4096;
Fs = 2.4*10^9;
dt = Num_acc * FFT_Points/Fs;

%---------------------------- Let's go -------------------------------
% We start to read data frame from the file.
% We will check the time info first, and get zeros, if we find frame loss.

% let's check the start time first
[d,fisrt_time_info] = RTD_ReadFrame();
fisrt_time_info
% check if we have specified a folding_start_time
if(length(folding_start_time)>0)
    skip_data = 1;
else
    skip_data = 0;
end
% if so, we need to check the folding_start_time
if(skip_data == 1)
    if( fisrt_time_info>folding_start_time)
        disp('The folding start time is smaller than the fisrt time info!');
        return;
    elseif(rem(folding_start_time-fisrt_time_info,Num_acc)~=0)
        disp('Invalid folding start time, please check it!');
        return;
    else
        skip_samples = (folding_start_time-fisrt_time_info)/Num_acc;
    end
end

bin = input('Pls type in the bin number(default-512; -1-Original number):');

if(length(bin) == 0)
   bin = 512;
end

% get data from the data file, and skip the data get before the folding start time
data_seg0 = [];
if(skip_data == 1)
    for i = 1:floor(skip_samples/(Frame_len-4))
        [d,t] =  RTD_ReadFrame();
        if(t<0)
            disp('There is not enough data for the skipping operation!')
            return;
        end
    end
remaining = rem(skip_samples,Frame_len-4);
data_seg0 = d(remaining+1:(Frame_len-4),1);
end
t_start=datetime;
i = 1;
while(1)
    [d,t] = RTD_ReadFrame();
     if(t<0)
        break;
     end
    time(i) = t;
    data_seg1(((i-1)*2048+1):(i*2048),1)=d(:,1);
    i = i + 1;
end
data = [data_seg0; data_seg1];
RTD_CloseFile();

obs_time = input('How long you want to observe?(s,default:-1):')
if(obs_time~=-1)
    obs_len = floor(obs_time/dt);
    data = data(1:obs_len);
end

% plot the time info and data
time_s = time*512/(300*10^6);
figure;
subplot(3,1,1);
plot(time_s,'r-*');grid;
ylabel('t(s)');
title('Time Info');
subplot(3,1,2);
plot(diff(time)*512/(2.4*10^9)*1000,'g-*');grid;
% ylabel('t(ms)');
title('Diff of Time Info');
subplot(3,1,3);
t = (1:length(data))*dt;
plot(t,data,'b');grid;
xlabel('t(s)');
title('data');

% Next is folding.
obs_time = max(t);
fprintf('Obs_time(s): %.2f\n',obs_time);
[p_range,dp] = CalDoppler(obs_time,0,period,dt);

 p_range(1) = p_range(1) - 0.00001;
 p_range(2) = p_range(2) + 0.00001;
  p_range(1)=period;
  p_range(2)=period;
cycle = floor((p_range(2) - p_range(1)) / dp);


fprintf('Searching Period from %.12f to %.12f step %.12f; totally %d cycles\n',...
    p_range(1),p_range(2),dp,cycle);

record_filename = [pathstr,'/record/',name,'_record'];

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
% fp = fopen(record_filename,'w+');
% fprintf(fp,'obs_time(s): %.2f\n',obs_time);
% fclose(fp);
result_max=0;
for p = p_range(1) : dp : p_range(2)
    fprintf('folding No. %d of  %d--',i,cycle+1);
    fold_d = folding(data,p,dt);
    % write the data into a file for future analysis
    result_filename = [pathstr,'/result/',name,'/',name,'_result',int2str(i)];
    %WritetoFile(result_filename,fold_d,p);

    save(result_filename,'fold_d','p');
    p_i(i)=p;
    
    % check the data
    result(i) = DataAnalysis(fold_d);
    
    if result(i)>result_max
        result_max=result(i);
        fold_result=fold_d;
        period_result=sprintf('Period:%.12f in i=%d',p,i);
        i_result = i;
    end
    
    
    fprintf('result: %f\n',result(i));    
%    Record(record_filename,i,result(i));
    i=i+1;
end
t_stop=datetime;

fprintf('Processing time:\r\n');
between(t_start,t_stop)

save(record_filename,'result','i_result',...
'fold_result','period_result','obs_time','Num_acc');

figure;
plot(result);grid;title('Result');

[N,I]=max(result);

fprintf('Estimated period is %.15f where i = %d\n',p_i(I),I);

if(bin > 0)
    len = length(fold_result);
    delta_bin = floor(len/bin);
    for i=1:bin-1
       tmp(i) = sum(fold_result((i-1)*delta_bin+1:i*delta_bin))/delta_bin; 
    end
    tmp(bin)=sum(fold_result((bin-1)*delta_bin+1:len))/(len-(bin-1)*delta_bin); 
end
fold_result = tmp;
tmp = sort(fold_result);
m = mean(tmp(1:length(tmp/2)));
fold_result = fold_result - m;
snr = Cal_SNR(fold_result);
name = [period_result,'  ','SNR: ',num2str(snr)];
figure;
fold_t = (1:length(fold_result))*dt*1000;
fold_t = fold_t/max(fold_t);
plot(fold_t,fold_result);grid;
set(gca,'FontSize',14);
title(name,'FontSize',16);
xlabel('Phase','FontSize',16);
ylabel('Power','FontSize',16);
    
