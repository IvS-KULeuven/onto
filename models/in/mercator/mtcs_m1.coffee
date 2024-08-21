########################################################################################################################
#                                                                                                                      #
# Model of the M1 software.                                                                                            #
#                                                                                                                      #
########################################################################################################################

require "ontoscript"

# metamodels
REQUIRE "models/import_all.coffee"

# models
REQUIRE "models/mtcs/common/software.coffee"
REQUIRE "models/mtcs/telemetry/software.coffee"

MODEL "http://www.mercator.iac.es/onto/models/mtcs/m1/software" : "m1_soft"

m1_soft.IMPORT mm_all
m1_soft.IMPORT common_soft
m1_soft.IMPORT telemetry_soft


########################################################################################################################
# Define the containing PLC library
########################################################################################################################

m1_soft.ADD MTCS_MAKE_LIB "mtcs_m1"

# make aliases (with scope of this file only)
COMMONLIB = common_soft.mtcs_common
THISLIB   = m1_soft.mtcs_m1
TELEMETRYLIB = telemetry_soft.mtcs_telemetry


########################################################################################################################
# M1Config
########################################################################################################################
MTCS_MAKE_CONFIG THISLIB, "M1Config",
    items:
        radialSupport                   : { comment: "Radial support" }
        axialSupport                    : { comment: "Axial support" }
        pneumaticSupplySensorFullScale  : { type: t_double                      , comment: "Sensor full scale range, in Bar" }
        pneumaticSupplyPressure         : { type: COMMONLIB.MeasurementConfig   , comment: "Pneumatic supply pressure config, in Bar" }
        inclinometerVoltage             : { type: COMMONLIB.MeasurementConfig   , comment: "Inclinometer voltage measuremennt config, in Volts" }


########################################################################################################################
# M1
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB,  "M1",
    variables:
        editableConfig                  : { type: THISLIB.M1Config              , comment: "Editable configuration of the M1 subsystem" }
    references:
        operatorStatus                  : { type: COMMONLIB.OperatorStatus      , comment: "Shared operator status"}
        tubeAngleMeasurement            : { type: TELEMETRYLIB.TelemetryAccelerometer , comment: "Accelerometer box angle measurement"}
    variables_read_only:
        config                          : { type: THISLIB.M1Config              , comment: "Active configuration of the M1 subsystem" }
        pneumaticSupplyPressure         : { type: COMMONLIB.PressureMeasurement , comment: "Pressure measurement of the pneumatic supply" }
    parts:
        inclinometer:
            comment                     : "Inclinometer"
            arguments:
                config                  : {}
            attributes:
                statuses:
                    attributes:
                        healthStatus    : { type: COMMONLIB.HealthStatus }
        radialSupport:
            comment                     : "Radial support"
            arguments:
                config                  : {}
                inclinometer            : {}
                operatorStatus          : {}
                operatingStatus         : {}
            attributes:
                statuses:
                    attributes:
                        healthStatus    : { type: COMMONLIB.HealthStatus }
                        busyStatus      : { type: COMMONLIB.BusyStatus }
        axialSupport:
            comment                     : "Axial support"
            arguments:
                config                  : {}
                inclinometer            : {}
                operatorStatus          : {}
                operatingStatus         : {}
                tubeAngle               : {}
            attributes:
                statuses:
                    attributes:
                        healthStatus    : { type: COMMONLIB.HealthStatus }
                        busyStatus      : { type: COMMONLIB.BusyStatus }
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
        # processes
        initialize:
            isEnabled                   : -> OR(self.statuses.initializationStatus.shutdown,
                                                self.statuses.initializationStatus.initializingFailed,
                                                self.statuses.initializationStatus.initialized)
        lock:
            isEnabled                   : -> AND(self.operatorStatus.tech, self.statuses.initializationStatus.initialized)
        unlock:
            isEnabled                   : -> AND(self.operatorStatus.tech, self.statuses.initializationStatus.locked)
        changeOperatingState:
            isEnabled                   : -> AND(self.statuses.busyStatus.idle, self.statuses.initializationStatus.initialized, self.operatorStatus.tech)
        # statuses
        healthStatus:
            isGood                      : -> MTCS_SUMMARIZE_GOOD(self.parts.radialSupport,
                                                                 self.parts.axialSupport,
                                                                 self.parts.io,
                                                                 self.parts.configManager)
            hasWarning                  : -> MTCS_SUMMARIZE_WARN(self.parts.radialSupport,
                                                                 self.parts.axialSupport,
                                                                 self.parts.io,
                                                                 self.parts.configManager)
        busyStatus:
            isBusy                      : -> OR(self.statuses.initializationStatus.initializing,
                                                self.parts.radialSupport.statuses.busyStatus.busy,
                                                self.parts.axialSupport.statuses.busyStatus.busy,
                                                self.parts.configManager.statuses.busyStatus.busy)
        operatingStatus:
            superState                  : -> self.statuses.initializationStatus.initialized
        # parts
        inclinometer:
            config                      : -> self.config.inclinometerVoltage
        configManager:
            isEnabled                   : -> self.operatorStatus.tech
        radialSupport:
            config                      : -> self.config.radialSupport
            inclinometer                : -> self.parts.inclinometer
            operatorStatus              : -> self.operatorStatus
            operatingStatus             : -> self.statuses.operatingStatus
        axialSupport:
            config                      : -> self.config.axialSupport
            inclinometer                : -> self.parts.inclinometer
            operatorStatus              : -> self.operatorStatus
            operatingStatus             : -> self.statuses.operatingStatus
            tubeAngle                   : -> self.tubeAngleMeasurement.averageYAngle
        # variables
        pneumaticSupplyPressure:
            config                      : -> self.config.pneumaticSupplyPressure
            conversionFactor        : -> DIV(
                                            self.config.pneumaticSupplySensorFullScale
                                            DOUBLE(Math.pow(2,15)) "resolution"
                                         )


########################################################################################################################
# M1Inclinometer
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB,  "M1Inclinometer",
    typeOf                  : [ THISLIB.M1Parts.inclinometer ]
    references:
        config              : { type: COMMONLIB.MeasurementConfig   , comment: "Reference to the config" }
    variables:
        voltageMeasurement  : { type: COMMONLIB.VoltageMeasurement  , comment: 'Measured voltage' }
    variables_read_only:
        actualElevation     : { type: COMMONLIB.AngularPosition     , comment: 'Elevation actual value' }
        averageElevation    : { type: COMMONLIB.AngularPosition     , comment: 'Elevation average value' }
    statuses:
        healthStatus        : { type: COMMONLIB.HealthStatus        , comment: 'Is the inclinometer elevation trustworthy?'}
    calls:
        healthStatus:
            isGood          : -> self.voltageMeasurement.statuses.healthStatus.isGood
            hasWarning      : -> self.voltageMeasurement.statuses.healthStatus.hasWarning
        voltageMeasurement:
            config          : -> self.config
            conversionFactor: -> DIV(
                                    DOUBLE(10.0) "factor"
                                    DOUBLE(Math.pow(2,15)) "resolution"
                                 )


########################################################################################################################
# M1RadialSupportConfig
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "M1RadialSupportConfig",
    typeOf: [ THISLIB.M1Config.radialSupport ]
    items:
        regulatorPressure:
            type: COMMONLIB.MeasurementConfig
            comment: "Regulator pressure config, in Bar"
        mirrorPressure:
            type: COMMONLIB.MeasurementConfig
            comment: "Regulator pressure config, in Bar"
        regulatorPressureSensorFullScale:
            type: t_double
            comment: "Sensor full scale range, in Bar"
        mirrorPressureSensorFullScale:
            type: t_double
            comment: "Sensor full scale range, in Bar"
        correctionCoefficient:
            type: t_double
            comment: "Correction coefficient for radial pressure"
        controllerLimitMax:
            type: t_double
            comment: "Maximum output of the controller, in Bar"
        controllerLimitMin:
            type: t_double
            comment: "Minimum output of the controller, in Bar"
        pressureRegulatorRange:
            type: t_double
            comment: "Pressure regulator range, in Bar"


########################################################################################################################
# M1RadialSupport
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB,  "M1RadialSupport",
    typeOf                          : [ THISLIB.M1Parts.radialSupport ]
    references:
        config                      : { type: THISLIB.M1RadialSupportConfig }
        inclinometer                : { type: THISLIB.M1Inclinometer, expand: false }
        operatorStatus              : { type: COMMONLIB.OperatorStatus }
        operatingStatus             : { type: COMMONLIB.OperatingStatus }
    variables_hidden:
        pressureSetpointOutput      : { type: t_int16                                   , comment: "Output value", address: "%Q*" }
    variables_read_only:
        # measured values
        regulatorPressure           : { type: COMMONLIB.PressureMeasurement             , comment: "Pressure measurement at the regulator" }
        mirrorPressure              : { type: COMMONLIB.PressureMeasurement             , comment: "Pressure measurement at the mirror" }
        # setpoints
        actualPressureSetpoint      : { type: COMMONLIB.Pressure                        , comment: "Pressure setpoint actually used" }
        autoPressureSetpoint        : { type: COMMONLIB.Pressure                        , comment: "Pressure setpoint in AUTO mode" }
        manualPressureSetpoint      : { type: COMMONLIB.Pressure                        , comment: "Pressure setpoint in MANUAL mode" }
    statuses:
        pressureSetpointStatus      : { type: COMMONLIB.OperatingStatus                 , comment: "Operating status of the radial pressure setpoint" }
        healthStatus                : { type: COMMONLIB.HealthStatus }
        busyStatus                  : { type: COMMONLIB.BusyStatus }
    parts:
        vacuumRelay                 : { type: COMMONLIB.SimpleRelay                     , comment: "Switch Radial vacuum ON to retract the radial pads during mirror manipulations." }
    processes:
        changePressureSetpoint      : { type: COMMONLIB.ChangeSetpointProcess           , comment: "Change a pressure setpoint, in Bar" }
        changePressureSetpointState : { type: COMMONLIB.ChangeOperatingStateProcess     , comment: "Change the operating state of the pressure setpoint only" }
    calls:
        # parts
        vacuumRelay:
            isEnabled               : -> AND(self.statuses.busyStatus.idle,
                                             self.operatingStatus.manual,
                                             self.operatorStatus.tech )
        # processes
        changePressureSetpoint:
            isEnabled               : -> self.parts.vacuumRelay.isEnabled # same as for vacuumRelay
        changePressureSetpointState:
            isEnabled               : -> self.parts.vacuumRelay.isEnabled # same as for vacuumRelay
        # statuses
        healthStatus:
            isGood                  : -> AND(
                                            MTCS_SUMMARIZE_GOOD( self.processes.changePressureSetpointState,
                                                                 self.processes.changePressureSetpoint,
                                                                 self.regulatorPressure ),
                                            OR(self.mirrorPressure.statuses.healthStatus.isGood, self.mirrorPressure.statuses.enabledStatus.disabled))
            hasWarning              : -> OR(
                                            MTCS_SUMMARIZE_WARN( self.processes.changePressureSetpointState,
                                                                 self.processes.changePressureSetpoint,
                                                                 self.regulatorPressure,
                                                                 self.mirrorPressure),
                                            self.parts.vacuumRelay.digitalOutput)
        busyStatus:
            isBusy                  : -> OR( self.processes.changePressureSetpointState.statuses.busyStatus.busy,
                                             self.processes.changePressureSetpoint.statuses.busyStatus.busy,
                                             self.parts.vacuumRelay.statuses.busyStatus.busy )
        # variables
        regulatorPressure:
            config                  : -> self.config.regulatorPressure
            conversionFactor        : -> DIV(
                                            self.config.regulatorPressureSensorFullScale
                                            DOUBLE(Math.pow(2,15)) "resolution"
                                         )
        mirrorPressure:
            config                  : -> self.config.mirrorPressure
            conversionFactor        : -> DIV(
                                            self.config.mirrorPressureSensorFullScale
                                            DOUBLE(Math.pow(2,15)) "resolution"
                                         )


########################################################################################################################
# M1AxialSupportConfig
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "M1AxialSupportConfig",
    typeOf: [ THISLIB.M1Config.axialSupport ] # THISLIB.M1Parts.radialSupport.config,
    items:
        regulatorPressure:
            type: COMMONLIB.MeasurementConfig
            comment: "Regulator pressure config, in Bar"
        mirrorPressure:
            type: COMMONLIB.MeasurementConfig
            comment: "Regulator pressure config, in Bar"
        mirrorSouthForce:
            type: COMMONLIB.MeasurementConfig
            comment: "Mirror south force config, in decaNewton"
        mirrorNorthEastForce:
            type: COMMONLIB.MeasurementConfig
            comment: "Mirror north east force config, in decaNewton"
        mirrorNorthWestForce:
            type: COMMONLIB.MeasurementConfig
            comment: "Mirror north west force config, in decaNewton"
        mirrorAverageForce:
            type: COMMONLIB.MeasurementConfig
            comment: "Mirror moving average force config, in decaNewton"
        regulatorPressureSensorFullScale:
            type: t_double
            comment: "Sensor full scale range, in Bar"
        mirrorPressureSensorFullScale:
            type: t_double
            comment: "Sensor full scale range, in Bar"
        correctionCoefficient:
            type: t_double
            comment: "Correction coefficient for axial pressure"
        controllerKp:
            type: t_double
            comment: "Proportional factor (gain) of the PI controller"
        controllerTn:
            type: t_double
            comment: "Integral time factor of the PI controller. in seconds"
        controllerLimitMax:
            type: t_double
            comment: "Maximum output of the controller, in Bar"
        controllerLimitMin:
            type: t_double
            comment: "Minimum output of the controller, in Bar"
        pressureRegulatorRange:
            type: t_double
            comment: "Pressure regulator range, in Bar"


########################################################################################################################
# M1AxialSupport
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB,  "M1AxialSupport",
    typeOf                          : [ THISLIB.M1Parts.axialSupport ]
    references:
        config                      : { type: THISLIB.M1AxialSupportConfig }
        inclinometer                : { type: THISLIB.M1Inclinometer, expand: false }
        operatorStatus              : { type: COMMONLIB.OperatorStatus }
        operatingStatus             : { type: COMMONLIB.OperatingStatus }
        tubeAngle                   : { type: COMMONLIB.AngularPosition }
    variables_hidden:
        pressureSetpointOutput      : { type: t_int16                                   , comment: "Output value", address: "%Q*" }
    variables_read_only:
        # measured values
        regulatorPressure           : { type: COMMONLIB.PressureMeasurement             , comment: "Pressure measurement at the regulator" }
        mirrorPressure              : { type: COMMONLIB.PressureMeasurement             , comment: "Pressure measurement at the mirror" }
        mirrorSouthForce            : { type: COMMONLIB.ForceMeasurement                , comment: "Force measurement South (SO)"}
        mirrorNorthEastForce        : { type: COMMONLIB.ForceMeasurement                , comment: "Force measurement North East (NE)"}
        mirrorNorthWestForce        : { type: COMMONLIB.ForceMeasurement                , comment: "Force measurement North West (NW)"}
        mirrorAverageForce          : { type: COMMONLIB.ForceMeasurement                , comment: "Average of SO, NE and NW"}
        # setpoints
        actualPressureSetpoint      : { type: COMMONLIB.Pressure                        , comment: "Pressure setpoint actually used" }
        autoPressureSetpoint        : { type: COMMONLIB.Pressure                        , comment: "Pressure setpoint in AUTO mode" }
        manualPressureSetpoint      : { type: COMMONLIB.Pressure                        , comment: "Pressure setpoint in MANUAL mode" }
        controllerSetpoint          : { type: COMMONLIB.Force                           , comment: "Force setpoint of the controller" }
    statuses:
        pressureSetpointStatus      : { type: COMMONLIB.OperatingStatus                 , comment: "Operating status of the radial pressure setpoint" }
        healthStatus                : { type: COMMONLIB.HealthStatus }
        busyStatus                  : { type: COMMONLIB.BusyStatus }
    processes:
        changePressureSetpoint      : { type: COMMONLIB.ChangeSetpointProcess           , comment: "Change a pressure setpoint, in Bar" }
        changePressureSetpointState : { type: COMMONLIB.ChangeOperatingStateProcess     , comment: "Change the operating state of the pressure setpoint only" }
    calls:
        # processes
        changePressureSetpoint:
            isEnabled               : -> AND(self.statuses.busyStatus.idle,
                                             self.operatingStatus.manual,
                                             self.operatorStatus.tech )
        changePressureSetpointState:
            isEnabled               : -> AND(self.statuses.busyStatus.idle,
                                             self.operatingStatus.manual,
                                             self.operatorStatus.tech )
        # statuses
        healthStatus:
            isGood                  : -> AND(
                                            MTCS_SUMMARIZE_GOOD(
                                                              self.processes.changePressureSetpointState,
                                                              self.processes.changePressureSetpoint,
                                                              self.regulatorPressure,
                                                              self.mirrorAverageForce )
                                            OR(self.mirrorPressure.statuses.healthStatus.isGood, self.mirrorPressure.statuses.enabledStatus.disabled))
            hasWarning              : -> MTCS_SUMMARIZE_WARN( self.processes.changePressureSetpointState,
                                                              self.processes.changePressureSetpoint,
                                                              self.regulatorPressure,
                                                              self.mirrorPressure,
                                                              self.mirrorAverageForce )
        busyStatus:
            isBusy                  : -> OR( self.processes.changePressureSetpointState.statuses.busyStatus.busy,
                                             self.processes.changePressureSetpoint.statuses.busyStatus.busy )
        # variables
        regulatorPressure:
            config                  : -> self.config.regulatorPressure
            conversionFactor        : -> DIV(
                                            self.config.regulatorPressureSensorFullScale
                                            DOUBLE(Math.pow(2,15)) "resolution"
                                         )
        mirrorPressure:
            config                  : -> self.config.mirrorPressure
            conversionFactor        : -> DIV(
                                            self.config.mirrorPressureSensorFullScale
                                            DOUBLE(Math.pow(2,15)) "resolution"
                                         )
        mirrorSouthForce:
            config                  : -> self.config.mirrorSouthForce
            conversionFactor        : -> DIV(
                                            MUL(
                                                DOUBLE(-200.0) "sensor_N_per_mV"
                                                DOUBLE(20.0) "inputRange_mV")
                                            DOUBLE(Math.pow(2,31)) "resolution"
                                         )

        mirrorNorthEastForce:
            config                  : -> self.config.mirrorNorthEastForce
            conversionFactor        : -> DIV(
                                            MUL(
                                                DOUBLE(-200.0) "sensor_N_per_mV"
                                                DOUBLE(20.0) "inputRange_mV")
                                            DOUBLE(Math.pow(2,31)) "resolution"
                                         )
        mirrorNorthWestForce:
            config                  : -> self.config.mirrorNorthWestForce
            conversionFactor        : -> DIV(
                                            MUL(
                                                DOUBLE(-200.0) "sensor_N_per_mV"
                                                DOUBLE(20.0) "inputRange_mV")
                                            DOUBLE(Math.pow(2,31)) "resolution"
                                         )
        mirrorAverageForce:
            config                  : -> self.config.mirrorAverageForce
            conversionFactor        : -> DIV(
                                            MUL(
                                                DOUBLE(-200.0) "sensor_N_per_mV"
                                                DOUBLE(20.0) "inputRange_mV")
                                            DOUBLE(Math.pow(2,31)) "resolution"
                                         )


########################################################################################################################
# M1M2IO
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB, "M1M2IO",
    typeOf              : [ THISLIB.M1Parts.io ]
    statuses:
        healthStatus    : { type: COMMONLIB.HealthStatus   , comment: "Is the I/O in a healthy state?"  }
    parts:
        COU             : { type: COMMONLIB.EtherCatDevice }
        AI1             : { type: COMMONLIB.EtherCatDevice }
        AI2             : { type: COMMONLIB.EtherCatDevice }
        AI3             : { type: COMMONLIB.EtherCatDevice }
        AO1             : { type: COMMONLIB.EtherCatDevice }
        DO1             : { type: COMMONLIB.EtherCatDevice }
        RES1            : { type: COMMONLIB.EtherCatDevice }
        RES2            : { type: COMMONLIB.EtherCatDevice }
        RES3            : { type: COMMONLIB.EtherCatDevice }
        PWR1            : { type: COMMONLIB.EtherCatDevice }
        SSI1            : { type: COMMONLIB.EtherCatDevice }
        AI4             : { type: COMMONLIB.EtherCatDevice }
        INC1            : { type: COMMONLIB.EtherCatDevice }
        P5V1            : { type: COMMONLIB.EtherCatDevice }
        DO2             : { type: COMMONLIB.EtherCatDevice }
        DO3             : { type: COMMONLIB.EtherCatDevice }
        RE1             : { type: COMMONLIB.EtherCatDevice }
    calls:
        COU:
            id          : -> STRING("M1M2:COU") "id"
            typeId      : -> STRING("EK1101") "typeId"
        AI1:
            id          : -> STRING("M1M2:AI1") "id"
            typeId      : -> STRING("EL3102") "typeId"
        AI2:
            id          : -> STRING("M1M2:AI2") "id"
            typeId      : -> STRING("EL3204") "typeId"
        AI3:
            id          : -> STRING("M1M2:AI3") "id"
            typeId      : -> STRING("EL3204") "typeId"
        AO1:
            id          : -> STRING("M1M2:AO1") "id"
            typeId      : -> STRING("EL4022") "typeId"
        DO1:
            id          : -> STRING("M1M2:DO1") "id"
            typeId      : -> STRING("EL2024") "typeId"
        RES1:
            id          : -> STRING("M1M2:RES1") "id"
            typeId      : -> STRING("EL3351") "typeId"
        RES2:
            id          : -> STRING("M1M2:RES2") "id"
            typeId      : -> STRING("EL3351") "typeId"
        RES3:
            id          : -> STRING("M1M2:RES3") "id"
            typeId      : -> STRING("EL3351") "typeId"
        PWR1:
            id          : -> STRING("M1M2:PWR1") "id"
            typeId      : -> STRING("EL9410") "typeId"
        SSI1:
            id          : -> STRING("M1M2:SSI1") "id"
            typeId      : -> STRING("EL5001") "typeId"
        AI4:
            id          : -> STRING("M1M2:AI4") "id"
            typeId      : -> STRING("EL3164") "typeId"
        INC1:
            id          : -> STRING("M1M2:INC1") "id"
            typeId      : -> STRING("ES5101") "typeId"
        P5V1:
            id          : -> STRING("M1M2:P5V1") "id"
            typeId      : -> STRING("EL9505") "typeId"
        DO2:
            id          : -> STRING("M1M2:DO2") "id"
            typeId      : -> STRING("EL2124") "typeId"
        DO3:
            id          : -> STRING("M1M2:DO3") "id"
            typeId      : -> STRING("EL2124") "typeId"
        RE1:
            id          : -> STRING("M1M2:RE1") "id"
            typeId      : -> STRING("EL2622") "typeId"
        healthStatus:
            isGood      : -> MTCS_SUMMARIZE_GOOD( self.parts.COU,
                                                  self.parts.AI1,
                                                  self.parts.AI2,
                                                  self.parts.AI3,
                                                  self.parts.AO1,
                                                  self.parts.DO1,
                                                  self.parts.RES1,
                                                  self.parts.RES2,
                                                  self.parts.RES3,
                                                  self.parts.PWR1,
                                                  self.parts.SSI1,
                                                  self.parts.AI4,
                                                  self.parts.INC1,
                                                  self.parts.P5V1,
                                                  self.parts.DO2,
                                                  self.parts.DO3,
                                                  self.parts.RE1 )


########################################################################################################################
# Write the model to file
########################################################################################################################

m1_soft.WRITE "models/mtcs/m1/software.jsonld"



