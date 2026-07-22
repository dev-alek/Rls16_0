block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dcpcuq1.p $
$Archive: utl/dcpcuq1.p $

Расчет скидки или категории согласно накопитекльному алгоритма по ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/18/05
Author: Bakhtadze Natalya
Creation date: 11/18/05

*/

define input parameter parparentproc    as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle     as handle no-undo .
define input parameter p-cre-db-num     as integer      no-undo .
define input parameter p-task-type      as character    no-undo.
define input parameter p-task-num       as integer      no-undo.
define input parameter p-db-num         as integer      no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dcpcuq1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/dcpcuq1.p $":U .
define variable vss-description as character no-undo init "Расчет скидки или категории согласно накопительному алгоритму по ДК".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ adm/auto-def.i    }
{ ref/shd-attr.i    }
{ gbl/cur-time.i }
{ cmp/dc-list.i dc-list def }
{ gbl/updtruls.i "NEW SHARED" }
{ rul/calldscr.i }
{ ref/tmpchgs.i  }
{ rul/tempcont.i }

define variable v-counter                   as integer      no-undo.
define variable v-param-list                as character    no-undo.
define variable v-param-type                as character    no-undo.
define variable v-host-code                 as integer      no-undo.
define variable v-parameter                 as character    no-undo .
define variable glog        as logical   no-undo .
define variable ii          as integer   no-undo .
define variable v-entry     as character no-undo .
define variable v-curr-r-b  as character no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-can-calc as character no-undo .
define variable v-for-what as character no-undo .
define variable v-sum-id  as character no-undo .
define variable v-current-d-card as character no-undo .


DEFINE VARIABLE v-algo-field-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-update-mode AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-dc-list-mode AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-dc-type-list-mode AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-dc-type-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-dc-type-algo-list AS CHARACTER NO-UNDO.
define variable v-db-num like ub.db.db-num no-undo .
define variable v-num-rec-value-err as integer no-undo .

define buffer buf_dis-card-type for ub.dis-card-type.
define buffer buf_dis-card for ub.dis-card.
DEFINE TEMP-TABLE sample NO-UNDO LIKE ub.rule-by-call.
define temp-table tt0-rule-by-call no-undo like ub.rule-by-call
field num-rec as integer
field num-rec-calc-err as integer
field num-rec-value-err as integer
field num-rec-ok as integer
field num-rec-new as integer
field num-rec-calc-err-new as integer
field num-rec-value-err-new as integer
field num-rec-ok-new as integer

 .
define buffer buf_tt0-rule-by-call for tt0-rule-by-call.
define buffer buf2_tt0-rule-by-call for tt0-rule-by-call.



{ utl/uclcdcft.i }



do
on error undo, return error return-value
:

  &scop display-message    run write-log-and-file in p-log-handle (  ~
        input 1                                                      ~
      , input log-file-name                                          ~
      , input 1                                                      ~
      , input ~{&my-message~})


  &scop display-counter    run show-counter in p-log-handle .       ~
        run write-counter in p-log-handle ( input ~{&my-message}) no-error



  assign
  log-file-name = "shd-free.log".


  run get-db-num in parparentproc (output v-db-num) no-error .
  if v-db-num <> 0 then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("!!!Перерасчет накопительных скидок и категорий по ДК возможен только в ГБД")).
   return error.
  end.
  run schedule-attr-value in this-procedure (
        input p-cre-db-num
      , input p-task-type
      , input p-task-num
      , input {&attr-schedule-param-list-h}
      , output v-param-list
      , output v-param-type
  ).
  if v-param-list = "":U then do:

&scop my-message   substitute("!!!Не заданы параметры расчета скидки или категории согласно накопительному алгоритма по ДК в задаче &1&2" ~
                                    , p-task-num                                                                       ~
                                    , ~{&new-line~})

      {&display-message}.
      return.
  end.
  assign
  v-dc-list-mode = entry(1, v-param-list, {&delim-par})
  v-update-mode = entry(2, v-param-list, {&delim-par})
  v-dc-type-list-mode = entry(3, v-param-list, {&delim-par})
  v-dc-type-list = entry(4, v-param-list, {&delim-par})
  v-dc-type-algo-list = entry(5, v-param-list, {&delim-par})
  no-error
  .
  if error-status :error then do:
&scop my-message substitute("!!!Ошибки при получении параметров расчета&1" +  ~
                          "&2&1&3&1"                                                ~
                          , error-status:get-message(1)                             ~
                          , return-value )
    {&display-message}.
  end.
  /*вывыдем данные о параметрах*/
&scop my-message substitute("Пересчет скидок и категорий по дисконтным картам в соответствии с накопительными алгоритмами&1" +  ~
                            "Отбор дисконтных карт: &2&1" + ~
                            "Режим работы: &3&1" + ~
                            "Отбор типов дисконтных карт: &4&1" + ~
                            "Отбор итогов для пересчета или проверки: &5"  ~
                          , ~{&new-line~}  ~
                          , (if v-dc-list-mode = "LIST" then "по списку карт" else "все карты, подлежащие расчету по алгоритму") ~
                          , (if v-update-mode = "update" then "ПЕРЕСЧЕТ" else "ПРОВЕРКА") ~
                          , (if v-dc-type-list-mode = "*" then "ВСЕ ТИПЫ" else ("ПО СПИСКУ" + {&space-char} + v-dc-type-list )) ~
                          , (if v-dc-type-algo-list = "" then "ВСЕ АЛГОРИТМЫ" else "ВЫБРАННЫЕ АЛГОРИТМЫ"))

    {&display-message}.



  { gbl/curr-r-b.i v-curr-r-b }

  IF v-dc-type-list-mode = "LIST"
  AND v-dc-type-list = '':u  then do:
&scop my-message substitute("!!!Не задан список типов ДК&1", ~{&new-line~})
    {&display-message}.
    return .

  end.
  /*
  IF v-dc-type-list-mode = "*"
  AND v-dc-type-algo-list = '':u
  then do:

&scop my-message substitute("!!!Не задан список частных или общих итогов&1", ~{&new-line~})

    {&display-message}.

  end.
  */
  IF v-dc-list-mode = "LIST"
  AND NOT CAN-FIND(FIRST dc-list) then do:
&scop my-message substitute("!!!Не задан список ДК&1", ~{&new-line~})

    {&display-message}.
    return error.
  END.

  /*сначала заполним список алгоритмов*/

  run fill-table in this-procedure (
                                     input v-dc-type-list-mode
                                    ,input v-dc-type-list
                                    ,input yes ).


  _buf_tt0-rule-by-call:
  for each buf_tt0-rule-by-call,
      first buf_dis-card-type where
            buf_dis-card-type.uniq-key-rec = buf_tt0-rule-by-call.call_id
  break
  by buf_tt0-rule-by-call.call_id:
    if first-of(buf_tt0-rule-by-call.call_id) then do:
      v-current-d-card = "".
      if v-dc-type-list-mode <> "*"
      and lookup(buf_dis-card-type.type, v-dc-type-list) = 0 then NEXT _buf_tt0-rule-by-call.
      do while v-current-d-card < "Z":
        v-num-rec-value-err = 0.
        run str/saledc.p ( input parparentproc
                    , input this-procedure:handle /*p-parent-handle*/
                    , input p-log-handle
                    , input {&dct-proc_batch-card-recalc}
                    , input ? /*p-emitent-host-code*/
                    , input "" /*p-type*/
                    , input 0 /*p-profile-id*/
                    , input 0 /*p-codex-id*/
                    , input 0 /*p-ruleset-id*/
                    , input g#db-num
                    , input buf_dis-card-type.uniq-key-rec
                    , input ? /*doc-date - выставим внутри*/
                    , input ? /*fact-date - выставим внутри*/
                    , input ? /*cre-pay*/
                    , input 1 /*p-sign*/
                    , input 1 /* p-direction */
                    , input (v-update-mode = "update") /*p-save*/
                    ) no-error .
        if error-status :error then do:
          undo, return error return-value.
        end.
        for each buf2_tt0-rule-by-call:
          assign
          buf2_tt0-rule-by-call.num-rec           = buf2_tt0-rule-by-call.num-rec + buf2_tt0-rule-by-call.num-rec-new
          buf2_tt0-rule-by-call.num-rec-new       = 0
          buf2_tt0-rule-by-call.num-rec-calc-err  = buf2_tt0-rule-by-call.num-rec-calc-err + buf2_tt0-rule-by-call.num-rec-calc-err-new
          buf2_tt0-rule-by-call.num-rec-calc-err-new = 0
          buf2_tt0-rule-by-call.num-rec-value-err = buf2_tt0-rule-by-call.num-rec-value-err + buf2_tt0-rule-by-call.num-rec-value-err-new
          buf2_tt0-rule-by-call.num-rec-value-err-new = 0
          buf2_tt0-rule-by-call.num-rec-ok        = buf2_tt0-rule-by-call.num-rec-ok  + buf2_tt0-rule-by-call.num-rec-ok-new
          buf2_tt0-rule-by-call.num-rec-ok-new = 0
          .
        end.
      end. /*do while v-current-d-card < "Z":*/
    end.
  end. /* for each buf_tt0-rule-by-call,*/
run tempcont_clear in this-procedure no-error.

&scop my-message substitute("Завершен расчет&1", ~{&new-line~})
   {&display-message}.
end. /*doe*/


procedure is-to-create-d-card :
define input parameter p-d-card as character no-undo .
define output parameter p-create-chr as character no-undo .
  do
  on error undo, return error
  :
     if v-dc-list-mode = "all":U then do:
       p-create-chr = "*".
     end.
     else do:
       find first dc-list no-lock where
                  dc-list.d-card = p-d-card no-error.
       if not available dc-list then do:
         p-create-chr = string(no).
       end.
       else do:
         p-create-chr = string(yes).
       end.
     end.
  end.
end procedure. /* is-to-create-d-card */

procedure is-to-calc-algo :
define input parameter p-uniq-key-rec as character no-undo .
define output parameter p-calc-chr as character no-undo .

do
on error undo, return error
:
  if v-dc-type-algo-list = '':U then do:
    p-calc-chr = '*':U.
  end.
  else do:
    p-calc-chr = string(lookup(p-uniq-key-rec, v-dc-type-algo-list) > 0).
  end.
end.

end procedure. /* is-to-calc-algo */

procedure set-current-d-card :
define input parameter p-current-d-card as character no-undo .

  do
  on error undo, return error
  :
     v-current-d-card = p-current-d-card.
  end.

end procedure. /* set-current-d-card */

procedure get-current-d-card :
define output parameter p-current-d-card as character no-undo .

  do
  on error undo, return error
  :
    p-current-d-card = v-current-d-card.
  end.

end procedure. /* get-current-d-card */


procedure set-num-rec :
define input parameter p-num-rec as integer no-undo .
define input parameter p-num-rec-calc-err as integer no-undo .
define input parameter p-num-rec-value-err as integer no-undo .
define input parameter p-num-rec-ok as integer no-undo .
define parameter buffer buf_rule-by-call for ub.rule-by-call.
define input parameter p-display as logical no-undo .

define buffer buf_temp-changes for temp-changes.
define buffer buf_temp-tables for temp-tables.
define buffer buf_tt0-rule-by-call for tt0-rule-by-call.

  do
  on error undo, return error
  :
    for each buf_temp-changes
    break
    by buf_temp-changes.uniq-key-rec
    by buf_temp-changes.f_name
    :
      if first-of(buf_temp-changes.uniq-key-rec) then do:
        assign
        v-num-rec-value-err = v-num-rec-value-err + 1
        p-num-rec-ok = p-num-rec-ok - 1
        .
      end.
      if buf_temp-changes.uniq-key-rec begins {&table_dis-card} then do:

  &scop my-message substitute("&1:&5" +  ~
                            "старое значение &2 = &3&5" +  ~
                            "новое значение  &2 = &4" ~
                            , calldscr(buf_temp-changes.uniq-key-rec)   ~
                            , (if buf_temp-changes.t_name = ~{&table_dis-card-property~} then '' else  buf_temp-changes.f_name) ~
                            , buf_temp-changes.v_old  ~
                            , buf_temp-changes.v_new  ~
                            , ~{&new-line~})

            {&display-message}.
      end.
      delete buf_temp-changes.
    end. /*if buf_temp-changes.uniq-key-rec begins {&table_dis-card} then do:*/
    if p-display = yes then do:
      tempcont_v-num_ = 0.
      run hide-counter in p-log-handle.
    end.
    find first buf_tt0-rule-by-call where
              buf_tt0-rule-by-call.call_id = buf_rule-by-call.call_id
         and  buf_tt0-rule-by-call.codex_id = buf_rule-by-call.codex_id
         and  buf_tt0-rule-by-call.ruleset_id = buf_rule-by-call.ruleset_id
         and  buf_tt0-rule-by-call.order_id = buf_rule-by-call.order_id no-error.
    if available buf_tt0-rule-by-call then do:
      assign
      buf_tt0-rule-by-call.num-rec-new = p-num-rec
      buf_tt0-rule-by-call.num-rec-calc-err-new = p-num-rec-calc-err
      buf_tt0-rule-by-call.num-rec-value-err-new = v-num-rec-value-err
      buf_tt0-rule-by-call.num-rec-ok-new = p-num-rec-ok
      .
      if p-display then do:
&scop my-message substitute("&2---------------------Просмотрено карт - &1&2" +  ~
                            "---------------------Ошибок при расчете - &3&2" +  ~
                            (if v-update-mode = "update" ~
                            then                         ~
                            "---------------------Пересчитано - &4&2"   ~
                            else                                              ~
                            "---------------------Значений для пересчета - &4&2") + ~
                            "---------------------Значений не подлежащих пересчету - &5" ~
                            , buf_tt0-rule-by-call.num-rec  + buf_tt0-rule-by-call.num-rec-new  ~
                            , ~{&new-line~}                                        ~
                            , buf_tt0-rule-by-call.num-rec-calc-err + buf_tt0-rule-by-call.num-rec-calc-err-new   ~
                            ,  buf_tt0-rule-by-call.num-rec-value-err + buf_tt0-rule-by-call.num-rec-value-err-new  ~
                            , ((buf_tt0-rule-by-call.num-rec-ok + buf_tt0-rule-by-call.num-rec-ok-new)             ~
                              - (buf_tt0-rule-by-call.num-rec-value-err + buf_tt0-rule-by-call.num-rec-value-err-new )) ~
                            )

        {&display-message}.

      end. /*if p-display then do:*/
      else do:
&scop my-message substitute("Просмотрено карт - &1", buf_tt0-rule-by-call.num-rec  + buf_tt0-rule-by-call.num-rec-new)

        {&display-counter}.
      end.
    end.
  end.

end procedure. /* set-num-rec */