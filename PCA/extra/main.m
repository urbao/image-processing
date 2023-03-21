clear all% clear all varaibles
close all % close all opened figures and windows
clc % clear the command window

% ---- Step 1: read the image in ----
img=imread('quokka.jpg'); % read the image file
[height, width, RGB]=size(img); % record the size of img

% first. add some random noise to image via built-in function
% then, convert the image to height*L matrix
X=imnoise(img, 'salt & pepper', 0.1);
X=double(reshape(X, height, []));
% find the mean value of column
% substract of the mean from the X matrix
d=mean(X, 2);
centered_X=X-d;

% define the pricipal component number(PC_count)
% find the top PC_count number of orthogonal basis
% finally, compress the centered_X to smaller size Y matrix
PC_count=75;
orth_vec=orth(centered_X);
C=orth_vec(:, 1:PC_count); 
Y=transpose(C)*centered_X;

% ---- Step 4: reconstruct data via C, Y and d ----
X_reconstruct=(C*Y)+(d*ones(1, width*3));

% ---- Step 5: plot the image for observation ----
% image plot
figure;
image(img);
title("Original image(768x1024x3)");
xlabel("Width");
ylabel("Height");

% X plot
figure;
X=reshape(X, height, width, 3);
image(uint8(X)); % convert data back to 8-bit unsigned integer 
title("Original image with random noise");
xlabel("Width");
ylabel("Height");

% X_reconstruct plot
figure;
X_reconstruct=reshape(X_reconstruct, height, width, []);
image(uint8(reshape(X_reconstruct, height, width, RGB)));
title("After PCA");
xlabel("Width");
ylabel("Height");
