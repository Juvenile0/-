%% I. 清空环境变量

%% II. 导入数据
%data = importdata('seed.txt');
%index = find((data(:,8)==1)|(data(:,8)==2));
%data = data(index,:);
%data(:,8) = data(:,8) - 1;
%g=data
%%

G=g1;
% 1. 随机产生训练集和测试集
n = randperm(size(G,1));
Data1=G;
%%
m=300;
% 2. 训练集  200

train_matrix = Data1(n(1:m),1:end-1);
train_label = Data1(n(1:m),end);
%%
% 3. 测试集――196个样本
test_matrix = Data1(n(m+1:end),1:end-1);
test_label = Data1(n(m+1:end),end);

all_matrix=[train_matrix;test_matrix];
all_label=[train_label;test_label];


 
%% III. 数据归一

[Train_matrix,PS] = mapminmax(train_matrix');
Train_matrix = Train_matrix';
Test_matrix = mapminmax('apply',test_matrix',PS);
Test_matrix = Test_matrix';
[all_matrix,PS] = mapminmax('apply',all_matrix',PS);
all_matrix=all_matrix';
%Train_matrix=all_matrix(n(1:m),:);
%Test_matrix=all_matrix(n(m+1:end),:);

%% IV. SVM创建/训练(RBF核函数)
%%
% 1. 寻找最佳c/g参数――交叉验证方法
[c,g] = meshgrid(-5:0.2:5,-5:0.2:5);
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
        if  cg(i,j)==bestacc && bestc > 2^c(i,j)
            bestacc = cg(i,j);
            bestc = 2^c(i,j);
            bestg = 2^g(i,j);
        end               
    end
end
[C,h] = contour(c,g,cg,65:1.5:100);
clabel(C,h,'FontSize',10,'Color','r');
xlabel('log2c','FontSize',10);
ylabel('log2g','FontSize',10);
grid on;
cmd = [' -t 2',' -c ',num2str(bestc),' -g ',num2str(bestg)];
 
%%
% 2. 创建/训练SVM模型
model = svmtrain(train_label,Train_matrix,cmd);
 
%% V. SVM仿真测试
[predict_label_1,accuracy_1,decision_values1] = svmpredict(train_label,Train_matrix,model); 
[predict_label_2,accuracy_2,decision_values2] = svmpredict(test_label,Test_matrix,model);
[predict_label_3,accuracy_3,decision_values3] = svmpredict(all_label,all_matrix,model);
%[predict_label_4,~,~] = svmpredict(zeros(10,1),Classify_matrix,model);

%% VI. 绘图

figure(3)
plotroc(all_label',decision_values3');
string = {'测试集SVM预测结果对比(RBF核函数)';
          ['accuracy = ' num2str(accuracy_3(1)) '%']};
title(string)
AUC=AUC(all_label',predict_label_3')
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

 
