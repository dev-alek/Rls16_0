block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: scales2.p $
$Archive: ref/scales2.p $

Изменение статуса весов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/16/04
Author: Bakhtadze Natalya
Creation date: 03/16/04

*/

/*
Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/

define input parameter par-recid as recid no-undo.
define input-output parameter par-sts like ub.scales.sts no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: scales2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/scales2.p $":U .
define variable vss-description as character no-undo init "Изменение статуса весов".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/trg-def.i }

DEFINE VARIABLE loc#log as logical no-undo .
DEFINE BUFFER bf_scales for ub.scales.
DEFINE VARIABLE choice as logical no-undo .
DEFINE VARIABLE varold-sts like ub.scales.sts no-undo .
define variable v-to-send as logical no-undo .
define variable v-scales-num as integer no-undo .
define variable v-scales-name as character no-undo .
define variable v-scales-master as integer no-undo .


_main:
do
on error undo, return error
:

FIND FIRST bf_scales WHERE
           recid(bf_scales) = par-recid.
v-scales-num = bf_scales.scales-num.
v-scales-name = bf_scales.scales-name.
v-scales-master = bf_scales.master.
varold-sts = bf_scales.sts.
if par-sts = ? then do:
  CASE varold-sts:
    when integer({&current-status-int}) then do:
      assign
      par-sts = integer({&deleted-status-int}).
    end.
    when integer({&deleted-status-int}) then do:
      assign
      par-sts = integer({&current-status-int}).
    end.
  END CASE.
end.

CASE par-sts:
  WHEN integer({&current-status-int}) then do:
    if integer({&current-status-int}) = bf_scales.sts  then do:
      message "Весы уже имеют статус ТЕКУЩИЙ!"
      view-as alert-box ERROR.
      par-sts = ?.
      return error.
    end.
    else do:
      if bf_scales.master <> 0 then do:
        assign
        v-to-send = yes.
      end.
      message
      "Весы удалены - восстановить?"
      view-as alert-box QUestion buttons YEs-no update choice.
    end.
  end.
  WHEN integer({&deleted-status-int}) then do:
    if integer({&deleted-status-int}) = bf_scales.sts  then do:
      message "Весы уже имеют статус УДАЛЕН!"
      view-as alert-box ERROR.
      par-sts = ?.
      return error.
    end.
    else do:
      message
      "Выключить весы?" skip
      string(if can-find(first ub.scales no-lock where
                            ub.scales.db-num = bf_scales.db-num
                         AND ub.scales.master = bf_scales.scales-num)
      then "При выключении ГЛАВНЫХ весов Вы не сможете пересылать товары на подчиненные весы"
      else "":U)
      view-as alert-box QUestion buttons yes-no update choice.
    end.
  end.
END CASE.
if choice then do:
  run proc-on-off in this-procedure (input-output par-sts) no-error.
end.
if error-status:error then do:
  undo _main, return error return-value .
end.

par-sts = ?.
if v-to-send then do:
  message
  substitute("Для корректной работы весов №&1 &2,&3" +
            "которые являются подчиненными,&3"  +
            "необходимо переслать ВСЕ ТОВАРЫ&4на их ГЛАВНЫЕ весы №4"
            , v-scales-num
            , v-scales-name
            , {&new-line}
            , v-scales-master)
  view-as alert-box WARNING.
end.

end.

procedure proc-on-off:
define input-output parameter par-sts like ub.scales.sts no-undo .

define variable num-scls as integer no-undo .
define variable ii-num-scls as integer no-undo .
define variable conf-par as character no-undo .
define variable par-type as character no-undo .

define buffer buf_scales for ub.scales.

  do
  on error undo, return error
  :
    if par-sts = integer({&current-status-int}) then do:
      { gbl/conf-rd.i
      "'num-scls'"
      "''"
      "''"
      0
      "''"
      "''"
      "''":U
      yes
      conf-par
      par-type
      no-error
      }
      if error-status:error then undo, return error substitute("Ошибка при чтении значения параметра num-scls&1&2&3"
                                                               , {&new-line}
                                                               , error-status:get-message(1)
                                                               ,return-value ).

      if par-type <> "I" then do:
        message
        "Неправильный тип параметра num-scls (должно быть integer)."
        view-as alert-box error.
        undo , return error "":U.
      end.
      assign
      num-scls = integer(conf-par)
      no-error .
      if error-status:error then do:
        message
        substitute("Неправильное значение параметра num-scls:&1 (должно быть integer).", conf-par)
        view-as alert-box error.
        undo , return error "":U.
      end.
      if num-scls = 0 then do:
        /*
        undo , return error substitute("Превышено максимальное количество включенных весов в БД: &1", num-scls).
        */
        undo , return error substitute("В Вашей системе запрещена работа с весами в данной БД: значение параметра num-scls = &1", num-scls).
      end.
      else do:
        
       /* for each buf_scales no-lock where
                buf_scales.sts = integer({&current-status-int}) and buf_scales.db-num = g#db-num:
          assign
          ii-num-scls = ii-num-scls + 1
          .
        end.
        if ii-num-scls >= num-scls then do:
          undo , return error substitute("Превышено максимальное количество включенных весов в БД: &1", num-scls).
        end. */
        
      end.
    end.
    assign
    bf_scales.sts = par-sts.
    release bf_scales no-error .
    if error-status:error then do:
      undo , return error return-value  .
    end.
    par-sts = ?.
  end.

end procedure. /* proc-on-off */