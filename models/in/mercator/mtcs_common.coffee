require "ontoscript"


REQUIRE "models/util/softwarefactories.coffee"

MODEL "http://www.mercator.iac.es/onto/models/mtcs/common/software" : "common_soft"

common_soft.IMPORT softwarefactories


########################################################################################################################
# Define the containing PLC library
########################################################################################################################

common_soft.ADD MTCS_MAKE_LIB "mtcs_common"

# make an alias to the library (with scope of this file only)
THISLIB = common_soft.mtcs_common


########################################################################################################################
# InitializationStates
########################################################################################################################
MTCS_MAKE_ENUM THISLIB, "InitializationStates",
    items:
        [   "SHUTDOWN",
            "INITIALIZING",
            "INITIALIZING_FAILED",
            "INITIALIZED",
            "LOCKED"  ]


########################################################################################################################
# OperatorStates
########################################################################################################################
MTCS_MAKE_ENUM THISLIB, "OperatorStates",
    items:
        [   "NONE",
            "OBSERVER",
            "TECH"      ]


########################################################################################################################
# OperatingStates
########################################################################################################################
MTCS_MAKE_ENUM THISLIB, "OperatingStates",
    items:
        [   "AUTO",
            "MANUAL" ]

        
########################################################################################################################
# OperatingModeStates
########################################################################################################################
MTCS_MAKE_ENUM THISLIB, "OperatingModeStates",
    items:
        [   "LOCAL",
            "REMOTE" ]


########################################################################################################################
# LeftRightLimitSwitches
########################################################################################################################
MTCS_MAKE_ENUM THISLIB, "LimitSwitches",
    items:
        [   "POSITIVE_LIMIT_SWITCH",
            "NEGATIVE_LIMIT_SWITCH" ]



########################################################################################################################
# Units
########################################################################################################################
MTCS_MAKE_ENUM THISLIB, "Units",
    items:
        [   "DEGREE",
            "RADIAN",
            "PERCENT",
            "RADIANS_PER_SECOND",
            "DEGREES_PER_SECOND",
            "MILLIMETERS_PER_SECOND",
            "REVOLUTIONS_PER_SECOND",
            "REVOLUTIONS_PER_MINUTE",
            "AMPS",
            "MILLIAMPS",
            "MILLIMETER",
            "MICROMETER",
            "DEGREES_CELSIUS",
            "KELVIN",
            "BAR",
            "PASCAL",
            "UNITLESS",
            "NEWTON",
            "DECANEWTON",
            "VOLT",
            "MILLIVOLT",
            "HERTZ",
            "G",
            "MILLIG",
            "NEWTONMETER",
            "ARCSECONDS",
            "ARCSECONDS_PER_SECOND",
            "RADIANS_PER_SQUARE_SECOND",
            "DEGREES_PER_SQUARE_SECOND",
            "ARCSECONDS_PER_SQUARE_SECOND",
            "METERS_PER_SECOND",
            "HECTOPASCAL",
            "SECONDS",
            "MINUTES",
            "MILLIMETERS_PER_HOUR",
            "HITS_PER_SQUARE_CENTIMETER",
            "HITS_PER_SQUARE_CENTIMETER_PER_HOUR"
        ]


########################################################################################################################
# RequestResults
########################################################################################################################
MTCS_MAKE_ENUM THISLIB, "RequestResults",
    items:
        [   "ACCEPTED",
            "REJECTED"   ]



########################################################################################################################
# ApertureStatus
########################################################################################################################
MTCS_MAKE_STATUS THISLIB, "ApertureStatus",
    variables:
        "isOpen":
            type: t_bool
            comment: "TRUE if the 'open' limit switch is active"
        "isClosed":
            type: t_bool
            comment: "TRUE if the 'open' limit switch is active"
    states:
        "open":
            expr: -> AND( self.isOpen, NOT(self.isClosed) )
            comment: "The aperture is open"
        "closed":
            expr: -> AND( self.isClosed, NOT(self.isOpen) )
            comment: "The aperture is closed"
        "partiallyOpen":
            expr: -> NOT( OR( self.isOpen, self.isClosed) )
            comment: "The aperture is partially open"
        "undefined":
            expr: -> AND( self.isOpen, self.isClosed)
            comment: "The aperture status is undefined"



########################################################################################################################
# BusyStatus
########################################################################################################################
MTCS_MAKE_STATUS THISLIB, "BusyStatus",
    variables:
        "isBusy":
            type: t_bool
            comment: "TRUE if busy"
    states:
        "idle":
            expr: -> NOT( self.isBusy )
            comment: "The subject is idle"
        "busy":
            expr: -> self.isBusy
            comment: "The subject is busy"


## Add a 'summarize' helper function!
root.MTCS_SUMMARIZE_BUSY = (statemachines...) ->
    inputs = (statemachine.statuses.busyStatus.busy for statemachine in statemachines)
    return OR( inputs... )


########################################################################################################################
# StartedStatus
########################################################################################################################
MTCS_MAKE_STATUS THISLIB, "StartedStatus",
    variables:
        "isStarted":
            type: t_bool
            comment: "TRUE if started"
    states:
        "started":
            expr: -> self.isStarted
            comment: "The subject is started"
        "notStarted":
            expr: -> NOT( self.isStarted )
            comment: "The subject is started"


########################################################################################################################
# EnabledStatus
########################################################################################################################
MTCS_MAKE_STATUS THISLIB, "EnabledStatus",
    variables:
        "isEnabled":
            type: t_bool
            comment: "TRUE if enabled"
    states:
        "enabled":
            expr: -> self.isEnabled
            comment: "The subject is enabled"
        "disabled":
            expr: -> NOT( self.isEnabled )
            comment: "The subject is disabled"



########################################################################################################################
# PoweredStatus
########################################################################################################################
MTCS_MAKE_STATUS THISLIB, "PoweredStatus",
    variables:
        "isEnabled":
            type: t_bool
            comment: "TRUE if power is enabled"
    states:
        "enabled":
            expr: -> self.isEnabled
            comment: "The power is enabled"
        "disabled":
            expr: -> NOT( self.isEnabled )
            comment: "The power is disabled"


########################################################################################################################
# HealthStatus
########################################################################################################################
MTCS_MAKE_STATUS THISLIB, "HealthStatus",
    variables:
        "isGood":
            type: t_bool
            comment: "TRUE if the subject is in Good health"
        "hasWarning":
            type: t_bool
            initial: bool(false)
            comment: "TRUE to add a warning to the Good health state"
    states:
        "good":
            expr: -> AND(self.isGood, NOT(self.hasWarning))
            comment: "The subject is in Good health"
        "warning":
            expr: -> AND(self.isGood, self.hasWarning)
            comment: "The subject is in Good health, but there are one or more warnings present"
        "bad":
            expr: -> NOT( self.isGood )
            comment: "The subject is in Bad health"


## Add a 'summarize' helper function!
root.MTCS_SUMMARIZE_GOOD = (statemachines...) ->
    inputs = (statemachine.statuses.healthStatus.isGood for statemachine in statemachines)
    return AND( inputs... )

root.MTCS_SUMMARIZE_WARN = (statemachines...) ->
    inputs = (statemachine.statuses.healthStatus.hasWarning for statemachine in statemachines)
    return OR( inputs... )

root.MTCS_SUMMARIZE_GOOD_OR_DISABLED = (statemachines...) ->
    inputs = ( OR(statemachine.statuses.healthStatus.isGood, statemachine.statuses.enabledStatus.disabled) for statemachine in statemachines)
    return AND( inputs... )

########################################################################################################################
# InitializationStatus
########################################################################################################################
MTCS_MAKE_STATUS THISLIB, "InitializationStatus",
    variables:
        "state":
            type: THISLIB.InitializationStates
            comment: "Enum!"
    states:
        "shutdown":
            expr: -> EQ( self.state, THISLIB.InitializationStates.SHUTDOWN )
            comment: "Shutdown"
        "initializing":
            expr: -> EQ( self.state, THISLIB.InitializationStates.INITIALIZING )
            comment: "Initializing"
        "initializingFailed":
            expr: -> EQ( self.state, THISLIB.InitializationStates.INITIALIZING_FAILED )
            comment: "Initializing failed"
        "initialized":
            expr: -> EQ( self.state, THISLIB.InitializationStates.INITIALIZED )
            comment: "Initialized"
        "locked":
            expr: -> EQ( self.state, THISLIB.InitializationStates.LOCKED )
            comment: "Locked"


########################################################################################################################
# MotionStatus
########################################################################################################################
MTCS_MAKE_STATUS THISLIB, "MotionStatus",
    variables:
        "actVel":
            type: t_double
            comment: "Actual velocity"
        "tolerance":
            type: t_double
            comment: "Tolerance (should be positive)!"
    states:
        "forward":
            expr: -> GT(self.actVel, ABS(self.tolerance))
            comment: "Moving forwared"
        "backward":
            expr: -> LT( self.actVel, NEG(ABS(self.tolerance)) )
            comment: "Moving backward"
        "standstill":
            expr: -> NOT( OR( self.forward, self.backward ) )
            comment: "Standing still"




########################################################################################################################
# HiHiLoLoAlarmConfig
########################################################################################################################
MTCS_MAKE_CONFIG THISLIB, "HiHiLoLoAlarmConfig",
    items:
        enabled:
            type: t_bool
            comment: "Is the alarm enabled?"
        loLo:
            type: t_double
            comment: "LowLow alarm limit (produces ERROR)"
        lo:
            type: t_double
            comment: "Low alarm limit (produces WARNING)"
        hi:
            type: t_double
            comment: "High alarm limit (produces WARNING)"
        hiHi:
            type: t_double
            comment: "HighHigh alarm limit (produces ERROR)"


########################################################################################################################
# HiHiLoLoAlarmStatus
########################################################################################################################
MTCS_MAKE_STATUS THISLIB, "HiHiLoLoAlarmStatus",
    variables:
        "config":
            type: THISLIB.HiHiLoLoAlarmConfig
            comment: "Config"
        "value":
            type: t_double
            comment: "Value in the correct units to compare to the values from the config"
    states:
        "disabled":
            expr: -> NOT(self.config.enabled)
            comment: "The alarm is disabled"
        "hiHi":
            expr: -> AND(self.config.enabled, GE(self.value, self.config.hiHi))
            comment: "HighHigh limit active"
        "hi":
            expr: -> AND(self.config.enabled, GE(self.value, self.config.hi), LT(self.value, self.config.hiHi))
            comment: "High limit active"
        "ok":
            expr: -> AND(self.config.enabled, GT(self.value, self.config.lo), LT(self.value, self.config.hi))
            comment: "The value is within normal range"
        "lo":
            expr: -> AND(self.config.enabled, LE(self.value, self.config.lo), LT(self.value, self.config.loLo))
            comment: "Low limit active"
        "loLo":
            expr: -> AND(self.config.enabled, LE(self.value, self.config.loLo))
            comment: "LowLow limit active"


########################################################################################################################
# MeasurementConfig
########################################################################################################################
MTCS_MAKE_CONFIG THISLIB, "MeasurementConfig",
    items:
        enabled:
            type: t_bool
            comment: "Is the quantity being measured? (Can be false e.g. if the sensor is deliberately not connected (yet).)"
        gain:
            type: t_double
            comment: "Gain to be applied to the measured value (default: 1 = no gain)"
            initial: double(1.0)
        offset:
            type: t_double
            comment: "Offset to be added to the measured value (default: 0 = no offset)"
        alarms:
            type: THISLIB.HiHiLoLoAlarmConfig
            comment: "Config"


########################################################################################################################
# OpeningStatus
########################################################################################################################
MTCS_MAKE_STATUS THISLIB, "OpeningStatus",
    variables:
        "isOpening":
            type: t_bool
            comment: "TRUE if opening"
        "isClosing":
            type: t_bool
            comment: "TRUE if closing"
    states:
        "opening":
            expr: -> AND( self.isOpening, NOT(self.isClosing) )
            comment: "Opening"
        "closing":
            expr: -> AND( self.isClosing, NOT(self.isOpening) )
            comment: "Closing"
        "standstill":
            expr: -> NOT( OR( self.isClosing, self.isOpening ) )
            comment: "Standing still"



########################################################################################################################
# OperatorStatus
########################################################################################################################
MTCS_MAKE_STATUS THISLIB, "OperatorStatus",
    variables:
        "state":
            type: THISLIB.OperatorStates
            comment: "Enum!"
    states:
        "none":
            expr: -> EQ( self.state, THISLIB.OperatorStates.NONE )
            comment: "None"
        "tech":
            expr: -> EQ( self.state, THISLIB.OperatorStates.TECH )
            comment: "Tech"
        "observer":
            expr: -> EQ( self.state, THISLIB.OperatorStates.OBSERVER )
            comment: "Observer"


########################################################################################################################
# OperatingStatus
########################################################################################################################
MTCS_MAKE_STATUS THISLIB, "OperatingStatus",
    variables:
        "state":
            type: THISLIB.OperatingStates
            comment: "Enum!"
    states:
        "auto":
            expr: -> EQ( self.state, THISLIB.OperatingStates.AUTO )
            comment: "Auto"
        "manual":
            expr: -> EQ( self.state, THISLIB.OperatingStates.MANUAL )
            comment: "Manual"


########################################################################################################################
# OperatingModeStatus
########################################################################################################################
MTCS_MAKE_STATUS THISLIB, "OperatingModeStatus",
    variables:
        "state":
            type: THISLIB.OperatingModeStates
            comment: "Enum!"
    states:
        "local":
            expr: -> EQ( self.state, THISLIB.OperatingModeStates.LOCAL )
            comment: "Local"
        "remote":
            expr: -> EQ( self.state, THISLIB.OperatingModeStates.REMOTE )
            comment: "Remote"


########################################################################################################################
# MTCSStatus
########################################################################################################################
MTCS_MAKE_STATUS THISLIB, "ActivityStatus",
    variables:
        isMoving:
            type: t_bool
            comment: "TRUE if moving"
        isAwake:
            type: t_bool
            comment: "TRUE if awake"
    states:
        moving:
            expr: -> AND( self.isAwake    , self.isMoving )
            comment: "Opening"
        awake:
            expr: -> AND( self.isAwake    , NOT(self.isMoving ) )
            comment: "Opening"
        sleeping:
            expr: -> NOT(self.isAwake)
            comment: "Opening"


########################################################################################################################
# Types not to added to a library, and thus not generated (we only define them so that we can refer to them)
########################################################################################################################

common_soft.ADD PLC_STRUCT() "LogBuffer"

common_soft.ADD PLC_FB(
  in:
    name          : { type: t_string }
    actualStatus  : { type: t_string }
    pHealthStatus : { pointsToType: THISLIB.HealthStatus , initial: int(0) }
    pBusyStatus   : { pointsToType: THISLIB.BusyStatus   , initial: int(0) }
  inout:
    previousStatus: { type: t_string }
    buffer        : { type: common_soft.LogBuffer }
    subBuffer     : { type: common_soft.LogBuffer }
) "GlobalLogger"

# create a global variable
common_soft.ADD GLOBAL_VARIABLE(type: common_soft.GlobalLogger) "LOGGER"

########################################################################################################################
# QuantityValue
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB, "QuantityValue",
    variables:
        value: { type: t_double       , comment: "Numeric value" }
        unit:  { type: THISLIB.Units  , comment: "Unit of the numeric value" }


########################################################################################################################
# AngularPosition
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB, "AngularPosition",
    variables_hidden:
        newDegreesValue: { type: t_double, comment: "New position value in degrees" }
    variables_read_only:
        radians     : { type: THISLIB.QuantityValue, comment: "Angular position in radians" }
        degrees     : { type: THISLIB.QuantityValue, comment: "Angular position in degrees" }
        arcseconds  : { type: THISLIB.QuantityValue, comment: "Angular position in arcseconds" }
    calls:
        radians:
            value : -> MUL(self.newDegreesValue, DOUBLE(PIVALUE/180.0) "radPerDeg")
            unit  : -> THISLIB.Units.RADIAN
        degrees:
            value : -> self.newDegreesValue
            unit  : -> THISLIB.Units.DEGREE
        arcseconds:
            value : -> MUL(self.newDegreesValue, DOUBLE(3600.0) "arcsecPerDeg")
            unit  : -> THISLIB.Units.ARCSECONDS


#########################################################################################################################
## DeltaCoordinate
#########################################################################################################################
#MTCS_MAKE_STATEMACHINE THISLIB, "DeltaCoordinate",
#    extends: THISLIB.AngularPosition
#    variables:
#        minutes :  { type: t_int16, comment: "Alpha minutes (an integer value!)" }
#        seconds :  { type: t_double, comment: "Alpha seconds (a decimal value!)" }



########################################################################################################################
# LinearPosition
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB, "LinearPosition",
    variables_hidden:
        newMillimetersValue: { type: t_double, comment: "New position value in millimeters" }
    variables_read_only:
        millimeters: { type: THISLIB.QuantityValue, comment: "Linear position in millimeters" }
        micrometers: { type: THISLIB.QuantityValue, comment: "Linear position in micrometers" }
    calls:
        millimeters:
            value : -> self.newMillimetersValue
            unit  : -> THISLIB.Units.MILLIMETER
        micrometers:
            value : -> MUL(self.newMillimetersValue, DOUBLE(1000.0) "milliToMicro")
            unit  : -> THISLIB.Units.MICROMETER

########################################################################################################################
# AngularVelocity
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB, "AngularVelocity",
    variables_hidden:
        newDegreesPerSecondValue: { type: t_double, comment: "New velocity value in degrees per second" }
    variables_read_only:
        radiansPerSecond    : { type: THISLIB.QuantityValue, comment: "Angular velocity in radians per second" }
        degreesPerSecond    : { type: THISLIB.QuantityValue, comment: "Angular velocity in degrees per second" }
        arcsecondsPerSecond : { type: THISLIB.QuantityValue, comment: "Angular velocity in arcseconds per second" }
    calls:
        radiansPerSecond:
            value : -> MUL(self.newDegreesPerSecondValue, DOUBLE(PIVALUE/180.0) "radPerDeg")
            unit  : -> THISLIB.Units.RADIANS_PER_SECOND
        degreesPerSecond:
            value : -> self.newDegreesPerSecondValue
            unit  : -> THISLIB.Units.DEGREES_PER_SECOND
        arcsecondsPerSecond:
            value : -> MUL(self.newDegreesPerSecondValue, DOUBLE(3600.0) "arcsecondsPerDeg")
            unit  : -> THISLIB.Units.ARCSECONDS_PER_SECOND

########################################################################################################################
# AngularAcceleration
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB, "AngularAcceleration",
    variables_hidden:
        newDegreesPerSquareSecondValue: { type: t_double, comment: "New velocity value in degrees per second^2" }
    variables_read_only:
        radiansPerSquareSecond   : { type: THISLIB.QuantityValue, comment: "Angular velocity in radians per second^2" }
        degreesPerSquareSecond   : { type: THISLIB.QuantityValue, comment: "Angular velocity in degrees per second^2" }
        arcsecondsPerSquareSecond: { type: THISLIB.QuantityValue, comment: "Angular velocity in arcseconds per second^2" }
    calls:
        radiansPerSquareSecond:
            value : -> MUL(self.newDegreesPerSquareSecondValue, DOUBLE(PIVALUE/180.0) "radPerDeg")
            unit  : -> THISLIB.Units.RADIANS_PER_SQUARE_SECOND
        degreesPerSquareSecond:
            value : -> self.newDegreesPerSquareSecondValue
            unit  : -> THISLIB.Units.DEGREES_PER_SQUARE_SECOND
        arcsecondsPerSquareSecond:
            value : -> MUL(self.newDegreesPerSquareSecondValue, DOUBLE(3600.0) "arcsecondsPerDeg")
            unit  : -> THISLIB.Units.ARCSECONDS_PER_SQUARE_SECOND

########################################################################################################################
# AngularVelocity
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB, "LinearVelocity",
    variables_hidden:
        newMillimetersPerSecondValue: { type: t_double, comment: "New velocity value in millimeters per second" }
    variables_read_only:
        millimetersPerSecond: { type: THISLIB.QuantityValue, comment: "Linear velocity in millimeters per second" }
    calls:
        millimetersPerSecond:
            value : -> self.newMillimetersPerSecondValue
            unit  : -> THISLIB.Units.MILLIMETERS_PER_SECOND

########################################################################################################################
# Voltage
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB, "Voltage",
    variables_hidden:
        newVoltValue: { type: t_double, comment: "New voltage" }
    variables_read_only:
        volt       : { type: THISLIB.QuantityValue, comment: "Voltage in Volt" }
        milliVolt  : { type: THISLIB.QuantityValue, comment: "Voltage in millivolt" }
    calls:
        milliVolt:
            value : -> MUL(self.newVoltValue, DOUBLE(1000.0) "milli")
            unit  : -> THISLIB.Units.MILLIVOLT
        volt:
            value : -> self.newVoltValue
            unit  : -> THISLIB.Units.VOLT

########################################################################################################################
# GForce
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB, "GForce",
    variables_hidden:
        newMilliGValue: { type: t_double, comment: "New milliG value" }
    variables_read_only:
        g       : { type: THISLIB.QuantityValue, comment: "Acceleration in g units" }
        milliG  : { type: THISLIB.QuantityValue, comment: "Acceleration in in milli g units" }
    calls:
        milliG:
            value : -> self.newMilliGValue
            unit  : -> THISLIB.Units.MILLIG
        g:
            value : -> DIV(self.newMilliGValue, DOUBLE(1000.0) "milli")
            unit  : -> THISLIB.Units.G

########################################################################################################################
# Current
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB, "Current",
    variables_hidden:
        newAmpsValue: { type: t_double, comment: "New current in amps" }
    variables_read_only:
        amps        : { type: THISLIB.QuantityValue, comment: "Current in amps" }
        milliAmps   : { type: THISLIB.QuantityValue, comment: "Current in milliamps" }
    calls:
        milliAmps:
            value : -> MUL(self.newAmpsValue, DOUBLE(1000.0) "milli")
            unit  : -> THISLIB.Units.MILLIAMPS
        amps:
            value : -> self.newAmpsValue
            unit  : -> THISLIB.Units.AMPS


########################################################################################################################
# Torque
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB, "Torque",
    variables_hidden:
        newNewtonmeterValue: { type: t_double, comment: "New torque in Nm" }
    variables_read_only:
        newtonmeter: { type: THISLIB.QuantityValue, comment: "Torque in Nm" }
    calls:
        newtonmeter:
            value : -> self.newNewtonmeterValue
            unit  : -> THISLIB.Units.NEWTONMETER

