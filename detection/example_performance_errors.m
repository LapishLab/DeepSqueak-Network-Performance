%% Brandon vs. Anna (single file)
brandon = "/home/lapishla/Documents/GitHub/DeepSqueak-Network-Performance/detection/human_curated/Prat_Urgency/detection_files/validation";
anna = "/home/lapishla/Documents/GitHub/DeepSqueak-Network-Performance/detection/human_curated/Prat_Urgency/detection_files/validation/Anna_duplicate/";
david = "/home/lapishla/Documents/GitHub/DeepSqueak-Network-Performance/detection/human_curated/Prat_Urgency/detection_files/validation/David_duplicate/";
% [score, details] = detection_performance(anna, brandon, .0001, 0.01)
[score, details] = detection_performance(david, brandon, .0001, 0.01)

% plot_FN(details)
plot_FP(details)
% plot_TP(details)

%% Vary USV duration threshold for Brandon vs. Anna
duration = 0 : .005 : 1;
recalls = nan(size(duration));
precisions = nan(size(duration));
f1 = nan(size(duration));
for i = 1:length(duration)
    results = detection_performance(david, brandon, .0001, duration(i));
    recalls(i) = results.recall;
    precisions(i) = results.precision;
    f1(i) = results.F1;
end

figure(1); clf; hold on;
plot(duration, recalls, DisplayName="recall")
plot(duration, precisions, DisplayName="precision")
plot(duration, f1, DisplayName="F1")
legend()
ylim([0 1])
xlabel("duration (s)")


%% Vary overlap for Brandon vs. Anna
overlap = 0.01:.05:1;
recalls = nan(size(overlap));
precisions = nan(size(overlap));
f1 = nan(size(overlap));
for i = 1:length(overlap)
    results = detection_performance(anna, brandon, overlap(i));
    recalls(i) = results.recall;
    precisions(i) = results.precision;
    f1(i) = results.F1;
end

figure(1); clf; hold on;
plot(overlap, recalls, DisplayName="recall")
plot(overlap, precisions, DisplayName="precision")
plot(overlap, f1, DisplayName="F1")
legend()
ylim([0 1])
xlabel("Overlap")

%% brandon vs brandon sanity check
[results, details] = detection_performance(brandon, brandon, .1)

%% Brandon vs. sara3 network
brandon = "/home/lapishla/Documents/GitHub/DeepSqueak-Network-Performance/detection/human_curated/Prat_Urgency/detection_files/validation/";
sara3 = "/home/lapishla/Desktop/net_test/sara3/";
[results, details] = detection_performance(brandon, sara3, .3)
%% Brandon vs. Sulayman network (truitt.mat) 
truitt = "/home/lapishla/Desktop/net_test/truitt/";
[results, details] = detection_performance(brandon, truitt, .3)

