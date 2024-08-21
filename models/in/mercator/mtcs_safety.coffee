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

MODEL "http://www.mercator.iac.es/onto/models/mtcs/safety/software" : "safety_soft"

safety_soft.IMPORT mm_all
safety_soft.IMPORT common_soft


########################################################################################################################
# Define the containing PLC library
########################################################################################################################

safety_soft.ADD MTCS_MAKE_LIB "mtcs_safety"

# make aliases (with scope of this file only)
COMMONLIB = common_soft.mtcs_common
THISLIB   = safety_soft.mtcs_safety



########################################################################################################################
# SafetyDomeAccessAlertConfig
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "SafetyDomeAccessAlertConfig",
    items:
        pattern       : { type: t_uint32, comment: "Bit pattern, for which bit=high means alert active, bit=low means alert off" }
        patternLength : { type: t_uint8 , comment: "Number of bits of the bitPattern to use (between 1 and 32)" }
        bitLength     : { type: t_uint16, comment: "Sound length of 1 bit, in milliseconds" }
        totalTime     : { type: t_uint16, comment: "The time, in number of milliseconds, during which the pattern is repeated. 0 means repeat forever." }

########################################################################################################################
# SafetyDomeAccessConfig
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "SafetyDomeAccessConfig",
    items:
        disabled                       : { type: t_bool                             , comment: "True if the dome access control system should be disabled permanently." }
        bypassTimeAfterPassword        : { type: t_double                           , comment: "Time until during which the doors sensors are being bypassed after entering the password, in seconds" }
        bypassingSound                 : { type: THISLIB.SafetyDomeAccessAlertConfig, comment: "Sound to play when the doors sensors are being bypassed" }
        bypassedPermanentlyVisual      : { type: THISLIB.SafetyDomeAccessAlertConfig, comment: "LED pattern to play when the doors sensors are now bypassed permanently" }
        doorsOpenedWhenEnteringSound   : { type: THISLIB.SafetyDomeAccessAlertConfig, comment: "Sound to play when a door is being opened for the first time (i.e. when a person is entering)" }
        doorsOpenedWhenLeavingSound    : { type: THISLIB.SafetyDomeAccessAlertConfig, comment: "Sound to play when a door is being opened for the 2nd or 3rd or ... time (i.e. when a person is leaving)"  }
        leavingWhenDoorsClosedSound    : { type: THISLIB.SafetyDomeAccessAlertConfig, comment: "Sound to play when the personHasLeftButton is pressed when the doors are closed" }
        leavingWhenDoosOpenedSound     : { type: THISLIB.SafetyDomeAccessAlertConfig, comment: "Sound to play when the personHasLeftButton is pressed when the doors are still open" }
        doorsOpenedVisual              : { type: THISLIB.SafetyDomeAccessAlertConfig, comment: "LED pattern to play when the doors were opened without bypass (i.e. without password)" }


########################################################################################################################
# SafetyConfig
########################################################################################################################

MTCS_MAKE_CONFIG THISLIB, "SafetyConfig",
    items:
        domeAccess : { type: THISLIB.SafetyDomeAccessConfig, comment: "Some configuration values of the Dome Access" }


