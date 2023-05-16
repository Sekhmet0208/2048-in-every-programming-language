macro(SP=DocumentTools:-SetProperty, GP=DocumentTools:-GetProperty);
G := module()
	
	export reset,f,getname;
	local a:=Matrix(4):
	local buttonpress:="False";
	local score:=0;
	local highscoreM,highscore,hscore,hname,M,j,k,z,e,move,r,c,q,w,checklose,loss,matrixtotextarea;
	
	getname:=proc();	
		hname:=GP("Name",value);
		buttonpress:="True";
		if score>hscore then
			M:=Matrix(1, 2, [[score, hname]]):
			ExportMatrix("this:///Score.csv",M);
			reset();
		else
			reset();
		end if;
	end proc;

	matrixtotextarea:=proc(m)
		local m2,colors;
		colors:=["White","Beige","LightGrey",ColorTools:-Color("RGB", [255/255, 127/255,  80/255]),ColorTools:-Color("RGB", [255/255, 99/255,  71/255]),ColorTools:-Color("RGB", [255/255, 69/255,  0/255]),ColorTools:-Color("RGB", [255/255, 0/255,  0/255]),ColorTools:-Color("RGB", [255/255, 215/255,  0/255]), ColorTools:-Color("RGB", [255/255, 255/255,  0/255]),ColorTools:-Color("RGB", [204/255, 204/255,  0/255]),ColorTools:-Color("RGB", [153/255, 153/255,  0/255]),ColorTools:-Color("RGB", [102/255, 102/255,  0/255]), ColorTools:-Color("RGB", [0/255, 0/255,  0/255])]; 
		m2 := ArrayTools:-Reshape(m^%T, [16,1]):
		SP(seq([cat("TextArea",i),value,m2[i+1,1]],i=0..15));
		SP(seq(["Table1",fillcolor[(`if`(i+1<5,1,`if`(i+1<9 and i+1>4,2,`if`(i+1<13 and i+1>8,3, `if`(i+1<17 and i+1>12,4,1))))),(i mod 4)+1],`if`(m2[i+1,1]=0,colors[1],`if`(m2[i+1,1]=2,colors[2],`if`(m2[i+1,1]=4,colors[3],`if`(m2[i+1,1]=8,colors[4],`if`(m2[i+1,1]=16,colors[5],`if`(m2[i+1,1]=32,colors[6],`if`(m2[i+1,1]=64,colors[7],`if`(m2[i+1,1]=128,colors[8],`if`(m2[i+1,1]=256,colors[9],`if`(m2[i+1,1]=512,colors[10],`if`(m2[i+1,1]=1024,colors[11],`if`(m2[i+1,1]=2048,colors[12],`if`(m2[i+1,1]>2048,colors[13],"White")))))))))))))],i=0..15));
		SP(seq([cat("TextArea",i),fillcolor,`if`(m2[i+1,1]=0,colors[1],`if`(m2[i+1,1]=2,colors[2],`if`(m2[i+1,1]=4,colors[3],`if`(m2[i+1,1]=8,colors[4],`if`(m2[i+1,1]=16,colors[5],`if`(m2[i+1,1]=32,colors[6],`if`(m2[i+1,1]=64,colors[7],`if`(m2[i+1,1]=128,colors[8],`if`(m2[i+1,1]=256,colors[9],`if`(m2[i+1,1]=512,colors[10],`if`(m2[i+1,1]=1024,colors[11],`if`(m2[i+1,1]=2048,colors[12],`if`(m2[i+1,1]>2048,colors[13],"White")))))))))))))],i=0..15),refresh);
		SP(seq([cat("TextArea",i),fontcolor,`if`(m2[i+1,1]=0,colors[1],`if`(m2[i+1,1]=2,colors[13],`if`(m2[i+1,1]=4,colors[13],"White")))],i=0..15),refresh);
	end proc:
	
	reset:=proc();
		highscoreM := Import("this:///Score.csv", output = Matrix);
		hscore := highscoreM[1,1];
		hname := highscoreM[1,2];
		highscore:=sprintf("%s",cat(hscore,"\n",hname));
		buttonpress:="False";
		a:=Matrix(4, 4, [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]]):
		score:=0;
		matrixtotextarea(a);
		SP("Score/Lose",visible,true);
		SP("Score/Lose",enabled,true);
		SP("Score/Lose",caption,"Click an Arrow to begin.");
		SP("Score",value,score);
		SP("Highscore",value,highscore);
		SP(seq([j, enabled, false], j in ["Name","Enter"])); 
		SP(seq([j, visible, false], j in ["Name","Enter"])); 
		SP(seq([j, enabled, true], j in ["Score","Highscore", seq(cat("Button",k),k=0..4)]));	
		SP(seq([j, visible, true], j in ["Score","Highscore", seq(cat("Button",k),k=0..4)]));
	end proc;

	checklose:=proc();
		for q from 2 to 4 do
			for w from 4 to 1 by -1  do
				if a[q,w]=a[q-1,w] then
					loss:="False";
					return loss;														
				end if;
			end do;
		end do;
		return loss;
	end proc;		

	f:=proc(keypress);
		SP("Score/Lose",visible,false);
		SP("Score/Lose",enabled,false);
		j := rand(1 .. 4); 
		k := rand(1 .. 4); 
		z := rand(1 .. 10); 
		e := 0; 
		move:=proc();	
			for q from 4 to 2 by -1 do
				for w from 4 to 1 by -1  do
					if a[q,w]=a[q-1,w] then
						a[q-1,w]:=a[q-1,w]+a[q,w];
						score:=score+a[q-1,w];
						a[q,w]:=0;
						if q-1>1 and a[q-2,w]=0 then
							a[q-2,w]:=a[q-1,w];
							a[q-1,w]:=0;
							if q-2>1 and a[q-3,w]=0 then
								a[q-3,w]:=a[q-2,w];
								a[q-2,w]:=0;
							end if;
						end if;					
					elif q-1>1 and a[q,w]=a[q-2,w] and a[q-1,w]=0 then
						a[q-2,w]:=a[q-2,w]+a[q,w];
						score:=score+a[q-2,w];
						a[q,w]:=0;
						if q-2>1 and a[q-3,w]=0 then
							a[q-3,w]:=a[q-2,w];
							a[q-2,w]:=0;
						end if;					
					elif q-2>1 and a[q,w]=a[q-3,w] and a[q-1,w]=0 and a[q-2,w]=0 then
						a[q-3,w]:=a[q-3,w]+a[q,w];
						score:=score+a[q-3,w];
						a[q,w]:=0;	
					elif a[q-1,w]=0 then
						a[q-1,w]:=a[q-1,w]+a[q,w];
						a[q,w]:=0;
						if q-1>1 and a[q-2,w]=0 then
							a[q-2,w]:=a[q-1,w];
							a[q-1,w]:=0;
							if q-2>1 and a[q-3,w]=0 then
								a[q-3,w]:=a[q-2,w];
								a[q-2,w]:=0;
							end if;
						end if;					
					elif q-1>1 and a[q-2,w]=0 and a[q-1,w]=0 then
						a[q-2,w]:=a[q-2,w]+a[q,w];
						a[q,w]:=0;
						if q-2>1 and a[q-3,w]=0 then
							a[q-3,w]:=a[q-2,w];
							a[q-2,w]:=0;
						end if;					
					elif q-2>1 and a[q-3,w]=0 and a[q-1,w]=0 and a[q-2,w]=0 then
						a[q-3,w]:=a[q-3,w]+a[q,w];
						a[q,w]:=0;
					end if;
				end do;
			end do;		
		end proc;
	
 		r := j(); 
          c := k();  
		if keypress="Up" then
			move();					
		
		elif keypress="Left" then
			a:=LinearAlgebra:-Transpose(a);
			move();
			a:=LinearAlgebra:-Transpose(a);
		
		elif keypress="Right" then
			a := ArrayTools:-FlipDimension(LinearAlgebra:-Transpose(a),1);
			move();
			a := LinearAlgebra:-Transpose(ArrayTools:-FlipDimension(a,1));
			
		elif keypress="Down" then
			a := ArrayTools:-FlipDimension(a, 1);
			move();
			a := ArrayTools:-FlipDimension(a, 1);		
		end if;
        
		if a[r, c] = 0 then 
			if z() > 3 then 
				a[r, c] := 2; 
			else; 
				a[r, c] := 4; 
			end if; 
		else
			for q to 4 do 
				for w to 4 do 
					if a[q, w] <> 0 then;
						e:=e+1; 
					end if; 
				end do; 
			end do; 
			if e = 16 then
				loss:="True";
				checklose();					
				a:=LinearAlgebra:-Transpose(a);
				checklose();
				a:=LinearAlgebra:-Transpose(a);
				a := ArrayTools:-FlipDimension(LinearAlgebra:-Transpose(a),1);
				checklose();
				a := LinearAlgebra:-Transpose(ArrayTools:-FlipDimension(a,1));			
				a := ArrayTools:-FlipDimension(a, 1);
				checklose();
				a := ArrayTools:-FlipDimension(a, 1);
				if loss="True" then		 
					SP("Score/Lose",visible,"True");
					SP("Score/Lose",enabled,"True");
					SP("Score/Lose",caption,"You Lose!");
					if score>hscore then
						SP("Score/Lose",caption,"Highscore! Enter your name below!");
						SP("Enter",caption,"Confirm");
						SP(seq([j, enabled, true], j in ["Name","Enter","Score/Lose"])); 
						SP(seq([j, visible, true], j in ["Name","Enter","Score/Lose"])); 
						SP(seq([j, enabled, false], j in [seq(cat("Button",k),k=0..4)]));
						SP(seq([j, visible, false], j in [seq(cat("Button",k),k=0..4)]));
						if buttonpress="True" then
							M:=Matrix(1, 2, [[score, hname]]):
							ExportMatrix("this:///Score.csv",M);
							buttonpress:="False";
							reset();
						end if;
					else
						SP("Score/Lose",caption,"Sorry, please try again.");
						SP("Enter",caption,"Restart");
						SP("Enter",visible,"True");
						SP("Enter",enabled,"True");
						SP(seq([j, enabled, false], j in [seq(cat("Button",k),k=0..4)]));
						SP(seq([j, visible, false], j in [seq(cat("Button",k),k=0..4)]));			
						if buttonpress="True" then
							buttonpress:="False";
							reset();
						end if;
					end if;
				end if;	
			else 
                  e:=0;
                  while a[r, c] <> 0 do 
                      r := j(); 
                      c := k(); 
                  end do; 
                  if z() > 1 then 
                      a[r, c] := 2; 
                  else 
                      a[r, c] := 4; 
                  end if; 
			end if; 
		end if;  
		matrixtotextarea(a); 
          SP("Score",value,score,refresh);    
          return a;  
	end proc;
end module;
G:-reset();SP("Score/Lose",caption,"Click an Arrow to begin.");
