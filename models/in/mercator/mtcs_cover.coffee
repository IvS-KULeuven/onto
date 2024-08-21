##########################################################################
#                                                                        #
# Model of the cover software.                                           #
#                                                                        #
##########################################################################

require "ontoscript"

# models
REQUIRE "models/mtcs/common/software.coffee"
REQUIRE "models/util/softwarefactories.coffee"

MODEL "http://www.mercator.iac.es/onto/models/mtcs/cover/software" : "cover_soft"

cover_soft.IMPORT common_soft

##########################################################################
# Define the containing PLC library
##########################################################################

cover_soft.ADD MTCS_MAKE_LIB "mtcs_cover"

# make aliases (with scope of this file only)
COMMONLIB = common_soft.mtcs_common
THISLIB   = cover_soft.mtcs_cover


##########################################################################
# CoverApertureProcedureStates
##########################################################################

MTCS_MAKE_ENUM THISLIB, "CoverApertureProcedureStates",
  comment: "The disjoint states of the opening and closing procedure"
  items:
    [ "IDLE",
      "ABORTED",
      "PREPARE_PROCESS",
      "ENABLING_RELAYS",
      "ENABLING_MOTORS",
      "ENABLING_MAGNETS",
      "DISABLING_RELAYS",
      "DISABLING_MOTORS",
      "DISABLING_MAGNETS",
      "OPENING_TOP_PANELS",
      "OPENING_BOTH_PANELS",
      "CLOSING_BOTTOM_PANELS",
      "CLOSING_BOTH_PANELS",
      "ERROR",
      "RESETTING",
      "ABORTING"
    ]


##########################################################################
# CoverConfig
###########################################################################

MTCS_MAKE_CONFIG THISLIB, "CoverConfig",
  items:
    top   : { comment: "The config of the top panel set" }
    bottom  : { comment: "The config of the bottom panel set" }
    openingVelocity:
      comment: "The opening velocity of the panels in degrees per second (always positive!)"
      type:  t_double
      initial: double(20.0)
    closingVelocity:
      comment: "The closing velocity of the panels in degrees per second (always positive!)"
      type:  t_double
      initial: double(20.0)
    magnetRemanentTime:
      comment: "How many seconds should be waited after disabling a magnet, before a panel may move?"
      type:  t_double
      initial: double(3.0)
    targetDistanceBetweenPanelSets:
      comment: "The minimum distance in degrees between both panelsets"
      type:  t_double
    minDistanceBetweenPanelSets:
      comment: "The minimum distance in degrees between both panelsets"
      type:  t_double
    unsafeRangeMinElevation:
      comment: "The minimum elevation of the unsafe range"
      type:  t_double
    unsafeRangeMinAzimuth:
      comment: "The minimum azimuth of the unsafe range"
      type:  t_double
    unsafeRangeMaxAzimuth:
      comment: "The maximum azimuth of the unsafe range"
      type:  t_double


########################################################################################################################
# Cover
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB, "Cover",
  variables:
    editableConfig          : { type: THISLIB.CoverConfig               , comment: "Editable configuration of the cover" }
  references:
    operatorStatus          : { type: COMMONLIB.OperatorStatus }
    aziPos                  : { type: COMMONLIB.AngularPosition         , comment: "Actual azimuth position of the telescope"}
    elePos                  : { type: COMMONLIB.AngularPosition         , comment: "Actual elevation position of the telescope"}
  variables_read_only:
    config                  : { type: THISLIB.CoverConfig               , comment: "Active configuration of the cover" }
    currentMeasurement      : { type: COMMONLIB.CurrentMeasurement      , comment: "The current measurement of the selected panels" }
    safeToOpenOrClose       : { type: t_bool                            , comment: "True if safe to open or close!" }
  parts:
    top:
      comment               : "TOP panels"
      arguments:
        initializationStatus: { type: COMMONLIB.InitializationStatus    , expand: false }
        operatingStatus     : { type: COMMONLIB.OperatingStatus         , expand: false }
        operatorStatus      : { type: COMMONLIB.OperatorStatus          , expand: false }
      attributes:
        config              : {}
        coverConfig         : { type: THISLIB.CoverConfig               , expand: false  }
        statuses:
          attributes:
            apertureStatus  : { type: COMMONLIB.ApertureStatus }
            healthStatus    : { type: COMMONLIB.HealthStatus }
            busyStatus      : { type: COMMONLIB.BusyStatus }
    bottom:
      comment               : "BOTTOM panels"
      arguments:
        initializationStatus: { type: COMMONLIB.InitializationStatus    , expand: false }
        operatingStatus     : { type: COMMONLIB.OperatingStatus         , expand: false }
        operatorStatus      : { type: COMMONLIB.OperatorStatus          , expand: false }
      attributes:
        config              : {}
        coverConfig         : { type: THISLIB.CoverConfig               , expand: false }
        statuses:
          attributes:
            apertureStatus  : { type: COMMONLIB.ApertureStatus }
            healthStatus    : { type: COMMONLIB.HealthStatus }
            busyStatus      : { type: COMMONLIB.BusyStatus }
    io:
      comment               : "I/O modules"
      attributes:
        statuses:
          attributes:
            healthStatus    : { type: COMMONLIB.HealthStatus }
    apertureProcedure:
      comment               : "The closing/opening/... procedure"
      arguments:
        top                 : {}
        bottom              : {}
        coverConfig         : {}
      attributes:
        state               : {}
        statuses:
          attributes:
            healthStatus    : { type: COMMONLIB.HealthStatus }
            busyStatus      : { type: COMMONLIB.BusyStatus }
    configManager:
      comment               : "The config manager (to load/save/activate configuration data)"
      type                  : COMMONLIB.ConfigManager
  statuses:
    initializationStatus    : { type: COMMONLIB.InitializationStatus }
    apertureStatus          : { type: COMMONLIB.ApertureStatus }
    healthStatus            : { type: COMMONLIB.HealthStatus }
    busyStatus              : { type: COMMONLIB.BusyStatus }
    operatingStatus         : { type: COMMONLIB.OperatingStatus }
  processes:
    initialize              : { type: COMMONLIB.Process             , comment: "Start initializing" }
    lock                    : { type: COMMONLIB.Process             , comment: "Lock the cover" }
    unlock                  : { type: COMMONLIB.Process             , comment: "Unlock the cover" }
    reset                   : { type: COMMONLIB.Process             , comment: "Reset any errors" }
    changeOperatingState    : { type: COMMONLIB.ChangeOperatingStateProcess   , comment: "Change the operating state (e.g. AUTO, MANUAL, ...)" }
    open                    : { type: COMMONLIB.Process             , comment: "Start opening the cover (only enabled in AUTO mode!)" }
    close                   : { type: COMMONLIB.Process             , comment: "Start closing the cover (only enabled in AUTO mode!)" }
    forceOpen               : { type: COMMONLIB.Process             , comment: "Start opening the cover EVEN IF WE'RE IN THE UNSAFE REGION" }
    forceClose              : { type: COMMONLIB.Process             , comment: "Start closing the cover EVEN IF WE'RE IN THE UNSAFE REGION" }
    abort                   : { type: COMMONLIB.Process             , comment: "Abort opening/closing the cover (only enabled in AUTO mode!)" }
  calls:
    currentMeasurement:
      {} # just update
    initialize:
      isEnabled       : -> OR(self.statuses.initializationStatus.shutdown,
                              self.statuses.initializationStatus.initializingFailed,
                              self.statuses.initializationStatus.initialized)
    lock:
      isEnabled       : -> AND(self.operatorStatus.tech, self.statuses.initializationStatus.initialized)
    unlock:
      isEnabled       : -> AND(self.operatorStatus.tech, self.statuses.initializationStatus.locked)
    changeOperatingState:
      isEnabled       : -> AND(self.statuses.busyStatus.idle, self.statuses.initializationStatus.initialized)
    forceOpen:
      isEnabled       : -> AND(OR(self.statuses.busyStatus.idle,
                              AND(self.statuses.busyStatus.busy,
                                EQ(self.parts.apertureProcedure.state, THISLIB.CoverApertureProcedureStates.CLOSING_BOTH_PANELS))),
                             self.statuses.initializationStatus.initialized,
                             self.statuses.operatingStatus.auto,
                             NOT(self.statuses.apertureStatus.open) )
    forceClose:
      isEnabled       : -> AND(OR(self.statuses.busyStatus.idle,
                              AND(self.statuses.busyStatus.busy,
                                EQ(self.parts.apertureProcedure.state, THISLIB.CoverApertureProcedureStates.OPENING_BOTH_PANELS))),
                             self.statuses.initializationStatus.initialized,
                             self.statuses.operatingStatus.auto,
                             NOT(self.statuses.apertureStatus.closed))
    open:
      isEnabled       : -> AND(self.processes.forceOpen.statuses.enabledStatus.enabled, self.safeToOpenOrClose)
    close:
      isEnabled       : -> AND(self.processes.forceClose.statuses.enabledStatus.enabled, self.safeToOpenOrClose)
    abort:
      isEnabled       : -> self.parts.apertureProcedure.statuses.busyStatus.busy
    reset:
      isEnabled       : -> AND(NOT(OR(self.statuses.initializationStatus.shutdown, self.statuses.initializationStatus.locked)),
                               EQ(self.parts.apertureProcedure.state, THISLIB.CoverApertureProcedureStates.ERROR))
    top:
      initializationStatus  : -> self.statuses.initializationStatus
      operatorStatus        : -> self.operatorStatus
      operatingStatus       : -> self.statuses.operatingStatus
      config                : -> self.config.top
      coverConfig           : -> self.config
    bottom:
      initializationStatus  : -> self.statuses.initializationStatus
      operatorStatus        : -> self.operatorStatus
      operatingStatus       : -> self.statuses.operatingStatus
      config                : -> self.config.bottom
      coverConfig           : -> self.config
    apertureProcedure:
      top                   : -> self.parts.top
      bottom                : -> self.parts.bottom
      coverConfig           : -> self.config
    operatingStatus:
      superState            : -> self.statuses.initializationStatus.initialized
    apertureStatus:
      isOpen                : -> AND(self.parts.top.statuses.apertureStatus.open,   self.parts.bottom.statuses.apertureStatus.open)
      isClosed              : -> AND(self.parts.top.statuses.apertureStatus.closed, self.parts.bottom.statuses.apertureStatus.closed)
    healthStatus:
      isGood                : -> MTCS_SUMMARIZE_GOOD( self.parts.top, self.parts.bottom, self.parts.apertureProcedure, self.parts.io)
      hasWarning            : -> OR( MTCS_SUMMARIZE_WARN( self.parts.top, self.parts.bottom, self.parts.apertureProcedure, self.parts.io),
                                    AND( self.statuses.busyStatus.idle, NOT( OR( self.statuses.apertureStatus.open, self.statuses.apertureStatus.closed ) ) ) )
    busyStatus:
      isBusy                : -> OR(self.parts.top.statuses.busyStatus.busy,
                                    self.parts.bottom.statuses.busyStatus.busy,
                                    self.parts.apertureProcedure.statuses.busyStatus.busy)
    configManager:
      isEnabled             : -> AND(self.operatorStatus.tech, self.statuses.initializationStatus.initialized)
  constraints:
    open                    : -> { sameAs: COIMPLICATION(iff: self.statuses.apertureStatus.open  , then: cover_sys.system.open  ) }
    closed                  : -> { sameAs: COIMPLICATION(iff: self.statuses.apertureStatus.closed, then: cover_sys.system.closed) }


########################################################################################################################
# CoverApertureProcedure
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB, "CoverApertureProcedure",
  typeOf: [ THISLIB.CoverParts.apertureProcedure ]
  variables_hidden:
    state         : { type: THISLIB.CoverApertureProcedureStates  , comment: "New state, to be set by the manual implementation" , expand: false }
  variables_read_only:
    opening       : { type: t_bool                , comment: "Is the procedure busy with opening?" }
    closing       : { type: t_bool                , comment: "Is the procedure busy with closing?" }
    distance      : { type: COMMONLIB.AngularPosition       , comment: "The closest distance between the top and bottom panels" , expand: false }
  references:
    top         : {}
    bottom        : {}
    coverConfig     : { type: THISLIB.CoverConfig, expand: false }
  statuses:
    busyStatus      : { type: COMMONLIB.BusyStatus          , comment: "Is the CoverApertureProcedure in a busy state?" }
    healthStatus    : { type: COMMONLIB.HealthStatus        , comment: "Is the CoverApertureProcedure in a healthy state?" }
  calls:
    processStatus:
      state       : -> self.state
    busyStatus:
      isBusy      : -> NOT( OR( EQ(self.state, THISLIB.CoverApertureProcedureStates.IDLE),
                      EQ(self.state, THISLIB.CoverApertureProcedureStates.ABORTED),
                      EQ(self.state, THISLIB.CoverApertureProcedureStates.ERROR)) )
    healthStatus:
      isGood      : -> NOT( EQ(self.state, THISLIB.CoverApertureProcedureStates.ERROR) )
      hasWarning    : -> EQ(self.state, THISLIB.CoverApertureProcedureStates.ABORTED)


########################################################################################################################
# CoverPanelSetConfig
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "CoverPanelSetConfig",
  typeOf: [ THISLIB.CoverParts.top.config, THISLIB.CoverParts.bottom.config, THISLIB.CoverConfig.top, THISLIB.CoverConfig.bottom ]
  items:
    p1        : { comment: "The config of the first panel of this set" }
    p2        : { comment: "The config of the second panel of this set" }
    p3        : { comment: "The config of the third panel of this set" }
    p4        : { comment: "The config of the fourth panel of this set" }
    name      : { type: t_string  , comment: "The name of the panel set" }


########################################################################################################################
# CoverPanelSet
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB, "CoverPanelSet",
  typeOf            : [ THISLIB.CoverParts.top, THISLIB.CoverParts.bottom,
                  THISLIB.CoverApertureProcedure.top, THISLIB.CoverApertureProcedure.bottom ]
  references:
    initializationStatus  : { type: COMMONLIB.InitializationStatus }
    operatorStatus      : { type: COMMONLIB.OperatorStatus }
    operatingStatus     : { type: COMMONLIB.OperatingStatus }
    config          : { type: THISLIB.CoverPanelSetConfig }
    coverConfig       : { type: THISLIB.CoverConfig }
  parts:
    p1:
      comment: "Panel 1"
      arguments:
        initializationStatus  : { type: COMMONLIB.InitializationStatus  , expand: false }
        operatorStatus      : { type: COMMONLIB.OperatorStatus    , expand: false }
        operatingStatus     : { type: COMMONLIB.OperatingStatus     , expand: false }
        config          : {}
        coverConfig       : { type: THISLIB.CoverConfig       , expand: false  }
      attributes:
        statuses:
          attributes:
            apertureStatus      : { type: COMMONLIB.ApertureStatus }
            healthStatus      : { type: COMMONLIB.HealthStatus }
            busyStatus        : { type: COMMONLIB.BusyStatus }
    p2:
      comment: "Panel 2"
      arguments:
        initializationStatus  : { type: COMMONLIB.InitializationStatus  , expand: false }
        operatorStatus      : { type: COMMONLIB.OperatorStatus    , expand: false }
        operatingStatus     : { type: COMMONLIB.OperatingStatus     , expand: false }
        config          : {}
        coverConfig       : { type: THISLIB.CoverConfig       , expand: false }
      attributes:
        statuses:
          attributes:
            apertureStatus      : { type: COMMONLIB.ApertureStatus }
            healthStatus      : { type: COMMONLIB.HealthStatus }
            busyStatus        : { type: COMMONLIB.BusyStatus }
    p3:
      comment: "Panel 3"
      arguments:
        initializationStatus  : { type: COMMONLIB.InitializationStatus  , expand: false }
        operatorStatus      : { type: COMMONLIB.OperatorStatus    , expand: false }
        operatingStatus     : { type: COMMONLIB.OperatingStatus     , expand: false }
        config          : {}
        coverConfig       : { type: THISLIB.CoverConfig       , expand: false }
      attributes:
        statuses:
          attributes:
            apertureStatus      : { type: COMMONLIB.ApertureStatus }
            healthStatus      : { type: COMMONLIB.HealthStatus }
            busyStatus        : { type: COMMONLIB.BusyStatus }
    p4:
      comment: "Panel 4"
      arguments:
        initializationStatus  : { type: COMMONLIB.InitializationStatus  , expand: false }
        operatorStatus      : { type: COMMONLIB.OperatorStatus    , expand: false }
        operatingStatus     : { type: COMMONLIB.OperatingStatus     , expand: false }
        config          : {}
        coverConfig       : { type: THISLIB.CoverConfig       , expand: false }
      attributes:
        statuses:
          attributes:
            apertureStatus      : { type: COMMONLIB.ApertureStatus }
            healthStatus      : { type: COMMONLIB.HealthStatus }
            busyStatus        : { type: COMMONLIB.BusyStatus }
    magnetsRelay:
      comment: "Relay for the magnets of this panelset"
      type: COMMONLIB.SimpleRelay
  statuses:
    apertureStatus      : { type: COMMONLIB.ApertureStatus }
    healthStatus      : { type: COMMONLIB.HealthStatus }
    busyStatus        : { type: COMMONLIB.BusyStatus }
  processes:
    reset           : { type: COMMONLIB.Process, comment: "Reset any errors" }
  calls:
    reset:
      isEnabled       : -> self.initializationStatus.initialized
    p1:
      initializationStatus: -> self.initializationStatus
      operatorStatus    : -> self.operatorStatus
      operatingStatus   : -> self.operatingStatus
      config        : -> self.config.p1
      coverConfig     : -> self.coverConfig
    p2:
      initializationStatus: -> self.initializationStatus
      operatorStatus    : -> self.operatorStatus
      operatingStatus   : -> self.operatingStatus
      config        : -> self.config.p2
      coverConfig     : -> self.coverConfig
    p3:
      initializationStatus: -> self.initializationStatus
      operatorStatus    : -> self.operatorStatus
      operatingStatus   : -> self.operatingStatus
      config        : -> self.config.p3
      coverConfig     : -> self.coverConfig
    p4:
      initializationStatus: -> self.initializationStatus
      operatorStatus    : -> self.operatorStatus
      operatingStatus   : -> self.operatingStatus
      config        : -> self.config.p4
      coverConfig     : -> self.coverConfig
    magnetsRelay:
      isEnabled       : -> AND( self.initializationStatus.initialized, self.operatingStatus.manual ) # observers are allowed
    apertureStatus:
      isOpen        : -> AND(self.parts.p1.statuses.apertureStatus.open,
                     self.parts.p2.statuses.apertureStatus.open,
                     self.parts.p3.statuses.apertureStatus.open,
                     self.parts.p4.statuses.apertureStatus.open)
      isClosed      : -> AND(self.parts.p1.statuses.apertureStatus.closed,
                     self.parts.p2.statuses.apertureStatus.closed,
                     self.parts.p3.statuses.apertureStatus.closed,
                     self.parts.p4.statuses.apertureStatus.closed)
    healthStatus:
      isGood        : -> MTCS_SUMMARIZE_GOOD( self.parts.p1, self.parts.p2, self.parts.p3, self.parts.p4)
      hasWarning      : -> MTCS_SUMMARIZE_WARN( self.parts.p1, self.parts.p2, self.parts.p3, self.parts.p4)
    busyStatus:
      isBusy        : -> OR(self.parts.p1.statuses.busyStatus.busy,
                    self.parts.p2.statuses.busyStatus.busy,
                    self.parts.p3.statuses.busyStatus.busy,
                    self.parts.p4.statuses.busyStatus.busy)


##########################################################################
# CoverPanelConfig
##########################################################################

MTCS_MAKE_CONFIG THISLIB, "CoverPanelConfig",
  typeOf: [THISLIB.CoverPanelSetConfig[p] for p in ["p1","p2","p3","p4"]]
  items:
    closedPosition:
      type: t_double
      comment: "The closed position of the panel in degrees"
    openPosition:
      type: t_double
      comment: "The open position of the panel in degrees"
    openTolerance:
      type: t_double
      comment: "The tolerance for opening, in degrees"
    closedTolerance:
      type: t_double
      comment: "The tolerance for closing, in degrees"
    standstillTolerance:
      type: t_double
      comment: "Tolerance in degrees per second: if smaller than " +
               "ABS(this value), then the cover panel is considered " +
               "to be standing still"
    name:
      type: t_string
      comment: "The name of the panel"
    offset:
      type: t_double
      comment: "The offset of the panel w.r.t. north"


##########################################################################
# CoverPanel
##########################################################################

MTCS_MAKE_STATEMACHINE THISLIB, "CoverPanel",
  typeOf: [ THISLIB.CoverPanelSetParts.p1,
            THISLIB.CoverPanelSetParts.p2,
            THISLIB.CoverPanelSetParts.p3,
            THISLIB.CoverPanelSetParts.p4,
            THISLIB.CoverPanelSet.parts.p1,
            THISLIB.CoverPanelSet.parts.p2,
            THISLIB.CoverPanelSet.parts.p3,
            THISLIB.CoverPanelSet.parts.p4 ]
  references:
    initializationStatus:
        type: COMMONLIB.InitializationStatus
        comment: "INITIALIZED or INITIALIZING or ..."
    operatorStatus:
        type: COMMONLIB.OperatorStatus
        comment: "TECH or OBSERVER or ..."
    operatingStatus:
        type: COMMONLIB.OperatingStatus
        comment: "MANUAL or AUTO or NONE"
    config:
        type: THISLIB.CoverPanelConfig
        comment: "Configuration of the panel"
    coverConfig:
        type: THISLIB.CoverConfig
        comment: "Configuration of the cover"
        expand: false
  variables:
    encoderErrorSignal:
        type: t_bool
        comment: 'Externally read error signal'
        address: "%I*"
  parts:
    axis:
        type: COMMONLIB.AngularAxis
        comment: "NC Axis"
    motorRelay:
        type: COMMONLIB.SimpleRelay
        comment: "Relay for the motor"
  statuses:
    busyStatus:
        type: COMMONLIB.BusyStatus
        comment: "Is the panel in a busy state?"
    apertureStatus:
        type: COMMONLIB.ApertureStatus
        comment: "Is the panel open or closed?"
    healthStatus:
        type: COMMONLIB.HealthStatus
        comment: "Is the panel in a healthy state?"
    openingStatus:
        type: COMMONLIB.OpeningStatus
        comment: "Is the panel opening or closing or standing still?"
  processes:
    startOpening:
        type: COMMONLIB.Process
        comment: "Start opening the panel"
    startClosing:
        type: COMMONLIB.Process
        comment: "Start closing the panel"
  calls:
    axis:
      isEnabled: -> AND(self.operatorStatus.tech,
                        self.operatingStatus.manual,
                        self.initializationStatus.initialized)
      standstillTolerance : -> self.config.standstillTolerance
    motorRelay:
      isEnabled: -> self.parts.axis.isEnabled # same as for axis
    busyStatus:
      isBusy: -> OR( self.parts.axis.statuses.busyStatus.busy,
                     self.parts.motorRelay.statuses.busyStatus.busy )
    healthStatus:
      isGood: -> AND(self.parts.axis.statuses.healthStatus.isGood,
                     NOT(self.encoderErrorSignal))
      hasWarning: -> self.parts.axis.statuses.healthStatus.hasWarning
    apertureStatus:
      isOpen    : -> LT(ABS(SUB(self.config.openPosition,
                                self.parts.axis.actPos.degrees.value)),
                        self.config.openTolerance)
      isClosed  : -> LT(ABS(SUB(self.config.closedPosition,
                                self.parts.axis.actPos.degrees.value)),
                        self.config.closedTolerance)
    openingStatus:
      isOpening       : -> self.parts.axis.statuses.motionStatus.backward
      isClosing       : -> self.parts.axis.statuses.motionStatus.forward
    startOpening:
      isEnabled       : -> AND(self.operatorStatus.tech,
                               self.operatingStatus.manual,
                               self.initializationStatus.initialized)
    startClosing:
      isEnabled       : -> AND(self.operatorStatus.tech,
                               self.operatingStatus.manual,
                               self.initializationStatus.initialized)


########################################################################################################################
# CoverIO
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB, "CoverIO",
  typeOf        : [ THISLIB.CoverParts.io ]
  statuses:
    healthStatus  : { type: COMMONLIB.HealthStatus   , comment: "Is the I/O in a healthy state?"  }
  parts:
    coupler     : { type: COMMONLIB.EtherCatDevice , comment: "Coupler" }
    slot1       : { type: COMMONLIB.EtherCatDevice , comment: "Slot 1" }
    slot2       : { type: COMMONLIB.EtherCatDevice , comment: "Slot 2" }
    slot3       : { type: COMMONLIB.EtherCatDevice , comment: "Slot 3" }
    slot4       : { type: COMMONLIB.EtherCatDevice , comment: "Slot 4" }
    slot5       : { type: COMMONLIB.EtherCatDevice , comment: "Slot 5" }
    slot6       : { type: COMMONLIB.EtherCatDevice , comment: "Slot 6" }
    slot7       : { type: COMMONLIB.EtherCatDevice , comment: "Slot 7" }
    slot8       : { type: COMMONLIB.EtherCatDevice , comment: "Slot 8" }
    slot9       : { type: COMMONLIB.EtherCatDevice , comment: "Slot 9" }
    slot10      : { type: COMMONLIB.EtherCatDevice , comment: "Slot 10" }
    slot11      : { type: COMMONLIB.EtherCatDevice , comment: "Slot 11" }
    slot12      : { type: COMMONLIB.EtherCatDevice , comment: "Slot 12" }
    slot13      : { type: COMMONLIB.EtherCatDevice , comment: "Slot 13" }
  calls:
    coupler:
      id      : -> STRING("110A1") "id"
      typeId    : -> STRING("EK1101") "typeId"
    slot1:
      id      : -> STRING("115A1") "id"
      typeId    : -> STRING("EL2008") "typeId"
    slot2:
      id      : -> STRING("116A1") "id"
      typeId    : -> STRING("EL4008") "typeId"
    slot3:
      id      : -> STRING("117A1") "id"
      typeId    : -> STRING("EL1088") "typeId"
    slot4:
      id      : -> STRING("118A1") "id"
      typeId    : -> STRING("EL5002") "typeId"
    slot5:
      id      : -> STRING("118A5") "id"
      typeId    : -> STRING("EL5002") "typeId"
    slot6:
      id      : -> STRING("119A1") "id"
      typeId    : -> STRING("EL5002") "typeId"
    slot7:
      id      : -> STRING("119A5") "id"
      typeId    : -> STRING("EL5002") "typeId"
    slot8:
      id      : -> STRING("111A1") "id"
      typeId    : -> STRING("EL2622") "typeId"
    slot9:
      id      : -> STRING("111A5") "id"
      typeId    : -> STRING("EL2622") "typeId"
    slot10:
      id      : -> STRING("112A1") "id"
      typeId    : -> STRING("EL2622") "typeId"
    slot11:
      id      : -> STRING("112A5") "id"
      typeId    : -> STRING("EL2622") "typeId"
    slot12:
      id      : -> STRING("113A1") "id"
      typeId    : -> STRING("EL2622") "typeId"
    slot13:
      id      : -> STRING("114A1") "id"
      typeId    : -> STRING("EL3681") "typeId"
    healthStatus:
      isGood    : -> MTCS_SUMMARIZE_GOOD( self.parts.coupler,
                          self.parts.slot1,
                          self.parts.slot2,
                          self.parts.slot3,
                          self.parts.slot4,
                          self.parts.slot5,
                          self.parts.slot6,
                          self.parts.slot7,
                          self.parts.slot8,
                          self.parts.slot9,
                          self.parts.slot10,
                          self.parts.slot11,
                          self.parts.slot12,
                          self.parts.slot13 )


########################################################################################################################
# Write the model to file
########################################################################################################################

cover_soft.WRITE "models/mtcs/cover/software.jsonld"
