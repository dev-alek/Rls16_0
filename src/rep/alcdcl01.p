block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: alcdcl01.p $
$Archive: rep/alcdcl01.p $

Декларация об объемах розничной продажи алкогольной продукции (Приморский край)

Автор: Хныкин Павел Андреевич
Дата создания: 09/22/06
Author: Pavel Khnykin
Creation date: 09/22/06

*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: alcdcl01.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/alcdcl01.p $":U .
define variable vss-description as character no-undo init "Декларация об объемах розничной продажи алкогольной продукции (Приморский край)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i   }
{ cmp/library.i    }
{ str/lib-trn.i    }
{ cmp/r-pril.i new }
{ cmp/r-page1.i    }
{ rep/f-fdec.i     }
{ gbl/waitfram.i   }
{ gbl/prn-lib.i    }
{ rep/r-sym.i      }
{ rep/fmtcli.i     }
{ trg/factord.i    }
{ gbl/clntattr.i   }
{ rep/ost-line.i   }
{ str/clcprtsl.i   }
{ str/get-pr.i def }
{ str/trdcalib.i   }
{ rep/lkp-font.i   }
{ gbl/getsect.i def }
do
on error undo, return error return-value
:
  &scop print-excel 1
  &scop stroke " ------------- ":U
  &scop div-num 1000
  &scop list-doc-delim ",":U
  &scop list-date-delim {&list-doc-delim}
  &scop list-dal-delim {&list-doc-delim}
  &scop dal-format ">>>>>>>>>9.9999"
  &scop dal-format-len 15
  &scop sum-format ">>>>>>>>>>9.999"
  &scop sum-format-len 15

  &scop f-w-alc-type-name 26
  &scop f-w-fmtcli-name 30
  &scop f-w-fmtcli-inn 15
  &scop f-w-fmtcli-post-addres 35
  &scop f-w-sert 15
  &scop f-w-sert-give 20
  &scop f-w-doc-num-date 25
  &scop f-w-dal 15
  &scop f-width 194
  &scop f-w-line 194
  &scop f-decl-width 196
  &scop f-w-decl-line 196
  &scop f-w-decl-alc-type-name 30

  function str-format returns character (val as decimal , v-format as char, v-str-len as integer) forward.

  define stream out-stream.

  define buffer buf_parts         for ub.parts.
  define buffer buf_goods         for ub.goods.
  define buffer buf_cli-gds       for ub.cli-gds.
  define buffer buf_trn-doc       for ub.trn-doc.
  define buffer buf_doc-line      for ub.doc-line.
  define buffer buf_sert          for ub.sert.
  define buffer buf_sert-join     for ub.sert-join.
  define buffer buf_clients       for ub.clients.
  define buffer buf_alc-sale-lic  for ub.alc-sale-lic.

  define variable v-line                    as character            no-undo .
  define variable g#report-num              as integer              no-undo .
  define variable v-counter                 as integer              no-undo .
  define variable v-vardate                 as date                 no-undo .
  define variable v-repfrm-title            as character  initial "Формирование отчета по партиям...":U no-undo .
  define variable v-enc-name                as character            no-undo .
  define variable v-enc-value               as character            no-undo .
  define variable v-begin-date              as date                 no-undo .
  define variable v-end-date                as date                 no-undo .
  define variable v-host-code               like ub.clients.host-code  no-undo .
  define variable v-dal                     as decimal              no-undo .
  define variable v-sert                    like ub.sert.sert-code     no-undo .
  define variable v-sert-give               like ub.sert.ps            no-undo .
  define variable v-doc-num-date            as character            no-undo .
  define variable v-sea-num                 as integer    initial 1 format ">>9"  no-undo .
  define variable v-total                         as decimal    format "->>>,>>>,>>9.99"        no-undo .
  define variable v-total-qnty                    as decimal    format "->>>,>>>,>>9.99"        no-undo .
  define variable v-total-local-producer          as decimal    format "->>>,>>>,>>9.99"        no-undo .
  define variable v-total-local-rus               as decimal    format "->>>,>>>,>>9.99"        no-undo .
  define variable v-total-local-imp               as decimal    format "->>>,>>>,>>9.99"        no-undo .
  define variable v-total-not-local-rus           as decimal    format "->>>,>>>,>>9.99"        no-undo .
  define variable v-total-not-local-imp           as decimal    format "->>>,>>>,>>9.99"        no-undo .
  define variable v-total-local-producer-qnty     as decimal    format ">>,>>>,>>9.9999"        no-undo .
  define variable v-total-local-rus-qnty          as decimal    format ">>,>>>,>>9.9<<<"        no-undo .
  define variable v-total-local-imp-qnty          as decimal    format ">>,>>>,>>9.9<<<"        no-undo .
  define variable v-total-not-local-rus-qnty      as decimal    format ">>,>>>,>>9.9<<<"        no-undo .
  define variable v-total-not-local-imp-qnty      as decimal    format ">>,>>>,>>9.9<<<"        no-undo .
  define variable v-ras                           as decimal    format "->>>,>>>,>>9.99"        no-undo .
  define variable v-spis                          as decimal    format "->>>,>>>,>>9.99"        no-undo .
  define variable v-ras-qnty                      as decimal    format ">>,>>>,>>9.9<<<"        no-undo .
  define variable v-spis-qnty                     as decimal    format ">>,>>>,>>9.9<<<"        no-undo .
  define variable v-ost-end                       as decimal    format "->>>,>>>,>>9.99"        no-undo .
  define variable v-ost-end-qnty                  as decimal    format ">>,>>>,>>9.9<<<"        no-undo .
  define variable v-ost                           as decimal    format "->>>,>>>,>>9.99"        no-undo .
  define variable v-ost-qnty                      as decimal    format ">>,>>>,>>9.9<<<"        no-undo .
  define variable v-gt-total                      as decimal    format "->>>,>>>,>>9.99"        no-undo .
  define variable v-gt-total-qnty                 as decimal    format ">>,>>>,>>9.9<<<"        no-undo .
  define variable v-gt-total-local-producer       as decimal    format "->>>,>>>,>>9.99"        no-undo .
  define variable v-gt-total-local-rus            as decimal    format "->>>,>>>,>>9.99"        no-undo .
  define variable v-gt-total-local-imp            as decimal    format "->>>,>>>,>>9.99"        no-undo .
  define variable v-gt-total-not-local-rus        as decimal    format "->>>,>>>,>>9.99"        no-undo .
  define variable v-gt-total-not-local-imp        as decimal    format "->>>,>>>,>>9.99"        no-undo .
  define variable v-gt-total-local-producer-qnty  as decimal    format ">>,>>>,>>9.9<<<"        no-undo .
  define variable v-gt-total-local-rus-qnty       as decimal    format ">>,>>>,>>9.9<<<"        no-undo .
  define variable v-gt-total-local-imp-qnty       as decimal    format ">>,>>>,>>9.9<<<"        no-undo .
  define variable v-gt-total-not-local-rus-qnty   as decimal    format ">>,>>>,>>9.9<<<"        no-undo .
  define variable v-gt-total-not-local-imp-qnty   as decimal    format ">>,>>>,>>9.9<<<"        no-undo .
  define variable v-gt-ras                        as decimal    format "->>>,>>>,>>9.99"        no-undo .
  define variable v-gt-spis                       as decimal    format "->>>,>>>,>>9.99"        no-undo .
  define variable v-gt-ras-qnty                   as decimal    format ">>,>>>,>>9.9<<<"        no-undo .
  define variable v-gt-spis-qnty                  as decimal    format ">>,>>>,>>9.9<<<"        no-undo .
  define variable v-gt-ost-end                    as decimal    format "->>>,>>>,>>9.99"        no-undo .
  define variable v-gt-ost-end-qnty               as decimal    format ">>,>>>,>>9.9<<<"        no-undo .
  define variable v-gt-ost                        as decimal    format "->>>,>>>,>>9.99"        no-undo .
  define variable v-gt-ost-qnty                   as decimal    format ">>,>>>,>>9.9<<<"        no-undo .
  define variable v-par-val                       as character                                  no-undo .
  define variable v-par-type                      as character                                  no-undo .
  define variable v-addres                        as character                                  no-undo .

  define variable v-str-ost-qnty                  as character  format "X({&dal-format-len})" no-undo .
  define variable v-str-total-qnty                as character  format "X({&dal-format-len})" no-undo .
  define variable v-str-total-local-producer-qnty as character  format "X({&dal-format-len})" no-undo .
  define variable v-str-total-local-rus-qnty      as character  format "X({&dal-format-len})" no-undo .
  define variable v-str-total-local-imp-qnty      as character  format "X({&dal-format-len})" no-undo .
  define variable v-str-total-not-local-rus-qnty  as character  format "X({&dal-format-len})" no-undo .
  define variable v-str-total-not-local-imp-qnty  as character  format "X({&dal-format-len})" no-undo .
  define variable v-str-ras-qnty                  as character  format "X({&dal-format-len})" no-undo .
  define variable v-str-spis-qnty                 as character  format "X({&dal-format-len})" no-undo .
  define variable v-str-ost-end-qnty              as character  format "X({&dal-format-len})" no-undo .
  define variable v-str-dal                       as character  format "X({&dal-format-len})" no-undo .


  define temp-table tt-gds no-undo like ub.goods
    field alc-type-inner-code like ub.alc-type.alc-type-inner-code
    field create-user-db-num  like ub.alc-type.create-user-db-num
    field alc-type-code       like ub.alc-type.alc-type-code
    field alc-type-name       like ub.alc-type.alc-type-name
  index pi is primary unique gds-code
  index sea alc-type-inner-code
            create-user-db-num
  .

  define temp-table tt-alc-type no-undo like ub.alc-type
  /*index pi is primary unique alc-type-code*/
  .

  define temp-table tt-alc-pri no-undo
    field alc-type-inner-code    like ub.alc-type.alc-type-inner-code
    field create-user-db-num     like ub.alc-type.create-user-db-num
    field alc-type-code          like ub.alc-type.alc-type-code
    field doc-code               like ub.trn-doc.doc-code
    field artic                  like ub.doc-line.artic
    field prod-type              like ub.doc-line.prod-type
    field prod-code              like ub.doc-line.prod-code
    field fact-qnty              like ub.doc-line.fact-qnty
    field cli-type               like ub.trn-doc.cli-type
    field cli-code               like ub.trn-doc.cli-code
    field fact-date              like ub.trn-doc.fact-date
    field ms-base                like ub.goods.ms-base
  index pi is primary unique
    alc-type-inner-code
    create-user-db-num
    doc-code
    artic
    prod-type
    prod-code
  index sort
    alc-type-inner-code
    create-user-db-num
/*    alc-type-code*/
    cli-type
    cli-code
    fact-date
    doc-code
  .

  define frame f-decl
    sym1 column-label ":!:!:!:" format "X(1)" space(0)
    v-sea-num column-label "№!п/п! !" space(0)
    sym2 column-label ":!:!:!:" format "X(1)" space(0)
    tt-gds.alc-type-name column-label "Наименование видов!и коды!алкогольной продукции!" format "X({&f-w-decl-alc-type-name})" space(0)
    sym3 column-label ":!:!:!:" format "X(1)" space(0)
    v-str-ost-qnty column-label "Остаток!на!начало года!" space(0)
    sym4 column-label ":!:!:!:" format "X(1)" space(0)
    v-str-total-qnty  column-label "Всего! ! !" space(0)
    sym5 column-label ":!:!:!:" format "X(1)" space(0)
    v-str-total-local-producer-qnty  column-label "От!производителей!края!" space(0)
    sym6 column-label ":!:!:!:" format "X(1)" space(0)
    v-str-total-local-rus-qnty column-label "от организаций!оптовой!торговли края!отеч." space(0)
    sym7 column-label ":!:!:!:" format "X(1)" space(0)
    v-str-total-local-imp-qnty column-label "от организаций!оптовой!торговли края!импорт" space(0)
    sym8 column-label ":!:!:!:" format "X(1)" space(0)
    v-str-total-not-local-rus-qnty column-label "от постав-!щиков из-за!пределов края!отеч." space(0)
    sym9 column-label ":!:!:!:" format "X(1)" space(0)
    v-str-total-not-local-imp-qnty column-label "от постав-!щиков из-за!пределов края!импорт" space(0)
    sym10 column-label ":!:!:!:" format "X(1)" space(0)
    v-str-ras-qnty  column-label "Розничная!продажа! !" space(0)
    sym11 column-label ":!:!:!:" format "X(1)" space(0)
    v-str-spis-qnty  column-label "Списание,!возврат!поставщику" space(0)
    sym12 column-label ":!:!:!:" format "X(1)" space(0)
    v-str-ost-end-qnty column-label "Остаток!на конец!отчетного!периода" space(0)
    sym13 column-label ":!:!:!:" format "X(1)" space(0)
  header
    v-line format "X({&f-decl-width})" at 1 skip
    ":" at 1 ":" at 5 ":" at 36 ":" at 52 "Поступления (закупки)" at 95 ":" at 148 ":" at 164 ":" at 180 ":" at 196 skip
    ":" at 1 ":" at 5 ":" at 36 ":" at 52
    "_______________________________________________________________________________________________" at 53  ":" at 148 ":" at 164 ":" at 180 ":" at 196 skip
    v-line format "X({&f-decl-width})" at 1
  with width {&A4_LS} down stream-io.

  define frame f-in
    sym1 column-label ":!:!:" format "X(1)" space(0)
    v-sea-num column-label "№!п/п!" space(0)
    sym2 column-label ":!:!:" format "X(1)" space(0)
    tt-gds.alc-type-name column-label "Наименование видов!алкогольной продукции!" format "X({&f-w-alc-type-name})" space(0)
    sym3 column-label ":!:!:" format "X(1)" space(0)
    v-fmtcli-name column-label "Наименование поставщика! !" format "X({&f-w-fmtcli-name})" space(0)
    sym4 column-label ":!:!:" format "X(1)" space(0)
    v-fmtcli-inn column-label "{&abbr_inn_allshift}! !" format "X({&f-w-fmtcli-inn})" space(0)
    sym5 column-label ":!:!:" format "X(1)" space(0)
    v-addres column-label "Место нахождения!(юридический адрес)!" format "X({&f-w-fmtcli-post-addres})" space(0)
    sym6 column-label ":!:!:" format "X(1)" space(0)
    v-sert column-label "Серия, номер,!дата выдачи!" format "X({&f-w-sert})" space(0)
    sym7 column-label ":!:!:" format "X(1)" space(0)
    v-sert-give column-label "Кем выдана! !" format "X({&f-w-sert-give})" space(0)
    sym8 column-label ":!:!:" format "X(1)" space(0)
    v-doc-num-date column-label "Дата и номер!товарно-транспартной!накладной" format "X({&f-w-doc-num-date})" space(0)
    sym9 column-label ":!:!:" format "X(1)" space(0)
    v-str-dal column-label "Объем!продукции!(дал)" space(0)
    sym10 column-label ":!:!:" format "X(1)" space(0)
  header
    v-line format "X({&f-width})" at 1
    ":" at 1 ":" at 5 ":" at 32 "Поставщик" at 75 ":" at 115 "Лицензия" at 130 ":" at 152 ":" at 178 ":" at 194 skip
    ":" at 1 ":" at 5 ":" at 32 "__________________________________________________________________________________" at 33 ":" at 115 "____________________________________" AT 116 ":" at 152 ":" at 178 ":" at 194 skip
    v-line format "X({&f-width})" at 1

  with width {&A4_LS} down stream-io.

  form header
          v-line format "X({&f-w-line})" at 1 SKIP
          "Продолжение - на следующей странице" at 1 SKIP
  with frame BottomFrame width {&A4_LS} PAGE-BOTTOM NO-LABELS NO-BOX .

{ gbl/working.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get " " my-handle }

{ gbl/getsect.i run "''"  0 {&attr-report-glob}}

for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'ardecldt' then  v-par-val =  string(thbjattr_thbj-attr.property-value-date,"99/99/9999") .
end.

  assign
    v-line        = fill( "-" , 300 )
    v-begin-date  = date(v-par-val)
    v-end-date    = x-Date-Alone
  .
  run get-report-num in my-handle (output g#report-num).
  { cmp/open-out.i stream out-stream " " ReportPageHeight }
  run waitfram-show in this-procedure ( "Формирование данных об организации..." ) .
  run find-alc-goods in this-procedure .
  run print-enclosure in this-procedure .
  run waitfram-show in this-procedure ( "Формирование декларации об объемах розничной продажи..." ) .
  run print-decl in this-procedure .
  view stream out-stream frame BottomFrame .
  run waitfram-show in this-procedure ( "Формирование сведений об объемах закупки и поставщиках..." ) .
  run print-alc-pri2 in this-procedure .
  hide stream out-stream frame BottomFrame.
  output stream out-stream close.
  {&CloseExcel}
  empty temp-table tt-gds.
  empty temp-table tt-alc-type.
  run waitfram-hide in this-procedure .
  { gbl/stopwork.i }
  /*run prn-file.w(8) .*/
  define variable v-user-action   as character no-undo .
  define variable v-printed       as logical   no-undo .
  /*
  define variable DisabledOptions as integer   no-undo .
  define variable v-orient-page as character no-undo .
  run How-name in this-procedure (
      input ReportPageHeight,
      input ReportPageWidth,
      output v-orient-page )
      .
  if v-orient-page = "A4-lans":U then DisabledOptions = 8 .
                                else DisabledOptions = 0 .



  */
  run gbl/prnfilen.w
      (input  ""
      ,input  8
      ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
      ,input  ReportFontNum
      ,output v-user-action
      ,output v-printed
      ) .

end.

procedure print-enclosure :

do
on error undo, return error return-value
:

  define variable v-host-egrip-num  as character format "X(75)" no-undo .
  define variable v-host-egrip-date as character format "X(10)" no-undo .
  define variable v-s-num           as character format "X(87)" no-undo .
  define variable v-s-date          as date      format "99/99/9999" no-undo .
  define variable v-sertificate     as character format "X(87)" no-undo .
  define variable v-object          as character format "X(87)" no-undo .
  define variable v-first-date      as date      format "99/99/9999" no-undo .
  define variable v-last-date       as date      format "99/99/9999" no-undo .
  define variable v-org-address     as character format "X(87)" no-undo .
  define variable v-str             as character no-undo .
  define variable v-log-carret      as logical   no-undo .
  define variable v-host-egrip      as character format "X(87)" no-undo .

  assign
    sheetf.sizes =
      "80"  + {&comma-char} +
      "100"
    Sheetf.colformat = "1=@;2=@;"
  .
  find first obj-list no-lock no-error .
  if not available obj-list then do:
    message
      "Не определен объект для формирования отчета"
    view-as alert-box information .
    return error.
  end.

  { gbl/hostcode.i obj-list.obj-type obj-list.obj-code v-host-code }
  run fmtcli-get-client in this-procedure
            ( input  {&cmp}
            , input  v-host-code
            ) .
  run clntattr-value in this-procedure (
        input {&cmp}
      , input v-host-code
      , input {&attr-egrip-date}
      , output v-host-egrip-date
      , output v-par-type
  ).
  run clntattr-value in this-procedure (
        input {&cmp}
      , input v-host-code
      , input {&attr-egrip-num}
      , output v-host-egrip-num
      , output v-par-type
  ).
  assign
    v-host-egrip-date = string(date(v-host-egrip-date),"99/99/9999")
    v-str     = substitute("&1, &2", v-fmtcli-addres , v-fmtcli-phone)
    v-host-egrip = v-host-egrip-date + ", " + v-host-egrip-num
  .

  find first buf_clients no-lock
    where buf_clients.obj-type = {&cmp}
      and buf_clients.obj-code = v-host-code
  no-error .
  if not available buf_clients then do:
    message
      substitute ("Не могу найти фирму с кодом: &1", v-host-code)
    view-as alert-box error .
    return error.
  end.
  /*
  find first buf_sert-join no-lock
    where buf_sert-join.cli-type = buf_clients.obj-type
      and buf_sert-join.cli-code = buf_clients.obj-code
  no-error .
  if available buf_sert-join then do:
    find first buf_sert no-lock
      where buf_sert.sert-code = buf_sert-join.sert-code
    no-error .
    if not available buf_sert then do:
      assign
        v-sertificate = ""
      .
    end.
    else do:
      assign
        v-sertificate = substitute("&1 выдан &2 c &3 по &4", buf_sert.sert-code , buf_sert.PS , string( buf_sert.first-date , "99/99/9999"), string( buf_sert.last-date , "99/99/9999"))
      .
    end.
  end.
  */
   find first buf_alc-sale-lic
        where buf_alc-sale-lic.cli-type = buf_clients.obj-type
          and buf_alc-sale-lic.cli-code = buf_clients.obj-code
          and buf_alc-sale-lic.date-to  > x-Date-Alone
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
    "Приложение №1":U at 180 skip
    "к Порядку представления":u at 170 skip
    "деклараций о":U at 181 skip
    "розничной продаже алкогольной":U at 164 skip
    "продукции на":U at 181 skip
    "территории Приморского края,":U at 166 skip
    "утвержденному":U at 180 skip
    "постановлением Администрации":U at 165 skip
    "Приморского края от":U at 174 skip
    "19 июня 2006 г. № 148-па":U at 169 skip (2)
    "Данные об организации":U at 10 skip (1)
    v-line format "X(170)" at 10 skip
    ": Наименование организации" at 10 ":" at 91 v-fmtcli-name format "X(87)" ":" at 179
    v-line format "X(170)" at 10 skip
    ": {&abbr_inn_allshift}" at 10 ":" at 91 v-fmtcli-inn format "X(87)" ":" at 179
    v-line format "X(170)" at 10 skip
    ": Дата внесения в Единый государственный реестр юридических лиц, номер" at 10 ":" at 91 v-host-egrip ":" at 179
    v-line format "X(170)" at 10 skip
  .

  {&PutExcel}
    {&tabulation} "Приложение №1":U  skip
    {&tabulation} "к Порядку представления":u skip
    {&tabulation} "деклараций о":U  skip
    {&tabulation} "розничной продаже алкогольной":U skip
    {&tabulation} "продукции на":U  skip
    {&tabulation} "территории Приморского края,":U skip
    {&tabulation} "утвержденному":U skip
    {&tabulation} "постановлением Администрации":U skip
    {&tabulation} "Приморского края от":U skip
    {&tabulation} "19 июня 2006 г. № 148-па":U skip(2)
     "Данные об организации":U {&tabulation} skip (1)

    "Наименование организации"  {&tabulation}
    v-fmtcli-name               {&tabulation}
  skip
    "{&abbr_inn_allshift}"                       {&tabulation}
    v-fmtcli-inn                {&tabulation}
  skip
    "Дата внесения в Единый государственный реестр юридических лиц, номер"  {&tabulation}
    v-host-egrip               {&tabulation}
  skip
    "Место нахождения организации (адрес государственной регистрации), телефон"  {&tabulation}
    v-str               {&tabulation}
  skip.

  do while v-str <> ""
  :
    assign
      v-org-address = substring(v-str, 1 , 87)
      v-str         = substring(v-str, 87 , length(v-str))
    .
    if v-log-carret then do:
      put stream out-stream
        ":" at 10 ":" at 91 v-org-address ":" at 179
      .
    end.
    else do:
      put stream out-stream
        ": Место нахождения организации (адрес государственной регистрации), телефон" at 10 ":" at 91 v-org-address ":" at 179
      .
      assign
        v-log-carret = yes
      .
    end.
  end.
  put stream out-stream v-line format "X(170)" at 10 skip.
  for each obj-list no-lock
    break by obj-list.obj-type
          by obj-list.obj-code
  :
    run fmtcli-get-client in this-procedure
            ( input  obj-list.obj-type
            , input  obj-list.obj-code
            ) .

    if v-fmtcli-name = "" then do:
      assign
        v-object = ""
      .
    end.
    else do:
      if v-fmtcli-addres = "" then do:
        assign
          v-object = v-fmtcli-name
        .
      end.
      else do:
        assign
          v-object = substitute("&1, &2", v-fmtcli-name, v-fmtcli-addres)
        .
      end.
    end.
    assign
      v-str = v-object
    .

    {&PutExcel}
      if first(obj-list.obj-type) and first (obj-list.obj-code) then
        "Объект торговли и (или) общественного питания, его адрес"
      else ""
      {&tabulation}
      v-str               {&tabulation}
    skip.

    do while v-str <> ""
    :
      assign
        v-object  = substring(v-str, 1 , 87)
        v-str     = substring(v-str, 87 , length(v-str))
      .
      if first(obj-list.obj-type) and first (obj-list.obj-code) then do:
        put stream out-stream
          ": Объект торговли и (или) общественного питания, его адрес" at 10 ":" at 91 v-object ":" at 179
          v-line format "X(170)" at 10 skip
        .
      end.
      else do:
        put stream out-stream
          ":" at 10 ":" at 91 v-object ":" at 179
          v-line format "X(170)" at 10 skip
        .
      end.
    end.
  end.

  put stream out-stream
    ": Номер, регистрационный номер, дата, срок действия лицензии" at 10 ":" at 91 v-sertificate ":" at 179
    v-line format "X(170)" at 10 skip
  .
  {&PutExcel}
    "Номер, регистрационный номер, дата, срок действия лицензии"  {&tabulation}
    v-sertificate               {&tabulation}
  skip.

  page stream out-stream.
  down stream out-stream 1 .
end.
end procedure. /* print-enclosure */


procedure print-decl :

do
on error undo, return error return-value
:
  define buffer buf_trn-doc     for ub.trn-doc.
  define buffer t-doc           for ub.trn-doc.
  define buffer buf_clients     for ub.clients.
  define buffer buf_ot-line     for ub.ot-line.
  define buffer buf_tt-clcparts for tt-clcparts.


  define variable var-x-store-code    like ub.clients.obj-code    no-undo.
  define variable var-x-store-type    like ub.clients.obj-type    no-undo.
  define variable var-x-date-start    like ub.stk-tot.Fact-date   no-undo.
  define variable var-x-date-endt     like ub.stk-tot.Fact-date   no-undo.
  define variable var-x-sum-type      like ub.stk-tot.sum-type    no-undo.
  define variable var-x-ost-sum-type  like ub.stk-tot.sum-type    no-undo.
  define variable var-x-cat-id        like ub.stk-tot.cat-id      no-undo.
  define variable var-xTog-obj        as   log                 no-undo.

  define variable var-Quantity        like ub.stk-tot.fact-qnty   initial ? no-undo.
  define variable var-Coast_R         like ub.stk-tot.sum-rubl    no-undo.
  define variable var-Coast_V         like ub.stk-tot.sum-rubl    no-undo.
  define variable var-VAT_R           like ub.stk-tot.sum-rubl    no-undo.
  define variable var-VAT_V           like ub.stk-tot.sum-rubl    no-undo.
  define variable var-Fact-order      like ub.stk-tot.Fact-order  no-undo.

  define variable var-x-artic         like ub.stk-line.artic        no-undo.
  define variable var-x-prod-code     like ub.stk-line.prod-code    no-undo.
  define variable var-x-prod-type     like ub.stk-line.prod-type    no-undo.

  define variable var-SLT_R           like ub.stk-tot.sum-rubl    no-undo.
  define variable var-SLT_V           like ub.stk-tot.sum-rubl    no-undo.

  define variable v-fact-order-1      like ub.ot-line.fact-order no-undo .
  define variable v-fact-order-2      like ub.ot-line.fact-order no-undo .
  define variable v-shift-end-fact-order          as decimal    no-undo .
  define variable v-day-end-fact-order            as decimal    no-undo .
  define variable v-cli-local                     as character  no-undo .
  define variable v-cli-alc-producer              as character  no-undo .
  define variable v-attr-type                     as character  no-undo .
  define variable v-is-imp-gds                    as logical    no-undo .
  define variable v-is-first-line                 as logical initial yes   no-undo .
  define variable v-carret                        as logical   no-undo .
  define variable v-alc-type-name                      as character no-undo .
  define variable v-curr-r-b                      as character no-undo .
  define variable v-part-sum-r                    as decimal   no-undo .
  define variable v-part-qnty                     as decimal   no-undo .
  define variable v-ot-line-sum-r                 as decimal   no-undo .
  define variable v-ot-line-qnty                  as decimal   no-undo .

  { gbl/curr-r-b.i v-curr-r-b }

  {&pageExcel}
  find first sheetf
    where sheetf.sheet-num = 2
  no-error .
  if not available sheetf then do:
    create sheetf.
  end.
  assign
      sheetf.sheet-num   = 2
      sheetf.MergeCellsH = "4:9/6:7,8:9"
      sheetf.MergeCellsV = "1=1:3/2=1:3/3=1:3/4=2:3/5=2:3/10=1:3/11=1:3/12=1:3"
      sheetf.Excel-Column-Lable =
      "№ п/п" + {&comma-char} +
      "Наименование видов и коды алкогольной продукции" + {&comma-char} +
      "Остаток на начало года" + {&comma-char} +
      "Поступления (закупки)"  + {&comma-char} +
       {&comma-char} +
       {&comma-char} +
       {&comma-char} +
       {&comma-char} +
       {&comma-char} +
       "Розничная продажа" + {&comma-char} +
       "Списание возврат поставщику" + {&comma-char} +
       "Остаток на конец отчетного периода" + {&comma-char} +
       {&new-line}   +
       {&comma-char} +
       {&comma-char} +
       {&comma-char} +
       "Всего" + {&comma-char} +
       "От производителей края" + {&comma-char} +
       "От организации оптовой торговли края" + {&comma-char} +
       {&comma-char} +
       "От поставщиков из-за пределов края" + {&comma-char} +
       {&comma-char} +
       {&comma-char} +
       {&comma-char} +
       {&comma-char} +
       {&new-line}   +
       {&comma-char} +
       {&comma-char} +
       {&comma-char} +
       {&comma-char} +
       {&comma-char} +
       "отеч." + {&comma-char} +
       "импорт" + {&comma-char} +
       "отеч." + {&comma-char} +
       "импорт" + {&comma-char} +
       {&comma-char} +
       {&comma-char} +
       {&comma-char} +
       {&new-line}   +
       "1"  + {&comma-char} +
       "2"  + {&comma-char} +
       "3"  + {&comma-char} +
       "4"  + {&comma-char} +
       "5"  + {&comma-char} +
       "6"  + {&comma-char} +
       "7"  + {&comma-char} +
       "8"  + {&comma-char} +
       "9"  + {&comma-char} +
       "10" + {&comma-char} +
       "11" + {&comma-char} +
       "12" + {&comma-char}
    sheetf.sizes =
    "3"  + {&comma-char} +
    "50"  + {&comma-char} +
    "15"  + {&comma-char} +
    "15"  + {&comma-char} +
    "15"  + {&comma-char} +
    "15"  + {&comma-char} +
    "15"  + {&comma-char} +
    "15"  + {&comma-char} +
    "15"  + {&comma-char} +
    "15"  + {&comma-char} +
    "15"  + {&comma-char} +
    "15"
    Sheetf.colformat = "1=@;2=@;3=@;4=@;5=@;6=@;7=@;8=@;9=@;10=@;11=@;12=@;"
    /* шапка отчета  */
    ReportNAme = "ДЕКЛАРАЦИЯ ОБ ОБЪЕМАХ РОЗНИЧНОЙ ПРОДАЖИ АЛКОГОЛЬНОЙ ПРОДУКЦИИ за " + string(v-begin-date,"99/99/9999") + " - " + string(v-end-date,"99/99/9999")
    str1       = {&new-line}
    str2       = ""
    str3       = ""
    str4       = "1. Сведения о розничной продаже алкогольной продукции"
  .

  run rep/extitle.p (2).

  put stream out-stream
    "ДЕКЛАРАЦИЯ ОБ ОБЪЕМАХ РОЗНИЧНОЙ ПРОДАЖИ АЛКОГОЛЬНОЙ ПРОДУКЦИИ за " at 60
    v-begin-date format "99/99/9999" " - " v-end-date format "99/99/9999" skip
    "(отчетный период)" at 127 skip
    "1. Сведения о розничной продаже алкогольной продукции" skip
  .
  run day-begin-fact-order in this-procedure ( input v-begin-date
                                             , output v-fact-order-1
                                             ) no-error .
  if error-status:error then do:
    message error-status :get-message(1) view-as alert-box error .
    return error.
  end.
  run factord-end-day in this-procedure ( input v-end-date
                                        , output v-fact-order-2
                                        ) no-error .
  if error-status:error then do:
    message error-status :get-message(1) view-as alert-box error .
    return error.
  end.
  case x-SET_PAY_TYPE :
    when {&p-cost} then do:
      assign
        var-x-sum-type      = {&arh-cost}
        var-x-ost-sum-type  = {&arh-cost}
      .
    end.
    when {&p-crsa} then do:
      assign
        var-x-sum-type      = {&arh-sale}
        var-x-ost-sum-type  = {&arh-crsa}
      .
    end.
    otherwise do:
      assign
        var-x-sum-type      = {&arh-cost}
        var-x-ost-sum-type  = {&arh-cost}
      .
    end.
  end case.

for each tt-alc-type no-lock
  break by tt-alc-type.alc-type-code
:
  for each obj-list no-lock ,
      each tt-gds no-lock
        where tt-gds.alc-type-code = tt-alc-type.alc-type-code
  :
        assign
          var-x-store-code  = obj-list.obj-code
          var-x-store-type  = obj-list.obj-type
          var-x-artic       = tt-gds.artic
          var-x-prod-code   = tt-gds.prod-code
          var-x-prod-type   = tt-gds.prod-type
          var-x-cat-id      = {&root-cat-id}
          var-xTog-obj      = yes
        .
        RUN ost-line  (
            input   var-x-store-code,
            input   var-x-store-type,
            INPUT   var-x-artic     ,
            INPUT   var-x-prod-code ,
            INPUT   var-x-prod-type ,
            input   no              ,
            input   v-fact-order-1  ,
            input   var-x-ost-sum-type  ,
            input   var-x-cat-id    ,
            input   var-xTog-obj    ,
            output  var-Quantity    ,
            output  var-Coast_R     ,
            output  var-Coast_V     ,
            output  var-VAT_R       ,
            output  var-VAT_V       ,
            output  var-SLT_R       ,
            output  var-SLT_V       ).
        assign
          v-ost      = v-ost + var-Coast_R / {&div-num}
          v-ost-qnty = v-ost-qnty + (var-Quantity * tt-gds.ms-base / 10 )
        .
  end.
  for each obj-list no-lock,
      each tt-gds no-lock,
        each buf_ot-line no-lock
          where   buf_ot-line.artic        = tt-gds.artic
            and   buf_ot-line.prod-code    = tt-gds.prod-code
            and   buf_ot-line.prod-type    = tt-gds.prod-type
            and   buf_ot-line.fact-order   <= v-fact-order-2  /* fact-order конца периода */
            and   buf_ot-line.fact-order   >= v-fact-order-1  /* fact-order начала периода */
            and   buf_ot-line.obj-code     = obj-list.obj-code
            and   buf_ot-line.obj-type     = obj-list.obj-type
            and   buf_ot-line.sum-type     = var-x-sum-type
            and   tt-gds.alc-type-inner-code = tt-alc-type.alc-type-inner-code
            AND   tt-gds.create-user-db-num  = tt-alc-type.create-user-db-num
        /* break by tt-gds.alc-type-code ??? */
    :
        find first buf_trn-doc no-lock
          where buf_trn-doc.doc-code = buf_ot-line.doc-code
        no-error .
        if not available buf_trn-doc then do:
          message
            substitute( "Не могу найти документ &1" , buf_ot-line.doc-code )
          view-as alert-box error .
          next.
        end.
        /* определяем национальность товара */
        if tt-gds.alpha1 = "RU":U or tt-gds.nationality = "российский":U then do:
          assign
            v-is-imp-gds = no
          .
        end.
        else do:
          assign
            v-is-imp-gds = yes
          .
        end.
        run clntattr-value in this-procedure ( input buf_trn-doc.cli-type
                                             , input buf_trn-doc.cli-code
                                             , input {&attr-cli-local}
                                             , output v-cli-local
                                             , output v-attr-type
                                             ) .
        run clntattr-value in this-procedure ( input buf_trn-doc.cli-type
                                             , input buf_trn-doc.cli-code
                                             , input {&attr-cli-alc-producer}
                                             , output v-cli-alc-producer
                                             , output v-attr-type
                                             ) .


        if x-SET_PAY_TYPE = {&p-crsa} then do:
          /* текущая цена товара */
          { str/get-pr.i calc
                    buf_trn-doc.obj-type
                    buf_trn-doc.obj-code
                    tt-gds.gds-code
                    ?
          }
          assign
            v-ot-line-sum-r = abs( gp-price-sale * buf_ot-line.fact-qnty ) / {&div-num}
          .
        end.
        else do:
          assign
            v-ot-line-sum-r = abs(buf_ot-line.sum-rubl  / {&div-num})
          .
        end.
        assign
          v-ot-line-qnty  = abs(buf_ot-line.fact-qnty * tt-gds.ms-base / 10)
        .
        case buf_ot-line.ext-doc-type:
          /*  - это приход */
          when {&tdedt_pri_vnesh            }  then do:
            if logical(v-cli-local) then do:
              /* местный поставщик */
              if logical(v-cli-alc-producer) then do:
                /* поставщик - производитель */
                assign
                  v-total-local-producer      = v-total-local-producer + v-ot-line-sum-r
                  v-total-local-producer-qnty = v-total-local-producer-qnty + v-ot-line-qnty
                .
              end.
              else do:
                /* поставщик местный не производитель */
                if v-is-imp-gds then do:
                  assign
                    v-total-local-imp       = v-total-local-imp + v-ot-line-sum-r
                    v-total-local-imp-qnty  = v-total-local-imp-qnty + v-ot-line-qnty
                  .
                end.
                else do:
                  assign
                    v-total-local-rus       = v-total-local-rus + v-ot-line-sum-r
                    v-total-local-rus-qnty  = v-total-local-rus-qnty + v-ot-line-qnty
                  .
                end.
              end.
            end.
            else do:
              /* поставщик из-за пределов края */
                if v-is-imp-gds then do:
                  assign
                    v-total-not-local-imp       = v-total-not-local-imp + v-ot-line-sum-r
                    v-total-not-local-imp-qnty  = v-total-not-local-imp-qnty + v-ot-line-qnty
                  .
                end.
                else do:
                  assign
                    v-total-not-local-rus       = v-total-not-local-rus + v-ot-line-sum-r
                    v-total-not-local-rus-qnty  = v-total-not-local-rus-qnty + v-ot-line-qnty
                  .
                end.
            end.
          end.
          when {&TDEDT_Pri_Perem} then do:
            for each buf_parts no-lock
                  where buf_parts.out-code  = buf_ot-line.doc-code
                    and buf_parts.obj-type  = buf_ot-line.obj-type
                    and buf_parts.obj-code  = buf_ot-line.obj-code
                    and buf_parts.artic     = buf_ot-line.artic
                    and buf_parts.prod-type = buf_ot-line.prod-type
                    and buf_parts.prod-code = buf_ot-line.prod-code
            :
              for each buf_tt-clcparts
              on error undo, return error return-value
              :
                delete buf_tt-clcparts .
              end.

              create buf_tt-clcparts .
              buffer-copy buf_parts to buf_tt-clcparts .

              find first t-doc no-lock
                where t-doc.doc-code = buf_parts.in-code
              no-error .
              if not available t-doc then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Не найден складской документ" buf_parts.in-code
                  view-as alert-box error .
                next.
              end.
              find first buf_doc-line no-lock
                where buf_doc-line.doc-code  = buf_parts.in-code
                  and buf_doc-line.artic     = buf_ot-line.artic
                  and buf_doc-line.prod-type = buf_ot-line.prod-type
                  and buf_doc-line.prod-code = buf_ot-line.prod-code
                no-error .
              if not available buf_doc-line
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Не найдена строка документа" skip
                  "Складской документ" buf_parts.in-code skip
                  "Артикул" buf_ot-line.artic buf_ot-line.prod-type buf_ot-line.prod-code skip
                  view-as alert-box error .
                next.
              end.

              run clcprtsl_calc-ttable in this-procedure
                (input true                     /* paris-doc         */
                ,input true                     /* paris-cur         */
                ,input buf_doc-line.road-tax    /* parroad-tax       */
                ,input buf_doc-line.excise      /* parexcise         */
                ,input buf_doc-line.vat-pc      /* parvat-pc         */
                ,input buf_doc-line.cons-vat-pc /* parcons-vat-pc    */
                ,input buf_doc-line.slt-pc      /* parslt-pc         */
                ,input t-doc.base-rate          /* parbase-rate      */
                ,input t-doc.base-scale         /* parbase-scale     */
                ,input v-curr-r-b               /* parr-b            */
                ,input ?                        /* parcur-base       */
                ,input ?                        /* parcur-road-tax   */
                ,input ?                        /* parcur-excise     */
                ,input ?                        /* parcur-vat-pc     */
                ,input ?                        /* parcurcons-vat-pc */
                ,input ?                        /* parcurslt-pc      */
                ) no-error .
              if error-status :error
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Ошибка при вызове процедуры clcprtsl_calc-ttable" skip
                  error-status :get-message(1) skip
                  return-value skip
                view-as alert-box error .
                return error.
              end.
              find first tt-allsum-line
                    where tt-allsum-line.sum-type = {&sum-general}
              no-error.
              if available tt-allsum-line
              then do:
                  assign
                      v-part-sum-r =  if x-SET_PAY_TYPE = {&p-crsa} then tt-allsum-line.sum-dsc-rubl-doc / {&div-num}
                                      else tt-allsum-line.sum-dsc-rubl-acc / {&div-num}
                  .
              end.
              else do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Не найдена сумма для партии!" skip
                  error-status :get-message(1) skip
                  return-value skip
                view-as alert-box error .
                return error.
              end.
              assign
                v-part-qnty = buf_parts.fact-qnty * tt-gds.ms-base / 10
              .
              run clntattr-value in this-procedure  ( input buf_parts.supp-type
                                                    , input buf_parts.supp-code
                                                    , input {&attr-cli-local}
                                                    , output v-cli-local
                                                    , output v-attr-type
                                                    ) .
              run clntattr-value in this-procedure  ( input buf_parts.supp-type
                                                    , input buf_parts.supp-code
                                                    , input {&attr-cli-alc-producer}
                                                    , output v-cli-alc-producer
                                                    , output v-attr-type
                                                    ) .
              if logical(v-cli-local) then do:
                /* местный поставщик */
                if logical(v-cli-alc-producer) then do:
                  /* поставщик - производитель */
                  assign
                    v-total-local-producer      = v-total-local-producer + v-part-sum-r
                    v-total-local-producer-qnty = v-total-local-producer-qnty + v-part-qnty
                  .
                end.
                else do:
                  /* поставщик местный не производитель */
                  if v-is-imp-gds then do:
                    assign
                      v-total-local-imp       = v-total-local-imp + v-part-sum-r
                      v-total-local-imp-qnty  = v-total-local-imp-qnty + v-part-qnty
                    .
                  end.
                  else do:
                    assign
                      v-total-local-rus       = v-total-local-rus + v-part-sum-r
                      v-total-local-rus-qnty  = v-total-local-rus-qnty + v-part-qnty
                    .
                  end.
                end.
              end.
              else do:
                /* поставщик из-за пределов края */
                  if v-is-imp-gds then do:
                    assign
                      v-total-not-local-imp       = v-total-not-local-imp + v-part-sum-r
                      v-total-not-local-imp-qnty  = v-total-not-local-imp-qnty + v-part-qnty
                    .
                  end.
                  else do:
                    assign
                      v-total-not-local-rus       = v-total-not-local-rus + v-part-sum-r
                      v-total-not-local-rus-qnty  = v-total-not-local-rus-qnty + v-part-qnty
                    .
                  end.
              end.

            end.
          end.
          /* - расход */
          when {&tdedt_ras_vnesh            }  then do:
            assign
              v-ras       = v-ras + abs(buf_ot-line.sum-rubl  / {&div-num})
              v-ras-qnty  = v-ras-qnty + v-ot-line-qnty
            .
          end.
          when {&tdedt_ras_vnesh_kass       }  then do:
            assign
              v-ras       = v-ras + abs(buf_ot-line.sum-rubl  / {&div-num})
              v-ras-qnty  = v-ras-qnty + v-ot-line-qnty
            .
          end.
          when {&tdedt_vozvrat_vnesh        }  then do:
            assign
              v-ras       = v-ras - abs(buf_ot-line.sum-rubl  / {&div-num})
              v-ras-qnty  = v-ras-qnty - v-ot-line-qnty
            .
          end.
          when {&tdedt_vozvrat_vnesh_kass   }  then do:
            assign
              v-ras       = v-ras - abs(buf_ot-line.sum-rubl  / {&div-num})
              v-ras-qnty  = v-ras-qnty - v-ot-line-qnty
            .
          end.
          /* - списание и возврат поставщику */
          when {&tdedt_ras_vnesh_vp         } then do:
            assign
              v-spis       = v-spis + abs(buf_ot-line.sum-rubl  / {&div-num})
              v-spis-qnty  = v-spis-qnty + v-ot-line-qnty
            .
          end.
          when {&tdedt_spi_vnesh            }  then do:
            assign
              v-spis       = v-spis + abs(buf_ot-line.sum-rubl  / {&div-num})
              v-spis-qnty  = v-spis-qnty + v-ot-line-qnty
            .
          end.
          when {&TDEDT_Ras_Perem} then do:
            assign
              v-spis       = v-spis + abs(buf_ot-line.sum-rubl  / {&div-num})
              v-spis-qnty  = v-spis-qnty + v-ot-line-qnty
            .
          end.
          when {&TDEDT_Vozvrat_Perem} then do:
            assign
              v-spis       = v-spis - abs(buf_ot-line.sum-rubl  / {&div-num})
              v-spis-qnty  = v-spis-qnty - v-ot-line-qnty
            .
          end.
      end case.
   end. /* for each obj-list */
      if last-of(tt-alc-type.alc-type-code) then do:
          assign
            v-total       =   v-total-local-producer
                            + v-total-local-rus
                            + v-total-local-imp
                            + v-total-not-local-rus
                            + v-total-not-local-imp
            v-total-qnty  =   v-total-local-producer-qnty
                            + v-total-local-rus-qnty
                            + v-total-local-imp-qnty
                            + v-total-not-local-rus-qnty
                            + v-total-not-local-imp-qnty
            v-ost-end      = v-ost + v-total - v-ras - v-spis
            v-ost-end-qnty = v-ost-qnty + v-total-qnty - v-ras-qnty - v-spis-qnty
            v-gt-total                      = v-gt-total + v-total
            v-gt-total-qnty                 = v-gt-total-qnty + v-total-qnty
            v-gt-total-local-producer       = v-gt-total-local-producer + v-total-local-producer
            v-gt-total-local-rus            = v-gt-total-local-rus + v-total-local-rus
            v-gt-total-local-imp            = v-gt-total-local-imp + v-total-local-imp
            v-gt-total-not-local-rus        = v-gt-total-not-local-rus + v-total-not-local-rus
            v-gt-total-not-local-imp        = v-gt-total-not-local-imp + v-total-not-local-imp
            v-gt-total-local-producer-qnty  = v-gt-total-local-producer-qnty + v-total-local-producer-qnty
            v-gt-total-local-rus-qnty       = v-gt-total-local-rus-qnty + v-total-local-rus-qnty
            v-gt-total-local-imp-qnty       = v-gt-total-local-imp-qnty + v-total-local-imp-qnty
            v-gt-total-not-local-rus-qnty   = v-gt-total-not-local-rus-qnty + v-total-not-local-rus-qnty
            v-gt-total-not-local-imp-qnty   = v-gt-total-not-local-imp-qnty + v-total-not-local-imp-qnty
            v-gt-ras                        = v-gt-ras + v-ras
            v-gt-spis                       = v-gt-spis + v-spis
            v-gt-ras-qnty                   = v-gt-ras-qnty + v-ras-qnty
            v-gt-spis-qnty                  = v-gt-spis-qnty + v-spis-qnty
            v-gt-ost-end                    = v-gt-ost-end + v-ost-end
            v-gt-ost-end-qnty               = v-gt-ost-end-qnty + v-ost-end-qnty
            v-gt-ost                        = v-gt-ost + v-ost
            v-gt-ost-qnty                   = v-gt-ost-qnty + v-ost-qnty
            v-carret                        = no
            v-alc-type-name                 = substring(tt-alc-type.alc-type-name, 1, {&f-w-decl-alc-type-name})
          .
          if line-counter( out-stream ) + 6 > page-size( out-stream ) then do:
            page stream out-stream .
          end.

          display stream out-stream
                " 1"              @  v-sea-num
                "            2"   @  tt-gds.alc-type-name
                "       3"        @  v-str-ost-qnty
                "       4"        @  v-str-total-qnty
                "       5"        @  v-str-total-local-producer-qnty
                "       6"        @  v-str-total-local-rus-qnty
                "       7"        @  v-str-total-local-imp-qnty
                "       8"        @  v-str-total-not-local-rus-qnty
                "       9"        @  v-str-total-not-local-imp-qnty
                "      10"        @  v-str-ras-qnty
                "      11"        @  v-str-spis-qnty
                "      12"        @  v-str-ost-end-qnty
                    sym1
                    sym2
                    sym3
                    sym4
                    sym5
                    sym6
                    sym7
                    sym8
                    sym9
                    sym10
                    sym11
                    sym12
                    sym13
            with frame f-decl.
            down stream out-stream with frame f-decl.
            put stream out-stream  v-line format "X({&f-decl-width})" at 1 skip.
            if length( tt-alc-type.alc-type-name ) > {&f-w-decl-alc-type-name} then do:
              assign
                v-carret = yes
              .
            end.
            assign
              v-str-ost-qnty                  = str-format( v-ost-qnty                  , {&dal-format} , {&dal-format-len} )
              v-str-total-qnty                = str-format( v-total-qnty                , {&dal-format} , {&dal-format-len} )
              v-str-total-local-producer-qnty = str-format( v-total-local-producer-qnty , {&dal-format} , {&dal-format-len} )
              v-str-total-local-rus-qnty      = str-format( v-total-local-rus-qnty      , {&dal-format} , {&dal-format-len} )
              v-str-total-local-imp-qnty      = str-format( v-total-local-imp-qnty      , {&dal-format} , {&dal-format-len} )
              v-str-total-not-local-rus-qnty  = str-format( v-total-not-local-rus-qnty  , {&dal-format} , {&dal-format-len} )
              v-str-total-not-local-imp-qnty  = str-format( v-total-not-local-imp-qnty  , {&dal-format} , {&dal-format-len} )
              v-str-ras-qnty                  = str-format( v-ras-qnty                  , {&dal-format} , {&dal-format-len} )
              v-str-spis-qnty                 = str-format( v-spis-qnty                 , {&dal-format} , {&dal-format-len} )
              v-str-ost-end-qnty              = str-format( v-ost-end-qnty              , {&dal-format} , {&dal-format-len} )
            .
            display stream out-stream
              v-sea-num
              v-alc-type-name @ tt-gds.alc-type-name
              v-str-ost-qnty
              v-str-total-qnty
              v-str-total-local-producer-qnty
              v-str-total-local-rus-qnty
              v-str-total-local-imp-qnty
              v-str-total-not-local-rus-qnty
              v-str-total-not-local-imp-qnty
              v-str-ras-qnty
              v-str-spis-qnty
              v-str-ost-end-qnty
              sym1
              sym2
              sym3
              sym4
              sym5
              sym6
              sym7
              sym8
              sym9
              sym10
              sym11
              sym12
              sym13
            with frame f-decl.
            down stream out-stream with frame f-decl.

            assign
              v-str-ost-qnty                  = str-format( v-ost-qnty                  , {&dal-format} , 0  )
              v-str-total-qnty                = str-format( v-total-qnty                , {&dal-format} , 0  )
              v-str-total-local-producer-qnty = str-format( v-total-local-producer-qnty , {&dal-format} , 0  )
              v-str-total-local-rus-qnty      = str-format( v-total-local-rus-qnty      , {&dal-format} , 0  )
              v-str-total-local-imp-qnty      = str-format( v-total-local-imp-qnty      , {&dal-format} , 0  )
              v-str-total-not-local-rus-qnty  = str-format( v-total-not-local-rus-qnty  , {&dal-format} , 0  )
              v-str-total-not-local-imp-qnty  = str-format( v-total-not-local-imp-qnty  , {&dal-format} , 0  )
              v-str-ras-qnty                  = str-format( v-ras-qnty                  , {&dal-format} , 0  )
              v-str-spis-qnty                 = str-format( v-spis-qnty                 , {&dal-format} , 0  )
              v-str-ost-end-qnty              = str-format( v-ost-end-qnty              , {&dal-format} , 0  )
            .
            {&PutExcel}
              v-sea-num                       {&tabulation}
              tt-alc-type.alc-type-name              {&tabulation}
              v-str-ost-qnty                  {&tabulation}
              v-str-total-qnty                {&tabulation}
              v-str-total-local-producer-qnty {&tabulation}
              v-str-total-local-rus-qnty      {&tabulation}
              v-str-total-local-imp-qnty      {&tabulation}
              v-str-total-not-local-rus-qnty  {&tabulation}
              v-str-total-not-local-imp-qnty  {&tabulation}
              v-str-ras-qnty                  {&tabulation}
              v-str-spis-qnty                 {&tabulation}
              v-str-ost-end-qnty              {&tabulation}
            skip.

            assign
              v-str-ost-qnty                  = str-format( v-ost                  , {&sum-format} , {&sum-format-len} )
              v-str-total-qnty                = str-format( v-total                , {&sum-format} , {&sum-format-len} )
              v-str-total-local-producer-qnty = str-format( v-total-local-producer , {&sum-format} , {&sum-format-len} )
              v-str-total-local-rus-qnty      = str-format( v-total-local-rus      , {&sum-format} , {&sum-format-len} )
              v-str-total-local-imp-qnty      = str-format( v-total-local-imp      , {&sum-format} , {&sum-format-len} )
              v-str-total-not-local-rus-qnty  = str-format( v-total-not-local-rus  , {&sum-format} , {&sum-format-len} )
              v-str-total-not-local-imp-qnty  = str-format( v-total-not-local-imp  , {&sum-format} , {&sum-format-len} )
              v-str-ras-qnty                  = str-format( v-ras                  , {&sum-format} , {&sum-format-len} )
              v-str-spis-qnty                 = str-format( v-spis                 , {&sum-format} , {&sum-format-len} )
              v-str-ost-end-qnty              = str-format( v-ost-end              , {&sum-format} , {&sum-format-len} )
            .
            display stream out-stream
              " " @ v-sea-num
              substring(tt-alc-type.alc-type-name, {&f-w-decl-alc-type-name}, length(tt-alc-type.alc-type-name)) when v-carret @ tt-gds.alc-type-name
              v-str-ost-qnty
              v-str-total-qnty
              v-str-total-local-producer-qnty
              v-str-total-local-rus-qnty
              v-str-total-local-imp-qnty
              v-str-total-not-local-rus-qnty
              v-str-total-not-local-imp-qnty
              v-str-ras-qnty
              v-str-spis-qnty
              v-str-ost-end-qnty
              sym1
              sym2
              sym3
              sym4
              sym5
              sym6
              sym7
              sym8
              sym9
              sym10
              sym11
              sym12
              sym13
            with frame f-decl.
            down stream out-stream with frame f-decl.
            put stream out-stream v-line format "X({&f-decl-width})" at 1 SKIP.

            assign
              v-str-ost-qnty                  = str-format( v-ost                  , {&sum-format} , 0 )
              v-str-total-qnty                = str-format( v-total                , {&sum-format} , 0 )
              v-str-total-local-producer-qnty = str-format( v-total-local-producer , {&sum-format} , 0 )
              v-str-total-local-rus-qnty      = str-format( v-total-local-rus      , {&sum-format} , 0 )
              v-str-total-local-imp-qnty      = str-format( v-total-local-imp      , {&sum-format} , 0 )
              v-str-total-not-local-rus-qnty  = str-format( v-total-not-local-rus  , {&sum-format} , 0 )
              v-str-total-not-local-imp-qnty  = str-format( v-total-not-local-imp  , {&sum-format} , 0 )
              v-str-ras-qnty                  = str-format( v-ras                  , {&sum-format} , 0 )
              v-str-spis-qnty                 = str-format( v-spis                 , {&sum-format} , 0 )
              v-str-ost-end-qnty              = str-format( v-ost-end              , {&sum-format} , 0 )
            .
            {&PutExcel}
              " "                             {&tabulation}
              " "                             {&tabulation}
              v-str-ost-qnty                  {&tabulation}
              v-str-total-qnty                {&tabulation}
              v-str-total-local-producer-qnty {&tabulation}
              v-str-total-local-rus-qnty      {&tabulation}
              v-str-total-local-imp-qnty      {&tabulation}
              v-str-total-not-local-rus-qnty  {&tabulation}
              v-str-total-not-local-imp-qnty  {&tabulation}
              v-str-ras-qnty                  {&tabulation}
              v-str-spis-qnty                 {&tabulation}
              v-str-ost-end-qnty              {&tabulation}
            skip.
        assign
          v-total-local-producer        = 0
          v-total-local-rus             = 0
          v-total-local-imp             = 0
          v-total-not-local-rus         = 0
          v-total-not-local-imp         = 0
          v-total-local-producer-qnty   = 0
          v-total-local-rus-qnty        = 0
          v-total-local-imp-qnty        = 0
          v-total-not-local-rus-qnty    = 0
          v-total-not-local-imp-qnty    = 0
          v-ras                         = 0
          v-spis                        = 0
          v-ras-qnty                    = 0
          v-spis-qnty                   = 0
          v-ost                         = 0
          v-ost-qnty                    = 0
          v-ost-end                     = 0
          v-ost-end-qnty                = 0
          v-sea-num                     = v-sea-num + 1
        .
      end.

end.
  assign
    v-str-ost-qnty                  = str-format( v-gt-ost-qnty                  , {&dal-format} , {&dal-format-len} )
    v-str-total-qnty                = str-format( v-gt-total-qnty                , {&dal-format} , {&dal-format-len} )
    v-str-total-local-producer-qnty = str-format( v-gt-total-local-producer-qnty , {&dal-format} , {&dal-format-len} )
    v-str-total-local-rus-qnty      = str-format( v-gt-total-local-rus-qnty      , {&dal-format} , {&dal-format-len} )
    v-str-total-local-imp-qnty      = str-format( v-gt-total-local-imp-qnty      , {&dal-format} , {&dal-format-len} )
    v-str-total-not-local-rus-qnty  = str-format( v-gt-total-not-local-rus-qnty  , {&dal-format} , {&dal-format-len} )
    v-str-total-not-local-imp-qnty  = str-format( v-gt-total-not-local-imp-qnty  , {&dal-format} , {&dal-format-len} )
    v-str-ras-qnty                  = str-format( v-gt-ras-qnty                  , {&dal-format} , {&dal-format-len} )
    v-str-spis-qnty                 = str-format( v-gt-spis-qnty                 , {&dal-format} , {&dal-format-len} )
    v-str-ost-end-qnty              = str-format( v-gt-ost-end-qnty              , {&dal-format} , {&dal-format-len} )
  .
  display stream out-stream
    " "                             @ v-sea-num
    "ИТОГО:  "                      @ tt-gds.alc-type-name
    v-str-ost-qnty
    v-str-total-qnty
    v-str-total-local-producer-qnty
    v-str-total-local-rus-qnty
    v-str-total-local-imp-qnty
    v-str-total-not-local-rus-qnty
    v-str-total-not-local-imp-qnty
    v-str-ras-qnty
    v-str-spis-qnty
    v-str-ost-end-qnty
    sym1
    sym2
    sym3
    sym4
    sym5
    sym6
    sym7
    sym8
    sym9
    sym10
    sym11
    sym12
    sym13
  with frame f-decl.
  down stream out-stream with frame f-decl.

  assign
    v-str-ost-qnty                  = str-format( v-gt-ost-qnty                  , {&dal-format} , 0 )
    v-str-total-qnty                = str-format( v-gt-total-qnty                , {&dal-format} , 0 )
    v-str-total-local-producer-qnty = str-format( v-gt-total-local-producer-qnty , {&dal-format} , 0 )
    v-str-total-local-rus-qnty      = str-format( v-gt-total-local-rus-qnty      , {&dal-format} , 0 )
    v-str-total-local-imp-qnty      = str-format( v-gt-total-local-imp-qnty      , {&dal-format} , 0 )
    v-str-total-not-local-rus-qnty  = str-format( v-gt-total-not-local-rus-qnty  , {&dal-format} , 0 )
    v-str-total-not-local-imp-qnty  = str-format( v-gt-total-not-local-imp-qnty  , {&dal-format} , 0 )
    v-str-ras-qnty                  = str-format( v-gt-ras-qnty                  , {&dal-format} , 0 )
    v-str-spis-qnty                 = str-format( v-gt-spis-qnty                 , {&dal-format} , 0 )
    v-str-ost-end-qnty              = str-format( v-gt-ost-end-qnty              , {&dal-format} , 0 )
  .
  {&PutExcel}
    ""                              {&tabulation}
    "ИТОГО:"                        {&tabulation}
    v-str-ost-qnty                  {&tabulation}
    v-str-total-qnty                {&tabulation}
    v-str-total-local-producer-qnty {&tabulation}
    v-str-total-local-rus-qnty      {&tabulation}
    v-str-total-local-imp-qnty      {&tabulation}
    v-str-total-not-local-rus-qnty  {&tabulation}
    v-str-total-not-local-imp-qnty  {&tabulation}
    v-str-ras-qnty                  {&tabulation}
    v-str-spis-qnty                 {&tabulation}
    v-str-ost-end-qnty              {&tabulation}
  skip.

  assign
    v-str-ost-qnty                  = str-format( v-gt-ost                  , {&sum-format} , {&sum-format-len} )
    v-str-total-qnty                = str-format( v-gt-total                , {&sum-format} , {&sum-format-len} )
    v-str-total-local-producer-qnty = str-format( v-gt-total-local-producer , {&sum-format} , {&sum-format-len} )
    v-str-total-local-rus-qnty      = str-format( v-gt-total-local-rus      , {&sum-format} , {&sum-format-len} )
    v-str-total-local-imp-qnty      = str-format( v-gt-total-local-imp      , {&sum-format} , {&sum-format-len} )
    v-str-total-not-local-rus-qnty  = str-format( v-gt-total-not-local-rus  , {&sum-format} , {&sum-format-len} )
    v-str-total-not-local-imp-qnty  = str-format( v-gt-total-not-local-imp  , {&sum-format} , {&sum-format-len} )
    v-str-ras-qnty                  = str-format( v-gt-ras                  , {&sum-format} , {&sum-format-len} )
    v-str-spis-qnty                 = str-format( v-gt-spis                 , {&sum-format} , {&sum-format-len} )
    v-str-ost-end-qnty              = str-format( v-gt-ost-end              , {&sum-format} , {&sum-format-len} )
  .
  display stream out-stream
    " "                                               @ v-sea-num
    " "                                               @ tt-gds.alc-type-name
    v-str-ost-qnty
    v-str-total-qnty
    v-str-total-local-producer-qnty
    v-str-total-local-rus-qnty
    v-str-total-local-imp-qnty
    v-str-total-not-local-rus-qnty
    v-str-total-not-local-imp-qnty
    v-str-ras-qnty
    v-str-spis-qnty
    v-str-ost-end-qnty
    sym1
    sym2
    sym3
    sym4
    sym5
    sym6
    sym7
    sym8
    sym9
    sym10
    sym11
    sym12
    sym13
  with frame f-decl.
  down stream out-stream with frame f-decl.
  put stream out-stream v-line format "X({&f-decl-width})" at 1 SKIP.
  page stream out-stream.

  assign
    v-str-ost-qnty                  = str-format( v-gt-ost                  , {&sum-format} , 0  )
    v-str-total-qnty                = str-format( v-gt-total                , {&sum-format} , 0  )
    v-str-total-local-producer-qnty = str-format( v-gt-total-local-producer , {&sum-format} , 0  )
    v-str-total-local-rus-qnty      = str-format( v-gt-total-local-rus      , {&sum-format} , 0  )
    v-str-total-local-imp-qnty      = str-format( v-gt-total-local-imp      , {&sum-format} , 0  )
    v-str-total-not-local-rus-qnty  = str-format( v-gt-total-not-local-rus  , {&sum-format} , 0  )
    v-str-total-not-local-imp-qnty  = str-format( v-gt-total-not-local-imp  , {&sum-format} , 0  )
    v-str-ras-qnty                  = str-format( v-gt-ras                  , {&sum-format} , 0  )
    v-str-spis-qnty                 = str-format( v-gt-spis                 , {&sum-format} , 0  )
    v-str-ost-end-qnty              = str-format( v-gt-ost-end              , {&sum-format} , 0  )
  .
  {&PutExcel}
    ""                              {&tabulation}
    ""                              {&tabulation}
    v-str-ost-qnty                  {&tabulation}
    v-str-total-qnty                {&tabulation}
    v-str-total-local-producer-qnty {&tabulation}
    v-str-total-local-rus-qnty      {&tabulation}
    v-str-total-local-imp-qnty      {&tabulation}
    v-str-total-not-local-rus-qnty  {&tabulation}
    v-str-total-not-local-imp-qnty  {&tabulation}
    v-str-ras-qnty                  {&tabulation}
    v-str-spis-qnty                 {&tabulation}
    v-str-ost-end-qnty              {&tabulation}
  skip.
end.

end procedure. /* print-decl */


procedure find-alc-goods :

do
on error undo, return error return-value
:

  define buffer buf_alc-type      for ub.alc-type.
  define buffer buf_alc-type-gds  for ub.alc-type-gds.
  define buffer buf_goods         for ub.goods.

  /* заполняем список алкогольных товаров */
  empty temp-table tt-gds.
  empty temp-table tt-alc-type.
  for each buf_alc-type no-lock
        where buf_alc-type.alc-type-status = 0
  :
    create tt-alc-type.
    buffer-copy buf_alc-type to tt-alc-type.
    for each buf_alc-type-gds no-lock
          where buf_alc-type-gds.alc-type-inner-code = buf_alc-type.alc-type-inner-code
            AND buf_alc-type-gds.create-user-db-num  = buf_alc-type.create-user-db-num
      , first buf_goods no-lock
          where buf_goods.gds-code = buf_alc-type-gds.gds-code
    :
      find first tt-gds no-lock where tt-gds.gds-code = buf_goods.gds-code no-error .
      if not available tt-gds then do:
        create tt-gds.
        buffer-copy buf_goods to tt-gds
        assign
          tt-gds.alc-type-inner-code = buf_alc-type.alc-type-inner-code
          tt-gds.create-user-db-num  = buf_alc-type.create-user-db-num
          tt-gds.alc-type-code       = buf_alc-type.alc-type-code
          tt-gds.alc-type-name       = buf_alc-type.alc-type-name
        .
      end.
    end.
  end.

end.

end procedure. /* find-alc-goods */


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
  define variable v-sert-code             as character no-undo .
  define variable v-sert-date             as character no-undo .

  for each   buf_alc-supp-lic
       where buf_alc-supp-lic.cli-type = p-cli-type
         and buf_alc-supp-lic.cli-code = p-cli-code
         and buf_alc-supp-lic.date-to  > x-Date-Alone
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
  /*
  find first buf_sert-join  no-lock
    where buf_sert-join.cli-type = p-cli-type
      and buf_sert-join.cli-code = p-cli-code
  no-error .
  if not available buf_sert-join then do:
    assign
      v-sert-code = ""
      p-sert-give = ""
      v-sert-date = ""
    .
  end.
  else do:
    find first buf_sert no-lock
      where buf_sert.sert-code = buf_sert-join.sert-code
    no-error .
    if not available buf_sert then do:
      assign
        v-sert-code = ""
        p-sert-give = ""
        v-sert-date = ""
      .
    end.
    else do:
      assign
        v-sert-code = buf_sert.sert-code
        p-sert-give = buf_sert.ps
        v-sert-date = string( buf_sert.first-date , "99/99/9999" )
      .
    end.
  end.
  if p-sert-give = ""  then do:
    assign
      p-sert-give = {&stroke}
    .
  end.
  if v-sert-code = "" or v-sert-code = ? then do:
    assign
      p-sert = {&stroke}
    .
  end.
  else do:
    if v-sert-date = "" or v-sert-date = ? then do:
      assign
        p-sert = substitute("&1", v-sert-code)
      .
    end.
    else do:
      assign
        p-sert = substitute("&1, &2", v-sert-code, v-sert-date)
      .
    end.
  end.
  */
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

procedure create-tt-alc-pri :

do
on error undo, return error return-value
:
  define buffer buf_tt-alc-pri for tt-alc-pri.
  define buffer t-doc          for ub.trn-doc.
  define buffer buf_goods      for ub.goods.
  define buffer buf_obj-list   for obj-list.

  define variable v-doc-code              like ub.doc-line.doc-code  no-undo .
  define variable v-doc-date              like ub.trn-doc.fact-date  no-undo .
  define variable v-ms-base               like ub.goods.ms-base      no-undo .
  define variable v-qnty                  like ub.doc-line.fact-qnty no-undo .
  define variable v-attr-value            as character            no-undo .
  define variable v-attr-type             as character            no-undo .
  define variable v-fact-order-1          like ub.ot-line.fact-order no-undo .
  define variable v-fact-order-2          like ub.ot-line.fact-order no-undo .
  define variable v-shift-end-fact-order  as decimal              no-undo .
  define variable v-day-end-fact-order    as decimal              no-undo .
  define variable v-income-doc-code       like ub.trn-doc.doc-code   no-undo .

  empty temp-table tt-alc-pri.

  for each tt-alc-type no-lock,
      each obj-list no-lock ,
      each buf_trn-doc no-lock
            where buf_trn-doc.obj-type     = obj-list.obj-type
              and buf_trn-doc.obj-code     = obj-list.obj-code
              and buf_trn-doc.status_      = {&fact}
              and buf_trn-doc.fact-date   >= v-begin-date
              and buf_trn-doc.fact-date   <= v-end-date
              and ( buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
                or  buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem}) ,
      each buf_doc-line no-lock
            where buf_doc-line.doc-code    = buf_trn-doc.doc-code ,
      first tt-gds no-lock
            where buf_doc-line.artic       = tt-gds.artic
              and buf_doc-line.prod-type   = tt-gds.prod-type
              and buf_doc-line.prod-code   = tt-gds.prod-code
              and tt-gds.alc-type-inner-code          = tt-alc-type.alc-type-inner-code
              AND tt-gds.create-user-db-num          = tt-alc-type.create-user-db-num
    :
      /* если это внутренний приход */
      if buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem} then do:
        for each buf_parts no-lock
              where buf_parts.out-code  = buf_trn-doc.doc-code
                and buf_parts.obj-type  = buf_trn-doc.obj-type
                and buf_parts.obj-code  = buf_trn-doc.obj-code
                and buf_parts.artic     = buf_doc-line.artic
                and buf_parts.prod-type = buf_doc-line.prod-type
                and buf_parts.prod-code = buf_doc-line.prod-code
        :
          /* ищем товар для определения объема товара */
          find first buf_goods no-lock
            where buf_goods.artic     = buf_parts.artic
              and buf_goods.prod-type = buf_parts.prod-type
              and buf_goods.prod-code = buf_parts.prod-code
          no-error .
          if not available buf_goods then do:
            message
              "Не найден товар!" skip
              buf_parts.artic skip
              buf_parts.prod-type skip
              buf_parts.prod-code
            view-as alert-box error.
          end.
          /* находим приходный документ */
          run find-income-doc-code in this-procedure ( input buf_parts.in-code
                                                     , input buf_goods.gds-code
                                                     , input buf_parts.part-code
                                                     , output v-income-doc-code
                                                     ).
          find first t-doc no-lock
            where t-doc.doc-code = v-income-doc-code
          no-error .
          if not available t-doc then do:
            message
              substitute("Не могу найти накладную с номером: &1", buf_parts.in-code)
            view-as alert-box error .
            next.
          end.
          /*
            если партия из документа за отчетный период и по объекту из списка объектов
            участвующих в формировании отчета, то пропускаем его, он учтется как внешний приход
          */
          if    t-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
            and t-doc.fact-date   >= v-begin-date
            and t-doc.fact-date   <= v-end-date
          then do:
            find first buf_obj-list no-lock
              where buf_obj-list.obj-type = t-doc.obj-type
                and buf_obj-list.obj-code = t-doc.obj-code
            no-error .
            if available buf_obj-list then do :
              next.
            end.
          end.

          /* дата документа из атрибутов */
          { str/tdat-val.i
            t-doc.doc-code
            {&trdcattr-dids}
            v-attr-value
            v-attr-type
            }
          assign
            v-doc-date = if v-attr-value = "" or v-attr-value = ? then t-doc.fact-date else date( v-attr-value )
          .
          /* номер документа из атрибутов */
          { str/tdat-val.i
            t-doc.doc-code
            {&trdcattr-nids}
            v-attr-value
            v-attr-type
            }
          assign
            v-doc-code = if v-attr-value = "" or v-attr-value = ? then
                            (if buf_parts.in-code <> ? then buf_parts.in-code else "" )
                         else v-attr-value
          .
          find first buf_tt-alc-pri no-lock
            where buf_tt-alc-pri.alc-type-inner-code = tt-alc-type.alc-type-inner-code
              AND buf_tt-alc-pri.create-user-db-num  = tt-alc-type.create-user-db-num
              and buf_tt-alc-pri.doc-code   = v-doc-code
              and buf_tt-alc-pri.artic      = buf_parts.artic
              and buf_tt-alc-pri.prod-type  = buf_parts.prod-type
              and buf_tt-alc-pri.prod-code  = buf_parts.prod-code
          no-error .
          if available buf_tt-alc-pri then do:
            assign
              v-qnty = buf_tt-alc-pri.fact-qnty
              buf_tt-alc-pri.fact-qnty = buf_tt-alc-pri.fact-qnty + buf_parts.fact-qnty
            .
          end.
          else do:
            create tt-alc-pri.
            assign
              tt-alc-pri.alc-type-inner-code  = tt-alc-type.alc-type-inner-code
              tt-alc-pri.create-user-db-num   = tt-alc-type.create-user-db-num
              tt-alc-pri.alc-type-code        = tt-alc-type.alc-type-code
              tt-alc-pri.doc-code             = v-doc-code
              tt-alc-pri.artic                = buf_parts.artic
              tt-alc-pri.prod-type            = buf_parts.prod-type
              tt-alc-pri.prod-code            = buf_parts.prod-code
              tt-alc-pri.fact-qnty            = buf_parts.fact-qnty
              tt-alc-pri.cli-type             = t-doc.cli-type
              tt-alc-pri.cli-code             = t-doc.cli-code
              tt-alc-pri.fact-date            = v-doc-date
              tt-alc-pri.ms-base              = if available buf_goods then buf_goods.ms-base else 0
            .
          end.
        end.
      end.
      else do: /* по строке накладной */
        /* ищем товар для определения объема товара */
        find first buf_goods no-lock
          where buf_goods.artic     = buf_doc-line.artic
            and buf_goods.prod-type = buf_doc-line.prod-type
            and buf_goods.prod-code = buf_doc-line.prod-code
        no-error .
        if not available buf_goods then do:
          message
            "Не найден товар!" skip
            buf_doc-line.artic skip
            buf_doc-line.prod-type skip
            buf_doc-line.prod-code
          view-as alert-box error.
        end.

        /* дата документа из атрибутов */
        { str/tdat-val.i
         buf_trn-doc.doc-code
         {&trdcattr-dids}
         v-attr-value
         v-attr-type
        }
        assign
          v-doc-date = if v-attr-value = "" or v-attr-value = ? then buf_trn-doc.fact-date else date( v-attr-value )
        .
        /* номер документа из атрибутов */
        { str/tdat-val.i
          buf_trn-doc.doc-code
          {&trdcattr-nids}
          v-attr-value
          v-attr-type
          }
        assign
          v-doc-code = if v-attr-value = "" or v-attr-value = ? then buf_trn-doc.doc-code else v-attr-value
        .
        find first buf_tt-alc-pri no-lock
          where buf_tt-alc-pri.alc-type-inner-code  = tt-alc-type.alc-type-inner-code
            and buf_tt-alc-pri.create-user-db-num   = tt-alc-type.create-user-db-num
            and buf_tt-alc-pri.alc-type-code        = tt-alc-type.alc-type-code
            and buf_tt-alc-pri.doc-code             = v-doc-code
            and buf_tt-alc-pri.artic                = buf_doc-line.artic
            and buf_tt-alc-pri.prod-type            = buf_doc-line.prod-type
            and buf_tt-alc-pri.prod-code            = buf_doc-line.prod-code
        no-error .
        if available buf_tt-alc-pri then do:
          assign
            v-qnty = buf_tt-alc-pri.fact-qnty
            buf_tt-alc-pri.fact-qnty = buf_tt-alc-pri.fact-qnty + buf_doc-line.fact-qnty
          .
        end.
        else do:
          create tt-alc-pri.
          assign
            tt-alc-pri.alc-type-inner-code  = tt-alc-type.alc-type-inner-code
            tt-alc-pri.create-user-db-num   = tt-alc-type.create-user-db-num
            tt-alc-pri.alc-type-code        = tt-alc-type.alc-type-code
            tt-alc-pri.doc-code             = v-doc-code
            tt-alc-pri.artic                = buf_doc-line.artic
            tt-alc-pri.prod-type            = buf_doc-line.prod-type
            tt-alc-pri.prod-code            = buf_doc-line.prod-code
            tt-alc-pri.fact-qnty            = buf_doc-line.fact-qnty
            tt-alc-pri.cli-type             = buf_trn-doc.cli-type
            tt-alc-pri.cli-code             = buf_trn-doc.cli-code
            tt-alc-pri.fact-date            = v-doc-date
            tt-alc-pri.ms-base              = if available buf_goods then buf_goods.ms-base else 0
          .
        end.
      end.

    end.
end.

end procedure. /* create-tt-alc-pri */

procedure print-alc-pri2 :

do
on error undo, return error return-value
:
  define buffer buf_parts     for ub.parts.
  define buffer t-doc         for ub.trn-doc.
  define buffer buf_alc-type  for ub.alc-type.

  define variable v-sert-code             as character no-undo .
  define variable v-sert-date             as character no-undo .
  define variable v-is-null-rec           as logical   no-undo .
  define variable v-is-first-alc-type-name-str as logical init yes  no-undo .
  define variable v-alc-type-name              as character no-undo .
  define variable v-doc-num-list          as character no-undo .
  define variable v-doc-date-list         as character no-undo .
  define variable v-dal-list              as character no-undo .
  define variable v-count                 as integer   no-undo .
  define variable v-i                     as integer   no-undo .
  define variable v-doc                   as character no-undo .
  define variable v-date                  as character no-undo .
  define variable v-dal                   as decimal   no-undo .

  {&pageExcel}
  find first sheetf
    where sheetf.sheet-num = 3
  no-error .
  if not available sheetf then do:
    create sheetf.
  end.
  assign
      sheetf.sheet-num   = 3
      sheetf.MergeCellsH = "3:7/6:7"
      sheetf.MergeCellsV = "1=1:3/2=1:3/3=2:3/4=2:3/5=2:3/8=1:3/9=1:3"
      sheetf.Excel-Column-Lable =
      "№ п/п"                                         + {&comma-char} +
      "Наименование видов алкогольной продукции"      + {&comma-char} +
      "Поставщик"                                     + {&comma-char} +
                                                        {&comma-char} +
                                                        {&comma-char} +
                                                        {&comma-char} +
                                                        {&comma-char} +
       "Дата и номер товарно-транспортной накладной"  + {&comma-char} +
       "Объем закупленой продукции"                   + {&comma-char} +
       {&new-line}   +
                                                        {&comma-char} +
                                                        {&comma-char} +
       "наименование поставщика"                      + {&comma-char} +
       "{&abbr_inn_allshift}"                         + {&comma-char} +
       "место нахождения (юридический адрес)"         + {&comma-char} +
       "лицензия"                                     + {&comma-char} +
                                                        {&comma-char} +
       {&new-line}   +
                                                        {&comma-char} +
                                                        {&comma-char} +
                                                        {&comma-char} +
                                                        {&comma-char} +
                                                        {&comma-char} +
       "серия номер дата выдачи"                      + {&comma-char} +
       "кем выдана"                                   + {&comma-char} +
                                                        {&comma-char} +
                                                        {&comma-char} +
       {&new-line}   +
       "1"  + {&comma-char} +
       "2"  + {&comma-char} +
       "3"  + {&comma-char} +
       "4"  + {&comma-char} +
       "5"  + {&comma-char} +
       "6"  + {&comma-char} +
       "7"  + {&comma-char} +
       "8"  + {&comma-char} +
       "9"  + {&comma-char}
    sheetf.sizes =
    "3"  + {&comma-char} +
    "40"  + {&comma-char} +
    "40"  + {&comma-char} +
    "15"  + {&comma-char} +
    "60"  + {&comma-char} +
    "20"  + {&comma-char} +
    "20"  + {&comma-char} +
    "20"  + {&comma-char} +
    "12"
    Sheetf.colformat = "1=0;2=@;3=@;4=@;5=@;6=@;7=@;8=@;9=@;"
    /* шапка отчета  */
    ReportNAme = "ДЕКЛАРАЦИЯ ОБ ОБЪЕМАХ РОЗНИЧНОЙ ПРОДАЖИ АЛКОГОЛЬНОЙ ПРОДУКЦИИ за " + string(v-begin-date,"99/99/9999") + " - " + string(v-end-date,"99/99/9999")
    str1       = {&new-line}
    str2       = ""
    str3       = ""
    str4       = "2. Сведения об объемах закупки и поставщиках алкогольной продукции"
  .

  run rep/extitle.p (3).

  put stream out-stream
        skip (3)
        "2. Сведения об объемах закупки и поставщиках алкогольной продукции"
        skip (2)
  .
  assign
    v-sea-num = 0
  .
  /* создаем временную табличку со строками накладных */
  run create-tt-alc-pri in this-procedure .

  for each tt-alc-type no-lock
    use-index i-alc-type-code
    :
    assign
      v-is-null-rec = yes
      v-sea-num     = v-sea-num + 1
      v-alc-type-name  = tt-alc-type.alc-type-name
      v-is-first-alc-type-name-str = yes
    .
    /* печатаем тип алкогольной продукции */
    do while length(v-alc-type-name) > 0
    :
      display stream out-stream
        v-sea-num when v-is-first-alc-type-name-str
        substring(v-alc-type-name, 1, {&f-w-alc-type-name}) @ tt-gds.alc-type-name
        {&stroke} @ v-fmtcli-name
        {&stroke} @ v-fmtcli-inn
        {&stroke} @ v-addres
        {&stroke} @ v-sert
        {&stroke} @ v-sert-give
        {&stroke} @ v-doc-num-date
        {&stroke} @ v-str-dal
        sym1
        sym2
        sym3
        sym4
        sym5
        sym6
        sym7
        sym8
        sym9
        sym10
      with frame f-in.
      down stream out-stream with frame f-in.
      assign
        v-alc-type-name = substring(v-alc-type-name, {&f-w-alc-type-name} + 1 , length(v-alc-type-name))
        v-is-first-alc-type-name-str = no
      .
    end.
    assign
      v-alc-type-name  = tt-alc-type.alc-type-name
    .
    /* считаем данные по накладным  */
    for each tt-alc-pri no-lock
      where tt-alc-pri.alc-type-inner-code = tt-alc-type.alc-type-inner-code
        and tt-alc-pri.create-user-db-num  = tt-alc-type.create-user-db-num
      break by tt-alc-pri.alc-type-inner-code
            BY tt-alc-pri.create-user-db-num
            by tt-alc-pri.cli-type
            by tt-alc-pri.cli-code
            by tt-alc-pri.fact-date
            by tt-alc-pri.doc-code
    :
      /* последняя строка документа, выводим суммы */
      if last-of( tt-alc-pri.doc-code ) then do:
        /* собираем данные по накладной */
        run fmtcli-get-client in this-procedure
                  ( input  tt-alc-pri.cli-type
                  , input  tt-alc-pri.cli-code
                  ) .
        if v-fmtcli-addres = "" then do:
          assign
            v-addres = {&stroke}
          .
        end.
        else do:
          assign
            v-addres = v-fmtcli-addres
          .
        end.
        run find-sert ( input tt-alc-pri.cli-type
                      , input tt-alc-pri.cli-code
                      , input tt-alc-pri.alc-type-inner-code
                      , output v-sert
                      , output v-sert-give
                      ) .
        assign
          v-doc-num-date  = substitute("&1, &2", tt-alc-pri.doc-code , tt-alc-pri.fact-date)
          v-dal           = v-dal + ( tt-alc-pri.fact-qnty * tt-alc-pri.ms-base / 10 )
          v-str-dal       = str-format(v-dal, {&dal-format}, {&dal-format-len})
          v-fmtcli-name   = if v-fmtcli-name = "" or v-fmtcli-name = ? then {&stroke} else v-fmtcli-name
          v-fmtcli-inn    = if v-fmtcli-inn = "" or v-fmtcli-inn = ? then {&stroke} else v-fmtcli-inn
        .
        /* выводим данные по накладной */
        display stream out-stream
          v-fmtcli-name
          v-fmtcli-inn
          v-addres
          v-sert
          v-sert-give
          v-doc-num-date
          v-str-dal
          sym1
          sym2
          sym3
          sym4
          sym5
          sym6
          sym7
          sym8
          sym9
          sym10
        with frame f-in.
        down stream out-stream with frame f-in.

        /* выводим в Excel */
        assign
          v-str-dal       = str-format(v-dal, {&dal-format}, 0 )
        .

        {&PutExcel}
          if v-is-null-rec then string(v-sea-num)  else "" {&tabulation}
          if v-is-null-rec then v-alc-type-name else "" {&tabulation}
          v-fmtcli-name   {&tabulation}
          v-fmtcli-inn    {&tabulation}
          v-addres        {&tabulation}
          v-sert          {&tabulation}
          v-sert-give     {&tabulation}
          v-doc-num-date  {&tabulation}
          v-str-dal       {&tabulation}
        skip.

        /* обнуляем литраж */
        assign
          v-dal           = 0
          v-str-dal       = ""
          v-doc-num-date  = ""
          v-is-null-rec   = no
        .
      end.
      /* собираем литраж по одному документу */
      else do:
        assign
          v-dal = v-dal + ( tt-alc-pri.fact-qnty * tt-alc-pri.ms-base / 10 )
        .
      end.
    end. /* считаем данные по накладным  */

    /* строка-разделитель */
    put stream out-stream v-line format "X({&f-width})" at 1 SKIP.
  end.

  if line-counter( out-stream ) + 13 > page-size( out-stream ) then do:
    page stream out-stream .
  end.
  put stream out-stream
    skip(2)
    "Примечание:" skip
    "Дал(декалитр, десять литров) - единица измерения алкогольной продукции (количество бутылок x емкость : 10)." skip (2)
    "М.П." "Руководитель организации" at 160 skip
    "____________________________________" at 160 skip
    "(Ф.И.О.)" at 170 skip(2)
    "Главный бухгалтер" at 160 skip
    "____________________________________" at 160 skip
    "(Ф.И.О.)" at 170 skip(2)
  .

  {&PutExcel}
  skip(2)
  "Примечание:" skip
  "Дал(декалитр, десять литров) - единица измерения алкогольной продукции (количество бутылок x емкость : 10)." skip (2)

  "М.П."
  fill({&tabulation}, 6)
  "Руководитель организации" skip(1)
  fill({&tabulation}, 6)
  "____________________________________" skip
  fill({&tabulation}, 6)
  fill(" ",15) "(Ф.И.О.)" skip(2)

  fill({&tabulation}, 6)
  "Главный бухгалтер" skip(1)
  fill({&tabulation}, 6)
  "____________________________________" skip
  fill({&tabulation}, 6)
  fill(" ",15) "(Ф.И.О.)"
  skip.

  /* чистим временную табличку */
  empty temp-table tt-alc-pri.
end.

end procedure. /* print-alc-pri2 */


procedure find-income-doc-code :
/* -----------------------------------------------------------
  purpose:
  parameters:  <none>
  notes:
-------------------------------------------------------------*/
define input  parameter p-in-code         like ub.parts.in-code    no-undo .
define input  parameter p-gds-code        like ub.goods.gds-code   no-undo .
define input  parameter p-part-code       like ub.parts.part-code  no-undo .
define output parameter p-income-doc-code like ub.parts.in-code    no-undo .

define buffer buf_parts-attr for ub.parts-attr .
define buffer buf_income_parts-attr for ub.parts-attr .


do on error undo, return error return-value :
  assign
    p-income-doc-code = ?
  .
  find first buf_parts-attr no-lock
    where buf_parts-attr.in-code   = p-in-code
      and buf_parts-attr.gds-code  = p-gds-code
      and buf_parts-attr.part-code = p-part-code
  no-error .
  if available buf_parts-attr then do:
    find first buf_income_parts-attr no-lock
      where buf_income_parts-attr.in-code   = buf_parts-attr.income-in-code
        and buf_income_parts-attr.gds-code  = buf_parts-attr.income-gds-code
        and buf_income_parts-attr.part-code = buf_parts-attr.income-part-code
      no-error .
    if available buf_income_parts-attr then do:
      assign
        p-income-doc-code = buf_parts-attr.income-in-code
      .
    end.
    else do:
      assign
        p-income-doc-code = ?
      .
    end.
  end.
  else do:
    assign
      p-income-doc-code = ?
    .
  end.
end. /* do */

end procedure.