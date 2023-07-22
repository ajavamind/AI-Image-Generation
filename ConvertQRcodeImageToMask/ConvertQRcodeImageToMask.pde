// convert a QR code image into a transparent mask based on color value
// used to make white or green areas transparent
// experimental

PImage qrImg;
PImage result;
// input QR image must be 1024 x 1024
String filename = "qrcode.url.png";
int saveCounter = 0;

void setup() {
  size(1024, 1024);
  qrImg = loadImage(filename);
  println("image.width="+qrImg.width+ " image.height="+qrImg.height);
}

void draw() {
  background(color(255, 0, 0));
  if (result != null) {
    image(result, 0, 0, width, height);
  } else {
    image(qrImg, 0, 0, width, height);
  }
}

/**
 * Convert PImage into a transparent PImage
 * PImage img Input image
 * returns PImage converted to transparent
 */
PImage makeColorTransparent(PImage img, int colorThreshold, int opaqueBarcode, int transparentBackground) {
  PImage result;
  result = createImage(img.width, img.height, ARGB);
  img.loadPixels();
  result.loadPixels();
  for (int i = 0; i < img.pixels.length; i++) {
    if (brightness(img.pixels[i]) <= brightness(colorThreshold)) {
      result.pixels[i] = opaqueBarcode;  // all black opaque
    } else {
      result.pixels[i] = transparentBackground;  // make transparent alpha white
    }
  }
  result.updatePixels();
  return result;
}


void keyPressed() {
  println("keyCode="+keyCode);
  switch(keyCode) {
  case 32:  // space bar
    println("result w="+result.width + " h="+result.height);
    if (result != null) {
      saveCounter++;
    result.save(nf(saveCounter)+ filename.substring(0, filename.lastIndexOf("."))+".png");
    }
    break;    
  case 48: // 0 key
    result = makeColorTransparent(qrImg, color(32), 0xFF000000, 0x00FFFFFF);
    break;
  case 49: // 1 key
    result = makeColorTransparent(qrImg, color(32), 0xFF808080, 0x00FFFFFF);
    break;
  case 50: // 2 key
    result = makeColorTransparent(qrImg, color(32), 0xFF808080, 0x00000000);
    break;
  default:
    break;
  }
}
