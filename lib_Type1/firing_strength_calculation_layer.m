% 22 JUN 2023
function output = firing_strength_calculation_layer(membership_values,operator_type)
% v0.2 compatibel with mini-batch
% more operators can be added
%
% rule inferance for static rules, rule count is equal to number of input membership
% function or number of outputs
%
% @param output -> output
%
%       (n,1,mb) vector
%       n = number of rows in input
%       (:,1,1) -> firing strength of each rule
%
% @param input 1 -> membership_values
%
%       (n,m) vector
%       n = number of input membership
%       function or number of outputs
%       m = number of inputs to FIS system or number of features
%       (:,1) -> fuzzified values of input one for each membership function
%       (1,:) -> fuzzified output of membership fuction 1 of each input
%
% @param input 2 -> operator_type
%
%       a string
%       operator type that will be applied in rules
%       4 options are available for now: "product" , "sum" , "max" , "min"
%
if operator_type == "product"
    firing_strength = prod(membership_values,2);
elseif operator_type == "sum"
    firing_strength = sum(membership_values,2);
elseif operator_type == "max"
    firing_strength = max(membership_values,[],2);
elseif operator_type == "min"
    firing_strength = min(membership_values,[],2);
elseif operator_type == "bounded-product"
    number_of_inputs = width(membership_values);
    firing_strength = sum(membership_values,2) - (number_of_inputs - 1);
    firing_strength = relu(firing_strength);
elseif operator_type == "mean"
    firing_strength = mean(membership_values,2);
elseif operator_type == "deneme"
    firing_strength = 1 - mean((1 - membership_values),2);
elseif operator_type == "deneme2"
    firing_strength =  sqrt(mean((membership_values.^2),2));
elseif operator_type == "deneme3"
    firing_strength =  sqrt(mean(((1-membership_values).^2),2));

end

output = firing_strength;

end