block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: get-ipcs.p $
$Archive: str/get-ipcs.p $

Программа приема чеков с касс IPC-servis+

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
/*абсолютный путь*/
define input parameter p-path as character no-undo .
/*полное имя файла*/
define input parameter filename as char no-undo.
/*сокращенное имя файла*/
define input parameter file_ as char no-undo.
define input-output parameter p-view-log as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":u .
define variable vss-author      as character no-undo init "$Author: expertek $":u .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: get-ipcs.p $":u .
define variable vss-archive     as character no-undo init "$Archive: str/get-ipcs.p $":u .
define variable vss-description as character no-undo init "Программа приема чеков с касс IPC-servis+" .
{ cmp/vssrevis.i }

{ str/get-chk.i }
/*общие для кассовой части и чековой*/

{ str/get-chkc.i def }
/*только чековая часть*/

DEFINE VARIABLE id_ as character no-undo .
DEFINE VARIABLE z-val as integer no-undo .
DEFINE VARIABLE cass-num as integer no-undo .


define buffer b-doc for ub.chk-doc.
define buffer b-pay for ub.chk-pay.
define buffer b-gds for ub.chk-gds.
define buffer b-discnt for ub.chk-discnt.

define temp-table ipcs-file No-undo
field seq-val as integer
field z-val as integer
field cass-num as integer
index ipcsf is unique primary
z-val
cass-num
.

define temp-table tt-str no-undo
field id as character
field PS like ub.chk-doc.PS
field d-card like ub.chk-doc.d-card
field discnt-value-abs like ub.chk-discnt.discnt-value-abs
index pi is unique primary
id ascending.


assign
prev-code = ""
.
assign
shop-type = p-obj-type
shop-code = p-obj-code
.

{ str/get-chkc.i run }
define variable p-pos-type as character no-undo .
assign
dflt-cd = {&cd-type-ipc-servispl}
p-pos-type = dflt-cd
get-chkc_context.pos-type = p-pos-type
.
run get-comments in this-procedure no-error .

run get-cards in this-procedure no-error .

input stream ChkStream from value(filename).
M-R:
REPEAT :
  import stream ChkStream unformatted ss.
  assign
  var-file-line-num = var-file-line-num + 1
  .
  if ss = "" then do:
    run proc-end in this-procedure no-error .
    NEXT M-R.
  end.
  run proc-str in this-procedure (ss) no-error .
END . /* REPEAT */
DO TRANSACTION:
  if file_ = "cashsail.dat" or ENTRY(2, file_, ".") = "ret" then do:
    run proc-end in this-procedure no-error .
  end.
END.

input stream ChkStream close.


FIND FIRST ipcs-file where
           ipcs-file.z-val = z-val AND
           ipcs-file.cass-num = cass-num  NO-ERROR.
IF NOT AVAIL ipcs-file then do:
    create ipcs-file.
    assign
    ipcs-file.cass-num = cass-num
    ipcs-file.z-val = z-val
    ipcs-file.seq-val = next-value(s-file-num, {&db-name_schema})
    .
END.
if entry(2, file_, ".") = "dat" then do:
  os-copy value(filename) value(p-path + {&slash-char} + entry(1,file_,'.') + '.' + string(ipcs-file.seq-val)).
end.
if file_ = "cashsail.dat" then do:
  if search(p-path + {&slash-char} + "cashcmnt.dat":U) <> ? then do:
    os-copy value(p-path + {&slash-char} + "cashcmnt.dat":U) value(p-path + {&slash-char} + "cashcmnt":U + '.' + string(ipcs-file.seq-val)).
  end.
  if search(p-path + {&slash-char} + "cashdcrd.dat":U) <> ? then do:
    os-copy value(p-path + {&slash-char} + "cashdcrd.dat":U) value(p-path + {&slash-char} + "cashdcrd":U + '.' + string(ipcs-file.seq-val)).
  end.
end.
if can-do("dat,ret,del":U, entry(2,filename,'.')) then
os-delete value(filename).
error-status:error = false.

procedure get-comments :

  do
  on error undo, return error
  :
    /*закачаем во врем таблицу комментарии к чекам*/
    if search(p-path + {&slash-char} + "cashcmnt.dat":U) <> ? then do:
      assign
      var-file-line-num = 0
      .
      input stream ChkStream from value(p-path + {&slash-char} + "cashcmnt.dat":U).
      _cashcmnt:
      REPEAT:
        import stream ChkStream unformatted ss.
        assign
        var-file-line-num = var-file-line-num + 1
        .
        if ss = "":U then NEXT _cashcmnt.
        run proc-comments in this-procedure (input ss) no-error .
      END. /*repeat*/
    end. /*комментарии*/
    output stream ChkStream close.
  end.

end procedure. /* get-comments */

procedure proc-comments :
define input parameter p-ss as character no-undo .

DEFINE VARIABLE PS_ as character no-undo .

  do
  on error undo, return error
  :
    assign
    z-val = integer(entry(3,p-ss))
    cass-num = integer(entry(2, p-ss))
    id_ = entry(3,p-ss) + {&slash-char} + entry(1,p-ss) + {&slash-char} + entry(2,p-ss) + {&slash-char} + entry(4,p-ss)
    ps_ = entry(5,p-ss)
    no-error
    .
    if error-status:error then do:
      {&error-in-file-format}
    end.
    find first tt-str where
                tt-str.id = id_ no-error .
    if not avail tt-str then do:
      create tt-str.
      assign
      tt-str.id = id_
      tt-str.PS = "@" + PS_ + "@"
      .
    end. /*if not avail tt-str*/
  end. /*doe*/
end procedure. /* proc-comments */


procedure get-cards :

  do
  on error undo, return error
  :
    assign
    var-file-line-num = 0
    .
    /*закачаем во врем таблицу d-card к чекам*/
    if search(p-path + {&slash-char} + "cashdcrd.dat":U) <> ? then do:
      input stream ChkStream from value(p-path + {&slash-char} + "cashdcrd.dat":U).
      _cashdcrd:
      REPEAT:
        import stream ChkStream unformatted ss.
        assign
        var-file-line-num = var-file-line-num + 1
        .
        if ss = "":U then NEXT _cashdcrd.
        run proc-cards in this-procedure (input ss ) no-error .
      END. /*repeat*/
    end. /*карты*/
    output stream ChkStream close.
  end.
end procedure. /* get-cards */


procedure proc-cards :
define input parameter p-ss as character no-undo .

DEFINE VARIABLE var-dc-discnt as decimal no-undo .
DEFINE VARIABLE dopd-card as character no-undo .
DEFINE VARIABLE idopd-card as decimal no-undo .
DEFINE VARIABLE hh as integer no-undo .

  do
  on error undo, return error
  :
    assign
    z-val = integer(entry(3,p-ss))
    cass-num = integer(entry(2, p-ss))
    id_ = entry(3,p-ss) + {&slash-char} + entry(1,p-ss) + {&slash-char} + entry(2,p-ss) + {&slash-char} + entry(4,p-ss)
    dopd-card = trim(entry(6,p-ss), {&double-quote})
    var-dc-discnt = decimal(trim(entry(7,p-ss), {&double-quote}))
    no-error
    .
    do hh = 1 to length(dopd-card):
      assign
      idopd-card = decimal(substr(dopd-card, hh))
      no-error
      .
      if error-status:error = no then do:
        assign
        dopd-card = substr(dopd-card, hh)
        .
        LEAVE.
      end.
    end.
    find first tt-str where
                tt-str.id = id_ no-error .
    if not avail tt-str then do:
      create tt-str.
      assign
      tt-str.id = id_
      tt-str.d-card = dopd-card
      tt-str.discnt-value-abs = var-dc-discnt
      .
    end. /*if not avail tt-str*/
  end. /*doe*/

