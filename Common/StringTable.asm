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

;; 	    // First entry is string 0
;;      // Analog Inputs
        data.b  "TempSensor.nvo",     0
        data.b  "LightSensor.nvo",    0
        data.b  "Switch1.nvo.value",  0
        data.b  "Switch2.nvo.value",  0
        data.b  "Lamp1.nvo.value",    0
        data.b  "Lamp2.nvo.value",    0
        data.b  "Joystick.nvo",       0        
        data.b  "LightSensor::nciLowLightAlarm", 0        
        data.b  "TempSensor::nciHighTempAlarm",  0
        data.b  "TempSensor::nciMaxSendTime",    0        
;;      // Analog Outputs       
        data.b  "Switch1.nvi.value",  0
        data.b  "Switch2.nvi.value",  0        
        data.b  "Lamp1.nvi.value",    0
        data.b  "Lamp2.nvi.value",    0           
;;      // Binary Inputs        
        data.b  "Switch1.nvo.state",  0
        data.b  "Switch2.nvo.state",  0                   
        data.b  "Lamp1.nvo.state",    0
        data.b  "Lamp2.nvo.state",    0        
;;      // Binary Outputs       
        data.b  "Switch1.nvi.state",  0
        data.b  "Switch2.nvi.state",  0        
        data.b  "Lamp1.nvi.state",    0
        data.b  "Lamp2.nvi.state",    0
;;
        data.b  0                       ; end marker

