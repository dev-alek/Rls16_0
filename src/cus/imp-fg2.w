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

Импорт из текстового файла - продолжение

Автор: Чернова Светлана Александровна
Дата создания: 12/28/06
Author: Svetlana Chernova
Creation date: 12/28/06

create: Румянцев Юрий Александрович

*/



/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input parameter parparentproc as widget-handle no-undo .
define input  parameter file-name as char no-undo .

/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/showinf.i  }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ trg/new-bcod.i }
{ ref/grplibfn.i }
{ gbl/getcntxt.i def }

{ str/tt-tax.i "new shared" tt-tax full }
define new shared buffer goods for ub.goods.


define variable ref-list as char no-undo.

define stream imp.
define stream err.

define new shared var vattaxcd as integer no-undo.
define new shared variable slttaxcd as integer no-undo.

define variable g-grp   as char no-undo.
DEFINE variable grp-code like ub.gds-grp.node-code No-UNDO.

DEFINE variable text-string as char no-undo.
DEFINE variable impc as integer No-UNDO.
DEFINE variable imp-save as integer No-UNDO.


DEFINE variable i-name as char no-undo.
DEFINE variable i-artic as char no-undo.
DEFINE variable i-size as char no-undo.
DEFINE variable i-color as char no-undo.
DEFINE variable i-scale as char no-undo.
DEFINE variable i-sertif  as char no-undo.
DEFINE variable i-sostav  as char no-undo.
DEFINE variable i-prav  as char no-undo.

DEFINE variable varrate-code LIKE ub.tax-rate-gds-grp.rate-code NO-UNDO.


DEFINE variable i-grp as integer no-undo.

DEFINE variable i-gds-code like goods.gds-code NO-UNDO.
DEFINE variable j-gds-code like goods.gds-code NO-UNDO.


/*DEFINE variable i-grp-code AS integer NO-UNDO.
DEFINE variable i-grp-name as char no-undo.*/

DEFINE variable i-city as char init ? no-undo.
DEFINE VARIABLE var-bc-code as integer no-undo .

define buffer buf-goods for ub.goods.
define buffer buf_bar-code for ub.bar-code.

DEFINE variable i-prod-bc as char no-undo.

define variable v_os-file as char no-undo.
define variable prt-name as char no-undo.

DEFine variable rt as recid NO-UNDO.
DEFine variable tax-rate-rid as char no-undo init "".
define variable taxvalue like ub.tax-rate-value.rate-value no-undo.

DEFine variable cod-size-color like ub.gds-prt.node-code no-undo.
DEFine variable end-cod like ub.gds-prt.upper-code no-undo.
DEFine variable cod-size like ub.gds-prt.upper-code no-undo.
DEFine variable cod-color like ub.gds-prt.upper-code no-undo.

define temp-table tbl-grp NO-UNDO
       field Num-grp    as int
       field Name-grp  as char
       field Short-Name-grp  as char
       field code like ub.gds-grp.node-code
   index pi is unique primary
       Num-grp.

define variable grp-full as char.
define variable N-grp as integer.
define buffer buf-grp for ub.gds-grp.
define buffer buf-prt for ub.gds-prt.

DEFINE variable add-scale as log no-undo.
DEFINE variable reply as log no-undo.

DEFINE variable NDS-code like  ub.tax-rate-value.rate-value  no-undo .
DEFINE variable NP-code     like  ub.tax-rate-value.rate-value init ? no-undo .

DEFINE variable  N-param AS DEC NO-UNDO.

DEFINE variable  log-save as log no-undo.
define variable dif-pdbc as logical no-undo initial no.
define variable pbc-veto  as logical no-undo.
define variable v-param-type                as character                no-undo.
define variable v-value-character           as character                no-undo.
define variable v-value-date                as date                     no-undo.
define variable v-value-decimal             as decimal                  no-undo.
define variable v-value-integer             as INTEGER                  no-undo.
define variable v-value-logical             AS LOGICAL                  no-undo.
define variable v-tth                       as handle                   no-undo.



/* уровень шкалы */
define temp-table ld no-undo
    field num  as integer                     /* Номер уровня */
    field ord  as integer                     /* Число признаков */
    field name like ub.gds-prt.node-name         /* Название уровня */
    index name is primary unique name .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS grp Imly-City Btn_OK Btn_Cancel Cli-code ~
Cli-type Cli-Name grp-txt city1 city2
&Scoped-Define DISPLAYED-OBJECTS Cli-code Cli-type Cli-Name grp-txt city1 ~
city2

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "Выход"
     SIZE 15 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "Выполнить"
     SIZE 15 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON grp
     LABEL "Группа"
     SIZE 10.5 BY 1.21.

DEFINE BUTTON Imly-City
     LABEL "Страна"
     SIZE 10.5 BY 1.21.

DEFINE BUTTON Imply-Cli
     LABEL "Производитель"
     SIZE 14.13 BY 1.13.

DEFINE VARIABLE city1 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.88 BY 1.21
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE city2 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 48.5 BY 1.21
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE Cli-code AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 8.88 BY 1.13
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE Cli-Name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 34.5 BY 1.13
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE Cli-type AS CHARACTER FORMAT "X(8)":U
      VIEW-AS TEXT
     SIZE 4.63 BY 1.13
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE grp-txt AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 53 BY 1.21
     BGCOLOR 15  NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Imply-Cli AT ROW 2.25 COL 1
     grp AT ROW 5 COL 1
     Imly-City AT ROW 6.75 COL 1
     Btn_OK AT ROW 8.25 COL 11
     Btn_Cancel AT ROW 8.25 COL 43
     Cli-code AT ROW 2.25 COL 14 COLON-ALIGNED NO-LABEL
     Cli-type AT ROW 2.25 COL 23.5 COLON-ALIGNED NO-LABEL
     Cli-Name AT ROW 2.25 COL 28.5 COLON-ALIGNED NO-LABEL
     grp-txt AT ROW 5 COL 10 COLON-ALIGNED NO-LABEL
     city1 AT ROW 6.75 COL 10 COLON-ALIGNED NO-LABEL
     city2 AT ROW 6.75 COL 14.5 COLON-ALIGNED NO-LABEL
     "                         Необходимо указать" VIEW-AS TEXT
          SIZE 64 BY .92 AT ROW 1 COL 1
          BGCOLOR 8 FGCOLOR 0
     "       Не обязательные параметры подставляемые по умолчанию" VIEW-AS TEXT
          SIZE 64 BY 1 AT ROW 3.75 COL 1
          BGCOLOR 8 FGCOLOR 0
     SPACE(0.00) SKIP(4.74)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Импорт товаров из текстового файла"
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

/* SETTINGS FOR BUTTON Imply-Cli IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Импорт товаров из текстового файла */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame /* Выполнить */
DO:
    define variable l-is-weight as logical no-undo .
    define variable l-is-pgweight as logical no-undo .
    define variable l-is-petrolium as logical no-undo .


   if cli-code = 0 then do:
            message "Не задан производитель "
            view-as alert-box ERROR.
            return no-apply.
   end.

   if trim(grp-txt) = "" then do:
            message "Не задана группа товаров "
            view-as alert-box ERROR.
            return no-apply.
   end.

   if trim(city1) = "" then do:
            message "Не задана страна "
            view-as alert-box ERROR.
            return no-apply.
   end.

   if trim(file-name) = "" then do:
            message "Не задан файл для импорта "
            view-as alert-box ERROR.
            return no-apply.
   end.


   add-scale = false.
   input stream imp from value (file-name) .


   repeat:

        IMPORT stream imp UNFORMATTED text-string /* NO-ERROR */ .
        if trim(text-string) = "" then   leave.

        impc = impc + 1.

        if num-entries (text-string, ";") < 24 then do:
               N-param = num-entries (text-string, ";").
               OUTPUT stream Err TO value ("Imp_goods.err") append.
                  put stream Err unformatted
                    string(today, "99/99/9999") " "
                    string(time, "HH:MM")
                    " Неправильное число параметров в строке, должно быть 24 "  N-param skip.
                  export stream  Err text-string .
               output stream Err close.
               next.
        end.
        IF trim(ENTRY( 9, text-string, ";")) = "Article name" THEN NEXT.


        assign
            i-artic  = trim(ENTRY( 9, text-string, ";") + "-" + ENTRY( 10, text-string, ";"))
            i-size   = ENTRY( 11, text-string, ";")
            i-color  = ENTRY( 13, text-string, ";")
            i-prod-bc = ENTRY( 19, text-string, ";")
            i-name   = trim(ENTRY( 8, text-string, ";"))
            i-scale  =  i-size + "/" +  i-color
            i-sertif = trim(ENTRY( 14, text-string, ";") + " " + ENTRY( 15, text-string, ";") + " " + ENTRY( 16, text-string, ";"))
            i-sostav = trim(ENTRY( 23, text-string, ";"))
            i-prav   = trim(ENTRY( 24, text-string, ";"))
            log-save      = false
        .

        if num-entries (text-string, ";") = 21 THEN
           ASSIGN i-name  = i-name + " " + TRIM(ENTRY( 21, text-string, ";")).


        if trim(i-artic) = "" THEN DO:
            OUTPUT stream Err TO value ("Imp_goods.err") append.
               put stream Err unformatted
                  string(today, "99/99/9999") " "
                  string(time, "HH:MM")
                  " Не задан артикул товара, см. строку " impc skip.
               export stream  Err text-string .
            output stream Err close.
            next.
        END.

        if trim(i-size) = "" AND trim(i-color) = "" THEN
           ASSIGN  i-scale =  "_Пустая шкала".
        ELSE DO:
           if trim(i-size) = "" THEN i-size = "Б.Р.".
           if trim(i-color) = "" THEN i-color = "Б.Ц.".
           i-scale =  i-size + "/" +  i-color.
        END.  /* ELSE DO:  */

        if trim(i-prod-bc) = "" THEN DO:
            OUTPUT stream Err TO value ("Imp_goods.err") append.
               put stream Err unformatted
                  string(today, "99/99/9999") " "
                  string(time, "HH:MM")
                  " Не задан бар-код товара, см. строку " impc  skip.
               export stream  Err text-string .
            output stream Err close.
            next.
        END.

        IF trim(i-name) = "" THEN DO:
            OUTPUT stream Err TO value ("Imp_goods.err") append.
               put stream Err unformatted
                  string(today, "99/99/9999") " "
                  string(time, "HH:MM")
                  " Не заданно наименование товара, см. строку " impc skip.
               export stream  Err text-string .
            output stream Err close.
            next.

        END.

        display
                 impc  label "Прочитано"
                 imp-save label "Сохранено"
                 i-artic format "x(10)" label "Артикул"
                 text-string format "x(40)" label "Строка файла"
              with frame ff view-as dialog-box
              title ": Импорт справочника товаров из файла".
        pause 0.


        /*  Есть ли такая шкала  к которой хотят привезать товар  */
        find first buf-prt where
             buf-prt.root    = no and
             buf-prt.f-name = i-scale  no-lock no-error.
        if not avail buf-prt then do:
                find first buf-prt where
/*!!!!!*/             buf-prt.upper-code = cod-size-color and
                      buf-prt.root       = no and
                      buf-prt.node-name = i-size  no-lock no-error.
                if not avail buf-prt then do:
                      run add-color (input i-size, output reply ).
                      if reply = false then do:
                               OUTPUT stream Err TO value ("Imp_goods.err") append.
                               put stream err unformatted
                                  string(today, "99/99/9999") " "
                                  string(time, "HH:MM")
                                  " Такая шкала  размера отсутствует в БД, см. строку " impc skip.
                               export stream  err text-string .
                               output stream err close.
                         next.
                      end.   /*  if reply = false do: */
                      add-scale = true.
                end.  /*  if not avail buf-prt then do:  */


                find first buf-prt where
                     buf-prt.root    = no and
                     buf-prt.node-name = i-color  no-lock no-error.
                if not avail buf-prt then do:

                     run add-size (input i-color, output reply ).
                     if reply = false then do:
                         OUTPUT stream Err TO value ("Imp_goods.err") append.
                         put stream err unformatted
                           string(today, "99/99/9999") " "
                           string(time, "HH:MM")
                           " Такая шкала цвета отсутствует в БД, см. строку " impc skip.
                         export stream  err text-string .
                         output stream err close.
                        next.
                     end.   /*  if reply = false do: */
                     add-scale = true.
                end.  /*  if not avail buf-prt then do:  */

        end.  /*    if not avail buf-prt then do:    */



        /* А что со страной ?  */
        if  trim(city1) <> "" then  i-city = city1 .

        find first ub.lvl-name no-lock no-error.

        find first ub.gds-prt where
             ub.gds-prt.prt-root  = ub.lvl-name.upper-code and
             ub.gds-prt.is-term   = no  and
             ub.gds-prt.upper-code = ub.lvl-name.upper-code
        no-lock no-error.
        if not avail gds-prt then do:
                  OUTPUT stream Err TO value ("Imp_goods.err") append.
                  put stream err unformatted
                    string(today, "99/99/9999") " "
                    string(time, "HH:MM")
                    " Корневая шкала не найдена" skip.
                  export stream  err text-string .
                  output stream err close.
                  next.
        end.

        find goods where
                   goods.artic = i-artic and
                   goods.prod-type = cli-type and
                   goods.prod-code = cli-code
        no-lock no-error.
        if not avail goods then do:   /*  Нет такого товара */
             do transaction:


                     define variable v-host-code     as integer           no-undo.

                     { gbl/hostcode.i
                        v-cntxt-obj-type
                        v-cntxt-obj-code
                        v-host-code
                     }

                     run ref/dtaxgdss.p (
                           input no
                         , input /*par-unit-base*/  "шт."
                         , input /*par-node-code*/  grp-code
                         , input ?
                         , input ?
                         , input /*par-host-code*/   v-host-code
                         , input /*par-obj-type*/   v-cntxt-obj-type
                         , input /*par-obj-code*/  v-cntxt-obj-code
                     ).
                     define variable v-recid         as recid             no-undo.

            run ref/goods01.p (
                  input parparentproc
                , input {&add-def}           /* {&add-def} или {&update} */
                , input no          /*копирование с другого товара - тогда par-copy-rec - должен быть задан*/
                , input 0          /*нужно ли вводить ДОП БК вместе с товаром*/
                , input no         /*мз карточки товара - yes*/
                , input yes        /*ругаемся вслух или ?*/
                , input YES         /* yes - пропускается проверка на повторный артикул */
                , input no         /*идет импорт из файла - из карточки товара*/
                , input yes        /*надо сохранить только одну запись - потом выход в справ*/
                , input v-host-code
                , input v-cntxt-obj-type
                , input v-cntxt-obj-code
                , input yes                       /*товар - yes услуга no*/
                , input ?                            /*recid записи с которой копируем*/
                , input 0
                , input i-artic                     /* артикул*/
                , input cli-type          /* тип производителя */
                , input cli-code          /*код производителя */
                , input gds-prt.node-code
                , input  grp-code
                , input i-name             /* наименование товара */
                , input ""
                , input ""             /* Название англ. */
                , input i-name             /* Название на ценнике */
                , input replace( replace( i-name, chr( 39 ), "" ), chr( 34 ), "" )
                , input i-city                /* Код страны */
                , input "шт."       /* Ед. изм. */
                , input "шт."       /* Ед. изм. */
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
                , input "" /*i-11*/        /* Назначение  */
                , input "" /*i-22*/        /*  Характеристики */
                , input i-prav /*i-33*/        /*  Правила эксплутации */
                , input i-sertif           /*  Сертификация */
                , input i-sostav      /* Состав (комплектность)  */
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
                    skip "Ошибка создания или изменения карточки товара."
                    skip return-value
                    skip i-artic
                    skip trim(error-status :get-message(1))
                         trim(error-status :get-message(2))
                         trim(error-status :get-message(3))
                view-as alert-box error.
            end.


                    log-save = true.
             end.   /*   do transaction: */
        end.   /*    if not avail goods then do:   /*  Уже есть такой товар */   */

        find goods where
                   goods.artic = i-artic and
                   goods.prod-type = cli-type and
                   goods.prod-code = cli-code
        no-lock no-error.
        if not avail goods then do:   /*  Уже есть такой товар */
               OUTPUT stream Err TO value ("Imp_goods.err") append.
                  put stream Err unformatted
                    string(today, "99/99/9999") " "
                    string(time, "HH:MM")
                    " Уже есть такой товар, см. строку " impc skip.
                  export stream  Err text-string .
               output stream Err close.
        end.

        /**************   Импорт  Доп БК    *****************/
        find first ub.prod-bc where  ub.prod-bc.b-str  = i-prod-bc no-lock no-error.
        if  not avail ub.prod-bc then do:   /*  Такого   Доп БК  нет */
              find ub.gds-prt where
                  ub.gds-prt.prt-root = ub.lvl-name.upper-code and
                  ub.gds-prt.f-name = i-scale  no-lock no-error.
              if  avail gds-prt then do:   /*  Такая шкала есть */

                   do transaction  :
                         find first ub.bar-code where ub.bar-code.gds-code = ub.goods.gds-code and
                             ub.bar-code.node-code = ub.gds-prt.node-code no-lock no-error.
                         if not avail ub.bar-code then do:
                                run gen-b-code IN THIS-PROCEDURE (
                                               input {&gbl-bc-code}
                                              ,output var-bc-code
                                              ) no-error.
                                if error-status:error then do:
                                     return .
                                end.
                                else do:
                                   create buf_bar-code.
                                   assign
                                         buf_bar-code.b-code        = var-bc-code
                                         buf_bar-code.node-code     = ub.gds-prt.node-code
                                         buf_bar-code.gds-code      = ub.goods.gds-code
                                         buf_bar-code.in-code       = "":U
                                         buf_bar-code.part-code     = "":U
                                         buf_bar-code.unit-cli      = ub.goods.unit-base
                                         buf_bar-code.cli-base-rate = 1
                                   .
                                end.
                                find first ub.bar-code where ub.bar-code.gds-code = ub.goods.gds-code and
                                       ub.bar-code.node-code = ub.gds-prt.node-code no-lock no-error.
                         end.   /*  if not avail bar-code then do:  */
                   end. /*  do transaction */
                  { gbl/prodbctv.i
                      i-prod-bc
                      ub.bar-code.unit-cli
                      ub.goods.unit-base
                      'weight=request':u
                      l-is-weight
                  }

                  { gbl/prodbctv.i
                      i-prod-bc
                      ub.bar-code.unit-cli
                      ub.goods.unit-base
                      'pgweight=request':u
                      l-is-pgweight
                  }

                  { gbl/prodbctv.i
                      i-prod-bc
                      ub.bar-code.unit-cli
                      ub.goods.unit-base
                      'petrolium=request':u
                      l-is-petrolium
                  }

                  if (l-is-weight
                  or l-is-pgweight
                  or l-is-petrolium
                  ) then do:
                   OUTPUT stream Err TO value ("Imp_goods.err") append.
                      put stream err unformatted
                       string(today, "99/99/9999") " "
                       string(time, "HH:MM")
                       " ДопБК Весовой или топливый невозможно проимпортировать, см. строку " impc skip.
                      export stream  err text-string .
                   output stream err close.

                  end.
                  else do:
                   do transaction:
                      define variable rid as recid no-undo .
                      rid = ?.
                      run trg/prod-bc1.p (
                                          input  parparentproc
                                          ,input yes /*p-silent*/
                                          ,input dif-pdbc /* dif-pdbc */
                                          ,input pbc-veto /*pbc-veto*/
                                          ,input no /*send-ref*/
                                          ,input '' /*cdrg-type*/
                                          ,input ""
                                          ,buffer ub.goods
                                          ,input ub.bar-code.b-code
                                          ,input-output i-prod-bc
                                          ,output rid
                                          ) no-error.
                      if error-status :error then do:
                        OUTPUT stream Err TO value ("Imp_goods.err") append.
                            put stream err unformatted
                            string(today, "99/99/9999") " "
                            string(time, "HH:MM")
                            substitute(" Ошибка при импорте ДопБК (&1&2&3), см. строку &4"
                                      , error-status:get-message(1)
                                      , {&new-line}
                                      , return-value
                                      ,impc )
                                      skip.
                            export stream  err text-string .
                        output stream err close.
                      end.
                      else if rid = ? then do:
                        OUTPUT stream Err TO value ("Imp_goods.err") append.
                            put stream err unformatted
                            string(today, "99/99/9999") " "
                            string(time, "HH:MM")
                            substitute(" Невозможен импорт ДопБК (&1), см. строку &2"
                                      , return-value
                                      ,impc )
                                      skip.
                            export stream  err text-string .
                        output stream err close.
                      end.

                         log-save = true.
                   end. /*  do transaction */
                   end.

              end.  /*  if  avail gds-prt then do:     Такой шкала нет */
              else do:   /*  Такой шкала нет */
                   OUTPUT stream Err TO value ("Imp_goods.err") append.
                      put stream err unformatted
                       string(today, "99/99/9999") " "
                       string(time, "HH:MM")
                       " Такая шкала отсутствует в БД, см. строку " impc skip.
                      export stream  err text-string .
                   output stream err close.
              end.  /*  else do:  */
        end.  /*  if  not avail prod-bc then do:   /*  Такого   Доп БК  нет */ */
        else do:
                   OUTPUT stream Err TO value ("Imp_goods.err") append.
                      put stream err unformatted
                        string(today, "99/99/9999") " "
                        string(time, "HH:MM")
                        " Такой Доп-БК уже существует в БД, см. строку " impc skip.
                      export stream  err text-string .
                   output stream err close.
        end.  /*  else do:  */
        if   log-save = true then imp-save = imp-save + 1.

   end.  /*  repeat:  */
   input stream imp close.

    message ("Импорт из файла " + file-name + " закончен, прочитано " + string(impc) +
             ",  сохранено " + string(imp-save) ) skip
             "Все строки из файла которые не удалось импортировать можно посмотреть в файле Imp_goods.err "
    view-as alert-box  INFORMATION.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL grp Dialog-Frame
ON CHOOSE OF grp IN FRAME Dialog-Frame /* Группа */
DO:
    run ref/gds-grp.w ( input parparentproc
                 , input "b-sel"
                 , input v-cntxt-obj-type
                 , input v-cntxt-obj-code
                 , input-output g-grp ).

    if g-grp <> "" then do:
       FIND FIRST ub.gds-grp WHERE
         recid (ub.gds-grp) = integer (g-grp) NO-LOCK.
       if avail ub.gds-grp then do:
            g-grp = "".
            run grplib-get-full-name in this-procedure ( input ub.gds-grp.node-code, output g-grp ) .
            assign
               grp-code = ub.gds-grp.node-code
               grp-txt = g-grp.
            disp
                grp-txt
            with frame {&frame-name}.
            /*************************************************/

            FOR EACH ub.tax No-LOCK WHERE
                     ub.tax.individual = no:
                  if ub.tax.individual = yes then next .

                  FIND LAST ub.tax-rate-gds-grp No-LOCK WHERE
                        ub.tax-rate-gds-grp.node-code = grp-code AND
                        ub.tax-rate-gds-grp.tax-code = ub.tax.tax-code AND
                        ub.tax-rate-gds-grp.host-code = 0 AND
                        ub.tax-rate-gds-grp.obj-type = "" AND
                        ub.tax-rate-gds-grp.obj-code = 0 NO-ERROR.
                  if avail ub.tax-rate-gds-grp THEN
                    assign
                          varrate-code = ub.tax-rate-gds-grp.rate-code.

                  FIND FIRST ub.tax-rate No-LOCK WHERE
                              ub.tax-rate.tax-code = ub.tax.tax-code AND
                              ub.tax-rate.rate-code = varrate-code No-ERROR.
                  if error-status:error or not avail ub.tax-rate then do:
                    message
                         vss-workfile vss-revision vss-description skip
                         "Не найдена запись ставки налога:"
                         "код налога" ub.tax.tax-code "код ставки" varrate-code
                     view-as alert-box error .
                  end.
                  IF ub.tax-rate-gds-grp.tax-code = 1 THEN NDS-code = ub.tax-rate-gds-grp.rate-code.
                  IF ub.tax-rate-gds-grp.tax-code = 2 THEN NP-code = ub.tax-rate-gds-grp.rate-code.
            end. /* for */
       end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Imly-City
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Imly-City Dialog-Frame
ON CHOOSE OF Imly-City IN FRAME Dialog-Frame /* Страна */
DO:
define variable v-rid-list as character no-undo .
    run ref/countris.w ( input parparentproc
                  , input "b-sel"
                  , input-output v-rid-list ).
if v-rid-list <> '' then  do:
  FIND ub.country WHERE recid (ub.country) = integer(v-rid-list) NO-LOCK.
  if avail country then
          assign
          city1 = ub.country.alpha1
          city2 = ub.country.long-name.
            disp
              city1
              city2
         with frame {&frame-name}.
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Imply-Cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Imply-Cli Dialog-Frame
ON CHOOSE OF Imply-Cli IN FRAME Dialog-Frame /* Производитель */
DO:
define variable ref-rec as recid no-undo .
    /*   Производитель по умолчанию                   */

    run ref/cli-all.w ( parparentproc, input "b-sel", {&cmp}, ?, ?, ?, ?, ?, output  ref-list).
    if ref-list = '' then do:
      return no-apply.
    end.
    ref-rec = integer (ref-list).
    if  ref-rec <> ? then do:
        FIND ub.clients WHERE recid (ub.clients) = ref-rec NO-LOCK .
        if avail ub.clients then
           assign
           Cli-type = ub.clients.obj-type
           Cli-code = ub.clients.obj-code
           Cli-name = ub.clients.obj-name .
           disp
             Cli-type
             Cli-code
             Cli-name
        with frame {&frame-name}.
    end.
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

  { gbl/getcntxt.i get }
   find gds-prt where
        gds-prt.root    = YES and
        gds-prt.node-name = "Размер + Цвет" no-lock no-error.
   if not avail gds-prt then do:
            message "Не найдена шкала - Размер + Цвет  "
            view-as alert-box ERROR.
            return no-apply.
   end.
   else
      assign
          end-cod = gds-prt.upper-code
          cod-size-color = gds-prt.node-code.
/*
   find gds-prt where
        gds-prt.root    = no and
        gds-prt.node-name = "Размер" no-lock no-error.
   if not avail gds-prt then do:
            message "Не найден уровень шкалы - Размер "
            view-as alert-box ERROR.
            return no-apply.
   end.
   else  cod-size = gds-prt.upper-code.

   find gds-prt where gds-prt.node-name = "Цвет" no-lock no-error.
   if not avail gds-prt then do:
            message "Не найден уровень шкалы - Цвет  "
            view-as alert-box ERROR.
            return no-apply.
   end.
   else  cod-color = gds-prt.upper-code.
*/


   enable Imply-Cli with frame {&frame-name}.

  run adm/shattri.p (
      input "get":U
      ,input  '':U /*p-obj-type*/
      ,input  0 /*p-obj-code*/
      ,input  {&attr-gds-ref}
      ,input  {&attr-gds-ref_dif-pdbc} /*p-param-code*/
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output dif-pdbc
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error.
  delete object v-tth.
  run adm/shattri.p (
      input "get":U
      ,input  '':U /*p-obj-type*/
      ,input  0 /*p-obj-code*/
      ,input  {&attr-gds-ref}
      ,input  {&attr-gds-ref_pbc-veto} /*p-param-code*/
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output pbc-veto
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error.
  delete object v-tth.


  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-color Dialog-Frame
PROCEDURE add-color :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

/*   Создание шкалы  ЦВЕТ    */
define input  parameter new-scale like ub.gds-prt.f-name no-undo .
define output parameter reply  as log no-undo .

define buffer buf-gds-prt-1  for ub.gds-prt.
define buffer buf-gds-prt-2  for ub.gds-prt.

define variable u-c like ub.gds-prt.upper-code no-undo.
define variable p-n like ub.gds-prt.prt-num no-undo.
define variable n-c like ub.gds-prt.node-code no-undo.
define variable p-r like ub.gds-prt.prt-root no-undo.

for each ld :
  delete ld.
end.

     reply = false.
     /* Собераем все размеры для одного цевета, цве берем первый попавшицся - 4 */
     for each ub.gds-prt where
           ub.gds-prt.upper-code = 1233 /*4*/ and
           ub.gds-prt.node-name <> ub.gds-prt.f-name and
           ub.gds-prt.is-term = yes
      no-lock:
          find ld where ld.name = ub.gds-prt.node-name no-lock no-error.
          if not avail ld then do:
              create ld.
                 assign
                    ld.name = ub.gds-prt.node-name
                    ld.num    = ub.gds-prt.prt-num .
          end.
     end.

     /* Берем из кол-ва уровней шкал первый   */
     find first ub.lvl-name no-lock no-error.
      if not avail ub.lvl-name then do:
            reply = false.
            return.
      end.

     /* Ищем корневую запись - Цвер - Размер, берем указатель на шкалу Цвет   */
     find gds-prt where
           gds-prt.upper-code = lvl-name.upper-code and
           gds-prt.prt-num    = 0
      no-lock no-error.
      if not avail gds-prt then do:
            reply = false.
            return.
      end.
      u-c = gds-prt.node-code .

      /* Ищем номер самой последней записи, добавлять начнем со следующего номера  */
      find last gds-prt  no-lock use-index pi no-error.
      if not avail gds-prt then do:
            reply = false.
            return.
      end.
      n-c = gds-prt.node-code.

      /* Ищем последней номер шкалы Цвет, добавлять начнем со следующего номера  */
      find last gds-prt no-lock  where
          gds-prt.upper-code =  u-c
      use-index level no-error.
      if not avail gds-prt then do:
            reply = false.
            return.
      end.
      p-n = gds-prt.prt-num.

      do transaction:
           create buf-gds-prt-1.
           assign
               buf-gds-prt-1.node-code   =  n-c + 1
               buf-gds-prt-1.upper-code  = u-c
               buf-gds-prt-1.node-name    = new-scale
               buf-gds-prt-1.prt-num     = p-n + 1
               buf-gds-prt-1.root        = no
               buf-gds-prt-1.lvl-num     = lvl-name.level
               buf-gds-prt-1.f-name      = new-scale
               buf-gds-prt-1.is-term     = no
               buf-gds-prt-1.prt-root    = lvl-name.upper-code
            .

            n-c = n-c + 1.

            for each ld no-lock :
                 create buf-gds-prt-2.
                 assign
                     buf-gds-prt-2.node-code   = n-c  + 1
                     buf-gds-prt-2.upper-code  = buf-gds-prt-1.node-code
                     buf-gds-prt-2.node-name    = ld.name
                     buf-gds-prt-2.prt-num     = ld.num
                     buf-gds-prt-2.root        = no
                     buf-gds-prt-2.lvl-num     = 1
                     buf-gds-prt-2.f-name      = trim(buf-gds-prt-1.f-name) + "/" + trim(ld.name)                     buf-gds-prt-2.is-term     = yes
                     buf-gds-prt-2.prt-root    = lvl-name.upper-code
                 .
                 n-c = n-c + 1.
            end.
            reply = true.
      end. /*  do transaction:  */


/******************************************************************
/*   Создание шкалы  ЦВЕТ    */

define input  parameter new-scale like gds-prt.f-name no-undo .
define output parameter reply  as log no-undo .

define buffer buf-gds-prt-1  for gds-prt.
define buffer buf-gds-prt-2  for gds-prt.

define variable u-c like gds-prt.upper-code no-undo.
define variable p-n like gds-prt.prt-num no-undo.
define variable n-c like gds-prt.node-code no-undo.
define variable p-r like gds-prt.prt-root no-undo.

for each ld :
  delete ld.
end.


      reply = false.
      p-n = ?.

      /* Ищем последней номер шкалы Цвета, добавлять начнем со следующего номера  */

      FOR EACH gds-prt no-lock where
          gds-prt.is-term = YES
/*          gds-prt.upper-code = end-cod /*1233*/ */ BY gds-prt.prt-num :
         p-n = gds-prt.prt-num.
     END.
     if p-n = ? then do:
           reply = false.
           return.
     end.



     /* Собераем все цвета  */
                                              for each gds-prt where
                     gds-prt.upper-code = cod-size-color and
           gds-prt.node-name = gds-prt.f-name and
           gds-prt.is-term = no
      no-lock:
          find ld where ld.name = gds-prt.node-name no-lock no-error.
          if not avail ld then do:
              create ld.
                 assign
                    ld.name = gds-prt.node-name
                    ld.num  = gds-prt.prt-num
                    ld.ord  = gds-prt.node-code .
          end.
      end. /*  for each gds-prt where  */

     /* Берем из кол-ва уровней шкал первый   */

     find first lvl-name WHERE
         lvl-name.level = 1 AND
         lvl-name.lvl-name = "Цвет"
      NO-LOCK NO-ERROR.
      if not avail lvl-name then do:
            reply = false.
            return.
      end.

      /* Ищем номер самой последней записи, добавлять начнем со следующего номера  */
      n-c = ?.
      FOR EACH gds-prt NO-LOCK BY gds-prt.node-code :
          n-c = gds-prt.node-code.
      END.
      if n-c = ? then do:
            reply = false.
            return.
      end.



      do transaction:
           for each ld no-lock:


                create buf-gds-prt-1.
                assign
                    buf-gds-prt-1.node-code    =  n-c + 1
                    buf-gds-prt-1.upper-code   = ld.ord
                    buf-gds-prt-1.node-name    = new-scale
                    buf-gds-prt-1.prt-num      = p-n + 1
                    buf-gds-prt-1.root         = no
                    buf-gds-prt-1.lvl-num      = 1
                    buf-gds-prt-1.f-name       = ld.name + "/" + new-scale
                    buf-gds-prt-1.is-term      = yes
                    buf-gds-prt-1.prt-root     = lvl-name.upper-code
                 .
            n-c = n-c + 1.
            reply = true.



         end. /*  for each ld no-lock:  */
      end. /*  do transaction:  */
*****************************************************************/
      current-value (s-gds-prt, {&db-name_schema}) = n-c.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-size Dialog-Frame
PROCEDURE add-size :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

/*   Создание шкалы  Размер    */
define input  parameter new-scale like ub.gds-prt.f-name no-undo .
define output parameter reply  as log no-undo .


define buffer buf-gds-prt-1  for ub.gds-prt.
define buffer buf-gds-prt-2  for ub.gds-prt.

define variable u-c like ub.gds-prt.upper-code no-undo.
define variable p-n like ub.gds-prt.prt-num no-undo.
define variable n-c like ub.gds-prt.node-code no-undo.
define variable p-r like ub.gds-prt.prt-root no-undo.

for each ld :
  delete ld.
end.

      reply = false.
      p-n = 0.

      /* Ищем последней номер шкалы Размер, добавлять начнем со следующего номера  */
      find last ub.gds-prt no-lock where
           ub.gds-prt.upper-code = 1233 /*4*/ use-index level no-error.
      if not avail ub.gds-prt then do:
            reply = false.
            return.
      end.
      p-n = ub.gds-prt.prt-num.

      /* Собераем все цвета  */
      for each ub.gds-prt where
           ub.gds-prt.upper-code = 1232 /*3*/ and
           ub.gds-prt.node-name = ub.gds-prt.f-name and
           ub.gds-prt.is-term = no
      no-lock:
          find ld where ld.name = ub.gds-prt.node-name no-lock no-error.
          if not avail ld then do:
              create ld.
                 assign
                    ld.name = ub.gds-prt.node-name
                    ld.num    = ub.gds-prt.prt-num
                    ld.ord     = ub.gds-prt.node-code .
          end.
      end. /*  for each gds-prt where  */

     /* Берем из кол-ва уровней шкал первый   */
     find first ub.lvl-name no-lock no-error.
      if not avail ub.lvl-name then do:
            reply = false.
            return.
      end.

      /* Ищем номер самой последней записи, добавлять начнем со следующего номера  */
      find last ub.gds-prt  no-lock use-index pi no-error.
      if not avail ub.gds-prt then do:
            reply = false.
            return.
      end.
      n-c = ub.gds-prt.node-code.

      do transaction:
           for each ld no-lock:
                create buf-gds-prt-1.
                assign
                    buf-gds-prt-1.node-code    =  n-c + 1
                    buf-gds-prt-1.upper-code   = ld.ord
                    buf-gds-prt-1.node-name    = new-scale
                    buf-gds-prt-1.prt-num      = p-n + 1
                    buf-gds-prt-1.root         = no
                    buf-gds-prt-1.lvl-num      = 1
                    buf-gds-prt-1.f-name       = ld.name + "/" + new-scale
                    buf-gds-prt-1.is-term      = yes
                    buf-gds-prt-1.prt-root     = ub.lvl-name.upper-code
                 .
            n-c = n-c + 1.
            reply = true.
           end. /*  for each ld no-lock:  */
      end. /*  do transaction:  */


/***************************************************************
/*   Создание шкалы  Размер    */

define input  parameter new-scale like gds-prt.f-name no-undo .
define output parameter reply  as log no-undo .

define buffer buf-gds-prt-1  for gds-prt.
define buffer buf-gds-prt-2  for gds-prt.


DEFine variable u-c like gds-prt.upper-code no-undo.
define variable p-n like gds-prt.prt-num no-undo.
define variable n-c like gds-prt.node-code no-undo.
define variable p-r like gds-prt.prt-root no-undo.

for each ld :
  delete ld.
end.

     reply = false.
     /* Собераем все размеры для одного цевета, цве берем первый попавшицся - 4 */
     for each gds-prt where
           gds-prt.upper-code = end-cod /*1233*/ and
           gds-prt.node-name <> gds-prt.f-name and
           gds-prt.is-term = yes
      no-lock:
          find ld where ld.name = gds-prt.node-name no-lock no-error.
          if not avail ld then do:
              create ld.
                 assign
                    ld.name = gds-prt.node-name
                    ld.num    = gds-prt.prt-num .
          end.
     end.

     /* Берем из кол-ва уровней шкал первый   */
     find first lvl-name WHERE
         lvl-name.level = 0 AND
         lvl-name.lvl-name = "Размер"
     no-lock no-error.
      if not avail lvl-name then do:
            reply = false.
            return.
      end.

     /* Ищем корневую запись - Цвер - Размер, берем указатель на шкалу Цвет   */
     find gds-prt where
           gds-prt.upper-code = lvl-name.upper-code and
           gds-prt.prt-num    = 0
      no-lock no-error.
      if not avail gds-prt then do:
            reply = false.
            return.
      end.
      u-c = gds-prt.node-code .

      /* Ищем номер самой последней записи, добавлять начнем со следующего номера  */
      find last gds-prt  no-lock use-index pi no-error.
      if not avail gds-prt then do:
            reply = false.
            return.
      end.
      n-c = gds-prt.node-code.

      /* Ищем последней номер шкалы Цвет, добавлять начнем со следующего номера  */
      find last gds-prt no-lock  where
          gds-prt.upper-code =  u-c
      use-index level no-error.
      if not avail gds-prt then do:
            reply = false.
            return.
      end.
      p-n = gds-prt.prt-num.


      do transaction:
           create buf-gds-prt-1.
           assign
               buf-gds-prt-1.node-code   =  n-c + 1
               buf-gds-prt-1.upper-code  = u-c
               buf-gds-prt-1.node-name    = new-scale
               buf-gds-prt-1.prt-num     = p-n + 1
               buf-gds-prt-1.root        = no
               buf-gds-prt-1.lvl-num     = lvl-name.level
               buf-gds-prt-1.f-name      = new-scale
               buf-gds-prt-1.is-term     = no
               buf-gds-prt-1.prt-root    = lvl-name.upper-code
            .

            n-c = n-c + 1.


            for each ld no-lock :

                 create buf-gds-prt-2.
                 assign
                     buf-gds-prt-2.node-code   = n-c  + 1
                     buf-gds-prt-2.upper-code  = buf-gds-prt-1.node-code
                     buf-gds-prt-2.node-name    = ld.name
                     buf-gds-prt-2.prt-num     = ld.num
                     buf-gds-prt-2.root        = no
                     buf-gds-prt-2.lvl-num     = 1
                     buf-gds-prt-2.f-name      = trim(buf-gds-prt-1.f-name) + "/" + trim(ld.name)
                     buf-gds-prt-2.is-term     = yes
                     buf-gds-prt-2.prt-root    = lvl-name.upper-code
                 .
                 n-c = n-c + 1.
            end.
            reply = true.
      end. /*  do transaction:  */
**********************************************************/
      current-value (s-gds-prt, {&db-name_schema}) = n-c.


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
  DISPLAY Cli-code Cli-type Cli-Name grp-txt city1 city2
      WITH FRAME Dialog-Frame.
  ENABLE grp Imly-City Btn_OK Btn_Cancel Cli-code Cli-type Cli-Name grp-txt
         city1 city2
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE res-t Dialog-Frame
PROCEDURE res-t :
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME