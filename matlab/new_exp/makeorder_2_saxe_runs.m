function makeorder_2_saxe_runs(participant, version, user)
%% Generates 2 run/CSV scripts for Heather Kosakowskis's stimuli, containing 6 videos per block with 
%% a blank baseline block between each stim block.
%
% INPUT: Should be the subject name, the exp version number, and the user of the laptop. 
% OUTPUTS: 2 unique CSV files, one for each run. 
% 
% 
% STIMULI: 4 main stimulus categories with 2 subcategories each (totaling
% 8 stim blocks)
% 10) Faces: side, front
% 11) Limbs: hands, feet
% 12) Objects: collisions, shapes 
% 13) Scenes: fences, egomotion
% Blank is the baseline condition that occurs between every stimulus block
%
%% no task for the infant floc
%% VERSION: 1.0 8/13/2024 by CT
% Department of Psychology, Stanford University

%%%%%%%%%%%%%%%%%%%%%%%%%
% EXPERIMENTAL PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%
addpath(fullfile('/Users', user, 'Desktop', 'bbfloc', 'matlab', 'functions'));
participant_folder = fullfile('/Users', user, 'Desktop', 'bbfloc', 'psychopy', 'data', participant, 'exp_v1');
stim_dir = fullfile('/Users', user, 'Desktop', 'bbfloc', 'stimuli', 'saxestim_wfixation');

% Stimulus categories 
cats = {'Faces_side', 'Faces_front', 'Limbs_hands', 'Limbs_feet', 'Objects_collisions', 'Objects_shapes', 'Scenes_fences', 'Scenes_egomotion'};

ncats = length(cats); % number of stimulus conditions
nconds = ncats;  % number of conditions to be counterbalanced (including baseline blocks)
% Map the original category index to a new index
category_mapping = [10, 11, 12, 13, 14, 15, 16, 17, 18];

% Presentation and design parameters
nruns = 2; % number of runs
nreps = 1; % number of  blocks per category per run
vidsperblock = 6;
viddur = 2.6667;  %stimulus presentation time (secs)

nblocks = nconds*nreps; % number of blocks in a run
ntrials = nblocks*vidsperblock; % number of trials in a run
blockdur =  vidsperblock*viddur; % block duration (sec)
rundur = nblocks*blockdur; % run duration (sec)

% Get user input and concatenate it into the file path
if version == 1
    exp = 'exp_v1';
elseif version == 2
    exp = 'exp_v2';
elseif version == 3
    exp = 'exp_v3';
end

participant_folder = fullfile('/Users', user, 'Desktop', 'bbfloc', 'psychopy', 'data', participant, exp);

% Create matrix for Block #
blockmat = zeros(ntrials,nruns);
for r = 1:nruns
    blockmat(:,r) = reshape(repmat(1:nblocks,vidsperblock,1),ntrials,1);
end

% Create matrix for Condition without consecutive repetitions
condmat = zeros(ntrials,nruns);
for r = 1:nruns
    condvec = [randperm(ncats)];    % generate the order of the stim presentation
    % Check for consecutive repetitions and reshuffle if found
    while any(diff(condvec) == 0)
        condvec = [randperm(ncats)];
    end
    condvec = [condvec'];
    condmat(:, r) = reshape(repmat(condvec', vidsperblock, 1), ntrials, 1);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%
% GENERATE MATRIX FOR STIMULI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stimmat = cell(ntrials, nruns); % Initialize cell array for videos

for r = 1:nruns
    for cat = 1:ncats
        % Generate unique video numbers for this condition and run
        vidnums = randperm(vidsperblock); % Random permutation of numbers from 1 to vidsperblock
        vidcounter = 0;
        
        for tri = 1:ntrials
            if condmat(tri,r) == cat %check if current trial in the run corresponds with the category 
                    vidcounter = vidcounter + 1;
                    stimmat{tri,r} = strcat(lower(cats{cat}),'-',num2str(vidnums(vidcounter)),'.mp4')
                % Stop if we have already assigned all images and videos for this block
                if vidcounter == vidsperblock
                    break;
                end
            end
        end
    end
end

disp(stimmat)
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Write CSV 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% Path to the directory containing video files
stim_directory = fullfile('/Users', user, 'Desktop', 'bbfloc',  'stimuli', 'saxestim_wfixation');
for r = 1:nruns

    % First Determine the run number based off the exp version
    if version == 1
        run_number = (r == 1) * 1 + (r ~= 1) * 4; 
    elseif version == 2
        run_number = (r == 1) * 2 + (r ~= 1) * 5;
    elseif version == 3
        run_number = (r == 1) * 3 + (r ~= 1) * 6;
    end
    
    csvfilename = fullfile(participant_folder, strcat('script_saxe_newexp_run', num2str(run_number), '.csv'));
    fid = fopen(csvfilename, 'w');
    if fid == -1
        error('Failed to open file: %s', csvfilename);
    end
    fprintf(fid, 'Block #,Onset-time(s),Category,TaskMatch,Video Name,Video Path,Video Dur\n');

    onset_time = 0; 
    current_block = 1; 
    
    % Write initial baseline block
    write_baseline_block_dynamic(fid, current_block, onset_time, stim_directory);
    onset_time = onset_time + 4 * 2; % Adjusted for 2 blank trials
    current_block = current_block + 1;
    
    % Loop through trials
    for i = 1:ntrials 
        original_category_index = condmat(i, r);
        mapped_category_index = category_mapping(original_category_index); 
        vid_name = stimmat{i, r};
        stim_path = fullfile(stim_dir, vid_name);
        
        % Determine if the current trial is the last in the block
        if mod(i,6) == 0
            % Reduce the duration of the last trial by 0.0002 seconds
            fprintf(fid, '%i,%f,%i,%s,%s,%s,%f\n', ...
                current_block, onset_time, mapped_category_index, cats{original_category_index}, vid_name, stim_path, viddur - 0.0002);
        else
            fprintf(fid, '%i,%f,%i,%s,%s,%s,%f\n', ...
                current_block, onset_time, mapped_category_index, cats{original_category_index}, vid_name, stim_path, viddur);
        end

        % Update onset time based on trial
        if mod(i,6) == 0
            onset_time = onset_time + (viddur - 0.0002);
        else
            onset_time = onset_time + viddur;
        end

        % Insert blank block if condmat changes 
        if i < ntrials && condmat(i, r) ~= condmat(i + 1, r) 
            current_block = current_block + 1;
            write_baseline_block_dynamic(fid, current_block, onset_time, stim_directory);
            onset_time = onset_time + 4 * 2; % Adjusted for 2 blank trials
            current_block = current_block + 1;
        end
    end

    % Write closing baseline block
    current_block = current_block + 1;
    write_baseline_block_dynamic(fid, current_block, onset_time, stim_directory);
    onset_time = onset_time + 4 * 2; % Adjusted for 2 blank trials
    current_block = current_block + 1;
    
    fclose(fid); % Close the file after writing
end
