% reset all windows and cmd window, and clear all
clc;
close all;
clear all;

%=======================================================
% variables that can be modified based on preference
%-------------------------------------------------------
% mode to decide which entries missed
% allowed: random|fixed
mask_mode="random";
%-------------------------------------------------------
% the ratio of missing entries
% only valid when mask_mode is set to "random"
% ratio=mask_columns/total_columns
missing_cols_ratio=0.10;
%-------------------------------------------------------
% the cols index which will be set to missing
% only valid when mask_mode is set to "fixed"
% "random" mode will overwrite this matrix
missing_cols=[3 14 19 25 34 56 64 79 87 92 112 136 144];

%=======================================================
% load the Nevada.mat data
% The data is stored in variable called 'X'
load("Nevada.mat", 'X');
% get the size of each dimension of X
rows=size(X,1);
cols=size(X,2);
bands=size(X,3);

%=======================================================
% generate mask whose size is same as 'X'
% set missing_cols of mask to 0 as missing entries
mask=ones(rows, cols, bands);
%-------------------------------------------------------
% random mode: random mask based on random_mask_ratio
if mask_mode=="random"
    % generate random cols based on the random_mask_ratio
    num_missing_cols=ceil(missing_cols_ratio*cols);
    missing_cols=randperm(cols, num_missing_cols);
    mask(:, missing_cols, :)=0;
%-------------------------------------------------------
% fixed mode: mask defined by user in Line 20
% check missing_cols validty before computing(MAX: cols, min:1)
elseif mask_mode=="fixed"
    for missing_col=missing_cols
        if missing_col<1
            disp("Mask column index smaller than 1")
            return;
        elseif missing_col>cols
            disp("Mask column index larger than "+cols);
            return
        end
    end
    mask(:, missing_cols, :)=0;
else 
    disp("The mask_mode is not valid");
end
%-------------------------------------------------------
% apply mask to the Nevada data 'X', and save it as 'Y'
Y=X.*mask;
% create subplot to show the X and Y respectively
subplot(1,2,1);
imshow(X(:,:,50));
title('Reference');
subplot(1,2,2);
imshow(Y(:,:,50));
title('Corrupted');

%=======================================================




