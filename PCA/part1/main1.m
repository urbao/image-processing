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
X_centered=X-d; % X_centered means NO offset
cov_X=cov(X_centered');
%{
[eigenvectors, eigenvalues]=eig(cov_X);

[~, indices]=sort(diag(eigenvalues), 'descend');
eigenvectors=eigenvectors(:, indices);

C=eigenvectors(:, 1:4);
% display C as four curves
x=linspace(0, 1, 10);
xi=linspace(0, 1, 10000); % cut to smaller grid for interpolation
C_inter=zeros(length(xi), 4);
for i=1:4
    C_inter(:, i)=spline(x, C(:, i), xi);
end
figure;
hold on;
for i=1:4
    plot(xi, C_inter(:, i));
end
xlabel('Sampling Points');
ylabel('Value');
title('Four orthonormal vectors in C');
legend('Vector 1', 'Vector 2', 'Vector 3', 'Vector 4');

Y=C'*(X-d');
Xc=C*Y'+d';

err=X;
figure;
imagesc(err);
colormap('jet');
colorbar;
xlabel('Data point index');
ylabel('Variable index');
title('Difference between X and Xc');
%}
