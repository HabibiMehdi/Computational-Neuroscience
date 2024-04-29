
clear;
clc;
close all;

load('D:\spike\Simulator\C_Easy1_noise035.mat')

figure(1)
plot(data)
title('Raw-data')

%pwelch(data,[],[],[],4000);
%%
order = 3;
cut_off = 500;
fs = 2000;

[b,a] = butter(order,cut_off/(fs/2),'high');
data_filter = filtfilt(b,a,data);

figure(2)
plot(data_filter);
title('data-filtered')
hold on 

%spike detection
Sig = median(abs(data_filter)/0.6745);
plot(ones(length(data_filter),1)*5*Sig,'k','LineWidth',2)


%%
temp = data_filter ;
temp(data_filter< 5*Sig) = 0;
[spike,spike_inx] = findpeaks(temp,"MinPeakDistance",20);

%% spike sorting
num_spike = length(spike_inx);
num_forward = 20;
num_backward = 12;

spike_curves = zeros(num_spike ,num_forward+num_backward +1 );

for i=1:num_spike
    spike_curves(i,:) = data_filter(spike_inx(i)-num_backward :spike_inx(i)+num_forward );
end
% polt all spikes with each other
figure 
hold on
for i=1:num_spike
    plot(spike_curves(i,:),'k')
end

%% feature extraction for spike

spike_feature = zeros(num_spike , 2);
for i=1:num_spike
    spike_feature(i,1) = findpeaks(spike_curves(i,:),"NPeaks",1);
    spike_feature(i,2) = sum(abs(spike_curves(i,:)));
   
end

figure 
 scatter(spike_feature(:,1),spike_feature(:,2))

 %% clustering with k-means

[idx,C] = kmeans(spike_feature,2,'Distance','cityblock');



hold on
scatter(spike_feature(idx==1,1),spike_feature(idx==1,2))
scatter(spike_feature(idx==2,1),spike_feature(idx==2,2))

%% spike plot with labels
figure 
hold on

for i=1:num_spike
    if idx==1
        plot(spike_curves(i,:),'k')
    elseif idx==2
        plot(spike_curves(i,:),'r')
    end

end