end procedure. /* proc-cards */


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
     lll = get-chkc_context.ll
     p-view-log = (p-view-log or get-chkc_context.view-log)
     .
  end.

end procedure. /* proc-end */


procedure proc-str :
define input parameter p-ss as character no-undo .

DEFINE VARIABLE pre-pay-type as character no-undo .
DEFINE VARIABLE cur-pay-type as character no-undo .
DEFINE VARIABLE TotSum-Value as decimal no-undo .
  do
  on error undo, return error
  :
    assign
    z-val = integer(entry(3,p-ss))
    cass-num = integer(entry(2, p-ss))
    id_ = entry(3,p-ss) + {&slash-char} + entry(1,p-ss) + {&slash-char} + entry(2,p-ss) + {&slash-char} + entry(4,p-ss)
    no-error
    .
    if error-status:error then do:
      {&error-in file-format}
    end.
    if entry( 2, file_, '.' ) = "del" then do:
      /*сторнирование*/
      FIND ub.chk-doc WHERE
            ub.chk-doc.doc-code = string(p-obj-code) + {&slash-char} + id_ NO-ERROR .
      if available ub.chk-doc then  do:
        if FALSE /*ub.ub.ub.ub.chk-doc.out-code = ?*/ then do:
          /*Исаков заявляет что не надо удалять чеки никогда - т.к. это не делается в других кассах*/
          DELETE ub.chk-doc.
          return .
        end.
        else do:
          FOR EACH ub.chk-pay WHERE
                  ub.chk-pay.doc-code = chk-doc.doc-code :
            BUFFER-COPY ub.chk-pay TO b-pay
            assign
            b-pay.tot-sum = - ub.chk-pay.tot-sum
            b-pay.tot-rubl = - ub.chk-pay.tot-rubl
            b-pay.tot-base = - ub.chk-pay.tot-base
            b-pay.doc-code = ub.chk-pay.doc-code + "в"
            .
          END.
          FOR EACH ub.chk-gds WHERE
                  ub.chk-gds.doc-code = ub.chk-doc.doc-code :
            BUFFER-COPY chk-gds TO b-gds
            assign
            b-gds.src-qnty = - ub.chk-gds.src-qnty
            b-gds.src-sum  = - chk-gds.src-sum
            b-gds.doc-code = chk-gds.doc-code + "в"
            .
          END.
          FOR EACH ub.chk-discnt WHERE
                  ub.chk-discnt.doc-code = chk-doc.doc-code :
            BUFFER-COPY ub.chk-discnt TO b-discnt
            assign
            b-discnt.discnt-value-abs = - ub.chk-discnt.discnt-value-abs
            b-discnt.discnt-value-pcnt = - ub.chk-discnt.discnt-value-pcnt
            b-discnt.object-qnty = - ub.chk-discnt.object-qnty
            b-discnt.object-sum = - ub.chk-discnt.object-sum
            b-discnt.doc-code = ub.chk-gds.doc-code + "в"
            .
          END.
          CREATE b-doc .
          assign
          lll = lll + 1
          b-doc.chk-date = ub.chk-doc.chk-date
          b-doc.chk-time = ub.chk-doc.chk-time + chk-doc.chk-num
          b-doc.chk-num = - ub.chk-doc.chk-num
          b-doc.sales-man = ub.chk-doc.sales-man
          b-doc.pay-desk = ub.chk-doc.pay-desk
          b-doc.cashier = ub.chk-doc.cashier
          b-doc.office = ub.chk-doc.office
          b-doc.obj-type = ub.chk-doc.obj-type
          b-doc.obj-code = ub.chk-doc.obj-code
          b-doc.tot-doc = - ub.chk-doc.tot-doc
          b-doc.discnt = - ub.chk-doc.discnt
          b-doc.doc-code = ub.chk-doc.doc-code + "в"
          b-doc.netto = - ub.chk-doc.netto
          b-doc.shift-date = ub.chk-doc.shift-date
          b-doc.shift-num = ub.chk-doc.shift-num
          b-doc.shift-name = ub.chk-doc.shift-name
          b-doc.src-d-card = ub.chk-doc.src-d-card
          b-doc.src-shift-date = ub.chk-doc.src-shift-date
          b-doc.cash-rate = ub.chk-doc.cash-rate
          b-doc.cash-scale = ub.chk-doc.cash-scale
          b-doc.z-number = ub.chk-doc.z-number
          b-doc.correct = ub.chk-doc.correct
          b-doc.chk-type = (if ub.chk-doc.chk-type = integer({&rcpt-sale})
                            then integer({&rcpt-return})
                            else integer({&rcpt-sale})
                            )
          b-doc.d-pcnt = ub.chk-doc.d-pcnt
          b-doc.src-d-pcnt = ub.chk-doc.src-d-pcnt
          .
        end.
      end.
    end.
    else do: /*not del*/
      assign
      pay-desk_ = int( entry( 2, p-ss ) )
      chk-num_ = int( entry( 4, p-ss ) )
      sales-man_ = int(entry(15,p-ss))
      chk-date_ =  date( int( substr( entry( 6, p-ss ), 4, 2 ) ),
                         int( substr( entry( 6, p-ss ), 1, 2 ) ),
                         int( substr( entry( 6, p-ss ), 7, 4 ) ) )
      chk-time_ =  truncate ( int(entry(7, p-ss)) / 100, 0 ) * 3600 + /*часы*/
                   (int(entry(7, p-ss)) - truncate ( int(entry(7, p-ss)) / 100, 0 ) * 100) * 60
      z-num_ = int(entry (3 , p-ss))
      cashier_ = int( entry( 16, p-ss ) )
      chk-type_ =  if int(entry(18, p-ss)) > 0
                    then integer({&rcpt-sale})
                    else integer({&rcpt-return})
      bc-buf =  if length(entry(8, p-ss)) < 25
                then trim( substr( entry( 8, p-ss ), 17, length( entry( 8, p-ss ) ) - 17 ) )
                else trim( substr( entry( 8, p-ss ), 18, length( entry( 8, p-ss ) ) - 18 ) )
      price-from-check =  dec( entry( 11, p-ss ) )
      curr-string-qnty = (if chk-type_ = integer({&rcpt-sale})
                         then dec( entry( 10, p-ss ) )
                         else (- dec( entry( 10, p-ss ) ))
                        )
      TotSum-Value = if chk-type_ = integer({&rcpt-sale})
                     then dec( entry( 13, p-ss ) )
                     else (- dec( entry( 13, p-ss ) ))
      tot_sum = if chk-type_ = integer({&rcpt-sale})
                THEN ( if get-chkc_context.base-code <> 0 then dec( entry( 14, p-ss ) ) else dec( entry( 13, p-ss ) ) )
                ELSE ( if get-chkc_context.base-code <> 0 then ( - dec( entry( 14, p-ss ) ) ) else ( - dec( entry( 13, p-ss ) ) ) )
      cur-pay-type = entry( 20, p-ss )
      curr_code =  if can-do( "0,1", entry( 19, p-ss ) )
                   then base-cass
                   else int( entry( int( lookup( cur-pay-type, cass-card ) ), curr-card ) )
      pay_code = if can-do( "0,1", entry( 19, p-ss ) )
                 then pay-nal
                 else int( entry( int( lookup( cur-pay-type, cass-card ) ), trade-card ) )
      no-error .
      if error-status:error then do:
        {&error-in-file-format}
      end.
      FIND chk-doc WHERE
          chk-doc.doc-code = string( p-obj-code ) + {&slash-char} + id_  NO-WAIT NO-ERROR.

      IF (NOT AVAIl chk-doc AND NOT LOCKED CHK-doc  AND NOT AMBIGUOUS chk-doc ) OR
          /*чека в системе нет*/
          can-find(FIRST chk_doc where chk_doc.doc-code = id_) then do:
        /*данный файл закачивается в первый раз*/
        FIND FIRST chk_Doc where chk_doc.doc-code = id_ NO-ERROR.
        IF not avail chk_doc then do:
          run proc-end in this-procedure .
          CREATE chk_doc.
          assign
          chk_doc.doc-code = id_.
          /*чек встречается в файле первый раз*/
          find first tt-str where
          tt-str.id = id_ no-error .
          CREATE chk-doc.
          assign
          lll = lll + 1
          lng = 0
          lnp = 0
          cr = 0
          chk-doc.pay-desk = pay-desk_
          chk-doc.chk-num = chk-num_
          chk-doc.obj-type = p-obj-type
          chk-doc.obj-code = p-obj-code
          chk-doc.doc-code = string(p-obj-code) + {&slash-char} + id_
          chk-doc.office = ?
          for-chk-type = ""
          prev-code = chk-doc.doc-code
          chk-doc.sales-man = sales-man_
          chk-doc.chk-date = chk-date_
          chk-doc.chk-time = chk-time_
          chk-doc.shift-date = chk-doc.chk-date
          chk-doc.src-shift-date = chk-doc.shift-date
          chk-doc.cash-rate = 1
          chk-doc.cash-scale = 1
          chk-doc.z-number = z-num_
          chk-doc.correct = yes
          chk-doc.d-pcnt = 0
          chk-doc.src-d-pcnt = 0
          chk-doc.shift-num = 0
          chk-doc.shift-name = '':U
          chk-doc.cashier = cashier_
          chk-doc.chk-type = chk-type_
          chk-doc.correct = yes
          chk-doc.src-d-card = (if avail tt-str
                            then tt-str.d-card
                            else "":U)
          chk-doc.PS = (if avail tt-str
                            then tt-str.PS
                            else "":U)
          .
        end.
        IF not AVAILABLE CHK-GDS /*строчек вообще не было*/
          or NOT (chk-gds.doc-code = chk-doc.doc-code  /*новый товар или чек */
                  AND chk-gds.src-code = bc-buf)
          or (chk-gds.doc-code = chk-doc.doc-code /*принудительное разделение на строчки - например золотые кольца*/
              AND chk-gds.src-code = bc-buf
              AND pre-pay-type = cur-pay-type) then do:
          CREATE chk-gds.
          assign
          lng = lng + 1
          chk-gds.doc-code = chk-doc.doc-code
          chk-gds.line-num = lng
          chk-gds.chk-date = chk-doc.chk-date
          pre-pay-type = cur-pay-type
          chk-gds.b-code =  0
          chk-gds.grp-code = 0
          chk-gds.src-code = bc-buf
          chk-gds.is-error = no
          chk-gds.discnt = 0
          chk-gds.time-oper = chk-doc.chk-time
          chk-gds.src-qnty = 0
          chk-gds.doc-qnty = 0
          chk-gds.src-price = price-from-check
          chk-gds.src-discnt = 0
          chk-gds.src-sum = 0
          chk-gds.src-qnty = chk-gds.src-qnty + curr-string-qnty
          chk-gds.pass-gds = 0
          chk-gds.line-sign = (if chk-doc.chk-type = integer({&rcpt-sale})
                              then (chk-gds.src-qnty >= 0)
                              else (chk-gds.src-qnty <= 0)
                              )
          chk-gds.line-type =  "":U
          .
        end.
        else do:
          define variable v-prev-qnty as decimal no-undo .
          assign
          v-prev-qnty = chk-gds.src-qnty
          chk-gds.src-qnty = chk-gds.src-qnty + curr-string-qnty
          .
        end.
        assign
        chk-gds.src-sum = chk-gds.src-sum - (chk-gds.src-discnt * v-prev-qnty) + tot_sum
        chk-gds.src-discnt = (chk-gds.src-price * abs(chk-gds.src-qnty)  -
                      (IF chk-type_ = integer({&rcpt-sale}) then 1 else - 1) * chk-gds.src-sum) / abs(chk-gds.src-qnty)
        .
        if chk-gds.src-discnt <> 0 then do:
          find first chk-discnt where
                    chk-discnt.doc-code = chk-doc.doc-code
                and chk-discnt.line-num = chk-gds.line-num
                and chk-discnt.record-type = 0 no-error.
          if not available chk-discnt then do:
             create chk-discnt.
             assign
             chk-discnt.discnt-id = (var-discnt-id + 1)
             var-discnt-id = var-discnt-id + 1
             .
          end.
          assign
          chk-discnt.doc-code = chk-doc.doc-code
          chk-discnt.record-type = 0
          chk-discnt.line-num = chk-gds.line-num
          chk-discnt.time-oper = chk-doc.chk-time
          chk-discnt.line-type = integer({&discnt-gds})
          chk-discnt.line-sign =  (chk-gds.src-qnty >= 0 ) NE (chk-gds.src-discnt > 0 )
          chk-discnt.pass-discnt = integer({&discnt-p-auto})
          chk-discnt.value-type = integer({&discnt-v-unknown})
          chk-discnt.discnt-type = integer({&discnt-t-unknown})
          chk-discnt.src-d-card = chk-doc.src-d-card
          chk-discnt.discnt-value-abs = chk-gds.src-discnt
          chk-discnt.object-qnty = chk-gds.src-qnty
          chk-discnt.object-sum = chk-gds.src-sum
          chk-gds.src-sum = chk-gds.src-price * chk-gds.src-qnty
          chk-discnt.discnt-value-pcnt = if chk-gds.src-sum <> 0 then
                                          chk-gds.src-discnt * chk-gds.src-qnty / chk-gds.src-sum * 100
                                          else 0
          chk-discnt.object-line-num = chk-gds.line-num
          chk-discnt.pay-desk = chk-doc.pay-desk
          chk-discnt.obj-code = chk-doc.obj-code
          chk-discnt.obj-type = chk-doc.obj-type
          chk-discnt.chk-date = chk-doc.chk-date
          chk-discnt.chk-time = chk-doc.chk-time
          .
        end.
        FIND chk-pay where
              chk-pay.doc-code = chk-doc.doc-code AND
              chk-pay.curr-code = curr_code AND
              chk-pay.pay-code = pay_code      NO-ERROR.
        if NOT available chk-pay then do:
          CREATE chk-pay.
          assign
          lnp = lnp + 1
          chk-pay.doc-code = chk-doc.doc-code
          chk-pay.line-num = lnp
          chk-pay.chk-date = chk-doc.chk-date
          chk-pay.obj-code = p-obj-code
          chk-pay.obj-type = p-obj-type
          chk-pay.pay-code = pay_code
          chk-pay.curr-code = curr_code
          chk-pay.tot-sum = chk-pay.tot-sum + TotSum-Value
          chk-pay.time-oper = chk-doc.chk-time
          chk-pay.line-type = "":U
          chk-pay.line-sign =  (if chk-doc.chk-type = integer({&rcpt-sale})
                                then (chk-pay.tot-sum >= 0)
                                else (chk-pay.tot-sum <= 0)
                                )
          chk-pay.pay-card = "":U
          chk-pay.cash-rate = if curr_code <> 0
                              then TotSum-Value / tot_sum
                              else 1
          chk-pay.bank-rate = 1
          chk-pay.bank-scale = 1
          chk-pay.pass-pay  = 0
          chk-pay.is-error = no
          .
        end. /* if not available chk-pay */
        else do:
          assign
          chk-pay.tot-sum = chk-pay.tot-sum + TotSum-Value
          .
        end.  /*avail chk-pay*/
      end. /*чека в системе нет*/
    end. /*not del*/

  end. /*doe*/

end procedure. /* proc-str */