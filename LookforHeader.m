function [status] = LookforHeader(fp)
% Looking for the first frame header(0xffff) here.
status = -1;
frame_header = fread(fp,1,'uint16');
while(frame_header ~= 65535 && ~feof(fp))
    frame_header = fread(fp,1,'uint16');
end
if(frame_header == 65535)
    status = fseek(fp,-2,0);
end
end

