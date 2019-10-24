function preprocMPT( dataLoc, minVal, errRecip )
%preprocMPT
%  %imports, removes bad data based on reciprocals, removes NANS, removes negative values, writes Protocol
% minVal is the smallest R value that will be kept
% errRecip is the reciprocal error threshold that will be retained

D = importMPT(dataLoc); %auto import fxn generated by MATLA B
abmn = [D(:,3) D(:,5) D(:,7) D(:,9)]; %takes electrode locations from raw data
R = D(:,10); %takes resistance from raw data
dat = [abmn R D(:,11)]; %makes a single matrix out of all raw data

%% clen up negative or NaN values
dat_a = sortrows(dat,5); %sort based on colum that will have NaNs
firstD = max(find(dat_a(:,5)<minVal))+1; %finds the last negative val, +1 for first positive value. used to delete negative R vals
lastD = find(~isnan(dat_a(:,5)),1,'last'); %finds the begning of the NaN rows to delete

dat = dat_a(firstD:lastD,:); %take only rows >0 and without NaN R values
%% Loop through all quadrapoles to find reciprocals
inst = dat;
    for i = 1:length(inst)
        tx = sort(inst(i,1:2));
        rx = sort(inst(i,3:4));
        
        for j = 1:length(inst)
            Tx = sort(inst(j,1:2));
            Rx = sort(inst(j,3:4));
            
            if rx == Tx & tx == Rx
                reciprocal(i,:) = [tx rx Tx Rx inst(i,5) inst(j,5)];
                
            end
        end
    end
    
    for i = 1:length(reciprocal)
        holder = reciprocal(i,:);
        reciprocal(i,:) = [0 0 0 0 0 0 0 0 0 0];
        for j = 1:length(reciprocal)
            if reciprocal(j,1:8) == [holder(5:8) holder(1:4)]
                reciprocal(j,:) = [0 0 0 0 0 0 0 0 0 0];
            end
        end
        reciprocal(i,:) = holder;
    end
    reciprocal = reciprocal(find(reciprocal(:,1)),:);
    reciprocal = [reciprocal(:,1:4) reciprocal(:,9:10)];
    reciprocal(:,7) = abs(reciprocal(:,5) - reciprocal(:,6));  %adds column 7 whihch is the abs.diff between FWD/RECIP
       
    for i = 1:length(reciprocal)
        if max(reciprocal(i,1:2))>max(reciprocal(i,3:4))
            reciprocal(i,1:4) = [sort(reciprocal(i,3:4),2) sort(reciprocal(i,1:2),2)];
        else
            reciprocal(i,1:4) = [sort(reciprocal(i,1:2),2) sort(reciprocal(i,3:4),2)];
        end
        %reciprocal(i,sz(2)+1) = mean([mean(data(i,1:2)) mean(data(i,3:4))]);
        %data(i,sz(2)+2) = abs((max(data(i,1:2))-min(data(i,3:4))))+abs(data(i,1)-data(i,2));
    end
    
    for R = 1:length(reciprocal)
    Xr(R) = mean([mean(reciprocal(R,1:2)) mean(reciprocal(R,3:4))]);
    Zr(R) = abs((max(reciprocal(R,1:2))-min(reciprocal(R,3:4))))+abs(reciprocal(R,1)-reciprocal(R,2));
    end
    
RECIPS = [reciprocal Xr' Zr']; %reciprocal electrode locations, Rf, Rr, absolute deviation, add on pseudolocations for plotting
RECIPS = [RECIPS RECIPS(:,7)./mean(RECIPS(:,5:6),2)]; % add on a column of percent reciprocal error in decimal units

%% remove any U% above XX% reciprocal error
cnt = 1;
for i = 1:length(RECIPS)
    if RECIPS(i,10) < errRecip % reciprocal error
        DAT(cnt,:) = [RECIPS(i,1:4) mean(RECIPS(i,5:6)) RECIPS(i,10)];% loop through and keep all columsn in each row belo threshold
        cnt = cnt+1;
    end
end
data = DAT;

%% assemble r2 protocol.dat
out = zeros(1,5);
radUnc = zeros(1,2);
%for i = 1:length(data)
out = [out; data(:,1:5)];
%end
nums = 1:length(out)-1;
out = [nums' out(2:end,:)];
dataNumber=max(nums);
protocolData = [out];
newfile = [pwd '/protocol.dat'];
dlmwrite(newfile,dataNumber)
dlmwrite(newfile,protocolData,'-append','delimiter','\t')
clear newfile;
fprintf('protocol.dat written\n')

end

