function plot_FP(details)
    for r=1:height(details)
        target_ind = details.FP{r};

        [~,name] = fileparts(details.truth_file(r));
        fprintf("Plotting %i False Positives for %s \n", height(target_ind), name)
        
        truth_boxes = load(details.truth_file(r)).Calls.Box;
        test_boxes = load(details.test_file(r)).Calls.Box;
        audio_file = load(details.truth_file(r)).audiodata.Filename;
        
        for i=1:height(target_ind)
            target_box = test_boxes(target_ind(i), :);
            other_boxes = truth_boxes;
            plot_box_instance(target_box, other_boxes, audio_file)
        end
    end
end