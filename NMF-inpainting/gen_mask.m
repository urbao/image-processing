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
corrupted_cols=[2,7,9,17,23,28,31,48,81,92,108,114,124,137,142];
% the bands that will be masked
% limitation: 0<bands<=183
masked_bands=[2,3,8,11,18,26,42,73,89,115,127,143,156,177,182];

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