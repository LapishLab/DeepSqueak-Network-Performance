function vary_duration(truth_dir, test_dir, opts)
    arguments
        truth_dir string % Path to folder containing manually curated detection files
        test_dir string % Path to folder containing network generated detected files
        opts.min_overlap double % minimum overlap of detection boxes to be considered matching
        opts.min_score double % Score (confidence) of a USV to be included in the analysis
    end

    % opts = namedargs2cell(opts); %repackage options to pass on to detection_performance function

    % duration = 0 : .005 : 1;
    duration = logspace(-3,-1,50); %logspaced from 1ms to 100ms
    f1 = nan(size(duration));
    recalls = f1;
    precisions = f1;

    for i = 1:length(duration)
        opts.min_duration = duration(i);
        args = namedargs2cell(opts); %repackage to use as named arguments
        results = detection_performance(truth_dir, test_dir, args{:});
        recalls(i) = results.recall;
        precisions(i) = results.precision;
        f1(i) = results.F1;
    end
    
    clf; hold on;
    plot(duration, recalls, DisplayName="Recall")
    plot(duration, precisions, DisplayName="Precision")
    plot(duration, f1, DisplayName="F1")
    legend()
    ylim([0 1])
    xlabel("Minimum duration threshold (s)")
    ylabel("Performance")
end