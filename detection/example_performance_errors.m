%% Brandon vs. Anna (single file)
brandon = "/home/lapishla/Documents/GitHub/DeepSqueak-Network-Performance/detection/human_curated/Prat_Urgency/detection_files/validation";
anna = "/home/lapishla/Documents/GitHub/DeepSqueak-Network-Performance/detection/human_curated/Prat_Urgency/detection_files/validation/Anna_duplicate/";
david = "/home/lapishla/Documents/GitHub/DeepSqueak-Network-Performance/detection/human_curated/Prat_Urgency/detection_files/validation/David_duplicate/";

mouseR2 = "/home/lapishla/Desktop/network_validation/mouse_R2/";
sara = "/home/lapishla/Desktop/network_validation/sara/";
train1 ="/home/lapishla/Desktop/network_validation/train1/";

test = mouseR2;

[score, details] = detection_performance(brandon, test)
%
% plot_FN(details)
% plot_FP(details)
% plot_TP(details)

% Test various thresholds
figure(2); clf
vary_duration(brandon,test)

figure(3); clf
vary_overlap(brandon,test)

figure(4); clf
vary_score(brandon,test)