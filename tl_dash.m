clear; close all; fclose('all');
sep = 1; %enter electrode seperation here manually
inDat1a = '/raw_data/CP_RECIP20190222_1452.Data';
dataRange = [4:10];
%% import and setup
if exist(fullfile(cd,'start.dat'),'file') < 2
    disp('preprocessing the initial dataset')
    preprocMPT([pwd inDat1a], 1.0, 0.1 ) %imports, removes bad data based on reciprocals, removes NANS, removes negative values, writes Protocol
    
    % INVERT THE BACKGROUND DATASET
    copyfile([pwd '\R2files\nrmlR2.in'],[pwd '\R2.in']);
    disp('inverting the background data')
    system('R2.exe')
    clear DATA DAT data d D abmn R
    copyfile([pwd '\f001_res.dat'],[pwd '\start.dat']);
end
%%
% r=importipresult('f001_res.dat');
% h = ert_tri(r(:,4),[2 4],[0 28 265 278],-1.25);
% xlim([0 60])
% ylim([-4 15])
%
% title([ '[log(Ohm m)]']);
% set(gcf,'position',[680 678 560 210])
% outname = ['initial.png'];
% %patch([-.1 20 -.1],[11 -1.1 -1.1],'w','edgecolor','none')
% print(outname,'-dpng','-r600')
% close all
%%
%copyfile([pwd '\f001_res.dat'],[pwd '\start.dat']);
%delete([pwd '/f001_res.dat'])
%copyfile([pwd '\f001_res.dat'],[drct '\' nm{kk} '_res.dat'])
%copyfile([pwd '\f001_sen.dat'],[drct '\' nm{kk} '_sen.dat'])

%% Invert the time lapse next
copyfile([pwd '/start.dat'],[pwd '/previous.dat']); %duplicate the file with different name to allow for timestwp-wise differencing
direc = dir('raw_data');
for k = dataRange %set "Data range" above to avoid non-name values in folder
    inDat2 = direc(k).name;
    disp(['now processing dataset' num2str(k-2)])
    preprocMPT([pwd '/raw_data/' inDat2], 1.0, 0.1)

    % INVERT
    %copyfile([pwd '\R2files\tlR2.in'],[pwd '\R2.in']); % switch on for
    %differencing
    copyfile([pwd '\R2files\altR2.in'],[pwd '\R2.in']);
    
    disp(['now processing dataset' num2str(k-2)])
    system('R2.exe')
    
    % PLOT DIFFERENCE
    r2=importipresult('f001_res.dat');
    r1=importipresult('start.dat');
    r3=importipresult('previous.dat');
    
    % VWC DIFFERENCING - [OFF UNTIL MODEL PARAMS DEFINED]
    %m = -.53;
    %B = 3.89; %from Carey et al 2017
    %wc1 = B.*(r1(:,3)).^m;
    %wc2 = B.*(r2(:,3)).^m;
    %wc3= B.*(r3(:,3)).^m;
    %dW = ((wc1-wc2)./mean([wc1 wc2],2)).*100;
    %dW_prev = ((wc3-wc2)./mean([wc3 wc2],2)).*100;
    disp(['...getting ready to plot 2 figs for datset #' num2str(k-2)])
    
    % FIRST FIGURE - DIFFERENCE SINCE START
    h = ert_tri_TL((r2(:,3)-r1(:,3))./r2(:,3).*100,[-100 100],[0 96 -10 1],-3);
    xlim([0 96])
    ylim([-10 1])
    title([ inDat2(9:16) ' % difference since 20190222']);
    set(gcf,'position',[680 678 560 210])
    outname = 'pct_difference.png';
    print(outname,'-dpng','-r600')
    close all
    
    % SECOND FIGURE - DIFFERENCE SINCE PREVIOUS TIMESTEP
    h = ert_tri_TL((r2(:,3)-r3(:,3))./r2(:,3).*100,[-100 100],[0 96 -10 1],-3);
    xlim([0 96])
    ylim([-10 1])
    title([ inDat2(9:16) ' % difference since prevoius timestep']);
    set(gcf,'position',[680 678 560 210])
    outname = 'pct_difference_ts.png';
    print(outname,'-dpng','-r600')
    close all
    
    % THIRD FIGURE - RHO
    r=importipresult('f001_res.dat');
    h = ert_tri(r(:,4),[1 3],[0 96 -10 1],-3);
    xlim([0 96])
    ylim([-11 1])
    title([ '[log(Ohm m)]']);
    set(gcf,'position',[680 678 560 210])
    outname = ['end.png'];
    print(outname,'-dpng','-r600')
    close all
    
    
    % MOVE SOME FILES AROUND
    if exist(fullfile(cd,'f001_res.dat'),'file') == 2
        disp('moving some files around....')
        mkdir([pwd '/results/' inDat2])
        copyfile([pwd '/f001_res.dat'],[pwd '/results/' inDat2 '/f001_res.dat']);
        copyfile([pwd '/f001_res.dat'],[pwd '/previous.dat']);
        copyfile([pwd '/f001_sen.dat'],[pwd '/results/' inDat2 '/f001_sen.dat']);
        copyfile([pwd '/protocol.dat'],[pwd '/results/' inDat2 '/protocol.dat']);
        %copyfile([pwd '/f001_diffres.dat'],[pwd '/results/' inDat2 '/f001_diffres.dat']);
        copyfile([pwd '/R2.out'],[pwd '/results/' inDat2 '/R2.out']);
        copyfile([pwd '/pct_difference.png'],[pwd '/figures/pd' inDat2(9:16) '.png']);          % CHECK THIS LINE - if set the inDat2 so that the range of the datafile with the date is used
        copyfile([pwd '/pct_difference_ts.png'],[pwd '/figures/pd_ts_' inDat2(9:16) '.png']);   % CHECK THIS LINE - if set the inDat2 so that the range of the datafile with the date is used
        copyfile([pwd '/end.png'],[pwd '/figures/' inDat2(9:16) '.png']);                       % CHECK THIS LINE - if set the inDat2 so that the range of the datafile with the date is used
        delete([pwd '/f001_res.dat'])
    end
    %delete([pwd '/f001_res.dat'])
end
