block-level on error undo, throw.
 /*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: get-ncr.p $
$Archive: str/get-ncr.p $

Программа приема чеков с касс NCR

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/20/05
Author: Bakhtadze Natalya
Creation date: 10/20/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-pos-type like ub.cash-desk.pos-type  no-undo .
define input parameter p-version as character no-undo .
DEFINE INPUT PARAMETER file_ as character no-undo.
define input-output parameter p-view-log as logical no-undo .

DEFINE VARIABLE vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":u .
DEFINE VARIABLE vss-author      as character no-undo init "$Author: expertek $":u .
DEFINE VARIABLE vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":u .
DEFINE VARIABLE vss-workfile    as character no-undo init "$Workfile: get-ncr.p $":u .
DEFINE VARIABLE vss-archive     as character no-undo init "$Archive: str/get-ncr.p $":u .
DEFINE VARIABLE vss-description as character no-undo init "Программа приема чеков с касс NCR" .
{ cmp/vssrevis.i }

{ str/get-chk.i }
/*общие для кассовой части и чековой*/

{ str/get-chkc.i def }
/*только чековая часть*/
{ cmp/bitoper.i }

/*глобальный тип чека в спуле* - стринг от цифры  1-20*/
DEFINE VARIABLE curr-grp-code             as   int no-undo.

/*курс нац вал из шапки чека*/
DEFINE VARIABLE naz-rate                   as   decimal no-undo.
/*для раскладки строчки*/
DEFINE VARIABLE var-record-type            as   character no-undo .
DEFINE VARIABLE n-entry                    as   char no-undo extent 25.
DEFINE VARIABLE kriv2                      as   logical no-undo.
DEFINE VARIABLE accept-types               as   character no-undo .
DEFINE VARIABLE wth-type                   as   integer no-undo .
DEFINE VARIABLE code1                      as   character no-undo .
DEFINE VARIABLE code2                      as   character no-undo .
DEFINE VARIABLE code3                      as   character no-undo .
DEFINE VARIABLE action-code                as   character no-undo .
DEFINE VARIABLE is-in-check                as logical no-undo .
DEFINE VARIABLE was-deleted                as logical no-undo .
DEFINE VARIABLE var-returns                as character no-undo .
define variable v-flag-salesman            as   logical   no-undo .
define variable v-version-dec              as  decimal no-undo .
define buffer for-goods for ub.goods.
define buffer for-bar for ub.bar-code.

define variable v-disc-round as decimal no-undo initial 0.

assign
shop-type = p-obj-type
shop-code = p-obj-code
.

{ str/get-chkc.i run }
get-chkc_context.pos-type = p-pos-type.


RUN get-ncr-c in this-procedure (file_) no-error .
if error-status:error then return no-apply.


PROCEDURE get-ncr-c.
def input parameter filename as char no-undo.


run get-ncr-parameters in this-procedure no-error.
if error-status:error then return error.
run gbl/filename.p (
                input filename
               ,output v-full-path
               ,output v-path
               ,output v-file-name
               ,output v-file-name-no-ext
               ,output v-file-name-ext
               ) no-error .
if error-status:error then return error.
error-status:error = FALSE.

input stream ChkStream from value( filename ).
_repeat:
REPEAT :
_line:
DO TRANSACTION:
  import stream ChkStream unformatted ss.
  assign
  var-file-line-num = var-file-line-num + 1
  .
  if ss = "" or ss = ? then do:
    n-entry[1] = "".
    leave _line.
  end.
  DO ii = 1 to num-entries(ss, {&colon-char}):
    assign
    n-entry[ii] = entry(ii, ss, {&colon-char})
    .
  END.
  DO ii = (num-entries(ss, {&colon-char}) + 1) to 25:
      assign
      n-entry[ii] = "".
  END.
  assign
  ii = num-entries(ss, {&colon-char})    .
  if trim(n-entry[8]) <> "":u  then do:
    assign
    code1 = substr(n-entry[8], 1, 1)
    code2 = substr(n-entry[8], 2, 1)
    code3 = substr(n-entry[8], 3, 1)
    .
  end.
  else do:
    assign
    code1 = "":U
    code2 = "":U
    code3 = "":U
    .
  end.
END.
DO TRANSACTION :
  CASE n-entry[7]:
    when 'F':U then do:
      /*надо уладить все дела со принятыми чеками!!!*/
      /* проверим что это F к нашему чеку*/
      if code1 = gbl-type and action-code = substr(n-entry[11], 1, 2) then do:
        assign
        gbl-type = "":U
        action-code = "":U
        is-in-check = no
        .
        run proc-end in this-procedure (if ub.chk-doc.chk-type = integer({&rcpt-inventory})
                                        then string(0)
                                        else string ( dec(substr(n-entry[11], 9, 10)) - v-disc-round) ) no-error .
      end.
      else do:
        assign
        gbl-type = "":U
        action-code = "":U
        is-in-check = no
        .
        release ub.chk-doc no-error .
        release ub.chk-gds no-error .
        release ub.chk-pay no-error .
        release ub.chk-discnt no-error .
        /*check-check не отработает в ub.chk-doc.office останется ошибка - что нам и надо*/
        if avail ub.chk-doc then do:
          ub.chk-doc.correct = no.
        end.
        release ub.chk-pay  no-error .
        /*check-check-wth не отработает в мц ub.chk-doc.correct останется ошибка - что нам и надо*/
      end.
    end.
    when 'H':U then  do:  /* Заголовок чека любого типа */
      run proc-start in this-procedure no-error .
    end. /*when H*/
    when "T":U then do: /* Оплата чека  или строка чека МЦ */
      CASE gbl-type:
        when "1":U then do:
          run proc-tender in this-procedure(input 0, input NOT (not exist and is-in-check) ) no-error .
        end.
        when "0":U then do:
          run proc-tender in this-procedure(input 1, input Not (not mc-exist and is-in-check) ) no-error .
        end.

        /*
        when "O":U then do:
          run proc-tender in this-procedure(input 1, input mc-exist) no-error .
        end.
        */
        otherwise do:
          /* ошибка */
        end.
      END CASE.
    end.
    when "S":U then  do:  /* Строка чека тип 1,6,7 */
      run proc-sale in this-procedure no-error .
    end.
    when "D":U then do: /* Итоговые скидки - могут быть только в чеке типа 1,6 */
      if trim(n-entry[8]) = "120" then do :
        v-disc-round = dec( substr(n-entry[11], 9 , 10 )).
      end.
      else do :
        run proc-cash-discount in this-procedure no-error .
      end.
    end.
    when "I":U then do: /*инвентаризация*/
      run proc-inv in this-procedure .
    end.
    when "C":U then do: /*скидки на товар*/
      if available ub.chk-gds then do:
        case p-pos-type:
          when {&cd-type-ncr-gm} then do:
            run proc-gds-discnt in this-procedure no-error .
          end.
          when {&cd-type-ncr-as-r} then do:
            run proc-gds-discnt-as-r in this-procedure no-error .
          end.
        end case.
      end.
    end.
    when "P":U then do: /*продавец*/
      run proc-set-salesman in this-procedure no-error .
    end.
    when "W":U then do:
      if p-pos-type = {&cd-type-ncr-as-r}
      and v-version-dec >= 2.6 then do:
        /*nothing*/
      end.
      else do:
        run proc-without-discount in this-procedure no-error .
      end.
    end.
    when "A":U or /*supervisor*/
    when "B":U or /*что-то про комплекты - игнорируем*/
    when "G":U or /*что-то про купоны*/
    when "L":U or /* LAYAWAY что-то вроде предварительных заказов игнорир  */
    when "M":U or /*выплаты и приход по счету*/
    when "N":U or /*банковские реквизиты при оплате картой или банковским чеком - игнорируем*/
    when "V":U or /*VAT - игнорируем*/
    when "O":U or /*строки чек офиса игнорируем*/
    when "X":U or /* transf erигнорир*/
    when "U":U or /*кредитные карты*/
    when "R":U or /*кредитные карты*/
    when "Q":U or  /*запрос демографических данных*/
    when "J":U or  /*журанльная информация*/
    when "K":U    /*Описание вознаграждений в Электронных Промоакциях*/
    then do:
      /*nothing!!!!*/
    end.
    otherwise do:
      {&error-in-file-format}
    end.
    END CASE .
  END.
END .
assign
error-status:error = false.
input stream ChkStream close.
END PROCEDURE.

PROCEDURE get-ncr-parameters:
define variable v-index as integer no-undo .
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
  undo, return .
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
  undo, return .
end.



{ gbl/conf-rd.i
 "'is-cdinv'"
 0
 "''":U
 0
 "''":U
 "''":U
 "''":U
 NO
 is-cdinv
 par-type
 NO-ERROR
 }


if is-wth = yes then do:
  accept-types =  "0,1":U.
  /*0 money trans 1 - sale 5 stock-count */
end.
else do:
  accept-types =  "1":U.
end.
if logical(is-cdinv) then accept-types = accept-types + ",5":U.
if annu-check then
accept-types = accept-types + ",2":U.
assign
v-version-dec = decimal(p-version)
no-error .

END PROCEDURE.



procedure proc-start :

  do
  on error undo, return error
  :
    assign
    gbl-type = code1
    action-code = substr(n-entry[11], 1, 2)
    no-error
    .
    /*перепишем в переменные общие для всех  обрабатываемых нами типов чеков данные!!!!*/
    if can-do(accept-types,  gbl-type ) then do:
      assign
      sales-man_ = 0
      v-flag-salesman  = no
      chk-date_  =   date(
                                    int( substr( n-ENTRY[3], 3, 2 ) ), /*month*/
                                    int( substr( n-ENTRY[3], 5, 2 ) ), /*day*/
                                    int( substr( n-ENTRY[3], 1, 2 )) + 2000   /*year*/
                                    )
      chk-time_ =  int( substr( n-entry[4], 1, 2 ) ) * 3600 + int( substr( n-entry[4], 3, 2 ) ) * 60  +
                    int( substr(n-entry[4], 5, 2) )
      shift-date_ = chk-date_
      shift-num_ = 0
      shift-name_ = '':U
      shop-code = ( if get-chkc_context.hnum
                    then int( trim(  n-entry[1] ) )
                    else p-obj-code )
      shop-type = ( if get-chkc_context.hnum then {&shop} else p-obj-type )
      chk-num_ = int( trim( n-entry[5] ) )
      pay-desk_ = int( trim( n-entry[2] ) )
      cashier_ = int( trim( n-entry[9] ) )
      chk-type_ = (if gbl-type = "2"
                  then  integer({&rcpt-annu})
                  else (if gbl-type = "5"
                        then integer({&rcpt-inventory})
                        else (
                              if code2 = "0":U
                              then integer({&rcpt-sale})
                              else (if code2 = "5":U or code2 = "6":U
                                    then integer({&rcpt-return})
                                    else 0)
                             )
                       )
                )
      d-card_ = (if gbl-type = "5" then "" else trim( n-entry[10]))
      no-error
      .
      if error-status:error then do:
        {&error-in-file-format}
      end.
    end. /*если содержится в accept-types*/
    else do:
      /*какие-то неизвестные нам виды чеков*/
      assign
      exist = yes
/*      mc-exist = yes*/
      gbl-type = "":U
      . /* Предпологаем что уже есть в базе */

    end.
    if is-wth and lookup(gbl-type, "0,6,7,9":U) > 0 then do:
      /*инициируем переменные для приема чеков-МЦ*/
      assign
      mc-for-chk-type = ""
      mc-exist = yes /* Предполагаем что уже есть в базе */
      wth-type = 0
      .
      CASE action-code:
        when "10":U or
        when "15":U then do:
          /*кассовый фонд*/
          wth-type = 3.
        end.
        when "11":U then do:
          /*инкассация*/
          wth-type = 2.
        end.
        when "06":U then do:
          /*выплата из кассы по счету ? */
          wth-type = 5.
        end.
        when "09":U then do:
          /*декларация*/
          wth-type = 7.
        end.
        when "14":U then do:
          /*перевод оплаты*/
          wth-type = 4.
        end.
        when "12":U then do:
          /*from bank to office*/
          wth-type = 4.
        end.
        when "13":U then do:
          /*from office to bank*/
          wth-type = 4.
        end.
        when "40":U then do:
          /*office to central cash terminal*/
          wth-type = 4.
        end.
        when "50":U then do:
          /*central cash terminal to ofiice*/
          wth-type = 4.
        end.
      END CASE.
      FIND  ub.chk-doc where
            ub.chk-doc.obj-type = shop-type and
            ub.chk-doc.obj-code = shop-code and
            ub.chk-doc.chk-date = chk-date_ and
            ub.chk-doc.pay-desk = pay-desk_ and
            ub.chk-doc.chk-time = chk-time_ and
            ub.chk-doc.chk-num  = chk-num_  and
            ub.chk-doc.sales-man = sales-man_
            NO-ERROR NO-WAIT.
      IF NOT AVAIL ub.chk-doc AND NOT LOCKED ub.chk-doc  AND NOT AMBIGUOUS ub.chk-doc then do:
        /*установить смены на кассе*/
        assign
        mc-exist = no
        cr = 0
        lll = lll + 1 .
        CREATE ub.chk-doc.
        assign
        ub.chk-doc.office = ?
        ub.chk-doc.chk-type = 0
        is-in-check = yes
        lng = 0
        lnp = 0
        ub.chk-doc.obj-code = shop-code
        ub.chk-doc.obj-type = shop-type
        ub.chk-doc.doc-code = (if get-chkc_context.db-num = 0
                              then string(next-value(s-chk, {&db-name_schema} ))
                              else string( shop-code ) + {&slash-char} + string( next-value( s-chk, {&db-name_schema} ) ))
        ub.chk-doc.chk-num = chk-num_
        ub.chk-doc.chk-date = chk-date_
        ub.chk-doc.chk-time = chk-time_
        ub.chk-doc.sales-man = sales-man_
        ub.chk-doc.pay-desk = pay-desk_
        ub.chk-doc.cashier = cashier_
        ub.chk-doc.discnt = 0
        ub.chk-doc.shift-date = shift-date_
        ub.chk-doc.src-shift-date = shift-date_
        ub.chk-doc.shift-num = shift-num_
        ub.chk-doc.shift-name = shift-name_
        ub.chk-doc.src-shift-name = shift-name_
        ub.chk-doc.z-number = 0
        ub.chk-doc.chk-type = wth-type
        ub.chk-doc.cash-rate = 1
        ub.chk-doc.cash-scale = 1
        ub.chk-doc.tot-doc = 0
        ub.chk-doc.netto = 0
        ub.chk-doc.discnt = 0
        ub.chk-doc.d-pcnt = 0
        ub.chk-doc.src-d-pcnt = 0
        ub.chk-doc.doc-qnty = 0
        ub.chk-doc.src-tot-doc = 0
        ub.chk-doc.src-d-mask = ''
        ub.chk-doc.d-mask = ''
        ub.chk-doc.d-card = ''
        ub.chk-doc.src-d-card = ''
        ub.chk-doc.src-cli-type = ?
        ub.chk-doc.src-cli-code = ?
        ub.chk-doc.cli-type = ?
        ub.chk-doc.cli-code = ?
        ub.chk-doc.doc-num2 = ?
        ub.chk-doc.out-2-code = ?
        no-error
        .
        if error-status:error then
        ub.chk-doc.correct = no.
        assign
        naz-rate = 1
        no-error.
        mc-prev-code = ub.chk-doc.doc-code.
      end. /* not(can-find) */
      else
      mc-curr-chk-type = 0 .
    end.
    if lookup( gbl-type, "1":U ) > 0
    or (logical(is-cdinv)
    and  LOOKUP(gbl-type,  "5":U ) > 0)
    then do:
      /*инициируем переменные для приема товарных чеков*/
      assign
      for-chk-type = ""
      tot-d-pcnt = 0
      exist = yes  /* Предполагаем что уже есть в базе */
      .
      FIND  ub.chk-doc where
            ub.chk-doc.obj-type = shop-type and
            ub.chk-doc.obj-code = shop-code and
            ub.chk-doc.chk-date = chk-date_ and
            ub.chk-doc.pay-desk = pay-desk_ and
            ub.chk-doc.chk-time = chk-time_ and
            ub.chk-doc.chk-num = chk-num_   and
            ub.chk-doc.sales-man = sales-man_
            NO-ERROR NO-WAIT.
      IF NOT AVAIL ub.chk-doc AND NOT LOCKED ub.chk-doc  AND NOT AMBIGUOUS ub.chk-doc then do:
        /*установить смены на кассе*/
        assign
        exist = no
        cr = 0
        lll = lll + 1 .
        CREATE ub.chk-doc.
        assign
        ub.chk-doc.office = ?
        is-in-check = yes
        var-returns = "":U
        lng = 0
        lnp = 0
        sub-d = 0
        netto-for-sub-d = 0
        var-discnt-id = 0
        ub.chk-doc.obj-code = shop-code
        ub.chk-doc.obj-type = shop-type
        ub.chk-doc.doc-code = (if get-chkc_context.db-num = 0
                                          then string(next-value(s-chk, {&db-name_schema} ))
                                          else string( shop-code ) + {&slash-char} + string( next-value( s-chk, {&db-name_schema} ) ))
        ub.chk-doc.chk-num = chk-num_
        ub.chk-doc.chk-date = chk-date_
        ub.chk-doc.chk-time = chk-time_
        ub.chk-doc.sales-man = sales-man_
        ub.chk-doc.pay-desk = pay-desk_
        ub.chk-doc.cashier = cashier_
        ub.chk-doc.discnt = 0
        ub.chk-doc.src-d-card = (if ub.chk-doc.chk-type = integer({&rcpt-inventory}) then '':U else d-card_)
        ub.chk-doc.shift-date = shift-date_
        ub.chk-doc.src-shift-date = shift-date_
        ub.chk-doc.shift-num = shift-num_
        ub.chk-doc.shift-name = shift-name_
        ub.chk-doc.src-shift-name = shift-name_
        ub.chk-doc.cash-rate =  1
        ub.chk-doc.cash-scale = 1
        ub.chk-doc.z-number = 0
        ub.chk-doc.chk-type = chk-type_
        ub.chk-doc.correct = yes
        ub.chk-doc.src-d-pcnt = 0
        . /*в спуле стоит с минусом*/
        prev-code = ub.chk-doc.doc-code.
      end. /* not(can-find) */
    end. /*товарные чеки*/
  end.

end procedure. /* proc-start */


