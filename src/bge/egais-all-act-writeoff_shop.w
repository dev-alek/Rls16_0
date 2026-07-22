&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список накладных ЕГАИС

  Author: 
    Автор: Морозов Александр Сергеевич
    Дата создания: 15/11/03
    Author: Alexandr Morozov
    Creation date: 15/11/03
 
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
using ibs.th.bge.egais.*.
/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-select as logical   no-undo .
define output parameter p-RegID as character no-undo .
/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Акты о списании из торгового зала ЕГАИС".

{ cmp/vssrevis.i }
{ cmp/showinf.i  }

define variable th-act-header         as handle    no-undo.
define variable bh-act-header         as handle    no-undo.
define variable qh-act-header         as handle    no-undo.
define variable browse-hdl-act-header as handle    no-undo.
define variable bcol                as handle    extent 11 no-undo.
define variable calc-col-hndl       as handle    no-undo .
define variable calc-col-hndl2      as handle    no-undo .
define variable egais               as class     ActWriteOff_Shop no-undo.
define variable v-db-num            as integer   no-undo .
define variable v-user-id           as character no-undo .
define variable qh-ab-gds-EG-header as handle    no-undo.
define variable qh-ab-gds-EG        as handle    no-undo.
define variable bh-ab-gds-EG-header as handle    no-undo.
define variable bh-ab-gds-EG        as handle    no-undo.
define variable v-RegID             as character no-undo .

define variable glog        as logical no-undo .

define variable v-act-num as character no-undo .

define variable ii                  as integer no-undo .

define variable v-value-character   as character no-undo .
define variable v-value-decimal     as decimal   no-undo .
define variable v-value-integer     as integer   no-undo .
define variable v-value-logical     as logical   no-undo .
define variable v-value-type        as character no-undo .
define variable v-value-date        as date      no-undo .
define variable v-ext-sys           as integer   no-undo .

define buffer buf_clob-bind     for ub.clob-bind .
define buffer buf_clob-data     for ub.clob-data .

define buffer buf_goods         for ub.goods .
define buffer buf_parts         for ub.parts .
define buffer x_ext-classif     for ub.ext-classif .
define buffer x_ext-classif-attr     for ub.ext-classif-attr .

define variable v-fs-rar as character no-undo view-as text format "X(15)" label "Код ФС РАР (FSRAR ID)" .

{ gbl/color.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/thbjattr.i }
{ ref/extclass.i }
{ibs/th/bge/egais/awo-egais_shop.i proc new shared }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_OK RADIO-SET-1 
&Scoped-Define DISPLAYED-OBJECTS RADIO-SET-1 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_lkp 
     LABEL "Просмотр" 
     SIZE 15 BY 1.13.
     
DEFINE BUTTON Btn_create 
     LABEL "Создать" 
     SIZE 15 BY 1.13.

DEFINE BUTTON Btn_chg 
     LABEL "Изменить" 
     SIZE 15 BY 1.13.

DEFINE BUTTON Btn_del 
     LABEL "Удалить" 
     SIZE 15 BY 1.13.
     
DEFINE BUTTON Btn_send 
     LABEL "Отправить" 
     SIZE 15 BY 1.13.
          
DEFINE BUTTON Btn_OK AUTO-GO 
     LABEL "Выход" 
     SIZE 15 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON Btn_Ans 
     LABEL "Посмотреть ответ" 
     SIZE 20 BY 1.13
     BGCOLOR 8 .
     
DEFINE BUTTON Btn_Sel AUTO-GO
     LABEL "Выбор" 
     SIZE 15 BY 1.13
     BGCOLOR 8 .
     
DEFINE BUTTON Btn_Edit
     LABEL "Редактировать" 
     SIZE 15 BY 1.13 tooltip "Вернуть в 'Новые' для редактирования"
     BGCOLOR 8 .
     
DEFINE VARIABLE f-date AS DATE FORMAT "99/99/99":U 
     LABEL "Дата с" 
     VIEW-AS FILL-IN 
     SIZE 9.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-date-2 AS DATE FORMAT "99/99/99":U 
     LABEL "по" 
     VIEW-AS FILL-IN 
     SIZE 9.5 BY 1 NO-UNDO.


DEFINE VARIABLE RADIO-SET-1 AS INTEGER INITIAL 1 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Новые", 1,
          "Отправленные", 2
     SIZE 27 BY 1.25 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1.2 COL 2
     Btn_create at row 1.2 col 17
     Btn_chg at row 1.2 col 32
     Btn_del at row 1.2 col 47
     Btn_send at row 1.2 col 62
     Btn_Ans AT ROW 1.2 COL 32 WIDGET-ID 10
     Btn_lkp AT ROW 1.2 COL 17 WIDGET-ID 12
     Btn_Sel AT ROW 1.2 COL 17
     Btn_Edit AT ROW 1.2 COL 52
     RADIO-SET-1 AT ROW 1.2 COL 80 NO-LABEL WIDGET-ID 2
     f-date AT ROW 2.5 COL 8.63 COLON-ALIGNED WIDGET-ID 22
     f-date-2 AT ROW 2.5 COL 22.75 COLON-ALIGNED WIDGET-ID 26
     SPACE(2) SKIP(22.2)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Акты о списании товаров из торгового зала ЕГАИС"
         DEFAULT-BUTTON Btn_OK WIDGET-ID 100.


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
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON window-close OF FRAME Dialog-Frame /* Накладные ЕГАИС */
do:
    delete object egais no-error .
  apply "END-ERROR":U to self.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_lkp Dialog-Frame
ON CHOOSE OF Btn_lkp IN FRAME Dialog-Frame /* Загрузить */
DO:
    if not bh-act-header:available then return no-apply .
    run bge/egais-act-writeOff_shop.w (parparentproc, {&lookup}, egais, v-ext-sys, v-fs-rar, bh-act-header:handle) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME Btn_Edit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_Edit Dialog-Frame
ON CHOOSE OF Btn_Edit IN FRAME Dialog-Frame 
DO:
    if not bh-act-header:available then return no-apply .
    find last buf_clob-bind where buf_clob-bind.field-name_ = {&lob-egais-awo_shop} and buf_clob-bind.uniq-key-rec = bh-act-header:buffer-field ("num"):buffer-value .
    entry(4, buf_clob-bind.descr, {&delim-par}) = string(no) no-error .
    entry(5, buf_clob-bind.descr, {&delim-par}) = "" no-error .
    entry(6, buf_clob-bind.descr, {&delim-par}) = "" no-error . 
    bh-act-header:buffer-field ("is-sent"):buffer-value = string(no) no-error .
    bh-act-header:buffer-field ("answer_"):buffer-value = "" no-error .
    bh-act-header:buffer-field ("RegID"):buffer-value = "" no-error .
    
    find first ub.esys-all-attr 
                where ub.esys-all-attr.table-name = "esys-pck-sent" 
                and ub.esys-all-attr.attr-code = "egais"
                and ub.esys-all-attr.key2       = 4
                and ub.esys-all-attr.attr-value = buf_clob-bind.uniq-key-rec
                no-error.
    if available (ub.esys-all-attr )
    then do:
      delete ub.esys-all-attr .
    end.
    
    run refresh-query .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME Btn_Sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_Sel Dialog-Frame
ON CHOOSE OF Btn_Sel IN FRAME Dialog-Frame /* Загрузить */
DO:
    if not bh-act-header:available then return no-apply .
    assign p-RegID = bh-act-header:buffer-field ("RegID"):buffer-value .
    if p-RegID = "" or p-RegID = ? or num-entries(p-RegID, CHR(5)) <> 2 then do :
        message "Данный акт либо относится к старой версии ЕГАИС, либо по нему ещё не получен ответ (в этом случае нажмите кнопку 'Посмотреть ответ')." view-as alert-box .
        p-RegID = "" .
        return no-apply .
    end.
    if entry(2, p-RegID, CHR(5)) = "R" then do :
        message "Данный акт о списании был отклонён ЕГАИС. Чтобы узнать причину нажмите кнопку 'Посмотреть ответ'" view-as alert-box .
        p-RegID = "" .
        return no-apply .
    end.
    assign p-RegID = entry(1, p-RegID, CHR(5)) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME Btn_create
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_create Dialog-Frame
ON CHOOSE OF Btn_create IN FRAME Dialog-Frame /* Создать */
DO:
    run bge/egais-act-writeOff_shop.w (parparentproc, {&add-def}, egais, v-ext-sys, v-fs-rar, bh-act-header:handle) .
    bh-act-header = egais:GetHndlTable(3, "").
    run refresh-query.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME Btn_chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_chg Dialog-Frame
