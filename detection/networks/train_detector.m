function [detector, info, op] = train_detector(train_folder, validation_folder, net_path)
[train, training_table] = load_datastore(train_folder);
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
old_detector = load(net_path).detector;

% Train the YOLO v2 network.
[detector,info] = trainYOLOv2ObjectDetector(train,old_detector,op);

network = struct();
network.detector = detector;
network.options = op;
network.info = info;
network.wind = training_table.wind;
network.noverlap = training_table.noverlap;
network.nfft = training_table.nfft;
network.imLength = training_table.imLength;
network.imScale = training_table.imScale;

timestamp = string(datetime('now', 'Format', 'yyyy-MM-dd_HH-mm-ss'));
file_path = fullfile(fileparts(net_path), "lapish_"+timestamp+".mat");
save(file_path, '-struct', "network")
end

function [data, d]= load_datastore(folder)
    % load and concatonate TTables
    fnames = {dir(fullfile(folder,"*.mat")).name};
    ttables = table();
    for i=1:length(fnames)
        d = load(fullfile(folder,fnames{i}));
        ttables = cat(1, ttables, d.TTable);
    end

    % correct image paths (if using GUI image generation and copying files)
    if ~exist(ttables.imageFilename(1), 'file')
        for i=1:height(ttables)
            ttables.imageFilename{i} = strrep(ttables.imageFilename{i}, "Training/", folder);
        end
    end

    % Convert to datastore
    blds = boxLabelDatastore(ttables(:,2:end));
    imds = imageDatastore(string(ttables.imageFilename));
    data = combine(imds, blds);
end