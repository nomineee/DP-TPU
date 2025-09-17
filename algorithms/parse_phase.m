function [pha,F] = parse_phase(pha1,pha2,F_1,F_2)
%UNTITLED2 此处显示有关此函数的摘要
%   此处显示详细说明
c = 2*pi;
pha = pha1 - pha2 ;

pha = mod(pha , c);
F=F_1/(F_1-F_2);
end

