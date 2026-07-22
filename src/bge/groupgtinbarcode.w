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

Сбор данных по GTIN и штрих-кодам

Автор: Шкляр Елена 
Дата создания: 01/16/07
Author: Elena Shklyar
Creation date: 01/16/07

          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/
{ bge/temp_gtin.i }
{ gbl/objsrv.i } 
{ gbl/getcntxt.i def }
/* ***************************  Definitions  ************************** */
/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input-output parameter table for tt-goods .
define input parameter p-type-mark as character no-undo .
define output parameter p-recid as recid  no-undo .
/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сбор данных по GTIN и штрих-кодам".

{ cmp/vssrevis.i }
{ cmp/showinf.i  }
{ cmp/str-glbl.i }
{ ref/gds-attr.i }
 
{ gbl/is-num.i }
define variable v-scan-str as character no-undo.
define variable iLang      as integer   no-undo.
define variable p-value-logical as logical no-undo.
define variable p-value-character  as character no-undo.
define variable p-value-date       as date no-undo.
define variable p-value-decimal    as decimal no-undo.
define variable p-value-integer    as integer no-undo.
define variable p-param-type       as character no-undo.
define variable v-tth as handle no-undo .


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_OK Btn_Cancel f-bar-code f-bar-code-2 
&Scoped-Define DISPLAYED-OBJECTS f-gds-code f-gds-name f-bar-code ~
f-bar-code-2 f-GTIN f-qnty f-type-mark 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_Cancel AUTO-END-KEY 
   LABEL "Отмена" 
   SIZE 10 BY 1.

DEFINE BUTTON Btn_OK AUTO-GO 
   LABEL "Ввод" 
   SIZE 10 BY 1.

DEFINE VARIABLE f-type-mark  AS CHARACTER FORMAT "X(256)" 
   LABEL "Тип маркировки" 
   VIEW-AS COMBO-BOX INNER-LINES 5
   LIST-ITEM-PAIRS "","not-type",
   "Табачная продукция","tabak",
   "Обувь","shoes",
   "Духи и парфюмерия","perfume",
   "Легпром","industry",
   "Шины","tires",
   "Лекарства","apteka",
   "Фотокамеры/фотовспышки","photo",
   "Молочная продукция","milk",
   "Упакованная вода","water",
   "Стики","stiki"
   DROP-DOWN-LIST
   SIZE 33.5 BY 1.

DEFINE VARIABLE f-bar-code   AS CHARACTER FORMAT "X(256)" 
   LABEL "Штрих-код упаковки" 
   VIEW-AS FILL-IN 
   SIZE 33.5 BY 1.

DEFINE VARIABLE f-bar-code-2 AS CHARACTER FORMAT "X(256)" 
   LABEL "Штрих-код индивидуальной упаковки" 
   VIEW-AS FILL-IN 
   SIZE 33.5 BY 1.

DEFINE VARIABLE f-gds-code   AS INTEGER   FORMAT ">>>>>>>>>>>>>>>9" INITIAL 0 
   LABEL "Код товара" 
   VIEW-AS FILL-IN 
   SIZE 33.5 BY 1.

DEFINE VARIABLE f-gds-name   AS CHARACTER FORMAT "X(256)" 
   LABEL "Название товара" 
   VIEW-AS FILL-IN 
   SIZE 33.5 BY 1.

DEFINE VARIABLE f-GTIN       AS CHARACTER FORMAT "X(256)" 
   LABEL "GTIN упаковки" 
   VIEW-AS FILL-IN 
   SIZE 33.5 BY 1.

