function [T_range,dp] = CalDoppler(obs_t,obs_pos,T,dt)
v_earth = 463;
c = 3*10^8;
% if(obs_t==-1)
%     alfa = -pi/2;
% else
%     alfa = 2*pi*obs_t/(24*60*60);
% end
alfa = pi/2;
v_obs = v_earth * cos(obs_pos) * sin(alfa) * 1.2 ;
coff1 = c/(c+v_obs);
coff2 = c/(c-v_obs);
T_range(1) = T * coff1  ;
T_range(2) = T * coff2  ;
delta_T = T - T_range(1);
% cal dp
t_bin = dt;
dp = T/obs_t*t_bin/4;
end

