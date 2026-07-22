&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME f-okei2


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf-code FOR Code.
DEFINE TEMP-TABLE tt_code NO-UNDO LIKE code
  .



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS f-okei2 
/*

$Revision: $
$Author: $
$Date: $
$Workfile: $
$Archive: $

Типы маркировки

Автор: Белова Марина
Дата создания: 08/02/2024
Author: Belova Marina
Creation date: 08/02/2024

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

{ ref/codepar.i}

define variable vss-revision    as character no-undo init "$Revision: $":U .
define variable vss-author      as character no-undo init "$Author: $":U .
define variable vss-date        as character no-undo init "$Date: $":U .
define variable vss-workfile    as character no-undo init "$Workfile: $":U .
define variable vss-archive     as character no-undo init "$Archive: $":U .
define variable vss-description as character no-undo init "Типы маркировки".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/r-pril.i new }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ gbl/prn-lib.i }
{ gbl/waitfram.i }
{ cmp/mrk-strf.i }

&Scoped-define BEF_CODE_PARENT MarkType
&Scoped-define CODE_PARENT "{&BEF_CODE_PARENT}"

/* Local Variable Definitions ---                                       */

define variable log-res     as log       no-undo.
define variable v-rid       as recid     no-undo .
define variable v-db-num like ub.db.db-num no-undo .
define variable vIsUpdated as logical no-undo.
define stream out-xml.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f-okei2
&Scoped-define BROWSE-NAME BROWSE-5

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt_code

/* Definitions for BROWSE BROWSE-5                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-5 tt_code.code tt_code.CodeValue ~
tt_code.CodeName INTEGER (tt_code.misc1) ~
if logical(tt_code.misc2) then "+" else "-" ~
string(int(tt_code.misc4),"HH:MM") + " " + replace(tt_code.misc3,"/", ".") 
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-5 
&Scoped-define QUERY-STRING-BROWSE-5 FOR EACH tt_code NO-LOCK ~
    BY tt_code.code INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-5 OPEN QUERY BROWSE-5 FOR EACH tt_code NO-LOCK ~
    BY tt_code.code INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-5 tt_code
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-5 tt_code


/* Definitions for DIALOG-BOX f-okei2                                   */
&Scoped-define OPEN-BROWSERS-IN-QUERY-f-okei2 ~
    ~{&OPEN-QUERY-BROWSE-5}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-add b-upd b-del b-xml b-print ~
b-help 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add 
     LABEL "&Добавить":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-del 
     LABEL "&Удалить":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-GO 
     LABEL "&Выход ":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-help 
     LABEL "Помо&щь":L 
     SIZE 3 BY 1.

DEFINE BUTTON b-print 
     LABEL "Пе&чать":L 
     SIZE 3 BY 1.

DEFINE BUTTON b-upd 
     LABEL "&Изменить":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-xml 
     LABEL "Выгрузить" 
     SIZE 14 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-5 FOR 
      tt_code SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-5
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-5 f-okei2 _STRUCTURED
  QUERY BROWSE-5 NO-LOCK DISPLAY
      tt_code.code FORMAT "x(6)":U
      tt_code.CodeValue FORMAT "x(20)":U WIDTH 19.4
      tt_code.CodeName FORMAT "x(60)":U WIDTH 59.2
      INTEGER (tt_code.misc1) COLUMN-LABEL "Длина!серийного!номера" FORMAT ">>>>9":U
            WIDTH 12.2
      if logical(tt_code.misc2) then "+" else "-" COLUMN-LABEL "Конфигурация!для кассы" FORMAT "X":U
      string(int(tt_code.misc4),"HH:MM") + " " + replace(tt_code.misc3,"/", ".") COLUMN-LABEL "Дата/ Время" FORMAT "X(16)":U
            WIDTH 11
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 131 BY 17.62 ROW-HEIGHT-CHARS .76 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f-okei2
     b-exit AT ROW 1 COL 1
     b-add AT ROW 1 COL 14
     b-upd AT ROW 1 COL 24
     b-del AT ROW 1 COL 34 WIDGET-ID 2
     b-xml AT ROW 1 COL 44 WIDGET-ID 6
     b-print AT ROW 1 COL 122
     b-help AT ROW 1 COL 128
     BROWSE-5 AT ROW 2.91 COL 1 WIDGET-ID 300
     SPACE(0.19) SKIP(0.00)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Типы маркировки":L.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Temp-Tables and Buffers:
      TABLE: buf-code B "?" ? ub Code
      TABLE: tt_code T "?" NO-UNDO ub code
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX f-okei2
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-5 b-help f-okei2 */
ASSIGN 
       FRAME f-okei2:SCROLLABLE       = FALSE.

