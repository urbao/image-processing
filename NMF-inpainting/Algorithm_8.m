% reset all windows and cmd window, and clear all
clc;
close all;
clear all;

%% load the original unmasked data for comparison
load("Nevada.mat", 'X');
load("Data_8.mat", 'Y_omega');
rows=size(Y_omega, 1);
cols=size(Y_omega, 2);
bands=size(Y_omega, 3);

%% apply mask to Neveda data 'X', and show some info
%======================================================
Red_band=18;
Green_band=8;
Blue_band=2;
% show X and Y(masked_X)    
subplot(1,4,1);
imshow(X(:,:,[Red_band, Green_band, Blue_band]));
title('Reference');
subplot(1,4,2);
imshow(Y_omega(:,:,[Red_band, Green_band, Blue_band]));
title('Corrupted');
%-------------------------------------------------------

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

%% reformat the Y matrix into a non-zero value matrix
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

%% create corrupted_col
corrupted_cols = zeros(1);
countt = 1;
for i = 1:cols
    if zero_cols(1, i) == 1
        corrupted_cols(1, countt) = i;
        countt = countt + 1;
    end
end


%% Plug Y_reformat into the HyperCSI function
%========================================================
% count of endmembers
N=9;
% after removing some cols, the Y_reformat cols count changed
reformat_cols=size(Y_rm_stripe, 2);
% reshape Y_reformat matrix to (M*L)
Y_rm_stripe_in_matrix=reshape(Y_rm_stripe, rows*reformat_cols, bands)';
[A_est, S_estt, time]=HyperCSI(Y_rm_stripe_in_matrix, N);

tic;
S_est = zeros(N, rows*reformat_cols);
for i = 1:rows*reformat_cols
    S_est(:, i) = lsqnonneg(A_est, Y_rm_stripe_in_matrix(:, i));
end

%% reshape S_est to cubic
%========================================================
%recover data to cubic type
S_cubic = ones(rows, cols, N);

S_est_col = 1;

while S_est_col <= size(S_est, 2)

    for i = 1:cols
        for j = 1:rows
            if ~any(corrupted_cols == i)
                for k = 1:N
                    S_cubic(j, i, k) = S_est(k ,S_est_col);
                end
                S_est_col = S_est_col + 1;

            end
        end
    end
end

%% interpolation
%=========================================================
%test: griddata(x, y, v, xq, yq)
% create grid
S_grid = S_cubic;

xx = linspace(1,150,150);  %x, xq            %row
yy = linspace(1,150,150);  %y_no_precessed   %col
for j = size(corrupted_cols, 2):-1:1
    yy(corrupted_cols(j)) = [];  %y
    S_grid(:, corrupted_cols(j), :) = [];    %Z
end

[XX, YY] = meshgrid(xx, yy);

yq = corrupted_cols;    %yq

[Xq, Yq] = meshgrid(xx, yq);

S_recover_cubic = zeros(rows);

% start interpolation and store in Sk
for k = 1:N
    Sk = reshape(S_grid(:, :, k),150, []); 
    vq = griddata(XX', YY', Sk, Xq', Yq');
    
    for kk = 1:size(corrupted_cols, 2)
        size_of_Sk = size(Sk, 2);
        Sk(:, corrupted_cols(1, kk) + 1:size_of_Sk + 1) = Sk(:, corrupted_cols(1, kk):size_of_Sk);
        
        Sk(:, corrupted_cols(1, kk)) = vq(:, kk);

    end
    
    S_recover_cubic(:, 1:cols, k) = Sk;

end



% turn S_recover_cubic into N*(rows*cols) matrix
S_recover = zeros();

m = 1;
for j = 1:cols
    for i = 1:rows
        for k = 1:N
           S_recover(k, m) = S_recover_cubic(i, j, k); 
            
        end
        m = m + 1;
    end
end


%% recover Y
%========================================================
% replace data with having existed one
Y = A_est * S_recover;
Y_omega_ = reshape(Y_omega, rows*cols, bands)';

for i = 1:bands
    for j = 1:rows*cols
        if (Y_omega_(i, j) ~= 0) && (Y_omega_(i, j) ~= Y(i, j))
            Y(i, j) = Y_omega_(i, j);
        end
    end
end

%% show recovered image, and some common error measurement
%========================================================
elapsed_time=toc;
disp("Elapsed Time: "+elapsed_time+"s");
subplot(1,4,4);
Y_show = reshape(Y', rows, cols, bands);
imshow(Y_show(:,:,[Red_band, Green_band, Blue_band]));
title('Recovered');

X_ = reshape(X, rows*cols, bands)';
frobenius = 0;
for i = 1:bands
    for j = 1:rows*cols
        frobenius = frobenius + (Y(i, j) - X_(i, j)) .^ 2;
    end
end

frobenius = frobenius .^ 0.5;
disp(("frobenius: ") + frobenius);

% calculate rmse error
diff=X_-Y;
squared_diff=diff.^2;
mean_squared_diff=mean(squared_diff(:));
rmse=sqrt(mean_squared_diff);
disp("rmse: "+rmse);

% calculate ssim index(Structral SiMilarity index)
ssim_index=ssim(Y, X_);
disp("ssim: "+ssim_index);
