// Graphical User Interface components
// Uses G4P contributed Processing library (only runs with Windows Java)

import g4p_controls.*;
import java.awt.Font;

static final String TITLE = "Generate Images With OpenAI DALL-E2 API";
static final String SUBTITLE = "";
static final String INITIAL_PROMPT = "Enter prompt here. Use ESC key to exit. ";
static final String VERSION_NAME = "1.0";
static final String VERSION_CODE = "1";
static final String CREDITS = "Written by Andy Modla";
static final String COPYRIGHT = "Copyright 2023 Andrew Modla";
static String VERSION = "Version "+VERSION_NAME +" Number "+VERSION_CODE;


GButton generateButton;
GButton clearButton;
//GButton runButton;
//GButton runJButton;
//GButton saveFolderButton;
//GButton chatButton;
//GButton chatSketchButton;
GTextArea promptArea;
GTextArea responseArea;

int WIDTH;
int HEIGHT;
int PROMPT_X;
int PROMPT_Y;
int RESPONSE_X;
int RESPONSE_Y;
int PROMPT_WIDTH;
int PROMPT_HEIGHT;
int RESPONSE_WIDTH;
int RESPONSE_HEIGHT;
int GENERATE_BUTTON_X;
int GENERATE_BUTTON_Y;
int GENERATE_BUTTON_WIDTH;
int GENERATE_BUTTON_HEIGHT;
int CLEAR_BUTTON_X;
int CLEAR_BUTTON_Y;
int CLEAR_BUTTON_WIDTH;
int CLEAR_BUTTON_HEIGHT;
int RUN_BUTTON_X;
int RUN_BUTTON_Y;
int RUN_BUTTON_WIDTH;
int RUN_BUTTON_HEIGHT;
int RUNJ_BUTTON_X;
int RUNJ_BUTTON_Y;
int RUNJ_BUTTON_WIDTH;
int RUNJ_BUTTON_HEIGHT;
int SAVE_FOLDER_BUTTON_X;
int SAVE_FOLDER_BUTTON_Y;
int SAVE_FOLDER_BUTTON_WIDTH;
int SAVE_FOLDER_BUTTON_HEIGHT;
int CHAT_BUTTON_X;
int CHAT_BUTTON_Y;
int CHAT_BUTTON_WIDTH;
int CHAT_BUTTON_HEIGHT;
int CHAT_SKETCH_BUTTON_X;
int CHAT_SKETCH_BUTTON_Y;
int CHAT_SKETCH_BUTTON_WIDTH;
int CHAT_SKETCH_BUTTON_HEIGHT;

// animation variables section
static final int ANIMATION_STEPS = 4;
int[] animationCounter = new int[3];
String[] animationSequence = {"|", "/", "-", "\\"};
int animationHeight = 96;  // font height
static final int NO_ANIMATION = 0;
static final int SHOW_SECONDS = 1;
static final int SHOW_SPINNER = 2;
int animation = NO_ANIMATION;  // flag to control animation while waiting for a thread like openai-api to respond

void initGUI() {
  fontHeight = 18; //24;

  //RESPONSE_WIDTH = (3*width) / 4;
  RESPONSE_WIDTH = 1024;
  RESPONSE_HEIGHT = height - 3*fontHeight;
  RESPONSE_X = 0;
  RESPONSE_Y = 0;

  PROMPT_WIDTH = 1024; //(3*width)/4;
  //PROMPT_HEIGHT = 5 * fontHeight;
  PROMPT_HEIGHT = 3 * fontHeight;
  PROMPT_X = 0;
  PROMPT_Y = height - PROMPT_HEIGHT;

  G4P.setMouseOverEnabled(true);
  promptArea = new GTextArea(this, PROMPT_X, PROMPT_Y, PROMPT_WIDTH, PROMPT_HEIGHT, G4P.SCROLLBARS_NONE, PROMPT_WIDTH-3*int(textWidth("W")));
  promptArea.setFont(new Font("Arial", Font.BOLD, fontHeight));
  promptArea.setPromptText(INITIAL_PROMPT);
  promptArea.setOpaque(true);

  GENERATE_BUTTON_WIDTH = (width - PROMPT_WIDTH)/2;
  GENERATE_BUTTON_HEIGHT = 3 * fontHeight;
  GENERATE_BUTTON_X = PROMPT_WIDTH + 1;
  GENERATE_BUTTON_Y = height - PROMPT_HEIGHT;

  CLEAR_BUTTON_WIDTH = (width - PROMPT_WIDTH)/2;
  CLEAR_BUTTON_HEIGHT = 3 * fontHeight;
  CLEAR_BUTTON_X = PROMPT_WIDTH + 1 + CLEAR_BUTTON_WIDTH;
  CLEAR_BUTTON_Y = height - PROMPT_HEIGHT;

  generateButton = new GButton(this, GENERATE_BUTTON_X, GENERATE_BUTTON_Y, GENERATE_BUTTON_WIDTH, GENERATE_BUTTON_HEIGHT, "Generate");
  generateButton.tag = "Button:  Generate";
  generateButton.setOpaque(true);

  Font buttonFont = new Font("Arial", Font.BOLD, 2*fontHeight);
  generateButton.setFont(buttonFont);
  clearButton = new GButton(this, CLEAR_BUTTON_X, CLEAR_BUTTON_Y, CLEAR_BUTTON_WIDTH, CLEAR_BUTTON_HEIGHT, "Clear");
  clearButton.tag = "Button:  Clear";
  clearButton.setOpaque(true);
  clearButton.setFont(buttonFont);

  setTitle(TITLE);
}

