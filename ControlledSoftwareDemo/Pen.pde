final int pen_diameter_min = 1;
final int pen_diameter_max = 50;
final int pen_correction_x = 0;
final int pen_correction_y = 30;

// Frame objec it used to get the position of the window on the screen
java.awt.Frame outer_window;

class Pen {
  PVector position;
  PVector velocity;
  int diameter;
  boolean is_pen_down = false;
  int red = 0;
  int green = 0;
  int blue  = 0;

  // Constructor method
  Pen() {
    // Set the pen in the middle of the drawing surface
    position = new PVector(width/2, height/2);
    velocity = new PVector(0, 0);
    // Start the pen size at half the maximum
    diameter = (pen_diameter_min + pen_diameter_max)/2;
    // Define the window object so that the position can be located later
    outer_window = (java.awt.Frame) ((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame();
  }

  // Method that runs every frame
  void run() {
    println(red + "," + green + "," + blue);
    move();
    show_cursor();
    mark_canvas();
  }

  // Move the pen based on its speed read from the controller
  // Limit the pen position to be inside the screen
  void move() {
    position = PVector.add(position, velocity);
    position.x = max(position.x, 0);
    position.x = min(position.x, width);
    position.y = max(position.y, 0);
    position.y = min(position.y, height);
  }

  // Move the computer mouse to be on top of the drawing surface where drawing will occur
  void show_cursor() {
    // Window position + pen position on screen + a correction factor due to title bar height and cursor placement
    robot.mouseMove(outer_window.getX() + (int)position.x + pen_correction_x, outer_window.getY() + (int)position.y + pen_correction_y);
  }
  
  // Draw circles only if the button is pressed
  void mark_canvas() {
    if (is_pen_down) {
      fill(red, green, blue);
      ellipse(position.x, position.y, diameter, diameter);
    }
  }
}
