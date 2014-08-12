//bombs vs. zombies
//completed in one sitting in approx 4 hours

//A game based on plants vs zombies
//Aim of the game is to prevent zombies (represented by F's) from getting
//to the right of the screen. You must plant bombs in their paths to kill them.
//There is a limited amount of bombs that can be placed at any one time
//You can pick up bombs and re-plant them somewhere else if necessary
// X represents the player, F represents the zombies, O represents a bomb 
//and 0 (zero) represents the player on a bomb (it can be picked back up)

//This sets the initial seed value for random generation 
//uses the current minute and second to guarantee randomness
//
value "\\S ",(string `mm$.z.t),string `ss$.z.t;

//set up the table. Can customise the header provided each character is unique
header:"StopTheZOmbiEs";
size:count header;
tab:flip (`$'header)!n cut (size*n:`int$0.6*size)#`;

//tablookup:{[x] x:string x;first ?[`tab;enlist (=;`N;"I"$1_x);();c!c:enlist `$x[0]]};
upd:{[coord;sym] coord:string coord;sym:enlist sym;![`tab;enlist (=;`i;$[.z.K>=3f;"J";"I"]$1_coord);0b;(enlist `$coord[0])!enlist sym];};

maxbombs:4;
score:0;
finished:0b;

upd[`b4;`X];

//find all coordinates for a certain letter
find:{[sym;table] raze {[x] `$(string -1_x) cross enlist string last x} each l where 1<count each l:(where each sym=table),'til count table};

move:{[input]
	if[null input;:show tab];
	if[`bomb~input;:bomb[]];
	$[()~find[`X;tab];  //player could be on a bomb
		[replace_bomb:1b;current:string first find[`0;tab]];
		[replace_bomb:0b;current:string first find[`X;tab]]];
	change:(`up`down`left`right!(neg 1;1;neg 1;1))input;
	new:$[input in `up`down;
			current[0],string (-1+n) & 0 | change+"I"$1_current; //minimize at zero and maximize at n (boundaries)
			(header (-1+size) & 0 | change+header?current[0]),1_current];
	$[replace_bomb;upd[`$current;`O];upd[`$current;`]];
	$[(`$new) in find[`F;tab];
		[upd[`$new;`$"*"];:gameover[]]; //gameover if you hit a zombie
		(`$new) in find[`O;tab];
			[upd[`$new;`0];show tab]; //if you land on a bomb display a zero
			[upd[`$new;`X];show tab]];
	};

move_zombie:{[zombie]
	new:(header 1+header?first string zombie),1_string zombie;
	if[((last header)~first new) and not (`$new) in find[`O;tab];[upd[zombie;`];upd[`$new;`F];:gameover[]]]; //gameover if zombie reaches the end (and there's no bomb)
	upd[zombie;`];
	if[(`$new) in find[`X;tab] union find[`0;tab];[upd[`$new;`$"*"];:gameover[]]]; //gamover if zombie lands on player
	$[(`$new) in find[`O;tab];
		[upd[`$new;`$"*"];score::score+1;speed::speed-15;value"\\t ",string speed];
		upd[`$new;`F]]
	};
	
bomb:{[] 
	$[()~find[`X;tab]; //player must be on a bomb
		[current:first find[`0;tab];upd[current;`X];show tab]; //pick up the bomb
		$[(-1+maxbombs)<(count find[`0;tab])+count find[`O;tab];show tab;[current:first find[`X;tab];upd[current;`0];show tab]]] //otherwise plant a bomb (provided there are spare bombs)
	};
	
gameover:{[] show tab; 
			value"\\t 0"; //stop the timer
			value"\\x .z.pi"; //stop all inputs
			finished::1b;
			show "GAME OVER! Your score is: ",string score;show "Type reset[] to start again";
			};


animate:{[]
	//any asterix's on the screen should be removed
	upd[;`] each find[`$"*";tab];
	
	//find all zombies - starting with the right-most ones
	zombies:l idesc header?1#'string l:find[`F;tab];
	move_zombie each zombies;
	
	//generate new zombies
	//nums:$[(`int$())~d:distinct (first 1?n)?n;0;d]
	freq:first 1?(0;0;1;1;first 1?n); //adjust the fequency
	nums:distinct freq?n;  
	if[not (`int$())~nums;upd[;`F] each `$"S",'string nums];
	
	if[not finished;show tab]};


	
//move dictated by "a", "s" or "d" buttons
//bombs are planted by entering a space (i.e. spacebar)
//.z.pi:{[x] move[("wads "!`up`left`right`down`bomb)(lower x[0])]};
//.z.pi will get defined in the start function

start:{[input]
	speed::$[not null input;input;2000];
	//take directions from wasd
	.z.pi:{[x] move[("wads "!`up`left`right`down`bomb)(lower x[0])]};
	.z.ts:{animate[]};
	value"\\t ",string speed};
	
reset:{[]
	tab::flip (`$'header)!n cut (size*n:`int$0.6*size)#`;
	score::0;
	finished::0b;
	upd[`b4;`X];
	start[]};
	
//Intro messages

show "Welcome to Bombs vs Zombies!!";
show "Type start[] to start the game.";
show "Move the player (X) using w,a,s,d followed by the enter button.";
show "Plant or pick up a bomb by pressing spacebar followed by the enter button.";
show "You can plant a maximum of 4 bombs at any time.";
show "Resize the window so that only this table and the q below it are visable";
show tab;