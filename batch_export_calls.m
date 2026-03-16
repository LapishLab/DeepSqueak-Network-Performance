function output_table = batch_export_calls(predictions_folder, csv_path, output_folder)
    t = readtable(csv_path, Delimiter=',');
    t = t(~cellfun(@isempty, t.split), :); % remove audio files not in test/validation/train

    [~,id,~] = fileparts(t.link_name);
    t.id = string(id);
    

    % Prepare a table to keep track of export progress
    output_csv = fullfile(output_folder, "Export.csv");
    output_table = table();
    output_table.session_path = unique(fileparts(t.audio_file_path));
    

    % Which variables from audio table should be carried into export table
    % TODO: make more robust (maybe this should be input argument?)
    common_variables = {'subject','sex','treatment','issueTime'};

    temp = cell(height(output_table),length(common_variables));
    temp = cell2table(temp, "VariableNames",common_variables);
    output_table = cat(2,output_table, temp);
    
    for i=1:height(output_table)
        % Find rows in audio table which correspond to this session
        session = output_table.session_path{i};
        in_session = contains(t.audio_file_path, session);

        common_vals = t(in_session,common_variables);
        common_vals = unique(common_vals);
        
        if height(common_vals) > 1
            warning("More than 1 unique variable for session, skipping")
            continue
        end
        output_table{i, common_variables} = table2cell(common_vals);

        % Get list of "expected" detection files for the session
        session_mats = fullfile(predictions_folder, t.id(in_session) + ".mat");

        if any(~cellfun(@exist, session_mats))
            warning("Missing detection files for session: " + session);
            continue;
        end

        % Merge these detection files and save at export mat
        output_table.export_path(i) = export_calls(session_mats, output_folder);

        % Save the table of export info
        writetable(output_table, output_csv);

        fprintf("Completed file %i/%i \n", i,height(output_table))
    end
end