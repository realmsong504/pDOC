function [R2, R2_adj] = msong_plotR2(x1, x2, figure_title, model_degree, x_label, y_label)
% P1:  measure values
% P2:  predict values
% figure_title : string
% model_degree: the number of regression coefficients (including the intercept)
P1 = x1(:);
P2 = x2(:);
[r p] = corrcoef(P1, P2);
R20 = r(1,2);
R2 = msong_rsquare(P1, P2);

if(model_degree<=0)
    R2_adj = 0;
else
    n = length(P1);
    p = model_degree;
    R2_adj = 1 - (n-1)/(n-p)*(1- R2);
    if(R2_adj<0)
        R2_adj=0;
    end
end
if nargin<6
    x_label ='CRS-R T1 score';
    y_label = 'Predicted prognosis score';
end
if nargin<3
    figure_title = 'Measured value - Predicted value';
end


figure('Name', figure_title); %hold on;
hold on;

m1 = min(min(P1(:)), min(P2(:)));
m1 = floor(m1);
m2 = max(max(P1(:)), max(P2(:)));
m2 = ceil(m2);
d = m2 - m1;

plot(P1, P2, 'r*');
%plot([m1:0.1:m2], [m1:0.1:m2],'k-');
plot([0:0.1:23], [0:0.1:23],'k-');

title(figure_title);
xlabel(x_label);
ylabel(y_label);
% xlim([m1 m2]);
% ylim([m1 m2]);
xlim([0 max(23, max(x1(:)))]);
ylim([0 max(23, max(x2(:)))]);
if(R2_adj<=0)
    %text(max(P1(:))-d/3, min(P2(:)) + d/10 , sprintf('R^2 = %4.3f',  R2));
    text(max(P1(:))-d/3, min(P2(:)) + d/10 , sprintf('r=%4.3f, R^2 = %4.3f', R20, R2));
    fprintf('r=%4.3f, R^2 = %4.3f\n', R20, R2);
else
    %text(max(P1(:))-d/3, min(P2(:)) + d/10 , sprintf('R^2 = %4.3f, R^2_a_d_j = %4.3f', R2, R2_adj));
    text(max(P1(:))-d/3, min(P2(:)) + d/10 , sprintf('r = %4.3f, R^2 = %4.3f, R^2_a_d_j = %4.3f', R20, R2, R2_adj));
    fprintf('r = %4.3f, R^2 = %4.3f, R^2(adj) = %4.3f\n', R20, R2, R2_adj);
end
hold off;
%hold off;


