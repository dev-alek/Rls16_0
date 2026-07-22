/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Пересылка скидки на итог на кассу

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/02/05
Author: Bakhtadze Natalya
Creation date: 12/02/05

*/
block-level on error undo, throw.

define input parameter parparentproc    as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle     as handle no-undo .
define input parameter p-parameter      as character no-undo .

/*
p-parameter включает
define input parameter i-obj-code like shop.obj-code no-undo.
DEFINE INPUT PARAMETER action as char no-undo.
*/


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Пересылка скидки на итог на кассу".
{ cmp/vssrevis.i }


{ cmp/trg-def.i }
define variable i-obj-code like ub.clients.obj-code no-undo .
define variable action as char no-undo.
define variable p-what-send as character no-undo .
{ bge/bgelib.i }
{ str/cd-xml.i }
{ str/cdsnddef.i }
{ gbl/disrules.i work }
{ str/defcncrd.i }
{ gbl/disrules.i cash-desk }
{ gbl/getcntxt.i def }

/*вспомогат*/
define variable conf-attr as character no-undo .
define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable dflt-cd as character no-undo .
/*счетчик записей текущего пакета категорийных скидок NCR*/
define variable cr-ncr-dis-kat               as integer       no-undo .
/*гдк хранить файлы неприкосоновеннхы ручнхы настроек может быть no TH NCR*/
define variable ncr-save-param               as character         no-undo init 'no'.

define variable v-upper-rule-num-tot-discnt like ub.dis-rule.upper-rule-num no-undo .
define variable v-upper-rule-num-tot-discnt-kat like ub.dis-rule.upper-rule-num no-undo .
define variable v-template-list-tot-discnt as character no-undo .
define variable v-template-list-gds as character no-undo .
define variable v-template-list-group as character no-undo .
define variable v-template-list-payment as character no-undo .
define variable v-template-list-client as character no-undo .
define variable v-record as character no-undo .
define variable dr-list as character no-undo .

define stream plucash.
define stream bar.
define buffer lock-batchprocess for ub.batchprocess .
{ gbl/getcntxt.i get }

/*разнящийся вывод для разных типов касс*/
{ str/putc-9.i }
{ str/putctodr.i }
{ str/putcgddr.i }
{ str/putcgrdr.i }
{ str/putcpmdr.i }
{ str/putccldr.i }


/*PROCEDURE for-cash-cycle*/
/*пройдем цикл по всем кассам одного типа*/
{ str/cd-cycl9.i }

/*PROCEDURE SENDING.*/
{ str/cd-sen9.i }

do on error undo, throw:
assign
i-obj-code = integer(entry(1, p-parameter, {&delim-par}))
action = entry(2, p-parameter, {&delim-par})
p-what-send = entry(3, p-parameter, {&delim-par})
no-error
.
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2&3"
                         , p-parameter
                         , {&new-line}
                         , error-status:get-message(1)
                         )).
  v-view-log = yes.
  undo, return error .
end .


{ gbl/hostcode.i
  {&shop}
  i-obj-code
  v-host-code
}

if not g#news
and not g#auto
then do:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_cashdesk-discnt-total_add-def':U
    {&cntxt-object}
    v-host-code
    {&shop}
    i-obj-code
    0
    0
    0
    true
    glog
  }

  if NOT glog then return .
end.

{ gbl/dflt-cd.i {&shop} i-obj-code dflt-cd }
if p-what-send = 'ALL'
or p-what-send = 'tot-discnt' then do:
  run prepare-tot-discnt in this-procedure (
                                            output v-template-list-tot-discnt ) .
  if dflt-cd = {&cd-type-ibm} then do:
    if v-upper-rule-num-tot-discnt <> 0 then do:
      find first cash-dis-rule where
        cash-dis-rule.rule-num = v-upper-rule-num-tot-discnt no-error.
      if available cash-dis-rule
      and cash-dis-rule.templ-rl-root = 53 then do:
        v-upper-rule-num-tot-discnt-kat = v-upper-rule-num-tot-discnt.
        v-upper-rule-num-tot-discnt = 0.
      end.
    end.
  end.
end.
if p-what-send = 'ALL'
or p-what-send = 'gds-discnt' then do:
  run prepare-gds-discnt in this-procedure ( output v-template-list-gds ) .
end.
if p-what-send = 'ALL'
or p-what-send = 'group-discnt' then do:
  run prepare-group-discnt in this-procedure ( output v-template-list-group ) .
end.
if p-what-send = 'ALL'
or p-what-send = 'payment-discnt' then do:
  run prepare-payment-discnt in this-procedure ( output v-template-list-payment) .
end.
if p-what-send = 'ALL'
or p-what-send = 'client-discnt' then do:
  run prepare-client-discnt in this-procedure ( output v-template-list-client ).
end.
if action = "D":U
or (v-upper-rule-num-tot-discnt <> 0
   and
   (p-what-send = 'all'
    or
    p-what-send = 'tot-discnt')
  )
or can-find(first cash-dis-rule)
then do:
  RUN SENDING in this-procedure no-error.
  if error-status:error then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!Ошибки при отсылке правил скидок на кассы  маг&1"
                          , i-obj-code
                          )
                                          ).

    assign
    v-view-log = yes
    .
    if g#news then return error .
  end.
end.

  finally :
{ str/cdviewlg.i
"'!!!При отсылке информации на кассы произошли ошибки!!!'"
log-file-name not-delete }

    run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("&1", {&new-line})
    ).
    define variable v-save-file-name as character no-undo .
    v-save-file-name = substitute("&1send-cd.log", ibs.th.gbl.gbl-inipar:logDir) .
    OS-APPEND value(log-file-name) value(v-save-file-name).
    OS-DELETE value(log-file-name).
  end finally .
end. /* end_of doe */
{ str/defcncrd.i proc-create no-gds }


procedure prepare-tot-discnt :
define output parameter p-template-list-tot-discnt as character no-undo .
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
  do
  on error undo, return error
  :
    for each buf_dis-cfg-rule no-lock where
            buf_Dis-cfg-rule.table-name = {&table_dis-thbj-rule}
       and buf_Dis-cfg-rule.pos-type = dflt-cd
       and buf_dis-cfg-rule.discnt-role = {&dthbjr-pcnt-tot-kateg}:
      if buf_dis-cfg-rule.link-prop  = integer({&dr-appl-object})
      and lookup(string(buf_Dis-cfg-rule.templ-rl-root), p-template-list-tot-discnt) = 0
      then do:
        assign
        p-template-list-tot-discnt = p-template-list-tot-discnt +
                                    (if p-template-list-tot-discnt = '':U
                                    then '':U
                                    else {&comma-char}) +
                                    string(buf_Dis-cfg-rule.templ-rl-root).
      end.
    end.
    if p-template-list-tot-discnt = '':U then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("Для маг&1 тип кассы по умолчанию &2 - скидки на итог чека не отправляются"
                            , i-obj-code
                            , dflt-cd
                            )
                                          ).
      return.
    end.
    run create-dis-rule-by-template in this-procedure ( input {&dthbjr-pcnt-tot-kateg}
                                                       ,input p-template-list-tot-discnt
                                                       ,input "на итог чека" ) .
  end.

end procedure. /* prepare-tot-discnt */

procedure prepare-gds-discnt :
define output parameter p-template-list-gds as character no-undo .

  do
  on error undo, return error
  :
    CASE dflt-cd:
      when {&cd-type-maria} then do:
        assign
        p-template-list-gds = string(1) + {&comma-char} +
                          string(2) + {&comma-char} +
                          string(38) + {&comma-char} +
                          string(39).
      end.
      when {&cd-type-ncr-gm}
      or
      when {&cd-type-ncr-as-r}
      then do:
        assign
        p-template-list-gds = string(26) + {&comma-char} +
                          string(33)
        .
      end.
      otherwise do:
        if p-what-send <> 'ALL' then
        run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("Для маг&1 тип кассы по умолчанию &2 - правила скидок на товар не отправляются"
                                , i-obj-code
                                , dflt-cd
                                )
                                              ).
        return.
      end.
    END CASE.
    run create-dis-rule-by-template in this-procedure ( input {&table_dis-gds-rule}
                                                       ,input p-template-list-gds
                                                       ,input "на товар" ) .
  end.
end procedure. /* prepare-gds-discnt */

procedure prepare-group-discnt :
define output parameter p-template-list-group as character no-undo .

  do
  on error undo, return error
  :
    CASE dflt-cd:
      when {&cd-type-maria} then do:
        assign
        p-template-list-group = string(46) + {&comma-char} +
                          string(47) + {&comma-char} +
                          string(48) + {&comma-char} +
                          string(49).
      end.
      otherwise do:
        if p-what-send <> 'ALL' then
        run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("Для маг&1 тип кассы по умолчанию &2 - правила скидок на группы товара не отправляются"
                                , i-obj-code
                                , dflt-cd
                                )
                                              ).
        return.
      end.
    END CASE.
    run create-dis-rule-by-template in this-procedure ( input 'group':U
                                                       ,input p-template-list-group
                                                       ,input "на группу товара" ) .
  end. /*doe*/
end procedure. /* prepare-group-discnt */

procedure prepare-payment-discnt :
define output parameter p-template-list-payment as character no-undo .

  do
  on error undo, return error
  :
    CASE dflt-cd:
      when {&cd-type-maria} then do:
        assign
        p-template-list-payment = string(42) + {&comma-char} +
                          string(43) + {&comma-char} +
                          string(44) + {&comma-char} +
                          string(45).
      end.
      otherwise do:
        if p-what-send <> 'ALL' then
        run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("Для маг&1 тип кассы по умолчанию &2 - правила скидок на платеж не отправляются"
                                , i-obj-code
                                , dflt-cd
                                )
                                              ).
        return.
      end.
    END CASE.
    run create-dis-rule-by-template in this-procedure ( input 'payment':U
                                                       ,input p-template-list-payment
                                                       ,input "на платеж") .
  end.
end procedure. /* prepare-payment-discnt */

procedure prepare-client-discnt :
define output parameter p-template-list-client as character no-undo .

  do
  on error undo, return error
  :
    CASE dflt-cd:
      when {&cd-type-maria} then do:
        assign
        p-template-list-client = string(11) + {&comma-char} +
                          string(12) + {&comma-char} +
                          string(40) + {&comma-char} +
                          string(41)
                          .
      end.
      otherwise do:
        if p-what-send <> 'ALL' then
        run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("Для маг&1 тип кассы по умолчанию &2 - правила скидок для пост. клиентов не отправляются"
                                , i-obj-code
                                , dflt-cd
                                )
                                              ).
      end.
    END CASE.
    run create-dis-rule-by-template in this-procedure ( input 'client'
                                                      , input p-template-list-client
                                                      , input "для пост. клиентов" ) .
  end.
end procedure. /* prepare-client-discnt */


procedure create-dis-rule-by-template :
define input parameter p-what-create as character no-undo .
define input parameter p-template-list as character no-undo .
define input parameter p-discnt-des as character no-undo .
define variable v-ii as integer no-undo .
define variable ll as integer no-undo .
define variable vc-obj-type like ub.clients.obj-type no-undo .
define variable vc-obj-code like ub.clients.obj-code no-undo .
define variable vc-host-code like ub.sysconf.host-code no-undo .
define variable vc-region as character no-undo .
define variable v-des     as character no-undo .
define variable  v-level-1           as character no-undo .
define variable  v-level-2           as character no-undo .
define variable  v-discnt-type       like ub.dis-rule.discnt-type       no-undo .
define variable  v-subject-type      like ub.dis-rule.subject-type      no-undo .
define variable  v-value-type        like ub.dis-rule.value-type        no-undo .
define variable  v-global            as integer no-undo .
define variable  v-host              as integer no-undo .
define variable  v-object            as integer no-undo .
define variable  v-output-display    as logical   no-undo . /* виден в броусе статус 0*/
define variable  v-tree              as character no-undo .
define variable  v-other             as character no-undo . /* еще чего - нибудь */
define variable  v-not-found         as integer no-undo .


