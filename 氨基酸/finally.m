clc
clear
%һ.�������ݣ����ݴ���
[~,~,Data]=xlsread('Data.xls');        %Data.xls��excelɾ���ظ����õ��ı���ܹ�396+10�ǰ198��Ϊ���ữ���У����10��Ϊ���������
new_Data = zeros(size(Data,1),15);           %  ����Ϊ2L+1���� �ӵ�8λs���������Ҹ�ȡL���ȵ����У�����µİ���������
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
new_Data(1:198,end)=1;          %��15�����Ա�ʾ���࣬1-���ữ  0-δ���ữ
frequent=frequent(Data);        %21����������ÿ�������еİٷֱ�
Data1=recreate(frequent,new_Data);      %α�����ᴦ������������




%��.������������
% 1. �������ѵ�����Ͳ��Լ�
n = randperm(size(Data1,1)-10);
m=300;
% ѵ���� 300
train_matrix = Data1(n(1:m),1:end-1);
train_label = Data1(n(1:m),end);
% ���Լ��D�D96������
test_matrix = Data1(n(m+1:396),1:end-1);
test_label = Data1(n(m+1:396),end);
% ����������
classify_matrix = Data1(397:end,1:end-1);
classify_label = Data1(397:end,end);
% ȫ������
all_matrix=[train_matrix;test_matrix];
all_label=[train_label;test_label];


% 2.���ݹ�һ������
[Train_matrix,PS] = mapminmax(train_matrix');
Train_matrix = Train_matrix';
Test_matrix = mapminmax('apply',test_matrix',PS);
Test_matrix = Test_matrix';
[Classify_matrix,PS] = mapminmax('apply',classify_matrix',PS);
Classify_matrix=Classify_matrix';
[All_matrix,PS] = mapminmax('apply',all_matrix',PS);
All_matrix=All_matrix';


%��. svmѵ������(ѡ��RBF�˺���)
% 1. ʹ�ý�����֤��Ѱ����Ѳ��� c & g;
[c,g] = meshgrid(-5:0.5:5,-5:0.5:5);
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
        if  cg(i,j)==eps && bestc > 2^c(i,j)
            bestacc = cg(i,j);
            bestc = 2^c(i,j);
            bestg = 2^g(i,j);
        end               
    end
end
% 2. c g ����Ѱ�ҹ���ͼ���ʾ

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
 
% ��.svm����
[predict_label_1,accuracy_1,decision_values1] = svmpredict(train_label,Train_matrix,model); 
[predict_label_2,accuracy_2,decision_values2] = svmpredict(test_label,Test_matrix,model);
[predict_label_3,accuracy_3,decision_values3] = svmpredict(all_label,All_matrix,model);
[predict_label_4,~,~] = svmpredict(classify_label,Classify_matrix,model);    %����������

% ��.��ͼ
%1.������ά�ȸ���
figure(1)
mesh(c,g,cg)
xlabel('log2c','FontSize',10);
ylabel('log2g','FontSize',10);
grid on;
colormap([0 0 1]) % ��ɫ
%2.���ƶ�ά�ȸ���
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
legend('��ʵ���','Ԥ�����')
xlabel('���Լ��������')
ylabel('���Լ��������')
string = {'���Լ�SVMԤ�����Ա�(RBF�˺���)';
          ['accuracy = ' num2str(accuracy_3(1)) '%']};
title(string)

% ����roc����
figure(4)
plotroc(all_label',decision_values3');
string = {'���Լ�SVMԤ�����Ա�(RBF�˺���)';
          ['accuracy = ' num2str(accuracy_3(1)) '%']};
title(string)
% �����������ֵ
result=AUC(all_label',predict_label_3');
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



