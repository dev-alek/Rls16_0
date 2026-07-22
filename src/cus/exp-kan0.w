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

Экспорт результатов продаж    Заказчика "Кан-Ру"

Автор: Румянцев Юрий Александрович
Дата создания: 04/12/06
Author: Yuri Rumyantsev
Creation date: 04/12/06

Формат экспорта:
R01;001;1111;2003-01-28;13:20:00;23.028-10-008-0128;1;974.7;20;5;74.7

Описание приведенных полей:
1  - номер магазина, осуществляющего продажи c префиксом R;
2  - номер кассы, на которой пробит чек
3  - номер кассира
4  - номер чека по кассе
5  - дата пробития чека в формате ГГГГ-ММ-ДД
6  - время пробития чека в формате ЧЧ:ММ:СС
7  - артикул товара-цвет-размер  (цвет-размер - товар шкальный, шкала 2-х мерная)
8  - количество
9  - продажная цена единицы товара без учета скидки, но включающая налоги НДС и НсП.
10  - ставка НДС в %
11 - ставка НсП в %
12 - сумма скидки на единицу товара
13 - тип оплаты (наличные/кредиткой/смешанный)
14 - номер карты клиента

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .

/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Экспорт результатов продаж".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ cus/exp-kan-mapobj.i }

define stream txt.
define variable v_os-file as char no-undo.
define variable prt-name as char no-undo.
define variable t1 as char no-undo.
define variable nal as logical no-undo.
define variable beznal as logical no-undo.
define variable ToP as char no-undo.
define variable dcrd as char no-undo.
define variable v-obj as character no-undo.

define variable VAT-p like ub.tax-rate-value.rate-value no-undo .
define variable SLT-p like ub.tax-rate-value.rate-value no-undo .


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS date-beg date-End file-name B-file Btn_OK ~
Btn_Cancel
&Scoped-Define DISPLAYED-OBJECTS date-beg date-End file-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-file
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "Cancel"
     SIZE 15 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "OK"
     SIZE 15 BY 1.13
     BGCOLOR 8 .

DEFINE VARIABLE date-beg AS DATE FORMAT "99/99/9999":U
     LABEL "Даты С"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE date-End AS DATE FORMAT "99/99/9999":U
     LABEL "По"
     VIEW-AS FILL-IN
     SIZE 11.5 BY 1 NO-UNDO.

DEFINE VARIABLE file-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Файл"
     VIEW-AS FILL-IN
     SIZE 39 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     date-beg AT ROW 1.5 COL 9 COLON-ALIGNED
     date-End AT ROW 1.5 COL 28.5 COLON-ALIGNED
     file-name AT ROW 3 COL 1.5
     B-file AT ROW 3 COL 47
     Btn_OK AT ROW 4.5 COL 9.5
     Btn_Cancel AT ROW 4.5 COL 29
     SPACE(6.12) SKIP(0.28)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Экспорт чеков в файл"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN file-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Экспорт чеков в файл */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-file
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-file Dialog-Frame
ON CHOOSE OF B-file IN FRAME Dialog-Frame
DO:

    DEF VAR ll_commit AS LOG    NO-UNDO INIT NO.

    SYSTEM-DIALOG GET-FILE v_os-file
        TITLE "Выберите файл для экспорта"
        FILTERS
          " Текстовые файлы (*.txt) " "*.txt",
          " Все файлы (*.*) "                      "*.*"
        ask-overwrite
        save-as
        use-filename
        update ll_commit
        default-extension "txt"
        .
    IF ll_commit <> YES THEN do:
       RETURN NO-APPLY.
    end.
    IF v_os-file = PROGRAM-NAME( 1 ) THEN DO:
        BELL.
        MESSAGE "Рекурсия!" VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.
    ASSIGN file-name = ( IF SEARCH( v_os-file ) = ? THEN v_os-file ELSE SEARCH( v_os-file ) ).
    DISP file-name WITH FRAME {&FRAME-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame /* OK */
DO:
  assign
        date-beg
        date-end
        .

  if date-beg > date-end then do:
         message "Дата начала периода должна быть меньше даты конца". pause.
  end.
  else if date-beg = ? then do:
         message "Не задана дата C". pause  .
  end.
  else if date-end = ? then do:
         message "Не задана дата По". pause.
  end.
  else do:
        if trim(v_os-file) = "" then do:
             message "Не задан файл для экспорта". pause.
        end.
        else do:
              output stream txt to value (v_os-file) no-echo.

              put stream txt  unformatted
                 "SHOP ID; CASH REGISTER ID; CASSIER ID; ID NUMBER OF DOCUMENT; DATE; TIME; INDEX-COLOR-SIZE; QUANTITY; PRICE WITHOUT DISCOUNT OF ONE ITEM; VAT IN %; SALES IN %; AMOUNT OF DISCOUNT OF ONE ITEM; TYPE OF PAYMENT; FIDELITY CARD NUMBER"
              skip.
              _chk-doc:
              FOR EACH chk-doc NO-LOCK where
                     chk-doc.obj-type = v-cntxt-obj-type  and
                     chk-doc.obj-code = v-cntxt-obj-code  and
                     chk-doc.chk-date >= date-beg   and
                     chk-doc.chk-date <= date-end
                   by chk-doc.chk-date
                   by chk-doc.chk-time
                   by chk-doc.pay-desk
                   :
                   if lookup(string(chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-doc.
                   display
                            chk-doc.doc-code
                            chk-doc.chk-date
                         with frame ff view-as dialog-box
                         title ": Экспорт чеков в файл".
                   pause 0.

                   find first mapobj no-lock where mapobj.obj-type = chk-doc.obj-type
                                               and mapobj.obj-code = chk-doc.obj-code no-error.
                   if available mapobj then v-obj = mapobj.kan-code.
                   else v-obj = 'R' + string(chk-doc.obj-code, "99").

                   assign
                      nal = FALSE
                      beznal = FALSE
                      .
                   for each chk-pay no-lock where
                                  chk-pay.doc-code = chk-doc.doc-code:
                          if chk-pay.pay-code = 1 then    nal = TRUE.
                          else  beznal = TRUE.
/*                        FIND FIRST cash-pay where
                                          cash-pay.cdpay-code = chk-pay.pay-code no-lock.
                        FIND FIRST sysconf where
                                          sysconf.host-code = v-cntxt-host-code-obj no-lock.
                        if sysconf.cash-pay = cash-pay.pay-code then nal = TRUE.
                        else beznal = TRUE. */
                   end.   /*  for each chk-pay no-lock where  */

                   if nal and beznal then ToP = "MX".
                   else if nal then ToP = "GO".
                   else if beznal then ToP = "KK".

                   for each chk-gds no-lock where
                                chk-gds.doc-code = chk-doc.doc-code and
                                chk-gds.doc-qnty <> 0 ,
                        FIRST bar-code No-LOCK WHERE
                                  bar-code.b-code = chk-gds.b-code :

                        FIND FIRSt goods WHERE
                                        goods.gds-code = bar-code.gds-code NO-LOCK.
                        FIND FIRST gds-prt WHERE
                                          gds-prt.node-code = bar-code.node-code NO-LOCK.
                        assign
                            vat-p = ?
                            SLT-p = ?
                            .

                        { gbl/pftxvalg.i goods.gds-code {&vat-tax-code} ? v-cntxt-host-code-obj v-cntxt-obj-type v-cntxt-obj-code vat-p no-error }
                        { gbl/pftxvalg.i goods.gds-code {&slt-tax-code} ? v-cntxt-host-code-obj v-cntxt-obj-type v-cntxt-obj-code slt-p no-error }

                        prt-name =( if gds-prt.node-name = {&empty-scale} then "-"
                                           else ( if gds-prt.upper-code = goods.prt-root
                                                       then "-------------------" else gds-prt.f-name ) ) .
                        t1  = "-".

                        if r-index(prt-name, "/") > 0 then overlay ( prt-name, r-index(prt-name, "/"), 1) = t1.

                        if chk-doc.d-card = ? or chk-doc.d-card = "" then dcrd = "0".
                        else dcrd = chk-doc.d-card.

                        put stream txt  unformatted
                               trim(string(v-obj)) + ";" +
                               trim(string(chk-doc.pay-desk,">999"))  + ";" +
                               trim(string(chk-doc.cashier,">999"))  + ";" +
                               trim(string(chk-doc.chk-num)) + ";" +
                               trim(string(year(chk-doc.chk-date), "9999")) + "-" +
                               trim(string(month(chk-doc.chk-date), "99")) + "-" +
                               trim(string(DAY(chk-doc.chk-date), "99")) + ";" +
                               trim(string(chk-doc.chk-time, "HH:MM:SS")) + ";" +
                               trim(string(goods.artic)) + "-" +
                               trim(string(prt-name)) + ";" +
                               trim(string(chk-gds.doc-qnty)) + ";" +
                               trim(string(chk-gds.price-base)) + ";" +
                               trim(string(vat-p)) + ";" +
                               trim(string(slt-p)) + ";" +
                               trim(string(chk-gds.discnt)) + ";" +
                               trim(string(ToP)) + ";" +
                               trim(string(dcrd))
                        skip.
                   end.   /*  for each chk-gds no-lock where   */
              end.  /*  for each chk-doc no-lock where  */
              output close.
              message "Экспорт в файл закончен.".

        end.
  end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME file-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL file-name Dialog-Frame
ON LEAVE OF file-name IN FRAME Dialog-Frame /* Файл */
DO:
    ASSIGN file-name.
    IF SEARCH( file-name ) <> ? AND SEARCH( file-name ) <> "":U THEN DO:
        ASSIGN FILE-INFO:FILE-NAME = file-name.
        IF FILE-INFO:FULL-PATHNAME <> ? THEN ASSIGN file-name = FILE-INFO:FULL-PATHNAME.

        DISP file-name WITH FRAME {&FRAME-NAME}.
    END.
    APPLY "TAB":U TO file-name IN FRAME {&FRAME-NAME}.
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
  { gbl/getcntxt.i get }
  if v-cntxt-obj-type <> {&shop} then do:
    message "Текущий объект не МАГАЗИН!"
    view-as alert-box ERROR.
    BELL.
    return error.
  end.
  date-beg = today.
  date-end = today.
  assign
  date-beg
  date-end.

  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame _DEFAULT-DISABLE
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame _DEFAULT-ENABLE
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
  DISPLAY date-beg date-End file-name
      WITH FRAME Dialog-Frame.
  ENABLE date-beg date-End file-name B-file Btn_OK Btn_Cancel
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME