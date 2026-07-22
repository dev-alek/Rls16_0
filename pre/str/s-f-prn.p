block-level on error undo, throw.
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id           as recid                no-undo.
define input parameter p-mode           as character            no-undo.
do
on error undo, return error
:
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: s-f-prn.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/s-f-prn.p $":U .
define variable vss-description as character no-undo init "Печать счета-фактуры".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define NEW shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define NEW shared variable RepPathName        as character no-undo .
define NEW shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function breakstr returns character ( input        for-name    as character,
                                      input        line-length as integer,
                                      input-output line1       as character,
                                      input-output line2       as character ) :
  define variable ii as integer no-undo.
  if length( for-name ) > line-length then do:
    assign ii    = 1
           line1 = "":u
           line2 = "":u.
    if length( entry( ii, for-name , " ":u ) ) > line-length then do:
      assign line1 =       substring( for-name, 1, line-length     )
             line2 = trim( substring( for-name,    line-length + 1 ) ).
    end.                                                     else do:
      do while length( line1 + entry( ii, for-name, " ":u ) ) < ( line-length + 1 ) :
        assign line1 = line1 + entry( ii, for-name, " ":u ) + " ":u
               ii    = ii    + 1.
        if length( entry( ii, for-name, " ":u ) ) > line-length then do:
          assign line1 = line1 + substring( for-name, length( line1 ), line-length - length( line1 ) + 1 ).
        end.
      end.
      assign line2 = trim( substring( for-name, length( line1 ) ) ).
    end.
  end.                                else do:
    assign line1 = for-name
           line2 = "":u.
  end.
  return ( line1 ).
end function.
def var vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.
def var vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-param no-undo   field param-code     as character   field param-sub-code as character   field param-value    as character   index xpk is primary unique param-code param-sub-code   .
procedure paramls-clear :
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    for each buf_temp-param
    on error undo, return error
    :
      delete buf_temp-param .
    end.
  end.
end procedure.
procedure paramls-write :
  define input  parameter p-code     as character no-undo .
  define input  parameter p-sub-code as character no-undo .
  define input  parameter p-value    as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
      where buf_temp-param.param-code     = p-code
        and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if not available buf_temp-param then do:
      create buf_temp-param .
      assign
        buf_temp-param.param-code     = p-code
        buf_temp-param.param-sub-code = p-sub-code
      .
    end.
    assign
      buf_temp-param.param-value = p-value
    .
  end.
end procedure.
procedure paramls-read :
  define input  parameter p-code          as character no-undo .
  define input  parameter p-sub-code      as character no-undo .
  define input  parameter p-default-value as character no-undo .
  define output parameter p-value         as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
      where buf_temp-param.param-code     = p-code
        and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if available buf_temp-param then do:
      assign
        p-value = buf_temp-param.param-value
      .
    end.
    else do:
      assign
        p-value = p-default-value
      .
    end.
  end.
end procedure.
procedure paramls-append :
  define input  parameter p-code     as character no-undo .
  define input  parameter p-sub-code as character no-undo .
  define input  parameter p-value    as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
         where buf_temp-param.param-code     = p-code
           and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if not available buf_temp-param then do:
      create buf_temp-param .
      assign
        buf_temp-param.param-code     = p-code
        buf_temp-param.param-sub-code = p-sub-code
        buf_temp-param.param-value    = p-value
      .
    end.
    else do:
        assign
            buf_temp-param.param-value = buf_temp-param.param-value + ",":U + p-value
        .
    end.
  end.
end procedure.
define variable vss-include-info5 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define stream excel-line.
define stream excel-cell.
define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character
    index pi is primary unique data-key
.
define temp-table temp_line-data no-undo
    field data-key     as character
    field xl-line-id   as integer
    field Name         as character
    field pokazately   as character
    field UAES         as character
    field OKEI         as character
    field EI           as character
    field qnty         as character
    field price        as character
    field SumNoVAT     as character
    field SumActciz    as character
    field VATpc        as character
    field VATsum       as character
    field sum          as character
    field countrycode  as character
    field country      as character
    field GTD          as character
    index pi is primary unique xl-line-id
.
define variable v-facturxl-current-data-row     as integer      no-undo.
define variable v-facturxl-cell-file-name       as character    no-undo.
define variable v-facturxl-data-file-name       as character    no-undo.
procedure facturxl-init :
    define buffer buf_temp_cell-data        for temp_cell-data.
    define buffer buf_usr-flt               for ubflt.usr-flt.
    define variable v-column-list as character no-undo .
    define variable v-column-type as character no-undo .
    define variable v-num-cloumns as integer no-undo .
do
for buf_temp_cell-data
  , buf_usr-flt
on error undo, return error
:
    assign
        v-facturxl-current-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-facturxl-data-file-name
    ).
    output stream excel-line to value( v-facturxl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-facturxl-cell-file-name
    ).
    output stream excel-cell to value( v-facturxl-cell-file-name ).
    run facturxl-write-cell-data in this-procedure (
          input "valutCode":U
        , input if printrubl then "0":U else "1":U
    ).
  if lookup ("corr" , p-mode) <> 0 then do :
    v-column-list = "Name,pokazately,UAES,OKEI,EI,qnty,price,SumNoVAT,SumActciz,VATpc,VATsum,sum":U .
    v-column-type = "S,S,S,I,S,D,C,C,S,D,C,C":U .
  end.
  else do :
    v-column-list = "Name,UAES,OKEI,EI,qnty,price,SumNoVAT,SumActciz,VATpc,VATsum,sum,countrycode,country,GTD":U .
    v-column-type = "S,S,I,S,D,C,C,S,D,C,C,I,S,S":U .
  end.
  v-num-cloumns = num-entries(v-column-list) .
  run facturxl-write-cell-data in this-procedure (
          input "columnList":U
        , input v-column-list
  ).
  run facturxl-write-cell-data in this-procedure (
          input "columnType":U
        , input v-column-type
  ).
  run facturxl-write-cell-data in this-procedure (
          input "columnAmount":U
        , input string(v-num-cloumns)
  ).
  if lookup ("corr" , p-mode) <> 0 then .
  else do :
    run facturxl-write-cell-data in this-procedure (
          input "subtotalList":U
        , input "SumNoVAT,VATsum,sum":U
    ).
    run facturxl-write-cell-data in this-procedure (
          input "subtotalType":U
        , input "S,S,S":U
    ).
    run facturxl-write-cell-data in this-procedure (
          input "subtotalAmount":U
        , input "3":U
    ).
  end.
end.
end procedure.
procedure facturxl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/sf_97.xlt":U.
        export "exe/t_97.bas":U.
        export v-facturxl-cell-file-name.
        export v-facturxl-data-file-name.
    output close.
end.
end procedure.
procedure facturxl-close-10 :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/sf_97-10.xlt":U.
        export "exe/t_97.bas":U.
        export v-facturxl-cell-file-name.
        export v-facturxl-data-file-name.
    output close.
end.
end procedure.
procedure facturxl-close-vat-itog :
do
on error undo, return error return-value
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/sf_97vat.xlt":U.
        export "exe/t_97.bas":U.
        export v-facturxl-cell-file-name.
        export v-facturxl-data-file-name.
    output close.
end.
end procedure.
procedure facturxl-close-topaukc :
do
on error undo, return error return-value
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/sf_97topaukc.xlt":U.
        export "exe/t_97.bas":U.
        export v-facturxl-cell-file-name.
        export v-facturxl-data-file-name.
    output close.
end.
end procedure.
procedure facturxl-close-corr :
do
on error undo, return error return-value
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/corr_sf.xlt":U.
        export "exe/t_csf_97.bas":U.
        export v-facturxl-cell-file-name.
        export v-facturxl-data-file-name.
    output close.
end.
end procedure.
procedure facturxl-write-cell-data :
define input parameter p-data-key   as character        no-undo.
define input parameter p-data-value as character        no-undo.
    define buffer buf_temp_cell-data     for temp_cell-data.
do
for buf_temp_cell-data
on error undo, return error
:
    find first buf_temp_cell-data
         where buf_temp_cell-data.data-key = p-data-key
    no-error.
    if not available buf_temp_cell-data
    then do:
        create buf_temp_cell-data.
        assign
            buf_temp_cell-data.data-key = p-data-key
        .
    end.
    assign
        buf_temp_cell-data.data-value = p-data-value
    .
    put stream excel-cell unformatted
                        buf_temp_cell-data.data-key
        chr(9)   buf_temp_cell-data.data-value
        chr(10)
    .
end.
end procedure.
procedure facturxl-write-line-data :
define input parameter p-Name          as character        no-undo.
define input parameter p-UAES          as character        no-undo.
define input parameter p-OKEI          as character        no-undo.
define input parameter p-EI            as character        no-undo.
define input parameter p-qnty          as character        no-undo.
define input parameter p-price         as character        no-undo.
define input parameter p-SumNoVAT      as character        no-undo.
define input parameter p-SumActciz     as character        no-undo.
define input parameter p-VATpc         as character        no-undo.
define input parameter p-VATsum        as character        no-undo.
define input parameter p-sum           as character        no-undo.
define input parameter p-countrycode   as character        no-undo.
define input parameter p-country       as character        no-undo.
define input parameter p-GTD           as character        no-undo.
    define buffer buf_temp_line-data        for temp_line-data.
do
for buf_temp_line-data
on error undo, return error
:
    for each buf_temp_line-data
    :
        delete buf_temp_line-data.
    end.
    create buf_temp_line-data.
    assign
        v-facturxl-current-data-row = v-facturxl-current-data-row + 1
    .
    assign
        buf_temp_line-data.data-key     = "LD":U
        buf_temp_line-data.xl-line-id   = v-facturxl-current-data-row
        buf_temp_line-data.Name         = p-Name
        buf_temp_line-data.UAES         = p-UAES
        buf_temp_line-data.OKEI         = p-OKEI
        buf_temp_line-data.EI           = p-EI
        buf_temp_line-data.qnty         = p-qnty
        buf_temp_line-data.price        = p-price
        buf_temp_line-data.SumNoVAT     = p-SumNoVAT
        buf_temp_line-data.SumActciz    = p-SumActciz
        buf_temp_line-data.VATpc        = p-VATpc
        buf_temp_line-data.VATsum       = p-VATsum
        buf_temp_line-data.sum          = p-sum
        buf_temp_line-data.countrycode  = p-countrycode
        buf_temp_line-data.country      = p-country
        buf_temp_line-data.GTD          = p-GTD
    .
    put stream excel-line unformatted
                        buf_temp_line-data.data-key
        chr(9)   buf_temp_line-data.Name
        chr(9)   buf_temp_line-data.UAES
        chr(9)   buf_temp_line-data.OKEI
        chr(9)   buf_temp_line-data.EI
        chr(9)   buf_temp_line-data.qnty
        chr(9)   buf_temp_line-data.price
        chr(9)   buf_temp_line-data.SumNoVAT
        chr(9)   buf_temp_line-data.SumActciz
        chr(9)   buf_temp_line-data.VATpc
        chr(9)   buf_temp_line-data.VATsum
        chr(9)   buf_temp_line-data.sum
        chr(9)   buf_temp_line-data.countrycode
        chr(9)   buf_temp_line-data.country
        chr(9)   buf_temp_line-data.GTD
        chr(10)
    .
end.
end procedure.
procedure facturxl-write-line-data-corr :
define input parameter p-Name          as character        no-undo.
define input parameter p-pokazately    as character        no-undo.
define input parameter p-UAES          as character        no-undo.
define input parameter p-OKEI          as character        no-undo.
define input parameter p-EI            as character        no-undo.
define input parameter p-qnty          as character        no-undo.
define input parameter p-price         as character        no-undo.
define input parameter p-SumNoVAT      as character        no-undo.
define input parameter p-SumActciz     as character        no-undo.
define input parameter p-VATpc         as character        no-undo.
define input parameter p-VATsum        as character        no-undo.
define input parameter p-sum           as character        no-undo.
    define buffer buf_temp_line-data        for temp_line-data.
do
for buf_temp_line-data
on error undo, return error
:
    for each buf_temp_line-data
    :
        delete buf_temp_line-data.
    end.
    create buf_temp_line-data.
    assign
        v-facturxl-current-data-row = v-facturxl-current-data-row + 1
    .
    assign
        buf_temp_line-data.data-key     = "LD":U
        buf_temp_line-data.xl-line-id   = v-facturxl-current-data-row
        buf_temp_line-data.Name         = p-Name
        buf_temp_line-data.pokazately   = p-pokazately
        buf_temp_line-data.UAES         = p-UAES
        buf_temp_line-data.OKEI         = p-OKEI
        buf_temp_line-data.EI           = p-EI
        buf_temp_line-data.qnty         = p-qnty
        buf_temp_line-data.price        = p-price
        buf_temp_line-data.SumNoVAT     = p-SumNoVAT
        buf_temp_line-data.SumActciz    = p-SumActciz
        buf_temp_line-data.VATpc        = p-VATpc
        buf_temp_line-data.VATsum       = p-VATsum
        buf_temp_line-data.sum          = p-sum
    .
    put stream excel-line unformatted
                        buf_temp_line-data.data-key
        chr(9)   buf_temp_line-data.Name
        chr(9)   buf_temp_line-data.pokazately
        chr(9)   buf_temp_line-data.UAES
        chr(9)   buf_temp_line-data.OKEI
        chr(9)   buf_temp_line-data.EI
        chr(9)   buf_temp_line-data.qnty
        chr(9)   buf_temp_line-data.price
        chr(9)   buf_temp_line-data.SumNoVAT
        chr(9)   buf_temp_line-data.SumActciz
        chr(9)   buf_temp_line-data.VATpc
        chr(9)   buf_temp_line-data.VATsum
        chr(9)   buf_temp_line-data.sum
        chr(10)
    .
end.
end procedure.
procedure facturxl-run-excel :
define input parameter p-header-filename    as character        no-undo.
define input parameter p-data-filename      as character        no-undo.
    define variable v-template-file-name    as character    no-undo.
    define variable v-vb-file-name          as character    no-undo.
    define buffer buf_temp-param for temp-param .
do
for buf_temp-param
on error undo, return error
:
    create buf_temp-param.
    assign
        v-template-file-name    = search( "exe/sf_97.xlt" )
        v-vb-file-name          = search( "exe/t_97.bas")
    .
    if v-template-file-name = ?
    or v-template-file-name = "":U
    then do:
        message
            "Ошибка имени файла шаблона."
        view-as alert-box error.
    end.
    if v-vb-file-name = ?
    or v-vb-file-name = "":U
    then do:
        message
            "Ошибка имени файла кода обработки."
        view-as alert-box error.
    end.
    run paramls-write in this-procedure (
          input "template":U
        , input "template-file-name":U
        , input v-template-file-name
    ).
    run paramls-write in this-procedure (
          input "template":U
        , input "vb-file-name":U
        , input v-vb-file-name
    ).
    run paramls-write in this-procedure (
          input "data":U
        , input "data-header-filename":U
        , input p-header-filename
    ).
    run paramls-write in this-procedure (
          input "data":U
        , input "data-filename":U
        , input p-data-filename
    ).
    run gbl/macroxlt.p (
        input-output table buf_temp-param
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка создания файла Excel."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
end.
end procedure.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxp-doc-prt         like ub.store.doc-prt         no-undo.
  define variable v-cntxp-price-calc      like ub.store.price-calc      no-undo.
  define variable v-cntxp-inout-price     like ub.store.inout-price     no-undo.
  define variable v-cntxp-unit-cli-perm   like ub.store.unit-cli-perm   no-undo.
  define variable v-cntxp-out-rate        like ub.store.out-rate        no-undo.
  define variable v-cntxp-out-line-discnt like ub.store.out-line-discnt no-undo.
  define variable v-cntxp-in-ov           like ub.store.in-ov           no-undo.
  define variable v-cntxp-in-perm         like ub.store.in-perm         no-undo.
  define variable v-cntxp-no-eq           like ub.store.no-eq           no-undo.
  define variable v-cntxp-rsrv-time       like ub.store.rsrv-time       no-undo.
  define variable v-cntxp-load-time       like ub.store.load-time       no-undo.
  define variable v-cntxp-holidays        like ub.store.holidays        no-undo.
  define variable v-cntxp-in-pay          like ub.store.in-pay          no-undo.
  define variable v-cntxp-out-pay         like ub.store.out-pay         no-undo.
  define variable v-cntxp-ret-pay         like ub.store.ret-pay         no-undo.
  define variable v-cntxp-ret-sup-pay     like ub.store.ret-sup-pay     no-undo.
  define variable v-cntxp-down-pay        like ub.store.down-pay        no-undo.
  define variable v-cntxp-inv-pay         like ub.store.inv-pay         no-undo.
  define variable v-cntxp-chk-pay         like ub.store.chk-pay         no-undo.
  define variable v-cntxp-retail          like ub.sysconf.ord-prt       no-undo.
  define variable v-cntxp-osn-base        like ub.sysconf.osn-base      no-undo.
  define variable v-cntxp-conf-par        as   character                no-undo.
  define variable v-cntxp-par-type        as   character                no-undo.
  define variable v-cntxp-curr-host-code  like ub.store.host-code       no-undo.
  define variable v-cntxp-obj-type        like ub.clients.obj-type      no-undo.
  define variable v-cntxp-obj-code        like ub.clients.obj-code      no-undo.
  define variable v-cntxp-db-num          as integer   no-undo .
  define variable v-cntxp-userid          as character no-undo .
  define variable v-cntxp-level           as character no-undo .
  define variable v-cntxp-db-num-obj      as integer   no-undo .
  define variable v-cntxp-is-admin        as logical   no-undo .
  define buffer bf-cntxp_store for ub.store.
  define buffer bf-cntxp_shop  for ub.shop.
  define buffer bf-cntxp_sysconf for ub.sysconf.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in p-mainmenu-handle
    (output v-cntxp-db-num
    ,output v-cntxp-userid
    ,output v-cntxp-level
    ,output v-cntxp-curr-host-code
    ,output v-cntxp-obj-type
    ,output v-cntxp-obj-code
    ,output v-cntxp-db-num-obj
    ,output v-cntxp-is-admin
    ) .
  if (v-cntxp-obj-type = 'маг':U or v-cntxp-obj-type = 'скл':U) and
     v-cntxp-obj-code <> 0 then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-prt'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  yes
  ,output v-cntxp-conf-par
  ,output v-cntxp-par-type
  ) no-error .
    case v-cntxp-obj-type :
      when 'скл':U then do:
        find first bf-cntxp_store where bf-cntxp_store.obj-code = v-cntxp-obj-code no-lock.
        find first bf-cntxp_sysconf where bf-cntxp_sysconf.host-code = bf-cntxp_store.host-code no-lock.
        assign
          v-cntxp-doc-prt         = (v-cntxp-conf-par = "yes") and bf-cntxp_store.doc-prt
          v-cntxp-price-calc      = bf-cntxp_store.price-calc
          v-cntxp-inout-price     = bf-cntxp_store.inout-price
          v-cntxp-unit-cli-perm   = bf-cntxp_store.unit-cli-perm
          v-cntxp-out-rate        = bf-cntxp_store.out-rate
          v-cntxp-out-line-discnt = bf-cntxp_store.out-line-discnt
          v-cntxp-in-ov           = bf-cntxp_store.in-ov
          v-cntxp-in-perm         = bf-cntxp_store.in-perm
          v-cntxp-no-eq           = bf-cntxp_store.no-eq
          v-cntxp-rsrv-time       = bf-cntxp_store.rsrv-time
          v-cntxp-load-time       = bf-cntxp_store.load-time
          v-cntxp-holidays        = bf-cntxp_store.holidays
          v-cntxp-in-pay          = bf-cntxp_store.in-pay
          v-cntxp-out-pay         = bf-cntxp_store.out-pay
          v-cntxp-ret-pay         = bf-cntxp_store.ret-pay
          v-cntxp-ret-sup-pay     = bf-cntxp_store.ret-sup-pay
          v-cntxp-down-pay        = bf-cntxp_store.down-pay
          v-cntxp-inv-pay         = bf-cntxp_store.inv-pay
          v-cntxp-chk-pay         = bf-cntxp_store.chk-pay
          v-cntxp-retail          = bf-cntxp_sysconf.ord-prt
          v-cntxp-osn-base        = bf-cntxp_sysconf.osn-base
          .
      end.
      when 'маг':U then do:
        find first bf-cntxp_shop where bf-cntxp_shop.obj-code = v-cntxp-obj-code no-lock.
        find first bf-cntxp_sysconf where bf-cntxp_sysconf.host-code = bf-cntxp_shop.host-code no-lock.
        assign
          v-cntxp-doc-prt         = (v-cntxp-conf-par = "yes") and bf-cntxp_shop.doc-prt
          v-cntxp-price-calc      = bf-cntxp_shop.price-calc
          v-cntxp-inout-price     = bf-cntxp_shop.inout-price
          v-cntxp-unit-cli-perm   = bf-cntxp_shop.unit-cli-perm
          v-cntxp-out-rate        = bf-cntxp_shop.out-rate
          v-cntxp-out-line-discnt = bf-cntxp_shop.out-line-discnt
          v-cntxp-in-ov           = bf-cntxp_shop.in-ov
          v-cntxp-in-perm         = bf-cntxp_shop.in-perm
          v-cntxp-no-eq           = bf-cntxp_shop.no-eq
          v-cntxp-rsrv-time       = bf-cntxp_shop.rsrv-time
          v-cntxp-load-time       = bf-cntxp_shop.load-time
          v-cntxp-holidays        = bf-cntxp_shop.holidays
          v-cntxp-in-pay          = bf-cntxp_shop.in-pay
          v-cntxp-out-pay         = bf-cntxp_shop.out-pay
          v-cntxp-ret-pay         = bf-cntxp_shop.ret-pay
          v-cntxp-ret-sup-pay     = bf-cntxp_shop.ret-sup-pay
          v-cntxp-down-pay        = bf-cntxp_shop.down-pay
          v-cntxp-inv-pay         = bf-cntxp_shop.inv-pay
          v-cntxp-chk-pay         = bf-cntxp_shop.chk-pay
          v-cntxp-retail          = bf-cntxp_sysconf.ord-prt
          v-cntxp-osn-base        = bf-cntxp_sysconf.osn-base
          .
      end.
    end case.
  end.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in p-mainmenu-handle
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
run get-report-num in p-mainmenu-handle ( output g#report-num ).
run get-quest-print in p-mainmenu-handle ( output g#quest-print ).
define variable v-torgconf-doc-code             as character    no-undo.
define variable v-torgconf-doc-date             as character    no-undo.
define stream Out-stream .
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) .
    output close.
    output to value( string( session:temp-directory + "rpt" + string( g#report-num ) ) + ".txl" ) .
    output close.
define variable str                     as character            no-undo.
define variable gds-str                 as character            no-undo.
define variable gds-str1                as character            no-undo.
define variable gds-str2                as character            no-undo.
define variable v-lines-counter         as integer              no-undo.
define variable v-tot-sum               as decimal              no-undo.
define variable v-tot-VAT               as decimal              no-undo.
define variable v-tot-sum-no-VAT        as decimal              no-undo.
define variable sym1 as char init ":" no-undo.
define variable sym2 as char init ":" no-undo.
define variable sym3 as char init ":" no-undo.
define variable sym4 as char init ":" no-undo.
define variable sym5 as char init ":" no-undo.
define variable sym6 as char init ":" no-undo.
define variable sym7 as char init ":" no-undo.
define variable sym8 as char init ":" no-undo.
define variable sym9 as char init ":" no-undo.
define variable sym10 as char init ":" no-undo.
define variable sym11 as char init ":" no-undo.
define variable sym12 as char init ":" no-undo.
define variable sym13 as char init ":" no-undo.
define variable v-single-line    as character            no-undo.
define variable v-propis         as character            no-undo.
define variable v-propis-cop     as character            no-undo.
define buffer buf_schet-fact-doc        for schet-fact-doc .
define buffer buf_schet-fact-line       for schet-fact-line .
      define frame factur
        sym1 column-label ":!:" format "X(1)" space(0)
        buf_schet-fact-line.gds-name    column-label "Наименование товара! ":C59 format "X(59)" space(0)
        sym2 column-label ":!:" format "X(1)" space(0)
        buf_schet-fact-line.unit-base   column-label "Ед.!изм." format "X(4)" space(0)
        sym3 column-label ":!:" format "X(1)" space(0)
        buf_schet-fact-line.fact-qnty   column-label "Количество ! " format ">>>>>>9.<<<" space(0)
        sym4 column-label ":!:" format "X(1)" space(0)
        buf_schet-fact-line.price-rubl  column-label "Цена!за ед.изм.":C12 format "->>>>>>>9.99" space(0)
        sym5 column-label ":!:" format "X(1)" space(0)
        buf_schet-fact-line.sum-rubl column-label "Стоимость товаров!всего без налога":C17 format "->>>>>>>>>>>>9.99" space(0)
        sym6 column-label ":!:" format "X(1)" space(0)
        buf_schet-fact-line.excise column-label "в т.ч.!акциз":C9 format ">>>>>9.99" space(0)
        sym7 column-label ":!:" format "X(1)" space(0)
        buf_schet-fact-line.Vat-pc column-label "Ставка!налога":C6 format ">9.9<%" space(0)
        sym8 column-label ":!:" format "X(1)" space(0)
        buf_schet-fact-line.VAT-rubl column-label "Сумма!налога":C12 format "->>>>>>>9.99" space(0)
        sym9 column-label ":!:" format "X(1)" space(0)
        buf_schet-fact-line.sum-rubl-VAT column-label "Ст-ть товаров!с учетом налога":c15 format "->>>>>>>>>>9.99" space(0)
        sym11 column-label ":!:" format "X(1)" space(0)
        buf_schet-fact-line.country column-label "Страна!происхождения":C15 format "X(15)" space(0)
        sym12 column-label ":!:" format "X(1)" space(0)
        buf_schet-fact-line.gtd column-label "Номер грузовой таможенной!декларации":C26 format "X(26)" space(0)
        sym13 column-label ":!:" format "X(1)" space(0)
     header
        ( if PAGE-NUMBER( Out-stream ) > 1
          then string( "Документ N: " + v-torgconf-doc-code + " от " + v-torgconf-doc-date )
          else "":U )                                                       at 40 format "X(50)"
        string( "Страница " + string( PAGE-NUMBER( Out-stream ), ">>9" ) )  at 180 format "X(13)" skip
        v-single-line format "X(198)" at 1
     with width 235 down stream-io.
if session :set-wait-state( "compiler" ) then.
  find first buf_schet-fact-doc no-lock where recid( buf_schet-fact-doc ) = rec_id .
  assign
    v-torgconf-doc-code = buf_schet-fact-doc.doc-code
    v-torgconf-doc-date = string(buf_schet-fact-doc.doc-date,"99/99/9999")
  .
  assign
    v-single-line   = fill("-", 198)
    v-lines-counter = 1
  .
output stream Out-stream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(43) .
  run facturxl-init in this-procedure .
  run print-header in this-procedure .
  form header
    v-single-line format "X(198)" at 1 skip  "Продолжение - на следующей странице" at 30 skip
    with frame Bottomframe width 235 page-bottom no-labels no-box .
  view stream Out-stream frame Bottomframe .
  form with frame factur .
  for each buf_schet-fact-line no-lock  where buf_schet-fact-line.doc-code = buf_schet-fact-doc.doc-code
  break by buf_schet-fact-line.line-num
  :
    run print-line in this-procedure .
  end.
  put stream Out-stream  v-single-line format "X(198)"   .
  if line-counter( Out-stream ) + 7 > page-size( Out-stream ) then  page stream Out-stream.
  run facturxl-write-cell-data in this-procedure ( input "it_SumNoVAT":U , input string( v-tot-sum-no-VAT ) ).
  run facturxl-write-cell-data in this-procedure ( input "it_VATsum":U   , input string( v-tot-VAT ) ).
  run facturxl-write-cell-data in this-procedure ( input "it_sum":U      , input string( v-tot-sum ) ).
  run rep/wp-rub.p ( input v-tot-sum , output v-propis, output v-propis-cop ).
  down stream Out-stream with frame factur .
  put stream Out-stream  skip  ": Всего к оплате  " v-propis format "X(107)"
    ":"   v-tot-VAT format ">>>>>>>>9.99"
    ":"   v-tot-sum format ">>>>>>>>>>>9.99"
    ":               :                          :"
  .
  put stream Out-stream v-single-line format "X(198)" at 1 .
    put stream Out-stream
        skip
        space(5) "Руководитель предприятия" format "X(50)" "/ " fill( "_", 36 ) format "X(36)" " /"
        "     Гл. бухгалтер" format "X(50)" "/ " fill( "_", 36 ) format "X(36)" " /"
    .
  put stream Out-stream
        skip  space(10) "М.П." format "X(5)"
        skip  space(5) "Выдал" format "X(50)" skip
  .
  run facturxl-close in this-procedure .
  hide stream Out-stream frame Bottomframe .
  output stream Out-stream close.
if session :set-wait-state( "" ) then.
  define variable v-user-action as character no-undo .
  define variable v-printed as logical   no-undo .
  os-delete value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" ) .
  os-rename
      value(  string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
      value(  string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )
  .
  run gbl/prnfilen.w
    (input  ""
    ,input  8
    ,input  string(session :temp-directory) + "rpt" + string( g#report-num )
    ,input  7
    ,output v-user-action
    ,output v-printed
    ) .
  os-delete value( string( session:temp-directory ) +  "$" + string( g#report-num ) + ".txl" ) .
  os-delete value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" ) .
end.
procedure print-more:
  do on error undo, return error :
    def var v-start-string as character no-undo.
    def var v-add-string as character no-undo.
    assign v-start-string = gds-str2 .
    do while trim(v-start-string) <> "" :
      assign gds-str = v-start-string.
      v-add-string = breakstr(gds-str, 59, input-output v-add-string, input-output v-start-string).
      display stream Out-stream
        sym1 fill(" ",17) + v-add-string @ buf_schet-fact-line.gds-name sym2 sym3 sym4 sym5 sym6 sym7 sym8  sym9  sym11 sym12 sym13
      with frame factur .
      down stream Out-stream 1 with frame factur .
    end.
  end.
end procedure.
procedure print-line :
  do on error undo, return error :
    display stream Out-stream
      sym1  buf_schet-fact-line.gds-name
      sym2  buf_schet-fact-line.unit-base
      sym3  buf_schet-fact-line.fact-qnty
      sym4  buf_schet-fact-line.price-rubl
      sym5  buf_schet-fact-line.sum-rubl
      sym6  buf_schet-fact-line.excise
      sym7  buf_schet-fact-line.Vat-pc
      sym8  buf_schet-fact-line.VAT-rubl
      sym9  buf_schet-fact-line.sum-rubl-VAT
      sym11 buf_schet-fact-line.country
      sym12 buf_schet-fact-line.GTD
      sym13
    with frame factur .
    down stream Out-stream 1 with frame factur .
    run facturxl-write-line-data in this-procedure (
        input buf_schet-fact-line.gds-name
      , input buf_schet-fact-line.unit-base
      , input buf_schet-fact-line.fact-qnty
      , input buf_schet-fact-line.price-rubl
      , input buf_schet-fact-line.sum-rubl
      , input buf_schet-fact-line.excise
      , input buf_schet-fact-line.Vat-pc
      , input buf_schet-fact-line.VAT-rubl
      , input buf_schet-fact-line.sum-rubl-VAT
      , input buf_schet-fact-line.country
      , input buf_schet-fact-line.GTD
    ).
    assign
      v-tot-sum-no-VAT  = v-tot-sum-no-VAT + buf_schet-fact-line.sum-rubl
      v-tot-VAT         = v-tot-VAT        + buf_schet-fact-line.VAT-rubl
      v-tot-sum         = v-tot-sum        + buf_schet-fact-line.sum-rubl-VAT
      v-lines-counter   = v-lines-counter + 1
    .
  end.
end procedure.
procedure print-header :
  define variable v-print-doc      as character           no-undo.
  define variable v-par-type       as character           no-undo.
  define variable t-num            as character           no-undo.
  define variable v-plat-rasch-doc as character    no-undo.
  define variable v-rubl-name      as character    no-undo.
define buffer buf_currency for ub.currency.
assign v-plat-rasch-doc    = "":U  .
 do on error undo, return error :
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input v-cntxt-obj-type
  ,input v-cntxt-obj-code
  ,input 'prt-firm':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
    for each thbjattr_thbj-attr :
        if thbjattr_thbj-attr.prop-code = 'factur01' then v-print-doc =  string(thbjattr_thbj-attr.property-value-logical) .
    end.
    if v-print-doc <> 'yes'  then assign v-print-doc = "no"  .
    assign  t-num = substitute( "&1         от &2 &3" , v-torgconf-doc-code , v-torgconf-doc-date
           , ( if buf_schet-fact-doc.status_ <> 'факт':U then string( "(" + caps( buf_schet-fact-doc.status_ ) + ")" ) else "":U ) )
    .
    assign v-plat-rasch-doc = buf_schet-fact-doc.in-doc-code + " от " + string(buf_schet-fact-doc.in-doc-date, "99/99/9999") .
find first buf_currency no-lock
         where buf_currency.curr-code = 0
    .
    assign
        v-rubl-name = buf_currency.curr-name
    .
put stream Out-stream
                space(25) string( "СЧЕТ-ФАКТУРА N " +  t-num ) format "X(190)"
        skip(1) space(5) string( "Продавец " + fill( " ", 31 ) + buf_schet-fact-doc.cli-name ) format "X(190)"
        skip    space(5) string( "Адрес "    + fill( " ", 34 ) + buf_schet-fact-doc.cli-address ) format "X(190)"
        skip    space(5) string( "Идентификационный номер продавца (ИНН/КПП) " + buf_schet-fact-doc.cli-inn + "/" + buf_schet-fact-doc.cli-kpp ) format "X(190)"
        skip    space(5) string( "Грузоотправитель и его адрес " + fill( " ", 10 ) + buf_schet-fact-doc.Gruz-otprav ) format "X(190)"
        skip    space(5) string( "Грузополучатель и его адрес" + fill( " ", 12 ) + buf_schet-fact-doc.Gruz-poluch )   format "X(190)"
        skip    space(5) string( "К платежно-расчетному документу        " + v-plat-rasch-doc ) format "X(190)"
        skip(1) space(5) string( "Покупатель" + fill( " ", 29 ) + buf_schet-fact-doc.own-name ) format "X(190)"
        skip    space(5) string( "Адрес" + fill( " ", 34 ) + buf_schet-fact-doc.own-address ) format "X(190)"
        skip    space(5) string( "Идентификационный номер покупателя (ИНН/КПП)" + buf_schet-fact-doc.own-inn + "/" + buf_schet-fact-doc.own-kpp ) format "X(190)"
        skip    space(5) string( "Валюта : " + v-rubl-name ) format "X(190)"
        skip
    .
    run facturxl-write-cell-data in this-procedure ( input "h_docCode":U , input v-torgconf-doc-code ).
    run facturxl-write-cell-data in this-procedure ( input "h_docDate":U , input v-torgconf-doc-date ).
    run facturxl-write-cell-data in this-procedure ( input "h_supplier":U , input buf_schet-fact-doc.cli-name ).
    run facturxl-write-cell-data in this-procedure ( input "h_supplierAddr":U , input buf_schet-fact-doc.cli-address ).
    run facturxl-write-cell-data in this-procedure ( input "h_supplierINN":U , input buf_schet-fact-doc.cli-inn + "/" + buf_schet-fact-doc.cli-kpp ).
    run facturxl-write-cell-data in this-procedure ( input "h_cargoFrom":U , input buf_schet-fact-doc.Gruz-otprav ).
    run facturxl-write-cell-data in this-procedure ( input "h_cargoTo":U , input buf_schet-fact-doc.Gruz-poluch ).
    run facturxl-write-cell-data in this-procedure ( input "h_platDoc":U , input v-plat-rasch-doc ).
    run facturxl-write-cell-data in this-procedure ( input "h_saler":U   , input buf_schet-fact-doc.own-name ).
    run facturxl-write-cell-data in this-procedure ( input "h_salerAddr":U , input buf_schet-fact-doc.own-address ).
    run facturxl-write-cell-data in this-procedure ( input "h_salerINN":U , input buf_schet-fact-doc.own-inn + "/" + buf_schet-fact-doc.own-kpp ).
    run facturxl-write-cell-data in this-procedure ( input "h_currency":U , input v-rubl-name ).
end.
end procedure.
