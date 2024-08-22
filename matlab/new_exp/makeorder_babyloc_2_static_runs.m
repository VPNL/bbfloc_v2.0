function makeorder_babyloc_2_static_runs(participant, version)
%% Generates 2 runs/CSV scripts for functional
%% localizer for the infant scans containing 16 stimuli per block with presentation rates of
%% 2Hz. 

% INPUT: Should be the baby's number 
% OUTPUTS: Separate script files for each run of PTB experiment.
%
% STIMULI: 5 stimulus categories
% 1) Faces-S: adult set; static
% 2) Hands-S: limbs static
% 3) Cars-S: cars static
% 4) Scenes-S: places static indoor and outdoors 
% 5) Food-S: foods
%
%
% BLANKS: 1 blank block appears between each block of stimuli 
%
%% no task for the infant floc
%% VERSION: 1.0 9/29/2023 by AS & VN & XY & CT
% Department of Psychology, Stanford University
%%%%%%%%%%%%%%%%%%%%%%%%%
% EXPERIMENTAL PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%

addpath(fullfile('/Users', user, 'Desktop', 'bbfloc', 'matlab', 'functions'));
% Stimulus categories (categories in same condition must be grouped)
cats = {'Faces-S', 'Limbs-S', 'Cars-S', 'Scenes-S', 'Food-S'};
ncats = length(cats); % number of stimulus conditions
nconds = ncats;  % number of conditions to be counterbalanced (including baseline blocks)

% Presentation and design parameters
nruns = 2; % number of runs
nreps = 3; % number of blocks per category per run
stimsperblock = 16; % number of stimuli in a block
stimdur = .5; % stimulus presentation time (secs)
TR = 2; % fMRI TR (secs)
propodd = .5;

nblocks = nconds*nreps; % number of blocks in a run
ntrials = nblocks*stimsperblock; % number of trials in a run
blockdur = stimsperblock*stimdur; % block duration (sec)
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENERATE STIMULUS SEQUENCES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Trials are grouped into blocks, and each block consists of trials from the same category.
% The order of blocks within a run is randomized due to the randomization of stimulus categories.

% Create matrix for Block #
blockmat = zeros(ntrials,nruns);
for r = 1:nruns
    blockmat(:,r) = reshape(repmat(1:nblocks,stimsperblock,1),ntrials,1);
end

% Create matrix for condition (stimulus category); where the randomness
% component comes from
condmat = zeros(ntrials,nruns);
for r = 1:nruns
    condvec = [randperm(ncats), randperm(ncats), randperm(ncats)]; % generate the order of the stim presentation
    % Check for consecutive repetitions of category and reshuffle if found;
    % ensure each category repeats exactly four times within a run
    while any(diff(condvec) == 0)
        condvec = [randperm(ncats), randperm(ncats), randperm(ncats)];
    end
    
    condvec = [condvec'];
    condmat(:, r) = reshape(repmat(condvec', stimsperblock, 1), ntrials, 1);
 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENERATE MATRIX FOR IMAGES 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
imgmat = cell(ntrials, nruns); %initialize cell array with dims ntrials x nruns

for r = 1:nruns
    for cat = 1:ncats
        stimnums = randperm(144);
        counter = 0;
        for tri = 1:ntrials
            if condmat(tri,r) == cat
                counter = counter + 1;
                imgmat{tri,r} = strcat(lower(cats{cat}(1:end-2)),'-',num2str(stimnums(counter)),'.jpg'); % assign unique image for each trial
            else
            end
        end
    end
end

disp(imgmat)

% Path to the directory containing image files
stim_directory = fullfile('/Users', user, 'Desktop', 'bbfloc', 'stimuli',  'updated_static_stimuli');


%%%%%%%%%%%%%%%%%%%
% WRITE CSV
%%%%%%%%%%%%%%%%%%%

for r = 1:nruns
    % First Determine the run numbers based off the exp version
    if version == 1
        run_number = (r == 1) * 2 + (r ~= 1) * 5; 
    elseif version == 2
        run_number = (r == 1) * 3 + (r ~= 1) * 6;
    elseif version == 3
        run_number = (r == 1) * 1 + (r ~= 1) * 4;
    end

    csvfilename = fullfile(participant_folder, strcat('script_babyloc_static_newexp_run', num2str(run_number), '.csv'));
    fid = fopen(csvfilename, 'w');
    fprintf(fid, 'Block #,Onset-time(s),Category,TaskMatch,Image Name,Image Path\n');

    onset_time = 0; %initalize onset time
    current_block = 1; % initalize block #

    write_baseline_block_static(fid, current_block, onset_time, stim_directory);
    onset_time = onset_time + stimdur * 16; % Account for the sixteen blank trials
    current_block = current_block + 1;

    % Iterate over each trial in ntrials
    for i = 1:ntrials

        % Write the stimulus block (from img_mat)
        img_name = imgmat{i, r};
        img_path = fullfile(stim_directory, img_name);

        fprintf(fid, '%i,%f,%i,%s,%s,%s\n', ...
            current_block,... % write trial block
            onset_time,... % write trial onset time
            condmat(i, r),... % write trial condition,
            cats{condmat(i, r)},... % write stimulus category
            img_name, ... % write image file name
            img_path); % write full image path

        % Update onset time for the next stimulus
        onset_time = onset_time + stimdur; % Update onset time for the next trial

        % Check if the next trial belongs to a different category
        if i < ntrials && condmat(i, r) ~= condmat(i + 1, r) 
            
            % Increment block number for the next stimulus trial
            current_block = current_block + 1;

            write_baseline_block_static(fid, current_block, onset_time, stim_directory);
            onset_time = onset_time + stimdur * 16;
            current_block = current_block + 1;
            
        end
    end     
    current_block = current_block + 1;
    write_baseline_block_static(fid, current_block, onset_time, stim_directory);
    onset_time = onset_time + stimdur * 2; % Account for the two blank trials
    current_block = current_block + 1;
    fclose(fid); % Close the file after writing
end
