clc
close all
warning off

% first, read the image (must under same driectory)
[file, path]=uigetfile('*.*');
filename=fullfile(path, file);
image=imread(filename);
subplot(1,3,1); % output the original image with subplot function
imshow(image);
title('Original');

% using matlab built-in superpixels function
Pixels_num=500;  %break image into Pixels_num parts
[L, Label_num]=superpixels(image, Pixels_num, NumIterations=10);
% BI is Boundary-Image
BI=boundarymask(L); % use boundarymask() to output the superpixels 
subplot(1,3,2);
imshow(imoverlay(image, BI, 'red'), 'InitialMagnification', 67);
title('Boundary mask');


result=zeros(size(image), 'like', image);
idx=label2idx(L);
rows=size(image, 1);
cols=size(image, 2);
for label=1:Label_num
    red_idx=idx{label};
    green_idx=idx{label}+rows*cols;
    blue_idx=idx{label}+2*rows*cols;
    result(red_idx)=mean(image(red_idx));
    result(green_idx)=mean(image(green_idx));
    result(blue_idx)=mean(image(blue_idx));
end

subplot(1,3,3);
imshow(result);
title('SLIC');
