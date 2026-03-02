function output = get_confusion_from_overlap(truth_box, test_box, opts)
% calculate perfomance for single pair of truth/test detection files
    arguments
        truth_box double  % Truth boxes
        test_box double   % Test boxes
        opts.min_overlap double = 0.1 % minimum overlap of detection boxes to be considered matching
    end
    % TODO: determine best way to handle differing X & Y units impact on overlap

    overlap = calc_box_overlap(truth_box, test_box);%[truth x test] matrix
    [max_overlap, truth_ind] = max(overlap,[],1); % max overlap for each test box 
    isMatch = max_overlap>opts.min_overlap; % Does each test box have a matching truth box?

    if isempty(truth_box) % If there are no truth boxes, then none of the test boxes have matches
        isMatch = false(1, height(test_box));
    end

    TP_ind_truth = truth_ind(isMatch);% True positive: truth box index
    TP_ind_test = find(isMatch);% True positive: test box index
    FP_ind = find(~isMatch);% False positive: Index of test box with no matching truth box
    FN_ind = find(~ismember(1:height(truth_box), truth_ind(isMatch))); % False Negative: Index of truth box with no matching test box

    n_TP = length(TP_ind_truth);
    n_FP = length(FP_ind);
    n_FN = length(FN_ind);

    output = struct();
    output.recall = n_TP / (n_TP + n_FN);
    output.precision = n_TP / (n_TP + n_FP);
    output.F1 = 2 * output.precision * output.recall / (output.precision + output.recall);
    output.TP = {[TP_ind_truth ; TP_ind_test]'};
    output.FN = {FN_ind'}; 
    output.FP = {FP_ind'}; 
end