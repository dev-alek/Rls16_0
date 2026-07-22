&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
using ibs.th.str.marking.sts.*.
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-mark

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DECLARATIONS d-mark 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

История движения марки

Автор: Шкляр Елена
Дата создания: 20/04/95
Author: Shklyar Elena
Creation date: 20/04/95

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mark as character no-undo .
define input parameter p-mode as character no-undo .

/*define var p-mark as character no-undo .*/
/*define var p-mode as character no-undo .*/


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "История движения марки".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/r-pril.i new }
{ gbl/userobjs.i }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ gbl/prn-lib.i }
{ gbl/waitfram.i }
{ cmp/mrk-strf.i }
{ gbl/color.i }
{ str/temp_upd.i }
{ utl/gtin.i }
{ rep/gn-extp.i }
/* Local Variable Definitions ---                                       */

define variable log-res     as log       no-undo.
define variable rr          as recid     no-undo.
define variable v_type      as char      no-undo.
define variable v-is-deploy as logical   no-undo .
define variable v-rid-list  as character no-undo .
define variable v-db-list   as character no-undo .
define variable iLang            as integer   no-undo.
define variable p-value-logical as logical no-undo.
define variable p-value-character  as character no-undo.
define variable p-value-date       as date no-undo.
define variable p-value-decimal    as decimal no-undo.
define variable p-value-integer    as integer no-undo.
define variable p-param-type       as character no-undo.
define variable v-tth as handle no-undo .
define variable v-marking   as character no-undo .
define variable canEditStatus      as logical no-undo.
define variable canEditOnlineCheck as logical no-undo.
define variable expire_DateOther   as character no-undo .

define buffer buf_marking       for ub.marking .
define buffer buf_marking-attr  for ub.marking-attr .
define buffer buf_marking-lines for ub.marking-lines .
define buffer buf_utd-marking-lines for ub.utd-marking-lines .
define buffer buf_parts         for ub.parts . 
define buffer buf_goods         for ub.goods .
define buffer buf_trn-doc       for ub.trn-doc .
define buffer buf_utd           for ub.utd .
DEFINE BUFFER X_marking-line    FOR tt-mark-line.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* Temp-Table and Buffer definitions                                    */



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-mark 
/*------------------------------------------------------------------------

  File: 

  Description: 

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: 

  Created: 16/02/20 - 12:57 pm

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-mark
&Scoped-define BROWSE-NAME br-mark

/* Definitions for BROWSE br-mark-item                                  */
&Scoped-define FIELDS-IN-QUERY-br-mark X_marking-line.gds-code ~
X_marking-line.mark-parent X_marking-line.mark X_marking-line.unit X_marking-line.sts 
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-mark 
&Scoped-define QUERY-STRING-br-mark FOR EACH X_marking-line NO-LOCK by X_marking-line.fact-order desc by X_marking-line.date_ desc INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-mark OPEN QUERY br-mark FOR EACH X_marking-line NO-LOCK by X_marking-line.fact-order desc by X_marking-line.date_ desc INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-mark X_marking-line
&Scoped-define FIRST-TABLE-IN-QUERY-br-mark X_marking-line


/* Definitions for DIALOG-BOX d-mark                                    */
&Scoped-define OPEN-BROWSERS-IN-QUERY-d-mark ~
    ~{&OPEN-QUERY-br-mark}
    
/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit B-1 v-mark b-hist b-sostav v-mark-2 ~
f-last-change f-status emission_Date Btn_dateOther expire_Date ~
f-online-result Btn_rn br-mark Btn_pn 
&Scoped-Define DISPLAYED-OBJECTS v-mark f-GTIN v-mark-2 f-last-change ~
f-status f-gds-name f-gds-code mrc f-obj-code f-obj-type f-weight ~
produced_Date emission_Date expire_Date f-online-result f-rn ~
f-unit f-unit-2 f-loc-key f-pn 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD GdsName d-mark 
FUNCTION GdsName RETURNS CHARACTER
  ( input p-gds-code as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD GdsUnit d-mark 
FUNCTION GdsUnit RETURNS CHARACTER
  ( input p-gds-code as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD StatusName d-mark 
FUNCTION StatusName RETURNS CHARACTER
  ( input p-sts as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-1 
     LABEL "Button 1" 
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-GO 
     LABEL "&Выход ":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-hist 
     IMAGE-UP FILE "cmp/b-hist.bmp":U
     IMAGE-DOWN FILE "cmp/b-hist.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/b-hist.bmp":U NO-CONVERT-3D-COLORS
     LABEL "Ис&тория" 
     SIZE 3 BY 1.

DEFINE BUTTON b-sostav 
     IMAGE-UP FILE "cmp/b-file.bmp":U
     IMAGE-DOWN FILE "cmp/b-filed.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/b-file.bmp":U
     LABEL "" 
     SIZE 5 BY 1.14 TOOLTIP "Посмотреть состав марки".

DEFINE BUTTON Btn_dateOther 
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U NO-CONVERT-3D-COLORS
     LABEL "" 
     SIZE 3 BY 1 TOOLTIP "Годен до (иные условия хранения)".

DEFINE BUTTON Btn_pn 
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U NO-CONVERT-3D-COLORS
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON Btn_rn 
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U NO-CONVERT-3D-COLORS
     LABEL "" 
     SIZE 3 BY 1.

DEFINE VARIABLE f-online-result AS INTEGER FORMAT "-9":U INITIAL ? 
     VIEW-AS COMBO-BOX INNER-LINES 4
     LIST-ITEM-PAIRS "",-1,
                     "Запрет продажи",0,
                     "Продажа разрешена",1,
                     "Необходимо проверить сроки годности",2
     DROP-DOWN-LIST
     SIZE 39.25 BY 1 NO-UNDO.

DEFINE VARIABLE f-status AS INTEGER FORMAT "->>9":U INITIAL -1 
     VIEW-AS COMBO-BOX INNER-LINES 7
     LIST-ITEM-PAIRS "",-1
     DROP-DOWN-LIST
     SIZE 39.25 BY 1 NO-UNDO.

DEFINE VARIABLE emission_Date AS CHARACTER FORMAT "X(256)":U 
     LABEL "Дата эмиссии кода маркировки" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE expire_Date AS character FORMAT "X(20)":U 
     LABEL "Срок годности" 
     VIEW-AS FILL-IN 
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE f-gds-code AS CHARACTER FORMAT "X(256)":U 
     LABEL "Код" 
     VIEW-AS FILL-IN 
     SIZE 21 BY 1 NO-UNDO.

DEFINE VARIABLE f-gds-name AS CHARACTER FORMAT "X(256)":U 
     LABEL "Наименование" 
     VIEW-AS FILL-IN 
     SIZE 44 BY 1 NO-UNDO.

DEFINE VARIABLE f-GTIN AS CHARACTER FORMAT "X(256)":U 
     LABEL "GTIN" 
     VIEW-AS FILL-IN 
     SIZE 44 BY 1 NO-UNDO.

DEFINE VARIABLE f-last-change AS DATETIME FORMAT "99/99/99 HH:MM:SS":U 
     LABEL "Изменен" 
     VIEW-AS FILL-IN 
     SIZE 44 BY 1 TOOLTIP "Дата и время изменения статуса" NO-UNDO.

DEFINE VARIABLE f-loc-key AS CHARACTER FORMAT "X(256)":U 
     LABEL "Блокировка марки" 
     VIEW-AS FILL-IN 
     SIZE 44 BY 1 NO-UNDO.

DEFINE VARIABLE f-obj-code AS INTEGER FORMAT ">>>>>>>>>>>9":U INITIAL 0 
     LABEL "Объект" 
     VIEW-AS FILL-IN 
     SIZE 7.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-obj-type AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 7.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-pn AS CHARACTER FORMAT "X(256)":U 
     LABEL "ПН" 
     VIEW-AS FILL-IN 
     SIZE 21 BY 1 NO-UNDO.

DEFINE VARIABLE f-rn AS CHARACTER FORMAT "X(256)":U 
     LABEL "Документ" 
     VIEW-AS FILL-IN 
     SIZE 21 BY 1 NO-UNDO.

DEFINE VARIABLE f-unit AS CHARACTER FORMAT "X(256)":U 
     LABEL "Ед.изм. EDO" 
     VIEW-AS FILL-IN 
     SIZE 7.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-unit-2 AS CHARACTER FORMAT "X(256)":U 
     LABEL "Ед.изм." 
     VIEW-AS FILL-IN 
     SIZE 7.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-weight AS CHARACTER FORMAT "X(40)":U 
     LABEL "Вес" 
     VIEW-AS FILL-IN      
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE mrc AS CHARACTER FORMAT "X(256)":U 
     LABEL "МРЦ" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE produced_Date AS CHARACTER FORMAT "X(256)":U 
     LABEL "Дата нанесения кода маркировки" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE v-mark AS CHARACTER FORMAT "X(255)" 
     LABEL "Марка" 
     VIEW-AS FILL-IN 
     SIZE 75.63 BY 1.

DEFINE VARIABLE v-mark-2 AS CHARACTER FORMAT "X(255)" 
     LABEL "Марка" 
     VIEW-AS FILL-IN 
     SIZE 44 BY 1.

DEFINE VARIABLE online-check AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
    SIZE 5 BY .81 NO-UNDO.


{ gbl/objsrv.i }
def var Marking as class mark no-undo .

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD EdoTypeName d-utd 
FUNCTION EdoTypeName RETURNS CHARACTER
  (input p-stsTH as integer)  .
  Return ObjSrv:Env:Utd:EDocType:GetLabel(p-stsTH) .
END FUNCTION .  
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-mark FOR 
  X_marking-line SCROLLING.
&ANALYZE-RESUME
/* Browse definitions                                                   */
DEFINE BROWSE br-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-mark d-mark _STRUCTURED
  QUERY br-mark NO-LOCK DISPLAY
  X_marking-line.doc-type COLUMN-LABEL "Тип" FORMAT "X(35)":U
  X_marking-line.date_ COLUMN-LABEL "Дата" FORMAT "99.99.9999":U width 30
  X_marking-line.out-code COLUMN-LABEL "Номер документа" FORMAT "x(30)":U
  string(X_marking-line.obj-code) + " " + X_marking-line.obj-type COLUMN-LABEL "Объект" FORMAT "x(20)":U 
  X_marking-line.doc-level COLUMN-LABEL "Уровень" FORMAT "-99":U
  /*  StatusName(integer(X_marking-line.sts)) COLUMN-LABEL "Статус" FORMAT "X(45)":U*/
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 106.5 BY 12.75 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-mark
     b-exit AT ROW 1 COL 1.38
     B-1 AT ROW 1 COL 11.63 WIDGET-ID 248
     v-mark AT ROW 1.08 COL 27.63 COLON-ALIGNED WIDGET-ID 34
     b-hist AT ROW 1.08 COL 106
     b-sostav AT ROW 2.19 COL 57 WIDGET-ID 294
     f-GTIN AT ROW 2.21 COL 67 COLON-ALIGNED WIDGET-ID 220
     v-mark-2 AT ROW 2.25 COL 10.63 COLON-ALIGNED WIDGET-ID 252
     f-last-change AT ROW 3.38 COL 67 COLON-ALIGNED WIDGET-ID 268
     f-status AT ROW 3.42 COL 10.63 COLON-ALIGNED NO-LABEL WIDGET-ID 218
     f-gds-name AT ROW 4.54 COL 67 COLON-ALIGNED WIDGET-ID 222
     f-gds-code AT ROW 4.63 COL 10.63 COLON-ALIGNED WIDGET-ID 224
     mrc AT ROW 5.67 COL 82 RIGHT-ALIGNED WIDGET-ID 266
     f-obj-code AT ROW 5.75 COL 10.63 COLON-ALIGNED WIDGET-ID 256
     f-obj-type AT ROW 5.75 COL 18.75 COLON-ALIGNED NO-LABEL WIDGET-ID 258
     f-weight AT ROW 5.75 COL 107 RIGHT-ALIGNED WIDGET-ID 294
     produced_Date AT ROW 6.75 COL 82 RIGHT-ALIGNED WIDGET-ID 262
     emission_Date AT ROW 7.83 COL 82 RIGHT-ALIGNED WIDGET-ID 264
     Btn_dateOther AT ROW 8.92 COL 89 WIDGET-ID 292
     expire_Date AT ROW 8.96 COL 88 RIGHT-ALIGNED WIDGET-ID 290
     online-check AT ROW 9.96 COL 22.38 WIDGET-ID 274
     f-online-result AT ROW 10.04 COL 67 COLON-ALIGNED NO-LABEL WIDGET-ID 278
     f-rn AT ROW 11.25 COL 10.63 COLON-ALIGNED WIDGET-ID 246
     Btn_rn AT ROW 11.25 COL 34.25 WIDGET-ID 250
     f-unit AT ROW 11.25 COL 81.25 COLON-ALIGNED WIDGET-ID 226
     f-unit-2 AT ROW 11.25 COL 107.25 RIGHT-ALIGNED WIDGET-ID 254
     br-mark AT ROW 12.25 COL 3.38 WIDGET-ID 200
     f-loc-key AT ROW 25.21 COL 21 COLON-ALIGNED WIDGET-ID 260
     f-pn AT ROW 25.21 COL 81 COLON-ALIGNED WIDGET-ID 244
     Btn_pn AT ROW 25.5 COL 104.75 WIDGET-ID 68
     "Результат online-проверки ГИС МТ:" VIEW-AS TEXT
          SIZE 36 BY .63 AT ROW 10.25 COL 35 WIDGET-ID 288
     "Статус:" VIEW-AS TEXT
          SIZE 8 BY .63 AT ROW 3.75 COL 4.38 WIDGET-ID 272
     SPACE(83.24) SKIP(15.44)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Движение марки":L.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Temp-Tables and Buffers:
      TABLE: X_marking B "NEW SHARED" ? ub marking
      TABLE: X_marking-lines B "NEW SHARED" ? ub marking-lines
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-mark
   FRAME-NAME                                                           */
/* BROWSE-TAB br-mark f-unit-2 d-mark */
ASSIGN 
       FRAME d-mark:SCROLLABLE       = FALSE.

/* SETTINGS FOR FILL-IN emission_Date IN FRAME d-mark
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN expire_Date IN FRAME d-mark
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN f-gds-code IN FRAME d-mark
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-gds-name IN FRAME d-mark
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-GTIN IN FRAME d-mark
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-loc-key IN FRAME d-mark
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-obj-code IN FRAME d-mark
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-obj-type IN FRAME d-mark
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-pn IN FRAME d-mark
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-rn IN FRAME d-mark
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-status IN FRAME d-mark
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-unit IN FRAME d-mark
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-unit-2 IN FRAME d-mark
   NO-ENABLE ALIGN-R                                                    */
/* SETTINGS FOR FILL-IN f-weight IN FRAME d-mark
   NO-ENABLE ALIGN-R                                                    */
/* SETTINGS FOR FILL-IN mrc IN FRAME d-mark
   NO-ENABLE ALIGN-R                                                    */
/* SETTINGS FOR FILL-IN produced_Date IN FRAME d-mark
   NO-ENABLE ALIGN-R                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define BROWSE-NAME br-mark
&Scoped-define SELF-NAME br-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-mark d-mark
ON value-changed OF br-mark IN FRAME d-mark
DO:
    run enable_mark .
  END .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME Btn_dateOther
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_dateOther d-mark
ON CHOOSE OF Btn_dateOther IN FRAME d-mark
DO:
   define variable kk as integer no-undo .
   define variable dateOther as character no-undo .
   define variable dateOtherMes as character no-undo .
   do kk = 1 to num-entries(expire_DateOther):
       dateOtherMes = entry(1,entry(kk,expire_DateOther),".") .
       dateOtherMes = replace(dateOtherMes,"/",".") .
       if kk = 1 then dateOther = " " + dateOtherMes .
       else dateOther = dateOther + {&new-line} + dateOtherMes .
   end.

message dateOther 
view-as alert-box title "Иные условия хранения".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME f-status
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-status d-mark
ON value-changed OF f-status IN FRAME d-mark
DO:
   assign 
     f-status
   .
END .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-online-result
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-online-results d-mark
ON value-changed OF f-online-result IN FRAME d-mark
DO:
   assign 
     f-online-result
   .
END .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_pn
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_pn d-mark
ON CHOOSE OF Btn_pn IN FRAME d-mark
DO:
    { gbl/stdbtn.i }
run show-in-code in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit d-mark
ON CHOOSE OF b-exit IN FRAME d-mark /* Выход  */
DO:
  define buffer b_marking for ub.marking.
  define buffer buf_marking-attr for ub.marking-attr.

  if available buf_marking then
  do:
    if online-check:sensitive then
    do:  
        assign online-check.
        find first buf_marking-attr where 
                   buf_marking-attr.attr-code = "notOnlineCheck"
               and buf_marking-attr.mark begins buf_marking.mark
             exclusive-lock no-error.
        if (available buf_marking-attr and buf_marking-attr.attr-value <> string(online-check))
           or (not available buf_marking-attr and online-check) then
        do:
          if available buf_marking-attr and not online-check then 
          do:
            delete buf_marking-attr.
          end.
          else do:
            if not available buf_marking-attr then
            do:
              create buf_marking-attr.
              assign
                buf_marking-attr.mark = buf_marking.mark
                buf_marking-attr.attr-code = "notOnlineCheck"
              .
            end.
            buf_marking-attr.attr-value = string(online-check).
          end.
        end.
    end.
    if buf_marking.sts <> f-status then do:
      message "У марки был изменен статус.~nСохранить?" view-as alert-box question buttons yes-no 
        update isSave as logical.
      if isSave then do:
        find first b_marking where rowid(b_marking) = rowid(buf_marking) exclusive-lock.
        assign
          b_marking.sts = f-status
          b_marking.last-change = now 
        .      
      end.
    end.

    if buf_marking.online-result <> (if f-online-result = -1 then ? else f-online-result) then do:
      message "У марки был изменен результат online-проверки ГИС МТ.~nСохранить?" view-as alert-box question buttons yes-no 
        update isSaveResult as logical.
      if isSaveResult then do:
        find first b_marking where rowid(b_marking) = rowid(buf_marking) exclusive-lock.
        assign
          b_marking.online-result = if f-online-result = -1 then ? else f-online-result 
        .      
      end.
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_rn
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_rn d-mark
ON CHOOSE OF Btn_rn IN FRAME d-mark
DO:
        { gbl/stdbtn.i }
if X_marking-line.type <> 1  then do:

run show-out-code in this-procedure .
end.
else do:
        run str/upd_browse.w (input parparentproc,
        input x_marking-line.doc-id,
        input x_marking-line.db-num,
        input x_marking-line.EDocType,
        input {&lookup},
        input ?
        ) no-error .
end.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-mark d-mark
ON return OF v-mark IN FRAME d-mark /* Марка */
DO:
    define variable v_list as character no-undo .
    define variable ii     as integer   no-undo.
    assign 
      v-mark = v-mark:screen-value .

    ASSIGN 
      v_list = 'Ё,Й,Ц,У,К,Е,Н,Г,Ш,Щ,З,Х,Ъ,Ф,Ы,В,А,П,Р,О,Л,Д,Ж,Э,Я,Ч,С,М,И,Т,Ь,Б,Ю':U .
  
    /*проверка на русские буквы*/
    do ii = 1 to length (v-mark):
      if LOOKUP( SUBSTRING( v-mark, ii, 1 ), v_list )  > 1 then
      do:
        message "Не корректно считана акцизная марка, перед считыванием переключите клавиатуру на английскую раскладку."
          view-as alert-box.
        v-mark:screen-value = "" .
        v-mark = "" . 
        return .  
      end.
    end.
  
    /*Проверка марки*/
    run init-temp .
    run enable_mark .
    v-mark:screen-value = "" .
    v-mark = "" . 
    display 
      with frame {&frame-name} .
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist d-mark
ON CHOOSE OF B-hist IN FRAME d-mark /* История */
DO:
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-undo.
  IF available buf_marking THEN DO:
    run ref/cmarking.w (
              buf_marking.mark, 
              parparentproc,
              0,
              "",
              0,
              "",
              "one",
              ?,
              "",
              "" ,
              v-cntxt-db-num,
              ?,
              input-output v-rid-list ) .
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sostav
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sostav d-mark
ON CHOOSE OF b-sostav IN FRAME d-mark /* Состав марки */
DO:
  define buffer bf_marking for ub.marking.  
    
  if v-mark-2 = "" then return no-apply.
  
  if can-find(first bf_marking where bf_marking.mark-parent begins v-mark-2)
  then do:
      empty temp-table tt-marking-lines.
      for first bf_marking no-lock where 
                bf_marking.mark begins v-mark-2:
        create tt-marking-lines .
        assign
          tt-marking-lines.gds-name    = GdsName(bf_marking.gds-code)
          tt-marking-lines.mark        = bf_marking.mark
          tt-marking-lines.gds-code    = bf_marking.gds-code
          tt-marking-lines.isMark      = IsMark(tt-marking-lines.mark)    
          tt-marking-lines.sts         = bf_marking.sts
          tt-marking-lines.unit        = bf_marking.unit
          tt-marking-lines.unit-ext    = bf_marking.unit-ext
          tt-marking-lines.box-qnty    = bf_marking.box-qnty  when tt-marking-lines.box-qnty eq 0 or tt-marking-lines.box-qnty eq ?
          tt-marking-lines.mark-parent = bf_marking.mark-parent
          tt-marking-lines.stts        = Marking:GetLabel(bf_marking.sts)
          tt-marking-lines.doc-level   = 1
        .
                    
      end.
      for each bf_marking no-lock where 
                bf_marking.mark-parent begins v-mark-2:
        create tt-marking-lines .
        assign
          tt-marking-lines.gds-name    = GdsName(bf_marking.gds-code)
          tt-marking-lines.mark        = bf_marking.mark
          tt-marking-lines.gds-code    = bf_marking.gds-code
          tt-marking-lines.isMark      = IsMark(tt-marking-lines.mark)    
          tt-marking-lines.sts         = bf_marking.sts
          tt-marking-lines.unit        = bf_marking.unit
          tt-marking-lines.unit-ext    = bf_marking.unit-ext
          tt-marking-lines.box-qnty    = bf_marking.box-qnty  when tt-marking-lines.box-qnty eq 0 or tt-marking-lines.box-qnty eq ?
          tt-marking-lines.mark-parent = bf_marking.mark-parent
          tt-marking-lines.stts        = Marking:GetLabel(bf_marking.sts)
          tt-marking-lines.doc-level   = 2
        .
                    
      end.
      if available (tt-marking-lines) then 
      do:
        run str/mark_browse.w (input parparentproc,
           input-output table tt-marking-lines by-reference,
           input {&lookup},
           input "Состав марки " + v-mark-2,
           input 0,
           input ""
           ) no-error .
      end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-mark 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
  THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} 
  APPLY "END-ERROR":U TO SELF.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }
  Marking = ObjSrv:Env:Marking:Sts:Mark. .
  if p-mark <> "" then v-mark = p-mark .
  run LoadKeyboardLayoutA (input v-mark, input 0, output iLang).
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

  /*Проверка прав на изменение статуса марки */
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_mark_stchange':U
    {&cntxt-firm}
    v-cntxt-host-code-obj
    '':U
    0
    0
    0
    0
    false
    canEditStatus
  }
  /*Проверка прав на изменение признака марки Игнорироать online-проверку*/
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_mark_online_check':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    false
    canEditOnlineCheck
  }
  run init-status in this-procedure .
  run init-temp in this-procedure .
  run enable_UI in this-procedure .
  run enable_mark in this-procedure .
  apply "entry" to v-mark in FRAME {&FRAME-NAME}.
  if p-mark <> "" then WAIT-FOR GO OF FRAME {&FRAME-NAME} focus {&browse-name}.
  else WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS v-mark.
  
END.
run disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-mark  _DEFAULT-DISABLE
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
  HIDE FRAME d-mark.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_mark d-mark 
PROCEDURE enable_mark :
/* --------------------------------------------------------------------
                  Purpose:     ENABLE the User Interface
                  Parameters:  <none>
                  Notes:       Here we display/view/enable the widgets in the
                               user-interface.  In addition, OPEN all queries
                               associated with each FRAME and BROWSE.
                               These statements here are based on the "Other
                               Settings" section of the widget Property Sheets.
                   -------------------------------------------------------------------- */
  display 
    f-last-change
    f-gds-code
    f-obj-code
    f-obj-type
    f-gds-name
    f-unit
    f-unit-2
    f-GTIN
    v-mark-2
    f-loc-key
    mrc
    f-weight
    produced_Date
    emission_Date
    expire_Date
    with frame {&frame-name} .
  
  hide online-check in frame {&frame-name} .
  
  if expire_DateOther <> "" and expire_DateOther <> ? then enable Btn_dateOther with frame {&frame-name} .
  else disable Btn_dateOther with frame {&frame-name} .
  if available (buf_marking) then do:
    display f-status f-online-result with frame {&frame-name} .
    if canEditStatus then
      enable f-status with frame {&frame-name} .
    if canEditOnlineCheck then
      enable f-online-result with frame {&frame-name} .
  end.
  else do:
    hide f-status f-online-result in frame {&frame-name} .
  end.
  if available (buf_marking) and buf_marking.sts = Marking:MarkError:KeyIntDB then do:
    f-status:fgcolor in frame {&frame-name} = 12.
  end.   
  if available (X_marking-line) then 
  do:

    f-pn = X_marking-line.in-code .
    f-rn = X_marking-line.out-code .
    display
      f-pn
      f-rn
      with frame {&frame-name} .   
    if f-pn <> "" and f-pn <> {&free-code} and f-pn <> {&output-code} then 
    do:
      display
        f-pn
        with frame {&frame-name} .
      enable 
        Btn_pn
        with frame {&frame-name} .
    end.  
    if f-rn <> "" and f-rn <> {&free-code} and f-rn <> {&output-code} then 
    do:
      display
        f-rn
        with frame {&frame-name} .
      enable 
        Btn_rn
        with frame {&frame-name} .
    end. 
    end. 
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-mark 
PROCEDURE enable_UI :
/* --------------------------------------------------------------------
                  Purpose:     ENABLE the User Interface
                  Parameters:  <none>
                  Notes:       Here we display/view/enable the widgets in the
                               user-interface.  In addition, OPEN all queries
                               associated with each FRAME and BROWSE.
                               These statements here are based on the "Other
                               Settings" section of the widget Property Sheets.
                   -------------------------------------------------------------------- */

  ENABLE
    br-mark
    b-exit
    b-hist
    b-sostav
    WITH FRAME {&frame-name}.
  hide B-1 in frame {&frame-name} .
  if p-mark <> "" then 
  do:
    hide
      v-mark
      in FRAME {&FRAME-NAME} .
  end.  
  else 
  do:
    enable
      v-mark
      WITH FRAME {&FRAME-NAME} .
  end.  
  if f-pn <> "" and f-pn <> {&free-code} and f-pn <> {&output-code} then
  do:
    display
      f-pn
      with frame {&frame-name} .
    enable 
      Btn_pn
      with frame {&frame-name} .
  end.  
  if f-rn <> "" and f-rn <> {&free-code} and f-rn <> {&output-code} then 
  do:
    display
      f-rn
      with frame {&frame-name} .
    enable 
      Btn_rn
      with frame {&frame-name} .
  end.

  display
    f-gds-name
    f-obj-code
    f-obj-type
    f-gds-code
    f-unit
    f-unit-2
    f-GTIN
    v-mark-2
    f-loc-key
    with frame {&frame-name} .    
  hide f-status f-online-result in frame {&frame-name} .   
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-status d-mark 
PROCEDURE init-status :
  define variable vi as integer no-undo.
  define variable MarkType as ibs.th.gbl.map.mapstring no-undo.
  define variable objMark  as ibs.th.gbl.propmap no-undo.
  do with frame {&frame-name}:
/*    f-status:delete(1).*/
    MarkType = ObjSrv:Env:Marking:Sts:Mark:MAPTYPE.
    do vi = 1 to MarkType:GetItemByLab(vi):
      objMark  = ObjSrv:Env:Marking:Sts:Mark:CurrProp.
      f-status:add-last(objMark:Label_, objMark:KeyIntDB).
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-temp d-mark 
PROCEDURE init-temp :
/* --------------------------------------------------------------------
                  Purpose:     ENABLE the User Interface
                  Parameters:  <none>
                  Notes:       Here we display/view/enable the widgets in the
                               user-interface.  In addition, OPEN all queries
                               associated with each FRAME and BROWSE.
                               These statements here are based on the "Other
                               Settings" section of the widget Property Sheets.
                   -------------------------------------------------------------------- */
  /*GTIN в любом случае показывать*/
  release buf_marking. 
  empty temp-table X_marking-line.

  /*  f-GTIN:screen-value =*/
  assign
      f-GTIN = "" 
      f-gds-code = "" 
      f-gds-name = "" 
      f-status = 0 
      f-last-change = ? 
      /*соответствие товаров*/
      f-unit     = ""      
      f-unit-2   = ""  
      f-obj-code = ? 
      f-obj-type = ""    
      v-mark-2 = "" 
      f-loc-key = "" 
      f-pn = "" 
      f-rn = "" 
      mrc  = "" 
      f-weight = "" 
      emission_Date = "" 
      produced_Date = ""       
      f-online-result = -1
      online-check  = no 
      .

  if v-mark <> "" then 
  do:
/*	 mMRCCode = yes .*/
  v-marking = GetCodeIdent(v-mark) .

  v-mark-2   = v-marking .
  if v-marking <> "" and v-marking <> ? then do:
    find first buf_marking no-lock where buf_marking.mark begins v-marking 
/*    and buf_marking.obj-code = v-cntxt-obj-code and buf_marking.obj-type = v-cntxt-obj-type*/
    no-error .
    if available (buf_marking) then 
    do:
         assign
           f-status = buf_marking.sts 
           f-online-result = if buf_marking.online-result = ? then -1 else buf_marking.online-result
           f-last-change = buf_marking.last-change 
           /*соответствие товаров*/
           f-gds-code = string(buf_marking.gds-code) 
           f-gds-name = GdsName(buf_marking.gds-code) 
           f-unit     = buf_marking.unit-ext      
           f-GTIN     = buf_marking.gds-ext-id 
           f-unit-2   = buf_marking.unit  
           f-obj-code = buf_marking.obj-code 
           f-obj-type = buf_marking.obj-type 
           f-loc-key = buf_marking.loc-key 
           expire_Date = entry(1,buf_marking.expDate,".") 
           expire_Date = replace(expire_Date,"/",".")    
           expire_DateOther = buf_marking.expDateOther                   
           .
        
         for first buf_marking-attr no-lock where buf_marking-attr.attr-code = "MRC"
                                              and buf_marking-attr.mark = buf_marking.mark:
            mrc = buf_marking-attr.attr-value .                                              
         end.                                                
         for first buf_marking-attr no-lock where buf_marking-attr.attr-code = "emissionDate"
                                              and buf_marking-attr.mark = buf_marking.mark:
            emission_Date = buf_marking-attr.attr-value .                                              
         end.                                  
         for first buf_marking-attr no-lock where buf_marking-attr.attr-code = "producedDate"
                                              and buf_marking-attr.mark = buf_marking.mark:
            produced_Date = buf_marking-attr.attr-value .                                              
         end.                                       
/*         for first buf_marking-attr no-lock where buf_marking-attr.attr-code = "notOnlineCheck"*/
/*                                              and buf_marking-attr.mark = buf_marking.mark:    */
/*            online-check = logical(buf_marking-attr.attr-value).                               */
/*         end.                                                                                  */
         for first buf_marking-attr no-lock where buf_marking-attr.attr-code = "weight"
                                              and buf_marking-attr.mark = buf_marking.mark:
            f-weight = if decimal(buf_marking-attr.attr-value) < 1 and  decimal(buf_marking-attr.attr-value) >= 0 
                          then string(decimal(buf_marking-attr.attr-value),"9.999") 
                          else buf_marking-attr.attr-value.
            f-weight = substitute("&1 &2",f-weight, GdsUnit(buf_marking.gds-code)).                                              
         end.   
                                          
         for each buf_marking-lines no-lock where buf_marking-lines.mark begins v-marking:
            /*      if NumUPD = "" then NumUPD = buf_marking-lines.DocumentExt .*/
            create X_marking-line .
            buffer-copy buf_marking-lines to X_marking-line .
            X_marking-line.gds-code = buf_marking.gds-code .
        
            find first buf_trn-doc no-lock where buf_trn-doc.doc-code = if buf_marking-lines.out-code <> {&output-code} 
                                             and buf_marking-lines.out-code <> {&free-code} then buf_marking-lines.out-code else buf_marking-lines.in-code 
               no-error .
            if available (buf_trn-doc) then do:
                X_marking-line.date_ = buf_trn-doc.doc-date .
                X_marking-line.doc-type = func-get-name-from-ext-type(buf_trn-doc.ext-doc-type,no) .
                if X_marking-line.fact-order = 0 then X_marking-line.fact-order = 1 .
            end.            
         end.  
         for each buf_utd-marking-lines no-lock where buf_utd-marking-lines.mark begins v-marking:
            for first buf_utd no-lock where buf_utd.doc-id = buf_utd-marking-lines.doc-id 
                                        and buf_utd.db-num = buf_utd-marking-lines.db-num:  
                create X_marking-line .
                assign
                  X_marking-line.doc-type    = EdoTypeName(buf_utd.EDocType)
                  X_marking-line.mark        = buf_marking.mark
                  X_marking-line.out-code    = buf_utd.DocumentNumber
                  X_marking-line.date_       = buf_utd.DocumentDate
                  X_marking-line.sts         = buf_utd-marking-lines.sts
                  X_marking-line.type        = 1
                  X_marking-line.obj-code    = buf_utd.obj-code
                  X_marking-line.obj-type    = buf_utd.obj-type
                  X_marking-line.doc-id      = buf_utd.doc-id
                  X_marking-line.db-num      = buf_utd.db-num
                  X_marking-line.EdocType    = buf_utd.EdocType
                .
            end.
         end.  
    end. /* available (buf_marking) */
    else do:
      assign  
         f-GTIN = getGtinByDM(v-mark) 
         f-gds-code = string(getGdsCodeByGtin(f-GTIN)) 
         f-gds-name = GdsName(integer(f-gds-code)) 
         .      
    end.  
  end.   /* v-marking <> "" and v-marking <> ? */  
  end.  /* v-mark <> "" */
        
  {&OPEN-QUERY-br-mark}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE show-in-code d-mark 
PROCEDURE show-in-code :
/* -----------------------------------------------------------
    Purpose:
    Parameters:  <none>
    Notes:
  -------------------------------------------------------------*/
  /* показать складской документ */
  for first ub.marking-lines no-lock where ub.marking-lines.mark = buf_marking.mark,
    first ub.goods no-lock where ub.goods.gds-code = ub.marking-lines.gds-code:

    run str/showdoc.p
      (input parparentproc      /* parparentproc */
      ,input f-pn   /* p-doc-code    */
      ,input ub.goods.artic     /* p-artic       */
      ,input ub.goods.prod-type /* p-prod-type   */
      ,input ub.goods.prod-code /* p-prod-code   */
      ,input true               /* p-doc-type    */
      ).
  end.
  apply "entry":u to br-mark in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE show-out-code d-mark 
PROCEDURE show-out-code :
/* -----------------------------------------------------------
    Purpose:
    Parameters:  <none>
    Notes:
  -------------------------------------------------------------*/
  /* показать складской документ */
  for first ub.marking-lines no-lock where ub.marking-lines.mark = buf_marking.mark,
    first ub.goods no-lock where ub.goods.gds-code = ub.marking-lines.gds-code:

    run str/showdoc.p
      (input parparentproc      /* parparentproc */
      ,input f-rn   /* p-doc-code    */
      ,input ub.goods.artic     /* p-artic       */
      ,input ub.goods.prod-type /* p-prod-type   */
      ,input ub.goods.prod-code /* p-prod-code   */
      ,input true               /* p-doc-type    */
      ).
  
    apply "entry":u to br-mark in frame {&frame-name}.
  end.
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION GdsName d-mark 
FUNCTION GdsName RETURNS CHARACTER
  ( input p-gds-code as integer ) :
  /*------------------------------------------------------------------------------
    Purpose:  
      Notes:  
  ------------------------------------------------------------------------------*/
  define buffer buf_goods for ub.goods .
  define variable v-gds-name as character no-undo . 
  find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
  if available (buf_goods) then v-gds-name = buf_goods.gds-name .
  RETURN v-gds-name.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION GdsName d-mark 
FUNCTION GdsUnit RETURNS CHARACTER
  ( input p-gds-code as integer ) :
  /*------------------------------------------------------------------------------
    Purpose:  
      Notes:  
  ------------------------------------------------------------------------------*/
  define buffer buf_goods for ub.goods .
  define variable v-gds-unit as character no-undo . 
  find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
  if available (buf_goods) then v-gds-unit = buf_goods.unit-base .
  RETURN v-gds-unit.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION StatusName d-mark 
FUNCTION StatusName RETURNS CHARACTER
  ( input p-sts as integer ) :
  /*------------------------------------------------------------------------------
    Purpose:  
      Notes:  
  ------------------------------------------------------------------------------*/

  Return Marking:GetLabel(p-sts) .  


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME v-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-mark d-mark
ON ENTRY OF v-mark IN FRAME d-mark /* Марка */
DO:
            run LoadKeyboardLayoutA (input v-mark, input 0, output iLang).
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE LoadKeyboardLayoutA d-utd
procedure LoadKeyboardLayoutA external "user32" :
    define input  parameter P1 as char.
    define input  parameter P2 as LONG.
    define return parameter pret as LONG.
end procedure.
        
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME 
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ActivateKeyboardLayout d-utd 
procedure ActivateKeyboardLayout external "user32" :
    define input parameter P1 as LONG.
    define input parameter P2 as LONG.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME