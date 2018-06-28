//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  10-06-2017                               --
//    Fall 2017 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------


module  ball ( input         Clk,                // 50 MHz clock
                             Reset,              // Active-high reset signal
                             frame_clk,          // The clock indicating a new frame (~60Hz)
               input [9:0]   DrawX, DrawY,       // Current pixel coordinates
					input [4:0]   Key,					 //pressed key
					input logic [0:29][0:35][0:5] megaman_shooting_text,
					input logic [0:29][0:35][0:5] megaman_running1_text,
					input logic [0:29][0:35][0:5] megaman_running2_text,
					input logic [0:29][0:35][0:5] megaman_running3_text,
					input logic [0:29][0:35][0:5] megaman_jumping_text,
					input logic [0:27][0:26][0:5] soldier1_text,
					input logic [0:27][0:26][0:5] soldier2_text,
					input logic [0:28][0:34][0:5] soldierhigh1_text,
					input logic [0:28][0:34][0:5] soldierhigh2_text,
					input logic [0:34][0:88][0:5] tank1_text,
					input logic [0:34][0:88][0:5] tank2_text,
					input logic [0:34][0:88][0:5] tank3_text,
					input logic [0:29][0:35][0:5] boss_shooting_text,
					input logic [0:29][0:35][0:5] boss_running1_text,
					input logic [0:29][0:35][0:5] boss_running2_text,
					input logic [0:29][0:35][0:5] boss_running3_text,
					input logic [0:29][0:35][0:5] boss_jumping_text,
					input logic [0:1][0:2][0:5] rocket_text,
					input logic [0:2][0:5] bullet_text,
               output logic [5:0] colorValue // What current pixel is
              );

    parameter [9:0] Ball_X_Center=320;  // Center position on the X axis
    parameter [9:0] Ball_Y_Center=240;  // Center position on the Y axis
    parameter [9:0] Ball_X_Min=0;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max=639;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min=0;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max=479;     // Bottommost point on the Y axis
    parameter [9:0] Ball_X_Step=1;      // Step size on the X axis
    parameter [9:0] Ball_Y_Step=1;      // Step size on the Y axis
    parameter [9:0] Ball_Size_X=36;        // Ball size
	 parameter [9:0] Ball_Size_Y=30;
	 parameter [9:0] Soldier_Size_X=27;
	 parameter [9:0] Soldier_Size_Y=28;
	 parameter [9:0] Soldierhigh_Size_X=35;
	 parameter [9:0] Soldierhigh_Size_Y=29;
	 parameter [9:0] Tank_Size_X=89;
	 parameter [9:0] Tank_Size_Y=35;
	 parameter [9:0] Boss_Size_X=36;
	 parameter [9:0] Boss_Size_Y=30;
	 parameter [9:0] Bullet_Size_X=3;
	 parameter [9:0] Bullet_Size_Y=1;
	 parameter [9:0] Rocket_Size_Y=2;

    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion, Boss_X_Motion, Boss_X_Motion_in;
    logic [9:0] Ball_X_Pos_in, Ball_X_Motion_in, Ball_Y_Pos_in, Ball_Y_Motion_in, Boss_Y_Motion, Boss_Y_Motion_in;
	 
	 logic [15:0][9:0] Mainbullets_X_Pos, Mainbullets_Y_Pos, Mainbullets_X_Pos_in, Mainbullets_Y_Pos_in;
	 logic [15:0][9:0] Enemybullets_X_Pos, Enemybullets_Y_Pos, Enemybullets_X_Pos_in, Enemybullets_Y_Pos_in;
	 logic [15:0][9:0] Enemyhighbullets_X_Pos, Enemyhighbullets_Y_Pos, Enemyhighbullets_X_Pos_in, Enemyhighbullets_Y_Pos_in;
	 logic [15:0][9:0] Tankbullets_X_Pos, Tankbullets_Y_Pos, Tankbullets_X_Pos_in, Tankbullets_Y_Pos_in;
	 logic [15:0][9:0] Bossbullets_X_Pos, Bossbullets_Y_Pos, Bossbullets_X_Pos_in, Bossbullets_Y_Pos_in;
	 
	 logic [15:0] Main_shot, Enemy_shot, Enemyhigh_shot, Tank_shot, Boss_shot, Main_shot_in, Enemy_shot_in, Enemyhigh_shot_in, Tank_shot_in, Boss_shot_in;
	 logic [3:0] Mainbullet_count, Enemybullet_count, Enemyhighbullet_count, Tankbullet_count, Bossbullet_count, Mainbullet_count_in, Enemybullet_count_in, Enemyhighbullet_count_in, Tankbullet_count_in, Bossbullet_count_in;
	 logic [15:0] isbullet, isbullet_enemy, isbullet_enemyhigh, isbullet_tank, isbullet_boss;
	 
	 logic jump, jump_in, enemy_runcount, enemy_runcount_in, moveBoss, moveBoss_in, randommove, randommove_in;
	 
	 logic manualreset;
	 
	 logic enemy0_hit, enemy1_hit, enemy2_hit, enemy3_hit, main_hit, enemy0_hit_in, enemy1_hit_in, enemy2_hit_in, enemy3_hit_in, main_hit_in;

	 logic[1:0] ball_runcount, ball_runcount_in;
	 logic[3:0] waitcount, waitcount_in;
	 logic[4:0] reloadcount, reloadcount_in;
	 logic[6:0] reloadcount_tank, reloadcount_tank_in;

    logic [9:0] enemy0_X_Pos, enemy0_Y_Pos, enemy0_X_Pos_in, enemy0_Y_Pos_in;
	 logic [9:0] enemy1_X_Pos, enemy1_Y_Pos, enemy1_X_Pos_in, enemy1_Y_Pos_in;
	 logic [9:0] enemy2_X_Pos, enemy2_Y_Pos, enemy2_X_Pos_in, enemy2_Y_Pos_in;
	 logic [9:0] enemy3_X_Pos, enemy3_Y_Pos, enemy3_X_Pos_in, enemy3_Y_Pos_in;
	 
	 logic[1:0] tank_countdown, tank_countdown_in, boss_countdown, boss_countdown_in;

    /* Since the multiplicants are required to be signed, we have to first cast them
       from logic to int (signed by default) before they are multiplied. */
    int Ball_DistX, Ball_DistY, enemy0_DistX, enemy0_DistY, enemy1_DistX, enemy1_DistY, enemy2_DistX, enemy2_DistY, enemy3_DistX, enemy3_DistY;
	 logic [15:0][9:0] Mainbullets_DistX, Mainbullets_DistY, Enemybullets_DistX, Enemybullets_DistY, Enemyhighbullets_DistX, Enemyhighbullets_DistY, Tankbullets_DistX, Tankbullets_DistY, Bossbullets_DistX, Bossbullets_DistY;
    assign Ball_DistX = DrawX - Ball_X_Pos;
    assign Ball_DistY = DrawY - Ball_Y_Pos;

	 assign enemy0_DistX = DrawX - enemy0_X_Pos;
	 assign enemy0_DistY = DrawY - enemy0_Y_Pos;
	 assign enemy1_DistX = DrawX - enemy1_X_Pos;
	 assign enemy1_DistY = DrawY - enemy1_Y_Pos;
	 assign enemy2_DistX = DrawX - enemy2_X_Pos;
	 assign enemy2_DistY = DrawY - enemy2_Y_Pos;
	 assign enemy3_DistX = DrawX - enemy3_X_Pos;
	 assign enemy3_DistY = DrawY - enemy3_Y_Pos;
	 
	 
	 logic [2:0] tank_dead, tank_dead_in;
	 logic [3:0] boss_dead, boss_dead_in;

	 logic [4:0] health, health_in;
	 
	 
	 logic [1:0] state, state_in; //00 start, 01 game, 10 lose, 11 win
    //////// Do not modify the always_ff blocks. ////////
    // Detect rising edge of frame_clk
    logic frame_clk_delayed;
    logic frame_clk_rising_edge;
    always_ff @ (posedge Clk) begin

        frame_clk_delayed <= frame_clk;
    end
    assign frame_clk_rising_edge = (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
    // Update ball position and motion
    always_ff @ (posedge Clk)
    begin
	 state <= state_in;
        if (Reset || manualreset)
        begin
            Ball_X_Pos <= Ball_X_Center;
            Ball_Y_Pos <= Ball_Y_Max - Ball_Size_Y;
            Ball_X_Motion <= 10'd0;
            Ball_Y_Motion <= 10'd0;
				Boss_X_Motion <= 10'd0;
            Boss_Y_Motion <= 10'd0;
				jump <= 1'b0;
				
				
				enemy0_X_Pos <= Ball_X_Max + Soldier_Size_X;
				enemy0_Y_Pos <= Ball_Y_Max - Soldier_Size_Y;
				enemy1_X_Pos <= Ball_X_Max + Soldierhigh_Size_X + Soldierhigh_Size_X;
				enemy1_Y_Pos <= Ball_Y_Max - Soldierhigh_Size_Y;
				enemy2_X_Pos <= Ball_X_Max + Tank_Size_X;
				enemy2_Y_Pos <= Ball_Y_Max - Tank_Size_Y;
				enemy3_X_Pos <= Ball_X_Max;
				enemy3_Y_Pos <= Ball_Y_Max - Boss_Size_Y;

				Main_shot = 16'b0;
				Enemy_shot = 16'b0;
				Enemyhigh_shot = 16'b0;
				Tank_shot = 16'b0;
				Boss_shot = 16'b0;
				
				Mainbullet_count <= 4'b0;
				Enemybullet_count <= 4'b0;
				Enemyhighbullet_count <= 4'b0;
				Tankbullet_count <= 4'b0;
				Bossbullet_count <= 4'b0;
				reloadcount <= 5'b0;
				reloadcount_tank <= 7'b0;
				enemy0_hit <= 1'b0;
				enemy1_hit <= 1'b0;
				enemy2_hit <= 1'b0;
				enemy3_hit <= 1'b0;
				main_hit <= 1'b0;
				
				tank_countdown <= 2'b0;
				boss_countdown <= 2'b0;
				tank_dead <= 3'b0;
				boss_dead <= 4'b0;
				
				health <= 5'd30;
				moveBoss <= 1'b0;
				randommove <= 1'b0;
        end
        else if (frame_clk_rising_edge && state == 2'b01)        // Update only at rising edge of frame clock
        begin
            Ball_X_Pos <= Ball_X_Pos_in;
            Ball_Y_Pos <= Ball_Y_Pos_in;
            Ball_X_Motion <= Ball_X_Motion_in;
            Ball_Y_Motion <= Ball_Y_Motion_in;
				Boss_X_Motion <= Boss_X_Motion_in;
            Boss_Y_Motion <= Boss_Y_Motion_in;
				jump <= jump_in;

				ball_runcount <= ball_runcount_in;
				enemy_runcount <= enemy_runcount_in;
				waitcount <=waitcount_in;

				enemy0_X_Pos <= enemy0_X_Pos_in;
            enemy0_Y_Pos <= enemy0_Y_Pos_in;
				enemy1_X_Pos <= enemy1_X_Pos_in;
            enemy1_Y_Pos <= enemy1_Y_Pos_in;
				enemy2_X_Pos <= enemy2_X_Pos_in;
            enemy2_Y_Pos <= enemy2_Y_Pos_in;
				enemy3_X_Pos <= enemy3_X_Pos_in;
            enemy3_Y_Pos <= enemy3_Y_Pos_in;
				
				Mainbullets_X_Pos <= Mainbullets_X_Pos_in;
				Enemybullets_X_Pos <= Enemybullets_X_Pos_in;
				Enemyhighbullets_X_Pos <= Enemyhighbullets_X_Pos_in;
				Tankbullets_X_Pos <= Tankbullets_X_Pos_in;
				Bossbullets_X_Pos <= Bossbullets_X_Pos_in;
				Mainbullets_Y_Pos <= Mainbullets_Y_Pos_in;
				Enemybullets_Y_Pos <= Enemybullets_Y_Pos_in;
				Enemyhighbullets_Y_Pos <= Enemyhighbullets_Y_Pos_in;
				Tankbullets_Y_Pos <= Tankbullets_Y_Pos_in;
				Bossbullets_Y_Pos <= Bossbullets_Y_Pos_in;
				
				Main_shot <= Main_shot_in;
				Enemy_shot <= Enemy_shot_in;
				Enemyhigh_shot <= Enemyhigh_shot_in;
				Tank_shot <= Tank_shot_in;
				Boss_shot <= Boss_shot_in;
				
				Mainbullet_count <= Mainbullet_count_in;
				Enemybullet_count <= Enemybullet_count_in;
				Enemyhighbullet_count <= Enemyhighbullet_count_in;
				Tankbullet_count <= Tankbullet_count_in;
				Bossbullet_count <= Bossbullet_count_in;
				
				enemy0_hit <= enemy0_hit_in;
				enemy1_hit <= enemy1_hit_in;
				enemy2_hit <= enemy2_hit_in;
				enemy3_hit <= enemy3_hit_in;
				main_hit <= main_hit_in;
				
				reloadcount <= reloadcount_in;
				reloadcount_tank <= reloadcount_tank_in;
				
				tank_countdown <= tank_countdown_in;
				boss_countdown <= boss_countdown_in;
				tank_dead <= tank_dead_in;
				boss_dead <= boss_dead_in;
				
				health <= health_in;
				moveBoss <= moveBoss_in;
				randommove <= randommove_in;
        end
        // By defualt, keep the register values.
    end
    // You need to modify always_comb block.
    always_comb
    begin
		manualreset = 1'b0;
		state_in = 2'b00;
		if(state == 2'b00)
		begin
			if(Key != 5'b0)
			state_in = 2'b01;
			else
			state_in = 2'b00;
		end
		else if(state == 2'b01)
		begin
			if(health > 5'd30)
			state_in = 2'b10;
			else if(boss_dead == 4'b1111)
			state_in = 2'b11;
			else
			state_in = 2'b01;
		end
		else
			begin
			manualreset = 1'b1;
			if(Key == 5'b00100)
			state_in = 2'b00;
			else
			state_in = state;
		end
		//set distance from current coordinate for all bullets
		for(int i=0; i<15; i=i+1)
		begin
			Mainbullets_DistX[i] = DrawX - Mainbullets_X_Pos[i];
			Mainbullets_DistY[i] = DrawY - Mainbullets_Y_Pos[i];
			Enemybullets_DistX[i] = DrawX - Enemybullets_X_Pos[i];
			Enemybullets_DistY[i] = DrawY - Enemybullets_Y_Pos[i];
			Enemyhighbullets_DistX[i] = DrawX - Enemyhighbullets_X_Pos[i];
			Enemyhighbullets_DistY[i] = DrawY - Enemyhighbullets_Y_Pos[i];
			Tankbullets_DistX[i] = DrawX - Tankbullets_X_Pos[i];
			Tankbullets_DistY[i] = DrawY - Tankbullets_Y_Pos[i];
			Bossbullets_DistX[i] = DrawX - Bossbullets_X_Pos[i];
			Bossbullets_DistY[i] = DrawY - Bossbullets_Y_Pos[i];
		end
        // Update the ball's and enemy's position with its motion
        Ball_X_Pos_in = Ball_X_Pos + Ball_X_Motion;
        Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;
		  enemy0_X_Pos_in = enemy0_X_Pos + (~(Ball_X_Step) + 1'b1);
        enemy0_Y_Pos_in = enemy0_Y_Pos;
		  enemy1_X_Pos_in = enemy1_X_Pos;
        enemy1_Y_Pos_in = enemy1_Y_Pos;
		  enemy2_X_Pos_in = enemy2_X_Pos;
        enemy2_Y_Pos_in = enemy2_Y_Pos;
		  enemy3_X_Pos_in = enemy3_X_Pos;
        enemy3_Y_Pos_in = enemy3_Y_Pos;
		  if(enemy_runcount == 1'b0)
		  enemy1_X_Pos_in = enemy1_X_Pos + (~(Ball_X_Step) + 1'b1);
        enemy1_Y_Pos_in = enemy1_Y_Pos;
		  if((waitcount == 3'b0) && (enemy2_X_Pos >= (Ball_X_Max - Tank_Size_X)))
		  enemy2_X_Pos_in = enemy2_X_Pos + (~(Ball_X_Step) + 1'b1);
        enemy2_Y_Pos_in = enemy2_Y_Pos;
		  
		  moveBoss_in = moveBoss;
		  if(tank_dead >= 3'b110) //tank dead
		  moveBoss_in = 1'b1;
		  enemy3_X_Pos_in = Ball_X_Max;
		  if(moveBoss == 1'b1)
		  begin
		  enemy3_X_Pos_in = enemy3_X_Pos + Boss_X_Motion;
        enemy3_Y_Pos_in = enemy3_Y_Pos + Boss_Y_Motion;
		  end
		  
		  //by default bullets keep their positions
		  Mainbullets_X_Pos_in = Mainbullets_X_Pos;
		  Mainbullets_Y_Pos_in = Mainbullets_Y_Pos;
		  Enemybullets_X_Pos_in = Enemybullets_X_Pos;
		  Enemybullets_Y_Pos_in = Enemybullets_Y_Pos;
		  Enemyhighbullets_X_Pos_in = Enemyhighbullets_X_Pos;
		  Enemyhighbullets_Y_Pos_in = Enemyhighbullets_Y_Pos;
		  Tankbullets_X_Pos_in = Tankbullets_X_Pos;
		  Tankbullets_Y_Pos_in = Tankbullets_Y_Pos;
		  Bossbullets_X_Pos_in = Bossbullets_X_Pos;
		  Bossbullets_Y_Pos_in = Bossbullets_Y_Pos;
		  
		  //reload times
		  reloadcount_in = 5'b0; //for default not reloading
		  reloadcount_tank_in = 7'b0;
		  
		  //random movement of boss
		  randommove_in = randommove;
		  if (enemy3_X_Pos == Ball_X_Center  ||  enemy3_X_Pos == Ball_X_Max)
		  randommove_in = randommove + 1'b1;
		  if(randommove == 1'b0)
		  Boss_X_Motion_in = Ball_X_Step;
		  else
		  Boss_X_Motion_in = (~(Ball_X_Step) + 1'b1);
		  Boss_Y_Motion_in = 10'b0;
		  
		  //For each bullet, if it's not shot it's outside the screen, if shot it moves
		  //also bullet speeds are decided here
		  for(int j=0; j<15; j=j+1)
		  begin
			if(Main_shot[j] == 1'b0)
			begin
				Mainbullets_X_Pos_in[j] = Ball_X_Min;
				Mainbullets_Y_Pos_in[j] = Ball_Y_Min;
			end
			else
			begin
				Mainbullets_X_Pos_in[j] = Mainbullets_X_Pos[j] + 10'd2;
				Mainbullets_Y_Pos_in[j] = Mainbullets_Y_Pos[j];
			end
			if(Enemy_shot[j] == 1'b0)
			begin
				Enemybullets_X_Pos_in[j] = Ball_X_Center;
				Enemybullets_Y_Pos_in[j] = Ball_Y_Max + 10'd1;
			end
			else
			begin
				Enemybullets_X_Pos_in[j] = Enemybullets_X_Pos[j] + 10'b1111111110;
				Enemybullets_Y_Pos_in[j] = Enemybullets_Y_Pos[j];
			end
			if(Enemyhigh_shot[j] == 1'b0)
			begin
				Enemyhighbullets_X_Pos_in[j] = Ball_X_Center;
				Enemyhighbullets_Y_Pos_in[j] = Ball_Y_Max + 10'd1;
			end
			else
			begin
				Enemyhighbullets_X_Pos_in[j] = Enemyhighbullets_X_Pos[j] + 10'b1111111111;
				Enemyhighbullets_Y_Pos_in[j] = Enemyhighbullets_Y_Pos[j];
			end
			if(Tank_shot[j] == 1'b0)
			begin
				Tankbullets_X_Pos_in[j] = Ball_X_Center;
				Tankbullets_Y_Pos_in[j] = Ball_Y_Max + 10'd1;
			end
			else
			begin
				Tankbullets_X_Pos_in[j] = Tankbullets_X_Pos[j] + 10'b1111111111;
				Tankbullets_Y_Pos_in[j] = Tankbullets_Y_Pos[j];
				tank_countdown_in = tank_countdown + 2'b01;
			end
			if(Boss_shot[j] == 1'b0)
			begin
				Bossbullets_X_Pos_in[j] = Ball_X_Center;
				Bossbullets_Y_Pos_in[j] = Ball_Y_Max + 10'd1;
			end
			else
			begin
				Bossbullets_X_Pos_in[j] = Enemybullets_X_Pos[j] + 10'b1111111110;
				Bossbullets_Y_Pos_in[j] = Enemybullets_Y_Pos[j];
			end
		  end
		  
		  tank_countdown_in = tank_countdown;
		  if (tank_countdown != 2'b0)
		  tank_countdown_in = tank_countdown + 2'b01;
		  
		  Main_shot_in = Main_shot;
		  Enemy_shot_in = Enemy_shot;
		  Enemyhigh_shot_in = Enemyhigh_shot;
		  Tank_shot_in = Tank_shot;
		  Boss_shot_in = Boss_shot;
		  
		  Mainbullet_count_in = Mainbullet_count;//which bullet is shot
		  Enemybullet_count_in = Enemybullet_count;
		  Enemyhighbullet_count_in = Enemyhighbullet_count;
		  Tankbullet_count_in = Tankbullet_count;
		  Bossbullet_count_in = Bossbullet_count;
		  
        // By default, x motion is 0 y motion is gravity and jump is jump
        Ball_X_Motion_in = 10'd0;
        Ball_Y_Motion_in =  Ball_Y_Step;
		  ball_runcount_in = 2'b0;
		  jump_in = jump;
		  waitcount_in = waitcount + 3'b001;
		  if(waitcount == 3'b0)
		  enemy_runcount_in = enemy_runcount + 1'b1;
		  else
		  enemy_runcount_in = enemy_runcount;
		  
		  if(waitcount == 3'b0)
			 begin
				if(boss_countdown != 2'b11)
				boss_countdown_in = boss_countdown + 2'b01;
				else
				boss_countdown_in = 2'b0;
			 end
			 else
			 boss_countdown_in = boss_countdown;

        // Be careful when using comparators with "logic" datatype because compiler treats
        //   both sides of the operator UNSIGNED numbers. (unless with further type casting)
        // e.g. Ball_Y_Pos - Ball_Size <= Ball_Y_Min
        // If Ball_Y_Pos is 0, then Ball_Y_Pos - Ball_Size will not be -4, but rather a large positive number.
        case(Key)
        //W go up
        5'b10000 :  begin
          if(Ball_Y_Pos + Ball_Size_Y >= Ball_Y_Max)
          jump_in = 1'b1;
        end
        //A go left
        5'b01000 : begin
          Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
			 if(waitcount == 3'b0)
			 begin
				if(ball_runcount != 2'b11)
				ball_runcount_in = ball_runcount + 2'b1;
				else
				ball_runcount_in = 2'b1;
			 end
			 else
			 ball_runcount_in = ball_runcount;
        end
        //D go right
        5'b00010 : begin
          Ball_X_Motion_in = Ball_X_Step;
			 if(waitcount == 3'b0)
			 begin
				if(ball_runcount != 2'b11)
				ball_runcount_in = ball_runcount + 2'b1;
				else
				ball_runcount_in = 2'b1;
			 end
			 else
			 ball_runcount_in = ball_runcount;
        end
		  //Spacebar shoot
		  5'b00001 : begin
		  if(reloadcount == 5'b0)//if not reloading shoot
		  begin
			 Mainbullet_count_in = Mainbullet_count + 4'b0001;
			 if((Mainbullet_count ==4'b0000) && (Main_shot == 16'b0))
			 begin
			 Mainbullets_X_Pos_in[0] = Ball_X_Pos_in + 10'd31;
			 Mainbullets_Y_Pos_in[0] = Ball_Y_Pos_in + 10'd13;
			 Main_shot_in[0] = 1'b1;
			 reloadcount_in = reloadcount + 5'b00001;
			 end
			 else if(Mainbullet_count ==4'b0001)
			 begin
			 Mainbullets_X_Pos_in[1] = Ball_X_Pos_in + 10'd31;
			 Mainbullets_Y_Pos_in[1] = Ball_Y_Pos_in + 10'd13;
			 Main_shot_in[1] = 1'b1;
			 reloadcount_in = reloadcount + 5'b00001;
			 end
			 else if(Mainbullet_count ==4'b0010)
			 begin
			 Mainbullets_X_Pos_in[2] = Ball_X_Pos_in + 10'd31;
			 Mainbullets_Y_Pos_in[2] = Ball_Y_Pos_in + 10'd13;
			 Main_shot_in[2] = 1'b1;
			 reloadcount_in = reloadcount + 5'b00001;
			 end
			 else if(Mainbullet_count ==4'b0011)
			 begin
			 Mainbullets_X_Pos_in[3] = Ball_X_Pos_in + 10'd31;
			 Mainbullets_Y_Pos_in[3] = Ball_Y_Pos_in + 10'd13;
			 Main_shot_in[3] = 1'b1;
			 reloadcount_in = reloadcount + 5'b00001;
			 end
			 else if(Mainbullet_count ==4'b0100)
			 begin
			 Mainbullets_X_Pos_in[4] = Ball_X_Pos_in + 10'd31;
			 Mainbullets_Y_Pos_in[4] = Ball_Y_Pos_in + 10'd13;
			 Main_shot_in[4] = 1'b1;
			 reloadcount_in = reloadcount + 5'b00001;
			 end
			 else if(Mainbullet_count ==4'b0101)
			 begin
			 Mainbullets_X_Pos_in[5] = Ball_X_Pos_in + 10'd31;
			 Mainbullets_Y_Pos_in[5] = Ball_Y_Pos_in + 10'd13;
			 Main_shot_in[5] = 1'b1;
			 reloadcount_in = reloadcount + 5'b00001;
			 end
			 else if(Mainbullet_count ==4'b0110)
			 begin
			 Mainbullets_X_Pos_in[6] = Ball_X_Pos_in + 10'd31;
			 Mainbullets_Y_Pos_in[6] = Ball_Y_Pos_in + 10'd13;
			 Main_shot_in[6] = 1'b1;
			 reloadcount_in = reloadcount + 5'b00001;
			 end
			 else if(Mainbullet_count ==4'b0111)
			 begin
			 Mainbullets_X_Pos_in[7] = Ball_X_Pos_in + 10'd31;
			 Mainbullets_Y_Pos_in[7] = Ball_Y_Pos_in + 10'd13;
			 Main_shot_in[7] = 1'b1;
			 reloadcount_in = reloadcount + 5'b00001;
			 end
			 else if(Mainbullet_count ==4'b1000)
			 begin
			 Mainbullets_X_Pos_in[8] = Ball_X_Pos_in + 10'd31;
			 Mainbullets_Y_Pos_in[8] = Ball_Y_Pos_in + 10'd13;
			 Main_shot_in[8] = 1'b1;
			 reloadcount_in = reloadcount + 5'b00001;
			 end
			 else if(Mainbullet_count ==4'b1001)
			 begin
			 Mainbullets_X_Pos_in[9] = Ball_X_Pos_in + 10'd31;
			 Mainbullets_Y_Pos_in[9] = Ball_Y_Pos_in + 10'd13;
			 Main_shot_in[9] = 1'b1;
			 reloadcount_in = reloadcount + 5'b00001;
			 end
			 else if(Mainbullet_count ==4'b1010)
			 begin
			 Mainbullets_X_Pos_in[10] = Ball_X_Pos_in + 10'd31;
			 Mainbullets_Y_Pos_in[10] = Ball_Y_Pos_in + 10'd13;
			 Main_shot_in[10] = 1'b1;
			 reloadcount_in = reloadcount + 5'b00001;
			 end
			 else if(Mainbullet_count ==4'b1011)
			 begin
			 Mainbullets_X_Pos_in[11] = Ball_X_Pos_in + 10'd31;
			 Mainbullets_Y_Pos_in[11] = Ball_Y_Pos_in + 10'd13;
			 Main_shot_in[11] = 1'b1;
			 reloadcount_in = reloadcount + 5'b00001;
			 end
			 else if(Mainbullet_count ==4'b1100)
			 begin
			 Mainbullets_X_Pos_in[12] = Ball_X_Pos_in + 10'd31;
			 Mainbullets_Y_Pos_in[12] = Ball_Y_Pos_in + 10'd13;
			 Main_shot_in[12] = 1'b1;
			 reloadcount_in = reloadcount + 5'b00001;
			 end
			 else if(Mainbullet_count ==4'b1101)
			 begin
			 Mainbullets_X_Pos_in[13] = Ball_X_Pos_in + 10'd31;
			 Mainbullets_Y_Pos_in[13] = Ball_Y_Pos_in + 10'd13;
			 Main_shot_in[13] = 1'b1;
			 reloadcount_in = reloadcount + 5'b00001;
			 end
			 else if(Mainbullet_count ==4'b1110)
			 begin
			 Mainbullets_X_Pos_in[14] = Ball_X_Pos_in + 10'd31;
			 Mainbullets_Y_Pos_in[14] = Ball_Y_Pos_in + 10'd13;
			 Main_shot_in[14] = 1'b1;
			 reloadcount_in = reloadcount + 5'b00001;
			 end
			 else if(Mainbullet_count ==4'b1111)
			 begin
			 Mainbullets_X_Pos_in[15] = Ball_X_Pos_in + 10'd31;
			 Mainbullets_Y_Pos_in[15] = Ball_Y_Pos_in + 10'd13;
			 Main_shot_in[15] = 1'b1;
			 //start reloading
			 reloadcount_in = reloadcount + 5'b00001;
			 end
		  end
		  end
        endcase
		  
		  //ENEMY SHOTS
		  if(reloadcount_tank == 7'b0)//if not reloading shoot
		  begin
			 Enemybullet_count_in = Enemybullet_count + 4'b0001;
		    if((Enemybullet_count ==4'b0000) && (Enemy_shot == 16'b0))
			 begin
			 Enemybullets_X_Pos_in[0] = enemy0_X_Pos_in + 10'd5;
			 Enemybullets_Y_Pos_in[0] = enemy0_Y_Pos_in + 10'd15;
			 Enemy_shot_in[0] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 6'b00001;
			 end
			 else if(Enemybullet_count ==4'b0001)
			 begin
			 Enemybullets_X_Pos_in[1] = enemy0_X_Pos_in + 10'd5;
			 Enemybullets_Y_Pos_in[1] = enemy0_Y_Pos_in + 10'd15;
			 Enemy_shot_in[1] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 6'b00001;
			 end
			 else if(Enemybullet_count ==4'b0010)
			 begin
			 Enemybullets_X_Pos_in[2] = enemy0_X_Pos_in + 10'd5;
			 Enemybullets_Y_Pos_in[2] = enemy0_Y_Pos_in + 10'd15;
			 Enemy_shot_in[2] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 6'b00001;
			 end
			 else if(Enemybullet_count ==4'b0011)
			 begin
			 Enemybullets_X_Pos_in[3] = enemy0_X_Pos_in + 10'd5;
			 Enemybullets_Y_Pos_in[3] = enemy0_Y_Pos_in + 10'd15;
			 Enemy_shot_in[3] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 6'b00001;
			 end
			 else if(Enemybullet_count ==4'b0100)
			 begin
			 Enemybullets_X_Pos_in[4] = enemy0_X_Pos_in + 10'd5;
			 Enemybullets_Y_Pos_in[4] = enemy0_Y_Pos_in + 10'd15;
			 Enemy_shot_in[4] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 6'b00001;
			 end
			 else if(Enemybullet_count ==4'b0101)
			 begin
			 Enemybullets_X_Pos_in[5] = enemy0_X_Pos_in + 10'd5;
			 Enemybullets_Y_Pos_in[5] = enemy0_Y_Pos_in + 10'd15;
			 Enemy_shot_in[5] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 6'b00001;
			 end
			 else if(Enemybullet_count ==4'b0110)
			 begin
			 Enemybullets_X_Pos_in[6] = enemy0_X_Pos_in + 10'd5;
			 Enemybullets_Y_Pos_in[6] = enemy0_Y_Pos_in + 10'd15;
			 Enemy_shot_in[6] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 6'b00001;
			 end
			 else if(Enemybullet_count ==4'b0111)
			 begin
			 Enemybullets_X_Pos_in[7] = enemy0_X_Pos_in + 10'd5;
			 Enemybullets_Y_Pos_in[7] = enemy0_Y_Pos_in + 10'd15;
			 Enemy_shot_in[7] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 6'b00001;
			 end
			 else if(Enemybullet_count ==4'b1000)
			 begin
			 Enemybullets_X_Pos_in[8] = enemy0_X_Pos_in + 10'd5;
			 Enemybullets_Y_Pos_in[8] = enemy0_Y_Pos_in + 10'd15;
			 Enemy_shot_in[8] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 6'b00001;
			 end
			 else if(Enemybullet_count ==4'b1001)
			 begin
			 Enemybullets_X_Pos_in[9] = enemy0_X_Pos_in + 10'd5;
			 Enemybullets_Y_Pos_in[9] = enemy0_Y_Pos_in + 10'd15;
			 Enemy_shot_in[9] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 6'b00001;
			 end
			 else if(Enemybullet_count ==4'b1010)
			 begin
			 Enemybullets_X_Pos_in[10] = enemy0_X_Pos_in + 10'd5;
			 Enemybullets_Y_Pos_in[10] = enemy0_Y_Pos_in + 10'd15;
			 Enemy_shot_in[10] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 6'b00001;
			 end
			 else if(Enemybullet_count ==4'b1011)
			 begin
			 Enemybullets_X_Pos_in[11] = enemy0_X_Pos_in + 10'd5;
			 Enemybullets_Y_Pos_in[11] = enemy0_Y_Pos_in + 10'd15;
			 Enemy_shot_in[11] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 6'b00001;
			 end
			 else if(Enemybullet_count ==4'b1100)
			 begin
			 Enemybullets_X_Pos_in[12] = enemy0_X_Pos_in + 10'd5;
			 Enemybullets_Y_Pos_in[12] = enemy0_Y_Pos_in + 10'd15;
			 Enemy_shot_in[12] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 6'b00001;
			 end
			 else if(Enemybullet_count ==4'b1101)
			 begin
			 Enemybullets_X_Pos_in[13] = enemy0_X_Pos_in + 10'd5;
			 Enemybullets_Y_Pos_in[13] = enemy0_Y_Pos_in + 10'd15;
			 Enemy_shot_in[13] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 6'b00001;
			 end
			 else if(Enemybullet_count ==4'b1110)
			 begin
			 Enemybullets_X_Pos_in[14] = enemy0_X_Pos_in + 10'd5;
			 Enemybullets_Y_Pos_in[14] = enemy0_Y_Pos_in + 10'd15;
			 Enemy_shot_in[14] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 6'b00001;
			 end
			 else if(Enemybullet_count ==4'b1111)
			 begin
			 Enemybullets_X_Pos_in[15] = enemy0_X_Pos_in + 10'd5;
			 Enemybullets_Y_Pos_in[15] = enemy0_Y_Pos_in + 10'd15;
			 Enemy_shot_in[15] = 1'b1;
			 //start reloading
			 reloadcount_tank_in = reloadcount_tank + 6'b00001;
			 end
		  end
			 
		  //ENEMY_HIGH SHOTS
		  if(reloadcount_tank == 5'b0)//if not reloading shoot
		  begin
			 Enemyhighbullet_count_in = Enemyhighbullet_count + 4'b0001;
			 if((Enemyhighbullet_count ==4'b0000) && (Enemyhigh_shot == 16'b0))
			 begin 
			 Enemyhighbullets_X_Pos_in[0] = enemy1_X_Pos_in + 10'd0;
			 Enemyhighbullets_Y_Pos_in[0] = enemy1_Y_Pos_in + 10'd12;
			 Enemyhigh_shot_in[0] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
			 else if(Enemyhighbullet_count ==4'b0001)
			 begin
			 Enemyhighbullets_X_Pos_in[1] = enemy1_X_Pos_in + 10'd0;
			 Enemyhighbullets_Y_Pos_in[1] = enemy1_Y_Pos_in + 10'd12;
			 Enemyhigh_shot_in[1] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
			 else if(Enemyhighbullet_count ==4'b0010)
			 begin
			 Enemyhighbullets_X_Pos_in[2] = enemy1_X_Pos_in + 10'd0;
			 Enemyhighbullets_Y_Pos_in[2] = enemy1_Y_Pos_in + 10'd12;
			 Enemyhigh_shot_in[2] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
			 else if(Enemyhighbullet_count ==4'b0011)
			 begin
			 Enemyhighbullets_X_Pos_in[3] = enemy1_X_Pos_in + 10'd0;
			 Enemyhighbullets_Y_Pos_in[3] = enemy1_Y_Pos_in + 10'd12;
			 Enemyhigh_shot_in[3] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
			 else if(Enemyhighbullet_count ==4'b0100)
			 begin
			 Enemyhighbullets_X_Pos_in[4] = enemy1_X_Pos_in + 10'd0;
			 Enemyhighbullets_Y_Pos_in[4] = enemy1_Y_Pos_in + 10'd12;
			 Enemyhigh_shot_in[4] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
			 else if(Enemyhighbullet_count ==4'b0101)
			 begin
			 Enemyhighbullets_X_Pos_in[5] = enemy1_X_Pos_in + 10'd0;
			 Enemyhighbullets_Y_Pos_in[5] = enemy1_Y_Pos_in + 10'd12;
			 Enemyhigh_shot_in[5] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
			 else if(Enemyhighbullet_count ==4'b0110)
			 begin
			 Enemyhighbullets_X_Pos_in[6] = enemy1_X_Pos_in + 10'd0;
			 Enemyhighbullets_Y_Pos_in[6] = enemy1_Y_Pos_in + 10'd12;
			 Enemyhigh_shot_in[6] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
			 else if(Enemyhighbullet_count ==4'b0111)
			 begin
			 Enemyhighbullets_X_Pos_in[7] = enemy1_X_Pos_in + 10'd0;
			 Enemyhighbullets_Y_Pos_in[7] = enemy1_Y_Pos_in + 10'd12;
			 Enemyhigh_shot_in[7] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
			 else if(Enemyhighbullet_count ==4'b1000)
			 begin
			 Enemyhighbullets_X_Pos_in[8] = enemy1_X_Pos_in + 10'd0;
			 Enemyhighbullets_Y_Pos_in[8] = enemy1_Y_Pos_in + 10'd12;
			 Enemyhigh_shot_in[8] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
			 else if(Enemyhighbullet_count ==4'b1001)
			 begin
			 Enemyhighbullets_X_Pos_in[9] = enemy1_X_Pos_in + 10'd0;
			 Enemyhighbullets_Y_Pos_in[9] = enemy1_Y_Pos_in + 10'd12;
			 Enemyhigh_shot_in[9] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
			 else if(Enemyhighbullet_count ==4'b1010)
			 begin
			 Enemyhighbullets_X_Pos_in[10] = enemy1_X_Pos_in + 10'd0;
			 Enemyhighbullets_Y_Pos_in[10] = enemy1_Y_Pos_in + 10'd12;
			 Enemyhigh_shot_in[10] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
			 else if(Enemyhighbullet_count ==4'b1011)
			 begin
			 Enemyhighbullets_X_Pos_in[11] = enemy1_X_Pos_in + 10'd0;
			 Enemyhighbullets_Y_Pos_in[11] = enemy1_Y_Pos_in + 10'd12;
			 Enemyhigh_shot_in[11] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
			 else if(Enemyhighbullet_count ==4'b1100)
			 begin
			 Enemyhighbullets_X_Pos_in[12] = enemy1_X_Pos_in + 10'd0;
			 Enemyhighbullets_Y_Pos_in[12] = enemy1_Y_Pos_in + 10'd12;
			 Enemyhigh_shot_in[12] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
			 else if(Enemyhighbullet_count ==4'b1101)
			 begin
			 Enemyhighbullets_X_Pos_in[13] = enemy1_X_Pos_in + 10'd0;
			 Enemyhighbullets_Y_Pos_in[13] = enemy1_Y_Pos_in + 10'd12;
			 Enemyhigh_shot_in[13] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
			 else if(Enemyhighbullet_count ==4'b1110)
			 begin
			 Enemyhighbullets_X_Pos_in[14] = enemy1_X_Pos_in + 10'd0;
			 Enemyhighbullets_Y_Pos_in[14] = enemy1_Y_Pos_in + 10'd12;
			 Enemyhigh_shot_in[14] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
			 else if(Enemyhighbullet_count ==4'b1111)
			 begin
			 Enemyhighbullets_X_Pos_in[15] = enemy1_X_Pos_in + 10'd0;
			 Enemyhighbullets_Y_Pos_in[15] = enemy1_Y_Pos_in + 10'd12;
			 Enemyhigh_shot_in[15] = 1'b1;
			 //start reloading
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
		  end
			
			//TANK SHOTS 
		  if(reloadcount_tank == 5'b0 && (enemy2_X_Pos <= (Ball_X_Max - Tank_Size_X)))//if not reloading shoot
		  begin
			 Tankbullet_count_in = Tankbullet_count + 4'b0001;
			 if((Tankbullet_count ==4'b0000) && (Tank_shot == 16'b0))
			 begin 
			 Tankbullets_X_Pos_in[0] = enemy2_X_Pos_in + 10'd0;
			 Tankbullets_Y_Pos_in[0] = enemy2_Y_Pos_in + 10'd5;
			 Tank_shot_in[0] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
			 else if(Tankbullet_count ==4'b0001)
			 begin
			 Tankbullets_X_Pos_in[1] = enemy2_X_Pos_in + 10'd0;
			 Tankbullets_Y_Pos_in[1] = enemy2_Y_Pos_in + 10'd5;
			 Tank_shot_in[1] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
			 else if(Tankbullet_count ==4'b0010)
			 begin
			 Tankbullets_X_Pos_in[2] = enemy2_X_Pos_in + 10'd0;
			 Tankbullets_Y_Pos_in[2] = enemy2_Y_Pos_in + 10'd5;
			 Tank_shot_in[2] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
			 else if(Tankbullet_count ==4'b0011)
			 begin
			 Tankbullets_X_Pos_in[3] = enemy2_X_Pos_in + 10'd0;
			 Tankbullets_Y_Pos_in[3] = enemy2_Y_Pos_in + 10'd5;
			 Tank_shot_in[3] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
			 else if(Tankbullet_count ==4'b0100)
			 begin
			 Tankbullets_X_Pos_in[4] = enemy2_X_Pos_in + 10'd0;
			 Tankbullets_Y_Pos_in[4] = enemy2_Y_Pos_in + 10'd5;
			 Tank_shot_in[4] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
			 else if(Tankbullet_count ==4'b0101)
			 begin
			 Tankbullets_X_Pos_in[5] = enemy2_X_Pos_in + 10'd0;
			 Tankbullets_Y_Pos_in[5] = enemy2_Y_Pos_in + 10'd5;
			 Tank_shot_in[5] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
			 else if(Tankbullet_count ==4'b0110)
			 begin
			 Tankbullets_X_Pos_in[6] = enemy2_X_Pos_in + 10'd0;
			 Tankbullets_Y_Pos_in[6] = enemy2_Y_Pos_in + 10'd5;
			 Tank_shot_in[6] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
			 else if(Tankbullet_count ==4'b0111)
			 begin
			 Tankbullets_X_Pos_in[7] = enemy2_X_Pos_in + 10'd0;
			 Tankbullets_Y_Pos_in[7] = enemy2_Y_Pos_in + 10'd5;
			 Tank_shot_in[7] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
			 else if(Tankbullet_count ==4'b1000)
			 begin
			 Tankbullets_X_Pos_in[8] = enemy2_X_Pos_in + 10'd0;
			 Tankbullets_Y_Pos_in[8] = enemy2_Y_Pos_in + 10'd5;
			 Tank_shot_in[8] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
			 else if(Tankbullet_count ==4'b1001)
			 begin
			 Tankbullets_X_Pos_in[9] = enemy2_X_Pos_in + 10'd0;
			 Tankbullets_Y_Pos_in[9] = enemy2_Y_Pos_in + 10'd5;
			 Tank_shot_in[9] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
			 else if(Tankbullet_count ==4'b1010)
			 begin
			 Tankbullets_X_Pos_in[10] = enemy2_X_Pos_in + 10'd0;
			 Tankbullets_Y_Pos_in[10] = enemy2_Y_Pos_in + 10'd5;
			 Tank_shot_in[10] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
			 else if(Tankbullet_count ==4'b1011)
			 begin
			 Tankbullets_X_Pos_in[11] = enemy2_X_Pos_in + 10'd0;
			 Tankbullets_Y_Pos_in[11] = enemy2_Y_Pos_in + 10'd5;
			 Tank_shot_in[11] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
			 else if(Tankbullet_count ==4'b1100)
			 begin
			 Tankbullets_X_Pos_in[12] = enemy2_X_Pos_in + 10'd0;
			 Tankbullets_Y_Pos_in[12] = enemy2_Y_Pos_in + 10'd5;
			 Tank_shot_in[12] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
			 else if(Tankbullet_count ==4'b1101)
			 begin
			 Tankbullets_X_Pos_in[13] = enemy2_X_Pos_in + 10'd0;
			 Tankbullets_Y_Pos_in[13] = enemy2_Y_Pos_in + 10'd5;
			 Tank_shot_in[13] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
			 else if(Tankbullet_count ==4'b1110)
			 begin
			 Tankbullets_X_Pos_in[14] = enemy2_X_Pos_in + 10'd0;
			 Tankbullets_Y_Pos_in[14] = enemy2_Y_Pos_in + 10'd5;
			 Tank_shot_in[14] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
			 else if(Tankbullet_count ==4'b1111)
			 begin
			 Tankbullets_X_Pos_in[15] = enemy2_X_Pos_in + 10'd0;
			 Tankbullets_Y_Pos_in[15] = enemy2_Y_Pos_in + 10'd5;
			 Tank_shot_in[15] = 1'b1;
			 //start reloading
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
		  end
		  
		//BOSS SHOTS 
		  if(reloadcount_tank == 5'b0 && (enemy3_X_Pos <= (Ball_X_Max - Boss_Size_X)))//if not reloading shoot
		  begin
			 Bossbullet_count_in = Bossbullet_count + 4'b0001;
			 if((Bossbullet_count ==4'b0000) && (Boss_shot == 16'b0))
			 begin 
			 Bossbullets_X_Pos_in[0] = enemy3_X_Pos_in + 10'd0;
			 Bossbullets_Y_Pos_in[0] = enemy3_Y_Pos_in + 10'd15;
			 Boss_shot_in[0] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
			 else if(Bossbullet_count ==4'b0001)
			 begin
			 Bossbullets_X_Pos_in[1] = enemy3_X_Pos_in + 10'd0;
			 Bossbullets_Y_Pos_in[1] = enemy3_Y_Pos_in + 10'd15;
			 Boss_shot_in[1] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
			 else if(Bossbullet_count ==4'b0010)
			 begin
			 Bossbullets_X_Pos_in[2] = enemy3_X_Pos_in + 10'd0;
			 Bossbullets_Y_Pos_in[2] = enemy3_Y_Pos_in + 10'd15;
			 Boss_shot_in[2] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
			 else if(Bossbullet_count ==4'b0011)
			 begin
			 Bossbullets_X_Pos_in[3] = enemy3_X_Pos_in + 10'd0;
			 Bossbullets_Y_Pos_in[3] = enemy3_Y_Pos_in + 10'd15;
			 Boss_shot_in[3] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
			 else if(Bossbullet_count ==4'b0100)
			 begin
			 Bossbullets_X_Pos_in[4] = enemy3_X_Pos_in + 10'd0;
			 Bossbullets_Y_Pos_in[4] = enemy3_Y_Pos_in + 10'd15;
			 Boss_shot_in[4] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
			 else if(Bossbullet_count ==4'b0101)
			 begin
			 Bossbullets_X_Pos_in[5] = enemy3_X_Pos_in + 10'd0;
			 Bossbullets_Y_Pos_in[5] = enemy3_Y_Pos_in + 10'd15;
			 Boss_shot_in[5] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
			 else if(Bossbullet_count ==4'b0110)
			 begin
			 Bossbullets_X_Pos_in[6] = enemy3_X_Pos_in + 10'd0;
			 Bossbullets_Y_Pos_in[6] = enemy3_Y_Pos_in + 10'd15;
			 Boss_shot_in[6] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
			 else if(Bossbullet_count ==4'b0111)
			 begin
			 Bossbullets_X_Pos_in[7] = enemy3_X_Pos_in + 10'd0;
			 Bossbullets_Y_Pos_in[7] = enemy3_Y_Pos_in + 10'd15;
			 Boss_shot_in[7] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
			 else if(Bossbullet_count ==4'b1000)
			 begin
			 Bossbullets_X_Pos_in[8] = enemy3_X_Pos_in + 10'd0;
			 Bossbullets_Y_Pos_in[8] = enemy3_Y_Pos_in + 10'd15;
			 Boss_shot_in[8] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
			 else if(Bossbullet_count ==4'b1001)
			 begin
			 Bossbullets_X_Pos_in[9] = enemy3_X_Pos_in + 10'd0;
			 Bossbullets_Y_Pos_in[9] = enemy3_Y_Pos_in + 10'd15;
			 Boss_shot_in[9] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
			 else if(Bossbullet_count ==4'b1010)
			 begin
			 Bossbullets_X_Pos_in[10] = enemy3_X_Pos_in + 10'd0;
			 Bossbullets_Y_Pos_in[10] = enemy3_Y_Pos_in + 10'd15;
			 Boss_shot_in[10] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
			 else if(Bossbullet_count ==4'b1011)
			 begin
			 Bossbullets_X_Pos_in[11] = enemy3_X_Pos_in + 10'd0;
			 Bossbullets_Y_Pos_in[11] = enemy3_Y_Pos_in + 10'd15;
			 Boss_shot_in[11] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
			 else if(Bossbullet_count ==4'b1100)
			 begin
			 Bossbullets_X_Pos_in[12] = enemy3_X_Pos_in + 10'd0;
			 Bossbullets_Y_Pos_in[12] = enemy3_Y_Pos_in + 10'd15;
			 Boss_shot_in[12] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
			 else if(Bossbullet_count ==4'b1101)
			 begin
			 Bossbullets_X_Pos_in[13] = enemy3_X_Pos_in + 10'd0;
			 Bossbullets_Y_Pos_in[13] = enemy3_Y_Pos_in + 10'd15;
			 Boss_shot_in[13] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
			 else if(Bossbullet_count ==4'b1110)
			 begin
			 Bossbullets_X_Pos_in[14] = enemy3_X_Pos_in + 10'd0;
			 Bossbullets_Y_Pos_in[14] = enemy3_Y_Pos_in + 10'd15;
			 Boss_shot_in[14] = 1'b1;
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
			 else if(Bossbullet_count ==4'b1111)
			 begin
			 Bossbullets_X_Pos_in[15] = enemy3_X_Pos_in + 10'd0;
			 Bossbullets_Y_Pos_in[15] = enemy3_Y_Pos_in + 10'd15;
			 Boss_shot_in[15] = 1'b1;
			 //start reloading
			 reloadcount_tank_in = reloadcount_tank + 7'b00001;
			 end
		  end
			 
		  //if reloading, keep counting until reload is over (counter reaches 0 again)
		  if(reloadcount != 5'b0 && reloadcount != 5'b11111)
		  reloadcount_in = reloadcount + 5'b00001;
		  else if (reloadcount == 5'b11111)
		  reloadcount_in = 5'b0;
		  if(reloadcount_tank != 7'b0 && reloadcount_tank != 7'b1111111)
		  reloadcount_tank_in = reloadcount_tank + 7'b0000001;
		  else if (reloadcount_tank == 7'b1111111)
		  reloadcount_tank_in = 7'b0;

		  
//MOTIONS
		  //if at the end of the screen bullets are renewed/not shot anymore
		  for(int k=0; k<15; k=k+1)
		  begin
		  if(Mainbullets_X_Pos[k] >= Ball_X_Max)
		  Main_shot_in[k] = 1'b0;
		  if(Enemybullets_X_Pos[k] <= Ball_X_Min || Enemybullets_X_Pos[k] >= Ball_X_Max)
		  Enemy_shot_in[k] = 1'b0;
		  if(Enemyhighbullets_X_Pos[k] <= Ball_X_Min || Enemyhighbullets_X_Pos[k] >= Ball_X_Max)
		  Enemyhigh_shot_in[k] = 1'b0;
		  if(Tankbullets_X_Pos[k] <= Ball_X_Min || Tankbullets_X_Pos[k] >= Ball_X_Max)
		  Tank_shot_in[k] = 1'b0;
		  if(Bossbullets_X_Pos[k] <= Ball_X_Min || Bossbullets_X_Pos[k] >= Ball_X_Max)
		  Boss_shot_in[k] = 1'b0;
		  end
		  
		  
		  //ball movements
        if ( Ball_Y_Pos + Ball_Size_Y + Ball_Size_Y + Ball_Size_Y <= Ball_Y_Max )
            jump_in = 1'b0;
        else if( jump == 1'b1 )
            Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);
        else if( Ball_Y_Pos + Ball_Size_Y >= Ball_Y_Max )  // Ball is at the bottom edge, stay!
            Ball_Y_Motion_in = 10'd0;  // 2's complement.
        else if ( Ball_Y_Pos <= Ball_Y_Min + Ball_Size_Y )  // Ball is at the top edge, BOUNCE!
            Ball_Y_Motion_in = Ball_Y_Step;
        if( Ball_X_Pos + Ball_Size_X >= Ball_X_Max )  // Ball is at the right edge, BOUNCE!
            Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);  // 2's complement.
        else if ( Ball_X_Pos <= Ball_X_Min + Ball_Size_X )  // Ball is at the left edge, BOUNCE!
            Ball_X_Motion_in = Ball_X_Step;


		  tank_dead_in = tank_dead;
		  boss_dead_in = boss_dead;
		  if(enemy2_hit == 1'b1)
		  begin
				tank_dead_in = tank_dead + 3'b001;
				enemy2_hit_in = 1'b0;
		  end
		  if(enemy3_hit == 1'b1)
		  begin
				boss_dead_in = boss_dead + 4'b0001;
				enemy3_hit_in = 1'b0;
		  end
		  //if enemy is at the left it is teleported back
		  if ((enemy0_X_Pos <= Ball_X_Min) || (enemy0_hit == 1'b1))
		  begin
				enemy0_X_Pos_in = Ball_X_Max + Soldier_Size_X;
				enemy0_hit_in = 1'b0;
		  end
		  if ((enemy1_X_Pos <= Ball_X_Min) || (enemy1_hit == 1'b1))
		  begin
				enemy1_X_Pos_in = Ball_X_Max + Soldierhigh_Size_X + Soldierhigh_Size_X;
				enemy1_hit_in = 1'b0;
		  end
		  if ((enemy2_X_Pos <= Ball_X_Min) || (tank_dead == 3'b111))
		  begin
				enemy2_X_Pos_in = Ball_X_Max + Tank_Size_X + Tank_Size_X + Tank_Size_X;
				tank_dead_in = 3'b000;
		  end
		  if ((enemy3_X_Pos <= Ball_X_Min) || (boss_dead == 4'b1111))
		  begin
				enemy3_X_Pos_in = Ball_X_Max + Tank_Size_X + Tank_Size_X + Tank_Size_X;
				boss_dead_in = 4'b0000;
		  end
    /**************************************************************************************
        ATTENTION! Please answer the following quesiton in your lab report! Points will be allocated for the answers!
        Hidden Question #2/2:
          Notice that Ball_Y_Pos is updated using Ball_Y_Motion.
          Will the new value of Ball_Y_Motion be used when Ball_Y_Pos is updated, or the old?
          What is the difference between writing
            "Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;" and
            "Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion_in;"?
          How will this impact behavior of the ball during a bounce, and how might that interact with a response to a keypress?
          Give an answer in your Post-Lab.
    **************************************************************************************/

        // Compute whether the pixel corresponds to ball or background
		  colorValue = 6'b0; //value is all 0s by default
		  
		  isbullet = 16'b0; //bullet isn't in current pixel by default
		  isbullet_enemy = 16'b0;
		  isbullet_enemyhigh = 16'b0;
		  isbullet_tank = 16'b0;
		  isbullet_boss = 16'b0;
		  
		  enemy0_hit_in = 1'b0; //enemy not hit by default
		  enemy1_hit_in = 1'b0;
		  enemy2_hit_in = 1'b0;
		  enemy3_hit_in = 1'b0;
		  main_hit_in = 1'b0;
		  health_in = health;

		  for(int l=0; l<15; l=l+1)
		  begin
		  if ((Mainbullets_DistX[l] < Bullet_Size_X) && (Mainbullets_DistY[l] < Bullet_Size_Y))
		  isbullet[l] = 1'b1;
		  if ((Enemybullets_DistX[l] < Bullet_Size_X) && (Enemybullets_DistY[l] < Bullet_Size_Y))
		  isbullet_enemy[l] = 1'b1;
		  if ((Enemyhighbullets_DistX[l] < Bullet_Size_X) && (Enemyhighbullets_DistY[l] < Rocket_Size_Y))
		  isbullet_enemyhigh[l] = 1'b1;
		  if ((Tankbullets_DistX[l] < Bullet_Size_X) && (Tankbullets_DistY[l] < Rocket_Size_Y))
		  isbullet_tank[l] = 1'b1;
		  if ((Bossbullets_DistX[l] < Bullet_Size_X) && (Bossbullets_DistY[l] < Bullet_Size_Y))
		  isbullet_boss[l] = 1'b1;
		  
		  if (((Enemybullets_X_Pos[l] - Ball_X_Pos) < Ball_Size_X) && ((Enemybullets_Y_Pos[l] - Ball_Y_Pos) < Ball_Size_Y))
			begin
			main_hit_in = 1'b1;
			Enemy_shot_in[l] = 1'b0;
			health_in = health - 5'b00001;
			end
			else if (((Enemyhighbullets_X_Pos[l] - Ball_X_Pos) < Ball_Size_X) && ((Enemyhighbullets_Y_Pos[l] - Ball_Y_Pos) < Ball_Size_Y))
			begin
			main_hit_in = 1'b1;
			Enemyhigh_shot_in[l] = 1'b0;
			health_in = health - 5'b00010;
			end
			else if (((Tankbullets_X_Pos[l] - Ball_X_Pos) < Ball_Size_X) && ((Tankbullets_Y_Pos[l] - Ball_Y_Pos) < Ball_Size_Y))
			begin
			main_hit_in = 1'b1;
			Tank_shot_in[l] = 1'b0;
			health_in = health - 5'b00010;
			end
		  if (((Mainbullets_X_Pos[l] - enemy0_X_Pos) < Soldier_Size_X) && ((Mainbullets_Y_Pos[l] - enemy0_Y_Pos) < Soldier_Size_Y))
			begin
			enemy0_hit_in = 1'b1;
			Main_shot_in[l] = 1'b0;
			end
		  else if (((Mainbullets_X_Pos[l] - enemy1_X_Pos) < Soldierhigh_Size_X) && ((Mainbullets_Y_Pos[l] - enemy1_Y_Pos) < Soldierhigh_Size_Y))
			begin
			enemy1_hit_in = 1'b1;
			Main_shot_in[l] = 1'b0;
			end
		  else if (((Mainbullets_X_Pos[l] - enemy2_X_Pos) < Tank_Size_X) && ((Mainbullets_Y_Pos[l] - enemy2_Y_Pos) < Tank_Size_Y))
			begin
			enemy2_hit_in = 1'b1;
			Main_shot_in[l] = 1'b0;
			end
		  else if (((Mainbullets_X_Pos[l] - enemy3_X_Pos) < Boss_Size_X) && ((Mainbullets_Y_Pos[l] - enemy3_Y_Pos) < Boss_Size_Y))
			begin
			enemy3_hit_in = 1'b1;
			Main_shot_in[l] = 1'b0;
			end
		  end
		  
			if(state == 2'b00)
			colorValue = 6'h2;
			else if (state == 2'b10)
			colorValue = 6'he;
			else if (state == 2'b11)
			colorValue = 6'h3;
		   //megaman jumping
			else if ((Ball_DistX < Ball_Size_X) && (Ball_DistY < Ball_Size_Y) && (megaman_jumping_text[Ball_DistY][Ball_DistX] != 6'b0) &&  (jump == 1'b1))
			colorValue = megaman_jumping_text[Ball_DistY][Ball_DistX];
			//megaman running1
			else if((Ball_DistX < Ball_Size_X) && (Ball_DistY < Ball_Size_Y) && (megaman_running1_text[Ball_DistY][Ball_DistX] != 6'b0) &&  (ball_runcount == 2'b01) &&  (jump != 1'b1))
			colorValue = megaman_running1_text[Ball_DistY][Ball_DistX]; //value is that pixel of megaman_text
			//megaman running2
			else if((Ball_DistX < Ball_Size_X) && (Ball_DistY < Ball_Size_Y) && (megaman_running2_text[Ball_DistY][Ball_DistX] != 6'b0) &&  (ball_runcount == 2'b10) &&  (jump != 1'b1))
			colorValue = megaman_running2_text[Ball_DistY][Ball_DistX];
			//megaman running3
			else if((Ball_DistX < Ball_Size_X) && (Ball_DistY < Ball_Size_Y) && (megaman_running3_text[Ball_DistY][Ball_DistX] != 6'b0) &&  (ball_runcount == 2'b11) &&  (jump != 1'b1))
			colorValue = megaman_running3_text[Ball_DistY][Ball_DistX];
			//megaman shooting
			else if((Ball_DistX < Ball_Size_X) && (Ball_DistY < Ball_Size_Y) && (megaman_shooting_text[Ball_DistY][Ball_DistX] != 6'b0) &&  (ball_runcount == 2'b00) &&  (jump != 1'b1))
			colorValue = megaman_shooting_text[Ball_DistY][Ball_DistX];
			//soldier1 shot
			else if ((enemy0_hit == 1'b1) && (enemy0_DistX < Soldier_Size_X) && (enemy0_DistY < Soldier_Size_Y) && (enemy_runcount == 1'b0) &&  (soldier1_text[enemy0_DistY][enemy0_DistX] != 6'b0))
			colorValue = 6'he;//if shot soldier becomes red	
			//soldier1 not shot
			else if ((enemy0_hit != 1'b1) && (enemy0_DistX < Soldier_Size_X) && (enemy0_DistY < Soldier_Size_Y) && (enemy_runcount == 1'b0) &&  (soldier1_text[enemy0_DistY][enemy0_DistX] != 6'b0))
			colorValue = soldier1_text[enemy0_DistY][enemy0_DistX]; //value is that pixel of soldier_text
			//soldier2 shot
			else if ((enemy0_hit == 1'b1) && (enemy0_DistX < Soldier_Size_X) && (enemy0_DistY < Soldier_Size_Y) && (enemy_runcount == 1'b1) &&  (soldier2_text[enemy0_DistY][enemy0_DistX] != 6'b0))
			colorValue = 6'he;//if shot soldier becomes red;
			//soldier2 not shot
			else if ((enemy0_hit != 1'b1) && (enemy0_DistX < Soldier_Size_X) && (enemy0_DistY < Soldier_Size_Y) && (enemy_runcount == 1'b1) &&  (soldier2_text[enemy0_DistY][enemy0_DistX] != 6'b0))
			colorValue = soldier2_text[enemy0_DistY][enemy0_DistX];
			//soldierhigh1 shot
			else if ((enemy1_hit == 1'b1) && (enemy1_DistX < Soldierhigh_Size_X) && (enemy1_DistY < Soldierhigh_Size_Y) && (enemy_runcount == 1'b0) &&  (soldierhigh1_text[enemy1_DistY][enemy1_DistX] != 6'b0))
			colorValue = 6'he;
			//soldierhigh1 not shot
			else if ((enemy1_hit != 1'b1) && (enemy1_DistX < Soldierhigh_Size_X) && (enemy1_DistY < Soldierhigh_Size_Y) && (enemy_runcount == 1'b0) &&  (soldierhigh1_text[enemy1_DistY][enemy1_DistX] != 6'b0))
			colorValue = soldierhigh1_text[enemy1_DistY][enemy1_DistX];
			//soldierhigh2 shot
			else if ((enemy1_hit == 1'b1) && (enemy1_DistX < Soldierhigh_Size_X) && (enemy1_DistY < Soldierhigh_Size_Y) && (enemy_runcount == 1'b1) &&  (soldierhigh1_text[enemy1_DistY][enemy1_DistX] != 6'b0))
			colorValue = 6'he;
			//soldierhigh2 not shot
			else if ((enemy1_hit != 1'b1) && (enemy1_DistX < Soldierhigh_Size_X) && (enemy1_DistY < Soldierhigh_Size_Y) && (enemy_runcount == 1'b1) &&  (soldierhigh1_text[enemy1_DistY][enemy1_DistX] != 6'b0))
			colorValue = soldierhigh2_text[enemy1_DistY][enemy1_DistX];
			//tank1 shot
			else if ((enemy2_hit == 1'b1) && (enemy2_DistX < Tank_Size_X) && (enemy2_DistY < Tank_Size_Y) && (tank_countdown == 2'b00) &&  (tank1_text[enemy2_DistY][enemy2_DistX] != 6'b0))
			colorValue = 6'he;
			//tank1 not shot
			else if ((enemy2_hit != 1'b1) && (enemy2_DistX < Tank_Size_X) && (enemy2_DistY < Tank_Size_Y) && (tank_countdown == 2'b00) &&  (tank1_text[enemy2_DistY][enemy2_DistX] != 6'b0))
			colorValue = tank1_text[enemy2_DistY][enemy2_DistX];
			//tank2 shot
			else if ((enemy2_hit == 1'b1) && (enemy2_DistX < Tank_Size_X) && (enemy2_DistY < Tank_Size_Y) && (tank_countdown == 2'b01) &&  (tank2_text[enemy2_DistY][enemy2_DistX] != 6'b0))
			colorValue = 6'he;
			//tank2 not shot
			else if ((enemy2_hit != 1'b1) && (enemy2_DistX < Tank_Size_X) && (enemy2_DistY < Tank_Size_Y) && (tank_countdown == 2'b01) &&  (tank2_text[enemy2_DistY][enemy2_DistX] != 6'b0))
			colorValue = tank2_text[enemy2_DistY][enemy2_DistX];
			//tank3 shot
			else if ((enemy2_hit == 1'b1) && (enemy2_DistX < Tank_Size_X) && (enemy2_DistY < Tank_Size_Y) && (tank_countdown >= 2'b10) &&  (tank3_text[enemy2_DistY][enemy2_DistX] != 6'b0))
			colorValue = 6'he;
			//tank3 not shot
			else if ((enemy2_hit != 1'b1) && (enemy2_DistX < Tank_Size_X) && (enemy2_DistY < Tank_Size_Y) && (tank_countdown >= 2'b10) &&  (tank3_text[enemy2_DistY][enemy2_DistX] != 6'b0))
			colorValue = tank3_text[enemy2_DistY][enemy2_DistX];
			//boss1 shot
			else if ((enemy3_hit == 1'b1) && (enemy3_DistX < Boss_Size_X) && (enemy3_DistY < Boss_Size_Y) && (boss_countdown == 2'b00) &&  (boss_running1_text[enemy3_DistY][enemy3_DistX] != 6'b0))
			colorValue = 6'he;
			//boss1 not shot
			else if ((enemy3_hit != 1'b1) && (enemy3_DistX < Boss_Size_X) && (enemy3_DistY < Boss_Size_Y) && (boss_countdown == 2'b00) &&  (boss_running1_text[enemy3_DistY][enemy3_DistX] != 6'b0))
			colorValue = boss_running1_text[enemy3_DistY][enemy3_DistX];
			//boss2 shot
			else if ((enemy3_hit == 1'b1) && (enemy3_DistX < Boss_Size_X) && (enemy3_DistY < Boss_Size_Y) && (boss_countdown == 2'b01) &&  (boss_running2_text[enemy3_DistY][enemy3_DistX] != 6'b0))
			colorValue = 6'he;
			//boss2 not shot
			else if ((enemy3_hit != 1'b1) && (enemy3_DistX < Boss_Size_X) && (enemy3_DistY < Boss_Size_Y) && (boss_countdown == 2'b01) &&  (boss_running2_text[enemy3_DistY][enemy3_DistX] != 6'b0))
			colorValue = boss_running2_text[enemy3_DistY][enemy3_DistX];
			//boss3 shot
			else if ((enemy3_hit == 1'b1) && (enemy3_DistX < Boss_Size_X) && (enemy3_DistY < Boss_Size_Y) && (boss_countdown >= 2'b10) &&  (boss_running3_text[enemy3_DistY][enemy3_DistX] != 6'b0))
			colorValue = 6'he;
			//boss3 not shot
			else if ((enemy3_hit != 1'b1) && (enemy3_DistX < Boss_Size_X) && (enemy3_DistY < Boss_Size_Y) && (boss_countdown >= 2'b10) &&  (boss_running3_text[enemy3_DistY][enemy3_DistX] != 6'b0))
			colorValue = boss_running3_text[enemy3_DistY][enemy3_DistX];
			//bullet
			else if (isbullet != 16'b0)
			colorValue = bullet_text[0];
			else if (isbullet_enemy != 16'b0)
			colorValue = bullet_text[0];
			else if (isbullet_enemyhigh != 16'b0)
			colorValue = rocket_text[0][0];
			else if (isbullet_tank != 16'b0)
			colorValue = rocket_text[0][0];
			else if (isbullet_boss != 16'b0)
			colorValue = bullet_text[0];
			
			else if ((DrawX < 10'd20) && (DrawY == 10'd20 || DrawY == 10'd21) && (health > DrawX))
			colorValue = 6'h2;
			else if (main_hit)
			colorValue = 6'he;
        /* The ball's (pixelated) circle is generated using the standard circle formula.  Note that while
           the single line is quite powerful descriptively, it causes the synthesis tool to use up three
           of the 12 available multipliers on the chip! */

    end

endmodule
