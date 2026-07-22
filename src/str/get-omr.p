block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: get-omr.p $
$Archive: str/get-omr.p $

Программа приема чеков с касс OMRON

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/26/06
Author: Bakhtadze Natalya
Creation date: 01/26/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter file_ as character no-undo.
define input-output parameter p-view-log as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":u .
define variable vss-author      as character no-undo init "$Author: expertek $":u .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: get-omr.p $":u .
define variable vss-archive     as character no-undo init "$Archive: str/get-omr.p $":u .
define variable vss-description as character no-undo init "Программа приема чеков с касс omron" .
{ cmp/vssrevis.i }


{ str/get-chk.i }
/*общие для кассовой части и чековой*/

{ str/get-chkc.i def }
/*только чековая часть*/
dflt-cd = {&cd-type-omron}.

DEFINE VARIABLE yy as integer no-undo .

define temp-table curr-cass no-undo
field code as int
field scale as int
field rate as dec
index pi is unique primary        code.


assign
shop-type = p-obj-type
shop-code = p-obj-code
.

{ str/get-chkc.i run }
get-chkc_context.pos-type = dflt-cd.

input stream ChkStream from value( file_ ) .

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
      run proc-01 in this-procedure (ss) no-error .
    end.
    when '03' then /* Итоги чека */ do:
      run proc-03 in this-procedure (ss) no-error .
    end.
    when '04' then do:  /* Оплата чека */
      run proc-04 in this-procedure (ss) no-error .
    end.
    when '11' or when '12' then do:       /* Строка чека */
      run proc-11-12 in this-procedure (ss) no-error .
    end.
  END CASE .
END .
input stream ChkStream close.
DO TRANSACTION:
  run proc-end in this-procedure no-error .
END.


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

procedure proc-01 :
define input parameter p-ss as character no-undo .

  do
  on error undo, return error
  :
    assign
    chk-num_ = int(substr(p-ss,3,12))
    yy = int( substr( p-ss, 31, 2 ) )
    yy = int( truncate( year( today ) / 100, 0 ) ) * 100 + yy
    chk-date_ = date(int(substr(p-ss, 29, 2)), int(substr(p-ss, 27, 2)), yy)
    chk-time_ = int(substr(p-ss, 48, 2)) * 3600 + int(substr(p-ss, 51, 2)) * 60
    sales-man_ = int(substr(p-ss, 33, 4))
    pay-desk_ = int(substr(p-ss, 37, 3))
    cashier_ = int(substr(p-ss, 40, 4))
    chk-type_ =  (if substr(p-ss, 46, 2) = "00":U
                  then integer({&rcpt-sale})
                  else integer({&rcpt-return})
                 )
    no-error .
    if error-status:error then do:
      {&error-in-file-format}
    end.
    assign
    exist = yes   /* Предпологаем что уже есть в базе */
    .
    find  ub.chk-doc where
          ub.chk-doc.obj-type = p-obj-type and
          ub.chk-doc.obj-code = p-obj-code and
          ub.chk-doc.chk-num = chk-num_ and
          ub.chk-doc.chk-date = chk-date_ and
          ub.chk-doc.chk-time = chk-time_ and
          ub.chk-doc.sales-man = sales-man_ and
          ub.chk-doc.pay-desk =  pay-desk_ NO-WAIT NO-ERROR.
    IF NOT AVAIL ub.chk-doc AND
        NOT LOCKED ub.chk-doc AND
        NOT AMBIGUOUS ub.chk-doc then  do:
      assign
      exist = no
      lll = lll + 1 .
      FIND curr-cass WHERE
            curr-cass.code = get-chkc_context.base-code no-error.
      CREATE ub.chk-doc.
      assign
      lng = 0
      lnp = 0
      sub-d = 0
      var-discnt-id = 0
      netto-for-sub-d = 0
      ub.chk-doc.obj-code = p-obj-code
      ub.chk-doc.obj-type = p-obj-type
      ub.chk-doc.doc-code =  (if get-chkc_context.db-num = 0
                            then string(next-value(s-chk, {&db-name_schema}))
                            else string( p-obj-code ) + {&slash-char} + string( next-value( s-chk, {&db-name_schema} ) )
                            )
      ub.chk-doc.chk-num = chk-num_
      ub.chk-doc.chk-date = chk-date_
      ub.chk-doc.shift-date = ub.chk-doc.chk-date
      ub.chk-doc.src-shift-date = ub.chk-doc.chk-date
      ub.chk-doc.shift-num = 0
      ub.chk-doc.shift-name = '':U
      ub.chk-doc.src-shift-name = '':U
      ub.chk-doc.chk-time = chk-time_
      ub.chk-doc.sales-man = sales-man_
      ub.chk-doc.pay-desk = pay-desk_
      ub.chk-doc.cashier = cashier_
      for-chk-type = ""
      prev-code = ub.chk-doc.doc-code
      ub.chk-doc.cash-rate = if avail curr-cass
                          then curr-cass.rate / curr-cass.scale
                          else 1
      ub.chk-doc.cash-scale = 1
      ub.chk-doc.z-number = 0
      ub.chk-doc.correct = yes
      ub.chk-doc.chk-type =  chk-type_
      ub.chk-doc.d-pcnt = 0
      ub.chk-doc.src-d-pcnt = 0

      .
    end. /* not(can-find) */
  end. /*doe*/

end procedure. /* proc-01 */


procedure proc-03 :
define input parameter p-ss as character no-undo .

DEFINE VARIABLE var-sub-d as decimal no-undo .
  do
  on error undo, return error
  :
    if exist then return.
    assign
    var-sub-d =  dec( substr( p-ss, 20, 12 ) ) - dec( substr( p-ss, 51, 11 ) )
    no-error
    .
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

DEFINE VARIABLE dop_code  as integer no-undo .
  do
  on error undo, return error
  :
    if exist then return.

    assign
    dop_code = int( substr( p-ss, 3, 2 ) )
    tot_sum = dec( substr(p-ss, 20, 12 ) ) / 100

    curr_code = if dop_code < 13
                then get-chkc_context.base-code
                else  ( if dop_code = 13
                        then get-chkc_context.base-code
                        else int( entry( dop_code - 13, curr-list ) )
                      )
    pay_code =  if dop_code < 13
                then int( entry( pay_code - 1, pay-list ) )
                else int( nal )
    tot_sum = dec( substr( p-ss, 20, 12 ) ) / 100
    cass-rate = dec(substr(p-ss, 41, 10)) / 10000
    rate-por = int(substr(p-ss, 40, 1))
    cass-rate = cass-rate * exp( 10, int( rate-por ) )
    no-error
    .
    if error-status:error then do:
      {&error-in-file-format}
    end.

    CREATE ub.chk-pay.
    assign
    lnp = lnp  + 1
    ub.chk-pay.doc-code = ub.chk-doc.doc-code
    ub.chk-pay.line-num = lnp
    ub.chk-pay.chk-date = ub.chk-doc.chk-date
    ub.chk-pay.tot-sum = tot_sum
    ub.chk-pay.obj-code = p-obj-code
    ub.chk-pay.obj-type = p-obj-type
    ub.chk-pay.CASH-RATE = cass-rate / ub.chk-doc.cash-rate
    ub.chk-pay.bank-rate = 1
    ub.chk-pay.bank-scale = 1
    ub.chk-pay.time-oper = ub.chk-doc.chk-time
    ub.chk-pay.pay-card = "":U
    ub.chk-pay.pass-pay = 0
    ub.chk-pay.line-type = "":U
    ub.chk-pay.line-sign = (if ub.chk-doc.chk-type = integer({&rcpt-sale})
                          then (chk-pay.tot-sum >= 0)
                          else (chk-pay.tot-sum <= 0)
                          )
    ub.chk-pay.is-error = no
    ub.chk-pay.tot-sum = tot_sum
    .
  end. /*doe*/

end procedure. /* proc-04 */


procedure proc-11-12 :
define input parameter p-ss as character no-undo .

DEFINE VARIABLE discnt-sale as integer no-undo .
DEFINE VARIABLE discnt-value as decimal no-undo .
  do
  on error undo, return error
  :
    if exist then return.
    assign
    bc-buf = trim( substr( p-ss, 5, 16 ) )
    curr-string-qnty = dec(substr( p-ss, 32, 8 ) ) / 100
    discnt-sale = integer(substr( p-ss, 3, 2 ))
    price-from-check = dec( substr(p-ss, 21, 11 ) ) / 100 /* {&to-bo} */
    discnt-value = dec( substr(p-ss, 40, 11 ) ) / 100
    no-error
    .
    if error-status:error then do:
      {&error-in-file-format}
    end.
    /*               todo                                   */
    /*выяснить может ли этот блок лечь на стандартный bc-rcnz*/
    /*
    FIND prod-bc WHERE
          prod-bc.b-str = bc-buf no-lock NO-ERROR.
    if available prod-bc then do:
      FIND FIRST bar-code No-LOCK WHERE
                  bar-code.b-code = prod-bc.b-code NO-ERROR.
      IF AVAIL bar-code then do:
        FIND goods WHERE goods.gds-code = bar-code.gds-code No-LOCK.
        FIND gds-prt WHERE gds-prt.upper-code = goods.prt-root NO-LOCK .
        b-c = bar-code.b-code.
      end.
      else b-c = ?.
    end.
    else
    assign
    b-c = if int( substr( s, 5, 16 ) ) < 99999999
          then int( substr( s, 15, 6 ) )
          else int( substr( s, 14, 6 ) ) .
  FIND bar-code where
        bar-code.b-code = b-c NO-LOCK NO-ERROR .

    */
    if curr-string-qnty <> 0 then /* ненулевое кол-во */  do:
      CREATE ub.chk-gds.
      assign
      lng = lng + 1
      ub.chk-gds.doc-code = ub.chk-doc.doc-code
      ub.chk-gds.line-num = lng
      ub.chk-gds.chk-date = ub.chk-doc.chk-date
      ub.chk-gds.b-code = 0
      ub.chk-gds.grp-code = 0
      ub.chk-gds.src-code = bc-buf
      ub.chk-gds.is-error = no
      ub.chk-gds.src-price = price-from-check
      ub.chk-gds.src-qnty = curr-string-qnty
      ub.chk-gds.doc-qnty = 0
      ub.chk-gds.time-oper = ub.chk-doc.chk-time
      ub.chk-gds.src-sum = ub.chk-gds.src-qnty * ub.chk-gds.src-price
      ub.chk-gds.pass-gds = 0
      ub.chk-gds.line-type =  "":U
      ub.chk-gds.line-sign = (if ub.chk-doc.chk-type = integer({&rcpt-sale})
                            then (chk-gds.src-qnty >= 0)
                            else (chk-gds.src-qnty <= 0)
                            )
      ub.chk-gds.src-discnt = if discnt-sale = 41
                            then ub.chk-gds.src-price * discnt-sale / 100
                            else (  if discnt-sale = 42
                                    then discnt-value / ub.chk-gds.src-qnty
                                    else  ub.chk-gds.src-discnt
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
                                        ub.chk-gds.src-discnt / ub.chk-gds.src-sum * 100
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
    end. /*current-string-qnty <> 0*/
  end. /*doe*/

end procedure. /* proc-11-12 */

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
    end.
  end. /*doe*/

end procedure. /* proc-99 */