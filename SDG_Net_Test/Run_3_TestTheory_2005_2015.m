clear; clc; close all

% 载入数据（之前计算好的）
load("SDG_Results_2005.mat");
load("SDG_Results_2015.mat");

%% 计算
% 2005年的SDG增长潜力（根据SDG Space算出的）
Data_Goals_GrowthPotential_2005 = Data_Goals_SDGSpace_2005 - Data_Goals_Original_2005;
% 2005-2015年的SDG实际增长
Data_Goals_Growth_2005_2015 = Data_Goals_Original_2015 - Data_Goals_Original_2005;

% 将各省各SDG矩阵转化成列向量
SDG_GrowthPotential_2005 = Data_Goals_GrowthPotential_2005(:); % 增长潜力
SDG_Level_2005 = Data_Goals_Original_2005(:); % 2005年SDG值
SDG_Growth_2005_2015 = Data_Goals_Growth_2005_2015(:); % 实际增长（2005-2015）

%% 检验"SDG Complementarity Network"的理论：追踪增长潜力最大和最小的Goals（考虑所有地区）
K_HighValues = 21; % 所有地区增长潜力最大的Goals数量
...注：因为可能存在缺失值，上面变量取值可能略高于考虑的Goals数量
[SDG_GrowthPotential_2005_maxK,I_maxK] = maxk(SDG_GrowthPotential_2005,K_HighValues);
[temp_row,temp_col] = ind2sub(size(Data_Goals_GrowthPotential_2005),I_maxK);
SDG_Growth_2005_2015_maxK = SDG_Growth_2005_2015(I_maxK);
% 追踪所有地区增长潜力最大的Goals的Dataframe
Dataframe_HighGrowthPotential_2005 = table(temp_row, temp_col, ...
    SDG_GrowthPotential_2005_maxK, ...
    SDG_Growth_2005_2015_maxK);
% 设置Dataframe变量名称
Dataframe_HighGrowthPotential_2005.Properties.VariableNames = ...
    ["Province" "Goal" "GrowthPotential_2005" "SDG_Growth_2005_2015"];
% 删除Dataframe含缺失数据的行
Dataframe_HighGrowthPotential_2005 = rmmissing(Dataframe_HighGrowthPotential_2005);

K_LowValues = 20; % 所有地区增长潜力最小的Goals数量
...注：因为可能存在缺失值，上面变量取值可能略高于考虑的Goals数量
[SDG_GrowthPotential_2005_minK,I_minK] = mink(SDG_GrowthPotential_2005,K_LowValues);
[temp_row,temp_col] = ind2sub(size(Data_Goals_GrowthPotential_2005),I_minK);
SDG_Growth_2005_2015_minK = SDG_Growth_2005_2015(I_minK);
% 追踪所有地区增长潜力最小的Goals的Dataframe
Dataframe_LowGrowthPotential_2005 = table(temp_row, temp_col, ...
    SDG_GrowthPotential_2005_minK, ...
    SDG_Growth_2005_2015_minK);
% 设置Dataframe变量名称
Dataframe_LowGrowthPotential_2005.Properties.VariableNames = ...
    ["Province" "Goal" "GrowthPotential_2005" "SDG_Growth_2005_2015"];
% 删除Dataframe含缺失数据的行
Dataframe_LowGrowthPotential_2005 = rmmissing(Dataframe_LowGrowthPotential_2005);

% 将本节的两个Dataframe写入Excel表格
writetable(Dataframe_HighGrowthPotential_2005,"Dataframe_TopGrowthPotential_2005.xlsx", ...
    "Sheet","HighGrowthPotential_2005")
writetable(Dataframe_LowGrowthPotential_2005,"Dataframe_TopGrowthPotential_2005.xlsx", ...
    "Sheet","LowGrowthPotential_2005")

% 清除多余变量
clear temp_row temp_col

% 画图，追踪增长潜力最大和最小的Goals
Dataframe_GrowthPotential_2005 = ...
    vertcat(Dataframe_HighGrowthPotential_2005,flipud(Dataframe_LowGrowthPotential_2005));
f0 = figure;
b = bar(Dataframe_GrowthPotential_2005.GrowthPotential_2005, ...
    'FaceColor',"cyan",'EdgeColor',"none",'LineWidth',1); % 条形图
hold on
h0 = plot(Dataframe_GrowthPotential_2005.SDG_Growth_2005_2015, ...
    'Color',"k","LineWidth",1.5, ...
    'Marker',"o"); % 折线图
ylim([-50,50]) % Y轴范围
ylabel("Change in SDG Scores")
legend("Network Growth Potential in 2005","SDG Growth from 2005 to 2015")
grid on
% 将X轴的数字清楚
XTickLabel = cell(1,length(gca().XTickLabel));
for i=1:length(gca().XTickLabel)
    XTickLabel{i} = "";
end
clear i
xticklabels(XTickLabel)
% 图上加文字
dim = [.14 .1 .2 .1]; % 文本框位置
str = 'High Network Growth Potentials';
annotation('textbox',dim,'String',str,'FitBoxToText','on', ...
    'EdgeColor',"none",'BackgroundColor',"green");
dim = [.525 .1 .2 .1]; % 文本框位置
str = 'Low Network Growth Potentials';
annotation('textbox',dim,'String',str,'FitBoxToText','on', ...
    'EdgeColor',"none",'BackgroundColor',"green", ...
    'FaceAlpha',0.35);

%% 检验"SDG Complementarity Network"的理论：可解释机器学习
% 注：这部分用时较长，如果不画Partial Dependence Plot，可以注释掉

% 建立机器学习模型
rng default
Mdl = fitrensemble([SDG_GrowthPotential_2005 SDG_Level_2005],SDG_Growth_2005_2015, ...
    'OptimizeHyperparameters','auto'); % 自动选择超参数

% 画局部依赖图（Partial Dependence Plot）
f1 = figure;
h1 = plotPartialDependence(Mdl,[1 2], ...
    "UseParallel",true);
h1.XLabel.String = "SDG Growth Potential in 2005";
h1.YLabel.String = "SDG Level in 2005";
h1.ZLabel.String = "SDG Growth from 2005 to 2015";
h1.Title.String = "Partial Dependence of SDG Growth 2005-2015 " + ...
    "on Network SDG Growth Potential and SDG Level in 2005";
c1 = colorbar; % 颜色条
c1.Label.String = 'SDG Score Growth 2005-2015';

%% 检验"SDG Complementarity Network"的理论：散点图
...注：将所有地区的SDG分两部分做散点图和多元线性回归：
...增长潜力较小（小于negtive cutoff）和增长潜力较大（大于positive cutoff）

% Negtive cutoff. For robustness check, please try [-2.5, -5, -15]
Cutoff_GrowthPotential_Neg = -5;
idx_Neg = SDG_GrowthPotential_2005 < Cutoff_GrowthPotential_Neg;
SDG_GrowthPotential_2005_Neg = SDG_GrowthPotential_2005(idx_Neg);
SDG_Level_2005_Neg = SDG_Level_2005(idx_Neg);
SDG_Growth_2005_2015_Neg = SDG_Growth_2005_2015(idx_Neg);
% Posive cutoff. For robustness check, please try [2.5, 5, 15]
Cutoff_GrowthPotential_Pos = 5; 
idx_Pos = SDG_GrowthPotential_2005 > Cutoff_GrowthPotential_Pos;
SDG_GrowthPotential_2005_Pos = SDG_GrowthPotential_2005(idx_Pos);
SDG_Level_2005_Pos = SDG_Level_2005(idx_Pos);
SDG_Growth_2005_2015_Pos = SDG_Growth_2005_2015(idx_Pos);

% 散点图
f2 = figure;
tiledlayout(1,2) % Prepare to draw multiple graphs
YLimit_Scatter = [-40,40]; % Y轴范围

nexttile % 初始年增长潜力较小（小于negtive cutoff）的点
h2 = scatter(SDG_GrowthPotential_2005_Neg,SDG_Growth_2005_2015_Neg,40, ...
    'MarkerEdgeColor',[0 .5 .5], ...
    'MarkerFaceColor',[0 .7 .7], ...
    'LineWidth',1.5);
xlim([-46,Cutoff_GrowthPotential_Neg+1]) % X轴范围
ylim(YLimit_Scatter) % Y轴范围
xlabel("Growth Potential of SDGs in 2005")
ylabel("Growth of SDGs between 2005 and 2015")
hh2 = lsline; % 加回归线
hh2.Color = 'k';
hh2.LineWidth = 1.7;
hh2.LineStyle = "--";
box on % 加上边框

nexttile % 初始年增长潜力较大（大于positive cutoff）的点
h3 = scatter(SDG_GrowthPotential_2005_Pos,SDG_Growth_2005_2015_Pos,40, ...
    'MarkerEdgeColor',[0 .5 .5], ...
    'MarkerFaceColor',[0 .7 .7], ...
    'LineWidth',1.5);
xlim([Cutoff_GrowthPotential_Pos-0.75,30]) % X轴范围
ylim(YLimit_Scatter) % Y轴范围
xlabel("Growth Potential of SDGs in 2005")
% ylabel("Growth of SDGs between 2005 and 2015")
hh3 = lsline; % 加回归线
hh3.Color = 'k';
hh3.LineWidth = 1.7;
hh3.LineStyle = "--";
box on % 加上边框

%% 检验"SDG Complementarity Network"的理论：多元线性回归
% SDG_GrowthPotential_2005_Neg为负值时，预测SDG_Growth_2005_2015的多元线性回归模型
LinearModel_Neg = fitlm([SDG_GrowthPotential_2005_Neg SDG_Level_2005_Neg],SDG_Growth_2005_2015_Neg);
% SDG_GrowthPotential_2005_Pos为正值时，预测SDG_Growth_2005_2015的多元线性回归模型
LinearModel_Pos = fitlm([SDG_GrowthPotential_2005_Pos SDG_Level_2005_Pos],SDG_Growth_2005_2015_Pos);
% 展示模型结果
fprintf('———————————————————————————————————————————————————————————————————\n') % 空行
disp("For SDGs with negative network growth potentials in 2005:")
disp(LinearModel_Neg)
fprintf('\n') % 空行
fprintf('———————————————————————————————————————————————————————————————————\n') % 空行
disp("For SDGs with positive network growth potentials in 2005:")
disp(LinearModel_Pos) 