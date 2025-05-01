
/**
 * Use jvm-openai API for OpenAI
 * https://github.com/StefanBratanov/jvm-openai/releases/tag/v0.11.0
 * Example code to generate images with dall-e-2, dall-e-3, and gpt-image-1 models
 * includes examples for model listings, chat and supporting methods, etc.
 * also uses model gpt-4.1 for testing
 */

import java.net.URI;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import java.time.Duration;
import java.lang.System;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Enumeration;
import java.util.Locale;
import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.Base64;
import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.awt.image.BufferedImage;
import javax.imageio.ImageIO;

import java.awt.Image;
import java.awt.Graphics2D;
import io.github.stefanbratanov.jvm.openai.*;
import io.github.stefanbratanov.jvm.openai.OpenAI;

private static final Duration IMAGE_TIMEOUT = Duration.ofSeconds(60);
PImage urlImg;
PImage[] pimg;
int current = 0;
int numImages = 2;

PImage pimgFromB64;
OpenAI openAI;
String prompt="An acrylic painting of a bouquet of twelve red roses.";
String revisedPrompt;
String testFilename= "testFilename";

void setup() {
  //size(1024, 1024);
  size(1536, 1024);
  background(128);
  openAI = OpenAI.newBuilder(System.getenv("OPENAI_API_KEY"))
    .requestTimeout(IMAGE_TIMEOUT)
    //.organization("OPENAI_ORG_ID")
    .build();

  //test();
  //testListModels();
  //testImageDallE3();
  testImageGptimage1();
  //testPath();
}

void testPath() {
  println(sketchPath() + File.separator + testFilename+"_"+current+".png");
}

void test() {
  // Test simple chat connection
  ChatClient chatClient = openAI.chatClient();
  CreateChatCompletionRequest createChatCompletionRequest = CreateChatCompletionRequest.newBuilder()
    .model("gpt-4.1")
    .message(ChatMessage.userMessage("Who won the world series in 2020?"))
    .build();
  ChatCompletion chatCompletion = chatClient.createChatCompletion(createChatCompletionRequest);
  println(chatCompletion.choices().get(0));
  System.out.println("Prompt: "+ prompt);
  System.out.println("Result: "+chatCompletion.choices().get(0).message().content());
}

void testListModels() {
  ModelsClient modelsClient = openAI.modelsClient();
  List<Model> models = modelsClient.listModels();
  println("Current Models: "+getDateTime());
  for (int i=0; i<models.size(); i++) {
    println(models.get(i).id());
  }
}

// Current Models: 20250429_155948
// gpt-4o-audio-preview-2024-12-17
// dall-e-3
// dall-e-2
// gpt-4o-audio-preview-2024-10-01
// text-embedding-3-small
// o3
// o3-2025-04-16
// o4-mini
// gpt-4.1-nano
// gpt-4.1-nano-2025-04-14
// gpt-4o-realtime-preview-2024-10-01
// o4-mini-2025-04-16
// o1-pro-2025-03-19
// gpt-4o-realtime-preview
// o1-pro
// babbage-002
// o1
// gpt-4
// o1-2024-12-17
// text-embedding-ada-002
// chatgpt-4o-latest
// gpt-4o-realtime-preview-2024-12-17
// text-embedding-3-large
// gpt-4o-mini-audio-preview
// gpt-4o-audio-preview
// o1-preview-2024-09-12
// gpt-4o-mini-realtime-preview
// gpt-4.1-mini
// gpt-4o-mini-realtime-preview-2024-12-17
// gpt-3.5-turbo-instruct-0914
// gpt-4o-mini-search-preview
// computer-use-preview-2025-03-11
// gpt-4.1-mini-2025-04-14
// davinci-002
// gpt-3.5-turbo-1106
// gpt-4o-search-preview
// gpt-4-turbo
// gpt-3.5-turbo-instruct
// gpt-3.5-turbo
// gpt-4-turbo-preview
// gpt-4o-mini-search-preview-2025-03-11
// gpt-4-0125-preview
// gpt-4o-2024-11-20
// whisper-1
// gpt-4o-2024-05-13
// gpt-4-turbo-2024-04-09
// gpt-3.5-turbo-16k
// gpt-image-1
// o1-preview
// gpt-4-0613
// gpt-4.5-preview
// gpt-4.5-preview-2025-02-27
// gpt-4o-search-preview-2025-03-11
// omni-moderation-2024-09-26
// o3-mini
// o3-mini-2025-01-31
// tts-1-hd
// gpt-4o
// tts-1-hd-1106
// gpt-4o-mini
// gpt-4o-2024-08-06
// gpt-4.1
// gpt-4.1-2025-04-14
// gpt-4o-mini-2024-07-18
// gpt-4o-mini-transcribe
// o1-mini
// gpt-4o-mini-audio-preview-2024-12-17
// gpt-3.5-turbo-0125
// o1-mini-2024-09-12
// gpt-4o-transcribe
// tts-1
// gpt-4-1106-preview
// gpt-4o-mini-tts
// tts-1-1106
// computer-use-preview
// omni-moderation-latest

void testImageDallE3() {
  ImagesClient imagesClient = openAI.imagesClient();
  CreateImageRequest createImageRequest = CreateImageRequest.newBuilder()
    .model("dall-e-3")
    .prompt(prompt)
    .build();
  Images images = imagesClient.createImage(createImageRequest);
  // Get the first image from the list
  Images.Image img = images.data().get(0);
  // Extract revisedPrompt
  revisedPrompt = img.revisedPrompt();
  println("Revised Prompt: " + revisedPrompt);
  String url = img.url();
  PImage pimgFromUrl = loadImage(url); // loadImage from a URL
  urlImg = pimgFromUrl;

  // Display the image
  if (pimgFromUrl != null) {
    image(urlImg, 0, 0);
  }
}

void testImageGptimage1() {
  ImagesClient imagesClient = openAI.imagesClient();
  CreateImageRequest createImageRequest = CreateImageRequest.newBuilder()
    .model("gpt-image-1")
    .prompt(prompt)
    .n(numImages)
    .outputCompression(100)
    .outputFormat("png")
    .quality("medium")
    .size("1536x1024")
    .build();
  Images images = imagesClient.createImage(createImageRequest);

  // Get the first image from the list
  pimg = new PImage[numImages];
  for (int i=0; i<numImages; i++) {
    Images.Image img = images.data().get(i);
    pimg[i] = loadPImage(img);
    // Extract revisedPrompt
    revisedPrompt = img.revisedPrompt();
    println("Revised Prompt: " + i +" "+revisedPrompt);
  }
}

// Load PImage from base64 JSON
PImage loadPImage(Images.Image img) {
  PImage pimgFromB64 = null;
  String b64Json = img.b64Json();
  if (b64Json != null && !b64Json.isEmpty()) {
    try {
      // Decode base64 string to bytes
      byte[] imageBytes = Base64.getDecoder().decode(b64Json);
      // Convert bytes to InputStream
      InputStream in = new ByteArrayInputStream(imageBytes);
      // Read BufferedImage from InputStream
      BufferedImage bimg = ImageIO.read(in);
      // Convert BufferedImage to PImage
      pimgFromB64 = bufferedToPImage(bimg);
    }
    catch (Exception e) {
      e.printStackTrace();
    }
  }
  return pimgFromB64;
}

// Function to convert BufferedImage to PImage
PImage bufferedToPImage(BufferedImage bimg) {
  if (bimg == null) return null;
  PImage pimg = new PImage(bimg.getWidth(), bimg.getHeight(), ARGB);
  bimg.getRGB(0, 0, bimg.getWidth(), bimg.getHeight(), pimg.pixels, 0, bimg.getWidth());
  pimg.updatePixels();
  return pimg;
}

void draw() {
  if (urlImg != null) {
    image(urlImg, 0, 0);
  } else if (pimg != null && pimg[current] != null) {
    image(pimg[current], 0, 0);
  }
}

// save sketch frame with space bar
void keyPressed() {
  if (key == ' ') {
    String dateTime = getDateTime();
    String filename = dateTime+"_GptImage1";
    pimg[current].save(sketchPath() + File.separator + filename+"_"+current+".png");
    String[] revision = new String[1];
    if (revisedPrompt != null) {
      revision[0] = revisedPrompt;
    } else {
      revision[0] = prompt;
    }
    saveStrings(sketchPath() + File.separator + filename+".txt", revision);
  } else if (key == 'n') {
    current++;
    if (current >= numImages) current = 0;
  }
}

String getDateTime() {
  Date current_date = new Date();
  String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss", Locale.US).format(current_date);
  return timeStamp;
}

//// Load image from base64 JSON
//String b64Json = img.b64Json();
//pimgFromB64 = null;
//if (b64Json != null && !b64Json.isEmpty()) {
//  try {
//    // Decode base64 string to bytes
//    byte[] imageBytes = Base64.getDecoder().decode(b64Json);
//    // Convert bytes to InputStream
//    InputStream in = new ByteArrayInputStream(imageBytes);
//    // Read BufferedImage from InputStream
//    BufferedImage bimg = ImageIO.read(in);
//    // Convert BufferedImage to PImage
//    pimgFromB64 = bufferedToPImage(bimg);
//  }
//  catch (Exception e) {
//    e.printStackTrace();
//  }
//}
//// Display the image (choose one)
//if (pimgFromB64 != null) {
//  image(pimgFromB64, 0, 0);
//}
