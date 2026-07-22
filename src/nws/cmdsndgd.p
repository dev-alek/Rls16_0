block-level on error undo, throw.
/*

$Revision: a38042964324, 1747, rls $
$Author: ASMorozov $
$Date: Thu Jan 24 17:02:17 2019 +0300 $
$Workfile: cmdsndgd.p $
$Archive: nws/cmdsndgd.p $

Отправить в ГБД информацию обо всех товарах по указанному объекту

Автор: Перваков Михаил Сергеевич
Дата создания: 03/16/05
Author: Mikhail Pervakov
Creation date: 03/16/05

*/

define input  parameter p-imp-handle as handle    no-undo .
define input  parameter p-counter    as integer   no-undo .
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: a38042964324, 1747, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Jan 24 17:02:17 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cmdsndgd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: nws/cmdsndgd.p $":U .
define variable vss-description as character no-undo init "Отправить в ГБД информацию обо всех товарах по указанному объекту".
{ cmp/vssrevis.i "substitute('&1|&2|&3':u,p-counter,p-obj-type,p-obj-code)" }
{ cmp/trg-def.i  }
{ gbl/waitfram.i }

define variable v-cmd-proc-handle as handle    no-undo .
define variable v-cmd-code1       as integer   no-undo .
define variable v-object-exist    as logical   no-undo .
define variable v-rec-ord         as integer   no-undo .

define buffer buf_gds-obj      for ub.gds-obj .
define buffer buf_prt-obj      for ub.prt-obj .
define buffer buf_parts        for ub.parts .
define buffer buf_batchprocess for ub.batchprocess .

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:


  define variable conf-par as character no-undo.
  define variable mode-erprn as logical no-undo.
  define variable par-type as character no-undo.
    { gbl/conf-rd.i
    "'is-erpRN'"
    0
    "''"
    0
    "''"
    "''"
    "''"
    NO
    conf-par
    par-type
    no-error
    }
  if not error-status:error and conf-par = "yes":u then mode-erprn = yes.
  else mode-erprn = no.
  if mode-erprn 
  then do:
    /* "При включенном параметре is-erpRN запуск распределенной проверки остатков по товарам невозможен." view-as alert-box information title "Внимание".*/
    return.
  end.

  if p-obj-type = ?
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Неизвестное значение типа объекта" skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if p-obj-code = ?
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Неизвестное значение кода объекта" skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  { gbl/objat.i
    p-obj-type
    p-obj-code
    "'check-exist':u"
    v-object-exist
    no-error
  }
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при проверке существования объекта" skip
      "Не найден объект" skip
      "Объект" p-obj-type p-obj-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  /* блокируем создание gds-obj */
  run gbl/lockgdoc.p
    (input  p-obj-type                  /* p-obj-type        */
    ,input  p-obj-code                  /* p-obj-code        */
    ,input  {&lock-prc-gds-obj-create}  /* p-lock-gds-type   */
    ,input  {&lock-prc-subtype-disable} /* p-sub-type        */
    ,buffer buf_batchprocess            /* lock_batchprocess */
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при проверке возможности создания записей товара на объекте" skip
      "Объект" p-obj-type p-obj-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  do transaction
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    /* блокируем все gds-obj */
    define variable v-ind as integer   no-undo .

    assign
      v-ind = 0
    .
    for each buf_gds-obj exclusive-lock
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Блокировка товаров на объекте. Объект &1 &2. Заблокировано товаров &3. Артикул &4", p-obj-type, p-obj-code, v-ind, buf_gds-obj.artic)
          ) .
      end.
    end.

    /* инициализируем библиотеку формирования команды */
    run nws/cmd-bush.p persistent set v-cmd-proc-handle
      no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute("Ошибка при запуске процедуры cmd-bush.p") skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      delete procedure v-cmd-proc-handle .
      undo, return error return-value .
    end.

    /* начало формирования команды */
    run begin-create-command in v-cmd-proc-handle
      (input  {&cmd-transfer-goods} + {&delim-cmd} + string(p-obj-type) + {&delim-cmd} + string(p-obj-code) /* p-command-name */
      ,input "":U                                                                                           /* p-db-list      */
      ,output v-cmd-code1                                                                                   /* p-command-code */
      ) no-error.
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Ошибка при создании команды &1", {&cmd-transfer-goods} ) skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      delete procedure v-cmd-proc-handle .
      undo, return error return-value .
    end.

    /* отправляем информацию об остатках по всем товарам */
    assign
      v-ind = 0
    .

    for each buf_gds-obj exclusive-lock
      where buf_gds-obj.obj-type = p-obj-type
        and buf_gds-obj.obj-code = p-obj-code
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Отправка информации о товарах на объекте в ГБД. Объект &1 &2. Отправлено товаров &3. Артикул &4", p-obj-type, p-obj-code, v-ind, buf_gds-obj.artic)
          ) .
      end.

      run add-dump in v-cmd-proc-handle
        (input v-cmd-code1                  /* p-command-code */
        ,input {&table_gds-obj}             /* p-dump-name    */
        ,input '+update':U
        ,input (buffer buf_gds-obj :handle) /* p-tbl-handle   */
        ,input '':U
        ,output v-rec-ord
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          substitute( "Ошибка при добавлении записи &1 в команду с кодом &2", {&table_gds-obj}, v-cmd-code1 ) skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        delete procedure v-cmd-proc-handle .
        undo, return error return-value .
      end.

      /* все остатки по признакам */
      for each buf_prt-obj share-lock
        where buf_prt-obj.obj-type = p-obj-type
          and buf_prt-obj.obj-code = p-obj-code
          and buf_prt-obj.artic    = buf_gds-obj.artic
          and buf_prt-obj.prod-type = buf_gds-obj.prod-type
          and buf_prt-obj.prod-code = buf_gds-obj.prod-code
      on error undo, return error return-value
      :
        run add-dump in v-cmd-proc-handle
          (input v-cmd-code1                  /* p-command-code */
          ,input {&table_prt-obj}             /* p-dump-name    */
          ,input '+update':U
          ,input (buffer buf_prt-obj :handle) /* p-tbl-handle   */
          ,input '':U
          ,output v-rec-ord
          ) no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            substitute( "Ошибка при добавлении записи &1 в команду с кодом &2", {&table_prt-obj}, v-cmd-code1 ) skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          delete procedure v-cmd-proc-handle .
          undo, return error return-value .
        end.
      end.

      /* все партии свободной зоны */
      for each buf_parts share-lock
        where buf_parts.obj-type  = p-obj-type
          and buf_parts.obj-code  = p-obj-code
          and buf_parts.artic     = buf_gds-obj.artic
          and buf_parts.prod-type = buf_gds-obj.prod-type
          and buf_parts.prod-code = buf_gds-obj.prod-code
          and buf_parts.rsrv-free = yes
          and buf_parts.status_   = no
          and buf_parts.in-code   <> buf_parts.out-code
      on error undo, return error return-value
      :
        run add-dump in v-cmd-proc-handle
          (input v-cmd-code1                /* p-command-code */
          ,input {&table_parts}             /* p-dump-name    */
          ,input '+update':U
          ,input (buffer buf_parts :handle) /* p-tbl-handle   */
          ,input '':U
          ,output v-rec-ord
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            substitute( "Ошибка при добавлении записи &1 в команду с кодом &2", {&table_parts}, v-cmd-code1 ) skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          delete procedure v-cmd-proc-handle .
          undo, return error return-value .
        end.
      end.
    end.

    /* завершить формирование команды и отправить информацию по новостям */
    run send-command in v-cmd-proc-handle
      ( input v-cmd-code1 /* p-command-code */
      ,input "0"          /* p-db-list      */
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Ошибка при отправке в новости команды с кодом &1", v-cmd-code1 ) skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      delete procedure v-cmd-proc-handle .
      undo, return error return-value .
    end.
  end.

  delete procedure v-cmd-proc-handle .
end.