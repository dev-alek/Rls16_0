block-level on error undo, throw.
define input parameter parparentproc    as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle     as handle no-undo .
define input parameter p-auto           as integer no-undo .
define input parameter V-CURR-R-B       as character no-undo .
define input parameter p-inkas-code  like ub.inkas.inkas-code no-undo .
define input parameter p-host-code   like ub.trn-doc.host-code no-undo .
define input parameter p-obj-type    like ub.trn-doc.obj-type  no-undo .
define input parameter p-obj-code    like ub.trn-doc.obj-code  no-undo .
define input parameter p-artic       like ub.doc-line.artic    no-undo .
define input parameter p-prod-type   like ub.doc-line.prod-type    no-undo .
define input parameter p-prod-code   like ub.doc-line.prod-code    no-undo .
define input parameter p-prt-code   like ub.gds-dtl.prt-code    no-undo .
define input parameter p-rz       as logical no-undo .
define input parameter p-title    as character no-undo .
define input-output parameter p-num_rec_res as integer no-undo .
define output parameter p-num_rec_other as integer no-undo .
define output parameter p-num_rec_other_res as integer no-undo .
define parameter buffer buf_trn-doc for ub.trn-doc.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: 2014/01/27 14:27:46 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: tpsirsrv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/tpsirsrv.p $":U .
define variable vss-description as character no-undo init "Резервирование/разрезервирование ЧУЖИХ товаров в продаже".
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
procedure doc-code:
define input  parameter parmode          as   character           no-undo.
define input  parameter parobj-type      like ub.clients.obj-type no-undo.
define input  parameter parobj-code      like ub.clients.obj-code no-undo.
define input  parameter parroot-doc-code like ub.trn-doc.doc-code no-undo.
define output parameter pardoc-code      like ub.trn-doc.doc-code no-undo.
define buffer buf_sys-ctrl for ub.sys-ctrl  .
define variable vardb-remote     as   logical             no-undo.
define variable vartemp-doc-code like ub.trn-doc.doc-code no-undo.
define variable v-delimiter as character no-undo .
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
:
find first buf_sys-ctrl no-lock .
vardb-remote = buf_sys-ctrl.db-num <> 0 .
  CASE parmode:
    when "main":u then do:
      if vardb-remote then do:
        assign
          pardoc-code = trim (string (next-value (s-trn-doc, ub), ">>>>>>>>>9")) + "-" + trim (string (parobj-code, ">>>>9")) + substring (parobj-type, (if g#language = "RUS" then 1 else 2), 1).
      end.
      else do:
        assign
          pardoc-code = trim (string (next-value (s-trn-doc, ub), ">>>>>>>>>9")) + "-".
      end.
    end.
    when "trio" then do:
      assign
        pardoc-code = replace (parroot-doc-code, "=", "*").
    end.
    otherwise do:
      assign
      v-delimiter = entry(lookup(entry(1, parmode), "main,chip,pair,flora,trio-m,quadro,stock-up,stock-down,stock-fix," +                          "main_s,chip_s,pair_s,trio-m_s,quadro_s,stock-up_s,stock-down_s,stock-fix_s":U), ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)))
      no-error
      .
      if error-status:error  then do:
        undo, return error substitute("Ошибка при генерации номера документа&1Неверное значение параметра parmode &2"
                                      ,chr(10)
                                      ,parmode
                                      ).
      end.
      if num-entries(parmode) = 1
      and parmode <> "chip":U
      and parmode <> "chip_s":U
      then do:
        assign
        pardoc-code = replace (parroot-doc-code, "-", v-delimiter).
      end.
      else if (lookup("chip":U, parmode) > 0
               or
               lookup("chip_s":U, parmode) > 0) then do:
        assign
          vartemp-doc-code = parroot-doc-code.
        do while true:
          if index (vartemp-doc-code , ".") = 0 then
            vartemp-doc-code  = replace (vartemp-doc-code , v-delimiter, v-delimiter + "1.").
          else
            vartemp-doc-code  =
            substring (vartemp-doc-code , 1, index (vartemp-doc-code, v-delimiter)) +
            string (integer (substring (vartemp-doc-code, index (vartemp-doc-code, v-delimiter) + 1, index (vartemp-doc-code, ".") - index (vartemp-doc-code, v-delimiter) - 1)) + 1) +
            substring (vartemp-doc-code, index (vartemp-doc-code, ".")).
          if not can-find (ub.trn-doc where ub.trn-doc.doc-code = vartemp-doc-code no-lock) then leave.
        end.
        assign
          pardoc-code = vartemp-doc-code.
      end.
    end.
  end CASE.
  if pardoc-code = '':U
  or (parroot-doc-code <> '':U
  and pardoc-code = parroot-doc-code) then do:
    undo, return error substitute("Ошибка при генерации номера документа&1"
                                  ,chr(10)).
  end.
end.
end. // procedure/method
function get-doc-code-int64 returns int64
  ( input p-doc-code as character ) :
  define variable v-ind              as integer   no-undo .
  define variable v-num-entries      as integer   no-undo .
  define variable v-doc-code-int64   as int64     no-undo .
  define variable v-canonic-doc-code as character no-undo .
  assign
    v-num-entries      = num-entries( ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)) )
    v-canonic-doc-code = p-doc-code
  .
  do v-ind = 1 to v-num-entries
  :
    assign
      v-canonic-doc-code = entry(1, v-canonic-doc-code, entry( v-ind, ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)) ) )
    .
  end.
  assign
    v-doc-code-int64 = int64(v-canonic-doc-code) no-error
  .
  return v-doc-code-int64 .
end. // function/method
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-waitfram-action01         as character   no-undo .
define variable v-waitfram-action02         as character   no-undo .
define variable v-waitfram-action03         as character   no-undo .
define variable mWaitFramTextBeg            as character   no-undo.
define variable mWaitFramTextEnd            as character   no-undo.
define variable mWaitFramView               as logical     no-undo.
define variable mWaitProcEvent              as logical     no-undo init yes.
define variable mWaitFramInterval           as integer     no-undo init 1 .
define variable mWaitFramStop               as logical     no-undo.
define variable mWaitFramStopUser           as logical     no-undo.
define variable mWaitFramStopTimeOut        as logical     no-undo.
define variable mWaitFramStartProc          as datetime-tz no-undo.
define variable mWaitFramTimeOut            as decimal     no-undo init ?.
define button B-WaitFramStop auto-end-key
     label "Стоп"
     size 10 by 1 tooltip "Остоновить процесс".
define button B-viewProcInfo
     label "Информация"
     size 15 by 1 tooltip "Информация о процесс".
define frame waitfram
  v-waitfram-action01 format "x(72)" no-label skip
  v-waitfram-action02 format "x(72)" no-label skip
  v-waitfram-action03 format "x(72)" no-label skip
  B-viewProcInfo
  B-WaitFramStop at row 4 col 30
  with view-as dialog-box side-labels three-d cancel-button B-WaitFramStop
  .
define new global shared variable mBatchMode as logical no-undo init ?.
define variable mFramBachModHandle as handle no-undo.
mFramBachModHandle = frame waitfram:handle.
define variable mFameOldVis as logical no-undo.
define variable mVisCUrentVin as logical no-undo.
if session:batch-mode
then
   mBatchMode = yes.
if mBatchMode = ? then do:
  mVisCUrentVin = current-window:visible.
  mFameOldVis = mFramBachModHandle:visible.
  mFramBachModHandle:visible  = yes.
  mBatchMode = mFramBachModHandle:visible ne yes.
  mFramBachModHandle:visible = mFameOldVis.
  current-window:visible = mVisCUrentVin.
end.
 if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramBachModHandle:visible), "frameRepError").
  end.
on choose of B-WaitFramStop in frame waitfram
do:
  mWaitFramStop = yes.
  mWaitFramStopUser = yes.
end.
function waitfram-check-timeout returns logical():
   define variable vtime as int64 no-undo.
   if mWaitFramStopTimeOut
   then
      return yes.
   vtime = ( now - mWaitFramStartProc ) / 1000 .
   if     mWaitFramTimeOut ne ?
      and mWaitFramTimeOut ne 0
      and mWaitFramTimeOut lt vtime
   then do:
      mWaitFramStopTimeOut = yes.
   end.
   return mWaitFramStopTimeOut.
end.
procedure waitfram-hide :
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    pause 0 before-hide .
    if not mBatchMode then
      hide frame waitfram .
  if     not mWaitFramView
     and mWaitProcEvent
  then
    process events .
  end.
end procedure.
procedure waitfram-show :
  define input  parameter p-message as character no-undo .
  define variable v-left-margin as integer   no-undo .
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    if length(p-message) <= 70 then do:
      assign
        v-left-margin = integer((70 - length(p-message)) / 2)
      .
      assign
        v-left-margin = max(0, v-left-margin - (v-left-margin mod 5))
      .
      assign
        v-waitfram-action01 = " "
        v-waitfram-action02 = " "
                                 + fill(" ", v-left-margin)
                                 + p-message
        v-waitfram-action03 = " "
      .
    end.
    else do:
      define variable vRindex1 as integer no-undo.
      define variable vRindex2 as integer no-undo.
      vRindex1 = r-index(p-message," ",70).
      if vRindex1 = 0
      then
         vRindex1 = 70.
      if length(p-message)  <= vRindex1 + 70 then do:
        assign
          v-waitfram-action01 = " "
          v-waitfram-action02 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action03 = " " + substring(p-message,  vRindex1 + 1, 70      )
        .
      end.
      else do:
        vRindex2 = r-index(p-message," ",vRindex1 + 70).
        if vRindex2 <= vRindex1
        then
           vRindex2 = vRindex1 + 70.
        assign
          v-waitfram-action01 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action02 = " " + substring(p-message,  vRindex1 + 1, vRindex2 - vRindex1 )
          v-waitfram-action03 = " " + substring(p-message,  vRindex2 + 1, 70)
        .
      end.
    end.
    B-viewProcInfo:visible   in frame waitfram = no.
    B-viewProcInfo:sensitive in frame waitfram = no.
    B-WaitFramStop:visible   in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    B-WaitFramStop:sensitive in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    if  (   mWaitFramView
       or  mWaitProcEvent)
       and not mBatchMode
    then
       display
          v-waitfram-action01 skip
          v-waitfram-action02 skip
          v-waitfram-action03 skip
       with frame waitfram .
    if     mWaitFramView
       then do:
          if     mWaitFramInterval ne ?
             and not mBatchMode
          then
             wait-for go of frame waitfram pause mWaitFramInterval.
       end.
       else
          if     mWaitProcEvent
             and not mBatchMode
          then
             process events .
  end.
