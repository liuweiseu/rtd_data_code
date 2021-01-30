function [status]=WritetoFile(filename,fold_d,period)
fp = fopen(filename,'w');
status = fp;
if(fp<0)
    disp("The file can't be opened!");
    return;
end
fprintf(fp,'%.18f\r\n',period);
for i = 1:length(fold_d)
    fprintf(fp,'%f\r\n',fold_d(i));
end
fclose(fp);
end

