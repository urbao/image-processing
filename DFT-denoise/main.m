clc;
clear all;
close all;

% read the image, and convert it to greyscale
image=imread('iamge.jpg');
grayImage=rgb2gray(image);


% use subplot to show results
