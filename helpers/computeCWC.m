function CWC = computeCWC(PICP, PINAW, confidence, eta)

    if size(PICP) ~= size(PINAW)
        error('PICP and PINAW must have the same dimensions.');
    end
    if length(confidence) ~= size(PICP, 1)
        error('The length of alpha must match the number of rows in PICP and PINAW.');
    end
    
    
    alphaMatrix = repmat(confidence(:), 1, size(PICP, 2));
    lambda = PICP < confidence';

    penalty = lambda .* exp( -eta .* (PICP - alphaMatrix));
    
    CWC = PINAW .* (1 + penalty);
end
