function [split, group_id]= balanced_split(t, n)
    % split table into groups (e.g. test, validation, & train) while
    % maintaining balanced experimental conditions
    arguments
        t table % table where rows = samples & columns = conditions
        n double = 1 % smallest N for each unique group in validationa and test splits
    end
    t = convertvars(t, @(x) true, "string"); % convert all values to strings
    
    [group_id, group_label] = findgroups(t);
    counts = histcounts(group_id, 1:max(group_id)+1);
    split_n = n .* counts ./ min(counts);
    group_label.split_n = split_n';
    split_n = round(split_n);
    group_label.split_n_round = split_n';

    fprintf("Total files in Test/Val: %d \n", sum(split_n))
    disp(group_label)

    rng(1); % use same random seed for consistent random results
    
    split = strings(height(t),1);
    for id = 1:max(group_id)
        s = strings(counts(id), 1);
        s_n = split_n(id);
        s(1:s_n) = "test";
        s(s_n+1:s_n*2) = "validation";
        s(s_n*2+1:end) = "train";

         s = s(randperm(length(s)));
        split(group_id==id) = s;
    end
end

