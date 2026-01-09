function plot_FP(details)
    for r=1:height(details)
        target_ind = details.FP{r};

        [~,name] = fileparts(details.truth_file(r));
        fprintf("Plotting %i False Positives for %s \n", height(target_ind), name)

        truth = load(details.truth_file(r)).Calls;
        test = load(details.test_file(r)).Calls;
        test.index = (1:height(test))';
        audio_file = load(details.truth_file(r)).audiodata.Filename;
        
        for i=1:height(target_ind)
            % target_box = test_boxes(target_ind(i), :);
            % other_boxes = truth_boxes;
            % plot_box_instance(target_box, other_boxes, audio_file)




            bad_test = test(target_ind(i), :);
            
            truth.overlap = calc_box_overlap(truth.Box, bad_test.Box);
            
            overlapping_truth = truth(truth.overlap>0,:);

            fprintf("  False positive at index: %i\n", target_ind(i))
            disp(bad_test)
            if ~isempty(overlapping_truth)
                fprintf("    Overlapping truth boxes\n")
                disp(overlapping_truth)
            else
                fprintf("   No overlapping truth boxes.\n");
            end

            plot_box_instance(bad_test.Box, overlapping_truth.Box, audio_file)
        end
    end
end