function done = interpElx(x,z,inc,int,numelx)
%inc = .5; % the incriment needs to be automated
cnt = 1;
for i = 2:length(x)
    B = polyfit([x(i) x(i-1)],[z(i) z(i-1)],1);
    X = x(i-1):inc:x(i);
    Z = B(1).*X+B(2);
    
    outx(:,i-1) = X(1:end-1);
    outz(:,i-1) = Z(1:end-1);
end

sz = size(outx);
dist = reshape(outx,[1 sz(1)*sz(2)]);
elev = reshape(outz,[1 sz(1)*sz(2)]);

stInd = 1;
for i = 1:numelx-1
    Dist = dist(stInd:end);
    Elev = elev(stInd:end);
    for j = 1:length(Dist)-1
        
        a2 = (Dist(j)-Dist(1))^2;
        b2 = (Elev(j)-Elev(1))^2;
        c2(j) = sqrt(a2+b2); %hypot dist starting point to each point
    end
    loc = abs(c2-int);
    nwInd = find(loc == min(loc));
    done(i,:) = [Dist(nwInd) Elev(nwInd)];
    stInd = stInd+nwInd;
end

done = [0 z(1); done]
%dist = (dist(1:int:end)); % the interval needs to be automated
%elev = (elev(1:int:end));

%done = [dist' elev'];










