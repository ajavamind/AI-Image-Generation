/**
 * Edit Image
 *
 * creates a mask PImage
 */
PImage baseImage;
PImage maskImage;
PGraphics workImage;
PImage editImage;
boolean erase = true;

void setup() {
  size(1024, 1024);
  background(128);
  baseImage = loadImage("sunflowers_blue_vase.png");
  editImage = makeTransparent(baseImage);
  workImage = makeEditGraphics(baseImage.width, baseImage.height, color(0, 0, 0, 0));
  //workImage = makeEditGraphics(baseImage.width, baseImage.height, color(255, 255, 255, 255));
}

void draw() {
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
    workImage.strokeWeight(32);
    workImage.line(mx, my, pmx, pmy);
  }
  workImage.endDraw();
  maskImage = mergeImages(baseImage, workImage);
  image(maskImage, 0, 0);
  fill(255);
  noStroke();
  if (mousePressed == true) {
    circle(mx, my, 32);
  }
  if (keyPressed) {
    if (key == ' ') {
      //maskImage = mergeImages(baseImage, workImage);
      maskImage.save("mask.png");
      println("saved mask.png");
    } else if (key == 'x') {
      erase = !erase;
    }
  }
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
PGraphics makeEditGraphics(int w, int h, color col) {
  PGraphics result;
  result = createGraphics(w, h);
  result.beginDraw();
  result.background(col);
  result.endDraw();
  return result;
}

/**
 * Make a transparent PImage
 * w width
 * h height
 * colour  color value (r, g, b, alpha)
 * returns PImage converted to transparent
 */
PImage makeTransparentImage(int w, int h, color colour) {
  PImage result;
  result = createImage(w, h, ARGB);
  result.loadPixels();
  for (int i = 0; i < result.pixels.length; i++) {
    result.pixels[i] = colour;
  }
  result.updatePixels();
  return result;
}
