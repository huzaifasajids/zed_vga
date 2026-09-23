`timescale 1ns / 1ps

// Allows 1 clock cycle latency to the image producing module to produce the colors
// For info about FP, SYNC, BP:
// https://pcbjunkie.net/wp-content/uploads/2019/09/640x480-display-timing.png

module video_controller_vga#(
    parameter H_ACTIVE = 640,              // horizontal active pixels
    parameter H_FP     = 16,               // horizontal front porch
    parameter H_SYNC   = 96,               // horizontal sync pulse
    parameter H_BP     = 48,               // horizontal back porch
    parameter V_ACTIVE = 480,              // vertical active pixels
    parameter V_FP     = 11,               // vertical front porch
    parameter V_SYNC   = 2,                // vertical sync pulse
    parameter V_BP     = 31                // vertical back porch
)(
    input wire i_pixel_clk,
    input wire i_rst,
    // data for next pixel
    input wire [3:0] i_red,
    input wire [3:0] i_green,
    input wire [3:0] i_blue,
    // current pixel position
    output wire [15:0] o_next_x,
    output wire [15:0] o_next_y,
    output wire o_new_frame,
    output wire o_active,
    // VGA Interface
    output wire o_vga_vsync,
    output wire o_vga_hsync,
    output wire [3:0] o_vga_red,
    output wire [3:0] o_vga_green,
    output wire [3:0] o_vga_blue
);

localparam ROW = H_ACTIVE + H_FP + H_SYNC + H_BP;  // complete line
localparam COL = V_ACTIVE + V_FP + V_SYNC + V_BP;  // complete screen

reg [3:0]  red_reg;
reg [3:0]  green_reg;
reg [3:0]  blue_reg;
reg [15:0] h_count = 0; // horizontal position
reg [15:0] v_count = 0; // vertical position
reg hsync_reg;
reg vsync_reg;
reg hsync_reg2;
reg vsync_reg2;

always@(posedge i_pixel_clk) begin
    if(i_rst) begin
        red_reg   <= 4'd0;
        green_reg <= 4'd0;
        blue_reg  <= 4'd0;
    end else begin
        red_reg   <= i_red;
        green_reg <= i_green;
        blue_reg  <= i_blue;
    end
end

assign o_vga_red   = red_reg;
assign o_vga_green = green_reg;
assign o_vga_blue  = blue_reg;

always @ (posedge i_pixel_clk) begin
    if (i_rst) begin                // reset to start of frame
        h_count <= 0;
        v_count <= 0;
    end else begin
        if (h_count < ROW-1) begin
            h_count <= h_count + 1;
        end else begin
            h_count <= 0;
            if (v_count < COL-1) begin
                v_count <= v_count + 1;
            end else begin
                v_count <= 0;
            end
        end
    end
end

// keep x and y bound within the active pixels
assign o_next_x = (h_count >= H_ACTIVE) ? (H_ACTIVE - 1) : (h_count);
assign o_next_y = (v_count >= V_ACTIVE) ? (V_ACTIVE - 1) : (v_count);
assign o_active = (h_count < H_ACTIVE) & (v_count < V_ACTIVE);
// o_new_frame: high for one tick at the end of the final active pixel line
assign o_new_frame = ((v_count == COL - 1) & (h_count == ROW - 1));

// generate sync signals
always@(posedge i_pixel_clk) begin
    if (i_rst) begin
        hsync_reg <= 1'b0;
        vsync_reg <= 1'b0;
    end else begin
        hsync_reg <= (h_count >= H_ACTIVE + H_FP) & (h_count < H_ACTIVE + H_FP + H_SYNC);
        vsync_reg <= (v_count >= V_ACTIVE + V_FP) & (v_count < V_ACTIVE + V_FP + V_SYNC);
        // we give 1 clock cycle delay to the sync signals for the color data to be available
        hsync_reg2 <= ~(hsync_reg);   // active low
        vsync_reg2 <= ~(vsync_reg);   // active low
    end
end

assign o_vga_hsync = hsync_reg2;
assign o_vga_vsync = vsync_reg2;

endmodule
