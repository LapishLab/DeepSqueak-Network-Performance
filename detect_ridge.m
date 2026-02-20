function [amplitude, freq_inds, time_inds] = detect_ridge(spect, opt)
arguments
    spect double % Spectrogram values (Frequency x Time) 
    opt.ampThresh double = 0.8250; % amplitude threshold
    opt.entropyThesh double = 0.2150; % Entropy threshold
end
spect = imgaussfilt(spect, [.5,.5]);

%% Ridge Detection
% Calculate entropy at each time point
entropy = geomean(spect,1) ./ mean(spect,1);
brightThreshold=prctile(spect(:), opt.ampThresh*100);

%% Chose single pixel for each timepoint
[amplitude,freq_inds] = max(spect,[],1);

%% Get index of the time points where aplitude is greater than theshold
% % iteratively lower threshholds until at least 6 points are selected
% % threshold is lowered over a max of 10 iterations (38.55% of its original value) 

greaterthannoise = amplitude>brightThreshold & (1-entropy)>opt.entropyThesh;

%% Restrict to pixels greater than noise
amplitude = amplitude(greaterthannoise);
freq_inds = freq_inds(greaterthannoise);
time_inds = find(greaterthannoise);


end
