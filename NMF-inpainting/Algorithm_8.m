% reset all windows and cmd window, and clear workspace
clc;
close all;
clear workspace;

%% mask mode variable
%=======================================================
% valid: random|fixed
mask_mode="fixed";

%% random mode variables
%=======================================================
% random mode selects the corrupted_cols based on random_corrupted_cols_ratio,
% then selects mask_bands based on random_masked_bands_ratio for each
% corrupted_cols randomly
%-------------------------------------------------------
% the ratio of columns that have corruption
% ratio=corrupted_columns/total_columns
random_corrupted_cols_ratio=0.1;
%-------------------------------------------------------
% the ratio of bands that have been masked
% ratio=masked_bands/total_bands
random_masked_bands_ratio=0.1;

%% fixed mode variables(will be Overwritten when "random" mode chosed)
%=======================================================
% fixed mode chooses the corrupted_cols based on fixed_corrupted_cols,
% then mask the bands of fixed_masked_bands for each corrupted_cols
%-------------------------------------------------------
% the columns that will have corruption
% limitation: 0 < col <= 150
corrupted_cols=[2,7,9,17,23,28,31,48,53,59,62,77,81,92,108,114,124,137,142];
%-------------------------------------------------------
% the bands that will be masked
% limitation: 0 < band <= 183
masked_bands=[2,3,8,11,18,26,42,73,89,115,127,143,156,177,182];

%% load the Nevada.mat data, and stored useful data
%=======================================================
% The data is stored in variable called 'X'
load("Nevada.mat", 'X');
% get the size of each dimension of X
rows=size(X,1);
cols=size(X,2);
bands=size(X,3);

%% generate the mask based on mask_mode
%=======================================================
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

%% apply mask to Neveda data 'X', and show some info
%======================================================
Y_omega=X.*mask;
Red_band=18;
Green_band=8;
Blue_band=2;
% show X and Y(masked_X)
figure;
subplot(1,4,1);
imshow(X(:,:,[Red_band, Green_band, Blue_band]));
title('Reference');
subplot(1,4,2);
imshow(Y_omega(:,:,[Red_band, Green_band, Blue_band]));
title('Corrupted');
%-------------------------------------------------------
% show some corrupted and masked info
disp("corrupted_cols: "+join(string(sort(corrupted_cols)), ','));
disp("Corrupted Column Count: "+length(corrupted_cols));
disp("========================");
if mask_mode=="random"
    disp("random mode has different masked_bands for each corrupted_cols")
else
    disp("masked_bands: "+join(string(sort(masked_bands)), ','));
end
disp("Masked Bands Count: "+length(masked_bands));
disp("========================");
% show percentage of missing_data
M=bands;
L=rows*cols;
missing_entries=0;
for row_idx=1:rows
    for col_idx=1:cols
        for band_idx=1:bands
            if Y_omega(row_idx, col_idx, band_idx)==0
                missing_entries=missing_entries+1;
            end
        end
    end
end
missing_percentage=missing_entries/(M*L)*100;
disp(("missing entries count: ")+missing_entries);
disp("missing percentage: "+missing_percentage+"%");
disp("========================");

%% reformat the Y_omega matrix into a non-zero value matrix
%========================================================
% use "any" function create logical zero_cols array
% first check row dimension, then bands dimension
zero_cols = any(any(Y_omega == 0, 1), 3);
% remove columns with at least one zero value in any band
% "~zero_cols" means the column with all bands no missing data
subplot(1,4,3);
Y_rm_stripe=Y_omega(:, ~zero_cols, :);
imshow(Y_rm_stripe(:,:,[Red_band, Green_band, Blue_band]));
title("Reformat");

%% Plug Y_reformat into the HyperCSI function
%========================================================
% count of endmembers
N=9;
% after removing some cols, the Y_reformat cols count changed
reformat_cols=size(Y_rm_stripe, 2);
% reshape Y_reformat matrix to (M*L)
Y_rm_stripe=reshape(Y_rm_stripe, rows*reformat_cols, bands)';
[A_est, S_est, time]=HyperCSI(Y_rm_stripe, N);

%% Try to find SS_est
%========================================================
tic;
SS_est=zeros(N, rows*cols);
Y_omega=reshape(Y_omega, rows*cols, bands)';
% the following variables are used to solve SS_est coefficient
AAA=zeros(bands,N);
bbb=zeros(bands,1);
eqs_counter=0;
% run through each column of Y_omega matrix to use 
% any non-zero value to solve SS_est
for ii=1:rows*cols
    for jj=1:bands
        % since Y_omega(jj, ii) is non-zero, so save
        % Y_omega and A_est value into bbb and AAA matrix
        if Y_omega(jj, ii)~=0
            bbb(eqs_counter+1, 1)=Y_omega(jj, ii);
            for kk=1:N
                AAA(eqs_counter+1, kk)=A_est(jj, kk);
            end
        end
        % when jj=bands means all bands already recorded
        % ,which means we can solve the SS_est coefficients
        if jj==bands
            sol=pinv(AAA)*bbb;
            SS_est(:, ii)=sol;
            % after this reset varibles, and break the loop
            AAA=zeros(bands,N);
            bbb=zeros(bands,1);
            eqs_counter=0;
        end
    end
end
elapsed_time=toc;
disp("Elapsed Time: "+elapsed_time+"s");

subplot(1,4,4);
Y=A_est*SS_est;
Y=reshape(Y', rows, cols, bands);
imshow(Y(:,:,[Red_band, Green_band, Blue_band]));
title("Recover");

%% Calculate the Frobenius norm of ||X-A_est*SS_est||
%========================================================
X_recover=A_est*SS_est;
X_recover=reshape(X_recover', rows, cols, bands);
frob=norm(X-X_recover, 'fro');
disp("Frobenius Norm: "+frob);
disp("========================");
