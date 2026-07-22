&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Данные по автотранспорту

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/16/07
Author: Dmitry Ukhanov
Creation date: 08/16/07

Автор: Перваков Михаил Сергеевич
Дата создания: 04/11/06
Author: Mikhail Pervakov
Creation date: 04/11/06

*/

/* ***************************  Definitions  ************************** */
/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo.
define input parameter parmode as character no-undo.
define input-output parameter parrecid as recid no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Данные по автотранспорту".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }

define variable ref-list         as character no-undo.
define variable v-af-obj-code    like ub.clients.obj-code no-undo.
define variable v-af-obj-type    like ub.clients.obj-type no-undo.
define variable v-i              AS INTEGER   NO-UNDO.
define variable varauto-tank-sec as CHARACTER no-undo.
define variable v-auto-num       as character no-undo.


DEFINE BUFFER buf_auto-tank        FOR ub.auto-tank.
DEFINE BUFFER type_auto-tank-attr  FOR ub.auto-tank-attr.
DEFINE BUFFER neck_auto-tank-attr  FOR ub.auto-tank-attr.
DEFINE BUFFER sep_auto-tank-attr   FOR ub.auto-tank-attr.
DEFINE BUFFER valve_auto-tank-attr  FOR ub.auto-tank-attr.
DEFINE BUFFER con-sleeve_auto-tank-attr   FOR ub.auto-tank-attr.
DEFINE BUFFER error_auto-tank-attr FOR ub.auto-tank-attr.
DEFINE BUFFER temp_auto-tank-attr  FOR ub.auto-tank-attr.
define buffer buf_auto-section     for ub.auto-section.

DEFINE TEMP-TABLE tt_auto-tank-sec NO-UNDO
   FIELD sec-num     AS integer
   FIELD brutto-qnty AS DECIMAL
   field add-volume  as decimal
   .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME brw-auto-num-sec

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt_auto-tank-sec

/* Definitions for BROWSE brw-auto-num-sec                              */
&Scoped-define FIELDS-IN-QUERY-brw-auto-num-sec tt_auto-tank-sec.sec-num tt_auto-tank-sec.brutto-qnty tt_auto-tank-sec.add-volume /*ENABLE tt_auto-tank-sec.diametr tt_auto-tank-sec.brutto-qnty*/   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brw-auto-num-sec   
&Scoped-define SELF-NAME brw-auto-num-sec
&Scoped-define QUERY-STRING-brw-auto-num-sec FOR EACH tt_auto-tank-sec EXCLUSIVE-LOCK
&Scoped-define OPEN-QUERY-brw-auto-num-sec OPEN QUERY brw-auto-num-sec FOR EACH tt_auto-tank-sec EXCLUSIVE-LOCK.
&Scoped-define TABLES-IN-QUERY-brw-auto-num-sec tt_auto-tank-sec
&Scoped-define FIRST-TABLE-IN-QUERY-brw-auto-num-sec tt_auto-tank-sec


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-brw-auto-num-sec}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-cancel b-help RECT-1 RECT-2 SEP c-AC-type ~
b-choose-auto-firm varPS b-view-sec brw-auto-num-sec 
&Scoped-Define DISPLAYED-OBJECTS SEP varname varauto-num varauto-firm ~
c-AC-type C-neck f-error f-temp varPS 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add-sec 
   LABEL "Добавить" 
   SIZE 10 BY 1.

DEFINE BUTTON b-cancel AUTO-END-KEY 
   LABEL "&Отмена" 
   SIZE 10 BY 1
   BGCOLOR 8 .

DEFINE BUTTON b-chg-sec 
   LABEL "Изменить" 
   SIZE 10 BY 1.

DEFINE BUTTON b-choose-auto-firm 
   IMAGE-UP FILE "btn-down-arrow":U
   IMAGE-DOWN FILE "btn-down-arrow":U
   IMAGE-INSENSITIVE FILE "btn-down-arrow":U
   LABEL "b-choose-auto-firm" 
   SIZE 3 BY 1.

DEFINE BUTTON b-del-sec 
   LABEL "Удалить" 
   SIZE 10 BY 1.

DEFINE BUTTON b-help 
   LABEL "&Помощь" 
   SIZE 10 BY 1
   BGCOLOR 8 .

DEFINE BUTTON b-save AUTO-GO 
   LABEL "&Ввод" 
   SIZE 10 BY 1
   BGCOLOR 8 .

DEFINE BUTTON b-view-sec 
   LABEL "Просмотр" 
   SIZE 10 BY 1.

DEFINE VARIABLE c-AC-type    AS INTEGER   FORMAT "->,>>>,>>9":U INITIAL 0 
   LABEL "Тип АЦ" 
   VIEW-AS COMBO-BOX INNER-LINES 5
   LIST-ITEM-PAIRS "",0,
   "Бензовоз",1,
   "Газовоз",2
   DROP-DOWN-LIST
   SIZE 21.5 BY 1 NO-UNDO.

DEFINE VARIABLE C-neck       AS INTEGER   FORMAT "->,>>>,>>9":U INITIAL 0 
   LABEL "Горловина" 
   VIEW-AS COMBO-BOX INNER-LINES 5
   LIST-ITEM-PAIRS "",4,
   "Эллиптическая",2,
   "Прямоугольная или квадратная",1,
   "Цилиндрическая",3,
   "Без горловины/нарушена геометрия",0
   DROP-DOWN-LIST
   SIZE 36.5 BY 1 NO-UNDO.

DEFINE VARIABLE varPS        AS CHARACTER 
   VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL LARGE
   SIZE 58 BY 2.88 DROP-TARGET NO-UNDO.

DEFINE VARIABLE f-error      AS DECIMAL   FORMAT ">>,>>9.999":U INITIAL .4 
   LABEL "Относительная погрешность определения объема  АЦ, %" 
   VIEW-AS FILL-IN 
   SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-temp       AS DECIMAL   FORMAT ">>,>>9.9999999999":U INITIAL .0000125 
   LABEL "Темпер.коэф. линейного расширения материала стенки АЦ,°С" 
   VIEW-AS FILL-IN 
   SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE varauto-firm AS CHARACTER FORMAT "X(256)" 
   LABEL "Автопредприятие" 
   VIEW-AS FILL-IN 
   SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE varauto-num  AS CHARACTER FORMAT "X(20)" 
   LABEL "Гос. номер" 
   VIEW-AS FILL-IN 
   SIZE 21.5 BY 1 TOOLTIP "Государственный регистрационный номер автомобиля" NO-UNDO.

DEFINE VARIABLE varname      AS CHARACTER FORMAT "X(40)" 
   LABEL "Название (марка)" 
   VIEW-AS FILL-IN 
   SIZE 20.5 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-1
   EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
   SIZE 77.5 BY 11.38.

DEFINE RECTANGLE RECT-2
   EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
   SIZE 75.5 BY 3.5.

DEFINE VARIABLE SEP AS LOGICAL INITIAL no 
   LABEL "Наличие СЭП" 
   VIEW-AS TOGGLE-BOX
   SIZE 15 BY .83 NO-UNDO.
   
DEFINE VARIABLE valve AS LOGICAL INITIAL no 
   LABEL "Контрольный вентиль" 
   VIEW-AS TOGGLE-BOX
   SIZE 25 BY .83 NO-UNDO.
   
DEFINE VARIABLE con-sleeve   AS decimal FORMAT ">>>>9.9<" 
   LABEL "Длина соединительного рукава, м" 
   VIEW-AS FILL-IN 
   SIZE 10 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brw-auto-num-sec FOR 
   tt_auto-tank-sec SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brw-auto-num-sec
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brw-auto-num-sec Dialog-Frame _FREEFORM
   QUERY brw-auto-num-sec DISPLAY
   tt_auto-tank-sec.sec-num FORMAT ">>>>9":U COLUMN-LABEL "№ секции"
   tt_auto-tank-sec.brutto-qnty FORMAT "->>,>>>,>>9.<<<":U COLUMN-LABEL "Вместимость!секции (л)"
   tt_auto-tank-sec.add-volume  FORMAT "->>,>>>,>>9.<<<":U COLUMN-LABEL "Дополнительный объем трубопровода нижнего!налива(л)"
  /*ENABLE
      tt_auto-tank-sec.diametr
      tt_auto-tank-sec.brutto-qnty*/
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 76 BY 9.13.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
   b-save AT ROW 1 COL 1
   b-cancel AT ROW 1 COL 11
   b-help AT ROW 1 COL 21
   SEP AT ROW 1.25 COL 56 WIDGET-ID 50
   varname AT ROW 2.5 COL 17.5 COLON-ALIGNED
   varauto-num AT ROW 2.5 COL 54 COLON-ALIGNED
   varauto-firm AT ROW 3.75 COL 17.5 COLON-ALIGNED WIDGET-ID 2
   c-AC-type AT ROW 3.75 COL 54 COLON-ALIGNED WIDGET-ID 36
   b-choose-auto-firm AT ROW 3.79 COL 36.88 WIDGET-ID 4
   C-neck AT ROW 5 COL 17.5 COLON-ALIGNED WIDGET-ID 38
   valve at row 5 col 3 WIDGET-ID 88
   con-sleeve at row 5 col 30 WIDGET-ID 98
   f-error AT ROW 7.25 COL 59.75 COLON-ALIGNED WIDGET-ID 46
   f-temp AT ROW 8.54 COL 3.75 WIDGET-ID 48
   varPS AT ROW 10.25 COL 19.5 NO-LABEL
   b-add-sec AT ROW 14.38 COL 2 WIDGET-ID 22
   b-chg-sec AT ROW 14.38 COL 12 WIDGET-ID 18
   b-del-sec AT ROW 14.38 COL 22 WIDGET-ID 32
   b-view-sec AT ROW 14.38 COL 32 WIDGET-ID 20
   brw-auto-num-sec AT ROW 15.63 COL 1.75 WIDGET-ID 100
   "Информация по секциям автотранспорта" VIEW-AS TEXT
   SIZE 36 BY .67 AT ROW 13.29 COL 21.75 WIDGET-ID 26
   FGCOLOR 4 
   "Метрологические характеристики" VIEW-AS TEXT
   SIZE 30.75 BY .67 AT ROW 6.17 COL 23.13 WIDGET-ID 44
   FGCOLOR 4 
   "Примечание:" VIEW-AS TEXT
   SIZE 11.88 BY .88 AT ROW 11.29 COL 3.25
   RECT-1 AT ROW 13.63 COL 1 WIDGET-ID 28
   RECT-2 AT ROW 6.5 COL 2 WIDGET-ID 40
   SPACE(1.37) SKIP(15.37)
   WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
   SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
   TITLE "Данные по автотранспорту"
   DEFAULT-BUTTON b-save CANCEL-BUTTON b-cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB brw-auto-num-sec b-view-sec Dialog-Frame */
ASSIGN 
   FRAME Dialog-Frame:SCROLLABLE = FALSE
   FRAME Dialog-Frame:HIDDEN     = TRUE.

/* SETTINGS FOR BUTTON b-add-sec IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON b-chg-sec IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON b-del-sec IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON b-save IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-temp IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN varauto-firm IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
   varauto-firm:READ-ONLY IN FRAME Dialog-Frame = TRUE.

/* SETTINGS FOR FILL-IN varauto-num IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varname IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
   varPS:RETURN-INSERTED IN FRAME Dialog-Frame = TRUE
   varPS:READ-ONLY IN FRAME Dialog-Frame       = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brw-auto-num-sec
/* Query rebuild information for BROWSE brw-auto-num-sec
     _START_FREEFORM
OPEN QUERY brw-auto-num-sec FOR EACH tt_auto-tank-sec EXCLUSIVE-LOCK.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE brw-auto-num-sec */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Данные по автотранспорту */
   DO:
      APPLY "END-ERROR":U TO SELF.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add-sec
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add-sec Dialog-Frame
ON CHOOSE OF b-add-sec IN FRAME Dialog-Frame /* Добавить */
   DO:
      define variable unopen as logical no-undo init yes.
   
      if varauto-num:screen-value = ? or trim(varauto-num:screen-value) = "" then 
      do :
         message "Введите номер автотранспорта!" view-as alert-box.
         return no-apply.
      end .
      if c-AC-type = 0 then 
      do :
         message "Введите тип АЦ!" view-as alert-box.
         return no-apply.
      end .      
      if c-AC-type = 1 and C-neck = 4 then 
      do:
      end.    
      if c-AC-type = 2 then 
      do:
         FIND FIRST tt_auto-tank-sec NO-LOCK NO-ERROR.
         if available (tt_auto-tank-sec) then 
         do:
            message "Для данного газовоза уже настроены параметры вместимости." skip
               "Вы уверены, что хотите добавить секцию газовозу?"
               view-as alert-box question buttons yes-no update unopen.

         end.                                  
      end.   
      ASSIGN
         varauto-num      = varauto-num:screen-value
         varauto-tank-sec = ?
         .
      if unopen then 
      do:
         run str/auto-tncs.w
            ( input        {&add-def}
            ,input        varauto-num
            ,input        c-AC-type
            ,input        C-neck
            ,input-output varauto-tank-sec
            ) no-error.
         RUN init-proc.
         {&OPEN-QUERY-brw-auto-num-sec}
         FIND FIRST tt_auto-tank-sec WHERE tt_auto-tank-sec.sec-num = integer(varauto-tank-sec) NO-LOCK NO-ERROR.
         IF AVAILABLE tt_auto-tank-sec THEN 
         DO:
            REPOSITION brw-auto-num-sec TO RECID recid(tt_auto-tank-sec) NO-ERROR.            
         END.
         for each tt_auto-tank-sec no-lock :
            disable varauto-num with frame {&frame-name}.
         end.     
         apply "value-changed" to brw-auto-num-sec in frame dialog-frame.
      end.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cancel Dialog-Frame
ON CHOOSE OF b-cancel IN FRAME Dialog-Frame /* Отмена */
   DO:
      if not available ub.auto-tank then
         for each buf_auto-section exclusive-lock where buf_auto-section.auto-num = varauto-num :
            delete buf_auto-section .
         end.      
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg-sec
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg-sec Dialog-Frame
ON CHOOSE OF b-chg-sec IN FRAME Dialog-Frame /* Изменить */
   DO:

      if available tt_auto-tank-sec then 
      do:
         ASSIGN
            varauto-tank-sec = string(tt_auto-tank-sec.sec-num)
            .
         run str/auto-tncs.w
            ( input        {&update}
            ,input        varauto-num
            ,input        c-AC-type
            ,input        C-neck
            ,input-output varauto-tank-sec
            ) no-error.
         RUN init-proc.
         {&OPEN-QUERY-brw-auto-num-sec}
         FIND FIRST tt_auto-tank-sec WHERE tt_auto-tank-sec.sec-num = integer(varauto-tank-sec) NO-LOCK NO-ERROR.
         IF AVAILABLE tt_auto-tank-sec THEN 
         DO:
            REPOSITION brw-auto-num-sec TO RECID recid(tt_auto-tank-sec) NO-ERROR.
         END.
         apply "value-changed" to brw-auto-num-sec in frame dialog-frame.
      end.
      else 
      do:
         message "Не выбрана секция." view-as alert-box error.
      end.

   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-choose-auto-firm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-choose-auto-firm Dialog-Frame
ON CHOOSE OF b-choose-auto-firm IN FRAME Dialog-Frame /* b-choose-auto-firm */
   DO:
      run ref/cli-all.w
         ( parparentproc
         , input  "b-sel"
         , ?
         , ?
         , ?
         , ?
         , ?
         , ?
         ,output ref-list
         ).
      If ref-list <> "" then 
      do :
         find first ub.clients no-lock
            where recid(ub.clients) = integer(ref-list) no-error.
         if available ub.clients then 
         do :
            varauto-firm = ub.clients.obj-type + " " + string(ub.clients.obj-code) .
         end.
      end.
      else 
      do :
         varauto-firm = "".
      end.
      display varauto-firm WITH FRAME Dialog-Frame.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del-sec
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del-sec Dialog-Frame
ON CHOOSE OF b-del-sec IN FRAME Dialog-Frame /* Удалить */
   DO:
      define variable varlog as log NO-UNDO.


      if available tt_auto-tank-sec then 
      do:
         ASSIGN
            v-auto-num = varauto-num
            .

         MESSAGE "Удалить секцию?" view-as alert-box question
            buttons yes-no
            update varlog.
         if varlog = false then return no-apply.

         FIND FIRST buf_auto-section WHERE buf_auto-section.auto-num = v-auto-num 
            and buf_auto-section.section-num = tt_auto-tank-sec.sec-num EXCLUSIVE-LOCK NO-ERROR.
         IF AVAILABLE buf_auto-section THEN
            DELETE buf_auto-tank.

         DELETE tt_auto-tank-sec.
         {&OPEN-QUERY-brw-auto-num-sec}

      end.
      else 
      do:
         message "Не выбрана секция." view-as alert-box error.
      end.
      for each tt_auto-tank-sec no-lock :
         disable varauto-num with frame {&frame-name}.
      end.
      find first tt_auto-tank-sec no-lock no-error.
      if not available tt_auto-tank-sec then enable varauto-num with frame {&frame-name}.
      apply "value-changed" to brw-auto-num-sec in frame dialog-frame.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-save Dialog-Frame
ON CHOOSE OF b-save IN FRAME Dialog-Frame /* Ввод */
   DO:
      if varauto-num:screen-value = ? or trim(varauto-num:screen-value) = "" 
         or varname:screen-value = ? or trim(varname:screen-value) = ""
         then 
      do :
         message "Заполните поля 'марка' и 'гос. номер'" view-as alert-box.
         return no-apply .
      end.    
      if c-AC-type = 0 and not SEP then 
      do:
         message "Выберите тип АЦ" view-as alert-box.
         return no-apply .      
      end.  
      if c-AC-type = 1 and C-neck = 4 then 
      do:
         message "Выберите тип горловины" view-as alert-box.
         return no-apply .
      end.    
      if varauto-firm = "" then 
      do:
         message "Выберите автопредприятие" view-as alert-box.
         return no-apply .
      end.         
      if parmode = {&add-def} then 
      do:
         if can-find (first ub.auto-tank where ub.auto-tank.auto-num = input frame {&frame-name} varauto-num)
            then 
         do:
            message "Уже существует автотранспорт с гос. номером: " input frame {&frame-name} varauto-num view-as alert-box.
            return no-apply.
         end.
      
         create ub.auto-tank.
         assign
            parrecid             = recid(ub.auto-tank)
            ub.auto-tank.status_ = {&current-status}
            .
      end.
      
      assign
        valve
        con-sleeve
      .
  
      if parmode = {&add-def} or
         parmode = {&update} then 
      do:
         assign
            ub.auto-tank.auto-num  = input frame {&frame-name} varauto-num
            ub.auto-tank.name      = input frame {&frame-name} varname
            ub.auto-tank.ps        = input frame {&frame-name} varps
            ub.auto-tank.type-AC   = input frame {&frame-name} c-AC-type
            ub.auto-tank.type-neck = input frame {&frame-name} C-neck
            .
         if varauto-firm <> "" then 
         do: 
            assign 
               ub.auto-tank.firm-code = integer(entry(2,varauto-firm," "))
               ub.auto-tank.firm-type = string(entry(1,varauto-firm," "))
               .
         end.
      end.
      if parmode = {&add-def} then 
      do :
         if varauto-firm <> "" then 
         do :
            create ub.auto-tank-attr.
            assign
               ub.auto-tank-attr.auto-num   = ub.auto-tank.auto-num
               ub.auto-tank-attr.attr-code  = "auto-firm"
               ub.auto-tank-attr.attr-value = input frame {&frame-name} varauto-firm
               .
         end.
         
         create ub.auto-tank-attr.
         assign
            ub.auto-tank-attr.auto-num   = ub.auto-tank.auto-num
            ub.auto-tank-attr.attr-code  = "auto-sep"
            ub.auto-tank-attr.attr-value = string(SEP)
            .

         create ub.auto-tank-attr.
         assign
            ub.auto-tank-attr.auto-num   = ub.auto-tank.auto-num
            ub.auto-tank-attr.attr-code  = "autotype-AC"
            ub.auto-tank-attr.attr-value = string(c-AC-type)
            .
         if c-AC-type = 1 then 
         do :        
            create ub.auto-tank-attr.
            assign
               ub.auto-tank-attr.auto-num   = ub.auto-tank.auto-num
               ub.auto-tank-attr.attr-code  = "autotype-neck"
               ub.auto-tank-attr.attr-value = string(C-neck)
               .
            if f-error <> 0 or f-error <> ? then 
            do:
               create ub.auto-tank-attr.
               assign
                  ub.auto-tank-attr.auto-num   = ub.auto-tank.auto-num
                  ub.auto-tank-attr.attr-code  = "auto-error"
                  ub.auto-tank-attr.attr-value = string(f-error)
                  .          
            end.
            if f-temp <> 0 or f-temp <> ? then 
            do:
               create ub.auto-tank-attr.
               assign
                  ub.auto-tank-attr.auto-num   = ub.auto-tank.auto-num
                  ub.auto-tank-attr.attr-code  = "auto-temp"
                  ub.auto-tank-attr.attr-value = string(f-temp)
                  .          
            end.
         end.
         if c-AC-type = 2 then 
         do :        
            create ub.auto-tank-attr.
            assign
               ub.auto-tank-attr.auto-num   = ub.auto-tank.auto-num
               ub.auto-tank-attr.attr-code  = "valve"
               ub.auto-tank-attr.attr-value = string(valve)
               .
            if con-sleeve > 0 then
            do:
               create ub.auto-tank-attr.
               assign
                  ub.auto-tank-attr.auto-num   = ub.auto-tank.auto-num
                  ub.auto-tank-attr.attr-code  = "con-sleeve"
                  ub.auto-tank-attr.attr-value = string(con-sleeve)
                  .          
            end.
         end.
      end.
      if parmode = {&update} then 
      do:
         if varauto-firm <> "" then 
         do :
            ub.auto-tank.firm-code   = integer(entry(2,varauto-firm," ")) .
            ub.auto-tank.firm-type   = string(entry(1,varauto-firm," ")) .
         end.
         else 
         do :  
            ub.auto-tank.firm-code   = 0 .
            ub.auto-tank.firm-type   = "" .
         end.
         
         if available sep_auto-tank-attr then sep_auto-tank-attr.attr-value = string(SEP) .
         else 
         do :
            create sep_auto-tank-attr.
            assign
                sep_auto-tank-attr.auto-num   = ub.auto-tank.auto-num
                sep_auto-tank-attr.attr-code  = "auto-sep"
                sep_auto-tank-attr.attr-value = string(SEP)
                .
         end.
         if c-AC-type = 2 then 
         do :        
            if available valve_auto-tank-attr then valve_auto-tank-attr.attr-value = string(valve) .
            else 
            do :
                create valve_auto-tank-attr.
                assign
                    valve_auto-tank-attr.auto-num   = ub.auto-tank.auto-num
                    valve_auto-tank-attr.attr-code  = "valve"
                    valve_auto-tank-attr.attr-value = string(valve)
                .
            end .
            if con-sleeve > 0 then
            do:
               if available con-sleeve_auto-tank-attr then con-sleeve_auto-tank-attr.attr-value = string(con-sleeve) .
               else 
               do :
                    create con-sleeve_auto-tank-attr.
                    assign
                        con-sleeve_auto-tank-attr.auto-num   = ub.auto-tank.auto-num
                        con-sleeve_auto-tank-attr.attr-code  = "con-sleeve"
                        con-sleeve_auto-tank-attr.attr-value = string(con-sleeve)
                    .    
               end .     
            end.
         end.
         if f-error <> 0 and f-error <> ? then 
         do :
            if available error_auto-tank-attr then error_auto-tank-attr.attr-value = input frame {&frame-name} f-error .
            else 
            do :
               create error_auto-tank-attr.
               assign
                  error_auto-tank-attr.auto-num   = ub.auto-tank.auto-num
                  error_auto-tank-attr.attr-code  = "auto-error"
                  error_auto-tank-attr.attr-value = input frame {&frame-name} f-error
                  .
            end.
         end.
         else 
         do :  
            if available error_auto-tank-attr then delete error_auto-tank-attr.
         end.
         if f-temp <> 0 and f-temp <> ? then 
         do :
            if available temp_auto-tank-attr then temp_auto-tank-attr.attr-value = input frame {&frame-name} f-temp .
            else 
            do :
               create temp_auto-tank-attr.
               assign
                  temp_auto-tank-attr.auto-num   = ub.auto-tank.auto-num
                  temp_auto-tank-attr.attr-code  = "auto-temp"
                  temp_auto-tank-attr.attr-value = input frame {&frame-name} f-temp
                  .
            end.
         end.
         else 
         do :  
            if available temp_auto-tank-attr then delete temp_auto-tank-attr.
         end.
         if c-AC-type <> 0 and c-AC-type <> ? then 
         do :
            if available type_auto-tank-attr then type_auto-tank-attr.attr-value = input frame {&frame-name} c-AC-type .
            else 
            do :
               create type_auto-tank-attr.
               assign
                  type_auto-tank-attr.auto-num   = ub.auto-tank.auto-num
                  type_auto-tank-attr.attr-code  = "autotype-AC"
                  type_auto-tank-attr.attr-value = input frame {&frame-name} c-AC-type
                  .
            end.
         end.
         else 
         do :  
            if available type_auto-tank-attr then delete type_auto-tank-attr.
         end.
         if C-neck <> 4 and C-neck <> ? and c-AC-type <> 2 then 
         do :
            if available neck_auto-tank-attr then neck_auto-tank-attr.attr-value = input frame {&frame-name} C-neck .
            else 
            do :
               create neck_auto-tank-attr.
               assign
                  neck_auto-tank-attr.auto-num   = ub.auto-tank.auto-num
                  neck_auto-tank-attr.attr-code  = "autotype-neck"
                  neck_auto-tank-attr.attr-value = input frame {&frame-name} C-neck
                  .
            end.  
         end.
         else 
         do :  
            if available neck_auto-tank-attr then delete neck_auto-tank-attr.
         end.            
      end.
      ub.auto-tank.brutto-qnty = 0 .
      for each ub.auto-section no-lock where ub.auto-section.auto-num = varauto-num:
        ub.auto-tank.brutto-qnty = ub.auto-tank.brutto-qnty + ub.auto-section.brutto-qnty.
      end.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-view-sec
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-view-sec Dialog-Frame
ON CHOOSE OF b-view-sec IN FRAME Dialog-Frame /* Просмотр */
   DO:
  
      if available tt_auto-tank-sec then 
      do:
         ASSIGN
            varauto-num      = if available ub.auto-tank then ub.auto-tank.auto-num else varauto-num:screen-value
            varauto-tank-sec = string(tt_auto-tank-sec.sec-num)
            .
         run str/auto-tncs.w
            ( input        {&lookup}
            ,input        varauto-num
            ,input        c-AC-type
            ,input        C-neck
            ,input-output varauto-tank-sec
            ) no-error.
      end.
      else 
      do:
         message "Не выбрана секция." view-as alert-box error.
      end.  
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brw-auto-num-sec
&Scoped-define SELF-NAME brw-auto-num-sec
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brw-auto-num-sec Dialog-Frame
ON choose OF brw-auto-num-sec IN FRAME Dialog-Frame
   DO:
      find first tt_auto-tank-sec no-error . 
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME c-AC-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-AC-type Dialog-Frame
ON VALUE-CHANGED OF c-AC-type IN FRAME Dialog-Frame /* Тип АЦ */
   DO:
      assign c-AC-type .
      if c-AC-type = 1 then 
      do:
         enable
            C-neck
            f-error
            f-temp
            with frame {&frame-name} .
         display
            f-error
            f-temp
            with frame {&frame-name} .
         hide
            valve
            con-sleeve
            in frame {&frame-name} .   
      end.   
      else 
      if c-AC-type = 2 then 
      do:
         hide
            C-neck
            f-error
            f-temp
            in frame {&frame-name} .   
         display
            valve
            con-sleeve
            with frame {&frame-name} .  
         enable
            valve
            con-sleeve
            with frame {&frame-name} .     
      end.     
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME C-neck
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-neck Dialog-Frame
ON VALUE-CHANGED OF C-neck IN FRAME Dialog-Frame /* Горловина */
   DO:
      assign C-neck .
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-error
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-error Dialog-Frame
ON VALUE-CHANGED OF f-error IN FRAME Dialog-Frame /* Относительная погрешность определения объема  АЦ, % */
   DO:
      assign f-error .
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-temp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-temp Dialog-Frame
ON VALUE-CHANGED OF f-temp IN FRAME Dialog-Frame /* Темпер.коэф. линейного расширения материала стенки АЦ,°С */
   DO:
      assign f-temp .
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME SEP
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL SEP Dialog-Frame
ON VALUE-CHANGED OF SEP IN FRAME Dialog-Frame /* СЭП */
   DO:
      assign SEP .
        
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

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

   if parmode = {&lookup} then 
   do:
      find first ub.auto-tank where recid(ub.auto-tank) = parrecid no-lock.
      find first error_auto-tank-attr no-lock
         where error_auto-tank-attr.auto-num = ub.auto-tank.auto-num
         and error_auto-tank-attr.attr-code = "auto-error" no-error.
      find first temp_auto-tank-attr no-lock
         where temp_auto-tank-attr.auto-num = ub.auto-tank.auto-num
         and temp_auto-tank-attr.attr-code = "auto-temp" no-error.
      find first type_auto-tank-attr no-lock
         where type_auto-tank-attr.auto-num = ub.auto-tank.auto-num
         and type_auto-tank-attr.attr-code = "autotype-AC" no-error.
      find first neck_auto-tank-attr no-lock
         where neck_auto-tank-attr.auto-num = ub.auto-tank.auto-num
         and neck_auto-tank-attr.attr-code = "autotype-neck" no-error.           
      find first sep_auto-tank-attr no-lock
         where sep_auto-tank-attr.auto-num = ub.auto-tank.auto-num
         and sep_auto-tank-attr.attr-code = "auto-sep" no-error.  
      find first valve_auto-tank-attr no-lock
         where valve_auto-tank-attr.auto-num = ub.auto-tank.auto-num
         and valve_auto-tank-attr.attr-code = "valve" no-error.           
      find first con-sleeve_auto-tank-attr no-lock
         where con-sleeve_auto-tank-attr.auto-num = ub.auto-tank.auto-num
         and con-sleeve_auto-tank-attr.attr-code = "con-sleeve" no-error. 
   end.
   if parmode = {&update} then 
   do:
      do transaction:
         find first ub.auto-tank where recid(ub.auto-tank) = parrecid exclusive-lock.
         find first error_auto-tank-attr exclusive-lock
            where error_auto-tank-attr.auto-num = ub.auto-tank.auto-num
            and error_auto-tank-attr.attr-code = "auto-error" no-error.
         find first temp_auto-tank-attr exclusive-lock
            where temp_auto-tank-attr.auto-num = ub.auto-tank.auto-num
            and temp_auto-tank-attr.attr-code = "auto-temp" no-error.
         find first type_auto-tank-attr exclusive-lock
            where type_auto-tank-attr.auto-num = ub.auto-tank.auto-num
            and type_auto-tank-attr.attr-code = "autotype-AC" no-error.
         find first neck_auto-tank-attr exclusive-lock
            where neck_auto-tank-attr.auto-num = ub.auto-tank.auto-num
            and neck_auto-tank-attr.attr-code = "autotype-neck" no-error.
         find first sep_auto-tank-attr exclusive-lock
            where sep_auto-tank-attr.auto-num = ub.auto-tank.auto-num
            and sep_auto-tank-attr.attr-code = "auto-sep" no-error.     
         find first valve_auto-tank-attr exclusive-lock
            where valve_auto-tank-attr.auto-num = ub.auto-tank.auto-num
            and valve_auto-tank-attr.attr-code = "valve" no-error.           
         find first con-sleeve_auto-tank-attr exclusive-lock
            where con-sleeve_auto-tank-attr.auto-num = ub.auto-tank.auto-num
            and con-sleeve_auto-tank-attr.attr-code = "con-sleeve" no-error.         
      end.
   end.
   if parmode = {&lookup} or
      parmode = {&update} then 
   do:
      assign
         varauto-num  = ub.auto-tank.auto-num
         varname      = ub.auto-tank.NAME
         varps        = ub.auto-tank.ps
         varauto-firm = string (ub.auto-tank.firm-type) + " " + string (ub.auto-tank.firm-code)
         c-AC-type    = ub.auto-tank.type-AC
         C-neck       = ub.auto-tank.type-neck.

      if available error_auto-tank-attr then f-error = decimal(error_auto-tank-attr.attr-value).
      if available temp_auto-tank-attr then f-temp = decimal(temp_auto-tank-attr.attr-value) .
      if available sep_auto-tank-attr then sep = logical (sep_auto-tank-attr.attr-value) .
      if available valve_auto-tank-attr then valve = logical (valve_auto-tank-attr.attr-value) .
      if available con-sleeve_auto-tank-attr then con-sleeve = decimal(con-sleeve_auto-tank-attr.attr-value) .
      if varauto-firm = "" or varauto-firm = ? then 
      do:
         FOR first auto-tank-attr no-lock where auto-tank-attr.attr-code = "auto-firm"
            and auto-tank-attr.auto-num = ub.auto-tank.auto-num:
            varauto-firm = auto-tank-attr.attr-value .
         end.   
      end.   

   end.

   run init-proc in this-procedure .

   RUN local-enable_UI.
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
   DISPLAY SEP varname varauto-num varauto-firm c-AC-type C-neck f-error f-temp 
      varPS 
      WITH FRAME Dialog-Frame.
   ENABLE b-cancel b-help RECT-1 RECT-2 SEP c-AC-type b-choose-auto-firm C-neck 
      f-error f-temp varPS b-view-sec brw-auto-num-sec 
      WITH FRAME Dialog-Frame.
   VIEW FRAME Dialog-Frame.
   {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame 
PROCEDURE init-proc :
   /*------------------------------------------------------------------------------
        Purpose:     
        Parameters:  <none>
        Notes:       
      ------------------------------------------------------------------------------*/
   define variable v-diam   as character no-undo .
   define variable v-name   as decimal   no-undo .
   define variable v-lenght as character no-undo .
   define variable v-width  as character no-undo .
   
   FOR EACH tt_auto-tank-sec EXCLUSIVE-LOCK:
      DELETE tt_auto-tank-sec.
   END.

   v-auto-num = if available ub.auto-tank then ub.auto-tank.auto-num else varauto-num:screen-value in frame {&frame-name} .
   FOR EACH buf_auto-section WHERE buf_auto-section.auto-num = v-auto-num NO-LOCK:
      CREATE tt_auto-tank-sec.
      ASSIGN 
         tt_auto-tank-sec.sec-num     = buf_auto-section.section-num
         tt_auto-tank-sec.brutto-qnty = buf_auto-section.brutto-qnty
         tt_auto-tank-sec.add-volume  = buf_auto-section.add-volume
      NO-ERROR. 
   END.

   FIND FIRST tt_auto-tank-sec WHERE tt_auto-tank-sec.sec-num = 1 NO-LOCK NO-ERROR.
   IF AVAILABLE tt_auto-tank-sec THEN 
   DO:
      REPOSITION brw-auto-num-sec TO RECID recid(tt_auto-tank-sec) NO-ERROR.
   END.

   apply "value-changed" to brw-auto-num-sec in frame dialog-frame.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-enable_UI Dialog-Frame 
PROCEDURE local-enable_UI :
   /*------------------------------------------------------------------------------
     Purpose:     Override standard ADM method
     Notes:
   ------------------------------------------------------------------------------*/

   /* Code placed here will execute PRIOR to standard behavior. */

   /* Dispatch standard ADM method.                             */

   RUN enable_ui IN THIS-PROCEDURE.

   if parmode = {&add-def} or parmode = {&update} then 
   do:
      enable b-choose-auto-firm c-AC-type varPS varauto-num varname varauto-firm b-save b-add-sec b-chg-sec b-del-sec with frame {&frame-name}.
      assign 
         varps:read-only = no.
      if c-AC-type = 1 then 
      do:
         enable
            C-neck
            f-error
            f-temp
            sep
            with frame {&frame-name} .
         display
            f-error
            f-temp
            with frame {&frame-name} .
      end.  
      if sep then 
      do:
         disable
            C-neck
            f-error
            f-temp
            with frame {&frame-name} .
      end.   
   end.
   hide
    valve
    con-sleeve
    in frame {&frame-name} . 
   apply "value-changed" to c-ac-type in frame dialog-frame.
   {&OPEN-QUERY-brw-auto-num-sec}
   
   if parmode = {&lookup}
   then do :
     disable
         b-choose-auto-firm c-AC-type varPS varauto-num varname varauto-firm sep
         C-neck f-error f-temp valve con-sleeve
         with frame {&frame-name} .
   end .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

