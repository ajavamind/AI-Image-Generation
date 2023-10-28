/**
 * Use OpenAI-Java API
 * https://github.com/TheoKanning/openai-java
 */

import com.theokanning.openai.service.OpenAiService;
import com.theokanning.openai.completion.CompletionRequest;
import com.theokanning.openai.image.CreateImageRequest;
import com.theokanning.openai.*;
import java.time.Duration;

PImage img;
private static final Duration IMAGE_TIMEOUT = Duration.ofSeconds(60);
 
void setup() {
  size(1024, 1024);
  background(128);
  String token = System.getenv("OPENAI_API_KEY");
  
  OpenAiService service = new OpenAiService(token, IMAGE_TIMEOUT);
  println("\nCreating Image...");
  CreateImageRequest request = CreateImageRequest.builder()
    .prompt("large snowflakes falling on a beach")
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
