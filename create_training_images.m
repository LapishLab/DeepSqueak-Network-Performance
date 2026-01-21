function create_training_images(input_dir, output_dir)
mat_files = fullfile(input_dir,{dir(fullfile(input_dir,"*.mat")).name}');
mkdir(fullfile(output_dir,"images"));     
% Get training settings
wind = .0032;
noverlap = .0016;
nfft = .0032;
imLength = .5;

TTable = table();

% m = [];
for k = 1:length(mat_files)
    d = load(mat_files(k));
    d.Calls = d.Calls((d.Calls.Box(:,1)+imLength) <  d.audiodata.Duration,:); % cut out calls within window length of file end
    d.Calls = d.Calls((d.Calls.Box(:,1)+d.Calls.Box(:,3)-imLength) > 0,:); % cut out calls within window length of file start
    
    if height(d.Calls)==0
        continue
    end

    [audio,Fs] = audioread(d.audiodata.Filename);
    

    call_start = d.Calls.Box(:, 1);
    call_width = d.Calls.Box(:, 3);
    call_stop = call_start + call_width;

    % Calculate Groups of Calls
    bout_inds = get_bout_inds(call_start,call_stop,imLength);
    % Choose cut times
    image_start_time = choose_cuts(bout_inds,call_start,call_stop, imLength);

    image_start_ind = round(image_start_time*Fs);
    image_stop_ind = round(imLength*Fs) + image_start_ind;

    vars = {'imageFilename', 'USV'};
    varTypes = {'string', 'cell'};

    file_table = table('Size', [length(image_start_ind), length(vars)], ...
              'VariableNames', vars, ...
              'VariableTypes', varTypes);

    for b = 1:length(image_start_ind)
        a = audio(image_start_ind(b):image_stop_ind(b));

        % Make the spectrogram
        [~, fr, ti, p] = spectrogram(a,round(Fs*wind),round(Fs*noverlap),round(Fs*nfft),Fs);
        % -- Auto Scale (p)
        im=autoScale(p);


        USV_inds = bout_inds(b,1):bout_inds(b,2);
        bout_boxes = d.Calls.Box(USV_inds,:);

        % convert box times to pixels
        bout_boxes(:,1) = bout_boxes(:,1) - image_start_time(b);
        bout_boxes(:,[1,3]) = bout_boxes(:,[1,3])/imLength*size(im,2);

        % convert box frequency to pixels
        bout_boxes(:,2) = bout_boxes(:,2) - min(fr);
        bout_boxes(:, [2,4])=bout_boxes(:, [2,4])/(max(fr)-min(fr))*size(im,1)*1000;
        bout_boxes(:,2) = size(im,1) - bout_boxes(:,2) - bout_boxes(:,4); %Compensate for vertical flip
        
        % round to nearest pixel
        bout_boxes = ceil(bout_boxes);

        % figure(1); clf; hold on
        % imagesc(im);
        % rectangle('Position',bout_boxes, 'EdgeColor',   'r')


        % resize images for 300x300 YOLO Network (Could be bigger but works nice)
        % targetSize = [413 413];
        % sz=size(im);
        % im = imresize(im,targetSize);
        % box = bboxresize(box,targetSize./sz);

        % sub = im(bout_boxes(1,2):(bout_boxes(1,2)+bout_boxes(1,4)), bout_boxes(1,1):(bout_boxes(1,1)+bout_boxes(1,3)));
        % m = [m,max(sub(:))];
        % imagesc(sub)
        % pause(0.1)

        filename = fullfile(output_dir, sprintf('images/%d_%d.png', k, b));
        imwrite(im, filename, 'BitDepth', 8);

        file_table.imageFilename(b)= filename;
        file_table.USV(b) = {bout_boxes};
    end
    TTable = cat(1,TTable,file_table);
end
output = struct();
output.TTable = TTable;
output.wind = wind;
output.noverlap = noverlap;
output.nfft=nfft;
output.imLength = imLength;
output.imScale=@autoScale;

output_filename = fullfile(output_dir,'img_table.mat');
save(output_filename,'-struct','output');

end


function [im] = autoScale(p)
p = sqrt(p); % amplitude instead of power
p = flipud(p);
% im = imadjust(p);
% im = p / max(p(:));
im=p/.002;
end


function inds = get_bout_inds(call_start,call_stop,image_width)
    buffer = .05; 
    inRange = triu(pdist2(call_start,call_stop) < (image_width-buffer));

    [row, col] = find(inRange);
    
    last_USV_ind = accumarray(row, col, [], @max, nan);
    last_USV_ind = last_USV_ind(~isnan(last_USV_ind));
    first_USV_ind = unique(row);
    
    
    repeats = [false; diff(last_USV_ind)==0];

    first_USV_ind(repeats) = [];
    last_USV_ind(repeats) = [];

    inds = [first_USV_ind, last_USV_ind];
end

function image_start = choose_cuts(bout_inds,call_start,call_stop,image_width)

    buffer = .01; 
    bout_start = call_start(bout_inds(:,1));
    bout_stop = call_stop(bout_inds(:,2));
    
    start_earliest = bout_stop - image_width + buffer;
    previous_call = call_stop(bout_inds(2:end,1)-1);
    start_earliest(2:end) = max([start_earliest(2:end),previous_call], [], 2);
    
    
    start_latest = bout_start-buffer;
    next_call = call_start(bout_inds(1:end-1,2)+1);
    start_latest(1:end-1) = min([start_latest(1:end-1), next_call-image_width], [], 2);
    
    
    rand_scale = randi([1,99], size(start_earliest))/100;
    image_start = start_earliest + rand_scale .* (start_latest-start_earliest);
end