function msong_radarplot(X,colors,feature_name, axisMax, subject_label, subject_name)
% creates a radar (spider) plot for multiple data series.
%INPUT:
%   X: numeric vector MxN  (N is number of features, M is number of samples)
%   feature_name: cell of string vector 1xN
%   colors: char array, one of the matlab colors
%   axisMax: range of feature
%   subject_label: 
%         1 for normal controls,
%         -1 for MCS, 
%         -2 for VS, 
%         0 for new sample
% msong@nlpr.ia.ac.cn

M = size(X,1);
N = size(X,2);
if(nargin<5)
    subject_label = ones( M, 1);
end
if(nargin<4)
    max_X = max(X,[], 1);
else
    max_X =  axisMax;
end

if(length(colors)<M)
    colors = repmat(colors(1), M, 1);
end
if(numel(feature_name)<N)
    feature_name = repmat(' ', N, 1);
end

% create the axis (CordXG CordYG) and to plot the feature_names (CordYL)
Angle1=repmat(2*pi/size(max_X,2),size(max_X,2),1);
Angle=cumsum([ 0 ; 0 ;  Angle1]);
CordXG=zeros(1,(size(max_X,2))*2);
CordYG=zeros(1,(size(max_X,2))*2);
CordXL=zeros(1,(size(max_X,2)));
CordYL=zeros(1,(size(max_X,2)));
for i=1:size(max_X,2)
    
    [CordXG(i*2-1) CordYG(i*2-1)]=pol2cart(Angle1(1)*(i-1),0);
    [CordXG(i*2) CordYG(i*2)]=pol2cart(Angle1(1)*(i-1),max(max_X));
    [CordXL(i) CordYL(i)]=pol2cart(Angle1(1)*(i-1)*1,max(max_X)*1.1);
end
% plot radar axis
plot(CordXG,CordYG,'k')
hold on
axis square;  % msong
set(gcf,'color','w'); %msong
axis([-max(max_X)*1.1 max(max_X)*1.1 -max(max_X)*1.1 max(max_X)*1.1])
axis off

%plot text feature_names nearby the rader axis
for i=1:size(CordXL,2)
    text(CordXL(i), CordYL(i),cell2mat(feature_name(i)), 'FontSize',12,'HorizontalAlignment','center','Rotation',0)
end

% plot grid circle and value feature_names
Angle2=Angle(2:end);
for i=1:5
    Rad=repmat((max(max_X)/5)*i,size(Angle2));
    [CordXS CordYS]=pol2cart(Angle2,Rad);
    plot(CordXS, CordYS,':k')
    text((max(max_X)/5/3),(max(max_X)/5)*i,num2str((max(max_X)/5)*i,2),'FontSize',8)
end

% create 2 vectors angel (Angle) and raius (X) and convert from Polaric to Cartesian
[t_label ] = unique(subject_label);
n_label = numel(t_label);
switch n_label
    case 1
        for i = 1:M
            X_i= X(i,:);
            X_i2 = [X_i(1,1) X_i X_i(1,1)];  % msong
            [CordX,CordY] = pol2cart(Angle,X_i2');
            plot(CordX,CordY,colors(i),'LineWidth',2)
        end
    case 2
        
        if( min(t_label(:))>0)
            index_1 = find(subject_label==t_label(1));
            for i = 1:length(index_1)
                s_index = index_1(i);
                X_i= X(s_index,:);
                X_i2 = [X_i(1,1) X_i X_i(1,1)];  % msong
                [CordX,CordY] = pol2cart(Angle,X_i2');
                h1 = plot(CordX,CordY,colors(s_index),'LineWidth',2);
            end
            index_2 = find(subject_label==t_label(2));  % MCS or DOC
            for i = 1:length(index_2)
                s_index = index_2(i);
                X_i= X(s_index,:);
                X_i2 = [X_i(1,1) X_i X_i(1,1)];  % msong
                [CordX,CordY] = pol2cart(Angle,X_i2');
                h2 = plot(CordX,CordY,colors(s_index),'LineWidth',3);
            end
            if(max(t_label(:))>2 && min(t_label(:))>0)
                legend([h1, h2], 'VS patients', 'Normal controls');
            else
                legend([h1, h2], 'MCS patients', 'Normal controls');
            end
            
        else
            % unknown subject, you can use subject_name
            index_1 = find(subject_label==t_label(2));
            for i = 1:length(index_1)
                s_index = index_1(i);
                X_i= X(s_index,:);
                X_i2 = [X_i(1,1) X_i X_i(1,1)];  % msong
                [CordX,CordY] = pol2cart(Angle,X_i2');
                h1 = plot(CordX,CordY,colors(s_index),'LineWidth',2);
            end
            index_2 = find(subject_label==t_label(1));  % MCS or DOC
            for i = 1:length(index_2)
                s_index = index_2(i);
                X_i= X(s_index,:);
                X_i2 = [X_i(1,1) X_i X_i(1,1)];  % msong
                [CordX,CordY] = pol2cart(Angle,X_i2');
                h2 = plot(CordX,CordY,colors(s_index),'LineWidth',3);
            end
            [v d] = version;
            version_flag = str2double(v(end-5:end-2));
            if(version_flag>2016)
                legend([h1, h2], 'Normal controls', subject_name, 'Location','SouthEastOutside', 'Interpreter', 'none');
            else
                legend([h1, h2], 'Location','SouthEastOutside', 'Normal controls', subject_name, 'Interpreter', 'none');
            end
        end
        
    case 3
        index_1 = find(subject_label==t_label(1));
        for i = 1:length(index_1)  % DOC
            s_index = index_1(i);
            X_i= X(s_index,:);
            X_i2 = [X_i(1,1) X_i X_i(1,1)];  % msong
            [CordX,CordY] = pol2cart(Angle,X_i2');
            h1 = plot(CordX,CordY,colors(s_index),'LineWidth',2);
        end
        index_2 = find(subject_label==t_label(2));  % MCS
        for i = 1:length(index_2)
            s_index = index_2(i);
            X_i= X(s_index,:);
            X_i2 = [X_i(1,1) X_i X_i(1,1)];  % msong
            [CordX,CordY] = pol2cart(Angle,X_i2');
            h2 = plot(CordX,CordY,colors(s_index),'LineWidth',3);
        end
        index_3 = find(subject_label==t_label(3));  % NC
        for i = 1:length(index_3)
            s_index = index_3(i);
            X_i= X(s_index,:);
            X_i2 = [X_i(1,1) X_i X_i(1,1)];  % msong
            [CordX,CordY] = pol2cart(Angle,X_i2');
            h3 = plot(CordX,CordY,colors(s_index),'LineWidth',3);
        end
        legend([h1, h2, h3], 'VS patients', 'MCS patients', 'Normal controls');
    case 4
        index_1 = find(subject_label==t_label(1));  % DOC
        for i = 1:length(index_1)
            s_index = index_1(i);
            X_i= X(s_index,:);
            X_i2 = [X_i(1,1) X_i X_i(1,1)];  % msong
            [CordX,CordY] = pol2cart(Angle,X_i2');
            h1 = plot(CordX,CordY,colors(s_index),'LineWidth',2);
        end
        index_2 = find(subject_label==t_label(2));  % MCS
        for i = 1:length(index_2)
            s_index = index_2(i);
            X_i= X(s_index,:);
            X_i2 = [X_i(1,1) X_i X_i(1,1)];  % msong
            [CordX,CordY] = pol2cart(Angle,X_i2');
            h2 = plot(CordX,CordY,colors(s_index),'LineWidth',2);
        end
        index_4 = find(subject_label==t_label(4));  % NC
        for i = 1:length(index_4)
            s_index = index_4(i);
            X_i= X(s_index,:);
            X_i2 = [X_i(1,1) X_i X_i(1,1)];  % msong
            [CordX,CordY] = pol2cart(Angle,X_i2');
            h3 = plot(CordX,CordY,colors(s_index),'LineWidth',2);
        end
        index_3 = find(subject_label==t_label(3));  % new sample
        for i = 1:length(index_3)
            s_index = index_3(i);
            X_i= X(s_index,:);
            X_i2 = [X_i(1,1) X_i X_i(1,1)];  % msong
            [CordX,CordY] = pol2cart(Angle,X_i2');
            h4 = plot(CordX,CordY,colors(s_index),'LineWidth',3);
        end
     
        legend([h1, h2, h3, h4], 'VS patients', 'MCS patients', 'Normal controls', subject_name, 'Interpreter', 'none');

end


hold off;

