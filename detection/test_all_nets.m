
test_dir = "/home/lapishla/Desktop/test/";
% truth_file = "/home/lapishla/Documents/GitHub/DeepSqueak-Network-Performance/detection/human_curated/Prat_Urgency/detection_files/train/Anna_duplicate/20250817_121000_subject070_094.mat";
truth_file = "/home/lapishla/Documents/GitHub/DeepSqueak-Network-Performance/detection/human_curated/Prat_Urgency/detection_files/train/20250817_121000_subject070_094.mat";

test_names = {dir(test_dir+"*.mat").name};
test_files = fullfile(test_dir,test_names);


results = cell(length(test_files), 1);
for i=1:length(test_files)
    results{i} = calc_file_performance(truth_file,test_files(i), .1);
end
results = struct2table(cat(1, results{:}));
results.net = test_names';
results.F1(isnan(results.F1)) = 0;
results = sortrows(results,"F1","descend");
%%
net_name = split(results.net, "_");
net_name = string(net_name(:,end));
net_name = erase(net_name, '.mat');
bar(net_name, results.F1);
ylabel('F1 score')