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

  ArrayList<PVector> getPoints() {
    return points;
  }
}
