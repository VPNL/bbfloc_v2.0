function write_baseline_block_static(fid, block, onset_time, stim_directory) 
% this function writes baseline trials for static runs
% CT 8/24
    stimdur = 0.5; 
    for j = 1:16 %loop thru each trial
         random_index = randi([1, 144]); %pick a random image for the current trial
            blank_img_name = sprintf('%s-%d.jpg', 'blank', random_index); %generate image name for the current trial
            blank_img_path = fullfile(stim_directory, blank_img_name); %generate image path for the current trial
            fprintf(fid, '%i,%f,%i,%s,%s,%s\n', ...
                block,... % write blank block
                onset_time,... % write blank onset time
                0, ... % write blank condition
                'Blank', ... % write blank category
                blank_img_name, ... % empty image name
                blank_img_path); % empty image path
         onset_time = onset_time + stimdur; % Update onset time for the next blank imag   
    end
end
