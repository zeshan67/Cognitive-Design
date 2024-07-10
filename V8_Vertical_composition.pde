import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioInput in;

int numCurves = 10;
Curve[] curves;

color[] gradientColors;

void setup() {
  size(800, 600);
  minim = new Minim(this);
  in = minim.getLineIn(Minim.MONO, 512);
  if (in == null) {
    println("Audio input initialization failed");
    exit();
  }

  // Create gradient colors
  gradientColors = new color[numCurves];
  for (int i = 0; i < numCurves; i++) {
    float t = map(i, 0, numCurves - 1, 0, 1);
    gradientColors[i] = lerpColor(color(255, 182, 193), color(255, 105, 180), t);
  }

  curves = new Curve[numCurves];
  for (int i = 0; i < numCurves; i++) {
    curves[i] = new Curve(random(width), gradientColors[i % gradientColors.length]);
  }

  background(30); // Dark background color
}

void draw() {
  background(30); // Dark background color
  if (in != null) {
    float amplitude = in.left.level();

    // Adjust the entire gradient color based on the amplitude
    for (int i = 0; i < numCurves; i++) {
      curves[i].changeColor(adjustColor(gradientColors[i], amplitude));
    }

    for (int i = 0; i < numCurves; i++) {
      curves[i].move(amplitude);
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
  float x;
  float vx;
  color curveColor;
  PVector[] points;
  int numPoints = 100;

  Curve(float x, color curveColor) {
    this.x = x;
    this.vx = random(-0.5, 0.5);
    this.curveColor = curveColor;
    points = new PVector[numPoints];
    for (int i = 0; i < numPoints; i++) {
      points[i] = new PVector(x + random(-10, 10), i * (height / (numPoints - 1)));
    }
  }

  void changeColor(color newColor) {
    curveColor = newColor;
  }

  void move(float amplitude) {
    float movement = amplitude * 20; // Adjust this factor for more or less movement
    for (int i = 0; i < numPoints; i++) {
      points[i].x = x + sin(TWO_PI * i / numPoints + frameCount * 0.02) * movement;
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

  // Increase saturation and brightness based on the factor
  float brightnessFactor = map(factor, 0, 1, 0.5, 1.5);
  r = constrain(r * brightnessFactor, 0, 255);
  g = constrain(g * brightnessFactor, 0, 255);
  b = constrain(b * brightnessFactor, 0, 255);

  return color(r, g, b);
}
