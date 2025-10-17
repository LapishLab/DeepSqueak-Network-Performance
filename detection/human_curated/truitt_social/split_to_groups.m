%% load csv 
file_name = "split.csv";
split_table_original = readtable(file_name);

%% make a copy of the table that we can change variables
t = split_table_original;
t = convertvars(t, @(x) true, "string"); % convert all values to strings

%% don't include "none" rows
included_rows = ~contains(t.sex, 'none');

% group together experiment days with similar types
t{contains(t.exp, "OF"),"exp"} = "OF";
t{contains(t.exp, "BL"),"exp"} = "BL";
t{contains(t.exp, "ST"),"exp"} = "ST";


%% split by sex, strain, and experiment
split_variables = t(included_rows, {'sex','strain','exp'});
g = balanced_split(split_variables);

%% save grouping to original table
sets = ["test"; "validation"; "train"];
split_table_original.grouping = strings(height(t),1);
split_table_original.grouping(included_rows) = sets(g);
writetable(split_table_original, file_name)