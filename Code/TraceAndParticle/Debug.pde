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
