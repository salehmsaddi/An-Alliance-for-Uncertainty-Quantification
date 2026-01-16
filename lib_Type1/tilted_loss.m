function tilted_loss = tilted_loss(y,y_lower, y_upper, q1, q2, mbs)

lower_loss = 1/mbs*(sum(max(q1*(y-y_lower), (q1-1)*(y-y_lower))));
upper_loss = 1/mbs*(sum(max(q2*(y-y_upper), (q2-1)*(y-y_upper))));

tilted_loss = lower_loss + upper_loss;

end

