// Text Entry and control key input handling //<>//
// Key codes serve dual purpose for commands and text entry

static final int KEYCODE_NOP = 0;
static final int KEYCODE_BACK = 4;
static final int KEYCODE_BACKSPACE = 8;
static final int KEYCODE_TAB = 9;
//static final int KEYCODE_ENTER = 10;
static final int KEYCODE_ENTER = 66; // Android
static final int KEYCODE_LF = 10;

static final int KEY_CTRL_C = 3;
static final int KEY_CTRL_D = 4;
static final int KEY_CTRL_V = 22;
static final int KEY_CTRL_Z = 26;

static final int KEYCODE_SHIFT = 16;
static final int KEYCODE_CTRL = 17;
static final int KEYCODE_ALT = 18;
static final int KEYCODE_ESC = 27;

static final int KEYCODE_SPACE = 32;
static final int KEYCODE_PAGE_UP = 33;
static final int KEYCODE_PAGE_DOWN = 34;
static final int KEYCODE_END = 35;
static final int KEYCODE_HOME = 36;
static final int KEYCODE_LEFT = 37;
static final int KEYCODE_UP = 38;
static final int KEYCODE_RIGHT = 39;
static final int KEYCODE_DOWN = 40;

static final int KEYCODE_COMMA = 44;
static final int KEYCODE_MINUS = 45;
static final int KEYCODE_PERIOD = 46;
static final int KEYCODE_SLASH = 47;
static final int KEYCODE_QUESTION_MARK = 47;
static final int KEYCODE_0 = 48;
static final int KEYCODE_1 = 49;
static final int KEYCODE_2 = 50;
static final int KEYCODE_3 = 51;
static final int KEYCODE_4 = 52;
static final int KEYCODE_5 = 53;
static final int KEYCODE_6 = 54;
static final int KEYCODE_7 = 55;
static final int KEYCODE_8 = 56;
static final int KEYCODE_9 = 57;
static final int KEYCODE_SEMICOLON = 59;
static final int KEYCODE_PLUS = 61;
static final int KEYCODE_EQUAL = 61;
static final int KEYCODE_A = 65;
static final int KEYCODE_B = 66;
static final int KEYCODE_C = 67;
static final int KEYCODE_D = 68;
static final int KEYCODE_E = 69;
static final int KEYCODE_F = 70;
static final int KEYCODE_G = 71;
static final int KEYCODE_H = 72;
static final int KEYCODE_I = 73;
static final int KEYCODE_J = 74;
static final int KEYCODE_K = 75;
static final int KEYCODE_L = 76;
static final int KEYCODE_M = 77;
static final int KEYCODE_N = 78;
static final int KEYCODE_O = 79;
static final int KEYCODE_P = 80;
static final int KEYCODE_Q = 81;
static final int KEYCODE_R = 82;
static final int KEYCODE_S = 83;
static final int KEYCODE_T = 84;
static final int KEYCODE_U = 85;
static final int KEYCODE_V = 86;
static final int KEYCODE_W = 87;
static final int KEYCODE_X = 88;
static final int KEYCODE_Y = 89;
static final int KEYCODE_Z = 90;
static final int KEYCODE_LEFT_BRACKET = 91;
static final int KEYCODE_BACK_SLASH = 92;
static final int KEYCODE_RIGHT_BRACKET = 93;

static final int KEYCODE_F1 = 112;
static final int KEYCODE_F2 = 113;
static final int KEYCODE_F3 = 114;
static final int KEYCODE_F4 = 115;
static final int KEYCODE_F5 = 116;
static final int KEYCODE_F6 = 117;
static final int KEYCODE_F7 = 118;
static final int KEYCODE_F8 = 119;
static final int KEYCODE_F9 = 120;
static final int KEYCODE_F10 = 121;
static final int KEYCODE_F11 = 122;
static final int KEYCODE_F12 = 123;

static final int KEYCODE_LEFT_BRACE = 123;
static final int KEYCODE_VERTICAL = 124;
static final int KEYCODE_RIGHT_BRACE = 125;
static final int KEYCODE_TILDE = 126;

static final int KEYCODE_DEL = 127;
static final int KEYCODE_QUOTE = 222;

static final int KEYCODE_KEYBOARD = 1000;
static final int KEYCODE_ERROR = 10000;
static final int KEY_CONTROL = 65535;

//-------------------------------------------------------------------------------------

private boolean shiftKey = false;
private boolean controlKey = false;
private boolean altKey = false;

StringBuilder promptEntry;
int promptIndex;
String[] promptList = new String[3];

static final int FILENAME_LENGTH = 60;

// store for key presses when it is time for draw() to process input key commands
volatile int lastKey;
volatile int lastKeyCode;

