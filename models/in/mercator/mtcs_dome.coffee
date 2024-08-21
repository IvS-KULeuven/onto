##########################################################################
#                                                                        #
# Model of the dome software.                                           #
#                                                                        #
##########################################################################

require "ontoscript"

# models
REQUIRE "models/mtcs/common/software.coffee"
REQUIRE "models/util/softwarefactories.coffee"
REQUIRE "models/mtcs/safety/software.coffee"

MODEL "http://www.mercator.iac.es/onto/models/mtcs/dome/software" : "dome_soft"

dome_soft.IMPORT common_soft
dome_soft.IMPORT safety_soft

##########################################################################
# Define the containing PLC library
##########################################################################

dome_soft.ADD MTCS_MAKE_LIB "mtcs_dome"

# make aliases (with scope of this file only)
COMMONLIB = common_soft.mtcs_common
THISLIB   = dome_soft.mtcs_dome
SAFETYLIB = safety_soft.mtcs_safety


##########################################################################
# DomeConfig
##########################################################################

MTCS_MAKE_CONFIG THISLIB, "DomeConfig",
  items:
    shutter                 : { comment: "The config of the shutter mechanism" }
    rotation                : { comment: "The config of the rotation system" }
    light                   : { comment: "The config of the light in the dome" }
    maxTrackingDistance     : { comment: "The maximum distance between telescope and dome while tracking",  type: t_double }
    trackingLoopTime        : { type: t_double, comment: "Loop time, in seconds, of the tracking." }
    knownPositions          : { comment: "The known positions of the dome" }
    knownPositionTolerance  : { type: t_double  , comment: "Tolerance (in degrees) to determine if the dome is at a known position" }


########################################################################################################################
# DomeKnownPositionConfig
########################################################################################################################
MTCS_MAKE_CONFIG THISLIB, "DomeKnownPositionConfig",
    items:
        name:
            type: t_string
            comment: "The name of the position (e.g. 'PARK')"
        position:
            type: t_double
            comment: "Azimuth in degrees"


########################################################################################################################
# DomeKnownPositionsConfig
########################################################################################################################
MTCS_MAKE_CONFIG THISLIB, "DomeKnownPositionsConfig",
    typeOf: THISLIB.DomeConfig.knownPositions
    items:
        position0     : { type: THISLIB.DomeKnownPositionConfig, comment : "Known position 0"   , expand: false }
        position1     : { type: THISLIB.DomeKnownPositionConfig, comment : "Known position 1"   , expand: false }
        position2     : { type: THISLIB.DomeKnownPositionConfig, comment : "Known position 2"   , expand: false }
        position3     : { type: THISLIB.DomeKnownPositionConfig, comment : "Known position 3"   , expand: false }
        position4     : { type: THISLIB.DomeKnownPositionConfig, comment : "Known position 4"   , expand: false }
        position5     : { type: THISLIB.DomeKnownPositionConfig, comment : "Known position 5"   , expand: false }
        position6     : { type: THISLIB.DomeKnownPositionConfig, comment : "Known position 6"   , expand: false }
        position7     : { type: THISLIB.DomeKnownPositionConfig, comment : "Known position 7"   , expand: false }
        position8     : { type: THISLIB.DomeKnownPositionConfig, comment : "Known position 8"   , expand: false }
        position9     : { type: THISLIB.DomeKnownPositionConfig, comment : "Known position 9"   , expand: false }


##########################################################################
# DomeShutterConfig
##########################################################################

MTCS_MAKE_CONFIG THISLIB, "DomeShutterConfig",
  typeOf: THISLIB.DomeConfig.shutter
  items:
    wirelessPolling         : { type: t_double, comment: "Polling frequency of the wireless I/O device, in seconds. Negative value = no polling." }
    wirelessIpAddress       : { type: t_string, comment: "IP address of the wireless I/O device" }
    wirelessPort            : { type: t_uint16, comment: "Port of the wireless I/O device" }
    wirelessUnitID          : { type: t_uint8 , comment: "Unit ID the wireless I/O device" }
    wirelessTimeoutSeconds  : { type: t_double, comment: "The timeout of a single command. Does not lead to an error (yet), because we still retry."}
    wirelessRetriesSeconds  : { type: t_double, comment: "The total timeout of the retries. If no valid data is received after this time, then we consider the shutters in error." }
    upperEstimatedOpenTime  : { type: t_double, comment: "Estimated opening time of the upper panel, in seconds"}
    upperEstimatedCloseTime : { type: t_double, comment: "Estimated closing time of the upper panel, in seconds"}
    lowerEstimatedOpenTime  : { type: t_double, comment: "Estimated opening time of the lower panel, in seconds"}
    lowerEstimatedCloseTime : { type: t_double, comment: "Estimated closing time of the lower panel, in seconds"}
    lowerOpenTimeout        : { type: t_double, comment: "Opening timeout of the lower panel, in seconds"}
    lowerCloseTimeout       : { type: t_double, comment: "Closing timeout of the lower panel, in seconds"}
    upperOpenTimeout        : { type: t_double, comment: "Opening timeout of the upper panel, in seconds"}
    upperCloseTimeout       : { type: t_double, comment: "Closing timeout of the upper panel, in seconds"}
    timeAfterStop           : { type: t_double, comment: "Time to wait after a stop command, in seconds"}

