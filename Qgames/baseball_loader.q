// baseball loader

//frame importer

//read in all frames
a:read0`:baseball_frames.q;

//remove certain artefacts
a:{ssr[x;"\"";""]} each a;
a:{ssr[x;"+nl+";""]} each a;
a:{ssr[x;"jgs";"^^^"]} each a;
a:{ssr[x;"\\\\";"\\"]} each a;

//make them all 64 width
a:64$'a;

//chop into frames of height 8
a:8 cut a;

//uncomment these if you want to just run the animation
//frame:0;
//.z.ts:{show a[frame];frame::(frame+1) mod 20};
// \t 100

//idea for game is to split each frame into two parts:
//the left side (batter) and the right side (pitcher)
//each should work independently
//use fill (^) to merge the two sides at any given time

//set .z.pi so that just pressing the enter button causes the batter to swing

//get the batter half, then pad it out
batter:{13#'x} each a;
batter:{64$'x} each batter;

//get the pitcher half, then pad it out
pitcher:{13_'x} each a;
pitcher:{-64$'x} each pitcher;

//need modified versions of pitcher frames in the case where the batter misses
pitcher_miss:pitcher;

//make the modifications
pitcher_miss[10]:pitcher_miss[9];
pitcher_miss[10]:.[pitcher_miss[10];(6 54);:;"|"];
pitcher_miss[10]:.[pitcher_miss[10];(6 55);:;" "];
pitcher_miss[10]:.[pitcher_miss[10];(4 13);:;"."];
pitcher_miss[10]:.[pitcher_miss[10];(5 10);:;"o"];

pitcher_miss[11]:pitcher_miss[10];
pitcher_miss[11]:.[pitcher_miss[11];(5 10);:;"."];
pitcher_miss[11]:.[pitcher_miss[11];(6 8);:;"o"];


//{.[x;y;:;" "]}/[pitcher_miss[10];(3 15;2 18;1 21)]

//both start at frame zero but are independent
batter_frame:0;
pitcher_frame:0;

//miss indicator
missed:0b;

score:0;

//batter starts moving at frame 7 (index 6)
//batter ends motion at frame 18 (index 17)
//ball can only be hit on frame 10 (index 9)

.z.ts:{
	pitcher_frame::(pitcher_frame+1) mod 20;
	$[missed and pitcher_frame in 9 10 11;
	frame:batter[batter_frame]^pitcher_miss[pitcher_frame];
	$[(pitcher_frame=9) and not batter_frame=9;
		[missed::1b;frame:batter[batter_frame]^pitcher_miss[pitcher_frame]];
		[if[missed;pitcher_frame::17];if[(pitcher_frame=9) and batter_frame=9;score::score+1;speed::speed-2];missed::0b;frame:batter[batter_frame]^pitcher[pitcher_frame]]
		]
		];
	//tidy up the output
	frame:{ssr[x;"\\ ";"\\"]} each frame;
	frame:{ssr[x;"\\\\";"\\"]} each frame;
	//make the width uniform
	frame:(64-sum each frame="\\")$'frame;
	
	//add the score to the frame
	frame:(enlist ((neg count s)_first frame),s:"score: ",string score),1_frame;
	
	show frame;
	if[not batter_frame=0;batter_frame::(batter_frame+1) mod 18];
	};

//determine if batter is in the middle of a swing
mid_swing:{batter_frame in 6 7 8 9 10 11 12 13 14 15 16 17};
	
start:{[x]
	.z.pi:{
		if[not mid_swing[];
			value "\\t 0";
			batter_frame::6;
			value "\\t ",string speed;
			];
		};
	speed::$[null x;100;x];
	value "\\t ",string speed;
	};

//START MESSAGES

show "Welcome to the Baseball Game!";
show "Resize the screen so that only this frame and the q) below it are visable.";
show "Type start[] to start the game and press Enter to swing."
show a[0]