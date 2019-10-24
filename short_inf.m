clear all
dirNm = [pwd '/results'];
d = dir(dirNm);

for i = 4:length(d)
    f = load([dirNm '/' d(i,:).name '/f001_res.dat']);
    
    cnt = 1;
    for j = 1:length(f)
        if f(j,1)>44 && f(j,1)<46
            out(cnt,:) = f(j,:);
            cnt = cnt+1;
        end
    end
    next = flipud(sortrows(out,2));
    
    K = 1:4:64;
    KK = K-1;
    for k = 1:length(K)-1;
    OutD(k,i) = [mean(next(K(k):KK(k+1),2))];
    OutR(k,i) = [mean(next(K(k):KK(k+1),3))];
    end
    
end
%%
close all
imagesc(1:length(d),OutD(:,5),(OutR(:,5:end)))
colorbar
colormap hot
set(gca,'ydir','normal')