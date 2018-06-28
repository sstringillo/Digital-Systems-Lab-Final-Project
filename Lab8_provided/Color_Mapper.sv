//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  10-06-2017                               --
//                                                                       --
//    Fall 2017 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------

// color_mapper: Decide which color to be output to VGA for each pixel.
module  color_mapper ( input  logic [5:0] colorValue,            // Whether current pixel belongs to ball 
                                                              //   or background (computed in ball.sv)
                       input        [9:0] DrawX, DrawY,       // Current pixel coordinates
                       output logic [7:0] VGA_R, VGA_G, VGA_B // VGA RGB output
                     );
    
    logic [7:0] Red, Green, Blue;
    
    // Output colors to VGA
    assign VGA_R = Red;
    assign VGA_G = Green;
    assign VGA_B = Blue;
    
    // Assign color based on is_ball signal
    always_comb
	 //54 colors total, represented in 6 bits
    begin
		  case(colorValue)
        6'h1:
        begin
            // White ball
            Red = 8'h00;
            Green = 8'h00;
            Blue = 8'h00;
        end
		  6'h2:
        begin
            // White ball
            Red = 8'hff;
            Green = 8'hff;
            Blue = 8'hff;
        end
		  6'h3:
        begin
            // White ball
            Red = 8'h37;
            Green = 8'h37;
            Blue = 8'h37;
        end
		  6'h4:
        begin
            // White ball
            Red = 8'h40;
            Green = 8'h40;
            Blue = 8'h40;
        end
		  6'h5:
        begin
            // White ball
            Red = 8'h4c;
            Green = 8'h4c;
            Blue = 8'h4c;
        end
		  6'h6:
        begin
            // White ball
            Red = 8'ha6;
            Green = 8'h22;
            Blue = 8'h17;
        end
		  6'h7:
        begin
            // White ball
            Red = 8'h8a;
            Green = 8'h07;
            Blue = 8'h07;
        end
		  6'h8:
        begin
            // White ball
            Red = 8'h80;
            Green = 8'h50;
            Blue = 8'h35;
        end
		  6'h9:
        begin
            // White ball
            Red = 8'he8;
            Green = 8'hb9;
            Blue = 8'h97;
        end
		  6'ha:
        begin
            // White ball
            Red = 8'hee;
            Green = 8'hce;
            Blue = 8'hb3;
        end
		  6'hb:
        begin
            // White ball
            Red = 8'h00;
            Green = 8'h39;
            Blue = 8'ha6;
        end
		  6'hc:
        begin
            // White ball
            Red = 8'hd5;
            Green = 8'h2b;
            Blue = 8'h1e;
        end
		  6'hd:
        begin
            // White ball
            Red = 8'h80;
            Green = 8'h80;
            Blue = 8'h40;
        end
		  6'he:
        begin
            // White ball
            Red = 8'hf0;
            Green = 8'h00;
            Blue = 8'h00;
        end
		  6'hf:
        begin
            // White ball
            Red = 8'h80;
            Green = 8'h80;
            Blue = 8'h80;
        end
		  6'h10:
        begin
            // White ball
            Red = 8'hc0;
            Green = 8'hc0;
            Blue = 8'hc0;
        end
		  6'h11:
        begin
            // White ball
            Red = 8'h15;
            Green = 8'h1f;
            Blue = 8'h00;
        end
		  6'h12:
        begin
            // White ball
            Red = 8'h52;
            Green = 8'h28;
            Blue = 8'h03;
        end
		  6'h13:
        begin
            // White ball
            Red = 8'h80;
            Green = 8'h40;
            Blue = 8'h00;
        end
		  6'h14:
        begin
            // White ball
            Red = 8'h32;
            Green = 8'h3b;
            Blue = 8'h01;
        end
		  6'h15:
        begin
            // White ball
            Red = 8'h44;
            Green = 8'h4c;
            Blue = 8'h02;
        end
		  6'h16:
        begin
            // White ball
            Red = 8'hff;
            Green = 8'h00;
            Blue = 8'h00;
        end
		  6'h17:
        begin
            // White ball
            Red = 8'haf;
            Green = 8'h9b;
            Blue = 8'h60;
        end
		  6'h18:
        begin
            // White ball
            Red = 8'h54;
            Green = 8'h6f;
            Blue = 8'h1c;
        end
		  6'h19:
        begin
            // White ball
            Red = 8'h1e;
            Green = 8'h1e;
            Blue = 8'h1e;
        end
		  6'h1a:
        begin
            // White ball
            Red = 8'h57;
            Green = 8'h57;
            Blue = 8'h57;
        end
		  6'h1b:
        begin
            // White ball
            Red = 8'hdb;
            Green = 8'hdb;
            Blue = 8'hdb;
        end
		  6'h1c:
        begin
            // White ball
            Red = 8'h80;
            Green = 8'h00;
            Blue = 8'h00;
        end
		  6'h1d:
        begin
            // White ball
            Red = 8'h6f;
            Green = 8'h37;
            Blue = 8'h00;
        end
		  6'h1e:
        begin
            // White ball
            Red = 8'h91;
            Green = 8'h4a;
            Blue = 8'h04;
        end
		  6'h1f:
        begin
            // White ball
            Red = 8'he1;
            Green = 8'ha7;
            Blue = 8'h77;
        end
		  6'h20:
        begin
            // White ball
            Red = 8'h8b;
            Green = 8'h8a;
            Blue = 8'h66;
        end
		  6'h21:
        begin
            // White ball
            Red = 8'hff;
            Green = 8'hd7;
            Blue = 8'h4e;
        end
		  6'h22:
        begin
            // White ball
            Red = 8'h4b;
            Green = 8'h56;
            Blue = 8'h41;
        end
		  6'h23:
        begin
            // White ball
            Red = 8'h36;
            Green = 8'h00;
            Blue = 8'h00;
        end
		  6'h24:
        begin
            // White ball
            Red = 8'h23;
            Green = 8'h23;
            Blue = 8'h23;
        end
		  6'h25:
        begin
            // White ball
            Red = 8'h35;
            Green = 8'h44;
            Blue = 8'h22;
        end
		  6'h26:
        begin
            // White ball
            Red = 8'h2a;
            Green = 8'h2a;
            Blue = 8'h2a;
        end
		  6'h27:
        begin
            // White ball
            Red = 8'h6e;
            Green = 8'h6e;
            Blue = 8'h6e;
        end
		  6'h28:
        begin
            // White ball
            Red = 8'h7f;
            Green = 8'h7f;
            Blue = 8'h7f;
        end
		  6'h29:
        begin
            // White ball
            Red = 8'h47;
            Green = 8'h5a;
            Blue = 8'h2e;
        end
		  6'h2a:
        begin
            // White ball
            Red = 8'h9d;
            Green = 8'h9d;
            Blue = 8'h9d;
        end
		  6'h2b:
        begin
            // White ball
            Red = 8'hc3;
            Green = 8'hc3;
            Blue = 8'hc3;
        end
		  6'h2c:
        begin
            // White ball
            Red = 8'hff;
            Green = 8'hf6;
            Blue = 8'h8f;
        end
		  6'h2d:
        begin
            // White ball
            Red = 8'h61;
            Green = 8'h7a;
            Blue = 8'h3f;
        end
		  6'h2e:
        begin
            // White ball
            Red = 8'h30;
            Green = 8'h27;
            Blue = 8'h27;
        end
		  6'h2f:
        begin
            // White ball
            Red = 8'h6f;
            Green = 8'h54;
            Blue = 8'h38;
        end
		  6'h30:
        begin
            // White ball
            Red = 8'h52;
            Green = 8'h28;
            Blue = 8'h03;
        end
		  6'h31:
        begin
            // White ball
            Red = 8'h63;
            Green = 8'h00;
            Blue = 8'h00;
        end
		  6'h32:
        begin
            // White ball
            Red = 8'he1;
            Green = 8'ha7;
            Blue = 8'h77;
        end
		  6'h33:
        begin
            // White ball
            Red = 8'hbf;
            Green = 8'hbc;
            Blue = 8'h83;
        end
		  6'h34:
        begin
            // White ball
            Red = 8'hff;
            Green = 8'hd7;
            Blue = 8'h00;
        end
		  6'h35:
        begin
            // White ball
            Red = 8'h4d;
            Green = 8'h70;
            Blue = 8'h4d;
        end
        default: 
        begin
            // Background with nice color gradient
            Red = 8'h3f; 
            Green = 8'h00;
            Blue = 8'h7f - {1'b0, DrawX[9:3]};
        end
		  endcase
    end
    
endmodule
