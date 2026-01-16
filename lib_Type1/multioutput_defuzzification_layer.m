% 15 JULY 2023

function output = multioutput_defuzzification_layer(x,normalized_firing_strength, learnable_parameters,number_outputs, output_type)
% docstring will be added

if output_type == "singleton"

    normalized_firing_strength = repmat(normalized_firing_strength,1,number_outputs);
    output = normalized_firing_strength.* learnable_parameters.singleton.c; % first we multiply elementwise our firing strengths with output memberships
    output = sum(output, 1); %then we sum with respect to dimension 1

elseif output_type == "linear"

    temp_mf = [learnable_parameters.linear.a,learnable_parameters.linear.b];
    x = permute(x,[2 1 3]); 
    temp_input = [x; ones(1, size(x, 2), size(x, 3))];
    temp_input = permute(temp_input, [1 3 2]); %for dlarray implementation

    c = temp_mf*temp_input;
    c = reshape(c, [size(normalized_firing_strength, 1), number_outputs, size(normalized_firing_strength, 3)]);

    normalized_firing_strength = repmat(normalized_firing_strength,1,number_outputs);

    output = normalized_firing_strength.* c;
    output = sum(output, 1); %then we sum with respect to dimension 1

elseif output_type == "IV"

    c_upper = learnable_parameters.IV.c + abs(learnable_parameters.IV.delta);
    c_lower = learnable_parameters.IV.c - abs(learnable_parameters.IV.delta);

    normalized_firing_strength = repmat(normalized_firing_strength,1,number_outputs);
    output_upper = normalized_firing_strength.* c_upper;
    output_lower = normalized_firing_strength.* c_lower;

    output_upper = sum(output_upper, 1);
    output_lower = sum(output_lower, 1);
    output = [output_upper ;output_lower ;(output_upper+output_lower)./2 ];

elseif output_type == "IVL"
    
    temp_mf = [learnable_parameters.IVL.a,learnable_parameters.IVL.b];
    temp_delta = [learnable_parameters.IVL.delta_a,learnable_parameters.IVL.delta_b];

    x = permute(x,[2 1 3]); %comment at
    temp_input = [x; ones(1, size(x, 2), size(x, 3))];
    temp_input = permute(temp_input, [1 3 2]); %for dlarray implementation

    linear_lower = (temp_mf * temp_input) - (abs(temp_delta * temp_input));
    linear_upper = (temp_mf * temp_input) + (abs(temp_delta * temp_input));

    linear_upper = reshape(linear_upper, [size(normalized_firing_strength, 1), number_outputs, size(normalized_firing_strength, 3)]);
    linear_lower = reshape(linear_lower, [size(normalized_firing_strength, 1), number_outputs, size(normalized_firing_strength, 3)]);

    normalized_firing_strength = repmat(normalized_firing_strength,1,number_outputs);

    output_upper = normalized_firing_strength.* linear_upper;
    output_lower = normalized_firing_strength.* linear_lower;

    output_upper = sum(output_upper, 1);
    output_lower = sum(output_lower, 1);

    output = [output_upper; output_lower ;(output_upper+output_lower)./2 ];

end
output = dlarray(output);

end