function vary_score(truth_dir, test_dir, opts)
    arguments
        truth_dir string % Path to folder containing manually curated detection files
        test_dir string % Path to folder containing network generated detected files
        opts.min_overlap double % minimum overlap of detection boxes to be considered matching
        opts.min_duration double % minimum duration of a USV to be included in the analysis
    end

    score = 0:.05:1; 
    f1 = nan(size(score));
    recalls = f1;
    precisions = f1;

    for i = 1:length(score)
        opts.min_score = score(i);
        args = namedargs2cell(opts); %repackage to use as named arguments
        results = detection_performance(truth_dir, test_dir, args{:});
        recalls(i) = results.recall;
        precisions(i) = results.precision;
        f1(i) = results.F1;
    end
    
    clf; hold on;
    plot(score, recalls, DisplayName="Recall")
    plot(score, precisions, DisplayName="Precision")
    plot(score, f1, DisplayName="F1")
    legend()
    ylim([0 1])
    xlabel("Minimum score threshold")
    ylabel("Performance")
end