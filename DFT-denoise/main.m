clc;
clear all;
close all;

%% load image, and convert to double-precision greyscale
image=imread('lena.jpg');
gray_img=rgb2gray(image);
image=im2double(gray_img);

%% apply noise to double-precision greyscale image
r=20;
noisy_img=add_noise(image,r);

%% apply 2D DFT to original image & noisy_img
% record elapsed_time for DFT
imageFT=DFT_2D(image);
tic;
noisy_imgFT=DFT_2D(noisy_img);
e_time=toc;

%% apply fftshift(), log() and mat2gray() to image & noisy_img
% original image part
imageFT_shift=fftshift(imageFT);
log_imageFT=log(1+abs(imageFT_shift));
log_imageFT=mat2gray(log_imageFT);
% noised image part
noisy_imgFT_shift=fftshift(noisy_imgFT);
noisy_imgFT=log(1+abs(noisy_imgFT_shift));
noisy_imgFT=mat2gray(noisy_imgFT);

%% use filter to remove high-frequency component
[rows, cols]=size(noisy_img);
filter=zeros(rows,cols);
filter(r:rows-r,r:cols-r)=1;
filter_img=noisy_imgFT_shift.*filter;
log_filter_img=log(1+abs(filter_img));
log_filter_img=mat2gray(log_filter_img);

%% apply 2D IDFT to denoised images
% record elapsed_time for IDFT
filter_img=ifftshift(filter_img);
tic;
denoise_img=IDFT_2D(filter_img);
e_time1=toc;
denoise_img=real(denoise_img);
denoise_img=mat2gray(denoise_img);

%% show all result
figure;
subplot(2,4,1), imshow(image);title('Original');
subplot(2,4,2), imshow(noisy_img);title('Noised Image');
subplot(2,4,3), imshow(log_imageFT);title('log FT Original Image');
subplot(2,4,4), imshow(noisy_imgFT);title('log FT Noised Image');
subplot(2,4,5), imshow(filter);title('Filter');
subplot(2,4,6), imshow(log_filter_img);title('log filter FT Image');
subplot(2,4,7), imshow(denoise_img);title('Denoised Image');

%% display info in command window
frob=norm(denoise_img-image, 'fro');
ssim_val=ssim(denoise_img, image);
disp("Frobenius Norm: "+frob);
disp("SSIM Value: "+ssim_val);
disp("2D DFT Elapsed Time: "+e_time+"s");
disp("2D IDFT Elapsed Time: "+e_time1+"s");

%% Subprogram 1: implementation of 2D DFT
% method: break down to two 1D DFT(efficient)
% input: 2D image
% output: 2D DFT coefficient matrix
function [output]=DFT_2D(input)
    [rows, cols]=size(input);
    output=zeros(rows, cols);
    row_dft = zeros(rows, cols);
    % perform 1D DFT on rows dimension
    for kk = 1:rows
        row_dft(kk,:)=DFT_1D(input(kk,:));
    end
    % perform 1D DFT on cols dimension
    for ll = 1:cols
        output(:,ll)=DFT_1D(row_dft(:,ll).');
    end
end

%% Subprogram 2: implementation of 2D IDFT
% method: break down to two 1D IDFT(efficient)
% input: 2D DFT coefficient matrix
% output: 2D recover image
function [output]=IDFT_2D(input)
    [rows, cols]=size(input);
    output=zeros(rows,cols);
    row_idft = zeros(rows, cols);
    % perform 1D DFT on rows dimension
    for kk = 1:rows
        row_idft(kk,:)=IDFT_1D(input(kk,:));
    end
    % perform 1D DFT on cols dimension
    for ll = 1:cols
        output(:,ll)=IDFT_1D(row_idft(:,ll).');
    end
end

%% Subprogram 3: implementation of 1D DFT(used in DFT_2D())
% input: 1D image(1*N)
% output: 1D DFT coefficient matrix
function [output]=DFT_1D(input)
    N=length(input);
    output=zeros(1,N);
    % compute 1D DFT
    for ii=1:N
        for jj=1:N
            output(ii)=output(ii)+input(jj)*exp(-1i*2*pi*(ii-1)*(jj-1)/N);
        end
    end
end

%% Subprogram 4: implementation of 1D IDFT(used in IDFT_2D())
% input: 1D image(1*N)
% output: 1D IDFT coefficient matrix
function [output]=IDFT_1D(input)
    N=length(input);
    output=zeros(1,N);
    % compute 1D IDFT
    for ii=1:N
        for jj=1:N
            output(ii)=output(ii)+input(jj)*exp(1i*2*pi*(ii-1)*(jj-1)/N);
        end
        % Inverse DFT factor
        output(ii)=output(ii)/N;
    end
end