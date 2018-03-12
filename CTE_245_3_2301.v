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
        5'b11001: out_valid = 1'b0;
        5'b11010: out_valid = 1'b1;
        5'b11011: out_valid = 1'b0;
        5'b11100: out_valid = 1'b1;
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

reg  [10:0]  r_tmp8;
reg  [10:0]  r_tmp9;
reg  [10:0]  r_tmp10;

assign multi1 = {1'b0, r_data[0]} * w_a6;
assign multi2 = {1'b0, r_data[1]} * w_a7;
assign multi3 = {1'b0, r_data[2]} * w_a8;

always @(posedge clk) begin
    if (reset) begin
        r_tmp8  <= 11'b0;
        r_tmp9  <= 11'b0;
        r_tmp10 <= 11'b0;
    end
    else begin
        r_tmp8  <= (&cnt[1:0]) ? ~multi1[16:6]:
                                  multi1[16:6];
        r_tmp9  <= (cnt[2] ^ cnt[0] & ~cnt[1]) ? ~multi2[16:6]:
                                                  multi2[16:6];
        r_tmp10 <= (cnt[2] ^ cnt[0])  ? ~multi3[16:6]:
                                         multi3[16:6];
    end
end

assign w_yuv_tmp = {r_tmp8[10], r_tmp8} - {r_tmp8[10], r_tmp9} - {r_tmp8[10], r_tmp10};
//assign w_yuv_tmp = multi1[17:6] - multi2[17:6] - multi3[17:6];
//assign w_yuv_tmp = w_sub2;

always @(*) begin
    case (cnt)
        3'b011: begin
            w_a6 = mat21;
            w_a7 = mat22;
            w_a8 = mat23;
        end
        3'b100: begin
            w_a6 = mat11;
            w_a7 = mat12;
            w_a8 = mat13;
        end
        3'b101: begin
            w_a6 = mat31;
            w_a7 = mat32;
            w_a8 = mat33;
        end
        3'b001: begin
            w_a6 = mat11;
            w_a7 = mat12;
            w_a8 = mat13;
        end
        default: begin
            w_a6 = 8'bx;
            w_a7 = 8'bx;
            w_a8 = 8'bx;
        end
    endcase
end

always @(*) begin
    case (cnt)
        3'b100: begin
            if (w_yuv_tmp[10] & w_yuv_tmp[9:2] <= 8'd139 )      yuv_out = 8'b10001011; // -117
            else if (~w_yuv_tmp[10] & w_yuv_tmp[9:2] >= 8'd117) yuv_out = 8'b01110101; // 117
            else                                                yuv_out = w_yuv_tmp[9:2] + w_yuv_tmp[1];
        end
        3'b101: begin
            if (w_yuv_tmp[11])      yuv_out = 8'b0;   // <= 0
            else if (w_yuv_tmp[10]) yuv_out = 8'hff;  // > 0xff
            else                    yuv_out = w_yuv_tmp[9:2] + w_yuv_tmp[1];
        end
        3'b000: begin
            if (w_yuv_tmp[10] & w_yuv_tmp[9:2] <= 8'd145)       yuv_out = 8'b10010001;  // -111
            else if (~w_yuv_tmp[10] & w_yuv_tmp[9:2] >= 8'd111) yuv_out = 8'b01101111;  // 111
            else                                                yuv_out = w_yuv_tmp [9:2] + w_yuv_tmp[1];
        end
        3'b010: begin
            if (w_yuv_tmp[11])      yuv_out = 8'b0;   // <= 0
            else if (w_yuv_tmp[10]) yuv_out = 8'hff;  // > 0xff
            else                    yuv_out = w_yuv_tmp[9:2] + w_yuv_tmp[1];
        end
        default: yuv_out = 8'bx;
    endcase
end
endmodule
