clear; clc; close all
tic;

%% Read data
load("SDG_Data_2005.mat");

% 生成随机的SDG评价指标，有真实数据后替换！
% Data_Goals = rand(size(Data_Goals));

%% Deal with contant variables and missing values
% Fill the missing values with column means
Mean_Goals = mean(Data_Goals,'omitnan');
Data_Goals_Full = fillmissing(Data_Goals,'constant',Mean_Goals);

% Choose the regions used to compute the network (in the bracket)
% developed 
% Idx_RegionsUsed = [19 10 15 11 16 23];
% poor province
% Idx_RegionsUsed = [26 29 30 21 28 31];
% Data_Goals_Full = Data_Goals_Full(Idx_RegionsUsed,:);
% Data_Goals = Data_Goals(Idx_RegionsUsed,:);

Data_Goals_Original_2005 = Data_Goals; % Original data with missing values
Data_Goals = fillmissing(Data_Goals,'constant',0); % Fill the missing values

%% 用相关系数测算各指标间网络关系
% 构建网络矩阵
Net_Corr = corrcoef(Data_Goals,"Rows","pairwise");
Net_Corr = Net_Corr - diag(diag(Net_Corr)); % Set diagonal elements to 0.

% Check whether missing values exist in the network
if sum(isnan(Net_Corr),"all")>0
    disp("Missing values exist in the correlation network. Please check!")
    return;
end

% 根据网络矩阵，构建图
Net_Corr_Graph = graph(Net_Corr,'omitselfloops');

%% 用RCA（Revealed Comparative Advantage）测算各指标间网络关系
shares_1 = diag( ( 1 ./ sum(Data_Goals_Full,2) ) ) * Data_Goals_Full;
shares_2 = sum(Data_Goals_Full) / sum(Data_Goals_Full,'all');
RCA = shares_1 / diag(shares_2);
RCA = RCA>1; % Revealed Comparative Advantage

% 构建网络矩阵
% Net_RCA = corrcoef(RCA);
% Net_RCA = Net_RCA - diag(diag(Net_RCA)); % Set diagonal elements to 0

% 构建网络矩阵，根据"Product Space"方法
Net_RCA = RCA' * RCA ./ ...
max(repmat(sum(RCA),n_Goals,1),repmat(sum(RCA)',1,n_Goals));
Net_RCA = Net_RCA - diag(diag(Net_RCA)); % Set diagonal elements to 0

% 根据网络矩阵，构建图
Net_RCA_Graph = graph(Net_RCA,'omitselfloops');

%% 计算初始年（2005年）的网络密度（新内容）
Cutoff_Net = 0.5; % Network cutoff. 可以根据文章内容改变
Net_RCA_2005 = Net_RCA;
Net_RCA_2005(Net_RCA_2005<Cutoff_Net) = 0;
Net_RCA_Weights_2005 = Net_RCA_2005 / diag( sum(Net_RCA_2005) );
% 对于每个地区每个Goal，计算网络中相连Goal的加权平均
Data_Goals_SDGSpace_2005 = Data_Goals_Full * Net_RCA_Weights_2005;

%% 保存文件
save("SDG_Results_2005.mat","Data_Goals_Original_2005", "Data_Goals_SDGSpace_2005", ...
    "Net_RCA_2005", "Net_RCA_Weights_2005")

%% Figures
% tiledlayout(2,2) % Prepare to draw multiple graphs
% Fig_Colormap = flipud(parula); % Colormap of figures
% Fig_NetLineWidth = 1; % General linewidths of the networks
% Fig_NetMarker = '.'; % Node maker of the networks
% Fig_NetLayout = 'force'; % Change layout of the network
% Fig_IndicatorNames = 1:n_Goals; % Indicator names in the figure
% Fig_HeatmapGrid = 'off'; % Heatmap grid visibility
% 
% nexttile % Heatmap for network calculated using correlation methods
% h1 = heatmap(Net_Corr);
% h1.Title = "Linkages from Correlation";
% h1.XDisplayLabels= Fig_IndicatorNames;
% h1.YDisplayLabels= Fig_IndicatorNames;
% h1.Colormap = Fig_Colormap; % Change colormap
% h1.ColorLimits = [-1,1]; % Change color limits
% h1.GridVisible = Fig_HeatmapGrid; % Heatmap grid visibility
% 
% nexttile % Show the network
% g1 = plot(Net_Corr_Graph,'Layout',Fig_NetLayout);
% title("Network from Correlation")
% g1.NodeLabel = Fig_IndicatorNames;
% g1.Marker = Fig_NetMarker;
% % Network edge widths according absolute values of edge weights 
% g1.LineWidth = Fig_NetLineWidth * abs(Net_Corr_Graph.Edges.Weight);
% % Network edge colors according to the values of edge weights 
% temp_idx = ceil( 256 * ( (Net_Corr_Graph.Edges.Weight - (-1)) / 2 ) );
% g1.EdgeColor = Fig_Colormap(temp_idx,:);
% 
% nexttile % Heatmap for network calculated using RCA
% h2 = heatmap(Net_RCA);
% h2.Title = "Linkages from RCA";
% h2.XDisplayLabels= Fig_IndicatorNames;
% h2.YDisplayLabels= Fig_IndicatorNames;
% h2.Colormap = Fig_Colormap; % Change colormap
% h2.ColorLimits = [-1,1]; % Change color limits
% h2.GridVisible = Fig_HeatmapGrid; % Heatmap grid visibility
% 
% nexttile % Show the network
% g2 = plot(Net_RCA_Graph,'Layout',Fig_NetLayout);
% title("Network from RCA")
% g2.NodeLabel = Fig_IndicatorNames;
% g2.Marker = Fig_NetMarker;
% % Network edge widths according absolute values of edge weights 
% g2.LineWidth = Fig_NetLineWidth * abs(Net_RCA_Graph.Edges.Weight);
% % Network edge colors according to the values of edge weights 
% temp_idx = ceil( 256 * ( (Net_RCA_Graph.Edges.Weight - (-1)) / 2 ) );
% g2.EdgeColor = Fig_Colormap(temp_idx,:);
% 
% % Save the figure
% exportgraphics(gcf,'SDG_Net_SDGs.png','Resolution',600)

%% End
Time_MATLAB = toc; % End timing