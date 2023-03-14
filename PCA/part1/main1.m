clear all% clear all varaibles
close all % close all opened figures and windows
clc % clear the command window

% ---- Step 1: generate disired matrix ---- 
rk=4; % rk: desired rank of matrix
% use while loop to make sure rank of matrix M is 4
% since, most case A,B should be linearly independent, and their rank is 4
% however, it might have some chance to have linearly dependent cases
% and, that's why the while loop been used
rank_X=0;
while rank_X~=rk
    % A, B: rank must smaller or equal to 4, and the value is either 0 or 1
    % X: rank is at most min{rank(A), rank(B)}
    A=randi([0,1], 10, rk);
    B=randi([0,1], rk, 5); 
    X=A*B;
    rank_X=rank(X);
end
% print out rank of X
fprintf("Rank of X: "+rank(X)+"\n");

% ---- Step 2: get mean of X and substract it from X ----
d=mean(X, 2); % d means the column mean value of X
X_centered=X-d; % X_centered means remove extra offset d from X

% ---- Step 3: apply svd function to find pca(X) ----

