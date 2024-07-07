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
      shapes[i].move(amplitude);
      for (int j = i + 1; j < numShapes; j++) {
        shapes[i].checkCollision(shapes[j]);
      }
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
  float vx, vy;
  int shapeType;
  color shapeColor;
  float radius = 25;
  
  Shape(float x, float y, color shapeColor) {
    this.x = x;
    this.y = y;
    this.vx = random(-2, 2);
    this.vy = random(-2, 2);
    this.shapeType = (int)random(3);
    this.shapeColor = shapeColor;
  }
  
  void changeShape() {
    shapeType = (shapeType + 1) % 3;
  }
  
  void changeColor(color newColor) {
    shapeColor = newColor;
  }
  
  void move(float amplitude) {
    x += vx * amplitude * 10;
    y += vy * amplitude * 10;
    
    // Bounce off the edges
    if (x < radius || x > width - radius) {
      vx *= -1;
    }
    if (y < radius || y > height - radius) {
      vy *= -1;
    }
  }
  
  void checkCollision(Shape other) {
    float dx = other.x - this.x;
    float dy = other.y - this.y;
    float distance = sqrt(dx * dx + dy * dy);
    float minDist = this.radius + other.radius;
    
    if (distance < minDist) {
      // Calculate angle, sine, and cosine
      float angle = atan2(dy, dx);
      float targetX = this.x + cos(angle) * minDist;
      float targetY = this.y + sin(angle) * minDist;
      float ax = (targetX - other.x) * 0.5;
      float ay = (targetY - other.y) * 0.5;
      
      // Adjust velocities based on elastic collision
      this.vx -= ax;
      this.vy -= ay;
      other.vx += ax;
      other.vy += ay;
    }
  }
  
  void display() {
    fill(shapeColor);
    noStroke();
    
    pushMatrix();
    translate(x, y);
    
    if (shapeType == 0) {
      ellipse(0, 0, radius * 2, radius * 2);
    } else if (shapeType == 1) {
      rect(-radius, -radius, radius * 2, radius * 2);
    } else if (shapeType == 2) {
      triangle(-radius, radius, 0, -radius, radius, radius);
    }
    
    popMatrix();
  }
}
