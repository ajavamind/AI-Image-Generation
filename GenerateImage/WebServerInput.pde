// work in progress
// read a directory listing file from a web server
// scan for filenames, store in a list
// return the last jpg or png file in the list

import java.util.ArrayList;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

String directoryUrl = "http://192.168.1.238:8080";  // HTML server on my phone local network uses Android application: Multi Remote Camera
PImage lastPhoto;
File imageFile;

// on separate thread
void readServerImage() {
  ArrayList<String> list;
  list = getPhotoDirectory(directoryUrl);
  String lastFilename = list.get(list.size() - 1);
  try {
    lastPhoto = loadImage(directoryUrl+"/"+lastFilename);
  }
  catch(Exception e) {
    println("Could not get the image file");
    lastPhoto = null;
  }
  if (lastPhoto != null ) {
    captureFrame(lastPhoto, saveFolderPath+File.separator+lastFilename);
  }
  animation = NO_ANIMATION;
}

/**
 * Capture frame
 */
void captureFrame(PImage img, String path ) {
  println("captureFrame()");
  PImage serverImage = createImage(1024, 1024, ARGB);
  serverImage.copy(img, 0, 0, 1024, 1024, 0, 0, 1024, 1024); // copy cropped image

  current = 0;
  for (int i=0; i<numImages; i++) {
    receivedImage[i] = null;
    saved[i] = false;
    imageURL[i] = "";
  }
  saved[current] = true;
  receivedImage[current] = serverImage;
  serverImage.save(path);
  //saveCameraImageSelection(path);
}

/**
 * get Photo Directory
 */
ArrayList<String> getPhotoDirectory(String dir) {
  String[] html = loadStrings(dir);
  ArrayList<String> filenames = new ArrayList<String>();

  Pattern pattern = Pattern.compile("href=\"(.*?)\"");
  for (int i=0; i<html.length; i++) {
    //String sq = html[i].replaceAll("\"", "\\\"");
    String sq = html[i];
    Matcher matcher = pattern.matcher(sq);

    while (matcher.find()) {
      String filename = matcher.group(1);
      if (filename.matches(".+\\.(?i)(jpg|png)")) {
        filename = filename.replaceAll("/", "");
        filenames.add(filename);
      }
    }

    println(filenames);
  }
  return filenames;
}
