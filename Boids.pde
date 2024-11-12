public Boid[] boids;

public void setup(){
    size(1280, 720);

    this.boids = new Boid[1000];
    for(int i = 0; i < boids.length; i++) {
        boids[i] = new Boid();
    }

    frameRate(60);
}

public void draw(){
    background(0);

    for(Boid boid : boids) {
        boid.update(boids);
    }
    for(Boid boid : boids) {
        boid.render(10.0);
    }
}

public final PVector[] boidShape = {
    PVector.fromAngle(0),
    PVector.fromAngle(PI - QUARTER_PI),
    PVector.fromAngle(PI).mult(0.5),
    PVector.fromAngle(PI + QUARTER_PI)
};
public final float turnIncrement = PI / 36.0;
public final float boidSpeed = 10;

public class Boid {
    public PVector position;
    public PVector velocity;
    public PVector acceleration;
    public float range;

    public Boid() {
        this.position = new PVector(random(width), random(height));
        this.velocity = PVector.random2D().mult(random(boidSpeed) / 2.0);
        this.acceleration = new PVector(0, 0);
        this.range = 100;
    }

    public void update(Boid[] boids) {
        PVector coherence   = this.calculateCoherence   (boids, 5.0, 1.0, 0.05);
        PVector separation  = this.calculateSeparation  (boids, 1.0, 1.0, 0.10);
        PVector alignment   = this.calculateAlignment   (boids, 2.0, 1.0, 0.05);

        this.acceleration.add(coherence);
        this.acceleration.add(separation);
        this.acceleration.add(alignment);

        if(mousePressed) {
            PVector mousePosition = new PVector(mouseX, mouseY);
            if(this.position.dist(mousePosition) < this.range * 1.0) {
                PVector mouseAttraction = PVector.sub(mousePosition, this.position).mult(0.10);
                if(mouseButton == LEFT) this.acceleration.add(mouseAttraction);
                if(mouseButton == RIGHT) this.acceleration.sub(mouseAttraction);
            }
        }

        this.velocity.add(this.acceleration);
        this.velocity.limit(boidSpeed);
        this.position.add(this.velocity);
        this.screenWrap();
        this.acceleration.mult(0);
    }

    public PVector calculateCoherence(Boid[] boids, float rangeWeight, float overallWeight, float speedLimit) {
        PVector coherencePoint = new PVector(0, 0);
        int boidsInRange = 0;
        for(Boid boid : boids) {
            if(boid != this && this.position.dist(boid.position) < this.range * rangeWeight) {
                coherencePoint.add(boid.position);
                boidsInRange++;
            }
        }
        if(boidsInRange > 0) {
            coherencePoint.div(boidsInRange);
            coherencePoint.sub(this.position);
            coherencePoint.limit(speedLimit);
            coherencePoint.mult(overallWeight);
        }
        return coherencePoint;
    }

    public PVector calculateSeparation(Boid[] boids, float rangeWeight, float overallWeight, float speedLimit) {
        PVector separationPoint = new PVector(0, 0);
        int boidsInRange = 0;
        for(Boid boid : boids) {
            float distance = this.position.dist(boid.position);
            if(boid != this && distance < this.range * rangeWeight) {
                separationPoint.add(PVector.sub(boid.position, this.position).div(distance));
                boidsInRange++;
            }
        }
        if(boidsInRange > 0) {
            separationPoint.div(boidsInRange);
            separationPoint.limit(speedLimit);
            separationPoint.mult(overallWeight);
        }
        return separationPoint;
    }

    public PVector calculateAlignment(Boid[] boids, float rangeWeight, float overallWeight, float speedLimit) {
        PVector averageVelocity = new PVector(0, 0);
        int boidsInRange = 0;
        for(Boid boid : boids) {
            if(boid != this && this.position.dist(boid.position) < this.range * rangeWeight) {
                averageVelocity.add(boid.velocity);
                boidsInRange++;
            }
        }
        if(boidsInRange > 0) {
            averageVelocity.div(boidsInRange);
            averageVelocity.limit(speedLimit);
            averageVelocity.mult(overallWeight);
        }
        return averageVelocity;
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

    public void render(float scale) {
        noStroke();
        fill(255, 50);
        beginShape();
        for(PVector point : boidShape) {
            PVector newPoint = point.copy()
                .mult(scale)
                .rotate(this.velocity.heading())
                .add(position);
            vertex(newPoint.x, newPoint.y);
        }
        endShape(CLOSE);
    }
}