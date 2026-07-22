block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: get-mari.p $
$Archive: str/get-mari.p $

Программа приема чеков с касс МАРИЯ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/16/06
Author: Bakhtadze Natalya
Creation date: 01/16/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-pos-type like ub.cash-desk.pos-type no-undo .
define input parameter p-cash-num like ub.cash-desk.cash-num no-undo .
DEFINE INPUT PARAMETER file_ as character no-undo.
define input parameter p-close-shift as logical no-undo .
define input parameter p-other as character no-undo .
define input-output parameter p-view-log as logical no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":u .
define variable vss-author      as character no-undo init "$Author: expertek $":u .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: get-mari.p $":u .
define variable vss-archive     as character no-undo init "$Archive: str/get-mari.p $":u .
define variable vss-description as character no-undo init "Программа приема чеков с касс МАРИЯ" .
{ cmp/vssrevis.i }

{ str/get-chk.i }
/*общие для кассовой части и чековой*/

{ str/get-chkc.i def }
/*только чековая часть*/

{ str/tekkatsk.i }
{ ref/cp-attr.i }

DEFINE VARIABLE accept-types               as   character no-undo .
define variable v-flag-card                as   logical   no-undo .
define variable v-end-of-check             as   logical no-undo init yes.
define variable is-cdinv                   as character no-undo .
define variable v-is-petrol-check          as logical no-undo .
define variable prev-z-count               as integer no-undo .
define variable v-hundred as logical no-undo .

define temp-table tt-ss no-undo
field z-count as integer
field chk-num as integer
field jour-no as integer
field rec-no as integer
field is-head as logical
field is-shift as logical
field num-fields as integer
field first-check as logical
field n-entry  as character extent 20
field hundred as logical
index pi is unique primary jour-no rec-no
index ihead is-head
index ichkn chk-num
index ishift is-shift
.
define buffer buf_tt-ss for tt-ss.
/*читаем журанл продаж НП*/
define variable v-petrol-mode              as logical no-undo .
define variable mariapayg as character no-undo .
define variable mariapayp as character no-undo .
define variable v-rec-no as integer no-undo .
define variable v-rec-no2 as integer no-undo .
define variable v-jour-no as integer no-undo .
define variable v-jour-no2 as integer no-undo .
define variable v-rec-no-start-check as integer no-undo .
define variable v-shift-date as date no-undo .
define variable v-first-check-in-jo as logical no-undo init yes.
define variable v-first-journal as logical no-undo .
define variable v-two-files as logical no-undo .
define variable filename2 as character no-undo .

define temp-table temp-cash-desk no-undo
field last-date like ub.chk-doc.chk-date
field last-z-count like ub.chk-doc.z-number
field last-num-recs as decimal
field last-p-date like ub.chk-doc.chk-date
field last-p-z-count like ub.chk-doc.z-number
field last-p-num-recs as integer
field cash-num like ub.cash-desk.cash-num
index pi is unique primary
cash-num.


assign
shop-type = p-obj-type
shop-code = p-obj-code
dflt-cd = p-pos-type
.
{ str/get-chkc.i run }
get-chkc_context.pos-type = p-pos-type.

FUNCTION convert-pay-code returns integer (input p-spool-pay-code as integer
                                          , output p-curr-code as integer
                                             ):
define variable v-cdpay-code like ub.cash-pay.cdpay-code no-undo .
define variable ii as integer no-undo .
define variable v-entry as character no-undo .
p-curr-code = ?.
_do:
do ii = 1 to num-entries(mariapayg, ';'):
  v-entry = entry(ii, mariapayg, ';').
  if v-entry begins substitute("&1/", p-spool-pay-code) then do:
     assign
     v-cdpay-code = integer(entry(1, entry(2, v-entry, {&slash-char})))
     p-curr-code =  integer(entry(2, entry(2, v-entry, {&slash-char})))
     no-error
     .
     leave _do.
  end.
end.
if p-curr-code = ? then
assign
p-curr-code = 0
v-cdpay-code = 0
.
return v-cdpay-code.
END FUNCTION.



FUNCTION convert-pet-pay-code returns integer (input p-spool-pay-code as integer
                                             , input p-emitent-code as integer
                                             , input p-petrol-card as character
                                             , output p-curr-code as integer
                                             ):
define variable v-cdpay-code like ub.cash-pay.cdpay-code no-undo .
define variable ii as integer no-undo .
define variable v-entry as character no-undo .
define buffer buf_cash-pay-attr for ub.cash-pay-attr.
p-curr-code = ?.
if p-petrol-card <> '':U then do:
  p-petrol-card = string(integer(p-petrol-card)).
  for each buf_cash-pay-attr no-lock where
          buf_cash-pay-attr.attr-code = {&cp-attr-paycard-all-prefix}:
    do ii = 1 to num-entries(buf_cash-pay-attr.attr-value):
       if p-petrol-card begins string(decimal(entry(ii, buf_cash-pay-attr.attr-value))) then do:
          assign
          v-cdpay-code = buf_cash-pay-attr.cdpay-code
          p-curr-code = buf_caSH-PAY-ATTR.CURR-CODE
          .
          LEAVE.
       end.
    end.
  end.
end.
else do:
  _do:
  do ii = 1 to num-entries(mariapayp, ';'):
    v-entry = entry(ii, mariapayp, ';').
    if v-entry begins substitute("&1,&2/", p-spool-pay-code, p-emitent-code) then do:
      assign
      v-cdpay-code = integer(entry(1, entry(2, v-entry, {&slash-char})))
      p-curr-code =  integer(entry(2, entry(2, v-entry, {&slash-char})))
      no-error
      .
      leave _do.
    end.
  end.
end.
if p-curr-code = ? then
assign
p-curr-code = 0
v-cdpay-code = 0
.

return v-cdpay-code.
END FUNCTION.


FUNCTION convert-chk-type returns integer( input p-spool-chk-type as character):
define variable v-chk-type like ub.chk-doc.chk-type no-undo .

CASE p-spool-chk-type:
  when '001':U then do:
     v-chk-type = integer({&rcpt-sale}).
  end.
  when '002':U  then do:
     v-chk-type = integer({&rcpt-return}).
  end.
END CASE.
return v-chk-type.
END FUNCTION.


FUNCTION convert-pet-chk-type returns integer( input p-spool-chk-type as character):
define variable v-chk-type like ub.chk-doc.chk-type no-undo .

CASE p-spool-chk-type:
  when '001':U
  or
  when '002':U  then do:
     v-chk-type = integer({&rcpt-sale}).
  end.
  when '003':U then do:
     v-chk-type = integer({&rcpt-return}).
  end.
  when '004':U then do:
     v-chk-type = integer({&rcpt-tech-refuell}).
  end.
  when '005':U then do:
     v-chk-type = integer({&rcpt-overflow}).
  end.
END CASE.
return v-chk-type.
END FUNCTION.

RUN get-mari-c in this-procedure ( input file_ ) no-error .
if error-status:error then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!Ошибка при обработке файла &1: &2"
                            , file_
                            , return-value
                          )
                                          ).
  assign
  p-view-log = yes
  .
  undo, return "error":U.
end.

PROCEDURE get-mari-c.
define input parameter filename as char no-undo.
define variable rr as integer no-undo .
define variable v-l as integer no-undo .
define variable v-check-es as logical no-undo .

define buffer buf_cash-desk for ub.cash-desk.


run gbl/filename.p (
                input filename
               ,output v-full-path
               ,output v-path
               ,output v-file-name
               ,output v-file-name-no-ext
               ,output v-file-name-ext
               ) no-error .
if error-status:error then do:
  assign
  p-view-log = yes
  .
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!При обработке файла &1 произошла ошибка при получении полного пути файлу: &2"
                          , filename
                          , return-value
                        )
                                  ).
  return "error":U.
end.
if index({&object-groups}, string(integer(v-file-name-ext)) + '-') > 0 then do:
  assign
  v-file-name-ext = substring({&object-groups}, index({&object-groups}, string(integer(v-file-name-ext)) + '-'))
  v-file-name-ext = entry(2, v-file-name-ext, '-')
  v-file-name-ext = entry(1, v-file-name-ext)
  .
  filename2 = v-path + {&slash-char} + v-file-name-no-ext + '.' + string(integer(v-file-name-ext), '999').
  if search( filename2) <> ? then do:
     v-two-files = yes.
  end.
end.
run get-mar-parameters in this-procedure ( input v-file-name-ext) no-error.
if error-status:error then do:
  assign
  p-view-log = yes
  .
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!При обработке файла &1 произошла ошибка при получении значений настроечных параметров: &2"
                          , filename
                          , return-value
                        )
                                        ).
  undo, return "error":U.
end.
error-status:error = FALSE.
do rr = 1 to (if v-two-files then 2 else 1):
  if rr = 1 then do:
    input stream ChkStream from value( filename ).
  end.
  if rr = 2 then do:
    input stream ChkStream from value( filename2 ).
  end.
  _repeat:
  REPEAT :
    import stream ChkStream unformatted ss.
    assign
    var-file-line-num = var-file-line-num + 1
    .
    if var-file-line-num modulo 100 = 0 then do:
      run show-counter in p-log-handle .
      run write-counter in p-log-handle ( substitute("Файл &1: предварительно прочитано строк &2", filename, var-file-line-num)).
    end.
    if ss = '':U
    or ss = ? then next _repeat.
    assign
    v-first-check-in-jo = (v-jour-no <> integer(entry(1, ss, {&delim-key})))
    v-jour-no = integer(entry(1, ss, {&delim-key}))
    v-rec-no = integer(entry(2, ss, {&delim-key}))
    ss = entry(3, ss, {&delim-key})
    no-error
    .
    if error-status:error then do:
      {&error-in-file-format}
    end.
    if v-first-check-in-jo then do:
      assign
      v-first-journal = tekka-is-first-journal (v-jour-no)
      .
    end.
    find first tt-ss where
                tt-ss.jour-no = v-jour-no
            and tt-ss.rec-no = v-rec-no no-error .
    if not available tt-ss then do:
      create tt-ss.
      assign
      tt-ss.jour-no = v-jour-no
      tt-ss.rec-no = v-rec-no
      tt-ss.is-head = (rr = 1)
      tt-ss.first-check = (v-first-journal and tt-ss.rec-no = 1)
      .
      if ss begins 'close-shift=' then do:
        tt-ss.is-shift  = yes.
      end.
      if ss begins 'tekka-date-time=' then do:
        run tekka-date-time in this-procedure ( input entry(2, ss, '=':U), input entry(3, ss, '=':U )) no-error .
        delete tt-ss.
        next _repeat.
      end.

      DO ii = 1 to num-entries(ss, {&delim-par}):
        v-check-es = no.
        tt-ss.n-entry[ii] = entry(ii, ss, {&delim-par}) .
        if tt-ss.is-shift = no then do:
          if v-petrol-mode then do:
            if ii = {&petrol-doc-num-field} then do:
              assign
              tt-ss.chk-num = integer(tt-ss.n-entry[ii])
              no-error
              .
              v-check-es = yes.
            end.
            if ii = {&petrol-z-count-field} then do:
              assign
              tt-ss.z-count = integer(tt-ss.n-entry[ii])
              tt-ss.hundred = (if tt-ss.z-count = 0 or tt-ss.z-count = 100 then yes else no)
              tt-ss.z-count = (if tt-ss.hundred then 11 else tt-ss.z-count)
              no-error
              .
              v-check-es = yes.
            end.
          end.
          else do:
            if (rr = 1 and ii = {&goods-doc-doc-num-field} )
            or (rr = 2 and ii = {&goods-doc-num-field} )
            then do:
              assign
              tt-ss.chk-num = integer(tt-ss.n-entry[ii])
              no-error
              .
              v-check-es = yes.
            end.
            if (rr = 1 and ii = {&goods-doc-z-count-field} )
            then do:
              assign
              tt-ss.z-count = integer(tt-ss.n-entry[ii])
              tt-ss.hundred = (if tt-ss.z-count = 0 or tt-ss.z-count = 100 then yes else no)
              tt-ss.z-count = (if tt-ss.hundred then 11 else tt-ss.z-count)
              no-error
              .
              v-check-es = yes.
            end.
          end. /*no petrol*/
          if v-check-es = yes
          and error-status:error then do:
            {&error-in-file-format}
          end.
        end. /*if tt-ss.is-shift = no then do:*/
      END. /*do ii*/
      tt-ss.num-fields = ii - 1.
    end.
  end.
  input stream ChkStream close.
end. /*do rr*/
/*
output to tt.txt append.
for each tt-ss:
  export tt-ss.
end.
output close.
*/

if v-petrol-mode then do:
  _tt-ss1:
  for each tt-ss:
    if tt-ss.is-shift then do:
      run proc-shift in this-procedure ( buffer tt-ss, input tt-ss.num-fields ) no-error .
      next _tt-ss1.
    end.
    else do:
      run proc-petrol-str in this-procedure no-error .
      run proc-end in this-procedure no-error .
    end.
  end.
end.
else do:
  _tt-ss2:
  for each tt-ss where
          tt-ss.is-head = yes:
    if tt-ss.is-shift then do:
      run proc-shift in this-procedure ( buffer tt-ss, input tt-ss.num-fields ) no-error .
    end.
    else do:
      v-l = 0.
      _v-l:
      for  each buf_tt-ss where
           buf_tt-ss.is-head = no
        and buf_tt-ss.chk-num = tt-ss.chk-num:
        assign
        v-jour-no2 = buf_tt-ss.jour-no
        v-rec-no2 = buf_tt-ss.rec-no
        v-l = v-l + 1
        .
        run proc-str in this-procedure ( input (v-l = 1)) no-error .
        if exist then leave _v-l.
      end.
      if not exist then do:
        run proc-end in this-procedure no-error .
      end.
        run process-maria-attr in this-procedure ( input (tekka-num-recs(tt-ss.jour-no, tt-ss.rec-no) +
                                                          tekka-num-recs(v-jour-no2, v-rec-no2) / 10000) ).
    end. /*not shift*/
  end. /*for each tt-ss*/
END . /*not petrol*/

for each temp-cash-desk:
  find first buf_cash-desk no-lock where
            buf_cash-desk.db-num = g#db-num
        AND buf_cash-desk.obj-code = p-obj-code
        AND buf_cash-desk.pos-type = {&cd-type-maria}
        AND buf_cash-desk.cash-num = temp-cash-desk.cash-num no-error .
  if available buf_cash-desk then do:
    run cd-attr-write in this-procedure (
                                           input g#db-num
                                          ,input p-obj-code
                                          ,input {&cd-type-maria}
                                          ,input temp-cash-desk.cash-num
                                          ,input {&cda-maria_operative}
                                          ,input {&cda-maria_operative_last-check-maria}
                                          ,input (cd-attr-CD-DatetoString (temp-cash-desk.last-date)  + {&space-char} +
                                                  string(temp-cash-desk.last-z-count) + {&space-char} +
                                                  string(temp-cash-desk.last-num-recs) + {&space-char} +
                                                  cd-attr-CD-DatetoString (temp-cash-desk.last-p-date)  + {&space-char} +
                                                  string(temp-cash-desk.last-p-z-count) + {&space-char} +
                                                  string(temp-cash-desk.last-p-num-recs) )
                                        ,input ?
                                        ,input 0.0
                                        ,input 0
                                        ,input no
                                                  ) no-error .
    if error-status:error then
    message
    error-status:get-message(1) return-value
    view-as alert-box .
  end.
end.


END PROCEDURE. /*get-mar-c*/

procedure proc-end :

  do
  on error undo, return error
  :
     /*ппроверка всего что только что приняли*/
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
     p-view-log = (p-view-log or get-chkc_context.view-log)
     lll = get-chkc_context.ll
     .
  end.

end procedure. /* proc-end */

procedure proc-str :
define input parameter p-check-start as logical no-undo .

DEFINE VARIABLE pre-pay-type as character no-undo .
DEFINE VARIABLE cur-pay-type as character no-undo .
DEFINE VARIABLE TotSum-Value as decimal no-undo .
define variable v-year as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-clu_ as integer no-undo .
define variable v-discnt-dir as integer no-undo .
define variable pay-type2 as character no-undo .
define variable pay_code2 as integer no-undo .
define variable curr_code2 as integer no-undo .
define variable tot_sum2 as decimal no-undo .
define variable pp as integer no-undo .
define variable discnt-from-check-prim as decimal no-undo .
define variable file_ as character no-undo . /*заглушка для вывода ошибки формата*/
define buffer buf_shift-cash for ub.shift-cash.

do
on error undo, return error return-value
:

  if p-check-start then do:
    assign
    gbl-type = tt-ss.n-entry[3]
    .
    if lookup (gbl-type, accept-types) = 0 then do:
      /*какие-то неизвестные нам виды чеков*/
      assign
      exist = yes
      . /* Предпологаем что уже есть в базе */
      return.
    end.
    assign
    v-is-petrol-check = no
    chk-date_ = 01/01/1990
    chk-time_ = 0
    shift-date_ = chk-date_
    shift-num_ = 0
    shift-name_ = ''
    shop-code = 0
    shop-type = "":U
    sales-man_ = 0
    v-flag-card = no
    cashier_ = 0
    pay-desk_ = 0
    z-num_ = 0
    cash-rate_ = 0
    d-card_ = "":U
    d-mask_ = "":U
    cli-type_ = "":U
    cli-code_ = 0
    tot-d-pcnt = 0
    doc-num_ = "":U
    v-end-of-check = no
    exist = no
    .
    run cur-time in this-procedure ( output v-today, output v-time).
    assign
    v-year    = (if int( substr( tt-ss.n-entry[6 + {&pay-type-2} ], 1, 3 ) ) = month(v-today)
                  then year(v-today)
                  else year(v-today) - 1)
    chk-date_ = date(
                        int( substr( tt-ss.n-entry[6 + {&pay-type-2} ], 1, 3 ) ),
                        int( substr( tt-ss.n-entry[6 + {&pay-type-2} ], 4, 2 ) ),
                        int( v-year)
                        )
    chk-time_ =  int( substr( tt-ss.n-entry[5 + {&pay-type-2} ], 1, 3 ) ) * 3600 +
                 int( substr( tt-ss.n-entry[5 + {&pay-type-2} ], 4, 2 ) ) * 60
    shop-code = p-obj-code
    shop-type = p-obj-type
    chk-num_ = tt-ss.chk-num
    sales-man_ = 0
    cashier_ = integer( tt-ss.n-entry[2] )
    pay-desk_ = p-cash-num
    z-num_ =  tt-ss.z-count
    cash-rate_ = 1
    d-card_   = '':U
    v-clu_ = 0
    cli-type_ =  '':U
    cli-code_ = 0
    shift-num_ =  z-num_
    shift-name_ = string(shift-num_)
    shift-num_ = if get-chkc_context.shift-on then 0 else shift-num_
    doc-num_ = '':U
    chk-type_ = convert-chk-type(gbl-type)
    pay-type = substring(tt-ss.n-entry[4], 1, 3)
    pay_code = convert-pay-code(input integer(pay-type), output curr_code)
    pay-type2 = (if {&pay-type-2} = 1
                 then tt-ss.n-entry[5]
                 else substring(tt-ss.n-entry[4], 4, 3))
    pay_code2 = (if pay-type2 <> '000':U
                then convert-pay-code(input integer(pay-type2), output curr_code2)
                else 0)
    tot_sum  = integer(tt-ss.n-entry[8 + {&pay-type-2}]) / 100
    tot_sum2  = integer(tt-ss.n-entry[9 + {&pay-type-2}]) / 100
    pay-card_ = tt-ss.n-entry[10 + {&pay-type-2}] + tt-ss.n-entry[11 + {&pay-type-2}]
    no-error .
    .
    if error-status:error then do:
      var-file-line-num = tt-ss.rec-no.
      {&error-in-file-format}
    end.
    if tt-ss.first-check then do:
      v-shift-date = chk-date_.
    end.
    else do:
      if tt-ss.z-count <> prev-z-count then do:
        find first buf_shift-cash  no-lock where
                  buf_shift-cash.obj-type = p-obj-type
              and buf_shift-cash.obj-code = p-obj-code
              and buf_shift-cash.cash-num = p-cash-num
              and buf_shift-cash.shift-date >= (chk-date_ - 1)
              and buf_shift-cash.z-num = (if tt-ss.hundred then 100 else tt-ss.z-count) no-error.
        if available buf_shift-cash then do:
          v-shift-date = buf_shift-cash.shift-date.
        end.
        else do:
          run write-log-and-file in p-log-handle (
                  input 1
                , input log-file-name
                , input 1
                , input substitute( "!!!Ошибка при обработке данных с кассы &1: Невозможно получить дату смены с № &2"
                                    , p-cash-num
                                    , tt-ss.z-count
                                  )
                                                  ).
          assign
          p-view-log = yes
          .
        end.
      end.
      prev-z-count = tt-ss.z-count.
    end.
    assign
    shift-date_ = if cas-shft
                  then v-shift-date
                  else chk-date_
    .

    /*инициируем переменные для приема товарных чеков*/
    assign
    for-chk-type = ""
    exist = yes  /* Предполагаем что уже есть в базе */
    .
    FIND  ub.chk-doc where
          ub.chk-doc.obj-type = shop-type and
          ub.chk-doc.obj-code = shop-code and
          ub.chk-doc.chk-date = chk-date_ and
          ub.chk-doc.pay-desk = pay-desk_ and
          ub.chk-doc.chk-time = chk-time_ and
          ub.chk-doc.chk-num = chk-num_ and
          ub.chk-doc.sales-man = sales-man_ NO-ERROR NO-WAIT.
    IF (NOT AVAIL ub.chk-doc AND NOT LOCKED ub.chk-doc  AND NOT AMBIGUOUS ub.chk-doc)
    /*чека в системе нет*/
    then do:
      CREATE ub.chk-doc.
      assign
      lll = lll + 1
      exist = no
      lng = 0
      lnp = 0
      cr = 0
      sub-d = 0
      var-discnt-id = 0
      lng-sub-d = 0
      netto-for-sub-d = 0
      v-rec-no-start-check = v-rec-no
      ub.chk-doc.pay-desk = p-cash-num
      ub.chk-doc.chk-num = chk-num_
      ub.chk-doc.obj-type = p-obj-type
      ub.chk-doc.obj-code = p-obj-code
      ub.chk-doc.doc-code = (if get-chkc_context.db-num = 0
                          then string(next-value(s-chk, {&db-name_schema}))
                          else string( shop-code ) + {&slash-char} + string( next-value( s-chk, {&db-name_schema} ) ))
      ub.chk-doc.office = ?
      for-chk-type = ""
      prev-code = ub.chk-doc.doc-code
      ub.chk-doc.sales-man = sales-man_
      ub.chk-doc.chk-date = chk-date_
      ub.chk-doc.chk-time = chk-time_
      ub.chk-doc.shift-date = ub.chk-doc.chk-date
      ub.chk-doc.src-shift-date = ub.chk-doc.shift-date
      ub.chk-doc.cash-rate = 1
      ub.chk-doc.cash-scale = 1
      ub.chk-doc.z-number = z-num_
      ub.chk-doc.correct = yes
      ub.chk-doc.d-pcnt = 0
      ub.chk-doc.src-d-pcnt = 0
      ub.chk-doc.shift-num = (if cas-shft then shift-num_ else 0)
      ub.chk-doc.cashier = cashier_
      ub.chk-doc.chk-type = chk-type_
      ub.chk-doc.correct = yes
      ub.CHK-DOC.discnt = 0
      ub.chk-doc.src-d-card =  d-card_
      ub.chk-doc.src-d-pcnt = 0
      ub.chk-doc.src-shift-date = (if cas-shft then shift-date_ else chk-date_)
      ub.chk-doc.cash-rate = 1
      ub.chk-doc.cash-scale = 1
      ub.chk-doc.z-number = z-num_
      ub.chk-doc.doc-num = doc-num_ + (if shift-name_ <> '':U
                                      then ({&delim-par} + shift-name_)
                                      else '':U)
      ub.chk-doc.correct = yes
      .
    end.
    else do:
      assign
      exist = yes
      . /* Предпологаем что уже есть в базе */
      return.
    end.
  end. /*if p-check-start*/
  assign
  v-discnt-dir = (if substring(buf_tt-ss.n-entry[1], 1, 3) = '001' then 1 else - 1)
  bc-buf = left-trim(buf_tt-ss.n-entry[4], '0')
  curr-string-qnty = integer(buf_tt-ss.n-entry[5]) / 10000 * (if chk-type_ = integer({&rcpt-return}) then -1 else 1)
  Sum-from-check = integer(buf_tt-ss.n-entry[7]) / 100  * (if chk-type_ = integer({&rcpt-return}) then -1 else 1)
  price-from-check =  abs(sum-from-check / curr-string-qnty)
  discnt-from-check = integer(buf_tt-ss.n-entry[6]) / 100 * (if chk-type_ = integer({&rcpt-return}) then -1 else 1) * v-discnt-dir
  discnt-from-check-prim = discnt-from-check / abs(curr-string-qnty) * (if chk-doc.chk-type = integer({&rcpt-return})
                                                                        then - 1
                                                                        else 1)
  no-error .
  if error-status:error then do:
     var-file-line-num = buf_tt-ss.rec-no.
     file_ = filename2.
    {&error-in-file-format}
  end.
  IF not AVAILABLE ub.CHK-GDS /*строчек вообще не было*/
    or NOT (ub.chk-gds.doc-code = ub.chk-doc.doc-code  /*новый товар или чек */
            AND ub.chk-gds.src-code = bc-buf)
    or NOT (ub.chk-gds.doc-code = ub.chk-doc.doc-code /*принудительное разделение на строчки - например золотые кольца*/
        AND ub.chk-gds.src-code = bc-buf
        AND pre-pay-type = cur-pay-type
        AND round(ub.chk-gds.src-discnt, 2) = round(discnt-from-check / curr-string-qnty, 2)
        )
    or not (ub.chk-gds.doc-code = ub.chk-doc.doc-code
            and ub.chk-gds.line-num = tt-ss.rec-no - v-rec-no-start-check + 1)
    or not ub.chk-gds.src-price = price-from-check
      then do:
    CREATE ub.chk-gds.
    assign
    lng = lng + 1
    ub.chk-gds.doc-code = chk-doc.doc-code
    ub.chk-gds.line-num = lng
    ub.chk-gds.chk-date = chk-doc.chk-date
    pre-pay-type = cur-pay-type
    ub.chk-gds.b-code =  0
    ub.chk-gds.grp-code = 0
    ub.chk-gds.src-code = bc-buf
    ub.chk-gds.is-error = no
    ub.chk-gds.discnt = 0
    ub.chk-gds.time-oper = chk-doc.chk-time
    ub.chk-gds.src-qnty = 0
    ub.chk-gds.doc-qnty = 0
    ub.chk-gds.src-price = price-from-check
    ub.chk-gds.src-sum = 0
    ub.chk-gds.src-qnty = curr-string-qnty
    ub.chk-gds.src-discnt = discnt-from-check-prim
    ub.chk-gds.pass-gds = 0
    ub.chk-gds.line-sign = (if ub.chk-doc.chk-type = integer({&rcpt-sale})
                        then (ub.chk-gds.src-qnty >= 0)
                        else (ub.chk-gds.src-qnty <= 0)
                        )
    ub.chk-gds.line-type =  "":U
    .
  end.
  else do:
    assign
    ub.chk-gds.src-discnt = (ub.chk-gds.src-discnt * abs(ub.chk-gds.src-qnty) + discnt-from-check-prim * abs(curr-string-qnty)) / abs( chk-gds.src-qnty + curr-string-qnty)
    ub.chk-gds.src-qnty = ub.chk-gds.src-qnty + curr-string-qnty
    .
  end.
  assign
  ub.chk-gds.src-sum = ub.chk-gds.src-sum + sum-from-check
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
    ub.chk-discnt.line-sign =  (ub.chk-gds.src-qnty >= 0 ) NE (ub.chk-gds.src-discnt > 0 )
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
  if p-check-start then do:
    do pp = 1 to (if pay_code2 > 0 then 2 else 1):
      if pp = 2 then do:
        assign
        pay_code = pay_code2
        curr_code = curr_code2
        tot_sum = tot_sum2
        .
      end.
      FIND ub.chk-pay where
              ub.chk-pay.doc-code = ub.chk-doc.doc-code AND
              ub.chk-pay.curr-code = curr_code AND
              ub.chk-pay.pay-code = pay_code      NO-ERROR.
      if NOT available ub.chk-pay then do:
        CREATE ub.chk-pay.
        assign
        lnp = lnp + 1
        ub.chk-pay.doc-code = ub.chk-doc.doc-code
        ub.chk-pay.line-num = lnp
        ub.chk-pay.chk-date = ub.chk-doc.chk-date
        ub.chk-pay.obj-code = p-obj-code
        ub.chk-pay.obj-type = p-obj-type
        ub.chk-pay.pay-code = pay_code
        ub.chk-pay.pay-card = pay-card_
        ub.chk-pay.curr-code = curr_code
        ub.chk-pay.tot-sum = ub.chk-pay.tot-sum + tot_sum * (if chk-type_ = integer({&rcpt-return}) then -1 else 1)
        ub.chk-pay.time-oper = ub.chk-doc.chk-time
        ub.chk-pay.line-type = "":U
        ub.chk-pay.line-sign =  (if ub.chk-doc.chk-type = integer({&rcpt-sale})
                              then (ub.chk-pay.tot-sum >= 0)
                              else (ub.chk-pay.tot-sum <= 0)
                              )
        ub.chk-pay.cash-rate = 1
        ub.chk-pay.bank-rate = 1
        ub.chk-pay.bank-scale = 1
        ub.chk-pay.pass-pay  = 0
        ub.chk-pay.is-error = no
        .
      end. /* if not available chk-pay */
      else do:
        assign
        ub.chk-pay.tot-sum = ub.chk-pay.tot-sum + tot_sum * (if chk-type_ = integer({&rcpt-return}) then -1 else 1)
        .
      end.  /*avail chk-pay*/
    end. /*do pp*/
  end. /*if p-check-start*/
end. /*doe*/
end procedure. /* proc-str */



procedure proc-petrol-str :

DEFINE VARIABLE pre-pay-type as character no-undo .
DEFINE VARIABLE cur-pay-type as character no-undo .
DEFINE VARIABLE TotSum-Value as decimal no-undo .
define variable v-year as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-clu_ as integer no-undo .
define variable v-discnt-dir as integer no-undo .
define variable bc-buf-int as integer no-undo .
define variable v-emitent as integer no-undo .
define variable discnt-from-check-prim as decimal no-undo .
define variable v-petrol-plus as logical no-undo .
define variable v-forma-opl as integer no-undo .

define buffer buf_cd-plu for ub.cd-plu.
define buffer buf_cd-clu for ub.cd-clu.
define buffer buf_shift-cash for ub.shift-cash.


do
on error undo, return error
:

  assign
  gbl-type = substring(tt-ss.n-entry[1], 7, 3)
  .
  if can-do(accept-types,  gbl-type ) then do:
    assign
    v-is-petrol-check = no
    chk-date_ = 01/01/1990
    chk-time_ = 0
    shift-date_ = chk-date_
    shift-num_ = 0
    shift-name_ = ''
    shop-code = 0
    shop-type = "":U
    sales-man_ = 0
    v-flag-card = no
    cashier_ = 0
    pay-desk_ = 0
    z-num_ = 0
    cash-rate_ = 0
    d-card_ = "":U
    d-mask_ = "":U
    cli-type_ = "":U
    cli-code_ = 0
    tot-d-pcnt = 0
    doc-num_ = "":U
    v-end-of-check = no
    exist = no
    .
    run cur-time in this-procedure ( output v-today, output v-time).
    assign
    v-discnt-dir = (if substring(tt-ss.n-entry[1], 1, 3) = '001' then 1 else - 1)
    chk-type_ = convert-pet-chk-type(gbl-type)
    v-year    = (if int( substr( tt-ss.n-entry[8], 1, 3 ) ) = month(v-today)
                  then year(v-today)
                  else year(v-today) - 1)
    chk-date_ = date(
                        int( substr( tt-ss.n-entry[8], 1, 3 ) ),
                        int( substr( tt-ss.n-entry[8], 4, 2 ) ),
                        int( v-year)
                        )
    chk-time_ =  int( substr( tt-ss.n-entry[7], 1, 3 ) ) * 3600 + int( substr( tt-ss.n-entry[7], 4, 2 ) ) * 60
    shift-date_ = if get-chkc_context.cas-shft
                  then v-shift-date
                  else chk-date_
    shop-code = p-obj-code
    shop-type = p-obj-type
    chk-num_ = tt-ss.chk-num
    sales-man_ = 0
    cashier_ = integer( trim( tt-ss.n-entry[6] ) )
    pay-desk_ = p-cash-num
    z-num_ =  tt-ss.z-count
    cash-rate_ = 1
    pay-card_   = tt-ss.n-entry[15] + tt-ss.n-entry[16]
    pay-card_ = (if trim(pay-card_, '0') = '':U then '':U else pay-card_)
    v-forma-opl = integer(substring(tt-ss.n-entry[2], 3))
    v-petrol-plus = if ((v-forma-opl = 0 or v-forma-opl = 1)
                    AND
                    integer(substring(tt-ss.n-entry[3], 4, 3)) = 20
                    and
                    (integer(substring(tt-ss.n-entry[1], 4, 3)) = 1 or integer(substring(tt-ss.n-entry[1], 4, 3)) = 2)
                    )
                    then yes
                    else no
    v-clu_ = (if v-forma-opl <> 255
              and not v-petrol-plus
              then (v-forma-opl + 1)
              else 0)
    shift-num_ =  z-num_
    shift-name_ = string(shift-num_)
    shift-num_ = if get-chkc_context.shift-on then 0 else shift-num_
    doc-num_ = tt-ss.n-entry[10]
    bc-buf = substring(tt-ss.n-entry[3], 1, 3)
    bc-buf-int = integer(bc-buf)
    price-from-check =  integer( tt-ss.n-entry[12]) / 100
    curr-string-qnty = integer(tt-ss.n-entry[11]) / 100 * (if chk-type_ = integer({&rcpt-return}) then -1 else 1)
    Sum-from-check = integer(tt-ss.n-entry[14]) / 100 * (if chk-type_ = integer({&rcpt-return}) then -1 else 1)
    discnt-from-check     = integer(tt-ss.n-entry[13]) / 100 * (if chk-type_ = integer({&rcpt-return}) then -1 else 1) * v-discnt-dir
    discnt-from-check-prim =  discnt-from-check / abs(curr-string-qnty) * (if chk-type_ = integer({&rcpt-return})
                                                                            then - 1
                                                                            else 1)
    pay-type = substring(tt-ss.n-entry[1], 4, 3)
    v-emitent = integer(substring(tt-ss.n-entry[3], 4, 3))
        v-emitent = (if v-emitent = 31 then 0 else v-emitent)
    pay_code = (if chk-type_ = integer({&rcpt-tech-refuell})
                or chk-type_ = integer({&rcpt-overflow})
                then 0
                else convert-pet-pay-code(input integer(pay-type)
                                  , input v-emitent
                                  , input (if v-petrol-plus then pay-card_ else '':U)
                                  , output curr_code))
    pump_ = integer(substring(tt-ss.n-entry[4], 1, 3)) + 1
    nozzle_ = integer(substring(tt-ss.n-entry[4], 4, 3)) + 1

    no-error .
    if error-status:error then do:
      var-file-line-num = tt-ss.rec-no.
      {&error-in-file-format}
    end.
    if tt-ss.first-check then do:
      v-shift-date = chk-date_.
    end.
    else do:
      if tt-ss.z-count <> prev-z-count then do:
        find first buf_shift-cash  no-lock where
                  buf_shift-cash.obj-type = p-obj-type
              and buf_shift-cash.obj-code = p-obj-code
              and buf_shift-cash.cash-num = p-cash-num
              and buf_shift-cash.shift-date >= (chk-date_ - 1)
              and buf_shift-cash.z-num = (if tt-ss.hundred then 100 else tt-ss.z-count) no-error.
        if available buf_shift-cash then do:
          v-shift-date = buf_shift-cash.shift-date.
        end.
        else do:
          run write-log-and-file in p-log-handle (
                  input 1
                , input log-file-name
                , input 1
                , input substitute( "!!!Ошибка при обработке данных с кассы &1: Невозможно получить дату смены с № &2"
                                    , p-cash-num
                                    , tt-ss.z-count
                                  )
                                                  ).
          assign
          p-view-log = yes
          .
        end.
      end.
      prev-z-count = tt-ss.z-count.
    end.
    assign
    shift-date_ = if cas-shft
                  then v-shift-date
                  else chk-date_
    .

    find first buf_cd-plu no-lock where
           buf_cd-plu.obj-type = p-obj-type
       and buf_cd-plu.obj-code = p-obj-code
       and buf_cd-plu.pos-type = {&cd-type-maria}
       and buf_cd-plu.plu-type = {&petrolium}
       and buf_cd-plu.plu-code = (bc-buf-int + 1)  no-error .

    if not available buf_cd-plu then do:
      assign
      bc-buf = {&delim-par} + bc-buf.
    end.
    else do:
      assign
      bc-buf = string(buf_cd-plu.b-str) + {&delim-par} + string(bc-buf-int + 1, {&cd-goods-code-format}).
    end.
    if v-clu_ <> 0 then do:
      find first buf_cd-clu no-lock where
               buf_cd-clu.obj-type = p-obj-type
           and buf_cd-clu.obj-code = p-obj-code
           and buf_cd-clu.pos-type = {&cd-type-maria}
           and buf_cd-clu.clu-type = '':U
           and buf_cd-clu.clu-code = v-clu_
      no-error .
      if not available buf_cd-clu then do:
        assign
        cli-type_ = '':U
        cli-code_ = 0
        .
      end.
      else do:
