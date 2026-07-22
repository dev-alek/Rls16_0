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

Автор: Морозов Александр Сергеевич
Дата создания: 07/09/07
Author: Alexandr Morozov
Creation date: 07/09/07

*/
&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DECLARATIONS Procedure
using ibs.th.str.marking.handlers.*.
using ibs.th.str.utd.handlers.introduce.

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
{bge/egais-mark.i}
{ str/lib-trn.i  }
{ str/lib-calc.i }
{ str/libbcrcn.i }
{ cmp/croslist.i }
{ gbl/lineattr.i }
{ str/temp_upd.i }
{ utl/gtin.i     }
{ rep/gn-extp.i  }
{ gbl/getcntxt.i def }
define temp-table tt-mark no-undo
  field alcmark as character.

/* Parameters Definitions ---                                           */

define input  parameter parparentproc         as handle              no-undo .
define input  parameter p-doc-code            as character           no-undo .
define input  parameter p-mode                as character           no-undo .
define input  parameter p-inv-handle          as handle              no-undo .

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
define variable v-mark-short     as character no-undo. 
define buffer t_doc        for ub.trn-doc .
define buffer bf_trn-doc   for ub.trn-doc .
define buffer buf_marking  for ub.marking .
define buffer buf_marking-lines  for ub.marking-lines .
define buffer bf_doc-line  for ub.doc-line.
define buffer bf_gds-dtl   for ub.gds-dtl.
define buffer bf_prod-bc   for ub.prod-bc.
define buffer bf_bar-code  for ub.bar-code.
define variable v-timedelay  as integer   no-undo.
define variable v-scan-str as character no-undo.

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
&Scoped-Define ENABLED-OBJECTS b-exit b-cancel b-help b-imp b-cntl-th ~
B_mark v-mark 
&Scoped-Define DISPLAYED-OBJECTS v-mark f-msg 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cancel 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-cntl-th 
     LABEL "Контроль TH" 
     SIZE 14 BY 1.

DEFINE BUTTON b-exit AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help 
     LABEL "&Помощь" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-imp 
     LABEL "Импорт" 
     SIZE 10 BY 1.

DEFINE BUTTON B_mark 
     LABEL "Все марки" 
     SIZE 15 BY 1.13.

DEFINE VARIABLE f-msg AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 83 BY 1
     FGCOLOR 12  NO-UNDO.

DEFINE VARIABLE v-mark AS CHARACTER FORMAT "X(256)":U 
     LABEL "Марка" 
     VIEW-AS FILL-IN 
     SIZE 76 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-cancel AT ROW 1 COL 11.5
     b-help AT ROW 1 COL 22
     b-imp AT ROW 1 COL 32.5 WIDGET-ID 2
     b-cntl-th AT ROW 1 COL 42.5 WIDGET-ID 2
     B_mark AT ROW 1 COL 72.38 WIDGET-ID 80
     v-mark AT ROW 3 COL 7.5 COLON-ALIGNED
     f-msg AT ROW 4.38 COL 2.13 NO-LABEL WIDGET-ID 82
     SPACE(2.25) SKIP(0.44)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Сканирование марок"
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
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Сканирование марок */
DO:

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cntl-th
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cntl-th Dialog-Frame
ON choose OF b-cntl-th IN FRAME Dialog-Frame /* Контроль TH */
DO:
    if not v-scan-str = "" 
      then return no-apply.
    run bge/egais-control-marks.w (input parparentproc).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-cntl-th
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cntl-th Dialog-Frame
ON return OF b-cntl-th IN FRAME Dialog-Frame /* Контроль TH */
DO:
    run save_update .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
DO:
    run save_update .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON return OF b-exit IN FRAME Dialog-Frame /* Ввод */
DO:
    run save_update .
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


&Scoped-define SELF-NAME B_mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B_mark Dialog-Frame
ON CHOOSE OF B_mark IN FRAME Dialog-Frame /* Все марки */
DO:
  define buffer buf_utd-marking-lines for ub.utd-marking-lines.
  define buffer buf_marking for ub.marking.

  if available (t_doc) then do:
      for each ub.marking-attr no-lock where
            ub.marking-attr.attr-value = t_doc.doc-code
        and (ub.marking-attr.attr-code = "inv-doc" or ub.marking-attr.attr-code = "inv-doc-scan"):

      for each ub.marking-lines no-lock where
        ub.marking-lines.obj-type = t_doc.obj-type
        and ub.marking-lines.obj-code = t_doc.obj-code
        and ub.marking-lines.out-code = {&free-code}
        and ub.marking-lines.mark = ub.marking-attr.mark
        :

        find first ub.marking no-lock where ub.marking.mark = ub.marking-lines.mark and ub.marking.sts <> ObjSrv:Env:Marking:Sts:Mark:UnknowSts:KeyIntDB no-error.
        if available (ub.marking)
          then 
        do:
          create tt-marking-lines.
          buffer-copy ub.marking-lines to tt-marking-lines.
          tt-marking-lines.sts = ub.marking.sts.
          tt-marking-lines.stts = objSrv:Env:Marking:Sts:Mark:GetLabel(ub.marking.sts).
          tt-marking-lines.sts-utd = ub.marking-lines.sts.
          tt-marking-lines.stts-utd = objSrv:Env:Marking:Sts:Mark:Checked_:Label_.
          tt-marking-lines.box-qnty = ub.marking.box-qnty .
          tt-marking-lines.unit = ub.marking.unit .
          tt-marking-lines.unit-ext = ub.marking.unit-ext .
          if ub.marking-attr.attr-code = "inv-doc-scan"
            then tt-marking-lines.doc-level = 1.
            else tt-marking-lines.doc-level = 2.
          
          tt-marking-lines.mark-parent = ub.marking.mark-parent.
          tt-marking-lines.out-code = t_doc.doc-code.
        end.

      end.
    end.
  
    for each ub.utd no-lock where
            ub.utd.doc-code = t_doc.doc-code
        :
      for each buf_utd-marking-lines no-lock where buf_utd-marking-lines.db-num = ub.utd.db-num and buf_utd-marking-lines.doc-id = ub.utd.doc-id and buf_utd-marking-lines.mark <> "",
        each buf_marking no-lock where buf_marking.mark = buf_utd-marking-lines.mark:
        find first ub.goods where buf_marking.gds-code = ub.goods.gds-code.
        create tt-marking-lines .
        assign
          tt-marking-lines.gds-name    = ub.goods.gds-name
          tt-marking-lines.stts-utd    = objSrv:Env:Marking:Sts:Mark:GetLabel(buf_utd-marking-lines.sts)
          tt-marking-lines.stts        = objSrv:Env:Marking:Sts:Mark:GetLabel(buf_marking.sts)
          tt-marking-lines.mark        = buf_marking.mark
          tt-marking-lines.mark-parent = buf_marking.mark-parent
          tt-marking-lines.gds-code    = buf_utd-marking-lines.gds-code
          tt-marking-lines.sts         = buf_marking.sts
          tt-marking-lines.sts-utd     = buf_utd-marking-lines.sts
          tt-marking-lines.unit        = buf_marking.unit
          tt-marking-lines.unit-ext    = buf_marking.unit-ext
          tt-marking-lines.box-qnty    = buf_marking.box-qnty
          tt-marking-lines.LineNum     = buf_utd-marking-lines.LineNum
          tt-marking-lines.db-num      = buf_utd-marking-lines.db-num
          tt-marking-lines.doc-id      = buf_utd-marking-lines.doc-id
          tt-marking-lines.doc-level   = buf_utd-marking-lines.doc-level
          . 
      end.
    end.

    if available (tt-marking-lines) then
    do:
      run str/mark_browse.w (input parparentproc,
        input-output table tt-marking-lines by-reference,
        input {&lookup},
        input "Марки по документу: " + t_doc.doc-code,
        input "0",
        input "" /*тип продукции*/
        )  .
    end.

    for each tt-marking-lines:
      delete tt-marking-lines.
    end.
  end.

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

&Scoped-define SELF-NAME UUID_VSD
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL UUID_VSD Dialog-Frame
ON any-printable OF v-mark IN FRAME Dialog-Frame /*             UUID ВСД */
do:

  run proc-any-key.

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL UUID_VSD Dialog-Frame
ON any-printable OF b-exit IN FRAME Dialog-Frame /*             UUID ВСД */
do:

  run proc-any-key.

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cancel Dialog-Frame
ON any-printable OF b-cancel IN FRAME Dialog-Frame /*             UUID ВСД */
do:

  run proc-any-key.

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME B_mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B_mark Dialog-Frame
ON any-printable OF B_mark IN FRAME Dialog-Frame /*             UUID ВСД */
do:

  run proc-any-key.

end.

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
    run save_update .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-mark Dialog-Frame
ON return OF v-mark IN FRAME Dialog-Frame /* Марка */
DO:
    run save_update .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL end-error Dialog-Frame
ON end-error OF FRAME Dialog-Frame /* Марка */
DO:

  return no-apply.

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
{ gbl/app_help.i }
MAIN-BLOCK:
DO ON ERROR UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  :
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
  find first t_doc no-lock where t_doc.doc-code = p-doc-code no-error .
  find first trn-doc exclusive-lock where trn-doc.doc-code = p-doc-code no-error .  
  
  hide b-imp b-cancel b-cntl-th b-help in frame {&frame-name}.
  
  if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(t_doc.obj-type, t_doc.obj-code):IsManual
    then enable v-mark with frame {&frame-name}.
    else disable v-mark with frame {&frame-name}.
  
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ActivateKeyboardLayout Dialog-Frame 
PROCEDURE ActivateKeyboardLayout external 'user32' :
  define input parameter P1 as long.
  define input parameter P2 as long.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CrCheckMark Dialog-Frame 
PROCEDURE CrCheckMark :
define variable v-error      as logical   no-undo init no.
  define variable l-error      as logical   no-undo init no.
  define variable v-error-lang as logical   no-undo init no.
          
  define variable ii           as integer   no-undo .
/*  define variable v-parts      as character no-undo .          */
/*  define variable gds-rec      as recid     no-undo .          */
/*  define variable v-gds-code   as integer   no-undo .          */
/*  define variable v-host-code  like sysconf.host-code no-undo. */
/*  define variable v-tax-date   as date      no-undo.           */
/*  define variable v-vat-pc     like ub.doc-line.vat-pc no-undo.*/
/*  define variable v-slt-pc     like ub.doc-line.slt-pc no-undo.*/
/*  define variable ungroup      as logical no-undo .            */
  define variable chg-qnty     as integer   no-undo .
/*  define buffer buf_doc-line for ub.doc-line .                 */
/*  define buffer buf_parts    for ub.parts .                    */
/*  define buffer out_parts    for ub.parts .                    */
/*  define buffer buf_goods    for ub.goods .                    */
/*  define buffer buf_gds-prt  for ub.gds-prt .                  */
/*  define buffer cpl_gds-dtl  for ub.gds-dtl .                  */
/*  define variable v-GTIN as character no-undo .                */
/*  define buffer buf_marking-lines for ub.marking-lines.        */
  assign 
    v-mark = v-mark:screen-value in frame {&frame-name}.
  if v-mark = ""
    then return.

  define variable vcodident as character no-undo.
  v-mark-short = GetCodeIdent(v-mark).
  
  if v-mark-short = "" or v-mark-short = ?
  then do:
    run dispmessage ("Марка не распознана.").
    return.
  end.
  
  find first ub.marking-attr no-lock where (ub.marking-attr.attr-code = "inv-doc" or ub.marking-attr.attr-code = "inv-doc-scan") and (ub.marking-attr.mark begins v-mark-short) no-error.
  
  if available (ub.marking-attr) 
  then do:
    run dispmessage ("Марка находится в инвентаризации - " + ub.marking-attr.attr-value).
    return.
  end.
  
  find first buf_marking where (buf_marking.mark begins v-mark-short) no-error.

  if not available (buf_marking)
  then do:
    run dispmessage ("Марка не найдена в системе.").
    return.    
  end.
  
  if buf_marking.unit-ext = "LEVEL2"
  then do:
    run dispmessage ("Внимание!~nДобавление марки короба в данный вид документа невозможно!").
    return.
  end.
  
  find first buf_marking-lines where (buf_marking-lines.mark begins v-mark-short)
    and buf_marking-lines.out-code = {&free-code} no-error.
  
  if buf_marking.sts = ObjSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB
  then do:
    run dispmessage ("Упаковка разгруппирована.").
    return.
  end.
  
  if available (buf_marking-lines)
  then do:

    find first ub.goods no-lock where ub.goods.gds-code = buf_marking-lines.gds-code no-error.
    find first bf_doc-line no-lock where bf_doc-line.doc-code = p-doc-code
      and bf_doc-line.artic = ub.goods.artic
      and bf_doc-line.prod-type = ub.goods.prod-type
      and bf_doc-line.prod-code = ub.goods.prod-code no-error.
    
    if not available (bf_doc-line)
    then do:
      run dispmessage (substitute ("В накладной к линии с товаром &1 &2 к марке &3.", string (ub.goods.gds-code), ub.goods.gds-name, buf_marking-lines.mark)).
      return.
    end.

    create ub.marking-attr.
    ub.marking-attr.mark = buf_marking.mark.
    ub.marking-attr.attr-code = "inv-doc-scan".
    ub.marking-attr.attr-value = p-doc-code.
    def var rec as recid no-undo.
    rec = recid (bf_doc-line).
    release bf_doc-line.
    
    /*ObjSrv:Lib:MarkingTree:UnGroupDoc(buf_marking.mark, buf_marking-lines.in-code, buf_marking-lines.out-code, buf_marking-lines.obj-code, buf_marking-lines.obj-type).*/    
    ObjSrv:Lib:MarkingTree:UnGroupMark(buf_marking.mark).
    if ObjSrv:Lib:MarkingTree:LevelDown(buf_marking.mark) 
    then do:
      ObjSrv:Lib:MarkingTree:LockInvChildeMark(buf_marking.mark, p-doc-code).
    end.
    run go-line in p-inv-handle (input rec).
    f-msg:screen-value in frame {&FRAME-NAME} = v-mark-short .
    f-msg:fgcolor in frame {&FRAME-NAME} = 2.
  end.
  else do:
    run dispmessage ("Марка не числится на остатках. Статус марки - " + ObjSrv:Env:Marking:Sts:Mark:GetLabel(buf_marking.sts)).
  end.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE crIntroduce Dialog-Frame 
PROCEDURE crIntroduce :
  define variable v-GTIN as character no-undo .  
  v-GTIN = getGtinByDM(v-mark).
  find first bf_prod-bc no-lock where bf_prod-bc.bc-on-type = "GTIN" and bf_prod-bc.b-str = v-GTIN no-error.
  if not available (bf_prod-bc)
  then do:
    run dispmessage (substitute ("Не найден товар привязанный к GTIN &1.", v-GTIN)).
    return.
  end. 
  define variable vcodident as character no-undo.
  v-mark-short = GetCodeIdent(v-mark).
  if v-mark-short = "" or v-mark-short = ?
  then do:
    run dispmessage ("Марка не распознана.").
    return.
  end.
  find first buf_marking no-lock where buf_marking.mark = v-mark-short no-error.
  if available (buf_marking)
  then do:
    case buf_marking.sts:
      when ObjSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB then do:
        run dispmessage ("Упаковка разгруппирована.").
        return.
      end.
      when ObjSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB then do:
        run dispmessage ("Марка в свободной зоне.").
        return.
      end.
    end case.
    ObjSrv:Lib:MarkingTree:UnGroupMark(buf_marking.mark).
  end.
  find first bf_bar-code no-lock where bf_bar-code.b-code = bf_prod-bc.b-code.
  find first ub.goods no-lock where ub.goods.gds-code = bf_bar-code.gds-code no-error.
  find first bf_doc-line no-lock where bf_doc-line.doc-code = p-doc-code
    and bf_doc-line.artic = ub.goods.artic
    and bf_doc-line.prod-type = ub.goods.prod-type
    and bf_doc-line.prod-code = ub.goods.prod-code no-error.
  if not available (bf_doc-line)
  then do:
    run dispmessage (substitute ("В инвентаризации нет линии с товаром привязанным к GTIN &1.", v-GTIN)).
    return.
  end.
  def var IntroUtd as class introduce no-undo.
  IntroUtd = new introduce().
  IntroUtd:AddMarkUTD(v-mark, p-doc-code) no-error.
  if error-status:error
  then do:
    run dispmessage (substitute ("Ошибка добавления марки &1.", return-value)).
    return.
  end.
  delete object IntroUtd no-error.
  def var rec as recid no-undo.
  rec = recid (bf_doc-line).
  release bf_doc-line.
  release buf_marking.
  run go-line in p-inv-handle (input rec).
  f-msg:screen-value in frame {&FRAME-NAME} = v-mark-short .
  f-msg:fgcolor in frame {&FRAME-NAME} = 2.

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
  DISPLAY v-mark f-msg 
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-cancel b-help b-imp b-cntl-th B_mark v-mark 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE LoadKeyboardLayoutA Dialog-Frame 
PROCEDURE LoadKeyboardLayoutA external 'user32':
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
      run save_update.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save_update Dialog-Frame 
PROCEDURE save_update :
define variable v-error      as logical   no-undo init no.
  define variable l-error      as logical   no-undo init no.
  define variable v-error-lang as logical   no-undo init no.
          
  define variable ii           as integer   no-undo .
/*  define variable v-parts      as character no-undo .          */
/*  define variable gds-rec      as recid     no-undo .          */
/*  define variable v-gds-code   as integer   no-undo .          */
/*  define variable v-host-code  like sysconf.host-code no-undo. */
/*  define variable v-tax-date   as date      no-undo.           */
/*  define variable v-vat-pc     like ub.doc-line.vat-pc no-undo.*/
/*  define variable v-slt-pc     like ub.doc-line.slt-pc no-undo.*/
/*  define variable ungroup      as logical no-undo .            */
  define variable chg-qnty     as integer   no-undo .
/*  define buffer buf_doc-line for ub.doc-line .                 */
/*  define buffer buf_parts    for ub.parts .                    */
/*  define buffer out_parts    for ub.parts .                    */
/*  define buffer buf_goods    for ub.goods .                    */
/*  define buffer buf_gds-prt  for ub.gds-prt .                  */
/*  define buffer cpl_gds-dtl  for ub.gds-dtl .                  */
/*  define buffer buf_marking-lines for ub.marking-lines.        */
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
    
    if p-mode = "introduce"
        then run crIntroduce.
        else run CrCheckMark.
    v-mark = "".
    v-mark:screen-value in frame {&frame-name} = "".
    v-mark-short = "".
  end.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-any-key Dialog-Frame 
PROCEDURE proc-any-key :
  if not ObjSrv:Env:ParametrsOfSection:GetSectionEDO(t_doc.obj-type, t_doc.obj-code):IsManual
  then 
    if v-scan-str = ""
      then v-timedelay = etime.
      else
        if etime - v-timedelay > 700
          then v-scan-str = "".
  v-scan-str = v-scan-str + last-event:label.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME