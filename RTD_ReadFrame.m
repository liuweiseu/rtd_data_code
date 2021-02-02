function [d,t] = RTD_ReadFrame()
% we read data frame from the file.
% return:   1. d -- 2048 * 16bits data
%           2. t -- time info
%           if t<0, it means we read to the end of the file.
global_para;
if(Lost_frame > 0)
   d = zeros(Frame_len-4,1);
   t = Last_time_info;
   Last_time_info = t + Delta_time;
   Lost_frame = Lost_frame - 1;
   return;
end

[data,cnt] = fread(RTD_fp,Frame_len + 4,'uint16');
% if we read to the end of the file.
if(cnt ~= Frame_len+4)
    d = zeros(Frame_len-4,1);
    t = -1;
    return;
end

Lost_frame = SearchFrameHeader(RTD_fp,data);

if(Lost_frame > 0)
   % record the number of lost frames.
   Lost_frame_total(L_index) = Lost_frame;
   L_index = L_index + 1;
   % return zeros back
   d = zeros(Frame_len-4,1);
   % return a corrct time info
   t = Last_time_info;
   Last_time_info = t + Delta_time;
   Lost_frame = Lost_frame - 1;
   return;
elseif(Lost_frame < 0)
    disp('Time Info Error!');
    t = data(2)*2^32 + data(3)*2^16 + data(4);
    d = data(5:Frame_len,1);
    return;
else
    t = data(2)*2^32 + data(3)*2^16 + data(4);
    d = data(5:Frame_len,1);
    return;
end

end

