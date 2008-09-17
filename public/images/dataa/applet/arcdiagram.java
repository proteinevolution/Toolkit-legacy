import processing.core.*; import java.applet.*; import java.awt.*; import java.awt.image.*; import java.awt.event.*; import java.io.*; import java.net.*; import java.text.*; import java.util.*; import java.util.zip.*; public class arcdiagram extends PApplet {String[] lines;
String[] lines2;
int index=0;
int i2ndex=0;
float len=0;
float dstart=0;
float dend=0;
float difflen=0;
float d2start=0;
float d2end=0;
int swtch=0;
float num=0.0f;
String stalk="S";
String head="H";
String conN="CN";
String conH="CH";
PFont fonta;

public void setup() {
  size(800, 350);
  background(255);
  smooth();
  lines = loadStrings("data.txt");
  lines2= lines;
  fonta = loadFont("TheSans-Plain-12.vlw");
  textFont(fonta);
  fill (0,0,0);
 
  text("Legend:", 700, 30);
  fill(235,230,10);
  text("stalks", 700, 50);
  fill(185,20,20);
  text("heads", 700, 65);
  fill(20,185,20);
  text("connectors", 700, 80);
  fill(30,30,30);
  text("anchor", 700, 95);

}

public void draw() {
  
  //draw rectangles
  if (index < lines.length) {
    String[] pieces = split(lines[index], ' ');
    if (pieces.length == 2){
      len = PApplet.parseFloat(pieces[1]);
      num=700.0f/len;
      noFill();
      stroke(50);
      rect(20,320, num*len, 10);

    }
    if (pieces.length == 4) {
      dstart = PApplet.parseInt(pieces[2]);
      dend = PApplet.parseInt(pieces[3]);
      len=dend-dstart+1;//len=len+1;
      fill (30,30,30,50);
      if (pieces[0].equals(stalk)==true){
        fill(235,230,10,80);
      }
      if (pieces[0].equals(head)==true){
        fill(185,20,20,50);
      }
      if (pieces[0].equals(conN)==true){
        fill(20,185,20,50);
      }
      if (pieces[0].equals(conH)==true){
        fill(20,185,20,50);
      }

      rect(20+num*dstart, 320, num*len, 10);
    }
    // Go to the next line for the next run through draw()
    index = index + 1;
  }


  //draw arcs
  if (i2ndex < lines2.length) {

    String[] pieces = split(lines2[i2ndex], ' ');
    if (pieces.length == 4) {
      for (int i = index ; i < lines2.length; i++){
        String[] p2ieces=split (lines2[i], ' ');  
        if (p2ieces.length == 4){
          if (PApplet.parseInt(pieces[1]) == PApplet.parseInt(p2ieces[1])) {        
            swtch=1;    
            dstart = PApplet.parseFloat(pieces[2]);
            dend = PApplet.parseFloat(pieces[3]);
            len=dend-dstart+1;//len=len+1;
            d2start = PApplet.parseFloat(p2ieces[2]);            
            difflen = PApplet.parseFloat(p2ieces[2]) - dstart;
            if (pieces[0].equals(stalk)==true){
              stroke(235,230,10,80);
            }
            if (pieces[0].equals(head)==true){
              stroke(185,20,20,50);
            }
            if (pieces[0].equals(conN)==true){
              stroke(20,185,20,50);
            }
            if (pieces[0].equals(conH)==true){
              stroke(20,185,20,50);
            }
            noFill();
            strokeWeight(num*(dend - dstart));
            strokeCap(SQUARE);
            arc (21+num*(dend+(d2start-dend)/2), 315, num*difflen, num*difflen, PI, 0);
            strokeWeight(1);
            stroke(50);
            break;
          }
        }
        if (i == lines.length){ 
          swtch=1;
        }
      }
    }
    // Go to the next line for the next run through draw()
    i2ndex = i2ndex + 1;
  } 
  if (i2ndex == lines2.length){
    exit();
  }
}



  static public void main(String args[]) {     PApplet.main(new String[] { "arcdiagram" });  }}