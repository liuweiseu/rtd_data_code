function [status] = Record(filename,index,result)
fp=fopen(filename,'a+');
status = fp;
if(fp<0)
    disp("The file can't be opened!");
    return;
end
fprintf(fp,'%d: %.2f\r\n',index,result);
fclose(fp);
end

