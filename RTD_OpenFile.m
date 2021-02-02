function [Num_Acc] = RTD_OpenFile(filename)
global_para;

Num_Acc = -1;

% Open the file first
RTD_fp = fopen(filename,'r');
if(RTD_fp < 0)
    disp("The data file can't be opened!");
    return;
end

% Search for the frame header and cal Num_Acc
frame_header = fread(RTD_fp,1,'uint16');
while(frame_header ~= 65535 && ~feof(RTD_fp))
    frame_header = fread(RTD_fp,1,'uint16');
    if(frame_header ~= 65535)
        continue;
    else
       d = fread(RTD_fp,Frame_len + 3,'uint16');
       t0 = d(1) * 2^32 + d(2) * 2^16 + d(3);
       t1 = d(Frame_len+1) * 2^32 + d(Frame_len+2) * 2^16 + d(Frame_len+3);
       if(mod(t1-t0,Frame_len-4)==0)
            Num_Acc = (t1 - t0)/(Frame_len - 4);
            fseek(RTD_fp,-2*(Frame_len+4),0);
            break;
       else
           fseek(RTD_fp,-2*(Frame_len+3),0);
       end
    end
end

end

