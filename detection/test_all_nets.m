% clear
% truth_dir = "/home/lapishla/Documents/GitHub/DeepSqueak-Network-Performance/" + ...
%     "detection/human_curated/Prat_Urgency/detection_files/validation/";
% % truth_dir = truth_dir + "Anna_duplicate/";
% truth_file = truth_dir + "20250817_121000_whitened_subject070_094.mat";
% 
% test_dir = "/home/lapishla/Desktop/network_test/all_networks_single_file/";
% test_names = {dir(test_dir+"*.mat").name};
% test_names = fullfile(test_dir,test_names);
% 
% results = cell(length(test_names), 1);
% for i=1:length(test_names)
%     results{i} = calc_file_performance(truth_file,test_names(i), .1);
% end
% results = struct2table(cat(1, results{:}));
% results.net = test_names';
% results.F1(isnan(results.F1)) = 0;
% results = sortrows(results,"F1","descend");
% %
% net_name = split(results.net, "_");
% net_name = string(net_name(:,end));
% net_name = erase(net_name, '.mat');
% bar(net_name, results.F1);
% ylabel('F1 score')

%%
clear
truth_dir = "/home/lapishla/Documents/GitHub/DeepSqueak-Network-Performance/" + ...
    "detection/human_curated/Prat_Urgency/detection_files/validation/";

test_parent = "/home/lapishla/Desktop/network_test/full/";
test_names = {dir(test_parent).name};
test_names = test_names(3:end);
%
results = cell(length(test_names), 1);
for i=1:length(test_names)
    test = fullfile(test_parent, test_names{i});
    results{i} = detection_performance(truth_dir, test, overlap_threshold=.1);
end
results = struct2table(cat(1, results{:}));
results.net = test_names';
results.F1(isnan(results.F1)) = 0;
results = sortrows(results,"F1","descend");
%
subplot(3,1,1)
bar(test_names, results.recall);
ylabel('Recall')
subplot(3,1,2)
bar(test_names, results.precision);
ylabel('Precision')
subplot(3,1,3)
bar(test_names, results.F1);
ylabel('F1 score')