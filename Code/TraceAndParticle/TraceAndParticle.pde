
import java.*;
import KinectPV2.KJoint;
import KinectPV2.*;
//import spout.*;

// ----------------------------------------
// Spout & projection setup to broadcast to madmapper
// ----------------------------------------
//Spout spout;
int rotation = 90;
int myswitch = 0;
// ----------------------------------------
//Kinect skeleton setup
// ----------------------------------------

KinectPV2 kinect;

float depthMin = 1;
float depthMax = 3.5;

PVector headPos = new PVector(0, 0);
PVector handLeftPos = new PVector(0, 0);
PVector handRightPos = new PVector(0, 0);
PVector footLeftPos = new PVector(0, 0);
PVector footRightPos = new PVector(0, 0);
PVector bodyPos = new PVector(0, 0);

// ----------------------------------------
//Trace setup 
// ----------------------------------------
int maxPoints = 300;

PointSystem head;
PointSystem handLeft;
PointSystem handRight;
PointSystem footLeft;
PointSystem footRight;
PointSystem body;

// ----------------------------------------
//Particle setup
// ----------------------------------------

int PARTICLE_NUM = 100;
color[][] colors = {{ #69D2E7, #A7DBD8, #E0E4CC, #DAF7A6 }, //#ADDF8C, #FA6900,,  #FF4E50
  { #F38630, #FF6500, #FF0063, #520042  } //#31CFAD,
};
//color[] colors2 = { #31CFAD, #ADDF8C, #FF6500, #FF0063, #520042, #DAF7A6 };
//color[] colors3 = { #581845, #900C3F, #C70039, #C70039, #FFC300, #DAF7A6 };

float wander1 = 0.5;
float wander2 = 2.0;
float drag1 = .9;
float drag2 = .99;
float force1 = .5;
float force2 = 2;
float theta1 = -0.5;
float theta2 = 0.5;
float size1 = 5;
float size2 = 25;
float sizeScalar = 0.98;
float max;

ArrayList<Particle> particles = new ArrayList<Particle>();


void setup() {
  size(3840, 2160, P2D);
  background(0);

  head = new PointSystem();
  handLeft = new PointSystem();
  handRight = new PointSystem();
  footLeft = new PointSystem();
  footRight = new PointSystem();
  body = new PointSystem();

  kinect = new KinectPV2(this);
  //Enables depth and Body tracking (mask image)
  kinect.enableDepthMaskImg(true);
  kinect.enableSkeletonDepthMap(true);
  kinect.enableSkeleton3DMap(true);

  kinect.init();

  //spout = new Spout(this);
  //spout.setSenderName("Spout Processing Sender");
}

void draw() {
  background(0);
  myswitch = frameCount/1000%5;
  //pushMatrix();
  //translate(512, 0);
  //fill(0, 30);
  //rect(0, 0, width/2, height); //  black background 
  //image(kinect.getDepthMaskImage(), 0, 0);

  //fill(255, 0, 0);
  //text(frameRate, 50, 50);
  //popMatrix();

  //get the skeletons as an Arraylist of KSkeletons
  ArrayList<KSkeleton> skeletonArray =  kinect.getSkeletonDepthMap();
  ArrayList<KSkeleton> skeletonArray2 =  kinect.getSkeleton3d();

  //individual joints
  if (skeletonArray.size()==0) {
    scale(7.5);
    update();
    max = random(1, 4);
    for (int j=0; j<max; j++) {
      spawn(width/15, height/15, 0); //try to draw with head
    }
    for (int i=particles.size()-1; i>=0; i--) {
      particles.get(i).show();
    }
  } else {
    for (int w = 0; w < skeletonArray.size(); w++) {

      KSkeleton skeleton = (KSkeleton) skeletonArray.get(w);
      KSkeleton skeleton2 = (KSkeleton) skeletonArray2.get(w);

      //if the skeleton is being tracked compute the skleton joints
      if (skeleton.isTracked()) {
        KJoint[] joints = skeleton.getJoints();
        KJoint[] joints2 = skeleton2.getJoints();

        //color col  = skeleton.getIndexColor();
        color col = color(255, 0, 0);
        fill(col);
        stroke(col);


        // ----------------------------------------
        //Debug draw
        // ----------------------------------------
        //pushMatrix();
        //translate(512, 0);
        //drawBody(joints);
        //drawHandState(joints[KinectPV2.JointType_HandRight]);
        //drawHandState(joints[KinectPV2.JointType_HandLeft]);
        //popMatrix();

        // ----------------------------------------------------------
        //Get and map all 6 points from side view to bird view
        // ----------------------------------------------------------
        headPos.x = joints[KinectPV2.JointType_Head].getX();
        headPos.y = map(joints2[KinectPV2.JointType_Head].getZ(), depthMin, depthMax, 0, 424);
        handLeftPos.x = joints[KinectPV2.JointType_HandLeft].getX();
        handLeftPos.y = map(joints2[KinectPV2.JointType_HandLeft].getZ(), depthMin, depthMax, 0, 424);   
        handRightPos.x = joints[KinectPV2.JointType_HandRight].getX();
        handRightPos.y = map(joints2[KinectPV2.JointType_HandRight].getZ(), depthMin, depthMax, 0, 424);     
        footLeftPos.x = joints[KinectPV2.JointType_FootLeft].getX();
        footLeftPos.y = map(joints2[KinectPV2.JointType_FootLeft].getZ(), depthMin, depthMax, 0, 424);
        footRightPos.x = joints[KinectPV2.JointType_FootRight].getX();
        footRightPos.y = map(joints2[KinectPV2.JointType_FootRight].getZ(), depthMin, depthMax, 0, 424);
        bodyPos.x = joints[KinectPV2.JointType_SpineMid].getX();
        bodyPos.y = map(joints2[KinectPV2.JointType_SpineMid].getZ(), depthMin, depthMax, 0, 424);

        // update the points
        head.addPoint(headPos.x, headPos.y);
        handLeft.addPoint(handLeftPos.x, handLeftPos.y);
        handRight.addPoint(handRightPos.x, handRightPos.y);
        footLeft.addPoint(footLeftPos.x, footLeftPos.y);
        footRight.addPoint(footRightPos.x, footRightPos.y);
        body.addPoint(bodyPos.x, bodyPos.y);
        //}
      }



      pushMatrix();
      scale(7.5);

      strokeWeight(2);
      //translate(0, height);
      //rotate(radians(-rotation));

      // ----------------------------------------
      //Visualization of trace
      // ----------------------------------------
      if (myswitch == 4) {
        for (int i=head.getPoints().size()-1; i>=0; i--) {
          int alpha = (int) map(i+1, 0, head.getPoints().size(), 0, 50);
          noFill();
          //fill(255,alpha);
          stroke(255, alpha);
          // ----------------------------------------
          //Beizer curve
          // ---------------------------------------- 
          bezier(handLeft.getPoints().get(i).x, handLeft.getPoints().get(i).y, footLeft.getPoints().get(i).x, footLeft.getPoints().get(i).y, footRight.getPoints().get(i).x, footRight.getPoints().get(i).y, handRight.getPoints().get(i).x, handRight.getPoints().get(i).y);
        }
      }

      // ----------------------------------------
      //Triangular shape
      // ---------------------------------------- 
      else if ((myswitch == 3)||(myswitch == 2)) {
        stroke(255);
        line(handLeftPos.x, handLeftPos.y, handRightPos.x, handRightPos.y);
        line(handLeftPos.x, handLeftPos.y, footRightPos.x, footRightPos.y);
        line(handLeftPos.x, handLeftPos.y, footLeftPos.x, footLeftPos.y);
        line(handRightPos.x, handRightPos.y, footLeftPos.x, footLeftPos.y);
        line(handRightPos.x, handRightPos.y, footRightPos.x, footRightPos.y);
        line(footLeftPos.x, footLeftPos.y, footRightPos.x, footRightPos.y);
      }

      // ----------------------------------------
      //Visualization with particle in draw loop
      // ---------------------------------------- 
      else if ((myswitch == 0)||(myswitch == 1)) {
        update();
        if (frameCount % 3 == 0) {
          //for (int i=body.getPoints().size()-1; i>=0; i--) {
          max = random(1, 4);
          for (int j=0; j<max; j++) {
            spawn(headPos.x, headPos.y, w % 2); //try to draw with head
          }
        }
        //}
        for (int i=particles.size()-1; i>=0; i--) {
          particles.get(i).show();
        }
      }
      popMatrix();
    }
  }
  // ----------------------------------------
  //Trace of points
  // ---------------------------------------- 
  //head.display(color(255,0,0));
  //handLeft.display(255);
  //handRight.display(255);
  //footLeft.display(255);
  //footRight.display(255);
  //body.display(255);

  // ----------------------------------------
  //Spout communication
  // ---------------------------------------- 
  //spout.sendTexture();
}
