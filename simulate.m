clc;clear;
close all;

warning('off', 'all');

addpath('lib_Type1\')
addpath('lib_Type2\')
addpath('helpers\')
addpath('datatsets\')

confidence_vector = [0.90 , 0.95 , 0.99];
save_flag = "down";

n_trials = 10;


%%
number_of_epoch = 100;
input_membership_type = "gaussmf";
fuzzy_set_type ="HS";
tnorm = "HTSK2";
output_membership_type = "linear";
CSCM = "WKM";                              % Choose betweem "KM" & "WKM"


%% Boston
load Boston.mat
dataset_name = "Boston";

x = data(:, 1 : end-1);
y = data(:, end);

data = [x y];

training_num = 354;
cal_num = 99;
mbs = 64; %mini batch size
learnRate = 0.01;
number_mf = 5;
number_of_rules = 5;

%%

data_size = size(data,1);
test_num = data_size-training_num;
propTrain_num = training_num - cal_num;

PICP_IT2 = zeros(n_trials , numel(confidence_vector));
PICP_CQR_IT2 = zeros(n_trials , numel(confidence_vector));
PICP_CQRm_IT2 = zeros(n_trials , numel(confidence_vector));
PICP_CQRr_IT2 = zeros(n_trials , numel(confidence_vector));
PICP_SCP_IT2 = zeros(n_trials , numel(confidence_vector));
PICP_SCP_T1 = zeros(n_trials , numel(confidence_vector));

PINAW_IT2 = zeros(n_trials , numel(confidence_vector));
PINAW_CQR_IT2 = zeros(n_trials , numel(confidence_vector));
PINAW_CQRm_IT2 = zeros(n_trials , numel(confidence_vector));
PINAW_CQRr_IT2 = zeros(n_trials , numel(confidence_vector));
PINAW_SCP_IT2 = zeros(n_trials , numel(confidence_vector));
PINAW_SCP_T1 = zeros(n_trials , numel(confidence_vector));


%% configuration of IT2-FLS

u = int2bit(0:(2^number_of_rules)-1,number_of_rules);

% Adam parameters
gradDecay = 0.9;
sqGradDecay = 0.999;
averageGrad = [];
averageSqGrad = [];

% plotting frequency
plotFrequency = 10;

% dataset seperation proportions
fracTrain = 0.7;
fracTest = 0.3;

number_inputs = size(x,2);
number_outputs = size(y,2);


% Normalization upfront
[xn,input_mean,input_std] = zscore_norm(x);
[yn,output_mean,output_std] = zscore_norm(y);


data = [xn yn];

%%
tic
for trial = 1 : n_trials

    fprintf('trial = %d\n', trial);
    
    seed = randi([0 10000]) + (123 * trial); 

    rng(seed)

    idx = randperm(data_size);

    Training_temp = data(idx(1:training_num),:);
    Testing_temp = data(idx(training_num+1:end),:);



    Calibration_temp = Training_temp(1:cal_num , :);
    propTraining_temp = Training_temp(cal_num + 1 : end , :);

    %%calibration data
    Calib.inputs = reshape(Calibration_temp(:,1:number_inputs)', [1, number_inputs, cal_num]);
    Calib.outputs = reshape(Calibration_temp(:,(number_inputs+1:end))', [1, number_outputs, cal_num]);

    %training data
    Train.inputs = reshape(propTraining_temp(:,1:number_inputs)', [1, number_inputs, propTrain_num]); % traspose come from the working mechanism of the reshape, so it is a must
    Train.outputs = reshape(propTraining_temp(:,(number_inputs+1:end))', [1, number_outputs, propTrain_num]);

    Train.inputs = dlarray(Train.inputs);
    Train.outputs = dlarray(Train.outputs);

    %testing data
    Test.inputs = reshape(Testing_temp(:,1:number_inputs)', [1, number_inputs, test_num]);
    Test.outputs = reshape(Testing_temp(:,(number_inputs+1:end))', [1, number_outputs, test_num]);


    yTrue_calib = reshape(Calib.outputs,[number_outputs, cal_num]);
    yTrue_train = reshape(Train.outputs,[number_outputs, propTrain_num]);
    yTrue_test = reshape(Test.outputs,[number_outputs, test_num]);



    %% T1 Initialization & Training

    number_of_iter_per_epoch = floorDiv(propTrain_num, mbs);
    number_of_iter = number_of_epoch * number_of_iter_per_epoch;

    averageGrad_T1 = [];
    averageSqGrad_T1 = [];
    
    Learnable_parameters_T1 = initialize_Glorot_Kmeans(Train.inputs, Train.outputs, number_mf ,output_membership_type);

    global_iteration = 1;
    
    for epoch_T1 = 1: number_of_epoch
    
        [batch_inputs, batch_targets] = create_mini_batch(Train.inputs, Train.outputs, propTrain_num);
        for iter = 1:number_of_iter_per_epoch
    
            [mini_batch_inputs_T1, targets_T1] = call_batch(batch_inputs, batch_targets,iter,mbs);
    
            [loss_T1, gradients_T1, ~] = dlfeval(@fismodelLoss, mini_batch_inputs_T1, number_inputs, targets_T1,number_outputs, number_mf, mbs, Learnable_parameters_T1, output_membership_type);
    
    
            [Learnable_parameters_T1, averageGrad_T1, averageSqGrad_T1] = adamupdate(Learnable_parameters_T1, gradients_T1, averageGrad_T1, averageSqGrad_T1,...
                iter, learnRate, gradDecay, sqGradDecay);
    
            global_iteration = global_iteration + 1;
    
        end
    end
    
    % Inference
    yPred_calib_T1 = fismodel(Calib.inputs, number_mf, number_inputs,number_outputs,length(Calib.inputs), Learnable_parameters_T1, output_membership_type);
    yPred_train_T1 = fismodel(Train.inputs, number_mf, number_inputs,number_outputs,length(Train.inputs), Learnable_parameters_T1, output_membership_type);
    yPred_test_T1 = fismodel(Test.inputs, number_mf, number_inputs,number_outputs,length(Test.inputs), Learnable_parameters_T1, output_membership_type);
    
    if height(yPred_test_T1) ~= 1
        yPred_calib_T1 = yPred_calib_T1(3,1,:);
        yPred_train_T1 = yPred_train_T1(3,1,:);
        yPred_test_T1 = yPred_test_T1(3,1,:);
    end

    yPred_calib_T1 = reshape(yPred_calib_T1, [number_outputs, size(Calib.inputs,3)]);
    yPred_train_T1 = reshape(yPred_train_T1, [number_outputs, size(Train.inputs,3)]);
    yPred_test_T1 = reshape(yPred_test_T1, [number_outputs, size(Test.inputs,3)]);


    %% IT2 Initialization & Training

    Learnable_parameters = initialize_Glorot_IT2(Train.inputs,fuzzy_set_type, Train.outputs, output_membership_type, number_of_rules, CSCM);  
    global_iteration = 1;


    
    for ii = 1 : numel(confidence_vector)

        confidence = confidence_vector(ii);

        for epoch = 1: number_of_epoch

            [batch_inputs, batch_targets] = create_mini_batch(Train.inputs, Train.outputs, propTrain_num);

            for iter = 1:number_of_iter_per_epoch

                [mini_batch_inputs, targets] = call_batch(batch_inputs, batch_targets,iter,mbs);
                
                %calculating loss and gradient
                [loss, gradients, ~, ~, ~] = dlfeval(@Copy_of_IT2_fismodelLoss, mini_batch_inputs ,...
                    number_inputs, targets,number_outputs, number_of_rules, mbs, Learnable_parameters, output_membership_type,...
                    input_membership_type,fuzzy_set_type,CSCM,u,tnorm, confidence);
                
                % updating parameters
                [Learnable_parameters, averageGrad, averageSqGrad] = adamupdate(Learnable_parameters, gradients, averageGrad, averageSqGrad,...
                    global_iteration, learnRate, gradDecay, sqGradDecay);

                global_iteration = global_iteration + 1;

            end
        end


        % Inference
        [yPred_calib_lower, yPred_calib_upper, yPred_calib] = IT2_fismodel(Calib.inputs, number_of_rules, number_inputs,number_outputs,length(Calib.inputs), Learnable_parameters, output_membership_type,input_membership_type,fuzzy_set_type,CSCM,u,tnorm);
        [yPred_train_lower, yPred_train_upper, yPred_train] = IT2_fismodel(Train.inputs, number_of_rules, number_inputs,number_outputs,length(Train.inputs), Learnable_parameters, output_membership_type,input_membership_type,fuzzy_set_type,CSCM,u,tnorm);
        [yPred_test_lower, yPred_test_upper, yPred_test] = IT2_fismodel(Test.inputs, number_of_rules, number_inputs,number_outputs,length(Test.inputs), Learnable_parameters, output_membership_type,input_membership_type,fuzzy_set_type,CSCM,u,tnorm);


        yPred_calib = reshape(yPred_calib, [number_outputs, size(Calib.inputs,3)]);
        yPred_calib_upper = reshape(yPred_calib_upper, [number_outputs, size(Calib.inputs,3)]);
        yPred_calib_lower = reshape(yPred_calib_lower, [number_outputs, size(Calib.inputs,3)]);

        yPred_train = reshape(yPred_train, [number_outputs, size(Train.inputs,3)]);
        yPred_train_upper = reshape(yPred_train_upper, [number_outputs, size(Train.inputs,3)]);
        yPred_train_lower = reshape(yPred_train_lower, [number_outputs, size(Train.inputs,3)]);

        yPred_test = reshape(yPred_test, [number_outputs, size(Test.inputs,3)]);
        yPred_test_upper = reshape(yPred_test_upper, [number_outputs, size(Test.inputs,3)]);
        yPred_test_lower = reshape(yPred_test_lower, [number_outputs, size(Test.inputs,3)]);

        crossing_flag_calib = any(yPred_calib_upper< yPred_calib_lower);
        crossing_flag_train = any(yPred_train_upper< yPred_train_lower);
        crossing_flag_test = any(yPred_test_upper< yPred_test_lower);


        %% CP
        intervals_list_IT2 = [yPred_test_lower ; yPred_test_upper]';

        
        
        intervals_list_CQR_IT2 = CQR(yPred_calib_lower, yPred_calib_upper, yTrue_calib, confidence, ...
                                    yPred_test_upper, yPred_test_lower);

        intervals_list_CQRm_IT2 = CQRm(yPred_calib_lower, yPred_calib_upper, yPred_calib, yTrue_calib, confidence, ...
                                    yPred_test_upper, yPred_test_lower, yPred_test);

        intervals_list_CQRr_IT2 = CQRr(yPred_calib_lower, yPred_calib_upper, yTrue_calib, confidence, ...
                                    yPred_test_upper, yPred_test_lower);

        intervals_list_SCP_IT2 = CP(yTrue_calib, confidence, yPred_calib, yPred_test);

        intervals_list_SCP_T1 = CP(yTrue_calib, confidence, yPred_calib_T1, yPred_test_T1);


        PICP_IT2(trial, ii) = get_PICP(yTrue_test', intervals_list_IT2);
        PINAW_IT2(trial, ii) = get_PINAW(yTrue_test', intervals_list_IT2);

        PICP_CQR_IT2(trial, ii) = get_PICP(yTrue_test', intervals_list_CQR_IT2);
        PINAW_CQR_IT2(trial, ii) = get_PINAW(yTrue_test', intervals_list_CQR_IT2);

        PICP_CQRm_IT2(trial, ii) = get_PICP(yTrue_test', intervals_list_CQRm_IT2);
        PINAW_CQRm_IT2(trial, ii) = get_PINAW(yTrue_test', intervals_list_CQRm_IT2);

        PICP_CQRr_IT2(trial, ii) = get_PICP(yTrue_test', intervals_list_CQRr_IT2);
        PINAW_CQRr_IT2(trial, ii) = get_PINAW(yTrue_test', intervals_list_CQRr_IT2);

        PICP_SCP_IT2(trial, ii) = get_PICP(yTrue_test', intervals_list_SCP_IT2);
        PINAW_SCP_IT2(trial, ii) = get_PINAW(yTrue_test', intervals_list_SCP_IT2);

        PICP_SCP_T1(trial, ii) = get_PICP(yTrue_test', intervals_list_SCP_T1);
        PINAW_SCP_T1(trial, ii) = get_PINAW(yTrue_test', intervals_list_SCP_T1);


    end


end


%% Store the results in a .mat file
clc

% Define model names
modelNames = {'SCP_T1', 'SCP_IT2', 'IT2', 'CQR_IT2', 'CQRm_IT2', 'CQRr_IT2'};

% Initialize results structure
results = struct();

% Loop over each prefix
prefixes = {'PICP', 'PINAW'};
for p = 1:length(prefixes)
    prefix = prefixes{p};

    % Loop over each model name
    for m = 1:length(modelNames)
        modelName = modelNames{m};

        % Construct the variable name for the current prefix and model
        varName = sprintf('%s_%s', prefix, modelName);

        % Check if the variable exists in the workspace
        if evalin('base', sprintf('exist(''%s'', ''var'')', varName))
            % Get the variable's value from the workspace
            value = evalin('base', varName);

            % Assign the value to the results structure
            results.(sprintf('%s_%s', prefix, modelName)) = value;
        else
            warning('Variable %s does not exist in the workspace.', varName);
        end
    end
end

results.config.dataset_name = dataset_name;
results.config.data_size = data_size;
results.config.propTrain_num = propTrain_num;
results.config.cal_num = cal_num;
results.config.test_num = test_num;
results.config.mbs = mbs;
results.config.number_of_epoch = number_of_epoch;
results.config.number_of_rules = number_of_rules;
results.config.input_membership_type = input_membership_type;
results.config.fuzzy_set_type = fuzzy_set_type;
results.config.tnorm = tnorm;
results.config.output_membership_type = output_membership_type;
results.config.CSCM = CSCM;

file_name = sprintf('%s_%s_%s.mat', dataset_name, tnorm, CSCM);
save(file_name,'results');


%%
function [X0, targets]  = create_mini_batch(X, yTrue, minibatch_size)

shuffle_idx = randperm(size(X, 3), minibatch_size);

X0 = X(:, :, shuffle_idx);
targets = yTrue(:, :, shuffle_idx);

if canUseGPU %checking if there is a GPU available
    X0 = gpuArray(X0);
    targets = gpuArray(targets);
end

end


%%
function [mini_batch_inputs, targets] = call_batch(batch_inputs, batch_targets,iter,mbs)

mini_batch_inputs = batch_inputs(:, :, ((iter-1)*mbs)+1:(iter*mbs));
targets = batch_targets(:, :, ((iter-1)*mbs)+1:(iter*mbs));


end