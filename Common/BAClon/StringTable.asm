;;_____________________________________________________________________________
;; Note about NC included assembly files, the radix is hex.
;;_____________________________________________________________________________

        SEG     CODE
        ORG
        IMPORT  _loadr
        IMPORT  _l_shift16
        IMPORT  _add16

LOADROS         equ     4


;;_____________________________________________________________________________
        SEG     TRANSIENT
        ORG
;;-----------------------------------------------------------------------------
;; void loadTString2(unsigned idx, char *dp);
;;
;; Possible variations:
;;      idx could be an unsigned long.
;;      A maximum length argument could be included.
;;-----------------------------------------------------------------------------

        APEXP   %loadTString2
%loadTString2                           ; (idx, *dp)
        pushd   #_tstr_base-*-LOADROS   ; (*offset, ..)
        call    _loadr                  ; (*tp, idx, *dp)
        popd    [3]                     ; (idx, *dp)
_ldstr_top                              ; (idx, *dp)
        ; assume start of string
        push    tos                     ; (idx, idx, ..)
        sbrz    _ldstr_found            ; (idx, *dp)
_ldstr_sloop
        push    [3][0]                  ; (c, idx, ..)
        sbrz    _ldstr_null             ; (idx, *dp)
        inc     [3]
        br      _ldstr_sloop
_ldstr_null                             ; (idx, *dp)
        ; move to next, or check for end.
        dec                             ; (idx--, ..)
        inc     [3]
        push    [3][0]                  ; (c, idx, ..)
        brnz    _ldstr_top              ; (idx, *dp)
        ;
        ; either the located string, or the terminator null.
_ldstr_found                            ; (idx, *dp)
        drop    tos
        popd    [0]                     ; ()
_ldstr_scpy_loop
        push    [3][0]                  ; (c)
        push    tos                     ; (c, c)
        pop     [0][0]                  ; (c)
        inc     [3]
        inc     [0]                     ; (c)
        brnz    _ldstr_scpy_loop        ; ([c])
        ret                             ; ()


_tstr_base      EXPORT

;;      String 0
        data.b  "Space Temp C", 0
        data.b  "SNVT_temp_p_US F", 0
        data.b  "Space Temp F", 0

;;      // Illuminance cannot be used with MSTP - IO ports are repurposed on EVB

        data.b  "Illuminance",  0

        data.b  "Demo SNVT lev cont f", 0
;;      // 5
        data.b  "Demo SNVT count 32",   0

        data.b  "Demo  Amperes",        0

;;      // some example mappings of 'normal variables', as opposed to Network Variables..

        data.b  "Normal signed short - Pos",    0
        data.b  "Normal signed short - Neg",    0
        data.b  "Normal unsigned short - Low",  0

;;      // 10
        data.b  "Normal unsigned short - High", 0

        data.b  "Normal signed long - Pos",     0
        data.b  "Normal signed long - Neg",     0
        data.b  "Normal unsigned long - Low",   0
        data.b  "Normal unsigned long - High",  0

        data.b  "Normal float - Pos",   0
        data.b  "Normal float - Neg",   0

;;      //---------------------------------------------------------------------------------------------------------------------------
;;      // Examples of user created mapping types
;;      // 'User defined' SNVT_scene

        data.b  "Demo snvtscene.scene_number",  0
        data.b  "Demo snvtscene.function",      0


;;      //---------------------------------------------------------------------------------------------------------------------------
;;      // the following for testing only

        data.b  "AI snvtenvironment.lampCurrent",       0
        data.b  "AI snvtenvironment.lampVoltage",       0
        data.b  "AI snvtenvironment.supplyVoltage",     0
        data.b  "AI snvtenvironment.supplyCurrent",     0
        data.b  "AI snvtenvironment.ballastTemp",       0
        data.b  "AI snvtenvironment.power",     0
        data.b  "AI snvtenvironment.powerFactor",       0
        data.b  "AI snvtenvironment.runHours",  0
        data.b  "AI snvtenvironment.energy",    0


        data.b  "Loopback Analog Float:AI",     0
        data.b  "Loopback Analog Int8:AI",      0
        data.b  "Loopback Analog UInt8:AI",     0
        data.b  "Loopback Analog Int16:AI",     0
        data.b  "Loopback Analog UInt16:AI",    0
        data.b  "Loopback Analog Int32:AI",     0
        data.b  "Loopback Analog UInt32:AI",    0

