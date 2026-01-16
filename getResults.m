clc;clear;
close all;


addpath('helpers\')

DatasetName = 'Boston';

SAVETITLE = sprintf('%s_CWC_Fig', DatasetName);

%%
load(sprintf('%s_HTSK2_KM.mat', DatasetName));

dataset_name = sprintf('%s %s %s', results.config.dataset_name, results.config.tnorm, results.config.CSCM);

%%
confidence_vector = [0.90 , 0.95 , 0.99];
modelName = {'SCP_T1', 'SCP_IT2', 'IT2', 'CQR_IT2', 'CQRm_IT2', 'CQRr_IT2'};


struct2vars(results)

% CWC calculation
for modelNameIndex = 1 : length(modelName)

    vecNamePICP = sprintf('PICP_%s', string(modelName(modelNameIndex)));
    vecNamePINAW = sprintf('PINAW_%s', string(modelName(modelNameIndex)));
    vecNameCWC = sprintf('CWC_%s', string(modelName(modelNameIndex)));

    PICPtemp = eval(vecNamePICP);
    PINAWtemp = eval(vecNamePINAW);
 
    eta = 25;
    CWC_result = computeCWC(PICPtemp', PINAWtemp', confidence_vector, eta)';
    

    eval([vecNameCWC ' = CWC_result;']);

end

for ii = 1 : numel(confidence_vector)
    confidence = confidence_vector(ii) * 100;

    PICPexpName = sprintf('Experiment_PICP_%d', confidence);
    PINAWexpName = sprintf('Experiment_PINAW_%d', confidence);
    CWCexpName = sprintf('Experiment_CWC_%d', confidence);

    tempPICP = [];
    tempPINAW = [];
    tempCWC = [];


    for modelNameIndex = 1 : length(modelName)

        vecNamePICP = sprintf('PICP_%s', string(modelName(modelNameIndex)));
        tempvec = eval(vecNamePICP);
        tempPICP = [tempPICP ; tempvec(:, ii)*100];

        vecNamePINAW = sprintf('PINAW_%s', string(modelName(modelNameIndex))); 
        tempvec = eval(vecNamePINAW);
        tempPINAW = [tempPINAW ; tempvec(:, ii)];

        vecNameCWC = sprintf('CWC_%s', string(modelName(modelNameIndex))); 
        tempvec = eval(vecNameCWC);
        tempCWC = [tempCWC ; tempvec(:, ii)];
    end

    assignin('base', PICPexpName, tempPICP);
    assignin('base', PINAWexpName, tempPINAW);
    assignin('base', CWCexpName, tempCWC);
end



PICP_all_KM = [90 - Experiment_PICP_90 ; 95 - Experiment_PICP_95 ; 99 - Experiment_PICP_99];
PINAW_all_KM = [Experiment_PINAW_90 ; Experiment_PINAW_95 ; Experiment_PINAW_99];
CWC_all_KM = [Experiment_CWC_90 ; Experiment_CWC_95 ; Experiment_CWC_99];


for ii = 1 : numel(confidence_vector)
    confidence = confidence_vector(ii) * 100;

    PICPexpName = sprintf('mockExperiment_PICP_%d', confidence);
    PINAWexpName = sprintf('mockExperiment_PINAW_%d', confidence);
    CWCexpName = sprintf('mockExperiment_CWC_%d', confidence);

    tempPICP = [];
    tempPINAW = [];
    tempCWC = [];


    for modelNameIndex = 1 : length(modelName)

        vecNamePICP = sprintf('PICP_%s', string(modelName(modelNameIndex)));
        tempvec = eval(vecNamePICP);
        tempPICP = [tempPICP , tempvec(:, ii)*100];

        vecNamePINAW = sprintf('PINAW_%s', string(modelName(modelNameIndex))); 
        tempvec = eval(vecNamePINAW);
        tempPINAW = [tempPINAW , tempvec(:, ii)];

        vecNameCWC = sprintf('CWC_%s', string(modelName(modelNameIndex)));
        tempvec = eval(vecNameCWC);
        tempCWC = [tempCWC , tempvec(:, ii)];
    end

    assignin('base', PICPexpName, tempPICP);
    assignin('base', PINAWexpName, tempPINAW);
    assignin('base', CWCexpName, tempCWC);
end


Table_KM = table(    round(mean(mockExperiment_PICP_90), 3)', ...
                         round(mean(mockExperiment_PINAW_90), 3)', ...
                         round(mean(mockExperiment_CWC_90), 3)', ...
                         round(mean(mockExperiment_PICP_95), 3)', ...
                         round(mean(mockExperiment_PINAW_95), 3)', ...
                         round(mean(mockExperiment_CWC_95), 3)', ...
                         round(mean(mockExperiment_PICP_99), 3)', ...
                         round(mean(mockExperiment_PINAW_99), 3)', ...
                         round(mean(mockExperiment_CWC_99), 3)');


%%
load(sprintf('%s_HTSK2_WKM.mat', DatasetName));

dataset_name = sprintf('%s %s %s', results.config.dataset_name, results.config.tnorm, results.config.CSCM);

struct2vars(results)

% CWC calculation
for modelNameIndex = 1 : length(modelName)

    vecNamePICP = sprintf('PICP_%s', string(modelName(modelNameIndex)));
    vecNamePINAW = sprintf('PINAW_%s', string(modelName(modelNameIndex)));
    vecNameCWC = sprintf('CWC_%s', string(modelName(modelNameIndex)));

    PICPtemp = eval(vecNamePICP);
    PINAWtemp = eval(vecNamePINAW);

    eta = 25;
    CWC_result = computeCWC(PICPtemp', PINAWtemp', confidence_vector, eta)';
    
    eval([vecNameCWC ' = CWC_result;']);

end

for ii = 1 : numel(confidence_vector)
    confidence = confidence_vector(ii) * 100;

    PICPexpName = sprintf('Experiment_PICP_%d', confidence);
    PINAWexpName = sprintf('Experiment_PINAW_%d', confidence);
    CWCexpName = sprintf('Experiment_CWC_%d', confidence);

    tempPICP = [];
    tempPINAW = [];
    tempCWC = [];


    for modelNameIndex = 1 : length(modelName)

        vecNamePICP = sprintf('PICP_%s', string(modelName(modelNameIndex)));
        tempvec = eval(vecNamePICP);
        tempPICP = [tempPICP ; tempvec(:, ii)*100];

        vecNamePINAW = sprintf('PINAW_%s', string(modelName(modelNameIndex))); 
        tempvec = eval(vecNamePINAW);
        tempPINAW = [tempPINAW ; tempvec(:, ii)];

        vecNameCWC = sprintf('CWC_%s', string(modelName(modelNameIndex))); 
        tempvec = eval(vecNameCWC);
        tempCWC = [tempCWC ; tempvec(:, ii)];
    end

    assignin('base', PICPexpName, tempPICP);
    assignin('base', PINAWexpName, tempPINAW);
    assignin('base', CWCexpName, tempCWC);
end

for ii = 1 : numel(confidence_vector)
    confidence = confidence_vector(ii) * 100;

    PICPexpName = sprintf('mockExperiment_PICP_%d', confidence);
    PINAWexpName = sprintf('mockExperiment_PINAW_%d', confidence);
    CWCexpName = sprintf('mockExperiment_CWC_%d', confidence);

    tempPICP = [];
    tempPINAW = [];
    tempCWC = [];


    for modelNameIndex = 1 : length(modelName)

        vecNamePICP = sprintf('PICP_%s', string(modelName(modelNameIndex)));
        tempvec = eval(vecNamePICP);
        tempPICP = [tempPICP , tempvec(:, ii)*100];

        vecNamePINAW = sprintf('PINAW_%s', string(modelName(modelNameIndex))); 
        tempvec = eval(vecNamePINAW);
        tempPINAW = [tempPINAW , tempvec(:, ii)];

        vecNameCWC = sprintf('CWC_%s', string(modelName(modelNameIndex)));
        tempvec = eval(vecNameCWC);
        tempCWC = [tempCWC , tempvec(:, ii)];
    end

    assignin('base', PICPexpName, tempPICP);
    assignin('base', PINAWexpName, tempPINAW);
    assignin('base', CWCexpName, tempCWC);
end


PICP_all_WKM = [90 - Experiment_PICP_90 ; 95 - Experiment_PICP_95 ; 99 - Experiment_PICP_99];
PINAW_all_WKM = [Experiment_PINAW_90 ; Experiment_PINAW_95 ; Experiment_PINAW_99];
CWC_all_WKM = [Experiment_CWC_90 ; Experiment_CWC_95 ; Experiment_CWC_99];

Table_WKM = table(    round(mean(mockExperiment_PICP_90), 3)', ...
                         round(mean(mockExperiment_PINAW_90), 3)', ...
                         round(mean(mockExperiment_CWC_90), 3)', ...
                         round(mean(mockExperiment_PICP_95), 3)', ...
                         round(mean(mockExperiment_PINAW_95), 3)', ...
                         round(mean(mockExperiment_CWC_95), 3)', ...
                         round(mean(mockExperiment_PICP_99), 3)', ...
                         round(mean(mockExperiment_PINAW_99), 3)', ...
                         round(mean(mockExperiment_CWC_99), 3)');

Table_WKM(1,:) = [];

Table_all = [Table_KM ; Table_WKM];


filename = sprintf('%s.xlsx', DatasetName);

writetable(Table_all,      filename, 'Sheet', 1, 'WriteRowNames', true);




%% Plot config

close all

algo = [repmat({'Fuzzy'}, 10, 1) ; repmat({'CQR'}, 10, 1) ; repmat({'CQR-m'}, 10, 1) ; repmat({'CQR-r'}, 10, 1) ; repmat({'CP_ystar'}, 10, 1) ; repmat({'CP_T1'}, 10, 1)];
algo = repmat(algo, 3, 1);

experiment_info = [repmat({'90 %'}, 60, 1) ; repmat({'95 %'}, 60, 1) ; repmat({'99 %'}, 60, 1)];

YLABEL = 'CWC';

YLABEL_FONT = 14;
XLABEL_FONT = 14;

YTICK_FONT = 12;

LEGEND_FONT = 9;

%% CWC plot
figure;
t = tiledlayout(2, 1, 'TileSpacing', 'compact', 'Padding', 'compact'); % Two rows, one column

% First plot
ax1 = nexttile;
groupedBoxchart(categorical(experiment_info), categorical(algo), CWC_all_KM);
yline(0, '--');
ylabel(YLABEL, 'FontSize', YLABEL_FONT);
xticklabels([]); % Remove x-tick labels for the top plot
set(gca, 'FontSize', YTICK_FONT);

legend({'SCP-T1', 'SCP-IT2-KM','IT2-KM', 'CQR-IT2-KM', 'CQRm-IT2-KM', ...
        'CQRr-IT2-KM'}, ....
    'FontSize', LEGEND_FONT, 'Orientation', 'horizontal', ...
    'Location', 'northoutside', 'NumColumns', 3);

% Second plot
ax2 = nexttile;
groupedBoxchart(categorical(experiment_info), categorical(algo), CWC_all_WKM); % Change DATA3 if needed
yline(0, '--');
ylabel(YLABEL, 'FontSize', YLABEL_FONT);
xticklabels({'90%', '95%', '99%'});
set(gca, 'FontSize', YTICK_FONT);

legend({'SCP-T1', 'SCP-IT2-WKM','IT2-WKM', 'CQR-IT2-WKM', 'CQRm-IT2-WKM', ...
        'CQRr-IT2-WKM'}, ...
    'FontSize', LEGEND_FONT, 'Orientation', 'horizontal', ...
    'Location', 'northoutside', 'NumColumns', 3);

t.TileSpacing = 'compact';
t.Padding = 'compact';


set(gcf, 'Units', 'inches');
set(gcf, 'Position', [0 0 6 6]);


print(gcf, SAVETITLE, '-dpng', '-r300'); 