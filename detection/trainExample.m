clear
% net = "/home/lapishla/Documents/GitHub/DeepSqueak/Networks/YOLOX2026-02-26_08-17-26.mat";
% train = "/home/lapishla/Desktop/training/training_images/";
% validate = "/home/lapishla/Desktop/training/validation_images/";

train = "/home/lapishla/Documents/GitHub/DeepSqueak-Network-Performance/detection/human_curated/Prat_Urgency/detection_files/train/";
validate = "/home/lapishla/Documents/GitHub/DeepSqueak-Network-Performance/detection/human_curated/Prat_Urgency/detection_files/validation/";

train_img = "/home/lapishla/Desktop/test/train";
validate_img = "/home/lapishla/Desktop/test/validate";

settings = spectrogram_settings();
%% Create training images
create_training_images(train,train_img,settings);
create_training_images(validate,validate_img,settings);
%% Make a fresh detector
im_table = load(fullfile(validate_img, 'img_table.mat'));
labels=unique(cat(1,im_table.TTable.Labels{:}));
net = "/home/lapishla/Documents/GitHub/DeepSqueak/Networks/freshYOLOX.mat";
generate_blank_YOLOX(net, settings, labels);
%% Train the detector
network = train_detector(train_img, validate_img, net);
%% Run validation on the generated images
[score,details] = detect_pregenerated_images(network.detector,im_table);
%% run detector
network = load("/home/lapishla/Documents/GitHub/DeepSqueak/Networks/YOLOX3_2026-03-03_09-31-34.mat");
network.settings = spectrogram_settings();
%%
prediction_output = "/home/lapishla/Desktop/Prat_all_predictions/";
network = load("/home/lapishla/Documents/GitHub/DeepSqueak/Networks/YOLOX3_2026-03-03_09-31-34.mat");
network.settings = spectrogram_settings();
audio_root = "/home/lapishla/Documents/GitHub/DeepSqueak-Network-Performance/detection/human_curated/Prat_Urgency/audio/";
%%
audio_folder = audio_root + "train/";
batch_detect_calls(audio_folder, prediction_output, network)
%%
audio_folder = audio_root + "test/";
batch_detect_calls(audio_folder, prediction_output, network)
%%
audio_folder = audio_root + "validation/";
batch_detect_calls(audio_folder, prediction_output, network)