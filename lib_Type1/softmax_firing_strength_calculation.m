function output = softmax_firing_strength_calculation(x, learnable_parameters, number_mf, number_inputs, mbs)


input_matrix = repmat(x, number_mf, 1, 1);

output = zeros(number_mf, number_inputs, mbs, "gpuArray");

%%

exponent = 0.5 * ((input_matrix - learnable_parameters.input_centers).^2 ./ (learnable_parameters.input_sigmas.^2));

Z = mean(exponent,2);
frs = -Z;

output = softmax(frs,"DataFormat","CSB");

end

