&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сканирование акцизных марок

Автор: Шкляр Елена
Дата создания: 07/09/07
Author: Elena Shklyar
Creation date: 07/09/07

*/
&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
using ibs.th.bge.egais.*. 
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DECLARATIONS Procedure
using ibs.th.str.alcohol.*.
using ibs.th.str.marking.handlers.*.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сканирование акцизных марок".
{ gbl/objsrv.i }

define input  parameter parparentproc         as  handle              no-undo .
define input  parameter p-doc-code            as  character           no-undo .
define input  parameter p-mode                as character            no-undo .
define input  parameter p-gds-code            as integer              no-undo .
define input  parameter p-message             as character            no-undo .
define output parameter p-mark                as character            no-undo .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ str/marks.i    }
{ bge/egais-mark.i }
{ str/lib-trn.i  }
{ str/lib-calc.i }
{ str/libbcrcn.i }
{ str/trdcalib.i }
{ cmp/croslist.i }
{ gbl/lineattr.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ str/temp_upd.i }
{ utl/gtin.i }
{ rep/gn-extp.i }
{ ref/gds-attr.i    }
{ str/utd-typemark.i }
/*{ str/fbrlib.i }*/
define temp-table tt-mark no-undo
  field alcmark as character.

/* Parameters Definitions ---                                           */

define variable thMarkSts  as class ibs.th.str.marking.sts.mark no-undo.
define variable EDOParSec  as class ibs.th.gbl.env.prmtrs.edo   no-undo.
define variable Marking    as class ibs.th.skt.ControlledClients.marking.

define variable extGdsObj       as class     extgds.
define variable iLang           as integer   no-undo.
define variable p-value-logical as logical no-undo.
define variable p-value-character  as character no-undo.
define variable p-value-date       as date no-undo.
define variable p-value-decimal    as decimal no-undo.
define variable p-value-integer    as integer no-undo.
define variable p-param-type       as character no-undo.
define variable v-tth as handle no-undo .

define variable v-alc-code      as character no-undo .
define variable v-proc-name-err as character no-undo initial 'impmark.txt'. /* Имя лога */
define variable l-error         as logical   no-undo. /* Есть ли ошибки */
define variable is-impfile      as logical   no-undo. /* Есть ли ошибки */
define variable v-user-action   as character no-undo.
define variable v-printed       as logical   no-undo.
define variable Tree            as class     tree   no-undo .  
define buffer t_doc        for ub.trn-doc .
define buffer bf_trn-doc   for ub.trn-doc .
define buffer buf_gen-attr for ub.gen-attr .
define buffer bf_parts     for ub.parts .
define buffer out_parts    for ub.parts .
define buffer bf_gen-attr  for ub.gen-attr .
define buffer bf_marking-lines for ub.marking-lines .
define buffer buf_goods    for ub.goods .
define buffer bf_prod-bc  for ub.prod-bc .
define buffer bf_bar-code for ub.bar-code .

define variable v-scan-str       as character no-undo.
define VARIABLE v-manual         as logical   no-undo .
DEFINE VARIABLE v-timedelay as integer no-undo .
define variable v-is-return as logical no-undo init no .
define variable v-gds-code as integer no-undo .
define variable v-free-qnty as decimal no-undo .
define variable v-free-part-qnty as decimal no-undo .
define variable v-scan-qnty as decimal no-undo .

define variable varvalue as character no-undo.
define variable vartype  as character no-undo.

define stream str-err .
define stream in-stream.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-imp v-mark 
&Scoped-Define DISPLAYED-OBJECTS v-mark F-text 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO 
  LABEL "&Выход" 
  SIZE 10 BY 1
  BGCOLOR 8 .

DEFINE BUTTON b-imp 
  LABEL "Импорт" 
  SIZE 10 BY 1.

DEFINE VARIABLE F-text AS CHARACTER FORMAT "X(256)":U 
  VIEW-AS FILL-IN 
  SIZE 83 BY 1.25
  FGCOLOR 12 NO-UNDO.

DEFINE VARIABLE v-mark AS CHARACTER FORMAT "X(256)":U 
  LABEL "Марка" 
  VIEW-AS FILL-IN 
  SIZE 80 BY 1 
  BGCOLOR 15 NO-UNDO.
define variable mWork as logical no-undo.

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
  b-exit AT ROW 1 COL 1
  b-imp AT ROW 1 COL 32.5 WIDGET-ID 2
  v-mark AT ROW 2.71 COL 7.5 COLON-ALIGNED
  F-text AT ROW 4.24 COL 4 NO-LABEL WIDGET-ID 224
  SPACE(2.59) SKIP(0.70)
  WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
  SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
  TITLE "Сканирование марок"
  DEFAULT-BUTTON b-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN 
  FRAME Dialog-Frame:SCROLLABLE = FALSE
  FRAME Dialog-Frame:HIDDEN     = TRUE.

/* SETTINGS FOR FILL-IN F-text IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Сканирование марок */
  DO:
    APPLY "END-ERROR":U TO SELF.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Выход */
  DO:
    mWork = false.
    if p-mode = {&add-def} then 
    do:
      run save_update  no-error.
      if error-status:error
      then
         return no-apply.
    end.
    else 
    do:
      define variable vcodident as character no-undo.
      vcodident = GetCodeIdent(v-mark:screen-value).
      p-mark = vcodident .
    end.  
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON return OF b-exit IN FRAME Dialog-Frame /* Выход */
  DO:
     mWork = false.
    if p-mode = {&add-def} then 
    do:
      run save_update .
      if error-status:error
      then
         return no-apply.
    end.
    else 
    do:
      define variable vcodident as character no-undo.
      vcodident = GetCodeIdent(v-mark:screen-value).
      p-mark = vcodident .
    end.  
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-imp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-imp Dialog-Frame
ON choose OF b-imp IN FRAME Dialog-Frame /* Импорт */
  DO:
    is-impfile = true.
    run proc-choose-file no-error.
    is-impfile = false.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-mark Dialog-Frame
