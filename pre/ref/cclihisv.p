block-level on error undo, throw.
define input parameter p-obj-type like ub.c-cli-hist.obj-type no-undo .
define input parameter p-obj-code like ub.c-cli-hist.obj-code no-undo .
define input parameter p-chip-num like ub.c-cli-hist.chip-num no-undo .
define input parameter p-corr-user-db-num like ub.c-cli-hist.corr-user-db-num no-undo .
define input parameter p-host-code like ub.c-cli-hist.host-code no-undo .
define input parameter p-subject like ub.c-cli-hist.subject no-undo .
define input parameter p-action   like ub.c-cli-hist.action no-undo .
define input parameter p-silent  as logical no-undo .
define output parameter p-description as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: 9263cff4388a, 1753, rls $":U .
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Feb 07 16:50:10 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cclihisv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/cclihisv.p $":U .
define variable vss-description as character no-undo init "Заполнение временной таблицы для показа изменений по таблицам истории клиента".
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
def var vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure clntattr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-code in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-value :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-value    like ub.clients-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-value in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-write :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.clients-attr.attr-value no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-write in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-exist :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-exist in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-delete :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-delete in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-copy-to :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-copy-to in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-auto-author-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-auto-author-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-by-type :
  define input  parameter p-archive-type      as character no-undo .
  define output parameter p-archive-attr-list as character no-undo .
  define variable vss-description as character no-undo initial "clntattr-get-archive-by-type-01: возвращает список атрибутов для складского архива".
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-by-type in g#attr-lib
      (input  p-archive-type
      ,output p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-vat-register :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-vat-register in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-requisite-alc-decl :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-requisite-alc-decl in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION gbclcode-is-this-db-code returns logical ( input p-db-num as integer
                                                    ,input p-range-type as character
                                                    ,input p-code as integer):
define variable v-seq-val as integer no-undo .
define buffer buf_code-range for ub.code-range.
find first buf_code-range no-lock where
          buf_code-range.db-num = p-db-num
    and  buf_code-range.range-type = p-range-type
    and  buf_code-range.stts = 'u'
    and buf_code-range.first-code <= p-code
    and buf_code-range.last-code >= p-code no-error .
if available buf_code-range then return yes.
CASE p-range-type:
  when 'pngb':U then do:
    v-seq-val = current-value(s-pngb-code, ub).
  end.
  when 'fmgb':U then do:
    v-seq-val = current-value(s-fmgb-code, ub).
  end.
END CASE.
if p-code <= v-seq-val then do:
  find first buf_code-range no-lock where
            buf_code-range.db-num = p-db-num
      and  buf_code-range.range-type = p-range-type
      and  buf_code-range.stts = 'a'
      and buf_code-range.first-code <= p-code
      no-error .
 if available buf_code-range then return yes.
end.
find first buf_code-range no-lock where
          buf_code-range.db-num = p-db-num
    and  buf_code-range.range-type = p-range-type
    and  buf_code-range.stts = 'f'
    and buf_code-range.first-code <= p-code
    and buf_code-range.last-code >= p-code
    no-error .
if available buf_code-range then return yes.
return no.
END FUNCTION.
FUNCTION gbclcode-is-this-db-code-short returns logical ( input p-db-num as integer
                                                    ,input p-range-type as character
                                                    ,input p-code as integer):
define variable v-seq-val as integer no-undo .
define buffer buf_code-range for ub.code-range.
CASE p-range-type:
  when 'pngb':U then do:
    v-seq-val = current-value(s-pngb-code, ub).
  end.
  when 'fmgb':U then do:
    v-seq-val = current-value(s-fmgb-code, ub).
  end.
END CASE.
if p-code <= v-seq-val then do:
  find first buf_code-range no-lock where
            buf_code-range.db-num = p-db-num
      and  buf_code-range.range-type = p-range-type
      and buf_code-range.first-code <= p-code
      and buf_code-range.last-code >= p-code no-error .
  if available buf_code-range then return yes.
end.
return no.
END FUNCTION.
FUNCTION gbclcode-is-this-db-role returns integer ( input p-role as character
                                                    ,input p-db-num as integer
                                                    ,input p-staff-code as integer
                                                    ,input p-date as date
                                                     ):
define buffer buf_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
find first buf_staff no-lock where
          buf_staff.role = p-role
      and buf_staff.role-level = 'db':U
      and buf_staff.db-num = p-db-num
      and buf_staff.staff-code = p-staff-code
      and buf_staff.date-end >= p-date use-index pi  no-error .
if available buf_staff then do:
  return buf_staff.psn-code.
end.
return 0.
end FUNCTION.
FUNCTION gbclcode-get-this-db-first-role returns integer ( input p-role as character
                                                          ,input p-db-num as integer
                                                          ,input p-date as date
                                                              ):
define buffer buf_staff for ub.staff.
define buffer buf2_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
for each  buf_staff no-lock where
          buf_staff.role = p-role
      and buf_staff.db-num = p-db-num,
first buf2_staff no-lock where
      buf2_staff.role = p-role
  and buf2_staff.role-level = 'db':U
  and buf2_staff.staff-code = buf_staff.staff-code
  and buf2_staff.date-start <= p-date
  and buf2_staff.date-end >= p-date
by buf_staff.staff-code
by date-start descending:
  return buf_staff.staff-code.
end.
end FUNCTION.
FUNCTION gbclcode-get-db-role returns integer ( input p-role as character
                                               ,input p-db-num as integer
                                               ,input p-psn-code as integer
                                               ,input p-date as date
                                               ,output p-c-password as character
                                                     ):
define buffer buf_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
find first buf_staff no-lock where
          buf_staff.role = p-role
      and buf_staff.role-level = 'db':U
      and buf_staff.db-num = p-db-num
     and buf_staff.date-end >= p-date
     and buf_staff.psn-code = p-psn-code use-index irole-psn no-error .
if available buf_staff
then do:
  assign
  p-c-password = buf_staff.password.
  return buf_staff.staff-code.
end.
p-c-password = ''.
return 0.
end FUNCTION.
FUNCTION gbclcode-is-psn-role returns integer (
                                              input p-role as character
                                              ,input p-psn-code as integer
                                              ,input p-date as date
                                                  ):
define buffer buf_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
for each buf_staff no-lock where
          buf_staff.psn-code = p-psn-code
     and  buf_staff.role = p-role
by buf_staff.role-level
by buf_staff.date-start
     :
  if  buf_staff.date-start <= p-date and
  buf_staff.date-end >= p-date  then do:
    return buf_staff.staff-code.
  end.
end.
return 0.
end FUNCTION.
FUNCTION gbclcode-get-role-name returns character ( input p-role as character):
define variable v-role-name as character no-undo .
assign
v-role-name = entry (lookup (p-role, 'C,S':U) + 1, ',':U + 'Кассир,Продавец':U)
no-error .
return v-role-name.
END.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION gbclcode-get-position returns character ( input p-role as character
                                                  ,input p-role-level as character
                                                  ,input p-work-place as character
                                                  ,input p-staff-code as integer
                                                             ):
define variable v-role-name as character no-undo .
define variable v-role-level as character no-undo .
define variable v-staff-code as integer no-undo .
assign
v-role-name = entry (lookup (p-role, 'C,S':U) + 1, ',':U + 'Кассир,Продавец':U)
v-role-level = substitute("&1 &2", entry (lookup (p-role-level, 'global,db,firm,object':U) + 1, ',':U + 'Глобально,БД,Фирма,Объект':U) , p-work-place)
v-staff-code = p-staff-code
no-error .
return substitute("&1, &2, Код &3"
                ,v-role-name
                ,v-role-level
                ,(if p-staff-code = 0 then chr(63) else string(p-staff-code))).
END.
FUNCTION gbclcode-get-work-place returns character (
                                                input p-role as character
                                               ,input p-role-level as character
                                               ,input p-db-num as integer
                                               ,input p-host-code as integer
                                               ,input p-obj-type as character
                                               ,input p-obj-code as integer
                                               ) :
define variable v-work-place as character no-undo .
define variable v-obj-type as character no-undo .
  case p-role-level:
    when 'db':U then do:
      v-work-place = string(p-db-num, "99999").
    end.
    when 'firm':U then do:
      v-work-place = string(p-host-code, "99999").
    end.
    when 'object':U then do:
      assign
      v-work-place = p-obj-type + string(p-obj-code, "999999999")
      .
    end.
  END CASE.
  return v-work-place.
END FUNCTION.
FUNCTION gbclcode-get-level-last-code returns integer (
                                                        input p-role as character
                                                      , input p-role-level as character
                                                      , input p-work-place as character
                                                      , input p-date-start as date
                                                      ):
DEFINE VARIABLE v-today as date no-undo .
define buffer buf_staff for ub.staff.
if p-work-place = chr(63) then return ?.
if p-date-start = ? then do:
  v-today = today .
end.
else do:
  v-today = p-date-start.
end.
find last buf_staff no-lock where
          buf_staff.role = p-role
     and  buf_staff.role-level = p-role-level
     and  buf_staff.work-place = p-work-place
     and  buf_staff.date-start <= v-today + 1
     and  buf_staff.date-end >= v-today + 1
     use-index pi  no-error .
if available buf_staff
then return buf_staff.staff-code.
return 0.
end FUNCTION.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cur-time :
   define output parameter p-today as date      no-undo .
   define output parameter p-time  as integer   no-undo .
  do
  on error undo, return error
  :
    define variable v-date1 as date      no-undo .
    define variable v-date2 as date      no-undo .
    define variable v-time  as integer   no-undo .
    assign
      v-date1 = today
      v-time  = time
      v-date2 = today
    .
    if v-date1 <> v-date2
    then do:
      assign
        v-date1 = today
        v-time  = v-time
      .
    end.
    assign
      p-today = v-date1
      p-time  = v-time
    .
  end.
end.
function cur-time-date returns character
:
  return string(today, '99/99/9999':U) .
end.
function cur-time-mjd returns decimal
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return integer(v-date) - 2400002 + (v-time / 86400) .
end.
function cur-time-get-ending-index returns integer
(input p-number as integer
)
:
  if p-number < 0
  or p-number = ?
  then do:
    return 1 .
  end.
  define variable v-rest as integer   no-undo .
  assign
    p-number = p-number modulo 100
  .
  if p-number < 20
  then do:
    assign
      v-rest = p-number
    .
  end.
  else do:
    assign
      v-rest = p-number modulo 10
    .
  end.
  case v-rest :
    when 1
    then do:
      return 2 .
    end.
    when 2 or
    when 3 or
    when 4
    then do:
      return 3 .
    end.
    otherwise do:
      return 1 .
    end.
  end case .
end.
procedure cur-time-mjd-to-date :
   define input  parameter i-mjd-diff as decimal no-undo.
   define output parameter o-Date     as date    no-undo.
   define output parameter o-Time     as integer no-undo.
   define variable v-day-number as integer   no-undo .
   if    i-mjd-diff < 0
      or i-mjd-diff = ?
   then do:
      return "?" .
   end.
   assign
      v-day-number = truncate(i-mjd-diff,0).
      o-Date = date(v-day-number + 2400002).
      o-Time = truncate((i-mjd-diff - v-day-number) * 86400, 0)
  .
end.
function cur-time-mjd-to-string returns character
(input p-mjd-diff as decimal
)
:
  define variable v-day-number as integer   no-undo .
  define variable v-seconds    as integer   no-undo .
  define variable v-hour       as integer   no-undo .
  define variable v-min        as integer   no-undo .
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дня" ] .
  define variable v-hour-name   as character no-undo extent 3 initial [  "часов",     "час",    "часа" ] .
  define variable v-min-name    as character no-undo extent 3 initial [  "минут",  "минута",  "минуты" ] .
  define variable v-second-name as character no-undo extent 3 initial [ "секунд", "секунда", "секунды" ] .
  if p-mjd-diff < 0
  or p-mjd-diff = ?
  then do:
    return "?" .
  end.
  assign
    v-day-number = integer(truncate(p-mjd-diff,0))
    v-seconds    = truncate((p-mjd-diff - v-day-number) * 86400, 0)
  .
  if v-seconds > 86400
  then do:
    assign
      v-seconds = 86400 - 1
    .
  end.
  if v-seconds < 0
  then do:
    assign
      v-seconds = 0
    .
  end.
  assign
    v-hour = truncate(v-seconds / 3600, 0)
  .
  assign
    v-seconds = v-seconds modulo 3600
  .
  assign
    v-min = truncate(v-seconds / 60, 0)
  .
  assign
    v-seconds = v-seconds modulo 60
  .
  return
      (if v-day-number <> 0
        then string(v-day-number) + " " + v-day-name[cur-time-get-ending-index(v-day-number)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0
        then string(v-hour) + " " + v-hour-name[cur-time-get-ending-index(v-hour)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0 or v-min <> 0
        then string(v-min) + " " + v-min-name[cur-time-get-ending-index(v-min)] + " "
        else ""
      )
    + string(v-seconds) + " " + v-second-name[cur-time-get-ending-index(v-seconds)]
    .
end.
function cur-time-string returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.
function cur-time-string-sec returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .
end.
function cur-time-custom  returns character
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return
    p-prefix
    + string(v-date, p-date-format)
    + p-delimiter
    + string(v-time, p-time-format)
    + p-suffix
    .
end.
function cur-time-print  returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
end.
function cur-time-datetime returns datetime
:
  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.
end.
function cur-time-string-msec returns character
:
  define variable v-date as datetime  no-undo .
  v-date = now.
  return string(v-date) .
end.
def var vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-key-rec :
  define input  parameter p-tbl-name    as character no-undo.
  define input  parameter p-bh_tbl-name as handle    no-undo.
  define output parameter p-key-rec     as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-rec). endkey", vss-workfile )
  :
    define variable fh               as handle    no-undo .
    define variable v-ok             as logical   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    if p-tbl-name = ?
      or p-tbl-name = "":U
    then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info4 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info4, p-tbl-name ).
    end.
    assign
      p-key-rec = p-tbl-name
      v-inform  = p-bh_tbl-name:index-information(1)
      v-ind     = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = p-bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info4, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info4, v-inform, p-tbl-name ).
      end.
      do v-ind = 1 to v-idx-field-qnty by 2
      on error undo, return error
      :
        assign
          fh = p-bh_tbl-name:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) ).
          p-key-rec = p-key-rec + chr(3) + substitute("&1", replace(fh:buffer-value(),chr(3),chr(2) + chr(9) + chr (2)))
        .
      end.
    end.
    if p-key-rec = ? then do:
      assign
        p-key-rec = "":U
      .
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info4, p-tbl-name ).
    end.
  end.
  return.
