function [status] = DataAnalysis(data)
status = -1;
Threshold = 3;
data = data-mean(data);
if(max(data)>Threshold)
    status = max(data);
end
status = max(data);
end

