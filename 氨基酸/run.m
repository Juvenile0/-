%% I. ��ջ�������

%% II. ��������
%data = importdata('seed.txt');
%index = find((data(:,8)==1)|(data(:,8)==2));
%data = data(index,:);
%data(:,8) = data(:,8) - 1;
%g=data
%%

G=g1;
% 1. �������ѵ�����Ͳ��Լ�
n = randperm(size(G,1));
Data1=G;
%%
m=300;
% 2. ѵ����  200

train_matrix = Data1(n(1:m),1:end-1);
train_label = Data1(n(1:m),end);
%%
% 3. ���Լ��D�D196������
test_matrix = Data1(n(m+1:end),1:end-1);
test_label = Data1(n(m+1:end),end);

all_matrix=[train_matrix;test_matrix];
all_label=[train_label;test_label];


 
%% III. ���ݹ�һ

[Train_matrix,PS] = mapminmax(train_matrix');
Train_matrix = Train_matrix';
Test_matrix = mapminmax('apply',test_matrix',PS);
Test_matrix = Test_matrix';
[all_matrix,PS] = mapminmax('apply',all_matrix',PS);
all_matrix=all_matrix';
%Train_matrix=all_matrix(n(1:m),:);
%Test_matrix=all_matrix(n(m+1:end),:);

%% IV. SVM����/ѵ��(RBF�˺���)
%%
% 1. Ѱ�����c/g�����D�D������֤����
[c,g] = meshgrid(-5:0.2:5,-5:0.2:5);
[m,n] = size(c);
cg = zeros(m,n);
eps = 10^(-4);
v = 3;      %3Ч�����
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
% 2. ����/ѵ��SVMģ��
model = svmtrain(train_label,Train_matrix,cmd);
 
%% V. SVM�������
[predict_label_1,accuracy_1,decision_values1] = svmpredict(train_label,Train_matrix,model); 
[predict_label_2,accuracy_2,decision_values2] = svmpredict(test_label,Test_matrix,model);
[predict_label_3,accuracy_3,decision_values3] = svmpredict(all_label,all_matrix,model);
%[predict_label_4,~,~] = svmpredict(zeros(10,1),Classify_matrix,model);

%% VI. ��ͼ

figure(3)
plotroc(all_label',decision_values3');
string = {'���Լ�SVMԤ�����Ա�(RBF�˺���)';
          ['accuracy = ' num2str(accuracy_3(1)) '%']};
title(string)
AUC=AUC(all_label',predict_label_3')
TP=0;  %����
FN=0;   %����
TN=0;   %����
FP=0;   %����
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
Sn=(TP/(TP+FN))         %������
Sp=(TN/(TN+FP))         %������
PPV=(TP/(TP+FP))        %��׼��
CC=((TP*TN)-(FN*FP))/sqrt((TP+TN)*(TN+FP)*(TP+FP)*(TN+FN))  %���ϵ��

 
