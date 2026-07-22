block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: taxrati1.p $
$Archive: ref/taxrati1.p $

Сохранение изменений в карточке ставки налога

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
define input parameter par-mode       as character no-undo .
define input parameter p-silent       as logical  no-undo .
define input parameter partax-code    like ub.tax-rate.tax-code no-undo .
define input parameter parrate-code   like ub.tax-rate.rate-code no-undo .
define input parameter parrate-name   like ub.tax-rate.rate-name no-undo .
define input parameter parstatus    like ub.tax-rate.status_   no-undo .

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: taxrati1.p $":U .
def var vss-archive     as character no-undo init "$Archive: ref/taxrati1.p $":U .
def var vss-description as character no-undo init "Сохранение изменений в карточке ставки налога".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ ref/grplib.i }


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  define variable v-mess    as character no-undo .
  define variable var-entry as character no-undo .
  define variable v-root-node as integer no-undo .

  define buffer buf_tax-rate      for ub.tax-rate .
  define buffer buf-next_tax-rate for ub.tax-rate .
  define buffer buf_tax-rate-gds-grp for ub.tax-rate-gds-grp.

  if g#db-num > 0 then do:
    assign
      v-mess = "Вызов процедуры в УБД запрещен"
    .
    run err-mess in this-procedure ( input-output v-mess ).
    undo main-block, return error (if p-silent = yes then v-mess else '':U).
  end.

  if parrate-name = "" then do:
    assign
      v-mess = "Не указано полное наименование ставки."
      var-entry = 'rate-name':U
    .
    run err-mess in this-procedure ( input-output v-mess ).
    undo main-block, return error (if p-silent = yes then v-mess else var-entry ).
  end.

  if parrate-code = 0 OR
    parrate-code = ? then do:
    assign
      v-mess = "Не указан код ставки."
      var-entry = "rate-code":U
    .
    run err-mess in this-procedure ( input-output v-mess ).
    undo main-block, return error (if p-silent = yes then v-mess else var-entry ).
  end.
  if par-mode = {&add-def} then do:
    find first buf-next_tax-rate share-lock where
            buf-next_tax-rate.rate-code = parrate-code no-error .
    if available buf-next_tax-rate then do:
      assign
        v-mess = "Ставка налога с таким кодом уже есть."
        var-entry = "rate-code":U
      .
      run err-mess in this-procedure ( input-output v-mess ).
      undo main-block, return error (if p-silent = yes then v-mess else var-entry ).
    end.
    find first buf-next_tax-rate share-lock where
            buf-next_tax-rate.tax-code = partax-code
        and buf-next_tax-rate.rate-code = parrate-code
      no-error .
    if available buf-next_tax-rate then do:
      assign
        v-mess = "Ставка налога такого вида и с таким кодом уже есть."
        var-entry = "rate-code":U
      .
      run err-mess in this-procedure ( input-output v-mess ).
      undo main-block, return error (if p-silent = yes then v-mess else var-entry ).
    end.
    create buf_tax-rate.
    assign
    buf_tax-rate.tax-code = partax-code
    buf_tax-rate.rate-code = parrate-code
    buf_tax-rate.rate-name = parrate-name
    buf_tax-rate.status_   = parstatus
    par-rid = recid( buf_tax-rate )
    .
  end. /*add-def*/
  else do:
    find first buf_tax-rate exclusive-lock where
              recid(buf_tax-rate) = par-rid no-error.
    if not available buf_tax-rate then do:
      assign
        v-mess = "Ставка налога отсутствует."
      .
      run err-mess in this-procedure ( input-output v-mess ).
      undo main-block, return error (if p-silent = yes then v-mess else '':U ).
    end.

    if buf_tax-rate.status_ = {&deleted-status} then do:
      if buf_tax-rate.status_ <> parstatus then do:
        assign
          buf_tax-rate.status_ = parstatus
        .
      end.
      else do:
        assign
          v-mess = "Ставка удалена - изменение невозможно."
        .
        run err-mess in this-procedure ( input-output v-mess ).
        undo main-block, return error (if p-silent = yes then v-mess else '':U ).
      end.
    end.
    assign
    buf_tax-rate.rate-name = parrate-name
    .
  end.
  release buf_tax-rate no-error .
  if error-status:error then do:
    assign
      v-mess = substitute( "Ошибка при сохранении записи СТАВКА НАЛОГА.&1&2&1&3", {&new-line}, error-status:get-message(1), return-value )
    .
    run err-mess in this-procedure ( input-output v-mess ).
    undo main-block, return error (if p-silent = yes then v-mess else '':U ).
  end.
  if partax-code = integer({&vat-tax-code})
  then do:
    run  grplib-get-root-code in this-procedure ( output v-root-node).
    if not can-find(first ub.tax-rate-gds-grp where
                            ub.tax-rate-gds-grp.tax-code = integer({&vat-tax-code})
                        AND ub.tax-rate-gds-grp.node-code = v-root-node
                        AND ub.tax-rate-gds-grp.host-code = 0
                        AND ub.tax-rate-gds-grp.obj-type = "":U
                        AND ub.tax-rate-gds-grp.obj-code = 0
                            ) then do:
      create buf_tax-rate-gds-grp.
      assign
      buf_tax-rate-gds-grp.node-code = v-root-node
      buf_tax-rate-gds-grp.tax-code = integer({&vat-tax-code})
      buf_tax-rate-gds-grp.rate-code = parrate-code
      .
      release buf_tax-rate-gds-grp no-error.
      if error-status:error then do:
        v-mess = substitute("Ошибка при сохранении записи СТАВКА НАЛОГА ДЛЯ ГРУППЫ ТОВАРОВ ПО УМОЛЧАНИЮ (группа с вн.кодом &4) .&1&2&1&3"
                               , {&new-line}
                               , error-status:get-message(1)
                               , return-value
                               , v-root-node
                               ).
        run err-mess in this-procedure ( input-output v-mess ).
        undo main-block, return error (if p-silent = yes then v-mess else '':U ).
      end.
    end.
  end.
  return '':U.

end. /*doe*/

procedure err-mess:
  define input-output parameter p-mess as character no-undo.

  case p-silent:
    when yes then do:
      assign
      p-mess = substitute("Сохранение изменений в карточке ставки налога &1Тип ставки &2&1Код ставки &3&1&4"
                         , {&new-line}
                         , partax-code
                         , parrate-code
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