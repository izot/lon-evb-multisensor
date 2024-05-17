ReadMe for the EVB MultiSensor Example

The EVB MultiSensor Example (EvbMultiSensor) demonstrates how you can use switch
devices to activate lamp devices in a self-installed or managed network.  For
managed networks, it also demonstrates how you can use light sensor, temperature
sensor, joystick, and display devices to view the current temperature, light
level, and alarm conditions of a local or remote device and configure light and
temperature alarm set points.

In ISI mode, this example uses one push button (SW1) that represents a switch
device, one LED (LED1) that represents a lamp device, a push button (SW2) to
initiate and complete an ISI connection, and an LED (LED2) that indicates the
connection status of the ISI connection.

In Managed mode, this example uses two push buttons (SW1 and SW2) that represent
switch devices and two LEDs (LED1 and LED2) that represent lamp devices, a
temperature sensor, a light level sensor, an LCD display, and a joystick used to
select the information displayed on the LCD and to enter set points for light
and temperature alarms.  In managed mode, you use an LNS application such as the
OpenLNS Commissioning Tool to commission the MultiSensorExample device and to
connect the various I/O objects on the FT 5000 or FT 6000 evaluation board.

The Multi Sensor Example interface includes the following functional blocks:
- A Node Object functional block.
- An array of two Switch functional blocks representing the push button I/O
  objects and an array of two Lamp functional blocks representing the LED I/O
  objects on the evaluation board.   The Switch and Lamp functional
  blocks contain SNVT_switch input and output network variables.
- A LightSensor functional block representing the light sensor I/O object on
  the evaluation board.  The LightSensor functional block includes a
  SNVT_lux output network variable and a SCPTluxSetPoint configuration property
  network variable.
- A TempSensor functional block representing the temperature sensor I/O object
  on the  evaluation board.  The TempSensor functional block includes
  a SNVT_temp_p output network variable, SCPTmaxSendTime (heartbeat) and
  SCPTminSendTime (throttle), and SCPTminDeltaTemp file configuration
  properties, and a SCPThighLimTemp configuration property network variable.
- A Joystick functional block representing the joystick I/O object on the
  evaluation board.  The Joystick functional block includes a SNVT_angle_deg
  output network variable which can be changed to SNVT_switch output network
  variable and a SCPTnvType configuration property network variable.
- A Virtual Functional Block encapsulating the SNVT_lux and SNVT_temp_p values
  received from a remote device.

By default, this example is located at
<LonWorks>\NeuronC\Examples\<EVB>\NcMultiSensorExample, where <LonWorks> is
the default LonWorks folder (typically C:\LonWorks or C:\Program Files\LonWorks)
on your machine, and <EVB> is the name of your evaluation board (e.g. FT 6000 EVB).

You will find the following files and folders at this location:

ReadMe.txt                  This file.
NcMultiSensor.zip           A zip archive containing an OpenLNS CT drawing and
                            database that can be used to load the application
                            and commission it on an  evaluation board.
NcMultiSensorExample.NbPrj  NodeBuilder project file for this application. Mini
                            EVK users can ignore this file.
NcMultiSensorExample.NbOpt  NodeBuilder options file for this application. Mini
                            EVK users can ignore this file.
Source                      Folder containing the source files.
  Main.nc                   Main application source file for this example. Mini
                            EVK users can compile this file to build the
                            application as this file includes all the remaining
                            source files required for this application.
  NodeObject.nc             Source file containing implementation of the Node
                            Object functional block.
  Lamp.nc                   Source file containing implementation of the Lamp
                            functional block.
  Switch.nc                 Source file containing implementation of the Switch
                            functional block.
  LightSensor.nc            Source file containing implementation of the Light
                            Sensor functional block.
  TempSensor.nc             Source file containing implementation of the
                            Temperature Sensor functional block.
  Joystick.nc               Source file containing implementation of the
                            Joystick functional block.
  LCD.h                     Header file containing the data structures and
                            function prototypes used to drive the various LCD
                            modes.
  LCD.nc                    Source file containing implementation of the
                            functions used to drive the various LCD modes.
  NcMultiSensorExample.NbDt NodeBuilder device template file for this
                            application. Mini EVK users can ignore this file.
..\Common                   Folder containing source files that are shared by
                            the example applications.
  EvalBoard.h               Header file that contains the I/O pin assignments of
                            the Neuron chip on the  evaluation board,
                            the data structures used for representing the I/O
                            values, and the function prototypes used to access
                            the various I/O components on the evaluation board.
  EvalBoard.nc              Source file containing the implementation of the
                            functions used to access the various I/O components
                            on the  evaluation board.
  Filesys.h                 Header file containing data structures for
                            implementing configuration properties in files.
  IsiImplementation.nc      Source file containing the implementation of the
                            ISI specific functions used to implement the ISI
                            functionality in this example application.
  Lux.nc                    Source file containing the implementation to obtain
                            the value of the light level reported by the light
                            level sensor in Lux.
