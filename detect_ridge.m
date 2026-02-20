function [amplitude, freq_inds, time_inds] = detect_ridge(spect)
%% Ridge Detection
% Calculate entropy at each time point
entropy = geomean(spect,1) ./ mean(spect,1);
entropy= smooth(entropy,0.1,'rlowess')';

AmplitudeThreshold= 0.8250;
EntropyThreshold= 0.2150;
brightThreshold=prctile(spect(:),AmplitudeThreshold*100);

%% Chose single pixel for each timepoint
[amplitude,freq_inds] = max(spect,[],1);

%% Get index of the time points where aplitude is greater than theshold
% % iteratively lower threshholds until at least 6 points are selected
% % threshold is lowered over a max of 10 iterations (38.55% of its original value) 

iter = 1;
greaterthannoise = false(1, size(spect, 2));
while sum(greaterthannoise)<5
    if iter==1
        greaterthannoise = greaterthannoise | amplitude  > brightThreshold;
        greaterthannoise = greaterthannoise & 1-entropy  > EntropyThreshold;
    else
        greaterthannoise = greaterthannoise | amplitude  > brightThreshold / 1.1 ^ iter;
        greaterthannoise = greaterthannoise & 1-entropy > EntropyThreshold / 1.1 ^ iter;
    end
    iter = iter + 1;
    if iter > 2
        disp('Not enough contour points: lowering threshold')
    end
    if iter > 10
       disp('Warning: Extremely short call or no discernable contour')
       greaterthannoise = false(1,width(freq_inds));
       break
    end
end

%% Restrict to pixels greater than noise
amplitude = amplitude(greaterthannoise);
freq_inds = freq_inds(greaterthannoise);
time_inds = find(greaterthannoise);

%% Try smoothing over frequency
try
    freq_inds = smooth(time_inds, freq_inds, 0.025, 'rlowess');
    freq_inds = round(freq_inds);
catch
    disp('Cannot apply smoothing. The line is probably too short');
end

end
