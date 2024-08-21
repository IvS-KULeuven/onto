########################################################################################################################
#                                                                                                                      #
# Model of the M3 software.                                                                                            #
#                                                                                                                      #
########################################################################################################################

require "ontoscript"

# metamodels
REQUIRE "models/import_all.coffee"

# models
REQUIRE "models/mtcs/common/software.coffee"

MODEL "http://www.mercator.iac.es/onto/models/mtcs/m3/software" : "m3_soft"

m3_soft.IMPORT mm_all
m3_soft.IMPORT common_soft


########################################################################################################################
# Define the containing PLC library
########################################################################################################################

m3_soft.ADD MTCS_MAKE_LIB "mtcs_m3"

# make aliases (with scope of this file only)
COMMONLIB = common_soft.mtcs_common
THISLIB   = m3_soft.mtcs_m3


########################################################################################################################
# M3KnownPositionIDs
########################################################################################################################

MTCS_MAKE_ENUM THISLIB, "M3PositionIDs",
    items:
        [   "UNKNOWN",
            "CASSEGRAIN",
            "NASMYTH_A",
            "NASMYTH_B",
            "NASMYTH_C",
            "NASMYTH_D",
            "OTHER_0",
            "OTHER_1",
            "OTHER_2",
            "OTHER_3",
            "OTHER_4" ]


########################################################################################################################
# M3GotoProcedureStates
########################################################################################################################
MTCS_MAKE_ENUM THISLIB, "M3GotoProcedureStates",
    items:
        [   "IDLE",
            "ABORTED",
            "PREPARE_PROCESS",
            "GOING_TO_POSITION",
            "IMPROVING_POSITION",
            "ERROR",
            "RESETTING",
            "ABORTING"   ]


########################################################################################################################
# M3RotateProcedureStates
########################################################################################################################

MTCS_MAKE_ENUM THISLIB, "M3RotateProcedureStates",
    items:
        [   "IDLE",
            "ABORTED",
            "PREPARE_PROCESS",
            "DECOUPLING_AXES",
            "ENABLING_AXES",
            "UNDOING_OFFSET",
            "COUPLING_AXES",
            "BOTH_GOING_TO_TARGET_PLUS_OFFSET",
            "DECOUPLING_AXES_AGAIN",
            "MOVING_ABL_TO_FINAL_POSITION",
            "DISABLING_ABL",
            "MOVING_POS_TO_FINAL_POSITION",
            "IMPROVING_POSITION",
            "DISABLING_POS",
            "ERROR",
            "RESETTING",
            "ABORTING" ]


########################################################################################################################
# M3TranslateProcedureStates
########################################################################################################################
MTCS_MAKE_ENUM THISLIB, "M3TranslateProcedureStates",
    items:
        [   "IDLE",
            "ABORTED",
            "PREPARE_PROCESS",
            "ENABLING_AXIS",
            "MOVING",
            "IMPROVING_POSITION",
            "DISABLING_AXIS",
            "ERROR",
            "RESETTING",
            "ABORTING"    ]


########################################################################################################################
# M3TranslationHomingProcedureStates
########################################################################################################################
MTCS_MAKE_ENUM THISLIB, "M3TranslationHomingProcedureStates",
    items:
        [   "IDLE",
            "ABORTED",
            "PREPARE_PROCESS",
            "ENABLING_AXIS",
            "MOVE_TO_LIMIT_SWITCH",
            "WAIT_FOR_LIMIT_SWITCH",
            "STOP",
            "APPLY_HOMING_SETTINGS",
            "MOVE_TO_MECH_STOP",
            "WAIT_FOR_MECH_STOP",
            "SET_ZERO_POSITION",
            "DISABLE_AXIS",
            "RESETTING",
            "ERROR",
            "ABORTING"    ]


########################################################################################################################
# M3CalibrateRotationProcedureStates
########################################################################################################################
MTCS_MAKE_ENUM THISLIB, "M3CalibrateRotationProcedureStates",
    items:
        [   "IDLE",
            "ABORTED",
            "PREPARE_PROCESS",
            "DECOUPLING_AXES",
            "ENABLING_AXES",
            "COUPLING_AXES",
            "GOING_TO_START_POSITION",
            "DECOUPLING_AXES_AGAIN",
            "START_MOVING",
            "WAIT_UNTIL_MOVING_STABLE",
            "WAIT_UNTIL_RANGE_PASSED",
            "HALT",
            "GO_TO_CLUTCH_ZERO_TORQUE",
            "DISABLING_AXES",
            "WAIT_UNTIL_STANDSTILL",
            "SYNC_AXES"
            "ERROR",
            "RESETTING",
            "ABORTING" ]


########################################################################################################################
# M3PositionStates
########################################################################################################################
MTCS_MAKE_ENUM THISLIB, "M3TargetStates",
    items:
        [ "NO_TARGET_GIVEN",
          "KNOWN_POSITION",
          "NEW_POSITION" ]


########################################################################################################################
# M3TargetStatus
########################################################################################################################
MTCS_MAKE_STATUS THISLIB, "M3TargetStatus",
    variables:
        "state":
            type: THISLIB.M3TargetStates
            comment: "Enum!"
    states:
        "noTargetGiven":
            expr: -> EQ( self.state, THISLIB.M3TargetStates.NO_TARGET_GIVEN )
            comment: "No target given"
        "knownPosition":
            expr: -> EQ( self.state, THISLIB.M3TargetStates.KNOWN_POSITION )
            comment: "Known position"
        "newPosition":
            expr: -> EQ( self.state, THISLIB.M3TargetStates.NEW_POSITION )
            comment: "Undefined"


########################################################################################################################
# M3PositionConfig
########################################################################################################################
MTCS_MAKE_CONFIG THISLIB, "M3PositionConfig",
    items:
        name:
            type: t_string
            comment: "The name of the M3 position"
        rotationPosition:
            type: t_double
            comment: "The position of the rotation stage in degrees"
        rotationOffset:
            type: t_double
            comment: "The offset between the positions of the two motors of the rotation stage in degrees"
        translationPosition:
            type: t_double
            comment: "The position of the translation stage in millimeters"
        doRotation:
            type: t_bool
            comment: "Do a rotation for this position (TRUE) or not (FALSE)"
        doTranslation:
            type: t_bool
            comment: "Do a translation for this position (TRUE) or not (FALSE)"


########################################################################################################################
# M3KnownPositionsConfig
########################################################################################################################
MTCS_MAKE_CONFIG THISLIB, "M3KnownPositionsConfig",
    items:
        cassegrain     : { type: THISLIB.M3PositionConfig, comment : "Cassegrain"                   , expand: false }
        nasmythA       : { type: THISLIB.M3PositionConfig, comment : "Nasmyth A"                    , expand: false }
        nasmythB       : { type: THISLIB.M3PositionConfig, comment : "Nasmyth B"                    , expand: false }
        nasmythC       : { type: THISLIB.M3PositionConfig, comment : "Nasmyth C"                    , expand: false }
        nasmythD       : { type: THISLIB.M3PositionConfig, comment : "Nasmyth D"                    , expand: false }
        other0         : { type: THISLIB.M3PositionConfig, comment : "Freely choosable position 0"  , expand: false }
        other1         : { type: THISLIB.M3PositionConfig, comment : "Freely choosable position 1"  , expand: false }
        other2         : { type: THISLIB.M3PositionConfig, comment : "Freely choosable position 2"  , expand: false }
        other3         : { type: THISLIB.M3PositionConfig, comment : "Freely choosable position 3"  , expand: false }
        other4         : { type: THISLIB.M3PositionConfig, comment : "Freely choosable position 4"  , expand: false }


########################################################################################################################
# M3RotationConfig
########################################################################################################################
MTCS_MAKE_CONFIG THISLIB, "M3RotationConfig",
    items:
        standstillTolerance:
            type: t_double
            comment: "The tolerance for which the axis appears to be standing still, in degrees/sec"
        motorToMirrorRatio:
            type: t_double
            comment: "The motor-to-mirror transmission ratio"
        encoderToMirrorRatio:
            type: t_double
            comment: "The encoder-to-mirror transmission ratio"
        positioningDrive:
            type: COMMONLIB.FaulhaberDriveConfig
            comment: "The config of the positioning faulhaber drive"
            expand: false
        antiBacklashDrive:
            type: COMMONLIB.FaulhaberDriveConfig
            comment: "The config of the anti-backlash faulhaber drive"
            expand: false
        negativeSoftLimit:
            type: t_double
            comment: "Negative soft limit, in degrees"
        positiveSoftLimit:
            type: t_double
            comment: "Negative soft limit, in degrees"
        maxPositionError:
            type: t_double
            comment: "Maximum position error, in degrees"
        maxOffsetError:
            type: t_double
            comment: "Maximum position error, in degrees"
        gotoOffsetVelocity: # e.g. 6.0
            type: t_double
            comment: "Velocity to move from/to the offset position, in degrees/sec on the MOTOR reduction exit shaft reference system"
        gotoTargetVelocity: # e.g. 6.0
            type: t_double
            comment: "Velocity to move to the target, in degrees/sec on the MIRROR reference system"
        gotoImprovingPositionTime: # e.g. 3.0
            type: t_double
            comment: "Time while the Goto procedure may improve the position, in seconds"
        calibrateStartPosition: # e.g. 50.0
            type: t_double
            comment: "Mirror position (in degrees) to start the calibration from"
        calibrateMoveToZeroTorqueVelocity: # e.g. 1.0
            type: t_double
            comment: "Velocity to move to the zero-torque position, in degrees/sec on the MIRROR reference system"
        calibrateVelocity: # e.g. 1.0
            type: t_double
            comment: "Velocity during which the current is being measured, in degrees/sec on the MIRROR reference system"
        calibrateRange: # e.g. 70.0
            type: t_double
            comment: "Position range where the current is being measured, in degrees on the MOTOR reference system"
        calibrateOffset: # e.g. 30.0
            type: t_double
            comment: "Degrees between zero-torque position and minimum-torque position, on the MOTOR reference system"


########################################################################################################################
# M3TranslationConfig
########################################################################################################################
MTCS_MAKE_CONFIG THISLIB, "M3TranslationConfig",
    items:
        homingContinuousCurrentLimit:
            type: t_uint16
            comment: "The continuous current limit for the translation stage motor in milliAmps, during homing"
        homingPeakCurrentLimit:
            type: t_uint16
            comment: "The peak current limit for the translation stage motor in milliAmps, during homing"
        homingSearchLimitSwitchVelocity:
            type: t_double
            comment: "The velocity of the motor shaft during homing, in mm/sec"
        homingToHardwareStopVelocity:
            type: t_double
            comment: "The velocity of the motor shaft during homing, in mm/sec"
        standstillTolerance:
            type: t_double
            comment: "The tolerance for which the axis appears to be standing still, in mm/sec"
        motorDrive:
            type: COMMONLIB.FaulhaberDriveConfig
            comment: "The config of the faulhaber drive"
            expand: false
        negativeSoftLimit:
            type: t_double
            comment: "Negative soft limit, in millimeters"
        positiveSoftLimit:
            type: t_double
            comment: "Negative soft limit, in millimeters"
        maxPositionError:
            type: t_double
            comment: "Maximum position error, in millimeters"
        drawCassegrainLimit:
            type: t_double
            comment: "Below this limit (in millimeters) the mirror will be drawn flipped away"
        drawNasmythLimit:
            type: t_double
            comment: "Above this limit (in millimeters) the mirror will be drawn frontal"
        gotoImprovingPositionTime:
            type: t_double
            comment: "Time while the Goto procedure may improve the position, in seconds"
        gotoVelocity:
            type: t_double
            comment: "Velocity to go to a new position, in degrees/second"


########################################################################################################################
# M3Config
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "M3Config",
    items:
        knownPositions:
            comment: "All known M3 positions"
            type:    THISLIB.M3KnownPositionsConfig
            expand: false
        rotation:
            comment: "The settings of the rotation stage"
            type:    THISLIB.M3RotationConfig
            expand: false
        translation:
            comment: "The settings of the translation stage"
            type:    THISLIB.M3TranslationConfig
            expand: false
        moveAfterInitialization:
            comment: "Move the mirror to a known position after initialization"
            type:    t_bool
        moveAfterInitializationPosition:
            comment: "Move the mirror to this position after initialization"
            type:    t_string



########################################################################################################################
# M3GotoKnownPosition
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "M3GotoKnownPosition",
    extends: COMMONLIB.BaseProcess
    arguments:
        name : { type: t_string, comment: "Name of the position (must be configured in M3Config.knownPositions!)" }


########################################################################################################################
# GotoNewPosition
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "M3GotoNewPosition",
    extends: COMMONLIB.BaseProcess
    arguments:
        rotationPosition     : { type: t_double, comment: "Position of the rotation stage, in degrees" }
        rotationOffset       : { type: t_double, comment: "Offset between the motors of the rotation stage, in degrees" }
        translationPosition  : { type: t_double, comment: "Position of the rotation stage, in millimeters" }
        doRotation           : { type: t_bool  , comment: "Do a rotation for this position (TRUE) or not (FALSE)" }
        doTranslation        : { type: t_bool  , comment: "Do a translation for this position (TRUE) or not (FALSE)" }


########################################################################################################################
# M3RotationTarget
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB,  "M3RotationTarget",
    variables_hidden:
        isTargetGiven               : { type: t_bool                             , comment: "TRUE if a target is given" }
        newPositionDegrees          : { type: t_double                           , comment: "New target position in degrees" }
        newOffsetDegrees            : { type: t_double                           , comment: "New target offset in degrees" }
    references:
        knownPositions      : { type: THISLIB.M3KnownPositionsConfig   , comment: "The known positions"}
    variables_read_only:
        name                : { type: t_string                  , comment: "Name of the target (only in case the position and offset match an entry in the config!)" }
        position            : { type: COMMONLIB.AngularPosition , comment: "Target position for M3 rotation (only in case statuses.targetStatus.noTargetGiven is FALSE)" }
        offset              : { type: COMMONLIB.AngularPosition , comment: "Target offset for M3 rotation (only in case statuses.targetStatus.noTargetGiven is FALSE)"}
    statuses:
        targetStatus        : { type: THISLIB.M3TargetStatus }
    calls:
        position:
            newDegreesValue : -> self.newPositionDegrees
        offset:
            newDegreesValue : -> self.newOffsetDegrees


########################################################################################################################
# M3TranslationTarget
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB,  "M3TranslationTarget",
    variables_hidden:
        isTargetGiven                   : { type: t_bool, initial: bool(false)      , comment: "TRUE if a target is given" }
        newPositionMillimeters          : { type: t_double                          , comment: "New target position in millimeters" }
    references:
        knownPositions          : { type: THISLIB.M3KnownPositionsConfig    , comment: "The known positions", expand: false}
    variables_read_only:
        name                    : { type: t_string                          , comment: "Name of the target (only in case the position matches an entry in the config!)" }
        position                : { type: COMMONLIB.LinearPosition          , comment: "Target position for M3 translation (only in case statuses.targetStatus.noTargetGiven is FALSE)" }
    statuses:
        targetStatus            : { type: THISLIB.M3TargetStatus }
    calls:
        position:
            newMillimetersValue : -> self.newPositionMillimeters


########################################################################################################################
# M3
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB,  "M3",
    variables:
        editableConfig                  : { type: THISLIB.M3Config           , comment: "Editable configuration of M3" , expand: false }
    references:
        operatorStatus                  : { type: COMMONLIB.OperatorStatus   , comment: "Shared operator status"}
    variables_read_only:
        config                          : { type: THISLIB.M3Config           , comment: "Active configuration of M3" }
        actualKnownPositionName         : { type: t_string                   , comment: "Name of the actual position according to config.knownPositions" }
        actualKnownPositionID           : { type: THISLIB.M3PositionIDs      , comment: "ID of the actual position according to config.knownPositions" }
    parts:
        rotation:
            comment                     : "Rotation mechanism"
            arguments:
                initializationStatus    : { type: COMMONLIB.InitializationStatus , expand: false }
                operatingStatus         : { type: COMMONLIB.OperatingStatus      , expand: false }
                operatorStatus          : { type: COMMONLIB.OperatorStatus       , expand: false }
                config                  : {}
                m3Config                : { type: THISLIB.M3Config               , expand: false }
            attributes:
                procedures              : {}
                statuses:
                    attributes:
                        healthStatus    : { type: COMMONLIB.HealthStatus }
                        busyStatus      : { type: COMMONLIB.BusyStatus }
        translation:
            comment                     : "Translation mechanism"
            arguments:
                initializationStatus    : { type: COMMONLIB.InitializationStatus , expand: false }
                operatingStatus         : { type: COMMONLIB.OperatingStatus      , expand: false }
                operatorStatus          : { type: COMMONLIB.OperatorStatus       , expand: false }
                config                  : {}
                m3Config                : { type: THISLIB.M3Config               , expand: false }
            attributes:
                procedures              : {}
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
        gotoProcedure:
            comment                     : "The goto procedure"
            arguments:
                rotation                : {}
                translation             : {}
                m3Config                : {}
            attributes:
                isGotoAllowed           : {}
                statuses:
                    attributes:
                        healthStatus    : { type: COMMONLIB.HealthStatus }
                        busyStatus      : { type: COMMONLIB.BusyStatus   }
        configManager:
            comment                     : "The config manager (to load/save/activate configuration data)"
            type                        : COMMONLIB.ConfigManager
    statuses:
        initializationStatus            : { type: COMMONLIB.InitializationStatus }
        apertureStatus                  : { type: COMMONLIB.ApertureStatus }
        healthStatus                    : { type: COMMONLIB.HealthStatus }
        busyStatus                      : { type: COMMONLIB.BusyStatus }
        operatingStatus                 : { type: COMMONLIB.OperatingStatus }
    processes:
        initialize                      : { type: COMMONLIB.Process                       , comment: "Start initializing" }
        lock                            : { type: COMMONLIB.Process                       , comment: "Lock the system" }
        unlock                          : { type: COMMONLIB.Process                       , comment: "Unlock the system" }
        reset                           : { type: COMMONLIB.Process                       , comment: "Reset any errors" }
        changeOperatingState            : { type: COMMONLIB.ChangeOperatingStateProcess   , comment: "Change the operating state (e.g. AUTO, MANUAL, ...)" }
        gotoKnownPosition               : { type: THISLIB.M3GotoKnownPosition             , comment: "Go to the known position with the given name (only in AUTO mode!)" }
        gotoNewPosition                 : { type: THISLIB.M3GotoNewPosition               , comment: "Go to the new position with the given settings (only in AUTO mode!)" }
        abort                           : { type: COMMONLIB.Process                       , comment: "Abort the goto procedure" }
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
        shutdown:
            isEnabled                   : -> AND(self.statuses.busyStatus.idle, NOT( self.statuses.initializationStatus.shutdown))
        reset:
            isEnabled                   : -> self.statuses.healthStatus.bad
        abort:
            isEnabled                   : -> self.parts.gotoProcedure.statuses.busyStatus.busy
        gotoKnownPosition:
            isEnabled                   : -> AND(self.parts.gotoProcedure.isGotoAllowed,
                                                 self.statuses.initializationStatus.initialized,
                                                 self.statuses.operatingStatus.auto)
        gotoNewPosition:
            isEnabled                   : -> AND(self.parts.gotoProcedure.isGotoAllowed,
                                                 self.statuses.initializationStatus.initialized,
                                                 self.statuses.operatingStatus.auto)
        close:
            isEnabled                   : -> AND(self.statuses.busyStatus.idle, self.statuses.initializationStatus.initialized, self.statuses.operatingStatus.auto)
        rotation:
            initializationStatus        : -> self.statuses.initializationStatus
            operatorStatus              : -> self.operatorStatus
            operatingStatus             : -> self.statuses.operatingStatus
            config                      : -> self.config.rotation
            m3Config                    : -> self.config
        translation:
            initializationStatus        : -> self.statuses.initializationStatus
            operatorStatus              : -> self.operatorStatus
            operatingStatus             : -> self.statuses.operatingStatus
            config                      : -> self.config.translation
            m3Config                    : -> self.config
        gotoProcedure:
            rotation                    : -> self.parts.rotation
            translation                 : -> self.parts.translation
            m3Config                    : -> self.config
        operatingStatus:
            superState                  : -> self.statuses.initializationStatus.initialized
        healthStatus:
            isGood                      : -> MTCS_SUMMARIZE_GOOD(self.parts.rotation, self.parts.translation, self.parts.gotoProcedure, self.parts.io)
            hasWarning                  : -> OR( MTCS_SUMMARIZE_WARN(self.parts.rotation, self.parts.translation, self.parts.gotoProcedure, self.parts.io),
                                                 AND(self.statuses.busyStatus.idle,
                                                     EQ(self.actualKnownPositionID, THISLIB.M3PositionIDs.UNKNOWN)) )

        busyStatus:
            isBusy                      : -> OR(self.parts.rotation.statuses.busyStatus.busy,
                                                self.parts.translation.statuses.busyStatus.busy,
                                                self.parts.gotoProcedure.statuses.busyStatus.busy)
        configManager:
            isEnabled                   : -> self.operatorStatus.tech


########################################################################################################################
# M3GotoProcedure
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB, "M3GotoProcedure",
    typeOf: [ THISLIB.M3Parts.gotoProcedure ]
    variables:
        state               : { type: THISLIB.M3GotoProcedureStates         , comment: "New state, to be set by the manual implementation" }
    variables_read_only:
        isGotoAllowed       : { type: t_bool                                , comment: "TRUE if a goto command is allowed" }
    references:
        rotation            : {}
        translation         : {}
        m3Config            : { type: THISLIB.M3Config, expand: false }
    statuses:
        busyStatus          : { type: COMMONLIB.BusyStatus                  , comment: "Is the M3GotoProcedure in a busy state?" }
        healthStatus        : { type: COMMONLIB.HealthStatus                , comment: "Is the M3GotoProcedure in a healthy state?" }
    calls:
        busyStatus:
            isBusy          : -> NOT( OR( EQ(self.state, THISLIB.M3GotoProcedureStates.IDLE),
                                          EQ(self.state, THISLIB.M3GotoProcedureStates.ABORTED),
                                          EQ(self.state, THISLIB.M3GotoProcedureStates.ERROR) ) )
        healthStatus:
            isGood          : -> NOT( EQ(self.state, THISLIB.M3GotoProcedureStates.ERROR) )
            hasWarning      : -> EQ(self.state, THISLIB.M3GotoProcedureStates.ABORTED)


########################################################################################################################
# M3RotationGoto
########################################################################################################################

MTCS_MAKE_PROCESS THISLIB, "M3RotationGoto",
    extends: COMMONLIB.BaseProcess
    arguments:
        position     : { type: t_double, comment: "Position setpoint of the rotation stage, in degrees" }
        offset       : { type: t_double, comment: "Offset setpoint between the motors of the rotation stage, in degrees" }