DEFINE VARIABLE f-qnty AS INTEGER FORMAT ">>>9" INITIAL 0 
     LABEL "Кол-во индивидуальных упаковок" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1.25 COL 2
     Btn_Cancel AT ROW 1.25 COL 12
     f-gds-code AT ROW 3 COL 70.25 RIGHT-ALIGNED WIDGET-ID 12
     f-gds-name AT ROW 4.46 COL 70.25 RIGHT-ALIGNED WIDGET-ID 14
     f-bar-code AT ROW 5.92 COL 70.25 RIGHT-ALIGNED WIDGET-ID 16
     f-bar-code-2 AT ROW 7.46 COL 70.25 RIGHT-ALIGNED WIDGET-ID 24
     f-GTIN AT ROW 8.92 COL 35.75 COLON-ALIGNED WIDGET-ID 18
     f-qnty AT ROW 10.38 COL 35.75 COLON-ALIGNED WIDGET-ID 20
     f-type-mark AT ROW 11.83 COL 35.75 COLON-ALIGNED WIDGET-ID 22
     SPACE(2.87) SKIP(1.83)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Товар для ввода".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN 
   FRAME Dialog-Frame:SCROLLABLE = FALSE.

/* SETTINGS FOR FILL-IN f-bar-code IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN f-bar-code-2 IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN f-gds-code IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-R                                                    */
/* SETTINGS FOR FILL-IN f-gds-name IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-R                                                    */
/* SETTINGS FOR FILL-IN f-GTIN IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-qnty IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR COMBO-BOX f-type-mark IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame /* Ввод */
   DO:
      run create-proc in this-procedure no-error .
      if return-value = 'cancel' then return no-apply .
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-bar-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-bar-code Dialog-Frame
ON ENTRY OF f-bar-code IN FRAME Dialog-Frame /* Штрих-код упаковки */
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-bar-code Dialog-Frame
ON return,tab OF f-bar-code IN FRAME Dialog-Frame /* Штрих-код упаковки */
   DO:
      run scan-barCode (NO).
      if return-value = 'cancel' 
      then do: 
         self:screen-value = "". 
         return no-apply . 
      end.   

      if f-bar-code-2:SENSITIVE in frame {&frame-name} = true then 
      do:
         apply "entry":U to f-bar-code-2 in frame {&frame-name} .
         return no-apply.
      end.
      else do:
         apply "entry":U to f-GTIN in frame {&frame-name} .
         return no-apply.
      end.     
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-bar-code Dialog-Frame
ON LEAVE OF f-bar-code IN FRAME Dialog-Frame /* Штрих-код упаковки */
   DO:
      run scan-barCode (YES).
      if return-value = 'cancel' 
      then do: 
         self:screen-value = "". 
         return no-apply . 
      end.   
      
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-bar-code-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-bar-code-2 Dialog-Frame
ON ENTRY OF f-bar-code-2 IN FRAME Dialog-Frame /* Штрих-код индивидуальной упаковки */
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-bar-code-2 Dialog-Frame
ON return,tab,LEAVE OF f-bar-code-2 IN FRAME Dialog-Frame /* Штрих-код индивидуальной упаковки */
   DO:
      if f-bar-code-2:screen-value <> "" then do:
      run scan-barCode1 .
      if return-value = 'cancel' 
      then do: 
         self:screen-value = "". 
         return no-apply . 
      end.
      if f-GTIN:SENSITIVE in frame {&frame-name} = true then 
      do:
         apply "entry":U to f-gtin in frame {&frame-name} .
          return no-apply.  
               end.      
      end.                                                                                                                                               
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME f-GTIN
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-GTIN Dialog-Frame
ON ENTRY OF f-GTIN IN FRAME Dialog-Frame /* GTIN упаковки */
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-GTIN Dialog-Frame
ON LEAVE OF f-GTIN IN FRAME Dialog-Frame /* GTIN упаковки */
   DO:
      define variable vTXt     as character no-undo .
      define variable bar_code as character no-undo .
      vTXt = f-GTIN:screen-value.
/*      if vTXt = '' then return .*/
      if    length(vtxt) > 14
         then 
      do:  
         if    (length(vtxt) eq 14 + 7 + 4 + 4
            or length(vtxt) eq 14 + 7 + 4 )
            then 
            f-GTIN:screen-value = substring(vtxt,1,14).
         else if vtxt begins "01"
               then
               f-GTIN:screen-value = substring(vtxt,3,14).
            else 
            do:
            /*int(substring(vtxt,1,2)) no-error.
            prod-bc.b-str:screen-value = if error-status:error
                                         then substring(vtxt,3,14)
                                         else substring(vtxt,1,14).
          */
            end.
      end.
      if length(f-GTIN:screen-value) ne 14
      then do:
         message "Введенный код не Gtin. Gtin состоит из 14 символов." 
            view-as alert-box.
         self:screen-value = "".
         return no-apply.
      end.    
      bar_code = substr (f-GTIN:screen-value, 1, length (f-GTIN:screen-value) - 1).
      run str/chk-sum.p
         (input-output bar_code
         ) no-error .
      if error-status :error
         then 
      do:
         message "Бар-код должен быть GTIN."
            view-as alert-box.
         self:screen-value = "".
         return  no-apply .
      end.
      if substr (bar_code, length (bar_code), 1) <> substr (f-GTIN:screen-value, length (bar_code), 1)
         then 
      do:
         message "Бар-код должен быть GTIN."
            view-as alert-box.

         if session:debug-alert 
            then
            message " Ваш код " + f-GTIN:screen-value + " Правильный GTIN " + bar_code
               view-as alert-box.
         self:screen-value = "".
         return  no-apply .
      end.
      assign f-GTIN .
/*      disable f-GTIN f-bar-code-2 f-bar-code with frame {&frame-name} .*/
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-qnty Dialog-Frame
ON LEAVE OF f-qnty IN FRAME Dialog-Frame /* Кол-во */
   DO:
      assign f-qnty .
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-GTIN Dialog-Frame
ON return,tab OF f-GTIN IN FRAME Dialog-Frame /* GTIN упаковки */
   DO:
      if f-qnty:screen-value <> "" and f-qnty:screen-value <> "0" then 
      apply "entry" to f-type-mark IN FRAME Dialog-Frame.
      else apply "entry" to f-qnty IN FRAME Dialog-Frame.
      
      return no-apply.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-type-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-type-mark Dialog-Frame
ON value-changed OF f-type-mark IN FRAME Dialog-Frame /* Тип маркировки */
   DO:
      assign f-type-mark .
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
   run init-proc.
      f-type-mark = p-type-mark .
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
   for each tt-goods where gds-code = 0:
      delete tt-goods .
   end.       
   RUN enable_UI.
   WAIT-FOR GO OF FRAME {&FRAME-NAME} focus f-bar-code.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame 
PROCEDURE init-proc :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
define variable v-list as character no-undo.
define variable vi as integer no-undo.
define variable MarkType as ibs.th.gbl.map.mapstring no-undo.
define variable objType  as ibs.th.gbl.propmap no-undo.

MarkType = ObjSrv:Env:Marking:Types:MAPTYPE.
do vi = 1 to MarkType:GetItemByLab(vi):     
objType  = ObjSrv:Env:Marking:Types:CurrProp.

    v-list = v-list + "," + objType:Label_ + "," + objType:NameProp.
end.

v-list = trim(v-list, ",").
f-type-mark:list-item-pairs in frame {&FRAME-NAME} = v-list.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ActivateKeyboardLayout Dialog-Frame 
PROCEDURE ActivateKeyboardLayout external "user32" :
   define input parameter P1 as LONG.
   define input parameter P2 as LONG.
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
   if f-GTIN = "" then 
   do:
      message "Не заполено поле GTIN"
         view-as alert-box.
      return 'cancel' .
   end.   
   if f-qnty < 2 or f-qnty = ? then 
   do:
      message "Необходимо указывать количество более 1-го"
         view-as alert-box.
      return 'cancel' .
   end.   
   if f-bar-code = "" then do:
      message "Необходимо указать штрих код упаковки"
      view-as alert-box.
      return 'cancel' .
   end.   
   if f-bar-code-2:screen-value in frame {&frame-name} = "" then do:
      run scan-barCode (NO).
      if return-value = 'next' 
      then return 'cancel' . 
   end.   
   find first tt-goods no-lock where tt-goods.gds-code = f-gds-code and
      tt-goods.GTIN = f-GTIN no-error .
   if not available (tt-goods) then 
   do:                                     
      create tt-goods .
      assign
         tt-goods.barcode   = f-bar-code
         tt-goods.gds-code  = f-gds-code
         tt-goods.gds-name  = f-gds-name
         tt-goods.GTIN      = f-GTIN
         tt-goods.qnty      = f-qnty
         .
         tt-goods.type-mark = f-type-mark:screen-value in frame {&frame-name}
         .
      p-recid = recid (tt-goods) .
   end.
   else 
   do:
      p-recid = recid (tt-goods) .
      message "Данные уже сохранены"
         view-as alert-box.
      return error .
   end.     
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
   DISPLAY f-gds-code f-gds-name f-bar-code f-bar-code-2 f-GTIN f-qnty 
      f-type-mark 
      WITH FRAME Dialog-Frame.
   ENABLE Btn_OK Btn_Cancel f-bar-code 
      WITH FRAME Dialog-Frame.
   {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE LoadKeyboardLayoutA Dialog-Frame 
PROCEDURE LoadKeyboardLayoutA external "user32" :
   define input  parameter P1 as char.
   define input  parameter P2 as LONG.
   define return parameter pret as LONG.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE scan-barCode Dialog-Frame 
PROCEDURE scan-barCode :
   define input  parameter ILEAVE as logical no-undo.
   define variable v_list    as character no-undo .
   define variable ii        as integer   no-undo .
   define variable v-barCode as character no-undo .
   define buffer buf_goods         for ub.goods .
   define buffer buf_bar-code      for ub.bar-code .
   define buffer buf_bar-code-attr for ub.bar-code-attr .
   define buffer buf_prod-bc       for ub.prod-bc .
   define buffer buf_prod-bc-attr  for ub.prod-bc-attr.
   define buffer buf_goods-attr    for ub.goods-attr .
   define buffer base-bar-code     for ub.bar-code.
   define variable v-rid            as recid     no-undo .
   define variable v-b-str          like ub.prod-bc.b-str no-undo .
   define variable v-gds-attr-type  as character no-undo .
   define variable v-gds-attr-value as character no-undo .
   
   if f-bar-code:screen-value in frame {&frame-name} = ""
      then 
   do:
      f-bar-code:screen-value in frame {&frame-name} = v-scan-str.
   end.
      
   v-scan-str = "". 
   assign 
      v-barCode = f-bar-code:screen-value in frame {&frame-name}.
      f-bar-code = f-bar-code:screen-value in frame {&frame-name}.
   if not is-numeral (v-barCode,"digit")
   then do:
      message "Просканируйте штрих-код."
      view-as alert-box.
      f-bar-code = "" .
      display f-bar-code with frame {&frame-name} .   
      return 'cancel' .
   end.    
   if v-barCode = "" then do:
      message "Просканируйте штрих-код упаковки."
      view-as alert-box.
      return 'cancel' .
   end.    
   if length(f-bar-code:screen-value) > 13 then do:
      message "Штрих-код не должен превышать 13 символов."
      view-as alert-box.
      return 'cancel' .
   end .   
   find first buf_prod-bc exclusive-lock where buf_prod-bc.b-str = string(v-barCode) no-error .
   if not available (buf_prod-bc) then 
   do:
      if not ILEAVE
      THEN
         message "Штрих-код не найден в БД. Просканируйте штрих-код индивидуальной упаковки"
            view-as alert-box.

      display f-bar-code with frame {&frame-name} .
      enable f-bar-code-2 with frame {&frame-name} .
      return 'next' .
   end.                       
   find first buf_bar-code no-lock where buf_bar-code.b-code = buf_prod-bc.b-code and buf_bar-code.cli-base-rate > 1 no-error .
   if not available (buf_bar-code) then 
   do:
      if not ILEAVE
      THEN
         message "Штрих-код не найден в БД. Просканируйте штрих-код индивидуальной упаковки"
            view-as alert-box.
      display f-bar-code with frame {&frame-name} .
      enable f-bar-code-2 with frame {&frame-name} .
      return 'next' .
   end.   
   for first buf_goods no-lock where buf_goods.gds-code = buf_bar-code.gds-code:
      f-gds-code = buf_goods.gds-code .
      f-gds-name = buf_goods.gds-name .
      f-qnty = buf_bar-code.cli-base-rate .
      f-bar-code = v-barCode .
         
      RUN gds-attr-value (
         INPUT buf_goods.gds-code,
         INPUT {&attr-mark-type},
         OUTPUT v-gds-attr-value,
         OUTPUT v-gds-attr-type
         ).
      f-type-mark = v-gds-attr-value .
         f-bar-code-2 = "" .
      display
         f-bar-code
         f-bar-code-2
         f-gds-code
         f-gds-name
         f-qnty
         f-type-mark
         with frame {&frame-name} .
      enable
         f-GTIN
         f-type-mark
         with frame {&frame-name} .
      disable f-bar-code-2 f-qnty with frame {&frame-name} .
   end.   
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE scan-barCode1 Dialog-Frame 
PROCEDURE scan-barCode1 :
   define variable v_list    as character no-undo .
   define variable ii        as integer   no-undo .
   define variable v-barCode as character no-undo .
   define buffer buf_goods         for ub.goods .
   define buffer buf_bar-code      for ub.bar-code .
   define buffer buf_bar-code-attr for ub.bar-code-attr .
   define buffer buf_prod-bc       for ub.prod-bc .
   define buffer buf_prod-bc-attr  for ub.prod-bc-attr.
   define buffer buf_goods-attr    for ub.goods-attr .
   define buffer base-bar-code     for ub.bar-code.
   define variable v-rid            as recid     no-undo .
   define variable v-b-str          like ub.prod-bc.b-str no-undo .
   define variable v-gds-attr-type  as character no-undo .
   define variable v-gds-attr-value as character no-undo .
   
   if f-bar-code-2:screen-value in frame {&frame-name} = ""
      then 
   do:
      f-bar-code-2:screen-value in frame {&frame-name} = v-scan-str.
   end.
      
   v-scan-str = "". 
   assign 
      v-barCode = f-bar-code-2:screen-value in frame {&frame-name}.
   if not is-numeral (v-barCode,"digit")
   then do:
      message "Просканируйте штрих-код."
      view-as alert-box.
      return 'cancel' .
   end.     
   if v-BarCode = ""
   then do:
      message "Просканируйте штрих-код индивидуальной упаковки"
      view-as alert-box.
      return 'cancel' .
   end.     
   find first buf_prod-bc exclusive-lock where buf_prod-bc.b-str = string(v-barCode) no-error .
   if not available (buf_prod-bc) then 
   do:
      message "Штрих-код не найден в БД"
         view-as alert-box.
      return 'cancel' .
   end.                       
   find first buf_bar-code no-lock where buf_bar-code.b-code = buf_prod-bc.b-code and buf_bar-code.cli-base-rate = 1 no-error .
   if not available (buf_bar-code) then 
   do:
      message "Штрих-код не найден в БД."
         view-as alert-box.
      return 'cancel' .
   end.   
   for first buf_goods no-lock where buf_goods.gds-code = buf_bar-code.gds-code:
      f-gds-code = buf_goods.gds-code .
      f-gds-name = buf_goods.gds-name .
      f-bar-code-2 = v-barCode .
         
      RUN gds-attr-value (
         INPUT buf_goods.gds-code,
         INPUT {&attr-mark-type},
         OUTPUT v-gds-attr-value,
         OUTPUT v-gds-attr-type
         ).
      f-type-mark = v-gds-attr-value .
            
      display
         f-bar-code-2
         f-gds-code
         f-gds-name
         f-qnty
         f-type-mark
         with frame {&frame-name} .
      enable
         f-GTIN
         f-type-mark
         f-qnty
         with frame {&frame-name} .
   end.   
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
