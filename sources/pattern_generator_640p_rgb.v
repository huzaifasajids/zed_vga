`timescale 1ns / 1ps

module pattern_generator_640p_rgb(
    input wire i_pixel_clk,
    input wire i_rst,
    input wire i_grayscale,
    // pixel position
    input wire [15:0] i_x_pos,
    input wire i_new_frame,
    // Color Data
    output wire [3:0] o_red,
    output wire [3:0] o_green,
    output wire [3:0] o_blue
);

reg [3:0] red_reg;
reg [3:0] green_reg;
reg [3:0] blue_reg;
reg grayscale_reg;
wire [3:0] bar_index;

// bar_index (640 / 64 = 10 bars)
assign bar_index = i_x_pos >> 6;

always @(posedge i_pixel_clk) begin
    if (i_new_frame) begin
        grayscale_reg <= i_grayscale;
    end
end

always @(posedge i_pixel_clk) begin
    if (grayscale_reg == 0)
    begin
        case (bar_index)
            4'd0:    {red_reg, green_reg, blue_reg} <= {4'h0, 4'h0, 4'h0}; // Black
            4'd1:    {red_reg, green_reg, blue_reg} <= {4'hF, 4'd0, 4'd0}; // Red
            4'd2:    {red_reg, green_reg, blue_reg} <= {4'hF, 4'hC, 4'h0}; // Orange
            4'd3:    {red_reg, green_reg, blue_reg} <= {4'hF, 4'hF, 4'h0}; // Yellow
            4'd4:    {red_reg, green_reg, blue_reg} <= {4'h0, 4'hF, 4'h0}; // Green
            4'd5:    {red_reg, green_reg, blue_reg} <= {4'h0, 4'h0, 4'hF}; // Blue
            4'd6:    {red_reg, green_reg, blue_reg} <= {4'h0, 4'hF, 4'hF}; // Cyan
            4'd7:    {red_reg, green_reg, blue_reg} <= {4'hC, 4'h0, 4'hC}; // Purple
            4'd8:    {red_reg, green_reg, blue_reg} <= {4'hF, 4'h0, 4'hF}; // Magenta
            default: {red_reg, green_reg, blue_reg} <= {4'hF, 4'hF, 4'hF}; // White
        endcase
    end else begin
        case (bar_index)
            4'd0:    {red_reg, green_reg, blue_reg} <= {4'hF, 4'hF, 4'hF}; // White
            4'd1:    {red_reg, green_reg, blue_reg} <= {4'hD, 4'hD, 4'hD}; // Light gray
            4'd2:    {red_reg, green_reg, blue_reg} <= {4'hB, 4'hB, 4'hB}; // Medium-light gray
            4'd3:    {red_reg, green_reg, blue_reg} <= {4'h9, 4'h9, 4'h9}; // Medium gray
            4'd4:    {red_reg, green_reg, blue_reg} <= {4'h7, 4'h7, 4'h7}; // Darker gray
            4'd5:    {red_reg, green_reg, blue_reg} <= {4'h5, 4'h5, 4'h5}; // Dark gray
            4'd6:    {red_reg, green_reg, blue_reg} <= {4'h3, 4'h3, 4'h3}; // Very dark gray
            4'd7:    {red_reg, green_reg, blue_reg} <= {4'h2, 4'h2, 4'h2}; // Near-black gray
            4'd8:    {red_reg, green_reg, blue_reg} <= {4'h1, 4'h1, 4'h1}; // Dark gray step
            default: {red_reg, green_reg, blue_reg} <= {4'h0, 4'h0, 4'h0}; // Black
        endcase
    end
end

assign o_red   = red_reg;
assign o_green = green_reg;
assign o_blue  = blue_reg;

endmodule