##########################################################################
# DomeRotationConfig
##########################################################################

MTCS_MAKE_CONFIG THISLIB, "DomeRotationConfig",
  typeOf: THISLIB.DomeConfig.rotation
  items:
    maxMovingVelocity             : { type: t_double, comment: "Maximum velocity when moving absolute or relative, in degrees per second" }
    maxMasterSlaveLag             : { type: t_double, comment: "Below this lag value (in degrees), the lag is considered not an error" }
    torqueCoefficientV            : { type: t_double, comment: "Coefficient v in 'SlaveTorque = v * MasterVelo + a * MasterAcceleration" }
    torqueCoefficientA            : { type: t_double, comment: "Coefficient a in 'SlaveTorque = v * MasterVelo + a * MasterAcceleration" }
    homePosition                  : { type: t_double, comment: "Azimuth position of the home sensor, in degrees" }
    homingMoveOutOfSensorDistance : { type: t_double, comment: "If on the sensor, move this distance, in degrees" }
    homingStage1Velocity          : { type: t_double, comment: "Velocity, in degrees per second, of the first homing stage" }
    homingStage1Timeout           : { type: t_double, comment: "Timeout of the first homing stage, in seconds" }
    homingStage2Velocity          : { type: t_double, comment: "Velocity, in degrees per second, of the second homing stage" }
    homingStage2Timeout           : { type: t_double, comment: "Timeout of the second homing stage, in seconds" }
    homingDoTwoStages             : { type: t_bool  , comment: "True for 2-stages homing, False for 1-stage homing." }
    quickStopDeceleration         : { type: t_double, comment: "Quick stop deceleration, in degrees/sec2"}
    quickStopJerk                 : { type: t_double, comment: "Quick stop jerk, in degrees/sec3"}



##########################################################################
# DomeLightConfig
##########################################################################

MTCS_MAKE_CONFIG THISLIB, "DomeLightConfig",
  typeOf: THISLIB.DomeConfig.light
  items:
    timeDomeLightOn             : { type: t_double, comment: "Time to keep the light on, in seconds" }
    enableDomeLight             : { type: t_bool  , comment: "True for enabling the control of the light" }


########################################################################################################################
# DomeMoveKnownPositionProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "DomeMoveKnownPositionProcess",
    extends: COMMONLIB.BaseProcess
    arguments:
        name        : { type: t_string  , comment: "Name of the position to move to"}


########################################################################################################################
# Dome
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB, "Dome",
  variables:
    editableConfig              : { type: THISLIB.DomeConfig                , comment: "Editable configuration of the cover" }
  references:
    operatorStatus              : { type: COMMONLIB.OperatorStatus          , comment: "Reference to the operator (observer/tech)"}
    activityStatus              : { type: COMMONLIB.ActivityStatus          , comment: "Shared activity status"}
    aziTargetPos                : { type: COMMONLIB.AngularPosition         , comment: "Azimuth target position of the telescope Axes"}
    safetyDomeShutter           : { type: SAFETYLIB.SafetyDomeShutter       , comment: "Reference to the dome shutter safety", expand: false }
    safetyMotionBlocking        : { type: SAFETYLIB.SafetyMotionBlocking    , comment: "Reference to the motion blocking safety", expand: false }
    safetyDomeAccess            : { type: SAFETYLIB.SafetyDomeAccess        , comment: "Reference to the dome access safety", expand: false }
  variables_read_only:
    config                      : { type: THISLIB.DomeConfig                , comment: "Active configuration of the cover" }
    isPoweredOffByPersonInDome  : { type: t_bool                            , comment: "True if the dome is powered off due to a person entering the dome" }
    isTracking                  : { type: t_bool                            , comment: "True if the dome is tracking the telescope" }
    telescopeTargetDistance     : { type: COMMONLIB.AngularPosition         , comment: "Actual distance between telescope target and dome" }
    isAtKnownPosition           : { type: t_bool                            , comment: "True if the dome is at a known position" }
    actualKnownPositionName     : { type: t_string                          , comment: "Name of the known position if isAtKnownPosition is True" }
  parts:
    shutter:
      comment                   : "Shutter mechanism"
      arguments:
        initializationStatus    : { comment: "Dome initialization status (initialized/initializing/...)" }
        operatorStatus          : { comment: "MTCS operator (observer/tech)" }
        operatingStatus         : { comment: "Dome operating status (manual/auto)" }
        activityStatus          : { comment: "Shared activity status"}
        safety                  : { comment: "The dome shutter safety" }
        config                  : { comment: "The shutter config" }
      attributes:
        statuses:
          attributes:
            healthStatus        : { type: COMMONLIB.HealthStatus }
            busyStatus          : { type: COMMONLIB.BusyStatus }
    rotation:
      comment                   : "Rotation mechanism"
      arguments:
        initializationStatus    : { comment: "Dome initialization status (initialized/initializing/...)"}
        operatorStatus          : { comment: "MTCS operator (observer/tech)"}
        operatingStatus         : { comment: "Dome operating status (manual/auto)"}
        config                  : { comment: "The rotation config"}
      attributes:
        isHomed                 : {type: t_bool}
        statuses:
          attributes:
            healthStatus        : { type: COMMONLIB.HealthStatus }
            busyStatus          : { type: COMMONLIB.BusyStatus }
            poweredStatus       : { type: COMMONLIB.PoweredStatus }
    light:
      comment                   : "Light in dome"
      arguments:
        initializationStatus    : { comment: "Dome initialization status (initialized/initializing/...)" }
        operatorStatus          : { comment: "MTCS operator (observer/tech)" }
        operatingStatus         : { comment: "Dome operating status (manual/auto)" }
        activityStatus          : { comment: "Shared activity status"}
        config                  : { comment: "The light config" }
        isDomeLightON           : { comment: "True if the light inside the dome is ON" }
      attributes:
        statuses:
          attributes:
            healthStatus        : { type: COMMONLIB.HealthStatus }
            busyStatus          : { type: COMMONLIB.BusyStatus }      
    io:
      comment                   : "EtherCAT devices"
      attributes:
        statuses:
          attributes:
            healthStatus        : { type: COMMONLIB.HealthStatus }
    configManager:
      comment                   : "The config manager (to load/save/activate configuration data)"
      type                      : COMMONLIB.ConfigManager
  statuses:
    initializationStatus        : { type: COMMONLIB.InitializationStatus }
    healthStatus                : { type: COMMONLIB.HealthStatus }
    busyStatus                  : { type: COMMONLIB.BusyStatus }
    operatingStatus             : { type: COMMONLIB.OperatingStatus }
    poweredStatus               : { type: COMMONLIB.PoweredStatus }
  processes:
    initialize                  : { type: COMMONLIB.Process                     , comment: "Start initializing" }
    lock                        : { type: COMMONLIB.Process                     , comment: "Lock the cover" }
    unlock                      : { type: COMMONLIB.Process                     , comment: "Unlock the cover" }
    changeOperatingState        : { type: COMMONLIB.ChangeOperatingStateProcess , comment: "Change the operating state (e.g. AUTO, MANUAL, ...)" }
    reset                       : { type: COMMONLIB.Process                     , comment: "Reset any errors" }
    powerOn                     : { type: COMMONLIB.Process                     , comment: "Power on the dome" }
    powerOff                    : { type: COMMONLIB.Process                     , comment: "Power off the dome" }
    syncWithAxes                : { type: COMMONLIB.Process                     , comment: "Synchronize the dome once with the axes" }
    startTracking               : { type: COMMONLIB.Process                     , comment: "Start tracking the axes" }
    stopTracking                : { type: COMMONLIB.Process                     , comment: "Stop tracking the axes" }
    stop                        : { type: COMMONLIB.Process                     , comment: "Stop the rotation movement and/or tracking" }
    moveKnownPosition           : { type: THISLIB.DomeMoveKnownPositionProcess  , comment: "Move the dome to the given known position" }
  calls:
    # processes
    initialize:
      isEnabled                 : -> AND(NOT(self.statuses.initializationStatus.locked),
                                         OR(self.statuses.initializationStatus.shutdown,
                                            self.statuses.initializationStatus.initializingFailed,
                                            self.statuses.initializationStatus.initialized))
    lock:
      isEnabled                 : -> self.operatorStatus.tech
      
    unlock:
      isEnabled                 : -> AND(self.operatorStatus.tech,
                                         self.statuses.initializationStatus.locked)
    changeOperatingState:
      isEnabled                 : -> FALSE # we currently don't use AUTO/MANUAL
    reset:
      isEnabled                 : -> AND(self.statuses.busyStatus.idle,
                                         self.statuses.initializationStatus.initialized)
    powerOn:
      isEnabled                 : -> AND(NOT(self.statuses.initializationStatus.locked),
                                         self.statuses.initializationStatus.initialized,
                                         self.processes.powerOn.statuses.busyStatus.idle)
    powerOff:
      isEnabled                 : -> AND(self.statuses.initializationStatus.initialized,
                                         self.processes.powerOff.statuses.busyStatus.idle)
    stop:
      isEnabled                 : -> OR(self.statuses.busyStatus.busy, self.isTracking, self.operatorStatus.tech)

    startTracking:
      isEnabled                 : -> AND(self.statuses.poweredStatus.enabled,
                                         NOT(self.isTracking),
                                         self.parts.rotation.isHomed)
    stopTracking:
      isEnabled                 : -> self.isTracking
    moveKnownPosition:
        isEnabled               : -> AND(self.statuses.initializationStatus.initialized,
                                         self.statuses.busyStatus.idle,
                                         self.statuses.poweredStatus.enabled,
                                         self.parts.rotation.isHomed)
    syncWithAxes:
        isEnabled               : -> AND(self.statuses.initializationStatus.initialized,
                                         self.statuses.busyStatus.idle,
                                         self.statuses.poweredStatus.enabled,
                                         self.parts.rotation.isHomed)
    # parts
    shutter:
      initializationStatus      : -> self.statuses.initializationStatus
      operatorStatus            : -> self.operatorStatus
      operatingStatus           : -> self.statuses.operatingStatus
      activityStatus            : -> self.activityStatus
      safety                    : -> self.safetyDomeShutter
      config                    : -> self.config.shutter
    rotation:
      initializationStatus      : -> self.statuses.initializationStatus
      operatorStatus            : -> self.operatorStatus
      operatingStatus           : -> self.statuses.operatingStatus
      config                    : -> self.config.rotation
    light:
      initializationStatus      : -> self.statuses.initializationStatus
      operatorStatus            : -> self.operatorStatus
      operatingStatus           : -> self.statuses.operatingStatus
      activityStatus            : -> self.activityStatus
      config                    : -> self.config.light
    configManager:
      isEnabled                 : -> self.operatorStatus.tech
    # statuses
    poweredStatus:
      isEnabled                 : -> self.parts.rotation.statuses.poweredStatus.enabled
    operatingStatus:
      superState                : -> self.statuses.initializationStatus.initialized
    healthStatus:
      isGood                    : -> MTCS_SUMMARIZE_GOOD(self.parts.shutter,
                                                         self.parts.rotation,
                                                         self.parts.light,
                                                         self.parts.io)

      hasWarning                : -> MTCS_SUMMARIZE_WARN(self.parts.shutter,
                                                           self.parts.rotation,
                                                           self.parts.light,
                                                           self.parts.io)
    busyStatus:
      isBusy                    : -> MTCS_SUMMARIZE_BUSY(self.parts.shutter,
                                                         self.parts.rotation)



