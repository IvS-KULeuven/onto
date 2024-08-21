########################################################################################################################
#                                                                                                                      #
# Model of the Axes software.                                                                                            #
#                                                                                                                      #
########################################################################################################################

require "ontoscript"

# models
REQUIRE "models/mtcs/common/software.coffee"
REQUIRE "models/mtcs/tmc/software.coffee"
REQUIRE "models/mtcs/services/software.coffee"
REQUIRE "models/mtcs/safety/software.coffee"

MODEL "http://www.mercator.iac.es/onto/models/mtcs/axes/software" : "axes_soft"

axes_soft.IMPORT common_soft
axes_soft.IMPORT tmc_soft
axes_soft.IMPORT services_soft
axes_soft.IMPORT safety_soft


########################################################################################################################
# Define the containing PLC library
########################################################################################################################

axes_soft.ADD MTCS_MAKE_LIB "mtcs_axes"

# make aliases (with scope of this file only)
COMMONLIB    = common_soft.mtcs_common
THISLIB      = axes_soft.mtcs_axes
TMCLIB       = tmc_soft.mtcs_tmc
SERVICESLIB  = services_soft.mtcs_services
SAFETYLIB    = safety_soft.mtcs_safety

########################################################################################################################
# AxesIds
########################################################################################################################

MTCS_MAKE_ENUM THISLIB, "AxesIds",
    items:
        [   "AZI",
            "ABL",
            "ELE",
            "ROC",
            "RON" ]



########################################################################################################################
# AxesLocationConfig
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "AxesLocationConfig",
    items:
        longitude:
            type: t_double
            comment: "Observatory location: longitude [degrees, positive = E, negative = W]"
        latitude:
            type: t_double
            comment: "Observatory location: latitude [degrees, positive = N, negative = S]"
        height:
            type: t_float
            comment: "Observatory location: height above sea-level [m]"
        polarMotionX:
            type: t_float
            comment: "Earth polar motion x in degrees"
        polarMotionY:
            type: t_float
            comment: "Earth polar motion y in degrees"
        nutationDx:
            type: t_float
            comment: "Nutation adjustment dX in degrees"
        nutationDy:
            type: t_float
            comment: "Nutation adjustment dY in degrees"

########################################################################################################################
# AxesLocalConditionsConfig
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "AxesLocalConditionsConfig",
    items:
        useTemperatureFromSensors:
            type: t_bool
            comment: "True if the temperature from the sensors should be used, false to use the temperature from the config"
        configuredTemperature:
            type: t_float
            comment: "Local temperature in degrees, fixed by config"
        configuredPressure:
            type: t_float
            comment: "Local temperature in hectoPascal = millibar, fixed by config"
        useRelativeHumidityFromSensors:
            type: t_bool
            comment: "True if the temperature from the sensors should be used, false to use the temperature from the config"
        configuredRelativeHumidity:
            type: t_float
            comment: "Local relative humidity as a fraction (0...1), fixed by config"
        configuredObservingWavelength:
            type: t_float
            comment: "Observing wavelength in microns, fixed by config"
        troposphericLapseRate:
            type: t_float
            comment: "Tropospheric lapse rate in K/m"


########################################################################################################################
# AxesAzimuthConfig
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "AxesAzimuthConfig",
    items:
        absoluteEncoderOffset       : { type: t_double, comment: "Offset in degrees, of the absolute encoder, w.r.t. zero" }
        absoluteEncoderInvert       : { type: t_bool  , comment: "TRUE to invert the counting direction of the absolute encoder" }
        lidasInvert                 : { type: t_bool  , comment: "TRUE to invert the counting direction of the LIDAs" }
        moveOutOfLimitSwitchDistance: { type: t_double, comment: "How many degrees should the moveOutOfLimitSwitch process try to move?" }
        positiveLimitSwitchInput    : { type: t_int8  , comment: "Which input (0-7) represents the positive limit switch?" }
        negativeLimitSwitchInput    : { type: t_int8  , comment: "Which input (0-7) represents the negative limit switch?" }
        minPositionLimitVirtualAxis : { type: t_double, comment: "Limit the minimum position of the virtual axis to this value in degrees" }
        maxPositionLimitVirtualAxis : { type: t_double, comment: "Limit the maximum position of the virtual axis to this value in degrees" }
        minPositionLimitPhysicalAxis: { type: t_double, comment: "Limit the minimum position of the physical axis to this value in degrees" }
        maxPositionLimitPhysicalAxis: { type: t_double, comment: "Limit the maximum position of the physical axis to this value in degrees" }
        velocityLimit               : { type: t_double, comment: "Limit the velocity of the axis to this value in degrees/sec" }
        accelerationLimit           : { type: t_double, comment: "Limit the acceleration (or deceleration) of the axis to this value in degrees/sec^2" }
        minPositionSetpoint         : { type: t_double, comment: "The minimum position setpoint of the axis in degrees (should be a bit before the minPositionLimit)" }
        maxPositionSetpoint         : { type: t_double, comment: "The maximum position setpoint of the axis in degrees (should be a bit before the maxPositionLimit)" }
        maxVelocitySetpoint         : { type: t_double, comment: "The maximum velocity setpoint of the axis in degrees/sec" }
        maxAccelerationSetpoint     : { type: t_double, comment: "The maximum acceleration setpoint of the axis in degrees/sec^2" }
        slipLimit                   : { type: t_double, comment: "If the difference between the LIDA-encoder and motor-encoder positions is above this value in degrees, then we have detected slip"}
        ablMaxTorqueRiseSpeed       : { type: t_double, comment: "The ABL torque can rise maximum ... Nm/s on the telescope axis (always >0)" }
        ablMaxTorqueFallSpeed       : { type: t_double, comment: "The ABL torque can fall maximum ... Nm/s on the telescope axis (always >0)" }
        ablMaxTorque                : { type: t_double, comment: "The maximum ABL torque in Nm/s on the telescope axis (always >0)" }
        ablMinTorque                : { type: t_double, comment: "The minimum ABL torque in Nm/s on the telescope axis (always >0)" }
        ablZeroAccTorque            : { type: t_double, comment: "The ABL torque when the axis is not accelerating or decelerating (always >0)" }
        ablTorqueOutputOverride     : { type: t_double, comment: "Scale the ABL output torque by this fraction value (only for testing purposes, must be 1 normally!)"}
        ablPositiveTorque           : { type: t_bool  , comment: "True if a positive torque must be applied, false if a negative torque must be applied" }
        aziAndAblSameDirection      : { type: t_bool  , comment: "True if the AZI and ABL axes rotate in the same direction?" }
        homingHomePosition          : { type: t_double, comment: "The position of the homing mark (in degrees), with respect to the absolute zero"}
        homingStartAbsEncPosition   : { type: t_double, comment: "Absolute encoder position where the homing should go to first, in degrees"}
        homingGotoStartVelocity     : { type: t_double, comment: "Velocity when going to the start position, in degrees/sec"}
        homingVelocity              : { type: t_double, comment: "Velocity to search for the homing mark, in degrees/sec"}
        homingRange                 : { type: t_double, comment: "Maximum distance to be covered while searching for the homing mark, in degrees"}
        quickStopDeceleration       : { type: t_double, comment: "Quick stop deceleration, in degrees/sec2"}
        quickStopJerk               : { type: t_double, comment: "Quick stop jerk, in degrees/sec3"}

########################################################################################################################
# AxesElevationConfig
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "AxesElevationConfig",
    items:
        absoluteEncoderOffset       : { type: t_double, comment: "Offset in degrees, of the absolute encoder, w.r.t. zero" }
        absoluteEncoderInvert       : { type: t_bool  , comment: "TRUE to invert the counting direction" }
        lidasInvert                 : { type: t_bool  , comment: "TRUE to invert the counting direction of the LIDAs" }
        moveOutOfLimitSwitchDistance: { type: t_double, comment: "How many degrees should the moveOutOfLimitSwitch process try to move?" }
        positiveLimitSwitchInput    : { type: t_int8  , comment: "Which input (0-7) represents the positive limit switch?" }
        negativeLimitSwitchInput    : { type: t_int8  , comment: "Which input (0-7) represents the negative limit switch?" }
        minPositionLimitVirtualAxis : { type: t_double, comment: "Limit the minimum position of the axis to this value in degrees, of the virtual axis" }
        maxPositionLimitVirtualAxis : { type: t_double, comment: "Limit the maximum position of the axis to this value in degrees, of the virtual axis" }
        minPositionLimitPhysicalAxis: { type: t_double, comment: "Limit the minimum position of the axis to this value in degrees, of the physical axis" }
        maxPositionLimitPhysicalAxis: { type: t_double, comment: "Limit the maximum position of the axis to this value in degrees, of the physical axis" }
        velocityLimit               : { type: t_double, comment: "Limit the velocity of the axis to this value in degrees/sec" }
        accelerationLimit           : { type: t_double, comment: "Limit the acceleration (or deceleration) of the axis to this value in degrees/sec^2" }
        minPositionSetpoint         : { type: t_double, comment: "The minimum position setpoint of the axis in degrees" }
        maxPositionSetpoint         : { type: t_double, comment: "The maximum position setpoint of the axis in degrees" }
        maxVelocitySetpoint         : { type: t_double, comment: "The maximum velocity setpoint of the axis in degrees/sec" }
        maxAccelerationSetpoint     : { type: t_double, comment: "The maximum acceleration setpoint of the axis in degrees/sec^2" }
        slipLimit                   : { type: t_double, comment: "If the difference between the LIDA-encoder and motor-encoder positions is above this value in degrees, then we have detected slip" }
        homingHomePosition          : { type: t_double, comment: "The position of the homing mark (in degrees), with respect to the absolute zero"}
        homingStartAbsEncPosition   : { type: t_double, comment: "Absolute encoder position where the homing should go to first, in degrees"}
        homingGotoStartVelocity     : { type: t_double, comment: "Velocity when going to the start position, in degrees/sec"}
        homingVelocity              : { type: t_double, comment: "Velocity to search for the homing mark, in degrees/sec"}
        homingRange                 : { type: t_double, comment: "Maximum distance to be covered while searching for the homing mark, in degrees"}
        quickStopDeceleration       : { type: t_double, comment: "Quick stop deceleration, in degrees/sec2"}
        quickStopJerk               : { type: t_double, comment: "Quick stop jerk, in degrees/sec3"}

########################################################################################################################
# AxesRotationConfig
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "AxesRotationConfig",
    items:
        motorEncoderOffset          : { type: t_double, comment: "Offset in degrees, of the absolute motor encoder, w.r.t. zero" }
        moveOutOfLimitSwitchDistance: { type: t_double, comment: "How many degrees should the moveOutOfLimitSwitch process try to move?" }
        positiveLimitSwitchInput    : { type: t_int8  , comment: "Which input (0-7) represents the positive limit switch?" }
        negativeLimitSwitchInput    : { type: t_int8  , comment: "Which input (0-7) represents the negative limit switch?" }
        minPositionLimitVirtualAxis : { type: t_double, comment: "Limit the minimum position of the axis to this value in degrees, of the virtual axis" }
        maxPositionLimitVirtualAxis : { type: t_double, comment: "Limit the maximum position of the axis to this value in degrees, of the virtual axis" }
        minPositionLimitPhysicalAxis: { type: t_double, comment: "Limit the minimum position of the axis to this value in degrees, of the physical axis" }
        maxPositionLimitPhysicalAxis: { type: t_double, comment: "Limit the maximum position of the axis to this value in degrees, of the physical axis" }
        velocityLimit               : { type: t_double, comment: "Limit the velocity of the axis to this value in degrees/sec" }
        accelerationLimit           : { type: t_double, comment: "Limit the acceleration (or deceleration) of the axis to this value in degrees/sec^2" }
        minPositionSetpoint         : { type: t_double, comment: "The minimum position setpoint of the axis in degrees" }
        maxPositionSetpoint         : { type: t_double, comment: "The maximum position setpoint of the axis in degrees" }
        maxVelocitySetpoint         : { type: t_double, comment: "The maximum velocity setpoint of the axis in degrees/sec" }
        maxAccelerationSetpoint     : { type: t_double, comment: "The maximum acceleration setpoint of the axis in degrees/sec^2" }
        quickStopDeceleration       : { type: t_double, comment: "Quick stop deceleration, in degrees/sec2"}
        quickStopJerk               : { type: t_double, comment: "Quick stop jerk, in degrees/sec3"}