procedure proc-sale :
DEFINE VARIABLE codechr as character no-undo .
DEFINE VARIABLE curr-string-qnty1 as decimal no-undo .
DEFINE VARIABLE curr-string-qnty2 as decimal no-undo .
DEFINE VARIABLE curr-string-qntys as decimal no-undo .
define variable v-found as logical no-undo .
define buffer del_chk-gds for ub.chk-gds.
define buffer del_chk-discnt for ub.chk-discnt.

  do
  on error undo, return error
  :
    if exist or not is-in-check then return.
    /*надо разобрать 10-е поле*/
    assign
    was-deleted = no
    codechr = substr(n-entry[10], 22, 1)
    curr-string-qntys = int(substr(n-entry[10], 17, 1 ) + "1":U)
    curr-string-qnty1 = int(substr(n-entry[10], 18, 4 ))
    curr-string-qnty2 = int(substr(n-entry[10], 23, 3 ))
    curr-string-qnty = if codechr = ".":U
                        then
                        (curr-string-qnty1 + curr-string-qnty2 / 1000 )
                        else
                        (curr-string-qnty1 * (int(codechr) * 100 + curr-string-qnty2 / 10 ))
    curr-string-qnty = curr-string-qntys * curr-string-qnty
    bc-buf = trim( substr(n-entry[10], 1, 16  ))
    time-oper_ =  int( substr( n-entry[4], 1, 2 ) ) * 3600 +
                  int( substr( n-entry[4], 3, 2 ) ) * 60  +
                  int( substr(n-entry[4], 5, 2) )
    pass-gds_ = (if code3 = "0":U or code3 = "8"
                then 1
                else 0
                )
    no-error
    .
    CASE p-pos-type:
      when {&cd-type-ncr-gm} then do:
        assign
        sum-from-check = dec(substr( n-entry[10], 26, 10 )) / 100
        price-from-check = abs(sum-from-check / curr-string-qnty)
        .
      end.
      when {&cd-type-ncr-as-r} then do:
        assign
        price-from-check = dec(substr( n-entry[10], 26, 10 )) / 100
        sum-from-check = price-from-check * curr-string-qnty
        .
      end.
    END CASE.
    if error-status:error then do:
      {&error-in-file-format}
    end.
    if code2 = "7":U then do:
      _del_chk-gds:
      for each del_chk-gds where
               del_chk-gds.doc-code = ub.chk-doc.doc-code:
        if del_chk-gds.src-code = bc-buf and
           del_chk-gds.src-qnty =  - curr-string-qnty and
          del_chk-gds.src-sum = - sum-from-check and
          lookup(string(del_chk-gds.line-num), var-returns) = 0
          then do:
          create ub.chk-gds.
          buffer-copy del_chk-gds except line-num to ub.chk-gds
          assign
          lng = lng + 1
          ub.chk-gds.src-qnty = - del_chk-gds.src-qnty
          ub.chk-gds.src-sum = - del_chk-gds.src-sum
          ub.chk-gds.line-num = lng
          ub.chk-gds.line-sign = not del_chk-gds.line-sign
          was-deleted = yes
          var-returns = var-returns + {&comma-char} + string(del_chk-gds.line-num)
          .
          define variable v-wd-sum as decimal no-undo .
          for each tt-wd where
                  tt-wd.line-num = del_chk-gds.line-num:
            assign
            v-wd-sum = v-wd-sum + tt-wd.wd-sum .
          end.
          netto-for-sub-d = netto-for-sub-d + ub.chk-gds.src-sum - ub.chk-gds.src-discnt * ub.chk-gds.src-qnty + v-wd-sum.

          for each del_chk-discnt No-LOCK WHERE
                   del_chk-discnt.doc-code = ub.chk-doc.doc-code AND
                   del_chk-discnt.line-num = del_chk-gds.line-num AND
                   del_chk-discnt.object-line-num = del_chk-gds.line-num AND
                   del_chk-discnt.record-type = 0
                   :
            create ub.chk-discnt.
            buffer-copy del_chk-discnt to ub.chk-discnt
            assign
            ub.chk-discnt.object-line-num = ub.chk-gds.line-num
            ub.chk-discnt.discnt-value-abs = - del_chk-discnt.discnt-value-abs
            ub.chk-discnt.discnt-value-pcnt = - del_chk-discnt.discnt-value-pcnt
            ub.chk-discnt.object-qnty = - del_chk-discnt.object-qnty
            ub.chk-discnt.object-sum = - del_chk-discnt.object-sum
            .
          END.  /*for each del_chk-discnt*/
          for each del_chk-discnt WHERE
                   del_chk-discnt.doc-code = ub.chk-doc.doc-code AND
                   del_chk-discnt.line-num >= del_chk-gds.line-num AND
                   del_chk-discnt.object-line-num = 0 AND
                   del_chk-discnt.record-type = 0:
            assign
            del_chk-discnt.object-sum = del_chk-discnt.object-sum -
                                        del_chk-gds.src-qnty * (del_chk-gds.src-price - del_chk-gds.src-discnt)
            del_chk-discnt.discnt-value-pcnt = if del_chk-discnt.object-sum = 0
                                        then 0
                                        else del_chk-discnt.discnt-value-abs / del_chk-discnt.object-sum  * 100
            .
          end.
          find first tt-wd where
                    tt-wd.line-num = del_chk-gds.line-num no-error .
          if not avail tt-wd then do:
            create tt-wd.
            assign
            tt-wd.doc-code = del_chk-gds.doc-code
            tt-wd.record-type = 0
            tt-wd.line-type  = integer({&discnt-gds-without-discnt})
            tt-wd.discnt-id = 0
            tt-wd.line-num = del_chk-gds.line-num
            tt-wd.wd-sum   = 0
            .
            create ub.chk-discnt.
            assign
            ub.chk-discnt.doc-code = ub.chk-doc.doc-code
            ub.chk-discnt.record-type = 0
            ub.chk-discnt.discnt-id = (var-discnt-id + 1)
            ub.chk-discnt.line-num = del_chk-gds.line-num
            ub.chk-discnt.time-oper = time-oper_
            ub.chk-discnt.line-type = integer({&discnt-gds-without-discnt})
            ub.chk-discnt.line-sign = no
            ub.chk-discnt.pass-discnt = integer({&discnt-p-auto})
            ub.chk-discnt.value-type = integer({&discnt-v-abs})
            ub.chk-discnt.discnt-type = if ub.chk-doc.src-d-card <> ""
                                      then integer({&discnt-t-d-card})
                                      else integer({&discnt-t-sum})
            ub.chk-discnt.src-d-card = ub.chk-doc.src-d-card
            ub.chk-discnt.discnt-value-abs = 0
            ub.chk-discnt.discnt-value-pcnt = 0
            ub.chk-discnt.object-line-num = del_chk-gds.line-num
            ub.chk-discnt.object-sum = - del_chk-gds.src-qnty * (del_chk-gds.src-price - del_chk-gds.src-discnt)
            ub.chk-discnt.object-qnty = del_chk-gds.src-qnty
            ub.chk-discnt.pay-desk = ub.chk-doc.pay-desk
            ub.chk-discnt.obj-code = ub.chk-doc.obj-code
            ub.chk-discnt.obj-type = ub.chk-doc.obj-type
            ub.chk-discnt.chk-date = ub.chk-doc.chk-date
            ub.chk-discnt.chk-time = ub.chk-doc.chk-time
            var-discnt-id = var-discnt-id + 1
            .
          end.
          else do:
            assign
            tt-wd.wd-sum = 0
            .
          end.
          v-found = yes.
          LEAVE _del_chk-gds.
        end.  /*if del_chk-gds.src-code = bc-buf and*/
        /*создадим записи в таблице товаров без скидок чтобы потом по удаленным не размазывать!!!*/
      end. /*for each del_chk-gds*/
      if v-found then do:
        create tt-wd.
        assign
        tt-wd.line-num = ub.chk-gds.line-num
        tt-wd.discnt-id = 0
        tt-wd.doc-code = ub.chk-gds.doc-code
        tt-wd.record-type = 0
        tt-wd.line-type  = integer({&discnt-gds-without-discnt})
        tt-wd.wd-sum   = 0
        .
        create ub.chk-discnt.
        assign
        ub.chk-discnt.doc-code = ub.chk-doc.doc-code
        ub.chk-discnt.record-type = 0
        ub.chk-discnt.discnt-id = (var-discnt-id + 1)
        ub.chk-discnt.line-num = ub.chk-gds.line-num
        ub.chk-discnt.time-oper = time-oper_
        ub.chk-discnt.line-type = integer({&discnt-gds-without-discnt})
        ub.chk-discnt.line-sign = no
        ub.chk-discnt.pass-discnt = integer({&discnt-p-auto})
        ub.chk-discnt.value-type = integer({&discnt-v-abs})
        ub.chk-discnt.discnt-type = if ub.chk-doc.src-d-card <> ""
                                  then integer({&discnt-t-d-card})
                                  else integer({&discnt-t-sum})
        ub.chk-discnt.src-d-card = ub.chk-doc.src-d-card
        ub.chk-discnt.discnt-value-abs = 0
        ub.chk-discnt.discnt-value-pcnt = 0
        ub.chk-discnt.object-line-num = ub.chk-gds.line-num
        ub.chk-discnt.object-sum = - ub.chk-gds.src-qnty * (chk-gds.src-price - ub.chk-gds.src-discnt)
        ub.chk-discnt.object-qnty = ub.chk-gds.src-qnty
        ub.chk-discnt.pay-desk = ub.chk-doc.pay-desk
        ub.chk-discnt.obj-code = ub.chk-doc.obj-code
        ub.chk-discnt.obj-type = ub.chk-doc.obj-type
        ub.chk-discnt.chk-date = ub.chk-doc.chk-date
        ub.chk-discnt.chk-time = ub.chk-doc.chk-time
        var-discnt-id = var-discnt-id + 1
        .
      end.
    end.  /*if code2 = "7":U*/
    if not v-found then do:
      CREATE ub.chk-gds.
      assign
      lng = lng + 1
      ub.chk-gds.doc-code = ub.chk-doc.doc-code
      ub.chk-gds.line-num = lng
      ub.chk-gds.grp-code = 0
      ub.chk-gds.chk-date = ub.chk-doc.chk-date
      ub.chk-gds.b-code = 0
      ub.chk-gds.src-code = bc-buf
      ub.chk-gds.is-error = no
      ub.chk-gds.src-price = price-from-check
      ub.chk-gds.src-qnty = curr-string-qnty
      ub.chk-gds.doc-qnty = 0
      ub.chk-gds.src-sum  =  sum-from-check
      ub.chk-gds.src-discnt = 0
      ub.chk-gds.pump = 0
      ub.chk-gds.road-tax = 0
      ub.chk-gds.time-oper =  time-oper_
      ub.chk-gds.pass-gds = pass-gds_
      ub.chk-gds.sales-man = sales-man_
      ub.chk-doc.sales-man = (if not v-flag-salesman
                          and
                          (
                          ub.chk-doc.sales-man = 0
                          or ub.chk-doc.sales-man = sales-man_)
                          then sales-man_
                          else 0)
      v-flag-salesman   = (if not v-flag-salesman  and sales-man_ <> 0
                          then yes
                          else v-flag-salesman)
      ub.chk-gds.line-sign = (if ub.chk-doc.chk-type = integer({&rcpt-sale})
                          then (chk-gds.src-qnty >= 0)
                          else (chk-gds.src-qnty <= 0)
                          )
      ub.chk-gds.line-type = '':U
      netto-for-sub-d = netto-for-sub-d + ub.chk-gds.src-sum - ub.chk-gds.src-discnt * ub.chk-gds.src-qnty
      .
    end.
  end. /*doe*/

end procedure. /* proc-sale */


procedure proc-cash-discount :
DEFINE VARIABLE var-sub-d as decimal no-undo .
DEFINE VARIABLE var-lng as integer no-undo .
DEFINE VARIABLE var-str-dec as decimal no-undo .
define buffer buf_chk-gds for ub.chk-gds.

  do
  on error undo, return error
  :
    if exist or not is-in-check then return.
    assign
    var-sub-d =  - dec( substr(n-entry[11], 9 , 10 )) / 100  /* "+" - т.к. скидка  идет со знаком "-" */
    time-oper_ =  int( substr( n-entry[4], 1, 2 ) ) * 3600 +
                  int( substr( n-entry[4], 3, 2 ) ) * 60  +
                  int( substr(n-entry[4], 5, 2) )
    no-error .
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
    ub.chk-discnt.time-oper = time-oper_
    ub.chk-discnt.line-type = (if code2 = "5":U or code2 = "6":U
                            then integer({&discnt-sub-total})
                            else integer({&discnt-total})
                            )
    ub.chk-discnt.line-sign = yes
    ub.chk-discnt.pass-discnt = integer({&discnt-p-auto})
    ub.chk-discnt.value-type = if code2 = "5":U or code2 = "7":U
                            then integer({&discnt-v-abs})
                            else (if code2 = '6':U or code2 = '8'
                                  then integer({&discnt-v-pcnt})
                                  else integer({&discnt-v-unknown})
                                 )
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
    netto-for-sub-d = netto-for-sub-d - var-sub-d
    .
    release ub.chk-discnt.
  end. /*doe*/

end procedure. /* proc-cash-discount */

procedure proc-13 :

  do
  on error undo, return error
  :
    /* чек закрытия смены на кассе слава богу состоит из одной строки!!!! */
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

  end.

end procedure. /* proc-13 */

