&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------


$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Импорт контрактов

Автор: Шкляр Елена 
Дата создания: 01/16/07
Author: Elena Shklyar
Creation date: 01/16/07

          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .

/* Local Variable Definitions ---                                       */

define variable l-error         as logical   no-undo. /* Есть ли ошибки */
define variable v-user-action   as character no-undo.
define variable v-printed       as logical   no-undo.
define variable v-proc-name-err as character no-undo initial 'impcontract.err'. /* Имя лога */
define variable v-proc-name-alc as character no-undo initial 'imp-contr.txt'. /* Имя лога */  
define variable browse-br-marks as handle    no-undo.
define variable bcol            as handle    no-undo.
define variable bcol1           as handle    no-undo.
define variable bcol2           as handle    no-undo.
define variable bcol3           as handle    no-undo.
define variable bcol4           as handle    no-undo.
define variable bcol5           as handle    no-undo.
define variable v-mode          as character no-undo. 

DEFINE buffer buf_clients for ub.clients .
define buffer b_contract  for ub.contract.
define buffer b_contract-attr for ub.contract-attr .
define stream str-err .
define stream str-contract .
  
define TEMP-TABLE tt-contract no-undo    
    field doc-type          as character                    
    field cli-type          as character                    
    field cli-code          as integer    
    field contract-prn-code as character           
    field contract-type     as character               
    field contract-date     as DATE                    
    field contract-date-beg as date                
    field contract-date-end as date                
    field host-code         as integer
    field edi               as logical    
    field contract-code     as integer
    field cli-name          as character
    field user-name         as character
    field user-db-num       as integer
    field log-error         as LOGICAL   INIT no                
    index host-code contract-date contract-prn-code.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Импорт контрактов".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ gbl/color.i }
{ trg/new-bcod.i }


{ cmp/library.i  }

{ gbl/thbjattr.i}
{ str/cont-ms.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-contract

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-contract

/* Definitions for BROWSE br-contract                                   */
&Scoped-define FIELDS-IN-QUERY-br-contract tt-contract.doc-type tt-contract.cli-type tt-contract.cli-code tt-contract.contract-prn-code tt-contract.contract-type tt-contract.contract-date tt-contract.contract-date-beg tt-contract.contract-date-end tt-contract.host-code tt-contract.edi  
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-contract   
&Scoped-define SELF-NAME br-contract
&Scoped-define QUERY-STRING-br-contract FOR EACH tt-contract NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-contract OPEN QUERY {&SELF-NAME} FOR EACH tt-contract NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-contract tt-contract
&Scoped-define FIRST-TABLE-IN-QUERY-br-contract tt-contract


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-contract}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_OK Btn_EXIT Btn_Cancel Btn_del ~
Btn_change Btn_imp br-contract 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_Cancel AUTO-END-KEY 
    LABEL "Отмена" 
    SIZE 10 BY 1
    BGCOLOR 8 .

DEFINE BUTTON Btn_change 
    LABEL "Изменить" 
    SIZE 10 BY 1
    BGCOLOR 8 .

DEFINE BUTTON Btn_del 
    LABEL "Удалить" 
    SIZE 10 BY 1
    BGCOLOR 8 .

DEFINE BUTTON Btn_EXIT AUTO-GO 
    LABEL "Сохранить" 
    SIZE 10 BY 1
    BGCOLOR 8 .

DEFINE BUTTON Btn_imp 
    LABEL "Импорт" 
    SIZE 10 BY 1
    BGCOLOR 8 .

DEFINE BUTTON Btn_OK AUTO-GO 
    LABEL "Ввод" 
    SIZE 10 BY 1
    BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-contract FOR 
    tt-contract SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-contract
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-contract Dialog-Frame _FREEFORM
    QUERY br-contract NO-LOCK DISPLAY
    tt-contract.doc-type FORMAT "X(4)":U WIDTH 10         LABEL "Тип"
    tt-contract.cli-type FORMAT "X(3)":U WIDTH 10         LABEL "Объект"
    tt-contract.cli-code FORMAT ">>>>>>>>>>>9":U          LABEL "Код"
    tt-contract.contract-prn-code FORMAT "X(16)":U        LABEL "Номер"
    tt-contract.contract-type FORMAT "X(50)":U            LABEL "Тип договора"
    tt-contract.contract-date FORMAT "99/99/9999":U       LABEL "Дата"
    tt-contract.contract-date-beg FORMAT "99/99/9999":U   LABEL "Начало"
    tt-contract.contract-date-end FORMAT "99/99/9999":U   LABEL "Конец"
    tt-contract.host-code FORMAT "9999999999":U WIDTH 13.63    LABEL "Фирма"
    (if tt-contract.edi then "+":U else "-":U) format "X(1)":U LABEL "Поставки через ЭДО"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 95.5 BY 15.5 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
    Btn_OK AT ROW 1.25 COL 2
    Btn_EXIT AT ROW 1.25 COL 2
    Btn_Cancel AT ROW 1.25 COL 12
    Btn_del AT ROW 1.25 COL 22
    Btn_change AT ROW 1.25 COL 22 WIDGET-ID 2
    Btn_imp AT ROW 1.25 COL 22
    br-contract AT ROW 2.5 COL 1.5 WIDGET-ID 200
    SPACE(0.62) SKIP(0.03)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
    SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
    TITLE "Импорт договоров"
    DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel WIDGET-ID 100.


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
/* BROWSE-TAB br-contract Btn_imp Dialog-Frame */
ASSIGN 
    FRAME Dialog-Frame:SCROLLABLE = FALSE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-contract
/* Query rebuild information for BROWSE br-contract
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-contract NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-contract */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Импорт договоров */
    DO:
        APPLY "END-ERROR":U TO SELF.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-contract
&Scoped-define SELF-NAME br-contract
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-contract Dialog-Frame
ON ROW-DISPLAY OF br-contract IN FRAME Dialog-Frame
    DO:
   
     
        if tt-contract.contract-type = ""  then 
        do:
            tt-contract.contract-type:BGCOLOR in browse br-contract = red_COLOR.
        end.
        if tt-contract.contract-prn-code = "" then 
        do:
            tt-contract.contract-prn-code:BGCOLOR in browse br-contract = red_COLOR.
        end.
        if tt-contract.cli-code = 0 then 
        do:
            tt-contract.cli-code:BGCOLOR in browse br-contract = red_COLOR.
        end.    
        if tt-contract.cli-type = "" then 
        do:
            tt-contract.cli-type:BGCOLOR in browse br-contract = red_COLOR.
        end.    
        if tt-contract.doc-type = "" then 
        do:
            tt-contract.doc-type:BGCOLOR in browse br-contract = red_COLOR.
        end.    
        
        find first clients no-lock where clients.obj-type = tt-contract.cli-type
                                     and clients.obj-code = tt-contract.cli-code
                                     no-error.
        if not available clients
        then do :
          tt-contract.cli-code:BGCOLOR in browse br-contract = red_COLOR.
          tt-contract.cli-type:BGCOLOR in browse br-contract = red_COLOR.
        end.     
        
        find first firm no-lock where firm.firm-code = tt-contract.host-code no-error .
        if not available firm
        then do :
          tt-contract.host-code:BGCOLOR in browse br-contract = red_COLOR.
        end.                        

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_change
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_change Dialog-Frame
ON CHOOSE OF Btn_change IN FRAME Dialog-Frame /* Изменить */
    DO:
        define buffer buf_tt-contract for tt-contract .
        define VARIABLE v-doc-type          as character no-undo .
        define VARIABLE v-cli-type          as character no-undo .
        DEFINE VARIABLE v-cli-code          as integer   no-undo .
        DEFINE VARIABLE v-contract-prn-code as character no-undo .
        DEFINE VARIABLE v-contract-type     as character no-undo .
        DEFINE VARIABLE v-contract-date     as date      no-undo .
        DEFINE VARIABLE v-contract-date-beg as date      no-undo .
        DEFINE VARIABLE v-contract-date-end as date      no-undo .
        DEFINE VARIABLE v-host-code         as integer   no-undo .

        assign
            v-doc-type          = tt-contract.doc-type
            v-cli-type          = tt-contract.cli-type
            v-cli-code          = tt-contract.cli-code
            v-contract-prn-code = tt-contract.contract-prn-code
            v-contract-type     = tt-contract.contract-type
            v-contract-date     = tt-contract.contract-date
            v-contract-date-beg = tt-contract.contract-date-beg
            v-contract-date-end = tt-contract.contract-date-end
            v-host-code         = tt-contract.host-code     
            .     
        run bge/edit_contract.w (
            input-output v-doc-type,
            input-output v-cli-type,
            input-output v-cli-code,
            input-output v-contract-prn-code,
            input-output v-contract-type,
            input-output v-contract-date,
            input-output v-contract-date-beg,
            input-output v-contract-date-end,
            input-output v-host-code
            ) no-error .                                                                        

        find first buf_tt-contract where buf_tt-contract.contract-prn-code = tt-contract.contract-prn-code no-error .
        if not AVAILABLE buf_tt-contract then 
        do:
            create buf_tt-contract .
            tt-contract.contract-prn-code = v-contract-prn-code .
        end.    
        
        assign
            tt-contract.doc-type          = v-doc-type
            tt-contract.cli-type          = v-cli-type
            tt-contract.cli-code          = v-cli-code
            tt-contract.contract-type     = v-contract-type
            tt-contract.contract-date     = v-contract-date
            tt-contract.contract-date-beg = v-contract-date-beg
            tt-contract.contract-date-end = v-contract-date-end
            tt-contract.host-code         = v-host-code
            .     

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_del Dialog-Frame
ON CHOOSE OF Btn_del IN FRAME Dialog-Frame /* Удалить */
    DO:
    /*удалить*/
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_EXIT
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_EXIT Dialog-Frame
ON CHOOSE OF Btn_EXIT IN FRAME Dialog-Frame /* Сохранить */
    DO:
        run create-proc in this-procedure no-error .
        if return-value = "cancel" then return no-apply .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_imp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_imp Dialog-Frame
ON choose OF Btn_imp IN FRAME Dialog-Frame /* Импорт */
    DO:
        run proc-choose-file no-error .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
    THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    RUN enable_UI.
    WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

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
    ENABLE Btn_OK Btn_EXIT Btn_Cancel Btn_imp br-contract 
        WITH FRAME Dialog-Frame.
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-choose-file Dialog-Frame 
PROCEDURE proc-choose-file :
    /*------------------------------------------------------------------------------
          Purpose:     
          Parameters:  <none>
          Notes:       
        ------------------------------------------------------------------------------*/
    /* Выбор файла */

    if search (v-proc-name-err) <> ? then 
    do:
        os-delete value(v-proc-name-err).
    end.
    if search (v-proc-name-alc) <> ? then 
    do:
        os-delete value(v-proc-name-alc).
    end.
    DEFINE VARIABLE vCh AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vLg AS LOGICAL   NO-UNDO.
    def    var      ii  as int.
    SYSTEM-DIALOG GET-FILE vCh
        MUST-EXIST
        TITLE "Выбор файла"
        USE-FILENAME UPDATE vLg.
    IF vCh <> "" THEN
    DO:

        output stream str-err to value(v-proc-name-err)   .
        INPUT FROM value(vCh). 
        
        REPEAT: 
            create tt-contract .
            import DELIMITER ";" tt-contract no-error.
 
            tt-contract.doc-type = trim(tt-contract.doc-type) .
            if tt-contract.doc-type <> {&income} and tt-contract.doc-type <> {&expense} and tt-contract.doc-type <> "" then 
            do:
                put stream str-err unformatted
                    "Не существующий тип документа" + " " + tt-contract.doc-type + "."
                    skip .
                tt-contract.log-error = yes .
                tt-contract.doc-type = "" .

            end.
            tt-contract.cli-type = trim(tt-contract.cli-type) .
            if tt-contract.cli-type <> {&prs} and tt-contract.cli-type <> {&cmp} and tt-contract.cli-type <> "" then 
            do:
                put stream str-err unformatted
                    "Не существующий тип поставщика" + " " + tt-contract.cli-type + "."
                    skip .
                tt-contract.log-error = yes .
                tt-contract.cli-type = "" .
            end.
            if tt-contract.cli-code <> 0 then 
            do:
                find first buf_clients no-lock where buf_clients.obj-code = tt-contract.cli-code and buf_clients.obj-type = tt-contract.cli-type no-error .
                if not AVAILABLE buf_clients then 
                do:
                    put stream str-err unformatted
                        "Нет поставщика с типом" + " " + tt-contract.cli-type + " и кодом " + string(tt-contract.cli-code)
                        skip .
                    tt-contract.log-error = yes .
                    tt-contract.cli-code = 0 .
                end.
                else 
                do:
                    tt-contract.cli-name = buf_clients.obj-name .
                end.    
            end.
            tt-contract.contract-prn-code = trim(tt-contract.contract-prn-code) .
            if tt-contract.cli-code <>  0 and tt-contract.cli-type <> "" and tt-contract.doc-type <> "" and (tt-contract.contract-prn-code = "" or tt-contract.contract-prn-code = ?) then 
            do:
                put stream str-err unformatted
                    "Не задан номер договора."
                    skip .
                tt-contract.log-error = yes .
                tt-contract.contract-prn-code = "".
            end.
            tt-contract.contract-type = trim(tt-contract.contract-type) .
            if tt-contract.contract-type <> {&contr-buy-sale}
                and tt-contract.contract-type <> {&contr-comiss}
                and tt-contract.contract-type <> {&contr-resp-store}
                and tt-contract.contract-type <> {&contr-agent}
                and tt-contract.contract-type <> {&contr-free}
                and tt-contract.contract-type <> {&contr-tpsi}
                and tt-contract.contract-type <> ""
                then 
            do:
                put stream str-err unformatted
                    "Не существующий тип договора  " + tt-contract.contract-type + "."
                    skip .
                tt-contract.log-error = yes .
                tt-contract.contract-type = "" .
            end.
            
            find first firm no-lock where firm.firm-code = tt-contract.host-code no-error .
            if not available firm
            then do :
              put stream str-err unformatted
                    "Не найдена собственная фирма с кодом  " + string(tt-contract.host-code) + "."
                    skip .
                tt-contract.log-error = yes .
                tt-contract.host-code = 0 .
            end.
        END. 

        INPUT CLOSE. 

        output stream str-err close.
        message substitute("Импорт контрактов завершен.")
            view-as alert-box.
    END.
    for each tt-contract:            
        if tt-contract.doc-type = "" and tt-contract.cli-type = "" and tt-contract.cli-code = 0 then 
        do:
            DELETE tt-contract .
        end.
    end.    
    open query br-contract for each tt-contract .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-proc Dialog-Frame 
PROCEDURE create-proc :
    /*------------------------------------------------------------------------------
      Purpose:
      Parameters:  <none>
      Notes:
    ------------------------------------------------------------------------------*/
    define variable p-sys-date     as date      no-undo .
    define variable p-sys-time     as character no-undo .
    define variable p-sys-time-int as integer   no-undo .
    define variable f-code         as integer   no-undo .
    define variable v-log          as logical   no-undo .
    define variable bad-contract-list as character no-undo .
    
    find first tt-contract no-lock where tt-contract.log-error = yes no-error .
    if available tt-contract
    then do :
      for each tt-contract no-lock where tt-contract.log-error = yes :
        bad-contract-list = bad-contract-list + tt-contract.contract-prn-code + ", " .
      end.
      bad-contract-list = trim(bad-contract-list) .
      bad-contract-list = trim(bad-contract-list, ",") .
      message "Список договоров, которые НЕ будут сохранены: " skip
              bad-contract-list skip
              "Ошибки в файле impcontract.err" skip
              "Продолжить?"
      view-as alert-box question buttons yes-no update v-log .
      if not v-log
      then do :
        return "cancel" .
      end.
    end .

    for each tt-contract no-lock where tt-contract.log-error = no and tt-contract.doc-type <> "":
        find first b_contract EXCLUSIVE-LOCK where b_contract.contract-prn-code = tt-contract.contract-prn-code and b_contract.cli-code = tt-contract.cli-code
        and b_contract.cli-type = tt-contract.cli-type no-error .
        if not AVAILABLE (b_contract) then 
        do:
            run gen-b-code in this-procedure ( input {&gbl-ct-code}, output f-code) no-error .
            if error-status:error then 
            do:
                message "Ошибка при генерации внутреннего № договора" view-as alert-box ERROR.
                return error.
            end.
            { gbl/curdburt.i  tt-contract.user-db-num   tt-contract.user-name   p-sys-date   p-sys-time   p-sys-time-int  }
            create b_contract .
            assign
                b_contract.contract-code     = f-code
                b_contract.contract-prn-code = tt-contract.contract-prn-code 
                b_contract.cli-type          = tt-contract.cli-type
                b_contract.cli-code          = tt-contract.cli-code
                b_contract.cli-name          = tt-contract.cli-name
                .
        end.
        assign
            b_contract.doc-type          = tt-contract.doc-type
            b_contract.host-code         = tt-contract.host-code
            b_contract.contract-type     = tt-contract.contract-type
            b_contract.status_           = {&current-contr}
            b_contract.user-db-num       = tt-contract.user-db-num   
            b_contract.contract-date     = tt-contract.contract-date
            b_contract.contract-date-beg = tt-contract.contract-date-beg
            b_contract.contract-date-end = tt-contract.contract-date-end
            b_contract.contract-prn-code = tt-contract.contract-prn-code
            .
      if tt-contract.edi then do:
        find first b_contract-attr exclusive-lock where b_contract-attr.host-code = b_contract.host-code and b_contract-attr.contract-code = b_contract.contract-code
        and b_contract-attr.attr-code = "contract-edi"  no-error .
        if available (b_contract-attr) then b_contract-attr.attr-value = string(tt-contract.edi) .
        else do:
          create b_contract-attr .
          assign
          b_contract-attr.host-code = b_contract.host-code
          b_contract-attr.contract-code = b_contract.contract-code
          b_contract-attr.attr-code = "contract-edi"
          b_contract-attr.attr-value = string (tt-contract.edi)
          .
        end.  
      end.  
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
