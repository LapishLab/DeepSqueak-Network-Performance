function combine_labels(usv_dir, noise_dir)
f = find_matching_detection_files(usv_dir, noise_dir);
for i=1:height(f)
    %% Load real USV and labeled noise calls
    usv_filename = f.truth_file(i);
    noise_filename = f.test_file(i);

    usvs = load(usv_filename);
    noises = load(noise_filename);

    usv_calls = usvs.Calls;
    noise_calls = noises.Calls;

    %% Restrict noise calls to labels starting with "noise"
    is_noise = startsWith(string(noise_calls.Type), "noise");
    noise_calls = noise_calls(is_noise, :);

    %% Only keep noise calls that don't overlap with real USV
    overlap = calc_box_overlap(noise_calls.Box, usv_calls.Box);

    % Optional plotting to see what noise overlaps with real USV
    plot_overlapping = false;
    if plot_overlapping
        [noise_ind, usv_ind] = find(overlap>0);
        for ii=1:length(noise_ind)
            noise_box = noise_calls.Box(noise_ind(ii),:);
            usv_box = usv_calls.Box(usv_ind(ii), :);
            disp(noise_calls.Type(noise_ind(ii)))
            plot_box_instance(usv_box, noise_box,  usvs.audiodata.Filename);
            
        end
    end
    noise_calls = noise_calls(~any(overlap>0, 2),:);

    %% Insert Noise calls into real USV file
    combined_calls = cat(1, usv_calls, noise_calls);

    % Sort by start time
    start_times = combined_calls.Box(:,1);
    [~,sort_ind] = sort(start_times);
    combined_calls = combined_calls(sort_ind, :);

    % Resave mat file
    usvs.Calls = combined_calls;
    save(usv_filename, '-struct', "usvs")
end
end