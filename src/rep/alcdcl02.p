block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: alcdcl02.p $
$Archive: rep/alcdcl02.p $

Декларация об объемах розничной продажи алкогольной продукции (Калуга)

Автор: Хныкин Павел Андреевич
Дата создания: 09/22/06
Author: Pavel Khnykin
Creation date: 09/22/06

*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: alcdcl02.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/alcdcl02.p $":U .
define variable vss-description as character no-undo init "Декларация об объемах розничной продажи алкогольной продукции (Калуга)".
{ cmp/vssrevis.i   }
{ cmp/str-glbl.i   }
{ cmp/library.i    }
{ cmp/r-pril.i new }
{ cmp/r-page1.i    }
{ rep/f-fdec.i     }
{ gbl/waitfram.i   }
{ gbl/prn-lib.i    }
{ rep/r-sym.i      }
{ rep/fmtcli.i     }
{ trg/factord.i    }
{ gbl/clntattr.i   }
{ str/clcprtsl.i   }
{ str/trdcalib.i   }
{ rep/lkp-font.i   }
{ gbl/getsect.i def }
{ gbl/paramls.i    }
define variable g#report-num              as integer              no-undo .
run get-report-num in my-handle (output g#report-num).
{ rep/alcdclxl.i   }


define input  parameter p-doc-list as character no-undo .
define input  parameter p-Pri_Perem as logical   no-undo .
define input  parameter p-begin-date as date   no-undo .
define input  parameter p-end-date   as date   no-undo .

/* scopes */
  &scop stroke " ------- ":U
  &scop div-num 1000
  &scop list-doc-delim ",":U
  &scop list-date-delim {&list-doc-delim}
  &scop list-dal-delim {&list-doc-delim}
  &scop dal-format ">>>>>>>>>9.9999"
  &scop dal-format-len 12
  &scop sum-format ">>>>>>>>>>9.999"
  &scop sum-format-len 15

  &scop f-w-alc-type-name 25
  &scop f-w-fmtcli-name 30
  &scop f-w-fmtcli-inn 15
  &scop f-w-fmtcli-post-addres 35
  &scop f-w-sert 15
  &scop f-w-sert-give 20
  &scop f-w-doc-num-date 20
  &scop f-w-dal 15
  &scop f-w-cli-region-code 9
  &scop f-w-supp-type 14
  &scop f-alc-pri-width 216
  &scop f-w-line 194
  &scop f-decl-width 196
  &scop f-w-decl-line 196
  &scop f-w-decl-sea-name 30

  &scop f-alc-retail-width 230
  &scop dal-frmt "->>>>>9"
  &scop dal-frmt-len 7
  &scop f-alc-type-name 30

  /* тип поставщика */
  &scop unknown 0
  &scop local 1
  &scop region  2
  &scop foreign 3

  &scop file-not-binded-gds nbgoods.txt

  define variable v-producer                      as integer   no-undo .
  define variable v-sert            as character no-undo .
  define variable v-sert-give       as character no-undo .
  define variable v-attr-value                    as character no-undo .
  define variable v-attr-type                     as character no-undo .
  define variable v-doc-code        as character no-undo .
  define variable v-doc-date        as date      no-undo .

/* temp-tables */

  /* алкогольные товары */
  define temp-table tt-gds no-undo like ub.goods
    field alc-type-code       like ub.alc-type.alc-type-code
    field alc-type-name       like ub.alc-type.alc-type-name
    field alc-type-inner-code like ub.alc-type.alc-type-inner-code
    field list_    as character
  index pi is primary unique gds-code
  index sea alc-type-code.

  output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) .
  output close.

  /* исключаемые док-ты */
  define temp-table tt-doc no-undo
    field doc-code    like ub.trn-doc.doc-code
    index pi is primary unique doc-code .

  /* виды алкогольной продукции */
  define temp-table tt-alc-type no-undo like ub.alc-type.

  /*
    таблица под отчет
    сведения о розничной продаже
  */
  define temp-table tt-alc-retail no-undo
    /* вид алкогольной продукции */
    field alc-type-code like ub.alc-type.alc-type-code
    field alc-type-name like ub.alc-type.alc-type-name
    field sea-list as character

    /* Остаток на начало отчетного периода */
    field ost-beg-local     as decimal /* произведено в области */
    field ost-beg-region    as decimal /* произведенов других субъектах РФ */
    field ost-beg-imp       as decimal /* импортный */
    field ost-beg-tot       as decimal
    /* Поступило за отчетный период */
    field pri-local     as decimal /* произведено в области */
    field pri-region    as decimal /* произведенов других субъектах РФ */
    field pri-imp       as decimal /* импортный */
    field pri-tot       as decimal
    /* Продано за отчетный период */
    field sale-local     as decimal /* произведено в области */
    field sale-region    as decimal /* произведенов других субъектах РФ */
    field sale-imp       as decimal /* импортный */
    field sale-tot       as decimal
    /* Возврат */
    field ret-local     as decimal /* произведено в области */
    field ret-region    as decimal /* произведенов других субъектах РФ */
    field ret-imp       as decimal /* импортный */
    field ret-tot       as decimal
    /* Прочее */
    field oth-local     as decimal /* произведено в области */
    field oth-region    as decimal /* произведенов других субъектах РФ */
    field oth-imp       as decimal /* импортный */
    field oth-tot       as decimal
    /* Остаток на конец отчетного периода */
    field ost-end-local     as decimal /* произведено в области */
    field ost-end-region    as decimal /* произведенов других субъектах РФ */
    field ost-end-imp       as decimal /* импортный */
    field ost-end-tot       as decimal
    index pi is primary unique  alc-type-code
  .


  define temp-table tt-alc-pri no-undo
    field cli-name        like ub.clients.obj-name
    field cli-type        like ub.clients.obj-type
    field cli-code        like ub.clients.obj-code
    field cli-inn         as character
    field cli-address     as character
    field cli-region-code as character
    field lic-num         as character
    field lic-give        as character
    field doc-num-date    as character
    field doc-code        like ub.trn-doc.doc-code
    field fact-date       like ub.trn-doc.fact-date
    field alc-type-name   like ub.alc-type.alc-type-name
    field alc-type-code   like ub.alc-type.alc-type-code
    field sea-list        as character
    field prod-type       as integer
    field supp-type       as character
    field quantity-str    as character
    field quantity        as decimal
    field in-code         like ub.parts.in-code
    field part-code       like ub.parts.part-code
    index pi is primary unique  alc-type-code doc-code in-code part-code prod-type
  .

/* functions */
  function str-format returns character (val as decimal , v-format as char, v-str-len as integer) forward.

/* streams */
/*  define stream nbgoods .*/
  define stream out-stream.

/* variables */
  define buffer buf_stk-line  for ub.stk-line .
  define buffer buf_trn-doc   for ub.trn-doc.

  define variable v-par-val                 as character            no-undo .
  define variable v-par-type                as character            no-undo .
  define variable v-line                    as character            no-undo .
  define variable v-host-code               like ub.clients.host-code  no-undo .
  define variable v-alc-type-name           as character            no-undo .
  define variable v-is-first-page-of-report as logical              no-undo .
  define variable v-is-find-not-binded-gds  as logical              no-undo .
  define variable Counter1 as integer   no-undo .

  if p-doc-list <> "" then do:
    define variable ii as integer   no-undo .
    DO ii = 1 TO NUM-ENTRIES(p-doc-list):
      FIND FIRST buf_trn-doc no-lock  WHERE recid(buf_trn-doc) = INTEGER( ENTRY(ii, p-doc-list)) .
      if available buf_trn-doc then do:
        create tt-doc .
        assign tt-doc.doc-code = buf_trn-doc.doc-code .
      end.
    end.
  end.

/* frames */
  define frame f-alc-retail
    sym1                         no-label format "X(1)"                          space(0)
    tt-alc-retail.alc-type-name  no-label format "X({&f-alc-type-name})"         space(0)
    sym2                         no-label format "X(1)"                          space(0)
/*    tt-alc-retail.alc-type-code       no-label format ">>>>9"                         space(0)*/
    tt-alc-retail.alc-type-code  no-label format "X(5)"                          space(0)
    sym3                         no-label format "X(1)"                          space(0)
    tt-alc-retail.ost-beg-tot    no-label format {&dal-frmt}                     space(0)
    sym4                         no-label format "X(1)"                          space(0)
    tt-alc-retail.ost-beg-local  no-label format {&dal-frmt}                     space(0)
    sym5                         no-label format "X(1)"                          space(0)
    tt-alc-retail.ost-beg-region no-label format {&dal-frmt}                     space(0)
    sym6                         no-label format "X(1)"                          space(0)
    tt-alc-retail.ost-beg-imp    no-label format {&dal-frmt}                     space(0)
    sym7                         no-label format "X(1)"                          space(0)
    tt-alc-retail.pri-tot        no-label format {&dal-frmt}                     space(0)
    sym8                         no-label format "X(1)"                          space(0)
    tt-alc-retail.pri-local      no-label format {&dal-frmt}                     space(0)
    sym9                         no-label format "X(1)"                          space(0)
    tt-alc-retail.pri-region     no-label format {&dal-frmt}                     space(0)
    sym10                        no-label format "X(1)"                          space(0)
    tt-alc-retail.pri-imp        no-label format {&dal-frmt}                     space(0)
    sym11                        no-label format "X(1)"                          space(0)
    tt-alc-retail.sale-tot       no-label format {&dal-frmt}                     space(0)
    sym12                        no-label format "X(1)"                          space(0)
    tt-alc-retail.sale-local     no-label format {&dal-frmt}                     space(0)
    sym13                        no-label format "X(1)"                          space(0)
    tt-alc-retail.sale-region    no-label format {&dal-frmt}                     space(0)
    sym14                        no-label format "X(1)"                          space(0)
    tt-alc-retail.sale-imp       no-label format {&dal-frmt}                     space(0)
    sym15                        no-label format "X(1)"                          space(0)
    tt-alc-retail.ret-tot        no-label format {&dal-frmt}                     space(0)
    sym16                        no-label format "X(1)"                          space(0)
    tt-alc-retail.ret-local      no-label format {&dal-frmt}                     space(0)
    sym17                        no-label format "X(1)"                          space(0)
    tt-alc-retail.ret-region     no-label format {&dal-frmt}                     space(0)
    sym18                        no-label format "X(1)"                          space(0)
    tt-alc-retail.ret-imp        no-label format {&dal-frmt}                     space(0)
    sym19                        no-label format "X(1)"                          space(0)
    tt-alc-retail.oth-tot        no-label format {&dal-frmt}                     space(0)
    sym20                        no-label format "X(1)"                          space(0)
    tt-alc-retail.oth-local      no-label format {&dal-frmt}                     space(0)
    sym21                        no-label format "X(1)"                          space(0)
    tt-alc-retail.oth-region     no-label format {&dal-frmt}                     space(0)
    sym22                        no-label format "X(1)"                          space(0)
    tt-alc-retail.oth-imp        no-label format {&dal-frmt}                     space(0)
    sym23                        no-label format "X(1)"                          space(0)
    tt-alc-retail.ost-end-tot    no-label format {&dal-frmt}                     space(0)
    sym24                        no-label format "X(1)"                          space(0)
    tt-alc-retail.ost-end-local  no-label format {&dal-frmt}                     space(0)
    sym25                        no-label format "X(1)"                          space(0)
    tt-alc-retail.ost-end-region no-label format {&dal-frmt}                     space(0)
    sym26                        no-label format "X(1)"                          space(0)
    tt-alc-retail.ost-end-imp    no-label format {&dal-frmt}                     space(0)
    sym27                        no-label format "X(1)"                          space(0)
  header
    (if v-is-first-page-of-report then "1. Сведения о розничной продаже алкогольной продукции" else "" ) format "X(60)" at 40 skip
    "+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+" skip
    "|          Наименование        | Код | Остаток на начало отчетного   | Поступило за отчетный период  | Продано за отчетный период    |           Возврат             |            Прочее             |  Остаток на конец отчетного   |" skip
    "|        видов алкогольной     |алко-|    периода (декалитров)       |            (декалитров)       |       (декалитров)            |                               |                               |      периода (декалитрах)     |" skip
    "|            продукции         |голь-|-------------------------------+-------------------------------+-------------------------------+-------------------------------+-------------------------------+-------------------------------+" skip
    "|                              |ной  | Всего |      в том числе      | Всего |      в том числе      | Всего |      в том числе      | Всего |      в том числе      | Всего |      в том числе      | Всего |      в том числе      |" skip
    "|                              |про- |-------+-----------------------+-------+-----------------------+-------+-----------------------+-------+-----------------------+-------+-----------------------+-------+-----------------------+" skip
    "|                              |дук- |       |произв.|ввезен.|импорт-|       |произв.|ввезен.|импорт-|       |произв.|ввезен.|импорт-|       |произв.|ввезен.|импорт-|       |произв.|ввезен.|импорт-|       |произв.|ввезен.|импорт-|" skip
    "|                              |ции  |       |  в    | из др.| ный   |       |  в    | из др.| ный   |       |  в    | из др.| ный   |       |  в    | из др.| ный   |       |  в    | из др.| ный   |       |  в    | из др.| ный   |" skip
    "|                              |     |       |Калужск| суб-ов|       |       |Калужск| суб-ов|       |       |Калужск| суб-ов|       |       |Калужск| суб-ов|       |       |Калужск| суб-ов|       |       |Калужск| суб-ов|       |" skip
    "|                              |     |       |области|   РФ  |       |       |области|   РФ  |       |       |области|   РФ  |       |       |области|   РФ  |       |       |области|   РФ  |       |       |области|   РФ  |       |" skip
    "|------------------------------+-----+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+" skip
  with width {&DOS_CW_2} down stream-io no-labels no-box.

/*  form header*/
/*          fill( "-" , {&f-alc-retail-width} ) format "X({&f-alc-retail-width})" at 1 SKIP*/
/*          "Продолжение - на следующей странице" at 1 SKIP*/
/*  with frame BottomPriFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .*/

  define frame f-alc-pri
    sym1                        no-label format "X(1)"                          space(0)
    tt-alc-pri.cli-name         no-label format "X({&f-w-fmtcli-name})"         space(0)
    sym2                        no-label format "X(1)"                          space(0)
    tt-alc-pri.cli-inn          no-label format "X({&f-w-fmtcli-inn})"          space(0)
    sym3                        no-label format "X(1)"                          space(0)
    tt-alc-pri.cli-address      no-label format "X({&f-w-fmtcli-post-addres})"  space(0)
    sym4                        no-label format "X(1)"                          space(0)
    tt-alc-pri.cli-region-code  no-label format "X({&f-w-cli-region-code})"     space(0)
    sym5                        no-label format "X(1)"                          space(0)
    tt-alc-pri.lic-num          no-label format "X({&f-w-sert})"                space(0)
    sym6                        no-label format "X(1)"                          space(0)
    tt-alc-pri.lic-give         no-label format "X({&f-w-sert-give})"           space(0)
    sym7                        no-label format "X(1)"                          space(0)
    tt-alc-pri.doc-num-date     no-label format "X({&f-w-doc-num-date})"        space(0)
    sym8                        no-label format "X(1)"                          space(0)
    v-alc-type-name                  no-label format "X({&f-w-alc-type-name})"            space(0)
    sym9                        no-label format "X(1)"                          space(0)
    tt-alc-pri.alc-type-code         no-label format ">>>>>>999"                     space(0)
    sym10                       no-label format "X(1)"                          space(0)
    tt-alc-pri.prod-type        no-label format ">>>>9"                         space(0)
    sym11                       no-label format "X(1)"                          space(0)
    tt-alc-pri.quantity-str     no-label format "X({&dal-format-len})"          space(0)
    sym12                       no-label format "X(1)"                          space(0)
  header
    (if v-is-first-page-of-report then "2. Сведения о поставщиках алкогольной продукции" else "" ) format "X(60)" at 40 skip
    "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" skip
    ": Наименование                 :      {&abbr_inn_allshift}      :           Юридический             :   Код   :           Лицензия                 :    Дата отгрузки   :       Наименование      :   Код   : Производитель:  Объем в   :" skip
    ":  поставщика                  :   поставщика  :             адрес                 :субъектов:------------------------------------:        номер       :          видов          :продукции:    (1,2,3)   : декалитрах :" skip
    ":                              :               :           поставщика              :   РФ    :     Серия,    :        кем         :    товарно-транс-  :       алкогольной       :         :см. примечание:            :" skip
    ":                              :               :                                   :         :     номер,    :       выдана       :      портного      :        продукции        :         :              :            :" skip
    ":                              :               :                                   :         :     дата      :                    :      документа     :                         :         :              :            :" skip
    ":                              :               :                                   :         :     выдачи,   :                    :                    :                         :         :              :            :" skip
    ":                              :               :                                   :         :     срок      :                    :                    :                         :         :              :            :" skip
    ":                              :               :                                   :         :   действия    :                    :                    :                         :         :              :            :" skip
    ":------------------------------:---------------:-----------------------------------:---------:---------------:--------------------:--------------------:-------------------------:---------:--------------:------------:" skip
  with width {&DOS_CW_2} down stream-io no-labels no-box.

  form header
          fill( "-" , {&f-alc-pri-width} ) format "X({&f-alc-pri-width})" at 1 SKIP
          "Продолжение - на следующей странице" at 1 SKIP
  with frame BottomPriFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .

do
  on error  undo , return error return-value
  on endkey undo , return error return-value
  on stop   undo , return error return-value
:

  { gbl/working.i }
  run alcdclxl-init in this-procedure.

  assign
    v-line        = fill( "-" , 300 )
  .

  define variable v-fact-order-start   as decimal   no-undo .
  define variable v-fact-order-end     as decimal   no-undo .
  run day-begin-fact-order in this-procedure ( input p-begin-date, output v-fact-order-start ). /*Поиск нач fact-order*/
  run day-begin-fact-order in this-procedure ( input ( p-end-date + 1 ),   output v-fact-order-end ). /*Поиск посл fact-order*/

  define variable num-obj as integer   no-undo .
  assign num-obj = 0 .
  for each  obj-list : assign num-obj = num-obj + 1 .  end.
  if num-obj = 0  then do:
    message  "Не определен объект для формирования отчета"   view-as alert-box information .
    return error.
  end.

  { cmp/open-out.i stream out-stream " " {&CS_PS} }

  /* печатаем первый лист */
  run print-enclosure in this-procedure .

  { rep/repfrm.i def } /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 100 } /* Показать окно информации о текущем процессе */

  assign Counter1  = 0 .
  run find-alc-goods in this-procedure .

  assign Counter1  = 0 .
  run print-alc-retail in this-procedure .
  view stream out-stream frame BottomFrame .

  assign Counter1  = 0 .
  run print-alc-pri in this-procedure .
  /* чистим временные таблички */
  run clear-temp-tables in this-procedure .

  { rep/repfrm.i off }
  /* закрываем потоки  */
  output stream out-stream close.

  { gbl/stopwork.i }

  if v-is-find-not-binded-gds = yes then do:
    message
      "При формировании отчета были найдены товары входящие в группу товаров алкоголь, но не привязанных к справочнику виды алкогольной продукции. " skip
      "Список товаров выведен в файл {&file-not-binded-gds}"
    view-as alert-box information.
  end.

  run alcdclxl-close in this-procedure .

  os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .
  os-rename
    value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
    value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )
  .

  /* печатаем */
  define variable v-user-action   as character no-undo .
  define variable v-printed       as logical   no-undo .
/*  define variable DisabledOptions as integer   no-undo .*/
/*  define variable v-orient-page as character no-undo .*/
/*  run How-name in this-procedure (*/
/*      input ReportPageHeight,*/
/*      input ReportPageWidth,*/
/*      output v-orient-page )*/
/*      .*/
/*  if v-orient-page = "A4-lans":U then DisabledOptions = 8 .*/
/*                                 else DisabledOptions = 0 .*/
  run gbl/prnfilen.w
      (input  ""
      ,input  8
      ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
      ,input  ReportFontNum
      ,output v-user-action
      ,output v-printed
      ) .
  os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .
end.


/* печать титульного (первого листа) */
procedure print-enclosure :

do
on error undo, return error return-value
:
  &scop l-border-pos 5
  &scop c-border-pos 85
  &scop r-border-pos 193
  &scop v-line-width 189

  define buffer buf_clients       for ub.clients.
  define buffer buf_alc-sale-lic  for ub.alc-sale-lic.

  define variable v-host-egrip-num  as character format "X(75)" no-undo .
  define variable v-host-egrip-date as character format "X(10)" no-undo .
  define variable v-sertificate     as character format "X(87)" no-undo .
  define variable v-org-address     as character format "X(87)" no-undo .
  define variable v-str             as character no-undo .
  define variable v-log-carret      as logical   no-undo .
  define variable v-host-egrip      as character format "X(87)" no-undo .

  find first obj-list no-lock no-error .
  { gbl/hostcode.i obj-list.obj-type obj-list.obj-code v-host-code }
  run fmtcli-get-client in this-procedure ( input  {&cmp}, input  v-host-code ) .
  run clntattr-value in this-procedure ( input {&cmp}, input v-host-code, input {&attr-egrip-date}, output v-host-egrip-date, output v-par-type).
  run clntattr-value in this-procedure ( input {&cmp}, input v-host-code, input {&attr-egrip-num} , output v-host-egrip-num , output v-par-type).
  assign
    v-host-egrip-date = string(date(v-host-egrip-date),"99/99/9999")
    v-str             = substitute("&1, &2", v-fmtcli-addres , v-fmtcli-phone)
    v-host-egrip      = ( if v-host-egrip-date = "?" then "" else v-host-egrip-date + ", " + v-host-egrip-num )
  .

  find first buf_clients no-lock where buf_clients.obj-type = {&cmp} and buf_clients.obj-code = v-host-code no-error .
  if not available buf_clients then do:
    message  substitute ("Не могу найти фирму с кодом: &1", v-host-code)  view-as alert-box error .
    return error.
  end.
   find first buf_alc-sale-lic
        where buf_alc-sale-lic.cli-type = buf_clients.obj-type
          and buf_alc-sale-lic.cli-code = buf_clients.obj-code
          and buf_alc-sale-lic.date-to  > p-end-date
         no-lock
         no-error
         .
  if available buf_alc-sale-lic then do:
      assign
        v-sertificate = substitute( "серия&1 №&2 выдана &3 c &4 по &5"
                                  , buf_alc-sale-lic.seria
                                  , buf_alc-sale-lic.number
                                  , buf_alc-sale-lic.who-are-got
                                  , string( buf_alc-sale-lic.date-from , "99/99/9999")
                                  , string( buf_alc-sale-lic.date-to , "99/99/9999")
                                  )
      .
  end.
  else do:
    assign
      v-sertificate = ""
    .
  end.

  put stream out-stream
    "Приложение № 2":U at 180 skip
    "к приказу":U at 185 skip
    "Центра по лицензированию Калужской области":U at 152 skip
    "от 21 апреля 2006 г. N 114":U at 168 skip(2)
    "Данные об организации":U at {&l-border-pos} skip (1)
    v-line format "X({&v-line-width})" at {&l-border-pos} skip
    ": Наименование" at {&l-border-pos} ":" at {&c-border-pos} v-fmtcli-name format "X(87)" ":" at {&r-border-pos}
    v-line format "X({&v-line-width})" at {&l-border-pos} skip
    ": {&abbr_inn_allshift}" at {&l-border-pos} ":" at {&c-border-pos} v-fmtcli-inn format "X(87)" ":" at {&r-border-pos}
    v-line format "X({&v-line-width})" at {&l-border-pos} skip
    ": Дата внесения и номер в Единый " at {&l-border-pos} ":" at {&c-border-pos} v-host-egrip ":" at {&r-border-pos}
    ": государственный реестр юридических лицр " at {&l-border-pos} ":" at {&c-border-pos} ":" at {&r-border-pos}

    v-line format "X({&v-line-width})" at {&l-border-pos} skip
  .

  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-orgname}, input v-fmtcli-name ).
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-orghinn}, input v-fmtcli-inn ).
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-hostegrip}, input v-host-egrip ).
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-addr}, input v-str ).
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sertificate}, input v-sertificate ).

  do while v-str <> ""  :
    assign
      v-org-address = substring(v-str, 1 , 87)
      v-str         = substring(v-str, 87 , length(v-str))
    .
    if v-log-carret then do:
      put stream out-stream  ":" at {&l-border-pos} ":" at {&c-border-pos} v-org-address ":" at {&r-border-pos} .
    end.
    else do:
      put stream out-stream ": Место нахождения организации, телефон" at {&l-border-pos} ":" at {&c-border-pos} v-org-address ":" at {&r-border-pos} .
      assign v-log-carret = yes .
    end.
  end.
  put stream out-stream v-line format "X({&v-line-width})" at {&l-border-pos} skip.

  put stream out-stream
    ": Количество обособленных подразделений (торговых объектов)" at {&l-border-pos}  ":" at {&c-border-pos}  ":" at {&r-border-pos} skip
    ": и (или) общественного питания, их адреса" at {&l-border-pos}  ":" at {&c-border-pos}  ":" at {&r-border-pos} skip
    v-line format "X({&v-line-width})" at {&l-border-pos} skip
   .

  put stream out-stream
    ": Серия, номер бланка, регистрационный номер," at {&l-border-pos}
    ":" at {&c-border-pos}
    v-sertificate
    ":" at {&r-border-pos}
    ": срок действия лицензии, кем выдана" at {&l-border-pos}
    ":" at {&c-border-pos}
    ":" at {&r-border-pos}
    v-line format "X({&v-line-width})" at {&l-border-pos} skip
  .

  page stream out-stream.
  down stream out-stream 1 .
end.
end procedure. /* print-enclosure */


/*
  заполнение временных табличек с типами алкоголя и связанных с ними товаров
*/
procedure find-alc-goods :

do
on error undo, return error return-value
:
  define buffer buf_alc-type      for ub.alc-type.
  define buffer buf_alc-type-gds  for ub.alc-type-gds.
  define buffer buf_goods         for ub.goods.

  define frame f-nbgoods
        buf_goods.artic     no-label format "X(10)"     space(0)
        buf_goods.prod-code no-label format ">>>>>>>>9" space(0)
        buf_goods.prod-type no-label format "X(10)"     space(0)
        buf_goods.gds-name  no-label format "X(40)"     space(0)
  with width {&DOS_CW_2} down stream-io no-labels no-box.

  define variable v-gds-grp-code  as integer   no-undo .

  /* заполняем список алкогольных товаров */
  empty temp-table tt-gds.
  empty temp-table tt-alc-type.

  for each buf_alc-type no-lock :
    create tt-alc-type.
    buffer-copy buf_alc-type to tt-alc-type.
    for each buf_alc-type-gds no-lock where buf_alc-type-gds.alc-type-inner-code = buf_alc-type.alc-type-inner-code
      , first buf_goods no-lock where buf_goods.gds-code = buf_alc-type-gds.gds-code
    :
      assign Counter1 = Counter1 + 1.
      { rep/repfrm.i disp Counter1 "'Заполняем список алкогольных товаров'" }

      find first tt-gds no-lock where tt-gds.gds-code = buf_goods.gds-code no-error .
      if not available tt-gds then do:
        create tt-gds.
        buffer-copy buf_goods to tt-gds .
        assign
          tt-gds.alc-type-code = buf_alc-type.alc-type-code
          tt-gds.alc-type-name = buf_alc-type.alc-type-name
          tt-gds.alc-type-inner-code = buf_alc-type.alc-type-inner-code
/*          tt-gds.list_    = buf_alc-type.list_*/
        .
      end.
    end.
  end.
{ gbl/getsect.i run "''"  0 {&attr-report-glob}}

for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'alcgrpgd' then  v-par-val =  string(thbjattr_thbj-attr.property-value-integer) .
end.

  /* сверяемся с группой товаров алкоголь */
  assign
    v-gds-grp-code = integer(v-par-val)
  .

  for each buf_goods no-lock
    where buf_goods.grp-code = v-gds-grp-code
  :
    /* проверяем заведен ли этот товар через виды алк. продукции */
    find first tt-gds no-lock where tt-gds.gds-code = buf_goods.gds-code no-error .
    /*
      если товар не заведен, то выводим предупреждение и выводим в файл те товары
      что не заведены через справочник виды алк. продукции
    */

    assign Counter1 = Counter1 + 1.
    { rep/repfrm.i disp Counter1 "'Заполняем список алкогольных товаров'" }

    if not available tt-gds then do:
      /* открываем поток */
      if v-is-find-not-binded-gds = no then do:
        output to value ("{&file-not-binded-gds}").
      end.
      assign v-is-find-not-binded-gds = yes .
      display  buf_goods.artic " "   buf_goods.prod-code " "    buf_goods.prod-type " "   buf_goods.gds-name  with frame f-nbgoods.
      down 1.
    end.
  end. /* for each buf_goods */
  output close.
end.

end procedure. /* find-alc-goods */


/*
  Нахождение номера сертификата и кем он выдан клиенту.
*/
procedure find-sert :

define input  parameter p-cli-type            like ub.trn-doc.cli-type no-undo .
define input  parameter p-cli-code            like ub.trn-doc.cli-code no-undo .
define input  parameter p-alc-type-inner-code like ub.alc-type.alc-type-inner-code .
define output parameter p-sert      as character          no-undo .
define output parameter p-sert-give as character          no-undo .

define buffer buf_alc-supp-lic      for ub.alc-supp-lic.
define buffer buf_alc-supp-lic-type for ub.alc-supp-lic-type.

do
on error undo, return error return-value
:

  for each   buf_alc-supp-lic
       where buf_alc-supp-lic.cli-type = p-cli-type
         and buf_alc-supp-lic.cli-code = p-cli-code
         and buf_alc-supp-lic.date-to  > p-end-date
       no-lock
       :
       IF buf_alc-supp-lic.all-type = 0 then do:
          find first buf_alc-supp-lic-type
               where buf_alc-supp-lic-type.alc-supp-lic-code   = buf_alc-supp-lic.alc-supp-lic-code
               and buf_alc-supp-lic-type.alc-type-inner-code = p-alc-type-inner-code
               no-lock
               no-error.
          if not available buf_alc-supp-lic-type then do:
             next.
          end.
      end.
      assign
        p-sert       =  substitute( "серия &1 № &2 выдана &3 c &4 по &5"
                                  , buf_alc-supp-lic.seria
                                  , buf_alc-supp-lic.number
                                  )
        p-sert-give  = substitute( "выдана &3 c &4 по &5"
                                  , buf_alc-supp-lic.who-are-got
                                  , string( buf_alc-supp-lic.date-from , "99/99/9999")
                                  , string( buf_alc-supp-lic.date-to , "99/99/9999")
                                  )
      .
      return.
  end. /* for each */
end.
end procedure. /* find-sert */


function str-format returns character (val as decimal , v-format as char, v-str-len as integer):
  define variable v-str as character no-undo .
  assign
    v-str = ( if val = 0 then {&stroke} else replace( trim(string( val , v-format )) , "." , "," ) )
  .
  if length(v-str) < v-str-len then do:
    assign
      v-str = fill(" ", v-str-len - length(v-str)) + v-str
    .
  end.
  return v-str.
end function.


/*
  формирование временной таблички по продаже алкогольной продукции
*/
procedure create-tt-alc-retail :

do
on error undo, return error return-value
:
  empty temp-table tt-alc-retail.
  define buffer buf_doc-line for ub.doc-line.

  for each tt-alc-type :
    create tt-alc-retail.
    assign
      tt-alc-retail.alc-type-code = tt-alc-type.alc-type-code
      tt-alc-retail.alc-type-name = tt-alc-type.alc-type-name
/*      tt-alc-retail.sea-list = tt-alc-type.list_*/
    .
  end.

  for each tt-gds :
    run get-cli-type in this-procedure ( input tt-gds.prod-code, input tt-gds.prod-type, output v-producer ).
    find first tt-alc-retail where tt-alc-retail.alc-type-code = tt-gds.alc-type-code no-error .
    if not available tt-alc-retail then do:
      create tt-alc-retail.
      assign
        tt-alc-retail.alc-type-code = tt-gds.alc-type-code
        tt-alc-retail.alc-type-name = tt-gds.alc-type-name
        tt-alc-retail.sea-list = tt-gds.list_
      .
    end.
    for each obj-list :
      assign Counter1 = Counter1 + 1.
      { rep/repfrm.i disp Counter1 "'Формирование декларации об объемах розничной продажи...'" }

      /* обсчитываем остатки на начало */
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = obj-list.obj-type
          and buf_stk-line.obj-code  = obj-list.obj-code
          and buf_stk-line.artic     = tt-gds.artic
          and buf_stk-line.prod-type = tt-gds.prod-type
          and buf_stk-line.prod-code = tt-gds.prod-code
          and buf_stk-line.sum-type  = {&arh-cost}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order < v-fact-order-start
      use-index category no-error .
      if available buf_stk-line then do:
        case v-producer :
          when {&local} then   assign tt-alc-retail.ost-beg-local  = tt-alc-retail.ost-beg-local  + (buf_stk-line.fact-qnty * tt-gds.ms-base / 10 ) .
          when {&region} then  assign tt-alc-retail.ost-beg-region = tt-alc-retail.ost-beg-region + (buf_stk-line.fact-qnty * tt-gds.ms-base / 10 ) .
          when {&foreign} then assign tt-alc-retail.ost-beg-imp    = tt-alc-retail.ost-beg-imp    + (buf_stk-line.fact-qnty * tt-gds.ms-base / 10 ) .
        end case.
      end.

      define variable v-qnty as decimal   no-undo .
      /* обсчитываем поступления, продажу, возврат, прочее */
      /*  поступления */
      run CalcOborot in this-procedure  ( input {&TDEDT_Pri_Vnesh},output v-qnty) .
      case v-producer :
        when {&local} then   assign tt-alc-retail.pri-local  = tt-alc-retail.pri-local  + (v-qnty * tt-gds.ms-base / 10 ) .
        when {&region} then  assign tt-alc-retail.pri-region = tt-alc-retail.pri-region + (v-qnty * tt-gds.ms-base / 10 ) .
        when {&foreign} then assign tt-alc-retail.pri-imp    = tt-alc-retail.pri-imp    + (v-qnty * tt-gds.ms-base / 10 ) .
      end case.
      if num-obj = 1 then run CalcOborot  in this-procedure ( input {&TDEDT_Pri_Perem},output v-qnty)  .
      else                run CalcOborot1 in this-procedure ( input {&TDEDT_Pri_Perem},output v-qnty)  .
      case v-producer :
        when {&local} then   assign tt-alc-retail.pri-local  = tt-alc-retail.pri-local  + (v-qnty * tt-gds.ms-base / 10 ) .
        when {&region} then  assign tt-alc-retail.pri-region = tt-alc-retail.pri-region + (v-qnty * tt-gds.ms-base / 10 ) .
        when {&foreign} then assign tt-alc-retail.pri-imp    = tt-alc-retail.pri-imp    + (v-qnty * tt-gds.ms-base / 10 ) .
      end case.
      if num-obj = 1 then run CalcOborot  in this-procedure ( input {&TDEDT_Vozvrat_Perem},output v-qnty)  .
      else                run CalcOborot1 in this-procedure ( input {&TDEDT_Vozvrat_Perem},output v-qnty)  .
      case v-producer :
        when {&local} then   assign tt-alc-retail.pri-local  = tt-alc-retail.pri-local  + (v-qnty * tt-gds.ms-base / 10 ) .
        when {&region} then  assign tt-alc-retail.pri-region = tt-alc-retail.pri-region + (v-qnty * tt-gds.ms-base / 10 ) .
        when {&foreign} then assign tt-alc-retail.pri-imp    = tt-alc-retail.pri-imp    + (v-qnty * tt-gds.ms-base / 10 ) .
      end case.
      /*  продажу */
      run CalcOborot in this-procedure ( input {&TDEDT_Ras_Vnesh_Kass},output v-qnty)  .
      case v-producer :
        when {&local} then   assign tt-alc-retail.sale-local  = tt-alc-retail.sale-local  + abs(v-qnty * tt-gds.ms-base / 10 ) .
        when {&region} then  assign tt-alc-retail.sale-region = tt-alc-retail.sale-region + abs(v-qnty * tt-gds.ms-base / 10 ) .
        when {&foreign} then assign tt-alc-retail.sale-imp    = tt-alc-retail.sale-imp    + abs(v-qnty * tt-gds.ms-base / 10 ) .
      end case.
      /*  возврат */
      run CalcOborot in this-procedure ( input {&TDEDT_Vozvrat_Vnesh_Kass},output v-qnty)  .
      case v-producer :
        when {&local} then   assign tt-alc-retail.ret-local  = tt-alc-retail.ret-local  + (v-qnty * tt-gds.ms-base / 10 ) .
        when {&region} then  assign tt-alc-retail.ret-region = tt-alc-retail.ret-region + (v-qnty * tt-gds.ms-base / 10 ) .
        when {&foreign} then assign tt-alc-retail.ret-imp    = tt-alc-retail.ret-imp    + (v-qnty * tt-gds.ms-base / 10 ) .
      end case.
      /*  прочее */
      run CalcOborot in this-procedure ( input {&TDEDT_vozvrat_vnesh},output v-qnty)  .
      case v-producer :
        when {&local} then   assign tt-alc-retail.oth-local  = tt-alc-retail.oth-local  - (v-qnty * tt-gds.ms-base / 10 ) .
        when {&region} then  assign tt-alc-retail.oth-region = tt-alc-retail.oth-region - (v-qnty * tt-gds.ms-base / 10 ) .
        when {&foreign} then assign tt-alc-retail.oth-imp    = tt-alc-retail.oth-imp    - (v-qnty * tt-gds.ms-base / 10 ) .
      end case.
      run CalcOborot in this-procedure ( input {&TDEDT_Inv},output v-qnty)  .
      case v-producer :
        when {&local} then   assign tt-alc-retail.oth-local  = tt-alc-retail.oth-local  - (v-qnty * tt-gds.ms-base / 10 ) .
        when {&region} then  assign tt-alc-retail.oth-region = tt-alc-retail.oth-region - (v-qnty * tt-gds.ms-base / 10 ) .
        when {&foreign} then assign tt-alc-retail.oth-imp    = tt-alc-retail.oth-imp    - (v-qnty * tt-gds.ms-base / 10 ) .
      end case.
      run CalcOborot in this-procedure ( input {&TDEDT_Peresort},output v-qnty)  .
      case v-producer :
        when {&local} then   assign tt-alc-retail.oth-local  = tt-alc-retail.oth-local  - (v-qnty * tt-gds.ms-base / 10 ) .
        when {&region} then  assign tt-alc-retail.oth-region = tt-alc-retail.oth-region - (v-qnty * tt-gds.ms-base / 10 ) .
        when {&foreign} then assign tt-alc-retail.oth-imp    = tt-alc-retail.oth-imp    - (v-qnty * tt-gds.ms-base / 10 ) .
      end case.
      run CalcOborot in this-procedure ( input {&TDEDT_Ras_Vnesh},output v-qnty)  .
      case v-producer :
        when {&local} then   assign tt-alc-retail.oth-local  = tt-alc-retail.oth-local  + abs(v-qnty * tt-gds.ms-base / 10 ) .
        when {&region} then  assign tt-alc-retail.oth-region = tt-alc-retail.oth-region + abs(v-qnty * tt-gds.ms-base / 10 ) .
        when {&foreign} then assign tt-alc-retail.oth-imp    = tt-alc-retail.oth-imp    + abs(v-qnty * tt-gds.ms-base / 10 ) .
      end case.
      if num-obj = 1 then run CalcOborot  in this-procedure ( input {&TDEDT_Ras_Perem},output v-qnty)  .
      else                run CalcOborot1 in this-procedure ( input {&TDEDT_Ras_Perem},output v-qnty)  .
      case v-producer :
        when {&local} then   assign tt-alc-retail.oth-local  = tt-alc-retail.oth-local  + abs(v-qnty * tt-gds.ms-base / 10 ) .
        when {&region} then  assign tt-alc-retail.oth-region = tt-alc-retail.oth-region + abs(v-qnty * tt-gds.ms-base / 10 ) .
        when {&foreign} then assign tt-alc-retail.oth-imp    = tt-alc-retail.oth-imp    + abs(v-qnty * tt-gds.ms-base / 10 ) .
      end case.
      run CalcOborot in this-procedure ( input {&TDEDT_Ras_Vnesh_VP},output v-qnty)  .
      case v-producer :
        when {&local} then   assign tt-alc-retail.oth-local  = tt-alc-retail.oth-local  + abs(v-qnty * tt-gds.ms-base / 10 ) .
        when {&region} then  assign tt-alc-retail.oth-region = tt-alc-retail.oth-region + abs(v-qnty * tt-gds.ms-base / 10 ) .
        when {&foreign} then assign tt-alc-retail.oth-imp    = tt-alc-retail.oth-imp    + abs(v-qnty * tt-gds.ms-base / 10 ) .
      end case.
      run CalcOborot in this-procedure ( input {&TDEDT_Spi_Vnesh},output v-qnty)  .
      case v-producer :
        when {&local} then   assign tt-alc-retail.oth-local  = tt-alc-retail.oth-local  + abs(v-qnty * tt-gds.ms-base / 10 ) .
        when {&region} then  assign tt-alc-retail.oth-region = tt-alc-retail.oth-region + abs(v-qnty * tt-gds.ms-base / 10 ) .
        when {&foreign} then assign tt-alc-retail.oth-imp    = tt-alc-retail.oth-imp    + abs(v-qnty * tt-gds.ms-base / 10 ) .
      end case.
      run CalcOborot in this-procedure  ( input {&TDEDT_Pri_Prvo},output v-qnty) .
      case v-producer :
        when {&local} then   assign tt-alc-retail.oth-local  = tt-alc-retail.oth-local  - abs(v-qnty * tt-gds.ms-base / 10 ) .
        when {&region} then  assign tt-alc-retail.oth-region = tt-alc-retail.oth-region - abs(v-qnty * tt-gds.ms-base / 10 ) .
        when {&foreign} then assign tt-alc-retail.oth-imp    = tt-alc-retail.oth-imp    - abs(v-qnty * tt-gds.ms-base / 10 ) .
      end case.
      run CalcOborot in this-procedure ( input {&TDEDT_Ras_Prvo},output v-qnty)  .
      case v-producer :
        when {&local} then   assign tt-alc-retail.oth-local  = tt-alc-retail.oth-local  + abs(v-qnty * tt-gds.ms-base / 10 ) .
        when {&region} then  assign tt-alc-retail.oth-region = tt-alc-retail.oth-region + abs(v-qnty * tt-gds.ms-base / 10 ) .
        when {&foreign} then assign tt-alc-retail.oth-imp    = tt-alc-retail.oth-imp    + abs(v-qnty * tt-gds.ms-base / 10 ) .
      end case.
      run CalcOborot in this-procedure ( input {&TDEDT_Spi_Prvo},output v-qnty)  .
      case v-producer :
        when {&local} then   assign tt-alc-retail.oth-local  = tt-alc-retail.oth-local  + abs(v-qnty * tt-gds.ms-base / 10 ) .
        when {&region} then  assign tt-alc-retail.oth-region = tt-alc-retail.oth-region + abs(v-qnty * tt-gds.ms-base / 10 ) .
        when {&foreign} then assign tt-alc-retail.oth-imp    = tt-alc-retail.oth-imp    + abs(v-qnty * tt-gds.ms-base / 10 ) .
      end case.
    end.
    /* смотрим исключенные документы */
    for each tt-doc :
      find first buf_doc-line no-lock
        where buf_doc-line.doc-code  = tt-doc.doc-code
          and buf_doc-line.artic     = tt-gds.artic
          and buf_doc-line.prod-type = tt-gds.prod-type
          and buf_doc-line.prod-code = tt-gds.prod-code
      no-error .
      if not available buf_doc-line then next .
      case buf_doc-line.ext-doc-type :
        when  {&TDEDT_Pri_Vnesh} or
        when  {&TDEDT_Pri_Perem} or
        when  {&TDEDT_Vozvrat_Perem} then do:
          case v-producer :
            when {&local} then   assign tt-alc-retail.pri-local  = tt-alc-retail.pri-local  - (buf_doc-line.fact-qnty * tt-gds.ms-base / 10 ) .
            when {&region} then  assign tt-alc-retail.pri-region = tt-alc-retail.pri-region - (buf_doc-line.fact-qnty * tt-gds.ms-base / 10 ) .
            when {&foreign} then assign tt-alc-retail.pri-imp    = tt-alc-retail.pri-imp    - (buf_doc-line.fact-qnty * tt-gds.ms-base / 10 ) .
          end case.
        end.
        when {&TDEDT_Ras_Vnesh_Kass} then do:
          case v-producer :
            when {&local} then   assign tt-alc-retail.sale-local  = tt-alc-retail.sale-local  - (buf_doc-line.fact-qnty * tt-gds.ms-base / 10 ) .
            when {&region} then  assign tt-alc-retail.sale-region = tt-alc-retail.sale-region - (buf_doc-line.fact-qnty * tt-gds.ms-base / 10 ) .
            when {&foreign} then assign tt-alc-retail.sale-imp    = tt-alc-retail.sale-imp    - (buf_doc-line.fact-qnty * tt-gds.ms-base / 10 ) .
          end case.
        end.
        when {&TDEDT_Vozvrat_Vnesh_Kass} then do:
          case v-producer :
            when {&local} then   assign tt-alc-retail.ret-local  = tt-alc-retail.ret-local  - (buf_doc-line.fact-qnty * tt-gds.ms-base / 10 ) .
            when {&region} then  assign tt-alc-retail.ret-region = tt-alc-retail.ret-region - (buf_doc-line.fact-qnty * tt-gds.ms-base / 10 ) .
            when {&foreign} then assign tt-alc-retail.ret-imp    = tt-alc-retail.ret-imp    - (buf_doc-line.fact-qnty * tt-gds.ms-base / 10 ) .
          end case.
        end.
        when {&TDEDT_vozvrat_vnesh} or
        when  {&TDEDT_Pri_Prvo} then do:
          case v-producer :
            when {&local} then   assign tt-alc-retail.oth-local  = tt-alc-retail.oth-local  + (buf_doc-line.fact-qnty * tt-gds.ms-base / 10 ) .
            when {&region} then  assign tt-alc-retail.oth-region = tt-alc-retail.oth-region + (buf_doc-line.fact-qnty * tt-gds.ms-base / 10 ) .
            when {&foreign} then assign tt-alc-retail.oth-imp    = tt-alc-retail.oth-imp    + (buf_doc-line.fact-qnty * tt-gds.ms-base / 10 ) .
          end case.
        end.
        when {&TDEDT_Inv} or
        when {&TDEDT_Peresort}  then do:
          case v-producer :
            when {&local} then   assign tt-alc-retail.oth-local  = tt-alc-retail.oth-local  + (buf_doc-line.fact-qnty * tt-gds.ms-base / 10 ) .
            when {&region} then  assign tt-alc-retail.oth-region = tt-alc-retail.oth-region + (buf_doc-line.fact-qnty * tt-gds.ms-base / 10 ) .
            when {&foreign} then assign tt-alc-retail.oth-imp    = tt-alc-retail.oth-imp    + (buf_doc-line.fact-qnty * tt-gds.ms-base / 10 ) .
          end case.
        end.
        when {&TDEDT_Ras_Prvo} or
        when {&TDEDT_Spi_Prvo} or
        when {&TDEDT_Ras_Perem} or
        when {&TDEDT_Ras_Vnesh} or
        when {&TDEDT_Ras_Vnesh_VP} or
        when {&TDEDT_Spi_Vnesh} then do:
          case v-producer :
            when {&local} then   assign tt-alc-retail.oth-local  = tt-alc-retail.oth-local  - (buf_doc-line.fact-qnty * tt-gds.ms-base / 10 ) .
            when {&region} then  assign tt-alc-retail.oth-region = tt-alc-retail.oth-region - (buf_doc-line.fact-qnty * tt-gds.ms-base / 10 ) .
            when {&foreign} then assign tt-alc-retail.oth-imp    = tt-alc-retail.oth-imp    - (buf_doc-line.fact-qnty * tt-gds.ms-base / 10 ) .
          end case.
        end.
      end.
    end.

    /* вычисляем остаток на конец учетного периода  */
    assign
      tt-alc-retail.ost-beg-tot     = tt-alc-retail.ost-beg-local  + tt-alc-retail.ost-beg-region  + tt-alc-retail.ost-beg-imp
      tt-alc-retail.pri-tot         = tt-alc-retail.pri-local      + tt-alc-retail.pri-region      + tt-alc-retail.pri-imp
      tt-alc-retail.sale-tot        = tt-alc-retail.sale-local     + tt-alc-retail.sale-region     + tt-alc-retail.sale-imp
      tt-alc-retail.ret-tot         = tt-alc-retail.ret-local      + tt-alc-retail.ret-region      + tt-alc-retail.ret-imp
      tt-alc-retail.oth-tot         = tt-alc-retail.oth-local      + tt-alc-retail.oth-region      + tt-alc-retail.oth-imp
      tt-alc-retail.ost-end-local   = tt-alc-retail.ost-beg-local  + tt-alc-retail.pri-local       - tt-alc-retail.sale-local  + tt-alc-retail.ret-local  - tt-alc-retail.oth-local
      tt-alc-retail.ost-end-region  = tt-alc-retail.ost-beg-region + tt-alc-retail.pri-region      - tt-alc-retail.sale-region + tt-alc-retail.ret-region - tt-alc-retail.oth-region
      tt-alc-retail.ost-end-imp     = tt-alc-retail.ost-beg-imp    + tt-alc-retail.pri-imp         - tt-alc-retail.sale-imp    + tt-alc-retail.ret-imp    - tt-alc-retail.oth-imp
      tt-alc-retail.ost-end-tot     = tt-alc-retail.ost-beg-tot    + tt-alc-retail.pri-tot         - tt-alc-retail.sale-tot    + tt-alc-retail.ret-tot    - tt-alc-retail.oth-tot
    .
  end.
end.
end procedure. /* create-tt-alc-retail */


procedure print-alc-retail :

do
on error undo, return error return-value
:
  page stream out-stream.
  view stream out-stream frame TopPriFrame .
  view stream out-stream frame BottomPriFrame .
  define variable line-num as integer   no-undo .

  run create-tt-alc-retail in this-procedure .

  assign  v-is-first-page-of-report  = yes .
  for each tt-alc-retail no-lock break by tt-alc-retail.sea-list :
    assign Counter1 = Counter1 + 1.
    { rep/repfrm.i disp Counter1 "'Формирование декларации об объемах розничной продажи...'" }

    /* считаем итого */
    accumulate  tt-alc-retail.ost-beg-tot      (total) .
    accumulate  tt-alc-retail.ost-beg-local    (total) .
    accumulate  tt-alc-retail.ost-beg-region   (total) .
    accumulate  tt-alc-retail.ost-beg-imp      (total) .
    accumulate  tt-alc-retail.pri-tot          (total) .
    accumulate  tt-alc-retail.pri-local        (total) .
    accumulate  tt-alc-retail.pri-region       (total) .
    accumulate  tt-alc-retail.pri-imp          (total) .
    accumulate  tt-alc-retail.sale-tot         (total) .
    accumulate  tt-alc-retail.sale-local       (total) .
    accumulate  tt-alc-retail.sale-region      (total) .
    accumulate  tt-alc-retail.sale-imp         (total) .
    accumulate  tt-alc-retail.ret-tot          (total) .
    accumulate  tt-alc-retail.ret-local        (total) .
    accumulate  tt-alc-retail.ret-region       (total) .
    accumulate  tt-alc-retail.ret-imp          (total) .
    accumulate  tt-alc-retail.oth-tot          (total) .
    accumulate  tt-alc-retail.oth-local        (total) .
    accumulate  tt-alc-retail.oth-region       (total) .
    accumulate  tt-alc-retail.oth-imp          (total) .
    accumulate  tt-alc-retail.ost-end-tot      (total) .
    accumulate  tt-alc-retail.ost-end-local    (total) .
    accumulate  tt-alc-retail.ost-end-region   (total) .
    accumulate  tt-alc-retail.ost-end-imp      (total) .

    if v-is-first-page-of-report = yes and line-counter(out-stream) = page-size( out-stream) then do:
      assign v-is-first-page-of-report = no .
    end.

    /* выводим строку отчета */
    display stream out-stream
      tt-alc-retail.alc-type-name
      tt-alc-retail.alc-type-code
      tt-alc-retail.ost-beg-tot
      tt-alc-retail.ost-beg-local
      tt-alc-retail.ost-beg-region
      tt-alc-retail.ost-beg-imp
      tt-alc-retail.pri-tot
      tt-alc-retail.pri-local
      tt-alc-retail.pri-region
      tt-alc-retail.pri-imp
      tt-alc-retail.sale-tot
      tt-alc-retail.sale-local
      tt-alc-retail.sale-region
      tt-alc-retail.sale-imp
      tt-alc-retail.ret-tot
      tt-alc-retail.ret-local
      tt-alc-retail.ret-region
      tt-alc-retail.ret-imp
      tt-alc-retail.oth-tot
      tt-alc-retail.oth-local
      tt-alc-retail.oth-region
      tt-alc-retail.oth-imp
      tt-alc-retail.ost-end-tot
      tt-alc-retail.ost-end-local
      tt-alc-retail.ost-end-region
      tt-alc-retail.ost-end-imp
      sym1  sym2  sym3  sym4  sym5  sym6  sym7  sym8  sym9  sym10
      sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18 sym19 sym20
      sym21 sym22 sym23 sym24 sym25 sym26 sym27
    with frame f-alc-retail.
    down stream out-stream 1 with frame f-alc-retail.
    put stream out-stream unformatted fill( "-" , {&f-alc-retail-width} ) skip.

    run alcdclxl-sheet1-write-line-data (
        tt-alc-retail.alc-type-name
      , tt-alc-retail.alc-type-code
      , tt-alc-retail.ost-beg-tot
      , tt-alc-retail.ost-beg-local
      , tt-alc-retail.ost-beg-region
      , tt-alc-retail.ost-beg-imp
      , tt-alc-retail.pri-tot
      , tt-alc-retail.pri-local
      , tt-alc-retail.pri-region
      , tt-alc-retail.pri-imp
      , tt-alc-retail.sale-tot
      , tt-alc-retail.sale-local
      , tt-alc-retail.sale-region
      , tt-alc-retail.sale-imp
      , tt-alc-retail.ret-tot
      , tt-alc-retail.ret-local
      , tt-alc-retail.ret-region
      , tt-alc-retail.ret-imp
      , tt-alc-retail.oth-tot
      , tt-alc-retail.oth-local
      , tt-alc-retail.oth-region
      , tt-alc-retail.oth-imp
      , tt-alc-retail.ost-end-tot
      , tt-alc-retail.ost-end-local
      , tt-alc-retail.ost-end-region
      , tt-alc-retail.ost-end-imp
    ) .
    assign   line-num = line-num + 1 .
  end.

/*  put stream out-stream unformatted fill( "-" , {&f-alc-retail-width} ) skip.*/
  display stream out-stream
    " ИТОГО "                                      @  tt-alc-retail.alc-type-name
      accum total tt-alc-retail.ost-beg-tot        @  tt-alc-retail.ost-beg-tot
      accum total tt-alc-retail.ost-beg-local      @  tt-alc-retail.ost-beg-local
      accum total tt-alc-retail.ost-beg-region     @  tt-alc-retail.ost-beg-region
      accum total tt-alc-retail.ost-beg-imp        @  tt-alc-retail.ost-beg-imp
      accum total tt-alc-retail.pri-tot            @  tt-alc-retail.pri-tot
      accum total tt-alc-retail.pri-local          @  tt-alc-retail.pri-local
      accum total tt-alc-retail.pri-region         @  tt-alc-retail.pri-region
      accum total tt-alc-retail.pri-imp            @  tt-alc-retail.pri-imp
      accum total tt-alc-retail.sale-tot           @  tt-alc-retail.sale-tot
      accum total tt-alc-retail.sale-local         @  tt-alc-retail.sale-local
      accum total tt-alc-retail.sale-region        @  tt-alc-retail.sale-region
      accum total tt-alc-retail.sale-imp           @  tt-alc-retail.sale-imp
      accum total tt-alc-retail.ret-tot            @  tt-alc-retail.ret-tot
      accum total tt-alc-retail.ret-local          @  tt-alc-retail.ret-local
      accum total tt-alc-retail.ret-region         @  tt-alc-retail.ret-region
      accum total tt-alc-retail.ret-imp            @  tt-alc-retail.ret-imp
      accum total tt-alc-retail.oth-tot            @  tt-alc-retail.oth-tot
      accum total tt-alc-retail.oth-local          @  tt-alc-retail.oth-local
      accum total tt-alc-retail.oth-region         @  tt-alc-retail.oth-region
      accum total tt-alc-retail.oth-imp            @  tt-alc-retail.oth-imp
      accum total tt-alc-retail.ost-end-tot        @  tt-alc-retail.ost-end-tot
      accum total tt-alc-retail.ost-end-local      @  tt-alc-retail.ost-end-local
      accum total tt-alc-retail.ost-end-region     @  tt-alc-retail.ost-end-region
      accum total tt-alc-retail.ost-end-imp        @  tt-alc-retail.ost-end-imp
      sym1  sym2  sym3  sym4  sym5  sym6  sym7  sym8  sym9  sym10
      sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18 sym19 sym20
      sym21 sym22 sym23 sym24 sym25 sym26 sym27
  with frame f-alc-retail.
  down stream out-stream 1 with frame f-alc-retail.
  put stream out-stream unformatted fill( "-" , {&f-alc-retail-width} ) skip.

  put stream out-stream
    skip
    "             М.П."         "Руководитель организации__________________________________________" at 100 skip
    "        Дата_____________" "Главный бухгалтер_________________________________________________" at 100 skip
  .


&scop HeadSize  2
line-num = line-num + {&HeadSize} - 1 .

  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-ostbegtot   }, input "=SUM(C{&HeadSize}:C" + string(line-num ) + ")").
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-ostbeglocal }, input "=SUM(D{&HeadSize}:D" + string(line-num ) + ")").
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-ostbegregion}, input "=SUM(E{&HeadSize}:E" + string(line-num ) + ")").
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-ostbegimp   }, input "=SUM(F{&HeadSize}:F" + string(line-num ) + ")").
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-pritot      }, input "=SUM(G{&HeadSize}:G" + string(line-num ) + ")").
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-prilocal    }, input "=SUM(H{&HeadSize}:H" + string(line-num ) + ")").
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-priregion   }, input "=SUM(I{&HeadSize}:I" + string(line-num ) + ")").
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-priimp      }, input "=SUM(J{&HeadSize}:J" + string(line-num ) + ")").
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-saletot     }, input "=SUM(K{&HeadSize}:K" + string(line-num ) + ")").
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-salelocal   }, input "=SUM(L{&HeadSize}:L" + string(line-num ) + ")").
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-saleregion  }, input "=SUM(M{&HeadSize}:M" + string(line-num ) + ")").
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-saleimp     }, input "=SUM(N{&HeadSize}:N" + string(line-num ) + ")").
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-rettot      }, input "=SUM(O{&HeadSize}:O" + string(line-num ) + ")").
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-retlocal    }, input "=SUM(P{&HeadSize}:P" + string(line-num ) + ")").
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-retregion   }, input "=SUM(Q{&HeadSize}:Q" + string(line-num ) + ")").
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-retimp      }, input "=SUM(R{&HeadSize}:R" + string(line-num ) + ")").
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-othtot      }, input "=SUM(S{&HeadSize}:S" + string(line-num ) + ")").
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-othlocal    }, input "=SUM(T{&HeadSize}:T" + string(line-num ) + ")").
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-othregion   }, input "=SUM(U{&HeadSize}:U" + string(line-num ) + ")").
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-othimp      }, input "=SUM(V{&HeadSize}:V" + string(line-num ) + ")").

  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-ostendtot   }, input substitute("=C&1+G&1-K&1+O&1-S&1" ,line-num + 1 )) .
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-ostendlocal }, input substitute("=D&1+H&1-L&1+P&1-T&1" ,line-num + 1 )) .
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-ostendregion}, input substitute("=E&1+I&1-M&1+Q&1-U&1" ,line-num + 1)) .
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-ostendimp   }, input substitute("=F&1+J&1-N&1+R&1-V&1" ,line-num + 1)) .



/*
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-ostbegtot   }, input accum total tt-alc-retail.ost-beg-tot     ).
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-ostbeglocal }, input accum total tt-alc-retail.ost-beg-local   ).
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-ostbegregion}, input accum total tt-alc-retail.ost-beg-region  ).
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-ostbegimp   }, input accum total tt-alc-retail.ost-beg-imp     ).
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-pritot      }, input accum total tt-alc-retail.pri-tot         ).
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-prilocal    }, input accum total tt-alc-retail.pri-local       ).
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-priregion   }, input accum total tt-alc-retail.pri-region      ).
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-priimp      }, input accum total tt-alc-retail.pri-imp         ).
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-saletot     }, input accum total tt-alc-retail.sale-tot        ).
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-salelocal   }, input accum total tt-alc-retail.sale-local      ).
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-saleregion  }, input accum total tt-alc-retail.sale-region     ).
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-saleimp     }, input accum total tt-alc-retail.sale-imp        ).
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-rettot      }, input accum total tt-alc-retail.ret-tot         ).
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-retlocal    }, input accum total tt-alc-retail.ret-local       ).
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-retregion   }, input accum total tt-alc-retail.ret-region      ).
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-retimp      }, input accum total tt-alc-retail.ret-imp         ).
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-othtot      }, input accum total tt-alc-retail.oth-tot         ).
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-othlocal    }, input accum total tt-alc-retail.oth-local       ).
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-othregion   }, input accum total tt-alc-retail.oth-region      ).
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-othimp      }, input accum total tt-alc-retail.oth-imp         ).
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-ostendtot   }, input accum total tt-alc-retail.ost-end-tot     ).
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-ostendlocal }, input accum total tt-alc-retail.ost-end-local   ).
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-ostendregion}, input accum total tt-alc-retail.ost-end-region  ).
  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet1-it-ostendimp   }, input accum total tt-alc-retail.ost-end-imp     ).
  */
end.
end procedure. /* print-alc-retail */



/*
  определяем тип поставщика:
    - местный
    - региональный
    - импортный
*/
procedure get-cli-type :
  define input  parameter p-cli-code like ub.trn-doc.cli-code no-undo .
  define input  parameter p-cli-type like ub.trn-doc.cli-type no-undo .
  define output parameter p-type     as integer            no-undo .

  /* атрибуты поставщика */
  define variable v-is-local                      as logical   no-undo .
  define variable v-is-producer                   as logical   no-undo .
  define variable v-is-foreign-producer           as logical   no-undo .

 do on error undo, return error return-value :
   run clntattr-value in this-procedure ( input p-cli-type, input p-cli-code, input {&attr-cli-local}, output v-attr-value, output v-attr-type ) .
   assign v-is-local = logical( v-attr-value ) .

   run clntattr-value in this-procedure ( input p-cli-type, input p-cli-code, input {&attr-cli-alc-producer}, output v-attr-value, output v-attr-type ) .
   assign v-is-producer = logical ( v-attr-value ) .

   run clntattr-value in this-procedure ( input p-cli-type, input p-cli-code, input {&attr-foreign-producer}, output v-attr-value, output v-attr-type ) .
   assign v-is-foreign-producer = logical( v-attr-value ) .

   /* местный поставщик и производитель */
   if ( v-is-local = yes ) then assign  p-type = {&local} .
   /* поставщик из регионов */
   if ( v-is-local = no ) and ( v-is-foreign-producer = no ) then assign  p-type = {&region} .
   /* импортный поставщик */
   if v-is-foreign-producer = yes then assign  p-type = {&foreign}  .
  end.
end procedure. /* get-cli-type */


/*
  заполнение временной таблички под второй лист отчета
*/
procedure create-tt-alc-pri :

do
on error undo, return error return-value
:
  define buffer buf_doc-line for ub.doc-line.
  define buffer buf_trn-doc  for ub.trn-doc.
  define buffer buf_parts    for ub.parts.

  define variable v-attr-value      as character no-undo .
  define variable v-attr-type       as character no-undo .
  define variable v-quantity        as character no-undo .
  define variable v-region-code     as character no-undo .
  define variable v-q               as decimal   no-undo .

  empty temp-table tt-alc-pri.

  for each tt-gds,
    each obj-list no-lock,
      each buf_doc-line no-lock
        where buf_doc-line.artic      = tt-gds.artic
          and buf_doc-line.prod-type  = tt-gds.prod-type
          and buf_doc-line.prod-code  = tt-gds.prod-code
          and buf_doc-line.obj-type   = obj-list.obj-type
          and buf_doc-line.obj-code   = obj-list.obj-code
          and buf_doc-line.status_    = {&fact}
          and buf_doc-line.ext-doc-type = {&TDEDT_Pri_Vnesh}
          and buf_doc-line.fact-order >= v-fact-order-start
          and buf_doc-line.fact-order <  v-fact-order-end
    :
    find first tt-doc where tt-doc.doc-code = buf_doc-line.doc-code no-error .
    if available tt-doc then next .

    assign Counter1 = Counter1 + 1.
    { rep/repfrm.i disp Counter1 "'Формирование сведений об объемах закупки и поставщиках...'" }

    /* тип поставщика */
    run get-cli-type in this-procedure ( input buf_doc-line.prod-code, input buf_doc-line.prod-type, output v-producer ).

    find first tt-alc-pri
      where tt-alc-pri.alc-type-code  = tt-gds.alc-type-code
        and tt-alc-pri.doc-code  = buf_doc-line.doc-code
        and tt-alc-pri.in-code   = buf_doc-line.doc-code
        and tt-alc-pri.part-code = ""
        and tt-alc-pri.prod-type = v-producer

    no-error .
    if not available tt-alc-pri then do:
      find first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_doc-line.doc-code .
      /* реквизиты поставщика */
      run fmtcli-get-client in this-procedure ( input  buf_trn-doc.cli-type, input  buf_trn-doc.cli-code ) .
      /* лицензия  */
      run find-sert in this-procedure ( input buf_trn-doc.cli-type
                                      , input buf_trn-doc.cli-code
                                      , input tt-gds.alc-type-inner-code
                                      , output v-sert
                                      , output v-sert-give ) .
      /* регион поставщика */
      run clntattr-value in this-procedure ( input buf_trn-doc.cli-type, input buf_trn-doc.cli-code, input {&attr-region-code}, output v-attr-value, output v-attr-type ) .
      create tt-alc-pri.
      assign
        tt-alc-pri.cli-name        = if v-fmtcli-name = "" or v-fmtcli-name = ? then {&stroke} else v-fmtcli-name
        tt-alc-pri.cli-type        = buf_trn-doc.cli-type
        tt-alc-pri.cli-code        = buf_trn-doc.cli-code
        tt-alc-pri.cli-inn         = if v-fmtcli-inn = "" or v-fmtcli-inn = ? then {&stroke} else v-fmtcli-inn
        tt-alc-pri.cli-address     = if v-fmtcli-addres = "" then {&stroke} else v-fmtcli-addres
        tt-alc-pri.cli-region-code = if integer(v-attr-value) = 0 then {&stroke} else v-attr-value
        tt-alc-pri.lic-num         = v-sert
        tt-alc-pri.lic-give        = v-sert-give
        tt-alc-pri.doc-code        = buf_doc-line.doc-code
        tt-alc-pri.in-code         = buf_doc-line.doc-code
        tt-alc-pri.part-code       = "":u
        tt-alc-pri.fact-date       = buf_trn-doc.fact-date
/*        tt-alc-pri.doc-num-date    = substitute("&1, &2", buf_trn-doc.doc-code , buf_trn-doc.fact-date)*/
        tt-alc-pri.alc-type-name        = tt-gds.alc-type-name
        tt-alc-pri.alc-type-code        = tt-gds.alc-type-code
        tt-alc-pri.sea-list        = tt-gds.list_
        tt-alc-pri.prod-type       = v-producer
      .
      /* тип поставщика */
      run get-cli-type in this-procedure ( input buf_trn-doc.cli-code, input buf_trn-doc.cli-type, output v-producer ).
      assign  tt-alc-pri.supp-type       = if v-producer = 0 then {&stroke} else string(v-producer,"9")  .
      /* дата документа из атрибутов */
      { str/tdat-val.i
        buf_trn-doc.doc-code
        {&trdcattr-dids}
        v-attr-value
        v-attr-type
        }
      assign v-doc-date = if v-attr-value = "" or v-attr-value = ? then buf_trn-doc.fact-date else date( v-attr-value ) .
      /* номер документа из атрибутов */
      { str/tdat-val.i
         buf_trn-doc.doc-code
         {&trdcattr-nids}
         v-attr-value
         v-attr-type
         }
      assign v-doc-code = if v-attr-value = "" or v-attr-value = ? then buf_trn-doc.doc-code else v-attr-value .
      assign tt-alc-pri.doc-num-date = substitute("&1, &2", v-doc-code , v-doc-date) .
    end.
    assign
      tt-alc-pri.quantity     = tt-alc-pri.quantity + ( buf_doc-line.fact-qnty * tt-gds.ms-base / 10 )
      tt-alc-pri.quantity-str = str-format( tt-alc-pri.quantity, {&dal-format}, {&dal-format-len} )
    .
  end. /* each  */

  if p-Pri_Perem = yes then do:
    run CalcPri in this-procedure ( input {&TDEDT_Pri_Perem} )  .
    run CalcPri in this-procedure ( input {&TDEDT_Vozvrat_Perem} ) .
    run CalcPri in this-procedure ( input {&TDEDT_Pri_Prvo} ) .
  end.

end.

end procedure. /* create-tt-alc-pri */


/* печать отчета (сведения о поставщиках) */
procedure print-alc-pri :
  do on error undo, return error return-value :

  page stream out-stream.
  view stream out-stream frame TopPriFrame .
  view stream out-stream frame BottomPriFrame .

  run create-tt-alc-pri in this-procedure .

  assign
    v-is-first-page-of-report  = yes
    ii = 0
  .
  for each tt-alc-pri no-lock  break by tt-alc-pri.sea-list by tt-alc-pri.cli-code by tt-alc-pri.cli-type by tt-alc-pri.prod-type by tt-alc-pri.fact-date :
    assign Counter1 = Counter1 + 1.
    { rep/repfrm.i disp Counter1 "'Формирование сведений об объемах закупки и поставщиках...'" }

    /* считаем итого */
    accumulate tt-alc-pri.quantity (total).

    if v-is-first-page-of-report = yes and line-counter(out-stream) = page-size( out-stream) then do:
      assign v-is-first-page-of-report = no .
    end.

    /* выводим строку отчета */
    display stream out-stream
      tt-alc-pri.cli-name
      tt-alc-pri.cli-inn
      tt-alc-pri.cli-address
      tt-alc-pri.cli-region-code
      tt-alc-pri.lic-num
      tt-alc-pri.lic-give
      tt-alc-pri.doc-num-date
      tt-alc-pri.alc-type-name @ v-alc-type-name
      tt-alc-pri.alc-type-code
      tt-alc-pri.prod-type
      tt-alc-pri.quantity-str
      sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12
    with frame f-alc-pri.
    down stream out-stream 1 with frame f-alc-pri.

    run alcdclxl-sheet2-write-line-data (
        tt-alc-pri.cli-name
      , tt-alc-pri.cli-inn
      , tt-alc-pri.cli-address
      , tt-alc-pri.cli-region-code
      , tt-alc-pri.lic-num
      , tt-alc-pri.lic-give
      , tt-alc-pri.doc-num-date
      , tt-alc-pri.alc-type-name
      , tt-alc-pri.alc-type-code
      , tt-alc-pri.prod-type
      , string( tt-alc-pri.quantity )
    ) .
    /* разделитель после каждого вида продукции */
    if last-of(tt-alc-pri.sea-list) then do:
       put stream out-stream unformatted fill( "-" , {&f-alc-pri-width} ) skip.
    end.
    assign ii = ii + 1  .
  end.
/*  put stream out-stream unformatted fill( "-" , {&f-alc-pri-width} ) skip.*/
  display stream out-stream
    " ИТОГО " @ tt-alc-pri.cli-name
    str-format( accum total tt-alc-pri.quantity , {&dal-format} , {&dal-format-len} )  @ tt-alc-pri.quantity-str
    sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12
  with frame f-alc-pri.
  down stream out-stream 1 with frame f-alc-pri.
  put stream out-stream unformatted fill( "-" , {&f-alc-pri-width} ) skip.

  run alcdclxl-write-cell-data in this-procedure ( input {&alcdclxl-sheet2-it-quantity}, input string(accum total tt-alc-pri.quantity )).

  put stream out-stream
    skip
    "             М.П."         "Руководитель организации__________________________________________" at 100 skip
    "        Дата_____________" "Главный бухгалтер_________________________________________________" at 100 skip
    "Примечание:  1. Калужская область    2. Другие субъекты Российской Федерации   3. Иностранный производитель" skip
  .

  hide stream out-stream frame BottomPriFrame .
end.

end procedure. /* print-alc-pri */


/* чистим временные таблички */
procedure clear-temp-tables :

do
on error undo, return error return-value
:
  empty temp-table tt-alc-type.
  empty temp-table tt-gds.
  empty temp-table tt-alc-retail.
  empty temp-table tt-alc-pri.

end.

end procedure. /* clear-temp-tables */


procedure CalcOborot :
  do on error undo, return error return-value :
    define input  parameter p-doc-type as character no-undo .
    define output parameter p-qnty  as decimal   no-undo .

    assign  p-qnty = 0 .

    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = obj-list.obj-type
        and buf_stk-line.obj-code  = obj-list.obj-code
        and buf_stk-line.artic     = tt-gds.artic
        and buf_stk-line.prod-type = tt-gds.prod-type
        and buf_stk-line.prod-code = tt-gds.prod-code
        and buf_stk-line.sum-type  = {&arh-csdt} + p-doc-type
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-end
      use-index category no-error .
    if available buf_stk-line then assign p-qnty = p-qnty + buf_stk-line.fact-qnty .
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = obj-list.obj-type
        and buf_stk-line.obj-code  = obj-list.obj-code
        and buf_stk-line.artic     = tt-gds.artic
        and buf_stk-line.prod-type = tt-gds.prod-type
        and buf_stk-line.prod-code = tt-gds.prod-code
        and buf_stk-line.sum-type  = {&arh-csdt} + p-doc-type
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order < v-fact-order-start
      use-index category no-error .
    if available buf_stk-line then assign p-qnty = p-qnty - buf_stk-line.fact-qnty .
  end.
end procedure. /* CalcOborot */


procedure CalcOborot1 :
  do on error undo, return error return-value :
    define input  parameter p-doc-type as character no-undo .
    define output parameter p-qnty  as decimal   no-undo .

    define buffer buf_obj-list for obj-list.
    define buffer buf_doc-line  for ub.doc-line .
    define buffer buf_trn-doc   for ub.trn-doc .

    assign  p-qnty = 0 .

    for each buf_doc-line no-lock
      where buf_doc-line.obj-type     = obj-list.obj-type
        and buf_doc-line.obj-code     = obj-list.obj-code
        and buf_doc-line.artic        = tt-gds.artic
        and buf_doc-line.prod-type    = tt-gds.prod-type
        and buf_doc-line.prod-code    = tt-gds.prod-code
        and buf_doc-line.ext-doc-type = p-doc-type
        and buf_doc-line.status_      = {&fact}
        and buf_doc-line.fact-order > v-fact-order-start
        and buf_doc-line.fact-order < v-fact-order-end
      :
      find first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_doc-line.doc-code .
      find first buf_obj-list where buf_obj-list.obj-type = buf_trn-doc.cli-type and buf_obj-list.obj-code = buf_trn-doc.cli-code no-error .
      if not available buf_obj-list then assign p-qnty = p-qnty + buf_doc-line.fact-qnty .
    end.
  end.
end procedure. /* CalcOborot1 */


procedure CalcPri :
  do on error undo, return error return-value :
    define input  parameter p-ext-doc-type as character no-undo .

    define buffer buf_doc-line  for ub.doc-line .
    define buffer buf_parts     for ub.parts .
    define buffer buf_trn-doc   for ub.trn-doc .
    define buffer buf_obj-list  for obj-list.

    for each tt-gds,
      each obj-list no-lock,
        each buf_doc-line no-lock
          where buf_doc-line.artic      = tt-gds.artic
            and buf_doc-line.prod-type  = tt-gds.prod-type
            and buf_doc-line.prod-code  = tt-gds.prod-code
            and buf_doc-line.obj-type   = obj-list.obj-type
            and buf_doc-line.obj-code   = obj-list.obj-code
            and buf_doc-line.status_    = {&fact}
            and buf_doc-line.ext-doc-type = p-ext-doc-type
            and buf_doc-line.fact-order >= v-fact-order-start
            and buf_doc-line.fact-order <  v-fact-order-end,
        each buf_parts where buf_parts.out-code  = buf_doc-line.doc-code  and
                             buf_parts.obj-type  = obj-list.obj-type      and
                             buf_parts.obj-code  = obj-list.obj-code      and
                             buf_parts.artic     = buf_doc-line.artic     and
                             buf_parts.prod-type = buf_doc-line.prod-type and
                             buf_parts.prod-code = buf_doc-line.prod-code no-lock
      :
      find first tt-doc where tt-doc.doc-code = buf_doc-line.doc-code no-error .
      if available tt-doc then next .
      if ( p-ext-doc-type = {&TDEDT_Pri_Perem} or p-ext-doc-type = {&TDEDT_Vozvrat_Perem} ) then do:
        find first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_doc-line.doc-code .
        find first buf_obj-list where buf_obj-list.obj-type = buf_trn-doc.cli-type and buf_obj-list.obj-code = buf_trn-doc.cli-code no-error .
        if available buf_obj-list then next .
      end.

      assign Counter1 = Counter1 + 1.
      { rep/repfrm.i disp Counter1 "'Формирование сведений об объемах закупки и поставщиках...'" }

      /* тип поставщика */
      run get-cli-type in this-procedure ( input buf_doc-line.prod-code, input buf_doc-line.prod-type, output v-producer ).

      find first tt-alc-pri
        where tt-alc-pri.alc-type-code  = tt-gds.alc-type-code
          and tt-alc-pri.doc-code  = buf_doc-line.doc-code
          and tt-alc-pri.in-code   = buf_parts.in-code
          and tt-alc-pri.part-code = buf_parts.part-code
          and tt-alc-pri.prod-type = v-producer
      no-error .
      if not available tt-alc-pri then do:
        /* реквизиты поставщика */
        run fmtcli-get-client in this-procedure ( input  buf_parts.supp-type, input  buf_parts.supp-code ) .
        /* лицензия  */
        run find-sert in this-procedure ( input buf_parts.supp-type
                                        , input buf_parts.supp-code
                                        , input tt-gds.alc-type-inner-code
                                        , output v-sert
                                        , output v-sert-give ) .
        /* регион поставщика */
        run clntattr-value in this-procedure ( input buf_parts.supp-type, input buf_parts.supp-code, input {&attr-region-code}, output v-attr-value, output v-attr-type ) .
        create tt-alc-pri.
        assign
          tt-alc-pri.cli-name        = if v-fmtcli-name = "" or v-fmtcli-name = ? then {&stroke} else v-fmtcli-name
          tt-alc-pri.cli-type        = buf_parts.supp-type
          tt-alc-pri.cli-code        = buf_parts.supp-code
          tt-alc-pri.cli-inn         = if v-fmtcli-inn = "" or v-fmtcli-inn = ? then {&stroke} else v-fmtcli-inn
          tt-alc-pri.cli-address     = if v-fmtcli-addres = "" then {&stroke} else v-fmtcli-addres
          tt-alc-pri.cli-region-code = if integer(v-attr-value) = 0 then {&stroke} else v-attr-value
          tt-alc-pri.lic-num         = v-sert
          tt-alc-pri.lic-give        = v-sert-give
          tt-alc-pri.alc-type-code   = tt-gds.alc-type-code
          tt-alc-pri.doc-code        = buf_doc-line.doc-code
          tt-alc-pri.in-code         = buf_parts.in-code
          tt-alc-pri.part-code       = buf_parts.part-code
          tt-alc-pri.prod-type       = v-producer
          tt-alc-pri.fact-date       = buf_parts.fact-date
          tt-alc-pri.alc-type-name   = tt-gds.alc-type-name
          tt-alc-pri.sea-list        = tt-gds.list_
        .
        /* тип поставщика */
        run get-cli-type in this-procedure ( input buf_parts.supp-code, input buf_parts.supp-type, output v-producer ).
        assign  tt-alc-pri.supp-type       = if v-producer = 0 then {&stroke} else string(v-producer,"9")  .
        find first buf_trn-doc where buf_trn-doc.doc-code = buf_parts.in-code no-lock no-error.
        assign v-doc-date = buf_parts.fact-date.
        if available buf_trn-doc then do:
          /* номер документа из атрибутов */
          { str/tdat-val.i      buf_trn-doc.doc-code     {&trdcattr-nids}    v-attr-value     v-attr-type      }
          assign v-doc-code = if v-attr-value = "" or v-attr-value = ? then buf_parts.in-code + " " + buf_parts.out-code else v-attr-value + " " + buf_parts.out-code.
          assign tt-alc-pri.doc-num-date = substitute("&1, &2", v-doc-code , v-doc-date) .
        end.
        else do:
          assign v-doc-code = buf_parts.in-code + " " + buf_parts.out-code.
          assign tt-alc-pri.doc-num-date = substitute("&1, &2", v-doc-code , v-doc-date) .
        end.
      end.
      assign
        tt-alc-pri.quantity     = tt-alc-pri.quantity + ( buf_parts.fact-qnty * tt-gds.ms-base / 10 )
        tt-alc-pri.quantity-str = str-format( tt-alc-pri.quantity, {&dal-format}, {&dal-format-len} )
      .
    end. /* each  */

  end.
end procedure. /* CalcPri */