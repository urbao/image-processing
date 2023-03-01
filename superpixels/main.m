% close & clear all current working pane
clc
close all
warning off

% let user choose their photo using `uigetfile` function
[file, path]=uigetfile('*.*');
filename=fullfile(path, file);
image=imread(filename);
subplot(1,3,1); % output the original image with subplot function (the left one)
imshow(image);
title('Original');

% using matlab built-in superpixels function
Pixels_num=7500;  %break image into Pixels_num parts
[L, Label_num]=superpixels(image, Pixels_num, NumIterations=10);

% BI is Boundary-Image, which shows the edge of different superpixels
BI=boundarymask(L); % use boundarymask() to output the superpixels 
subplot(1,3,2);
% using `imoverlay` function to diaplay image with red line edge
imshow(imoverlay(image, BI, 'red'), 'InitialMagnification', 67);
title('Boundary mask');

% convert image to an array, so matlab can compute the result
result=zeros(size(image), 'like', image);
idx=label2idx(L); % convert the `Boundary-Image L` to linear indices(number-only)
rows=size(image, 1);
cols=size(image, 2);
% for each label, try to find out the `mean value` of corresponding RGB on that index
for label=1:Label_num
    red_idx=idx{label};
    green_idx=idx{label}+rows*cols;
    blue_idx=idx{label}+2*rows*cols;
    result(red_idx)=mean(image(red_idx));
    result(green_idx)=mean(image(green_idx));
    result(blue_idx)=mean(image(blue_idx));
end

% print out the final SLIC result
subplot(1,3,3);
imshow(result);
title('SLIC');
