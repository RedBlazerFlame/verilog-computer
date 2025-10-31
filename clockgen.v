`timescale 1ns / 1ps

module clockgen #(parameter HALFPERIOD = 1) (input en, output clk);

reg clkreg;

always @ *
begin
    if(en)
    begin
        #(HALFPERIOD) clkreg <= 1'b0;
        #(HALFPERIOD) clkreg <= 1'b1;
    end
    else
        clkreg <= 1'b0;
end

assign clk = clkreg;

endmodule