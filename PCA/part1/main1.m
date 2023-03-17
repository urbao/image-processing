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
    B=randi([0,1], rk, 100); 
    X=A*B;
    rank_X=rank(X);
end
% print out rank of X
fprintf("Rank of X: "+rank(X)+"\n");

% ---- Step 2: get mean of X and substract it from X ----
d=mean(X, 2); % d means the column mean value of X
X_centered=X-d; % X_centered means remove extra offset d from X

% ---- Step 3: apply orth function to find pca(X) ----
% in order to find 4 orthogonal basis
C=orth(X_centered);
% Compress X_centered to 4*100 Y
Y=transpose(C)*X_centered;

% ---- Step 4: reconstruct data to X_reconstruct via C, Y and d
% Given equation: X_reconstruct=C*Y+d*ones(100)
X_reconstruct=(C*Y)+(d*ones([1, 100]));

% ---- Step 5: Plot C as curves
% time vector with 10 sampling points
t=linspace(1, 10, 10);
% plot each column as one curve with 10 sampling points
plot(t, C(:,1), t, C(:,2), t, C(:,3), t, C(:,4), 'LineWidth', 2)
legend('Column1', 'Column2', 'Column3', 'Column4')
xlabel('Sampling points')
ylabel('Amplitude')
title('Four curves of C matrix')

% ---- Step 6: Plot X_reconstruct-X as 2D map
X_error=X_reconstruct-X;
figure;
imagesc(X_error);
colorbar;
title('2D map of X-error')
xlabel('X-axis')
ylabel('Y-axis')
