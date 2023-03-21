clear all% clear all varaibles
close all % close all opened figures and windows
clc % clear the command window

% ---- Step 1: read the image in ----
img=imread('parrot.jpg'); % read the image file
[height, width, RGB]=size(img); % record the size of img
% convert img matrix into 3*L size with double value
% since the img=height*width*3, in order to reshape the image to 3*L
% first, reshape based on RGB, then do the transpose will flip the matrix
% to 3*L form
X=transpose(double(reshape(img, [], 3))); 

% ---- Step 2: remove mean value from each column ----
d=mean(X, 2);
centered_X=X-d;

% ---- Step 3: apply PCA to centered_X ----
orth_vec=orth(centered_X);
C=orth_vec(:, 1:2); % choose the top two column as basis
Y=transpose(C)*centered_X;

% ---- Step 4: reconstruct data via C, Y and d ----
X_reconstruct=(C*Y)+(d*ones(1, height*width));

% ---- Step 5: print out the desired plot ----
% X plot
figure;
% before plot the image, we need to reshape back to 
% original image size, so first transpose back to L*3, then
% reshape it back to height*width*3
X=reshape(transpose(X), height, width, 3);
image(uint8(X)); % convert data back to 8-bit unsigned integer 
title("RGB true-color composition of X");
xlabel("Width");
ylabel("Height");

% Y plot
% reshape to original image size
figure;
band1=reshape(Y(1, :), [height, width]);
band2=reshape(Y(2, :), [height, width]);
% convert to gray-scale
band1=mat2gray(band1); 
band2=mat2gray(band2);
subplot(1,2,1);
imshow(band1);
title("First Band Image");
subplot(1,2,2);
imshow(band2);
title("Second Band Image");


% X_reconstruct plot
figure;
X_reconstruct=reshape(transpose(X_reconstruct), height, width, []);
image(uint8(reshape(X_reconstruct, height, width, RGB)));
title("RGB true-color composition of X-reconstruct");
xlabel("Width");
ylabel("Height");