########################################################################################################################
# AxesKnownPositionConfig
########################################################################################################################
MTCS_MAKE_CONFIG THISLIB, "AxesKnownPositionConfig",
    items:
        name:
            type: t_string
            comment: "The name of the position (e.g. 'PARK')"
        allowObserver:
            type: t_bool
            comment: "Can an observer switch to this position?"
        azi:
            type: t_double
            comment: "Azimuth in degrees"
        ele:
            type: t_double
            comment: "Elevation in degrees"
        roc:
            type: t_double
            comment: "Cassegrain rotation in degrees"
        ron:
            type: t_double
            comment: "Nasmyth B rotation in degrees"
        doAzi:
            type: t_bool
            comment: "Change the azimuth axis to the 'azi' position"
        doEle:
            type: t_bool
            comment: "Change the elevation axis to the 'ele' position"
        doRoc:
            type: t_bool
            comment: "Change the cassegrain rotation axis to the 'roc' position"
        doRon:
            type: t_bool
            comment: "Change the nasmyth rotation axis to the 'ron' position"


########################################################################################################################
# AxesKnownPositionsConfig
########################################################################################################################
MTCS_MAKE_CONFIG THISLIB, "AxesKnownPositionsConfig",
    items:
        position0     : { type: THISLIB.AxesKnownPositionConfig, comment : "Known position 0"   , expand: false }
        position1     : { type: THISLIB.AxesKnownPositionConfig, comment : "Known position 1"   , expand: false }
        position2     : { type: THISLIB.AxesKnownPositionConfig, comment : "Known position 2"   , expand: false }
        position3     : { type: THISLIB.AxesKnownPositionConfig, comment : "Known position 3"   , expand: false }
        position4     : { type: THISLIB.AxesKnownPositionConfig, comment : "Known position 4"   , expand: false }
        position5     : { type: THISLIB.AxesKnownPositionConfig, comment : "Known position 5"   , expand: false }
        position6     : { type: THISLIB.AxesKnownPositionConfig, comment : "Known position 6"   , expand: false }
        position7     : { type: THISLIB.AxesKnownPositionConfig, comment : "Known position 7"   , expand: false }
        position8     : { type: THISLIB.AxesKnownPositionConfig, comment : "Known position 8"   , expand: false }
        position9     : { type: THISLIB.AxesKnownPositionConfig, comment : "Known position 9"   , expand: false }
        position10    : { type: THISLIB.AxesKnownPositionConfig, comment : "Known position 10"  , expand: false }
        position11    : { type: THISLIB.AxesKnownPositionConfig, comment : "Known position 11"  , expand: false }
        position12    : { type: THISLIB.AxesKnownPositionConfig, comment : "Known position 12"  , expand: false }
        position13    : { type: THISLIB.AxesKnownPositionConfig, comment : "Known position 13"  , expand: false }
        position14    : { type: THISLIB.AxesKnownPositionConfig, comment : "Known position 14"  , expand: false }
        position15    : { type: THISLIB.AxesKnownPositionConfig, comment : "Known position 15"  , expand: false }
        position16    : { type: THISLIB.AxesKnownPositionConfig, comment : "Known position 16"  , expand: false }
        position17    : { type: THISLIB.AxesKnownPositionConfig, comment : "Known position 17"  , expand: false }
        position18    : { type: THISLIB.AxesKnownPositionConfig, comment : "Known position 18"  , expand: false }
        position19    : { type: THISLIB.AxesKnownPositionConfig, comment : "Known position 19"  , expand: false }


########################################################################################################################
# AxesConfig
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "AxesConfig",
    items:
        location                    : { type: THISLIB.AxesLocationConfig        , comment: "Location of the observatory", expand: false }
        localConditions             : { type: THISLIB.AxesLocalConditionsConfig , comment: "Location of the observatory", expand: false }
        knownPositions              : { type: THISLIB.AxesKnownPositionsConfig  , comment: "Known (predefined) positions (e.g. could be Park, Cover, Park winter, Mirror washing, ...)", expand: false }
        azi                         : { type: THISLIB.AxesAzimuthConfig         , comment: "Azimuth axis", expand: false }
        ele                         : { type: THISLIB.AxesElevationConfig       , comment: "Elevation axis", expand: false }
        roc                         : { type: THISLIB.AxesRotationConfig        , comment: "Cassegrain rotation axis", expand: false }
        ron                         : { type: THISLIB.AxesRotationConfig        , comment: "Nasmyth rotation axis", expand: false }
        cassegrainRotatorName       : { type: t_string                          , comment: "Name of the Cassegrain rotator" }
        nasmythRotatorName          : { type: t_string                          , comment: "Name of the Nasmyth rotator" }
        rocGuiAngle                 : { type: t_double                          , comment: "Amgle to show ROC in the GUI" }
        ronGuiAngle                 : { type: t_double                          , comment: "Amgle to show RON in the GUI" }
        nasmythRotatorName          : { type: t_string                          , comment: "Name of the Nasmyth rotator" }
        knownPositionToleranceAzi   : { type: t_double                          , comment: "Tolerance (in degrees) to determine if the telescope is at a known position in azi direction" }
        knownPositionToleranceEle   : { type: t_double                          , comment: "Tolerance (in degrees) to determine if the telescope is at a known position in ele direction" }
        knownPositionToleranceRoc   : { type: t_double                          , comment: "Tolerance (in degrees) to determine if the telescope is at a known position in roc direction" }
        knownPositionToleranceRon   : { type: t_double                          , comment: "Tolerance (in degrees) to determine if the telescope is at a known position in ron direction" }
        rocPositionAngleSign        : { type: t_int16                           , comment: "-1 to invert the sign of the PA for the cas derotator, 1 for positive" }
        ronPositionAngleSign        : { type: t_int16                           , comment: "-1 to invert the sign of the PA for the cas derotator, 1 for positive" }
        tpointAziSign               : { type: t_int16                           , comment: "-1 or 1 to invert input for TPOINT: A" }
        tpointEleSign               : { type: t_int16                           , comment: "-1 or 1 to invert input for TPOINT: E " }
        tpointDeltaAziSign          : { type: t_int16                           , comment: "-1 or 1 to invert input for TPOINT: DA" }
        tpointDeltaEleSign          : { type: t_int16                           , comment: "-1 or 1 to invert input for TPOINT: DE" }
        tpointOldFormulas           : { type: t_bool                            , comment: "True to use the old formulas" }
        tpointConvertRawAlphaDelta  : { type: t_bool                            , comment: "If True, raw encoder values will be converted to feedback.alpha and feedback.delta, instead of corrected encoder values. Only use for tech stuff!" }

########################################################################################################################
# AxesPointingModelConfig
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "AxesPointingModelConfig",
    items:
        name    : { type: t_string, comment: "This name can be matched against the instrument name in the MTCS config and the focal station name in the M3 config." }
        IE      : { type: t_double, comment: 'Index error in elevation' }
        IA      : { type: t_double, comment: 'Index error in azimuth' }
        CA      : { type: t_double, comment: 'Nonperpendicularity of elevation and pointing axes' }
        AN      : { type: t_double, comment: 'NS misalignment of azimuth axis' }
        AW      : { type: t_double, comment: 'EW misalignment of azimuth axis' }
        NPAE    : { type: t_double, comment: 'Nonperpendicularity of azimuth and elevation axes' }
        NRX     : { type: t_double, comment: 'Horizontal displacement of Nasmyth rotation' }
        NRY     : { type: t_double, comment: 'Vertical displacement of Nasmyth rotation' }
        ACES    : { type: t_double, comment: 'Az centering error (sin component)' }
        ACEC    : { type: t_double, comment: 'Az centering error (cos component)' }
        ECES    : { type: t_double, comment: 'El centering error (sin component)' }
        ECEC    : { type: t_double, comment: 'El centering error (cos component)' }
#        A1A     : { type: t_double, comment: 'Az change supplied through auxiliary reading 1' }
#        A1S     : { type: t_double, comment: 'LR change supplied through auxiliary reading 1' }
#        A1E     : { type: t_double, comment: 'El change supplied through auxiliary reading 1' }
#        A2A     : { type: t_double, comment: 'Az change supplied through auxiliary reading 2' }
#        A2S     : { type: t_double, comment: 'LR change supplied through auxiliary reading 2' }
#        A2E     : { type: t_double, comment: 'El change supplied through auxiliary reading 2' }
        TF      : { type: t_double, comment: 'Tube flexure - sin(zeta) law' }
        TX      : { type: t_double, comment: 'Tube flexure - tan(zeta) law' }
        FLOP    : { type: t_double, comment: 'Constant vertical displacement' }
        POX     : { type: t_double, comment: 'The x-coordinate of a pointing origin on a derotator' }
        POY     : { type: t_double, comment: 'The y-coordinate of a pointing origin on a derotator' }



########################################################################################################################
# AxesMoveUnits
########################################################################################################################
MTCS_MAKE_ENUM THISLIB, "AxesMoveUnits",
    items:
        [   "DEGREES",
            "RADIANS",
            "ARCSECONDS" ]

########################################################################################################################
# AxesAlphaUnits
########################################################################################################################
MTCS_MAKE_ENUM THISLIB, "AxesAlphaUnits",
    items:
        [   "HOURS",
            "DEGREES",
            "RADIANS" ]

########################################################################################################################
# AxesDeltaUnits
########################################################################################################################
MTCS_MAKE_ENUM THISLIB, "AxesDeltaUnits",
    items:
        [   "DEGREES",
            "RADIANS" ]

########################################################################################################################
# AxesMuUnits
########################################################################################################################
MTCS_MAKE_ENUM THISLIB, "AxesMuUnits",
    items:
        [   "ARCSECONDS_PER_YEAR",
            "MILLIARCSECONDS_PER_YEAR",
            "DEGREES_PER_YEAR",
            "RADIANS_PER_YEAR" ]


########################################################################################################################
# AxesSetTargetProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "AxesSetTargetProcess",
    extends: COMMONLIB.BaseProcess
    arguments:
        alphaUnits          : { type: THISLIB.AxesAlphaUnits    , comment: "The units in which alpha is given" }
        alpha               : { type: t_double                  , comment: "Right ascention, in the units of the alphaUnits argument" }
        deltaUnits          : { type: THISLIB.AxesDeltaUnits    , comment: "The units in which delta is given" }
        delta               : { type: t_double                  , comment: "Declination, in the units of the deltaUnits argument" }
        muUnits             : { type: THISLIB.AxesMuUnits       , comment: "The units in which muAlpha and muDelta are given" }
        muAlpha             : { type: t_double                  , comment: "Right ascention proper motion, the units of muUmits (do not multiply by cos(delta)!)" }
        muDelta             : { type: t_double                  , comment: "Declination proper motion, in radians/year" }
        parallax            : { type: t_double                  , comment: "Object parallax, in arcseconds" }
        radialVelocity      : { type: t_double                  , comment: "Object radial velocity, in km/s" }
        epoch               : { type: t_double, initial: 2000.0 , comment: "Epoch, e.g. 2000.0" }

