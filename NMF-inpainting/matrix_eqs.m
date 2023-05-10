% reset all windows and cmd window, and clear workspace
clc;
close all;
clear all;

%% Define the imshow bands info
Red_band=18;
Green_band=8;
Blue_band=2;

%% load the original unmasked data for comparison
load("Nevada.mat", 'X');
figure;
subplot(1,4,1);
imshow(X(:,:,[Red_band, Green_band, Blue_band]));
title("Reference");

%% load the "Data_8.mat" data, and save useful info
load("Data_8.mat", 'Y_omega');
rows=size(Y_omega, 1);
cols=size(Y_omega, 2);
bands=size(Y_omega, 3);
subplot(1,4,2);
imshow(Y_omega(:,:,[Red_band, Green_band, Blue_band]));
title("Corrupted");

%% show some masked-data info
missing_entries=0;
for rr=1:rows
    for cc=1:cols
        for bb=1:bands
            if Y_omega(rr, cc, bb)==0
                missing_entries=missing_entries+1;
            end
        end
    end
end
disp("missing_entries count: "+missing_entries);
M=bands;
L=rows*cols;
missing_precentage=missing_entries/(M*L)*100;
disp("missing percentage: "+missing_precentage+"%");

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
% count of endmembers (idea from result of diff_N_frob.m)
N=6;
% after removing some cols, the Y_reformat cols count changed
reformat_cols=size(Y_rm_stripe, 2);
% reshape Y_reformat matrix to (M*L)
Y_rm_stripe=reshape(Y_rm_stripe, rows*reformat_cols, bands)';
[A_est, SS_est, time]=HyperCSI(Y_rm_stripe, N);

%% Try to find S_est
% start timer
tic;
%========================================================
% Method: Try to solve equations by def of matrix multiplication
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
            S_est(:, ii)=sol;
            % after this reset varibles, and break the loop
            AAA=zeros(bands,N);
            bbb=zeros(bands,1);
            eqs_counter=0;
        end
    end
end
%=========================================================
% output the recovered_image
subplot(1,4,4);
Y=A_est*S_est;
Y=reshape(Y', rows, cols, bands);
imshow(Y(:,:,[Red_band, Green_band, Blue_band]));
title("Recover");

% stop timer, and disp elapsed time
elapsed_time=toc;
disp("Elapsed time: "+elapsed_time+"s");

%% Calculate the Frobenius norm of ||X-A_est*S_est||
%========================================================
X=reshape(X, rows*cols, bands)';
Y=reshape(Y, rows*cols, bands)';
frob=norm(X-Y, 'fro');
disp("Frobenius Norm: "+frob);

% calculate rmse error
diff=X-Y;
squared_diff=diff.^2;
mean_squared_diff=mean(squared_diff(:));
rmse=sqrt(mean_squared_diff);
disp("rmse: "+rmse);

% calculate ssim index(Structral SiMilarity index)
ssim_index=ssim(Y, X);
disp("ssim: "+ssim_index);

