function [] = InitGlobal()
global_para;
% record the lost frames
Lost_frame = 0;
% frame: frame header(0xffff) + time_info(48bit) + data(2048 * 16 bits)
Frame_len = 1 + 3 + 2048;
% record the header errors
Header_err = 0;
% record the current lost frames
L_index = 1;
% record the numbers of all the lost frames
Lost_frame_total = 0;
% there are errors on each data.
% this is used for checking header.
% if the data value is greater than the threshold, it could be a frame header
Threshold = 60000;

end

