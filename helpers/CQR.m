function PIs = CQR(yPred_calib_lower, yPred_calib_upper, yTrue_calib, confidence, ...
    yPred_test_upper, yPred_test_lower)

    
    %% calibration

    E = max(yPred_calib_lower - yTrue_calib, yTrue_calib - yPred_calib_upper);
    
    alphas = sort(E, 'ascend');
    alphas_index = ceil((confidence)*(length(E)+1));

    %% test


    LB = yPred_test_lower - alphas(alphas_index);
    UB = yPred_test_upper + alphas(alphas_index);

    PIs = [LB ; UB]';
end