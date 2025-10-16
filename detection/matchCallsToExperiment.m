load("calls.mat")
session_info = readtable("Truitt_times.csv");
%%
session_info.calls = cell(height(session_info), 1);
for i=1:height(session_info)
    start = session_info.time(i);
    stop = start + 300; % fixed 5 minute recording
    isMatch = calls.startTime>start & calls.stopTime<stop;
    session_info.calls{i} = calls(isMatch,:);
end

%% drop rows without calls. Something went wrong with syncing
session_info = session_info(~cellfun(@isempty, session_info.calls), :);
