import processing.core.PApplet;

public class EditImage extends PApplet {

  PImage baseImage;
  PImage zoomImage;
  PImage maskImage;
  PGraphics workImage;
  PImage editImage;
  boolean erase = true;
  String saveFolder;
  boolean editReady = false;
  int editKey;
  int editKeyCode;
  int brushWidth;

  void settings() {
    size(1024, 1024);
  }

  void init(PImage img, String outputFolder) {
    brushWidth = 32;
    println("Edit Imageinit ");
    baseImage = img.copy();
    println("copy ");
    editImage = makeTransparent(baseImage);
    workImage = makeImageGraphics(baseImage.width, baseImage.height, color(0, 0, 0, 0));
    saveFolder = outputFolder;
    println("saveFolder="+outputFolder);
    editReady = true;
  }

  void stop() {
    editReady = false;
    baseImage = null;
  }

  void draw() {
    if (!editReady) {
      text("Waiting for Image to edit.", width/2, height/2);
      return;
    }
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
      workImage.strokeWeight(brushWidth);
      workImage.line(mx, my, pmx, pmy);
    }
    workImage.endDraw();
    maskImage = mergeImages(baseImage, workImage);
    image(maskImage, 0, 0);
    fill(255);
    noStroke();
    circle(mx, my, brushWidth); // show brush at mouse coordinates
    updateEditKey();
  }

  boolean updateEditKey() {
    boolean consumed = true;
    switch (editKeyCode) {
    case KEYCODE_S:
      String path = saveFolder + File.separator + promptList[1] + "_RGBA.png";
      maskImage.save(path);
      println("saved mask "+ path);
      break;
    case KEYCODE_X:
      erase = !erase;
      break;
    case KEYCODE_RIGHT_BRACKET:
      brushWidth += 4;
      if (brushWidth >= 256) brushWidth = 256;
      break;
    case KEYCODE_LEFT_BRACKET:
      brushWidth -= 4;
      if (brushWidth <= 4) brushWidth = 4;
      break;
    case KEYCODE_PLUS: // zoom in
      //transparentImage = resizeTransparent(receivedImage, 0.5);
      //transparentImage.save(sketchPath() + File.separator + saveFolder + File.separator + "transparentImage_0.50.png");
      break;
    case KEYCODE_MINUS: // zoom out
      //transparentImage = resizeTransparent(receivedImage, 0.5);
      //transparentImage.save(sketchPath() + File.separator + saveFolder + File.separator + "transparentImage_0.50.png");
      break;
    default:
      break;
    }
    editKeyCode = 0;
    editKey = 0;
    return consumed;
  }

  void keyPressed() {
    println("EditImage key="+ key + " key10=" + int(key) + " keyCode="+keyCode);
    editKey = key;
    editKeyCode = keyCode;
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
  PImage eraseTransparent(PImage img) {
    PImage result;
    result = createImage(img.width, img.height, ARGB);
    img.loadPixels();
    result.loadPixels();
    for (int i = 0; i < img.pixels.length; i++) {
      int col = img.pixels[i];
      int alpha = col & 0x000000FF;
      if (alpha <= 128) {
        result.pixels[i] = col & 0xFFFFFF00;
      } else {
        result.pixels[i] = img.pixels[i];
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
        result.pixels[i] = 0;
      } else {
        result.pixels[i] = colb;
      }
    }
    result.updatePixels();
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
