function [p] = msong_PLS_PermutationTest(feature, response, yfit, n)
% feature:
% response:
% n:
ncomp2= 3;  % number of PLS components
X = feature;
y = response;


% [XL,yl,XS,YS,beta,PCTVAR] = plsregress(X,y,ncomp2 );
% yfit = [ones(size(X,1),1) X]*beta;
R2 = msong_rsquare(response, yfit);

R2_i = zeros(n,1);
for i=1:n
    
    RandIndex = randperm(length(response));
    test_y = response(RandIndex,:);
    
    [XL,yl,XS,YS,beta2,PCTVAR] = plsregress(X,test_y,ncomp2);
    yfit_i = [ones(size(X,1),1) X]*beta2;
    
    % P1:  measure values
    % P2:  predict values
    R2_i(i) = msong_rsquare(response, yfit_i);
   
end
p = (sum(R2_i>=R2)+1)./(n+1);

L = R2_i;
Lmin=min(L);
Lmax=max(L);
%histfit(L,100,'exponential');
% hist(L, 100);
% xlabel('R2');
% ylabel('count');
% title('Permutation Test');
% hold on
% %plot(label,'r')
% plot(R2,0,'b');
% hold off;