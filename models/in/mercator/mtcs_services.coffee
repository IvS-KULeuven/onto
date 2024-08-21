########################################################################################################################
#                                                                                                                      #
# Model of the Services software.                                                                                        #
#                                                                                                                      #
########################################################################################################################

require "ontoscript"

# metamodels
REQUIRE "models/import_all.coffee"

# models
REQUIRE "models/mtcs/common/software.coffee"
REQUIRE "models/mtcs/tmc/software.coffee"

MODEL "http://www.mercator.iac.es/onto/models/mtcs/services/software" : "services_soft"

services_soft.IMPORT mm_all
services_soft.IMPORT common_soft
services_soft.IMPORT tmc_soft



########################################################################################################################
# Define the containing PLC library
########################################################################################################################

services_soft.ADD MTCS_MAKE_LIB "mtcs_services"

# make aliases (with scope of this file only)
COMMONLIB = common_soft.mtcs_common
THISLIB   = services_soft.mtcs_services
TMCLIB    = tmc_soft.mtcs_tmc


########################################################################################################################
# ServicesTimingTimeSource
########################################################################################################################

MTCS_MAKE_ENUM THISLIB, "ServicesTimingTimeSource",
    items:
        [ "LOCAL_CLOCK",
          "PTP_IEEE_1588" ]


########################################################################################################################
# ServicesTimingConfig
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "ServicesTimingConfig",
    items:
        leapSeconds:
            type: t_int16
            comment: "Number of leap seconds, so that UTC = TAI + this value. See ftp://maia.usno.navy.mil/ser7/tai-utc.dat for the latest number."
        dut:
            type: t_double
            comment: "Delta UT (= UT1 - UTC). Put to 0.0 to ignore."
        alwaysUseLocalClock:
            type: t_bool
            comment: "If TRUE, then the local clock (source=LOCAL_CLOCK) will be used even if an external (more accurate!) clock is available"
        ignoreSerialError:
            type: t_bool
            comment: "Don't show the Servicestiming status as ERROR in case the serial link fails"


########################################################################################################################
# ServicesMeteoConfig
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "ServicesMeteoConfig",
    items:
        enableWeatherMonitoring:
            type: t_bool
            comment: "Enable weather monitoring and emergency closing"
        wetLimit:
            type: t_double
            comment: "Wet if (rainIntensity+hailIntrelaensity)>wetLimit"
        windSpeedMinimum:
            type: COMMONLIB.MeasurementConfig
            comment: "Config for the wind speed minimum"
            expand: false
        windSpeedAverage:
            type: COMMONLIB.MeasurementConfig
            comment: "Config for the wind speed average"
            expand: false
        windSpeedMaximum:
            type: COMMONLIB.MeasurementConfig
            comment: "Config for the wind speed maximum"
            expand: false
        windDirectionMinimum:
            type: COMMONLIB.MeasurementConfig
            comment: "Config for the wind direction minimum"
            expand: false
        windDirectionAverage:
            type: COMMONLIB.MeasurementConfig
            comment: "Config for the wind direction average"
            expand: false
        windDirectionMaximum:
            type: COMMONLIB.MeasurementConfig
            comment: "Config for the wind direction maximum"
            expand: false
        airPressure:
            type: COMMONLIB.MeasurementConfig
            comment: "Config for the air pressure"
            expand: false
        airTemperature:
            type: COMMONLIB.MeasurementConfig
            comment: "Config for the air temperature"
            expand: false
        internalTemperature:
            type: COMMONLIB.MeasurementConfig
            comment: "Config for the internal temperature"
            expand: false
        relativeHumidity:
            type: COMMONLIB.MeasurementConfig
            comment: "Config for the relative humidity"
            expand: false
        rainAccumulation:
            type: COMMONLIB.MeasurementConfig
            comment: "Config for the rain accumulation"
            expand: false
        rainDuration:
            type: COMMONLIB.MeasurementConfig
            comment: "Config for the rain duration"
            expand: false
        rainIntensity:
            type: COMMONLIB.MeasurementConfig
            comment: "Config for the rain intensity"
            expand: false
        rainPeakIntensity:
            type: COMMONLIB.MeasurementConfig
            comment: "Config for the rain peak intensity"
            expand: false
        hailAccumulation:
            type: COMMONLIB.MeasurementConfig
            comment: "Config for the hail accumulation"
            expand: false
        hailDuration:
            type: COMMONLIB.MeasurementConfig
            comment: "Config for the hail duration"
            expand: false
        hailIntensity:
            type: COMMONLIB.MeasurementConfig
            comment: "Config for the hail intensity"
            expand: false
        hailPeakIntensity:
            type: COMMONLIB.MeasurementConfig
            comment: "Config for the hail peak intensity"
            expand: false
        heatingTemperature:
            type: COMMONLIB.MeasurementConfig
            comment: "Config for the heating temperature"
            expand: false
        heatingVoltage:
            type: COMMONLIB.MeasurementConfig
            comment: "Config for the heating voltage"
            expand: false
        supplyVoltage:
            type: COMMONLIB.MeasurementConfig
            comment: "Config for the supply voltage"
            expand: false
        referenceVoltage:
            type: COMMONLIB.MeasurementConfig
            comment: "Config for the 3.5 V reference voltage"
            expand: false


########################################################################################################################
# ServicesWestTemperatureTimeConfig
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "ServicesWestTemperatureTimeConfig",
    items:
        enable:
            type: t_bool
            comment: "Enable this time (TRUE) or not (FALSE)"
        hour:
            type: t_double
            comment: "The time to change the setpoint, as decimal hour (e.g. 9.5 = 9:30 am)"
        offset:
            type: t_double
            comment: "Setpoint = air temperature of meteo station + this offset (in degrees celsius)"


########################################################################################################################
# ServicesWestTemperatureUpdateConfig
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "ServicesWestTemperatureUpdateConfig",
    items:
        time0: { type: THISLIB.ServicesWestTemperatureTimeConfig, comment: "Time config 0" }
        time1: { type: THISLIB.ServicesWestTemperatureTimeConfig, comment: "Time config 1" }
        time2: { type: THISLIB.ServicesWestTemperatureTimeConfig, comment: "Time config 2" }
        time3: { type: THISLIB.ServicesWestTemperatureTimeConfig, comment: "Time config 3" }
        time4: { type: THISLIB.ServicesWestTemperatureTimeConfig, comment: "Time config 4" }


########################################################################################################################
# ServicesWestParametersAddressesConfig
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "ServicesWestParametersAddressesConfig",
    comment: "Config about Modbus parameters addresses"  
    items:
        #Bit parameters addresses
        communicationWriteStatus:     { type: t_uint16, initial: 1, comment: "Communication Write Status" }
        manualControl:                { type: t_uint16, initial: 2, comment: "Manual control" }
        selfTune:                     { type: t_uint16, initial: 3, comment: "Activate SelfTune" }
        preTune:                      { type: t_uint16, initial: 4, comment: "Activate PreTune" }
        alarm1Status:                 { type: t_uint16, initial: 5, comment: "Alarm 1 status" }
        alarm2Status:                 { type: t_uint16, initial: 6, comment: "Alarm 2 status" }
        setpointRampling:             { type: t_uint16, initial: 7, comment: "Setpoint ramping" }
        loopAlarmStatus:              { type: t_uint16, initial: 10, comment: "Loop alarm status" }
        loopAlarm:                    { type: t_uint16, initial: 12, comment: "Loop alarm" }
        digitalInput2:                { type: t_uint16, initial: 13, comment: "State Option B digital input" }
        #Word parameters addresses
        processVariable:              { type: t_uint16, initial: 1, comment: "Process Variable" }
        setpoint:                     { type: t_uint16, initial: 2, comment: "Setpoint" }
        outputPower:                  { type: t_uint16, initial: 3, comment: "Power percentage" }
        desviation:                   { type: t_uint16, initial: 4, comment: "Difference ProcessVariable and Setpoint" }
        primaryProportionalBand:      { type: t_uint16, initial: 6, comment: "Primary Proportional band PB" }
        directActing:                 { type: t_uint16, initial: 7, comment: "Direct reverse acting" }
        resetTime:                    { type: t_uint16, initial: 8, comment: "Reset Time. Integral time constant" }
        rate:                         { type: t_uint16, initial: 9, comment: "Rate. Derivative time constant" }
        output1ClycleTime:            { type: t_uint16, initial: 10, comment: "Output 1 cycle time in seconds" }
        scaleRangeLowerLimit:         { type: t_uint16, initial: 11, comment: "Lower Limit of input range" }
        scaleRangeUpperLimit:         { type: t_uint16, initial: 12, comment: "Upper Limit of input range" }
        alarm1Value:                  { type: t_uint16, initial: 13, comment: "Alarm 1 active at this level" }
        alarm2Value:                  { type: t_uint16, initial: 14, comment: "Alarm 2 active at this level" }
        manualReset:                  { type: t_uint16, initial: 15, comment: "Bias value in percentage" }
        deadbandOverlap:              { type: t_uint16, initial: 16, comment: "Deadband and Overlap percentage" }
        onOffDiferential:             { type: t_uint16, initial: 17, comment: "Input span for ON/OFF differential" }
        decimalPointPosition:         { type: t_uint16, initial: 18, comment: "Decimal point position" }
        output2ClycleTime:            { type: t_uint16, initial: 19, comment: "Output 2 cycle time in seconds" }
        primaryOutputPowerLimit:      { type: t_uint16, initial: 20, comment: "Safety power limit in porcentage" }
        actualSetpoint:               { type: t_uint16, initial: 21, comment: "Current Setpoint value (ramping)" }
        setpointUpperLimit:           { type: t_uint16, initial: 22, comment: "Setpoint upper limit" }
        setpointLowerLimit:           { type: t_uint16, initial: 23, comment: "Setpoint lower limit" }
        setpointRampRate:             { type: t_uint16, initial: 24, comment: "Setpoint ramp rate" }
        inputFilterTimeContant:       { type: t_uint16, initial: 25, comment: "Input Filter time contant" }
        processValueOffset:           { type: t_uint16, initial: 26, comment: "Process Value offset" }
        alarm1Hysteresis:             { type: t_uint16, initial: 32, comment: "Alarm 1 hysteresis in percentage" }
        alarm2Hysteresis:             { type: t_uint16, initial: 33, comment: "Alarm 2 hysteresis in percentage" }


