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
//---------------------------------- Control Signal ---------------------------------
reg  [7:0]  yuv_out;
reg  [5:0]  r_busy;
reg  [6:0]  r_valid;
reg  [5:0]  r_yuv_select [0:1];
reg         r_start;
wire        w_start;
integer     i;
//-----------------------------------------------------------------------------------

//---------------------------------- Register File ----------------------------------
reg  [7:0]  r_data       [0:2];
//-----------------------------------------------------------------------------------

//---------------------------------- YUV Calculate ----------------------------------
wire [9:0]  w_r_tmp1;
wire [9:0]  w_r_tmp2;
wire [8:0]  w_r_tmp3;
wire [10:0] w_r_tmp4;
wire [10:0] w_g_tmp1;
wire [8:0]  w_g_tmp2;
wire [11:0] w_g_tmp3;
wire [9:0]  w_b_tmp1;
//-----------------------------------------------------------------------------------

//---------------------------------- YUV Calculate ----------------------------------
wire [9:0]  w_y_tmp1;
wire [9:0]  w_y_tmp2;
wire [11:0] w_y_tmp3;
wire [9:0]  w_y_tmp4;
wire [12:0] w_y_tmp5;
wire [12:0] w_y_tmp6;
wire [8:0]  w_y_tmp7;
wire [8:0]  w_u_tmp1;
wire [8:0]  w_v_tmp1;
wire [8:0]  w_v_tmp2;
wire [9:0]  w_v_tmp3;
reg  [7:0]  r_y;
reg  [7:0]  r_u;
reg  [7:0]  r_v;
//-----------------------------------------------------------------------------------

//---------------------------------- Register File ----------------------------------
always @(posedge clk or posedge reset) begin
    if (reset) begin
        {r_data[0], r_data[1], r_data[2]} <= 24'b0;
    end
    else if(~op_mode) begin
        if (~r_yuv_select[0][3] & ~r_yuv_select[1][3]) r_data[0] <= yuv_in;
        if (~r_yuv_select[0][3] &  r_yuv_select[1][3]) r_data[1] <= yuv_in;
        if ( r_yuv_select[0][3] & ~r_yuv_select[1][3]) r_data[2] <= yuv_in;
    end
    else begin
        if (~busy) {r_data[0], r_data[2], r_data[1]} <= rgb_in;
    end
end
//-----------------------------------------------------------------------------------

//---------------------------------- Control Signal ---------------------------------
always @(posedge clk) if (reset) r_start <= 1'b0; else r_start <= op_mode;

always @(posedge clk) begin
    if (reset) begin
        r_yuv_select[0] <= 6'b011010;
        r_yuv_select[1] <= 6'b111000;
    end
    else begin
        r_yuv_select[0][5] <= r_yuv_select[0][0];
        r_yuv_select[1][5] <= r_yuv_select[1][0];
        for (i = 1; i < 6; i = i + 1) begin
            r_yuv_select[0][i - 1] <= r_yuv_select[0][i];
            r_yuv_select[1][i - 1] <= r_yuv_select[1][i];
        end
    end
end

always @(posedge clk) begin
    if (reset) begin
        r_busy  <= 6'b000011;
        r_valid <= 7'b0110000;
    end
    else if (w_start) begin
        r_busy[5]   <= 1'b0;
        r_busy[2:0] <= 3'b111;
        r_valid[4]  <= 1'b1;
        r_valid[1]  <= 1'b1;
    end
    else begin
        r_busy[5]  <= r_busy[0];
        r_valid[5] <= r_valid[0];
        for (i = 1; i < 6; i = i + 1) begin
            r_busy[i - 1]  <= r_busy[i];
            r_valid[i - 1] <= r_valid[i];
        end
        r_valid[6] <= in_en & r_valid[0];
    end
end

assign w_start = r_start ^ op_mode;
assign busy = r_busy[0];
assign out_valid = r_valid[6];
//-----------------------------------------------------------------------------------

//-------------------------------- Pipelin Register ---------------------------------
always @(posedge clk) begin
    if (reset) begin
        r_y <= 8'b0;
        r_u <= 8'b0;
        r_v <= 8'b0;
    end
    else begin
        r_y <= w_y_tmp7[8] ? 8'hff : w_y_tmp7[7:0];
        r_u <= w_u_tmp1[8:1] + w_u_tmp1[0];
        r_v <= w_v_tmp3[9:2] + w_v_tmp3[1];
    end
end
//-----------------------------------------------------------------------------------

