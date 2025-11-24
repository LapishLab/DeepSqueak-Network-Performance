function validate_detection_files(path)
    if exist(path, 'file')
        validate_detection_file(path)
    elseif exist(path, 'dir')
        matfiles = {dir(fullfile(path, "*.mat")).name}';
        if isempty(matfiles)
            warning('No .mat files found in the specified folder.');
        end
        for i=1:length(matfiles)
            path = fullfile(path, matfiles{i});
            fprintf("validating %s \n",matfiles{i})
            validate_detection_file(path);
        end
    else
        error("Path is not a valid directory or file")
    end
end

function validate_detection_file(filepath)
    mat_changed = false;
    d = load(filepath);
    
    % Does the mat file have detection data
    if ~isfield(d, 'Calls') || ~isfield(d, 'audiodata')
        warning('The loaded .mat file %s does not a valid detection file', filepath);
    end
    
    % Does the audio file exist at the path saved in the mat file
    if ~exist(d.audiodata.Filename, "file")
        warning('The audio file %s referenced in the detection file does not exist.', d.audiodata.Filename);
    
        % % temporary - do something more robust in the future
        % audio_folder = "/home/lapishla/Documents/GitHub/DeepSqueak-Network-Performance/detection/human_curated/Prat_Urgency/audio/train/";
        % [~, audio_name, ~] = fileparts(d.audiodata.Filename);
        % d.audiodata.Filename = audio_folder + audio_name + ".wav";
        % mat_changed = true;
    end
    
    % Does the audio file lname match the detection file name
    [~, detection_name, ~] = fileparts(filepath);
    [~, audio_name, ~] = fileparts(d.audiodata.Filename);
    if detection_name ~= audio_name
        warning('The detection file name %s does not match the audio file name %s.', detection_name, audio_name);
    end
    
    
    boxes = d.Calls.Box;
    
    dur = boxes(:,3);
    
    % Does the duration = 0
    zero_duration = find(dur == 0);
    if zero_duration
        warning('The following call boxes have 0 time; %s', mat2str(zero_duration))
    end
    
    % Is the duration too short
    min_time = 5e-3; % 8 ms is ~5 pixels with default settings
    short_duration = find(dur>0 & dur<min_time);
    if short_duration
        warning('The following call boxes are too short; %s', mat2str(short_duration))
    end
    
    % Is the frequency too low
    freq = boxes(:,2);
    min_freq = 5;
    low_freq = find(freq<min_freq);
    if low_freq
        warning('The following call boxes are too low frequency; %s', mat2str (low_freq))
    end
    
    % does the box have 0 height
    freq_height = boxes(:,4);
    zero_height = find(freq_height == 0);
    if zero_height
        warning('The following call boxes have 0 box height; %s', mat2str(zero_height))
        d.Calls(zero_height,:) = [];
        mat_changed = true;
    end
    
    % Are there exact duplicates
    [~, ia, ~] = unique(boxes, 'rows', 'stable');
    duplicate_boxes = setdiff(1:size(boxes,1), ia);
    if duplicate_boxes
        warning('The following call boxes are duplicates; %s', mat2str(duplicate_boxes))
    
        d.Calls(duplicate_boxes,:) = [];
        mat_changed = true;
    end
    
    % Are there boxes with any overlap
    overlap = rectint(boxes, boxes);
    overlap(logical(eye(size(overlap)))) = 0;%set diagonal to 0;
    [overlap_boxes,~] = find(overlap<1 & overlap>0);
    if duplicate_boxes
        warning('The following call boxes are overlap other boxes; %s', mat2str(overlap_boxes))
    end
    
    %TODO: put in warning if overlap in time
    if mat_changed
        save(filepath, "-struct", "d")
    end

end