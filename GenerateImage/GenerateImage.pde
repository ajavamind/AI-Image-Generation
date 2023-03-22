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

private static final boolean DEBUG_GUI = false;
private static final Duration IMAGE_TIMEOUT = Duration.ofSeconds(120);

OpenAiService service;
CreateImageRequest request;

String imageURL;
PImage img;
int imageSize = 1024;

String promptPrefix;
String prompt;
String promptSuffix;
String requestPrompt;  // should be less than 400 characters for Dall-E 2
String saveFolder = "output";
String[] promptList = new String[2];
int imageCounter = 1;
boolean saved = false;
boolean start = false;
boolean ready = false;
boolean animation = false;  // while waiting for openai to respond

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
PImage testImg;
String testUrl;

volatile int lastKey;
volatile int lastKeyCode;

void setup() {
  size(1920, 1080);
  background(128);
  fontHeight = 18;

  surface.setTitle("Generate Images With DALL-E2");
  // request focus on window so user does not have to press mouse key on window to get focus
  String RENDERER = JAVA2D; // default for size()
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
    println("Renderer: "+RENDERER+ " Window focus exception: " + ren.toString());
  }

  errorMessageHeight = height -4;
  statusHeight = height-fontHeight-4;
  promptHeight = height-2*fontHeight-4;
  promptEntry = new StringBuilder(400);
  promptIndex = 0;
  if (DEBUG_GUI) {
    testUrl = "sunflowers_blue_vase.png";
    testImg = loadImage(testUrl);
  }

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
    println("\nCreating Image for prompt: " + prompt);
    saved = false;
    img = null;

    // build the request prompt string
    if (promptPrefix.equals("")) requestPrompt = prompt;
    else requestPrompt = promptPrefix + " "+ prompt;
    if (!promptSuffix.equals("")) requestPrompt +=  " " + promptSuffix;
    request = CreateImageRequest.builder()
      .prompt(requestPrompt)
      .build();

    imageURL = "";
    ready = false;
    animation = true;
    // start thread to create Image and wait for response from OpenAI in background
    if (DEBUG_GUI) {
      println("debug createImage");
      imageURL = testUrl;
      ready = true;
    } else {
      thread("createImage");  // execute createImage() method in a separate thread
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
    img = requestImage(imageURL);
  }

  // check for valid image before display and save
  if (img != null && img.width>0 && img.height>0) {
    animation = false;
    image(img, 0, 0, img.width, img.height);
    if (!saved) {
      println("save image");
      int length = prompt.length();
      if (length > FILENAME_LENGTH) {
        length = FILENAME_LENGTH;
      }
      String filename = prompt.substring(0, length).replaceAll(" ", "_");
      String filenamePath = saveFolder+File.separator+filename + "_"+ number(imageCounter);
      img.save(filenamePath + ".png");
      promptList[0] = prompt;
      promptList[1] = filenamePath + ".png";
      saveStrings(filenamePath + ".txt", promptList);
      imageCounter++;
      saved = true;
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
      int seconds = animationCounter[select]/int(frameRate);
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
