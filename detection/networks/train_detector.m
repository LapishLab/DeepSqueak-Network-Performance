function [detector, info, options] = train_detector(train_folder, validation_folder,net_path,checkpoint_dir)
train = load_datastore(train_folder);
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
layers = load(net_path).detector;

% Train the YOLO v2 network.
[detector,info] = trainYOLOv2ObjectDetector(train,layers,options);

end


function data = load_datastore(folder)
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