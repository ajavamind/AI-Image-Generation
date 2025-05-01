/**
 * Use OpenAI-Java API
 * https://github.com/TheoKanning/openai-java
 */

import com.theokanning.openai.service.OpenAiService;
import com.theokanning.openai.completion.CompletionRequest;
import com.theokanning.openai.image.CreateImageRequest;
import com.theokanning.openai.*;
import java.time.Duration;
import java.lang.System;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Enumeration;
import java.util.Locale;

PImage img;
private static final Duration IMAGE_TIMEOUT = Duration.ofSeconds(60);

void setup() {
  size(1024, 1024);
  background(128);
  String token = System.getenv("OPENAI_API_KEY");

  OpenAiService service = new OpenAiService(token, IMAGE_TIMEOUT);
  println("\nCreating Image...");
  CreateImageRequest request = CreateImageRequest.builder()
    .prompt("single red rose painting")
    //.model("dall-e-3")
    .build();

  println("\nImage is located at:");
  String imgUrl = service.createImage(request).getData().get(0).getUrl();
  println(imgUrl);

  img = requestImage(imgUrl);
}

void draw() {
  if (img != null) {
    image(img, 0, 0);
  }
}

void keyPressed() {
  if (key == ' ') {
    String dateTime = getDateTime();
    saveFrame(dateTime+"_DallE_####.png");
  }
}

String getDateTime() {
  Date current_date = new Date();
  String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss", Locale.US).format(current_date);
  return timeStamp;
}
