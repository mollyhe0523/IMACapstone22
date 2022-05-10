import java.*;
import KinectPV2.KJoint;
import KinectPV2.*;

// ----------------------------------------
//Kinect skeleton setup
// ----------------------------------------

KinectPV2 kinect;
float depthMin = 1.5;
float depthMax = 4.5;

PVector headPos = new PVector(0,0);
PVector handLeftPos = new PVector(0,0);
PVector handRightPos = new PVector(0,0);
PVector footLeftPos = new PVector(0,0);
PVector footRightPos = new PVector(0,0);
PVector bodyPos = new PVector(0,0);


int maxPoints = 15;

PointSystem head;
PointSystem handLeft;
PointSystem handRight;
PointSystem footLeft;
PointSystem footRight;
PointSystem body;


void setup() {
  size(1024, 424);
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
}

void draw() {
  background(0);
   
  pushMatrix();
  translate(512,0);
  fill(0,30);
  rect(0, 0, width/2, height); //  black background 
  image(kinect.getDepthMaskImage(), 0, 0);
  
  //get the skeletons as an Arraylist of KSkeletons
  ArrayList<KSkeleton> skeletonArray =  kinect.getSkeletonDepthMap();
  ArrayList<KSkeleton> skeletonArray2 =  kinect.getSkeleton3d();

  //individual joints
  //for (int i = 0; i < skeletonArray.size(); i++) {
   if (skeletonArray.size()>0){
    KSkeleton skeleton = (KSkeleton) skeletonArray.get(0);
    KSkeleton skeleton2 = (KSkeleton) skeletonArray2.get(0);
    
    //if the skeleton is being tracked compute the skleton joints
    if (skeleton.isTracked()) {
      KJoint[] joints = skeleton.getJoints();
      KJoint[] joints2 = skeleton2.getJoints();

      //color col  = skeleton.getIndexColor();
      color col = color(255,0,0);
      fill(col);
      stroke(col);


// ----------------------------------------
//Debug draw
// ----------------------------------------
      drawBody(joints);
      drawHandState(joints[KinectPV2.JointType_HandRight]);
      drawHandState(joints[KinectPV2.JointType_HandLeft]);
      
// ----------------------------------------------------------
//Get and map all 6 points from side view to bird view
// ----------------------------------------------------------
      headPos.x = joints[KinectPV2.JointType_Head].getX();
      headPos.y = map(joints2[KinectPV2.JointType_Head].getZ(),depthMin,depthMax,0,424);
      handLeftPos.x = joints[KinectPV2.JointType_HandLeft].getX();
      handLeftPos.y = map(joints2[KinectPV2.JointType_HandLeft].getZ(),depthMin,depthMax,0,424);   
      handRightPos.x = joints[KinectPV2.JointType_HandRight].getX();
      handRightPos.y = map(joints2[KinectPV2.JointType_HandRight].getZ(),depthMin,depthMax,0,424);     
      footLeftPos.x = joints[KinectPV2.JointType_FootLeft].getX();
      footLeftPos.y = map(joints2[KinectPV2.JointType_FootLeft].getZ(),depthMin,depthMax,0,424);
      footRightPos.x = joints[KinectPV2.JointType_FootRight].getX();
      footRightPos.y = map(joints2[KinectPV2.JointType_FootRight].getZ(),depthMin,depthMax,0,424);
      bodyPos.x = joints[KinectPV2.JointType_SpineMid].getX();
      bodyPos.y = map(joints2[KinectPV2.JointType_SpineMid].getZ(),depthMin,depthMax,0,424);

  // update the points
  head.addPoint(headPos.x, headPos.y);
  handLeft.addPoint(handLeftPos.x, handLeftPos.y);
  handRight.addPoint(handRightPos.x, handRightPos.y);
  footLeft.addPoint(footLeftPos.x, footLeftPos.y);
  footRight.addPoint(footRightPos.x, footRightPos.y);
  body.addPoint(bodyPos.x, bodyPos.y);
  
    }
  }
  
  fill(255, 0, 0);
  text(frameRate, 50, 50);
  popMatrix();
  
  for (int i=head.getPoints().size()-1; i>=0; i--){
      int alpha = (int) map(i,0,head.getPoints().size()-1, 0,150);
      fill(255, alpha);
      bezier(handLeft.getPoints().get(i).x,handLeft.getPoints().get(i).y,footLeft.getPoints().get(i).x,footLeft.getPoints().get(i).y,footRight.getPoints().get(i).x,footRight.getPoints().get(i).y,handRight.getPoints().get(i).x,handRight.getPoints().get(i).y);
  }
  
  //head.display(color(255,0,0));
  //handLeft.display(color(0,255,0));
  //handRight.display(color(0,255,0));
  //footLeft.display(color(0,0,255));
  //footRight.display(color(0,0,255));
  //body.display(255);
}


class PointSystem {
  ArrayList<PVector> points = new ArrayList<PVector>();
  
  PointSystem() {
    //
  }
  
  void addPoint(float x, float y) {
    PVector newPoint = new PVector(x, y); 
    points.add( newPoint );
    
    // if the number of points are greater than the maximum, remove the oldest one.
    if (points.size() > maxPoints) {
      points.remove(0);
    }
  }
  
  void display(color col) {
    pushStyle();
    
    noFill();
    stroke(col);
    beginShape();
    for (int i=0; i<points.size(); i++) {
      PVector point = points.get(i);
      vertex(point.x, point.y);
    }
    endShape();
    
    popStyle();
  }
  
  ArrayList<PVector> getPoints(){
    return points;
  }
  
}


// ----------------------------------------
//Debug draw functions
// ----------------------------------------

//draw the body
void drawBody(KJoint[] joints) {
  //Single joints
  drawJoint(joints, KinectPV2.JointType_HandLeft);
  drawJoint(joints, KinectPV2.JointType_HandRight);
  drawJoint(joints, KinectPV2.JointType_FootLeft);
  drawJoint(joints, KinectPV2.JointType_FootRight);
  drawJoint(joints, KinectPV2.JointType_SpineMid);
  drawJoint(joints, KinectPV2.JointType_Head);
}

//draw a single joint
void drawJoint(KJoint[] joints, int jointType) {
  pushMatrix();
  translate(joints[jointType].getX(), joints[jointType].getY());
  //translate(map(joints[jointType].getX(),0,1,0,512), map(joints[jointType].getY(),0,1,0,424));
  ellipse(0, 0, 25, 25);
  popMatrix();
}

//draw a ellipse depending on the hand state
void drawHandState(KJoint joint) {
  noStroke();
  handState(joint.getState());
  pushMatrix();
  translate(joint.getX(), joint.getY());
  //translate(map(joint.getX(),0,1,0,512), map(joint.getY(),0,1,0,424));
  ellipse(0, 0, 30, 30);
  popMatrix();
}

/*
Different hand state
 KinectPV2.HandState_Open
 KinectPV2.HandState_Closed
 KinectPV2.HandState_Lasso
 KinectPV2.HandState_NotTracked
 */

//Depending on the hand state change the color
void handState(int handState) {
  switch(handState) {
  case KinectPV2.HandState_Open:
    fill(0, 255, 0);
    break;
  case KinectPV2.HandState_Closed:
    fill(255, 0, 0);
    break;
  case KinectPV2.HandState_Lasso:
    fill(0, 0, 255);
    break;
  case KinectPV2.HandState_NotTracked:
    fill(100, 100, 100);
    break;
  }
}




//
