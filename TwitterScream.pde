///TWITTER///
import twitter4j.conf.*;
import twitter4j.*;
import twitter4j.auth.*;
import twitter4j.api.*;
import java.util.*;
///CAMERA///
import processing.video.*;
///AUDIO///
import ddf.minim.*; 
import ddf.minim.analysis.*;

Twitter twit;///twitter
ConfigurationBuilder cb = new ConfigurationBuilder();

Minim minim;///audio
FFT fft;  
AudioInput in;   

Capture cam;///camera

List<Status> tweets;
File file;
int currentTweet = 0;
PImage img;
float amp = 15; // used to make signal stronger/weaker 
float ampWave = 10 * amp, avgAudio; // store avg volume ; 
void setup() {
  size(640, 480);
  img = createImage(width, height, RGB);
  ///TWITTER SETUP///
  /////having the correct path is fondamental/////
  file = new File("/Users/yannpatrick/Documents/Processing3/TwitterScream/output.jpg");
  ////////////////////////////////////////////////
  cb.setOAuthConsumerKey("Vq0pTTJbVeCETRrmxmIwX4v67");
  cb.setOAuthConsumerSecret("JFhruKoNx0xomOMb5GmznuJJTyu0ZSATBWknXfVE1c9mIpVBXM");
  cb.setOAuthAccessToken("812625522689765376-gccAXyVDUiXrPP0gPG8LhOb69yn6BHy");
  cb.setOAuthAccessTokenSecret("wBNJWGtti8EgSflnDFAzoWKE7LbzCTARbXoFlMXzXneBe");
  TwitterFactory tf = new TwitterFactory(cb.build());
  twit = tf.getInstance();
  ///AUDIO SETUP///
  minim = new Minim(this); // initalize in setup 
  in = minim.getLineIn(Minim.STEREO, 512); // audio in + bufferSize 512 or 1024 
  fft = new FFT(in.bufferSize(), in.sampleRate());  
  fft.logAverages(22, 3); // 3 = 30, 4 = 40, etc.. 
  ///CAMERA SETUP///
  cam = new Capture(this, width, height);
  cam.start();
  ///thread for re-tweeting///
  //thread("refreshTweets");
}

void draw() {
  if (cam.available()) {
    cam.read();
    img = cam;
    image(img, 0, 0);
  }
  fft.forward(in.mix); 
  for (int i = 0; i < fft.avgSize(); i++) {  
    avgAudio+= abs(fft.getAvg(i)*amp); // duplicate everything for stereo w/ right too!
  }    
  avgAudio /= fft.avgSize();
  if (avgAudio > 100)tweet();///set the 
}

void tweet() {
  ////CREATE THE IMAGE///
   cam.save("output.jpg");
  ///////////////////////////
  try {
    StatusUpdate status = new StatusUpdate("This is a scream sent from processing");
    status.setMedia(file);
    twit.updateStatus(status);
    System.out.println("Status updated");
  }
  catch (TwitterException te) {
    System.out.println("Error: "+ te.getMessage());
  }
}