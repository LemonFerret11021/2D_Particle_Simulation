class Particle{

  private PVector position = new PVector(), velocity = new PVector(), force = new PVector();
  private float radius, mass, averageForce, standardDeviation;
  
  //constructor
  Particle(PVector _position, PVector _velocity, PVector _force, float _radius){
    
    position.set(_position);
    velocity.set(_velocity);
    force.set(_force);
    radius = _radius;
    mass = radius;
  
  }
  
  Particle(PVector _position, float _mass){
  
    position.set(_position);
    mass = _mass;
  
  }
  
  public void eeForce(Particle _Particle){
    PVector _position = _Particle.getPosition();
    
    //distance between particles
    float r = dist(position.x, position.y, _position.x, position.y);
    
    if(r > 0.001){
    
      float dx = position.y - _position.x; // x distance
      float dy = position.y - _position.y; // y distance
      
      //electron electron repulsion force calculation;
      float newForce = (kSlider.getValue() * 1.602e-19 * 1.602e-19) / (r * r);
      
      //normalize force
      float norm = sqrt(dx * dx + dy * dy);
      dx /= norm;
      dy /= norm;
      
      // add overall force for x and y components
      force.x += newForce * dx;
      force.y += newForce * dy;
    
    }
    
  }
  
  public void gravity(Particle _Particle){
     
    PVector _position = _Particle.getPosition();

    //distance between particles
    float r = dist(position.x, position.y, _position.x, _position.y);
    
    if(r > radius){
    
      float _mass = _Particle.getMass();
    
      float dx = position.x - _position.x; //x distance
      float dy = position.y - _position.y; //y distance
    
      //gravity equation
      float newForce = (Gslider.getValue() * mass * _mass) / (r * r);
    
      //normalize the force
      float norm = sqrt(dx * dx + dy * dy);
      dx /= norm;
      dy /= norm;
      
      //magnitude + x component of the force & same for y
      force.x -= newForce * dx;
      force.y -= newForce * dy;
    
    }
  
  }
  
  public void moveParticle(){
    
    if((mouseX < position.x + radius && mouseX > position.x - radius) && (mouseY < position.y + radius && mouseY > position.y - radius)){
      position.set(new PVector(mouseX, mouseY));
      force.set(new PVector(0,0));
    }
    
  }
  
  public void mouseForce(){

    //distance between particles
    float r = dist(position.x, position.y, mouseX, mouseY);
    
    if(r > radius && r < 250){
    
      float dx = position.x - mouseX; //x distance
      float dy = position.y - mouseY; //y distance
    
      //gravity equation
      //float newForce = (Gslider.getValue() * mass * _mass) / (r * r);
    
      //normalize the force
      float norm = sqrt(dx * dx + dy * dy);
      dx /= norm;
      dy /= norm;
      
      //magnitude + x component of the force & same for y
      force.x -= 800 * dx;
      force.y -= 800 * dy;
    
    }
  
  }
  
  void checkInsideCollision(Particle _Particle){
    
    PVector _position = _Particle.getPosition();

    //distance between particles
    float r = dist(position.x, position.y, _position.x, _position.y);
    
    if(r < radius){
      
      if(random(0,1) < 0.5){
         position.x += radius - r;
         _position.x -= radius - r;
      } else {
         position.x -= radius - r;
         _position.x += radius - r;
      }
      
     if(random(0,1) < 0.5){
       position.y += radius - r;
       position.y -= radius - r;
     } else {
       position.y -= radius - r;
       _position.y += radius - r;
     
     }
      

      
    }
  
  }
  
  boolean checkCollision(Particle _Particle){
    
    PVector _position = _Particle.getPosition();

    //distance between particles
    float r = dist(position.x, position.y, _position.x, _position.y);
    
    return r <= radius;
  
  }
  
  void resolveCollisions(Particle _Particle){
    
    PVector _velocity = _Particle.getVelocity();

    float _mass = _Particle.getMass();
    
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
    
    _Particle.setVelocity(_velocity);
    
  }
  
  void separateParticles(Particle _Particle) {
    
    PVector _position = _Particle.getPosition();
    float _size = _Particle.getRadius();
    
    float overlap = (radius / 2 + _size / 2) - dist(position.x, position.y, _position.x, _position.y);
    if (overlap > 0) {
        PVector direction = new PVector(position.x - _position.x, position.y - _position.y);
        direction.normalize();
        
        position.x += direction.x * overlap / 2;
        position.y += direction.y * overlap / 2;
        _Particle.setPosition(new PVector(_position.x - direction.x * overlap / 2, _position.y - direction.y * overlap / 2));
    }
}
  
  public void UpdateParticle(){
    
    velocity.x += force.x * deltaTime;
    velocity.y += force.y * deltaTime;
    
    position.x += velocity.x * deltaTime;
    position.y += velocity.y * deltaTime;
    
    keepInScreen();
    
    standardDeviation = max(standardDeviation, 1e-6);
    //color the particle according to the force acting on it;
    float forceMag = dist(0, 0, force.x, force.y);
    float normalizedForce = constrain((forceMag - averageForce) / (standardDeviation), -3, 3);
    float adjustForce = map(normalizedForce, -3, 3, 0, 1);
    color c = lerpColor(color(0, 0, 255), color(255, 0, 0), adjustForce);
    noStroke();
    fill(c);
    
    circle(position.x, position.y, radius);
    
    force.x = 0;
    force.y = 0;
    
  }
  
  void keepInScreen(){

   if(position.x >= width - radius || position.x <= radius){
      
      if(position.x >= width - radius)
        position.x = width - radius;
      
      if(position.x <= radius)
        position.x = radius;
      
      velocity.x *= -0.5; 
    }

    if(position.y >= height - radius || position.y <= radius){
      
      if(position.y >= height - radius)
        position.y = height - radius;
      
      if(position.y <= radius)
        position.y = radius;
    
      velocity.y *= -0.5;
    
    }
}
  
  //setters
  public void setPosition(PVector pos){position.set(pos);}
  public void setVelocity(PVector vel){velocity.set(vel);}
  public void setForce(PVector _force){force.set(_force);}
  public void setSize(float rad){radius = rad;}
  public void setMass(float Mass){mass = Mass;}
  public void setAverageForce(float AverageForce){averageForce = AverageForce;} 
  public void setStandardDeviation(float SDV){standardDeviation = SDV;}
  
  //getters
  public PVector getPosition(){return new PVector(position.x, position.y);}
  public PVector getVelocity(){return new PVector(velocity.x, velocity.y);}
  public PVector getForce(){return new PVector(force.x, force.y);}
  public float getRadius(){return radius;}
  public float getMass(){return mass;}
  

}
