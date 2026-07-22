block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Приведение дефолтных раскладок, имеющихся в БД к эталонному виду

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/26/08
Author: Bakhtadze Natalya
Creation date: 09/26/08

*/

define input parameter p-forced as logical no-undo .
define input parameter p-read-only as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Приведение дефолтных раскладок, имеющихся в БД к эталонному виду".
{ cmp/vssrevis.i }

{ cmp/trg-def.i  }  /* не убирать, иначе будет вызываться отовсюду, и СПН не сработает */
{ trg/factord.i  }
{ gbl/cur-time.i }
{ gbl/waitfram.i }
{ gbl/layconf.i  }
define stream imp-stream.
{ utl/upgimptt.i def "new shared" }
{ trg/layouth.i }
{ gbl/key-rec.i }

define variable v-check1 as logical no-undo .
define variable v-check2 as logical no-undo .

define variable v-force as logical no-undo .
define variable v-mes   as character no-undo .
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
define variable v-md5-signature as character no-undo .

&global-define shared-option new shared

&global-define table-name layout
{&create-static-table}.

&global-define table-name layout-elem
{&create-static-table}.

&global-define table-name layout-elem-rule
{&create-static-table}.


&global-define table-name wi-mode
{&create-static-table}.

&global-define table-name rule-call-param
{&create-static-table}.

&global-define table-name rule-by-call
{&create-static-table}.

&global-define table-name rule-by-set
{&create-static-table}.




define buffer buf_tt-layout for tt-layout.
define buffer buf_tt-layout-elem for tt-layout-elem.
define buffer buf_tt-wi-mode for tt-wi-mode.


run waitfram-show in this-procedure ("Реинициализация раскладок").
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if ( g#db-num > 0 ) then return.
  if not p-forced then do:
    run check-layout-version in this-procedure (output v-check1).
  end.
  if v-check1
  or p-forced
  then do:
    if v-check1
     and p-read-only then do:
        return error substitute("&1 &2 &3&4До начала работы с данной БД (режим RO) необходимо произвести вход в ОСНОВНУЮ БД!!!"
                                ,vss-workfile
                                ,vss-revision
                                ,vss-description
                                ,{&new-line}).
     end.
     run gbl/md5.p (
       input  "cmp/fix-lay.txt"     /* p-file-name     */
      ,output v-md5-signature /* p-md5-signature */
      ) .
    if v-md5-signature <> "{&layout-md5}" then do:
      message
      substitute("Несовпадение файла эталонных записей по расладкам (fix-lay.txt) с контрольным числом")
      view-as alert-box error .
      undo, return error .
    end.
    run gbl/filename.p ( input "cmp/fix-lay.txt"
                        ,output v-full-path
                        ,output v-path
                        ,output v-file-name
                        ,output v-file-name-no-ext
                        ,output v-file-name-ext
                        ) no-error .
    if error-status:error then do:
      message
      substitute("Не найден файл эталонных записей по раскладкам (fix-lay.txt)")
      view-as alert-box error .
      undo, return error .
    end.
    run str/diallog.w (
          input ? /*parparentproc*/
        ,input this-procedure
        ,input ('utl/upgimptt.p' + {&delim-par}  +
                '1' + {&delim-par} +
                '1' + {&delim-par} +
                '1' + {&delim-par} +
                '1')
        ,input v-full-path
        ,input yes /*p-auto-go*/
        ,input 'Прервать'
        ,input 'Чтение файла в память') no-error .
    if error-status:error then do:
      message
      substitute("Ошибка при чтении в память файла эталонных записей по раскладкам (fix-lay.txt)&1&2&1&3"
                   , {&new-line}
                   , error-status:get-message(1)
                   , return-value )
      view-as alert-box error .
      undo, return error .
    end.
    if v-check1 then do:
      find first buf_tt-layout no-lock where
                buf_tt-layout.layout-id = '_'  no-error.
      if not available buf_tt-layout
      or buf_tt-layout.layout-name <> {&layout-revision} then do:
        message
        substitute("Версии дефолтных раскладок в r-кодах и файле эталонных записей по раскладкам (fix-lay.txt) НЕ СОВПАДАЮТ&1" +
                   "в r-кодах - &2&1" +
                   "в файле - &3"
                   , {&new-line}
                   , {&layout-revision}
                   , (if available buf_tt-layout then buf_tt-layout.layout-name else '')
                   )
        view-as alert-box error .
        undo, return error .
      end.
    end.
    run add-wi-mode in this-procedure no-error .
    if error-status:error then do:
      run waitfram-hide in this-procedure .
      assign
      v-mes = substitute("Ошибки при инициализации режимов работы IBS TH POS:&1&2 &3"
                         , {&new-line}
                         , error-status:get-message(1)
                         , return-value ).
      if p-forced then do:
        message
        v-mes
        view-as alert-box error .
      end.
      undo, return error v-mes.
    end.
    run add-layout-elem in this-procedure  no-error .
    if error-status:error then do:
      run waitfram-hide in this-procedure .
      assign
      v-mes = substitute("Ошибки при инициализации элементов для раскладок IBS TH POS:&1&2 &3"
                         , {&new-line}
                         , error-status:get-message(1)
                         , return-value ).
      if p-forced then do:
        message
        v-mes
        view-as alert-box error .
      end.
      undo, return error v-mes.
    end.
    run add-layout in this-procedure no-error .
    if error-status:error then do:
      run waitfram-hide in this-procedure .
      assign
      v-mes = substitute("Ошибки при инициализации раскладок:&1&2 &3"
                         , {&new-line}
                         , error-status:get-message(1)
                         , return-value ).
      if p-forced then do:
        message
        v-mes
        view-as alert-box error .
      end.
      undo, return error v-mes.
    end.
    run delete-layout-elem in this-procedure no-error .
    if error-status:error then do:
      run waitfram-hide in this-procedure .
      assign
      v-mes = substitute("Ошибки при удалении ненужных элементов для раскладок:&1&2 &3"
                         , {&new-line}
                         , error-status:get-message(1)
                         , return-value ).
      if p-forced then do:
        message
        v-mes
        view-as alert-box error .
      end.
      undo, return error v-mes.
    end.
    run delete-wi-mode in this-procedure no-error .
    if error-status:error then do:
      run waitfram-hide in this-procedure .
      assign
      v-mes = substitute("Ошибки при удалении ненужных режимов:&1&2 &3"
                         , {&new-line}
                         , error-status:get-message(1)
                         , return-value ).
      if p-forced then do:
        message
        v-mes
        view-as alert-box error .
      end.
      undo, return error v-mes.
    end.
    run delete-rule-by-set in this-procedure no-error.
    if error-status:error then do:
      run waitfram-hide in this-procedure .
      assign
      v-mes = substitute("Ошибки при удалении ненужных привязок правил:&1&2 &3"
                         , {&new-line}
                         , error-status:get-message(1)
                         , return-value ).
      if p-forced then do:
        message
        v-mes
        view-as alert-box error .
      end.
      undo, return error v-mes.
    end.
  end.
  for each buf_temp-tables
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    if valid-handle(buf_temp-tables.tbl-handle) then do:
      delete object buf_temp-tables.tbl-handle.
     end.
  end.
end. /*doe*/

run waitfram-hide in this-procedure .

procedure add-layout-elem :
define variable v-cmp as logical   no-undo .
define variable v-chip-num as integer no-undo .
define buffer buf_tt-layout-elem for tt-layout-elem.
define buffer buf_layout-elem for ub.layout-elem.
define buffer buf_layout-elem-rule for ub.layout-elem-rule.
define buffer buf_layout for ub.layout.
define buffer buf2_layout-elem-rule for ub.layout-elem-rule.

main-block:
do
on error undo, return error return-value
:


  for each buf_tt-layout-elem
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    v-cmp = no.
    find first buf_layout-elem where
             buf_layout-elem.layout-type = buf_tt-layout-elem.layout-type
         and buf_layout-elem.device-type = buf_tt-layout-elem.device-type
         and buf_layout-elem.mode-id = buf_tt-layout-elem.mode-id
         and buf_layout-elem.widget-id = buf_tt-layout-elem.widget-id no-error .
    if not available buf_layout-elem then do:
      create buf_layout-elem.
      v-cmp = no.
    end.
    else do:
      buffer-compare buf_tt-layout-elem to buf_layout-elem save result in v-cmp.
    end.
    if not v-cmp then do:
      buffer-copy buf_tt-layout-elem to buf_layout-elem.
    end.
    if buf_tt-layout-elem.elem-type = integer({&lelem-type-nonprogrammable}) then do:
      for each buf_layout-elem-rule no-lock where
              buf_layout-elem-rule.mode-id = tt-layout-elem.mode-id
          and buf_layout-elem-rule.widget-id = tt-layout-elem.widget-id
        on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
        on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
        on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
        :
        find first buf_layout share-lock where
                 buf_layout.layout-id = buf_layout-elem-rule.layout-id
             and buf_layout.layout-type = buf_layout-elem.layout-type
             and buf_layout.device-type = buf_layout-elem.device-type no-error.
        if available buf_layout
        and buf_layout.is-default = integer({&layout-ordinal})
        then do:
          run  layouth_create-layout_h  in this-procedure (
                                                         input {&update}
                                                        ,input buf_layout.layout-id
                                                        ,buffer buf_layout
                                                        ,output v-chip-num).

          if buf_layout.sts <> integer({&to-delete-status-int}) then
          assign
          buf_layout.sts = integer({&blocked-status-int})
          .
          find first buf2_layout-elem-rule exclusive-lock where
                    recid(buf2_layout-elem-rule) = recid(buf_layout-elem-rule).
          run  layouth_create-layout-elem-rule_h  in this-procedure (
                                                          input {&update}
                                                        ,input buf2_layout-elem-rule.layout-id
                                                        ,input buf2_layout-elem-rule.mode-id
                                                        ,input buf2_layout-elem-rule.widget-id
                                                        ,buffer buf2_layout-elem-rule
                                                        ,input v-chip-num).
          assign
          buf2_layout-elem-rule.sts = integer({&deleted-status-int})
          .

        end.
      end.
    end.
  end.
end.

end procedure. /* add-layout-elem */


procedure delete-layout-elem :
define variable v-cmp as logical   no-undo .
define variable v-chip-num as integer no-undo .
define buffer buf_tt-layout-elem for tt-layout-elem.
define buffer buf_layout-elem for ub.layout-elem.
define buffer buf_layout-elem-rule for ub.layout-elem-rule.
define buffer buf2_layout-elem-rule for ub.layout-elem-rule.
define buffer buf_layout for ub.layout.


main-block:
do
on error undo, return error return-value
:


  for each buf_layout-elem
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    v-cmp = no.
    find first buf_tt-layout-elem where
             buf_tt-layout-elem.layout-type = buf_layout-elem.layout-type
         and buf_tt-layout-elem.device-type = buf_layout-elem.device-type
         and buf_tt-layout-elem.mode-id = buf_layout-elem.mode-id
         and buf_tt-layout-elem.widget-id = buf_layout-elem.widget-id no-error .
    if not available buf_tt-layout-elem then do:
      for each buf_layout-elem-rule no-lock where
              buf_layout-elem-rule.mode-id = buf_layout-elem.mode-id
          and buf_layout-elem-rule.widget-id = buf_layout-elem.widget-id
        on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
        on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
        on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
        :
        find first buf_layout share-lock where
                 buf_layout.layout-id = buf_layout-elem-rule.layout-id
             and buf_layout.layout-type = buf_layout-elem.layout-type
             and buf_layout.device-type = buf_layout-elem.device-type no-error.
        if available buf_layout then do:
          run  layouth_create-layout_h  in this-procedure (
                                                         input {&update}
                                                        ,input buf_layout.layout-id
                                                        ,buffer buf_layout
                                                        ,output v-chip-num).

          if buf_layout.sts <> integer({&to-delete-status-int}) then
          assign
          buf_layout.sts = integer({&blocked-status-int})
          .
        end.
        find first buf2_layout-elem-rule exclusive-lock where
                  recid(buf2_layout-elem-rule) = recid(buf_layout-elem-rule).
        run  layouth_create-layout-elem-rule_h  in this-procedure (
                                                        input {&update}
                                                      ,input buf2_layout-elem-rule.layout-id
                                                      ,input buf2_layout-elem-rule.mode-id
                                                      ,input buf2_layout-elem-rule.widget-id
                                                      ,buffer buf2_layout-elem-rule
                                                      ,input v-chip-num).
        assign
        buf2_layout-elem-rule.sts = integer({&deleted-status-int})
        .
      end.
    end.
  end.
end.

end procedure. /* add-layout */


procedure add-layout :
define variable v-cmp as logical   no-undo .
define variable v-chip-num as integer no-undo .
define variable v-ler-uniq-key-rec as character no-undo .
define variable v-rbc-uniq-key-rec as character no-undo .
define variable v-call#-id as integer no-undo .
define buffer buf_tt-layout for tt-layout.
define buffer buf_tt-layout-elem for tt-layout-elem.
define buffer buf_layout for ub.layout.
define buffer buf2_layout for ub.layout.
define buffer buf3_layout for ub.layout.
define buffer buf_layout-elem for ub.layout-elem.
define buffer buf2_layout-elem-rule for ub.layout-elem-rule.
define buffer buf_tt-layout-elem-rule for tt-layout-elem-rule.
define buffer buf_layout-elem-rule for ub.layout-elem-rule.
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_tt-rule-call-param for tt-rule-call-param.
define buffer buf_rule-by-call for ub.rule-by-call.
define buffer buf_tt-rule-by-call for tt-rule-by-call.
define buffer buf_wi-mode for ub.wi-mode.


main-block:
do
on error undo, return error return-value
:


  for each buf_tt-layout where
         (buf_tt-layout.is-default = integer({&layout-default})
          or
          buf_tt-layout.is-default = integer({&layout-mandatory})
          )
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    v-chip-num = -1.
    v-cmp = yes.
    find first buf_layout exclusive-lock where
             buf_layout.layout-id = buf_tt-layout.layout-id no-error.
    if not available buf_layout then do:
      create buf_layout.
      v-cmp = no.
    end.
    else do:
      buffer-compare buf_tt-layout to buf_layout case-sensitive save result in v-cmp.
    end.
    if not v-cmp then do:
      run  layouth_create-layout_h  in this-procedure (
                                                      input (if new(buf_layout) then {&add-def} else {&update})
                                                    ,input buf_tt-layout.layout-id
                                                    ,buffer buf_layout
                                                    ,output v-chip-num).
      buffer-copy buf_tt-layout to buf_layout.
    end.
    for each buf_tt-layout-elem-rule where
            buf_tt-layout-elem-rule.layout-id = buf_tt-layout.layout-id
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile ):
      v-cmp = yes.
      find first buf_layout-elem-rule where
                buf_layout-elem-rule.layout-id = buf_tt-layout.layout-id
            and buf_layout-elem-rule.mode-id = buf_tt-layout-elem-rule.mode-id
            and buf_layout-elem-rule.widget-id = buf_tt-layout-elem-rule.widget-id no-error.
      if not available buf_layout-elem-rule then do:
        create buf_layout-elem-rule.
        v-cmp = no.
      end.
      else do:
       buffer-compare buf_tt-layout-elem-rule to buf_layout-elem-rule case-sensitive save result in v-cmp.
      end.
      if not v-cmp then do:
        if v-chip-num < 0 then do:
          run  layouth_create-layout_h  in this-procedure (
                                                          input (if new(buf_layout) then {&add-def} else {&update})
                                                        ,input buf_tt-layout.layout-id
                                                        ,buffer buf_layout
                                                        ,output v-chip-num).
        end.
        run  layouth_create-layout-elem-rule_h  in this-procedure (
                                                        input (if new(buf_layout-elem-rule)
                                                               then {&add-def}
                                                               else {&update})
                                                      ,input buf_tt-layout-elem-rule.layout-id
                                                      ,input buf_tt-layout-elem-rule.mode-id
                                                      ,input buf_tt-layout-elem-rule.widget-id
                                                      ,buffer buf_layout-elem-rule
                                                      ,input v-chip-num).
        buffer-copy buf_tt-layout-elem-rule to buf_layout-elem-rule.
      end.
      for each buf_tt-rule-by-call where
             buf_tt-rule-by-call.call_id = buf_tt-layout-elem-rule.uniq-key-rec
      on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
      on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile ):
        v-cmp = yes.
        find first buf_rule-by-call where
                 buf_rule-by-call.call_id = buf_tt-rule-by-call.call_id
            and  buf_rule-by-call.codex_id = buf_tt-rule-by-call.codex_id
            and  buf_rule-by-call.ruleset_id = buf_tt-rule-by-call.ruleset_id
            and  buf_rule-by-call.order_id = buf_tt-rule-by-call.order_id no-error.
       if not available buf_rule-by-call then do:
         create buf_rule-by-call.
         v-cmp = no.
       end.
       else do:
         buffer-compare buf_tt-rule-by-call to buf_rule-by-call case-sensitive save result in v-cmp.
       end.
       if not v-cmp then do:
          buffer-copy buf_tt-rule-by-call to buf_rule-by-call.
        end. /*if not v-cmp then do:*/
      end. /*for each buf_tt-rule-by-call where*/
      for each buf_tt-rule-call-param where
             buf_tt-rule-call-param.call_id = buf_tt-layout-elem-rule.uniq-key-rec
      on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
      on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile ):
        v-cmp = yes.
        find first buf_rule-call-param where
                 buf_rule-call-param.call_id = buf_tt-rule-call-param.call_id
            and  buf_rule-call-param.codex_id = buf_tt-rule-call-param.codex_id
            and  buf_rule-call-param.ruleset_id = buf_tt-rule-call-param.ruleset_id
            and  buf_rule-call-param.order_id = buf_tt-rule-call-param.order_id
            and  buf_rule-call-param.param-name = buf_tt-rule-call-param.param-name
            and  buf_rule-call-param.p-index = buf_tt-rule-call-param.p-index no-error.
       if not available buf_rule-call-param then do:
         create buf_rule-call-param.
         v-cmp = no.
       end.
       else do:
         buffer-compare buf_tt-rule-call-param to buf_rule-call-param case-sensitive save result in v-cmp.
       end.
       if not v-cmp then do:
          if v-chip-num < 0 then do:
            run  layouth_create-layout_h  in this-procedure (
                                                            input (if new(buf_layout) then {&add-def} else {&update})
                                                          ,input buf_tt-layout.layout-id
                                                          ,buffer buf_layout
                                                          ,output v-chip-num).
          end.
          run  layouth_create-rule-call-param_h  in this-procedure (
                                                          input (if new(buf_rule-call-param)
                                                                then {&add-def}
                                                                else {&update})
                                                        ,input buf_tt-rule-call-param.call#_id
                                                        ,input buf_tt-rule-call-param.codex_id
                                                        ,input buf_tt-rule-call-param.ruleset_id
                                                        ,input buf_tt-rule-call-param.order_id
                                                        ,input buf_tt-rule-call-param.param-name
                                                        ,input buf_tt-rule-call-param.p-index
                                                        ,input buf_tt-rule-call-param.call_id
                                                        ,buffer buf_rule-call-param
                                                        ,input v-chip-num).
          buffer-copy buf_tt-rule-call-param to buf_rule-call-param.
        end. /*if not v-cmp then do:*/
      end. /*for each buf_tt-rule-call-param where*/
      for each buf_rule-call-param where
             buf_rule-call-param.call_id = buf_tt-layout-elem-rule.uniq-key-rec
      on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
      on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile ):
        find first buf_tt-rule-call-param where
                 buf_tt-rule-call-param.call_id = buf_rule-call-param.call_id
            and  buf_tt-rule-call-param.codex_id = buf_rule-call-param.codex_id
            and  buf_tt-rule-call-param.ruleset_id = buf_rule-call-param.ruleset_id
            and  buf_tt-rule-call-param.order_id = buf_rule-call-param.order_id
            and  buf_tt-rule-call-param.param-name = buf_rule-call-param.param-name
            and  buf_tt-rule-call-param.p-index = buf_rule-call-param.p-index no-error.
        if not available buf_tt-rule-call-param then do:
          if v-chip-num < 0 then do:
            run  layouth_create-layout_h  in this-procedure (
                                                            input (if new(buf_layout) then {&add-def} else {&update})
                                                          ,input buf_tt-layout.layout-id
                                                          ,buffer buf_layout
                                                          ,output v-chip-num).
          end.
          run  layouth_create-rule-call-param_h  in this-procedure (
                                                          input {&deletion}
                                                        ,input buf_rule-call-param.call#_id
                                                        ,input buf_rule-call-param.codex_id
                                                        ,input buf_rule-call-param.ruleset_id
                                                        ,input buf_rule-call-param.order_id
                                                        ,input buf_rule-call-param.param-name
                                                        ,input buf_rule-call-param.p-index
                                                        ,input buf_rule-call-param.call_id
                                                        ,buffer buf_rule-call-param
                                                        ,input v-chip-num).

        end.
      end.
    end.
    for each buf_layout-elem-rule where
            buf_layout-elem-rule.layout-id = buf_tt-layout.layout-id
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile ):
      find first buf_tt-layout-elem-rule where
                buf_tt-layout-elem-rule.layout-id = buf_layout.layout-id
            and buf_tt-layout-elem-rule.mode-id = buf_layout-elem-rule.mode-id
            and buf_tt-layout-elem-rule.widget-id = buf_layout-elem-rule.widget-id no-error.
      if not available buf_tt-layout-elem-rule then do:
        if v-chip-num < 0 then do:
          run  layouth_create-layout_h  in this-procedure (
                                                          input (if new(buf_layout) then {&add-def} else {&update})
                                                        ,input buf_tt-layout.layout-id
                                                        ,buffer buf_layout
                                                        ,output v-chip-num).
        end.
        run  layouth_create-layout-elem-rule_h  in this-procedure (
                                                        input {&deletion}
                                                      ,input buf_layout-elem-rule.layout-id
                                                      ,input buf_layout-elem-rule.mode-id
                                                      ,input buf_layout-elem-rule.widget-id
                                                      ,buffer buf_layout-elem-rule
                                                      ,input v-chip-num).
        for each buf_rule-by-call where
             buf_rule-by-call.call_id = buf_layout-elem-rule.uniq-key-rec
        on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
        on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
        on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile ):
           delete buf_rule-by-call.
        end.
        for each buf_rule-call-param where
              buf_rule-call-param.call_id = buf_layout-elem-rule.uniq-key-rec
        on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
        on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
        on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile ):
          if v-chip-num < 0 then do:
            run  layouth_create-layout_h  in this-procedure (
                                                            input (if new(buf_layout) then {&add-def} else {&update})
                                                          ,input buf_tt-layout.layout-id
                                                          ,buffer buf_layout
                                                          ,output v-chip-num).
          end.
          run  layouth_create-rule-call-param_h  in this-procedure (
                                                          input {&deletion}
                                                        ,input buf_rule-call-param.call#_id
                                                        ,input buf_rule-call-param.codex_id
                                                        ,input buf_rule-call-param.ruleset_id
                                                        ,input buf_rule-call-param.order_id
                                                        ,input buf_rule-call-param.param-name
                                                        ,input buf_rule-call-param.p-index
                                                        ,input buf_rule-call-param.call_id
                                                        ,buffer buf_rule-call-param
                                                        ,input v-chip-num).
           delete buf_rule-call-param.
        end.
        delete buf_layout-elem-rule.
      end.
    end. /*    for each buf_layout-elem-rule where*/
    if buf_tt-layout.is-default = integer({&layout-mandatory}) then do:
      for each buf2_layout no-lock where
              buf2_layout.layout-type = buf_tt-layout.layout-type
          and buf2_layout.device-type = buf_tt-layout.device-type:
        if buf2_layout.layout-id = buf_tt-layout.layout-id then next .
        for each buf_tt-layout-elem-rule where
                buf_tt-layout-elem-rule.layout-id = buf_tt-layout.layout-id
        on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
        on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
        on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
        :

          find first buf2_layout-elem-rule no-lock where
                buf2_layout-elem-rule.layout-id = buf2_layout.layout-id
             and buf2_layout-elem-rule.mode-id = buf_tt-layout-elem-rule.mode-id
             and buf2_layout-elem-rule.widget-id = buf_tt-layout-elem-rule.widget-id no-error.
          if not available buf2_layout-elem-rule
          or (available (buf2_layout-elem-rule)
             and
             buf2_layout-elem-rule.rule_id <> buf_tt-layout-elem-rule.rule_id) then do:
             run  layouth_create-layout_h  in this-procedure (
                                                           input {&update}
                                                          ,input buf2_layout.layout-id
                                                          ,buffer buf2_layout
                                                          ,output v-chip-num).
            if available buf2_layout-elem-rule then do:
              find current buf2_layout-elem-rule share-lock.
              run  layouth_create-layout-elem-rule_h  in this-procedure (
                                                              input {&update}
                                                            ,input buf2_layout-elem-rule.layout-id
                                                            ,input buf2_layout-elem-rule.mode-id
                                                            ,input buf2_layout-elem-rule.widget-id
                                                            ,buffer buf2_layout-elem-rule
                                                            ,input v-chip-num).
              assign
              buf2_layout-elem-rule.sts = integer({&deleted-status-int}).
              find first buf3_layout share-lock where recid(buf3_layout) = recid(buf2_layout) no-error.
              if available buf3_layout then do:
                if buf3_layout.sts <> integer({&to-delete-status-int}) then
                buf3_layout.sts = integer({&blocked-status-int})
                .
              end.
            end. /*if available buf2_layout-elem-rule then d*/
            else do:
              run  layouth_create-layout-elem-rule_h  in this-procedure (
                                                              input {&add-def}
                                                            ,input buf2_layout.layout-id
                                                            ,input buf_tt-layout-elem-rule.mode-id
                                                            ,input buf_tt-layout-elem-rule.widget-id
                                                            ,buffer buf2_layout-elem-rule
                                                            ,input v-chip-num).
              create buf2_layout-elem-rule.
              buffer-copy buf_tt-layout-elem-rule
              except layout-id
              to buf2_layout-elem-rule
              assign
              buf2_layout-elem-rule.layout-id = buf2_layout.layout-id
              buf2_layout-elem-rule.is-mandatory = integer({&layout-elem-rule-mandatory})
              .
              run gen-key-rec in this-procedure ( input {&table_layout-elem-rule}
                                                  ,input (buffer  buf2_layout-elem-rule:handle)
                                                  ,output v-ler-uniq-key-rec).
              buf2_layout-elem-rule.uniq-key-rec = v-ler-uniq-key-rec.
              find first buf_wi-mode no-lock where
                        buf_wi-mode.mode-type = {&wi-mode-IBS-TH-pos}
                    and buf_wi-mode.mode-id  = buf2_layout-elem-rule.mode-id.
              find first buf_rule-by-call share-lock where
                        buf_rule-by-call.call_id = buf2_layout-elem-rule.uniq-key-rec
                    and buf_rule-by-call.codex_id = buf_wi-mode.codex_id
                    and buf_rule-by-call.ruleset_id = buf_wi-mode.ruleset_id
                    and buf_rule-by-call.order_id = 0 no-error.
              if not available buf_rule-by-call then do:
                run rul/g-callid.p (
                                    input (if buf2_layout.is-default = integer({&layout-ordinal})
                                            then {&table_layout-elem-rule}
                                            else {&table_layout-elem-rule} + {&comma-char} + "minus")
                                    ,input buf2_layout-elem-rule.uniq-key-rec
                                    ,output v-call#-id).
                create buf_rule-by-call.
                assign
                buf_rule-by-call.call_id = buf2_layout-elem-rule.uniq-key-rec
                buf_rule-by-call.call#_id = v-call#-id
                buf_rule-by-call.codex_id = buf_wi-mode.codex_id
                buf_rule-by-call.ruleset_id = buf_wi-mode.ruleset_id
                buf_rule-by-call.order_id = 0
                .
                run gen-key-rec in this-procedure ( input {&table_rule-by-call}
                                                    ,input (buffer  buf_rule-by-call:handle)
                                                    ,output v-rbc-uniq-key-rec).
                buf_rule-by-call.uniq-key-rec = v-rbc-uniq-key-rec.
                .
              end.
            end.
          end. /*if not available buf2_layout-elem-rule*/
        end. /*        for each buf_tt-layout-elem-rule where*/
      end. /*      for each buf2_layout share-lock where*/
    end. /* if buf_tt-layout.is-default = integer({&layout-mandatory}) then do:*/
  end. /*for each buf_tt-layout where buf_tt-layout.is-default = integer({&layout-default})*/
end. /*doe */

end procedure. /* add-layout */

procedure add-wi-mode:
define variable v-cmp as logical   no-undo .
define buffer buf_tt-wi-mode for tt-wi-mode.
define buffer buf_wi-mode for ub.wi-mode.


main-block:
do
on error undo, return error return-value
:


  for each buf_tt-wi-mode
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    v-cmp = no.
    find first buf_wi-mode where
             buf_wi-mode.mode-type = buf_tt-wi-mode.mode-type
         and buf_wi-mode.mode-id = buf_tt-wi-mode.mode-id  no-error .
    if not available buf_wi-mode then do:
      create buf_wi-mode.
      v-cmp = no.
    end.
    else do:
      buffer-compare buf_tt-wi-mode to buf_wi-mode save result in v-cmp.
    end.
    if not v-cmp then do:
      buffer-copy buf_tt-wi-mode to buf_wi-mode.
    end.
  end.
end.

end procedure. /* add-wi-mode */


procedure delete-wi-mode :
define variable v-chip-num as integer   no-undo .
define buffer buf_tt-wi-mode for tt-wi-mode.
define buffer buf_wi-mode for ub.wi-mode.
define buffer buf_layout-elem-rule for ub.layout-elem-rule.
define buffer buf2_layout-elem-rule for ub.layout-elem-rule.
define buffer buf_layout for ub.layout.

main-block:
do
on error undo, return error
:
  for each buf_wi-mode share-lock
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    find first buf_tt-wi-mode where
              buf_tt-wi-mode.mode-type = buf_wi-mode.mode-type
          and buf_tt-wi-mode.mode-id = buf_wi-mode.mode-id no-error.
    if not available buf_tt-wi-mode
    and buf_wi-mode.mode-type = {&wi-mode-IBS-TH-pos}
    then do:
       for each buf_layout-elem-rule no-lock where
                buf_layout-elem-rule.mode-id = buf_wi-mode.mode-id
        on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
        on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
        on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
       :
           v-chip-num = -1.
          find first buf_layout share-lock where
                buf_layout.layout-id = buf_layout-elem-rule.layout-id no-error.
          if available buf_layout
          then do:
            /*wrtie-to-log*/
             run  layouth_create-layout_h  in this-procedure (
                                                           input {&update}
                                                          ,input buf_layout.layout-id
                                                          ,buffer buf_layout
                                                          ,output v-chip-num).
            if buf_layout.sts <> integer({&to-delete-status-int}) then
            assign
            buf_layout.sts = integer({&blocked-status-int})
            .
          end.
          find first buf2_layout-elem-rule exclusive-lock where
                  recid(buf2_layout-elem-rule) = recid(buf_layout-elem-rule).
           if v-chip-num >= 0 then
           run  layouth_create-layout-elem-rule_h  in this-procedure (
                                                            input {&update}
                                                          ,input buf2_layout-elem-rule.layout-id
                                                          ,input buf2_layout-elem-rule.mode-id
                                                          ,input buf2_layout-elem-rule.widget-id
                                                          ,buffer buf2_layout-elem-rule
                                                          ,input v-chip-num).

          assign
          buf2_layout-elem-rule.sts = integer({&deleted-status-int})
          .
       end.
       delete buf_wi-mode.
    end.
  end.
end.

end procedure. /* delete-wi-mode */

procedure delete-rule-by-set :
define buffer buf_tt-rule-by-set for tt-rule-by-set.
define buffer buf_rule-by-set for ub.rule-by-set.

main-block:
do
on error undo, return error
:
  for each buf_rule-by-set share-lock
  where buf_rule-by-set.codex_id = 19
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    find first buf_tt-rule-by-set where
              buf_tt-rule-by-set.codex_id = buf_rule-by-set.codex_id
          and buf_tt-rule-by-set.ruleset_id = buf_rule-by-set.ruleset_id
          and buf_tt-rule-by-set.rule_id = buf_rule-by-set.rule_id
          no-error.
    if not available buf_tt-rule-by-set
    and buf_rule-by-set.codex_id = 19
    then do:
      delete buf_rule-by-set.
    end.
  end. /*for each buf_rule-by-set share-lock*/
end. /*doe*/

end procedure. /* delete-rule-by-set */