;;      // following tests NV Update by using loopback
        data.b  "Loopback LocalSetpoint:AI",    0

        data.b  "Sixteen Bit Overlay - AI",     0

        data.b  "nvoSwitchOut.value - AI",      0

        data.b  "VAV1:nvoUnitStatus.Mode",      0
        data.b  "VAV1:nvoUnitStatus.IA",        0

        data.b  "VAV1:nvoUnitStatus.HOP",       0
        data.b  "VAV1:nvoUnitStatus.HOS",       0

        data.b  "VAV1:nvoHVACoverride.State",   0
        data.b  "VAV1:nvoHVACoverride.Percent", 0
        data.b  "VAV1:nvoHVACoverride.Flow",    0

        data.b  "SNVT_switch_2.setting.value",  0

        data.b  "AI snvtscene.scene_number",    0
        data.b  "AI snvtscene.function",        0

        data.b  "AI snvtsetting.function",      0
        data.b  "AI snvtsetting.setting",       0
        data.b  "AI snvtsetting.rotation",      0

;;      // mapBinToNormalVarUShort("Loopback Binary uint8:BO", uint8Loopback, 3),

;;      // Create_Binary_Output("nvoSwitch", &nviSwitch,

        data.b  "AI snvtswitch.value",  0

        data.b  "SNVT_switch AI value", 0
        data.b  "SNVT_switch AI generic",       0

;;      // commenting out to test COV on BI only Create_Binary_Output("Loopback Binary uint8:BO", &uint8Loopback, LDT_UShort, 3);

;;      //---------------------------------------------------------------------------------------------------------------------------
;;      // Create Analog Output Objects

        data.b  "Local Setpoint",       0

;;      // Since we cannot see these without LCD, we won't show them in BACnet either

        data.b  "LCD switch (AO value)",        0
        data.b  "LCD Switch (AO generic)",      0

;;      //---------------------------------------------------------------------------------------------------------------------------
;;      // Examples of user created mapping types

        data.b  "Demo snvtscene.scene_number",  0
        data.b  "Demo snvtscene.function",      0

        data.b  "Demo snvtsetting.function",    0
        data.b  "Demo snvtsetting.setting",     0
        data.b  "Demo snvtsetting.rotation",    0

;;    //---------------------------------------------------------------------------------------------------------------------------
;;    // The following example if for an Analog Output where the user wants to manipulate the output from the Neuron Application
;;    // via the BacAppAPI. The handle must be saved uniquely for reference for by the API

        data.b  "Controlled Analog Output",     0


;;      //---------------------------------------------------------------------------------------------------------------------------
;;      // the following for BTC testing only. Do not change the names lightly!

        data.b  "Loopback LocalSetpoint:AO",    0

        data.b  "Loopback Analog Float:AO",     0
        data.b  "Loopback Analog Int8:AO",      0
        data.b  "Loopback Analog UInt8:AO",     0
        data.b  "Loopback Analog Int16:AO",     0
        data.b  "Loopback Analog UInt16:AO",    0
        data.b  "Loopback Analog Int32:AO",     0
        data.b  "Loopback Analog UInt32:AO",    0

;;      // These are to test SNVT switch logic

        data.b  "SNVT_switch AO value", 0
        data.b  "SNVT_switch AO generic",       0

