block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Закачка конфигурации RUM

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/12/07
Author: Bakhtadze Natalya
Creation date: 09/12/07

*/

define input parameter p-forced as logical no-undo .
define input parameter p-read-only as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Закачка конфигурации RUM".
{ cmp/vssrevis.i }

{ cmp/trg-def.i  }  /* не убирать, иначе будет вызываться отовсюду, и СПН не сработает */
{ gbl/cur-time.i }
{ gbl/waitfram.i }
{ gbl/rumconf.i }
{ gbl/key-rec.i }
define stream imp-stream.
{ utl/upgimptt.i def "new shared" }

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

&global-define table-name ruleset
{&create-static-table}.

&global-define table-name prop-head
{&create-static-table}.

&global-define table-name prop-ruleset
{&create-static-table}.

&global-define table-name prop-map
{&create-static-table}.

&global-define table-name prop-script
{&create-static-table}.

&global-define table-name pscript-ruleset
{&create-static-table}.

&global-define table-name rule-profile
{&create-static-table}.

&global-define table-name rule-by-profile
{&create-static-table}.

&global-define table-name ruledict
{&create-static-table}.

&global-define table-name ruledict-param
{&create-static-table}.

&global-define table-name rule
{&create-static-table}.

&global-define table-name rule-script
{&create-static-table}.

&global-define table-name rule-i-script
{&create-static-table}.

&global-define table-name rule-by-set
{&create-static-table}.

&global-define table-name prop-ref
{&create-static-table}.

&global-define table-name rp-rule-param
{&create-static-table}.

&global-define table-name rule-process
{&create-static-table}.

define buffer buf_tt-ruledict for tt-ruledict.

/*
&glob display-message  run write-log-and-file in p-log-handle ( ~
          input 1 ~
        , input log-file-name ~
        , input 1 ~
        , input ~{&my-message~} ~
                                      )

*/
&glob display-message  message ~{&my-message~} view-as alert-box