########################################################################################################################
# ServicesWestControllerVariables
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "ServicesWestControllerVariables",
    comment: "Configuration parameters"  
    items:
        setpoint:
            type: t_double
            comment: "Setpoint"
        defaultSetpoint:
            type: t_double
            comment: "Default setpoint"
        minSetpoint: 
            type: t_double
            comment: "Minimun setpoint"
        maxSetpoint:
            type: t_double
            comment: "Maximal setpoint"
        processValueOffset:
            type: t_double
            comment: "Offset process varible"
        differentialOnOff:
            type: t_double
            comment: "On/Off differential"
        alarmValue:
            type: t_double
            comment: "Alarm value"
        inputFilterTimeConstant:
            type: t_double
            comment: "Input filter time constant"
        cycleTime:
            type: t_double
            comment: "Cycle time for control loop"                
        proportionalBand:
            type: t_uint16
            comment: "Proportional constant"
        resetTime:
            type: t_uint16
            comment: "Integral time constant"
        rate:
            type: t_uint16
            comment: "Dervative time constant"


########################################################################################################################
# ServicesWestControllerConfig
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "ServicesWestControllerConfig",
    items:
        unitID:
            type: t_uint8
            comment: "The address or UnitID of the controller"
        update:
            type: t_bool
            comment: "True to automatically update the setpoint"
        warningMessage:
            type: t_string
            comment: "A warning message (empty = not shown)"
        measurement:
            type: COMMONLIB.MeasurementConfig
            comment: "The measurement config"
        variables:
            type: THISLIB.ServicesWestControllerVariables
            comment: "Configuration parameters"


########################################################################################################################
# ServicesWestConfig
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "ServicesWestConfig",
    items:
        updateProcessVariables:
            type: t_bool
            comment: "True to automatically update process variables"
        updateVariablesPollingInterval :
            type: t_double
            comment: "Time between bus reads in seconds"
        domeTempControl:
            type: t_bool
            comment: "True to automatically update dome temperatures"
        domeTempCycleTime :
            type: t_double
            comment: "Time between bus checks in seconds"
        hydraulicsTempControl:
            type: t_bool
            comment: "True to enable PID controller for hydraulics temperatures"
        hydraulicsTempCycleTime :
            type: t_double
            comment: "Cycle time for PID Controller in seconds"
        hydraulicsProportionalConstantKP :
            type: t_double
            comment: "Proportional constant (Kp) for PID Controller "
        hydraulicsIntegralConstantTn :
            type: t_double
            comment: "Integral constant (Tn) for PID Controller in seconds"
        domeTemperature:
            type: THISLIB.ServicesWestControllerConfig
            comment: "The address of the Dome temperature controller"
        firstFloorTemperature:
            type: THISLIB.ServicesWestControllerConfig
            comment: "The address of the first floor temperature controller"
        pumpsRoomTemperature:
            type: THISLIB.ServicesWestControllerConfig
            comment: "The address of the pumps room temperature controller"
        oilHeatExchangerTemperature:
            type: THISLIB.ServicesWestControllerConfig
            comment: "The address of the oil heat exchanger temperature controller"
        serversRoomTemperature:
            type: THISLIB.ServicesWestControllerConfig
            comment: "The address of the servers room temperature controller"
        parameterAddresses:
            type: THISLIB.ServicesWestParametersAddressesConfig
            comment: "Config about Modbus parameters addresses"
        temperatureUpdate:
            type: THISLIB.ServicesWestTemperatureUpdateConfig
            comment: "The config for the temperature setpoint"

########################################################################################################################
# ServicesChillerControllerParameterAddress
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "ServicesChillerControllerParameterAddresses",
    comment: "Config about Modbus parameters addresses"  
    items:
        #Logical Area 1. Analog input. Read only. Words 16bits
        waterTankTemperature:     { type: t_uint16, initial: 258, comment: "Water tank temperature" }
        highPressureCircuit1:     { type: t_uint16, initial: 260, comment: "High pressure of circuit 1" }
        highPressureCircuit2:     { type: t_uint16, initial: 262, comment: "High pressure of circuit 2" }
        chillerCurrentInput:      { type: t_uint16, initial: 264, comment: "Chiller current input" }
        waterPumpCurrentInput:    { type: t_uint16, initial: 266, comment: "Water pump current input" }        
        evaporatorOutTemp1:       { type: t_uint16, initial: 268, comment: "Evaporator out temperature 1" }
        evaporatorOutTemp2:       { type: t_uint16, initial: 270, comment: "Evaporator out temperature 2" }
        ambientTemperature:       { type: t_uint16, initial: 272, comment: "Ambient temperature" }
        waterPumpChassisTemp:     { type: t_uint16, initial: 274, comment: "Water Pump chassis temperature" }        
        #Logical Area 2. Digital input. Read only. Words 16bits
        digitalInputStatus1:      { type: t_uint16, initial: 512, comment: "Flow switch status" }
        digitalInputStatus2:      { type: t_uint16, initial: 513, comment: "Digital input status 2" }
        digitalInputStatus3:      { type: t_uint16, initial: 514, comment: "Digital input status 3" }
        digitalInputStatus4:      { type: t_uint16, initial: 515, comment: "Digital input status 4" }
        #Logical Area 3. Data. R/W. Words 16bits
        setpoint:                 { type: t_uint16, initial: 768, comment: "Setpoint parameter address" }
        minSetpoint:              { type: t_uint16, initial: 769, comment: "Minimal Setpoint parameter address" }
        maxSetpoint:              { type: t_uint16, initial: 770, comment: "Maximal Setpoint parameter address" }
        trippingBand:             { type: t_uint16, initial: 774, comment: "Tripping Band parameter address" }
        #Logical Area 5. Unit Status. R/W. Words 16bits
        unitStatus:               { type: t_uint16, initial: 1280, comment: "Unit Status parameter address" }
        unitControllerReset:      { type: t_uint16, initial: 1282, comment: "Unit Controlelr reset parameter address" }
        #Logical Area 8. Digital output status. Read only. Words 16bits
        relayOutputStatus1:       { type: t_uint16, initial: 2048, comment: "Relay output status 1" }
        relayOutputStatus2:       { type: t_uint16, initial: 2049, comment: "Relay output status 2" }
        relayOutputStatus3:       { type: t_uint16, initial: 2050, comment: "Relay output status 3" }
        relayOutputStatus4:       { type: t_uint16, initial: 2051, comment: "Relay output status 4" }
        relayOutputStatus5:       { type: t_uint16, initial: 2052, comment: "Relay output status 5" }
        relayOutputStatus6:       { type: t_uint16, initial: 2053, comment: "Relay output status 6" }
        relayOutputStatus7:       { type: t_uint16, initial: 2054, comment: "Relay output status 7" }
        #Logical Area 9. Analog output status. Read only. Words 16bits
        AnalogOutputStatus1:      { type: t_uint16, initial: 2304, comment: "Fan Condenser1 Output" }
        AnalogOutputStatus2:      { type: t_uint16, initial: 2306, comment: "Fan Condenser2 Output" }
        #Logical Area 13. Alarm status. Read only. Words 16bits
        alarmStatus1:             { type: t_uint16, initial: 3328, comment: "Alarm status 1" }
        alarmStatus2:             { type: t_uint16, initial: 3329, comment: "Alarm status 2" }
        alarmStatus3:             { type: t_uint16, initial: 3330, comment: "Alarm status 3" }
        alarmStatus6:             { type: t_uint16, initial: 3333, comment: "Alarm status 6" }
        alarmStatus7:             { type: t_uint16, initial: 3334, comment: "Alarm status 7" }
        alarmStatus10:            { type: t_uint16, initial: 3337, comment: "Alarm status 10" }
        alarmStatus11:            { type: t_uint16, initial: 3338, comment: "Alarm status 11" }
        #Logical Area 14. Load hours. R/W. Words 16bits
        hoursCompressor1:         { type: t_uint16, initial: 3584, comment: "Operation hours of compressor 1" }
        hoursCompressor2:         { type: t_uint16, initial: 3585, comment: "Operation hours of compressor 2" }
        hoursCompressor3:         { type: t_uint16, initial: 3586, comment: "Operation hours of compressor 3" }
        hoursCompressor4:         { type: t_uint16, initial: 3587, comment: "Operation hours of compressor 4" }
        hoursPump:                { type: t_uint16, initial: 3590, comment: "Operation hours of water pump" }         
        #Logical Area 15. Alarms per hour. Read only. Words 16bits
        alarmOilCompressor1:      { type: t_uint16, initial: 3840, comment: "Alarm oil Compressor 1" }
        alarmOilCompressor2:      { type: t_uint16, initial: 3841, comment: "Alarm oil Compressor 2" }
        alarmOilCompressor3:      { type: t_uint16, initial: 3842, comment: "Alarm oil Compressor 3" }
        alarmOilCompressor4:      { type: t_uint16, initial: 3843, comment: "Alarm oil Compressor 4" }
        alarmFanOverload:         { type: t_uint16, initial: 3846, comment: "Alarm fan overload" }
        alarmColdSideFlowSwitch:  { type: t_uint16, initial: 3847, comment: "Alarm cold side flow switch" }
        alarmHotSideFlowSwitch:   { type: t_uint16, initial: 3848, comment: "Alarm hot side flow switch" }
        alarmCirc1LowTempPressDI: { type: t_uint16, initial: 3849, comment: "Alarm circuit 1 low temppress DI" }
        alarmCirc2LowTempPressDI: { type: t_uint16, initial: 3850, comment: "Alarm circuit 2 low temppress DI" }
        alarmCirc1LowTempPressPB: { type: t_uint16, initial: 3851, comment: "Alarm circuit 1 low temppress PB" }
        alarmCirc2LowTempPressPB: { type: t_uint16, initial: 3852, comment: "Alarm circuit 2 low temppress PB" }

########################################################################################################################
# ServicesChillerControllerAlarmStatus1
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "ServicesChillerControllerAlarmStatus1",
    comment: "Alarm indicators at AlarmStatus1 register"
    items:
        bit0:        { type: t_string, initial: "'Probe8 (Evap2. Water Temperature)'"}
        bit1:        { type: t_string, initial: "'Probe9 (Ambient Temperature)'"}
        bit2:        { type: t_string, initial: "'Probe10 (Not used)'"}
        bit3:        { type: t_string, initial: "'Probe11 (Not used)'"}
        bit4:        { type: t_string, initial: "'Probe12 (Not used)'"}
        bit5:        { type: t_string, initial: "'Compressor1 Maintenance'"}
        bit6:        { type: t_string, initial: "'Compressor2 Maintenance'"}
        bit7:        { type: t_string, initial: "'Compressor3 Maintenance'"}
        bit8:        { type: t_string, initial: "'Alarm not defined'"}
        bit9:        { type: t_string, initial: "'Probe1 (Not used)'"}
        bit10:       { type: t_string, initial: "'Probe2 (Tank. Water Temperature)'"}
        bit11:       { type: t_string, initial: "'Probe3 (High Pressure Cric1)'"}
        bit12:       { type: t_string, initial: "'Probe4 (High Pressure Cric2)'"}
        bit13:       { type: t_string, initial: "'Probe5 (Not used)'"}
        bit14:       { type: t_string, initial: "'Probe6 (Not used)'"}
        bit15:       { type: t_string, initial: "'Probe7 (Evap1. Water Temperature)'"}

