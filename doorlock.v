module doorlock(
clk,
n_rst,
bt_1,
bt_2,
bt_3,
cover,
fnd_1,
fnd_2,
fnd_3,
led_o,
led_f,
led_state
);

input clk;
input n_rst;
input bt_1;
input bt_2;
input bt_3;
input cover;
output[6:0] fnd_1;
output[6:0] fnd_2;
output[6:0] fnd_3;
output reg led_o;
output reg led_f;
output reg[3:0] led_state;
reg[3:0] c_state;
reg[3:0] n_state;

reg bt_1d1; //bt up&down in 1 sig
reg bt_1d2;
reg bt_2d1;
reg bt_2d2;
reg bt_3d1;
reg bt_3d2;

wire bt_1_on;
wire bt_2_on;
wire bt_3_on;

parameter S_0 = 3'h0; //stop
parameter S_1 = 3'h1; //start
parameter S_2 = 3'h2; //r
parameter S_3 = 3'h3; //r
parameter S_4 = 3'h4; //fr
parameter S_5 = 3'h5; //w
parameter S_6 = 3'h6; //w
parameter S_7 = 3'h7; //fw

always@(posedge clk or negedge n_rst)
if(!n_rst)
 c_state <= S_0;
else
 c_state <= n_state;

//bt push in 1 sig
always @(posedge clk or negedge n_rst)
if(!n_rst) 
begin
 bt_1d1 <= 1'b1;
 bt_1d2 <= 1'b1;
 bt_2d1 <= 1'b1;
 bt_2d2 <= 1'b1;
 bt_3d1 <= 1'b1;
 bt_3d2 <= 1'b1;
end 
else begin
 bt_1d1 <= bt_1; 
 bt_1d2 <= bt_1d1;
 bt_2d1 <= bt_2; 
 bt_2d2 <= bt_2d1;
 bt_3d1 <= bt_3; 
 bt_3d2 <= bt_3d1;
end
//bt_on
assign bt_1_on = (bt_1d1 == 1'b0 && bt_1d2 == 1'b1);
assign bt_2_on = (bt_2d1 == 1'b0 && bt_2d2 == 1'b1);
assign bt_3_on = (bt_3d1 == 1'b0 && bt_3d2 == 1'b1);


always @(c_state or bt_1_on or bt_2_on or bt_3_on or cover)
case(c_state)
S_0 : begin
 n_state = (cover == 1'b1)? S_1 : S_0;
end
S_1 : begin
 n_state = (bt_2_on == 1'b1)? S_2 :
 (bt_1_on == 1'b1 || bt_3_on == 1'b1)? S_5 : S_1;
end
S_2 : begin
 n_state = (bt_1_on == 1'b1)?S_3 :
 (bt_2_on == 1'b1 || bt_3_on == 1'b1)? S_6 : S_2;
end
S_3 : begin
 n_state = (bt_3_on == 1'b1)?S_4 :
 (bt_1_on == 1'b1 || bt_2_on == 1'b1)? S_7 : S_3;
end
S_4 : begin
 n_state = (!cover) ? S_0 : S_4; 
end
S_5 : begin
 n_state = (bt_1_on == 1'b1 || bt_2_on == 1'b1 || bt_3_on == 1'b1)? S_6 : S_5; 
end
S_6 : begin
 n_state = (bt_1_on == 1'b1 || bt_2_on == 1'b1 || bt_3_on == 1'b1)? S_7 : S_6; 
end
S_7 : begin
 n_state = (!cover) ? S_0 : S_7; 
end
default : begin
 n_state = (cover == 1'b1)? S_1 : S_0;
end
endcase

always@(c_state)
begin
case(c_state)
S_0 : begin
led_state = 3'h0;
end
S_1 : begin
led_state = 3'h1;
end
S_2 : begin
led_state = 3'h2;
end
S_3 : begin
led_state = 3'h3;
end
S_4 : begin
led_state = 3'h4;
end
S_5 : begin
led_state = 3'h5;
end
S_6 : begin
led_state = 3'h6;
end
S_7 : begin
led_state = 3'h7;
end
default : begin
led_state = 3'h0;
end
endcase
end

always @(c_state) 
begin
case (c_state)
 S_4: begin
 led_o = 1'b1;
 led_f = 1'b0;
end
 S_7: begin
 led_o = 1'b0;
 led_f = 1'b1;
end
default: begin
 led_o = 1'b0;
 led_f = 1'b0;
end
endcase
end

//fnd display
reg [1:0] fnd_cnt;
wire any_bt;
assign any_bt = (bt_1_on || bt_2_on || bt_3_on);
 
always@(posedge clk or negedge n_rst)
if(!n_rst)
	fnd_cnt <= 2'd0;
else begin
	if(cover == 1'b1 && any_bt == 1'b1)
		fnd_cnt <= fnd_cnt + 2'd1;
	else if(c_state == S_4 || c_state == S_7)
		fnd_cnt <= 2'd0;
	else
		fnd_cnt <= fnd_cnt;
end

reg [3:0] fnd_1_reg;
reg [3:0] fnd_2_reg;
reg [3:0] fnd_3_reg;


always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin      
        fnd_1_reg <= 4'h0;
        fnd_2_reg <= 4'h0;
        fnd_3_reg <= 4'h0;
    end    
    else if(cover == 1'b1) begin
        if (c_state == S_1) begin
            if (bt_1_on) fnd_1_reg <= 4'd1;
            else if (bt_2_on) fnd_1_reg <= 4'd2;
            else if (bt_3_on) fnd_1_reg <= 4'd3;
            else              fnd_1_reg <= fnd_1_reg;
        end
        else if (c_state == S_2 || c_state == S_5) begin
            if (bt_1_on) fnd_2_reg <= 4'd1;
            else if (bt_2_on) fnd_2_reg <= 4'd2;
            else if (bt_3_on) fnd_2_reg <= 4'd3;
            else              fnd_2_reg <= fnd_2_reg; 
        end
        else if (c_state == S_3 || c_state == S_6) begin
            if (bt_1_on) fnd_3_reg <= 4'd1;
            else if (bt_2_on) fnd_3_reg <= 4'd2;
            else if (bt_3_on) fnd_3_reg <= 4'd3;
            else              fnd_3_reg <= fnd_3_reg; 
        end
        else begin       
            fnd_1_reg <= fnd_1_reg;
            fnd_2_reg <= fnd_2_reg;
            fnd_3_reg <= fnd_3_reg;
        end
    end

    else begin
        fnd_1_reg <= 4'b0;
        fnd_2_reg <= 4'b0;
        fnd_3_reg <= 4'b0;
    end
end

//cover=0 > fnd reset



fnd u_fnd_1(
.number(fnd_1_reg),
.hex_d(fnd_1)
);

fnd u_fnd_2(
.number(fnd_2_reg),
.hex_d(fnd_2)
);

fnd u_fnd_3(
.number(fnd_3_reg),
.hex_d(fnd_3)
);

endmodule