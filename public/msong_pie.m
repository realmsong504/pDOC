function hh = msong_pie(varargin)
%PIE    Pie chart.
%   PIE(X) draws a pie plot of the data in the vector X.  The values in X
%   are normalized via X/SUM(X) to determine the area of each slice of pie.
%   If SUM(X) <= 1.0, the values in X directly specify the area of the pie
%   slices.  Only a partial pie will be drawn if SUM(X) < 1.
%
%   PIE(X,EXPLODE) is used to specify slices that should be pulled out from
%   the pie.  The vector EXPLODE must be the same size as X. The slices
%   where EXPLODE is non-zero will be pulled out.
%
%   PIE(...,LABELS) is used to label each pie slice with cell array LABELS.
%   LABELS must be the same size as X and can only contain strings.
%
%   PIE(AX,...) plots into AX instead of GCA.
%
%   H = PIE(...) returns a vector containing patch and text handles.
%
%   Example
%      pie([2 4 3 5],{'North','South','East','West'})
%
%   See also PIE3.

%   Clay M. Thompson 3-3-94
%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 1.16.4.8 $  $Date: 2005/10/28 15:54:38 $

% Parse possible Axes input
[cax,args,nargs] = axescheck(varargin{:});
error(nargchk(1,3,nargs,'struct'));

x = args{1}(:); % Make sure it is a vector
args = args(2:end);

nonpositive = (x <= 0);
if all(nonpositive)
    error('MATLAB:pie:NoPositiveData',...
        'Must have positive data in the pie chart.');
end
if any(nonpositive)
    warning('MATLAB:pie:NonPositiveData',...
        'Ignoring non-positive data in pie chart.');
    x(nonpositive) = [];
end
xsum = sum(x);
if xsum > 1+sqrt(eps), x = x/xsum; end

% Look for labels
if nargs>1 && iscell(args{end})
    txtlabels = args{end};
    if any(nonpositive)
        txtlabels(nonpositive) = [];
    end
    args(end) = [];
else
    for i=1:length(x)
        if x(i)<.01,
            txtlabels{i} = '< 1%';
        else
            txtlabels{i} = sprintf('%d%%',round(x(i)*100));
        end
    end
end

% Look for explode
if isempty(args),
    explode = zeros(size(x));
else
    explode = args{1};
    if any(nonpositive)
        explode(nonpositive) = [];
    end
end

explode = explode(:); % Make sure it is a vector

if length(txtlabels)~=0 && length(x)~=length(txtlabels),
    error(id('StringLengthMismatch'),'Cell array of strings must be the same length as X.');
end

if length(x) ~= length(explode),
    error(id('ExploreLengthMismatch'),'X and EXPLODE must be the same length.');
end

cax = newplot(cax);
next = lower(get(cax,'NextPlot'));
hold_state = ishold(cax);

theta0 = pi/2;
maxpts = 100;
inside = 0;

explode_min = min(explode);

if(explode_min==0)
    %% original pie
    h = [];
    for i=1:length(x)
        n = max(1,ceil(maxpts*x(i)));
        r = [0;ones(n+1,1);0];
        theta = theta0 + [0;x(i)*(0:n)'/n;0]*2*pi;
        if inside,
            [xtext,ytext] = pol2cart(theta0 + x(i)*pi,.5);
        else
            [xtext,ytext] = pol2cart(theta0 + x(i)*pi,1.2);
        end
        [xx,yy] = pol2cart(theta,r);
        if explode(i),
            [xexplode,yexplode] = pol2cart(theta0 + x(i)*pi,.1);
            xtext = xtext + xexplode;
            ytext = ytext + yexplode;
            xx = xx + xexplode;
            yy = yy + yexplode;
        end
        theta0 = max(theta);
        h = [h,patch('XData',xx,'YData',yy,'CData',i*ones(size(xx)), ...
            'FaceColor','Flat','parent',cax), ...
            text(xtext,ytext,txtlabels{i},...
            'HorizontalAlignment','center','parent',cax)];
    end
    
    if ~hold_state,
        view(cax,2); set(cax,'NextPlot',next);
        axis(cax,'equal','off',[-1.2 1.2 -1.2 1.2])
    end
    
    if nargout>0, hh = h; end
else
    %% msong_pie:  similar explode will combine together
    h = [];
    ex_group = unique(explode);
    n_group = numel(ex_group);
    xx_cell = [];%cell(n_group,1);
    yy_cell = [];%cell(n_group,1);
    xx_start_cell = [];
    yy_start_cell = [];
    
    index = 1;
    n_piont = zeros(n_group,1 );
    for i=1: n_group
        temp = ex_group(i);
        i_index = find(explode==temp);
        sum_x_i = sum(x(i_index));
        
        n = max(1,ceil(maxpts*sum_x_i ));
        n_point(i) = n;
        %r = [0;ones(n+1,1);0];
        %theta = theta0 + [0;sum_x_i*(0:n)'/n;0]*2*pi;
        r = [ones(n+1,1)];
        theta = theta0 + [sum_x_i*(0:n)'/n]*2*pi;
        [xx,yy] = pol2cart(theta,r);
        
      
        
        if(temp~=0)
            [xexplode,yexplode] = pol2cart(theta0 + sum_x_i*pi,.1);
            %             xtext = xtext + xexplode;
            %             ytext = ytext + yexplode;
            xx = xx + xexplode;
            yy = yy + yexplode;
            
            xx_start_cell(i) = xexplode;
            yy_start_cell(i) = yexplode;
        else
            xx_start_cell(i) = 0;
            yy_start_cell(i) = 0;
        end
        %         xx_cell{i} = xx;
        %         yy_cell{i} = yy;
        index2 = index + numel(xx) -1 ;
        
        xx_cell(index: index2) = xx;
        yy_cell(index: index2) = yy;
        theta0 = max(theta);
        index = index2+1;
    end
    
    
    theta0 = pi/2;
    maxpts = 100;
    inside = 0;


    j2 = 0;
    index_group0 = 0;
    for i=1:length(x)
        index_group = find(ex_group==explode(i));
        if(i<length(x))
            index_group2 = find(ex_group==explode(i+1));
        else
            index_group2 = index_group;
        end
        
        n = max(1,ceil(maxpts*x(i)));
        theta = theta0 + [0;x(i)*(0:n)'/n;0]*2*pi;
        if inside,
            [xtext,ytext] = pol2cart(theta0 + x(i)*pi,.5);
        else
            [xtext,ytext] = pol2cart(theta0 + x(i)*pi,1.1);
        end  

        if(index_group0~= index_group && index_group==index_group2)
            j2 = j2+1;
            if(j2+ceil(maxpts*x(i) )<=numel(xx_cell))
                xd = xx_cell(j2: j2+max(1,ceil(maxpts*x(i) ))+1 );
                yd = yy_cell(j2: j2+max(1,ceil(maxpts*x(i) ))+1 );
            else
                xd = xx_cell(j2:numel(xx_cell)) ;
                yd = yy_cell(j2: numel(xx_cell));
            end
            
            xexplode = xx_start_cell(index_group);
            yexplode = yy_start_cell(index_group);
            
            %         if inside,
            %             [xtext,ytext] = pol2cart(theta0 + sum_x_i*pi,.5);
            %         else
            %             [xtext,ytext] = pol2cart(theta0 + sum_x_i*pi,1.2);
            %         end
            %         if(temp~=0)
            %             [xexplode,yexplode] = pol2cart(theta0 + sum_x_i*pi,.1);
            %             xtext = xtext + xexplode;
            %             ytext = ytext + yexplode;
            %         end
            xx = [0+xexplode, xd, 0+xexplode];
            yy = [0+yexplode, yd, 0+yexplode];
            j2 = j2+max(1,ceil(maxpts*x(i) ))-1 ;
            
        elseif (index_group0== index_group && index_group==index_group2)
            j2 = j2+1;
            if(j2+ceil(maxpts*x(i) )<=numel(xx_cell))
                xd = xx_cell(j2: j2+max(1,ceil(maxpts*x(i) )) );
                yd = yy_cell(j2: j2+max(1,ceil(maxpts*x(i) )) );
            else
                xd = xx_cell(j2: numel(xx_cell)) ;
                yd = yy_cell(j2: numel(xx_cell));
            end
            
            xexplode = xx_start_cell(index_group);
            yexplode = yy_start_cell(index_group);
            xx = [0+xexplode, xd, 0+xexplode];
            yy = [0+yexplode, yd, 0+yexplode];
            j2 = j2+max(1,ceil(maxpts*x(i) ))-1 ;
        else
            j2 = j2+1;
            if(j2+ceil(maxpts*x(i) )<=numel(xx_cell))
                xd = xx_cell(j2: j2+max(1,ceil(maxpts*x(i) ))-1 );
                yd = yy_cell(j2: j2+max(1,ceil(maxpts*x(i) ))-1 );
            else
                xd = xx_cell(j2: numel(xx_cell)) ;
                yd = yy_cell(j2: numel(xx_cell));
            end
            
            xexplode = xx_start_cell(index_group);
            yexplode = yy_start_cell(index_group);
            xx = [0+xexplode, xd, 0+xexplode];
            yy = [0+yexplode, yd, 0+yexplode];
            j2 = j2+max(1,ceil(maxpts*x(i) ))-1 ;
            
        end

            xtext = xtext + xexplode;
            ytext = ytext + yexplode;
            
        h = [h,patch('XData',xx,'YData',yy,'CData',i*ones(size(xx)), ...
            'FaceColor','Flat','parent',cax), ...
            text(xtext,ytext,txtlabels{i},...
            'HorizontalAlignment','center','parent',cax) ];
        index_group0 = index_group;
        theta0 = max(theta);

    end
    
    if ~hold_state,
        view(cax,2); set(cax,'NextPlot',next);
        axis(cax,'equal','off',[-1.2 1.2 -1.2 1.2])
    end
    
    if nargout>0, hh = h; end
    
    
end

% Register handles with m-code generator
% if ~isempty(h)
%   mcoderegister('Handles',h,'Target',h(1),'Name','pie');
% end

function str=id(str)
str = ['MATLAB:pie:' str];
