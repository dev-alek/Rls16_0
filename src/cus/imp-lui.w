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

Импорт карточек товара, строк в прих. документ и переоценку из файла EXCEL,
  для Луивуиттона
Привязывается к группе "test", шкале - "_Пустая шкала", производителю - орг 4
страна - Франци

Автор: Хныкин Павел Андреевич
Дата создания: 06/19/07
Author: Pavel Khnykin
Creation date: 06/19/07

Автор1: Румянцев Юрий Александрович
Дата создания: 08/09/05

*/

define input  parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Импорт из текстового файла".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

{ trg/new-bcod.i }
{ str/tt-tax.i "new shared" tt-tax full }
define new shared buffer buf_goods for ub.goods.
/*define variable parparentproc as widget-handle no-undo .*/
{ gbl/getcntxt.i def }
{ ref/grplibfn.i }



/*------------------------------------------------------------------------

  File:

  Description:

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author:

  Created:
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

define buffer buf_bar-code  for ub.bar-code.
define buffer buf_price-doc for ub.price-doc.
define buffer buf_sys-ctrl  for ub.sys-ctrl.
define buffer buf_gds-prt   for ub.gds-prt.
define buffer buf_gds-grp   for ub.gds-grp.
define buffer buf_clients   for ub.clients.

def var v_os-file as char no-undo.
define variable v-ok AS LOG NO-UNDO.

DEFINE VARIABLE chExcelApplication AS COM-HANDLE no-undo .
define variable chWorkBook   as com-handle no-undo .
define variable chWorkSheet  as com-handle no-undo .
define variable ch-range   as com-handle no-undo .
define variable Cell AS CHAR NO-UNDO.

DEF VAR i-LINE AS INT NO-UNDO.
define variable I-Artic AS CHAR NO-UNDO. /* Калонка 1 - Артикул*/
define variable I-Name AS CHAR NO-UNDO.  /* Калонка 6 - Наименование*/
define variable I-Vol AS CHAR NO-UNDO.    /* Калонка 3 - кол-во */
define variable I-Prix AS CHAR NO-UNDO.    /* Калонка 4 - Цена - прихода */
define variable I-Price AS CHAR NO-UNDO.    /* Калонка 5 - Цена - продажи */
define variable I-Eng-Name AS CHAR NO-UNDO.  /* Калонка 2 - Наименование*/
define variable Var-Dec AS DEC NO-UNDO.

DEFINE var i-grp-code AS integer NO-UNDO.

DEFINE var i-grp-name as char INIT "test"  no-undo.
DEFINE var i-scale as char INIT "_Пустая шкала" no-undo.
DEFINE var i-Cli-type as char INIT "орг"  no-undo.
DEFINE var i-Cli-code as INTEGER INIT 4  no-undo.
DEFINE var i-city as CHAR INIT "FR" no-undo.

define variable v-host-code  as integer  no-undo.
define variable v-recid  as RECID  no-undo.
DEFINE var j-gds-code like ub.goods.gds-code NO-UNDO.

DEFINE var impc-save AS INT NO-UNDO.
define variable impc-update as integer no-undo .
def stream err.

def var i-doc-num       like   ub.price-doc.doc-num no-undo .
DEF VAR loc-ref-list      as    char no-undo .

define variable v-log as logical   no-undo .

define variable f-name     as character no-undo .
def stream txt-temp.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS file-name B-file Tumbler Btn_OK Btn_Cancel
&Scoped-Define DISPLAYED-OBJECTS file-name Tumbler

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
     LABEL "Выход"
     SIZE 15 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK
     LABEL "Выполнить"
     SIZE 15 BY 1.13
     BGCOLOR 8 .

DEFINE VARIABLE file-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Файл для импорта"
     VIEW-AS FILL-IN
     SIZE 52.5 BY 1 NO-UNDO.

DEFINE VARIABLE Tumbler AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "В справочник товаров", 1,
"В документ переоценки", 2,
"В файл для последующей загрузки в приходный документ", 3
     SIZE 56 BY 2 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     file-name AT ROW 2.25 COL 1
     B-file AT ROW 2.25 COL 71.5
     Tumbler AT ROW 5 COL 15 NO-LABEL
     Btn_OK AT ROW 7.25 COL 16
     Btn_Cancel AT ROW 7.25 COL 41
     "              Куда будем импортировать данные из файла" VIEW-AS TEXT
          SIZE 73.5 BY 1 AT ROW 3.5 COL 1
          BGCOLOR 8
     "          Укажите файл из которого необходимо произвести импорт" VIEW-AS TEXT
          SIZE 73.5 BY .67 AT ROW 1.25 COL 1
          BGCOLOR 8
     SPACE(0.24) SKIP(6.74)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Импорт из текстового файла"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

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
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Импорт из текстового файла */
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
        TITLE "Выберите файл для импорта"
              FILTERS "Excel (*.xls)" "*.xls"
              MUST-EXIST
              USE-FILENAME
        update ll_commit
        default-extension "xls"
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
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame /* Выполнить */
DO:
    assign
        Tumbler.

    if  trim(file-name) = "" then do:
            message "Не задан файл для импорта "
            view-as alert-box ERROR.
            return no-apply.
    end.

    /**  Открытие Excel  **/
    create "Excel.Application" chExcelApplication no-error.
    if error-status :error then do:
        message
        "Ошибка при запуске Excel" skip
        error-status :get-message(1) skip
        view-as alert-box error .
        return no-apply .
    end.    
    assign
       chExcelApplication:interactive = false
       chExcelApplication:ScreenUpdating = FALSE
       chExcelApplication:visible = FALSE
       i-line       = 0
       impc-save    = 0
       impc-update  = 0
     .
    chWorkBook   = chExcelApplication:WorkBooks:open( file-name ).
    chWorkSheet  = chExcelApplication:Sheets:item (1).

/*    { gbl/hostcode.i*/
/*         v-cntxt-obj-type*/
/*         v-cntxt-obj-code*/
/*         v-host-code*/
/*    }*/


    if Tumbler = 2  THEN do:  /* В переоценку  */
        /* выбираем переоценку */
        run str/pr-docs.w (input parparentproc
                    ,input "b-sel":U
                    ,input {&work}
                    ,input {&g___new}
                    ,input v-cntxt-obj-type
                    ,input v-cntxt-obj-code
                    ,input ""
                    ,output loc-ref-list).


        if loc-ref-list  = '':U
        or loc-ref-list  = ?
        then do:
          message
            "Переоценка не выбрана."
          view-as alert-box error.
          return .
        end.
        find buf_price-doc no-lock
          where recid (buf_price-doc) = integer(entry(1, loc-ref-list))
        no-error .
        if not available buf_price-doc then do:
          message
            substitute("Переоценка с recid &1 не найдена", integer(entry(1, loc-ref-list)))
          view-as alert-box .
          return .
        end.
        if buf_price-doc.status_ <> {&g___new} then do:
          message
            "Статус переоценки должен быть 'новый'."
          view-as alert-box error.
          return .
        end.
        i-doc-num = buf_price-doc.doc-num.
    END.  /* if Tumbler = 2  THEN do:  */
    ELSE if Tumbler = 3  THEN do:  /* В приходный документ  */
        system-dialog get-file f-name
            TITLE "Экспорт в файл для последующей загрузки в приходный документ"
          filters "Файл для экспорта (*.adb) " "*.adb"
          ask-overwrite
          save-as
          use-filename
          update v-log
          default-extension "adb".

        if not v-log then return.

    END. /* ELSE if Tumbler = 3  THEN do:  */
    repeat:
        i-line = i-line + 1.

        I-Artic   = (chWorkSheet:range ("A" + string(i-LINE)):value) no-error.
        I-Eng-Name = (chWorkSheet:range ("B" + string(i-LINE)):value) no-error.
        I-Vol     = (chWorkSheet:range ("C" + string(i-LINE)):value) no-error.
        I-Prix    = (chWorkSheet:range ("D" + string(i-LINE)):value) no-error.
        I-Price   = (chWorkSheet:range ("E" + string(i-LINE)):value) no-error.
        I-Name    = (chWorkSheet:range ("F" + string(i-LINE)):value) no-error.

        if error-status :error then message "Не верно задана строка " i-LINE  view-as alert-box information .

        IF I-Artic = "AARCOD" THEN DO:
            NEXT.
        END.

        IF DEC (I-Vol) = ? THEN do:
            i-line = i-line - 1.
            LEAVE.
        END.

        display
                 i-line       label "Работаю со строкой":U
                 impc-save    label "Сохранено":U
                 impc-update  label "Изменено":U
           with frame ff view-as dialog-box
        title ": Импорт из файла".
        pause 0.

        IF TRIM(i-artic) = "" THEN DO:
            OUTPUT stream Err TO value ("Imp_Lui.err") append.
            put stream Err unformatted
                string(today, "99/99/9999") " "
                string(time, "HH:MM")
                " Строка - " i-line " - ячейка АРТИКУЛ (A) не должна быть пустой" skip .
            output stream Err close.
            next.
        END.

        IF TRIM(I-Name) = "" THEN DO:
            OUTPUT stream Err TO value ("Imp_Lui.err") append.
            put stream Err unformatted
                string(today, "99/99/9999") " "
                string(time, "HH:MM")
                " Строка - " i-line " - ячейка НАИМЕНОВАНИЕ (F) не должна быть пустой" skip .
            output stream Err close.
            next.
        END.

        find buf_goods where
             buf_goods.artic = i-artic and
             buf_goods.prod-type = i-cli-type and
             buf_goods.prod-code = i-cli-code
        no-lock no-error.
        if not available buf_goods then do:   /*  Нет такого товара */
            if Tumbler = 1 then do:  /* В справочник товаров  */
                  run proc-imp-goods in this-procedure ( input {&add-def} , input ? ).
            end.
            if Tumbler = 2 OR Tumbler = 3 then DO:
                OUTPUT stream Err TO value ("Imp_Lui.err") append.
                put stream ERR UNFORMATTED
                    string(today, "99/99/9999") " "
                    string(time, "HH:MM")
                    " Строка - " i-line " - товар отсутствует в БД, пропускаем" skip.
                output stream Err close.
                NEXT.
            END.
        END.
        ELSE DO: /* товар есть */
            if Tumbler = 1 then DO:
              run proc-imp-goods in this-procedure ( input {&update} , input buf_goods.gds-code ).
              assign
                impc-update = impc-update + 1
              .
            END.
        END.

        if Tumbler = 2  THEN do:  /* В переоценку  */
              Var-Dec = DEC (I-Price) NO-ERROR.
              IF ERROR-STATUS:ERROR OR Var-Dec <= 0 THEN DO:
                  OUTPUT stream Err TO value ("Imp_Lui.err") append.
                  put stream Err unformatted
                      string(today, "99/99/9999") " "
                      string(time, "HH:MM")
                      " Строка - " i-line " - в ячейке ЦЕНА (E) стоит что-то не перевариваемое" skip .
                  output stream Err close.
                  next.
              END.

              find first buf_bar-code no-lock
                where buf_bar-code.gds-code = buf_goods.gds-code
              no-error .
              if not available buf_bar-code
              then do:
                 OUTPUT stream Err TO value ("Imp_Lui.err") append.
                 put stream Err unformatted
                     string(today, "99/99/9999") " "
                     string(time, "HH:MM")
                     " Строка - " i-line " - У товара нет собственного Бар-Кода" skip .
                 output stream Err close.
                 next.
              end.  /* if not avail bar-code then do:  */

              run proc-imp-price .
        end.
        ELSE if Tumbler = 3 THEN do:  /* В файл для прихода  */
             Var-Dec = DEC (I-Vol) NO-ERROR.
             IF ERROR-STATUS:ERROR OR Var-Dec <= 0 THEN DO:
                OUTPUT stream Err TO value ("Imp_Lui.err") append.
                put stream Err unformatted
                    string(today, "99/99/9999") " "
                    string(time, "HH:MM")
                    " Строка - " i-line " - в ячейке КОЛИЧЕСТВО (C) стоит что-то не перевариваемое" skip .
                output stream Err close.
                next.
             END.
             Var-Dec = DEC (I-Prix) NO-ERROR.
             IF ERROR-STATUS:ERROR OR Var-Dec <= 0 THEN DO:
                OUTPUT stream Err TO value ("Imp_Lui.err") append.
                put stream Err unformatted
                    string(today, "99/99/9999") " "
                    string(time, "HH:MM")
                    " Строка - " i-line " - в ячейке ЦЕНА ПРИХОДА (D) стоит что-то не перевариваемое" skip .
                output stream Err close.
                next.
             END.

             OUTPUT stream txt-temp TO value (f-name) append.
                 put stream txt-temp  unformatted
                     "ITEM:" +
                      buf_goods.artic + ";" +
                      trim(string(buf_goods.prod-code)) + ";;;;" +
                      trim(string(I-Prix)) + ";" +
                      trim(string(I-Vol)) + ";;;;;;;;;" SKIP.

             output stream txt-temp close.
             impc-save = impc-save + 1.

        end.

    END. /* repeat  */
    OUTPUT stream err close.

    /**  Закрытие Excel  **/
    release object chWorkSheet   no-error .
    RELEASE object chWorkBook   no-error .

    assign
       v-ok = chExcelApplication:Quit() no-error
     .
    release object chExcelApplication   no-error .

    message ("Импорт из файла " + file-name + " закончен" + {&new-line} + "прочитано " + string(i-line) +
             ",  сохранено " + string(impc-save) + ", из них изменено " + string(impc-update) + '.' +
             {&new-line} + " Все ошибки выведены в файл - Imp_Lui.err" )
    view-as alert-box  INFORMATION.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME file-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL file-name Dialog-Frame
ON LEAVE OF file-name IN FRAME Dialog-Frame /* Файл для импорта */
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

/* no app_help.i */

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

   message  "Импорт из Excel данных по товарам." skip
           "При импорте используется работа с Excel, поэтому не прерывайте работу Excel и не нарушайте уже установленную связь!"
           skip "Продолжать ?"
           view-as alert-box question buttons ok-cancel update v-ok .
   if v-ok <> TRUE THEN DO:
       return no-apply.
   END.

   message  "Прежде чем продолжить работу данной программы убедитесь, что в файле, который вы ":U skip
            "хотите закачать в ТН, колонка, содержащая АРТИКУЛ, была отформатирована как числовая ":U SKIP
            "без десятичных знаков. В случае если артикул будет состоять из одних цифр, например 111011,":U SKIP
             "в ТН он закачается как 111011.00. ":U
           skip "Продолжать ?":U
           view-as alert-box WARNING  buttons OK-CANCEL TITLE "В Н И М А Н И Е" update v-ok .
   if v-ok <> TRUE THEN DO:
       return no-apply.
   END.

   find first buf_sys-ctrl.
   if buf_sys-ctrl.db-num <> 0 then do:
     message "Данная утилита может работать только в ГБД.". PAUSE.
     return.
   end.

   /*  Есть ли такая шкала  к которой хотят привезать товар  */
   find first buf_gds-prt no-lock
    where buf_gds-prt.root      = YES
      and buf_gds-prt.node-name = i-scale
   no-error.
   if not available buf_gds-prt then do:
       message "Нет шкалы " i-scale. pause.
       return.
   END.

   /*  Есть ли такая группа  к которой хотят привезать товар  */
   find first buf_gds-grp no-lock
    where buf_gds-grp.lvl-num   = buf_gds-grp.upper-code
      and buf_gds-grp.node-name = i-grp-name
   no-error.
   if not avail buf_gds-grp then do:
       message "Нет группы " i-grp-name. pause.
       return.
   END.

   find first buf_clients no-lock
    where buf_clients.obj-type = i-cli-type
      and buf_clients.obj-code = i-cli-code
   no-error.
   if not available buf_clients then do:
       message "Нет клиента " i-cli-type i-cli-code. pause.
       return.
   END.
/*   parparentproc = g#mainmenu-handle.*/
   { gbl/getcntxt.i get }

       RUN enable_UI.
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
  DISPLAY file-name Tumbler
      WITH FRAME Dialog-Frame.
  ENABLE file-name B-file Tumbler Btn_OK Btn_Cancel
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-imp-goods Dialog-Frame
PROCEDURE proc-imp-goods :
define input  parameter p-mode      as character            no-undo .
define input  parameter p-gds-code  like ub.goods.gds-code  no-undo .
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
   if p-mode <> {&add-def} and p-mode <> {&update} then do:
    message
      "Неверное значение параметра p-mode в процедуре proc-imp-goods = " p-mode
    view-as alert-box error.
    return.
   end.


   do transaction:
            if p-mode = {&add-def} then do :
              run ref/dtaxgdss.p ( input no
                                 , input "шт":U /*par-unit-base*/
                                 , input buf_gds-grp.node-code  /* gds-prt.node-code  */
                                 , input ?
                                 , input ?
                                 , input v-cntxt-host-code-obj  /*par-host-code*/
                                 , input v-cntxt-obj-type       /*par-obj-type*/
                                 , input v-cntxt-obj-code       /*par-obj-code*/
                                 ).
            end.

            run ref/goods01.p (
                  input parparentproc
                , input p-mode           /* {&add-def} или {&update} */
                , input no       /*копирование с другого товара - тогда par-copy-rec - должен быть задан*/
                , input 0    /*нужно ли вводить ДОП БК вместе с товаром*/
                , input no         /*мз карточки товара - yes*/
                , input yes        /*ругаемся вслух или ?*/
                , input no   /* yes - пропускается проверка на повторный артикул */
                , input no           /*идет импорт из файла - из карточки товара*/
                , input yes  /*надо сохранить только одну запись - потом выход в справ*/
                , input v-cntxt-host-code-obj
                , input v-cntxt-obj-type
                , input v-cntxt-obj-code
                , input yes                       /*товар - yes услуга no*/
                , input ?                            /*recid записи с которой копируем*/
                , input p-gds-code
                , input i-artic                     /* артикул*/
                , input i-cli-type          /* тип производителя */
                , input i-cli-code          /*код производителя */
                , input buf_gds-prt.node-code
                , input buf_gds-grp.node-code
                , input i-name             /* наименование товара */
                , input ""
                , input I-Eng-Name     /* Название англ. */
                , input i-name         /* Название на ценнике */
                , input replace( replace( i-name, chr( 39 ), "" ), chr( 34 ), "" )
                , input i-city                /* Код страны */
                , input "шт"        /* Ед. изм. */
                , input "шт"        /* Ед. изм. */
                , input 0.0          /* Макс. кол-во дробн./шт */
                , input 0.0          /*  Мин. кол-во дробн./шту */
                , input 1             /* Коэффициент  */
                , input 1             /* Кол. в упак.  */
                , input 0             /* Об'ем штуки */
                , input 0             /* Вес штуки */
                , input 0             /* Об'ем упаковки  */
                , input 0             /* Вес упаковки  */
                , input {&pr-calc-grp}            /*   Способ расчета  */
                , input 0             /* Процент наценки  */
                , input yes
                , input 0
                , input 0
                , input ""            /* ОКДП  */
                , input ""          /* Назначение  */
                , input ""          /*  Характеристики */
                , input ""          /*  Правила эксплутации */
                , input ""          /*  Сертификация */
                , input ""          /* Состав (комплектность)  */
                , input 0             /* Срок хранения  */
                , input 0             /* Код условия хранения  */
                , input ""            /* Сорт  */
                , input 0.0           /* процент алкоголя */
                , input 0             /*  Норма естественной убы */
                , input 0             /*  Норма отходов */
                , input ""            /*  Код ТНВЭД */
                , input ""            /*  Национальность */
                , input ""            /* Таможенная единица изм  */
                , input 0             /*  Коэффициент */
                , input ?             /*  Код глоб.группы меню */
                , input ""            /*  Примечание */
                , input no           /* настройка  */
                , input no           /*  в системе разрешены ювелирные изделия */
                , input no           /* в системе разрешена стеклотара  */
                , input no           /*  в системе разрешено топливо */
                , input "no"        /* в системе разрешена таможня  */
                , input yes         /*настройка*/
                , input no           /*настройка*/
                , input no           /* автоматический артикул */
                , input 0           /*главный код товара берется из артикула*/
                , input-output v-recid
                , output j-gds-code           /*gds-code*/
            ) no-error .

            if error-status :error
            then do:
                message
                         vss-workfile vss-revision vss-description
                    skip string(
                                if p-mode = {&add-def} then "Ошибка создания карточки товара.":U
                                else "Ошибка редактирования карточки товара.":U
                               )
                    skip return-value
                    skip i-artic
                    skip trim(error-status :get-message(1))
                         trim(error-status :get-message(2))
                         trim(error-status :get-message(3))
                view-as alert-box error.
            end.
            ELSE
               ASSIGN
                  impc-save = impc-save + 1.
   end.   /*   do transaction: */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-imp-price Dialog-Frame
PROCEDURE proc-imp-price :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define buffer buf_price-list for ub.price-list.

do
on error undo, return error return-value
:
  find buf_price-list
    where buf_price-list.doc-num    = i-doc-num       and
          buf_price-list.price-type = ""              and
          buf_price-list.b-code     = buf_bar-code.b-code
  no-error.
  if available buf_price-list then do:
    next.
  end.
  else do:
    create buf_price-list.
    assign
      buf_price-list.doc-num     = i-doc-num
      buf_price-list.b-code      = buf_bar-code.b-code
      buf_price-list.artic       = buf_goods.artic
      buf_price-list.prod-type   = buf_goods.prod-type
      buf_price-list.prod-code   = buf_goods.prod-code
      buf_price-list.main-price  = yes /*(bar-code.b-code = bar-code.gds-code)*/
      buf_price-list.calc-method = {&pr-calc-no}
      buf_price-list.obj-code    = buf_price-doc.obj-code
      buf_price-list.obj-type    = buf_price-doc.obj-type
    .
  end.
  assign
    buf_price-list.price-sale = dec(I-Price)
    impc-save = impc-save + 1
  .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME