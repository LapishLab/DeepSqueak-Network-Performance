function s = calc_file_performance(truth_file,test_file, overlap_threshold, duration_threshold)
% calculate perfomance for single pair of truth/test detection files
    arguments
        truth_file string = "anna" % Path to manually curated detection file
        test_file string = "brandon" % Path to network generated detected file
        overlap_threshold double = 0.5 % Required overlap of detection boxes to be considered matching
        duration_threshold double = .008 % Required duration of a USV to be included in the analysis
    end
    truth_boxes = load_boxes(truth_file);
    test_boxes = load_boxes(test_file);

    %% remove too short USVs
    is_short = truth_boxes(:,3) < duration_threshold;
    truth_boxes(is_short, :) = [];

    is_short = test_boxes(:,3) < duration_threshold;
    test_boxes(is_short, :) = [];

    %% calculator overlap
    overlap = calc_box_overlap(truth_boxes, test_boxes);%[truth x test] matrix
    [max_overlap, truth_ind] = max(overlap); % max overlap for each test box 
    isMatch = max_overlap>overlap_threshold; % Does each test box have a matching truth box?

    TP_ind_truth = truth_ind(isMatch);% True positive: truth box index
    TP_ind_test = find(isMatch);% True positive: test box index
    FP_ind = find(~isMatch);% False positive: Index of test box with no matching truth box
    FN_ind = find(~ismember(1:height(truth_boxes), truth_ind(isMatch))); % False Negative: Index of truth box with no matching test box

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
