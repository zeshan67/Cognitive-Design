import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioInput in;

int numShapes = 5;
Shape[] shapes;

color[] pastelColors = {
  color(255, 182, 193),
  color(176, 224, 230),
  color(152, 251, 152),
  color(255, 228, 181),
  color(221, 160, 221)
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
    shapes[i] = new Shape(random(width), random(height), pastelColors[i % pastelColors.length]);
  }
}

void draw() {
  background(255);
  if (in != null) {
    float amplitude = in.left.level();
    
    if (amplitude > 0.2) {
      for (int i = 0; i < numShapes; i++) {
        shapes[i].changeShape();
        shapes[i].changeColor(adjustColor(pastelColors[(int)random(pastelColors.length)], amplitude));
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
    
    // Bounce off the edges and stay within bounds
    if (x < radius) {
      x = radius;
      vx *= -1;
    } else if (x > width - radius) {
      x = width - radius;
      vx *= -1;
    }
    if (y < radius) {
      y = radius;
      vy *= -1;
    } else if (y > height - radius) {
      y = height - radius;
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

color adjustColor(color c, float factor) {
  float r = red(c);
  float g = green(c);
  float b = blue(c);
  
  // Increase saturation based on the factor
  float saturationFactor = map(factor, 0, 1, 0.5, 1.5);
  r = constrain(r * saturationFactor, 0, 255);
  g = constrain(g * saturationFactor, 0, 255);
  b = constrain(b * saturationFactor, 0, 255);
  
  return color(r, g, b);
}
