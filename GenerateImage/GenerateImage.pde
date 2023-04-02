/**
 *
 * Generate AI images from a text prompt using OpenAI Dall-E 2 API
 * written by Andy Modla, copyright 2023
 *
 * Sketch calls OpenAI-Java API from a Github implementation found at
 * https://github.com/TheoKanning/openai-java
 *
 * In order to use this implementation of openai-java with Processing,
 * I built a modified example from openai-java with gradlew in info mode.
 * From the example build folders I downloaded jar files found in the -cp classpath.
 * The jar files were copied into the "code" folder.
 *
 * Help with prompts:
 * https://dallery.gallery/wp-content/uploads/2022/07/The-DALL%C2%B7E-2-prompt-book-v1.02.pdf
 
 * Keyboard Operation:
 * ESC key exit program
 * Enter key sends text prompt request to DALL-E2 service of OpenAI
 *
 *  OPENAI_TOKEN is your paid account token stored in the environment variables for Windows 10/11
 *
 * Image files received are saved in a default output folder with text prompt for filename
 */

import com.theokanning.openai.service.OpenAiService;
import com.theokanning.openai.completion.CompletionRequest;
import com.theokanning.openai.image.CreateImageRequest;
import com.theokanning.openai.*;
import java.time.Duration;

private static final boolean DEBUG_GUI = false;
//private static final boolean DEBUG_GUI = true;
private static final boolean DEBUG = true;  // Log println on Processing SDK console
private static final Duration IMAGE_TIMEOUT = Duration.ofSeconds(120); // seconds

OpenAiService service;
CreateImageRequest request;
CreateImageEditRequest editRequest;
CreateImageVariationRequest variationRequest;

PImage receivedImage;
PImage maskImage;  // mask
String imageURL;

String editImagePath = null;
String editMaskPath = null;
String filename;
String filenamePath;

int numImages = 1; // number of images requested from openai service
int imageSize = 1024;  // square default working size and aspect ratio
String genImageSize = "1024x1024";
// note image type is png

String promptPrefix;
String prompt;
String promptSuffix;
String requestPrompt;  // should be less than 400 characters for Dall-E 2
String saveFolder = "output"; // default output folder location relative to sketch path
String saveFolderPath; // full path to save folder

String[] promptList = new String[3];
//promptList[0] = prompt;
//promptList[1] = filename;
//promptList[2] = filenamePath + ".png";

int imageCounter = 1;
boolean saved = false;
boolean start = false;
boolean ready = false;
boolean edit = false;

private static final int GENERATE_IMAGE = 0;
private static final int EDIT_IMAGE = 1;
private static final int EDIT_MASK_IMAGE = 2;
private static final int VARIATION_IMAGE = 3;
int createType = GENERATE_IMAGE; // type of image creation request

// animation section
boolean animation = false;  // flag to control animation while waiting for openai to respond
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
float appFrameRate = 30; // draw frames per second

// store for key presses when it is time for draw() to process input key commands
volatile int lastKey;
volatile int lastKeyCode;

String RENDERER = JAVA2D; // default for setup size()
EditMaskImage editImageSketch; // mask image editor

/**
 * sketch setup
 */
void setup() {
  size(1920, 1080);
  background(128);   // light gray
  fontHeight = 18;
  frameRate(appFrameRate);
  setTitle("Generate Images With OpenAI DALL-E2 API");

  // request focus on window so user does not have to press mouse key on window to get focus
  // a quirk fix for processing sketches in Java on Windows
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

  // prompt text area can display 3 lines
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

  saveFolderPath = sketchPath() + File.separator + saveFolder; // default on start

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

  openFileSystem();
}

/**
 * Main sketch draw loop
 */
