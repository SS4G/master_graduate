// combine logic of fixMul

assign neg_output = {$fill_ones, prim_output[WIDTH - 1: POINT_WIDTH]};
assign pos_output = {$fill_zeros, prim_output[WIDTH - 1: POINT_WIDTH]};
assign outP = prim_output[$mul_out_MSB]?