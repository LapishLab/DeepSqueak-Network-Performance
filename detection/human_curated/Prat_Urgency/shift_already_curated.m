%% load csv 
clear
t = readtable("audioFiles_subjectInfo.csv", Delimiter=',');
original = t; % save an unedited copy of the table
t = convertvars(t, @(x) true, "string"); % convert everything to strings because David likes them more than cell arrays of characters

%% get expected filename in table 90890_subject007
[~,f_names,~] = fileparts(t.audio_file_path);
expected_table_names = f_names + "_subject" + t.subject + ".mat";
%% lookup all the completed mat files
curated_files = string(struct2table(dir("detection_files/validation/*.mat")).name);
%% look through table for completed mat file, and change to validation if necessary, also swapping file not in list to train or whatever we just swapped

matches = expected_table_names == curated_files';
curated_files(~sum(matches))
%% resave the table