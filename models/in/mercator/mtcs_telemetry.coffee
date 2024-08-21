########################################################################################################################
#                                                                                                                      #
# Model of the telemetry software.                                                                                     #
#                                                                                                                      #
########################################################################################################################

require "ontoscript"

# metamodels
REQUIRE "models/import_all.coffee"

# models
REQUIRE "models/mtcs/common/software.coffee"

MODEL "http://www.mercator.iac.es/onto/models/mtcs/telemetry/software" : "telemetry_soft"

telemetry_soft.IMPORT mm_all
telemetry_soft.IMPORT common_soft


########################################################################################################################
# Define the containing PLC library
########################################################################################################################

telemetry_soft.ADD MTCS_MAKE_LIB "mtcs_telemetry"

# make aliases (with scope of this file only)
COMMONLIB = common_soft.mtcs_common
THISLIB   = telemetry_soft.mtcs_telemetry


########################################################################################################################
# TelemetryTemperaturesConfig
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "TelemetryTemperaturesConfig",
    items:
        m1:
            type: COMMONLIB.MeasurementConfig
            comment: "Temperature of M1"
            expand: false
        mirrorCell:
            type: COMMONLIB.MeasurementConfig
            comment: "Temperature of the mirror cell"
            expand: false
        m2:
            type: COMMONLIB.MeasurementConfig
            comment: "Temperature of M2"
            expand: false
        m2Electronics:
            type: COMMONLIB.MeasurementConfig
            comment: "Temperature of the M2 electricity"
            expand: false
        topTube:
            type: COMMONLIB.MeasurementConfig
            comment: "Temperature of the top of the tube"
            expand: false
        centreTube:
            type: COMMONLIB.MeasurementConfig
            comment: "Temperature of the centre of the tube"
            expand: false
        fork:
            type: COMMONLIB.MeasurementConfig
            comment: "Temperature of the fork"
            expand: false
        nasmythAir:
            type: COMMONLIB.MeasurementConfig
            comment: "Temperature of the air inside the Nasmyth focal station"
            expand: false
        rem:
            type: COMMONLIB.MeasurementConfig
            comment: "Temperature inside the REM cabinet"
            expand: false
        rpm:
            type: COMMONLIB.MeasurementConfig
            comment: "Temperature inside the RPM cabinet"
            expand: false
        hermesTelescopeAdapter:
            type: COMMONLIB.MeasurementConfig
            comment: "Temperature inside the HERMES telescope adapter"
            expand: false
        topAir:
            type: COMMONLIB.MeasurementConfig
            comment: "Temperature of the air at the top of the tube"
            expand: false
        insideTube:
            type: COMMONLIB.MeasurementConfig
            comment: "Temperature of the air inside the tube"
            expand: false


########################################################################################################################
# TelemetryRelativeHumiditiesConfig
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "TelemetryRelativeHumiditiesConfig",
    items:
        topAir:
            type: COMMONLIB.MeasurementConfig
            comment: "Relative humidity of the air at the top of the tube"
            expand: false
        insideTube:
            type: COMMONLIB.MeasurementConfig
            comment: "Relative humidity of the air inside the tube"
            expand: false


########################################################################################################################
# TelemetryDewpointsConfig
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "TelemetryDewpointsConfig",
    items:
        topAir:
            type: COMMONLIB.MeasurementConfig
            comment: "Dewpoint of the air at the top of the tube"
            expand: false
        insideTube:
            type: COMMONLIB.MeasurementConfig
            comment: "Dewpoint of the air inside the tube"
            expand: false


########################################################################################################################
# TelemetryAccelerometerConfig
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "TelemetryAccelerometerConfig",
    items:
        x:
            type: COMMONLIB.MeasurementConfig
            comment: "X angle"
            expand: false
        y:
            type: COMMONLIB.MeasurementConfig
            comment: "X angle"
            expand: false


########################################################################################################################
# TelemetryAccelerometersConfig
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "TelemetryAccelerometersConfig",
    items:
        tube:
            type: THISLIB.TelemetryAccelerometerConfig
            comment: "Accelerometer box at the tube"


########################################################################################################################
# TelemetryConfig
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "TelemetryConfig",
    items:
        temperatures:
            type: THISLIB.TelemetryTemperaturesConfig
            comment: "All temperatures"
            expand: false
        relativeHumidities:
            type: THISLIB.TelemetryRelativeHumiditiesConfig
            comment: "All relative humidities"
            expand: false
        dewpoints:
            type: THISLIB.TelemetryDewpointsConfig
            comment: "All dewpoints"
            expand: false
        accelerometers:
            type: THISLIB.TelemetryAccelerometersConfig
            comment: "All accelerometers"


########################################################################################################################
# TelemetryTemperatures
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB,  "TelemetryTemperatures",
    references:
        config : { type: THISLIB.TelemetryTemperaturesConfig, comment: "Configuration of the temperatures"}
    variables_read_only:
        m1:
            type: COMMONLIB.TemperatureMeasurement
            comment: "Temperature of M1"
        mirrorCell:
            type: COMMONLIB.TemperatureMeasurement
            comment: "Temperature of the mirror cell"
        m2:
            type: COMMONLIB.TemperatureMeasurement
            comment: "Temperature of M2"
        m2Electronics:
            type: COMMONLIB.TemperatureMeasurement
            comment: "Temperature of the M2 electricity"
        topTube:
            type: COMMONLIB.TemperatureMeasurement
            comment: "Temperature of the top of the tube"
        centreTube:
            type: COMMONLIB.TemperatureMeasurement
            comment: "Temperature of the centre of the tube"
        fork:
            type: COMMONLIB.TemperatureMeasurement
            comment: "Temperature of the fork"
        nasmythAir:
            type: COMMONLIB.TemperatureMeasurement
            comment: "Temperature of the air inside the Nasmyth focal station"
        rem:
            type: COMMONLIB.TemperatureMeasurement
            comment: "Temperature inside the REM cabinet"
        rpm:
            type: COMMONLIB.TemperatureMeasurement
            comment: "Temperature inside the RPM cabinet"
        hermesTelescopeAdapter:
            type: COMMONLIB.TemperatureMeasurement
            comment: "Temperature inside the HERMES telescope adapter"
        topAir:
            type: COMMONLIB.TemperatureMeasurement
            comment: "Temperature of the air at the top of the tube"
        insideTube:
            type: COMMONLIB.TemperatureMeasurement
            comment: "Temperature of the air inside the tube"
    statuses:
        healthStatus    : { type: COMMONLIB.HealthStatus          , comment: "Are all temperatures in a healthy state?" }
    calls:
        healthStatus:
            isGood      : -> MTCS_SUMMARIZE_GOOD_OR_DISABLED(
                                                 self.m1, self.mirrorCell, self.m2, self.m2Electronics, self.topTube, self.centreTube,
                                                 self.fork, self.nasmythAir, self.rem, self.rpm, self.hermesTelescopeAdapter,
                                                 self.topAir, self.insideTube)
            hasWarning  : -> MTCS_SUMMARIZE_WARN(self.m1, self.mirrorCell, self.m2, self.m2Electronics, self.topTube, self.centreTube,
                                                 self.fork, self.nasmythAir, self.rem, self.rpm, self.hermesTelescopeAdapter,
                                                 self.topAir, self.insideTube)
        m1:
            config: -> self.config.m1
        mirrorCell:
            config: -> self.config.mirrorCell
        m2:
            config: -> self.config.m2
        m2Electronics:
            config: -> self.config.m2Electronics
        topTube:
            config: -> self.config.topTube
        centreTube:
            config: -> self.config.centreTube
        fork:
            config: -> self.config.fork
        nasmythAir:
            config: -> self.config.nasmythAir
        rem:
            config: -> self.config.rem
        rpm:
            config: -> self.config.rpm
        hermesTelescopeAdapter:
            config: -> self.config.hermesTelescopeAdapter
        topAir:
            config: -> self.config.topAir
        insideTube:
            config: -> self.config.insideTube