public void handleTextEvents(GEditableTextControl textcontrol, GEvent event) {
  /* code */
  //if (DEBUG) println(event.toString());
  if (event.toString().equals("LOST_FOCUS")) {
  }
}

public void handleButtonEvents(GButton button, GEvent event) {
  // Folder selection
  if (button == generateButton && event == GEvent.CLICKED) {
    println("Button Generate pressed");
    lastKey = 0;
    lastKeyCode = KEYCODE_ENTER;
  //} else if (button == runButton && event == GEvent.CLICKED) {
  //  println("Button Run pressed");
  //  lastKey = 0;
  //  lastKeyCode = KEYCODE_F10;
  //} else if (button == runJButton && event == GEvent.CLICKED) {
  //  println("Button Run pressed");
  //  lastKey = 0;
  //  lastKeyCode = KEYCODE_F11;
  //} else if (button == chatButton && event == GEvent.CLICKED) {
  //  println("Button Chat pressed");
  //  lastKey = 0;
  //  lastKeyCode = KEYCODE_F2;
  //} else if (button == chatSketchButton && event == GEvent.CLICKED) {
  //  println("Button Chat Sketch pressed");
  //  lastKey = 0;
  //  lastKeyCode = KEYCODE_F4;
  } else if (button == clearButton && event == GEvent.CLICKED) {
    println("Button Clear pressed");
    promptArea.setText("");
  //} else if (button == saveFolderButton && event == GEvent.CLICKED) {
  //  println("saveFolder selection pressed");
    //lastKey = 0;
    //lastKeyCode = KEYCODE_F9;
  }
}
/**
 * Perform animation while waiting for a thread to complete
 * selectAnimation type of animation
 */
void doAnimation(int selectAnimation) {
  fill(color(0, 0, 255));
  textSize(animationHeight);
  String working;
  switch(selectAnimation) {
  case SHOW_SECONDS:
    int seconds = animationCounter[selectAnimation]/int(appFrameRate);
    working = str(seconds) + " ... \u221e" ;  // infinity
    text(working, RESPONSE_WIDTH/2- textWidth(working)/2, RESPONSE_HEIGHT/2);
    animationCounter[selectAnimation]++;
    break;
  case SHOW_SPINNER:
    working = animationSequence[animationCounter[selectAnimation]]; // Symbol sequence
    text(working, RESPONSE_WIDTH/2 - textWidth(working)/2, RESPONSE_HEIGHT/2);
    animationCounter[selectAnimation]++;
    if (animationCounter[selectAnimation] >= ANIMATION_STEPS) animationCounter[selectAnimation] = 0;
    break;
  default:
    animationCounter[0] = 0;
    animationCounter[1] = 0;
    animationCounter[2] = 0;
    break;
  }
}

void showIntroductionScreen() {
  if (showIntroduction) {
    //println("Introduction Screen");
    int introTextSize = 24;
    int vstart = 60;
    int voffset = vstart + introTextSize;
    int hstart = 10;
    int hoffset = hstart;

    textAlign(LEFT);
    textSize(introTextSize);
    fill(color(255, 128, 128));

    text(TITLE, hoffset, voffset);
    voffset += introTextSize;
    text(SUBTITLE, hoffset, voffset);
    voffset += introTextSize;
    text(VERSION, hoffset, voffset);
    voffset += introTextSize;
    text(CREDITS, hoffset, voffset);
    voffset += introTextSize;
    text(COPYRIGHT, hoffset, voffset);
    voffset += introTextSize;
  }
}