end procedure.
   procedure waitfram-show-this:
      define input  parameter iInterval as int64 no-undo.
      define variable vtime as int64 no-undo.
      vtime = ( now - mWaitFramStartProc  ) / 1000 .
      mWaitFramInterval = iInterval.
      run waitfram-show (substitute("&1&2 &3&4" ,
                                    mWaitFramTextBeg ,
                                    if vtime eq ? then "" else substitute (" Прошло: &1 сек" , string( vtime)),
                                    if mWaitFramTimeOut ne 0 and mWaitFramTimeOut ne ? then " из " + string(mWaitFramTimeOut) + " сек. " else "",
                                    mWaitFramTextEnd
                                   )
                        ).
   end.
   procedure WaitFramRunPause:
      define input  parameter iInterval as dec no-undo.
      define variable vStart  as datetime-tz no-undo.
      define variable vend    as datetime-tz no-undo.
      define variable vint as int64 no-undo.
      define variable vOk as logical no-undo.
      vStart = now.
      vend   = vStart.
      publish "WaitFramPause" (iInterval,output vOk).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and (   vint > 0
              or (    not vOk
                  and iInterval eq ?
                  )
              )
      then
         run waitfram-show-this (iInterval).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and vint > 0
      then do:
         run gbl/pause.p (vint * 1000).
      end.
      if iInterval ne ?
      then
         publish "WaitFramStop".
      waitfram-check-timeout().
   end.
   procedure WaitFramWaitFor:
      define input  parameter iInterval as dec no-undo.
      assign
         mWaitFramStartProc   = now
         mWaitFramStopUser    = no
         mWaitFramStopTimeOut = no
      .
      block-wait:
      do while not mWaitFramStop:
         run WaitFramRunPause (iInterval).
         if  waitfram-check-timeout()
         then do:
            leave block-wait.
         end.
      end.
      run waitfram-hide.
   end.
procedure waitfram-join :
  define input  parameter p-line-1  as character no-undo .
  define input  parameter p-line-2  as character no-undo .
  define input  parameter p-line-3  as character no-undo .
  define output parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-message = substring(p-line-1 + fill(' ', 70), 1, 70)
                + substring(p-line-2 + fill(' ', 70), 1, 70)
                + substring(p-line-3 + fill(' ', 70), 1, 70)
    .
  end.
end procedure.
function waitfram-join-function returns character
  (input p-line-1 as character
  ,input p-line-2 as character
  ,input p-line-3 as character
  ).
  define variable v-message as character no-undo .
  run waitfram-join in this-procedure
    (input  p-line-1
    ,input  p-line-2
    ,input  p-line-3
    ,output v-message
    ) .
  return v-message .
end function .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table lib-trn_ret-doc       no-undo like ub.trn-doc.
define temp-table lib-trn_ret-line      no-undo like ub.doc-line
  field cst-code                like ub.trn-doc.cst-code
  field part-code               like ub.parts.part-code
  .
define temp-table lib-trn_ret-line-attr no-undo like ub.doc-line-attr.
define temp-table lib-trn_ret-dtl       no-undo like ub.gds-dtl.
define temp-table lib-trn_ret-parts     no-undo like ub.parts.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define SHARED temp-table tt0-info no-undo
field doc-code   like ub.trn-doc.doc-code
field artic      like ub.doc-line.artic
field prod-type  like ub.doc-line.prod-type
field prod-code  like ub.doc-line.prod-code
field prt-code  like ub.gds-dtl.prt-code
field obj-type   like ub.doc-line.obj-type
field obj-code   like ub.doc-line.obj-code
field error-message as character
field a-to-res as decimal
field was-res as decimal
field to-res as decimal
field is-res as decimal
field o-was-res as decimal
field o-to-res as decimal
field o-is-res as decimal
index pi is unique primary
obj-type
obj-code
artic
prod-type
prod-code
index iartic
artic
prod-type
prod-code
.
define SHARED temp-table tt0-doc-line no-undo like lib-trn_ret-line.
define SHARED temp-table tt0-gds-dtl  no-undo like ub.gds-dtl.
define SHARED temp-table tt0-parts    no-undo like ub.parts.
define SHARED temp-table temp-tpsi-clients  no-undo like ub.clients.
FUNCTION set-tpsi-doc-PS returns character( buffer buf_sale-doc for ub.sale-doc):
define variable v-ps as character no-undo .
assign
v-PS = substitute('@&1 для закрытия продажи &2 на &3&4&5товаров &6&5признаков &7'
                  , entry (lookup (buf_sale-doc.ext-doc-type, 'ee,ev,ie,es,iv':U), 'Межфирм.расход по ТПСИ,Внутр.расход по ТПСИ,Межфирм.приход по ТПСИ,Внутр.приход по ТПСИ':U)
                  , buf_sale-doc.out-code
                  , buf_sale-doc.obj-type
                  , buf_sale-doc.obj-code
                  , chr(4)
                  , buf_sale-doc.tot-lines
                  , buf_sale-doc.tot-dtl
                  ).
return v-Ps.
END FUNCTION.
procedure create-tt0-doc-line-gds-dtl :
define input parameter p-proprietor-obj-type like ub.trn-doc.obj-type no-undo .
define input parameter p-proprietor-obj-code like ub.trn-doc.obj-code no-undo .
define input parameter p-ext-doc-type        as character no-undo .
define input parameter p-doc-code            like ub.trn-doc.doc-code no-undo .
define input parameter p-artic               like ub.gds-dtl.artic no-undo .
define input parameter p-prod-type           like ub.gds-dtl.prod-type no-undo .
define input parameter p-prod-code           like ub.gds-dtl.prod-code no-undo .
define input parameter p-prt-code            like ub.gds-dtl.prt-code  no-undo .
define input parameter p-fact-qnty           like ub.gds-dtl.fact-qnty no-undo .
define output parameter p-was-gds-dtl-doc-qnty  like ub.gds-dtl.fact-qnty no-undo .
define output parameter p-gds-dtl-fact-qnty  like ub.gds-dtl.fact-qnty no-undo .
define parameter buffer b-doc-line           for ub.doc-line.
define parameter buffer b-gds-dtl            for ub.gds-dtl.
define parameter buffer buf_sale-doc for ub.sale-doc.
define variable old-qnty like ub.doc-line.fact-qnty no-undo .
define buffer other_doc-line for ub.doc-line.
define buffer other_gds-dtl for ub.gds-dtl.
  do
  on error undo, return error return-value
  :
    find first tt0-doc-line where
              tt0-doc-line.obj-type = p-proprietor-obj-type
          AND tt0-doc-line.obj-code = p-proprietor-obj-code
          AND tt0-doc-line.prod-type = p-prod-type
          AND tt0-doc-line.prod-code = p-prod-code
          AND tt0-doc-line.artic     = p-artic
          AND tt0-doc-line.ext-doc-type = p-ext-doc-type
          AND tt0-doc-line.status_      = 'нередакт':U no-error .
    if not available tt0-doc-line then do:
      create tt0-doc-line.
      buffer-copy b-doc-line
      except
      obj-type obj-code doc-code status_ ext-doc-type doc-qnty fact-qnty
      to tt0-doc-line
      assign
      tt0-doc-line.status_ = 'нередакт':U
      tt0-doc-line.ext-doc-type = p-ext-doc-type
      tt0-doc-line.obj-type = p-proprietor-obj-type
      tt0-doc-line.obj-code = p-proprietor-obj-code
      tt0-doc-line.doc-code = p-doc-code
      .
    end.
    if p-doc-code <> "":U then do:
      find first other_doc-line no-lock where
              other_doc-line.doc-code = p-doc-code
          AND  other_doc-line.artic    = p-artic
          AND  other_doc-line.prod-type = p-prod-type
          AND  other_doc-line.prod-code = p-prod-code no-error .
      if available other_doc-line then do:
        find first buf_sale-doc where buf_sale-doc.doc-code = other_doc-line.doc-code.
        assign
        tt0-doc-line.doc-qnty = other_doc-line.doc-qnty
        .
      end.
      else do:
        assign
        tt0-doc-line.doc-code = '':U
        .
      end.
    end.
    find first tt0-gds-dtl where
            tt0-gds-dtl.obj-type = p-proprietor-obj-type
        AND tt0-gds-dtl.obj-code = p-proprietor-obj-code
        AND tt0-gds-dtl.prod-type = p-prod-type
        AND tt0-gds-dtl.prod-code = p-prod-code
        AND tt0-gds-dtl.artic     = p-artic
        AND tt0-gds-dtl.prt-code  = p-prt-code  no-error .
    if not available tt0-gds-dtl then do:
      create tt0-gds-dtl.
      buffer-copy b-gds-dtl
      except
      obj-type obj-code doc-code doc-qnty fact-qnty
      to tt0-gds-dtl
      assign
      tt0-gds-dtl.obj-type = p-proprietor-obj-type
      tt0-gds-dtl.obj-code = p-proprietor-obj-code
      tt0-gds-dtl.doc-code = p-doc-code
      .
    end.
    if p-doc-code <> "":U then do:
        find first other_gds-dtl no-lock where
                other_gds-dtl.doc-code = p-doc-code
            AND  other_gds-dtl.artic    = p-artic
            AND  other_gds-dtl.prod-type    = p-prod-type
            AND  other_gds-dtl.prod-code    = p-prod-code
            AND  other_gds-dtl.prt-code    = p-prt-code no-error .
        if available other_gds-dtl then do:
          assign
          tt0-gds-dtl.doc-qnty = other_gds-dtl.doc-qnty
          .
        end.
        else do:
          assign
          tt0-gds-dtl.doc-code = '':U
          .
        end.
    end.
    assign
    old-qnty = tt0-gds-dtl.doc-qnty
    tt0-gds-dtl.fact-qnty = (if p-fact-qnty = ? then (- old-qnty) else (p-fact-qnty - tt0-gds-dtl.doc-qnty))
    tt0-doc-line.fact-qnty = tt0-doc-line.fact-qnty + (if p-fact-qnty = ? then (- old-qnty) else p-fact-qnty)
    p-gds-dtl-fact-qnty = tt0-gds-dtl.fact-qnty
    p-was-gds-dtl-doc-qnty = tt0-gds-dtl.doc-qnty
    .
  end.
end procedure.
procedure fill-tt-tpsi-table :
define input parameter p-doc-code  like ub.trn-doc.doc-code  no-undo .
define input parameter p-host-code like ub.trn-doc.host-code no-undo .
define input parameter p-obj-type  like ub.trn-doc.obj-type  no-undo .
define input parameter p-obj-code  like ub.trn-doc.obj-code  no-undo .
define variable v-proprietor-host-code      like ub.clients.host-code no-undo .
define variable v-proprietor-obj-type       like ub.clients.obj-type no-undo .
define variable v-proprietor-obj-code       like ub.clients.obj-code no-undo .
define variable v-ext-doc-type              like ub.trn-doc.ext-doc-type no-undo .
define variable v-gds-dtl-fact-qnty         like ub.gds-dtl.fact-qnty no-undo .
define variable v-was-gds-dtl-fact-qnty     like ub.gds-dtl.fact-qnty no-undo .
define buffer buf_goods for ub.goods.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_gds-dtl for ub.gds-dtl.
define buffer buf_sale-doc for ub.sale-doc.
  do
  on error undo, return error
  :
    _doc-line:
    for each buf_Doc-line no-lock where
          buf_doc-line.doc-code = p-doc-code,
      first buf_goods no-lock where
          buf_goods.artic = buf_doc-line.artic
     AND  buf_goods.prod-type  = buf_doc-line.prod-type
     AND  buf_goods.prod-code  = buf_doc-line.prod-code,
        each buf_gds-dtl no-lock where
          buf_gds-dtl.doc-code = buf_doc-line.doc-code
      AND  buf_gds-dtl.artic    = buf_doc-line.artic
      AND  buf_gds-dtl.prod-type = buf_doc-line.prod-type
      AND  buf_gds-dtl.prod-code = buf_doc-line.prod-code:
      assign
      v-ext-doc-type = "":U.
      run tpsi-preselect-gds-proprietor in this-procedure (
                                                  input buf_goods.gds-code
                                                ,input g#db-num
                                                ,output v-proprietor-host-code
                                                ,output v-proprietor-obj-type
                                                ,output v-proprietor-obj-code ) no-error .
      if v-proprietor-host-code = p-host-code then do:
        assign
        v-ext-doc-type = 'ev':U .
      end.
      else do:
        assign
        v-ext-doc-type =  'ee':U .
      end.
      if  (v-proprietor-obj-type = p-obj-type
      AND v-proprietor-obj-code = p-obj-code)
      OR (v-proprietor-obj-type = "":U
      AND v-proprietor-obj-code = 0)
      OR v-proprietor-obj-code = ?
      then next _doc-line.
      find first buf_sale-doc no-lock where
                buf_sale-doc.inkas-code = p-doc-code
           AND buf_sale-doc.obj-type = v-proprietor-obj-type
           AND buf_sale-doc.obj-code = v-proprietor-obj-code
           AND buf_sale-doc.ext-doc-type = v-ext-doc-type
           no-error .
      run create-tt0-doc-line-gds-dtl  in this-procedure (
                                                           input v-proprietor-obj-type
                                                          ,input v-proprietor-obj-code
                                                          ,input v-ext-doc-type
                                                          ,input (if available buf_sale-doc then buf_sale-doc.doc-code else "":U)
                                                          ,input buf_doc-line.artic
                                                          ,input buf_Doc-line.prod-type
                                                          ,input buf_doc-line.prod-code
                                                          ,input buf_gds-dtl.prt-code
                                                          ,input 0
                                                          ,output v-was-gds-dtl-fact-qnty
                                                          ,output v-gds-dtl-fact-qnty
                                                          ,buffer buf_doc-line
                                                          ,buffer buf_gds-dtl
                                                          ,buffer buf_sale-doc
                                                        ).
    end.
  end.
end procedure.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
procedure get-alias-type-price-obj :
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-obj-code  like ub.clients.obj-code no-undo .
define input parameter p-prop-host-code like ub.sysconf.host-code no-undo .
define input parameter p-prop-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-prop-obj-code  like ub.clients.obj-code no-undo .
define output parameter p-ext-doc-type like ub.trn-doc.ext-doc-type no-undo .
define output parameter p-alias-type-price as character no-undo .
define output parameter p-price-obj-type like ub.clients.obj-type no-undo .
define output parameter p-price-obj-code like ub.clients.obj-code no-undo .
define variable v-mediat-obj-type           like ub.trn-doc.obj-type no-undo .
define variable v-mediat-obj-code           like ub.trn-doc.obj-code no-undo .
define variable v-mediat-objf               as character no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
define buffer buf_trn-doc for ub.trn-doc.
  _main:
  do
  on error undo, return error return-value
  :
    run adm/shattri.p (
      input "get":U
      ,input  p-prop-obj-type
      ,input  p-prop-obj-code
      ,input  'alias-tpsi':U
      ,input  '':U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
    if error-status:error
    then do:
      undo _main, return error substitute("Не удалось определить настройки МЕЖФИРМЕННОГО ИЛИ ВНУТРЕННЕГО ПЕРЕМЕЩЕНИЯ ЧУЖИХ ТОВАРОВ для &1&2"
                              , p-prop-obj-type
                              , p-prop-obj-code).
    end.
    find first thbjattr_thbj-attr where
              thbjattr_thbj-attr.obj-type = p-prop-obj-type
          and thbjattr_thbj-attr.obj-code = p-prop-obj-code
          and thbjattr_thbj-attr.upper-prop-code = 'alias-tpsi':U
          and thbjattr_thbj-attr.prop-code = 'alias-type-price':U no-error.
    if not available thbjattr_thbj-attr
    or thbjattr_thbj-attr.property-value-integer = 0 then do:
      undo _main, return error substitute("Не задано значение атрибута ТИП ЦЕНЫ МЕЖФИРМЕННОГО ИЛИ ВНУТРЕННЕГО ПЕРЕМЕЩЕНИЯ ЧУЖИХ ТОВАРОВ для &1&2"
                              , p-prop-obj-type
                              , p-prop-obj-code).
    end.
    assign
    p-alias-type-price = string(thbjattr_thbj-attr.property-value-integer).
    if p-prop-host-code = p-host-code
    and (p-alias-type-price = '':U
    or   p-alias-type-price <> '5':U)
    then  do:
      assign
      p-ext-doc-type = 'ev':U
      p-price-obj-type = p-obj-type
      p-price-obj-code = p-obj-code
      p-alias-type-price = '3':U
      .
    end.
    else do:
      if p-prop-host-code = p-host-code  then do:
        assign
        p-ext-doc-type = 'ev':U
        p-price-obj-type = p-obj-type
        p-price-obj-code = p-obj-code
        .
      end.
      else do:
        assign
        p-ext-doc-type = 'ee':U.
        assign
        v-mediat-obj-type = "":U
        v-mediat-obj-code = 0
        v-mediat-objf = "":U
        .
        if p-alias-type-price = '4':U then do:
          find first thbjattr_thbj-attr where
                    thbjattr_thbj-attr.obj-type = p-prop-obj-type
                and thbjattr_thbj-attr.obj-code = p-prop-obj-code
                and thbjattr_thbj-attr.upper-prop-code = 'alias-tpsi':U
                and thbjattr_thbj-attr.prop-code = 'alias-object-price':U no-error.
          if not available thbjattr_thbj-attr
          or thbjattr_thbj-attr.property-value-character = "":U then do:
            undo _main, return error substitute("Не найден объект-посредник для межфирменного перемещения ЧУЖИХ товаров с &1&2"
                                    , p-prop-obj-type
                                    , p-prop-obj-code).
          end.
          assign
          v-mediat-objf     = thbjattr_thbj-attr.property-value-character
          v-mediat-obj-type = entry(1, v-mediat-objf)
          v-mediat-obj-code = integer(entry(2, v-mediat-objf))
          no-error
          .
          if error-status:error then do:
            undo _main, return error substitute("Неверный формат атрибута ОБЪЕКТ-ПОСРЕДНИК для межфирменного перемещения ЧУЖИХ товаров для &1&2"
                                    , p-prop-obj-type
                                    , p-prop-obj-code).
          end.
        end.
        CASE p-alias-type-price:
          when '1':U then do:
            assign
            p-price-obj-type = p-prop-obj-type
            p-price-obj-code = p-prop-obj-code
            .
          end.
          when '2':U then do:
            assign
            p-price-obj-type = p-prop-obj-type
            p-price-obj-code = p-prop-obj-code
            .
          end.
          when '3':U
          or
          when '5':U
          then do:
            assign
            p-price-obj-type = p-obj-type
            p-price-obj-code = p-obj-code
            .
          end.
          when '4':U then do:
            assign
            p-price-obj-type = v-mediat-obj-type
            p-price-obj-code = v-mediat-obj-code
            .
          end.
        END CASE.
      end.
    end.
  end.
end procedure.
procedure write-tt0-info:
define input parameter p-artic as character no-undo .
define input parameter p-prod-type as character no-undo .
define input parameter p-prod-code as integer no-undo .
define input parameter p-prt-code as integer no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-doc-code as character no-undo .
define input parameter p-from-tpsi as logical no-undo .
define input parameter p-all-qnty as decimal no-undo .
define input parameter p-was-res as decimal no-undo .
define input parameter p-to-res as decimal no-undo .
define input parameter p-is-res as decimal no-undo .
define input parameter p-o-was-res as decimal no-undo .
define input parameter p-o-to-res as decimal no-undo .
define input parameter p-o-is-res as decimal no-undo .
define input parameter p-mess   as character no-undo .
define buffer buf_tt0-info for tt0-info.
  do
  on error undo, return error return-value
  :
    find first buf_tt0-info where
             buf_tt0-info.artic = p-artic
         and buf_tt0-info.prod-type = p-prod-type
         and buf_tt0-info.prod-code = p-prod-code
         and buf_tt0-info.prt-code = p-prt-code
         no-error .
    if not available buf_tt0-info then do:
      create buf_tt0-info.
      assign
      buf_tt0-info.artic = p-artic
      buf_tt0-info.prod-type = p-prod-type
      buf_tt0-info.prod-code = p-prod-code
      buf_tt0-info.prt-code  = p-prt-code
      buf_tt0-info.obj-type  = p-obj-type
      buf_tt0-info.obj-code  = p-obj-code
      buf_tt0-info.a-to-res  = ?
      buf_tt0-info.to-res    = ?
      buf_tt0-info.was-res   = ?
      buf_tt0-info.o-was-res = ?
      buf_tt0-info.o-to-res  = ?
      buf_tt0-info.o-is-res  = ?
      buf_tt0-info.is-res    = ?
      .
    end.
    assign
    buf_tt0-info.a-to-res  =
                              (if buf_tt0-info.a-to-res <> ?
                              and p-all-qnty = ?
                              then buf_tt0-info.a-to-res
                              else p-all-qnty)
    buf_tt0-info.was-res   = (if buf_tt0-info.was-res <> ?
                              and p-was-res = ?
                              then buf_tt0-info.was-res
                              else p-was-res)
    buf_tt0-info.to-res    = (if buf_tt0-info.to-res <> ?
                              and p-to-res = ?
                              then buf_tt0-info.to-res
                              else p-to-res)
    buf_tt0-info.is-res    = (if buf_tt0-info.is-res <> ?
                              and p-is-res = ?
                              then buf_tt0-info.is-res
                              else p-is-res)
    buf_tt0-info.o-was-res   = (if buf_tt0-info.o-was-res <> ?
                              and p-o-was-res = ?
                              then buf_tt0-info.o-was-res
                              else p-o-was-res)
    buf_tt0-info.o-to-res    = (if buf_tt0-info.o-to-res <> ?
                              and p-o-to-res = ?
                              then buf_tt0-info.o-to-res
                              else p-o-to-res)
    buf_tt0-info.o-is-res    = (if buf_tt0-info.o-is-res <> ?
                              and p-o-is-res = ?
                              then buf_tt0-info.o-is-res
                              else p-o-is-res)
    .
    assign
    buf_tt0-info.doc-code  = p-doc-code
    buf_tt0-info.error-message   = p-mess
    .
  end.
end procedure.
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable gp-doc-num    like ub.price-list.doc-num    no-undo.
define variable gp-price-sale like ub.price-list.price-sale no-undo.
define variable gp-road-tax   like ub.price-list.road-tax   no-undo.
define variable gp-excise     like ub.price-list.excise     no-undo.
define variable gp-b-code     like ub.bar-code.b-code       no-undo.
define variable gp-fact-order as decimal   no-undo .
define variable gp-price-sale-parts as decimal   no-undo .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION set-sale-doc-PS returns character( buffer buf_sale-doc for ub.sale-doc):
define variable v-ps as character no-undo .
if available buf_sale-doc then
assign
v-PS = substitute('&1&2 &1&3&1Кол-во_чеков &4&1строк_чеков &5&1товаров &6&1признаков &7&1'
                    , chr(4)
                    , (if buf_sale-doc.chr-office = 'у':U then "УСЛУГИ." else "ТОВАРЫ." )
                    , entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U )
                    , buf_sale-doc.chk-amount
                    , buf_sale-doc.gds-amount
                    , buf_sale-doc.tot-lines
                    , buf_sale-doc.tot-dtl
                    ).
