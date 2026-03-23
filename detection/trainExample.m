clear
% net = "/home/lapishla/Documents/GitHub/DeepSqueak/Networks/YOLOX2026-02-26_08-17-26.mat";
% train = "/home/lapishla/Desktop/training/training_images/";
% validate = "/home/lapishla/Desktop/training/validation_images/";

train = "/home/lapishla/Documents/GitHub/DeepSqueak-Network-Performance/detection/human_curated/Prat_Urgency/detection_files/train/";
validate = "/home/lapishla/Documents/GitHub/DeepSqueak-Network-Performance/detection/human_curated/Prat_Urgency/detection_files/validation/";

train_img = "/home/lapishla/Desktop/training_images/train";
validate_img = "/home/lapishla/Desktop/training_images/validation";

settings = spectrogram_settings();

%% Create training images
det = load_all_detection(train);
det.Calls = cellfun(@merge_types, det.Calls, UniformOutput=false);
det = filter_all_calls(det);
summary(cat(1, det.Calls{:}).Type)
% im_train = create_training_images(det,train_img,settings);

det = load_all_detection(validate);
det.Calls = cellfun(@merge_types, det.Calls, UniformOutput=false);
det = filter_all_calls(det);
summary(cat(1, det.Calls{:}).Type)
% im_val = create_training_images(det,validate_img,settings);
%% Make a fresh detector
% im_val = load(fullfile(validate_img, 'img_table.mat'));
% im_train = load(fullfile(train_img, 'img_table.mat'));
labels=unique(cat(1, im_val.TTable.Labels{:}, im_train.TTable.Labels{:}));
net = "/home/lapishla/Documents/GitHub/DeepSqueak/Networks/freshYOLOX.mat";
generate_blank_YOLOX(net, settings, labels);
%% Train the detector
network = train_detector(train_img, validate_img, net);
%% Run validation on the generated images
[score,details,l] = detect_pregenerated_images(network.detector,im_val);
%% run detector
network = load("/home/lapishla/Documents/GitHub/DeepSqueak/Networks/YOLOX_noise_label.mat");
% network.settings = spectrogram_settings();
%%
%prediction_output = "/home/lapishla/Desktop/Prat_all_predictions/";
prediction_output = "/home/lapishla/Documents/GitHub/DeepSqueak-Network-Performance/detection/human_curated/scentEtOH_urgencyDD/audio/validation/";
network = load("/home/lapishla/Documents/GitHub/DeepSqueak/Networks/YOLOX3_2026-03-03_09-31-34.mat");
network.settings = spectrogram_settings();
audio_root = "/home/lapishla/Documents/GitHub/DeepSqueak-Network-Performance/detection/human_curated/scentEtOH_urgencyDD/audio/";
%%
audio_folder = audio_root + "train/";
batch_detect_calls(audio_folder, prediction_output, network)
%%
audio_folder = audio_root + "test/";
batch_detect_calls(audio_folder, prediction_output, network)
%%
audio_folder = audio_root + "validation/";
batch_detect_calls(audio_folder, prediction_output, network)
%

function calls = merge_types(calls)
label = string(calls.Type);
isUSV = contains(label, 'USV');
label(isUSV) = 'USV';
label(~isUSV) = 'noise';
calls.Type = categorical(label);
end

function det = filter_all_calls(det)
for i=1:height(det)
    d = table2struct(det(i,:));
    d = filter_calls(d, include_non_usv=true, include_rejected=true);
    det{i,:} = struct2cell(d)';
end
end