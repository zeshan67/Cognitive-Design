import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioInput in;

int numCurves = 5;
Curve[] curves;

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

  curves = new Curve[numCurves];
  for (int i = 0; i < numCurves; i++) {
    curves[i] = new Curve(random(height), pastelColors[i % pastelColors.length]);
  }
}

void draw() {
  background(255);
  if (in != null) {
    float amplitude = in.left.level();
    
    if (amplitude > 0.2) {
      for (int i = 0; i < numCurves; i++) {
        curves[i].changeColor(adjustColor(pastelColors[(int)random(pastelColors.length)], amplitude));
      }
    }
    
    for (int i = 0; i < numCurves; i++) {
      curves[i].move(amplitude);
      for (int j = i + 1; j < numCurves; j++) {
        curves[i].checkCollision(curves[j]);
      }
      curves[i].display();
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

class Curve {
  float y;
  float vy;
  color curveColor;
  PVector[] points;
  int numPoints = 100;
  
  Curve(float y, color curveColor) {
    this.y = y;
    this.vy = random(-2, 2);
    this.curveColor = curveColor;
    points = new PVector[numPoints];
    for (int i = 0; i < numPoints; i++) {
      points[i] = new PVector(i * (width / (numPoints - 1)), y + random(-10, 10));
    }
  }
  
  void changeColor(color newColor) {
    curveColor = newColor;
  }
  
  void move(float amplitude) {
    y += vy * amplitude * 10;
    
    // Update points
    for (int i = 0; i < numPoints; i++) {
      points[i].y = y + sin(TWO_PI * i / numPoints) * 20 * amplitude;
    }
    
    // Bounce off the edges and stay within bounds
    if (y < 0) {
      y = 0;
      vy *= -1;
    } else if (y > height) {
      y = height;
      vy *= -1;
    }
  }
  
  void checkCollision(Curve other) {
    float distance = abs(other.y - this.y);
    float minDist = 20; // Minimum distance between curves
    
    if (distance < minDist) {
      float overlap = minDist - distance;
      float adjustment = overlap / 2;
      if (this.y < other.y) {
        this.y -= adjustment;
        other.y += adjustment;
      } else {
        this.y += adjustment;
        other.y -= adjustment;
      }
      this.vy *= -1;
      other.vy *= -1;
    }
  }
  
  void display() {
    noFill();
    stroke(curveColor);
    strokeWeight(2);
    
    beginShape();
    for (PVector point : points) {
      curveVertex(point.x, point.y);
    }
    endShape();
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
