block-level on error undo, throw.
define input parameter parparentproc     as widget-handle no-undo .
define input-output parameter p-rid      as recid no-undo.
define input parameter p-mode            as character no-undo .
define input parameter p-callpoint       as character no-undo .
define input parameter p-silent          as logical no-undo .
define input parameter p-firm-code       like  ub.firm.firm-code      no-undo .
define input parameter p-stts            like  ub.clients.stts         no-undo .
define input parameter p-obj-name        like  ub.clients.obj-name     no-undo .
define input parameter p-lim-kr          like  ub.clients.lim-kr       no-undo .
define input parameter p-PS              like  ub.clients.PS           no-undo .
define input parameter p-grp-code        like  ub.clients.grp-code     no-undo .
define input parameter p-addres1         like  ub.firm.addres1         no-undo .
define input parameter p-addres2         like  ub.firm.addres2         no-undo .
define input parameter p-city            like  ub.firm.city            no-undo .
define input parameter p-contact-psn     like  ub.firm.contact-psn     no-undo .
define input parameter p-director        like  ub.firm.director        no-undo .
define input parameter p-e-mail          like  ub.firm.e-mail          no-undo .
define input parameter p-engl-name       like  ub.firm.engl-name       no-undo .
define input parameter p-fax             like  ub.firm.fax             no-undo .
define input parameter p-given-by        like  ub.firm.given-by        no-undo .
define input parameter p-ind             like  ub.firm.ind             no-undo .
define input parameter p-inn             like  ub.firm.inn             no-undo .
define input parameter p-no-check-inn    as logical                    no-undo .
define input parameter p-is-pboul        like  ub.firm.is-pboul        no-undo .
define input parameter p-kpp             like  ub.firm.kpp             no-undo .
define input parameter p-okonh           like  ub.firm.okonh           no-undo .
define input parameter p-okpo            like  ub.firm.okpo            no-undo .
define input parameter p-passp-num       like  ub.firm.passp-num       no-undo .
define input parameter p-passp-ser       like  ub.firm.passp-ser       no-undo .
define input parameter p-phone           like  ub.firm.phone           no-undo .
define input parameter p-phone1-note     like  ub.firm.phone1-note     no-undo .
define input parameter p-post-addr1      like  ub.firm.post-addr1      no-undo .
define input parameter p-post-addr2      like  ub.firm.post-addr2      no-undo .
define input parameter p-post-city       like  ub.firm.post-city       no-undo .
define input parameter p-post-ind        like  ub.firm.post-ind        no-undo .
define input parameter p-reg-code        like  ub.clients.reg-code     no-undo .
define input parameter p-telex           like  ub.firm.telex           no-undo .
define input parameter p-tobj-code       like  ub.firm.tobj-code       no-undo .
define input parameter p-turnover-buyer      like ub.clients.turnover-buyer       no-undo .
define input parameter p-turnover-buyer-gds  like ub.clients.turnover-buyer-gds   no-undo .
define variable vss-revision    as character no-undo init "$Revision: d47c064bc860, 1107, rls $":U .
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:13:53 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: firm1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/firm1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке организации".
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
FUNCTION calc-range RETURNS LOGICAL(
                                     input  my-db-num as integer
                                    ,input  my-code-src as integer
                                    ,input p-range-type as character
                                    ):
define variable mycode as integer no-undo .
mycode = abs(my-code-src).
if mycode = 0 then return no.
define buffer buf_code-range for ub.code-range.
find first  buf_code-range no-lock where
        buf_code-range.db-num = my-db-num
    and buf_code-range.range-type = p-range-type
    and buf_code-range.stts = 'u'
    and buf_code-range.first-code <= mycode
    and buf_code-range.last-code >= mycode no-error .
if available buf_code-range then return yes.
find first buf_code-range no-lock where
        buf_code-range.db-num = my-db-num
    and buf_code-range.range-type = p-range-type
    and buf_code-range.stts = 'a':U
    and buf_code-range.first-code <= mycode no-error .
if p-range-type = 'fmgb':U
and available buf_code-range
and (buf_code-range.stts = 'u'
    or
    mycode <  current-value(s-fmgb-code, ub)) then return yes.
if p-range-type = 'pngb':U
and available buf_code-range
and (buf_code-range.stts = 'u'
    or
    mycode <  current-value(s-pngb-code, ub)) then return yes.
if my-code-src < 0 then do:
  find first buf_code-range no-lock where
          buf_code-range.db-num = my-db-num
      and buf_code-range.range-type = p-range-type
      and buf_code-range.stts = 'f':U
      and buf_code-range.first-code <= mycode
      and buf_code-range.last-code >= mycode  no-error .
  if available buf_code-range then return yes.
end.
  find first buf_code-range no-lock where
          buf_code-range.db-num = my-db-num
      and buf_code-range.range-type = p-range-type
      and buf_code-range.first-code <= mycode
      and buf_code-range.last-code >= mycode  no-error .
