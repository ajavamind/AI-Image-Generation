// This sketch opens a UVC/webcam camera window and returns a snapshot
// Runs in separate window
// ESC key returns focus to main window

import processing.core.PApplet; // sketch top class
import gab.opencv.*;
import processing.video.*;
import gab.opencv.*;
import org.opencv.core.Mat;
import org.opencv.videoio.VideoCapture;
import org.opencv.videoio.Videoio;

public class UvcCameraInputImage extends PApplet {
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
  int cropx = 0;  // left border position to crop center of image
  //boolean sbs3D = true;  // stereo camera side-by-side
  boolean anaglyph = true;  // convert to anaglyph
  boolean sbs3D = true;
  PImage left;
  PImage right;

  void settings() {
    // size matches DALLE response size
    size(1024, 1024);  // default renderer JAVA2D
  }

  void setup() {
    if (DEBUG) println("UvcCameraInput setup() "+width +" "+height);
    setTitle("UVC Camera Input Image");
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

    video = new VideoCapture(camNum, Videoio.CAP_DSHOW);  // for Windows
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
      //println("img w="+img.width + " h="+img.height);

      if (anaglyph && sbs3D) {   // convert to anaglyph first
        left = createImage(frame1.width()/2, frame1.height(), RGB);
        left.copy(img, 0, 0, frame1.width()/2, frame1.height(), 0, 0, frame1.width()/2, frame1.height());
        right = createImage(frame1.width()/2, frame1.height(), RGB);
        right.copy(img, frame1.width()/2, 0, frame1.width()/2, frame1.height(), 0, 0, frame1.width()/2, frame1.height());
        img = createAnaglyph(left, right, 0);
        cropx = img.width/2 - width/2;
      } else if (sbs3D) {
        cropx = img.width/2 - width;
      } else {
        cropx = img.width/2 - width/2;
      }

      //println("cropx="+cropx);
      image(img, -cropx, 0); // crop for 1024x1024 display screen

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
    frameImage = createImage(1024, 1024, ARGB);  // transparency layer included (alpha)
    frameImage.copy(img, cropx, 0, 1024, 1024, 0, 0, 1024, 1024); // copy cropped image

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

  // create anaglyph from left and right eye views
  PImage createAnaglyph(PImage left, PImage right, int offset) {
    PImage img;
    if (DEBUG) println("createAnaglyph() from PImage ");
    if (!(left != null && left.width > 0)) {
      return null;
    } else if (!(right != null && right.width > 0)) {
      return null;
    }
    img = colorAnaglyph(left, right, offset);
    return img;
  }


  private PImage colorAnaglyph(PImage bufL, PImage bufR, int offset) {
    // color anaglyph merge left and right images
    if (DEBUG) println("colorAnaglyph offset="+offset);
    if (bufL == null || bufR == null)
      return null;
    //if (DEBUG) println("parallax="+parallax);
    PImage bufA = createImage(bufL.width, bufL.height, RGB);
    bufA.loadPixels();
    bufL.loadPixels();
    bufR.loadPixels();
    int cr = 0;
    int w = bufL.width;
    int h = bufL.height;
    int i = 0;
    int j = w - offset;
    int k = w;
    int len = bufL.pixels.length;
    while (i < len) {
      if (j > 0) {
        cr = bufR.pixels[i];
        if ((i + offset) < 0  || (i+offset) >= len) {
          //if (DEBUG) println("anaglyph creation out of range "+ (i+offset));
        } else {
          bufA.pixels[i] = color(red(bufL.pixels[i+offset]), green(cr), blue(cr));
        }
        j--;
      } else {
        bufA.pixels[i] = 0;
      }
      k--;
      if (k <= 0) {
        k = w;
        j = w - offset;
      }
      i++;
    }
    bufA.updatePixels();
    PImage temp = createImage(w-offset, h, RGB);
    temp.copy(bufA, 0, 0, temp.width, temp.height, 0, 0, temp.width, temp.height);
    bufA.parent = null; // dispose
    bufA = null;
    return temp;
  }
}
