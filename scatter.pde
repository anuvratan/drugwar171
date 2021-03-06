Collect table;


//screen resolution
int width3 = 1440;
int height3 = 900;
int width2 = 700;
int height2 = 400;

float screen_width = width3*.5;
float screen_height = height3 *.5;

int background_color = 50;

float shifted = screen_height*.9;

int dot_size = 7;

//intialize
int var_year = 0;

float sum_T = 0;
float sum_H = 0;
float sum_E = 0;

float variance_T, variance_H, variance_E;

float average_T, average_H, average_E;

float average_T_interval, average_H_interval, average_E_interval;

float x_screen_interval, y_screen_interval;


float sd_T, sd_H, sd_E;

float multiplier_T, multiplier_H, multiplier_E;

float average_multiplier_T, average_multiplier_H, average_multiplier_E;

String [] names;

boolean hover = false;

int quadrant;


void setupA() {
  //size(int(screen_width)*2,int(screen_height)*2);
    background(background_color);
    table = new Collect("Anuv_Data.tsv");
    calculate();
    names = new String[table.numRows];
 
  noStroke();

}


void calculate() {

  for(int i=1; i<table.numRows; i++){
  sum_T = sum_T + table.getFloatAt(i,3+4*var_year);
  sum_H = sum_H + table.getFloatAt(i,4+4*var_year);
  sum_E = sum_E + table.getFloatAt(i,1+4*var_year);   
  }

  //average
  average_T = sum_T/(table.numRows-1);
  average_H = sum_H/(table.numRows-1);
  average_E = sum_E/(table.numRows-1);

  
  //calculate intervals from average for zooming
  average_T_interval = average_T/10;
  average_H_interval = average_H/10;
  average_E_interval = average_E/10;
  
  //standard dev
  for(int i=1; i<table.numRows; i++){
    variance_T = variance_T + sq(table.getFloatAt(i,3+4*var_year)-average_T);
    variance_H = variance_H + sq(table.getFloatAt(i,4+4*var_year)-average_H);
    variance_E = variance_E + sq(table.getFloatAt(i,1+4*var_year)-average_E);
  }

  sd_T = sqrt(variance_T/(table.numRows-1));
  sd_H = sqrt(variance_H/(table.numRows-1));
  sd_E = sqrt(variance_E/(table.numRows-1));
}


void drawA() {
  //background(200);

  draw_scatter();
  drawTitle(var_year+1990);
  hoverOverDot();
  /*
  | IMPORTANT:
  | the next two lines determine the dimensions of the plot area
  */
  int w = (int) (width2 * 0.9);
  int h = (int) (height2 * 0.7);
}

