predictions_folder = "/home/lapishla/Desktop/Prat_all_predictions/";
csv_path = "/home/lapishla/Documents/GitHub/DeepSqueak-Network-Performance/detection/human_curated/Prat_Urgency/split.csv";
output_folder = "/home/lapishla/Desktop/Prat_session_export/";
output_table = batch_export_calls(predictions_folder, csv_path,output_folder)




% %% Fixing bad csv file
% t.subject = pad(t.subject, 3, "left", '0');
% d.subject = pad(d.subject, 3, "left", '0');
% 
% d.audio_file_path = strrep(d.audio_file_path, '.WAV', '_whitened.flac')
% 
% bad = false(height(t),1);
% for i=1:height(d)
%    new_bad = strcmp(d.audio_file_path(i), t.audio_file_path) &  strcmp(d.subject(i), t.subject);
% 
%    if sum(new_bad) ~=1
%        error('uh oh')
%    else
%        bad = bad | new_bad;
%    end
% end
% %%
% t = t(~bad,:)
% 
% %%
% writetable(t,'split_fixed.csv' )