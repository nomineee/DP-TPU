function  data_mat(v1,path,num)

for i = 1:size(v1,3)
    item = v1(:,:,i);
    k=i+num;
    if k<10
        c = ['a0000',num2str(k)];
    end
    if k > 9 &&k<100
        c = ['a000',num2str(k)];
    end
    if k > 99 && k<999
        c = ['a00',num2str(k)];
    end
    if k>999 && k<9999
        c = ['a0',num2str(k)];
    end
save([path,c],'item','-v7.3');
end