;       // These are to test SNVT switch fields (loopback)

        data.b  "AO snvtswitch.value",              0


        data.b  "AO snvtenvironment.lampCurrent",       0
        data.b  "AO snvtenvironment.lampVoltage",       0
        data.b  "AO snvtenvironment.supplyVoltage",     0
        data.b  "AO snvtenvironment.supplyCurrent",     0
        data.b  "AO snvtenvironment.ballastTemp",       0
        data.b  "AO snvtenvironment.power",     0
        data.b  "AO snvtenvironment.powerFactor",       0
        data.b  "AO snvtenvironment.runHours",  0
        data.b  "AO snvtenvironment.energy",    0

        data.b  "AO snvtscene.scene_number",    0
        data.b  "AO snvtscene.function",        0

        data.b  "AO snvtsetting.function",      0
        data.b  "AO snvtsetting.setting",       0
        data.b  "AO snvtsetting.rotation",      0

;;      //---------------------------------------------------------------------------------------------------------------------------
;;      // Create Binary Input Objects

;;      // Since we cannot see these without LCD, we won't show them in BACnet either
        data.b  "LCD Switch (BI)",      0

;;      // an example of creating a Binary Input object mapped to a bit offset of a bitfield Lon variable or Lon Variable field.
;;      // User needs to be aware of the datasize of the underlying field to be mapped (currently supports 8, 16, 32 bit, by function name)
        data.b  "Demo BI bitfield1",    0
        data.b  "Demo BI bitfield7",    0
        data.b  "Demo BI bitfield8",    0
        data.b  "Demo BI bitfield15",   0

        data.b  "NON_SPF_CORRIDOR_BTD_L2_E26_CLOSE_FB", 0

;;      //---------------------------------------------------------------------------------------------------------------------------
;;      // the following for testing only

        data.b  "Loopback Binary UInt8:BI",     0

        data.b  "Loopback SNVT_switch:BI",      0

        data.b  "BI snvtswitch.state",  0

        data.b  "SNVT_switch BI state", 0
        data.b  "SNVT_switch BI generic",       0

;;      //---------------------------------------------------------------------------------------------------------------------------
;;      // Create Binary Outputs

;;      // Since we cannot see these without LCD, we won't show them in BACnet either
        data.b  "LCD switch (BO state)",        0
        data.b  "LCD Switch (BO generic)",      0

;;     // Demo for using bitfield (16-bit SNVT_state). Note that we use the sam Lon Ordinary Variable here as for the Binary_Input demo
;;     // so writing to this over BACnet should change the corresponding BACnet BI Object PV. (A sort of loopback test).
        data.b  "Demo BO bitfield1",    0
        data.b  "Demo BO bitfield7",    0
        data.b  "Demo BO bitfield8",    0
        data.b  "Demo BO bitfield15",   0

;;     //---------------------------------------------------------------------------------------------------------------------------
;;     // The following example if for a Binary Output where the user wants to manipulate the output from the Neuron Application
;;     // via the BacAppAPI. The handle must be saved uniquely for reference for by the API

        data.b  "Controlled Binary Output",     0

;;    //---------------------------------------------------------------------------------------------------------------------------
;;    // the following for testing only - these names match requirements in BTC

        data.b  "Loopback Binary UInt8:BO",     0
        data.b  "Loopback SNVT_switch:BO",      0

        data.b  "SNVT_switch BO state", 0
        data.b  "SNVT_switch BO generic",       0

;;      // These are to test SNVT switch fields (loopback)

;;      // Todo - Create diff return types for Analog and Binary handles to avoid problems...
        data.b  "BO snvtswitch.state",  0

        data.b  "safety (no limit checks yet?)",  0
        data.b  "safety (no limit checks yet?)",  0
        data.b  "safety (no limit checks yet?)",  0
        data.b  "safety (no limit checks yet?)",  0
        data.b  "safety (no limit checks yet?)",  0
        data.b  "safety (no limit checks yet?)",  0
        data.b  "safety (no limit checks yet?)",  0
        data.b  "safety (no limit checks yet?)",  0
        data.b  "safety (no limit checks yet?)",  0
        data.b  "safety (no limit checks yet?)",  0
;;
        data.b  0                       ; end marker

