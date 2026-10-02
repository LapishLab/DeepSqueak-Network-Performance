%compares old Prat_Urgency to new Prat_Urgency
%checks for missing files and moves the train, test and validation
%assignment from old split to new split

folder_path = "/media/lapishla/usv/DeepSqueak-Network-Performance/detection/human_curated/scentEtOH_urgencyRAP/Prat_Urgency";
file_name_old = "split_old.csv";
file_name_new = "split.csv";
old_path = fullfile(folder_path, file_name_old);
new_path = fullfile(folder_path, file_name_new);

%import old split file 
t_opts = detectImportOptions(old_path, Delimiter=",");
t_opts = setvartype(t_opts, t_opts.SelectedVariableNames, 'string');% convert everything to strings because David likes them more than cell arrays of characters
t_old = readtable(old_path, t_opts); 

%import new split file
t_opts = detectImportOptions(new_path, Delimiter=",");
t_opts = setvartype(t_opts, t_opts.SelectedVariableNames, 'string');% convert everything to strings because David likes them more than cell arrays of characters
t_new = readtable(new_path, t_opts); 

% Inputs:
%   oldTable  = older table
%   newTable  = newer table
%   keyVar    = matching column name (used to align rows)
%   colsToReplace = columns you want to copy from oldTable into newTable

%extract matching data from the file path. 
t_old_audio_paths = extractBefore(t_old.audio_file_path, "_whitened");
t_new_audio_paths = extractBefore(t_new.audio_file_path, ".WAV");

keyVar = "audio_file_path"
colsToReplace = {'split','group_id'};   % change this

% Find matching rows in oldTable for each row of newTable
[is_member, loc] = ismember(t_new_audio_paths, t_old_audio_paths);

% Check for missing matches
if any(~is_member)
    mismatch = t_new(~is_member, :);
    warning('Some rows in newTable do not have a match in oldTable.');
end



% Columns to compare (everything except key and selected replacement columns)
varsToCheck = setdiff(t_new.Properties.VariableNames, [keyVar, colsToReplace, "file_ID", "issueTime"]);

% Preallocate
n = height(t_new);
rowMatches = false(n,1);
diffVars = strings(n,1);

% Compare matched rows
for i = 1:n
    if ~is_member(i)
        diffVars(i) = "No match in oldTable";
        continue
    end

    thisDiffs = [];

    for v = 1:numel(varsToCheck)
        var = varsToCheck{v};

        oldVal = t_old{loc(i), var};
        newVal = t_new{i, var};

        if ~isequaln(oldVal, newVal)
            thisDiffs = [thisDiffs, string(var)]; %#ok<AGROW>
        end
    end

    rowMatches(i) = isempty(thisDiffs);
    if isempty(thisDiffs)
        diffVars(i) = "";
    else
        diffVars(i) = strjoin(thisDiffs, ", ");
    end
end

% % Report rows that differ
% mismatchRows = find(~rowMatches);
% checkReport = table( ...
%     newTable.(keyVar)(mismatchRows), ...
%     mismatchRows, ...
%     diffVars(mismatchRows), ...
%     'VariableNames', {keyVar, 'RowIndexInNewTable', 'DifferentVariables'} );
% 
% disp('Rows that do not match (excluding replacement columns):')
% disp(checkReport)

% Only replace selected columns for matched rows
for k = 1:numel(colsToReplace)
    var = colsToReplace{k};
    t_new{is_member, var} = t_old{loc(is_member), var};
end

%write table 
writetable(t_new, fullfile(folder_path, "split_org.csv"));