clear all;
close all;
clc;

% load the Nevada.mat data
load("Nevada.mat", 'X');
rows=size(X, 1);
cols=size(X, 2);
bands=size(X, 3);

% NNN: the different N value set
% XXX: different N recover_X forbenius norm error set
% record from N=2 to N=11
NNN=zeros(1,10);
XXX=zeros(1,10);
X=reshape(X, rows*cols, bands)';
% from N=2 to N=11, recover the X and calculate frob error
for i=2:11
    [A, S, time]=HyperCSI(X, i);
    recover_X=A*S;
    frob=norm(X-recover_X, 'fro');
    NNN(1, i-1)=i;
    XXX(1, i-1)=frob;
end

% plot the Frobenius Norm error with N as line
figure;
plot(NNN, XXX, 'LineWidth', 2);
title('Relationship of N v.s. Forbenius Norm Error');
xlabel('N');
ylabel('Forbenius Norm Error');