########################################################################################################################
# AxesPointProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "AxesPointProcess",
    extends: COMMONLIB.BaseProcess
    variables:
        state               : { type: t_int16                   , comment: "State of the process" }
    arguments:
        alphaUnits          : { type: THISLIB.AxesAlphaUnits    , comment: "The units in which alpha is given" }
        alpha               : { type: t_double                  , comment: "Right ascention, in the units of the alphaUnits argument" }
        deltaUnits          : { type: THISLIB.AxesDeltaUnits    , comment: "The units in which delta is given" }
        delta               : { type: t_double                  , comment: "Declination, in the units of the deltaUnits argument" }
        muUnits             : { type: THISLIB.AxesMuUnits       , comment: "The units in which muAlpha and muDelta are given" }
        muAlpha             : { type: t_double                  , comment: "Right ascention proper motion, the units of muUmits (do not multiply by cos(delta)!)" }
        muDelta             : { type: t_double                  , comment: "Declination proper motion, in radians/year" }
        parallax            : { type: t_double                  , comment: "Object parallax, in arcseconds" }
        radialVelocity      : { type: t_double                  , comment: "Object radial velocity, in km/s" }
        epoch               : { type: t_double, initial: 2000.0 , comment: "Epoch, e.g. 2000.0" }
        tracking            : { type: t_bool  , initial: true   , comment: "True to start tracking the object, false to Only do a pointing" }
        rotUnits            : { type: THISLIB.AxesMoveUnits     , comment: "Units of the 'rot', 'roc' and 'ron' arguments (RADIANS, DEGREES, ARCSECONDS, ...)"}
        rotOffset           : { type: t_double                  , comment: "Offset to move the currently active rotator (incompatible with 'roc' and 'ron' args)"}
        rocOffset           : { type: t_double                  , comment: "Offset to move the cassegrain rotation axis (incompatible with 'rot' arg)" }
        ronOffset           : { type: t_double                  , comment: "Offset to move the nasmyth rotation axis (incompatible with 'rot' arg)" }
        doRotOffset         : { type: t_bool                    , comment: "True to move the currently active rotator, false to leave it untouched" }
        doRocOffset         : { type: t_bool                    , comment: "True to move the cassegrain rotation axis, false to leave it untouched" }
        doRonOffset         : { type: t_bool                    , comment: "True to move the nasmyth rotation axis, false to leave it untouched" }


########################################################################################################################
# AxesPointRelativeProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "AxesPointRelativeProcess",
    extends: COMMONLIB.BaseProcess
    arguments:
        alphaUnits          : { type: THISLIB.AxesAlphaUnits        , comment: "The units in which alpha is given" }
        alpha               : { type: t_double                      , comment: "Right ascention, in the units of the alphaUnits argument" }
        deltaUnits          : { type: THISLIB.AxesDeltaUnits        , comment: "The units in which delta is given" }
        delta               : { type: t_double                      , comment: "Declination, in the units of the deltaUnits argument" }



########################################################################################################################
# AxesMoveRelativeProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "AxesMoveRelativeProcess",
    extends: COMMONLIB.BaseProcess
    arguments:
        units : { type: THISLIB.AxesMoveUnits                       , comment: "Units of the 'value' argument (RADIANS, DEGREES, ARCSECONDS, ...)"}
        value : { type: t_double                                    , comment: "Move the axis with this value (which units depends on the 'units' argument)" }

########################################################################################################################
# AxesMoveAbsoluteProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "AxesMoveAbsoluteProcess",
    extends: COMMONLIB.BaseProcess
    arguments:
        units : { type: THISLIB.AxesMoveUnits           , comment: "Units of the 'value' argument (RADIANS, DEGREES, ARCSECONDS, ...)"}
        value : { type: t_double                        , comment: "Move the axis to this value (which units depends on the 'units' argument) + the optional offset" }
        offset : { type: t_double                        , comment: "Optional extra offset (which will not be added to the 'startPos'" }

########################################################################################################################
# AxesMoveKnownPositionProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "AxesMoveKnownPositionProcess",
    extends: COMMONLIB.BaseProcess
    arguments:
        name        : { type: t_string  , comment: "Name of the position to move to"}



########################################################################################################################
# AxesMoveUnits
########################################################################################################################
MTCS_MAKE_ENUM THISLIB, "AxesMoveVelocityUnits",
    items:
        [   "DEGREES_PER_SECOND",
            "ARCSECONDS_PER_SECOND",
            "RADIANS_PER_SECOND",
            "ARCSECONDS_PER_MINUTE",
            "ARCSECONDS_PER_HOUR" ]


########################################################################################################################
# AxesRotatorActivity
########################################################################################################################
MTCS_MAKE_ENUM THISLIB, "AxesRotatorActivity",
    items:
        [   "NONE_ACTIVE",
            "ROC_ACTIVE",
            "RON_ACTIVE" ]



########################################################################################################################
# AxesMoveVelocityProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "AxesMoveVelocityProcess",
    extends: COMMONLIB.BaseProcess
    arguments:
        units : { type: THISLIB.AxesMoveVelocityUnits   , comment: "Units of the 'value' argument (RADIANS_PER_SECOND, DEGREES_PER_SECOND, ...)"}
        value : { type: t_double                        , comment: "Move the axis with this velocity (which units depends on the 'units' argument)" }


########################################################################################################################
# AxesMoveOutOfLimitSwitchProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "AxesMoveOutOfLimitSwitchProcess",
    extends: COMMONLIB.BaseProcess
    arguments:
        switch  : { type: COMMONLIB.LimitSwitches, comment: "Positive or negative limit switch", expand: false  }


########################################################################################################################
# AxesPowerOnProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "AxesPowerOnProcess",
    extends: COMMONLIB.BaseProcess
    variables:
        state : { type: t_int16, comment: "State of the process" }

########################################################################################################################
# AxesMultiPowerOnProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "AxesMultiPowerOnProcess",
    extends: COMMONLIB.BaseProcess
    variables:
        state : { type: t_int16, comment: "State of the process" }
    arguments:
        azi : { type: t_bool, comment: "TRUE to power on AZI" }
        ele : { type: t_bool, comment: "TRUE to power on ELE" }
        roc : { type: t_bool, comment: "TRUE to power on ROC" }
        ron : { type: t_bool, comment: "TRUE to power on RON" }
        fw  : { type: t_bool, comment: "TRUE to power on FW" }

########################################################################################################################
# AxesPowerOffProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "AxesPowerOffProcess",
    extends: COMMONLIB.BaseProcess
    variables:
        state : { type: t_int16, comment: "State of the process" }


########################################################################################################################
# AxesStopProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "AxesStopProcess",
    extends: COMMONLIB.BaseProcess
    variables:
        state : { type: t_int16, comment: "State of the process" }



########################################################################################################################
# AxesAddAlphaDeltaVelocityProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "AxesSetAlphaDeltaVelocityProcess",
    extends: COMMONLIB.BaseProcess
    arguments:
        units           : { type: THISLIB.AxesMoveVelocityUnits, comment: "Units of the alphaVelocity and deltaVelocity" }
        alphaVelocity   : { type: t_double, comment: "Velocity in alpha direction" }
        deltaVelocity   : { type: t_double, comment: "Velocity in delta direction" }


########################################################################################################################
# AxesDoHomingProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "AxesDoHomingProcess",
    extends: COMMONLIB.BaseProcess
    variables:
        state : { type: t_int16, comment: "State of the process" }


########################################################################################################################
# AxesMultiMoveProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "AxesMultiMoveProcess",
    extends: COMMONLIB.BaseProcess
    variables:
        waitingForAzi : { type: t_bool              , comment: "True if the process is waiting for AZI" }
        waitingForEle : { type: t_bool              , comment: "True if the process is waiting for ELE" }
        waitingForRoc : { type: t_bool              , comment: "True if the process is waiting for ROC" }
        waitingForRon : { type: t_bool              , comment: "True if the process is waiting for RON" }
    arguments:
        units       : { type: THISLIB.AxesMoveUnits , comment: "Units of the 'azi', 'ele', 'roc' and 'ron' arguments (RADIANS, DEGREES, ARCSECONDS, ...)"}
        azi         : { type: t_double              , comment: "Angle to move the azimuth axis" }
        ele         : { type: t_double              , comment: "Angle to move the elevation axis" }
        rot         : { type: t_double              , comment: "Angle to move the currently active rotator (incompatible with 'roc' and 'ron' args)"}
        roc         : { type: t_double              , comment: "Angle to move the cassegrain rotation axis (incompatible with 'rot' arg)" }
        ron         : { type: t_double              , comment: "Angle to move the nasmyth rotation axis (incompatible with 'rot' arg)" }
        doAzi       : { type: t_bool                , comment: "True to move the azimuth axis, false to leave it untouched" }
        doEle       : { type: t_bool                , comment: "True to move the elevation axis, false to leave it untouched" }
        doRot       : { type: t_bool                , comment: "True to move the currently active rotator, false to leave it untouched" }
        doRoc       : { type: t_bool                , comment: "True to move the cassegrain rotation axis, false to leave it untouched" }
        doRon       : { type: t_bool                , comment: "True to move the nasmyth rotation axis, false to leave it untouched" }
        preferMostTravel    : { type: t_bool     , initial: false   , comment: "Only in case of relative movement during tracking: If possible, go to the position where there is most travel (if the telescope is tracking). If false, it will go there the quickest way possible." }

########################################################################################################################
# AxesEnablePointingModelProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "AxesEnablePointingModelProcess",
    extends: COMMONLIB.BaseProcess
    arguments:
        name : { type: t_string, comment: "Name of the pointing model" }


########################################################################################################################
# Mockup of drive object
########################################################################################################################

createDrive = (comment) ->
    return {
            type: COMMONLIB.AX52XXDrive
            comment: comment
            expand: false
            arguments:
                isEnabled : { type: t_bool }
            attributes:
                parts:
                    attributes:
                        channelA : { type: COMMONLIB.AX52XXDriveChannel, expand: false }
                        channelB : { type: COMMONLIB.AX52XXDriveChannel, expand: false }
                statuses:
                    attributes:
                        healthStatus    : { type: COMMONLIB.HealthStatus }
                        busyStatus      : { type: COMMONLIB.BusyStatus }
    }


########################################################################################################################
# Axes
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB,  "Axes",
    variables:
        editableConfig                  : { type: THISLIB.AxesConfig                        , comment: "Editable configuration of the Axes subsystem" , expand: false}
        fromCppAxes                     : { type: TMCLIB.TmcToPlcAxes      , address: "%I*" , comment: "Data from the C++ task", expand: false}
    references:
        timing                          : { type: SERVICESLIB.ServicesTiming                , comment: "Reference to the timing service", expand: false }
        motionBlocking                  : { type: SAFETYLIB.SafetyMotionBlocking            , comment: "Reference to the motion blocking safety", expand: false }
        domeAccess                      : { type: SAFETYLIB.SafetyDomeAccess                , comment: "Reference to the dome access safety", expand: false }
        operatorStatus                  : { type: COMMONLIB.OperatorStatus                  , comment: "Shared operator status" }
        activityStatus                  : { type: COMMONLIB.ActivityStatus                  , comment: "Shared activity status"}
        activeInstrument                : { type: COMMONLIB.InstrumentConfig                , comment: "Instrument config *if* isInstrumentActive is TRUE", expand: false }
        isInstrumentActive              : { type: t_bool                                    , comment: "Is an instrument currently active (i.e. is M3 static at a known position?)"}
    variables_read_only:
        isPoweredOffByPersonInDome      : { type: t_bool                                    , comment: "True if the axes are powered off due to a person entering the dome" }
        isPointing                      : { type: t_bool                                    , comment: "True if the telescope is pointing" }
        isLimitsReached                 : { type: t_bool                                    , comment: "True if a positiom limit is reached" }
        isTracking                      : { type: t_bool                                    , comment: "True if the telescope is tracking" }
        isOffsetting                    : { type: t_bool                                    , comment: "True if the telescope is offsetting (movin" }
        isAtKnownPosition               : { type: t_bool                                    , comment: "True if the telescope is at a known position" }
        isPointingModelActive           : { type: t_bool                                    , comment: "Is a pointing model currently active?"}
        activeRotator                   : { type: THISLIB.AxesRotatorActivity               , comment: "Which rotator is active?" }
        actualKnownPositionName         : { type: t_string                                  , comment: "Name of the known position if isAtKnownPosition is True" }
        config                          : { type: THISLIB.AxesConfig                        , comment: "Active configuration of the Axes subsystem" }
        toCppAxes                       : { type: TMCLIB.TmcFromPlcAxes    , address: "%Q*" , comment: "Data to the C++ task", expand: false}
        activePointingModel             : { type: THISLIB.AxesPointingModelConfig           , comment: "Currently active TPoint model (if isPointingModelActive is TRUE)" , expand: false}
        activePointingModelNumber       : { type: t_int16                                   , comment: "Number of the currently active TPoint model (if isPointingModelActive is TRUE), -1 if no model is active" , expand: false}
        target:
            comment                     : "The actual target"
            arguments:
                isGiven                 : { comment: "Is there a target given (if not, the target values don't make sense)" }
                isValid                 : { comment: "Is target valid (i.e. not too low, no transformation errors present, ...)?" }
            attributes:
                statuses:
                    attributes:
                        healthStatus    : { type: COMMONLIB.HealthStatus }
        feedback:
            comment                     : "The actual feedback"
            arguments:
                isValid                 : { comment: "Is feedback valid (i.e. are the encoders in a valid state, no transformation errors present, ...)?" }
            attributes:
                statuses:
                    attributes:
                        healthStatus    : { type: COMMONLIB.HealthStatus }
    parts:
        azi:
            comment                     : "The azimuth axis"
            arguments:            
                isEnabled               : { comment: "Is control enabled?" }
                id                      : { comment: "The axis ID" }
                config                  : { comment: "The axis config" }
                aziDriveChannel         : { comment: "The AZI drive channel" }
                ablDriveChannel         : { comment: "The ABL drive channel" }
                aziMainDriveChannel     : { comment: "The main drive channel of the AZI drive" }
                ablMainDriveChannel     : { comment: "The main drive channel of the ABL drive" }
            attributes:
                statuses:
                    attributes:
                        healthStatus    : { type: COMMONLIB.HealthStatus }
                        busyStatus      : { type: COMMONLIB.BusyStatus }
                        poweredStatus   : { type: COMMONLIB.PoweredStatus }
        ele:
            comment                     : "The elevation axis"
            arguments:
                isEnabled               : { comment: "Is control enabled?" }
                id                      : { comment: "The axis ID" }
                config                  : { comment: "The axis config" }
                driveChannel            : { comment: "The ELE drive channel" }
                mainDriveChannel        : { comment: "The main drive channel of the drive" }
            attributes:
                statuses:
                    attributes:
                        healthStatus    : { type: COMMONLIB.HealthStatus }
                        busyStatus      : { type: COMMONLIB.BusyStatus }
                        poweredStatus   : { type: COMMONLIB.PoweredStatus }
        roc:
            comment                     : "The cassegrain derotator axis"
            arguments:
                isEnabled               : { comment: "Is control enabled?" }
                id                      : { comment: "The axis ID" }
                config                  : { comment: "The axis config" }
                driveChannel            : { comment: "The ROC drive channel" }
                mainDriveChannel        : { comment: "The main drive channel of the drive" }
            attributes:
                statuses:
                    attributes:
                        healthStatus    : { type: COMMONLIB.HealthStatus }
                        busyStatus      : { type: COMMONLIB.BusyStatus }
                        poweredStatus   : { type: COMMONLIB.PoweredStatus }
        ron:
            comment                     : "The nasmyth derotator axis"
            arguments:
                isEnabled               : { comment: "Is control enabled?" }
                id                      : { comment: "The axis ID" }
                config                  : { comment: "The axis config" }
                driveChannel            : { comment: "The RON drive channel" }
                mainDriveChannel        : { comment: "The main drive channel of the drive" }
            attributes:
                statuses:
                    attributes:
                        healthStatus    : { type: COMMONLIB.HealthStatus }
                        busyStatus      : { type: COMMONLIB.BusyStatus }
                        poweredStatus   : { type: COMMONLIB.PoweredStatus }
        io:
            comment                     : "I/O modules and drives"
            attributes:
                isEnabled               : { type: t_bool                                    , comment: "Is control enabled?" }
                parts:
                    attributes:
                        aziDrive        : createDrive("AZI drive")
                        ablDrive        : createDrive("ABL drive")
                        eleDrive        : createDrive("ELE drive")
                statuses:
                    attributes:
                        healthStatus    : { type: COMMONLIB.HealthStatus }
        configManager:
            comment                     : "The config manager (to load/save/activate configuration data)"
            type                        : COMMONLIB.ConfigManager
        tpoint:
            comment                     : "The TPOINT models setup"
            attributes:
                isEnabled               : { type: t_bool }
                statuses:
                    attributes:
                        healthStatus    : { type: COMMONLIB.HealthStatus }
                        busyStatus      : { type: COMMONLIB.BusyStatus }

    statuses:
        initializationStatus            : { type: COMMONLIB.InitializationStatus }
        healthStatus                    : { type: COMMONLIB.HealthStatus }
        busyStatus                      : { type: COMMONLIB.BusyStatus }
        operatingStatus                 : { type: COMMONLIB.OperatingStatus }
        poweredStatus                   : { type: COMMONLIB.PoweredStatus }
    processes:
        initialize                      : { type: COMMONLIB.Process                         , comment: "Start initializing" }
        reset                           : { type: COMMONLIB.Process                         , comment: "Reset the axis (no homing)" }
        lock                            : { type: COMMONLIB.Process                         , comment: "Lock the system" }
        unlock                          : { type: COMMONLIB.Process                         , comment: "Unlock the system" }
        changeOperatingState            : { type: COMMONLIB.ChangeOperatingStateProcess     , comment: "Change the operating state (e.g. AUTO, MANUAL, ...)" }
        setTarget                       : { type: THISLIB.AxesSetTargetProcess              , comment: "Set a new target" }
        point                           : { type: THISLIB.AxesPointProcess                  , comment: "Point the telescope to a new target" }
        pointRelative                   : { type: THISLIB.AxesPointRelativeProcess         , comment: "Point the telescope relative to the current target" }
        stop                            : { type: THISLIB.AxesStopProcess                   , comment: "Stop the axes (i.e. stop pointing, tracking, moving, ...)" }
        quickStop                       : { type: THISLIB.AxesStopProcess                   , comment: "Quickly stop the axes (i.e. stop pointing, tracking, moving, ...)" }
        powerOn                         : { type: THISLIB.AxesMultiPowerOnProcess           , comment: "Power on the axes" }
        powerOff                        : { type: THISLIB.AxesPowerOffProcess               , comment: "Power off the axes" }
        doHoming                        : { type: THISLIB.AxesDoHomingProcess               , comment: "Do a homing of the axes" }
        moveAbsolute                    : { type: THISLIB.AxesMultiMoveProcess              , comment: "Move the axes in alt-azimuth to an absolute position" }
        moveRelative                    : { type: THISLIB.AxesMultiMoveProcess              , comment: "Move the axes in alt-azimuth relative to the current position" }
        moveKnownPosition               : { type: THISLIB.AxesMoveKnownPositionProcess      , comment: "Move the axes to the given known position" }
        enablePointingModel             : { type: THISLIB.AxesEnablePointingModelProcess    , comment: "Enable a pointing model with the given name" }
        disablePointingModel            : { type: COMMONLIB.Process                         , comment: "Disable the currently active pointing model"}
        setAlphaDeltaVelocity           : { type: THISLIB.AxesSetAlphaDeltaVelocityProcess  , comment: "Set an additional alpha/delta velocity (e.g. to track solar system objects)"}
    calls:
        # processes
        initialize:
            isEnabled                   : -> AND( NOT(self.statuses.initializationStatus.locked),
                                                  OR(self.statuses.initializationStatus.shutdown,
                                                     self.statuses.initializationStatus.initializingFailed,
                                                     self.statuses.initializationStatus.initialized) )
        lock:
            isEnabled                   : -> self.operatorStatus.tech
        unlock:
            isEnabled                   : -> AND(self.operatorStatus.tech, self.statuses.initializationStatus.locked)
        changeOperatingState:
            isEnabled                   : -> AND(self.statuses.busyStatus.idle, self.statuses.initializationStatus.initialized, self.operatorStatus.tech)
        setTarget:
            isEnabled                   : -> AND(self.statuses.initializationStatus.initialized, self.operatorStatus.tech)
        point:
            isEnabled                   : -> AND(self.statuses.initializationStatus.initialized,
                                                 self.statuses.busyStatus.idle,
                                                 self.statuses.poweredStatus.enabled)
        pointRelative:
            isEnabled                   : -> AND(self.statuses.initializationStatus.initialized,
                                                 self.statuses.busyStatus.idle,
                                                 self.statuses.poweredStatus.enabled)
        reset:
            isEnabled                   : -> TRUE
        stop:
            isEnabled                   : -> self.statuses.initializationStatus.initialized
        quickStop:
            isEnabled                   : -> self.statuses.initializationStatus.initialized
        moveAbsolute:
            isEnabled                   : -> AND(self.statuses.initializationStatus.initialized,
                                                 self.statuses.busyStatus.idle,
                                                 self.statuses.poweredStatus.enabled)
        moveRelative:
            isEnabled                   : -> AND(self.statuses.initializationStatus.initialized,
                                                 self.statuses.busyStatus.idle,
                                                 self.statuses.poweredStatus.enabled)
        powerOn:
            isEnabled                   : -> AND( NOT(self.statuses.initializationStatus.locked),
                                                  self.statuses.initializationStatus.initialized,
                                                  self.processes.powerOn.statuses.busyStatus.idle )
        powerOff:
            isEnabled                   : -> AND( self.statuses.initializationStatus.initialized,
                                                  self.processes.powerOff.statuses.busyStatus.idle )
        doHoming:
            isEnabled                   : -> self.operatorStatus.tech
        moveKnownPosition:
            isEnabled                   : -> AND(self.statuses.initializationStatus.initialized,
                                                 self.statuses.busyStatus.idle,
                                                 self.statuses.poweredStatus.enabled)
        enablePointingModel:
            isEnabled                   : -> self.statuses.busyStatus.idle
        disablePointingModel:
            isEnabled                   : -> self.statuses.busyStatus.idle
        setAlphaDeltaVelocity:
            isEnabled                   : -> AND( self.statuses.initializationStatus.initialized,
                                                  self.statuses.busyStatus.idle )
        # statuses
        healthStatus:
            isGood                      : -> MTCS_SUMMARIZE_GOOD(
                                                     self.feedback,
                                                     self.target,
                                                     self.parts.azi,
                                                     self.parts.ele,
                                                     self.parts.roc,
                                                     self.parts.ron,
                                                     self.parts.configManager,
                                                     self.parts.tpoint,
                                                     self.parts.io,
                                                     self.processes.initialize,
                                                     self.processes.reset,
                                                     self.processes.lock,
                                                     self.processes.unlock,
                                                     self.processes.changeOperatingState,
                                                     self.processes.setTarget,
                                                     self.processes.point,
                                                     self.processes.pointRelative,
                                                     self.processes.stop,
                                                     self.processes.quickStop,
                                                     self.processes.powerOn,
                                                     self.processes.powerOff,
                                                     self.processes.doHoming,
                                                     self.processes.moveAbsolute,
                                                     self.processes.moveRelative,
                                                     self.processes.moveKnownPosition,
                                                     self.processes.enablePointingModel,
                                                     self.processes.disablePointingModel,
                                                     self.processes.setAlphaDeltaVelocity)
            hasWarning                  : -> MTCS_SUMMARIZE_WARN(
                                                     self.feedback,
                                                     self.target,
                                                     self.parts.azi,
                                                     self.parts.ele,
                                                     self.parts.roc,
                                                     self.parts.ron,
                                                     self.parts.configManager,
                                                     self.parts.tpoint,
                                                     self.parts.io,
                                                     self.processes.initialize,
                                                     self.processes.reset,
                                                     self.processes.lock,
                                                     self.processes.unlock,
                                                     self.processes.changeOperatingState,
                                                     self.processes.setTarget,
                                                     self.processes.point,
                                                     self.processes.pointRelative,
                                                     self.processes.stop,
                                                     self.processes.quickStop,
                                                     self.processes.powerOn,
                                                     self.processes.powerOff,
                                                     self.processes.doHoming,
                                                     self.processes.moveAbsolute,
                                                     self.processes.moveRelative,
                                                     self.processes.moveKnownPosition,
                                                     self.processes.enablePointingModel,
                                                     self.processes.disablePointingModel,
                                                     self.processes.setAlphaDeltaVelocity)
        busyStatus:
            isBusy                      : -> MTCS_SUMMARIZE_BUSY(
                                                     self.parts.azi,
                                                     self.parts.ele,
                                                     self.parts.roc,
                                                     self.parts.ron,
                                                     self.parts.configManager,
                                                     self.parts.tpoint,
                                                     self.processes.initialize,
                                                     self.processes.reset,
                                                     self.processes.lock,
                                                     self.processes.unlock,
                                                     self.processes.changeOperatingState,
                                                     self.processes.setTarget,
                                                     self.processes.point,
                                                     self.processes.pointRelative,
                                                     self.processes.stop,
                                                     self.processes.quickStop,
                                                     self.processes.powerOn,
                                                     self.processes.powerOff,
                                                     self.processes.doHoming,
                                                     self.processes.moveAbsolute,
                                                     self.processes.moveRelative,
                                                     self.processes.moveKnownPosition,
                                                     self.processes.enablePointingModel,
                                                     self.processes.disablePointingModel,
                                                     self.processes.setAlphaDeltaVelocity)
        operatingStatus:
            superState                  : -> self.statuses.initializationStatus.initialized
        configManager:
            isEnabled                   : -> self.operatorStatus.tech
        tpoint:
            isEnabled                   : -> self.operatorStatus.tech
        io:
            isEnabled                   : -> self.operatorStatus.tech
        azi:
            isEnabled                   : -> AND( NOT(self.statuses.initializationStatus.locked),
                                                  self.operatorStatus.tech )
            id                          : -> THISLIB.AxesIds.AZI
            config                      : -> self.config.azi
            aziDriveChannel             : -> self.parts.io.parts.aziDrive.parts.channelA
            ablDriveChannel             : -> self.parts.io.parts.ablDrive.parts.channelA
            aziMainDriveChannel         : -> self.parts.io.parts.aziDrive.parts.channelA # AZI drive channel = main drive channel
            ablMainDriveChannel         : -> self.parts.io.parts.ablDrive.parts.channelA # ABL drive channel = main drive channel
        ele:
            isEnabled                   : -> AND( NOT(self.statuses.initializationStatus.locked),
                                                  self.operatorStatus.tech )
            id                          : -> THISLIB.AxesIds.ELE
            config                      : -> self.config.ele
            driveChannel                : -> self.parts.io.parts.eleDrive.parts.channelA
            mainDriveChannel            : -> self.parts.io.parts.eleDrive.parts.channelA # ELE drive channel = main drive channel
        roc:
            isEnabled                   : -> AND( NOT(self.statuses.initializationStatus.locked),
                                                  self.operatorStatus.tech )
            id                          : -> THISLIB.AxesIds.ROC
            config                      : -> self.config.roc
            driveChannel                : -> self.parts.io.parts.aziDrive.parts.channelB
            mainDriveChannel            : -> self.parts.io.parts.aziDrive.parts.channelA
        ron:
            isEnabled                   : -> AND( NOT(self.statuses.initializationStatus.locked),
                                                  self.operatorStatus.tech )
            id                          : -> THISLIB.AxesIds.RON
            config                      : -> self.config.ron
            driveChannel                : -> self.parts.io.parts.ablDrive.parts.channelB
            mainDriveChannel            : -> self.parts.io.parts.ablDrive.parts.channelA