void draw_scatter(){
  
  //white background
  fill(250);
  noStroke();
  rect(screen_width*.1,screen_height*.05+shifted,screen_width*.9-90, screen_height*.85);
  resetFill();

  //data maximums
  //E=expenditure, T= total, H= homocides
  float max_E = 3.0E10;
  float max_T = 359.;
  float max_H = 3000;

  float interval_E = max_E/10;
  float interval_T = max_T/10;
  float interval_H = max_H/10;
  
  resetStroke();
  //x-axis
  line(screen_width*.1,screen_height*.9+shifted,screen_width*.9-10,screen_height*.9+shifted);

  resetFont();

  //label
  text("Cartel Expenditures (Pesos)", screen_width*.9, screen_height*.93+shifted);
  
  //x-axis tick marks and labels
 
  x_screen_interval = (screen_width*.85)/10;
  for(int i=3; i<11;i++) {
    line(screen_width*.1+x_screen_interval*(i-2), screen_height*.9-2+shifted, screen_width*.1+x_screen_interval*(i-2), screen_height*.9+2+shifted); 
    
    //vertical labels
    pushMatrix();
    translate(screen_width*.1+x_screen_interval*(i-2), screen_height*.9+12+shifted);
      text("10E"+(i-1),0,2);
    popMatrix();

}
  //y-axis
  line(screen_width*.1, screen_height*.05+shifted, screen_width*.1, screen_height*.9+shifted);

  //label
  pushMatrix();
  translate(screen_width*.03, screen_height*.5+shifted);
  rotate(3*PI/2);
  text("Homocides",0,0);
  popMatrix();
  
  
  //y-axis tick marks
  y_screen_interval = (screen_height*.85)/4;
  for(int i=1; i<5;i++) {  
    line(screen_width*.1-2, screen_height*.05+y_screen_interval*i+shifted, screen_width*.1+2, screen_height*.05+y_screen_interval*i+shifted); 
    text("10E"+(i-1), screen_width*.1-25, screen_height*.9-y_screen_interval*i+2+shifted);

  }
 
 
 
 
 
 
  multiplier_T = (screen_width*.85)/max_T;
  multiplier_H = (screen_height*.85)/max_H;
  multiplier_E = (screen_width*.85)/max_E;

  average_multiplier_T = (screen_width*.85)/average_T;
  average_multiplier_H = (screen_height*.85)/average_H;
  average_multiplier_E = (screen_width*.85)/average_E; 
  

  
  for(int i=1; i<table.numRows; i++){
    noStroke();

    //save municipality names in array
    names[i] = table.getDataAt(i,0);
  
 
    //color based on standard deviation of E from mean    
    //if(table.getFloatAt(i,3+4*var_year)> average_T + 4*sd_T)
    //  fill(250,0,0);
    //else if(table.getFloatAt(i,3+4*var_year)> average_T + 2*sd_T)
    //  fill(200,100,0);

    //draw dot
    fill(100,50); 
    ellipse(screen_width*.1+(log10(table.getFloatAt(i,1+4*var_year))-3)*x_screen_interval, screen_height*.9-log10(table.getFloatAt(i,4+4*var_year))*y_screen_interval+shifted,dot_size,dot_size);
   
   
    stroke(0);
  }
  
//TEST
fill(0,0,250);
ellipse(screen_width*.1+(log10(table.getFloatAt(457,1+4*var_year))-3)*x_screen_interval, screen_height*.9-log10(table.getFloatAt(457,4+4*var_year))*y_screen_interval+shifted,dot_size,dot_size);
   




}

void resetStroke() {
  strokeWeight(1);
  stroke(0);
}


void resetFill() {
 fill(250); 
}



void drawTitle (int t) {
  fill(0);
  textAlign(CENTER);
  textSize(15);
  fill(0);
  text(t, screen_width/2, screen_height*.03+shifted+25);
  resetFill();
}


void hoverOverDot() {
hover = false;
for(int i = 0; i<table.numRows-1; i++){
  if(distance(mouseX,mouseY,screen_width*.1+(log10(table.getFloatAt(i,1+4*var_year))-3)*x_screen_interval,screen_height*.9-log10(table.getFloatAt(i,4+4*var_year))*y_screen_interval+shifted)<5 && i != 0 && hover==false){
    hover = true;
    textSize(20);
    fill(100,100,250);
    text(names[i], 500, 60);
    resetFill();
    }
  

}
}







float distance(float x1,float y1,float x2,float y2){
  float d = sqrt(sq(x2-x1)+sq(y2-y1));
  return d;
}


float log10 (float x) {
  return (log(x) / log(10));
}

void keyPressed() {
  
    //reset
    sum_T = 0;
    sum_H = 0;
    sum_E = 0;
    variance_T = 0;
    variance_H = 0;
    variance_E = 0;
  
    if(key == CODED) {
      if (keyCode == RIGHT && var_year<20){ 
        var_year = var_year + 1;
           calculate();}
      else if (keyCode == LEFT && var_year>0){
         var_year = var_year -1;  
          calculate();}
    }

}



void resetFont() {
 textSize(10);
 textAlign(CENTER); 
}







