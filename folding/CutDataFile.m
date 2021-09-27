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
RTD_CloseFile();
%------------------------- cal parameters ----------------------------
Delta_time = Num_acc*2048;
FFT_Points = 4096;
Fs = 2.4*10^9;
dt = Num_acc * FFT_Points/Fs;

t_required = input('Pls specify the length of data you want(s)=');

N_required = t_required/dt;

RequiredSize = floor(N_required/2048*(2048+4))*2; % bytes


name = [name,'_',num2str(t_required),'s'];

filename_n = [pathstr,'/',name,suffix];
fp_r = fopen(filename);
d = fread(fp_r,RequiredSize,'uint8');
fclose(fp_r);

fp_w = fopen(filename_n,'w');
fwrite(fp_w,d,'uint8');
fclose(fp_w);
