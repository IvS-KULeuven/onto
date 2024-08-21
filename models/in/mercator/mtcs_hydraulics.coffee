########################################################################################################################
#                                                                                                                      #
# Model of the hydraulics software.                                                                                    #
#                                                                                                                      #
########################################################################################################################

require "ontoscript"

# metamodels
REQUIRE "models/import_all.coffee"

# models
REQUIRE "models/mtcs/common/software.coffee"
REQUIRE "models/mtcs/safety/software.coffee"

MODEL "http://www.mercator.iac.es/onto/models/mtcs/hydraulics/software" : "hydraulics_soft"

hydraulics_soft.IMPORT mm_all
hydraulics_soft.IMPORT common_soft
hydraulics_soft.IMPORT safety_soft


########################################################################################################################
# Define the containing PLC library
########################################################################################################################

hydraulics_soft.ADD MTCS_MAKE_LIB "mtcs_hydraulics"

# make aliases (with scope of this file only)
COMMONLIB = common_soft.mtcs_common
SAFETYLIB = safety_soft.mtcs_safety
THISLIB   = hydraulics_soft.mtcs_hydraulics


########################################################################################################################
# HydraulicsPumpsStates
########################################################################################################################

MTCS_MAKE_ENUM THISLIB, "HydraulicsPumpsStates",
    items:
        [   "STOPPED",
            "POWERING_ON",
            "RESETTING_DRIVES",
            "COMMANDING_SAFETY",
            "BUILDING_UP_PRESSURE",
            "RUNNING",
            "STOPPING",
            "POWERING_OFF",
            "MANUAL",
            "ERROR"
        ]


########################################################################################################################
# HydraulicsConfig
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "HydraulicsConfig",
    items:
        top                            : { comment: "Top side settings" }
        bottom                         : { comment: "Bottom side settings" }
        controlCycleTime               : { type: t_double                      , comment: "Cycle time in seconds of the control loop (old system: 60.0)" }
        controlHysteresis              : { type: t_double                      , comment: "Don't change the frequency setpoint if the error is below this value (in Hz) (old system: 1.0)" }
        buildUpPressureTime            : { type: t_double                      , comment: "Time in seconds during startup, when the pumps must run at maxFrequency" }
        bearingTemperature             : { type: COMMONLIB.MeasurementConfig   , comment: "Oil temperature measured at the bearing" }
        stoppingTime                   : { type: t_double                      , comment: "Time in seconds during stopping" }
        pumpsPowerOnTIme               : { type: t_double                      , comment: "Time in seconds to wait while powering on" }
        pumpsPowerOffTIme              : { type: t_double                      , comment: "Time in seconds to wait while powering off" }


########################################################################################################################
# HydraulicsSideConfig
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "HydraulicsSideConfig",
    typeOf: [ THISLIB.HydraulicsConfig.top, THISLIB.HydraulicsConfig.bottom ]
    items:
        minFrequency                    : { type: t_double                      , comment: "Minimum allowed frequency in Hz (old system: 50.0 for both pumps)"}
        maxFrequency                    : { type: t_double                      , comment: "Maximum allowed frequency in Hz (old system: 100.0 for both pumps)"}
        pressureMeasurement             : { type: COMMONLIB.MeasurementConfig   , comment: "Pressure measurement config, in Bar" }
        pressureSensorFullScale         : { type: t_double                      , comment: "Sensor full scale range, in Bar" }
        frequencyMeasurement            : { type: COMMONLIB.MeasurementConfig   , comment: "Frequency measurement config, in Hertz" }
        frequencyMeasurementFullScale   : { type: t_double                      , comment: "Measurement full scale range, in Hertz" }
        conversionCoefficientA          : { type: t_double                      , comment: "Coefficient 'a' of formula: Frequency[Hz] = a * temp[Celsius]^2 + b * temp[Celsius] + c" }
        conversionCoefficientB          : { type: t_double                      , comment: "Coefficient 'b' of formula: Frequency[Hz] = a * temp[Celsius]^2 + b * temp[Celsius] + c" }
        conversionCoefficientC          : { type: t_double                      , comment: "Coefficient 'c' of formula: Frequency[Hz] = a * temp[Celsius]^2 + b * temp[Celsius] + c" }


########################################################################################################################
# Hydraulics
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB,  "Hydraulics",
    variables:
        editableConfig                  : { type: THISLIB.HydraulicsConfig          , comment: "Editable configuration of the Safety subsystem" }
        circulationFilterGOK            : { type: t_bool, address: "%I*"            , comment: "TRUE if there is no overpressure for circulation filter G" }
        circulationFilterDOK            : { type: t_bool, address: "%I*"            , comment: "TRUE if there is no overpressure for circulation filter D" }
        oilLevelTooHigh                 : { type: t_bool, address: "%I*"            , comment: "TRUE if the oil level is too high (--> problem!)" }
        pumpsState                      : { type: THISLIB.HydraulicsPumpsStates     , comment: "The current state of the pumps"}
        pumpsStatus                     : { type: t_string                          , comment: "Textual representation of the current pumps status"  }
    references:
        operatorStatus                  : { type: COMMONLIB.OperatorStatus          , comment: "Shared operator status" }
        safetyHydraulics                : { type: SAFETYLIB.SafetyHydraulics        , comment: "The hydraulics part of the safety system" }
        safetyIO                        : { type: SAFETYLIB.SafetyIO                , comment: "The I/O part of the safety system"       , expand: false}
    variables_read_only:
        config                          : { type: THISLIB.HydraulicsConfig          , comment: "Active configuration of the Hydraulics subsystem" }
        bearingTemperature              : { type: COMMONLIB.TemperatureMeasurement  , comment: "Temperature measured at the bearing" }
    parts:
        circulationPumpRelay            : { type: COMMONLIB.SimpleRelay             , comment: "Relay to power on/off the circulation pump" }
        pumpsPowerRelay                 : { type: COMMONLIB.SimpleRelay             , comment: "Relay to power on/off the pumps" }
        top:
            comment                     : "Top side"
            arguments:
                operatorStatus          : {}
                operatingStatus         : {}
                safetyHydraulics        : {}
                config                  : {}
                hydraulicsConfig        : {}
            attributes:
                statuses:
                    attributes:
                        healthStatus    : { type: COMMONLIB.HealthStatus }
                        busyStatus      : { type: COMMONLIB.BusyStatus   }
        bottom:
            comment                     : "Bottom side"
            arguments:
                operatorStatus          : {}
                operatingStatus         : {}
                safetyHydraulics        : {}
                config                  : {}
                hydraulicsConfig        : {}
            attributes:
                statuses:
                    attributes:
                        healthStatus    : { type: COMMONLIB.HealthStatus }
                        busyStatus      : { type: COMMONLIB.BusyStatus   }
        io:
            comment                     : "I/O modules"
            arguments:
                safetyIO                : { type: SAFETYLIB.SafetyHydraulics, expand: false }
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
        startUpPumps                    : { type: COMMONLIB.Process                       , comment: "Start up the pumps" }
        stopPumps                       : { type: COMMONLIB.Process                       , comment: "Stop the pumps" }
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
            isEnabled                   : -> AND(self.statuses.busyStatus.idle, self.operatorStatus.tech)
#        operatingStatus:
#            superState                  : -> self.statuses.initializationStatus.initialized
        healthStatus:
            isGood                      : -> AND(
                                                MTCS_SUMMARIZE_GOOD(self.parts.io,
                                                                    self.parts.configManager,
                                                                    self.processes.initialize,
                                                                    self.processes.lock,
                                                                    self.processes.unlock,
                                                                    self.processes.changeOperatingState,
                                                                    self.safetyHydraulics),
                                                self.circulationFilterGOK,
                                                self.circulationFilterDOK,
                                                NOT( self.oilLevelTooHigh ),
                                                NOT( EQ( self.pumpsState, THISLIB.HydraulicsPumpsStates.ERROR )) )
            hasWarning                  : -> OR(
                                                MTCS_SUMMARIZE_WARN(self.parts.io,
                                                                    self.parts.configManager,
                                                                    self.processes.initialize,
                                                                    self.processes.lock,
                                                                    self.processes.unlock,
                                                                    self.processes.changeOperatingState ),
                                                self.bearingTemperature.statuses.healthStatus.hasWarning,
                                                self.bearingTemperature.statuses.healthStatus.bad,
                                                EQ( self.pumpsState, THISLIB.HydraulicsPumpsStates.MANUAL ))
        busyStatus:
            isBusy                      : -> OR(self.statuses.initializationStatus.initializing,
                                                self.processes.initialize.statuses.busyStatus.busy,
                                                self.processes.lock.statuses.busyStatus.busy,
                                                self.processes.unlock.statuses.busyStatus.busy,
                                                self.processes.changeOperatingState.statuses.busyStatus.busy,
                                                self.processes.startUpPumps.statuses.busyStatus.busy,
                                                self.processes.stopPumps.statuses.busyStatus.busy)
        configManager:
            isEnabled                   : -> self.operatorStatus.tech
        bearingTemperature:
            config                      : -> self.config.bearingTemperature
        io:
            safetyIO                    : -> self.safetyIO
        top:
            operatorStatus              : -> self.operatorStatus
            operatingStatus             : -> self.statuses.operatingStatus
            safetyHydraulics            : -> self.safetyHydraulics
            config                      : -> self.config.top
            hydraulicsConfig            : -> self.config
        bottom:
            operatorStatus              : -> self.operatorStatus
            operatingStatus             : -> self.statuses.operatingStatus
            safetyHydraulics            : -> self.safetyHydraulics
            config                      : -> self.config.bottom
            hydraulicsConfig            : -> self.config
        startUpPumps:
            isEnabled                   : -> AND(
                                                self.statuses.initializationStatus.initialized,
                                                OR( EQ(self.pumpsState, THISLIB.HydraulicsPumpsStates.STOPPED),
                                                    EQ(self.pumpsState, THISLIB.HydraulicsPumpsStates.MANUAL),
                                                    EQ(self.pumpsState, THISLIB.HydraulicsPumpsStates.ERROR)))
        stopPumps:
            isEnabled                   : -> AND(
                                                self.statuses.initializationStatus.initialized,
                                                OR( EQ(self.pumpsState, THISLIB.HydraulicsPumpsStates.RUNNING),
                                                    EQ(self.pumpsState, THISLIB.HydraulicsPumpsStates.MANUAL),
                                                    EQ(self.pumpsState, THISLIB.HydraulicsPumpsStates.ERROR)))
        circulationPumpRelay:
            isEnabled                   : -> AND(self.statuses.busyStatus.idle, self.operatorStatus.tech, self.statuses.operatingStatus.manual)
        pumpsPowerRelay:
            isEnabled                   : -> AND(self.statuses.busyStatus.idle, self.operatorStatus.tech)


########################################################################################################################
# HydraulicsSide
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB, "HydraulicsSide",
    typeOf                      : [ THISLIB.HydraulicsParts.top, THISLIB.HydraulicsParts.bottom ]
    references:
        operatorStatus          : { type: COMMONLIB.OperatorStatus }
        operatingStatus         : { type: COMMONLIB.OperatingStatus }
        safetyHydraulics        : { type: SAFETYLIB.SafetyHydraulics, expand: false }
        config                  : { type: THISLIB.HydraulicsSideConfig }
        hydraulicsConfig        : { type: THISLIB.HydraulicsConfig }
    variables:
        entranceFilter1OK       : { type: t_bool, address: "%I*"        , comment: "TRUE if there is no overpressure for entrance filter 1" }
        entranceFilter2OK       : { type: t_bool, address: "%I*"        , comment: "TRUE if there is no overpressure for entrance filter 2" }
        entranceFilter3OK       : { type: t_bool, address: "%I*"        , comment: "TRUE if there is no overpressure for entrance filter 3" }
        entranceFilter4OK       : { type: t_bool, address: "%I*"        , comment: "TRUE if there is no overpressure for entrance filter 4" }
    variables_read_only:
        driveTripOK             : { type: t_bool                        , comment: "TRIP output of the drive, as copied from the safety system"}
        driveRelease            : { type: t_bool                        , comment: "Release output of the drive (ReglerFreigabe RFR), as copied from the safety system"}
        driveMinFrequency       : { type: t_bool                        , comment: "Minimum frequency output of the drive (QMIN), as copied from the safety system"}
        # measured values
        pressureMeasurement     : { type: COMMONLIB.PressureMeasurement , comment: "Pressure measurement" }
        frequencyMeasurement    : { type: COMMONLIB.FrequencyMeasurement, comment: "Frequency measurement" }
        # setpoints
        driveSetpoint           : { type: COMMONLIB.Frequency           , comment: "Frequency setpoint actually used" }
        driveSetpointSignal     : { type: t_int16, address: "%Q*"       , comment: "Raw signal value of the frequency setpoint" }
        resetDriveSignal        : { type: t_bool , address: "%Q*"       , comment: "Output to reset the drive" }
    statuses:
        healthStatus            : { type: COMMONLIB.HealthStatus        , comment: "Is the hydraulics side in a healthy state? Good=RUN, Bad=safe stopped"  }
        busyStatus              : { type: COMMONLIB.BusyStatus          , comment: "Is the hydraulics side busy?"  }
    processes:
        resetDrive                      : { type: COMMONLIB.Process                         , comment: "Reset the drive" }
        changeFrequencySetpoint         : { type: COMMONLIB.ChangeSetpointProcess           , comment: "Change the frequency setpoint, in Hertz" }
    calls:
        # statuses
        healthStatus:
            isGood                  : -> AND(
                                            MTCS_SUMMARIZE_GOOD( self.processes.resetDrive,
                                                                 self.processes.changeFrequencySetpoint),
                                            OR(self.pressureMeasurement.statuses.healthStatus.isGood, self.pressureMeasurement.statuses.enabledStatus.disabled),
                                            OR(self.frequencyMeasurement.statuses.healthStatus.isGood, self.frequencyMeasurement.statuses.enabledStatus.disabled),
                                            self.entranceFilter1OK,
                                            self.entranceFilter2OK,
                                            self.entranceFilter3OK,
                                            self.entranceFilter4OK,
                                            self.driveTripOK)
            hasWarning              : ->  MTCS_SUMMARIZE_WARN( self.processes.changeFrequencySetpoint,
                                                               self.pressureMeasurement,
                                                               self.frequencyMeasurement )
        busyStatus:
            isBusy                  : -> OR( self.processes.changeFrequencySetpoint.statuses.busyStatus.busy,
                                             self.processes.resetDrive.statuses.busyStatus.busy)
        pressureMeasurement:
            config                  : -> self.config.pressureMeasurement
            conversionFactor        : -> DIV(
                                            self.config.pressureSensorFullScale
                                            DOUBLE(Math.pow(2,15)) "resolution"
                                         )
        frequencyMeasurement:
            config                  : -> self.config.frequencyMeasurement
            conversionFactor        : -> DIV(
                                            self.config.frequencyMeasurementFullScale
                                            DOUBLE(Math.pow(2,15)) "resolution"
                                         )
        changeFrequencySetpoint:
            isEnabled               : -> AND(self.statuses.busyStatus.idle,
                                             self.operatingStatus.manual,
                                             self.operatorStatus.tech )
        resetDrive:
            isEnabled               : -> AND(self.statuses.busyStatus.idle, self.operatorStatus.tech )