void keyPressed() {
  //println("key="+ key + " key10=" + int(key) + " keyCode="+keyCode);
  if (lastKeyCode == KEYCODE_ERROR) {
    return;
  } else if (keyCode >= KEYCODE_COMMA && keyCode <= KEYCODE_RIGHT_BRACKET
    || key == ' ' || keyCode == KEYCODE_QUOTE || key == '`') {
    keyCode = KEYCODE_KEYBOARD; // these keys for prompt text entry
  } else if (key==ESC) {  // prevent worker sketch exit
    key = 0; // override so that key is ignored
    keyCode = KEYCODE_ESC;
  } else if (keyCode == KEYCODE_CTRL) {
    controlKey = true;
  } else if (keyCode == KEYCODE_ALT) {
    altKey = true;
  }
  lastKey = key;
  lastKeyCode = keyCode;
}

void keyReleased() {
  if (keyCode == KEYCODE_CTRL) {
    controlKey = false;
    println("keyReleased Ctrl");
  } else if (keyCode == KEYCODE_ALT) {
    altKey = false;
    println("keyReleased Alt");
  }
}

/**
 * updateKey
 * keyboard entry and display in text area
 * return true when key consumed
 */
boolean updateKey() {
  //println("lastKey="+ lastKey + " lastKeyCode="+lastKeyCode);
  boolean status = false;

  // check for control keys
  switch(lastKey) {
  case KEY_CTRL_V:
  case KEY_CTRL_C:
  case KEY_CTRL_Z:
    lastKey = 0;
    lastKeyCode = 0;
    return status;
  case KEY_CTRL_D:
    lastKey = 0;
    lastKeyCode = 0;
    // print debug information for context
    println("debug context");
    for (int i=0; i<context.size(); i++) {
      println("context["+i+"]="+context.get(i));
    }
    return status;
  default:
    break;
  }

  switch(lastKeyCode) {
  case KEYCODE_ERROR:
    for (int i=0; i<numImages; i++) {
      imageURL[i] = "";
    }
    ready = false;
    start = false;
    break;
  case KEYCODE_LF:
    break;
  case KEYCODE_ENTER:
    if (DEBUG) println("Enter");
    prompt = promptArea.getText();
    //responseArea.setVisible(false);
    if (!start) {
      errorText = null;
      ready = false;
      for (int i=0; i<numImages; i++) saved[i] = false;
      start = true;
    }
    if (DEBUG) {
      println("ENTER promptList: ");
      for (int i=0; i<promptList.length; i++) {
        println(promptList[i]);
      }
    }
    break;
  case KEYCODE_F1:
    println("GENERATE IMAGE mode");
    createType = GENERATE_IMAGE;
    break;
  case KEYCODE_F2:
    createType = EDIT_MASK_IMAGE;
    println("EDIT IMAGE mode");
    editNewImage(receivedImage[current], maskImage, false);
    break;
  case KEYCODE_F3:
    println("EDIT embedded MASK IMAGE mode");
    createType = EDIT_EMBED_MASK_IMAGE;
    editNewImage(receivedImage[current], maskImage, true);
    break;
  case KEYCODE_F4:
    println("VARIATION  IMAGE mode");
    createType = VARIATION_IMAGE;
    break;
  case KEYCODE_F5:
    println("F5 Reload Image and Mask");
    processImageSelection();  // reload image
    processMaskSelection();  // reload mask
    break;
  case KEYCODE_F6:
    println("F6 Select Output Folder");
    selectOutputFolder();
    break;
  case KEYCODE_F7:
    println("F7 Select Last image file in a directory");
    selectHTMLServerImage();
    animation = SHOW_SPINNER;
    break;
  case KEYCODE_F8:
    println("F8 Camera Image Input");
    if (controlKey) {
      processCameraImageSelection();
    } else {
      selectCameraImage(null, null, true);
    }
    break;
  case KEYCODE_F9:
    println("F9 Select Image File");
    if (controlKey) {
      processImageSelection();  // reload image
    } else {
      selectInputImage();
    }
    break;
  case KEYCODE_F10:
    println("F10 Select Image Mask File");
    if (controlKey) {
      processMaskSelection();  // reload mask
    } else {
      selectMaskImage();
    }
    break;
  case KEYCODE_F11:
    break;
  case KEYCODE_F12:
    if (DEBUG) println("F12 screenshot command");
    screenshot = true;
    break;
  case KEYCODE_TAB:
    current++;
    if (current == numImages) current = 0;
    editImagePath = receivedImageSave[current];
    break;
  case KEYCODE_ESC:
    service.shutdownExecutor();
    exit(); // exit gracefully
    break;
  default:
    break;
  }
  lastKey = 0;
  lastKeyCode = 0;
  return status;
}
