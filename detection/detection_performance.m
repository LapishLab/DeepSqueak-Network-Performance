function [score, details] = detection_performance(truth_dir, test_dir, opts)
% calculate perfomance for all detection files in truth/test folders
    arguments
        truth_dir string % Path to folder containing manually curated detection files
        test_dir string % Path to folder containing network generated detected files
        opts.min_overlap double % minimum overlap of detection boxes to be considered matching
        opts.min_duration double % minimum duration of a USV to be included in the analysis
        opts.min_score double % Score (confidence) of a USV to be included in the analysis
    end
    f = find_matching_detection_files(truth_dir, test_dir);
    
    % get performance for each file
    details = cell(height(f), 1);
    opts = namedargs2cell(opts);
    for i=1:height(f)
        details{i} = calc_file_performance(f.truth_file(i), f.test_file(i), opts{:});
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


function matches = find_matching_detection_files(truth, test)
% Find test file that starts with the same name as the truth file
    truth_files = string({dir(truth + filesep + "*.mat").name})';
    test_files = string({dir(test + filesep + "*.mat").name})';
    test_files = extractBefore(test_files, '.mat');

    num_truth = length(truth_files);
    matches = strings(num_truth,2);
    match_found = false(num_truth,1);
    for i = 1:num_truth
        pattern = extractBefore(truth_files(i), '.mat');
        is_match = strcmp(test_files, pattern);
        if sum(is_match)==1
            matches(i,1) = truth + filesep + truth_files(i);
            matches(i,2) = test  + filesep + test_files(is_match);
            match_found(i) = true;
        elseif sum(is_match)>1
            warning("Multiple test files found for " + pattern)
        % elseif sum(is_match)<1
        %     warning("No test file found for " + pattern)
        end 
    end

    matches = matches(match_found,:);
    if isempty(matches)
        error("No matching files found in this folder")
    end
    matches = table(matches(:,1), matches(:,2), VariableNames=["truth_file","test_file"]);
end