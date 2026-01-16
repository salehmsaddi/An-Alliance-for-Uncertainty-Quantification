%multi input için limitler belirlenmeli



function learnable_parameters = initializeGlorot(input_lower_bound, input_upper_bound, number_mf, output_type, number_input, number_output, output_lower_bound, output_upper_bound)

    length_between_input_centers = (input_upper_bound-input_lower_bound) / (number_mf - 1);
    input_centers = zeros(number_mf,number_input);

    for i = 1:length(length_between_input_centers)
        input_centers(:, i) = input_lower_bound:length_between_input_centers(i):input_upper_bound;
    end
    
    
    sigma = length_between_input_centers / 3;
%     sigmas = ones(number_mf, number_input).*sigma;
    sigmas = repelem(sigma,number_mf,1);
    learnable_parameters.input_centers = dlarray(input_centers);
    learnable_parameters.input_sigmas = dlarray(sigmas);




    if output_type == "singleton"

        length_between_output_centers = (output_upper_bound - output_lower_bound) / (number_mf - 1);
        output_centers = zeros(number_mf,number_output);

        for i = 1:length(length_between_output_centers)
            output_centers(:, i) = output_lower_bound:length_between_output_centers(i):output_upper_bound;
        end

        learnable_parameters.singleton.c= dlarray(output_centers);

    end

    if output_type == "linear"

        learnable_parameters.linear.a = ones(number_mf,number_input) + randn(number_mf,number_input);
        learnable_parameters.linear.a(learnable_parameters.linear.a < output_lower_bound) = output_lower_bound;
        learnable_parameters.linear.a(learnable_parameters.linear.a > output_upper_bound) = output_upper_bound;

        learnable_parameters.linear.a = dlarray(learnable_parameters.linear.a);


        learnable_parameters.linear.b = randn(number_mf,1);
        learnable_parameters.linear.b(learnable_parameters.linear.b < output_lower_bound) = output_lower_bound;
        learnable_parameters.linear.b(learnable_parameters.linear.b > output_upper_bound) = output_upper_bound;

        learnable_parameters.linear.b = dlarray(learnable_parameters.linear.b);

    end







end