//import codeanticode.syphon.*;

import gab.opencv.*;
import java.awt.Rectangle;
import processing.video.*;
import java.awt.*;

import ddf.minim.*;
import ddf.minim.analysis.*;

import processing.sound.*;


Minim minim;
AudioPlayer song;
BeatDetect beat;

Capture video;
OpenCV opencv;

PShader blur;
PShader invert;

PGraphics canvas;
//SyphonServer server;

float dcameraZ;

ArrayList<Eachframe> eachFrames;

Camera cam;
PVector cameraPos;
boolean[] keys;

PImage temp;


int rapportMove;

/*void settings() {
  size(400, 400, P3D);
  PJOGL.profile=1;
}*/


void setup() {
  fullScreen(P3D);
 // server = new SyphonServer(this, "Processing Syphon");
  noCursor();
  smooth();
  //size(640, 480, P3D);

  minim = new Minim(this);
  song = minim.loadFile("Von Af - An Italian Groove.wav", 2048);
  song.loop();
  // a beat detection object song SOUND_ENERGY mode with a sensitivity of 10 milliseconds
  beat = new BeatDetect();

  //Shader blur
  blur = loadShader("blur.glsl"); 
  invert = loadShader("invert.glsl");

  background(0);
  hint(ENABLE_DEPTH_SORT);

  cam = new Camera();
  cameraPos = cam.eye.copy();
  cameraPos.y = 0;
  cameraPos.z = 500;

  video = new Capture(this, 640, 480);
  opencv = new OpenCV(this, video.width, video.height);
  //Seulement afficher les objets en mouvements
  opencv.startBackgroundSubtraction(5, 3, 0.5);

  eachFrames = new ArrayList<Eachframe>();

  //Image blanche
  temp = createImage(video.width, video.height, ARGB);
  for (int i = 0; i < temp.pixels.length; i++) {
    temp.pixels[i] = color(255);
  }

  video.start();

  keys = new boolean[256];
}

void keyPressed() {
  keys[keyCode] = true;
}

void keyReleased() {
  keys[keyCode] = false;
}


void draw() {
  background(0);
  int minVol = 1;
  int maxVol = 400;

  //Volume Gauche
  float preLimiteLeft = map(song.left.level(), 0, 1, minVol, maxVol);
  int limiteL = round(preLimiteLeft);
  //Volume Droit
  float preLimiteRight = map(song.right.level(), 0, 1, minVol, maxVol);
  int limiteR = round(preLimiteRight);
  //Moyenne des Volumes
  int limite = round((limiteR+limiteL)/2);



  //println(limite);

  rapportMove = 32;
  if (keys['w'-rapportMove]) cameraPos.y -= 20;
  else if (keys['s'-rapportMove]) cameraPos.y += 20;

  if (keys['a'-rapportMove]) cameraPos.x -= 20;
  else if (keys['d'-rapportMove]) cameraPos.x += 20;

  if (keys['y'-rapportMove]) cameraPos.z -= 20;
  else if (keys['x'-rapportMove]) cameraPos.z += 20;

  cam.eye.x += (cameraPos.x - cam.eye.x) * 0.1;
  cam.eye.y += (cameraPos.y - cam.eye.y) * 0.1;
  cam.eye.z += (cameraPos.z - cam.eye.z) * 0.1;   
  cam.center.x = cam.eye.x/2;
  cam.center.y = cam.eye.y/2;
  cam.center.z = 0;

  cam.apply();

  ///translate(width/2, height/2);
  imageMode(CENTER);

  /*float sourisH = map(mouseX, 0, width, -width, width);
   float sourisV = map(mouseY, 0, width, -width, width);*/
  //rotateY(PI/4);
  //rotateX(-PI/8);
  if (frameCount %300==0) {
    cameraPos.x = sin(frameCount*0.01)*500;
    cameraPos.y = cos(frameCount*0.013)*500;
  }

  if (frameCount%1000 ==0) {
    cameraPos.x = 0;
    cameraPos.y = 0;
  }

  //Vitesse de défilement des frames
  int vitesse = 30;


  translate(0, 0, -frameCount*vitesse);

  beat.detect(song.mix);

  opencv.loadImage(video);
  //Update pour l'affichage des objets en mouvement
  opencv.updateBackground();
  //Afficher seulement le contour
  if (frameCount >= 500) {
    opencv.findCannyEdges(30, 75);
  }
  //Les lignes se dilatent toutes les 20 frames
  //if (frameCount%20 ==0) {
  if ( beat.isOnset() ) opencv.dilate();

  //Les lignes se dilatent toutes les 100 frames
  /*if (frameCount%100 ==0) {
   opencv.erode();
   }*/
  //Masque en utilisant l'output comme alpha
  temp.mask(opencv.getOutput());


  float rotation = 0;
  float vitesseRotation = 0;


  if (frameCount >=1500 && frameCount < 2500) {
    rotation = 0.01;
    vitesseRotation = frameCount%1500;
  }

  if (frameCount >=2500 && frameCount < 3500) {
    rotation = -0.01;
    vitesseRotation = frameCount%2500;
  }

  if (frameCount >=5000 && frameCount < 6000) {
    rotation = 0.01;
    vitesseRotation = frameCount%5000;
  }

  if (frameCount >=6000 && frameCount < 7000) {
    rotation = -0.01;
    vitesseRotation = frameCount%6000;
  }

  float echelle = abs(sin(frameCount*0.01));
  if (echelle < 0.1) {
    echelle = 0.1;
  }





  float preCouleurR = sin(frameCount*0.1)*255;
  float couleurR = map(abs(preCouleurR), 0, 255, 100, 255);

  float preCouleurG = sin(frameCount*0.02)*255;
  float couleurG = abs(preCouleurG);

  float preCouleurB = sin(frameCount*0.014)*255;
  float couleurB = map(abs(preCouleurB), 0, 255, 100, 150);

  //Crée une nouvelle image toutes les 5 frames
  if (frameCount % 1 ==0) {
    Eachframe tempEachFrame = new Eachframe(temp, 0, 0, frameCount*vitesse, vitesseRotation*rotation, echelle, couleurR, couleurG, couleurB);
    eachFrames.add(tempEachFrame);
  }
  //dessine toutes les frames créé
  for (int i = 0; i < eachFrames.size(); i++) {

    eachFrames.get(i).draw();
    //Dès qu'on arrive à 100 frame on supprime la plus vieille frame
    if (eachFrames.size() > limite) {
      eachFrames.remove(0);
    }
  }
  //filtre de flou
  filter(blur);

  //if (keys['i'-rapportMove]) {
  if (frameCount >= 4880 && frameCount < 4900) {
    if (frameCount%4 ==0) {
      filter(invert);
    }
  }
  println(frameCount);

  //server.sendScreen();
}

void captureEvent(Capture c) {
  c.read();
}