function done = interpElx(x,z,inc,int,numelx)
% interpElx: takes electrode posistion in x-z space at smaller or larger 
% spacing and interpolates to make them at the desired electrode
% spacing.  input must be in x-z space, NOT along-the-line-distance space.
% The inputs do NOT need to be evenly spaced in the x-direction.
% Appropriate for LiDAR extracted positions or sparse GPS measurements
%
% x = map-view distance along the line
% z = elevation
% inc = interpolation incrament, leave at 0.001 unless v. long or shrt line
% int = electrode spacing interval
% numelex = number of total electrodes
%
% A Parsekian 11/2019
% ===================================================================

cnt = 1;
outx = 0; outz = 0;
for i = 2:length(x) % first loop through to interpolate each point
    B = polyfit([x(i) x(i-1)],[z(i) z(i-1)],1);
    X = x(i-1):inc:x(i);
    Z = B(1).*X+B(2);
    outx = [outx X(1:end-1)]; %add to the end of the existing vctr
    outz = [outz Z(1:end-1)];
end

dist = outx(2:end); %just removes the zeroes added to initate the vectrs
elev = outz(2:end);

% next, loop to follow along the line and incramentally find the next
% x-location that satisfies the known allong-the-line-distance "int"
stInd = 1;
for i = 1:numelx-1
    Dist = dist(stInd:end); %each loop incraments the starting indx to move along the line
    Elev = elev(stInd:end);
    for j = 1:length(Dist)-1 %calculate the allong-line-dist for each interpolated point
        a2 = (Dist(j)-Dist(1))^2;
        b2 = (Elev(j)-Elev(1))^2;
        c2(j) = sqrt(a2+b2); %hypot dist starting point to each point
    end
    loc = abs(c2-int);
    nwIndH = find(loc == min(loc)); %find the dist along line that matches the defined elx interval
    nwInd  = nwIndH(1); % just in case there are two minima
    done(i,:) = [Dist(nwInd) Elev(nwInd)]; %add correct value to output list
    stInd = stInd+nwInd; %advance the starting index
end

done = [0 z(1); done]; % the zero point had been skipped, so add that back in

subplot(1,2,1)
plot(done(:,1),done(:,2),'+r'); hold on
plot(x,z,'ok')

for i = 1:length(done)-1  % just check the interpolation
    A2 = (done(i,1)-done(i+1,1))^2;
    B2 = (done(i,2)-done(i+1,2))^2;
    C2(i) = sqrt(A2+B2);
end
subplot(1,2,2)
hist(C2) %due to irregular sampling, there will be small variations in allong-line-dist, but these will be less than the width of an electrode.