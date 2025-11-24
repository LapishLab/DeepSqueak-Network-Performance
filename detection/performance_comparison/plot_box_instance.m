function plot_box_instance(target_box, other_boxes, audio_file)
mid_time = target_box(1) + target_box(3)/2;
window_size = 0.5;
time_range = [mid_time-window_size/2, mid_time+window_size/2];


plot_spectrum(audio_file, time_range(1), time_range(2))
plot_boxes(target_box, 'green')

% TODO: restrict other boxes to within this window
plot_boxes(other_boxes, 'blue')

[~,filename,~] = fileparts(audio_file);
title(strrep(filename, '_', '\_'))


while true
    in = input("  Change color limits with: h+, h-, l+, l- \n" + ...
        "  Or hit enter to continue to next USV \n", "s");
    switch in
        case "h+"
            clim(clim() .* [1 1.5])
        case "h-"
            clim(clim() .* [1 0.75])
        case "l+"
            clim(clim() .* [1.5 1])
        case "l-"
            clim(clim() .* [.75 1])
        otherwise
            break
    end
end


end

function plot_boxes(boxes, color)
    for i=1:height(boxes)
        rectangle('pos', boxes(i,:), EdgeColor=color)
    end
end