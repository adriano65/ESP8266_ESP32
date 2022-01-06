# M5stickC-IDF

> ESP-IDF component to work with M5StickC  
> Compiler Environment:esp-idf-v3.2.3  
> TFT lib base [loboris TFT library ](https://github.com/loboris/ESP32_TFT_library)

---

## Versions
* Version 0.0.1 2019-10-21@Hades
	* Creat this project
	* Add LCD Device Library
	* Add Wire(I2C) Library
	* Add AXP192 Library
	* Add MPU6886 Library
---
* Version 0.0.2 2019-10-22@Hades
	* Edit AXP192 Library 
	```C
	float AXP192GetVinVoltage(wire_t *wire)
	```

	* Edit main-Examples 
		* Add Demo for LCD
		* Add Demo for AXP192
		* Add Demo for MPU6886
		* Add Demo for Button
---
* Version 1.0.1 2019-10-23@Hades

	* remove power.c & power.h
	* remove event.c & event.h
	* remove display.c & display.h

	* Edit I2S micophone Examles
	```C
	void MicRecordTest()
	```
	* edit m5stick.c 