else  do:
assign
v-PS = substitute('&1&2 &1&3&1Кол-во_чеков &4&1строк_чеков &5&1товаров &6&1признаков &7&1'
                    , chr(4)
                    , '':U
                    , entry (lookup ('es':U, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U )
                    , 0
                    , 0
                    , 0
                    , 0
                    ).
end.
return v-ps.
END FUNCTION.
FUNCTION get-sale-doc-kind returns character (
                                             input p-doc-kind as character
                                           , input p-ext-doc-type as character
                                           , output p-order as integer
                                           , output p-msign as integer
                                           , output p-main as logical
                                           , output p-in-inkas as logical
                                           , output p-dir_ as integer
                                           ):
define variable v-doc-kind as character no-undo.
define variable v-type as character no-undo .
define variable v-value as character no-undo .
CASE p-doc-kind:
  when 'es':U then do:
    assign
    p-order = 100
    p-msign = 1
    p-main = yes
    p-in-inkas = yes
    p-dir_ = 1
    .
    return p-ext-doc-type.
  end.
  when  'rs':U then do:
    assign
    p-order = 200
    p-msign = - 1
    p-main = no
    p-in-inkas = yes
    p-dir_ = - 1
    .
    return p-ext-doc-type.
  end.
  when 'rwo':U then do:
    assign
    p-msign = - 1
    p-main = no
    p-in-inkas = no
    p-order = 300
    p-dir_ = 1
    .
    return 'rwo':U.
  end.
  when 'trf':U then do:
    assign
    p-msign = 1
    p-main = no
    p-in-inkas = no
    p-order = 400
    p-dir_ = 1
    .
    return 'trf':U.
  end.
  when 'swo':U then do:
   assign
   p-msign = 1
   p-main = no
   p-in-inkas = no
   p-order =  500
   p-dir_ = 1
   .
   return 'swo':U.
 end.
 when 'vir':U then do:
   assign
   p-msign = 1
   p-main = no
   p-in-inkas = no
   p-order = 600
   p-dir_ = 1
   .
   return 'vir':U.
 end.
 when 'itr':U then do:
   assign
   p-msign = 1
   p-main = no
   p-in-inkas = no
   p-order = -1
   p-dir_ = -1
   .
  return 'itr':U.
 end.
 when 'ngs':U then do:
   assign
   p-msign = 1
   p-main = no
   p-in-inkas = no
   p-order = 700
   p-dir_ = 1
   .
   return 'ngs':U.
 end.
 when 'rgs':U then do:
   assign
   p-msign = -1
   p-main = no
   p-in-inkas = no
   p-order = 701
   p-dir_ = -1
   .
   return 'rgs':U.
 end.
 otherwise do:
    assign
    p-msign = 1
    p-main = no
    p-in-inkas = no
    p-order = -1.
    return p-ext-doc-type.
  end.
END CASE.
END FUNCTION.
procedure saledoc-create :
define input parameter p-inkas-code like ub.inkas.inkas-code no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-obj-code  like ub.clients.obj-code no-undo .
define input parameter p-doc-kind as character no-undo .
define input parameter p-office as character no-undo .
define input parameter p-tpsidoc as logical no-undo .
define input parameter p-alias-type-price as character no-undo .
define input parameter p-price-obj-type as character no-undo .
define input parameter p-price-obj-code as integer no-undo .
define parameter buffer buf_trn-doc for ub.trn-doc.
define variable v-order as integer no-undo.
define variable v-main as logical no-undo .
define variable v-in-inkas as logical no-undo .
define variable v-msign as integer no-undo .
define variable v-dir_ as integer no-undo .
define variable v-trn-doc-code as character no-undo .
define buffer buf_sale-doc for ub.sale-doc.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
   if available buf_trn-doc then do:
     v-trn-doc-code = buf_trn-doc.doc-code.
   end.
   find first buf_sale-doc where
            buf_sale-doc.inkas-code = p-inkas-code
        and buf_sale-doc.doc-kind = p-doc-kind
        and buf_sale-doc.chr-office = p-office
        and (v-trn-doc-code = '' or buf_sale-doc.doc-code = v-trn-doc-code)
        no-error .
   if not available buf_sale-doc  then do:
      create buf_sale-doc.
      assign
      buf_sale-doc.inkas-code = p-inkas-code
      buf_sale-doc.storage =  'trn-doc':U
      buf_sale-doc.host-code = p-host-code
      buf_sale-doc.obj-type = p-obj-type
      buf_sale-doc.obj-code = p-obj-code
      buf_sale-doc.doc-kind  = p-doc-kind
      buf_sale-doc.order = lookup(p-doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U) * 100 + (if p-office = 'у':U then 5 else 0)
      buf_sale-doc.chr-office = p-office
      buf_sale-doc.doc-code = v-trn-doc-code
      .
   end.
   if available buf_trn-doc then
   buffer-copy buf_trn-doc
   to buf_sale-doc
   .
  assign
  buf_sale-doc.doc-kind = get-sale-doc-kind (
                                             input p-doc-kind
                                            ,input buf_sale-doc.ext-doc-type
                                            ,output v-order
                                            ,output v-msign
                                            ,output v-main
                                            ,output v-in-inkas
                                            ,output v-dir_).
  assign
  buf_sale-doc.order = v-order + (if p-office = 'у':U then 5 else 0)
  buf_sale-doc.main-doc = v-main
  buf_sale-doc.in-inkas = v-in-inkas
  buf_sale-doc.msign = v-msign
  buf_sale-doc.dir = v-dir_
  buf_sale-doc.fbrsale = lookup(buf_sale-doc.doc-kind, 'es,swo':U) > 0
  buf_sale-doc.main-receipt-type = integer(entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U) + 1, '0,1,6,96,17,69,17,17':U))
  buf_sale-doc.poss-wro-codes = '':U
  buf_sale-doc.chr-office = p-office
  buf_sale-doc.tpsidoc = p-tpsidoc
  buf_sale-doc.alias-type-price = p-alias-type-price
  buf_sale-doc.price-obj-type = (if p-tpsidoc
                                 then p-price-obj-type
                                 else '':U)
  buf_sale-doc.price-obj-code = (if p-tpsidoc
                                 then p-price-obj-code
                                 else 0)
  .
  assign
  buf_sale-doc.poss-wro-codes = (if (v-order > 0 and buf_sale-doc.doc-kind <> 'vir':U) then entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U) + 1, '0,2,-2,-6;-3;-9;-4,17,1;3':U) else '':U)
  no-error.
end.
END.
procedure fbr-saledoc-create :
define input parameter p-inkas-code as character no-undo .
define variable v-pri-prvo-doc-qnty like ub.trn-doc.doc-qnty no-undo .
define variable v-pri-prvo-fact-qnty like ub.trn-doc.doc-qnty no-undo .
define variable v-pri-prvo-tot-lines like ub.trn-doc.tot-lines no-undo .
define buffer buf_fbr-doc for ub.fbr-doc.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_sale-doc for ub.sale-doc.
define buffer buf2_sale-doc for ub.sale-doc.
define buffer buf2_trn-doc for ub.trn-doc.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_gds-dtl for ub.gds-dtl.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_chk-doc for ub.chk-doc.
do
on error undo, return error
:
  for each buf_fbr-doc no-lock where
        buf_fbr-doc.out-code = p-inkas-code:
    for each buf_trn-doc no-lock where
          buf_trn-doc.out-code = buf_fbr-doc.doc-code
    by buf_trn-doc.fact-order
    on error undo, return error:
      if buf_trn-doc.ext-doc-type = 'em':U
      or buf_trn-doc.ext-doc-type = 'im':U
      or buf_trn-doc.ext-doc-type = 'wm':U
      or buf_trn-doc.ext-doc-type = 'ev':U
      or buf_trn-doc.ext-doc-type = 'iv':U
      then do:
        find first buf_sale-doc where
                buf_sale-doc.inkas-code = p-inkas-code
            and buf_sale-doc.doc-code = buf_trn-doc.doc-code
            AND buf_sale-doc.storage  = 'trn-doc':U
                no-error .
        if not available buf_sale-doc then do:
        create buf_sale-doc.                                                                                             buffer-copy buf_trn-doc                                                                                             to buf_sale-doc.                                                                                                assign                                                                                                                  buf_sale-doc.storage  =  'trn-doc':U                                                                          buf_sale-doc.doc-kind = buf_trn-doc.ext-doc-type                                                                buf_sale-doc.order =  - 1                                                                                          buf_sale-doc.main-doc = no                                                                                             buf_sale-doc.in-inkas = no                                                                                         buf_sale-doc.fbrsale = yes                                                                                         buf_sale-doc.msign = 1                                                                                             buf_sale-doc.filled   = buf_sale-doc.fact-qnty <> 0 or buf_sale-doc.tot-lines <> 0                       buf_sale-doc.doc-qnty = (if buf_sale-doc.ext-doc-type = 'pc':U                                                           then ?                                                                                                                  else buf_sale-doc.doc-qnty)                                                          buf_sale-doc.fact-qnty = (if buf_sale-doc.ext-doc-type = 'pc':U                                                          then ?                                                                                                                  else buf_sale-doc.fact-qnty)                                                        buf_sale-doc.inkas-code = p-inkas-code.
        end.
        if buf_trn-doc.ext-doc-type = 'im':U then do:
          assign
          v-pri-prvo-doc-qnty = buf_trn-doc.doc-qnty
          v-pri-prvo-fact-qnty = buf_trn-doc.fact-qnty
          v-pri-prvo-tot-lines = buf_trn-doc.tot-lines
          .
        end.
        for each buf2_trn-doc no-lock where
                buf2_trn-doc.out-code = buf_sale-doc.doc-code:
          find first buf2_sale-doc where
                  buf2_sale-doc.inkas-code = p-inkas-code
              and buf2_sale-doc.doc-code = buf2_trn-doc.doc-code
              AND buf2_sale-doc.storage = 'trn-doc':U no-error .
          if not available buf2_sale-doc then do:
            create buf2_sale-doc.                                                                                             buffer-copy buf2_trn-doc                                                                                             to buf2_sale-doc.                                                                                                assign                                                                                                                  buf2_sale-doc.storage  =  'trn-doc':U                                                                          buf2_sale-doc.doc-kind = buf2_trn-doc.ext-doc-type                                                                buf2_sale-doc.order =  - 1                                                                                          buf2_sale-doc.main-doc = no                                                                                             buf2_sale-doc.in-inkas = no                                                                                         buf2_sale-doc.fbrsale = yes                                                                                         buf2_sale-doc.msign = 1                                                                                             buf2_sale-doc.filled   = buf2_sale-doc.fact-qnty <> 0 or buf2_sale-doc.tot-lines <> 0                       buf2_sale-doc.doc-qnty = (if buf2_sale-doc.ext-doc-type = 'pc':U                                                           then ?                                                                                                                  else buf2_sale-doc.doc-qnty)                                                          buf2_sale-doc.fact-qnty = (if buf2_sale-doc.ext-doc-type = 'pc':U                                                          then ?                                                                                                                  else buf2_sale-doc.fact-qnty)                                                        buf2_sale-doc.inkas-code = p-inkas-code.
          end.
        end.
      end.
    end.
    find first buf_sale-doc where
              buf_sale-doc.inkas-code = p-inkas-code
          AND buf_sale-doc.storage = 'fbr-doc':U
          AND buf_sale-doc.doc-code = buf_fbr-doc.doc-code no-error .
    if not available buf_sale-doc then do:
      create buf_sale-doc.
      assign
      buf_sale-doc.storage       =  'fbr-doc':U
      buf_sale-doc.doc-type      = 'производство':U
      buf_sale-doc.doc-code      = buf_fbr-doc.doc-code
      buf_sale-doc.ext-doc-type  = 'производство':U
      buf_sale-doc.doc-kind      = 'производство':U
      buf_sale-doc.obj-type      = buf_fbr-doc.obj-type
      buf_sale-doc.obj-code      = buf_fbr-doc.obj-code
      buf_sale-doc.cli-type      = buf_fbr-doc.obj-type
      buf_sale-doc.cli-code      = buf_fbr-doc.obj-code
      buf_sale-doc.doc-qnty      = v-pri-prvo-doc-qnty
      buf_sale-doc.fact-qnty     = v-pri-prvo-fact-qnty
      buf_sale-doc.tot-lines     = v-pri-prvo-tot-lines
      buf_sale-doc.tot-dtl       = v-pri-prvo-tot-lines
      buf_sale-doc.fbrsale       = yes
      buf_sale-doc.inkas-code    = p-inkas-code
      .
    end.
  end.
end.
end procedure.
define variable v-base-code                 like ub.sysconf.base-code no-undo .
define variable v-alias-type-price          as character no-undo .
define variable v-doc-code                  like ub.trn-doc.doc-code no-undo .
define variable v-prop-host-code            like ub.sysconf.host-code no-undo .
define variable v-prop-base-code            like ub.sysconf.base-code no-undo .
define variable v-ext-doc-type              like ub.trn-doc.ext-doc-type no-undo .
define variable v-price-obj-type            like ub.trn-doc.obj-type no-undo .
define variable v-price-obj-code            like ub.trn-doc.obj-code no-undo .
define variable v-sys-today                 as date no-undo .
define variable v-base-rate                 like ub.curr-accnt.exch-rate no-undo .
define variable v-base-scale                like ub.curr-accnt.exch-scale no-undo .
define variable v-exch-rate                 like ub.curr-accnt.exch-rate no-undo .
define variable v-exch-scale                like ub.curr-accnt.exch-scale no-undo .
define variable v-curr-abbr                 as character no-undo .
define variable v-attr-value                as character no-undo .
define variable v-attr-type                 as character no-undo .
define variable l-shift-on                  as logical no-undo init no.
define variable v-shift-date                like ub.shift-obj.shift-date no-undo.
define variable v-shift-num                 like ub.shift-obj.shift-num no-undo.
define variable v-shift-name                as   character no-undo.
define variable v-out-pay                   like ub.shop.out-pay no-undo .
define variable v-purch-code                like ub.trn-doc.purch-code no-undo .
define variable v-purch-name                as character no-undo .
define variable v-curr-code                 like ub.contract.curr-code no-undo .
define variable v-contract-code             like ub.trn-doc.contract-code no-undo .
define variable v-gds-code                  like ub.goods.gds-code  no-undo .
define variable v-mes                       as character no-undo .
define variable v-ps                        as character no-undo .
define variable v-discnt-type               as character no-undo .
define variable prev-doc-code               like ub.trn-doc.doc-code no-undo .
define variable v-num_rec-res-exist         as integer no-undo .
define variable v-current-doc-code          as character no-undo .
define buffer buf_bar-code for ub.bar-code.
define buffer buf_Clients for ub.clients.
define buffer buf_shop    for ub.shop.
define buffer buf_store for ub.store.
define buffer buf_contract for ub.contract.
define buffer buf_prop_trn-doc for ub.trn-doc.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_gds-dtl  for ub.gds-dtl.
define buffer bufi_gds-dtl  for ub.gds-dtl.
define buffer buf_tt0-gds-dtl for tt0-gds-dtl.
define buffer buf_sysconf for ub.sysconf.
define buffer buf_tt0-doc-line for tt0-doc-line.
define buffer prev_sale-doc for ub.sale-doc.
define buffer buf_sale-doc for ub.sale-doc.
define temp-table tt0-one-doc-line no-undo like lib-trn_ret-line.
define temp-table tt0-one-gds-dtl  no-undo like ub.gds-dtl.
define temp-table tt0-one-parts    no-undo like ub.parts.
_main:
do
on error undo, return error return-value :
  find first buf_clients no-lock where
            buf_clients.obj-type = p-obj-type
        AND buf_clients.obj-code = p-obj-code.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  p-host-code
  ,output v-base-code
  )  .
  _doc-line:
  for each tt0-doc-line where
          tt0-doc-line.doc-code = "":U,
      each tt0-gds-dtl where
          tt0-gds-dtl.obj-type = tt0-doc-line.obj-type
      AND tt0-gds-dtl.obj-code = tt0-doc-line.obj-code
      AND tt0-gds-dtl.prod-type = tt0-doc-line.prod-type
      AND tt0-gds-dtl.prod-code = tt0-doc-line.prod-code
      AND tt0-gds-dtl.artic     = tt0-doc-line.artic
      break
      by tt0-doc-line.obj-type
      by tt0-doc-line.obj-code
      :
    if p-artic = '':U
    or (tt0-doc-line.artic = p-artic
          and tt0-doc-line.prod-type = p-prod-type
          and tt0-doc-line.prod-code = p-prod-code)
          then do:
      run write-tt0-info in this-procedure (
                                            input tt0-doc-line.artic
                                          ,input tt0-doc-line.prod-type
                                          ,input tt0-doc-line.prod-code
                                          ,input tt0-gds-dtl.prt-code
                                          ,input tt0-doc-line.obj-type
                                          ,input tt0-doc-line.obj-code
                                          ,input tt0-doc-line.doc-code
                                          ,input yes
                                          ,input ?
                                          ,input ?
                                          ,input ?
                                          ,input ?
                                          ,input tt0-gds-dtl.doc-qnty
                                          ,input (if p-rz then (tt0-gds-dtl.doc-qnty - tt0-gds-dtl.fact-qnty)
                                                  else ( - tt0-gds-dtl.doc-qnty)
                                                  )
                                          ,input tt0-gds-dtl.doc-qnty
                                          ,input '':u).
      if p-num_rec_other modulo  10 = 0 then do:
        assign
        v-mes = substitute("&1 ЧУЖИХ товаров - обработано строк &2 успешно &3"
                                                              , p-title
                                                              , p-num_rec_other
                                                              , p-num_rec_other_res
                                                              ).
        if p-auto = 0 then
        run waitfram-show in this-procedure (input v-mes).
        else
        run write-counter in p-log-handle (input v-mes).
      end.
      assign
      p-num_rec_other = p-num_rec_other + 1 .
    end.
    if first-of(tt0-doc-line.obj-code) then do:
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  tt0-doc-line.obj-type
  ,input  tt0-doc-line.obj-code
  ,output v-prop-host-code
  )  .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-prop-host-code
  ,output v-prop-base-code
  )  .
      run get-alias-type-price-obj  in this-procedure (
                                                          input p-host-code
                                                          ,input p-obj-type
                                                          ,input p-obj-code
                                                          ,input v-prop-host-code
                                                          ,input tt0-doc-line.obj-type
                                                          ,input tt0-doc-line.obj-code
                                                          ,output v-ext-doc-type
                                                          ,output v-alias-type-price
                                                          ,output v-price-obj-type
                                                          ,output v-price-obj-code) no-error .
      if error-status:error then do:
        undo _main, return error substitute("Ошибка при получении типа цены и объекта цены для перемещения с &1&2 на &3&4:&5&6 &7"
                                , p-obj-type
                                , p-obj-code
                                , tt0-doc-line.obj-type
                                , tt0-doc-line.obj-code
                                , chr(10)
                                , error-status:get-message(1)
                                , return-value ).
      end.
      CASE tt0-doc-line.obj-type:
        when 'маг':U then do:
          find first buf_shop no-lock where
                    buf_shop.obj-code = tt0-doc-line.obj-code no-error .
          if not available buf_shop then
          undo _main, return error substitute("Не найден &1&2 (ОБЪЕКТ для перемещения ЧУЖИХ товаров для &2&3)"
                                    , tt0-doc-line.obj-type
                                    , tt0-doc-line.obj-code
                                    , p-obj-type
                                    , p-obj-code
                                    ).
          assign
          v-out-pay = buf_shop.out-pay.
        end.
        when 'скл':U then do:
          find first buf_store no-lock where
                    buf_store.obj-code = tt0-doc-line.obj-code no-error .
          if not available buf_store then
          undo _main, return error substitute("Не найден &1&2 (ОБЪЕКТ для перемещения ЧУЖИХ товаров для &2&3)"
                                    , tt0-doc-line.obj-type
                                    , tt0-doc-line.obj-code
                                    , p-obj-type
                                    , p-obj-code
                                    ).
          assign
          v-out-pay = buf_store.out-pay.
        end.
      END CASE.
      if p-host-code <> v-prop-host-code then do:
        find first buf_contract no-lock where
                  buf_contract.host-code = p-host-code
              AND buf_contract.cli-type = 'орг':U
              AND buf_contract.cli-code = v-prop-host-code
              AND buf_contract.status_ = 'тек':U
              AND buf_contract.contract-type = 'Продажи через ТПСИ':U no-error .
        if available buf_contract then do:
          run get-purch-contract in this-procedure (
                                                      input buf_contract.host-code
                                                     ,input buf_contract.contract-code
                                                     ,output v-purch-code
                                                     ,output v-purch-name) no-error .
          if error-status:error then do:
            undo _main, return error substitute("Ошибка при определении типа приобретения для документа межфирменного перемещения ЧУЖИХ товаров с &1&2:&3&4&5"
                                          , tt0-doc-line.obj-type
                                          , tt0-doc-line.obj-code
                                          , chr(10)
                                          , error-status:get-message(1)
                                          , return-value
                                          ).
          end.
          assign
          v-curr-code = buf_contract.curr-code
          v-contract-code = buf_contract.contract-code
          .
        end.
        else do:
          assign
          v-purch-code = integer('1':U)
          v-curr-code = 0
          v-contract-code = 0
          .
        end.
      end.
      else do:
        assign
        v-purch-code = integer('1':U)
        v-curr-code = v-base-code
        v-contract-code = 0
        .
      end.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  tt0-doc-line.obj-type
  ,input  tt0-doc-line.obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  ) no-error .
      if error-status:error then do:
        undo _main, return error substitute("Ошибка при определении параметра СМЕННАЯ РАБОТА на объекте для документа перемещения ЧУЖИХ товаров с &1&2:&3&4&5"
                                      , tt0-doc-line.obj-type
                                      , tt0-doc-line.obj-code
                                      , chr(10)
                                      , error-status:get-message(1)
                                      , return-value
                                      ).
      end.
      if l-shift-on then do:
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  tt0-doc-line.obj-type
  ,input  tt0-doc-line.obj-code
  ,output v-shift-date
  ,output v-shift-num
  ,output v-shift-name
  ) no-error .
        if error-status:error then do:
          undo _main, return error substitute("Ошибка при определении ДАТЫ И НОМЕРА СМЕНЫ на объекте для документа перемещения ЧУЖИХ товаров с &1&2:&3&4&5"
                                        , tt0-doc-line.obj-type
                                        , tt0-doc-line.obj-code
                                        , chr(10)
                                        , error-status:get-message(1)
                                        , return-value
                                        ).
        end.
      end.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  tt0-doc-line.obj-type
  ,input  tt0-doc-line.obj-code
  ,output v-sys-today
  ) no-error .
      if error-status:error then do:
        undo _main, return error substitute("Ошибка при определении даты на объекте для документа перемещения ЧУЖИХ товаров с &1&2:&3&4&5"
                                      , tt0-doc-line.obj-type
                                      , tt0-doc-line.obj-code
                                      , chr(10)
                                      , error-status:get-message(1)
                                      , return-value
                                      ).
      end.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  v-prop-host-code
  ,input  v-sys-today
  ,output v-base-rate
  ,output v-base-scale
  ) no-error .
      if error-status:error then do:
        undo _main, return error substitute("Ошибка при определении курса базовой валюты для документа перемещения ЧУЖИХ товаров с &1&2 на даут &3:&4&5&6"
                                      , tt0-doc-line.obj-type
                                      , tt0-doc-line.obj-code
                                      , string(v-sys-today, "99/99/9999")
                                      , chr(10)
                                      , error-status:get-message(1)
                                      , return-value
                                      ).
      end.
      if v-curr-code <> 0
      and v-curr-code <> v-base-code
      then do:
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  v-curr-code
  ,input  v-sys-today
  ,output v-exch-rate
  ,output v-exch-scale
  ,output v-curr-abbr
  ) no-error .
        if error-status:error then do:
          undo _main, return error substitute("Ошибка при определении курса валюты &1 для документа перемещения ЧУЖИХ товаров с &2&3 на дату &4:&5&6&7"
                                        , v-curr-code
                                        , tt0-doc-line.obj-type
                                        , tt0-doc-line.obj-code
                                        , string(v-sys-today, "99/99/9999")
                                        , chr(10)
                                        , error-status:get-message(1)
                                        , return-value
                                        ).
        end.
      end.
      else do:
        if v-curr-code = 0 then do:
          assign
          v-exch-rate = 1
          v-exch-scale = 1
          .
        end.
        else do:
          assign
          v-exch-rate = v-base-rate
          v-exch-scale = v-base-scale
          .
        end.
      end.
      find first buf_sale-doc where
                buf_sale-doc.inkas-code = p-inkas-code
            and buf_sale-doc.tpsidoc = yes
            and buf_sale-doc.host-code  = v-prop-host-code
            and buf_sale-doc.obj-type   = tt0-gds-dtl.obj-type
            and buf_sale-doc.obj-code   = tt0-gds-dtl.obj-code no-error.
      if available buf_sale-doc then do:
        find first ub.sale-doc where recid(ub.sale-doc) = recid(buf_sale-doc).
        find first buf_prop_trn-doc where
                  buf_prop_trn-doc.doc-code = buf_sale-doc.doc-code no-error .
        if not available buf_prop_trn-doc then do:
          delete buf_sale-doc.
        end.
      end.
      if not available buf_prop_trn-doc then  do:
        run doc-code in this-procedure
         (input "main",
          input tt0-doc-line.obj-type,
          input tt0-doc-line.obj-code,
          input ?,
          output v-doc-code ) no-error.
        if error-status:error then do:
          undo _main, return error substitute("Ошибка при генерации номера документа перемещения ЧУЖИХ товаров с &1&2:&3&4&5"
                                        , tt0-doc-line.obj-type
                                        , tt0-doc-line.obj-code
                                        , chr(10)
                                        , error-status:get-message(1)
                                        , return-value
                                        ).
        end.
        assign
        v-ps =  '':U
        v-discnt-type = (if v-alias-type-price = '5':U then 'строка':U else 'процент':U)
        .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crtrndoc in g#lib-trn
