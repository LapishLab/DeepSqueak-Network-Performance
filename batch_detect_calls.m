function batch_detect_calls(audio_folder, output_folder, network)
    %% Get path to all audio files
    fnames = {dir(fullfile(audio_folder,"*.flac")).name};
    audio_files = fullfile(audio_folder, fnames)';
    for i = 1:length(fnames)
        % Run detection
        detection = detect_calls(audio_files(i), network);
    
        % Save detection to mat file
        [~,subname,~] = fileparts(audio_files(i));
        file_path = fullfile(output_folder, subname+".mat");
        save(file_path, '-struct', "detection")
        fprintf("Completed file %i/%i \n", i,length(fnames))
    end
end