########################################################################################################################
#                                                                                                                      #
# Model of the M2 software.                                                                                            #
#                                                                                                                      #
########################################################################################################################

require "ontoscript"

# models
REQUIRE "models/mtcs/common/software.coffee"
REQUIRE "models/mtcs/m1/software.coffee"
REQUIRE "models/mtcs/m2/system.coffee"
REQUIRE "models/mtcs/m3/software.coffee"
REQUIRE "models/mtcs/telemetry/software.coffee"

MODEL "http://www.mercator.iac.es/onto/models/mtcs/m2/software" : "m2_soft"

m2_soft.IMPORT common_soft
m2_soft.IMPORT m1_soft
m2_soft.IMPORT m3_soft
m2_soft.IMPORT telemetry_soft


########################################################################################################################
# Define the containing PLC library
########################################################################################################################

m2_soft.ADD MTCS_MAKE_LIB "mtcs_m2"

# make aliases (with scope of this file only)
COMMONLIB    = common_soft.mtcs_common
THISLIB      = m2_soft.mtcs_m2
M1LIB        = m1_soft.mtcs_m1
M3LIB        = m3_soft.mtcs_m3
TELEMETRYLIB = telemetry_soft.mtcs_telemetry


########################################################################################################################
# M2Axes
########################################################################################################################

MTCS_MAKE_ENUM THISLIB, "M2Axes",
    items:
        [   "X",
            "Y",
            "Z",
            "TILTX",
            "TILTY" ]


########################################################################################################################
# M2Config
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "M2Config",
    items:
        x     : { comment: "The config of the X axis" }
        y     : { comment: "The config of the Y axis" }
        z     : { comment: "The config of the Z axis" }
        tiltX : { comment: "The config of the tiltX axis" }
        tiltY : { comment: "The config of the tiltY axis" }
        thermalFocus:
            comment: "The thermal focus coefficients for all focal stations"
        waitAfterPowerOn:
            comment: "Time (in seconds) to wait after the field electricity of M2 have been powered on"
            type:    t_double
        waitAfterPowerOff:
            comment: "Time (in seconds) to wait after the field electricity of M2 have been powered off"
            type:    t_double
        powerOffTimeout:
            comment: "If no new command is sent to M2 within this time (in seconds) after completion of the last command, M2 will be powered off automatically"
            type:    t_double
        fixedXPosition:
            comment: "The fixed X position in mm"
            type:    t_double
        fixedXPositionTolerance:
            comment: "If the X position is within fixedXPosition +/- this tolerance, there's no need to adjust it"
            type:    t_double
        fixedYPosition:
            comment: "The fixed Y position in mm"
            type:    t_double
        fixedYPositionTolerance:
            comment: "If the Y position is within fixedYPosition +/- this tolerance, there's no need to adjust it"
            type:    t_double
        fixedTiltXPosition:
            comment: "The fixed TiltX position in mm"
            type:    t_double
        fixedTiltXPositionTolerance:
            comment: "If the TiltX position is within fixedTiltXPosition +/- this tolerance, there's no need to adjust it"
            type:    t_double
        fixedTiltYPosition:
            comment: "The fixed TiltY position in mm"
            type:    t_double
        fixedTiltYPositionTolerance:
            comment: "If the TiltY position is within fixedTiltYPosition +/- this tolerance, there's no need to adjust it"
            type:    t_double
        verifyFixedPositinsOnThermalFocus:
            comment: "Each time a theremal focus is done, verify the fixed positions (and adjust them if they fall out of the tolerance)"
            type:    t_bool


########################################################################################################################
# M2ThermalFocusConfig
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "M2ThermalFocusStationConfig",
    items:
        offset                  : { type: t_double, comment: "focus = offset + topCoefficient*topTemperature + centreCoefficient*centreTemperature + mirrorCellCoefficient*mirrorCellTemperature" }
        topCoefficient          : { type: t_double, comment: "focus = offset + topCoefficient*topTemperature + centreCoefficient*centreTemperature + mirrorCellCoefficient*mirrorCellTemperature" }
        centreCoefficient       : { type: t_double, comment: "focus = offset + topCoefficient*topTemperature + centreCoefficient*centreTemperature + mirrorCellCoefficient*mirrorCellTemperature" }
        mirrorCellCoefficient   : { type: t_double, comment: "focus = offset + topCoefficient*topTemperature + centreCoefficient*centreTemperature + mirrorCellCoefficient*mirrorCellTemperature" }


########################################################################################################################
# M2ThermalFocusConfig
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "M2ThermalFocusConfig",
    typeOf: THISLIB.M2Config.thermalFocus
    items:
        cassegrain : { type: THISLIB.M2ThermalFocusStationConfig, comment: "Cassegrain thermal focus config"}
        nasmythA   : { type: THISLIB.M2ThermalFocusStationConfig, comment: "Nasmyth A thermal focus config"}
        nasmythB   : { type: THISLIB.M2ThermalFocusStationConfig, comment: "Nasmyth B thermal focus config"}
        nasmythC   : { type: THISLIB.M2ThermalFocusStationConfig, comment: "Nasmyth C thermal focus config"}
        nasmythD   : { type: THISLIB.M2ThermalFocusStationConfig, comment: "Nasmyth D thermal focus config"}
        other0     : { type: THISLIB.M2ThermalFocusStationConfig, comment: "Other 0 thermal focus config"}
        other1     : { type: THISLIB.M2ThermalFocusStationConfig, comment: "Other 1 thermal focus config"}
        other2     : { type: THISLIB.M2ThermalFocusStationConfig, comment: "Other 2 thermal focus config"}
        other3     : { type: THISLIB.M2ThermalFocusStationConfig, comment: "Other 3 thermal focus config"}
        other4     : { type: THISLIB.M2ThermalFocusStationConfig, comment: "Other 4 thermal focus config"}


########################################################################################################################
# M2SelectAxisProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "M2SelectAxisProcess",
    extends: COMMONLIB.BaseProcess
    arguments:
        axis  : { type: THISLIB.M2Axes, comment: "The axis to select" }


########################################################################################################################
# M2MoveProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "M2MoveProcess",
    extends: COMMONLIB.BaseProcess
    arguments:
        axis  : { type: THISLIB.M2Axes, comment: "The axis to move" }
        position : { type: t_double, comment: "Move to a certain position in millimeters" }


########################################################################################################################
# M2MoveStepsProcess
########################################################################################################################

MTCS_MAKE_PROCESS THISLIB, "M2MoveStepsProcess",
    extends: COMMONLIB.BaseProcess
    arguments:
        axis  : { type: THISLIB.M2Axes  , comment: "The axis to move" }
        steps : { type: t_uint32        , comment: "Move a certain number of steps" }
        cw    : { type: t_bool          , comment: 'True if the axis should be moved in CW (negative) direction'}
        fast  : { type: t_bool          , comment: 'True if the axis should be moved fast (only used in case of Z-axis!)'}


########################################################################################################################
# M2DoThermalFocusForStationPosition
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "M2DoThermalFocusForStationPosition",
    extends: COMMONLIB.BaseProcess
    arguments:
        station : { type: M3LIB.M3PositionIDs, comment: "The station numerical ID for which the thermal focus should be executed" }


########################################################################################################################
# M2DoThermalFocusForStationName
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "M2DoThermalFocusForStationName",
    extends: COMMONLIB.BaseProcess
    arguments:
        station : { type: t_string, comment: "The configured station name, for which the thermal focus should be executed" }


########################################################################################################################
# M2
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB,  "M2",
    variables:
        editableConfig                  : { type: THISLIB.M2Config                      , comment: "Editable configuration of the M2 subsystem" }
    references:
        operatorStatus                  : { type: COMMONLIB.OperatorStatus              , comment: "Shared operator status" }
        io                              : { type: M1LIB.M1M2IO                          , comment: "Shared I/O with M1" }
        actualFocalStation              : { type: M3LIB.M3PositionIDs                   , comment: "Actual M3 focal station, needed for thermal focus" }
        m3KnownPositionsConfig          : { type: M3LIB.M3KnownPositionsConfig          , comment: "Config of M3 with all info (e.g. names) of focal stations" }
        temperatures                    : { type: TELEMETRYLIB.TelemetryTemperatures    , comment: "Telemetry temperatures"}
    variables_read_only:
        config                          : { type: THISLIB.M2Config                      , comment: "Active configuration of the M2 subsystem" }
        selectedAxis                    : { type: THISLIB.M2Axes                        , comment: "The axis which is currently selected by the multiplexer" }
        selectedAxisName                : { type: t_string                              , comment: "The name of the axis which is currently selected by the multiplexer" }
        powerOffTimer                   : { type: t_double                              , comment: "Number of seconds before the power of the M2 field electricity will be powered off automatically"}
        thermalFocusCassegrain          : { type: COMMONLIB.LinearPosition              , comment: "Thermal focus position for cassegrain" }
        thermalFocusNasmythA            : { type: COMMONLIB.LinearPosition              , comment: "Thermal focus position for nasmyth A" }
        thermalFocusNasmythB            : { type: COMMONLIB.LinearPosition              , comment: "Thermal focus position for nasmyth B" }
        thermalFocusNasmythC            : { type: COMMONLIB.LinearPosition              , comment: "Thermal focus position for nasmyth C" }
        thermalFocusNasmythD            : { type: COMMONLIB.LinearPosition              , comment: "Thermal focus position for nasmyth D" }
        thermalFocusActualFocalStation  : { type: COMMONLIB.LinearPosition              , comment: "Thermal focus position for nasmyth D" }
    parts:
        powerRelay:
            comment                     : "Relay to power on/off the power of the M2 field electricity"
            type                        : COMMONLIB.SimpleRelay
        heater:
            comment                     : "Digital output to power on/off the heater of M2"
            type                        : COMMONLIB.SimpleRelay
        x:
            comment                     : "The X axis"
            arguments:
                powered                 : {}
                config                  : {}
                axisConfig              : {}
            attributes:
                statuses:
                    attributes:
                        healthStatus    : { type: COMMONLIB.HealthStatus }
        y:
            comment                     : "The Y axis"
            arguments:
                powered                 : {}
                config                  : {}
                axisConfig              : {}
            attributes:
                statuses:
                    attributes:
                        healthStatus    : { type: COMMONLIB.HealthStatus }
        z:
            comment                     : "The Z axis"
            arguments:
                powered                 : {}
                config                  : {}
                axisConfig              : {}
                isEnabled               : { type: t_bool }
            attributes:
                statuses:
                    attributes:
                        healthStatus    : { type: COMMONLIB.HealthStatus }
        tiltX:
            comment                     : "The TiltX axis"
            arguments:
                powered                 : {}
                config                  : {}
                axisConfig              : {}
            attributes:
                statuses:
                    attributes:
                        healthStatus    : { type: COMMONLIB.HealthStatus }
        tiltY:
            comment                     : "The TiltY axis"
            arguments:
                powered                 : {}
                config                  : {}
                axisConfig              : {}
            attributes:
                statuses:
                    attributes:
                        healthStatus    : { type: COMMONLIB.HealthStatus }
        multiplexer:
            comment                     : "The multiplexer inputs and outputs"
            arguments:
                isEnabled               : { type: t_bool }
                powered                 : {}
            attributes:
                statuses:
                    attributes:
                        healthStatus    : { type: COMMONLIB.HealthStatus }
                        busyStatus      : { type: COMMONLIB.BusyStatus }
        configManager:
            comment                     : "The config manager (to load/save/activate configuration data)"
            type                        : COMMONLIB.ConfigManager
        moveStepsProcedure:
            comment                     : "The move steps procedure"
            arguments:
                powerOn                 : {}
                x                       : {}
                y                       : {}
                z                       : {}
                tiltX                   : {}
                tiltY                   : {}
                multiplexer             : {}
                config                  : {}
            attributes:
                statuses:
                    attributes:
                        healthStatus    : { type: COMMONLIB.HealthStatus }
                        busyStatus      : { type: COMMONLIB.BusyStatus   }
        movePositionProcedure:
            comment                     : "The move to a certain position procedure"
            arguments:
                powerOn                 : {}
                x                       : {}
                y                       : {}
                z                       : {}
                tiltX                   : {}
                tiltY                   : {}
                multiplexer             : {}
                moveStepsProcedure      : {}
                config                  : {}
            attributes:
                statuses:
                    attributes:
                        healthStatus    : { type: COMMONLIB.HealthStatus }
                        busyStatus      : { type: COMMONLIB.BusyStatus   }
    statuses:
        initializationStatus            : { type: COMMONLIB.InitializationStatus }
        poweredStatus                   : { type: COMMONLIB.PoweredStatus }
        healthStatus                    : { type: COMMONLIB.HealthStatus }
        busyStatus                      : { type: COMMONLIB.BusyStatus }
        operatingStatus                 : { type: COMMONLIB.OperatingStatus }
    processes:
        initialize                      : { type: COMMONLIB.Process                     , comment: "Start initializing" }
        lock                            : { type: COMMONLIB.Process                     , comment: "Lock the system" }
        unlock                          : { type: COMMONLIB.Process                     , comment: "Unlock the system" }
        changeOperatingState            : { type: COMMONLIB.ChangeOperatingStateProcess , comment: "Change the operating state (e.g. AUTO, MANUAL, ...)" }
        moveAbsolute                    : { type: THISLIB.M2MoveProcess                 , comment: "Move the position of one axis in an absolute way" }
        moveRelative                    : { type: THISLIB.M2MoveProcess                 , comment: "Move the position of one axis relative to the current position" }
        moveSteps                       : { type: THISLIB.M2MoveStepsProcess            , comment: "Move the position of one axis by providing a number of steps (i.e. motor pulses)" }
        doThermalFocus                  : { type: COMMONLIB.Process                     , comment: "Do a thermal focus for the currently active focus" }
        doThermalFocusForStationName    : { type: THISLIB.M2DoThermalFocusForStationName, comment: "Do a thermal focus for a specified focal station (based on the configured name of the station)" }
        doThermalFocusForStationPosition: { type: THISLIB.M2DoThermalFocusForStationPosition, comment: "Do a thermal focus for a specified focal station (based on the station numerical ID)" }
        verifyFixedPositions            : { type: COMMONLIB.Process                     , comment: "Verify (and adjust if necessary) the fixed positions of X, Y, TiltX, and TiltY" }
        powerOn                         : { type: COMMONLIB.Process                     , comment: "Power on the M2 electricity" }
        powerOff                        : { type: COMMONLIB.Process                     , comment: "Power off the M2 electricity" }
        abort                           : { type: COMMONLIB.Process                     , comment: "Abort the move procedure" }
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
        moveAbsolute:
            isEnabled                   : -> AND(self.statuses.initializationStatus.initialized, self.statuses.busyStatus.idle)
        moveRelative:
            isEnabled                   : -> self.processes.moveAbsolute.isEnabled
        moveSteps:
            isEnabled                   : -> AND(self.statuses.initializationStatus.initialized, self.operatorStatus.tech)
        doThermalFocus:
            isEnabled                   : -> AND( self.processes.moveAbsolute.isEnabled, NOT( EQ(self.actualFocalStation, M3LIB.M3PositionIDs.UNKNOWN) ) )
        doThermalFocusForStationPosition:
            isEnabled                   : -> self.processes.moveAbsolute.isEnabled
        verifyFixedPositions:
            isEnabled                   : -> self.processes.moveAbsolute.isEnabled
        doThermalFocusForStationName:
            isEnabled                   : -> self.processes.moveAbsolute.isEnabled
        abort:
            isEnabled                   : -> OR( self.parts.moveStepsProcedure.statuses.busyStatus.busy,
                                                 self.parts.movePositionProcedure.statuses.busyStatus.busy)
        powerOn:
            isEnabled                   : -> AND(self.statuses.busyStatus.idle, self.statuses.initializationStatus.initialized)
        powerOff:
            isEnabled                   : -> AND(self.statuses.busyStatus.idle, self.statuses.initializationStatus.initialized)
        # statuses
        healthStatus:
            isGood                      : -> AND(
                                                OR(
                                                    MTCS_SUMMARIZE_GOOD(
                                                            self.parts.x,
                                                            self.parts.y,
                                                            self.parts.z,
                                                            self.parts.tiltX,
                                                            self.parts.tiltY,
                                                            self.parts.multiplexer
                                                    ),
                                                    self.statuses.poweredStatus.disabled
                                                ),
                                                MTCS_SUMMARIZE_GOOD(self.io, self.temperatures, self.parts.configManager)
                                            )
            hasWarning                  : -> OR(
                                                AND(
                                                    MTCS_SUMMARIZE_WARN(
                                                            self.parts.x,
                                                            self.parts.y,
                                                            self.parts.z,
                                                            self.parts.tiltX,
                                                            self.parts.tiltY,
                                                            self.parts.multiplexer
                                                    ),
                                                    self.statuses.poweredStatus.enabled
                                                ),
                                                MTCS_SUMMARIZE_WARN(self.io, self.temperatures, self.parts.configManager)
                                             )
        busyStatus:
            isBusy                      : -> OR(self.statuses.initializationStatus.initializing,
                                                self.parts.multiplexer.statuses.busyStatus.busy,
                                                self.parts.configManager.statuses.busyStatus.busy,
                                                self.processes.abort.statuses.busyStatus.busy,
                                                self.processes.powerOn.statuses.busyStatus.busy,
                                                self.processes.powerOff.statuses.busyStatus.busy,
                                                self.processes.doThermalFocus.statuses.busyStatus.busy,
                                                self.processes.doThermalFocusForStationName.statuses.busyStatus.busy,
                                                self.processes.doThermalFocusForStationPosition.statuses.busyStatus.busy,
                                                self.processes.verifyFixedPositions.statuses.busyStatus.busy,
                                                self.processes.moveSteps.statuses.busyStatus.busy,
                                                self.processes.moveAbsolute.statuses.busyStatus.busy,
                                                self.processes.moveRelative.statuses.busyStatus.busy)
        operatingStatus:
            superState                  : -> self.statuses.initializationStatus.initialized
        poweredStatus:
            isEnabled                   : -> AND(self.parts.powerRelay.digitalOutput,
                                                 self.processes.powerOn.statuses.busyStatus.idle,
                                                 self.processes.powerOff.statuses.busyStatus.idle)
        # parts
        x:
            powered                     : -> self.statuses.poweredStatus.enabled
            config                      : -> self.config
            axisConfig                  : -> self.config.x
        y:
            powered                     : -> self.statuses.poweredStatus.enabled
            config                      : -> self.config
            axisConfig                  : -> self.config.y
        z:
            powered                     : -> self.statuses.poweredStatus.enabled
            config                      : -> self.config
            axisConfig                  : -> self.config.z
            isEnabled                   : -> self.operatorStatus.tech
        tiltX:
            powered                     : -> self.statuses.poweredStatus.enabled
            config                      : -> self.config
            axisConfig                  : -> self.config.tiltX
        tiltY:
            powered                     : -> self.statuses.poweredStatus.enabled
            config                      : -> self.config
            axisConfig                  : -> self.config.tiltY
        multiplexer:
            isEnabled                   : -> self.operatorStatus.tech
            powered                     : -> self.statuses.poweredStatus.enabled
        powerRelay:
            isEnabled                   : -> self.operatorStatus.tech
        heater:
            isEnabled                   : -> self.operatorStatus.tech
        configManager:
            isEnabled                   : -> self.operatorStatus.tech
        moveStepsProcedure:
            powerOn                     : -> self.processes.powerOn
            x                           : -> self.parts.x
            y                           : -> self.parts.y
            z                           : -> self.parts.z
            tiltX                       : -> self.parts.tiltX
            tiltY                       : -> self.parts.tiltY
            multiplexer                 : -> self.parts.multiplexer
            config                      : -> self.config
        movePositionProcedure:
            powerOn                     : -> self.processes.powerOn
            x                           : -> self.parts.x
            y                           : -> self.parts.y
            z                           : -> self.parts.z
            tiltX                       : -> self.parts.tiltX
            tiltY                       : -> self.parts.tiltY
            multiplexer                 : -> self.parts.multiplexer
            moveStepsProcedure          : -> self.parts.moveStepsProcedure
            config                      : -> self.config


########################################################################################################################
# M2AxisGeneralConfig
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "M2AxisGeneralConfig",
    items:
        measurement:
            comment: "Configure the position measurement"
            type:    COMMONLIB.MeasurementConfig
        stoppingSteps:
            comment: "The number of steps to be expected between the time at which the PLC realizes that the brake release signal must be set, and the time that the axis is fully stopped (for Z axis: at low speed)"
            type:    t_uint32
        finalSenseCW:
            comment: "TRUE if the motor final sense must be ClockWise (- motion on the screw), FALSE if the motor final sense must be CounterClockWise (+ motion on the screw) (for Z axis: at low speed)"
            type:    t_bool
        closePosition:
            comment: "The number of steps between the Close position (C) and final position (F)"
            type:    t_uint32
        antiBacklashPosition:
            comment: "The number of steps between the Anti-backlash position (A) and final position (F)"
            type:    t_uint32
        waitAfterMove:
            comment: "Time (in seconds) to wait after the axis has been moved"
            type:    t_double
        timeout:
            comment: "Timeout for a movement, in seconds (for Z-axis: at low speed)"
            type:    t_double
        verifyPositionOnInitialization:
            comment: "Verify the fixed positions (and adjust them if they fall out of the tolerance) during the Initialization procedure"
            type:    t_bool


########################################################################################################################
# M2PotentiometerConfig
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "M2ZAxisConfig",
    typeOf: [ THISLIB.M2Config.z ]
    items:
        general:
            comment: "Settings which are general for all axes"
            type: THISLIB.M2AxisGeneralConfig
        highSpeedStoppingSteps:
            comment: "The number of steps to be expected between the time at which the PLC realizes that the brake release signal must be set, and the time that the axis is fully stopped at high speed"
            type:    t_uint32
#        highSpeedFinalMove:
#            comment: "The number of steps which should be carried out at minimum to counter-act the backlash in the system during the final move at HIGH speed"
#            type: t_uint32
#        encoderOffset:
#            comment: "The number of encoder ticks when the Z position is zero micrometer"
#            type: t_int32
        highSpeedTimeout:
            comment: "Timeout for a fast movement of the Z axis (in seconds)"
            type:    t_double


########################################################################################################################
# M2PotentiometerAxisConfig
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "M2PotentiometerAxisConfig",
    typeOf: [ THISLIB.M2Config.x, THISLIB.M2Config.y, THISLIB.M2Config.tiltX, THISLIB.M2Config.tiltY ]
    items:
        general:
            comment: "Settings which are general for all axes"
            type: THISLIB.M2AxisGeneralConfig
        voltageCorrectionFactor:
            comment: "Position = voltage * correctionFactor * voltageToPosition"
            type: t_double


########################################################################################################################
# M2ConstantsZ
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "M2ConstantsZ",
    comment: "Some mechanical constants for the Z axis"
    items:
        MOT_TO_RED_RATIO    : { type: t_double , copyFrom: m2_sys.z.parts.motToRed.ratio.quantityValue  , comment: "Motor reduction ratio" }
        RED_TO_SCREW_RATIO  : { type: t_double , copyFrom: m2_sys.z.parts.redToScrew.ratio.quantityValue, comment: "Transmission ratio between the motor reduction and the screw" }
        SCREW_TO_ENC_RATIO  : { type: t_double , copyFrom: m2_sys.z.parts.screwToEnc.ratio.quantityValue, comment: "Transmission ratio between the encoder and the screw" }
        MIN_POSITION        : { type: t_double , copyFrom: m2_sys.z.properties.minPosition              , comment: "Minimum position of the axis, in micrometer" }
        MAX_POSITION        : { type: t_double , copyFrom: m2_sys.z.properties.maxPosition              , comment: "Maximum position of the axis, in micrometer" }
        SCREW_PITCH         : { type: t_double , copyFrom: m2_sys.z.properties.screwPitch               , comment: "Screw pitch, in micrometer" }
        FEEDBACK_RESOLUTION : { type: t_double , copyFrom: m2_sys.z.properties.feedbackResolution       , comment: "Motor feedback resolution (pulses per revolution of the motor rotor)" }


########################################################################################################################
# M2ConstantsX, M2ConstantsY, M2ConstantsTiltX, M2ConstantsTiltY
########################################################################################################################

for name in [ 'x', 'y', 'tiltX', 'tiltY' ]
    MTCS_MAKE_CONFIG THISLIB, "M2Constants#{name.capitalize()}",
        comment: "Some mechanical constants for the #{name.capitalize()} axis"
        items:
            MOT_TO_RED_RATIO            : { type: t_double , copyFrom: m2_sys[name].parts.motToRed.ratio.quantityValue  , comment: "Motor reduction ratio" }
            RED_TO_SCREW_RATIO          : { type: t_double , copyFrom: m2_sys[name].parts.redToScrew.ratio.quantityValue, comment: "Transmission ratio between the motor reduction and the screw" }
            SCREW_TO_POT_RATIO          : { type: t_double , copyFrom: m2_sys[name].parts.screwToPot.ratio.quantityValue, comment: "Transmission ratio between the potentiometer and the screw" }
            MIN_POSITION                : { type: t_double , copyFrom: m2_sys[name].properties.minPosition              , comment: "Minimum position of the axis, in micrometer" }
            MAX_POSITION                : { type: t_double , copyFrom: m2_sys[name].properties.maxPosition              , comment: "Maximum position of the axis, in micrometer" }
            SCREW_PITCH                 : { type: t_double , copyFrom: m2_sys[name].properties.screwPitch               , comment: "Screw pitch, in micrometer" }
            FEEDBACK_RESOLUTION         : { type: t_double , copyFrom: m2_sys[name].properties.feedbackResolution       , comment: "Motor feedback resolution (pulses per revolution of the motor rotor)" }
            POTENTIOMETER_REVOLUTIONS   : { type: t_double , copyFrom: m2_sys[name].properties.potentiometerRevolutions , comment: "Max number of revolutions of the potentiometer" }


########################################################################################################################
# M2Multiplexer
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB,  "M2Multiplexer",
    typeOf: THISLIB.M2Parts.multiplexer
    variables:
        noFault         : { type: t_bool                  , address: "%I*"  , comment: "FALSE if the drive selected by the multiplexer is in faulty state, TRUE if it is in a healthy state"}
        isEnabled       : { type: t_bool                                    , comment: "TRUE if the multiplexer is enabled, FALSE if not"}
        powered         : { type: t_bool                                                    , comment: "TRUE if the axis is powered" }
    parts:
        A               : { type: COMMONLIB.SimpleRelay                     , comment: "Output A of the multiplexer corresponding with the selected axis" }
        B               : { type: COMMONLIB.SimpleRelay                     , comment: "Output B of the multiplexer corresponding with the selected axis" }
        C               : { type: COMMONLIB.SimpleRelay                     , comment: "Output C of the multiplexer corresponding with the selected axis" }
        driveEnable     : { type: COMMONLIB.SimpleRelay                     , comment: "Enabled (TRUE) if the drive selected by the multiplexer must be enabled, Disabled (FALSE) if it must be disabled" }
        CW              : { type: COMMONLIB.SimpleRelay                     , comment: "Enabled (TRUE) if the motor selected by the multiplexer will run in CW direction (- motion on the screw), Disabled (FALSE) if it will run in CCW direction (+ motion on the screw)" }
        release         : { type: COMMONLIB.SimpleRelay                     , comment: "Disabled (FALSE) if the motor selected by the multiplexer must be braking, Enabled (TRUE) if it must be released" }
    processes:
        selectAxis      : { type: THISLIB.M2SelectAxisProcess               , comment: "Select an axis" }
    statuses:
        healthStatus    : { type: COMMONLIB.HealthStatus                    , comment: "Is the selected drive healthy?"}
        busyStatus      : { type: COMMONLIB.BusyStatus                      , comment: "Is the selected drive busy?"}
    calls:
        A:
            isEnabled   : -> self.isEnabled
        B:
            isEnabled   : -> self.isEnabled
        C:
            isEnabled   : -> self.isEnabled
        driveEnable:
            isEnabled   : -> self.isEnabled
        CW:
            isEnabled   : -> self.isEnabled
        release:
            isEnabled   : -> self.isEnabled
        selectAxis:
            isEnabled   : -> self.isEnabled
        healthStatus:
            isGood      : -> AND( OR(self.noFault, NOT(self.powered)),
                                  self.processes.selectAxis.statuses.healthStatus.good )
        busyStatus:
            isBusy      : -> OR( self.parts.A.statuses.busyStatus.busy,
                                 self.parts.B.statuses.busyStatus.busy,
                                 self.parts.C.statuses.busyStatus.busy,
                                 self.parts.driveEnable.statuses.busyStatus.busy,
                                 self.parts.CW.statuses.busyStatus.busy,
                                 self.parts.release.statuses.busyStatus.busy )


########################################################################################################################
# M2XAxis, M2YAxis, M2TiltXAxis, M2TiltYAxis
########################################################################################################################

for name in [ 'x', 'y', 'tiltX', 'tiltY' ]
    MTCS_MAKE_STATEMACHINE THISLIB,  "M2#{name.capitalize()}Axis",
        typeOf: THISLIB.M2Parts[name]
        references:
            config                  : { type: THISLIB.M2Config                          , expand: false , comment: "The general M2 config" }
            axisConfig              : { type: THISLIB.M2PotentiometerAxisConfig                         , comment: "The config particular for this axis" }
        variables:
            position                : { type: COMMONLIB.LinearPositionMeasurement16                     , comment: "Actual position of the axis" }
            backlashLifted          : { type: t_bool                                                    , comment: "TRUE if the backlash was previously lifted" }
            powered                 : { type: t_bool                                                    , comment: "TRUE if the axis is powered" }
        variables_read_only:
            constants               : { type: THISLIB["M2Constants#{name.capitalize()}"]                , comment: "Some constants particular for this axis" }
        statuses:
            healthStatus            : { type: COMMONLIB.HealthStatus                                    , comment: "Is the axis healthy?"}
        calls:
            position:
                config              : -> self.axisConfig.general.measurement
                conversionFactor    : -> DIV(
                                              MUL(
                                                    self.constants.POTENTIOMETER_REVOLUTIONS
                                                    MUL(self.constants.SCREW_TO_POT_RATIO
                                                        self.constants.SCREW_PITCH)
                                              ),
                                              MUL(
                                                    DOUBLE(Math.pow(2,15)) "resolution"
                                                    DOUBLE(1000) "micrometer_per_millimeter"
                                              )
                                         )

            healthStatus:
                isGood              : -> self.position.statuses.healthStatus.isGood
                hasWarning          : -> self.position.statuses.healthStatus.hasWarning


########################################################################################################################
# M2ZAxis
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB,  "M2ZAxis",
    typeOf: THISLIB.M2Parts.z
    references:
        config              : { type: THISLIB.M2Config          , expand: false , comment: "The general M2 config" }
        axisConfig          : { type: THISLIB.M2ZAxisConfig                     , comment: "The config particular for this axis" }
    variables:
        position            : { type: COMMONLIB.LinearPositionMeasurementU32    , comment: "Actual position of the axis" }
        backlashLifted      : { type: t_bool                                    , comment: "TRUE if the backlash was previously lifted" }
        powered             : { type: t_bool                                    , comment: "TRUE if the axis is powered" }
        isEnabled           : { type: t_bool                                    , comment: "TRUE if the Z axis control is enabled, FALSE if not"}
    variables_read_only:
        constants           : { type: THISLIB.M2ConstantsZ                      , comment: "Some constants particular for this axis" }
#        actualPosition      : { type: COMMONLIB.LinearPosition  , expand: false , comment: "Actual position of the axis" }
#        averagePosition     : { type: COMMONLIB.LinearPosition  , expand: false , comment: "Average position of the axis" }
    parts:
        highSpeed           : { type: COMMONLIB.SimpleRelay                     , comment: "Enabled (TRUE) to enable the high-speed motion of the Z axis, Disabled (FALSE) to leave it low-speed" }
        encoder             : { type: COMMONLIB.SSIEncoder                      , comment: "The SSI encoder of the Z axis" }
    statuses:
        healthStatus        : { type: COMMONLIB.HealthStatus                    , comment: "Is the axis healthy?"}
    calls:
        highSpeed:
            isEnabled           : -> self.isEnabled
        position:
            rawValue            : -> self.parts.encoder.counterValue
            error               : -> OR( self.parts.encoder.dataError, self.parts.encoder.frameError, self.parts.encoder.powerFailure, self.parts.encoder.syncError )
            config              : -> self.axisConfig.general.measurement
            conversionFactor    : -> DIV(
                                        MUL(
                                                self.constants.SCREW_TO_ENC_RATIO,
                                                self.constants.SCREW_PITCH
                                        )
                                        MUL(
                                                DOUBLE(Math.pow(2,13)) "resolution_single_turn"  # encoder resolution = 13 bits / rev
                                                DOUBLE(1000) "micrometer_per_millimeter"
                                        )
                                     )
        healthStatus:
            isGood                      : -> MTCS_SUMMARIZE_GOOD(self.position, self.parts.encoder)
            hasWarning                  : -> MTCS_SUMMARIZE_WARN(self.position, self.parts.encoder)


########################################################################################################################
# M3GotoProcedureStates
########################################################################################################################

MTCS_MAKE_ENUM THISLIB, "M2MoveProcedureStates",
    items:
        [   "IDLE",
            "ABORTED",
            "PREPARE_PROCESS",
            "MOVING",
            "MOVING_TO_ANTI_BACKLASH_POSITION",
            "MOVING_CLOSE_TO_FINAL_POSITION",
            "MOVING_TO_FINAL_POSITION",
            "ERROR",
            "ABORTING"   ]

########################################################################################################################
# M2MoveStepsProcedure
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB, "M2MoveStepsProcedure",
    typeOf: [ THISLIB.M2Parts.moveStepsProcedure ]
    variables:
        state               : { type: THISLIB.M2MoveProcedureStates , comment: "New state, to be set by the manual implementation" }
        actualCounterValue  : { type: t_uint32            , address: '%I*'  , comment: "Actual counter value" }
        stepsRemaining      : { type: t_uint32                              , comment: "Number of steps remaining"}
    references:
        powerOn             : { type: COMMONLIB.Process     , expand: false }
        x                   : { type: THISLIB.M2XAxis       , expand: false }
        y                   : { type: THISLIB.M2YAxis       , expand: false }
        z                   : { type: THISLIB.M2ZAxis       , expand: false }
        tiltX               : { type: THISLIB.M2TiltXAxis   , expand: false }
        tiltY               : { type: THISLIB.M2TiltYAxis   , expand: false }
        multiplexer         : { type: THISLIB.M2Multiplexer , expand: false }
        config              : { type: THISLIB.M2Config      , expand: false }
    statuses:
        busyStatus          : { type: COMMONLIB.BusyStatus                  , comment: "Is the M2MoveStepsProcedure in a busy state?" }
        healthStatus        : { type: COMMONLIB.HealthStatus                , comment: "Is the M2MoveStepsProcedure in a healthy state?" }
    calls:
        busyStatus:
            isBusy          : -> NOT( OR( EQ(self.state, THISLIB.M2MoveProcedureStates.IDLE),
                                          EQ(self.state, THISLIB.M2MoveProcedureStates.ABORTED),
                                          EQ(self.state, THISLIB.M2MoveProcedureStates.ERROR) ) )
        healthStatus:
            isGood          : -> NOT( EQ(self.state, THISLIB.M2MoveProcedureStates.ERROR) )
            hasWarning      : -> EQ(self.state, THISLIB.M2MoveProcedureStates.ABORTED)


########################################################################################################################
# M2MovePositionProcedure
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB, "M2MovePositionProcedure",
    typeOf: [ THISLIB.M2Parts.movePositionProcedure ]
    variables:
        state               : { type: THISLIB.M2MoveProcedureStates , comment: "New state, to be set by the manual implementation" }
    references:
        powerOn             : { type: COMMONLIB.Process             , expand: false }
        x                   : { type: THISLIB.M2XAxis               , expand: false }
        y                   : { type: THISLIB.M2YAxis               , expand: false }
        z                   : { type: THISLIB.M2ZAxis               , expand: false }
        tiltX               : { type: THISLIB.M2TiltXAxis           , expand: false }
        tiltY               : { type: THISLIB.M2TiltYAxis           , expand: false }
        multiplexer         : { type: THISLIB.M2Multiplexer         , expand: false }
        moveStepsProcedure  : { type: THISLIB.M2MoveStepsProcedure  , expand: false }
        config              : { type: THISLIB.M2Config              , expand: false }
    statuses:
        busyStatus          : { type: COMMONLIB.BusyStatus                  , comment: "Is the M2MoveAbsoluteProcedure in a busy state?" }
        healthStatus        : { type: COMMONLIB.HealthStatus                , comment: "Is the M2MoveAbsoluteProcedure in a healthy state?" }
    calls:
        busyStatus:
            isBusy          : -> NOT( OR( EQ(self.state, THISLIB.M2MoveProcedureStates.IDLE),
                                          EQ(self.state, THISLIB.M2MoveProcedureStates.ABORTED),
                                          EQ(self.state, THISLIB.M2MoveProcedureStates.ERROR) ) )
        healthStatus:
            isGood          : -> NOT( EQ(self.state, THISLIB.M2MoveProcedureStates.ERROR) )
            hasWarning      : -> EQ(self.state, THISLIB.M2MoveProcedureStates.ABORTED)


########################################################################################################################
# Write the model to file
########################################################################################################################

m2_soft.WRITE "models/mtcs/m2/software.jsonld"