if available buf_code-range then return no.
return ?.
END FUNCTION.
define variable v-db-num like ub.db.db-num no-undo .
define variable v-correct-inn as logical no-undo .
define buffer buf_cli-grp for ub.cli-grp.
define variable v-err-mess as character no-undo .
define variable v-is-correct as logical no-undo .
define variable v-type        as character no-undo .
define variable v-issue-host-code like ub.sysconf.host-code no-undo .
define variable v-inn-uniq-error as logical no-undo .
define variable v-new-inn like ub.firm.inn no-undo .
define variable v-import as logical no-undo .
define buffer buf_dis-card for ub.dis-card.
define buffer buf_clients for ub.clients.
define buffer buf_firm for ub.firm.
define buffer buf_regions for ub.regions.
def var vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-b-code :
  define input  parameter type-code like ub.code-range.range-type no-undo .
  define output parameter p-b-code  like ub.bar-code.b-code       no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-b-code). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (gen-b-code). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-b-code). endkey", vss-workfile )
  :
    define buffer buf_thbj-attr     for ub.thbj-attr .
    define buffer buf_sys-ctrl   for ub.sys-ctrl .
    define buffer buf_code-range for ub.code-range .
    define variable l-code         as   integer              no-undo .
    define variable v-db-num       like ub.db.db-num         no-undo .
    define variable cfg-param-code like ub.thbj-attr.prop-code no-undo .
    if type-code = 'sslc':U
    or type-code = 'ssgb':U
    then do:
      message
        "Нельзя генерировать локальный или глобальный взвешиваемый код." skip
        "Обратитесь к администратору системы."
        view-as alert-box error .
      undo, return error (if type-code = 'sslc':U then "loc-ss-code":U else "gbl-ss-code" ) .
    end.
    run trg/getpcode.p ( input  type-code
                   ,output cfg-param-code
                  ).
    run get-next-seq( input  type-code,
                      output l-code
                    ).
    find first buf_sys-ctrl no-lock.
    if type-code = 'sclc':U
    or type-code = 'pglc':U
    then do:
      assign
        v-db-num = 0
      .
    end.
    else do:
      assign
        v-db-num = buf_sys-ctrl.db-num
      .
    end.
    find first buf_code-range no-lock
      where buf_code-range.db-num     = v-db-num
        and buf_code-range.range-type = type-code
        and buf_code-range.stts       = "a"
      use-index stts
      no-error .
    if available buf_code-range
       and l-code <= buf_code-range.last-code
       and l-code >= buf_code-range.first-code then do:
      assign
        p-b-code = l-code
      .
    end.
    else do:
      if available buf_code-range
         and l-code < buf_code-range.last-code then do:
        message
          substitute( "Последовательность для создания кодов с типом &1 имеет неверное значение.", type-code ) skip
          "Обратитесь к администратору системы."
          view-as alert-box error .
        undo, return error "sequence":U .
      end.
      do transaction
      on error undo, return error
      :
        find first buf_thbj-attr exclusive-lock
          where buf_thbj-attr.upper-prop-code = 'code-range':U
            and buf_thbj-attr.prop-code = cfg-param-code
            and buf_thbj-attr.obj-type   = 'БД':U
            and buf_thbj-attr.obj-code   = v-db-num
          no-error .
        if not available buf_thbj-attr then do:
          find first buf_thbj-attr exclusive-lock
            where buf_thbj-attr.upper-prop-code = 'code-range':U
              and buf_thbj-attr.prop-code = cfg-param-code
              and buf_thbj-attr.obj-type   = ''
              and buf_thbj-attr.obj-code   = 0
            no-error .
          if not available buf_thbj-attr then do:
            if not locked buf_thbj-attr then do:
              message
                substitute( "Отсутствует параметр 'длина диапазона кодов' (&1) для БД &2.", cfg-param-code, buf_sys-ctrl.db-num ) skip
                "Обратитесь к администратору системы."
                view-as alert-box error .
            end.
            undo, return error "config":U .
          end.
        end.
        run get-next-seq( input type-code,
                          output l-code
                        ).
        find first buf_code-range
          where buf_code-range.db-num     = v-db-num
            and buf_code-range.range-type = type-code
            and buf_code-range.stts       = "a"
          use-index stts
          no-error .
        if available buf_code-range
        and l-code <= buf_code-range.last-code
        and l-code >= buf_code-range.first-code
        then do:
          assign
            p-b-code = l-code
          .
        end.
        else do:
          if available buf_code-range then do:
            assign
              buf_code-range.stts = "u"
            .
          end.
          find first buf_code-range
            where buf_code-range.db-num     = v-db-num
              and buf_code-range.range-type = type-code
              and buf_code-range.stts       = "f"
            use-index stts
            no-error .
          if not available buf_code-range then do:
            message
              substitute( "Отсутствует свободный диапазон для кодов с типом &1.", type-code ) skip
              "Обратитесь к администратору системы"
              view-as alert-box error .
            undo, return error "code-range":U .
          end.
          assign
            buf_code-range.stts           = "a"
          .
          if buf_code-range.first-code = 1 then do:
            run set-seq-cr( input type-code,
                            input buf_code-range.first-code
                          ).
            assign
              p-b-code = 1
            .
          end.
          else do:
            run set-seq-cr( input type-code,
                            input ( buf_code-range.first-code - 1 )
                          ).
            run get-next-seq( input type-code,
                              output p-b-code
                            ).
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure get-next-seq :
  define input  parameter type-code like ub.code-range.range-type no-undo .
  define output parameter next-seq  as   integer                  no-undo .
  do
  on error  undo, return error substitute( "&1 (get-next-seq). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (get-next-seq). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (get-next-seq). endkey", vss-workfile )
  :
    case type-code:
      when 'bcgb':U then do:
        assign
          next-seq = next-value(s-bcgb-code, ub)
        .
      end.
      when 'scgb':U then do:
        assign
          next-seq = next-value(s-scgb-code, ub)
        .
      end.
      when 'sclc':U then do:
        assign
          next-seq = next-value(s-sclc-code, ub)
        .
      end.
      when 'pglc':U then do:
        assign
          next-seq = next-value(s-pglc-code, ub)
        .
      end.
      when 'dcgb':U then do:
        assign
          next-seq = next-value(s-dcgb-code, ub)
        .
      end.
      when 'ctgb':U then do:
        assign
          next-seq = next-value(s-ctgb-code, ub)
        .
      end.
      when 'drgb':U then do:
        assign
          next-seq = next-value(s-drgb-code, ub)
        .
      end.
      when 'fmgb':U then do:
        assign
          next-seq = next-value(s-fmgb-code, ub)
        .
      end.
      when 'pngb':U then do:
        assign
          next-seq = next-value(s-pngb-code, ub)
        .
      end.
      when 'cagb':U then do:
        assign
          next-seq = next-value(s-cagb-code, ub)
        .
      end.
      when 'fdgb':U then do:
        assign
          next-seq = next-value(s-fin-doc, ub)
        .
      end.
    end case.
  end.
end procedure.
procedure set-seq-cr :
  define input parameter type-code like ub.code-range.range-type no-undo .
  define input parameter set-val   like ub.code-range.first-code no-undo .
  do
  on error  undo, return error substitute( "&1 (set-seq-cr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (set-seq-cr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (set-seq-cr). endkey", vss-workfile )
  :
    case type-code:
      when 'bcgb':U then do:
        assign
          current-value(s-bcgb-code, ub) = set-val
        .
      end.
      when 'scgb':U then do:
        assign
          current-value(s-scgb-code, ub) = set-val
        .
      end.
      when 'sclc':U then do:
        assign
          current-value(s-sclc-code, ub) = set-val
        .
      end.
      when 'pglc':U then do:
        assign
          current-value(s-pglc-code, ub) = set-val
        .
      end.
      when 'dcgb':U then do:
        assign
          current-value(s-dcgb-code, ub) = set-val
        .
      end.
      when 'ctgb':U then do:
        assign
          current-value(s-ctgb-code, ub) = set-val
        .
      end.
      when 'drgb':U then do:
        assign
          current-value(s-drgb-code, ub) = set-val
        .
      end.
      when 'fmgb':U then do:
        assign
          current-value(s-fmgb-code, ub) = set-val
        .
      end.
      when 'pngb':U then do:
        assign
          current-value(s-pngb-code, ub) = set-val
        .
      end.
      when 'cagb':U then do:
        assign
          current-value(s-cagb-code, ub) = set-val
        .
      end.
      when 'fdgb':U then do:
        assign
          current-value(s-fin-doc, ub) = set-val
        .
      end.
    end case.
  end.
end procedure.
procedure new-bcod-gen-code-range :
  do
  on error  undo, return error substitute( "&1 (new-bcod-gen-code-range). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (new-bcod-gen-code-range). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (new-bcod-gen-code-range). endkey", vss-workfile )
  :
    define input parameter p-db-num  like ub.db.db-num             no-undo .
    define input parameter type-code like ub.code-range.range-type no-undo .
    define buffer buf_code-range      for ub.code-range .
    define buffer last_code-range     for ub.code-range .
    define buffer last-1_code-range   for ub.code-range .
    define buffer last-2_code-range   for ub.code-range .
    define buffer last-3_code-range   for ub.code-range .
    define buffer buf_sys-ctrl        for ub.sys-ctrl .
    define variable conf-par       as character no-undo .
    define variable par-type       as character no-undo .
    define variable cfg-param-code like ub.thbj-attr.prop-code no-undo .
    define variable v-cre-cdrg as logical   no-undo .
    define variable v-cre-str  as character no-undo .
    define variable v-cr1      as integer no-undo .
    define variable v-cr2      as integer no-undo .
    define variable v-cr3      as integer no-undo .
    define variable v-cmax     as integer no-undo .
    find first buf_sys-ctrl no-lock .
    if buf_sys-ctrl.db-num <> 0 and type-code <> 'cagb':U then do:
      undo, return error substitute("&1 &2 &3&4Диапазоны кодов можно создавать только в ГБД&4База данных &5"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,chr(10)
                                    , p-db-num
                                   ).
    end.
    run trg/getpcode.p ( input  type-code
                   ,output cfg-param-code
                  ).
    for each buf_code-range
      where buf_code-range.db-num     = -1
        and buf_code-range.range-type = type-code
        and buf_code-range.stts       = "f"
    by buf_code-range.first-code
    on error  undo, return error substitute( "&1 (new-bcod-gen-code-range). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    on stop   undo, return error substitute( "&1 (new-bcod-gen-code-range). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (new-bcod-gen-code-range). endkey", vss-workfile )
    :
      assign
        buf_code-range.db-num = p-db-num
      .
      return .
    end.
    assign
      v-cre-cdrg = TRUE
    .
    case type-code:
      when 'sclc':U
      or when 'scgb':U
      or when 'pglc':U
      then do:
        find last last-1_code-range no-lock
          where last-1_code-range.range-type = 'sclc':U
          no-error .
        if available last-1_code-range then do:
          v-cr1 = last-1_code-range.last-code.
        end.
        find last last-2_code-range no-lock
          where last-2_code-range.range-type = 'scgb':U
          no-error .
        if available last-2_code-range then do:
          v-cr2 = last-2_code-range.last-code.
          end.
        find last last-3_code-range no-lock
          where last-3_code-range.range-type = 'pglc':U
          no-error .
        if available last-3_code-range then do:
          v-cr3 = last-3_code-range.last-code.
        end.
        v-cmax = maximum(v-cr1, v-cr2, v-cr3)
        .
        if v-cmax = v-cr1  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-1_code-range )
              .
          end.
        if v-cmax = v-cr2  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-2_code-range )
              .
          end.
        if v-cmax = v-cr3  then do:
          find last last_code-range no-lock
            where recid( last_code-range ) = recid( last-3_code-range )
            .
        end.
        if last_code-range.last-code + 1 > 99999 then do:
          assign
            v-cre-cdrg = FALSE
          .
        end.
      end.
      when 'bcgb':U
      or when 'sslc':U
      or when 'ssgb':U
      then do:
        find last last-1_code-range no-lock
          where last-1_code-range.range-type = 'sslc':U
          no-error .
        if available last-1_code-range then do:
          v-cr1 = last-1_code-range.last-code.
        end.
        find last last-2_code-range no-lock
          where last-2_code-range.range-type = 'bcgb':U
          no-error .
        if available last-2_code-range then do:
          v-cr2 = last-2_code-range.last-code.
          end.
        find last last-3_code-range no-lock
          where last-3_code-range.range-type = 'ssgb':U
          no-error .
        if available last-3_code-range then do:
          v-cr3 = last-3_code-range.last-code.
        end.
        v-cmax = maximum(v-cr1, v-cr2, v-cr3)
        .
        if v-cmax = v-cr1  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-1_code-range )
              .
          end.
        if v-cmax = v-cr2  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-2_code-range )
              .
          end.
        if v-cmax = v-cr3  then do:
          find last last_code-range no-lock
            where recid( last_code-range ) = recid( last-3_code-range )
            .
        end.
      end.
      otherwise do:
        find last last_code-range no-lock
          where last_code-range.range-type = type-code
          no-error .
      end.
    end case.
    if not available last_code-range then do:
      undo, return error substitute("&1 &2 &3&4В БД нет ни одного диапазона с типом &5&4Не была проведена инициализация диапазонов!"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    , chr(10)
                                    , type-code
                                   ) .
    end.
    define variable v-mes2 as character no-undo .
    define variable v-param-type2 as character no-undo .
    define variable v-value-character2 as INTEGER no-undo .
    define variable v-value-date2 as date no-undo .
    define variable v-value-decimal2 as decimal no-undo .
    define variable v-value-integer2 AS integer no-undo .
    define variable v-value-logical2 AS LOGICAL no-undo .
    define variable v-tth2 as handle no-undo .
    run adm/shattri.p (
        input "get":U
        ,input  'БД':U
        ,input  p-db-num
        ,input  'code-range':U
        ,input  cfg-param-code
        ,output v-value-character2
        ,output v-value-date2
        ,output v-value-decimal2
        ,output v-value-integer2
        ,output v-value-logical2
        ,output v-param-type2
        ,INPUT-OUTPUT table-handle v-tth2
        ) no-error .
    if error-status :error then do:
      delete object v-tth2.
      v-mes2 = substitute("Ошибка при получении размера диапазона собственных глобальных кодов&2&1&2&3"
                         , error-status:get-message(1)
                         , chr(10)
                         , return-value ).
      undo, return error v-mes2.
    end.
    delete object v-tth2.
    if v-cre-cdrg = TRUE then do:
      create buf_code-range .
      assign
        buf_code-range.db-num     = p-db-num
        buf_code-range.range-type = type-code
        buf_code-range.stts       = "f"
        buf_code-range.first-code = last_code-range.last-code + 1
        buf_code-range.last-code  = last_code-range.last-code + integer(v-value-integer2)
        v-cre-str = "Свободный диапазон успешно создан"
      .
    end.
    else do:
      assign
        v-cre-str = "Нет возможности создать свободный диапазон." + chr(10)
                    + substitute( "Превышен предел диапазонов c типом &1", type-code )
      .
    end.
  end.
  return v-cre-str .
end procedure.
procedure gen-new-code-range-if-neces :
  define input parameter v-db-num           like ub.db.db-num             no-undo .
  define input parameter v-range-type       like ub.code-range.range-type no-undo .
  define input parameter v-cur-code         as   integer                  no-undo .
  define input parameter v-g#news           as   logical                  no-undo .
  define input parameter v-g#db-num         like ub.db.db-num             no-undo .
  define input parameter v-g#news-source-db like ub.db.db-num             no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-new-code-range-if-neces). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (gen-new-code-range-if-neces). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-new-code-range-if-neces). endkey", vss-workfile )
  :
    define variable l-code-range-exist as logical   no-undo init false .
    define variable v-db-for-send      as character no-undo .
    define buffer buf_code-range  for ub.code-range .
    define buffer buf1_code-range for ub.code-range .
    define buffer buf_db          for ub.db .
    find first buf_code-range
      where buf_code-range.range-type = v-range-type
        and buf_code-range.last-code >= v-cur-code
      use-index last-codei
      no-error .
    if
    (
       available buf_code-range
       and
      (buf_code-range.db-num = v-db-num
        and
      buf_code-range.first-code <= v-cur-code
      )
    or
      (
        v-range-type = 'drgb':U
        AND
        v-cur-code = 0
      )
   )
   then do:
      assign
        l-code-range-exist = true
      .
      if v-g#news
      and buf_code-range.stts = "f" then do:
        assign
          buf_code-range.stts = "u"
        .
      end.
    end.
    if not l-code-range-exist
       and v-g#news-source-db <> 0
    then do:
      undo, return error substitute("&1 &2 &3&4Отсутствует диапазон кодов для БД &5 Тип диапазона кодов &6 Код &7"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,chr(10)
                                    ,v-db-num
                                    ,v-range-type
                                    ,v-cur-code
                                   ).
    end.
    if (not l-code-range-exist
        or ( v-cur-code >= int( (buf_code-range.first-code + buf_code-range.last-code) / 2 ) )
       )
    and ( not can-find (first buf1_code-range no-lock
                        where buf1_code-range.db-num = v-db-num
                          and buf1_code-range.range-type = v-range-type
                          and buf1_code-range.stts = "f"
                       )
        )
    then do:
      if v-g#db-num = 0 then do:
        run new-bcod-gen-code-range in this-procedure
          (input v-db-num,
           input v-range-type
          ) no-error .
        if error-status :error then do:
          undo, return error substitute("Ошибка при создании нового свободного диапазона &1 Тип диапазона кодов &2 Код &3:&4&5 &6"
                                        , substitute("&1 &2 &3", vss-workfile, vss-revision, vss-description)
                                        ,v-db-num
                                        ,v-range-type
                                        ,v-cur-code
                                        ,chr(10)
                                        ,error-status:get-message(1)
                                        ,return-value
                                       ).
        end.
      end.
      else do:
        if v-range-type = 'sclc':U
        or v-range-type = 'pglc':U
        then do:
          assign
            v-db-for-send = "":U
          .
          if v-g#db-num = 0 then do:
            for each buf_db no-lock
              where buf_db.db-num > 0
                and buf_db.db-num <> v-g#news-source-db
            on error  undo, return error substitute( "&1 (gen-new-code-range-if-neces). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
            :
              assign
                v-db-for-send = v-db-for-send + chr(1) + string( buf_db.db-num )
              .
            end.
            assign
              v-db-for-send = right-trim( v-db-for-send, chr(1) )
            .
          end.
          else do:
            if not v-g#news then do:
              assign
                v-db-for-send = "0":U
              .
            end.
          end.
          run nws/cr-route.p ( input 'send-cmd':U
                        ,input ("command":U + chr(1) + "create":U + chr(1) +
                               "code-range":U + chr(1) +
                               (if v-range-type = 'sclc':U
                                then string( current-value(s-sclc-code, ub))
                                else string( current-value(s-pglc-code, ub))
                                ) + chr(1) +
                                v-range-type)
                        ,input ?
                        ,input v-db-for-send
                        ) no-error .
          if error-status :error then do:
            undo, return error return-value.
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure cre-loc-sc-code-range :
  define input parameter v-cur-code as integer no-undo .
define input parameter p-cdrg-type as character no-undo .
  do
  on error  undo, return error substitute( "&1 (cre-loc-sc-code-range). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (cre-loc-sc-code-range). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (cre-loc-sc-code-range). endkey", vss-workfile )
  :
    define buffer buf_code-range for ub.code-range .
    find first buf_code-range
         where buf_code-range.range-type = p-cdrg-type
           and buf_code-range.first-code >= v-cur-code
         no-error .
    if not available buf_code-range then do:
      run new-bcod-gen-code-range in this-procedure
        ( input 0,
          input p-cdrg-type
        ) no-error .
      if error-status :error then do:
        undo, return error substitute( "Ошибка при создании нового свободного диапазона локальных весовых или штучных кодов&1"
                                       + "Код &2&1&3 &4"
                                      , chr(10)
                                      , v-cur-code
                                      , error-status:get-message(1)
                                      , return-value
                                     ) .
      end.
    end.
  end.
end procedure.
procedure mark-used-if-need :
define input parameter p-cur-code as integer no-undo .
define input parameter p-range-type like ub.code-range.range-type no-undo .
define input parameter p-db-num like ub.code-range.db-num no-undo .
  do
  on error  undo, return error substitute( "&1 (mark-used-if-need). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (mark-used-if-need). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (mark-used-if-need). endkey", vss-workfile )
  :
    DEFINE VARIABLE v-db-num like ub.code-range.db-num no-undo .
    define buffer buf_code-range for ub.code-range .
    assign
    v-db-num = if p-range-type = 'sclc':U
               then 0
               else p-db-num
    .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer locK-batchprocess3 for ub.batchprocess.
run gbl/lock-prc.p
    (input 'lscc':U
    ,input 0
    ,input 0
    ,input 0
    ,input ""
    ,input ""
    ,input ""
    ,input (
            ",,,Вкл/выкл лок. вес. кодов"
           )
    ,input true
    ,buffer lock-batchprocess3
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "В данный момент идет процесс вкл/выкл лок. вес. кодов" skip
      view-as alert-box error .
    undo, return error .
  end.
    find first buf_code-range
         where buf_code-range.range-type = p-range-type
           and buf_code-range.first-code >= p-cur-code
           and buf_code-range.last-code <= p-cur-code
           and buf_code-range.db-num = v-db-num
         no-error .
    if not available buf_code-range then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при создании поиске диапазона" skip
        "База данных" p-db-num skip
        "Код" p-cur-code skip
        "Тип" p-range-type
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if buf_code-range.stts = "f":U then do:
      assign
      buf_code-range.stts = "u":U
      .
    end.
  end.
end procedure.
if p-mode <> 'ДОБАВЛЕНИЕ':U
AND p-mode <> 'ИЗМЕНЕНИЕ':U
and p-mode <> 'ДОБАВЛЕНИЕ-ИМПОРТ':U
then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр p-mode" p-mode
  view-as alert-box error .
  return error '':u.
end.
if p-mode = 'ДОБАВЛЕНИЕ-ИМПОРТ':U then do:
  assign
  p-mode = 'ДОБАВЛЕНИЕ':U
  v-import = yes
  .
end.
if p-callpoint <> "discards":U
and p-callpoint <> "cli-all":U
and p-callpoint <> "":U
then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-callpoint"  p-callpoint
    view-as alert-box ERROR.
    undo, return error.
end.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
if p-mode = 'ДОБАВЛЕНИЕ':U then do:
  RUN chk-code in this-procedure ( output v-is-correct) no-error.
  if error-status:error THEN do:
    assign
    v-err-mess = substitute("Ошибка при проверке кода организации &1&2&3"
                            , p-firm-code
                            , chr(10)
                            , return-value ).
    run err-mess in this-procedure ( input-output v-err-mess).
    undo, return error (if p-silent then v-err-mess else (if return-value = "":U then "firm-code":U else return-value)).
  end.
  if not v-is-correct then do:
    undo, return error (if p-silent then v-err-mess else (if return-value = "":U then "firm-code":U else return-value)).
  end.
  p-firm-code = abs(p-firm-code).
end.
RUN chk-name in this-procedure ( p-firm-code, output v-is-correct) no-error.
if error-status:error THEN do:
  assign
  v-err-mess = substitute("Ошибка при проверке названия организации &1", p-obj-name)
  .
  run err-mess in this-procedure ( input-output  v-err-mess ).
  undo, return error (if p-silent then v-err-mess else "obj-name":U).
end.
if not v-is-correct then do:
  undo, return error (if p-silent then v-err-mess else "obj-name":U).
end.
find first buf_cli-grp no-lock where
          buf_cli-grp.node-code = p-grp-code no-error .
if not avail buf_cli-grp then do:
  assign
  v-err-mess = substitute("Неверный код группы клиента &1", p-grp-code) .
  run err-mess in this-procedure ( input-output v-err-mess ).
  undo, return error v-err-mess.
end.
if can-find(first ub.cli-grp no-lock where
                    ub.cli-grp.upper-code = p-grp-code) then do:
  v-err-mess = "Клиент может быть привязан только к терминальной группе".
  run err-mess in this-procedure ( input-output v-err-mess).
  undo, return error (if p-silent then v-err-mess else "":U).
end.
if p-inn <> "":U and not p-no-check-inn then do:
  run gbl/keyinn.p ( input p-inn, input 'орг':U, input p-firm-code, input p-is-pboul, output v-correct-inn) no-error .
  if error-status:error or not v-correct-inn then do:
    assign
    v-err-mess = substitute("Неверный ИНН &1: &2", p-inn, return-value).
    run err-mess in this-procedure ( input-output v-err-mess ).
    return error (if p-silent then v-err-mess else "inn":U).
  end.
end.
if p-reg-code <> 0  then do:
  find first buf_regions no-lock where
            buf_regions.reg-code = p-reg-code no-error.
  if not available buf_regions then do:
    assign
    v-err-mess = substitute("Неверный код региона &1", p-reg-code).
    run err-mess ( input-output v-err-mess ).
    return error ( if p-silent then v-err-mess else "reg-code":U).
  end.
end.
define variable v-int as integer no-undo .
if p-passp-num <> "":U then do:
  assign
  v-int = integer(p-passp-num)
  no-error .
  if error-status:error
  or v-int = ?
  or trim(p-passp-num, "0123456789") <> '':U
  then do:
    assign
    v-err-mess = substitute("Неверный № паспорта &1: &2", p-passp-num, return-value).
    run err-mess ( input-output v-err-mess ).
    return error ( if p-silent then v-err-mess else "passp-num":U).
  end.
end.
if p-tobj-code > 0 then do:
  IF NOT can-find(first ub.clients where
                       ub.clients.obj-type = 'чел':U
                   and ub.clients.obj-code = p-tobj-code) then do:
    assign
    v-err-mess = substitute("Значение поля <<КОД ТОРГОВОГО ПРЕДСТАВИТЕЛЯ>>&1должно соответствовать имеющемуся в системе клиенту типа <<&2>>"
                          ,chr(10)
                        ,'чел':U).
    run err-mess ( input-output v-err-mess ).
    return error ( if p-silent then v-err-mess else "tobj-code":U).
  END.
end.
main-block:
DO for buf_clients
      ,buf_firm
ON ERROR undo main-block, RETURN ERROR
ON STOP undo main-block, RETURN ERROR :
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    if available buf_clients then release buf_clients.
    create buf_clients.
    assign
    buf_clients.obj-type = 'орг':U
    buf_clients.obj-code = p-firm-code
    buf_clients.obj-name = p-obj-name
    buf_clients.stts     = p-stts
    buf_clients.grp-code = p-grp-code
    .
    create buf_firm.
    assign
    buf_firm.firm-code =  p-firm-code
    .
    assign
    p-rid = recid(buf_clients)
    .
  end.
  else do:
    FIND FIRST buf_clients where
              recid(buf_clients) = p-rid No-ERROR.
    if not available buf_clients then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись КЛИЕНТ - p-rid" p-rid
      view-as alert-box error .
      undo main-block, return error '':u.
    end.
    if buf_clients.obj-type <>  'орг':U
    OR buf_clients.obj-code <> p-firm-code then do:
      message
      vss-workfile vss-revision vss-description skip
      "Для уже имеющейся записи нельзя изменить"
      "тип и код клиента" skip
      view-as alert-box ERROR.
      undo main-block, return error '':U.
    end.
    FIND FIRST buf_firm where
              buf_firm.firm-code = p-firm-code No-ERROR.
    if not available buf_firm then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись ОРГАНИЗАЦИЯ - p-firm-code" p-firm-code
      view-as alert-box error .
      undo main-block, return error '':u.
    end.
  end.
  assign
  v-new-inn = p-inn.
  run trg/inn-uniq.p (
                   input-output v-new-inn
                  ,input (if p-mode = 'ДОБАВЛЕНИЕ':U then p-inn else buf_firm.inn)
                  ,input 'орг':U
                  ,input buf_firm.firm-code
                  ,input p-silent
                  ,input recid(buf_firm)
                  ,input buffer buf_firm:handle
                  ,output v-inn-uniq-error
                  ) no-error.
  if error-status:error then do:
    v-err-mess = substitute("Ошибка при проверке ИНН на уникальность&1&2&1&3"
                            , chr(10)
                            , error-status:get-message(1)
                            , return-value) .
    run err-mess in this-procedure ( input-output v-err-mess ).
    undo, return error (if p-silent then v-err-mess else "inn-uniq":U).
  end.
  if v-inn-uniq-error then do:
    v-err-mess = return-value .
    if v-err-mess = 'inn-uniq-no-message' then do:
      v-err-mess = 'inn-uniq'.
    end.
    else do:
      run err-mess in this-procedure ( input-output v-err-mess ).
    end.
    undo, return error (if p-silent then v-err-mess else "inn-uniq":U).
  end.
  assign
  buf_clients.obj-name    =  p-obj-name
  buf_clients.lim-kr      =  p-lim-kr
  buf_clients.PS          =  p-PS
  buf_clients.grp-code    =  p-grp-code
  buf_firm.addres1        =  p-addres1
  buf_firm.addres2        =  p-addres2
  buf_firm.city           =  p-city
  buf_firm.contact-psn    =  p-contact-psn
  buf_firm.director       =  p-director
  buf_firm.e-mail         =  p-e-mail
  buf_firm.engl-name      =  p-engl-name
  buf_firm.fax            =  p-fax
  buf_firm.given-by       =  p-given-by
  buf_firm.ind            =  p-ind
  buf_firm.inn            =  p-inn
  buf_firm.is-pboul       =  p-is-pboul
  buf_firm.kpp            =  p-kpp
  buf_firm.okonh          =  p-okonh
  buf_firm.okpo           =  p-okpo
  buf_firm.passp-num      =  p-passp-num
  buf_firm.passp-ser      =  p-passp-ser
  buf_firm.phone          =  p-phone
  buf_firm.phone1-note    =  p-phone1-note
  buf_firm.post-addr1     =  p-post-addr1
  buf_firm.post-addr2     =  p-post-addr2
  buf_firm.post-city      =  p-post-city
  buf_firm.post-ind       =  p-post-ind
  buf_clients.reg-code    =  p-reg-code
  buf_firm.telex          =  p-telex
  buf_firm.tobj-code      =  p-tobj-code
  buf_clients.turnover-buyer     = p-turnover-buyer
  buf_clients.turnover-buyer-gds = p-turnover-buyer-gds
  buf_clients.trg-param   =    (if v-import
                               and p-callpoint = "discards"
                               then 'no-callnews':U
                               else '':U)
  buf_firm.trg-param      =    (if v-import
                               and p-callpoint = "discards"
                               then 'no-callnews':U
                               else '':U)
  .
  release buf_clients no-error.
  if error-status:error then do:
    message
    vss-workfile vss-revision vss-description skip
    "Ошибка при сохранении записи КЛИЕНТА" skip
    ERROR-STATUS:GET-NUMBER(1) skip
    return-value
    view-as alert-box .
    undo main-block, return error "":U.
  end.
  release buf_firm no-error.
  if error-status:error then do:
    message
    vss-workfile vss-revision vss-description skip
    "Ошибка при сохранении записи ОРГАНИЗАЦИИ" skip
    ERROR-STATUS:GET-NUMBER(1) skip
    return-value
    view-as alert-box .
    undo main-block, return error "":U.
  end.
end.
procedure chk-code :
define output parameter p-is-correct as logical no-undo .
define variable v-rid as recid no-undo .
define variable maindb-begin-code as integer no-undo.
define variable maindb-end-code as integer no-undo.
define variable currentdb-begin-code as integer no-undo.
define variable currentdb-end-code as integer no-undo.
define variable glog as logical no-undo .
define variable v-result as logical no-undo .
define buffer buf_clients for ub.clients.
define buffer buf_person for ub.person.
do
on error undo, return error return-value
:
 if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    if p-firm-code = 0 then do:
      run gen-b-code in this-procedure ( input 'fmgb':U, output p-firm-code) no-error .
      if error-status:error then do:
        assign
        v-err-mess = substitute("Ошибка при получении кода организации для нового контрагента&1&2&1&3"
                                , chr(10)
                                , error-status:get-message(1)
                                , return-value ).
        run err-mess in this-procedure ( input-output v-err-mess ).
        undo, return  error (if p-silent then v-err-mess else "firm-code":U).
      end.
    end.
    else do:
      assign
      v-result = calc-range(
                         input v-db-num
                        ,input p-firm-code
                        ,input 'fmgb':U
                        )
      no-error .
      if v-result = ?  then  do:
          assign
          v-err-mess = substitute("Не найден диапапазон контрагентов для кода контрагента &1 в БД &2", p-firm-code, v-db-num).
          run err-mess in this-procedure ( input-output v-err-mess ).
          undo, return  error (if p-silent then v-err-mess else "psn-code":U).
      end.
      if v-result = no  and v-import = no then  do:
        assign
        v-err-mess = substitute("Вы не можете САМОСТОЯТЕЛЬНО определить код НОВОЙ организации = &1", p-firm-code).
        run err-mess in this-procedure ( input-output v-err-mess ).
        undo, return  error (if p-silent then v-err-mess else "firm-code":U).
      end.
    end.
    if p-firm-code = 0 then  do:
      assign
      v-err-mess = "Код организации не может быть равен 0".
      run err-mess in this-procedure (input-output v-err-mess).
      undo, return error (if p-silent then v-err-mess else "":U).
    end.
    if can-find( first ub.firm where
                      ub.firm.firm-code = p-firm-code ) then do:
      assign
      v-err-mess =  substitute("Организация с кодом &1 уже есть", p-firm-code).
      run err-mess in this-procedure ( input-output v-err-mess).
      undo, return error (if p-silent then v-err-mess else "firm-code":U).
    end.
  end.
  assign
  p-is-correct = yes
  .
end.
end procedure.
procedure chk-name :
DEFINE INPUT PARAMETER p-firm-code like ub.firm.firm-code no-undo.
define output parameter p-is-correct as logical no-undo .
define variable int-buf as integer no-undo .
DEFINE buffer buf_firm for ub.firm.
  do
  on error undo, return error return-value
  :
    if p-obj-name  = "" then do:
      assign
      v-err-mess = "Нет названия".
      run err-mess in this-procedure  ( input-output v-err-mess ).
      undo, return error (if p-silent then v-err-mess else "obj-name":U).
    end.
    assign
    p-is-correct = yes
    .
  end.
end procedure.
PROCEDURE err-mess:
  DEFINE INPUT-output PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      p-mess = substitute("Клиент орг&1: &2", p-firm-code,  p-mess).
    end.
    otherwise do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.
