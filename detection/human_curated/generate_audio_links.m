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

    % Validate audio_file_path entries and pad subject
    nRows = height(T);
    T.subject = string(T.subject);
    T.subject(strlength(T.subject)<3) = pad(T.subject(strlength(T.subject)<3), 3, 'left', '0');

    validPaths = true(nRows, 1);
    ids = strings(nRows, 1);

    for i = 1:nRows
        audioFile = T.audio_file_path{i};
        if ~isfile(audioFile)
            warning('Invalid audio path at row %d: %s', i, audioFile);
            validPaths(i) = false;
        end
        [~, name, ~] = fileparts(audioFile);
        ids(i) = sprintf('%s_subject%s', name, T.subject(i));
    end

    T.id = ids;

    % Create output directories
    baseDir = fileparts(csvPath);
    audioDir = fullfile(baseDir, 'audio');
    detectDir = fullfile(baseDir, 'detection_files');
    subDirs = unique(T.split)';

    for d = {audioDir, detectDir}
        for s = subDirs
            targetDir = fullfile(d{1}, s{1});
            if ~exist(targetDir, 'dir')
                mkdir(targetDir);
            end
        end
    end

    % Create symbolic links
    for i = 1:nRows
        if ~validPaths(i)
            continue;
        end
        src = T.audio_file_path{i};
        dest = fullfile(audioDir, T.split{i}, T.id(i)+".wav");
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

    fprintf('Processed %d entries. Valid paths: %d\n', nRows, sum(validPaths));
end