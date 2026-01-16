function [loss, gradients, yPred] = fismodelLoss(mini_batch_inputs, number_inputs, targets, number_outputs, number_mf, mbs, learnable_parameters, output_membership_type)

yPred = fismodel(mini_batch_inputs, number_mf, number_inputs,number_outputs, mbs, learnable_parameters, output_membership_type);

% if output_membership_type == "IV" || output_membership_type == "IVL"
%     % tilted loss
%     loss = l2loss(yPred(1,3,:), targets, NormalizationFactor="batch-size", DataFormat="SCB");
%     loss_tilted = tilted_loss(targets, yPred(1, 2, :), yPred(1, 1, :), 0.1, 0.9, mbs);
% 
%     loss = loss + loss_tilted;
% elseif output_membership_type == "singleton" || output_membership_type == "linear"
%     %l2 loss
%     loss = l2loss(yPred, targets, NormalizationFactor="batch-size", DataFormat="SCB");
% 
% end

if output_membership_type == "IV" || output_membership_type == "IVL"
    % tilted loss
    loss = log_cosh_loss(yPred(3,1,:), targets, mbs);
    loss_tilted = tilted_loss(targets, yPred(2, 1, :), yPred(1, 1, :), 0.1, 0.9, mbs);

    loss = loss + loss_tilted;
elseif output_membership_type == "singleton" || output_membership_type == "linear"

    loss = log_cosh_loss(yPred, targets, mbs);

    % loss = sum((targets - yPred).^2);
    % 
    % loss = sum(loss);
end



gradients = dlgradient(loss, learnable_parameters);

end