clear all% clear all varaibles
close all % close all opened figures and windows
clc % clear the command window

% ---- Step 1: read the image in ----
img=imread('parrot.jpg'); % read the image file
[height, width, RGB]=size(img); % record the size of img
X=double(reshape(img, 3, [])); % convert img matrix into 3*L size with double value

% ---- Step 2: remove mean value from each column ----
d=mean(X, 2);
centered_X=X-d;

% ---- Step 3: apply PCA to centered_X ----
orth_vec=orth(centered_X);
C=orth_vec(:, 1:2); % choose the top two column as basis
Y=transpose(C)*centered_X;

% ---- Step 4: reconstruct data via C, Y and d ----
X_reconstruct=(C*Y)+(d*ones([1, size(X, 2)]));

% ---- Step 5: print out the desired plot ----
% X plot
figure;
image(uint8(reshape(X, height, width, RGB)));
title("RGB true-color composition of X");
xlabel("Pixels");
ylabel("Value");

% Y plot
subplot(1, 2, 1);
band1=reshape(Y(1, :), height, width);
imshow(band1, []);
title("First band");
subplot(1, 2, 2);
band2=reshape(Y(2, :), height, width);
imshow(band2, []);
title("Second band");

% X_reconstruct plot
figure;
image(uint8(reshape(X_reconstruct, height, width, RGB)));
title("RGB true-color composition of X-reconstruct");
xlabel("Pixels");
ylabel("Value");
