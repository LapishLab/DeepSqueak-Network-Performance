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
            matches(i,2) = test  + filesep + test_files(is_match) + ".mat";
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