end procedure.
procedure gen-where-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character  no-undo.
  define input  parameter p-key-rec    as character  no-undo.
  define input  parameter p-key-handle as handle     no-undo .
  define input  parameter p-db-name    as character  no-undo .
  define input  parameter p-tt-handle  as handle     no-undo .
  define output parameter o-Where      as character  no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable fh_key           as handle    no-undo .
    define variable fh_search        as handle    no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-field-name     as character no-undo .
    define variable v-field-val      as character no-undo .
    define variable v-word-link      as character no-undo .
    define variable vTable           as character no-undo.
    define variable bh_tbl-key       as handle    no-undo .
    assign
      p-key-rec = trim( p-key-rec )
    .
    if p-key-handle <> ? then do:
      if not valid-handle(p-key-handle)
         or p-key-handle:type <> "buffer"
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info4 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info4, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info4 ).
      end.
    end.
    assign
      vTable = entry( 1 , p-key-rec, chr(3) )
    .
    if p-tt-handle <> ?
      and ( not valid-handle(p-tt-handle)
            or p-tt-handle:type <> "buffer"
          )
    then do:
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info4, vTable, chr(10) ).
    end.
    if p-tt-handle = ? then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    else do:
      create buffer bh_tbl-name for table p-tt-handle:table-handle .
    end.
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info4, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info4, v-inform, vTable ).
    end.
    assign
      o-where     = "where":U
      v-word-link = "":U
      v-field-num = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld = 0
    .
    if i-tablekey ne "" and i-tablekey ne ?
    then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tablekey )
      .
      create buffer bh_tbl-key for table v-full-tbl-name .
    end.
    if i-tableSerach ne "" and i-tableSerach ne ?
    then do:
      delete object bh_tbl-name no-error.
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if p-key-handle = ?
        and v-count-fld > v-field-num
      then do:
        leave block_where.
      end.
      define variable VfieldKeyTable as handle no-undo.
      assign
        v-field-name = entry( 4 + v-ind, v-inform, ",":U )
        fh_search    = bh_tbl-name:buffer-field( v-field-name )
      .
      if     bh_tbl-key ne ?
      then do:
         VfieldKeyTable = bh_tbl-key:buffer-field( v-field-name ) no-error.
         if VfieldKeyTable eq ?
         then next block_where.
      end.
      if v-full-tbl-name ne "" and v-full-tbl-name ne ?
      then
         o-where = substitute( "&1 &2 &3.&4 =", o-where, v-word-link,v-full-tbl-name, v-field-name ).
      else
         o-where = substitute( "&1 &2 &3 =", o-where, v-word-link, v-field-name ).
      if p-key-handle = ? then do:
        assign
          v-field-val = replace (entry( v-count-fld + 1 , p-key-rec, chr(3) ),chr(2) + chr(9) + chr (2),chr(3))
        .
      end.
      else do:
        assign
          fh_key = p-key-handle:buffer-field( v-field-name )
        .
        if fh_key = ?
          or not valid-handle( fh_key )
        then do:
          delete object bh_tbl-name.
          if     bh_tbl-key ne ?
          then
             delete object bh_tbl-key.
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info4, p-key-handle:name, v-field-name ).
        end.
        assign
          v-field-val = fh_key:buffer-value
        .
      end.
      if fh_search:data-type ="character":U then do:
        assign
          v-field-val = replace( v-field-val, '~~':U, '~~~~':U )
          v-field-val = replace( v-field-val, '"':U, '~~"':U )
          v-field-val = replace( v-field-val, "'":U, "~~'":U )
          v-field-val = replace( v-field-val, '~{':U, '~~~{':U )
          v-field-val = replace( v-field-val, '~}':U, '~~~}':U )
          v-field-val = replace( v-field-val, '~\':U, '~~~\':U )
          v-field-val = replace( v-field-val, chr(10), '~~n':U )
          v-field-val = replace( v-field-val, chr(9), '~~t':U )
          v-field-val = replace( v-field-val, chr(13), '~~r':U )
          v-field-val = replace( v-field-val, chr(27), '~~E':U )
          v-field-val = replace( v-field-val, chr(8), '~~b':U )
          v-field-val = replace( v-field-val, chr(12), '~~f':U )
          v-field-val = substitute( '"&1"', v-field-val )
        .
      end.
      assign
        o-where = substitute( "&1 &2", o-where, v-field-val )
      .
      if v-word-link = "":U then do:
        assign
          v-word-link = "and":U
        .
      end.
    end.
    delete object bh_tbl-name.
    if     bh_tbl-key ne ?
    then
       delete object bh_tbl-key.
    if p-key-handle = ?
      and v-count-fld <> v-field-num
    then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info4, vTable ).
    end.
  end.
end procedure.
procedure gen-hn-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character no-undo.
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  define variable v-full-tbl-name as character no-undo.
  define variable v-where         as character no-undo.
  define variable bh_tbl-name     as handle    no-undo.
  define variable vTable          as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile ):
      run gen-where-keyr-tab(i-tableSerach,
                             i-tablekey,
                             p-key-rec,
                             p-key-handle,
                             p-db-name,
                             p-tt-handle,
                             output v-where).
      if i-tableSerach ne "" and i-tableSerach ne ?
      then do:
         v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach ).
         create buffer bh_tbl-name for table v-full-tbl-name .
      end.
      else do:
         if p-tt-handle = ? then do:
            assign
               vTable = entry( 1 , p-key-rec, chr(3) )
            .
            v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable ).
            create buffer bh_tbl-name for table v-full-tbl-name .
         end.
         else do:
            create buffer bh_tbl-name for table p-tt-handle:table-handle .
         end.
      end.
      if p-tt-handle = ? then do:
         bh_tbl-name:find-first( v-where, p-stts-lock ) no-error .
      end.
      else do:
         bh_tbl-name:find-first( v-where ) no-error .
      end.
      o-hn = bh_tbl-name.
   end.
end procedure.
procedure gen-hn-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output o-hn).
end.
procedure gen-row-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter p-tbl-row    as rowid     no-undo.
  define output parameter p-tbl-name   as character no-undo.
  define variable vHn as handle no-undo.
    run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output vHn).
    p-tbl-row = if vHn:available then vHn:rowid else ?.
    p-tbl-name =  vHn:table.
    delete object vHn no-error.
  if p-tbl-row = ? then do:
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info4, p-tbl-name, p-key-rec ).
  end.
  else do:
    return.
  end.
end procedure.
procedure gen-key-fv :
  define input  parameter p-key-rec    as character no-undo .
  define output parameter p-field-list as character no-undo .
  define output parameter p-value-list as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info4 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info4 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info4, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info4, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      p-value-list = "":U
      v-delim-key  = "":U
      v-field-num  = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.
      assign
        p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U )
        p-value-list = p-value-list + v-delim-key + entry( v-count-fld + 1 , p-key-rec, chr(3) )
      .
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info4, v-tbl-name ).
    end.
  end.
end procedure.
procedure gen-key-field :
  define input  parameter p-table      as character no-undo .
  define output parameter p-field-list as character no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-table = ?
      or p-table = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info4 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info4 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info4, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info4, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      v-delim-key  = "":U
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U ).
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
  end.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
procedure thbjattr_code :
   define input  parameter p-upper-code     as character no-undo .
   define input  parameter p-code           as character no-undo .
   define output parameter p-label          as character no-undo .
   define output parameter p-user-can-edit  as logical   no-undo .
   define output parameter p-output-display as logical   no-undo .
   define output parameter p-other          as character no-undo .
   define output parameter p-prop-list      as character no-undo .
   define output parameter p-prop-type-list as character no-undo .
   define output parameter p-prop-label-list as character no-undo .
   define output parameter p-global          as logical no-undo .
   define output parameter p-host           as logical no-undo .
   define output parameter p-shop           as logical no-undo .
   define output parameter p-store          as logical no-undo .
   define output parameter p-db             as logical no-undo .
   define variable p-region as logical no-undo.
   run thbjattr_code_reg in this-procedure (
                                            p-upper-code,
                                            p-code,
                                            output p-label,
                                            output p-user-can-edit,
                                            output p-output-display,
                                            output p-other,
                                            output p-prop-list,
                                            output p-prop-type-list,
                                            output p-prop-label-list,
                                            output p-global,
                                            output p-host,
                                            output p-shop,
                                            output p-store,
                                            output p-db,
                                            output p-region
                                            ).
end procedure.
procedure thbjattr_code_reg :
define input  parameter p-upper-code     as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-label          as character no-undo .
define output parameter p-user-can-edit  as logical   no-undo .
define output parameter p-output-display as logical   no-undo .
define output parameter p-other          as character no-undo .
define output parameter p-prop-list      as character no-undo .
define output parameter p-prop-type-list as character no-undo .
define output parameter p-prop-label-list as character no-undo .
define output parameter p-global          as logical no-undo .
define output parameter p-host           as logical no-undo .
define output parameter p-shop           as logical no-undo .
define output parameter p-store          as logical no-undo .
define output parameter p-db             as logical no-undo .
define output parameter p-region         as logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_code in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-label
    ,output p-user-can-edit
    ,output p-output-display
    ,output p-other
    ,output p-prop-list
    ,output p-prop-type-list
    ,output p-prop-label-list
    ,output p-global
    ,output p-host
    ,output p-shop
    ,output p-store
    ,output p-db
    ,output p-region
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info5, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_tooltip :
define input  parameter p-upper-code  as character no-undo .
define input  parameter p-code      as character no-undo .
define output parameter p-tooltip   as character no-undo .
define output parameter p-label     as character no-undo .
define output parameter p-tooltip-code as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_tooltip in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-tooltip
    ,output p-label
    ,output p-tooltip-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_legacy :
define input  parameter p-upper-code     as character no-undo .
define output parameter p-level-way      as character no-undo .
define output parameter p-up-way         as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_legacy in g#attr-lib
    (input  p-upper-code
    ,output p-level-way
    ,output p-up-way
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info5, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_value :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define output parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define output parameter p-value-date    like ub.thbj-attr.property-value-date no-undo .
define output parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define output parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define output parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
define output parameter p-type     as character no-undo .
define output parameter p-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_value in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-value-character
    ,output p-value-date
    ,output p-value-decimal
    ,output p-value-integer
    ,output p-value-logical
    ,output p-type
    ,output p-found
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_get-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-param-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-mode as character no-undo .
define input-output parameter table-handle p-tth.
define output parameter p-all-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_get-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-param-code
    ,input  p-mode
    ,input-output table-handle p-tth
    ,output p-all-found
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_write :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define input  parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define input  parameter p-value-date like ub.thbj-attr.property-value-date no-undo .
define input  parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define input  parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define input  parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_write in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,input  p-value-character
    ,input  p-value-date
    ,input  p-value-decimal
    ,input  p-value-integer
    ,input  p-value-logical
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_set-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter table-handle p-tth.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_set-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  table-handle p-tth
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_delete :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code       like ub.thbj-attr.prop-code  no-undo .
define output parameter p-deleted  as logical no-undo.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-deleted
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_delete-section :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_manual-edit :
define input  parameter p-ucode          as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-section-num    as integer no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_manual-edit in g#attr-lib
    (input  p-ucode
    ,input  p-code
    ,output  p-section-num
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-chg-fields as character no-undo.
define variable v-old-fields as character no-undo.
define variable v-new-fields as character no-undo.
define variable ii as integer no-undo.
define variable v-mess as character no-undo .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION get-region RETURNS CHARACTER
  ( input parhost-code as integer, input parobj-type as character, input parobj-code as integer ) :
  define variable par-region as character no-undo.
  if parhost-code = 0 and
       parobj-type = "":U and
       parobj-code = 0 then do:
       par-region = "Глобально".
       return par-region.
    end.
    if parobj-type = 'орг':U then do:
       par-region = fill(chr(32), 2) + "Фирма" + chr(32) + string(parhost-code).
       return par-region.
    end.
    if parobj-type = 'регион':U
    then do:
       par-region = fill(chr(32), 2) + "Регион" + chr(32) + string(parobj-code).
       return par-region.
    end.
    par-region = fill(chr(32), 4) + parobj-type + chr(32) + string(parobj-code).
    return par-region.
END FUNCTION.
FUNCTION get-objregion RETURNS CHARACTER
  (  input parobj-type as character, input parobj-code as integer ) :
  define variable par-region as character no-undo.
  if  parobj-type = "":U and
      parobj-code = 0
  then do:
     par-region = "Глобально".
  end.
  else if parobj-type = 'орг':U
  then do:
     par-region = fill(chr(32), 2) + "Фирма" + chr(32) + string(parobj-code).
  end.
  else if parobj-type = 'регион':U
  then do:
     par-region = fill(chr(32), 2) + "Регион" + chr(32) + string(parobj-code).
  end.
  else
     par-region = fill(chr(32), 4) + parobj-type + chr(32) + string(parobj-code).
  return par-region.
END FUNCTION.
FUNCTION calldscr returns character ( input p-call-id as character):
define variable v-descr as character no-undo .
define variable v-field-list as character no-undo .
define variable v-value-list as character no-undo.
define variable v-prop-label as character no-undo .
define variable v-node-label as character no-undo .
define variable v-dt-code as integer no-undo .
define variable v-host-code as integer no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
define variable v-label as character no-undo .
define variable v-node-code as integer no-undo .
define buffer buf_prop-head for ub.prop-head.
define buffer buf_prop-ref for ub.prop-ref.
define buffer buf_prop-map for ub.prop-map.
run gen-key-fv in this-procedure ( input p-call-id
                                  ,output v-field-list
                                  ,output v-value-list) no-error .
if error-status:error then return p-call-id.
CASE entry(1, p-call-id, chr(3)):
  when 'dis-card-type':U then do:
    v-descr = substitute("Тип ДК: эмитент &1 тип: &2"
                         ,integer(entry(lookup("emitent-host-code", v-field-list, chr(3)), v-value-list, chr(3)) )
                         ,entry(lookup("type", v-field-list, chr(3)), v-value-list, chr(3))
                         ).
  end.
  when 'dis-card':U then do:
    v-descr = substitute("ДК: № &1"
                         ,entry(lookup("d-card", v-field-list, chr(3)), v-value-list, chr(3))
                         ).
  end.
  when 'dis-card-property':U then do:
    v-dt-code = integer(entry(lookup("dt-code", v-field-list, chr(3)), v-value-list, chr(3)) ).
    v-node-code = integer(entry(lookup("node-code", v-field-list, chr(3)), v-value-list, chr(3)) ).
    v-host-code = integer(entry(lookup("host-code", v-field-list, chr(3)), v-value-list, chr(3)) ).
    v-obj-type = entry(lookup("obj-type", v-field-list, chr(3)), v-value-list, chr(3)) .
    v-obj-code = integer(entry(lookup("obj-code", v-field-list, chr(3)), v-value-list, chr(3)) ).
    find first buf_prop-ref no-lock where
              buf_prop-ref.dt-code = v-dt-code no-error .
    if available buf_prop-ref then do:
      find first buf_prop-head no-lock where
                buf_prop-head.dtm-code = buf_prop-ref.dtm-code no-error .
      v-prop-label = buf_prop-head.prop-label.
      find first buf_prop-map no-lock where
                buf_prop-map.dtm-code = buf_prop-ref.dtm-code
            and buf_prop-map.node-code = v-node-code no-error .
      if available buf_prop-map then do:
        v-label = buf_prop-map.node-label.
      end.
    end.
    v-descr = substitute("ДК: № &1 &2:&3 &4"
                         ,entry(lookup("d-card", v-field-list, chr(3)), v-value-list, chr(3))
                         ,v-prop-label
                         ,v-label
                         ,get-region(v-host-code, v-obj-type, v-obj-code)
                         ).
  end.
  when 'clients':U then do:
    v-descr = substitute("&1&2"
                         ,entry(lookup("obj-type", v-field-list, chr(3)), v-value-list, chr(3))
                         ,integer(entry(lookup("obj-code", v-field-list, chr(3)), v-value-list, chr(3)) )
                         ).
  end.
  when 'ext-system':U then do:
    v-descr = substitute("Внешняя система &1"
                         ,integer(entry(lookup("esys-id", v-field-list, chr(3)), v-value-list, chr(3)))
                         ).
  end.
  WHEN 'thbj-attr':U then do:
    if entry(lookup("upper-prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'rum':U
    or entry(lookup("upper-prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'rum_obj':U
    then do:
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'goods':U then do:
        v-descr = "Операции с товарами".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'clients':U then do:
        v-descr = "Операции с клиентами".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'gds-grp':U then do:
        v-descr = "Операции с группами товаров".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'cli-grp':U then do:
        v-descr = "Операции с группами клиентов".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'chk-doc_ibs-th':U then do:
        v-descr = "Операции с чеками на POS IBS-TH".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'chk-doc_ibs-th-mob':U then do:
        v-descr = "Операции с чеками на POS IBS-TH-MOB".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'edoc':U then do:
        v-descr = "Операции в системе электронного документооборота".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'thref':U then do:
        v-descr = "Операции со справочниками".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'pdf':U then do:
        v-descr = "Операции с ДНЦ и переоценками".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'rep':U then do:
        v-descr = "Отчеты".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'ord':U then do:
        v-descr = "Операции с заказами".
      end.
    end.
  end.
  when 'cash-desk':U then do:
    v-descr = substitute("БД &1 Маг &2 Касса № &4 &3"
                         ,entry(lookup("db-num", v-field-list, chr(3)), v-value-list, chr(3))
                         ,entry(lookup("obj-code", v-field-list, chr(3)), v-value-list, chr(3))
                         ,entry(lookup("cash-num", v-field-list, chr(3)), v-value-list, chr(3))
                         ,entry(lookup("pos-type", v-field-list, chr(3)), v-value-list, chr(3))
                         ).
  end.
  when 'ext-file':U then do:
    v-descr = substitute("БД &1 Файл № &3 (из БД &2)"
                         ,entry(lookup("db-num", v-field-list, chr(3)), v-value-list, chr(3))
                         ,entry(lookup("from-db-num", v-field-list, chr(3)), v-value-list, chr(3))
                         ,entry(lookup("file-num", v-field-list, chr(3)), v-value-list, chr(3))
                         ).
  end.
end case.
return v-descr.
end function.
define variable v-thbj-attr-uniq-key-rec as character no-undo .
define buffer current_c-thbj-attr for ub.c-thbj-attr.
function  getPSwd returns character (istr as char ):
   return fill("*",length(istr)).
end.
procedure thbj-attr-self-proc :
define input parameter p-action as integer no-undo .
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define variable v-tooltip-code as character no-undo .
define variable v-global as logical no-undo .
define variable v-host as logical no-undo .
define variable v-shop as logical no-undo .
define variable v-store as logical no-undo .
define variable v-db as logical   no-undo .
define variable v-other as character no-undo .
define variable v-user-can-edit as logical no-undo .
define variable v-output-display as logical no-undo .
define variable v-prop-list as character no-undo .
define variable v-prop-type-list as character no-undo .
define variable v-prop-label-list as character no-undo .
define variable v-fields-name-list as character no-undo .
define variable v-label-param as character no-undo .
define variable v-prop-code-num as integer no-undo .
define variable v-type as character no-undo .
do
on error undo, return error
:
  run thbjattr_tooltip in this-procedure (
                input  current_c-thbj-attr.upper-prop-code
              ,input  current_c-thbj-attr.prop-code
              ,output v-tooltip
              ,output v-label
              ,output v-tooltip-code
              ) no-error .
  p-description = "Параметр" + chr(32) + v-label.
  run thbjattr_code in this-procedure (
      input  current_c-thbj-attr.upper-prop-code
      ,input current_c-thbj-attr.prop-code
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ,output v-prop-list
      ,output v-prop-type-list
      ,output v-prop-label-list
      ,output v-global
      ,output v-host
      ,output v-shop
      ,output v-store
      ,output v-db
      ) no-error .
  assign
  v-prop-code-num = lookup(current_c-thbj-attr.prop-code, v-prop-list)
  v-type = entry(v-prop-code-num, v-prop-type-list)
  no-error
  .
  if current_c-thbj-attr.subject = 'thbj-attr':U
  or current_c-thbj-attr.subject = ''
  then do:
        v-label-param =  "upper-prop-code" + chr(4) + "Группа параметра" + chr(4) + "" + chr(8)
                    + " prop-code" + chr(4) + "Параметр" + chr(4) + "" + chr(8)
                    + "prop-value-type" + chr(4) + "Тип Значения" + chr(4) + "" + chr(8)
                    + "obj-type" + chr(4) + "Тип объекта" + chr(4) + "" + chr(8)
                    + "obj-code" + chr(4) + "Код объекта" + chr(4) + ""  .
    case v-type:
      when 'character':U then do:
         if     current_c-thbj-attr.upper-prop-code eq "gismt"
            and (current_c-thbj-attr.prop-code eq "oflinepswd"
                 or current_c-thbj-attr.prop-code eq "proxypswd"
                 or current_c-thbj-attr.prop-code eq "MaxApiToken")
         then v-label-param = "property-value-character" + chr(4) + "Значение(строк.)" + chr(4) + "getpswd" + chr(8) +
                      v-label-param.
         else assign
             v-label-param = "property-value-character" + chr(4) + "Значение(строк.)" + chr(4) + "" + chr(8) +
                      v-label-param.
        v-fields-name-list = "property-value-character," + "upper-prop-code, prop-code,prop-value-type,obj-type,obj-code".
      end.
      when 'date':U then do:
        v-label-param = "property-value-date" + chr(4) + "Значение(Дата)" + chr(4) + "" + chr(8)  +
                      v-label-param.
        v-fields-name-list = "property-value-date," + "upper-prop-code, prop-code,prop-value-type,obj-type,obj-code".
      end.
      when 'decimal':U then do:
        v-label-param = "property-value-decimal" + chr(4) + "Значение" + chr(4) + "" + chr(8) +
                        v-label-param.
        v-fields-name-list = "property-value-decimal," + "upper-prop-code, prop-code,prop-value-type,obj-type,obj-code".
      end.
      when 'integer':U then do:
        v-label-param = "property-value-integer" + chr(4) + "Значение" + chr(4) + "" + chr(8) +
                        v-label-param.
        v-fields-name-list = "property-value-integer," + "upper-prop-code, prop-code,prop-value-type,obj-type,obj-code".
      end.
      when 'logical':U then do:
        v-label-param = "property-value-logical" + chr(4) + "Значение" + chr(4) + "" + chr(8) +
        v-label-param.
        v-fields-name-list = "property-value-logical," + "upper-prop-code, prop-code,prop-value-type,obj-type,obj-code".
      end.
    end case.
    run proc-full-temp-changes in this-procedure (
                                                input p-action = integer('1':U)
                                                ,input p-action = integer('99':U)
                                                ,input  buffer current_c-thbj-attr:handle
                                                ,input  'thbj-attr':U
                                                ,input  v-fields-name-list
                                                ,input  v-label-param).
  end.
end.
end procedure.
procedure rp-by-call-proc :
define output parameter p-description as character no-undo .
define buffer current_c-rp-by-call for ub.c-rp-by-call .
  do
  on error undo, return error
  :
    find first current_c-rp-by-call no-lock where
               current_c-rp-by-call.chip-num = current_c-thbj-attr.chip-num
           AND current_c-rp-by-call.corr-user-db-num = current_c-thbj-attr.corr-user-db-num
           AND current_c-rp-by-call.call_id = v-thbj-attr-uniq-key-rec no-error .
    if not avail current_c-rp-by-call then do:
       v-mess = "Неверная ссылка на c-rp-by-call в таблице c-thbj-attr".
       run err-mess(input-output v-mess).
    end.
define variable v-label-param as character no-undo .
v-label-param =
  "call_id" + chr(4) + "Точка вызова" + chr(4) + "calldscr" + chr(8)
 + "call#_id" + chr(4) + "Уник.идент.точки вызова" + chr(4) + "" + chr(8)
 + "profile_id" + chr(4) + "Профайл" + chr(4) + "" .
 run proc-full-temp-changes in this-procedure (
                                             input  (current_c-thbj-attr.action = integer('1':U))
                                            ,input  (current_c-thbj-attr.action = integer('99':U))
                                            ,input  buffer current_c-rp-by-call:handle
                                            ,input  'rp-by-call':U
                                            ,input  "call_id,call#_id,profile_id"
                                            ,input  v-label-param).
end.
end procedure.
procedure rule-by-call-proc :
define output parameter p-description as character no-undo .
define buffer current_c-rule-by-call for ub.c-rule-by-call .
  do
  on error undo, return error
  :
    find first current_c-rule-by-call no-lock where
               current_c-rule-by-call.chip-num = current_c-thbj-attr.chip-num
           AND current_c-rule-by-call.corr-user-db-num = current_c-thbj-attr.corr-user-db-num
           AND current_c-rule-by-call.call_id = v-thbj-attr-uniq-key-rec no-error .
    if not avail current_c-rule-by-call then do:
       v-mess = "Неверная ссылка на c-rule-by-call в таблице c-thbj-attr".
       run err-mess(input-output v-mess).
    end.
define variable v-label-param as character no-undo .
v-label-param =
  "call_id" + chr(4) + "Точка вызова" + chr(4) + "calldscr" + chr(8)
 + "call#_id" + chr(4) + "Уник.идент.точки вызова" + chr(4) + "" + chr(8)
 + "profile_id" + chr(4) + "Профайл" + chr(4) + ""  + chr(8)
 + "can-calc" + chr(4) + "Включено" + chr(4) + ""  + chr(8)
 + "can-run" + chr(4) + "Может быть включено" + chr(4) + ""  + chr(8)
 + "codex_id" + chr(4) + "Кодекс" + chr(4) + ""  + chr(8)
 + "ruleset_id" + chr(4) + "Набор правил" + chr(4) + ""  + chr(8)
 + "order_id" + chr(4) + "Порядок вызова" + chr(4) + ""  + chr(8)
 + "rule_id" + chr(4) + "№ правила" + chr(4) + ""  + chr(8)
 + "algo-des" + chr(4) + "Описание правила" + chr(4) + ""  + chr(8)
 + "is_dynamic" + chr(4) + "Отключаемое" + chr(4) + ""
 .
 run proc-full-temp-changes in this-procedure (
                                             input  (current_c-thbj-attr.action = integer('1':U))
                                            ,input  (current_c-thbj-attr.action = integer('99':U))
                                            ,input  buffer current_c-rule-by-call:handle
                                            ,input  'rule-by-call':U
                                            ,input  "call_id,call#_id,profile_id,can-calc,can-run,codex_id,ruleset_id,order_id,algo-des,rule_id,is_dynamic"
                                            ,input  v-label-param).
end.
end procedure.
procedure rule-call-param-proc :
define output parameter p-description as character no-undo .
define buffer current_c-rule-call-param for ub.c-rule-call-param .
  do
  on error undo, return error
  :
    find first current_c-rule-call-param no-lock where
               current_c-rule-call-param.chip-num = current_c-thbj-attr.chip-num
           AND current_c-rule-call-param.corr-user-db-num = current_c-thbj-attr.corr-user-db-num
           AND current_c-rule-call-param.call_id = v-thbj-attr-uniq-key-rec no-error .
    if not avail current_c-rule-call-param then do:
       v-mess = "Неверная ссылка на c-rule-call-param в таблице c-thbj-attr".
       run err-mess(input-output v-mess).
    end.
define variable v-label-param as character no-undo .
v-label-param =
  "call_id" + chr(4) + "Точка вызова" + chr(4) + "calldscr" + chr(8)
 + "call#_id" + chr(4) + "Уник.идент.точки вызова" + chr(4) + "" + chr(8)
 + "profile_id" + chr(4) + "Профайл" + chr(4) + ""  + chr(8)
 + "codex_id" + chr(4) + "Кодекс" + chr(4) + ""  + chr(8)
 + "ruleset_id" + chr(4) + "Набор правил" + chr(4) + ""  + chr(8)
 + "order_id" + chr(4) + "Порядок вызова" + chr(4) + ""  + chr(8)
 + "rule_id" + chr(4) + "№ правила" + chr(4) + ""  + chr(8)
 + "param-des" + chr(4) + "Описание параметра" + chr(4) + ""  + chr(8)
 + "param-data-type" + chr(4) + "Тип данных" + chr(4) + ""  + chr(8)
 + "param-2-data-type" + chr(4) + "Тип данных2" + chr(4) + ""  + chr(8)
 + "param-3-data-type" + chr(4) + "Тип данных3" + chr(4) + ""  + chr(8)
 + "param-label" + chr(4) + "Лейбл параметра" + chr(4) + ""  + chr(8)
 + "param-mode" + chr(4) + "Мода параметра" + chr(4) + ""  + chr(8)
 + "param-name" + chr(4) + "Имя параметра" + chr(4) + ""  + chr(8)
 + "p-index" + chr(4) + "Индекс" + chr(4) + ""  + chr(8)
 + "param-num" + chr(4) + "№ параметра" + chr(4) + ""  + chr(8)
 + "param-value-character" + chr(4) + "Значение параметра" + chr(4) + ""  + chr(8)
 + "param-value-date" + chr(4) + "Значение параметра" + chr(4) + ""  + chr(8)
 + "param-value-decimal" + chr(4) + "Значение параметра" + chr(4) + ""  + chr(8)
 + "param-value-integer" + chr(4) + "Значение параметра" + chr(4) + ""  + chr(8)
 + "param-value-logical" + chr(4) + "Значение параметра" + chr(4) + ""
 .
 run proc-full-temp-changes in this-procedure (
                                             input  (current_c-thbj-attr.action = integer('1':U))
                                            ,input  (current_c-thbj-attr.action = integer('99':U))
                                            ,input  buffer current_c-rule-call-param:handle
                                            ,input  'rule-call-param':U
                                            ,input  "call_id,call#_id,profile_id,codex_id,ruleset_id,order_id,rule_id,param-des,param-data-type,param-label,param-mode,param-name,param-num,param-value-character,param-value-date,param-value-decimal,param-value-integer,param-value-logical"
                                            ,input  v-label-param).
end.
end procedure.
define buffer buf_c-cli-hist for ub.c-cli-hist.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define SHARED temp-table temp-changes no-undo
field f_name as character
field l_name as character
field v_old as character
field v_new as character
field t_name as character
field num_ as integer
field uniq-key-rec as character
field action as integer
field fNotChange as logical
index pi is unique primary
num_
t_name
f_name
index
Chan
fnotChange
t_name
f_name
index imain uniq-key-rec
.
FUNCTION get-all-fields returns character (p-file-name as character ):
define variable v-dop as character no-undo .
  find first _file no-lock where _file._file-name = p-file-name no-error .
  if not available _file then return "":U.
  for each _field no-lock where
           _field._file-recid = recid(_file) :
    assign
    v-dop = v-dop + _field._field-name + chr(44)
    .
  end.
  return trim(v-dop).
END FUNCTION.
PROCEDURE proc-full-temp-changes :
  define input  parameter p-act-create as logical   no-undo .
  define input  parameter p-act-delete as logical   no-undo .
  define input  parameter p-hst-handle as handle    no-undo .
  define input  parameter p-main-table as character no-undo .
  define input  parameter p-field-list as character no-undo .
  define input  parameter p-label-form as character no-undo .
  define variable h-new-buf         as handle    no-undo .
  define variable h-main-buf        as handle    no-undo .
  define variable h-for-comp        as handle    no-undo .
  define variable v-inform          as character no-undo .
  define variable v-ind             as integer   no-undo .
  define variable v-idx-field-qnty  as integer   no-undo .
  define variable v-num-entries     as integer   no-undo .
  define variable fh                as handle    no-undo .
  define variable fh-main           as handle    no-undo .
  define variable fh-old            as handle    no-undo .
  define variable fh-new            as handle    no-undo .
  define variable v-field-name      as character no-undo .
  define variable v-field-lvl       as character no-undo .
  define variable v-field-form      as character no-undo .
  define variable v-search-exp      as character no-undo .
  define variable v-srch-main       as character no-undo .
  define variable v-word-link       as character no-undo .
  define variable v-av-chip-num     as logical   no-undo .
  define variable v-main-pi-fld-lst as character no-undo .
  define variable v-main-fld-lst    as character no-undo .
  define variable v-delim-list      as character no-undo .
  define variable v-label           as character no-undo .
  define variable v-old-value       as character no-undo case-sensitive.
  define variable v-new-value       as character no-undo case-sensitive.
  define variable v-chg-fields as character no-undo.
  for each temp-changes:
    delete temp-changes.
  end.
  if not p-hst-handle:available then do:
    return .
  end.
  create buffer h-new-buf  for table p-hst-handle .
  create buffer h-main-buf for table p-main-table .
  assign
    v-inform = h-main-buf:index-information(1)
    v-ind    = 2
  .
  do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
  on error undo, return error
  :
    assign
      v-inform = h-main-buf:index-information( v-ind )
      v-ind    = v-ind + 1
    .
  end.
  if v-inform = ?
    or LC( entry( 1, v-inform, ",":U ) ) = "default":U
    or entry( 3, v-inform, ",":U ) <> "1":U
  then do:
    return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-workfile, h-main-buf:name ).
  end.
  assign
    v-idx-field-qnty = num-entries( v-inform ) - 4
  .
  if v-idx-field-qnty < 2 then do:
    return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-workfile, v-inform, h-main-buf:name ).
  end.
  assign
    v-srch-main   = "where":U
    v-word-link   = "":U
    v-av-chip-num = false
    v-delim-list  = "":U
  .
  do v-ind = 1 to v-idx-field-qnty by 2
  on error undo, return error
  :
    assign
      v-field-name      = entry( 4 + v-ind, v-inform, ",":U )
      fh                = p-hst-handle:buffer-field( v-field-name )
      fh-main           = h-main-buf:buffer-field( v-field-name )
      v-srch-main       = substitute( "&1 &2 &3.&4 =", v-srch-main, v-word-link, fh-main:table, v-field-name )
      v-main-pi-fld-lst = v-main-pi-fld-lst + v-delim-list + v-field-name
    .
    if fh:data-type ="character":U then do:
      assign
        v-srch-main = substitute( '&1 "&2"', v-srch-main, replace( replace( fh:buffer-value(), '"':U, '""':U ), '~~':U, '~~~~':U ) )
      .
    end.
    else do:
      assign
        v-srch-main = substitute( "&1 &2", v-srch-main, fh:buffer-value() )
      .
    end.
    if v-delim-list = "":U then do:
      assign
        v-delim-list = ",":U
      .
    end.
    if v-word-link = "":U then do:
      assign
        v-word-link = "and":U
      .
    end.
  end.
  assign
    v-delim-list  = "":U
  .
  do v-ind = 1 to h-main-buf:num-fields
  on error undo, return error
  :
    assign
      fh-main      = h-main-buf:buffer-field( v-ind )
      v-field-name = fh-main:name
    .
      assign
        v-main-fld-lst = v-main-fld-lst + v-delim-list + v-field-name
      .
      if v-delim-list = "":U then do:
        assign
          v-delim-list = ",":U
        .
      end.
  end.
  assign
    v-inform = p-hst-handle:index-information(1)
    v-ind    = 2
  .
  do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
  on error undo, return error
  :
    assign
      v-inform = p-hst-handle:index-information( v-ind )
      v-ind    = v-ind + 1
    .
  end.
  if v-inform = ?
    or LC( entry( 1, v-inform, ",":U ) ) = "default":U
    or entry( 3, v-inform, ",":U ) <> "1":U
  then do:
    return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-workfile, p-hst-handle:name ).
  end.
  assign
    v-idx-field-qnty = num-entries( v-inform ) - 4
  .
  if v-idx-field-qnty < 2 then do:
    return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-workfile, v-inform, p-hst-handle:name ).
  end.
  assign
    v-search-exp  = "where":U
    v-word-link   = "":U
    v-av-chip-num = false
  .
  do v-ind = 1 to v-idx-field-qnty by 2
  on error undo, return error
  :
    assign
      v-field-name = entry( 4 + v-ind, v-inform, ",":U )
      fh           = p-hst-handle:buffer-field( v-field-name )
      v-search-exp = substitute( "&1 &2 &3.&4", v-search-exp, v-word-link, fh:table, v-field-name )
    .
    if v-field-name = "chip-num":U then do:
      assign
        v-search-exp  = substitute( "&1 >", v-search-exp )
        v-av-chip-num = true
      .
    end.
    else do:
      assign
        v-search-exp = substitute( "&1 =", v-search-exp )
      .
    end.
    if fh:data-type ="character":U then do:
      assign
        v-search-exp = substitute( '&1 "&2"', v-search-exp, replace( replace( fh:buffer-value(), '"':U, '""':U ), '~~':U, '~~~~':U ) )
      .
    end.
    else do:
      assign
        v-search-exp = substitute( '&1 &2', v-search-exp, fh:buffer-value() )
      .
    end.
    if v-word-link = "":U then do:
      assign
        v-word-link = "and":U
      .
    end.
  end.
  if v-av-chip-num = false then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Таблица &2 не содержит поля chip-num.", vss-workfile, p-hst-handle:name ) skip
      "Использование данной процедуры невозможно!" skip
      view-as alert-box error .
    return error .
  end.
  h-new-buf:find-first( v-search-exp, no-lock ) no-error .
  if not h-new-buf:available then do:
    h-main-buf:find-first( v-srch-main, no-lock ) no-error .
    if not h-main-buf:available then do:
      assign
        h-for-comp = ?
      .
    end.
    else do:
      assign
        h-for-comp = h-main-buf
      .
    end.
  end.
  else do:
    assign
      h-for-comp = h-new-buf
    .
  end.
  assign
    v-num-entries = num-entries( v-main-fld-lst, ",":U )
  .
  do v-ind = 1 to v-num-entries
  on error undo, return error return-value
  :
    assign
      v-field-name = entry( v-ind, v-main-fld-lst )
      fh-old       = p-hst-handle:buffer-field( v-field-name )
      v-old-value  = fh-old:buffer-value()
      v-label      = trim( fh-old:label )
    .
    if ( trim( p-field-list ) <> "":U
         and lookup( v-field-name, p-field-list ) > 0
       )
       or trim( p-field-list ) = "":U
    then do:
      if h-for-comp <> ? then do:
        assign
          fh-new      = h-for-comp:buffer-field( v-field-name )
          v-new-value = fh-new:buffer-value()
        .
      end.
      else do:
        assign
          v-new-value = "":U
        .
      end.
        if p-act-create = true then do:
          assign
            v-old-value = "":U
          .
        end.
        if p-act-delete = true then do:
          assign
            v-new-value = "":U
          .
        end.
      if v-old-value <> v-new-value
      then do:
        create temp-changes.
        assign
          temp-changes.t_name = p-main-table
          temp-changes.f_name = v-field-name
          temp-changes.l_name = replace( v-label, "&":U, "":U )
          temp-changes.v_old  = trim( v-old-value )
          temp-changes.v_new  = trim( v-new-value )
          temp-changes.num_   = 0
          temp-changes.fNotChange = v-old-value eq v-new-value
        .
      end.
    end.
  end.
  assign
    v-num-entries = num-entries( p-label-form, chr(8) )
  .
  do v-ind = 1 to v-num-entries
  on error undo, return error return-value
  :
    if num-entries( entry( v-ind, p-label-form, chr(8) ), chr(4) ) = 3 then do:
      assign
        v-field-name = entry( 1, entry( v-ind, p-label-form, chr(8) ), chr(4) )
        v-field-lvl  = entry( 2, entry( v-ind, p-label-form, chr(8) ), chr(4) )
        v-field-form = entry( 3, entry( v-ind, p-label-form, chr(8) ), chr(4) )
      .
      find first temp-changes
        where temp-changes.f_name = v-field-name
        no-error .
      if available temp-changes then do:
        if trim( v-field-lvl ) <> "":U then do:
          assign
            temp-changes.l_name = v-field-lvl
          .
        end.
        if trim( v-field-form ) <> "":U then do:
          assign
            temp-changes.v_old = dynamic-function( v-field-form, temp-changes.v_old )
          .
          if h-for-comp <> ? then do:
            assign
              temp-changes.v_new = dynamic-function( v-field-form, temp-changes.v_new )
            .
          end.
        end.
      end.
    end.
    else do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка! Список должен содержать три поля с разделителем delim-par!" skip
        substitute( "список для поля '&1': '&2'"
                    ,entry( 1, entry( v-ind, p-label-form, chr(8) ), chr(4) )
                    ,entry( v-ind, p-label-form, chr(8) )
                  ) skip
        substitute( "полный список: &2", p-label-form ) skip
        view-as alert-box error .
    end.
  end.
  delete object h-new-buf .
  delete object h-main-buf .
END PROCEDURE.
define temp-table temp-thbj-attr no-undo
like ub.thbj-attr.
function display-int-status returns character(input p-stts-char as character):
if p-stts-char = '0':U then return 'тек':U.
else return 'удал':U.
END FUNCTION.
function display-gender returns character(input p-gender as character):
case p-gender:
  when "no"
  or when "false"
  then do:
    return "м".
  end.
  when "yes"
  or when "true"
  then do:
    return "ж".
  end.
  when ?
  or when chr(63)
  then do:
    return chr(63).
  end.
end case.
END FUNCTION.
find first buf_c-cli-hist no-lock where
          buf_c-cli-hist.obj-type = p-obj-type
      AND buf_c-cli-hist.obj-code = p-obj-code
      AND buf_c-cli-hist.chip-num = p-chip-num
      AND buf_c-cli-hist.corr-user-db-num = p-corr-user-db-num
      AND buf_c-cli-hist.subject  = p-subject no-error .
if not available buf_c-cli-hist then do:
  return error .
end.
CASE p-subject:
  when 'clients':U then do:
    run clients-proc in this-procedure(output p-description) no-error .
  end.
  when 'clients-attr':U then do:
    run clients-attr-proc in this-procedure(output p-description) no-error .
  end.
  when 'sysconf':U then do:
    run sysconf-proc in this-procedure(output p-description) no-error .
  end.
  when 'person':U then do:
    run person-proc in this-procedure(output p-description) no-error  .
  end.
  when 'firm':U then do:
    run firm-proc in this-procedure(output p-description) no-error  .
  end.
  when 'shop':U then do:
    run shop-proc in this-procedure(output p-description) no-error  .
  end.
  when 'store':U then do:
    run store-proc in this-procedure(output p-description) no-error  .
  end.
  when 'staff':U then do:
    run staff-proc in this-procedure(output p-description) no-error  .
  end.
  when 'dis-thbj-rule':U then do:
    run dis-thbj-rule-proc in this-procedure(output p-description) no-error  .
  end.
  when 'thbj-attr':U then do:
    run thbj-attr-proc in this-procedure(output p-description) no-error  .
  end.
  when 'ext-classif':U then do:
    run ext-classif-proc in this-procedure(output p-description) no-error  .
  end.
END CASE.
if error-status:error then do:
  return error .
end.
procedure clients-proc :
define output parameter p-description as character no-undo .
define buffer current_c-clients for ub.c-clients  .
do
on error undo, return error return-value
:
  find first current_c-clients no-lock where
              current_c-clients.obj-type = p-obj-type
          AND current_c-clients.obj-code = p-obj-code
          AND current_c-clients.chip-num = p-chip-num
          AND current_c-clients.corr-user-db-num = p-corr-user-db-num no-error .
  if not avail current_c-clients then do:
      v-mess = "Неверная ссылка на c-clients в таблице c-cli-hist".
      run err-mess ( input-output v-mess).
      return error (if p-silent then v-mess else '':U).
  end.
define variable v-label-param as character no-undo .
  v-label-param =
    "PS" + chr(4) + "Примечания" + chr(4) + "" + chr(8)
 + "buy-cons" + chr(4) + "Покупатель конс.товаров" + chr(4) + "" + chr(8)
 + "buy-gds" + chr(4) + "Покупатель товаров" + chr(4) + "" + chr(8)
 + "db-num" + chr(4) + "№ БД" + chr(4) + "" + chr(8)
 + "host-code" + chr(4) + "Код своей фирмы" + chr(4) + "" + chr(8)
 + "buy-serv" + chr(4) + "Покупатель услуг" + chr(4) + "" + chr(8)
 + "grp-code" + chr(4) + "Вн.Код группы" + chr(4) + "" + chr(8)
 + "grp-name" + chr(4) + "Название группы" + chr(4) + "" + chr(8)
 + "is-prod" + chr(4) + "Производитель" + chr(4) + "" + chr(8)
 + "lim-kr" + chr(4) + "Лимит кредита" + chr(4) + "" + chr(8)
 + "num_podr" + chr(4) + "№ подразделения" + chr(4) + "" + chr(8)
 + "obj-name" + chr(4) + "Название" + chr(4) + "" + chr(8)
 + "sup-cons" + chr(4) + "Поставщик конс.товара" + chr(4) + "" + chr(8)
 + "sup-gds" + chr(4) + "Поставщик товаров" + chr(4) + "" + chr(8)
 + "sup-serv" + chr(4) + "Поставщик услуг" + chr(4) + "" + chr(8)
 + "stts" + chr(4) + "Статус" + chr(4) + "display-int-status" + chr(8)
 + "reg-code" + chr(4) + "Регион" + chr(4) + "" .
  run proc-full-temp-changes in this-procedure (
                                               input buf_c-cli-hist.action = integer('1':U)
                                              ,input buf_c-cli-hist.action = integer('99':U)
                                              ,input  buffer current_c-clients:handle
                                              ,input  'clients':U
                                              ,input  "PS,buy-cons,buy-gds,buy-serv,Покупатель услуг,db-num,host-code,grp-code,grp-name,is-prod,lim-kr,num_podr,obj-name,sup-cons,sup-gds,sup-serv,stts,reg-code"
                                              ,input  v-label-param).
end.
end procedure.
procedure clients-attr-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define buffer current_c-clients-attr for ub.c-clients-attr  .
do
on error undo, return error return-value
:
  find first current_c-clients-attr no-lock where
              current_c-clients-attr.obj-type = p-obj-type
          AND current_c-clients-attr.obj-code = p-obj-code
          AND current_c-clients-attr.chip-num = p-chip-num
          AND current_c-clients-attr.corr-user-db-num = p-corr-user-db-num
          AND current_c-clients-attr.attr-code = buf_c-cli-hist.attr-code
          no-error .
  if not avail current_c-clients-attr then do:
      v-mess = "Неверная ссылка на c-clients-attr в таблице c-cli-hist".
      run err-mess ( input-output v-mess).
      return error (if p-silent then v-mess else '':U).
  end.
  run clntattr-tooltip in this-procedure (
                input current_c-clients-attr.attr-code
              ,output v-tooltip
              ,output v-label
              ) no-error .
  assign
  p-description = "Атрибут" + chr(32) + v-label
  .
  define variable v-label-param as character no-undo .
v-label-param =
 "attr-value" + chr(4) + "Значение" + chr(4) + "" .
 run proc-full-temp-changes in this-procedure (
                                               input buf_c-cli-hist.action = integer('1':U)
                                              ,input buf_c-cli-hist.action = integer('99':U)
                                            ,input  buffer current_c-clients-attr:handle
                                            ,input  'clients-attr':U
                                            ,input  "attr-value"
                                            ,input  v-label-param).
end.
end procedure.
procedure sysconf-proc :
define output parameter p-description as character no-undo .
define buffer current_c-sysconf for ub.c-sysconf  .
  do
  on error undo, return error return-value
  :
    find first current_c-sysconf no-lock where
               current_c-sysconf.host-code = p-obj-code
           AND current_c-sysconf.chip-num = p-chip-num
           AND current_c-sysconf.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail current_c-sysconf then do:
       v-mess = "Неверная ссылка на c-sysconf в таблице c-cli-hist".
       run err-mess ( input-output v-mess).
       return error (if p-silent then v-mess else '':U).
    end.
define variable v-label-param as character no-undo .
v-label-param =
  "accnt-type" + chr(4) + "Учетная политика" + chr(4) + "" + chr(8)
 + "all-prt" + chr(4) + "Перес. на кассу все признаков товара" + chr(4) + "" + chr(8)
 + "an-uchet-code-in" + chr(4) + "Код аналит. учет по умолч" + chr(4) + "" + chr(8)
 + "artic-disable" + chr(4) + "Автомат. артикул" + chr(4) + "" + chr(8)
 + "avrg-price" + chr(4) + "Средние учетные цены" + chr(4) + "" + chr(8)
 + "auto-pay" + chr(4) + "Авто создание ф.о. и плат." + chr(4) + "" + chr(8)
 + "base-code" + chr(4) + "Код базовой валюты" + chr(4) + "" + chr(8)
 + "bclose-date" + chr(4) + "Дата последнего закрытия баланса" + chr(4) + "" + chr(8)
 + "branch" + chr(4) + "Отрасль (вид деятельности)" + chr(4) + "" + chr(8)
 + "cash-pay" + chr(4) + "Оплата наличными" + chr(4) + "" + chr(8)
 + "cashier" + chr(4) + "Кассир" + chr(4) + "" + chr(8)
 + "cd-bc-alt" + chr(4) + "На кассу бар-код доп. ед. изм." + chr(4) + "" + chr(8)
 + "cd-bc-base" + chr(4) + "На кассу бар-код осн. ед. изм." + chr(4) + "" + chr(8)
 + "cd-loc-alt" + chr(4) + "На кассу лок. код доп. ед. изм." + chr(4) + "" + chr(8)
 + "cd-loc-base" + chr(4) + "На кассу лок. код осн. ед. изм." + chr(4) + "" + chr(8)
 + "cd-parts-all" + chr(4) + "На кассу код партии для всех товаров" + chr(4) + "" + chr(8)
 + "cd-parts-not-blank" + chr(4) + "На кассу коды партий с непустыми номерами" + chr(4) + "" + chr(8)
 + "cd-parts-ser" + chr(4) + "На кассу партии для сер.тов." + chr(4) + "" + chr(8)
 + "cd-pb-alt" + chr(4) + "На кассу Доп. БК доп. ед. изм." + chr(4) + "" + chr(8)
 + "cd-pb-base" + chr(4) + "На кассу доп. БК осн. ед. изм." + chr(4) + "" + chr(8)
 + "cd-sc-base" + chr(4) + "На кассу вес. код" + chr(4) + "" + chr(8)
 + "cel-nazn-code-in" + chr(4) + "Код целев. назн. по умолч" + chr(4) + "" + chr(8)
 + "chk-pay" + chr(4) + "Код оплаты продажи" + chr(4) + "" + chr(8)
 + "cons-vat-pc" + chr(4) + "Консигнационный НДС" + chr(4) + "" + chr(8)
 + "contract-city" + chr(4) + "Город" + chr(4) + "" + chr(8)
 + "contract-type" + chr(4) + "Тип контракта" + chr(4) + "" + chr(8)
 + "cor-acc-in" + chr(4) + "Корр. счет по умолч" + chr(4) + "" + chr(8)
 + "cor-acc1-in" + chr(4) + "Корр. счет1 по умолч" + chr(4) + "" + chr(8)
 + "cost-calc" + chr(4) + "Расчет учетных цен" + chr(4) + "" + chr(8)
 + "credit-pay" + chr(4) + "Платеж в кредит на кассе" + chr(4) + "" + chr(8)
 + "down-pay" + chr(4) + "Оплата списания" + chr(4) + "" + chr(8)
 + "fbr-pay" + chr(4) + "Код Оплаты пр-ва" + chr(4) + "" + chr(8)
 + "fin-SLT-pc" + chr(4) + "Налог с продаж" + chr(4) + "" + chr(8)
 + "fin-VAT-pc" + chr(4) + "НДС" + chr(4) + "" + chr(8)
 + "firm-db-num" + chr(4) + "Номер БД фирмы" + chr(4) + "" + chr(8)
 + "head-position" + chr(4) + "Должность рук-ля" + chr(4) + "" + chr(8)
 + "holidays" + chr(4) + "Выходные" + chr(4) + "" + chr(8)
 + "in-ov" + chr(4) + "Переоценка после ПН" + chr(4) + "" + chr(8)
 + "in-pay" + chr(4) + "Оплата прихода" + chr(4) + "" + chr(8)
 + "in-perm" + chr(4) + "Добавление ПН на пассивном складе" + chr(4) + "" + chr(8)
 + "inout-price" + chr(4) + "Изменение налогов поставщика в ПН" + chr(4) + "" + chr(8)
 + "inv-pay" + chr(4) + "Оплата инвентар." + chr(4) + "" + chr(8)
 + "is-an-uchet" + chr(4) + "Обязателен код анал. учета в платежах" + chr(4) + "" + chr(8)
 + "is-cassa-acc" + chr(4) + "Обязателен касс. счет в наличн. платежах" + chr(4) + "" + chr(8)
 + "is-code-cel-nazn" + chr(4) + "Обязателен код цел.назн. в платежах" + chr(4) + "" + chr(8)
 + "is-corr-acc" + chr(4) + "Обязателен корр.счет в платежах" + chr(4) + "" + chr(8)
 + "fin-calc" + chr(4) + "Способ учета фин.документов" + chr(4) + "" + chr(8)
 + "KOPF" + chr(4) + "КОПФ" + chr(4) + "" + chr(8)
 + "load-time" + chr(4) + "Срок отгрузки (дней)" + chr(4) + "" + chr(8)
 + "negative-rest" + chr(4) + "Отрицательные остатки" + chr(4) + "" + chr(8)
 + "no-eq" + chr(4) + "Акт несоотв. в ед. изм. поставщика" + chr(4) + "" + chr(8)
 + "ord-prt" + chr(4) + "Детальный заказ (по признакам)" + chr(4) + "" + chr(8)
 + "osn-base" + chr(4) + "Учет ОС в баз. вал." + chr(4) + "" + chr(8)
 + "out-line-discnt" + chr(4) + "Скидка по строке РН" + chr(4) + "" + chr(8)
 + "out-pay" + chr(4) + "Оплата расхода" + chr(4) + "" + chr(8)
 + "out-rate" + chr(4) + "Изменение курса РН" + chr(4) + "" + chr(8)
 + "pay-code-schet-base" + chr(4) + "Вн№ счета в нац.вал.по умолч" + chr(4) + "" + chr(8)
 + "pay-code-schet-rubl" + chr(4) + "Вн№ счета в баз по умолч" + chr(4) + "" + chr(8)
 + "pay-sign" + chr(4) + "Подпись по умолч." + chr(4) + "" + chr(8)
 + "pay-sign-post" + chr(4) + "Должность по умолч." + chr(4) + "" + chr(8)
 + "price-calc" + chr(4) + "Запрещен приход при неравенстве цен" + chr(4) + "" + chr(8)
 + "property" + chr(4) + "Организационно-правовая форма" + chr(4) + "" + chr(8)
 + "purch-code" + chr(4) + "Тип приобретения" + chr(4) + "" + chr(8)
 + "ret-credit-pay" + chr(4) + "Оплата задолженности по кредиту" + chr(4) + "" + chr(8)
 + "ret-pay" + chr(4) + "Оплата возврата" + chr(4) + "" + chr(8)
 + "ret-sup-pay" + chr(4) + "Оплата возврата пост." + chr(4) + "" + chr(8)
 + "rsrv-time" + chr(4) + "Период резервирования (дней)" + chr(4) + "" + chr(8)
 + "sale-code" + chr(4) + "Тип контрагента-РЕАЛИЗАЦИЯ В МАГ" + chr(4) + "" + chr(8)
 + "sale-type" + chr(4) + "Код контрагента-РЕАЛИЗАЦИЯ В МАГ" + chr(4) + "" + chr(8)
 + "snr-accnt" + chr(4) + "Главный бухгалтер" + chr(4) + "" + chr(8)
 + "SOEI" + chr(4) + "СОЕИ" + chr(4) + "" + chr(8).
v-label-param = v-label-param
 + "srok-opl" + chr(4) + "СРок оплаты" + chr(4) + "" + chr(8)
 + "unit-cli-perm" + chr(4) + "Изменение ед. изм. поставщика" + chr(4) + "" + chr(8)
 + "usl-opl" + chr(4) + "Условия оплаты" + chr(4) + "" + chr(8)
 + "VAT-sp" + chr(4) + "Спецналог" + chr(4) + "" + chr(8)
 + "xd-an-code" + chr(4) + "Код статьи для курсовых разниц" + chr(4) + "" + chr(8)
 + "xd-grp-code" + chr(4) + "Код группы для генерации проводок по К.Р." + chr(4) + "" + chr(8)
 + "xdn-an-code" + chr(4) + "Код статьи для отрицательных курсовых разниц" + chr(4) + "" + chr(8)
 + "xdn-grp-code" + chr(4) + "Номер БД для копирования прав и расписания при импорте из 1С" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input buf_c-cli-hist.action = integer('1':U)
                                            ,input buf_c-cli-hist.action = integer('99':U)
                                            ,input  buffer current_c-sysconf:handle
                                            ,input  'sysconf':U
                                            ,input  "accnt-type,all-prt,an-uchet-code-in,artic-disable,avrg-price,auto-pay,base-code,bclose-date,branch,cash-pay,cashier,cd-bc-alt,cd-bc-base,cd-loc-alt,cd-loc-base,cd-parts-all,cd-parts-not-blank,cd-parts-ser,cd-pb-alt,cd-pb-base,cd-sc-base,cel-nazn-code-in,chk-pay,cons-vat-pc,contract-city,contract-type,cor-acc-in,cor-acc1-in,cost-calc,credit-pay,down-pay,fbr-pay,fin-SLT-pc,fin-VAT-pc,firm-db-num,head-position,holidays,in-ov,in-pay,in-perm,inout-price,inv-pay,is-an-uchet,is-cassa-acc,is-code-cel-nazn,is-corr-acc,fin-calc,KOPF,load-time,negative-rest,no-eq,ord-prt,osn-base,out-line-discnt,out-pay,out-rate,pay-code-schet-base,pay-code-schet-rubl,pay-sign,pay-sign-post,price-calc,property,purch-code,ret-credit-pay,ret-pay,ret-sup-pay,rsrv-time,sale-code,sale-type,snr-accnt,SOEI,srok-opl,unit-cli-perm,usl-opl,VAT-sp,xd-an-code,xd-grp-code,xdn-an-code,xdn-grp-code"
                                            ,input  v-label-param).
end.
end procedure.
procedure firm-proc :
define output parameter p-description as character no-undo .
define buffer current_c-firm for ub.c-firm  .
do
on error undo, return error return-value
:
    find first current_c-firm no-lock where
               current_c-firm.firm-code = p-obj-code
           AND current_c-firm.chip-num = p-chip-num
           AND current_c-firm.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail current_c-firm then do:
       v-mess = "Неверная ссылка на c-firm в таблице c-cli-hist".
       run err-mess ( input-output v-mess).
       return error (if p-silent then v-mess else '':U).
    end.
define variable v-label-param as character no-undo .
v-label-param =
  "addres1" + chr(4) + "Адрес" + chr(4) + "" + chr(8)
 + "addres2" + chr(4) + "Адрес1" + chr(4) + "" + chr(8)
 + "city" + chr(4) + "Страна город" + chr(4) + "" + chr(8)
 + "contact-psn" + chr(4) + "Контактное лицо" + chr(4) + "" + chr(8)
 + "director" + chr(4) + "Руководитель" + chr(4) + "" + chr(8)
 + "e-mail" + chr(4) + "e-mail" + chr(4) + "" + chr(8)
 + "engl-name" + chr(4) + "Английское название" + chr(4) + "" + chr(8)
 + "fax" + chr(4) + "Факс" + chr(4) + "" + chr(8)
 + "firm-code" + chr(4) + "Код организации" + chr(4) + "" + chr(8)
 + "gen-acct" + chr(4) + "Главный бухгалтер" + chr(4) + "" + chr(8)
 + "ind" + chr(4) + "Индекс" + chr(4) + "" + chr(8)
 + "inn" + chr(4) + "ИНН" + chr(4) + "" + chr(8)
 + "kpp" + chr(4) + "КПП" + chr(4) + "" + chr(8)
 + "main-obj-code" + chr(4) + "Код гл. объект межфирм пермещения" + chr(4) + "" + chr(8)
 + "main-obj-type" + chr(4) + "Тип гл. объект межфирм пермещения" + chr(4) + "" + chr(8)
 + "okonh" + chr(4) + "ОКОНХ" + chr(4) + "" + chr(8)
 + "okpo" + chr(4) + "ОКПО" + chr(4) + "" + chr(8)
 + "phone" + chr(4) + "Телефон" + chr(4) + "" + chr(8)
 + "phone1-note" + chr(4) + "Прим." + chr(4) + "" + chr(8)
 + "post-addr1" + chr(4) + "Почт.адрес" + chr(4) + "" + chr(8)
 + "post-addr2" + chr(4) + "Почт.адрес2" + chr(4) + "" + chr(8)
 + "post-city" + chr(4) + "Страна город (почт.адр.)" + chr(4) + "" + chr(8)
 + "post-ind" + chr(4) + "Индекс (почт.адр.)" + chr(4) + "" + chr(8)
 + "telex" + chr(4) + "Телекс" + chr(4) + "" + chr(8)
 + "tobj-code" + chr(4) + "Код торгового представителя" + chr(4) + "" + chr(8)
 + "is-pboul" + chr(4) + "ПБОЮЛ" + chr(4) + ""  .
  run proc-full-temp-changes in this-procedure (
                                             input buf_c-cli-hist.action = integer('1':U)
                                            ,input buf_c-cli-hist.action = integer('99':U)
                                            ,input  buffer current_c-firm:handle
                                            ,input  'firm':U
                                            ,input  "addres1,addres2,city,contact-psn,director,e-mail,engl-name,fax,firm-code,gen-acct,ind,inn,kpp,main-obj-code,main-obj-type,okonh,okpo,phone,phone1-note,post-addr1,post-addr2,telex,tobj-code,is-pboul"
                                            ,input  v-label-param).
end.
end procedure.
procedure person-proc :
define output parameter p-description as character no-undo .
define buffer current_c-person for ub.c-person  .
do
on error undo, return error return-value
:
    find first current_c-person no-lock where
               current_c-person.psn-code = p-obj-code
           AND current_c-person.chip-num = p-chip-num
           AND current_c-person.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail current_c-person then do:
       v-mess = "Неверная ссылка на c-person в таблице c-cli-hist".
       run err-mess ( input-output v-mess).
       return error (if p-silent then v-mess else '':U).
    end.
define variable v-label-param as character no-undo .
v-label-param =
  "address" + chr(4) + "Адрес" + chr(4) + "" + chr(8)
 + "city" + chr(4) + "Город" + chr(4) + "" + chr(8)
 + "e-mail" + chr(4) + "e-mail" + chr(4) + "" + chr(8)
 + "fax" + chr(4) + "Факс" + chr(4) + "" + chr(8)
 + "firm-code" + chr(4) + "Код организации" + chr(4) + "" + chr(8)
 + "firm-name" + chr(4) + "Организация" + chr(4) + "" + chr(8)
 + "given-by" + chr(4) + "Паспорт выдан" + chr(4) + "" + chr(8)
 + "ind" + chr(4) + "Индекс" + chr(4) + "" + chr(8)
 + "inn" + chr(4) + "ИНН" + chr(4) + "" + chr(8)
 + "kpp" + chr(4) + "КПП" + chr(4) + "" + chr(8)
 + "name1" + chr(4) + "Имя" + chr(4) + "" + chr(8)
 + "name2" + chr(4) + "Отчество" + chr(4) + "" + chr(8)
 + "okonh" + chr(4) + "ОКОНХ" + chr(4) + "" + chr(8)
 + "okpo" + chr(4) + "ОКРО" + chr(4) + "" + chr(8)
 + "passp-num" + chr(4) + "Паспорт: номер" + chr(4) + "" + chr(8)
 + "passp-ser" + chr(4) + "Паспорт: серия" + chr(4) + "" + chr(8)
 + "phone1" + chr(4) + "Телефон" + chr(4) + "" + chr(8)
 + "phone1-note" + chr(4) + "Прим." + chr(4) + "" + chr(8)
 + "position" + chr(4) + "Должность" + chr(4) + "" + chr(8)
 + "post-box" + chr(4) + "а/я" + chr(4) + "" + chr(8)
 + "address" + chr(4) + "Адрес почтовый" + chr(4) + "" + chr(8)
 + "post-city" + chr(4) + "Город (почт.адр.)" + chr(4) + "" + chr(8)
 + "post-ind" + chr(4) + "Индекс (почт.адр.)" + chr(4) + "" + chr(8)
 + "is-pboul" + chr(4) + "ПБОЮЛ" + chr(4) + "" + chr(8)
 + "gender" + chr(4) + "пол" + chr(4) + "display-gender" + chr(8)
 + "date-birth" + chr(4) + "ДР" + chr(4) + ""
 .
 run proc-full-temp-changes in this-procedure (
                                             input buf_c-cli-hist.action = integer('1':U)
                                            ,input buf_c-cli-hist.action = integer('99':U)
                                            ,input  buffer current_c-person:handle
                                            ,input  'person':U
                                            ,input  "address,city,e-mail,fax,firm-code,firm-name,given-by,ind,inn,kpp,name1,name2,okonh,okpo,passp-num,passp-ser,phone1,phone1-note,position,post-box,is-pboul,gender,date-birth"
                                            ,input  v-label-param).
end.
end procedure.
procedure shop-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define variable v-field-name as character no-undo .
define variable v-field-function as character no-undo .
define variable jj as integer no-undo .
define variable v-field-label  as character no-undo .
define variable v-field-list as character no-undo .
define buffer current_shop for ub.shop  .
define buffer current_c-shop for ub.c-shop  .
define buffer new_c-shop for ub.c-shop  .
  do
  on error undo, return error return-value
  :
    find first current_c-shop no-lock where
               current_c-shop.obj-code = p-obj-code
           AND current_c-shop.chip-num = p-chip-num
           AND current_c-shop.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail current_c-shop then do:
       v-mess = "Неверная ссылка на c-shop в таблице c-cli-hist".
       run err-mess ( input-output v-mess).
       return error (if p-silent then v-mess else '':U).
    end.
define variable v-label-param as character no-undo .
v-label-param =
  "acct" + chr(4) + "Бухгалтер" + chr(4) + "" + chr(8)
 + "addres1" + chr(4) + "Адрес" + chr(4) + "" + chr(8)
 + "addres2" + chr(4) + "Адрес1" + chr(4) + "" + chr(8)
 + "all-prt" + chr(4) + "На кассу все признаки тов" + chr(4) + "" + chr(8)
 + "buy-goods" + chr(4) + "Выкуп" + chr(4) + "" + chr(8)
 + "kitchen-store-code" + chr(4) + "Код Склада Кухни" + chr(4) + "" + chr(8)
 + "kitchen-store-type" + chr(4) + "Тип Склада кухни" + chr(4) + "" + chr(8)
 + "cd-bc-alt" + chr(4) + "На кассу бар-код доп. ед. изм." + chr(4) + "" + chr(8)
 + "cd-bc-base" + chr(4) + "На кассу бар-код осн. ед. изм." + chr(4) + "" + chr(8)
 + "cd-loc-alt" + chr(4) + "На кассу лок. код доп. ед. изм." + chr(4) + "" + chr(8)
 + "cd-loc-base" + chr(4) + "На кассу лок. код осн. ед. изм." + chr(4) + "" + chr(8)
 + "cd-parts-all" + chr(4) + "На кассу коды партии для всех тов" + chr(4) + "" + chr(8)
 + "cd-parts-not-blank" + chr(4) + "На кассу партии с непустыми кодами" + chr(4) + "" + chr(8)
 + "cd-parts-ser" + chr(4) + "На кассу партии для сер тов" + chr(4) + "" + chr(8)
 + "cd-pb-alt" + chr(4) + "На кассу доп. БК доп. ед. изм." + chr(4) + "" + chr(8)
 + "cd-pb-base" + chr(4) + "На кассу доп. БК осн. ед. изм." + chr(4) + "" + chr(8)
 + "cd-sc-base" + chr(4) + "На кассу вес. код" + chr(4) + "" + chr(8)
 + "chk-pay" + chr(4) + "Оплата продажи" + chr(4) + "" + chr(8)
 + "day-only" + chr(4) + "В продажи чеки одного дня" + chr(4) + "" + chr(8)
 + "director" + chr(4) + "Директор" + chr(4) + "" + chr(8)
 + "discaloc" + chr(4) + "Размазывать скидку на итог" + chr(4) + "" + chr(8)
 + "doc-prt" + chr(4) + "Учет по шкалам" + chr(4) + "" + chr(8)
 + "down-pay" + chr(4) + "Оплата списания" + chr(4) + "" + chr(8)
 + "dst-price" + chr(4) + "Перемещение по ценам объекта" + chr(4) + "" + chr(8)
 + "fax" + chr(4) + "Факс" + chr(4) + "" + chr(8)
 + "fbr-pay" + chr(4) + "Код Оплаты пр-ва" + chr(4) + "" + chr(8)
 + "goods-man" + chr(4) + "Товаровед" + chr(4) + "" + chr(8)
 + "holidays" + chr(4) + "Выходные" + chr(4) + "" + chr(8)
 + "host-code" + chr(4) + "Код фирмы" + chr(4) + "" + chr(8)
 + "in-ov" + chr(4) + "Переоценка после ПН" + chr(4) + "" + chr(8)
 + "in-pay" + chr(4) + "Оплата прихода" + chr(4) + "" + chr(8)
 + "in-perm" + chr(4) + "Перемещение по цене магазина" + chr(4) + "" + chr(8)
 + "inout-price" + chr(4) + "Изменение налогов поставщика в ПН" + chr(4) + "" + chr(8)
 + "inv-pay" + chr(4) + "Оплата инвентар." + chr(4) + "" + chr(8)
 + "is-catering" + chr(4) + "Объект-РЕСТОРАН" + chr(4) + "" + chr(8)
 + "is-kitchen" + chr(4) + "Объект-КУХНЯ" + chr(4) + "" + chr(8)
 + "is-kitchen-store" + chr(4) + "Объект-склад КУХНИ" + chr(4) + "" + chr(8)
 + "load-time" + chr(4) + "Срок отгрузки (дней)" + chr(4) + "" + chr(8)
 + "no-eq" + chr(4) + "Запрещен приход при отсутствии цен" + chr(4) + "" + chr(8)
 + "no-short-code" + chr(4) + "?" + chr(4) + "" + chr(8)
 + "out-line-discnt" + chr(4) + "Скидка по строке РН" + chr(4) + "" + chr(8)
 + "out-pay" + chr(4) + "Оплата расхода" + chr(4) + "" + chr(8)
 + "out-rate" + chr(4) + "Изменение курса РН" + chr(4) + "" + chr(8)
 + "phone" + chr(4) + "Телефон" + chr(4) + "" + chr(8)
 + "pr-cash" + chr(4) + "Разрешить переоценку без блокировки касс" + chr(4) + "" + chr(8)
 + "price-calc" + chr(4) + "Запрещен приход при неравенстве цен" + chr(4) + "" + chr(8)
 + "purch-code" + chr(4) + "Тип приобретения" + chr(4) + "" + chr(8)
 + "ret-pay" + chr(4) + "Оплата возврата" + chr(4) + "" + chr(8)
 + "ret-sup-pay" + chr(4) + "Оплата возврата пост." + chr(4) + "" + chr(8)
 + "rsrv-time" + chr(4) + "Период резервирования (дней)" + chr(4) + "" + chr(8)
 + "shift-on" + chr(4) + "Включены смены" + chr(4) + "" + chr(8)
 + "store-boss" + chr(4) + "Зав. складом" + chr(4) + "" + chr(8)
 + "store-man" + chr(4) + "Кладовщик" + chr(4) + "" + chr(8)
 + "sub-store-code" + chr(4) + "Код объекта-подсобки" + chr(4) + "" + chr(8)
 + "sub-store-on" + chr(4) + "Есть подсобка" + chr(4) + "" + chr(8)
 + "sub-store-type" + chr(4) + "Тип объекта-подсобки" + chr(4) + "" + chr(8)
 + "unit-cli-perm" + chr(4) + "Изменение ед. изм. поставщика" + chr(4) + "" + chr(8)
 + "with-serv" + chr(4) + "Торгует услугами" + chr(4) + "" + chr(8)
 + "work-hours" + chr(4) + "Часы работы" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input buf_c-cli-hist.action = integer('1':U)
                                            ,input buf_c-cli-hist.action = integer('99':U)
                                            ,input  buffer current_c-shop:handle
                                            ,input  'shop':U
                                            ,input  "acct,addres1,addres2,all-prt,buy-goods,kitchen-store-code,kitchen-store-type,cd-bc-alt,cd-bc-base,cd-loc-alt,cd-loc-base,cd-parts-all,cd-parts-not-blank,cd-parts-ser,cd-pb-alt,cd-pb-base,cd-sc-base,chk-pay,day-only,director,discaloc,doc-prt,down-pay,dst-price,fax,fbr-pay,goods-man,holidays,host-code,in-ov,in-pay,in-perm,inout-price,inv-pay,is-catering,is-kitchen,is-kitchen-store,load-time,no-eq,no-short-code,out-line-discnt,out-pay,out-rate,phone,pr-cash,price-calc,purch-code,ret-pay,rsrv-time,shift-on,store-boss,store-man,sub-store-code,sub-store-on,sub-store-type,unit-cli-perm,with-serv,work-hours"
                                            ,input  v-label-param).
end.
end procedure.
procedure store-proc :
define output parameter p-description as character no-undo .
define buffer current_c-store for ub.c-store  .
do
on error undo, return error return-value
:
find first current_c-store no-lock where
            current_c-store.obj-code = p-obj-code
        AND current_c-store.chip-num = p-chip-num
        AND current_c-store.corr-user-db-num = p-corr-user-db-num
        no-error .
if not avail current_c-store then do:
    v-mess = "Неверная ссылка на c-store в таблице c-cli-hist".
    run err-mess ( input-output v-mess).
    return error (if p-silent then v-mess else '':U).
end.
define variable v-label-param as character no-undo .
v-label-param =
  "active" + chr(4) + "Активный склад" + chr(4) + "" + chr(8)
 + "addres1" + chr(4) + "Адрес" + chr(4) + "" + chr(8)
 + "addres2" + chr(4) + "Адрес1" + chr(4) + "" + chr(8)
 + "chk-pay" + chr(4) + "Оплата продажи" + chr(4) + "" + chr(8)
 + "doc-prt" + chr(4) + "Учет по шкалам" + chr(4) + "" + chr(8)
 + "down-pay" + chr(4) + "Оплата списания" + chr(4) + "" + chr(8)
 + "dst-price" + chr(4) + "Перемещение по ценам объекта" + chr(4) + "" + chr(8)
 + "fax" + chr(4) + "Факс" + chr(4) + "" + chr(8)
 + "fbr-pay" + chr(4) + "Код Оплаты пр-ва" + chr(4) + "" + chr(8)
 + "holidays" + chr(4) + "Выходные" + chr(4) + "" + chr(8)
 + "host-code" + chr(4) + "Код фирмы" + chr(4) + "" + chr(8)
 + "in-ov" + chr(4) + "Переоценка после ПН" + chr(4) + "" + chr(8)
 + "in-pay" + chr(4) + "Оплата прихода" + chr(4) + "" + chr(8)
 + "in-perm" + chr(4) + "Добавление ПН на пассивном складе" + chr(4) + "" + chr(8)
 + "inout-price" + chr(4) + "Изменение налогов поставщика в ПН" + chr(4) + "" + chr(8)
 + "inv-pay" + chr(4) + "Оплата инвентар." + chr(4) + "" + chr(8)
 + "load-time" + chr(4) + "Срок отгрузки (дней)" + chr(4) + "" + chr(8)
 + "no-eq" + chr(4) + "Запрещен приход при отсутствии цен" + chr(4) + "" + chr(8)
 + "out-line-discnt" + chr(4) + "Скидка по строке РН" + chr(4) + "" + chr(8)
 + "out-pay" + chr(4) + "Оплата расхода" + chr(4) + "" + chr(8)
 + "out-rate" + chr(4) + "Изменение курса РН" + chr(4) + "" + chr(8)
 + "phone" + chr(4) + "Телефон" + chr(4) + "" + chr(8)
 + "price-calc" + chr(4) + "Запрещен приход при неравенстве цен" + chr(4) + "" + chr(8)
 + "purch-code" + chr(4) + "Тип приобретения" + chr(4) + "" + chr(8)
 + "ret-pay" + chr(4) + "Оплата возврата" + chr(4) + "" + chr(8)
 + "ret-sup-pay" + chr(4) + "Оплата возврата пост." + chr(4) + "" + chr(8)
 + "rsrv-time" + chr(4) + "Период резервирования (дней)" + chr(4) + "" + chr(8)
 + "shift-on" + chr(4) + "Включены смены" + chr(4) + "" + chr(8)
 + "store-boss" + chr(4) + "Зав. складом" + chr(4) + "" + chr(8)
 + "store-man" + chr(4) + "Кладовщик" + chr(4) + "" + chr(8)
 + "unit-cli-perm" + chr(4) + "Изменение ед. изм. поставщика" + chr(4) + "" + chr(8)
 + "work-hours" + chr(4) + "Часы работы" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input buf_c-cli-hist.action = integer('1':U)
                                            ,input buf_c-cli-hist.action = integer('99':U)
                                            ,input  buffer current_c-store:handle
                                            ,input  'store':U
                                            ,input  "active,addres1,addres2,chk-pay,doc-prt,down-pay,dst-price,fax,fbr-pay,holidays,host-code,in-ov,in-pay,in-perm,inout-price,inv-pay,load-time,no-eq,out-line-discnt,out-pay,out-rate,phone,price-calc,purch-code,ret-pay,ret-sup-pay,rsrv-time,shift-on,store-boss,store-man,unit-cli-perm,work-hours"
                                            ,input  v-label-param).
end.
end procedure.
procedure staff-proc :
define output parameter p-description as character no-undo .
define buffer current_c-staff for ub.c-staff  .
do
on error undo, return error return-value  :
find first current_c-staff no-lock where
            current_c-staff.psn-code = p-obj-code
        AND current_c-staff.chip-num = p-chip-num
        AND current_c-staff.corr-user-db-num = p-corr-user-db-num
        no-error .
if not avail current_c-staff then do:
    v-mess = "Неверная ссылка на c-staff в таблице c-cli-hist".
    run err-mess ( input-output v-mess).
    return error  (if p-silent then v-mess else '':U).
end.
define variable v-label-param as character no-undo .
v-label-param =
  "date-start" + chr(4) + "Начало работы" + chr(4) + "" + chr(8)
 + "date-end" + chr(4) + "Окончание работы" + chr(4) + "" + chr(8)
 + "db-num" + chr(4) + "БД" + chr(4) + "" + chr(8)
 + "host-code" + chr(4) + "Фирма" + chr(4) + "" + chr(8)
 + "obj-type" + chr(4) + "Тип объекта" + chr(4) + "" + chr(8)
 + "obj-code" + chr(4) + "Код объекта" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input buf_c-cli-hist.action = integer('1':U)
                                            ,input buf_c-cli-hist.action = integer('99':U)
                                            ,input  buffer current_c-staff:handle
                                            ,input  'staff':U
                                            ,input  "date-start,date-end,db-num,host-code,obj-type,obj-code"
                                            ,input  v-label-param).
