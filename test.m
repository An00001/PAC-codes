N=8;
n=ceil(log2(N));
N=2^n;
k=4;
R=k/N;
d=[0,1,1,0];
c=[1,0,1];%c=[c_0,c_1,...,c_m]
conv_length=length(c);
m=length(c)-1;
snr_dB=20;
%% RM score
Channel_indices=(0:N-1)';
bitStr=dec2bin(Channel_indices);
bit=abs(bitStr)-48;
RM_score=sum(bit,2);
[RM_score_sorted, sorted_indices]=sort(RM_score,'ascend');
info_indices=sorted_indices(end-k+1:end);
%% Rate Profile
v=zeros(1,N);
v(info_indices)=d;
%% convolutional encoder
c_zp=[c,zeros(1,N-conv_length)];
T=triu(toeplitz(c_zp)); %upper-triangular Toeplitz matrix
u=v*T;
u2=convTrans(v,c);
%% Polar Encoding
P=get_P(N);
x=mod(u*P,2);
bpsk=1-2*x;
%% Channel
sigma = 1/sqrt(2 * R) * 10^(-snr_dB/20);
noise = randn(1,N);
y=bpsk+sigma*noise;
%% List decoding
llr=2*y/sigma^2;

%% convolution encoding functions 
function u = convTrans(v,c)
    u=zeros(1,length(v));
    curr_state = zeros(1,length(c)-1);
    for i = 1:length(v)
        [u(i),curr_state]=conv1bTrans(v(i),curr_state,c);
    end
end

function [u,next_state] = conv1bTrans(v,curr_state,c)
    u=mod(v*c(1),2);
    for j=2:length(c)
        if(c(j)==1)
           u=mod(u+curr_state(j-1),2);
        end
    end
    next_state=[v,curr_state(1:end-1)];
end