########################################################################################################################
# DomeShutter
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB, "DomeShutter",
  typeOf: THISLIB.DomeParts.shutter
  variables:
    lowerOpenSignal         : { type: t_bool                            , comment: "False if the signal is not present OR if there is a communication error" }
    lowerClosedSignal       : { type: t_bool                            , comment: "False if the signal is not present OR if there is a communication error" }
    upperOpenSignal         : { type: t_bool                            , comment: "False if the signal is not present OR if there is a communication error" }
    upperClosedSignal       : { type: t_bool                            , comment: "False if the signal is not present OR if there is a communication error" }
    wirelessTimeout         : { type: t_bool                            , comment: "True if the wireless communication to the shutter signals is timing out" }
    wirelessError           : { type: t_bool                            , comment: "True if the wireless communication to the shutter signals is in error (other than timeout)" }
    wirelessErrorId         : { type: t_uint32                          , comment: "The error id if wirelessError is true" }
    wirelessData            : { type: t_uint16                          , comment: "The received wireless data" }
    upperTimeRemaining      : { type: COMMONLIB.Duration                , comment: "Estimated time remaining to open/close the upper panel" }
    lowerTimeRemaining      : { type: COMMONLIB.Duration                , comment: "Estimated time remaining to open/close the lower panel" }
    isLowerMonitored        : { type: t_bool                            , comment: "TRUE if the lower shutter panel is being monitored" }
    noOfLowerAutoClosings   : { type: t_int16                           , comment: "The number of times that the lower panel has been closed automatically, by monitoring" }
    
    manualOpenUpper         : { type: t_bool          , address: "%I*"  , comment: "Manual operation: open upper switch" }
    manualCloseUpper        : { type: t_bool          , address: "%I*"  , comment: "Manual operation: close upper switch" }
    manualOpenLower         : { type: t_bool          , address: "%I*"  , comment: "Manual operation: open lower switch" }
    manualCloseLower        : { type: t_bool          , address: "%I*"  , comment: "Manual operation: close lower switch" }
    manualPumpOn            : { type: t_bool          , address: "%I*"  , comment: "Manual operation: pump ON" }
    automaticOperation      : { type: t_bool          , address: "%I*"  , comment: "TRUE if switch is on Auto, FALSE if switch is Manual" }
    
  references:
    initializationStatus    : { type: COMMONLIB.InitializationStatus    , comment: "Dome initialization status (initialized/initializing/...)"}
    operatorStatus          : { type: COMMONLIB.OperatorStatus          , comment: "MTCS operator (observer/tech)"}
    operatingStatus         : { type: COMMONLIB.OperatingStatus         , comment: "Dome operating status (manual/auto)"}
    activityStatus          : { type: COMMONLIB.ActivityStatus          , comment: "Shared activity status"}
    safety                  : { type: SAFETYLIB.SafetyDomeShutter       , comment: "The dome shutter safety", expand: false }
    config                  : { type: THISLIB.DomeShutterConfig         , comment: "The shutter config"}
  parts:
    pumpsRelay              : { type: COMMONLIB.SimpleRelay             , comment: "Relay to start the pumps motors" }
    upperOpenRelay          : { type: COMMONLIB.SimpleRelay             , comment: "Relay to open the upper shutter panel" }
    upperCloseRelay         : { type: COMMONLIB.SimpleRelay             , comment: "Relay to close the upper shutter panel" }
    lowerOpenRelay          : { type: COMMONLIB.SimpleRelay             , comment: "Relay to open the upper shutter panel" }
    lowerCloseRelay         : { type: COMMONLIB.SimpleRelay             , comment: "Relay to close the upper shutter panel" }
  statuses:
    apertureStatus          : { type: COMMONLIB.ApertureStatus          , comment: "Combined aperture status (i.e. of both panels)" }
    lowerApertureStatus     : { type: COMMONLIB.ApertureStatus          , comment: "Aperture status of the lower panel" }
    upperApertureStatus     : { type: COMMONLIB.ApertureStatus          , comment: "Aperture status of the upper panel" }
    healthStatus            : { type: COMMONLIB.HealthStatus            , comment: "Health status"}
    busyStatus              : { type: COMMONLIB.BusyStatus              , comment: "Busy status" }
  processes:
    reset                   : { type: COMMONLIB.Process                 , comment: "Reset errors" }
    open                    : { type: COMMONLIB.Process                 , comment: "Open both panels" }
    close                   : { type: COMMONLIB.Process                 , comment: "Close both panels" }
    stop                    : { type: COMMONLIB.Process                 , comment: "Stop the panels" }
    lowerOpen               : { type: COMMONLIB.Process                 , comment: "Open the lower panel" }
    lowerClose              : { type: COMMONLIB.Process                 , comment: "Close the lower panel" }
    upperOpen               : { type: COMMONLIB.Process                 , comment: "Open the upper panel" }
    upperClose              : { type: COMMONLIB.Process                 , comment: "Close the upper panel" }
  calls:
    # processes
    stop:
      isEnabled             : -> self.statuses.busyStatus.busy
    reset:
      isEnabled             : -> TRUE
    open:
      isEnabled             : -> AND(self.statuses.healthStatus.isGood, NOT(self.initializationStatus.locked), 
                                    (OR(self.operatorStatus.tech, AND(self.statuses.busyStatus.idle, self.initializationStatus.initialized, OR(self.activityStatus.awake, self.activityStatus.moving) ) ) ) )
    lowerOpen:
      isEnabled             : -> self.processes.open.isEnabled # same as processes.open
    upperOpen:
      isEnabled             : -> self.processes.open.isEnabled # same as processes.open
    close:
      isEnabled             : -> AND(self.statuses.healthStatus.isGood, NOT(self.initializationStatus.locked), self.statuses.busyStatus.idle, self.initializationStatus.initialized)
    lowerClose:
      isEnabled             : -> self.processes.close.isEnabled # same as processes.close
    upperClose:
      isEnabled             : -> self.processes.close.isEnabled # same as processes.close
    # relays
    pumpsRelay:
      isEnabled             : -> self.operatorStatus.tech
    upperOpenRelay:
      isEnabled             : -> self.operatorStatus.tech
    upperCloseRelay:
      isEnabled             : -> self.operatorStatus.tech
    lowerOpenRelay:
      isEnabled             : -> self.operatorStatus.tech
    lowerCloseRelay:
      isEnabled             : -> self.operatorStatus.tech
    # statuses
    lowerApertureStatus:
      superState            : -> NOT(OR(self.wirelessTimeout,self.wirelessError))
      isOpen                : -> self.lowerOpenSignal
      isClosed              : -> self.lowerClosedSignal
    upperApertureStatus:
      superState            : -> NOT(OR(self.wirelessTimeout,self.wirelessError))
      isOpen                : -> self.upperOpenSignal
      isClosed              : -> self.upperClosedSignal
    apertureStatus:
      superState            : -> NOT(OR(self.wirelessTimeout,self.wirelessError))
      isOpen                : -> AND(self.statuses.lowerApertureStatus.open     , self.statuses.upperApertureStatus.open )
      isClosed              : -> AND(self.statuses.lowerApertureStatus.closed   , self.statuses.upperApertureStatus.closed )
    healthStatus:
      isGood                : -> AND(
                                    NOT(OR(self.wirelessTimeout,self.wirelessError)),
                                    MTCS_SUMMARIZE_GOOD(self.processes.reset,
                                                        self.processes.open,
                                                        self.processes.close,
                                                        self.processes.stop,
                                                        self.processes.lowerOpen,
                                                        self.processes.lowerClose,
                                                        self.processes.upperOpen,
                                                        self.processes.upperClose ))
      hasWarning            : -> OR(
                                     MTCS_SUMMARIZE_WARN( self.processes.reset,
                                                          self.processes.open,
                                                          self.processes.close,
                                                          self.processes.stop,
                                                          self.processes.lowerOpen,
                                                          self.processes.lowerClose,
                                                          self.processes.upperOpen,
                                                          self.processes.upperClose ),
                                     AND(self.statuses.busyStatus.idle, self.statuses.lowerApertureStatus.partiallyOpen),
                                     AND(self.statuses.busyStatus.idle, self.statuses.upperApertureStatus.partiallyOpen),
                                     NOT(self.automaticOperation))
    busyStatus:
      isBusy                : -> MTCS_SUMMARIZE_BUSY( self.processes.reset,
                                                      self.processes.open,
                                                      self.processes.close,
                                                      self.processes.stop,
                                                      self.processes.lowerOpen,
                                                      self.processes.lowerClose,
                                                      self.processes.upperOpen,
                                                      self.processes.upperClose )
########################################################################################################################
# DomeMoveProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "DomeMoveProcess",
    extends: COMMONLIB.BaseProcess
    arguments:
        position     : { type: t_double, comment: "New absolute or relative position value in degrees" }


########################################################################################################################
# DomeRotation
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB, "DomeRotation",
  typeOf: THISLIB.DomeParts.rotation
  variables_read_only:
    actPos                      : { type: COMMONLIB.AngularPosition         , comment: "The actual position (same as parts.masterAxis!)", expand: false }
    actVelo                     : { type: COMMONLIB.AngularVelocity         , comment: "The actual velocity (same as parts.masterAxis!)", expand: false }
    actTorqueMaster             : { type: COMMONLIB.Torque                  , comment: "The actual torque on the telescope axis by the master motor", expand: false }
    actTorqueSlave              : { type: COMMONLIB.Torque                  , comment: "The actual torque on the telescope axis by the slave motor", expand: false }
    masterSlaveLag              : { type: COMMONLIB.AngularPosition         , comment: "masterAxis.actPos - slaveAxis.actPos" }
    masterSlaveLagError         : { type: t_bool                            , comment: "(ABS(masterSlaveLag) >= config.maxMasterSlaveLag) AND isHomed AND poweredOn" }
    homingSensorSignal          : { type: t_bool                            , comment: "True = at home position"}
    isHomed                     : { type: t_bool                            , comment: "True if homing was done" }
  references:
    initializationStatus        : { type: COMMONLIB.InitializationStatus    , comment: "Reference to the MTCS initialization status"}
    operatorStatus              : { type: COMMONLIB.OperatorStatus          , comment: "Reference to the MTCS operator status"}
    operatingStatus             : { type: COMMONLIB.OperatingStatus         , comment: "Reference to the Dome operating status"}
    config                      : { type: THISLIB.DomeRotationConfig        , comment: "Reference to the rotation config"}
  parts:
    masterAxis                  : { type: COMMONLIB.AngularAxis             , comment: "Master axis" }
    slaveAxis                   : { type: COMMONLIB.AngularAxis             , comment: "Slave axis" }
    drive                       : { type: COMMONLIB.AX52XXDrive             , comment: "Dual axis drive" }
  statuses:
    healthStatus                : { type: COMMONLIB.HealthStatus            , comment: "Health status"}
    busyStatus                  : { type: COMMONLIB.BusyStatus              , comment: "Busy status" }
    poweredStatus               : { type: COMMONLIB.PoweredStatus           , comment: "Powered status" }
  processes:
    reset                       : { type: COMMONLIB.Process                 , comment: "Reset errors" }
    stop                        : { type: COMMONLIB.Process                 , comment: "Stop the rotation" }
    moveAbsolute                : { type: THISLIB.DomeMoveProcess           , comment: "Move absolute" }
    moveRelative                : { type: THISLIB.DomeMoveProcess           , comment: "Move relative" }
    home                        : { type: COMMONLIB.Process                 , comment: "Perform a homing" }
    powerOn                     : { type: COMMONLIB.Process                 , comment: "Power on master and slave" }
    powerOff                    : { type: COMMONLIB.Process                 , comment: "Power off master and slave" }
  calls:
    reset:
      isEnabled                 : -> self.statuses.busyStatus.idle
    stop:
      isEnabled                 : -> OR(self.statuses.busyStatus.busy, self.operatorStatus.tech)
    moveAbsolute:
      isEnabled                 : -> AND(self.statuses.busyStatus.idle, self.statuses.poweredStatus.enabled)
    moveRelative:
      isEnabled                 : -> self.processes.moveAbsolute.isEnabled # same as moveAbsolute
    home:
      isEnabled                 : -> self.processes.moveAbsolute.isEnabled # same as moveAbsolute
    powerOn:
      isEnabled                 : -> AND(NOT(self.initializationStatus.locked), self.statuses.busyStatus.idle)
    powerOff:
      isEnabled                 : -> self.statuses.busyStatus.idle
    # parts
    masterAxis:
      isEnabled                 : -> AND(NOT(self.initializationStatus.locked), self.operatorStatus.tech)
    slaveAxis:
      isEnabled                 : -> AND(NOT(self.initializationStatus.locked), self.operatorStatus.tech)
    drive:
      isEnabled                 : -> AND(NOT(self.initializationStatus.locked), self.operatorStatus.tech)
    # statuses
    poweredStatus:
      isEnabled             : -> AND(self.parts.masterAxis.statuses.poweredStatus.enabled,
                                     self.parts.slaveAxis.statuses.poweredStatus.enabled)
    healthStatus:
      isGood                : -> AND(
                                    MTCS_SUMMARIZE_GOOD(self.parts.masterAxis,
                                                        self.parts.slaveAxis,
                                                        self.parts.drive,
                                                        self.processes.reset,
                                                        self.processes.stop),
                                    NOT(self.masterSlaveLagError),
                                    OR(self.isHomed, NOT(self.initializationStatus.initialized)))
      hasWarning            : -> MTCS_SUMMARIZE_WARN(self.parts.masterAxis,
                                                     self.parts.slaveAxis,
                                                     self.parts.drive,
                                                     self.processes.reset,
                                                     self.processes.stop)
    busyStatus:
      isBusy                : -> MTCS_SUMMARIZE_BUSY(self.parts.masterAxis,
                                                     self.parts.slaveAxis,
                                                     self.parts.drive,
                                                     self.processes.reset,
                                                     self.processes.stop)



