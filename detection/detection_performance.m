function performance = detection_performance(truth_dir, test_dir, threshold)
% calculate perfomance for all detection files in truth/test folders
    arguments
        truth_dir string % Path to folder containing manually curated detection files
        test_dir string % Path to folder containing network generated detected files
        threshold double = 0.5 % Required overlap of detection boxes to be considered matching
    end
    f = find_matching_detection_files(truth_dir, test_dir);
    performance = table();
    for i=1:height(f)
        s = calc_file_performance(f.truth_file(i), f.test_file(i), threshold);
        performance(i,:) =  struct2table(s);
    end
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

    overlap = calc_box_overlap(truth_boxes, test_boxes);
    isMatch = overlap>threshold;
    
    s = struct();
    s.truth_file = truth_file;
    s.test_file = test_file;
    s.TP = sum(any(isMatch,2)); % True positive is row (truth) with matching column (test)
    s.FN = sum(~any(isMatch,2)); % False negative is row (truth) with no matching column (test)
    s.FP = sum(~any(isMatch,1)); % False positive is column (test) with now matching row (truth)
    s.precision = s.TP / (s.TP + s.FP);
    s.recall = s.TP / (s.TP + s.FN);
    s.F1 = 2 * s.precision * s.recall / (s.precision + s.recall);
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

