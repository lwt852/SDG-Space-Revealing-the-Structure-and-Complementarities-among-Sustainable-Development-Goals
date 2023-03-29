clear; clc; close all
tic;

%% Read data
load("SDG_Data.mat");

%% Deal with contant variables and missing values
% Remove the indicator with constant values
Data_Indicators_Original = Data_Indicators; % Record the original data
Data_Indicators(:,5) = [];
% Number of used indicators
n_Indicators_Used = size(Data_Indicators,2);

% Fill the missing values with column means.
Mean_Indicators = mean(Data_Indicators,'omitnan');
Data_Indicators_Full = fillmissing(Data_Indicators,'constant',Mean_Indicators);

% Indicator Names.
Indicator_Used_Idx = 1:n_Indicators_Used; % Indices of used indicators

%% 用相关系数测算各指标间网络关系
% 构建网络矩阵
Net_Corr = corrcoef(Data_Indicators,"Rows","pairwise");
Net_Corr = Net_Corr - diag(diag(Net_Corr)); % Set diagonal elements to 0.

% Check whether missing values exist in the network
if sum(isnan(Net_Corr),"all")>0
    disp("Missing values exist in the correlation network. Please check!")
    return;
end

% 根据网络矩阵，构建图
Net_Corr_Graph = graph(Net_Corr,'omitselfloops');

%% 用RCA（Revealed Comparative Advantage）测算各指标间网络关系
shares_1 = diag( ( 1 ./ sum(Data_Indicators_Full,2) ) ) * Data_Indicators_Full;
shares_2 = sum(Data_Indicators_Full) / sum(Data_Indicators_Full,'all');
RCA = shares_1 / diag(shares_2);
RCA = RCA>1; % Revealed Comparative Advantage

% 构建网络矩阵
% Net_RCA = corrcoef(RCA);
% Net_RCA = Net_RCA - diag(diag(Net_RCA)); % Set diagonal elements to 0.

% 构建网络矩阵，根据"Product Space"方法
Net_RCA = RCA' * RCA ./ ...
max(repmat(sum(RCA),n_Indicators_Used,1),repmat(sum(RCA)',1,n_Indicators_Used));
Net_RCA = Net_RCA - diag(diag(Net_RCA)); % Set diagonal elements to 0.

% 根据网络矩阵，构建图
Net_RCA_Graph = graph(Net_RCA,'omitselfloops');

%% Figures
tiledlayout(2,2) % Prepare to draw multiple graphs
Fig_Colormap = flipud(parula); % Colormap of figures
Fig_NetLineWidth = 1; % General linewidths of the networks
Fig_NetMarker = '.'; % Node maker of the networks
Fig_NetLayout = 'force'; % Change layout of the network
Fig_IndicatorNames = repmat("",n_Indicators_Used,1); % Indicator names in the figure
Fig_HeatmapGrid = 'off'; % Heatmap grid visibility

nexttile % Heatmap for network calculated using correlation methods
h1 = heatmap(Net_Corr);
h1.Title = "Linkages from Correlation";
h1.XDisplayLabels= Fig_IndicatorNames;
h1.YDisplayLabels= Fig_IndicatorNames;
h1.Colormap = Fig_Colormap; % Change colormap
h1.ColorLimits = [-1,1]; % Change color limits
h1.GridVisible = Fig_HeatmapGrid; % Heatmap grid visibility

nexttile % Show the network
g1 = plot(Net_Corr_Graph,'Layout',Fig_NetLayout);
title("Network from Correlation")
g1.NodeLabel = Fig_IndicatorNames;
g1.Marker = Fig_NetMarker;
% Network edge widths according absolute values of edge weights 
g1.LineWidth = Fig_NetLineWidth * abs(Net_Corr_Graph.Edges.Weight);
% Network edge colors according to the values of edge weights 
temp_idx = ceil( 256 * ( (Net_Corr_Graph.Edges.Weight - (-1)) / 2 ) );
g1.EdgeColor = Fig_Colormap(temp_idx,:);

nexttile % Heatmap for network calculated using RCA
h2 = heatmap(Net_RCA);
h2.Title = "Linkages from RCA";
h2.XDisplayLabels= Fig_IndicatorNames;
h2.YDisplayLabels= Fig_IndicatorNames;
h2.Colormap = Fig_Colormap; % Change colormap
h2.ColorLimits = [-1,1]; % Change color limits
h2.GridVisible = Fig_HeatmapGrid; % Heatmap grid visibility

nexttile % Show the network
g2 = plot(Net_RCA_Graph,'Layout',Fig_NetLayout);
title("Network from RCA")
g2.NodeLabel = Fig_IndicatorNames;
g2.Marker = Fig_NetMarker;
% Network edge widths according absolute values of edge weights 
g2.LineWidth = Fig_NetLineWidth * abs(Net_RCA_Graph.Edges.Weight);
% Network edge colors according to the values of edge weights 
temp_idx = ceil( 256 * ( (Net_RCA_Graph.Edges.Weight - (-1)) / 2 ) );
g2.EdgeColor = Fig_Colormap(temp_idx,:);

% Save the figure
exportgraphics(gcf,'SDG_Net_Indicators.png','Resolution',600)

%% End
Time_MATLAB = toc; % End timing