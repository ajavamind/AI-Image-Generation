
/**
 * Use jvm-openai API for OpenAI
 * https://github.com/StefanBratanov/jvm-openai/releases/tag/v0.11.0
 * Example code to generate images with dall-e-2, dall-e-3, and gpt-image-1 models
 * includes examples for model listings, chat and supporting methods, etc.
 * also uses model gpt-4.1 for testing.
 
 * Assumes 4K monitor for display
 */

import java.net.URI;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import java.time.Duration;
import java.lang.System;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Enumeration;
import java.util.Locale;
import java.io.IOException;
import java.net.URI;
import java.util.Base64;
import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.awt.image.BufferedImage;
import javax.imageio.ImageIO;
import java.nio.file.Path;
import java.nio.file.Paths;
import io.github.stefanbratanov.jvm.openai.*;
import io.github.stefanbratanov.jvm.openai.OpenAI;

private static final Duration IMAGE_TIMEOUT = Duration.ofSeconds(180);
PImage urlImg;
PImage[] pimg;
int current = 0;
int numImages = 2;
int elapsedTime = 0;
int FRAME_RATE = 30;

PImage pimgFromB64;
PImage testImage;
OpenAI openAI;
String prompt="An acrylic painting of a bouquet of twelve yellow roses.";
String revisedPrompt;
String testFilename= "testFilename";

void setup() {
  size(3072, 1536);
  //size(2048, 1536);
  //size(2048, 1024);
  //size(1536, 1024);
  //size(1024,1024);
  background(128);
  frameRate(FRAME_RATE);
  openAI = OpenAI.newBuilder(System.getenv("OPENAI_API_KEY"))
    .requestTimeout(IMAGE_TIMEOUT)
    //.organization("OPENAI_ORG_ID")
    .build();

  //test();

  thread("testImageGptimage1");
  
  //testPath();
  //thread("testEditImageGptimage1");
  //thread("testEditMaskImageGptimage1");

  //thread("testEditMergeImageGptimage1");
  //thread("testEditPhotoGptimage1");
}

void testPath() {
  println(sketchPath() + File.separator + testFilename+"_"+current+".png");
}

void test() {
  // Test simple chat connection
  String prompt = "Who won the world series in 2020?";
  ChatClient chatClient = openAI.chatClient();
  CreateChatCompletionRequest createChatCompletionRequest = CreateChatCompletionRequest.newBuilder()
    .model("gpt-4.1")
    .message(ChatMessage.userMessage(prompt))
    .build();
  ChatCompletion chatCompletion = chatClient.createChatCompletion(createChatCompletionRequest);
  println(chatCompletion.choices().get(0));
  System.out.println("Prompt: "+ prompt);
  System.out.println("Result: "+chatCompletion.choices().get(0).message().content());
}

void testImageGptimage1() {
  String sDate = getDateTime();
  prompt = "generate a random subject realistic photo for today "+ sDate +". Make it relevant and colorful";
  String filename = "IFT_"+sDate;
  ImagesClient imagesClient = openAI.imagesClient();
  CreateImageRequest createImageRequest = CreateImageRequest.newBuilder()
    .model("gpt-image-1")
    .prompt(prompt)
    .n(numImages)
    .outputCompression(100)
    .outputFormat("png")
    .quality("medium")
    .size("1024x1024")
    .build();
  Images images = imagesClient.createImage(createImageRequest);

  getImages(images, filename, "");

}

void testEditImageGptimage1() {
  // gpt-image-1 model only
  prompt = "change rose petal color to white with blue streaks. place bouquet in a blue vase.";
  String filename = "testImage";
  numImages = 1;
  //Path currentDir = Paths.get(".");
  //System.out.println(currentDir);
  String sPath = sketchPath() + File.separator + "input" + File.separator + filename+".png";
  testImage = loadImage(sPath);
  Path path = Paths.get(sPath);
  //System.out.println("image path="+path);
  ImagesClient imagesClient = openAI.imagesClient();
  EditImageRequest editImageRequest = EditImageRequest.newBuilder()
    .image(path)
    .model("gpt-image-1")
    //.model("dall-e-2")
    .prompt(prompt)
    .n(numImages)
    //.quality("medium")  // causes error with gpt-image-1
    //.responseFormat("b64_json")  // causes error with gpt-image-1
    //.size("1024x1024") // causes error with gpt-image-1
    .build();
  Images images = null;
  try {
    images = imagesClient.editImage(editImageRequest);
  }
  catch (Exception e) {
    println("Exception Error: ");
    println(e);
    println();
  }

  getImages(images, filename, "_edited"+ getDateTime());
}

void testEditPhotoGptimage1() {
  // gpt-image-1 model only
  prompt = "Modify this photo of a boy and girl sculpture looking at a mobile phone instead of a book. keep photo realistic";
  String filename = "readers_l";
  numImages = 4;
  //Path currentDir = Paths.get(".");
  //System.out.println(currentDir);
  String sPath = sketchPath() + File.separator + "input" + File.separator + filename+".png";
  testImage = loadImage(sPath);
  Path path = Paths.get(sPath);
  //System.out.println("image path="+path);
  ImagesClient imagesClient = openAI.imagesClient();
  EditImageRequest editImageRequest = EditImageRequest.newBuilder()
    .image(path)
    .model("gpt-image-1")
    //.model("dall-e-2")
    .prompt(prompt)
    .n(numImages)
    //.quality("medium")  // causes error with gpt-image-1
    //.responseFormat("b64_json")  // causes error with gpt-image-1
    //.size("1024x1024") // causes error with gpt-image-1
    .build();
  Images images = null;
  try {
    images = imagesClient.editImage(editImageRequest);
  }
  catch (Exception e) {
    println("Exception Error: ");
    println(e);
    println();
  }

  getImages(images, filename, "_edit_"+ getDateTime());
}

void testEditMergeImageGptimage1() {
  // gpt-image-1 model only
  prompt = "Merge stereoscopic left and right images into a red and cyan anaglyph image.";
  String filenameLeft = "readers_l.png";
  String filenameRight = "readers_r.png";
  numImages = 1;
  //Path currentDir = Paths.get(".");
  //System.out.println("currentDir="+currentDir);
  String lsPath = sketchPath() + File.separator + "input" + File.separator + filenameLeft;
  String rsPath = sketchPath() + File.separator + "input" + File.separator + filenameRight;
  testImage = loadImage(lsPath);
  Path[] path = new Path[2];
  path[0] = Paths.get(lsPath);
  path[1] = Paths.get(rsPath);
  //System.out.println("image path="+path);
  ImagesClient imagesClient = openAI.imagesClient();
  EditImageRequest editImageRequest = EditImageRequest.newBuilder()
    .image(path)
    .model("gpt-image-1")
    //.model("dall-e-2")
    .prompt(prompt)
    .n(numImages)
    //.quality("medium")  // causes error with gpt-image-1
    //.responseFormat("b64_json")  // causes error with gpt-image-1
    //.size("1024x1024") // causes error with gpt-image-1
    .build();
  Images images = null;
  try {
    images = imagesClient.editImage(editImageRequest);
  }
  catch (Exception e) {
    println("Exception Error: ");
    println(e);
    println();
  }

  getImages(images, "readers", "_anaglyph_"+ getDateTime());
}

