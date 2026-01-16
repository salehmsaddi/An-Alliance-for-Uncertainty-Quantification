function PIs = CP(yTrue_calib, confidence, yPred_calib, yPred_test)


    %% calibration
    
    residuals_cal = abs(yTrue_calib        - yPred_calib);
    
    alphas = sort(residuals_cal, 'ascend');
    alphas_index = ceil((confidence)*(length(residuals_cal)+1));

    
    %% test    
    
    LB = yPred_test - alphas(alphas_index);
    UB = yPred_test + alphas(alphas_index);
    
    PIs = [LB ; UB]';
end