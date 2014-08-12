// MINESWEEPER GAME
//
// load the game using q minesweeperloader.q width
// where width is a number from 2 to 26
//
//This sets the initial seed value for random generation 
//uses the current minute and second to guarantee randomness
//
value "\\S ",(string `mm$.z.t),string `ss$.z.t;
//
// widen the console view
//
value"\\c 1000 1000";
//
// Take command line parameters (or default to 9)
//
params:$[()~.z.x;"9";.z.x];
if[bool1:(2>w) or 26<w:$[.z.K>=3f;"J";"I"]$first params;
	show "Game supports widths from 2 to 26.";
	show "Game has defaulted to width 9 with 10 mines.";
	show "You must quit q and re-run the script to change width."];
//
// create a reset function
//
reset:{[x] value"\\l minesweeperloader.q"};
//
//the width of the board. Is configurable from the command line
//
size:$[bool1;9;$[`size in `.;size;$[.z.K>=3f;"J";"I"]$first params]];
//
//make the number of mines equal 17% (except for the default 9 10)
//
mines:$[9=size;10;2=size;1;floor 0.17*size*size];
//
//keep track of users attempts
//
attempts:`;
valid:{[x] all x in til size};
//
//create the initial table
//
tab:1!flip (`N,`$'.Q.a til size)!(enlist 1+til size),size cut (size*size)#`;
//
//add in the mines
//
wheremines:(mines?.Q.a til size),'mines?1+til size;
//there might be duplicates so add additional (randomly generate 100 and add new ones)
if[0<u:(count wheremines)-count distinct wheremines;[extrawheremines:(100?.Q.a til size),'100?1+til size;wheremines:wheremines,u#extrawheremines except wheremines]];
{[x] value "update ",x[0],":`O from `tab where N=",string x[1]} each wheremines;
//
//create a duplicate table to handle the numbers
//
numtab:tab;
numbers:{[t]
	data:flip value flip value t;
	{[c;data] 
	num:count where `O={[d;x] d[x[0]][x[1]]}[data] each c +/:1_n cross n:0 -1 1;
	col:.Q.a c[1];row:1+c[0];
	if[not 0=num;![`numtab;enlist (=;`N;row);0b;(enlist `$col)!enlist ($;enlist `;($:;num))]]
	}[;data] each p cross p:til size
	};
numbers[numtab];
minetab:tab;
//
//merge the tables
//
tab:$[.z.K>=3f;numtab^tab;numtab uj tab];
//
//create the table that the viewer will see
//
viewtab:1!flip (`N,`$'.Q.a til size)!(enlist 1+til size),size cut (size*size)#`X;
//
//create a function to expose the open areas
//
exposearea:{[i]
	c:enlist (-1+$[.z.K>=3f;"J";"I"]$1_string first i;.Q.a?(string first i)[0]);
	neighbours::c;
	boundary::();
	data::flip value flip value tab;
	{[l] coord:first l;
		f:k where null {[x] data[x[0]][x[1]]} each k:j where valid'[j:coord +/:b,flip reverse flip b:0 cross 1 -1];
		boundary::distinct boundary,k where not null {[x] data[x[0]][x[1]]} each k;
		output:1_distinct l,f except f inter neighbours;
		neighbours::distinct neighbours,f;
		$[0=count output;l;output]}/[c];
	{[x] value "update ",(.Q.a x[1]),":` from `viewtab where N=",string 1+x[0]} each neighbours;
	{[x] ![`viewtab;enlist (=;`N;x[0]);0b;(enlist `$.Q.a x[1])!enlist ($;enlist `;($:;x[2]))]} each ((1 0)+/:boundary),'{[x] $[.z.K>=3f;"J";"I"]$string data[x[0]][x[1]]} each boundary;
	viewtab
	};
//
//create the function to reveal the table
//
reveal:{[input] 
	row:1_string input;
	col:first string input;
	if[not row in string 1+til size;:show "Coordinate not valid! Try another"];
	if[not col in .Q.a til size;:show "Coordinate not valid! Try another"];
	$[input in attempts;:show "You have already entered that coordinate! Try another";attempts::attempts,input];
	if[input in `$raze each string wheremines;[show $[.z.K>=3f;numtab^tab;numtab uj tab];show "GAME OVER!";show "Type reset[] to reset the game with same width.";:show "You must quit q and re-run the script to change width."]];
	if[not null v:tab[$[.z.K>=3f;"J";"I"]$row][`$col];[row:$[.z.K>=3f;"J";"I"]$row;v:$[.z.K>=3f;"J";"I"]$string v;![`viewtab;enlist (=;`N;row);0b;(enlist `$col)!enlist ($;enlist `;($:;v))];$[gamewon[];[show $[.z.K>=3f;numtab^tab;numtab uj tab];show "YOU WIN!!";show "Type reset[] to reset the game with same width.";:show "You must quit q and re-run the script to change width."];:show viewtab]]];
	//otherwise it must be a blank area
	exposearea[input]
	};
//
// win function - Game is won when count of X's + count of F's = number of mines
gamewon:{[] mines=(sum sum each `X=value flip value viewtab) + sum sum each `F=value flip value viewtab}
//
// Flag function
flag:{[input] row:1_string input;col:first string input;$[`X~viewtab[$[.z.K>=3f;"J";"I"]$row][`$col];value "update ",col,":`F from `viewtab where N=",row;`F~viewtab[$[.z.K>=3f;"J";"I"]$row][`$col];value "update ",col,":`X from `viewtab where N=",row;:show "Cannot flag this coordinate."];show viewtab};
//
//Startup activity
//
show "Welcome to Minesweeper!";
show viewtab;
show "Reveal a coordinate using reveal[`f4] for example.";
show "You can flag or unflag a mine using flag[`e12] for example.";