/**
 *
 * Generate AI images from a text prompt using OpenAI Dall-E2 API
 * Written by Andy Modla, copyright 2023
 * Currently coded to run in Processing SDK for Java on Windows
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
 * ESC key exit program or give focus to main window GenerateImage
 * Enter key sends text prompt request to DALL-E2 service of OpenAI
 *
 *  OPENAI_TOKEN is your paid account token stored as an environment variable for Windows 10/11
 *
 * Image files received are saved in a default output folder with a shortened text prompt used as the filename
 */


private static final boolean DEBUG_GUI = false;
//private static final boolean DEBUG_GUI = true; // prevents invoking OpenAI service
private static final boolean DEBUG = true;  // Log println on Processing SDK console

PImage[] receivedImage; // images downloaded from ImageResult following a request
String[] receivedImageSave; // the filenames where images downloaded from ImageResult following a request are saved
int current = 0;  // index for receivedImage main display
PImage maskImage;  // mask
String[] imageURL;  // image URL from result data response

String editImagePath = null;
String editMaskPath = null;
String filename;
String filenamePath;

//String promptPrefix;
String prompt;
//String promptSuffix;
String requestPrompt;  // should be less than 400 characters for Dall-E 2

String sessionDateTime;
int imageCounter = 1;
boolean[] saved;
boolean showIntroduction = true;
boolean start = false;
boolean ready = false;
boolean edit = false;
boolean screenshot = false;
int screenshotCounter = 1;

private static final String MODE = "Mode: ";
private static final int GENERATE_IMAGE = 0;
private static final int EDIT_MASK_IMAGE = 1;
private static final int EDIT_EMBED_MASK_IMAGE = 2;
private static final int VARIATION_IMAGE = 3;
private static final String GENERATE_IMAGE_DESC = "F1 - Generate Image";
private static final String EDIT_MASK_IMAGE_DESC = "F2 - Edit Mask";
private static final String EDIT_EMBED_MASK_IMAGE_DESC = "F3 - Edit Embedded Mask";
private static final String VARIATION_IMAGE_DESC = "F4 - Generate Variation";
int createType = GENERATE_IMAGE; // type of image creation request


int statusHeight;
int promptHeight;
int errorMessageHeight;
int fontHeight;
String errorText;
PImage testImage;
String testUrl;

float appFrameRate = 30; // draw frames per second
String RENDERER = JAVA2D; // default for setup size()

GenerateImage generateImageSketch; // main sketch window
EditMaskImage editImageSketch; // mask image editor sketch window
UvcCameraInputImage cameraImageSketch; // camera input sketch window

/**
 * sketch setup
 */
void setup() {
  size(1920, 1080, RENDERER);
  //size(2560, 1440, RENDERER);
  background(128);   // light gray
  initGUI();
  
  frameRate(appFrameRate);
  generateImageSketch = this;
  sessionDateTime = getDateTime();

  getFocus();

  errorMessageHeight = height/2 -2*fontHeight;  // center screeen
  statusHeight = height-3*fontHeight-4;  // above prompt area

  // prompt text area can display 3 lines
  // only one line used
  promptHeight = height-2*fontHeight-4; // top line

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

  receivedImage = new PImage[NUM_DISPLAY];
  receivedImageSave = new String[NUM_DISPLAY];
  imageURL = new String[NUM_DISPLAY];
  saved = new boolean[NUM_DISPLAY];
  for (int i=0; i<numImages; i++) saved[i] = false;
  current = 0;

  // set start flag to begin generation in the draw() animation loop
  start = false;

  openFileSystem();
} // setup

/**
 * Main sketch draw loop
 */
void draw() {
  background(128);  // light gray

  // check for key or mouse input and process on this draw thread
  boolean update = updateKey();
  if (update) {
    prompt = promptEntry.toString();
    //println("prompt "+prompt.length()+" ="+prompt);
  }

  // show prompt text on display
  textSize(fontHeight);

  // check is prompt length is minimum size
  if (start && prompt.length() > 3) {
    start = false;
    for (int i=0; i<numImages; i++) saved[i] = false;
    for (int i=0; i<numImages; i++) {
      receivedImage[i] = null;
    }

    requestPrompt =  prompt;
    // build the request to OpenAI with the prompt depending on createType
    if (createType == EDIT_MASK_IMAGE || createType == EDIT_EMBED_MASK_IMAGE) {
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
    for (int i=0; i<numImages; i++) {
      imageURL[i] = "";
    }
    ready = false;
    animation = SHOW_SECONDS; // allow animation while waiting for OpenAI response to request

    // start thread to create Image and wait for response from OpenAI DallE2
    if (!DEBUG_GUI) {
      switch(createType) {
      case GENERATE_IMAGE:
        thread("createImage");  // execute createImage method in a separate thread
        break;
      case EDIT_MASK_IMAGE:
        editMaskPath = editImageSketch.saveMask(saveFolderPath + File.separator + sessionDateTime + "_" + promptList[1]+"_RGBA.png", false);
        thread("createImageEdit"); // execute createImageEdit() method in a separate thread
        break;
      case EDIT_EMBED_MASK_IMAGE:
        editImagePath = editImageSketch.saveMask(saveFolderPath + File.separator + sessionDateTime + "_" + promptList[1]+"_RGBA.png", true);
        editMaskPath = null;  // ignore because mask was embedded in original image editImagePath
        thread("createImageEdit");  // execute createImageEdit() method in a separate thread
        break;
      case VARIATION_IMAGE:
        thread("createImageVariation"); // execute createImageVariation method in a separate thread
        break;
      default:
        break;
      };
    } else { // DEBUG_GUI
      println("debug createImage");
      for (int i=0; i<numImages; i++) {
        imageURL[i] = testUrl;
      }
      switch(createType) {
      case GENERATE_IMAGE:
        //thread("createImage");  // execute createImage method in a separate thread
        break;
      case EDIT_MASK_IMAGE:
        editMaskPath = editImageSketch.saveMask(saveFolderPath + File.separator + sessionDateTime + "_" + promptList[1]+"_RGBA.png", false);
        //thread("createImageEdit"); // execute createImageEdit() method in a separate thread
        break;
      case EDIT_EMBED_MASK_IMAGE:
        editImagePath = editImageSketch.saveMask(saveFolderPath + File.separator + sessionDateTime + "_" + promptList[1]+"_RGBA.png", true);
        editMaskPath = null;  // ignore because mask was embedded in original image editImagePath
        //thread("createImageEdit");  // execute createImageEdit() method in a separate thread
        break;
      case VARIATION_IMAGE:
        //thread("createImageVariation"); // execute createImageVariation method in a separate thread
        break;
      default:
        break;
      };
      ready = true;
    }

  }

  // check if image is ready
  if (ready && !imageURL[0].equals("")) {
    println("\nImage is located at:");
    // get the image in a background thread
    ready = false;
    current = 0;
    for (int i=0; i<numImages; i++) {
      println("requestImage["+i+"]="+imageURL[i]);
      receivedImage[i] = requestImage(imageURL[i]);
    }
  }

  // check for valid image received before save
  for (int j=0; j<numImages; j++) {
    if (receivedImage[j] != null && receivedImage[j].width>0 && receivedImage[j].height>0) {
      if (!saved[j]) {
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
        filenamePath = saveFolderPath+File.separator+ sessionDateTime + "_" +filename;
        String name = filenamePath + ".png";
        println("save received image filenamePath="+name);
        receivedImage[j].save(name);
        receivedImageSave[j] = name;
        promptList[0] = prompt;
        promptList[1] = filename;
        promptList[2] = filenamePath + ".png";
        editImagePath = promptList[2];
        saveStrings(filenamePath + ".txt", promptList);
        imageCounter++;
        saved[j] = true;
      }
    }
  }

  // check for valid image received before display and save
  if (receivedImage[current] != null && receivedImage[current].width>0 && receivedImage[current].height>0) {
    animation = NO_ANIMATION;
    showIntroduction = false;
    image(receivedImage[current], 0, 0, receivedImage[current].width, receivedImage[current].height);
    //fill(0);
    //if (requestPrompt != null) text(requestPrompt, width/128, statusHeight);
  } else {
    showIntroductionScreen();
  }

  // display all images received as large thumbnails
  // check for valid image received before display
  int num = NUM_DISPLAY;
  
  for (int i=0; i<num; i++) {
    if (receivedImage[i] != null && receivedImage[i].width>0 && receivedImage[i].height>0) {
      // temporary code, TO DO make layout flexible
      image(receivedImage[i], 1024 + (i%2)*448, 128+(i/2)*448, 448, 448);
      if (DEBUG) {
        textSize(4*fontHeight);
        //text(str(i), 1024+224 + (i%2)*448, 128+224+(i/2)*448);
      }
    }
  }

  // Show mode in information section
  fill(192);
  rect(1024, 0, 896, 128);

  fill(color(255, 0, 255));
  textSize(2*fontHeight);
  int x = 1024+10;
  int y = fontHeight+10;
  switch(createType) {
  case GENERATE_IMAGE:
    text(MODE+GENERATE_IMAGE_DESC, x, y);
    break;
  case EDIT_MASK_IMAGE:
    text(MODE+EDIT_MASK_IMAGE_DESC, x, y);
    break;
  case EDIT_EMBED_MASK_IMAGE:
    text(MODE+EDIT_EMBED_MASK_IMAGE_DESC, x, y);
    break;
  case VARIATION_IMAGE:
    text(MODE+VARIATION_IMAGE_DESC, x, y);
    break;
  default:
    text("Generate Image Mode Internal Error", x, y);
    break;
  };

  // Update animation if active
  doAnimation(animation);

  // show any errors from the request
  showError(errorText);

  // Drawing finished, check for screenshot command request
  saveScreenshot();
} // draw

void showError(String str) {
  if (str != null) {
    fill(color(255, 128, 0));
    textSize(2*fontHeight);
    int leng = str.length();
    int i = 0;
    int k = 1;
    while (i<leng) {
      if ((leng -i)<80) {
        text(str.substring(i), width/128, k*2*fontHeight+errorMessageHeight);
        break;
      } else {
        text(str.substring(i, i+80), width/128, k*2*fontHeight+errorMessageHeight);
      }
      i+= 80;
      k++;
    }
  }
}
//---------------------------------------------------------------------------
// creation image threads

// createImage called in a background thread
void createImage() {
  println("createImage()");
  try {
    ready = true;
    ImageResult result = service.createImage(request);
    for (int i=0; i<numImages; i++) {
      imageURL[i] = result.getData().get(i).getUrl();
    }
  }
  catch (Exception rex) {
    errorText = "Service problem "+ rex;
    println("Service problem "+ rex);
    lastKeyCode = KEYCODE_ERROR;
    animation = NO_ANIMATION;
  }
}

// createImageEdit called in a background thread
void createImageEdit() {
  println("createImageEdit() "+editImagePath +" " + editMaskPath);
  try {
    ready = true;
    ImageResult result = service.createImageEdit(editRequest, editImagePath, editMaskPath);
    for (int i=0; i<numImages; i++) {
      imageURL[i] = result.getData().get(i).getUrl();
    }
  }
  catch (Exception rex) {
    errorText = "Service problem "+ rex;
    println("Service problem "+ rex);
    lastKeyCode = KEYCODE_ERROR;
    animation = NO_ANIMATION;
  }
}

// createImageVariation called in a background thread
void createImageVariation() {
  println("createImageVariation() "+ editImagePath);
  try {
    ready = true;
    ImageResult result = service.createImageVariation(variationRequest, editImagePath);
    for (int i=0; i<numImages; i++) {
      imageURL[i] = result.getData().get(i).getUrl();
    }
  }
  catch (Exception rex) {
    errorText = "Service problem "+ rex;
    println("Service problem "+ rex);
    lastKeyCode = KEYCODE_ERROR;
    animation = NO_ANIMATION;
  }
}

void processImageSelection() {
  if (imageSelection != null) {
    editImagePath = imageSelection.getAbsolutePath();
    promptList[1] = editImagePath.substring(editImagePath.lastIndexOf(File.separator)+1);
    current = 0;
    for (int i=0; i<numImages; i++) {
      receivedImage[i] = null;
      saved[i] = false;
      imageURL[i] = "";
    }
    saved[current] = true;
    receivedImage[current] = loadImage(editImagePath); // TODO before resize and save file to png
    if (DEBUG) println("editImagePath="+editImagePath);
    if (DEBUG) println("selectImageFile: "+promptList[1]);
  }
}
