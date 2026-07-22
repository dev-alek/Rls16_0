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
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DECLARATIONS Procedure
using ibs.th.str.marking.handlers.*.
using ibs.th.skt.*.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сканирование акцизных марок".
{ gbl/objsrv.i }
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ str/marks.i    }
{ str/fbrhist.i main }
{ gbl/lineattr.i }
{ str/temp_upd.i }
{ gbl/attr-lib.i }
{ utl/gtin.i     }
{ gbl/waitfram.i noprocess }
{ str/tt-fbr-line.i }
{ gbl/getcntxt.i def }
{ str/utd-typemark.i}

/* Parameters Definitions ---                                           */

define input  parameter parparentproc         as handle              no-undo .

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
define variable v-user-action   as character no-undo.
define variable v-printed       as logical   no-undo.
define variable v-mark-short     as character no-undo. 
define buffer t_doc        for ub.fbr-doc .
define buffer bf_fbr-doc   for ub.fbr-doc .
define buffer buf_marking  for ub.marking .
define buffer buf_marking-lines  for ub.marking-lines .
define buffer bf_fbr-line  for ub.fbr-line.
define buffer buf_recipe   for ub.recipe .
define buffer bf_bar-code  for ub.bar-code.
define variable v-timedelay  as integer   no-undo.
define variable v-scan-str as character no-undo.
define variable v-num-str as integer no-undo .
define variable v-manual as logical no-undo .
define variable marking    as class ibs.th.skt.ControlledClients.marking.

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
&Scoped-Define ENABLED-OBJECTS v-mark B_mark b-exit b-cancel 
&Scoped-Define DISPLAYED-OBJECTS v-mark f-msg br-fbr-line

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */
&Scoped-define open-query-br-fbr-line open query br-fbr-line for each tt-fbr-line by tt-fbr-line.num INDEXED-REPOSITION .
/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME

/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cancel auto-end-key
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-exit AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B_mark 
     LABEL "Марки" 
     SIZE 10 BY 1.

DEFINE VARIABLE f-msg AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 95 BY 1 NO-UNDO.

DEFINE VARIABLE v-mark AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 95 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-fbr-line FOR
      tt-fbr-line SCROLLING.

&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-fbr-line
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-fbr-line Dialog-Frame _FREEFORM
  QUERY br-fbr-line DISPLAY
    tt-fbr-line.num format ">>>>>9" label "Номер"
    tt-fbr-line.gds-code format ">>>>>>>>>>>>>>9" label "Код"
    tt-fbr-line.gds-name format "X(150)" width 40 label "Наименование"
    tt-fbr-line.ingr-qnty format ">>>>>>>>>>>9.999" label "Количество"
    tt-fbr-line.unit format "X(13)" label "Ед. измерения"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 95 BY 8.
/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     "Марка для производства:" VIEW-AS TEXT
          SIZE 28 BY .95 AT ROW 1.3 COL 3.4 WIDGET-ID 90
     v-mark AT ROW 2.4 COL 1 COLON-ALIGNED NO-LABEL
     br-fbr-line at row 3.5 col 1 COLON-ALIGNED
     f-msg AT ROW 12 COL 1 COLON-ALIGNED NO-LABEL WIDGET-ID 92
     B_mark AT ROW 13.2 COL 1 COLON-ALIGNED WIDGET-ID 80
     b-exit AT ROW 13.2 COL 12 COLON-ALIGNED
     b-cancel AT ROW 13.2 COL 23 COLON-ALIGNED
     SPACE(1.0) SKIP(1)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Резервирование марок для производства"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-cancel.


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
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN f-msg IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
ASSIGN 
       f-msg:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
do:
  find first tt-fbr-line no-error .
  find first tt-marking-lines no-error .
  if available tt-fbr-line
  and available tt-marking-lines
  then do :
    run waitfram-show in this-procedure (input "Ждите... Идёт создание и закрытие документа производства").
    
    run str/cr-fbr-doc-mark.p ( input parparentproc
                              , input this-procedure
                              , input table tt-fbr-line by-reference
                              , input table tt-marking-lines by-reference
                              ) .
    
    run waitfram-hide in this-procedure .
  end .
  empty temp-table tt-fbr-line .
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cancel Dialog-Frame
ON CHOOSE OF b-cancel IN FRAME Dialog-Frame /* Отмена */
do:
  for each tt-marking-lines :
    find first buf_marking exclusive-lock where buf_marking.mark = tt-marking-lines.mark no-error .
    if locked buf_marking
    then do :
      /* error? */
    end .
    if not available buf_marking
    then do :
      next .
    end .
    assign buf_marking.sts = tt-marking-lines.old-sts .
  end .  
  empty temp-table tt-marking-lines .
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-mark Dialog-Frame
ON any-printable OF v-mark IN FRAME Dialog-Frame 
do:

  run proc-any-key.

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B_mark Dialog-Frame
ON CHOOSE OF B_mark IN FRAME Dialog-Frame /* Марки */
DO:
  
  find first tt-marking-lines no-error .
  if available (tt-marking-lines) then
  do:
    run str/mark_browse.w (input parparentproc,
      input-output table tt-marking-lines by-reference,
      input {&lookup},
      input "Марки по документу",
      input "0",
      input "" /*тип продукции*/
      )  .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-mark Dialog-Frame
ON ENTRY OF v-mark IN FRAME Dialog-Frame
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
ON LEAVE OF v-mark IN FRAME Dialog-Frame
DO:
    assign frame {&frame-name} v-mark .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-mark Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF v-mark IN FRAME Dialog-Frame
DO:
    run save_update .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-mark Dialog-Frame
ON return OF v-mark IN FRAME Dialog-Frame
DO:
    run save_update .

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
/*{ gbl/app_help.i }*/
MAIN-BLOCK:
DO ON ERROR UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  :
  { gbl/getcntxt.i get }
  assign v-num-str = 0 .
  marking = new ibs.th.skt.ControlledClients.marking() .
  
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
  
/*  hide b-cancel in frame {&frame-name}.*/

  enable v-mark with frame {&frame-name}.
  
  if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code):IsManual
  then v-manual = yes.
  else do:
    v-manual = no .
    v-mark:READ-ONLY IN FRAME {&frame-name} = TRUE .
  end.   

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ActivateKeyboardLayout Dialog-Frame 
PROCEDURE ActivateKeyboardLayout external "user32":
define input parameter P1 as LONG.
   define input parameter P2 as LONG.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CrCheckMark Dialog-Frame 
PROCEDURE CrCheckMark :
  define buffer buf_goods for ub.goods .
  define buffer buf_recipe for ub.recipe .
  define buffer buf_recipe-gds for ub.recipe-gds .
  define buffer buf_marking-child for ub.marking .
  define buffer buf_marking-parent for ub.marking .
  define buffer buf_gds-obj for ub.gds-obj .
  
  define variable v-par-type as character no-undo.
  define variable v-par-val  as character no-undo.
  define variable v-gds-code as integer no-undo .
  define variable v-num-recipes as integer no-undo .
  define variable v-GTIN as character no-undo .
  define variable v-GTIN-qnty as decimal no-undo .
  define variable v-mark-weight as decimal no-undo .
  define variable v-isweighed as logical no-undo .
  define variable v-mark-child-qnty as decimal no-undo .
  define variable v-free-qnty as decimal no-undo .
  define variable v-old-sts as integer no-undo .
  define variable v-recipe-code like ub.recipe.recipe-code no-undo .
  define variable v-ingr-gds-code as integer no-undo .
  define variable v-koef-qnty as decimal no-undo .
  define variable v-exp-date-txt as character no-undo .
  
  define variable v-GisMTcheckStatus as integer no-undo .
  define variable v-is-off-line as logical no-undo .

  assign 
    v-mark = v-mark:screen-value in frame {&frame-name}.
  if v-mark = ""
    then return.

  v-mark-short = GetCodeIdent(v-mark).
  
  if v-mark-short = "" or v-mark-short = ?
  then do:
    run dispmessage ("Неизвестный формат марки.").
    return.
  end.
  
  find first buf_marking where (buf_marking.mark begins v-mark-short) no-error.
  
  if available buf_marking
  then do :
    v-GTIN = getGtinByDM(buf_marking.mark) .
  end .
  else do :
    v-GTIN = getGtinByDM(v-mark) .
  end .
  v-gds-code = getGdsCodeByGtin(v-GTIN) .
  v-GTIN-qnty = getQntyCodeByGtin(v-GTIN) .
  
  if v-gds-code = ?
  then do :
    run dispmessage ("Товар не найден.").
    return.
  end .
  
  find first buf_goods no-lock where buf_goods.gds-code = v-gds-code no-error .
  if not available buf_goods
  then do :
    run dispmessage ("Товар не найден.").
    return.
  end .
  
  if v-GTIN-qnty = ?
  or v-GTIN-qnty <= 0.0
  then do :
    run dispmessage ("Не установлен коэффициент для упаковки.").
    return.
  end .
  
  &scop proc-name gds-attr-value
  {&run_proc_attr-lib}
  ( buf_goods.gds-code,
   {&attr-mark-type},
   output v-par-val,
   output v-par-type
  ).
  v-isweighed = WghProdVariable(v-cntxt-obj-type, v-cntxt-obj-code, buf_goods.gds-code) .
  if v-isweighed
  then do : 
    if available buf_marking
    then do :
      v-mark-weight = MarkWeight(buf_marking.mark).
      if v-mark-weight = 0
      or v-mark-weight = ?
      then do :
        run dispmessage ("Марка не может быть добавлена, т.к. в БД отсутствует ее вес.").
        return.
      end .
    end .
    else do :
      run dispmessage ("Марка не найдена в БД.").
      return.
    end .
  end.  
  if not ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code):GetIsEDOForType(v-par-val)
  and not v-isweighed
  then do :
    run dispmessage ("Сканирование марок данного товара для производства не требуется").
    return.
  end .
  
  assign v-num-recipes = 0 .
  for each buf_recipe-gds no-lock where buf_recipe-gds.artic     = buf_goods.artic
                                    and buf_recipe-gds.prod-type = buf_goods.prod-type
                                    and buf_recipe-gds.prod-code = buf_goods.prod-code,
  each buf_recipe no-lock where buf_recipe.recipe-code = buf_recipe-gds.recipe-code
                            and buf_recipe.recipe-type = {&alternative}
                            and buf_recipe.stts       <> 2
  :
    assign
      v-num-recipes   = v-num-recipes + 1
      v-recipe-code   = buf_recipe.recipe-code
      v-ingr-gds-code = buf_recipe.gds-code
      v-koef-qnty     = buf_recipe-gds.qnty
    .
  end .
  
  if v-num-recipes = 0
  then do :
    message substitute("Для товара &1 &2 рецепт не найден. Обратитесь в офис для создания рецепта", buf_goods.gds-code, buf_goods.gds-name)
    view-as alert-box .
    return.
  end .
  
  if v-num-recipes <> 1
  then do :
    message substitute("Для товара &1 &2 найдено более одного рецепта «Альтернатива», поэтому автоматический выбор рецепта невозможен, товар не добавлен. Создайте документ производства с этим товаром вручную. Обратитесь в офис для корректировки рецептов", buf_goods.gds-code, buf_goods.gds-name)
    view-as alert-box .
    return.
  end .
  
  run waitfram-show in this-procedure (input "Идет проверка марки, пожалуйста, подождите..." ).

/*  v-GisMTcheckStatus = marking:checkScanMark(v-cntxt-obj-code                                                        */
/*                                            , v-mark                                                                 */
/*                                            , v-mark-short                                                           */
/*                                            , available buf_marking                                                  */
/*                                            , output v-is-off-line)                                                  */
/*                                            no-error.                                                                */
/*  if not v-is-off-line                                                                                               */
/*  and v-GisMTcheckStatus = 0                                                                                         */
/*  then do :                                                                                                          */
/*    run waitfram-hide in this-procedure .                                                                            */
/*    message ("Онлайн-проверка вернула отрицательный результат, марка не может быть добавлена в производство")        */
/*    view-as alert-box .                                                                                              */
/*    return.                                                                                                          */
/*  end .                                                                                                              */
/*                                                                                                                     */
/*  if v-is-off-line                                                                                                   */
/*  and v-GisMTcheckStatus = 0                                                                                         */
/*  then do :                                                                                                          */
/*    run waitfram-hide in this-procedure .                                                                            */
/*    message ("Использование товара запрещено контролирующими органами, марка не может быть добавлена в производство")*/
/*    view-as alert-box .                                                                                              */
/*    return.                                                                                                          */
/*  end .                                                                                                              */
/*                                                                                                                     */
/*  if v-is-off-line                                                                                                   */
/*  and v-GisMTcheckStatus = 3                                                                                         */
/*  then do :                                                                                                          */
/*    run waitfram-hide in this-procedure .                                                                            */
/*    message ("Онлайн и офлайн – проверки не выполнены, товар не может быть добавлен в производство")                 */
/*    view-as alert-box .                                                                                              */
/*    return.                                                                                                          */
/*  end .                                                                                                              */
/*                                                                                                                     */
/*  if not v-is-off-line                                                                                               */
/*  and v-GisMTcheckStatus = 2                                                                                         */
/*  then do :                                                                                                          */
/*    run waitfram-hide in this-procedure .                                                                            */
/*    message ("Онлайн проверка не выполнена, товар не может быть добавлен в производство")                            */
/*    view-as alert-box .                                                                                              */
/*    return.                                                                                                          */
/*  end .                                                                                                              */
 
  if available buf_marking
  then do :
    v-exp-date-txt = marking:ChekExpirationDate(v-cntxt-obj-type, v-cntxt-obj-code, buffer buf_marking).
    
    if buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB
    and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB
    then do :
      run waitfram-hide in this-procedure .
      message (substitute("Операция невозможна. Статус марки – <&1>. ", objSrv:Env:Marking:Sts:Mark:GetLabel(buf_marking.sts)) + v-exp-date-txt)
      view-as alert-box . 
/*      if buf_marking.sts = objSrv:Env:Marking:Sts:Mark:Reserved:KeyIntDB                                                                                 */
/*      or buf_marking.sts = objSrv:Env:Marking:Sts:Mark:ReservedFromProduction:KeyIntDB                                                                   */
/*      then do :                                                                                                                                          */
/*        message (substitute("КМ в статусе <&1>, марка не может быть добавлена повторно", objSrv:Env:Marking:Sts:Mark:GetLabel(buf_marking.sts)))         */
/*        view-as alert-box .                                                                                                                              */
/*      end .                                                                                                                                              */
/*      else do :                                                                                                                                          */
/*        message (substitute("КМ в статусе <&1>, марка не может быть использована в производство", objSrv:Env:Marking:Sts:Mark:GetLabel(buf_marking.sts)))*/
/*        view-as alert-box .                                                                                                                              */
/*      end .                                                                                                                                              */
      return.
    end .
    if v-exp-date-txt > ""
    then do :
      run waitfram-hide in this-procedure .
      message (v-exp-date-txt)
      view-as alert-box .
      return .
    end .
  end .
  else do :
/*    if v-GisMTcheckStatus = 2                                                                                      */
/*/*    or (v-GisMTcheckStatus = 0 and v-is-off-line)  выше уже есть такое условие */                                */
/*    then do :                                                                                                      */
/*      run waitfram-hide in this-procedure .                                                                        */
/*      message ("Марка не найдена в БД и онлайн проверка не выполнена, товар не может быть добавлен в производство")*/
/*      view-as alert-box .                                                                                          */
/*      return.                                                                                                      */
/*    end .                                                                                                          */
    create buf_marking .
    assign
      buf_marking.mark = v-mark-short
      buf_marking.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB
      buf_marking.box-qnty = v-GTIN-qnty
      buf_marking.obj-type = v-cntxt-obj-type
      buf_marking.obj-code = v-cntxt-obj-code
      buf_marking.gds-code = buf_goods.gds-code
      buf_marking.unit     = buf_goods.unit-base
      buf_marking.gds-ext-id = v-GTIN
    .
  end .
  
  run waitfram-hide in this-procedure .
  
  find first tt-marking-lines where buf_marking.mark begins tt-marking-lines.mark no-error.
  if available tt-marking-lines
  then do :
    run dispmessage ("Марка добавлена в документ ранее.").
    return.
  end .
  
  if integer(v-GTIN-qnty) <> 1 /* групповая упаковка */
  then do :
    assign v-mark-child-qnty = 0 .
    if available buf_marking
    then do :
      for each buf_marking-child no-lock where buf_marking-child.mark-parent = buf_marking.mark :
        v-mark-child-qnty = v-mark-child-qnty + 1 .
      end .
    end .
    if v-mark-child-qnty <> v-GTIN-qnty
    then do :
      run dispmessage ("Состав групповой упаковки неизвестен, необходимо отсканировать потребительские упаковки").
      return.
    end .
  end .
  
  assign v-free-qnty = 0 .
  find first buf_gds-obj no-lock where buf_gds-obj.obj-type  = v-cntxt-obj-type
                                   and buf_gds-obj.obj-code  = v-cntxt-obj-code
                                   and buf_gds-obj.artic     = buf_goods.artic
                                   and buf_gds-obj.prod-type = buf_goods.prod-type
                                   and buf_gds-obj.prod-code = buf_goods.prod-code
                                   no-error .
  if available buf_gds-obj
  then do :
    assign v-free-qnty = buf_gds-obj.free-qnty .
  end .
  
  find first tt-fbr-line where tt-fbr-line.gds-code = buf_goods.gds-code no-error .
  if not available tt-fbr-line
  then do :
    assign v-num-str = v-num-str + 1 .
    create tt-fbr-line .
    assign
      tt-fbr-line.num = v-num-str
      tt-fbr-line.gds-code = buf_goods.gds-code
      tt-fbr-line.gds-name = buf_goods.gds-name
      tt-fbr-line.qnty = 0
      tt-fbr-line.ingr-qnty = 0
      tt-fbr-line.recipe-code = v-recipe-code
      tt-fbr-line.recipe-type = {&alternative}
      tt-fbr-line.ingr-gds-code = v-ingr-gds-code
      tt-fbr-line.unit = buf_goods.unit-base
      tt-fbr-line.weighed = v-isweighed
      tt-fbr-line.mark-weight = v-mark-weight 
    .  
  end .
  
  if tt-fbr-line.weighed and 
     (tt-fbr-line.ingr-qnty + v-mark-weight) <= v-free-qnty
  then do :
    assign
      tt-fbr-line.qnty = tt-fbr-line.qnty + (v-mark-weight * v-koef-qnty)
      tt-fbr-line.ingr-qnty = tt-fbr-line.ingr-qnty + v-mark-weight
    .
  end .
  else if (tt-fbr-line.ingr-qnty + v-GTIN-qnty) <= v-free-qnty
  then do :
    assign
      tt-fbr-line.qnty = tt-fbr-line.qnty + (v-GTIN-qnty * v-koef-qnty)
      tt-fbr-line.ingr-qnty = tt-fbr-line.ingr-qnty + v-GTIN-qnty
    .
  end .
  else do :
    if tt-fbr-line.ingr-qnty = 0
    then do :
      assign v-num-str = v-num-str - 1 .
      delete tt-fbr-line .
    end .
    run dispmessage ("Марка не может быть добавлена, т.к. будут превышены книжные остатки товара").
    return.
  end .
  
  find current buf_marking exclusive-lock no-error .
  if locked buf_marking
  then do :
    if tt-fbr-line.weighed
    then do :
      assign tt-fbr-line.ingr-qnty = tt-fbr-line.ingr-qnty - v-mark-weight .
    end .
    else do :
      assign tt-fbr-line.ingr-qnty = tt-fbr-line.ingr-qnty - v-GTIN-qnty .
    end .
    if tt-fbr-line.ingr-qnty = 0
    then do :
      assign v-num-str = v-num-str - 1 .
      delete tt-fbr-line .
    end .
    run dispmessage ("Марка не может быть добавлена, т.к. с ней работает другой пользователь").
    return.
  end .
  
  assign
    v-old-sts = buf_marking.sts
    buf_marking.sts = objSrv:Env:Marking:Sts:Mark:Reserved:KeyIntDB
  .
  
  create tt-marking-lines .
  assign
    tt-marking-lines.mark = buf_marking.mark
    tt-marking-lines.gds-code = buf_goods.gds-code
    tt-marking-lines.gds-name = buf_goods.gds-name
    tt-marking-lines.obj-type = v-cntxt-obj-type
    tt-marking-lines.obj-code = v-cntxt-obj-code
    tt-marking-lines.sts      = buf_marking.sts
    tt-marking-lines.old-sts  = v-old-sts
    tt-marking-lines.box-qnty = v-GTIN-qnty
    tt-marking-lines.doc-level = 1
    tt-marking-lines.weight = if v-isweighed then string(v-mark-weight) else ""
  .
  
  for each buf_marking-child exclusive-lock where buf_marking-child.mark-parent = buf_marking.mark :
    assign
      v-old-sts = buf_marking-child.sts
      buf_marking-child.sts = objSrv:Env:Marking:Sts:Mark:Reserved:KeyIntDB
    .
    create tt-marking-lines .
    assign
      tt-marking-lines.mark = buf_marking-child.mark
      tt-marking-lines.gds-code = buf_goods.gds-code
      tt-marking-lines.gds-name = buf_goods.gds-name
      tt-marking-lines.obj-type = v-cntxt-obj-type
      tt-marking-lines.obj-code = v-cntxt-obj-code
      tt-marking-lines.sts      = buf_marking-child.sts
      tt-marking-lines.old-sts  = v-old-sts
      tt-marking-lines.box-qnty = 1.0
      tt-marking-lines.doc-level = 2
    .
  end .
  
  for first buf_marking-parent exclusive-lock where buf_marking-parent.mark = buf_marking.mark-parent
                                                and buf_marking.mark-parent > ""
  :
    assign buf_marking-parent.sts = objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB .
  end .
  
end.

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
define input parameter p-str as character no-undo.
  f-msg:fgcolor in frame {&FRAME-NAME} = 12.
  do:
    display p-str @ f-msg with frame {&frame-name}.
/*    message p-str view-as alert-box information title "Информация".*/
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
  DISPLAY v-mark f-msg br-fbr-line
      WITH FRAME Dialog-Frame.
  ENABLE v-mark B_mark b-exit b-cancel br-fbr-line
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE LoadKeyboardLayoutA Dialog-Frame 
PROCEDURE LoadKeyboardLayoutA external "user32":
  define input  parameter P1 as char.
  define input  parameter P2 as LONG.
  define return parameter pret as LONG.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save_update Dialog-Frame 
PROCEDURE save_update :
  define variable v-error      as logical   no-undo init no.
  define variable l-error      as logical   no-undo init no.
  define variable v-error-lang as logical   no-undo init no.
          
  define variable ii           as integer   no-undo .
  define variable chg-qnty     as integer   no-undo .
  
  do trans:
    f-msg:screen-value in frame {&FRAME-NAME} = "" .
    
    if v-mark:screen-value in frame {&frame-name} = ""
    then do:
      v-mark:screen-value in frame {&frame-name} = v-scan-str.
      v-scan-str = "". 
    end.
    
    assign 
      v-mark = v-mark:screen-value in frame {&frame-name}.
    if v-mark = ""
      then return.
    
    run CrCheckMark.

    {&open-query-br-fbr-line}
    
    v-mark = "".
    v-mark:screen-value in frame {&frame-name} = "".
    v-mark-short = "".
  end.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

