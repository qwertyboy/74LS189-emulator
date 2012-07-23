/*
74LS189 Emulator

This sketch is to replicate the funtions of the 74LS189 SRAM
logic chip. This is not pin-compatible, but is feature-compatible.
More features, such as serial access, will be available at a later
date.

Data is stored in an array for ease of use.
*/

//Main data array. We use boolean so we only have 1's and 0's
boolean ram_data[16][4] = {
  {0,0,0,0},
  {0,0,0,0},
  {0,0,0,0},
  {0,0,0,0},
  {0,0,0,0},
  {0,0,0,0},
  {0,0,0,0},
  {0,0,0,0},
  {0,0,0,0},
  {0,0,0,0},
  {0,0,0,0},
  {0,0,0,0},
  {0,0,0,0},
  {0,0,0,0},
  {0,0,0,0},
  {0,0,0,0}
};

//Define some schtuff
#define write_en 2
#define chip_sel 3
#define address 0
#define data 1

//Address inputs are 4-7
boolean address_vals[] = {0, 0, 0, 0};
byte address_byte;

//Data inputs are 8-11
boolean data_vals[] = {0, 0, 0, 0};

//Inverted data outputs are 12-15
boolean notdata[] = {0, 0, 0, 0};

//Write-enable and chip select values
boolean write_en_state = 1;
boolean chip_sel_state = 1;


void setup(){
  //Set up inputs
  pinMode(write_en, INPUT);
  pinMode(chip_sel, INPUT);
  
  //The rest is just a quick way to set up successive pins
  for(byte input_pin = 4; input_pin < 12; input_pin++){
    pinMode(input_pin, INPUT);
  }
  
  //for(byte data_in = 8; data_in < 12; data_in++){
  //  pinMode(data_in, INPUT);
  //}
  
  for(byte data_out = 12; data_out < 16; data_out++){
    pinMode(data_out, OUTPUT);
  }
}

void loop(){
  //Get status of pins
  chip_sel_state = digitalRead(chip_sel);
  write_en_state = digitalRead(write_en);
  
  if(chip_sel_state == 0){
    //Read the address pins and convert them into a useable number
    readPins(address);
    
    for(byte index = 0; index < 4; index++){
      bitWrite(address_byte, index, address_vals[index]);
    }
    
    if(write_en_state == 0){
      //Read the data pins
      readPins(data);
      
      //Use the address number that we figured out for the correct line
      //in the memory array. Use a simple for loop to index the column.
      //Also invert the data and store it in the output array.
      for(byte index = 0; index < 4; index++){
        ram_data[address_byte][index] = data_vals[index];
        notdata[index] = !ram_data[address_byte][index];
      }
    }
    
    //Output the inverted data onto the correct pins.
    for(byte output_pin = 12; output_pin < 16; output_pin++){
      for(byte index = 0; index < 4; index++){
        digitalWrite(output_pin, notdata[index]);
      }
    }
  }
}



//This is a general purpose function to read pin states. To read
//address pins, "type" should be "0". To read data pins, "type"
//should be "1".
void readPins(boolean type){
  byte low_pin;
  byte high_pin;
  byte pin;
  byte index;
  boolean pin_state;
  
  boolean temp_data[] = {0, 0, 0, 0};
  boolean temp_index;
  
  //Give pin-to-read variables values dependent on what pins we
  //want to read
  if(type == 0){
    low_pin = 4;
    high_pin = 8;
  }
  
  if(type == 1){
    low_pin = 8;
    high_pin = 12;
  }
  

  //Main for loop to read the pins requested, stores them in a
  //temporary array
  for(pin = low_pin; pin < high_pin; pin++){
    for(index = 0; index < 4; index++){
      pin_state = digitalRead(pin);
      temp_data[index] = pin_state;
    }
  }
  
  
  //Transfer the data into the correct array
  if(type == 0){
    for(temp_index = 0; temp_index < 4; temp_index++){
      address_vals[temp_index] = temp_data[temp_index];
    }
  }
  
  if(type == 1){
    for(temp_index = 0; temp_index < 4; temp_index++){
      data_vals[temp_index] = temp_data[temp_index];
    }
  }
}
