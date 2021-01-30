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
       if(tmp(i)~=0)
           cnt(i) = cnt(i) + 1;
       end
    end
    index_double = index_double + N_double;
    if((index_double - index_int) > 1)
        index_int = index_int + 1;
    end
end

for i=1:N_int
     fold_d(i) = fold_d(i)/cnt(i);
end

end

