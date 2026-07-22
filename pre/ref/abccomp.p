block-level on error undo, throw.
define input  parameter parparentproc  as widget-handle no-undo.
define input  parameter p-mode as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: abccomp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/abccomp.p $":U .
define variable vss-description as character no-undo init "Сравнение ABC (вызов разных режимов )".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
  define variable p-rez as character no-undo .
    run ref/abcanal.w ( input parParentProc ,  "b-sel,b-mark" , output p-rez) .
 if num-entries(p-rez) < 1 then do:
    message
    "Должно быть отмечено не менее одного анализа !!!"
    view-as alert-box information .
    return.
 end.
 if p-mode = "lvl":U then do:
  define variable v-lvl as character no-undo .
  v-lvl   = '1'.
  run gbl/d-prompt.w
   (  'title=':u + "Задание параметров отчета" + '\':u
    + 'text1=':u + "введите уровень группы" + '\':u
    + 'text2=':u + "" + '\':u
    + 'format=>9\':u
    + 'type=int\':u
    ,input-output v-lvl
    ).
  if return-value = 'false':u
  then do:
    return .
  end.
   if v-lvl = '0' or v-lvl = ? or v-lvl = '' then do:
      message "Не верно указан № уровня !" view-as alert-box error .
      return .
   end.
 end.
define variable var-i as integer   no-undo .
define variable var-kol as integer   no-undo .
var-kol = num-entries (p-rez).
define buffer buf1_abc-analysis for ub.abc-analysis.
define buffer buf_abc-analysis for ub.abc-analysis.
define variable g-ok as logical   no-undo .
define variable g1 as logical   no-undo init false  .
define variable g2 as logical   no-undo init false .
define variable g3 as logical   no-undo init false .
define variable g4 as logical   no-undo init false .
find first buf1_abc-analysis no-lock where recid(buf1_abc-analysis) = int(entry(1,p-rez )) no-error .
repeat var-i = 1 to var-kol :
   find first buf_abc-analysis no-lock where recid(buf_abc-analysis) = int(entry(var-i,p-rez )) no-error .
    if buf_abc-analysis.cral-id <> buf1_abc-analysis.cral-id and g1 = false  then do:
        message
            "Есть несоответствия по критерию анализа. " skip
            "Продолжать сравнение ?"
            view-as alert-box question
            button yes-no
            update g-ok .
            if g-ok = false then return .
            else g1 = true .
    end.
    if buf_abc-analysis.abc-hash-string-obj <> buf1_abc-analysis.abc-hash-string-obj and g2 = false then do:
        message
            "Есть несоответствия по списку объектов. " skip
            "Продолжать сравнение ?"
            view-as alert-box question
            button yes-no
            update g-ok .
            if g-ok = false then return .
            else g2 = true .
    end.
    if buf_abc-analysis.abc-hash-string-doc <> buf1_abc-analysis.abc-hash-string-doc and g3 = false then do:
        message
            "Есть несоответствия по списку типов документов. " skip
            "Продолжать сравнение ?"
            view-as alert-box question
            button yes-no
            update g-ok .
            if g-ok = false then return .
            else g3 = true .
    end.
end.
define variable v-user-name as character no-undo .
define variable vss-include-info2 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrfulnm in g#library
  (input  v-cntxt-userid
  ,output v-user-name
  )  .
 case p-mode :
      when "goods" then
          run ref/prexabc.p  ( parParentProc , p-rez , v-user-name) no-error .
      when "gds" then
          run rep/r-abcgds.p ( parParentProc , p-rez , v-user-name) no-error .
      when "grp" then
          run rep/r-abcgrp.p ( parParentProc , p-rez , v-user-name) no-error .
      when "prod" then
          run rep/r-abcpro.p ( parParentProc , p-rez , v-user-name) no-error .
      when "lvl" then
          run rep/r-abcsec.p ( parParentProc , p-rez , int(v-lvl) , v-user-name) no-error .
 end case .
