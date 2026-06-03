module register_8bit(
    input   [7:0] D,
    output  [7:0] Q,
    input enable,
    input clk
); 
    reg     [7:0] res;
    always@(posedge clk)
    begin
        if(enable) begin
            res <= D;
        end
    end

    assign Q = res;

endmodule