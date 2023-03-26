/**
 *
 * Generate AI images from a text prompt using OpenAI Dall-E 2 API
 * written by Andy Modla, copyright 2023
 *
 * Sketch calls OpenAI-Java API from a Github implementation found at
 * https://github.com/TheoKanning/openai-java
 *
 * In order to use this implementation of openai-java with Processing,
 * I built the example with gradlew in info mode.
 * From the example build folders I downloaded jar files found in the -cp classpath.
 * The jar files were copied into the "code" folder.
 *
 * Help with prompts:
 * https://dallery.gallery/wp-content/uploads/2022/07/The-DALL%C2%B7E-2-prompt-book-v1.02.pdf
 
 * Keyboard Operation:
 * ESC key exit program
 * Enter key sends prompt text request to DALL-E2 service of OpenAI
 *
 * Image files received are saved in output folder with text prompt name
 */

import com.theokanning.openai.service.OpenAiService;
import com.theokanning.openai.completion.CompletionRequest;
import com.theokanning.openai.image.CreateImageRequest;
import com.theokanning.openai.*;
import java.time.Duration;

//private static final boolean DEBUG_GUI = false;
private static final boolean DEBUG_GUI = true;
private static final Duration IMAGE_TIMEOUT = Duration.ofSeconds(120);

OpenAiService service;
CreateImageRequest request;
CreateImageEditRequest editRequest;
CreateImageVariationRequest variationRequest;

String imageURL;
PImage receivedImage;
PImage previousImage;
PImage transparentImage;  //
String editImagePath = null;
String editMaskPath = null;
String filename;
String filenamePath;

int numImages = 1;
int imageSize = 1024;  // square default
String genImageSize = "1024x1024";

String promptPrefix;
String prompt;
String promptSuffix;
String requestPrompt;  // should be less than 400 characters for Dall-E 2
String saveFolder = "output";
String saveFolderPath;
String[] promptList = new String[3];

int imageCounter = 1;
boolean saved = false;
boolean start = false;
boolean ready = false;
boolean edit = false;

private static final int GENERATE_IMAGE = 0;
private static final int EDIT_IMAGE = 1;
private static final int VARIATION_IMAGE = 2;
int createType = GENERATE_IMAGE;

boolean animation = false;  // show animation while waiting for openai to respond

static final int ANIMATION_STEPS = 4;
int[] animationCounter = new int[2];
String[] animationSequence = {"|", "/", "-", "\\"};
int animationHeight = 96;
static final int SHOW_SECONDS = 0;
static final int SHOW_SYMBOLS = 1;

int statusHeight;
int promptHeight;
int errorMessageHeight;
int fontHeight;
String errorText;
StringBuilder promptEntry;
int promptIndex;
static final int FILENAME_LENGTH = 60;
PImage testImage;
String testUrl;
float appFrameRate = 30;

volatile int lastKey;
volatile int lastKeyCode;

String RENDERER = JAVA2D; // default for setup size()
EditImage editImageSketch;

void setup() {
  size(1920, 1080);
  background(128);
  fontHeight = 18;
  frameRate(appFrameRate);
  surface.setTitle("Generate Images With DALL-E2");
  // request focus on window so user does not have to press mouse key on window to get focus
  try {
    if (RENDERER.equals(P2D)) {
      ((com.jogamp.newt.opengl.GLWindow) surface.getNative()).requestFocus();  // for P2D
    } else if (RENDERER.equals(P3D)) {
      ((com.jogamp.newt.opengl.GLWindow) surface.getNative()).requestFocus();  // for P2D
    } else {
      ((java.awt.Canvas) surface.getNative()).requestFocus();  // for JAVA2D (default)
    }
  }
  catch (Exception ren) {
    println("Renderer: "+ RENDERER + " Window focus exception: " + ren.toString());
  }

  errorMessageHeight = height/2 -2*fontHeight;  // center screeen
  statusHeight = height-3*fontHeight-4;  // above prompt area

  // prompt area can display 3 lines
  // only one line used
  promptHeight = height-2*fontHeight-4; // top line
  //promptHeight = height-1*fontHeight-4; // middle line
  //promptHeight = height-0*fontHeight-4; // bottom line

  promptEntry = new StringBuilder(400);
  promptIndex = 0;
  if (DEBUG_GUI) {
    testUrl = "sunflowers_blue_vase.png";
    testImage = loadImage(testUrl);
  }

  saveFolderPath = sketchPath() + File.separator + saveFolder;
  
  // create the OPENAI API service
  // OPENAI_TOKEN is your paid account token stored in the environment variables for Windows 10/11
  String token = System.getenv("OPENAI_TOKEN");
  service = new OpenAiService(token, IMAGE_TIMEOUT);

  // initial prompt text setup
  promptPrefix = "";
  promptSuffix = "";
  prompt = "Enter prompt here.";

  // change prefix and suffix as needed, final prompt is concatenation of
  // promptPrefix + prompt + promptSuffix

  // set start flag to begin generation in the draw() animation loop
  start = false;
  
}

void draw() {
  background(128);
  textSize(fontHeight);

  // check for key or mouse input
  boolean update = updateKey();
  if (update) {
    prompt = promptEntry.toString();
    println("prompt "+prompt.length()+" ="+prompt);
  }
  noStroke();
  fill(128);
  rect(0, height - statusHeight, width, statusHeight);
  fill(255);
  text(prompt, width/128, promptHeight);
  float offset = 0;
  if (prompt.length() > 0) {
    offset  = textWidth(prompt.substring(0, promptIndex));
  }
  text("|", width/128 + offset-2, promptHeight); // cursor

  if (start && prompt.length() > 3) {
    start = false;
    saved = false;
    receivedImage = null;

    // build the request prompt string
    if (promptPrefix.equals("")) requestPrompt = prompt;
    else requestPrompt = promptPrefix + " "+ prompt;
    if (!promptSuffix.equals("")) requestPrompt +=  " " + promptSuffix;

    if (createType == EDIT_IMAGE) {
      println("\nEdit Image with prompt: " + prompt);
      editRequest = CreateImageEditRequest.builder()
        .prompt(requestPrompt)
        .n(numImages) // number of images to return
        .size(genImageSize)
        .responseFormat("url")
        .build();
    } else if (createType == GENERATE_IMAGE) {
      println("\nCreating Image with prompt: " + prompt);
      request = CreateImageRequest.builder()
        .prompt(requestPrompt)
        .n(numImages) // number of images to return
        .size(genImageSize)
        .build();
    } else if (createType == VARIATION_IMAGE) {
      println("\nVariation Image with prompt: " + prompt);
      variationRequest = CreateImageVariationRequest.builder()
        .n(numImages) // number of images to return
        .size(genImageSize)
        .responseFormat("url")
        .build();
    }

    imageURL = "";
    ready = false;
    animation = true;
    // start thread to create Image and wait for response from OpenAI in background
    if (DEBUG_GUI) {
      println("debug createImage");
      imageURL = testUrl;
      ready = true;
    } else {
      if (createType == EDIT_IMAGE) {
        editImagePath = sketchPath() + File.separator + promptList[2];
        editMaskPath = sketchPath() + File.separator + saveFolder + File.separator + promptList[1]+"_RGBA.png";
        thread("createImageEdit");
      } else if (createType == GENERATE_IMAGE) {
        thread("createImage");  // execute createImage() method in a separate thread
      } else if (createType == VARIATION_IMAGE) {
        thread("createImageVariation");
      }
    }

    // display status on screen
    fill(color(255, 0, 0));
    text("Sending Generate Image.", width/8, statusHeight);
  }

  // check if image is ready
  if (ready && !imageURL.equals("")) {
    println("\nImage is located at:");
    println(imageURL);
    // get the image in a background thread
    ready = false;
    println("requestImage="+imageURL);
    receivedImage = requestImage(imageURL);
  }

  // check for valid image before display and save
  if (receivedImage != null && receivedImage.width>0 && receivedImage.height>0) {
    animation = false;
    image(receivedImage, 0, 0, receivedImage.width, receivedImage.height);
    if (!saved) {
      println("save image");
      int length = prompt.length();
      if (length > FILENAME_LENGTH) {
        length = FILENAME_LENGTH;
      }
      StringBuilder temp = new StringBuilder(prompt.substring(0, length));
      for (int i=0; i<temp.length(); i++) {
        char c = temp.charAt(i);
        //if (c == ' ' || c == ',' || c == '\"') {
        //  temp.setCharAt(i, '_');
        //}
        if (!((c >= '0' && c <= '9') || (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z'))) {
          temp.setCharAt(i, '_');
        }
      }
      filename = temp.toString()  + "_"+ number(imageCounter);
      println("filename="+filename);
      filenamePath = saveFolder+File.separator+filename;
      println("filenamePath="+filenamePath);
      receivedImage.save(filenamePath + ".png");
      promptList[0] = prompt;
      promptList[1] = filename;
      promptList[2] = filenamePath + ".png";
      saveStrings(filenamePath + ".txt", promptList);
      imageCounter++;
      saved = true;
    }
    if (transparentImage != null) {
      image(transparentImage, 0, 0, transparentImage.width, transparentImage.height);
    }
    fill(0);
    text(requestPrompt, width/128, statusHeight);
  }

  doAnimation(animation, SHOW_SECONDS);
  //doAnimation(animation, SHOW_SYMBOLS);

  if (errorText != null) {
    fill(color(255, 0, 0));
    text(errorText, width/128, errorMessageHeight);
  }
}

// createImage called in a background thread
void createImage() {
  try {
    ready = true;
    imageURL = service.createImage(request).getData().get(0).getUrl();
  }
  catch (Exception rex) {
    errorText = "Service problem "+ rex;
    println("Service problem "+ rex);
    lastKeyCode = KEYCODE_ERROR;
    animation = false;
  }
}

// createImageEdit called in a background thread
void createImageEdit() {
  try {
    transparentImage = null;  // prevent display since we have editImagePath and new image will replace
    ready = true;
    imageURL = service.createImageEdit(editRequest, editImagePath, editMaskPath).getData().get(0).getUrl();
  }
  catch (Exception rex) {
    errorText = "Service problem "+ rex;
    println("Service problem "+ rex);
    lastKeyCode = KEYCODE_ERROR;
    animation = false;
  }
}

// createImageVariation called in a background thread
void createImageVariation() {
  try {
    ready = true;
    imageURL = service.createImageVariation(variationRequest, editImagePath).getData().get(0).getUrl();
  }
  catch (Exception rex) {
    errorText = "Service problem "+ rex;
    println("Service problem "+ rex);
    lastKeyCode = KEYCODE_ERROR;
    animation = false;
  }
}

/**
 * Convert PImage to a transparent PImage
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
 * Perform animation while waiting for OpenAI
 * status true for animation on
 * select type of animation
 */
void doAnimation(boolean status, int select) {
  if (status) {
    fill(color(0, 0, 255));
    textSize(animationHeight);
    switch(select) {
    case 0:
      int seconds = animationCounter[select]/int(appFrameRate);
      String working0 = str(seconds) + " ... \u221e" ;  // infinity
      text(working0, imageSize/2- textWidth(working0)/2, height/2);
      animationCounter[select]++;
      break;
    case 1:
      String working1 = animationSequence[animationCounter[select]]; // Symbol sequence
      text(working1, imageSize/2 - textWidth(working1)/2, height/2);
      animationCounter[select]++;
      if (animationCounter[select] >= ANIMATION_STEPS) animationCounter[select] = 0;
      break;
    default:
      break;
    }
  } else {
    animationCounter[select] = 0;
  }
}

//------------------------------------------------------------------------------------


// Add leading zeroes to number
String number(int index) {
  // fix size of index number at 4 characters long
  //  if (index == 0)
  //    return "";
  if (index < 10)
  return ("000" + String.valueOf(index));
  else if (index < 100)
  return ("00" + String.valueOf(index));
  else if (index < 1000)
  return ("0" + String.valueOf(index));
  return String.valueOf(index);
}
