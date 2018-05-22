function R = msong_z2r(M)
% convert fisher' Z value to correlation r
%   M 
%[m n ] = size(M);
M2 = M(:);
 R2 = (exp(2*M2) - 1)./(exp(2*M2) +1);
 R = reshape(R2, size(M));