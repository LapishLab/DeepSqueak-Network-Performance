function [score, details] = detection_performance(truth_dir, test_dir, opts)
% calculate perfomance for all detection files in truth/test folders
    arguments
        truth_dir string % Path to folder containing manually curated detection files
        test_dir string % Path to folder containing network generated detected files
        opts.min_overlap double % minimum overlap of detection boxes to be considered matching
        opts.min_duration double % minimum duration of a USV to be included in the analysis
        opts.min_score double % Score (confidence) of a USV to be included in the analysis
        opts.include_rejected logical % Should USVs marked as "rejected" be included in the analysis
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

