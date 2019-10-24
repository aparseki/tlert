function [ p ] = err_mod( D, nbins )
%calculate error function based on stacking errors in sting file


d = [D(:,5) D(:,6)./10];

res = abs(d(:,1));
err = abs(res.*d(:,2));

%plot(res,err,'ok')

bins = (logspace(log10(min(res)),log10(max(res)),nbins));

R = sortrows([res err],1);
for i = 1:length(bins)
    [~,Rind(i)] = min(abs(R(:,1)-bins(i)));
end

for i = 1:length(Rind)-1
    RR(i,:) = mean(R(Rind(i):Rind(i+1),:),1);
end

P = polyfit(RR(:,1),RR(:,2),1);

p = (round(P.*1000))./1000;
%p = fliplr(p);\

%% plot and save
% plot(RR(:,1),RR(:,2),'ok'); hold on
% x = 1:1:150;
% plot(x,p(1).*x+p(2));
% xlabel('R')
% ylabel('err')
% outname = ['err_' num2str(p(1)) '_mod.png'];
% print(outname,'-dpng','-r300')
% close all

end

