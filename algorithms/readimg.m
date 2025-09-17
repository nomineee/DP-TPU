function [image,nms] = readimg(pt,name)
if strcmp(name,'tif')
ext = '*.tif';
end
if strcmp(name,'bmp')
ext = '*.bmp';
end
dis = dir([pt ext]);
nms = {dis.name};
sort_nat_name=sort_nat({dis.name});
%利用N步相移法求包裹相位
if strcmp(name,'tif')
image=uint16(zeros(480,640,length(nms)));
end
if strcmp(name,'bmp')
image=uint8(zeros(480,640,length(nms)));
end
for k = 1:1:length(nms)
    nm = [pt sort_nat_name{k}];
    img = imread(nm);
    imgray=img(:,:,1);
    image(:,:,k)= imgray(:,:);
end
if strcmp(name,'tif')
   image=image./257;
end
end