########################################################################################################################
# TorqueLimit
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB, "TorqueLimit",
    variables_hidden:
        newFractionValue : { type: t_double, comment: "New torque limit as a unitless fraction (between 0 and 1)" }
        maxNewtonmeter   : { type: t_double, comment: "Newtonmeters corresponding to 100 percent (fraction=1)" }
    variables_read_only:
        unitless        : { type: THISLIB.QuantityValue, comment: "Torque limit as a unitless fraction" }
        percent         : { type: THISLIB.QuantityValue, comment: "Torque limit in percent" }
        newtonmeter     : { type: THISLIB.QuantityValue, comment: "Torque in Nm" }
    calls:
        unitless:
            value : -> self.newFractionValue
            unit  : -> THISLIB.Units.UNITLESS
        percent:
            value : -> MUL(self.newFractionValue, DOUBLE(100) "conversionFactor")
            unit  : -> THISLIB.Units.PERCENT
        newtonmeter:
            value : -> MUL(self.newFractionValue, self.maxNewtonmeter)
            unit  : -> THISLIB.Units.NEWTONMETER


########################################################################################################################
# AverageCurrent
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB, "AverageCurrent",
    extends: THISLIB.Current


########################################################################################################################
# Duration
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB, "Duration",
    variables_hidden:
        newSecondsValue: { type: t_double, comment: "New duration in seconds" }
    variables_read_only:
        seconds     : { type: THISLIB.QuantityValue, comment: "Duration in seconds" }
        minutes     : { type: THISLIB.QuantityValue, comment: "Duration in minutes" }
    calls:
        seconds:
            value : -> self.newSecondsValue
            unit  : -> THISLIB.Units.SECONDS
        minutes:
            value : -> DIV(self.newSecondsValue, DOUBLE(60.0) "secPerMin")
            unit  : -> THISLIB.Units.MINUTES

########################################################################################################################
# Temperature
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB, "Temperature",
    variables_hidden:
        newCelsiusValue: { type: t_double, comment: "New temperature in degrees Celsius" }
    variables_read_only:
        celsius     : { type: THISLIB.QuantityValue, comment: "Temperature in degrees Celsius" }
        kelvin      : { type: THISLIB.QuantityValue, comment: "Temperature in Kelvin" }
    calls:
        celsius:
            value : -> self.newCelsiusValue
            unit  : -> THISLIB.Units.DEGREES_CELSIUS
        kelvin:
            value : -> SUM(self.newCelsiusValue, DOUBLE(273.15) "zeropoint")
            unit  : -> THISLIB.Units.KELVIN


########################################################################################################################
# Pressure
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB, "Pressure",
    variables_hidden:
        newBarValue: { type: t_double, comment: "New pressure in Bar" }
    variables_read_only:
        bar        : { type: THISLIB.QuantityValue, comment: "Pressure in Bar" }
        pascal     : { type: THISLIB.QuantityValue, comment: "Pressure in Pascal" }
        hectoPascal: { type: THISLIB.QuantityValue, comment: "Pressure in HectoPascal" }
    calls:
        bar:
            value  : -> self.newBarValue
            unit   : -> THISLIB.Units.BAR
        pascal:
            value  : -> MUL(self.newBarValue, DOUBLE(100000) "conversionFactor")
            unit   : -> THISLIB.Units.PASCAL

########################################################################################################################
# Frequency
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB, "Frequency",
    variables_hidden:
        newHertzValue: { type: t_double, comment: "New frequency in Hz" }
    variables_read_only:
        hertz       : { type: THISLIB.QuantityValue, comment: "Frequency in Hertz" }
    calls:
        hertz:
            value : -> self.newHertzValue
            unit  : -> THISLIB.Units.HERTZ

########################################################################################################################
# Force
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB, "Force",
    variables_hidden:
        newNewtonValue  : { type: t_double, comment: "New force in Newton" }
    variables_read_only:
        newton          : { type: THISLIB.QuantityValue, comment: "Force in Newton" }
        decaNewton      : { type: THISLIB.QuantityValue, comment: "Force in decaNewton" }
    calls:
        newton:
            value  : -> self.newNewtonValue
            unit   : -> THISLIB.Units.NEWTON
        decaNewton:
            value  : -> DIV(self.newNewtonValue, DOUBLE(10) "conversionFactor")
            unit   : -> THISLIB.Units.DECANEWTON

########################################################################################################################
# Fraction
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB, "Fraction",
    variables_hidden:
        newFractionValue: { type: t_double, comment: "New fraction (between 0 and 1)" }
    variables_read_only:
        unitless   : { type: THISLIB.QuantityValue, comment: "Fraction as a unitless value between 0 and 1" }
        percent    : { type: THISLIB.QuantityValue, comment: "Fraction as a percentage value between 0 and 100" }
    calls:
        unitless:
            value : -> self.newFractionValue
            unit  : -> THISLIB.Units.UNITLESS
        percent:
            value : -> MUL(self.newFractionValue, DOUBLE(100) "conversionFactor")
            unit  : -> THISLIB.Units.PERCENT


########################################################################################################################
# BaseProcess
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB, "BaseProcess",
    variables_hidden:
        "isEnabled"         : { type: t_bool, comment: "Should the trigger be enabled?" }
    statuses:
        "enabledStatus"     : { type: THISLIB.EnabledStatus    , comment: "Is the process enabled or not?" }
        "busyStatus"        : { type: THISLIB.BusyStatus       , comment: "Is the process busy or not?" }
        "healthStatus"      : { type: THISLIB.HealthStatus     , comment: "Is the process in a healthy state or not?" }
        "startedStatus"     : { type: THISLIB.StartedStatus    , comment: "Is the process started or not?" }
    local:
        do_request          : { type: t_bool                   , comment: "Write TRUE to request the start of the process" }
        do_request_result   : { type: THISLIB.RequestResults   , comment: "Result of the request" }
    calls:
        enabledStatus:
            isEnabled: -> self.isEnabled



########################################################################################################################
# BaseMcProcess
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB,  "BaseMcProcess",
    extends: THISLIB.BaseProcess
    variables:
        errorId: { type: t_uint32, comment: "Error ID according to Beckhoff/PlcOpen Motion Control" }


########################################################################################################################
# ProcessStep
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB, "ProcessStep",
    variables_hidden:
        isEnabled       : { type: t_bool                , comment: "Is the step enabled?" }
    references:
        process         : { type: THISLIB.BaseProcess   , comment: "The process corresponding to the step", expand: false }
    statuses:
        enabledStatus   : { type: THISLIB.EnabledStatus , comment: "Is the process step enabled or not?"  }
    calls:
        enabledStatus:
            isEnabled: -> self.isEnabled



########################################################################################################################
# BaseXmlIOProcess
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB,  "BaseXmlDataSrvProcess",
    extends: THISLIB.BaseProcess
    variables:
        errorId: { type: t_uint32, comment: "Error ID according to Beckhoff XML Data Server library" }


########################################################################################################################
# Process
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "Process", # default process
    extends: THISLIB.BaseProcess


########################################################################################################################
# McProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "McProcess",
    extends: THISLIB.BaseMcProcess
#    variables:
#        testVar : { type: t_uint32 , comment: "Error ID of the PLCopen FB" }


########################################################################################################################
# ChangeSetpointProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "ChangeSetpointProcess",
    extends: THISLIB.BaseProcess
    arguments:
        setpoint     : { type: t_double, comment: "New setpoint value" }

########################################################################################################################
# ChangeParameterProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "ChangeParameterProcess",
    extends: THISLIB.BaseProcess
    arguments:
        parameter     : { type: t_double, comment: "New parameter value" }


########################################################################################################################
# McMoveAbsoluteProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "McMoveAbsoluteProcess",
    extends: THISLIB.BaseMcProcess
    arguments:
        position    : { type: t_double, comment: "New position setpoint" }
        maxVelocity : { type: t_double, comment: "Maximum velocity" }

########################################################################################################################
# McMoveRelativeProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "McMoveRelativeProcess",
    extends: THISLIB.BaseMcProcess
    arguments:
        distance    : { type: t_double, comment: "Distance to move" }
        maxVelocity : { type: t_double, comment: "Maximum velocity" }

########################################################################################################################
# McPowerProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "McPowerProcess",
    extends: THISLIB.BaseMcProcess
    arguments:
        enable    : { type: t_bool, comment: "Enable the power or not" }

########################################################################################################################
# McSetPositionProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "McSetPositionProcess",
    extends: THISLIB.BaseMcProcess
    arguments:
        value   : { type: t_double, comment: "New position to be taken over by the encoder" }

########################################################################################################################
# McStopProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "McStopProcess",
    extends: THISLIB.BaseMcProcess
    arguments:
        deceleration    : { type: t_double, comment: "Deceleration (use 0 for default). If non zero, then also jerk must be non zero!" }
        jerk            : { type: t_double, comment: "Jerk (use 0 for default). If non zero, then also deceleration must be non zero!" }

########################################################################################################################
# McMoveVelocityProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "McMoveVelocityProcess",
    extends: THISLIB.BaseMcProcess
    arguments:
        value   : { type: t_double, comment: "New velocity" }

########################################################################################################################
# SwitchProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "SetEnabledProcess",
    extends: THISLIB.BaseProcess
    arguments:
        enabled : { type: t_bool, comment: "True to enable, false to disable" }

########################################################################################################################
# McWriteParameter
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "McWriteParameter",
    extends: THISLIB.BaseMcProcess
    arguments:
        parameterNumber : { type: t_int16   , comment: "Number of the parameter" }
        value           : { type: t_double  , comment: "Value to write"}


########################################################################################################################
# McReadParameter
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "McReadParameter",
    extends: THISLIB.BaseMcProcess
    arguments:
        parameterNumber : { type: t_int16   , comment: "Number of the parameter" }
    variables:
        value           : { type: t_double  , comment: "Value that was read"}

########################################################################################################################
# McWriteBoolParameter
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "McWriteBoolParameter",
    extends: THISLIB.BaseMcProcess
    arguments:
        parameterNumber : { type: t_int16   , comment: "Number of the parameter" }
        value           : { type: t_bool    , comment: "Value to write"}


########################################################################################################################
# McReadParameter
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "McReadBoolParameter",
    extends: THISLIB.BaseMcProcess
    arguments:
        parameterNumber : { type: t_int16   , comment: "Number of the parameter" }
    variables:
        value           : { type: t_bool  , comment: "Value that was read"}
        
        
########################################################################################################################
# McStartProbing
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "McProbe",
    extends: THISLIB.BaseMcProcess
    arguments:
        risingEdge       : { type: t_bool    , comment: "True to probe the rising edge, false to probe the falling edge" }
        timeout          : { type: t_double  , comment: "Timeout, in seconds. After this timeout, probing is aborted. timeout <= 0 means endless probing." }
    variables:
        recordedPosition : { type: t_double  , comment: "Value that was probed"}



