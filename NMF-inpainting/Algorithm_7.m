% reset all windows and cmd window, and clear all
clc;
close all;
clear all;


% load the Nevada.mat data, and stored to variable called `Nevada`
% p.s. Use the `whos` command to check the data is called 'X'
load("Nevada.mat", 'X');
Nevada=X;