/* SETTINGS FOR BROWSE BROWSE-5 IN FRAME f-okei2
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-5
/* Query rebuild information for BROWSE BROWSE-5
     _TblList          = "Temp-Tables.tt_code"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _OrdList          = "Temp-Tables.tt_code.code|yes"
     _FldNameList[1]   > Temp-Tables.tt_code.code
"tt_code.code" ? "x(6)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > Temp-Tables.tt_code.CodeValue
"tt_code.CodeValue" ? ? "character" ? ? ? ? ? ? no ? no no "19.4" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > Temp-Tables.tt_code.CodeName
"tt_code.CodeName" ? ? "character" ? ? ? ? ? ? no ? no no "59.2" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > "_<CALC>"
"INTEGER (tt_code.misc1)" "Длина!серийного!номера" ">>>>9" ? ? ? ? ? ? ? no ? no no "12.2" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   > "_<CALC>"
"if logical(tt_code.misc2) then ""+"" else ""-""" "Конфигурация!для кассы" "X" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[6]   > "_<CALC>"
"string(int(tt_code.misc4),""HH:MM"") + "" "" + replace(tt_code.misc3,""/"", ""."")" "Дата/ Время" "X(16)" ? ? ? ? ? ? ? no ? no no "11" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE BROWSE-5 */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME f-okei2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-okei2 f-okei2
ON END-ERROR OF FRAME f-okei2 /* Типы маркировки */
DO:
    run checkChanges in this-procedure no-error.   
    if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-okei2 f-okei2
ON go OF FRAME f-okei2 /* Типы маркировки */
do:
    run checkChanges in this-procedure no-error.   
    if error-status:error then return no-apply.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add f-okei2
ON choose OF b-add IN FRAME f-okei2 /* Добавить */
do:
   define variable vCode      as character no-undo.
   define variable vCodeValue as character no-undo.
   define variable vCodeName  as character no-undo.
   define variable vMisc1     as character no-undo.
   define variable vMisc2     as character no-undo.
   define variable vMisc3     as character no-undo.
   define variable vMisc4     as character no-undo.
   define variable vId        as rowid     no-undo.
   define buffer buf_tt_code for tt_code.

   for last buf_tt_code no-lock
            by int(buf_tt_code.code):
       vCode = string(int(buf_tt_code.code) + 1).
   end.

   run ref/marktype.p (
                                input parparentproc
                              , input {&add-def}
                              , input-output vCode
                              , input-output vCodeValue
                              , input-output vCodeName
                              , input-output vMisc1
                              , input-output vMisc2
                              , input-output vMisc3
                              , input-output vMisc4
                              , output vIsUpdated
                       ).
   find first buf_tt_code where
              buf_tt_code.code = vCode
        no-lock no-error.
   if avail buf_tt_code then 
   do:
     message 
        "Ошибка добавления" skip
        "В справочнике уже есть тип маркировки с кодом " buf_tt_code.code "."  
        view-as alert-box.
     return no-apply.
   end.
   
   find first buf_tt_code where
              buf_tt_code.code = vCodeValue
        no-lock no-error.
   if avail buf_tt_code then 
   do:
     message 
        "Ошибка добавления" skip
        "В справочнике уже есть тип маркировки со значением " buf_tt_code.code "."  
        view-as alert-box.
     return no-apply.
   end.
   if vIsUpdated then 
   do:
       create tt_code.
       assign
         tt_code.parent = "MarkType"
         tt_code.code      = vCode 
         tt_code.codevalue = vCodeValue 
         tt_code.codename  = vCodeName 
         tt_code.misc1     = vMisc1 
         tt_code.misc2     = vMisc2 
         tt_code.misc3     = vMisc3 
         tt_code.misc4     = vMisc4 
         tt_code.export_ = yes 
         tt_code.status_ = 0
         tt_code.nwsgbd = yes
         vId            = rowid(tt_code)
       .
      {&OPEN-QUERY-BROWSE-5}
      reposition BROWSE-5 to rowid vId.
      apply "ENTRY" to BROWSE-5.
   end.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del f-okei2
