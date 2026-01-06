function [detector, info, options] = train_detector(train_folder, validation_folder,net_path,checkpoint_dir)
[train, example] = load_datastore(train_folder);
val = load_datastore(validation_folder);

options = trainingOptions('sgdm',...
          'InitialLearnRate',0.001,...
          'Verbose',true,...
          'MiniBatchSize',16,...
          'MaxEpochs',250,...
          'Shuffle','never',...
          'VerboseFrequency',30,...
          'CheckpointPath',checkpoint_dir,...
          'Plots','training-progress', ...
          'ValidationData',val);

% Load existing network
original = load(net_path);

% Train the YOLO v2 network.
[detector,info] = trainYOLOv2ObjectDetector(train,original.detector,options);


final = original;
final.detector = detector;
file_path = fullfile(checkpoint_dir, 'final.mat');
save(file_path, '-struct', "final")


%% add missing values to checkpoints
add_checkpoint_options(checkpoint_dir, example, options)
end

function add_checkpoint_options(checkpoint_dir, example, options)
    % load and concatonate TTables
    fnames = {dir(checkpoint_dir+"*.mat").name};

    for i=1:length(fnames)
        file_path = fullfile(checkpoint_dir,fnames{i});
        d = load(file_path);
        d.wind = example.wind;
        d.nfft = example.nfft;
        d.noverlap = example.noverlap;
        d.imScale = example.imScale;
        d.imLength = example.imLength;
        save(file_path, '-struct', "d")
    end
end

function [data, d]= load_datastore(folder)
    % load and concatonate TTables
    fnames = {dir(folder+"*.mat").name};
    ttables = table();
    for i=1:length(fnames)
        d = load(fullfile(folder,fnames{i}));
        ttables = cat(1, ttables, d.TTable);
    end
    % correct image paths
    for i=1:height(ttables)
        ttables.imageFilename{i} = strrep(ttables.imageFilename{i}, "Training/", folder);
    end

    % Convert to datastore
    blds = boxLabelDatastore(ttables(:,2:end));
    imds = imageDatastore([ttables.imageFilename{:}]');
    data = combine(imds, blds);
end