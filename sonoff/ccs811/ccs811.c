#include <osapi.h>
#include <ets_sys.h>
#include <c_types.h>
#include <errno.h>
#include <mem.h>

#include <i2c.h>
#include "ccs811.h"

// Uncomment one of the following defines to enable debug output
// #define CCS811_DEBUG_LEVEL_1             // only error messages
#define CCS811_DEBUG_LEVEL_2             // debug and error messages

#if defined(CCS811_DEBUG_LEVEL_2)
#define debug(s, f, ...) os_printf("%s %s: " s "\n", "CCS811", f, ## __VA_ARGS__)
#define debug_dev(s, f, d, ...) os_printf("%s %s: addr %02x - " s "\n", "CCS811", f, d->addr, ## __VA_ARGS__)
#else
#define debug(s, f, ...)
#define debug_dev(s, f, d, ...)
#endif

#if defined(CCS811_DEBUG_LEVEL_1) || defined(CCS811_DEBUG_LEVEL_2)
#define error(s, f, ...) os_printf("%s %s: " s "\n", "CCS811", f, ## __VA_ARGS__)
#define error_dev(s, f, d, ...) os_printf("%s %s: addr %02x - " s "\n", "CCS811", f, d->addr, ## __VA_ARGS__)
#else
#define error(s, f, ...)
#define error_dev(s, f, d, ...)
#endif

/* CCS811 register addresses */
#define CCS811_REG_STATUS          0x00
#define CCS811_REG_MEAS_MODE       0x01
#define CCS811_REG_ALG_RESULT_DATA 0x02
#define CCS811_REG_RAW_DATA        0x03
#define CCS811_REG_ENV_DATA        0x05
#define CCS811_REG_NTC             0x06
#define CCS811_REG_THRESHOLDS      0x10
#define CCS811_REG_BASELINE        0x11

#define CCS811_REG_HW_ID           0x20
#define CCS811_REG_HW_VER          0x21
#define CCS811_REG_FW_BOOT_VER     0x23
#define CCS811_REG_FW_APP_VER      0x24

#define CCS811_REG_ERROR_ID        0xe0

#define CCS811_REG_APP_ERASE       0xf1
#define CCS811_REG_APP_DATA        0xf2
#define CCS811_REG_APP_VERIFY      0xf3
#define CCS811_REG_APP_START       0xf4
#define CCS811_REG_SW_RESET        0xff

// status register bits
#define CCS811_STATUS_ERROR        0x01  // error, details in CCS811_REG_ERROR
#define CCS811_STATUS_DATA_RDY     0x08  // new data sample in ALG_RESULT_DATA
#define CCS811_STATUS_APP_VALID    0x10  // valid application firmware loaded
#define CCS811_STATUS_FW_MODE      0x80  // firmware is in application mode

// error register bits
#define CCS811_ERR_WRITE_REG_INV   0x01  // invalid register address on write
#define CCS811_ERR_READ_REG_INV    0x02  // invalid register address on read
#define CCS811_ERR_MEASMODE_INV    0x04  // invalid requested measurement mode
#define CCS811_ERR_MAX_RESISTANCE  0x08  // maximum sensor resistance exceeded 
#define CCS811_ERR_HEATER_FAULT    0x10  // heater current not in range
#define CCS811_ERR_HEATER_SUPPLY   0x20  // heater voltage not applied correctly

/**
 * Type declarations
 */

typedef struct {
    uint8_t reserved_1 :2;
    uint8_t int_thresh :1;  // interrupt if new ALG_RESULT_DAT crosses on of the thresholds
    uint8_t int_datardy:1;  // interrupt if new sample is ready in ALG_RESULT_DAT 
    uint8_t drive_mode :3;  // mode number binary coded
} ccs811_meas_mode_reg_t;


/**
 * forward declaration of functions for internal use only
 */

static bool ccs811_reg_read(uint8_t reg, uint8_t *data, uint32_t len);
static bool ccs811_reg_write(uint8_t reg, uint8_t *data, uint32_t len);
static bool ccs811_check_error_status ();
static bool ccs811_enable_threshold (bool enabled);
static bool ccs811_is_available ();

ccs811_sensor_t * ccs811_sensor;

