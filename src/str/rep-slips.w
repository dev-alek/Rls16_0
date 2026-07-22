&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------

  File: 

  Description: 

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: 

  Created: 
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parParentproc as handle no-undo .
/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Толкач выгрузки на прайс-чекер".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/sel-date.i }
{ str/getctxtp.i def }
{ gbl/getcntxt.i def }

define variable print-type as character no-undo.
define buffer chk-slip-head for ub.chk-slip-head .
define buffer buf_cash-desk for ub.cash-desk.

define stream out-slip .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-chk-slip-head

/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-print1 v-date v-cash-num v-src ~
v-kind br-chk-slip-head 
&Scoped-Define DISPLAYED-OBJECTS v-date v-cash-num v-src v-kind 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME

function func-src returns character
    (input v-int-type as integer):
    case v-int-type :
        when 1 then 
            return "ФН ККТ" .
        when 2 then 
            return "ТУ" .
        when 3 then 
            return "Касса" .
        when 4 then 
            return "АСУ Заправщик" .
        otherwise 
        return " - " .
    end case .
end function .

function func-kind returns character
    (input v-int-type as integer):
    case v-int-type :
        when 1 then 
            return "Z-отчет" .
        when 2 then 
            return "Отчет ТУ" .
        when 3 then 
            return "Кассовый отчет о незавершенных возвратах" .
        when 4 then 
            return "Финансовый отчет" .
        when 5 then 
            return "Отчет по топливу и платежам" .
        when 6 then 
            return "Отчет по услугам" .
        when 7 then 
            return "Отчет по аннуляциям" .
        when 8 then 
            return "Отчет по сбросам и переливам" .
        when 9 then 
            return "Отчет по товарам" .
        when 10 then 
            return "Сменный отчет АСУ Заправщик" .
        otherwise 
        return " - " .
    end case .
end function .



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cd 
    IMAGE-UP FILE "btn-down-arrow":U
    IMAGE-DOWN FILE "btn-down-arrow":U
    IMAGE-INSENSITIVE FILE "btn-down-arrow":U
    LABEL "Btn 1" 
    SIZE 3 BY 1.

DEFINE BUTTON b-choose-date 
    IMAGE-UP FILE "btn-down-arrow":U
    IMAGE-DOWN FILE "btn-down-arrow":U
    IMAGE-INSENSITIVE FILE "btn-down-arrow":U
    LABEL "b-choose-date" 
    SIZE 3 BY .88.

DEFINE BUTTON b-choose-shift 
    IMAGE-UP FILE "btn-down-arrow":U
    IMAGE-DOWN FILE "btn-down-arrow":U
    IMAGE-INSENSITIVE FILE "btn-down-arrow":U
    LABEL "b-choose-date" 
    SIZE 3 BY .88.

DEFINE BUTTON b-exit AUTO-END-KEY 
    LABEL "Выход" 
    SIZE 15 BY 1.13
    BGCOLOR 8 .

DEFINE BUTTON b-print1 
    LABEL "Сохранить в файл" 
    SIZE 17 BY 1.13
    BGCOLOR 8 .

DEFINE VARIABLE v-kind     AS INTEGER FORMAT ">>9":U INITIAL 0 
    LABEL "Тип" 
    VIEW-AS COMBO-BOX INNER-LINES 6
    LIST-ITEM-PAIRS "Все",0,
    "Z-отчет",1,
    "Отчет ТУ",2,
    "Кассовый отчет о незавершенных возвратах",3,
    "Финансовый отчет",4,
    "Отчет по топливу и платежам",5,
    "Отчет по услугам",6,
    "Отчет по аннуляциям",7,
    "Отчет по сбросам и переливам",8,
    "Отчет по товарам",9,
    "Сменный отчет АСУ Заправщик",10
    DROP-DOWN-LIST
    SIZE 50 BY 1 NO-UNDO.

DEFINE VARIABLE v-src      AS INTEGER FORMAT "->>9":U INITIAL 0 
    LABEL "Источник" 
    VIEW-AS COMBO-BOX INNER-LINES 4
    LIST-ITEM-PAIRS "Все",0,
    "ФН ККТ",1,
    "ТУ",2,
    "Касса",3,
    "АСУ Заправщик",4
    DROP-DOWN-LIST
    SIZE 50 BY 1 NO-UNDO.

DEFINE VARIABLE dateShift  AS DATE    FORMAT "99/99/9999":U 
    LABEL "Смена" 
    VIEW-AS FILL-IN 
    SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE numShift   AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0 
    LABEL "№" 
    VIEW-AS FILL-IN 
    SIZE 3.5 BY 1 NO-UNDO.

DEFINE VARIABLE v-cash-num AS INTEGER FORMAT ">>>9":U INITIAL 0 
    LABEL "Касса" 
    VIEW-AS FILL-IN 
    SIZE 7 BY 1 NO-UNDO.

DEFINE VARIABLE v-date     AS DATE    FORMAT "99/99/9999":U INITIAL today 
    LABEL "Сформирован" 
    VIEW-AS FILL-IN 
    SIZE 12 BY 1 NO-UNDO.

DEFINE MENU MENU-b-print1
    MENU-ITEM m_one         LABEL "Текущий"
    MENU-ITEM m_all         LABEL "Все"  .

DEFINE BUTTON b-help 
    LABEL "Помощь":L 
    SIZE 7 BY 1.
    
/* Browse definitions                                                   */
define query br-chk-slip-head for chk-slip-head scrolling .

define browse br-chk-slip-head
    query br-chk-slip-head display
    chk-slip-head.CashShiftDate format "99/99/9999" COLUMN-LABEL "Дата смены" width 10
    chk-slip-head.CashShiftNum COLUMN-LABEL "№ смены" width 10
    chk-slip-head.slip-dt format "99/99/9999 HH:MM:SS" COLUMN-LABEL "Сформирован" width 20
    chk-slip-head.cash-num COLUMN-LABEL "Касса" width 10
    func-src(chk-slip-head.src_) COLUMN-LABEL "Источник" width 15 format "X(100)"
    func-kind(chk-slip-head.kind) COLUMN-LABEL "Тип" width 35 format "X(100)"
    chk-slip-head.ID COLUMN-LABEL "ID" format "X(100)"
WITH SEPARATORS SIZE 121.5 BY 12 .
  
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
    b-exit AT ROW 1.08 COL 2
    b-print1 AT ROW 1.08 COL 18.75 WIDGET-ID 2
    v-cash-num AT ROW 1.08 COL 48.5 COLON-ALIGNED WIDGET-ID 6
    b-cd AT ROW 1.08 COL 57.75 WIDGET-ID 14
    v-src AT ROW 1.08 COL 71.9 COLON-ALIGNED WIDGET-ID 8
    v-kind AT ROW 2.21 COL 71.9 COLON-ALIGNED WIDGET-ID 12
    b-help AT ROW 1 COL 92.5
    numShift AT ROW 2.25 COL 27.63 COLON-ALIGNED WIDGET-ID 22
    v-date AT ROW 2.25 COL 48.5 COLON-ALIGNED WIDGET-ID 4
    b-choose-date AT ROW 2.25 COL 62.63 WIDGET-ID 16
    dateShift AT ROW 2.29 COL 7.5 COLON-ALIGNED WIDGET-ID 20
    b-choose-shift AT ROW 2.29 COL 22.63 WIDGET-ID 18
    br-chk-slip-head AT ROW 3.46 COL 2
    SPACE(0.75) SKIP(0.41)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
    SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
    TITLE "Отчеты кассового оборудования, ККТ, ТУ"
    CANCEL-BUTTON b-exit WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-chk-slip-head b-choose-shift Dialog-Frame */
ASSIGN 
    FRAME Dialog-Frame:SCROLLABLE = FALSE
    FRAME Dialog-Frame:HIDDEN     = TRUE.

ASSIGN 
    br-chk-slip-head:COLUMN-RESIZABLE IN FRAME Dialog-Frame = TRUE.
       
       /* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

ASSIGN
    b-print1:POPUP-MENU IN FRAME Dialog-Frame = MENU MENU-b-print1:HANDLE. 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Отчеты кассового оборудования, ККТ, ТУ */
    DO:
        APPLY "END-ERROR":U TO SELF.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cd Dialog-Frame
ON CHOOSE OF b-cd IN FRAME Dialog-Frame /* Btn 1 */
    DO:
        define variable ri-list as character no-undo .
  
        run ref/cashlist.w
            (input  parparentproc
            ,input  'b-sel':U
            ,input  {&g___object}
            ,v-cntxt-db-num
            ,v-cntxt-host-code-obj
            ,v-cntxt-obj-type
            ,v-cntxt-obj-code
            ,input  ?
            ,output ri-list
            ) no-error.
        if ri-list = '' then 
        do:
            return no-apply .
        end.
        FIND FIRST buf_cash-desk No-LOCK WHERE
            recid(buf_cash-desk) = integer(ri-list) no-error.
        if not available buf_cash-desk then 
        do:
            return no-apply .
        end.
        v-cash-num = buf_cash-desk.cash-num .
        display v-cash-num WITH FRAME Dialog-Frame.
        run reopen-query .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    
&Scoped-define SELF-NAME v-cash-num
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-cash-num Dialog-Frame
ON value-changed OF v-cash-num IN FRAME Dialog-Frame
    DO:
        assign v-cash-num .
        if v-cash-num > 0
            then 
        do :
            FIND FIRST buf_cash-desk No-LOCK where buf_cash-desk.db-num = v-cntxt-db-num
                and buf_cash-desk.obj-code = v-cntxt-obj-code
                and buf_cash-desk.cash-num = v-cash-num
                no-error .
            if not available buf_cash-desk
                then 
            do :
                message "Не найдена касса с кодом " v-cash-num view-as alert-box .
                return no-apply .
            end .                                   
        end .
        run reopen-query .
    END.

on del of v-cash-num in frame Dialog-Frame
    do :
        v-cash-num = ? .
        v-cash-num:screen-value = "?" .
        run reopen-query .
    end .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

on delete-character of dateShift in frame Dialog-Frame
    do:
        dateShift = ? .
        dateShift:screen-value = string(dateShift,"99/99/9999")  .
        run reopen-query .
    end.

on del of dateShift in frame Dialog-Frame
    do :
        dateShift = ? .
        dateShift:screen-value = string(dateShift,"99/99/9999")  .
        run reopen-query .
    end .

on ctrl-d of dateShift in frame Dialog-Frame
    do:
        define variable v-curr-sv-date as date no-undo .

        if (can-query (self, "sensitive")
            and
            self :sensitive = true
            )
            or (can-query (self, "read-only")
            and
            self :read-only = false
            )
            then 
        do:
            if self :handle <> focus :handle
                then 
            do:
                apply "entry":u to self .
            end.

            run gbl/getcurdt.p
                (output v-curr-sv-date
                ) .
            assign
                self :screen-value = string(v-curr-sv-date) .
            .
        end.
        return no-apply.
    end.

on del of numShift in frame Dialog-Frame
    do :
        numShift = 0 .
        numShift:screen-value = "0" .
        run reopen-query .
    end .

&Scoped-define SELF-NAME v-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-date Dialog-Frame
ON leave OF v-date IN FRAME Dialog-Frame
    DO:
        assign v-date .
        run reopen-query .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-choose-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-choose-date Dialog-Frame
ON CHOOSE OF b-choose-date IN FRAME Dialog-Frame /* b-choose-date */
    DO:
        run sel-date in this-procedure
            (input v-date :handle
            ,input ""
            ) .
        apply "leave" to v-date IN FRAME Dialog-Frame .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME v-src
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-src Dialog-Frame
ON value-changed OF v-src IN FRAME Dialog-Frame
    DO:
        define variable Kind_ as character no-undo .
        assign v-src .
        case v-src:
            when 0 then 
                do:
                    Kind_ = "Все" + {&comma-char} + '0':U + {&comma-char} + 
                        "Z-отчет" + {&comma-char} + '1':U + {&comma-char} + 
                        "Отчет ТУ" + {&comma-char} + '2':U + {&comma-char} + 
                        /*              "Кассовый отчет о незавершенных возвратах" + {&comma-char} + '3':U + {&comma-char} +*/
                        "Финансовый отчет" + {&comma-char} + '4':U + {&comma-char} + 
                        "Отчет по топливу и платежам" + {&comma-char} + '5':U + {&comma-char} + 
                        "Отчет по услугам" + {&comma-char} + '6':U + {&comma-char} + 
                        "Отчет по аннуляциям" + {&comma-char} + '7':U + {&comma-char} + 
                        "Отчет по сбросам и переливам" + {&comma-char} + '8':U + {&comma-char} + 
                        "Отчет по товароам" + {&comma-char} + '9':U + {&comma-char} + 
                        "Сменный отчет АСУ Заправщик" + {&comma-char} + '10':U .          
                end.
            when 1 then 
                do:
                    Kind_ = "Z-отчет" + {&comma-char} + '1':U .             
                end.
            when 2 then 
                do:
                    Kind_ = "Отчет ТУ" + {&comma-char} + '2':U .             
                end.
            when 3 then 
                do:
                    Kind_ = "Финансовый отчет" + {&comma-char} + '4':U + {&comma-char} + 
                        "Отчет по топливу и платежам" + {&comma-char} + '5':U + {&comma-char} + 
                        "Отчет по услугам" + {&comma-char} + '6':U + {&comma-char} + 
                        "Отчет по аннуляциям" + {&comma-char} + '7':U + {&comma-char} + 
                        "Отчет по сбросам и переливам" + {&comma-char} + '8':U + {&comma-char} + 
                        "Отчет по товароам" + {&comma-char} + '9':U .             
                end.
            when 4 then 
                do:
                    Kind_ = "Сменный отчет АСУ Заправщик" + {&comma-char} + '10':U .             
                end.
        end case .    


        ASSIGN
            v-kind:LIST-ITEM-PAIRS  in frame {&frame-name} = Kind_ .
        run reopen-query .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME v-kind
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-kind Dialog-Frame
ON value-changed OF v-kind IN FRAME Dialog-Frame
    DO:
        assign v-kind .
        run reopen-query .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-print1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print1 Dialog-Frame
ON CHOOSE OF b-print1 IN FRAME Dialog-Frame /* Сохранить в файл */
    DO:
        if not available chk-slip-head
            then 
        do :
            return no-apply .
        end .
        if print-type = "" then 
        do:
            run gbl/pop-up.p ( input b-print1:handle, input no) no-error.
            if error-status:error then return no-apply.
        end.
        if print-type = "" then return no-apply.
        if print-type = "one"
            then 
        do :
            run str/chk-slip-print.p (input chk-slip-head.db-num,
                input chk-slip-head.ID,
                input chk-slip-head.CheckID,
                input chk-slip-head.RRN,
                input print-type)
                .
        end .
        else 
        do :
            run print-rep .
        end .                            
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-chk-slip-head
&Scoped-define SELF-NAME br-chk-slip-head
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-chk-slip-head Dialog-Frame
ON RETURN OF br-chk-slip-head IN FRAME Dialog-Frame
    OR mouse-select-dblclick of br-chk-slip-head in frame Dialog-Frame
    do:
        if not available chk-slip-head
            then 
        do :
            return no-apply .
        end .
        run str/chk-slip.w (input chk-slip-head.db-num,
            input chk-slip-head.ID,
            input chk-slip-head.CheckID,
            input chk-slip-head.RRN)
            .
    end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME dateShift
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL dateShift Dialog-Frame
ON leave OF dateShift IN FRAME Dialog-Frame /* Смена */
    DO:
        assign dateShift .
        run reopen-query .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_all Dialog-Frame
ON CHOOSE OF MENU-ITEM m_all /* Все */
    DO:
        print-type = "reports":U.
        apply "choose" to b-print1 in frame {&frame-name}.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_one
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_one Dialog-Frame
ON CHOOSE OF MENU-ITEM m_one /* Текущий */
    DO:
        print-type = "one":U.
        apply "choose" to b-print1 in frame {&frame-name}.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-choose-shift
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-choose-shift Dialog-Frame
ON CHOOSE OF b-choose-shift IN FRAME Dialog-Frame /* b-choose-date */
    DO:
        run sel-date in this-procedure
            (input dateShift :handle
            ,input ""
            ) .
        apply "leave" to dateShift IN FRAME Dialog-Frame .
    /*    define variable rec-list-2 as char no-undo.                                              */
    /*    run str/sht-all.w                                                                        */
    /*        (input parParentproc                                                                 */
    /*        ,input v-cntxt-obj-type /*p-curr-obj-type*/                                          */
    /*        ,input v-cntxt-obj-code /*p-curr-obj-code*/                                          */
    /*        ,input  "b-sel"                                                                      */
    /*        ,input "obj":U                                                                       */
    /*        ,input v-cntxt-obj-type   /*p-obj-type*/                                             */
    /*        ,input v-cntxt-obj-code   /*p-obj-code*/                                             */
    /*        ,input "rep/e-shift.w":U                                                             */
    /*        ,input-output rec-list-2 ).                                                          */
    /*                                                                                             */
    /*    find shift-obj where recid (shift-obj) = integer (entry(1,rec-list-2))  no-lock no-error.*/
    /*    if AVAILABLE  shift-obj then                                                             */
    /*    DO:                                                                                      */
    /*        Assign                                                                               */
    /*            dateShift = shift-obj.shift-date                                                 */
    /*            numShift  = shift-obj.shift-num.                                                 */
    /*                                                                                             */
    /*        enable dateShift  numShift with frame {&frame-name}.                                 */
    /*        Display dateShift  numShift with frame {&frame-name}.                                */
    /*                                                                                             */
    /*     end.                                                                                    */
    /*run reopen-query .*/
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME numShift
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL numShift Dialog-Frame
ON leave OF numShift IN FRAME Dialog-Frame /* № */
    DO:
        assign numShift .
        run reopen-query .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
    THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ gbl/ed_date.i v-date }
{ gbl/ed_date.i dateShift }
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    b-print1:MENU-MOUSE = 1 .
    { gbl/getcntxt.i get }
    { str/getctxtp.i get }

    RUN enable_UI.
  
    open query br-chk-slip-head for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
        and date(chk-slip-head.slip-dt) = v-date
        and chk-slip-head.is-report = 1 .
                                                               
    WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

procedure reopen-query :
  if v-cash-num = ?
  or v-cash-num = 0
  then do :
    if v-src = 0
    then do :
      if v-kind = 0
      then do :
        open query br-chk-slip-head
        for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                         and date(chk-slip-head.slip-dt) = v-date
                                         and chk-slip-head.is-report = 1
        .
      end .
      else do :
        open query br-chk-slip-head
        for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                         and date(chk-slip-head.slip-dt) = v-date
                                         and chk-slip-head.is-report = 1
                                         and chk-slip-head.kind = v-kind
        .
      end .
    end .
    else do :
      if v-kind = 0
      then do :
        open query br-chk-slip-head
        for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                         and date(chk-slip-head.slip-dt) = v-date
                                         and chk-slip-head.is-report = 1
                                         and chk-slip-head.src_ = v-src
        .
      end .
      else do :
        open query br-chk-slip-head
        for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                         and date(chk-slip-head.slip-dt) = v-date
                                         and chk-slip-head.is-report = 1
                                         and chk-slip-head.kind = v-kind
                                         and chk-slip-head.src_ = v-src
        .
      end .
    end .
  end .
  else do :
    if v-src = 0
    then do :
      if v-kind = 0
      then do :
        open query br-chk-slip-head
        for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                         and date(chk-slip-head.slip-dt) = v-date
                                         and chk-slip-head.is-report = 1
                                         and chk-slip-head.cash-num = v-cash-num
        .
      end .
      else do :
        open query br-chk-slip-head
        for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                         and date(chk-slip-head.slip-dt) = v-date
                                         and chk-slip-head.is-report = 1
                                         and chk-slip-head.cash-num = v-cash-num
                                         and chk-slip-head.kind = v-kind
        .
      end .
    end .
    else do :
      if v-kind = 0
      then do :
        open query br-chk-slip-head
        for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                         and date(chk-slip-head.slip-dt) = v-date
                                         and chk-slip-head.is-report = 1
                                         and chk-slip-head.cash-num = v-cash-num
                                         and chk-slip-head.src_ = v-src
        .
      end .
      else do :
        open query br-chk-slip-head
        for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                         and date(chk-slip-head.slip-dt) = v-date
                                         and chk-slip-head.is-report = 1
                                         and chk-slip-head.cash-num = v-cash-num
                                         and chk-slip-head.kind = v-kind
                                         and chk-slip-head.src_ = v-src
        .
      end .
    end .
  end .
    if v-date <> ? then 
    do:
        if v-cash-num = ?
            or v-cash-num = 0
            then 
        do :
            if v-src = 0
                then 
            do :
                if v-kind = 0
                    then 
                do :
                    if dateShift = ? then 
                    do:
                        if numShift = 0 then 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                .
                        end. /* if numShift = 0 then do: */
                        else 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftNum = numShift
                                .
                        end.
                    end. /* if dateShift = ? then do: */
                    else 
                    do:
                        if numShift = 0 then 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftDate = dateShift
                                .
                        end. /* if numShift = 0 then do: */
                        else 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.CashShiftNum = numShift
                                .
                        end.            
                    end.  
                end . /*if v-kind = 0*/
                else 
                do :
                    if dateShift = ? then 
                    do:
                        if numShift = 0 then 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.is-report = 1
                                .
                        end. /* if numShift = 0 then do: */
                        else 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftNum = numShift
                                .
                        end.
                    end. /* if dateShift = ? then do: */
                    else 
                    do:
                        if numShift = 0 then 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftDate = dateShift
                                .
                        end. /* if numShift = 0 then do: */
                        else 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.CashShiftNum = numShift
                                .
                        end.            
                    end.            
                end .
            end . /* if v-src = 0 */
            else 
            do :
                if v-kind = 0
                    then 
                do :
                    if dateShift = ? then 
                    do:
                        if numShift = 0 then 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.src_ = v-src
                                .
                        end. /* if numShift = 0 then do: */
                        else 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.src_ = v-src
                                .
                        end.
                    end. /* if dateShift = ? then do: */
                    else 
                    do:
                        if numShift = 0 then 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.src_ = v-src
                                .
                        end. /* if numShift = 0 then do: */
                        else 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.src_ = v-src
                                .
                        end.            
                    end.  
                end . /*if v-kind = 0*/
                else 
                do :
                    if dateShift = ? then 
                    do:
                        if numShift = 0 then 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.src_ = v-src
                                .
                        end. /* if numShift = 0 then do: */
                        else 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.src_ = v-src
                                .
                        end.
                    end. /* if dateShift = ? then do: */
                    else 
                    do:
                        if numShift = 0 then 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.src_ = v-src
                                .
                        end. /* if numShift = 0 then do: */
                        else 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.src_ = v-src
                                .
                        end.            
                    end.            
                end .
            end .
        end . /* if v-cash-num = ?
  or v-cash-num = 0 */
        else 
        do :
            if v-src = 0
                then 
            do :
                if v-kind = 0
                    then 
                do :
                    if dateShift = ? then 
                    do:
                        if numShift = 0 then 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end. /* if numShift = 0 then do: */
                        else 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.
                    end. /* if dateShift = ? then do: */
                    else 
                    do:
                        if numShift = 0 then 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end. /* if numShift = 0 then do: */
                        else 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.            
                    end.  
                end . /*if v-kind = 0*/
                else 
                do :
                    if dateShift = ? then 
                    do:
                        if numShift = 0 then 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end. /* if numShift = 0 then do: */
                        else 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.
                    end. /* if dateShift = ? then do: */
                    else 
                    do:
                        if numShift = 0 then 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end. /* if numShift = 0 then do: */
                        else 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.            
                    end.            
                end .
            end . /* if v-src = 0 */
            else 
            do :
                if v-kind = 0
                    then 
                do :
                    if dateShift = ? then 
                    do:
                        if numShift = 0 then 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.src_ = v-src
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end. /* if numShift = 0 then do: */
                        else 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.src_ = v-src
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.
                    end. /* if dateShift = ? then do: */
                    else 
                    do:
                        if numShift = 0 then 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.src_ = v-src
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end. /* if numShift = 0 then do: */
                        else 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.src_ = v-src
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.            
                    end.  
                end . /*if v-kind = 0*/
                else 
                do :
                    if dateShift = ? then 
                    do:
                        if numShift = 0 then 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.src_ = v-src
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end. /* if numShift = 0 then do: */
                        else 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.src_ = v-src
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.
                    end. /* if dateShift = ? then do: */
                    else 
                    do:
                        if numShift = 0 then 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.src_ = v-src
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end. /* if numShift = 0 then do: */
                        else 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and date(chk-slip-head.slip-dt) = v-date
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.src_ = v-src
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.            
                    end.            
                end .
            end .
        end .
    end. /* if v-date <> ? then do: */
    else 
    do:
        if v-cash-num = ?
            or v-cash-num = 0
            then 
        do :
            if v-src = 0
                then 
            do :
                if v-kind = 0
                    then 
                do :
                    if dateShift = ? then 
                    do:
                        if numShift = 0 then 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                .
                        end. /* if numShift = 0 then do: */
                        else 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftNum = numShift
                                .
                        end.
                    end. /* if dateShift = ? then do: */
                    else 
                    do:
                        if numShift = 0 then 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftDate = dateShift
                                .
                        end. /* if numShift = 0 then do: */
                        else 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.CashShiftNum = numShift
                                .
                        end.            
                    end.  
                end . /*if v-kind = 0*/
                else 
                do :
                    if dateShift = ? then 
                    do:
                        if numShift = 0 then 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.is-report = 1
                                .
                        end. /* if numShift = 0 then do: */
                        else 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftNum = numShift
                                .
                        end.
                    end. /* if dateShift = ? then do: */
                    else 
                    do:
                        if numShift = 0 then 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftDate = dateShift
                                .
                        end. /* if numShift = 0 then do: */
                        else 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.CashShiftNum = numShift
                                .
                        end.            
                    end.            
                end .
            end . /* if v-src = 0 */
            else 
            do :
                if v-kind = 0
                    then 
                do :
                    if dateShift = ? then 
                    do:
                        if numShift = 0 then 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.src_ = v-src
                                .
                        end. /* if numShift = 0 then do: */
                        else 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.src_ = v-src
                                .
                        end.
                    end. /* if dateShift = ? then do: */
                    else 
                    do:
                        if numShift = 0 then 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.src_ = v-src
                                .
                        end. /* if numShift = 0 then do: */
                        else 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.src_ = v-src
                                .
                        end.            
                    end.  
                end . /*if v-kind = 0*/
                else 
                do :
                    if dateShift = ? then 
                    do:
                        if numShift = 0 then 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.src_ = v-src
                                .
                        end. /* if numShift = 0 then do: */
                        else 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.src_ = v-src
                                .
                        end.
                    end. /* if dateShift = ? then do: */
                    else 
                    do:
                        if numShift = 0 then 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.src_ = v-src
                                .
                        end. /* if numShift = 0 then do: */
                        else 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.src_ = v-src
                                .
                        end.            
                    end.            
                end .
            end .
        end . /* if v-cash-num = ?
  or v-cash-num = 0 */
        else 
        do :
            if v-src = 0
                then 
            do :
                if v-kind = 0
                    then 
                do :
                    if dateShift = ? then 
                    do:
                        if numShift = 0 then 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end. /* if numShift = 0 then do: */
                        else 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.
                    end. /* if dateShift = ? then do: */
                    else 
                    do:
                        if numShift = 0 then 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end. /* if numShift = 0 then do: */
                        else 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.            
                    end.  
                end . /*if v-kind = 0*/
                else 
                do :
                    if dateShift = ? then 
                    do:
                        if numShift = 0 then 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end. /* if numShift = 0 then do: */
                        else 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.
                    end. /* if dateShift = ? then do: */
                    else 
                    do:
                        if numShift = 0 then 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end. /* if numShift = 0 then do: */
                        else 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.            
                    end.            
                end .
            end . /* if v-src = 0 */
            else 
            do :
                if v-kind = 0
                    then 
                do :
                    if dateShift = ? then 
                    do:
                        if numShift = 0 then 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.src_ = v-src
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end. /* if numShift = 0 then do: */
                        else 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.src_ = v-src
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.
                    end. /* if dateShift = ? then do: */
                    else 
                    do:
                        if numShift = 0 then 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.src_ = v-src
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end. /* if numShift = 0 then do: */
                        else 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.src_ = v-src
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.            
                    end.  
                end . /*if v-kind = 0*/
                else 
                do :
                    if dateShift = ? then 
                    do:
                        if numShift = 0 then 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.src_ = v-src
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end. /* if numShift = 0 then do: */
                        else 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.src_ = v-src
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.
                    end. /* if dateShift = ? then do: */
                    else 
                    do:
                        if numShift = 0 then 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.src_ = v-src
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end. /* if numShift = 0 then do: */
                        else 
                        do:
                            open query br-chk-slip-head
                                for each chk-slip-head no-lock where chk-slip-head.obj-code = v-cntxt-obj-code
                                and chk-slip-head.is-report = 1
                                and chk-slip-head.kind = v-kind
                                and chk-slip-head.CashShiftDate = dateShift
                                and chk-slip-head.CashShiftNum = numShift
                                and chk-slip-head.src_ = v-src
                                and chk-slip-head.cash-num = v-cash-num
                                .
                        end.            
                    end.            
                end .
            end .
        end .
    end. /* if v-date <> ? then do: */
end procedure .

procedure print-rep :
  define buffer chk-slip-string for ub.chk-slip-string .

  define variable v-file-name as character no-undo.
  define variable vok as logical no-undo.
  define variable ii as integer no-undo .
  define variable v-slip-txt as character no-undo .
  define variable v-slip-txt-list as character no-undo .
  define variable cmd as character no-undo .
  
  SYSTEM-DIALOG GET-FILE v-file-name
      TITLE "Сохранить как"
      FILTERS
        " Файл PDF(*.pdf) " "*.pdf",
        " Все файлы (*.*) " "*.*"
      ask-overwrite
      save-as
      use-filename
      update vok
      default-extension "pdf"
      .
  if not vok THEN do:
    return .
  end.
  v-slip-txt-list = "" .
  get first br-chk-slip-head .
  v-slip-txt = "slip_" + string(time) .
  output stream out-slip to value(v-slip-txt)  .
  repeat while available chk-slip-head:

      for each chk-slip-string no-lock where chk-slip-string.db-num = chk-slip-head.db-num
                                         and chk-slip-string.ID = chk-slip-head.ID
                                         and chk-slip-string.CheckID = chk-slip-head.CheckId
                                         and chk-slip-string.RRN = chk-slip-head.RRN
                                         and chk-slip-string.str-num < 10000
                                         by chk-slip-string.str-num
                                         :
        put stream out-slip unformatted chk-slip-string.str-value skip .
      end .   
    get next br-chk-slip-head .
  end .
  output stream out-slip close . 

  define variable v-extprog-retval as character no-undo .
      run gbl/extprog.p
        (input  {&extprog_exec}                    /* p-action    */
        ,input  {&extprog_txt2pdf}                 /* p-prog-name */
        ,input  v-slip-txt                    /* p-param1    */
        ,input  v-file-name                        /* p-param2    */
        ,input  ""                                 /* p-param3    */
        ,output v-extprog-retval                   /* p-ret-value */
        ) .    
    /*  cmd = substitute('&1 -n="&2" -o="&3"', search("exe/slip2pdf.exe"), v-slip-txt-list, v-file-name) .*/
    /*                                                                                                    */
    /*  os-command silent value(cmd) .                                                                    */
  
    do ii = 1 to num-entries(v-slip-txt-list) :
        v-slip-txt = entry(ii, v-slip-txt-list) .
        os-delete value(v-slip-txt) no-error .
    end .
end procedure .

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame  _DEFAULT-DISABLE
PROCEDURE disable_UI :
    /*------------------------------------------------------------------------------
      Purpose:     DISABLE the User Interface
      Parameters:  <none>
      Notes:       Here we clean-up the user-interface by deleting
                   dynamic widgets we have created and/or hide 
                   frames.  This procedure is usually called when
                   we are ready to "clean-up" after running.
    ------------------------------------------------------------------------------*/
    /* Hide all frames. */
    HIDE FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame  _DEFAULT-ENABLE
PROCEDURE enable_UI :
    /*------------------------------------------------------------------------------
      Purpose:     ENABLE the User Interface
      Parameters:  <none>
      Notes:       Here we display/view/enable the widgets in the
                   user-interface.  In addition, OPEN all queries
                   associated with each FRAME and BROWSE.
                   These statements here are based on the "Other 
                   Settings" section of the widget Property Sheets.
    ------------------------------------------------------------------------------*/
    DISPLAY v-cash-num v-src v-kind numShift v-date dateShift 
        WITH FRAME Dialog-Frame.
    ENABLE b-exit b-print1 v-cash-num b-cd v-src v-kind numShift v-date 
        b-choose-date dateShift b-choose-shift br-chk-slip-head
        WITH FRAME Dialog-Frame.
    VIEW FRAME Dialog-Frame.
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

