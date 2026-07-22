block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: get-omrn.p $
$Archive: str/get-omrn.p $

Программа приема чеков с касс OMRON-NEW

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/17/05
Author: Bakhtadze Natalya
Creation date: 10/17/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-version as character no-undo .
define input parameter file_ as character no-undo.
define input-output parameter p-view-log as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":u .
define variable vss-author      as character no-undo init "$Author: expertek $":u .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: get-omrn.p $":u .
define variable vss-archive     as character no-undo init "$Archive: str/get-omrn.p $":u .
define variable vss-description as character no-undo init "Программа приема чеков с касс Omron-new" .
{ cmp/vssrevis.i }

{ str/get-chk.i }
/*общие для кассовой части и чековой*/

{ str/get-chkc.i def }
/*только чековая часть*/
dflt-cd = {&cd-type-omron-new}.

define temp-table curr-cass no-undo
field code as int
field scale as int
field rate as dec
index pi is unique primary        code.


DEFINE VARIABLE filenamebo as char no-undo.
DEFINE VARIABLE sav as char no-undo.
DEFINE VARIABLE p-full-path        as character no-undo .
DEFINE VARIABLE p-file-name-no-ext as character no-undo .
DEFINE VARIABLE p-file-name-ext    as character no-undo .
define variable v-base-rate        as decimal   no-undo .
define variable v-base-scale       as integer no-undo .
define variable v-versiond as decimal no-undo .
define variable not-nal-curr as integer no-undo .
define buffer bff_cash-pay for ub.cash-pay.


assign
shop-type = p-obj-type
shop-code = p-obj-code
.
assign
v-versiond = decimal(p-version)
no-error .
{ str/get-chkc.i run }
get-chkc_context.pos-type = dflt-cd.

FIND FIRST ub.shop WHERE
          ub.shop.obj-code = p-obj-code no-lock no-error.
find first bff_cash-pay no-lock where
          bff_cash-pay.cdpay-code = not-nal
      and bff_cash-pay.curr-code = base-cass no-error.
if available bff_cash-pay then do:
  assign
  not-nal-curr = bff_cash-pay.curr-code.
end.

input stream ChkStream from value(file_).
_repeat:
REPEAT :
  import stream ChkStream unformatted ss.
  assign
  var-file-line-num = var-file-line-num + 1
  .
  if ss = "":U then next _repeat.
  CASE substring( ss, 1, 2 ) :
    when '99' then  do: /* Курсы валют */
      run proc-99 in this-procedure (input ss) no-error .
    end.
    when '01' then do:  /* Заголовок чека */
      run proc-end in this-procedure no-error .
      assign
      exist = yes
      .  /* Предпологаем что уже есть в базе */
      run proc-01 in this-procedure (input ss) no-error .
    end.
    when '03' then do: /* Итоги чека */
      run proc-03 in this-procedure (input ss) no-error .
    end.
    when '04' then do:  /* Оплата чека */
      run proc-04 in this-procedure(input ss) no-error.
    end.
    when '11' OR when '12' then do:       /* Строка чека */
      run proc-11-12 in this-procedure (input ss) no-error .
    end. /*        when '11' OR when '12' */
  END CASE .
END .   /* REPEAT */
DO TRANSACTION:
  run proc-end in this-procedure no-error .
END.
error-status:error = false.
input stream ChkStream close.
run gbl/filename.p (
                input  file_
               ,output p-full-path
               ,output sav
               ,output filenamebo
               ,output p-file-name-no-ext
               ,output p-file-name-ext
                ).

