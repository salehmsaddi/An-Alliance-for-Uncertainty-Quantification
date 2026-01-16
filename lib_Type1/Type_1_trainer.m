function results = Type_1_trainer(data,output_membership_type,learnRate,number_of_epoch,plotFrequency,mbs,number_mf,number_inputs,number_outputs,training_num, where_to_save,how_to_save)

%%

gradDecay = 0.9;
sqGradDecay = 0.999;

averageGrad = [];
averageSqGrad = [];



data_size = max(size(data));
test_num = data_size-training_num;



idx = randperm(data_size);

Training_temp = data(idx(1:training_num),:);
Testing_temp = data(idx(training_num+1:end),:);

%% Zscore normalization


[xn,input_mean,input_std] = zscore(Training_temp(:,1:number_inputs));
[yn,output_mean,output_std] = zscore(Training_temp(:,number_inputs+1:end));


% needed for multi outputs
% output_std = output_std';
% output_mean = output_mean';
% input_std = input_std';
% input_mean = input_mean';

Training_temp = [xn yn];

Testing_temp(:,1:number_inputs) = (Testing_temp(:,1:number_inputs) - input_mean)./input_std;
Testing_temp(:,number_inputs+1:end) = (Testing_temp(:,number_inputs+1:end) - output_mean)./output_std;

%%

%training data
Train.inputs = reshape(Training_temp(:,1:number_inputs)', [1, number_inputs, training_num]); % traspose come from the working mechanism of the reshape, so it is a must
Train.outputs = reshape(Training_temp(:,(number_inputs+1:end))', [1, number_outputs, training_num]);

Train.inputs = dlarray(Train.inputs);
Train.outputs = dlarray(Train.outputs);

%testing data
Test.inputs = reshape(Testing_temp(:,1:number_inputs)', [1, number_inputs, test_num]);
Test.outputs = reshape(Testing_temp(:,(number_inputs+1:end))', [1, number_outputs, test_num]);

%% init

Learnable_parameters = initialize_Glorot_Kmeans(Train.inputs, Train.outputs, number_mf ,output_membership_type);
prev_learnable_parameters = Learnable_parameters;
%% create mini batch

[mini_batch_inputs, targets] = create_mini_batch(Train.inputs, Train.outputs, mbs);
%% denormalizing for plotting
yTrue_train = ((reshape(Train.outputs,[number_outputs, training_num])).*output_std)+output_mean;
yTrue_test = ((reshape(Test.outputs,[number_outputs, test_num])).*output_std)+output_mean;
%%

number_of_iter_per_epoch = floorDiv(size(Train.inputs, 3), mbs);

number_of_iter = number_of_epoch * number_of_iter_per_epoch;


for iter = 1:number_of_iter


    [loss, gradients, yPred_train] = dlfeval(@fismodelLoss, mini_batch_inputs, number_inputs, targets,number_outputs, number_mf, mbs, Learnable_parameters, output_membership_type);
    [Learnable_parameters, averageGrad, averageSqGrad] = adamupdate(Learnable_parameters, gradients, averageGrad, averageSqGrad,...
        iter, learnRate, gradDecay, sqGradDecay);



    if mod(iter,number_of_iter_per_epoch) == 0

        [mini_batch_inputs, targets] = create_mini_batch(Train.inputs, Train.outputs, mbs);


        %testing in each epoch
        yPred_test = fismodel(Test.inputs, number_mf, number_inputs,number_outputs, test_num, Learnable_parameters, output_membership_type);

        yPred_test = ((reshape(yPred_test, [1, max(size(Test.inputs))])).*output_std)+output_mean;

        
        if ((iter/number_of_iter_per_epoch) == 70)
            learnRate = learnRate/10;
        end
        if output_membership_type == "IV" || output_membership_type == "IVL"
            yPred_test = ((reshape(yPred_test(1, 3, :), [number_outputs, test_num])).*output_std)+output_mean;
        else
            yPred_test = ((reshape(yPred_test, [number_outputs, test_num])).*output_std)+output_mean;
        end




        iter_plot((iter/number_of_iter_per_epoch),plotFrequency,loss,yTrue_test,yPred_test);



    end


end

%% calculate rmse

%inference

yPred_train = fismodel(Train.inputs, number_mf, number_inputs,number_outputs, training_num, Learnable_parameters, output_membership_type);
yPred_test = fismodel(Test.inputs, number_mf, number_inputs,number_outputs, test_num, Learnable_parameters, output_membership_type);


if output_membership_type == "IV" || output_membership_type == "IVL"
    yPred_train = yPred_train(:,3,:);
    yPred_test = yPred_test(:,3,:);
end

%denorm
yPred_train = ((reshape(yPred_train,[number_outputs,training_num]).*output_std)+output_mean);
yPred_test = ((reshape(yPred_test,[number_outputs,test_num]).*output_std)+output_mean);


%rmse
train_RMSE = rmse(yPred_train',yTrue_train');
test_RMSE = rmse(yPred_test',yTrue_test');

results.train_RMSE = gather(extractdata(train_RMSE));
results.test_RMSE = gather(extractdata(test_RMSE));

% clear the persistent values in the plot function
clear iter_plot;


%%
cd(where_to_save)

if ~exist(how_to_save, 'dir')
    mkdir(how_to_save);
end

cd(how_to_save)
savefig
save


end

