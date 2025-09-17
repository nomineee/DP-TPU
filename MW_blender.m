close all;clc,clear;
% environment configuration
addpath(genpath('./algorithms')); % algorithms
%% low-frequency part
noise_level=0;
pt = '.\dataset\img\img_63\';
N = 12;
[image,nms] = readimg(pt,'bmp');
len = length(nms)/N-1;
[unwraping_phase_low,~,~,~,B_l] = unwarping_phase(image,N,len,noise_level);
index = find(unwraping_phase_low < 0);
unwraping_phase_low(index) = unwraping_phase_low(index) + 2*pi;
clear image;
%% high-frequency part
pt = '.\dataset\img\img_64\';
[image,nms] = readimg(pt,'bmp');
[unwraping_phase_high,~,~,~,B_h] = unwarping_phase(image,N,len,noise_level);
index = find(unwraping_phase_high < 0);
unwraping_phase_high(index) = unwraping_phase_high(index) + 2*pi;
clear image;
%% Multi-wavelength phase unwrapping methods
F_h = 64;
F_l = 63;
c=2*pi;
p=unwraping_phase_high-unwraping_phase_low;
[unwraping_phase_eq,F_hl] = parse_phase(unwraping_phase_high,unwraping_phase_low,F_h,F_l);
K=zeros(480,640,length(nms)/N);
K=round((F_hl*unwraping_phase_eq-unwraping_phase_high)/c);
