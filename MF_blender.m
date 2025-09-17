close all;clc,clear;
% environment configuration
addpath(genpath('./algorithms')); % algorithms
%% low-frequency part
noise_level=0;
pt = '.\dataset\img\img_1\';
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
%% Multi-frequency phase unwrapping methods
K=zeros(480,640,length(nms)/N);
F_h=64;
F_l=1;
K = round((F_h.*unwraping_phase_low - F_l.*unwraping_phase_high)/2/pi);
phase = K*2*pi+unwraping_phase_high;
