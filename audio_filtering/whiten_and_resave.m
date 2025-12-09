% loop through all the audio in datastar, (or in links?), filter and place next to original audio?
% rename original or filtered?
% if renaming original, then we need to swap out audio links

% For now, lets just test on a single audio file


% %%
% root = "/home/lapishla/Documents/GitHub/DeepSqueak-Network-Performance/detection/human_curated/Prat_Urgency/audio/";
% % folder = root+"validation/";
% folder = root+"test/";
% files = {dir(folder+"*.wav").name};
% [~, files] = isSymbolicLink(fullfile(folder,files));
% 
% %%
% for i=1:length(files)
%     whiten_and_resave(files(i))
% end

function whiten_and_resave(wav,new_name)
[original_audio, fs] = audioread(wav); % Read the original audio file

frac = 0.1;
background = get_background(original_audio, fs, frac);
resample_rate = 25;
filter = gen_filter(background, fs, resample_rate); % generate filter
audio_out = apply_filter(original_audio, filter);

%normalize audio
audio_out = audio_out/50;
audio_out(audio_out>1)=1;
audio_out(audio_out<-1)=-1;

figure(1);
subplot(1,2,1)
plot_spectrum_data(original_audio(1:fs),fs)
subplot(1,2,2)
plot_spectrum_data(audio_out(1:fs),fs)

%% get audio metadata
info = audioinfo(wav);
comment = sprintf(['%s\nSpectrally whitened using inverse power spectra' ...
    ' on %s'], info.Comment, string(datetime('now')));
%% save audio


audiowrite(new_name, audio_out, fs, Comment=comment, Artist=info.Artist);

end