function s = calc_file_performance(truth_file, test_file, opts)
% calculate perfomance for single pair of truth/test detection files
    arguments
        truth_file string = "anna" % Path to manually curated detection file
        test_file string = "brandon" % Path to network generated detected file
        opts.min_overlap double = 0.1 % minimum overlap of detection boxes to be considered matching
        opts.min_duration double = .005 % minimum duration of a USV to be included in the analysis
        opts.min_score double = 0.5 % Score (confidence) of a USV to be included in the analysis
        opts.include_rejected logical = false; % Should USVs marked as "rejected" be included in the analysis
    end

    %% load calls
    truth = load(truth_file);
    test = load(test_file);

    %% filter calls
    truth = filter_calls(truth, min_duration=opts.min_duration, min_score=opts.min_score, include_rejected=opts.include_rejected);
    test = filter_calls(test, min_duration=opts.min_duration, min_score=opts.min_score, include_rejected=opts.include_rejected);

    truth_box = truth.Calls.Box;
    test_box = test.Calls.Box;
    %% calculator overlap
    overlap = calc_box_overlap(truth_box, test_box);%[truth x test] matrix
    [max_overlap, truth_ind] = max(overlap); % max overlap for each test box 
    isMatch = max_overlap>opts.min_overlap; % Does each test box have a matching truth box?

    TP_ind_truth = truth_ind(isMatch);% True positive: truth box index
    TP_ind_test = find(isMatch);% True positive: test box index
    FP_ind = find(~isMatch);% False positive: Index of test box with no matching truth box
    FN_ind = find(~ismember(1:height(truth_box), truth_ind(isMatch))); % False Negative: Index of truth box with no matching test box

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



