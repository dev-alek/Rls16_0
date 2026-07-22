block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: send-tsd.p $
$Archive: str/send-tsd.p $

Формирование файла для ТСД

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/23/03
Author: Bakhtadze Natalya
Creation date: 06/23/03

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .

/*
p-parameter включает
define input parameter i-obj-type like ub.clients.obj-type no-undo .
define input parameter i-obj-code like ub.clients.obj-code no-undo.

*/


&SCOPED-DEFINE called send-codes-only
&SCOPED-DEFINE tsd    yes

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: send-tsd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/send-tsd.p $":U .
define variable vss-description as character no-undo init "Формирование файла для ТСД".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ cmp/gds-list.i gds-list def shared }
&undefine gds-list_i_def
{ cmp/gds-list.i gds-list-marker def " " }
{ cmp/bb-list.i bb-list def shared }
{ str/tsdtmpdf.i }
{ str/tsdtmpdt.i "new shared" }
{ gbl/thbj-def.i }

define variable i-obj-type like ub.clients.obj-type no-undo .
define variable i-obj-code like ub.clients.obj-code no-undo.

/*вспомогательная переменаая для gds-list.i */
DEFINE VARIABLE lns-cnt                   as integer               no-undo .
/*вспомогательная переменаая для gds-list.i */
DEFINE VARIABLE line-rec                  as recid                 no-undo .
/*разделитель , который заказал пользователь через template*/
define variable v-delim                   as character             no-undo .
/* -----------------------------------------  sendgood.i*----------------------------------------------------------*/

/*{ str/sendgood.i }*/

{ str/bc-gnrt.i new bc }
{ str/defc-tsd.i }
{ cmp/library.i  }
{ str/round-m.i  }
{ trg/factord.i  }
{ str/lib-trn.i  }
{ str/tax-val.i  }
{ gbl/cur-time.i }
{ cmp/bitoper.i }

define variable action                       as character      no-undo init "U":U .
/*счетчик записей текущего пакета*/
DEFINE VARIABLE cr                           as integer        no-undo .
/*флаг начала пакета*/
DEFINE VARIABLE start-paket                  as logical init yes no-undo .
/*флаг засоренности директории большим кол-вом файлов*/
DEFINE VARIABLE BadFlag                      as logical          no-undo .
/*считчик для показа работы процесса*/
define variable v-count                      as integer          no-undo .
/**/
DEFINE VARIABLE var-report-num               as integer          no-undo .
DEFINE VARIABLE g#log                        as logical          no-undo .
/**/
DEFINE VARIABLE ind                          as integer          no-undo .
/*ошибка операционки*/
DEFINE VARIABLE os-er                        as integer          no-undo .
/*вспом строковая переменная */
DEFINE VARIABLE s as character no-undo.
/*вспомогат переменная для чтения настроек*/
DEFINE VARIABLE conf-attr                    as character        no-undo .
/*вспомогат переменная для чтения настроек*/
DEFINE VARIABLE conf-par                     as character        no-undo .
/*вспомогат переменная для чтения настроек*/
DEFINE VARIABLE par-type                     as character        no-undo .
/*переменная для хранения причин ошибок*/
DEFINE VARIABLE prichina                     as character        no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .

define buffer request_prod-bc for ub.prod-bc.
define buffer r-gds-prt for ub.gds-prt.
define buffer buf_prod for ub.clients.
define buffer buf_cash-gds for cash-gds.
define buffer buf_goods for ub.goods.

define stream term_.
define stream IBMStream .
define stream LogStream .