void draw() {
  background(128);
  textSize(fontHeight);

  // check for key or mouse input and process on this draw thread
  boolean update = updateKey();
  if (update) {
    prompt = promptEntry.toString();
    //println("prompt "+prompt.length()+" ="+prompt);
  }

  // show prompt text on display
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

  // check is prompt length is minimum size
  if (start && prompt.length() > 3) {
    start = false;
    saved = false;
    receivedImage = null;

    // build the request prompt string from prompt prefix and suffix
    if (promptPrefix.equals("")) requestPrompt = prompt;
    else requestPrompt = promptPrefix + " "+ prompt;
    if (!promptSuffix.equals("")) requestPrompt +=  " " + promptSuffix;

    // build the request to OpenAI with the prompt depending on createType
    if (createType == EDIT_IMAGE || createType == EDIT_MASK_IMAGE) {
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
    animation = true; // allow animatins while waiting for OpenAI response to request
    
    // start thread to create Image and wait for response from OpenAI
    if (!DEBUG_GUI) {
      if (createType == EDIT_IMAGE) {
        editMaskPath = editImageSketch.saveMask(saveFolderPath + File.separator + promptList[1]+"_RGBA.png", false);
        thread("createImageEdit"); // execute createImageEdit() method in a separate thread
      } else if (createType == EDIT_MASK_IMAGE) {
        editImagePath = editImageSketch.saveMask(saveFolderPath + File.separator + promptList[1]+"_RGBA.png", true);
        editMaskPath = null;  // ignore because mask was embedded in original image editImagePath
        thread("createImageEdit");  // execute createImageEdit() method in a separate thread
      } else if (createType == GENERATE_IMAGE) {
        thread("createImage");  // execute createImage method in a separate thread
      } else if (createType == VARIATION_IMAGE) {
        thread("createImageVariation"); // execute createImageVariation method in a separate thread
      }
    } else { // DEBUG_GUI
      println("debug createImage");
      imageURL = testUrl;
      ready = true;
    }

    // display status on screen
    fill(color(255, 0, 0));
    text("Sending Generate Image.", width/8, statusHeight);
  }

  // check if image is ready
  if (ready && !imageURL.equals("")) {
    println("\nImage is located at:");
    // get the image in a background thread
    ready = false;
    println("requestImage="+imageURL);
    receivedImage = requestImage(imageURL);
  }

  // check for valid image received before display and save
  if (receivedImage != null && receivedImage.width>0 && receivedImage.height>0) {
    animation = false;
    image(receivedImage, 0, 0, receivedImage.width, receivedImage.height);
    if (!saved) {
      int length = prompt.length();
      if (length > FILENAME_LENGTH) {
        length = FILENAME_LENGTH;
      }
      StringBuilder temp = new StringBuilder(prompt.substring(0, length));
      for (int i=0; i<temp.length(); i++) {
        char c = temp.charAt(i);
        if (!((c >= '0' && c <= '9') || (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z'))) {
          temp.setCharAt(i, '_');
        }
      }
      filename = temp.toString()  + "_"+ number(imageCounter);
      println("save image filename="+filename);
      filenamePath = saveFolderPath+File.separator+filename;
      println("save received image filenamePath="+filenamePath+ ".png");
      receivedImage.save(filenamePath + ".png");
      promptList[0] = prompt;
      promptList[1] = filename;
      promptList[2] = filenamePath + ".png";
      editImagePath = promptList[2];
      saveStrings(filenamePath + ".txt", promptList);
      imageCounter++;
      saved = true;
    }
    fill(0);
    if (requestPrompt != null) text(requestPrompt, width/128, statusHeight);
  }

  doAnimation(animation, SHOW_SECONDS);  // elapsed time animation
  //doAnimation(animation, SHOW_SYMBOLS); // spinner

  // show any errors from the request
  if (errorText != null) {
    fill(color(255, 0, 0));
    text(errorText, width/128, errorMessageHeight);
  }
}

//---------------------------------------------------------------------------
// creation image threads

// createImage called in a background thread
void createImage() {
  println("createImage()");
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
  println("createImageEdit()");
  println("editImagePath="+editImagePath);
  println("editMaskPath="+editMaskPath);
  try {
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
  println("createImageVariation()");
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

//--------------------------------------------------------------------
// 
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
 * Perform animation while waiting for OpenAI
 * status true for animation on
 * select type of animation
 */
void doAnimation(boolean status, int selectAnimation) {
  if (status) {
    fill(color(0, 0, 255));
    textSize(animationHeight);
    switch(selectAnimation) {
    case 0:
      int seconds = animationCounter[selectAnimation]/int(appFrameRate);
      String working0 = str(seconds) + " ... \u221e" ;  // infinity
      text(working0, imageSize/2- textWidth(working0)/2, height/2);
      animationCounter[selectAnimation]++;
      break;
    case 1:
      String working1 = animationSequence[animationCounter[selectAnimation]]; // Symbol sequence
      text(working1, imageSize/2 - textWidth(working1)/2, height/2);
      animationCounter[selectAnimation]++;
      if (animationCounter[selectAnimation] >= ANIMATION_STEPS) animationCounter[selectAnimation] = 0;
      break;
    default:
      break;
    }
  } else {
    animationCounter[selectAnimation] = 0;
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
