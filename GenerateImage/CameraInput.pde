// This sketch opens a webcam camera window and returns a snapshot
// Runs in separate window
// ESC key shifts focus back to main window

import processing.core.PApplet; // sketch top class
import gab.opencv.*;
import processing.video.*;
import java.awt.*;
import gab.opencv.*;
import org.opencv.core.Mat;
import org.opencv.videoio.VideoCapture;
import org.opencv.videoio.Videoio;

public class CameraInputImage extends PApplet {
  VideoCapture video;
  OpenCV opencv;
  PImage frameImage;
  boolean cameraReady = false;
  boolean sketchSetup = false;
  int camKey;
  int camKeyCode;
  Mat frame1;
  int camNum = 0;
  PImage img;


  void settings() {
    // size matches DALLE response size
    size(1024, 1024);  // default renderer JAVA2D
  }

  void setup() {
    if (DEBUG) println("CameraInput setup()");
    setTitle("Camera Input Image");    
    sketchSetup = true;
  }
  
  /**
   * initialize this instance of EditMaskImage
   */
  void init(PImage img, PImage mImg, boolean embedMask) {
    stop();
    println("Camera Input Image init() ");

    //opencv = new OpenCV(this, 640, 480);
    opencv = new OpenCV(this, 1024, 1024);

    video = new VideoCapture(camNum, Videoio.CAP_DSHOW);
    frame1 = new Mat();
    video.set(Videoio.CAP_PROP_FRAME_WIDTH, 1920);
    video.set(Videoio.CAP_PROP_FRAME_HEIGHT, 1080);
    cameraReady = true;
  }

  /**
   * Prevent drawing until ready
   */
  void stop() {
    cameraReady = false;
  }


  void draw() {
    background(128);
    updateCamKey();
    if (!cameraReady) {
      textSize(48);
      text("Waiting for Camera Image", 10, height/2);
      return;
    }
    if (video.read(frame1)) {
      img = createImage(frame1.width(), frame1.height(), RGB);
      opencv.toPImage(frame1, img);
      
      image(img, -(width-448), 0); // crop for 1024x1024 display screen 
      
      //noFill();
      //stroke(0, 255, 0);
      //strokeWeight(3);
      //for (int i = 0; i < faces.length; i++) {
      //  println(faces[i].x + "," + faces[i].y);
      //  rect(faces[i].x, faces[i].y, faces[i].width, faces[i].height);
      //}
    }
  }

  /**
   * Capture frame
   */
  void captureFrame() {
    println("captureFrame()");
    frameImage = createImage(1024, 1024, ARGB);
    frameImage.copy(img,448,0,1024,1024,0,0,1024,1024); // copy cropped image
    
    current = 0;
    for (int i=0; i<numImages; i++) {
      receivedImage[i] = null;
      saved[i] = false;
      imageURL[i] = "";
    }
    saved[current] = true;
    receivedImage[current] = frameImage;
    String frameImagePath = saveFolderPath + File.separator + "CAM" + getDateTime() + ".png";
    frameImage.save(frameImagePath);
    saveCameraImageSelection(frameImagePath);
  }

  /**
   * process key commands
   */
  boolean updateCamKey() {
    boolean consumed = false;
    switch (camKeyCode) {
    case KEYCODE_ESC:
      generateImageSketch.surface.setVisible(true);  // give focus back to main sketch
      break;
    case KEYCODE_ENTER: // select video frame for main sketch
      captureFrame();
      break;
    default:
      return consumed;
      //break;
    }
    camKeyCode = 0;
    camKey = 0;
    consumed = true;
    return consumed;
  }

  /**
   * Key press notification on separate thread
   * save keys for draw thread
   */
  void keyPressed() {
    if (key==ESC) {  // prevent sketch exit
      key = 0; // override so that key is ignored
      keyCode = KEYCODE_ESC;
    }
    camKey = key;
    camKeyCode = keyCode;
    if (DEBUG) println("Camera Input key="+ camKey + " key10=" + int(camKey) + " keyCode="+camKeyCode);
  }
}
