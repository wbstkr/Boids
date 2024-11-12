public final PVector[] boidShape = {
    PVector.fromAngle(0).mult(20),
    PVector.fromAngle(3 * QUARTER_PI).mult(20),
    PVector.fromAngle(PI).mult(10),
    PVector.fromAngle(-3 * QUARTER_PI).mult(20)
};
public final float turnIncrement = PI / 36.0;
public final float boidSpeed = 5;

public Boid[] boids;

public void setup(){
    size(600, 600);

    this.boids = new Boid[100];
    for(int i = 0; i < boids.length; i++) {
        boids[i] = new Boid();
    }

    // frameRate(1);
}

public void draw(){
    background(0);

    for(Boid boid : boids) {
        boid.update(boids);
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

    public void update(Boid[] boids) {
        this.coherence(boids);
        this.separation(boids);
        this.alignment();

        this.heading += random(-1, 1) * PI / 180.0;
        this.cleanUpHeading();

        this.position.add(PVector.fromAngle(this.heading).mult(boidSpeed));

        this.screenWrap();
    }

    public void coherence(Boid[] boids) {
        PVector coherencePoint = new PVector(0, 0);
        for(Boid boid : boids) {
            coherencePoint.add(boid.position);
        }
        coherencePoint.div(boids.length);
        float newHeading = PVector.sub(coherencePoint, this.position).heading();

        this.heading += turnIncrement * headingDifferential(newHeading);
    }

    public void separation(Boid[] boids) {
        // PVector futurePoint = this.position.copy().add(PVector.fromAngle(this.heading).mult(this.range));
        PVector steerAwayPoint = new PVector(0, 0);
        float steerAwayIndex = 0;
        for(Boid boid : boids) {
            if(this.position.dist(boid.position) < this.range) {
                steerAwayPoint.add(boid.position);
                steerAwayIndex += 1;
            }
        }
        if(steerAwayIndex > 0) {
            steerAwayPoint.div(steerAwayIndex);
            float steerAwayHeading = PVector.sub(steerAwayPoint, this.position).heading();
            this.heading -= turnIncrement * headingDifferential(steerAwayHeading);
        }
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

    public void screenWrap() {
        if(this.position.x < -40) {
            this.position.x += width + 80;
        }
        if(this.position.x > width + 40) {
            this.position.x -= width + 80;
        }
        if(this.position.y < -40) {
            this.position.y += height + 80;
        }
        if(this.position.y > height + 40) {
            this.position.y -= height + 80;
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