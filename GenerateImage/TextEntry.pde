// Text Entry GUI

static final int KEYCODE_NOP = 0;
static final int KEYCODE_BACK = 4;
static final int KEYCODE_BACKSPACE = 8;
static final int KEYCODE_TAB = 9;
static final int KEYCODE_ENTER = 10;

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

static final int KEYCODE_DEL = 127;
static final int KEYCODE_QUOTE = 222;

static final int KEYCODE_KEYBOARD = 1000;
static final int KEYCODE_ERROR = 10000;
static final int KEY_CONTROL = 65535;

//-------------------------------------------------------------------------------------

// mouse Click to request another image generation using the same prompt
//void mouseClicked() {
//  if (lastKeyCode == KEYCODE_ERROR) {
//    return;
//  }
//  lastKeyCode = KEYCODE_ENTER;
//}

//void mousePressed() {
//  if (!edit) {
//    String[] sketchName = {"EditImage"};
//    if (editImageSketch == null) {
//      editImageSketch = new EditImage();
//      runSketch(sketchName, editImageSketch);
//      edit = true;
//    }
//  }
//}

void keyPressed() {
  println("key="+ key + " key10=" + int(key) + " keyCode="+keyCode);
  if (lastKeyCode == KEYCODE_ERROR) {
    return;
  } else if (keyCode >= KEYCODE_COMMA && keyCode <= KEYCODE_RIGHT_BRACKET
    || key == ' ' || keyCode == KEYCODE_QUOTE ) {
    lastKey = key;
    lastKeyCode = KEYCODE_KEYBOARD; // these keys for prompt text entry
  } else {
    lastKey = key;
    lastKeyCode = keyCode;
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
  switch(lastKeyCode) {
  case KEYCODE_ERROR:
    imageURL = "";
    ready = false;
    start = false;
    break;
  case KEYCODE_ENTER:
    if (!start) {
      errorText = null;
      ready = false;
      saved = false;
      start = true;
    }
    break;
  case KEYCODE_F1:
    println("Key enter GENERATE IMAGE mode");
    createType = GENERATE_IMAGE;
    break;
  case KEYCODE_F2:
    createType = EDIT_IMAGE;
    println("Key enter EDIT IMAGE mode");
    editNewImage();
    break;
  case KEYCODE_F3:
    println("Key enter EDIT MASK IMAGE mode");
    createType = EDIT_MASK_IMAGE;
    editNewImage();
    break;
  case KEYCODE_F4:
    println("Key enter VARIATION  IMAGE mode");
    createType = VARIATION_IMAGE;
    break;
  case KEYCODE_TAB:
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
  default:
    break;
  }
  lastKey = 0;
  lastKeyCode = 0;
  return status;
}

void editNewImage() {
  if (receivedImage != null) {
    if (!edit) {
      String[] sketchName = {"EditImage"};
      if (editImageSketch == null) {
        editImageSketch = new EditImage();
        runSketch(sketchName, editImageSketch);
        editImageSketch.init(receivedImage, saveFolderPath);
        edit = true;
      }
    } else {
      editImageSketch.init(receivedImage, saveFolderPath);
    }
  }
}
  
  void addKey(char aKey) {
    promptEntry.insert(promptIndex, aKey);
    promptIndex++;
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

  import java.awt.Toolkit;
  import java.awt.datatransfer.Clipboard;
  import java.awt.datatransfer.DataFlavor;
  import java.awt.datatransfer.StringSelection;
  import java.awt.datatransfer.Transferable;
  import java.awt.datatransfer.UnsupportedFlavorException;

  void test() {
    // copy text to the clipboard in Java:
    StringSelection stringSelection = new StringSelection("Text to copy to clipboard");
    Clipboard clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();
    clipboard.setContents(stringSelection, null);

    //To paste text from the clipboard

    clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();
    Transferable contents = clipboard.getContents(null);
    if (contents != null && contents.isDataFlavorSupported(DataFlavor.stringFlavor)) {
      String text="";
      try {
        text = (String) contents.getTransferData(DataFlavor.stringFlavor);
      }
      catch (Exception ufe) {
        text = "";
      }
      System.out.println(text);
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
