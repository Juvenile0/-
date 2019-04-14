%计算21个氨基酸百分比的函数
function g = frequent(X)
   %X对应字符串序列
   m=21;
   alpha = char('ARNDCQEGHILKMFPSTWYVO');   %1:21维向量分别对应A-O氨基酸在序列中的百分比
   g = zeros(size(X,1),m);
    for i=1:size(X,1)
        for j=1:21
            if(j==16)    
                g(i,j)= (length(find(char(X(i))==alpha(1,j)))-1)/14;    %出去最中间项氨基酸
            else
                g(i,j)= length(find(char(X(i))==alpha(1,j)))/14;    %计算每个氨基酸的频率，序列长度为14;
            end
        end
    end
    
    
end

