function [myZC, myZCx, myZCy, ys] = myZC(x,y)



ys = sign(y);
ysd = diff(ys);
myZC = find(ysd~=0);

% refine x-position
for zc = 1:length(myZC)
    clear xos yos zcid
    
    % over-sampling x,y between two consecutive sample including a zero-cross
    xos = linspace( x(myZC(zc)), x(myZC(zc)+1), 1000 ); % linspace(X1, X2) generates a row vector of 100 linearly equally spaced points between X1 and X2
    yos = linspace( y(myZC(zc)), y(myZC(zc)+1), 1000 );
    
    zcid = find(yos>=-0.01 & yos<=0.01);
    
    myZCx(zc) = xos(zcid(1));
    myZCy(zc) = yos(zcid(1));
    
end


end