end.
end procedure.
FUNCTION get-dis-thbj-rule-name returns character ( input p-dis-thbj-rule-code as character):
define variable v-name as character no-undo .
v-name =  entry (lookup (p-dis-thbj-rule-code, 'pcnt-tot-kateg,dflt-gds-temp-disc,abs-tot-kateg,pcnt-codes,kateg-codes,free-discnt-flag,pmnt-discnt-flag,kat-gds-grp,temp-disc-pdf,pcnt-kat-pdf,bonus-tot,bonus-all':u) + 1, ',' + '% Скидка на итог,Временная скидка на товар по умолчанию,Abs Скидка на итог,Коды % скидок,Коды категорий,Флаг своб.скидки,Флаг уст. скидки на платеж,Ск-ка на группу товаров для кат.клиентов,Временная через ТПЛ,Категорийная через ТПЛ,Начисление бонусов на сумму чека,Правило-итого бонусов по чеку':u).
return v-name.
end FUNCTION.
procedure dis-thbj-rule-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define variable v-old-position as character no-undo .
define variable v-new-position as character no-undo .
define variable v-last as logical no-undo .
define variable v-field-name as character no-undo .
define variable v-field-function as character no-undo .
define variable jj as integer no-undo .
define variable v-field-label  as character no-undo .
define variable v-field-list as character no-undo .
define buffer current_dis-thbj-rule for ub.dis-thbj-rule  .
define buffer current_c-dis-thbj-rule for ub.c-dis-thbj-rule  .
define buffer new_c-dis-thbj-rule for ub.c-dis-thbj-rule  .
define buffer new_c-cli-hist for ub.c-cli-hist  .
  do
  on error undo, return error return-value
  :
    if p-obj-type = 'орг':U then do:
      find first current_c-dis-thbj-rule no-lock where
                current_c-dis-thbj-rule.obj-type = '':U
            and current_c-dis-thbj-rule.obj-code = 0
            AND current_c-dis-thbj-rule.chip-num = p-chip-num
            AND current_c-dis-thbj-rule.corr-user-db-num = p-corr-user-db-num
            no-error .
    end.
    else do:
      find first current_c-dis-thbj-rule no-lock where
                current_c-dis-thbj-rule.obj-type = p-obj-type
            AND current_c-dis-thbj-rule.obj-code = p-obj-code
            AND current_c-dis-thbj-rule.chip-num = p-chip-num
            AND current_c-dis-thbj-rule.corr-user-db-num = p-corr-user-db-num
            no-error .
    end.
    if not avail current_c-dis-thbj-rule then do:
       v-mess = "Неверная ссылка на c-dis-thbj-rule в таблице c-cli-hist".
       run err-mess ( input-output v-mess).
       return error  (if p-silent then v-mess else '':U).
    end.
    find first new_c-dis-thbj-rule no-lock where
              new_c-dis-thbj-rule.host-code = current_c-dis-thbj-rule.host-code
          and new_c-dis-thbj-rule.obj-type = current_c-dis-thbj-rule.obj-type
          and new_c-dis-thbj-rule.obj-code = current_c-dis-thbj-rule.obj-code
          and new_c-dis-thbj-rule.pos-type = current_c-dis-thbj-rule.pos-type
          and new_c-dis-thbj-rule.discnt-role = current_c-dis-thbj-rule.discnt-role
          and new_c-dis-thbj-rule.nonunique = current_c-dis-thbj-rule.nonunique
          AND new_c-dis-thbj-rule.chip-num > p-chip-num
          AND new_c-dis-thbj-rule.corr-user-db-num = p-corr-user-db-num no-error.
    if not available new_c-dis-thbj-rule then do:
    find first current_dis-thbj-rule no-lock where
              current_dis-thbj-rule.host-code = current_c-dis-thbj-rule.host-code
          and current_dis-thbj-rule.obj-type = current_c-dis-thbj-rule.obj-type
          and current_dis-thbj-rule.obj-code = current_c-dis-thbj-rule.obj-code
          and current_dis-thbj-rule.pos-type = current_c-dis-thbj-rule.pos-type
          and current_dis-thbj-rule.discnt-role = current_c-dis-thbj-rule.discnt-role
          and current_dis-thbj-rule.nonunique = current_c-dis-thbj-rule.nonunique no-error.
      if not available current_dis-thbj-rule then do:
        return error.
      end.
      buffer-compare current_dis-thbj-rule to current_c-dis-thbj-rule
      case-sensitive
      save result in v-chg-fields.
    end.
    else do:
      buffer-compare new_c-dis-thbj-rule except chip-num corr-date corr-time corr-user-name corr-user-db-num
      to current_c-dis-thbj-rule
      case-sensitive
      save result in v-chg-fields.
    end.
  _ii:
  do ii = 1 to num-entries(v-chg-fields):
    assign
    v-field-name = entry(ii, v-chg-fields)
    jj = lookup(v-field-name, "pos-type,disnct-role,templ-rl-root,rule-num,key#_one,Key#_two,key#_three,CHarkey_one,Charkey_two,Charkey_three").
    if jj = 0 then next _ii.
    assign
    v-field-label = entry(jj, "Место использ.,Тип скидки,Тип шаблона,№ правила,Код 1,Код 2,Код 3,Скод 1,Скод 2,Скод 3")
    v-field-function = entry(jj, ",get-dis-thbj-rule-name,,,,,")
    .
    create temp-changes.
    assign
    temp-changes.f_name = v-field-name
    temp-changes.l_name = v-field-label
    temp-changes.v_old = string(buffer current_c-dis-thbj-rule:buffer-field(v-field-name):buffer-value)
    temp-changes.v_new =  (if available new_c-dis-thbj-rule
                                then string(buffer new_c-dis-thbj-rule:buffer-field(v-field-name):buffer-value)
                                else string(buffer current_dis-thbj-rule:buffer-field(v-field-name):buffer-value)
                           )
    .
    if v-field-function <> '':U then do:
      assign
      temp-changes.v_old = DYNAMIC-function(v-field-function, temp-changes.v_old)
      temp-changes.v_new = DYNAMIC-function(v-field-function, temp-changes.v_new)
      .
    end.
   end.
 end.
