block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rkepsygg.p $
$Archive: str/rkepsygg.p $

Синхронизация дерева групп блюд в IBS TH с деревом блюд на кассе R-keeper

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/18/05
Author: Bakhtadze Natalya
Creation date: 02/18/05

*/


define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-rid-list as character no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rkepsygg.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/rkepsygg.p $":U .
define variable vss-description as character no-undo init "Синхронизация дерева групп блюд в IBS TH с деревом блюд на кассе R-keeper".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ ref/fbrglib.i     }
{ str/libbcrcn.i }
{ str/r-keepth.i }


define variable log-file-name                as character      no-undo init "rkepsyn.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .

DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE ii0 AS INTEGER NO-UNDO.
define variable ii-ok as integer no-undo .
define variable v-lvl-num as integer no-undo .
define variable v-upper-num as character no-undo .
define variable v-stop-state as logical no-undo .
define variable v-fbrggrp-root-code like ub.fbr-gds-grp.node-code no-undo .

define buffer buf_cd-grp for ub.cd-grp.
define buffer upper_cd-grp for ub.cd-grp.
define buffer buf_fbr-gds-grp for ub.fbr-gds-grp.
define buffer upper_fbr-gds-grp for ub.fbr-gds-grp.


define temp-table tt-cd-grp no-undo like ub.cd-grp
field lvl-num as integer
index pi is unique primary grp-code
index ilvl lvl-num
.

assign
ii0 = num-entries(p-rid-list)
.

/*сначала перепишем все во временную таблицу*/
for each tt-cd-grp:
  delete tt-cd-grp.
end.

_ii:
DO ii = 1 TO ii0:

   FIND FIRST buf_cd-grp Exclusive-lock WHERE
            RECID(buf_cd-grp) = INTEGER(ENTRY(ii, p-rid-list)) NO-ERROR.
   IF not AVAILABLE  buf_cd-grp  THEN do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("Не найдена или занята запись группы блюд на кассе R-keeper c recid &1", INTEGER(ENTRY(ii, p-rid-list)))).
      assign
      v-view-log = yes.
      next _ii.
   end.
  create tt-cd-grp.
  buffer-copy buf_cd-grp to tt-cd-grp
  assign
  tt-cd-grp.lvl-num = buf_cd-grp.key#_one
  .
end.

do
on error undo, return error
:

  run fbrglib-get-root-code in this-procedure ( output v-fbrggrp-root-code ) no-error.
  if error-status :error
  then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("Не найден корневой узел дерева групп блюд для &1&2", p-curr-obj-type, p-curr-obj-code)).
      assign
      v-view-log = yes.
      return.
  end.

  ii = 0.
  _tt:
  for each tt-cd-grp no-lock
        by tt-cd-grp.lvl-num:
    ii = ii + 1.
    /*найдем fbr-gds-grp на данном объекте с данным out-code */
    find first buf_Fbr-gds-grp exclusive-lock where
              buf_Fbr-gds-grp.obj-type = p-curr-obj-type
        AND  buf_Fbr-gds-grp.obj-code = p-curr-obj-code
        and  buf_Fbr-gds-grp.out-code = tt-cd-grp.grp-code NO-WAIT no-error .
    if not available buf_Fbr-gds-grp and not locked buf_Fbr-gds-grp then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Группа блюд на кассе R-KEEPER с кодом &1 <&2>&3 - не найдена соответствующая группа блюд на  &4&5 в IBS TH"
                              , tt-cd-grp.grp-code
                              , tt-cd-grp.grp-name
                              , {&new-line}
                              , p-curr-obj-type
                              , p-curr-obj-code
                            )).
      assign
      v-view-log = yes.
      next _tt.
    end.
    if locked buf_Fbr-gds-grp then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Группа блюд на кассе R-KEEPER с кодом &1 <&2>&3 - запись для соответствующей группа блюд на &4&5 в IBS TH ЗАНЯТА"
                              , tt-cd-grp.grp-code
                              , tt-cd-grp.grp-name
                              , {&new-line}
                              , p-curr-obj-type
                              , p-curr-obj-code
                            )).
      assign
      v-view-log = yes.
      next _tt.
    end.
    /*найдем группу куда перепривязывать*/
    if tt-cd-grp.upper-grp-code = 0 then do:
      find first upper_fbr-gds-grp exclusive-lock where
                upper_fbr-gds-grp.node-code = v-fbrggrp-root-code NO-WAIT no-error .
    end.
    else do:
      find first upper_fbr-gds-grp exclusive-lock where
                upper_fbr-gds-grp.obj-type = p-curr-obj-type
          AND  upper_fbr-gds-grp.obj-code = p-curr-obj-code
          and  upper_fbr-gds-grp.out-code = tt-cd-grp.upper-grp-code NO-WAIT no-error .
    end.
    if not available upper_fbr-gds-grp and not locked upper_fbr-gds-grp then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Группа блюд на кассе R-KEEPER с кодом &1 <&2>&3 - не найдена соответствующая группа блюд на  &4&5 в IBS TH"
                              , tt-cd-grp.upper-grp-code
                              , tt-cd-grp.grp-name
                              , {&new-line}
                              , p-curr-obj-type
                              , p-curr-obj-code
                            )).
      assign
      v-view-log = yes.
      next _tt.
    end.
    if locked upper_fbr-gds-grp then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Группа блюд на кассе R-KEEPER с кодом &1 <&2>&3 - запись для соответствующей группы блюд на &4&5 в IBS TH ЗАНЯТА"
                              , tt-cd-grp.upper-grp-code
                              , tt-cd-grp.grp-name
                              , {&new-line}
                              , p-curr-obj-type
                              , p-curr-obj-code
                            )).
      assign
      v-view-log = yes.
      next _tt.
    end.
    /*перепривяжем если надо*/
    if buf_fbr-gds-grp.node-code <> upper_fbr-gds-grp.node-code then do:
      run move-item in this-procedure (
                                        input p-curr-obj-type
                                        ,input p-curr-obj-code
                                        ,input buf_fbr-gds-grp.node-code
                                        ,input upper_fbr-gds-grp.node-code
                                        ,input buf_fbr-gds-grp.out-code
                                        ,input upper_fbr-gds-grp.out-code
                                      ) no-error .
      if error-status:error then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "!!!Ошибка при привязке группа блюд с кодом на кассе &1 <&2>&3" +
                                "к группе блюд с кодом на кассе &4 <&5>&3" +
                                "&6 &7"
                                , buf_fbr-gds-grp.out-code
                                , buf_fbr-gds-grp.node-name
                                , {&new-line}
                                , upper_fbr-gds-grp.out-code
                                , upper_fbr-gds-grp.node-name
                                , error-status:get-message(1)
                                , return-value
                              )).
        assign
        v-view-log = yes.
        next _tt.
      end.
    end.  /* if buf_fbr-gds-grp.node-code <> upper_fbr-gds-grp.node-code then do: */
    ii-ok = ii-ok + 1.
    run show-counter in p-log-handle .
    run write-counter in p-log-handle (substitute("Обработано &1 групп блюд, из них упешно &2"
                                      , ii
                                      , ii-ok
                                      )) no-error.
    run get-stop-state in p-log-handle(output v-stop-state).
    if v-stop-state then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Процесс прерван пользователем"
                            )).
      assign
      v-view-log = yes.
      LEAVE _tt.
    end.
  end. /*for eac tt-cd-grp*/

  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!Из &1 групп блюд успешно синхронизировано &2"
                          , ii0
                          , ii-ok
                        )).

