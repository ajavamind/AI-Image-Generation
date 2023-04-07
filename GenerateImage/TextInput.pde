// Text Entry and control key input handling //<>//
// Key codes serve dual purpose for commands and text entry

static final int KEYCODE_NOP = 0;
static final int KEYCODE_BACK = 4;
static final int KEYCODE_BACKSPACE = 8;
static final int KEYCODE_TAB = 9;
static final int KEYCODE_ENTER = 10;

static final int KEY_CTRL_C = 3;
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

void keyPressed() {
  println("key="+ key + " key10=" + int(key) + " keyCode="+keyCode);
  if (lastKeyCode == KEYCODE_ERROR) {
    return;
  } else if (keyCode >= KEYCODE_COMMA && keyCode <= KEYCODE_RIGHT_BRACKET
    || key == ' ' || keyCode == KEYCODE_QUOTE ) {
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
    pasteClipboard();
    status = true;
    lastKey = 0;
    lastKeyCode = 0;
    return status;
  case KEY_CTRL_C:
    copyText();
    status = true;
    lastKey = 0;
    lastKeyCode = 0;
    return status;
  case KEY_CTRL_Z:
    // TODO
    status = true;
    lastKey = 0;
    lastKeyCode = 0;
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
  case KEYCODE_ENTER:
    if (!start) {
      errorText = null;
      ready = false;
      for (int i=0; i<numImages; i++) saved[i] = false;
      start = true;
    }
    println("promptList: ");
    for (int i=0; i<promptList.length; i++) {
      println(promptList[i]);
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
    println("F5 Unused");
    break;
  case KEYCODE_F6:
    println("Select Output Folder");
    selectOutputFolder();
    break;
  case KEYCODE_F7:
    println("F7 Unused");
    break;
  case KEYCODE_F8:
    println("Camera Image Input");
    if (controlKey) {
      processCameraImageSelection();
    } else {
      selectCameraImage(null, null, true);
    }
    break;
  case KEYCODE_F9:
    println("Select Image File");
    if (controlKey) {
      processImageSelection();  // reload image
    } else {
      selectInputImage();
    }
    break;
  case KEYCODE_F10:
    println("Select Image Mask File");
    if (controlKey) {
      processMaskSelection();  // reload mask
    } else {
      selectMaskImage();
    }
    break;
  case KEYCODE_F11:
    break;
  case KEYCODE_F12:
    if (DEBUG) println("screenshot command");
    screenshot = true;
    break;
  case KEYCODE_TAB:
    current++;
    if (current == numImages) current = 0;
    break;
  case KEYCODE_KEYBOARD:
    addKey(char(lastKey));
    status = true;
    break;
  case KEYCODE_DEL:
    deleteNext();
    status = true;
    break;
  case KEYCODE_BACKSPACE:
    deletePrevious();
    status = true;
    break;
  case KEYCODE_LEFT:
    if (promptIndex> 0) {
      promptIndex--;
    }
    break;
  case KEYCODE_RIGHT:
    if (promptIndex < promptEntry.length()) {
      promptIndex++;
    }
    break;
  case KEYCODE_HOME:
    promptIndex = 0;
    break;
  case KEYCODE_END:
    promptIndex = promptEntry.length();
    break;
  case KEYCODE_ESC:
    exit(); // exit gracefully
    break;
  default:
    break;
  }
  lastKey = 0;
  lastKeyCode = 0;
  return status;
}

// TODO
//String[] args ={this.toString()};  //Need to attach current name which is stripped by the new sketch
//String[] newArgs = {name, str(handle)};
//SecondApplet sa = new SecondApplet();
//PApplet.runSketch(concat(args, newArgs), sa);

void editNewImage(PImage inputImage, PImage maskImage, boolean embed) {
  if (inputImage != null) {
    if (!edit) {
      String[] sketchName = {"Edit Mask Image"};
      if (editImageSketch == null) {
        editImageSketch = new EditMaskImage();
        runSketch(sketchName, editImageSketch);
        editImageSketch.init(inputImage, maskImage, embed);
        edit = true;
      }
    } else {
      editImageSketch.init(inputImage, maskImage, embed);
    }
  }
}

void selectCameraImage(PImage inputImage, PImage maskImage, boolean embed) {
  if (inputImage == null) {
    String[] sketchName = {"Camera Input"};
    if (cameraImageSketch == null) {
      cameraImageSketch = new CameraInputImage();
      runSketch(sketchName, cameraImageSketch);
      cameraImageSketch.init(inputImage, maskImage, embed);
    } else {
      cameraImageSketch.getSurface().setVisible(true);  // get focus for CameraInput
    }
  } else {
    cameraImageSketch.init(inputImage, maskImage, embed);
  }
}


void addKey(char aKey) {
  promptEntry.insert(promptIndex, aKey);
  promptIndex++;
}

void addString(String str) {
  promptEntry.insert(promptIndex, str);
  promptIndex += str.length();
}

void undoString(String str) {  // TODO
  //promptEntry.insert(promptIndex, str);
  // promptIndex -= str.length();
}

void deleteNext() {
  if (promptIndex < promptEntry.length()) {
    promptEntry.deleteCharAt(promptIndex);
  }
}

void deletePrevious() {
  if (promptEntry.length() > 0) {
    promptIndex--;
    if (promptIndex < 0) {
      promptIndex++;
    } else {
      promptEntry.deleteCharAt(promptIndex);
    }
  }
}

//-------------------------------------------------------------------------------------

import java.awt.Toolkit;
import java.awt.datatransfer.Clipboard;
import java.awt.datatransfer.DataFlavor;
import java.awt.datatransfer.StringSelection;
import java.awt.datatransfer.Transferable;
import java.awt.datatransfer.UnsupportedFlavorException;

// copy text to the clipboard in Java:
void copyText() {
  StringSelection stringSelection = new StringSelection(prompt);
  Clipboard clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();
  clipboard.setContents(stringSelection, null);
}

// paste text from the clipboard
void pasteClipboard() {
  Clipboard clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();
  Transferable contents = clipboard.getContents(null);
  if (contents != null && contents.isDataFlavorSupported(DataFlavor.stringFlavor)) {
    String text="";
    try {
      text = (String) contents.getTransferData(DataFlavor.stringFlavor);
      text = text.replaceAll("\n", "   ");
    }
    catch (Exception ufe) {
      text = "";
    }
    println("paste clipboard "+ text);
    addString(text);
  }
}



//-------------------------------------------------------------------

// Work in progress

public class TextEntry {
  int x, y; // top left corner of keyboard entry area
  int w, h; // width and height of keyboard entry area
  int inset; // space between left border to start of text

  color backgnd = color(128, 128, 128);
  color fillText = color(255, 255, 255);

  public TextEntry(int x, int y, int w, int h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    inset = w/128;
  }

  public void clear() {
    noStroke();
    fill(backgnd);
    rect(x, y, w, h);
    fill(fillText);
  }
}
