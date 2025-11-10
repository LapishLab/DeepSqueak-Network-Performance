%% load csv 
clear
t = readtable("split.csv", Delimiter=',');
original = t; % save an unedited copy of the table
t = convertvars(t, @(x) true, "string"); % convert everything to strings because David likes them more than cell arrays of characters

%% get expected filename in table 90890_subject007
[~,f_names,~] = fileparts(t.audio_file_path);
expected_table_names = f_names + "_subject" + t.subject + ".mat";
%% lookup all the completed mat files
curated_files = string(struct2table(dir("detection_files/validation/*.mat")).name);
%% look through table for completed mat file, and change to validation if necessary, also swapping file not in list to train or whatever we just swapped

% matches = expected_table_names == curated_files';
protected_rows = nan(size(curated_files));
for i = 1:length(curated_files)
    t_ind = curated_files(i) == expected_table_names;
    m = t(t_ind, :);
    
    protected_rows(i) = find(t_ind);

    if m.split ~= "validation"
        swappable_inds = find(t.group_id == m.group_id & t.split == "validation");
        swappable_inds =  swappable_inds(~any(protected_rows == swappable_inds'));

        if isempty(swappable_inds)
            cur_path = "detection_files/validation/" + curated_files(i);
            new_path = fullfile("detection_files", m.split, curated_files(i));
            movefile(cur_path, new_path); % Move the file to the new path
        else
            ind_to_swap = swappable_inds(randi(length(swappable_inds), 1,1));

            t.split(t_ind) = t.split(ind_to_swap);
            t.split(ind_to_swap) = m.split;
        end
    end
end


%% resave the table
writetable(t, 'split.csv')