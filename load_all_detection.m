function [output] = load_all_detection(folder)
%% Returns table with columns: file_names | audiodata | Calls 

% Find all .mat files in folder
files = dir(fullfile(folder, "*.mat"));
% get rid of ._ files created by mac OS
files = files(~startsWith({files.name}, "._"));

% Get file names from struct and convert to string because structs are
% annoying to work with
file_names = string({files.name});

% Save all the data in a table, because they are fun to work with
output = table();
output.file_names = file_names(:);

% loop through each file and load it into the table
for i = 1:length(file_names)
    detection_struct = load(fullfile(folder, file_names(i)));
    output.audiodata{i} = detection_struct.audiodata;
    calls = detection_struct.Calls;
    calls.audioFile = string(repmat(detection_struct.audiodata.Filename, height(calls),1)); % also save audiodata with calls to simplify later processing if calls concatonated accross files
    output.Calls(i) = {calls};
end
end