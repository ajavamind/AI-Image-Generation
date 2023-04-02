// This sketch creates a mask image for request
// Runs in separate window

import processing.core.PApplet; // sketch top class

public class EditMaskImage extends PApplet {

  PImage baseImage;
  PImage zoomImage;
  PImage maskImage;
  PGraphics workImage;
  PImage editImage;
  boolean erase = true;
  boolean editReady = false;
  int editKey;
  int editKeyCode;
  int brushSize;
  private static final int MAX_BRUSH_SIZE = 256;
  private static final int MIN_BRUSH_SIZE = 4;
  private static final int BRUSH_SIZE_STEP = 4;

  void settings() {
    // size matches DALLE response size
    size(1024, 1024);  // default renderer JAVA2D
  }
  
  /**
   * initialize the this instance
   */
  void init(PImage img, PImage mImg, boolean embedMask) {
    stop();
    brushSize = 32;
    baseImage = img.copy();
    println("Edit Mask Image init ");
    editImage = makeTransparent(baseImage);
    workImage = makeImageGraphics(baseImage.width, baseImage.height, color(0, 0, 0, 0));
    if (mImg != null) {
      workImage.loadPixels();
      mImg.loadPixels();
      for (int i=0; i<mImg.pixels.length; i++) {
        // replace transparent area of image with opaque white
        if ((mImg.pixels[i] & 0xFF000000) == 0) {
          workImage.pixels[i] = color(255,255,255,255);
        } 
      }
      workImage.updatePixels();
      workImage.save(saveFolderPath + File.separator+"amasktest.png");
      println("save amasktest.png");
    } else {
      println("mImg is null");
    }
    editReady = true;
  }

  /**
   * Prevent drawing until ready
   */
  void stop() {
    editReady = false;
  }

  /**
   * Edit Mask Image sketch draw loop
   */
  void draw() {
    if (!editReady) {
      text("Waiting for Image to edit.", width/2, height/2);
      return;
    }
    // save current and previous mouse locations
    int mx = mouseX;
    int my = mouseY;
    int pmx = pmouseX;
    int pmy = pmouseY;
    workImage.beginDraw();
    workImage.noStroke();
    workImage.fill(255, 255, 255, 255);
    if (mousePressed == true) {
      if (erase) {
        workImage.stroke(255);
      } else {
        workImage.stroke(0x00000000);
      }
      workImage.strokeWeight(brushSize);
      workImage.line(mx, my, pmx, pmy);
    }
    workImage.endDraw();
    maskImage = mergeImages(baseImage, workImage);
    image(maskImage, 0, 0);
    fill(255);
    noStroke();
    if (focused) circle(mx, my, brushSize); // show brush at mouse coordinates
    updateEditKey();
  }

  /**
   * save the mask image being edited
   */
  public String saveMask(String path, boolean embed) {
    PImage temp;
    if (embed) {  // is this really needed?
      temp = eraseTransparent(maskImage, baseImage);
      temp.save(path);
      println("save embed mask "+ path);
    } else {
      temp = eraseTransparent(maskImage, baseImage);
      temp.save(path);
      println("save transparent mask "+ path);
    }
    return path;
  }

  /** 
   * process key commands
   */
  boolean updateEditKey() {
    boolean consumed = false;
    switch (editKeyCode) {
    case KEYCODE_X: // alternate between erase and restore
      erase = !erase;
      break;
    case KEYCODE_RIGHT_BRACKET: // increase brush size
      brushSize += BRUSH_SIZE_STEP;
      if (brushSize >= MAX_BRUSH_SIZE) brushSize = MAX_BRUSH_SIZE;
      break;
    case KEYCODE_LEFT_BRACKET:  // reduce brush size
      brushSize -= BRUSH_SIZE_STEP;
      if (brushSize <= MIN_BRUSH_SIZE) brushSize = MIN_BRUSH_SIZE;
      break;
    case KEYCODE_PLUS: // zoom in
      PImage tempImage = workImage;
      //      workImage = resizeTransparent(tempImage, 0.5);
      //      baseImage = resizeTransparent(baseImage, 0.5);
      break;
    case KEYCODE_MINUS: // zoom out
      //      transparentImage = resizeTransparent(receivedImage, 0.5);
      //      transparentImage.save(sketchPath() + File.separator + saveFolder + File.separator + "transparentImage_0.50.png");
      break;
    default:
      return consumed;
      //break;
    }
    editKeyCode = 0;
    editKey = 0;
    consumed = true;
    return consumed;
  }

