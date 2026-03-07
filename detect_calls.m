function output = detect_calls(audio_file, network, opts)
arguments
    audio_file string % Path to audio file 
    network struct % Settings for spectrogram
    opts.plot logical = false
end 

settings = network.settings;

% read audio
[audio,Fs] = audioread(audio_file);
img_dur = settings.img_dur;
audio_dur = length(audio)/Fs;

% Split audio into chunks
image_start = 0:img_dur*(1-settings.img_overlap):audio_dur-img_dur; % in seconds
% TODO: make an image at the end of the file
all_prediction = cell(length(image_start), 1);
for b = 1:length(image_start)
    %% generate spectrogram of audio segment
    start_ind = round(image_start(b)*Fs)+1; % add 1 because index by 1 instead of 0
    stop_ind = start_ind + round(img_dur*Fs)-1;
    [im, T, F] = gen_spect_image(audio(start_ind:stop_ind), Fs, settings);
    im = uint8(im*255); % model requires uint8
    T = T + image_start(b);
    %% Run prediction
    prediction = predict_boxes(im, network.detector);
    if opts.plot
        figure(1); clf;
        annotated_img = insertObjectAnnotation(im, "Rectangle", prediction.Box,prediction.Labels);
        imshow(annotated_img)
        pause(.1)
    end
    %% Convert pixels to seconds and kHz
    prediction.Box(:,1) = T(round(prediction.Box(:,1))); %start time -> index of T
    prediction.Box(:,2) = F(round(prediction.Box(:,2))) / 1000; %start frequency -> index of F (convert to kHz)
    prediction.Box(:,3) = prediction.Box(:,3) * diff(T(1:2)); %time duration -> scale from T
    prediction.Box(:,4) = prediction.Box(:,4) * diff(F(1:2))/1000; %frequency range -> scale from F (convert to kHz)

    %% Save in cell array
    all_prediction{b} = prediction;
    fprintf(".")
end
fprintf("\n")
all_prediction = cat(1, all_prediction{:});

%% Remove overlapping boxes (may want to do on a per label basis)
[~,~,inds] = selectStrongestBbox(all_prediction.Box, all_prediction.Score, OverlapThreshold=0);
all_prediction = all_prediction(inds,:);

 
%% Save calls and audioinfo in a struct
output = struct();
output.Calls = all_prediction;
output.audiodata = audioinfo(audio_file);
end