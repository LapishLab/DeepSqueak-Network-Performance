function output_path = export_calls(session_mats, output_folder)
% Save a struct with
% Calls table
%   box coordinates - ridge times - ridge frequencies - ridge amplitudes
% Gaps???
% File start time saved in mat name?

t = table();

%% Get table of mat files and when they start
[~,t.id,~] = fileparts(session_mats);
id_split = split(t.id, "_");
time_str = id_split(:,1) + "_" + id_split(:,2);
t.file_time = datetime(time_str, "InputFormat", "yyyyMMdd_HHmmss");
t = sortrows(t,"file_time","ascend");

% start time is the time of the first file
start_time = t.file_time(1);
t.file_start = seconds(t.file_time - start_time);
t.file_stop = nan(height(t),1); % Fill in file stop time after loading audiodata

all_calls = cell(length(session_mats),1);
for i=1:length(session_mats)
    if(~exist(session_mats(i), 'file'))
        warning("No detection file found for %s", session_mats(i))
        continue
    end

    % load and filter calls
    d=load(session_mats(i));
    d = filter_calls(d);
    
    % get ridges
    [d.Calls.ridge_time, d.Calls.ridge_frequency, d.Calls.ridge_amp,] = detect_ridge(d.Calls, d.audiodata.Filename);
    
    % shift Box and ridge time by offset
    d.Calls.Box(:,1) = d.Calls.Box(:,1) + t.file_start(i);
    add_offset = @(x) x + t.file_start(i);
    d.Calls.ridge_time = cellfun(add_offset, d.Calls.ridge_time, 'UniformOutput', false);

    % Save the audio index
    d.Calls.file_index = repmat(i, height(d.Calls),1);
        
    % Save the Calls and file info
    all_calls{i} = d.Calls;
    t.file_stop(i) = t.file_start(i) + d.audiodata.Duration;
    t.audiodata{i} = d.audiodata;
end
all_calls = cat(1,all_calls{:});

%% TODO check that there are not gaps between files
%% Save as file
output = struct();
output.calls = all_calls;
output.audio_file_info = t;

%% TODO: include metadata about detection (include in detection script)

output_path = fullfile(output_folder, t.id(1)+".mat");
save(output_path, '-struct', 'output')
end