########################################################################################################################
# Safety
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB,  "Safety",
    variables:
        editableConfig                  : { type: THISLIB.SafetyConfig          , comment: "Editable configuration of the Safety subsystem" }
    references:
        operatorStatus                  : { type: COMMONLIB.OperatorStatus      , comment: "Shared operator status"}
        activityStatus                  : { type: COMMONLIB.ActivityStatus      , comment: "Shared activity status"}
    variables_read_only:
        config                          : { type: THISLIB.SafetyConfig          , comment: "Active configuration of the Safety subsystem" }
    parts:
        hydraulics:
            comment                     : "Hydraulics safety"
            arguments:
                operatorStatus          : {}
                activityStatus          : {}
            attributes:
                statuses:
                    attributes:
                        healthStatus    : { type: COMMONLIB.HealthStatus }
                        busyStatus      : { type: COMMONLIB.BusyStatus }
        emergencyStops:
            comment                     : "Emergency stops"
            attributes:
                statuses:
                    attributes:
                        healthStatus    : { type: COMMONLIB.HealthStatus }
                        busyStatus      : { type: COMMONLIB.BusyStatus }
        domeAccess:
            comment                     : "Dome access"
            arguments:
                operatorStatus          : {}
                activityStatus          : {}
                config                  : {}
            attributes:
                statuses:
                    attributes:
                        healthStatus    : { type: COMMONLIB.HealthStatus }
                        busyStatus      : { type: COMMONLIB.BusyStatus }
        motionBlocking:
            comment                     : "Motion blocking"
            arguments:
                activityStatus          : {}
                hydraulics              : {}
                emergencyStops          : {}
                domeAccess              : {}
            attributes:
                statuses:
                    attributes:
                        healthStatus    : { type: COMMONLIB.HealthStatus }
                        busyStatus      : { type: COMMONLIB.BusyStatus }
        domeShutter:
            comment                     : "Dome Shutter"
            arguments:
                activityStatus          : {}
                emergencyStops          : {}
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
        communicationHealthStatus       : { type: COMMONLIB.HealthStatus }
        functionBlockHealthStatus       : { type: COMMONLIB.HealthStatus }
        outputHealthStatus              : { type: COMMONLIB.HealthStatus }
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
            isGood                      : -> MTCS_SUMMARIZE_GOOD(self.parts.io,
                                                                 self.parts.hydraulics,
                                                                 self.parts.emergencyStops,
                                                                 self.parts.domeAccess,
                                                                 self.parts.motionBlocking,
                                                                 self.parts.domeShutter)
            hasWarning                  : -> MTCS_SUMMARIZE_WARN(self.parts.io,
                                                                 self.parts.hydraulics,
                                                                 self.parts.emergencyStops,
                                                                 self.parts.domeAccess,
                                                                 self.parts.motionBlocking,
                                                                 self.parts.domeShutter)
        busyStatus:
            isBusy                      : -> OR(self.statuses.initializationStatus.initializing,
                                                self.parts.emergencyStops.statuses.busyStatus.busy,
                                                self.parts.domeAccess.statuses.busyStatus.busy,
                                                self.parts.hydraulics.statuses.busyStatus.busy,
                                                self.parts.domeShutter.statuses.busyStatus.busy,
                                                self.parts.motionBlocking.statuses.busyStatus.busy)
        configManager:
            isEnabled                   : -> self.operatorStatus.tech
        hydraulics:
            operatorStatus              : -> self.operatorStatus
            activityStatus              : -> self.activityStatus
        domeAccess:
            operatorStatus              : -> self.operatorStatus
            activityStatus              : -> self.activityStatus
            config                      : -> self.config.domeAccess
        motionBlocking:
            activityStatus              : -> self.activityStatus
            hydraulics                  : -> self.parts.hydraulics
            emergencyStops              : -> self.parts.emergencyStops
            domeAccess                  : -> self.parts.domeAccess
        domeShutter:
            activityStatus              : -> self.activityStatus
            emergencyStops              : -> self.parts.emergencyStops

########################################################################################################################
# SafetyIO
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB, "SafetyIO",
    typeOf              : [ THISLIB.SafetyParts.io ]
    statuses:
        healthStatus    : { type: COMMONLIB.HealthStatus   , comment: "Is the I/O in a healthy state?"  }
    parts:
        domeAccess:
            comment     : "DA: Dome access I/O"
            attributes:
                statuses:
                    attributes:
                        healthStatus    : { type: COMMONLIB.HealthStatus }
        hydraulicsAndSafety:
            comment     : "HS: Hydraulics and Safety I/O"
            attributes:
                statuses:
                    attributes:
                        healthStatus    : { type: COMMONLIB.HealthStatus }
    calls:
        healthStatus:
            isGood      : -> MTCS_SUMMARIZE_GOOD( self.parts.hydraulicsAndSafety, self.parts.domeAccess )
            hasWarning  : -> MTCS_SUMMARIZE_WARN( self.parts.hydraulicsAndSafety, self.parts.domeAccess )



