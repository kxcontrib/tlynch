//snake game using wasd keys

//on the controller process you can simply enter the key in the terminal and press enter
//.z.pi:{[x] show("wasd"!`up`left`down`right)x[0]}

//This sets the initial seed value for random generation 
//uses the current minute and second to guarantee randomness
//
value "\\S ",(string `mm$.z.t),string `ss$.z.t;

//size of square table
size:10;
tab:flip (`$'size#.Q.a)!size cut (size*size)#`;
//all coords
allcoords:`$(,/')string (cols tab) cross til size;
//tablookup:{[x] x:string x;first ?[`tab;enlist (=;`N;"I"$1_x);();c!c:enlist `$x[0]]};
upd:{[coord;sym] coord:string coord;sym:enlist sym;![`tab;enlist (=;`i;$[.z.K>=3f;"J";"I"]$1_coord);0b;(enlist `$coord[0])!enlist sym];};

//make basic snake to begin with
upd[`c7;`O];
upd[`d7;`O];
upd[`e7;`$"@"];

//this list wil always represent the snake
//just need to remove the tail and add new head to this list
snake:`e7`d7`c7;

//starting direction
direction:`right;

animate:{[]
	//what was the head is now body
	upd[first snake;`O];
	//find the new location for the head
	$[direction in `left`right;
		[newcolnum:(`left`right!-1 1)[direction] + (cols tab)?`$first string first snake;
		newcol:(cols tab) newcolnum mod size;
		newcoord:`$(string newcol),1_string first snake;
		coordcheck[newcoord]];
		[newrownum:(`up`down!-1 1)[direction] + "I"$1_string first snake;
		newrow:newrownum mod size;
		newcoord:`$(first string first snake),string newrow;
		coordcheck[newcoord]]];
	if[not game_over;show tab];
	};

//function to check the validity of the new snake head
coordcheck:{[coord]
	$[coord in snake;:gameover[];snake::coord,snake];
		$[coord=food;
			[food::first 1?allcoords except snake;
			upd[food;`X]];
			[upd[last snake;`]; //remove the tail of the snake
			snake::-1_snake;
			]];
		upd[coord;`$"@"]};	

	
//place the starting food
food:`e4;
upd[food;`X];

//game over funtion
game_over:0b;
gameover:{[] value"\\t 0";game_over::1b;show "Game Over!";show "Score: ",string (count snake)-2};
	
//function to start the game
//it sets the speed, sets the timer and sets the inputs as w,a,s,d
start:{[input]
	speed::$[not null input;input;500];
	//take directions from wasd
	.z.pi:{[x] if[x[0] in "wasd";value"\\t 0";direction::("wasd"!`up`left`down`right)x[0];value"\\t ",string speed]};
	.z.ts:{animate[]};
	value"\\t ",string speed};
	
	
//Introductions
value"\\c 1000 1000";
show "Welcome to snake!!";
show "Type start[500] to start the game at speed 500";
show "Reduce this number to start the game faster";
show "Specify the direction of the snake using w,a,s,d and enter button";
show "Resize the window so that only this table and the q below it are visable";
show tab;









