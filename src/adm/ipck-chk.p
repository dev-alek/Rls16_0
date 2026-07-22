block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ipck-chk.p $
$Archive: adm/ipck-chk.p $

Проверка готовности пакета обновления к инсталляции

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/05/05
Author: Bakhtadze Natalya
Creation date: 12/05/05

*/


define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .

/*
p-parameter включает
define input parameter p-file-name as character no-undo .
имя манифеста то бишь пакета
define input parameter p-action as character no-undo .
define input parameter p-lock-par as character no-undo .
question answer
*/


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ipck-chk.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/ipck-chk.p $":U .
define variable vss-description as character no-undo init "Проверка готовности пакета обновления к инсталляции".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/trg-def.i }
{ adm/ipck-mf.i }

define variable p-db-num as integer no-undo .
define variable p-from-db-num as integer no-undo .
define variable p-file-name  as character no-undo .
define variable p-action as character no-undo .
define variable p-lock-par as character no-undo .
define variable v-lock-par as character no-undo .
define buffer buf_ext-file for ub.ext-file.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

assign
p-db-num = integer(entry(1, p-parameter, {&delim-par} ))
p-from-db-num = integer(entry(2, p-parameter, {&delim-par} ))
p-file-name = entry(3, p-parameter, {&delim-par} )
p-action = entry(4, {&delim-par})
no-error .
if error-status:error then do:
  return error substitute("Ошибка входных параметров &1:&2&3&4"
                         , p-parameter
                         , {&new-line}
                         , error-status:get-message(1)
                         , return-value
                         ).
end.

assign
p-lock-par = (if num-entries(p-action) > 1
              then entry(2, p-action)
              else '':U)
p-action = entry(1, p-action)
.


CASE p-action:
  when {&query} then do:
    find first buf_ext-file exclusive-lock where
            buf_Ext-file.db-num = p-db-num
        and buf_Ext-file.from-db-num = p-from-db-num
        and buf_Ext-file.file-type = p-file-name
        and buf_Ext-file.file-name = p-file-name no-error.
    if not available buf_ext-file then do:
      if p-db-num = g#db-num and g#db-num = 0
      then do:
      end.
      else do:
        run nws/cr-route.p (
                    input {&send-cmd}
                    ,input ("command"
                            + {&delim-nws} + "run-file"
                            + {&delim-nws} + "ipck-chk.p"
                            + {&delim-nws} + (string(buf_Ext-file.db-num)
                            + {&delim-par} +  string(buf_Ext-file.from-db-num)
                            + {&delim-par} +  buf_ext-file.FILE-NAME
                            + {&delim-par} + {&reply} + {&comma-char} + "not-found"))
                    ,input ?
                    ,input string(0)
                    ) no-error .
      end.
    end.
    run ipck-mf-check-ipck in this-procedure ( input p-db-num, input p-from-db-num, input p-file-name) no-error.
    if error-status:error then do:
      v-lock-par = {&error}.
    end.
    else do:
      v-lock-par = {&ready}.
    end.
    if g#db-num = 0 and p-db-num = g#db-num then do:
      run adm/ipck-chk.p ( INPUT parparentproc
                            ,INPUT p-parent-handle
                            ,INPUT p-log-handle
                            ,INPUT (string(buf_ext-file.db-num)
                                      + {&delim-par} + string(buf_ext-file.from-db-num)
                                      + {&delim-par} + buf_ext-file.FILE-NAME
                                      + {&delim-par} + {&reply} + {&comma-char} + v-lock-par)).
    end.
    else do:
      run nws/cr-route.p (
                    input {&send-cmd}
                    ,input ("command"
                            + {&delim-nws} + "run-file"
                            + {&delim-nws} + "ipck-chk.p"
                            + {&delim-nws} + (string(buf_Ext-file.db-num)
                            + {&delim-par} +  string(buf_ext-file.from-db-num)
                            + {&delim-par} +  buf_ext-file.FILE-NAME
                            + {&delim-par} + {&reply} + {&comma-char} + v-lock-par))
                  ,input ?
                  ,input string(0)
                  ) no-error .
    end.
  end.
  when {&reply} then do:
    find first buf_ext-file no-lock where
            buf_Ext-file.db-num = p-db-num
        and buf_Ext-file.from-db-num = p-from-db-num
        and buf_Ext-file.file-type = p-file-name
        and buf_Ext-file.file-name = p-file-name no-error.
    if available buf_Ext-file then do:
      find first buf_ext-file exclusive-lock where
              buf_Ext-file.db-num = p-db-num
          and buf_Ext-file.from-db-num = p-from-db-num
          and buf_Ext-file.file-type = p-file-name
          and buf_Ext-file.file-name = p-file-name .
      ASSIGN
      buf_Ext-file.STATUS_ = REPLACE(buf_Ext-file.STATUS_, {&ready}, "":U)
      buf_Ext-file.STATUS_ = REPLACE(buf_Ext-file.STATUS_, {&question-mark}, "":U)
      buf_Ext-file.STATUS_ = trim(buf_Ext-file.STATUS_, {&comma-char})
      buf_Ext-file.STATUS_ = REPLACE(buf_Ext-file.STATUS_, {&comma-char} + {&comma-char}, {&comma-char})
      buf_Ext-file.STATUS_ = buf_Ext-file.STATUS_ + {&comma-char} + p-lock-par
      buf_Ext-file.STATUS_ = trim(buf_Ext-file.STATUS_, {&comma-char})
      .
    end.
  end.
END CASE.
end. /*doe*/