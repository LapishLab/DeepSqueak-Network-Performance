%% load csv 
clear
t = readtable("audioFiles_subjectInfo.csv", Delimiter=',');
original = t; % save an unedited copy of the table
t = convertvars(t, @(x) true, "string"); % convert everything to strings because David likes them more than cell arrays of characters

%% determine how many rats are present
t.num_rats = ones(height(t),1);
t.num_rats(contains(t.treatment, "_")) = 2;

%% merge column values
t{contains(t.treatment, "EtOH_Control"), "treatment"} = "Control_EtOH";

%% choose which rows to include
% include_row = t.num_rats==2; % only rows with 2 rats
include_row = true(height(t),1); % all rows

%% Calculate balanced split for given rows and columns
[split, group_id] = balanced_split(t(include_row, {'sex','treatment'}));
% [split, group_id] = balanced_split(t(include_row, {'sex','num_rats'}));

%% Add split and unique group ID to the original table
original.split(include_row) = split;
original.group_id(include_row) = group_id;

%% Save the table
writetable(original, 'split.csv')

