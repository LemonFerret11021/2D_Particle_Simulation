import controlP5.*;

ControlP5 cp5;
Slider Gslider, kSlider, maxForceSlider, kDamping;

float Gmin = 6.67430e-11, Gmax = 6.67430e1;
float kMin = 8.99e1, kMax = 8.99e16;
float minMaxForce = 1e-20, maxMaxForce = 1;
float kDampMin = 0.1, kDampMax = 0.9;

float lastTime;
public float deltaTime;

int particlesNum = 1000;

float averageForce = 0;
float sumForces = 0;

ArrayList<Particle> particles = new ArrayList<Particle>();

void setup(){
  
  lastTime = millis();
  
  fullScreen();
  
  float savedValues[] = loadSliderValues();
  
  sliders(savedValues);
  
  for(int i = 0; i < particlesNum; i++){
  
    particles.add(new Particle(
                                random(0, width),  //x
                                random(0, height), //y
                                0.0,               //xSpeed
                                0.0,               //ySpeed
                                0.0,               //xForce
                                0.0,               //yForce
                                20                 //size
    ));
                                 
  }
   
}

void draw(){
  
  computeDeltaTime();
  
  background(0);
  
  float sumForces = 0;
  float highestForce = 0;
  float lowestForce = 0;
  float squaredSum = 0;
  
  for(int i = 0; i < particlesNum; i++){
  
    for(int ii = 0; ii < particlesNum; ii++){
    
      if(i != ii){
        
        
        
          if(particles.get(i).checkCollision(particles.get(ii))){
        particles.get(i).resolveCollisions(particles.get(ii));
        particles.get(i).separateParticles(particles.get(ii));
        }
        particles.get(i).gravity(particles.get(ii));
        particles.get(i).eeForce(particles.get(ii));
        //particles.get(i).checkInsideCollision(particles.get(ii));
        


      }
    
    }
    
    float thisXForce = particles.get(i).getXForce();
    float thisYForce = particles.get(i).getYForce();
    
    float thisForce = dist(0, 0, thisXForce, thisYForce);
    
    if(thisForce < lowestForce)
      lowestForce = thisForce;
      
    if(thisForce > highestForce)
      highestForce = thisForce;
      
    
    sumForces += thisForce;
    squaredSum += thisForce * thisForce;
    
    
    particles.get(i).UpdateParticle();
    
  }
   
  averageForce = sumForces/particlesNum;
  
  float variance = (squaredSum / particlesNum) - (averageForce * averageForce);
  float SDV = sqrt(variance);

  for(int i = 0; i < particlesNum; i++){
  
    particles.get(i).setLowestForce(lowestForce);
    particles.get(i).setHighestForce(highestForce);
    particles.get(i).setAverageForce(averageForce);
    particles.get(i).setStandardDeviation(SDV);
  
  }

}


void mousePressed(){

  if(mouseButton == RIGHT){
  
          particles.add(new Particle(
                                mouseX,            //x
                                mouseY,            //y
                                0.0,               //xSpeed
                                0.0,               //ySpeed
                                0.0,               //xForce
                                0.0,               //yForce
                                20                 //size
    ));
    
    particlesNum ++;
  
  }

}

void computeDeltaTime() {
  // Calculate deltaTime in seconds
  float currentTime = millis();
  deltaTime = (currentTime - lastTime) / 1000.0; // Convert milliseconds to seconds
  lastTime = currentTime;

}

void sliders(float[] savedValues){

  //create slider
  cp5 = new ControlP5(this);
  
  //k slider
  kSlider = cp5.addSlider("k")
              .setPosition(50, 100)
              .setSize(1000, 20)
              .setRange(kMin, kMax)
              .setValue(savedValues[2]);
  
  // G slider
  Gslider = cp5.addSlider("G")
              .setPosition(50, 50)        
              .setSize(1000, 20)           
              .setRange(Gmin, Gmax)        
              .setValue(savedValues[3]);  
              
  // kDamping slider            
  kDamping = cp5.addSlider("kDamping")
              .setPosition(50, 200)        
              .setSize(1000, 20)           
              .setRange(kDampMin, kDampMax)        
              .setValue(savedValues[0]);   
  
  //particle Color gradient adjuster slider
  maxForceSlider = cp5.addSlider("Max Force")
              .setPosition(50, 150)        
              .setSize(1000, 20)           
              .setRange(minMaxForce, maxMaxForce)        
              .setValue(savedValues[1]);
  
  
}

void dispose() {
  saveSliderValues(kDamping.getValue(), maxForceSlider.getValue(), kSlider.getValue(), Gslider.getValue());
}

// Function to save slider value to file
void saveSliderValues(float kDamping, float maxForce, float k, float G) {
  String[] data = { str(kDamping), str(maxForce), str(k), str(G) };
  saveStrings("saveFile.txt", data);
}

// Function to load slider value from file
float[] loadSliderValues() {
  String[] data = loadStrings("saveFile.txt");
  if (data != null && data.length >= 4) {
    return new float[] {float(data[0]), float(data[1]), float(data[2]), float(data[3])};  // Convert string to float
  }
  return new float[] {kDampMin, minMaxForce, kMin, Gmin}; // Default value if file doesn't exist
}
