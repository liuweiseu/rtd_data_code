function [period] = GetPeriod(pulsar_info_file,pulsar_name)
period = 0;
try
    d = importdata(pulsar_info_file);
catch
    disp('No file for Pulsar info!');
    return;
end

len = length(d.rowheaders);

for i = 1:len
    s = strcmp(d.rowheaders{i},pulsar_name);
    if(s == 1)
        period = d.data(i);
    end
end

end

