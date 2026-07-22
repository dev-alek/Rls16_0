block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись группы клиентов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/


TRIGGER PROCEDURE FOR WRITE OF ub.cli-grp OLD oldb.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись группы клиентов".
{ cmp/vssrevis.i "substitute('&1|&2|&3',ub.cli-grp.node-code,ub.cli-grp.upper-code,ub.cli-grp.node-name)" }
{ cmp/trg-def.i }
{ ref/cgrplbfn.i }
{ trg/clientsh.i }
{ gbl/cur-time.i }
{ trg/cli-grph.i cli-grp-trig oldb ub.cli-grp }

define buffer b-cli-grp for ub.cli-grp.
define buffer other_cli-grp for ub.cli-grp.
define variable name as char no-undo.
define variable uc as int no-undo.
define variable skip-proc as log no-undo.                  /* неважное поле */
define variable v-changed-node-code like ub.cli-grp.node-code no-undo .
define variable v-changed-node-code-2 like ub.cli-grp.node-code no-undo .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-only-is-term as logical no-undo .
define variable v-chr as character no-undo .
define buffer buf_dis-grp-rule for ub.dis-grp-rule.
define buffer buf2_dis-grp-rule for ub.dis-grp-rule.
define buffer buf_clients for ub.clients.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  if not g#news and ( g#db-num > 0 ) then do:
    message
    vss-workfile vss-revision vss-description skip
    "Нельзя изменять запись ГРУППЫ КЛИЕНТОВ в УБД" skip
    "Номер текущей БД" g#db-num
    view-as alert-box error .
    undo main-block, return error .
  end.

  /* отменяем триггер для ускорения - товары / клиенты в новости не идут, передается 1 команда */
  on write of ub.clients override do: end.

  /* чтобы не было рекурсивного вызова этого триггера, отключаем его */
  on write of ub.cli-grp override do: end.

  on write of ub.c-clients override do: end.
  on write of ub.c-cli-hist override do: end.


  /* собираем полное имя, игнорируя корневой узел */
  run cli-grplib-get-full-name in this-procedure
    (input ub.cli-grp.node-code
    ,output name
    ).

  /* добавление нового узла */
  if oldb.node-code <> ub.cli-grp.node-code
  then do:
    /* новый узел, т.к. других причин для смены node-code не бывает
     - переносим всех клиентов из вышестоящего узла */
    find b-cli-grp
      where b-cli-grp.node-code = ub.cli-grp.upper-code
      .
    assign
      cli-grp.lvl-num = b-cli-grp.lvl-num + 1
       b-cli-grp.is-term = no
    .
    /*если это изменение терминальности спровоцированное рождением другой группы */
    /*то срабатывания триггера на b-gds-grp не будет потому что мы его отключили  */

  assign
  v-changed-node-code = ub.cli-grp.node-code
  .


    for each buf_clients
      where buf_clients.grp-code = b-cli-grp.node-code
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :

      run clientsh_write-clients-proc  in this-procedure (
                                                           buffer buf_clients
                                                          ,input {&hn-source-grp-chg}
                                                          ,input string(ub.cli-grp.node-code)
                                                          ).
      assign
      buf_clients.grp-code = ub.cli-grp.node-code
      .
    end.

    /* теперь перенесем скидку, если она есть */
    for each buf_dis-grp-rule share-lock where
            buf_dis-grp-rule.classif-type = {&table_cli-grp}
        and buf_dis-grp-rule.node-code = b-cli-grp.node-code
        and buf_dis-grp-rule.host-code = 0
        and buf_dis-grp-rule.obj-type = '':U
        and buf_dis-grp-rule.obj-code = 0
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
       create buf2_dis-grp-rule.
       buffer-copy buf_dis-grp-rule except node-code to buf2_dis-grp-rule
       assign
       buf2_dis-grp-rule.node-code = ub.cli-grp.node-code
       .
       delete buf_dis-grp-rule.
    end.
  end.
  else if ub.cli-grp.upper-code <> oldb.upper-code then do:
      find b-cli-grp  where
        b-cli-grp.node-code = ub.cli-grp.upper-code no-wait no-error.
    if not available b-cli-grp then do:
       undo main-block, return error substitute("cli-grp with node-code &1 is locked", ub.cli-grp.upper-code).
    end.

    assign
    b-cli-grp.is-term = no
    ub.cli-grp.lvl-num = b-cli-grp.lvl-num + 1
    .
    find first b-cli-grp where
             b-cli-grp.node-code = oldb.upper-code no-wait no-error.
    if locked(b-cli-grp) then do:
      undo main-block, return error substitute("cli-grp with node-code &1 is locked", oldb.upper-code) .
    end.
    else do:
      if available b-cli-grp then do:
        if not can-find(first other_cli-grp no-lock where
                              other_cli-grp.upper-code = oldb.upper-code
                          AND recid(other_cli-grp) <> recid(ub.cli-grp)) then do:

          assign
          b-cli-grp.is-term = yes
          .
        end.
      end. /*if available b-cli-grp then do*/
    end. /*not locked*/
  end. /*if ub.cli-grp.upper-code <> oldb.upper-code then do:*/

  /* переписываем полный путь во всех клиентах или товарах + gds-obj поддерева */
  buffer-compare oldb to ub.cli-grp
  case-sensitive
  save result in v-chr.
  if v-chr = "is-term":U then do:
    assign
    v-only-is-term = yes
    .
  end.

  assign
    ub.cli-grp.is-term = yes
  .
  assign
  v-changed-node-code-2 = ub.cli-grp.node-code
  .
  run grp-tree in this-procedure
    (input ub.cli-grp.node-code
    ,input name
    ) no-error.
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры grp-tree" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo main-block, return error.
  end.

  /* признак изменения справочника */
  define variable v-synch-cli-grp as integer   no-undo .
  assign
    v-synch-cli-grp = next-value (synch-cli-grp, {&db-name_schema})
  .

  /* СПН */
  run str/callnews.p
    (input {&table_cli-grp}
    ,input (buffer ub.cli-grp:handle)
    ) no-error .
  if error-status :error then do:
    message
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box.
    undo main-block, return error.
  end.

  /* пишем историю */
  if not g#news then do:
    define variable v-l as logical no-undo .
    buffer-compare oldb to ub.cli-grp
    case-sensitive
    save result in v-l.
    if not v-l then
    run cli-grph_write-cli-grp-trigger in this-procedure (
                                                            new(ub.cli-grp)
                                                           ,"":U
                                                           ,"":U
                                                           , (if new(ub.cli-grp) then integer({&hn-create}) else integer({&hn-update}))
                                                           ).

  end.
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_cli-grp}
        , input ( buffer ub.cli-grp:handle )
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
    if new(ub.cli-grp) then 
  do:   
    run trg/userlog.p (
      input {&nwsdochs_action_create}
      , input {&table_cli-grp}
      , input ( buffer ub.cli-grp :handle )
      , input ?
      , input ""
      ) no-error.
    if error-status :error
      then 
    do:
      undo, return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
        , {&new-line}
        , vss-workfile
        , return-value
        , error-status :get-message ( 1 ) ).
    end.
  end. 
  else 
  do:
    run trg/userlog.p (
      input {&nwsdochs_action_update}
      , input {&table_cli-grp}
      , input ( buffer ub.cli-grp :handle )
      , input ?
      , input ""
      ) no-error.
    if error-status :error
      then 
    do:
      undo, return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
        , {&new-line}
        , vss-workfile
        , return-value
        , error-status :get-message ( 1 ) ).
    end.

  end.  
END.


procedure grp-tree :

  define input param nc as int no-undo.
  define input param cur-name as char no-undo.
  define buffer b-g-g for ub.cli-grp.
  main-block:
  do
  on error undo, return error return-value
  :
    for each b-g-g
      where b-g-g.upper-code = nc
      on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
      on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
      :

      if nc = ub.cli-grp.node-code then do:
        assign
          ub.cli-grp.is-term = no
        .
      end.
      run grp-tree in this-procedure
        (input b-g-g.node-code
        ,input trim(cur-name, {&delim-grp}) + (if cur-name = "":U then "":U else {&delim-grp}) + b-g-g.node-name
        ).
    end.

    for each ub.clients
      where ub.clients.grp-code = nc
      on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
      on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
      :

      if v-changed-node-code <> nc
      and not v-only-is-term
      then do:
        run clientsh_write-clients-proc  in this-procedure (
                                                              buffer ub.clients
                                                            ,input {&hn-source-grp-chg}
                                                            ,input string(v-changed-node-code-2)
                                                            ).
      end.

      assign
        ub.clients.grp-name = trim(cur-name , {&delim-grp}) + {&delim-grp}
      .
    end.
  end.
end procedure.