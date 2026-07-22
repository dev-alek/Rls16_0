block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: taxvali1.p $
$Archive: ref/taxvali1.p $

Сохранение изменений в карточке значений ставки налога

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/18/05
Author: Bakhtadze Natalya
Creation date: 11/18/05


*/

/*
Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/

define input-output parameter par-rid as recid no-undo .
define input parameter par-mode as character no-undo .
define input parameter p-silent as logical   no-undo .
define input parameter partax-code like ub.tax-rate-value.tax-code no-undo .
define input parameter parrate-code like ub.tax-rate-value.rate-code no-undo .
define input parameter parrate-value like ub.tax-rate-value.rate-value no-undo .
define input parameter parfact-date like ub.tax-rate-value.fact-date no-undo .
define input parameter parhost-code like ub.tax-rate-value.host-code no-undo .
define input parameter parobj-type like ub.tax-rate-value.obj-type no-undo .
define input parameter parobj-code like ub.tax-rate-value.obj-code no-undo .
define input parameter parstatus  like ub.tax-rate-value.status_ no-undo .


def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: taxvali1.p $":U .
def var vss-archive     as character no-undo init "$Archive: ref/taxvali1.p $":U .
def var vss-description as character no-undo init "Сохранение изменений в карточке значений ставки налога".
{ cmp/vssrevis.i }

{ cmp/trg-def.i  }
{ trg/factord.i  }
{ gbl/cur-time.i }

main-block:
do transaction
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  define variable var-entry as character no-undo .
  define variable var-fact-order like ub.tax-rate-value.fact-order no-undo .
  define variable dop-rid as recid no-undo .
  define variable is-found as logical no-undo .
  define variable loc#log as logical no-undo .
  define variable v-today as date      no-undo.
  define variable v-time  as integer   no-undo.
  define variable varfact-date as date no-undo .
  define variable v-first-value as logical no-undo .

  define variable v-mess as character no-undo .

  define buffer b_tax-rate-value     for ub.tax-rate-value.
  define buffer buf_tax-rate-value   for ub.tax-rate-value.
  define buffer first_tax-rate-value for ub.tax-rate-value.
  define buffer new_tax-rate-value   for ub.tax-rate-value .
  define buffer up_tax-rate-value    for ub.tax-rate-value .

  if par-mode <> {&add-def} then do:
    assign
      v-mess = substitute( "&1 (&2). Ошибка задания входных параметров. Неверный параметр par-mode (&3).", vss-workfile, vss-revision, par-mode )
    .
    run err-mess in this-procedure ( input-output v-mess ).
    undo main-block, return error (if p-silent = yes then v-mess else '':U ).
  end.
  FIND FIRST ub.tax-rate No-LOCK where
            ub.tax-rate.tax-code = partax-code AND
            ub.tax-rate.rate-code = parrate-code No-ERROR.
  if not available ub.tax-rate then do:
    assign
      v-mess = substitute( "Не найдена ставка." )
    .
    run err-mess in this-procedure ( input-output v-mess ).
    undo main-block, return error (if p-silent = yes then v-mess else '':U ).
  end.
  if ub.tax-rate.status_ = {&deleted-status} then do:
    assign
      v-mess = substitute( "Нельзя добавить значениe к удаленной ставке." )
    .
    run err-mess in this-procedure ( input-output v-mess ).
    undo main-block, return error (if p-silent = yes then v-mess else '':U ).
  end.
  find first first_tax-rate-value no-lock where
            first_tax-rate-value.tax-code = partax-code
        AND first_tax-rate-value.rate-code = parrate-code no-error .
  if not available first_tax-rate-value then do:
    assign
    v-first-value = true
    .
  end.
  if v-first-value = true then do:
    assign
    v-today = 01/01/1990
    .
  end.
  else do:
    if parobj-type = ""
    or parobj-code = 0
    then do:
        run cur-time in this-procedure ( output v-today
                                      , output v-time
                                      ).
    end.
    else do:
        { gbl/curobjdt.i parobj-type parobj-code v-today }
    end.
  end.

  if parfact-date = ? then do:
      assign
      v-mess = substitute( "Не указана дата начала действия данного значения ставки." )
        var-entry = "fact-date":U
      .
      run err-mess in this-procedure ( input-output v-mess ).
      undo main-block, return error (if p-silent = yes then v-mess else var-entry ).
  end.
  if p-silent = no
    and parfact-date < v-today
  then do:
    assign
      v-mess = substitute( "Указана дата начала действия данного значения ставки меньше текущей." )
      var-entry = "fact-date":U
    .
    run err-mess in this-procedure ( input-output v-mess ).
    undo main-block, return error (if p-silent = yes then v-mess else var-entry ).
  end.

  assign
  varfact-date = parfact-date
  .
  run factord-end-day in this-procedure (input parfact-date, output var-fact-order).
  find last b_tax-rate-value no-lock
    where b_tax-rate-value.tax-code = partax-code
      and b_tax-rate-value.rate-code = parrate-code
      and b_tax-rate-value.fact-order <= var-fact-order
      and b_tax-rate-value.host-code = parhost-code
      and b_tax-rate-value.obj-type = parobj-type
      and b_tax-rate-value.obj-code = parobj-code
      and b_tax-rate-value.status_ = {&current-status}
    no-error.
  if available b_tax-rate-value
    and b_tax-rate-value.rate-value = parrate-value
  then do:
    assign
      v-mess = substitute( "Уже есть ТАКОЕ ЖЕ значение ставки налога, которое действует с &1", string( b_tax-rate-value.fact-date, "99/99/9999" ) )
      var-entry = "rate-value":U
    .
    run err-mess in this-procedure ( input-output v-mess ).
    undo main-block, return error (if p-silent = yes then v-mess else var-entry ).
  end.
  else do:
    FIND LAST b_tax-rate-value No-LOCK WHERE
              b_tax-rate-value.tax-code = partax-code AND
              b_tax-rate-value.rate-code = parrate-code AND
              b_tax-rate-value.fact-order <= var-fact-order AND
              b_tax-rate-value.host-code = parhost-code AND
              b_tax-rate-value.obj-type = parobj-type AND
              b_tax-rate-value.obj-code = parobj-code
              NO-ERROR.
    if not available b_tax-rate-value then do:
      assign
      varfact-date = 01/01/1990
      .
      run factord-end-day in this-procedure (input varfact-date, output var-fact-order).
    end.
  end.

  FIND FIRST b_tax-rate-value  NO-LOCK where
            b_tax-rate-value.tax-code = partax-code AND
            b_tax-rate-value.rate-code = parrate-code AND
            b_tax-rate-value.fact-order = var-fact-order AND
            b_tax-rate-value.host-code = parhost-code AND
            b_tax-rate-value.obj-type = parobj-type AND
            b_tax-rate-value.obj-code = parobj-code AND
            b_tax-rate-value.status_ = {&current-status}
            No-ERROR.
  if available b_tax-rate-value then do:
    if parfact-date > v-today then do:
      if p-silent = no then do:
        message "Уже есть значение ставки налога" skip
                "с такой датой начала действия"
                "Переписать значение? "
        view-as alert-box QUESTION
        buttons YES-NO update loc#log.
      end.
      else do:
        assign
          loc#log = true
        .
      end.
      if loc#log = false then do:
        assign
          var-entry = "fact-date":U
        .
        return error var-entry.
      end.
      else do:
        assign
          dop-rid = recid(b_tax-rate-value)
          is-found = yes
        .
      end.
    end.
    else do:
      assign
        v-mess = substitute( "Уже есть значение ставки налога действующее с &1", string( b_tax-rate-value.fact-date, "99/99/9999" ) )
        var-entry = "fact-date":U
      .
      run err-mess in this-procedure ( input-output v-mess ).
      undo main-block, return error (if p-silent = yes then v-mess else var-entry ).
    end.
  end.
  else do:
    FIND FIRST b_tax-rate-value  NO-LOCK where
              b_tax-rate-value.tax-code = partax-code AND
              b_tax-rate-value.rate-code = parrate-code AND
              b_tax-rate-value.fact-order = var-fact-order AND
              b_tax-rate-value.host-code = parhost-code AND
              b_tax-rate-value.obj-type = parobj-type AND
              b_tax-rate-value.obj-code = parobj-code AND
              b_tax-rate-value.status_ = {&deleted-status}
              No-ERROR.
    if available b_tax-rate-value then do:
      if p-silent = no then do:
        message substitute( "Уже есть удаленное значение ставки налога (&1)", b_tax-rate-value.rate-value ) skip
                substitute( "с такой же датой начала действия (&1)", b_tax-rate-value.fact-date ) skip
                "Восстановить и переписать значение? "
        view-as alert-box QUESTION
        buttons YES-NO update loc#log.
        if not loc#log then do:
          var-entry = "fact-date":U.
          return error var-entry.
        end.
        else do:
          assign
          dop-rid = recid(b_tax-rate-value)
          is-found = yes.
        end.
      end.
      else do:
        if parstatus = {&current-status} then do:
          assign
          dop-rid = recid(b_tax-rate-value)
          is-found = yes.
        end.
        else do:
          assign
            v-mess = substitute( "Уже есть удаленное значение ставки налога (&1) с такой датой начала действия (&2)", b_tax-rate-value.rate-value, b_tax-rate-value.fact-date )
            var-entry = "fact-date":U
          .
          run err-mess in this-procedure ( input-output v-mess ).
          undo main-block, return error (if p-silent = yes then v-mess else var-entry ).
        end.
      end.
    end.
  end.

  if is-found = true then do:
    FIND FIRST b_tax-rate-value EXCLUSIVE-LOCK where
              recid( b_tax-rate-value) = dop-rid No-ERROR.
    if not available b_tax-rate-value then do:
      assign
        v-mess = substitute( "Не удалось переписать значение ставки налога" )
      .
      run err-mess in this-procedure ( input-output v-mess ).
      undo main-block, return error (if p-silent = yes then v-mess else '':U ).
    end.
    assign
    b_tax-rate-value.rate-value = parrate-value
    b_tax-rate-value.status_ = {&current-status}
    par-rid = recid( b_tax-rate-value )
    .
    release b_tax-rate-value no-error .
    if error-status:error then do:
      assign
        v-mess = substitute( "&2 (&3). Ошибка при сохранении записи ЗНАЧЕНИЕ СТАВКИ НАЛОГА.&1&4&1&5"
                              , {&new-line}
                              , vss-workfile
                              , vss-revision
                              , error-status:get-message(1)
                              , return-value )
      .
      run err-mess in this-procedure ( input-output v-mess ).
      undo main-block, return error (if p-silent = yes then v-mess else '':U ).
    end.
  end.
  else do: /* NOT is-found */
    create new_tax-rate-value.
    assign
    new_tax-rate-value.tax-code = partax-code
    new_tax-rate-value.rate-code = parrate-code
    new_tax-rate-value.rate-value = parrate-value
    new_tax-rate-value.fact-date = varfact-date
    new_tax-rate-value.fact-order = var-fact-order
    new_tax-rate-value.status_ = {&current-status}
    new_tax-rate-value.host-code = parhost-code
    new_tax-rate-value.obj-type = parobj-type
    new_tax-rate-value.obj-code = parobj-code
    par-rid = recid( new_tax-rate-value )
    .
    if parobj-code <> 0 then do:
      /*папа есть?*/
      find last buf_tax-rate-value no-lock where
                buf_tax-rate-value.tax-code = partax-code AND
                buf_tax-rate-value.rate-code = parrate-code AND
                buf_tax-rate-value.host-code = parhost-code AND
                buf_tax-rate-value.obj-type = "":U AND
                buf_tax-rate-value.obj-code = 0 AND
                buf_tax-rate-value.fact-order <= var-fact-order  NO-ERROR.
      IF not available buf_tax-rate-value OR
        (buf_tax-rate-value.status_ = {&deleted-status} AND
        NOT can-find(first up_tax-rate-value where
                        up_tax-rate-value.tax-code = partax-code AND
                        up_tax-rate-value.rate-code = parrate-code AND
                        up_tax-rate-value.host-code = parhost-code AND
                        up_tax-rate-value.obj-type = '':U AND
                        up_tax-rate-value.obj-code = 0 AND
                        up_tax-rate-value.fact-order <= var-fact-order AND
                        recid(up_tax-rate-value) <> recid(buf_tax-rate-value)
                      ) AND
        buf_tax-rate-value.fact-order <> var-fact-order
        ) then do:
        if g#db-num > 0 then do:
          assign
            v-mess = substitute( "При создании значения ставки налога на объекте&1"
                                  + "в БД уже должна быть определено значение ставки налога по фирме, которой принадлежит объект &1"
                                  + "Введите значение ставки налога на фирме в ОФИСЕ и перешлите его по СПН&1"
                                  , {&new-line}
                                ) .
          run err-mess in this-procedure ( input-output v-mess ).
          undo main-block, return error (if p-silent = yes then v-mess else '':U ).
        end.
        create up_tax-rate-value.
        assign
        up_tax-rate-value.tax-code = partax-code
        up_tax-rate-value.rate-code = parrate-code
        up_tax-rate-value.rate-value = parrate-value
        up_tax-rate-value.fact-date = varfact-date
        up_tax-rate-value.fact-order = var-fact-order
        up_tax-rate-value.status_ = {&current-status}
        up_tax-rate-value.host-code = parhost-code
        up_tax-rate-value.obj-type = "":U
        up_tax-rate-value.obj-code = 0
        .
      end.
      else do:
        if not available buf_tax-rate-value then do:
          find LAST up_tax-rate-value where
                    up_tax-rate-value.tax-code = partax-code AND
                    up_tax-rate-value.rate-code = parrate-code AND
                    up_tax-rate-value.host-code = parhost-code AND
                    up_tax-rate-value.obj-type = '':U AND
                    up_tax-rate-value.obj-code = 0 AND
                    up_tax-rate-value.fact-order <= var-fact-order AND
                    up_tax-rate-value.status_ = {&deleted-status} NO-WAIT No-ERROR.
          if not available up_tax-rate-value then do:
            assign
              v-mess = substitute( "Не удается создать запись-родитель для значения ставки" )
            .
            run err-mess in this-procedure ( input-output v-mess ).
            undo main-block, return error (if p-silent = yes then v-mess else '':U ).
          end.
          assign
          up_tax-rate-value.status_ = {&current-status}
          .
        end.
      end.
      if available up_tax-rate-value then do:
        release up_tax-rate-value no-error .
        if error-status:error then do:
          assign
            v-mess = substitute( "&2 (&3). Ошибка при сохранении записи-родителя для значения ставки.&1&4&1&5"
                                  , {&new-line}
                                  , vss-workfile
                                  , vss-revision
                                  , error-status:get-message(1)
                                  , return-value )
          .
          run err-mess in this-procedure ( input-output v-mess ).
          undo main-block, return error (if p-silent = yes then v-mess else '':U ).
        end.
      end.
    end.
    if parhost-code <> 0 then do:
      /*дедушка есть?*/
      FIND  LAST BUF_TAX-RATE-VALUe NO-LOCK where
                  buf_tax-rate-value.tax-code = partax-code AND
                  buf_tax-rate-value.rate-code = parrate-code AND
                  buf_tax-rate-value.host-code = 0 AND
                  buf_tax-rate-value.obj-type = "":U AND
                  buf_tax-rate-value.obj-code = 0 AND
                  buf_tax-rate-value.fact-order <= var-fact-order NO-ERROR.
      IF not available buf_tax-rate-value OR
        (buf_tax-rate-value.status_ = {&deleted-status} AND
        NOT can-find(first up_tax-rate-value where
                        up_tax-rate-value.tax-code = partax-code AND
                        up_tax-rate-value.rate-code = parrate-code AND
                        up_tax-rate-value.host-code = 0 AND
                        up_tax-rate-value.obj-type = '':U AND
                        up_tax-rate-value.obj-code = 0 AND
                        up_tax-rate-value.fact-order <= var-fact-order AND
                        recid(up_tax-rate-value) <> recid(buf_tax-rate-value)
                      ) AND
        buf_tax-rate-value.fact-order <> var-fact-order
        ) then do:
        create up_tax-rate-value.
        assign
        up_tax-rate-value.tax-code = partax-code
        up_tax-rate-value.rate-code = parrate-code
        up_tax-rate-value.rate-value = parrate-value
        up_tax-rate-value.fact-date = varfact-date
        up_tax-rate-value.fact-order = var-fact-order
        up_tax-rate-value.status_ = {&current-status}
        up_tax-rate-value.host-code = 0
        up_tax-rate-value.obj-type = "":U
        up_tax-rate-value.obj-code = 0
        .
      end.
      else do:
        if not available buf_tax-rate-value then do:
          find LAST up_tax-rate-value where
                    up_tax-rate-value.tax-code = partax-code AND
                    up_tax-rate-value.rate-code = parrate-code AND
                    up_tax-rate-value.host-code = 0 AND
                    up_tax-rate-value.obj-type = '':U AND
                    up_tax-rate-value.obj-code = 0 AND
                    up_tax-rate-value.fact-order <= var-fact-order AND
                    up_tax-rate-value.status_ = {&deleted-status} No-ERROR.
          if not available up_tax-rate-value then do:
            assign
              v-mess = substitute( "Не удается создать запись-родитель для значения ставки." )
            .
            run err-mess in this-procedure ( input-output v-mess ).
            undo main-block, return error (if p-silent = yes then v-mess else '':U ).
          end.
          assign
          up_tax-rate-value.status_ = {&current-status}
          .
        end.
      end.
      if available up_tax-rate-value then do:
        release up_tax-rate-value no-error .
        if error-status:error then do:
          assign
            v-mess = substitute( "&2 (&3). Ошибка при сохранении записи-родителя для значения ставки.&1&4&1&5"
                                  , {&new-line}
                                  , vss-workfile
                                  , vss-revision
                                  , error-status:get-message(1)
                                  , return-value )
          .
          run err-mess in this-procedure ( input-output v-mess ).
          undo main-block, return error (if p-silent = yes then v-mess else '':U ).
        end.
      end.

    end.
    release new_tax-rate-value no-error .
    if error-status:error then do:
      assign
        v-mess = substitute( "&2 (&3). Ошибка при сохранении записи ЗНАЧЕНИЕ СТАВКИ НАЛОГА.&1&4&1&5"
                              , {&new-line}
                              , vss-workfile
                              , vss-revision
                              , error-status:get-message(1)
                              , return-value )
      .
      run err-mess in this-procedure ( input-output v-mess ).
      undo main-block, return error (if p-silent = yes then v-mess else '':U ).
    end.
  end.

  return '':U.

end. /*TRANSACTION */

procedure err-mess:
  define input-output parameter p-mess as character no-undo.

  case p-silent:
    when yes then do:
      assign
      p-mess = substitute("Сохранение изменений в карточке ЗНАЧЕНИЙ ставки налога&1"
                          + "Тип ставки &2&1"
                          + "Код ставки &3&1"
                          + "Код фирмы &4&1"
                          + "Объект &5 &6&1"
                          + "Дата включениия &7&1"
                          + "&8"
                         , {&new-line}
                         , partax-code
                         , parrate-code
                         , parhost-code
                         , parobj-type
                         , parobj-code
                         , parfact-date
                         , p-mess)
      .
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
end procedure.