run waitfram-show in this-procedure ("Реинициализация конфигурации RUM").
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if ( g#db-num > 0 ) then return.
  if not p-forced then do:
    run check-rum-version in this-procedure (output v-check1).
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
       input  "cmp/fixrum.txt"     /* p-file-name     */
      ,output v-md5-signature /* p-md5-signature */
      ) .
    if v-md5-signature <> "{&rum-md5}" then do:
      message
      substitute("Несовпадение файла эталонных записей по конфигурации RUM (fixrum.txt) с контрольным числом")
      view-as alert-box error .
      undo, return error .
    end.
    run gbl/filename.p ( input "cmp/fixrum.txt"
                        ,output v-full-path
                        ,output v-path
                        ,output v-file-name
                        ,output v-file-name-no-ext
                        ,output v-file-name-ext
                        ) no-error .
    if error-status:error then do:
      message
      substitute("Не найден файл эталонных записей по конфигурации RUM (fixrum.txt)")
      view-as alert-box error .
      undo, return error .
    end.
    run str/diallog.w (
          input ? /*parparentproc*/
        ,input this-procedure
        ,input ('utl/upg-imp.p' + {&delim-par}  +
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
      substitute("Ошибка при чтении файла эталонных записей по конфигурации RUM (fixrum.txt)&1&2&1&3"
                   , {&new-line}
                   , error-status:get-message(1)
                   , return-value )
      view-as alert-box error .
      undo, return error .
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
    define buffer buf_rule for ub.rule.
    find last buf_rule no-lock use-index pi.
    if current-value(s-rule-id, {&db-name_schema}) < buf_rule.rule_Id then do:
      current-value(s-rule-id, {&db-name_schema}) = buf_rule.rule_Id.
    end.
    define buffer buf_rule-script for ub.rule-script.
    find last buf_rule-script no-lock use-index pi.
    if current-value(s-rule-script-id, {&db-name_schema}) < buf_rule-script.script_Id then do:
      current-value(s-rule-script-id, {&db-name_schema}) = buf_rule-script.script_Id.
    end.
    define variable v-rule-profile-uniq-key-rec as character no-undo .
    define variable v-mess as character no-undo .
    define buffer buf_rule-profile for ub.rule-profile.
    define buffer buf_ruledict for ub.ruledict.
    define buffer buf_ruledict-param for ub.ruledict-param.
    for each buf_rule-profile no-lock
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
      run gen-key-rec in this-procedure (
                                        input  {&table_rule-profile}
                                        ,input buffer buf_rule-profile:handle
                                        ,output v-rule-profile-uniq-key-rec).
      for first buf_ruledict no-lock where
              buf_ruledict.uniq-key-rec = v-rule-profile-uniq-key-rec,
          each buf_ruledict-param no-lock where
              buf_ruledict-param.entry-id = buf_ruledict.entry-id
      on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
      on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile ):
        if buf_ruledict-param.param-data-type = {&abl-datatype-character}
        and buf_ruledict-param.param-2-data-type = "xsd"
        then do:
          run rul/rdp-clob.p ( buffer buf_ruledict-param
                              ,input  {&update}) no-error.
          if error-status:error then  do:
            &scop my-message     substitute("Не удалось сохранить CLOB &1:&2&3&2&4" ~
                                ,buf_ruledict-param.init-value-character ~
                                ,~{&new-line~} ~
                                , error-status:get-message(1) ~
                                , return-value )
            {&display-message}.
            undo, return error .
          end.
        end.
      end.
    end.
  end.
end. /*doe*/

run waitfram-hide in this-procedure .

/*возвращает order  вызова правила для конкректного call беря параметрами rule-by-profile*/
function get-order-id returns integer ( input p-profile-id as integer
                                       ,input p-codex-id as integer
                                       ,input p-ruleset-id as integer
                                       ,input p-rp-order-id as integer
                                       ,input p-call-id as character
                                       ,input p-once-more as integer
                                       ):
define variable v-ii as integer   no-undo .
define buffer buf_rule-by-call for ub.rule-by-call.
for each buf_rule-by-call no-lock where
        buf_rule-by-call.call_id = p-call-id
    and buf_rule-by-call.codex_id = p-codex-id
    and buf_rule-by-call.ruleset_id = p-ruleset-id
    and buf_rule-by-call.once-more = p-once-more
    and buf_rule-by-call.profile_id = p-profile-id
    :
    if v-ii = p-rp-order-id then do:
       return buf_rule-by-call.order_id.
    end.
    v-ii = v-ii + 1.
end.
return -1.
end.


procedure ruledict-param_add :
define input parameter p-bh as handle no-undo .
  run ruledict-param_add-update in this-procedure ( input p-bh, input p-bh:rowid) no-error.
  if error-status :error then undo, return error return-value .
end.

procedure ruledict-param_update :
define input parameter p-bh-old as handle no-undo .
define input parameter p-bh-new-temp as handle no-undo .
  run ruledict-param_add-update in this-procedure ( input p-bh-new-temp, input p-bh-old:rowid) no-error.
  if error-status :error then undo, return error return-value .

end.


procedure ruledict-param_add-update :
define input parameter p-bh as handle no-undo .
define input parameter p-rowid as rowid no-undo .
define buffer buf_ruledict-param for ub.ruledict-param.
define buffer buf_ruledict for ub.ruledict.

  do
  on error undo, return error
  :
    find first buf_ruledict-param where
              rowid(buf_ruledict-param) = p-rowid.
    if p-bh::param-data-type = {&abl-datatype-character}
    and p-bh::param-2-data-type = "xsd"
    then do:
      find first buf_ruledict no-lock where
                buf_ruledict.entry-id = buf_ruledict-param.entry-id  no-error.
      if available buf_ruledict
      and buf_ruledict.entry-type = {&rdict-etype-rule-profile} then do:
        run rul/rdp-clob.p ( buffer buf_ruledict-param
                            ,input (if new(buf_ruledict-param) then {&add-def} else {&update})) no-error.
        if error-status:error then  do:
          &scop my-message     substitute("Не удалось сохранить CLOB &1:&2&3&2&4" ~
                              ,p-bh::init-value-character ~
                              ,~{&new-line~} ~
                              , error-status:get-message(1) ~
                              , return-value )
          {&display-message}.
          undo, return error .
        end.
      end.
    end.
  end.

end procedure. /* ruledict-param_add-update */

procedure ruledict-param_delete :
define input parameter p-bh as handle no-undo .
define buffer buf_ruledict-param for ub.ruledict-param.

  do
  on error undo, return error
  :
    find first buf_ruledict-param where
              rowid(buf_ruledict-param) = p-bh:rowid.
    if buf_ruledict-param.param-data-type = {&abl-datatype-character}
    and buf_ruledict-param.param-2-data-type = "xsd"
    then do:
      run rul/rdp-clob.p ( buffer buf_ruledict-param
                          ,input  {&deletion})) no-error.
      if error-status:error then  do:
        &scop my-message     substitute("Не удалось сохранить CLOB &1:&2&3&2&4" ~
                            ,buf_ruledict-param.init-value-character ~
                            ,~{&new-line~} ~
                            , error-status:get-message(1) ~
                            , return-value )
        {&display-message}.
        undo, return error .
      end.
    end.
  end.

end procedure. /* ruledict-param_delete */


procedure rp-rule-param_add :
define input parameter p-bh as handle no-undo .
define variable v-rule-profile-uniq-key-rec as character no-undo .
define variable v-curr-r-b as character no-undo .
define variable v-order-id as integer   no-undo .
define variable v-order-id2 as integer   no-undo .
define buffer buf_rp-rule-param for ub.rp-rule-param.
define buffer buf2_rp-rule-param for ub.rp-rule-param.
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf2_rule-call-param for ub.rule-call-param.
define buffer buf_rule-profile for ub.rule-profile.
define buffer buf_ruledict for ub.ruledict.
define buffer buf2_ruledict for ub.ruledict.
define buffer buf_ruledict2 for ub.ruledict.
define buffer buf_ruledict-param for ub.ruledict-param.
define buffer buf2_ruledict-param for ub.ruledict-param.
define buffer buf_ruledict-param2 for ub.ruledict-param.
define buffer buf_rule-by-call for ub.rule-by-call.
define buffer buf2_rule-by-call for ub.rule-by-call.
define buffer buf_rp-by-call for ub.rp-by-call.
define buffer buf_rule for ub.rule.
define buffer buf2_rule for ub.rule.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  find first buf_rp-rule-param where
            rowid(buf_rp-rule-param) = p-bh:rowid.
  find first buf_rule-profile where buf_rule-profile.profile_id = buf_rp-rule-param.profile_id.
  run gen-key-rec in this-procedure (
                                    input  {&table_rule-profile}
                                    ,input buffer buf_rule-profile:handle
                                    ,output v-rule-profile-uniq-key-rec).
  find first buf_ruledict2 no-lock where
          buf_ruledict2.entry-type = {&rdict-etype-rule-profile}
      and  buf_ruledict2.uniq-key-rec = v-rule-profile-uniq-key-rec.
  find first buf_ruledict-param2 no-lock where
        buf_ruledict-param2.entry-id = buf_ruledict2.entry-id
    and buf_ruledict-param2.param-name = buf_rp-rule-param.rp-param-name.


  for each buf_rp-by-call exclusive-lock where
          buf_rp-by-call.profile_id = buf_rp-rule-param.profile_id
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :

    v-order-id = get-order-id ( input buf_rp-rule-param.profile_id
                              ,input buf_rp-rule-param.codex_id
                              ,input buf_rp-rule-param.ruleset_id
                              ,input buf_rp-rule-param.rp_order_id
                              ,input buf_rp-by-call.call_id
                              ,input buf_rp-by-call.once-more
                              ).
    if v-order-id <> -1 then do:
      find first buf_rule-by-call exclusive-lock where
            buf_rule-by-call.call_id = buf_rp-by-call.call_id
        and buf_rule-by-call.codex_id = buf_rp-rule-param.codex_id
        and buf_rule-by-call.ruleset_id = buf_rp-rule-param.ruleset_id
        and buf_rule-by-call.order_id = v-order-id.
      /*надо найти уже имеющийся параметр чтобы из него взять значение*/
      for each buf2_rp-rule-param no-lock where
                buf2_rp-rule-param.profile_id = buf_rp-rule-param.profile_id
            and buf2_rp-rule-param.rp-param-name = buf_rp-rule-param.rp-param-name:
        v-order-id2 = get-order-id ( input buf2_rp-rule-param.profile_id
                                  ,input buf2_rp-rule-param.codex_id
                                  ,input buf2_rp-rule-param.ruleset_id
                                  ,input buf2_rp-rule-param.rp_order_id
                                  ,input buf_rp-by-call.call_id
                                  ,input buf_rp-by-call.once-more
                                  ).
        find first buf2_rule-by-call exclusive-lock where
              buf2_rule-by-call.call_id = buf_rp-by-call.call_id
          and buf2_rule-by-call.codex_id = buf2_rp-rule-param.codex_id
          and buf2_rule-by-call.ruleset_id = buf2_rp-rule-param.ruleset_id
          and buf2_rule-by-call.order_id = v-order-id2.

        find first buf2_rule no-lock where
                  buf2_rule.rule_id = buf2_rp-rule-param.rule_id.
        find first buf2_ruledict no-lock where
                buf2_ruledict.entry-type = {&rdict-etype-rule}
            and  buf2_ruledict.uniq-key-rec = buf2_rule.uniq-key-rec.
          find first buf2_ruledict-param where
                    buf2_ruledict-param.entry-id = buf2_ruledict.entry-id
                and buf2_ruledict-param.param-name = buf2_rp-rule-param.rule-param-name
                    .
          find first buf2_rule-call-param where
                    buf2_rule-call-param.call_id = buf2_rule-by-call.call_id
                and buf2_rule-call-param.codex_id = buf2_rule-by-call.codex_id
                and buf2_rule-call-param.ruleset_id = buf2_rule-by-call.ruleset_id
                and buf2_rule-call-param.order_id = buf2_rule-by-call.order_id
                and buf2_rule-call-param.param-name = buf2_ruledict-param.param-name no-error.
         if available buf2_rule-call-param then leave.
      end.
      find first buf_rule no-lock where
                buf_rule.rule_id = buf_rule-by-call.rule_id.
      find first buf_ruledict no-lock where
              buf_ruledict.entry-type = {&rdict-etype-rule}
          and  buf_ruledict.uniq-key-rec = buf_rule.uniq-key-rec.
        find first buf_ruledict-param where
                  buf_ruledict-param.entry-id = buf_ruledict.entry-id
              and buf_ruledict-param.param-name = buf_rp-rule-param.rule-param-name
                  .
        find first buf_rule-call-param where
                  buf_rule-call-param.call_id = buf_rule-by-call.call_id
              and buf_rule-call-param.codex_id = buf_rule-by-call.codex_id
              and buf_rule-call-param.ruleset_id = buf_rule-by-call.ruleset_id
              and buf_rule-call-param.order_id = buf_rule-by-call.order_id
              and buf_rule-call-param.param-name = buf_ruledict-param.param-name no-error.
        if not available buf_rule-call-param then do:
          create buf_rule-call-param.
          assign
          buf_rule-call-param.call#_id = buf_rule-by-call.call#_id
          buf_rule-call-param.call_id = buf_rule-by-call.call_id
          buf_rule-call-param.codex_id = buf_rule-by-call.codex_id
          buf_rule-call-param.ruleset_id = buf_rule-by-call.ruleset_id
          buf_rule-call-param.order_id = buf_rule-by-call.order_id
          buf_rule-call-param.param-name = buf_ruledict-param.param-name
          .
        end.
        assign
        buf_rule-call-param.rule_id = buf_rule-by-call.rule_id
        buf_rule-call-param.p-index = 0
        buf_rule-call-param.param-des = buf_ruledict-param.documentation
        buf_rule-call-param.param-num = buf_ruledict-param.param-num
        buf_rule-call-param.param-label = buf_ruledict-param.param-label
        buf_rule-call-param.param-mode = buf_ruledict-param.param-mode
        buf_rule-call-param.param-data-type = buf_ruledict-param.param-data-type
        buf_rule-call-param.param-2-data-type = buf_ruledict-param.param-2-data-type
        buf_rule-call-param.param-3-data-type = buf_ruledict-param.param-3-data-type
        buf_rule-call-param.param-value-character = buf_ruledict-param2.init-value-character
        buf_rule-call-param.param-value-date = buf_ruledict-param2.init-value-date
        buf_rule-call-param.param-value-decimal = buf_ruledict-param2.init-value-decimal
        buf_rule-call-param.param-value-integer = buf_ruledict-param2.init-value-integer
        buf_rule-call-param.param-value-logical = buf_ruledict-param2.init-value-logical
        buf_rule-call-param.profile_id          = buf_rule-by-call.profile_id
        buf_rule-call-param.once-more           = buf_rule-by-call.once-more
        .
        if available buf2_rule-call-param then do:
          assign
          buf_rule-call-param.param-value-character = buf2_rule-call-param.param-value-character
          buf_rule-call-param.param-value-date      = buf2_rule-call-param.param-value-date
          buf_rule-call-param.param-value-decimal   = buf2_rule-call-param.param-value-decimal
          buf_rule-call-param.param-value-integer   = buf2_rule-call-param.param-value-integer
          buf_rule-call-param.param-value-logical   = buf2_rule-call-param.param-value-logical
          .
        end.
        { gbl/curr-r-b.i v-curr-r-b }
      if buf_ruledict-param.param-2-data-type = "r-b" then do:
        buf_rule-call-param.param-value-character = (if v-curr-r-b = {&r-b-rubl}
                                                        then {&r-b-rubl}
                                                        else {&r-b-base}).

      end.
      if available buf_rule-call-param then do:
        run str/callnews.p
          (input {&table_rule-call-param}
          ,input (buffer buf_rule-call-param:handle)
          ) no-error .
        if error-status:error then do:
            &scop my-message     substitute("Не удалось сохранить rule-call-param&1:&2&1&3" ~
                                ,~{&new-line~} ~
                                , error-status:get-message(1) ~
                                , return-value )
            {&display-message}.
          undo main-block, return error .
        end.
      end.
    end. /*if v-order-id <> -1 then do:*/
  end.
end.

end procedure. /* rp-rule-param_add-update */

procedure rp-rule-param_delete :
define input parameter p-bh as handle no-undo .
define variable v-order-id as integer   no-undo .
define buffer buf_rp-rule-param for ub.rp-rule-param.
define buffer buf_rp-by-call for ub.rp-by-call.
define buffer buf_rule-call-param for ub.rule-call-param.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  find first buf_rp-rule-param where
            rowid(buf_rp-rule-param) = p-bh:rowid.

  for each buf_rp-by-call exclusive-lock where
          buf_rp-by-call.profile_id = buf_rp-rule-param.profile_id
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :

    v-order-id = get-order-id ( input buf_rp-rule-param.profile_id
                              ,input buf_rp-rule-param.codex_id
                              ,input buf_rp-rule-param.ruleset_id
                              ,input buf_rp-rule-param.rp_order_id
                              ,input buf_rp-by-call.call_id
                              ,input buf_rp-by-call.once-more
                              ).
   if v-order-id <> -1 then do:
     for each buf_rule-call-param exclusive-lock where
          buf_rule-call-param.call_id = buf_rp-by-call.call_id
      and buf_rule-call-param.codex_id = buf_rp-rule-param.codex_id
      and buf_rule-call-param.ruleset_id = buf_rp-rule-param.ruleset_id
      and buf_rule-call-param.order_id = v-order-id
      and buf_rule-call-param.param-name = buf_rp-rule-param.rule-param-name
      and buf_rule-call-param.rule_id = buf_rp-rule-param.rule_id
      and buf_rule-call-param.profile_id  = buf_rp-rule-param.profile_id
      on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
      on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
      :
        run nws/cmd-del.p
          ( input {&table_rule-call-param}
          ,input (buffer buf_rule-call-param:handle)
          ,input ''
          ) no-error .
        if error-status :error then do:
          if error-status:error then do:
              &scop my-message     substitute("Не удалось удалить rule-call-param&1:&2&1&3" ~
                                  ,~{&new-line~} ~
                                  , error-status:get-message(1) ~
                                  , return-value )
              {&display-message}.
             undo main-block, return error .
          end.
        end.
        delete buf_rule-call-param.
     end.
   end.
  end.
