block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: in-grptx.p $
$Archive: utl/in-grptx.p $

Инициализация налогов в группах товаров

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/29/03
Author: Bakhtadze Natalya
Creation date: 08/29/03

*/

define input parameter par-fill-method as character no-undo .
/*error-or-space   all   error незапол или неверные-все-неверные*/

define input parameter par-groups as character no-undo .
/*all select select-tree  все группы или выборочно по par-rid-list*/

define input parameter par-values as character no-undo .
/*default group - заданными значениями или из верхней группы*/


define input parameter par-rid-list as character no-undo .
/*recid выбраных групп*/

{ str/tt-tax.i "shared"}
/*те значения которые задал пользователь*/
{ str/tt-tax.i " "  loc-tt-tax }
/*те значения которые передаются по дереву вниз */
{ str/tt-tax.i " "  v-tt-tax }

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: in-grptx.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/in-grptx.p $":U .
define variable vss-description as character no-undo init "Инициализация налогов в группах товаров".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

{ gbl/waitfram.i }
DEFINE VARIABLE ii as integer no-undo .
DEFINE VARIABLE jj as integer no-undo .
DEFINE VARIABLE kk as integer no-undo .
define variable v-process as logical no-undo .
define variable v-contin as logical no-undo .
define variable v-node-code like ub.gds-grp.node-code no-undo .
define variable v-lvl-num as integer no-undo .
define variable glog as logical no-undo .

define buffer upper_gds-grp for ub.gds-grp.

if ( g#db-num > 0 ) then do:
  message vss-workfile vss-revision vss-description skip
  "Утилиту можно запустить только в ГБД"
  view-as alert-box error .
  return error .
end.


message
"Инициализация налогов в ГРУППАХ ТОВАРОВ ?   Вы уверены ?"
view-as alert-box question buttons OK-Cancel update glog.
if glog <> true then return.

for each tt-tax no-lock:
  find first loc-tt-tax where
            loc-tt-tax.tax-code = tt-tax.tax-code no-error .
  if not available loc-tt-tax then do:
    create loc-tt-tax.
    buffer-copy tt-tax to loc-tt-tax.
  end.
end.
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
                      (buffer ub.gds-grp
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

define variable v-value as integer no-undo .
define variable v-type as character no-undo .

define variable ll as integer no-undo .
define variable v-error as logical no-undo .

define buffer buf_tax-rate-gds-grp for ub.tax-rate-gds-grp .
define buffer buf_tax-rate for ub.tax-rate.

  do
  on error undo, return error
  :
   /*берем значение из группы в локальную таблицу */
    for each loc-tt-tax no-lock:
      find first buf_tax-rate-gds-grp where
                 buf_tax-rate-gds-grp.node-code = buf_gds-grp.node-code
            AND buf_tax-rate-gds-grp.tax-code = loc-tt-tax.tax-code
            AND buf_tax-rate-gds-grp.host-code = 0
            AND buf_tax-rate-gds-grp.obj-type = "":U
            AND buf_tax-rate-gds-grp.obj-code = 0 no-error .
      if available buf_tax-rate-gds-grp then do:
        /*проверим валидность*/
        find first buf_tax-rate no-lock where
                   buf_tax-rate.tax-code = buf_tax-rate-gds-grp.tax-code
               AND buf_tax-rate.rate-code = buf_tax-rate-gds-grp.rate-code no-error .
        if not available buf_tax-rate then do:
          v-value = ?
          .
        end.
        else do:
          assign
          v-value = buf_tax-rate-gds-grp.rate-code
          .
        end.
      end.
      else do:
        assign
        v-value = ?
        .
      end.
      find first v-tt-tax where
                v-tt-tax.tax-code = loc-tt-tax.tax-code no-error .
      if not available v-tt-tax then
      create v-tt-tax.
      buffer-copy loc-tt-tax except rate-code to v-tt-tax
      assign
      v-tt-tax.rate-code = v-value
      .
      /*обработка какие записи заполнять - ошибочные, все, ошибочные и пустые*/
      CASE par-fill-method:
        when "all":U then do:
          assign
          v-tt-tax.rate-code = loc-tt-tax.rate-code
          .
          /*ничего делать не надо - уже отработано в предыдущем assign*/
        end.
        when "error-or-space":U then do:
          if v-tt-tax.rate-code = ? then do:
            assign
            v-tt-tax.rate-code = loc-tt-tax.rate-code
            .
          end.
        end.
      END CASE.
      /*выясним а надо ли - может все значения и так уже правильные*/
      if not available buf_tax-rate-gds-grp
      or buf_tax-rate-gds-grp.rate-code <> v-tt-tax.rate-code then do:
        if not available buf_tax-rate-gds-grp then do:
          create buf_tax-rate-gds-grp.
          assign
          buf_tax-rate-gds-grp.node-code = buf_gds-grp.node-code
          buf_tax-rate-gds-grp.host-code = 0
          buf_tax-rate-gds-grp.obj-type = "":U
          buf_tax-rate-gds-grp.obj-code = 0
          .
        end.
        assign
        buf_tax-rate-gds-grp.tax-code = v-tt-tax.tax-code
        buf_tax-rate-gds-grp.rate-code = v-tt-tax.rate-code
        .
      end.
    end. /*for each tt-tax*/
  end.

end procedure. /* proc-assign */


procedure ini-tree :
define input parameter par-node-code like ub.gds-grp.node-code no-undo .
define input parameter par-lvl-num   like ub.gds-grp.lvl-num no-undo .

define variable v-value as character no-undo .
define variable v-type as character no-undo .
define variable v-rid as recid no-undo .

DEFINE VARIABLE v-contin as logical no-undo .
define variable v-process as logical no-undo .
define variable v-nc like ub.gds-grp.node-code no-undo .
define buffer buf_gds-grp for ub.gds-grp.
define buffer new_gds-grp for ub.gds-grp.
define buffer buf_tax-rate-gds-grp for ub.tax-rate-gds-grp.
define buffer buf_tax-rate for ub.tax-rate.

  do
  on error undo, return error
  :
    /*сначала считаем значения из группы*/
    for each tt-tax no-lock
      , first loc-tt-tax where loc-tt-tax.tax-code = tt-tax.tax-code
    :
      find first buf_tax-rate-gds-grp no-lock where
                buf_tax-rate-gds-grp.node-code = par-node-code
            AND buf_tax-rate-gds-grp.tax-code = tt-tax.tax-code
            AND buf_tax-rate-gds-grp.host-code = 0
            AND buf_tax-rate-gds-grp.obj-type = "":U
            AND buf_tax-rate-gds-grp.obj-code = 0 no-error .
      if available buf_tax-rate-gds-grp then do:
        /*проверим на валидность*/
        /*проверим валидность*/
        find first buf_tax-rate no-lock where
                   buf_tax-rate.tax-code = buf_tax-rate-gds-grp.tax-code
               AND buf_tax-rate.rate-code = buf_tax-rate-gds-grp.rate-code no-error .
        if not available buf_tax-rate then do:
          assign
          loc-tt-tax.rate-code =tt-tax.rate-code
          .
        end.
        else do:
          assign
          loc-tt-tax.rate-code = buf_tax-rate-gds-grp.rate-code
          .
        end.
      end.
      else do:
        assign
        loc-tt-tax.rate-code = tt-tax.rate-code
        .
      end.
    end.
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
                                          buffer buf_gds-grp
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