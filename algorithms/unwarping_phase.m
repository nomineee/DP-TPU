function [unwrapping_phase,M,D,A,B] = unwarping_phase(image,N,len,K)
%%% N-step fringe shifting
%N=12;%%step
a = 480;
b = 640;
image = im2double(image);
image(image<4/255) = nan;
%%%% add noise
% if K>0
%     sigma = 1.5693;
%     l = (len+1)*3;
%     sigma = K * sigma;
% %     noise = zeros(a,b,1);
%     for k = 1:1:l
%         noise = sigma .* randn(a,b,1);
%         image(:,:,k) = image(:,:,k) + noise;
%     end
% end

M = zeros(a,b,len+1);
D = zeros(a,b,len+1);
A = zeros(a,b,len+1);
% B = zeros(a,b,len+1);
for j = 0:1:len %%object
    for k = 1:1:N %%N step
        M(:,:,j+1)=image(:,:,k+j*N).*sin(2*pi*(k)/N )+M(:,:,j+1);
        D(:,:,j+1)=image(:,:,k+j*N).*cos(2*pi*(k)/N )+D(:,:,j+1);
        A(:,:,j+1)=image(:,:,k+j*N);
    end
end
%% Gaussian filtering
% sigma = 1;
% gausFilter = fspecial('gaussian',[3 3],sigma);
% M=imfilter(M,gausFilter,'replicate');
% D=imfilter(D,gausFilter,'replicate');
B = (2/N)*((M.^2+D.^2).^0.5);
A = A/N;
unwrapping_phase = atan2(M,D);
end