########################################################################################################################
# HydraulicsIO
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB, "HydraulicsIO",
    typeOf              : [ THISLIB.HydraulicsParts.io ]
    references:
        safetyIO        : { type: SAFETYLIB.SafetyIO       , comment: "The safety I/O"  }
    statuses:
        healthStatus    : { type: COMMONLIB.HealthStatus   , comment: "Is the I/O in a healthy state?"  }
    parts:
        pumpsGroup:
            comment     : "PG: Pumps Group"
            attributes:
                statuses:
                    attributes:
                        healthStatus    : { type: COMMONLIB.HealthStatus }
    calls:
        healthStatus:
            isGood      : -> MTCS_SUMMARIZE_GOOD( self.safetyIO, self.parts.pumpsGroup )
            hasWarning  : -> MTCS_SUMMARIZE_WARN( self.safetyIO, self.parts.pumpsGroup )


########################################################################################################################
# HydraulicsPumpsGroupIO
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB, "HydraulicsPumpsGroupIO",
    typeOf              : [ THISLIB.HydraulicsIOParts.pumpsGroup ]
    statuses:
        healthStatus    : { type: COMMONLIB.HealthStatus   , comment: "Is the I/O in a healthy state?"  }
    parts:
        COU             : { type: COMMONLIB.EtherCatDevice , comment: "PG:COU (EK1101)" }
        DI1             : { type: COMMONLIB.EtherCatDevice , comment: "PG:DI1 (EL1008)" }
        SI1             : { type: COMMONLIB.EtherCatDevice , comment: "PG:SI1 (EL1904)" }
        SI2             : { type: COMMONLIB.EtherCatDevice , comment: "PG:SI2 (EL1904)" }
        SI3             : { type: COMMONLIB.EtherCatDevice , comment: "PG:SI3 (EL1904)" }
        DI2             : { type: COMMONLIB.EtherCatDevice , comment: "PG:DI2 (EL1008)" }
    calls:
        COU:
            id          : -> STRING("PG:COU") "id"
            typeId      : -> STRING("EK1101") "typeId"
        DI1:
            id          : -> STRING("PG:DI1") "id"
            typeId      : -> STRING("EL1008") "typeId"
        SI1:
            id          : -> STRING("PG:SI1") "id"
            typeId      : -> STRING("EL1904") "typeId"
        SI2:
            id          : -> STRING("PG:SI2") "id"
            typeId      : -> STRING("EL1904") "typeId"
        SI3:
            id          : -> STRING("PG:SI3") "id"
            typeId      : -> STRING("EL1904") "typeId"
        DI2:
            id          : -> STRING("PG:DI2") "id"
            typeId      : -> STRING("EL1008") "typeId"
        healthStatus:
            isGood       : -> MTCS_SUMMARIZE_GOOD( self.parts.COU,
                                                   self.parts.DI1,
                                                   self.parts.SI1,
                                                   self.parts.SI2,
                                                   self.parts.SI3,
                                                   self.parts.DI2 )
            hasWarning   : -> MTCS_SUMMARIZE_WARN( self.parts.COU,
                                                   self.parts.DI1,
                                                   self.parts.SI1,
                                                   self.parts.SI2,
                                                   self.parts.SI3,
                                                   self.parts.DI2 )

########################################################################################################################
# Write the model to file
########################################################################################################################

hydraulics_soft.WRITE "models/mtcs/hydraulics/software.jsonld"