########################################################################################################################
# TelemetryRelativeHumidities
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB,  "TelemetryRelativeHumidities",
    references:
        config : { type: THISLIB.TelemetryRelativeHumiditiesConfig, comment: "Configuration of the relative humidities"}
    variables_read_only:
        topAir:
            type: COMMONLIB.RelativeHumidityMeasurement
            comment: "Relative humidity of the air at the top of the tube"
        insideTube:
            type: COMMONLIB.RelativeHumidityMeasurement
            comment: "Relative humidity of the air inside the tube"
    statuses:
        healthStatus    : { type: COMMONLIB.HealthStatus          , comment: "Are all relative humidities in a healthy state?" }
    calls:
        healthStatus:
            isGood      : -> MTCS_SUMMARIZE_GOOD_OR_DISABLED(self.topAir, self.insideTube)
            hasWarning  : -> MTCS_SUMMARIZE_WARN(self.topAir, self.insideTube)
        topAir:
            config: -> self.config.topAir
        insideTube:
            config: -> self.config.insideTube


########################################################################################################################
# TelemetryDewpoint
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB,  "TelemetryDewpoint",
    references:
        config          : { type: COMMONLIB.MeasurementConfig         , comment: "Configuration" }
        temperature     : { type: COMMONLIB.TemperatureMeasurement      , comment: "Temperature to be taken into account" }
        relativeHumidity: { type: COMMONLIB.RelativeHumidityMeasurement , comment: "Relative humidity to be taken into account" }
    variables_read_only:
        actual          : { type: COMMONLIB.Temperature         , comment: "Actual dewpoint temperature"            }
        average         : { type: COMMONLIB.Temperature         , comment: "Average dewpoint temperature"           }
    statuses:
        enabledStatus   : { type: COMMONLIB.EnabledStatus       , comment: "Is the dewpoint being calculated?" }
        healthStatus    : { type: COMMONLIB.HealthStatus        , comment: "Is the depoint OK?" }
        alarmStatus     : { type: COMMONLIB.HiHiLoLoAlarmStatus , comment: "Alarm status"}
    calls:
        # variables are not explicitely called here, they're updated by custom written logic of the superclass
        # statuses
        enabledStatus:
            isEnabled       : -> self.config.enabled
        alarmStatus:
            superState      : -> self.statuses.enabledStatus.enabled
            config          : -> self.config.alarms
            value           : -> self.average.celsius.value
        healthStatus:
            superState      : -> self.statuses.enabledStatus.enabled
            isGood          : -> NOT( OR(self.temperature.error,
                                         self.relativeHumidity.statuses.healthStatus.bad,
                                         self.statuses.alarmStatus.hiHi,
                                         self.statuses.alarmStatus.loLo))
            hasWarning      : -> OR( self.statuses.alarmStatus.hi,
                                     self.statuses.alarmStatus.lo )


########################################################################################################################
# TelemetryDewpoints
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB,  "TelemetryDewpoints",
    references:
        config                  : { type: THISLIB.TelemetryDewpointsConfig      , comment: "Configuration of the dewpoints"}
        temperatures            : { type: THISLIB.TelemetryTemperatures         , comment: "Measured temperatures"}
        relativeHumidities      : { type: THISLIB.TelemetryRelativeHumidities   , comment: "Measured relative humidities"}
    variables_read_only:
        topAir                  : { type: THISLIB.TelemetryDewpoint             , comment: "Dewpoint of the air at the top of the tube" }
        insideTube              : { type: THISLIB.TelemetryDewpoint             , comment: "Dewpoint of the air inside the tube" }
    statuses:
        healthStatus            : { type: COMMONLIB.HealthStatus                , comment: "Are all dewpoints in a healthy state?" }
    calls:
        healthStatus:
            isGood              : -> MTCS_SUMMARIZE_GOOD_OR_DISABLED(self.topAir, self.insideTube)
            hasWarning          : -> MTCS_SUMMARIZE_WARN(self.topAir, self.insideTube)
        topAir:
            config              : -> self.config.topAir
            temperature         : -> self.temperatures.topAir
            relativeHumidity    : -> self.relativeHumidities.topAir
        insideTube:
            config              : -> self.config.insideTube
            temperature         : -> self.temperatures.insideTube
            relativeHumidity    : -> self.relativeHumidities.insideTube