define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_dis-thbj-rule for ub.dis-thbj-rule.
define buffer buf_cash-dis-rule for cash-dis-rule.
  do
  on error undo, return error return-value
  :
    if p-template-list = '':U then return.
    _v-ii:
    do v-ii = 1 to num-entries(p-template-list):
      /*получим параметры ШАБЛОНА в смылсе его использования по уровням контекста*/
      run dr-code  in this-procedure (
                                          input  integer(entry(v-ii, p-template-list))
                                          ,output v-des
                                          ,output v-discnt-type
                                          ,output v-subject-type
                                          ,output v-value-type
                                          ,output v-level-1
                                          ,output v-level-2
                                          ,output v-global
                                          ,output v-host
                                          ,output v-object
                                          ,output v-output-display
                                          ,output v-tree
                                          ,output v-other).
      _ll:
      do ll = 1 to 3:
        CASE ll:
          when 1 then do:
            if v-object = 0 then next _ll.
            assign
            vc-obj-code = i-obj-code
            vc-obj-type = {&shop}
            vc-host-code = v-host-code
            vc-region    = substitute("&1&2", vc-obj-type, vc-obj-code)
            .
          end.
          when 2 then do:
            if v-host = 0 then next _ll.
            assign
            vc-obj-code = 0
            vc-obj-type = '':U
            vc-host-code = v-host-code
            vc-region    = substitute("Фирма &1&2", vc-host-code)
            .
          end.
          when 3 then do:
            if v-global = 0 then next _ll.
            assign
            vc-obj-code = 0
            vc-obj-type = '':U
            vc-host-code = 0
            vc-region    = "Глобально"
            .
          end.
        END CASE.
        if p-what-create = {&dthbjr-pcnt-tot-kateg}
        then do:
          _buf_dis-rule:
          for each buf_dis-rule no-lock where
                        buf_dis-rule.upper-rule-num = integer(entry(v-ii, p-template-list))
                    and buf_dis-rule.host-code = vc-host-code
                    AND buf_dis-rule.obj-type = vc-obj-type
                    AND buf_dis-rule.obj-code = vc-obj-code
                    AND buf_dis-rule.sts = integer({&current-status-int}),
          first buf_dis-thbj-rule no-lock where
                buf_dis-thbj-rule.host-code = vc-host-code
            and buf_dis-thbj-rule.obj-type = vc-obj-type
            and buf_dis-thbj-rule.obj-code = vc-obj-code
            and buf_dis-thbj-rule.pos-type = dflt-cd
            and buf_dis-thbj-rule.discnt-role = {&dthbjr-pcnt-tot-kateg}
            and buf_dis-thbj-rule.rule-num = buf_dis-rule.rule-num
          :
            /*тут надо фильтровать правила по приоритету*/
            find first buf_cash-dis-rule no-lock where ll > 1
              and buf_cash-dis-rule.dis-kat            = buf_dis-rule.dis-kat
              and buf_cash-dis-rule.templ-rl-root      = buf_dis-rule.templ-rl-root
              and buf_cash-dis-rule.time-templ-rl-root = buf_dis-rule.time-templ-rl-root no-error .
            if avail buf_cash-dis-rule then next _buf_dis-rule .

            run create-dis-rule in this-procedure ( buf_dis-rule.rule-num, yes) no-error .
            if p-what-create = {&dthbjr-pcnt-tot-kateg} then do:
              if lookup("dis-kat", v-level-1) = 0 then do:
                if v-upper-rule-num-tot-discnt = 0 then
                assign
                v-upper-rule-num-tot-discnt = buf_dis-rule.rule-num
                .
              end.
              else do:
                if v-upper-rule-num-tot-discnt-kat = 0 then
                assign
                v-upper-rule-num-tot-discnt-kat = (if buf_Dis-rule.is-term = yes
                                                   then buf_dis-rule.upper-rule-num
                                                   else buf_dis-rule.rule-num)
                .
              end.
            end.
            /*next _v-ii.*/
          end.
          if action = "U" then do:
            if (ll = 1 and v-host = 0 and v-global = 0)
            or (ll = 2 and v-object = 0 and v-global = 0)
            or (ll = 3 and v-object = 0 and v-host = 0) then do:
              assign
              v-not-found = v-not-found + 1.
            end.
          end.
        end. /*if p-what-create = {&dthbjr-pcnt-tot-kateg}*/
        else do:
          for each buf_dis-rule no-lock where
                  buf_dis-rule.templ-rl-root = integer(entry(v-ii, p-template-list))
            and  buf_dis-rule.host-code = vc-host-code
            and  buf_dis-rule.obj-type = vc-obj-type
            and  buf_dis-rule.obj-code = vc-obj-code:
            if action = 'U':U and buf_dis-rule.sts <> integer({&used-status-int}) then next.
            run create-dis-rule in this-procedure ( buf_dis-rule.rule-num, yes) no-error .
            if p-what-create = 'tot-discnt' then do:
              if lookup("dis-kat", v-level-1) = 0 then do:
                if v-upper-rule-num-tot-discnt = 0 then
                assign
                v-upper-rule-num-tot-discnt = buf_dis-rule.rule-num
                .
              end.
              else do:
                if v-upper-rule-num-tot-discnt-kat = 0 then
                assign
                v-upper-rule-num-tot-discnt-kat = buf_dis-rule.upper-rule-num
                .
              end.
            end.
          end. /*for each buf_dis-rule no-lock where*/
          if not can-find(first cash-dis-rule where cash-dis-rule.upper-rule-num = integer(entry(v-ii, p-template-list)) ) then do:
            if (ll = 1 and v-host = 0 and v-global = 0)
            or (ll = 2 and v-object = 0 and v-global = 0)
            or (ll = 3 and v-object = 0 and v-host = 0) then do:
              assign
              v-not-found = v-not-found + 1.
            end.
          end.
          else do:
            LEAVE _ll.
          end.
        end.
      end. /*do ll*/
    end. /*do v-ii*/
    if v-not-found = num-entries(p-template-list) then do:
            run write-log-and-file in p-log-handle (
                    input 1
                  , input log-file-name
                  , input 1
                  , input substitute("Для маг&1 не определены скидки &2"
                                    , i-obj-code
                                    , p-discnt-des
                                    )
                                                  ).
    end.
  end. /*doe*/

