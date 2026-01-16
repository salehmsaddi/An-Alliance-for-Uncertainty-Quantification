% commented on 23 JAN 2024
function [loss, gradients, yPred_lower, yPred_upper, yPred] = Copy_of_IT2_fismodelLoss(x, number_inputs, targets,number_outputs, number_of_rules, mbs, learnable_parameters, output_type, input_mf_type, fuzzy_set_type,CSCM,u,tnorm, confidence)
% IT2 FLS Model
[yPred_lower, yPred_upper, yPred] = IT2_fismodel(x, number_of_rules, number_inputs,number_outputs, mbs, learnable_parameters, output_type, input_mf_type, fuzzy_set_type,CSCM,u,tnorm);

% loss for accuracy 
loss = log_cosh_loss(yPred, targets, mbs);

alpha = 1 - confidence;

% loss for coverage
% 99 percent coverage
loss_tilted = tilted_loss(targets, yPred_lower, yPred_upper, alpha/2, 1 - alpha/2,mbs);

loss = sum((loss + loss_tilted),2);

% calculate gradient
gradients = dlgradient(loss, learnable_parameters);

end