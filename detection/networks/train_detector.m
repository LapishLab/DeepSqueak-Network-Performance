function [detector, info, op] = train_detector(train_folder, validation_folder, net_path)
train = load_datastore(train_folder);
val = load_datastore(validation_folder);

op = trainingOptions('sgdm');
op.InitialLearnRate=0.001;
op.MiniBatchSize=16;
op.MaxEpochs = 100;
op.Shuffle='every-epoch'; %(default once)
op.CheckpointFrequencyUnit='iteration';
op.CheckpointFrequency=10;
op.ValidationFrequency=10; %Unit in iterations
op.Plots='training-progress';     
op.ValidationData=val;
% 'CheckpointPath',tempdir,...
op.OutputNetwork='best-validation';

% Load existing network
network = load(net_path);

% Train the YOLO v2 network.
[detector,info] = trainYOLOv2ObjectDetector(train,network.detector,op);


network.detector = detector;
network.options = op;
network.info = info;

timestamp = string(datetime('now', 'Format', 'yyyy-MM-dd_HH-mm-ss'));
file_path = fullfile(fileparts(net_path), "lapish_"+timestamp+".mat");
save(file_path, '-struct', "network")
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