(input ?
,input ?
,input v-base-rate
,input v-base-scale
,input (if tt0-doc-line.ext-doc-type = 'ee':U then p-host-code else p-obj-code)
,input (if tt0-doc-line.ext-doc-type = 'ee':U then 'орг':U else p-obj-type)
,input buf_clients.obj-name
,input g#db-num
,input g#userid
,input v-discnt-type
,input v-doc-code
,input v-sys-today
,input 'рас':U
,input no
,input v-prop-host-code
,input (if v-prop-host-code = p-host-code then yes else no)
,input tt0-doc-line.obj-code
,input tt0-doc-line.obj-type
,input no
,input v-out-pay
,input v-ps
,input no
,input 'без':U
,input 'нередакт':U
,input 'в т. ч.':U
,input tt0-doc-line.ext-doc-type
,input v-purch-code
) no-error
.
        if error-status:error then do:
          undo _main, return error substitute("Ошибка при создании документа перемещения ЧУЖИХ товаров с &1&2:&3&4&5"
                                        , tt0-doc-line.obj-type
                                        , tt0-doc-line.obj-code
                                        , chr(10)
                                        , error-status:get-message(1)
                                        , return-value
                                        ).
        end.
        find first buf_prop_trn-doc where
                  buf_prop_trn-doc.doc-code = v-doc-code no-error .
        if error-status:error then do:
          undo _main, return error substitute("Ошибка при создании документа перемещения ЧУЖИХ товаров с &1&2:&3&4&5"
                                        , tt0-doc-line.obj-type
                                        , tt0-doc-line.obj-code
                                        , chr(10)
                                        , error-status:get-message(1)
                                        , return-value
                                        ).
        end.
        assign
        buf_prop_trn-doc.exch-code = v-curr-code
        buf_prop_trn-doc.exch-rate = v-exch-rate
        buf_prop_trn-doc.exch-scale = v-exch-scale
        buf_prop_trn-doc.shift-date = if l-shift-on then v-shift-date else ?
        buf_prop_trn-doc.shift-num = if l-shift-on then v-shift-num else 0
        buf_prop_trn-doc.shift-name = if l-shift-on then v-shift-name else ""
        buf_prop_trn-doc.out-code  = buf_trn-doc.doc-code
        .
        if v-prop-host-code <> p-host-code then
        assign
        buf_prop_trn-doc.hold-obj-type = p-obj-type
        buf_prop_trn-doc.hold-obj-code = p-obj-code
        buf_prop_trn-doc.hold-doc-code-child  = "hold":u
        buf_prop_trn-doc.hold-doc-code-parent = "hold":u.
        buf_prop_trn-doc.contract-code = v-contract-code
        .
        run saledoc-create  in this-procedure (
                                                 input p-inkas-code
                                                ,input p-host-code
                                                ,input p-obj-type
                                                ,input p-obj-code
                                                ,input entry(lookup(buf_prop_trn-doc.ext-doc-type, 'ee,ev,ie,es,iv':U), 'tpsi-hold-expense,tpsi-internal-expense,tpsi-hold-income,tpsi-internal-income':U)
                                                ,input buf_prop_trn-doc.office
                                                ,input yes
                                                ,input v-alias-type-price
                                                ,input v-price-obj-type
                                                ,input v-price-obj-code
                                                ,buffer buf_prop_trn-doc ) no-error .
        if error-status:error then do:
          undo _main, return error substitute("Ошибка записи данных автодокумента вида &5 для продажи &4 в таблицу связанных документов по продажу:&1&2 &3"
                                        , chr(10)
                                        , error-status:get-message(1)
                                        , return-value
                                        , p-inkas-code
                                        , entry(lookup(buf_prop_trn-doc.ext-doc-type, 'ee,ev,ie,es,iv':U), 'tpsi-hold-expense,tpsi-internal-expense,tpsi-hold-income,tpsi-internal-income':U)
                                        ).
        end.
      end.
      assign
      v-current-doc-code = buf_prop_trn-doc.doc-code
      .
    end.
    if p-artic = '':U
    or (tt0-doc-line.artic = p-artic
          and tt0-doc-line.prod-type = p-prod-type
          and tt0-doc-line.prod-code = p-prod-code)
          then do:
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  tt0-doc-line.artic
  ,input  tt0-doc-line.prod-type
  ,input  tt0-doc-line.prod-code
  ,output v-gds-code
  )  .
      CASE sale-doc.alias-type-price:
        when '1':U  then do:
          assign
          tt0-gds-dtl.price-rubl = 0
          tt0-gds-dtl.price-base = 0
          tt0-doc-line.road-tax  = 0
          tt0-doc-line.excise    = 0
          tt0-gds-dtl.doc-code   = v-current-doc-code
          tt0-doc-line.doc-code  = v-current-doc-code
          .
        end.
        when '5':U  then do:
          assign
          tt0-gds-dtl.ov         = yes
          tt0-gds-dtl.doc-code   = v-current-doc-code
          tt0-doc-line.doc-code  = v-current-doc-code
          .
        end.
        otherwise do:
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
gp-fact-order = 0 .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  v-gds-code
  ,input  tt0-gds-dtl.prt-code
  ,output gp-b-code
  ) no-error .
if error-status:error then do:
  message
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  run write-tt0-info in this-procedure (                                                                                                              input tt0-doc-line.artic                                                                                    ,input tt0-doc-line.prod-type                                                                                 ,input tt0-doc-line.prod-code                                                                                 ,input tt0-gds-dtl.prt-code                                                                                   ,input tt0-doc-line.obj-type                                                                                  ,input tt0-doc-line.obj-code                                                                                  ,input tt0-doc-line.doc-code                                                                                  ,input yes                                                                                                    ,input ?                                                                                                      ,input ?                                                                                                      ,input ?                                                                                                      ,input ?                                                                                                      ,input tt0-gds-dtl.doc-qnty                                                                                   ,input (tt0-gds-dtl.doc-qnty - tt0-gds-dtl.fact-qnty)                                                         ,input tt0-gds-dtl.doc-qnty                                                                                   ,input substitute('товар &1: ошибка при определении цены товара на объекте &2&3:&4&5 &6', V-gds-code, v-price-obj-type, v-price-obj-code,  chr(10), error-status:get-message(1), return-value )).           next _doc-line.
end.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  v-price-obj-type
  ,input  v-price-obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  run write-tt0-info in this-procedure (                                                                                                              input tt0-doc-line.artic                                                                                    ,input tt0-doc-line.prod-type                                                                                 ,input tt0-doc-line.prod-code                                                                                 ,input tt0-gds-dtl.prt-code                                                                                   ,input tt0-doc-line.obj-type                                                                                  ,input tt0-doc-line.obj-code                                                                                  ,input tt0-doc-line.doc-code                                                                                  ,input yes                                                                                                    ,input ?                                                                                                      ,input ?                                                                                                      ,input ?                                                                                                      ,input ?                                                                                                      ,input tt0-gds-dtl.doc-qnty                                                                                   ,input (tt0-gds-dtl.doc-qnty - tt0-gds-dtl.fact-qnty)                                                         ,input tt0-gds-dtl.doc-qnty                                                                                   ,input substitute('товар &1: ошибка при определении цены товара на объекте &2&3:&4&5 &6', V-gds-code, v-price-obj-type, v-price-obj-code,  chr(10), error-status:get-message(1), return-value )).           next _doc-line.
