function generate_audio_links(csvPath)
    % Validate input
    if ~isfile(csvPath)
        error('CSV file not found: %s', csvPath);
    end

    % Read CSV into a table
    T = readtable(csvPath, Delimiter=",");

    % Verify required columns
    requiredCols = {'audio_file_path', 'split', 'subject'};
    missingCols = setdiff(requiredCols, T.Properties.VariableNames);
    if ~isempty(missingCols)
        error('Missing required columns: %s', strjoin(missingCols, ', '));
    end

    % Pad subject with 0 to 3 digit length
    nRows = height(T);
    T.subject = string(T.subject);
    T.subject(strlength(T.subject)<3) = pad(T.subject(strlength(T.subject)<3), 3, 'left', '0');

    % Skip files that are not assigned a split group
     skip = cellfun(@isempty, T.split);


    % Validate audio_file_path
    validPaths = isfile(T.audio_file_path);
    if any(~validPaths & ~skip)
        bad_lines = num2str(find(~validPaths));
        bad_lines = strjoin(string(bad_lines),'\n');
        error("These rows contain invalid file paths: \n%s", bad_lines)
    end

    % generate new file name by combining filename and subject #
    [~, original_name, ext] = fileparts(T.audio_file_path);
    T.link_name = compose('%s_subject%s%s', ...
        string(original_name), ...
        T.subject, ...
        string(ext) ...
        );

    new_filepath = fullfile(fileparts(csvPath), 'audio', T.split, T.link_name);

    % Create folders if necessary
    audio_folders = unique(fileparts(new_filepath(~skip)));
    for i=1:length(audio_folders)
        if ~exist(audio_folders(i), 'dir')
            mkdir(audio_folders(i));
        end
    end

    % Create symbolic links
    for i = 1:nRows
        if skip(i)
            continue;
        end
        src = T.audio_file_path{i};
        dest = new_filepath(i);
        try
            if isunix || ismac
                system(sprintf('ln -sf "%s" "%s"', src, dest));
            elseif ispc
                system(sprintf('mklink "%s" "%s"', dest, src));  % Windows uses reversed order
            else
                warning('Unsupported OS for symbolic links.');
            end
        catch
            warning('Failed to create symlink for row %d', i);
        end
    end

    % resave csv file with ID/new_audio_name
    writetable(T, csvPath); 

    fprintf('Processed %d entries. Valid paths: %d\n', nRows, sum(validPaths));
end