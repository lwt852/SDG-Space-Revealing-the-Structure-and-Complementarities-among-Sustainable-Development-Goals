clear; clc; close all
tic;
%compare the network stability between years
net_corr_2015 = csvread('net_corr_goal.csv',0,0)
net_corr_2010=csvread('net_corr_goal2010.csv',0,0)
net_corr_2005=csvread('net_corr_goal2005.csv',0,0)
net_rca_2015=csvread('net_rca_goal.csv',0,0)
net_rca_2010=csvread('net_rca_goal2010.csv',0,0)
net_rca_2005=csvread('net_rca_goal2005.csv',0,0)

%between 2010 and 2005 and 2015

corr0510 = norm(net_corr_2005-net_corr_2010)
norm_05=norm(net_corr_2005)

corr1015_per= (norm(net_corr_2010-net_corr_2015))./(norm(net_corr_2015))
corr0515_per= (norm(net_corr_2005-net_corr_2015))./(norm(net_corr_2015))
rca1015_per= (norm(net_rca_2010-net_rca_2015))./(norm(net_rca_2015))
rca0515_per= (norm(net_rca_2005-net_rca_2015))./(norm(net_rca_2015))
%%              1015   0515
%%corr_per    0.3125  0.7114
%%rca_per     0.1718   0.1801

%compare the stability between groups in 2015
net_corr_poor=csvread('net_corr_goal_poor.csv',0,0)
net_corr_rich=csvread('net_corr_goal_developed.csv',0,0)
net_rca_poor=csvread('net_rca_goal_poor.csv',0,0)
net_rca_rich=csvread('net_rca_goal_developed.csv',0,0)

corr = norm(net_corr_poor-net_corr_2015)
norm_test=norm(net_corr_2015)
test=corr./norm_test
corr_poor_per = (norm(net_corr_poor - net_corr_2015))./(norm(net_corr_2015))
corr_rich_per = (norm(net_corr_rich-net_corr_2015))./(norm(net_corr_2015))
rca_poor_per = (norm(net_rca_poor-net_rca_2015))./(norm(net_rca_2015))
rca_rich_per = (norm(net_rca_rich-net_rca_2015))./(norm(net_rca_2015))

%%              poor   rich
%%corr_per      1.2546  1.1852
%%rca_per       0.3207   0.4602