end.
gp-price-sale-parts = gp-price-sale.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_avprpart in g#lib-trn3
  (input  v-price-obj-type
  ,input  v-price-obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale-parts
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  run write-tt0-info in this-procedure (                                                                                                              input tt0-doc-line.artic                                                                                    ,input tt0-doc-line.prod-type                                                                                 ,input tt0-doc-line.prod-code                                                                                 ,input tt0-gds-dtl.prt-code                                                                                   ,input tt0-doc-line.obj-type                                                                                  ,input tt0-doc-line.obj-code                                                                                  ,input tt0-doc-line.doc-code                                                                                  ,input yes                                                                                                    ,input ?                                                                                                      ,input ?                                                                                                      ,input ?                                                                                                      ,input ?                                                                                                      ,input tt0-gds-dtl.doc-qnty                                                                                   ,input (tt0-gds-dtl.doc-qnty - tt0-gds-dtl.fact-qnty)                                                         ,input tt0-gds-dtl.doc-qnty                                                                                   ,input substitute('товар &1: ошибка при определении цены товара на объекте &2&3:&4&5 &6', V-gds-code, v-price-obj-type, v-price-obj-code,  chr(10), error-status:get-message(1), return-value )).           next _doc-line.
end.
if gp-price-sale-parts <> 0 and gp-price-sale-parts <> ? then do:
    gp-price-sale = gp-price-sale-parts.
 end.
          assign
          tt0-gds-dtl.price-rubl = (if v-curr-r-b = 'rubl':U
                                    then gp-price-sale
                                    else gp-price-sale * v-base-rate / v-base-scale)
          tt0-gds-dtl.price-base = (if v-curr-r-b = 'base':U
                                    then gp-price-sale
                                    else gp-price-sale / (v-base-rate / v-base-scale))
          tt0-doc-line.road-tax    = gp-road-tax
          tt0-doc-line.excise      = gp-excise
          tt0-gds-dtl.doc-code   = v-current-doc-code
          tt0-doc-line.doc-code  = v-current-doc-code
          tt0-gds-dtl.ov         = yes
          .
        end.
      END CASE.
    end.
  end.
  define variable v-rsrv-fact-qnty                      as logical no-undo init yes.
  define variable v-all-qnty                            as logical no-undo .
  define variable v-fix-price                           as logical no-undo init yes .
  define variable v-use-parts                           as logical no-undo .
  _tpsi-doc:
  for each ub.sale-doc no-lock where
           ub.sale-doc.inkas-code = p-inkas-code
       and ub.sale-doc.tpsidoc = yes,
      first buf_prop_trn-doc where
            buf_prop_trn-doc.doc-code = ub.sale-doc.doc-code,
      first buf_sysconf no-lock where
           buf_sysconf.host-code = ub.sale-doc.host-code :
    if p-artic <> "":U then do:
      find first buf_tt0-doc-line no-lock where
                (buf_tt0-doc-line.doc-code = sale-doc.doc-code
           AND  buf_tt0-doc-line.artic = p-artic
           AND  buf_tt0-doc-line.prod-type = p-prod-type
           AND  buf_tt0-doc-line.prod-code = p-prod-code)
        or     (buf_tt0-doc-line.obj-type = sale-doc.obj-type
           and  buf_tt0-doc-line.obj-code = sale-doc.obj-code
           AND  buf_tt0-doc-line.artic = p-artic
           AND  buf_tt0-doc-line.prod-type = p-prod-type
           AND  buf_tt0-doc-line.prod-code = p-prod-code)
              no-error .
      if not available buf_tt0-doc-line then NEXT _tpsi-doc.
    end.
    assign
    buf_prop_trn-doc.status_ = 'накл':U
    buf_prop_trn-doc.flag_  = no
    .
    if p-artic = '':U then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_copy-ret in g#lib-trn
  (
    input parparentproc
  , input sale-doc.doc-code
  , input buf_trn-doc.doc-type
  , input buf_trn-doc.status_
  , input buf_trn-doc.internal
  , input buf_trn-doc.cli-type
  , input buf_trn-doc.cli-code
  , input buf_trn-doc.discnt-type
  , input buf_trn-doc.tot-calc
  , input buf_trn-doc.discnt-pc
  , input buf_trn-doc.agnt
  , input buf_trn-doc.boss
  , input buf_trn-doc.wrkr
  , input buf_trn-doc.base-rate
  , input buf_trn-doc.base-scale
  , input buf_trn-doc.exch-code
  , input buf_trn-doc.vat-type
  , input buf_prop_trn-doc.doc-code
  , input no
  , input buf_prop_trn-doc.discnt-pc
  , input buf_prop_trn-doc.agnt
  , input buf_prop_trn-doc.boss
  , input buf_prop_trn-doc.wrkr
  , input buf_prop_trn-doc.base-rate
  , input buf_prop_trn-doc.base-scale
  , input buf_sysconf.cash-pay
  , input buf_sysconf.base-code
  , input-output table tt0-doc-line
  , input-output table tt0-gds-dtl
  , input-output table tt0-parts
  , input v-use-parts
  , input v-all-qnty
  , input v-fix-price
  , input v-rsrv-fact-qnty
  ) no-error.
    end.
    else do:
      for each tt0-one-doc-line:
        delete tt0-one-doc-line.
      end.
      for each tt0-one-gds-dtl:
        delete tt0-one-gds-dtl.
      end.
      for each tt0-one-parts:
        delete tt0-one-parts.
      end.
      for each tt0-gds-dtl where
             tt0-gds-dtl.artic = p-artic
         and tt0-gds-dtl.prod-type = tt0-gds-dtl.prod-type
         and tt0-gds-dtl.prod-code = tt0-gds-dtl.prod-code
         and tt0-gds-dtl.prt-code = tt0-gds-dtl.prt-code:
         create tt0-one-gds-dtl.
         buffer-copy tt0-gds-dtl to tt0-one-gds-dtl.
         leave.
      end.
      for each tt0-doc-line where
             tt0-doc-line.artic = p-artic
         and tt0-doc-line.prod-type = tt0-doc-line.prod-type
         and tt0-doc-line.prod-code = tt0-doc-line.prod-code:
         create tt0-one-doc-line.
         buffer-copy tt0-doc-line
         except doc-qnty fact-qnty cli-qnty
         to tt0-one-doc-line.
         buffer-copy tt0-gds-dtl using  doc-qnty fact-qnty
         to tt0-one-doc-line.
      end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_copy-ret in g#lib-trn
  (
    input parparentproc
  , input sale-doc.doc-code
  , input buf_trn-doc.doc-type
  , input buf_trn-doc.status_
  , input buf_trn-doc.internal
  , input buf_trn-doc.cli-type
  , input buf_trn-doc.cli-code
  , input buf_trn-doc.discnt-type
  , input buf_trn-doc.tot-calc
  , input buf_trn-doc.discnt-pc
  , input buf_trn-doc.agnt
  , input buf_trn-doc.boss
  , input buf_trn-doc.wrkr
  , input buf_trn-doc.base-rate
  , input buf_trn-doc.base-scale
  , input buf_trn-doc.exch-code
  , input buf_trn-doc.vat-type
  , input buf_prop_trn-doc.doc-code
  , input no
  , input buf_prop_trn-doc.discnt-pc
  , input buf_prop_trn-doc.agnt
  , input buf_prop_trn-doc.boss
  , input buf_prop_trn-doc.wrkr
  , input buf_prop_trn-doc.base-rate
  , input buf_prop_trn-doc.base-scale
  , input buf_sysconf.cash-pay
  , input buf_sysconf.base-code
  , input-output table tt0-one-doc-line
  , input-output table tt0-one-gds-dtl
  , input-output table tt0-one-parts
  , input v-use-parts
  , input v-all-qnty
  , input v-fix-price
  , input v-rsrv-fact-qnty
  ) no-error.
      for each tt0-one-doc-line,
         first tt0-doc-line where
              tt0-doc-line.artic = tt0-one-doc-line.artic
          and tt0-doc-line.prod-type = tt0-one-doc-line.prod-type
          and tt0-doc-line.prod-code = tt0-one-doc-line.prod-code:
         buffer-copy tt0-one-doc-line
         except doc-qnty fact-qnty cli-qnty
         to tt0-doc-line.
         assign
         tt0-doc-line.doc-qnty = tt0-doc-line.doc-qnty - tt0-gds-dtl.doc-qnty + tt0-one-doc-line.doc-qnty
         tt0-doc-line.fact-qnty = tt0-doc-line.fact-qnty - tt0-gds-dtl.fact-qnty + tt0-one-doc-line.doc-qnty
         .
      end.
      for each tt0-one-gds-dtl,
         first tt0-gds-dtl where
              tt0-gds-dtl.artic = tt0-one-gds-dtl.artic
          and tt0-gds-dtl.prod-type = tt0-one-gds-dtl.prod-type
          and tt0-gds-dtl.prt-code = tt0-one-gds-dtl.prt-code:
        buffer-copy
        tt0-one-gds-dtl using doc-qnty fact-qnty
        to tt0-gds-dtl.
      end.
    end.
    if error-status:error then do:
      for each tt0-info no-lock where
              tt0-info.doc-code = '':U,
          first buf_tt0-doc-line  where
                buf_tt0-doc-line.doc-code = sale-doc.doc-code
            and buf_tt0-doc-line.artic = tt0-info.artic
            and buf_tt0-doc-line.prod-type = tt0-info.prod-type
            and buf_tt0-doc-line.prod-code = tt0-info.prod-code
      break
      by tt0-info.artic
      by tt0-info.prod-type
      by tt0-info.prod-code:
        if first-of (tt0-info.prod-code) then do:
          if p-artic <> ""
          and not (tt0-info.artic = p-artic
              and tt0-info.prod-type = p-prod-type
              and tt0-info.prod-code = p-prod-code )
          then next.
          assign
          buf_tt0-doc-line.doc-code = ''.
        end.
      end.
      for each tt0-info where
              tt0-info.doc-code = '':U,
          first tt0-gds-dtl  where
                tt0-gds-dtl.doc-code = sale-doc.doc-code
            and tt0-gds-dtl.artic = tt0-info.artic
            and tt0-gds-dtl.prod-type = tt0-info.prod-type
            and tt0-gds-dtl.prod-code = tt0-info.prod-code
            and tt0-gds-dtl.prt-code  = tt0-info.prt-code
      break
      by tt0-info.artic
      by tt0-info.prod-type
      by tt0-info.prod-code:
        if p-artic = ""
        or (tt0-gds-dtl.artic = p-artic
            and tt0-gds-dtl.prod-type = p-prod-type
            and tt0-gds-dtl.prod-code = p-prod-code
            and tt0-gds-dtl.prt-code = p-prt-code ) then do:
          assign
          tt0-gds-dtl.doc-code = ''
          tt0-info.error-message =  substitute("Ошибка при копировании линий в документ перемещения ЧУЖИХ товаров с &1&2:&3&4&5"
                                      , sale-doc.obj-type
                                      , sale-doc.obj-code
                                      , chr(10)
                                      , error-status:get-message(1)
                                      , return-value)
          .
        end.
      end.
      if p-artic <> "":U then
      undo _tpsi-doc, return error substitute("Ошибка при копировании линий в документ перемещения ЧУЖИХ товаров с &1&2:&3&4&5"
                                    , sale-doc.obj-type
                                    , sale-doc.obj-code
                                    , chr(10)
                                    , error-status:get-message(1)
                                    , return-value
                                    ).
      else do:
        undo _tpsi-doc, NEXT _tpsi-doc.
      end.
    end.
    assign
    buf_prop_trn-doc.status_ = 'нередакт':U
    buf_prop_trn-doc.flag_  = no
    .
    case sale-doc.alias-type-price :
      when '1':U  then do:
        for each buf_doc-line no-lock where
                buf_doc-line.doc-code = buf_prop_trn-doc.doc-code,
            each buf_gds-dtl WHERE
                buf_gds-dtl.doc-code = buf_prop_trn-doc.doc-code
            AND buf_gds-dtl.doc-code = buf_prop_trn-doc.doc-code:
        if p-artic <> '':u
        and not (buf_gds-dtl.artic = p-artic
            and buf_gds-dtl.prod-type = p-prod-type
            and buf_gds-dtl.prod-code = p-prod-code
            and buf_gds-dtl.prt-code = p-prt-code )
        then next.
        assign
        buf_gds-dtl.price-base       = buf_doc-line.price-base
        buf_gds-dtl.price-rubl       = buf_doc-line.price-rubl
        .
        END.
      end.
      when '5':U then do:
        for each buf_gds-dtl where
                buf_gds-dtl.doc-code = buf_prop_trn-doc.doc-code,
            first bufi_gds-dtl WHERE
                bufi_gds-dtl.doc-code = buf_trn-doc.doc-code
            AND bufi_gds-dtl.artic = buf_gds-dtl.artic
            AND bufi_gds-dtl.prod-type = buf_gds-dtl.prod-type
            AND bufi_gds-dtl.prod-code = buf_gds-dtl.prod-code
            AND bufi_gds-dtl.prt-code = buf_gds-dtl.prt-code :
          if p-artic <> '':u
          and not (buf_gds-dtl.artic = p-artic
              and buf_gds-dtl.prod-type = p-prod-type
              and buf_gds-dtl.prod-code = p-prod-code
              and buf_gds-dtl.prt-code = p-prt-code )
          then next.
          assign
          buf_gds-dtl.price-base  = bufi_gds-dtl.price-base
          buf_gds-dtl.price-rubl  = bufi_gds-dtl.price-rubl
          buf_gds-dtl.discnt-base = bufi_gds-dtl.discnt-base
          buf_gds-dtl.discnt-rubl = bufi_gds-dtl.discnt-rubl
          buf_gds-dtl.discnt-type = no
          buf_gds-dtl.discnt-pc   = buf_gds-dtl.discnt-rubl * 100 / buf_gds-dtl.price-rubl
          .
        END.
      end.
    END CASE.
    run gbl/calc-trn.p (input parparentproc, input recid(buf_prop_trn-doc)) no-error .
    if error-status:error then do:
      undo _tpsi-doc, return error substitute("Ошибка при расчете шапки документа перемещения ЧУЖИХ товаров с &1&2:&3&4&5"
                                    , sale-doc.obj-type
                                    , sale-doc.obj-code
                                    , chr(10)
                                    , error-status:get-message(1)
                                    , return-value
                                    ).
    end.
  end.
  prev-doc-code = '':U.
  for each  sale-doc where
          sale-doc.inkas-code = p-inkas-code:
    assign
    sale-doc.tot-dtl = 0
    .
    for each tt0-gds-dtl no-lock where
        tt0-gds-dtl.doc-code = sale-doc.doc-code:
      sale-doc.tot-dtl = sale-doc.tot-dtl + 1.
      if tt0-gds-dtl.fact-qnty = 0 then do:
        find first tt0-info where
            tt0-info.artic = tt0-gds-dtl.artic
        and tt0-info.prod-type = tt0-gds-dtl.prod-type
        and tt0-info.prod-code = tt0-gds-dtl.prod-code
        and tt0-info.prt-code = tt0-gds-dtl.prt-code no-error .
      end.
      else do:
        if available tt0-info then release tt0-info.
      end.
      if tt0-gds-dtl.fact-qnty = 0
      and (available tt0-info and tt0-info.o-was-res <> tt0-gds-dtl.doc-qnty)
      then do:
        if p-artic = "":U
        or (tt0-gds-dtl.artic = p-artic
          and
          tt0-gds-dtl.prod-type = p-prod-type
          AND
          tt0-gds-dtl.prod-code = p-prod-code
          AND
          tt0-gds-dtl.prt-code = p-prt-code
          )
        then
        assign
        p-num_rec_other_res = p-num_rec_other_res + 1
        p-num_rec_res = p-num_rec_res + 1
        .
      end.
    end.
    find first buf_prop_trn-doc where
           buf_prop_trn-doc.doc-code = sale-doc.doc-code.
    find first prev_sale-doc where prev_sale-doc.doc-code = sale-doc.doc-code.
    assign
    buf_prop_trn-doc.ps = set-tpsi-doc-ps(buffer prev_sale-doc)
    prev_sale-doc.ps = buf_prop_trn-doc.ps
    .
  end.
  if p-auto = 0 then
  run waitfram-hide in this-procedure .
  else
  run hide-counter in p-log-handle.
end.
procedure get-purch-contract :
define input parameter p-host-code              like ub.sysconf.host-code no-undo .
define input parameter p-contract-code          like ub.contract.contract-code no-undo .
define output parameter p-purch-code            like ub.trn-doc.purch-code no-undo .
define output parameter p-purch-name            as character no-undo .
define buffer bf_contract for ub.contract.
do on error undo, return error return-value :
  find first bf_contract where bf_contract.host-code     = p-host-code     and
                               bf_contract.contract-code = p-contract-code no-lock.
  if lookup (bf_contract.contract-type, 'Купли-продажи,Агентский договор,Давальческого сырья,Продажи через ТПСИ':U) > 0 then do:
        assign
      p-purch-name = entry (lookup ('1':U, '1,2,3,4':U), 'выкуп,консигнация,ответственное хранение,старая консигнация':U).
  end.
  else do:
    if lookup (bf_contract.contract-type, 'Консигнации':U) > 0 then do:
            assign
        p-purch-name = entry (lookup ('2':U, '1,2,3,4':U), 'выкуп,консигнация,ответственное хранение,старая консигнация':U).
    end.
    else do:
      if lookup (bf_contract.contract-type, 'Ответственного хранения':U) > 0 then do:
                assign
          p-purch-name = entry (lookup ('3':U, '1,2,3,4':U), 'выкуп,консигнация,ответственное хранение,старая консигнация':U).
      end.
      else do:
        return error substitute("Нельзя определить по договору &1 (фирма &2) с типом &3 тип приобретения"
                                , bf_contract.contract-prn-code
                                , p-host-code
                                , bf_contract.contract-type ).
      end.
    end.
  end.
  assign
  p-purch-code = lookup (p-purch-name, 'выкуп,консигнация,ответственное хранение,старая консигнация':U).
end.
end procedure.
