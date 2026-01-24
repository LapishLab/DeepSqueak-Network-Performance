clear
truth_dir = "/home/lapishla/Documents/GitHub/DeepSqueak-Network-Performance/" + ...
    "detection/human_curated/Prat_Urgency/detection_files/validation/";

test_parent = "/home/lapishla/Desktop/network_validation/";
test_names = {dir(test_parent).name};
test_names = test_names(3:end);
%
results = cell(length(test_names), 1);
for i=1:length(test_names)
    test = fullfile(test_parent, test_names{i});
    r = detection_performance(truth_dir, test);
    r.net = test_names{i};
    results{i} = r;
end
results = struct2table(cat(1, results{:}));
results.F1(isnan(results.F1)) = 0;
results = sortrows(results,"F1","descend");
%
x = categorical(results.net);
x = reordercats(x,results.net);
subplot(3,1,1)
bar(x, results.recall);
ylim([0 1])
ylabel('Recall')
subplot(3,1,2)
bar(x, results.precision);
ylim([0 1])
ylabel('Precision')
subplot(3,1,3)
bar(x, results.F1);
ylim([0 1])
ylabel('F1 score')