ON ENTRY OF v-mark IN FRAME Dialog-Frame /* Марка */
  DO:
    run LoadKeyboardLayoutA (input v-scan-str, input 0, output iLang).
    run adm/shattri.p (
               input "get":U
               ,input  v-cntxt-obj-type /*p-obj-type*/
               ,input  v-cntxt-obj-code /*p-obj-code*/
               ,input  {&attr-marking}
               ,input  {&attr-marking_rus-key} /*p-param-code*/
               ,output p-value-character
               ,output p-value-date
               ,output p-value-decimal
               ,output p-value-integer
               ,output p-value-logical
               ,output p-param-type
               ,input-output table-handle v-tth
               ) no-error . 
    IF p-value-logical = yes THEN  iLang = 68748313.

    run ActivateKeyboardLayout (input iLang, input 0).
    
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-mark Dialog-Frame
ON LEAVE OF v-mark IN FRAME Dialog-Frame /* Марка */
  DO:
    assign frame {&frame-name} v-mark .
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-mark Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF v-mark IN FRAME Dialog-Frame /* Марка */
  DO:
    if p-mode = {&add-def} then 
    do:
      run save_update .
    end.
    else 
    do:
      apply "CHOOSE" to b-exit in frame {&frame-name}.
    end.  
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-mark Dialog-Frame
ON return OF v-mark IN FRAME Dialog-Frame /* Марка */
  DO:
    if p-mode = {&add-def} then 
    do:
      run save_update .
    end.
    else 
    do:
      apply "CHOOSE" to b-exit in frame {&frame-name}.
    end.  
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME v-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-mark Dialog-Frame
ON any-printable OF v-mark IN FRAME Dialog-Frame /*              */
do:
  run proc-any-key.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON any-printable OF b-exit IN FRAME Dialog-Frame /*              */
do:
  run proc-any-key.
end.

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
  
  thMarkSts = ObjSrv:Env:Marking:Sts:Mark.
      
  find first t_doc no-lock where t_doc.doc-code = p-doc-code no-error .
  EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(t_doc.obj-type, t_doc.obj-code).
  Marking = new ibs.th.skt.ControlledClients.marking().
  
  { str/tdat-val.i
    t_doc.doc-code
    {&trdcattr-is-return}
    varvalue
    vartype
    no-error
  }
  if varvalue = "yes" then do:
    v-is-return = yes .
    find first bf_parts no-lock where recid(bf_parts) = integer(p-message) no-error .
    p-message = "" .
    if available bf_parts
    then do :
      find first buf_goods no-lock where buf_goods.artic     = bf_parts.artic
                                     and buf_goods.prod-type = bf_parts.prod-type
                                     and buf_goods.prod-code = bf_parts.prod-code
                                     .
      frame Dialog-Frame:title = "Сканирование марок по товару " + string(buf_goods.gds-code) + " " + buf_goods.gds-name .
      
      v-free-part-qnty = bf_parts.fact-qnty .
      for each bf_gen-attr no-lock where bf_gen-attr.table-name = {&table_parts}
                                     and bf_gen-attr.attr-code  = "in-part-key"
                                     and bf_gen-attr.attr-value = {key/parts.i bf_parts },
      first out_parts no-lock where out_parts.obj-type  = entry(2, bf_gen-attr.p-key, {&delim-key})
                                and out_parts.obj-code  = integer(entry(3, bf_gen-attr.p-key, {&delim-key}))
                                and out_parts.artic     = entry(4, bf_gen-attr.p-key, {&delim-key})
                                and out_parts.prod-type = entry(5, bf_gen-attr.p-key, {&delim-key})
                                and out_parts.prod-code = integer(entry(6, bf_gen-attr.p-key, {&delim-key}))
                                and out_parts.in-code   = entry(7, bf_gen-attr.p-key, {&delim-key})
                                and out_parts.out-code  = entry(8, bf_gen-attr.p-key, {&delim-key})
                                and out_parts.part-code = entry(9, bf_gen-attr.p-key, {&delim-key})
      :
        v-free-part-qnty = v-free-part-qnty - out_parts.fact-qnty .
      end .
      if v-free-part-qnty < 0 then v-free-part-qnty = 0 .

      run calcMarks in this-procedure
        (bf_parts.obj-type, bf_parts.obj-code, buffer buf_goods, output v-free-qnty, output v-scan-qnty).
                                     
      p-message = "Доступно по партии: " + string(v-free-part-qnty) +
             "     Книжный остаток: " + string(v-free-qnty) +
             "     Просканировано: " + string(v-scan-qnty) .
    end .
  end.
  
  if p-gds-code <> ? then
  do:
    find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error.
    
    if avail buf_goods then
    do:  
      run calcMarks in this-procedure
        (t_doc.obj-type, t_doc.obj-code, buffer buf_goods, output v-free-qnty, output v-scan-qnty).

      p-message = "Книжный остаток: " + string(v-free-qnty) +
             "     Просканировано: " + string(v-scan-qnty) .
    end.
  end.
  
  if v-free-qnty = 0 then
  do:
    message "Количество просканированных марок достигло книжного остатка." view-as alert-box.
    return.
  end.
  
  
  F-text = p-message .  
  Tree = ObjSrv:Lib:MarkingTree .     
  run LoadKeyboardLayoutA (input v-scan-str, input 0, output iLang).
  run adm/shattri.p (
               input "get":U
               ,input  v-cntxt-obj-type /*p-obj-type*/
               ,input  v-cntxt-obj-code /*p-obj-code*/
               ,input  {&attr-marking}
               ,input  {&attr-marking_rus-key} /*p-param-code*/
               ,output p-value-character
               ,output p-value-date
               ,output p-value-decimal
               ,output p-value-integer
               ,output p-value-logical
               ,output p-param-type
               ,input-output table-handle v-tth
               ) no-error . 
  IF p-value-logical = yes THEN  iLang = 68748313.

  run ActivateKeyboardLayout (input iLang, input 0).     
  RUN enable_UI.
  apply "entry" to v-mark in FRAME {&FRAME-NAME}.
  
  if v-is-return
  then do :
    hide b-imp in frame {&FRAME-NAME}.
  end .
  
  find first trn-doc exclusive-lock where trn-doc.doc-code = p-doc-code no-error .  
    if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code):IsManual
    then v-manual = yes.
    else do:
        v-manual = no .
        v-mark:READ-ONLY IN FRAME {&frame-name}        = TRUE .
    end. 
    mWork = true.
/*    run gbl\inidebug.p.*/
  do while mWork:
     WAIT-FOR GO OF FRAME {&FRAME-NAME} pause 1.
     run gbl/readcom.p.
     if length(return-value) > 0
     then do:
        v-scan-str = return-value.
        v-mark:screen-value in frame {&frame-name} = v-scan-str.
     end.
  end.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ActivateKeyboardLayout Dialog-Frame 
PROCEDURE ActivateKeyboardLayout external "user32" :
  define input parameter P1 as long.
  define input parameter P2 as long.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calcMarks Dialog-Frame 
PROCEDURE calcMarks :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  define input  parameter p-obj-type as  character no-undo. 
  define input  parameter p-obj-code as  integer   no-undo. 
  define parameter buffer b_goods    for ub.goods. 
  define output parameter o-free-qnty as  decimal   no-undo. 
  define output parameter o-scan-qnty as  decimal   no-undo. 
  
  define buffer bf_gds-obj  for ub.gds-obj .
  define buffer buf_parts         for ub.parts .

  find first bf_gds-obj no-lock where bf_gds-obj.obj-type  = p-obj-type
                                  and bf_gds-obj.obj-code  = p-obj-code
                                  and bf_gds-obj.artic     = b_goods.artic
                                  and bf_gds-obj.prod-type = b_goods.prod-type
                                  and bf_gds-obj.prod-code = b_goods.prod-code
                                  no-error .
  if available bf_gds-obj then
    o-free-qnty = bf_gds-obj.free-qnty .

  for each buf_parts no-lock where buf_parts.out-code  = t_doc.doc-code
                               and buf_parts.obj-type  = t_doc.obj-type
                               and buf_parts.obj-code  = t_doc.obj-code
                               and buf_parts.artic     = b_goods.artic
      
  :
    o-scan-qnty = o-scan-qnty +  buf_parts.qnty .
  end .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE dispmessage Dialog-Frame 
PROCEDURE dispmessage :
do with frame {&frame-name}:
  define input parameter p-str as character no-undo.
  
  if is-impfile
    then 
  do:
    put stream str-err unformatted
      p-str
      skip.
    l-error = yes .    
  end.
  else 
  do:
    message p-str view-as alert-box information title "Информация".
  end.
  assign 
    v-mark              = ""
    v-mark:screen-value = ""
    v-scan-str          = ""
    p-mark              = ""
  .
end.
  
  
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
  DISPLAY v-mark F-text
    WITH FRAME Dialog-Frame.
  if p-mode = {&add-def} then 
  do:
    enable b-imp  with frame Dialog-Frame .
  end.  
  ENABLE b-exit v-mark 
    WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE LoadKeyboardLayoutA Dialog-Frame 
PROCEDURE LoadKeyboardLayoutA external "user32" :
  define input  parameter P1 as char.
  define input  parameter P2 as long.
  define return parameter pret as long.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-choose-file Dialog-Frame 
PROCEDURE proc-choose-file :
  /*Процедура выбора файла*/
  /* Выбор файла */

  if search (v-proc-name-err) <> ? then 
  do:
    os-delete value(v-proc-name-err).
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
    output stream str-err to value(v-proc-name-err)  APPEND .
    
    input stream in-stream from value(search (vCh)).

    /*DISABLE TRIGGERS FOR LOAD OF Customer.*/
    rpt_:
    REPEAT WITH FRAME {&FRAME-NAME}: 
      import stream in-stream v-mark.
      v-mark:screen-value = v-mark.
      run save_update .
    END. 
    INPUT CLOSE. 
    output stream str-err close.
    
    message substitute ("Не все марки были загружены") view-as alert-box.
    
    if l-error then 
    do: 
      if search (v-proc-name-err) <> ? then 
      do:
        run gbl/prnfilen.w
          (input  substitute ("Не все марки были загружены")
          ,input  0
          ,input  v-proc-name-err
          ,input  7
          ,output v-user-action
          ,output v-printed
          ).
      end.
    end.
    else 
    do:
      message substitute("Импорт акцизных марок завершен успешно.")
        view-as alert-box.
    end.  
  END.
  
  else os-delete value(v-proc-name-err). /* Если нет - удаляем лог */

   
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/*                                                                     */
/*&Scoped-define SELF-NAME b-cancel                                    */
/*&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cancel Dialog-Frame      */
/*ON any-printable OF b-cancel IN FRAME Dialog-Frame /*              */*/
/*do:                                                                  */
/*                                                                     */
/*  run proc-any-key.                                                  */
/*                                                                     */
/*end.                                                                 */
/*                                                                     */
/*/* _UIB-CODE-BLOCK-END */                                            */
/*&ANALYZE-RESUME                                                      */

/*&Scoped-define SELF-NAME B_mark                                    */
/*&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B_mark Dialog-Frame      */
/*ON any-printable OF B_mark IN FRAME Dialog-Frame /*              */*/
/*do:                                                                */
/*                                                                   */
/*  run proc-any-key.                                                */
/*                                                                   */
/*end.                                                               */
/*                                                                   */
/*/* _UIB-CODE-BLOCK-END */                                          */
/*&ANALYZE-RESUME                                                    */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save_update Dialog-Frame 
PROCEDURE save_update :
  define variable v-error      as logical   no-undo init no.
  define variable l-error      as logical   no-undo init no.
  define variable v-error-lang as logical   no-undo init no.
  define variable v-ok         as logical   no-undo .
          
  define variable ii           as integer   no-undo .
  define variable v-parts      as character no-undo .
  define variable gds-rec      as recid     no-undo .
  define variable v-gds-code   as integer   no-undo .
  define variable v-host-code  like sysconf.host-code no-undo.
  define variable v-tax-date   as date      no-undo.
  define variable v-vat-pc     like ub.doc-line.vat-pc no-undo.
  define variable v-slt-pc     like ub.doc-line.slt-pc no-undo.
  define variable ungroup      as logical   no-undo . 
  define variable chg-qnty     as integer   no-undo .
  define variable v-level      as integer   no-undo .
  define variable v-exp-date-txt as character no-undo .
  
  define buffer buf_doc-line for ub.doc-line .
  define buffer buf_parts    for ub.parts .
  define buffer out_parts    for ub.parts .
/*  define buffer buf_goods    for ub.goods .*/
  define buffer buf_goods-alt for ub.goods .
  define buffer buf_gds-prt  for ub.gds-prt .
  define buffer cpl_gds-dtl  for ub.gds-dtl .
  define variable v-GTIN as character no-undo .
  define variable v-GTIN-qnty as integer no-undo .
  define variable v-cis-gds-code as integer no-undo .
  define variable v-alt-gds-code as integer no-undo .
  define variable vcodident      as character no-undo.
  define variable vStatusCheckMark as integer no-undo.
  define variable vRunedOffLineCheck as logical no-undo.
  define buffer buf_marking-lines for ub.marking-lines.
  define buffer buf_marking       for ub.marking.
  define buffer b_marking-lines   for ub.marking-lines.
  define buffer b_trn-doc         for ub.trn-doc.
  define buffer buf_mark_goods    for ub.goods.
  define variable v-mark-weight   as decimal no-undo .
  define variable v-isweighed     as logical no-undo .
   
   if v-mark:screen-value in frame {&frame-name} = ""
    then do:
      v-mark:screen-value in frame {&frame-name} = v-scan-str.
      v-scan-str = "". 
    end.

  assign 
    v-mark = v-mark:screen-value in frame {&frame-name} .

  if v-mark <> "" then 
  do:
/*     if length(v-mark) < 29                                                              */
/*     then do:                                                                            */
/*        run dispmessage ("Данная последовательность не является маркой. Введите марку.").*/
/*        return error .                                                                   */
/*     end.                                                                                */

    vcodident = GetCodeIdent(v-mark).
    p-mark = vcodident .
      
    if v-is-return
    and (vcodident = ? or vcodident = "")
    then do :
      p-mark = v-mark .
    end .

    find first marking where marking.mark begins vcodident
      and vcodident > ""
      no-lock no-error  .

    if not avail marking or marking.unit-ext <> "LEVEL2" then
    do:
      v-GTIN = getGtinByDM(p-mark) .
      if v-GTIN = "" then
      do:
        run dispmessage ("Марка не распознана.").
        return error.
      end.
      v-cis-gds-code = getGdsCodeByGtin(v-GTIN) .
      if v-cis-gds-code = 0 or v-cis-gds-code = ? then
      do:
        run dispmessage ("Не определен товар.").
        return error.
      end.
      if avail buf_goods and buf_goods.gds-code <> v-cis-gds-code then
      do:
        find first buf_mark_goods where
                   buf_mark_goods.gds-code = v-cis-gds-code no-lock no-error.
        run dispmessage (substitute("Просканированная марка принадлежит другому товару, необходимо сканировать товар &1 &2.", buf_goods.gds-code, buf_goods.gds-name)).
        return error.
      end.
      find first bf_prod-bc no-lock where bf_prod-bc.b-str = v-GTIN
                                      and bf_prod-bc.bc-on
                                      no-error.
      if not available bf_prod-bc
      then do :
        run dispmessage ("В системе не найден доп. код " + v-GTIN + " (GTIN)").
        return .
      end .
      find first bf_bar-code no-lock where bf_bar-code.b-code = bf_prod-bc.b-code no-error .
      if not available bf_bar-code
      then do :
        run dispmessage ("В системе не найден бар-код " + string(bf_prod-bc.b-code) + "!!!").
        return .
      end .

      if bf_bar-code.cli-base-rate <> 1 and can-do({&expense_write-off}, t_doc.doc-type) and
         v-free-qnty < bf_bar-code.cli-base-rate then
      do: /* отсканирована упаковка и док-т расхода или списания и кол-во в упаковке < книжного остатка*/
        run dispmessage ("Марка групповой упаковки не может быть добавлена в документ, т.к. будет превышено количество товара по документу.~nСканируйте потребительские упаковки").
        return.
      end.
      v-isweighed = WghProdVariable(v-cntxt-obj-type, v-cntxt-obj-code, v-cis-gds-code) .
      if v-isweighed then do:
         if not avail marking 
         then do:
            run dispmessage ("Марка не найдена в БД").
            return .    
         end.    
         v-mark-weight = MarkWeight(marking.mark).
         if v-mark-weight = 0
         or v-mark-weight = ?
         then do :
            run dispmessage ("Марка не может быть добавлена, т.к. в БД отсутствует ее вес.").
            return .
         end .
       end.         
    end.

    if can-find(bf_marking-lines no-lock where bf_marking-lines.mark = p-mark
                                           and bf_marking-lines.out-code = t_doc.doc-code)
/*      and v-is-return*/
    then do :
      run dispmessage ("КМ добавлен в документ ранее").
      return .
    end . 

    if v-is-return then 
    do:
      if available marking then
      do:
        if marking.unit-ext <> "UNIT"
        and marking.unit-ext <> ?
        and marking.unit-ext <> ""
        then do :
          run dispmessage ("Некорректный тип упаковки. Сканируйте КМ потребительской упаковки.").
          return.
        end .
        if marking.sts <> thMarkSts:FreeZone:KeyIntDB and
           marking.sts <> thMarkSts:ReturnLock:KeyIntDB then 
        do:
          run dispmessage (substitute("Марка в статусе <&1> не может быть возвращена поставщику.",
                           thMarkSts:GetLabel(marking.sts))
                           ).
          return.
        end.
      end.
        
      if available bf_parts
      then do :
        find first buf_goods no-lock where buf_goods.artic = bf_parts.artic
                                       and buf_goods.prod-type = bf_parts.prod-type
                                       and buf_goods.prod-code = bf_parts.prod-code
                                       .
/*        RUN gds-attr-value (       */
/*          INPUT buf_goods.gds-code,*/
/*          INPUT {&attr-mark-type}, */
/*          OUTPUT varvalue,         */
/*          OUTPUT vartype           */
/*        ).                         */
        if available marking
/*        and not ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code):GetIsArticForType(varvalue)*/
        and not (num-entries(bf_parts.part-code, "_") = 2
                 and (length(entry(1, bf_parts.part-code, "_")) = 8
                  or length(entry(1, bf_parts.part-code, "_")) = 12
                  or length(entry(1, bf_parts.part-code, "_")) = 13
                  or length(entry(1, bf_parts.part-code, "_")) = 14))
        then do :
/*          if marking.gds-code <> buf_goods.gds-code                            */
/*          and marking.gds-code > 0                                             */
/*          then do :                                                            */
/*            run dispmessage ("Просканированный КМ относится к другому товару").*/
/*            return .                                                           */
/*          end .                                                                */
          find first buf_marking-lines no-lock where buf_marking-lines.gds-code  = buf_goods.gds-code
                                                 and buf_marking-lines.obj-type  = bf_parts.obj-type
                                                 and buf_marking-lines.obj-code  = bf_parts.obj-code
                                                 and buf_marking-lines.in-code   = bf_parts.in-code
                                                 and buf_marking-lines.out-code  = bf_parts.out-code
                                                 and buf_marking-lines.part-code = bf_parts.part-code
                                                 and buf_marking-lines.mark      = marking.mark
                                                 no-error .
          if not available buf_marking-lines
          then do :
            if t_doc.reason-code = 25 /* Корректировка поступления */
            then do :
/*              message "Просканированный КМ отсутствует в выбранной партии" view-as alert-box .*/
              run dispmessage ("Просканированный КМ отсутствует в выбранной партии").
              return .
            end .
            if t_doc.reason-code = 23 /* Обратная продажа */
            then do :
              message "КМ отсутствует в выбранной партии, продолжить оформление возврата упаковки?" view-as alert-box question buttons yes-no update v-ok .
              if not v-ok
              then do :
                assign 
                  v-mark              = ""
                  v-mark:screen-value = ""
                  v-scan-str          = ""
                  p-mark              = ""
                .
                return .
              end .
            end .
          end .
        end .
        else do :
/*          v-GTIN = getGtinByDM(p-mark) .                                            */
/*          v-cis-gds-code = getGdsCodeByGtin(v-GTIN) .                               */
/*          if v-cis-gds-code = ?                                                     */
/*          then do :                                                                 */
/*            run dispmessage ("GTIN " + v-GTIN + " не привязан ни к какому товару!").*/
/*            return .                                                                */
/*          end .                                                                     */
/*          if v-cis-gds-code <> buf_goods.gds-code                                   */
/*          then do :                                                                 */
/*            run dispmessage ("GTIN " + v-GTIN + " привязан к другому товару!").     */
/*            return .                                                                */
/*          end .                                                                     */
          if num-entries(bf_parts.part-code, "_") = 2
          then do :
            if v-GTIN <> entry(1, bf_parts.part-code, "_")
            then do :
              if t_doc.reason-code = 25 /* Корректировка поступления */
              then do :
                run dispmessage ("Возврат упаковки с GTIN " + v-GTIN + " по выбранной партии не возможен").
                return .
              end .
              if t_doc.reason-code = 23 /* Обратная продажа */
              then do :
                message ("Упаковка с GTIN " + v-GTIN + " отсутствует в выбранной партии, продолжить оформление возврата упаковки?") view-as alert-box question buttons yes-no update v-ok .
                if not v-ok
                then do :
                  assign 
                    v-mark              = ""
                    v-mark:screen-value = ""
                    v-scan-str          = ""
                    p-mark              = ""
                  .
                  return .
                end .
              end .
            end .
          end .
          else do :
            if t_doc.reason-code = 25 /* Корректировка поступления */
            then do :
              run dispmessage ("Возврат упаковки с GTIN " + v-GTIN + " по выбранной партии не возможен").
              return .
            end .
            if t_doc.reason-code = 23 /* Обратная продажа */
            then do :
              message ("Упаковка с GTIN " + v-GTIN + " отсутствует в выбранной партии, продолжить оформление возврата упаковки?") view-as alert-box question buttons yes-no update v-ok .
              if not v-ok
              then do :
                assign 
                  v-mark              = ""
                  v-mark:screen-value = ""
                  v-scan-str          = ""
                  p-mark              = ""
                .
                return .
              end .
            end .
          end .
        end .
      end .  /* if available bf_parts */
    end.

    if available marking
    then do:
      v-exp-date-txt = "" .
/*      v-exp-date-txt = marking:ChekExpirationDate(t_doc.obj-type, t_doc.obj-code, buffer marking).*/
      
      if marking.sts = thMarkSts:Reserved:KeyIntDB then
      do:
        run dispmessage (substitute("Операция невозможна. Статус марки – <&1>. ", thMarkSts:GetLabel(marking.sts)) + v-exp-date-txt).
        return.
      end.
      
      if marking.unit-ext = "LEVEL2" and
        t_doc.ext-doc-type = {&TDEDT_Spi_Vnesh}
      then do:
        run dispmessage ("Некорректный тип упаковки. Сканируйте КМ групповой или потребительской упаковки.").
        return.
      end.

      case t_doc.ext-doc-type:
      when {&TDEDT_Ras_Vnesh} then
      do:  /* Расход внешний. НЕ возврат */
        if not v-is-return and 
           marking.sts <> thMarkSts:FreeZone:KeyIntDB and
           marking.sts <> thMarkSts:Checked_:KeyIntDB then 
        do:
          run dispmessage (substitute("Операция невозможна. Статус марки – <&1>. ", thMarkSts:GetLabel(marking.sts)) + v-exp-date-txt).
          return.
        end.  
                
        /*vStatusCheckMark = marking:checkScanMark(t_doc.obj-code, v-mark, vcodident, no, output vRunedOffLineCheck) no-error.
        if error-status:error then
        do:
            run dispmessage (
              substitute("Марка не может быть списана,~nт.к. возникла ошибка при проверке: &1.",error-status:get-message(1))
              ).
            return.
        end.
        if vStatusCheckMark = 2 then
        do:
            run dispmessage (
              "Проверка марки не выполнена, марка не может быть добавлена в документ."
              ).
            return.
        end.
        if vStatusCheckMark = 0 then
        do:
            run dispmessage (
              "Проверка марки дала отрицательный результат, марка не может быть добавлена в документ."
              ).
            return.
        end.*/
      end.
      when {&TDEDT_Ras_Perem} then
      do:
        if marking.sts <> thMarkSts:FreeZone:KeyIntDB then 
        do:
          run dispmessage (substitute("Операция невозможна. Статус марки – <&1>. ", thMarkSts:GetLabel(marking.sts)) + v-exp-date-txt).
          return.
        end.  
      end.
      when {&TDEDT_Spi_Vnesh} then
      do:
        if marking.sts = thMarkSts:WrittenOff:KeyIntDB then 
        do:
          run dispmessage ("Товар списан ранее." + v-exp-date-txt).
          return.
        end.  
        if marking.sts = thMarkSts:DeliveryControl:KeyIntDB then 
        do:
          run dispmessage ("Товар еще не оприходован." + v-exp-date-txt).
          return.
        end.  
        if marking.sts = thMarkSts:Ungrouped:KeyIntDB then 
        do:
          run dispmessage ("Упаковка разгруппирована. Необходимо сканировать индивидуальные товары." + v-exp-date-txt).
          return.
        end.  
        if marking.sts = thMarkSts:UsedInProduction:KeyIntDB then 
        do:
          run dispmessage ("Товар использован для производства.~n" +
                           " В списание необходимо добавить товар-ингредиент,~n" + 
                           "для которого не требуется сканирование марок").
          return.
        end.  
        if marking.sts = thMarkSts:Moved:KeyIntDB then
        do:
          run dispmessage ("Товар перемещен на другой АЗК." + v-exp-date-txt).
          return.
        end. 
        if marking.sts <> thMarkSts:OutZone:KeyIntDB and
           marking.sts <> thMarkSts:Checked_:KeyIntDB and
           marking.sts <> thMarkSts:SaleLock:KeyIntDB and
           marking.sts <> thMarkSts:ReturnLock:KeyIntDB and
           marking.sts <> thMarkSts:FreeZone:KeyIntDB and
           marking.sts <> thMarkSts:Moved:KeyIntDB and
           marking.sts <> thMarkSts:OutOfInventory:KeyIntDB then
        do:
          run dispmessage (substitute("Операция невозможна. Статус марки – <&1>. ",thMarkSts:GetLabel(marking.sts)) + v-exp-date-txt).
          return.
        end.
        if marking.sts = thMarkSts:OutZone:KeyIntDB or
           marking.sts = thMarkSts:SaleLock:KeyIntDB or
           marking.sts = thMarkSts:SaleWaitLock:KeyIntDB or
           marking.sts = thMarkSts:Moved:KeyIntDB or
           marking.sts = thMarkSts:OutOfInventory:KeyIntDB then
        do:
          for each b_marking-lines no-lock where
                   b_marking-lines.mark    =  marking.mark
               and b_marking-lines.out-code <> t_doc.doc-code,
              first b_trn-doc no-lock where
                    b_trn-doc.doc-code     =  b_marking-lines.out-code
                and b_trn-doc.ext-doc-type =  {&TDEDT_Spi_Vnesh}
                and b_trn-doc.status_      <> {&fact}:
              run dispmessage (substitute("КМ в статусе <&1>, марка не может быть добавлена повторно. ",thMarkSts:GetLabel(marking.sts)) + v-exp-date-txt).
              return.
          end.
        end.    
      end.
      end case.
      
      if avail bf_bar-code and bf_bar-code.cli-base-rate <> 1 then
      do:     /* отсканирована упаковка */
        for each buf_marking where
                 buf_marking.mark-parent begins p-mark
            no-lock:
          v-GTIN-qnty = v-GTIN-qnty + 1.
        end.  
        if v-GTIN-qnty <> bf_bar-code.cli-base-rate then
        do:
          run dispmessage (
            substitute("Групповая упаковка с &1 составом. Для добавления в документ сканируйте марки потребительских упаковок.",
                       if v-GTIN-qnty = 0 then "неизвестным" else "неполным")
            ).
          return.
        end.
      end.
      
      if v-exp-date-txt > ""
      then do :
        run dispmessage (v-exp-date-txt) .
        return .
      end .

/*      RUN gds-attr-value (                                                                         */
/*      INPUT v-cis-gds-code,                                                                        */
/*      INPUT {&attr-mark-type},                                                                     */
/*      OUTPUT varvalue,                                                                             */
/*      OUTPUT vartype                                                                               */
/*      ).                                                                                           */
/*                                                                                                   */
/*      if varvalue = "tabak"                                                                        */
/*      then do :                                                                                    */
/*        v-level = ? .                                                                              */
/*        v-level = getlevelByCodId(p-mark) no-error .                                               */
/*        if v-level <> ?                                                                            */
/*        and v-level <> 1                                                                           */
/*        then do :                                                                                  */
/*          if available marking                                                                     */
/*          and marking.unit-ext = "UNIT"                                                            */
/*          then do : end .                                                                          */
/*          else do :                                                                                */
/*            run dispmessage ("Некорректный тип упаковки. Сканируйте КМ потребительской упаковки.").*/
/*            return error.                                                                          */
/*          end .                                                                                    */
/*        end .                                                                                      */
/*      end .                                                                                        */
/*      else do :                                                                                    */
/*        find first bf_prod-bc no-lock where bf_prod-bc.b-str = v-GTIN                            */
/*                                        and bf_prod-bc.bc-on                                     */
/*                                        no-error.                                                */
/*        if not available bf_prod-bc                                                              */
/*        then do :                                                                                */
/*          run dispmessage ("В системе не найден доп. код " + v-GTIN + " (GTIN)").                */
/*          return .                                                                               */
/*        end .                                                                                    */
/*        find first bf_bar-code no-lock where bf_bar-code.b-code = bf_prod-bc.b-code no-error .   */
/*        if not available bf_bar-code                                                             */
/*        then do :                                                                                */
/*          run dispmessage ("В системе не найден бар-код " + string(bf_prod-bc.b-code) + "!!!").  */
/*          return .                                                                               */
/*        end .                                                                                    */
/*        if bf_bar-code.cli-base-rate <> 1                                                        */
/*        then do :                                                                                */
/*          run dispmessage ("Некорректный тип упаковки. Сканируйте КМ потребительской упаковки.").*/
/*          return .                                                                               */
/*        end .                                                                                    */
/*      end .                                                                                      */
      
    end.    /* if avail marking */  
    else 
    do:
      if bf_bar-code.cli-base-rate <> 1 then
      do:     /* отсканирована упаковка */
          run dispmessage (
            "Групповая упаковка с неизвестным составом. Для добавления в документ сканируйте марки потребительских упаковок."
            ).
          return.
      end.

/*      vStatusCheckMark = marking:checkScanMark(t_doc.obj-code, v-mark, vcodident, no, output vRunedOffLineCheck) no-error.                       */
/*      if error-status:error then                                                                                                                 */
/*      do:                                                                                                                                        */
/*          run dispmessage (                                                                                                                      */
/*            substitute("Марка не найдена в базе ТН и не может быть списана,~nт.к. возникла ошибка при проверке: &1.",error-status:get-message(1))*/
/*            ).                                                                                                                                   */
/*          return.                                                                                                                                */
/*      end.                                                                                                                                       */
/*      if vStatusCheckMark = 2 then                                                                                                               */
/*      do:                                                                                                                                        */
/*          run dispmessage (                                                                                                                      */
/*            "Проверка марки не выполнена, марка отсутствует в БД и не может быть добавлена в документ."                                          */
/*            ).                                                                                                                                   */
/*          return.                                                                                                                                */
/*      end.                                                                                                                                       */
/*      if vStatusCheckMark = 0 then                                                                                                               */
/*      do:                                                                                                                                        */
/*          run dispmessage (                                                                                                                      */
/*            "Проверка марки дала отрицательный результат, марка не может быть добавлена в документ."                                             */
/*            ).                                                                                                                                   */
/*          return.                                                                                                                                */
/*      end.                                                                                                                                       */
      create ub.marking.
      assign
        ub.marking.mark     = vcodident
        ub.marking.sts      = thMarkSts:FreeZone:KeyIntDB
        ub.marking.box-qnty = 1
      .
      
/*      RUN ProcAlcCode IN THIS-PROCEDURE (input v-mark, output v-alc-code, output l-error, output v-error-lang) no-error.                                                                                                    */
/*                                                                                                                                                                                                                            */
/*                                                                                                                                                                                                                            */
/*      if v-error-lang then                                                                                                                                                                                                  */
/*      do:                                                                                                                                                                                                                   */
/*        run dispmessage ("Не корректно считана акцизная марка, перед считыванием переключите клавиатуру на английскую раскладку.").                                                                                         */
/*      end.                                                                                                                                                                                                                  */
/*      else                                                                                                                                                                                                                  */
/*      do:                                                                                                                                                                                                                   */
/*        if l-error then                                                                                                                                                                                                     */
/*        do:                                                                                                                                                                                                                 */
/*          run dispmessage (substitute ("Алког. код не преобразовывается в десятичную систему из акцизной марки: &1", v-mark)).                                                                                              */
/*          v-alc-code = "".                                                                                                                                                                                                  */
/*        end.                                                                                                                                                                                                                */
/*        else                                                                                                                                                                                                                */
/*        do:                                                                                                                                                                                                                 */
/*          /*Ищем товар по алкокоду*/                                                                                                                                                                                        */
/*          if     not v-alc-code = ""                                                                                                                                                                                        */
/*            then                                                                                                                                                                                                            */
/*          do:                                                                                                                                                                                                               */
/*            extGdsObj = new ExtGds (true).                                                                                                                                                                                  */
/*            extGdsObj:OpenQueryExtGds(0, v-alc-code).                                                                                                                                                                       */
/*          end.                                                                                                                                                                                                              */
/*          if valid-object (extGdsObj)                                                                                                                                                                                       */
/*            and extGdsObj:NumBundles = 0 then                                                                                                                                                                               */
/*          do:                                                                                                                                                                                                               */
/*            run dispmessage (substitute ("Для алког. кода &1 не найден товар (не установлено соответствие)", v-alc-code)).                                                                                                  */
/*          end.                                                                                                                                                                                                              */
/*          else                                                                                                                                                                                                              */
/*          do:                                                                                                                                                                                                               */
/*            /*Проверяем есть ли марка в базе*/                                                                                                                                                                              */
/*            find first buf_gen-attr no-lock where buf_gen-attr.attr-code = v-mark and buf_gen-attr.table-name = {&excise-mark} no-error .                                                                                   */
/*            if not available (buf_gen-attr)                                                                                                                                                                                 */
/*              then                                                                                                                                                                                                          */
/*            do:                                                                                                                                                                                                             */
/*              run dispmessage ("Марка: " + v-mark + " не зарегистрирована в системе.").                                                                                                                                     */
/*            end.                                                                                                                                                                                                            */
/*            else                                                                                                                                                                                                            */
/*            do:                                                                                                                                                                                                             */
/*              def var v-reserv as logical no-undo init false.                                                                                                                                                               */
/*              find first buf_gen-attr no-lock where                                                                                                                                                                         */
/*                buf_gen-attr.table-name = {&excise-mark}                                                                                                                                                                    */
/*                and buf_gen-attr.attr-code = v-mark                                                                                                                                                                         */
/*                and not entry(8,buf_gen-attr.p-key,{&delim-key}) = {&free-code}                                                                                                                                             */
/*                and entry(8,buf_gen-attr.p-key,{&delim-key}) <> entry(7,buf_gen-attr.p-key,{&delim-key}) no-error .                                                                                                         */
/*              if available (buf_gen-attr) then                                                                                                                                                                              */
/*              do:                                                                                                                                                                                                           */
/*                run dispmessage ( string ("Марка: " + v-mark + {&new-line} +                                                                                                                                                */
/*                  "уже зарезервирована в системе" + {&new-line} +                                                                                                                                                           */
/*                  "документ: " + entry (8,buf_gen-attr.p-key,{&delim-key}))).                                                                                                                                               */
/*                v-reserv = true.                                                                                                                                                                                            */
/*              end.     /*if can-find (buf_gen-attr no-lock where buf_gen-attr.attr-code = v-mark and buf_gen-attr.table-name = {&excise-mark} */                                                                            */
/*                                                                                                                                                                                                                            */
/*              /*Проверяем, есть ли марка в свободной зоне*/                                                                                                                                                                 */
/*              find first buf_gen-attr no-lock where buf_gen-attr.table-name = {&excise-mark}                                                                                                                                */
/*                and buf_gen-attr.attr-code = v-mark                                                                                                                                                                         */
/*                and num-entries (buf_gen-attr.p-key, {&delim-key}) >= 8                                                                                                                                                     */
/*                and buf_gen-attr.p-key begins "parts"                                                                                                                                                                       */
/*                and entry(8,buf_gen-attr.p-key,{&delim-key}) = {&free-code} no-error .                                                                                                                                      */
/*              if not available (buf_gen-attr) or v-reserv then                                                                                                                                                              */
/*              do:                                                                                                                                                                                                           */
/*                if not v-reserv                                                                                                                                                                                             */
/*                  then                                                                                                                                                                                                      */
/*                  run dispmessage ( string ("Марка: " + v-mark + {&new-line} +                                                                                                                                              */
/*                    "отсутсвует в свободной зоне."                                                                                                                                                                          */
/*                    )).                                                                                                                                                                                                     */
/*              end. /*if not available (buf_gen-attr) then */                                                                                                                                                                */
/*              else                                                                                                                                                                                                          */
/*              do:                                                                                                                                                                                                           */
/*                if v-alc-code = ""                                                                                                                                                                                          */
/*                  then                                                                                                                                                                                                      */
/*                do:                                                                                                                                                                                                         */
/*                  find first buf_parts no-lock where                                                                                                                                                                        */
/*                    buf_parts.obj-type = entry(2,buf_gen-attr.p-key,{&delim-key})                                                                                                                                           */
/*                    and buf_parts.obj-code = integer (entry(3,buf_gen-attr.p-key,{&delim-key}))                                                                                                                             */
/*                    and buf_parts.artic = entry(4,buf_gen-attr.p-key,{&delim-key})                                                                                                                                          */
/*                    and buf_parts.prod-type = entry(5,buf_gen-attr.p-key,{&delim-key})                                                                                                                                      */
/*                    and buf_parts.prod-code = integer (entry(6,buf_gen-attr.p-key,{&delim-key}))                                                                                                                            */
/*                    and buf_parts.in-code = entry(7,buf_gen-attr.p-key,{&delim-key})                                                                                                                                        */
/*                    and buf_parts.out-code = entry(8,buf_gen-attr.p-key,{&delim-key})                                                                                                                                       */
/*                    and buf_parts.part-code = entry(9,buf_gen-attr.p-key,{&delim-key})                                                                                                                                      */
/*                    .                                                                                                                                                                                                       */
/*                                                                                                                                                                                                                            */
/*                  if available (buf_parts) and num-entries (buf_parts.alc-ref-ab-path ) = 4                                                                                                                                 */
/*                    then                                                                                                                                                                                                    */
/*                  do:                                                                                                                                                                                                       */
/*                    assign                                                                                                                                                                                                  */
/*                      v-alc-code = entry (3, buf_parts.alc-ref-ab-path)                                                                                                                                                     */
/*                      .                                                                                                                                                                                                     */
/*                  end.                                                                                                                                                                                                      */
/*                                                                                                                                                                                                                            */
/*                  find first buf_goods no-lock where                                                                                                                                                                        */
/*                    buf_goods.artic = buf_parts.artic                                                                                                                                                                       */
/*                    and buf_goods.prod-type = buf_parts.prod-type                                                                                                                                                           */
/*                    and buf_goods.prod-code = buf_parts.prod-code.                                                                                                                                                          */
/*                  if available (buf_goods)                                                                                                                                                                                  */
/*                    then                                                                                                                                                                                                    */
/*                  do:                                                                                                                                                                                                       */
/*                    v-gds-code = buf_goods.gds-code.                                                                                                                                                                        */
/*                  end.                                                                                                                                                                                                      */
/*                end.                                                                                                                                                                                                        */
/*                else                                                                                                                                                                                                        */
/*                do:                                                                                                                                                                                                         */
/*                  /*резервируем в партию*/                                                                                                                                                                                  */
/*                                                                                                                                                                                                                            */
/*                  v-gds-code = extGdsObj:GetExtGdsValue(1):GdsCode.                                                                                                                                                         */
/*                end.                                                                                                                                                                                                        */
/*                find first bf_trn-doc no-lock where bf_trn-doc.doc-code = entry (7, buf_gen-attr.p-key, {&delim-key}) no-error.                                                                                             */
/*                if not available (bf_trn-doc) and not (t_doc.obj-type = bf_trn-doc.obj-type and t_doc.obj-code = bf_trn-doc.obj-code)                                                                                       */
/*                  then                                                                                                                                                                                                      */
/*                do:                                                                                                                                                                                                         */
/*                  run dispmessage (substitute ("Марка: " + v-mark + " не зарегистрирована в системе по поставщику &1.", (t_doc.obj-type + string (t_doc.obj-code)))).                                                       */
/*                  return.                                                                                                                                                                                                   */
/*                end.                                                                                                                                                                                                        */
/*              end.                                                                                                                                                                                                          */
/*              find first buf_goods no-lock where buf_goods.gds-code = v-gds-code no-error .                                                                                                                                 */
/*              if not available (buf_goods) then                                                                                                                                                                             */
/*              do:                                                                                                                                                                                                           */
/*                run dispmessage ("Нет товара с кодом: " + string(v-gds-code)).                                                                                                                                              */
/*              end.                                                                                                                                                                                                          */
/*              else                                                                                                                                                                                                          */
/*              do:                                                                                                                                                                                                           */
/*                gds-rec = recid(buf_goods) .                                                                                                                                                                                */
/*                                                                                                                                                                                                                            */
/*                find first buf_doc-line exclusive-lock where buf_doc-line.doc-code = p-doc-code                                                                                                                             */
/*                  and buf_doc-line.artic = buf_goods.artic and buf_doc-line.prod-code = buf_goods.prod-code                                                                                                                 */
/*                  and buf_doc-line.prod-type = buf_goods.prod-type no-error .                                                                                                                                               */
/*                if not available (buf_doc-line) then                                                                                                                                                                        */
/*                do:                                                                                                                                                                                                         */
/*                  run str/out-add.p (parparentproc,                                                                                                                                                                         */
/*                    recid(t_doc),                                                                                                                                                                                           */
/*                    ?,                                                                                                                                                                                                      */
/*                    ?,                                                                                                                                                                                                      */
/*                    recid(buf_goods),                                                                                                                                                                                       */
/*                    {&add-def},                                                                                                                                                                                             */
/*                    'scan-marks' + {&delim-key} + v-mark) no-error.                                                                                                                                                         */
/*                                                                                                                                                                                                                            */
/*                /*          /*Добавляем товар в накладную*/                                                                                                                                                               */*/
/*                                                                                                                                                                                                                            */
/*                end.                                                                                                                                                                                                        */
/*                else                                                                                                                                                                                                        */
/*                do:                                                                                                                                                                                                         */
/*                                                                                                                                                                                                                            */
/*                  /*Увеличеваем кол-во товара в накладной*/                                                                                                                                                                 */
/*                  find first cpl_gds-dtl exclusive-lock where cpl_gds-dtl.doc-code = buf_doc-line.doc-code                                                                                                                  */
/*                    and cpl_gds-dtl.artic = buf_doc-line.artic and buf_doc-line.prod-code = cpl_gds-dtl.prod-code                                                                                                           */
/*                    and buf_doc-line.prod-type = cpl_gds-dtl.prod-type no-error.                                                                                                                                            */
/*                                                                                                                                                                                                                            */
/*                  run str/out-add.p                                                                                                                                                                                         */
/*                    ( input parparentproc                                                                                                                                                                                   */
/*                    ,input recid(t_doc)                                                                                                                                                                                     */
/*                    ,input recid(buf_doc-line)                                                                                                                                                                              */
/*                    ,input recid(cpl_gds-dtl)                                                                                                                                                                               */
/*                    ,input recid (buf_goods)                                                                                                                                                                                */
/*                    ,input {&update}                                                                                                                                                                                        */
/*                    ,input 'scan-marks' + {&delim-key} + v-mark)                                                                                                                                                            */
/*                    no-error.                                                                                                                                                                                               */
/*                                                                                                                                                                                                                            */
/*                end.                                                                                                                                                                                                        */
/*              end.                                                                                                                                                                                                          */
/*            end. /*if available (buf_goods) then do*/                                                                                                                                                                       */
/*                                                                                                                                                                                                                            */
/*                                                                                                                                                                                                                            */
/*          end.                                                                                                                                                                                                              */
/*        end.                                                                                                                                                                                                                */
/*        apply "entry" to v-mark in FRAME {&FRAME-NAME}.                                                                                                                                                                     */
/*        assign                                                                                                                                                                                                              */
/*          v-mark              = ""                                                                                                                                                                                          */
/*          v-mark:screen-value = ""                                                                                                                                                                                          */
/*          .                                                                                                                                                                                                                 */
/*      end.                                                                                                                                                                                                                  */
    end.

    assign 
      v-mark              = ""
      v-mark:screen-value = ""
      v-scan-str          = ""
    .
    apply "CHOOSE" to b-exit in frame {&frame-name}.
  end.

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-any-key Dialog-Frame 
PROCEDURE proc-any-key :
    if not v-manual
        then
        if v-scan-str = ""
            then etime(yes).
        else
            if etime > 700
                then v-scan-str = "".
    v-scan-str = v-scan-str + last-event:label.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME