clear all% clear all varaibles
close all % close all opened figures and windows
clc % clear the command window

% ---- Step 1: read the image in ----
img=imread('parrot.jpg'); % parrot: 1024*768=786432 pixels
M=reshape(img, 3, []); % convert img to 3*L matrix
M=double(matrix);
[rows, cols]=size(M);
fprintf("M size: ["+rows+", "+cols+"]\n");

% ---- Step 2: apply PCA operation to the M ----
d=mean(M, 2);
centered_M=matrix-d;
[U, S, V]=svd(centered_M, 'econ');
C=U(:, 1:2);
Y=transpose(C)*centered_M;
