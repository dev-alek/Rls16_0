&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME dbi
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS dbi 
/*

$Revision: 8c1a0fd433e1, 1120, rls $
$Author: SMMolotkov $
$Date: Thu Dec 14 02:13:53 2017 +0300 $
$Workfile: dbi.w $
$Archive: adm/dbi.w $

Редактирование БД

Автор: Уханов Дмитрий Юрьевич
Дата создания: 04/12/99
Author: Dmitry Ukhanov
Creation date: 04/12/99

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input param mode as char no-undo.
define input-output param  ri as recid no-undo init ?.
define output parameter p-unload-history as logical no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision: 8c1a0fd433e1, 1120, rls $":U .
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:13:53 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dbi.w $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/dbi.w $":U .
define variable vss-description as character no-undo init "Редактирование БД".
{ cmp/vssrevis.i "substitute('&1',mode)" }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ adm/db-key.i   }
{ gbl/db-attr.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME dbi

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS db.db-name db.add-clients db.add-goods 
&Scoped-define ENABLED-TABLES db
&Scoped-define FIRST-ENABLED-TABLE db
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-help RECT-1 f-region ~
b-region 
&Scoped-Define DISPLAYED-FIELDS db.db-num db.db-key db.db-key-enc ~
db.db-name db.add-clients db.add-goods 
&Scoped-define DISPLAYED-TABLES db
&Scoped-define FIRST-DISPLAYED-TABLE db
&Scoped-Define DISPLAYED-OBJECTS f-region f-region-name 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO DEFAULT 
     LABEL "&Ввод ":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-help DEFAULT 
     LABEL "Помо&щь":L 
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY DEFAULT 
     LABEL "&Отмена":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-region 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L 
     SIZE 3 BY 1.

DEFINE VARIABLE f-days AS CHARACTER FORMAT "X(256)":U INITIAL "дней" 
      VIEW-AS TEXT 
     SIZE 5 BY 1 NO-UNDO.

DEFINE VARIABLE f-if AS CHARACTER FORMAT "X(256)":U INITIAL "Условия переформирования пакетов:" 
      VIEW-AS TEXT 
     SIZE 42.4 BY .67 NO-UNDO.

DEFINE VARIABLE f-region AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0 
     LABEL "Регион" 
     VIEW-AS FILL-IN 
     SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE f-region-name AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 46 BY .95 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL   
     SIZE 79 BY 2.24.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL   
     SIZE 79 BY 1.52.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL   
     SIZE 79 BY 4.76.

DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL   
     SIZE 79 BY 3.52.

DEFINE VARIABLE t-save-packs AS LOGICAL INITIAL no 
     LABEL "Удалять файлы пакетов СПН из каталога heap" 
     VIEW-AS TOGGLE-BOX
     SIZE 45 BY 1 NO-UNDO.

DEFINE VARIABLE t-unload-history AS LOGICAL INITIAL yes 
     LABEL "Выгружать историю" 
     VIEW-AS TOGGLE-BOX
     SIZE 64 BY .81
     FGCOLOR 12  NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME dbi
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 77
     db.db-num AT ROW 2.67 COL 12 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 10 BY 1
     db.db-key AT ROW 2.67 COL 34 COLON-ALIGNED
          LABEL "Ключ БД" FORMAT "X(12)"
          VIEW-AS FILL-IN 
          SIZE 13 BY 1
     db.db-key-enc AT ROW 2.67 COL 61 COLON-ALIGNED
          LABEL "Кодировка" FORMAT "X(16)"
          VIEW-AS FILL-IN 
          SIZE 17 BY 1
     db.db-name AT ROW 3.86 COL 12 COLON-ALIGNED FORMAT "X(40)"
          VIEW-AS FILL-IN 
          SIZE 57.4 BY 1
     f-region AT ROW 5.05 COL 12 COLON-ALIGNED WIDGET-ID 14
     b-region AT ROW 5.05 COL 20 WIDGET-ID 68
     db.add-clients AT ROW 6.71 COL 3
          VIEW-AS TOGGLE-BOX
          SIZE 22.6 BY .81 TOOLTIP "Возможность добавления клиентов"
     db.remote-stock AT ROW 6.71 COL 27 HELP
          ""
          VIEW-AS TOGGLE-BOX
          SIZE 21 BY .81 TOOLTIP "Отправка чужих остатков"
     db.send-check AT ROW 6.71 COL 56 HELP
          ""
          LABEL "Пересылать чеки"
          VIEW-AS TOGGLE-BOX
          SIZE 23.4 BY .81 TOOLTIP "ОТправлять чеки из БД в ГБД"
     db.add-goods AT ROW 7.71 COL 3
          VIEW-AS TOGGLE-BOX
          SIZE 22.2 BY .81 TOOLTIP "Возможность добавлять товары"
     db.on-line-rest AT ROW 7.71 COL 27 WIDGET-ID 2
          VIEW-AS TOGGLE-BOX
          SIZE 22 BY .81
     t-save-packs AT ROW 8.95 COL 3 WIDGET-ID 8
     db.save-packs AT ROW 8.95 COL 53.6 COLON-ALIGNED HELP
          "" WIDGET-ID 6
          LABEL "через"
          VIEW-AS FILL-IN 
          SIZE 5 BY 1
     db.max-p-size AT ROW 10.52 COL 53.6 COLON-ALIGNED
          LABEL "Максимальное кол-во записей в пакете"
          VIEW-AS FILL-IN 
          SIZE 14.4 BY 1
     db.max-p-queue AT ROW 12.48 COL 53.6 COLON-ALIGNED
          LABEL "Кол-во неподтвержденных пакетов больше" FORMAT "->>9"
          VIEW-AS FILL-IN 
          SIZE 6.2 BY 1
     db.max-p-time AT ROW 13.71 COL 53.6 COLON-ALIGNED HELP
          ""
          LABEL "Время ожидания подтверждения больше (мин)" FORMAT ">>>>>9"
          VIEW-AS FILL-IN 
          SIZE 7 BY 1
     db.unload-arch AT ROW 15.19 COL 3
          LABEL "Выгружать складские архивы по товарам и по поставщикам"
          VIEW-AS TOGGLE-BOX
          SIZE 64 BY .81
          FGCOLOR 12 
     db.unload-aht AT ROW 16.19 COL 3
          LABEL "Выгружать складской архив по типам приобретения"
          VIEW-AS TOGGLE-BOX
          SIZE 64 BY .81
          FGCOLOR 12 
     t-unload-history AT ROW 17.19 COL 3 WIDGET-ID 4
     f-region-name AT ROW 5.05 COL 23 COLON-ALIGNED NO-LABEL WIDGET-ID 16
     f-days AT ROW 8.95 COL 59.6 COLON-ALIGNED NO-LABEL WIDGET-ID 10
     f-if AT ROW 11.71 COL 4 NO-LABEL
     RECT-2 AT ROW 8.71 COL 2
     RECT-4 AT ROW 14.95 COL 2
     RECT-1 AT ROW 6.48 COL 2
     RECT-3 AT ROW 10.19 COL 2 WIDGET-ID 12
     SPACE(0.19) SKIP(3.56)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "БД":L
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX dbi
   FRAME-NAME                                                           */
ASSIGN 
       FRAME dbi:SCROLLABLE       = FALSE.

/* SETTINGS FOR FILL-IN db.db-key IN FRAME dbi
   NO-ENABLE EXP-LABEL EXP-FORMAT                                       */
/* SETTINGS FOR FILL-IN db.db-key-enc IN FRAME dbi
   NO-ENABLE EXP-LABEL EXP-FORMAT                                       */
/* SETTINGS FOR FILL-IN db.db-name IN FRAME dbi
   EXP-FORMAT                                                           */
/* SETTINGS FOR FILL-IN db.db-num IN FRAME dbi
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-days IN FRAME dbi
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       f-days:HIDDEN IN FRAME dbi           = TRUE
       f-days:READ-ONLY IN FRAME dbi        = TRUE.

/* SETTINGS FOR FILL-IN f-if IN FRAME dbi
   NO-DISPLAY NO-ENABLE ALIGN-L                                         */
ASSIGN 
       f-if:HIDDEN IN FRAME dbi           = TRUE
       f-if:READ-ONLY IN FRAME dbi        = TRUE.

/* SETTINGS FOR FILL-IN f-region-name IN FRAME dbi
   NO-ENABLE                                                            */
ASSIGN 
       f-region-name:READ-ONLY IN FRAME dbi        = TRUE.

