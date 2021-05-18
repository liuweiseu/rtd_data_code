function [lost] = SearchFrameHeader(fp,data)
global_para;
% let's read the data frame again, and search the frame header in it.
lost = -1;
Last_time_info = data(2)*2^32 + data(3)*2^16 + data(4);
time_info = data(Frame_len+2)*2^32 + data(Frame_len+3)*2^16 + data(Frame_len+4);
if((data(Frame_len+1) > Threshold) || (time_info == Last_time_info + Delta_time))
    lost = CheckTimeinfo(time_info);
    if( data(Frame_len+1)~= 65535)
        Header_err = Header_err + 1;
    end
end
% we found the frame header.
% let's move the pointer to the frame header.
fseek(fp,-8,0);
if(lost ~= -1)
    return;
end

% We didn't find the frame header.
% let's search the frame header in the data frame.
% because we lost some data, the frame header should be in the data frame.
fseek(fp,-2*Frame_len,0);
[data,cnt] = fread(fp,Frame_len+4,'uint16');
if(cnt ~= Frame_len+4)
    return;
end
pos = 0;
% 1. the frame header and time info may be in the data frame.
for i=4:Frame_len
    if(data(i)>Threshold)
        time_info = data(i+1)*2^32 + data(i+2)*2^16 + data(i+3);
    else
        continue;
    end
    lost = CheckTimeinfo(time_info);
    if(lost ~= -1)
        pos = i;
        lost = lost + 1;
        break;
    end
end

% if we find out the header in the data frame, 
% we need to know how many frames we lost.
if(pos ~= 0)
    fp_pos = -2*(Frame_len-pos+5);
    lost = lost;
else
    while(lost == -1)
        tmp = fread(fp,1,'uint16');
        if(tmp > Threshold)
            t = fread(fp,3,'uint16');
            time_info = t(1)*2^32 + t(2)*2^16 + t(3);
            lost = CheckTimeinfo(time_info);
        end
        if((lost == -1)&&(tmp>Threshold))
            fseek(fp,-6,0);
        end
    end
    lost = lost + 1;
    fp_pos = -8;
end
fseek(fp,fp_pos,0);
end

