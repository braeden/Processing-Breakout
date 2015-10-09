// Classes
class Ball {
  float x, y;
  float vx, vy;
  float r;
  int hitcnt = 0;
  boolean redHit = false;
  boolean yellowHit = false;
  boolean topHit = false;
  int v_mult;

  Ball(float xi, float yi, int vm) {
    r = 10;
    v_mult = vm;
    x = xi;
    y = yi;
    vy = 170;
    int[] sign = {-1, 1};
    vx = random(100, 170) * sign[round(random(1))]; // random number from -100 to 170 or 0.3 to 1
  }
  
  void checkCollisions() {   
    if (y < height - r) { // in between left edge and right edge
      if (x <= r ) { // hit top edge or bottom edge
        x = r;
        vx = -vx;
      } else if (x >= width - r) {
        x = width - r;
        vx = -vx;
      } else if(y <= r) {
        y = r;
        vy = -vy;
        if (!topHit && redHit) {
          topHit = true;
          p1.w = p1.w/2;
        }  
      }else {
        collidePaddle(p1);
      }
    } else {
      lives--;
      startGame();
    }
    int i = 0;
    for (Brick b: bricks) {
      if (b != null){
        collideBrick(b, i);
      }
      i++;
    }
  }
  
 void collidePaddle(Paddle p) {
    float projx = collide(x - r, x + r, p.x - p.w/2, p.x + p.w/2);
    if (projx == 0) return; // no overlap with X
    
    float projy = collide(y - r, y + r, p.y - p.h/2, p.y + p.h/2);
    if (projy == 0) return; // no overlap with Y
        
    if (abs(projx) <= abs(projy)) { // hit paddle
      x += projx; // rectify collision
      vx = -vx; // bounce
    } else {
      float dist = p.x - x;
      vx = -(dist * v_mult); //ball increases speed if closer to the corners
      y += projy; // rectify collision
      vy = -vy; // bounce
    }
  }
  
  void collideBrick(Brick b, int i) {
    float projx = collide(x - r, x + r, b.x - b.w/2, b.x + b.w/2);
    if (projx == 0) return; // no overlap with X
    
    float projy = collide(y - r, y + r, b.y - b.h/2, b.y + b.h/2);
    if (projy == 0) return; // no overlap with Y
        
    if (abs(projx) <= abs(projy)) { // hit paddle
      x += projx; // rectify collision
      vx = -vx; // bounce
    } else {
      y += projy; // rectify collision
      vy = -vy; // bounce
    }
    bricks[i] = null;
    if (i < 20) {
      score += 5;
    } else if (i < 40) {
      score += 4;
    } else if (i < 60) {
      score += 3;
    } else if (i < 80) {
      score += 2;
    } else if (i < 100) {
      score += 1;
    }
    hitcnt++;
    if (i < 20 && !redHit) { //Check criteria for speedup
      redHit = true;
      increaseSpeed();
    } else if (i < 40 && !yellowHit) {
      yellowHit = true;
      increaseSpeed();
    } else if (hitcnt == 4) {
      increaseSpeed();
    } else if (hitcnt == 12) {
      increaseSpeed();
    }
  }
  
  void increaseSpeed() {
    vx *= 1.5;
    vy *= 1.5; 
    v_mult *= 1.5;
  }
  
  void move(float dt) {
    x += vx*dt;
    y += vy*dt;
  }
  
  void draw() {
    ellipse(x, y, 2*r, 2*r);
  }
}

// returns the projection of the line (c1, c2) on line (c3, c4)
float collide(float c1, float c2, float c3, float c4) {
  if (c1 > c3 && c1 < c4) { // left edge overlap
    return(c4 - c1);
  } else if (c2 > c3 && c2 < c4) { // right edge overlap
    return(c3 - c2);
  }
  return(0); // no overlap  
}


class Paddle {
  float x, y;
  float s;
  float w, h;
  boolean left, right;
  
  Paddle(float xi, float yi) {
    w = 100;
    h = 10;
    s = 200; // Paddle Speed
    x = xi;
    y = yi;
  }
  
  void move(float dt) {
    x = mouseX;
    if (x >= (0 + w/2)) {
      x -= w/2;
    } else if (x <= (width - w/2)) {
      x = w/2;
    }
  }
  
  void draw() {
    rect(x, y, w, h);
  }
}


class Brick {
  float x,y;
  float w, h;
  color c;
  Brick(float inx, float iny, float inw, float inh, color inc) {
    x = inx;
    y = iny;
    w = inw;
    h = inh;
    c = inc;
  }
  
  void draw() {
    noStroke();
    fill(c);
    rect(x, y, w, h);
  }
}


// GLOBALS
Ball b;
Paddle p1;
Brick[] bricks;
int lives = 5;
int score = 0;
boolean redraw = false;
boolean paused = false;
long t;

// GAME FUNCTIONS
void startGame() {
  p1 = new Paddle(float(width)/2.0, height-10);
  b = new Ball(float(width)/2.0, float(height)/2.0, 10);
}

void endGame() {
  b.vx = 0;
  b.vy = 0;
  b = new Ball(float(width)/2.0, float(height)/2.0, 10);
  p1 = new Paddle(float(width)/2.0, height-10);
  cursor();
}

void restartGame() {
  redraw = true;
  b.v_mult = 10;
  setup();
}
void keyPressed() {
  if (key == 'r' || key == 'R') {
    lives = 3;
    score = 0;
    redraw = false;
    setup();
  } else if (key == 'p'  || key == 'P') {
    paused = !paused;
  }
}
float distance(float x1, float y1, float x2, float y2) {
  return(sqrt(sq(x2 - x1) + sq(y2 - y1)));
}

// EVENTS

void setup() {
  size(800, 600);
  ellipseMode(CENTER);
  rectMode(CENTER);
  frameRate(70);
  textSize(20);
  textAlign(CENTER);
  noCursor();
  
  t = System.nanoTime();

  bricks = new Brick[100];
  float wdth = width/10; //Standard Brick width
  float hght = height/30; //Standard Brick height
  float plusx = wdth/2; //offset from side of screen x axis
  float plusy = hght*3; //offset from side of screen x axis
  color col = color(0,0,0);
  for (int i=0; i<10; i++) {//Y
    for (int j=0; j<10; j++) {//X
      if (i<2) {
        col = color(255,0,0);
      } else if (i<4) {
        col = color(255,165,0);
      } else if (i<6) {
        col = color(230,230,0);
      } else if (i<8) {
        col = color(0,230,0);
      } else if (i<10) {
        col = color(0,200,200);
      }
      bricks[i*10+j] = new Brick(wdth*j+plusx, hght*i+plusy, wdth-2, hght-2, col);
    }
  }
  startGame();
}

void draw() {
  
  long ct = System.nanoTime();
  float dt = (ct - t) / 1000000000.0;
  t = ct;
  if (!focused) { paused = true; }
  background(255);
  if (lives == 0) {
    endGame();
    textAlign(CENTER);
    textSize(50);
    text("Gameover", width/2, height/2+50);
    textSize(30);
    text("Press 'R' to restart", width/2, height/2+100);
    textSize(20);
  } else if (paused) {
    //cursor();
    textAlign(CENTER);
    textSize(50);
    text("Paused", width/2, height/2+50);
    textSize(30);
    text("Press 'P' to resume", width/2, height/2+100);
    textSize(20);
  }
  // DRAW 
  stroke(0);
  fill(100);
  b.draw();
  p1.draw();
  int i = 0;
  for (Brick b: bricks) {
    if (b != null) {
      b.draw();
      i++;
    }
  }
  if (i == 0 && !redraw) {
    restartGame();
  }
  fill(0);
  text("Lives: " + lives, 40, 25);
  text("Score: " + score, width-60, 25);
  if (!paused) {
    b.checkCollisions();
    p1.move(dt);
    b.move(dt); 
  }
}