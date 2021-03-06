import processing.opengl.*;
import geomerative.*;
 
//TODO: cart2010 functionality
//TODO: use population data!
RShape mapImage;
RShape[] munis;
Table homicideTable;
Table cartelTable;
int mapHeight = height;
int mapWidth = width;
int municCount;
int[] colorScheme = {50, 153, 0, 255};
//int[] colorScheme = { 255, 255, 0, 50};
String[] municClave;
char[] municCartel;
float[] municHom;
float[] municGrey;
float xx = 280;
float yy = 0;
float pan = -40;
float zoom = 1.5;
int buttonX = joeyWidth - 80;
int buttonY = barHeight + 60;
int buttonS = 40;
int legendS = 80;
RectButton left, right, up, down, in, out;
boolean locked = false;
color highlightJ = color(0,100,255);
color[][] seriesColsJ={
  {#9400D3, #DA70D6,#A9A9A9},
  {#FF4500, #FFA500,#A9A9A9},
  {#4169E1, #87CEFA,#A9A9A9},
  {#C71585, #FF69B4,#A9A9A9},
  {#B22222, #FA8080,#A9A9A9},
  {#008000, #32CD32,#A9A9A9},
  {#FFB700, #FFEA00 ,#A9A9A9},
  {#708090, #D3D3D3,#A9A9A9},
  {#66CDAA, #AFEEEE,#708090}
};

String[][] cartelsJ = {
  {"Gulf Cartel", "G"},
  {"Los Zetas Cartel", "Z"},
  {"Pacifico Sur Cartel", "P"},
  {"La Familia Michoacana", "F"},
  {"Cartel de Juárez", "J"},
  {"Sinaloa Cartel","S"},
  {"Not Specified", "N"},
  {"In Dispute", "D"},
  {"Pacifico Sur and Sinaloa Cartels","s"},
  {"Acapulco and Pacifico Sur Cartels","a"},
  {"Gulf and Los Zetas Cartels","z"},
};


void setupJ() {

  //setup
  g.smooth = true;

  //initialize the geomerative library
  RG.init(this);
  RG.ignoreStyles(true);
  RG.setPolygonizer(RG.ADAPTATIVE);

  //setup map
  mapImage = RG.loadShape("muni_ink.svg");
  mapImage.centerIn(g, 0, 1, 1);

  //build homicideTable and cartelTable
  cartelTable = new Table("CartelIncomeExpensesByMunicipality.tsv");
  homicideTable = new Table("data/MunHomicides.tsv");
  municCount = homicideTable.getRowCount() - 1;
  municCartel = new char[municCount];
  municClave = new String[municCount];
  municHom = new float[municCount];
  municGrey = new float[municCount];
  munis = new RShape[municCount];

  for(int c = 0; c < municCount; c++){
    municClave[c] = "muni_" + homicideTable.getString(c+1,0);
    municHom[c] = homicideTable.getFloat(c+1,66)/homicideTable.getFloat(c+1,65);
    municCartel[c] = cartelTable.getString(c+1,6).charAt(0);
    munis[c] = mapImage.getChild(municClave[c]);
  }

  //create greyscale vector for heatmap
  for(int c = 0; c < municCount; c++)
    municGrey[c] = map(municHom[c], min(municHom), max(municHom),0,255);
  
  //setup buttons
  ellipseMode(CENTER);
  left = new RectButton(buttonX-buttonS,buttonY, 12, color(colorScheme[3],0), color(colorScheme[3],0));
  right = new RectButton(buttonX+buttonS,buttonY, 12, color(colorScheme[3],0), color(colorScheme[3],0));
  up = new RectButton(buttonX,buttonY-buttonS, 12, color(colorScheme[3],0), color(colorScheme[3],0));
  down = new RectButton(buttonX,buttonY+buttonS, 12, color(colorScheme[3],0), color(colorScheme[3],0));
  in = new RectButton(buttonX,buttonY-buttonS/4, 12, color(colorScheme[3],0), color(colorScheme[3],0));
  out = new RectButton(buttonX,buttonY+buttonS/4, 12, color(colorScheme[3],0), color(colorScheme[3],0));

  //zoomout once
  zoomit(1/zoom);
}

void drawJ() {

  //update graph
  update();

//draw map
  smooth();
  strokeWeight(0.1);
  

  RPoint p = new RPoint(mouseX-width/2 + xx, mouseY-height/2 + yy);
  translate(mapWidth/2-xx, mapHeight/2-yy);
  for(int i = 0; i < municCount; i++){
    RShape munic = munis[i];
    if(munic != null){
      if(munic.contains(p) & mouseX< joeyWidth & mouseY > barHeight){
        selectedMuni = i;
        hoverMuni = true;
      }else{
        fill(255);
        munic.draw();
        int[] cartcol  = cartelColor(municCartel[i]);
        //TODO not sure about mix thing
        fill(seriesColsJ[cartcol[0]][0],municGrey[i]);
        
        stroke(colorScheme[2]);
        munic.draw();
      }
   
      if(hoverMuni & i==selectedMuni){
        fill(highlightJ);
        munic.draw();
      }

    }
  }

  //draw buttons
  //translate(xx, -joeyHeight/1.3+yy);
  translate(-mapWidth/2+xx, -mapHeight/2+yy);
  left.display();
  right.display();
  up.display();
  down.display();
  in.display();
  out.display();

  //text in buttons
  textAlign(LEFT,TOP);
  //textSize(14);
  //stroke(1);
  fill(255);
  textSize(14);
  text("<",buttonX-buttonS,buttonY);
  text("+",buttonX,buttonY-buttonS/4);
  text("-",buttonX+1,buttonY+buttonS/4);
  text(">",buttonX+buttonS,buttonY);
textSize(18);
  text("^",buttonX+1,buttonY-buttonS);
textSize(12);
  text("v",buttonX+1,buttonY+buttonS);


  
//draw rectangles
  fill(colorScheme[0]);
  rectMode(CORNER);
  rect(joeyWidth,barHeight,valeriaWidth,2*valeriaHeight);
  rect(0,0,width,barHeight);

  //draw legend
  textSize(10);
  for(int i = 0; i < cartelsJ.length-3; i++){
    int [] cartcol = cartelColor(cartelsJ[i][1].charAt(0));
    fill(seriesColsJ[cartcol[0]][0]);
    rect(legendS*(i+1), barHeight/4,20,20);
    text(cartelsJ[i][0],legendS*(i+1), barHeight/4 + 25, 60,40);

  }
  
}


void zoomit(float zoom) {
  for(int i = 0; i < municCount; i++){
    RShape munic =  munis[i];
    if(munic != null){
      munic.scale(zoom);
      munis[i] = munic;
    }
  } 
}

void update(){
  if(locked == false) {
    left.update();
    right.update();
    up.update();
    down.update();
    in.update();
    out.update();
  } 
  else {
    locked = false;
  }

  if(mousePressed) {
    if(left.pressed())
      xx = xx + pan;
    if(right.pressed())
      xx = xx - pan;
    if(up.pressed())
      yy = yy + pan;
    if(down.pressed())
      yy = yy - pan;
    if(in.pressed())
      zoomit(zoom);
    if(out.pressed())
      zoomit(1/zoom);
  }
}

int[] cartelColor(char cartS){
  int cartIndl=0;
  int cartIndd=0;
  int rowCart=0;
  
  //define the colors
  switch(cartS){
  case 'G':
    cartIndl = 0;
    cartIndd = 0;
    rowCart = 0;
    break;
  case 'Z':
    cartIndl = 1;
     cartIndd = 1;
     rowCart = 1;
    break;
  case 'P':
    cartIndl = 2;
    cartIndd = 2;
    rowCart = 2;
    break;
  case 'F':
    cartIndl = 3;
    cartIndd = 3;
    rowCart = 3;
    break;
  case 'J':
    cartIndl = 4;
    cartIndd = 4;
    rowCart = 4;
    break;
  case 'S':
    cartIndl = 5;
    cartIndd = 5;
    rowCart = 5;
    break;
  case 'N':
    cartIndl = 6;
    cartIndd = 6;
    rowCart =6;
    break;
  case 'D':
    cartIndl = 7;
    cartIndd = 7;
    rowCart =7;
    break;
   case 's':
    cartIndl = 5;
    cartIndd = 2;
    rowCart =8;
    break;
   case 'a':
    cartIndl = 8;
    cartIndd = 2;
    rowCart =9;
    break;
   case 'z':
    cartIndl = 1;
    cartIndd = 0;
    rowCart =10;
    break;  
   default:
     //println("failed"); 
  }
  int[] vals = {cartIndl, cartIndd, rowCart};
  return vals;
}
