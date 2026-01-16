function [x_norm,minimum,range] = max_min_norm(x)
eps = 1e-8;
minimum = min(x);
range = max(x) - min(x);
x_norm = (x-minimum)./(range+eps);
end