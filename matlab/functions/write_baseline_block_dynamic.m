function write_baseline_block_dynamic(fid, block, onset_time, stim_directory)
% this function writes baseline trials for dynamic runs
% CT 8/24
    stim_dur = 4.00; 
    for j = 1:2
        random_index = randi([1, 48]);
        blank_vid_name = strcat('blank', "-", num2str(random_index), ".mp4");
        blank_vid_path = fullfile(stim_directory, blank_vid_name);
        fprintf(fid, '%i,%f,%i,%s,%s,%s,%i\n', ...
            block, onset_time, 0, 'Blank', blank_vid_name, blank_vid_path,stim_dur);
        onset_time = onset_time + stim_dur;
    end
end
