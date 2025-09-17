function [pha,F] = parse_phase(pha1,pha2,F_1,F_2)
c = 2*pi;
pha = pha1 - pha2 ;

pha = mod(pha , c);
F=F_1/(F_1-F_2);
end