end procedure.
procedure thbj-attr-proc :
define output parameter p-description as character no-undo .
do
on error undo, return error return-value
:
  find first current_c-thbj-attr no-lock where
              current_c-thbj-attr.obj-type = p-obj-type
          AND current_c-thbj-attr.obj-code = p-obj-code
          AND current_c-thbj-attr.chip-num = p-chip-num
          AND current_c-thbj-attr.corr-user-db-num = p-corr-user-db-num
          no-error .
  if not avail current_c-thbj-attr then do:
      v-mess = "Неверная ссылка на c-thbj-attr в таблице c-cli-hist".
      run err-mess ( input-output v-mess).
      return error (if p-silent then v-mess else '':U).
  end.
  create temp-thbj-attr.
  assign
  temp-thbj-attr.upper-prop-code       = current_c-thbj-attr.upper-prop-code
  temp-thbj-attr.prop-code             = current_c-thbj-attr.prop-code
  temp-thbj-attr.obj-type              = current_c-thbj-attr.obj-type
  temp-thbj-attr.obj-code              = current_c-thbj-attr.obj-code
  .
  run gen-key-rec in this-procedure ( input 'thbj-attr':U
                                    ,input (buffer temp-thbj-attr:handle)
                                    ,output v-thbj-attr-uniq-key-rec) .
  if current_c-thbj-attr.subject = ''
  or current_c-thbj-attr.subject = 'thbj-attr':U then do:
    run thbj-attr-self-proc in this-procedure (input buf_c-cli-hist.action, output p-description) no-error.
  end.
  else do:
    case current_c-thbj-attr.subject:
      when 'rp-by-call':U then do:
        run rp-by-call-proc in this-procedure(output p-description) no-error .
      end.
      when 'rule-by-call':U then do:
        run rule-by-call-proc in this-procedure(output p-description) no-error .
      end.
      when 'rule-call-param':U then do:
        run rule-call-param-proc in this-procedure(output p-description) no-error .
      end.
    end case.
  end.
