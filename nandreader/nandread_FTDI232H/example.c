// Quite minimal example showing how to configure MPSSE for SPI using libftdi
// compile like this: g++ minimal_spi.cpp -o minimal_spi -lftdipp -lftdi
#include <ftdi.hpp>
#include <usb.h>
#include <stdio.h>
#include <iostream>
#include <string.h>

// UM232H development module
#define VENDOR 0x0403
#define PRODUCT 0x6014

using namespace Ftdi;

namespace Pin {
   // enumerate the AD bus for conveniance.
   enum bus_t {
      SK = 0x01, // ADBUS0, SPI data clock
      DO = 0x02, // ADBUS1, SPI data out
      DI = 0x04, // ADBUS2, SPI data in
      CS = 0x08, // ADBUS3, SPI chip select
      L0 = 0x10, // ADBUS4, general-ourpose i/o, GPIOL0
      L1 = 0x20, // ADBUS5, general-ourpose i/o, GPIOL1
      L2 = 0x40, // ADBUS6, general-ourpose i/o, GPIOL2
      l3 = 0x80  // ADBUS7, general-ourpose i/o, GPIOL3
   };
}

// Set these pins high
const unsigned char pinInitialState = Pin::CS|Pin::L0|Pin::L1;
// Use these pins as outputs
const unsigned char pinDirection    = Pin::SK|Pin::DO|Pin::CS|Pin::L0|Pin::L1;

int main(void)
{
   // initialize
   struct ftdi_context ftdi;
   int ftdi_status = 0;
   ftdi_status = ftdi_init(&ftdi);
   if ( ftdi_status != 0 ) {
      std::cout << "Failed to initialize device\n";
      return 1;
   }
   ftdi_status = ftdi_usb_open(&ftdi, VENDOR, PRODUCT);
   if ( ftdi_status != 0 ) {
      std::cout << "Can't open device. Got error\n"
		<< ftdi_get_error_string(&ftdi) << '\n';
      return 1;
   }
   ftdi_usb_reset(&ftdi);
   ftdi_set_interface(&ftdi, INTERFACE_ANY);
   ftdi_set_bitmode(&ftdi, 0, 0); // reset
   ftdi_set_bitmode(&ftdi, 0, BITMODE_MPSSE); // enable mpsse on all bits
   ftdi_usb_purge_buffers(&ftdi);
   usleep(50000); // sleep 50 ms for setup to complete
   
   // Setup MPSSE; Operation code followed by 0 or more arguments.
   unsigned int icmd = 0;
   unsigned char buf[256] = {0};
   buf[icmd++] = TCK_DIVISOR;     // opcode: set clk divisor
   buf[icmd++] = 0x05;            // argument: low bit. 60 MHz / (5+1) = 1 MHz
   buf[icmd++] = 0x00;            // argument: high bit.
   buf[icmd++] = DIS_ADAPTIVE;    // opcode: disable adaptive clocking
   buf[icmd++] = DIS_3_PHASE;     // opcode: disable 3-phase clocking
   buf[icmd++] = SET_BITS_LOW;    // opcode: set low bits (ADBUS[0-7])
   buf[icmd++] = pinInitialState; // argument: inital pin states
   buf[icmd++] = pinDirection;    // argument: pin direction
   // Write the setup to the chip.
   if ( ftdi_write_data(&ftdi, buf, icmd) != icmd ) {
      std::cout << "Write failed\n";
   }
   // zero the buffer for good measure
   memset(buf, 0, sizeof(buf));
   icmd = 0;   
   
   // Now we will write and read 1 byte.
   // The DO and DI pins should be physically connected on the breadboard.
   // Next three commands sets the GPIOL0 pin low. Pulling CS low.
   buf[icmd++] = SET_BITS_LOW;
   buf[icmd++] = pinInitialState & ~Pin::CS;
   buf[icmd++] = pinDirection;
   // commands to write and read one byte in SPI0 (polarity = phase = 0) mode
   buf[icmd++] = MPSSE_DO_WRITE | MPSSE_WRITE_NEG | MPSSE_DO_READ;
   buf[icmd++] = 0x00; // length low byte, 0x0000 ==> 1 byte
   buf[icmd++] = 0x00; // length high byte
   buf[icmd++] = 0x12; // byte to send
   // Next three commands sets the GPIOL0 pin high. Pulling CS high.
   buf[icmd++] = SET_BITS_LOW;
   buf[icmd++] = pinInitialState | Pin::CS;
   buf[icmd++] = pinDirection;
   std::cout << "Writing: ";
   for ( int i = 0; i < icmd; ++i ) {
     std::cout << std::hex << (unsigned int)buf[i] << ' ';
   }
   std::cout << '\n';
   // need to purge tx when reading for some etherial reason
   ftdi_usb_purge_tx_buffer(&ftdi);
   if ( ftdi_write_data(&ftdi, buf, icmd) != icmd ) {
      std::cout << "Write failed\n";
   }
   // zero the buffer for good measure
   memset(buf, 0, sizeof(buf));
   icmd = 0;   

   // now get the data we read just read from the chip
   unsigned char readBuf[256] = {0};
   if ( ftdi_read_data(&ftdi, readBuf, 1) != 1 ) std::cout << "Read failed\n";
   else std::cout << "Answer: " << std::hex << (unsigned int)readBuf[0] << '\n';

   // close ftdi
   ftdi_usb_reset(&ftdi);
   ftdi_usb_close(&ftdi);
   return 0;
}

