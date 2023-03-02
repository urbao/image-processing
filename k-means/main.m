clc
clear all
close all
warning off

% read the file, and output original
image=imread('bird.jpg');
subplot(1,2,1);
imshow(image);
title('Original');

% break colors into 3 parts of matrix(RGB)
red=image(:,:,1);
green=image(:,:,2);
blue=image(:,:,3);
data=double([red(:), green(:), blue(:)]);

%start using K-means clustering
K=3;
[m, n]=kmeans(data, K); % result of kmeans will be an m*n vector
m=reshape(m, size(image, 1), size(image, 2)); % since m is M*1 matrix, we need to reshape to 2D, so we can perform image
n=n/255; % we break image pixel value between 0~1(since image is 256-color)
cluster_result=label2rgb(m, n); % label2rgb() can convert label matrix to RGB image
subplot(1,2,2);
title('After K-means');
imshow(cluster_result);
