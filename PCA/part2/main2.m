clear all% clear all varaibles
close all % close all opened figures and windows
clc % clear the command window

% ---- Step 1: read the image in ----
img=imread('parrot.jpg'); % parrot: 1024*768=786432 pixels
img_matrix=reshape(img, 3, []); % convert img to 3*L matrix
[rows, cols]=size(img_matrix);
fprintf("matrix size: ["+rows+", "+cols+"]\n");

% ---- Step 2: apply PCA operation to the matrix ----
