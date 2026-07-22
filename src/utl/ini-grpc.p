block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ini-grpc.p $
$Archive: utl/ini-grpc.p $

инициализация поля СПОСОБ РАСЧЕТА в gds-grp

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/08/05
Author: Bakhtadze Natalya
Creation date: 09/08/05

*/


define input parameter par-calc-method like ub.gds-grp.calc-method no-undo .
/*значение для заполнения поля calc-method*/

define input parameter par-increase-pc like ub.gds-grp.increase-pc no-undo .
/*значение для заполнения поля increase-pc*/

define input parameter par-min like ub.gds-grp.increase-pc no-undo .
/*значение для заполнения поля min*/

define input parameter par-max like ub.gds-grp.increase-pc no-undo .
/*значение для заполнения поля max*/

define input parameter par-round-method as character no-undo .
/*значение для заполнения поля МЕТОД ОКРУГЛЕНИЯ*/

define input parameter par-base as decimal no-undo .
/*значение для заполнения поля КОЭФ ОКРУГЛЕНИЯ*/

define input parameter par-cli-type as character no-undo .
/*значение для заполнения поля тип вн.пост*/

define input parameter par-cli-code as integer no-undo .
/*значение для заполнения поля код вн.пост*/

define input parameter par-fill-method as character no-undo .
/*error-or-space   all   error незапол или неверные-все-неверные*/

define input parameter par-groups as character no-undo .
/*all select select-tree  все группы или выборочно по par-rid-list*/

define input parameter par-values as character no-undo .
/*default group - заданными значениями или из верхней группы*/

define input parameter par-fields as integer no-undo .
/*какие поля заполнять - побитово*/

define input parameter par-region as integer no-undo .
/*обасть действия побитово*/

