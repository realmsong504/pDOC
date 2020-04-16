function result = msong_logistic(predicted_score, beta, alpha)
%%  logistic function

%result = 1 / (1 + exp(beta .* predicted_score + alpha));

n = numel(beta);
result = zeros(n,1);

for i=1:n
    result(i) = 1 / (1 + exp(beta(i) .* predicted_score + alpha(i)));
end
