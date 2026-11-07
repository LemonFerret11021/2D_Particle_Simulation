import controlP5.*;

float minMaxForce = 0.1, maxMaxForce = 1;
float Gmin = 6.67430e-5, Gmax = 6.67430;
float kMin = 1, kMax = 2000;
int particleNum = 1000;
float kDampMin = 0.1, kDampMax = 0.9;

float kDamp = 1;

float[] particleX = new float[particleNum],
particleY = new float[particleNum], 
particleSpeedX = new float[particleNum],
particleSpeedY = new float[particleNum],
particleForceX = new float[particleNum],
particleForceY = new float[particleNum],
particleRadius = new float[particleNum],
particleMass = new float[particleNum];

ControlP5 cp5;
Slider Gslider, kSlider, maxForceSlider, kDamping;


void setup(){
  
  fullScreen();
  
  //create slider
  cp5 = new ControlP5(this);
  
  float savedValues[] = loadSliderValues();
  
  //k slider
  kSlider = cp5.addSlider("k")
              .setPosition(50, 100)
              .setSize(1000, 20)
              .setRange(kMin, kMax)
              .setValue(savedValues[2]);
  
  // gravity slider
  Gslider = cp5.addSlider("G")
              .setPosition(50, 50)        
              .setSize(1000, 20)           
              .setRange(Gmin, Gmax)        
              .setValue(savedValues[3]);  
              
  kDamping = cp5.addSlider("kDamping")
              .setPosition(50, 200)        
              .setSize(1000, 20)           
              .setRange(kDampMin, kDampMax)        
              .setValue(savedValues[0]);   
  
  maxForceSlider = cp5.addSlider("Max Force")
              .setPosition(50, 150)        
              .setSize(1000, 20)           
              .setRange(minMaxForce, maxMaxForce)        
              .setValue(savedValues[1]);    
  
  //intialize particles
  for(int i = 0; i < particleNum; i++){
    
    //set size and mass
    particleRadius[i] = random(10,10);
    particleMass[i] = particleRadius[i];
    
    particleX[i] = random(0 + particleRadius[i], width - particleRadius[i]);
    particleY[i] = random(0 + particleRadius[i], height - particleRadius[i]);
    randomSeed(millis() * (long)particleX[i] * (long)particleY[i]);
    
    //particleSpeedX[i] = random(5, 10);
    //particleSpeedY[i] = random(5, 10);
    particleSpeedX[i] = random(-5,10);
    particleSpeedY[i] = random(-5,10);;
    
    if(random(1) < 0.5)
      particleSpeedX[i] *= -1;
      
    if(random(1) < 0.5)
      particleSpeedY[i] *= -1;
    
    particleForceX[i] = 0;
    particleForceY[i] = 0;
    
  }
  
}

void draw(){
  background(0);
  
  for(int i = 0; i < particleNum; i++){
    
    if(mousePressed){
      
     // Compute direction from particle to mouse
      float mdx = mouseX - particleX[i];
      float mdy = mouseY - particleY[i];
  
      // Compute distance
      float mouseDis = sqrt(mdx * mdx + mdy * mdy);
      
      if(mouseDis < 1) mouseDis = 1;
      
      mdx /= mouseDis;
      mdy /= mouseDis;
      
      if(mouseButton == RIGHT){
      
        particleForceX[i] -= mdx * 2;
        particleForceY[i] -= mdy * 2;
      
      } else if(mouseButton == LEFT){
      
        particleForceX[i] += mdx * 2;
        particleForceY[i] += mdy * 2;
      
      }
    
    }
    
    for(int ii = 0; ii < particleNum; ii++){
            
      float minDistance = (particleRadius[i] + particleRadius[ii]) * 1.5;
      
      float r = dist(particleX[i], particleY[i], particleX[ii], particleY[ii]);
      boolean computeGrav = true;
      
      
      if(r < minDistance){
      
        particleSpeedX[i] *= 0.9;
        particleSpeedY[i] *= 0.9;
        
        computeGrav = false;
      }
      if(computeGrav == true){
        gravity(i, ii);
      } else{
      
        kDamp =  kDamping.getValue();
      }
        
      electronElectron(i,ii);
      kDamp = 1;
      
    }
  
    updateParticles(i);
  
  }

  
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

void electronElectron(int i, int ii){
    
      float dx = particleX[i] - particleX[ii];  // X distance between i and ii
      float dy = particleY[i] - particleY[ii];  // Y distance between i and ii  
      float r = dist(particleX[i], particleY[i], particleX[ii], particleY[ii]);
      
      if(i != ii && r != 0){
         
        float force = (kSlider.getValue() * kDamp) / (r * r);
        
        
        
        float norm = sqrt(dx * dx + dy * dy);
          
        dx /= norm;
        dy /= norm;
        
   
        particleForceX[i] += force * dx;
        particleForceY[i] += force * dy;
        
        //float angle = atan2(dx, dy);
    
        //line(particleX[i], particleY[i], particleX[i] + 100*cos(angle), particleY[i] + 100*sin(angle)); 
        
      }
  
}

void gravity(int i, int ii){
   
     float r = dist(particleX[i], particleY[i], particleX[ii], particleY[ii]);
  
  
   if(i != ii && r != 0){
     
   float dx = particleX[i] - particleX[ii];  // X distance between i and ii
   float dy = particleY[i] - particleY[ii];  // Y distance between i and ii  
  
   float force = (Gslider.getValue() * particleMass[i] * particleMass[ii]) / (r * r);
   
   float norm = sqrt(dx * dx + dy * dy);
   dx /= norm;
   dy /= norm;
   
   particleForceX[i] -= force * dx;
   particleForceY[i] -= force * dy;
   
   //float angle = atan2(dx, dy);
    
   //line(particleX[i], particleY[i], particleX[i] + 100*cos(angle), particleY[i] + 100*sin(angle)); 
   
 } else if (r == 0){
   particleX[i] += 1;
 }
}

void updateParticles(int i){

    //float angle = atan2(particleForceY[i], particleForceX[i]);
    
    //line(particleX[i], particleY[i], particleX[i] + 100 * cos(angle), particleY[i] +  100 * sin(angle)); 
    
    particleSpeedX[i] += particleForceX[i];
    particleSpeedY[i] += particleForceY[i];
    
    
    keepInScreen(i);
     
    /*if(particleSpeedX[i] > maxSpeedSlider.getValue())
      particleSpeedX[i] = maxSpeedSlider.getValue();
      
    if(particleSpeedY[i] > maxSpeedSlider.getValue())
       particleSpeedY[i] = maxSpeedSlider.getValue();*/
    
    particleX[i] += particleSpeedX[i];
    particleY[i] += particleSpeedY[i];
    
    float forceMag = dist(0, 0, particleForceX[i], particleForceY[i]);
    
    float normalizedForce = constrain(forceMag / maxForceSlider.getValue(), 0, 1);
    color c = lerpColor(color(0, 0, 255), color(255, 0, 0), normalizedForce);
    
    
    noStroke();
    fill(c);
    circle(particleX[i], particleY[i], particleRadius[i]);
    
    particleForceX[i] = 0;
    particleForceY[i] = 0;
    
    
    
}


void keepInScreen(int i){

   if(particleX[i] >= width - particleRadius[i] || particleX[i] <= particleRadius[i]){
      
      if(particleX[i] >= width - particleRadius[i])
        particleX[i] = width - particleRadius[i];
      
      if(particleX[i] <= particleRadius[i])
        particleX[i] = particleRadius[i];
      
      particleSpeedX[i] *= -0.5; 
    }

    if(particleY[i] >= height - particleRadius[i] || particleY[i] <= particleRadius[i]){
      
      if(particleY[i] >= height - particleRadius[i])
        particleY[i] = height - particleRadius[i];
      
      if(particleY[i] <= particleRadius[i])
        particleY[i] = particleRadius[i];
    
      particleSpeedY[i] *= -0.5;
    
    }
  
}