########################################################################################################################
# ServicesChillerControllerAlarmStatus2
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "ServicesChillerControllerAlarmStatus2",
    comment: "Alarm indicators at AlarmStatus2 register"
    items:
        bit0:        { type: t_string, initial: "'Alarm not defined'"}
        bit1:        { type: t_string, initial: "'Alarm not defined'"}
        bit2:        { type: t_string, initial: "'Alarm not defined'"}
        bit3:        { type: t_string, initial: "'Alarm not defined'"}
        bit4:        { type: t_string, initial: "'Alarm not defined'"}
        bit5:        { type: t_string, initial: "'Alarm not defined'"}
        bit6:        { type: t_string, initial: "'Alarm not defined'"}
        bit7:        { type: t_string, initial: "'Alarm not defined'"}       
        bit8:        { type: t_string, initial: "'Compressor4 Maintenance'"}
        bit9:        { type: t_string, initial: "'Alarm not defined'"}
        bit10:       { type: t_string, initial: "'Alarm not defined'"}          
        bit11:       { type: t_string, initial: "'Pump/delivery Fan Maintenance'"}
        bit12:       { type: t_string, initial: "'Evaporator2 pump Maintenance'"}
        bit13:       { type: t_string, initial: "'Condenser1 Pump Maintenance'"}
        bit14:       { type: t_string, initial: "'Condenser2 Pump Maintenance'"}
        bit15:       { type: t_string, initial: "'Alarm not defined'"}            

########################################################################################################################
# ServicesChillerControllerAlarmStatus3
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "ServicesChillerControllerAlarmStatus3",
    comment: "Alarm indicators at AlarmStatus3 register"
    items:
        bit0:        { type: t_string, initial: "'Alarm not defined'"}
        bit1:        { type: t_string, initial: "'Alarm not defined'"}
        bit2:        { type: t_string, initial: "'Alarm not defined'"}
        bit3:        { type: t_string, initial: "'Alarm not defined'"}
        bit4:        { type: t_string, initial: "'Alarm not defined'"}
        bit5:        { type: t_string, initial: "'Alarm not defined'"}
        bit6:        { type: t_string, initial: "'Alarm not defined'"}
        bit7:        { type: t_string, initial: "'Alarm not defined'"}
        bit8:        { type: t_string, initial: "'Circuit1 defrost'"}
        bit9:        { type: t_string, initial: "'Circuit2 defrost'"}
        bit10:       { type: t_string, initial: "'Network Frequency'"}
        bit11:       { type: t_string, initial: "'Low Inlet Air Temperature'"}
        bit12:       { type: t_string, initial: "'Alarm not defined'"}
        bit13:       { type: t_string, initial: "'Alarm not defined'"}
        bit14:       { type: t_string, initial: "'Evaporator Low Outlet Temperature'"}
        bit15:       { type: t_string, initial: "'Evaporator High Outlet Temperature'"}

########################################################################################################################
# ServicesChillerControllerAlarmStatus6
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "ServicesChillerControllerAlarmStatus6",
    comment: "Alarm indicators at AlarmStatus6 register"
    items:
        bit0:        { type: t_string, initial: "'Compressor1 Thermal Overload'"}
        bit1:        { type: t_string, initial: "'Compressor2 Thermal Overload'"}
        bit2:        { type: t_string, initial: "'Compressor3 Thermal Overload'"}
        bit3:        { type: t_string, initial: "'Compressor4 Thermal Overload'"}
        bit4:        { type: t_string, initial: "'Alarm not defined'"}
        bit5:        { type: t_string, initial: "'Alarm not defined'"}
        bit6:        { type: t_string, initial: "'Circ1 Cond. Fan Thermal Overload'"}
        bit7:        { type: t_string, initial: "'Circ2 Cond. Fan Thermal Overload'"}
        bit8:        { type: t_string, initial: "'Alarm not defined'"}
        bit9:        { type: t_string, initial: "'Alarm not defined'"}
        bit10:       { type: t_string, initial: "'Compressor1 High Pressure'"}
        bit11:       { type: t_string, initial: "'Compressor2 High Pressure'"}
        bit12:       { type: t_string, initial: "'Compressor3 High Pressure'"}
        bit13:       { type: t_string, initial: "'Compressor4 High Pressure'"}
        bit14:       { type: t_string, initial: "'Alarm not defined'"}
        bit15:       { type: t_string, initial: "'Alarm not defined'"}

########################################################################################################################
# ServicesChillerControllerAlarmStatus7
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "ServicesChillerControllerAlarmStatus7",
    comment: "Alarm indicators at AlarmStatus7 register"
    items:
        bit0:        { type: t_string, initial: "'Alarm not defined'"}
        bit1:        { type: t_string, initial: "'Alarm not defined'"}
        bit2:        { type: t_string, initial: "'Alarm not defined'"}
        bit3:        { type: t_string, initial: "'Alarm not defined'"}
        bit4:        { type: t_string, initial: "'Alarm not defined'"}
        bit5:        { type: t_string, initial: "'Alarm not defined'"}
        bit6:        { type: t_string, initial: "'Alarm not defined'"}
        bit7:        { type: t_string, initial: "'Alarm not defined'"}
        bit8:        { type: t_string, initial: "'Evap1 Water Pump Thermal Overload'"}
        bit9:        { type: t_string, initial: "'Evap2 Water Pump Thermal Overload'"}
        bit10:       { type: t_string, initial: "'Cond1 Pump Thermal Overload'"}
        bit11:       { type: t_string, initial: "'Cond2 Pump Thermal Overload'"}
        bit12:       { type: t_string, initial: "'Circ1 High Pressure Switch Tripped'"}
        bit13:       { type: t_string, initial: "'Circ2 High Pressure Switch Tripped'"}
        bit14:       { type: t_string, initial: "'Circ1 High Pressure Probe'"}
        bit15:       { type: t_string, initial: "'Circ2 High Pressure Probe'"}

########################################################################################################################
# ServicesChillerControllerAlarmStatus10
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "ServicesChillerControllerAlarmStatus10",
    comment: "Alarm indicators at AlarmStatus10 register"
    items:
        bit0:        { type: t_string, initial: "'Hot Side Flow Switch'"}
        bit1:        { type: t_string, initial: "'Cic1 Low Pressure Switch'"}
        bit2:        { type: t_string, initial: "'Cic2 Low Pressure Switch'"}
        bit3:        { type: t_string, initial: "'Cic1 Low Pressure Probe'"}
        bit4:        { type: t_string, initial: "'Cic2 Low Pressure Probe'"}
        bit5:        { type: t_string, initial: "'Circ1 Pump-Down at startup'"}
        bit6:        { type: t_string, initial: "'Circ2 Pump-Down at startup'"}
        bit7:        { type: t_string, initial: "'Circ1 Pump-Down at shutdown'"}
        bit8:        { type: t_string, initial: "'Compressor1 Oil'"}
        bit9:        { type: t_string, initial: "'Compressor2 Oil'"}
        bit10:       { type: t_string, initial: "'Compressor3 Oil'"}
        bit11:       { type: t_string, initial: "'Compressor4 Oil'"}
        bit12:       { type: t_string, initial: "'Alarm not defined'"}
        bit13:       { type: t_string, initial: "'Alarm not defined'"}
        bit14:       { type: t_string, initial: "'Delivery Fan Thermal Overload'"}
        bit15:       { type: t_string, initial: "'Cold Side Flow Switch'"}

########################################################################################################################
# ServicesChillerControllerAlarmStatus11
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "ServicesChillerControllerAlarmStatus11",
    comment: "Alarm indicators at AlarmStatus11 register"
    items:
        bit0:        { type: t_string, initial: "'Compressor4 Discharge High Temperature'"}
        bit1:        { type: t_string, initial: "'Alarm not defined'"}
        bit2:        { type: t_string, initial: "'Alarm not defined'"}
        bit3:        { type: t_string, initial: "'General Alarm From Digital Input'"}
        bit4:        { type: t_string, initial: "'Alarm not defined'"}
        bit5:        { type: t_string, initial: "'Alarm not defined'"}
        bit6:        { type: t_string, initial: "'Alarm not defined'"}
        bit7:        { type: t_string, initial: "'Alarm not defined'"}
        bit8:        { type: t_string, initial: "'Circ2 Pump-Down at shutdown'"}
        bit9:        { type: t_string, initial: "'Circ1 Chiller Anti-freeze'"}
        bit10:       { type: t_string, initial: "'Circ2 Chiller Anti-freeze'"}
        bit11:       { type: t_string, initial: "'Circ1 Pump Anti-freeze'"}
        bit12:       { type: t_string, initial: "'Circ2 Pump Anti-freeze'"}
        bit13:       { type: t_string, initial: "'Compressor1 Discharge High Temperature'"}
        bit14:       { type: t_string, initial: "'Compressor2 Discharge High Temperature'"}
        bit15:       { type: t_string, initial: "'Compressor3 Discharge High Temperature'"}

