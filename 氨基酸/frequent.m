%����21��������ٷֱȵĺ���
function g = frequent(X)
   %X��Ӧ�ַ�������
   m=21;
   alpha = char('ARNDCQEGHILKMFPSTWYVO');   %1:21ά�����ֱ��ӦA-O�������������еİٷֱ�
   g = zeros(size(X,1),m);
    for i=1:size(X,1)
        for j=1:21
            if(j==16)    
                g(i,j)= (length(find(char(X(i))==alpha(1,j)))-1)/14;    %��ȥ���м������
            else
                g(i,j)= length(find(char(X(i))==alpha(1,j)))/14;    %����ÿ���������Ƶ�ʣ����г���Ϊ14;
            end
        end
    end
    
    
end

