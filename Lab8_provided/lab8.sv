//-------------------------------------------------------------------------
//      lab8.sv                                                          --
//      Christine Chen                                                   --
//      Fall 2014                                                        --
//                                                                       --
//      Modified by Po-Han Huang                                         --
//      10/06/2017                                                       --
//                                                                       --
//      Fall 2017 Distribution                                           --
//                                                                       --
//      For use with ECE 385 Lab 8                                       --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------


module lab8( input               CLOCK_50,
             input        [3:0]  KEY,          //bit 0 is set up as Reset
             output logic [6:0]  HEX0, HEX1,
             // VGA Interface 
             output logic [7:0]  VGA_R,        //VGA Red
                                 VGA_G,        //VGA Green
                                 VGA_B,        //VGA Blue
             output logic        VGA_CLK,      //VGA Clock
                                 VGA_SYNC_N,   //VGA Sync signal
                                 VGA_BLANK_N,  //VGA Blank signal
                                 VGA_VS,       //VGA virtical sync signal
                                 VGA_HS,       //VGA horizontal sync signal
             // CY7C67200 Interface
             inout  wire  [15:0] OTG_DATA,     //CY7C67200 Data bus 16 Bits
             output logic [1:0]  OTG_ADDR,     //CY7C67200 Address 2 Bits
             output logic        OTG_CS_N,     //CY7C67200 Chip Select
                                 OTG_RD_N,     //CY7C67200 Write
                                 OTG_WR_N,     //CY7C67200 Read
                                 OTG_RST_N,    //CY7C67200 Reset
             input               OTG_INT,      //CY7C67200 Interrupt
             // SDRAM Interface for Nios II Software
             output logic [12:0] DRAM_ADDR,    //SDRAM Address 13 Bits
             inout  wire  [31:0] DRAM_DQ,      //SDRAM Data 32 Bits
             output logic [1:0]  DRAM_BA,      //SDRAM Bank Address 2 Bits
             output logic [3:0]  DRAM_DQM,     //SDRAM Data Mast 4 Bits
             output logic        DRAM_RAS_N,   //SDRAM Row Address Strobe
                                 DRAM_CAS_N,   //SDRAM Column Address Strobe
                                 DRAM_CKE,     //SDRAM Clock Enable
                                 DRAM_WE_N,    //SDRAM Write Enable
                                 DRAM_CS_N,    //SDRAM Chip Select
                                 DRAM_CLK,     //SDRAM Clock
				 output logic [3:0]  LEDG			  //WASD LEDs
                    );
    
    logic Reset_h, Clk;
    logic [15:0] keycode;
	 logic [9:0] DrawX, DrawY;
	 
	 logic [5:0] colorValue;
	 logic [0:29][0:35][0:5] megaman_shooting_text;
	 logic [0:29][0:35][0:5] megaman_running1_text;
	 logic [0:29][0:35][0:5] megaman_running2_text;
	 logic [0:29][0:35][0:5] megaman_running3_text;
	 logic [0:29][0:35][0:5] megaman_jumping_text;
	 logic [0:27][0:26][0:5] soldier1_text;
	 logic [0:27][0:26][0:5] soldier2_text;
	 logic [0:28][0:34][0:5] soldierhigh1_text;
	 logic [0:28][0:34][0:5] soldierhigh2_text;
	 logic [0:34][0:88][0:5] tank1_text;
	 logic [0:34][0:88][0:5] tank2_text;
	 logic [0:34][0:88][0:5] tank3_text;
	 logic [0:29][0:35][0:5] boss_shooting_text;
	 logic [0:29][0:35][0:5] boss_running1_text;
	 logic [0:29][0:35][0:5] boss_running2_text;
	 logic [0:29][0:35][0:5] boss_running3_text;
	 logic [0:29][0:35][0:5] boss_jumping_text;
	 logic [0:2][0:5] bullet_text;
	 logic [0:1][0:2][0:5] rocket_text;
	 
	 logic [4:0] keypress;
    
    assign Clk = CLOCK_50;
    always_ff @ (posedge Clk) begin
        Reset_h <= ~(KEY[0]);        // The push buttons are active low
    end
    
    logic [1:0] hpi_addr;
    logic [15:0] hpi_data_in, hpi_data_out;
    logic hpi_r, hpi_w, hpi_cs;
	 
	 always_comb begin
		LEDG = 4'b0;
		case (keycode[7:0])
			8'd26 :  LEDG = 4'b1000; //W
			8'd04 :  LEDG = 4'b0100; //A
			8'd22 :  LEDG = 4'b0010; //S
			8'd07 :  LEDG = 4'b0001; //D
		endcase
		case (keycode[7:0])
			8'd26 :  keypress = 5'b10000; //W
			8'd04 :  keypress = 5'b01000; //A
			8'd22 :  keypress = 5'b00100; //S
			8'd07 :  keypress = 5'b00010; //D
			8'h2c :  keypress = 5'b00001; //space
			default: keypress = 5'b0;
		endcase
	 end
    
    // Interface between NIOS II and EZ-OTG chip
    hpi_io_intf hpi_io_inst(
                            .Clk(Clk),
                            .Reset(Reset_h),
                            // signals connected to NIOS II
                            .from_sw_address(hpi_addr),
                            .from_sw_data_in(hpi_data_in),
                            .from_sw_data_out(hpi_data_out),
                            .from_sw_r(hpi_r),
                            .from_sw_w(hpi_w),
                            .from_sw_cs(hpi_cs),
                            // signals connected to EZ-OTG chip
                            .OTG_DATA(OTG_DATA),    
                            .OTG_ADDR(OTG_ADDR),    
                            .OTG_RD_N(OTG_RD_N),    
                            .OTG_WR_N(OTG_WR_N),    
                            .OTG_CS_N(OTG_CS_N),    
                            .OTG_RST_N(OTG_RST_N)
    );
     
     // You need to make sure that the port names here match the ports in Qsys-generated codes.
     lab8_soc nios_system(
                             .clk_clk(Clk),         
                             .reset_reset_n(1'b1),    // Never reset NIOS
                             .sdram_wire_addr(DRAM_ADDR), 
                             .sdram_wire_ba(DRAM_BA),   
                             .sdram_wire_cas_n(DRAM_CAS_N),
                             .sdram_wire_cke(DRAM_CKE),  
                             .sdram_wire_cs_n(DRAM_CS_N), 
                             .sdram_wire_dq(DRAM_DQ),   
                             .sdram_wire_dqm(DRAM_DQM),  
                             .sdram_wire_ras_n(DRAM_RAS_N),
                             .sdram_wire_we_n(DRAM_WE_N), 
                             .sdram_clk_clk(DRAM_CLK),
                             .keycode_export(keycode),  
                             .otg_hpi_address_export(hpi_addr),
                             .otg_hpi_data_in_port(hpi_data_in),
                             .otg_hpi_data_out_port(hpi_data_out),
                             .otg_hpi_cs_export(hpi_cs),
                             .otg_hpi_r_export(hpi_r),
                             .otg_hpi_w_export(hpi_w)
    );
  
    // Use PLL to generate the 25MHZ VGA_CLK. Do not modify it.
 //   vga_clk vga_clk_instance(
 //       .clk_clk(Clk),
 //       .reset_reset_n(1'b1),
 //       .altpll_0_c0_clk(VGA_CLK),
 //       .altpll_0_areset_conduit_export(),    
 //       .altpll_0_locked_conduit_export(),
 //       .altpll_0_phasedone_conduit_export()
 //   );
	 
	 always_ff @ (posedge Clk) begin
        if(Reset_h)
            VGA_CLK <= 1'b0;
        else
            VGA_CLK <= ~VGA_CLK;
    end
    
    // TODO: Fill in the connections for the rest of the modules 
    VGA_controller vga_controller_instance(
			.Clk(Clk),
			.Reset(Reset_h),
			.VGA_HS(VGA_HS),      // Horizontal sync pulse.  Active low
         .VGA_VS(VGA_VS),      // Vertical sync pulse.  Active low
         .VGA_CLK(VGA_CLK),     // 25 MHz VGA clock input
         .VGA_BLANK_N(VGA_BLANK_N), // Blanking interval indicator.  Active low.
         .VGA_SYNC_N(VGA_SYNC_N),  // Composite Sync signal.  Active low.  We don't use it in this lab,
			.DrawX(DrawX),
			.DrawY(DrawY)
	 );
    
    // Which signal should be frame_clk?
    ball ball_instance(
			.Clk(Clk),
         .Reset(Reset_h),
         .frame_clk(VGA_VS),
         .DrawX(DrawX),
			.DrawY(DrawY),
			.Key(keypress),
			.colorValue(colorValue),
			.megaman_shooting_text(megaman_shooting_text),
			.megaman_running1_text(megaman_running1_text),
			.megaman_running2_text(megaman_running2_text),
			.megaman_running3_text(megaman_running3_text),
			.megaman_jumping_text(megaman_jumping_text),
			.soldier1_text(soldier1_text),
			.soldier2_text(soldier2_text),
			.soldierhigh1_text(soldierhigh1_text),
			.soldierhigh2_text(soldierhigh2_text),
			.tank1_text(tank1_text),
			.tank2_text(tank2_text),
			.tank3_text(tank3_text),
			.boss_shooting_text(boss_shooting_text),
			.boss_running1_text(boss_running1_text),
			.boss_running2_text(boss_running2_text),
			.boss_running3_text(boss_running3_text),
			.boss_jumping_text(boss_jumping_text),
			.bullet_text(bullet_text),
			.rocket_text(rocket_text)
	 );
	 
	 sprites sprites_instance(
			.clk(Clk),
			.megaman_shooting_text(megaman_shooting_text),
			.megaman_running1_text(megaman_running1_text),
			.megaman_running2_text(megaman_running2_text),
			.megaman_running3_text(megaman_running3_text),
			.megaman_jumping_text(megaman_jumping_text),
			.soldier1_text(soldier1_text),
			.soldier2_text(soldier2_text),
			.soldierhigh1_text(soldierhigh1_text),
			.soldierhigh2_text(soldierhigh2_text),
			.tank1_text(tank1_text),
			.tank2_text(tank2_text),
			.tank3_text(tank3_text),
			.boss_shooting_text(boss_shooting_text),
			.boss_running1_text(boss_running1_text),
			.boss_running2_text(boss_running2_text),
			.boss_running3_text(boss_running3_text),
			.boss_jumping_text(boss_jumping_text),
			.bullet_text(bullet_text),
			.rocket_text(rocket_text)
	 );
    
    color_mapper color_instance(
			.colorValue(colorValue),
         .DrawX(DrawX),
			.DrawY(DrawY),
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B)
	 );
    
    // Display keycode on hex display
    HexDriver hex_inst_0 (keycode[3:0], HEX0);
    HexDriver hex_inst_1 (keycode[7:4], HEX1);
    
    /**************************************************************************************
        ATTENTION! Please answer the following quesiton in your lab report! Points will be allocated for the answers!
        Hidden Question #1/2:
        What are the advantages and/or disadvantages of using a USB interface over PS/2 interface to
             connect to the keyboard? List any two.  Give an answer in your Post-Lab.
    **************************************************************************************/
endmodule
