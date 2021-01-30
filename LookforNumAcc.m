function [numacc] = LookforNumAcc(fp)
global_para;
d = fread(fp,Frame_len + 4,'uint16');
numacc = 0;
t0 = 0;
t1 = 0;

if(d(1) == 65535)
    t0 = d(2) * 2^32 + d(3) * 2^16 + d(4);
end

if(d(Frame_len+1) == 65535)
   t1 = d(Frame_len+2) * 2^32 + d(Frame_len+3) * 2^16 + d(Frame_len+4); 
end

if(mod(t1-t0,Frame_len-4)==0)
    numacc = (t1 - t0)/(Frame_len - 4);
end
fseek(fp,-2*(Frame_len+4),0);
end

