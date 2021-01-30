clear;
clc;
close all;

global_para;

%---------------------Init global parameters--------------------------
Lost_frame = 0;
% frame: frame header(0xffff) + time_info(48bit) + data(2048 * 16 bits)
Frame_len = 1 + 3 + 2048;
Header_err = 0;
L_index = 1;
Lost_frame_total = 0;
Threshold = 60000;
%------------------------- open data file ----------------------------
[filename0, pathname] = uigetfile( ...
    {'*.dat','data Files';...
    '*.*','All Files' },...
    'Select Data File',...
    '');
if isequal(filename0,0)
   disp('User selected Cancel')
   return;
else
   filename= fullfile(pathname, filename0);
end

fp=fopen(filename,'r');
[pathstr,name,suffix]=fileparts(filename);
%---------- Search for the necessary patameters from the file---------

% Num_acc = input('Please type in the Num Acc:');
% period = input('Please type in the period of the signal(s):');

% Let's finish it automatically.
% First, we need to get the period from Pulsar_info.txt
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

% Then, we need to find the first frame header in the file.
status = LookforHeader(fp,2);
if(status ~= 0)
    disp("The frame header can't be found in the file!!");
    fclose(fp);
    return;
end

% Last, we need to search for the num_acc
Num_acc = LookforNumAcc(fp);
if(Num_acc == 0)
    disp("Num_acc is incorrect!");
    fclose(fp);
    return;
else
    fprintf('Num_acc = %d\n',Num_acc);
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
    [d,t] = ReadFrame(fp);
    if(t<0)
        break;
    end
    time(i) = t;
    data(((i-1)*2048+1):(i*2048),1)=d(:,1);
    i = i + 1;
%     if(i==6000)
%         break;
%     end
end
fclose(fp);
% plot the time info and data
time_s = time*512/(2.4*10^9);
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
end

i = 0;
fp = fopen(record_filename,'w+');
fclose(fp);
for p = p_range(1) : dp : p_range(2)
    fold_d = folding(data,p,dt);
    % write the data into a file for future analysis
    result_filename = [pathstr,'/result/',name,'/',name,'_result',int2str(i),'.txt'];
    WritetoFile(result_filename,fold_d,p);
    % check the data
    result = DataAnalysis(fold_d);
%     if(result > 0)
        Record(record_filename,i,result);
%     end
    i = i + 1
end

    
