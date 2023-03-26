// image create with transparency
int vSpacing = 20;
int hOffset = 20;
int vOffset = 20;

void setup() {
  size(800, 400);
}

void draw() {
  noLoop();
  background(128);
  buildImage("blank", 1024, 1024, color(128, 128, 128, 255));
  buildImage("maskw", 1024, 1024, color(255, 255, 255, 0));
  buildImage("maskb", 1024, 1024, color(0, 0, 0, 0));
}

void buildImage(String name, int w, int h, color c) {
  PImage img = makeImage(w, h, c);
  String imagePath = sketchPath()+File.separator + "images"+File.separator+name+"_RGBA.png";
  img.save(imagePath);
  text("size width="+img.width + " height="+img.height, hOffset, vOffset);
  vOffset += vSpacing;
  text("saved "+imagePath, hOffset, vOffset);
  vOffset += vSpacing;
}

/**
 * Convert PImage into a transparent PImage
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