//------------------------------------ Calculate ------------------------------------
//------------------------------------- YUV2RGB -------------------------------------
//  R:
//
//  +01.0000 * Y
//  +00.0000 * U
//  +01.1010 * V
//
//  G:
//
//  +01.0000 * Y
//  -00.0100 * U
//  -00.1100 * V
//
//  B:
//
//  +01.0000 * Y
//  +10.0000 * U
//  +00.0000 * V

assign w_r_tmp1 = {1'b0, r_data[0], 1'b0} + {2'b0, r_data[2]};             // 10-bits
assign w_r_tmp2 = {w_r_tmp1[9:8] + {2{r_data[2][7]}}, w_r_tmp1[7:0]};      // 10-bits
assign w_r_tmp3 = {r_data[2], 1'b0} + {{3{r_data[2][7]}}, r_data[2][7:2]}; //  9-bits
assign w_r_tmp4 = {w_r_tmp2[9], w_r_tmp2} + {{2{w_r_tmp3[8]}}, w_r_tmp3};  // 11-bits

assign w_g_tmp1 = {2'b0, r_data[0], 1'b0} - {{3{r_data[2][7]}}, r_data[2]};// 11-bits
assign w_g_tmp2 = {r_data[1][7], r_data[1]} + {r_data[2][7], r_data[2]};   //  9-bits
assign w_g_tmp3 = {w_g_tmp1, 1'b0} - {{3{w_g_tmp2[8]}}, w_g_tmp2};         // 12-bits

assign w_b_tmp1 = {2'b0, r_data[0]} + {1'b0, r_data[1], 1'b0};             // 10-bits


//------------------------------------- RGB2YUV -------------------------------------
//  Y:
//
//  +0.0100 1010 * R
//  +0.0001 0100 * B
//  +0.1010 0001 * G
//
//  U:
//  
//  +0.1000 0000 * B
//  -0.1000 0000 * Y
//
//  V:
//
//  +0.1001 1110 * R
//  -0.1001 1110 * Y

assign w_y_tmp1 = w_r_tmp1;                                                     // 10-bits
assign w_y_tmp2 = w_b_tmp1;                                                     // 10-bits
assign w_y_tmp3 = {{1'b0, r_data[2]} + {6'b0, r_data[1][7:5]}, r_data[1][4:2]}; // 12-bits
assign w_y_tmp4 = {1'b0, w_y_tmp2[9:1]} + {4'b0, w_y_tmp1[9:4]};                // 10-bits
assign w_y_tmp5 = {2'b0, w_y_tmp1, 1'b0} + {1'b0, w_y_tmp3};                    // 13-bits
assign w_y_tmp6 = {3'b0, w_y_tmp4} + w_y_tmp5;                                  // 13-bits
assign w_y_tmp7 = w_y_tmp6[12:4] + w_y_tmp6[3];                                 //  9-bits
assign w_u_tmp1 = {1'b0, r_data[1]} - {1'b0, r_y};                              //  9-bits
assign w_v_tmp1 = {1'b0, r_data[0]} - {1'b0, r_y};                              //  9-bits
assign w_v_tmp2 = w_v_tmp1 + {{2{w_v_tmp1[8]}}, w_v_tmp1[8:2]};                 //  9-bits
assign w_v_tmp3 = {w_v_tmp2, 1'b0} - {{6{w_v_tmp1[8]}}, w_v_tmp1[8:5]};         // 10-bits

//------------------------------------- Output --------------------------------------
//------------------------------------- YUV2RGB -------------------------------------
assign rgb_out[23:16] =              w_r_tmp4[10] ? 8'h00 :
                                     w_r_tmp4[9]  ? 8'hff : w_r_tmp4[8:1] + w_r_tmp4[0];
assign rgb_out[15:8]  =              w_g_tmp3[11] ? 8'h00 : 
                 (w_g_tmp3[10] | &w_g_tmp3[9:1])  ? 8'hff : w_g_tmp3[9:2] + w_g_tmp3[1];
assign rgb_out[7:0]  = w_b_tmp1[9] ^ r_data[1][7] ? 8'h00 :
                                      w_b_tmp1[8] ? 8'hff : w_b_tmp1[7:0];

//------------------------------------- RGB2YUV -------------------------------------
always @(*) begin
    case ({r_yuv_select[0][0], r_yuv_select[1][0]})
        2'b00:   yuv_out = r_y;
        2'b01:   yuv_out = r_u;
        2'b10:   yuv_out = r_v;
        default: yuv_out = 8'b0;
    endcase
end
//-----------------------------------------------------------------------------------
endmodule
