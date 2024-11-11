public final PVector[] boidShape = {
    PVector.fromAngle(0).mult(20),
    PVector.fromAngle(3 * QUARTER_PI).mult(20),
    PVector.fromAngle(PI).mult(10),
    PVector.fromAngle(-3 * QUARTER_PI).mult(20)
};
public final float turnIncrement = PI / 36.0;

public Boid[] boids;

public void setup(){
    size(600, 600);

    this.boids = new Boid[100];
    for(int i = 0; i < boids.length; i++) {
        boids[i] = new Boid();
    }
}

public void draw(){
    background(0);

    for(Boid boid : boids) {
        boid.update();
    }
    for(Boid boid : boids) {
        boid.render();
    }
}

public class Boid {
    public PVector position;
    public float heading;
    public float range;

    public Boid() {
        this.position = new PVector(random(width), random(height));
        this.heading = random(TWO_PI) - PI;
        this.range = 100;
    }

    public void update() {
        this.coherence();
        this.separation();
        this.alignment();

        this.heading += random(-1, 1) * PI / 180.0;
        this.cleanUpHeading();

        this.position.add(PVector.fromAngle(this.heading).mult(5));
    }

    public void coherence() {
        float newHeading = new PVector(mouseX, mouseY).sub(this.position).heading();

        this.heading += turnIncrement * headingDifferential(newHeading);
    }

    public void separation() {
    }

    public void alignment() {
    }

    // +1 means turn right, -1 means turn left
    public int headingDifferential(float newHeading) {
        if(this.heading > 0) {
            if(newHeading < this.heading && newHeading > this.heading - PI) return -1;
            else return 1;
        } else if(this.heading < 0) {
            if(newHeading > this.heading && newHeading < this.heading + PI) return 1;
            else return -1;
        } else return 1;
    }

    public void cleanUpHeading() {
        if(this.heading > PI) {
            this.heading -= TWO_PI;
        }
        if(this.heading < -PI) {
            this.heading += TWO_PI;
        }
    }

    public void render() {
        noStroke();
        fill(255, 50);
        beginShape();
        for(PVector point : boidShape) {
            PVector newPoint = point.copy().rotate(this.heading).add(position);
            vertex(newPoint.x, newPoint.y);
        }
        endShape(CLOSE);
    }
}