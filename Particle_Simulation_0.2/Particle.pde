class Particle{

  private float x, y, xSpeed, ySpeed, xForce, yForce, size, mass, averageForce, lowestForce, highestForce, standardDeviation;
  //constructor
  Particle(float X, float Y, float XSpeed, float YSpeed, float XForce, float YForce, float Size){
    
    x = X;
    y = Y;
    xSpeed = XSpeed;
    ySpeed = YSpeed;
    xForce = XForce;
    yForce = YForce;
    size = Size;
    
    mass = size;
  
  }
  
  public void eeForce(Particle _Particle){
  
    float _x = _Particle.getX();
    float _y = _Particle.getY();
    
    //distance between particles
    float r = dist(x, y, _x, _y);
    
    if(r > 0.001){
    
      float dx = x - _x; // x distance
      float dy = y - _y; // y distance
      
      //electron electron repulsion force calculation;
      float force = (kSlider.getValue() * 1.602e-19 * 1.602e-19) / (r * r);
      
      //normalize force
      float norm = sqrt(dx * dx + dy * dy);
      dx /= norm;
      dy /= norm;
      
      // add overall force for x and y components
      xForce += force * dx;
      yForce += force * dy;
    
    }
    
  }
  
  public void gravity(Particle _Particle){
  
    float _x = _Particle.getX();
    float _y = _Particle.getY();

    //distance between particles
    float r = dist(x, y, _x, _y);
    
    if(r > size){
    
      float _mass = _Particle.getMass();
    
      float dx = x - _x; //x distance
      float dy = y - _y; //y distance
    
      //gravity equation
      float Force = (Gslider.getValue() * mass * _mass) / (r * r);
    
      //normalize the force
      float norm = sqrt(dx * dx + dy * dy);
      dx /= norm;
      dy /= norm;
      
      //magnitude + x component of the force & same for y
      xForce -= Force * dx;
      yForce -= Force * dy;
    
    }
  
  }
  
  void checkInsideCollision(Particle _Particle){
  
    float _x = _Particle.getX();
    float _y = _Particle.getY();

    //distance between particles
    float r = dist(x, y, _x, _y);
    
    if(r < size){
      
      if(random(0,1) < 0.5){
         x += size - r;
         _x -= size - r;
      } else {
         x -= size - r;
         _x += size - r;
      }
      
     if(random(0,1) < 0.5){
       y += size - r;
       y -= size - r;
     } else {
       y -= size - r;
       _y += size - r;
     
     }
      

      
    }
  
  }
  
  boolean checkCollision(Particle _Particle){
    
    float _x = _Particle.getX();
    float _y = _Particle.getY();

    //distance between particles
    float r = dist(x, y, _x, _y);
    
    return r <= size;
  
  }
  
  void resolveCollisions(Particle _Particle){
    
    float _xSpeed = _Particle.getXSpeed();
    float _ySpeed = _Particle.getYSpeed();
    float _mass = _Particle.getMass();
    
    PVector velocity = new PVector(xSpeed, ySpeed);
    PVector _velocity = new PVector(_xSpeed, _ySpeed);
    
    PVector normal = PVector.sub(_velocity, velocity);
    
    normal.normalize();
    
    PVector relativeVelocity = PVector.sub(velocity, _velocity);
    
    float velocityAlongNormal = relativeVelocity.dot(normal);

    // If particles are moving towards each other, we handle the collision
    if (velocityAlongNormal < 0) {
      // Calculate the impulse (change in velocity)
      float impulse = 2 * velocityAlongNormal / (mass + _mass);

      // Update velocities based on the impulse
      velocity.sub(PVector.mult(normal, impulse * _mass));
      _velocity.add(PVector.mult(normal, impulse * mass));
    }
    
    xSpeed = velocity.x;
    ySpeed = velocity.y;
    _Particle.setXSpeed(_velocity.x);
    _Particle.setYSpeed(_velocity.y);
    
  }
  
  void separateParticles(Particle _Particle) {
    float _size = _Particle.getSize();
    float _x = _Particle.getX();
    float _y = _Particle.getY();
    float overlap = (size / 2 + _size / 2) - dist(x, y, _x, _y);
    if (overlap > 0) {
        PVector direction = new PVector(x - _x, y - _y);
        direction.normalize();
        
        x += direction.x * overlap / 2;
        y += direction.y * overlap / 2;
        _Particle.setX(_x - direction.x * overlap / 2);
        _Particle.setY(_y - direction.y * overlap / 2);
    }
}
  
  public void UpdateParticle(){
  
    xSpeed += xForce * deltaTime;
    ySpeed += yForce * deltaTime;
    
    x += xSpeed * deltaTime;
    y += ySpeed * deltaTime;
    
    keepInScreen();
    
    standardDeviation = max(standardDeviation, 1e-6);
    //color the particle according to the force acting on it;
    float forceMag = dist(0, 0, xForce, yForce);
    float normalizedForce = constrain((forceMag - averageForce) / (standardDeviation), -3, 3);
    float adjustForce = map(normalizedForce, -3, 3, 0, 1);
    color c = lerpColor(color(0, 0, 255), color(255, 0, 0), adjustForce);
    noStroke();
    fill(c);
    
    circle(x, y, size);
    
    xForce = 0;
    yForce = 0;
    
  }
  
  void keepInScreen(){

   if(x >= width - size || x <= size){
      
      if(x >= width - size)
        x = width - size;
      
      if(x <= size)
        x = size;
      
      xSpeed *= -0.5; 
    }

    if(y >= height - size || y <= size){
      
      if(y >= height - size)
        y = height - size;
      
      if(y <= size)
        y = size;
    
      ySpeed *= -0.5;
    
    }
}
  
  //setters
  public void setX(float X){x = X;}
  public void setY(float Y){y = Y;}
  public void setXSpeed(float XSpeed){xSpeed = XSpeed;}
  public void setYSpeed(float YSpeed){ySpeed = YSpeed;}
  public void setXForce(float XForce){xForce = XForce;}
  public void setYForce(float YForce){yForce = YForce;}
  //public void setSize(float Size){size = Size;}
  public void setMass(float Mass){mass = Mass;}
  public void setAverageForce(float AverageForce){averageForce = AverageForce;}
  public void setHighestForce(float HighestForce){highestForce = HighestForce;}
  public void setLowestForce(float LowestForce){lowestForce = LowestForce;} 
  public void setStandardDeviation(float SDV){standardDeviation = SDV;}
  
  //getters
  public float getX(){return x;}
  public float getY(){return y;}
  public float getXSpeed(){return xSpeed;}
  public float getYSpeed(){return ySpeed;}
  public float getXForce(){return xForce;}
  public float getYForce(){return yForce;}
  public float getSize(){return size;}
  public float getMass(){return mass;}
  

}
