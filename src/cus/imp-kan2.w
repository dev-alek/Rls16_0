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

загрузка товара для КАНРУ

Автор: Румянцев Юрий Александрович
Дата создания: 05/20/09
Author: Yuri Rumyantsev
Creation date: 05/20/09

*/




/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "загрузка товара для КАНРУ".

define input  parameter file-name as char no-undo .
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ trg/new-bcod.i }
{ ref/grplibfn.i }
{ gbl/getcntxt.i def }
{ str/tt-tax.i "new shared" tt-tax full }
define new shared buffer goods for ub.goods.


define variable ref-list as char no-undo.

define stream imp.
define stream err.

def new shared var vattaxcd as integer no-undo.
def new shared var slttaxcd as integer no-undo.

define variable text-string as char no-undo.
define variable impc as integer No-UNDO.
define variable imp-save as integer No-UNDO.

define variable i-artic as char no-undo.
define variable i-scale as char no-undo.
define variable i-name as char no-undo.
define variable i-unit-name as char no-undo.
define variable i-VAT-code AS integer NO-UNDO.
define variable i-NP-code AS integer NO-UNDO.
define variable i-grp as integer no-undo.

define variable i-gds-code like ub.goods.gds-code NO-UNDO.
define variable j-gds-code like ub.goods.gds-code NO-UNDO.


define variable i-grp-code AS integer NO-UNDO.
define variable i-grp-name as char no-undo.

define variable i-city as char init ? no-undo.
DEFINE VARIABLE var-bc-code as integer no-undo .

define buffer buf-goods for ub.goods.
define buffer buf_bar-code for ub.bar-code.

define variable i-prod-bc as character no-undo.

define variable v_os-file as character no-undo.
define variable prt-name as character no-undo.

define variable rt as recid NO-UNDO.
define variable tax-rate-rid as character no-undo init "".
define variable taxvalue like ub.tax-rate-value.rate-value no-undo.

define temp-table tbl-grp no-undo
field Num-grp    as int
field Name-grp  as char
field Short-Name-grp  as char
field code like ub.gds-grp.node-code
index pi is unique primary
Num-grp.

define variable grp-full as character no-undo .
define variable N-grp as integer no-undo .
def buffer buf_grp for ub.gds-grp.
def buffer buf_prt for ub.gds-prt.

define variable i-color as char no-undo.
define variable i-size as char no-undo.
define variable add-scale as log no-undo.
define variable reply as log no-undo.

define variable NDS-code like  ub.tax-rate-value.rate-value  no-undo .
define variable NP-code  like  ub.tax-rate-value.rate-value init ? no-undo .

define variable  log-save as log no-undo.

/* уровень шкалы */
def temp-table ld no-undo
field num  as integer                     /* Номер уровня */
field ord  as integer                     /* Число признаков */
field name like ub.gds-prt.node-name         /* Название уровня */
index name is primary unique name .

define buffer buf_clients for ub.clients.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Imly-City b-exit b-quit Cli-code Cli-type ~
Cli-Name city1 city2
&Scoped-Define DISPLAYED-OBJECTS Cli-code Cli-type Cli-Name city1 city2

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO
     LABEL "Выполнить"
     SIZE 15 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "Выход"
     SIZE 15 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON Imly-City
     LABEL "Страна"
     SIZE 10.5 BY 1.2.

DEFINE BUTTON Imply-Cli
     LABEL "Производитель"
     SIZE 14.1 BY 1.13.

DEFINE VARIABLE city1 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.9 BY 1.2
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE city2 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 48.5 BY 1.2
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE Cli-code AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 8.9 BY 1.13
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE Cli-Name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 34.5 BY 1.13
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE Cli-type AS CHARACTER FORMAT "X(8)":U
      VIEW-AS TEXT
     SIZE 4.6 BY 1.13
     BGCOLOR 15  NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Imply-Cli AT ROW 2.27 COL 1
     Imly-City AT ROW 5.5 COL 1
     b-exit AT ROW 7.27 COL 11
     b-quit AT ROW 7.27 COL 43
     Cli-code AT ROW 2.27 COL 14 COLON-ALIGNED NO-LABEL
     Cli-type AT ROW 2.27 COL 23.5 COLON-ALIGNED NO-LABEL
     Cli-Name AT ROW 2.27 COL 28.5 COLON-ALIGNED NO-LABEL
     city1 AT ROW 5.5 COL 10 COLON-ALIGNED NO-LABEL
     city2 AT ROW 5.5 COL 14.5 COLON-ALIGNED NO-LABEL
     "       Не обязательные параметры подставляемые по умолчанию" VIEW-AS TEXT
          SIZE 64 BY 1 AT ROW 4 COL 1
          BGCOLOR 8 FGCOLOR 0
     "                         Необходимо указать" VIEW-AS TEXT
          SIZE 64 BY .93 AT ROW 1 COL 1
          BGCOLOR 8 FGCOLOR 0
     SPACE(0.00) SKIP(6.64)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Импорт товаров из текстового файла"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.


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


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Выполнить */
DO:
define variable v-rate-value as decimal no-undo .
define variable v-is-new as logical no-undo .
define variable v-b-str as character no-undo .
define variable v-rid as recid no-undo .
define buffer buf_goods for ub.goods.
define buffer buf_gds-grp for ub.gds-grp.
define buffer buf_gds-prt for ub.gds-prt.
define buffer buf_tax-rate for ub.tax-rate.
define buffer buf_lvl-name for ub.lvl-name.
define buffer buf_prod-bc for ub.prod-bc.
define buffer buf_bar-code for ub.bar-code.

if cli-code = 0 then do:
  message "Не задан производитель "
  view-as alert-box ERROR.
  return no-apply.
end.

if trim(file-name) = "" then do:
  message "Не задан файл для импорта "
  view-as alert-box ERROR.
  return no-apply.
end.

for each buf_gds-grp  no-lock:
find first buf_grp where
          buf_grp.upper-code = buf_gds-grp.node-code no-lock no-error.
if avail buf_grp then next.

 run grplib-get-full-name in this-procedure ( input buf_gds-grp.node-code
                                             ,output grp-full).

 if index(buf_gds-grp.node-name, "-") = 0 then do:
   message
  "Существуют группы товаров которые начинаются не с номера в начале названия," skip
  "в начале названия должен стоять номер и символ -" skip
   buf_gds-grp.node-name  skip
   view-as alert-box ERROR   .
   return no-apply.
 end.

 N-grp = integer(substring(buf_gds-grp.node-name, 1, index(buf_gds-grp.node-name, "-") - 1)).

 find first tbl-grp where tbl-grp.num-grp = n-grp no-lock no-error.
 if not avail tbl-grp then do:
    create tbl-grp.
    assign
    tbl-grp.num-grp = n-grp
    tbl-grp.name-grp = grp-full
    tbl-grp.Short-Name-grp = buf_gds-grp.node-name
    tbl-grp.code = buf_gds-grp.node-code.

  end.  /*    if not avail tbl-grp then do:   */
  else do:
    message
    "Существуют группы товаров с одинаковым номером " N-grp " в начале названия" skip
    buf_gds-grp.node-name  skip
    tbl-grp.Short-Name-grp  skip
    "В одном из них измените начальный номер на другой. "
     view-as alert-box ERROR   .
     return no-apply.
  end.
end.

add-scale = false.
input stream imp from value (file-name) .


repeat:
  IMPORT stream imp UNFORMATTED text-string /* NO-ERROR */ .
  if trim(text-string) = "" then   leave.

  impc = impc + 1.

  if num-entries (text-string, ";") <> 11 then do:
    OUTPUT stream Err TO value ("Imp_goods.err") append.
    put stream Err unformatted
    string(today, "99/99/9999") " "
    string(time, "HH:MM")
    " Неправильное число параметров в строке, должно быть 10, в конце строки должен стоять знак ;" skip.
    export stream  Err text-string .
    output stream Err close.
   next.
  end.

  assign
  i-artic          = ENTRY( 1, text-string, ";")
  i-name        = ENTRY( 2, text-string, ";")
  i-unit-name = ENTRY( 3, text-string, ";")
  i-grp            = integer(ENTRY( 4, text-string, ";"))
  i-vat-code    = integer(ENTRY(5, text-string, ";"))
  i-NP-code      = integer(ENTRY(6, text-string, ";"))
  i-prod-bc       = ENTRY(8, text-string, ";")
  log-save      = false
  .

    /*  Выделяем из товара шкалу -  31.001-AB-101-0034
          где: 31.001-AB  -  товар
                  101/0034   - шкала       */
    i-scale  = "/".
    overlay ( i-artic, r-index(i-artic, "-"), 1) = i-scale.
    i-scale = substring( i-artic, r-index(i-artic, "-") + 1 ).
    i-artic = substring( i-artic, 1, r-index(i-artic, "-") - 1 ).

    display
    impc  label "Прочитано"
    imp-save label "Сохранено"
    i-artic format "x(10)" label "Артикул"
    text-string format "x(40)" label "Строка файла"
    with frame ff view-as dialog-box
    title ": Импорт справочника товаров из файла".
    pause 0.

    if i-unit-name = "th" then do:
      i-unit-name = "шт".
    end.
    else  do:   /*   */
      OUTPUT stream Err TO value ("Imp_goods.err") append.
      put stream Err unformatted
      string(today, "99/99/9999") " "
      string(time, "HH:MM")
      " Неизвестная единица измерения товара" skip.
      export stream  Err text-string .
      output stream Err close.
      next.
    end.

    /*  Есть ли такая группа товара к которой хотят привезать товар  */
    find first tbl-grp where
             tbl-grp.num-grp = i-grp no-lock no-error.
    if not avail tbl-grp then do:   /*  Такой группы нет */
      OUTPUT stream Err TO value ("Imp_goods.err") append.
      put stream err unformatted
      string(today, "99/99/9999") " "
      string(time, "HH:MM")
      " Группа к которой хотят привезать товар отсутствует в БД" skip.
      export stream  err text-string .
      output stream err close.
      next.
    end.

    /*  Есть ли ставка НДС с таким процентом  */
    _tax-rate:
    for each buf_tax-rate no-lock where
            buf_tax-rate.tax-code = integer({&vat-tax-code}):
      { gbl/pftaxval.i
        ?
        buf_tax-rate.tax-code
        buf_tax-rate.rate-code
        ?
        v-cntxt-host-code-obj
        v-cntxt-obj-type
        v-cntxt-obj-code
        v-rate-value
        no-error}
      if not error-status:error then do:
        if v-rate-value = i-vat-code then do:
          leave.
        end.
      end.
    end.
    if not avail buf_tax-rate then do:   /*  Такой ставки НДС нет */
      OUTPUT stream Err TO value ("Imp_goods.err") append.
      put stream err unformatted
      string(today, "99/99/9999") " "
      string(time, "HH:MM")
      substitute(" Ставка НДС с таким процентом (&1) отсутствует в БД", i-vat-code) skip.
      export stream  err text-string .
      output stream err close.
      next.
    end.
    else  do:
      NDS-code = buf_tax-rate.rate-code.
    end.
    _tax-rate:
    for each buf_tax-rate no-lock where
            buf_tax-rate.tax-code = integer({&slt-tax-code}):
      { gbl/pftaxval.i
        ?
        buf_tax-rate.tax-code
        buf_tax-rate.rate-code
        ?
        v-cntxt-host-code-obj
        v-cntxt-obj-type
        v-cntxt-obj-code
        v-rate-value
        no-error}
      if not error-status:error then do:
        if v-rate-value = i-np-code then do:
          leave.
        end.
      end.
    end.
    if not avail buf_tax-rate then do:   /*  Такой ставки НДС нет */
      OUTPUT stream Err TO value ("Imp_goods.err") append.
      put stream err unformatted
      string(today, "99/99/9999") " "
      string(time, "HH:MM")
      substitute(" Ставка НП с таким процентом (&1) отсутствует в БД", i-np-code) skip.
      export stream  err text-string .
      output stream err close.
      next.
    end.
    else  do:
      NP-code = buf_tax-rate.rate-code.
    end.

    /*  Есть ли такая шкала  к которой хотят привезать товар  */
    find first buf_prt where
          buf_prt.root    = no and
          buf_prt.f-name = i-scale  no-lock no-error.
    if not avail buf_prt then do:
      i-color = substring( i-scale, 1, r-index(i-scale, "/") - 1 ).
      i-size = substring( i-scale, r-index(i-scale, "/") + 1 ).

      find first buf_prt where
              buf_prt.root    = no and
              buf_prt.node-name = i-color  no-lock no-error.
      if not avail buf_prt then do:
         run add-color in this-procedure  ( input i-color
                                          , output reply ).
         if reply = false then do:
            OUTPUT stream Err TO value ("Imp_goods.err") append.
            put stream err unformatted
            string(today, "99/99/9999") " "
            string(time, "HH:MM")
            " Такая шкала отсутствует в БД" skip.
            export stream  err text-string .
            output stream err close.
            next.
         end.   /*  if reply = false do: */
       add-scale = true.
       end.  /*  if not avail buf_prt then do:  */

       find first buf_prt where
                buf_prt.root    = no
            and buf_prt.node-name = i-size  no-lock no-error.
       if not avail buf_prt then do:
         run add-size in this-procedure  ( input i-size
                                          , output reply ).
         if reply = false then do:
            OUTPUT stream Err TO value ("Imp_goods.err") append.
            put stream err unformatted
            string(today, "99/99/9999") " "
            string(time, "HH:MM")
            " Такая шкала отсутствует в БД" skip.
            export stream  err text-string .
            output stream err close.
            next.
          end.   /*  if reply = false do: */
          add-scale = true.
        end.  /*  if not avail buf_prt then do:  */
    end.  /*    if not avail buf_prt then do:    */

    /* А что со страной ?  */
    if  trim(city1) <> "" then  i-city = city1 .

    find first buf_lvl-name no-lock no-error.

    find first buf_gds-prt where
          buf_gds-prt.prt-root  = buf_lvl-name.upper-code
      and buf_gds-prt.is-term   = no
      and buf_gds-prt.upper-code = buf_lvl-name.upper-code
    no-lock no-error.
    if not avail buf_gds-prt then do:
      OUTPUT stream Err TO value ("Imp_goods.err") append.
      put stream err unformatted
      string(today, "99/99/9999") " "
      string(time, "HH:MM")
      " Корневая шкала не найдена" skip.
      export stream  err text-string .
      output stream err close.
      next.
    end.

    find first buf_goods where
               buf_goods.artic = i-artic
          and  buf_goods.prod-type = cli-type
          and  buf_goods.prod-code = cli-code
    no-lock no-error.
    if not avail buf_goods then do:   /*  Нет такого товара */
      do transaction:
        run ref/dtaxgdss.p (
              input no /*p-silent*/
            , input /*par-unit-base*/  i-unit-name
            , input /*par-node-code*/  buf_gds-prt.node-code
            , input ?
            , input ?
            , input /*par-host-code*/   v-cntxt-host-code-obj
            , input /*par-obj-type*/   v-cntxt-obj-type
            , input /*par-obj-code*/  v-cntxt-obj-code
        ).

        define variable v-recid         as recid             no-undo.
        run ref/goods01.p (
              input parparentproc
            , input {&add-def}           /* {&add-def} или {&update} */
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
            , input 0
            , input i-artic                     /* артикул*/
            , input cli-type          /* тип производителя */
            , input cli-code          /*код производителя */
            , input buf_gds-prt.node-code
            , input tbl-grp.code
            , input i-name             /* наименование товара */
            , input ""
            , input i-name             /* Название англ. */
            , input i-name             /* Название на ценнике */
            , input replace( replace( i-name, chr( 39 ), "" ), chr( 34 ), "" )
            , input i-city                /* Код страны */
            , input i-unit-name       /* Ед. изм. */
            , input i-unit-name       /* Ед. изм. */
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
            , input "" /*i-33*/        /*  Правила эксплутации */
            , input "" /*i-44*/        /*  Сертификация */
            , input "" /*i-struct */  /* Состав (комплектность)  */
            , input 0             /* Срок хранения  */
            , input 0             /* Код условия хранения  */
            , input ""            /* Сорт  */
            , input 0             /*алкоголя*/
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

  find first buf_goods where
            buf_goods.artic = i-artic
      and  buf_goods.prod-type = cli-type
      and  buf_goods.prod-code = cli-code
  no-lock no-error.
  if not avail buf_goods then do:   /*  Уже есть такой товар */
    OUTPUT stream Err TO value ("Imp_goods.err") append.
      put stream Err unformatted
        string(today, "99/99/9999") " "
        string(time, "HH:MM")
        " Нет такого товара" skip.
      export stream  Err text-string .
    output stream Err close.
  end.

  /**************   Импорт  Доп БК    *****************/
  find first buf_prod-bc where
            buf_prod-bc.b-str  = i-prod-bc no-lock no-error.
  if  not avail buf_prod-bc then do:   /*  Такого   Доп БК  нет */
    find first buf_gds-prt where
        buf_gds-prt.prt-root = buf_lvl-name.upper-code and
        buf_gds-prt.f-name = i-scale  no-lock no-error.
    if  avail buf_gds-prt then do:   /*  Такая шкала есть */
      do transaction  :
        { gbl/barcodcr.i
          buf_goods.gds-code
          buf_gds-prt.node-code
          ''
          ''
          buf_goods.unit-base
          1
          v-is-new
          buf_bar-code
          no-error
          }
        v-b-str = i-prod-bc.
        run trg/prod-bc1.p (
                           input parparentproc
                          ,input yes /*p-silent*/
                          ,input yes /*dif-pdbc*/
                          ,input yes /*pbc-veto*/
                          ,input no /*send-ref*/
                          ,input '' /*p-cdrg-type*/
                          ,input '' /*ean-type*/
                          ,buffer buf_goods
                          ,input buf_bar-code.b-code
                          ,input-output v-b-str
                          ,output v-rid
                           ) no-error .
         if not error-status:error then do:
           log-save = true.
         end.
         else do:
            OUTPUT stream Err TO value ("Imp_goods.err") append.
            put stream err unformatted
            string(today, "99/99/9999") " "
            string(time, "HH:MM")
            substitute("Ошибка при сохранении ДопБК:&1&2&1&3", {&new-line}, error-status:get-message(1) , return-value ) skip.
            export stream  err text-string .
            output stream err close.
         end.
        end. /*  do transaction */
      end.  /*  if  avail gds-prt then do:     Такой шкала нет */
      else do:   /*  Такой шкала нет */
        OUTPUT stream Err TO value ("Imp_goods.err") append.
        put stream err unformatted
        string(today, "99/99/9999") " "
        string(time, "HH:MM")
        " Такая шкала отсутствует в БД" skip.
        export stream  err text-string .
        output stream err close.
    end.  /*  else do:  */
  end.  /*  if  not avail prod-bc then do:   /*  Такого   Доп БК  нет */ */
  else do:
    OUTPUT stream Err TO value ("Imp_goods.err") append.
    put stream err unformatted
    string(today, "99/99/9999") " "
    string(time, "HH:MM")
    " Такой Доп-БК уже существует в БД" skip.
    export stream  err text-string .
    output stream err close.
  end.  /*  else do:  */
  if   log-save = true then imp-save = imp-save + 1.
end.  /*  repeat:  */
input stream imp close.

message
substitute("Импорт из файла &1 закончен, прочитано &2, сохранено &3&4" +
           "Все строки из файла которые не удалось импортировать можно посмотреть в файле Imp_goods.err "
           , file-name
           , impc
           , imp-save
           , {&new-line}
)
view-as alert-box  INFORMATION.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Imly-City
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Imly-City Dialog-Frame
ON CHOOSE OF Imly-City IN FRAME Dialog-Frame /* Страна */
DO:
define variable v-rid-list as character no-undo .
define buffer buf_country for ub.country.
run ref/countris.w ( input parparentproc
                    ,input "b-sel"
                    ,input-output v-rid-list ).
if v-rid-list <> '' then     do:
 FIND first buf_country no-lock WHERE
         recid (buf_country) = integer(v-rid-list) no-error.
 if avail buf_country then
  assign
  city1 = buf_country.alpha1
  city2  =  buf_country.long-name
  .
  display
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
define variable ref-list as character no-undo .
define variable ref-rec as recid no-undo .
    /*   Производитель по умолчанию                   */
  run ref/cli-all.w ( input parparentproc
                     ,input "b-sel"
                     ,input {&cmp}
                     ,input ?
                     ,input ?
                     ,input ?
                     ,input ?
                     ,input ?
                     ,output  ref-list).

 ref-rec = integer (ref-list).
if  ref-rec <> ? then do:
  FIND first buf_clients no-lock WHERE recid (buf_clients) = ref-rec NO-error.
  if avail buf_clients then do:
    assign
    Cli-type = buf_clients.obj-type
    Cli-code = buf_clients.obj-code
    Cli-name = buf_clients.obj-name .
  end.
  display
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
  FIND first buf_clients no-lock WHERE
            buf_clients.obj-type = {&cmp}
        and buf_clients.obj-code = 8 no-error.
  if avail buf_clients then do:
    assign
    Cli-type = buf_clients.obj-type
    Cli-code = buf_clients.obj-code
    Cli-name = buf_clients.obj-name .
    display
    Cli-type
    Cli-code
    Cli-name
    with frame {&frame-name}.
  end.
  else do:
    enable
    Imply-Cli
    with frame {&frame-name}.
  end.
  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-color Dialog-Frame
PROCEDURE add-color :
/*   Создание шкалы  ЦВЕТ    */
define input  parameter new-scale like ub.gds-prt.f-name no-undo .
define output parameter reply  as log no-undo .

define buffer buf-gds-prt-1  for ub.gds-prt.
define buffer buf-gds-prt-2  for ub.gds-prt.
define buffer buf_gds-prt for ub.gds-prt.
define buffer buf_lvl-name for ub.lvl-name.

define variable u-c like ub.gds-prt.upper-code no-undo.
define variable p-n like ub.gds-prt.prt-num no-undo.
define variable n-c like ub.gds-prt.node-code no-undo.
define variable p-r like ub.gds-prt.prt-root no-undo.

for each ld :
  delete ld.
end.

reply = false.
/* Собераем все размеры для одного цевета, цве берем первый попавшицся - 4 */
for each buf_gds-prt where
      buf_gds-prt.upper-code = 4 and
      buf_gds-prt.node-name <> buf_gds-prt.f-name and
      buf_gds-prt.is-term = yes
no-lock:
    find first ld where
             ld.name = buf_gds-prt.node-name no-lock no-error.
    if not avail ld then do:
        create ld.
        assign
        ld.name = buf_gds-prt.node-name
        ld.num  = buf_gds-prt.prt-num
        .
    end.
end.

/* Берем из кол-ва уровней шкал первый   */
find first buf_lvl-name no-lock no-error.
if not avail buf_lvl-name then do:
  reply = false.
  return.
end.

/* Ищем корневую запись - Цвер - Размер, берем указатель на шкалу Цвет   */
find buf_gds-prt where
      buf_gds-prt.upper-code = buf_lvl-name.upper-code and
      buf_gds-prt.prt-num    = 0
no-lock no-error.
if not avail buf_gds-prt then do:
  reply = false.
  return.
end.
u-c = buf_gds-prt.node-code .

/* Ищем номер самой последней записи, добавлять начнем со следующего номера  */
find last buf_gds-prt  no-lock use-index pi no-error.
if not avail buf_gds-prt then do:
  reply = false.
  return.
end.
n-c = buf_gds-prt.node-code.

/* Ищем последней номер шкалы Цвет, добавлять начнем со следующего номера  */
find last buf_gds-prt no-lock  where
         buf_gds-prt.upper-code =  u-c
use-index level no-error.
if not avail buf_gds-prt then do:
  reply = false.
  return.
end.
p-n = buf_gds-prt.prt-num.

do transaction:
  create buf-gds-prt-1.
  assign
  buf-gds-prt-1.node-code   =  n-c + 1
  buf-gds-prt-1.upper-code  = u-c
  buf-gds-prt-1.node-name    = new-scale
  buf-gds-prt-1.prt-num     = p-n + 1
  buf-gds-prt-1.root        = no
  buf-gds-prt-1.lvl-num     = ub.lvl-name.level
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
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-size Dialog-Frame
PROCEDURE add-size :
/*   Создание шкалы  Размер    */
define input  parameter new-scale like ub.gds-prt.f-name no-undo .
define output parameter reply  as log no-undo .

define buffer buf_gds-prt for ub.gds-prt.
define buffer buf-gds-prt-1  for ub.gds-prt.
define buffer buf-gds-prt-2  for ub.gds-prt.
define buffer buf_lvl-name for ub.lvl-name.

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
find last buf_gds-prt no-lock where
    buf_gds-prt.upper-code = 4 use-index level no-error.
if not avail buf_gds-prt then do:
  reply = false.
  return.
end.
p-n = buf_gds-prt.prt-num.

/* Собераем все цвета  */
for each buf_gds-prt where
    buf_gds-prt.upper-code = 3
and buf_gds-prt.node-name = buf_gds-prt.f-name
and buf_gds-prt.is-term = no
no-lock:
  find first ld where
     ld.name = buf_gds-prt.node-name no-lock no-error.
  if not avail ld then do:
    create ld.
    assign
    ld.name = buf_gds-prt.node-name
    ld.num    = buf_gds-prt.prt-num
    ld.ord     = buf_gds-prt.node-code
    .
  end.
end. /*  for each gds-prt where  */

/* Берем из кол-ва уровней шкал первый   */
find first buf_lvl-name no-lock no-error.
if not avail buf_lvl-name then do:
  reply = false.
  return.
end.

/* Ищем номер самой последней записи, добавлять начнем со следующего номера  */
find last buf_gds-prt  no-lock use-index pi no-error.
if not avail buf_gds-prt then do:
  reply = false.
  return.
end.
n-c = buf_gds-prt.node-code.

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
    buf-gds-prt-1.prt-root     = buf_lvl-name.upper-code
      .
    n-c = n-c + 1.
    reply = true.
  end. /*  for each ld no-lock:  */
end. /*  do transaction:  */


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
  DISPLAY Cli-code Cli-type Cli-Name city1 city2
      WITH FRAME Dialog-Frame.
  ENABLE Imly-City b-exit b-quit Cli-code Cli-type Cli-Name city1 city2
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME