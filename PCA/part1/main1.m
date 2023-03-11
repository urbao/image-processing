clc % clear command window

k=4; % k: rank of matrix
% use while loop to make sure rank of matrix M is 4
% since, most case A,B should be linearly independent, and their rank is 4
% however, it might have some chance to have linearly dependent cases
% and, that's why the while loop been used
rank_X=0;
while rank_X~=k
        % A, B: rank must smaller or equal to 4
        % X: rank is at most min{rank(A), rank(B)}
        A=randi([0,1], 10, k);
        B=randi([0,1], k, 100); 
        X=A*B;
        rank_X=rank(X);
end
% print out rank of X
fprintf("Rank of X: "+rank(X)+"\n");

% apply PCA on X