DEFINE VARIABLE chk_name                     as character        no-undo .
DEFINE VARIABLE bar_code                     as character        no-undo .
DEFINE VARIABLE b_code                       as character        no-undo .
DEFINE VARIABLE l-empty-scale                as logical          no-undo .
DEFINE VARIABLE main-b-code                  like ub.bar-code.b-code  no-undo .
/*флаг продажи по партияи*/
DEFINE VARIABLE cashparts                    like ub.gds-obj.cash-parts no-undo .
/*флаг топливного товара*/
DEFINE VARIABLE petrol-trk                   as logical          no-undo .
DEFINE VARIABLE for-prod-name                as character        no-undo .
/*строка налогов*/
DEFINE VARIABLE tax-string                   as character        no-undo init "" .
/*флаг обработки след товара*/
DEFINE VARIABLE new-good                     as logical          no-undo init yes .
/*флаг взвешиваемого товара*/
DEFINE VARIABLE is-sc                        as logical          no-undo .
/*код налогов*/
DEFINE VARIABLE rdtaxcd                      as INTEGER          no-undo .
DEFINE VARIABLE vattaxcd                     as INTEGER          no-undo .
DEFINE VARIABLE exctaxcd                     as INTEGER          no-undo .

/*-----------------НАСТРОЙКИ--------------------------------*/
/*уникальный цифровой артикул + ДОПБК = артикулу*/
DEFINE VARIABLE unq-artc                     as logical           no-undo init no .
/*на кассу имя товара или артикул*/
DEFINE VARIABLE nam-artc                     as logical           no-undo init no .
/*what do i send to cash-desk - for parts loc code or parts code?*/
DEFINE VARIABLE cod-pcod                     as logical           no-undo .
/*точность представления - кол-во знаков после зап*/
DEFINE VARIABLE rnd-znak                     as integer           no-undo init 2 .

define variable callpoint                    as character          no-undo .
define variable v-is-price                   as logical            no-undo .
define variable v-is-time                    as logical            no-undo .
define variable v-is-artic                   as logical            no-undo .
define variable v-rec                        as recid              no-undo .
define variable V-LENGTH                     as integer            no-undo .
define variable V-NUM-CLMN                   as integer            no-undo .
define variable v-file-name                  as character          no-undo .
define variable v-host-code                  like ub.sysconf.host-code no-undo .
define variable v-doc-prt                    like ub.shop.doc-prt  no-undo .
define variable v-in-ov                      like ub.shop.in-ov    no-undo .
/*пишем 0 если не в переоценке и 1 если в переоценке*/
define variable v-err-ov                     as integer            no-undo .
define variable v-no-good                    as logical            no-undo .
define variable v-artic-delim                as integer            no-undo .
define variable v-recs                       as integer            no-undo .
define variable v-recs-ok                    as integer            no-undo .
define variable v-rec-num                    as integer            no-undo .
define variable v-scl-format                 as character          no-undo .
define variable v-pg-format                  as character          no-undo .
define variable v-encoding                   as character          no-undo .
define variable log-file-name                as character          no-undo init "send-tsd.txt".
define variable v-view-log                   as logical            no-undo .
/*на входе готовая таблица бар-кодов лежащая в bb-list*/
define variable v-bb-mode                    as character          no-undo .
define variable v-found                      as logical no-undo .
/*может быть b-code - тогда только основные баркоды*/
/*может быть bb-list - тогда только те кто есть в bb-list - там никогда не бывает партионных*/
/*может быть all - тогда все типы бар-кодов по настройке фильтра*/
function tsd-scl-format returns character ( buffer buf_cash-gds for cash-gds
                                          , input p-scl-format as character):
define variable v-int as integer no-undo .
if LOOKUP( {&weight}, buf_cash-gds.unit-cli-type ) > 0
    and buf_cash-gds.unit-cli = buf_cash-gds.unit-base
    and buf_cash-gds.b-str <> '':U
    then do:
  v-int = integer(buf_cash-gds.b-code-tsd).
  if length(p-scl-format) > 5 then do:
    return substring(p-scl-format, 1, 2) + string(v-int, substring(p-scl-format, 3)).
  end.
  else do:
    return string(v-int, p-scl-format).
  end.
end.
else do:
  return buf_cash-gds.b-code-tsd.
end.
end function.
function tsd-pg-format returns character ( buffer buf_cash-gds for cash-gds
                                          , input p-pg-format as character):
define variable v-int as integer no-undo .
if buf_cash-gds.bc-on-type = {&loc-pg-code} then do:
  v-int = integer(buf_cash-gds.b-code-tsd).
  if length(p-pg-format) > 5 then do:
    return substring(p-pg-format, 1, 2) + string(v-int, substring(p-pg-format, 3)).
  end.
  else do:
    return string(v-int, p-pg-format).
  end.
end.
else do:
  return buf_cash-gds.b-code-tsd.
end.
end function.


&scop NEW-GOOD  assign ~
                new-good = yes ~
                petrol-trk = no ~
                cashparts = no ~
                main-b-code = 0 ~
                v-err-ov = 0 ~
                v-no-good = no ~
                v-artic-delim = 0 ~
                .

{ str/asc-tsd.i  gds-list }

/*PROCEDURE term-prt.*/
/*заполняет таблицу cash-gds сканируя бар-коды и ДОПБК*/
{ str/term-prt.i gds-list streetsd }

/*рождение кода согласно настройка магазина и типу товара - для кассы IBM-POS*/
{ str/ibm-gdsc.i temp-shop left }


assign
i-obj-type = entry(1, p-parameter, {&delim-par})
i-obj-code = integer(entry(2, p-parameter, {&delim-par}))
v-bb-mode  = (if num-entries(p-parameter, {&delim-par}) > 2 then entry(3, p-parameter, {&delim-par}) else '':U)
no-error
.
  { gbl/getsect.i run "''" 0 {&attr-nakl-glob} }
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = {&attr-nakl-glob_rnd-znk} then rnd-znak = thbjattr_thbj-attr.property-value-integer .
  end.

for each thbjattr_thbj-attr :
  delete thbjattr_thbj-attr .
end.

{ gbl/getsect.i run "''" 0 {&attr-gds-ref} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = {&attr-gds-ref_unq-artc} then unq-artc = thbjattr_thbj-attr.property-value-logical .
end.

assign
rdtaxcd  = integer({&road-tax-code})
vattaxcd = integer({&vat-tax-code})
exctaxcd = integer({&excise-tax-code}).

assign
var-report-num = dynamic-next-value( "next-report":U, "ubflt":U)
.

{ gbl/hostcode.i
  i-obj-type
  i-obj-code
  v-host-code
  no-error
  }
for each thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.
run adm/shattri.p (
    input "get":U
    ,input  i-obj-type
    ,input  i-obj-code
    ,input  {&attr-cd-inf-send}
    ,input  '':U /*p-param-code*/
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
if error-status:error then return error .
for each thbjattr_thbj-attr where
        thbjattr_thbj-attr.obj-type = i-obj-type
    and thbjattr_thbj-attr.obj-code = i-obj-code
    and thbjattr_thbj-attr.upper-prop-code = {&attr-cd-inf-send}
on error undo, return error :
  case thbjattr_thbj-attr.prop-code:
    when {&attr-cd-inf-send_nam-artc} then do:
      nam-artc = thbjattr_thbj-attr.property-value-logical.
    end.
    when {&attr-cd-inf-send_cod-pcod} then do:
      cod-pcod = thbjattr_thbj-attr.property-value-logical.
    end.
  end case.
end.

CASE i-obj-type:
  when {&shop} then do:
    find first ub.shop where
              ub.shop.obj-code = i-obj-code.
    find first ub.sysconf no-lock where
               ub.sysconf.host-code = ub.shop.host-code.
    assign
    v-doc-prt = ub.shop.doc-prt
    v-in-ov = ub.shop.in-ov
    .
  end.
  when {&stock} then do:
    find first ub.store where
              ub.store.obj-code = i-obj-code.
    find first ub.sysconf no-lock where
               ub.sysconf.host-code = ub.store.host-code.
    assign
    v-doc-prt = ub.store.doc-prt
    v-in-ov = ub.store.in-ov
    .
  end.
END CASE.

error-status:error = no.

/* $Workfile: send-tsd.p $ e n d */

/*--------------------------------------------sendgood.i ----------------------------------------------------------*/


run init-tsd-template in this-procedure .

run gbl/prntput.p ( input c-point, output v-rec ).
run gbl/tsd-tmpl.w (
               input parparentproc
              ,input i-obj-type
              ,input i-obj-code
              ,input (if v-bb-mode <> "":U then "":U else "btn-codes") /*bttn*/
              ,input c-point
              ,input Tbl
              ,input join-tbl
              ,input Fld
              ,input Lab
              ,input Spr
              ,input v-size
              ,input v-size-min
              ,input v-format
              ,input Dim
              ,output v-rec
              ,OUTPUT V-LENGTH
              ,OUTPUT V-NUM-CLMN
              ,output v-file-name
              ,output v-encoding
            ).
if v-rec = ? then return.
find first ubflt.filter no-lock where
           recid(ubflt.filter) = v-rec no-error .
if not avail ubflt.filter then return.

assign
v-delim = entry(3, ubflt.filter.fields-sort-rus, {&delim-par})
v-is-price = (lookup("function.price":U, ubflt.filter.fields-sort) > 0)
v-is-time = (lookup("function.date-time":U, ubflt.filter.fields-sort) > 0)
v-is-artic = (lookup("function.artic":U, ubflt.filter.fields-sort) > 0)
v-rec-num = integer(entry(4, ubflt.filter.fields-sort-rus, {&delim-par}))
v-scl-format = (if num-entries(ubflt.filter.fields-sort-rus, {&delim-par}) < 5
                then ">>>>9"
                else entry(5, ubflt.filter.fields-sort-rus, {&delim-par})
              )
v-pg-format = (if num-entries(ubflt.filter.fields-sort-rus, {&delim-par}) < 6
                then ">>>>9"
                else entry(6, ubflt.filter.fields-sort-rus, {&delim-par})
              )
.

assign
cr = 0
.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Подготовка данных")
                                          ).
assign
  v-count = 0
.
if v-bb-mode = "bb-list":U then do:
  _bb-list:
  for each bb-list
  break by bb-list.gds-code
  :
    if first-of(bb-list.gds-code) then do:
      find first gds-list no-lock where
                gds-list.gds-code = bb-list.gds-code no-error .

      if not available gds-list then do:
        find first buf_goods no-lock where
                  buf_goods.gds-code = bb-list.gds-code no-error .
        if not available buf_goods then next _bb-list.
        { cmp/gds-list.i gds-list  assign " " buf_goods }
        { cmp/gds-list.i gds-list-marker assign " " buf_goods }
      end.
    end.
  end.
end.

find first temp-shop.
CASE v-bb-mode:
  when "b-code":U then do:
    assign
    temp-shop.all-prt                 = yes
    temp-shop.cd-bc-alt               = no
    temp-shop.cd-bc-alt               = no
    temp-shop.cd-bc-base              = yes
    temp-shop.cd-loc-alt              = no
    temp-shop.cd-loc-base             = no
    temp-shop.cd-parts-all            = no
    temp-shop.cd-parts-not-blank      = no
    temp-shop.cd-parts-ser            = no
    temp-shop.cd-pb-alt               = no
    temp-shop.cd-pb-base              = no
    temp-shop.cd-sc-base              = no
    .
  end.
  when "bb-list":U then do:
    assign
    temp-shop.all-prt                 = yes
    temp-shop.cd-bc-alt               = yes
    temp-shop.cd-bc-alt               = yes
    temp-shop.cd-bc-base              = yes
    temp-shop.cd-loc-alt              = yes
    temp-shop.cd-loc-base             = yes
    temp-shop.cd-parts-all            = no
    temp-shop.cd-parts-not-blank      = no
    temp-shop.cd-parts-ser            = no
    temp-shop.cd-pb-alt               = yes
    temp-shop.cd-pb-base              = yes
    temp-shop.cd-sc-base              = yes
    .
  end.


END CASE.
_gds-list:
FOR EACH gds-list :
    assign
      v-count = v-count + 1
    .
    {&NEW-GOOD}
    run get-prt-and-unit in this-procedure (
                                            input gds-list.prt-root
                                            ,input gds-list.unit-base
                                            ,output l-empty-scale
                                            ) .
    FIND FIRST ub.gds-obj WHERE
              ub.gds-obj.obj-type = {&shop} AND
              ub.gds-obj.obj-code = i-obj-code AND
              ub.gds-obj.artic = gds-list.artic AND
              ub.gds-obj.prod-type = gds-list.prod-type AND
              ub.gds-obj.prod-code = gds-list.prod-code nO-LOCK NO-ERROR.

    if v-count modulo 10 = 0 then do:
      run show-counter in p-log-handle .
      run write-counter in p-log-handle (substitute("Обработано: &1. Подготовка данных - товар &2 &3&4"
                                          , v-count
                                          , gds-list.artic
                                          , gds-list.prod-type
                                          , gds-list.prod-code)) no-error.
    end.
    if available ub.gds-obj then do:
      assign
      cashparts = ub.gds-obj.cash-parts.
    end.
    RUN term-prt( ub.gds-prt.prt-root, ?) no-error.
    ACCUMULATE gds-list.artic (COUNT).
    /* на сегодняшний момент мы должны послать СРАЗУ все записи*/
    /*---------------------------------------------------------------------------------
    if NOT alllstcs AND ( (accum count gds-list.artic)  modulo cdpcknum)  = 0 then do:
        /*пошлем те cash-gds, которые успели сделать*/
        if cr > 0 then do:
          v-found = yes.
        RUN SENDING in this-procedure (v-file-name, chr(int(v-delim))) no-error.
        end.
        /*вернемся к первому и начнем писать в таблицу с головы*/
        assign
        start-paket = yes
        cr = 0
        .
    end. /* (accum count gds-list.artic)  modulo cdpcknum)  = 0 */
    ------------------------------------------------------------------------------------*/
END . /*for each gds-list*/
/*пошлем те cash-gds, которые успели сделать но еще не послали*/
if cr > 0 then do:
  v-found = yes.
RUN SENDING in this-procedure (v-file-name, chr(int(v-delim))) no-error .
  if error-status:error then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("!!!Ошибки при выгрузке файла &1 для объекта &2&3", v-file-name, i-obj-type, i-obj-code)
                                            ).
  end.
end.
if v-found then do:
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Сохранен файл &1 для объекта &2&3", v-file-name, i-obj-type, i-obj-code)
                                          ).
end.
else do:
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
      , input substitute("Не было данных для сохранения в файл для объекта &1&2", i-obj-type, i-obj-code)
                                          ).
end.

if v-bb-mode = "bb-list":U then do:
  for each gds-list-marker,
      first gds-list where
            gds-list.gds-code = gds-list-marker.gds-code:
    delete gds-list.
    delete gds-list-marker.
  end.
end.


/*нужно ли стирать temp-table?*/

{ str/cdviewlg.i
"'!!!При отсылке информации на ТСД произошли ошибки!!!'"
"'send-tsd.txt'" }

procedure init-tsd-template :
define variable na                   as integer            no-undo .


  do
  on error undo, return error
  :
    assign
    join-tbl = 'Доступные поля'
    tbl = 'function'
    fld = ""
    lab = ""
    spr = ""
    dim = '0'
    v-size = "":U
    v-size-min = "":U
    v-format = "":U
    c-point = "Список товаров" + {&delim-par} +  "TSD":u
    .
    run prnfield-add in this-procedure('b-code-tsd', 'Бар-код (ДопБК/локал./локал.EAN)', 'function.character', 16, 16, "X(16)":U,
    input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-size-min,
    input-output v-format, input-output dim)  no-error.
    run prnfield-add in this-procedure('artic', 'Артикул', 'function.character', 16, 16, "X(16)":U,
    input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-size-min,
    input-output v-format, input-output dim)  no-error.
    run prnfield-add in this-procedure('price', 'Цена', 'function.decimal', 11, 11, "99999999.99":U,
    input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-size-min,
    input-output v-format, input-output dim)  no-error.
    run prnfield-add in this-procedure('date-time', 'Дата-время установки цены', 'function.string', 16, 16, "X(16)":U,
    input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-size-min,
    input-output v-format, input-output dim)  no-error.
    run prnfield-add in this-procedure('object', 'Объект действия цены', 'function.string', 8, 8, "X(8)":U,
    input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-size-min,
    input-output v-format, input-output dim)  no-error.
    run prnfield-add in this-procedure('gds-name', 'Название', 'function.character', 46, 5, "X(48)":U,
    input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-size-min,
    input-output v-format, input-output dim)  no-error.
    run prnfield-add in this-procedure('prod-name', 'Производитель', 'function.character', 40, 5, "X(40)":U,
    input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-size-min,
    input-output v-format, input-output dim)  no-error.
    run prnfield-add in this-procedure('unit-cli', 'Ед.изм', 'function.character', 3, 3, "X(3)":U,
    input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-size-min,
    input-output v-format, input-output dim)  no-error.
    run prnfield-add in this-procedure('engl-name', 'Англ.Название', 'function.character', 48, 5, "X(48)":U,
    input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-size-min,
    input-output v-format, input-output dim)  no-error.
    run prnfield-add in this-procedure('b-code', 'Локальный Бар-код', 'function.integer', 9, 9, "999999999":U,
    input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-size-min,
    input-output v-format, input-output dim)  no-error.
    run prnfield-add in this-procedure('no-z-b-code', 'Локальный Бар-код без лид.0', 'function.integer', 9, 9, ">>>>>>>>9":U,
    input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-size-min,
    input-output v-format, input-output dim)  no-error.
    run prnfield-add in this-procedure('gds-code', 'Код товара', 'function.integer', 9, 9, "999999999":U,
    input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-size-min,
    input-output v-format, input-output dim)  no-error.

  end.

end procedure. /* init-tsd-template */

procedure get-prt-and-unit :
define input parameter par-prt-root like ub.goods.prt-root no-undo .
define input parameter par-unit-base like ub.goods.unit-base no-undo .
define output parameter par-empty-scale as logical no-undo .

  do
  on error undo, return error
  :
    FIND FIRST ub.gds-prt where
               ub.gds-prt.upper-code = par-prt-root NO-LOCK .
    assign
    par-empty-scale = NOT (v-doc-prt AND ( ub.gds-prt.node-name <> {&empty-scale}))
    .
    FIND FIRST ub.units WHERE
               ub.units.unit-name = par-unit-base NO-LOCK .

  end.

end procedure. /* get-prt-and-unit */

PROCEDURE sending:
define input parameter p-file-name as character no-undo .
/*здесь уже это один символ ASCII*/
define input parameter p-delim as character no-undo .
define variable v-log-name as character no-undo .
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .

run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Сохранение в файл &1", p-file-name)
                                          ).

if search(p-file-name) = ? then do:
  output stream IbmStream to value(p-file-name) .
  output stream IbmStream close.
end.

run gbl/filename.p (
 input  p-file-name
,output v-full-path
,output v-path
,output v-file-name
,output v-file-name-no-ext
,output v-file-name-ext
               ) no-error  .
if error-status:error then do:
  message
  "Не удалось создать или найти файл" p-file-name
  view-as alert-box error .
  return error .
end.
if v-encoding = "WINDOWS-1251" then
output stream IbmStream to value(v-path + {&slash-char} + v-file-name-no-ext + ".tx0":U)   .
else
output stream IbmStream to value(v-path + {&slash-char} + v-file-name-no-ext + ".tx0":U)  convert target v-encoding .
output stream LogStream to value(v-path + {&slash-char} + v-file-name-no-ext + ".log":U) .
OS-delete
value(v-path + {&slash-char} + v-file-name-no-ext + ".txt":U)
.
run write-header in this-procedure  .
/*сформируем вывод для ТСД*/
RUN putc-tsd (p-delim, output v-recs, output v-recs-ok).
/*закрываем поток*/
output stream IbmStream close.
run write-bottom in this-procedure .
output stream LogStream close.
if os-error <> 0 then return error.
OS-rename
value(v-path + {&slash-char} + v-file-name-no-ext + ".tx0":U)
value(v-path + {&slash-char} + v-file-name-no-ext + ".txt":U)
.
if os-error <> 0 then return error.
END PROCEDURE.


PROCEDURE putc-tsd.
define input parameter p-delim as character no-undo .
define output parameter p-recs as integer no-undo .
define output parameter p-recs-ok as integer no-undo .
DEFINE VARIABLE ii  as  integer no-undo.
DEFINE VARIABLE IBM-good-code-2 as character no-undo .
define variable v-str as character no-undo .
define variable v-format as character no-undo .
_cash-gds:
FOR EACH cash-gds No-LOCK WHERE
        cash-gds.crf <= cr
    AND cash-gds.b-code-tsd <> "":U
by cash-gds.b-code-tsd:
  CASE v-bb-mode:
    when "bb-list":U then do:
      if string(cash-gds.b-code) = trim(cash-gds.b-code-tsd)
      then do:
        find first bb-list no-lock where
                  bb-list.gds-code = cash-gds.gds-code
              and bb-list.node-code = cash-gds.node-code
              and bb-list.unit-cli = cash-gds.unit-cli
              AND bb-list.b-str = '':U no-error .
      end.
      else do:
        if LOOKUP( {&weight}, cash-gds.unit-type ) = 0 or cash-gds.unit-base <> cash-gds.unit-cli then do:
          find first bb-list no-lock where
                  bb-list.gds-code = cash-gds.gds-code
              and bb-list.node-code = cash-gds.node-code
              and bb-list.unit-cli = cash-gds.unit-cli
                AND bb-list.b-str = trim(cash-gds.b-code-tsd) no-error .
        end.
        else do:
          find first bb-list no-lock where
                  bb-list.gds-code = cash-gds.gds-code
              and bb-list.node-code = cash-gds.node-code
              and bb-list.unit-cli = cash-gds.unit-cli
                AND bb-list.b-str = cash-gds.b-str no-error .
        end.
      end.
      if not available bb-list then NEXT _cash-gds.
    end.
  END CASE.
  assign
  v-str = "":U
  p-recs = p-recs + 1
  .
  if cash-gds.is-err > 0
  OR p-recs-ok = v-rec-num
  then do:
    PUt stream Logstream unformatted
    "ERRR!!!" {&space-char}
     cash-gds.b-code-tsd {&space-char}
     (if p-recs-ok  = v-rec-num
      then "number of records exceeded"
      else "":U) {&space-char}
     (if BinMask(cash-gds.is-err, "1XXXX":U)
     then "articul contains delimiter"
     else "":U) {&space-char}
     (if BinMask(cash-gds.is-err, "XXXX1":U)
     then "needs overvalue"
     else "":U) {&space-char}
     (if BinMask(cash-gds.is-err, "XXX1X":U)
     then "err at price determination"
     else "":U) {&space-char}
     (if BinMask(cash-gds.is-err, "XX1XX":U)
     then "no price"
     else "":U) {&space-char}
     (if BinMask(cash-gds.is-err, "X1XXX":U)
     then "no date-time"
     else "":U) {&space-char}
     "code to export" {&space-char} cash-gds.b-code-tsd {&space-char}
     "good's code" {&space-char} cash-gds.gds-code {&space-char}
     cash-gds.gds-name
    skip.
  end. /*cash-gds.is-err = yes*/
  if BinMask(cash-gds.is-err, "0XX00":U)
  AND p-recs-ok < v-rec-num
  then do:
    assign
    p-recs-ok = p-recs-ok + 1
    .
    for each t-f no-lock
    by t-f.field-table-order
    :
      assign
      v-format = "X(":U + t-f.field-csize + ")":U
      .
      CASE t-f.field-name:
        when "b-code-tsd":U then do:
          assign
          v-str = v-str + string(cash-gds.b-code-tsd, "X(16)") + p-delim.
        end.
        when "artic":U then do:
          assign
          v-str = v-str + string(cash-gds.artic, v-format) + p-delim
          .
        end.
        when "price":U then do:
          assign
          v-str = v-str + (if cash-gds.price-sale = ?
                          then "???????????":U
                          else string(cash-gds.price-sale, t-f.field-format)) + p-delim
          .
        end.
        when "date-time":U then do:
          assign
          v-str = v-str + (if cash-gds.price-date = ?
                          then "??????????":U
                          else string(cash-gds.price-date, "99/99/9999":U)) + {&space-char} +
                          (if cash-gds.price-time = 0
                          then "?????":U
                          else string(cash-gds.price-time, "HH:MM":U)) + p-delim
          .
        end.
        when "object":U then do:
          assign
          v-str = v-str + i-obj-type + string(i-obj-code, "99999":U) + p-delim
          .
        end.
        when "gds-name":U then do:
          if p-delim <> '':U then do:
            assign
            v-str = v-str + replace(string(cash-gds.gds-name, v-format), p-delim, {&space-char}) + p-delim
            .
          end.
          else do:
            assign
            v-str = v-str + string(cash-gds.gds-name, v-format)
            .
          end.
        end.
        when "engl-name":U then do:
          if p-delim <> '':U then do:
            assign
            v-str = v-str + replace(string(cash-gds.engl-name, v-format), p-delim, {&space-char}) + p-delim
            .
          end.
          else do:
            assign
            v-str = v-str + string(cash-gds.engl-name, v-format)
            .
          end.
        end.
        when "prod-name":U then do:
          if p-delim <> '':U then do:
            assign
            v-str = v-str + replace(string(cash-gds.prod-name, v-format), p-delim, {&space-char}) + p-delim
            .
          end.
          else do:
            assign
            v-str = v-str + string(cash-gds.prod-name, v-format)
            .
          end.
        end.
        when "unit-cli":U then do:
          if p-delim <> '':U then do:
            assign
            v-str = v-str + replace(string(cash-gds.unit-cli, v-format), p-delim, {&space-char}) + p-delim
            .
          end.
          else do:
            assign
            v-str = v-str + string(cash-gds.unit-cli, v-format)
            .
          end.
        end.
        when "b-code":U then do:
          assign
          v-str = v-str + string(cash-gds.b-code, "999999999") + p-delim.
        end.
        when "gds-code":U then do:
          assign
          v-str = v-str + string(cash-gds.gds-code, "999999999") + p-delim.
        end.
        when "no-z-b-code":U then do:
          assign
          v-str = v-str + string(string(cash-gds.gds-code), "X(9)") + p-delim.
        end.

      END CASE.
    end. /*for each t-f no-lock*/
    assign
    v-str = trim(v-str, p-delim)
    .
  end. /*cash-gds.is-err = no*/
  PUT stream LogStream unformatted
  v-str
  SKIP.
  PUT stream IBMstream unformatted
  v-str
  SKIP.

END.

END PROCEDURE .

procedure write-header :
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .

  do
  on error undo, return error
  :
    run cur-time in this-procedure(output v-today, output v-time).
    put stream LOgStream unformatted
    "!!!This is log file for export to Data Collector!!!" skip
    "(encode 1251)" skip
    string(v-today, "99/99/9999":U) {&space-char}
    string(v-time, "hh:mm:ss":U) skip
    "fields used for export" {&space-char} replace(ubflt.filter.fields-sort, "function.":U, "":U) skip
    "fields length" {&space-char} entry(3, ubflt.filter.where-ysl, {&delim-par}) skip
    "fields delimiter's ASCII code" {&space-char} v-delim skip
    "number of records in file" {&space-char} v-rec-num
    skip(2).
  end.

end procedure. /* write-header */


procedure write-bottom :
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .

  do
  on error undo, return error
  :
    run cur-time in this-procedure(output v-today, output v-time).
    put stream LOgStream unformatted
    skip(2)
    "!!!End of file for Data Collector!!!" skip
    string(v-today, "99/99/9999":U) {&space-char}
    string(v-time, "hh:mm:ss":U) skip
    "number of records" {&space-char} v-recs skip
    "number of success records" {&space-char} v-recs-ok
    skip.

  end.

end procedure. /* write-bottom */