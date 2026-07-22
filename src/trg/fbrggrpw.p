block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись группы блюд

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.fbr-gds-grp OLD oldb.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись группы блюд".
{ cmp/vssrevis.i "substitute('&1|&2|&3', ub.fbr-gds-grp.obj-type, ub.fbr-gds-grp.obj-code, ub.fbr-gds-grp.node-code) " }
{ cmp/trg-def.i }
{ gbl/cur-time.i }
{ trg/fgdsgrph.i fbr-gds-grp-trig oldb ub.fbr-gds-grp }

define buffer buf_fbr-gds-grp for ub.fbr-gds-grp.
define buffer other_fbr-gds-grp for ub.fbr-gds-grp.

DEFINE VARIABLE conf-par as character no-undo .
DEFINE VARIABLE par-type as character no-undo .
define variable v-obj-db-num like ub.db.db-num no-undo .
define variable v-l as logical no-undo .
define variable v-fbrggrp-root-code like ub.fbr-gds-grp.node-code no-undo .


/* чтобы не было рекурсивного вызова этого триггера, отключаем его */
on write of ub.fbr-gds-grp override do: end.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  if g#db-num > 0
  and ub.fbr-gds-grp.obj-type = "":U
  and ub.fbr-gds-grp.obj-code = 0
  and not g#news
  then do:
    message
     vss-workfile vss-revision vss-description skip
    "Нельзя изменять запись глобальной ГРУППЫ БЛЮД (рубрикатора) в УБД" skip
    view-as alert-box error .
    undo main-block, return error .

  end.
  if not (g#news and g#db-num = 0)
  and ub.fbr-gds-grp.obj-type <> '':U
  and ub.fbr-gds-grp.obj-code <> 0 then do:
      { gbl/objdbnum.i ub.fbr-gds-grp.obj-type ub.fbr-gds-grp.obj-code v-obj-db-num }
      if v-obj-db-num <> g#db-num then do:
        message
        vss-workfile vss-revision vss-description skip
        "Нельзя изменять запись ГРУППЫ БЛЮД (рубрикатора) в чужой БД" skip
        view-as alert-box error .
        undo main-block, return error .
      end.
  end.

  if ub.fbr-gds-grp.node-code <> oldb.node-code then do:
    /* !!! */
    /* новый узел, т.к. других причин для смены node-code не бывает */

      find buf_fbr-gds-grp
        where buf_fbr-gds-grp.node-code = ub.fbr-gds-grp.upper-code
        AND buf_fbr-gds-grp.obj-type = ub.fbr-gds-grp.obj-type
        AND buf_fbr-gds-grp.obj-code = ub.fbr-gds-grp.obj-code
        no-error .
        if available buf_fbr-gds-grp then
      assign
        ub.fbr-gds-grp.lvl-num = buf_fbr-gds-grp.lvl-num + 1
        buf_fbr-gds-grp.is-term = no
      .
    /*если это изменение терминальности спровоцированное рождением другой группы */
    /*то срабатывания триггера на buf_fbr-gds-grp не будет потому что мы его отключили  */


  end.
  else if ub.fbr-gds-grp.upper-code <> oldb.upper-code then do:
     run fbrglib-get-root-code in this-procedure ( output v-fbrggrp-root-code ) no-error.
    if error-status :error
    then do:
        undo main-block, return error "Не найден корневой узел." + {&new-line} + return-value.
    end.
    if ub.fbr-gds-grp.upper-code = v-fbrggrp-root-code then do:
      find buf_fbr-gds-grp
        where buf_fbr-gds-grp.node-code = v-fbrggrp-root-code
         no-error
        .
    end.
    else do:
      find buf_fbr-gds-grp
        where buf_fbr-gds-grp.node-code = ub.fbr-gds-grp.upper-code
        AND buf_fbr-gds-grp.obj-type = ub.fbr-gds-grp.obj-type
        AND buf_fbr-gds-grp.obj-code = ub.fbr-gds-grp.obj-code no-error
        .
    end.
      if available buf_fbr-gds-grp then
      assign
        buf_fbr-gds-grp.is-term = no
        ub.fbr-gds-grp.lvl-num = if ub.fbr-gds-grp.upper-code = v-fbrggrp-root-code
                                 then 0
                                 else (buf_fbr-gds-grp.lvl-num + 1)
      .
    find first buf_fbr-gds-grp where
             buf_fbr-gds-grp.node-code = oldb.upper-code
          AND buf_fbr-gds-grp.obj-type = ub.fbr-gds-grp.obj-type
          AND buf_fbr-gds-grp.obj-code = ub.fbr-gds-grp.obj-code
             no-error .
    if available buf_fbr-gds-grp
    and not can-find(first other_fbr-gds-grp no-lock where
                           other_fbr-gds-grp.upper-code = buf_fbr-gds-grp.node-code
                        AND other_fbr-gds-grp.obj-type = ub.fbr-gds-grp.obj-type
                        AND other_fbr-gds-grp.obj-code = ub.fbr-gds-grp.obj-code
                      ) then do:

      assign
      buf_fbr-gds-grp.is-term = yes
      .
    end.
  end.
  else do:
    assign
      ub.fbr-gds-grp.is-term = yes
    .
  end.
  run fbr-grp-tree in this-procedure
    (input ub.fbr-gds-grp.node-code
     ,input ub.fbr-gds-grp.obj-type
     ,input ub.fbr-gds-grp.obj-code
    ) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры fbr-grp-tree" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo main-block, return error.
  end.

    run str/callnews.p (
          input "fbr-gds-grp"
        , input (buffer ub.fbr-gds-grp:handle)
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip "Ошибка пересылки группы блюд по новостям."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo main-block, return error .
    end.

   /*создаем batchporcess для отсылки на кассы*/
   if ub.fbr-gds-grp.obj-type <> "":U
   AND ub.fbr-gds-grp.obj-code <> 0 then do:
     find first buf_fbr-gds-grp where
               buf_fbr-gds-grp.node-code = ub.fbr-gds-grp.upper-code
            AND buf_fbr-gds-grp.obj-type = ub.fbr-gds-grp.obj-type
            AND buf_fbr-gds-grp.obj-code = ub.fbr-gds-grp.obj-code no-error.

      if available buf_Fbr-gds-grp then do:
        { ref/send-ref.i conf-par par-type }
        if not g#news and send-ref then do:
          /*выясним что изменилось*/
          assign
          v-l = yes
          .
          buffer-compare ub.fbr-gds-grp using
          out-code
          upper-code
          node-name
          to oldb
          case-sensitive
          save result in v-l .
          if not v-l then do:
            run trg/nu_fgrp.p (
                          input  ub.fbr-gds-grp.obj-type
                          ,input  ub.fbr-gds-grp.obj-code
                          ,input  ub.fbr-gds-grp.node-code
                          ,input  ub.fbr-gds-grp.upper-code
                          ,input  ub.fbr-gds-grp.out-code
                          ,input  buf_Fbr-gds-grp.out-code
                          ,input  ub.Fbr-gds-grp.lvl-num
                          ,input  "U":U
                          ).
          end.
      end.
     end.
   end.
    /* пишем историю */
    if not g#news
    and not new(ub.fbr-gds-grp)
    then do:
      buffer-compare oldb to ub.fbr-gds-grp
      case-sensitive
      save result in v-l.
    end.
    if not v-l or new(ub.fbr-gds-grp) then
    run fbr-gds-grph_write-fbr-gds-grp-trigger in this-procedure (
                                                            new(ub.fbr-gds-grp)
                                                          ,"":U
                                                          ,"":U
                                                          , (if new(ub.fbr-gds-grp) then integer({&hn-create}) else integer({&hn-update}))
                                                          ).

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_fbr-gds-grp}
        , input ( buffer ub.fbr-gds-grp:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
end.

procedure fbr-grp-tree :

  define input  parameter nc       as integer   no-undo .
  define input parameter p-obj-type like ub.fbr-gds-grp.obj-type no-undo .
  define input parameter p-obj-code like ub.fbr-gds-grp.obj-code no-undo .

  def buffer buf_fbr-gds-grp for ub.fbr-gds-grp .

  do
  on error undo, return error return-value
  :

    for each buf_fbr-gds-grp
      where buf_fbr-gds-grp.upper-code = nc
      AND buf_fbr-gds-grp.obj-type = p-obj-type
      AND buf_fbr-gds-grp.obj-code = p-obj-code
    on error undo, return error
    :
      if nc = ub.fbr-gds-grp.node-code then do:
        assign
          ub.fbr-gds-grp.is-term = no
        .
      end.
      run fbr-grp-tree
        (input buf_fbr-gds-grp.node-code
         ,input buf_fbr-gds-grp.obj-type
         ,input buf_fbr-gds-grp.obj-code

        ).
    end.
  end.
end procedure.


procedure fbrglib-get-root-code :
do
on error undo, return error
:
define output parameter p-root-code as integer      no-undo.

    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.

    find first buf_fbr-gds-grp no-lock
         where buf_fbr-gds-grp.upper-code = 0
    no-error .
    if not available buf_fbr-gds-grp
    then do:
        undo, return error .
    end.
    else do:
        assign
            p-root-code = buf_fbr-gds-grp.node-code
        .
    end.
end.
end procedure. /* fbrglib-get-root-code */