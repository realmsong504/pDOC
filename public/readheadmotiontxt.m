function [Y] = readheadmotiontxt(filename)
% read the head motion txt file titled by filename
% Y is the matrix of the parameters of head motion
% the 1st, 2nd and 3rd columns are the translation parameters in x, y and
% z direction (in mm), respectively;
% the 4th, 5th and 6th columns are the rotate parameters around 3
% directions, respectively.

fid=fopen(filename,'rt');
if fid==-1
    err=strcat('can not open ',filename);
    error(err);
end
Y=fscanf(fid,'%f');
status = fclose(fid);
if status==-1
    err=strcat('can not close ',filename);
    error(err);
end
numcol=6;
numrow=length(Y)/numcol;
B=reshape(Y,[numcol,numrow]);
Y=B';
% Y(:,4:6) = Y(:,4:6)*(180/pi);


    