end procedure. /* create-dis-rule-by-template */

/*пересылка моделей скидок*/
procedure putc-dr-maria :
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-template-list as character no-undo .
define variable v-ii  as  integer     no-undo.
define variable v-maria-rule-num as integer no-undo .
define variable v-dop as character no-undo .
define variable v-string as character no-undo .
define variable v-maria-rule-type as integer no-undo .
define variable v-bush as integer no-undo .
define buffer down_cash-dis-rule for cash-dis-rule.

  do
  on error undo, return error:
    do v-ii = 1 to num-entries(p-template-list):
      for each cash-dis-rule where
              cash-dis-rule.templ-rl-root = integer(entry( v-ii, p-template-list))
        and  cash-dis-rule.upper-rule-num = integer(entry( v-ii, p-template-list)):
        v-bush = 0.
        if index(dr-list, string(cash-dis-rule.rule-num) + '-') = 0 then do:
          next.
        end.
        assign
        v-dop = substring(dr-list, index(dr-list, string(cash-dis-rule.rule-num) + '-':U))
        v-dop = substring(v-dop, 1, index(v-dop, {&comma-char}) - 1)
        v-maria-rule-num = integer(entry(2, v-dop, '-':U)) - 1
        .
        if action = 'D':U  then do:
          assign
          v-string  = fill( {&space-char} , 12) + {&delim-par} +
                      '0' + {&delim-par} +
                      '000' + {&delim-par} +
                      '00000' + {&delim-par} +
                      fill(fill('0', 9) + {&delim-par} + fill('0', 5) + {&delim-par} , 5) +
                      fill(fill('0', 9) + {&delim-par} + fill('0', 5) + {&delim-par} , 5)
         .
        end.
        else do:
          if cash-dis-rule.value-type = integer({&discnt-v-pcnt}) then do:
            if index(cash-dis-rule.uniq-field, 'tot-sum') = 0
            and index(cash-dis-rule.uniq-field, 'doc-qnty') = 0 then do:
              assign
              v-maria-rule-type = 0.
            end.
            if index(cash-dis-rule.uniq-field, 'tot-sum') > 0
            then do:
              assign
              v-maria-rule-type = 1.
            end.
            if index(cash-dis-rule.uniq-field, 'doc-qnty') > 0
            then do:
              assign
              v-maria-rule-type = 2.
            end.
          end.
          if cash-dis-rule.value-type = integer({&discnt-v-abs}) then do:
            assign
            v-maria-rule-type = 3.
          end.
          assign
          v-string =  string(cash-dis-rule.des, "X(12)") + {&delim-par} +
                      string(v-maria-rule-type, '999') + {&delim-par} +
                      (if v-maria-rule-type = 3
                      then string( cash-dis-rule.discnt-value * 100, '999')
                      else '000') + {&delim-par} +
                      (if v-maria-rule-type = 0
                      then string( cash-dis-rule.discnt-value * 100, '99999')
                      else '00000') + {&delim-par}.
          if v-maria-rule-type = 0
          or v-maria-rule-type = 3 then do:
            assign
            v-string = v-string +
                        fill(fill('0', 9) + {&delim-par} + fill('0', 5) + {&delim-par} , 5) +
                        fill(fill('0', 9) + {&delim-par} + fill('0', 5) + {&delim-par} , 5)
            .
          end.
          else do:
            if v-maria-rule-type = 2 then do:
              v-string = v-string + fill(fill('0', 9) + {&delim-par} + fill('0', 5) + {&delim-par} , 5).
            end.
            for each down_cash-dis-rule where
                  down_cash-dis-rule.upper-rule-num = cash-dis-rule.rule-num:
              assign
              v-bush = v-bush + 1.
              if v-maria-rule-type = 1 then do:
                assign
                v-string = v-string + string(down_cash-dis-rule.tot-sum * 100, '999999999') + {&delim-par} +
                                      string(down_cash-dis-rule.discnt-value * 100, '99999') + {&delim-par}.
              end.
              if v-maria-rule-type = 2 then do:
                assign
                v-string = v-string + string(down_cash-dis-rule.doc-qnty * 100, '999999999') + {&delim-par} +
                                      string(down_cash-dis-rule.discnt-value * 100, '99999') + {&delim-par}.
              end.
            end.
            if v-bush  < 5 then do:
               v-string = v-string + fill(fill('0', 9) + {&delim-par} + fill('0', 5) + {&delim-par} , 5 - v-bush).
            end.
            if v-maria-rule-type = 1 then do:
              v-string = v-string + fill(fill('0', 9) + {&delim-par} + fill('0', 5) + {&delim-par} , 5).
            end.
          end.
        end. /*не D*/
        assign
        v-string = right-trim(v-string, {&delim-par}).
        run maria-put in this-procedure (
                                        buffer buf_cash-desk
                                      , input out
                                      , input fname
                                      , input yes
                                      , input 0
                                      , input no
                                      , input 25
                                      , input 20
                                      , input v-maria-rule-num + 1
                                      , input v-string ).
      end. /*for each cash-dis-rule*/
    end. /*do v-ii = 1 to num-entries(v-template-list-gds):*/


  end.

end procedure. /* putc-dr-maria */