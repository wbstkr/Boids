public Boid[] boids;

public final int NUM_OF_BOIDS = 1000;
public final float BOID_SCALE = 10.0;

public void setup() {
  size(1280, 720);

  this.boids = new Boid[NUM_OF_BOIDS];
  for (int i = 0; i < this.boids.length; i++) {
    this.boids[i] = new Boid();
  }

  frameRate(60);
}

public void draw() {
  background(0);

  for (Boid boid : this.boids) {
    boid.update(this.boids);
  }
  for (Boid boid : this.boids) {
    boid.render(BOID_SCALE);
  }

  if (keyPressed)
    if (key == 'r')
      setup();
}