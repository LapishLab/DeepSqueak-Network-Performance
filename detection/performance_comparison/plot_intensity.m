function plot_intensity(details)
    TP_int = cell(height(details),2);
    FP_int = cell(height(details),1);
    FN_int = cell(height(details),1);

    for i=1:height(details)
        truth = load(details.truth_file(i));
        truth_int = calculate_intensity(truth.Calls, truth.audiodata);

        test = load(details.test_file(i));
        test_int = calculate_intensity(test.Calls, test.audiodata);

        % Get true positives
        if ~isempty(details.TP{i})
            TP_int{i,1} = truth_int(details.TP{i}(:,1));
            TP_int{i,2} = test_int(details.TP{i}(:,2));
        end

        if ~isempty(details.FP{i})
            FP_int{i} = test_int(details.FP{i});
        end
        if ~isempty(details.FN{i})
            FN_int{i} = truth_int(details.FN{i});
        end

    end

    m = cellfun(@max, cat(2,TP_int,FP_int,FN_int), 'UniformOutput', false);
    m = max([m{:}]);
    edges = linspace(0,m,200);

    subplot(3,1,1)
    histogram(cell2mat(TP_int), edges)
    ylabel('TP')
    subplot(3,1,2)
    histogram(cell2mat(FP_int), edges)
    ylabel('FP')
    subplot(3,1,3)
    histogram(cell2mat(FN_int), edges)
    ylabel('FN')
    xlabel('RMS Intensity');
end