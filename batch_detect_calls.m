function batch_detect_calls(audio_folder, output_folder, network)
    % make a table to keep track of files
    t = table();

    %% Get audio files and planned save names
    t.audio_names = string({dir(fullfile(audio_folder,"*.flac")).name})';
    t.audio_paths = fullfile(audio_folder, t.audio_names);
    t.mat_names = strrep(t.audio_names, ".flac", ".mat");
    t.mat_paths = fullfile(output_folder,t.mat_names);
    
    %% Check that file hasn't already been processed
    need_export = ~cellfun(@exist, t.mat_paths);
    t = t(need_export,:);
    
    %% Run detection on each file and save results in mat
    for i = 1:height(t)
        % Run detection
        detection = detect_calls(t.audio_paths(i), network);
    
        % Save detection to mat file
        save(t.mat_paths(i), '-struct', "detection")
        fprintf("Completed file %i/%i \n", i,height(t))
    end
end