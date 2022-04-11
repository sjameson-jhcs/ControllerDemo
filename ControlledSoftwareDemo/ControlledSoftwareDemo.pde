// Java libraries to be used for getting the window position on screen
import java.awt.AWTException;
import java.awt.Robot;
import java.awt.event.KeyEvent;
import java.io.*;
// Serial library used for serial communication
import processing.serial.*;
Serial controller_serial_port;

// Pen object is a custom class used for drawing circles
Pen pen;
// Robot object is used to move the computer cursor
Robot robot;

// Method that runs once at the beginning of the program
void setup() {
  find_and_connect_to_usb_controller("usbserial");
  size(500, 500);
  // Set the background to be white just once at the beginning
  background(255);
  pen = new Pen();
  try {
    robot = new Robot();
  }
  catch (AWTException e) {
    e.printStackTrace();
  }
  controller_serial_port.clear();
}

// Search the list of available usb devices to find one with the name that passed
// This name will vary from device to device. You can change the hard coded name in the setup method
// Only part of the name is needed. It does not need to be a full match
void find_and_connect_to_usb_controller(String controller_serial_name) {
  int serial_port = -1;
  // Loop through all available usb devices
  for (int i = 0; i < Serial.list().length; i++) {
    // If the desired name is present then store the port number and stop looking
    if (Serial.list()[i].indexOf(controller_serial_name) >= 0) {
      serial_port = i;
      break;
    }
  }
  // If the named device is found then establish a connection
  if (serial_port >= 0) {
    controller_serial_port = new Serial(this, Serial.list()[serial_port], 9600);
  }
  // If the named device is not found then print an error message to console and exit the program
  else {
    println("Unable to find device named " + controller_serial_name + " in this list of available devices. Check the name of your device in the list below and adjust the code in the [setup] method.");
    printArray(Serial.list());
    exit();
  }
}

// Method that runs continuously
void draw() {
  pen.run();
}

// Listener method that triggers when a serial event occurs
void serialEvent(Serial port) {
  // Grab any incoming controller data and send it off to be processed
  handle_control_data(port.readStringUntil(']'));
}

// Check for a data stream that is incomplete or out of order
// This is most likely to occur when the program first starts and picks up data mid-transmission
String scrub_data(String data) {
  if (data == null) return "";
  // Look for data that is in the format "[a,b,c,]"
  int opening_brace_index = data.lastIndexOf("[");
  int closing_brace_index = data.lastIndexOf("]");
  // If either brace is missing or out of order then abort by returning an empty string
  if (opening_brace_index < 0 || closing_brace_index < 0 || opening_brace_index > closing_brace_index) return "";
  // Only return the LAST data in that is in proper braces. In case 2 data sets are present we want to use only the newest set.
  return data.substring(opening_brace_index+1, closing_brace_index);
}

// Parse the data stream and use the values as needed
void handle_control_data(String data) {
  String scrubbed_data = scrub_data(data);
  // Ideally the processing code will run much faster than data is streaming in via usb
  // So we will only take action when data is available
  int data_index = 0;
  String data_string = "";
  int data_value = 0;
  while (scrubbed_data.length() > 1 && data_index < scrubbed_data.length()) {
    try {
      data_string = scrubbed_data.substring(0, scrubbed_data.indexOf(","));
      scrubbed_data = scrubbed_data.substring(scrubbed_data.indexOf(",")+1, scrubbed_data.length());
      data_value = Integer.parseInt(data_string);
    }
    catch (NumberFormatException ex) {
      println("WARNING: Bad Data - data is expected to be a number. Non-number data has been ignored.");
    }
    if (data_index == 0) {
      if (data_value == 1) pen.is_pen_down = true;
      else pen.is_pen_down = false;
    }
    if (data_index == 1) {
      pen.velocity.x = map(data_value, 0, 1023, 5, -5);
    }
    if (data_index == 2) {
      pen.velocity.y = map(data_value, 0, 1023, 5, -5);
    }
    if (data_index == 3) {
      pen.red = (int)map(data_value, 0, 1023, 0, 255);
    }
    if (data_index == 4) {
      pen.green = (int)map(data_value, 0, 1023, 0, 255);
    }
    if (data_index == 5) {
      pen.blue = (int)map(data_value, 0, 1023, 0, 255);
    }
    data_index++;
  }
}

void keyPressed() {
  exit();
}


final int debounce_delay = 50;
boolean is_button_available = true;
boolean is_button_bouncing = false;
int button_flip_timestamp = 0;
// This is an example of debouncing a button with a 50ms delay
// This example is not used currently
boolean debounce_button(int button_state){
  // If the button was bouncing but the delay time has passed then set it to no longer be bouncing
  if(is_button_bouncing && millis() - button_flip_timestamp > debounce_delay){
    is_button_bouncing = false;
  }
  // Ignore all inputs while bouncing
  if (!is_button_bouncing) {
    // An initial button press has occured
    if (button_state == 1 && is_button_available) {
      button_flip_timestamp = millis();
      is_button_bouncing = true;
      is_button_available = false;
      return true;
    }
    // The button was just released
    if(button_state == 0 && !is_button_available){
      button_flip_timestamp = millis();
      is_button_bouncing = true;
      is_button_available = true;
    }
  }
  return false;
}
