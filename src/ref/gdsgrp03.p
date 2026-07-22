block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: gdsgrp03.p $
$Archive: ref/gdsgrp03.p $

Удаление группы товаров

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/18/09
Author: Bakhtadze Natalya
Creation date: 02/18/09

*/

/*
Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/

define input parameter p-silent as logical no-undo .
define input parameter p-rid as recid no-undo .
define input parameter p-child-grp-behavior as character no-undo .
define input parameter p-child-gds-behavior as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gdsgrp03.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/gdsgrp03.p $":U .
define variable vss-description as character no-undo init "Удаление группы товара".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ ref/grplib.i }
{ ref/grpobj.i }
{ str/tt-tax.i "NEW SHARED" tt-tax full }

DEFINE VARIABLE v-full-name as character no-undo .
DEFINE VARIABLE v-error-message as character no-undo .
DEFINE VARIABLE v-node-code like ub.gds-grp.node-code no-undo .
define variable v-answer as logical no-undo .
define variable v-root-code as integer no-undo .
define variable v-counter as integer no-undo .
define variable v-upper-code as integer no-undo .
define variable v-is-terminal as logical no-undo .
define variable v-have-goods as logical no-undo .

define buffer upper_gds-grp  for ub.gds-grp.
define buffer buf_gds-grp for ub.gds-grp.
define buffer buf2_gds-grp for ub.gds-grp.
define buffer buf_same_gds-grp for ub.gds-grp.

main-block:
do
on error undo, return error
:
  if g#db-num <> 0 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Нельзя удалять группы клиентов в УБД"
    view-as alert-box error .
    undo main-block, return error .
  end.
  find first buf_gds-grp exclusive-lock where
            recid(buf_gds-grp) = p-rid no-error .
  if not avail buf_gds-grp then do:
    assign
    v-error-message = substitute("Не найдена группа товаров, которую предполагается удалить (recid=&1)", p-rid).
    run err-mess in this-procedure ( input-output v-error-message).
    undo main-block, return error (if p-silent then v-error-message else "node-code").
  end.
  run grplib-get-root-code in this-procedure ( output v-root-code ) no-error.
  if buf_gds-grp.node-code = v-root-code
  then do:
    v-error-message = "Нельзя удалить корневую группу.".
    run err-mess in this-procedure ( input-output v-error-message).
    undo main-block, return error (if p-silent then v-error-message else "").
  end.
  /*---START--------- Нельзя удалить последнюю группу первого уровня ---------------------*/
  if buf_gds-grp.upper-code = v-root-code then do:
    assign
        v-counter = v-counter + 1
    .
    count-first-level-grp:
    for each buf2_gds-grp no-lock
        where buf2_gds-grp.upper-code = v-root-code
    :
      assign
          v-counter = v-counter + 1
      .
      if v-counter > 1
      then do:
          leave count-first-level-grp.
      end.
      else do:
        v-error-message = "Нельзя удалить последнюю группу первого уровня.".
        run err-mess in this-procedure ( input-output v-error-message).
        undo main-block, return error (if p-silent then v-error-message else "").
      end.
    end. /*for each buf2_gds-grp no-lock*/
  end.
  /*---END----------- Нельзя удалить последнюю группу первого уровня ---------------------*/
  assign
  v-upper-code    = buf_gds-grp.upper-code
  v-answer        = no
  .
  run grplib-is-terminal in this-procedure ( input buf_gds-grp.node-code, output v-is-terminal ) no-error.
  if error-status :error
  then do:
    v-error-message = substitute("Ошибка при определении терминальности группы:&1&2&1&3"
                                  , {&new-line}
                                  , error-status:get-message(1)
                                  , return-value ).
    run err-mess in this-procedure ( input-output v-error-message).
    undo main-block, return error (if p-silent then v-error-message else "").
  end.
  if v-is-terminal = no
  then do:
  /* проверяем, не имеет ли одна из подгрупп такое же название, как и соседняя к удаляемой */
    for each buf2_gds-grp
    where buf2_gds-grp.upper-code = v-upper-code
      and buf2_gds-grp.node-code <> buf_gds-grp.node-code
    :
      find first buf_same_gds-grp no-lock
          where buf_same_gds-grp.upper-code  = buf_gds-grp.node-code
          and buf_same_gds-grp.node-name   = buf2_gds-grp.node-name
      no-error.
      if available buf_same_gds-grp
      then do:
        v-error-message = substitute("Одна из подгрупп удаляемой группы имеет название:&1&2&1-"  +
                                    "такое же, как одна из соседних к удаляемой групп.&1-" +
                                    "После удаления получились бы 2 группы на одном уровне, имеющие одинаковые названия, что запрещено."
                                      , {&new-line}
                                      , buf_gds-grp.node-name
                                    ).
      end.
    end.
    if p-silent then do:
      if p-child-grp-behavior = "up" then do:
        v-answer = yes.
      end.
      else do:
        v-error-message = substitute("В удаляемой группе есть подгруппы").
        run err-mess in this-procedure ( input-output v-error-message).
        undo main-block, return error (if p-silent then v-error-message else "").
      end.
    end.
    else do:
      if p-child-grp-behavior = "up" then do:
        message
        substitute("Текущая группа будет удалена.&1" +
                    "Ее подгруппы будут перенесены в вышестоящую группу.&1&1" +
                  "Слить группу с вышестоящей?"
                  , {&new-line})
        view-as alert-box question buttons yes-no update v-answer.
      end.
      else do:
        v-error-message = substitute("В удаляемой группе есть подгруппы").
        run err-mess in this-procedure ( input-output v-error-message).
        undo main-block, return error (if p-silent then v-error-message else "").
      end.
    end.
  end.
  if v-is-terminal = yes
  then do:
    run grplib-have-goods in this-procedure (
          input buf_gds-grp.node-code
        , output v-have-goods
    ) no-error .
    if error-status :error
    then do:
      v-error-message = substitute("Ошибка определения наличия товаров в группе.&1&2&1&3"
                                  ,{&new-line}
                                  , error-status:get-message(1)
                                  ,return-value).
      run err-mess in this-procedure ( input-output v-error-message).
      undo main-block, return error (if p-silent then v-error-message else "").
    end.
    if v-have-goods = yes
    then do:
      if p-child-gds-behavior = "up" then do:
        find first buf2_gds-grp no-lock
              where buf2_gds-grp.upper-code = v-upper-code
                and buf2_gds-grp.node-code <> buf_gds-grp.node-code
        no-error .
        if available buf2_gds-grp
        then do:
          v-error-message = substitute("В одной группе не могут быть одновременно подгруппы и товары.&1" +
                                          "Эта группа не может быть слита с вышестоящей."
                                          , {&new-line}).
          run err-mess in this-procedure ( input-output v-error-message).
          undo main-block, return error (if p-silent then v-error-message else "").
        end.
        if  p-silent then do:
          v-answer = yes.
        end.
        else do:
          message
          "Текущая группа будет удалена." skip
          "Товары будут перенесены в вышестоящую группу." skip (1)
          "Слить группу с вышестоящей?"
          view-as alert-box question buttons yes-no update v-answer.
        end.
      end.
      else do:
        v-error-message = substitute("В удаляемой группе есть товары").
        run err-mess in this-procedure ( input-output v-error-message).
        undo main-block, return error (if p-silent then v-error-message else "").
      end.
    end.
    else do:
      if p-silent then do:
        v-answer = yes.
      end.
      else do:
        message
        "Удалить группу ? Вы уверены ?"
        view-as alert-box question buttons yes-no update v-answer.
      end.
    end.
  end.
  if not v-answer
  then do:
     return 'no-apply'.
  end.
  delete-from-base:
  do
  ON ERROR UNDO delete-from-base, return no-apply
  ON stop UNDO delete-from-base, return no-apply:
    delete buf_gds-grp no-error.
    if error-status:error then do:
      v-error-message = substitute("Ошибка при удалении из БД:&1&2&1&3"
                                  , {&new-line}
                                  , error-status:get-message(1)
                                  , return-value
                                  ).
    end.
  end.
  find first buf_gds-grp no-lock
        where buf_gds-grp.node-code = v-upper-code
  no-error.
  if not available buf_gds-grp
  then do:
    v-error-message = substitute("После удаления не найдена вышестоящая группа с вн.кодом &1"
                                 , v-upper-code).
    run err-mess in this-procedure ( input-output v-error-message).
    undo main-block, return error (if p-silent then v-error-message else "").
  end.
end.


PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Группа c внутр. №: &1 (&2):&3&4"
                         , buf_gds-grp.node-code
                         , buf_gds-grp.node-name
                         , {&new-line}
                         , p-mess)
      .
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.