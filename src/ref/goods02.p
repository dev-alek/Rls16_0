block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: goods02.p $
$Archive: ref/goods02.p $

Смена статуса товара

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/25/05
Author: Bakhtadze Natalya
Creation date: 08/25/05

*/


define input parameter p-gds-rec as recid no-undo .
define input parameter p-silent as logical no-undo .
define input-output parameter p-stts like ub.goods.stts no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: goods02.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/goods02.p $":U .
define variable vss-description as character no-undo init "Смена статуса товара".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/waitfram.i }

DEFINE VARIABLE loc#log as logical no-undo .
DEFINE VARIABLE choice as logical no-undo .
DEFINE VARIABLE varold-stts like ub.goods.stts no-undo .
define variable v-gds-code like ub.goods.gds-code no-undo .
define variable v-mess as character no-undo .
define variable v-recid as recid no-undo .
define buffer buf_goods for ub.goods.
define buffer buf_gds-obj for ub.gds-obj.


_main:
do
on error undo, return error return-value
:
 find first buf_goods exclusive-lock where recid(buf_goods) = p-gds-rec.
  varold-stts = buf_goods.stts.
  if p-stts = ? then do:
    CASE varold-stts:
      when integer({&current-status-int}) then do:
        assign
        p-stts = integer({&deleted-status-int}).
      end.
      when integer({&deleted-status-int})
      then do:
        assign
        p-stts = integer({&current-status-int}).
      end.
    END CASE.
  end.

CASE p-stts:
  when integer({&befor-artic-change-int})
  or when integer({&artic-change-int})
  then do:
    assign
    v-mess =  substitute("Товар с кодом &1:&2&3 &4&2В настоящий момент по ТОВАРУ проводится смена артикула и/или производителя:&2" +
                         "смена статуса запрещена"
                         , buf_goods.gds-code
                         , {&new-line}
                         , buf_goods.artic
                         , buf_goods.gds-name).
    if p-silent then do:
      message
      v-mess
      view-as alert-box ERROR.
    end.
    else do:
      undo _main, return error (if p-silent then v-mess else '').
    end.
  end.
  WHEN integer({&current-status-int}) then do:
    if integer({&current-status-int}) = buf_goods.stts  then do:
      if p-silent then do:
        return ''.
      end.
      else do:
        message "ТОВАР уже имеет статус ТЕКУЩИЙ!"
        view-as alert-box ERROR.
        p-stts = ?.
        undo _main, return error.
      end.
    end.
    else do:
      if p-silent then do:
        choice = yes.
      end.
      else do:
        message
        "ТОВАР удален - восстановить?"
        view-as alert-box QUestion buttons YEs-no update choice.
      end.
    end.
  end.
  WHEN integer({&deleted-status-int}) then do:
    if integer({&deleted-status-int}) = buf_goods.stts  then do:
      if p-silent then do:
        return ''.
      end.
      else do:
        message "ТОВАР уже имеет статус УДАЛЕН!"
        view-as alert-box ERROR.
        p-stts = ?.
        undo _main, return error.
      end.
    end.
    else do:
      if p-silent then do:
        choice = yes.
      end.
      else do:
        message
        "Поставить статус УДАЛЕН?" skip(0)
        view-as alert-box QUestion buttons yes-no update choice.
      end.
    end.
  end.
END CASE.
if choice then do:

  /*проверим возможность выключения*/
  CASE p-stts:
    when integer({&deleted-status-int}) then do:
      if not g#db-num > 0 then do:
        for each buf_gds-obj no-lock where
                 buf_gds-obj.artic     = buf_goods.artic
             and buf_gds-obj.prod-type = buf_goods.prod-type
             and buf_gds-obj.prod-code = buf_goods.prod-code
        on error undo, return error :
          if NOT ( buf_gds-obj.fact-qnty = 0   and
                   buf_gds-obj.avrg-qnty = 0 ) then do:
            assign
            v-mess = substitute("По данным офиса по товару с кодом &1 &2(&3 &4) имеются остатки на объектах&2"  +
                                "Удаление запрещено"
                                , buf_goods.gds-code
                                , {&new-line}
                                , buf_goods.artic
                                , buf_goods.gds-name
                                ).
            if not p-silent then do:
              message v-mess
              view-as alert-box error .
            end.
            undo, return error (if p-silent then v-mess else '':U).
          end. /*if NOT ( buf_gds-obj.fact-qnty = 0   and*/
        end. /* for each buf_gds-obj no-lock where*/
      end. /*if not g#db-num > 0 then do:*/
    end.
  END CASE.
  if error-status:error then do:
    v-mess = substitute("Не может быть сменен статус у ТОВАРА с кодом &1"
                          , buf_goods.gds-code
                          , {&new-line}
                          , error-status:get-message(1)
                          , return-value ).
    undo _main, return error (if p-silent then v-mess else '':U).
  end.
  assign
  buf_goods.stts = p-stts.
  v-gds-code = buf_goods.gds-code.
  release buf_goods no-error .
  if error-status:error then do:
    v-mess = substitute("Ошибка при сохранении записи ТОВАР с кодом &1&2&3&2&4"
                             , v-gds-code
                             , {&new-line}
                             , error-status:get-message(1)
                             , return-value ).
    if not p-silent then do:
      message
      v-mess
      view-as alert-box error .
    end.
    undo _main, return error (if p-silent then v-mess else '':U).
  end.
  run ref/dgdsass.p ( input v-gds-code ) no-error .
  if error-status:error then do:
    v-mess = substitute("Ошибка при удалении ассортиментных матриц и ИЖТ по ТОВАРУ с кодом &1&2&3&2&4"
                             , v-gds-code
                             , {&new-line}
                             , error-status:get-message(1)
                             , return-value ).
    if not p-silent then do:
      message
      v-mess
      view-as alert-box error .
    end.
    undo _main, return error (if p-silent then v-mess else '':U).
  end.

end.
p-stts = ?.
end.