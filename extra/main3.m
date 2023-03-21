clear all% clear all varaibles
close all % close all opened figures and windows
clc % clear the command window

% ---- Step 1: read the image in ----
[file, path]=uigetfile('*.*');
filename=fullfile(path, file);
img=imread(filename); % read the image file
[height, width, RGB]=size(img); % record the size of img

% convert img matrix into 3*L size with double value
% since the img=height*width*3, in order to reshape the image to 3*L
% first, reshape based on RGB, then do the transpose will flip the matrix
% to 3*L form
X=imnoise(img, 'salt & pepper', 0.1);
X=double(reshape(X, height, []));
d=mean(X, 2);
centered_X=X-d;

components_count=50;
orth_vec=orth(centered_X);
C=orth_vec(:, 1:components_count); % choose the top two column as basis
Y=transpose(C)*centered_X;

% ---- Step 4: reconstruct data via C, Y and d ----
X_reconstruct=(C*Y)+(d*ones(1, width*3));

% X plot
figure;
% before plot the image, we need to reshape back to 
% original image size, so first transpose back to L*3, then
% reshape it back to height*width*3
X=reshape(X, height, width, 3);
image(uint8(X)); % convert data back to 8-bit unsigned integer 
title("Original X with noise");
xlabel("Width");
ylabel("Height");

% X_reconstruct plot
figure;
X_reconstruct=reshape(X_reconstruct, height, width, []);
image(uint8(reshape(X_reconstruct, height, width, RGB)));
title("After PCA");
xlabel("Width");
ylabel("Height");


