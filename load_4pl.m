function [DD] = load_4pl(filein)

%filein = '/Users/parsekia/Dropbox/UWyo_Faculty/grants/GCR_Musselman_Colorado_TLERT/data/tlert/2022-06-30_15-35-28.tx0';

fid = fopen(filein,'rt');
nLn = 1;
while true
    thisline = fgetl(fid);
    if strcmp(thisline(1:5),'* num'); break; end  %end of file
    nLn = nLn+1;
end
fclose(fid);

HeadderLines = nLn+1; % found number of headder lines, adjusted to beginning of data
fid = fopen(filein,'rt');
for i=1:HeadderLines; %loop through headderlines with pointer
    fgetl(fid);
end

dCnt = 1;
while true
    d = fgetl(fid);
    if d == -1 ; break; end
    dd = strsplit(d,[{' '}]);
    R = str2num(dd{8})/ str2num(dd{7});
    if isempty(R) %check to see if the data line is blank
        DD(dCnt,:) = [str2num(dd{3}) str2num(dd{4}) str2num(dd{5}) str2num(dd{6}) -9999 -9999 str2num(dd{12})];% A B M N R Unc rhoA
    else
        DD(dCnt,:) = [str2num(dd{3}) str2num(dd{4}) str2num(dd{5}) str2num(dd{6}) R R*str2num(dd{7}) str2num(dd{12})];% A B M N R Unc rhoA
    end

    dCnt = dCnt+1;
    %end
end

clear thisline R nLn i HeadderLines filein fid dd dCnt d ans
end