########################################################################################################################
# ServicesChillerControllerBitwiseConfig
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "ServicesChillerControllerBitwiseConfig",
    comment: "Config about words and masks for bitwise actions"  
    items:
        #Words for masks and commands over Unit Status register. Words 16bits
        statusOnMask:    { type: t_uint16, initial: int(0b0000001100000000), comment: "Word check if Chiller is ON" }
        switchOnMask:    { type: t_uint16, initial: int(0b0000010000000100), comment: "Word to switch ON the Chiller" }
        switchOffMask:   { type: t_uint16, initial: int(0b0000000000000001), comment: "Word to switch OFF the Chiller" }
        resetUnitMask:   { type: t_uint16, initial: int(0b0000000010000000), comment: "Word to reset controller Unit" }
        resetAlarmMask:  { type: t_uint16, initial: int(0b0001000000010000), comment: "Word to reset Alarm" }
        #Masks for bitwise checking in 16 bit registers
        flowSwitchMask:  { type: t_uint16, initial: int(0b0000100000000000), comment: "Word to check if Flow switch is ON" }
        alarmOnMask:     { type: t_uint16, initial: int(0b0000000100000001), comment: "Word to check if Alarm relay is ON" }
        waterPumpOnMask: { type: t_uint16, initial: int(0b0000001000000010), comment: "Word to check if water Pump relay is ON" }
        compressor1Mask: { type: t_uint16, initial: int(0b0010000000100000), comment: "Word to check if Compressor1 is ON" }    
        compressor2Mask: { type: t_uint16, initial: int(0b0001000000010000), comment: "Word to check if Compressor2 is ON" }
        compressor3Mask: { type: t_uint16, initial: int(0b0000100000001000), comment: "Word to check if Compressor3 is ON" }
        compressor4Mask: { type: t_uint16, initial: int(0b0000010000000100), comment: "Word to check if Compressor4 is ON" }
        #Masks for bitwise checking in 16 bit registers
        bit0:        { type: t_uint16, initial: int(0b0000000000000001), comment: "Word mask to check bit0" }
        bit1:        { type: t_uint16, initial: int(0b0000000000000010), comment: "Word mask to check bit1" }
        bit2:        { type: t_uint16, initial: int(0b0000000000000100), comment: "Word mask to check bit2" }
        bit3:        { type: t_uint16, initial: int(0b0000000000001000), comment: "Word mask to check bit3" }
        bit4:        { type: t_uint16, initial: int(0b0000000000010000), comment: "Word mask to check bit4" }
        bit5:        { type: t_uint16, initial: int(0b0000000000100000), comment: "Word mask to check bit5" }
        bit6:        { type: t_uint16, initial: int(0b0000000001000000), comment: "Word mask to check bit6" }
        bit7:        { type: t_uint16, initial: int(0b0000000010000000), comment: "Word mask to check bit7" }
        bit8:        { type: t_uint16, initial: int(0b0000000100000000), comment: "Word mask to check bit8" }
        bit9:        { type: t_uint16, initial: int(0b0000001000000000), comment: "Word mask to check bit9" }
        bit10:       { type: t_uint16, initial: int(0b0000010000000000), comment: "Word mask to check bit10" }
        bit11:       { type: t_uint16, initial: int(0b0000100000000000), comment: "Word mask to check bit11" }
        bit12:       { type: t_uint16, initial: int(0b0001000000000000), comment: "Word mask to check bit12" }
        bit13:       { type: t_uint16, initial: int(0b0010000000000000), comment: "Word mask to check bit13" }
        bit14:       { type: t_uint16, initial: int(0b0100000000000000), comment: "Word mask to check bit14" }
        bit15:       { type: t_uint16, initial: int(0b1000000000000000), comment: "Word mask to check bit15" }


########################################################################################################################
# ServicesChillerControllerAlarmStatusRegisters
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "ServicesChillerControllerAlarmStatusRegisters",
    comment: "Config about Alarm statuses registers"
    items:
        AlarmStatus1:
            type: THISLIB.ServicesChillerControllerAlarmStatus1
            comment: "Alarm indicators at AlarmStatus1 register"
        AlarmStatus2:
            type: THISLIB.ServicesChillerControllerAlarmStatus2
            comment: "Alarm indicators at AlarmStatus2 register"
        AlarmStatus3:
            type: THISLIB.ServicesChillerControllerAlarmStatus3
            comment: "Alarm indicators at AlarmStatus3 register"
        AlarmStatus6:
            type: THISLIB.ServicesChillerControllerAlarmStatus6
            comment: "Alarm indicators at AlarmStatus6 register"
        AlarmStatus7:
            type: THISLIB.ServicesChillerControllerAlarmStatus7
            comment: "Alarm indicators at AlarmStatus7 register"
        AlarmStatus10:
            type: THISLIB.ServicesChillerControllerAlarmStatus10
            comment: "Alarm indicators at AlarmStatus10 register"
        AlarmStatus11:
            type: THISLIB.ServicesChillerControllerAlarmStatus11
            comment: "Alarm indicators at AlarmStatus11 register"


########################################################################################################################
# ServicesChillerControllerVariables
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "ServicesChillerControllerVariables",
    items:
        #Logical Area 3. Data. R/W. Words 16bits
        setpoint:
            type: t_double
            comment: "Setpoint"
        minSetpoint: 
            type: t_double
            comment: "Minimun setpoint"
        maxSetpoint:
            type: t_double
            comment: "Maximal setpoint"
        trippingBand:
            type: t_double
            comment: "Tripping band"     


########################################################################################################################
# ServicesChillerControllerConfig
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "ServicesChillerControllerConfig",
    items:
        unitID:
            type: t_uint8
            comment: "The address or UnitID of the controller"
        waterTankTemperatureMeasurement:
            type: COMMONLIB.MeasurementConfig
            comment: "The WaterTank measurement config"
        warningMessageWaterTemperatureMeasurement:
            type: t_string
            comment: "A warning message (empty = not shown)"
        waterPumpSupervisorMeasurement:
            type: COMMONLIB.MeasurementConfig
            comment: "The WaterPump supervisor measurement config"
        messageWaterPumpSupervisorMeasurement:
            type: t_string
            comment: "A message to be shown on config tab"
        warningMessageWaterPumpSupervisorMeasurement:
            type: t_string
            comment: "A warning message (empty = not shown)"
        parameterAddresses:
            type: THISLIB.ServicesChillerControllerParameterAddresses
            comment: "Config about Modbus parameters addresses"
        variables:
            type: THISLIB.ServicesChillerControllerVariables
            comment: "Config value for some parameters"
        alarmRegisters:
            type: THISLIB.ServicesChillerControllerAlarmStatusRegisters
            comment: "Config about Alarm statuses registers"
        bitwise:
            type: THISLIB.ServicesChillerControllerBitwiseConfig
            comment: "Config about words and masks for bitwise actions"

########################################################################################################################
# ServicesChillerConfig
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "ServicesChillerConfig",
    items:
        updateSetpoint:
            type: t_bool
            comment: "True to automatically update the setpoint"
        temperatureToChangeSetpoint:
            type: t_double
            comment: "Temperature to change Setpoint"   
        summerSetpoint:
            type: t_double
            comment: "Temperature setpoint for summer"            
        winterSetpoint:
            type: t_double
            comment: "Temperature setpoint for winter"
        offsetSetpoint:
            type: t_double
            comment: "Setpoint = air temperature of meteo station + this offset (in degrees celsius)"
        updateSetpointInterval:
            type: t_double
            comment: "Time interval to check ambient/setpoint temperature in seconds"
        updateVariables:
            type: t_bool
            comment: "True to automatically update the setpoint"
        pollingMeasuresInterval:
            type: t_double
            comment: "Time between bus measurement reads in seconds"
        pollingConfigInterval:
            type: t_double
            comment: "Time between bus config variables reads in seconds"
        pollingAlarmsInterval:
            type: t_double
            comment: "Time between bus alarm registers reads in seconds"
        chillerMainController:
            type: THISLIB.ServicesChillerControllerConfig
            comment: "The Chiller controller config"

########################################################################################################################
# ServicesConfig
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "ServicesConfig",
    items:
        timing:
            type: THISLIB.ServicesTimingConfig
            comment: "Timing config"
            expand: false
        meteo:
            type: THISLIB.ServicesMeteoConfig
            comment: "Meteo config"
        west:
            type: THISLIB.ServicesWestConfig
            comment: "West config"
        chiller:
            type: THISLIB.ServicesChillerConfig
            comment: "Chiller config"

########################################################################################################################
# Services
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB,  "Services",
    variables:
        editableConfig                  : { type: THISLIB.ServicesConfig        , comment: "Editable configuration of the Services subsystem", expand: false }
    references:
        operatorStatus                  : { type: COMMONLIB.OperatorStatus      , comment: "Shared operator status" }
        domeApertureStatus              : { type: COMMONLIB.ApertureStatus      , comment: "Is the dome open or closed?", expand: false }
    variables_read_only:
        config                          : { type: THISLIB.ServicesConfig        , comment: "Active configuration of the Services subsystem" }
    parts:
        timing:
            comment                     : "Timing service"
            arguments:
                config                  : {}
                operatorStatus          : {}
            attributes:
                statuses:
                    attributes:
                        healthStatus    : { type: COMMONLIB.HealthStatus }
        meteo:
            comment                     : "Meteo service"
            arguments:
                config                  : {}
            attributes:
                airTemperature          : {}
                statuses:
                    attributes:
                        healthStatus    : { type: COMMONLIB.HealthStatus }
        west:
            comment                     : "West service"
            arguments:
                operatorStatus          : {}
                config                  : {}
                airTemperature          : {}
                domeApertureStatus      : {}
            attributes:
                statuses:
                    attributes:
                        healthStatus    : { type: COMMONLIB.HealthStatus }       
        chiller:
            comment                     : "Chiller service"
            arguments:
                operatorStatus          : {}
                config                  : {}
                airTemperature          : {}
            attributes:
                statuses:
                    attributes:
                        healthStatus    : { type: COMMONLIB.HealthStatus }
        io:
            comment                     : "I/O modules"
            attributes:
                statuses:
                    attributes:
                        healthStatus    : { type: COMMONLIB.HealthStatus }
        configManager:
            comment                     : "The config manager (to load/save/activate configuration data)"
            type                        : COMMONLIB.ConfigManager
    statuses:
        initializationStatus            : { type: COMMONLIB.InitializationStatus }
        healthStatus                    : { type: COMMONLIB.HealthStatus }
        busyStatus                      : { type: COMMONLIB.BusyStatus }
        operatingStatus                 : { type: COMMONLIB.OperatingStatus }
    processes:
        initialize                      : { type: COMMONLIB.Process                       , comment: "Start initializing" }
        lock                            : { type: COMMONLIB.Process                       , comment: "Lock the system" }
        unlock                          : { type: COMMONLIB.Process                       , comment: "Unlock the system" }
        changeOperatingState            : { type: COMMONLIB.ChangeOperatingStateProcess   , comment: "Change the operating state (e.g. AUTO, MANUAL, ...)" }
    calls:
        initialize:
            isEnabled                   : -> OR(self.statuses.initializationStatus.shutdown,
                                                self.statuses.initializationStatus.initializingFailed,
                                                self.statuses.initializationStatus.initialized)
        lock:
            isEnabled                   : -> AND(self.operatorStatus.tech, self.statuses.initializationStatus.initialized)
        unlock:
            isEnabled                   : -> AND(self.operatorStatus.tech, self.statuses.initializationStatus.locked)
        changeOperatingState:
            isEnabled                   : -> FALSE # there is no MANUAL mode #-> AND(self.statuses.busyStatus.idle, self.statuses.initializationStatus.initialized)
        operatingStatus:
            superState                  : -> self.statuses.initializationStatus.initialized
        healthStatus:
            isGood                      : -> MTCS_SUMMARIZE_GOOD(self.parts.timing, 
                                                                 self.parts.meteo,
                                                                 self.parts.west,
                                                                 self.parts.chiller,
                                                                 self.parts.io)
            hasWarning                  : -> MTCS_SUMMARIZE_WARN(self.parts.timing, 
                                                                 self.parts.meteo,
                                                                 self.parts.west,
                                                                 self.parts.chiller,
                                                                 self.parts.io)
        busyStatus:
            isBusy                      : -> self.statuses.initializationStatus.initializing
        configManager:
            isEnabled                   : -> self.operatorStatus.tech
        timing:
            operatorStatus              : -> self.operatorStatus
            config                      : -> self.config.timing
        meteo:
            config                      : -> self.config.meteo
        west:
            operatorStatus              : -> self.operatorStatus
            config                      : -> self.config.west
            airTemperature              : -> self.parts.meteo.airTemperature
            domeApertureStatus          : -> self.domeApertureStatus
        chiller:
            operatorStatus              : -> self.operatorStatus
            config                      : -> self.config.chiller
            airTemperature              : -> self.parts.meteo.airTemperature

