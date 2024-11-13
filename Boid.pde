public final PVector[] BOID_SHAPE = {
  PVector.fromAngle(0),
  PVector.fromAngle(PI - QUARTER_PI),
  PVector.fromAngle(PI).mult(0.5),
  PVector.fromAngle(PI + QUARTER_PI)};
public final float MAX_SPEED = 10.0;

public class Boid {
  public PVector position;
  public PVector velocity;
  public PVector acceleration;
  public float separationRange;
  public float alignmentRange;
  public float cohesionRange;
  public float mouseRange;

  public Boid() {
    this.position = new PVector(random(width), random(height));
    this.velocity = PVector.random2D().mult(random(MAX_SPEED) / 2.0);
    this.acceleration = new PVector(0, 0);
    this.separationRange = 100;
    this.alignmentRange = 100;
    this.cohesionRange = 100;
    this.mouseRange = 100;
  }

  public void update(Boid[] boids) {
    PVector separation = this.getSeparation(boids, 0.05);
    PVector alignment = this.getAlignment(boids, 0.05);
    PVector cohesion = this.getCohesion(boids, 0.05);
    PVector edgeRepel = this.getEdgeRepel(5.0);
    PVector mouseInteraction = this.getMouseInteraction(1.0);

    this.acceleration.mult(0);
    this.acceleration.sub(separation);
    this.acceleration.add(alignment);
    this.acceleration.add(cohesion);
    this.acceleration.add(edgeRepel);
    this.acceleration.add(mouseInteraction);

    this.velocity.add(this.acceleration);
    this.velocity.limit(MAX_SPEED);
    this.position.add(this.velocity);
    // this.screenWrap();
  }

  public PVector getSeparation(Boid[] boids, float strength) {
    PVector separation = new PVector(0, 0);
    int boidsInRange = 0;
    for (Boid boid : boids) {
      if (boid != this && this.position.dist(boid.position) < this.separationRange) {
        PVector difference = PVector.sub(boid.position, this.position)
          .setMag(this.separationRange * 0.5 / PVector.dist(boid.position, this.position));
        separation.add(difference);
        boidsInRange++;
      }
    }
    if (boidsInRange > 0)
      separation.mult(strength);
    return separation;
  }

  public PVector getAlignment(Boid[] boids, float strength) {
    PVector averageVelocity = new PVector(0, 0);
    int boidsInRange = 0;
    for (Boid boid : boids) {
      if (boid != this && this.position.dist(boid.position) < this.alignmentRange) {
        averageVelocity.add(boid.velocity);
        boidsInRange++;
      }
    }
    if (boidsInRange > 0)
      averageVelocity.div(boidsInRange)
        .sub(this.velocity)
        .mult(strength);
    return averageVelocity;
  }

  public PVector getCohesion(Boid[] boids, float strength) {
    PVector cohesion = new PVector(0, 0);
    int boidsInRange = 0;
    for (Boid boid : boids) {
      if (boid != this && this.position.dist(boid.position) < this.cohesionRange) {
        cohesion.add(boid.position);
        boidsInRange++;
      }
    }
    if (boidsInRange > 0)
      cohesion.div(boidsInRange)
        .sub(this.position)
        .mult(strength);
    return cohesion;
  }

  public PVector getEdgeRepel(float strength) {
    PVector edgeRepel = new PVector(0, 0);
    if (this.position.x < 0)
      edgeRepel.x += strength;
    if (this.position.x > width)
      edgeRepel.x -= strength;
    if (this.position.y < 0)
      edgeRepel.y += strength;
    if (this.position.y > height)
      edgeRepel.y -= strength;
    return edgeRepel;
  }

  public PVector getMouseInteraction(float strength) {
    PVector mouseInteraction = new PVector(0, 0);
    if (mousePressed) {
      PVector mousePosition = new PVector(mouseX, mouseY);
      if (PVector.dist(mousePosition, this.position) < this.mouseRange) {
        mouseInteraction = PVector.sub(mousePosition, this.position)
          .setMag(strength * this.mouseRange / PVector.dist(mousePosition, this.position));
        if (mouseButton == RIGHT) mouseInteraction.mult(-1.0);
      }
    }
    return mouseInteraction;
  }

  public void screenWrap() {
    if (this.position.x < -40)
      this.position.x += width + 80;
    if (this.position.x > width + 40)
      this.position.x -= width + 80;
    if (this.position.y < -40)
      this.position.y += height + 80;
    if (this.position.y > height + 40)
      this.position.y -= height + 80;
  }

  public void render(float boidScale) {
    noStroke();
    fill(255, 50);
    beginShape();
    for (PVector point : BOID_SHAPE) {
      PVector newPoint = PVector.mult(point, boidScale)
        .rotate(this.velocity.heading())
        .add(position);
      vertex(newPoint.x, newPoint.y);
    }
    endShape(CLOSE);
  }
}
