block-level on error undo, throw.
/*

$Revision: eb58aa57459c, 2002, rls $
$Author: EShklyar $
$Date: Wed Sep 18 21:01:08 2019 +0300 $
$Workfile: r-cpych.p $
$Archive: cus/r-cpych.p $

Отчет по продажам в разрезе платежных карт - выполнение отчета

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/11/10
Author: Bakhtadze Natalya
Creation date: 02/11/10

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-discnt-dtl as logical no-undo .
define input parameter p-pay-card as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: eb58aa57459c, 2002, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Wed Sep 18 21:01:08 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-cpych.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/r-cpych.p $":U .
define variable vss-description as character no-undo init "Отчет по продажам в разрезе платежных карт - выполнение отчета".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-pril.i new  }
{ cmp/r-page1.i  }
{ gbl/prn-lib.i }
{ gbl/waitfram.i }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/thbj-def.i }

define temp-table temp-cpych no-undo
field pay-card as character
field fpay-card as character
field chk-date as date
field chk-time as integer
field doc-code as character
field obj-type as character
field obj-code as integer
field b-code as integer
field gds-code as integer
field line-num as integer
field price-base as decimal
field doc-qnty as decimal
field doc-qnty-2 as decimal
field sum-tot as decimal
field discnt as decimal
field discnt-sum as decimal
field sum-netto as decimal
field num-chk as integer
field is-ptrl as logical
field category as character
index pi is unique primary
pay-card
doc-code
obj-type
obj-code
line-num
index igds
obj-type
obj-code
gds-code
index iview
obj-type
obj-code
fpay-card
chk-date
chk-time
doc-code
line-num
index iview2
obj-type
obj-code
doc-code
index icat
category
.

define temp-table temp-inkas no-undo
field inkas-code as character
field obj-type as character
field obj-code as integer
field shift-date as date
field shift-num as integer
index pi is unique primary
inkas-code
index iview
obj-type
obj-code
shift-date
shift-num
inkas-code
.

define temp-table temp-discnt no-undo
field obj-type as character
field obj-code as integer
field discnt-type as integer
field discnt-sum as decimal
index pi is unique primary
obj-type
obj-code
discnt-type
.


define variable v-header as character no-undo .
define variable v-header-curr as character no-undo .
define variable v-rubl as logical no-undo .
define variable v-r-b as logical no-undo .
define variable v-curr-r-b as character no-undo .
define variable v-one-curr-code as logical no-undo .
define variable v-curr-code like ub.currency.curr-code no-undo init ?.
define variable v-base-code as integer no-undo .
define variable Line            as character no-undo.
define variable date_string     as character no-undo.
define variable v-pay-card      as character no-undo .
define variable v-pay-card-itog      as character no-undo .
define variable v-chk-date-time as character no-undo .
define variable v-sum-tot as decimal no-undo .
define variable v-discnt-name as character no-undo .
define variable v-sum-netto as decimal no-undo .
define variable v-line as integer no-undo .
define variable num-objs as integer no-undo .
define variable ii-excel as integer no-undo .
define variable ii-page as integer no-undo init 1.
define variable v-qnty-2 as decimal no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
define variable par-l-mask  as logical no-undo .
define variable v-param-type as character no-undo .

DEFINE shared TEMP-TABLE tt-cash-pay  no-undo LIKE ub.cash-pay.
define buffer buf1_sheetf for sheetf.
define buffer buf_sheetf for sheetf.
define buffer buf_temp-inkas for temp-inkas.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_goods for ub.goods.
define buffer buf_chk-discnt for ub.chk-discnt.
define buffer buf_currency for ub.currency.
define buffer buf_temp-cpych for temp-cpych.
define buffer gds-obj_temp-cpych for temp-cpych.
define buffer gds_temp-cpych for temp-cpych.
define buffer obj_temp-cpych for temp-cpych.
define buffer all_temp-cpych for temp-cpych.
define buffer card-obj_temp-cpych for temp-cpych.
define buffer card_temp-cpych for temp-cpych.
define buffer obj_temp-discnt for temp-discnt.
define buffer all_temp-discnt for temp-discnt.


&global-define  no-benefits    "Не было никакой выручки  ~
в течение заданного Вами периода времени."
define buffer buf_inkas for ub.inkas.

&scop   page-excel-block  if ii-excel > 32000 then do:                                    ~
                           {&pageExcel}                                               ~
                           find first buf_sheetf where                                ~
                                     buf_sheetf.sheet-num = ii-page + 1 no-error.     ~
                           if not available buf_sheetf then do:                       ~
                             create buf_sheetf.                                       ~
                           end.                                                       ~
                           buffer-copy buf1_sheetf except sheet-num                   ~
                           to buf_sheetf                                              ~
                           assign                                                     ~
                           buf_sheetf.sheet-num = ii-page + 1                         ~
                           .                                                          ~
                           run rep/extitle.p (ii-page) .                                   ~
                           assign                                                     ~
                           ii-page = ii-page + 1                                      ~
                           ii-excel = 0                                               ~
                           .                                                          ~
                         end



run waitfram-show in this-procedure ("Ждите...").

run adm/shattri.p (
      input "get":U
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  {&attr-dc-ref}
    ,input  {&attr-dc-ref_l-mask} /*p-param-code*/
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output par-l-mask
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .

for each thbjattr_thbj-attr where
       thbjattr_thbj-attr.obj-type = v-cntxt-obj-type
   and thbjattr_thbj-attr.obj-code = v-cntxt-obj-code
   and thbjattr_thbj-attr.upper-prop-code = {&attr-dc-ref}
on error undo, return error return-value :
  case thbjattr_thbj-attr.prop-code:
    when {&attr-dc-ref_l-mask} then do:
      assign
      par-l-mask = thbjattr_thbj-attr.property-value-logical.
    end.
  end case.
end.
/*соберем данные*/
for each buf_temp-inkas:
  delete buf_temp-inkas.
end.

FOR EACH obj-list No-LOCK:
  num-objs = num-objs + 1.
  case X-Radio-task > 1:
    when yes then do:
      _inkas:
      for each  buf_Inkas no-lock where
                buf_inkas.shift-date  >= x-date-start
            AND buf_inkas.shift-date  <= x-date-end
            AND buf_inkas.obj-type   = obj-list.obj-type
            AND buf_inkas.obj-code   = obj-list.obj-code:
        /*сменные сутки и порядок*/
        IF X-Radio-task = 3
        AND  ((buf_inkas.shift-date = x-date-start AND buf_inkas.shift-num < X-shift-start) OR
              (buf_inkas.shift-date = x-date-end AND  buf_inkas.shift-num > X-shift-end) ) THEN DO:
           next _inkas.

        END.
        /*сменные сутки и номер смены*/
        IF X-radio-task = 4
        AND buf_inkas.shift-num <> X-Shift-Alone then DO:
          next _inkas.
        END.
        create buf_temp-inkas.
        buffer-copy buf_inkas to buf_temp-inkas.
        { gbl/basecode.i buf_inkas.host-code v-base-code }
        assign
        v-curr-code = (if v-curr-code = ? then v-base-code else v-curr-code)
        v-one-curr-code = (if v-base-code = v-curr-code then yes else no)
        .
        run process-inkas in this-procedure ( buffer buf_temp-inkas ).
        release buf_temp-inkas.
      END. /*FOR EACH buf_inkas*/
    end. /*when yes then do:*/
    when no then do:
      for each  buf_Inkas no-lock where
                buf_inkas.doc-date  >= x-date-start
            AND buf_inkas.doc-date  <= x-date-end
            AND buf_inkas.obj-type   = obj-list.obj-type
            AND buf_inkas.obj-code   = obj-list.obj-code
            AND buf_inkas.status_     = {&fact}:
        create buf_temp-inkas.
        buffer-copy buf_inkas to buf_temp-inkas.
        { gbl/basecode.i buf_inkas.host-code v-base-code }
        assign
        v-curr-code = (if v-curr-code = ? then v-base-code else v-curr-code)
        v-one-curr-code = (if v-base-code = v-curr-code then yes else no)
        .
        run process-inkas in this-procedure ( buffer buf_temp-inkas ).
        release buf_temp-inkas.
      end. /*for each  buf_Inkas no-lock where*/
    end. /*when no then do:*/
  end case.
END. /*FOR EACH OBJ-LIST*/

/*уже печатаем*/
{ gbl/curr-r-b.i
  v-curr-r-b
}

assign
v-r-b = (if v-curr-r-b = {&r-b-rubl} or v-one-curr-code then yes else no)
/*печатаем р у б л и ? */
v-rubl =(if not v-r-b or (v-r-b = yes and v-curr-r-b = {&r-b-rubl})
        then yes
        else no)
.


DEFINE FRAME OutFrame
v-pay-card                        column-label "№ карты"          format "X(19)"
v-chk-date-time                   column-label "Дата,время"       format "X(16)"
buf_chk-gds.doc-code              column-label "Чек №"            format "X(19)"
buf_goods.artic                   column-label "Артикул"          format "X(16)"
buf_goods.gds-name                column-label "Наименование"     format "X(36)"
buf_chk-gds.price-base            column-label "Цена"             format ">>>,>>9.99"
buf_chk-gds.doc-qnty              column-label "Количество"       format "->>>,>>9.999"
v-qnty-2                          column-label "Кол-во кг"        format "->>>,>>9.999"
v-sum-tot                         column-label "Сумма без скидки" format "->>>,>>>,>>9.99"
v-discnt-name                     column-label "Тип скидки"       format "X(20)"
buf_chk-discnt.discnt-value-pcnt  column-label "% скидки"         format "->9.99"
buf_chk-discnt.discnt-value-abs   column-label "Сумма скидки"     format "->>,>>>,>>9.99"
v-sum-netto                       column-label "Сумма нетто"      format "->>>,>>>,>>9.99"
HEADER
cur-time-print() AT 5 format "X(35)"
string( "Страница " + string( PAGE-NUMBER( PrnLibStream ), ">>>>>9" ) ) AT 70 format "X(23)" SKIP
Line format "X(195)" AT 1 skip
v-header format "X(195)" AT 1
with width {&DOS_CW_2} down stream-io.

FORM HEADER
Line format "X(195)" AT 1 SKIP
"Продолжение - на следующей странице" AT 60 SKIP
with FRAME BottomFrame width {&DOS_CW_2}
PAGE-BOTTOM no-labels no-box.

assign
v-rubl = (if not v-r-b or (v-r-b = yes and v-curr-r-b = {&r-b-rubl})
         then yes
         else no)
.

if v-rubl = yes then do:
  assign
  v-header-curr = string( "(Все суммы в {&abbr_rublyah})" )
  .
end.
else do:
  find first buf_currency no-lock where
            buf_currency.curr-code = v-curr-code no-error .
  assign
  v-header-curr = string( "(Все суммы в " +
                          (if available buf_currency
                          then buf_currency.curr-abbr
                          else string(v-curr-code)) + ")"
                        )
  .
end.


assign
sheetf.Excel-Column-Lable =  "№ карты,Дата-время,Чек №,Артикул,Наименование,Цена,Количество,Кол-во кг,Сумма без скидки,Тип скидки,% скидки,Сумма скидки,Сумма нетто"
sheetf.colformat = "1=@;2=@;3=@;4=@;5=@;6=0.00;7=0.000;8=0.000;9=0.00;11=0.00;12=0.00;13=0.00"
sheetf.sizes = "19,16,19,16,36,10,12,12,15,20,6,14,15"
/*можно ли печатать в r-b*/
v-r-b = (if v-curr-r-b = {&r-b-rubl} or v-one-curr-code then yes else no)
.


run waitfram-show in this-procedure ("Ждите..." ).

run prn-lib-open-stream  in this-procedure (
                                            input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).
assign
str3 = v-header-curr.
run rep/extitle.p (1).
run waitfram-show in this-procedure ("Ждите..." ).
find first buf1_sheetf no-lock where
          buf1_sheetf.sheet-num = 1 or buf1_sheetf.sheet-num = 0.

PUT stream PrnLibStream UNFORMATTED
"Отчет по продажам в разрезе платежных карт"
format "x(50)" SKIP(1).
PUT stream PrnLibStream UNFORMATTED
str1 skip
str2 skip
str4 skip
v-header-curr skip
reportheader skip
.
FORM with FRAME OutFrame.
VIEW STREAM PrnLibStream FRAME BottomFrame .
VIEW STREAM PrnLibStream FRAME OutFrame .

for each obj-list
break
by obj-list.obj-type
by obj-list.obj-code
:
  {&page-excel-block}.
  for each buf_temp-cpych where
          buf_temp-cpych.obj-type = obj-list.obj-type
      and buf_temp-cpych.obj-code = obj-list.obj-code
      and buf_temp-cpych.category = ""
  break
  by buf_temp-cpych.fpay-card
  by buf_temp-cpych.chk-date
  by buf_temp-cpych.chk-time
  by buf_temp-cpych.doc-code
  :
    find first buf_bar-code no-lock where
              buf_bar-code.b-code = buf_temp-cpych.b-code no-error.
    if available buf_bar-code then do:
      find first buf_goods no-lock where
                buf_goods.gds-code = buf_bar-code.b-code no-error.
    end.
    if available buf_goods
    or buf_temp-cpych.is-ptrl = no
    then do:
      find first gds-obj_temp-cpych where
                gds-obj_temp-cpych.obj-type = obj-list.obj-type
            and gds-obj_temp-cpych.obj-code = obj-list.obj-code
            and gds-obj_temp-cpych.category = "gds-obj"
            and gds-obj_temp-cpych.gds-code = (if buf_temp-cpych.is-ptrl
                                               then  buf_goods.gds-code
                                               else -1)
                                               no-error.
      if not available gds-obj_temp-cpych then do:
        create gds-obj_temp-cpych.
        assign
        gds-obj_temp-cpych.pay-card = ''
        gds-obj_temp-cpych.fpay-card = ''
        gds-obj_temp-cpych.chk-date  = ?
        gds-obj_temp-cpych.chk-time = 0
        gds-obj_temp-cpych.doc-code = ''
        gds-obj_temp-cpych.obj-type = obj-list.obj-type
        gds-obj_temp-cpych.obj-code = obj-list.obj-code
        gds-obj_temp-cpych.b-code  = 0
        gds-obj_temp-cpych.gds-code = (if buf_temp-cpych.is-ptrl
                                       then buf_goods.gds-code
                                       else -1)
        gds-obj_temp-cpych.line-num = v-line + 1
        v-line = v-line + 1
        gds-obj_temp-cpych.num-chk = 0
        gds-obj_temp-cpych.discnt = 0
        gds-obj_temp-cpych.category = "gds-obj"
        .
      end.
      find first gds_temp-cpych where
                gds_temp-cpych.obj-type = ''
            and gds_temp-cpych.obj-code = 0
            and gds_temp-cpych.category = "gds"
            and gds_temp-cpych.gds-code = (if buf_temp-cpych.is-ptrl
                                           then buf_goods.gds-code
                                           else -1) no-error.
      if not available gds_temp-cpych then do:
        create gds_temp-cpych.
        assign
        gds_temp-cpych.pay-card = ''
        gds_temp-cpych.fpay-card = ''
        gds_temp-cpych.chk-date  = ?
        gds_temp-cpych.chk-time = 0
        gds_temp-cpych.doc-code = ''
        gds_temp-cpych.obj-type = ''
        gds_temp-cpych.obj-code = 0
        gds_temp-cpych.b-code  = 0
        gds_temp-cpych.gds-code = (if buf_temp-cpych.is-ptrl
                                   then buf_goods.gds-code
                                   else -1)
        gds_temp-cpych.line-num = v-line + 1
        v-line = v-line + 1
        gds_temp-cpych.num-chk = 0
        gds_temp-cpych.discnt = 0
        gds_temp-cpych.category = "gds"
        .
      end.
    end. /*if available buf_goods then do:*/
    find first obj_temp-cpych where
              obj_temp-cpych.obj-type = obj-list.obj-type
          and obj_temp-cpych.obj-code = obj-list.obj-code
          and obj_temp-cpych.category = "obj" no-error.
    if not available obj_temp-cpych then do:
      create obj_temp-cpych.
      assign
      obj_temp-cpych.pay-card = ''
      obj_temp-cpych.fpay-card = ''
      obj_temp-cpych.chk-date  = ?
      obj_temp-cpych.chk-time = 0
      obj_temp-cpych.doc-code = ''
      obj_temp-cpych.obj-type = obj-list.obj-type
      obj_temp-cpych.obj-code = obj-list.obj-code
      obj_temp-cpych.b-code  = 0
      obj_temp-cpych.gds-code = 0
      obj_temp-cpych.line-num = v-line + 1
      v-line = v-line + 1
      obj_temp-cpych.num-chk = 0
      obj_temp-cpych.discnt = 0
      obj_temp-cpych.category = "obj"
      .
    end.
    find first all_temp-cpych where
              all_temp-cpych.obj-type = ''
          and all_temp-cpych.obj-code = 0
          and all_temp-cpych.category = "all"
          and all_temp-cpych.gds-code = 0 no-error.
    if not available all_temp-cpych then do:
      create all_temp-cpych.
      assign
      all_temp-cpych.pay-card = ''
      all_temp-cpych.fpay-card = ''
      all_temp-cpych.chk-date  = ?
      all_temp-cpych.chk-time = 0
      all_temp-cpych.doc-code = ''
      all_temp-cpych.obj-type = ''
      all_temp-cpych.obj-code = 0
      all_temp-cpych.b-code  = 0
      all_temp-cpych.gds-code = 0
      all_temp-cpych.line-num = v-line + 1
      v-line = v-line + 1
      all_temp-cpych.num-chk = 0
      all_temp-cpych.discnt = 0
      all_temp-cpych.category = "all"
      .
    end.
    assign
    gds-obj_temp-cpych.doc-qnty = gds-obj_temp-cpych.doc-qnty + buf_temp-cpych.doc-qnty
    gds-obj_temp-cpych.doc-qnty-2 = gds-obj_temp-cpych.doc-qnty-2 + buf_temp-cpych.doc-qnty-2
    gds-obj_temp-cpych.sum-tot  = gds-obj_temp-cpych.sum-tot + buf_temp-cpych.sum-tot
    gds-obj_temp-cpych.sum-netto  = gds-obj_temp-cpych.sum-netto + buf_temp-cpych.sum-netto
    gds-obj_temp-cpych.discnt-sum  = gds-obj_temp-cpych.discnt-sum + buf_temp-cpych.discnt * buf_temp-cpych.doc-qnty
    gds_temp-cpych.doc-qnty = gds_temp-cpych.doc-qnty + buf_temp-cpych.doc-qnty
    gds_temp-cpych.doc-qnty-2 = gds_temp-cpych.doc-qnty-2 + buf_temp-cpych.doc-qnty-2
    gds_temp-cpych.sum-tot  = gds_temp-cpych.sum-tot + buf_temp-cpych.sum-tot
    gds_temp-cpych.sum-netto  = gds_temp-cpych.sum-netto + buf_temp-cpych.sum-netto
    gds_temp-cpych.discnt-sum  = gds_temp-cpych.discnt-sum + buf_temp-cpych.discnt * buf_temp-cpych.doc-qnty
    obj_temp-cpych.doc-qnty = obj_temp-cpych.doc-qnty + buf_temp-cpych.doc-qnty
    obj_temp-cpych.doc-qnty-2 = obj_temp-cpych.doc-qnty-2 + buf_temp-cpych.doc-qnty-2
    obj_temp-cpych.sum-tot  = obj_temp-cpych.sum-tot + buf_temp-cpych.sum-tot
    obj_temp-cpych.sum-netto  = obj_temp-cpych.sum-netto + buf_temp-cpych.sum-netto
    obj_temp-cpych.discnt-sum  = obj_temp-cpych.discnt-sum + buf_temp-cpych.discnt * buf_temp-cpych.doc-qnty
    all_temp-cpych.doc-qnty = all_temp-cpych.doc-qnty + buf_temp-cpych.doc-qnty
    all_temp-cpych.doc-qnty-2 = all_temp-cpych.doc-qnty-2 + buf_temp-cpych.doc-qnty-2
    all_temp-cpych.sum-tot  = all_temp-cpych.sum-tot + buf_temp-cpych.sum-tot
    all_temp-cpych.sum-netto  = all_temp-cpych.sum-netto + buf_temp-cpych.sum-netto
    all_temp-cpych.discnt-sum  = all_temp-cpych.discnt-sum + buf_temp-cpych.discnt * buf_temp-cpych.doc-qnty
    .
    
    v-pay-card = if first-of(buf_temp-cpych.fpay-card)
                  then buf_temp-cpych.fpay-card
                  else ''.
    if par-l-mask and v-cntxt-db-num <> 0 and v-pay-card <> "" then v-pay-card = substring(v-pay-card,1,6) + "XXXXXX" + substring (v-pay-card,13,4).

    if first-of(buf_temp-cpych.fpay-card) then do:
      {&page-excel-block}.
    end.
    display stream prnlibstream
    v-pay-card
    (string(buf_temp-cpych.chk-date, "99.99.9999") + {&space-char} + string(buf_temp-cpych.chk-time, "HH:MM")) @ v-chk-date-time
    buf_temp-cpych.doc-code  @ buf_chk-gds.doc-code
    (if available buf_goods then buf_goods.artic else "") @ buf_goods.artic
    (if available buf_goods then buf_goods.gds-name else "!!!НЕИЗВ. ТОВАР") @ buf_goods.gds-name
    buf_temp-cpych.price-base @ buf_chk-gds.price-base
    buf_temp-cpych.doc-qnty @  buf_chk-gds.doc-qnty
    buf_temp-cpych.doc-qnty-2 @  v-qnty-2
    buf_temp-cpych.sum-tot @ v-sum-tot
    /*v-discnt-name */
    buf_temp-cpych.discnt / buf_temp-cpych.price-base * 100 @  buf_chk-discnt.discnt-value-pcnt
    buf_temp-cpych.discnt * buf_temp-cpych.doc-qnty @  buf_chk-discnt.discnt-value-abs
    buf_temp-cpych.sum-netto @ v-sum-netto
    with frame outframe.
    down 1 stream prnlibstream
    with frame outframe.
    {&PutExcel}
    v-pay-card {&tabulation}
    (string(buf_temp-cpych.chk-date, "99.99.9999") + {&space-char} + string(buf_temp-cpych.chk-time, "HH:MM")) {&tabulation}
    buf_temp-cpych.doc-code {&tabulation}
    (if available buf_goods then buf_goods.artic else "") {&tabulation}
    (if available buf_goods then buf_goods.gds-name else "!!!НЕИЗВ. ТОВАР") {&tabulation}
    buf_temp-cpych.price-base {&tabulation}
    buf_temp-cpych.doc-qnty {&tabulation}
    buf_temp-cpych.doc-qnty-2 {&tabulation}
    buf_temp-cpych.sum-tot {&tabulation}
    {&tabulation}
    buf_temp-cpych.discnt / buf_temp-cpych.price-base {&tabulation}
    buf_temp-cpych.discnt * buf_temp-cpych.doc-qnty {&tabulation}
    buf_temp-cpych.sum-netto {&tabulation}
    skip.
    ii-excel = ii-excel + 1.
    if p-discnt-dtl then do:
      /*печатаем скидки*/
      for each buf_chk-discnt no-lock where
              buf_chk-discnt.record-type = 1
          and buf_chk-discnt.doc-code = buf_temp-cpych.doc-code
          and buf_chk-discnt.line-num = buf_temp-cpych.line-num:

         find first obj_temp-discnt where
                  obj_temp-discnt.obj-type = obj-list.obj-type
              and obj_temp-discnt.obj-code = obj-list.obj-code
              and obj_temp-discnt.discnt-type = buf_chk-discnt.discnt-type no-error.
         if not available obj_temp-discnt then do:
           create obj_temp-discnt.
           assign
           obj_temp-discnt.obj-type = obj-list.obj-type
           obj_temp-discnt.obj-code = obj-list.obj-code
           obj_temp-discnt.discnt-type = buf_chk-discnt.discnt-type
           .
         end.
         find first all_temp-discnt where
                  all_temp-discnt.obj-type = ''
              and all_temp-discnt.obj-code = 0
              and all_temp-discnt.discnt-type = buf_chk-discnt.discnt-type no-error.
         if not available all_temp-discnt then do:
           create all_temp-discnt.
           assign
           all_temp-discnt.obj-type = ''
           all_temp-discnt.obj-code = 0
           all_temp-discnt.discnt-type = buf_chk-discnt.discnt-type
           .
         end.
         assign
         obj_temp-discnt.discnt-sum = obj_temp-discnt.discnt-sum + buf_chk-discnt.discnt-value-abs
         all_temp-discnt.discnt-sum = all_temp-discnt.discnt-sum + buf_chk-discnt.discnt-value-abs
         .
         release obj_temp-discnt.
         release all_temp-discnt.
&scop discnt-type-code string(buf_chk-discnt.discnt-type)
        display stream prnlibstream
        {&discnt-type-name} @ v-discnt-name
        buf_chk-discnt.discnt-value-pcnt
        buf_chk-discnt.discnt-value-abs
        with frame outframe.
        down 1 stream prnlibstream
        with frame outframe.
        {&PutExcel}
        {&tabulation}
        {&tabulation}
        {&tabulation}
        {&tabulation}
        {&tabulation}
        {&tabulation}
        {&tabulation}
        {&tabulation}
        {&tabulation}
        {&discnt-type-name} {&tabulation}
        buf_chk-discnt.discnt-value-pcnt {&tabulation}
        buf_chk-discnt.discnt-value-abs {&tabulation}
        skip
        .
        ii-excel = ii-excel + 1.
      end.
      /*печатаем скидки*/
      for each buf_chk-discnt no-lock where
              buf_chk-discnt.record-type = 2
          and buf_chk-discnt.doc-code = buf_temp-cpych.doc-code
          and buf_chk-discnt.line-num = buf_temp-cpych.line-num:
        find first all_temp-discnt where
                all_temp-discnt.obj-type = obj-list.obj-type
            and all_temp-discnt.obj-code = obj-list.obj-code
            and all_temp-discnt.discnt-type = buf_chk-discnt.discnt-type no-error.
        if not available all_temp-discnt then do:
          create all_temp-discnt.
          assign
          all_temp-discnt.obj-type = ''
          all_temp-discnt.obj-code = 0
          all_temp-discnt.discnt-type = buf_chk-discnt.discnt-type
          .
        end.
        assign
        obj_temp-discnt.discnt-sum = obj_temp-discnt.discnt-sum + buf_chk-discnt.discnt-value-abs
        all_temp-discnt.discnt-sum = all_temp-discnt.discnt-sum + buf_chk-discnt.discnt-value-abs
        .
        release obj_temp-discnt.
        release all_temp-discnt.

        display stream prnlibstream
        "Погрешность" @ v-discnt-name
        buf_chk-discnt.discnt-value-pcnt
        buf_chk-discnt.discnt-value-abs
        with frame outframe.
        down 1 stream prnlibstream
        with frame outframe.
        {&PutExcel}
        {&tabulation}
        {&tabulation}
        {&tabulation}
        {&tabulation}
        {&tabulation}
        {&tabulation}
        {&tabulation}
        {&tabulation}
        "Погрешность" {&tabulation}
        buf_chk-discnt.discnt-value-pcnt {&tabulation}
        buf_chk-discnt.discnt-value-abs {&tabulation}
        skip
        .
        ii-excel = ii-excel + 1.
      end.
    end.
    release gds-obj_temp-cpych.
    release obj_temp-cpych.
    release gds_temp-cpych.
    release all_temp-cpych.
    if last-of(buf_temp-cpych.fpay-card)
    /*and num-objs = 1*/
    then do:
      if par-l-mask and v-cntxt-db-num <> 0 and buf_temp-cpych.fpay-card <> "" then v-pay-card-itog = substring(buf_temp-cpych.fpay-card,1,6) + "XXXXXX" + substring (buf_temp-cpych.fpay-card,13,4).
      else v-pay-card-itog = buf_temp-cpych.fpay-card .
      find first card-obj_temp-cpych where
                card-obj_temp-cpych.obj-type = obj-list.obj-typ
            and card-obj_temp-cpych.obj-code = obj-list.obj-code
            and card-obj_temp-cpych.pay-card  =  buf_temp-cpych.pay-card
            and card-obj_temp-cpych.category  =  "card-obj"            .
      display stream prnlibstream
      '' @ v-pay-card
      "Итого по карте" @ v-chk-date-time
      v-pay-card-itog  @ buf_chk-gds.doc-code
      '' @ buf_goods.artic
      'чеков:' @ buf_goods.gds-name
      card-obj_temp-cpych.num-chk @ buf_chk-gds.price-base
      card-obj_temp-cpych.doc-qnty @  buf_chk-gds.doc-qnty
      card-obj_temp-cpych.doc-qnty-2 @  v-qnty-2
      card-obj_temp-cpych.sum-tot @ v-sum-tot
      card-obj_temp-cpych.discnt-sum @  buf_chk-discnt.discnt-value-abs
      card-obj_temp-cpych.sum-netto @ v-sum-netto
      with frame outframe.
      down 1 stream prnlibstream
      with frame outframe.
      {&PutExcel}
      '' {&tabulation}
      "Итого по карте" {&tabulation}
      v-pay-card-itog  {&tabulation}
      '' {&tabulation}
      'чеков:' {&tabulation}
      card-obj_temp-cpych.num-chk {&tabulation}
      card-obj_temp-cpych.doc-qnty {&tabulation}
      card-obj_temp-cpych.doc-qnty-2 {&tabulation}
      card-obj_temp-cpych.sum-tot {&tabulation}
      {&tabulation}
      {&tabulation}
      card-obj_temp-cpych.discnt-sum  {&tabulation}
      card-obj_temp-cpych.sum-netto {&tabulation}
      skip.
      ii-excel = ii-excel + 1.
    end. /*if last-of(buf_temp-cpych.fpay-card)*/
  end. /*  for each buf_temp-cpych where*/
  if num-objs = 1 then do:
    underline stream PrnLibStream
    v-pay-card
    v-chk-date-time
    buf_chk-gds.doc-code
    buf_goods.artic
    buf_goods.gds-name
    buf_chk-gds.price-base
    buf_chk-gds.doc-qnty
    v-qnty-2
    v-sum-tot
    v-discnt-name
    buf_chk-discnt.discnt-value-pcnt
    buf_chk-discnt.discnt-value-abs
    v-sum-netto
    with frame OutFrame.
    down 1 stream PrnLibstream
    with frame OutFrame.
  end.
  if num-objs = 1 then do:
    put stream PrnLibStream unformatted
    "Итого по видам топлива и сопутствующим товарам"
    skip
    .
    {&PutExcel}
    "Итого по видам топлива и сопутствующим товарам"
    skip
    .
    ii-excel = ii-excel + 1.
    for each gds-obj_temp-cpych where
              gds-obj_temp-cpych.obj-type = obj-list.obj-typ
          and gds-obj_temp-cpych.obj-code = obj-list.obj-code
          and gds-obj_temp-cpych.category  =  "gds-obj" :
      if gds-obj_temp-cpych.gds-code > 0 then do:
        find first buf_goods no-lock where
                    buf_goods.gds-code = gds-obj_temp-cpych.gds-code no-error.
        display stream prnlibstream
        '' @ v-chk-date-time
        ''  @ buf_chk-gds.doc-code
        '' @ buf_goods.artic
        (if available buf_goods then buf_goods.artic else "") @ buf_goods.artic
        (if available buf_goods then buf_goods.gds-name else "!!!НЕИЗВ. ТОВАР") @ buf_goods.gds-name
        gds-obj_temp-cpych.doc-qnty @  buf_chk-gds.doc-qnty
        gds-obj_temp-cpych.doc-qnty-2 @  v-qnty-2
        gds-obj_temp-cpych.sum-tot @ v-sum-tot
        gds-obj_temp-cpych.discnt-sum @  buf_chk-discnt.discnt-value-abs
        gds-obj_temp-cpych.sum-netto @ v-sum-netto
        with frame outframe.
        down 1 stream prnlibstream
        with frame outframe.
        {&PutExcel}
        {&tabulation}
        {&tabulation}
        {&tabulation}
        (if available buf_goods then buf_goods.artic else "") {&tabulation}
        (if available buf_goods then buf_goods.gds-name else "!!!НЕИЗВ. ТОВАР") {&tabulation}
        {&tabulation}
        gds-obj_temp-cpych.doc-qnty {&tabulation}
        gds-obj_temp-cpych.doc-qnty-2 {&tabulation}
        gds-obj_temp-cpych.sum-tot {&tabulation}
        {&tabulation}
        {&tabulation}
        gds-obj_temp-cpych.discnt-sum {&tabulation}
        gds-obj_temp-cpych.sum-netto {&tabulation}
        skip
        .
        ii-excel = ii-excel + 1.
      end.
      else do:
        display stream prnlibstream
        "" @ v-chk-date-time
        ''  @ buf_chk-gds.doc-code
        '' @ buf_goods.artic
        "Сопутствующие товары" @ buf_goods.gds-name
        gds-obj_temp-cpych.doc-qnty @  buf_chk-gds.doc-qnty
        /*gds-obj_temp-cpych.doc-qnty-2 @  v-qnty-2*/
        gds-obj_temp-cpych.sum-tot @ v-sum-tot
        gds-obj_temp-cpych.discnt-sum @  buf_chk-discnt.discnt-value-abs
        gds-obj_temp-cpych.sum-netto @ v-sum-netto
        with frame outframe.
        down 1 stream prnlibstream
        with frame outframe.
        {&PutExcel}
        {&tabulation}
        {&tabulation}
        {&tabulation}
        {&tabulation}
        "Сопутствующие товары" {&tabulation}
        {&tabulation}
        gds-obj_temp-cpych.doc-qnty  {&tabulation}
        {&tabulation}
        gds-obj_temp-cpych.sum-tot {&tabulation}
        {&tabulation}
        {&tabulation}
        gds-obj_temp-cpych.discnt-sum  {&tabulation}
        gds-obj_temp-cpych.sum-netto
        skip
        .
        ii-excel = ii-excel + 1.
      end.
    end. /*    for each gds-obj_temp-cpych where*/
    if p-discnt-dtl
    and can-find(first obj_temp-discnt where
              obj_temp-discnt.obj-type = obj-list.obj-type
          and obj_temp-discnt.obj-code = obj-list.obj-code)
    then do:
      put stream PrnLibStream unformatted
      "Итого по типам скидок"
      skip
      .
      {&PutExcel}
      "Итого по типам скидок"
      skip
      .

      for each obj_temp-discnt where
              obj_temp-discnt.obj-type = obj-list.obj-type
          and obj_temp-discnt.obj-code = obj-list.obj-code:
  &scop discnt-type-code string(obj_temp-discnt.discnt-type)
        display stream prnlibstream
        "---------->" @ v-pay-card
        {&discnt-type-name} @ v-discnt-name
        obj_temp-discnt.discnt-sum @ buf_chk-discnt.discnt-value-abs
        with frame outframe.
        down 1 stream prnlibstream
        with frame outframe.
        {&PutExcel}
        "---------->" {&tabulation}
        {&tabulation}
        {&tabulation}
        {&tabulation}
        {&tabulation}
        {&tabulation}
        {&tabulation}
        {&tabulation}
        {&tabulation}
        {&discnt-type-name} {&tabulation}
        {&tabulation}
        obj_temp-discnt.discnt-sum {&tabulation}
        skip
        .
        ii-excel = ii-excel + 1.
    end.
    end. /*if p-discnt-dtl then do:*/
  end. /*if num-objs = 1 then do:*/
  underline stream PrnLibStream
  v-pay-card
  v-chk-date-time
  buf_chk-gds.doc-code
  buf_goods.artic
  buf_goods.gds-name
  buf_chk-gds.price-base
  buf_chk-gds.doc-qnty
  v-qnty-2
  v-sum-tot
  v-discnt-name
  buf_chk-discnt.discnt-value-pcnt
  buf_chk-discnt.discnt-value-abs
  v-sum-netto
  with frame OutFrame.
  down 1 stream PrnLibstream
  with frame OutFrame.
  find first obj_temp-cpych where
            obj_temp-cpych.obj-type = obj-list.obj-typ
        and obj_temp-cpych.obj-code = obj-list.obj-code
        and obj_temp-cpych.category  =  "obj" no-error.
  if not available obj_temp-cpych then do:
    create obj_temp-cpych.
    assign
    obj_temp-cpych.pay-card = ''
    obj_temp-cpych.fpay-card = ''
    obj_temp-cpych.chk-date  = ?
    obj_temp-cpych.chk-time = 0
    obj_temp-cpych.doc-code = ''
    obj_temp-cpych.obj-type = obj-list.obj-type
    obj_temp-cpych.obj-code = obj-list.obj-code
    obj_temp-cpych.b-code  = 0
    obj_temp-cpych.gds-code = 0
    obj_temp-cpych.line-num = v-line + 1
    v-line = v-line + 1
    obj_temp-cpych.num-chk = 0
    obj_temp-cpych.discnt = 0
    obj_temp-cpych.category = "obj"
    .
  end.
  display stream prnlibstream
  "Итого по объекту" @ v-pay-card
  substitute('&1&2', obj-list.obj-type, obj-list.obj-code) @ v-chk-date-time
  obj-list.obj-name @ buf_chk-gds.doc-code
  '' @ buf_goods.artic
  'чеков:' @ buf_goods.gds-name
  obj_temp-cpych.num-chk @ buf_chk-gds.price-base
  obj_temp-cpych.doc-qnty @  buf_chk-gds.doc-qnty
  obj_temp-cpych.doc-qnty-2 @  v-qnty-2
  obj_temp-cpych.sum-tot @ v-sum-tot
  obj_temp-cpych.discnt-sum @  buf_chk-discnt.discnt-value-abs
  obj_temp-cpych.sum-netto @ v-sum-netto
  with frame outframe.
  {&PutExcel}
  "Итого по объекту" {&tabulation}
  substitute('&1&2', obj-list.obj-type, obj-list.obj-code) {&tabulation}
  obj-list.obj-name {&tabulation}
  {&tabulation}
  'чеков:' {&tabulation}
  obj_temp-cpych.num-chk {&tabulation}
  obj_temp-cpych.doc-qnty {&tabulation}
  obj_temp-cpych.doc-qnty-2 {&tabulation}
  obj_temp-cpych.sum-tot {&tabulation}
  {&tabulation}
  {&tabulation}
  obj_temp-cpych.discnt-sum  {&tabulation}
  obj_temp-cpych.sum-netto
  skip.
  ii-excel = ii-excel + 1.
  if num-objs > 1 then do:
    down 1 stream prnlibstream
    with frame outframe.
    underline stream PrnLibStream
    v-pay-card
    v-chk-date-time
    buf_chk-gds.doc-code
    buf_goods.artic
    buf_goods.gds-name
    buf_chk-gds.price-base
    buf_chk-gds.doc-qnty
    v-qnty-2
    v-sum-tot
    v-discnt-name
    buf_chk-discnt.discnt-value-pcnt
    buf_chk-discnt.discnt-value-abs
    v-sum-netto
    with frame OutFrame.
    down 1 stream PrnLibstream
    with frame OutFrame.
  end.
end. /*for each obj-list*/
if num-objs > 1 then do:
  put stream PrnLibStream unformatted
  "Итого по видам топлива и сопутствующим товарам"
  skip
  .
  {&PutExcel}
  "Итого по видам топлива и сопутствующим товарам"
  skip
  .
  ii-excel = ii-excel + 1.
  for each gds_temp-cpych where
        gds_temp-cpych.category = "gds":
    if gds_temp-cpych.gds-code > 0 then do:
      find first buf_goods no-lock where
                  buf_goods.gds-code = gds_temp-cpych.gds-code no-error.
      display stream prnlibstream
      "" @ v-chk-date-time
      '' @ buf_chk-gds.doc-code
      (if available buf_goods then buf_goods.artic else "") @ buf_goods.artic
      (if available buf_goods then buf_goods.gds-name else "!!!НЕИЗВ. ТОВАР") @ buf_goods.gds-name
      gds_temp-cpych.doc-qnty @  buf_chk-gds.doc-qnty
      gds_temp-cpych.doc-qnty-2 @ v-qnty-2
      gds_temp-cpych.sum-tot @ v-sum-tot
      gds_temp-cpych.discnt-sum @  buf_chk-discnt.discnt-value-abs
      gds_temp-cpych.sum-netto @ v-sum-netto
      with frame outframe.
      down 1 stream prnlibstream
      with frame outframe.
      {&PutExcel}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      (if available buf_goods then buf_goods.artic else "") {&tabulation}
      (if available buf_goods then buf_goods.gds-name else "!!!НЕИЗВ. ТОВАР") {&tabulation}
      {&tabulation}
      gds_temp-cpych.doc-qnty  {&tabulation}
      gds_temp-cpych.doc-qnty-2  {&tabulation}
      gds_temp-cpych.sum-tot {&tabulation}
      {&tabulation}
      {&tabulation}
      gds_temp-cpych.discnt-sum {&tabulation}
      gds_temp-cpych.sum-netto
      skip.
      ii-excel = ii-excel + 1.
    end.
    else do:
      display stream prnlibstream
      "Итого по " @ v-chk-date-time
      ''  @ buf_chk-gds.doc-code
      '' @ buf_goods.artic
      "Сопутствующие товары" @ buf_goods.gds-name
      gds_temp-cpych.doc-qnty @  buf_chk-gds.doc-qnty
      gds_temp-cpych.doc-qnty-2 @  v-qnty-2
      gds_temp-cpych.sum-tot @ v-sum-tot
      gds_temp-cpych.discnt-sum @  buf_chk-discnt.discnt-value-abs
      gds_temp-cpych.sum-netto @ v-sum-netto
      with frame outframe.
      down 1 stream prnlibstream
      with frame outframe.
      {&PutExcel}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      "Сопутствующие товары" {&tabulation}
      {&tabulation}
      gds_temp-cpych.doc-qnty  {&tabulation}
      gds_temp-cpych.doc-qnty-2  {&tabulation}
      gds_temp-cpych.sum-tot {&tabulation}
      {&tabulation}
      {&tabulation}
      gds_temp-cpych.discnt-sum {&tabulation}
      gds_temp-cpych.sum-netto
      skip.
      ii-excel = ii-excel + 1.
    end.
  end.
  if p-discnt-dtl
  and can-find(first obj_temp-discnt where
            obj_temp-discnt.obj-type = ''
        and obj_temp-discnt.obj-code = 0)
  then do:
    put stream PrnLibStream unformatted
    "Итого по типам скидок"
    skip
    .
    {&PutExcel}
    "Итого по типам скидок"
    skip
    .
    ii-excel = ii-excel + 1.
    for each all_temp-discnt where
            all_temp-discnt.obj-type = ''
        and all_temp-discnt.obj-code = 0:
  &scop discnt-type-code string(all_temp-discnt.discnt-type)
      display stream prnlibstream
      "---------->" @ v-pay-card
      {&discnt-type-name} @ v-discnt-name
      all_temp-discnt.discnt-sum @ buf_chk-discnt.discnt-value-abs
      with frame outframe.
      down 1 stream prnlibstream
      with frame outframe.
      {&PutExcel}
      "---------->" {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      {&discnt-type-name} {&tabulation}
      {&tabulation}
      all_temp-discnt.discnt-sum {&tabulation}
      skip
      .
      ii-excel = ii-excel + 1.
    end.
  end. /*if p-discnt-dtl then do:*/
end.
find first all_temp-cpych where
          all_temp-cpych.obj-type = ''
      and all_temp-cpych.obj-code = 0
      and all_temp-cpych.category  =  "all" no-error.
if not available all_temp-cpych then do:
  create all_temp-cpych.
  assign
  all_temp-cpych.pay-card = ''
  all_temp-cpych.fpay-card = ''
  all_temp-cpych.chk-date  = ?
  all_temp-cpych.chk-time = 0
  all_temp-cpych.doc-code = ''
  all_temp-cpych.obj-type = obj-list.obj-type
  all_temp-cpych.obj-code = obj-list.obj-code
  all_temp-cpych.b-code  = 0
  all_temp-cpych.gds-code = 0
  all_temp-cpych.line-num = v-line + 1
  v-line = v-line + 1
  all_temp-cpych.num-chk = 0
  all_temp-cpych.discnt = 0
  all_temp-cpych.category = "all"
  .
end.
underline stream PrnLibStream
v-pay-card
v-chk-date-time
buf_chk-gds.doc-code
buf_goods.artic
buf_goods.gds-name
buf_chk-gds.price-base
buf_chk-gds.doc-qnty
v-qnty-2
v-sum-tot
v-discnt-name
buf_chk-discnt.discnt-value-pcnt
buf_chk-discnt.discnt-value-abs
v-sum-netto
with frame OutFrame.
down 1 stream PrnLibstream
with frame OutFrame.
display stream prnlibstream
"ИТОГО ПО ВСЕМ ОБЪЕКТАМ" @ v-pay-card
'' @ v-chk-date-time
'' @ buf_chk-gds.doc-code
'' @ buf_goods.artic
'чеков:' @ buf_goods.gds-name
all_temp-cpych.num-chk @ buf_chk-gds.price-base
all_temp-cpych.doc-qnty @  buf_chk-gds.doc-qnty
all_temp-cpych.doc-qnty-2 @  v-qnty-2
all_temp-cpych.sum-tot @ v-sum-tot
all_temp-cpych.discnt-sum @  buf_chk-discnt.discnt-value-abs
all_temp-cpych.sum-netto @ v-sum-netto
with frame outframe.
down 1 stream prnlibstream
with frame outframe.
{&PutExcel}
"ИТОГО ПО ВСЕМ ОБЪЕКТАМ" {&tabulation}
{&tabulation}
{&tabulation}
{&tabulation}
'чеков:' {&tabulation}
all_temp-cpych.num-chk {&tabulation}
all_temp-cpych.doc-qnty {&tabulation}
all_temp-cpych.doc-qnty-2 {&tabulation}
all_temp-cpych.sum-tot  {&tabulation}
{&tabulation}
{&tabulation}
all_temp-cpych.discnt-sum  {&tabulation}
all_temp-cpych.sum-netto
skip
.
ii-excel = ii-excel + 1.



run waitfram-hide in this-procedure .
HIDE STREAM PrnLibStream FRAME BottomFrame .
OUTPUT STREAM PrnLibStream CLOSE.
{&CloseExcel}
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).



procedure process-inkas :
define parameter buffer buf_temp-inkas for temp-inkas.
define variable v-doc-code as character no-undo .
define buffer buf_tt-cash-pay  for tt-cash-pay.
define buffer buf_chk-pay for ub.chk-pay.
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_temp-cpych for temp-cpych.
define buffer card-obj_temp-cpych for temp-cpych.
define buffer card_temp-cpych for temp-cpych.


for each buf_tt-cash-pay,
      each buf_chk-pay no-lock where
          buf_chk-pay.out-code = buf_temp-inkas.inkas-code
        and buf_chk-pay.pay-code = buf_tt-cash-pay.cdpay-code
        and buf_chk-pay.curr-code = buf_tt-cash-pay.curr-code
by  buf_chk-pay.doc-code           :
  if buf_chk-pay.pay-card = "0"
  or buf_chk-pay.pay-card = ""
  or buf_chk-pay.pay-card = ? then next.
  /*
  if p-pay-card <> ''
  and left-trim(trim(buf_chk-pay.pay-card), "0") <> left-trim(trim(p-pay-card), "0") then next.
  */
  /*теперь им подавай точный поиск!!!*/
  if p-pay-card <> ''
  and buf_chk-pay.pay-card <> p-pay-card then next.

  if v-doc-code <> buf_chk-pay.doc-code then do:
    /**/
    find first card-obj_temp-cpych where
            card-obj_temp-cpych.pay-card = buf_chk-pay.pay-card
        and card-obj_temp-cpych.obj-type = buf_chk-pay.obj-type
        and card-obj_temp-cpych.obj-code = buf_chk-pay.obj-code
        and card-obj_temp-cpych.category = "card-obj"
        no-error.
    if not available card-obj_temp-cpych then do:
      create card-obj_temp-cpych.
      assign
      card-obj_temp-cpych.pay-card = buf_chk-pay.pay-card
      card-obj_temp-cpych.fpay-card = fill( {&space-char} , 16 - length(buf_chk-pay.pay-card)) + buf_chk-pay.pay-card
      card-obj_temp-cpych.chk-date  = ?
      card-obj_temp-cpych.chk-time = 0
      card-obj_temp-cpych.doc-code = ''
      card-obj_temp-cpych.obj-type = buf_chk-pay.obj-type
      card-obj_temp-cpych.obj-code = buf_chk-pay.obj-code
      card-obj_temp-cpych.b-code   = 0
      card-obj_temp-cpych.line-num  = 0
      card-obj_temp-cpych.category = "card-obj"
      .
    end.
    find first card_temp-cpych where
            card_temp-cpych.pay-card = buf_chk-pay.pay-card
        and card_temp-cpych.obj-type = ''
        and card_temp-cpych.obj-code = 0
        and card_temp-cpych.category = "card"
        no-error.
    if not available card_temp-cpych then do:
      create card_temp-cpych.
      assign
      card_temp-cpych.pay-card = buf_chk-pay.pay-card
      card_temp-cpych.fpay-card = fill( {&space-char} , 16 - length(buf_chk-pay.pay-card)) + buf_chk-pay.pay-card
      card_temp-cpych.chk-date  = ?
      card_temp-cpych.chk-time = 0
      card_temp-cpych.doc-code = ''
      card_temp-cpych.obj-type = ''
      card_temp-cpych.obj-code = 0
      card_temp-cpych.b-code   = 0
      card_temp-cpych.line-num  = 0
      card_temp-cpych.category = "card"
      .
    end.
    find first obj_temp-cpych where
              obj_temp-cpych.obj-type = obj-list.obj-type
          and obj_temp-cpych.obj-code = obj-list.obj-code
          and obj_temp-cpych.category = "obj" no-error.
    if not available obj_temp-cpych then do:
      create obj_temp-cpych.
      assign
      obj_temp-cpych.pay-card = ''
      obj_temp-cpych.fpay-card = ''
      obj_temp-cpych.chk-date  = ?
      obj_temp-cpych.chk-time = 0
      obj_temp-cpych.doc-code = ''
      obj_temp-cpych.obj-type = obj-list.obj-type
      obj_temp-cpych.obj-code = obj-list.obj-code
      obj_temp-cpych.b-code  = 0
      obj_temp-cpych.gds-code = 0
      obj_temp-cpych.line-num = v-line + 1
      v-line = v-line + 1
      obj_temp-cpych.num-chk = 0
      obj_temp-cpych.discnt = 0
      obj_temp-cpych.category = "obj"
      .
    end.
    find first all_temp-cpych where
              all_temp-cpych.obj-type = ''
          and all_temp-cpych.obj-code = 0
          and all_temp-cpych.category = "all" no-error.
    if not available all_temp-cpych then do:
      create all_temp-cpych.
      assign
      all_temp-cpych.pay-card = ''
      all_temp-cpych.fpay-card = ''
      all_temp-cpych.chk-date  = ?
      all_temp-cpych.chk-time = 0
      all_temp-cpych.doc-code = ''
      all_temp-cpych.obj-type = ''
      all_temp-cpych.obj-code = 0
      all_temp-cpych.b-code  = 0
      all_temp-cpych.gds-code = 0
      all_temp-cpych.line-num = v-line + 1
      v-line = v-line + 1
      all_temp-cpych.num-chk = 0
      all_temp-cpych.discnt = 0
      all_temp-cpych.category = "all"
      .
    end.
    find first buf_temp-cpych where
            buf_temp-cpych.pay-card = buf_chk-pay.pay-card
        and buf_temp-cpych.doc-code = buf_chk-pay.doc-code no-error.
    if not available buf_temp-cpych then do:
      find first buf_chk-doc no-lock where
                buf_chk-doc.doc-code = buf_chk-pay.doc-code no-error.
      if available buf_chk-doc then do:
        assign
        card-obj_temp-cpych.num-chk = card-obj_temp-cpych.num-chk + 1
        card_temp-cpych.num-chk     = card_temp-cpych.num-chk + 1
        obj_temp-cpych.num-chk     = obj_temp-cpych.num-chk + 1
        all_temp-cpych.num-chk     = all_temp-cpych.num-chk + 1
        .
        for each buf_chk-gds no-lock where
                buf_chk-gds.doc-code = buf_chk-doc.doc-code:
          create buf_temp-cpych.
          assign
          buf_temp-cpych.pay-card = buf_chk-pay.pay-card
          buf_temp-cpych.fpay-card = fill( {&space-char} , 16 - length(buf_chk-pay.pay-card)) + buf_chk-pay.pay-card
          buf_temp-cpych.chk-date  = buf_chk-doc.chk-date
          buf_temp-cpych.chk-time = buf_chk-doc.chk-time
          buf_temp-cpych.doc-code = buf_chk-doc.doc-code
          buf_temp-cpych.obj-type = buf_chk-doc.obj-type
          buf_temp-cpych.obj-code = buf_chk-doc.obj-code
          buf_temp-cpych.b-code   = buf_chk-gds.b-code
          buf_temp-cpych.price-base = buf_chk-gds.price-base
          buf_temp-cpych.doc-qnty = buf_chk-gds.doc-qnty
          buf_temp-cpych.doc-qnty-2 = (if buf_chk-gds.pump > 0
                                       then buf_chk-gds.doc-qnty * buf_chk-gds.density
                                       else 0)
          buf_temp-cpych.sum-tot   = buf_chk-gds.doc-qnty * buf_chk-gds.price-base
          buf_temp-cpych.discnt    = buf_chk-gds.discnt
          buf_temp-cpych.sum-netto  = buf_chk-gds.doc-qnty * (buf_chk-gds.price-base - buf_chk-gds.discnt)
          buf_temp-cpych.num-chk = 0
          buf_temp-cpych.line-num = buf_chk-gds.line-num
          buf_temp-cpych.is-ptrl = (buf_chk-gds.pump > 0)
          buf_temp-cpych.category = ""
          .
          assign
          card-obj_temp-cpych.doc-qnty  = card-obj_temp-cpych.doc-qnty + buf_chk-gds.doc-qnty
          card-obj_temp-cpych.doc-qnty-2  = card-obj_temp-cpych.doc-qnty-2 + (if buf_chk-gds.pump > 0
                                                                              then buf_chk-gds.doc-qnty * buf_chk-gds.density
                                                                              else 0)
          card-obj_temp-cpych.sum-tot   = card-obj_temp-cpych.sum-tot + buf_chk-gds.doc-qnty * buf_chk-gds.price-base
          card-obj_temp-cpych.sum-netto  = card-obj_temp-cpych.sum-netto + buf_chk-gds.doc-qnty * (buf_chk-gds.price-base - buf_chk-gds.discnt)
          card_temp-cpych.doc-qnty  = card_temp-cpych.doc-qnty + buf_chk-gds.doc-qnty
          card_temp-cpych.doc-qnty-2  = card_temp-cpych.doc-qnty + (if buf_chk-gds.pump > 0
                                                                    then buf_chk-gds.doc-qnty * buf_chk-gds.density
                                                                    else 0)
          card_temp-cpych.sum-tot   = card_temp-cpych.sum-tot + buf_chk-gds.doc-qnty * buf_chk-gds.price-base
          card_temp-cpych.sum-netto  = card_temp-cpych.sum-netto + buf_chk-gds.doc-qnty * (buf_chk-gds.price-base - buf_chk-gds.discnt)
          .
          release buf_temp-cpych.
        end. /*for each buf_chk-gds no-lock where*/
      end. /*if available buf_chk-doc then do:*/
      release card-obj_temp-cpych.
      release card_temp-cpych.
      release obj_temp-cpych.
      release all_temp-cpych.
    end. /*if not available buf_temp-cpych then do:*/
    v-doc-code = buf_chk-pay.doc-code.
  end. /*if v-doc-code <> buf_chk-pay.doc-code then do:*/
end. /*for each buf_tt-cash-pay,*/


end procedure. /* process-inkas */