import gab.opencv.*;
import processing.video.*;

OpenCV opencv;
OpenCV motionTrack;
Capture video;
Histogram histogram;


int lowerb = 50;
int upperb = 100;

double colorThreshold = 0;
double motionThreshold = 0;

void setup() {
  size(650, 480);
  video = new Capture(this, 640/2, 480/2);
  opencv = new OpenCV(this, 640/2, 480/2);
  motionTrack = new OpenCV(this, 640/2, 480/2);
  video.start();
}

void draw() {
  double a;
  double b;
  background(0);
  opencv.useColor(HSB);
  opencv.equalizeHistogram();
  opencv.loadImage(video); 
  motionTrack.loadImage(video);
  
  
  
  
  opencv.setGray(opencv.getH().clone());
  opencv.inRange(lowerb, upperb);
  histogram = opencv.findHistogram(opencv.getH(), 255);
  image(opencv.getOutput(), 0, 0);
  
  
  
  opencv.loadImage(opencv.getOutput());
  opencv.calculateOpticalFlow();
  translate(video.width+10,0);
  stroke(255,0,0);
  opencv.drawOpticalFlow();
  
  PVector aveFlow = opencv.getAverageFlow();
  int flowScale = 25;
  
  stroke(255);
  strokeWeight(2);
  line(video.width/2, video.height/2, video.width/2 + aveFlow.x*flowScale, video.height/2 + aveFlow.y*flowScale);
  a = aveFlow.x*flowScale;
  b = aveFlow.y*flowScale;
  colorThreshold = Math.sqrt(Math.pow(a,2) + Math.pow(b,2));
  
  translate(-video.width-10,video.height);
  image(video,0,0);
  
  translate(-10,-video.height);
  noStroke(); fill(0,255,0);
  histogram.draw(10, height - 230, 400, 200);
  noFill(); stroke(0);
  line(10, height-30, 410, height-30);

  text("Hue", 10, height - (textAscent() + textDescent()));

  float lb = map(lowerb, 0, 255, 0, 400);
  float ub = map(upperb, 0, 255, 0, 400);

  stroke(255, 0, 0); fill(255, 0, 0);
  strokeWeight(2);
  line(lb + 10, height-30, ub +10, height-30);
  ellipse(lb+10, height-30, 3, 3 );
  text(lowerb, lb-10, height-15);
  ellipse(ub+10, height-30, 3, 3 );
  text(upperb, ub+10, height-15);
  
  motionTrack.calculateOpticalFlow();
  PVector ave2Flow = motionTrack.getAverageFlow();
  
  
  translate(video.width+10,video.height);
  stroke(0,0,255);
  strokeWeight(2);
  line(video.width/2, video.height/2, video.width/2 + ave2Flow.x*flowScale, video.height/2 + ave2Flow.y*flowScale);
  ellipse(video.width/2 + ave2Flow.x*flowScale, video.height/2 + ave2Flow.y*flowScale, 8, 8);
  
  a = ave2Flow.x*flowScale;
  b = ave2Flow.y*flowScale;
  motionThreshold = Math.sqrt(Math.pow(a,2) + Math.pow(b,2));
  
  if (colorThreshold >= 0.25*motionThreshold && motionThreshold >= 30){
    System.out.println("FIRE!");
  } else {
    //System.out.println("PAUSE");
  }
}

void mouseMoved() {
  if (keyPressed) {
    upperb += mouseX - pmouseX;
  } 
  else {
    if (upperb < 255 || (mouseX - pmouseX) < 0) {
      lowerb += mouseX - pmouseX;
    }

    if (lowerb > 0 || (mouseX - pmouseX) > 0) {
      upperb += mouseX - pmouseX;
    }
  }

  upperb = constrain(upperb, lowerb, 255);
  lowerb = constrain(lowerb, 0, upperb-1);
}


void captureEvent(Capture c) {
  c.read();
}