void ccs811_init_sensor (uint8_t addr) {
    
    if ((ccs811_sensor = (ccs811_sensor_t *)os_zalloc (sizeof(ccs811_sensor_t))) == NULL) return;

    // init sensor data structure
    ccs811_sensor->addr = addr;
    ccs811_sensor->mode = ccs811_mode_idle;
    ccs811_sensor->error_code = CCS811_OK;

    // check whether sensor is available including the check of the hardware id and the error state
    if (!ccs811_is_available()) {
        error_dev("Sensor is not available.", __FUNCTION__, ccs811_sensor);
        os_free (ccs811_sensor); ccs811_sensor=NULL;
        return ;
    }

    const static uint8_t sw_reset[4] = { 0x11, 0xe5, 0x72, 0x8a };

    // doing a software reset first
    if (!ccs811_reg_write(CCS811_REG_SW_RESET, (uint8_t*)sw_reset, 4)) {
        error_dev("Could not reset the sensor.", __FUNCTION__, ccs811_sensor);
        os_free (ccs811_sensor); ccs811_sensor=NULL;
        return ;
    }
    
    uint8_t status;

    // wait 100 ms after the reset
    os_delay_us(100*1000);

    // get the status to check whether sensor is in bootloader mode
    if (!ccs811_reg_read(CCS811_REG_STATUS, &status, 1)) {
        error_dev("Could not read status register %02x.", __FUNCTION__, ccs811_sensor, CCS811_REG_STATUS);
        os_free (ccs811_sensor); ccs811_sensor=NULL;
        return ;
    }
    
    // if sensor is in bootloader mode (FW_MODE == 0), it has to switch
    // to the application mode first
    if (!(status & CCS811_STATUS_FW_MODE)) {
        // check whether valid application firmware is loaded
        if (!(status & CCS811_STATUS_APP_VALID)) {
            error_dev("Sensor is in boot mode, but has no valid application.", __FUNCTION__, ccs811_sensor);
            os_free (ccs811_sensor); ccs811_sensor=NULL;
            return ;
        }

        // swtich to application mode
        if (!ccs811_reg_write(CCS811_REG_APP_START, 0, 0)) {
            error_dev("Could not start application", __FUNCTION__, ccs811_sensor);
            os_free (ccs811_sensor); ccs811_sensor=NULL;
            return ;
        }
    
        // wait 100 ms after starting the app
        os_delay_us(100*1000);
    
        // get the status to check whether sensor switched to application mode
        if (!ccs811_reg_read(CCS811_REG_STATUS, &status, 1) || !(status & CCS811_STATUS_FW_MODE)) {
            error_dev("Could not start application.", __FUNCTION__, ccs811_sensor);
            os_free (ccs811_sensor); ccs811_sensor=NULL;
            return ;
        }
    }
    
    // try to set default measurement mode to *ccs811_mode_1s*
    if (!ccs811_set_mode(ccs811_mode_1s)) {
        os_free (ccs811_sensor); ccs811_sensor=NULL;
        return ;
    }
    
}


bool ccs811_set_mode (ccs811_mode_t mode) {
    ccs811_meas_mode_reg_t reg;

    if (!ccs811_sensor) return false;
    
    ccs811_sensor->error_code = CCS811_OK;

    // read measurement mode register value
    if (!ccs811_reg_read(CCS811_REG_MEAS_MODE, (uint8_t*)&reg, 1))
        return false;
    
    reg.drive_mode = mode;
    
    // write back measurement mode register
    if (!ccs811_reg_write(CCS811_REG_MEAS_MODE, (uint8_t*)&reg, 1)) {
        error_dev ("Could not set measurement mode.", __FUNCTION__, ccs811_sensor);
        return false;
    }
    
    // check whether setting measurement mode were succesfull
    if (!ccs811_reg_read(CCS811_REG_MEAS_MODE, (uint8_t*)&reg, 1) ||
        reg.drive_mode != mode)
    {
        error_dev ("Could not set measurement mode to %d", __FUNCTION__, ccs811_sensor, mode);
        return ccs811_check_error_status ();
    }
    
    ccs811_sensor->mode = mode;
        
    return true;
}

#define CCS811_ALG_DATA_ECO2_HB   0
#define CCS811_ALG_DATA_ECO2_LB   1
#define CCS811_ALG_DATA_TVOC_HB   2
#define CCS811_ALG_DATA_TVOC_LB   3
#define CCS811_ALG_DATA_STATUS    4
#define CCS811_ALG_DATA_ERROR_ID  5
#define CCS811_ALG_DATA_RAW_HB    6
#define CCS811_ALG_DATA_RAW_LB    7

bool ccs811_get_results (){
    if (!ccs811_sensor) return false;

    ccs811_sensor->error_code = CCS811_OK;
    
    if (ccs811_sensor->mode == ccs811_mode_idle) {       
        error_dev ("Sensor is in idle mode and not performing measurements.", __FUNCTION__, ccs811_sensor);
        ccs811_sensor->error_code = CCS811_DRV_WRONG_MODE;
        return false;
    }

    if (ccs811_sensor->mode == ccs811_mode_250ms && (ccs811_sensor->iaq_tvoc || ccs811_sensor->iaq_eco2))  {       
        error_dev ("Sensor is in constant power mode, only raw data are available every 250ms", __FUNCTION__, ccs811_sensor);
        ccs811_sensor->error_code = CCS811_DRV_NO_IAQ_DATA;
        return false;
    }    
  
    uint8_t data[8];

    // read IAQ sensor values and RAW sensor data including status and error id
    if (!ccs811_reg_read(CCS811_REG_ALG_RESULT_DATA, data, 8)) {
        error_dev ("Could not read sensor data.", __FUNCTION__, ccs811_sensor);
        ccs811_sensor->error_code |= CCS811_DRV_RD_DATA_FAILED;
        return false;
    }

    // check for errors
    if (data[CCS811_ALG_DATA_STATUS] & CCS811_STATUS_ERROR) {
        return ccs811_check_error_status ();
    }

    // check whether new data are ready, if not, latest values are read from sensor
    // and error_code is set
    if (!(data[CCS811_ALG_DATA_STATUS] & CCS811_STATUS_DATA_RDY)) {
        debug_dev ("No new data.", __FUNCTION__, ccs811_sensor);
        ccs811_sensor->error_code = CCS811_DRV_NO_NEW_DATA;
    }

    // if *iaq* is not NULL return IAQ sensor values
    ccs811_sensor->iaq_tvoc = data[CCS811_ALG_DATA_TVOC_HB] << 8 | data[CCS811_ALG_DATA_TVOC_LB];
    ccs811_sensor->iaq_eco2 = data[CCS811_ALG_DATA_ECO2_HB] << 8 | data[CCS811_ALG_DATA_ECO2_LB];
    
    // if *raw* is not NULL return RAW sensor data
    ccs811_sensor->raw_i = data[CCS811_ALG_DATA_RAW_HB] >> 2;
    ccs811_sensor->raw_v = (data[CCS811_ALG_DATA_RAW_HB] & 0x03) << 8 | data[CCS811_ALG_DATA_RAW_LB];
    
    return true;
}

uint32_t ccs811_get_ntc_resistance (uint32_t r_ref) {
    if (!ccs811_sensor) return 0;
    
    uint8_t data[4];
    
    // read baseline register
    if (!ccs811_reg_read(CCS811_REG_NTC, data, 4))
        return 0;
     
    // calculation from application note ams AN000372
    uint16_t v_ref = (uint16_t)(data[0]) << 8 | data[1];
    uint16_t v_ntc = (uint16_t)(data[2]) << 8 | data[3];
    
    return (v_ntc * r_ref / v_ref);
}


bool ccs811_set_environmental_data (float temperature, float humidity) {
    if (!ccs811_sensor) return false;
  
    uint16_t temp = (temperature + 25) * 512;   // -25 C maps to 0
    uint16_t hum  = humidity * 512;

    // fill environmental data
    uint8_t data[4]  = { temp >> 8, temp & 0xff,
                         hum  >> 8, hum  & 0xff  };

    // send environmental data to the sensor
    if (!ccs811_reg_write(CCS811_REG_ENV_DATA, data, 4)) {
        error_dev ("Could not write environmental data to sensor.", __FUNCTION__, ccs811_sensor);
        return false;
    }
    
    return true;
}

bool ccs811_set_eco2_thresholds (uint16_t low, uint16_t high, uint8_t hysteresis) {
    if (!ccs811_sensor) return false;

    ccs811_sensor->error_code = CCS811_OK;

    // check whether interrupt has to be disabled
    if (!low && !high && !hysteresis)
        return ccs811_enable_threshold (false);
    
    // check parameters
    if (low < CCS_ECO2_RANGE_MIN || high > CCS_ECO2_RANGE_MAX || low > high || !hysteresis) {
        error_dev ("Wrong threshold parameters", __FUNCTION__, ccs811_sensor);
        ccs811_sensor->error_code = CCS811_DRV_WRONG_PARAMS;
        return ccs811_enable_threshold (false);
    }
    
    // fill the threshold data
    uint8_t data[5] = { low  >> 8, low  & 0xff,
                        high >> 8, high & 0xff,
                        hysteresis };
    
    // write threshold data to the sensor
    if (!ccs811_reg_write(CCS811_REG_THRESHOLDS, data, 5))
    {
        error_dev ("Could not write threshold interrupt data to sensor.", __FUNCTION__, ccs811_sensor);
        return ccs811_enable_threshold (false);
    }

    // finally enable the threshold interrupt mode    
    return ccs811_enable_threshold (true);
}


bool ccs811_enable_interrupt (bool enabled) {
    if (!ccs811_sensor) return false;

    ccs811_meas_mode_reg_t reg;
    
    // read measurement mode register value
    if (!ccs811_reg_read(CCS811_REG_MEAS_MODE, (uint8_t*)&reg, 1))
        return false;
    
    reg.int_datardy = enabled;
    reg.int_thresh  = false;      // threshold mode must not enabled
    
    // write back measurement mode register
    if (!ccs811_reg_write(CCS811_REG_MEAS_MODE, (uint8_t*)&reg, 1))
    {
        error_dev ("Could not set measurment mode register.", __FUNCTION__, ccs811_sensor);
        return false;
    }
    
    return true;
}

uint16_t ccs811_get_baseline () {
    if (!ccs811_sensor) return 0;
    
    uint8_t data[2];
    
    // read baseline register
    if (!ccs811_reg_read(CCS811_REG_BASELINE, data, 2))
        return 0;
        
    return (uint16_t)(data[0]) << 8 | data[1];
}


bool ccs811_set_baseline (uint16_t baseline) {
    if (!ccs811_sensor) return false;

    uint8_t data[2] = { baseline >> 8, baseline & 0xff };
    
    // write baseline register
    if (!ccs811_reg_write(CCS811_REG_BASELINE, data, 2))
        return false;
        
    return true;
}


/**
 * FUNCTIONS FOR INTERNAL USE ONLY
 */


static bool ccs811_enable_threshold (bool enabled) {
    if (!ccs811_sensor) return false;
    
    ccs811_meas_mode_reg_t reg;

    // first, enable/disable the data ready interrupt
    if (!ccs811_enable_interrupt (enabled))
        return false;

    // read measurement mode register value
    if (!ccs811_reg_read(CCS811_REG_MEAS_MODE, (uint8_t*)&reg, 1))
        return false;
    
    // second, enable/disable the threshold interrupt mode
    reg.int_thresh = enabled;
    
    // write back measurement mode register
    if (!ccs811_reg_write(CCS811_REG_MEAS_MODE, (uint8_t*)&reg, 1)) {
        error_dev ("Could not set measurement mode register.", __FUNCTION__, ccs811_sensor);
        return false;
    }
    
    return true;
}


static bool ccs811_reg_read(uint8_t reg, uint8_t *data, uint32_t len) {
    if (!ccs811_sensor || !data) return false;

    debug_dev ("Read %d byte from i2c starting at reg addr %02x.", __FUNCTION__, ccs811_sensor, len, reg);

    i2c_start();
    i2c_writeByte(ccs811_sensor->addr);
    if(!i2c_check_ack()){
        debug("1. slave not ack..\n", __FUNCTION__);
        i2c_stop();
        return false;
        }
    i2c_writeByte(reg);
    if(!i2c_check_ack()){
        debug("2. slave not ack..\n", __FUNCTION__);
        i2c_stop();
        return false;
        }
    /*
    data[0] = i2c_readByte();
    i2c_send_ack(1);
    data[1] = i2c_readByte();
    */
    
    for (int i=0; i < len; i++) {
        data[i] = i2c_readByte();
        i2c_send_ack(1);                       		
        //uint8_t lsb = i2c_readByte();     
        //i2c_send_ack(0);
        }
    
    i2c_send_ack(0);
    i2c_stop(); 


/*
    if (!i2c_slave_read(ccs811_sensor->addr, &reg, data, len)) {
        ccs811_sensor->error_code = CCS811_I2C_READ_FAILED;
        error_dev ("Error %d on read %d byte from I2C slave reg addr %02x.", __FUNCTION__, ccs811_sensor, 0, len, reg);
        return false;
    }
*/

#   ifdef CCS811_DEBUG_LEVEL_2
    os_printf("CCS811 %s: addr %02x - Read following bytes: ", __FUNCTION__, ccs811_sensor->addr);
    os_printf("%0x: ", reg);
    for (int i=0; i < len; i++)
        os_printf("%0x ", data[i]);
    os_printf("\n");
#   endif

    return true;
}


static bool ccs811_reg_write(uint8_t reg, uint8_t *data, uint32_t len) {
    if (!ccs811_sensor) return false;

    debug_dev ("Write %d bytes to i2c slave starting at reg addr %02x", __FUNCTION__, ccs811_sensor, len, reg);

#   ifdef CCS811_DEBUG_LEVEL_2
    if (data && len) {
        os_printf("CCS811 %s: addr %02x - Write following bytes: ", __FUNCTION__, ccs811_sensor->addr);
        for (int i=0; i < len; i++)
            os_printf("%02x ", data[i]);
        os_printf("\n");
        }
#   endif

    i2c_start(); 
    i2c_writeByte(ccs811_sensor->addr); 
    if(!i2c_check_ack()){
        os_printf("slave not ack..\n return \n");
        i2c_stop();
        return false;
        }
    i2c_writeByte(reg);
    if(!i2c_check_ack()){
        os_printf("slave not ack..\n return \n");
        i2c_stop();
        return false;
    }

    /*
    int result = i2c_slave_write(, &reg, data, len);

    if (result) {
        ccs811_sensor->error_code |= (result == -EBUSY) ? CCS811_I2C_BUSY : CCS811_I2C_WRITE_FAILED;
        error_dev ("Error %d on write %d byte to i2c slave register %02x.", __FUNCTION__, ccs811_sensor, result, len, reg);
        return false;
        }
    */

    return true;
}


static bool ccs811_check_error_status (){
    if (!ccs811_sensor) return false;

    ccs811_sensor->error_code = CCS811_OK;

    uint8_t status;
    uint8_t err_reg;
    
    // check status register
    if (!ccs811_reg_read(CCS811_REG_STATUS, &status, 1))
        return false;
    
    if (!status & CCS811_STATUS_ERROR)
        // everything is fine
        return true;
        
    // Check the error register
    if (!ccs811_reg_read(CCS811_REG_ERROR_ID, &err_reg, 1))
        return false;

    if (err_reg & CCS811_ERR_WRITE_REG_INV)    {
        error_dev ("Received an invalid register for write.", __FUNCTION__, ccs811_sensor);
        ccs811_sensor->error_code = CCS811_DRV_WR_REG_INV;
        return false;
    }
    
    if (err_reg & CCS811_ERR_READ_REG_INV)    {
        error_dev ("Received an invalid register for read.", __FUNCTION__, ccs811_sensor);
        ccs811_sensor->error_code = CCS811_DRV_RD_REG_INV;
        return false;
    }
    
    if (err_reg & CCS811_ERR_MEASMODE_INV) {
        error_dev ("Received an invalid measurement mode request.", __FUNCTION__, ccs811_sensor);
        ccs811_sensor->error_code = CCS811_DRV_MM_INV;
        return false;
    }
    
    if (err_reg & CCS811_ERR_MAX_RESISTANCE)
    {
        error_dev ("Sensor resistance measurement has reached or exceeded the maximum range.", __FUNCTION__, ccs811_sensor);
        ccs811_sensor->error_code = CCS811_DRV_MAX_RESIST;
        return false;
    }
    
    if (err_reg & CCS811_ERR_HEATER_FAULT) {
        error_dev ("Heater current not in range.", __FUNCTION__, ccs811_sensor);
        ccs811_sensor->error_code = CCS811_DRV_HEAT_FAULT;
        return false;
    }
    
    if (err_reg & CCS811_ERR_HEATER_SUPPLY) {
        error_dev ("Heater voltage is not being applied correctly.", __FUNCTION__, ccs811_sensor);
        ccs811_sensor->error_code = CCS811_DRV_HEAT_SUPPLY;
        return false;
    }

    return true;
}


static bool ccs811_is_available () {
    if (!ccs811_sensor) return false;

    uint8_t reg_data[5];
        
    // check hardware id (register 0x20) and hardware version (register 0x21)
    if (!ccs811_reg_read(CCS811_REG_HW_ID, reg_data, 5))
        return false;
        
    if (reg_data[0] != 0x81) {
        error_dev ("Wrong hardware ID %02x, should be 0x81", __FUNCTION__, ccs811_sensor, reg_data[0]);
        ccs811_sensor->error_code = CCS811_DRV_HW_ID;
        return false;
    }
        
    debug_dev ("hardware version:      %02x", __FUNCTION__, ccs811_sensor, reg_data[1]);
    debug_dev ("firmware boot version: %02x", __FUNCTION__, ccs811_sensor, reg_data[3]);
    debug_dev ("firmware app version:  %02x", __FUNCTION__, ccs811_sensor, reg_data[4]);
        
    return ccs811_check_error_status ();
}