procedure proc-end :
define input parameter p-end-sum-str as character no-undo .
DEFINE VARIABLE v-end-sum as decimal no-undo .

  do
  on error undo, return error
  :

     assign
     v-end-sum = dec(p-end-sum-str) / 100
     no-error .

     if error-status:error then do:
        {&error-in-file-format}
     end.

     /*ппроверка всего что только что приняли*/
     get-chkc_context.ll = lll.
    { str/libchkvl_getcheck.i
      "buffer get-chkc_context:handle"
      ~{&add-def~}
      ''
      yes
      yes
      v-end-sum
      lng-sub-d
      sub-d
      var-discnt-id
      prev-code
      no-error
     }
    { str/libchkvl_getwcheck.i
    "buffer get-chkc_context:handle"
    ~{&add-def~}
    ''
    yes
    yes
    v-end-sum
    mc-prev-code
    no-error
    }

     for each tt-wd:
      delete tt-wd.
     end.
     assign
     prev-code = "":U
     mc-prev-code = "":U
     p-view-log = (p-view-log or get-chkc_context.view-log)
     lll = get-chkc_context.ll
     .
  end.

end procedure. /* proc-end */


procedure proc-gds-discnt :
DEFINE VARIABLE var-discnt as decimal no-undo .
DEFINE VARIABLE var-discnt-type as integer no-undo .
DEFINE VARIABLE var-gds-for-discnt as decimal no-undo .


  do
  on error undo, return error
  :
    if exist or not is-in-check or was-deleted then return.
    assign
    t-c-d =  - dec(substr(n-entry[11], 9, 10 )) / 100
    no-error
    .
    /*на всякий пожарный*/
    if error-status:error or trim( substr(n-entry[10], 1, 16  )) <> bc-buf then do:
      {&error-in-file-format}
    end.
    assign
    time-oper_ =  int( substr( n-entry[4], 1, 2 ) ) * 3600 +
                  int( substr( n-entry[4], 3, 2 ) ) * 60  +
                  int( substr(n-entry[4], 5, 2) )
    var-gds-for-discnt = (ub.chk-gds.src-price - ub.chk-gds.src-discnt) * ub.chk-gds.src-qnty
    .
    assign
    ub.chk-gds.src-discnt = ub.chk-gds.src-discnt + t-c-d / ub.chk-gds.src-qnty
    netto-for-sub-d = netto-for-sub-d - t-c-d
    .
    case code3:
      when "0":U then do:
        case code2:
          when "0":U then do:
            assign
            var-discnt-type = integer({&discnt-t-promo})
            .
          end.
          when "1":U then do:
            assign
            var-discnt-type = integer({&discnt-t-std})
            .
          end.
          when "2":U then do:
            assign
            var-discnt-type = integer({&discnt-t-sum})
            .
          end.
          when "3":U then do:
            assign
            var-discnt-type = integer({&discnt-t-unknown})
            .
          end.
          when "7":U then do:
            assign
            var-discnt-type = integer({&discnt-t-staff})
            .
          end.
          when "8":U then do:
            assign
            var-discnt-type = integer({&discnt-t-d-card})
            .
          end.
        END CASE.
      end.
      when "1":U then do:
        assign
        var-discnt-type = integer({&discnt-t-mark-down})
        .
      end.
      when "2":U then do:
        assign
        var-discnt-type = integer({&discnt-t-mark-down})
        .
      end.
      when "3":U then do:
        assign
        var-discnt-type = integer({&discnt-t-set})
        .
      end.
      when "5":U then do:
        assign
        var-discnt-type = integer({&discnt-t-qnty})
        .
      end.
      when "6":U then do:
        assign
        var-discnt-type = integer({&discnt-t-std})
        .
      end.
      when "7":U then do:
        assign
        var-discnt-type = integer({&discnt-t-hour})
        .
      end.
      when "8":U then do:
        assign
        var-discnt-type = integer({&discnt-t-another})
        .
      end.
    END CASE.
    create ub.chk-discnt.
    assign
    ub.chk-discnt.doc-code = ub.chk-doc.doc-code
    ub.chk-discnt.record-type = 0
    ub.chk-discnt.discnt-id = (var-discnt-id + 1)
    ub.chk-discnt.line-num = ub.chk-gds.line-num
    ub.chk-discnt.time-oper = time-oper_
    ub.chk-discnt.line-type = integer({&discnt-gds})
    ub.chk-discnt.line-sign =  (chk-gds.src-qnty >= 0 ) NE (t-c-d > 0 )
    ub.chk-discnt.pass-discnt = integer({&discnt-p-auto})
    ub.chk-discnt.value-type = if code2 = "3":U
                            then integer({&discnt-v-pcnt})
                            else (if code2 = "2":U then
                                  integer({&discnt-v-abs})
                                  else integer({&discnt-v-unknown})
                                  )
    ub.chk-discnt.discnt-type = var-discnt-type
    ub.chk-discnt.src-d-card = ub.chk-doc.src-d-card
    ub.chk-discnt.discnt-value-abs = t-c-d
    ub.chk-discnt.object-qnty = ub.chk-gds.src-qnty
    ub.chk-discnt.object-sum = var-gds-for-discnt
    ub.chk-discnt.discnt-value-pcnt = if var-gds-for-discnt <> 0
                                   then t-c-d / var-gds-for-discnt * 100
                                   else 0
    ub.chk-discnt.object-line-num = ub.chk-gds.line-num
    ub.chk-discnt.pay-desk = ub.chk-doc.pay-desk
    ub.chk-discnt.obj-code = ub.chk-doc.obj-code
    ub.chk-discnt.obj-type = ub.chk-doc.obj-type
    ub.chk-discnt.chk-date = ub.chk-doc.chk-date
    ub.chk-discnt.chk-time = ub.chk-doc.chk-time
    var-discnt-id = var-discnt-id + 1
    .
  end. /*doe*/

end procedure. /* proc-gds-discnt */


