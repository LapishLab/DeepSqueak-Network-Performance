function g = balanced_split(t, proportions)
    % split table into groups (e.g. test, validation, & train) while
    % maintaining balanced experimental conditions
    arguments
        t table % table where rows = samples & columns = conditions
        proportions double = [.3, .3, .4] % proportion data in each group
    end
    t = convertvars(t, @(x) true, "string"); % convert all values to strings
    
    all_groups = findgroups(t);
    counts = histcounts(all_groups, 1:max(all_groups)+1);
    if min(min(proportions) * counts) < 1
        warning("N too low to split across each unique group," + ...
            "attempting to splitting independently by grouping variable")
        g = brute_force_split_by_columns(t, proportions);
    else
        g = split_groups(all_groups, proportions);
    end
end

%% helper functions
function g = split_groups(all_groups, proportions)
    g = nan(size(all_groups));
    for g_ind = 1:max(all_groups)
        full_ind = find(all_groups==g_ind); % rows for this group
        full_ind = full_ind(randperm(length(full_ind))); % rand shuffle
    
        bin_edges = [0, cumsum(round(proportions*length(full_ind)))];
        bin_edges(end) = length(full_ind);% avoid rounding errors for last group
        for i=1:length(proportions)
            g(full_ind((bin_edges(i)+1):bin_edges(i+1))) = i; % that's a lot of indexing
        end
    end

end

function [g, best_err] = brute_force_split_by_columns(t, proportions)
    column_categories = nan(size(t));
    column_proportions = cell(width(t), 1);
    for i=1:width(t)
        c = findgroups(t{:,i});
        column_categories(:,i)=c;
        column_proportions{i} = group_fractions(c, max(c));
    end
    
    g = gen_ordered_group(height(t), proportions);
    
    best_err = inf;
    figure(1); clf; hold on;
    
    num_shuffles = 5000000;
    for i=1:num_shuffles
        new_g = g(randperm(length(g)));
        err = grouping_error(new_g, column_categories, column_proportions);
        if err<best_err
            g = new_g;
            best_err=err;
            scatter(i, err, 'filled');
        end 
    end
    
    xlabel('shuffle #')
    ylabel('error')
    xlim([0,num_shuffles])
end

function p = group_fractions(g, num_groups)
counts = histcounts(g, 1:max(num_groups)+1);
p = counts ./ sum(counts);
end

function group = gen_ordered_group(n, proportions)
    cut_off_inds = cumsum(round(proportions*n));
    cut_off_inds(end) = n;
    
    start_ind = 1;
    group = nan(n, 1);
    for i=1:length(cut_off_inds)
        group(start_ind:cut_off_inds(i)) = i;
        start_ind = cut_off_inds(i) + 1;
    end
end

function err = grouping_error(g, label_ind, full_prop)
    err = 0;
    for i=1:max(g)
        subgroup = label_ind(g==i, :);
        for ii=1:width(subgroup)
            x = group_fractions(subgroup(:,ii) , label_ind(:,ii));
             err = err + sum((x - full_prop{ii}).^2);
        end
    end
end