&scoped-define dct-client-obj-type cli-type_
&scoped-define dct-client-obj-code cli-code_
        assign
        cli-type_ = buf_cd-clu.cli-type
        cli-code_ = buf_cd-clu.cli-code
        d-card_   =  {&dct-client-card-no}
        .
      end.
    end.
  end. /**/
  else do:
    /*какие-то неизвестные нам виды чеков*/
    assign
    exist = yes
    . /* Предпологаем что уже есть в базе */
    return.
  end.
  if can-do( accept-types , gbl-type ) then do:
    /*инициируем переменные для приема товарных чеков*/
    assign
    for-chk-type = ""
    exist = yes  /* Предполагаем что уже есть в базе */
    .
    FIND  ub.chk-doc where
          ub.chk-doc.obj-type = shop-type and
          ub.chk-doc.obj-code = shop-code and
          ub.chk-doc.chk-date = chk-date_ and
          ub.chk-doc.pay-desk = pay-desk_ and
          ub.chk-doc.chk-time = chk-time_ and
          ub.chk-doc.chk-num = chk-num_ and
          ub.chk-doc.sales-man = sales-man_ NO-ERROR NO-WAIT.
    IF (NOT AVAIL ub.chk-doc AND NOT LOCKED ub.chk-doc  AND NOT AMBIGUOUS ub.chk-doc)
    /*чека в системе нет*/
    then do:
        run proc-end in this-procedure .
        CREATE ub.chk-doc.
        assign
        lll = lll + 1
        exist = no
        lng = 0
        lnp = 0
        cr = 0
        sub-d = 0
        var-discnt-id = 0
        lng-sub-d = 0
        netto-for-sub-d = 0
        v-rec-no-start-check = v-rec-no
        ub.chk-doc.pay-desk = pay-desk_
        ub.chk-doc.chk-num = chk-num_
        ub.chk-doc.obj-type = p-obj-type
        ub.chk-doc.obj-code = p-obj-code
        ub.chk-doc.doc-code = (if get-chkc_context.db-num = 0
                            then string(next-value(s-chk, {&db-name_schema}))
                            else string( shop-code ) + {&slash-char} + string( next-value( s-chk, {&db-name_schema} ) ))
        ub.chk-doc.office = ?
        for-chk-type = ""
        prev-code = ub.chk-doc.doc-code
        ub.chk-doc.sales-man = sales-man_
        ub.chk-doc.chk-date = chk-date_
        ub.chk-doc.chk-time = chk-time_
        ub.chk-doc.shift-date = ub.chk-doc.chk-date
        ub.chk-doc.src-shift-date = ub.chk-doc.shift-date
        ub.chk-doc.cash-rate = 1
        ub.chk-doc.cash-scale = 1
        ub.chk-doc.z-number = z-num_
        ub.chk-doc.correct = yes
        ub.chk-doc.d-pcnt = 0
        ub.chk-doc.src-d-pcnt = 0
        ub.chk-doc.shift-num = (if cas-shft then shift-num_ else 0)
        ub.chk-doc.cashier = cashier_
        ub.chk-doc.chk-type = chk-type_
        ub.chk-doc.correct = yes
        ub.CHK-DOC.discnt = 0
        ub.chk-doc.src-d-card =  d-card_
        ub.chk-doc.src-d-pcnt = - tot-d-pcnt
        ub.chk-doc.src-shift-date = (if cas-shft then shift-date_ else chk-date_)
        ub.chk-doc.cash-rate = 1
        ub.chk-doc.cash-scale = 1
        ub.chk-doc.z-number = z-num_
        ub.chk-doc.doc-num = doc-num_ + (if shift-name_ <> '':U
                                        then ({&delim-par} + shift-name_)
                                        else '':U)
        v-is-petrol-check = lookup(string(ub.chk-doc.chk-type) , {&petrol-receipt-codes}) > 0
        ub.chk-doc.correct = yes
        .
      end.
      else do:
        assign
        exist = yes
        . /* Предпологаем что уже есть в базе */
        return.
      end.
      IF not AVAILABLE ub.CHK-GDS /*строчек вообще не было*/
        or NOT (ub.chk-gds.doc-code = ub.chk-doc.doc-code  /*новый товар или чек */
                AND ub.chk-gds.src-code = bc-buf)
        or NOT (ub.chk-gds.doc-code = ub.chk-doc.doc-code /*принудительное разделение на строчки - например золотые кольца*/
            AND ub.chk-gds.src-code = bc-buf
            AND pre-pay-type = cur-pay-type
            AND ub.chk-gds.pump = pump_ + 1000 * nozzle_
            )
            then do:
        CREATE ub.chk-gds.
        assign
        lng = lng + 1
        ub.chk-gds.doc-code = ub.chk-doc.doc-code
        ub.chk-gds.line-num = lng
        ub.chk-gds.chk-date = ub.chk-doc.chk-date
        pre-pay-type = cur-pay-type
        ub.chk-gds.b-code =  0
        ub.chk-gds.grp-code = 0
        ub.chk-gds.src-code = bc-buf
        ub.chk-gds.is-error = no
        ub.chk-gds.discnt = 0
        ub.chk-gds.time-oper = ub.chk-doc.chk-time
        ub.chk-gds.src-qnty = 0
        ub.chk-gds.doc-qnty = 0
        ub.chk-gds.src-price = price-from-check
        ub.chk-gds.src-sum = 0
        ub.chk-gds.src-qnty = curr-string-qnty
        ub.chk-gds.src-discnt = discnt-from-check-prim
        ub.chk-gds.pass-gds = 0
        ub.chk-gds.line-sign = (if ub.chk-doc.chk-type = integer({&rcpt-sale})
                            then (ub.chk-gds.src-qnty >= 0)
                            else (ub.chk-gds.src-qnty <= 0)
                            )
        ub.chk-gds.line-type =  "":U
        ub.chk-gds.pump = pump_ + 1000 * nozzle_
        .
      end.
      else do:
        assign
        ub.chk-gds.src-discnt = (ub.chk-gds.src-discnt * abs(ub.chk-gds.src-qnty) + discnt-from-check-prim * abs(curr-string-qnty)) / abs( chk-gds.src-qnty + curr-string-qnty)
        ub.chk-gds.src-qnty = ub.chk-gds.src-qnty + curr-string-qnty
        .
      end.
      assign
      ub.chk-gds.src-sum = ub.chk-gds.src-sum + sum-from-check
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
        ub.chk-discnt.object-line-num = chk-gds.line-num
        ub.chk-discnt.pay-desk = ub.chk-doc.pay-desk
        ub.chk-discnt.obj-code = ub.chk-doc.obj-code
        ub.chk-discnt.obj-type = ub.chk-doc.obj-type
        ub.chk-discnt.chk-date = ub.chk-doc.chk-date
        ub.chk-discnt.chk-time = ub.chk-doc.chk-time
        var-discnt-id = var-discnt-id + 1
        .
      end.
      if not (chk-type_ = integer({&rcpt-tech-refuell})
             or chk-type_ = integer({&rcpt-overflow})) then do:
        FIND ub.chk-pay where
              ub.chk-pay.doc-code = ub.chk-doc.doc-code AND
              ub.chk-pay.curr-code = curr_code AND
              ub.chk-pay.pay-code = pay_code      NO-ERROR.
        if NOT available ub.chk-pay
        or ub.chk-pay.pay-card <> pay-card_
        then do:
          CREATE ub.chk-pay.
          assign
          lnp = lnp + 1
          ub.chk-pay.doc-code = ub.chk-doc.doc-code
          ub.chk-pay.line-num = lnp
          ub.chk-pay.chk-date = ub.chk-doc.chk-date
          ub.chk-pay.obj-code = p-obj-code
          ub.chk-pay.obj-type = p-obj-type
          ub.chk-pay.pay-code = pay_code
          ub.chk-pay.curr-code = curr_code
          ub.chk-pay.tot-sum = ub.chk-pay.tot-sum + sum-from-check - discnt-from-check
          ub.chk-pay.time-oper = ub.chk-doc.chk-time
          ub.chk-pay.line-type = "":U
          ub.chk-pay.line-sign =  (if ub.chk-doc.chk-type = integer({&rcpt-sale})
                                then (ub.chk-pay.tot-sum >= 0)
                                else (ub.chk-pay.tot-sum <= 0)
                                )
          ub.chk-pay.pay-card = pay-card_
          ub.chk-pay.cash-rate = 1
          ub.chk-pay.bank-rate = 1
          ub.chk-pay.bank-scale = 1
          ub.chk-pay.pass-pay  = 0
          ub.chk-pay.is-error = no
          .
        end. /* if not available chk-pay */
        else do:
          assign
          ub.chk-pay.tot-sum = ub.chk-pay.tot-sum + sum-from-check - discnt-from-check
          .
        end.  /*avail chk-pay*/
      end.
    end. /*чека в системе нет*/