void testEditMaskImageGptimage1() {
  // gpt-image-1 model only
  prompt = "perform a photo realistic fill on all transparent pixels of this photo. use adjacent pixels for the fill. ";
  String filename = "maskImage2";
  String maskFilename = "maskImage2";
  numImages = 1;
  //Path currentDir = Paths.get(".");
  //System.out.println("currentDir="+currentDir);
  String sPath = sketchPath() + File.separator + "input" + File.separator + filename+".png";
  String msPath = sketchPath() + File.separator + "input" + File.separator + maskFilename+".png";
  testImage = loadImage(sPath);
  Path path = Paths.get(sPath);
  Path mPath = Paths.get(msPath);
  //System.out.println("image path="+path);
  ImagesClient imagesClient = openAI.imagesClient();
  EditImageRequest editImageRequest = EditImageRequest.newBuilder()
    .image(path)
    .model("gpt-image-1")
    //.model("dall-e-2")
    .prompt(prompt)
    .n(numImages)
    .mask(mPath)
    //.quality("medium")  // causes error with gpt-image-1
    //.responseFormat("b64_json")  // causes error with gpt-image-1
    //.size("1024x1024") // causes error with gpt-image-1 unknown parameter
    .build();
  Images images = null;
  try {
    images = imagesClient.editImage(editImageRequest);
  }
  catch (Exception e) {
    println("Exception Error: ");
    println(e);
    println();
  }

  // Get the images from the list
  getImages(images, filename, "_mask_"+ getDateTime());
}

void getImages(Images images, String filename, String suffix) {
  // Get the images from the list
  pimg = new PImage[numImages];
  if (images != null) {
    for (int i=0; i<numImages; i++) {
      Images.Image img = images.data().get(i);
      pimg[i] = loadPImage(img);
      if (pimg[i] != null) {
        pimg[i].save(sketchPath() + File.separator + "output" + File.separator + filename+ suffix + ".png");
      }
      // Extract revisedPrompt
      revisedPrompt = img.revisedPrompt();
      if (revisedPrompt != null) println("Revised Prompt: " + i +" "+revisedPrompt);
    }
  } else {
    println("images null");
  }
}

// Load PImage from base64 JSON
PImage loadPImage(Images.Image img) {
  PImage pimgFromB64 = null;
  String b64Json = img.b64Json();
  if (b64Json != null && !b64Json.isEmpty()) {
    try {
      // Decode base64 string to bytes
      byte[] imageBytes = Base64.getDecoder().decode(b64Json);
      // Convert bytes to InputStream
      InputStream in = new ByteArrayInputStream(imageBytes);
      // Read BufferedImage from InputStream
      BufferedImage bimg = ImageIO.read(in);
      // Convert BufferedImage to PImage
      pimgFromB64 = bufferedToPImage(bimg);
    }
    catch (Exception e) {
      e.printStackTrace();
    }
  }
  return pimgFromB64;
}

// Function to convert BufferedImage to PImage
PImage bufferedToPImage(BufferedImage bimg) {
  if (bimg == null) return null;
  PImage pimg = new PImage(bimg.getWidth(), bimg.getHeight(), ARGB);
  bimg.getRGB(0, 0, bimg.getWidth(), bimg.getHeight(), pimg.pixels, 0, bimg.getWidth());
  pimg.updatePixels();
  return pimg;
}

void draw() {
  background(128);
  textSize(48);
  if (urlImg != null) {
    image(urlImg, 0, 0);
  } else if (pimg != null && pimg[current] != null) {
    image(pimg[current], 0, 0);
    text(str(elapsedTime), 40, height-80);
  } else {
    elapsedTime = int(frameCount/FRAME_RATE);
    text("Working Elapsed Time (seconds) "+ elapsedTime, 40, height/2);
  }
  if (testImage != null) {
    image(testImage, width/2, 0);
  }
}

// save sketch frame with space bar
void keyPressed() {
  if (key == ' ') {
    String dateTime = getDateTime();
    String filename = dateTime+"_GptImage1";
    pimg[current].save(sketchPath() + File.separator + "output" + File.separator + filename+"_"+current+".png");
    String[] revision = new String[1];
    if (revisedPrompt != null) {
      revision[0] = revisedPrompt;
    } else {
      revision[0] = prompt;
    }
    saveStrings(sketchPath() + File.separator + "output" + File.separator + filename+".txt", revision);
  } else if (key == 'n') {
    current++;
    if (current >= numImages) current = 0;
  }
}

String getDateTime() {
  Date current_date = new Date();
  String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss", Locale.US).format(current_date);
  return timeStamp;
}