procedure proc-gds-discnt-as-r :
DEFINE VARIABLE var-discnt as decimal no-undo .
DEFINE VARIABLE var-discnt-type as integer no-undo .
DEFINE VARIABLE var-gds-for-discnt as decimal no-undo .
DEFINE VARIABLE codechr as character no-undo .
DEFINE VARIABLE curr-string-qnty1 as decimal no-undo .
DEFINE VARIABLE curr-string-qnty2 as decimal no-undo .
DEFINE VARIABLE curr-string-qntys as decimal no-undo .
define variable discnt-sign as character no-undo .
define variable v-discnt-value-abs as decimal no-undo .
define variable v-discnt-value-pcnt as decimal no-undo .


  do
  on error undo, return error
  :
    if exist or not is-in-check or was-deleted then return.
    assign
    discnt-sign = substr(n-entry[10], 26, 1 )
    t-c-d = (if discnt-sign = '<'
             or discnt-sign = '-'
             then 1
             else ( - 1)
             ) *
             dec(substr(n-entry[10], 27, 9 )) / 100
    /*после этой строки t-c-d всегда имеет смысл скидки - т.е. оно полож для скидки*/
    codechr = substr(n-entry[10], 22, 1)
    curr-string-qntys = int(substr(n-entry[10], 17, 1 ) + "1":U)
    curr-string-qnty1 = int(substr(n-entry[10], 18, 4 ))
    curr-string-qnty2 = int(substr(n-entry[10], 23, 3 ))
    curr-string-qnty = if codechr = ".":U
                        then
                        (curr-string-qnty1 + curr-string-qnty2 / 1000 )
                        else
                        (curr-string-qnty1 * (int(codechr) * 100 + curr-string-qnty2 / 10 ))
    curr-string-qnty = curr-string-qntys * curr-string-qnty
    no-error
    .
    /*на всякий пожарный*/
    if error-status:error or trim( substr(n-entry[10], 1, 16  )) <> bc-buf then do:
      {&error-in-file-format}
    end.
    assign
    time-oper_ =  int( substr( n-entry[4], 1, 2 ) ) * 3600 +
                  int( substr( n-entry[4], 3, 2 ) ) * 60  +
                  int( substr(n-entry[4], 5, 2) )
    var-gds-for-discnt = (ub.chk-gds.src-price - ub.chk-gds.src-discnt) * ub.chk-gds.src-qnty
    .
    case code2:
      when '0'
      or
      when '1' then do:
        assign
        ub.chk-gds.src-discnt = ub.chk-gds.src-discnt + t-c-d
        netto-for-sub-d = netto-for-sub-d - t-c-d * curr-string-qnty
        v-discnt-value-abs = t-c-d * curr-string-qnty
        v-discnt-value-pcnt =  if var-gds-for-discnt <> 0
                               then v-discnt-value-abs / var-gds-for-discnt * 100
                               else 0
        .
      end.
      otherwise do:
        assign
        ub.chk-gds.src-discnt = ub.chk-gds.src-discnt + t-c-d / ub.chk-gds.src-qnty
        netto-for-sub-d = netto-for-sub-d - t-c-d
        v-discnt-value-abs = t-c-d
        v-discnt-value-pcnt =  if var-gds-for-discnt <> 0
                              then t-c-d / var-gds-for-discnt * 100
                              else 0
        .
      end.
    END CASE.
    CASE code2:
      when '0':U then dO:
        CASE code3:
          when '1':U then do:
            assign
            var-discnt-type = integer({&discnt-t-mark-down})
            .
          end.
          when '2':U then do:
            assign
            var-discnt-type = integer({&discnt-t-another})
            .
          end.
          when '3':U then do:
            assign
            var-discnt-type = integer({&discnt-t-set})
            .
          end.
          when '5':U then do:
            assign
            var-discnt-type = integer({&discnt-t-qnty})
            .
          end.
          when '6':U then do:
            assign
            var-discnt-type = integer({&discnt-t-std})
            .
          end.
          when '7':U then do:
            assign
            var-discnt-type = integer({&discnt-t-hour})
            .
          end.
          when '8':U then do:
            assign
            var-discnt-type = integer({&discnt-t-another})
            .
          end.
        END CASE.
      end. /*code2 = 0*/
      when '7':U then do:
        assign
        var-discnt-type = integer({&discnt-t-staff})
        .
      end.
      when '8':U then do:
        assign
        var-discnt-type = integer({&discnt-t-d-card})
        .
      end.
      when '1':U then do:
        assign
        var-discnt-type = integer({&discnt-t-another})
        .
      end.
      when '2':U then do:
        assign
        var-discnt-type = integer({&discnt-t-sum})
        .
      end.
      when '3':U then do:
        assign
        var-discnt-type = integer({&discnt-t-std})
        .
      end.
      when '4':U then do:
        assign
        var-discnt-type = integer({&discnt-t-another})
        .
      end.
      when '5':U then do:
        assign
        var-discnt-type = integer({&discnt-t-set})
        .
      end.
    END CASE.
    create ub.chk-discnt.
    assign
    ub.chk-discnt.doc-code = ub.chk-doc.doc-code
    ub.chk-discnt.record-type = 0
    ub.chk-discnt.discnt-id = (var-discnt-id + 1)
    ub.chk-discnt.line-num = ub.chk-gds.line-num
    ub.chk-discnt.time-oper = time-oper_
    ub.chk-discnt.line-type = integer({&discnt-gds})
    ub.chk-discnt.line-sign =  (chk-gds.src-qnty >= 0 ) NE (t-c-d > 0 )
    ub.chk-discnt.pass-discnt = integer({&discnt-p-auto})
    ub.chk-discnt.value-type = if code2 = "3":U
                            then integer({&discnt-v-pcnt})
                            else (if code2 = "2":U then
                                  integer({&discnt-v-abs})
                                  else integer({&discnt-v-unknown})
                                  )
    ub.chk-discnt.discnt-type = var-discnt-type
    ub.chk-discnt.src-d-card = ub.chk-doc.src-d-card
    ub.chk-discnt.discnt-value-abs = v-discnt-value-abs
    ub.chk-discnt.object-qnty = ub.chk-gds.src-qnty
    ub.chk-discnt.object-sum = var-gds-for-discnt
    ub.chk-discnt.discnt-value-pcnt = v-discnt-value-pcnt
    ub.chk-discnt.object-line-num = ub.chk-gds.line-num
    ub.chk-discnt.pay-desk = ub.chk-doc.pay-desk
    ub.chk-discnt.obj-code = ub.chk-doc.obj-code
    ub.chk-discnt.obj-type = ub.chk-doc.obj-type
    ub.chk-discnt.chk-date = ub.chk-doc.chk-date
    ub.chk-discnt.chk-time = ub.chk-doc.chk-time
    var-discnt-id = var-discnt-id + 1
    .
  end. /*doe*/

end procedure. /* proc-gds-discnt */



procedure proc-set-salesman :

  do
  on error undo, return error
  :
    assign
    sales-man_ = integer(n-entry[9])
    no-error
    .
  end.

end procedure. /* proc-set-salesman */

procedure proc-without-discount :

DEFINE VARIABLE var-wd-sum as decimal no-undo .
  do
  on error undo, return error
  :
    /*на всякий пожарный*/
    if exist or not is-in-check or was-deleted then return.
    assign
    var-wd-sum = (dec(substr( n-entry[10], 26, 10 )) / 100)
    time-oper_ =  int( substr( n-entry[4], 1, 2 ) ) * 3600 +
                  int( substr( n-entry[4], 3, 2 ) ) * 60  +
                  int( substr(n-entry[4], 5, 2) )
    no-error
    .
    if error-status:error or trim( substr(n-entry[10], 1, 16  )) <> bc-buf then do:
      {&error-in-file-format}
    end.
    if var-wd-sum = 0 then return.
    /*рассмотрим отсутствие скидки на строку товара как надбавку - скидку с обратным знаком*/
    create tt-wd.
    assign
    tt-wd.line-num = ub.chk-gds.line-num
    tt-wd.wd-sum   = var-wd-sum
    tt-wd.doc-code = ub.chk-gds.doc-code
    tt-wd.record-type = 0
    tt-wd.line-type  = integer({&discnt-gds-without-discnt})
    .
    create ub.chk-discnt.
    assign
    ub.chk-discnt.doc-code = ub.chk-doc.doc-code
    ub.chk-discnt.record-type = 0
    ub.chk-discnt.discnt-id = (var-discnt-id + 1)
    ub.chk-discnt.line-num = ub.chk-gds.line-num
    ub.chk-discnt.time-oper = time-oper_
    ub.chk-discnt.line-type = integer({&discnt-gds-without-discnt})
    ub.chk-discnt.line-sign = no
    ub.chk-discnt.pass-discnt = integer({&discnt-p-auto})
    ub.chk-discnt.value-type = integer({&discnt-v-abs})
    ub.chk-discnt.discnt-type = if ub.chk-doc.src-d-card <> ""
                              then integer({&discnt-t-d-card})
                              else integer({&discnt-t-sum})
    ub.chk-discnt.src-d-card = ub.chk-doc.src-d-card
    ub.chk-discnt.discnt-value-abs = 0
    ub.chk-discnt.discnt-value-pcnt = 0
    ub.chk-discnt.object-line-num = ub.chk-gds.line-num
    ub.chk-discnt.object-sum = - var-wd-sum
    ub.chk-discnt.object-qnty = ub.chk-gds.src-qnty
    ub.chk-discnt.pay-desk = ub.chk-doc.pay-desk
    ub.chk-discnt.obj-code = ub.chk-doc.obj-code
    ub.chk-discnt.obj-type = ub.chk-doc.obj-type
    ub.chk-discnt.chk-date = ub.chk-doc.chk-date
    ub.chk-discnt.chk-time = ub.chk-doc.chk-time
    var-discnt-id = var-discnt-id + 1
    netto-for-sub-d = netto-for-sub-d - var-wd-sum
    .
    release ub.chk-discnt.
  end.

end procedure. /* proc-without-discount */


procedure proc-inv :
DEFINE VARIABLE codechr as character no-undo .
DEFINE VARIABLE curr-string-qnty1 as decimal no-undo .
DEFINE VARIABLE curr-string-qnty2 as decimal no-undo .
DEFINE VARIABLE curr-string-qntys as decimal no-undo .


  do
  on error undo, return error return-value
  :
   if exist
   or not is-in-check
   or not get-chkc_context.is-cdinv then return.


    assign
    codechr = substr(n-entry[10], 22, 1)
    curr-string-qnty1 = int(substr(n-entry[10], 17, 5 ))
    curr-string-qnty2 = int(substr(n-entry[10], 23, 3 ))
    curr-string-qnty = if codechr = ".":U
                      then
                      (curr-string-qnty1 + curr-string-qnty2 / 1000 )
                      else
                      (curr-string-qnty1 * (int(codechr) * 100 + curr-string-qnty2 / 10 ))
    time-oper_ =  int( substr( n-entry[4], 1, 2 ) ) * 3600 +
                  int( substr( n-entry[4], 3, 2 ) ) * 60  +
                  int( substr(n-entry[4], 5, 2) )
    pass-gds_ = (if code3 = "0":U or code3 = "8"
                then 1
                else 0
                )
    no-error
    .
    assign
    bc-buf = trim( substr(n-entry[10], 1, 16  ))
    .
    CASE p-pos-type:
      when {&cd-type-ncr-gm} then do:
        assign
        sum-from-check = dec(substr( n-entry[10], 26, 10 )) / 100
        price-from-check = abs(sum-from-check / curr-string-qnty)
        .
      end.
      when {&cd-type-ncr-as-r} then do:
        assign
        price-from-check = dec(substr( n-entry[10], 26, 10 )) / 100
        sum-from-check = price-from-check * curr-string-qnty
        .
      end.
    END CASE.
    if error-status:error then do:
      {&error-in-file-format}
    end.
    CREATE ub.chk-gds.
    assign
    lng = lng + 1
    ub.chk-gds.doc-code = ub.chk-doc.doc-code
    ub.chk-gds.line-num = lng
    ub.chk-gds.grp-code = 0
    ub.chk-gds.chk-date = ub.chk-doc.chk-date
    ub.chk-gds.b-code = 0
    ub.chk-gds.src-code = bc-buf
    ub.chk-gds.is-error = no
    ub.chk-gds.src-price = price-from-check
    ub.chk-gds.src-qnty = curr-string-qnty
    ub.chk-gds.doc-qnty = 0
    ub.chk-gds.src-sum  =  sum-from-check
    ub.chk-gds.src-discnt = 0
    ub.chk-gds.pump = 0
    ub.chk-gds.road-tax = 0
    ub.chk-gds.time-oper =  time-oper_
    ub.chk-gds.pass-gds = pass-gds_
    ub.chk-gds.sales-man = sales-man_
    ub.chk-doc.sales-man = (if not v-flag-salesman
                        and
                        (
                        ub.chk-doc.sales-man = 0
                        or ub.chk-doc.sales-man = sales-man_)
                        then sales-man_
                        else 0)
    v-flag-salesman   = (if not v-flag-salesman  and sales-man_ <> 0
                        then yes
                        else v-flag-salesman)
    ub.chk-gds.line-sign = (if ub.chk-doc.chk-type = integer({&rcpt-sale})
                        then (chk-gds.src-qnty >= 0)
                        else (chk-gds.src-qnty <= 0)
                        )
    ub.chk-gds.line-type = '':U
    netto-for-sub-d = netto-for-sub-d + ub.chk-gds.src-sum
    .
  end. /*doe*/

end procedure. /* proc-inv */

{ str/getncrpy.i }