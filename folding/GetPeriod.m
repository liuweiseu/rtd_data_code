function [period] = GetPeriod(pulsar_info_file,pulsar_name)
period = 0;
try
    d = importdata(pulsar_info_file);
catch
    disp('No file for Pulsar info!');
    return;
end

try
    % this is for matlab2020a
    name = d.rowheaders;
catch
    % this is for matlab2021a
    name = d.textdata;
end
len = length(name);

for i = 1:len
    s = strcmp(name{i},pulsar_name);
    if(s == 1)
        period = d.data(i);
    end
end

end

