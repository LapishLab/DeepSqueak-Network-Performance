root = "/home/lapishla/Documents/GitHub/DeepSqueak-Network-Performance/detection/human_curated/Prat_Urgency/detection_files/";
% folder = root+ "/train/";
% folder = root+ "/train/Anna_duplicate/";
update_names(root)
function update_names(folder)

    contents = struct2table(dir(folder));
    contents(1:2,:) = []; % remove . & ..

    subfolders = contents{contents.isdir,{'name'}};
    for i=1:length(subfolders)
        update_names(fullfile(folder,subfolders{i}))
    end

    fnames = contents.name(~contents.isdir);
    fnames = fnames(endsWith(fnames, '.mat'));
    for i =1:length(fnames)
        mat_path = fullfile(folder,fnames{i});
        d = load(mat_path);
        if exist(d.audiodata.Filename, 'file')
            [mat_dir,mat_base,mat_ext] = fileparts(mat_path);
            [~,audio_base,~] = fileparts(d.audiodata.Filename);
            if mat_base ~= audio_base
                new_mat_path = fullfile(mat_dir,audio_base + mat_ext);
                movefile(mat_path,new_mat_path)
            end
            continue
        end
        [audioFolder,old_audio,~] = fileparts(d.audiodata.Filename);

        possible_names = string({dir(audioFolder).name}');

        subject = "subject" + split(old_audio, 'subject');
        subject = subject(end);

        date = split(old_audio, '_') + "_";
        date = strjoin(date(1:2),"");

        match = contains(possible_names, subject) & contains(possible_names, date);

        if sum(match) > 1
            error("more than 1 match found for %s", fnames{i})
        end
        if sum(match) < 1
            error("No match found for %s", fnames{i});
        end

        d.audiodata.Filename = fullfile(audioFolder, possible_names(match));
        save(mat_path, "-struct", 'd');
    end
end