define input parameter par-rid-list as character no-undo .
/*recid выбраных групп*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ini-grpc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/ini-grpc.p $":U .
define variable vss-description as character no-undo init "Инициализация поля СПОСОБ РАСЧЕТА в gds-grp".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/bitoper.i }
{ ref/grpobj.i }
{ gbl/waitfram.i }


DEFINE VARIABLE ii as integer no-undo .
DEFINE VARIABLE jj as integer no-undo .
define variable kk as integer no-undo .
define variable v-process as logical no-undo .
define variable v-contin as logical no-undo .
define variable v-lvl-num as integer no-undo .
define variable v-node-code like ub.gds-grp.node-code no-undo .
define variable glog as logical no-undo .
define variable v-curr-db-num like ub.db.db-num no-undo .
define buffer upper_gds-grp for ub.gds-grp.


glog = no.

{ gbl/curdbnum.i v-curr-db-num }

if BinMask(par-fields, "XXXX1":U) then do:
  if par-values = "default":U AND
    (par-calc-method = ? or
    par-calc-method = "":U or
    lookup(par-calc-method, {&pr-calc-methods-grp-list}) = 0) then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра" par-calc-method
      view-as alert-box .
      return error .
  end.
end.

if BinMask(par-fields, "XX1XX":U) then do:
  if par-values = "default":U AND
    (par-round-method = ? or
    par-round-method = "":U or
    lookup(par-round-method, {&pr-rounds}) = 0) then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра" par-round-method
      view-as alert-box .
      return error .
  end.
  if par-values = "default":U AND
  lookup(par-round-method,  ({&pr-rounds-need-coef})) > 0 and
  par-base = 0 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение коэффициента 0 для метода округления" par-round-method
    view-as alert-box error .
    return error .
  end.
end.

if v-curr-db-num <> 0 then do:
  message vss-workfile vss-revision vss-description skip
  "Утилиту можно запустить только в ГБД"
  view-as alert-box error .
  return error .
end.
message
"Инициализация полей СПОСОБ РАСЧЕТА,НАЦЕНКА,ДИАПАЗОНЫ НАЦЕНКИ,МЕТОД ОКРУГЛЕНИЯ в ГРУППАХ ТОВАРОВ ?   Вы уверены ?"
view-as alert-box question buttons OK-Cancel update glog.
if glog <> true then return.
message
"Внимание !  Если работа утилиты закончится ненормально"
"(нормально - это сообщение о завершении - все записи успешно обработаны)," skip
"запустите ее сразу же повторно !"
view-as alert-box .

/* разбиваем транзакции, чтоб не переполнять таблицу захватов */
CASE par-values:
  when "default":U then do:
    _group:
    for each ub.gds-grp
    on error undo, next:
      CASE par-groups:
        when "select":U then do:
           if lookup(string(recid(ub.gds-grp)), par-rid-list) = 0 then NEXT _group.
        end.
        when "select-tree" then do:
          assign
          v-contin = yes
          v-node-code = ub.gds-grp.node-code
          .
          do while v-contin:
            run tree-up in this-procedure (input-output v-node-code, output v-contin, output v-process).
          end.
          if not v-process then NEXT _group.
        end.
      END CASE.
      ii = ii + 1.
      run proc-assign in this-procedure
                      (buffer ub.gds-grp,
                      0,
                      "":U,
                      0,
                      par-calc-method,
                      par-increase-pc,
                      par-min,
                      par-max,
                      par-round-method,
                      par-base,
                      par-cli-type ,
                      par-cli-code
                        ) no-error .
      if not error-status:error and return-value <> "error":U then
      jj = jj + 1.
      run waitfram-show in this-procedure ("Обработано" + {&space-char} +
                     string(ii) + {&space-char} +
                     "записей - успешно" + {&space-char} +
                     string(jj)).
    END.
  end.
  when "group":U then do:
    CASE par-groups:
      when "all":U or when "select-tree":U then do:
        find first upper_gds-grp No-LOCK where upper_gds-grp.upper-code = 0.
        assign
        v-lvl-num = upper_gds-grp.lvl-num
        v-node-code= upper_gds-grp.node-code
        .
        do while available upper_gds-grp:
          /*группы 1-го уровня не изменяются*/
          if upper_gds-grp.upper-code <> 0 then
          run ini-tree in this-procedure
                          (
                          input upper_gds-grp.node-code
                          ,input (upper_gds-grp.lvl-num + 1)
                          ,input upper_gds-grp.calc-method
                          ,input upper_gds-grp.increase-pc
                      ).
          find first upper_gds-grp NO-LOCK where
                     upper_gds-grp.lvl-num = v-lvl-num
                 AND upper_gds-grp.node-code > v-node-code no-error .
          if not avail upper_gds-grp then do:
            assign
            v-lvl-num = v-lvl-num + 1
            v-node-code = 0
            .
          end.
          find first upper_gds-grp NO-LOCK where
                     upper_gds-grp.lvl-num = v-lvl-num
                 AND upper_gds-grp.node-code > v-node-code no-error .
          if avail upper_gds-grp then do:
            assign
            v-lvl-num = upper_gds-grp.lvl-num
            v-node-code = upper_gds-grp.node-code
            .
          end.
        end.
      end. /*all*/
      when "select":U then do:
        do kk = 1 to num-entries(par-rid-list):
          find first ub.gds-grp where
                    recid(ub.gds-grp) = integer(entry(kk, par-rid-list)) no-error .
          if avail ub.gds-grp then do:
            find first upper_gds-grp where
                       upper_gds-grp.node-code = ub.gds-grp.upper-code no-error .
             if avail upper_gds-grp then
              run ini-tree  in this-procedure
                            (
                            input upper_gds-grp.node-code
                            ,input (upper_gds-grp.lvl-num + 1)
                            ,input upper_gds-grp.calc-method
                            ,input upper_gds-grp.increase-pc
                        ).
          end.
        end.
      end. /*select*/
    END CASE. /*par-group*/
  end. /*when group*/
END CASE. /*par-values*/

run waitfram-hide in this-procedure .

message
"Работа утилиты завершена" skip
"Обработано" ii "записей"  skip
"успешно" jj
view-as alert-box .


procedure proc-assign :
define parameter buffer buf_gds-grp for ub.gds-grp.
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-calc-method like ub.gds-grp.calc-method no-undo .
define input parameter p-increase-pc like ub.gds-grp.increase-pc no-undo .
define input parameter p-min like ub.gds-grp.increase-pc no-undo .
define input parameter p-max like ub.gds-grp.increase-pc no-undo .
define input parameter p-round-method as character no-undo .
define input parameter p-base as decimal no-undo .
define input parameter p-cli-type like ub.clients.obj-type no-undo .
define input parameter p-cli-code like ub.clients.obj-code no-undo .

