function ypred = fismodel(mini_batch_inputs, number_mf, number_inputs,number_outputs, mbs, learnable_parameters, output_membership_type)

fuzzifed = matrix_fuzzification_layer(mini_batch_inputs, "gaussmf", learnable_parameters, number_mf, number_inputs, mbs);
% %
% firestrength = firing_strength_calculation_layer(fuzzifed, "product");
firestrength = firing_strength_calculation_layer(fuzzifed, "deneme");

normalized = firing_strength_normalization_layer(firestrength);



% normalized = softmax_firing_strength_calculation(mini_batch_inputs,learnable_parameters,number_mf,number_inputs,mbs);



%     ypred = defuzzification_layer(mini_batch_inputs, normalized, learnable_parameters, output_membership_type);
ypred = multioutput_defuzzification_layer(mini_batch_inputs, normalized, learnable_parameters,number_outputs, output_membership_type);

end