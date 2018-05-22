function [s]= msong_print_PLS_Model(beta, variable_name, response_name, pie_figure, explode_flag)
% beta: PLS output
% variable_name
% 

n_beta = numel(beta);
n_variable = size(variable_name, 1);
if(n_variable == 1)
    n_variable = size(variable_name, 2);
end

if(nargin<3)
    response_name = 'y';
end


if(n_beta ~= n_variable + 1)
    error('n_beta ~= n_variable +1');
end
s = sprintf('%s = %4.3f\n', response_name, beta(1));
for i = 1: n_variable
    if(beta(i+1)>0)
        s2 = '+';
    else
        s2 = '-';
    end
    s1  = sprintf('%s%4.3f * (%s)\n', s2,abs(beta(i+1)), char(variable_name{i}));
    s = sprintf('%s%s', s, s1);
end
s = s(1: end-1);

%% print wight in the model
weight_fig = figure('Name', 'Feature Weight');
set(weight_fig,'units','centimeters','position',[3 3 10 8],'color','w');  % 20,15
box on;
hold on;
a = beta(2:end);
b = barh(a);
xlim([-3,3]);

% C=[1 0 1; ...  % purple
%     0 0.5 0]; % light blue
C=[0.8 0.8 0.8; ...  % purple
    0.8 0.8 0.8]; % light blue

ch = get(b,'children');
color_array = zeros(numel(a), 3);

for i= 1: numel(a)
    if(a(numel(a)-i+1)>0)
        color_array(numel(a)-i+1,:) = C(1, :);
    else
        color_array(numel(a)-i+1,:) = C(2, :);
    end
end
my_ylim= ylim;
plot(zeros(100,1), linspace(my_ylim(1), my_ylim(2), 100), 'k-', 'linewidth', 1.5);

set(gca, 'YTick', [1:numel(a)]);
set(gca, 'XTick',[-3 -2 -1 0 1  2 3], 'FontSize',10,'fontweight','b');
%set(gca,'YTickLabel',variable_name, 'FontSize',12,'fontweight','b');%'FontName','Times',
set(ch, 'FaceVertexCData', color_array );
hold off;



% printf pie
if(nargin==4)
    if  ishandle(pie_figure)
        myHd = pie_figure;
    else
        myFig = figure('Name', 'Feature figure'); %hold on;
        set(myFig,'units','centimeters','position',[3 3 12 12],'color','w'); %30,20
        myHd = gca;
    end
else
    myFig = figure('Name', 'Feature figure'); %hold on;
    set(myFig,'units','centimeters','position',[3 3 12 12],'color','w');  % 30, 20
    myHd = gca;
end

 variable_name2 = cell(numel(variable_name),1);
for i =1: numel(variable_name)
    temp = char(variable_name{i});
    temp2 = strrep(temp, '_', '\_');
    variable_name2{i} = temp2;
end

x = abs(beta(2:end));
explode = zeros(numel(x),1);
flag_reverse = 1;

if(flag_reverse)
    variable_name3 = variable_name2;
    x3 = x;
    for i = 1: numel(variable_name)
        x(i) = x3(end -i +1 );
        variable_name2{i} = variable_name3{end-i+1};
    end
    explode(1) = -1;
    explode(2) = -1;
    explode(3) = -1;
    explode(4) = -1;
else
    explode(end) = 1;
    explode(end-1) = 1;
    explode(end-2) = 1;
    explode(end-3) = 1;
end

if(nargin<5)
    explode_flag =1;
end
if(explode_flag>0)
    h = msong_pie(x,explode);  hold on;
    colormap jet
    %legend(h(1:2:end) , variable_name2,'location','SouthEastOutside');
    hold off;
else
    h = msong_pie(x);  hold on;
    colormap jet
    %legend(h(1:2:end) , variable_name2,'location','SouthEastOutside');
    hold off;
end





%P=findobj(h,'type','patch');


% hText = findobj(h,'Type','text');
% offset = 0.9;
% textPositions_cell = get(hText,{'Position'}); % cell array
% textPositions = cell2mat(textPositions_cell); % numeric array
% textPositions = textPositions* offset; % add offset
% 
% for i  = 1: numel(variable_name)
%    set(hText(i), 'Position',  textPositions(i,:));
% end