ON choose OF b-del IN FRAME f-okei2 /* Удалить */
do:
   define buffer buf_code for code.
   define buffer buf-goods-attr for ub.goods-attr.
   
   if not avail tt_code then return.
   define variable v-ok as logical no-undo.
   define variable vCode as int no-undo.
   
   vCode = int(tt_code.code) no-error.
   if vCode <> ? and vCode > 0 and vCode < 17 then do:
       message "Нельзя удалять зарезервированные типы маркировки" view-as alert-box.
       return no-apply. 
   end.  
   
   find first buf_code where
              buf_code.parent = "MarkType"
          and buf_code.code   = tt_code.code
        no-lock no-error.
   if avail buf_code then
   do:
      message "Нельзя удалить тип марки уже загруженной в систему" view-as alert-box.
      return no-apply. 
   end.      
   
   /* нельзя удалять тип маркировки, указанный на продукте */
   find first  buf-goods-attr no-lock where
               buf-goods-attr.attr-code = {&attr-mark-type}                                                                                                                                                                           
           and buf-goods-attr.attr-value  = tt_code.codevalue 
           no-error .
   if avail buf-goods-attr then do:
      message "Нельзя удалить тип маркировки, указанный для товара" view-as alert-box.
       return no-apply. 
   end.    
   
   message "Удалить запись Тип маркировки - Код:" tt_code.code "Наименование:" tt_code.codename "?"
      view-as alert-box question
      buttons yes-no
      title "Удаление"
      update v-ok .
   if not v-ok then return no-apply.
   do on error undo, return
   on stop undo, return:
      delete tt_code.
      {&OPEN-QUERY-BROWSE-5}
      apply "ENTRY" to BROWSE-5.
      reposition {&browse-name} to row 1.
   end.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-upd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-upd f-okei2
ON choose OF b-upd IN FRAME f-okei2 /* Изменить */
do:
   define variable vCode      as character no-undo.
   define variable vCodeValue as character no-undo.
   define variable vCodeName  as character no-undo.
   define variable vMisc1     as character no-undo.
   define variable vMisc2     as character no-undo.
   define variable vMisc3     as character no-undo.
   define variable vMisc4     as character no-undo.
   define buffer buf_tt_code for tt_code.

   if not avail tt_code then return.
   assign
      vCode      = tt_code.code
      vCodeValue = tt_code.codevalue
      vCodeName  = tt_code.codename
      vMisc1     = tt_code.misc1
      vMisc2     = tt_code.misc2
      vMisc3     = tt_code.misc3
      vMisc4     = tt_code.misc4
   .
   
   run ref/marktype.p (
                                input parparentproc
                              , input {&update}
                              , input-output vCode
                              , input-output vCodeValue
                              , input-output vCodeName
                              , input-output vMisc1
                              , input-output vMisc2
                              , input-output vMisc3
                              , input-output vMisc4
                              , output vIsUpdated
                       ).
   if vCode <> tt_code.code then
   do:
       find first buf_tt_code where
                  buf_tt_code.code = vCode
            no-lock no-error.
       if avail buf_tt_code then 
       do:
         message 
            "Ошибка изменения" skip
            "В справочнике уже есть тип маркировки с кодом " buf_tt_code.code "."  
            view-as alert-box.
         return no-apply.
       end.
   end.
   if vCodeValue <> tt_code.codevalue then
   do:
       find first buf_tt_code where
                  buf_tt_code.code = vCodeValue
            no-lock no-error.
       if avail buf_tt_code then 
       do:
         message 
            "Ошибка изменения" skip
            "В справочнике уже есть тип маркировки со значением " buf_tt_code.code "."  
            view-as alert-box.
         return no-apply.
       end.
   end.
   
   if vIsUpdated then do:
     assign
        tt_code.code      = vCode 
        tt_code.codevalue = vCodeValue 
        tt_code.codename  = vCodeName 
        tt_code.misc1     = vMisc1 
        tt_code.misc2     = vMisc2 
        tt_code.misc3     = vMisc3 
        tt_code.misc4     = vMisc4 
     .
     BROWSE-5:refresh().
   end.
   apply "ENTRY" to BROWSE-5.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-xml
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-xml f-okei2
ON CHOOSE OF b-xml IN FRAME f-okei2 /* Выгрузить */
DO:

   run Exp2Xml in this-procedure.
     
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-5
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK f-okei2 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
if valid-handle(active-window) and frame {&FRAME-NAME}:PARENT eq ?
  then frame {&FRAME-NAME}:PARENT = active-window.

{ gbl/app_help.i }

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
on window-close of frame {&FRAME-NAME}
  apply "END-ERROR":U to self.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
do on error   undo MAIN-BLOCK, leave MAIN-BLOCK
  on end-key undo MAIN-BLOCK, leave MAIN-BLOCK:

  { gbl/getcntxt.i get }
  { gbl/curdbnum.i v-db-num }
  
  run init-marktype.
  
  run enable_UI in this-procedure .

  wait-for go of frame {&FRAME-NAME} focus {&browse-name}.
end.
run disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE checkChanges f-okei2 
PROCEDURE checkChanges :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    define variable vIsChanged     as logical no-undo init no.
    define variable vBufferCompare as logical no-undo init no.
    define variable vExit          as logical no-undo.
    
    define buffer buf_code    for ub.code.
    define buffer buf_tt_code for tt_code.
    
    for each buf_code where 
             buf_code.parent = "MarkType"
        no-lock:
      accum buf_code.code (count).
    end.
    for each buf_tt_code 
        no-lock:
      accum buf_tt_code.code (count).
    end.
    if (accum count buf_code.code) <> (accum count buf_tt_code.code) then
        vIsChanged = true.
    
    if not vIsChanged then
    do:
        BLOCK_COMPARE:
        for each buf_tt_code where 
                 int(buf_tt_code.code) > 16
            no-lock:
          find first buf_code where 
                     buf_code.parent = "MarkType"
                 and buf_code.code = buf_tt_code.code
               no-lock no-error.
          if avail buf_code then
          do:
             buffer-compare buf_tt_code to buf_code
               SAVE RESULT IN vBufferCompare.
             if not vBufferCompare then
             do:
               vIsChanged = true.
               leave BLOCK_COMPARE.
             end.
          end.
          else
          do:
              vIsChanged = true.
              leave BLOCK_COMPARE.
          end.
        end.
    end.

    if vIsChanged then
    do:
        message 
          "Для сохранения обновленной конфигурации типов маркировки нажмите «Нет»" skip
          "и проведите выгрузку конфигурации в основной форме." skip
          "После выхода из режима конфигурации типов маркировки внесенные изменения будут удалены." skip
          "Вы уверены, что хотите завершить конфигурирование и закрыть форму?"
          view-as alert-box question buttons yes-no update vExit.
        if not vExit then return error.
     end.
     return.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI f-okei2  _DEFAULT-DISABLE
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
  HIDE FRAME f-okei2.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI f-okei2 
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
  enable
    BROWSE-5
    b-exit
    b-add
    when v-db-num = 0
    b-del
    when v-db-num = 0
    b-upd
    when v-db-num = 0
    b-xml
    when v-db-num = 0
    b-help
    with frame {&frame-name}.

  {&OPEN-BROWSERS-IN-QUERY-f-okei2}

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Exp2Xml f-okei2 
PROCEDURE Exp2Xml :
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    define buffer   b-code for ub.code.
    define buffer   b-tt_code for tt_code.
    define variable v-file-name as character no-undo.
    define variable vDateTime   as character no-undo.
    define variable vCodeName   as character no-undo.
    
    assign
      v-file-name = "marktype_000000000" + ".xml"
      vDateTime   = substitute("&1 &2",string(today,"99.99.9999"),string(time,"HH:MM")).
    .   
                  
    output stream out-xml to value(v-file-name).
    
    put stream out-xml unformatted
    "<?xml version=~"1.0~" encoding=~"windows-1251~" ?>" skip 
    "<Root>" skip
    "    <File-info>" skip
    "        <DateActive>01.01.2100</DateActive>" skip
    "        <version>000</version>" skip
    "    </File-info>" skip
    "    <table-Code NwsNotSend=~"TableList~">" skip 
    "        <record-Code record-delete=~"no~">" skip
    "            <code>Versions</code>" skip
    "            <CodeName>Версии справочников БД</CodeName>" skip
    "            <export_>yes</export_>" skip
    "            <status_>0</status_>" skip
    "            <nwsgbd>yes</nwsgbd>" skip
    "        </record-Code>" skip
    "        <record-Code record-delete=~"no~">" skip
    "            <parent>Versions</parent>" skip
    "            <code>0</code>" skip
    "            <CodeName>Версии справочников на главной БД</CodeName>" skip
    "            <export_>yes</export_>" skip
    "            <status_>0</status_>" skip
    "            <nwsgbd>yes</nwsgbd>" skip
    "        </record-Code>" skip
    "        <record-Code record-delete=~"no~">" skip
    "            <parent>Versions" {&delim-par} "0</parent>" skip
    "            <code>MarkType</code>" skip
    "            <CodeName>Типы маркировки</CodeName>" skip
    "            <CodeValue>" vDateTime "</CodeValue>" skip
    "            <export_>yes</export_>" skip
    "            <status_>0</status_>" skip
    "            <nwsgbd>yes</nwsgbd>" skip
    "        </record-Code>" skip
    "        <record-Code record-delete=~"no~">" skip
    "            <code>MarkType</code>" skip
    "            <CodeName>Типы маркировки</CodeName>" skip
    "            <export_>yes</export_>" skip
    "            <procview>ref/marktype-brw.w</procview>" skip
    "            <status_>0</status_>" skip
    "            <nwsgbd>yes</nwsgbd>" skip
    "        </record-Code>" skip
    .
    
    /* выгружаем в xml весь справочник, кроме старых марок */
    for each b-tt_code:
        assign
           vCodeName = replace(b-tt_code.CodeName, "&", "&amp;")
           vCodeName = replace(vCodeName, "~"", "&quot;")        
           vCodeName = replace(vCodeName, "'", "&apos;")
           vCodeName = replace(vCodeName, "<", "&lt;")
           vCodeName = replace(vCodeName, ">", "&gt;")
           vCodeName = replace(vCodeName, "<", "&lt;")
        .
        put stream out-xml unformatted
            "        <record-Code record-delete=~"no~">" skip
            "            <parent>MarkType</parent>" skip
            "            <code>" b-tt_code.code "</code>" skip
            "            <CodeValue>" b-tt_code.codevalue "</CodeValue>" skip
            "            <CodeName>" vCodeName "</CodeName>" skip
            "            <misc1>" b-tt_code.misc1 "</misc1>" skip
            "            <misc2>" b-tt_code.misc2 "</misc2>" skip
            "            <misc3>" b-tt_code.misc3 "</misc3>" skip
            "            <misc4>" b-tt_code.misc4 "</misc4>" skip
            "            <export_>" string(b-tt_code.export_) "</export_>" skip
            "            <status_>" string(b-tt_code.status_) "</status_>" skip
            "            <nwsgbd>" string(b-tt_code.nwsgbd) "</nwsgbd>" skip
            "        </record-Code>" skip
        .
    end.
    /* ищем удаленные записи и выгружаем их как удаленные */
/*    for each b-code no-lock where                                           */
/*             b-code.parent = {&CODE_PARENT}                                 */
/*            :                                                               */
/*        find first b-tt_code where                                          */
/*                   b-tt_code.parent = b-code.parent and                     */
/*                   b-tt_code.code = b-code.code                             */
/*        no-error.                                                           */
/*        if not avail b-tt_code then do:                                     */
/*        put stream out-xml unformatted                                      */
/*            "        <record-Code record-delete=~"yes~">" skip              */
/*            "            <parent>MarkType</parent>" skip                    */
/*            "            <code>" b-code.code "</code>" skip                 */
/*            "            <CodeValue>" b-code.codevalue "</CodeValue>" skip  */
/*            "            <CodeName>" b-code.CodeName "</CodeName>" skip     */
/*            "            <misc1>" b-code.misc1 "</misc1>" skip              */
/*            "            <misc2>" b-code.misc2 "</misc2>" skip              */
/*            "            <misc3>" b-code.misc3 "</misc3>" skip              */
/*            "            <misc4>" b-code.misc4 "</misc4>" skip              */
/*            "            <export_>" string(b-code.export_) "</export_>" skip*/
/*            "            <status_>" string(b-code.status_) "</status_>" skip*/
/*            "            <nwsgbd>" string(b-code.nwsgbd) "</nwsgbd>" skip   */
/*            "        </record-Code>" skip                                   */
/*        .                                                                   */
/*                                                                            */
/*        end.                                                                */
/*    end.                                                                    */
    
    put stream out-xml unformatted
    "    </table-Code>" skip
    "</Root>" skip
    .
    output stream out-xml close.
    MESSAGE "Справочник <Типы маркировки> выгружен в файл " search(v-file-name)
    VIEW-AS ALERT-BOX.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-marktype f-okei2 
PROCEDURE init-marktype :
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
   def buffer b-code for ub.code.
   
   empty temp-table tt_code.
   
   for each b-code no-lock where
            b-code.parent = {&CODE_PARENT}
            :
      create tt_code.
      buffer-copy b-code to tt_code. 
   end.                

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

