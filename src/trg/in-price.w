&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME DIALOG-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS DIALOG-1
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Введение (подтверждение) учетных цен для партии при создании отрицательных партий

Автор: Чернова Светлана Александровна
Дата создания: 07/09/07
Author: Svetlana Chernova
Creation date: 07/09/07


Автор1: Перваков Михаил Сергеевич
Дата создания: 04/05/06

Вызов ручного режима создания партий

Между ценами и курсом должны выполняться соотношение:
   price-base = price-rubl * scale / rate
   rate       = price-rubl * scale / price-base
   price-rubl = price-base * rate  / scale

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input-output parameter p-price-base as decimal   no-undo .
define input-output parameter p-price-rubl as decimal   no-undo .
define output parameter p-action           as character no-undo .
define input  parameter p-obj-type         as character no-undo .
define input  parameter p-obj-code         as integer   no-undo .
define input  parameter p-artic            as character no-undo .
define input  parameter p-prod-type        as character no-undo .
define input  parameter p-prod-code        as integer   no-undo .
define input  parameter p-supp-type        as character no-undo .
define input  parameter p-supp-code        as integer   no-undo .
define input  parameter p-base-rate        as decimal   no-undo .
define input  parameter p-base-scale       as decimal   no-undo .
define input  parameter p-parts-qnty       as decimal   no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Введение учетных цен для партии".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ cmp/showinf.i  }

define variable v-base-code     as integer   no-undo .
define variable v-currency-rubl as character no-undo .
define variable v-currency-base as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME DIALOG-1

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-goods b-supp b-help RECT-1 ~
RECT-2 RECT-3 RECT-4 b-rate-from-price b-curr-rate fi-rate fi-scale ~
fi-price-rubl b-rubl-from-base fi-price-base b-base-from-rubl ~
fi-currency-base-2 fi-formula-2 fi-currency-rubl fi-currency-rubl-2 ~
fi-formula-1 fi-formula-3 fi-currency-rubl-3 fi-formula-4 fi-currency-base ~
fi-currency-base-3 fi-formula-5 fi-formula-6
&Scoped-Define DISPLAYED-OBJECTS name fi-obj need-qnty supp-name fi-rate ~
rate-mmvb fi-scale scale-mmvb fi-price-rubl fi-price-base ~
fi-currency-base-2 fi-formula-2 fi-currency-rubl fi-currency-rubl-2 ~
fi-formula-1 fi-formula-3 fi-currency-rubl-3 fi-formula-4 fi-currency-base ~
fi-currency-base-3 fi-formula-5 fi-formula-6

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-base-from-rubl
     LABEL "abbr_rub_firstshift --> Вал"
     SIZE 14 BY 1 TOOLTIP "Расчет базовой учетной цены (Вал) на основе abbr_rublevoy (abbr_rub_firstshift)".

DEFINE BUTTON b-chg AUTO-GO
     LABEL "&Изменить"
     SIZE 10 BY 1 TOOLTIP "Вручную создать партии (с указанием учетной цены каждой партии)".

DEFINE BUTTON b-curr-rate
     LABEL "Курс ММВБ"
     SIZE 14 BY 1 TOOLTIP "Получить текущий курс ММВБ".

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод "
     SIZE 10 BY 1 TOOLTIP "Создать партию с указанной учетной ценой".

DEFINE BUTTON b-goods
     LABEL "&Товар"
     SIZE 10 BY 1 TOOLTIP "Просмотр карточки товара".

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1 TOOLTIP "Помощь".

DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Отмена"
     SIZE 10 BY 1 TOOLTIP "Отказ от создания партий".

DEFINE BUTTON b-rate-from-price
     LABEL "Цены --> Курс"
     SIZE 15 BY 1 TOOLTIP "Вычисление курса на основании текущих учетных цен".

DEFINE BUTTON b-rubl-from-base
     LABEL "Вал --> abbr_rub_firstshift"
     SIZE 14 BY 1 TOOLTIP "Расчет abbr_rublevoy учетной цены (abbr_rub_firstshift) на основе базовой (Вал)".

DEFINE BUTTON b-supp
     LABEL "&Поставщик"
     SIZE 10 BY 1 TOOLTIP "Просмотр карточки поставщика".