########################################################################################################################
# BaseAxis
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB, "BaseAxis",
    variables_hidden:
        isEnabled           : { type: t_bool                        , comment: "Is control enabled?" }
        standstillTolerance : { type: t_double                      , comment: "Tolerance in [main units] per second: if < ABS(this value), then the axis is considered to be standing still" }
    variables:
        axis_ref            : { type: beckhoff.Tc2_MC2.AXIS_REF     , comment: "The AXIS_REF to be linked to the NC I/O" }
        isGearingSupported  : { type: t_bool , initial: bool(false) , comment: "Is gearIn/gearOut supported?" }
    variables_read_only:
        isJogEnabled        : { type: t_bool                        , comment: "True if jog is enabled" }
    statuses:
        busyStatus          : { type: THISLIB.BusyStatus            , comment: "Is the NcAxis in a busy state?" }
        healthStatus        : { type: THISLIB.HealthStatus          , comment: "Is the NcAxis in a healthy state?" }
        poweredStatus       : { type: THISLIB.PoweredStatus         , comment: "Is the NcAxis powered?" }
        extSetGenStatus     : { type: THISLIB.EnabledStatus         , comment: "Is the NcAxis its external setpoint generator enabled?" }
        motionStatus        : { type: THISLIB.MotionStatus          , comment: "Is the NcAxis moving forward or backward or standing still?" }
    processes:
        moveAbsolute        : { type: THISLIB.McMoveAbsoluteProcess , comment: "Move absolute" }
        moveRelative        : { type: THISLIB.McMoveRelativeProcess , comment: "Move relative" }
        moveVelocity        : { type: THISLIB.McMoveVelocityProcess , comment: "Move at a constant velocity" }
        reset               : { type: THISLIB.McProcess             , comment: "Reset any errors" }
        stop                : { type: THISLIB.McProcess             , comment: "Stop any movement" }
        stopParametrized    : { type: THISLIB.McStopProcess         , comment: "Stop any movement" }
        power               : { type: THISLIB.McPowerProcess        , comment: "Power on/off the axis" }
        gearIn              : { type: THISLIB.McProcess             , comment: "Couple to master axis" }
        gearOut             : { type: THISLIB.McProcess             , comment: "Decouple from master axis" }
        initialize          : { type: THISLIB.Process               , comment: "Start initializing the axis" }
        setPosition         : { type: THISLIB.McSetPositionProcess  , comment: "Set the axis position" }
        enableExtSetGen     : { type: THISLIB.McProcess             , comment: "Enable the external setpoint generator" }
        disableExtSetGen    : { type: THISLIB.McProcess             , comment: "Disable the external setpoint generator" }
        forceCalibration    : { type: THISLIB.McProcess             , comment: "Force the calibration (homing) flag to TRUE" }
        resetCalibration    : { type: THISLIB.McProcess             , comment: "Reset the calibration (homing) flag to FALSE" }
        readParameter       : { type: THISLIB.McReadParameter       , comment: "Read a numerical parameter" }
        readBoolParameter   : { type: THISLIB.McReadBoolParameter   , comment: "Read a boolean parameter" }
        writeParameter      : { type: THISLIB.McWriteParameter      , comment: "Write a numerical parameter" }
        writeBoolParameter  : { type: THISLIB.McWriteBoolParameter  , comment: "Write a boolean parameter" }
        probeStart          : { type: THISLIB.McProbe               , comment: "Start probing a hardware pulse, until a pulse is found" }
        probeAbort          : { type: THISLIB.McProcess             , comment: "Stop probing even though the probe position is not found (yet)" }
    calls:
        busyStatus:
            isBusy                      : -> OR( self.processes.moveAbsolute.statuses.busyStatus.busy,
                                                 self.processes.moveRelative.statuses.busyStatus.busy,
                                                 self.processes.reset.statuses.busyStatus.busy,
                                                 self.processes.power.statuses.busyStatus.busy,
                                                 self.processes.gearIn.statuses.busyStatus.busy,
                                                 self.processes.gearOut.statuses.busyStatus.busy,
                                                 self.processes.initialize.statuses.busyStatus.busy,
                                                 self.processes.setPosition.statuses.busyStatus.busy,
                                                 self.processes.enableExtSetGen.statuses.busyStatus.busy,
                                                 self.processes.disableExtSetGen.statuses.busyStatus.busy,
                                                 self.processes.forceCalibration.statuses.busyStatus.busy,
                                                 self.processes.resetCalibration.statuses.busyStatus.busy,
                                                 self.processes.readParameter.statuses.busyStatus.busy,
                                                 self.processes.readBoolParameter.statuses.busyStatus.busy,
                                                 self.processes.writeParameter.statuses.busyStatus.busy,
                                                 self.processes.writeBoolParameter.statuses.busyStatus.busy,
                                                 self.processes.probeAbort.statuses.busyStatus.busy )
        healthStatus:
            isGood                      : -> NOT(self.axis_ref.Status.Error)
        poweredStatus:
            isEnabled                   : -> NOT( self.axis_ref.Status.Disabled )
        motionStatus:
            actVel                      : -> self.axis_ref.NcToPlc.ActVelo
            tolerance                   : -> self.standstillTolerance
        extSetGenStatus:
            isEnabled                   : -> self.axis_ref.Status.ExtSetPointGenEnabled
        # processes
        power:
            isEnabled                   : -> AND( self.isEnabled, self.processes.power.statuses.busyStatus.idle )
        initialize:
            isEnabled                   : -> AND( self.isEnabled, self.statuses.busyStatus.idle )
        moveAbsolute:
            isEnabled                   : -> self.isEnabled
        moveRelative:
            isEnabled                   : -> self.isEnabled
        moveVelocity:
            isEnabled                   : -> AND( self.isEnabled, self.processes.moveVelocity.statuses.busyStatus.idle )
        reset:
            isEnabled                   : -> AND( self.isEnabled, self.processes.reset.statuses.busyStatus.idle )
        gearIn:
            isEnabled                   : -> AND( self.isEnabled, self.processes.gearIn.statuses.busyStatus.idle, self.isGearingSupported )
        gearOut:
            isEnabled                   : -> AND( self.isEnabled, self.processes.gearOut.statuses.busyStatus.idle, self.isGearingSupported )
        stop:
            isEnabled                   : -> AND( self.isEnabled, self.processes.stop.statuses.busyStatus.idle )
        setPosition:
            isEnabled                   : -> AND( self.isEnabled, self.processes.setPosition.statuses.busyStatus.idle )
        enableExtSetGen:
            isEnabled                   : -> AND( self.isEnabled, self.processes.enableExtSetGen.statuses.busyStatus.idle )
        disableExtSetGen:
            isEnabled                   : -> AND( self.isEnabled, self.processes.disableExtSetGen.statuses.busyStatus.idle )
        forceCalibration:
            isEnabled                   : -> AND( self.isEnabled, self.statuses.busyStatus.idle )
        resetCalibration:
            isEnabled                   : -> AND( self.isEnabled, self.statuses.busyStatus.idle )
        readParameter:
            isEnabled                   : -> AND( self.isEnabled, self.statuses.busyStatus.idle )
        readBoolParameter:
            isEnabled                   : -> AND( self.isEnabled, self.statuses.busyStatus.idle )
        writeParameter:
            isEnabled                   : -> AND( self.isEnabled, self.statuses.busyStatus.idle )
        writeBoolParameter:
            isEnabled                   : -> AND( self.isEnabled, self.statuses.busyStatus.idle )
        probeStart:
            isEnabled                   : -> AND( self.isEnabled, self.statuses.busyStatus.idle )
        probeAbort:
            isEnabled                   : -> AND( self.isEnabled, self.statuses.busyStatus.idle )


########################################################################################################################
# AngularAxis
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB, "AngularAxis",
    extends: THISLIB.BaseAxis
    variables_read_only:
        actPos              : { type: THISLIB.AngularPosition       , comment: "Actual position of the axis" }
        actVel              : { type: THISLIB.AngularVelocity       , comment: "Actual velocity of the axis" }
    calls:
        actPos:
            newDegreesValue             : -> self.axis_ref.NcToPlc.ActPos
        actVel:
            newDegreesPerSecondValue    : -> self.axis_ref.NcToPlc.ActVelo

########################################################################################################################
# LinearAxis
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB, "LinearAxis",
    extends: THISLIB.BaseAxis
    variables_read_only:
        actPos                              : { type: THISLIB.LinearPosition       , comment: "Actual position of the axis" }
        actVel                              : { type: THISLIB.LinearVelocity       , comment: "Actual velocity of the axis" }
    calls:
        actPos:
            newMillimetersValue             : -> self.axis_ref.NcToPlc.ActPos
        actVel:
            newMillimetersPerSecondValue    : -> self.axis_ref.NcToPlc.ActVelo



########################################################################################################################
# SDOReadProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "SDOReadProcess",
    extends: THISLIB.BaseProcess
    arguments:
        index       : { type: t_uint16      , comment: 'SDO Index' }
        subindex    : { type: t_uint8       , comment: 'SDO SubIndex' }
        noOfBytes   : { type: t_uint32      , comment: 'Number of bytes to be read' }
    variables:
        value1Byte  : { type: t_uint8       , comment: "Value that has been read, if noOfBytes is 1" }
        value2Bytes : { type: t_uint16      , comment: "Value that has been read, if noOfBytes is 2" }
        value4Bytes : { type: t_uint32      , comment: "Value that has been read, if noOfBytes is 4" }
        errorId     : { type: t_uint32      , comment: "Error ID according to Beckhoff" }

########################################################################################################################
# SDOWriteProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "SDOWriteProcess",
    extends: THISLIB.BaseProcess
    arguments:
        index       : { type: t_uint16      , comment: 'SDO Index' }
        subindex    : { type: t_uint8       , comment: 'SDO SubIndex' }
        noOfBytes   : { type: t_uint32      , comment: 'Number of bytes to be written' }
        value1Byte  : { type: t_uint8       , comment: "Value to be written if noOfBytes is 1" }
        value2Bytes : { type: t_uint16      , comment: "Value to be written if noOfBytes is 2" }
        value4Bytes : { type: t_uint32      , comment: "Value to be written if noOfBytes is 4" }
    variables:
        errorId     : { type: t_uint32      , comment: "Error ID according to Beckhoff" }


########################################################################################################################
# FaulhaberDriveConfig
########################################################################################################################
MTCS_MAKE_CONFIG THISLIB, "FaulhaberDriveConfig",
    items:
        sendAtInitialization                : { type: t_bool    , comment : "Send the complete config to the drive during initialization" }
        CANopenBusNetId                     : { type: t_string  , comment : "The CANopen bus NetId, as configured via TwinCAT, e.g. '172.16.2.131.2.1'"    }
        CANopenNodePort                     : { type: t_uint16  , comment : "The CANopen node port number, as configured via TwinCAT, e.g. 1005"    }
        modesOfOperation                    : { type: t_uint8   , comment : "0x6060.0: Operating mode changeover" }
        polarity                            : { type: t_uint8   , comment : "0x607E.0: Direction of rotation" }
        maxProfileVelocity                  : { type: t_uint32  , comment : "0x607F.0: Maximum velocity, in rpm" }
        negativeLimitSwitch                 : { type: t_uint8   , comment : "0x2310.1: Lower limit switch configuration" }
        positiveLimitSwitch                 : { type: t_uint8   , comment : "0x2310.2: Upper limit switch configuration" }
        homingSwitch                        : { type: t_uint8   , comment : "0x2310.3: Homing switch configuration" }
        limitSwitchPolarity                 : { type: t_uint8   , comment : "0x2310.5: Limit switch positive edge" }
        continuousCurrentLimit              : { type: t_uint16  , comment : "0x2333.1: Continuous current limit, in milliamps"    }
        peakCurrentLimit                    : { type: t_uint16  , comment : "0x2333.2: Peak current limit, in milliamps"    }
        velocityControlProportionalTerm     : { type: t_uint16  , comment : "0x2331.1: Proportional term (gain) of the velocity control mode"    }
        velocityControlIntegralTerm         : { type: t_uint16  , comment : "0x2331.2: Integral term (gain) of the velocity control mode"    }


########################################################################################################################
# FaulhaberDrive
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB, "FaulhaberDrive",
    variables_hidden:
        isEnabled           : { type: t_bool                            , comment: "Is control enabled?" }
        newMilliampsValue   : { type: t_int16                           , comment: "Current in milliamps, linked to PDO"   , address: "%I*" }
    variables:
        config              : { type: THISLIB.FaulhaberDriveConfig      , comment: "Faulhaber drive config" }
    variables_read_only:
        actualCurrent       : { type: THISLIB.Current                   , comment: "Actual current" }
        averageCurrent      : { type: THISLIB.AverageCurrent            , comment: "Average current" }
    processes:
        write               : { type: THISLIB.SDOWriteProcess           , comment: "Write a number of bytes to the drive" }
        read                : { type: THISLIB.SDOReadProcess            , comment: "Read a number of bytes from the drive" }
        initialize          : { type: THISLIB.Process                   , comment: "Initialize the drive according to the config" }
    statuses:
        busyStatus          : { type: THISLIB.BusyStatus                , comment: "Is the NcAxis in a busy state?" }
        healthStatus        : { type: THISLIB.HealthStatus              , comment: "Is the NcAxis in a healthy state?" }
    calls:
        busyStatus:
            isBusy          : -> OR( self.processes.write.statuses.busyStatus.busy,
                                     self.processes.read.statuses.busyStatus.busy,
                                     self.processes.initialize.statuses.busyStatus.busy )
        healthStatus:
            isGood          : -> AND( self.processes.write.statuses.healthStatus.good,
                                      self.processes.read.statuses.healthStatus.good,
                                      self.processes.initialize.statuses.healthStatus.good )
        actualCurrent:
            newAmpsValue    : -> DIV(self.newMilliampsValue, DOUBLE(1000.0) "milliamp_per_amp")
        averageCurrent:
            newAmpsValue    : -> DIV(self.newMilliampsValue, DOUBLE(1000.0) "milliamp_per_amp")
        read:
            isEnabled       : -> AND( self.isEnabled, self.statuses.busyStatus.idle )
        write:
            isEnabled       : -> AND( self.isEnabled, self.statuses.busyStatus.idle )



########################################################################################################################
# SoEReadProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "SoEReadProcess",
    extends: THISLIB.BaseProcess
    arguments:
        index       : { type: t_uint16      , comment: 'SDO Index' }
        noOfBytes   : { type: t_uint32      , comment: 'Number of bytes to be read' }
    variables:
        value1Byte  : { type: t_uint8       , comment: "Value that has been read, if noOfBytes is 1" }
        value2Bytes : { type: t_uint16      , comment: "Value that has been read, if noOfBytes is 2" }
        value4Bytes : { type: t_uint32      , comment: "Value that has been read, if noOfBytes is 4" }
        adsErrorId      : { type: t_uint16      , comment: "ADS error ID " }
        sercosErrorId   : { type: t_uint16      , comment: "Sercos error ID " }

########################################################################################################################
# SoEWriteProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "SoEWriteProcess",
    extends: THISLIB.BaseProcess
    arguments:
        index       : { type: t_uint16      , comment: 'SDO Index' }
        noOfBytes   : { type: t_uint32      , comment: 'Number of bytes to be written' }
        value1Byte  : { type: t_uint8       , comment: "Value to be written if noOfBytes is 1" }
        value2Bytes : { type: t_uint16      , comment: "Value to be written if noOfBytes is 2" }
        value4Bytes : { type: t_uint32      , comment: "Value to be written if noOfBytes is 4" }
    variables:
        adsErrorId      : { type: t_uint16      , comment: "ADS error ID " }
        sercosErrorId   : { type: t_uint16      , comment: "Sercos error ID " }

########################################################################################################################
# SoEResetProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "SoEResetProcess",
    extends: THISLIB.BaseProcess
    variables:
        adsErrorId      : { type: t_uint16      , comment: "ADS error ID " }
        sercosErrorId   : { type: t_uint16      , comment: "Sercos error ID " }



########################################################################################################################
# DriveOperatingModes
########################################################################################################################
MTCS_MAKE_ENUM THISLIB, "DriveOperatingModes",
    items:
        [   "OPERATING_MODE_NONE",
            "OPERATING_MODE_TORQUE_CONTROL",
            "OPERATING_MODE_VELOCITY_CONTROL",
            "OPERATING_MODE_POSITION_CONTROL"   ]


########################################################################################################################
# DriveBrakeStates
########################################################################################################################
MTCS_MAKE_ENUM THISLIB, "DriveBrakeStates",
    items:
        [   "BRAKE_AUTOMATIC",
            "BRAKE_FORCE_LOCK",
            "BRAKE_FORCE_UNLOCK"  ]

########################################################################################################################
# SetBrakeProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "SetBrakeProcess",
    extends: THISLIB.BaseProcess
    arguments:
        newState  : { type: THISLIB.DriveBrakeStates, comment: "Requested brake state" }



########################################################################################################################
# AX52XXDriveChannel
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB, "AX52XXDriveChannel",
    variables:
        errorC1D                : { type: t_int16                     , comment: "Class 1 Diagnostic (C1D" , address: '%I*' }
        isEnabled               : { type: t_bool                      , comment: "Is control enabled?" }
        torqueFeedbackValue     : { type: t_int16                     , comment: "Torque feedback, cyclically updated by the drive channel" , address: '%I*' }
        torqueCommandValue      : { type: t_int16                     , comment: "Torque command (only in case of torque control!)" , address: '%Q*' }
        digitalInputs           : { type: t_int16                     , comment: "Digital inputs (e.g. bit 0 = 1 if input 0 = high), cyclically updated by the drive channel", address: '%I*' }
        digitalOutputs          : { type: t_int16                     , comment: "Digital outputs (e.g. bit 0 = 1 if input 0 = high), cyclically updated by the drive channel", address: '%Q*' }
        safetyOptionState       : { type: t_int16                     , comment: "Safety option state (P-0-2002)" , address: '%I*' }
        diagnosticNumber        : { type: t_uint32                    , comment: "Diagnostic number" , address: '%I*' }
    variables_read_only:
        isInSafetate            : { type: t_bool                      , comment: "True if the drive is in safe state" }
        actualTorqueFeedback    : { type: THISLIB.Torque              , comment: "The actual torque feedback value (updated constantly!)" }
        channelPeakCurrent      : { type: THISLIB.Current             , comment: "The configured channel peak current" }
        channelRatedCurrent     : { type: THISLIB.Current             , comment: "The configured channel peak current" }
        continuousStallTorque   : { type: THISLIB.Torque              , comment: "The motor continuous stall torque" }
        continuousStallCurrent  : { type: THISLIB.Current             , comment: "The motor continuous stall current" }
        torqueConstant          : { type: t_double                    , comment: "The motor torque constant, in Nm/A" }
        bipolarTorqueLimit      : { type: THISLIB.TorqueLimit         , comment: "The drive bipolar torque limit" }
        positiveTorqueLimit     : { type: THISLIB.TorqueLimit         , comment: "The drive positive torque limit" }
        negativeTorqueLimit     : { type: THISLIB.TorqueLimit         , comment: "The drive negative torque limit" }
        operatingMode           : { type: THISLIB.DriveOperatingModes , comment: "The drive operating mode, as an ENUM value" }
        operatingModeDescription: { type: t_string                    , comment: "The drive operating mode, as a descriptive text" }
        brakeState              : { type: THISLIB.DriveBrakeStates    , comment: "The drive brake state, as an ENUM value" }
        brakeStateDescription   : { type: t_string                    , comment: "The drive brake state, as a descriptive text" }
        torqueCommand           : { type: THISLIB.TorqueLimit         , comment: "The torque command (only in case of torque control!)" }
        safetyErrorAck          : { type: t_bool                      , comment: "Error acknowledge of AX5805 safety card" , address: '%Q*' }
    processes:
        read                    : { type: THISLIB.SoEReadProcess      , comment: "Read a number of bytes from the drive" }
        write                   : { type: THISLIB.SoEWriteProcess     , comment: "Write a number of bytes to the drive" }
        update                  : { type: THISLIB.Process             , comment: "Update the actual values" }
        reset                   : { type: THISLIB.SoEResetProcess     , comment: "Reset the drive channel" }
        acknowledgeSafetyError  : { type: THISLIB.Process             , comment: "Acknowledge the safety card error state" }
        setBrake                : { type: THISLIB.SetBrakeProcess     , comment: "Update the actual values" }
    statuses:
        busyStatus              : { type: THISLIB.BusyStatus          , comment: "Is the drive in a busy state?" }
        healthStatus            : { type: THISLIB.HealthStatus        , comment: "Is the drive in a healthy state?" }
    calls:
        # variables
        actualTorqueFeedback:
            newNewtonmeterValue : -> MUL( MUL( DIV(self.torqueFeedbackValue, DOUBLE(1000.0) "divisor"), self.channelPeakCurrent.amps.value), self.torqueConstant )
        torqueCommand:
            newFractionValue    : -> DIV(self.torqueCommandValue, DOUBLE(1000.0) "divisor")
            maxNewtonmeter      : -> MUL(self.channelPeakCurrent.amps.value, self.torqueConstant)
        # statuses
        busyStatus:
            isBusy          : -> MTCS_SUMMARIZE_BUSY(self.processes.write,
                                                     self.processes.read,
                                                     self.processes.update,
                                                     self.processes.reset,
                                                     self.processes.acknowledgeSafetyError)
        healthStatus:
            isGood          : -> MTCS_SUMMARIZE_GOOD(self.processes.write,
                                                     self.processes.read,
                                                     self.processes.update,
                                                     self.processes.reset,
                                                     self.processes.acknowledgeSafetyError)
            hasWarning      : -> MTCS_SUMMARIZE_WARN(self.processes.write,
                                                     self.processes.read,
                                                     self.processes.update,
                                                     self.processes.reset,
                                                     self.processes.acknowledgeSafetyError)
        # processes
        read:
            isEnabled       : -> AND( self.isEnabled, self.statuses.busyStatus.idle )
        write:
            isEnabled       : -> AND( self.isEnabled, self.statuses.busyStatus.idle )
        update:
            isEnabled       : -> self.statuses.busyStatus.idle
        reset:
            isEnabled       : -> self.statuses.busyStatus.idle
        setBrake:
            isEnabled       : -> AND( self.isEnabled, self.statuses.busyStatus.idle )
        acknowledgeSafetyError:
            isEnabled       : -> AND( self.isEnabled, self.processes.acknowledgeSafetyError.statuses.busyStatus.idle )

########################################################################################################################
# AX52XXDrive
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB, "AX52XXDrive",
    variables_hidden:
        isEnabled           : { type: t_bool                            , comment: "Is control enabled?" }
    statuses:
        busyStatus          : { type: THISLIB.BusyStatus                , comment: "Is the drive in a busy state?" }
        healthStatus        : { type: THISLIB.HealthStatus              , comment: "Is the drive in a healthy state?" }
    parts:
        channelA            : { type: THISLIB.AX52XXDriveChannel        , comment: "Channel A" }
        channelB            : { type: THISLIB.AX52XXDriveChannel        , comment: "Channel B" }
    calls:
        channelA:
            isEnabled       : -> self.isEnabled
        channelB:
            isEnabled       : -> self.isEnabled
        busyStatus:
            isBusy          : -> MTCS_SUMMARIZE_WARN(self.parts.channelA, self.parts.channelB)
        healthStatus:
            isGood          : -> MTCS_SUMMARIZE_GOOD(self.parts.channelA, self.parts.channelB)
            hasWarning      : -> MTCS_SUMMARIZE_WARN(self.parts.channelA, self.parts.channelB)


#########################################################################################################################
## AX52XXDrive
#########################################################################################################################
#MTCS_MAKE_ENUM THISLIB, "AX52XXDrive",
#    items:
#        [  "A",
#           "B"  ]

########################################################################################################################
# SSIEncoder
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB, "SSIEncoder",
    variables_hidden:
        counterValue    : { type: t_uint32                  , comment: "Counter value"                  , address: "%I*" }
        status          : { type: t_uint16                  , comment: "Status"                         , address: "%I*" }
    variables_read_only:
        dataError       : { type: t_bool                    , comment: "Data error"                    , address: "%I*" }
        frameError      : { type: t_bool                    , comment: "Frame error"                   , address: "%I*" }
        powerFailure    : { type: t_bool                    , comment: "Power failure"                 , address: "%I*" }
        syncError       : { type: t_bool                    , comment: "Sync error"                    , address: "%I*" }
    statuses:
        healthStatus    : { type: THISLIB.HealthStatus, comment: "Is the device in a healthy state?" }
    calls:
        healthStatus:
            isGood      : -> NOT( OR(self.dataError, self.frameError, self.powerFailure, self.syncError) )

########################################################################################################################
# IncrementalEncoder
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB, "IncrementalEncoder",
    variables_hidden:
        isEnabled           : { type: t_bool                    , comment: "Is control enabled?" }
        counterValue        : { type: t_uint32                  , comment: "Actual counter value"       , address: "%I*" }
        status              : { type: t_uint16                  , comment: "Status"                     , address: "%I*" }
        setCounterValue     : { type: t_uint32                  , comment: "Counter value to be set"    , address: "%Q*" }
        setCounter          : { type: t_bool                    , comment: "Counter value to be set"    , address: "%Q*" }
        enableLatchC        : { type: t_bool                    , comment: "Enable latch C"             , address: "%Q*" }
    variables_read_only:
        latchCValid         : { type: t_bool                    , comment: "Bit 0: Latch C valid"  }
        latchExternValid    : { type: t_bool                    , comment: "Bit 1: Latch extern valid"  }
        setCounterDone      : { type: t_bool                    , comment: "Bit 2: Set counter done"  }
        counterUnderflow    : { type: t_bool                    , comment: "Bit 3: Counter undeflow"  }
        counterOverflow     : { type: t_bool                    , comment: "Bit 4: Counter overflow"  }
        statusOfInputStatus : { type: t_bool                    , comment: "Bit 5: Status of input status"  }
        openCircuit         : { type: t_bool                    , comment: "Bit 6: Open circuit"  }
        extrapolationStall  : { type: t_bool                    , comment: "Bit 7: Extrapolation stall"  }
        statusOfInputA      : { type: t_bool                    , comment: "Bit 8: Status of input A"  }
        statusOfInputB      : { type: t_bool                    , comment: "Bit 9: Status of input B"  }
        statusOfInputC      : { type: t_bool                    , comment: "Bit 10: Status of input C"  }
        statusOfInputGate   : { type: t_bool                    , comment: "Bit 11: Status of input gate"  }
        statusOfExternLatch : { type: t_bool                    , comment: "Bit 12: Status of external latch"  }
        syncError           : { type: t_bool                    , comment: "Bit 13: Sync error"  }
    statuses:
        healthStatus        : { type: THISLIB.HealthStatus      , comment: "Is the device in a healthy state?" }
        busyStatus          : { type: THISLIB.BusyStatus        , comment: "Is the device in a busy state?" }
    processes:
        enableCounterResetC : { type: THISLIB.Process           , comment: "Enable the counter reset on the C pulse" }
        disableCounterResetC: { type: THISLIB.Process           , comment: "Disable the counter reset on the C pulse" }
    calls:
        healthStatus:
            isGood          : -> NOT( OR(   NOT(self.statusOfInputStatus),
                                            self.openCircuit,
                                            self.extrapolationStall,
                                            self.syncError) )
        busyStatus:
            isBusy          : -> MTCS_SUMMARIZE_BUSY(self.processes.enableCounterResetC, self.processes.disableCounterResetC)
        enableCounterResetC:
            isEnabled       : -> self.isEnabled
        disableCounterResetC:
            isEnabled       : -> self.isEnabled


########################################################################################################################
# EtherCatDevice
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB, "EtherCatDevice",
    variables:
        id       : { type: t_string , comment: "Label according to the electric schemes" }
        typeId   : { type: t_string , comment: "Manufacturer type, e.g. EL1008" }
        wcState  : { type: t_bool   , comment: "0 = Data valid, 1 = Data invalid" , address: "%I*" }
        infoData : { type: t_uint16 , comment: "EtherCAT state"                   , address: "%I*" }
    statuses:
        healthStatus : { type: THISLIB.HealthStatus, comment: "Is the device in a healthy state?" }
    calls:
        healthStatus:
            isGood  : -> AND( EQ(self.wcState, FALSE), EQ(self.infoData, UINT16(8) "etherCatInOPState" ) )

########################################################################################################################
# CANopenBus
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB, "CANopenBus",
    variables:
        error          : { type: t_uint8  , comment: "Number of boxes with BoxState unequal to 0"             , address: "%I*" }
        canState       : { type: t_uint16 , comment: "CAN state (See system manager for bit interpretation"   , address: "%I*" }
        rxErrorCounter : { type: t_uint8  , comment: "RxError-counter of the CAN controller"                  , address: "%I*" }
        txErrorCounter : { type: t_uint8  , comment: "TxError-counter of the CAN controller"                  , address: "%I*" }
    statuses:
        healthStatus : { type: THISLIB.HealthStatus, comment: "Is the device in a healthy state?" }
    calls:
        healthStatus:
            isGood  : -> EQ(self.error, UINT8(0) "noError" )

########################################################################################################################
# CurrentMeasurement
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB, "CurrentMeasurement",
    variables_hidden:
        microAmpsValue  : { type: t_int32              , comment: "Measured current in microamps"   , address: "%I*" }
        error           : { type: t_bool               , comment: "Error"                           , address: "%I*" }
    variables_read_only:
        current         : { type: THISLIB.Current      , comment: "The measured current" }
    statuses:
        healthStatus    : { type: THISLIB.HealthStatus , comment: "Is the measurement valid?" }
    calls:
        healthStatus:
            isGood       : -> NOT(self.error)
        current:
            newAmpsValue : -> DIV(self.microAmpsValue, DOUBLE(1000000) "microamp_per_amp")


########################################################################################################################
# VoltageMeasurement
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB, "VoltageMeasurement",
    variables_hidden:
        rawValue        : { type: t_int16              , comment: "Measured raw value"                                        , address: "%I*" }
        error           : { type: t_bool               , comment: "Error"                                                     , address: "%I*" }
        conversionFactor: { type: t_double             , comment: "rawValue * conversionFactor = volt.value"   , initial: double(10.0 / Math.pow(2,15))}
    variables_read_only:
        actual          : { type: THISLIB.Voltage      , comment: "Actual value" }
        average         : { type: THISLIB.Voltage      , comment: "Moving average value" }
        underrange      : { type: t_bool               , comment: "Underrange"                      , address: "%I*" }
        overrange       : { type: t_bool               , comment: "Overrange"                       , address: "%I*" }
    references:
        config          : { type: THISLIB.MeasurementConfig    , comment: "Reference to the config (alarms in volts)" }
    statuses:
        enabledStatus   : { type: THISLIB.EnabledStatus        , comment: "Is the voltage being measured?" }
        healthStatus    : { type: THISLIB.HealthStatus         , comment: "Is the measurement OK?" }
        alarmStatus     : { type: THISLIB.HiHiLoLoAlarmStatus  , comment: "Alarm status"}
    calls:
        enabledStatus:
            isEnabled    : -> self.config.enabled
        alarmStatus:
            superState   : -> self.statuses.enabledStatus.enabled
            config       : -> self.config.alarms
            value        : -> self.average.volt.value
        healthStatus:
            superState   : -> self.statuses.enabledStatus.enabled
            isGood       : -> NOT( OR(self.error,
                                      self.underrange,
                                      self.overrange,
                                      self.statuses.alarmStatus.hiHi,
                                      self.statuses.alarmStatus.loLo))
            hasWarning   : -> OR( self.statuses.alarmStatus.hi,
                                  self.statuses.alarmStatus.lo )
        actual:
            newVoltValue : -> SUM(MUL(self.rawValue, self.conversionFactor), self.config.offset)

########################################################################################################################
# TemperatureMeasurement
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB, "TemperatureMeasurement",
    variables_hidden:
        rawValue        : { type: t_int16              , comment: "Measured raw value"                                        , address: "%I*" }
        error           : { type: t_bool               , comment: "Error"                                                     , address: "%I*" } #&#176;
        conversionFactor: { type: t_double             , comment: "rawValue * conversionFactor = temperature.degrees.value"   , initial: double(0.01)}
    variables_read_only:
        actual          : { type: THISLIB.Temperature  , comment: "Actual value" }
        average         : { type: THISLIB.Temperature  , comment: "Moving average value" }
        underrange      : { type: t_bool               , comment: "Underrange"                      , address: "%I*" }
        overrange       : { type: t_bool               , comment: "Overrange"                       , address: "%I*" }
    references:
        config          : { type: THISLIB.MeasurementConfig    , comment: "Reference to the config (alarms in degrees celsius)" }
    statuses:
        enabledStatus   : { type: THISLIB.EnabledStatus        , comment: "Is the temperature being measured?" }
        healthStatus    : { type: THISLIB.HealthStatus         , comment: "Is the measurement OK?" }
        alarmStatus     : { type: THISLIB.HiHiLoLoAlarmStatus  , comment: "Alarm status"}
    calls:
        enabledStatus:
            isEnabled    : -> self.config.enabled
        alarmStatus:
            superState   : -> self.statuses.enabledStatus.enabled
            config       : -> self.config.alarms
            value        : -> self.average.celsius.value
        healthStatus:
            superState   : -> self.statuses.enabledStatus.enabled
            isGood       : -> NOT( OR(self.error,
                                      self.underrange,
                                      self.overrange,
                                      self.statuses.alarmStatus.hiHi,
                                      self.statuses.alarmStatus.loLo))
            hasWarning   : -> OR( self.statuses.alarmStatus.hi,
                                  self.statuses.alarmStatus.lo )
        actual:
            newCelsiusValue : -> SUM(MUL(self.rawValue, self.conversionFactor), self.config.offset)



########################################################################################################################
# PressureMeasurement
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB, "PressureMeasurement",
    variables_hidden:
        rawValue        : { type: t_int16              , comment: "Measured raw value"                                       , address: "%I*" }
        error           : { type: t_bool               , comment: "Error"                                                    , address: "%I*" }
        conversionFactor: { type: t_double             , comment: "rawValue * conversionFactor = bar.value"                  , initial: double(1) }
    variables_read_only:
        actual          : { type: THISLIB.Pressure     , comment: "Actual value" }
        average         : { type: THISLIB.Pressure     , comment: "Moving average value" }
        underrange      : { type: t_bool               , comment: "Underrange"                      , address: "%I*" }
        overrange       : { type: t_bool               , comment: "Overrange"                       , address: "%I*" }
    references:
        config          : { type: THISLIB.MeasurementConfig    , comment: "Reference to the config (alarms in bar)" }
    statuses:
        enabledStatus   : { type: THISLIB.EnabledStatus        , comment: "Is the pressure being measured?" }
        healthStatus    : { type: THISLIB.HealthStatus         , comment: "Is the measurement OK?" }
        alarmStatus     : { type: THISLIB.HiHiLoLoAlarmStatus  , comment: "Alarm status"}
    calls:
        enabledStatus:
            isEnabled    : -> self.config.enabled
        alarmStatus:
            superState   : -> self.statuses.enabledStatus.enabled
            config       : -> self.config.alarms
            value        : -> self.average.bar.value
        healthStatus:
            superState   : -> self.statuses.enabledStatus.enabled
            isGood       : -> NOT( OR(self.error,
                                      self.underrange,
                                      self.overrange,
                                      self.statuses.alarmStatus.hiHi,
                                      self.statuses.alarmStatus.loLo))
            hasWarning   : -> OR( self.statuses.alarmStatus.hi,
                                  self.statuses.alarmStatus.lo )
        actual:
            newBarValue  : -> SUM(MUL(self.rawValue, self.conversionFactor), self.config.offset)


########################################################################################################################
# FrequencyMeasurement
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB, "FrequencyMeasurement",
    variables_hidden:
        rawValue        : { type: t_int16              , comment: "Measured raw value"                                       , address: "%I*" }
        error           : { type: t_bool               , comment: "Error"                                                    , address: "%I*" }
        conversionFactor: { type: t_double             , comment: "rawValue * conversionFactor = hertz.value"                , initial: double(1) }
    variables_read_only:
        actual          : { type: THISLIB.Frequency    , comment: "Actual value" }
        average         : { type: THISLIB.Frequency    , comment: "Moving average value" }
        underrange      : { type: t_bool               , comment: "Underrange"                      , address: "%I*" }
        overrange       : { type: t_bool               , comment: "Overrange"                       , address: "%I*" }
    references:
        config          : { type: THISLIB.MeasurementConfig    , comment: "Reference to the config (alarms in hertz)" }
    statuses:
        enabledStatus   : { type: THISLIB.EnabledStatus        , comment: "Is the frequency being measured?" }
        healthStatus    : { type: THISLIB.HealthStatus         , comment: "Is the measurement OK?" }
        alarmStatus     : { type: THISLIB.HiHiLoLoAlarmStatus  , comment: "Alarm status"}
    calls:
        enabledStatus:
            isEnabled    : -> self.config.enabled
        alarmStatus:
            superState   : -> self.statuses.enabledStatus.enabled
            config       : -> self.config.alarms
            value        : -> self.average.hertz.value
        healthStatus:
            superState   : -> self.statuses.enabledStatus.enabled
            isGood       : -> NOT( OR(self.error,
                                      self.underrange,
                                      self.overrange,
                                      self.statuses.alarmStatus.hiHi,
                                      self.statuses.alarmStatus.loLo))
            hasWarning   : -> OR( self.statuses.alarmStatus.hi,
                                  self.statuses.alarmStatus.lo )
        actual:
            newHertzValue: -> SUM(MUL(self.rawValue, self.conversionFactor), self.config.offset)


########################################################################################################################
# GForceMeasurement
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB, "GForceMeasurement",
    variables_hidden:
        milliGValue     : { type: t_int16              , comment: "Measured raw milliG value (linked to I/O module)"         , address: "%I*" }
        error           : { type: t_bool               , comment: "Error"                                                    , address: "%I*" }
    variables_read_only:
        actual          : { type: THISLIB.GForce       , comment: "Actual value" }
        average         : { type: THISLIB.GForce       , comment: "Moving average value" }
#    references:
#        config          : { type: THISLIB.MeasurementConfig    , comment: "Reference to the config (alarms in milli g)" }
    statuses:
#        enabledStatus   : { type: THISLIB.EnabledStatus        , comment: "Is the frequency being measured?" }
        healthStatus    : { type: THISLIB.HealthStatus         , comment: "Is the measurement OK?" }
#        alarmStatus     : { type: THISLIB.HiHiLoLoAlarmStatus  , comment: "Alarm status"}
    calls:
#        enabledStatus:
#            isEnabled    : -> self.config.enabled
#        alarmStatus:
#            superState   : -> self.statuses.enabledStatus.enabled
#            config       : -> self.config.alarms
#            value        : -> self.average.milliG.value
#        healthStatus:
#            superState   : -> self.statuses.enabledStatus.enabled
#            isGood       : -> NOT( OR(self.error,
#                                      self.statuses.alarmStatus.hiHi,
#                                      self.statuses.alarmStatus.loLo))
#            hasWarning   : -> OR( self.statuses.alarmStatus.hi,
#                                  self.statuses.alarmStatus.lo )
        healthStatus:
            isGood       : -> NOT( self.error )
        actual:
            newMilliGValue: -> self.milliGValue


########################################################################################################################
# RelativeHumidityMeasurement
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB, "RelativeHumidityMeasurement",
    variables_hidden:
        rawValue        : { type: t_int16              , comment: "Measured raw value"                           , address: "%I*" }
        error           : { type: t_bool               , comment: "Error"                                        , address: "%I*" }
        conversionFactor: { type: t_double             , comment: "rawValue * conversionFactor = fraction.value", initial: double(1.0/(Math.pow(2,15)-1))}
    variables_read_only:
        actual          : { type: THISLIB.Fraction     , comment: "Actual value" }
        average         : { type: THISLIB.Fraction     , comment: "Moving average value" }
        underrange      : { type: t_bool               , comment: "Underrange"                      , address: "%I*" }
        overrange       : { type: t_bool               , comment: "Overrange"                       , address: "%I*" }
    references:
        config          : { type: THISLIB.MeasurementConfig    , comment: "Reference to the config (alarms in percent)" }
    statuses:
        enabledStatus   : { type: THISLIB.EnabledStatus        , comment: "Is the relative humidity being measured?" }
        healthStatus    : { type: THISLIB.HealthStatus         , comment: "Is the measurement OK?" }
        alarmStatus     : { type: THISLIB.HiHiLoLoAlarmStatus  , comment: "Alarm status"}
    calls:
        enabledStatus:
            isEnabled    : -> self.config.enabled
        alarmStatus:
            superState   : -> self.statuses.enabledStatus.enabled
            config       : -> self.config.alarms
            value        : -> self.average.percent.value
        healthStatus:
            superState   : -> self.statuses.enabledStatus.enabled
            isGood       : -> NOT( OR( AND(self.error, OR(self.underrange, self.overrange)),
                                       self.statuses.alarmStatus.hiHi,
                                       self.statuses.alarmStatus.loLo))
            hasWarning   : -> OR( self.statuses.alarmStatus.hi,
                                  self.statuses.alarmStatus.lo )
        actual:
            newFractionValue : -> SUM(MUL(MUL(self.rawValue, self.conversionFactor),self.config.gain), self.config.offset)

########################################################################################################################
# ForceMeasurement
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB, "ForceMeasurement",
    variables_hidden:
        rawValue        : { type: t_int32              , comment: "Measured raw value"                                       , address: "%I*" }
        error           : { type: t_bool               , comment: "Error"                                                    , address: "%I*" }
        underrange      : { type: t_bool               , comment: "Underrange"                                               , address: "%I*" }
        overrange       : { type: t_bool               , comment: "Overrange"                                                , address: "%I*" }
        conversionFactor: { type: t_double             , comment: "rawValue * conversionFactor = newton.value"         , initial: double(1) }
    variables_read_only:
        actual          : { type: THISLIB.Force        , comment: "Actual value" }
        average         : { type: THISLIB.Force        , comment: "Moving average value" }
    references:
        config          : { type: THISLIB.MeasurementConfig    , comment: "Reference to the config (alarms in Newton)" }
    statuses:
        enabledStatus   : { type: THISLIB.EnabledStatus        , comment: "Is the force being measured?" }
        healthStatus    : { type: THISLIB.HealthStatus         , comment: "Is the measurement OK?" }
        alarmStatus     : { type: THISLIB.HiHiLoLoAlarmStatus  , comment: "Alarm status"}
    calls:
        enabledStatus:
            isEnabled    : -> self.config.enabled
        alarmStatus:
            superState   : -> self.statuses.enabledStatus.enabled
            config       : -> self.config.alarms
            value        : -> self.average.newton.value
        healthStatus:
            superState   : -> self.statuses.enabledStatus.enabled
            isGood       : -> NOT( OR(self.error,
                                      self.underrange,
                                      self.overrange,
                                      self.statuses.alarmStatus.hiHi,
                                      self.statuses.alarmStatus.loLo))
            hasWarning   : -> OR( self.statuses.alarmStatus.hi,
                                  self.statuses.alarmStatus.lo )
        actual:
            newNewtonValue: -> SUM(MUL(self.rawValue, self.conversionFactor), self.config.offset)

########################################################################################################################
# LinearPositionMeasurement16
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB, "LinearPositionMeasurement16",
    variables_hidden:
        rawValue        : { type: t_int16              , comment: "Measured raw value"                                       , address: "%I*" }
        error           : { type: t_bool               , comment: "Error"                                                    , address: "%I*" }
        underrange      : { type: t_bool               , comment: "Underrange"                                               , address: "%I*" }
        overrange       : { type: t_bool               , comment: "Overrange"                                                , address: "%I*" }
        conversionFactor: { type: t_double             , comment: "rawValue * conversionFactor = millimeters.value"          , initial: double(1.0/(Math.pow(2,15)-1)) }
    variables_read_only:
        actual          : { type: THISLIB.LinearPosition, comment: "Actual value" }
        average         : { type: THISLIB.LinearPosition, comment: "Moving average value" }
    references:
        config          : { type: THISLIB.MeasurementConfig    , comment: "Reference to the config (alarms in millimeters)" }
    statuses:
        enabledStatus   : { type: THISLIB.EnabledStatus        , comment: "Is the position being measured?" }
        healthStatus    : { type: THISLIB.HealthStatus         , comment: "Is the measurement OK?" }
        alarmStatus     : { type: THISLIB.HiHiLoLoAlarmStatus  , comment: "Alarm status"}
    calls:
        enabledStatus:
            isEnabled    : -> self.config.enabled
        alarmStatus:
            superState   : -> self.statuses.enabledStatus.enabled
            config       : -> self.config.alarms
            value        : -> self.average.millimeters.value
        healthStatus:
            superState   : -> self.statuses.enabledStatus.enabled
            isGood       : -> NOT( OR(self.error,
                                      self.underrange,
                                      self.overrange,
                                      self.statuses.alarmStatus.hiHi,
                                      self.statuses.alarmStatus.loLo))
            hasWarning   : -> OR( self.statuses.alarmStatus.hi,
                                  self.statuses.alarmStatus.lo )
        actual:
            newMillimetersValue: -> SUM(MUL(self.rawValue, self.conversionFactor), self.config.offset)

########################################################################################################################
# LinearPositionMeasurementU32
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB, "LinearPositionMeasurementU32",
    variables_hidden:
        rawValue        : { type: t_uint32             , comment: "Measured raw value"                                       , address: "%I*" }
        error           : { type: t_bool               , comment: "Error"                                                    , address: "%I*" }
        underrange      : { type: t_bool               , comment: "Underrange"                                               , address: "%I*" }
        overrange       : { type: t_bool               , comment: "Overrange"                                                , address: "%I*" }
        conversionFactor: { type: t_double             , comment: "rawValue * conversionFactor = millimeters.value"          , initial: double(1.0/(Math.pow(2,31)-1)) }
    variables_read_only:
        actual          : { type: THISLIB.LinearPosition, comment: "Actual value" }
        average         : { type: THISLIB.LinearPosition, comment: "Moving average value" }
    references:
        config          : { type: THISLIB.MeasurementConfig    , comment: "Reference to the config (alarms in millimeters)" }
    statuses:
        enabledStatus   : { type: THISLIB.EnabledStatus        , comment: "Is the position being measured?" }
        healthStatus    : { type: THISLIB.HealthStatus         , comment: "Is the measurement OK?" }
        alarmStatus     : { type: THISLIB.HiHiLoLoAlarmStatus  , comment: "Alarm status"}
    calls:
        enabledStatus:
            isEnabled    : -> self.config.enabled
        alarmStatus:
            superState   : -> self.statuses.enabledStatus.enabled
            config       : -> self.config.alarms
            value        : -> self.average.millimeters.value
        healthStatus:
            superState   : -> self.statuses.enabledStatus.enabled
            isGood       : -> NOT( OR(self.error,
                                      self.underrange,
                                      self.overrange,
                                      self.statuses.alarmStatus.hiHi,
                                      self.statuses.alarmStatus.loLo))
            hasWarning   : -> OR( self.statuses.alarmStatus.hi,
                                  self.statuses.alarmStatus.lo )
        actual:
            newMillimetersValue: -> SUM(MUL(self.rawValue, self.conversionFactor), self.config.offset)

########################################################################################################################
# SimpleRelay
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB, "SimpleRelay",
    variables_hidden:
        isEnabled   : { type: t_bool                        , comment: "Is control enabled?" }
    variables_read_only:
        digitalOutput: { type: t_bool                       , comment: "Boolean, to bind to digital output"   , address: "%Q*" }
    processes:
        setEnabled  : { type: THISLIB.SetEnabledProcess     , comment: "Set the relay enabled or disabled" }
    statuses:
        busyStatus  : { type: THISLIB.BusyStatus            , comment: "Is the SimpleRelay in a busy state?" }
    calls:
        setEnabled:
            isEnabled   : -> AND( self.isEnabled, self.processes.setEnabled.statuses.busyStatus.idle )
        busyStatus:
            isBusy      : -> self.processes.setEnabled.statuses.busyStatus.busy



########################################################################################################################
# ChangeOperatingStateProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "ChangeOperatingStateProcess",
    extends: THISLIB.BaseProcess
    arguments:
        state : { type: THISLIB.OperatingStates, comment: "New operating state (e.g. AUTO, MANUAL)" }



########################################################################################################################
# ChangeOperatorStateProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "ChangeOperatorStateProcess",
    extends: THISLIB.BaseProcess
    arguments:
        state       : { type: THISLIB.OperatorStates    , comment: "New operator state (e.g. OBSERVER, TECH, ...)" }
        password    : { type: t_string                  , comment: "Password (only sometimes required, e.g. to go from OBSERVER to TECH)"  }



########################################################################################################################
# ChangeOperatingModeStateProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "ChangeOperatingModeStateProcess",
    extends: THISLIB.BaseProcess
    arguments:
        state : { type: THISLIB.OperatingModeStates, comment: "New operating state (e.g. LOCAL, REMOTE)" }


########################################################################################################################
# ReadXmlProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "ReadXmlProcess",
    extends: THISLIB.BaseXmlDataSrvProcess
    arguments:
        filePath : { type: t_string, comment: "Full path of the filename to read" }

########################################################################################################################
# WriteXmlProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "WriteXmlProcess",
    extends: THISLIB.BaseXmlDataSrvProcess
    arguments:
        filePath : { type: t_string, comment: "Full path of the filename to write" }


########################################################################################################################
# ActivateProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "ActivateProcess",
    extends: THISLIB.BaseProcess

########################################################################################################################
# ConfigManager
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB, "ConfigManager",
    variables_hidden:
        isEnabled       : { type: t_bool                        , comment: "Is control enabled?" }
    variables:
        filePath        : { type: t_string                      , comment: "Full path of the config filename" }
    processes:
        save            : { type: THISLIB.WriteXmlProcess       , comment: "Save the currently active config to disk" }
        load            : { type: THISLIB.ReadXmlProcess        , comment: "Load the config from disk" }
        activate        : { type: THISLIB.ActivateProcess       , comment: "Activate the loaded config" }
    statuses:
        busyStatus      : { type: THISLIB.BusyStatus            , comment: "Is the config manager in a busy state?" }
        healthStatus    : { type: THISLIB.HealthStatus          , comment: "Is the config manager in a healthy state?" }
    calls:
        # statuses
        busyStatus:
            isBusy      : -> OR( self.processes.save.statuses.busyStatus.busy,
                                 self.processes.load.statuses.busyStatus.busy,
                                 self.processes.activate.statuses.busyStatus.busy )
        healthStatus:
            isGood      : -> MTCS_SUMMARIZE_GOOD(self.processes.save, self.processes.load, self.processes.activate)
            hasWarning  : -> MTCS_SUMMARIZE_WARN(self.processes.save, self.processes.load, self.processes.activate)
        # processes
        save:
            isEnabled   : -> AND( self.isEnabled, self.statuses.busyStatus.idle )
        load:
            isEnabled   : -> AND( self.isEnabled, self.statuses.busyStatus.idle )
        activate:
            isEnabled   : -> AND( self.isEnabled, self.statuses.busyStatus.idle )


########################################################################################################################
# MTCSInstrumentConfig
########################################################################################################################
MTCS_MAKE_CONFIG THISLIB, "InstrumentConfig",
    items:
        name:
            type: t_string
            comment: "Name of the instrument"
        doInitialThermalFocus:
            type: t_bool
            comment: "Do a thermal focus when changing to this instrument"
        changeM3:
            type: t_bool
            comment: "Change M3 to the focal station with the same name as the instrument"
        moveKnownPosition:
            type: t_bool
            comment: "Move the axes to a known position (defined by the 'moveKnownPositionName' config entry) before turning off derotators"
        moveKnownPositionName:
            type: t_string
            comment: "Name of the known position to move to before turning off derotators"
        powerOnRoc:
            type: t_bool
            comment: "Turn on the Cassegrain derotator if needed"
        powerOffRoc:
            type: t_bool
            comment: "Turn off the Cassegrain derotator if needed"
        powerOnRon:
            type: t_bool
            comment: "Turn on the Nasmyth B derotator if needed"
        powerOffRon:
            type: t_bool
            comment: "Turn off the Nasmyth B derotator if needed"
        loadPointingModel:
            type: t_bool
            comment: "Load the pointing model with the same name as the instrument"
        rocActive:
            type: t_bool
            comment: "True if the Cassegrain rotator is active (irrespective of its power status)."
        ronActive:
            type: t_bool
            comment: "True if the Nasmyth rotator is active (irrespective of its power status)"





########################################################################################################################
# ModbusRTUBusReadCoilProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "ModbusRTUBusReadCoilProcess",
    extends: THISLIB.BaseProcess
    arguments:
        unitID       : { type: t_uint8  , comment: "Modbus station address (1..247)"}
        address      : { type: t_uint16 , comment: "Modbus data address"}
    variables:
        value        : { type: t_bool, comment: "Value of the coil" }
        errorId      : { type: t_int16, comment: "Error Id. Modbus error code" }

########################################################################################################################
# ModbusRTUBusWriteCoilProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "ModbusRTUBusWriteCoilProcess",
    extends: THISLIB.BaseProcess
    arguments:
        unitID       : { type: t_uint8  , comment: "Modbus station address (1..247)"}
        address      : { type: t_uint16 , comment: "Modbus data address"}
        value        : { type: t_bool   , comment: "Value to write on the coil" }
    variables:
        errorId      : { type: t_int16  , comment: "Error Id. Modbus error code" }

########################################################################################################################
# ModbusRTUBusReadRegisterProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "ModbusRTUBusReadRegisterProcess",
    extends: THISLIB.BaseProcess
    arguments:
        unitID       : { type: t_uint8  , comment: "Modbus station address (1..247)"}
        address      : { type: t_uint16 , comment: "Modbus data address"}
    variables:
        value        : { type: t_int16, comment: "Value of the register" }
        errorId      : { type: t_int16, comment: "Error Id. Modbus error code" }

########################################################################################################################
# ModbusRTUBusWriteRegisterProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "ModbusRTUBusWriteRegisterProcess",
    extends: THISLIB.BaseProcess
    arguments:
        unitID       : { type: t_uint8  , comment: "Modbus station address (1..247)"}
        address      : { type: t_uint16 , comment: "Modbus data address"}
        value        : { type: t_int16  , comment: "Value to write on the register" }
    variables:
        errorId      : { type: t_int16, comment: "Error Id. Modbus error code" }

########################################################################################################################
# ModbusRTUBusDiagnosticsProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "ModbusRTUBusDiagnosticsProcess",
    extends: THISLIB.BaseProcess
    arguments:
        unitID       : { type: t_uint8  , comment: "Modbus station address (1..247)"}
        subFunction  : { type: t_uint16 , comment: "Modbus subFunction code"}
        subData      : { type: t_int16  , comment: "Modbus data for subFunction " }
    variables:
        value        : { type: t_int16, comment: "Value of the register" }
        errorId      : { type: t_int16, comment: "Error Id. Modbus error code" }
        
########################################################################################################################
# ModbusRTUBus
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB, "ModbusRTUBus",
    variables_hidden:
        isEnabled       : { type: t_bool , comment: "Is control enabled?" }
    variables:
        retries         : { type: t_int16   , initial: int(3),  comment: "Number of retries for a succesfull process" }
    processes:
        readCoil       : { type: THISLIB.ModbusRTUBusReadCoilProcess, comment: "Read coil" }
        writeCoil      : { type: THISLIB.ModbusRTUBusWriteCoilProcess, comment: "Write coil" }
        readRegister   : { type: THISLIB.ModbusRTUBusReadRegisterProcess, comment: "Read register" }
        writeRegister  : { type: THISLIB.ModbusRTUBusWriteRegisterProcess, comment: "Write register" } 
        diagnostics    : { type: THISLIB.ModbusRTUBusDiagnosticsProcess, comment: "Diagnostics" } 
    statuses:
        busyStatus      : { type: THISLIB.BusyStatus            , comment: "Is the config manager in a busy state?" }
    calls:
        busyStatus:
            isBusy      : -> OR( self.processes.readCoil.statuses.busyStatus.busy,
                                 self.processes.writeCoil.statuses.busyStatus.busy,
                                 self.processes.readRegister.statuses.busyStatus.busy,
                                 self.processes.writeRegister.statuses.busyStatus.busy,
                                 self.processes.diagnostics.statuses.busyStatus.busy )        
        readCoil:
            isEnabled  : -> AND( self.isEnabled, self.statuses.busyStatus.idle )
        writeCoil:
            isEnabled  : -> AND( self.isEnabled, self.statuses.busyStatus.idle ) 
        readRegister:
            isEnabled  : -> AND( self.isEnabled, self.statuses.busyStatus.idle )
        writeRegister:
            isEnabled  : -> AND( self.isEnabled, self.statuses.busyStatus.idle )
        diagnostics:
            isEnabled  : -> AND( self.isEnabled, self.statuses.busyStatus.idle )


common_soft.WRITE "models/mtcs/common/software.jsonld"
