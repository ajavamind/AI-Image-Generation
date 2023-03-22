package example;

import com.theokanning.openai.service.OpenAiService;
import com.theokanning.openai.completion.CompletionRequest;
import com.theokanning.openai.image.CreateImageRequest;
import com.theokanning.openai.image.CreateImageVariationRequest;
import com.theokanning.openai.image.CreateImageEditRequest;
import java.io.File;

class OpenAiApiExample {
    public static void main(String... args) {
        String token = System.getenv("OPENAI_TOKEN");
        OpenAiService service = new OpenAiService(token);

/*
        System.out.println("\nCreating completion...");
        CompletionRequest completionRequest = CompletionRequest.builder()
//                .model("ada")
//                .model("gpt-3.5-turbo")
//				.model("code-davinci-002")
				.model("gpt-3.5")
                .prompt("code processing.org java sketch to compute number pi")
                .echo(true)
                .user("testing")
                .n(1)
				.temperature(0.0)
				.maxTokens(1024)
				.topP(1.0)
                .build();
        service.createCompletion(completionRequest).getChoices().forEach(System.out::println);
		*/


        System.out.println("\nCreating Image...");
//        CreateImageVariationRequest request = CreateImageVariationRequest.builder()
//                //.prompt("Two tabby cats breakdancing")
//				.n(2)
//                .build();
        int num = 1;
        CreateImageEditRequest editRequest = CreateImageEditRequest.builder()
                //.prompt("change cat and dog color to tabby red and do swing dance with holding paws")
                .prompt("add frame")
				.n(num)
				.size("1024x1024")
				.responseFormat("url")
                .build();

        CreateImageVariationRequest varRequest = CreateImageVariationRequest.builder()
                //.prompt("add bookmarker to photo")  // no prompt used with variation requests
				.n(num)
				.size("1024x1024")
				.responseFormat("url")
                .build();
        String imagePath;
		imagePath = File.separator+"images"+File.separator+"readers_RGBA_l.png";
		imagePath = File.separator+"images"+File.separator+"VAL_0340_1024_L_cr.png";
		imagePath = File.separator+"images"+File.separator+"mask_VAL_0340_1024_L_cr.png";
		String maskPath = null;
        maskPath = File.separator+"images"+File.separator+"readers_mask_RGBA_r.png";
		maskPath = File.separator+"images"+File.separator+"almost_empty_mask_RGBA.png";
		//maskPath = File.separator+"images"+File.separator+"readers_mask_RGBA_l.png";
		maskPath = File.separator+"images"+File.separator+"empty_mask_RGBA.png";
		maskPath = File.separator+"images"+File.separator+"almost_empty_mask_RGBA.png";
		maskPath = File.separator+"images"+File.separator+"mask_VAL_0340_1024_L_cr.png";
		maskPath = null;
		//imagePath = File.separator+"images"+File.separator+"dog_breakdancing_with_cat_RGBA.png";
        //String imagePath = File.separator+"images"+File.separator+"readers_l.png";
		File imageFile = new File(imagePath);
        System.out.println(imageFile);
        System.out.println(File.separator);
        System.out.println(imageFile.getAbsolutePath());
        try {
            System.out.println(imageFile.getCanonicalPath());
        } catch(Exception ioe) {
            System.out.println(ioe);
        }
        System.out.println("\nImage is located at:");
		for (int i=0; i<num; i++) {
            System.out.println(service.createImageEdit(editRequest, imagePath, maskPath).getData().get(0).getUrl());
            //System.out.println("num "+ (i+1) + " of " + num +" " + service.createImageVariation(varRequest, imagePath).getData().get(i).getUrl());
			System.out.println();	
		}
		
		// https://stackoverflow.com/questions/57100451/okhttp3-requestbody-createcontenttype-content-deprecated
		
    }
}