########################################################################################################################
# AxesTarget
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB, "AxesTarget",
    typeOf: THISLIB.Axes.target
    variables:
        isGiven             : { type: t_bool                        , comment: "True if the target is given, false if not" }
        isValid             : { type: t_bool                        , comment: "True if the target is valid, false if not" }
        isTooLow            : { type: t_bool                        , comment: "True if the target is too low to calculate, false if not" }
        alpha               : { type: COMMONLIB.AngularPosition     , comment: "The alpha coordinate (Right Ascention)" , expand: false}
        delta               : { type: COMMONLIB.AngularPosition     , comment: "The delta coordinate (Declination)" , expand: false }
        muAlpha             : { type: t_double                      , comment: "Right ascention proper motion, in arcseconds/year (not multiplied by cos(delta)!)" }
        muDelta             : { type: t_double                      , comment: "Declination proper motion, in arcseconds/year" }
        parallax            : { type: t_double                      , comment: "Object parallax, in arcseconds" }
        radialVelocity      : { type: t_double                      , comment: "Object radial velocity, in km/s" }
        epoch               : { type: t_double                      , comment: "Epoch, e.g. 2000.0" }
        alphaVelocity       : { type: COMMONLIB.AngularVelocity     , comment: "Additional target velocity (e.g. for solar system objects) in alpha direction", expand: false}
        deltaVelocity       : { type: COMMONLIB.AngularVelocity     , comment: "Additional target velocity (e.g. for solar system objects) in delta direction", expand: false}
        alphaTravelled      : { type: COMMONLIB.AngularPosition     , comment: "Alpha traveled so far due to the alphaVelocity", expand: false}
        deltaTravelled      : { type: COMMONLIB.AngularPosition     , comment: "Delta traveled so far due to the deltaVelocity", expand: false}
        alphaOffsetted      : { type: COMMONLIB.AngularPosition     , comment: "Alpha offsetted so far due to the alphaOffset", expand: false}
        deltaOffsetted      : { type: COMMONLIB.AngularPosition     , comment: "Delta offsetted so far due to the deltaOffset", expand: false}
        alphaStart          : { type: COMMONLIB.AngularPosition     , comment: "Original alpha without traveling (=alpha - alphaTraveled - alphaOffsetted)", expand: false}
        deltaStart          : { type: COMMONLIB.AngularPosition     , comment: "Original delta without traveling (=delta - deltaTraveled - deltaOffsetted)", expand: false}

        aziPos              : { type: COMMONLIB.AngularPosition     , comment: "The azimuth target position, as calculated by SLALIBl" , expand: false }
        aziVelo             : { type: COMMONLIB.AngularVelocity     , comment: "The azimuth target velocity, as calculated by SLALIB", expand: false }
        aziAcc              : { type: COMMONLIB.AngularAcceleration , comment: "The azimuth target acceleration, as calculated by SLALIB", expand: false }
        elePos              : { type: COMMONLIB.AngularPosition     , comment: "The elevation target position, as calculated by SLALIB" , expand: false }
        eleVelo             : { type: COMMONLIB.AngularVelocity     , comment: "The elevation target velocity, as calculated by SLALIB", expand: false }
        eleAcc              : { type: COMMONLIB.AngularAcceleration , comment: "The elevation target acceleration, as calculated by SLALIB", expand: false }
        paPos               : { type: COMMONLIB.AngularPosition     , comment: "The position angle target position, as calculated by SLALIB" , expand: false }
        paVelo              : { type: COMMONLIB.AngularVelocity     , comment: "The position angle target velocity, as calculated by SLALIB", expand: false }
        paAcc               : { type: COMMONLIB.AngularAcceleration , comment: "The position angle target acceleration, as calculated by SLALIB", expand: false }

        aziPointingModelOffset : { type: COMMONLIB.AngularPosition     , comment: "The azimuth pointing model offset calculated by the TPoint model" , expand: false }
        elePointingModelOffset : { type: COMMONLIB.AngularPosition     , comment: "The elevation pointing model offset calculated by the TPoint model" , expand: false }

        correctedAzi         : { type: COMMONLIB.AngularPosition     , comment: "The azimuth target position, as calculated by SLALIB, corrected by the TPoint model" , expand: false }
        correctedEle         : { type: COMMONLIB.AngularPosition     , comment: "The elevation target position, as calculated by SLALIB, corrected by the TPoint model" , expand: false }


    statuses:
        healthStatus        : { type: COMMONLIB.HealthStatus }
    calls:
        healthStatus:
            isGood          : -> OR( self.isValid, NOT(self.isGiven))


########################################################################################################################
# AxesFeedback
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB, "AxesFeedback",
    typeOf: THISLIB.Axes.feedback
    variables:
        isValid             : { type: t_bool                    , comment: "True if the feedback is valid, false if not" }
        isTooLow            : { type: t_bool                    , comment: "True if the feedback is too low to calculate, false if not" }
        alpha               : { type: COMMONLIB.AngularPosition , comment: "The alpha coordinate (Right Ascention)" , expand: false}
        delta               : { type: COMMONLIB.AngularPosition , comment: "The delta coordinate (Declination)" , expand: false}

        aziPos              : { type: COMMONLIB.AngularPosition , comment: "The measured AZI position, corrected by TPoint, and normalized to [0..2*PI]" , expand: false}
        elePos              : { type: COMMONLIB.AngularPosition , comment: "The measured ELE position, corrected by TPoint, normalized to [-PI..PI]" , expand: false}
        rocPos              : { type: COMMONLIB.AngularPosition , comment: "The measured ROC position, normalized to [-PI..PI]" , expand: false}
        ronPos              : { type: COMMONLIB.AngularPosition , comment: "The measured RON position, normalized to [-PI..PI]" , expand: false}
        rotPos              : { type: COMMONLIB.AngularPosition , comment: "The measured position of the currently active rotator (ROC or RON), normalized to [-PI..PI]" , expand: false}

        rotOffset           : { type: COMMONLIB.AngularPosition , comment: "The active rotator offset, to North" , expand: false }
        rocOffset           : { type: COMMONLIB.AngularPosition , comment: "The cassegrain rotator offset, to North", expand: false  }
        ronOffset           : { type: COMMONLIB.AngularPosition , comment: "The nasmyth rotator offset, to North", expand: false  }

    statuses:
        healthStatus        : { type: COMMONLIB.HealthStatus }
    calls:
        healthStatus:
            isGood          : -> self.isValid


########################################################################################################################
# AxesUnlockBrakeProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "AxesUnlockBrakeProcess",
    extends: COMMONLIB.BaseProcess
    arguments:
        seconds : { type: t_double, initial: double(10.0), comment: "Unlock the brake for this number of seconds (0 means forever)" }



########################################################################################################################
# AxesSetPositionProcess
########################################################################################################################
MTCS_MAKE_PROCESS THISLIB, "AxesSetPositionProcess",
    extends: COMMONLIB.BaseProcess
    arguments:
        value   : { type: t_double, comment: "New position to be taken over by the axis" }

########################################################################################################################
# AxesAzimuthAxis
########################################################################################################################

createMockupAxis = (comment) ->
    return {
        type: COMMONLIB.AngularAxis
        comment: comment
        expand: false
        arguments:
            isEnabled : { type: t_bool }
        attributes:
            statuses:
                attributes:
                    poweredStatus   : { type: COMMONLIB.PoweredStatus }
                    healthStatus    : { type: COMMONLIB.HealthStatus }
                    busyStatus      : { type: COMMONLIB.BusyStatus }
    }

createMockupLida = (comment) ->
    return {
        type: COMMONLIB.IncrementalEncoder
        comment: comment
        expand: false
        arguments:
            isEnabled : { type: t_bool }
        attributes:
            statuses:
                attributes:
                    healthStatus    : { type: COMMONLIB.HealthStatus }
                    busyStatus      : { type: COMMONLIB.BusyStatus }
    }

MTCS_MAKE_STATEMACHINE THISLIB, "AxesAzimuthAxis",
    typeOf: THISLIB.AxesParts.azi
    variables_hidden:
        isEnabled                   : { type: t_bool                                    , comment: "Is control enabled?" }
        REDUCTION_AZI_TO_TEL        : { type: t_double, initial: double(1440.0)         , comment: "The mechanical reduction between absolute encoder and telescope" }
        REDUCTION_ABL_TO_TEL        : { type: t_double, initial: double(180.0)          , comment: "The mechanical reduction between absolute encoder and telescope" }
        REDUCTION_ABS_ENC_TO_TEL    : { type: t_double, initial: double(18.0)           , comment: "The mechanical reduction between absolute encoder and telescope" }
    variables:
        id                          : { type: THISLIB.AxesIds                           , comment: "Id of this axis"}
    references:
        config                      : { type: THISLIB.AxesAzimuthConfig                 , comment: "Reference to the azimuth config", expand: false }
        aziDriveChannel             :
            type: COMMONLIB.AX52XXDriveChannel
            comment: "Reference to the AZI drive channel"
            expand: false
            attributes:
                statuses:
                    attributes:
                        healthStatus    : { type: COMMONLIB.HealthStatus }
                        busyStatus      : { type: COMMONLIB.BusyStatus }

        ablDriveChannel             :
            type: COMMONLIB.AX52XXDriveChannel
            comment: "Reference to the ABL drive channel"
            expand: false
            attributes:
                statuses:
                    attributes:
                        healthStatus    : { type: COMMONLIB.HealthStatus }
                        busyStatus      : { type: COMMONLIB.BusyStatus }
        aziMainDriveChannel         : { type: COMMONLIB.AX52XXDriveChannel              , comment: "Reference to the main drive channel (channel A) of the drive" , expand: false }
        ablMainDriveChannel         : { type: COMMONLIB.AX52XXDriveChannel              , comment: "Reference to the main drive channel (channel A) of the drive" , expand: false }
    variables_read_only:
        slipError                   : { type: t_bool                                    , comment: "TRUE if the motor appears to be slipping w.r.t. the external encoder" }
        positiveLimitSwitchError    : { type: t_bool                                    , comment: "TRUE if the positive limit switch has detected the axis" }
        negativeLimitSwitchError    : { type: t_bool                                    , comment: "TRUE if the negative limit switch has detected the axis" }
        setPosLimitReached          : { type: t_bool                                    , comment: "TRUE if the setpoint position has reached its limit" }
        deviation1SecAverage        : { type: COMMONLIB.AngularPosition                 , comment: "The deviation between target position and actual position, as a 1 second moving average", expand: false }
        deviation1SecRMS            : { type: COMMONLIB.AngularPosition                 , comment: "The deviation between target position and actual position, as a 1 second moving RMS error", expand: false }
        targetPos                   : { type: COMMONLIB.AngularPosition                 , comment: "The target position", expand: false }
        targetOffset                : { type: COMMONLIB.AngularPosition                 , comment: "Cumulative offset of targetPos. Equals targetPos - targetStart", expand: false }
        targetStart                 : { type: COMMONLIB.AngularPosition                 , comment: "Last absolute movement end position of the axis", expand: false }
        setPos                      : { type: COMMONLIB.AngularPosition                 , comment: "The setpoint position (same as parts.physicalAxis!)", expand: false }
        setVelo                     : { type: COMMONLIB.AngularVelocity                 , comment: "The setpoint velocity (same as parts.physicalAxis!)", expand: false }
        setAcc                      : { type: COMMONLIB.AngularAcceleration             , comment: "The setpoint acceleration (same as parts.physicalAxis!)", expand: false }
        actPos                      : { type: COMMONLIB.AngularPosition                 , comment: "The actual position (same as parts.physicalAxis!)", expand: false }
        actVelo                     : { type: COMMONLIB.AngularVelocity                 , comment: "The actual velocity (same as parts.physicalAxis!)", expand: false }
        actAcc                      : { type: COMMONLIB.AngularAcceleration             , comment: "The actual acceleration (same as parts.physicalAxis!)", expand: false }
        actTorqueAzi                : { type: COMMONLIB.Torque                          , comment: "The actual torque on the telescope axis by the AZI motor", expand: false }
        actTorqueAbl                : { type: COMMONLIB.Torque                          , comment: "The actual torque on the telescope axis by the ABL motor", expand: false }
        lida1Position               : { type: COMMONLIB.AngularPosition                 , comment: "Position of the telescope according to LIDA encoder no. 1", expand: false }
        lida2Position               : { type: COMMONLIB.AngularPosition                 , comment: "Position of the telescope according to LIDA encoder no. 2", expand: false }
        lida3Position               : { type: COMMONLIB.AngularPosition                 , comment: "Position of the telescope according to LIDA encoder no. 3", expand: false }
        lida4Position               : { type: COMMONLIB.AngularPosition                 , comment: "Position of the telescope according to LIDA encoder no. 4", expand: false }
        lidaAveragePosition         : { type: COMMONLIB.AngularPosition                 , comment: "Position of the telescope according to the average of the LIDA encoders", expand: false }
        absoluteEncoderPosition     : { type: COMMONLIB.AngularPosition                 , comment: "The position of the axis, based on the absolute encoder", expand: false }
    parts:
        virtualAxis                 : createMockupAxis("The virtual AZI axis")
        physicalAxis                : createMockupAxis("The physical AZI axis")
        ablAxis                     : createMockupAxis("The (anti-backlash) ABL axis")
        lida1                       : createMockupLida("The external (LIDA) encoder no. 1")
        lida2                       : createMockupLida("The external (LIDA) encoder no. 2")
        lida3                       : createMockupLida("The external (LIDA) encoder no. 3")
        lida4                       : createMockupLida("The external (LIDA) encoder no. 4")
        absoluteEncoder             : { type: COMMONLIB.SSIEncoder                      , comment: "The external absolute encoder" }
    processes:
        moveAbsolute                : { type: THISLIB.AxesMoveAbsoluteProcess           , comment: "Move the axis in an absolute way" }
        moveRelative                : { type: THISLIB.AxesMoveRelativeProcess           , comment: "Move the axis relative to the current position" }
        moveVelocity                : { type: THISLIB.AxesMoveVelocityProcess           , comment: "Move the axis endlessly with the given velocity" }
        reset                       : { type: COMMONLIB.Process                         , comment: "Reset the axis (no homing)" }
        moveOutOfLimitSwitch        : { type: THISLIB.AxesMoveOutOfLimitSwitchProcess   , comment: "Move out of a limit switch" }
        powerOn                     : { type: THISLIB.AxesPowerOnProcess                , comment: "Power on the axis" }
        powerOff                    : { type: THISLIB.AxesPowerOffProcess               , comment: "Power off the axis" }
        doHoming                    : { type: THISLIB.AxesDoHomingProcess               , comment: "Do a homing of the axis" }
        stop                        : { type: THISLIB.AxesStopProcess                   , comment: "Stop the axis (i.e. stop pointing, tracking, moving, ...)" }
        quickStop                   : { type: THISLIB.AxesStopProcess                   , comment: "Quickly stop the axes (i.e. stop pointing, tracking, moving, ...)" }
        unlockBrake                 : { type: THISLIB.AxesUnlockBrakeProcess            , comment: "Temporarily unlock the brake" }
        setPosition                 : { type: THISLIB.AxesSetPositionProcess            , comment: "Set the axis to the given position" }
    statuses:
        busyStatus                  : { type: COMMONLIB.BusyStatus                      , comment: "Is the axis in a busy state?" }
        healthStatus                : { type: COMMONLIB.HealthStatus                    , comment: "Is the axis in a healthy state?" }
        poweredStatus               : { type: COMMONLIB.PoweredStatus                   , comment: "Is the axis powered on or off?" }
    calls:
        virtualAxis:
            isEnabled  : -> self.isEnabled
        physicalAxis:
            isEnabled  : -> self.isEnabled
        ablAxis:
            isEnabled  : -> self.isEnabled
        lida1:
            isEnabled  : -> self.isEnabled
        lida2:
            isEnabled  : -> self.isEnabled
        lida3:
            isEnabled  : -> self.isEnabled
        lida4:
            isEnabled  : -> self.isEnabled
        poweredStatus:
            isEnabled  : -> AND(self.parts.virtualAxis.statuses.poweredStatus.enabled,
                                self.parts.physicalAxis.statuses.poweredStatus.enabled,
                                self.parts.ablAxis.statuses.poweredStatus.enabled)
        healthStatus:
            isGood     : -> AND( MTCS_SUMMARIZE_GOOD(self.aziDriveChannel,
                                                     self.ablDriveChannel,
                                                     self.parts.virtualAxis,
                                                     self.parts.physicalAxis,
                                                     self.parts.ablAxis,
                                                     self.parts.lida1,
                                                     self.parts.lida2,
                                                     self.parts.lida3,
                                                     self.parts.lida4,
                                                     self.parts.absoluteEncoder,
                                                     self.processes.moveAbsolute,
                                                     self.processes.moveRelative,
                                                     self.processes.moveVelocity,
                                                     self.processes.reset,
                                                     self.processes.moveOutOfLimitSwitch,
                                                     self.processes.powerOn,
                                                     self.processes.powerOff,
                                                     self.processes.doHoming,
                                                     self.processes.stop,
                                                     self.processes.quickStop,
                                                     self.processes.unlockBrake,
                                                     self.processes.setPosition),
                                 NOT(self.slipError),
                                 NOT(self.positiveLimitSwitchError),
                                 NOT(self.negativeLimitSwitchError))
            hasWarning : ->      MTCS_SUMMARIZE_WARN(self.aziDriveChannel,
                                                     self.ablDriveChannel,
                                                     self.parts.virtualAxis,
                                                     self.parts.physicalAxis,
                                                     self.parts.ablAxis,
                                                     self.parts.lida1,
                                                     self.parts.lida2,
                                                     self.parts.lida3,
                                                     self.parts.lida4,
                                                     self.parts.absoluteEncoder,
                                                     self.processes.moveAbsolute,
                                                     self.processes.moveRelative,
                                                     self.processes.moveVelocity,
                                                     self.processes.reset,
                                                     self.processes.moveOutOfLimitSwitch,
                                                     self.processes.powerOn,
                                                     self.processes.powerOff,
                                                     self.processes.doHoming,
                                                     self.processes.stop,
                                                     self.processes.quickStop,
                                                     self.processes.unlockBrake,
                                                     self.processes.setPosition)
        busyStatus:
            isBusy     : ->      MTCS_SUMMARIZE_BUSY(self.aziDriveChannel,
                                                     self.ablDriveChannel,
                                                     self.parts.virtualAxis,
                                                     self.parts.physicalAxis,
                                                     self.parts.ablAxis,
                                                     self.parts.lida1,
                                                     self.parts.lida2,
                                                     self.parts.lida3,
                                                     self.parts.lida4,
                                                     self.processes.moveAbsolute,
                                                     self.processes.moveRelative,
                                                     self.processes.moveVelocity,
                                                     self.processes.reset,
                                                     self.processes.moveOutOfLimitSwitch,
                                                     self.processes.powerOn,
                                                     self.processes.powerOff,
                                                     self.processes.doHoming,
                                                     self.processes.stop,
                                                     self.processes.quickStop,
                                                     self.processes.unlockBrake,
                                                     self.processes.setPosition)
        quickStop:
            isEnabled  : -> self.isEnabled
        moveAbsolute:
            isEnabled  : -> self.isEnabled
        moveRelative:
            isEnabled  : -> self.isEnabled
        moveVelocity:
            isEnabled  : -> self.isEnabled
        reset:
            isEnabled  : -> self.isEnabled
        moveOutOfLimitSwitch:
            isEnabled  : -> self.isEnabled
        unlockBrake:
            isEnabled  : -> self.isEnabled
        doHoming:
            isEnabled   : -> self.isEnabled
        powerOn:
            isEnabled   : -> self.isEnabled
        powerOff:
            isEnabled   : -> self.isEnabled
        stop:
            isEnabled   : -> self.isEnabled
        setPosition:
            isEnabled  : -> self.isEnabled




