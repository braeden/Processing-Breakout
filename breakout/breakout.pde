// Classes
class Ball {
  float x, y;
  float vx, vy;
  float r;
  
  Ball() {
    r = 10;
  }
  
  void initialize(float xi, float yi) {
    x = xi;
    y = yi; 
    vy = 1.5;
    int[] sign = {-1, 1};
    vx = -(random(0.3, 1) * sign[round(random(1))]); // random number from -1 to -0.3 or 0.3 to 1
  }
  
  void checkCollisions() {   
    if (x > 0 && x < float(width)) { // in between left edge and right edge
      if (y <= 0 || y > height) // hit top edge or bottom edge
        vy = -vy;
      else {        
        if (collideCorners(p1)|| collideLeftOrRight(p1)) { // corner and left or right edge
          vx = -vx;
        } else if (collideTopOrBottom(p1)){ // top or bottom edge
          vy = -vy;
        }
      }
    } else if (x <= 0 || x > width) { // hit left edge or right edge
       vx = -vx;
    }
  }
  
  boolean collideTopOrBottom(Paddle p) {
    return((abs(p.y - p.h/2 - y) <= r || abs(p.y + p.h/2 - y) <= r) && x >= p.x - p.w/2 && x <= p.x + p.w/2);
  }
  
  boolean collideLeftOrRight(Paddle p) {
    return((abs(p.x - p.w/2 - x) <= r || abs(p.x + p.w/2 - x) <= r) && y >= p.y - p.h/2 && y <= p.y + p.h/2);
  }
  
  boolean collideCorners(Paddle p) {
    return(distance(x, y, p.x - p.w/2, p.y - p.h/2) <= r || distance(x, y, p.x + p.w/2, p.y - p.h/2) <= r || distance(x, y, p.x - p.w/2, p.y + p.h/2) <= r || distance(x, y, p.x + p.w/2, p.y + p.h/2) <= r);
  }  
  
  boolean collide(Paddle p) {
    return(collideTopOrBottom(p) || collideLeftOrRight(p) || collideCorners(p));
  }
  
  void move() {
    x += vx;
    y += vy;
  }
  
  void draw() {
    ellipse(x, y, 2*r, 2*r);
  }
}

class Paddle {
  float x, y;
  float s;
  float w, h;
  boolean left, right;
  
  Paddle() {
    w = 100;
    h = 10;
    s = 1.5; // Paddle Speed
    
    left = false;
    right = false;
  }
  
  void initialize(float xi, float yi) {
    x = xi;
    y = yi;
  }
  
  void move() {
    if (left && x > (0 + h/2)) {
      x -= s;
      
      if (b.collide(this))
        b.y -= s+1;
    } else if (right && x < (width - h/2)) {
      x += s;
      
      if (b.collide(this))
        b.x += s+1;
    }
  }
  
  void draw() {
    rect(x, y, w, h);
  }
}

// GLOBALS
Ball b;
Paddle p1;

// GAME FUNCTIONS
void startGame() {
  b.initialize(float(width)/2.0, float(height)/2.0);
  p1.initialize(float(width)/2.0, height-15 );
}

float distance(float x1, float y1, float x2, float y2) {
  return(sqrt(sq(x2 - x1) + sq(y2 - y1)));
}

// EVENTS
void keyPressed() {
    if (keyCode == LEFT) {
      p1.left = true;
    } else if (keyCode == RIGHT) {
      p1.right = true;
    }
}

void keyReleased() {
    if (keyCode == LEFT) {
      p1.left = false;
    } else if (keyCode == RIGHT) {
      p1.right = false;
    }
}

void setup() {
  size(800, 600);
  ellipseMode(CENTER);
  rectMode(CENTER);
  frameRate(360);
  
  b = new Ball();
  p1 = new Paddle();
  
  startGame();
}

void draw() {
  background(255);
  
  // DRAW  
  stroke(0);
  fill(100);
  b.draw();
  p1.draw();
  
  // MOVE PADDLES
  p1.move();
 
  // MOVE BALL
  b.checkCollisions();
  b.move();  
}