function filter_all_csv(csvPath)
    % Validate input
    if ~isfile(csvPath)
        error('CSV file not found: %s', csvPath);
    end

    % Read CSV into a table
    T = readtable(csvPath, Delimiter=",");

    [folder,name,~]=fileparts(T.audio_file_path);
    new_names = fullfile(folder,name+"_whitened.flac");

    for i = 1:height(T)
        audioFile = T.audio_file_path{i};
        if ~isfile(audioFile)
            warning('Invalid audio path at row %d: %s', i, audioFile);
            continue
        end

        if ~exist(new_names(i),'file')
            whiten_and_resave(audioFile, new_names(i));
        end
        T.whitened_path{i} = new_names(i);
        disp(i)
        % title(num2str(i))
        % pause(0.1)
        writetable(T,csvPath)
    end
end