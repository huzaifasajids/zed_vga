`timescale 1ns / 1ps

module zed_vga(
    // Clock Interface
    input i_clk100MHz,
    
    // Control Signals
    input i_rst,
    input i_grayscale,

    // VGA Interface
    output o_vga_vsync,
    output o_vga_hsync,
    output [3:0] o_vga_red,
    output [3:0] o_vga_green,
    output [3:0] o_vga_blue
);

    wire clk_25MHz;    
    clock_divider #(
        .DIVIDEBY(4)
    ) clock_divider_i(
        .i_clk          (i_clk100MHz    ),
        .i_rst          (i_rst          ),
        .o_clk          (clk_25MHz      )
    );

    wire [15:0] pixel_x_vga;
    wire new_frame_vga;
    wire [3:0] red;
    wire [3:0] green;
    wire [3:0] blue;
    pattern_generator_640p_rgb pattern_generator_640p_rgb_i(
        .i_pixel_clk    (clk_25MHz      ),
        .i_rst          (i_rst          ),
        .i_grayscale    (i_grayscale    ),
        .i_new_frame    (new_frame_vga  ),
        .i_x_pos        (pixel_x_vga    ),
        .o_red          (red            ),
        .o_green        (green          ),
        .o_blue         (blue           )
    );
    
    video_controller_vga video_controller_vga_i(
        .i_pixel_clk    (clk_25MHz      ),
        .i_rst          (i_rst          ),
        .i_red          (red            ),
        .i_green        (green          ),
        .i_blue         (blue           ),
        .o_next_x       (pixel_x_vga    ),
        .o_next_y       (               ),
        .o_new_frame    (new_frame_vga  ),
        .o_active       (               ),
        .o_vga_vsync    (o_vga_vsync    ),
        .o_vga_hsync    (o_vga_hsync    ),
        .o_vga_red      (o_vga_red      ),
        .o_vga_green    (o_vga_green    ),
        .o_vga_blue     (o_vga_blue     )
    );

endmodule
