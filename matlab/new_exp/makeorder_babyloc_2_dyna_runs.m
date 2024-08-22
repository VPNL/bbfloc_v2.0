function makeorder_babyloc_2_dyna_runs(participant, version, user)
%% Generates 2 runs/CSV scripts for dynamic condition for the infant scans containing 2 stimuli per block with presentation rates of
%% .25hz and a blank block between every other block.
%
% INPUT: Should be the baby's number 
% OUTPUTS: Separate script file for each run of psychopy experiment.
%
% STIMULI: 4 stimulus categories
% 6) Faces-D: adults sets
% 7) Hands-D: hands only - no limbs 
% 8) Cars-D: cars, excavators, dump trucks, rc cars
% 9) Scenes-D: places indoor and outdoors 

% Blank is the baseline condition that occurs between every stimulus block
%
%% no task for the infant floc
%% VERSION: 2.0 3/29/2024 by CT
% Department of Psychology, Stanford University

%%%%%%%%%%%%%%%%%%%%%%%%%
% EXPERIMENTAL PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%

addpath(fullfile('/Users', user, 'Desktop', 'bbfloc', 'matlab', 'functions'));

% Stimulus categories (categories in same condition must be grouped)
cats = {'Faces-D', 'Hands-D', 'Cars-D', 'Scenes-D'};

ncats = length(cats); % number of stimulus conditions
nconds = ncats;  % number of conditions to be counterbalanced (including baseline blocks)

% Presentation and design parameters
nruns = 2; % number of runs
nreps = 4; % number of blocks per category per run
stimsperblock = 2; % number of stimuli in a block
stimdur = 4; % stimulus presentation time (secs)
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

% Create matrix for Block #
blockmat = zeros(ntrials,nruns);
for r = 1:nruns
    blockmat(:,r) = reshape(repmat(1:nblocks,stimsperblock,1),ntrials,1);
end

% Create matrix for Condition without consecutive repetitions
condmat = zeros(ntrials,nruns);
for r = 1:nruns
    condvec = [randperm(4) randperm(4) randperm(4) randperm(4)];    % generate the order of the stim presentation
    % Check for consecutive repetitions and reshuffle if found
    while any(diff(condvec) == 0)
        condvec = [randperm(4) randperm(4) randperm(4) randperm(4)];
    end
    
    condvec = [condvec'];
    condmat(:, r) = reshape(repmat(condvec', stimsperblock, 1), ntrials, 1);
end

% Create cell array to store videos
vidmat = cell(ntrials,nruns);

% Create cell arrays of actor names for each category
faceact = cell(1, nruns);
handact = cell(1, nruns);
caract = cell(1, nruns);
sceneact = cell(1, nruns);

% Create cell arrays to keep track of used actors for each category
used_face_actors = cell(1, nruns);
used_hand_actors = cell(1, nruns);
used_car_actors = cell(1, nruns);
used_scene_actors = cell(1, nruns);


%% Shuffle order of actors for all categories, then define the video ranges for different actors
for r = 1:nruns
    % Shuffle the order of actors for the faces category
    faceact{r} = shuffle({'AX_faces', 'BP_faces', 'BS_faces', 'DO_faces', 'EC_faces', 'HO_faces', 'IK_faces', 'JC_faces', 'JO_faces', 'JY_faces', 'KP_faces', 'KW_faces', 'SE_faces', 'SS_faces'});
    %Define the video ranges for different faces
    faceVideoRanges = {
    'AX_faces', 3;
    'BP_faces', 4;
    'BS_faces', 3;
    'DO_faces', 4; 
    'EC_faces', 3;
    'HO_faces', 4;
    'IK_faces', 3; 
    'JC_faces', 3;
    'JO_faces', 4;
    'JY_faces', 4; 
    'KP_faces', 4; 
    'KW_faces', 3; 
    'SE_faces', 3; 
    'SS_faces', 3; 
};

    % Shuffle the order of actors for the hands category
    handact{r} = shuffle({'AX_hands', 'BP_hands', 'BS_hands', 'DO_hands', 'HO_hands', 'EC_hands', 'IK_hands', 'JC_hands', 'JO_hands', 'JY_hands', 'KP_hands', 'KW_hands', 'SE_hands', 'SS_hands'});
    %Define the video ranges for different hands
    handVideoRanges = {
    'AX_hands', 3;
    'BP_hands', 4;
    'BS_hands', 3;
    'DO_hands', 3; 
    'HO_hands', 3; 
    'EC_hands', 4;
    'IK_hands', 4; 
    'JC_hands', 3;
    'JO_hands', 4;
    'JY_hands', 4; 
    'KP_hands', 4; 
    'KW_hands', 3; 
    'SE_hands', 3; 
    'SS_hands', 3; 
};

     %Shuffle the order of actors for the cars category
    caract{r} = shuffle({'blackexcavator', 'blueexcavator', 'dumptruck1', 'dumptruck2', 'dumptruck3', 'dumptruck4', 'dumptruck5', 'dumptruck6', 'dumptruck7', 'dumptruck8', 'dumptruck9', 'car1', 'car2', 'car3', 'car4', 'car5', 'car6', 'car7', 'car8', 'car9', 'yellowexcavator', 'rccar', 'racecar'});
    %Define the video ranges for different types of cars 
    carVideoRanges = {
    'blackexcavator', 8;
    'blueexcavator', 11;
    'dumptruck1', 1;
    'dumptruck2', 1;
    'dumptruck3', 1;
    'dumptruck4', 1;
    'dumptruck5', 1;
    'dumptruck6', 1;
    'dumptruck7', 1;
    'dumptruck8', 1; 
    'dumptruck9', 1;
    'car1', 1; 
    'car2', 1;
    'car3', 1; 
    'car4', 1; 
    'car5', 2; 
    'car6', 1;
    'car7', 1; 
    'car8', 1; 
    'car9', 1; 
    'yellowexcavator', 7;
    'rccar', 2; 
    'racecar', 1;
};

    %Shuffle the order of actors for the scenes category; all have one
    %video so no need to define video ranges
    sceneact{r} = shuffle({'bigwaterfall', 'forest', 'grass', 'river', 'rockystream', 'shore', 'sky', 'smallwaterfall', 'snow', 'trees', 'volcano', 'waterfallpond', 'waves'});

    sceneVideoRanges = {
    'bigwaterfall', 4;
    'forest', 3;
    'grass', 3;
    'river', 6;
    'rockystream', 3;
    'shore', 4;
    'sky', 2;
    'smallwaterfall', 3;
    'snow', 2;
    'trees', 4; 
    'volcano', 6;
    'waterfallpond', 4; 
    'waves', 4;
};

    % Initialize used actors for each run
    used_face_actors{r} = {};
    used_hand_actors{r} = {};
    used_car_actors{r} = {};
    used_scene_actors{r} = {};

end

%% This loop is used to initialize variables and generate video file names for each run.
for r = 1:nruns

    %These counters will be used to keep track of how many video files have been generated for each category (face, hands, cars, scenes) in the current run.
    fcounter = 0;
    hcounter = 0;
    ccounter = 0;
    scounter = 0;

    for tri = 1:ntrials %Inside this loop, the code checks the value of condmat(tri, r) to determine the category for the current trial (tri) in the current run (r).
        if condmat(tri, r) == 1 % for face category
            fcounter = fcounter + 1;
            % Generate a random number within the length of unused face actors
            unused_actors = setdiff(faceact{r}, used_face_actors{r});
            if isempty(unused_actors)
                % If all actors have been used, shuffle the actors and reset the used list
                unused_actors = faceact{r};
                used_face_actors{r} = {};
            end
            actor_num = randi(length(unused_actors));
            actor_name = unused_actors{actor_num};
            used_face_actors{r} = [used_face_actors{r}, actor_name];
            face_range = faceVideoRanges{strcmp(faceVideoRanges(:, 1), actor_name), 2};
            vidmat{tri, r} = strcat([actor_name, '_', num2str(randi(face_range)), '.mp4']);
        elseif condmat(tri, r) == 2 % for hands category
            hcounter = hcounter + 1;
            % Generate a random number within the length of unused face actors
            unused_actors = setdiff(handact{r}, used_hand_actors{r});
            if isempty(unused_actors)
                % If all actors have been used, shuffle the actors and reset the used list
                unused_actors = handact{r};
                used_face_actors{r} = {};
            end
            actor_num = randi(length(unused_actors));
            actor_name = unused_actors{actor_num};
            used_hand_actors{r} = [used_hand_actors{r}, actor_name];
            hand_range = handVideoRanges{strcmp(handVideoRanges(:, 1), actor_name), 2};
            vidmat{tri, r} = strcat([actor_name, '_',  num2str(randi(hand_range)), '.mp4']);
        elseif condmat(tri, r) == 3 % for cars category
            ccounter = ccounter + 1;
            % Generate a random number within the length of unused car actors
            unused_actors = setdiff(caract{r}, used_car_actors{r});
            if isempty(unused_actors)
                % If all actors have been used, shuffle the actors and reset the used list
                unused_actors = caract{r};
                used_car_actors{r} = {};
            end
            actor_num = randi(length(unused_actors));
            actor_name = unused_actors{actor_num};
            used_car_actors{r} = [used_car_actors{r}, actor_name];
            car_range = carVideoRanges{strcmp(carVideoRanges(:, 1), actor_name), 2};
            vidmat{tri, r} = strcat([actor_name, '_', num2str(randi(car_range)), '.mp4']);
        elseif condmat(tri, r) == 4 % for scenes category
            scounter = scounter + 1;
            % Generate a random number within the length of unused car actors
            unused_actors = setdiff(sceneact{r}, used_scene_actors{r});
            if isempty(unused_actors)
                % If all actors have been used, shuffle the actors and reset the used list
                unused_actors = sceneact{r};
                used_scene_actors{r} = {};
            end
            actor_num = randi(length(unused_actors));
            actor_name = unused_actors{actor_num};
            used_scene_actors{r} = [used_scene_actors{r}, actor_name];
            scene_range = sceneVideoRanges{strcmp(sceneVideoRanges(:, 1), actor_name), 2};
            vidmat{tri, r} = strcat([actor_name, '_', num2str(randi(scene_range)), '.mp4']);

        end
    end
end

%% Path to the directory containing video files
stim_directory = fullfile('/Users', user, 'Desktop', 'bbfloc',  'stimuli', 'dynamic_stimuli_resized_fixation');

% Map the original category index to a new index
category_mapping = [6, 7, 8, 9, 0];


%% Loop to write CSV file for each run of the experiment in the participant folder

for r = 1:nruns 

    % First determine the run numbers based off the exp version
    if version == 1
        run_number = (r == 1) * 3 + (r ~= 1) * 6; 
    elseif version == 2
        run_number = (r == 1) * 1 + (r ~= 1) * 4;
    elseif version == 3
        run_number = (r == 1) * 2 + (r ~= 1) * 5;
    end
    
    csvfilename = fullfile(participant_folder, strcat('script_babyloc_dyna_newexp_run', num2str(run_number), '.csv'));
    fid = fopen(csvfilename, 'w');
    fprintf(fid, 'Block #,Onset-time(s),Category,TaskMatch,Video Name,Video Path\n');
    
    onset_time = 0; 
    current_block = 1; 
    
    % Write initial baseline block
    write_baseline_block_dynamic(fid, current_block, onset_time, stim_directory);
    onset_time = onset_time + stimdur * 2; % Account for the two blank trials
    current_block = current_block + 1;

    % Loop through trials
    for i = 1:ntrials 
        original_category_index = condmat(i, r);
        mapped_category_index = category_mapping(original_category_index);
        vid_name = vidmat{i, r};
        vid_path = fullfile(stim_directory, vid_name);
        
        fprintf(fid, '%i,%f,%i,%s,%s,%s\n', ...
            current_block, onset_time, mapped_category_index, cats{original_category_index}, vid_name, vid_path);

        onset_time = onset_time + stimdur;

        % Insert blank block if at the end of a stimulus block
        if mod(i, stimsperblock) == 0  
            current_block = current_block + 1;
            write_baseline_block_dynamic(fid, current_block, onset_time, stim_directory);
            onset_time = onset_time + stimdur * 2; % Account for the two blank trials
            current_block = current_block + 1;
        end
    end
    fclose(fid); % Close the file after writing
end
end


