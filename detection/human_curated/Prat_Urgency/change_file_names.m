%% load csv 
clear
t = readtable("audioFiles_subjectInfo.csv", Delimiter=',');
t = convertvars(t, @(x) true, "string"); % convert everything to strings because David likes them more than cell arrays of characters

%% Get path string after 5th \
inds = strfind(t.audio_file_path, '\');
inds = cell2mat(inds);
inds = inds(:,5);
subpath = extractAfter(t.audio_file_path, inds);

%% convert to unix path and add datastar initial path string
subpath = strrep(subpath, '\', '/');
newpath = "/datastar/behavior_rooms/2CAP/" + subpath;

%% save new paths to csv file
t.audio_file_path = newpath;
writetable(t, 'audioFiles_subjectInfo.csv')