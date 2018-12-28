import processing.video.Capture;
import gab.opencv.OpenCV;
import java.awt.Rectangle;
 
import oscP5.*;
import netP5.*;

Capture cam;
OpenCV opencv;

// input resolution
int w = 320, h = 240;

// output zoom
int zoom = 1;


OscP5 oscP5;
NetAddress myRemoteLocation;


void setup() {

  // actual size, is a result of input resolution and zoom factor
  size(320 , 240 );

  // capture camera with input resolution
  cam = new Capture(this, w, h);
  cam.start();

  // init OpenCV with input resolution
  opencv = new OpenCV(this, w, h);

  // setup for facial recognition
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);  

  // limit frameRate
  //frameRate(30);
  
   /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,12000);
  
  /* myRemoteLocation is a NetAddress. a NetAddress takes 2 parameters,
   * an ip address and a port number. myRemoteLocation is used as parameter in
   * oscP5.send() when sending osc packets to another computer, device, 
   * application. usage see below. for testing purposes the listening port
   * and the port of the remote location address are the same, hence you will
   * send messages back to this sketch.
   */
  myRemoteLocation = new NetAddress("127.0.0.1",12000);
}


void draw() {

  // get the camera image
  opencv.loadImage(cam);

  // detect faces
  Rectangle[] faces = opencv.detect();

  // zoom to input resolution
  scale(zoom);

  // draw input image
  image(opencv.getInput(), 0, 0);

  // draw rectangles around detected faces
  fill(255, 64);
  strokeWeight(3);
  //for (int i = 0; i < faces.length; i++) {
    
  if (faces.length != 0){ 
    rect(faces[0].x, faces[0].y, faces[0].width, faces[0].height);
    //float x = map(faces[0].x,0,320, -2,2);
    //float y = map(faces[0].y, 0, 240,-2,2);
    println(faces[0].x, faces[0].y, frameRate);
    sendOSC(faces[0].x, faces[0].y);
  }  
//}
  

  // show performance and number of detected faces on the console
  if (frameCount % 50 == 0) {
    println("Frame rate:", round(frameRate), "fps");
    println("Number of faces:", faces.length);
  }
  
}

// read a new frame when it's available
void captureEvent(Capture c) {
  c.read();
}


void sendOSC(float x, float y){
  OscMessage myMessage = new OscMessage("/cam");
  myMessage.add(x);
  myMessage.add(y);
  oscP5.send(myMessage, myRemoteLocation);
}