########################################################################################################################
# DomeLight
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB, "DomeLight",
  typeOf: THISLIB.DomeParts.light
  variables:
    switchOnSignal          : { type: t_bool                            , comment: "True if the light must be switched ON" }  
    
    switchOnInput           : { type: t_bool          , address: "%I*"  , comment: "External operation: switch ON" }
    
    isDomeLightON           : { type: t_bool                            , comment: "Flag to indicate if dome light is ON or OFF" }


  references:
    initializationStatus    : { type: COMMONLIB.InitializationStatus    , comment: "Dome initialization status (initialized/initializing/...)"}
    operatorStatus          : { type: COMMONLIB.OperatorStatus          , comment: "MTCS operator (observer/tech)"}
    operatingStatus         : { type: COMMONLIB.OperatingStatus         , comment: "Dome operating status (manual/auto)"}
    activityStatus          : { type: COMMONLIB.ActivityStatus          , comment: "Shared activity status"}
    config                  : { type: THISLIB.DomeLightConfig           , comment: "The light config"}
  parts:
    switchOnRelay           : { type: COMMONLIB.SimpleRelay             , comment: "Relay to switch on the light" }
  statuses:
    healthStatus            : { type: COMMONLIB.HealthStatus            , comment: "Health status"}
    busyStatus              : { type: COMMONLIB.BusyStatus              , comment: "Busy status" }
  processes:
    reset                   : { type: COMMONLIB.Process                 , comment: "Reset errors" }
    switchLightOn           : { type: COMMONLIB.Process                 , comment: "Turn On the light in the dome" }
    switchLightOff          : { type: COMMONLIB.Process                 , comment: "Turn Off the light in the dome" }
  calls:
    # processes
    reset:
      isEnabled             : -> TRUE
    switchLightOn:
      isEnabled             : -> TRUE
    switchLightOff:
      isEnabled             : -> TRUE
    # relays
    switchOnRelay:
      isEnabled             : -> self.operatorStatus.tech
    # statuses
    healthStatus:
      isGood                : -> MTCS_SUMMARIZE_GOOD(self.processes.reset,
                                                     self.processes.switchLightOn,
                                                     self.processes.switchLightOff)
      hasWarning            : -> OR(self.isDomeLightON, MTCS_SUMMARIZE_WARN(self.processes.reset,
                                                                             self.processes.switchLightOn,
                                                                             self.processes.switchLightOff))
    busyStatus:
      isBusy                : -> MTCS_SUMMARIZE_BUSY(self.processes.reset,
                                                     self.processes.switchLightOn,
                                                     self.processes.switchLightOff)


########################################################################################################################
# DomeIO
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB, "DomeIO",
  typeOf        : [ THISLIB.DomeParts.io ]
  statuses:
    healthStatus  : { type: COMMONLIB.HealthStatus   , comment: "Is the I/O in a healthy state?"  }
  parts:
    coupler     : { type: COMMONLIB.EtherCatDevice , comment: "Coupler" }
    slot1       : { type: COMMONLIB.EtherCatDevice , comment: "Slot 1" }
    slot2       : { type: COMMONLIB.EtherCatDevice , comment: "Slot 2" }
    slot3       : { type: COMMONLIB.EtherCatDevice , comment: "Slot 3" }
    slot4       : { type: COMMONLIB.EtherCatDevice , comment: "Slot 4" }    
    drive       : { type: COMMONLIB.EtherCatDevice , comment: "Drive" }
  calls:
    coupler:
      id      : -> STRING("110A1") "id"
      typeId    : -> STRING("EK1101") "typeId"
    slot1:
      id      : -> STRING("111A0") "id"
      typeId    : -> STRING("ES1008") "typeId"
    slot2:
      id      : -> STRING("112A0") "id"
      typeId    : -> STRING("EL2904") "typeId"
    slot3:
      id      : -> STRING("112A5") "id"
      typeId    : -> STRING("EL2904") "typeId"
    slot4:
      id      : -> STRING("DO:RO1") "id"
      typeId    : -> STRING("EL2622") "typeId"
    drive:
      id      : -> STRING("10U1") "id"
      typeId    : -> STRING("AX5206") "typeId"
    healthStatus:
      isGood    : -> MTCS_SUMMARIZE_GOOD(
                          self.parts.coupler,
                          self.parts.slot1,
                          self.parts.slot2,
                          self.parts.slot3,
                          self.parts.slot4,
                          self.parts.drive )


########################################################################################################################
# Write the model to file
########################################################################################################################

dome_soft.WRITE "models/mtcs/dome/software.jsonld"
