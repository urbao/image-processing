clc;
clear all;
close all;

%% load image and convert to double-precision greyscale
image=imread('lena.jpg');
image=im2double(image);
gray_img=rgb2gray(image);

% define add noise size, and create subplot
r=20;
figure;
subplot(2,4,1),imshow(gray_img);title('Original Image');

%% Part 1: Use gray_img to compute 2D DFT
% apply noise to gray_img
noisy_gray_img=add_noise(gray_img, r);
subplot(2,4,2),imshow(noisy_gray_img);title('Noised Image');

% apply 2D DFT to gray_img & noisy_gray_img
% also record elapsed time
FT_gray_img=DFT_2D(gray_img);
tic;
FT_noisy_gray_img=DFT_2D(noisy_gray_img);
e_time1=toc;

% apply fftshift(),log() and mat2gray() to FT_gray_img & FT_noisy_gray_img
% original gray_img
FT_gray_img=fftshift(FT_gray_img);
log_FT_gray_img=log(1+abs(FT_gray_img));
log_FT_gray_img=mat2gray(log_FT_gray_img);
subplot(2,4,3),imshow(log_FT_gray_img);title('log FT Image');
% noisy gray_img
FT_noisy_gray_img=fftshift(FT_noisy_gray_img);
log_FT_noisy_gray_img=log(1+abs(FT_noisy_gray_img));
log_FT_noisy_gray_img=mat2gray(log_FT_noisy_gray_img);
subplot(2,4,4),imshow(log_FT_noisy_gray_img);title('log FT Noised Image');

% apply a filter to remove high-freq components
% create a filter
[rows, cols]=size(noisy_gray_img);
filter=zeros(rows, cols);
filter(r:rows-r, r:cols-r)=1;
subplot(2,4,5),imshow(filter); title('Filter');
% apply filter to FT_noisy_gray_img
filter_img=filter.*FT_noisy_gray_img;
log_filter_img=log(1+abs(filter_img));
log_filter_img=mat2gray(log_filter_img);
subplot(2,4,6),imshow(log_filter_img);title('log FT Filter Image');

% apply 2D IDFT to filter_img
filter_img=ifftshift(filter_img);
tic;
denoised_img=IDFT_2D(filter_img);
e_time2=toc;
denoised_img=real(denoised_img);
denoised_img=mat2gray(denoised_img);
subplot(2,4,7),imshow(denoised_img);title('Denoised Image');

% create high-pass filter to get the outline of original-grayscale-image
r1=55;
filter1=zeros(size(gray_img));
filter1(r1:rows-r1, r1:cols-r1)=1;
HP_filter=(filter1~=1);
sharp_img=HP_filter.*FT_gray_img;
sharp_img=ifftshift(sharp_img);
sharp_img = IDFT_2D(sharp_img);
sharp_img = real(sharp_img);
sharp_img = mat2gray(sharp_img);
subplot(2,4,8), imshow(sharp_img);title('HP Filter Original Image');

% display info, including SSIM & Frobeniuse Norm
frob_val=norm(denoised_img-gray_img, 'fro');
ssim_val=ssim(denoised_img, gray_img);
rmse_val=0;
disp("====DFT to Grayscale Image====");
disp("Frobenius Norm: "+frob_val);
disp("SSIM Value: "+ssim_val);
disp("DFT Elapsed Time: "+e_time1+"s");
disp("IDFT Elapsed Time: "+e_time2+"s");

%% Part 2: Use RGB image to compute 2D DFT
% create new figure, and show original image
figure;
subplot(2,4,1),imshow(image);title('Original Image');

% apply noise to image, and save as noisy_img
noisy_img=zeros(size(image));
for ii=1:3
    noisy_img(:,:,ii)=add_noise(image(:,:,ii),r);
end
subplot(2,4,2),imshow(noisy_img);title('Noised Image');

% apply 2D DFT to image, and see the log grayscale result
FT_image=zeros(size(image));
log_FT_img=zeros(size(image));
for ii=1:3
    FT_image(:,:,ii)=DFT_2D(image(:,:,ii));
    FT_image(:,:,ii)=fftshift(FT_image(:,:,ii));
    log_FT_img(:,:,ii)=log(1+abs(FT_image(:,:,ii)));
    log_FT_img(:,:,ii)=mat2gray(log_FT_img(:,:,ii));
end
subplot(2,4,3),imshow(log_FT_img);title('log FT Original Image');

% apply 2D DFT to noisy_img, and see the log grayscale result
% noisy_img_shift: used to apply filter
noisy_img_shift=zeros(size(image));
e_time3=0;
for ii=1:3
    tic;
    noisy_img(:,:,ii)=DFT_2D(noisy_img(:,:,ii));
    e_time3=e_time3+toc;
    noisy_img_shift(:,:,ii)=fftshift(noisy_img(:,:,ii));
    noisy_img(:,:,ii)=log(1+abs(noisy_img_shift(:,:,ii)));
    noisy_img(:,:,ii)=mat2gray(noisy_img(:,:,ii));
end
subplot(2,4,4),imshow(noisy_img);title('log FT Noised Image');

% apply filter to noisy_img_shift
subplot(2,4,5),imshow(filter);title('Filter');
filter_img=zeros(size(image));
log_filter_img=zeros(size(image));
for ii=1:3
    filter_img(:,:,ii)=filter.*noisy_img_shift(:,:,ii);
    log_filter_img(:,:,ii)=log(1+abs(filter_img(:,:,ii)));
    log_filter_img(:,:,ii)=mat2gray(log_filter_img(:,:,ii));
end
subplot(2,4,6),imshow(log_filter_img);title('log FT Filter Image');

% apply 2D IDFT to filter_img to denoise
denoise_img=zeros(size(image));
e_time4=0;
for ii=1:3
    filter_img(:,:,ii)=ifftshift(filter_img(:,:,ii));
    tic;
    denoise_img(:,:,ii)=IDFT_2D(filter_img(:,:,ii));
    e_time4=e_time4+toc;
    denoise_img(:,:,ii)=real(denoise_img(:,:,ii));
end
subplot(2,4,7),imshow(denoise_img); title('Denoised Image');

% apply high-pass filter to original-RGB-image
sharp_img=zeros(size(image));
for ii=1:3
    sharp_img(:,:,ii)=HP_filter.*FT_image(:,:,ii);
    sharp_img(:,:,ii)=ifftshift(sharp_img(:,:,ii));
    sharp_img(:,:,ii) = IDFT_2D(sharp_img(:,:,ii));
    sharp_img(:,:,ii) = real(sharp_img(:,:,ii));
    sharp_img(:,:,ii) = mat2gray(sharp_img(:,:,ii));
end
subplot(2,4,8), imshow(sharp_img);title('HP Filter Original Image');

% display info, including SSIM & Frobeniuse Norm
disp("====DFT to RGB Image====");
frob_val=norm(denoise_img-image, 'fro');
ssim_val=ssim(denoise_img, image);
disp("Frobenius Norm: "+frob_val);
disp("SSIM Value: "+ssim_val);
disp("DFT Elapsed Time: "+e_time3+"s");
disp("IDFT Elapsed Time: "+e_time4+"s");

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

%% Subprogram 5: implementation of 2D DFT full operations on grayscale-image
function [e_time1, e_time2]=Demo(gray_img)
    
end