end.
end procedure.
define temp-table temp-clients no-undo like ub.clients.
procedure ext-classif-proc :
define output parameter p-description as character no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-field-list as character no-undo .
define variable v-value-list as character no-undo .
define variable v-label-param as character no-undo .
define buffer curr_c-ext-classif for ub.c-ext-classif  .
do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
    create temp-clients.
    buffer-copy buf_c-cli-hist to temp-clients.
    run gen-key-rec in this-procedure ( input 'clients':U
                                       ,input (buffer temp-clients:handle)
                                       ,output v-uniq-key-rec).
    delete temp-clients.
    find first curr_c-ext-classif no-lock where
               curr_c-ext-classif.classif-subject = 'clients':U
           and curr_c-ext-classif.uniq-key-rec = v-uniq-key-rec
           AND curr_c-ext-classif.chip-num = p-chip-num
           AND curr_c-ext-classif.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail curr_c-ext-classif then do:
       v-mess = "Неверная ссылка на c-ext-classif в таблице c-cli-hist".
       run err-mess in this-procedure ( input-output v-mess).
       return error v-mess.
    end.
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-cli-hist.action = integer('1':U))
                                            ,input  (buf_c-cli-hist.action = integer('99':U))
                                            ,input  buffer curr_c-ext-classif:handle
                                            ,input  'ext-classif':U
                                            ,input  "pos-type,disnct-role,templ-rl-root,rule-num,key#_one,Key#_two,key#_three,CHarkey_one,Charkey_two,Charkey_three"
                                            ,input  v-label-param).
end.
end procedure.
PROCEDURE err-mess:
  DEFINE INPUT-output PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      p-mess =
      substitute("История контрагента  &1&2: щепка &3 БД:&4 фирма: &5  Предмет изменений &6&7&8"
                 ,p-obj-type
                 , p-obj-code
                 , p-chip-num
                 , p-corr-user-db-num
                 , p-host-code
                 , p-subject
                 , chr(10)
                 , p-mess
                 ).
    end.
    otherwise do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.
