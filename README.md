# FreePascal-Serial-Relays
Library to control Serial relays with Free Pascal

This is a library to control Serial Relays that use commands:

* A0 01 01 A2 Open the First Way
* A0 01 00 A1 Closes the First Way
* A0 02 01 A2 Opens the Second Way
* A0 02 00 A1 Closes the Second Way
* A0 03 01 A2 Opens the 3rd Way
* A0 03 00 A1 Closes the 3rd Way
* ...

Note that these are all backwards.. it should have been:
* A0 01 01 A2 Closes the First Relay
* A0 01 00 A1 Opens the First Relay
* A0 02 01 A2 Closes the Second Relay
* A0 02 00 A1 Opens the Second Relay
* A0 03 01 A2 Closes the Third Relay
* A0 03 00 A1 Opens the Third Relay
* ...



These Relays Control Boards are inexpensive and are made to attach to common relay boards

It was tested with these boards:
--------------------------------
* 16 Relay Controler only:  https://www.amazon.com/gp/product/B07V42R6V7
* 16 Relay Board:    https://www.amazon.com/gp/product/B07Y2X4F77
 

It allows you to turn any relay on or off programmatically

This controler board provides NO RESPONSES AT ALL, you get no confirmation that a command was received and there is no way to check the status of the relays.
The Library remembers the states the relays should be at and reports that back, but if the board is not initialized into a known state, or if a command is lost due to a communication error, the reported state could be inacurate since there is no feedback from the board.

It can control multiple relay boards at the same time, they are referenced by their COM Ports


Functions:
----------
* Function Serial_Device_Add(Port:String):Boolean;  //Adds a device at the port specified and opens the port
* Function Serial_Relay_Status(Device:String):integer; //Reports the status of all relays on board specified to the console
* Function Serial_Relay_List:integer; //Lists all relay boards added and their status to the cosole
* Function Write_Serial_Relay(Device:String;Relay_Number:Byte;State:Boolean):integer;
* Function Read_Serial_Relay(Device:String;Relay_Number:Byte):Byte;
* Function Set_Serial_Relays(Device:String):integer;  //Turns on All relays on the board specified
* Function Set_All_Serial_Relays:integer; //Turns on All relays on All boards
* Function Clear_Serial_Relays(Device:String):integer; //Turns off All relays on the board specified
* Function Clear_All_Serial_Relays:integer; //Turns on All relays on All boards
* Function Serial_Relay_Device_Status(Device:String):Word; //Reports the status of all relays on the board specified in a single word
* Function Serial_Relay_Device_Status_String(Device:String):String; //Reports the status of all relays on the board specified in a string of 1's and 0's
* Function Serial_Relay_State(Device:String;Relay_Number:Byte):Boolean; //Reports the status of a specific relay on the board specified as a boolean value

Ports are automatically closed when the program ends
