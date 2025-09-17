function [image,noise] = noise(image,noise_level)
S = size(image);
sigma = 1.5693;
noise = sigma * noise_level * rand(S(1),S(2),1);
image = image + noise;
end
