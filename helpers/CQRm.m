function PIs = CQRm(yPred_calib_lower, yPred_calib_upper, yPred_calib, yTrue_calib, confidence, ...
    yPred_test_upper, yPred_test_lower, yPred_test)
    
    %% calibration
    temp_low = yPred_calib - yPred_calib_lower; 
    temp_up = yPred_calib_upper - yPred_calib;

    E = max((yPred_calib_lower - yTrue_calib)./temp_low, (yTrue_calib - yPred_calib_upper)./temp_up);
    
    alphas = sort(E, 'ascend');
    alphas_index = ceil((confidence)*(length(E)+1));

    alpha_s = alphas(alphas_index);

    %% test
    delta_low = alpha_s * (yPred_test - yPred_test_lower);
    delta_up  = alpha_s * (yPred_test_upper - yPred_test);


    LB = yPred_test_lower - delta_low;
    UB = yPred_test_upper + delta_up;

    PIs = [LB ; UB]';
end