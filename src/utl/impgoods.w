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

Импорт товаров

Автор: Румянцев Юрий Александрович
Дата создания: 07/26/05
Author: Yuri Rumyantsev
Creation date: 07/26/05

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
define variable vss-description as character no-undo init "Импорт товаров".

{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i }
{ trg/new-bcod.i }
{ str/tt-tax.i "new shared" tt-tax full }
define new shared buffer goods for ub.goods.
{ gbl/getcntxt.i def }
{ ref/grplibfn.i }

define variable g-grp   as char no-undo.
define variable ref-list as char no-undo.

define stream imp.
define stream err.
define stream attem .



def new shared var vattaxcd as integer no-undo.
def new shared var slttaxcd as integer no-undo.

define variable f-name as char no-undo.
define variable p-artic     AS integer NO-UNDO init 1.
define variable p-name      AS integer NO-UNDO init 2.
define variable p-engl-name AS integer NO-UNDO.
define variable p-lab-name  AS integer NO-UNDO.
define variable p-SLT-code  AS integer NO-UNDO.
define variable p-VAT-code  AS integer NO-UNDO.
define variable p-unit-base AS integer NO-UNDO.
define variable p-struct    AS integer NO-UNDO.
define variable p-client    AS integer NO-UNDO.
define variable p-grp       AS integer NO-UNDO.
define variable p-city      AS integer NO-UNDO.
define variable p-gds-prt   AS integer NO-UNDO.
define variable p-11 AS integer NO-UNDO.
define variable p-22 AS integer NO-UNDO.
define variable p-33 AS integer NO-UNDO.
define variable p-44 AS integer NO-UNDO.

define variable choice as integer no-undo.
define variable i      AS integer NO-UNDO.

define variable i-artic     as character no-undo.
define variable i-name      as character no-undo.
define variable i-engl-name as character no-undo.
define variable i-lab-name  as character no-undo.
define variable i-SLT-code  AS integer   NO-UNDO.
define variable i-unit-base as character no-undo.
define variable i-VAT-code  AS integer   NO-UNDO.

define variable i-11 AS character NO-UNDO.
define variable i-22 AS character NO-UNDO.
define variable i-33 AS character NO-UNDO.
define variable i-44 AS character NO-UNDO.
define variable i-struct as character no-undo.

define variable i-grp-code    AS integer   NO-UNDO.
define variable i-grp-name    as character no-undo.
define variable i-city        as character no-undo.
define variable i-client-type as character no-undo.
define variable i-client-code AS integer   NO-UNDO.
define variable i-gds-prt     AS integer   NO-UNDO.

define variable i-gds-code like ub.goods.gds-code NO-UNDO.

define variable text-string as character no-undo.
define variable ii          as integer No-UNDO.
define variable impc        as integer No-UNDO.
define variable impc-save   as integer No-UNDO.

define variable grp-code like ub.gds-grp.node-code No-UNDO.
define variable t-gds-prt AS integer NO-UNDO.
define variable txt       as character no-undo.

define temp-table temp_grplib_found-grp no-undo
    field full-name  as character
    field node-code  as integer
    field level      as integer
    index pi is primary unique full-name
    index lv level
.

define buffer buf-goods for ub.goods.

DEFINE VARIABLE var-bc-code as integer no-undo .
define buffer buf_bar-code for ub.bar-code.

define variable NDS like  ub.tax-rate-value.rate-value  no-undo .
define variable NP  like  ub.tax-rate-value.rate-value  no-undo .

define variable reply as log no-undo.

define variable line as int no-undo.

define variable j-gds-code like ub.goods.gds-code NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS File R-S-stop Btn_Cancel File-txt Cli-code ~
Cli-type Cli-Name grp-txt city1 city2 measure-txt1 measure-txt2 ~
measure-txt3 prt-txt
&Scoped-Define DISPLAYED-OBJECTS R-S-stop File-txt Cli-code Cli-type ~
Cli-Name grp-txt city1 city2 measure-txt1 measure-txt2 measure-txt3 prt-txt

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 15 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK
     LABEL "Старт"
     SIZE 15 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON B-help
     LABEL "&Помощь"
     SIZE 15 BY 1.13
     .

DEFINE BUTTON File
     LABEL "Файл и настройки"
     SIZE 18.88 BY 1.33.

DEFINE BUTTON grp
     LABEL "Группа"
     SIZE 10.5 BY 1.21.

DEFINE BUTTON Imly-City
     LABEL "Страна"
     SIZE 10.5 BY 1.21.

DEFINE BUTTON Imply-Cli
     LABEL "Производитель"
     SIZE 14.13 BY 1.13.

DEFINE BUTTON measure
     LABEL "Ед. изм."
     SIZE 10.5 BY 1.21.

DEFINE BUTTON prt
     LABEL "Шкала"
     SIZE 10.5 BY 1.21.

DEFINE VARIABLE city1 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.88 BY 1.21
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE city2 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 53.88 BY 1.21
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE Cli-code AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 8.88 BY 1.13
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE Cli-Name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 43.63 BY 1.13
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE Cli-type AS CHARACTER FORMAT "X(8)":U
      VIEW-AS TEXT
     SIZE 4.63 BY 1.13
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE File-txt AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 53.5 BY 1.25
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE grp-txt AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 58.13 BY 1.21
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE measure-txt1 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6.5 BY 1.21
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE measure-txt2 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 22.25 BY 1.21
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE measure-txt3 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 28.63 BY 1.21
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE prt-txt AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 58.13 BY 1.21
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE R-S-stop AS INTEGER INITIAL 2
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Без останова", 1,
"Останов по ошибке", 2
     SIZE 21 BY 1.75 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     File AT ROW 1.42 COL 1.75
     Imply-Cli AT ROW 4.5 COL 1.38
     grp AT ROW 5.75 COL 5
     Imly-City AT ROW 7.25 COL 5
     measure AT ROW 8.75 COL 5
     prt AT ROW 10.25 COL 5
     R-S-stop AT ROW 11.75 COL 5.5 NO-LABEL
     Btn_OK AT ROW 13.75 COL 21
     Btn_Cancel AT ROW 13.75 COL 41.5
     b-help AT ROW 1.42 COL 71.5
     File-txt AT ROW 1.46 COL 19.5 COLON-ALIGNED NO-LABEL
     Cli-code AT ROW 4.5 COL 14.63 COLON-ALIGNED NO-LABEL
     Cli-type AT ROW 4.5 COL 24 COLON-ALIGNED NO-LABEL
     Cli-Name AT ROW 4.5 COL 29.13 COLON-ALIGNED NO-LABEL
     grp-txt AT ROW 5.75 COL 14.63 COLON-ALIGNED NO-LABEL
     city1 AT ROW 7.25 COL 14.63 COLON-ALIGNED NO-LABEL
     city2 AT ROW 7.25 COL 19 COLON-ALIGNED NO-LABEL
     measure-txt1 AT ROW 8.71 COL 14.63 COLON-ALIGNED NO-LABEL
     measure-txt2 AT ROW 8.71 COL 21.63 COLON-ALIGNED NO-LABEL
     measure-txt3 AT ROW 8.71 COL 44.38 COLON-ALIGNED NO-LABEL
     prt-txt AT ROW 10.25 COL 14.5 COLON-ALIGNED NO-LABEL
     "            Параметры подставляемые по умолчанию" VIEW-AS TEXT
          SIZE 73.38 BY .92 AT ROW 3.08 COL 1.5
          BGCOLOR 8 FGCOLOR 0
     SPACE(0.36) SKIP(9.12)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE BGCOLOR 0 FGCOLOR 15 "Импорт товаров в справочник из файла"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel.


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
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON Btn_OK IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON grp IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON Imly-City IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON Imply-Cli IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON measure IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON prt IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Импорт товаров в справочник из файла */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame /* Старт */
DO:
  assign
    R-S-stop
    impc-save = 0
    impc = 0
  .

 if p-client = 0 and Cli-type = "" then do:
         message "Производитель должен быть заведен в файле импорта или выбран какого подставлять по умолчанию" view-as alert-box.
 end.
 else do:
    if p-client = 0 then do:
          assign
            i-client-type = Cli-type
            i-client-code = Cli-code
          .
    end.

    find first ub.gds-prt no-lock
        where  ub.gds-prt.node-name = {&empty-scale}
    no-error.

    CASE choice:
        WHEN 1 then do:
            input stream imp from value (f-name) convert source "1251".
        END.
        WHEN 2 then do:
            input stream imp from value (f-name) convert source "KOI8-R".
        END.
    END CASE.

    OUTPUT stream err close.
    OUTPUT stream attem close.


    OUTPUT stream err TO value ("err.txt").
    OUTPUT stream attem TO value ("attem.txt").

    repeat:
        IMPORT stream imp UNFORMATTED text-string NO-ERROR.
        if trim(text-string) = "" then leave.
        assign impc = impc + 1.
        if NUm-ENTRIES(text-string, ";") <> line then do:
                  put stream err "В строчке " impc " неверное кол-во полей - " NUm-ENTRIES(text-string, ";")
                       "должно быть" line
                  skip.
                  export stream  err text-string .
                  IF r-s-stop = 1 THEN next.
                  ELSE RETURN.

        end.

        run next-good (output reply).

        display
                 impc
                 i-artic format "x(20)"
                 impc-save
              with frame ff view-as dialog-box
              title ": Загрузка справочника товаров из файла".
        pause 0.

        if  reply = false then do:
/*                export stream  err text-string . */
                next.
        end.

        if i-client-type = "" then do:
                if Cli-type = "" then do:
                          export stream  err text-string "Не задан производитель товаров".
                          IF r-s-stop = 1 THEN next.
                          ELSE RETURN.
                end.
                else
                  assign
                      i-client-type = Cli-type
                      i-client-code = Cli-code
                  .
        end.

        if i-grp-name = "" then do:
              if grp-txt = "" then do:
                     export stream  err text-string "Не задана группа товаров" .
                     IF r-s-stop = 1 THEN next.
                     ELSE RETURN.
              end.
              else
                     assign
                        i-grp-code = grp-code
                        i-grp-name = grp-txt.
        end.

        if i-unit-base = "" then do:
               if measure-txt1 = "" then do:
                     export stream  err text-string "Не задана единица измерения товаров".
                     IF r-s-stop = 1 THEN next.
                     ELSE RETURN.
               end.
               else   assign    i-unit-base = measure-txt1.
        end.

        if i-city = ""  then i-city = city1 .


        if p-gds-prt = 0 and prt-txt <> "" then do:
            find first ub.gds-prt no-lock  where
                       ub.gds-prt.root = TRUE and
                       ub.gds-prt.node-name = prt-txt
            no-error.
            if available ub.gds-prt then  i-gds-prt = ub.gds-prt.node-code.
            else do:
                    export stream  err text-string "Не задана шкала товаров".
                    IF r-s-stop = 1 THEN next.
                    ELSE RETURN.
            end.
        end.

        find first goods where
                   goods.artic = i-artic and
                   goods.prod-type = i-client-type and
                   goods.prod-code = i-client-code
        no-lock no-error.
        if available goods then do:
                  put stream attem "Такой товар уже есть в БД" skip.
                  export stream  attem text-string .
                  IF r-s-stop = 1 THEN next.
                  ELSE RETURN.
        end.

        do transaction:

/**************************************************************************/
                define variable v-host-code     as integer           no-undo.

                { gbl/hostcode.i
                v-cntxt-obj-type
                v-cntxt-obj-code
                v-host-code
                }

                run ref/dtaxgdss.p (
                      input yes
                    , input /*par-unit-base*/  i-unit-base
                    , input /*par-node-code*/  ub.gds-prt.node-code
                    , input ?
                    , input ?
                    , input /*par-host-code*/  v-host-code
                    , input /*par-obj-type*/   v-cntxt-obj-type
                    , input /*par-obj-code*/   v-cntxt-obj-code
                ).

                IF p-VAT-code > 0 THEN DO:
                  find first tt-tax
                      where tt-tax.tax-code = integer( {&vat-tax-code} )
                  no-error.
                  if available tt-tax   then do:
                      assign
                          tt-tax.rate-code = NDS .
                  end.
                END.

                if p-SLT-code > 0  then DO:
                  find first tt-tax
                      where tt-tax.tax-code = integer( {&slt-tax-code} )
                  no-error.
                  if available tt-tax  then do:
                      assign
                          tt-tax.rate-code = NP  .
                  end.
                END.

            define variable v-recid         as recid             no-undo.
            run ref/goods01.p (
                  input parparentproc
                , input {&add-def}    /* {&add-def} или {&update} */
                , input no   /*копирование с другого товара - тогда par-copy-rec - должен быть задан*/
                , input 0    /*нужно ли вводить ДОП БК вместе с товаром*/
                , input no   /*мз карточки товара - yes*/
                , input yes  /*ругаемся вслух или ?*/
                , input no   /* yes - пропускается проверка на повторный артикул */
                , input no   /*идет импорт из файла - из карточки товара*/
                , input yes  /*надо сохранить только одну запись - потом выход в справ*/
                , input v-host-code
                , input v-cntxt-obj-type
                , input v-cntxt-obj-code
                , input yes           /* товар - yes услуга no*/
                , input ?             /* recid записи с которой копируем*/
                , input 0
                , input i-artic       /* артикул*/
                , input i-client-type /* тип производителя */
                , input i-client-code /* код производителя */
                , input i-gds-prt     /* шкала */
                , input i-grp-code
                , input i-name        /* наименование товара */
                , input ""
                , input i-name        /* Название англ. */
                , input i-name        /* Название на ценнике */
                , input replace( replace( i-name, chr( 39 ), "" ), chr( 34 ), "" )
                , input i-city        /* Код страны */
                , input i-unit-base   /* Ед. изм. */
                , input i-unit-base   /* Ед. изм. */
                , input 0.0           /* Макс. кол-во дробн./шт */
                , input 0.0           /* Мин. кол-во дробн./шту */
                , input 1             /* Коэффициент  */
                , input 1             /* Кол. в упак.  */
                , input 0             /* Об'ем штуки */
                , input 0             /* Вес штуки */
                , input 0             /* Об'ем упаковки  */
                , input 0             /* Вес упаковки  */
                , input {&pr-calc-grp} /* Способ расчета  */
                , input 0             /* Процент наценки  */
                , input no            /* Отриц. остаток   */
                , input 0
                , input 0
                , input ""            /* ОКДП  */
                , input i-11          /* Назначение  */
                , input i-22          /* Характеристики */
                , input i-33          /* Правила эксплутации */
                , input i-44          /* Сертификация */
                , input i-struct      /* Состав (комплектность)  */
                , input 0             /* Срок хранения  */
                , input 0             /* Код условия хранения  */
                , input ""            /* Сорт  */
                , input 0.0           /* процент алкоголя */
                , input 0             /* Норма естественной убы */
                , input 0             /* Норма отходов */
                , input ""            /* Код ТНВЭД */
                , input ""            /* Национальность */
                , input ""            /* Таможенная единица изм  */
                , input 0             /* Коэффициент */
                , input ?             /* Код глоб.группы меню */
                , input ""            /* Примечание */
                , input no            /* настройка  */
                , input no            /* в системе разрешены ювелирные изделия */
                , input no            /* в системе разрешена стеклотара  */
                , input no            /* в системе разрешено топливо */
                , input "no"          /* в системе разрешена таможня  */
                , input yes           /* настройка*/
                , input no            /* настройка*/
                , input no            /* автоматический артикул */
                , input 0             /* главный код товара берется из артикула*/
                , input-output v-recid
                , output j-gds-code   /*gds-code*/
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
                IF r-s-stop = 2 THEN RETURN.
            end.
            else  impc-save = impc-save + 1.

        end.   /*   do transaction: */

    END.  /*     Repeat   */


    input stream imp close.
    OUTPUT stream err close.
    OUTPUT stream attem close.

    message ("Импорт из файла " + f-name + " закончен" + {&new-line} + "прочитано " + string(impc) +
             ",  сохранено " + string(impc-save) )
    view-as alert-box  INFORMATION.

 end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME File
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL File Dialog-Frame
ON CHOOSE OF File IN FRAME Dialog-Frame /* Файл и настройки */
DO:
      disable Btn_OK with frame {&frame-name}.
      disable grp with frame {&frame-name}.
      disable Imly-city with frame {&frame-name}.
      disable measure with frame {&frame-name}.
      disable prt with frame {&frame-name}.
      disable Imply-Cli with frame {&frame-name}.

      run utl/strtimp1.w (
                  input vattaxcd,
                  input slttaxcd,
                  output f-name,
                  output choice,
                  output p-artic,
                  OUTPUT p-name,
                  OUTPUT p-engl-name,
                  OUTPUT p-unit-base,
                  OUTPUT p-VAT-code,
                  OUTPUT p-SLT-code,
                  OUTPUT p-struct,
                  OUTPUT p-11,
                  OUTPUT p-22,
                  OUTPUT p-33,
                  OUTPUT p-44,

                  OUTPUT p-city,
                  OUTPUT p-grp,
                  OUTPUT p-gds-prt,
                  OUTPUT p-client,
                  OUTPUT line
                  ) no-error.
      if  error-status:error or f-name = "" then do:
              message
                vss-workfile vss-revision vss-description skip
                "Не выбран файл для импорта" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              return .
      end.
      assign
            file-txt = f-name.


      enable Btn_OK with frame {&frame-name}.

      if p-grp = 0 then
           enable grp with frame {&frame-name}.
      if p-city = 0 then
           enable Imly-city with frame {&frame-name}.
      if p-unit-base  = 0 then
           enable measure with frame {&frame-name}.
      if p-gds-prt = 0 then
           enable prt with frame {&frame-name}.
      if p-client = 0 then
           enable Imply-Cli with frame {&frame-name}.

      disp
           file-txt
      with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL grp Dialog-Frame
ON CHOOSE OF grp IN FRAME Dialog-Frame /* Группа */
DO:
    run ref/gds-grp.w (  input parparentproc
                  , input "b-sel"
                  , input v-cntxt-obj-type
                  , input v-cntxt-obj-code
                  , input-output g-grp ).
    if g-grp <> "" then do:
       FIND FIRST ub.gds-grp WHERE
         recid (ub.gds-grp) = integer (g-grp) NO-LOCK.
       if available ub.gds-grp then do:
            g-grp = "".

            run grplib-get-full-name in this-procedure ( input ub.gds-grp.node-code, output g-grp ) .

            assign
               grp-code = ub.gds-grp.node-code
               grp-txt = g-grp.
            disp
                grp-txt
            with frame {&frame-name}.
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
run ref/countris.w (input parparentproc,  "b-sel", input-output v-rid-list ).
if v-rid-list <> "" then     do:
    FIND ub.country WHERE recid (ub.country) = integer(v-rid-list) NO-LOCK.
    if available ub.country then
          assign
              city1  = ub.country.alpha1
              city2  = ub.country.long-name
          .
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
define variable v-ref-rec as recid no-undo .
      /*   Производитель по умолчанию                   */
    run ref/cli-all.w ( parparentproc, input "b-sel", {&cmp}, ?, ?, ?, ?, ?, output  ref-list).
    v-ref-rec = integer (ref-list).
    if  v-ref-rec <> ? then do:
        FIND ub.clients WHERE recid (ub.clients) = v-ref-rec NO-LOCK .
        if available ub.clients then
           assign
           Cli-type = ub.clients.obj-type
           Cli-code = ub.clients.obj-code
           Cli-name = ub.clients.obj-name
           .
           disp
             Cli-type
             Cli-code
             Cli-name
        with frame {&frame-name}.
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME measure
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL measure Dialog-Frame
ON CHOOSE OF measure IN FRAME Dialog-Frame /* Ед. изм. */
DO:
define variable v-ref-rec as recid no-undo .
    /*   Единицы измерения  по умолчанию   */
    run ref/units.w ( input parparentproc, yes, output v-ref-rec ).
    if v-ref-rec <> ? then  do:
        FIND ub.units WHERE recid (ub.units) = v-ref-rec NO-LOCK.
        assign
          measure-txt1 = ub.units.unit-name
          measure-txt2 = ub.units.long-name
          measure-txt3 = ub.units.type
        .
        disp
          measure-txt1
          measure-txt2
          measure-txt3
        with frame {&frame-name}.

    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME prt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL prt Dialog-Frame
ON CHOOSE OF prt IN FRAME Dialog-Frame /* Шкала */
DO:
 define variable v-ref-rec as recid no-undo .
    run ref/gdsprts.w (parparentproc, yes, output v-ref-rec).
    if v-ref-rec <> ? then do:
         FIND ub.gds-prt WHERE recid (ub.gds-prt) = v-ref-rec.
         if available ub.gds-prt then do:
            assign
              t-gds-prt = ub.gds-prt.prt-root
              prt-txt = ub.gds-prt.node-name
            .
            disp
                prt-txt
            with frame {&frame-name}.
       end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME R-S-stop
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

find first ub.sys-ctrl.
if ub.sys-ctrl.db-num <> 0 then do:
  message "Данная утилита может работать только в ГБД.".
  return.
end.


/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.

RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame  _DEFAULT-ENABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
  DISPLAY R-S-stop File-txt Cli-code Cli-type Cli-Name grp-txt city1 city2
          measure-txt1 measure-txt2 measure-txt3 prt-txt
      WITH FRAME Dialog-Frame.
  ENABLE File R-S-stop Btn_Cancel File-txt Cli-code Cli-type Cli-Name grp-txt
         city1 city2 measure-txt1 measure-txt2 measure-txt3 prt-txt
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
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
  DISPLAY R-S-stop File-txt Cli-code Cli-type Cli-Name grp-txt city1 city2
          measure-txt1 measure-txt2 measure-txt3 prt-txt
      WITH FRAME Dialog-Frame.
  ENABLE File R-S-stop Btn_Cancel File-txt Cli-code Cli-type Cli-Name grp-txt
         city1 city2 measure-txt1 measure-txt2 measure-txt3 prt-txt
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-node-code Dialog-Frame
PROCEDURE get-node-code :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
/*  По полному пути группы выдает КОД последнего гзла  */

define input parameter p-search-name  as character    no-undo.
define output parameter cod-grp  like ub.gds-grp.node-code no-undo.

define variable p-fill-path     as logical          no-undo.
define variable v-upper-code    as integer          no-undo.
define variable v-not-found     as logical init yes no-undo.
define variable v-counter       as integer          no-undo.
define variable v-level         as integer          no-undo.
define variable v-full-name     as character        no-undo.

define buffer buf_gds-grp       for ub.gds-grp.

cod-grp = ?.

run grplib-get-root-code ( output v-upper-code ) no-error .

if error-status :error  then do:
        undo, return error "grplib-expand-name: Ошибка при поиске корневого узла".
end.

assign
    v-full-name  = ""
    v-level      = num-entries( p-search-name, {&slash-char} ) .


for each temp_grplib_found-grp    :
    delete temp_grplib_found-grp.
end.

start-name-analyze:
do v-counter = 1 to v-level :
    if v-counter < v-level  then do:        /* Для всех групп кроме последней ищем точное совпадение */
            find first buf_gds-grp no-lock
                 where buf_gds-grp.upper-code = v-upper-code
                   and buf_gds-grp.node-name  = entry( v-counter, p-search-name, {&slash-char} )
            no-error .
            if not available buf_gds-grp   then do: /* Не обнаружена группа с таким названием */
                assign
                    v-full-name  = p-search-name
                .
/*                return error "grplib-expand-name: не найдена группа " + entry( v-level, p-search-name, {&slash-char} ).*/
            end.
            else do:        /*  Есть такая группа. Идем дальше. */
                assign
                    v-full-name = v-full-name + (if v-full-name = "" then "" else {&slash-char}) + buf_gds-grp.node-name
                    v-upper-code = buf_gds-grp.node-code
                .
                if p-fill-path = yes
                then do:
                    create temp_grplib_found-grp.
                    assign
                        temp_grplib_found-grp.full-name = v-full-name
                        temp_grplib_found-grp.node-code = v-upper-code
                        temp_grplib_found-grp.level     = v-counter
                    .
                end.
            end.
    end.
    else do:        /* Для последней группы ищем совпадение по начальным символам и составляем список таких групп */
            for each buf_gds-grp no-lock
               where buf_gds-grp.upper-code = v-upper-code
                 and buf_gds-grp.node-name begins entry( v-counter, p-search-name, {&slash-char} )
            :
                assign
                    v-not-found = no
                .
                create temp_grplib_found-grp.
                assign
                    temp_grplib_found-grp.full-name = v-full-name
                                                        + (if v-full-name = "" then "" else {&slash-char})
                                                        + buf_gds-grp.node-name
                    temp_grplib_found-grp.node-code = buf_gds-grp.node-code
                    temp_grplib_found-grp.level     = v-level
                .
            end.
            if v-not-found = yes   then do: /* Нет ни одной группы с таким названием */
                assign
                    v-full-name  = p-search-name
                .
                for each temp_grplib_found-grp
                :
                    delete temp_grplib_found-grp.
                end.
/*               return error "grplib-expand-name: не найдена группа " + entry( v-level, p-search-name, {&slash-char} ).*/
            end.
    end.
end.

for each temp_grplib_found-grp no-lock:
  assign cod-grp =  temp_grplib_found-grp.node-code.
end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE grplib-get-root-code Dialog-Frame
PROCEDURE grplib-get-root-code :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define output parameter p-root-code as integer      no-undo.

define buffer buf_gds-grp       for ub.gds-grp.

    find first buf_gds-grp no-lock
        where buf_gds-grp.upper-code = 0
    no-error .
    if not available buf_gds-grp
    then do:
        undo, return error .
    end.
    else do:
        assign
            p-root-code = buf_gds-grp.node-code
        .
    end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE next-good Dialog-Frame
PROCEDURE next-good :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output parameter reply-out as log   no-undo.

  assign
      i-artic = ""
      i-name = ""
      i-engl-name = ""
      i-lab-name = ""
      i-SLT-code = 0
      i-unit-base = ""
      i-VAT-code = 0
      i-11 = ""
      i-22 = ""
      i-33 = ""
      i-44 = ""
      i-struct = ""
      i-grp-code = 0
      i-grp-name = ""
      i-city = ""
      i-gds-prt = 0
      i-client-type = ""
      i-client-code = 0
      reply-out = true
  .

  assign
    i-artic = ENTRY(p-artic, text-string, ";")
    i-name  = ENTRY(p-name,  text-string, ";")
  .

  if p-engl-name > 0  then
        assign  i-engl-name = ENTRY(p-engl-name, text-string, ";").

  if p-lab-name > 0  then
        assign  i-lab-name = ENTRY(p-lab-name, text-string, ";").

  if p-struct > 0  then  assign i-struct = ENTRY(p-struct, text-string, ";").

  ASSIGN
    NDS = ?
    NP  = ?
  .

  if p-VAT-code > 0 then do:
       assign   i-vat-code = integer(ENTRY(p-vat-code, text-string, ";")).
       find last ub.tax-rate-value where    /*Значение ставки налога    НДС    */
                 ub.tax-rate-value.tax-code  = 1 and
                 ub.tax-rate-value.rate-code = i-vat-code no-lock no-error.
       IF NOT available ub.tax-rate-value then do:
            put stream err "Нет в БД ставки НДС с кодом "
                    i-vat-code
            skip.
            export stream  err text-string .
            assign reply-out = false.
            return .
       END.
       else NDS = ub.tax-rate-value.rate-code.
  end.
  else do:
       find last ub.tax-rate-value where    /*Значение ставки налога    НДС    */
                 ub.tax-rate-value.tax-code  = 1 and
                 ub.tax-rate-value.rate-code = 1 no-lock no-error.
       assign
         i-VAT-code =  ub.tax-rate-value.rate-code.
         NDS = ub.tax-rate-value.rate-code
       .
  end.

  if p-SLT-code > 0  then do:
       assign   i-SLT-code = integer(ENTRY(p-SLT-code, text-string, ";")).
       find last ub.tax-rate-value where    /*Значение ставки налога    НП    */
                 ub.tax-rate-value.tax-code  = 2 and
                 ub.tax-rate-value.rate-code = i-SLT-code no-lock no-error.
       IF NOT available ub.tax-rate-value then do:
            put stream err "Нет в БД ставки НП "
                    i-SLT-code
            skip.
            export stream  err text-string .
            assign reply-out = false.
            return .
       END.
       else  NP = tax-rate-value.rate-code .
  end.
  else do:
       find last ub.tax-rate-value where    /*Значение ставки налога    НП    */
                 ub.tax-rate-value.tax-code  = 2 and
                 ub.tax-rate-value.rate-code = 22 no-lock no-error.
       assign
         i-SLT-code = ub.tax-rate-value.rate-code
         NP = ub.tax-rate-value.rate-code
       .
  end.

  if p-unit-base > 0  then do:
       FIND FIRST ub.units NO-LOCK where
          ub.units.unit-name = ENTRY(p-unit-base, text-string, ";")
       No-ERROR.
       IF NOT available ub.units then do:
            put stream err "Нет в БД единицы измерения "
                    ENTRY(p-unit-base, text-string, ";")
            skip.
            export stream  err text-string .

            assign reply-out = false.
            return .
       END.
       assign  i-unit-base = ENTRY(p-unit-base, text-string, ";").
  end.

  if p-grp > 0  then do:
       assign i-grp-name = ENTRY(p-grp, text-string, ";").
       run get-node-code (input i-grp-name, output i-grp-code) .

       FIND FIRST ub.gds-grp NO-LOCK where
                  ub.gds-grp.node-code = i-grp-code
       No-ERROR.

       IF NOT available ub.gds-grp then do:
               put stream err "Нет в БД такой группы товаров "
                   ENTRY(p-grp, text-string, ";") format "x(50)"
               skip.
               export stream  err text-string .

               assign
                 i-grp-name = ""
                 i-grp-code = 0.
                 reply-out = false
               .
               return .
       END.
  end.

  if p-city > 0  then  do:
      assign i-city = ENTRY(p-city, text-string, ";").
      if trim(i-city) <> "" then do:
         find first ub.country where
                    ub.country.alpha1 = i-city no-lock no-error.
         if not available ub.country then do:
             put stream err "Нет в БД такой страны "
                    i-city
             skip.
             export stream  err text-string .
             assign
                i-city = ""
                reply-out = false
             .
             return.
         end.
      end.
  end.

  if p-client > 0  then  do:
     assign
         i-client-type = "орг"
         i-client-code = integer(ENTRY(p-client, text-string, ";")).
     find first ub.clients where
                ub.clients.obj-type = i-client-type  and
                ub.clients.obj-code = i-client-code no-lock no-error.
     if not available ub.clients then do:
          put stream err "Нет в БД такого производителя "
                    i-client-code
         skip.
         export stream  err text-string .
         assign
            i-client-type = ""
            i-client-code = 0
            reply-out = false
         .
         return .
     end.
  end.

   /*  Шкала  */
  if p-gds-prt > 0  then   do:
         find first ub.gds-prt where
              ub.gds-prt.root = TRUE and
              ub.gds-prt.node-name = ENTRY(p-gds-prt, text-string, ";")  no-lock no-error.
         if  not  available  ub.gds-prt  then do:
             put stream err "Нет в БД такой шкалы "
                    ENTRY(p-gds-prt, text-string, ";")
             skip.
             export stream  err text-string .
             assign
                 i-gds-prt = 0
                 reply-out = false
             .
             return.
         end.
         else i-gds-prt = ub.gds-prt.prt-root .
  end. /*  */

  if p-struct > 0  then  assign i-struct = ENTRY(p-struct, text-string, ";").

  if p-11 > 0  then  assign i-11 = ENTRY(p-11, text-string, ";").

  if p-22 > 0  then  assign i-22 = ENTRY(p-22, text-string, ";").

  if p-33 > 0  then  assign i-33 = ENTRY(p-33, text-string, ";").

  if p-44 > 0  then  assign i-44 = ENTRY(p-44, text-string, ";").


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME