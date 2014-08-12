//Tetris - Terry Lynch

//This sets the initial seed value for random generation 
//uses the current minute and second to guarantee randomness
//
value "\\S ",(string `mm$.z.t),string `ss$.z.t;
//
score:0;
gameover:0b;
size:10;
header:`T`e`t`r`i`s`g`a`m`E;
tab:flip header!b cut (size*b:floor 2*size)#`;

upd:{[coord;sym] 
	coord:string coord;
	sym:enlist sym;
	![`tab;enlist (=;`i;$[.z.K>=3f;"J";"I"]$1_coord);0b;(enlist `$coord[0])!enlist sym]};
	
//
//function to reset the game
reset:{[]
	value"\\t 0";
	.z.pi:{value x};
	tab::flip header!b cut (size*b:floor 2*size)#`;
	score::0;
	gameover::1b;};
//
//game is over if new shape clashes with the build-up
gameover_check:{[shape]
	$[0<count shape inter find[`X;tab];
		[upd[;`O] each shape;show tab;show "GAME OVER!";show "Score: ",string score;reset[]];
		upd[;`O] each shape];};
// the shapes
//square
shape1:{current::1;
	coords:`i0`s0`i1`s1;
	gameover_check[coords]};
//L 
shape2:{current::2;
	coords:`i1`s1`g1`g2;
	gameover_check[coords]};
//reverse L
shape3:{current::3;
	coords:`r1`i1`s1`r2;
	gameover_check[coords]};
//S
shape4:{current::4;
	coords:`r2`i2`i1`s1;
	gameover_check[coords]};
//reverse S
shape5:{current::5;
	coords:`r1`i1`i2`s2;
	gameover_check[coords]};
//straight
shape6:{current::6;
	coords:`r2`i2`s2`g2;
	gameover_check[coords]};
// T shape
shape7:{current::7;
	coords:`i1`r2`i2`s2;
	gameover_check[coords]};
//shape frequency
//the more there are of any number, the more likely they are to show up
//the straight shape should be less likely
frequency:1 1 1 2 2 2 2 3 3 3 3 4 4 4 5 5 5 6 6 7 7;
//find all coordinates for either `O or `X
find:{[sym;table] raze {[x] `$(string -1_x) cross enlist string last x} each l where 1<count each l:(where each sym=table),'til count table};
//
// function to find coords of next drop down
one_down:{[] `$t[;0],'string 1+"I"$1_'t:string find[`O;tab]};
//function to drop all `O by one
drop:{[]
	//if we hit the bottom (coord is greater than the count of the table) set it in
	if[any b<="I"$1_'string one_down[];:set_in[]];
	//if the shape hits an obstruction, set it in
	if[count one_down[] inter find[`X;tab];:set_in[]];
	old:find[`O;tab];
	new:one_down[];
	upd[;`] each old;
	upd[;`O] each new;show tab};
//
//logic to apply when we hit the bottom or an obstruction
set_in:{[]
	upd[;`X] each find[`O;tab];
	//look for lines and remove them
	find_lines[];
	//make a new random shape
	value "shape",(string first 1?frequency),"[]";
	$[gameover;gameover::0b;show tab]};
//
//function to find completed lines
find_lines:{
	full_rows:where all each `X=tab;
	if[count full_rows;
		[tab::flip ((count full_rows)#`),/:flip tab (til count tab) except full_rows;
		score::score + count full_rows;
		gamespeed::gamespeed - (count full_rows)*10;
		value"\\t ",string gamespeed;]]};
//
//move left or right
move:{[direction]
	if[null direction;:show tab];
	if[`rotate~direction;:value "rotate",(string current),"[]"];
	if[`down~direction;:drop[]];
	old:find[`O;tab];
	$[direction~`left;
		[if[any 0>n:-1+header?`$'first'[string old];:show tab];	//can't move left if we're at the very left edge
		new_coords:`$(string header n),'1_'string old;	//everything shifted to the left by one
		//need to put collision detection here before the new upd
		if[count new_coords inter find[`X;tab];:show tab];
		upd[;`] each old;
		upd[;`O] each new_coords;
		show tab];
		[if[any 9<n:1+header?`$'first'[string old];:show tab]; 	//can't move right if we're at the very right edge
		new_coords:`$(string header n),'1_'string old;	//everything shifted to the right by one
		//need to put collision detection here before the new upd
		if[count new_coords inter find[`X;tab];:show tab];
		upd[;`] each old;
		upd[;`O] each new_coords;
		show tab]];
	};
//
//move dictated by "a", "s" or "d" buttons
//rotations are performed by entering a space (i.e. spacebar)
//.z.pi:{[x] move[("ads "!`left`right`down`rotate)x[0]]};
//.z.pi will get defined in the start function
//
//rotations of shapes
//
//shape1 (no rotation for square)
rotate1:{[] show tab};
//
//shape2
// need to determine current orientation
shape2_down:{[] 
	//pointing down means 1 repeated letter containing max num
	one_repeated_letter:3=count distinct 1#'string find[`O;tab];
	if[one_repeated_letter;contains_max_num:(first where 1<count each group "I"$1_'string find[`O;tab])<max "I"$1_'string find[`O;tab] where first each t=first first where 2=count each group t:1#'string find[`O;tab]];
	$[one_repeated_letter;one_repeated_letter and contains_max_num;one_repeated_letter]};
//
shape2_up:{[] 
	//pointing up means 1 repeated letter containing min num
	one_repeated_letter:3=count distinct 1#'string find[`O;tab];
	if[one_repeated_letter;contains_min_num:(first where 1<count each group "I"$1_'string find[`O;tab])>min "I"$1_'string find[`O;tab] where first each t=first first where 2=count each group t:1#'string find[`O;tab]];
	$[one_repeated_letter;one_repeated_letter and contains_min_num;one_repeated_letter]};
//
shape2_left:{[]
	//pointing left means 3 repeated letter containing min column index
	repeated_letter:2=count distinct 1#'string find[`O;tab];
	if[repeated_letter;contains_min_index:first ((string header)?t except s) <(string header)?s:where 3=count each group t:1#'string find[`O;tab]];
	$[repeated_letter;repeated_letter and contains_min_index;repeated_letter]};
//
shape2_right:{[]
	//pointing right means 3 repeated letter containing max column index
	repeated_letter:2=count distinct 1#'string find[`O;tab];
	if[repeated_letter;contains_max_index:first ((string header)?t except s) >(string header)?s:where 3=count each group t:1#'string find[`O;tab]];
	$[repeated_letter;repeated_letter and contains_max_index;repeated_letter]};
//	
//create the rotators based on the orientation
shape2_down_rotate:{[] 
	columns:`$distinct 1#'string find[`O;tab];
	//create a mini-tab and rotate it 90 degrees
	mini_tab:flip columns!reverse ((-1+first n)#`),/:(enlist ```),(flip tab[columns]) n:"I"$distinct 1_'string find[`O;tab];
	find[`O;mini_tab]};
//
shape2_left_rotate:{[] 
	columns:header o,1+last o:asc header?`$distinct 1#'string find[`O;tab];
	//can't rotate in some circumstances
	if[any null columns;:`];
	mini_tab:flip columns!reverse ((first n)#`),/:(flip tab[columns]) n:"I"$distinct 1_'string find[`O;tab];
	find[`O;mini_tab]};
//
shape2_up_rotate:{[]
	columns:`$distinct 1#'string find[`O;tab];
	//put them in the order they appear
	columns:l asc (l:cols tab)?columns;
	mini_tab:flip columns!reverse ((first n)#`),/:((flip tab[columns]) n:"I"$distinct 1_'string find[`O;tab]),(enlist ```);
	//can't flip at the very bottom
	$[(count mini_tab)>count tab;`;find[`O;mini_tab]]};
//
shape2_right_rotate:{[] 
	columns:header (-1+first o),o:asc header?`$distinct 1#'string find[`O;tab];
	//can't rotate in some circumstances
	if[any null columns;:`];
	mini_tab:flip columns!reverse ((first n)#`),/:(flip tab[columns]) n:"I"$distinct 1_'string find[`O;tab];
	find[`O;mini_tab]};
//
//function to rotate shape 2
rotate2:{[]
	func_to_run:(`shape2_up_rotate;`shape2_down_rotate;`shape2_left_rotate;`shape2_right_rotate) where (shape2_up[];shape2_down[];shape2_left[];shape2_right[]);
	//if rotation is not possible, just show table
	if[any null new_coords:(first func_to_run)[];:show tab];
	//collision detection
	if[count new_coords inter find[`X;tab];:show tab];
	upd[;`] each find[`O;tab];
	upd[;`O] each new_coords;show tab};
//
//shape3
//rotating shape 3 is the same as shape 2!
rotate3:rotate2;
//
//shape4
rotate4:{[]
	columns:`$distinct 1#'string find[`O;tab];
	//if its vertical take an additional column
	if[2=count columns;columns:header (-1+l[0]),l:header?columns];
	if[any null columns;:show tab];
	//put them in the reverse order they appear
	columns:l desc (l:cols tab)?columns;
	nums:"I"$distinct 1_'string find[`O;tab];
	$[2 = count nums;[nums:(-1+nums[0]),nums;mini_tab:flip columns!reverse (nums[0]#`),/:(flip tab[columns]) nums];mini_tab:flip columns!reverse (nums[0]#`),/:(flip 2 rotate tab[columns]) nums];
	new_coords:find[`O;mini_tab];
	if[count new_coords inter find[`X;tab];:show tab];
	upd[;`] each find[`O;tab];
	upd[;`O] each new_coords;show tab};
//
//shape5
rotate5:{[]
	columns:`$distinct 1#'string find[`O;tab];
	//if its vertical take an additional column
	if[2=count columns;columns:header (1+l[0]),l:header?columns];
	if[any null columns;:show tab];
	//put them in the order they appear
	columns:l asc (l:cols tab)?columns;
	nums:"I"$distinct 1_'string find[`O;tab];
	$[2 = count nums;[nums:(-1+nums[0]),nums;mini_tab:flip columns!reverse (nums[0]#`),/:(flip tab[columns]) nums];mini_tab:flip columns!reverse (nums[0]#`),/:(flip 2 rotate tab[columns]) nums];
	new_coords:find[`O;mini_tab];
	if[count new_coords inter find[`X;tab];:show tab];
	upd[;`] each find[`O;tab];
	upd[;`O] each new_coords;show tab};	
//
//shape6
rotate6:{[]
	columns:`$distinct 1#'string find[`O;tab];
	nums:"I"$distinct 1_'string find[`O;tab];
	$[1<count columns;	//if its horizontal
		[new_nums:-4#(til l),l:first nums+1;
		//can't flip at the bottom
		if[(last new_nums)=count tab;:show tab];
		new_coords:`$(string columns[1]),/:string new_nums;
		if[count new_coords inter find[`X;tab];:show tab];
		upd[;`] each find[`O;tab];
		upd[;`O] each new_coords;show tab];
		[new_nums:nums[2];
		new_cols:raze header (-1+l),l,(l:header?columns)+/:1 2;
		if[any null new_cols;:show tab];
		new_coords:`$(string new_cols),\:string new_nums;
		if[count new_coords inter find[`X;tab];:show tab];
		upd[;`] each find[`O;tab];
		upd[;`O] each new_coords;show tab]]};
//
//shape7
rotate7:{[]
	columns:`$distinct 1#'string find[`O;tab];
	//put them in the order they appear
	columns:l asc (l:cols tab)?columns;
	nums:"I"$distinct 1_'string find[`O;tab];
	$[2<count columns;
		rotate7_horizontal[];
		rotate7_vertical[]]};
//
rotate7_horizontal:{[]
	repeated_letter:first first where 1<count each group 1#'string find[`O;tab];
	repeats:f where (f:find[`O;tab]) like repeated_letter,"*";
	pointing_up:(min "I"$1_'string repeats)<first where 1<count each group "I"$1_'string find[`O;tab];
		$[pointing_up; 
			[col:first 1#string (find[`O;tab])[1];
			row:1_string (find[`O;tab])[1];
			new_coord:`$(string header 1+header?`$col),string 1+"I"$row;
			new_coords:new_coord,find[`O;tab] 0 2 3;
			if[count new_coords inter find[`X;tab];:show tab];
			//can't rotate at the bottom
			if[(count tab)=1+"I"$row;:show tab];
			upd[;`] each find[`O;tab];
			upd[;`O] each new_coords;show tab];
			//else
			[col:first 1#string (find[`O;tab])[2];
			row:1_string (find[`O;tab])[2];
			new_coord:`$(string header -1+header?`$col),string -1+"I"$row;
			new_coords:new_coord,find[`O;tab] 0 1 3;
			if[count new_coords inter find[`X;tab];:show tab];
			upd[;`] each find[`O;tab];
			upd[;`O] each new_coords;show tab]
		]
	};
//
rotate7_vertical:{[]
	repeated_num:first first where 1<count each group 1_'string find[`O;tab];
	repeats:f where (f:find[`O;tab]) like "*",repeated_num;
	pointing_right:(max header?`$1#'string repeats)>header?first `$where 1<count each group 1#'string find[`O;tab];
		$[pointing_right;
			[col:first 1#string (find[`O;tab])[0];
			row:1_string (find[`O;tab])[0];
			if[null new_col:header -1+header?`$col;:show tab];
			new_coord:`$(string new_col),string 1+"I"$row;
			new_coords:new_coord,find[`O;tab] 1 2 3;
			if[count new_coords inter find[`X;tab];:show tab];
			upd[;`] each find[`O;tab];
			upd[;`O] each new_coords;show tab];
			//else
			[col:first 1#string (find[`O;tab])[3];
			row:1_string (find[`O;tab])[3];
			if[null new_col:header 1+header?`$col;:show tab];
			new_coord:`$(string new_col),string -1+"I"$row;
			new_coords:new_coord,find[`O;tab] 0 1 2;
			if[count new_coords inter find[`X;tab];:show tab];
			upd[;`] each find[`O;tab];
			upd[;`O] each new_coords;show tab]
		]
	};
//
//funtion to start the game
start:{[speed] 
	//play audio track (might need to make this loop/repeat)
	if[count .z.x;
		$["m"~first string .z.o;@[system;"afplay ",(first .z.x)," &";()];
		@[system;"start /min ",first .z.x;()]]];
	//system"start /min C:\\q\\tetris-gameboy-02.mp3";
	//set the inputs through .z.pi
	.z.pi:{[x] move[("ads "!`left`right`down`rotate)(lower x[0])]};
	//pick a random shape
	value "shape",(string first 1?frequency),"[]";
	//set the timer
	gamespeed::speed;
	value"\\t ",string gamespeed;};
//
//function which runs on the timer
.z.ts:{drop[]};
//
//Introduction Screen
show "Welcome to Tetris!";
show "To move left, press a then enter.";
show "To move right, press d then enter.";
show "To move down, press s then enter.";
show "To rotate, press spacebar then enter.";
show "To begin the game, run start[500] for example.";
show "The number represents the speed. Make it lower to start faster.";
show "To view the animation correctly, resize the terminal window";
show "so that only this table and the q) below it are visable.";
show tab;