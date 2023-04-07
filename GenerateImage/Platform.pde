// Java or Android platform build
// Accounts for code differences between Android and Java sketch builds
// Android mode not working in progress
//

private final static int JAVA_MODE = 0;
private final static int ANDROID_MODE = 1;
int buildMode = JAVA_MODE;  // change manually for the build

// ***** Important Comment Out the unused platform code below

//// Android Platform Build Mode
//import android.content.SharedPreferences;
//import android.preference.PreferenceManager;
//import android.content.Context;
//import android.graphics.Bitmap;
//import android.app.Activity;
//import select.files.*;

//boolean grantedRead = false;
//boolean grantedWrite = false;

//SelectLibrary files;

//void openFileSystem() {
//  requestPermissions();
//  files = new SelectLibrary(this);
//}

//void setTitle(String str) {
//}

//public void onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults) {
//  println("onRequestPermissionsResult "+ requestCode + " " + grantResults + " ");
//  for (int i=0; i<permissions.length; i++) {
//    println(permissions[i]);
//  }
//}

//void requestPermissions() {
//  if (!hasPermission("android.permission.READ_EXTERNAL_STORAGE")) {
//    requestPermission("android.permission.READ_EXTERNAL_STORAGE", "handleRead");
//  }
//  if (!hasPermission("android.permission.WRITE_EXTERNAL_STORAGE")) {
//    requestPermission("android.permission.WRITE_EXTERNAL_STORAGE", "handleWrite");
//  }
//}

//void handleRead(boolean granted) {
//  if (granted) {
//    grantedRead = granted;
//    println("Granted read permissions.");
//  } else {
//    println("Does not have permission to read external storage.");
//  }
//}

//void handleWrite(boolean granted) {
//  if (granted) {
//    grantedWrite = granted;
//    println("Granted write permissions.");
//  } else {
//    println("Does not have permission to write external storage.");
//  }
//}

//void selectConfigurationFile() {
//  //if (!grantedRead || !grantedWrite) {
//  //  requestPermissions();
//  //}
//  files.selectInput("Select Configuration File:", "fileSelected");
//}

//void selectPhotoFolder() {
//  if (saveFolderPath == null) {
//    files.selectFolder("Select Photo Folder", "folderSelected");
//    gui.displayMessage("Select Photo Folder", 30);
//  } else {
//    state = PRE_SAVE_STATE;
//    if (DEBUG) println("saveFolderPath="+saveFolderPath);
//    gui.displayMessage("Save Photo", 30);
//  }
//}

//final String configKey = "ConfigFilename";
//final String photoNumberKey = "photoNumber";
//final String myAppPrefs = "MultiNX";

//void saveConfig(String config) {
//  if (DEBUG) println("saveConfig "+config);
//  SharedPreferences sharedPreferences;
//  SharedPreferences.Editor editor;
//  sharedPreferences = getContext().getSharedPreferences(myAppPrefs, Context.MODE_PRIVATE);
//  editor = sharedPreferences.edit();
//  editor.putString(configKey, config );
//  editor.commit();
//}

//String loadConfig() {
//  SharedPreferences sharedPreferences;
//  sharedPreferences = getContext().getSharedPreferences(myAppPrefs, Context.MODE_PRIVATE);
//  String result = sharedPreferences.getString(configKey, null);
//  if (DEBUG) println("loadConfig "+result);
//  return result;
//}

//void savePhotoNumber(int number) {
//  if (DEBUG) println("savePhotoNumber "+number);
//  SharedPreferences sharedPreferences;
//  SharedPreferences.Editor editor;
//  sharedPreferences = getContext().getSharedPreferences(myAppPrefs, Context.MODE_PRIVATE);
//  editor = sharedPreferences.edit();
//  editor.putInt(photoNumberKey, number );
//  editor.commit();
//}

//int loadPhotoNumber() {
//  SharedPreferences sharedPreferences;
//  sharedPreferences = getContext().getSharedPreferences(myAppPrefs, Context.MODE_PRIVATE);
//  int result = sharedPreferences.getInt(photoNumberKey, 0);
//  if (DEBUG) println("loadPhotoNumber "+result);
//  return result;
//}

//private void destroy(PImage img) {
//  if (img == null) return;
//  Bitmap bitmap = (Bitmap) img.getNative();
//  if (bitmap != null)
//    bitmap.recycle();
//  img.setNative(null);
//  System.gc();
//}

//..........................................................................
//..........................................................................
//..........................................................................
//..........................................................................
//..........................................................................


// Java mode
void openFileSystem() {
}

void setTitle(String str) {
  surface.setTitle(str);
}

void selectInputImage() {
  if (DEBUG) println("Select Input Image File ");
  selectInput("Select Input Image File:", "selectImageFile");
}

void selectMaskImage() {
  if (DEBUG) println("Select Mask Image File ");
  selectInput("Select Mask Image File:", "selectMaskImageFile");
}

void selectOutputFolder() {
  selectFolder("Select Output Folder", "selectOutputFolder");
}

void saveConfig(String config) {
}

String loadConfig()
{
  return null;
}

void savePhotoNumber(int number) {
  if (DEBUG) println("savePhotoNumber "+number);
}

int loadPhotoNumber() {
  int result = 0;
  if (DEBUG) println("loadPhotoNumber "+result);
  return result;
}

//..........................................................................
//..........................................................................
//..........................................................................
//..........................................................................
//..........................................................................


// Code common to Android and Java platforms
// do not comment out

void selectOutputFolder(File selection) {
  if (selection == null) {
    if (DEBUG) println("Window closed or canceled.");
  } else {
    if (DEBUG) println("User selected Output Folder: " + selection.getAbsolutePath());
    saveFolderPath = selection.getAbsolutePath();
  }
}

private File imageSelection; // save image File selected for reload function
private File maskSelection; // save mask File selected for reload function
private File cameraImageSelection; // save camera image File for reload function

void selectImageFile(File selection) {
  if (selection == null) {
    if (DEBUG) println("Selection window was closed or the user hit cancel.");
    //showMsg("Selection window was closed or canceled.");
  } else {
    if (DEBUG) println("User selected " + selection.getAbsolutePath());
    imageSelection = selection;
    processImageSelection();
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
    receivedImage[current] = loadImage(editImagePath);
    if (DEBUG) println("editImagePath="+editImagePath);
    if (DEBUG) println("selectImageFile: "+promptList[1]);
  }
}

void selectMaskImageFile(File selection) {
  if (selection == null) {
    if (DEBUG) println("Selection window was closed or the user hit cancel.");
    //showMsg("Selection window was closed or canceled.");
  } else {
    if (DEBUG) println("User selected " + selection.getAbsolutePath());
    maskSelection = selection;
    processMaskSelection();
  }
}

void processMaskSelection() {
  if (maskSelection != null) {
    editMaskPath = maskSelection.getAbsolutePath();
    maskImage = loadImage(editMaskPath);
  }
}

void processCameraImageSelection() {
  if (cameraImageSelection != null) {
    editImagePath = cameraImageSelection.getAbsolutePath();
    promptList[1] = editImagePath.substring(editImagePath.lastIndexOf(File.separator)+1);
    current = 0;
    for (int i=0; i<numImages; i++) {
      receivedImage[i] = null;
      saved[i] = false;
      imageURL[i] = "";
    }
    saved[current] = true;
    receivedImage[current] = loadImage(editImagePath);
    if (DEBUG) println("editImagePath="+editImagePath);
    if (DEBUG) println("selectImageFile: "+promptList[1]);
  }
}

void saveCameraImageSelection(String filename) {
  cameraImageSelection = new File(filename);
}

void saveScreenshot() {
  if (screenshot) {
    screenshot = false;
    saveScreen(saveFolderPath, "screenshot_"+ getDateTime() + "_", number(screenshotCounter), "png");
    if (DEBUG) println("save "+ "screenshot_" + number(screenshotCounter));
    screenshotCounter++;
  }
}

// Save image of the composite screen
void saveScreen(String outputFolderPath, String outputFilename, String suffix, String filetype) {
  save(outputFolderPath + File.separator + outputFilename + suffix + "." + filetype);
}

String getDateTime() {
  Date current_date = new Date();
  String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss", Locale.US).format(current_date);
  return timeStamp;
}

// calls exiftool exe in the path
// sets portrait orientation by rotate camera left
void setEXIF(String filename) {
  try {
    Process process = Runtime.getRuntime().exec("exiftool -n -orientation=6 "+filename);
    process.waitFor();
  }
  catch (Exception ex) {
  }
}