end.
end procedure. /* rp-rule-param_delete */


procedure rule-by-profile_update :
define input parameter p-bh-old as handle no-undo .
define input parameter p-bh-new-temp as handle no-undo .
define variable v-order-id as integer   no-undo .
define buffer buf_rule-by-call for ub.rule-by-call.
define buffer buf_rp-by-call for ub.rp-by-call.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  if p-bh-old::is_dynamic <> p-bh-new-temp::is_dynamic
  and p-bh-old::codex_id = p-bh-new-temp::codex_id
  and p-bh-old::ruleset_id = p-bh-new-temp::ruleset_id
  and p-bh-old::profile_id = p-bh-new-temp::profile_id
  and p-bh-old::rule_id = p-bh-new-temp::rule_id
  and p-bh-old::rp_order_id = p-bh-new-temp::rp_order_id then do:
    for each buf_rp-by-call share-lock where
            buf_rp-by-call.profile_id = p-bh-old::profile_id
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
      v-order-id = get-order-id ( input p-bh-old::profile_id
                                ,input p-bh-old::codex_id
                                ,input p-bh-old::ruleset_id
                                ,input p-bh-old::rp_order_id
                                ,input buf_rp-by-call.call_id
                                ,input buf_rp-by-call.once-more
                                ).
      if v-order-id <> -1 then do:
        find first buf_rule-by-call share-lock where
            buf_rule-by-call.call_id = buf_rp-by-call.call_id
        and buf_rule-by-call.profile_id = p-bh-old::profile_id
        and buf_rule-by-call.codex_id = p-bh-old::codex_id
        and buf_rule-by-call.ruleset_id = p-bh-old::ruleset_id
        and buf_rule-by-call.rule_id = p-bh-old::rule_id
        and buf_rule-by-call.order_id = v-order-id no-error.
        if available buf_rule-by-call then do:
          if p-bh-old::is_dynamic = yes then do:
            /**/
            assign
            buf_rule-by-call.can-calc = yes
            buf_rule-by-call.can-run = yes
            .
          end.
          if p-bh-old::is_dynamic = no
          and p-bh-new-temp::is_dynamic = yes
          then do:
            /**/
            assign
            buf_rule-by-call.is_dynamic = yes
            .
          end.
          run str/callnews.p
            (input {&table_rule-by-call}
            ,input (buffer buf_rule-by-call:handle)
            ) no-error .
          if error-status:error then do:
            &scop my-message     substitute("Не удалось сохранить rule-by-call-param&1:&2&1&3" ~
                                ,~{&new-line~} ~
                                , error-status:get-message(1) ~
                                , return-value )
            {&display-message}.
            undo main-block, return error .
        end.
      end.
    end.
    end. /*for each buf_rp-by-call share-lock where*/
  end.
end.
end procedure.



procedure rule-by-profile_add :
define input parameter p-bh as handle no-undo .

define variable v-order-id as integer no-undo .
define variable v-exist as logical   no-undo .
define variable v-rule-by-call-uniq-key-rec as character no-undo .
define buffer buf_rule-by-profile for ub.rule-by-profile.
define buffer buf_rp-by-call for ub.rp-by-call.
define buffer buf_rule-by-call for ub.rule-by-call.
define buffer buf_rule-profile for ub.rule-profile.
define buffer bufo_rule-by-profile  for ub.rule-by-profile .
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_rule for ub.rule.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  find first buf_rule-by-profile where
            rowid(buf_rule-by-profile) = p-bh:rowid.
  find first buf_rule-profile where
            buf_rule-profile.profile_id = buf_rule-by-profile.profile_id.
  for each buf_rp-by-call exclusive-lock where
          buf_rp-by-call.profile_id = buf_rule-by-profile.profile_id
  break
  by buf_rp-by-call.call_id
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    v-exist = no.
    find first bufo_rule-by-profile no-lock where
              bufo_rule-by-profile.profile_id = buf_rule-by-profile.profile_id
          and bufo_rule-by-profile.codex_id = buf_rule-by-profile.codex_id
          and bufo_rule-by-profile.ruleset_id = buf_rule-by-profile.ruleset_id
          and bufo_rule-by-profile.rp_order_id = buf_rule-by-profile.rp_order_id no-error.
    if available bufo_rule-by-profile  and
    bufo_rule-by-profile.rule_id <> buf_rule-by-profile.rule_id then do:

      v-order-id = get-order-id ( input buf_rp-by-call.profile_id
                                ,input buf_rule-by-profile.codex_id
                                ,input buf_rule-by-profile.ruleset_id
                                ,input buf_rule-by-profile.rp_order_id
                                ,input buf_rp-by-call.call_id
                                ,input buf_rp-by-call.once-more
                                ).
      if v-order-id <> -1 then do:
        find first buf_rule-by-call where
                  buf_rule-by-call.call_id = buf_rp-by-call.call_id
              and buf_rule-by-call.profile_id = buf_rule-by-profile.profile_id
              and buf_rule-by-call.once-more = buf_rp-by-call.once-more
              and buf_rule-by-call.codex_id = buf_rule-by-profile.codex_id
              and buf_rule-by-call.ruleset_id  = buf_rule-by-profile.ruleset_id
              and buf_rule-by-call.order_id = v-order-id
              and buf_rule-by-call.rule_id = bufo_rule-by-profile.rule_id
              no-error.
        if available buf_rule-by-call then do:
          v-exist = yes.
          for each buf_rule-call-param exclusive-lock where
                  buf_rule-call-param.call_id = buf_rule-by-call.call_id
              and buf_rule-call-param.codex_id = buf_rule-by-call.codex_id
              and buf_rule-call-param.ruleset_id = buf_rule-by-call.ruleset_id
              and buf_rule-call-param.order_id = buf_rule-by-call.order_id
          on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
          on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
          on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
          :
            assign
            buf_rule-call-param.rule_id = buf_rule-by-profile.rule_id.
            run str/callnews.p
              (input {&table_rule-call-param}
              ,input (buffer buf_rule-call-param:handle)
              ) no-error .
            if error-status:error then do:
              &scop my-message     substitute("Не удалось сохранить rule-call-param&1:&2&1&3" ~
                                  ,~{&new-line~} ~
                                  , error-status:get-message(1) ~
                                  , return-value )
              {&display-message}.
              undo main-block, return error .
            end.
        end.
      end. /*if available buf_rule-by-call then do:*/
    end. /*if v-order-id <> -1 then do:*/
  end. /*    if available bufo_rule-by-profile  and*/
    if not v-exist then do:
      FIND FIRST buf_rule NO-LOCK WHERE
                    buf_rule.RULE_id = buf_rule-by-profile.RULE_id .
      FIND LAST buf_rule-by-call WHERE
                buf_rule-by-call.codex_id =  buf_rule-by-profile.codex_id
            AND buf_rule-by-call.ruleset_id = buf_rule-by-profile.ruleset_id
      USE-INDEX imain NO-ERROR.
      IF AVAILABLE buf_rule-by-call THEN DO:
        v-order-id = buf_rule-by-call.order_id + 1.
      END.
      ELSE DO:
        v-order-id = 0.
      END.
      CREATE buf_rule-by-call.
      BUFFER-COPY buf_rule-by-profile TO buf_rule-by-call
      ASSIGN
      buf_rule-by-call.order_id = v-order-id
      buf_rule-by-call.algo-des = buf_rule-profile.NAME + {&new-line} + buf_rule.NAME
      buf_rule-by-call.is_dynamic = buf_rule-by-profile.IS_dynamic
      buf_rule-by-call.can-calc = (IF buf_rule-by-call.is_dynamic
                                  THEN  no
                                  ELSE YES)
      buf_rule-by-call.call_id = buf_rp-by-call.call_id
    buf_rule-by-call.call#_id = buf_rp-by-call.call#_id
      buf_rule-by-call.once-more = buf_rp-by-call.once-more
      .
    run gen-key-rec in this-procedure (
                                      input  {&table_rule-by-call}
                                      ,input buffer buf_rule-by-call:handle
                                      ,output v-rule-by-call-uniq-key-rec).

    buf_rule-by-call.uniq-key-rec = v-rule-by-call-uniq-key-rec    .
    run str/callnews.p
      (input {&table_rule-by-call}
      ,input (buffer buf_rule-by-call:handle)
      ) no-error .
    if error-status:error then do:
      &scop my-message     substitute("Не удалось сохранить rule-by-call&1:&2&1&3" ~
                          ,~{&new-line~} ~
                          , error-status:get-message(1) ~
                          , return-value )
      {&display-message}.
      undo main-block, return error .
    end.
    end.
end. /*for each buf_rp-by-call exclusive-lock where*/
end. /*main=-block*/
end procedure. /* rule-by-profile_add */


procedure rule-by-profile_delete :
define input parameter p-bh as handle no-undo .

define variable v-order-id as integer no-undo .
define buffer buf_rule-by-profile for ub.rule-by-profile.
define buffer buf_rule-by-call for ub.rule-by-call.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  find first buf_rule-by-profile where
            rowid(buf_rule-by-profile) = p-bh:rowid.
  for each buf_rule-by-call exclusive-lock where
          buf_rule-by-call.profile_id = buf_rule-by-profile.profile_id
      and buf_rule-by-call.codex_id = buf_rule-by-profile.codex_id
      and buf_rule-by-call.ruleset_id = buf_rule-by-profile.ruleset_id
      and buf_rule-by-call.rule_id = buf_rule-by-profile.rule_id
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    run nws/cmd-del.p
      ( input {&table_rule-by-call}
      ,input (buffer ub.rule-by-call:handle)
      ,input ''
      ) no-error .
    if error-status :error then do:
      &scop my-message     substitute("Не удалось удалить rule-call-param&1:&2&1&3" ~
                          ,~{&new-line~} ~
                          , error-status:get-message(1) ~
                          , return-value )
      {&display-message}.
      undo main-block, return error .
    end.
    delete buf_rule-by-call.
    .
  end.
end.
end procedure. /* rule-by-profile_delete */