########################################################################################################################
# TelemetryAccelerometer
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB, "TelemetryAccelerometer",
    variables_read_only:
        X1plus              : { type: COMMONLIB.GForceMeasurement       , comment: "+X1 (channel 1 of EP1816-3008)" , expand: true}
        Y1plus              : { type: COMMONLIB.GForceMeasurement       , comment: "+Y1 (channel 2 of EP1816-3008)" , expand: true }
        Z1minus             : { type: COMMONLIB.GForceMeasurement       , comment: "-Z1 (channel 3 of EP1816-3008)" , expand: true }
        Y2plus              : { type: COMMONLIB.GForceMeasurement       , comment: "+Y2 (channel 4 of EP1816-3008)" , expand: true }
        X2minus             : { type: COMMONLIB.GForceMeasurement       , comment: "-X2 (channel 5 of EP1816-3008)" , expand: true }
        Z2minus             : { type: COMMONLIB.GForceMeasurement       , comment: "-Z2 (channel 6 of EP1816-3008)" , expand: true }
        actualXAngle        : { type: COMMONLIB.AngularPosition         , comment: "Actual X angle" , expand: true }
        actualYAngle        : { type: COMMONLIB.AngularPosition         , comment: "Actual Y angle" , expand: true }
        averageXAngle       : { type: COMMONLIB.AngularPosition         , comment: "Average X angle" }
        averageYAngle       : { type: COMMONLIB.AngularPosition         , comment: "Average Y angle" }
    references:
        xConfig             : { type: COMMONLIB.MeasurementConfig       , comment: "Reference to the config of the X angle (alarms in degrees)" }
        yConfig             : { type: COMMONLIB.MeasurementConfig       , comment: "Reference to the config of the Y angle (alarms in degrees)" }
    statuses:
        xEnabledStatus  : { type: COMMONLIB.EnabledStatus           , comment: "Is the X angle being measured?" }
        yEnabledStatus  : { type: COMMONLIB.EnabledStatus           , comment: "Is the Y angle being measured?" }
        xHealthStatus   : { type: COMMONLIB.HealthStatus            , comment: "Is the X angle measurement OK?" }
        yHealthStatus   : { type: COMMONLIB.HealthStatus            , comment: "Is the Y angle measurement OK?" }
        xAlarmStatus    : { type: COMMONLIB.HiHiLoLoAlarmStatus     , comment: "Alarm status of the X angle"}
        yAlarmStatus    : { type: COMMONLIB.HiHiLoLoAlarmStatus     , comment: "Alarm status of the Y angle"}
    calls:
        xEnabledStatus:
            isEnabled    : -> self.xConfig.enabled
        yEnabledStatus:
            isEnabled    : -> self.yConfig.enabled
        xAlarmStatus:
            superState   : -> self.statuses.xEnabledStatus.enabled
            config       : -> self.xConfig.alarms
            value        : -> self.averageXAngle.degrees.value
        yAlarmStatus:
            superState   : -> self.statuses.yEnabledStatus.enabled
            config       : -> self.yConfig.alarms
            value        : -> self.averageYAngle.degrees.value
        xHealthStatus:
            superState   : -> self.statuses.xEnabledStatus.enabled
            isGood       : -> NOT( OR(self.statuses.xAlarmStatus.hiHi,
                                      self.statuses.xAlarmStatus.loLo))
            hasWarning   : -> OR( self.statuses.xAlarmStatus.hi,
                                  self.statuses.xAlarmStatus.lo)
        yHealthStatus:
            superState   : -> self.statuses.yEnabledStatus.enabled
            isGood       : -> NOT( OR(self.statuses.yAlarmStatus.hiHi,
                                      self.statuses.yAlarmStatus.loLo))
            hasWarning   : -> OR( self.statuses.yAlarmStatus.hi,
                                  self.statuses.yAlarmStatus.lo)

########################################################################################################################
# TelemetryAccelerometers
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB,  "TelemetryAccelerometers",
    references:
        config                  : { type: THISLIB.TelemetryAccelerometersConfig , comment: "Configuration of the accelerometers"}
    variables_read_only:
        tube                    : { type: THISLIB.TelemetryAccelerometer        , comment: "Accelerometer box at the tube" }
    statuses:
        healthStatus            : { type: COMMONLIB.HealthStatus                , comment: "Are all accelerometers in a healthy state?" }
    calls:
        healthStatus:
            isGood              : -> AND(self.tube.statuses.xHealthStatus.isGood, self.tube.statuses.yHealthStatus.isGood)
            hasWarning          : -> OR(self.tube.statuses.xHealthStatus.hasWarning, self.tube.statuses.yHealthStatus.hasWarning)
        tube:
            xConfig              : -> self.config.tube.x
            yConfig              : -> self.config.tube.y

########################################################################################################################
# Telemetry
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB,  "Telemetry",
    variables:
        editableConfig                  : { type: THISLIB.TelemetryConfig       , comment: "Editable configuration of the Telemetry subsystem" }
    references:
        operatorStatus                  : { type: COMMONLIB.OperatorStatus      , comment: "Shared operator status"}
    variables_read_only:
        config                          : { type: THISLIB.TelemetryConfig       , comment: "Active configuration of the Telemetry subsystem" }
    parts:
        temperatures:
            comment                     : "All temperature measurements"
            type                        : THISLIB.TelemetryTemperatures
        relativeHumidities:
            comment                     : "All relative humidity measurements"
            type                        : THISLIB.TelemetryRelativeHumidities
        dewpoints:
            comment                     : "All calculated dewpoints"
            type                        : THISLIB.TelemetryDewpoints
        accelerometers:
            comment                     : "Feedback from the accelerometers (vibrations + angles)"
            type                        : THISLIB.TelemetryAccelerometers
        io:
            comment                     : "I/O modules"
            attributes:
                statuses:
                    attributes:
                        healthStatus    : { type: COMMONLIB.HealthStatus }
        flatfieldLeds:
            comment                     : "I/O modules"
            attributes:
                isEnabled               : { type: t_bool }
                statuses:
                    attributes:
                        busyStatus      : { type: COMMONLIB.BusyStatus }
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
            isEnabled                   : -> AND(self.statuses.busyStatus.idle, self.statuses.initializationStatus.initialized)
        operatingStatus:
            superState                  : -> self.statuses.initializationStatus.initialized
        healthStatus:
            isGood              : -> MTCS_SUMMARIZE_GOOD(self.parts.temperatures,
                                                         self.parts.relativeHumidities,
                                                         self.parts.dewpoints,
                                                         self.parts.accelerometers,
                                                         self.parts.io,
                                                         self.parts.configManager )
            hasWarning          : -> MTCS_SUMMARIZE_WARN(self.parts.temperatures,
                                                         self.parts.relativeHumidities,
                                                         self.parts.dewpoints,
                                                         self.parts.accelerometers,
                                                         self.parts.io,
                                                         self.parts.configManager  )
        busyStatus:
            isBusy              : -> OR(self.statuses.initializationStatus.initializing,
                                        self.parts.flatfieldLeds.statuses.busyStatus.busy,
                                        self.parts.configManager.statuses.busyStatus.busy )
        configManager:
            isEnabled           : -> self.operatorStatus.tech
        temperatures:
            config              : -> self.config.temperatures
        relativeHumidities:
            config              : -> self.config.relativeHumidities
        dewpoints:
            config              : -> self.config.dewpoints
            temperatures        : -> self.parts.temperatures
            relativeHumidities  : -> self.parts.relativeHumidities
        accelerometers:
            config              : -> self.config.accelerometers
        flatfieldLeds:
            isEnabled           : -> AND( self.statuses.initializationStatus.initialized, self.statuses.operatingStatus.manual )


########################################################################################################################
# TelemetryFlatfieldLeds
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB,  "TelemetryFlatfieldLeds",
    typeOf              : [ THISLIB.TelemetryParts.flatfieldLeds ]
    variables_hidden:
        isEnabled           : { type: t_bool                            , comment: "Is control enabled?" }
    parts:
        output1     : { type: COMMONLIB.SimpleRelay, comment: "Output 1" }
        output2     : { type: COMMONLIB.SimpleRelay, comment: "Output 2" }
        output3     : { type: COMMONLIB.SimpleRelay, comment: "Output 3" }
        output4     : { type: COMMONLIB.SimpleRelay, comment: "Output 4" }
        output5     : { type: COMMONLIB.SimpleRelay, comment: "Output 5" }
        output6     : { type: COMMONLIB.SimpleRelay, comment: "Output 6" }
        output7     : { type: COMMONLIB.SimpleRelay, comment: "Output 7" }
        output8     : { type: COMMONLIB.SimpleRelay, comment: "Output 8" }
    statuses:
        busyStatus  : { type: COMMONLIB.BusyStatus }
    calls:
        output1:
            isEnabled : -> self.isEnabled
        output2:
            isEnabled : -> self.isEnabled
        output3:
            isEnabled : -> self.isEnabled
        output4:
            isEnabled : -> self.isEnabled
        output5:
            isEnabled : -> self.isEnabled
        output6:
            isEnabled : -> self.isEnabled
        output7:
            isEnabled : -> self.isEnabled
        output8:
            isEnabled : -> self.isEnabled
        busyStatus:
            isBusy  : -> OR( self.parts.output1.statuses.busyStatus.busy,
                             self.parts.output2.statuses.busyStatus.busy,
                             self.parts.output3.statuses.busyStatus.busy,
                             self.parts.output4.statuses.busyStatus.busy,
                             self.parts.output5.statuses.busyStatus.busy,
                             self.parts.output6.statuses.busyStatus.busy,
                             self.parts.output7.statuses.busyStatus.busy,
                             self.parts.output8.statuses.busyStatus.busy )



########################################################################################################################
# TelemetryIO
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB, "TelemetryIO",
    typeOf              : [ THISLIB.TelemetryParts.io ]
    statuses:
        healthStatus    : { type: COMMONLIB.HealthStatus   , comment: "Is the I/O in a healthy state?"  }
    parts:
        coupler         : { type: COMMONLIB.EtherCatDevice , comment: "Coupler" }
        slot5           : { type: COMMONLIB.EtherCatDevice , comment: "Slot 5" }
        slot6           : { type: COMMONLIB.EtherCatDevice , comment: "Slot 6" }
        slot7           : { type: COMMONLIB.EtherCatDevice , comment: "Slot 7" }
        slot8           : { type: COMMONLIB.EtherCatDevice , comment: "Slot 8" }
        slot9           : { type: COMMONLIB.EtherCatDevice , comment: "Slot 9" }
        slot10          : { type: COMMONLIB.EtherCatDevice , comment: "Slot 10" }
        slot11          : { type: COMMONLIB.EtherCatDevice , comment: "Slot 11" }
        slot12          : { type: COMMONLIB.EtherCatDevice , comment: "Slot 12" }
        slot13          : { type: COMMONLIB.EtherCatDevice , comment: "Slot 13" }
        tubeAccelerometers: { type: COMMONLIB.EtherCatDevice , comment: "Tube accelerometers" }
    calls:
        coupler:
            id          : -> STRING("COUPLER") "id"
            typeId      : -> STRING("EK1100") "typeId"
        slot5:
            id          : -> STRING("113A1") "id"
            typeId      : -> STRING("EL3202-0010") "typeId"
        slot6:
            id          : -> STRING("114A1") "id"
            typeId      : -> STRING("EL3202-0010") "typeId"
        slot7:
            id          : -> STRING("115A1") "id"
            typeId      : -> STRING("EL3202-0010") "typeId"
        slot8:
            id          : -> STRING("116A1") "id"
            typeId      : -> STRING("EL3202-0010") "typeId"
        slot9:
            id          : -> STRING("117A1") "id"
            typeId      : -> STRING("EL3202-0010") "typeId"
        slot10:
            id          : -> STRING("118A1") "id"
            typeId      : -> STRING("EL3202-0010") "typeId"
        slot11:
            id          : -> STRING("119A1") "id"
            typeId      : -> STRING("EL3202-0010") "typeId"
        slot12:
            id          : -> STRING("120A1") "id"
            typeId      : -> STRING("EL3024") "typeId"
        slot13:
            id          : -> STRING("121A1") "id"
            typeId      : -> STRING("EL2008") "typeId"
        tubeAccelerometers:
            id          : -> STRING("ACCTUB") "id"
            typeId      : -> STRING("EP1816-3008") "typeId"
        healthStatus:
            isGood      : -> MTCS_SUMMARIZE_GOOD( self.parts.coupler,
                                                  self.parts.slot5,
                                                  self.parts.slot6,
                                                  self.parts.slot7,
                                                  self.parts.slot8,
                                                  self.parts.slot9,
                                                  self.parts.slot10,
                                                  self.parts.slot11,
                                                  self.parts.slot12,
                                                  self.parts.slot13,
                                                  self.parts.tubeAccelerometers )


########################################################################################################################
# Write the model to file
########################################################################################################################

telemetry_soft.WRITE "models/mtcs/telemetry/software.jsonld"



