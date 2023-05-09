clc;
clear all;
close all;

%% This program'll generate mask, and save masked data into Data_8.mat
%-------------------------------------------------------------
% Global Variables (can be modified based on user's preference)
% The mask will generate by the following rule.
% First, run through all `col` in corrupted_cols
% ,and for each `col`, mask `band` which is in the 
% masked_bands list.
%-------------------------------------------------------------
% the columns that will have corruption
% limitation: 0<col<=150
corrupted_cols=[2,3,8,10,12,14,16,18,20,22,24,26,28....
    30,32,34,36,38,44,46,54,56,58,60,62....
    64,66,68,70,72,78,80,82,84,86,88,90,92,94,96....
    98,100,102,104,106,108,110,112,114,116,118,120,122....
    124,126,128,130,132,134,136,142,144,146,148];
% the bands that will be masked
% limitation: 0<bands<=183
masked_bands=[2,3,5,8,10,12,14,15,16,18,20,22,24,26,28,29....
    ,30,31,33,34,42,44,48,51,52,58,66,68,70,73,77,80,81,83....
    86,88,89,99,106,109,114,115,118,120,127,128,129,131,137,143,....
    156,161,177,182];

% Load the Nevada.mat and save some useful info
load("Nevada.mat", 'X');
rows=size(X,1);
cols=size(X,2);
bands=size(X,3);

% initialize mask which size is the same as 'X'
mask=ones(rows, cols, bands);
% foolprrof checking for validty of corrupted_cols && masked_bands
for col=corrupted_cols
    if col>cols||col<1
        disp("[Error] corrupted_cols is invalid");
        return;
    end
end
for band=masked_bands
    if band>bands||band<1
        disp("[Error] masked_bands is invalid");
        return;
    end
end

% apply mask to Nevada data 'X', and save to 'Y_omega'
mask(:, corrupted_cols, masked_bands)=0;
Y_omega=X.*mask;
disp("Successfully apply mask to X");

% save the 'Y_omega' data to Data_8.mat
save("Data_8.mat", 'Y_omega');