end. /*doe*/

PROCEDURE move-item :
do
on error undo, return error
:
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-node-code  as integer      no-undo.   /* Группа, которую перемещаем */
define input parameter p-upper-code as integer      no-undo.   /* Группа, к которой присоединяем */
define input parameter p-out-code  as integer      no-undo.   /* Группа, которую перемещаем */
define input parameter p-upper-out-code as integer      no-undo.   /* Группа, к которой присоединяем */


    define variable v-node-full-name    as character    no-undo.
    define variable v-upper-full-name   as character    no-undo.
    define variable v-focused-row       as integer      no-undo.
    define variable v-have-goods        as logical      no-undo.

    define buffer buf_fbr-gds-grp           for ub.fbr-gds-grp.
    define buffer buf_upper_fbr-gds-grp     for ub.fbr-gds-grp.

    run fbrglib-have-goods in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input p-upper-code
        , output v-have-goods
    ) no-error .
    if error-status :error
    then do:
        undo, return error "move-item: Ошибка определения наличия товаров в группе." + {&new-line} + return-value.
    end.
    if v-have-goods = yes
    then do:
      undo, return error substitute("Нельзя переместить группу с кодом на кассе &1 в группе с кодом на кассе &2&3" +
                                    "т.к. в одной группе не могут быть одновременно подгруппы и товары."
                                    ,p-out-code
                                    ,p-upper-out-code
                                    , {&new-line}
                                    ).

    end.
    run fbrglib-get-full-name in this-procedure (
              input p-obj-type
            , input p-obj-code
            , input p-node-code
            , output v-node-full-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "move-item: Ошибка вычисления полного имени перемещаемой группы".
    end.
    run fbrglib-get-full-name in this-procedure (
              input p-obj-type
            , input p-obj-code
            , input p-upper-code
            , output v-upper-full-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "move-item: Ошибка вычисления полного имени группы".
    end.
    if v-upper-full-name begins v-node-full-name
    then do:
      undo, return error substitute("Группу  c кодом на кассе &1 нельзя переместить в ее собственную подгруппу."
                                    ,p-out-code
                                    ).
    end.
    do transaction
    on error undo, return error "move-item: Ошибка перемещения группы.".
        find first buf_fbr-gds-grp exclusive-lock
             where buf_fbr-gds-grp.obj-type     = p-obj-type
               and buf_fbr-gds-grp.obj-code     = p-obj-code
               and buf_fbr-gds-grp.node-code    = p-node-code
        no-error .
        if not available buf_fbr-gds-grp
        then do:
            undo, return error "move-item: Не найдена группа для перемещения.".
        end.
        assign
            buf_fbr-gds-grp.upper-code = p-upper-code
        .
    end.
end.
END PROCEDURE. /* move-item */