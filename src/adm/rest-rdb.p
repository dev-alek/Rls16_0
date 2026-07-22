block-level on error undo, throw.
/*

$Revision: f29df1d5f130, 3104, rls $
$Author: DRuban $
$Date: Вт авг 09 09:15:01 2022 +0300 $
$Workfile: rest-rdb.p $
$Archive: adm/rest-rdb.p $

Добавление и восстановление УБД запускается не из редактора!!!!!!!

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/00
Author: Dmitry Ukhanov
Creation date: 03/22/00

*/

define input parameter p-db-num      like ub.db.db-num     no-undo . /* номер УБД */
define input parameter p-db-key      like ub.db.db-key     no-undo . /* ключ УБД */
define input parameter p-db-key-enc  like ub.db.db-key-enc no-undo . /* код. ключ УБД */
define input parameter p-type-unload as   character        no-undo . /* тип выгрузки */
define input parameter p-unload-history as logical         no-undo . /* выгружать историю */

define variable vss-revision    as character no-undo initial "$Revision: f29df1d5f130, 3104, rls $":U .
define variable vss-author      as character no-undo initial "$Author: DRuban $":U .
define variable vss-date        as character no-undo initial "$Date: Вт авг 09 09:15:01 2022 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: rest-rdb.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: adm/rest-rdb.p $":U .
define variable vss-description as character no-undo initial "Добавление и восстановление УБД".
define variable mode-erprn as logical no-undo.
{ cmp/str-glbl.i      }
{ cmp/library.i       }
{ cmp/getmcode.i dst  }
{ gbl/cur-time.i      }
{ ref/gdsoattr.i      }
{ trg/new-bcod.i      }
{ adm/unloaddb.i      }
{ gbl/cd-attr.i
&db-name=dst
}
{ gbl/db-attr.i       }
{ nws/check-tc.i      }
{ nws/nws-tabs.i      }
{ cmp/rest-rdb.i      }
{ nws/lib-nws.i       }
{ gbl/objsrv.i }
   
define buffer buf_rrdb-option for rrdb-option.
define variable conf-par as character no-undo.
define variable ser-wth-conf-par as logical no-undo.

define variable par-type as character no-undo.
define variable fin-doc-par as integer no-undo.
define variable v-on-gbl as logical no-undo.

define variable v-multi as logical no-undo initial no .

define temp-table temp-cash-desk no-undo
  field last-date like ub.chk-doc.chk-date
  field last-time like ub.chk-doc.chk-time
  field cash-num  like ub.cash-desk.cash-num
  index pi        is   unique primary cash-num.

  define variable ind1                as integer   no-undo .
  define variable ind2                as integer   no-undo .
  define variable host                as integer   no-undo .

  define variable tot-cli-count       as integer   no-undo.
  define variable v-cli-count         as integer   no-undo.
  define variable tot-firm-db-count   as integer   no-undo.
  define variable firm-db-count       as integer   no-undo.
  define variable v-log               as logical   no-undo.
  define variable v-obj-is-active     as logical   no-undo.
  define variable v-proceeded-host    as character no-undo.

  define variable v-ok   as logical   no-undo .
  define variable v-lock as logical   no-undo .
  define variable v-msg  as character no-undo .

  define variable v-today       as date      no-undo.
  define variable v-time        as integer   no-undo.
  define variable v-hn          as logical   no-undo.

  define variable v-command   as character no-undo .
  define variable v-new-route as logical   no-undo .
  define variable v-subject as character no-undo .

  define variable bh as handle    no-undo .

  define buffer buf_pck-sent for ub.pck-sent .
  define buffer buf_pck-rcvd for ub.pck-rcvd .

  define temp-table tt-host-list no-undo
    field host-code like ub.store.host-code
    index pi        is   unique primary host-code
  .

  define variable l-prod-bc-global as logical no-undo .

  define            variable fl        as character no-undo format "x(14)":U .
  define new shared variable count-str as character no-undo initial "":U .

  define new shared frame ddd
    count-str label "":U      format "X(50)":U
    fl        label "Таблица" format "X(50)":U
    ind1      label "Записей"
  with view-as dialog-box side-labels 1 columns three-d title "Перекачка данных".

  define stream slog .


/* Определяем интеграционный или нет режим работы */
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
    IF not error-status:error and conf-par = "yes":U then mode-erprn = yes.
    else mode-erprn = no.
    
function get-hist-nws-option returns logical (  input p-db-num as integer
                                               ,input p-tbl-name as character ):
define buffer buf_hist-nws-option for ub.hist-nws-option.
define buffer buf0_hist-nws-option for ub.hist-nws-option.

find first buf_hist-nws-option no-lock where
          buf_hist-nws-option.table-name = p-tbl-name
      and buf_Hist-nws-option.db-num = p-db-num
      and buf_Hist-nws-option.host-code = 0
      and buf_Hist-nws-option.obj-type = '':U
      and buf_Hist-nws-option.obj-code = 0
      and buf_Hist-nws-option.charkey_one = '':U
      and buf_Hist-nws-option.charkey_two = '':U
      and buf_Hist-nws-option.charkey_three = '':U
      and buf_Hist-nws-option.key#_one = 0
      and buf_Hist-nws-option.key#_two = 0
      and buf_Hist-nws-option.key#_three = 0  no-error .
find first buf0_hist-nws-option no-lock where
          buf0_hist-nws-option.table-name = p-tbl-name
      and buf0_Hist-nws-option.db-num = 0
      and buf0_Hist-nws-option.host-code = 0
      and buf0_Hist-nws-option.obj-type = '':U
      and buf0_Hist-nws-option.obj-code = 0
      and buf0_Hist-nws-option.charkey_one = '':U
      and buf0_Hist-nws-option.charkey_two = '':U
      and buf0_Hist-nws-option.charkey_three = '':U
      and buf0_Hist-nws-option.key#_one = 0
      and buf0_Hist-nws-option.key#_two = 0
      and buf0_Hist-nws-option.key#_three = 0  no-error .
if
(not available buf_hist-nws-option
or buf_hist-nws-option.get-hist-from-nws >= 0 )
and
(not available buf0_hist-nws-option
or buf0_hist-nws-option.hist-to-nws >= 0 )
then do:
  return yes.
end.
return no.
end function.


do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:

  if num-entries(p-type-unload, {&delim-par}) = 2
  then do :
    v-multi = logical(entry(2, p-type-unload, {&delim-par})) no-error.
    p-type-unload = entry(1, p-type-unload, {&delim-par}) .
  end.

  if transaction = true
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Активна транзакция" skip
      "Выгрузка невозможна" skip
      view-as alert-box error .
    undo, return error "Активна транзакция" .
  end.


  if p-type-unload <> {&unload-copy}
  and not v-multi
  then do:
    message
      "Выгрузка УБД." skip
      "Все данные, не пришедшие в ГБД будут потеряны." skip
      "Продолжить?" skip
      view-as alert-box question buttons yes-no update v-log .
    if not v-log then do:
      return "not-create":U .
    end.
  end.

  view frame ddd.
  assign
    ind1 = 0
    fl = "start":U
    count-str = substitute( "Выгрузка УБД &1", p-db-num )
  .
  do with frame ddd
  :
    assign
      count-str :screen-value   = string( count-str, count-str :format)
      fl :screen-value          = string( fl, fl :format)
      ind1 :screen-value        = string( ind1, ind1 :format)
    .
  end.

  output stream slog to rest-rdb.txt append .
  export stream slog "start-rest":U cur-time-string() .
  output stream slog close .

  output stream slog to rest-rdb.txt append .
  export stream slog "disable triggers of dst":U cur-time-string() .
  output stream slog close .

  for each dst._file no-lock
    where dst._file._hidden = false
  on error  undo, return error substitute( "&1 (disable-load-triggers-dst). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo, return error substitute( "&1 (disable-load-triggers-dst). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (disable-load-triggers-dst). endkey", vss-workfile )
  :
    create buffer bh for table substitute( "dst.&1", dst._file._file-name ) .
    bh:disable-load-triggers(true) .
    delete object bh .
  end.

  if p-type-unload = {&unload-copy} then do:
    output stream slog to rest-rdb.txt append .
    export stream slog "disable triggers of src":U cur-time-string() .
    output stream slog close .

    for each src._file no-lock
      where src._file._hidden = false
    on error  undo, return error substitute( "&1 (disable-load-triggers-src). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo, return error substitute( "&1 (disable-load-triggers-src). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (disable-load-triggers-src). endkey", vss-workfile )
    :
      create buffer bh for table substitute( "src.&1", src._file._file-name ) .
      bh:disable-load-triggers(true) .
      delete object bh .
    end.
  end.


/*  run utl/delnotcl.p ( input p-db-num ) no-error . */
/*  if error-status :error then do: */
/*    message */
/*      vss-workfile vss-revision vss-description skip */
/*      "Ошибка при удалении незакрытых документов" skip */
/*      error-status :get-message(1) skip */
/*      return-value skip */
/*      view-as alert-box error . */
/*    undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) . */
/*  end. */
  run db-attr-write in this-procedure
    ( input p-db-num
     ,input {&attr-unload-after-cut}
     ,input "yes"
    ) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Ошибка при записи значения атрибута 'выгрузка после обрезания' для БД &1", p-db-num ) skip
      return-value skip
      error-status :get-message ( error-status :num-messages )
      view-as alert-box error
    .
    undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) .
  end.

  output stream slog to rest-rdb.txt append .
  export stream slog "lock-news":U cur-time-string() .
  output stream slog close .

  assign
    v-lock = false
  .
  { nws/lock-rt.i
    "'lockfull'"
    p-db-num
    0
    "substitute( 'Выгрузка УБД &1', p-db-num )"
    v-msg
    v-lock
    v-ok
    no-error
  }
  if error-status :error
    or v-lock = false
    or v-ok   = false
  then do:
    message
      vss-workfile vss-revision vss-description skip
      return-value skip
      error-status :get-message ( error-status :num-messages )
      view-as alert-box error
    .
    undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) .
  end.

  find first ub.db no-lock
    where ub.db.db-num = p-db-num
    .

  do transaction
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    define buffer buf_upgrade for ub.upgrade .

    find last buf_upgrade exclusive-lock
      where buf_upgrade.db-num = 0
      no-error .
    if available buf_upgrade then do:

      disable triggers for load of ub.upgrade.

      for each ub.upgrade exclusive-lock
        where ub.upgrade.db-num = p-db-num
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        delete ub.upgrade .
      end.
      create ub.upgrade .
      assign
        ub.upgrade.db-num      = p-db-num
        ub.upgrade.version-num = buf_upgrade.version-num
        ub.upgrade.version-ord = 1 /* dynamic-next-value( "s-upg-ord":U, "ub":U ) */
        ub.upgrade.step-num    = buf_upgrade.step-num
        ub.upgrade.err-msgs    = "":U
        ub.upgrade.err-code    = 0
        ub.upgrade.complete    = TRUE
        ub.upgrade.UpgDate     = today
        ub.upgrade.UpgTimeInt  = time
        ub.upgrade.UpgTime     = string( time, "HH:MM:SS" )
       .
      if p-type-unload = {&unload-copy} then do:
        for each src.upgrade exclusive-lock
          where src.upgrade.db-num = p-db-num
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          delete src.upgrade .
        end.
        create src.upgrade .
        assign
          src.upgrade.db-num      = ub.upgrade.db-num
          src.upgrade.version-num = ub.upgrade.version-num
          src.upgrade.version-ord = ub.upgrade.version-ord
          src.upgrade.step-num    = ub.upgrade.step-num
          src.upgrade.err-msgs    = ub.upgrade.err-msgs
          src.upgrade.err-code    = ub.upgrade.err-code
          src.upgrade.complete    = ub.upgrade.complete
          src.upgrade.UpgDate     = ub.upgrade.UpgDate
          src.upgrade.UpgTimeInt  = ub.upgrade.UpgTimeInt
          src.upgrade.UpgTime     = ub.upgrade.UpgTime
        .
      end.
    end.
  end.

  do transaction
  on error  undo, return error substitute( "&1 (transaction1). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo, return error substitute( "&1 (transaction1). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (transaction1). endkey", vss-workfile )
  :

    if not can-find (first src.db-status no-lock
      where src.db-status.db-num = p-db-num)
    then do:
      if not can-find (first ub.db-status no-lock
        where ub.db-status.db-num = p-db-num)
      then do:
        disable triggers for load of ub.db-status.
        create ub.db-status .
        assign
          ub.db-status.db-num = p-db-num
        .
      end.
      if p-type-unload = {&unload-copy} then do:
        for each ub.db-status no-lock
          where ub.db-status.db-num = p-db-num
        on error  undo, return error substitute( "&1 (db-status). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
        on stop   undo, return error substitute( "&1 (db-status). stop", vss-workfile )
        on endkey undo, return error substitute( "&1 (db-status). endkey", vss-workfile )
        :
          create src.db-status .
          buffer-copy ub.db-status to src.db-status .
        end.
      end.
    end.

    assign
      ind1 = 0
      fl = "code-range":U
      count-str = substitute( "Создание диапазонов кодов" )
    .
    do with frame ddd
    :
      assign
        count-str :screen-value   = string( count-str, count-str :format)
        fl :screen-value          = string( fl, fl :format)
        ind1 :screen-value        = string( ind1, ind1 :format)
      .
    end.

    /* при создании базы данных необходимо создать хотя бы один code-range */
    if not mode-erprn then do: 
        if not can-find (first src.code-range no-lock
          where src.code-range.db-num = p-db-num
            and src.code-range.range-type = {&gbl-bc-code})
        then do:
          if not can-find (first ub.code-range no-lock
            where ub.code-range.db-num = p-db-num
              and ub.code-range.range-type = {&gbl-bc-code})
          then do:
            disable triggers for load of ub.code-range.
            run new-bcod-gen-code-range in this-procedure
              ( input p-db-num
                ,input {&gbl-bc-code}
              ) no-error .
            if error-status :error then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при создании нового свободного диапазона" skip
                "База данных" p-db-num skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) .
            end.
          end.
          if p-type-unload = {&unload-copy} then do:
            for each ub.code-range no-lock
              where ub.code-range.db-num = p-db-num
                and ub.code-range.range-type = {&gbl-bc-code}
            on error  undo, return error substitute( "&1 (code-range1). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
            on stop   undo, return error substitute( "&1 (code-range1). stop", vss-workfile )
            on endkey undo, return error substitute( "&1 (code-range1). endkey", vss-workfile )
            :
              create src.code-range .
              buffer-copy ub.code-range to src.code-range .
            end.
          end.
        end.
    
        /* при создании базы данных необходимо создать хотя бы один code-range */
        if not can-find (first src.code-range no-lock
          where src.code-range.db-num = p-db-num
            and src.code-range.range-type = {&gbl-ct-code})
        then do:
          if not can-find (first ub.code-range no-lock
            where ub.code-range.db-num = p-db-num
              and ub.code-range.range-type = {&gbl-ct-code})
          then do:
            disable triggers for load of ub.code-range.
            run new-bcod-gen-code-range in this-procedure
              ( input p-db-num
                ,input {&gbl-ct-code}
              ) no-error .
            if error-status :error then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при создании нового свободного диапазона" skip
                "База данных" p-db-num skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) .
            end.
          end.
          if p-type-unload = {&unload-copy} then do:
            for each ub.code-range no-lock
              where ub.code-range.db-num = p-db-num
                and ub.code-range.range-type = {&gbl-ct-code}
            on error  undo, return error substitute( "&1 (code-range2). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
            on stop   undo, return error substitute( "&1 (code-range2). stop", vss-workfile )
            on endkey undo, return error substitute( "&1 (code-range2). endkey", vss-workfile )
            :
              create src.code-range .
              buffer-copy ub.code-range to src.code-range .
            end.
          end.
        end.
    
        if not can-find (first src.code-range no-lock
          where src.code-range.db-num = p-db-num
            and src.code-range.range-type = {&gbl-dr-code})
        then do:
          if not can-find (first ub.code-range no-lock
            where ub.code-range.db-num = p-db-num
              and ub.code-range.range-type = {&gbl-dr-code})
          then do:
            disable triggers for load of ub.code-range.
            run new-bcod-gen-code-range in this-procedure
              ( input p-db-num
                ,input {&gbl-dr-code}
              ) no-error .
            if error-status :error then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при создании нового свободного диапазона" skip
                "База данных" p-db-num skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) .
            end.
          end.
          if p-type-unload = {&unload-copy} then do:
            for each ub.code-range no-lock
              where ub.code-range.db-num = p-db-num
                and ub.code-range.range-type = {&gbl-dr-code}
            on error  undo, return error substitute( "&1 (code-range3). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
            on stop   undo, return error substitute( "&1 (code-range3). stop", vss-workfile )
            on endkey undo, return error substitute( "&1 (code-range3). endkey", vss-workfile )
            :
              create src.code-range .
              buffer-copy ub.code-range to src.code-range .
            end.
          end.
    
          if not can-find (first src.code-range no-lock
            where src.code-range.db-num = p-db-num
              and src.code-range.range-type = {&gbl-fm-code})
          then do:
            if not can-find (first ub.code-range no-lock
              where ub.code-range.db-num = p-db-num
                and ub.code-range.range-type = {&gbl-fm-code})
            then do:
              disable triggers for load of ub.code-range.
              run new-bcod-gen-code-range in this-procedure
                ( input p-db-num
                  ,input {&gbl-fm-code}
                ) no-error .
              if error-status :error then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Ошибка при создании нового свободного диапазона" skip
                  "База данных" p-db-num skip
                  error-status :get-message(1) skip
                  return-value skip
                  view-as alert-box error .
                undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) .
              end.
            end.
          end.
          if p-type-unload = {&unload-copy} then do:
            for each ub.code-range no-lock
              where ub.code-range.db-num = p-db-num
                and ub.code-range.range-type = {&gbl-fm-code}
            on error  undo, return error substitute( "&1 (code-range3). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
            on stop   undo, return error substitute( "&1 (code-range3). stop", vss-workfile )
            on endkey undo, return error substitute( "&1 (code-range3). endkey", vss-workfile )
            :
              create src.code-range .
              buffer-copy ub.code-range to src.code-range .
            end.
          end.
    
          if not can-find (first src.code-range no-lock
            where src.code-range.db-num = p-db-num
              and src.code-range.range-type = {&gbl-pn-code})
          then do:
            if not can-find (first ub.code-range no-lock
              where ub.code-range.db-num = p-db-num
                and ub.code-range.range-type = {&gbl-pn-code})
            then do:
              disable triggers for load of ub.code-range.
              run new-bcod-gen-code-range in this-procedure
                ( input p-db-num
                  ,input {&gbl-pn-code}
                ) no-error .
              if error-status :error then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Ошибка при создании нового свободного диапазона" skip
                  "База данных" p-db-num skip
                  error-status :get-message(1) skip
                  return-value skip
                  view-as alert-box error .
                undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) .
              end.
            end.
          end.
          if p-type-unload = {&unload-copy} then do:
            for each ub.code-range no-lock
              where ub.code-range.db-num = p-db-num
                and ub.code-range.range-type = {&gbl-pn-code}
            on error  undo, return error substitute( "&1 (code-range3). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
            on stop   undo, return error substitute( "&1 (code-range3). stop", vss-workfile )
            on endkey undo, return error substitute( "&1 (code-range3). endkey", vss-workfile )
            :
              create src.code-range .
              buffer-copy ub.code-range to src.code-range .
            end.
          end.
      end.         
     end. /* not mode-erprn */ 
     else do: /* Для интеграционного решения принудительно создаем максимальные диапазоны для справочников, которые импортируются в УБД */
        &scope minvalue 1000000000	
        create dst.code-range.
        assign
          dst.code-range.range-type = {&gbl-bc-code}
          dst.code-range.PS         = "FOR ERP"
          dst.code-range.beg-date   = today
          dst.code-range.first-code = 1
          dst.code-range.last-code  = {&minvalue} - 1
          dst.code-range.db-num     = p-db-num
          dst.code-range.stts       = "u":U
        .
        create dst.code-range.
        assign
          dst.code-range.range-type = {&gbl-bc-code}
          dst.code-range.PS         = "FOR ERP"
          dst.code-range.beg-date   = today
          dst.code-range.first-code = {&minvalue}
          dst.code-range.last-code  = {&minvalue} * 2
          dst.code-range.db-num = p-db-num
          dst.code-range.stts = "a":U
        .
        create dst.code-range.
        assign
          dst.code-range.range-type = {&gbl-fm-code}
          dst.code-range.PS         = "FOR ERP"
          dst.code-range.beg-date   = today
          dst.code-range.first-code = 1
          dst.code-range.last-code  = 999999999
          dst.code-range.db-num = p-db-num
          dst.code-range.stts = "a":U
        .  
        create dst.code-range.
        assign
          dst.code-range.range-type = {&gbl-pn-code}
          dst.code-range.PS         = "FOR ERP"
          dst.code-range.beg-date   = today
          dst.code-range.first-code = 1
          dst.code-range.last-code  = 999999999
          dst.code-range.db-num = p-db-num
          dst.code-range.stts = "a":U
        .  
        create dst.code-range.
        assign
          dst.code-range.range-type = {&gbl-fd-code}
          dst.code-range.PS         = "FOR ERP"
          dst.code-range.beg-date   = today
          dst.code-range.first-code = 1
          dst.code-range.last-code  = 999999999
          dst.code-range.db-num = p-db-num
          dst.code-range.stts = "a":U
        .
        /* Договоры  */  
        create dst.code-range.
        assign
          dst.code-range.range-type = {&gbl-ct-code}
          dst.code-range.PS         = "FOR ERP"
          dst.code-range.beg-date   = today
          dst.code-range.first-code = 1
          dst.code-range.last-code  = 999999999
          dst.code-range.db-num = p-db-num
          dst.code-range.stts = "a":U
        .  
        create dst.code-range.
        assign
          dst.code-range.range-type = {&gbl-dr-code}
          dst.code-range.PS         = "FOR ERP"
          dst.code-range.beg-date   = today
          dst.code-range.first-code = 1
          dst.code-range.last-code  = 999999999
          dst.code-range.db-num = p-db-num
          dst.code-range.stts = "a":U
        . 
        for each src.code-range where src.code-range.db-num = 0 and
            (src.code-range.range-type = {&loc-sc-code} or 
            src.code-range.range-type =  {&loc-ss-code} or
            src.code-range.range-type =  {&loc-pg-code}):
                create dst.code-range.
                buffer-copy src.code-range to dst.code-range .
        end.    
        for each src.code-range where src.code-range.db-num = p-db-num and          
            src.code-range.range-type =  {&gbl-ca-code} :           
                create dst.code-range.
                buffer-copy src.code-range to dst.code-range .
        end. 
     end. 
  end.

  output stream slog to rest-rdb.txt append .
  export stream slog "hist-nws-option":U cur-time-string() .
  output stream slog close .

  assign
    ind1 = 0
    fl = "hist-nws-option":U
    count-str = substitute( "Создание опции истории и маршрутизации" )
  .
  do with frame ddd
  :
    assign
      count-str :screen-value   = string( count-str, count-str :format)
      fl :screen-value          = string( fl, fl :format)
      ind1 :screen-value        = string( ind1, ind1 :format)
    .
  end.


  for each src.hist-nws-option no-lock
    where src.hist-nws-option.db-num = 0
  on error  undo, return error substitute( "&1 (hist-nws-option1). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo, return error substitute( "&1 (hist-nws-option1). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (hist-nws-option1). endkey", vss-workfile )
  :
    create dst.hist-nws-option .
    buffer-copy src.hist-nws-option to dst.hist-nws-option .
  end.
  for each src.hist-nws-option no-lock
    where src.hist-nws-option.db-num = p-db-num
  on error  undo, return error substitute( "&1 (hist-nws-option2). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo, return error substitute( "&1 (hist-nws-option2). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (hist-nws-option2). endkey", vss-workfile )
  :
    find first dst.hist-nws-option where
              dst.hist-nws-option.db-num = src.hist-nws-option.db-num
           and dst.hist-nws-option.hn-id = src.hist-nws-option.hn-id no-error.
    if not available dst.hist-nws-option then do:
      create dst.hist-nws-option .
      buffer-copy src.hist-nws-option to dst.hist-nws-option .
    end.
    else do:
      if dst.hist-nws-option.table-name <> src.hist-nws-option.table-name
      or dst.hist-nws-option.subject-group <> src.hist-nws-option.subject-group
      or dst.hist-nws-option.option-descr <> src.hist-nws-option.option-descr
      or dst.hist-nws-option.charkey_one <> src.hist-nws-option.charkey_one
      or dst.hist-nws-option.key#_one <> src.hist-nws-option.key#_one then do:
         buffer-copy src.hist-nws-option to dst.hist-nws-option .
      end.
    end.
  end.
  if ub.db.remote-stock = true then do:
    assign
      table-ref       = table-ref + ",prt-obj,db-status":U
      table-ref-where = table-ref-where + fill( {&delim-par}, 2 )
      table-ref-if-cond  = table-ref-if-cond   + fill( {&delim-par}, 2 )
    .
  end.
  else do:
    assign
      table-obj          = table-obj         + ",prt-obj":U
      table-obj-where    = table-obj-where   + {&delim-par}
      table-obj-if-cond  = table-obj-if-cond + fill( {&delim-par}, 1 )
    .
  end.
  if ub.db.unload-arch = true then do:
    /* Выгружать складской архив по товарам и складской архив по поставщикам */
    assign
      table-obj = table-obj + ",ot-line,ot-tot,stk-line,stk-tot,ot-supp-line,ot-supp-tot,stk-supp-line,stk-supp-tot":U
      table-obj-where = table-obj-where + fill({&delim-par}, 8)
      table-obj-if-cond = table-obj-if-cond + fill({&delim-par}, 8)
    .
  end.

  if ub.db.unload-aht = true then do:
    /* Выгружать складской архив по типам приобретения */
    assign
      table-obj = table-obj + ",aht-ot-line,aht-ot-tot,aht-stk-line,aht-stk-tot,aht-stk,aht-doc":U
      table-obj-where = table-obj-where + fill({&delim-par}, 6)
      table-obj-if-cond = table-obj-if-cond + fill({&delim-par}, 6)
    .
  end.
  run prepare-tables in this-procedure ( input table-ref
                                        ,input table-ref-where
                                        ,input table-ref-if-cond
                                        ,input '':U
                                        ,input "ref"
                                        ,input p-unload-history
                                        ).
  run prepare-tables in this-procedure ( input table-obj
                                        ,input table-obj-where
                                        ,input table-obj-if-cond
                                        ,input '':U
                                        ,input "obj"
                                        ,input p-unload-history
                                        ).

  run prepare-tables in this-procedure ( input table-host-obj
                                        ,input table-host-obj-where
                                        ,input table-host-obj-if-cond
                                        ,input '':U
                                        ,input "host-obj"
                                        ,input p-unload-history
                                        ).
  run prepare-tables in this-procedure ( input table-xobj
                                        ,input table-xobj-where
                                        ,input table-xobj-if-cond
                                        ,input table-xobj-fields
                                        ,input "xobj"
                                        ,input p-unload-history
                                        ).
  run prepare-tables in this-procedure ( input table-firm-db
                                        ,input table-firm-db-where
                                        ,input table-firm-db-if-cond
                                        ,input '':U
                                        ,input "firm-db"
                                        ,input p-unload-history
                                        ).
  run prepare-tables in this-procedure ( input table-db
                                        ,input table-db-where
                                        ,input table-db-if-cond
                                        ,input '':U
                                        ,input "db"
                                        ,input p-unload-history
                                        ).
  run prepare-dc in this-procedure ( input p-db-num
                                    ,input p-unload-history
                                    ).

  /* номер УБД которую создаем  причем dst - новая УБД а ub - ГБД */

  output stream slog to rest-rdb.txt append .
  export stream slog "clear-tables":U cur-time-string() .
  output stream slog close .

  for each dst.sys-ctrl exclusive-lock
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  :
    delete dst.sys-ctrl .
  end.
  for each dst.gds-grp exclusive-lock
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  :
    delete dst.gds-grp .
  end.
  for each dst.cli-grp exclusive-lock
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  :
    delete dst.cli-grp .
  end.
  for each dst.gds-prt exclusive-lock
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  :
    delete dst.gds-prt .
  end.
  for each dst.db exclusive-lock
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  :
    delete dst.db .
  end.

  do with frame ddd
  on error  undo, return error substitute( "&1 (frame ddd). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo, return error substitute( "&1 (frame ddd). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (frame ddd). endkey", vss-workfile )
  :
    output stream slog to rest-rdb.txt append .
    export stream slog "route":U cur-time-string() .
    output stream slog close .

    assign
      ind1 = 0
      fl = "route":U
      count-str = "Удаление маршрутизации"
      v-new-route = false
    .
    if p-type-unload = {&unload-copy} then do:
      on delete of src.route      override do: end.
      on delete of src.route-dump override do: end.
    end.

    for each ub.route exclusive-lock
       where ub.route.db-num    = p-db-num
       by ub.route.tbl-ord
    on error  undo, return error substitute( "&1 (ub.route). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo, return error substitute( "&1 (ub.route). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (ub.route). endkey", vss-workfile )
    :
      if ub.route.name-rec = "begins_unload_from_copy":U then do:
        assign
          v-new-route = true
        .
      end.
      assign
        ind1 = ind1 + 1
      .
      do with frame ddd
      :
        assign
          count-str :screen-value   = string( count-str, count-str :format)
          fl :screen-value          = string( fl, fl :format)
          ind1 :screen-value        = string( ind1, ind1 :format)
        .
      end.
      if p-type-unload = {&unload-copy}
        and v-new-route = false
      then do:
        for each src.route exclusive-lock
          where src.route.db-num    = ub.route.db-num
/*            and src.route.last-pack = ub.route.last-pack  это нельзя использовать т.к. пакету мог уже присвоится номер */
            and src.route.tbl-ord   = ub.route.tbl-ord
        on error  undo, return error substitute( "&1 (src.route). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
        on stop   undo, return error substitute( "&1 (src.route). stop", vss-workfile )
        on endkey undo, return error substitute( "&1 (src.route). endkey", vss-workfile )
        :
          { trg/routed.i src }
          delete src.route .
        end.
      end.
      delete ub.route .
    end.

    output stream slog to rest-rdb.txt append .
    export stream slog "pck-sent" cur-time-string() .
    output stream slog close .

    assign
      ind1 = 0
      fl = "pck-sent":U
      count-str = "":U
    .

    if p-type-unload <> {&unload-copy} then do:
      find last ub.pck-sent share-lock
        where ub.pck-sent.db-num   = p-db-num
          and ub.pck-sent.pack-num > 0
        use-index pi
        no-error
      .
      if available ub.pck-sent then do:  /* был хоть пакет с номером больше 0 */
        find first buf_pck-sent share-lock
          where buf_pck-sent.db-num = p-db-num
            and buf_pck-sent.pack-num = 0
          no-error .
        if available buf_pck-sent then do:
          do transaction
          on error  undo, return error substitute( "&1 (transaction_pck-sent). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
          on stop   undo, return error substitute( "&1 (transaction_pck-sent). stop", vss-workfile )
          on endkey undo, return error substitute( "&1 (transaction_pck-sent). endkey", vss-workfile )
          :
            for each ub.pck-sent-attr exclusive-lock
              where ub.pck-sent-attr.db-num   = buf_pck-sent.db-num
                and ub.pck-sent-attr.pack-num = buf_pck-sent.pack-num
            on error  undo, return error substitute( "&1 (pck-sent-attr). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
            on stop   undo, return error substitute( "&1 (pck-sent-attr). stop", vss-workfile )
            on endkey undo, return error substitute( "&1 (pck-sent-attr). endkey", vss-workfile )
            :
              delete ub.pck-sent-attr .
            end.
            delete buf_pck-sent .

            for each ub.pck-sent-attr exclusive-lock
              where ub.pck-sent-attr.db-num   = ub.pck-sent.db-num
                and ub.pck-sent-attr.pack-num = ub.pck-sent.pack-num
            on error  undo, return error substitute( "&1 (pck-sent-attr). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
            on stop   undo, return error substitute( "&1 (pck-sent-attr). stop", vss-workfile )
            on endkey undo, return error substitute( "&1 (pck-sent-attr). endkey", vss-workfile )
            :
              assign
                ub.pck-sent-attr.pack-num = 0 /* начнем жизнь с нуля */
              .
            end.
            assign
              ub.pck-sent.pack-num = 0 /* начнем жизнь с нуля */
            .
          end.

          for each ub.pck-sent exclusive-lock
            where ub.pck-sent.db-num   = p-db-num
              and ub.pck-sent.pack-num > 0
          on error  undo, return error substitute( "&1 (ub.pck-sent). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
          on stop   undo, return error substitute( "&1 (ub.pck-sent). stop", vss-workfile )
          on endkey undo, return error substitute( "&1 (ub.pck-sent). endkey", vss-workfile )
          :
            assign
              ind1 = ind1 + 1
            .
            do with frame ddd
            :
              assign
                count-str :screen-value   = string( count-str, count-str :format)
                fl :screen-value          = string( fl, fl :format)
                ind1 :screen-value        = string( ind1, ind1 :format)
              .
            end.
            for each ub.pck-sent-attr exclusive-lock
              where ub.pck-sent-attr.db-num   = ub.pck-sent.db-num
                and ub.pck-sent-attr.pack-num = ub.pck-sent.pack-num
            on error  undo, return error substitute( "&1 (pck-sent-attr). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
            on stop   undo, return error substitute( "&1 (pck-sent-attr). stop", vss-workfile )
            on endkey undo, return error substitute( "&1 (pck-sent-attr). endkey", vss-workfile )
            :
              delete ub.pck-sent-attr .
            end.
            delete ub.pck-sent .
          end.
        end.
      end.
    end.

    for each ub.pck-sent exclusive-lock
      where ub.pck-sent.db-num = p-db-num
    on error  undo, return error substitute( "&1 (ub.pck-sent). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo, return error substitute( "&1 (ub.pck-sent). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (ub.pck-sent). endkey", vss-workfile )
    :
      assign
        ind1 = ind1 + 1
      .
      do with frame ddd
      :
        assign
          count-str :screen-value   = string( count-str, count-str :format)
          fl :screen-value          = string( fl, fl :format)
          ind1 :screen-value        = string( ind1, ind1 :format)
        .
      end.

      create dst.pck-rcvd.
      buffer-copy ub.pck-sent to dst.pck-rcvd
        assign
          dst.pck-rcvd.db-num     = 0 /* ub.pck-sent.db-num */
/*          dst.pck-rcvd.pack-num   = ub.pck-sent.pack-num*/
/*          dst.pck-rcvd.total-recs = ub.pck-sent.total-recs*/
          dst.pck-rcvd.rcvd-recs  = ub.pck-sent.total-recs
/*          dst.pck-rcvd.CRC-pack   = ub.pck-sent.CRC-pack*/
          dst.pck-rcvd.rcvd       = yes
        .

      if p-type-unload = {&unload-copy} then do:
        find first src.pck-sent exclusive-lock
          where src.pck-sent.db-num   = ub.pck-sent.db-num
            and src.pck-sent.pack-num = ub.pck-sent.pack-num
        .
        assign
          src.pck-sent.rcvd = yes
        .
      end.
    end.

    output stream slog to rest-rdb.txt append .
    export stream slog "pck-rcvd":U cur-time-string() .
    output stream slog close .

    assign
      ind1 = 0
      fl = "pck-rcvd":U
      count-str = "":U
    .

    if p-type-unload <> {&unload-copy} then do:
      find last ub.pck-rcvd share-lock
        where ub.pck-rcvd.db-num   = p-db-num
          and ub.pck-rcvd.pack-num > 0
        use-index pi
        no-error
      .
      if available ub.pck-rcvd then do:  /* был хоть пакет с номером больше 0 */
        find first buf_pck-rcvd share-lock
          where buf_pck-rcvd.db-num = p-db-num
            and buf_pck-rcvd.pack-num = 0
          no-error .
        if available buf_pck-rcvd then do:
          do transaction
          on error  undo, return error substitute( "&1 (transaction_pck-rcvd). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
          on stop   undo, return error substitute( "&1 (transaction_pck-rcvd). stop", vss-workfile )
          on endkey undo, return error substitute( "&1 (transaction_pck-rcvd). endkey", vss-workfile )
          :
            for each ub.pck-rcvd-attr exclusive-lock
              where ub.pck-rcvd-attr.db-num   = buf_pck-rcvd.db-num
                and ub.pck-rcvd-attr.pack-num = buf_pck-rcvd.pack-num
            on error  undo, return error substitute( "&1 (pck-rcvd-attr). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
            on stop   undo, return error substitute( "&1 (pck-rcvd-attr). stop", vss-workfile )
            on endkey undo, return error substitute( "&1 (pck-rcvd-attr). endkey", vss-workfile )
            :
              delete ub.pck-rcvd-attr .
            end.
            delete buf_pck-rcvd .

            for each ub.pck-rcvd-attr exclusive-lock
              where ub.pck-rcvd-attr.db-num   = ub.pck-rcvd.db-num
                and ub.pck-rcvd-attr.pack-num = ub.pck-rcvd.pack-num
            on error  undo, return error substitute( "&1 (pck-rcvd-attr). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
            on stop   undo, return error substitute( "&1 (pck-rcvd-attr). stop", vss-workfile )
            on endkey undo, return error substitute( "&1 (pck-rcvd-attr). endkey", vss-workfile )
            :
              assign
                ub.pck-rcvd-attr.pack-num = 0 /* начнем жизнь с нуля */
              .
            end.
            assign
              ub.pck-rcvd.pack-num = 0 /* начнем жизнь с нуля */
            .
          end.

          for each ub.pck-rcvd exclusive-lock
            where ub.pck-rcvd.db-num   = p-db-num
              and ub.pck-rcvd.pack-num > 0
          on error  undo, return error substitute( "&1 (ub.pck-rcvd). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
          on stop   undo, return error substitute( "&1 (ub.pck-rcvd). stop", vss-workfile )
          on endkey undo, return error substitute( "&1 (ub.pck-rcvd). endkey", vss-workfile )
          :
            assign
              ind1 = ind1 + 1
            .
            do with frame ddd
            :
              assign
                count-str :screen-value   = string( count-str, count-str :format)
                fl :screen-value          = string( fl, fl :format)
                ind1 :screen-value        = string( ind1, ind1 :format)
      .
            end.
            for each ub.pck-rcvd-attr exclusive-lock
              where ub.pck-rcvd-attr.db-num   = ub.pck-rcvd.db-num
                and ub.pck-rcvd-attr.pack-num = ub.pck-rcvd.pack-num
            on error  undo, return error substitute( "&1 (pck-rcvd-attr). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
            on stop   undo, return error substitute( "&1 (pck-rcvd-attr). stop", vss-workfile )
            on endkey undo, return error substitute( "&1 (pck-rcvd-attr). endkey", vss-workfile )
            :
              delete ub.pck-rcvd-attr .
            end.
            delete ub.pck-rcvd .
          end.
        end.
      end.
    end.

    for each ub.pck-rcvd exclusive-lock
       where ub.pck-rcvd.db-num = p-db-num
    on error  undo, return error substitute( "&1 (ub.pck-rcvd). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo, return error substitute( "&1 (ub.pck-rcvd). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (ub.pck-rcvd). endkey", vss-workfile )
    :
      assign
        ind1 = ind1 + 1
      .
      do with frame ddd
      :
        assign
          count-str :screen-value   = string( count-str, count-str :format)
          fl :screen-value          = string( fl, fl :format)
          ind1 :screen-value        = string( ind1, ind1 :format)
        .
      end.

      create dst.pck-sent.
      buffer-copy ub.pck-rcvd to dst.pck-sent
        assign
          dst.pck-sent.db-num     = 0
/*          dst.pck-sent.pack-num   = ub.pck-rcvd.pack-num*/
/*          dst.pck-sent.total-recs = ub.pck-rcvd.total-recs*/
/*          dst.pck-sent.CRC-pack   = ub.pck-rcvd.CRC-pack*/
          dst.pck-sent.rcvd       = yes
        .

      if p-type-unload = {&unload-copy} then do:
        find first src.pck-rcvd exclusive-lock
          where src.pck-rcvd.db-num   = ub.pck-rcvd.db-num
            and src.pck-rcvd.pack-num = ub.pck-rcvd.pack-num
        .
        assign
          src.pck-rcvd.rcvd = yes
        .
      end.
    end.

    do transaction
    on error  undo, return error substitute( "&1 (sys-ctrl). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo, return error substitute( "&1 (sys-ctrl). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (sys-ctrl). endkey", vss-workfile )
    :
      output stream slog to rest-rdb.txt append .
      export stream slog "sys-ctrl":U cur-time-string() .
      output stream slog close .

      find first ub.sys-ctrl no-lock.

      find first dst.sys-ctrl no-error.
      if not available dst.sys-ctrl then do:
        create dst.sys-ctrl.
      end.
      assign
        dst.sys-ctrl.sys-date = today
        dst.sys-ctrl.db-num   = p-db-num
        dst.sys-ctrl.cut-date = ub.sys-ctrl.cut-date
        dst.sys-ctrl.sys-key  = ub.sys-ctrl.sys-key
        dst.sys-ctrl.language = ub.sys-ctrl.language
        dst.sys-ctrl.r-b      = ub.sys-ctrl.r-b
      .

    end.

    { adm/actn-gbl.i
      v-on-gbl
      no-error
    }
    if v-on-gbl then do:
      output stream slog to rest-rdb.txt append .
      export stream slog "action-role":U cur-time-string() .
      output stream slog close .

      for each ub.action-role no-lock
        where ub.action-role.db-num = 0
      on error  undo, return error substitute( "&1 (action-role). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo, return error substitute( "&1 (action-role). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (action-role). endkey", vss-workfile )
      :
        create dst.action-role.
        buffer-copy ub.action-role to dst.action-role .
      end.

      output stream slog to rest-rdb.txt append .
      export stream slog "action-role-attr":U cur-time-string() .
      output stream slog close .

      for each ub.action-role-attr no-lock
        where ub.action-role-attr.db-num = 0
      on error  undo, return error substitute( "&1 (action-role-attr). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo, return error substitute( "&1 (action-role-attr). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (action-role-attr). endkey", vss-workfile )
      :
        create dst.action-role-attr.
        buffer-copy ub.action-role-attr to dst.action-role-attr .
      end.

      output stream slog to rest-rdb.txt append .
      export stream slog "action-role-item":U cur-time-string() .
      output stream slog close .

      for each ub.action-role-item no-lock
        where ub.action-role-item.db-num = 0
      on error  undo, return error substitute( "&1 (action-role-item). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo, return error substitute( "&1 (action-role-item). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (action-role-item). endkey", vss-workfile )
      :
        create dst.action-role-item.
        buffer-copy ub.action-role-item to dst.action-role-item .
      end.

      output stream slog to rest-rdb.txt append .
      export stream slog "action-role-item-attr":U cur-time-string() .
      output stream slog close .

      for each ub.action-role-item-attr no-lock
        where ub.action-role-item-attr.db-num = 0
      on error  undo, return error substitute( "&1 (action-role-item-attr). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo, return error substitute( "&1 (action-role-item-attr). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (action-role-item-attr). endkey", vss-workfile )
      :
        create dst.action-role-item-attr.
        buffer-copy ub.action-role-item-attr to dst.action-role-item-attr .
      end.

    end.

    for each buf_rrdb-option where
            buf_rrdb-option.dump-point = "ref"
            by buf_rrdb-option.dump-point by buf_rrdb-option.first-table-name
    on error  undo, return error substitute( "&1 (buf_rrdb-option.dump-point = ref). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo, return error substitute( "&1 (buf_rrdb-option.dump-point = ref). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (buf_rrdb-option.dump-point = ref). endkey", vss-workfile )
    :
      assign
      v-subject =  (if buf_rrdb-option.subject-group = "dc"
                    then buf_rrdb-option.des
                    else buf_rrdb-option.first-table-name)
      count-str = "Глобальные справочники"
      fl = v-subject
      .

      do with frame ddd
      :
        assign
          count-str :screen-value   = string( count-str, count-str :format)
          fl :screen-value          = string( fl, fl :format)
          ind1 :screen-value        = string( ind1, ind1 :format)
        .
      end.

      output stream slog to rest-rdb.txt append .
      export stream slog "table-ref-move":U v-subject cur-time-string() .
      output stream slog close .
      if buf_rrdb-option.first-table-name begins 'c-':U then do:
        assign
        v-hn = yes
        v-hn = get-hist-nws-option( input p-db-num
                                   ,input buf_rrdb-option.first-table-name)
        no-error .
      end.
      else do:
        v-hn = yes.
      end.
      if not v-hn then do:
        output stream slog to rest-rdb.txt append .
        export stream slog "!!!SKIPPING other db  history records!!!!!" .
        output stream slog close .
      end.
      run adm/cred-tbl.p (
                         input this-procedure:handle
                        ,input p-db-num
                        ,input '':U /*p-obj-type*/
                        ,input 0 /*p-obj-code*/
                        ,input 0 /*p-host-code*/
                        ,input count-str
                        ,input {&all-query-buffers}
                        ,input {&all-query-buffers-export}
                        ,input buf_rrdb-option.where-phrase
                        ,input buf_rrdb-option.if-phrase
                        ,input buf_rrdb-option.if-buffer-num
                        ,input "ref"
                        ,input v-hn
                        ,input yes /*p-run-or-check*/
                        ) .
      output stream slog to rest-rdb.txt append .
      export stream slog "OK ref" v-subject cur-time-string() .
      output stream slog close .
    end.

    for each buf_rrdb-option where buf_rrdb-option.dump-point = "db"
    on error  undo, return error substitute( "&1 (buf_rrdb-option.dump-point = db). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo, return error substitute( "&1 (buf_rrdb-option.dump-point = db). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (buf_rrdb-option.dump-point = db). endkey", vss-workfile )
    :
      assign
      v-subject =  (if buf_rrdb-option.subject-group = "dc"
                    then buf_rrdb-option.des
                    else buf_rrdb-option.first-table-name)
      count-str = "Справочники по БД"
      fl = v-subject
      .

      do with frame ddd
      :
        assign
          count-str :screen-value   = string( count-str, count-str :format)
          fl :screen-value          = string( fl, fl :format)
          ind1 :screen-value        = string( ind1, ind1 :format)
        .
      end.

      output stream slog to rest-rdb.txt append .
      export stream slog "table-db-move":U v-subject cur-time-string() .
      output stream slog close .

      if buf_rrdb-option.first-table-name begins 'c-':U then do:
        assign
        v-hn = yes
        v-hn = get-hist-nws-option( input p-db-num
                                    ,input buf_rrdb-option.first-table-name)
        no-error .
      end.
      else do:
        v-hn = yes.
      end.
      if not v-hn then do:
        output stream slog to rest-rdb.txt append .
        export stream slog "!!!SKIPPING other db  history records!!!!!" .
        output stream slog close .
      end.
      run adm/cred-tbl.p (
                          input this-procedure:handle
                        ,input p-db-num
                        ,input '':U /*p-obj-type*/
                        ,input 0 /*p-obj-code*/
                        ,input 0 /*p-host-code*/
                        ,input count-str
                        ,input {&all-query-buffers}
                        ,input {&all-query-buffers-export}
                        ,input buf_rrdb-option.where-phrase
                        ,input buf_rrdb-option.if-phrase
                        ,input buf_rrdb-option.if-buffer-num
                        ,input "db"
                        ,input v-hn
                        ,input yes /*p-run-or-check*/
                        ) .
      output stream slog to rest-rdb.txt append .
      export stream slog "OK df" v-subject cur-time-string() .
      output stream slog close .
    end.
    assign
    count-str = ""
    fl = ""
    .

    do with frame ddd
    :
      assign
        count-str :screen-value   = string( count-str, count-str :format)
        fl :screen-value          = string( fl, fl :format)
        ind1 :screen-value        = string( ind1, ind1 :format)
      .
    end.



    /* Запись _user создается в триггере на изменение user-login.
       Триггера отключены, поэтому принудительно создаем здесь. */
    for each dst.user-login exclusive-lock
    on error  undo, return error substitute( "&1 (dst.user-login). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo, return error substitute( "&1 (dst.user-login). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (dst.user-login). endkey", vss-workfile )
    :
        if not can-find (first dst._user where dst._user._userid = dst.user-login.user-login no-lock) then do:
           { trg/user.i dst }
        end.
    end.

    /* Если выгружается новая УБД, то в ней создается адм
       создаем копию в ГБД принудительно, поскольку все отключено
    */
    do transaction
    on error  undo, return error substitute( "&1 (user-login). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo, return error substitute( "&1 (user-login). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (user-login). endkey", vss-workfile )
    :
      disable triggers for load of ub.user-account.
      disable triggers for load of ub.user-login.

      disable triggers for load of src.user-account.
      disable triggers for load of src.user-login.

      find first dst.user-login exclusive-lock
        where dst.user-login.user-login = "адм"
        no-error .
      if available dst.user-login then do:
        find first dst.user-account exclusive-lock
          where dst.user-account.user-id = dst.user-login.user-id
          no-error
        .
        find first ub.user-account exclusive-lock
          where ub.user-account.user-id = dst.user-account.user-id
          no-error .
        find first ub.user-login exclusive-lock
          where ub.user-login.user-id = dst.user-login.user-id
            and ub.user-login.db-num  = dst.user-login.db-num
          no-error .
        if not available ub.user-account then do:
          create ub.user-account.
          buffer-copy dst.user-account to ub.user-account.
        end.
        if not available ub.user-login then do:
          create ub.user-login.
          buffer-copy dst.user-login to ub.user-login.
        end.

        if p-type-unload = {&unload-copy} then do:
          find first src.user-account exclusive-lock
            where src.user-account.user-id = dst.user-account.user-id
            no-error .
          find first src.user-login exclusive-lock
            where src.user-login.user-id = dst.user-login.user-id
              and src.user-login.db-num  = dst.user-login.db-num
            no-error .
          if not available src.user-account then do:
            create src.user-account.
            buffer-copy dst.user-account to src.user-account.
          end.
          if not available src.user-login then do:
            create src.user-login.
            buffer-copy dst.user-login to src.user-login.
          end.
        end.
      end.
    end.

    /* выгрузка атрибутов в УБД (таблицы clients-attr) */
    run adm/restclna.p
      (input  p-db-num          /* p-db-num    */
      ,input  ub.db.unload-arch /* p-copy-arh  */
      ,input  ub.db.unload-arch /* p-copy-ahsp */
      ,input  ub.db.unload-aht  /* p-copy-aht  */
      ) .

    assign
      ind1 = 0
      fl = "clob-data":U
    .

    output stream slog to rest-rdb.txt append .
    export stream slog "clob-data":U cur-time-string() .
    output stream slog close .
    define variable v-jj as integer no-undo .
    define variable v-entry as character no-undo .
    define variable lob-res-list as character no-undo .
    lob-res-list = {&lob-res-gate} + {&comma-char} + {&lob-res-ref}.
    do v-jj = 1 to num-entries(lob-res-list):
      v-entry = entry(v-jj, lob-res-list).
    for each dst.clob-bind no-lock
        where dst.clob-bind.resource-type = v-entry
      ,each src.clob-data no-lock
      where src.clob-data.db-num = dst.clob-bind.db-num
        and src.clob-data.int64-id = dst.clob-bind.int64-id
    on error  undo, return error substitute( "&1 (clob-data). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo, return error substitute( "&1 (clob-data). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (clob-data). endkey", vss-workfile )
    :
      if not can-find (first dst.clob-data no-lock
      where dst.clob-data.db-num = dst.clob-bind.db-num
        and dst.clob-data.int64-id = dst.clob-bind.int64-id)
      then do:
        create dst.clob-data .
        buffer-copy src.clob-data to dst.clob-data .
      end.
    end.
    end.
    lob-res-list = {&lob-res-list} + {&comma-char} + {&lob-res-list-macro} .
    do v-jj = 1 to num-entries(lob-res-list):
      v-entry = entry(v-jj, lob-res-list).
      for each src.clob-bind no-lock
        where src.clob-bind.resource-type = v-entry
        ,each src.clob-data no-lock
        where src.clob-data.db-num = dst.clob-bind.db-num
          and src.clob-data.int64-id = dst.clob-bind.int64-id
      on error  undo, return error substitute( "&1 (clob-data). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo, return error substitute( "&1 (clob-data). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (clob-data). endkey", vss-workfile )
      :
        if src.clob-data.is-cs = no then next.
        create dst.clob-data .
        buffer-copy src.clob-data to dst.clob-data .
        create dst.clob-bind .
        buffer-copy src.clob-bind to dst.clob-bind .
      end.
    end.
    lob-res-list = {&lob-egais-ab} + {&comma-char} + {&lob-egais-awo}
      + {&comma-char} + {&lob-egais-ab_shop} + {&comma-char} + {&lob-egais-awo_shop}
      + {&comma-char} + {&lob-egais-wb} + {&comma-char} + {&lob-egais-ref-b} + {&comma-char} + {&lob-egais-wb-act} + {&comma-char} + {&lob-egais-ticket} + {&comma-char} + {&lob-egais-wb-ticket}.
    do v-jj = 1 to num-entries(lob-res-list):
      v-entry = entry(v-jj, lob-res-list).
      for each src.clob-bind no-lock
        where src.clob-bind.resource-type = v-entry
        ,each src.clob-data no-lock
        where src.clob-data.db-num = dst.clob-bind.db-num
          and src.clob-data.int64-id = dst.clob-bind.int64-id
      on error  undo, return error substitute( "&1 (clob-data). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo, return error substitute( "&1 (clob-data). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (clob-data). endkey", vss-workfile )
      :
        if src.clob-data.is-cs = no then next.
        create dst.clob-data .
        buffer-copy src.clob-data to dst.clob-data .
        create dst.clob-bind .
        buffer-copy src.clob-bind to dst.clob-bind .
      end.
    end.


    output stream slog to rest-rdb.txt append .
    export stream slog "bar-code":U cur-time-string() .
    output stream slog close .


    assign
      ind1 = 0
      fl = "bar-code":U
    .
    for each ub.bar-code no-lock
    on error  undo, return error substitute( "&1 (ub.bar-code). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo, return error substitute( "&1 (ub.bar-code). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (ub.bar-code). endkey", vss-workfile )
    :
      assign
        ind1 = ind1 + 1
      .
      do with frame ddd
      :
        assign
          fl :screen-value   = string( fl, fl :format)
          ind1 :screen-value = string( ind1, ind1 :format)
        .
      end.

      create dst.bar-code.
      buffer-copy ub.bar-code to dst.bar-code.
      for each ub.prod-bc no-lock
         where ub.prod-bc.b-code = ub.bar-code.b-code
      on error  undo, return error substitute( "&1 (ub.prod-bc). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo, return error substitute( "&1 (ub.prod-bc). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (ub.prod-bc). endkey", vss-workfile )
      :
        if ub.prod-bc.bc-on-type eq {&gtin}
        then
            l-prod-bc-global = yes.
        else do:
        { gbl/prodbcat.i
          ub.prod-bc
          "'global=request':u"
          l-prod-bc-global
          no-error
        }
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при определении типа дополнительного бар-кода prodbcat" skip
            "Основной бар-код" ub.prod-bc.b-code skip
            "Дополнительный бар-код" ub.prod-bc.b-str skip
            "Действие global=request" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) .
        end.
        end.
        if l-prod-bc-global then do:
          create dst.prod-bc.
          buffer-copy ub.prod-bc to dst.prod-bc.
        end.
      end.
    end.
    if not mode-erprn then do: 
       run cre-activ-code-range ( input p-db-num
                                 ,input {&gbl-bc-code}
                                ) no-error.
       if error-status :error then do:
         message
           vss-workfile vss-revision vss-description skip
           "Ошибка при активизации диапазона собственных кодов товаров (бар-кодов)" skip
           error-status :get-message(1) skip
           return-value skip
           view-as alert-box error .
         undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) .
       end.
    end.
    run cre-activ-code-range ( input p-db-num
                              ,input {&gbl-sc-code}
                             ) no-error.
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при активизации диапазона глобальных весовых кодов" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) .
    end.
    run cre-activ-code-range ( input p-db-num
                              ,input {&loc-sc-code}
                             ) no-error.
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при активизации диапазона локальных весовых кодов" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) .
    end.
    run cre-activ-code-range ( input p-db-num
                              ,input {&loc-pg-code}
                             ) no-error.
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при активизации диапазона локальных штучных кодов для весов" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) .
    end.
    run cre-activ-code-range ( input p-db-num
                              ,input {&gbl-ss-code}
                             ) no-error.
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при активизации диапазона глобальных взвешиваемых кодов" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) .
    end.
    run cre-activ-code-range ( input p-db-num
                              ,input {&loc-ss-code}
                             ) no-error.
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при активизации диапазона локальных взвешиваемых кодов" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) .
    end.
    run cre-activ-code-range ( input p-db-num
                              ,input {&gbl-dc-code}
                             ) no-error.
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при активизации диапазона кодов дисконтных карт" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) .
    end.
    run cre-activ-code-range ( input p-db-num
                              ,input {&gbl-ca-code}
                             ) no-error.
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при активизации диапазона кодов точек привязки" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) .
    end.
    run cre-activ-code-range ( input p-db-num
                              ,input {&gbl-ct-code}
                             ) no-error.
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при активизации диапазона кодов договоров" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) .
    end.
    run cre-activ-code-range ( input p-db-num
                              ,input {&gbl-dr-code}
                             ) no-error.
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при активизации диапазона кодов правил скидок и расписаний" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) .
    end.
     run cre-activ-code-range ( input p-db-num
                              ,input {&gbl-fd-code}
                             ) no-error.
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при активизации диапазона кодов фин документов" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) .
    end.
    if ub.db.remote-stock = no then do:
      output stream slog to rest-rdb.txt append .
      export stream slog "db-status" cur-time-string() .
      output stream slog close .

      for each ub.db-status no-lock
          where ub.db-status.db-num = p-db-num
      on error  undo, return error substitute( "&1 (ub.db-status). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo, return error substitute( "&1 (ub.db-status). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (ub.db-status). endkey", vss-workfile )
      :
        create dst.db-status.
        buffer-copy ub.db-status to dst.db-status.
      end.
    end.

    output stream slog to rest-rdb.txt append .
    export stream slog "ext-system":U cur-time-string() .
    output stream slog close .

    assign
      tot-cli-count = 0
    .
    /* выгрузка внешних систем */
    run adm/restext.p (
          input this-procedure
        , input p-db-num
        , input p-unload-history
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка выгрузки внешней подсистемы для БД" p-db-num
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) .
    end.
     /*Проверка конф. параметра ser-wth для оптимизации выгрузки документов МЦ*/
    { gbl/conf-rd.i
    "'ser-wth'"
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
    IF not error-status:error and conf-par = "yes":U then ser-wth-conf-par = yes.
    else ser-wth-conf-par = no.

    /* просматриваются все объекты БД */
    for each ub.clients no-lock
      where ub.clients.db-num = p-db-num
    on error  undo, return error substitute( "&1 (1 clients-all). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo, return error substitute( "&1 (1 clients-all). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (1 clients-all). endkey", vss-workfile )
    :
      assign
        tot-cli-count = tot-cli-count + 1
      .
    end.

    assign
      v-cli-count = 0
    .

    output stream slog to rest-rdb.txt append .
    export stream slog "start rest-season" cur-time-string() .
    output stream slog close .
    run rest-season in this-procedure
      ( input ""
       ,input ?
      )
      no-error
    .
    if error-status:error then do:
      output stream slog to rest-rdb.txt append .
      export stream slog
      "    !!!!rest-season"
      substitute( " &1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)) skip.
      output stream slog close .
      undo, return error  substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
    end.
    else do:
      output stream slog to rest-rdb.txt append .
      export stream slog
      "OK rest-season"  skip.
      output stream slog close .
    end.
    
    output stream slog to rest-rdb.txt append .
      export stream slog "start CashBook " cur-time-string() .
      output stream slog close .

      run rest-cash-book in this-procedure
        
        no-error .
      if error-status :error then do:
        output stream slog to rest-rdb.txt append .
        export stream slog  error-status :get-message(1) return-value cur-time-string() .
        output stream slog close .
        return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) .
      end.
      else do:
         output stream slog to rest-rdb.txt append .
         export stream slog
         "OK CashBook"  skip.
         output stream slog close .
      end.

    for each ub.clients no-lock
      where ub.clients.db-num = p-db-num
    on error  undo, return error substitute( "&1 (clients-all). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo, return error substitute( "&1 (clients-all). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (clients-all). endkey", vss-workfile )
    :
      output stream slog to rest-rdb.txt append .
      export stream slog substitute("START &1&2 &3", ub.clients.obj-type, ub.clients.obj-code, cur-time-string() ).
      output stream slog close .


      assign
        v-cli-count = v-cli-count + 1
        count-str = "Обработано объектов" + {&space-char} + string( v-cli-count ) + {&space-char}
                    + "из" + {&space-char} + string( tot-cli-count )
      .
      if ub.clients.obj-type = {&stock} then do:
        find ub.store where ub.store.obj-code = ub.clients.obj-code no-lock.
        assign
          host = ub.store.host-code
        .
      end.
      else do:
        find ub.shop where ub.shop.obj-code = ub.clients.obj-code no-lock.
        assign
          host = ub.shop.host-code
        .
      end.

      /* если мы еще не перекачивали таблицы привязанные к host-code, то перекачаем сейчас */
      if not can-find( first tt-host-list where tt-host-list.host-code = host no-lock ) then do:
        assign
          ind1 = 0
          fl = "cli-gds":U
        .
        for each ub.cli-gds no-lock
          where ub.cli-gds.host-code = host
        on error  undo, return error substitute( "&1 (ub.cli-gds). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
        on stop   undo, return error substitute( "&1 (ub.cli-gds). stop", vss-workfile )
        on endkey undo, return error substitute( "&1 (ub.cli-gds). endkey", vss-workfile )
        :
          assign  ind1 = ind1 + 1.
          do with frame ddd
          :
            assign
              count-str :screen-value   = string( count-str, count-str :format)
              fl :screen-value          = string( fl, fl :format)
              ind1 :screen-value        = string( ind1, ind1 :format)
            .
          end.

          if not can-find( first dst.cli-gds no-lock
            where dst.cli-gds.cli-type  = ub.cli-gds.cli-type
              and dst.cli-gds.cli-code  = ub.cli-gds.cli-code
              and dst.cli-gds.host-code = ub.cli-gds.host-code
              and dst.cli-gds.artic     = ub.cli-gds.artic
              and dst.cli-gds.prod-type = ub.cli-gds.prod-type
              and dst.cli-gds.prod-code = ub.cli-gds.prod-code )
              then do:
            create dst.cli-gds.
            buffer-copy ub.cli-gds to dst.cli-gds.
          end.
        end.
        create tt-host-list.
        assign
          tt-host-list.host-code = host
        .
      end.

      for each buf_rrdb-option
        where buf_rrdb-option.dump-point = "obj"
      on error  undo, return error substitute( "&1 (buf_rrdb-option.dump-point = obj). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo, return error substitute( "&1 (buf_rrdb-option.dump-point = obj). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (buf_rrdb-option.dump-point = obj). endkey", vss-workfile )
      :
        assign
        v-subject =  (if buf_rrdb-option.subject-group = "dc"
                      then buf_rrdb-option.des
                      else buf_rrdb-option.first-table-name)
        count-str = "Справочники по объектам"
        fl = v-subject
        .

        do with frame ddd
        :
          assign
            count-str :screen-value   = string( count-str, count-str :format)
            fl :screen-value          = string( fl, fl :format)
            ind1 :screen-value        = string( ind1, ind1 :format)
          .
        end.


        output stream slog to rest-rdb.txt append .
        export stream slog "table-obj-move" v-subject cur-time-string() .
        output stream slog close .

        if buf_rrdb-option.first-table-name begins 'c-':U then do:
          assign
          v-hn = yes
          v-hn = get-hist-nws-option( input p-db-num
                                      ,input buf_rrdb-option.first-table-name)
          no-error .
        end.
        else do:
          v-hn = yes.
        end.
        if not v-hn then do:
          output stream slog to rest-rdb.txt append .
          export stream slog "!!!SKIPPING other db  history records!!!!!" .
          output stream slog close .
        end.
        run adm/cred-tbl.p (
                           input this-procedure:handle
                          ,input p-db-num
                          ,input ub.clients.obj-type
                          ,input ub.clients.obj-code
                          ,input 0 /*p-host-code*/
                          ,input count-str
                          ,input {&all-query-buffers}
                          ,input {&all-query-buffers-export}
                          ,input buf_rrdb-option.where-phrase
                          ,input buf_rrdb-option.if-phrase
                          ,input buf_rrdb-option.if-buffer-num
                          ,input "obj"
                          ,input v-hn
                          ,input yes /*p-run-or-check*/
                          ) .
        output stream slog to rest-rdb.txt append .
        export stream slog "OK table-obj-move" v-subject cur-time-string() .
        output stream slog close .
      end.

      for each buf_rrdb-option
        where buf_rrdb-option.dump-point = "host-obj"
      on error  undo, return error substitute( "&1 (buf_rrdb-option.dump-point = obj). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo, return error substitute( "&1 (buf_rrdb-option.dump-point = obj). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (buf_rrdb-option.dump-point = obj). endkey", vss-workfile )
      :
        assign
        v-subject =  (if buf_rrdb-option.subject-group = "dc"
                      then buf_rrdb-option.des
                      else buf_rrdb-option.first-table-name)
        count-str = "Справочники по фирм-объектам"
        fl = v-subject
        .

        do with frame ddd
        :
          assign
            count-str :screen-value   = string( count-str, count-str :format)
            fl :screen-value          = string( fl, fl :format)
            ind1 :screen-value        = string( ind1, ind1 :format)
          .
        end.


        output stream slog to rest-rdb.txt append .
        export stream slog "table-host-obj-move" v-subject cur-time-string() .
        output stream slog close .

        if buf_rrdb-option.first-table-name begins 'c-':U then do:
          assign
          v-hn = yes
          v-hn = get-hist-nws-option( input p-db-num
                                      ,input buf_rrdb-option.first-table-name)
          no-error .
        end.
        else do:
          v-hn = yes.
        end.
        if not v-hn then do:
          output stream slog to rest-rdb.txt append .
          export stream slog "!!!SKIPPING other db  history records!!!!!" .
          output stream slog close .
        end.
        run adm/cred-tbl.p (
                           input this-procedure:handle
                          ,input p-db-num
                          ,input ub.clients.obj-type
                          ,input ub.clients.obj-code
                          ,input ub.clients.host-code
                          ,input count-str
                          ,input {&all-query-buffers}
                          ,input {&all-query-buffers-export}
                          ,input buf_rrdb-option.where-phrase
                          ,input buf_rrdb-option.if-phrase
                          ,input buf_rrdb-option.if-buffer-num
                          ,input "host-obj"
                          ,input v-hn
                          ,input yes /*p-run-or-check*/
                          ) .
        output stream slog to rest-rdb.txt append .
        export stream slog "OK table-host-obj-move" v-subject cur-time-string() .
        output stream slog close .
      end.


      /* выгрузим таблицы с нетрадиционными именами для obj-type и obj-code */
      for each buf_rrdb-option
        where buf_rrdb-option.dump-point = "Xobj"
      on error  undo, return error substitute( "&1 (buf_rrdb-option.dump-point = Xobj). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo, return error substitute( "&1 (buf_rrdb-option.dump-point = Xobj). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (buf_rrdb-option.dump-point = Xobj). endkey", vss-workfile )
      :
        assign
        v-subject =  (if buf_rrdb-option.subject-group = "dc"
                      then buf_rrdb-option.des
                      else buf_rrdb-option.first-table-name)
        count-str = "Справочники по объектам"
        fl = v-subject
        .

        do with frame ddd
        :
          assign
            count-str :screen-value   = string( count-str, count-str :format)
            fl :screen-value          = string( fl, fl :format)
            ind1 :screen-value        = string( ind1, ind1 :format)
          .
        end.

        output stream slog to rest-rdb.txt append .
        export stream slog "table-Xobj-move" v-subject cur-time-string() .
        output stream slog close .
        if buf_rrdb-option.first-table-name begins 'c-':U then do:
          assign
          v-hn = yes
          v-hn = get-hist-nws-option( input p-db-num
                                      ,input buf_rrdb-option.first-table-name)
          no-error .
        end.
        else do:
          v-hn = yes.
        end.
        if not v-hn then do:
          output stream slog to rest-rdb.txt append .
          export stream slog "!!!SKIPPING other db  history records!!!!!" .
          output stream slog close .
        end.
        run adm/cred-tbl.p (
                            input this-procedure:handle
                          ,input p-db-num
                          ,input ub.clients.obj-type
                          ,input ub.clients.obj-code
                          ,input 0 /*p-host-code*/
                          ,input count-str
                          ,input {&all-query-buffers}
                          ,input {&all-query-buffers-export}
                          ,input buf_rrdb-option.where-phrase
                          ,input buf_rrdb-option.if-phrase
                          ,input buf_rrdb-option.if-buffer-num
                          ,input "Xobj"
                          ,input v-hn
                          ,input yes /*p-run-or-check*/
                          ) .
        output stream slog to rest-rdb.txt append .
        export stream slog "OK Xobj" v-subject cur-time-string() .
        output stream slog close .
      end.

      if ub.clients.obj-type = {&shop} then do:
        do transaction
        on error  undo, return error substitute( "&1 (dst.curr-shop). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
        on stop   undo, return error substitute( "&1 (dst.curr-shop). stop", vss-workfile )
        on endkey undo, return error substitute( "&1 (dst.curr-shop). endkey", vss-workfile )
        :
          create dst.curr-shop.
          assign
            dst.curr-shop.curr-code = 0
            dst.curr-shop.exch-date = today
            dst.curr-shop.exch-rate = 1
            dst.curr-shop.exch-scale = 1
            dst.curr-shop.exch-time = time
            dst.curr-shop.obj-code = ub.clients.obj-code
            dst.curr-shop.obj-type = {&shop}.
        end.
      end.

      output stream slog to rest-rdb.txt append .
      export stream slog "start rest-price-doc " cur-time-string() .
      output stream slog close .

      run rest-price-doc in this-procedure
        ( input ub.clients.obj-type
         ,input ub.clients.obj-code
        )  no-error.
      .
      if error-status:error then do:
        output stream slog to rest-rdb.txt append .
        export stream slog
        "    !!!!rest-price-doc"
        substitute( " &1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)) skip.
        output stream slog close .
        undo, return error  substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
      end.
      else do:
        output stream slog to rest-rdb.txt append .
        export stream slog
        "OK rest-price-doc"  skip.
        output stream slog close .
      end.


      output stream slog to rest-rdb.txt append .
      export stream slog "start rest-price-all " cur-time-string() .
      output stream slog close .

      run rest-price-all in this-procedure
        ( input ub.clients.obj-type
         ,input ub.clients.obj-code
        )  no-error.
      .
      if error-status:error then do:
        output stream slog to rest-rdb.txt append .
        export stream slog
        "    !!!!rest-price-all"
        substitute( " &1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)) skip.
        output stream slog close .
        undo, return error  substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
      end.
      else do:
        output stream slog to rest-rdb.txt append .
        export stream slog
        "OK rest-price-all"  skip.
        output stream slog close .
      end.


      output stream slog to rest-rdb.txt append .
      export stream slog "start parts-free " cur-time-string() .
      output stream slog close .


      assign ind1 = 0
             fl   = "parts-free".
      for each ub.parts no-lock
        where ub.parts.obj-type = ub.clients.obj-type
          and ub.parts.obj-code = ub.clients.obj-code
          and ub.parts.out-code = {&free-code}
      on error  undo, return error substitute( "&1 (parts-free). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo, return error substitute( "&1 (parts-free). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (parts-free). endkey", vss-workfile )
      :
        assign  ind1 = ind1 + 1.
        do with frame ddd
        :
          assign
            count-str :screen-value   = string( count-str, count-str :format)
            fl :screen-value          = string( fl, fl :format)
            ind1 :screen-value        = string( ind1, ind1 :format)
          .
        end.
        run process-parts in this-procedure .
      end.

      output stream slog to rest-rdb.txt append .
      export stream slog "start parts-out " cur-time-string() .
      output stream slog close .


      assign ind1 = 0
             fl   = "parts-out".
      for each ub.parts no-lock
        where ub.parts.obj-type = ub.clients.obj-type
          and ub.parts.obj-code = ub.clients.obj-code
          and ub.parts.out-code = {&output-code}
      on error  undo, return error substitute( "&1 (parts-out). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo, return error substitute( "&1 (parts-out). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (parts-out). endkey", vss-workfile )
      :
        assign  ind1 = ind1 + 1.
        do with frame ddd
        :
          assign
            count-str :screen-value   = string( count-str, count-str :format)
            fl :screen-value          = string( fl, fl :format)
            ind1 :screen-value        = string( ind1, ind1 :format)
          .
        end.
        run process-parts in this-procedure .
      end.

      assign ind1 = 0
             fl   = "parts-obj-attr".
      for each ub.parts-obj-attr no-lock
        where ub.parts-obj-attr.obj-type = ub.clients.obj-type
          and ub.parts-obj-attr.obj-code = ub.clients.obj-code
      on error  undo, return error substitute( "&1 (parts-obj-attr). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo, return error substitute( "&1 (parts-obj-attr). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (parts-obj-attr). endkey", vss-workfile )
      :
        assign  ind1 = ind1 + 1.
        do with frame ddd
        :
          assign
            count-str :screen-value   = string( count-str, count-str :format)
            fl :screen-value          = string( fl, fl :format)
            ind1 :screen-value        = string( ind1, ind1 :format)
          .
        end.
        create dst.parts-obj-attr.
        buffer-copy ub.parts-obj-attr to dst.parts-obj-attr.
      end.


      output stream slog to rest-rdb.txt append .
      export stream slog "start rest-trn-doc " cur-time-string() .
      output stream slog close .

      run rest-trn-doc in this-procedure
        ( input ub.clients.obj-type
         ,input ub.clients.obj-code
        )
        no-error
      .
      if error-status :error then do:
          output stream slog to rest-rdb.txt append .
          export stream slog  error-status :get-message(1) return-value cur-time-string() .
          output stream slog close .
          return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) .
      end.
      
       

      if p-unload-history then do:
        output stream slog to rest-rdb.txt append .
        export stream slog "start rest-c-trn-doc " cur-time-string() .
        output stream slog close .


        run rest-c-trn-doc in this-procedure
          ( input ub.clients.obj-type
          ,input ub.clients.obj-code
          )
          no-error
        .
        if error-status :error then do:
            output stream slog to rest-rdb.txt append .
            export stream slog  error-status :get-message(1) return-value cur-time-string() .
            output stream slog close .
            return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) .
        end.
      end. /*if p-unload-history then do:*/

      output stream slog to rest-rdb.txt append .
      export stream slog "start rest-Utd " cur-time-string() .
      output stream slog close .

      run rest-Utd in this-procedure
        ( input ub.clients.obj-type
         ,input ub.clients.obj-code
        )
        no-error
      .
      if error-status :error then do:
          output stream slog to rest-rdb.txt append .
          export stream slog  error-status :get-message(1) return-value cur-time-string() .
          output stream slog close .
          return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) .
      end.
      
      output stream slog to rest-rdb.txt append .
      export stream slog "start rest-inkas " cur-time-string() .
      output stream slog close .


      run rest-inkas in this-procedure
        ( input ub.clients.obj-type
         ,input ub.clients.obj-code
        ) no-error .
      if error-status :error then do:
        return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) .
      end.
      if p-unload-history then do:
        output stream slog to rest-rdb.txt append .
        export stream slog "start rest-c-inkas " cur-time-string() .
        output stream slog close .

        run rest-c-inkas in this-procedure
          ( input ub.clients.obj-type
          ,input ub.clients.obj-code
          )
        .
      end.
      if not ser-wth-conf-par then do:
        output stream slog to rest-rdb.txt append .
        export stream slog "start rest-wth-doc " cur-time-string() .
        output stream slog close .


        run rest-wth-doc in this-procedure
          ( input ub.clients.obj-type
          ,input ub.clients.obj-code
          )
        .
        if p-unload-history then do:
        output stream slog to rest-rdb.txt append .
        export stream slog "start rest-c-wth-doc " cur-time-string() .
        output stream slog close .

        run rest-c-wth-doc in this-procedure
          ( input ub.clients.obj-type
          ,input ub.clients.obj-code
          )
        .
        end.
      end.
      /*----S----Финансовые-документы----*/
/*      { gbl/cashbook.i ub.clients.obj-type ub.clients.obj-code fin-doc-par no-error }*/
/*                                                                                     */
/*      if fin-doc-par = integer({&cash-book-object}) then do :                        */
        output stream slog to rest-rdb.txt append .
        export stream slog "start rest-fin-doc " cur-time-string() .
        output stream slog close .

        run rest-fin-doc in this-procedure
          ( input ub.clients.obj-type
          ,input ub.clients.obj-code
          )
        .
        if p-unload-history then do:
          output stream slog to rest-rdb.txt append .
          export stream slog "start rest-c-fin-doc " cur-time-string() .
          output stream slog close .

          run rest-c-fin-doc in this-procedure
            ( input ub.clients.obj-type
            ,input ub.clients.obj-code
            )
          .
        end.
/*      end.*/
      /*----E----Финансовые-документы----*/
      if ub.clients.obj-type = {&shop} then do:

        output stream slog to rest-rdb.txt append .
        export stream slog "start rest-chk " cur-time-string() .
        output stream slog close .

        run rest-chk in this-procedure
          ( input ub.clients.obj-type
          ,input ub.clients.obj-code
          )
        .
      end.

      output stream slog to rest-rdb.txt append .
      export stream slog "start rest-arh-wth-tot " cur-time-string() .
      output stream slog close .

      run rest-arh-wth-tot in this-procedure
          ( input ub.clients.obj-type
          ,input ub.clients.obj-code
          )
      .
      output stream slog to rest-rdb.txt append .
      export stream slog "start rest-arh-wth-w-p " cur-time-string() .
      output stream slog close .

      run rest-arh-wth-w-p in this-procedure
          ( input ub.clients.obj-type
          ,input ub.clients.obj-code
          )
      .



      output stream slog to rest-rdb.txt append .
      export stream slog "start fbr-doc " cur-time-string() .
      output stream slog close .


      assign ind1 = 0
             fl   = "fbr-doc".
      for each ub.fbr-doc no-lock
          where ub.fbr-doc.obj-type = ub.clients.obj-type
            and ub.fbr-doc.obj-code = ub.clients.obj-code
      on error  undo, return error substitute( "&1 (fbr-doc). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo, return error substitute( "&1 (fbr-doc). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (fbr-doc). endkey", vss-workfile )
      :
        for each ub.fbr-line no-lock
            where ub.fbr-line.doc-code = ub.fbr-doc.doc-code
        on error  undo, return error substitute( "&1 (fbr-line). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
        on stop   undo, return error substitute( "&1 (fbr-line). stop", vss-workfile )
        on endkey undo, return error substitute( "&1 (fbr-line). endkey", vss-workfile )
        :
          create dst.fbr-line.
          buffer-copy ub.fbr-line to dst.fbr-line no-error.
        end.
        assign  ind1 = ind1 + 1.
        do with frame ddd
        :
          assign
            count-str :screen-value   = string( count-str, count-str :format)
            fl :screen-value          = string( fl, fl :format)
            ind1 :screen-value        = string( ind1, ind1 :format)
          .
        end.

        create dst.fbr-doc.
        buffer-copy  ub.fbr-doc to dst.fbr-doc.
      end.

      output stream slog to rest-rdb.txt append .
      export stream slog "start fbr-pln " cur-time-string() .
      output stream slog close .

      assign ind1 = 0
             fl   = "fbr-pln".
      for each ub.fbr-pln no-lock
          where ub.fbr-pln.obj-type = ub.clients.obj-type
            and ub.fbr-pln.obj-code = ub.clients.obj-code
      on error  undo, return error substitute( "&1 (fbr-pln). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo, return error substitute( "&1 (fbr-pln). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (fbr-pln). endkey", vss-workfile )
      :
        for each ub.fbr-pln-line no-lock
            where ub.fbr-pln-line.doc-code = ub.fbr-pln.doc-code
        on error  undo, return error substitute( "&1 (fbr-pln-line). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
        on stop   undo, return error substitute( "&1 (fbr-pln-line). stop", vss-workfile )
        on endkey undo, return error substitute( "&1 (fbr-pln-line). endkey", vss-workfile )
        :
          create dst.fbr-pln-line.
          buffer-copy ub.fbr-pln-line to dst.fbr-pln-line no-error.
        end.
        assign  ind1 = ind1 + 1.
        do with frame ddd
        :
          assign
            count-str :screen-value   = string( count-str, count-str :format)
            fl :screen-value          = string( fl, fl :format)
            ind1 :screen-value        = string( ind1, ind1 :format)
          .
        end.
        create dst.fbr-pln.
        buffer-copy  ub.fbr-pln to dst.fbr-pln.
      end.
      if p-unload-history then do:
        output stream slog to rest-rdb.txt append .
        export stream slog "start c-fbr-pln " cur-time-string() .
        output stream slog close .

        assign ind1 = 0
              fl   = "c-fbr-pln".
        for each ub.c-fbr-pln no-lock
            where ub.c-fbr-pln.obj-type = ub.clients.obj-type
              and ub.c-fbr-pln.obj-code = ub.clients.obj-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          for each ub.c-fbr-pln-line no-lock
              where ub.c-fbr-pln-line.doc-code = ub.c-fbr-pln.doc-code
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
          :
            create dst.c-fbr-pln-line.
            buffer-copy ub.c-fbr-pln-line to dst.c-fbr-pln-line no-error.
          end.
          assign  ind1 = ind1 + 1.
          do with frame ddd
          :
            assign
              count-str :screen-value   = string( count-str, count-str :format)
              fl :screen-value          = string( fl, fl :format)
              ind1 :screen-value        = string( ind1, ind1 :format)
            .
          end.
          create dst.c-fbr-pln.
          buffer-copy  ub.c-fbr-pln to dst.c-fbr-pln.
        end.
      end.
      output stream slog to rest-rdb.txt append .
      export stream slog "start rvs-doc " cur-time-string() .
      output stream slog close .

      assign ind1 = 0
             fl   = "rvs-doc".
      for each ub.rvs-doc no-lock
          where ub.rvs-doc.obj-type = ub.clients.obj-type
            and ub.rvs-doc.obj-code = ub.clients.obj-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        for each ub.rvs-line no-lock
            where ub.rvs-line.rvs-code = ub.rvs-doc.rvs-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.rvs-line.
          buffer-copy ub.rvs-line to dst.rvs-line no-error.
        end.
        for each ub.rvs-line-pump no-lock
            where ub.rvs-line-pump.rvs-code = ub.rvs-doc.rvs-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.rvs-line-pump.
          buffer-copy ub.rvs-line-pump to dst.rvs-line-pump no-error.
        end.
        for each ub.rvs-pump no-lock
            where ub.rvs-pump.rvs-code = ub.rvs-doc.rvs-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.rvs-pump.
          buffer-copy ub.rvs-pump to dst.rvs-pump no-error.
        end.
        for each ub.doc-attr no-lock
            where ub.doc-attr.doc-code = ub.rvs-doc.rvs-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.doc-attr.
          buffer-copy ub.doc-attr to dst.doc-attr no-error.
        end.
        assign  ind1 = ind1 + 1.
        do with frame ddd
        :
          assign
            count-str :screen-value   = string( count-str, count-str :format)
            fl :screen-value          = string( fl, fl :format)
            ind1 :screen-value        = string( ind1, ind1 :format)
          .
        end.
        create dst.rvs-doc.
        buffer-copy  ub.rvs-doc to dst.rvs-doc.
      end.
      if p-unload-history then do:
        output stream slog to rest-rdb.txt append .
        export stream slog "start c-rvs-doc " cur-time-string() .
        output stream slog close .


        assign ind1 = 0
              fl   = "c-rvs-doc".
        for each ub.c-rvs-doc no-lock
            where ub.c-rvs-doc.obj-type = ub.clients.obj-type
              and ub.c-rvs-doc.obj-code = ub.clients.obj-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          for each ub.c-rvs-line no-lock
              where ub.c-rvs-line.rvs-code         = ub.c-rvs-doc.rvs-code
                and ub.c-rvs-line.corr-user-db-num = ub.c-rvs-doc.corr-user-db-num
                and ub.c-rvs-line.chip-num         = ub.c-rvs-doc.chip-num
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
          :
            create dst.c-rvs-line.
            buffer-copy ub.c-rvs-line to dst.c-rvs-line .
          end.
          for each ub.c-rvs-line-pump no-lock
              where ub.c-rvs-line-pump.rvs-code         = ub.c-rvs-doc.rvs-code
                and ub.c-rvs-line-pump.corr-user-db-num = ub.c-rvs-doc.corr-user-db-num
                and ub.c-rvs-line-pump.chip-num         = ub.c-rvs-doc.chip-num
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
          :
            create dst.c-rvs-line-pump.
            buffer-copy ub.c-rvs-line-pump to dst.c-rvs-line-pump .
          end.
          for each ub.c-doc-attr no-lock
              where ub.c-doc-attr.doc-code         = ub.c-rvs-doc.rvs-code
                and ub.c-doc-attr.corr-user-db-num = ub.c-rvs-doc.corr-user-db-num
                and ub.c-doc-attr.chip-num         = ub.c-rvs-doc.chip-num
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
          :
            create dst.c-doc-attr.
            buffer-copy ub.c-doc-attr to dst.c-doc-attr .
          end.
          assign  ind1 = ind1 + 1.
          do with frame ddd
          :
            assign
              count-str :screen-value   = string( count-str, count-str :format)
              fl :screen-value          = string( fl, fl :format)
              ind1 :screen-value        = string( ind1, ind1 :format)
            .
          end.
          create dst.c-rvs-doc.
          buffer-copy ub.c-rvs-doc to dst.c-rvs-doc.
        end.
      end.
      output stream slog to rest-rdb.txt append .
      export stream slog "start icnt-doc " cur-time-string() .
      output stream slog close .

      assign ind1 = 0
             fl   = "icnt-doc".
      for each ub.icnt-doc no-lock
          where ub.icnt-doc.obj-type = ub.clients.obj-type
            and ub.icnt-doc.obj-code = ub.clients.obj-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        for each ub.icnt-line no-lock
            where ub.icnt-line.doc-code = ub.icnt-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.icnt-line.
          buffer-copy ub.icnt-line to dst.icnt-line no-error.
        end.
        assign  ind1 = ind1 + 1.
        do with frame ddd
        :
          assign
            count-str :screen-value   = string( count-str, count-str :format)
            fl :screen-value          = string( fl, fl :format)
            ind1 :screen-value        = string( ind1, ind1 :format)
          .
        end.
        create dst.icnt-doc.
        buffer-copy  ub.icnt-doc to dst.icnt-doc.
      end.
      output stream slog to rest-rdb.txt append .
      export stream slog "start ord-doc " cur-time-string() .
      output stream slog close .


      assign ind1 = 0
             fl   = "ord-doc".

      for each ub.ord-doc no-lock
           where (ub.ord-doc.obj-type = ub.clients.obj-type
              and ub.ord-doc.obj-code = ub.clients.obj-code)
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
       if can-find (first dst.ord-doc no-lock
            where dst.ord-doc.doc-code = ub.ord-doc.doc-code ) then next.

        for each ub.ord-line no-lock
            where ub.ord-line.doc-code = ub.ord-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.ord-line.
          buffer-copy ub.ord-line to dst.ord-line no-error.
        end.

        for each ub.ord-dtl no-lock
            where ub.ord-dtl.doc-code = ub.ord-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.ord-dtl.
          buffer-copy ub.ord-dtl to dst.ord-dtl no-error.
        end.
        if ub.ord-doc.whole-send-news > 0 then do:
          for each ub.edi-status no-lock
            where ub.edi-status.tbl-name = {&table_ord-doc}
              and  ub.edi-status.doc-code = ub.ord-doc.doc-code
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
          :
            create dst.edi-status.
            buffer-copy ub.edi-status to dst.edi-status no-error.
          end.
          for each ub.edi-status no-lock
            where ub.edi-status.tbl-name = {&table_ord-line}
              and  ub.edi-status.doc-code begins (ub.ord-doc.doc-code + {&delim-par})
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
          :
            create dst.edi-status.
            buffer-copy ub.edi-status to dst.edi-status no-error.
          end.
        end. /*        if ub.ord-doc.whole-send-news > 0 then do:*/


        if not can-find( first dst.ord-cons no-lock
            where dst.ord-cons.cons-code = ub.ord-doc.cons-code )
        then do:
              for each ub.ord-cons no-lock
                  where ub.ord-cons.cons-code = ub.ord-doc.cons-code
              on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
              :
                create dst.ord-cons.
                buffer-copy ub.ord-cons to dst.ord-cons no-error.
                for each ub.ord-gds-cons no-lock
                    where ub.ord-gds-cons.cons-code = ub.ord-cons.cons-code
                on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
                :
                  create dst.ord-gds-cons.
                  buffer-copy ub.ord-gds-cons to dst.ord-gds-cons no-error.
                end.
                for each ub.ord-dtl-cons no-lock
                    where ub.ord-dtl-cons.cons-code = ub.ord-cons.cons-code
                on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
                :
                  create dst.ord-dtl-cons.
                  buffer-copy ub.ord-dtl-cons to dst.ord-dtl-cons no-error.
                end.
              end.

        end.
        assign  ind1 = ind1 + 1.
        do with frame ddd
        :
          assign
            count-str :screen-value   = string( count-str, count-str :format)
            fl :screen-value          = string( fl, fl :format)
            ind1 :screen-value        = string( ind1, ind1 :format)
          .
        end.
        create dst.ord-doc.
        buffer-copy  ub.ord-doc to dst.ord-doc.
      end.

      /* 2 одинаковых прохода - чтобы не ломался индекс из-за OR */
      for each ub.ord-doc no-lock
           where (ub.ord-doc.cli-type = ub.clients.obj-type
              and ub.ord-doc.cli-code = ub.clients.obj-code)
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
       if can-find (first dst.ord-doc no-lock
            where dst.ord-doc.doc-code = ub.ord-doc.doc-code ) then next.

        for each ub.ord-line no-lock
            where ub.ord-line.doc-code = ub.ord-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.ord-line.
          buffer-copy ub.ord-line to dst.ord-line no-error.
        end.

        for each ub.ord-dtl no-lock
            where ub.ord-dtl.doc-code = ub.ord-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.ord-dtl.
          buffer-copy ub.ord-dtl to dst.ord-dtl no-error.
        end.
        if ub.ord-doc.whole-send-news > 0 then do:
          for each ub.edi-status no-lock
            where ub.edi-status.tbl-name = {&table_ord-doc}
              and  ub.edi-status.doc-code = ub.ord-doc.doc-code
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
          :
            create dst.edi-status.
            buffer-copy ub.edi-status to dst.edi-status no-error.
          end.
          for each ub.edi-status no-lock
            where ub.edi-status.tbl-name = {&table_ord-line}
              and  ub.edi-status.doc-code begins (ub.ord-doc.doc-code + {&delim-par})
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
          :
            create dst.edi-status.
            buffer-copy ub.edi-status to dst.edi-status no-error.
          end.
        end. /*        if ub.ord-doc.whole-send-news > 0 then do:*/


        if not can-find( first dst.ord-cons no-lock
            where dst.ord-cons.cons-code = ub.ord-doc.cons-code )
        then do:
              for each ub.ord-cons no-lock
                  where ub.ord-cons.cons-code = ub.ord-doc.cons-code
              on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
              :
                create dst.ord-cons.
                buffer-copy ub.ord-cons to dst.ord-cons no-error.
                for each ub.ord-gds-cons no-lock
                    where ub.ord-gds-cons.cons-code = ub.ord-cons.cons-code
                on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
                :
                  create dst.ord-gds-cons.
                  buffer-copy ub.ord-gds-cons to dst.ord-gds-cons no-error.
                end.
                for each ub.ord-dtl-cons no-lock
                    where ub.ord-dtl-cons.cons-code = ub.ord-cons.cons-code
                on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
                :
                  create dst.ord-dtl-cons.
                  buffer-copy ub.ord-dtl-cons to dst.ord-dtl-cons no-error.
                end.
              end.

        end.
        assign  ind1 = ind1 + 1.
        do with frame ddd
        :
          assign
            count-str :screen-value   = string( count-str, count-str :format)
            fl :screen-value          = string( fl, fl :format)
            ind1 :screen-value        = string( ind1, ind1 :format)
          .
        end.
        create dst.ord-doc.
        buffer-copy  ub.ord-doc to dst.ord-doc.
      end.

      output stream slog to rest-rdb.txt append .
      export stream slog "start ord-doc-rcv " cur-time-string() .
      output stream slog close .


      assign ind1 = 0
             fl   = "ord-doc-rcv".
      for each ub.ord-doc-rcv no-lock
          where (ub.ord-doc-rcv.obj-type = ub.clients.obj-type
            and ub.ord-doc-rcv.obj-code = ub.clients.obj-code ) or
              ( ub.ord-doc-rcv.cli-type = ub.clients.obj-type
            and ub.ord-doc-rcv.cli-code = ub.clients.obj-code )

      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
       if can-find (first dst.ord-doc-rcv no-lock
            where dst.ord-doc-rcv.doc-code = ub.ord-doc-rcv.doc-code
              and dst.ord-doc-rcv.rcv-code = ub.ord-doc-rcv.rcv-code)
              then next.

        for each ub.ord-line-rcv no-lock
            where ub.ord-line-rcv.doc-code = ub.ord-doc-rcv.doc-code
              and ub.ord-line-rcv.rcv-code = ub.ord-doc-rcv.rcv-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.ord-line-rcv.
          buffer-copy ub.ord-line-rcv to dst.ord-line-rcv no-error.
        end.

        for each ub.ord-chain no-lock
            where ub.ord-chain.doc-code = ub.ord-doc-rcv.rcv-code
              and ub.ord-chain.doc-type = "rcv"
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.ord-chain.
          buffer-copy ub.ord-chain to dst.ord-chain no-error.
        end.

        for each ub.ord-dtl-rcv no-lock
            where ub.ord-dtl-rcv.doc-code = ub.ord-doc-rcv.doc-code
              and ub.ord-dtl-rcv.rcv-code = ub.ord-doc-rcv.rcv-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.ord-dtl-rcv.
          buffer-copy ub.ord-dtl-rcv to dst.ord-dtl-rcv no-error.
        end.
        if ub.ord-doc-rcv.whole-send-news > 0 then do:
          for each ub.edi-status no-lock
            where ub.edi-status.tbl-name = {&table_ord-doc-rcv}
              and  ub.edi-status.doc-code = ub.ord-doc-rcv.rcv-code
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
          :
            create dst.edi-status.
            buffer-copy ub.edi-status to dst.edi-status no-error.
          end.
          for each ub.edi-status no-lock
            where ub.edi-status.tbl-name = {&table_ord-line-rcv}
              and  ub.edi-status.doc-code begins (ub.ord-doc-rcv.rcv-code + {&delim-par})
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
          :
            create dst.edi-status.
            buffer-copy ub.edi-status to dst.edi-status no-error.
          end.
        end. /*        if ub.ord-doc.whole-send-news > 0 then do:*/

        assign  ind1 = ind1 + 1.
        do with frame ddd
        :
          assign
            count-str :screen-value   = string( count-str, count-str :format)
            fl :screen-value          = string( fl, fl :format)
            ind1 :screen-value        = string( ind1, ind1 :format)
          .
        end.
        create dst.ord-doc-rcv.
        buffer-copy  ub.ord-doc-rcv to dst.ord-doc-rcv.
      end.
      if ub.db.unload-aht = true then do:
        output stream slog to rest-rdb.txt append .
        export stream slog "start aht-time " cur-time-string() .
        output stream slog close .

        assign ind1 = 0
               fl   = "aht-time".
        for each ub.aht-time no-lock
            where ub.aht-time.obj-type = ub.clients.obj-type
              and ub.aht-time.obj-code = ub.clients.obj-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          assign  ind1 = ind1 + 1.
          do with frame ddd
          :
            assign
              count-str :screen-value   = string( count-str, count-str :format)
              fl :screen-value          = string( fl, fl :format)
              ind1 :screen-value        = string( ind1, ind1 :format)
            .
          end.
          create dst.aht-time.
          buffer-copy  ub.aht-time to dst.aht-time .
          for each ub.aht-gds no-lock
              where ub.aht-gds.aht-time-code = ub.aht-time.aht-time-code
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
          :
            create dst.aht-gds.
            buffer-copy ub.aht-gds to dst.aht-gds .
          end.
        end.
      end.
      output stream slog to rest-rdb.txt append .
      export stream slog "start obj-date " cur-time-string() .
      output stream slog close .


      /* Если на активном объекте таблица obj-date пуста (то есть, удаленка выкачивается после upgrad-а),
         то надо создать запись obj-date со статусом даты {&g___new}, как в пироге (02072213.p) */
      if not can-find (first dst.obj-date no-lock
           where dst.obj-date.obj-type = ub.clients.obj-type
             and dst.obj-date.obj-code = ub.clients.obj-code)
             then do:
        { gbl/objat.i
          ub.clients.obj-type
          ub.clients.obj-code
          "'active=request'"
          v-obj-is-active
          no-error
        }
        if v-obj-is-active = no
        then do:    /* Если в ГБД объект не активен, то он активен в выкачиваемой базе */
            run create-date-on-object (
                  input ub.clients.obj-type
                , input ub.clients.obj-code
            ) no-error.
            if error-status :error
            then do:
                message
                vss-description
                skip "Ошибка создания даты на объекте."
                skip "Тип объекта:" ub.clients.obj-type
                skip "Код объекта:" ub.clients.obj-code
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
                view-as alert-box error.
                undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) .
            end.
        end.
      end.

      output stream slog to rest-rdb.txt append .
      export stream slog "start rest-fin-ob " cur-time-string() .
      output stream slog close .

      run rest-fin-ob in this-procedure
        ( input ub.clients.obj-type
         ,input ub.clients.obj-code
        )
        no-error
      .
      if error-status :error then do:
          output stream slog to rest-rdb.txt append .
          export stream slog  error-status :get-message(1) return-value cur-time-string() .
          output stream slog close .
          return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) .
      end.

      output stream slog to rest-rdb.txt append .
      export stream slog "start rest-add-doc " cur-time-string() .
      output stream slog close .

      run rest-add-doc in this-procedure
        ( input ub.clients.obj-type
         ,input ub.clients.obj-code
        )
        no-error
      .
      if error-status :error then do:
          output stream slog to rest-rdb.txt append .
          export stream slog  error-status :get-message(1) return-value cur-time-string() .
          output stream slog close .
          return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) .
      end.

      output stream slog to rest-rdb.txt append .
      export stream slog "start rest-season-obj" cur-time-string() .
      output stream slog close .
      run rest-season in this-procedure
        ( input ub.clients.obj-type
         ,input ub.clients.obj-code
        )
        no-error
      .
      if error-status:error then do:
        output stream slog to rest-rdb.txt append .
        export stream slog
        "    !!!!rest-season-obj"
        substitute( " &1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)) skip.
        output stream slog close .
        undo, return error  substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
      end.
      else do:
        output stream slog to rest-rdb.txt append .
        export stream slog
        "OK rest-season-obj"  skip.
        output stream slog close .
      end.

      output stream slog to rest-rdb.txt append .
      export stream slog "start PromoAction " cur-time-string() .
      output stream slog close .

      run rest-promo-action in this-procedure
        no-error .
      if error-status :error then do:
        output stream slog to rest-rdb.txt append .
        export stream slog  error-status :get-message(1) return-value cur-time-string() .
        output stream slog close .
        return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) .
      end.   
    end. /* for each clients */

    /* Вызов процедуры выгрузки документов МЦ */
    if ser-wth-conf-par then do:
      output stream slog to rest-rdb.txt append .
      export stream slog "start rest-wth-doc-full " cur-time-string() .
      output stream slog close .

      run rest-wth-doc-full in this-procedure
      .

     if p-unload-history then do:
        output stream slog to rest-rdb.txt append .
        export stream slog "start rest-c-wth-doc-full " cur-time-string() .
        output stream slog close .

        run rest-c-wth-doc-full in this-procedure
        .
      end.
    end.

    output stream slog to rest-rdb.txt append .
    export stream slog "start prod-bc-db " cur-time-string() .
    output stream slog close .


    assign ind1 = 0
           fl   = "prod-bc-db".
    for each ub.prod-bc-db no-lock
        where ub.prod-bc-db.db-num = p-db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    :
      assign  ind1 = ind1 + 1.
      do with frame ddd
      :
        assign
          count-str :screen-value   = string( count-str, count-str :format)
          fl :screen-value          = string( fl, fl :format)
          ind1 :screen-value        = string( ind1, ind1 :format)
        .
      end.

      create dst.prod-bc-db.
      buffer-copy  ub.prod-bc-db to dst.prod-bc-db.
      create dst.prod-bc.
      buffer-copy  ub.prod-bc-db to dst.prod-bc
      assign
      dst.prod-bc.cr-db-num = ub.prod-bc-db.db-num
      .
    end.

    /* сюда вставлять таблицы, которые соотносятся с номером базы данных через sysconf.firm-db-num */

    /* просматриваются все фирмы БД */
    for each ub.sysconf no-lock
      where ub.sysconf.firm-db-num = p-db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    :
      assign
        tot-firm-db-count = tot-firm-db-count + 1
      .
    end.

    assign
      firm-db-count = 0
    .

    for each ub.sysconf no-lock
      where ub.sysconf.firm-db-num = p-db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    :
      assign
        firm-db-count = firm-db-count + 1
        count-str = "Обработано фирм, для которых главная БД фирмы =" + {&space-char} + string(p-db-num) + {&space-char} +
                    string( firm-db-count ) + {&space-char}
                    + "из" + {&space-char} + string( tot-firm-db-count )
      .
      for each buf_rrdb-option where buf_rrdb-option.dump-point = "firm-db"
      on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        assign
        v-subject =  (if buf_rrdb-option.subject-group = "dc"
                      then buf_rrdb-option.des
                      else buf_rrdb-option.first-table-name)
        count-str = "Справочники по главным БД фирм"
        fl = v-subject
        .

        do with frame ddd
        :
          assign
            count-str :screen-value   = string( count-str, count-str :format)
            fl :screen-value          = string( fl, fl :format)
            ind1 :screen-value        = string( ind1, ind1 :format)
          .
        end.


        output stream slog to rest-rdb.txt append .
        export stream slog "table-firm-db-move" v-subject cur-time-string() .
        output stream slog close .
        if buf_rrdb-option.first-table-name begins 'c-':U then do:
          assign
          v-hn = yes
          v-hn = get-hist-nws-option( input p-db-num
                                      ,input buf_rrdb-option.first-table-name)
          no-error .
        end.
        else do:
          v-hn = yes.
        end.
        if not v-hn then do:
          output stream slog to rest-rdb.txt append .
          export stream slog "!!!SKIPPING other db  history records!!!!!" .
          output stream slog close .
        end.
        run adm/cred-tbl.p (
                            input this-procedure:handle
                          ,input p-db-num
                          ,input '':U /*p-obj-type*/
                          ,input 0 /*p-obj-code*/
                          ,input ub.sysconf.host-code
                          ,input count-str
                          ,input {&all-query-buffers}
                          ,input {&all-query-buffers-export}
                          ,input buf_rrdb-option.where-phrase
                          ,input buf_rrdb-option.if-phrase
                          ,input buf_rrdb-option.if-buffer-num
                          ,input "firm-db"
                          ,input v-hn
                          ,input yes /*p-run-or-check*/
                          ) .
        output stream slog to rest-rdb.txt append .
        export stream slog "OK firm-db" v-subject cur-time-string() .
        output stream slog close .
      end.
    end. /*    for each ub.sysconf no-lock */

    assign
    v-cli-count = 0
    .
    _cl2:
    for each ub.clients no-lock
      where ub.clients.db-num = p-db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    :
      assign
        v-cli-count = v-cli-count + 1
        count-str = "Обработано объектов, для которых главная БД фирмы = 0" + {&space-char} + string( v-cli-count ) + {&space-char}
                    + "из" + {&space-char} + string( tot-cli-count )
      .
      if ub.clients.obj-type = {&stock} then do:
        find ub.store where ub.store.obj-code = ub.clients.obj-code no-lock.
        assign
          host = ub.store.host-code
        .
      end.
      else do:
        find ub.shop where ub.shop.obj-code = ub.clients.obj-code no-lock.
        assign
          host = ub.shop.host-code
        .
      end.
      find first ub.sysconf where ub.sysconf.host-code = host no-lock.
      if ub.sysconf.firm-db-num <> 0 then NEXT _cl2.
      if LOOKUP(string(ub.sysconf.host-code), v-proceeded-host, {&delim-par}) > 0 then NEXT _cl2.
      for each buf_rrdb-option where buf_rrdb-option.dump-point = "firm-db"
      on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        assign
        v-subject =  (if buf_rrdb-option.subject-group = "dc"
                      then buf_rrdb-option.des
                      else buf_rrdb-option.first-table-name)
        count-str = "Справочники по главным БД фирм"
        fl = v-subject
        .

        do with frame ddd
        :
          assign
            count-str :screen-value   = string( count-str, count-str :format)
            fl :screen-value          = string( fl, fl :format)
            ind1 :screen-value        = string( ind1, ind1 :format)
          .
        end.


        if lookup(buf_rrdb-option.first-table-name, table-firm-db-no) > 0 then next.
        output stream slog to rest-rdb.txt append .
        export stream slog "table-firm-db-move" v-subject cur-time-string() .
        output stream slog close .
        if buf_rrdb-option.first-table-name begins 'c-':U then do:
          assign
          v-hn = yes
          v-hn = get-hist-nws-option( input p-db-num
                                      ,input buf_rrdb-option.first-table-name)
          no-error .
        end.
        else do:
          v-hn = yes.
        end.
        if not v-hn then do:
          output stream slog to rest-rdb.txt append .
          export stream slog "!!!SKIPPING other db  history records!!!!!" .
          output stream slog close .
        end.
        run adm/cred-tbl.p (
                            input this-procedure:handle
                          ,input p-db-num
                          ,input '':U
                          ,input 0
                          ,input ub.sysconf.host-code
                          ,input count-str
                          ,input {&all-query-buffers}
                          ,input {&all-query-buffers-export}
                          ,input buf_rrdb-option.where-phrase
                          ,input buf_rrdb-option.if-phrase
                          ,input buf_rrdb-option.if-buffer-num
                          ,input "firm-db"
                          ,input v-hn
                          ,input yes /*p-run-or-check*/
                          ) .
        output stream slog to rest-rdb.txt append .
        export stream slog "OK firm-db" v-subject cur-time-string() .
        output stream slog close .
      end.
      assign
      v-proceeded-host = v-proceeded-host + {&delim-par} + string(ub.sysconf.host-code)
      .

    end.

    run rest-mpl in this-procedure .

    hide frame ddd no-pause.

    output stream slog to rest-rdb.txt append .
    export stream slog "rest-sequence" cur-time-string() .
    output stream slog close .

    create alias restseq    for database value( ldbname( "dst":U ) ) .
    /*create alias restseqflt for database value( ldbname( "ubfltdst":U ) ) .*/
    create alias restseqflt for database value( ldbname( "dst":U ) ) .
    run adm/restseq.p
      ( input "rest-no-msg"
       ,input "":U
       ,input yes
      ) no-error .
    if error-status :error then do:
      delete alias restseqflt.
      delete alias restseq.
      return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) .
    end.
    delete alias restseqflt.
    delete alias restseq.

    output stream slog to rest-rdb.txt append .
    export stream slog "stop-rest-success" cur-time-string() .
    output stream slog close .

    output stream slog to rest-rdb.txt append .
    export stream slog "two-commit-command" cur-time-string() .
    output stream slog close .

    run rest-tcc in this-procedure
      ( input p-db-num
       ,input p-type-unload
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при обработке команд two-commit" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) .
    end.

    output stream slog to rest-rdb.txt append .
    export stream slog "stop-two-commit-command" cur-time-string() .
    output stream slog close .

    output stream slog to rest-rdb.txt append .
    export stream slog "check-clients" cur-time-string() .
    output stream slog close .

    assign
      ind1 = 0
      fl = "":U
      count-str = "Проверка привязки объектов"
    .

    for each ub.clients share-lock
      where ub.clients.db-num = p-db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    :
      assign
        ind1 = ind1 + 1
      .
      do with frame inf
      :
        assign
          count-str :screen-value   = string( count-str, count-str :format)
          fl :screen-value          = string( fl, fl :format)
          ind1 :screen-value        = string( ind1, ind1 :format)
        .
      end.
      find first src.clients share-lock
        where src.clients.obj-type = ub.clients.obj-type
          and src.clients.obj-code = ub.clients.obj-code
        no-error .
      if not available src.clients
        or ub.clients.db-num <> src.clients.db-num
      then do:
        return error substitute( "&1. Клиенты привязаны к разным БД. Возможно была запущена утилита переноса объекта.", vss-workfile, ub.clients.obj-type, ub.clients.obj-code ).
      end.
    end.

    output stream slog to rest-rdb.txt append .
    export stream slog "stop-check-clients" cur-time-string() .
    output stream slog close .

    assign
      v-lock = true
    .
    { nws/lock-rt.i
      "'unlock'"
      p-db-num
      0
      "''"
      v-msg
      v-lock
      v-ok
      no-error
    }
    if error-status :error
      or v-lock = true
      or v-ok   = false
    then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "&1", v-msg ) skip
        return-value skip
        error-status :get-message ( error-status :num-messages )
        view-as alert-box error
      .
      return.
    end.
    
    output stream slog to rest-rdb.txt append .
    export stream slog "start gds-mercury " cur-time-string() .
    output stream slog close .
    
    for each src.gds-mercury no-lock:
      for each src.gds-mercury-attr no-lock where src.gds-mercury-attr.ID =  src.gds-mercury.ID 
        and src.gds-mercury-attr.db-num = src.gds-mercury.db-num:
        create dst.gds-mercury-attr .
        buffer-copy src.gds-mercury-attr to dst.gds-mercury-attr .
      end.
      create dst.gds-mercury.
      buffer-copy src.gds-mercury to dst.gds-mercury.
    end.
    
    output stream slog to rest-rdb.txt append .
    export stream slog "start vsd " cur-time-string() .
    output stream slog close .
    
    for each src.vsd where src.vsd.db-num = p-db-num no-lock:
      for each src.vsd-attr no-lock where src.vsd-attr.ID =  src.vsd.ID 
        and src.vsd-attr.db-num = src.vsd.db-num:
        create dst.vsd-attr .
        buffer-copy src.vsd-attr to dst.vsd-attr .
      end.
      create dst.vsd.
      buffer-copy src.vsd to dst.vsd.
    end.
    

    do transaction
    on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    on stop   undo, return error substitute( "&1. stop", vss-workfile )
    on endkey undo, return error substitute( "&1. endkey", vss-workfile )
    :
      disable triggers for load of ub.db.

      find ub.db exclusive-lock
        where ub.db.db-num = p-db-num
      .
      find dst.db exclusive-lock
        where dst.db.db-num = p-db-num
      .
      assign
        ub.db.db-key       = p-db-key
        ub.db.db-key-enc   = p-db-key-enc
        ub.db.stts         = 0
        dst.db.db-key      = p-db-key
        dst.db.db-key-enc  = p-db-key-enc
        dst.db.stts        = 0
      .
      if p-type-unload = {&unload-copy} then do:
        find src.db exclusive-lock
          where src.db.db-num = p-db-num
        .
        assign
          src.db.db-key      = p-db-key
          src.db.db-key-enc  = p-db-key-enc
          src.db.stts        = 0
        .
      end.

      run cur-time in this-procedure
        ( output v-today
         ,output v-time
        ).

      assign
        v-command = "command":U + {&delim-nws}
                    + "get-inf-dbs":U
      .
      { nws/cr-rt.i
        &cr-rt-log-db-name=dst
        &name-rec=v-command
        &db-num=0
        &uniq-key-rec="''":U
        &num-dump=0
        &CreDate=v-today
        &CreTimeInt=v-time
        &CreUserName="'rest-rdb'":U
      }

    end.
  end.

  if not can-find(first dst.db-attr where dst.db-attr.db-num = p-db-num and dst.db-attr.attr-code = {&attr-ver-met}) then
  do:
  /* BTS-2359 если нет атрибута,содержащего номер последнего обработанного файла upd\*.xml, для выгружаемой УБД */
  /* подменяем номер БД для этого атрибута у записи ТБД */
  /* если будут еще подобные корректировки, можно вынести в отдельную процедуру */
    for first dst.db-attr exclusive-lock where 
              dst.db-attr.db-num = 0 
          and dst.db-attr.attr-code = {&attr-ver-met}
    :
      dst.db-attr.db-num = p-db-num.  
    end.   
  end.
  
  disconnect dst.

  if not v-multi
  then
  message
    "Перекачка успешно завершена."
    view-as alert-box information .

  return.
end.

procedure cre-activ-code-range :
  define input parameter p-db-num     like dst.code-range.db-num     no-undo.
  define input parameter p-range-type like dst.code-range.range-type no-undo.

  do
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    define variable v-b-code as integer   no-undo .
    define variable crg-cre  as logical   no-undo .

    if p-range-type = {&loc-sc-code}
      or p-range-type = {&loc-ss-code}
      or p-range-type = {&loc-pg-code}
    then do:
      assign
        p-db-num = 0
      .
    end.

    if not can-find( first dst.code-range
                     where dst.code-range.db-num     = p-db-num
                       and dst.code-range.range-type = p-range-type
                     no-lock
                   )
    then do:
      if p-range-type = {&gbl-sc-code}
        or p-range-type = {&gbl-dc-code}
        or p-range-type = {&loc-ss-code}
        or p-range-type = {&gbl-ss-code}
        or p-range-type = {&loc-pg-code}
        or p-range-type = {&gbl-ca-code}
        or p-range-type = {&gbl-fd-code}
      then do:
      /* если нет ни одного диапазона глобальных весовых кодов (а это возможно), то нечего здесь делать */
        return.
      end.
      else do:
      /* а для всех остальных случаях должен быль хотя бы один диапазон */
        return error "Нет ни одного диапазона с типом" + {&space-char} + p-range-type.
      end.
    end.

    find first dst.code-range
      where dst.code-range.db-num     = p-db-num
        and dst.code-range.range-type = p-range-type
        and dst.code-range.stts       = "a":U
      no-error .
    if available dst.code-range then do:
      assign
        dst.code-range.stts = "u":U
      .
    end.
    run get-max-code in this-procedure
      ( input "f-u":U
        ,input p-db-num
        ,input p-range-type
        ,input ?
        ,input ?
        ,input FALSE
        ,output v-b-code
      ).
    if not can-find(first dst.code-range no-lock
      where dst.code-range.db-num     = p-db-num
        and dst.code-range.range-type = p-range-type
        and dst.code-range.stts       = "a":U)
      then do:
      assign
        crg-cre = FALSE
      .
      for each dst.code-range
        where dst.code-range.db-num     = p-db-num
          and dst.code-range.range-type = p-range-type
          and dst.code-range.stts       = "u":U
      by dst.code-range.first-code descending
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        assign
          dst.code-range.stts = "a":U
          crg-cre             = TRUE
        .
        leave .
      end.
      if not crg-cre then do:
        for each dst.code-range
          where dst.code-range.db-num     = p-db-num
            and dst.code-range.range-type = p-range-type
            and dst.code-range.stts       = "f":U
        by dst.code-range.first-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          assign
            dst.code-range.stts = "a":U
          .
          leave .
        end.
      end.
    end.
  end.

end procedure. /* cre-activ-code-range */


/* ========================================================================== */
procedure create-date-on-object :
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    define input parameter p-obj-type   as character    no-undo.
    define input parameter p-obj-code   as integer      no-undo.

    define variable v-last-date   as date         no-undo.
    define variable v-today       as date      no-undo.
    define variable v-time        as integer   no-undo.

    define buffer buf_obj-date      for dst.obj-date.
    define buffer buf_trn-doc       for ub.trn-doc.
    define buffer buf_price-doc     for ub.price-doc.

    run cur-time in this-procedure ( output v-today
                                   , output v-time
                                   ).
    find last buf_trn-doc no-lock
        where buf_trn-doc.obj-type = p-obj-type
          and buf_trn-doc.obj-code = p-obj-code
          and buf_trn-doc.status_  = {&fact}
    use-index fact-order
    no-error.
    find last buf_price-doc
        where buf_price-doc.obj-type = p-obj-type
          and buf_price-doc.obj-code = p-obj-code
          and buf_price-doc.status_  = {&act-overvalue}
    use-index fact-order
    no-error.
    if not available buf_trn-doc
    and not available buf_price-doc
    then do:
        assign
            v-last-date = v-today
        .
    end.
    else do:
      if not available buf_price-doc then do:
        assign
          v-last-date = buf_trn-doc.fact-date
        .
      end.
      else do:
        if not available buf_trn-doc then do:
          assign
            v-last-date = buf_price-doc.fact-date
          .
        end.
        else do:
          assign
            v-last-date = ( if buf_trn-doc.fact-date > buf_price-doc.fact-date
                            then buf_trn-doc.fact-date
                            else buf_price-doc.fact-date
                          )
          .
        end.
      end.
    end.
    create buf_obj-date .
    assign
        buf_obj-date.obj-type  = p-obj-type
        buf_obj-date.obj-code  = p-obj-code
        buf_obj-date.sys-date  = v-last-date
        buf_obj-date.status_   = {&g___new}
        buf_obj-date.open-id   = "rest-rdb":U
        buf_obj-date.open-date = v-today
        buf_obj-date.open-time = v-time
    .
end.
end procedure. /* create-date-on-object */


procedure process-parts :

   define buffer marking-lines for ub.marking-lines.
   define buffer buf_marking-lines for dst.marking-lines.

  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :

    create dst.parts .
    buffer-copy ub.parts to dst.parts .

    define variable v-parts-gds-code as integer   no-undo .
    { gbl/pargocod.i
      recid(ub.parts)
      v-parts-gds-code
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при поиске товара для партии" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) .
    end.
    
    for each marking-lines where marking-lines.gds-code   = v-parts-gds-code
                             and marking-lines.obj-type   = ub.parts.obj-type
                             and marking-lines.obj-code   = ub.parts.obj-code
                             and marking-lines.in-code    = ub.parts.in-code
                             and marking-lines.out-code   = ub.parts.out-code
                             and marking-lines.part-code  = ub.parts.part-code
    no-lock
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ):
       create buf_marking-lines.
       buffer-copy  marking-lines to buf_marking-lines.
       run rest-Onemark(buf_marking-lines.mark).
       
    end.
    /* проверяем, есть ли у партии атрибут партии поставщика */
    find first ub.parts-supp no-lock
      where ub.parts-supp.in-code   = ub.parts.in-code
        and ub.parts-supp.artic     = ub.parts.artic
        and ub.parts-supp.prod-type = ub.parts.prod-type
        and ub.parts-supp.prod-code = ub.parts.prod-code
        and ub.parts-supp.part-code = ub.parts.part-code
      no-error .
    if available ub.parts-supp
    then do:
      /* проверяем, что он еще не был скопирован */
      if not can-find (first dst.parts-supp no-lock
        where dst.parts-supp.in-code   = ub.parts.in-code
          and dst.parts-supp.artic     = ub.parts.artic
          and dst.parts-supp.prod-type = ub.parts.prod-type
          and dst.parts-supp.prod-code = ub.parts.prod-code
          and dst.parts-supp.part-code = ub.parts.part-code)
      then do:
        create dst.parts-supp .
        buffer-copy ub.parts-supp to dst.parts-supp .
      end.
    end.

    if not can-find (first dst.parts-attr no-lock
      where dst.parts-attr.in-code   = ub.parts.in-code
        and dst.parts-attr.gds-code  = v-parts-gds-code
        and dst.parts-attr.part-code = ub.parts.part-code)
    then do:
      find first ub.parts-attr no-lock
        where ub.parts-attr.in-code   = ub.parts.in-code
          and ub.parts-attr.gds-code  = v-parts-gds-code
          and ub.parts-attr.part-code = ub.parts.part-code
        no-error .
      if available ub.parts-attr
      then do:
        create dst.parts-attr .
        buffer-copy ub.parts-attr to dst.parts-attr .
      end.
    end.

    for each ub.parts-add no-lock
      where  ub.parts-add.in-code   = ub.parts.in-code
        and  ub.parts-add.gds-code  = v-parts-gds-code
        and  ub.parts-add.part-code = ub.parts.part-code :
      if not can-find (first dst.parts-add no-lock
      where  dst.parts-add.in-code   = ub.parts.in-code
        and  dst.parts-add.gds-code  = v-parts-gds-code
        and  dst.parts-add.part-code = ub.parts.part-code
        and  dst.parts-add.add-doc-code  = ub.parts-add.add-doc-code
        and  dst.parts-add.add-gds-code  = ub.parts-add.add-gds-code
        and  dst.parts-add.cli-type      = ub.parts-add.cli-type
        and  dst.parts-add.cli-code      = ub.parts-add.cli-code
        and  dst.parts-add.host-code     = ub.parts-add.host-code
        and  dst.parts-add.contract-code = ub.parts-add.contract-code)
        then do:
          create dst.parts-add .
          buffer-copy ub.parts-add to dst.parts-add .
        end.
    end.
  end.

end procedure. /* process-parts */

procedure process-c-parts :
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :

    create dst.c-parts .
    buffer-copy ub.c-parts to dst.c-parts .

    define variable v-parts-gds-code as integer   no-undo .
    { gbl/gds-code.i
      ub.c-parts.artic
      ub.c-parts.prod-type
      ub.c-parts.prod-code
      v-parts-gds-code
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при поиске кода товара по артикулу для таблицы c-parts" skip
        "Указатель на запись c-parts" recid(ub.c-parts) skip
        "Артикул" ub.c-parts.artic ub.c-parts.prod-type ub.c-parts.prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) .
    end.

    if not can-find (first dst.c-parts-attr no-lock
      where dst.c-parts-attr.in-code   = ub.c-parts.in-code
        and dst.c-parts-attr.gds-code  = v-parts-gds-code
        and dst.c-parts-attr.part-code = ub.c-parts.part-code)
    then do:
      find first ub.c-parts-attr no-lock
        where ub.c-parts-attr.in-code   = ub.c-parts.in-code
          and ub.c-parts-attr.gds-code  = v-parts-gds-code
          and ub.c-parts-attr.part-code = ub.c-parts.part-code
        no-error .
      if available ub.c-parts-attr
      then do:
        create dst.c-parts-attr .
        buffer-copy ub.c-parts-attr to dst.c-parts-attr .
      end.
    end.
  end.
end procedure. /* process-c-parts */

procedure rest-OneMark :
   define input parameter p-mark as character no-undo .
   define buffer marking          for  ub.marking.
   define buffer buf_marking      for dst.marking.
   define buffer marking-attr     for  ub.marking-attr.
   define buffer buf_marking-attr for dst.marking-attr.
   
   find first buf_marking where buf_marking.mark eq p-mark
   no-lock no-error.
   if not available buf_marking
   then do:
      find first marking where marking.mark eq p-mark
      no-lock no-error.
      if available  marking
      then do on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ):
         create buf_marking.
         buffer-copy marking to buf_marking.
         if     buf_marking.obj-type eq {&shop}
            and buf_marking.sts eq objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB
         then do:
            find dst.shop where dst.shop.obj-code = buf_marking.obj-code no-lock.
            if not available ub.shop
            then
               buf_marking.sts eq objSrv:Env:Marking:Sts:Mark:OutZone:KeyIntDB.
         end.
         for each marking-attr where marking-attr.mark eq buf_marking.mark
         no-lock
         on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ):
            create buf_marking-attr.
            buffer-copy marking-attr to buf_marking-attr.
         end.
      end.
   end.
end.

procedure rest-Utd :
   define input parameter p-obj-type as character no-undo .
   define input parameter p-obj-code as integer   no-undo .
  
   define buffer utd                         for ub.utd.
   define buffer but_utd                     for dst.utd.
   define buffer utd-attr                    for ub.utd-attr.
   define buffer but_utd-attr                for dst.utd-attr.
   define buffer Utd-err                     for ub.Utd-err.
   define buffer but_Utd-err                 for dst.Utd-err.
   define buffer Utd-lines                   for ub.Utd-lines.
   define buffer but_Utd-lines               for dst.Utd-lines.
   define buffer Utd-marking-lines           for ub.Utd-marking-lines.
   define buffer but_Utd-marking-lines       for dst.Utd-marking-lines.
   define buffer Utd-err-attr                for ub.Utd-err-attr.
   define buffer but_Utd-err-attr            for dst.Utd-err-attr.
   define buffer Utd-lines-attr              for ub.Utd-lines-attr.
   define buffer but_Utd-lines-attr          for dst.Utd-lines-attr.
   define buffer Utd-marking-lines-attr      for ub.Utd-marking-lines-attr.
   define buffer but_Utd-marking-lines-attr  for dst.Utd-marking-lines-attr.
   do
   on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
   on stop   undo, return error substitute( "&1. stop", vss-workfile )
   on endkey undo, return error substitute( "&1. endkey", vss-workfile )
   :

      assign
         ind1 = 0
         fl   = 'trn-doc':U
      .

      if transaction = true
      then do:
         message
            vss-workfile vss-revision vss-description skip
            "При выгрузке УПД активна транзакция" skip
            "Выгрузка невозможна" skip
         view-as alert-box error .
         undo, return error "При выгрузке документов активна транзакция" .
      end.

      for each utd no-lock
         where Utd.obj-type = p-obj-type
           and UTD.obj-code = p-obj-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
         create but_utd.
         buffer-copy utd to but_utd. 
         assign  ind1 = ind1 + 1.
         display ind1 count-str fl with frame ddd view-as dialog-box.
         
         for each utd-attr where  Utd-attr.db-num eq   Utd.db-num
                                 and  Utd-attr.doc-id eq   Utd.doc-id
         no-lock:
            create but_Utd-attr.
            buffer-copy Utd-attr to but_Utd-attr.
         end.
         
         for each utd-err where  Utd-err.db-num eq   Utd.db-num
                            and  Utd-err.doc-id eq   Utd.doc-id
         no-lock:
            create but_Utd-err.
            buffer-copy Utd-err to but_Utd-err.
         end.
         
         for each  Utd-lines where  Utd-lines.db-num eq   Utd.db-num
                               and  Utd-lines.doc-id eq   Utd.doc-id
         no-lock:
            create but_Utd-lines.
            buffer-copy Utd-lines to but_Utd-lines.
         end.
         
         for each  Utd-marking-lines where  Utd-marking-lines.db-num eq   Utd.db-num
                                       and  Utd-marking-lines.doc-id eq   Utd.doc-id
         no-lock:
            create but_Utd-marking-lines.
            buffer-copy Utd-marking-lines to but_Utd-marking-lines.
            run rest-OneMark(but_Utd-marking-lines.mark).
         end.
         
         for each utd-err-attr where  Utd-err-attr.db-num eq   Utd.db-num
                                 and  Utd-err-attr.doc-id eq   Utd.doc-id
         no-lock:
            create but_Utd-err-attr.
            buffer-copy Utd-err-attr to but_Utd-err-attr.
         end.
         
         for each  Utd-lines-attr where  Utd-lines-attr.db-num eq   Utd.db-num
                                    and  Utd-lines-attr.doc-id eq   Utd.doc-id
         no-lock:
            create but_Utd-lines-attr.
            buffer-copy Utd-lines-attr to but_Utd-lines-attr.
         end.
         
         for each  Utd-marking-lines-attr where  Utd-marking-lines-attr.db-num eq   Utd.db-num
                                            and  Utd-marking-lines-attr.doc-id eq   Utd.doc-id
         no-lock:
            create but_Utd-marking-lines-attr.
            buffer-copy Utd-marking-lines-attr to but_Utd-marking-lines-attr.
            
         end.
      end.
   end.
end.


procedure rest-trn-doc :
  define input parameter p-trn_obj-type as character no-undo .
  define input parameter p-trn_obj-code as integer   no-undo .

  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :

    assign
      ind1 = 0
    .
    assign
      fl   = 'trn-doc':U
    .

    if transaction = true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "При выгрузке документов активна транзакция" skip
        "Выгрузка невозможна" skip
        view-as alert-box error .
      undo, return error "При выгрузке документов активна транзакция" .
    end.

    for each ub.trn-doc no-lock
      where ub.trn-doc.obj-type = p-trn_obj-type
        and ub.trn-doc.obj-code = p-trn_obj-code
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    :
      if ( ub.trn-doc.status_ = {&wayb}
           and ub.trn-doc.flag_ = false
         )
         or ( ub.trn-doc.status_ = {&inquiry}
              and ub.trn-doc.flag_ = false
            )
      then do:
        /* в этих статусах в ГБД могут находиться только документы созданные в ГБД и по новостям они еще не отправлялись, */
        /* поэтому их выгружать не надо, иначе это приведет к ошибкам при закрытии                                        */
        next.
      end.
      assign  ind1 = ind1 + 1.
      display ind1 count-str fl with frame ddd view-as dialog-box.
      create dst.trn-doc.
      buffer-copy  ub.trn-doc to dst.trn-doc.

      find first ub.batchprocess no-lock
        where ub.batchprocess.bp_type     = {&btpr-type-trnhd}
          and ub.batchprocess.bp_status   = {&btpr-normal}
          and ub.batchprocess.charkey_one = ub.trn-doc.doc-code
        no-error .
      if available ub.batchprocess
      then do:
        create dst.batchprocess .
        buffer-copy ub.batchprocess to dst.batchprocess .
      end.

      if ub.db.unload-arch = true
      then do:
        /* arh, ahsp */
        find first ub.batchprocess no-lock
          where ub.batchprocess.bp_type     = {&btpr-type-arh}
            and ub.batchprocess.bp_status   = {&btpr-normal}
            and ub.batchprocess.charkey_one = ub.trn-doc.doc-code
          no-error .
        if available ub.batchprocess
        then do:
          create dst.batchprocess .
          buffer-copy ub.batchprocess to dst.batchprocess .
        end.

        find first ub.batchprocess no-lock
          where ub.batchprocess.bp_type     = {&btpr-type-ahsp}
            and ub.batchprocess.bp_status   = {&btpr-normal}
            and ub.batchprocess.charkey_one = ub.trn-doc.doc-code
          no-error .
        if available ub.batchprocess
        then do:
          create dst.batchprocess .
          buffer-copy ub.batchprocess to dst.batchprocess .
        end.
      end.

      if ub.db.unload-aht = true
      then do:
        /* aht */
        find first ub.batchprocess no-lock
          where ub.batchprocess.bp_type     = {&btpr-type-aht}
            and ub.batchprocess.bp_status   = {&btpr-normal}
            and ub.batchprocess.charkey_one = ub.trn-doc.doc-code
          no-error .
        if available ub.batchprocess
        then do:
          create dst.batchprocess .
          buffer-copy ub.batchprocess to dst.batchprocess .
        end.
      end.

      for each ub.doc-line no-lock
          where ub.doc-line.doc-code = ub.trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :

        create dst.doc-line.
        buffer-copy ub.doc-line to dst.doc-line.
      end.
      for each ub.gds-dtl no-lock
          where ub.gds-dtl.doc-code = ub.trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        create dst.gds-dtl.
        buffer-copy  ub.gds-dtl to dst.gds-dtl.
      end.
      for each ub.parts no-lock
        where ub.parts.out-code = ub.trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        run process-parts in this-procedure no-error.
        if error-status :error then do:
          undo, return error substitute( 'rest-rdb.p: &1 &2' , return-value , error-status :get-message(1) ).
        end.

      end.
      for each ub.parts-root no-lock
        where ub.parts-root.doc-code = ub.trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        create dst.parts-root.
        buffer-copy ub.parts-root to dst.parts-root.
      end.
      for each ub.inv-doc no-lock
          where ub.inv-doc.doc-code = ub.trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        create dst.inv-doc.
        buffer-copy ub.inv-doc to dst.inv-doc.
      end.
      for each ub.trn-doc-sum no-lock
          where ub.trn-doc-sum.doc-code = ub.trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        create dst.trn-doc-sum.
        buffer-copy ub.trn-doc-sum to dst.trn-doc-sum.
      end.

      for each ub.inv-line no-lock
          where ub.inv-line.doc-code = ub.trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        create dst.inv-line.
        buffer-copy ub.inv-line to dst.inv-line.
      end.

      for each ub.doc-line-sum no-lock
          where ub.doc-line-sum.doc-code = ub.trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        create dst.doc-line-sum.
        buffer-copy ub.doc-line-sum to dst.doc-line-sum.
      end.

      for each ub.doc-prts no-lock
          where ub.doc-prts.out-code = ub.trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        create dst.doc-prts.
        buffer-copy ub.doc-prts to dst.doc-prts.
      end.
      for each ub.doc-pl no-lock
          where ub.doc-pl.out-code = ub.trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        create dst.doc-pl.
        buffer-copy ub.doc-pl to dst.doc-pl.
      end.
      for each ub.doc-line-attr no-lock
          where ub.doc-line-attr.doc-code = ub.trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        create dst.doc-line-attr.
        buffer-copy ub.doc-line-attr to dst.doc-line-attr.
      end.
      for each ub.doc-attr no-lock
          where ub.doc-attr.doc-code = ub.trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        create dst.doc-attr.
        buffer-copy ub.doc-attr to dst.doc-attr.
      end.

      for each ub.doc-pl-pump no-lock
          where ub.doc-pl-pump.out-code = ub.trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        create dst.doc-pl-pump.
        buffer-copy ub.doc-pl-pump to dst.doc-pl-pump.
      end.
      for each ub.doc-fbr-gds no-lock
          where ub.doc-fbr-gds.out-code = ub.trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        create dst.doc-fbr-gds.
        buffer-copy ub.doc-fbr-gds to dst.doc-fbr-gds.
      end.
      for each ub.arh-trn-doc-contract no-lock
          where ub.arh-trn-doc-contract.doc-code = ub.trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        create dst.arh-trn-doc-contract.
        buffer-copy ub.arh-trn-doc-contract to dst.arh-trn-doc-contract.
      end.
      if ub.trn-doc.whole-send-news > 0 then do:
        for each ub.edi-status no-lock
            where ub.edi-status.tbl-name = {&table_trn-doc}
            and  ub.edi-status.doc-code = ub.trn-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.edi-status.
          buffer-copy ub.edi-status to dst.edi-status no-error.
        end.
        for each ub.edi-status no-lock
            where ub.edi-status.tbl-name = {&table_doc-line}
            and  ub.edi-status.doc-code begins (ub.trn-doc.doc-code + {&delim-par})
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.edi-status.
          buffer-copy ub.edi-status to dst.edi-status no-error.
        end.
      end. /*        if ub.trn-doc.whole-send-news > 0 then do:*/
     if p-unload-history then do:
      for each ub.c-trn-doc no-lock
          where ub.c-trn-doc.doc-code = ub.trn-doc.doc-code
            and ub.c-trn-doc.is-del = false
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        create dst.c-trn-doc.
        buffer-copy ub.c-trn-doc to dst.c-trn-doc.
      end.

      for each ub.c-doc-line no-lock
          where ub.c-doc-line.doc-code = ub.trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        create dst.c-doc-line.
        buffer-copy ub.c-doc-line to dst.c-doc-line.
      end.
      for each ub.c-gds-dtl no-lock
          where ub.c-gds-dtl.doc-code = ub.trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        create dst.c-gds-dtl.
        buffer-copy  ub.c-gds-dtl to dst.c-gds-dtl.
      end.
        for each ub.c-parts no-lock
          where ub.c-parts.out-code = ub.trn-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          run process-c-parts in this-procedure .
        end.

        for each ub.c-parts-root no-lock
          where ub.c-parts-root.doc-code = ub.trn-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.c-parts-root.
          buffer-copy ub.c-parts-root to dst.c-parts-root.
        end.
        for each ub.c-inv-line no-lock
            where ub.c-inv-line.doc-code = ub.trn-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.c-inv-line.
          buffer-copy ub.c-inv-line to dst.c-inv-line.
        end.
        for each ub.c-trn-doc-sum no-lock
            where ub.c-trn-doc-sum.doc-code = ub.trn-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.c-trn-doc-sum.
          buffer-copy ub.c-trn-doc-sum to dst.c-trn-doc-sum.
        end.
        for each ub.c-doc-line-sum no-lock
            where ub.c-doc-line-sum.doc-code = ub.trn-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.c-doc-line-sum.
          buffer-copy ub.c-doc-line-sum to dst.c-doc-line-sum.
        end.

        for each ub.c-doc-prts no-lock
            where ub.c-doc-prts.out-code = ub.trn-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.c-doc-prts.
          buffer-copy ub.c-doc-prts to dst.c-doc-prts.
        end.
        for each ub.c-doc-pl no-lock
            where ub.c-doc-pl.out-code = ub.trn-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.c-doc-pl.
          buffer-copy ub.c-doc-pl to dst.c-doc-pl.
        end.
        for each ub.c-doc-line-attr no-lock
            where ub.c-doc-line-attr.doc-code = ub.trn-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.c-doc-line-attr.
          buffer-copy ub.c-doc-line-attr to dst.c-doc-line-attr.
        end.

        for each ub.c-doc-pl-pump no-lock
            where ub.c-doc-pl-pump.out-code = ub.trn-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.c-doc-pl-pump.
          buffer-copy ub.c-doc-pl-pump to dst.c-doc-pl-pump.
        end.
        for each ub.c-doc-fbr-gds no-lock
            where ub.c-doc-fbr-gds.out-code = ub.trn-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.c-doc-fbr-gds.
          buffer-copy ub.c-doc-fbr-gds to dst.c-doc-fbr-gds.
        end.
      end. /*if p-unload-history then do:*/
    end.
  end.
  return.
end procedure. /* rest-trn-doc */

procedure rest-c-trn-doc :
  define input parameter p-trn_obj-type as character no-undo .
  define input parameter p-trn_obj-code as integer   no-undo .

  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :

    assign ind1 = 0
           fl   = "c-trn-doc is-del".
    for each ub.c-trn-doc no-lock
        where ub.c-trn-doc.obj-type = p-trn_obj-type
          and ub.c-trn-doc.obj-code = p-trn_obj-code
          and ub.c-trn-doc.is-del   = true

    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    :
      assign  ind1 = ind1 + 1.
      display ind1 count-str fl with frame ddd view-as dialog-box.
      create dst.c-trn-doc.
      buffer-copy ub.c-trn-doc to dst.c-trn-doc.
      for each ub.c-doc-line no-lock
          where ub.c-doc-line.doc-code = ub.c-trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        create dst.c-doc-line.
        buffer-copy ub.c-doc-line to dst.c-doc-line.
      end.
      for each ub.c-gds-dtl no-lock
          where ub.c-gds-dtl.doc-code = ub.c-trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        create dst.c-gds-dtl.
        buffer-copy  ub.c-gds-dtl to dst.c-gds-dtl.
      end.

      for each ub.c-parts no-lock
        where ub.c-parts.out-code = ub.c-trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        run process-c-parts in this-procedure .
      end.

      for each ub.c-parts-root no-lock
        where ub.c-parts-root.doc-code = ub.c-trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        create dst.c-parts-root.
        buffer-copy ub.c-parts-root to dst.c-parts-root.
      end.
      for each ub.c-inv-line no-lock
          where ub.c-inv-line.doc-code = ub.c-trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        create dst.c-inv-line.
        buffer-copy ub.c-inv-line to dst.c-inv-line.
      end.
      for each ub.c-trn-doc-sum no-lock
          where ub.c-trn-doc-sum.doc-code = ub.c-trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        create dst.c-trn-doc-sum.
        buffer-copy ub.c-trn-doc-sum to dst.c-trn-doc-sum.
      end.
      for each ub.c-doc-line-sum no-lock
          where ub.c-doc-line-sum.doc-code = ub.c-trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        create dst.c-doc-line-sum.
        buffer-copy ub.c-doc-line-sum to dst.c-doc-line-sum.
      end.

      for each ub.c-doc-prts no-lock
          where ub.c-doc-prts.out-code = ub.c-trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        create dst.c-doc-prts.
        buffer-copy ub.c-doc-prts to dst.c-doc-prts.
      end.
      for each ub.c-doc-pl no-lock
          where ub.c-doc-pl.out-code = ub.c-trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        create dst.c-doc-pl.
        buffer-copy ub.c-doc-pl to dst.c-doc-pl.
      end.
      for each ub.c-doc-line-attr no-lock
          where ub.c-doc-line-attr.doc-code = ub.c-trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        create dst.c-doc-line-attr.
        buffer-copy ub.c-doc-line-attr to dst.c-doc-line-attr.
      end.

      for each ub.c-doc-pl-pump no-lock
          where ub.c-doc-pl-pump.out-code = ub.c-trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        create dst.c-doc-pl-pump.
        buffer-copy ub.c-doc-pl-pump to dst.c-doc-pl-pump.
      end.
      for each ub.c-doc-fbr-gds no-lock
          where ub.c-doc-fbr-gds.out-code = ub.c-trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        create dst.c-doc-fbr-gds.
        buffer-copy ub.c-doc-fbr-gds to dst.c-doc-fbr-gds.
      end.
    end.
  end.
  return.
end procedure. /* rest-c-trn-doc */

procedure rest-inkas :
  define input parameter p-inkas_obj-type as character no-undo .
  define input parameter p-inkas_obj-code as integer   no-undo .

  do
  on error  undo, return error substitute( "&1 (rest-inkas). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo, return error substitute( "&1 (rest-inkas). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (rest-inkas). endkey", vss-workfile )
  :
    assign ind1 = 0
           fl   = "inkas".
    for each ub.inkas no-lock
        where ub.inkas.obj-type = p-inkas_obj-type
          and ub.inkas.obj-code = p-inkas_obj-code
    on error  undo, return error substitute( "&1 (rest-inkas/inkas). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo, return error substitute( "&1 (rest-inkas/inkas). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (rest-inkas/inkas). endkey", vss-workfile )
    :
      assign  ind1 = ind1 + 1.
      display ind1 count-str fl with frame ddd view-as dialog-box.
      create dst.inkas.
      buffer-copy  ub.inkas to dst.inkas.
      for each ub.inkas-pay no-lock
          where ub.inkas-pay.inkas-code = ub.inkas.inkas-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        create dst.inkas-pay.
        buffer-copy  ub.inkas-pay to dst.inkas-pay.
      end.
      for each ub.inkas-pay-desk no-lock
          where ub.inkas-pay-desk.inkas-code = ub.inkas.inkas-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        create dst.inkas-pay-desk.
        buffer-copy  ub.inkas-pay-desk to dst.inkas-pay-desk.
      end.
      for each ub.inkas-pay-wth no-lock
          where ub.inkas-pay-wth.inkas-code = ub.inkas.inkas-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        create dst.inkas-pay-wth.
        buffer-copy  ub.inkas-pay-wth to dst.inkas-pay-wth.
      end.

      for each ub.sale-doc no-lock
          where ub.sale-doc.inkas-code = ub.inkas.inkas-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        create dst.sale-doc.
        buffer-copy  ub.sale-doc to dst.sale-doc.
      end.
      if p-unload-history then do:
        for each ub.c-sale-doc no-lock
            where ub.c-sale-doc.inkas-code = ub.inkas.inkas-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.c-sale-doc.
          buffer-copy  ub.c-sale-doc to dst.c-sale-doc.
        end.

        for each ub.c-inkas no-lock
            where ub.c-inkas.inkas-code = ub.inkas.inkas-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          if ub.c-inkas.is-del = yes then do:
            return error substitute( "К существующей продаже &1 есть история его удаления", ub.c-inkas.inkas-code ) .
          end.
          create dst.c-inkas.
          buffer-copy ub.c-inkas to dst.c-inkas.
        end.
        for each ub.c-inkas-pay no-lock
            where ub.c-inkas-pay.inkas-code = ub.inkas.inkas-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.c-inkas-pay.
          buffer-copy ub.c-inkas-pay to dst.c-inkas-pay.
        end.
        for each ub.c-inkas-pay-desk no-lock
            where ub.c-inkas-pay-desk.inkas-code = ub.inkas.inkas-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.c-inkas-pay-desk.
          buffer-copy  ub.c-inkas-pay-desk to dst.c-inkas-pay-desk.
        end.
        for each ub.c-inkas-pay-wth no-lock
            where ub.c-inkas-pay-wth.inkas-code = ub.inkas.inkas-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.c-inkas-pay-wth.
          buffer-copy  ub.c-inkas-pay-wth to dst.c-inkas-pay-wth.
        end.



        /* выгрузим историю по чекам которые привязаны к данной продаже */
        /* историю по удаленным чекам будем выгружать отдельно */
        for each ub.c-chk-doc no-lock
            where ub.c-chk-doc.out-code = ub.inkas.inkas-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.c-chk-doc.
          buffer-copy  ub.c-chk-doc to dst.c-chk-doc.
        end.
        for each ub.c-chk-gds no-lock
            where ub.c-chk-gds.out-code = ub.inkas.inkas-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.c-chk-gds.
          buffer-copy  ub.c-chk-gds to dst.c-chk-gds.
        end.
        for each ub.c-chk-pay no-lock
            where ub.c-chk-pay.out-code = ub.inkas.inkas-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.c-chk-pay.
          buffer-copy  ub.c-chk-pay to dst.c-chk-pay.
        end.
        for each ub.c-chk-discnt no-lock
            where ub.c-chk-discnt.out-code = ub.inkas.inkas-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.c-chk-discnt.
          buffer-copy  ub.c-chk-discnt to dst.c-chk-discnt.
        end.
        for each ub.c-chk-doc-attr no-lock
            where ub.c-chk-doc-attr.out-code = ub.inkas.inkas-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.c-chk-doc-attr.
          buffer-copy  ub.c-chk-doc-attr to dst.c-chk-doc-attr.
        end.
      end. /*if p-unload-history then do:*/
    end.

  end.
  return.
end procedure. /* rest-inkas */

procedure rest-c-inkas :
  define input parameter p-inkas_obj-type as character no-undo .
  define input parameter p-inkas_obj-code as integer   no-undo .

  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :

    assign ind1 = 0
           fl   = "c-inkas".
    for each ub.c-inkas no-lock
        where ub.c-inkas.obj-type = p-inkas_obj-type
          and ub.c-inkas.obj-code = p-inkas_obj-code
          and ub.c-inkas.is-del = yes
    break
    by
    ub.c-inkas.inkas-code
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    :
      assign  ind1 = ind1 + 1.
      display ind1 count-str fl with frame ddd view-as dialog-box.
      create dst.c-inkas.
      buffer-copy ub.c-inkas to dst.c-inkas.
      if first-of(ub.c-inkas.inkas-code) then do:
        for each ub.c-inkas-pay no-lock
            where ub.c-inkas-pay.inkas-code = ub.c-inkas.inkas-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.c-inkas-pay.
          buffer-copy ub.c-inkas-pay to dst.c-inkas-pay.
        end.
        for each ub.c-inkas-pay-desk no-lock
            where ub.c-inkas-pay-desk.inkas-code = ub.c-inkas.inkas-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.c-inkas-pay-desk.
          buffer-copy ub.c-inkas-pay-desk to dst.c-inkas-pay-desk.
        end.
        for each ub.c-inkas-pay-wth no-lock
            where ub.c-inkas-pay-wth.inkas-code = ub.c-inkas.inkas-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.c-inkas-pay-wth.
          buffer-copy ub.c-inkas-pay-wth to dst.c-inkas-pay-wth.
        end.

        for each ub.c-sale-doc no-lock
            where ub.c-sale-doc.inkas-code = ub.c-inkas.inkas-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.c-sale-doc.
          buffer-copy  ub.c-sale-doc to dst.c-sale-doc.
        end.
      end.
    end.
  end.
  return.
end procedure. /* rest-c-inkas */


procedure rest-wth-doc :
  define input parameter p-wth-doc_obj-type as character no-undo .
  define input parameter p-wth-doc_obj-code as integer   no-undo .


  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
      assign ind1 = 0
             fl   = "wth-doc".
      for each ub.wth-doc no-lock
          where ub.wth-doc.obj-type = p-wth-doc_obj-type
            and ub.wth-doc.obj-code = p-wth-doc_obj-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        assign  ind1 = ind1 + 1.
        display ind1 count-str fl with frame ddd view-as dialog-box.
        create dst.wth-doc.
        buffer-copy  ub.wth-doc to dst.wth-doc.
        for each ub.wth-line no-lock
            where ub.wth-line.doc-code = ub.wth-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.wth-line.
          buffer-copy ub.wth-line to dst.wth-line.
        end.
        for each ub.wth-dtl no-lock
            where ub.wth-dtl.doc-code = ub.wth-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.wth-dtl.
          buffer-copy  ub.wth-dtl to dst.wth-dtl.
        end.
        for each ub.wth-doc-attr no-lock
            where ub.wth-doc-attr.doc-code = ub.wth-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.wth-doc-attr.
          buffer-copy  ub.wth-doc-attr to dst.wth-doc-attr.
        end.

        if ub.wth-doc.auto-fill = yes then do:
          if p-unload-history then do:
            for each ub.c-chk-doc no-lock
                where ub.c-chk-doc.out-code = ub.wth-doc.doc-code
            on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
            :
              create dst.c-chk-doc.
              buffer-copy  ub.c-chk-doc to dst.c-chk-doc.
            end.
            for each ub.c-chk-pay no-lock
                where ub.c-chk-pay.out-code = ub.wth-doc.doc-code
            on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
            :
              create dst.c-chk-pay.
              buffer-copy  ub.c-chk-pay to dst.c-chk-pay.
            end.
          end. /*if p-unload-history then do:*/
        end.
      end.

  end.

end procedure. /* rest-wth-doc */

procedure rest-c-wth-doc :
  define input parameter p-wthd_obj-type as character no-undo .
  define input parameter p-wthd_obj-code as integer   no-undo .

  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :

    assign ind1 = 0
           fl   = "c-wth-doc".
    for each ub.c-wth-doc no-lock
        where ub.c-wth-doc.obj-type = p-wthd_obj-type
          and ub.c-wth-doc.obj-code = p-wthd_obj-code
          and ub.c-wth-doc.is-del = yes
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    :
      assign  ind1 = ind1 + 1.
      display ind1 count-str fl with frame ddd view-as dialog-box.
      create dst.c-wth-doc.
      buffer-copy ub.c-wth-doc to dst.c-wth-doc.
      for each ub.c-wth-line no-lock
          where ub.c-wth-line.doc-code = ub.c-wth-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        create dst.c-wth-line.
        buffer-copy ub.c-wth-line to dst.c-wth-line.
      end.
      for each ub.c-wth-dtl no-lock
          where ub.c-wth-dtl.doc-code = ub.c-wth-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        create dst.c-wth-dtl.
        buffer-copy ub.c-wth-dtl to dst.c-wth-dtl.
      end.
    end.
  end.
  return.
end procedure. /* rest-c-wth-doc */

procedure rest-fin-doc :
  define input parameter p-fin-doc_obj-type as character no-undo .
  define input parameter p-fin-doc_obj-code as integer   no-undo .


  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
      assign ind1 = 0
             fl   = "fin-doc".
      for each ub.fin-doc no-lock
          where ub.fin-doc.obj-type = p-fin-doc_obj-type
            and ub.fin-doc.obj-code = p-fin-doc_obj-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        assign  ind1 = ind1 + 1.
        display ind1 count-str fl with frame ddd view-as dialog-box.
        create dst.fin-doc.
        buffer-copy  ub.fin-doc to dst.fin-doc.
        for each ub.fin-doc-attr no-lock
            where ub.fin-doc-attr.host-code     = ub.fin-doc.host-code
              and ub.fin-doc-attr.fin-doc-code  = ub.fin-doc.fin-doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.fin-doc-attr.
          buffer-copy ub.fin-doc-attr to dst.fin-doc-attr.
        end.
        for each ub.fin-doc-cor-acc-lk no-lock
            where ub.fin-doc-cor-acc-lk.host-code     = ub.fin-doc.host-code
              and ub.fin-doc-cor-acc-lk.fin-doc-code  = ub.fin-doc.fin-doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.fin-doc-cor-acc-lk.
          buffer-copy ub.fin-doc-cor-acc-lk to dst.fin-doc-cor-acc-lk.
          for each ub.fin-doc-cor-acc-lk-attr no-lock
              where ub.fin-doc-cor-acc-lk-attr.fin-code = ub.fin-doc-cor-acc-lk.fin-code
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
          :
            create dst.fin-doc-cor-acc-lk-attr.
            buffer-copy ub.fin-doc-cor-acc-lk-attr to dst.fin-doc-cor-acc-lk-attr.
          end.
        end.
        for each ub.fin-doc-schet-lk no-lock
            where ub.fin-doc-schet-lk.host-code     = ub.fin-doc.host-code
              and ub.fin-doc-schet-lk.fin-doc-code  = ub.fin-doc.fin-doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.fin-doc-schet-lk.
          buffer-copy ub.fin-doc-schet-lk to dst.fin-doc-schet-lk.
          for each ub.fin-doc-schet-lk-attr no-lock
              where ub.fin-doc-schet-lk-attr.code-schet = ub.fin-doc-schet-lk.code-schet
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
          :
            create dst.fin-doc-schet-lk-attr.
            buffer-copy ub.fin-doc-schet-lk-attr to dst.fin-doc-schet-lk-attr.
          end.
        end.
        for each ub.fin-doc-tax no-lock
            where ub.fin-doc-tax.host-code    = ub.fin-doc.host-code
              and ub.fin-doc-tax.fin-doc-code = ub.fin-doc.fin-doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.fin-doc-tax.
          buffer-copy ub.fin-doc-tax to dst.fin-doc-tax.
          for each ub.fin-doc-tax-attr no-lock
              where ub.fin-doc-tax-attr.fin-doc-code = ub.fin-doc-tax.fin-doc-code
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
          :
            create dst.fin-doc-tax-attr.
            buffer-copy ub.fin-doc-tax-attr to dst.fin-doc-tax-attr.
          end.
        end.
      end.
      for each ub.fin-doc-obj no-lock
          where ub.fin-doc-obj.obj-type = p-fin-doc_obj-type
            and ub.fin-doc-obj.obj-code = p-fin-doc_obj-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        assign  ind1 = ind1 + 1.
        display ind1 count-str fl with frame ddd view-as dialog-box.
        create dst.fin-doc-obj.
        buffer-copy  ub.fin-doc-obj to dst.fin-doc-obj.
        for each ub.fin-doc-obj-attr no-lock
            where ub.fin-doc-obj-attr.host-code     = ub.fin-doc-obj.host-code
              and ub.fin-doc-obj-attr.fin-doc-code  = ub.fin-doc-obj.fin-doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.fin-doc-obj-attr.
          buffer-copy ub.fin-doc-obj-attr to dst.fin-doc-obj-attr.
        end.
      end.
    /*  архивы  */
/*      for each ub.arh-fin-doc-schet-obj no-lock                                                                                                                */
/*          where ub.arh-fin-doc-schet-obj.obj-type = p-fin-doc_obj-type                                                                                         */
/*            and ub.arh-fin-doc-schet-obj.obj-code = p-fin-doc_obj-code                                                                                         */
/*      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )*/
/*      :                                                                                                                                                        */
/*        assign  ind1 = ind1 + 1.                                                                                                                               */
/*        display ind1 count-str fl with frame ddd view-as dialog-box.                                                                                           */
/*        create dst.arh-fin-doc-schet-obj.                                                                                                                      */
/*        buffer-copy  ub.arh-fin-doc-schet-obj to dst.arh-fin-doc-schet-obj.                                                                                    */
/*      end.                                                                                                                                                     */
/*      for each ub.arh-fin-doc-schet-obj-attr no-lock                                                                                                           */
/*          where ub.arh-fin-doc-schet-obj-attr.obj-type = p-fin-doc_obj-type                                                                                    */
/*            and ub.arh-fin-doc-schet-obj-attr.obj-code = p-fin-doc_obj-code                                                                                    */
/*      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )*/
/*      :                                                                                                                                                        */
/*        assign  ind1 = ind1 + 1.                                                                                                                               */
/*        display ind1 count-str fl with frame ddd view-as dialog-box.                                                                                           */
/*        create dst.arh-fin-doc-schet-obj-attr.                                                                                                                 */
/*        buffer-copy  ub.arh-fin-doc-schet-obj-attr to dst.arh-fin-doc-schet-obj-attr.                                                                          */
/*      end.                                                                                                                                                     */
/*                                                                                                                                                               */
/*      for each ub.arh-fin-doc-schet-nal-obj no-lock                                                                                                            */
/*          where ub.arh-fin-doc-schet-nal-obj.obj-type = p-fin-doc_obj-type                                                                                     */
/*            and ub.arh-fin-doc-schet-nal-obj.obj-code = p-fin-doc_obj-code                                                                                     */
/*      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )*/
/*      :                                                                                                                                                        */
/*        assign  ind1 = ind1 + 1.                                                                                                                               */
/*        display ind1 count-str fl with frame ddd view-as dialog-box.                                                                                           */
/*        create dst.arh-fin-doc-schet-nal-obj.                                                                                                                  */
/*        buffer-copy  ub.arh-fin-doc-schet-nal-obj to dst.arh-fin-doc-schet-nal-obj.                                                                            */
/*      end.                                                                                                                                                     */

  end.

end procedure.  /*  rest-fin-doc  */

procedure rest-c-fin-doc :
  define input parameter p-find_obj-type as character no-undo .
  define input parameter p-find_obj-code as integer   no-undo .

  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :

    assign ind1 = 0
           fl   = "c-fin-doc".
    for each ub.c-fin-doc no-lock
        where ub.c-fin-doc.obj-type = p-find_obj-type
          and ub.c-fin-doc.obj-code = p-find_obj-code
          and ub.c-fin-doc.is-del = yes
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    :
      assign  ind1 = ind1 + 1.
      display ind1 count-str fl with frame ddd view-as dialog-box.
      create dst.c-fin-doc.
      buffer-copy ub.c-fin-doc to dst.c-fin-doc.
      for each ub.c-fin-doc-attr no-lock
          where ub.c-fin-doc-attr.host-code     = ub.c-fin-doc.host-code
            and ub.c-fin-doc-attr.fin-doc-code  = ub.c-fin-doc.fin-doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        create dst.c-fin-doc-attr.
        buffer-copy ub.c-fin-doc-attr to dst.c-fin-doc-attr.
      end.
      for each ub.c-fin-doc-tax no-lock
          where ub.c-fin-doc-tax.host-code     = ub.c-fin-doc.host-code
            and ub.c-fin-doc-tax.fin-doc-code  = ub.c-fin-doc.fin-doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        create dst.c-fin-doc-tax.
        buffer-copy ub.c-fin-doc-tax to dst.c-fin-doc-tax.
      end.
    end.
  end.
end procedure.    /*  rest-c-fin-doc  */

procedure rest-wth-doc-full :
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
      assign ind1 = 0
             fl   = "wth-doc".
    for each ub.wth-doc no-lock
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    :
      if can-find(first ub.wth-parts where ub.wth-parts.out-code = ub.wth-doc.doc-code) or
      can-find(first ub.clients where ub.clients.db-num = p-db-num
                                  and ub.clients.obj-type = ub.wth-doc.obj-type
                                  and ub.clients.obj-code = ub.wth-doc.obj-code
               )
      then do:
        assign  ind1 = ind1 + 1.
        display ind1 count-str fl with frame ddd view-as dialog-box.
        create dst.wth-doc.
        buffer-copy  ub.wth-doc to dst.wth-doc.
        for each ub.wth-line no-lock
            where ub.wth-line.doc-code = ub.wth-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.wth-line.
          buffer-copy ub.wth-line to dst.wth-line.
        end.
        for each ub.wth-dtl no-lock
            where ub.wth-dtl.doc-code = ub.wth-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.wth-dtl.
          buffer-copy  ub.wth-dtl to dst.wth-dtl.
        end.
        for each ub.wth-doc-attr no-lock
            where ub.wth-doc-attr.doc-code = ub.wth-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          create dst.wth-doc-attr.
          buffer-copy  ub.wth-doc-attr to dst.wth-doc-attr.
        end.

        if ub.wth-doc.auto-fill = yes then do:
          if p-unload-history then do:
            for each ub.c-chk-doc no-lock
                where ub.c-chk-doc.out-code = ub.wth-doc.doc-code
            on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
            :
              create dst.c-chk-doc.
              buffer-copy  ub.c-chk-doc to dst.c-chk-doc.
            end.
            for each ub.c-chk-pay no-lock
                where ub.c-chk-pay.out-code = ub.wth-doc.doc-code
            on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
            :
              create dst.c-chk-pay.
              buffer-copy  ub.c-chk-pay to dst.c-chk-pay.
            end.
          end. /*if p-unload-history then do:*/
        end.
      end.
    end. /*for each wth-doc*/
  end.
end.   /*rest-wth-doc-full*/
procedure rest-c-wth-doc-full :
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
      assign ind1 = 0
             fl   = "c-wth-doc".
    for each ub.c-wth-doc no-lock  where
       ub.c-wth-doc.is-del = yes
    break by
    ub.c-wth-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    :
      if first-of(ub.c-wth-doc.doc-code) then do:
        if can-find(first ub.c-wth-parts where ub.c-wth-parts.out-code = ub.c-wth-doc.doc-code) or
        can-find(first ub.clients where ub.clients.db-num = p-db-num
                                    and ub.clients.obj-type = ub.c-wth-doc.obj-type
                                    and ub.clients.obj-code = ub.c-wth-doc.obj-code
                )
        then do:
          assign  ind1 = ind1 + 1.
          display ind1 count-str fl with frame ddd view-as dialog-box.
          create dst.c-wth-doc.
          buffer-copy  ub.c-wth-doc to dst.c-wth-doc.
          for each ub.c-wth-line no-lock
              where ub.c-wth-line.doc-code = ub.c-wth-doc.doc-code
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
          :
            create dst.c-wth-line.
            buffer-copy ub.c-wth-line to dst.c-wth-line.
          end.

          for each ub.c-wth-dtl no-lock
              where ub.c-wth-dtl.doc-code = ub.c-wth-doc.doc-code
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
          :
            create dst.c-wth-dtl.
            buffer-copy  ub.c-wth-dtl to dst.c-wth-dtl.
          end.
        end.
      end.
    end. /*for each wth-doc*/
  end.
end.   /*rest-c-wth-doc-full*/
procedure rest-arh-wth-tot :
  define input parameter p-wth-arh_obj-type as character no-undo .
  define input parameter p-wth-arh_obj-code as integer   no-undo .

  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
      assign ind1 = 0
             fl   = "arh-wth-tot".
      for each ub.arh-wth-tot no-lock
          where ub.arh-wth-tot.obj-type = p-wth-arh_obj-type
            and ub.arh-wth-tot.obj-code = p-wth-arh_obj-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        assign  ind1 = ind1 + 1.
        display ind1 count-str fl with frame ddd view-as dialog-box.
        create dst.arh-wth-tot.
        buffer-copy  ub.arh-wth-tot to dst.arh-wth-tot.
      end.

  end.

end procedure. /* rest-arh-wth-tot */
procedure rest-arh-wth-w-p :
  define input parameter p-wth-arh_obj-type as character no-undo .
  define input parameter p-wth-arh_obj-code as integer   no-undo .

  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
      assign ind1 = 0
             fl   = "arh-wth-w-p".
      for each ub.arh-wth-w-p no-lock
          where ub.arh-wth-w-p.obj-type = p-wth-arh_obj-type
            and ub.arh-wth-w-p.obj-code = p-wth-arh_obj-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        assign  ind1 = ind1 + 1.
        display ind1 count-str fl with frame ddd view-as dialog-box.
        create dst.arh-wth-w-p.
        buffer-copy  ub.arh-wth-w-p to dst.arh-wth-w-p.
      end.

  end.

end procedure. /* rest-arh-wth-w-p */


procedure rest-price-doc :
  define input parameter p-price-doc_obj-type as character no-undo .
  define input parameter p-price-doc_obj-code as integer   no-undo .

  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :

    assign
      ind1 = 0
      fl   = 'price-doc':U
    .
    for each ub.price-doc no-lock
      where ub.price-doc.obj-type = p-price-doc_obj-type
        and ub.price-doc.obj-code = p-price-doc_obj-code
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    :
      find first ub.batchprocess no-lock
        where ub.batchprocess.bp_type     = {&btpr-type-prc}
          and ub.batchprocess.bp_status   = {&btpr-normal}
          and ub.batchprocess.charkey_one = ub.price-doc.doc-num
        no-error .
      if available ub.batchprocess
      then do:
        create dst.batchprocess .
        buffer-copy ub.batchprocess to dst.batchprocess .
      end.

      if ub.db.unload-arch = true
      then do:
        /* arh, ahsp */
        find first ub.batchprocess no-lock
          where ub.batchprocess.bp_type     = {&btpr-type-arh}
            and ub.batchprocess.bp_status   = {&btpr-normal}
            and ub.batchprocess.charkey_one = ub.price-doc.doc-num
          no-error .
        if available ub.batchprocess
        then do:
          create dst.batchprocess .
          buffer-copy ub.batchprocess to dst.batchprocess .
        end.

        find first ub.batchprocess no-lock
          where ub.BatchProcess.bp_type     = {&btpr-type-ahsp}
            and ub.BatchProcess.bp_status   = {&btpr-normal}
            and ub.batchprocess.charkey_one = ub.price-doc.doc-num
          no-error .
        if available ub.batchprocess
        then do:
          create dst.batchprocess .
          buffer-copy ub.batchprocess to dst.batchprocess .
        end.
      end.

      if ub.db.unload-aht = true
      then do:
        find first ub.batchprocess no-lock
          where ub.batchprocess.bp_type     = {&btpr-type-aht}
            and ub.batchprocess.bp_status   = {&btpr-normal}
            and ub.batchprocess.charkey_one = ub.price-doc.doc-num
          no-error .
        if available ub.batchprocess
        then do:
          create dst.batchprocess .
          buffer-copy ub.batchprocess to dst.batchprocess .
        end.
      end.

      assign  ind1 = ind1 + 1.
      display ind1 count-str fl with frame ddd view-as dialog-box.

      for each ub.price-list no-lock
        where ub.price-list.doc-num = ub.price-doc.doc-num
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        create dst.price-list.
        buffer-copy ub.price-list to dst.price-list.
      end.

      for each ub.price-list-attr no-lock
        where ub.price-list-attr.doc-num = ub.price-doc.doc-num
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        create dst.price-list-attr.
        buffer-copy ub.price-list-attr to dst.price-list-attr.
      end.


      for each ub.parts no-lock
        where ub.parts.out-code = ub.price-doc.doc-num
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        run process-parts in this-procedure .
      end.

      create dst.price-doc.
      buffer-copy  ub.price-doc to dst.price-doc.
    end.
  end.
  return.
end procedure. /* rest-price-doc */

procedure rest-chk :
  define input parameter p-chk_obj-type as character no-undo .
  define input parameter p-chk_obj-code as integer   no-undo .

  define buffer buf_cash-desk for ub.caSH-DESK.
  define variable V-IS-magia as logical no-undo .

  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    assign ind1 = 0
           fl   = "chk-doc".
    find first buf_cash-desk no-lock where
              buf_cash-desk.obj-code = p-chk_obj-code
          AND buf_cash-desk.db-num = p-db-num
          AND buf_cash-desk.pos-type = {&cd-type-magia-XML} no-error .
    if available buf_cash-desk then do:
      assign
      v-is-magia = yes
      .
    end.
    for each ub.chk-doc no-lock
        where ub.chk-doc.obj-type = p-chk_obj-type
          and ub.chk-doc.obj-code = p-chk_obj-code
        use-index chk-out
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    :
      assign  ind1 = ind1 + 1.
      display ind1 count-str fl with frame ddd view-as dialog-box.
      if v-is-magia then do:
        find first temp-cash-desk where
                temp-cash-desk.cash-num = ub.chk-doc.pay-desk no-error.
        if not available temp-cash-desk then do:
          create temp-cash-desk.
          assign
          temp-cash-desk.cash-num = ub.chk-doc.pay-desk
          temp-cash-desk.last-date = ub.chk-doc.chk-date
          temp-cash-desk.last-time = ub.chk-doc.chk-time
          .
        end.
        else do:
          assign
          temp-cash-desk.last-time     = if temp-cash-desk.last-date < ub.chk-doc.chk-date
                                          or (temp-cash-desk.last-date = ub.chk-doc.chk-date
                                              and
                                              temp-cash-desk.last-time < ub.chk-doc.chk-time)
                                          then ub.chk-doc.chk-time
                                          else temp-cash-desk.last-time
          temp-cash-desk.last-date     = (if temp-cash-desk.last-date < ub.chk-doc.chk-date
                                          then ub.chk-doc.chk-date
                                          else temp-cash-desk.last-date)
          .
        end.
      end.
      for each ub.marking-chk no-lock
          where ub.marking-chk.doc-code = ub.chk-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        create dst.marking-chk.
        buffer-copy  ub.marking-chk to dst.marking-chk.
      end.
      for each ub.chk-gds no-lock
          where ub.chk-gds.doc-code = ub.chk-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        create dst.chk-gds.
        buffer-copy  ub.chk-gds to dst.chk-gds.
      end.
      for each ub.chk-pay no-lock
          where ub.chk-pay.doc-code = ub.chk-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        create dst.chk-pay.
        buffer-copy  ub.chk-pay to dst.chk-pay.
      end.
      for each ub.chk-discnt no-lock
          where ub.chk-discnt.doc-code = ub.chk-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        create dst.chk-discnt.
        buffer-copy  ub.chk-discnt to dst.chk-discnt.
      end.
      /*   это рассчитываемая таблица не будем выгружать - если надо будет рассчитается снова
      for each ub.chk-gds-pay no-lock
          where ub.chk-gds-pay.doc-code = ub.chk-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        create dst.chk-gds-pay.
        buffer-copy  ub.chk-gds-pay to dst.chk-gds-pay.
      end.
      */
      for each ub.chk-doc-attr no-lock
          where ub.chk-doc-attr.doc-code = ub.chk-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        create dst.chk-doc-attr.
        buffer-copy  ub.chk-doc-attr to dst.chk-doc-attr.
      end.

      create dst.chk-doc.
      buffer-copy  ub.chk-doc to dst.chk-doc.
    end.
    if v-is-magia then do:
      for each temp-cash-desk:
        find first buf_cash-desk no-lock where
                 buf_cash-desk.db-num = p-db-num
             AND buf_cash-desk.obj-code = p-chk_obj-code
             AND buf_cash-desk.pos-type = {&cd-type-magia-XML}
             AND buf_cash-desk.cash-num = temp-cash-desk.cash-num no-error .
        if available buf_cash-desk then
        run cd-attr-write in this-procedure (
                                                input p-db-num
                                              ,input p-chk_obj-code
                                              ,input {&cd-type-magia-xml}
                                              ,input temp-cash-desk.cash-num
                                              ,input {&cda-magia-xml_operative}
                                              ,input {&cda-magia-xml_operative_last-check-date-time}
                                              ,input (cd-attr-CD-DatetoString (temp-cash-desk.last-date) + {&space-char}  +  string(temp-cash-desk.last-time, "HH:MM:SS":U)
                                                    )
                                              ,input ? /*p-attr-date*/
                                              ,input 0.0 /*p-attr-decimal*/
                                              ,input 0 /*p-attr-integer*/
                                              ,input no /*p-attr-logical*/
                                              ) no-error.
      end.
    end.

    if p-unload-history then do:

      /* добавим сюда выгрузку истории УДАЛЕННЫХ чеков - история ПО ИЗМЕННЕЫМ ЧЕКАМ выгружается с продажей!! - по индексу sale */
      assign ind1 = 0
            fl   = "c-chk-doc".
      for each ub.c-chk-doc no-lock
          where ub.c-chk-doc.obj-type = p-chk_obj-type
            and ub.c-chk-doc.obj-code = p-chk_obj-code
            and ub.c-chk-doc.is-del = yes
          use-index idel
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        if ub.c-chk-doc.out-code <> ? then next.
        assign  ind1 = ind1 + 1.
        display ind1 count-str fl with frame ddd view-as dialog-box.
        for each ub.c-chk-gds no-lock
            where ub.c-chk-gds.doc-code = ub.c-chk-doc.doc-code
              and ub.c-chk-gds.chip-num = ub.c-chk-doc.chip-num
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          if ub.c-chk-gds.out-code <> ? then next.
          create dst.c-chk-gds.
          buffer-copy  ub.c-chk-gds to dst.c-chk-gds.
        end.
        for each ub.c-chk-pay no-lock
            where ub.c-chk-pay.doc-code = ub.c-chk-doc.doc-code
              and ub.c-chk-pay.chip-num = ub.c-chk-doc.chip-num
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          if ub.c-chk-pay.out-code <> ? then next.
          create dst.c-chk-pay.
          buffer-copy  ub.c-chk-pay to dst.c-chk-pay.
        end.
        for each ub.c-chk-discnt no-lock
            where ub.c-chk-discnt.doc-code = ub.c-chk-doc.doc-code
              and ub.c-chk-discnt.chip-num = ub.c-chk-doc.chip-num
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          if ub.c-chk-discnt.out-code <> ? then next.
          create dst.c-chk-discnt.
          buffer-copy  ub.c-chk-discnt to dst.c-chk-discnt.
        end.
        for each ub.c-chk-doc-attr no-lock
            where ub.c-chk-doc-attr.doc-code = ub.c-chk-doc.doc-code
              and ub.c-chk-doc-attr.chip-num = ub.c-chk-doc.chip-num
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          if ub.c-chk-doc-attr.out-code <> ? then next.
          create dst.c-chk-doc-attr.
          buffer-copy  ub.c-chk-doc-attr to dst.c-chk-doc-attr.
        end.
        create dst.c-chk-doc.
        buffer-copy  ub.c-chk-doc to dst.c-chk-doc.
      end.
    end. /*if p-unload-history then do:*/
  end.
  return.
end procedure. /* rest-chk */

procedure rest-tcc :
  define input  parameter p-db-num      as integer   no-undo .
  define input  parameter p-type-unload as character no-undo .

  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    define buffer buf-ub_db-rec-attr  for ub.db-rec-attr .
    define buffer buf-dst_db-rec-attr for dst.db-rec-attr .
    define buffer buf-src_db-rec-attr for src.db-rec-attr .
    define buffer buf_route       for dst.route .

    define variable v-today       as date      no-undo.
    define variable v-time        as integer   no-undo.

    define variable v-command      as character no-undo .
    define variable v-answer-code  as integer   no-undo .
    define variable v-answer-msg   as character no-undo .

    run fill-two-commit-command in this-procedure.
    find first temp_db-rec-attr
      where temp_db-rec-attr.db-num = ?
      no-error .
    if available temp_db-rec-attr then do:
      return error substitute( "Нельзя выгрузить БД!&1Есть незавершенные распределенные команды при которых выгрузка недопустима!", {&new-line} ).
    end.

    run cur-time in this-procedure
      ( output v-today
       ,output v-time
      ).
    run adm\comcom.p (p-db-num).
    
    for each temp_db-rec-attr
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    :
      if lookup( string( p-db-num ), temp_db-rec-attr.db-list, ",":U ) > 0 then do:
        if temp_db-rec-attr.attr-type = "execution":U
          or temp_db-rec-attr.attr-type = "recover":U
        then do:
          assign
            v-answer-code = 0
            v-answer-msg  = ""
          .
        end.
        else do:
          assign
            v-answer-code = 1
            v-answer-msg  = substitute( "Из-за выгрузки УБД &1 нельзя провести проверку.", p-db-num )
          .
          create buf-dst_db-rec-attr.
          buffer-copy temp_db-rec-attr to buf-dst_db-rec-attr
            assign
              buf-dst_db-rec-attr.db-num             = p-db-num
              buf-dst_db-rec-attr.attr-value-logical = yes
          .
        end.

        find first buf-ub_db-rec-attr no-lock
          where buf-ub_db-rec-attr.db-num       = p-db-num
            and buf-ub_db-rec-attr.uniq-key-rec = temp_db-rec-attr.uniq-key-rec
            and buf-ub_db-rec-attr.attr-code    = temp_db-rec-attr.attr-code
          no-error .
        if not available buf-ub_db-rec-attr then do:
          create buf-ub_db-rec-attr.
          buffer-copy temp_db-rec-attr to buf-ub_db-rec-attr
            assign
              buf-ub_db-rec-attr.db-num             = p-db-num
              buf-ub_db-rec-attr.attr-value-logical = yes
          .

          if p-type-unload = {&unload-copy} then do:
            create buf-src_db-rec-attr.
            buffer-copy temp_db-rec-attr to buf-src_db-rec-attr
              assign
                buf-src_db-rec-attr.db-num             = p-db-num
                buf-src_db-rec-attr.attr-value-logical = yes
            .
          end.
        end.
        /* мешает при обмене новостями , скорее всего это была защита от повторой выгрузки 
        assign
          v-command = "command":U + {&delim-nws}
                      + "two-commit":U + {&delim-nws}
                      + temp_db-rec-attr.attr-code /* p1-action */ + {&delim-nws}
                      + temp_db-rec-attr.attr-type /* p1-operation */ + {&delim-nws}
                      + temp_db-rec-attr.uniq-key-rec /* p1-uniq-key-rec */ + {&delim-nws}
                      + string( temp_db-rec-attr.attr-value-decimal /* p1-db-init */ ) + {&delim-nws}
                      + temp_db-rec-attr.attr-value /* p1-parameters */ + {&delim-nws}
                      + string( v-answer-code ) + {&delim-nws}
                      + v-answer-msg
        .
        { nws/cr-rt.i
          &cr-rt-log-db-name=dst
          &name-rec=v-command
          &db-num=0
          &uniq-key-rec="''":U
          &num-dump=0
          &CreDate=v-today
          &CreTimeInt=v-time
          &CreUserName="'rest-rdb'":U
        } */
      end.
    end.
  end.
end procedure. /* rest-tcc */

/* ========================================================================== */
procedure display-with-frame :
  define input parameter p-count-str      as character        no-undo.
  define input parameter p-table-name     as character        no-undo.
  define input parameter p-index          as integer          no-undo.

  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
      display
          p-count-str     @ count-str
          p-table-name    @ fl
          p-index         @ ind1
      with frame ddd
      view-as dialog-box.
  end.
end procedure. /* display-with-frame */

procedure rest-mpl :
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
/* Типы прайс-листов   все */

    assign ind1 = 0.
           fl   = "price-list-type".
    for each ub.price-list-type no-lock
        /*where ub.price-list-type.stts = integer({&pdf-new}) */
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    :
      assign  ind1 = ind1 + 1.
      display ind1 count-str fl with frame ddd view-as dialog-box.
      create dst.price-list-type.
      buffer-copy  ub.price-list-type to dst.price-list-type.

          for each ub.price-list-type-attr no-lock
             where ub.price-list-type-attr.plt-id     = ub.price-list-type.plt-id     and
                   ub.price-list-type-attr.plt-db-num = ub.price-list-type.plt-db-num
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
          :
            create dst.price-list-type-attr.
            buffer-copy ub.price-list-type-attr to dst.price-list-type-attr.
          end.
          for each ub.price-list-type-cash-pay no-lock
             where ub.price-list-type-cash-pay.plt-id     = ub.price-list-type.plt-id     and
                   ub.price-list-type-cash-pay.plt-db-num = ub.price-list-type.plt-db-num
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
          :
            create dst.price-list-type-cash-pay.
            buffer-copy ub.price-list-type-cash-pay to dst.price-list-type-cash-pay.
          end.

          for each ub.price-list-type-cassa no-lock
             where ub.price-list-type-cassa.plt-id     = ub.price-list-type.plt-id     and
                   ub.price-list-type-cassa.plt-db-num = ub.price-list-type.plt-db-num
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
          :
            create dst.price-list-type-cassa.
            buffer-copy ub.price-list-type-cassa to dst.price-list-type-cassa.
          end.

          for each ub.price-list-type-gds-grp no-lock
             where ub.price-list-type-gds-grp.plt-id     = ub.price-list-type.plt-id     and
                   ub.price-list-type-gds-grp.plt-db-num = ub.price-list-type.plt-db-num
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
          :
            create dst.price-list-type-gds-grp.
            buffer-copy ub.price-list-type-gds-grp to dst.price-list-type-gds-grp.
          end.

          for each ub.price-list-type-pay-type no-lock
             where ub.price-list-type-pay-type.plt-id     = ub.price-list-type.plt-id     and
                   ub.price-list-type-pay-type.plt-db-num = ub.price-list-type.plt-db-num
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
          :
            create dst.price-list-type-pay-type.
            buffer-copy ub.price-list-type-pay-type to dst.price-list-type-pay-type.
          end.
          if p-unload-history then do:
          for each ub.c-price-list-type no-lock
             where ub.c-price-list-type.plt-id     = ub.price-list-type.plt-id     and
                   ub.c-price-list-type.plt-db-num = ub.price-list-type.plt-db-num
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
          :
            create dst.c-price-list-type.
            buffer-copy ub.c-price-list-type to dst.c-price-list-type.
          end.

          for each ub.c-price-list-type-attr no-lock
             where ub.c-price-list-type-attr.plt-id     = ub.price-list-type.plt-id     and
                   ub.c-price-list-type-attr.plt-db-num = ub.price-list-type.plt-db-num
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
          :
            create dst.c-price-list-type-attr.
            buffer-copy ub.c-price-list-type-attr to dst.c-price-list-type-attr.
          end.
          for each ub.c-price-list-type-cash-pay no-lock
             where ub.c-price-list-type-cash-pay.plt-id     = ub.price-list-type.plt-id     and
                   ub.c-price-list-type-cash-pay.plt-db-num = ub.price-list-type.plt-db-num
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
          :
            create dst.c-price-list-type-cash-pay.
            buffer-copy ub.c-price-list-type-cash-pay to dst.c-price-list-type-cash-pay.
          end.

          for each ub.c-price-list-type-cassa no-lock
             where ub.c-price-list-type-cassa.plt-id     = ub.price-list-type.plt-id     and
                   ub.c-price-list-type-cassa.plt-db-num = ub.price-list-type.plt-db-num
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
          :
            create dst.c-price-list-type-cassa.
            buffer-copy ub.c-price-list-type-cassa to dst.c-price-list-type-cassa.
          end.

          for each ub.c-price-list-type-gds-grp no-lock
             where ub.c-price-list-type-gds-grp.plt-id     = ub.price-list-type.plt-id     and
                   ub.c-price-list-type-gds-grp.plt-db-num = ub.price-list-type.plt-db-num
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
          :
            create dst.c-price-list-type-gds-grp.
            buffer-copy ub.c-price-list-type-gds-grp to dst.c-price-list-type-gds-grp.
          end.

          for each ub.c-price-list-type-pay-type no-lock
             where ub.c-price-list-type-pay-type.plt-id     = ub.price-list-type.plt-id     and
                   ub.c-price-list-type-pay-type.plt-db-num = ub.price-list-type.plt-db-num
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
          :
            create dst.c-price-list-type-pay-type.
            buffer-copy ub.c-price-list-type-pay-type to dst.c-price-list-type-pay-type.
          end.
        end. /*if p-unload-history then do:*/
    end.
/* Документы назначения цены  закрытые */
/* TODO проверить по типу прайс-листа и выгружать если по всем объектам или по объектам выгружаемой БД  */
    assign ind1 = 0.
           fl   = "price-doc-forming".
    for each ub.price-doc-forming no-lock
        where ub.price-doc-forming.stts = integer({&pdf-fact}) /* факт */
          or  ub.price-doc-forming.stts = integer({&pdf-ready}) /* готов */
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    :
      assign  ind1 = ind1 + 1.
      display ind1 count-str fl with frame ddd view-as dialog-box.
      create dst.price-doc-forming.
      buffer-copy  ub.price-doc-forming to dst.price-doc-forming.

          for each ub.price-doc-forming-attr no-lock
             where ub.price-doc-forming-attr.plt-id     = ub.price-doc-forming.plt-id     and
                   ub.price-doc-forming-attr.plt-db-num = ub.price-doc-forming.plt-db-num and
                   ub.price-doc-forming-attr.pdf-id     = ub.price-doc-forming.pdf-id     and
                   ub.price-doc-forming-attr.pdf-db     = ub.price-doc-forming.pdf-db
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
          :
            create dst.price-doc-forming-attr.
            buffer-copy ub.price-doc-forming-attr to dst.price-doc-forming-attr.
          end.


          for each ub.price-doc-forming-gds no-lock
             where ub.price-doc-forming-gds.plt-id     = ub.price-doc-forming.plt-id     and
                   ub.price-doc-forming-gds.plt-db-num = ub.price-doc-forming.plt-db-num and
                   ub.price-doc-forming-gds.pdf-id     = ub.price-doc-forming.pdf-id     and
                   ub.price-doc-forming-gds.pdf-db     = ub.price-doc-forming.pdf-db
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
          :
            create dst.price-doc-forming-gds.
            buffer-copy ub.price-doc-forming-gds to dst.price-doc-forming-gds.
          end.

          for each ub.price-doc-forming-gds-qnty no-lock
             where ub.price-doc-forming-gds-qnty.plt-id     = ub.price-doc-forming.plt-id     and
                   ub.price-doc-forming-gds-qnty.plt-db-num = ub.price-doc-forming.plt-db-num and
                   ub.price-doc-forming-gds-qnty.pdf-id     = ub.price-doc-forming.pdf-id     and
                   ub.price-doc-forming-gds-qnty.pdf-db     = ub.price-doc-forming.pdf-db
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
          :
            create dst.price-doc-forming-gds-qnty.
            buffer-copy ub.price-doc-forming-gds-qnty to dst.price-doc-forming-gds-qnty.
          end.

          for each ub.price-doc-forming-gds-sum no-lock
             where ub.price-doc-forming-gds-sum.plt-id     = ub.price-doc-forming.plt-id     and
                   ub.price-doc-forming-gds-sum.plt-db-num = ub.price-doc-forming.plt-db-num and
                   ub.price-doc-forming-gds-sum.pdf-id     = ub.price-doc-forming.pdf-id     and
                   ub.price-doc-forming-gds-sum.pdf-db     = ub.price-doc-forming.pdf-db
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
          :
            create dst.price-doc-forming-gds-sum.
            buffer-copy ub.price-doc-forming-gds-sum to dst.price-doc-forming-gds-sum.
          end.
          for each ub.price-doc-forming-gds-tnv no-lock
             where ub.price-doc-forming-gds-tnv.plt-id     = ub.price-doc-forming.plt-id     and
                   ub.price-doc-forming-gds-tnv.plt-db-num = ub.price-doc-forming.plt-db-num and
                   ub.price-doc-forming-gds-tnv.pdf-id     = ub.price-doc-forming.pdf-id     and
                   ub.price-doc-forming-gds-tnv.pdf-db     = ub.price-doc-forming.pdf-db
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
          :
            create dst.price-doc-forming-gds-tnv.
            buffer-copy ub.price-doc-forming-gds-tnv to dst.price-doc-forming-gds-tnv.
          end.
          if p-unload-history then do:
          for each ub.c-price-doc-forming-attr no-lock
             where ub.c-price-doc-forming-attr.plt-id     = ub.price-doc-forming.plt-id     and
                   ub.c-price-doc-forming-attr.plt-db-num = ub.price-doc-forming.plt-db-num and
                   ub.c-price-doc-forming-attr.pdf-id     = ub.price-doc-forming.pdf-id     and
                   ub.c-price-doc-forming-attr.pdf-db     = ub.price-doc-forming.pdf-db
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
          :
            create dst.c-price-doc-forming-attr.
            buffer-copy ub.c-price-doc-forming-attr to dst.c-price-doc-forming-attr.
          end.


          for each ub.c-price-doc-forming-gds no-lock
             where ub.c-price-doc-forming-gds.plt-id     = ub.price-doc-forming.plt-id     and
                   ub.c-price-doc-forming-gds.plt-db-num = ub.price-doc-forming.plt-db-num and
                   ub.c-price-doc-forming-gds.pdf-id     = ub.price-doc-forming.pdf-id     and
                   ub.c-price-doc-forming-gds.pdf-db     = ub.price-doc-forming.pdf-db
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
          :
            create dst.c-price-doc-forming-gds.
            buffer-copy ub.c-price-doc-forming-gds to dst.c-price-doc-forming-gds.
          end.

          for each ub.c-price-doc-forming-gds-qnty no-lock
             where ub.c-price-doc-forming-gds-qnty.plt-id     = ub.price-doc-forming.plt-id     and
                   ub.c-price-doc-forming-gds-qnty.plt-db-num = ub.price-doc-forming.plt-db-num and
                   ub.c-price-doc-forming-gds-qnty.pdf-id     = ub.price-doc-forming.pdf-id     and
                   ub.c-price-doc-forming-gds-qnty.pdf-db     = ub.price-doc-forming.pdf-db
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
          :
            create dst.c-price-doc-forming-gds-qnty.
            buffer-copy ub.c-price-doc-forming-gds-qnty to dst.c-price-doc-forming-gds-qnty.
          end.

          for each ub.c-price-doc-forming-gds-sum no-lock
             where ub.c-price-doc-forming-gds-sum.plt-id     = ub.price-doc-forming.plt-id     and
                   ub.c-price-doc-forming-gds-sum.plt-db-num = ub.price-doc-forming.plt-db-num and
                   ub.c-price-doc-forming-gds-sum.pdf-id     = ub.price-doc-forming.pdf-id     and
                   ub.c-price-doc-forming-gds-sum.pdf-db     = ub.price-doc-forming.pdf-db
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
          :
            create dst.c-price-doc-forming-gds-sum.
            buffer-copy ub.c-price-doc-forming-gds-sum to dst.c-price-doc-forming-gds-sum.
          end.
          for each ub.c-price-doc-forming-gds-tnv no-lock
             where ub.c-price-doc-forming-gds-tnv.plt-id     = ub.price-doc-forming.plt-id     and
                   ub.c-price-doc-forming-gds-tnv.plt-db-num = ub.price-doc-forming.plt-db-num and
                   ub.c-price-doc-forming-gds-tnv.pdf-id     = ub.price-doc-forming.pdf-id     and
                   ub.c-price-doc-forming-gds-tnv.pdf-db     = ub.price-doc-forming.pdf-db
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
          :
            create dst.c-price-doc-forming-gds-tnv.
            buffer-copy ub.c-price-doc-forming-gds-tnv to dst.c-price-doc-forming-gds-tnv.
          end.
          for each ub.c-price-doc-forming no-lock
             where ub.c-price-doc-forming.plt-id     = ub.price-doc-forming.plt-id     and
                   ub.c-price-doc-forming.plt-db-num = ub.price-doc-forming.plt-db-num and
                   ub.c-price-doc-forming.pdf-id     = ub.price-doc-forming.pdf-id     and
                   ub.c-price-doc-forming.pdf-db     = ub.price-doc-forming.pdf-db
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
          :
            create dst.c-price-doc-forming.
            buffer-copy ub.c-price-doc-forming to dst.c-price-doc-forming.
          end.
       end.
    end.

  end.
  return.

end procedure. /* load-mpl */


procedure rest-assort-matrix :
/* восстановление ассортиментной матрицы  по объектам УБД и шаблонов созданных в УБД*/
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
  disable triggers for load of ub.assortment-matrix.
  disable triggers for load of ub.assortment-matrix-attr.
  disable triggers for load of ub.assortment-matrix-goods.
  disable triggers for dump of ub.assortment-matrix.
  disable triggers for dump of ub.assortment-matrix-attr.
  disable triggers for dump of ub.assortment-matrix-goods.

  disable triggers for load of dst.assortment-matrix.
  disable triggers for load of dst.assortment-matrix-attr.
  disable triggers for load of dst.assortment-matrix-goods.
  disable triggers for dump of dst.assortment-matrix.
  disable triggers for dump of dst.assortment-matrix-attr.
  disable triggers for dump of dst.assortment-matrix-goods.

  for each ub.assortment-matrix no-lock where
           ub.assortment-matrix.obj-type = p-obj-type and
           ub.assortment-matrix.obj-code = p-obj-code
           on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
           :
          create dst.assortment-matrix .
          buffer-copy ub.assortment-matrix to dst.assortment-matrix.

          for each ub.assortment-matrix-goods no-lock where
                  ub.assortment-matrix-goods.asmt-id = ub.assortment-matrix.asmt-id  and
                  ub.assortment-matrix-goods.db-num  = ub.assortment-matrix.db-num
                  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
                  :
                  create dst.assortment-matrix-goods .
                  buffer-copy ub.assortment-matrix-goods to dst.assortment-matrix-goods .
          end.
          for each ub.assortment-matrix-attr no-lock where
                  ub.assortment-matrix-attr.asmt-id = ub.assortment-matrix.asmt-id  and
                  ub.assortment-matrix-attr.db-num  = ub.assortment-matrix.db-num
                  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
                  :
                  create dst.assortment-matrix-attr .
                  buffer-copy ub.assortment-matrix-attr to dst.assortment-matrix-attr .
          end.


  end.
end.

end procedure. /* rest-assort-matrix */


procedure rest-season :
/* восстановление сезонов и товарного наполнения сезона по объектам УБД*/
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
  disable triggers for load of ub.season.
  disable triggers for load of ub.season-attr.
  disable triggers for load of ub.gds-season.
  disable triggers for load of ub.gds-season-attr.
  disable triggers for dump of ub.season.
  disable triggers for dump of ub.season-attr.
  disable triggers for dump of ub.gds-season.
  disable triggers for dump of ub.gds-season-attr.

  disable triggers for load of dst.season.
  disable triggers for load of dst.season-attr.
  disable triggers for load of dst.gds-season.
  disable triggers for load of dst.gds-season-attr.
  disable triggers for dump of dst.season.
  disable triggers for dump of dst.season-attr.
  disable triggers for dump of dst.gds-season.
  disable triggers for dump of dst.gds-season-attr.
  
  
  
  for each ub.season no-lock:
  
    find first ub.season-attr no-lock where ub.season-attr.sea-code =  ub.season.sea-code 
      and ub.season-attr.db-num = ub.season.db-num
      and ub.season-attr.attr-code = {&seaattr-obj} no-error.
    
    if (available ub.season-attr 
        and ub.season-attr.attr-value = p-obj-type + string (p-obj-code))
        or (not available ub.season-attr and p-obj-code = ?)
    then do:
      
      for each ub.season-attr no-lock where ub.season-attr.sea-code = ub.season.sea-code
        and ub.season-attr.db-num = ub.season.db-num:
        create dst.season-attr .
        buffer-copy ub.season-attr to dst.season-attr .  
      end.
      
      for each ub.gds-season no-lock where ub.gds-season.sea-code = ub.season.sea-code
        and ub.gds-season.db-num = ub.season.db-num:
        create dst.gds-season .
        buffer-copy ub.gds-season to dst.gds-season . 
      end.
      
      for each ub.gds-season-attr no-lock where ub.gds-season-attr.sea-code = ub.season.sea-code
          and ub.gds-season-attr.db-num = ub.season.db-num:
        create dst.gds-season-attr .
        buffer-copy ub.gds-season-attr to dst.gds-season-attr .
      end.
      
      create dst.season.
      buffer-copy ub.season to dst.season.
      
    end.
  
  end.

end.

end procedure. /* rest-season */


procedure rest-fin-ob :
/* восстановление ФО покупателей закрытые на факт */
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
  for each ub.fin-ob no-lock where
           ub.fin-ob.obj-type = p-obj-type and
           ub.fin-ob.obj-code = p-obj-code and
           ub.fin-ob.doc-type = {&income}  and
           ub.fin-ob.status_  = {&fin-fact}
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
          :

          for each ub.fin-ob-tax no-lock where
                   ub.fin-ob-tax.host-code = ub.fin-ob.host-code and
                   ub.fin-ob-tax.doc-code = ub.fin-ob.doc-code
                   on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
                   :
                    create dst.fin-ob-tax.
                    buffer-copy ub.fin-ob-tax to dst.fin-ob-tax.
          end.
          for each ub.fin-ob-attr no-lock where
                   ub.fin-ob-attr.host-code = ub.fin-ob.host-code and
                   ub.fin-ob-attr.doc-code  = ub.fin-ob.doc-code
                   on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
                   :
                    create dst.fin-ob-attr.
                    buffer-copy ub.fin-ob-attr to dst.fin-ob-attr.
          end.
          for each ub.fin-ob-trn no-lock where
                   ub.fin-ob-trn.host-code = ub.fin-ob.host-code and
                   ub.fin-ob-trn.doc-code  = ub.fin-ob.doc-code
                   on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
                   :
                    create dst.fin-ob-trn.
                    buffer-copy ub.fin-ob-trn to dst.fin-ob-trn.
          end.
          for each ub.fin-gds-part no-lock where
                   ub.fin-gds-part.host-code = ub.fin-ob.host-code and
                   ub.fin-gds-part.fin-ob-code  = ub.fin-ob.doc-code
                   on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
                   :
                    create dst.fin-gds-part.
                    buffer-copy ub.fin-gds-part to dst.fin-gds-part.
          end.

        create dst.fin-ob.
        buffer-copy ub.fin-ob to dst.fin-ob.
  end.


  end.
end procedure. /* rest-fin-ob */

procedure rest-price-all :
/* восстановление таблицы цен по объектам УБД */
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .

  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
  for each ub.price-all no-lock where
           ub.price-all.obj-type = p-obj-type and
           ub.price-all.obj-code = p-obj-code
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
          :
            create dst.price-all.
            buffer-copy ub.price-all to dst.price-all.
  end.

  end.

end procedure. /* rest-price-all */


procedure rest-add-doc :
/* восстановление таблицы ДопРасходов по объектам УБД */
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .

  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
  for each ub.add-doc no-lock where
           ub.add-doc.obj-type = p-obj-type and
           ub.add-doc.obj-code = p-obj-code and
           ( ub.add-doc.status_  = {&fact} or
           ub.add-doc.status_    = {&add-close} )
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
          :

      for each ub.add-line no-lock where
               ub.add-line.doc-code = ub.add-doc.doc-code
              on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
              :
            create dst.add-line.
            buffer-copy ub.add-line to dst.add-line.
      end.
      for each ub.add-trn no-lock where
               ub.add-trn.doc-code = ub.add-doc.doc-code
              on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
              :
            create dst.add-trn.
            buffer-copy ub.add-trn to dst.add-trn.
      end.

      create dst.add-doc.
      buffer-copy ub.add-doc to dst.add-doc.
  end.

  end.

end procedure. /* rest-add-doc */

procedure rest-cash-book private :
/* Кассовые книги. Действие то же самое, что с add-doc и с action-role */

  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
      for each ub.CashBook no-lock
      on error  undo, return error substitute( "&1 (CashBook). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo, return error substitute( "&1 (CashBook). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (CashBook). endkey", vss-workfile )
      :
        create dst.CashBook.
        buffer-copy ub.CashBook to dst.CashBook .
      end.

      for each ub.CashBookAttr no-lock
      on error  undo, return error substitute( "&1 (CashBookAttr). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo, return error substitute( "&1 (CashBookAttr). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (CashBookAttr). endkey", vss-workfile )
      :
        create dst.CashBookAttr.
        buffer-copy ub.CashBookAttr to dst.CashBookAttr .
      end.

      for each ub.CashBookRule no-lock
/*         where ub.CashBookRule.Obj-type = p-obj-type*/
/*           and ub.CashBookRule.Obj-code = p-obj-code*/
      on error  undo, return error substitute( "&1 (CashBookRule). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo, return error substitute( "&1 (CashBookRule). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (CashBookRule). endkey", vss-workfile )
      :
        create dst.CashBookRule.
        buffer-copy ub.CashBookRule to dst.CashBookRule .
        
      end.
      
      for each ub.CashBookRuleAttr no-lock
/*              where ub.CashBookRuleAttr.obj-type    = ub.CashBookRule.obj-type*/
/*                and ub.CashBookRuleAttr.obj-code    = ub.CashBookRule.obj-code*/
      on error  undo, return error substitute( "&1 (CashBookRuleAttr). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo, return error substitute( "&1 (CashBookRuleAttr). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (CashBookRuleAttr). endkey", vss-workfile )
      :
          create dst.CashBookRuleAttr.
          buffer-copy ub.CashBookRuleAttr to dst.CashBookRuleAttr .
      end.
      
      for each ub.OperServ no-lock
      on error  undo, return error substitute( "&1 (OperServ). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo, return error substitute( "&1 (OperServ). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (OperServ). endkey", vss-workfile )
      :
        create dst.OperServ.
        buffer-copy ub.OperServ to dst.OperServ .
      end.

      for each ub.OperServAttr no-lock
      on error  undo, return error substitute( "&1 (OperServAttr). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo, return error substitute( "&1 (OperServAttr). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (OperServAttr). endkey", vss-workfile )
      :
        create dst.OperServAttr.
        buffer-copy ub.OperServAttr to dst.OperServAttr .
      end.

  end. /* end_of doe */

end procedure. /* rest-cash-book */

procedure rest-promo-action private :
   /* Промоакции */
   do
      on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      on stop   undo, return error substitute( "&1. stop", vss-workfile )
      on endkey undo, return error substitute( "&1. endkey", vss-workfile )
      :
      for each dst.PromoAction:
         delete dst.PromoAction .
      end.   
      for each dst.PromoAttr:
         delete dst.PromoAttr .
      end.   
      for each dst.promo-schedule:
         delete dst.promo-schedule .
      end.   
      for each dst.promo-schedule-week:
         delete dst.promo-schedule-week .
      end.   
      for each dst.PromoCriterion:
         delete dst.PromoCriterion .
      end.   
      for each dst.PromoGift:
         delete dst.PromoGift .
      end.   
      for each dst.PromoGoods:
         delete dst.PromoGoods .
      end.         
      for each dst.PromoObject:
         delete dst.PromoObject .
      end.       
           
      for each ub.PromoAction no-lock
         where ub.PromoAction.end-date < today and ub.PromoAction.Status_ <> 2 
         on error  undo, return error substitute( "&1 (PromoAction). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
         on stop   undo, return error substitute( "&1 (PromoAction). stop", vss-workfile )
         on endkey undo, return error substitute( "&1 (PromoAction). endkey", vss-workfile )
         :
         create dst.PromoAction.
         buffer-copy ub.PromoAction to dst.PromoAction .
         for each ub.PromoAttr no-lock
            where ub.PromoAttr.tablename = "PromoAction" and
            ub.PromoAttr.attr-code = "promo-message" and
            ub.PromoAction.id = int64(entry(1,ub.PromoAttr.p-key,{&delim-key})) and 
            ub.PromoAction.db-num = integer(entry(2,ub.PromoAttr.p-key,{&delim-key}))
            on error  undo, return error substitute( "&1 (PromoAttr). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
            on stop   undo, return error substitute( "&1 (PromoAttr). stop", vss-workfile )
            on endkey undo, return error substitute( "&1 (PromoAttr). endkey", vss-workfile )
            :
            create dst.PromoAttr.
            buffer-copy ub.PromoAttr to dst.PromoAttr .
         end.

         for each ub.promo-schedule no-lock
            where ub.promo-schedule.db-num = ub.PromoAction.db-num and
            ub.promo-schedule.id = ub.PromoAction.promosched-id
            on error  undo, return error substitute( "&1 (promo-schedule). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
            on stop   undo, return error substitute( "&1 (promo-schedule). stop", vss-workfile )
            on endkey undo, return error substitute( "&1 (promo-schedule). endkey", vss-workfile )
            :
            create dst.promo-schedule.
            buffer-copy ub.promo-schedule to dst.promo-schedule .
        
         end.
      
         for each ub.promo-schedule-week no-lock
            where ub.promo-schedule-week.db-num = ub.PromoAction.db-num and
            ub.promo-schedule-week.promosched-id = ub.PromoAction.promosched-id
            on error  undo, return error substitute( "&1 (promo-schedule-week). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
            on stop   undo, return error substitute( "&1 (promo-schedule-week). stop", vss-workfile )
            on endkey undo, return error substitute( "&1 (promo-schedule-week). endkey", vss-workfile )
            :
            create dst.promo-schedule-week.
            buffer-copy ub.promo-schedule-week to dst.promo-schedule-week .
         end.
      
         for each ub.PromoCriterion no-lock
            where ub.PromoCriterion.db-num = ub.PromoAction.db-num and
            ub.PromoCriterion.idAction = ub.PromoAction.id
            on error  undo, return error substitute( "&1 (PromoCriterion). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
            on stop   undo, return error substitute( "&1 (PromoCriterion). stop", vss-workfile )
            on endkey undo, return error substitute( "&1 (PromoCriterion). endkey", vss-workfile )
            :
            create dst.PromoCriterion.
            buffer-copy ub.PromoCriterion to dst.PromoCriterion .
         end.

         for each ub.PromoGift no-lock
            where ub.PromoGift.db-num = ub.PromoAction.db-num and
            ub.PromoGift.idaction = ub.PromoAction.id
            on error  undo, return error substitute( "&1 (PromoGift). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
            on stop   undo, return error substitute( "&1 (PromoGift). stop", vss-workfile )
            on endkey undo, return error substitute( "&1 (PromoGift). endkey", vss-workfile )
            :
            create dst.PromoGift.
            buffer-copy ub.PromoGift to dst.PromoGift .
         end.

         for each ub.PromoGoods no-lock
            where ub.PromoGoods.db-num = ub.PromoAction.db-num and
            ub.PromoGoods.idAction = ub.PromoAction.id
            on error  undo, return error substitute( "&1 (PromoGoods). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
            on stop   undo, return error substitute( "&1 (PromoGoods). stop", vss-workfile )
            on endkey undo, return error substitute( "&1 (PromoGoods). endkey", vss-workfile )
            :
            create dst.PromoGoods.
            buffer-copy ub.PromoGoods to dst.PromoGoods .
         end.

         for each ub.PromoObject no-lock
            where ub.PromoObject.db-num = ub.PromoAction.db-num and
            ub.PromoObject.idAction = ub.PromoAction.id  
            on error  undo, return error substitute( "&1 (PromoObject). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
            on stop   undo, return error substitute( "&1 (PromoObject). stop", vss-workfile )
            on endkey undo, return error substitute( "&1 (PromoObject). endkey", vss-workfile )
            :
            create dst.PromoObject.
            buffer-copy ub.PromoObject to dst.PromoObject .
         end.
      end.
   end. /* end_of doe */

end procedure. /* rest-promo-action */