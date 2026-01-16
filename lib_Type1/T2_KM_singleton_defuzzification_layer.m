function [output_lower, output_upper, output_mean] = T2_KM_singleton_defuzzification_layer(x,lower_firing_strength,upper_firing_strength, learnable_parameters,number_outputs, output_type,type_reduction_method,mbs,number_mf,u)

delta_f = upper_firing_strength - lower_firing_strength;
delta_f = permute(delta_f,[3 1 2]);

payda2 = delta_f*u;

pay2 = (permute(learnable_parameters.singleton.c,[3 1 2]).*delta_f)*u;
pay2 = permute(pay2,[3,2,1]);
pay1 = sum(learnable_parameters.singleton.c.* lower_firing_strength,1);

pay = pay1 + pay2;

%         clear pay1_upper pay2_upper
%         clear delta_f u

payda2 = permute(payda2,[3,2,1]);
payda1 = sum(lower_firing_strength,1);

payda = payda1 + payda2;

%         clear payda1 payda2

output = pay./payda;

%         clear pay_lower pay_upper payda

output_lower = min(output,[],2);
output_upper = max(output,[],2);

%         clear output_lower_temp output_upper_temp

output_mean = (output_lower + output_upper)./2;

end

