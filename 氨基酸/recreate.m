%伪氨基酸化的函数
function g = recreate(Data,new_Data)
    %Data 对应百分比，new_Data对应理化性质
    n=1;
    w=0.05;  %加权因子,0.05效果最好
    g=zeros(size(Data,1),size(Data,2)+n+1);     %23维，前21维是氨基酸百分比，之后为氨基酸相关信息和分类
    L=15;
    [Data,PS] = mapminmax(Data');       %归一化处理
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