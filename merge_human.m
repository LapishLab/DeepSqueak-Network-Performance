%% load all detection files
root = "/home/lapishla/Desktop/network_validation/";
nora = root + "Nora";
brandon = root + "brandon";
aria = root + "aria";


% nora = load_all_detection(nora);
% brandon = load_all_detection(brandon);
aria_t = load_all_detection(aria);

%% Save detection files in folders for varying levels of confidence
mkdir(root+"majority")
mkdir(root+"conservative")
mkdir(root+"liberal")
mkdir(root+"controversial")

%% combine detection files with name labels
for i=1:height(aria_t)
    fname = aria_t.file_names(i);
    a = aria_t.Calls{i};
    a.curator = repmat("Aria", height(a), 1);

    n = load(fullfile(nora, fname)).Calls;
    n.curator = repmat("Nora", height(n),1);

    b = load(fullfile(brandon, fname)).Calls;
    b.curator = repmat("Brandon", height(b), 1);
    

    columns = ["Box","Score","Type","Accept","curator"];
    combined = [n(:,columns); b(:,columns); a(:,columns)]; % Combine the calls from all curators

    [~, sort_ind] = sort(combined.Box(:,1));
    combined = combined(sort_ind, :); % Sort by call time

    % Remove noise labels
    combined = combined(startsWith(string(combined.Type), "USV"), :);

    % Merge ovelapping boxes
    overlap = calc_box_overlap(combined.Box, combined.Box);

    % remove self overlap
    N = height(overlap);
    overlap(1:N+1:end) = 0;

    % Build adjacency matrix: 1 if boxes overlap
    A = overlap > 0;

    % Create graph
    G = graph(A);

    % Find connected components
    components = conncomp(G);


    % Choose the box with the greatest total overlap
    combined_collapsed = table;
    total_overlap = sum(overlap);
    for c = 1:max(components)
        members = find(components == c);
        [~, idx] = max(total_overlap(members));
        best_ind = members(idx);

        row = combined(best_ind, :);
        row.curator = {unique(combined.curator(members))};

        combined_collapsed = cat(1, combined_collapsed, row);
    end

    %% Save output structs based on how many votes each call received
    if height(combined_collapsed) < 1
        % No calls, skip saving for now
        continue
    end

    num_votes = cellfun(@numel, combined_collapsed.curator);

    % liberal = All calls from all curators included
    calls = combined_collapsed;
    save_det(aria_t(i,:), calls, root+"liberal/");
    
    % majority = At least 2 of the 3 curators agree that it is a call
    calls = combined_collapsed(num_votes>=2, :);
    save_det(aria_t(i,:), calls, root+"majority/");

    % Conservative = All 3 curators agree that it is a call
    calls = combined_collapsed(num_votes==3, :);
    save_det(aria_t(i,:), calls, root+"conservative/");

    % controversial = calls that received only 1 vote
    calls = combined_collapsed(num_votes == 1, :);
    save_det(aria_t(i,:), calls, root+"controversial/");
end

function save_det(template, new_calls, folder)
    output = struct();
    output.audiodata = template.audiodata{1};
    output.Calls = new_calls;

    save(folder+template.file_names{1}, '-struct','output')
end