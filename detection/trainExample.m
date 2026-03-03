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
% train_info = create_training_images(train,train_img,settings, saveAnnotated=true);
val_info = create_training_images(validate,validate_img,settings, saveAnnotated=true);
%% Make a fresh detector
net = "/home/lapishla/Documents/GitHub/DeepSqueak/Networks/freshYOLOX.mat";
detector = generate_blank_YOLOX(net, train_info);
%% Train the detector
[detector, info, options] = train_detector(train_img, validate_img, net);
%% Run validation on the generated images
im_table = load(fullfile(validate_img, 'img_table.mat'));
detect_pregenerated_images(detector,im_table)

