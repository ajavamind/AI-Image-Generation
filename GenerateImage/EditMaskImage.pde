// This sketch creates a mask image for request
// Runs in separate window
// ESC key shifts focus back to main window

import processing.core.PApplet; // sketch top class

public class EditMaskImage extends PApplet {

  PImage baseImage;
  PImage zoomImage;
  PImage maskImage;
  PGraphics workImage; // mask working copy
  PImage editImage;
  boolean erase = true;
  boolean editReady = false;
  boolean zoom = false;
  int editKey;
  int editKeyCode;
  int brushSize;
  int transparency = 255;
  
  private static final int MAX_BRUSH_SIZE = 256;
  private static final int MIN_BRUSH_SIZE = 4;
  private static final int BRUSH_SIZE_STEP = 4;
  private static final float MAX_ZOOM = 2.0;
  private static final float MIN_ZOOM = 0.25;
  private static final float ZOOM_STEP = 0.125;
  private static final float NO_ZOOM = 1.0;
  float zoomFactor = NO_ZOOM;

  void settings() {
    // size matches DALLE response size
    size(1024, 1024);  // default renderer JAVA2D
  }

  void setup() {
    if (DEBUG) println("EditMaskImage setup()");
    //setTitle(args[0]);  // TODO
  }

  /**
   * initialize this instance of EditMaskImage
   */
  void init(PImage img, PImage mImg, boolean embedMask) {
    stop();
    zoomImage = null;
    zoom = false;
    zoomFactor = NO_ZOOM;
    brushSize = 32;
    baseImage = img.copy();
    println("Edit Mask Image init ");
    editImage = makeTransparent(baseImage);
    workImage = makeImageGraphics(baseImage.width, baseImage.height, color(0, 0, 0, 0));
    if (mImg != null) {
      workImage.loadPixels();
      mImg.loadPixels();
      for (int i=0; i<mImg.pixels.length; i++) {
        // replace transparent area of image with opaque white representing the mask
        if ((mImg.pixels[i] & (transparency << 24)) == 0) {
          workImage.pixels[i] = color(255, 255, 255, transparency);
        }
      }
      workImage.updatePixels();
      //workImage.save(saveFolderPath + File.separator+"amasktest.png");
      //println("save amasktest.png");
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
        workImage.stroke(color(255, 255, 255, transparency)); // write white opague representing the mask
      } else {
        workImage.stroke(color(0,0,0, transparency)); // write fully transparent pixels
      }
      workImage.strokeWeight(brushSize);
      workImage.line(mx, my, pmx, pmy);
    }
    workImage.endDraw();
    if (zoomImage == null) {
      maskImage = mergeImages(baseImage, workImage);
    } else {
      maskImage = mergeImages(zoomImage, workImage);
    }
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
    if (zoom) {  //
      if (DEBUG) println("maskImage w="+maskImage.width+ " h="+maskImage.height);
      temp = eraseTransparent(maskImage, zoomImage);
      temp.save(path);
      if (DEBUG) println("save embedded mask: "+ path);
    } else {
      temp = eraseTransparent(maskImage, baseImage);
      temp.save(path);
      if (DEBUG) println("save transparent mask "+ path);
    }
    return path;
  }

  /**
   * process key commands
   */
  boolean updateEditKey() {
    boolean consumed = false;
    switch (editKeyCode) {
    case KEYCODE_ESC:
      generateImageSketch.surface.setVisible(true);  // give focus back to main sketch
      break;
    case KEYCODE_X: // alternate between erase and restore mask brush
      erase = !erase;
      break;
    case KEYCODE_I: // invert mask
      invertMask(workImage);
      erase = !erase; // invert brush
      break;
      
    case KEYCODE_RIGHT_BRACKET: // increase brush size
      brushSize += BRUSH_SIZE_STEP;
      if (brushSize >= MAX_BRUSH_SIZE) brushSize = MAX_BRUSH_SIZE;
      break;
    case KEYCODE_LEFT_BRACKET:  // reduce brush size
      brushSize -= BRUSH_SIZE_STEP;
      if (brushSize <= MIN_BRUSH_SIZE) brushSize = MIN_BRUSH_SIZE;
      break;
      
    case KEYCODE_RIGHT_BRACE: // transparency
      transparency += 1;
      if (transparency > 255) transparency = 255;
      break;
    case KEYCODE_LEFT_BRACE:  // reduce transparency
      transparency -= 1;
      if (transparency < 0) transparency = 0;
      break;
      
    case KEYCODE_PLUS: // zoom in
      if (createType == EDIT_EMBED_MASK_IMAGE) {
        if (zoomFactor < MAX_ZOOM) {
          zoomFactor += ZOOM_STEP;
          zoomImage = resizeTransparent(baseImage, zoomFactor);
          zoom = true;
          workImage = makeMask(zoomImage);
        }
      }
      break;
    case KEYCODE_MINUS: // zoom out
      if (createType == EDIT_EMBED_MASK_IMAGE) {
        if (zoomFactor > MIN_ZOOM) {
          zoomFactor -= ZOOM_STEP;
          zoomImage = resizeTransparent(baseImage, zoomFactor);
          zoom = true;
          workImage = makeMask(zoomImage);
        }
      }
      break;
      
    case KEYCODE_D:
      if (DEBUG_GUI) {
        String mpath = sketchPath()+File.separator+"1masktest.png";
        if (DEBUG) println(mpath);
        saveMask(mpath, true);
      }
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
    if (key==ESC) {  // prevent worker sketch exit
      key = 0; // override so that key is ignored
      keyCode = KEYCODE_ESC;
    }
    editKey = key;
    editKeyCode = keyCode;
    if (DEBUG) println("EditImage key="+ editKey + " key10=" + int(editKey) + " keyCode="+editKeyCode);
  }

  /**
   * Invert the mask and brush
   */
  void invertMask(PGraphics img) {
    img.loadPixels();
    for (int i=0; i<img.pixels.length; i++) {
      if (img.pixels[i] == 0xFFFFFFFF) {
        img.pixels[i] = color(0,0,0, transparency); //0x00000000;
      } else {
        img.pixels[i] = color(255,255,255, transparency);  //0xFFFFFFFF;
      }
    }
    img.updatePixels();
  }

  /**
   * Create a new mask using PImage with transparent pixels
   */
  PGraphics makeMask(PImage img) {
    PGraphics pg = makeImageGraphics(baseImage.width, baseImage.height, color(0, 0, 0, 0));
    img.loadPixels();
    pg.loadPixels();
    for (int i=0; i<img.pixels.length; i++) {
      // replace transparent area of image with opaque white representing the mask
      //if ((img.pixels[i] & 0xFF000000) == 0) {
      //  pg.pixels[i] = color(255, 255, 255, 255);
      //}
      if ((img.pixels[i] & (transparency << 24)) == 0) {
        pg.pixels[i] = color(255, 255, 255, 255);
      }
    }
    pg.updatePixels();
    return pg;
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

  ///**
  // * Erase semi-transparent pixels in PImage by setting alpha to 0
  // * PImage img Input image
  // * returns PImage converted to transparent
  // */
  //PImage eraseTransparent(PImage img) {
  //  PImage result;
  //  result = createImage(img.width, img.height, ARGB);
  //  img.loadPixels();
  //  result.loadPixels();
  //  for (int i = 0; i < img.pixels.length; i++) {
  //    int col = img.pixels[i];
  //    if (col == 0xFFFFFFFF) {
  //      result.pixels[i] = 0;
  //    } else {
  //      result.pixels[i] = 0xFF000000;
  //    }
  //  }
  //  result.updatePixels();
  //  return result;
  //}

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
   * Make a transparent PGraphics
   * w width
   * h height
   * colour  color value (r, g, b, alpha)
   * returns PImage converted to transparent
   */
  PGraphics makeImageGraphics(int w, int h, color col) {
    PGraphics result=null;
    println("makeImageGraphics w="+w+ " h="+h+" col="+hex(col));
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

//  /**
//   * Make a transparent PImage
//   * w width
//   * h height
//   * colour  color value (r, g, b, alpha)
//   * returns PImage converted to transparent
//   */
//  PImage makeImage(int w, int h, color colour) {
//    PImage result;
//    result = createImage(w, h, ARGB);
//    result.loadPixels();
//    for (int i = 0; i < result.pixels.length; i++) {
//      result.pixels[i] = colour;
//    }
//    result.updatePixels();
//    return result;
//  }

}
