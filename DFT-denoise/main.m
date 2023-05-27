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
[image_DFT, e_time]=DFT_2D(noisy_img);
image_DFT_brute_force=fft2(noisy_img);
image_DFT_brute_force=fftshift(image_DFT_brute_force);
image_DFT_brute_force=log(1+abs(image_DFT_brute_force));
image_DFT_brute_force=mat2gray(image_DFT_brute_force);
[noisy_img_DFT, e_time]=DFT_2D(noisy_img);

%% denoising to remove high-frequency components


%% apply Inverse 2D DFT to denoised images


%% show all result
figure;
subplot(1,4,1), imshow(image);title('Original');
subplot(1,4,2), imshow(noisy_img);title('Noised');
subplot(1,4,3), imshow(image_DFT);title('Efficient 2D DFT');
subplot(1,4,4), imshow(image_DFT_brute_force);title('Brute force 2D DFT');

%% Subprogram 1: implementation of 2D DFT(rearranged, efficient)
% input: 2D image
% output: DFT coefficient matrix
function [output,elpased_time]=DFT_2D(input)
    [rows, cols]=size(input);
    output=zeros(rows, cols);
    tic;
    % perform 1D DFT on rows
    for kk=1:rows
        for mm=1:rows
            output(mm,:)=input(mm,:)*exp(-1i*2*pi*(kk*mm/rows));
        end
    end

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
function [output, elasped_time]=DFT_2D_brute_force(input)
    [rows, cols]=size(input);
    output=zeros(rows, cols);
    tic;
    for kk=1:rows
        for ll=1:cols
            sum=0;
            for mm=1:rows
                for nn=1:cols
                    sum=sum+(input(mm,nn)*(exp(-1i*2*pi*(kk*mm/rows+ll*nn/cols))));
                end
            end
            output(kk,ll)=sum;
        end
    end
    elasped_time=toc;
end