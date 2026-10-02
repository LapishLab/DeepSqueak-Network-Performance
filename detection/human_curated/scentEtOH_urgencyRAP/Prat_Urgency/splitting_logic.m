%% Split files into validation, test, and training %%
%information to change for each file
% load csv 
clear
folder_path = "/media/lapishla/usv/DeepSqueak-Network-Performance/detection/human_curated/scentEtOH_urgencyRAP/Prat_Urgency";
csv_name = "audioFiles_subjectInfo.csv";
csv_path = fullfile(folder_path, csv_name);
t = readtable(csv_path, Delimiter=',');
original = t; % save an unedited copy of the table
t  = convertvars(t, @(x) true, "string"); % convert everything to strings because David likes them more than cell arrays of characters

%Set minute time limits for the file. Minimum time should be negative if
%you want to include any time before the behavior started. 
minute_min = -5;
minute_max = 60;

%what to consider when grouping the files
%time_group is calculated below
split_groups = {'sex','treatment','time_group'};


%% calculate file time into the recording
f_names = extractBefore(t.file_ID, "_subject");
file_times = datetime(f_names, 'InputFormat', 'yyyyMMdd_HHmmss');
t.issueTime = pad(t.issueTime, 6, 'left', '0');
issue_times = datetime(t.issueTime, 'InputFormat', 'HHmmss');  % Some missing, marked as NaN
post_issue = timeofday(file_times)-timeofday(issue_times); % need to use timeofday because date not included in issueTime
post_issue = seconds(post_issue); % convert to seconds for easier comparison
t.post_issue = post_issue;

 % histogram(post_issue)
 % ylabel('File counts')
 % xlabel('Audio file start time relative to MedPC issue time (s)')


%% Divide session time into thirds (find divide times)
 min_time = minute_min * 60; % calculate minimum time of behavior in seconds 
 max_time = minute_max * 60; % calculate max time of behavior in seconds
 ecdf(post_issue(post_issue>min_time & post_issue<max_time))
 yline(0.333, '--')
 yline(0.666, '--')

 total_time = abs(min_time) + abs(max_time);
 time_in_thirds = total_time/3;

tdiv = [min_time min_time+time_in_thirds min_time+(time_in_thirds*2) max_time];

%% Divide session time into thirds (Assign time labels)
t.time_group = strings(height(t),1);
t.time_group(post_issue>=tdiv(1) & post_issue<tdiv(2)) = "early";
t.time_group(post_issue>=tdiv(2) & post_issue<tdiv(3)) = "middle";
t.time_group(post_issue>=tdiv(3) & post_issue<tdiv(4)) = "late";

histogram(fillmissing(categorical(t.time_group), 'constant', 'undefined'))

%% merge column values
t{contains(t.treatment, "EtOH_Control"), "treatment"} = "Control_EtOH";
t{contains(t.treatment, "Control"), "treatment"} = "Control_Control"; % Treat single rat the same as double rat
t{contains(t.treatment, "EtOH"), "treatment"} = "EtOH_EtOH"; % Treat single rat the same as double rat

%% choose which rows to include
include_row = t.time_group ~= ""; % don't include rows that were not assigned a time label

%% Calculate balanced split for given rows and columns
[split, group_id] = balanced_split(t(include_row, split_groups));

%% Add time group, split, and unique group ID to the original table
original.time_group = t.time_group;
original.split(include_row) = split;
original.group_id(include_row) = group_id;

%% Save the table
writetable(original, fullfile(folder_path, "split.csv"))

