% reset all windows and cmd window, and clear all
clc;
close all;
clear all;

%=======================================================
%% mask mode variable
% valid: random|fixed
mask_mode="random";
%=======================================================
%% random mode variables
% random mode selects the corrupted_cols based on random_corrupted_cols_ratio,
% then selects mask_bands based on random_masked_bands_ratio for each
% corrupted_cols
%-------------------------------------------------------
% the ratio of columns that have corruption
% ratio=corrupted_columns/total_columns
random_corrupted_cols_ratio=0.5;
%-------------------------------------------------------
% the ratio of bands that have been masked
% ratio=masked_bands/total_bands
random_masked_bands_ratio=0.5;
%=======================================================
%% fixed mode variables(will be Overwritten when "random" mode chosed)
% fixed mode chooses the corrupted_cols based on fixed_corrupted_cols,
% then mask the bands of fixed_masked_bands for each corrupted_cols
%-------------------------------------------------------
% the columns that will have corruption
% limitation: 0 < col <= 150
corrupted_cols=[3, 14, 34, 56, 87, 92, 136, 144];
%-------------------------------------------------------
% the bands that will be masked
% limitation: 0 < band <= 183
masked_bands=[18, 38, 46, 79];
%=======================================================

%% load the Nevada.mat data, and stored useful data
% The data is stored in variable called 'X'
load("Nevada.mat", 'X');
% get the size of each dimension of X
rows=size(X,1);
cols=size(X,2);
bands=size(X,3);
%=======================================================

%% generate the mask
% generate mask whose size is same as 'X'
mask=ones(rows, cols, bands);
%-------------------------------------------------------
% random mode
if mask_mode=="random"
    % generate "corrupted_cols" and "masked_bands" based on the ratio
    corrupted_cols_count=ceil(random_corrupted_cols_ratio*cols);
    masked_bands_count=ceil(random_masked_bands_ratio*bands);
    corrupted_cols=randperm(cols, corrupted_cols_count);
    for col=corrupted_cols
        masked_bands=randperm(bands, masked_bands_count);
        mask(:, col, masked_bands)=0;
    end
%-------------------------------------------------------
% fixed mode
elseif mask_mode=="fixed"
    % foolproof checking for fixed_corrupted_cols && fixed_masked_bands
    for col=corrupted_cols
        if col>cols || col<1
            disp("[Error] corrupted_cols is invalid");
            return;
        end    
    end
    for band=masked_bands
        if band>bands || band<1
            disp("[Error] masked_bands is invalid");
            return;
        end
    end
    mask(:, corrupted_cols, masked_bands)=0;
else 
    disp("The mask_mode is invalid");
    return;
end
%=======================================================
%% apply mask to Neveda data 'X', and show some info
Y=X.*mask;
Red_band=18;
Green_band=8;
Blue_band=2;
% show X and Y(masked_X)
subplot(1,2,1);
imshow(X(:,:,[Red_band, Green_band, Blue_band]));
title('Reference');
subplot(1,2,2);
imshow(Y(:,:,[Red_band, Green_band, Blue_band]));
title('Corrupted');
%-------------------------------------------------------
% show some corrupted and masked info
disp("corrupted_cols: "+join(string(sort(corrupted_cols)), ', '));
if mask_mode=="random"
    disp("random mode has different masked_bands for each corrupted_cols")
else
    disp("masked_bands: "+join(string(sort(masked_bands)), ', '));
end
% show percentage of missing_data
M=bands;
L=rows*cols;
missing_entries=0;
for col_idx=1:cols
    for band_idx=1:bands
        if Y(:, col_idx, band_idx)==0
            missing_entries=missing_entries+1;
        end
    end
end
% the missing_data is stripe, so need to multiply rows
missing_entries=missing_entries*rows;
missing_percentage=missing_entries/(M*L);
disp("missing percentage: "+missing_percentage);
%=======================================================