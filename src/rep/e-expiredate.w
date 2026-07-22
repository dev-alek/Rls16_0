&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$


Автор: Шкляр Елена
Дата создания: 16/10/00
Author: Elena Shklyar
Creation date: 16/10/00

*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/
define variable vss-revision as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Отчёт по срокам годности маркированного товара".
/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter  parParentProc  as widget-handle no-undo.

define        variable temp-param-goods-choose as character no-undo .       
define        variable temp-param-goods        as character no-undo init "1,2,3,4,5,6,7". /* Товары */
define        variable t-str                   as character no-undo .
{ cmp/vssrevis.i }

{ cmp/str-glbl.i              }
{ cmp/r-page1.i  NEW}
my-handle = parParentProc .
{ ref/grplibfn.i }
{ cmp/cli-list.i cli-list def "new shared" }
{ rep/rep-bt.i   }
{ gbl/userobjs.i }
{ str/listhprc.i "gds-list"  }

define shared variable lns-cnt                 as integer   no-undo .
define shared variable s-notes                 as character no-undo .
define        variable keep-spis               as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit RECT-8 RECT-9 BUTTON-1 Btn_OK i-exit ~
SelectGood period-control BUTTON-node BUTTON-prod BUTTON-gds Goods-Editor ~
expired-goods F-button-1 TEXT-1 TEXT-2 Goods-count 
&Scoped-Define DISPLAYED-OBJECTS SelectGood period-control Goods-Editor ~
expired-goods F-button-1 TEXT-1 TEXT-2 Goods-count 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD customerName Dialog-Frame 
FUNCTION customerName RETURNS CHARACTER
    ( p-dogovor as character)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-END-KEY 
     LABEL "&Выход" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK AUTO-GO 
     LABEL "_ В&ыполнить" 
     SIZE 12 BY 1
     BGCOLOR 8 .

DEFINE BUTTON BUTTON-1 
     IMAGE-UP FILE "adeicon\ts-up":U
     IMAGE-DOWN FILE "adeicon\ts-down":U
     IMAGE-INSENSITIVE FILE "adeicon\ts-up":U NO-FOCUS
     LABEL "&1.Параметры" 
     SIZE 15 BY 1.17 TOOLTIP "Параметры".

DEFINE BUTTON BUTTON-gds 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "BUTTON-gds" 
     SIZE 3 BY .88.

DEFINE BUTTON BUTTON-node 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "BUTTON-node" 
     SIZE 3 BY .88.

DEFINE BUTTON BUTTON-prod 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "BUTTON-prod" 
     SIZE 3 BY .88.

DEFINE BUTTON i-exit 
     IMAGE-UP FILE "cmp/i-run.bmp":U
     IMAGE-DOWN FILE "cmp/i-run.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/i-rund.bmp":U
     LABEL "" 
     SIZE 2.5 BY .75.

DEFINE VARIABLE Goods-Editor AS CHARACTER 
     VIEW-AS EDITOR MAX-CHARS 32000 SCROLLBAR-VERTICAL
     SIZE 42.75 BY 1.96
     FONT 4 NO-UNDO.

DEFINE VARIABLE F-button-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Параметры" 
      VIEW-AS TEXT 
     SIZE 13 BY .67 TOOLTIP "Параметры" NO-UNDO.

DEFINE VARIABLE f-period AS CHARACTER FORMAT "X(256)":U initial "7"
     VIEW-AS FILL-IN 
     SIZE 5 BY 1 NO-UNDO.

DEFINE VARIABLE Goods-count AS CHARACTER FORMAT "X(30)":U 
      VIEW-AS TEXT 
     SIZE 42.75 BY .67
     FGCOLOR 1 FONT 4 NO-UNDO.

DEFINE VARIABLE TEXT-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Выбор товара" 
      VIEW-AS TEXT 
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE TEXT-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Период контроля" 
      VIEW-AS TEXT 
     SIZE 16.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE period-control AS INTEGER INITIAL 1 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "3 дня", 0,
"7 дней", 1,
"14 дней", 2,
"Свой вариант", 3
     SIZE 20 BY 4.13 NO-UNDO.

DEFINE VARIABLE SelectGood AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Все", 1,
"Группы товаров", 2,
"Производители", 3,
"Выборочно", 4
     SIZE 39.25 BY 4.13
     FGCOLOR 0  NO-UNDO.

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 45.5 BY 8.5.

DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 31.5 BY 6.75.

DEFINE VARIABLE expired-goods AS LOGICAL INITIAL no 
     LABEL "Показать просроченные товары" 
     VIEW-AS TOGGLE-BOX
     SIZE 31 BY .83
     FONT 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1 WIDGET-ID 4
     BUTTON-1 AT ROW 2.5 COL 2 WIDGET-ID 14
     Btn_OK AT ROW 1 COL 11 WIDGET-ID 10
     i-exit AT ROW 1.08 COL 11.13 WIDGET-ID 12 NO-TAB-STOP 
     SelectGood AT ROW 5.5 COL 3.25 NO-LABEL WIDGET-ID 390
     period-control AT ROW 5.5 COL 50 NO-LABEL WIDGET-ID 418
     BUTTON-node AT ROW 6.58 COL 43 WIDGET-ID 402
     BUTTON-prod AT ROW 7.63 COL 43 WIDGET-ID 406
     f-period AT ROW 8.5 COL 69 COLON-ALIGNED NO-LABEL WIDGET-ID 428
     BUTTON-gds AT ROW 8.67 COL 43 WIDGET-ID 398
     Goods-Editor AT ROW 10.67 COL 3.25 NO-LABEL WIDGET-ID 412
     expired-goods AT ROW 11.79 COL 49 WIDGET-ID 92
     F-button-1 AT ROW 2.75 COL 1 COLON-ALIGNED NO-LABEL WIDGET-ID 372
     TEXT-1 AT ROW 4.25 COL 11 COLON-ALIGNED NO-LABEL WIDGET-ID 414
     TEXT-2 AT ROW 4.25 COL 49.75 COLON-ALIGNED NO-LABEL WIDGET-ID 426
     Goods-count AT ROW 9.92 COL 3.25 NO-LABEL WIDGET-ID 432
     RECT-8 AT ROW 4.5 COL 2 WIDGET-ID 416
     RECT-9 AT ROW 4.5 COL 48.5 WIDGET-ID 430
     SPACE(2.99) SKIP(2.07)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Отчёт по срокам годности маркированного товара" WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */
FUNCTION stat-line RETURNS CHARACTER
    (input p-status-chr as character )  FORWARD.
&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB Dialog-Frame 
/* ************************* Included-Libraries *********************** */

{src/adm/method/smart.i}
{src/adm/method/record.i}
{src/adm/method/tableio.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
       BUTTON-gds:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN 
       BUTTON-node:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN f-period IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       Goods-Editor:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Отчёт по срокам годности маркированного товара */
DO:
        APPLY "END-ERROR":U TO SELF.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame /* _ Выполнить */
DO:
            assign
                SelectGood
                expired-goods
                .

             run rep/r-expireDate.p(input parParentProc,
                input SelectGood,
                input integer(f-period),
                input expired-goods
                ) .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-gds Dialog-Frame
ON CHOOSE OF BUTTON-gds IN FRAME Dialog-Frame /* BUTTON-gds */
DO:
        define variable ref-list       as character no-undo.
        define variable vRecId         as recid     no-undo.
        define variable vAnswer        as logical   no-undo.
        define variable vI             as integer   no-undo.
        define variable v-seq          as integer   no-undo .
        define variable num-rec        as integer   init 0 no-undo.
        define variable v-bh           as handle    no-undo .
        define variable v-recs         as integer   no-undo .
        define variable v-temp-seq     as integer   no-undo .
        define variable v-line         as integer   no-undo .
        define variable v-item         as character no-undo .
        define variable v-tot-lns      as integer   no-undo .
        define variable v-ref-rec      as recid     no-undo .
        define variable dsp-rs         as character no-undo .
        define variable rs-status      as character no-undo init {&current}.
        define variable v-tbl-name     as character no-undo .
        define variable rs-list-method as character no-undo init "goods".
        define variable tot-lns        as integer   init ? no-undo.
        define variable v-no-hist      as integer   no-undo init -1.
        define variable v-first        as logical   no-undo .
        
            run ref/gds-ref.p (
                input parParentProc
                ,input "b-mark,b-sel"
                ,input {&all}           /*p-stat */
                ,input {&all}        /*p-list  */
                ,input ?                /*p-cond  */
                ,input ?                /*p-rec   */
                ,input ?                /*p-grp   */
                ,input ?                /*p-cli-type */
                ,input ?                /*p-cli-code  */
                ,input v-cntxt-obj-type /*p-obj-type  */
                ,input v-cntxt-obj-code /*p-obj-code  */
                ,input ?                /*p-other     */
                ,output ref-list).
            if ref-list = "" and can-find(first gds-list) then
            do:
                message
                    "Не было выбрано ни одного товара. Очистить список ранее выбранных товаров?"
                    view-as alert-box QUESTION buttons YES-NO update vAnswer.
                if not vAnswer then return.
                else do:
                    empty temp-table gds-list .
                    empty temp-table gds-list-hist .
/*                    dsp-rs = "" .      */
/*                    s-notes = "" .     */
/*                    t-str = "" .       */
/*                    Goods-Editor = "" .*/
                end.
            end.
            find first gds-list no-error .
            if available (gds-list) then v-first = true .
            if ref-list <> "" then
            do:
                empty temp-table gds-list .
                empty temp-table gds-list-hist .
/*                s-notes = "" .     */
/*                t-str = "" .       */
/*                Goods-Editor = "" .*/
                
                v-recs = num-entries (ref-list).
                _next:
                do num-rec = 0 to v-recs:

                    if v-recs = 1 then
                    do:
                        num-rec = 1 .
                    end.
                    if num-rec > 0 then
                    do:
                        v-ref-rec = integer (entry (num-rec, ref-list)).
                        find goods where recid (goods) = v-ref-rec no-lock.
                        find first gds-list where gds-list.gds-code = goods.gds-code no-error .
                        if not available (gds-list) then do:
                        create gds-list .
                        buffer-copy goods to gds-list .
                        end.
                        else next _next .
                    end.

                    if v-recs = 1 then
                    do:
                        assign
                            v-temp-seq = v-seq
                            v-line     = 0
                            v-item     = '':U
                            v-tbl-name = {&table_goods}
                            v-bh       = buffer goods:handle
                            v-tot-lns  = tot-lns
                            .
                            if not v-first then dsp-rs     = substitute("Товар :&1 &2", goods.gds-name, stat-line(rs-status)) .
                            else dsp-rs     = substitute("Товар :&1 ", goods.gds-name) .
                    end.
                    else
                    do:
                        
                        if num-rec = 0 then
                        do:
                            if not v-first then do:
                            assign
                                v-temp-seq = v-seq
                                v-line     = 0
                                v-item     = '':U
                                v-tbl-name = '':U
                                v-bh       = ?
                                v-tot-lns  = tot-lns
                                .
                                dsp-rs     = substitute("Товары : &1", stat-line(rs-status)) .
                            end.
                        end.
                        else
                        do:
                            assign
                                v-temp-seq = v-seq - 1
                                v-line     = num-rec
                                dsp-rs     = substitute("&1 ", goods.gds-name) 
/*                                dsp-rs     = substitute("код &1 &2 &3&4 &5", goods.gds-code, goods.artic, goods.prod-type, goods.prod-code, goods.gds-name)*/
                                v-item     = '':U
                                v-tbl-name = {&table_goods}
                                v-bh       = buffer goods:handle
                                v-tot-lns  = tot-lns + num-rec
                                .
                        end.
                    end.
                    v-no-hist = (if num-rec = 1 then 0 else num-rec).
                    if dsp-rs <> "" then do:
                    run create-gds-list-hist in this-procedure(input {&add-def}
                        , input-output v-temp-seq
                        , input v-line
                        , input '':U
                        , input dsp-rs
                        , input v-tot-lns
                        , input rs-list-method
                        , input rs-status
                        , input v-item
                        , input v-tbl-name
                        , input v-bh
                        ).
                    if num-rec = 0 or v-recs = 1 then v-seq  = v-temp-seq.
                    end.
                end.
            end.
        lns-cnt = 0 .
        for each gds-list :
            lns-cnt = lns-cnt + 1 .
        end.

        define variable v-i as integer no-undo .
        s-notes =  "" .
        for each gds-list-hist :
            v-i = v-i + 1 .
            s-notes = s-notes + {&new-line} + gds-list-hist.hist-mode +  gds-list-hist.des .
            if v-i > 10 then
            do:
                s-notes = s-notes + " ... " .
                leave.
            end.
        end.
        run display-count-other in this-procedure .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-node
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-node Dialog-Frame
ON CHOOSE OF BUTTON-node IN FRAME Dialog-Frame /* BUTTON-node */
DO:
        run ref/gds-grp.w
            (             input my-handle
            ,input "b-sel,b-mark"
            ,input v-cntxt-obj-type
            ,input v-cntxt-obj-code
            ,input-output gdsgrp_recids ).
        run display-count-other in this-procedure .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-prod
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-prod Dialog-Frame
ON CHOOSE OF BUTTON-prod IN FRAME Dialog-Frame /* BUTTON-prod */
DO:
        define variable v-ind as integer no-undo .
        define buffer cli-prod for ub.clients .
        define variable cli-grp_recids as character no-undo .

        /* может и не надо??? */
        FOR EACH g#cli :
            delete g#cli .
        END .

        if SelectGood:screen-value = "{&g-prod}" then
        do:
            run ref/cli-all.w
                ( my-handle
                , "b-sel,b-mark"
                , {&pro}
                , {&all}
                , {&current}
                , ?
                , ",,,,,,NO,,"
                , ?
                , output cli-grp_recids ) no-error .
            if error-status :error then
                message vss-workfile vss-revision vss-description skip
                    error-status :get-message(1) skip
                    "Ошибка вызова cli-all.w"
                    view-as alert-box error .

            if cli-grp_recids = "" then 
            do:
                Assign 
                    goods-count  = '' 
                    Goods-Editor = ''.
                Display goods-count Goods-Editor with frame {&FRAME-NAME} .
            end.
            else 
            do:
                DO v-ind = 1 TO num-entries( cli-grp_recids )
                    :
                    FIND cli-prod WHERE recid( cli-prod ) = int( entry(v-ind, cli-grp_recids ) ) NO-LOCK.
                    create g#cli.
                    assign
                        g#cli.obj-type = cli-prod.obj-type
                        g#cli.obj-code = cli-prod.obj-code
                        g#cli.obj-name = cli-prod.obj-name.
                END.
            end.
        end.
        else 
        do:
            FOR EACH g#cli :
                delete g#cli .
            END .
            cli-grp_recids = "" .
        end.
        run display-count-other in this-procedure .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-period
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-period Dialog-Frame
ON VALUE-CHANGED OF f-period IN FRAME Dialog-Frame
DO:
        assign f-period .

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME i-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-exit Dialog-Frame
ON CHOOSE OF i-exit IN FRAME Dialog-Frame
DO:
        APPLY "choose" TO btn_ok.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME period-control
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL period-control Dialog-Frame
ON VALUE-CHANGED OF period-control IN FRAME Dialog-Frame
DO:
        assign period-control .
        case period-control:
            when 0 then 
                do:
                    hide f-period in frame Dialog-Frame .
                    f-period = "3" .
                end.
            when 1 then 
                do:
                    hide f-period in frame Dialog-Frame .
                    f-period = "7" .
                end.
            when 2 then 
                do:
                    hide f-period in frame Dialog-Frame .
                    f-period = "14" .
                end.
            when 3 then 
                do:
                    enable f-period with frame Dialog-Frame .
                end.                        
        end case .

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME SelectGood
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL SelectGood Dialog-Frame
ON VALUE-CHANGED OF SelectGood IN FRAME Dialog-Frame
DO:
        run val-goods in this-procedure .
        RUN new-state ("SELECTGOOD="  + String(SelectGood:screen-value)).

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

  /* Initialize attributes for update processing objects. */
  RUN set-attribute-list ('FIELDS-ENABLED=no,ADM-NEW-RECORD=no':U).


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    
    /* Документы */
    RUN enable_UI.
    hide BUTTON-node button-gds BUTTON-prod in frame {&FRAME-NAME} .
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
    DISPLAY SelectGood period-control expired-goods Goods-Editor F-button-1 
        TEXT-1 TEXT-2 
        WITH FRAME Dialog-Frame.
    ENABLE b-exit Btn_OK BUTTON-1 i-exit RECT-8 RECT-9 SelectGood period-control 
        expired-goods Goods-Editor F-button-1 
        TEXT-1 TEXT-2 
        WITH FRAME Dialog-Frame.
    VIEW FRAME Dialog-Frame.
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION customerName Dialog-Frame 
FUNCTION customerName RETURNS CHARACTER
    ( p-dogovor as character) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/
    define variable ii    as integer   no-undo .
    define variable name_ as character no-undo .
    define buffer buf_contract for ub.contract .
 
    do ii = 1 to num-entries(p-dogovor):                                                                            
        find first buf_contract no-lock where buf_contract.contract-code = integer(entry(ii,p-dogovor,",")) no-error .
        if available (buf_contract) then
        do:
            name_ = name_ + ", " + buf_contract.contract-prn-code .
        end.
    end.  
    if name_ <> "" then name_ = trim(name_,",") .       
    RETURN name_ .   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE val-goods s-object 
PROCEDURE val-goods :
    If temp-param-goods <> "" THEN 
    DO:
        assign
            Goods-Editor = ''
            goods-count = ''
            .
        Case Integer(SelectGood:screen-value IN frame {&FRAME-NAME}):
            When {&g-all} then 
                DO:
                    hide BUTTON-gds BUTTON-node BUTTON-prod in frame {&FRAME-NAME} .
                    Goods-Editor = " По всем товарам ".
                End.
            When {&g-grp} then 
                DO:
                    hide BUTTON-gds BUTTON-prod in frame {&FRAME-NAME} .
                    enable BUTTON-node  with frame {&FRAME-NAME} .
                End.
             When {&g-choice} then 
                DO:
                    hide BUTTON-node BUTTON-prod in frame {&FRAME-NAME} .
                    enable BUTTON-gds with frame {&FRAME-NAME} .
                END.
             When {&g-prod} then 
                DO:
                    hide BUTTON-node BUTTON-gds in frame {&FRAME-NAME} .
                    enable BUTTON-prod with frame {&FRAME-NAME} .
                END.
        End case.
        enable Goods-Editor  with frame {&FRAME-NAME}.
        display Goods-Editor goods-count with frame {&FRAME-NAME}.
    End.
    Else  hide Goods-Editor in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

FUNCTION stat-line RETURNS CHARACTER(input p-status-chr as character):
    /*функция возвращает строку для message и для dsp-rs*/
    DEFINE VARIABLE var-stat-line as character no-undo .

    CASE p-status-chr:
        when {&all} then 
            do:
                assign
                    var-stat-line = "(текущие и неактивные товары)"
                    .
            end.
        when {&current} then 
            do:
                assign
                    var-stat-line = "(текущие товары)"
                    .
            end.
        when {&deleted} then 
            do:
                assign
                    var-stat-line = "(неактивные товары)"
                    .
            end.
    END CASE.
    return var-stat-line .
END.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Display-count s-object 
PROCEDURE Display-count :
if SelectGood = {&g-spis} then 
    do:
        Assign
            goods-count  = '(Выбрано ' + string(lns-cnt) + ' список)'
            Goods-Editor = s-notes
            .
    end.
    else 
    do:
        If can-find (First gds-list no-lock)
            then
            Assign
                goods-count  = '(Выбрано ' + string(lns-cnt) + ' товаров)'
                Goods-Editor = s-notes
                .

        else
            Assign
                goods-count  = ''
                Goods-Editor = ''
                .
    end.
    Display goods-count Goods-Editor with frame {&FRAME-NAME} .
    x-Goods-Editor = Goods-Editor.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Display-count-OTHER Dialog-Frame 
PROCEDURE Display-count-OTHER :
/* -----------------------------------------------------------
      Purpose:
      Parameters:  <none>
      Notes:
    -------------------------------------------------------------*/
    x-SelectGood = Integer(SelectGood:screen-value IN frame {&FRAME-NAME}).
    run sel-x-selectgood in this-procedure .
    if LENGTH (t-str) > {&max-len-str} then 
    do:
        Assign  
            Goods-Editor = substring(T-str ,1, {&max-len-str}) + {&new-line} + "выборка для просмотра обрезана - слишком много записей " .
    end.
    else Assign  Goods-Editor = T-str  .

    Display goods-count Goods-Editor with frame {&FRAME-NAME} .
    x-Goods-Editor = Goods-Editor.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE sel-x-SelectGood s-object 
PROCEDURE sel-x-SelectGood :
/* -----------------------------------------------------------
      Purpose:
      Parameters:  <none>
      Notes:
    -------------------------------------------------------------*/

    define variable grp_name as char. /*inc*/
    define buffer buf_gds-grp for ub.gds-grp .

    define variable my-c as int no-undo.
    IF temp-param-goods <> "" THEN 
    DO:
        Case x-SelectGood :
            When {&g-all} then 
                t-str = " По всем товарам ".
            When {&g-grp} then 
                DO:
                    t-str = " По группам "  .
                    For each  tmp#grp :
                        delete tmp#grp.
                    End.

                    define variable v-ind as integer no-undo .
                    Repeat v-ind = 1 To num-entries( gdsgrp_recids )
                        :

                        find first buf_gds-grp WHERE recid ( buf_gds-grp ) = integer ( Entry(v-ind,gdsgrp_recids )) NO-LOCK.
                        RUN grplib-get-full-name in this-procedure( input buf_gds-grp.node-code, output Grp_Name ).
                        if Grp_Name <> ? Then  
                            if LENGTH(t-str) <= {&max-len-str} then t-str = t-str + {&new-line} + "     " + Grp_Name .
                        Create tmp#grp.
                        Assign 
                            tmp#grp.node-code = buf_gds-grp.node-code
                            tmp#grp.grp-name  = Grp_Name
                            tmp#grp.is-term   = buf_gds-grp.is-term
                            tmp#grp.lvl-num   = buf_gds-grp.lvl-num
                            .
                    end.
                    if num-entries( gdsgrp_recids ) > 0 THEN
                        goods-count = "выбрано " + string(num-entries( gdsgrp_recids )) + " групп " .
                    ELSE goods-count = "НЕ выбрано !!!".
                End.
            When {&g-prod} then 
                DO:
                    t-str = ''.
                    t-str = " По производителям " .
                    my-c = 0.
                    for each g#cli no-lock:
                        if LENGTH(t-str) <= {&max-len-str} then t-str = t-str + {&new-line} + "     " + g#cli.obj-name .
                        my-c =  my-c + 1 .
                    End.
                    if my-c > 0 THEN
                        goods-count = "выбрано " + String(my-c) .
                    ELSE goods-count = "НЕ выбрано !!!".
                END.
            When {&g-choice} then 
                DO:
                    if can-find (first gds-list no-lock ) then 
                    DO:
                        t-str = " По списку товаров " +  s-Notes.
                        goods-count = "выбрано " + String(lns-cnt) .
                    End.
                    Else Assign goods-count = "НЕ выбрано !!!" t-str       = "" lns-cnt     = 0 .

                End.
            When  {&g-spis}  then 
                DO:

                    if  keep-spis <> "" then 
                    DO:
                        t-str = s-Notes.
                        goods-count = "выбрано списков : " + String(lns-cnt) .
                    End.
                    Else Assign goods-count = "НЕ выбрано !!!" t-str       = "" lns-cnt     = 0 .

                End.

            When {&g-one} then 
                DO:
                    find first gds-list no-lock no-error.
                    if available gds-list THEN  Assign t-str       = " " +  gds-list.gds-name goods-count = "выбран 1 товар".
                    ELSE Assign t-str       = "" goods-count = "НЕ выбрано !!!" lns-cnt     = 0 .
                END.
            When {&g-grp-prod} then 
                DO:
                    t-str = " По группам "  .
                    For each  tmp#grp :
                        delete tmp#grp.
                    End.
                    Repeat v-ind = 1 To num-entries( gdsgrp_recids ):
                        find first buf_gds-grp WHERE recid ( buf_gds-grp ) = integer ( Entry(v-ind,gdsgrp_recids )) NO-LOCK.
                        run grplib-get-full-name in this-procedure ( input buf_gds-grp.node-code, output Grp_Name ).
                        if Grp_Name <> ? Then 
                            if LENGTH(t-str) <= {&max-len-str} then t-str = t-str + {&new-line} + "     " + Grp_Name .
                        Create tmp#grp.
                        Assign 
                            tmp#grp.node-code = buf_gds-grp.node-code
                            tmp#grp.grp-name  = Grp_Name
                            tmp#grp.is-term   = buf_gds-grp.is-term
                            tmp#grp.lvl-num   = buf_gds-grp.lvl-num
                            .
                    end.

                    t-str = t-str + {&new-line} +  " По производителям " .
                    my-c = 0.
                    for each g#cli no-lock:
                        t-str = t-str + {&new-line} + "     " + g#cli.obj-name no-error .
                        my-c =  my-c + 1 .
                    End.


                    if num-entries( gdsgrp_recids ) > 0  and my-c > 0 THEN 
                    DO:
                        goods-count = "выбрано " + string(num-entries( gdsgrp_recids )) + " групп "
                            + string(my-c) + " производителей " .


                    End.

                    ELSE goods-count = "НЕ выбрано !!!".
                End.

        End case.
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-keep-spis Dialog-Frame 
PROCEDURE select-keep-spis :
/* -----------------------------------------------------------
      Purpose: можно запустить принудительно со второй закладки
    
      Пример :
          { rep/get-link.i 'State':U }
           run select-keep-spis in State-source ("ttt") .
    
    
    
      Parameters:  <none>
      Notes:
    -------------------------------------------------------------*/
    define input  parameter p-keep-spis as character no-undo .

    define buffer buf_clob-bind for ub.clob-bind  .
    keep-spis = p-keep-spis.
    find first buf_clob-bind no-lock where
        buf_clob-bind.field-name_ = keep-spis no-error .

    if available buf_clob-bind then 
    do:
        keep-spis = buf_clob-bind.field-name_ .
        lns-cnt = 1 .
        s-notes = substitute("Хранимый Файл списка : &1 &2", buf_clob-bind.field-name, buf_clob-bind.descr ).
    end.
    else 
    do:
        keep-spis = "".
        lns-cnt = 0 .
        s-notes = " " .
    end.
    run display-count       in this-procedure .
    run display-count-other in this-procedure .
    selectgood    = {&g-spis} .
    x-selectgood  = {&g-spis} .
    run val-goods in this-procedure .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME