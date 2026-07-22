block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Приведение шаблонов скидок и шаблонов расписаний имеющихся в БД

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/16/04
Author: Bakhtadze Natalya
Creation date: 11/16/04

*/

define input parameter p-forced as logical no-undo .
define input parameter p-read-only as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Закачка правил скидок и расписаний".
{ cmp/vssrevis.i }

{ cmp/trg-def.i  }  /* не убирать, иначе будет вызываться отовсюду, и СПН не сработает */
{ trg/factord.i  }
{ gbl/cur-time.i }
{ gbl/waitfram.i }
{ gbl/disrules.i "create" }
{ gbl/distruls.i "create" }
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

&global-define table-name dis-rule
{&create-static-table}.

&global-define table-name dis-cfg-rule
{&create-static-table}.

&global-define table-name dis-time-rule
{&create-static-table}.

&global-define table-name drt-prop
{&create-static-table}.

define buffer buf_tt-dis-rule for tt-dis-rule.
define buffer buf_tt-dis-time-rule for tt-dis-time-rule.


run waitfram-show in this-procedure ("Реинициализация шаблонов для правил скидок и расписаний").
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if ( g#db-num > 0 ) then return.
  if not p-forced then do:
    run check-dr-version in this-procedure (output v-check1).
    run check-dtr-version in this-procedure (output v-check2).
  end.
  if v-check1
  or p-forced
  or v-check2
  then do:
    if (v-check1
    or v-check2 )
    and p-read-only then do:
      return error substitute("&1 &2 &3&4До начала работы с данной БД (режим RO) необходимо произвести вход в ОСНОВНУЮ БД!!!"
                              ,vss-workfile
                              ,vss-revision
                              ,vss-description
                              ,{&new-line}).

    end.
     run gbl/md5.p (
       input  "cmp/fixdr.txt"     /* p-file-name     */
      ,output v-md5-signature /* p-md5-signature */
      ) .
    if v-md5-signature <> "{&rule-md5}" then do:
      message
      substitute("Несовпадение файла эталонных записей по правилам скидок и расписаний (fixdr.txt) с контрольным числом")
      view-as alert-box error .
      undo, return error .
    end.
    run gbl/filename.p ( input "cmp/fixdr.txt"
                        ,output v-full-path
                        ,output v-path
                        ,output v-file-name
                        ,output v-file-name-no-ext
                        ,output v-file-name-ext
                        ) no-error .
    if error-status:error then do:
      message
      substitute("Не найден файл эталонных записей по правилам скидок и расписаний (fixdr.txt)")
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
      substitute("Ошибка при чтении в память файла эталонных записей по правилам скидок и расписаний (fixdr.txt)&1&2&1&3"
                   , {&new-line}
                   , error-status:get-message(1)
                   , return-value )
      view-as alert-box error .
      undo, return error .
    end.
    if v-check1 then do:
      find first buf_tt-dis-rule no-lock where
                buf_tt-dis-rule.rule-num = 0  no-error.
      if not available buf_tt-dis-rule
      or buf_tt-dis-rule.des <> {&rule-revision} then do:
        message
        substitute("Версии шаблонов скидок в r-кодах и файле эталонных записей по правилам скидок и расписаний (fixdr.txt) НЕ СОВПАДАЮТ&1" +
                   "в r-кодах - &2&1" +
                   "в файле - &3"
                   , {&new-line}
                   , {&rule-revision}
                   , buf_tt-dis-rule.des
                   )
        view-as alert-box error .
        undo, return error .
      end.
    end.
    if v-check2 then do:
      find first buf_tt-dis-time-rule no-lock where
                buf_tt-dis-time-rule.time-rule-num = {&dtr-templates-shift} no-error.
      if not available buf_tt-dis-time-rule
      or buf_tt-dis-time-rule.des <> {&time-rule-revision} then do:
        message
        substitute("Версии шаблонов расписаний в r-кодах и файле эталонных записей по правилам скидок и расписаний (fixdr.txt) НЕ СОВПАДАЮТ&1" +
                   "в r-кодах - &2&1" +
                   "в файле - &3"
                   , {&new-line}
                   , {&time-rule-revision}
                   , buf_tt-dis-time-rule.des
                   )
        view-as alert-box error .
        undo, return error .
      end.
    end.

    /*
    run delete-dis-rules in this-procedure ( input ?) no-error .
    if error-status:error then do:
      run waitfram-hide in this-procedure .
      assign
      v-mes = substitute("Ошибки при инициализации правил скидок:&1&2 &3"
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
    */
    run add-dis-rules in this-procedure no-error .
    if error-status:error then do:
      run waitfram-hide in this-procedure .
      assign
      v-mes = substitute("Ошибки при инициализации правил скидок:&1&2 &3"
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
  if v-check2 or p-forced then do:
    /*
    run delete-dis-time-rules in this-procedure no-error .
    if error-status:error then do:
      run waitfram-hide in this-procedure .
      assign
      v-mes = substitute("Ошибки при инициализации расписаний:&1&2 &3"
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
    */
    run add-dis-time-rules in this-procedure no-error .
    if error-status:error then do:
      run waitfram-hide in this-procedure .
      assign
      v-mes = substitute("Ошибки при инициализации расписаний:&1&2 &3"
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

procedure delete-dis-time-rules :
define variable v-recid as recid no-undo .
define variable v-templ-rl-root as integer no-undo .
define buffer buf_dis-time-rule for ub.dis-time-rule.
define buffer del_dis-time-rule for ub.dis-time-rule.
define buffer down_dis-time-rule for ub.dis-time-rule.
define buffer buf_dis-rule for ub.dis-rule.

  do
  on error undo, return error
  :
     for each buf_dis-time-rule where
              buf_dis-time-rule.time-rule-num >= {&dtr-templates-shift} + {&num-dtr-templates}
          AND buf_dis-time-rule.upper-time-rule-num = {&dtr-templates-shift} :
        assign
        buf_dis-time-rule.sts = integer({&non-used-status-int})
        v-recid = recid(buf_dis-time-rule)
        v-templ-rl-root = buf_dis-time-rule.templ-rl-root
        .
        release buf_dis-time-rule.
        for each down_dis-time-rule where
                down_dis-time-rule.templ-rl-root = v-templ-rl-root
            AND down_dis-time-rule.upper-time-rule-num = v-templ-rl-root
            AND down_dis-time-rule.lvl-num <> 0
        on error undo, return error:
          for each buf_dis-rule exclusive-lock where
                            buf_dis-rule.time-rule-num = down_dis-time-rule.time-rule-num
          on error undo, return error :
            delete buf_dis-rule.
          end.
          delete down_dis-time-rule.
        end.
        find first del_dis-time-rule where recid(del_dis-time-rule) = v-recid.
        delete del_dis-time-rule.
     end.
  end.

end procedure. /* delete-dis-time-rules */

procedure delete-dis-rules :
define input parameter p-templ-rl-root as integer no-undo .
define variable v-recid as recid no-undo .
define variable v-templ-rl-root as integer no-undo .
define buffer buf_dis-rule for ub.dis-rule.
define buffer del_dis-rule for ub.dis-rule.
define buffer down_dis-rule for ub.dis-rule.

  main-block:
  do
  on error undo, return error
  :
     for each buf_dis-rule where
              ((buf_dis-rule.rule-num >= {&num-dr-templates}
              and p-templ-rl-root = ?)
              or
              (buf_dis-rule.templ-rl-root = p-templ-rl-root))
          AND buf_dis-rule.upper-rule-num = 0
     on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
     on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
     on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
     :
        if p-templ-rl-root <> ?
        and buf_dis-rule.templ-rl-root <> p-templ-rl-root then next.
        assign
        buf_dis-rule.sts = integer({&non-used-status-int})
        v-recid = recid(buf_dis-rule)
        v-templ-rl-root = buf_dis-rule.templ-rl-root
        .
        release buf_dis-rule.
        for each down_dis-rule where
                down_dis-rule.templ-rl-root = v-templ-rl-root
            AND down_dis-rule.upper-rule-num = v-templ-rl-root
        on error undo, return error:
          delete down_dis-rule.
        end.
        find first del_dis-rule where recid(del_dis-rule) = v-recid.
        delete del_dis-rule.
     end.
  end.

end procedure. /* delete-dis-time-rules */



procedure add-dis-rules :
/*добавление шаблонов скидок*/
define variable v-num-rules as integer no-undo .
define buffer buf_tt-dis-rule for tt-dis-rule.
main-block:
do
on error undo, return error
:
  assign
  v-num-rules = {&num-dr-templates}
  .
  for each buf_tt-dis-rule where
          buf_tt-dis-rule.rule-num <= v-num-rules
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    run create-dis-rule in this-procedure (
                                             buffer buf_tt-dis-rule
                                            ,input buf_tt-dis-rule.des /*p-des  */
                                            ,input buf_tt-dis-rule.dis-kat /*p-dis-kat              */
                                            ,input buf_tt-dis-rule.discnt-type /*p-discnt-type           */
                                            ,input buf_tt-dis-rule.doc-qnty /*p-doc-qnty              */
                                            ,input buf_tt-dis-rule.tot-sum
                                            ,input buf_tt-dis-rule.charkey_one
                                            ,input buf_tt-dis-rule.charkey_two
                                            ,input buf_tt-dis-rule.charkey_three
                                            ,input buf_tt-dis-rule.deckey_one
                                            ,input buf_tt-dis-rule.deckey_two
                                            ,input buf_tt-dis-rule.deckey_three
                                            ,input buf_tt-dis-rule.key#_one
                                            ,input buf_tt-dis-rule.key#_two
                                            ,input buf_tt-dis-rule.key#_three
                                            ,input buf_tt-dis-rule.subject-type /*p-subject-type          */
                                            ,input buf_tt-dis-rule.time-rule-num /*p-time-rule-num         */
                                            ,input buf_tt-dis-rule.upper-rule-num /*p-upper-rule-num        */
                                            ,input buf_tt-dis-rule.value-type /*p-value-type            */
                                            ,input buf_tt-dis-rule.sts
                                            ,input buf_tt-dis-rule.uniq-field
                                            ,input buf_tt-dis-rule.other
                                            ,input buf_tt-dis-rule.rule-num   /*p-rule-num              */
                                          ) no-error .
    if error-status:error then do:
      undo, return error return-value .
    end.
  end. /*    for each buf_tt-dis-rule where*/
end. /*doe*/

end procedure. /* add-dis-rules */

procedure add-dis-time-rules :
/*добавление шаблонов расписаний*/
define variable v-num-rules as integer no-undo .
define buffer buf_tt-dis-time-rule for tt-dis-time-rule.

main-block:
do
on error undo, return error
:
 

  assign
  v-num-rules = {&num-dtr-templates}
  .
  for each buf_tt-dis-time-rule where
          buf_tt-dis-time-rule.time-rule-num >= {&dtr-templates-shift}
     and  buf_tt-dis-time-rule.time-rule-num <= (v-num-rules + {&dtr-templates-shift})
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    run create-dis-time-rule in this-procedure (
                                             buffer buf_tt-dis-time-rule
                                            ,input buf_tt-dis-time-rule.des /*p-des  */
                                            ,input buf_tt-dis-time-rule.date-from
                                            ,input buf_tt-dis-time-rule.date-to
                                            ,input buf_tt-dis-time-rule.time-from
                                            ,input buf_tt-dis-time-rule.time-to
                                            ,input buf_tt-dis-time-rule.month-day
                                            ,input buf_tt-dis-time-rule.week-day-0
                                            ,input buf_tt-dis-time-rule.week-day-1
                                            ,input buf_tt-dis-time-rule.week-day-2
                                            ,input buf_tt-dis-time-rule.week-day-3
                                            ,input buf_tt-dis-time-rule.week-day-4
                                            ,input buf_tt-dis-time-rule.week-day-5
                                            ,input buf_tt-dis-time-rule.week-day-6
                                            ,input buf_tt-dis-time-rule.week-day-7
                                            ,input buf_tt-dis-time-rule.upper-time-rule-num /*p-upper-rule-num        */
                                            ,input buf_tt-dis-time-rule.value-type /*p-value-type            */
                                            ,input buf_tt-dis-time-rule.sts
                                            ,input buf_tt-dis-time-rule.uniq-field
                                            ,input buf_tt-dis-time-rule.other
                                            ,input buf_tt-dis-time-rule.time-rule-num   /*p-rule-num              */
                                          ) no-error .

  end. /*for eac*/
end. /*doe*/
end procedure. /* add-dis-time-rules */



procedure create-dis-rule :
define parameter buffer buf_tt-dis-rule for tt-dis-rule.
define input parameter  p-des               like ub.dis-rule.des               no-undo .
define input parameter  p-dis-kat           like ub.dis-rule.dis-kat           no-undo .
define input parameter  p-discnt-type       like ub.dis-rule.discnt-type       no-undo .
define input parameter  p-doc-qnty          like ub.dis-rule.doc-qnty          no-undo .
define input parameter  p-tot-sum           like ub.dis-rule.tot-sum           no-undo .
define input parameter  p-charkey_one       like ub.dis-rule.charkey_one       no-undo .
define input parameter  p-charkey_two       like ub.dis-rule.charkey_two       no-undo .
define input parameter  p-charkey_three     like ub.dis-rule.charkey_three     no-undo .
define input parameter  p-deckey_one        like ub.dis-rule.deckey_one       no-undo .
define input parameter  p-deckey_two        like ub.dis-rule.deckey_two       no-undo .
define input parameter  p-deckey_three      like ub.dis-rule.deckey_three     no-undo .
define input parameter  p-key#_one          like ub.dis-rule.key#_one          no-undo .
define input parameter  p-key#_two          like ub.dis-rule.key#_two          no-undo .
define input parameter  p-key#_three        like ub.dis-rule.key#_three        no-undo .
define input parameter  p-subject-type      like ub.dis-rule.subject-type      no-undo .
define input parameter  p-time-rule-num     like ub.dis-rule.time-rule-num     no-undo .
define input parameter  p-upper-rule-num    like ub.dis-rule.upper-rule-num    no-undo .
define input parameter  p-value-type        like ub.dis-rule.value-type        no-undo .
define input parameter  p-sts               like ub.dis-rule.sts               no-undo .
define input parameter  p-tree              like ub.dis-rule.uniq-field        no-undo .
define input parameter  p-other             like ub.dis-rule.other-inf         no-undo .
define input parameter  p-rule-num          like ub.dis-rule.rule-num          no-undo .

define variable v-doc-rec as recid no-undo .
define variable v-exists as logical no-undo .
define variable v-level1 as character no-undo .
define variable v-level2 as character no-undo .
define variable v-curr-level as character no-undo .
define variable v-cmp-char as character no-undo .
define variable v-exists2 as logical   no-undo .
define buffer buf_dis-rule for ub.dis-rule.
define buffer down_dis-rule for ub.dis-rule.
define buffer buf_tt-dis-cfg-rule for tt-dis-cfg-rule.

on write of ub.dis-rule override do:
end.

main-block:
do
on error undo, return error
:
  find first buf_tt-dis-cfg-rule no-lock where
            buf_tt-dis-cfg-rule.templ-rl-root = p-rule-num
        and  buf_tt-dis-cfg-rule.table-name = '':U
        and  buf_tt-dis-cfg-rule.time-templ-rl-root = 0
        and  buf_tt-dis-cfg-rule.pos-type = '':U
        and  buf_tt-dis-cfg-rule.discnt-role = '':U no-error .
  if not available buf_tt-dis-cfg-rule then do:
  end.
  assign
  v-level1 = entry(1, buf_tt-dis-cfg-rule.other-inf, ";":U)
  v-level2 = (if num-entries(buf_tt-dis-cfg-rule.other-inf, ";":U) > 1
                then entry(2, buf_tt-dis-cfg-rule.other-inf, ";":U)
                else '')
  .
  find first buf_dis-rule where
            buf_dis-rule.rule-num = p-rule-num no-error.
  if not available buf_dis-rule then do:
    on write of ub.dis-rule revert.
    create buf_dis-rule.
    buffer-copy buf_tt-dis-rule to buf_Dis-rule.
  end.
  else do:
    if
    (buf_dis-rule.time-rule-num <> p-time-rule-num
    and
    lookup("time-rule-num", v-level1) = 0
    and
    lookup("time-rule-num", v-level2) = 0
    and
    (buf_dis-rule.sts = integer({&non-used-status-int})
     or
     p-time-rule-num = -1)
    ) then do:
      assign
      buf_dis-rule.time-rule-num = p-time-rule-num
      .
      release buf_dis-rule.
      find first buf_dis-rule where
                buf_dis-rule.rule-num = p-rule-num no-error.
    end.
    on write of ub.dis-rule revert.
    buffer-compare buf_dis-rule
    using des discnt-type uniq-field other-inf dis-kat doc-qnty tot-sum
          charkey_one charkey_two charkey_three
          deckey_one deckey_two deckey_three
          key#_one key#_two key#_three
    to buf_tt-dis-rule
    save result in v-cmp-char.
    if v-cmp-char <> ''
    then do:
      buffer-copy buf_tt-dis-rule
      using des discnt-type uniq-field other-inf dis-kat doc-qnty tot-sum
            charkey_one charkey_two charkey_three
            deckey_one deckey_two deckey_three
            key#_one key#_two key#_three
      to buf_dis-rule
      assign
      v-doc-rec                      = recid(buf_dis-rule)
      v-exists                       = yes
      .
    end.
    if buf_dis-rule.sts               <> (if p-sts <> integer({&non-used-status-int})
                                        then integer({&used-status-int})
                                        else integer({&non-used-status-int})) then do:
      assign
      buf_dis-rule.sts               = (if p-sts <> integer({&non-used-status-int})
                                        then integer({&used-status-int})
                                        else integer({&non-used-status-int}))
      v-doc-rec                      = recid(buf_dis-rule)
      v-exists2                       = yes
      .
    end.
    if buf_dis-rule.rule-num > 0 then do:
      if v-exists
      and v-cmp-char <> "des"
      then do:
        for each down_dis-rule where
                down_dis-rule.templ-rl-root = buf_dis-rule.templ-rl-root
            and down_dis-rule.lvl-num > 0
        on error undo main-block, return error:
          if down_dis-rule.upper-rule-num <= {&max-num-dr-template} then do:
            assign
            v-curr-level = v-level1
            .
          end.
          else do:
            assign
            v-curr-level = v-level2
            .
          end.
          if
          down_dis-rule.uniq-field        <> p-tree
          or down_dis-rule.discnt-type <> p-discnt-type
          or
          down_dis-rule.other-inf         <> p-other

          or ((down_dis-rule.dis-kat        <> p-dis-kat )
              and
              lookup("dis-kat", v-curr-level) = 0
            )
          or ((down_dis-rule.doc-qnty       <> p-doc-qnty)
              and
              lookup("doc-qnty", v-curr-level) = 0
            )
          or ((down_dis-rule.tot-sum       <> p-tot-sum)
              and
              lookup("tot-sum", v-curr-level) = 0
            )
          or ((down_dis-rule.charkey_one       <> p-charkey_one)
              and
              lookup("charkey_one", v-curr-level) = 0
            )
          or ((down_dis-rule.charkey_two       <> p-charkey_two)
              and
              lookup("charkey_two", v-curr-level) = 0
            )
          or ((down_dis-rule.charkey_three       <> p-charkey_three)
              and
              lookup("charkey_three", v-curr-level) = 0
            )
          or ((down_dis-rule.deckey_one       <> p-deckey_one)
              and
              lookup("deckey_one", v-curr-level) = 0
            )
          or ((down_dis-rule.deckey_two       <> p-deckey_two)
              and
              lookup("deckey_two", v-curr-level) = 0
            )
          or ((down_dis-rule.deckey_three       <> p-deckey_three)
              and
              lookup("deckey_three", v-curr-level) = 0
            )
          or ((down_dis-rule.key#_one       <> p-key#_one)
              and
              lookup("key#_one", v-curr-level) = 0
            )
          or ((down_dis-rule.key#_two       <> p-key#_two)
              and
              lookup("key#_two", v-curr-level) = 0
            )
          or ((down_dis-rule.key#_three       <> p-key#_three)
              and
              lookup("key#_three", v-curr-level) = 0
            )
          then do:
            assign
            down_dis-rule.uniq-field        = p-tree
            down_dis-rule.discnt-type       = p-discnt-type
            down_dis-rule.other-inf         = p-other
            down_dis-rule.dis-kat           = (if p-dis-kat <> down_dis-rule.dis-kat
                                              and lookup("dis-kat", v-curr-level) = 0
                                              then p-dis-kat else down_dis-rule.dis-kat)
            down_dis-rule.doc-qnty          = (if p-doc-qnty <> down_dis-rule.doc-qnty
                                              and lookup("doc-qnty", v-curr-level) = 0
                                              then p-doc-qnty else down_dis-rule.doc-qnty)
            down_dis-rule.tot-sum           = (if p-tot-sum <> down_dis-rule.tot-sum
                                              and lookup("tot-sum", v-curr-level) = 0
                                              then p-tot-sum else down_dis-rule.tot-sum)
            down_dis-rule.charkey_one       = (if p-charkey_one <> down_dis-rule.charkey_one
                                              and lookup("charkey_one", v-curr-level) = 0
                                              then p-charkey_one else down_dis-rule.charkey_one)
            down_dis-rule.charkey_two       = (if p-charkey_two <> down_dis-rule.charkey_two
                                              and lookup("charkey_two", v-curr-level) = 0
                                              then p-charkey_two else down_dis-rule.charkey_two)
            down_dis-rule.charkey_three     = (if p-charkey_three <> down_dis-rule.charkey_three
                                              and lookup("charkey_three", v-curr-level) = 0
                                              then p-charkey_three else down_dis-rule.charkey_three)
            down_dis-rule.deckey_one       = (if p-deckey_one <> down_dis-rule.deckey_one
                                              and lookup("deckey_one", v-curr-level) = 0
                                              then p-deckey_one else down_dis-rule.deckey_one)
            down_dis-rule.deckey_two       = (if p-deckey_two <> down_dis-rule.deckey_two
                                              and lookup("deckey_two", v-curr-level) = 0
                                              then p-deckey_two else down_dis-rule.deckey_two)
            down_dis-rule.deckey_three     = (if p-deckey_three <> down_dis-rule.deckey_three
                                              and lookup("deckey_three", v-curr-level) = 0
                                              then p-deckey_three else down_dis-rule.deckey_three)
            down_dis-rule.key#_one       = (if p-key#_one <> down_dis-rule.key#_one
                                              and lookup("key#_one", v-curr-level) = 0
                                              then p-key#_one else down_dis-rule.key#_one)
            down_dis-rule.key#_two       = (if p-key#_two <> down_dis-rule.key#_two
                                            and lookup("key#_two", v-curr-level) = 0
                                            then p-key#_two else down_dis-rule.key#_two)
            down_dis-rule.key#_three     = (if p-key#_three <> down_dis-rule.key#_three
                                            and lookup("key#_three", v-curr-level) = 0
                                            then p-key#_three else down_dis-rule.key#_three)
          .
            if down_dis-rule.lvl-num <> 1 then do:
              assign
              down_dis-rule.sts               =  (if down_dis-rule.sts <> integer({&non-root-status-int})
                                                  then integer({&non-root-status-int})
                                                  else down_dis-rule.sts)
              .
            end.
            release down_dis-rule no-error .
            if error-status:error then undo, return error return-value .
          end.
        end. /*for each*/
      end. /*if v-exists*/
      if v-exists2 then do:
        for each down_dis-rule where
                down_dis-rule.templ-rl-root = buf_dis-rule.templ-rl-root
            AND down_dis-rule.lvl-num       <> 0
        on error undo main-block, return error:
          if down_dis-rule.lvl-num <> 1 then do:
            assign
            down_dis-rule.sts               =  (if down_dis-rule.sts <> integer({&non-root-status-int})
                                                then integer({&non-root-status-int})
                                                else down_dis-rule.sts)
            .
            release down_dis-rule no-error .
            if error-status:error then undo, return error return-value.
          end.
        end. /*for each down_dis-rule where*/
      end. /*if v-exists2 then do:*/
    end. /*if buf_dis-rule.rule-num > 0 then do:*/
    run create-dis-cfg-rule in this-procedure ( input p-rule-num).
    run create-drt-prop in this-procedure ( input p-rule-num).
    return .
    /*
    if buf_dis-rule.des <> p-des
    or
    buf_dis-rule.dis-kat           <> p-dis-kat
    or
    buf_dis-rule.discnt-type       <> p-discnt-type
    or
    buf_dis-rule.doc-qnty          <> p-doc-qnty
    or
    buf_dis-rule.tot-sum           <> p-tot-sum
    or
    buf_dis-rule.charkey_one       <> p-charkey_one
    or
    buf_dis-rule.charkey_two       <> p-charkey_two
    or
    buf_dis-rule.charkey_three     <> p-charkey_three
    or
    buf_dis-rule.deckey_one       <> p-deckey_one
    or
    buf_dis-rule.deckey_two       <> p-deckey_two
    or
    buf_dis-rule.deckey_three     <> p-deckey_three
    or
    buf_dis-rule.key#_one          <> p-key#_one
    or
    buf_dis-rule.key#_two          <> p-key#_two
    or
    buf_dis-rule.key#_three        <> p-key#_three
    or
    buf_dis-rule.sts               <> (if p-sts <> integer({&non-used-status-int})
                                        then integer({&used-status-int})
                                        else integer({&non-used-status-int}))
    or
    buf_dis-rule.time-rule-num     <> p-time-rule-num
    or
    buf_dis-rule.upper-rule-num    <> p-upper-rule-num
    or
    buf_dis-rule.value-type        <> p-value-type
    or
    buf_dis-rule.root              <> yes
    or
    buf_dis-rule.lvl-num           <> 0
    or
    buf_dis-rule.is-term           <> yes
    or
    buf_dis-rule.uniq-field        <> p-tree
    or
    buf_dis-rule.other-inf         <> p-other
    or
    buf_dis-rule.rl-root           <> p-rule-num
    or
    buf_dis-rule.templ-rl-root     <> p-rule-num
    then do:
      assign
      buf_dis-rule.des               = p-des
      buf_dis-rule.dis-kat           = p-dis-kat
      buf_dis-rule.discnt-type       = p-discnt-type
      buf_dis-rule.doc-qnty          = p-doc-qnty
      buf_dis-rule.tot-sum           = p-tot-sum
      buf_dis-rule.charkey_one       = p-charkey_one
      buf_dis-rule.charkey_two       = p-charkey_two
      buf_dis-rule.charkey_three     = p-charkey_three
      buf_dis-rule.deckey_one       = p-deckey_one
      buf_dis-rule.deckey_two       = p-deckey_two
      buf_dis-rule.deckey_three     = p-deckey_three
      buf_dis-rule.key#_one          = p-key#_one
      buf_dis-rule.key#_two          = p-key#_two
      buf_dis-rule.key#_three        = p-key#_three
      buf_dis-rule.sts               = if p-sts <> integer({&non-used-status-int})
                                        then integer({&used-status-int})
                                        else integer({&non-used-status-int})
      buf_dis-rule.subject-type      = p-subject-type
      buf_dis-rule.time-rule-num     = p-time-rule-num
      buf_dis-rule.upper-rule-num    = p-upper-rule-num
      buf_dis-rule.value-type        = p-value-type
      buf_dis-rule.root              = yes
      buf_dis-rule.lvl-num           = 0
      buf_dis-rule.is-term           = yes
      buf_dis-rule.uniq-field        = p-tree
      buf_dis-rule.other-inf         = p-other
      buf_dis-rule.rl-root           = p-rule-num
      buf_dis-rule.templ-rl-root     = p-rule-num
      .
      release buf_dis-rule no-error .
      if error-status:error then undo, return error return-value .
    end.
    */
  end. /*else if not available dis-rule*/
  run create-dis-cfg-rule in this-procedure ( input p-rule-num).
  run create-drt-prop in this-procedure ( input p-rule-num).
end.

end procedure. /* create-dis-rule */

procedure create-dis-time-rule :
define parameter buffer buf_tt-dis-time-rule for tt-dis-time-rule.
define input parameter  p-des               like ub.dis-rule.des               no-undo .
define input parameter  p-date-from         like ub.dis-time-rule.date-from no-undo .
define input parameter  p-date-to           like ub.dis-time-rule.date-to  no-undo .
define input parameter  p-time-from         like ub.dis-time-rule.time-from  no-undo .
define input parameter  p-time-to           like ub.dis-time-rule.time-to  no-undo .
define input parameter  p-month-day         like ub.dis-time-rule.month-day no-undo .
define input parameter  p-week-day-0        like ub.dis-time-rule.week-day-0 no-undo .
define input parameter  p-week-day-1        like ub.dis-time-rule.week-day-1 no-undo .
define input parameter  p-week-day-2        like ub.dis-time-rule.week-day-2 no-undo .
define input parameter  p-week-day-3        like ub.dis-time-rule.week-day-3 no-undo .
define input parameter  p-week-day-4        like ub.dis-time-rule.week-day-4 no-undo .
define input parameter  p-week-day-5        like ub.dis-time-rule.week-day-5 no-undo .
define input parameter  p-week-day-6        like ub.dis-time-rule.week-day-6 no-undo .
define input parameter  p-week-day-7        like ub.dis-time-rule.week-day-7 no-undo .
define input parameter  p-upper-time-rule-num    like ub.dis-time-rule.upper-time-rule-num    no-undo .
define input parameter  p-value-type        like ub.dis-time-rule.value-type        no-undo .
define input parameter  p-sts               like ub.dis-time-rule.sts no-undo .
define input parameter  p-tree              like ub.dis-time-rule.uniq-field        no-undo .
define input parameter  p-other             like ub.dis-time-rule.other-inf         no-undo .
define input parameter  p-time-rule-num     like ub.dis-time-rule.time-rule-num          no-undo .

define variable v-doc-rec as recid no-undo .
define variable v-exists as logical no-undo .
define variable v-exitst2 as logical   no-undo .
define variable v-level1 as character no-undo .
define variable v-level2 as character no-undo .
define variable v-curr-level as character no-undo .
define buffer buf_dis-time-rule for ub.dis-time-rule.
define buffer down_dis-time-rule for ub.dis-time-rule.
define buffer buf_tt-dis-cfg-rule for tt-dis-cfg-rule.
on write of ub.dis-time-rule override do: end.
main-block:
do
on error undo, return error
:
  find first buf_tt-dis-cfg-rule no-lock where
            buf_tt-dis-cfg-rule.time-templ-rl-root = p-time-rule-num
        and  buf_tt-dis-cfg-rule.table-name = '':U
        and  buf_tt-dis-cfg-rule.templ-rl-root = 0
        and  buf_tt-dis-cfg-rule.pos-type = '':U
        and  buf_tt-dis-cfg-rule.discnt-role = '':U no-error .
  if not available buf_tt-dis-cfg-rule then do:
  end.
  assign
  v-level1 = entry(1, buf_tt-dis-cfg-rule.other-inf, ";":U)
  v-level2 = (if num-entries(buf_tt-dis-cfg-rule.other-inf, ";":U) > 1
                then entry(2, buf_tt-dis-cfg-rule.other-inf, ";":U)
                else '')
  .

  find first buf_dis-time-rule where
            buf_dis-time-rule.time-rule-num  = p-time-rule-num  no-error.
  if not available buf_dis-time-rule then do:
    on write of ub.dis-time-rule revert.
    create buf_dis-time-rule.
    assign
    buf_dis-time-rule.time-rule-num          = p-time-rule-num
    v-exists = yes
    .
  end.
  else do:
    if buf_dis-time-rule.des <> p-des
    or
    buf_dis-time-rule.uniq-field        <> p-tree
    or
    buf_dis-time-rule.other-inf         <> p-other
    or
    buf_dis-time-rule.sts               <> (if p-sts <> integer({&non-used-status-int})
                                            then integer({&used-status-int})
                                            else integer({&non-used-status-int}))
    then do:
      assign
      buf_dis-time-rule.des               = p-des
      buf_dis-time-rule.uniq-field        = p-tree
      buf_dis-time-rule.other-inf         = p-other
      buf_dis-time-rule.sts               = (if p-sts <> integer({&non-used-status-int})
                                              then integer({&used-status-int})
                                              else integer({&non-used-status-int}))
      v-exists = yes
      .
    end.
    if buf_dis-time-rule.time-rule-num <> {&dtr-templates-shift} then do:
      for each down_dis-time-rule where
              down_dis-time-rule.templ-rl-root = buf_dis-time-rule.templ-rl-root
          AND  down_dis-time-rule.lvl-num       <> 0
      on error undo main-block, return error:
        if down_dis-time-rule.upper-time-rule-num <= {&max-num-dr-template} then do:
          assign
          v-curr-level = v-level1
          .
        end.
        else do:
          assign
          v-curr-level = v-level2
          .
        end.
        if down_dis-time-rule.uniq-field        <> p-tree
        or
        down_dis-time-rule.other-inf         <> p-other
        or ((down_dis-time-rule.time-from       <> p-time-from)
            and
            lookup("time-from", v-curr-level) = 0
          )
        or ((down_dis-time-rule.time-to       <> p-time-to)
            and
            lookup("time-to", v-curr-level) = 0
          )
        or ((down_dis-time-rule.date-from       <> p-date-from)
            and
            lookup("date-from", v-curr-level) = 0
          )
        or ((down_dis-time-rule.date-to       <> p-date-to)
            and
            lookup("date-to", v-curr-level) = 0
          )
        or ((down_dis-time-rule.week-day-0       <> p-week-day-0)
            and
            lookup("week-day-0", v-curr-level) = 0
          )
        or ((down_dis-time-rule.week-day-1       <> p-week-day-1)
            and
            lookup("week-day-1", v-curr-level) = 0
          )
        or ((down_dis-time-rule.week-day-2       <> p-week-day-2)
            and
            lookup("week-day-2", v-curr-level) = 0
          )
        or ((down_dis-time-rule.week-day-3       <> p-week-day-3)
            and
            lookup("week-day-3", v-curr-level) = 0
          )

        or ((down_dis-time-rule.week-day-4       <> p-week-day-4)
            and
            lookup("week-day-4", v-curr-level) = 0
          )
        or ((down_dis-time-rule.week-day-5       <> p-week-day-5)
            and
            lookup("week-day-5", v-curr-level) = 0
          )
        or ((down_dis-time-rule.week-day-6       <> p-week-day-6)
            and
            lookup("week-day-6", v-curr-level) = 0
          )
        or ((down_dis-time-rule.week-day-7       <> p-week-day-7)
            and
            lookup("week-day-7", v-curr-level) = 0
          )
        or ((down_dis-time-rule.month-day       <> p-month-day)
            and
            lookup("month-day", v-curr-level) = 0
          )
        then do:
          assign
          down_dis-time-rule.uniq-field        = p-tree
          down_dis-time-rule.other-inf         = p-other
          down_dis-time-rule.date-from        = p-date-from
          down_dis-time-rule.date-to          = p-date-to
          down_dis-time-rule.time-from        = (if  ((down_dis-time-rule.time-from       <> p-time-from)
                                                  and
                                                  lookup("time-from", v-curr-level) = 0
                                                      )
                                                then p-time-from
                                                else down_dis-time-rule.time-from)

          down_dis-time-rule.time-to          = (if  ((down_dis-time-rule.time-to       <> p-time-to)
                                                  and
                                                  lookup("time-to", v-curr-level) = 0
                                                      )
                                                then p-time-to
                                                else down_dis-time-rule.time-to)


          down_dis-time-rule.week-day-0       = (if ((down_dis-time-rule.week-day-0       <> p-week-day-0)
                                                    and
                                                    lookup("week-day-0", v-curr-level) = 0
                                                  )
                                                then p-week-day-0
                                                else down_dis-time-rule.week-day-0)
          down_dis-time-rule.week-day-1       = (if ((down_dis-time-rule.week-day-1       <> p-week-day-1)
                                                    and
                                                    lookup("week-day-1", v-curr-level) = 0
                                                  )
                                                then p-week-day-1
                                                else down_dis-time-rule.week-day-1)
          down_dis-time-rule.week-day-2       = (if ((down_dis-time-rule.week-day-2       <> p-week-day-2)
                                                    and
                                                    lookup("week-day-2", v-curr-level) = 0
                                                  )
                                                then p-week-day-2
                                                else down_dis-time-rule.week-day-2)
          down_dis-time-rule.week-day-3       = (if ((down_dis-time-rule.week-day-3       <> p-week-day-3)
                                                    and
                                                    lookup("week-day-3", v-curr-level) = 0
                                                  )
                                                then p-week-day-3
                                                else down_dis-time-rule.week-day-3)
          down_dis-time-rule.week-day-4       = (if ((down_dis-time-rule.week-day-4       <> p-week-day-4)
                                                    and
                                                    lookup("week-day-4", v-curr-level) = 0
                                                  )
                                                then p-week-day-4
                                                else down_dis-time-rule.week-day-4)
          down_dis-time-rule.week-day-5       = (if ((down_dis-time-rule.week-day-5       <> p-week-day-5)
                                                    and
                                                    lookup("week-day-5", v-curr-level) = 0
                                                  )
                                                then p-week-day-5
                                                else down_dis-time-rule.week-day-5)
          down_dis-time-rule.week-day-6       = (if ((down_dis-time-rule.week-day-6       <> p-week-day-6)
                                                    and
                                                    lookup("week-day-6", v-curr-level) = 0
                                                  )
                                                then p-week-day-6
                                                else down_dis-time-rule.week-day-6)
          down_dis-time-rule.week-day-7       = (if ((down_dis-time-rule.week-day-7       <> p-week-day-7)
                                                    and
                                                    lookup("week-day-7", v-curr-level) = 0
                                                  )
                                                then p-week-day-7
                                                else down_dis-time-rule.week-day-7)
          down_dis-time-rule.month-day       = (if ((down_dis-time-rule.month-day       <> p-month-day)
                                                    and
                                                    lookup("month-day", v-curr-level) = 0
                                                  )
                                                then p-month-day
                                                else down_dis-time-rule.month-day)
          .
          release down_dis-time-rule no-error .
          if error-status:error then undo, return error return-value .
        end.
      end.
      for each down_dis-time-rule where
              down_dis-time-rule.templ-rl-root = buf_dis-time-rule.templ-rl-root
          AND down_dis-time-rule.lvl-num       > 0
      on error undo main-block, return error:
        if down_dis-time-rule.lvl-num <> 1 then do:
          assign
          down_dis-time-rule.sts               =  (if down_dis-time-rule.sts <> integer({&non-root-status-int})
                                              then integer({&non-root-status-int})
                                              else down_dis-time-rule.sts)
          .
          release down_dis-time-rule no-error .
          if error-status:error then undo, return error return-value.
        end.
      end.
    end. /*if buf_dis-time-rule.time-rule-num > 50000 then do:*/
    run create-drt-prop in this-procedure ( input p-time-rule-num).
    return .
  end.
  if buf_dis-time-rule.des <> p-des
  or
  buf_dis-time-rule.date-from         <> p-date-from
  or
  buf_dis-time-rule.date-to           <> p-date-to
  or
  buf_dis-time-rule.time-from         <> p-time-from
  or
  buf_dis-time-rule.time-to           <> p-time-to
  or
  buf_dis-time-rule.month-day         <> p-month-day
  or
  buf_dis-time-rule.week-day-0        <> p-week-day-0
  or
  buf_dis-time-rule.week-day-1        <> p-week-day-1
  or
  buf_dis-time-rule.week-day-2        <> p-week-day-2
  or
  buf_dis-time-rule.week-day-3        <> p-week-day-3
  or
  buf_dis-time-rule.week-day-4        <> p-week-day-4
  or
  buf_dis-time-rule.week-day-5        <> p-week-day-5
  or
  buf_dis-time-rule.week-day-6        <> p-week-day-6
  or
  buf_dis-time-rule.week-day-7        <> p-week-day-7
  or
  buf_dis-time-rule.sts               <> (if p-sts <> integer({&non-used-status-int})
                                          then integer({&used-status-int})
                                          else integer({&non-used-status-int}))
  or
  buf_dis-time-rule.upper-time-rule-num    <> p-upper-time-rule-num
  or
  buf_dis-time-rule.value-type        <> p-value-type
  or
  buf_dis-time-rule.root              <> yes
  or
  buf_dis-time-rule.lvl-num           <> 0
  or
  buf_dis-time-rule.is-term           <> yes
  or
  buf_dis-time-rule.uniq-field        <> p-tree
  or
  buf_dis-time-rule.other-inf         <> p-other
  or
  buf_dis-time-rule.rl-root           <> p-time-rule-num
  or
  buf_dis-time-rule.templ-rl-root     <> p-time-rule-num
  then do:
    assign
    buf_dis-time-rule.des                   = p-des
    buf_dis-time-rule.upper-time-rule-num    = p-upper-time-rule-num
    buf_dis-time-rule.date-from         = p-date-from
    buf_dis-time-rule.date-to           = p-date-to
    buf_dis-time-rule.time-from         = p-time-from
    buf_dis-time-rule.time-to           = p-time-to
    buf_dis-time-rule.month-day         = p-month-day
    buf_dis-time-rule.week-day-0        = p-week-day-0
    buf_dis-time-rule.week-day-1        = p-week-day-1
    buf_dis-time-rule.week-day-2        = p-week-day-2
    buf_dis-time-rule.week-day-3        = p-week-day-3
    buf_dis-time-rule.week-day-4        = p-week-day-4
    buf_dis-time-rule.week-day-5        = p-week-day-5
    buf_dis-time-rule.week-day-6        = p-week-day-6
    buf_dis-time-rule.week-day-7        = p-week-day-7
    buf_dis-time-rule.value-type        = p-value-type
    buf_dis-time-rule.root              = yes
    buf_dis-time-rule.lvl-num           = 0
    buf_dis-time-rule.is-term           = yes
    buf_dis-time-rule.uniq-field        = p-tree
    buf_dis-time-rule.other-inf         = p-other
    buf_dis-time-rule.rl-root           = p-time-rule-num     /*  + {&dtr-templates-shift} */
    buf_dis-time-rule.templ-rl-root     = p-time-rule-num     /*  + {&dtr-templates-shift} */
    buf_dis-time-rule.sts               = (if p-sts <> integer({&non-used-status-int})
                                            then integer({&used-status-int})
                                            else integer({&non-used-status-int}))
    .
    release buf_dis-time-rule no-error .
    if error-status:error then undo, return error return-value .
  end.
end.

end procedure. /* create-dis-time-rule */

procedure create-dis-cfg-rule :
define input parameter p-rule-num as integer no-undo .
define buffer buf_tt-dis-cfg-rule for tt-dis-cfg-rule.
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
define buffer buf2_dis-cfg-rule for ub.dis-cfg-rule.

main-block:
do
on error undo, return error
:
  for each buf_tt-dis-cfg-rule no-lock where
         buf_tt-dis-cfg-rule.templ-rl-root = p-rule-num
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    find first buf_dis-cfg-rule share-lock where
              buf_dis-cfg-rule.templ-rl-root = buf_tt-dis-cfg-rule.templ-rl-root
          and buf_dis-cfg-rule.table-name = buf_tt-dis-cfg-rule.table-name
          and buf_dis-cfg-rule.pos-type = buf_tt-dis-cfg-rule.pos-type
          and buf_dis-cfg-rule.time-templ-rl-root = buf_tt-dis-cfg-rule.time-templ-rl-root
          and buf_dis-cfg-rule.self-nonunique = buf_tt-dis-cfg-rule.self-nonunique no-error.
    if not available buf_dis-cfg-rule then do:
      create buf_dis-cfg-rule.
    end.
    buffer-copy buf_tt-dis-cfg-rule
    to buf_dis-cfg-rule.
  end.
  for each buf_dis-cfg-rule no-lock where
          buf_dis-cfg-rule.templ-rl-root = p-rule-num
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    find first buf_tt-dis-cfg-rule where
            buf_tt-dis-cfg-rule.templ-rl-root = buf_dis-cfg-rule.templ-rl-root
        and buf_tt-dis-cfg-rule.table-name = buf_dis-cfg-rule.table-name
        and buf_tt-dis-cfg-rule.pos-type = buf_dis-cfg-rule.pos-type
        and buf_tt-dis-cfg-rule.time-templ-rl-root = buf_dis-cfg-rule.time-templ-rl-root
        and buf_tt-dis-cfg-rule.self-nonunique = buf_dis-cfg-rule.self-nonunique
        no-error .
    if not available buf_tt-dis-cfg-rule then do:
      find first buf2_dis-cfg-rule exclusive-lock where
                recid(buf2_dis-cfg-rule) = recid(buf_dis-cfg-rule).
      delete buf2_dis-cfg-rule.
    end.
  end.
end.

end procedure. /* create-dis-cfg-rule */

procedure create-drt-prop :
define input parameter p-templ-rl-root as integer no-undo .
define buffer buf_tt-drt-prop for tt-drt-prop.
define buffer buf_drt-prop for ub.drt-prop.
define buffer buf2_drt-prop for ub.drt-prop.


main-block:
do
on error undo, return error
:
  for each buf_tt-drt-prop no-lock where
          buf_tt-drt-prop.templ-rl-root = p-templ-rl-root
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    find first buf_drt-prop share-lock where
              buf_drt-prop.templ-rl-root = buf_tt-drt-prop.templ-rl-root
          and buf_drt-prop.node-code = buf_tt-drt-prop.node-code no-error.
    if not available buf_drt-prop then do:
      create buf_drt-prop.
    end.
    buffer-copy buf_tt-drt-prop to buf_drt-prop.
  end.
  for each buf_drt-prop no-lock where
          buf_drt-prop.templ-rl-root = p-templ-rl-root
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    find first buf_tt-drt-prop where
            buf_tt-drt-prop.templ-rl-root = buf_drt-prop.templ-rl-root
        and buf_tt-drt-prop.node-code = buf_drt-prop.node-code no-error .
    if not available buf_tt-drt-prop then do:
      find first buf2_drt-prop exclusive-lock where
                recid(buf2_drt-prop) = recid(buf_drt-prop).
      delete buf2_drt-prop.
    end.
  end.
end.

end procedure. /* create-drt-prop */