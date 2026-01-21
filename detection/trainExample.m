clear
net = "/home/lapishla/Documents/GitHub/DeepSqueak/Networks/Mouse Detector YOLO R2.mat";
% train = "/home/lapishla/Desktop/training/training_images/";
% validate = "/home/lapishla/Desktop/training/validation_images/";


train = "/home/lapishla/Documents/GitHub/DeepSqueak-Network-Performance/detection/human_curated/Prat_Urgency/detection_files/train/";
validate = "/home/lapishla/Documents/GitHub/DeepSqueak-Network-Performance/detection/human_curated/Prat_Urgency/detection_files/validation/";

train_img = "/home/lapishla/Desktop/test/train";
validate_img = "/home/lapishla/Desktop/test/validate";
%%
create_training_images(train,train_img)
create_training_images(validate,validate_img)
%%
[detector, info, options] = train_detector(train_img, validate_img, net);

