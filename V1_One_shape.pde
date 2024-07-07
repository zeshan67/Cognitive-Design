import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioInput in;

int shapeType = 0;

void setup() {
  size(800, 600);
  minim = new Minim(this);
  in = minim.getLineIn(Minim.MONO, 512);
  if (in == null) {
    println("Audio input initialization failed");
    exit();
  }
}

void draw() {
  background(255);
  if (in != null) {
    float amplitude = in.left.level();
    
    if (amplitude > 0.2) {
      shapeType = (shapeType + 1) % 3;
    }
  
    fill(100, 150, 200);
    noStroke();
    
    translate(width / 2, height / 2);
    
    if (shapeType == 0) {
      ellipse(0, 0, 100, 100);
    } else if (shapeType == 1) {
      rect(-50, -50, 100, 100);
    } else if (shapeType == 2) {
      triangle(-50, 50, 0, -50, 50, 50);
    }
  }
}

void stop() {
  if (in != null) {
    in.close();
  }
  minim.stop();
  super.stop();
}
