`timescale 1ns/10ps
module CTE ( clk, reset, op_mode, in_en, yuv_in, rgb_in, busy, out_valid, rgb_out, yuv_out);
input   clk ;
input   reset ;
input   op_mode;
input   in_en;
output  busy;
output  out_valid;
input   [7:0]   yuv_in;
output  [23:0]  rgb_out;
input   [23:0]  rgb_in;
output  [7:0]   yuv_out;

//Write your code here 
reg         cur_state;
wire        next_state;
reg         busy;
reg         out_valid;
reg [2:0]   cnt;
reg [7:0]   r_data [0:2];

wire [9:0]  w_r1_tmp;
wire [9:0]  w_r2_tmp;
wire [11:0] w_r3_tmp;
wire [10:0] w_g1_tmp;
wire [8:0]  w_g2_tmp;
wire [11:0] w_g3_tmp;
wire [9:0]  w_b1_tmp;

wire [11:0] w_yuv_tmp;
reg  [7:0]  yuv_out;
reg  [17:0] w_a6;
reg  [17:0] w_a7;
reg  [17:0] w_a8;
wire [17:0] multi1;
wire [17:0] multi2;
wire [17:0] multi3;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        {r_data[0], r_data[1], r_data[2]} <= 24'b0;
    end
    else begin
        if(~op_mode) begin
            if (~^cnt & cnt[0])    r_data[0] <= yuv_in;
            if (cnt[1:0] == 2'b10) r_data[1] <= yuv_in;
            if (cnt[2] & ~cnt[0])  r_data[2] <= yuv_in;
        end
        else begin
            if (~busy) {r_data[0], r_data[1], r_data[2]} <= rgb_in;
        end
    end
end

always @(posedge clk or posedge reset) begin
    if (reset) cur_state <= 1'b0;
    else cur_state <= next_state;
end

always @(posedge clk) begin
    if (reset | cnt[2] & cnt[0]) cnt <= 3'b0;
    else cnt <= cnt + 3'b1;
end

assign next_state = cur_state | cnt[1];

always @(*) begin
    case ({cur_state, op_mode, cnt})
        5'b00010: busy = 1'b0;
        5'b01010: busy = 1'b0;

        5'b10000: busy = 1'b1;
        5'b10001: busy = 1'b1;
        5'b10010: busy = 1'b0;
        5'b10011: busy = 1'b0;
        5'b10100: busy = 1'b0;
        5'b10101: busy = 1'b0;

        5'b11000: busy = 1'b0;
        5'b11001: busy = 1'b1;
        5'b11010: busy = 1'b0;
        5'b11011: busy = 1'b1;
        5'b11100: busy = 1'b1;
        5'b11101: busy = 1'b1;

        default:  busy = 1'bx;
    endcase
end

always @(*) begin
    case ({cur_state, op_mode, cnt})
        5'b00000: out_valid = 1'b0;
        5'b00001: out_valid = 1'b0;
        5'b00010: out_valid = 1'b0;
        5'b01000: out_valid = 1'b0;
        5'b01001: out_valid = 1'b0;
        5'b01010: out_valid = 1'b0;

        5'b10000: out_valid = 1'b1;
        5'b10001: out_valid = 1'b0;
        5'b10010: out_valid = 1'b0;
        5'b10011: out_valid = 1'b0;
        5'b10100: out_valid = 1'b0;
        5'b10101: out_valid = 1'b1;

        5'b11000: out_valid = 1'b1;
        5'b11001: out_valid = 1'b1;
        5'b11010: out_valid = 1'b1;
        5'b11011: out_valid = 1'b0;
        5'b11100: out_valid = 1'b0;
        5'b11101: out_valid = 1'b1;

        default:  out_valid = 1'bx;
    endcase
end

//---------------------------------------------------------------------------------------
assign w_r1_tmp = {2'b0, r_data[0]} + {{2{r_data[2][7]}}, r_data[2]};
assign w_r2_tmp = {r_data[2][7], r_data[2], 1'b0} + {{3{r_data[2][7]}}, r_data[2][7:1]};
assign w_r3_tmp = {w_r1_tmp, 2'b0} + {{2{w_r2_tmp[9]}}, w_r2_tmp};
assign rgb_out[23:16] = w_r3_tmp[11] ? 8'h00 :
                        w_r3_tmp[10] ? 8'hff : w_r3_tmp[9:2] + w_r3_tmp[1];

assign w_g1_tmp = {2'b0, r_data[0], 1'b0} - {{3{r_data[2][7]}}, r_data[2]};
assign w_g2_tmp = {r_data[1][7], r_data[1]} + {r_data[2][7], r_data[2]};
assign w_g3_tmp = {w_g1_tmp, 1'b0} - {{3{w_g2_tmp[8]}}, w_g2_tmp};
assign rgb_out[15:8] = w_g3_tmp[11] ? 8'h00 : 
    (w_g3_tmp[10] | &w_g3_tmp[9:1]) ? 8'hff : w_g3_tmp[9:2] + w_g3_tmp[1];

assign w_b1_tmp = {2'b0, r_data[0]} + {r_data[1][7], r_data[1], 1'b0};
assign rgb_out[7:0] = w_b1_tmp[9] ? 8'h00 :
                      w_b1_tmp[8] ? 8'hff : w_b1_tmp[7:0];

//---------------------------------------------------------------------------------------
parameter [7:0] mat11 = 'h4A,
                mat12 = 'hA1,//9'h15F, //-A1
                mat13 = 'h14,//9'h1EC, //-14

                mat21 = 'h25,//9'h1DB, //-25
                mat22 = 'h51,
                mat23 = 'h76,//9'h18A, //-76

                mat31 = 'h70,
                mat32 = 'h63,
                mat33 = 'hC;

/*
0.145  = 0.253C = 0.0010 0101 0011 1100
0.3151 = 0.50AD = 0.0101 0000 1010 1101
0.4606 = 0.75EA = 0.0111 0101 1110 1010

0100 1010
1010 0001
0001 0100

0.6153 = 0.9E   = 0.1001 1110
 */

wire [9:0]  w_y_tmp1;
wire [9:0]  w_y_tmp2;
wire [7:0]  w_y_tmp3;
wire [5:0]  w_y_tmp4;
wire [12:0] w_y_tmp5;
wire [8:0]  w_y_tmp6;
wire [12:0] w_y_tmp7;
wire [8:0]  w_y_tmp8;

wire [8:0]  w_u_tmp1;

wire [8:0]  w_v_tmp1;
wire [10:0] w_v_tmp2;
wire [11:0] w_v_tmp3;

reg  [7:0]  r_y;
reg  [7:0]  r_u;
reg  [7:0]  r_v;

assign w_y_tmp1 = {2'b0, r_data[0]} + {1'b0, r_data[1], 1'b0};          // 10-bits (<< 2)
assign w_y_tmp2 = {1'b0, r_data[1], 1'b0} + {2'b0, r_data[2]};          // 10-bits
assign w_y_tmp3 = {1'b0, r_data[0][7:1]} + {2'b0, r_data[2][7:2]};      //  8-bits
assign w_y_tmp4 = {1'b0, r_data[0][7:3]} + {2'b0, r_data[1][7:4]};      //  6-bits

assign w_y_tmp5 = {1'b0, w_y_tmp1, 2'b0} + {3'b0, w_y_tmp2};            // 13-bits
assign w_y_tmp6 = {1'b0, w_y_tmp3} + {3'b0, w_y_tmp4};                  //  9-bits

assign w_y_tmp7 = w_y_tmp5 + {4'b0, w_y_tmp6};                          // 13-bits

assign w_y_tmp8 = w_y_tmp7[12:4] + w_y_tmp7[3];                         //  9-bits

assign w_u_tmp1 = {1'b0, r_data[2]} - {1'b0, r_y};                      //  9-bits

assign w_v_tmp1 = {1'b0, r_data[0]} - {1'b0, r_y};                      //  9-bits

assign w_v_tmp2 = {w_v_tmp1, 2'b0} + {{2{w_v_tmp1[8]}}, w_v_tmp1};      // 11-bits
assign w_v_tmp3 = {w_v_tmp2, 1'b0} - {{6{w_v_tmp1[8]}}, w_v_tmp1[8:3]}; // 12-bits

always @(posedge clk) begin
    if (reset) begin
        r_y <= 8'b0;
        r_u <= 8'b0;
        r_v <= 8'b0;
    end
    else begin
        r_y <= w_y_tmp8[8] ? 8'hff : w_y_tmp8[7:0];
        r_u <= w_u_tmp1[8:1] + w_u_tmp1[0];
        r_v <= w_v_tmp3[11:4] + w_v_tmp3[3];
    end
end

always @(*) begin
    case (cnt)
        3'b101: begin
            yuv_out = r_u;
        end
        3'b000: begin
            yuv_out = r_y;
        end
        3'b001: begin
            yuv_out = r_v;
        end
        3'b010: begin
            yuv_out = r_y;
        end
        default: yuv_out = 8'bx;
    endcase
end
endmodule
