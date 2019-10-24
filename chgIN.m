function chgIN( mB,inpath,inname,outpath )
%UNTITLED3 Summary of this function goes here
% Read txt into cell A
fid = fopen([inpath '\' inname],'r');
i = 1;
tline = fgetl(fid);
A{i} = tline;
while ischar(tline)
    i = i+1;
    tline = fgetl(fid);
    A{i} = tline;
end
fclose(fid);
% Change cell A

formatSpec = '%0.3f %0.3f %g %g';
A{9} = sprintf(formatSpec,mB(2),mB(1),1e-6,1e6);
% Write cell A into txt
fid = fopen([outpath '\R2.in'], 'w');
for i = 1:numel(A)
    if A{i+1} == -1
        fprintf(fid,'%s', A{i});
        break
    else
        fprintf(fid,'%s\n', A{i});
    end
end
end

