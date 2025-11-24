function [score, details] = detection_performance(truth_dir, test_dir, threshold)
% calculate perfomance for all detection files in truth/test folders
    arguments
        truth_dir string % Path to folder containing manually curated detection files
        test_dir string % Path to folder containing network generated detected files
        threshold double = 0.5 % Required overlap of detection boxes to be considered matching
    end
    f = find_matching_detection_files(truth_dir, test_dir);
    
    % get performance for each file
    details = cell(height(f), 1);
    for i=1:height(f)
        details{i} = calc_file_performance(f.truth_file(i), f.test_file(i), threshold);
    end
    details = struct2table([details{:}], AsArray=true); % unpack cell array of structs and convert to table
    details = cat(2, details, f); % add filenames

    % calculate final score
    score = struct();
    score.TP = sum(cellfun(@height, details.TP));% total true positive
    score.FN = sum(cellfun(@height, details.FN));% total false negative
    score.FP = sum(cellfun(@height, details.FP));% total false positive
    score.recall = score.TP / (score.TP + score.FN);
    score.precision = score.TP / (score.TP + score.FP);
    score.F1 = 2*score.precision*score.recall/(score.precision+score.recall);
end

function s = calc_file_performance(truth_file,test_file, threshold)
% calculate perfomance for single pair of truth/test detection files
    arguments
        truth_file string % Path to manually curated detection file
        test_file string  % Path to network generated detected file
        threshold double = 0.5 % Required overlap of detection boxes to be considered matching
    end
    truth_boxes = load_boxes(truth_file);
    test_boxes = load_boxes(test_file);

    overlap = calc_box_overlap(truth_boxes, test_boxes);%[truth x test] matrix
    [max_overlap, truth_ind] = max(overlap); % max overlap for each test box 
    isMatch = max_overlap>threshold; % Does each test box have a matching truth box?

    TP_ind_truth = truth_ind(isMatch);% True positive: truth box index
    TP_ind_test = find(isMatch);% True positive: test box index
    FP_ind = find(~isMatch);% False positive: Index of test box with no matching truth box
    FN_ind = find(~ismember(1:length(truth_boxes), truth_ind(isMatch))); % False Negative: Index of truth box with no matching test box

    n_TP = length(TP_ind_truth);
    n_FP = length(FP_ind);
    n_FN = length(FN_ind);

    s = struct();
    s.recall = n_TP / (n_TP + n_FN);
    s.precision = n_TP / (n_TP + n_FP);
    s.F1 = 2 * s.precision * s.recall / (s.precision + s.recall);
    s.TP = {[TP_ind_truth ; TP_ind_test]'};
    s.FN = {FN_ind'}; 
    s.FP = {FP_ind'}; 
end

function overlap_percentage = calc_box_overlap(A, B)
% calculate the percent overlap of detection boxes
    overlap_area = rectint(A, B);
    A_area = A(:,3) .* A(:,4);
    B_area = B(:,3) .* B(:,4);
    total_area = A_area + B_area' - overlap_area;
    overlap_percentage = overlap_area ./ total_area; 
end

function boxes = load_boxes(path)
    s = load(path);
    boxes = s.Calls.Box;
end

function matches = find_matching_detection_files(truth, test)
% Find test file that starts with the same name as the truth file
    truth_files = string({dir(truth + filesep + "*.mat").name})';
    test_files = string({dir(test + filesep + "*.mat").name})';

    matches = table();
    matches.truth_file = truth + filesep + truth_files;
    for i = 1:length(truth_files)
        pattern = extractBefore(truth_files(i), '.mat');
        is_match = contains(test_files, pattern);
        if sum(is_match)==1
            matches.test_file(i)=test + filesep + test_files(is_match);
        elseif sum(is_match)>1
            warning("Multiple test files found for " + pattern)
        elseif sum(is_match)<1
            warning("No test file found for " + pattern)
        end 
    end
    matches = rmmissing(matches); % remove rows without matches
end

