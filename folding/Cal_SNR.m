function [snr] = Cal_SNR(d)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    d = sort(d);
    len = length(d);
    %use half of the data to get the initial mean and var 
    len0 = floor(len/2);
    mean0 = mean(d(1:len0));
    v0 = var(d(1:len0),1);
    for i = 1:len
       if((d(i)-mean0)>3*v0)
           break;
       end
    end
    m1 = mean(d(1:i-1));
    d = d - m1;
    v1 = var(d(1:i-1),1);
    for i = 1:len
       if((d(i))>3*v1)
           break;
       end
    end
    p = sum(d(i:len));
    snr = p/(v1*sqrt(len-i+1));
end