########################################################################################################################
# SafetyHydraulicsAndSafetyIO
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB, "SafetyHydraulicsAndSafetyIO",
    typeOf              : [ THISLIB.SafetyIOParts.hydraulicsAndSafety ]
    statuses:
        healthStatus    : { type: COMMONLIB.HealthStatus   , comment: "Is the I/O in a healthy state?"  }
    parts:
        COU             : { type: COMMONLIB.EtherCatDevice , comment: "HS:COU (EK1101)" }
        DO1             : { type: COMMONLIB.EtherCatDevice , comment: "HS:DO1 (EL2008)" }
        SI1             : { type: COMMONLIB.EtherCatDevice , comment: "HS:SI1 (EL1904)" }
        SI2             : { type: COMMONLIB.EtherCatDevice , comment: "HS:SI2 (EL1904)" }
        SI3             : { type: COMMONLIB.EtherCatDevice , comment: "HS:SI3 (EL1904)" }
        SI4             : { type: COMMONLIB.EtherCatDevice , comment: "HS:SI4 (EL1904)" }
        SL              : { type: COMMONLIB.EtherCatDevice , comment: "HS:SL (EL6900)" }
        SO1             : { type: COMMONLIB.EtherCatDevice , comment: "HS:SO1 (EL2904)" }
        AI1             : { type: COMMONLIB.EtherCatDevice , comment: "HS:AI1 (EL3102)" }
        AI2             : { type: COMMONLIB.EtherCatDevice , comment: "HS:AI2 (EL3152)" }
        RTD1            : { type: COMMONLIB.EtherCatDevice , comment: "HS:RTD1 (EL3202-0010)" }
        PWR1            : { type: COMMONLIB.EtherCatDevice , comment: "HS:PWR1 (EL9410)" }
        AO1             : { type: COMMONLIB.EtherCatDevice , comment: "HS:AO1 (EL4132)" }
    calls:
        COU:
            id          : -> STRING("HS:COU") "id"
            typeId      : -> STRING("EK1101") "typeId"
        DO1:
            id          : -> STRING("HS:DI1") "id"
            typeId      : -> STRING("EL2008") "typeId"
        SI1:
            id          : -> STRING("HS:SI1") "id"
            typeId      : -> STRING("EL1904") "typeId"
        SI2:
            id          : -> STRING("HS:SI2") "id"
            typeId      : -> STRING("EL1904") "typeId"
        SI3:
            id          : -> STRING("HS:SI3") "id"
            typeId      : -> STRING("EL1904") "typeId"
        SI4:
            id          : -> STRING("HS:SI3") "id"
            typeId      : -> STRING("EL1904") "typeId"
        SL:
            id          : -> STRING("HS:SL") "id"
            typeId      : -> STRING("EL6900") "typeId"
        SO1:
            id          : -> STRING("HS:SO1") "id"
            typeId      : -> STRING("EL2904") "typeId"
        AI1:
            id          : -> STRING("HS:AI1") "id"
            typeId      : -> STRING("EL3102") "typeId"
        AI2:
            id          : -> STRING("HS:AI2") "id"
            typeId      : -> STRING("EL3152") "typeId"
        RTD1:
            id          : -> STRING("HS:RTD1") "id"
            typeId      : -> STRING("EL3202-0010") "typeId"
        PWR1:
            id          : -> STRING("HS:PWR1") "id"
            typeId      : -> STRING("EL9410") "typeId"
        AO1:
            id          : -> STRING("HS:AO1") "id"
            typeId      : -> STRING("EL4132") "typeId"
        healthStatus:
            isGood       : -> MTCS_SUMMARIZE_GOOD( self.parts.COU,
                                                   self.parts.DO1,
                                                   self.parts.SI1,
                                                   self.parts.SI2,
                                                   self.parts.SI3,
                                                   self.parts.SI4,
                                                   self.parts.SL,
                                                   self.parts.SO1,
                                                   self.parts.AI1,
                                                   self.parts.AI2,
                                                   self.parts.RTD1,
                                                   self.parts.PWR1,
                                                   self.parts.AO1 )
            hasWarning   : -> MTCS_SUMMARIZE_WARN( self.parts.COU,
                                                   self.parts.DO1,
                                                   self.parts.SI1,
                                                   self.parts.SI2,
                                                   self.parts.SI3,
                                                   self.parts.SI4,
                                                   self.parts.SL,
                                                   self.parts.SO1,
                                                   self.parts.AI1,
                                                   self.parts.AI2,
                                                   self.parts.RTD1,
                                                   self.parts.PWR1,
                                                   self.parts.AO1 )

########################################################################################################################
# SafetyDomeAccessIO
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB, "SafetyDomeAccessIO",
    typeOf              : [ THISLIB.SafetyIOParts.domeAccess ]
    statuses:
        healthStatus    : { type: COMMONLIB.HealthStatus   , comment: "Is the I/O in a healthy state?"  }
    parts:
        COU             : { type: COMMONLIB.EtherCatDevice , comment: "DA:COU (EK1101)" }
        DI1             : { type: COMMONLIB.EtherCatDevice , comment: "DA:DI1 (EL1008)" }
        DI2             : { type: COMMONLIB.EtherCatDevice , comment: "DA:DI2 (EL1008)" }
        DO1             : { type: COMMONLIB.EtherCatDevice , comment: "DA:DO1 (EL2008)" }
        SI1             : { type: COMMONLIB.EtherCatDevice , comment: "DA:SI1 (EL1904)" }
        RE1             : { type: COMMONLIB.EtherCatDevice , comment: "DA:RE1 (EL2622)" }
        RE2             : { type: COMMONLIB.EtherCatDevice , comment: "DA:RE2 (EL2622)" }
    calls:
        COU:
            id          : -> STRING("DA:COU") "id"
            typeId      : -> STRING("EK1101") "typeId"
        DI1:
            id          : -> STRING("DA:DI1") "id"
            typeId      : -> STRING("EL1008") "typeId"
        DI2:
            id          : -> STRING("DA:DI2") "id"
            typeId      : -> STRING("EL1008") "typeId"
        DO1:
            id          : -> STRING("DA:DO1") "id"
            typeId      : -> STRING("EL2008") "typeId"
        SI1:
            id          : -> STRING("DA:SI1") "id"
            typeId      : -> STRING("EL1904") "typeId"
        RE1:
            id          : -> STRING("DA:RE1") "id"
            typeId      : -> STRING("EL2622") "typeId"
        RE2:
            id          : -> STRING("DA:RE2") "id"
            typeId      : -> STRING("EL2622") "typeId"
        healthStatus:
            isGood       : -> MTCS_SUMMARIZE_GOOD( self.parts.COU,
                                                   self.parts.DI1,
                                                   self.parts.DI2,
                                                   self.parts.DO1,
                                                   self.parts.SI1,
                                                   self.parts.RE1,
                                                   self.parts.RE2 )
            hasWarning   : -> MTCS_SUMMARIZE_WARN( self.parts.COU,
                                                   self.parts.DI1,
                                                   self.parts.DI2,
                                                   self.parts.DO1,
                                                   self.parts.SI1,
                                                   self.parts.RE1,
                                                   self.parts.RE2 )

###################################################################################################
# SafetyHydraulics
###################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB, "SafetyHydraulics",
    typeOf                      : [ THISLIB.SafetyParts.hydraulics ]
    references:
        operatorStatus          : { type: COMMONLIB.OperatorStatus      , comment: "Shared operator status"}
        activityStatus          : { type: COMMONLIB.ActivityStatus      , comment: "Shared activity status"}
    variables:
        # group variables
        groupComError           : { type: t_bool, address: "%I*"        , comment: "TwinSAFE group communication error"}
        groupFbError            : { type: t_bool, address: "%I*"        , comment: "TwinSAFE group function block error"}
        groupOutError           : { type: t_bool, address: "%I*"        , comment: "TwinSAFE group output error"}
        # pumps powered
        pumpsPowered            : { type: t_bool, address: "%I*"        , comment: "TRUE if the pumps are powered"}
        # return filter
        returnFilterOverpressure: { type: t_bool, address: "%I*"        , comment: "TRUE if the oil return filter has an overpressure"}
        # pumps min. frequency (QMin)
        pumpsMinFrequency       : { type: t_bool, address: "%I*"        , comment: "TRUE if the pumps run at a minimum frequency (frequency > QMin)" }
        # pumps startup errors
        pumpsFrequencyNotRising : { type: t_bool, address: "%I*"        , comment: "TRUE if the frequency of the pumps is not rising after a startup command" }
        pressureNotRising       : { type: t_bool, address: "%I*"        , comment: "TRUE if the pressure is not rising after the frequency is rising" }
        # underpressure sensors
        top1NoUnderpressure     : { type: t_bool, address: "%I*"        , comment: "TRUE if there is no underpressure for Top pipe 1" }
        top2NoUnderpressure     : { type: t_bool, address: "%I*"        , comment: "TRUE if there is no underpressure for Top pipe 2" }
        top3NoUnderpressure     : { type: t_bool, address: "%I*"        , comment: "TRUE if there is no underpressure for Top pipe 3" }
        top4NoUnderpressure     : { type: t_bool, address: "%I*"        , comment: "TRUE if there is no underpressure for Top pipe 4" }
        bottom5NoUnderpressure  : { type: t_bool, address: "%I*"        , comment: "TRUE if there is no underpressure for Bottom pipe 5" }
        bottom6NoUnderpressure  : { type: t_bool, address: "%I*"        , comment: "TRUE if there is no underpressure for Bottom pipe 6" }
        bottom7NoUnderpressure  : { type: t_bool, address: "%I*"        , comment: "TRUE if there is no underpressure for Bottom pipe 7" }
        bottom8NoUnderpressure  : { type: t_bool, address: "%I*"        , comment: "TRUE if there is no underpressure for Bottom pipe 8" }
        # overpressure sensors
        topNoOverpressure       : { type: t_bool, address: "%I*"        , comment: "TRUE if there is no overpressure for the Top pipes" }
        bottomNoOverpressure    : { type: t_bool, address: "%I*"        , comment: "TRUE if there is no overpressure for the Bottom pipes" }
        # trips
        topTripOK               : { type: t_bool, address: "%I*"        , comment: "TRUE if there is no TRIP error for the top drive" }
        bottomTripOK            : { type: t_bool, address: "%I*"        , comment: "TRUE if there is no overpressure for the botton drive" }
        # calculated values
        noUnderpressure         : { type: t_bool, address: "%I*"        , comment: "TRUE if there is no underpressure for all 8 pipes" }
        noUnderpressureNoDelay  : { type: t_bool, address: "%I*"        , comment: "TRUE if there is no underpressure for all 8 pipes (even momentarily, without delay)" }
        underpressureError      : { type: t_bool, address: "%I*"        , comment: "TRUE if there is an underpressure problem (e.g. when the pumps are running and there is an underpressure)" }
        noOverpressure          : { type: t_bool, address: "%I*"        , comment: "TRUE if there is no overpressure for all 8 pipes" }
        # task status
        pumpsStartingUp         : { type: t_bool, address: "%I*"        , comment: "TRUE if the pumps are restarting" }
        pumpsStopped            : { type: t_bool, address: "%I*"        , comment: "TRUE if the pumps are stopped" }
        pumpsRunning            : { type: t_bool, address: "%I*"        , comment: "TRUE if the pumps are running" }
        # pumps release
        pumpsRelease            : { type: t_bool, address: "%I*"        , comment: "TRUE if the pumps are released (RFR 'ReglerFreigabe' high)" }
        # summary
        allOK                   : { type: t_bool, address: "%I*"        , comment: "TRUE if the hydraulics are OK" }
    variables_read_only:
        restartPumpsOutput      : { type: t_bool, address: "%Q*"        , comment: "Output to restart the pumps"}
        resetErrorsOutput       : { type: t_bool, address: "%Q*"        , comment: "Output to reset the errors"}
        errorAcknowledge        : { type: t_bool, address: "%Q*"        , comment: "Output to restart the TwinSAFE group"}
    statuses:
        healthStatus            : { type: COMMONLIB.HealthStatus        , comment: "Is the safety in a healthy state? Good=RUN, Bad=safe stopped"  }
        busyStatus              : { type: COMMONLIB.BusyStatus          , comment: "Is the safety busy?"  }
    processes:
        startupPumps            : { type: COMMONLIB.Process             , comment: "Start up the pumps (this will first trigger a reset() command!)" }
        reset                   : { type: COMMONLIB.Process             , comment: "Reset the errors (including the programmed ones and the TwinSAFE group ones)" }
    calls:
        healthStatus:
            isGood              : -> AND( self.allOK, NOT( OR( self.groupComError, self.groupFbError, self.groupOutError ) ) )
#            hasWarning          : -> AND( self.pumpsRunning, OR(self.activityStatus.awake, self.activityStatus.sleeping) )
        busyStatus:
            isBusy              : -> OR( self.processes.startupPumps.statuses.busyStatus.busy, self.processes.reset.statuses.busyStatus.busy)
        startupPumps:
            isEnabled           : -> AND( NOT( OR(self.pumpsStartingUp, self.processes.startupPumps.statuses.busyStatus.busy ) ), self.operatorStatus.tech)
        reset:
            isEnabled           : -> NOT( self.processes.reset.statuses.busyStatus.busy )


########################################################################################################################
# SafetyEmergencyStops
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB, "SafetyEmergencyStops",
    typeOf                      : [ THISLIB.SafetyParts.emergencyStops ]
    variables:
        # group variables
        groupComError           : { type: t_bool, address: "%I*"        , comment: "TwinSAFE group communication error"}
        groupFbError            : { type: t_bool, address: "%I*"        , comment: "TwinSAFE group function block error"}
        groupOutError           : { type: t_bool, address: "%I*"        , comment: "TwinSAFE group output error"}
        # summary
        allOK                   : { type: t_bool, address: "%I*"        , comment: "TRUE if the emergency stops are OK" }
        discrepancyError        : { type: t_bool, address: "%I*"        , comment: "TRUE if there is a discrepancy time error between two contacts of an emergency stop" }
        # individual stops
        dome1NO                 : { type: t_bool, address: "%I*"        , comment: "TRUE if the make contact (NO) is conducting --> button is pushed!" }
        dome1NC                 : { type: t_bool, address: "%I*"        , comment: "TRUE if the break contact (NC) is conducting --> button is not pushed" }
        dome2NO                 : { type: t_bool, address: "%I*"        , comment: "TRUE if the make contact (NO) is conducting --> button is pushed!" }
        dome2NC                 : { type: t_bool, address: "%I*"        , comment: "TRUE if the break contact (NC) is conducting --> button is not pushed" }
        firstFloorNO            : { type: t_bool, address: "%I*"        , comment: "TRUE if the make contact (NO) is conducting --> button is pushed!" }
        firstFloorNC            : { type: t_bool, address: "%I*"        , comment: "TRUE if the break contact (NC) is conducting --> button is not pushed" }
        controlRoomNO           : { type: t_bool, address: "%I*"        , comment: "TRUE if the make contact (NO) is conducting --> button is pushed!" }
        controlRoomNC           : { type: t_bool, address: "%I*"        , comment: "TRUE if the break contact (NC) is conducting --> button is not pushed" }
        domeAccessNO            : { type: t_bool, address: "%I*"        , comment: "TRUE if the make contact (NO) is conducting --> button is pushed!" }
        domeAccessNC            : { type: t_bool, address: "%I*"        , comment: "TRUE if the break contact (NC) is conducting --> button is not pushed" }
    variables_read_only:
        restartOutput           : { type: t_bool, address: "%Q*"        , comment: "Output to restart the emergency buttons"}
        errorAcknowledge        : { type: t_bool, address: "%Q*"        , comment: "Output to restart the TwinSAFE group"}
    statuses:
        healthStatus            : { type: COMMONLIB.HealthStatus        , comment: "Are the emergency stops in a healthy state? Good=RUN, Bad=safe stopped"  }
        busyStatus              : { type: COMMONLIB.BusyStatus          , comment: "Is the safety busy?"  }
    processes:
        reset                   : { type: COMMONLIB.Process             , comment: "Reset the errors (including the programmed ones and the TwinSAFE group ones)" }
    calls:
        busyStatus:
            isBusy              : -> self.processes.reset.statuses.busyStatus.busy
        healthStatus:
            isGood              : -> AND( self.allOK, NOT( OR( self.groupComError, self.groupFbError, self.groupOutError, self.discrepancyError ) ) )
        reset:
            isEnabled            : -> NOT( self.processes.reset.statuses.busyStatus.busy )


########################################################################################################################
# SafetyDomeAccess
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB, "SafetyDomeAccess",
    typeOf                      : [ THISLIB.SafetyParts.domeAccess ]
    references:
        operatorStatus          : { type: COMMONLIB.OperatorStatus      , comment: "Shared operator status"}
        activityStatus          : { type: COMMONLIB.ActivityStatus      , comment: "Shared activity status"}
        config                  : { type: THISLIB.SafetyDomeAccessConfig, comment: "The dome access config" }
    variables:
        # group variables
        groupComError           : { type: t_bool, address: "%I*"        , comment: "TwinSAFE group communication error"}
        groupFbError            : { type: t_bool, address: "%I*"        , comment: "TwinSAFE group function block error"}
        groupOutError           : { type: t_bool, address: "%I*"        , comment: "TwinSAFE group output error"}
        # keypad inputs
        keypadKey1              : { type: t_bool, address: "%I*"        , comment: "TRUE if keypad key 1 is being pressed"}
        keypadKey2              : { type: t_bool, address: "%I*"        , comment: "TRUE if keypad key 2 is being pressed"}
        keypadKey3              : { type: t_bool, address: "%I*"        , comment: "TRUE if keypad key 3 is being pressed"}
        keypadKey4              : { type: t_bool, address: "%I*"        , comment: "TRUE if keypad key 4 is being pressed"}
        keypadKey5              : { type: t_bool, address: "%I*"        , comment: "TRUE if keypad key 5 is being pressed"}
        keypadKey6              : { type: t_bool, address: "%I*"        , comment: "TRUE if keypad key 6 is being pressed"}
        keypadKey7              : { type: t_bool, address: "%I*"        , comment: "TRUE if keypad key 7 is being pressed"}
        keypadKey8              : { type: t_bool, address: "%I*"        , comment: "TRUE if keypad key 8 is being pressed"}
        keypadKey9              : { type: t_bool, address: "%I*"        , comment: "TRUE if keypad key 9 is being pressed"}
        keypadKeyStar           : { type: t_bool, address: "%I*"        , comment: "TRUE if keypad key * is being pressed"}
        # other inputs
        door1Closed             : { type: t_bool, address: "%I*"        , comment: "TRUE if door 1 is closed"}
        door2Closed             : { type: t_bool, address: "%I*"        , comment: "TRUE if door 2 is closed"}
        personHasLeftButtonPressed : { type: t_bool, address: "%I*"        , comment: "TRUE if the unblock button is being pressed"}
        returnButtonPressed     : { type: t_bool, address: "%I*"        , comment: "TRUE if the return button is being pressed"}
        safeAccess              : { type: t_bool, address: "%I*"        , comment: "TRUE if the safety still allows motion (e.g. also during the first seconds that a person has entered"}
    variables_read_only:
        errorAcknowledge        : { type: t_bool, address: "%Q*"        , comment: "Output to restart the TwinSAFE group"}
        personHasEntered        : { type: t_bool, address: "%Q*"        , comment: "TRUE if the doors were opened without bypass/password" }
        enteredLedOn            : { type: t_bool, address: "%Q*"        , comment: "TRUE if the yellow led should be on" }
        movingLedOn             : { type: t_bool, address: "%Q*"        , comment: "TRUE if the red led should be on" }
        awakeLedOn              : { type: t_bool, address: "%Q*"        , comment: "TRUE if the yellow led should be on" }
        sleepingLedOn           : { type: t_bool, address: "%Q*"        , comment: "TRUE if the orange led should be on" }
        buzzerSounding          : { type: t_bool, address: "%Q*"        , comment: "TRUE if the green is being sounded" }
        sensorsBeingBypassed    : { type: t_bool                        , comment: "TRUE if the sensors are currently being bypassed" }
        sensorsBypassedPermanently : { type: t_bool                     , comment: "TRUE if the sensors are being bypassed permanently" }
    parts:
        lampsRelay1             : { type: COMMONLIB.SimpleRelay         , comment: "Lamps relay 1" }
        lampsRelay2             : { type: COMMONLIB.SimpleRelay         , comment: "Lamps relay 2" }
        lampsRelay3             : { type: COMMONLIB.SimpleRelay         , comment: "Lamps relay 3" }
        lampsRelay4             : { type: COMMONLIB.SimpleRelay         , comment: "Lamps relay 4" }
    statuses:
        healthStatus            : { type: COMMONLIB.HealthStatus        , comment: "Are the emergency stops in a healthy state? Good=RUN, Bad=safe stopped"  }
        busyStatus              : { type: COMMONLIB.BusyStatus          , comment: "Is the safety busy?"  }
    processes:
        reset                   : { type: COMMONLIB.Process             , comment: "Reset the errors (including the programmed ones and the TwinSAFE group ones)" }
        personHasLeft           : { type: COMMONLIB.Process             , comment: "Unblock the telescope (if possible, i.e. if no E-Stops are active etc.)" }
        bypass                  : { type: COMMONLIB.Process             , comment: "Bypass the doors sensors for the number of seconds defined in the config" }
        bypassPermanently       : { type: COMMONLIB.Process             , comment: "Bypass the doors sensors permanently (until re-initialization)" }
        stopBypassing           : { type: COMMONLIB.Process             , comment: "Stop bypassing the doors sensors" }
    calls:
        busyStatus:
            isBusy              : -> OR( self.processes.reset.statuses.busyStatus.busy,
                                         self.processes.personHasLeft.statuses.busyStatus.busy,
                                         self.processes.bypass.statuses.busyStatus.busy,
                                         self.processes.bypassPermanently.statuses.busyStatus.busy,
                                         self.processes.stopBypassing.statuses.busyStatus.busy )
        healthStatus:
            isGood              : -> NOT( OR( self.groupComError, self.groupFbError, self.groupOutError) )
            hasWarning          : -> OR( self.personHasEntered, self.sensorsBypassedPermanently )
        reset:
            isEnabled           : -> self.statuses.busyStatus.idle
        personHasLeft:
            isEnabled           : -> AND( self.statuses.busyStatus.idle, self.operatorStatus.tech )
        bypass:
            isEnabled           : -> AND( self.statuses.busyStatus.idle, self.operatorStatus.tech, NOT(self.sensorsBeingBypassed) )
        bypassPermanently:
            isEnabled           : -> AND( self.statuses.busyStatus.idle, self.operatorStatus.tech, NOT(self.sensorsBypassedPermanently) )
        stopBypassing:
            isEnabled           : -> AND( self.statuses.busyStatus.idle, self.operatorStatus.tech, OR(self.sensorsBeingBypassed, self.sensorsBypassedPermanently) )
        lampsRelay1:
            isEnabled           : -> self.operatorStatus.tech
        lampsRelay2:
            isEnabled           : -> self.operatorStatus.tech
        lampsRelay3:
            isEnabled           : -> self.operatorStatus.tech
        lampsRelay4:
            isEnabled           : -> self.operatorStatus.tech



########################################################################################################################
# SafetyMotionBlocking
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB, "SafetyMotionBlocking",
    typeOf                      : [ THISLIB.SafetyParts.motionBlocking ]
    variables:
        # group variables
        groupComError               : { type: t_bool, address: "%I*"        , comment: "TwinSAFE group communication error"}
        groupFbError                : { type: t_bool, address: "%I*"        , comment: "TwinSAFE group function block error"}
        groupOutError               : { type: t_bool, address: "%I*"        , comment: "TwinSAFE group output error"}
        telescopeAzimuthReleaseOK   : { type: t_bool, address: "%I*"        , comment: "TRUE if the telescope azimuth axis is released" }
        telescopeElevationReleaseOK : { type: t_bool, address: "%I*"        , comment: "TRUE if the telescope elevation axis is released" }
        telescopeRotationReleaseOK  : { type: t_bool, address: "%I*"        , comment: "TRUE if the telescope rotation axes are released" }
        domeRotationReleaseOK       : { type: t_bool, address: "%I*"        , comment: "TRUE if the dome rotation axis is released" }
        motionAllowed               : { type: t_bool, address: "%I*"        , comment: "TRUE if motion is allowed"}
    references:
        activityStatus              : { type: COMMONLIB.ActivityStatus      , comment: "Shared activity status"}
        hydraulics                  : { type: THISLIB.SafetyHydraulics      , expand: false }
        emergencyStops              : { type: THISLIB.SafetyEmergencyStops  , expand: false }
        domeAccess                  : { type: THISLIB.SafetyDomeAccess      , expand: false }
    variables_read_only:
        errorAcknowledge            : { type: t_bool, address: "%Q*"        , comment: "Output to restart the TwinSAFE group"}
    statuses:
        busyStatus                  : { type: COMMONLIB.BusyStatus          , comment: "Is the safety busy?"  }
        healthStatus                : { type: COMMONLIB.HealthStatus        , comment: "Is everything unblocked? Good=unblocked, Bad=safe stopped"  }
    processes:
        reset                   : { type: COMMONLIB.Process             , comment: "Reset the errors (including the programmed ones and the TwinSAFE group ones)" }
    calls:
        busyStatus:
            isBusy              : -> self.processes.reset.statuses.busyStatus.busy
        healthStatus:
            isGood              : -> NOT( OR( self.groupComError, self.groupFbError, self.groupOutError ) )
            hasWarning          : -> AND( OR(self.activityStatus.awake, self.activityStatus.moving), NOT( AND(self.telescopeAzimuthReleaseOK, self.telescopeElevationReleaseOK, self.telescopeRotationReleaseOK, self.domeRotationReleaseOK)))
        reset:
            isEnabled            : -> NOT( self.processes.reset.statuses.busyStatus.busy )


########################################################################################################################
# SafetyDomeShutter
########################################################################################################################

MTCS_MAKE_STATEMACHINE THISLIB, "SafetyDomeShutter",
    typeOf                      : [ THISLIB.SafetyParts.domeShutter ]
    variables:
        # group variables
        groupComError               : { type: t_bool, address: "%I*"        , comment: "TwinSAFE group communication error"}
        groupFbError                : { type: t_bool, address: "%I*"        , comment: "TwinSAFE group function block error"}
        groupOutError               : { type: t_bool, address: "%I*"        , comment: "TwinSAFE group output error"}
        shutterAllowed              : { type: t_bool, address: "%I*"        , comment: "TRUE if dome shutter is allowed"}
        lowerOpenSafeOutput         : { type: t_bool, address: "%I*"        , comment: "Safety open lower shutter command"}
        lowerCloseSafeOutput        : { type: t_bool, address: "%I*"        , comment: "Safety close lower shutter command"}
        upperOpenSafeOutput         : { type: t_bool, address: "%I*"        , comment: "Safety open upper shutter command"}
        upperCloseSafeOutput        : { type: t_bool, address: "%I*"        , comment: "Safety close upper shutter command"}
        pumpOnSafeOutput            : { type: t_bool, address: "%I*"        , comment: "Safety pump on command"}
    references:
        activityStatus              : { type: COMMONLIB.ActivityStatus      , comment: "Shared activity status"}
        emergencyStops              : { type: THISLIB.SafetyEmergencyStops  , expand: false }
    variables_read_only:
        errorAcknowledge            : { type: t_bool, address: "%Q*"        , comment: "Output to restart the TwinSAFE group"}
    statuses:
        busyStatus                  : { type: COMMONLIB.BusyStatus          , comment: "Is the safety busy?"  }
        healthStatus                : { type: COMMONLIB.HealthStatus        , comment: "Is everything unblocked? Good=unblocked, Bad=safe stopped"  }
    processes:
        reset                       : { type: COMMONLIB.Process             , comment: "Reset the errors (including the programmed ones and the TwinSAFE group ones)" }
    calls:
        busyStatus:
            isBusy              : -> self.processes.reset.statuses.busyStatus.busy
        healthStatus:
            isGood              : -> NOT( OR( self.groupComError, self.groupFbError, self.groupOutError ) )
        reset:
            isEnabled            : -> NOT( self.processes.reset.statuses.busyStatus.busy )



########################################################################################################################
# Write the model to file
########################################################################################################################

safety_soft.WRITE "models/mtcs/safety/software.jsonld"



