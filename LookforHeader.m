function [status] = LookforHeader(fp, index)
% Looking for the first frame header(0xffff) here.
status = -1;
for i = 1:index
    frame_header = fread(fp,1,'uint16');
    while(frame_header ~= 65535 && ~feof(fp))
        frame_header = fread(fp,1,'uint16');
    end
end
if(frame_header == 65535)
    status = fseek(fp,-2,0);
end
end

