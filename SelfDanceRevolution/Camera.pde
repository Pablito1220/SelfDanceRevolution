class Camera {
  PVector eye, center, up;
  float fov, near, far;

  Camera() {   
    fov = PI/4.0;
    near = 0.01;
    far = 1000;
    eye = new PVector(0, 0, 0);
    center = new PVector(0, 0, -1);
    up = new PVector(0, 1, 0);
  }

  void apply() {
    float z = (height/2.0) / tan(fov/2.0);
    perspective(fov, float(width)/float(height), z*near, z*far);
    camera(eye.x, eye.y, eye.z, center.x, center.y, center.z, up.x, up.y, up.z);
  }
}