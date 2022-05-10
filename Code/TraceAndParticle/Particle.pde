class Particle {
  boolean alive;
  float size, wander, theta, drag;
  color PColor;
  PVector location, velocity;

  Particle (float x, float y, float size) {
    this.alive = true;
    this.size = size;
    this.wander = 0.15;
    this.theta = random (TWO_PI); //?
    this.drag = 0.92;
    this.PColor = #ffffff;
    this.location = new PVector(x, y);
    this.velocity = new PVector(0.0, 0.0);
  }

  void move() {
    this.location.add(this.velocity);
    this.velocity.mult(this.drag);
    this.theta+=random(theta1, theta2)*this.wander;
    this.velocity.x += sin(this.theta) * 0.1;
    this.velocity.y += cos(this.theta) * 0.1;
    this.size *= sizeScalar;
    this.alive = this.size > 0.5;
  }

  void show() {
    fill(this.PColor);
    noStroke();
    ellipse(this.location.x, this.location.y, this.size, this.size);
  }
}


// ----------------------------------------
//Visualization with particle functions
// ---------------------------------------- 
void spawn(float x, float y) {
  Particle myParticle;
  float theta, force;
  if (particles.size() >= PARTICLE_NUM) {
    particles.remove(0);
  }
  myParticle = new Particle(x, y, random(size1, size2));
  myParticle.wander = random(wander1, wander2);
  myParticle.PColor = colors[floor(random(7))];
  myParticle.drag = random(drag1, drag2);
  theta = random(TWO_PI);
  force = random(force1, force2);
  myParticle.velocity.x = sin(theta)*force;
  myParticle.velocity.y = cos(theta)*force;
  particles.add(myParticle);
}

void update() {
  int i;
  Particle currParticle;
  for (i=particles.size()-1; i>=0; i--) {
    currParticle = particles.get(i);
    if (currParticle.alive) {
      currParticle.move();
    }
  }
}