ON CHOOSE OF Btn_chg IN FRAME Dialog-Frame /*  */
DO:
    if not bh-act-header:available then return no-apply .
    v-act-num = bh-act-header:buffer-field ("num"):buffer-value .
    run bge/egais-act-writeOff_shop.w (parparentproc, {&update}, egais, v-ext-sys, v-fs-rar, bh-act-header:handle) .
    bh-act-header = egais:GetHndlTable(3, "").
    run refresh-query.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME Btn_del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_del Dialog-Frame
ON CHOOSE OF Btn_del IN FRAME Dialog-Frame /*  */
DO:
    if not bh-act-header:available then return no-apply .
    find last buf_clob-bind where buf_clob-bind.field-name_ = {&lob-egais-awo_shop} and buf_clob-bind.uniq-key-rec = bh-act-header:buffer-field ("num"):buffer-value .
    delete buf_clob-bind .
    bh-act-header:buffer-delete () .
    run refresh-query.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME Btn_send
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_send Dialog-Frame
ON CHOOSE OF Btn_send IN FRAME Dialog-Frame /*  */
DO:
    if not bh-act-header:available then return no-apply .
    find last buf_clob-bind where buf_clob-bind.field-name_ = {&lob-egais-awo_shop} and buf_clob-bind.uniq-key-rec = bh-act-header:buffer-field ("num"):buffer-value .
    find first buf_clob-data no-lock where buf_clob-data.db-num = buf_clob-bind.db-num and buf_clob-data.int64-id = buf_clob-bind.int64-id no-error.
    os-delete "temp-ActWriteOff_shop.xml".
    copy-lob
    from  object buf_clob-data.cdata
    to  file 'temp-ActWriteOff_shop.xml'
    no-convert
    no-error .
    run parseXML in this-procedure (input "temp-ActWriteOff_shop.xml") .
    find first tt-act-header .
    v-file = 'ActWriteOff_Shop.xml' .
    os-delete "ActWriteOff_Shop.xml" .
    run makeXMLegais_v2 .
    egais:inNum = tt-act-header.num .
    egais:SendRequestUTM() .
    glog = egais:IsSent .
    
    glog = egais:StatusErr .
    if glog then do :
        message egais:Msg view-as alert-box.
        return no-apply.
    end.
    else do :
        entry (4, buf_clob-bind.descr, {&delim-par}) = "yes".
        
        bh-act-header:buffer-field ("is-sent"):buffer-value = true.
    end.
    run refresh-query.
    
    message "Акт " egais:inNum " отправлен" view-as alert-box .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME Btn_Ans
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_Ans Dialog-Frame
ON CHOOSE OF Btn_Ans IN FRAME Dialog-Frame /* Сохранить */
DO:
  if not bh-act-header:available 
    then return no-apply.
    
    v-act-num = bh-act-header:buffer-field ("num"):buffer-value .
/*  if (bh-act-header:buffer-field ("answer_"):buffer-value) <> "" then do :                       */
/*    message (bh-act-header:buffer-field ("answer_"):buffer-value) view-as alert-box information .*/
/*  end.                                                                                           */
/*  else do :                                                                                      */
      egais:inNum = bh-act-header:buffer-field ("num"):buffer-value .
      egais:GetHndlTable(2, bh-act-header:buffer-field ("num"):buffer-value) .
      glog = egais:StatusErr .
      if glog
      and (bh-act-header:buffer-field ("answer_"):buffer-value = "" 
        or bh-act-header:buffer-field ("answer_"):buffer-value = ? )
      then do :
            message egais:Msg view-as alert-box.
            return no-apply.
      end.
      else message (bh-act-header:buffer-field ("answer_"):buffer-value) view-as alert-box information .  
/*  end.*/
  run refresh-query.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADIO-SET-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-SET-1 Dialog-Frame
ON value-changed OF RADIO-SET-1 IN FRAME Dialog-Frame
do:
  assign RADIO-SET-1 .
  if RADIO-SET-1 = 1 
  then do :
    ENABLE Btn_create Btn_chg Btn_del Btn_send 
      WITH FRAME Dialog-Frame. 
    HIDE Btn_Ans Btn_lkp Btn_Edit in FRAME Dialog-Frame.  
  end.
  else do :
    ENABLE Btn_Ans Btn_lkp Btn_Edit
      WITH FRAME Dialog-Frame.
    HIDE Btn_create Btn_chg Btn_del Btn_send in FRAME Dialog-Frame.    
  end.
  run refresh-query.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME f-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-date Dialog-Frame
ON leave OF f-date IN FRAME Dialog-Frame /* Дата с */
do:
  run refresh-query.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-date Dialog-Frame
ON return OF f-date IN FRAME Dialog-Frame /* Дата с */
do:
  run refresh-query.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-date-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-date-2 Dialog-Frame
ON leave OF f-date-2 IN FRAME Dialog-Frame /* по */
do:
  run refresh-query.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-date-2 Dialog-Frame
ON return OF f-date-2 IN FRAME Dialog-Frame /* по */
do:
  run refresh-query.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
if valid-handle(active-window) and frame {&FRAME-NAME}:PARENT eq ?
then frame {&FRAME-NAME}:PARENT = active-window.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
do on error   undo MAIN-BLOCK, leave MAIN-BLOCK
   on end-key undo MAIN-BLOCK, leave MAIN-BLOCK:

  { gbl/getcurus.i
    v-db-num
    v-user-id
    no-error
  }
  
  empty temp-table thbjattr_thbj-attr .
  run adm/shattri.p (
       input "get":U
      ,input v-cntxt-obj-type
      ,input v-cntxt-obj-code
      ,input {&attr-egais-host}
      ,input {&attr-egais-host_egais-fsrar}
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-value-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
  assign 
    v-fs-rar = v-value-character 
  .
  
  run adm/shattri.p (
       input "get":U
      ,input '':U
      ,input 0
      ,input {&attr-egais-host}
      ,input {&attr-egais-host_egais-exsys}
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-value-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
  assign v-ext-sys = v-value-integer .  
  
  
  egais = new ActWriteOff_Shop (v-cntxt-obj-type, v-cntxt-obj-code, v-fs-rar, v-ext-sys).
  egais:DbNum = v-db-num .
  egais:User_Id = v-user-id .

  bh-act-header = egais:GetHndlTable(3, "").
  create query qh-act-header.
  f-date = date (now) - 31.
  f-date-2 = ?.
  run refresh-query.

  
  create browse browse-hdl-act-header
    assign 
      title     = 'Акты о списании товара из торгового зала ЕГАИС'
      frame     = frame {&FRAME-NAME}:handle
      query     = qh-act-header
      x         = 10
      y         = 60
      width     = 104
      height    = 22
      visible   = true
      read-only = true
      sensitive = true
      separators = true
      column-resizable = true
      column-scrolling = true
      triggers:
/*        on mouse-move-dblclick persistent run msdblcl.*/
/*        on row-leave persistent run proc-row-leave.*/
      end triggers
  .
  
  on row-display of browse-hdl-act-header do :
      if valid-handle (calc-col-hndl) then do :
          if RADIO-SET-1 = 1 then calc-col-hndl:SCREEN-VALUE = "Новый" .
          else do : 
            assign v-RegID = bh-act-header:buffer-field ("RegID"):buffer-value .
            if v-RegID = "" or v-RegID = ? or num-entries(v-RegID, CHR(5)) <> 2 then calc-col-hndl:SCREEN-VALUE = "Отправлен" .
            if num-entries(v-RegID, CHR(5)) = 2 then do :
                if entry(2, v-RegID, CHR(5)) = "R" then do :
                    calc-col-hndl:SCREEN-VALUE = "Отклонен" .
                    calc-col-hndl:bgcolor = red_color .
                end.
                if entry(2, v-RegID, CHR(5)) = "A" then do :
                    calc-col-hndl:SCREEN-VALUE = "Принят" .
                    calc-col-hndl:bgcolor = green_color .
                end.
            end.    
          end.
      end.
      if valid-handle (calc-col-hndl2) then do :
          if RADIO-SET-1 = 1 then calc-col-hndl2:SCREEN-VALUE = " - " .
          else do : 
            assign v-RegID = bh-act-header:buffer-field ("RegID"):buffer-value .
            calc-col-hndl2:SCREEN-VALUE = entry(1, v-RegID, CHR(5)) .
          end.
      end.
  end.
  
  ON value-changed OF browse-hdl-act-header
  do:
      if calc-col-hndl:SCREEN-VALUE = "Отклонен" then enable Btn_Edit with FRAME Dialog-Frame .
                                                 else disable Btn_Edit with FRAME Dialog-Frame .
  end.
  
  if not bh-act-header = ? 
  then do:
    do ii = 1 to bh-act-header:num-fields - 3:
      bcol[ii] = browse-hdl-act-header:add-like-column('tt-act-header' + '.' + bh-act-header:buffer-field (ii):name, 0, 'FILL-IN').
    end.
    calc-col-hndl = browse-hdl-act-header:add-calc-column("char", "X(10)", "", "Статус") .
    calc-col-hndl2 = browse-hdl-act-header:add-calc-column("char", "X(20)", "", "RegID") .
    browse-hdl-act-header:get-browse-column (1):width-chars = 30.
    browse-hdl-act-header:get-browse-column (2):width-chars = 17.
    browse-hdl-act-header:get-browse-column (3):width-chars = 20.
    browse-hdl-act-header:get-browse-column (4):width-chars = 10.
    browse-hdl-act-header:get-browse-column (5):width-chars = 20.
  end.

  run enable_UI. 
  apply "value-changed" to RADIO-SET-1 in frame {&FRAME-NAME}. 
  
  if not p-select then hide Btn_sel in FRAME Dialog-Frame.
  else do :
      hide Btn_create Btn_chg Btn_del Btn_send RADIO-SET-1 Btn_Edit in FRAME Dialog-Frame.
      assign
        Btn_lkp:x = Btn_lkp:x + 120
        Btn_Ans:x = Btn_Ans:x + 120
      .
      ENABLE Btn_Ans Btn_lkp Btn_sel WITH FRAME Dialog-Frame.
  end.

  wait-for go of frame {&FRAME-NAME}.
end.
run disable_UI.

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
  DISPLAY RADIO-SET-1 f-date f-date-2 
      WITH FRAME Dialog-Frame.
  ENABLE Btn_OK RADIO-SET-1 f-date f-date-2
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE refresh-query Dialog-Frame 
PROCEDURE refresh-query :
    
def var v-proposition  as char no-undo.

if bh-act-header = ? 
  then return .

  assign input frame {&FRAME-NAME}
    f-date
    f-date-2
  .
  
  v-proposition = 
    (if f-date <> ? then " and tt-act-header.date_ >= " + string (f-date) else "") +
    (if f-date-2 <> ? then " and tt-act-header.date_ <= " + string (f-date-2) else "")
    .

if p-select then do :
    qh-act-header:query-close.
    qh-act-header:set-buffers (bh-act-header).
    qh-act-header:query-prepare ( substitute ("for each tt-act-header where tt-act-header.is-sent and tt-act-header.type_ = 'Пересортица' &1 by tt-act-header.date_ descending", v-proposition) ).
    qh-act-header:query-open.
end.
else do :  
  case RADIO-SET-1 :
    when 1  then 
    do:
      qh-act-header:query-close.
      qh-act-header:set-buffers (bh-act-header).
      qh-act-header:query-prepare ( substitute ("for each tt-act-header where not tt-act-header.is-sent &1 by tt-act-header.date_ descending", v-proposition) ).
      qh-act-header:query-open.
      bh-act-header:find-first ( "where tt-act-header.num = " + "'" + v-act-num + "'" + v-proposition) no-error .
    end.
    when 2  then 
    do:
      qh-act-header:query-close.
      qh-act-header:set-buffers (bh-act-header).
      qh-act-header:query-prepare ( substitute ("for each tt-act-header where tt-act-header.is-sent &1 by tt-act-header.date_ descending", v-proposition) ).
      qh-act-header:query-open.
      bh-act-header:find-first ( "where tt-act-header.num = " + "'" + v-act-num + "'" + v-proposition ) no-error .
    end.
  end case.
end.
if bh-act-header:available
  then qh-act-header:reposition-to-rowid ( bh-act-header:rowid ) no-error.
if valid-handle (browse-hdl-act-header) then apply "value-changed" to browse-hdl-act-header.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-row-leave Dialog-Frame 
PROCEDURE proc-row-leave :
  if false then do:
    do ii = 1 to extent (bcol).  
      bcol[ii]:bgcolor = RED_COLOR.
    end.
  end.
end.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