DEFINE VARIABLE fi-currency-base AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 7.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-currency-base-2 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 7.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-currency-base-3 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 7.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-currency-rubl AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 7.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-currency-rubl-2 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 7.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-currency-rubl-3 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 7.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-formula-1 AS CHARACTER FORMAT "X(256)":U INITIAL "= ----------------"
      VIEW-AS TEXT
     SIZE 19 BY .67 NO-UNDO.

DEFINE VARIABLE fi-formula-2 AS CHARACTER FORMAT "X(256)":U INITIAL "* КУРС"
      VIEW-AS TEXT
     SIZE 7.5 BY .67 NO-UNDO.

DEFINE VARIABLE fi-formula-3 AS CHARACTER FORMAT "X(256)":U INITIAL "МАСШТАБ"
      VIEW-AS TEXT
     SIZE 8 BY .67 NO-UNDO.

DEFINE VARIABLE fi-formula-4 AS CHARACTER FORMAT "X(256)":U INITIAL "* МАСШТАБ"
      VIEW-AS TEXT
     SIZE 9.5 BY .67 NO-UNDO.

DEFINE VARIABLE fi-formula-5 AS CHARACTER FORMAT "X(256)":U INITIAL "= -------------------"
      VIEW-AS TEXT
     SIZE 22 BY .67 NO-UNDO.

DEFINE VARIABLE fi-formula-6 AS CHARACTER FORMAT "X(256)":U INITIAL "КУРС"
      VIEW-AS TEXT
     SIZE 5 BY .67 NO-UNDO.

DEFINE VARIABLE fi-obj AS CHARACTER FORMAT "X(40)"
     LABEL "Объект"
     VIEW-AS FILL-IN
     SIZE 76 BY 1
     FGCOLOR 4 .

DEFINE VARIABLE fi-price-base AS DECIMAL FORMAT ">>,>>>,>>9.9999999999" INITIAL 0
     LABEL "Цена"
     VIEW-AS FILL-IN
     SIZE 19 BY 1 TOOLTIP "Базовая учетная цена" NO-UNDO.

DEFINE VARIABLE fi-price-rubl AS DECIMAL FORMAT ">>,>>>,>>9.9999999999" INITIAL 0
     LABEL "Цена"
     VIEW-AS FILL-IN
     SIZE 19 BY 1 TOOLTIP "abbr_rublevaya_firstshift учетная цена" NO-UNDO.

DEFINE VARIABLE fi-rate AS DECIMAL FORMAT ">>,>>9.9999":U INITIAL 0
     LABEL "&Курс"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE fi-scale AS DECIMAL FORMAT ">,>>9.99":U INITIAL 0
     LABEL "&Масштаб"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE name AS CHARACTER FORMAT "X(40)"
     LABEL "Товар"
     VIEW-AS FILL-IN
     SIZE 76 BY 1
     FGCOLOR 4 .

DEFINE VARIABLE need-qnty AS DECIMAL FORMAT "->,>>>,>>>,>>9.999":U INITIAL 0
     LABEL "Количество"
     VIEW-AS FILL-IN
     SIZE 19 BY 1 TOOLTIP "Недостающее количество"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE rate-mmvb AS DECIMAL FORMAT ">>,>>9.9999":U INITIAL 0
     LABEL "Курс ММВБ"
     VIEW-AS FILL-IN
     SIZE 14 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE scale-mmvb AS DECIMAL FORMAT ">,>>9.99":U INITIAL 0
     LABEL "Масштаб"
     VIEW-AS FILL-IN
     SIZE 14 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE supp-name AS CHARACTER FORMAT "X(40)"
     LABEL "Поставщик"
     VIEW-AS FILL-IN
     SIZE 76 BY 1
     FGCOLOR 4 .

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 50.5 BY 3.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 50.5 BY 3.27.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 25.5 BY 4.5.

DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 27 BY 4.5.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DIALOG-1
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-chg AT ROW 1 COL 21
     b-goods AT ROW 1 COL 31
     b-supp AT ROW 1 COL 41
     b-help AT ROW 1 COL 51
     name AT ROW 2.33 COL 7.3
     fi-obj AT ROW 3.53 COL 6.3
     need-qnty AT ROW 4.77 COL 12.3 COLON-ALIGNED
     supp-name AT ROW 5.97 COL 3.3
     b-rate-from-price AT ROW 7.5 COL 51
     b-curr-rate AT ROW 7.5 COL 80
     fi-rate AT ROW 9 COL 50 COLON-ALIGNED
     rate-mmvb AT ROW 9 COL 78 COLON-ALIGNED
     fi-scale AT ROW 10.27 COL 50 COLON-ALIGNED
     scale-mmvb AT ROW 10.27 COL 78 COLON-ALIGNED
     fi-price-rubl AT ROW 13.27 COL 5 AUTO-RETURN
     b-rubl-from-base AT ROW 13.27 COL 44
     fi-price-base AT ROW 16.77 COL 9 COLON-ALIGNED
     b-base-from-rubl AT ROW 16.77 COL 44
     fi-currency-base-2 AT ROW 12.77 COL 68.5 COLON-ALIGNED NO-LABEL
     fi-formula-2 AT ROW 12.77 COL 77.5 COLON-ALIGNED NO-LABEL
     fi-currency-rubl AT ROW 13.5 COL 29.5 COLON-ALIGNED NO-LABEL
     fi-currency-rubl-2 AT ROW 13.5 COL 57.5 COLON-ALIGNED NO-LABEL
     fi-formula-1 AT ROW 13.5 COL 66 COLON-ALIGNED NO-LABEL
     fi-formula-3 AT ROW 14.27 COL 71.5 COLON-ALIGNED NO-LABEL
     fi-currency-rubl-3 AT ROW 16.27 COL 68.5 COLON-ALIGNED NO-LABEL
     fi-formula-4 AT ROW 16.27 COL 77.5 COLON-ALIGNED NO-LABEL
     fi-currency-base AT ROW 17 COL 29.5 COLON-ALIGNED NO-LABEL
     fi-currency-base-3 AT ROW 17 COL 58 COLON-ALIGNED NO-LABEL
     fi-formula-5 AT ROW 17 COL 66 COLON-ALIGNED NO-LABEL
     fi-formula-6 AT ROW 17.77 COL 72.5 COLON-ALIGNED NO-LABEL
     RECT-1 AT ROW 12.27 COL 41.5
     RECT-2 AT ROW 15.77 COL 41.5
     RECT-3 AT ROW 7.27 COL 41.5
     RECT-4 AT ROW 7.27 COL 68.5
     SPACE(2.37) SKIP(8.72)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Редактирование учётной цены":L
         DEFAULT-BUTTON b-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX DIALOG-1
                                                                        */
ASSIGN
       FRAME DIALOG-1:SCROLLABLE       = FALSE.

/* SETTINGS FOR BUTTON b-chg IN FRAME DIALOG-1
   NO-ENABLE                                                            */
ASSIGN
       b-chg:HIDDEN IN FRAME DIALOG-1           = TRUE.

/* SETTINGS FOR FILL-IN fi-obj IN FRAME DIALOG-1
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN fi-price-rubl IN FRAME DIALOG-1
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN name IN FRAME DIALOG-1
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN need-qnty IN FRAME DIALOG-1
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN rate-mmvb IN FRAME DIALOG-1
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN scale-mmvb IN FRAME DIALOG-1
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN supp-name IN FRAME DIALOG-1
   NO-ENABLE ALIGN-L                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME DIALOG-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL DIALOG-1 DIALOG-1
ON GO OF FRAME DIALOG-1 /* Редактирование учётной цены */
DO:
  define variable v-ok as logical   no-undo .

  if p-action = '':U
  then do:
    assign
      p-action = 'exit':U
    .
  end.

  if p-action = 'exit':U
  then do:
    if  fi-price-base :sensitive
    then do:
      if input frame {&frame-name} fi-price-base = ?
      then do:
        message
          substitute("Не задана цена (&1)"
                    ,fi-currency-base :screen-value
                    ) skip
          view-as alert-box error .
        apply 'entry':u to fi-price-base .
        return no-apply .
      end.

      if input frame {&frame-name} fi-price-base = 0
      then do:
        assign
          v-ok = false
        .
        message
          substitute("Задана нулевая цена (&1)"
                    ,fi-currency-base :screen-value
                    ) skip
          "Продолжить?" skip
          view-as alert-box question buttons yes-no update v-ok .
        if v-ok <> true
        then do:
          apply 'entry':u to fi-price-base .
          return no-apply .
        end.
      end.
    end.

    if fi-price-rubl :sensitive
    then do:
      if input frame {&frame-name} fi-price-rubl = ?
      then do:
        message
          substitute("Не задана учетная цена (&1)"
                    ,fi-currency-rubl :screen-value
                    ) skip
          view-as alert-box error .
        apply 'entry':u to fi-price-rubl .
        return no-apply .
      end.

      if input frame {&frame-name} fi-price-rubl = 0
      then do:
        assign
          v-ok = false
        .
        message
          substitute("Учетная цена (&1) равна нулю"
                    ,fi-currency-rubl :screen-value
                    ) skip
          "Партия будет сохранена с нулевой учётной ценой." skip
          "Продолжить?" skip
          view-as alert-box question buttons yes-no update v-ok .
        if v-ok <> true
        then do:
          apply 'entry':u to fi-price-rubl .
          return no-apply .
        end.
      end.
    end.

    assign
      p-price-base = input frame {&frame-name} fi-price-base
      p-price-rubl = input frame {&frame-name} fi-price-rubl
    .

    if v-base-code = 0
    then do:
      assign
        p-price-base = p-price-rubl
      .
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-base-from-rubl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-base-from-rubl DIALOG-1
ON CHOOSE OF b-base-from-rubl IN FRAME DIALOG-1 /* abbr_rub_firstshift --> Вал */
DO:
  { gbl/stdbtn.i }
  run calc-base-from-rubl .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg DIALOG-1
ON CHOOSE OF b-chg IN FRAME DIALOG-1 /* Изменить */
DO:
  { gbl/stdbtn.i }
  assign
    p-action = "chg"
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-curr-rate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-curr-rate DIALOG-1
ON CHOOSE OF b-curr-rate IN FRAME DIALOG-1 /* Курс ММВБ */
DO:
  { gbl/stdbtn.i }

  define variable v-host-code  as integer no-undo .
  define variable v-exch-rate  like ub.curr-accnt.exch-rate no-undo .
  define variable v-exch-scale like ub.curr-accnt.exch-scale no-undo .
  define variable v-today as date      no-undo.
  define variable v-time  as integer   no-undo.


  { gbl/hostcode.i
    p-obj-type
    p-obj-code
    v-host-code
  }
  run cur-time in this-procedure ( output v-today
                                 , output v-time
                                 ).

  { gbl/baserate.i
    v-host-code
    v-today
    v-exch-rate
    v-exch-scale
    no-error
  }

  assign
    fi-rate  :screen-value  = string(v-exch-rate
                                 , fi-rate :format)
    fi-scale :screen-value  = string(v-exch-scale
                                 , fi-scale :format)
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit DIALOG-1
ON CHOOSE OF b-exit IN FRAME DIALOG-1 /* Ввод  */
DO:
  { gbl/stdbtn.i }
  assign
    p-action = "exit"
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-goods DIALOG-1
ON CHOOSE OF b-goods IN FRAME DIALOG-1 /* Товар */
DO:
  { gbl/stdbtn.i }
  if available ub.goods
  then do:
    run str/showgds.p
      (input parparentproc
      ,input ? /*p-call-handle*/
      ,input ub.goods.gds-code /* p-gds-code */
      ,input {&lookup}         /* p-mode     */
      ).
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit DIALOG-1
ON CHOOSE OF b-quit IN FRAME DIALOG-1 /* Отмена */
DO:
  { gbl/stdbtn.i }
  assign
    p-action = "quit"
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-rate-from-price
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-rate-from-price DIALOG-1
ON CHOOSE OF b-rate-from-price IN FRAME DIALOG-1 /* Цены --> Курс */
DO:
  { gbl/stdbtn.i }
  run calc-rate-from-price .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-rubl-from-base
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-rubl-from-base DIALOG-1
ON CHOOSE OF b-rubl-from-base IN FRAME DIALOG-1 /* Вал --> abbr_rub_firstshift */
DO:
  { gbl/stdbtn.i }
  run calc-rubl-from-base .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-supp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-supp DIALOG-1
ON CHOOSE OF b-supp IN FRAME DIALOG-1 /* Поставщик */
DO:
  { gbl/stdbtn.i }
  run ref/showcli.p
    (input parparentproc
    ,input p-supp-type /* p-obj-type */
    ,input p-supp-code /* p-obj-code */
    ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-price-base
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-price-base DIALOG-1
ON RETURN OF fi-price-base IN FRAME DIALOG-1 /* Цена */
DO:
  run calc-rubl-from-base.
  apply "choose":u to b-exit in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-price-rubl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-price-rubl DIALOG-1
ON RETURN OF fi-price-rubl IN FRAME DIALOG-1 /* Цена */
DO:
  run calc-base-from-rubl.
  apply "choose":u to b-exit in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-rate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-rate DIALOG-1
ON RETURN OF fi-rate IN FRAME DIALOG-1 /* Курс */
DO:
  define variable v-curr-r-b as character no-undo .
  { gbl/curr-r-b.i
    v-curr-r-b
  }
  if v-curr-r-b = {&r-b-base}
  then do:
    run calc-rubl-from-base.
    apply "entry":u to b-exit in frame {&frame-name}.
    return no-apply.
  end.
  else do:
    run calc-base-from-rubl.
    apply "entry":u to b-exit in frame {&frame-name}.
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK DIALOG-1


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */

{ gbl/app_help.i }

MAIN-BLOCK:
DO
ON ERROR   UNDO MAIN-BLOCK, RETURN ERROR
ON END-KEY UNDO MAIN-BLOCK, RETURN ERROR
ON STOP    UNDO MAIN-BLOCK, RETURN ERROR
:
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.

  find first ub.goods no-lock
    where ub.goods.artic     = p-artic
      and ub.goods.prod-type = p-prod-type
      and ub.goods.prod-code = p-prod-code
    no-error .
  if not available goods
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден товар" skip
      "Артикул" p-artic p-prod-code p-prod-type skip
      view-as alert-box error .
    undo main-block, return error .
  end.

  find first clients no-lock
    where clients.obj-type = p-supp-type
      and clients.obj-code = p-supp-code
    no-error .
  if not available clients
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден контрагент" skip
      "Контрагент" p-supp-type p-supp-code skip
      view-as alert-box error .
    undo main-block, return error .
  end.

  define buffer buf_obj_clients for ub.clients .

  find first buf_obj_clients no-lock
    where buf_obj_clients.obj-type = p-obj-type
      and buf_obj_clients.obj-code = p-obj-code
      no-error .
  if not available buf_obj_clients
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден объект" skip
      "Контрагент" p-obj-type p-obj-code skip
      view-as alert-box error .
    undo main-block, return error .
  end.


  assign
    name      = substitute("&1 &2 &3 &4"
                     ,goods.artic
                     ,goods.prod-type
                     ,goods.prod-code
                     ,goods.gds-name
                     )
    fi-obj    = substitute("&1 &2 &3"
                     ,p-obj-type
                     ,p-obj-code
                     ,buf_obj_clients.obj-name
                     )
    supp-name = substitute("&1 &2 &3"
                      ,p-supp-type
                      ,p-supp-code
                      ,clients.obj-name
                      )
    need-qnty = p-parts-qnty
  .

  assign
    fi-price-base = p-price-base
    fi-price-rubl = p-price-rubl
  .

  define variable v-host-code  as integer no-undo .
  define variable v-exch-rate  like ub.curr-accnt.exch-rate no-undo .
  define variable v-exch-scale like ub.curr-accnt.exch-scale no-undo .

  { gbl/hostcode.i
    p-obj-type
    p-obj-code
    v-host-code
  }

  { gbl/basecode.i
    v-host-code
    v-base-code
  }
  run cur-time in this-procedure
    (output  v-today
    ,output  v-time
    ).
  { gbl/baserate.i
    v-host-code
    v-today
    v-exch-rate
    v-exch-scale
    no-error
  }
  assign
    rate-mmvb  = v-exch-rate
    scale-mmvb = v-exch-scale
  .
  if  p-base-rate > 0
  and p-base-scale > 0
  then do:
    assign
      fi-rate  = p-base-rate
      fi-scale = p-base-scale
    .
  end.
  else do:
    assign
      fi-rate  = v-exch-rate
      fi-scale = v-exch-scale
    .
  end.

  define buffer buf_currency for ub.currency .
  find first buf_currency no-lock
    where buf_currency.curr-code = v-base-code
    no-error .
  if available buf_currency
  then do:
    assign
      v-currency-base = buf_currency.curr-abbr
    .
  end.
  else do:
    assign
      v-currency-base = "ВАЛ"
    .
  end.

  /* ищем название р_у_блевой валюты */
  find first buf_currency no-lock
    where buf_currency.curr-code = 0
    .
  assign
    v-currency-rubl = buf_currency.curr-abbr
  .

  assign
    fi-currency-base   = v-currency-base
    fi-currency-base-2 = v-currency-base
    fi-currency-base-3 = v-currency-base
    fi-currency-rubl   = v-currency-rubl
    fi-currency-rubl-2 = v-currency-rubl
    fi-currency-rubl-3 = v-currency-rubl
    b-rubl-from-base :label =  v-currency-base + " --> " + v-currency-rubl
    b-base-from-rubl :label =  v-currency-rubl + " --> " + v-currency-base
  .

  if fi-price-rubl > 0
  and fi-scale >0
  and fi-price-base > 0
  then do:
    /* calc-rate-from-price */
    assign
      fi-rate = fi-price-rubl * fi-scale / fi-price-base
    .
  end.
  assign
  b-base-from-rubl:LABEL in frame {&frame-name} = "{&abbr_rub_firstshift} --> Вал"
  b-base-from-rubl:TOOLTIP in frame {&frame-name}  = "Расчет базовой учетной цены (Вал) на основе {&abbr_rublevoy} ({&abbr_rub_firstshift})"
  b-rubl-from-base:label in frame {&frame-name}  = "Вал --> {&abbr_rub_firstshift}"
  b-rubl-from-base:TOOLTIP in frame {&frame-name} = "Расчет {&abbr_rublevoy} учетной цены ({&abbr_rub_firstshift}) на основе базовой (Вал)"
  fi-price-rubl:TOOLTIP in frame {&frame-name}  = "{&abbr_rublevaya_firstshift} учетная цена"
  .


  RUN enable_UI.

  if v-base-code = 0
  then do:
    assign
      fi-price-base      :sensitive = false
      fi-scale           :sensitive = false
      fi-rate            :sensitive = false
      b-curr-rate        :sensitive = false
      b-rate-from-price  :sensitive = false
      b-base-from-rubl   :sensitive = false
      b-rubl-from-base   :sensitive = false
      rate-mmvb          :sensitive = false
      scale-mmvb         :sensitive = false
      fi-currency-base   :sensitive = false
      fi-currency-base-2 :sensitive = false
      fi-currency-base-3 :sensitive = false
      fi-currency-rubl-2 :sensitive = false
      fi-currency-rubl-3 :sensitive = false
      rect-1             :sensitive = false
      rect-2             :sensitive = false
      fi-formula-1       :sensitive = false
      fi-formula-2       :sensitive = false
      fi-formula-3       :sensitive = false
      fi-formula-4       :sensitive = false
      fi-formula-5       :sensitive = false
      fi-formula-6       :sensitive = false
    .
    assign
      fi-price-base      :visible = false
      fi-scale           :visible = false
      fi-rate            :visible = false
      b-curr-rate        :visible = false
      b-rate-from-price  :visible = false
      b-base-from-rubl   :visible = false
      b-rubl-from-base   :visible = false
      rate-mmvb          :visible = false
      scale-mmvb         :visible = false
      fi-currency-base   :visible = false
      fi-currency-base-2 :visible = false
      fi-currency-base-3 :visible = false
      fi-currency-rubl-2 :visible = false
      fi-currency-rubl-3 :visible = false
      rect-1             :visible = false
      rect-2             :visible = false
      fi-formula-1       :visible = false
      fi-formula-2       :visible = false
      fi-formula-3       :visible = false
      fi-formula-4       :visible = false
      fi-formula-5       :visible = false
      fi-formula-6       :visible = false
    .
  end.

  if fi-price-base :sensitive
  then do:
    define variable v-curr-r-b as character no-undo .
    { gbl/curr-r-b.i
      v-curr-r-b
    }
    if v-curr-r-b = {&r-b-base}
    then do:
      apply "entry":u to fi-price-base in frame {&frame-name}.
    end.
    else do:
      apply "entry":u to fi-price-rubl in frame {&frame-name}.
    end.
  end.
  else do:
    apply "entry":u to fi-price-rubl in frame {&frame-name}.
  end.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.

RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calc-base-from-rubl DIALOG-1
PROCEDURE calc-base-from-rubl :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  run validate-not-zero
    (input 'scale':u
    ).
  if return-value = 'false':u
  then do:
    return 'false':u .
  end.

  do with frame {&frame-name}:
    assign
      fi-price-base :screen-value = string(input fi-price-rubl * input fi-scale / input fi-rate)
    .
  end. /* do with frame */



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calc-rate-from-price DIALOG-1
PROCEDURE calc-rate-from-price :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  run validate-not-zero
    (input 'price-base':u
    ).
  if return-value = 'false':u
  then do:
    return 'false':u .
  end.

  do with frame {&frame-name}:
    assign
      fi-rate :screen-value = string( input fi-price-rubl * input fi-scale / input fi-price-base)
    .
  end. /* do with frame */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calc-rubl-from-base DIALOG-1
PROCEDURE calc-rubl-from-base :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  run validate-not-zero
    (input 'scale':u
    ).
  if return-value = 'false':u
  then do:
    return 'false':u .
  end.

  do with frame {&frame-name}:
    assign
      fi-price-rubl :screen-value = string(input fi-price-base * input fi-rate  / input fi-scale)
    .
  end. /* do with frame */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI DIALOG-1  _DEFAULT-DISABLE
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
  HIDE FRAME DIALOG-1.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI DIALOG-1  _DEFAULT-ENABLE
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
  DISPLAY name fi-obj need-qnty supp-name fi-rate rate-mmvb fi-scale scale-mmvb
          fi-price-rubl fi-price-base fi-currency-base-2 fi-formula-2
          fi-currency-rubl fi-currency-rubl-2 fi-formula-1 fi-formula-3
          fi-currency-rubl-3 fi-formula-4 fi-currency-base fi-currency-base-3
          fi-formula-5 fi-formula-6
      WITH FRAME DIALOG-1.
  ENABLE b-exit b-quit b-goods b-supp b-help RECT-1 RECT-2 RECT-3 RECT-4
         b-rate-from-price b-curr-rate fi-rate fi-scale fi-price-rubl
         b-rubl-from-base fi-price-base b-base-from-rubl fi-currency-base-2
         fi-formula-2 fi-currency-rubl fi-currency-rubl-2 fi-formula-1
         fi-formula-3 fi-currency-rubl-3 fi-formula-4 fi-currency-base
         fi-currency-base-3 fi-formula-5 fi-formula-6
      WITH FRAME DIALOG-1.
  {&OPEN-BROWSERS-IN-QUERY-DIALOG-1}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE validate-not-zero DIALOG-1
PROCEDURE validate-not-zero :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  /* проверяем, что величины на основании которых мы вычисляем */
  /* определены */
  define input parameter p-need-check as character no-undo .

  do with frame {&frame-name} :
    case p-need-check
    :
      when 'rate':u
      then do:
        if input fi-rate = 0
        or input fi-rate = ?
        then do:
          message
            "Задайте" fi-rate:label
            view-as alert-box .
          apply "entry":u to fi-rate.
          return 'false':u .
        end.
      end.
      when 'price-base':u
      then do:
        if input fi-price-base = 0
        or input fi-price-base = ?
        then do:
          message
            "Задайте базовую учетную цену"
            view-as alert-box .
          apply "entry":u to fi-price-base.
          return 'false':u .
        end.
      end.
      when 'price-rubl':u
      then do:
        if input fi-price-rubl = 0
        or input fi-price-rubl = ?
        then do:
          message
            "Задайте учетную цену в {&abbr_rublyah}"
            view-as alert-box .
          apply "entry":u to fi-price-rubl.
          return 'false':u .
        end.
      end.
      when 'scale':u
      then do:
        if input fi-scale = 0
        or input fi-scale = ?
        then do:
          message
            "Задайте базовую учетную цену"
            view-as alert-box .
          apply 'entry':u to fi-scale.
          return 'false':u .
        end.
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Процедура validate-not-zero. Неизвестный параметр " skip
          "p-need-check" p-need-check skip
          view-as alert-box error .
        undo, return error .
      end.
    end case.

  end. /* do with frame */


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME