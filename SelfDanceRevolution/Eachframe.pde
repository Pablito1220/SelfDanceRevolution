class Eachframe {
  float x, y, z, rotation, echelle;
  float couleurR, couleurG, couleurB;
  PGraphics frame;

  Eachframe(PImage _temp, float x, float y, float z, float rotation, float echelle, float couleurR, float couleurG, float couleurB) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.rotation = rotation;
    this.echelle = echelle;
    this.couleurR = couleurR;
    this.couleurG = couleurG;
    this.couleurB = couleurB;

    frame = createGraphics(_temp.width, _temp.height);
    frame.beginDraw();

    frame.image(_temp, 0, 0);
    frame.endDraw();
  }

  void draw() {
    pushMatrix();
    translate(x, y, z);
    scale(-1, 1);
    //scale(echelle);
   
    rotate(rotation);

     
     //tint(round(couleurR), 100,80);

    image(frame, 0, 0);

    /* fill(0, 1);
     rect(-width/2, -height/2, width*2, height*2);*/
    popMatrix();
  }
}