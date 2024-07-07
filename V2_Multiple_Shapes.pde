import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioInput in;

int numShapes = 5;
Shape[] shapes;

color[] colors = {
  color(255, 0, 0),
  color(0, 255, 0),
  color(0, 0, 255),
  color(255, 255, 0),
  color(0, 255, 255)
};

void setup() {
  size(800, 600);
  minim = new Minim(this);
  in = minim.getLineIn(Minim.MONO, 512);
  if (in == null) {
    println("Audio input initialization failed");
    exit();
  }

  shapes = new Shape[numShapes];
  for (int i = 0; i < numShapes; i++) {
    shapes[i] = new Shape(random(width), random(height), colors[i % colors.length]);
  }
}

void draw() {
  background(255);
  if (in != null) {
    float amplitude = in.left.level();
    
    if (amplitude > 0.2) {
      for (int i = 0; i < numShapes; i++) {
        shapes[i].changeShape();
        shapes[i].changeColor(colors[(int)random(colors.length)]);
      }
    }
    
    for (int i = 0; i < numShapes; i++) {
      shapes[i].display();
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

class Shape {
  float x, y;
  int shapeType;
  color shapeColor;
  
  Shape(float x, float y, color shapeColor) {
    this.x = x;
    this.y = y;
    this.shapeType = (int)random(3);
    this.shapeColor = shapeColor;
  }
  
  void changeShape() {
    shapeType = (shapeType + 1) % 3;
  }
  
  void changeColor(color newColor) {
    shapeColor = newColor;
  }
  
  void display() {
    fill(shapeColor);
    noStroke();
    
    pushMatrix();
    translate(x, y);
    
    if (shapeType == 0) {
      ellipse(0, 0, 50, 50);
    } else if (shapeType == 1) {
      rect(-25, -25, 50, 50);
    } else if (shapeType == 2) {
      triangle(-25, 25, 0, -25, 25, 25);
    }
    
    popMatrix();
  }
}