########################################################################################################################
# ServicesTiming
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB,  "ServicesTiming",
    typeOf                              : [ THISLIB.ServicesParts.timing ]
    variables:
        fromEL6688                      : { type: TMCLIB.TmcFromIoEL6688        , address: "%I*" , comment: "Data from the EL6688", expand: false}
        fromEcatMaster                  : { type: TMCLIB.TmcFromIoEcatMaster    , address: "%I*" , comment: "Data from the EtherCAT master", expand: false}
        fromCppTiming                   : { type: TMCLIB.TmcToPlcTiming         , address: "%I*" , comment: "Data from the C++ task", expand: false}
    references:
        operatorStatus                  : { type: COMMONLIB.OperatorStatus      , comment: "Shared operator status"}
        config                          : { type: THISLIB.ServicesTimingConfig  , comment: "The config" }
    variables_read_only:
        toCppTiming                     : { type: TMCLIB.TmcFromPlcTiming       , address: "%Q*" , comment: "Data to the C++ task", expand: false}
        # actual source
        utcDateString                   : { type: t_string                      , comment: "UTC date as a string of format YYYY-MM-DD" }
        utcTimeString                   : { type: t_string                      , comment: "UTC time as a string of format HH-MM-SS.SSS" }
        # timestamp strings
        internalTimestampString         : { type : t_string                     , comment: "String representation of the internal timestamp"}
        externalTimestampString         : { type : t_string                     , comment: "String representation of the external timestamp (note: this is TAI, not UTC!)"}
    parts:
        serialInfo:
            comment                     : "Info acquired by serial link"
            attributes:
                statuses:
                    attributes:
                        healthStatus    : { type: COMMONLIB.HealthStatus }
    statuses:
        healthStatus                    : { type: COMMONLIB.HealthStatus }
    processes:
        {}
    calls:
        healthStatus:
            isGood                      : -> OR(self.config.ignoreSerialError, self.parts.serialInfo.statuses.healthStatus.good)


########################################################################################################################
# ServicesTimingSerialInfo
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB,  "ServicesTimingSerialInfo",
    typeOf                          : [ THISLIB.ServicesTimingParts.serialInfo ]
    variables_read_only:
        serialTimeout               : { type: t_bool    , comment: "Is the serial data not being received within time?" }
        comError                    : { type: t_bool    , comment: "Is there any problem with the COM port?" }
        comErrorID                  : { type: t_int16   , comment: "COM error id (see Beckhoff ComError_t)" }
        comErrorDescription         : { type: t_string  , comment: "Description of the COM error id" }
        time_h                      : { type: t_uint8   , comment: "Time: hours (0-24)" }
        time_m                      : { type: t_uint8   , comment: "Time: minutes (0-59)" }
        time_s                      : { type: t_uint8   , comment: "Time: seconds (0-59, or 60 if leap second)" }
        latitude_deg                : { type: t_uint8   , comment: "Latitude: degrees (0-90)" }
        latitude_min                : { type: t_float   , comment: "Latitude: minutes (0.0-59.99999)" }
        latitude_sign               : { type: t_string  , comment: "Latitude: sign (either 'N' or 'S')" }
        longitude_deg               : { type: t_uint8   , comment: "Longitude: degrees (0-180)" }
        longitude_min               : { type: t_float   , comment: "Longitude: minutes (0.0-59.99999)" }
        longitude_sign              : { type: t_string  , comment: "Longitude: sign (either 'E' or 'W')" }
        positionFix                 : { type: t_bool    , comment: "True if a position fix was accomplished, False if not" }
        satellitesUsed              : { type: t_uint8   , comment: "Number of satellites used" }
        horizontalDilutionOfPosition: { type: t_float   , comment: "Horizontal dilution of position" }
        meanSeaLevelAltitude        : { type: t_float   , comment: "Mean altitude above sea level in meters" }
        geoidSeparation             : { type: t_float   , comment: "Geoid separation in meters" }
        checksum                    : { type: t_uint8   , comment: "Checksum send by the time server" }
        calculatedChecksum          : { type: t_uint8   , comment: "Checksum calculated by the PLC" }
    statuses:
        portHealthStatus            : { type: COMMONLIB.HealthStatus }
        transmissionHealthStatus    : { type: COMMONLIB.HealthStatus }
        checksumHealthStatus        : { type: COMMONLIB.HealthStatus }
        healthStatus                : { type: COMMONLIB.HealthStatus }
    calls:
        portHealthStatus:
            isGood                  : -> NOT self.comError
        transmissionHealthStatus:
            isGood                  : -> NOT self.serialTimeout
        checksumHealthStatus:
            isGood                  : -> EQ( self.checksum, self.calculatedChecksum )
        healthStatus:
            isGood                  : -> AND( self.statuses.portHealthStatus.good,
                                              self.statuses.transmissionHealthStatus.good,
                                              self.statuses.checksumHealthStatus.good )



########################################################################################################################
# ServicesMeteoId
########################################################################################################################


MTCS_MAKE_ENUM THISLIB, "ServicesMeteoId",
    items:
        [
            "WIND_SPEED_MINIMUM",
            "WIND_SPEED_AVERAGE",
            "WIND_SPEED_MAXIMUM",
            "WIND_DIRECTION_MINIMUM",
            "WIND_DIRECTION_AVERAGE",
            "WIND_DIRECTION_MAXIMUM",
            "AIR_PRESSURE",
            "AIR_TEMPERATURE",
            "INTERNAL_TEMPERATURE",
            "RELATIVE_HUMIDITY",
            "RAIN_ACCUMULATION",
            "RAIN_DURATION",
            "RAIN_INTENSITY",
            "RAIN_PEAK_INTENSITY",
            "HAIL_ACCUMULATION",
            "HAIL_DURATION",
            "HAIL_PEAK_INTENSITY",
            "HAIL_INTENSITY",
            "HEATING_TEMPERATURE",
            "HEATING_VOLTAGE",
            "SUPPLY_VOLTAGE",
            "REFERENCE_VOLTAGE",
        ]


########################################################################################################################
# ServicesMeteoMeasurement
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB, "ServicesMeteoMeasurement",
    variables:
        id              : { type: THISLIB.ServicesMeteoId       , comment: "ID" }
    variables_hidden:
        inputString     : { type: t_string                      , comment: "Input string from the meteo station" }
    variables_read_only:
        data            : { type: COMMONLIB.QuantityValue       , comment: "Actual value" }
        invalidData     : { type: t_bool                        , comment: "True if the data is invalid" }
        lastChar        : { type: t_string                      , comment: "Last character" }
        name            : { type: t_string                      , comment: "Name of the measurementw" }
    references:
        config          : { type: COMMONLIB.MeasurementConfig   , comment: "Reference to the config" }
    statuses:
        enabledStatus   : { type: COMMONLIB.EnabledStatus       , comment: "Is the temperature being measured?" }
        healthStatus    : { type: COMMONLIB.HealthStatus        , comment: "Is the data valid and within range?" }
        alarmStatus     : { type: COMMONLIB.HiHiLoLoAlarmStatus , comment: "Alarm status"}
    calls:
        enabledStatus:
            isEnabled    : -> self.config.enabled
        alarmStatus:
            superState   : -> self.statuses.enabledStatus.enabled
            config       : -> self.config.alarms
            value        : -> self.data.value
        healthStatus:
            superState   : -> self.statuses.enabledStatus.enabled
            isGood       : -> NOT( OR(self.invalidData,
                                      self.statuses.alarmStatus.hiHi,
                                      self.statuses.alarmStatus.loLo))
            hasWarning   : -> OR( self.statuses.alarmStatus.hi,
                                  self.statuses.alarmStatus.lo )



########################################################################################################################
# ServicesMeteo
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB,  "ServicesMeteo",
    typeOf                              : [ THISLIB.ServicesParts.meteo ]
    variables:
        # serial comm
        serialTimeout               : { type: t_bool    , comment: "Is the serial data not being received within time?" }
        comError                    : { type: t_bool    , comment: "Is there any problem with the COM port?" }
        comErrorID                  : { type: t_int16   , comment: "COM error id (see Beckhoff ComError_t)" }
        comErrorDescription         : { type: t_string  , comment: "Description of the COM error id" }
        # measurements
        windSpeedMinimum            : { type: THISLIB.ServicesMeteoMeasurement  , comment: "Wind speed minimum" }
        windSpeedAverage            : { type: THISLIB.ServicesMeteoMeasurement  , comment: "Wind speed average" }
        windSpeedMaximum            : { type: THISLIB.ServicesMeteoMeasurement  , comment: "Wind speed maximum" }
        windDirectionMinimum        : { type: THISLIB.ServicesMeteoMeasurement  , comment: "Wind direction minimum" }
        windDirectionAverage        : { type: THISLIB.ServicesMeteoMeasurement  , comment: "Wind direction average" }
        windDirectionMaximum        : { type: THISLIB.ServicesMeteoMeasurement  , comment: "Wind direction maximum" }
        airPressure                 : { type: THISLIB.ServicesMeteoMeasurement  , comment: "Air pressure" }
        airTemperature              : { type: THISLIB.ServicesMeteoMeasurement  , comment: "Air temperature" }
        internalTemperature         : { type: THISLIB.ServicesMeteoMeasurement  , comment: "Internal temperature" }
        relativeHumidity            : { type: THISLIB.ServicesMeteoMeasurement  , comment: "Relative humidity" }
        rainAccumulation            : { type: THISLIB.ServicesMeteoMeasurement  , comment: "Rain accumulation" }
        rainDuration                : { type: THISLIB.ServicesMeteoMeasurement  , comment: "Rain duration" }
        rainIntensity               : { type: THISLIB.ServicesMeteoMeasurement  , comment: "Rain intensity" }
        rainPeakIntensity           : { type: THISLIB.ServicesMeteoMeasurement  , comment: "Rain peak intensity" }
        hailAccumulation            : { type: THISLIB.ServicesMeteoMeasurement  , comment: "Hail accumulation" }
        hailDuration                : { type: THISLIB.ServicesMeteoMeasurement  , comment: "Hail duration" }
        hailIntensity               : { type: THISLIB.ServicesMeteoMeasurement  , comment: "Hail intensity" }
        hailPeakIntensity           : { type: THISLIB.ServicesMeteoMeasurement  , comment: "Hail peak intensity" }
        heatingTemperature          : { type: THISLIB.ServicesMeteoMeasurement  , comment: "Heating temperature" }
        heatingVoltage              : { type: THISLIB.ServicesMeteoMeasurement  , comment: "Heating voltage" }
        supplyVoltage               : { type: THISLIB.ServicesMeteoMeasurement  , comment: "Supply voltage" }
        referenceVoltage            : { type: THISLIB.ServicesMeteoMeasurement  , comment: "Reference voltage" }
        # durationOK
        durationOK                  : { type: COMMONLIB.Duration                , comment: "Duration that the meteo is OK" }
        dewpoint                    : { type: COMMONLIB.Temperature             , comment: "Calculated dewpoint" }
        wet                         : { type: t_bool                            , comment: "Wet if (rainIntensity+hailIntensity) > config.wetLimit" }
        heating                     : { type: t_bool                            , comment: "Heating or not?"}
        windDirectionMinimumString  : { type: t_string                          , comment: "Average direction of the wind as a string"}
        windDirectionAverageString  : { type: t_string                          , comment: "Average direction of the wind as a string"}
        windDirectionMaximumString  : { type: t_string                          , comment: "Average direction of the wind as a string"}
    references:
        config                      : { type: THISLIB.ServicesMeteoConfig  , comment: "The config" }
    statuses:
        meteoHealthStatus            : { type: COMMONLIB.HealthStatus }
        healthStatus                : { type: COMMONLIB.HealthStatus }
    processes:
        {}
    calls:
        windSpeedMinimum:
            id                      : -> THISLIB.ServicesMeteoId.WIND_SPEED_MINIMUM
            config                  : -> self.config.windSpeedMinimum
        windSpeedAverage:
            id                      : -> THISLIB.ServicesMeteoId.WIND_SPEED_AVERAGE
            config                  : -> self.config.windSpeedAverage
        windSpeedMaximum:
            id                      : -> THISLIB.ServicesMeteoId.WIND_SPEED_MAXIMUM
            config                  : -> self.config.windSpeedMaximum
        windDirectionMinimum:
            id                      : -> THISLIB.ServicesMeteoId.WIND_DIRECTION_MINIMUM
            config                  : -> self.config.windDirectionMinimum
        windDirectionAverage:
            id                      : -> THISLIB.ServicesMeteoId.WIND_DIRECTION_AVERAGE
            config                  : -> self.config.windDirectionAverage
        windDirectionMaximum:
            id                      : -> THISLIB.ServicesMeteoId.WIND_DIRECTION_MAXIMUM
            config                  : -> self.config.windDirectionMaximum
        airPressure:
            id                      : -> THISLIB.ServicesMeteoId.AIR_PRESSURE
            config                  : -> self.config.airPressure
        airTemperature:
            id                      : -> THISLIB.ServicesMeteoId.AIR_TEMPERATURE
            config                  : -> self.config.airTemperature
        internalTemperature:
            id                      : -> THISLIB.ServicesMeteoId.INTERNAL_TEMPERATURE
            config                  : -> self.config.internalTemperature
        relativeHumidity:
            id                      : -> THISLIB.ServicesMeteoId.RELATIVE_HUMIDITY
            config                  : -> self.config.relativeHumidity
        rainAccumulation:
            id                      : -> THISLIB.ServicesMeteoId.RAIN_ACCUMULATION
            config                  : -> self.config.rainAccumulation
        rainDuration:
            id                      : -> THISLIB.ServicesMeteoId.RAIN_DURATION
            config                  : -> self.config.rainDuration
        rainIntensity:
            id                      : -> THISLIB.ServicesMeteoId.RAIN_INTENSITY
            config                  : -> self.config.rainIntensity
        rainPeakIntensity:
            id                      : -> THISLIB.ServicesMeteoId.RAIN_PEAK_INTENSITY
            config                  : -> self.config.rainPeakIntensity
        hailAccumulation:
            id                      : -> THISLIB.ServicesMeteoId.HAIL_ACCUMULATION
            config                  : -> self.config.hailAccumulation
        hailDuration:
            id                      : -> THISLIB.ServicesMeteoId.HAIL_DURATION
            config                  : -> self.config.hailDuration
        hailIntensity:
            id                      : -> THISLIB.ServicesMeteoId.HAIL_INTENSITY
            config                  : -> self.config.hailIntensity
        hailPeakIntensity:
            id                      : -> THISLIB.ServicesMeteoId.HAIL_PEAK_INTENSITY
            config                  : -> self.config.hailPeakIntensity
        heatingTemperature:
            id                      : -> THISLIB.ServicesMeteoId.HEATING_TEMPERATURE
            config                  : -> self.config.heatingTemperature
        heatingVoltage:
            id                      : -> THISLIB.ServicesMeteoId.HEATING_VOLTAGE
            config                  : -> self.config.heatingVoltage
        supplyVoltage:
            id                      : -> THISLIB.ServicesMeteoId.SUPPLY_VOLTAGE
            config                  : -> self.config.supplyVoltage
        referenceVoltage:
            id                      : -> THISLIB.ServicesMeteoId.REFERENCE_VOLTAGE
            config                  : -> self.config.referenceVoltage
        healthStatus:
            isGood                  : -> NOT( OR(self.serialTimeout, self.comError) )
        meteoHealthStatus:
            superState              : -> self.statuses.healthStatus.good
            isGood                  : -> MTCS_SUMMARIZE_GOOD_OR_DISABLED(
                                                self.windSpeedMinimum,
                                                self.windSpeedAverage,
                                                self.windSpeedMaximum,
                                                self.windDirectionMinimum,
                                                self.windDirectionAverage,
                                                self.windDirectionMaximum,
                                                self.airPressure,
                                                self.airTemperature,
                                                self.internalTemperature,
                                                self.relativeHumidity,
                                                self.rainAccumulation,
                                                self.rainDuration,
                                                self.rainIntensity,
                                                self.rainPeakIntensity,
                                                self.hailAccumulation,
                                                self.hailDuration,
                                                self.hailIntensity,
                                                self.hailPeakIntensity,
                                                self.heatingTemperature,
                                                self.heatingVoltage,
                                                self.supplyVoltage,
                                                self.referenceVoltage
                                        )
            hasWarning                 : -> MTCS_SUMMARIZE_WARN(
                                                self.windSpeedMinimum,
                                                self.windSpeedAverage,
                                                self.windSpeedMaximum,
                                                self.windDirectionMinimum,
                                                self.windDirectionAverage,
                                                self.windDirectionMaximum,
                                                self.airPressure,
                                                self.airTemperature,
                                                self.internalTemperature,
                                                self.relativeHumidity,
                                                self.rainAccumulation,
                                                self.rainDuration,
                                                self.rainIntensity,
                                                self.rainPeakIntensity,
                                                self.hailAccumulation,
                                                self.hailDuration,
                                                self.hailIntensity,
                                                self.hailPeakIntensity,
                                                self.heatingTemperature,
                                                self.heatingVoltage,
                                                self.supplyVoltage,
                                                self.referenceVoltage
                                        )

########################################################################################################################
# ServicesWestController
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB,  "ServicesWestController",
    variables:
        isEnabled           : { type: t_bool, comment: "Are the processes enabled?" }
        manualControl       : { type: t_bool, comment: "Controller switched to manualControl" }
        unit                : { type: COMMONLIB.Units }
        setpoint            : { type: COMMONLIB.QuantityValue, comment: "The current setpoint" }
        defaultSetpoint     : { type: COMMONLIB.QuantityValue, comment: "The default setpoint" }
        minSetpoint         : { type: COMMONLIB.QuantityValue, comment: "The minimun setpoint" }
        maxSetpoint         : { type: COMMONLIB.QuantityValue, comment: "The maximal setpoint" }
        offset              : { type: COMMONLIB.QuantityValue, comment: "Offset internally added to Process Value" }
        differentialOnOff   : { type: COMMONLIB.QuantityValue, comment: "Differential band for On/Off" }
        alarmValue          : { type: COMMONLIB.QuantityValue, comment: "Alarm value from setpoint" }
        inputFilter         : { type: COMMONLIB.QuantityValue, comment: "Input input filter time constant" }
        cycleTime           : { type: COMMONLIB.QuantityValue, comment: "Cycle time for control loop" }
        proportionalBand    : { type: COMMONLIB.QuantityValue, comment: "Proportional band constant" }
        resetTime           : { type: COMMONLIB.QuantityValue, comment: "Integral time constant" }
        rate                : { type: COMMONLIB.QuantityValue, comment: "Derivative time constant" }
        outputPower         : { type: COMMONLIB.QuantityValue, comment: "The Output power in percentage" }

    variables_read_only:
        invalidData         : { type: t_bool                 , comment: "True if there is invalid data"}
        processValue        : { type: COMMONLIB.QuantityValue, comment: "The Process value" }
        alarmActivated      : { type: t_bool                 , comment: "True if controller alarm is activated"}

    references:
        config              : { type: THISLIB.ServicesWestControllerConfig, comment: "A small config only for a single WEST controller" }
        bus                 : { type: COMMONLIB.ModbusRTUBus         , comment: "The shared Modbus RTU bus" }

    processes:
        updateProcessVariables    : { type: COMMONLIB.Process, comment: "Read process variables"}
        updateConfigVariables     : { type: COMMONLIB.Process, comment: "Read config variables"}
        writeSetpoint             : { type: COMMONLIB.ChangeSetpointProcess, comment: "Write the setpoint"}
        writeOffset               : { type: COMMONLIB.ChangeParameterProcess, comment: "Set an internal offset to Process Value"}
        writeProportinalBand      : { type: COMMONLIB.ChangeParameterProcess, comment: "Set the Proportinal band constant"}
        writeResetTime            : { type: COMMONLIB.ChangeParameterProcess, comment: "Set the Integral time constant"}
        writeRate                 : { type: COMMONLIB.ChangeParameterProcess, comment: "Set the Derivative time constant"}
        switchToManual            : { type: COMMONLIB.Process, comment: "Switch controller to Manual"}
        switchToAuto              : { type: COMMONLIB.Process, comment: "Switch controller to Auto"}
        writeOutputPower          : { type: COMMONLIB.ChangeParameterProcess, comment: "Set a specific output power"}
        writeConfigToController   : { type: COMMONLIB.Process, comment: "Write saved config to Controller"}

    statuses:
        healthStatus        : { type: COMMONLIB.HealthStatus        , comment: "Is the data valid and within range?" }
        alarmStatus         : { type: COMMONLIB.HiHiLoLoAlarmStatus , comment: "Alarm status"}

    calls:
        alarmStatus:
            superState   : -> self.config.measurement.enabled
            config       : -> self.config.measurement.alarms
            value        : -> self.processValue.value
        healthStatus:
            superState   : -> self.config.measurement.enabled
            isGood       : -> NOT( OR(self.invalidData,
                                      self.statuses.alarmStatus.hiHi,
                                      self.statuses.alarmStatus.loLo))
            hasWarning   : -> OR( self.statuses.alarmStatus.hi,
                                  self.statuses.alarmStatus.lo )
        updateProcessVariables:
            isEnabled:  -> self.isEnabled
        updateConfigVariables:
            isEnabled:  -> self.isEnabled
        writeSetpoint:
            isEnabled:  -> self.isEnabled
        writeOffset:
            isEnabled:  -> self.isEnabled
        writeProportinalBand:
            isEnabled:  -> self.isEnabled
        writeResetTime:
            isEnabled:  -> self.isEnabled
        writeRate:
            isEnabled:  -> self.isEnabled
        switchToManual:
            isEnabled:  -> self.isEnabled
        switchToAuto:
            isEnabled:  -> self.isEnabled
        writeOutputPower:
            isEnabled:  -> self.isEnabled
        writeConfigToController:
            isEnabled:  -> self.isEnabled

########################################################################################################################
# ServicesWest
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB,  "ServicesWest",
    typeOf                          : [ THISLIB.ServicesParts.west ]
    variables:
        {}
    references:
        operatorStatus              : { type: COMMONLIB.OperatorStatus          , comment: "Shared operator status" }
        config                      : { type: THISLIB.ServicesWestConfig        , comment: "The config" }
        airTemperature              : { type: THISLIB.ServicesMeteoMeasurement  , comment: "Air temperature" }
        domeApertureStatus          : { type: COMMONLIB.ApertureStatus      , comment: "Is the dome open or closed?", expand: false }
    statuses:
        healthStatus                : { type: COMMONLIB.HealthStatus      , comment: "Are the WESTs in healthy state (good) or not (bad)" }
        operatingStatus             : { type: COMMONLIB.OperatingStatus   , comment: "Are the WESTs being polled (auto) or not (manual)?" }
    parts:
        bus                         : { type: COMMONLIB.ModbusRTUBus         , comment: "The shared Modbus RTU bus" }
        domeTemperature             : { type: THISLIB.ServicesWestController , comment: "The West coparts.chillerMainController.parts.chillerMainControllerntroller at the dome to control the temperature " }
        firstFloorTemperature       : { type: THISLIB.ServicesWestController , comment: "The West controller at the first floor to control the temperature" }
        pumpsRoomTemperature        : { type: THISLIB.ServicesWestController , comment: "The West controller at the pumps room to control the temperature" }
        oilHeatExchangerTemperature : { type: THISLIB.ServicesWestController , comment: "The West controller at the heat exchanger to control the oil temperature" }
        serversRoomTemperature     : { type: THISLIB.ServicesWestController , comment: "The West controller at the servers room to control the temperature" }
    processes:
        changeOperatingState        : { type: COMMONLIB.ChangeOperatingStateProcess   , comment: "Change the operating state (e.g. AUTO, MANUAL, ...)" }
    calls:
        operatingStatus:
            {}
        changeOperatingState:
            isEnabled               : -> self.operatorStatus.tech
        healthStatus:
            isGood                  : -> MTCS_SUMMARIZE_GOOD(self.parts.domeTemperature,
                                                             self.parts.firstFloorTemperature,
                                                             self.parts.pumpsRoomTemperature,
                                                             self.parts.oilHeatExchangerTemperature,
                                                             self.parts.serversRoomTemperature)
            hasWarning              : -> MTCS_SUMMARIZE_WARN(self.parts.domeTemperature,
                                                             self.parts.firstFloorTemperature,
                                                             self.parts.pumpsRoomTemperature,
                                                             self.parts.oilHeatExchangerTemperature,
                                                             self.parts.serversRoomTemperature)
        bus:
            isEnabled               : -> AND(self.operatorStatus.tech, self.statuses.operatingStatus.manual)
        domeTemperature:
            isEnabled               : -> self.parts.bus.isEnabled
            unit                    : -> COMMONLIB.Units.DEGREES_CELSIUS
            config                  : -> self.config.domeTemperature
            bus                     : -> self.parts.bus
        firstFloorTemperature:
            isEnabled               : -> self.parts.bus.isEnabled
            unit                    : -> COMMONLIB.Units.DEGREES_CELSIUS
            config                  : -> self.config.firstFloorTemperature
            bus                     : -> self.parts.bus
        pumpsRoomTemperature:
            isEnabled               : -> self.parts.bus.isEnabled
            unit                    : -> COMMONLIB.Units.DEGREES_CELSIUS
            config                  : -> self.config.pumpsRoomTemperature
            bus                     : -> self.parts.bus
        oilHeatExchangerTemperature:
            isEnabled               : -> self.parts.bus.isEnabled
            unit                    : -> COMMONLIB.Units.DEGREES_CELSIUS
            config                  : -> self.config.oilHeatExchangerTemperature
            bus                     : -> self.parts.bus
        serversRoomTemperature:
            isEnabled               : -> self.parts.bus.isEnabled
            unit                    : -> COMMONLIB.Units.DEGREES_CELSIUS
            config                  : -> self.config.serversRoomTemperature
            bus                     : -> self.parts.bus

########################################################################################################################
# ServicesChillerController
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB,  "ServicesChillerController",
    variables :
        isEnabled            : { type: t_bool , comment: "Are the processes enabled?" }
        chillerOn            : { type: t_bool, comment: "The unit status, TRUE = Chiller is ON" }
        resetAlarmRegisters  : { type: t_bool, comment: "Flag to reset all active alarms"}
        #Logical Area 3. Data. R/W. Words 16bits
        setpoint             : { type: COMMONLIB.QuantityValue, comment: "The setpoint" }
        minSetpoint          : { type: COMMONLIB.QuantityValue, comment: "The minimun setpoint" }
        maxSetpoint          : { type: COMMONLIB.QuantityValue, comment: "The maximal setpoint" }
        trippingBand         : { type: COMMONLIB.QuantityValue, comment: "The tripping band" }
        #Logical Area 5. Unit Status. R/W. Words 16bits
        unitStatus           : { type: COMMONLIB.QuantityValue, comment: "The unit status" }
        unitResetRegister    : { type: COMMONLIB.QuantityValue, comment: "The unit reset register" }
        #Logical Area 14. Load hours. R/W. Words 16bits
        hoursCompressor1     : { type: COMMONLIB.QuantityValue, comment: "Operation hours of compressor 1" }
        hoursCompressor2     : { type: COMMONLIB.QuantityValue, comment: "Operation hours of compressor 2" }
        hoursCompressor3     : { type: COMMONLIB.QuantityValue, comment: "Operation hours of compressor 3" }
        hoursCompressor4     : { type: COMMONLIB.QuantityValue, comment: "Operation hours of compressor 4" }
        hoursPump            : { type: COMMONLIB.QuantityValue, comment: "Operation hours of water pump" }
            
    variables_read_only:
        invalidData          : { type: t_bool                 , comment: "True if there is invalid data"}
        #Logical Area 1. Analog input. Read only. Words 16bits
        waterTankTemperature : { type: COMMONLIB.QuantityValue, comment: "Water tank temperature" }
        highPressureCircuit1 : { type: COMMONLIB.QuantityValue, comment: "High pressure of circuit 1" }
        highPressureCircuit2 : { type: COMMONLIB.QuantityValue, comment: "High pressure of circuit 2" }
        chillerCurrentInput  : { type: COMMONLIB.QuantityValue, comment: "Chiller current input" }
        waterPumpCurrentInput: { type: COMMONLIB.QuantityValue, comment: "Water pump current input" }
        evaporatorOutTemp1   : { type: COMMONLIB.QuantityValue, comment: "Evaporator out temperature 1" }
        evaporatorOutTemp2   : { type: COMMONLIB.QuantityValue, comment: "EvaporwaterTankTemperatureMeasurementator out temperature 2" }
        ambientTemperature   : { type: COMMONLIB.QuantityValue, comment: "Ambient temperature" }
        waterPumpChassisTemp : { type: COMMONLIB.QuantityValue, comment: "Water Pump chassis temperature" }
        #Logical Area 2. Digital input. Read only. Words 16bits
        flowSwitchStatus     : { type: t_bool, comment: "Flow switch status. Digital Input Status 1" }
        digitalInputStatus2  : { type: t_bool, comment: "Digital input status 2" }
        digitalInputStatus3  : { type: t_bool, comment: "Digital input status 3" }
        digitalInputStatus4  : { type: t_bool, comment: "Digital input status 4" }
        #Logical Area 8. Digital output status. Read only. Words 16bits
        alarmRelayOutput     : { type: t_bool, comment: "Alarm output relay output status 1" }
        waterPumpRelayOutput : { type: t_bool, comment: "Water pump output relay output status 1" }
        relayOutputStatus2   : { type: t_bool, comment: "Relay output status 2" }
        relayOutputStatus3   : { type: t_bool, comment: "Relay output status 3" }
        compressorStatus1    : { type: t_bool, comment: "Compressor 1 status. ON/OFF" }
        compressorStatus2    : { type: t_bool, comment: "Compressor 2 status. ON/OFF" }
        compressorStatus3    : { type: t_bool, comment: "Compressor 3 status. ON/OFF" }
        compressorStatus4    : { type: t_bool, comment: "Compressor 4 status. ON/OFF" }
        #Logical Area 9. Analog output status. Read only. Words 16bits
        fanCondenser1Output  : { type: COMMONLIB.QuantityValue, comment: "Fan condenser 1 analog output 1" }
        fanCondenser2Output  : { type: COMMONLIB.QuantityValue, comment: "Fan condenser 2 analog output 2" }
        #Logical Area 13. Alarm status. Read only. Words 16bits
        alarmStatus1         : { type: COMMONLIB.QuantityValue, comment: "Alarms bitwise register" }
        alarmStatus2         : { type: COMMONLIB.QuantityValue, comment: "Alarms bitwise register" }
        alarmStatus3         : { type: COMMONLIB.QuantityValue, comment: "Alarms bitwise register" }
        alarmStatus6         : { type: COMMONLIB.QuantityValue, comment: "Alarms bitwise register" }
        alarmStatus7         : { type: COMMONLIB.QuantityValue, comment: "Alarms bitwise register" }
        alarmStatus10        : { type: COMMONLIB.QuantityValue, comment: "Alarms bitwise register" }
        alarmStatus11        : { type: COMMONLIB.QuantityValue, comment: "Alarms bitwise register" }
        #Logical Area 15. Alarms per hour. Read only. Words 16bits
        alarmOilCompressor1  : { type: COMMONLIB.QuantityValue, comment: "Alarms per hour. Oil Compressor 1" }
        alarmOilCompressor2  : { type: COMMONLIB.QuantityValue, comment: "Alarms per hour. Oil Compressor 2" }
        alarmOilCompressor3  : { type: COMMONLIB.QuantityValue, comment: "Alarms per hour. Oil Compressor 3" }
        alarmOilCompressor4  : { type: COMMONLIB.QuantityValue, comment: "Alarms per hour. Oil Compressedor 4" }
        alarmFanOverload     : { type: COMMONLIB.QuantityValue, comment: "Alarms per hour. Fan overload" }
        alarmColdSideFlowSwitch   : { type: COMMONLIB.QuantityValue, comment: "Alarms per hour. ColdSideFlowSwitch" }
        alarmHotSideFlowSwitch    : { type: COMMONLIB.QuantityValue, comment: "Alarms per hour. HotSideFlowSwitch " }
        alarmCirc1LowTempPressDI  : { type: COMMONLIB.QuantityValue, comment: "Alarms per hour. Circ1LowTempPressDI" }
        alarmCirc2LowTempPressDI  : { type: COMMONLIB.QuantityValue, comment: "Alarms per hour. Circ1LowTempPressPB" }
        alarmCirc1LowTempPressPB  : { type: COMMONLIB.QuantityValue, comment: "Alarms per hour. Circ1LowTempPressPB" }
        alarmCirc2LowTempPressPB  : { type: COMMONLIB.QuantityValue, comment: "Alarms per hour. Circ2LowTempPressPB" }
    references:
        config           : { type: THISLIB.ServicesChillerControllerConfig, comment: "A small config only for Chiller controller" }
        bus              : { type: COMMONLIB.ModbusRTUBus, comment: "The shared Modbus RTU bus" }
    processes:
        updateConfigVariables     : { type: COMMONLIB.Process, comment: "Read the Config variables"}
        updateMeasureVariables    : { type: COMMONLIB.Process, comment: "Read the Measurement variables"}
        updateAlarmRegisters      : { type: COMMONLIB.Process, comment: "Read the Alarm registers"}
        writeSetpoint             : { type: COMMONLIB.ChangeSetpointProcess, comment: "Write the setpoint"}
        switchChillerON           : { type: COMMONLIB.Process, comment: "Switch ON the Chiller"}
        switchChillerOFF          : { type: COMMONLIB.Process, comment: "Switch OFF the Chiller"}
        resetUnitController       : { type: COMMONLIB.Process, comment: "Reset Unit controller of the Chiller"}
        resetAlarms               : { type: COMMONLIB.Process, comment: "Reset all activated alarms"}
    statuses:
        healthStatus                      : { type: COMMONLIB.HealthStatus        , comment: "Is the data valid and within range?" }
        alarmStatusWatertemperature       : { type: COMMONLIB.HiHiLoLoAlarmStatus , comment: "Alarm status about Water temperature"}
        alarmStatusWaterPumpSupervisor    : { type: COMMONLIB.HiHiLoLoAlarmStatus , comment: "Alarm status about WaterPump supervisor"}
    calls:
        alarmStatusWatertemperature:
            superState   : -> self.config.waterTankTemperatureMeasurement.enabled
            config       : -> self.config.waterTankTemperatureMeasurement.alarms
            value        : -> self.waterTankTemperature.value
        alarmStatusWaterPumpSupervisor:
            superState   : -> self.config.waterPumpSupervisorMeasurement.enabled           
            config       : -> self.config.waterPumpSupervisorMeasurement.alarms
            value        : -> self.waterPumpCurrentInput.value
        healthStatus:
            superState   : -> AND(self.config.waterTankTemperatureMeasurement.enabled,
                                  self.config.waterPumpSupervisorMeasurement.enabled)
            isGood       : -> NOT( OR(self.invalidData,
                                      self.alarmRelayOutput,
                                      self.statuses.alarmStatusWatertemperature.hiHi,
                                      self.statuses.alarmStatusWatertemperature.loLo,
                                      self.statuses.alarmStatusWaterPumpSupervisor.hiHi,
                                      self.statuses.alarmStatusWaterPumpSupervisor.loLo))
            hasWarning   : -> OR( NOT(self.chillerOn),
                                  self.flowSwitchStatus,
                                  self.statuses.alarmStatusWatertemperature.hi,
                                  self.statuses.alarmStatusWatertemperature.lo,
                                  self.statuses.alarmStatusWaterPumpSupervisor.hi,
                                  self.statuses.alarmStatusWaterPumpSupervisor.lo)
        updateConfigVariables:
            isEnabled    : -> self.isEnabled
        updateMeasureVariables:
            isEnabled    : -> self.isEnabled
        updateAlarmRegisters:
            isEnabled    : -> self.isEnabled
        writeSetpoint:
            isEnabled    : -> self.isEnabled
        switchChillerON:
            isEnabled    : -> self.isEnabled
        switchChillerOFF:
            isEnabled    : -> self.isEnabled
        resetAlarms:
            isEnabled    : -> self.isEnabled


########################################################################################################################
# ServicesChiller
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB,  "ServicesChiller",
    typeOf                          : [ THISLIB.ServicesParts.chiller ]
    variables:
        {}
    references:
        operatorStatus              : { type: COMMONLIB.OperatorStatus          , comment: "Shared operator status" }
        config                      : { type: THISLIB.ServicesChillerConfig        , comment: "The config" }
        airTemperature              : { type: THISLIB.ServicesMeteoMeasurement  , comment: "Air temperature" }
    statuses:
        healthStatus                : { type: COMMONLIB.HealthStatus      , comment: "Is the Chiller in healthy state (good) or not (bad)" }
        operatingStatus             : { type: COMMONLIB.OperatingStatus   , comment: "Is the Chiller being polled (auto) or not (manual)?" }
    parts:
        bus                         : { type: COMMONLIB.ModbusRTUBus         , comment: "The shared Modbus RTU bus" }
        chillerMainController       : { type: THISLIB.ServicesChillerController , comment: "The Chiller controller to control the water temperature" }
    processes:
        changeOperatingState        : { type: COMMONLIB.ChangeOperatingStateProcess   , comment: "Change the operating state (e.g. AUTO, MANUAL, ...)" }
    calls:
        operatingStatus:
            {}
        changeOperatingState:
            isEnabled               : -> self.operatorStatus.tech
        healthStatus:
            isGood                  : -> self.parts.chillerMainController.statuses.healthStatus.isGood
            hasWarning              : -> self.parts.chillerMainController.statuses.healthStatus.hasWarning
        bus:
            isEnabled               : -> AND(self.operatorStatus.tech, self.statuses.operatingStatus.manual)
        chillerMainController:
            isEnabled               : -> self.parts.bus.isEnabled
            config                  : -> self.config.chillerMainController
            bus                     : -> self.parts.bus

########################################################################################################################
# ServicesIO
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB, "ServicesIO",
    typeOf              : [ THISLIB.ServicesParts.io ]
    statuses:
        healthStatus    : { type: COMMONLIB.HealthStatus   , comment: "Is the I/O in a healthy state?"  }
    parts:
        coupler         : { type: COMMONLIB.EtherCatDevice , comment: "Coupler" }
        slot1           : { type: COMMONLIB.EtherCatDevice , comment: "Slot 1" }
        slot2           : { type: COMMONLIB.EtherCatDevice , comment: "Slot 2" }
        slot3           : { type: COMMONLIB.EtherCatDevice , comment: "Slot 3" }
        slot4           : { type: COMMONLIB.EtherCatDevice , comment: "Slot 4" }
    calls:
        coupler:
            id          : -> STRING("COUPLER") "id"
            typeId      : -> STRING("EK1100") "typeId"
        slot1:
            id          : -> STRING("TI-RS232") "id"
            typeId      : -> STRING("EL6001") "typeId"
        slot2:
            id          : -> STRING("METEO") "id"
            typeId      : -> STRING("EL6001") "typeId"
        slot3:
            id          : -> STRING("WESTS") "id"
            typeId      : -> STRING("EL6001") "typeId"
        slot4:
            id          : -> STRING("TI-PTP") "id"
            typeId      : -> STRING("EL6688") "typeId"
        healthStatus:
            isGood      : -> MTCS_SUMMARIZE_GOOD( self.parts.coupler,
                                                  self.parts.slot1,
                                                  self.parts.slot2,
                                                  self.parts.slot3,
                                                  self.parts.slot4 )


########################################################################################################################
# Write the model to file
########################################################################################################################

services_soft.WRITE "models/mtcs/services/software.jsonld"



