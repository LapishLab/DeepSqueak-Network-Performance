clear
net = "/home/lapishla/Documents/GitHub/DeepSqueak/Networks/Mouse Detector YOLO R2.mat";
train = "/home/lapishla/Desktop/training/training_images/";
validate = "/home/lapishla/Desktop/training/validation_images/";

[detector, info, options] = train_detector(train, validate, net);

