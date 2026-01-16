function learnable_parameters = initializeGlorot2(input_intervals, output_intervals, number_mf, number_input, number_output, output_type)

mf_matrix = zeros(number_mf, number_input);

for i = 1:number_input
    % Calculate the step size for mean values
    stepSize = (input_intervals(i, 2) - input_intervals(i, 1)) / (number_mf - 1);
    
    % Generate mean values starting from the minimum value to the maximum value
    means = input_intervals(i, 1):stepSize:input_intervals(i, 2);
    
    % Store the mean values in the corresponding row of mfMatrix
    mf_matrix(:, i) = means.';
end

sf_matrix = (mf_matrix(2, :) - mf_matrix(1, :)) ./3;
sf_matrix = repmat(sf_matrix, number_mf, 1);

learnable_parameters.input_centers = dlarray(mf_matrix);
learnable_parameters.input_sigmas = dlarray(sf_matrix);

c = zeros(number_mf, number_output);

if output_type == "singleton"

    for j = 1:number_output
        % Calculate the step size for mean values
        stepSize = (output_intervals(j, 2) - output_intervals(j, 1)) / (number_mf - 1);
        
        % Generate mean values starting from the minimum value to the maximum value
        means = output_intervals(j, 1):stepSize:output_intervals(j, 2);
        
        % Store the mean values in the corresponding row of mfMatrix
        c(:, j) = means.';
    end

    learnable_parameters.singleton.c = dlarray(c);

end

if output_type == "linear"

    learnable_parameters.linear.a = ones(number_mf,number_input) + randn(number_mf,number_input);
%     learnable_parameters.linear.a(learnable_parameters.linear.a < output_lower_bound) = output_lower_bound;
%     learnable_parameters.linear.a(learnable_parameters.linear.a > output_upper_bound) = output_upper_bound;

    learnable_parameters.linear.a = dlarray(learnable_parameters.linear.a);


    learnable_parameters.linear.b = randn(number_mf,1);
%     learnable_parameters.linear.b(learnable_parameters.linear.b < output_lower_bound) = output_lower_bound;
%     learnable_parameters.linear.b(learnable_parameters.linear.b > output_upper_bound) = output_upper_bound;

    learnable_parameters.linear.b = dlarray(learnable_parameters.linear.b);

end


end