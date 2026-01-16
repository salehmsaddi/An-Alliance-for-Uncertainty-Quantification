% 22 JUN 2023
% old versions
% v0.1 solution with for loop for mini-batch
function output = defuzzification_layer(x,normalized_firing_strength, learnable_parameters, output_type)
% v0.2 compatible with minibatch
% !!! not compatible with multiple outputs !!! will be written when needed
%
%
% calculating the weighted sum with firts calcutating the weighted
% elements then adding them
%
% @param output -> output
%
%       (1,1,mbs) tensor
%       mbs = mini-batch size
%       (:,:,1) -> defuzzified output of the first element of the batch
%
% @param input 1 -> normalized_firing_strength
%
%       (rc,1,mbs) tensor
%       rc = number of rules
%       mbs = mini-batch size
%       (1,1,1) -> normalized firing strength of the first rule of the
%       first element of the batch
%
% @param input 2 -> output_mf
%
%       (rc,1) vector
%       rc = number of rules
%       (1,1) -> constant or value of the first output membership function





% solution with for loop
%
% output = zeros(1,length(normalized_firing_strength(1,1,:)));
% for i=1:length(normalized_firing_strength(1,1,:))
%     output(i) = normalized_firing_strength(:,:,i)*output_mf;
% end
%



%[s, ~, b] = size(normalized_firing_strength);
if output_type == "singleton"
    %without tensor multipication
    


    output = normalized_firing_strength.* learnable_parameters.singleton.c; % first we multiply elementwise our firing strengths with output memberships
    output = sum(output, 1); %then we sum with respect to dimension 1

    %with tensor multipication
    %     output = tensorprod(normalized_firing_strength,learnable_parameters.singleton.c,1,1);
    %     output = reshape(output,[1 1 size(output,2)]);

elseif output_type == "linear"
    %
    % if size(output_mf)(2) == 2 throw error

    temp_mf = [learnable_parameters.linear.a,learnable_parameters.linear.b];
    x = permute(x,[2 1 3]); %comment at
    temp_input = [x; ones(1, size(x, 2), size(x, 3))];
    temp_input = reshape(temp_input, [size(temp_input, 1), size(temp_input, 3)]); %for dlarray implementation

    c = temp_mf*temp_input;
    c = reshape(c, [size(c, 1), 1, size(c, 2)]);

    %     ctemp = tensorprod(extractdata(temp_mf),extractdata(temp_input),2,1); %dlarray e uygun hal !!
    output = normalized_firing_strength.* c;
    output = sum(output, 1); %then we sum with respect to dimension 1



elseif output_type == "IV"

    c_upper = learnable_parameters.IV.c + abs(learnable_parameters.IV.delta);
    c_lower = learnable_parameters.IV.c - abs(learnable_parameters.IV.delta);


    output_upper = normalized_firing_strength.* c_upper;
    output_lower = normalized_firing_strength.* c_lower;

    output_upper = sum(output_upper, 1);
    output_lower = sum(output_lower, 1);
    output = [output_upper output_lower (output_upper+output_lower)./2 ];

elseif output_type == "IVL"
    
    temp_mf = [learnable_parameters.IVL.a,learnable_parameters.IVL.b];
    temp_delta = [learnable_parameters.IVL.delta_a,learnable_parameters.IVL.delta_b];


    x = permute(x,[2 1 3]); %comment at
    temp_input = [x; ones(1, size(x, 2), size(x, 3))];
    temp_input = reshape(temp_input, [size(temp_input, 1), size(temp_input, 3)]); %for dlarray implementation



    linear_upper = (temp_mf * temp_input) + (temp_delta * abs(temp_input));
    linear_lower = (temp_mf * temp_input) - (temp_delta * abs(temp_input));

    linear_upper = reshape(linear_upper, [size(linear_upper, 1), 1, size(linear_upper, 2)]);
    linear_lower = reshape(linear_lower, [size(linear_lower, 1), 1, size(linear_lower, 2)]);

    output_upper = normalized_firing_strength.* linear_upper;
    output_lower = normalized_firing_strength.* linear_lower;


    output_upper = sum(output_upper, 1);
    output_lower = sum(output_lower, 1);

    output = [output_upper output_lower (output_upper+output_lower)./2 ];





end
%output = reshape(output, [s, b]);

output = dlarray(output);

end