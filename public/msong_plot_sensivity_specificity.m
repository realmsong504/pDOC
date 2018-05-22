function [ACC] = msong_plot_sensivity_specificity(label, P2, cut_point)
% label:  two class, bigger label for the postive sample, smaller label
% for negative sample
% P2: possibility for postive sample

% ACC: (1)the accuracy on the cut_point, (2) sensitivity, (3) specificity,
% (4) positive predictive value (PPV), (5) negative predictive value (NPV)
% ouput_cut_point: cut_point

if(nargin~=3)
     error('input error.');
end

mem_label = unique(label);
n_sample = numel(label);

if(numel(mem_label)~=2)
    error('label = %d', numel(mem_label));
end

if(size(label,1)~=1)
    label = label';
end
if(size(P2, 1)~=1)
    P2 = P2';
end

label(find(label==max(mem_label))) = 1;
n_positive = numel(find(label==1));
label(find(label==min(mem_label))) = 0;  % -1
n_negative = numel(find(label==0));  % -1
n_test = numel(P2);
%  ACC, Sensitivity,  specificity

i_cutpoint = cut_point;%cut_point2;
i_classify_rst = P2>=i_cutpoint;
i_correction = i_classify_rst==label;
ACC(1) = length(find(i_correction==1))/n_test;

label_predict_positive = P2>=i_cutpoint;
label_predict_negative = P2<i_cutpoint;

true_positive  = label_predict_positive.* label;
n_true_positive = sum(true_positive(:));
false_negative  = label_predict_negative.* label;
n_false_negative = sum(false_negative(:));
Sensitivity = n_true_positive./(n_true_positive+n_false_negative);

false_positive  = label_predict_positive.* (1-label);
n_false_positive = sum(false_positive(:));
true_negative  = label_predict_negative.* (1-label);
n_true_negative = sum(true_negative(:));
Specificity = n_true_negative./(n_false_positive+n_true_negative);

ACC(2) = Sensitivity;
ACC(3) = Specificity ;

PPV = n_true_positive./sum(label_predict_positive(:));
NPV = n_true_negative./sum(label_predict_negative(:));

ACC(4) = PPV;
ACC(5) = NPV;

precision = PPV;
recall = Sensitivity;
F1_score = 2*(precision*recall/(precision+recall));
ACC(6) = F1_score;

