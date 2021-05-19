clear;
clc;
close all;
global_para;

%---------------------Init global parameters--------------------------
Num_acc = 50;
Delta_time = Num_acc*2048;
Lost_frame = 0;
% frame: frame header(0xffff) + time_info(48bit) + data(2048 * 16 bits)
Frame_len = 1 + 3 + 2048;
Header_err = 0;
L_index = 1;
Lost_frame_total = 0;
%------------------------- cal parameters ----------------------------
FFT_Points = 4096;
Fs = 2.4*10^9;
dt = Num_acc * FFT_Points/Fs;
%------------------------- open data file ----------------------------
fp=fopen('../LFM.dat','r');

%--------------------------- Let's go! -------------------------------
% First, we need to find out the first frame header(0xffff).
status = LookforHeader(fp);
if(status == 0)
    disp('Find out the first frame header!');
else
    disp("We can't find a frame header in the file!!");
    return;
end

% Then, we start to read data frame from the file.
t = 0;
i = 1;
while(1)
    [d,t] = ReadFrame(fp);
    if(t<0)
        break;
    end
    time(i) = t;
    data(((i-1)*2048+1):(i*2048),1)=d(:,1);
    i = i + 1;
end

fclose(fp);
figure;
subplot(2,1,1);
plot(time);
title('Time info')
xlabel('Index');
ylabel('Time info');
subplot(2,1,2);
plot(diff(time));
title('Diff of time info');
xlabel('Index');
ylabel('Diff of time info');