end. /*doe*/
end procedure. /* proc-petrol-str */

PROCEDURE get-mar-parameters:
define input parameter p-read-object as character no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .

if get-chkc_context.shift-on and not get-chkc_context.cas-shft then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("!!!Внимание! На объекте &1&2 требуется использование смен, а настройка СМЕНЫ НА КАССЕ выключена - это недопустимо."
                         , get-chkc_context.obj-type
                         , get-chkc_context.obj-code
                          )).
  assign
  p-view-log = yes
  .
  undo, return "error":U.
end.

if get-chkc_context.t-shft > 0 and get-chkc_context.shift-on = yes then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("!!!Внимание! На объекте &1&2 требуется использование смен,&3" +
                          "а настройка СМЕЩЕННЫЕ СМЕНЫ НА КАССЕ&3" +
                          "(АРМ Администратор - Справочники - Магазины - Параметры - время начала пересменки)&3" +
                          "включена - это недопустимо."
                         , get-chkc_context.obj-type
                         , get-chkc_context.obj-code
                         , {&new-line}
                          )).
  assign
  p-view-log = yes
  .
  undo, return "error":U.
end.

{ gbl/conf-rd.i
 "'is-ptrl'"
 0
 "''":U
 0
 "''":U
 "''":U
 "''":U
 NO
 conf-par
 par-type
 NO-ERROR
 }
assign
is-ptrl = logical(conf-par) no-error .


if is-wth = yes then do:
  /*пока не читаем*/
  /*accept-types =  "":U.*/
end.
if LOOKUP(left-trim(p-read-object, '0'), '26,27,28,29,30,31,32,33') > 0 then do:
  /*читаем топливо*/
  accept-types =  "001,002,003":U.
  if is-ptrl
  and ptrl-check then
  assign
  accept-types = accept-types + ",004,005":U.
  assign
  v-petrol-mode = yes.
end.
if LOOKUP(left-trim(p-read-object, '0'), '42,43') > 0 then do:
  /*читаем товары*/
  accept-types =  "001,002,003":U.
end.

/*получим настройки перекодировки оплат*/
run adm/shattri.p (
      input "get":U
      ,input  {&shop}
      ,input  p-obj-code
      ,input  {&attr-cd-type-maria}
      ,input  {&attr-cd-type-maria_mariapayg} /*p-param-code*/
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
IF not error-status:error then do:
  mariapayg = v-value-character.
  delete object v-tth.
end.
else do:
  delete object v-tth.
  return error return-value .
end.
run adm/shattri.p (
      input "get":U
      ,input  {&shop}
      ,input  p-obj-code
      ,input  {&attr-cd-type-maria}
      ,input  {&attr-cd-type-maria_mariapayp} /*p-param-code*/
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
IF not error-status:error then do:
  mariapayp = v-value-character.
  delete object v-tth.
end.
else do:
  delete object v-tth.
  return error return-value .
end.
END PROCEDURE. /*get-mar-parameters*/

procedure process-maria-attr :
define input parameter p-num-recs as decimal no-undo .
define variable v-last-date as date no-undo .
define variable v-last-z-count as integer no-undo .
define variable v-last-num-recs as integer no-undo .
define variable v-p-last-date as date no-undo .
define variable v-p-last-z-count as integer no-undo .
define variable v-p-last-num-recs as integer no-undo .
define variable v-old as character no-undo .
define variable v-new as character no-undo .
define variable v-new-rel-z-count as integer no-undo .
define variable v-old-rel-z-count as integer no-undo .

  do
  on error undo, return error
  :

  find first temp-cash-desk where
           temp-cash-desk.cash-num = pay-desk_ no-error.
  if not available temp-cash-desk then do:

    run get-last-check-maria in this-procedure (
                                                            input g#db-num
                                                            ,input p-obj-code
                                                            ,input pay-desk_
                                                            ,output v-last-date
                                                            ,output v-last-z-count
                                                            ,output v-last-num-recs
                                                            ,output v-p-last-date
                                                            ,output v-p-last-z-count
                                                            ,output v-p-last-num-recs
                                                            ) no-error.

    create temp-cash-desk.
    assign
    temp-cash-desk.cash-num = pay-desk_
    temp-cash-desk.last-date = v-last-date
    temp-cash-desk.last-z-count = v-last-z-count
    temp-cash-desk.last-num-recs = v-last-num-recs
    temp-cash-desk.last-p-date = v-p-last-date
    temp-cash-desk.last-p-z-count = v-p-last-z-count
    temp-cash-desk.last-p-num-recs = v-p-last-num-recs
    .
  end.
  /*сотворим составную переменную*/
  assign
  v-old = string(year(temp-cash-desk.last-date), "9999") +
          string(month(temp-cash-desk.last-date), "99") +
          string(day(temp-cash-desk.last-date), "99") +
          string(temp-cash-desk.last-z-count, "99999") +
          string(temp-cash-desk.last-num-recs, "9999.9999") +
          string(year(temp-cash-desk.last-p-date), "9999") +
          string(month(temp-cash-desk.last-p-date), "99") +
          string(day(temp-cash-desk.last-p-date), "99") +
          string(temp-cash-desk.last-p-z-count, "99999") +
          string(temp-cash-desk.last-p-num-recs, "9999")
  .
  if v-petrol-mode then do:
    assign
    v-new = string(year(temp-cash-desk.last-date), "9999") +
            string(month(temp-cash-desk.last-date), "99") +
            string(day(temp-cash-desk.last-date), "99") +
            string(temp-cash-desk.last-z-count, "99999") +
            string(temp-cash-desk.last-num-recs, "9999.9999") +
            (if chk-date_ <> 01/01/1990 then
            (string(year(chk-date_), "9999") +
            string(month(chk-date_), "99") +
            string(day(chk-date_), "99"))
            else
            (string(year(temp-cash-desk.last-p-date), "9999") +
            string(month(temp-cash-desk.last-p-date), "99") +
            string(day(temp-cash-desk.last-p-date), "99")))  +
            string((if v-hundred and z-num_ = 11 then 100 else  z-num_), "99999") +
            string(p-num-recs, "9999")
    .
  end.
  else do:
    assign
    v-new = (if chk-date_ <> 01/01/1990 then
            (string(year(chk-date_), "9999") +
            string(month(chk-date_), "99") +
            string(day(chk-date_), "99"))
            else
            (string(year(temp-cash-desk.last-date), "9999") +
            string(month(temp-cash-desk.last-date), "99") +
            string(day(temp-cash-desk.last-date), "99")))  +
            string((if v-hundred and z-num_ = 11 then 100 else  z-num_), "99999") +
            string(p-num-recs, "9999.9999") +
            string(year(temp-cash-desk.last-p-date), "9999") +
            string(month(temp-cash-desk.last-p-date), "99") +
            string(day(temp-cash-desk.last-p-date), "99") +
            string(temp-cash-desk.last-p-z-count, "99999") +
            string(temp-cash-desk.last-p-num-recs, "9999")
            .
  end.
  if v-new > v-old then do:
    if v-petrol-mode then do:
      assign
      temp-cash-desk.last-p-date      = (if chk-date_ <> 01/01/1990 then chk-date_ else temp-cash-desk.last-p-date)
      temp-cash-desk.last-p-z-count   = (if v-hundred and z-num_ = 11 then 100 else  z-num_)
      temp-cash-desk.last-p-num-recs  = p-num-recs
      .
    end.
    else do:
      assign
      temp-cash-desk.last-date     = (if chk-date_ <> 01/01/1990 then chk-date_ else temp-cash-desk.last-date)
      temp-cash-desk.last-z-count  = (if v-hundred and z-num_ = 11 then 100 else  z-num_)
      temp-cash-desk.last-num-recs = p-num-recs
      .
    end.
  end.
  end. /**/

end procedure. /* process-maria-attr */

procedure proc-shift :
define parameter buffer buf_tt-ss for tt-ss.
define input parameter p-ii as integer no-undo .
define variable shift-info as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
    pay-desk_ = p-cash-num
    z-num_ = integer(entry(2, buf_tt-ss.n-entry[1], '=':U))
    no-error .
    if error-status:error then do:
      var-file-line-num = tt-ss.rec-no.
      {&error-in-file-format}
    end.
    assign
    chk-date_ = 01/01/1990
    .
    if p-ii > 2 then do:
      assign
      shift-num_ = z-num_ modulo 100
      v-hundred = (if shift-num_ = 0
                   or shift-num_ = 100 then yes else no)
      shift-num_ = (if shift-num_ = 0
                   or shift-num_ = 100 then 11 else shift-num_)
      shift-date_ = date(
                        int( substr( buf_tt-ss.n-entry[2], 6, 2 ) ),
                        int( substr( buf_tt-ss.n-entry[2], 8, 2 ) ),
                        int( substr( buf_tt-ss.n-entry[2], 2, 4  ) )
                        )
      shift-open-time_ = int( substr( buf_tt-ss.n-entry[3], 1, 7 ) ) * 3600 + int( substr( buf_tt-ss.n-entry[4], 8, 2 ) ) * 60
      chk-date_ = date(
                        int( substr( buf_tt-ss.n-entry[4], 6, 2 ) ),
                        int( substr( buf_tt-ss.n-entry[4], 8, 2 ) ),
                        int( substr( buf_tt-ss.n-entry[4], 2, 4 ) )
                        )
      chk-time_ =  int( substr( buf_tt-ss.n-entry[5], 1, 7 ) ) * 3600 + int( substr( buf_tt-ss.n-entry[5], 8, 2 ) ) * 60
      no-error
      .
      if error-status:error then do:
        var-file-line-num = buf_tt-ss.rec-no.
        {&error-in-file-format}
      end.
    end.
    if get-chkc_context.cas-shft then do:
      /*на кассах есть смены*/
      if current-pay-desk <> pay-desk_
      or NOT (current-cas-shift-name =  shift-name_
          AND current-cas-shift-date = shift-date_)
      OR not avail buf_shift-cash then do:
        { str/libchkvl_get-cash-shift.i
        "buffer get-chkc_context:handle"
        buf_shift-cash
        pay-desk_
        shift-date_
        shift-name_
        z-num_
        chk-date_
        chk-time_
        shift-open-time_
        no-error
        }
        if available buf_shift-cash then do:
          assign
          current-pay-desk = buf_shift-cash.cash-num
          current-cas-shift-name = buf_shift-cash.shift-name
          current-cas-shift-date = buf_shift-cash.shift-date
          .
        end.
        else do:
          current-pay-desk = -1.
        end.
      end.
    end. /*if cas-shft*/
    assign
    pay-desk_ = p-cash-num
    z-num_ = z-num_ + 1
    z-num_ = (if z-num_ = 101 then  1 else z-num_)
    .
    run process-maria-attr in this-procedure ( input 0.0).
  end.

end procedure. /* proc-shift */

procedure tekka-date-time  :
define input parameter p-tekka-date-time as character no-undo .
define input parameter p-cash-num as character no-undo .

  do
  on error undo, return error return-value
  :

define variable v-date as date.
define variable v-time as integer no-undo .
define variable v-type as character no-undo .
define variable v-date-time-info as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as integer no-undo .
define variable v-value-logical as logical no-undo .
define variable v-cd-date-time-info as character no-undo .
assign
v-date =  date(
          int( substr( p-tekka-date-time, 6, 2 ) ),
          int( substr( p-tekka-date-time, 8, 2 ) ),
          int( substr( p-tekka-date-time, 2, 4 ) )
            )
v-time =  int( substr( p-tekka-date-time, 16, 2 ) ) * 3600 +
          int( substr( p-tekka-date-time, 18, 2 ) ) * 60
no-error .
if error-status:error then return error.
assign
v-cd-date-time-info = string(YEAR(v-date), "9999":U) + "-":U +
             string(Month(v-date), "99":U) + "-":U +
             string(DAY(v-date), "99":U) +
             {&space-char}  +  string(v-time, "HH:MM:SS":U).


  run cd-attr-value in this-procedure (
                                                          input g#db-num
                                                          ,input p-obj-code
                                                          ,input {&cd-type-maria}
                                                          ,input integer(p-cash-num)
                                                          ,input {&cda-maria_operative}
                                                          ,input {&cda-maria_operative_data-actuality}
                                                          ,output v-date-time-info
                                                          ,output v-value-date
                                                          ,output v-value-decimal
                                                          ,output v-value-integer
                                                          ,output v-value-logical
                                                          ,output v-type
                                                          ) no-error.
  if v-date-time-info < v-cd-date-time-info then do:
    run cd-attr-write in this-procedure (
                                          input g#db-num
                                          ,input p-obj-code
                                          ,input {&cd-type-maria}
                                          ,input integer(p-cash-num)
                                          ,input {&cda-maria_operative}
                                          ,input {&cda-maria_operative_data-actuality}
                                          ,input v-cd-date-time-info
                                          ,input ?
                                          ,input 0.0
                                          ,input 0
                                          ,input no

                                          ).

  end.
end.

end procedure. /* tekka-date-time  */