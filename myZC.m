function [myZC, myZCx, myZCy, ys] = myZC(x,y)


ys = sign(y);
ysd = diff(ys);
myZC = find(ysd~=0);


% Error management
if length(myZC)==0
    myZC  = nan;
    myZCx = nan;
    myZCy = nan;
    ys    = nan;
    return
end


% refine x-position
for zc = 1:length(myZC)
    clear xos yos zcid id
    
    % over-sampling x,y between two consecutive sample including a zero-cross
    xos = linspace( x(myZC(zc)), x(myZC(zc)+1), 1000 ); % linspace(X1, X2) generates a row vector of 100 linearly equally spaced points between X1 and X2
    yos = linspace( y(myZC(zc)), y(myZC(zc)+1), 1000 );
    
    zcid = find(yos>=-0.015 & yos<=0.015);
        
    % use the closest point to zero
    [~, id] = min(abs( yos(zcid) ));
    
    myZCx(zc) = xos(zcid(id));
    myZCy(zc) = yos(zcid(id));
    
end


end


