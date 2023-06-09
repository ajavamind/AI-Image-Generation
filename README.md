# OpenAI Dall-E Image Generation
 This repository contain Processing Java sketches that invoke the OpenAI API interface to the Dall-E 2 image generation service.
 
 The sketches run on Windows using the Processing.org SDK version 4.2.
 
 The sketch GenerateImage creates images from a text prompt using OpenAI Dall-E 2 API.
 The sketch application displays the generated image and saves it in the "output" folder.
 
 Sketches use OpenAI-Java API from a Github implementation (version 0.12.0) found at
 
 https://github.com/TheoKanning/openai-java  - thank you Theo Kanning!
 
 The OpenAiApiExample.java file is the code I used to build with OpenAI-Java (gradlew) to determine the library jar files needed.
 I built the example with gradlew in info debug mode with a request to build an distribution zip file. 
 
.\gradlew --info example:distZip
 
 The zip file in example/build/distributions, example.zip, was unzipped and I copied jar files from example/lib folders 
 into the "code" folder used by the sketch.
 
 In order to use the sketch you will need to establish an OpenAI API account.
 In the environment variables for Windows 10/11 create a OPENAI_TOKEN variable with your paid account token as the value.
 
Warning:
Due to evolving changes with the OpenAI API interface, OpenAI-java, and GPT and DALL-E models, this code, as written, may not work in the future.

# Key Commands

The GeneratImage sketch uses key commands to control its operation.


F1 - Generate New Image mode, type prompt text, and press Enter.

F2 - Edit Image mode, edit the mask in a separate window, type prompt text, and press Enter.

F3 - Edit Image with embedded mask mode, edit the mask in a separate window, type prompt text, and press Enter.

F4 - Create Image variation mode, requires an image, press Enter.

F5 - Reload Mask and Image file

F6 - Select the output folder for storing images and masks.

F7 - Select Last image file in a directory

F8 - Camera Image Input

F9 - Select the image file.

F10 - Select the mask image file.

F11 - 

F12 - Screenshot

Tab - Rotate through result images generated for edit

Esc - Exit program if main window or hide edit windows