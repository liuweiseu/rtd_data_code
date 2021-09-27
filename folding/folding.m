function [fold_d] = folding(data,period,dt)

N_int = floor(period/dt);
N_double = period/dt;
fold_d = zeros(N_int,1);
tmp = zeros(N_int,1);
cnt = zeros(N_int,1);
index_int = 0;
index_double = 0;
len_d = length(data);
while(index_int < len_d-N_int)
    index_int = index_int + N_int;
    fold_d = fold_d + data(index_int-N_int+1:index_int,1);
    tmp = data(index_int-N_int+1:index_int,1);
    for i=1:N_int
       if(tmp(i)>-1)
           cnt(i) = cnt(i) + 1;
       end
    end
    index_double = index_double + N_double;
    if((index_double - index_int) > 1)
        index_int = index_int + 1;
    end
end

for i=1:N_int
    if(cnt(i)~=0)
        fold_d(i) = fold_d(i)/(cnt(i));
    else
        fold_d(i) = 0; 
    end
end

% fprintf('Averange from %d to %d times. get cnt=0 for %d times out of %d!---',...
%     max(cnt),min(cnt),sum(cnt==0),N_int);

end

