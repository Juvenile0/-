clc
clear
%一.加载数据，数据处理
[~,~,Data]=xlsread('Data.xls');        %Data.xls是excel删除重复项后得到的表格，总共396+10项，前198项为磷酸化序列，最后10项为待分类对象
new_Data = zeros(size(Data,1),15);           %  序列为2L+1长度 从第8位s氨基酸左右各取L长度的序列，组成新的氨基酸序列
C='ARNDCQEGHILKMFPSTWYVO';
alpha = [0.934 0.962 0.986 0.994 0.9 1.047 0.986 1.015 0.882 0.766 0.825 1.04 0.804 0.773 1.047 1.056 1.008 0.848 0.931 0.825 0];
for b=1:size(Data,1)
    a=char(Data(b));
    for c=1:7
        t = find(C==a(c));
        new_Data(b,c)=alpha(t);
    end
    for c=9:15
        t = find(C==a(c));
        new_Data(b,c-1)=alpha(t);
    end    
end
new_Data(1:198,end)=1;          %第15个属性表示分类，1-磷酸化  0-未磷酸化
frequent=frequent(Data);        %21个氨基酸在每个序列中的百分比
Data1=recreate(frequent,new_Data);      %伪氨基酸处理后的特征向量




%二.特征向量处理
% 1. 随机产生训练集和测试集
n = randperm(size(Data1,1)-10);
m=300;
% 训练集 300
train_matrix = Data1(n(1:m),1:end-1);
train_label = Data1(n(1:m),end);
% 测试集――96个样本
test_matrix = Data1(n(m+1:396),1:end-1);
test_label = Data1(n(m+1:396),end);
% 待分类样本
classify_matrix = Data1(397:end,1:end-1);
classify_label = Data1(397:end,end);
% 全部样本
all_matrix=[train_matrix;test_matrix];
all_label=[train_label;test_label];


% 2.数据归一化处理
[Train_matrix,PS] = mapminmax(train_matrix');
Train_matrix = Train_matrix';
Test_matrix = mapminmax('apply',test_matrix',PS);
Test_matrix = Test_matrix';
[Classify_matrix,PS] = mapminmax('apply',classify_matrix',PS);
Classify_matrix=Classify_matrix';
[All_matrix,PS] = mapminmax('apply',all_matrix',PS);
All_matrix=All_matrix';


%三. svm训练样本(选用RBF核函数)
% 1. 使用交叉验证法寻找最佳参数 c & g;
[c,g] = meshgrid(-5:0.5:5,-5:0.5:5);
[m,n] = size(c);
cg = zeros(m,n);
eps = 10^(-4);
v = 3;      %3效果最好
bestc = 1;
bestg = 0.1;
bestacc = 0;
for i = 1:m
    for j = 1:n
        cmd = ['-v',num2str(v),'-t 2',' -c ',num2str(2^c(i,j)),' -g ',num2str(2^g(i,j))];
        cg(i,j) = svmtrain(train_label,Train_matrix,cmd);    

        if cg(i,j) > bestacc
            bestacc = cg(i,j);
            bestc = 2^c(i,j);
            bestg = 2^g(i,j);
        end        
        %if abs( cg(i,j)-bestacc )<=eps && bestc > 2^c(i,j) 
        if  cg(i,j)==eps && bestc > 2^c(i,j)
            bestacc = cg(i,j);
            bestc = 2^c(i,j);
            bestg = 2^g(i,j);
        end               
    end
end
% 2. c g 参数寻找过程图像表示

c1=zeros(size(c,1),size(c,2));
g1=zeros(size(g,1),size(g,2));
for i=1:size(c,1)
  for k=1:size(c,2)
     c1(i,k)=2^c(i,k);
     g1(i,k)=2^g(i,k);
  end
end



cmd = [' -t 2',' -c ',num2str(bestc),' -g ',num2str(bestg)];
model = svmtrain(train_label,Train_matrix,cmd);     
 
% 四.svm测试
[predict_label_1,accuracy_1,decision_values1] = svmpredict(train_label,Train_matrix,model); 
[predict_label_2,accuracy_2,decision_values2] = svmpredict(test_label,Test_matrix,model);
[predict_label_3,accuracy_3,decision_values3] = svmpredict(all_label,All_matrix,model);
[predict_label_4,~,~] = svmpredict(classify_label,Classify_matrix,model);    %待测试样本

% 五.绘图
%1.绘制三维等高面
figure(1)
mesh(c,g,cg)
xlabel('log2c','FontSize',10);
ylabel('log2g','FontSize',10);
grid on;
colormap([0 0 1]) % 颜色
%2.绘制二维等高面
figure(2)
[C,h] = contour(c,g,cg,65:1.5:100);
clabel(C,h,'FontSize',10,'Color','r');
xlabel('log2c','FontSize',10);
ylabel('log2g','FontSize',10);
grid on;

figure(3)
plot(1:length(all_label),all_label,'r*')
axis([1 400 -1 1]);
hold on
plot(1:length(all_label),predict_label_3,'bo')
grid on
legend('真实类别','预测类别')
xlabel('测试集样本编号')
ylabel('测试集样本类别')
string = {'测试集SVM预测结果对比(RBF核函数)';
          ['accuracy = ' num2str(accuracy_3(1)) '%']};
title(string)

% 绘制roc曲线
figure(4)
plotroc(all_label',decision_values3');
string = {'测试集SVM预测结果对比(RBF核函数)';
          ['accuracy = ' num2str(accuracy_3(1)) '%']};
title(string)
% 计算相关属性值
result=AUC(all_label',predict_label_3');
TP=0;  %真阳
FN=0;   %假阴
TN=0;   %真阴
FP=0;   %假阳
 for i=1:size(all_matrix,1)
    if(all_label(i,1)==predict_label_3(i,1))
        if(predict_label_3(i,1)==1)
            TP=TP+1;
        else
            TN=TN+1;
        end

    else
        if(predict_label_3(i,1)==1)
            FP=FP+1;
        else
            FN=FN+1;
        end
    end     
 end

Sn=(TP/(TP+FN))         %敏感性
Sp=(TN/(TN+FP))         %特异性
PPV=(TP/(TP+FP))        %查准率
CC=((TP*TN)-(FN*FP))/sqrt((TP+TN)*(TN+FP)*(TP+FP)*(TN+FN))  %相关系数



