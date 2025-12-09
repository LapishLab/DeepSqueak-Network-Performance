function check_low_sampling(csvPath)
    % Validate input
    if ~isfile(csvPath)
        error('CSV file not found: %s', csvPath);
    end

    % Read CSV into a table
    T = readtable(csvPath, Delimiter=",");

     T.sr = nan(height(T),1);

    for i = 1:height(T)
        audioFile = T.audio_file_path{i};
        if ~isfile(audioFile)
            warning('Invalid audio path at row %d: %s', i, audioFile);
        end
        T.sr(i) = audioinfo(audioFile).SampleRate;
    end
    writetable(T,csvPath)
end