########################################################################################################################
# M3Rotation
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB,  "M3Rotation",
    typeOf                              : [ THISLIB.M3Parts.rotation,
                                            THISLIB.M3GotoProcedure.rotation ]
    variables:
        target                          : { type: THISLIB.M3RotationTarget }
        positiveLimitSwitchActive       : { type: t_bool                        , comment: "TRUE if the positive limit switch is active", address: "%I*" }
        negativeLimitSwitchActive       : { type: t_bool                        , comment: "TRUE if the negative limit switch is active", address: "%I*" }
    variables_read_only:
        actualPosition                  : { type: COMMONLIB.AngularPosition     , comment: "The actual position of the rotation" }
        actualPositionError             : { type: COMMONLIB.AngularPosition     , comment: "The actual position error of the rotation" }
        actualOffset                    : { type: COMMONLIB.AngularPosition     , comment: "The actual offset of the rotation" }
        actualOffsetError               : { type: COMMONLIB.AngularPosition     , comment: "The actual offset error of the rotation" }
    references:
        initializationStatus            : { type: COMMONLIB.InitializationStatus }
        operatorStatus                  : { type: COMMONLIB.OperatorStatus }
        operatingStatus                 : { type: COMMONLIB.OperatingStatus }
        config                          : { type: THISLIB.M3RotationConfig }
        m3Config                        : { type: THISLIB.M3Config }
    parts:
        positioningAxis                 : { type: COMMONLIB.AngularAxis     , comment: "Positioning axis: SSI encoder + Faulhaber drive" }
        antiBacklashAxis                : { type: COMMONLIB.AngularAxis     , comment: "Anti-backlash Axis: Faulhaber drive + hall sensors" }
        positioningDrive                : { type: COMMONLIB.FaulhaberDrive  , comment: "Positioning drive" }
        antiBacklashDrive               : { type: COMMONLIB.FaulhaberDrive  , comment: "Anti-backlash drive" }
        positioningHallAxis             : { type: COMMONLIB.AngularAxis     , comment: "Only hall sensors" }
        gotoProcedure:
            comment                     : "The goto procedure"
            arguments:
                config                      : {}
                positioningAxis             : {}
                antiBacklashAxis            : {}
                positioningDrive            : {}
                antiBacklashDrive           : {}
                positioningHallAxis         : {}
                target                      : {}
                positiveLimitSwitchActive   : {}
                negativeLimitSwitchActive   : {}
                actualPosition              : {}
                actualPositionError         : {}
                actualOffset                : {}
                actualOffsetError           : {}
            attributes:
                isGotoAllowed               : {}
                statuses:
                    attributes:
                        healthStatus    : { type: COMMONLIB.HealthStatus }
                        busyStatus      : { type: COMMONLIB.BusyStatus   }
        calibrateProcedure:
            comment                     : "The calibration procedure"
            arguments:
                config                      : {}
                positioningAxis             : {}
                antiBacklashAxis            : {}
                positioningDrive            : {}
                antiBacklashDrive           : {}
                positioningHallAxis         : {}
                target                      : {}
                actualPosition              : {}
                actualPositionError         : {}
                actualOffset                : {}
                actualOffsetError           : {}
            attributes:
                statuses:
                    attributes:
                        healthStatus    : { type: COMMONLIB.HealthStatus }
                        busyStatus      : { type: COMMONLIB.BusyStatus   }
    statuses:
        healthStatus                    : { type: COMMONLIB.HealthStatus }
        busyStatus                      : { type: COMMONLIB.BusyStatus }
    processes:
        goto                            : { type: THISLIB.M3RotationGoto , comment: "Start moving the rotation stage to the given position" }
        abort                           : { type: COMMONLIB.Process      , comment: "Abort any running procedures" }
        reset                           : { type: COMMONLIB.Process      , comment: "Reset any errors" }
        calibrate                       : { type: COMMONLIB.Process      , comment: "Start calibrating the rotation stage" }
    calls:
        actualPosition:
            newDegreesValue             : -> self.parts.positioningAxis.actPos.degrees.value
        actualPositionError:
            newDegreesValue             : -> SUB(self.actualPosition.degrees.value, self.target.position.degrees.value)
        actualOffset:
            newDegreesValue             : -> SUB(self.parts.antiBacklashAxis.actPos.degrees.value, self.parts.positioningHallAxis.actPos.degrees.value)
        actualOffsetError:
            newDegreesValue             : -> SUB(self.actualOffset.degrees.value, self.target.offset.degrees.value)
        target:
            knownPositions              : -> self.m3Config.knownPositions
        positioningAxis:
            isEnabled                   : -> AND(self.operatorStatus.tech, self.initializationStatus.initialized)
            standstillTolerance         : -> self.config.standstillTolerance
            isGearingSupported          : -> FALSE
        antiBacklashAxis:
            isEnabled                   : -> AND(self.operatorStatus.tech, self.initializationStatus.initialized)
            standstillTolerance         : -> MUL(self.config.standstillTolerance, self.config.motorToMirrorRatio)
            isGearingSupported          : -> TRUE
        positioningHallAxis:
            isEnabled                   : -> FALSE # only encoder axis!
            standstillTolerance         : -> MUL(self.config.standstillTolerance, self.config.motorToMirrorRatio)
            isGearingSupported          : -> FALSE
        positioningDrive:
            isEnabled                   : -> AND(self.operatorStatus.tech, self.initializationStatus.initialized)
            config                      : -> self.config.positioningDrive
        antiBacklashDrive:
            isEnabled                   : -> AND(self.operatorStatus.tech, self.initializationStatus.initialized)
            config                      : -> self.config.antiBacklashDrive
        busyStatus:
            isBusy                      : -> OR( self.parts.positioningAxis.statuses.busyStatus.busy,
                                                 self.parts.antiBacklashAxis.statuses.busyStatus.busy,
                                                 self.parts.positioningDrive.statuses.busyStatus.busy,
                                                 self.parts.antiBacklashDrive.statuses.busyStatus.busy,
                                                 self.parts.gotoProcedure.statuses.busyStatus.busy )
        healthStatus:
            isGood                      : -> MTCS_SUMMARIZE_GOOD( self.parts.positioningAxis,
                                                                  self.parts.antiBacklashAxis,
                                                                  self.parts.positioningDrive,
                                                                  self.parts.antiBacklashDrive,
                                                                  self.parts.positioningHallAxis,
                                                                  self.parts.gotoProcedure )
            hasWarning                  : -> MTCS_SUMMARIZE_WARN( self.parts.positioningAxis,
                                                                     self.parts.antiBacklashAxis,
                                                                     self.parts.positioningDrive,
                                                                     self.parts.antiBacklashDrive,
                                                                     self.parts.positioningHallAxis,
                                                                     self.parts.gotoProcedure )
        goto:
            isEnabled                   : -> AND(self.operatingStatus.manual,
                                                 self.initializationStatus.initialized,
                                                 self.parts.gotoProcedure.isGotoAllowed )
        calibrate:
            isEnabled                   : -> AND(self.operatingStatus.manual, self.initializationStatus.initialized )
        abort:
            isEnabled                   : -> OR( self.parts.gotoProcedure.statuses.busyStatus.busy,
                                                  self.parts.calibrateProcedure.statuses.busyStatus.busy )
        reset:
            isEnabled                   : -> self.statuses.healthStatus.bad
        gotoProcedure:
            config                      : -> self.config
            positioningAxis             : -> self.parts.positioningAxis
            antiBacklashAxis            : -> self.parts.antiBacklashAxis
            positioningDrive            : -> self.parts.positioningDrive
            antiBacklashDrive           : -> self.parts.antiBacklashDrive
            positioningHallAxis         : -> self.parts.positioningHallAxis
            target                      : -> self.target
            positiveLimitSwitchActive   : -> self.positiveLimitSwitchActive
            negativeLimitSwitchActive   : -> self.negativeLimitSwitchActive
            actualPosition              : -> self.actualPosition
            actualPositionError         : -> self.actualPositionError
            actualOffset                : -> self.actualOffset
            actualOffsetError           : -> self.actualOffsetError
        calibrateProcedure:
            config                      : -> self.config
            positioningAxis             : -> self.parts.positioningAxis
            antiBacklashAxis            : -> self.parts.antiBacklashAxis
            positioningDrive            : -> self.parts.positioningDrive
            antiBacklashDrive           : -> self.parts.antiBacklashDrive
            positioningHallAxis         : -> self.parts.positioningHallAxis
            target                      : -> self.target
            actualPosition              : -> self.actualPosition
            actualPositionError         : -> self.actualPositionError
            actualOffset                : -> self.actualOffset
            actualOffsetError           : -> self.actualOffsetError


########################################################################################################################
# M3RotationGotoProcedure
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB, "M3RotationGotoProcedure",
    typeOf: [ THISLIB.M3RotationParts.gotoProcedure ]
    variables:
        state                       : { type: THISLIB.M3RotateProcedureStates       , comment: "New state, to be set by the manual implementation" }
    variables_read_only:
        isGotoAllowed               : { type: t_bool                                , comment: "TRUE if a goto command is allowed" }
    references:
        config                      : { type: THISLIB.M3RotationConfig              ,  expand: false }
        positioningAxis             : { type: COMMONLIB.AngularAxis                 ,  expand: false }
        antiBacklashAxis            : { type: COMMONLIB.AngularAxis                 ,  expand: false }
        positioningDrive            : { type: COMMONLIB.FaulhaberDrive              ,  expand: false }
        antiBacklashDrive           : { type: COMMONLIB.FaulhaberDrive              ,  expand: false }
        positioningHallAxis         : { type: COMMONLIB.AngularAxis                 ,  expand: false }
        target                      : { type: THISLIB.M3RotationTarget              ,  expand: false }
        positiveLimitSwitchActive   : { type: t_bool                                ,  expand: false }
        negativeLimitSwitchActive   : { type: t_bool                                ,  expand: false }
        actualPosition              : { type: COMMONLIB.AngularPosition             ,  expand: false }
        actualPositionError         : { type: COMMONLIB.AngularPosition             ,  expand: false }
        actualOffset                : { type: COMMONLIB.AngularPosition             ,  expand: false }
        actualOffsetError           : { type: COMMONLIB.AngularPosition             ,  expand: false }
    statuses:
        busyStatus          : { type: COMMONLIB.BusyStatus                  , comment: "Is the M3RotationGotoProcedure in a busy state?" }
        healthStatus        : { type: COMMONLIB.HealthStatus                , comment: "Is the M3RotationGotoProcedure in a healthy state?" }
    calls:
        busyStatus:
            isBusy          : -> NOT( OR( EQ(self.state, THISLIB.M3RotateProcedureStates.IDLE),
                                          EQ(self.state, THISLIB.M3RotateProcedureStates.ABORTED),
                                          EQ(self.state, THISLIB.M3RotateProcedureStates.ERROR) ) )
        healthStatus:
            isGood          : -> NOT( EQ(self.state, THISLIB.M3RotateProcedureStates.ERROR) )
            hasWarning      : -> EQ(self.state, THISLIB.M3RotateProcedureStates.ABORTED)


########################################################################################################################
# M3RotationCalibrateProcedure
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB, "M3RotationCalibrateProcedure",
    typeOf: [ THISLIB.M3RotationParts.calibrateProcedure ]
    variables:
        state                       : { type: THISLIB.M3CalibrateRotationProcedureStates, comment: "Current state of the " }
    references:
        config                      : { type: THISLIB.M3RotationConfig              ,  expand: false }
        positioningAxis             : { type: COMMONLIB.AngularAxis                 ,  expand: false }
        antiBacklashAxis            : { type: COMMONLIB.AngularAxis                 ,  expand: false }
        positioningDrive            : { type: COMMONLIB.FaulhaberDrive              ,  expand: false }
        antiBacklashDrive           : { type: COMMONLIB.FaulhaberDrive              ,  expand: false }
        positioningHallAxis         : { type: COMMONLIB.AngularAxis                 ,  expand: false }
        target                      : { type: THISLIB.M3RotationTarget              ,  expand: false }
        actualPosition              : { type: COMMONLIB.AngularPosition             ,  expand: false }
        actualPositionError         : { type: COMMONLIB.AngularPosition             ,  expand: false }
        actualOffset                : { type: COMMONLIB.AngularPosition             ,  expand: false }
        actualOffsetError           : { type: COMMONLIB.AngularPosition             ,  expand: false }
    statuses:
        busyStatus          : { type: COMMONLIB.BusyStatus                          , comment: "Is the M3RotationCalibrateProcedure in a busy state?" }
        healthStatus        : { type: COMMONLIB.HealthStatus                        , comment: "Is the M3RotationCalibrateProcedure in a healthy state?" }
    calls:
        busyStatus:
            isBusy          : -> NOT( OR( EQ(self.state, THISLIB.M3CalibrateRotationProcedureStates.IDLE),
                                          EQ(self.state, THISLIB.M3CalibrateRotationProcedureStates.ABORTED),
                                          EQ(self.state, THISLIB.M3CalibrateRotationProcedureStates.ERROR) ) )
        healthStatus:
            isGood          : -> NOT( EQ(self.state, THISLIB.M3CalibrateRotationProcedureStates.ERROR) )
            hasWarning      : -> EQ(self.state, THISLIB.M3CalibrateRotationProcedureStates.ABORTED)


########################################################################################################################
# M3TranslationGoto
########################################################################################################################

MTCS_MAKE_PROCESS THISLIB, "M3TranslationGoto",
    extends: COMMONLIB.BaseProcess
    arguments:
        position     : { type: t_double, comment: "Position setpoint of the translation stage, in millimeters" }


########################################################################################################################
# M3Translation
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB,  "M3Translation",
    typeOf                              : [ THISLIB.M3Parts.translation,
                                            THISLIB.M3GotoProcedure.translation ]
    variables:
        target                          : { type: THISLIB.M3TranslationTarget }
        positiveLimitSwitchActive       : { type: t_bool                        , comment: "TRUE if the positive limit switch is active", address: "%I*" }
        negativeLimitSwitchActive       : { type: t_bool                        , comment: "TRUE if the negative limit switch is active", address: "%I*" }
    variables_read_only:
        actualPosition                  : { type: COMMONLIB.LinearPosition              , comment: "The actual position of the translation" }
        actualPositionError             : { type: COMMONLIB.LinearPosition              , comment: "The actual position error of the translation" }
    references:
        initializationStatus            : { type: COMMONLIB.InitializationStatus }
        operatorStatus                  : { type: COMMONLIB.OperatorStatus }
        operatingStatus                 : { type: COMMONLIB.OperatingStatus }
        config                          : { type: THISLIB.M3TranslationConfig }
        m3Config                        : { type: THISLIB.M3Config }
    parts:
        motorAxis                       : { type: COMMONLIB.LinearAxis                  , comment: "Motor axis" }
        motorDrive                      : { type: COMMONLIB.FaulhaberDrive              , comment: "Motor drive" }
        gotoProcedure:
            comment                     : "The goto procedure"
            arguments:
                config                      : {}
                motorAxis                   : {}
                motorDrive                  : {}
                target                      : {}
                positiveLimitSwitchActive   : {}
                negativeLimitSwitchActive   : {}
                actualPosition              : {}
                actualPositionError         : {}
            attributes:
                isGotoAllowed               : {}
                statuses:
                    attributes:
                        healthStatus        : { type: COMMONLIB.HealthStatus }
                        busyStatus          : { type: COMMONLIB.BusyStatus   }
        homingProcedure:
            comment                     : "The homing procedure"
            arguments:
                config                      : {}
                motorAxis                   : {}
                motorDrive                  : {}
                target                      : {}
                positiveLimitSwitchActive   : {}
                negativeLimitSwitchActive   : {}
                actualPosition              : {}
                actualPositionError         : {}
            attributes:
                statuses:
                    attributes:
                        healthStatus        : { type: COMMONLIB.HealthStatus }
                        busyStatus          : { type: COMMONLIB.BusyStatus   }
    statuses:
        healthStatus                    : { type: COMMONLIB.HealthStatus }
        busyStatus                      : { type: COMMONLIB.BusyStatus }
    processes:
        goto                            : { type: THISLIB.M3TranslationGoto     , comment: "Start moving the translation stage to the given position" }
        reset                           : { type: COMMONLIB.Process             , comment: "Reset any errors" }
        abort                           : { type: COMMONLIB.Process             , comment: "Abort any running procedures" }
        startHoming                     : { type: COMMONLIB.Process             , comment: "Start the homing procedure" }
    calls:
        actualPosition:
            newMillimetersValue         : -> self.parts.motorAxis.actPos.millimeters.value
        actualPositionError:
            newMillimetersValue         : -> SUB(self.actualPosition.millimeters.value, self.target.position.millimeters.value)
        target:
            knownPositions              : -> self.m3Config.knownPositions
        motorAxis:
            isEnabled                   : -> AND(self.operatorStatus.tech, self.initializationStatus.initialized)
            standstillTolerance         : -> self.config.standstillTolerance
            isGearingSupported          : -> FALSE
        motorDrive:
            isEnabled                   : -> AND(self.operatorStatus.tech, self.initializationStatus.initialized)
            config                      : -> self.config.motorDrive
        busyStatus:
            isBusy                      : -> self.parts.motorAxis.statuses.busyStatus.busy
        healthStatus:
            isGood                      : -> MTCS_SUMMARIZE_GOOD( self.parts.motorAxis,
                                                                  self.parts.motorDrive,
                                                                  self.parts.homingProcedure,
                                                                  self.parts.gotoProcedure )
            hasWarning                  : -> MTCS_SUMMARIZE_WARN( self.parts.motorAxis,
                                                                     self.parts.motorDrive,
                                                                     self.parts.homingProcedure,
                                                                     self.parts.gotoProcedure )
        goto:
            isEnabled                   : ->  AND(self.operatingStatus.manual,
                                                  self.initializationStatus.initialized,
                                                  self.parts.gotoProcedure.isGotoAllowed )
        gotoProcedure:
            config                      : -> self.config
            motorAxis                   : -> self.parts.motorAxis
            motorDrive                  : -> self.parts.motorDrive
            target                      : -> self.target
            positiveLimitSwitchActive   : -> self.positiveLimitSwitchActive
            negativeLimitSwitchActive   : -> self.negativeLimitSwitchActive
            actualPosition              : -> self.actualPosition
            actualPositionError         : -> self.actualPositionError
        homingProcedure:
            config                      : -> self.config
            motorAxis                   : -> self.parts.motorAxis
            motorDrive                  : -> self.parts.motorDrive
            target                      : -> self.target
            positiveLimitSwitchActive   : -> self.positiveLimitSwitchActive
            negativeLimitSwitchActive   : -> self.negativeLimitSwitchActive
            actualPosition              : -> self.actualPosition
            actualPositionError         : -> self.actualPositionError
        reset:
            isEnabled                   : -> self.statuses.healthStatus.bad
        abort:
            isEnabled                   : -> OR(self.parts.gotoProcedure.statuses.busyStatus.busy,
                                                self.parts.homingProcedure.statuses.busyStatus.busy)
        startHoming:
            isEnabled                   : -> AND(self.operatingStatus.manual, self.initializationStatus.initialized )


########################################################################################################################
# M3TranslationGotoProcedure
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB, "M3TranslationGotoProcedure",
    typeOf: [ THISLIB.M3TranslationParts.gotoProcedure ]
    variables:
        state                       : { type: THISLIB.M3TranslateProcedureStates    , comment: "New state, to be set by the manual implementation" }
    variables_read_only:
        isGotoAllowed               : { type: t_bool                                , comment: "TRUE if a goto command is allowed" }
    references:
        config                      : { type: THISLIB.M3TranslationConfig           ,  expand: false }
        motorAxis                   : { type: COMMONLIB.LinearAxis                  ,  expand: false }
        motorDrive                  : { type: COMMONLIB.FaulhaberDrive              ,  expand: false }
        target                      : { type: THISLIB.M3TranslationTarget           ,  expand: false }
        positiveLimitSwitchActive   : { type: t_bool }
        negativeLimitSwitchActive   : { type: t_bool }
        actualPosition              : { type: COMMONLIB.LinearPosition              ,  expand: false }
        actualPositionError         : { type: COMMONLIB.LinearPosition              ,  expand: false }
    statuses:
        busyStatus                  : { type: COMMONLIB.BusyStatus                  , comment: "Is the M3GotoProcedure in a busy state?" }
        healthStatus                : { type: COMMONLIB.HealthStatus                , comment: "Is the M3GotoProcedure in a healthy state?" }
    calls:
        busyStatus:
            isBusy                  : -> NOT( OR( EQ(self.state, THISLIB.M3TranslateProcedureStates.IDLE),
                                                  EQ(self.state, THISLIB.M3TranslateProcedureStates.ABORTED),
                                                  EQ(self.state, THISLIB.M3TranslateProcedureStates.ERROR) ) )
        healthStatus:
            isGood                  : -> NOT( EQ(self.state, THISLIB.M3TranslateProcedureStates.ERROR) )
            hasWarning              : -> EQ(self.state, THISLIB.M3TranslateProcedureStates.ABORTED)


########################################################################################################################
# M3TranslationHomingProcedure
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB, "M3TranslationHomingProcedure",
    typeOf: [ THISLIB.M3TranslationParts.homingProcedure ]
    variables:
        state                       : { type: THISLIB.M3TranslationHomingProcedureStates    , comment: "State to be set by the manual implementation" }
    references:
        config                      : { type: THISLIB.M3TranslationConfig           ,  expand: false }
        motorAxis                   : { type: COMMONLIB.LinearAxis                  ,  expand: false }
        motorDrive                  : { type: COMMONLIB.FaulhaberDrive              ,  expand: false }
        target                      : { type: THISLIB.M3TranslationTarget           ,  expand: false }
        positiveLimitSwitchActive   : { type: t_bool }
        negativeLimitSwitchActive   : { type: t_bool }
        actualPosition              : { type: COMMONLIB.LinearPosition              ,  expand: false }
        actualPositionError         : { type: COMMONLIB.LinearPosition              ,  expand: false }
    statuses:
        busyStatus                  : { type: COMMONLIB.BusyStatus                  , comment: "Is the M3GotoProcedure in a busy state?" }
        healthStatus                : { type: COMMONLIB.HealthStatus                , comment: "Is the M3GotoProcedure in a healthy state?" }
    calls:
        busyStatus:
            isBusy                  : -> NOT( OR( EQ(self.state, THISLIB.M3TranslationHomingProcedureStates.IDLE),
                                                  EQ(self.state, THISLIB.M3TranslationHomingProcedureStates.ABORTED),
                                                  EQ(self.state, THISLIB.M3TranslationHomingProcedureStates.ERROR) ) )
        healthStatus:
            isGood                  : -> NOT( EQ(self.state, THISLIB.M3TranslationHomingProcedureStates.ERROR) )
            hasWarning              : -> EQ(self.state, THISLIB.M3TranslationHomingProcedureStates.ABORTED)


########################################################################################################################
# M3IO
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB, "M3IO",
    typeOf              : [ THISLIB.M3Parts.io ]
    statuses:
        healthStatus    : { type: COMMONLIB.HealthStatus   , comment: "Is the I/O in a healthy state?"  }
    parts:
        canOpenBus      : { type: COMMONLIB.CANopenBus     , comment: "CANopen bus" }
        coupler         : { type: COMMONLIB.EtherCatDevice , comment: "Coupler" }
        slot1           : { type: COMMONLIB.EtherCatDevice , comment: "Slot 1" }
        slot2           : { type: COMMONLIB.EtherCatDevice , comment: "Slot 2" }
        slot3           : { type: COMMONLIB.EtherCatDevice , comment: "Slot 3" }
        slot4           : { type: COMMONLIB.EtherCatDevice , comment: "Slot 4" }
    calls:
        coupler:
            id          : -> STRING("COUPLER") "id"
            typeId      : -> STRING("EK1101") "typeId"
        slot1:
            id          : -> STRING("IODI1") "id"
            typeId      : -> STRING("EL1088") "typeId"
        slot2:
            id          : -> STRING("IOEN1") "id"
            typeId      : -> STRING("EL5101") "typeId"
        slot3:
            id          : -> STRING("IOEN2") "id"
            typeId      : -> STRING("EL5001") "typeId"
        slot4:
            id          : -> STRING("IOCO1") "id"
            typeId      : -> STRING("EL6751") "typeId"
        healthStatus:
            isGood      : -> MTCS_SUMMARIZE_GOOD( self.parts.coupler,
                                                  self.parts.slot1,
                                                  self.parts.slot2,
                                                  self.parts.slot3,
                                                  self.parts.slot4 )
            hasWarning : -> MTCS_SUMMARIZE_WARN( self.parts.coupler,
                                                    self.parts.slot1,
                                                    self.parts.slot2,
                                                    self.parts.slot3,
                                                    self.parts.slot4 )


########################################################################################################################
# Write the model to file
########################################################################################################################

m3_soft.WRITE "models/mtcs/m3/software.jsonld"