define variable v-value as character no-undo .
define variable v-type as character no-undo .
/*переменные текущих значений для группы*/
define variable v-max as decimal no-undo init ?.
define variable v-min as decimal no-undo init ?.
define variable v-incr as decimal no-undo init ? . /*это значение берем из атрибута*/
define variable v-round-method as character no-undo init ?.
define variable v-base as decimal no-undo init ?.
define variable v-rid as recid no-undo .
define variable v-calc-method as character no-undo .
define variable v-increase-pc as decimal no-undo . /*это значение берем из группы*/
define variable v-cli-type as character no-undo .
define variable v-cli-code as integer no-undo .


/*переменные значений которые будут присвоены*/
define variable x_max as decimal no-undo init ?.
define variable x_min as decimal no-undo init ?.
define variable x_incr as decimal no-undo init ? . /*это значение берем из атрибута*/
define variable x_round-method as character no-undo init ?.
define variable x_base as decimal no-undo init ?.
define variable x_rid as recid no-undo .
define variable x_calc-method as character no-undo .
define variable x_increase-pc as decimal no-undo . /*это значение берем из группы*/
define variable x_cli-type as character no-undo .
define variable x_cli-code as integer no-undo .



define variable v-delim as character no-undo .
define variable v-entry as character no-undo extent 4.
define variable ll as integer no-undo .
define variable v-error as logical no-undo .
define variable var-fill-method as character no-undo .

define buffer buf_gds-grp-obj for ub.gds-grp-obj.
define buffer buf_root_gds-grp-obj for ub.gds-grp-obj.

  do
  on error undo, return error
  :
    assign
    var-fill-method = par-fill-method
    .
    /*сначала считаем корневой атрибут*/
    find first buf_root_gds-grp-obj no-lock where
               buf_root_gds-grp-obj.node-code = buf_gds-grp.node-code
           AND buf_root_gds-grp-obj.host-code = 0
           AND buf_root_gds-grp-obj.obj-type = "":U
           AND buf_root_gds-grp-obj.obj-code = 0 no-error .

    if available buf_root_gds-grp-obj then do:
      assign
      v-min           = buf_root_gds-grp-obj.min-increase
      v-max           = buf_root_gds-grp-obj.max-increase
      v-incr          = buf_root_gds-grp-obj.increase-pc
      v-round-method  = buf_root_gds-grp-obj.round-method
      v-base          = buf_root_gds-grp-obj.round-coef
      v-cli-type      = buf_root_gds-grp-obj.cli-type
      v-cli-code      = buf_root_gds-grp-obj.cli-code

      .
    /*берем значением из группы*/
      assign
      v-calc-method = buf_gds-grp.calc-method
      v-increase-pc = buf_gds-grp.increase-pc
      .
      /*обработка какие поля заполнять*/
      assign
      x_cli-type     = if BinMask(par-fields, "1XXXX":U) then p-cli-type else v-cli-type
      x_cli-code     = if BinMask(par-fields, "1XXXX":U) then p-cli-code else v-cli-code
      x_min          = if BinMask(par-fields, "X1XXX":U) then p-Min else v-min
      x_max          = if BinMask(par-fields, "X1XXX":U) then p-Max else v-max
      x_incr         = if BinMask(par-fields, "XXX1X":U) then p-increase-pc else v-incr
      x_round-method = if BinMask(par-fields, "XX1XX":U) then p-round-method else v-round-method
      x_base         = if BinMask(par-fields, "XX1XX":U) then p-base else v-base
      x_calc-method  = if BinMask(par-fields, "XXXX1":U) then p-calc-method else v-calc-method
      x_increase-pc  = if BinMask(par-fields, "XXX1X":U) then p-increase-pc else v-increase-pc
      .
    end.
    else do:
      assign
      x_cli-type     = p-cli-type
      x_cli-code     = p-cli-code
      x_min          = p-Min
      x_max          = p-Max
      x_incr         = p-increase-pc
      x_round-method = p-round-method
      x_base         = p-base
      x_calc-method  = p-calc-method
      x_increase-pc  = p-increase-pc
      var-fill-method = "space"
      .
    end.
    /*обработка какие записи заполнять - ошибочные, все, ошибочные и пустые*/
    CASE var-fill-method:
      when "all":U then do:
        /*ничего делать не надо - уже отработано в предыдущем assign*/
      end.
      when "error-or-space":U then do:
        assign
        x_cli-type     = if v-cli-type = ?
                         or v-entry[1] = "":U
                         then p-cli-type
                         else v-cli-type
        x_cli-code     = if v-cli-code = ?
                         or v-entry[2] = "":U
                         then p-cli-code
                         else v-cli-code

        x_min          = if v-min = ?
                         or v-entry[1] = "":U
                         then p-Min
                         else v-min
        x_max          = if v-max = ?
                         or v-entry[2] = "":U
                         then p-Max
                         else v-max
        x_increase-pc  = if v-incr = ?
                         or v-entry[3] = "":U
                         or v-incr <> v-increase-pc
                         or v-increase-pc = ?
                         then p-increase-pc
                         else v-incr
        x_round-method = if v-round-method = "":U
                         or v-round-method = ?
                         or lookup(v-round-method, {&pr-rounds}) = 0
                         then p-round-method
                         else v-round-method
        x_base         = if v-base = ?
                         or (lookup(v-round-method, {&pr-rounds-need-coef}) > 0 and v-base = 0)
                         then p-base
                         else v-base
        x_calc-method  = if v-calc-method = "":U
                         or v-calc-method = ?
                         or lookup(v-calc-method, {&pr-calc-methods-grp-list}) = 0
                         then p-calc-method
                         else v-calc-method
        .
      end.
      when "error":U then do:
        assign
        x_min          = if v-min = ?
                         then p-Min
                         else v-min
        x_max          = if v-max = ?
                         then p-Max
                         else v-max
        x_cli-type     = if v-cli-type = ?
                         then p-cli-type
                         else v-cli-type
        x_cli-code     = if v-cli-code = ?
                         then p-cli-code
                         else v-cli-code

        x_increase-pc  = if v-incr = ?
                         or v-incr <> v-increase-pc
                         or v-increase-pc = ?
                         then p-increase-pc
                         else v-incr
        x_round-method = if v-round-method = ?
                         or lookup(v-round-method, {&pr-rounds}) = 0
                         then p-round-method
                         else v-round-method
        x_base         = if v-base = ?
                         or (lookup(v-round-method, {&pr-rounds-need-coef}) > 0 and v-base = 0)
                         then p-base
                         else v-base
        x_calc-method  = if v-calc-method  = ?
                         or lookup(v-calc-method, {&pr-calc-methods-grp-list}) = 0
                         then p-calc-method
                         else v-calc-method
        .
      end.
      when "space":U then do:
        assign
        x_min          = if v-entry[1] = "":U
                         then p-Min
                         else v-min
        x_max          = if v-entry[2] = "":U
                         then p-Max
                         else v-max
        x_cli-type     = if v-entry[1] = "":U
                         then p-cli-type
                         else v-cli-type
        x_cli-code     = if v-entry[2] = "":U
                         then p-cli-code
                         else v-cli-code

        x_increase-pc  = if v-entry[3] = "":U
                         then p-increase-pc
                         else v-incr
        x_round-method = if v-round-method = "":U
                         then p-round-method
                         else v-round-method
        x_base         = if v-round-method = "":U
                         then p-base
                         else v-base
        x_calc-method  = if v-calc-method = "":U
                         then p-calc-method
                         else v-calc-method
        .
      end.
    END CASE.
    /*в этом месте мы знаем чем заполнять*/
    /*проверим что то чем заполняем верно!!!*/
    assign
    v-error = if x_min = ? and BinMask(par-fields, "X1XXX":U)
              then yes
              else v-error
    v-error = if x_max = ? and BinMask(par-fields, "X1XXX":U)
              then yes
              else v-error
    v-error = if x_cli-type = ? and BinMask(par-fields, "1XXXX":U)
              then yes
              else v-error
    v-error = if x_cli-code = ? and BinMask(par-fields, "1XXXX":U)
              then yes
              else v-error

    v-error = if x_incr = ? and BinMask(par-fields, "XXX1X":U)
              then yes
              else v-error
    v-error = if (x_round-method = ?
              or lookup(x_round-method, {&pr-rounds}) = 0)
              and BinMask(par-fields, "XX1XX":U)
              then yes
              else v-error
    v-error = if (x_base = ?
              or (lookup(x_round-method, {&pr-rounds-need-coef}) > 0 and x_base = 0)
              )
              and BinMask(par-fields, "XX1XX":U)
              then yes
              else v-error
    v-error = if (x_calc-method  = ?
              or lookup(x_calc-method, {&pr-calc-methods-grp-list}) = 0)
              and BinMask(par-fields, "XXXX1":U)
              then yes
              else v-error
    .
    if v-error then return "error".
    /*выясним а надо ли - может все значения и так уже правильные*/
    /*сначала сравним то что заполняется в группе - calc-method и increase-pc*/
    if x_calc-method <> v-calc-method
    or x_increase-pc <> v-increase-pc then do:
      /*значит надо в группе что то изменить*/
      run ref/gdsgrp01.p (
                      input {&update}
                    ,input yes /*silent*/
                    ,input no /*p-get-node-code*/
                    ,input no /*p-fill-tax-from-upper*/
                    ,input-output buf_gds-grp.node-code
                    ,input-output buf_gds-grp.upper-code
                    ,input buf_gds-grp.node-name
                    ,input x_calc-method
                    ,input x_increase-pc
                    ,input x_round-method
                    ,input x_base
                    ,output v-rid
                    ) no-error.
      /*здесь присутствует x_round-method x_base но меняться они не будут -
      т.к. в update orund-method и base не меняются*/
    end.
    /*сравним то, что заполняется в атрибуте!!*/

    if /*x_min <> v-min
    or x_max <> v-max
    or x_cli-type <> v-cli-type
    or x_cli-code <> v-cli-code
    or x_round-method <> v-round-method
    or x_increase-pc <> v-increase-pc
    or x_base <> v-base then
    */ true = true  then do:

      /*что-то изменилось запишем в базу*/
      if ( BinMask(par-region, "XX1":U) and p-host-code = 0 ) or
         (( BinMask(par-region, "X1X":U)  or BinMask(par-region, "1XX":U) )  and p-host-code <> 0 )
      then do:
          /* Глобально */
          run grp-obj-write in this-procedure (
                                                input buf_gds-grp.node-code
                                              , input p-host-code
                                              , input p-obj-type
                                              , input p-obj-code
                                              , input x_min
                                              , input x_max
                                              , input x_increase-pc
                                              , input buf_gds-grp.calc-method
                                              , input x_round-method
                                              , input x_base
                                              , input x_cli-type
                                              , input x_cli-code
                                              ) no-error.

          end.


      if (BinMask(par-region, "X1X":U)
      or BinMask(par-region, "1XX":U)
         )
      and  par-fields <> 1 /*если 1 то заполняется только calc-method а его в атрибутах нет*/
      and p-host-code = 0
      then do:
        if BinMask(par-region, "X1X":U) then do:
              /*атрибуты по фирме ли объекту надо поменять*/
              for each buf_gds-grp-obj no-lock where
                      buf_gds-grp-obj.node-code = buf_gds-grp.node-code
                  AND buf_gds-grp-obj.host-code <> 0
                  and buf_gds-grp-obj.obj-type = ""
                  and buf_gds-grp-obj.obj-code = 0
                  :
                assign
                ii = ii + 1
                .
                run proc-assign in this-procedure
                                (buffer ub.gds-grp,
                                buf_gds-grp-obj.host-code,
                                buf_gds-grp-obj.obj-type,
                                buf_gds-grp-obj.obj-code,
                                p-calc-method,
                                p-increase-pc,
                                p-min,
                                p-max,
                                p-round-method,
                                p-base,
                                p-cli-type ,
                                p-cli-code
                                ) no-error .
                if not error-status:error and return-value <> "error":U then
                jj = jj + 1.
                run waitfram-show in this-procedure ("Обработано" + {&space-char} +
                              string(ii) + {&space-char} +
                              "записей - успешно" + {&space-char} +
                              string(jj)).
              end.
        end. /* firm */
        if BinMask(par-region, "1XX":U) then do:
              /*атрибуты по объекту надо поменять*/
              for each buf_gds-grp-obj no-lock where
                      buf_gds-grp-obj.node-code = buf_gds-grp.node-code
                  AND buf_gds-grp-obj.host-code <> 0
                  and buf_gds-grp-obj.obj-type <> ""
                  and buf_gds-grp-obj.obj-code <> 0
                  :

                assign
                ii = ii + 1
                .
                run proc-assign in this-procedure
                                (buffer ub.gds-grp,
                                buf_gds-grp-obj.host-code,
                                buf_gds-grp-obj.obj-type,
                                buf_gds-grp-obj.obj-code,
                                p-calc-method,
                                p-increase-pc,
                                p-min,
                                p-max,
                                p-round-method,
                                p-base,
                                p-cli-type ,
                                p-cli-code
                                ) no-error .
                if not error-status:error and return-value <> "error":U then
                jj = jj + 1.
                run waitfram-show in this-procedure ("Обработано" + {&space-char} +
                              string(ii) + {&space-char} +
                              "записей - успешно" + {&space-char} +
                              string(jj)).
              end.
        end. /* obj */
      end.
    end.
  end.

end procedure. /* proc-assign */


procedure ini-tree :
define input parameter par-node-code like ub.gds-grp.node-code no-undo .
define input parameter par-lvl-num   like ub.gds-grp.lvl-num no-undo .
/*это значения из группы*/
define input parameter p_calc-method like ub.gds-grp.calc-method no-undo .
define input parameter p_increase-pc like ub.gds-grp.increase-pc no-undo .

define variable v-value as character no-undo .
define variable v-type as character no-undo .
define variable v-max as decimal no-undo .
define variable v-min as decimal no-undo .
define variable v-incr as decimal no-undo .
define variable v-round-method as character no-undo .
define variable v-base         as decimal no-undo .
define variable v-rid as recid no-undo .
define variable v-calc-method as character no-undo .
define variable v-increase-pc as decimal no-undo .
define variable v-cli-type as character no-undo .
define variable v-cli-code as integer no-undo .


DEFINE VARIABLE v-contin as logical no-undo .
define variable v-process as logical no-undo .
define variable v-nc like ub.gds-grp.node-code no-undo .
define buffer buf_gds-grp for ub.gds-grp.
define buffer new_gds-grp for ub.gds-grp.
define buffer buf_gds-grp-obj for ub.gds-grp-obj.

  do
  on error undo, return error
  :
        /*сначала считаем корневой атрибут*/
    find first buf_gds-grp-obj no-lock where
               buf_gds-grp-obj.node-code = par-node-code
           AND buf_gds-grp-obj.host-code = 0
           AND buf_gds-grp-obj.obj-type = "":U
           AND buf_gds-grp-obj.obj-code = 0.
    assign
    v-min          = buf_gds-grp-obj.min-increase
    v-max          = buf_gds-grp-obj.max-increase
    v-incr         = buf_gds-grp-obj.increase-pc
    v-round-method = buf_gds-grp-obj.round-method
    v-base         = buf_gds-grp-obj.round-coef
    v-cli-type     = buf_gds-grp-obj.cli-type
    v-cli-code     = buf_gds-grp-obj.cli-code

    .
    _buf_gds-grp:
    for each  buf_gds-grp where
              buf_gds-grp.upper-code = par-node-code AND
              buf_gds-grp.lvl-num = par-lvl-num:
      if par-groups = "select-tree":U then do:
        assign
        v-contin = yes
        v-nc = buf_gds-grp.node-code
        .
        do while v-contin:
          run tree-up in this-procedure (input-output v-nc, output v-contin, output v-process).
        end.
      end.
      else v-process = yes
      .
      if not v-process then do:
        next _buf_gds-grp.
      end.
      assign
      ii = ii + 1
      .

      run proc-assign in this-procedure (
                                          buffer buf_gds-grp,
                                          0,
                                          "":U,
                                          0,
                                          p_calc-method,
                                          p_increase-pc,
                                          v-min,
                                          v-max,
                                          v-round-method,
                                          v-base,
                                          v-cli-type ,
                                          v-cli-code
                                          ) no-error .
      if not error-status:error and return-value <> "error":U then
      jj = jj + 1.
      release buf_gds-grp no-error .
      run waitfram-show in this-procedure ("Обработано" + {&space-char} +
                    string(jj) + {&space-char} +
                    "записей - успешно" + {&space-char} +
                    string(ii)).
    end.
  end.

end procedure. /* ini-tree */


procedure tree-up :
define input-output parameter p-node-code like ub.gds-grp.node-code no-undo .
define output parameter p-contin as logical no-undo init yes.
define output parameter p-process as logical no-undo init yes.
define buffer buf_gds-grp for ub.gds-grp.
  do
  on error undo, return error
  :

    find first buf_gds-grp no-lock where
               buf_gds-grp.node-code = p-node-code no-error .
    if not avail buf_gds-grp then do:
      assign
      p-process = no
      p-contin = no
      .
      return.
    end.
    if lookup(string(recid(buf_gds-grp)), par-rid-list) > 0 then do:
      assign
      p-process = yes
      p-contin = no
      .
      return.
    end.
    else do:
      assign
      p-process = no
      p-contin = yes
      p-node-code = buf_gds-grp.upper-code
      .
      return.
    end.
  end.

end procedure. /* tree-up */