function [lost] = CheckTimeinfo(time_info)
global_para;
delta_time_info = time_info - Last_time_info;
r = mod(delta_time_info,Delta_time);
if(r == 0)
    lost = delta_time_info/Delta_time-1;
else
    lost = -1;
end
end