########################################################################################################################
# AxesElevationAxis
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB, "AxesElevationAxis",
    typeOf: THISLIB.AxesParts.ele
    variables_hidden:
        isEnabled                   : { type: t_bool                                    , comment: "Is control enabled?" }
        REDUCTION_MOT_TO_TEL        : { type: t_double, initial: double(1440.0)         , comment: "The mechanical reduction between absolute encoder and telescope" }
        REDUCTION_ABS_ENC_TO_TEL    : { type: t_double, initial: double(18.0)           , comment: "The mechanical reduction between absolute encoder and telescope" }
    variables:
        id                          : { type: THISLIB.AxesIds                           , comment: "Id of this axis"}
    references:
        config                      : { type: THISLIB.AxesElevationConfig               , comment: "Reference to the elevation config", expand: false  }
        driveChannel             :
            type: COMMONLIB.AX52XXDriveChannel
            comment: "Reference to the ELE drive channel"
            expand: false
            attributes:
                statuses:
                    attributes:
                        healthStatus    : { type: COMMONLIB.HealthStatus }
                        busyStatus      : { type: COMMONLIB.BusyStatus }
        mainDriveChannel            : { type: COMMONLIB.AX52XXDriveChannel              , comment: "Reference to the main drive channel (channel A) of the drive" , expand: false }
    variables_read_only:
        slipError                   : { type: t_bool                                    , comment: "TRUE if the motor appears to be slipping w.r.t. the external encoder" }
        positiveLimitSwitchError    : { type: t_bool                                    , comment: "TRUE if the positive limit switch has detected the axis" }
        negativeLimitSwitchError    : { type: t_bool                                    , comment: "TRUE if the negative limit switch has detected the axis" }
        setPosLimitReached          : { type: t_bool                                    , comment: "TRUE if the setpoint position has reached its limit" }
        deviation1SecAverage        : { type: COMMONLIB.AngularPosition                 , comment: "The deviation between target position and actual position, as a 1 second moving average" , expand: false}
        deviation1SecRMS            : { type: COMMONLIB.AngularPosition                 , comment: "The deviation between target position and actual position, as a 1 second moving RMS error", expand: false }
        targetPos                   : { type: COMMONLIB.AngularPosition                 , comment: "The target position", expand: false }
        targetOffset                : { type: COMMONLIB.AngularPosition                 , comment: "Cumulative offset of targetPos. Equals targetPos - targetStart", expand: false }
        targetStart                 : { type: COMMONLIB.AngularPosition                 , comment: "Last absolute movement end position of the axis", expand: false }
        setPos                      : { type: COMMONLIB.AngularPosition                 , comment: "The setpoint position (same as parts.physicalAxis!)", expand: false }
        setVelo                     : { type: COMMONLIB.AngularVelocity                 , comment: "The setpoint velocity (same as parts.physicalAxis!)" , expand: false}
        setAcc                      : { type: COMMONLIB.AngularAcceleration             , comment: "The setpoint acceleration (same as parts.physicalAxis!)" , expand: false}
        actPos                      : { type: COMMONLIB.AngularPosition                 , comment: "The actual position (same as parts.physicalAxis!)" , expand: false}
        actVelo                     : { type: COMMONLIB.AngularVelocity                 , comment: "The actual velocity (same as parts.physicalAxis!)" , expand: false}
        actAcc                      : { type: COMMONLIB.AngularAcceleration             , comment: "The actual acceleration (same as parts.physicalAxis!)" , expand: false}
        actTorque                   : { type: COMMONLIB.Torque                          , comment: "The actual torque on the telescope axis by the ELE motor" , expand: false}
        lida1Position               : { type: COMMONLIB.AngularPosition                 , comment: "Position of the telescope according to LIDA encoder no. 1" , expand: false}
        lida2Position               : { type: COMMONLIB.AngularPosition                 , comment: "Position of the telescope according to LIDA encoder no. 2" , expand: false}
        lidaAveragePosition         : { type: COMMONLIB.AngularPosition                 , comment: "Position of the telescope according to the average of the LIDA encoders" , expand: false}
        absoluteEncoderPosition     : { type: COMMONLIB.AngularPosition                 , comment: "Position of the telescope according to the absolute encoder" , expand: false}
    parts:
        virtualAxis                 : createMockupAxis("The virtual axis")
        physicalAxis                : createMockupAxis("The physical ELE axis")
        lida1                       : createMockupLida("The external (LIDA) encoder no. 1")
        lida2                       : createMockupLida("The external (LIDA) encoder no. 2")
        absoluteEncoder             : { type: COMMONLIB.SSIEncoder                      , comment: "The external absolute encoder" }
    processes:
        moveAbsolute                : { type: THISLIB.AxesMoveAbsoluteProcess           , comment: "Move the axis in an absolute way" }
        moveRelative                : { type: THISLIB.AxesMoveRelativeProcess           , comment: "Move the axis relative to the current position" }
        moveVelocity                : { type: THISLIB.AxesMoveVelocityProcess           , comment: "Move the axis endlessly with the given velocity" }
        reset                       : { type: COMMONLIB.Process                         , comment: "Reset the axis (no homing)" }
        moveOutOfLimitSwitch        : { type: THISLIB.AxesMoveOutOfLimitSwitchProcess   , comment: "Move out of a limit switch" }
        powerOn                     : { type: THISLIB.AxesPowerOnProcess                , comment: "Power on the axis" }
        powerOff                    : { type: THISLIB.AxesPowerOffProcess               , comment: "Power off the axis" }
        doHoming                    : { type: THISLIB.AxesDoHomingProcess               , comment: "Do a homing of the axis" }
        stop                        : { type: THISLIB.AxesStopProcess                   , comment: "Stop the axis (i.e. stop pointing, tracking, moving, ...)" }
        quickStop                   : { type: THISLIB.AxesStopProcess                   , comment: "Quickly stop the axes (i.e. stop pointing, tracking, moving, ...)" }
        setPosition                 : { type: THISLIB.AxesSetPositionProcess            , comment: "Set the axis to the given position" }
        unlockBrake                 : { type: THISLIB.AxesUnlockBrakeProcess            , comment: "Temporarily unlock the brake" }
    statuses:
        busyStatus                  : { type: COMMONLIB.BusyStatus                      , comment: "Is the axis in a busy state?" }
        healthStatus                : { type: COMMONLIB.HealthStatus                    , comment: "Is the axis in a healthy state?" }
        poweredStatus               : { type: COMMONLIB.PoweredStatus                   , comment: "Is the axis powered on or off?" }
    calls:
        virtualAxis:
            isEnabled  : -> self.isEnabled
        physicalAxis:
            isEnabled  : -> self.isEnabled
        lida1:
            isEnabled  : -> self.isEnabled
        lida2:
            isEnabled  : -> self.isEnabled
        healthStatus:
            isGood     : -> AND( MTCS_SUMMARIZE_GOOD(self.driveChannel,
                                                     self.parts.virtualAxis,
                                                     self.parts.physicalAxis,
                                                     self.parts.lida1,
                                                     self.parts.lida2,
                                                     self.parts.absoluteEncoder,
                                                     self.processes.moveAbsolute,
                                                     self.processes.moveRelative,
                                                     self.processes.moveVelocity,
                                                     self.processes.reset,
                                                     self.processes.moveOutOfLimitSwitch,
                                                     self.processes.powerOn,
                                                     self.processes.powerOff,
                                                     self.processes.doHoming,
                                                     self.processes.stop,
                                                     self.processes.quickStop,
                                                     self.processes.unlockBrake,
                                                     self.processes.setPosition),
                                 NOT(self.slipError),
                                 NOT(self.positiveLimitSwitchError),
                                 NOT(self.negativeLimitSwitchError))
            hasWarning : ->      MTCS_SUMMARIZE_WARN(self.driveChannel,
                                                     self.parts.virtualAxis,
                                                     self.parts.physicalAxis,
                                                     self.parts.lida1,
                                                     self.parts.lida2,
                                                     self.parts.absoluteEncoder,
                                                     self.processes.moveAbsolute,
                                                     self.processes.moveRelative,
                                                     self.processes.moveVelocity,
                                                     self.processes.reset,
                                                     self.processes.moveOutOfLimitSwitch,
                                                     self.processes.powerOn,
                                                     self.processes.powerOff,
                                                     self.processes.doHoming,
                                                     self.processes.stop,
                                                     self.processes.quickStop,
                                                     self.processes.unlockBrake,
                                                     self.processes.setPosition)
        busyStatus:
            isBusy     : ->       MTCS_SUMMARIZE_BUSY(self.driveChannel,
                                                     self.parts.virtualAxis,
                                                     self.parts.physicalAxis,
                                                     self.parts.lida1,
                                                     self.parts.lida2,
                                                     self.processes.moveAbsolute,
                                                     self.processes.moveRelative,
                                                     self.processes.moveVelocity,
                                                     self.processes.reset,
                                                     self.processes.moveOutOfLimitSwitch,
                                                     self.processes.powerOn,
                                                     self.processes.powerOff,
                                                     self.processes.doHoming,
                                                     self.processes.stop,
                                                     self.processes.quickStop,
                                                     self.processes.unlockBrake,
                                                     self.processes.setPosition)
        poweredStatus:
            isEnabled  : -> AND(self.parts.virtualAxis.statuses.poweredStatus.enabled,
                                self.parts.physicalAxis.statuses.poweredStatus.enabled)
        quickStop:
            isEnabled  : -> self.isEnabled
        moveAbsolute:
            isEnabled  : -> self.isEnabled
        moveRelative:
            isEnabled  : -> self.isEnabled
        moveVelocity:
            isEnabled  : -> self.isEnabled
        reset:
            isEnabled  : -> self.isEnabled
        doHoming:
            isEnabled  : -> self.isEnabled
        moveOutOfLimitSwitch:
            isEnabled  : -> self.isEnabled
        powerOn:
            isEnabled  : -> self.isEnabled
        powerOff:
            isEnabled  : -> self.isEnabled
        stop:
            isEnabled  : -> self.isEnabled
        setPosition:
            isEnabled  : -> self.isEnabled


########################################################################################################################
# AxesRotationAxis
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB, "AxesRotationAxis",
    typeOf: [THISLIB.AxesParts.roc, THISLIB.AxesParts.ron]
    variables_hidden:
        isEnabled                   : { type: t_bool                                    , comment: "Is control enabled?" }
    variables:
        id                          : { type: THISLIB.AxesIds                           , comment: "Id of this axis"}
    references:
        config                      : { type: THISLIB.AxesRotationConfig                , comment: "Reference to the rotation config" , expand: false }
        driveChannel             :
            type: COMMONLIB.AX52XXDriveChannel
            comment: "Reference to the axis drive channel"
            expand: false
            attributes:
                statuses:
                    attributes:
                        healthStatus    : { type: COMMONLIB.HealthStatus }
                        busyStatus      : { type: COMMONLIB.BusyStatus }
        mainDriveChannel            : { type: COMMONLIB.AX52XXDriveChannel              , comment: "Reference to the main drive channel (channel A) of the drive" , expand: false }
    variables_read_only:
        positiveLimitSwitchError    : { type: t_bool                                    , comment: "TRUE if the positive limit switch has detected the axis" }
        negativeLimitSwitchError    : { type: t_bool                                    , comment: "TRUE if the negative limit switch has detected the axis" }
        setPosLimitReached          : { type: t_bool                                    , comment: "TRUE if the setpoint position has reached its limit" }
        deviation1SecAverage        : { type: COMMONLIB.AngularPosition                 , comment: "The deviation between target position and actual position, as a 1 second moving average", expand: false }
        deviation1SecRMS            : { type: COMMONLIB.AngularPosition                 , comment: "The deviation between target position and actual position, as a 1 second moving RMS error", expand: false }
        targetPos                   : { type: COMMONLIB.AngularPosition                 , comment: "The target position", expand: false }
        targetOffset                : { type: COMMONLIB.AngularPosition                 , comment: "Cumulative offset of targetPos. Equals targetPos - targetStart", expand: false }
        targetStart                 : { type: COMMONLIB.AngularPosition                 , comment: "Last absolute movement end position of the axis", expand: false }
        setPos                      : { type: COMMONLIB.AngularPosition                 , comment: "The setpoint position (same as parts.physicalAxis!)", expand: false }
        setVelo                     : { type: COMMONLIB.AngularVelocity                 , comment: "The setpoint velocity (same as parts.physicalAxis!)", expand: false }
        setAcc                      : { type: COMMONLIB.AngularAcceleration             , comment: "The setpoint acceleration (same as parts.physicalAxis!)", expand: false }
        actPos                      : { type: COMMONLIB.AngularPosition                 , comment: "The actual position (same as parts.eleAxis!)", expand: false }
        actVelo                     : { type: COMMONLIB.AngularVelocity                 , comment: "The actual velocity (same as parts.eleAxis!)", expand: false }
        actAcc                      : { type: COMMONLIB.AngularAcceleration             , comment: "The actual acceleration (same as parts.eleAxis!)", expand: false }
        actTorque                   : { type: COMMONLIB.Torque                          , comment: "The actual torque on the telescope axis by the ELE motor", expand: false }
    parts:
        virtualAxis                 : createMockupAxis("The virtual axis")
        physicalAxis                : createMockupAxis("The physical axis")
    processes:
        moveAbsolute                : { type: THISLIB.AxesMoveAbsoluteProcess           , comment: "Move the axis in an absolute way" }
        moveRelative                : { type: THISLIB.AxesMoveRelativeProcess           , comment: "Move the axis relative to the current position" }
        moveVelocity                : { type: THISLIB.AxesMoveVelocityProcess           , comment: "Move the axis endlessly with the given velocity" }
        reset                       : { type: COMMONLIB.Process                         , comment: "Reset the axis (no homing)" }
        moveOutOfLimitSwitch        : { type: THISLIB.AxesMoveOutOfLimitSwitchProcess   , comment: "Move out of a limit switch" }
        powerOn                     : { type: THISLIB.AxesPowerOnProcess                , comment: "Power on the axis" }
        powerOff                    : { type: THISLIB.AxesPowerOffProcess               , comment: "Power off the axis" }
        stop                        : { type: THISLIB.AxesStopProcess                   , comment: "Stop the axis (i.e. stop pointing, tracking, moving, ...)" }
        quickStop                   : { type: THISLIB.AxesStopProcess                   , comment: "Quickly stop the axes (i.e. stop pointing, tracking, moving, ...)" }
        setPosition                 : { type: THISLIB.AxesSetPositionProcess            , comment: "Set the axis to the given position" }
    statuses:
        busyStatus                  : { type: COMMONLIB.BusyStatus                      , comment: "Is the axis in a busy state?" }
        healthStatus                : { type: COMMONLIB.HealthStatus                    , comment: "Is the axis in a healthy state?" }
        poweredStatus               : { type: COMMONLIB.PoweredStatus                   , comment: "Is the axis powered on or off?" }
    calls:
        virtualAxis:
            isEnabled  : -> self.isEnabled
        physicalAxis:
            isEnabled  : -> self.isEnabled
        healthStatus:
            isGood     : -> AND( MTCS_SUMMARIZE_GOOD(self.driveChannel,
                                                     self.parts.virtualAxis,
                                                     self.parts.physicalAxis,
                                                     self.processes.moveAbsolute,
                                                     self.processes.moveRelative,
                                                     self.processes.moveVelocity,
                                                     self.processes.reset,
                                                     self.processes.moveOutOfLimitSwitch,
                                                     self.processes.powerOn,
                                                     self.processes.powerOff,
                                                     self.processes.stop,
                                                     self.processes.quickStop,
                                                     self.processes.setPosition),
                                 NOT(self.positiveLimitSwitchError),
                                 NOT(self.negativeLimitSwitchError))
            hasWarning : ->      MTCS_SUMMARIZE_WARN(self.driveChannel,
                                                     self.parts.virtualAxis,
                                                     self.parts.physicalAxis,
                                                     self.processes.moveAbsolute,
                                                     self.processes.moveRelative,
                                                     self.processes.moveVelocity,
                                                     self.processes.reset,
                                                     self.processes.moveOutOfLimitSwitch,
                                                     self.processes.powerOn,
                                                     self.processes.powerOff,
                                                     self.processes.stop,
                                                     self.processes.quickStop,
                                                     self.processes.setPosition)
        busyStatus:
            isBusy     : ->       MTCS_SUMMARIZE_BUSY(self.driveChannel,
                                                     self.parts.virtualAxis,
                                                     self.parts.physicalAxis,
                                                     self.processes.moveAbsolute,
                                                     self.processes.moveRelative,
                                                     self.processes.moveVelocity,
                                                     self.processes.reset,
                                                     self.processes.moveOutOfLimitSwitch,
                                                     self.processes.powerOn,
                                                     self.processes.powerOff,
                                                     self.processes.stop,
                                                     self.processes.quickStop,
                                                     self.processes.setPosition)
        poweredStatus:
            isEnabled  : -> AND(self.parts.virtualAxis.statuses.poweredStatus.enabled,
                                self.parts.physicalAxis.statuses.poweredStatus.enabled)
        quickStop:
            isEnabled  : -> self.isEnabled
        moveAbsolute:
            isEnabled  : -> self.isEnabled
        moveRelative:
            isEnabled  : -> self.isEnabled
        moveVelocity:
            isEnabled  : -> self.isEnabled
        reset:
            isEnabled  : -> self.isEnabled
        moveOutOfLimitSwitch:
            isEnabled  : -> self.isEnabled
        powerOn:
            isEnabled  : -> self.isEnabled
        powerOff:
            isEnabled  : -> self.isEnabled
        stop:
            isEnabled  : -> self.isEnabled
        setPosition:
            isEnabled  : -> self.isEnabled


########################################################################################################################
# AxesPointingModelSetup
########################################################################################################################
MTCS_MAKE_STATEMACHINE THISLIB, "AxesPointingModelSetup",
    variables_hidden:
        isEnabled               : { type: t_bool                            , comment: "Is control enabled?" }
    variables:
        editableConfig          : { type: THISLIB.AxesPointingModelConfig   , comment: "Editable configuration of the particular TPOINT model" , expand: false}
    variables_read_only:
        config                  : { type: THISLIB.AxesPointingModelConfig   , comment: "Active configuration of the particular TPOINT model", expand: false }
    parts:
        configManager           : { type: COMMONLIB.ConfigManager           , comment: "The config manager (to load/save/activate configuration data)" }
    calls:
        configManager:
            isEnabled           : -> self.isEnabled


########################################################################################################################
# AxesPointingModelsSetup
########################################################################################################################

createModel = () ->
    return {
            type: THISLIB.AxesPointingModelSetup
            expand: false
            arguments:
                isEnabled : { type: t_bool }
            attributes:
                parts:
                    attributes:
                        configManager:
                            attributes:
                                statuses:
                                    attributes:
                                        healthStatus    : { type: COMMONLIB.HealthStatus }
                                        busyStatus      : { type: COMMONLIB.BusyStatus }
    }

MTCS_MAKE_STATEMACHINE THISLIB, "AxesPointingModelsSetup",
    typeOf                      : [ THISLIB.AxesParts.tpoint ]
    variables_hidden:
        isEnabled               : { type: t_bool                        , comment: "Is control enabled?" }
    statuses:
        busyStatus              : { type: COMMONLIB.BusyStatus          , comment: "Is the pointing models setup in a busy state?" }
        healthStatus            : { type: COMMONLIB.HealthStatus        , comment: "Is the pointing models setup in a healthy state?" }
    parts:
        model0: createModel()
        model1: createModel()
        model2: createModel()
        model3: createModel()
        model4: createModel()
        model5: createModel()
        model6: createModel()
        model7: createModel()
        model8: createModel()
        model9: createModel()
    calls:
        busyStatus:
            isBusy              : -> MTCS_SUMMARIZE_BUSY( self.parts.model0.parts.configManager,
                                                          self.parts.model1.parts.configManager,
                                                          self.parts.model2.parts.configManager,
                                                          self.parts.model3.parts.configManager,
                                                          self.parts.model4.parts.configManager,
                                                          self.parts.model5.parts.configManager,
                                                          self.parts.model6.parts.configManager,
                                                          self.parts.model7.parts.configManager,
                                                          self.parts.model8.parts.configManager,
                                                          self.parts.model9.parts.configManager )
        healthStatus:
            isGood              : -> MTCS_SUMMARIZE_GOOD( self.parts.model0.parts.configManager,
                                                          self.parts.model1.parts.configManager,
                                                          self.parts.model2.parts.configManager,
                                                          self.parts.model3.parts.configManager,
                                                          self.parts.model4.parts.configManager,
                                                          self.parts.model5.parts.configManager,
                                                          self.parts.model6.parts.configManager,
                                                          self.parts.model7.parts.configManager,
                                                          self.parts.model8.parts.configManager,
                                                          self.parts.model9.parts.configManager )
            hasWarning          : -> MTCS_SUMMARIZE_WARN( self.parts.model0.parts.configManager,
                                                          self.parts.model1.parts.configManager,
                                                          self.parts.model2.parts.configManager,
                                                          self.parts.model3.parts.configManager,
                                                          self.parts.model4.parts.configManager,
                                                          self.parts.model5.parts.configManager,
                                                          self.parts.model6.parts.configManager,
                                                          self.parts.model7.parts.configManager,
                                                          self.parts.model8.parts.configManager,
                                                          self.parts.model9.parts.configManager )
        model0:
            isEnabled           : -> self.isEnabled
        model1:
            isEnabled           : -> self.isEnabled
        model2:
            isEnabled           : -> self.isEnabled
        model3:
            isEnabled           : -> self.isEnabled
        model4:
            isEnabled           : -> self.isEnabled
        model5:
            isEnabled           : -> self.isEnabled
        model6:
            isEnabled           : -> self.isEnabled
        model7:
            isEnabled           : -> self.isEnabled
        model8:
            isEnabled           : -> self.isEnabled
        model9:
            isEnabled           : -> self.isEnabled






########################################################################################################################
# AxesIO
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB, "AxesIO",
    typeOf              : [ THISLIB.AxesParts.io ]
    variables:
        isEnabled       : { type: t_bool                   , comment: "Is control enabled?" }
    statuses:
        healthStatus    : { type: COMMONLIB.HealthStatus   , comment: "Is the I/O in a healthy state?"  }
    parts:
        aziDrive        : createDrive("The AX5000 drive for the AZI en ROC motors")
        ablDrive        : createDrive("The AX5000 drive for the ABL en RON motors")
        eleDrive        : createDrive("The AX5000 drive for the ELE en FW motors")

        TA_AZID         : { type: COMMONLIB.EtherCatDevice , comment: "Telescope Axis - AZID" }
        TA_ABLD         : { type: COMMONLIB.EtherCatDevice , comment: "Telescope Axis - ABLD" }
        TA_ELED         : { type: COMMONLIB.EtherCatDevice , comment: "Telescope Axis - ELED" }
        TE_COU          : { type: COMMONLIB.EtherCatDevice , comment: "Telescope Encoders - COU" }
        TE_EN1          : { type: COMMONLIB.EtherCatDevice , comment: "Telescope Encoders - EN1" }
        TE_EN2          : { type: COMMONLIB.EtherCatDevice , comment: "Telescope Encoders - EN2" }
        TE_EN3          : { type: COMMONLIB.EtherCatDevice , comment: "Telescope Encoders - EN3" }
        TE_EN4          : { type: COMMONLIB.EtherCatDevice , comment: "Telescope Encoders - EN4" }
        TE_EN5          : { type: COMMONLIB.EtherCatDevice , comment: "Telescope Encoders - EN5" }
        TE_EN6          : { type: COMMONLIB.EtherCatDevice , comment: "Telescope Encoders - EN6" }
        TE_EN7          : { type: COMMONLIB.EtherCatDevice , comment: "Telescope Encoders - EN7" }
    calls:
        aziDrive:
            isEnabled   : -> self.isEnabled
        ablDrive:
            isEnabled   : -> self.isEnabled
        eleDrive:
            isEnabled   : -> self.isEnabled
        TA_AZID:
            id          : -> STRING("TA:AZID") "id"
            typeId      : -> STRING("AX5206") "typeId"
        TA_ABLD:
            id          : -> STRING("TA:ABLD") "id"
            typeId      : -> STRING("AX5206") "typeId"
        TA_ELED:
            id          : -> STRING("TA:ELED") "id"
            typeId      : -> STRING("AX5206") "typeId"
        TE_COU:
            id          : -> STRING("TE:COU") "id"
            typeId      : -> STRING("EK1100") "typeId"
        TE_EN1:
            id          : -> STRING("TE:EN1") "id"
            typeId      : -> STRING("EL5101") "typeId"
        TE_EN2:
            id          : -> STRING("TE:EN2") "id"
            typeId      : -> STRING("EL5101") "typeId"
        TE_EN3:
            id          : -> STRING("TE:EN3") "id"
            typeId      : -> STRING("EL5101") "typeId"
        TE_EN4:
            id          : -> STRING("TE:EN4") "id"
            typeId      : -> STRING("EL5101") "typeId"
        TE_EN5:
            id          : -> STRING("TE:EN5") "id"
            typeId      : -> STRING("EL5101") "typeId"
        TE_EN6:
            id          : -> STRING("TE:EN6") "id"
            typeId      : -> STRING("EL5101") "typeId"
        TE_EN7:
            id          : -> STRING("TE:EN7") "id"
            typeId      : -> STRING("EL5002") "typeId"
        healthStatus:
            isGood      : -> MTCS_SUMMARIZE_GOOD(self.parts.aziDrive,
                                                 self.parts.ablDrive,
                                                 self.parts.eleDrive,
                                                 self.parts.TA_AZID,
                                                 self.parts.TA_ABLD,
                                                 self.parts.TA_ELED,
                                                 self.parts.TE_COU,
                                                 self.parts.TE_EN1,
                                                 self.parts.TE_EN1,
                                                 self.parts.TE_EN2,
                                                 self.parts.TE_EN3,
                                                 self.parts.TE_EN4,
                                                 self.parts.TE_EN5,
                                                 self.parts.TE_EN6,
                                                 self.parts.TE_EN7)




########################################################################################################################
# Write the model to file
########################################################################################################################

axes_soft.WRITE "models/mtcs/axes/software.jsonld"
