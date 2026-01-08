function plot_FN(details)
    for r=1:height(details)
        target_ind = details.FN{r};

        [~,name] = fileparts(details.truth_file(r));
        fprintf("Plotting %i False Negatives for %s \n", height(target_ind), name)
        
        truth = load(details.truth_file(r)).Calls;
        test = load(details.test_file(r)).Calls;
        test.index = (1:height(test))';
        audio_file = load(details.truth_file(r)).audiodata.Filename;
        
        for i=1:height(target_ind)
            missed_truth = truth(target_ind(i), :);
            
            test.overlap = calc_box_overlap(test.Box, missed_truth.Box);
            
            overlapping_test = test(test.overlap>0,:);

            fprintf("  Missed USV index: %i\n", target_ind(i))
            if ~isempty(overlapping_test)
                fprintf("    Overlapping test boxes\n")
                disp(overlapping_test)
            else
                fprintf("   No overlapping test boxes.\n");
            end

            plot_box_instance(missed_truth.Box, overlapping_test.Box, audio_file)

        end
    end
end