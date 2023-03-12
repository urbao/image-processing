clear all% clear all varaibles
close all % close all opened figures and windows
clc % clear the command window

% ---- Step 1: generate disired matrix ---- 
rk=4; % rk: rank of matrix
% use while loop to make sure rank of matrix M is 4
% since, most case A,B should be linearly independent, and their rank is 4
% however, it might have some chance to have linearly dependent cases
% and, that's why the while loop been used
rank_X=0;
while rank_X~=rk
    % A, B: rank must smaller or equal to 4
    % X: rank is at most min{rank(A), rank(B)}
    A=randi([0,1], 10, rk);
    B=randi([0,1], rk, 100); 
    X=A*B;
    rank_X=rank(X);
end
% print out rank of X
fprintf("Rank of X: "+rank(X)+"\n");

% ---- Step 2: get mean of X and substract it from X ----
d=mean(X, 2); % 2 means the X is 2D array
X_centered=X-d; % X_centered means remove extra offset d from X

% ---- Step 3: use singular value decomposition(SVD) on X
[U, S, V]=svd(X);
Prin_Comp=X*V;
explaned_var=(diag(S).^2/sum(diag(S)).^2);
cumulative_explained_var=cumsum(explaned_var);
plot(cumulative_explained_var);

num_components_to_retain=1;
Prin_Comp_Reduced=Prin_Comp(:, 1:num_components_to_retain);
