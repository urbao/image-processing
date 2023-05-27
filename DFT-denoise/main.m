clc;
clear all;
close all;

%% load image, and convert to double-precision greyscale
image=imread('lena.jpg');
gray_img=rgb2gray(image);
image=im2double(gray_img);

%% apply noise to double-precision greyscale image
r=20;
noise_img=add_noise(image,r);

%% apply 2D DFT to original image & noisy_img
[imageFT, e_time]=DFT_2D(image);
[noise_imgFT]=DFT_2D(noise_img);

%% apply fftshift(), log() and mat2gray() to images
% original image part
imageFT_shift=fftshift(imageFT);
imageFT_log=log(1+abs(imageFT_shift));
imageFT_log=mat2gray(imageFT_log);
% noised image part
noise_imgFT_shift=fftshift(noise_imgFT);
noise_imgFT_log=log(1+abs(noise_imgFT_shift));
noise_imgFT_log=mat2gray(noise_imgFT_log);

%% denoising to remove high-frequency components


%% apply Inverse 2D DFT to denoised images


%% show all result
figure;
subplot(1,4,1), imshow(image);title('Original');
subplot(1,4,2), imshow(imageFT_log);title('log FT Original');
subplot(1,4,3), imshow(noise_imgFT_log);title('log FT Noised');

%% Subprogram 1: implementation of 2D DFT(rearranged, efficient)
% input: 2D image
% output: DFT coefficient matrix
function [output,elpased_time]=DFT_2D(input)
    [rows, cols]=size(input);
    output=zeros(rows, cols);
    tic;
    
    elpased_time=toc;
end

%% Subprogram 2: implementation of inversed 2D DFT(rearranged, efficient)
% input: DFT coefficient matrix
% output: 2D denoised image
function [output]=IDFT_2D(input)
    [rows, cols]=size(input);
    output=zeros(rows,cols);
    
end

%% Subprogram 3: implementation of 2D DFT (brute-force)
% purpose: comapare elapsed_time with the efficient method
% input: 2D image
% output: DFT coefficient matrix
function [output, elapsed_time]=DFT_2D_brute_force(input)
    [rows, cols]=size(input);
    output=zeros(rows, cols);
    tic;
    for kk=1:rows
        for ll=1:cols
            sum=0;
            for mm=1:rows
                for nn=1:cols
                    sum=sum+input(mm,nn)*(exp(-1i*2*pi*(kk*mm/rows+ll*nn/cols)));
                end
            end
            output(kk,ll)=sum;
        end
    end
    elapsed_time=toc;
end