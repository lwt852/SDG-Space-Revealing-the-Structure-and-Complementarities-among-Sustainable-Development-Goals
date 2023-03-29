clear; clc; close all
tic;

%% Read original data
Data_Indicators = readmatrix("中国省级SDG数据整理SDG1-17_1.xlsx", ...
    "Sheet","2015_Indicator","Range","B4:DP34"); % For SDG indicators

Data_Goals = readmatrix("中国省级SDG数据整理SDG1-17_1.xlsx", ...
    "Sheet","2015_Goal","Range","B2:R32"); % For SDGs 不同年份直接改名称即可。如“2005_Goal"和 “2010_Goal"
province = readtable("中国省级SDG数据整理SDG1-17_1.xlsx", ...
    "Sheet","省份信息","Range","A1:E32");
% Number of indicators and regions
[n_Regions, n_Indicators] = size(Data_Indicators);
[n_Regions_Validate, n_Goals] = size(Data_Goals);

%% Save key variables
save("SDG_Data_2015.mat","n_Goals","n_Regions","n_Indicators",...
    "Data_Indicators","Data_Goals");

%% End
Time_MATLAB = toc;