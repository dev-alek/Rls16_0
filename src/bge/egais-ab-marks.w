&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------


$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Акцизные марки

Автор: Шкляр Елена 
Дата создания: 01/16/07
Author: Elena Shklyar
Creation date: 01/16/07

          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
using ibs.th.bge.egais.*. 
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DECLARATIONS Procedure
using ibs.th.str.alcohol.*.
&ANALYZE-RESUME
{ibs/th/bge/egais/ab-egais.i  shared}
{ str/inv-marks-tt.i  -doc }
/* Parameters Definitions ---                                           */
define input parameter parparentproc     as handle       no-undo.
define input parameter p-num             as character    no-undo .
define input parameter p-position        as integer      no-undo .
define input parameter p-alc-code        as character    no-undo.
define input parameter p-qnty-goods      as integer      no-undo.
define input parameter p-mode            as character    no-undo.
define INPUT-OUTPUT PARAMETER TABLE FOR  tt-marks.

/*define variable v-proc-name-err    as character    no-undo.*/

define variable l-error         as logical   no-undo. /* Есть ли ошибки */
define variable v-user-action   as character no-undo.
define variable v-printed       as logical   no-undo.
define variable v-proc-name-err as character no-undo initial 'impmark.err'. /* Имя лога */
define variable v-proc-name-alc as character no-undo initial 'alc-code.txt'. /* Имя лога */
def    var      extGdsObj       as class     extgds.
define variable browse-br-marks as handle    no-undo.
define variable bcol            as handle    no-undo.
define variable bcol1           as handle    no-undo.
define variable bcol2           as handle    no-undo.
define variable bcol3           as handle    no-undo.
define variable bcol4           as handle    no-undo.
define variable bcol5           as handle    no-undo.
define variable v-mode          as character no-undo. 
/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Акцизные марки".

define variable v-gds-code    like ub.goods.gds-code     no-undo .
define variable v-gds-name    as character    no-undo .
define variable v-alc-code    as character    no-undo .
define variable v-error-lang  as logical      no-undo .
define variable sort-column-name as character no-undo .
define variable v-key-rec as character no-undo .

define stream str-err .
define stream str-alc .
define variable excMarks as class excisemarks no-undo.

define temp-table tt-del-marks like tt-marks .

{ cmp/vssrevis.i }

{bge/egais-mark.i}
{ cmp/showinf.i  }
{ gbl/color.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-marks

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-marks

/* Definitions for BROWSE br-marks                                      */
&Scoped-define FIELDS-IN-QUERY-br-marks (IF tt-marks.flag THEN "+":U ELSE "-":U) (IF tt-marks.reserv = 1 THEN "+":U ELSE "-":U) tt-marks.parts tt-marks.mark tt-marks.alc-code tt-marks.gds-code tt-marks.gds-name tt-marks.impor-full-name tt-marks.prod-full-name   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-marks   
&Scoped-define QUERY-STRING-br-marks FOR EACH tt-marks NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-marks OPEN QUERY br-marks FOR EACH tt-marks NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-marks tt-marks
&Scoped-define FIRST-TABLE-IN-QUERY-br-marks tt-marks


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-marks}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_OK Btn_EXIT Btn_Cancel Btn_del Btn_imp ~
Btn_goods Btn_excpmarks v-qnty-marks v-qnty-goods v-mark br-marks 
&Scoped-Define DISPLAYED-OBJECTS v-qnty-marks v-qnty-goods v-mark 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_Cancel AUTO-END-KEY 
     LABEL "Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_del 
     LABEL "Удалить" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_EXIT AUTO-GO 
     LABEL "Выход" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_goods 
     LABEL "Товары" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_excpmarks 
     LABEL "Неучт. марки" 
     SIZE 13 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_imp 
     LABEL "Импорт" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK AUTO-GO 
     LABEL "Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE v-mark AS CHARACTER FORMAT "X(255)" 
     LABEL "Марка" 
     VIEW-AS FILL-IN 
     SIZE 80 BY 1.

DEFINE VARIABLE v-qnty-goods AS INTEGER FORMAT "->>>>9":U INITIAL 0 
     LABEL "кол-во в партии" 
     VIEW-AS FILL-IN 
     SIZE 5.5 BY 1 NO-UNDO.

DEFINE VARIABLE v-qnty-marks AS INTEGER FORMAT ">>>>9":U INITIAL 0 
     LABEL "кол-во марок" 
     VIEW-AS FILL-IN 
     SIZE 5.5 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-marks FOR 
      tt-marks SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-marks
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-marks Dialog-Frame _FREEFORM
  QUERY br-marks NO-LOCK DISPLAY
      (IF tt-marks.flag THEN "+":U ELSE "-":U) FORMAT "x(1)":U COLUMN-LABEL "Т"
    (IF tt-marks.reserv = 1 THEN "+":U ELSE "-":U) FORMAT "x(1)":U COLUMN-LABEL "R"
    tt-marks.parts
    WIDTH 10
    tt-marks.mark    
    WIDTH 40
    tt-marks.alc-code 
    WIDTH 20
    tt-marks.gds-code 
    WIDTH 10
    tt-marks.gds-name
    WIDTH 30 
    tt-marks.impor-full-name
    WIDTH 30 
    tt-marks.prod-full-name
    WIDTH 30
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 112 BY 20.21 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1.25 COL 2
     Btn_EXIT AT ROW 1.25 COL 2
     Btn_Cancel AT ROW 1.25 COL 12
     Btn_del AT ROW 1.25 COL 22
     Btn_imp AT ROW 1.25 COL 32
     Btn_goods AT ROW 1.25 COL 42
     Btn_excpmarks AT ROW 1.25 COL 52 WIDGET-ID 12
     v-qnty-marks AT ROW 1.25 COL 106 COLON-ALIGNED WIDGET-ID 8
     v-qnty-goods AT ROW 2.25 COL 106 COLON-ALIGNED WIDGET-ID 10
     v-mark AT ROW 2.71 COL 7 COLON-ALIGNED
     br-marks AT ROW 4 COL 2
     SPACE(1.00) SKIP(0.29)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Ввод Акцизных марок"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query,br-marks
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-marks v-mark Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-marks
/* Query rebuild information for BROWSE br-marks
     _TblList          = "tt-marks"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-marks */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Ввод Акцизных марок */
DO:
      APPLY "END-ERROR":U TO SELF.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-marks
&Scoped-define SELF-NAME br-marks
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-marks Dialog-Frame
ON ROW-DISPLAY OF br-marks IN FRAME Dialog-Frame
DO:

    if p-num = "" and p-position = 0 then 
    do:
      if tt-marks.gds-code = 0 then 
      do:
        tt-marks.gds-code:BGCOLOR in browse br-marks = red_COLOR.
        tt-marks.alc-code:BGCOLOR in browse br-marks = red_COLOR.
        tt-marks.mark:BGCOLOR in browse br-marks = red_COLOR.
        tt-marks.gds-name:BGCOLOR in browse br-marks = red_COLOR.
        tt-marks.prod-full-name:BGCOLOR in browse br-marks = red_COLOR.
        tt-marks.impor-full-name:BGCOLOR in browse br-marks = red_COLOR.
      end.
      if tt-marks.flag = yes then 
      do:
        tt-marks.gds-code:BGCOLOR in browse br-marks = DARK_GREY_COLOR.
      end.            
    end.          

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-marks Dialog-Frame
ON VALUE-CHANGED OF br-marks IN FRAME Dialog-Frame
DO:
  if available tt-marks then do:
        if tt-marks.gds-code <> 0 and p-mode = {&update} then do:
          enable Btn_goods 
          WITH FRAME Dialog-Frame. 
        end.
        else do:
          disable Btn_goods 
          WITH FRAME Dialog-Frame.
        end.    
   end.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_Cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_Cancel Dialog-Frame
ON choose OF Btn_Cancel IN FRAME Dialog-Frame /* Отмена */
DO:
      for each tt-marks exclusive-lock where tt-marks.new_ :
        delete tt-marks .
      end.
      for each tt-del-marks where not tt-del-marks.new_ :
        create tt-marks.
        buffer-copy tt-del-marks to tt-marks .
      end.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_del Dialog-Frame
ON choose OF Btn_del IN FRAME Dialog-Frame /* Удалить */
DO:
      if not available tt-marks then return no-apply .
      find first tt-del-marks no-lock where tt-del-marks.mark = tt-marks.mark no-error .
      if not available tt-del-marks
      then do :
          create tt-del-marks.
          buffer-copy tt-marks to tt-del-marks .
      end.
      delete tt-marks .
      open query br-marks for each tt-marks where tt-marks.num = p-num and tt-marks.gds-part-position_ = p-position.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_goods Dialog-Frame
ON choose OF Btn_goods IN FRAME Dialog-Frame /* Товары */
DO:
      define variable v-prod-full-name as character no-undo .
      define variable v-import-full-name as character no-undo .
      
      if available tt-marks then 
      do:
        v-mode = {&lookup}.
        v-gds-code = 0 .
        run bge/egais-goods-mark.w ( input parparentproc, input v-mode, input-output tt-marks.alc-code, input-output v-gds-code, output v-gds-name, output v-prod-full-name, output v-import-full-name )  .  
        if v-gds-code <> 0 then 
        do:
          assign
            tt-marks.gds-code = v-gds-code
            tt-marks.gds-name = v-gds-name
            tt-marks.prod-full-name = v-prod-full-name
            tt-marks.impor-full-name = v-import-full-name
            .
        end.   
        /*  open query br-marks for each tt-marks  where tt-marks.num = p-num and tt-marks.gds-part-position_ = p-position .*/
        Br-marks:refresh() in frame {&frame-name} .
      end.
      else
        message "Не выбран алког. код"
          view-as alert-box.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_excpmarks
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_excpmarks Dialog-Frame
ON CHOOSE OF Btn_excpmarks IN FRAME Dialog-Frame /* Неучт. марки */
DO:
  
  excMarks = new excisemarks(v-cntxt-obj-type, v-cntxt-obj-code).
  excMarks:GetMarkForInvDoc(v-key-rec, p-alc-code, input-output table tt-marks-doc).
  
  for each tt-marks-doc:
    create tt-marks.
    assign
      tt-marks.alc-code = tt-marks-doc.alc-code
      tt-marks.gds-code = tt-marks-doc.gds-code
      tt-marks.mark = tt-marks-doc.exciseMark
    no-error.
    if error-status:error
      then delete tt-marks.
  end.
  open query br-marks for each tt-marks .
  assign 
    v-mark:screen-value = "" .
  assign v-mark .
  apply "entry" to v-mark in FRAME {&FRAME-NAME}.
  
/* run str\inv-marks.w.*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_imp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_imp Dialog-Frame
ON choose OF Btn_imp IN FRAME Dialog-Frame /* Импорт */
DO:
      run proc-choose-file no-error .
      open query br-marks for each tt-marks  where tt-marks.num = p-num and tt-marks.gds-part-position_ = p-position .
      assign 
        v-mark:screen-value = "" .
      assign v-mark .
      apply "entry" to v-mark in FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON choose OF Btn_OK IN FRAME Dialog-Frame /* Ввод */
DO:
      for each tt-marks exclusive-lock :
        /*      RUN ProcAlcCode IN THIS-PROCEDURE (input tt-marks.mark, output v-alc-code).*/
        assign 
          tt-marks.new_ = false .
      end.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-mark Dialog-Frame
ON return OF v-mark IN FRAME Dialog-Frame /* Марка */
DO:

            define variable v-error as logical no-undo init no.
            output stream str-err to value(v-proc-name-err) append.
            output stream str-alc to value(v-proc-name-alc) append.
            def var ii as int.
            assign 
                v-mark = v-mark:screen-value .
            RUN ProcAlcCode IN THIS-PROCEDURE (input v-mark, output v-alc-code, output l-error, output v-error-lang) no-error.
            if v-error-lang then 
            do:
                message "Не корректно считана акцизная марка, перед считыванием переключите клавиатуру на английскую раскладку."
                    view-as alert-box.
                put stream str-err unformatted
                    "Не корректно считана акцизная марка, акцизная марка содержит не допустимые символы или русские буквы."
                    skip .
                assign 
                    v-mark              = ""
                    v-mark:screen-value = ""
                    .
            end.
            else 
            do:
                if l-error then 
                do:
                    message substitute ("Алког. код не преобразовывается в десятичную систему из акцизной марки: &1", v-mark)
                        view-as alert-box.
                    v-alc-code = "".
                    put stream str-err unformatted
                        substitute ("Алког. код не преобразовывается в десятичную систему из акцизной марки: &1", v-mark)
                        skip .
                end.
                else 
                do:
                    extGdsObj = new ExtGds (true).
                    extGdsObj:OpenQueryExtGds(0, v-alc-code).
                    if extGdsObj:NumBundles = 0 then 
                    do:
                        message substitute ("Для алког. кода &1 не найден товар (не установлено соответствие)", v-alc-code)
                            view-as alert-box.
                        put stream str-err unformatted
                            substitute ("Для алког. кода &1 не найден товар (не установлено соответствие)", v-alc-code)
                            skip .
                        if p-num = "" and p-position = 0 then 
                        do:
                            find first tt-marks where tt-marks.mark = v-mark no-lock no-error.
                            if not available tt-marks then 
                            do:
                                create tt-marks .
                            end.    
                            assign
                                tt-marks.mark     = v-mark 
                                tt-marks.new_     = true
                                tt-marks.alc-code = v-alc-code 
                                .
                        end.
                    end.
                    else 
                    do:
                        if p-alc-code <> "" and p-alc-code <> extGdsObj:GetExtGdsValue(1):AlcCode then 
                        do :
                            message "Не тот товар! Вы вводите марки для алк. кода " + p-alc-code skip 
                                "Алк. код в марке - " extGdsObj:GetExtGdsValue(1):AlcCode view-as alert-box .
                        end.
                        if (p-alc-code <> "" and p-alc-code = extGdsObj:GetExtGdsValue(1):AlcCode) or p-alc-code = "" then 
                        do:
                            find first tt-marks where tt-marks.mark = v-mark no-lock no-error.
                            if AVAILABLE tt-marks then 
                            do:
                                MESSAGE "Марка с таким" v-mark "кодом уже введена"
                                    VIEW-AS ALERT-BOX.
                            end.    
                            else
                            do:
                                create tt-marks .
                            end.    
                            assign
                                tt-marks.num                = p-num
                                tt-marks.gds-part-position_ = p-position 
                                tt-marks.mark               = v-mark 
                                tt-marks.new_               = true .
                            tt-marks.gds-code           = extGdsObj:GetExtGdsValue(1):GdsCode .
                            tt-marks.alc-code           = extGdsObj:GetExtGdsValue(1):AlcCode .
                            /*                tt-marks.gds-name           = extGdsObj:GetExtGdsValue(1):FullNameGds*/
                            tt-marks.prod-full-name     = extGdsObj:GetExtGdsValue(1):FullNameProd .
                            tt-marks.impor-full-name    = extGdsObj:GetExtGdsValue(1):FullNameImpor .
                            .
                            v-gds-code = extGdsObj:GetExtGdsValue(1):GdsCode .
                            find first ub.goods where ub.goods.gds-code = v-gds-code no-lock no-error.
                            if available ub.goods then tt-marks.gds-name = ub.goods.gds-name .
                            if extGdsObj:NumBundles > 1 then tt-marks.flag = yes .
                            if p-num = "" and p-position = 0 then 
                            do:
                                do ii = 1 to extGdsObj:NumBundles:
                                    find first ub.goods where ub.goods.gds-code = v-gds-code no-lock no-error.
                                    if available ub.goods then v-gds-name = ub.goods.gds-name .    
                                    put stream str-alc unformatted
                                        substitute  ("&1 &2 &3 &4 &5 &6 &7 &8 &9",extGdsObj:GetExtGdsValue(ii):AlcCode, extGdsObj:GetExtGdsValue(ii):GdsCode, v-gds-name, 
                                        extGdsObj:GetExtGdsValue(ii):CliRegIdProd, extGdsObj:GetExtGdsValue(ii):FullNameProd, extGdsObj:GetExtGdsValue(ii):INNProd,
                                        extGdsObj:GetExtGdsValue(ii):KPPProd, extGdsObj:GetExtGdsValue(ii):CountryProd, extGdsObj:GetExtGdsValue(ii):CliRegIdImpor).
                                    put stream str-alc unformatted
                                        substitute  ("&1 &2 &3 &4", extGdsObj:GetExtGdsValue(ii):FullNameImpor, extGdsObj:GetExtGdsValue(ii):INNImpor, extGdsObj:GetExtGdsValue(ii):KPPImpor, extGdsObj:GetExtGdsValue(ii):CountryImpor) skip .                                           
                                end.         
                            end.    
                        end.    
                    end.
                    delete object extGdsObj .
                end.
                open query br-marks for each tt-marks  where tt-marks.num = p-num and tt-marks.gds-part-position_ = p-position .
         
                assign 
                    v-mark:screen-value = "" .
                assign v-mark .
                run count-marks-parts no-error .
                apply "entry" to v-mark in FRAME {&FRAME-NAME}.
            end.
            output stream str-alc close.
            output stream str-err close.            
            apply "value-changed" to br-marks IN FRAME Dialog-Frame .
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
    if num-entries (p-mode) > 1
    then do:
      assign
        v-key-rec = entry (2, p-mode)
        p-mode = entry (1, p-mode)
      .
    end.

    RUN count-marks-parts no-error .    
    RUN enable_UI.
    WAIT-FOR GO OF FRAME {&FRAME-NAME}.
  END.
  RUN disable_UI.

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
    br-marks:column-resizable in frame dialog-frame = true .
    ENABLE Btn_OK Btn_Cancel Btn_del Btn_imp Btn_EXIT v-mark br-marks Btn_excpmarks  
        WITH FRAME Dialog-Frame.
    DISABLE Btn_goods v-qnty-marks v-qnty-goods
        WITH FRAME Dialog-Frame.   
    if p-mode = {&update} then 
    do:
        if p-num = "" and p-position = 0 then 
        do:
            disable Btn_Cancel Btn_del Btn_OK 
                WITH FRAME Dialog-Frame. 
            hide Btn_OK v-qnty-marks v-qnty-goods
                IN FRAME Dialog-Frame. 
        end.
        else 
        do:
            hide Btn_EXIT 
                IN FRAME Dialog-Frame. 
        end. 
    end.
    else 
    do:
        disable Btn_Cancel Btn_del Btn_OK Btn_imp
            WITH FRAME Dialog-Frame. 
        hide Btn_OK 
            IN FRAME Dialog-Frame. 
    end.       
    VIEW FRAME Dialog-Frame.
  
    open query br-marks for each tt-marks  where tt-marks.num = p-num and tt-marks.gds-part-position_ = p-position .
    apply "value-changed" to br-marks IN FRAME Dialog-Frame .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-choose-file Dialog-Frame 
PROCEDURE proc-choose-file :
/*Процедура выбора файла*/
    /* Выбор файла */
    if search (v-proc-name-err) <> ? then 
    do:
        os-delete value(v-proc-name-err).
    end.
    if search (v-proc-name-alc) <> ? then 
    do:
        os-delete value(v-proc-name-alc).
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
        output stream str-alc to value(v-proc-name-alc)  APPEND .
        INPUT FROM value(vCh). 
        /*DISABLE TRIGGERS FOR LOAD OF Customer.*/
        
        REPEAT: 
            IMPORT v-mark.
            find first tt-marks where tt-marks.mark = v-mark no-lock no-error .
            if not available tt-marks then 
            do:
                create tt-marks.
                tt-marks.mark = v-mark .
                  
                run ProcAlcCode  IN THIS-PROCEDURE (input v-mark, output v-alc-code, output l-error, output v-error-lang ) no-error.
                if v-error-lang then 
                do:
                    put stream str-err unformatted
                        "Не корректно считана акцизная марка, акцизная марка содержит не допустимые символы или русские буквы."
                        skip .
                    v-alc-code = "".
                    l-error = yes .
                end.  
                else 
                do:
                    if p-alc-code <> "" and v-alc-code <> p-alc-code then 
                    do:
                        put stream str-err unformatted
                            substitute ("Алког. кода &1 не соответствует алког. коду в партии", v-alc-code)
                            skip.
                        l-error = yes .    
                    end.
                    else 
                    do:      
                        extGdsObj = new ExtGds (true).
                        extGdsObj:OpenQueryExtGds(0, v-alc-code).
                        if extGdsObj:NumBundles = 0 then 
                        do:
                            put stream str-err unformatted
                                substitute ("Для алког. кода &1 не найден товар (не установлено соответствие)", v-alc-code)
                                skip.
                            l-error = yes .    
                            if p-num = "" and p-position = 0 then 
                            do:
                                find first tt-marks where tt-marks.mark = v-mark no-lock no-error.
                                if not available tt-marks then 
                                do:
                                    create tt-marks .
                                end.    
                                assign
                                    tt-marks.mark     = v-mark 
                                    tt-marks.new_     = true
                                    tt-marks.alc-code = v-alc-code . 
                            end.          
                        end.
                        else 
                        do:
          
                            find first tt-marks where tt-marks.mark = v-mark no-lock no-error.
                            if not available tt-marks then 
                            do:
                                create tt-marks .
                            end.    
                            assign
                                tt-marks.num                = p-num
                                tt-marks.gds-part-position_ = p-position 
                                tt-marks.mark               = v-mark 
                                tt-marks.new_               = true .
                            tt-marks.gds-code           = extGdsObj:GetExtGdsValue(1):GdsCode .
                            tt-marks.alc-code           = v-alc-code .
                            tt-marks.prod-full-name     = extGdsObj:GetExtGdsValue(1):FullNameProd .
                            tt-marks.impor-full-name    = extGdsObj:GetExtGdsValue(1):FullNameImpor .
                            .
                            v-gds-code = extGdsObj:GetExtGdsValue(1):GdsCode .
                            find first ub.goods where ub.goods.gds-code = v-gds-code no-lock no-error.
                            if available ub.goods then tt-marks.gds-name = ub.goods.gds-name .      
                            if extGdsObj:NumBundles > 1 then tt-marks.flag = yes .
                            if p-num = "" and p-position = 0 then 
                            do:
                
                                put stream str-alc unformatted
                                    substitute  ("Информация по марке: &1:", v-mark) skip .
                                do ii = 1 to extGdsObj:NumBundles:
                                    find first ub.goods where ub.goods.gds-code = v-gds-code no-lock no-error.
                                    if available ub.goods then v-gds-name = ub.goods.gds-name .
                                    put stream str-alc unformatted
                                        substitute  ("&1 &2 &3 &4 &5 &6 &7 &8 &9",extGdsObj:GetExtGdsValue(ii):AlcCode, extGdsObj:GetExtGdsValue(ii):GdsCode, v-gds-name, 
                                        extGdsObj:GetExtGdsValue(ii):CliRegIdProd, extGdsObj:GetExtGdsValue(ii):FullNameProd, extGdsObj:GetExtGdsValue(ii):INNProd,
                                        extGdsObj:GetExtGdsValue(ii):KPPProd, extGdsObj:GetExtGdsValue(ii):CountryProd, extGdsObj:GetExtGdsValue(ii):CliRegIdImpor).
                                    put stream str-alc unformatted
                                        substitute  ("&1 &2 &3 &4", extGdsObj:GetExtGdsValue(ii):FullNameImpor, extGdsObj:GetExtGdsValue(ii):INNImpor, extGdsObj:GetExtGdsValue(ii):KPPImpor, extGdsObj:GetExtGdsValue(ii):CountryImpor) skip .                                           
                                end.      
                            end.
                        end.    
                    end.
                end.
            end.
        END. 
        INPUT CLOSE. 
        output stream str-alc close.
        output stream str-err close.
    
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
            if p-num = "" and p-position = 0 then 
            do: 
                message substitute("Импорт акцизных марок завершен успешно и выгружены в &2.",v-proc-name-alc)
                    view-as alert-box.
            end.
            else 
            do:
                message substitute("Импорт акцизных марок завершен успешно.")
                    view-as alert-box.
            end.  
        end.  
        delete object extGdsObj no-error.
    END.
  
    else os-delete value(v-proc-name-err). /* Если нет - удаляем лог */
    run count-marks-parts no-error .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE count-marks-parts Dialog-Frame 
PROCEDURE count-marks-parts :
    /*------------------------------------------------------------------------------
      Purpose:
      Parameters:  <none>
      Notes:
    ------------------------------------------------------------------------------*/
    do
        on error undo, return error
        :
        DEFINE VARIABLE ii as INTEGER no-undo .
        open query br-marks for each tt-marks  where tt-marks.num = p-num and tt-marks.gds-part-position_ = p-position .
        ii = 0 .
        v-qnty-goods = p-qnty-goods .
        if p-alc-code <> "" then 
        do: 
            for each tt-marks where tt-marks.alc-code = p-alc-code :
                ii = ii + 1 .
            end.     
        end.
        else 
        do:
            for each tt-marks :
                ii = ii + 1 .
            end.
        end.    
        v-qnty-marks = ii .
        display
            v-qnty-marks
            v-qnty-goods
            with frame {&frame-name}.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME