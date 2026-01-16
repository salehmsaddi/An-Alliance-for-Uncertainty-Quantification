function PIs = CQRr(yPred_calib_lower, yPred_calib_upper, yTrue_calib, confidence, ...
    yPred_test_upper, yPred_test_lower)
    
    %% calibration
    temp = yPred_calib_upper - yPred_calib_lower;

    E = max((yPred_calib_lower - yTrue_calib)./temp, (yTrue_calib - yPred_calib_upper)./temp);

    alphas = sort(E, 'ascend');
    alphas_index = ceil((confidence)*(length(E)+1));

    alpha_s = alphas(alphas_index);

    %% test
    delta  = alpha_s * (yPred_test_upper - yPred_test_lower);


    LB = yPred_test_lower - delta;
    UB = yPred_test_upper + delta;

    PIs = [LB ; UB]';
end