  /**
   * Key press notification on separate thread
   * save keys for draw thread use
   */
  void keyPressed() {
    editKey = key;
    editKeyCode = keyCode;
    println("EditImage key="+ editKey + " key10=" + int(editKey) + " keyCode="+editKeyCode);
  }

  /**
   * Make PImage into a transparent PImage
   * PImage img Input image
   * returns PImage converted to transparent
   */
  PImage makeTransparent(PImage img) {
    PImage result;
    result = createImage(img.width, img.height, ARGB);
    img.loadPixels();
    result.loadPixels();
    for (int i = 0; i < img.pixels.length; i++) {
      result.pixels[i] = img.pixels[i];
    }
    result.updatePixels();
    return result;
  }

  /**
   * Erase semi-transparent pixels in PImage by setting alpha to 0
   * PImage img Input image
   * returns PImage converted to transparent
   */
  PImage eraseTransparent(PImage img, PImage bImg) {
    PImage result;
    result = createImage(img.width, img.height, ARGB);
    img.loadPixels();
    bImg.loadPixels();
    result.loadPixels();
    for (int i = 0; i < img.pixels.length; i++) {
      int col = img.pixels[i];
      if (col == 0xFFFFFFFF) {
        result.pixels[i] = 0; // transparent pixel
      } else {
        result.pixels[i] = bImg.pixels[i]; // base image pixel
      }
    }
    result.updatePixels();
    return result;
  }

  /**
   * Erase semi-transparent pixels in PImage by setting alpha to 0
   * PImage img Input image
   * returns PImage converted to transparent
   */
  PImage eraseTransparent(PImage img) {
    PImage result;
    result = createImage(img.width, img.height, ARGB);
    img.loadPixels();
    result.loadPixels();
    for (int i = 0; i < img.pixels.length; i++) {
      int col = img.pixels[i];
      //int alpha = col & 0x000000FF;
      if (col == 0xFFFFFFFF) {
        result.pixels[i] = 0;
      } else {
        result.pixels[i] = 0xFF000000;
      }
    }
    result.updatePixels();
    return result;
  }

  /**
   * Merge mask with base image for display
   * PImage baseImg Input image
   * PImage maskImg
   * returns PImage converted to transparent
   */
  PImage mergeImages(PImage baseImg, PImage maskImg) {
    PImage result;
    result = createImage(baseImg.width, baseImg.height, ARGB);
    baseImg.loadPixels();
    maskImg.loadPixels();
    result.loadPixels();
    for (int i = 0; i < baseImg.pixels.length; i++) {
      int colb = baseImg.pixels[i];
      int colm = maskImg.pixels[i];
      if (colm == 0xFFFFFFFF) {
        result.pixels[i] = colm;
      } else {
        result.pixels[i] = colb;
      }
    }
    result.updatePixels();
    return result;
  }

  /**
   * Resize transparent PImage to a transparent PImage
   * assumes square aspect ratio
   * zoomFactor if greater than 1.0, the image is cropped along sides
   *     if less than 1.0, the image is shrunk
   * PImage img Input transparent image
   * returns PImage resized
   */
  PImage resizeTransparent(PImage img, float zoomFactor) {
    PImage result;
    PGraphics pg;

    pg = createGraphics(img.width, img.height);
    pg.beginDraw();
    float w = img.width*zoomFactor;
    float h = img.height*zoomFactor;
    float x = (img.width - w) / 2;
    float y = (img.height -h) / 2;
    pg.background(color(128, 128, 128, 0)); // transparent gray background
    pg.image(img, x, y, w, h);
    pg.endDraw();
    result = pg;
    return result;
  }

  /**
   * Make a transparent PImage
   * w width
   * h height
   * colour  color value (r, g, b, alpha)
   * returns PImage converted to transparent
   */
  PGraphics makeImageGraphics(int w, int h, color col) {
    PGraphics result=null;
    println("makeGraphics w="+w+ " h="+h+" col="+hex(col));
    try {
      result = createGraphics(w, h);
      result.beginDraw();
      result.background(col);
      result.endDraw();
    }
    catch (Exception e) {
      e.printStackTrace();
    }
    return result;
  }

  /**
   * Make a transparent PImage
   * w width
   * h height
   * colour  color value (r, g, b, alpha)
   * returns PImage converted to transparent
   */
  PImage makeImage(int w, int h, color colour) {
    PImage result;
    result = createImage(w, h, ARGB);
    result.loadPixels();
    for (int i = 0; i < result.pixels.length; i++) {
      result.pixels[i] = colour;
    }
    result.updatePixels();
    return result;
  }
}
