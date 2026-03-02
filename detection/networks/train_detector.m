function [detector, info, op] = train_detector(train_folder, validation_folder, net_path)
train = load_datastore(train_folder);
val = load_datastore(validation_folder);


contents = readall(train);
labels = unique(cat(1,contents{:,3}));
model = yoloxObjectDetector('small-coco', labels, InputSize=[1248 384 3]);

    % 'small-coco'
    % 'tiny-coco'
    % 'medium-coco'
    % 'large-coco'
    % 'nano-coco'



op = trainingOptions('sgdm');
op.InitialLearnRate=0.001;
op.MiniBatchSize= 8;
op.MaxEpochs = 100;
op.Shuffle='every-epoch'; %(default once)
op.CheckpointFrequencyUnit='iteration';
op.CheckpointFrequency=10;
op.ValidationFrequency=10; %Unit in iterations
op.Plots='training-progress';     
op.ValidationData=val;
[folder,file,~] = fileparts(net_path);
op.CheckpointPath = fullfile(folder, file+"_checkpoint");
[~] = mkdir(op.CheckpointPath);
op.OutputNetwork='best-validation';


% Load existing network
% old_detector = load(net_path).detector;

% Train the YOLO v2 network.
[detector,info] = trainYOLOXObjectDetector(train,model,op);

network = struct();
network.detector = detector;
network.info = info;
% network.settings = settings;


timestamp = string(datetime('now', 'Format', 'yyyy-MM-dd_HH-mm-ss'));
file_path = fullfile(fileparts(net_path), "lapish_"+timestamp+".mat");
save(file_path, '-struct', "network")
end

function data = load_datastore(folder)
    % load and concatonate TTables
    fnames = {dir(fullfile(folder,"*.mat")).name};
    ttables = table();
    for i=1:length(fnames)
        d = load(fullfile(folder,fnames{i}));
        ttables = cat(1, ttables, d.TTable);
    end
    ttables = ttables(~cellfun(@isempty, ttables.Labels), :);

    % correct image paths (if using GUI image generation and copying files)
    if ~exist(ttables.imageFilename(1), 'file')
        for i=1:height(ttables)
            ttables.imageFilename{i} = strrep(ttables.imageFilename{i}, "Training/", folder);
        end
    end

    % Convert to datastore
    blds = boxLabelDatastore( ttables(:,{'Boxes','Labels'}));
    imds = imageDatastore(string(ttables.imageFilename));
    data = combine(imds, blds);
end