if index(filenamebo, "ll":U) > 0 then
assign
filenamebo = REPLACE(FILENAMEbo, "ll":U, "zz":U) no-error.
else
assign
filenamebo = REPLACE(FILENAMEbo, "l":U, "z":U) no-error.
os-copy value(file_) value(sav + "\sav\":U + FILENAMEbo).
if os-error = 0 then
os-delete value(file_).


procedure proc-99 :
define input parameter p-ss as character no-undo .

DEFINE VARIABLE var-code-int as integer no-undo .
DEFINE VARIABLE var-code-chr as character no-undo .

  do
  on error undo, return error
  :
    assign
    var-code-int = int( substring( p-ss, 3, 3 ) )
    var-code-chr = TRIM(substring( p-ss, 3, 3 ), "0")
    rate-por = exp( 10, int( substring( p-ss, 14, 1 ) ) )
    cass-rate = dec( substring( p-ss, 6, 8 ) )
    no-error .

    if var-code-int <= num-entries( curr-list ) AND
       var-code-int > 0 AND
      lookup(var-code-chr, curr-list) > 0 then do:
      FIND curr-cass WHERE
            curr-cass.code = int( entry( var-code-int, curr-list ) ) NO-ERROR.
      if NOT available curr-cass then
      CREATE curr-cass.
      assign
      curr-cass.code = int( entry( var-code-int, curr-list ) )
      curr-cass.scale = rate-por
      curr-cass.rate = cass-rate
      .
      if curr-cass.code = get-chkc_context.base-code then do:
        assign
        v-base-rate = cass-rate
        v-base-scale = rate-por
        .
      end.
    end.
  end. /*doe*/

end procedure. /* proc-99 */


procedure proc-01 :
define input parameter p-ss as character no-undo .

DEFINE VARIABLE yy as integer no-undo.

  do
  on error undo, return error
  :

    assign
    yy = int( substr( p-ss, 31, 2 ) )
    yy = int( truncate( year( today ) / 100, 0 ) ) * 100 + yy
    chk-num_  = int(substr(p-ss, 3, 12))
    chk-date_ = date(int(substr(p-ss, 29, 2)),int(substr(p-ss, 27, 2)), yy)
    chk-time_ = int(substr(p-ss, 48, 2)) * 3600 + int(substr(p-ss, 51, 2)) * 60
    sales-man_ = int(substr(p-ss, 33, 4))
    pay-desk_ = int(substr(p-ss, 37, 3))
    cashier_ =  int(substr(ss, 40, 4))
    d-card_ = left-trim(trim(substr(ss, 15, 12)), '0')
    z-num_ = integer(substr(ss, 92, 4))
    chk-type_ =  (if substr(ss, 46, 2) = "00":U
                  then integer({&rcpt-sale})
                  else integer({&rcpt-return})
                  )
    no-error
    .
    if error-status:error then do:
      {&error-in-file-format}
    end.
    FIND  ub.chk-doc where
          ub.chk-doc.obj-type = p-obj-type and
          ub.chk-doc.obj-code = p-obj-code and
          ub.chk-doc.chk-num = chk-num_ and
          ub.chk-doc.chk-date = chk-date_ and
          ub.chk-doc.chk-time = chk-time_ and
          ub.chk-doc.sales-man = sales-man_ and
          ub.chk-doc.pay-desk = pay-desk_ NO-WAIT NO-ERROR.
    IF NOT AVAIL ub.chk-doc AND NOT LOCKED ub.chk-doc  AND NOT AMBIGUOUS ub.chk-doc then do:
      assign
      exist = no
      lll = lll + 1
      .
      CREATE ub.chk-doc.
      assign
      for-chk-type = ""
      lnp = 0
      lng = 0
      var-discnt-id = 0
      ub.chk-doc.obj-code = p-obj-code
      ub.chk-doc.obj-type = p-obj-type
      ub.chk-doc.doc-code = (if get-chkc_context.db-num = 0
                          then string(next-value(s-chk, {&db-name_schema}))
                          else string(p-obj-code) + {&slash-char} + string(next-value(s-chk, {&db-name_schema})))
      ub.chk-doc.chk-num = chk-num_
      ub.chk-doc.chk-date = chk-date_
      ub.chk-doc.shift-date = ub.chk-doc.chk-date
      ub.chk-doc.src-shift-date =  ub.chk-doc.shift-date
      ub.chk-doc.shift-num = 0
      ub.chk-doc.shift-name = '':U
      ub.chk-doc.src-shift-name = '':U
      ub.chk-doc.chk-time = chk-time_
      ub.chk-doc.sales-man = sales-man_
      ub.chk-doc.pay-desk = pay-desk_
      ub.chk-doc.cashier = cashier_
      ub.chk-doc.src-d-card = d-card_
      ub.chk-doc.z-number = z-num_
      ub.chk-doc.chk-type = chk-type_
      ub.chk-doc.src-d-pcnt = 0
      ub.chk-doc.d-pcnt = 0
      ub.chk-doc.correct = yes
      for-chk-type = ""
      prev-code = ub.chk-doc.doc-code
      .
      if v-versiond >= 33.0 then do:
        assign
        ub.chk-doc.cash-rate = ( if (get-chkc_context.r-b = {&r-b-base} and get-chkc_context.base-code = 0) or get-chkc_context.r-b = {&r-b-rubl} then 1 else v-base-rate )
        ub.chk-doc.cash-scale = ( if (get-chkc_context.r-b = {&r-b-base} and get-chkc_context.base-code = 0) or get-chkc_context.r-b = {&r-b-rubl} then 1 else v-base-scale )
        .
      end.
      else do:
        assign
        ub.chk-doc.cash-rate = if avail curr-cass
                      then curr-cass.rate / curr-cass.scale
                      else 1
        ub.chk-doc.cash-scale = 1
        .
      end.

    end. /* not(can-find) */
  end. /* doe */

end procedure. /* proc-01 */

procedure proc-03 :
define input parameter p-ss as character no-undo .


DEFINE VARIABLE var-sub-d as decimal no-undo .
  do
  on error undo, return error
  :
    if exist then return.
    if v-versiond >= 33.0 then do:
      assign
      var-sub-d  = ((DEC(substr(p-ss, 20, 12)) - DEC(substr(p-ss, 51,11))) / 100)/
                  ( if (get-chkc_context.r-b = {&r-b-base} and get-chkc_context.base-code = 0) or get-chkc_context.r-b = {&r-b-rubl} then 1 else (ub.chk-doc.cash-rate / ub.chk-doc.cash-scale))
      no-error .
    end.
    else do:
      assign
      var-sub-d  = (DEC(substr(p-ss, 20, 12)) - DEC(substr(p-ss, 51,11))) / 100
      no-error
      .
    end.

    if error-status:error then do:
      {&error-in-file-format}
    end.
    if var-sub-d = 0 then return.
    create ub.chk-discnt.
    assign
    ub.chk-discnt.doc-code = ub.chk-doc.doc-code
    ub.chk-discnt.record-type = 0
    ub.chk-discnt.discnt-id = (var-discnt-id + 1)
    ub.chk-discnt.line-num = ub.chk-gds.line-num
    ub.chk-discnt.time-oper = ub.chk-doc.chk-time
    ub.chk-discnt.line-type = integer({&discnt-sub-total})
    ub.chk-discnt.line-sign = yes
    ub.chk-discnt.pass-discnt = integer({&discnt-p-auto})
    ub.chk-discnt.value-type = integer({&discnt-v-abs})
    ub.chk-discnt.discnt-type = if ub.chk-doc.src-d-card <> ""
                              then integer({&discnt-t-d-card})
                              else integer({&discnt-t-sum})
    ub.chk-discnt.src-d-card = ub.chk-doc.src-d-card
    ub.chk-discnt.discnt-value-abs = var-sub-d
    ub.chk-discnt.discnt-value-pcnt = if netto-for-sub-d = 0
                                    then 0
                                    else var-sub-d * 100 / netto-for-sub-d
    ub.chk-discnt.object-line-num = 0
    ub.chk-discnt.object-sum = netto-for-sub-d
    ub.chk-discnt.pay-desk = ub.chk-doc.pay-desk
    ub.chk-discnt.obj-code = ub.chk-doc.obj-code
    ub.chk-discnt.obj-type = ub.chk-doc.obj-type
    ub.chk-discnt.chk-date = ub.chk-doc.chk-date
    ub.chk-discnt.chk-time = ub.chk-doc.chk-time
    var-discnt-id = var-discnt-id + 1
    sub-d = sub-d + var-sub-d
    netto-for-sub-d = netto-for-sub-d - sub-d
    .
    release ub.chk-discnt.
  end. /*doe*/

end procedure. /* proc-03 */


procedure proc-04 :
define input parameter p-ss as character no-undo .

DEFINE VARIABLE dop-code as integer no-undo .
  do
  on error undo, return error
  :
    if exist then return.
    assign
    pay_code = int( substr( p-ss, 3, 2 ) )
    curr_code = if v-versiond >= 33.0
                then
                (if pay_code < 13 or (pay_code >= 54 and pay_code  <= 93)
                then /*( if not-nal-curr = 0 then 0 else v-base-code )*/
                     integer(substr(p-ss, 5, 2))
                else ( if pay_code = 13 then base-cass else int( entry( pay_code - 13, curr-list ) ) ))
                else
                (if pay_code < 13
                then ( if not-nal-curr = 0 then 0 else get-chkc_context.base-code )
                else ( if pay_code = 13 then base-cass else int( entry( pay_code - 13, curr-list ) ) )
                )
    cass-rate = decimal(substr( p-ss, 41, 10)) / 10000 / exp(10, int(substr( p-ss, 40, 1 )))
    pay-card_ = trim(substr(p-ss, 53, 20))
    pass-pay_ = (if substr(p-ss, 83, 1) = "A":U
                 then 0
                 else 1)
    tot_sum = dec( substr( p-ss, 20, 12 ) ) / 100
    no-error .
    if error-status:error then do:
      {&error-in-file-format}
    end.
    create ub.chk-pay.
    assign
    lnp = lnp + 1
    ub.chk-pay.doc-code = ub.chk-doc.doc-code
    ub.chk-pay.pay-code = pay_code
    ub.chk-pay.curr-code = curr_code
    ub.chk-pay.line-num = lnp
    ub.chk-pay.chk-date = ub.chk-doc.chk-date
    ub.chk-pay.tot-sum = tot_sum
    ub.chk-pay.obj-code = p-obj-code
    ub.chk-pay.obj-type = p-obj-type
    ub.chk-pay.time-oper = ub.chk-doc.chk-time
    ub.chk-pay.cash-rate = cass-rate / ub.chk-doc.cash-rate
    ub.chk-pay.bank-rate = 1
    ub.chk-pay.bank-scale = 1
    ub.chk-pay.pass-pay = pass-pay_
    ub.chk-pay.pay-card = pay-card
    ub.chk-pay.line-type = "":U
    ub.chk-pay.line-sign = (if ub.chk-doc.chk-type = integer({&rcpt-sale})
                        then (chk-pay.tot-sum >= 0)
                        else (chk-pay.tot-sum <= 0)
                        )
    ub.chk-pay.is-error = no
    .
  end. /*doe*/

end procedure. /* proc-04 */

procedure proc-11-12 :
define input parameter p-ss as character no-undo .


DEFINE VARIABLE discnt-sale as integer no-undo .
DEFINE VARIABLE discnt-value as decimal no-undo .
define variable m-sign as character no-undo .

  do
  on error undo, return error
  :
    if exist then return.
    if v-versiond >= 33.0 then do:
      assign
      price-from-check = (dec( substr( p-ss, 65, 12 ) ) / 100 )
      curr-string-qnty = dec( substr( p-ss, 32, 8 ) ) / 100
      bc-buf = trim(substr( p-ss, 5, 16 ))
      discnt-sale = integer(substr( p-ss, 3, 2 ))
      discnt-value = - dec( substr(p-ss, 40, 11 ) ) / 100
      sales-man_ = integer(substr(p-ss, 123, 4))
      no-error.
    end.
    else do:
      assign
      m-sign           = substr(p-ss, 32, 1)
      price-from-check = dec( substr( p-ss, 21, 11 ) ) / 100
      curr-string-qnty = dec( substr( p-ss, 32, 8 ) ) / 100
      bc-buf = trim(substr( p-ss, 5, 16 ))
      discnt-sale = integer(substr( p-ss, 3, 2 ))
      discnt-value = dec( substr(p-ss, 40, 11 ) ) / 100
      no-error.
    end.


    if error-status:error then do:
      {&error-in-file-format}
    end.
    if not v-versiond >= 33.0 then do:
      if m-sign = '-' and lng = 0 then do:
        assign
        ub.chk-doc.chk-type = integer({&rcpt-return}).
      end.
    end.
    if unq-artc then /*не совмехкастория*/ do:
      FIND first ub.goods where
                  ub.goods.artic = bc-buf no-lock NO-ERROR.
      if available ub.goods then do:
        FIND FIRST ub.gds-prt where
                    ub.gds-prt.upper-code = ub.goods.prt-root      no-lock.
        FIND FIRST ub.bar-code where
                    ub.bar-code.gds-code = ub.goods.gds-code and
                    ub.BAR-CODE.UNIT-CLI = ub.GOODS.UNIT-BASE and
                    ub.BAR-CODE.IN-CODE = "" and
                    ub.BAR-CODE.PART-CODE = "" No-LOCK.
        assign
        bc-buf = if avail ub.bar-code
                then string(ub.bar-code.b-code)
                else "":U
        .
      end.
    end. /*UNQ-ARTC = YES*/
    if curr-string-qnty <> 0 then /* ненулевое кол-во */ do:
      CREATE ub.chk-gds.
      assign
      lng = lng + 1
      ub.chk-gds.doc-code = ub.chk-doc.doc-code
      ub.chk-gds.line-num = lng
      ub.chk-gds.chk-date = ub.chk-doc.chk-date
      ub.chk-gds.b-code =  0
      ub.chk-gds.grp-code = 0
      ub.chk-gds.src-code = bc-buf
      ub.chk-gds.is-error = no
      ub.chk-gds.price-base = price-from-check
      ub.chk-gds.src-qnty = curr-string-qnty
      ub.chk-gds.doc-qnty = 0
      ub.chk-gds.src-price = price-from-check
      ub.chk-gds.src-sum   =  ub.chk-gds.src-qnty * ub.chk-gds.src-price
      ub.chk-gds.src-discnt = 0
      ub.chk-gds.pass-gds = 0
      ub.chk-gds.line-type =  "":U
      ub.chk-gds.time-oper = ub.chk-doc.chk-time
      ub.chk-gds.line-sign = (if ub.chk-doc.chk-type = integer({&rcpt-sale})
                          then (chk-gds.src-qnty >= 0)
                          else (chk-gds.src-qnty <= 0)
                          )
      ub.chk-gds.src-discnt = if v-versiond >= 33.0
                           then
                           (if discnt-sale = 41
                            then ub.chk-gds.src-price * discnt-value / 100
                            else (  if discnt-sale = 42
                                    then discnt-value / ub.chk-gds.src-qnty / (ub.chk-doc.cash-rate / ub.chk-doc.cash-scale)
                                    else  ub.chk-gds.src-discnt
                                ))
                           else
                           (if discnt-sale = 41
                            then ub.chk-gds.src-price * discnt-value / 100
                            else (  if discnt-sale = 42
                                    then discnt-value / ub.chk-gds.src-qnty
                                    else  ub.chk-gds.src-discnt
                                )
                           )
      netto-for-sub-d = netto-for-sub-d + ub.chk-gds.src-sum - ub.chk-gds.src-discnt * ub.chk-gds.src-qnty
      .
      if ub.chk-gds.src-discnt <> 0 then do:
        create ub.chk-discnt.
        assign
        ub.chk-discnt.doc-code = ub.chk-doc.doc-code
        ub.chk-discnt.record-type = 0
        ub.chk-discnt.discnt-id = (var-discnt-id + 1)
        ub.chk-discnt.line-num = ub.chk-gds.line-num
        ub.chk-discnt.time-oper = ub.chk-doc.chk-time
        ub.chk-discnt.line-type = integer({&discnt-gds})
        ub.chk-discnt.line-sign =  (chk-gds.src-qnty >= 0 ) NE (chk-gds.src-discnt > 0 )
        ub.chk-discnt.pass-discnt = integer({&discnt-p-auto})
        ub.chk-discnt.value-type = integer({&discnt-v-unknown})
        ub.chk-discnt.discnt-type = integer({&discnt-t-unknown})
        ub.chk-discnt.src-d-card = ub.chk-doc.src-d-card
        ub.chk-discnt.discnt-value-abs = ub.chk-gds.src-discnt
        ub.chk-discnt.object-qnty = ub.chk-gds.src-qnty
        ub.chk-discnt.object-sum = ub.chk-gds.src-sum
        ub.chk-discnt.discnt-value-pcnt = if ub.chk-gds.src-sum <> 0 then
                                        ub.chk-gds.src-discnt * ub.chk-gds.src-qnty / ub.chk-gds.src-sum * 100
                                        else 0
        ub.chk-discnt.object-line-num = ub.chk-gds.line-num
        ub.chk-discnt.pay-desk = ub.chk-doc.pay-desk
        ub.chk-discnt.obj-code = ub.chk-doc.obj-code
        ub.chk-discnt.obj-type = ub.chk-doc.obj-type
        ub.chk-discnt.chk-date = ub.chk-doc.chk-date
        ub.chk-discnt.chk-time = ub.chk-doc.chk-time
        var-discnt-id = var-discnt-id + 1
        .
      end.
    end. /*ненулеове кол-во*/
  end. /*  doe */

end procedure. /* proc-11-12 */


procedure proc-end :
  do
  on error undo, return error
  :
     /*проверка всего что только что приняли*/
     get-chkc_context.ll = lll.
    { str/libchkvl_getcheck.i
      "buffer get-chkc_context:handle"
      ~{&add-def~}
      ''
      yes
      yes
      ?
      lng-sub-d
      sub-d
      var-discnt-id
      prev-code
      no-error
     }
     assign
     prev-code = "":U
     mc-prev-code = "":U
     p-view-log = (p-view-log or get-chkc_context.view-log)
     lll = get-chkc_context.ll
     .
  end.

end procedure. /* proc-end */