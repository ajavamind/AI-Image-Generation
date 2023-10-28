/**
 * OpenAI API interface
 * OpenAI java library in code folder is from https://github.com/TheoKanning/openai-java
 */

// OpenAI-Java library imports
import com.theokanning.openai.service.OpenAiService;
import com.theokanning.openai.completion.CompletionRequest;
import com.theokanning.openai.image.CreateImageRequest;
import com.theokanning.openai.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.time.Duration;

private static final Duration IMAGE_TIMEOUT = Duration.ofSeconds(120); // seconds

final List<ChatMessage> messages = new ArrayList<ChatMessage>();
final List<ChatMessage> context = new ArrayList<ChatMessage>();
ChatMessage systemMessage;

OpenAiService service;
CreateImageRequest request;
CreateImageEditRequest editRequest;
CreateImageVariationRequest variationRequest;

private static final int NUM = 4; // maximum number of images to request, up to 10 allowed by Dall-E2
private static final int NUM_DISPLAY = 4; // maximum number of images to request
int numImages = NUM; // number of images requested from openai service, default
int imageSize = 1024;  // square default working size and aspect ratio
String genImageSize = "1024x1024";
// note image type is always png with transparency

void initAI() {
  // OPENAI_API_KEY is your paid account token stored in the environment variables for Windows 10/11
  String token = getToken();
  // create the OPENAI API service
  service = new OpenAiService(token, IMAGE_TIMEOUT);
}
