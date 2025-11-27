module fnd(
number,
hex_d
);

input [3:0] number;
output reg [6:0] hex_d;

always@(number) begin
case(number)
4'h0 : begin
 hex_d = 7'b100_0000; //0
 end
4'h1 : begin
 hex_d = 7'b111_1001; //1
 end
4'h2 : begin
 hex_d = 7'b010_0100; //2
 end
4'h3 : begin
 hex_d = 7'b011_0000; //3
 end
4'h4 : begin
 hex_d = 7'b001_1001;
 end
4'h5 : begin
 hex_d = 7'b001_0010;
 end
4'h6 : begin
 hex_d = 7'b000_0010;
 end
4'h7 : begin
 hex_d = 7'b101_1000;
 end
4'h8 : begin
 hex_d = 7'b000_0000;
 end
4'h9 : begin
 hex_d = 7'b001_1000;
 end
default : begin
 hex_d = 7'b100_0000;
 end 
endcase
end
endmodule
