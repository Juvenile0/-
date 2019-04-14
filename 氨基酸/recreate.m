%α�����ữ�ĺ���
function g = recreate(Data,new_Data)
    %Data ��Ӧ�ٷֱȣ�new_Data��Ӧ������
    n=1;
    w=0.05;  %��Ȩ����,0.05Ч�����
    g=zeros(size(Data,1),size(Data,2)+n+1);     %23ά��ǰ21ά�ǰ�����ٷֱȣ�֮��Ϊ�����������Ϣ�ͷ���
    L=15;
    [Data,PS] = mapminmax(Data');       %��һ������
    Data=Data';
    sum=0;
    for t=1:size(Data,1)
        for u=1:21
            R=0;
            sum=0;
            for j=1:n
               for i=1:L-j
                    R=R+(new_Data(t,i)-new_Data(t,i+j))^2;     
               end
               sum=sum+1/(L-j)*R;
            end
            g(t,u)=Data(t,u)/(1+w*sum);
        end
        
       for u=22:(21+n)
          sum=0;
          for j=1:n
              for i=1:L-j
                  R=R+(new_Data(t,i)-new_Data(t,i+j))^2;     
              end
              sum=sum+1/(L-j)*R;
          end
           R=0;
          for c=1:(L-(u-21))
              R=R+(new_Data(t,c)-new_Data(t,c+u-21))^2;  
          end
          g(t,u)=w*R/((1+w*sum)*(L-u+21)); 
       end
       g(:,end)=new_Data(:,end);
       
    end 
end