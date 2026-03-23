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
    audio_paths = t.audio_paths;
    mat_paths = t.mat_paths;
    n=height(t);
    % for i=1:n
    parfor (i = 1:n, 8) % Run in parallel with 8 workers
        % Run detection
        detection = detect_calls(audio_paths(i), network);
    
        % Save detection to mat file
        save(mat_paths(i), '-fromstruct', detection)
        fprintf("Completed file %i/%i \n", i,n)
    end
end