function cval = ert_tri(rho_truelog,CMinMax,XYMinMax,SenLev)

%rho_truelog: vector of values to plot
%CMinMax: [color axis min; color axis max] in space you want to use log/lin

cmin = CMinMax(1); %Color axis minimum in ohm-m (code converts this to a log10 value)
cmax = CMinMax(2); %Color axis maximum in ohm-m (code converts this to a log10 value)
xmin = XYMinMax(1); %Minimum x-location
xmax = XYMinMax(2); %Maximum x-location
ymin = XYMinMax(3); %Minimum z-location
ymax = XYMinMax(4); %Maximum z-location

%mesh = load('mesh.mat'); %new mesh
%sens = load('newmesh_sen.mat'); %already comes up as variable A
LLmesh = importmesh('mesh.dat');
S = importipresult('f001_sen.dat');
A = S(:,4);
%clear mesh sens

mshl = LLmesh(1,1);
elementArray = LLmesh(2:mshl+1,1:6) ;
nodalArray = LLmesh(mshl+2:end,1:3) ;

cmap = jet(64); %cmap = flipud(cmap);
colorVal = linspace((cmin),(cmax),64);

h = figure;
cnt = 1;
for i = 1:size(elementArray)
    line1 = elementArray(i,2);
    line2 = elementArray(i,3);
    line3 = elementArray(i,4);
    
    [index1,value1] = find(nodalArray(:,1)==line1); %index1 = x value of 1st vertex
    [index2,value2] = find(nodalArray(:,1)==line2);
    [index3,value3] = find(nodalArray(:,1)==line3);
    [valueC,indexC] = min(((colorVal-rho_truelog(i,1)).^2));
    
    plotX = [nodalArray(index1,2),nodalArray(index2,2),nodalArray(index3,2),nodalArray(index1,2)];
    plotY = [nodalArray(index1,3),nodalArray(index2,3),nodalArray(index3,3),nodalArray(index1,3)];
    plotC = cmap(indexC,:);
    
    if A(i,1) < SenLev % 
       patch(plotX,plotY,[1 1 1],'edgecolor', 'none')
    else
        patch(plotX,plotY,plotC,'edgecolor','none');
        export(cnt,:) = [S(i,1:2) rho_truelog(i,1)];
        cnt = cnt+1;
    end
end

axis([xmin xmax ymin ymax])

hold on


%% add a countour line
XX=min(export(:,1)):.1:max(export(:,1));
YY=min(export(:,2)):.1:max(export(:,2));
D = griddata(export(:,1),export(:,2),export(:,3),XX,YY');
cval = contour(XX,YY,D,[.1],'-w','linewidth',.25);


%% finish
xlabel('distance [meters]')
ylabel('elev. [meters]')
caxis ([cmin cmax])
colormap jet
colorbar('eastoutside');
grid off
axis equal
save('result.txt','export','-ASCII')
end
