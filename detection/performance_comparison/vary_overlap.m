function vary_overlap(truth_dir, test_dir, opts)
    arguments
        truth_dir string % Path to folder containing manually curated detection files
        test_dir string % Path to folder containing network generated detected files
        opts.min_duration double % minimum duration of a USV to be included in the analysis
        opts.min_score double % Score (confidence) of a USV to be included in the analysis
    end

    overlap = 0:.05:1; 
    f1 = nan(size(overlap));
    recalls = f1;
    precisions = f1;

    for i = 1:length(overlap)
        opts.min_overlap = overlap(i);
        args = namedargs2cell(opts); %repackage to use as named arguments
        results = detection_performance(truth_dir, test_dir, args{:});
        recalls(i) = results.recall;
        precisions(i) = results.precision;
        f1(i) = results.F1;
    end
    
    clf; hold on;
    plot(overlap, recalls, DisplayName="Recall")
    plot(overlap, precisions, DisplayName="Precision")
    plot(overlap, f1, DisplayName="F1")
    legend()
    ylim([0 1])
    xlabel("Minimum overlap threshold")
    ylabel("Performance")
end