/* SETTINGS FOR FILL-IN db.max-p-queue IN FRAME dbi
   NO-DISPLAY NO-ENABLE EXP-LABEL                                       */
ASSIGN 
       db.max-p-queue:HIDDEN IN FRAME dbi           = TRUE.

/* SETTINGS FOR FILL-IN db.max-p-size IN FRAME dbi
   NO-DISPLAY NO-ENABLE EXP-LABEL                                       */
ASSIGN 
       db.max-p-size:HIDDEN IN FRAME dbi           = TRUE.

/* SETTINGS FOR FILL-IN db.max-p-time IN FRAME dbi
   NO-DISPLAY NO-ENABLE EXP-LABEL EXP-FORMAT EXP-HELP                   */
ASSIGN 
       db.max-p-time:HIDDEN IN FRAME dbi           = TRUE.

/* SETTINGS FOR TOGGLE-BOX db.on-line-rest IN FRAME dbi
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       db.on-line-rest:HIDDEN IN FRAME dbi           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-2 IN FRAME dbi
   NO-ENABLE                                                            */
ASSIGN 
       RECT-2:HIDDEN IN FRAME dbi           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-3 IN FRAME dbi
   NO-ENABLE                                                            */
ASSIGN 
       RECT-3:HIDDEN IN FRAME dbi           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-4 IN FRAME dbi
   NO-ENABLE                                                            */
ASSIGN 
       RECT-4:HIDDEN IN FRAME dbi           = TRUE.

/* SETTINGS FOR TOGGLE-BOX db.remote-stock IN FRAME dbi
   NO-DISPLAY NO-ENABLE EXP-HELP                                        */
ASSIGN 
       db.remote-stock:HIDDEN IN FRAME dbi           = TRUE.

/* SETTINGS FOR FILL-IN db.save-packs IN FRAME dbi
   NO-DISPLAY NO-ENABLE EXP-LABEL EXP-HELP                              */
ASSIGN 
       db.save-packs:HIDDEN IN FRAME dbi           = TRUE.

/* SETTINGS FOR TOGGLE-BOX db.send-check IN FRAME dbi
   NO-DISPLAY NO-ENABLE EXP-LABEL EXP-HELP                              */
ASSIGN 
       db.send-check:HIDDEN IN FRAME dbi           = TRUE.

/* SETTINGS FOR TOGGLE-BOX t-save-packs IN FRAME dbi
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       t-save-packs:HIDDEN IN FRAME dbi           = TRUE.

/* SETTINGS FOR TOGGLE-BOX t-unload-history IN FRAME dbi
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       t-unload-history:HIDDEN IN FRAME dbi           = TRUE.

/* SETTINGS FOR TOGGLE-BOX db.unload-aht IN FRAME dbi
   NO-DISPLAY NO-ENABLE EXP-LABEL                                       */
ASSIGN 
       db.unload-aht:HIDDEN IN FRAME dbi           = TRUE.

/* SETTINGS FOR TOGGLE-BOX db.unload-arch IN FRAME dbi
   NO-DISPLAY NO-ENABLE EXP-LABEL                                       */
ASSIGN 
       db.unload-arch:HIDDEN IN FRAME dbi           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit dbi
ON CHOOSE OF b-exit IN FRAME dbi /* Ввод  */
DO:

  define variable ret-val as integer no-undo .
  define variable v-db-attr-del as logical   no-undo .
  define variable v-reg-attr as integer no-undo.  

  define buffer buf1_db     for ub.db .
  define buffer buf_clients for ub.clients .
  define buffer buf_gds-obj for ub.gds-obj .

  if mode = "add":U then do:
    if input frame {&frame-name} ub.db.db-num = ? then do:
      message "Введите номер БД."
              view-as alert-box error.
      apply "ENTRY" to ub.db.db-num.
      return no-apply.
    end.
    if can-find (buf1_db where buf1_db.db-num = input frame {&frame-name} ub.db.db-num no-lock ) then do:
      message "БД с таким номером уже есть."
              view-as alert-box error.
      apply "ENTRY" to ub.db.db-num.
      undo, return no-apply.
    end.
  end.
  if ub.db.db-num :sensitive in frame {&frame-name} = true then do:
    assign
      ub.db.db-num
    .
  end.
  if ub.db.db-key :sensitive in frame {&frame-name} = true then do:
    if mode = "unld":U
      or ( mode <> "unld":U
           and trim( ub.db.db-key ) <> "":U
         )
    then do:
      run chk-db-key
        ( input ( input frame {&frame-name} ub.db.db-num )
        ,input ( input frame {&frame-name} ub.db.db-key )
        ,input ( input frame {&frame-name} ub.db.db-key-enc )
        ,output ret-val
        ).

      if ret-val <> 0 then do:
        message return-value
                view-as alert-box error.
        if ret-val = 1 then do:
          apply "ENTRY" to ub.db.db-key.
        end.
        else do:
          apply "ENTRY" to ub.db.db-key-enc.
        end.
        undo, return no-apply.
      end.
      assign
        ub.db.db-key
        ub.db.db-key-enc
        .
    end.
  end.
  if input frame {&frame-name} ub.db.db-name = "" then do:
    message "Название БД не может быть пустым."
            view-as alert-box error.
    apply "ENTRY" to ub.db.db-name.
    undo, return no-apply.
  end.
  if ub.db.on-line-rest = true
    and input frame {&frame-name} ub.db.on-line-rest = false
  then do:
    for each buf_clients no-lock
      where buf_clients.db-num = ub.db.db-num
      ,each buf_gds-obj
      where buf_gds-obj.obj-type = buf_clients.obj-type
        and buf_gds-obj.obj-code = buf_clients.obj-code
    on error undo, return no-apply
    :
      assign
        buf_gds-obj.on-line-rest = ?
      .
    end.
  end.
  assign
    ub.db.db-name
    ub.db.add-clients
    ub.db.add-goods
    ub.db.on-line-rest
    ub.db.remote-stock
    ub.db.max-p-queue
    ub.db.max-p-time
    ub.db.max-p-size
    ub.db.db-key
    ub.db.db-key-enc
    ub.db.send-check
    ub.db.unload-arch
    ub.db.unload-aht
    f-region
    t-save-packs    
    t-unload-history when mode = "unld"
    ri = recid (ub.db)
    p-unload-history = t-unload-history
  .
  if trim( ub.db.db-key ) <> "":U then do:
    run save-db-key( ub.db.db-key ) no-error.
    if error-status:error then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Невозможно сохранить ключ базы." ) skip
        return-value skip
        error-status :get-message ( error-status :num-messages )
        view-as alert-box error
      .
      undo, return no-apply.
    end.
  end.

  if t-save-packs :sensitive in frame {&frame-name} = true then do:
    if t-save-packs = true then do:
      assign
        ub.db.save-packs
      .
    end.
    else do:
      assign
        ub.db.save-packs = ?
      .
    end.
  end.
  
  if f-region <> ? and f-region <> 0 then do:
      run db-attr-write in this-procedure (ub.db.db-num, "reg-code", f-region) no-error.
      if error-status:error then do:
         message substitute("Ошибка сохранения кода региона &1 для БД &2: &3",f-region, ub.db.db-num, return-value)
           view-as alert-box error.
         undo, return no-apply. 
      end.    
  end.    
  else do:
      run db-attr-exist in this-procedure (ub.db.db-num, "reg-code", output v-db-attr-del) no-error.
      if v-db-attr-del then
        run db-attr-delete in this-procedure (ub.db.db-num, "reg-code", output v-db-attr-del) no-error.
  end.    

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit dbi
ON CHOOSE OF b-quit IN FRAME dbi /* Отмена */
DO:
  if mode = "add":U then do:
    delete ub.db.
  end.
  if mode <> "lkp":U then do:
    assign
      ri = ?
    .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-region
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-region dbi
ON CHOOSE OF b-region IN FRAME dbi
DO:  
    define buffer buf_regions for ub.regions.
    define variable v-reg-code as integer no-undo.
    
    run ref/regions.w ( input  ?
                      , input  {&choose}
                      , output v-reg-code
                       ).
  
    if v-reg-code = ? or v-reg-code = 0 then return.
    find first buf_regions no-lock
         where buf_regions.reg-code = v-reg-code
       no-error .
    if available buf_regions then do:
       assign
          f-region      = buf_regions.reg-code
          f-region-name = buf_regions.reg-name
          .
    end.    
    else do:
       assign
          f-region      = ?
          f-region-name = "":U
          .
    end.             
  
    display
      f-region
      f-region-name
      with frame {&frame-name} .
    /*apply "entry" to f-region in frame {&frame-name}.*/  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME f-region
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-region dbi
ON VALUE-CHANGED OF f-region IN FRAME dbi /* через */
DO:
  define buffer buf_regions for ub.regions.
  
  assign
    f-region
  .
  if f-region <> ? and f-region <> 0 then do:
      find first buf_regions no-lock
           where buf_regions.reg-code = f-region
         no-error .
      if available buf_regions then do:
         assign
            f-region      = buf_regions.reg-code
            f-region-name = buf_regions.reg-name
            .
      end.    
      else do:
         message "Отсутствует регион с кодом " f-region
         view-as alert-box.
         assign
            f-region      = ?
            f-region-name = "":U
            .
      end.
  end.
  else f-region-name = "":U.
  
  display
      f-region
      f-region-name
      with frame {&frame-name} .  
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME db.save-packs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL db.save-packs dbi
ON LEAVE OF db.save-packs IN FRAME dbi /* через */
DO:
  assign
    ub.db.save-packs
  .
  if ub.db.save-packs < 10 then do:
    message
      substitute( "Удалять пакеты раньше чем через 10 дней нельзя!" )
      view-as alert-box.
    assign
      ub.db.save-packs = 10
    .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-save-packs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-save-packs dbi
ON VALUE-CHANGED OF t-save-packs IN FRAME dbi /* Удалять файлы пакетов СПН из каталога heap */
DO:
  assign
    t-save-packs
  .
  if t-save-packs = true then do:
    if ub.db.save-packs = ?
      or ub.db.save-packs < 10
    then do:
      assign
        ub.db.save-packs = 10
      .
    end.
    enable
      ub.db.save-packs
      with frame {&frame-name}
      .
    display
      ub.db.save-packs
      f-days
      with frame {&frame-name}
      .
  end.
  else do:
    hide
      ub.db.save-packs
      f-days
      in frame {&frame-name}
      .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK dbi 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON STOP    UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/app_help.i }

  define variable ret-val as integer no-undo .
  define variable v-db-attr-value as character no-undo .
  define variable v-db-attr-type  as character no-undo .

  if mode <> "add":U then do:
    if mode = "lkp":U then do:
      find ub.db no-lock
        where recid (ub.db) = ri
        no-error
      .
    end.
    else do:
      find ub.db exclusive-lock
        where recid (ub.db) = ri
        no-error
      .
    end.
    if not available ub.db then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "БД &1 удалена." ) skip
        view-as alert-box information
      .
      return error .
    end.
  end.
/*  assign*/
/*    f-if = "Условия переформирования пакетов:"*/
/*  .*/

  case mode:
    when "add":U then do:
      create ub.db.
      frame {&frame-name}:title = "Добавление БД".
      assign
        ub.db.db-key      = "":U
        ub.db.db-key-enc  = "":U
        ub.db.max-p-size  = 10000
        ub.db.max-p-time  = 20
        ub.db.max-p-queue = 10
      .
    end.
    when "unld":U then do:
      frame {&frame-name}:title = "Выгрузка БД".
      if trim( ub.db.db-key ) <> "":U
        and trim( ub.db.db-key-enc ) <> "":U
      then do:
        run chk-db-key ( input ub.db.db-num
                        ,input ub.db.db-key
                        ,input ub.db.db-key-enc
                        ,output ret-val
                       ).
      end.

      assign
        ub.db.db-key     = "":U
        ub.db.db-key-enc = "":U
      .
    end.
    when "upd":U then do:
      frame {&frame-name}:title = "Изменение БД".
    end.
    when "lkp":U then do:
      frame {&frame-name}:title = "Просмотр БД".
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Не предусмотрена операция &1", mode ) skip
        view-as alert-box error
      .
      return error .
    end.
  end case.
  session:data-entry-return = yes .

  if ub.db.db-num = 0 then do:
    assign
      frame dbi :height-chars = 8.5
    .
  end.
  else do:
      run db-attr-value in this-procedure (ub.db.db-num, 
                                           "reg-code", 
                                           output f-region,
                                           output v-db-attr-type) no-error.
      if f-region = 0 then f-region = ?.                                     
  end.    


  RUN enable_UI.

  if ub.db.db-num <> 0 then do:
    enable
      ub.db.on-line-rest
      ub.db.send-check
      ub.db.remote-stock
      ub.db.max-p-queue
      ub.db.max-p-time
      ub.db.max-p-size
      ub.db.unload-arch
      ub.db.unload-aht
      f-region
      f-region-name
      t-save-packs
      RECT-2
      RECT-3
      RECT-4
      f-if
      WITH FRAME dbi
    .
    display
      ub.db.on-line-rest
      ub.db.send-check
      ub.db.remote-stock
      ub.db.max-p-queue
      ub.db.max-p-time
      ub.db.max-p-size
      ub.db.unload-arch
      ub.db.unload-aht
      f-region
      f-region-name
      t-save-packs
      f-if
      WITH FRAME dbi
    .
    if ub.db.save-packs <> ? then do:
      assign
        t-save-packs = true
      .
    end.
    else do:
      assign
        t-save-packs = false
      .
    end.

    display
      t-save-packs
      with frame dbi
    .

    apply "VALUE-CHANGED" to t-save-packs in frame {&frame-name} .
    apply "VALUE-CHANGED" to f-region in frame {&frame-name} .
  end.

  case mode:
    when "add":U then do:
      ENABLE ub.db.db-num WITH FRAME dbi.
    end.
    when "unld":U then do:
      ENABLE ub.db.db-key ub.db.db-key-enc t-unload-history WITH FRAME dbi.
      display
        t-unload-history
        with frame dbi .
    end.
    when "upd":U then do:
/*Исправление возможных проблем в СПН при выгрузке из копии. */
/*Сделано: */
/*1. выгрузить УБД из копии без установленного ключа нельзя*/
/*2. если для УБД не установлен ключ, то можно его установить не выгружая ее. */
      if trim( ub.db.db-key ) = "":U
        or trim( ub.db.db-key ) = ?
      then do:
        ENABLE ub.db.db-key ub.db.db-key-enc WITH FRAME dbi.
      end.
    end.
    when "lkp":U then do:
      disable all WITH FRAME dbi.
      ENABLE b-quit b-help WITH FRAME dbi.
    end.
  end case.

  {&OPEN-BROWSERS-IN-QUERY-dbi}
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.
session:data-entry-return = no .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI dbi  _DEFAULT-DISABLE
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
  HIDE FRAME dbi.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI dbi  _DEFAULT-ENABLE
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
  DISPLAY f-region f-region-name 
      WITH FRAME dbi.
  IF AVAILABLE db THEN 
    DISPLAY db.db-num db.db-key db.db-key-enc db.db-name db.add-clients 
          db.add-goods 
      WITH FRAME dbi.
  ENABLE b-exit b-quit b-help RECT-1 db.db-name f-region b-region 
         db.add-clients db.add-goods 
      WITH FRAME dbi.
  {&OPEN-BROWSERS-IN-QUERY-dbi}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

