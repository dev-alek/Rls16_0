block-level on error undo, throw.
using ibs.th.gbl.gbl-hndllib from propath.
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Библиотека процедур для работы с атрибутами документа":U.
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
if valid-handle( g#trdcalib ) and g#trdcalib <> this-procedure :handle then do:
  message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 0 ) vss-description skip( 1 )
          "trdcalib.p: попытка повторной загрузки библиотеки" skip( 1 )
          g#trdcalib                     skip( 0 )
          g#trdcalib     :type           skip( 0 )
          g#trdcalib     :file-name      skip( 0 )
          valid-handle( g#trdcalib     ) skip( 0 )
          this-procedure :handle         skip( 0 )
          this-procedure :type           skip( 0 )
          this-procedure :file-name      skip( 0 )
          valid-handle( this-procedure ) skip( 0 )
  view-as alert-box error title " О Ш И Б К А  ! ! ! ".
  undo, return error "trdcalib.p: попытка повторной загрузки библиотеки".
end.
else do:
  assign
    g#trdcalib = this-procedure :handle
  .
  def var gbl-hndllibObj as class gbl-hndllib no-undo.
  gbl-hndllibObj = new gbl-hndllib ().
  gbl-hndllibObj:InitHndl("g#trdcalib", g#trdcalib).
  delete object gbl-hndllibObj.
end.
on delete of this-procedure do:
  assign
    g#trdcalib = ?
  .
  def var gbl-hndllibObj as class gbl-hndllib no-undo.
  gbl-hndllibObj = new gbl-hndllib ().
  gbl-hndllibObj:InitHndl("g#trdcalib", g#trdcalib).
  delete object gbl-hndllibObj.
end.
procedure trdcalib_tdat-val :
  define  input parameter p-doc-code like ub.doc-attr.doc-code   no-undo.
  define  input parameter p-code     like ub.doc-attr.attr-code  no-undo.
  define output parameter p-value    like ub.doc-attr.attr-value no-undo.
  define output parameter p-type     as   character              no-undo.
  define buffer buf_doc-attr for ub.doc-attr.
  define variable v-format         as character no-undo.
  define variable v-fillin_width   as integer   no-undo.
  define variable v-fillin_height  as integer   no-undo.
  define variable v-label          as character no-undo.
  define variable v-user-can-edit  as logical   no-undo.
  define variable v-output-display as logical   no-undo.
  define variable v-other          as character no-undo.
  define variable v-proc-attr       as character no-undo .
  define variable v-full-screen-val as character no-undo .
  define variable v-sort as integer   no-undo .
  do on error undo, return error return-value :
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input p-code ,
                       output p-type ,
                       output v-format ,
                       output v-fillin_width ,
                       output v-fillin_height ,
                       output v-label ,
                       output v-user-can-edit ,
                       output v-output-display ,
                       output v-other  ,
                       output v-proc-attr ,
                       output v-full-screen-val ,
                       output v-sort
                       ) no-error .
    if error-status :error then do: undo, return error return-value. end.
    find first buf_doc-attr no-lock where
               buf_doc-attr.doc-code  = p-doc-code and
               buf_doc-attr.attr-code = p-code     no-error.
    assign p-value = ( if available buf_doc-attr then buf_doc-attr.attr-value else
                     ( if p-type = 'L':U then "no":U else "":U ) ).
  end.
end procedure.
procedure trdcalib_tdatinv-val :
  define  input parameter p-doc-code like ub.inv-doc-attr.doc-code   no-undo.
  define  input parameter p-code     like ub.inv-doc-attr.attr-code  no-undo.
  define output parameter p-value    like ub.inv-doc-attr.attr-value no-undo.
  define output parameter p-type     as   character              no-undo.
  define buffer buf_doc-attr for ub.inv-doc-attr.
  define variable v-format         as character no-undo.
  define variable v-fillin_width   as integer   no-undo.
  define variable v-fillin_height  as integer   no-undo.
  define variable v-label          as character no-undo.
  define variable v-user-can-edit  as logical   no-undo.
  define variable v-output-display as logical   no-undo.
  define variable v-other          as character no-undo.
  define variable v-proc-attr       as character no-undo .
  define variable v-full-screen-val as character no-undo .
  define variable v-sort as integer   no-undo .
  do on error undo, return error return-value :
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-cod in g#trdcalib (  input p-code ,
                       output p-type ,
                       output v-format ,
                       output v-fillin_width ,
                       output v-fillin_height ,
                       output v-label ,
                       output v-user-can-edit ,
                       output v-output-display ,
                       output v-other  ,
                       output v-proc-attr ,
                       output v-full-screen-val ,
                       output v-sort
                       ) no-error .
    if error-status :error then do: undo, return error return-value. end.
    find first buf_doc-attr no-lock where
               buf_doc-attr.doc-code  = p-doc-code and
               buf_doc-attr.attr-code = p-code     no-error.
    assign p-value = ( if available buf_doc-attr then buf_doc-attr.attr-value else
                     ( if p-type = 'L':U then "no":U else "":U ) ).
  end.
end procedure.
procedure trdcalib_tdat-wrt :
  define input parameter p-doc-code like ub.doc-attr.doc-code   no-undo.
  define input parameter p-code     like ub.doc-attr.attr-code  no-undo.
  define input parameter p-value    like ub.doc-attr.attr-value no-undo.
  define buffer buf_doc-attr for ub.doc-attr.
  define variable v-proc-attr       as character no-undo .
  define variable v-full-screen-val as character no-undo .
  define variable v-type           as character no-undo.
  define variable v-format         as character no-undo.
  define variable v-fillin_width   as integer   no-undo.
  define variable v-fillin_height  as integer   no-undo.
  define variable v-label          as character no-undo.
  define variable v-user-can-edit  as logical   no-undo.
  define variable v-output-display as logical   no-undo.
  define variable v-other          as character no-undo.
  define variable v-sort           as integer   no-undo .
  do on error undo, return error return-value :
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input p-code ,
                       output v-type ,
                       output v-format ,
                       output v-fillin_width ,
                       output v-fillin_height ,
                       output v-label ,
                       output v-user-can-edit ,
                       output v-output-display ,
                       output v-other  ,
                       output v-proc-attr ,
                       output v-full-screen-val ,
                       output v-sort
                       ) no-error .
    if error-status :error then do: undo, return error return-value. end.
    find first buf_doc-attr exclusive-lock where
               buf_doc-attr.doc-code  = p-doc-code and
               buf_doc-attr.attr-code = p-code     no-error.
    if not available buf_doc-attr then do:
      create buf_doc-attr.
      assign buf_doc-attr.doc-code  = p-doc-code
             buf_doc-attr.attr-code = p-code.
    end.
    assign buf_doc-attr.attr-value = p-value.
  end.
end procedure.
procedure trdcalib_tdatinv-wrt :
  define input parameter p-doc-code like ub.inv-doc-attr.doc-code   no-undo.
  define input parameter p-code     like ub.inv-doc-attr.attr-code  no-undo.
  define input parameter p-value    like ub.inv-doc-attr.attr-value no-undo.
  define buffer buf_doc-attr for ub.inv-doc-attr.
  define variable v-proc-attr       as character no-undo .
  define variable v-full-screen-val as character no-undo .
  define variable v-type           as character no-undo.
  define variable v-format         as character no-undo.
  define variable v-fillin_width   as integer   no-undo.
  define variable v-fillin_height  as integer   no-undo.
  define variable v-label          as character no-undo.
  define variable v-user-can-edit  as logical   no-undo.
  define variable v-output-display as logical   no-undo.
  define variable v-other          as character no-undo.
  define variable v-sort           as integer   no-undo .
  do on error undo, return error return-value :
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input p-code ,
                       output v-type ,
                       output v-format ,
                       output v-fillin_width ,
                       output v-fillin_height ,
                       output v-label ,
                       output v-user-can-edit ,
                       output v-output-display ,
                       output v-other  ,
                       output v-proc-attr ,
                       output v-full-screen-val ,
                       output v-sort
                       ) no-error .
    if error-status :error then do: undo, return error return-value. end.
    find first buf_doc-attr exclusive-lock where
               buf_doc-attr.doc-code  = p-doc-code and
               buf_doc-attr.attr-code = p-code     no-error.
    if not available buf_doc-attr then do:
      create buf_doc-attr.
      assign buf_doc-attr.doc-code  = p-doc-code
             buf_doc-attr.attr-code = p-code.
    end.
    assign buf_doc-attr.attr-value = p-value.
  end.
end procedure.
procedure trdcalib_tdat-xst :
  define  input parameter p-doc-code like ub.doc-attr.doc-code  no-undo.
  define  input parameter p-code     like ub.doc-attr.attr-code no-undo.
  define output parameter p-exist    as   logical               no-undo.
  define buffer buf_doc-attr for ub.doc-attr.
  define variable v-type           as character no-undo.
  define variable v-format         as character no-undo.
  define variable v-fillin_width   as integer   no-undo.
  define variable v-fillin_height  as integer   no-undo.
  define variable v-label          as character no-undo.
  define variable v-user-can-edit  as logical   no-undo.
  define variable v-output-display as logical   no-undo.
  define variable v-other          as character no-undo.
  define variable v-proc-attr       as character no-undo .
  define variable v-full-screen-val as character no-undo .
  define variable v-sort as integer   no-undo .
  do on error undo, return error return-value :
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input p-code ,
                       output v-type ,
                       output v-format ,
                       output v-fillin_width ,
                       output v-fillin_height ,
                       output v-label ,
                       output v-user-can-edit ,
                       output v-output-display ,
                       output v-other  ,
                       output v-proc-attr ,
                       output v-full-screen-val ,
                       output v-sort
                       ) no-error .
    if error-status :error then do: undo, return error return-value. end.
    find first buf_doc-attr no-lock where
               buf_doc-attr.doc-code  = p-doc-code and
               buf_doc-attr.attr-code = p-code     no-error.
    if available buf_doc-attr then do: p-exist = yes. end.
  end.
end procedure.
procedure trdcalib_tdat-del :
  define  input parameter p-doc-code like ub.doc-attr.doc-code  no-undo.
  define  input parameter p-code     like ub.doc-attr.attr-code no-undo.
  define output parameter p-deleted  as   logical               no-undo.
  define buffer buf_doc-attr for ub.doc-attr.
  define variable v-type           as character no-undo.
  define variable v-format         as character no-undo.
  define variable v-fillin_width   as integer   no-undo.
  define variable v-fillin_height  as integer   no-undo.
  define variable v-label          as character no-undo.
  define variable v-user-can-edit  as logical   no-undo.
  define variable v-output-display as logical   no-undo.
  define variable v-other          as character no-undo.
  define variable v-proc-attr       as character no-undo .
  define variable v-full-screen-val as character no-undo .
  define variable v-sort as integer   no-undo .
  do on error undo, return error return-value :
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input p-code ,
                       output v-type ,
                       output v-format ,
                       output v-fillin_width ,
                       output v-fillin_height ,
                       output v-label ,
                       output v-user-can-edit ,
                       output v-output-display ,
                       output v-other  ,
                       output v-proc-attr ,
                       output v-full-screen-val ,
                       output v-sort
                       ) no-error .
    if error-status :error then do: undo, return error return-value. end.
    find first buf_doc-attr exclusive-lock where
               buf_doc-attr.doc-code  = p-doc-code and
               buf_doc-attr.attr-code = p-code     no-error no-wait.
    if not available buf_doc-attr then do:
      assign p-deleted = no.
    end.
    else do:
      delete buf_doc-attr.
      assign p-deleted = yes.
    end.
  end.
end procedure.
procedure trdcalib_tdat-cod :
  define  input parameter p-code           as character no-undo.
  define output parameter p-type           as character no-undo.
  define output parameter p-format         as character no-undo.
  define output parameter p-fillin_width   as integer   no-undo.
  define output parameter p-fillin_height  as integer   no-undo.
  define output parameter p-label          as character no-undo.
  define output parameter p-user-can-edit  as logical   no-undo.
  define output parameter p-output-display as logical   no-undo.
  define output parameter p-other          as character no-undo.
  define output parameter p-proc-attr       as character no-undo.
  define output parameter p-full-screen-val as character no-undo.
  define output parameter p-sort as integer   no-undo .
  do on error undo, return error return-value :
    case p-code :
            when 'hold-part-code':U then do:     assign p-label          = "Номер партии для документа межфирменного перемещения"            p-type           = 'I':U             p-format         = "->>>,>>>,>>9"            p-fillin_width   = 12            p-fillin_height  = 1            p-label          = "Номер партии для документа межфирменного перемещения"            p-user-can-edit  = false            p-output-display = false            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when 'dov':U then do:     assign p-label          = "Доверенность"            p-type           = 'C':U             p-format         = "x(255)"            p-fillin_width   = 70            p-fillin_height  = 3            p-label          = "Доверенность"            p-user-can-edit  = true            p-output-display = true            p-sort           = 45            p-proc-attr      = ''            p-other          = '':u . end.
            when 'dids':U then do:     assign p-label          = "Дата приходной накладной поставщика"            p-type           = 'T':U             p-format         = "99/99/9999"            p-fillin_width   = 11            p-fillin_height  = 1            p-label          = "Дата приходной накладной поставщика"            p-user-can-edit  = true            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = 'nws':u . end.
            when 'nids':U then do:     assign p-label          = "Номер приходной накладной поставщика"            p-type           = 'C':U             p-format         = "x(70)"            p-fillin_width   = 71            p-fillin_height  = 1            p-label          = "Номер приходной накладной поставщика"            p-user-can-edit  = true            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = 'nws':u . end.
            when 'negais':U then do:     assign p-label          = "Идентификаторы накладной ЕГАИС"            p-type           = 'C':U             p-format         = "x(70)"            p-fillin_width   = 71            p-fillin_height  = 1            p-label          = "Идентификаторы накладной ЕГАИС"            p-user-can-edit  = true            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = 'nws':u . end.
            when 'egais':U then do:     assign p-label          = "Статус EGAIS"            p-type           = 'C':U             p-format         = "x(11)"            p-fillin_width   = 10            p-fillin_height  = 1            p-label          = "Статус EGAIS"            p-user-can-edit  = false            p-output-display = false            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when 'ddog':U then do:     assign p-label          = "Договор: Дата"            p-type           = 'T':U             p-format         = "99/99/9999"            p-fillin_width   = 11            p-fillin_height  = 1            p-label          = "Договор: Дата"            p-user-can-edit  = true            p-output-display = true            p-sort           = 30            p-proc-attr      = ''            p-other          = 'nws':u . end.
            when 'ndog':U then do:     assign p-label          = "Договор: Номер"            p-type           = 'C':U             p-format         = "x(70)"            p-fillin_width   = 71            p-fillin_height  = 1            p-label          = "Договор: Номер"            p-user-can-edit  = true            p-output-display = true            p-sort           = 40            p-proc-attr      = ''            p-other          = 'nws':u . end.
            when 'dsf':U then do:     assign p-label          = "Счет-фактура поставщика: Дата"            p-type           = 'T':U             p-format         = "99/99/9999"            p-fillin_width   = 11            p-fillin_height  = 1            p-label          = "Счет-фактура поставщика: Дата"            p-user-can-edit  = true            p-output-display = true            p-sort           = 70            p-proc-attr      = ''            p-other          = 'nws':u . end.
            when 'nsf':U then do:     assign p-label          = "Счет-фактура поставщика: Номер"            p-type           = 'C':U             p-format         = "x(70)"            p-fillin_width   = 71            p-fillin_height  = 1            p-label          = "Счет-фактура поставщика: Номер"            p-user-can-edit  = true            p-output-display = true            p-sort           = 75            p-proc-attr      = ''            p-other          = 'nws':u . end.
            when 'addsum':U then do:     assign p-label          = "Дополнительные суммы посчитанные по документу"            p-type           = 'C':U             p-format         = "x(70)"            p-fillin_width   = 255            p-fillin_height  = 1            p-label          = "Дополнительные суммы посчитанные по документу"            p-user-can-edit  = false            p-output-display = false            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when 'clcasol':U then do:     assign p-label          = "On-line расчет дополнительных сумм основных и после документа"            p-type           = 'L':U             p-format         = "yes/no"            p-fillin_width   = 3            p-fillin_height  = 1            p-label          = "On-line расчет дополнительных сумм основных и после документа"            p-user-can-edit  = false            p-output-display = false            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when 'clcaswt':U then do:     assign p-label          = "On-line расчет естественной убыли"            p-type           = 'L':U             p-format         = "yes/no"            p-fillin_width   = 3            p-fillin_height  = 1            p-label          = "On-line расчет естественной убыли"            p-user-can-edit  = false            p-output-display = false            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when 'scanfile':U then do:     assign p-label          = "Загруженные в документ сканерные файлы"            p-type           = 'L':U             p-format         = "yes/no"            p-fillin_width   = 3            p-fillin_height  = 1            p-label          = "Загруженные в документ сканерные файлы"            p-user-can-edit  = false            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when 'indoclnsum':U then do:     assign p-label          = "Заводить внешнюю приходную накладную через суммы"            p-type           = 'L':U             p-format         = "yes/no"            p-fillin_width   = 3            p-fillin_height  = 1            p-label          = "Заводить внешнюю приходную накладную через суммы"            p-user-can-edit  = false            p-output-display = false            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when 'purchlimit':U then do:     assign p-label          = "Есть в документе ограничение по типам кодов приобретения для резервирования"            p-type           = 'L':U             p-format         = "yes/no"            p-fillin_width   = 3            p-fillin_height  = 1            p-label          = "Есть в документе ограничение по типам кодов приобретения для резервирования"            p-user-can-edit  = false            p-output-display = false            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when 'purchcodelist':U then do:     assign p-label          = "Список кодов типов приобретения"            p-type           = 'C':U             p-format         = "x(70)"            p-fillin_width   = 3            p-fillin_height  = 1            p-label          = "Список кодов типов приобретения"            p-user-can-edit  = false            p-output-display = false            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when 'expense_own':U then do:     assign p-label          = "Расходы не включаемые в учетную цену"            p-type           = 'D':U             p-format         = "->,>>>,>>>,>>9.999"            p-fillin_width   = 20            p-fillin_height  = 1            p-label          = "Расходы не включаемые в учетную цену"            p-user-can-edit  = true            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = 'nws':u . end.
            when 'envd':U then do:     assign p-label          = "Единый налог на вмененный доход"            p-type           = 'L':U             p-format         = "yes/no"            p-fillin_width   = 4            p-fillin_height  = 1            p-label          = "Единый налог на вмененный доход"            p-user-can-edit  = false            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when '1ord_time':U then do:     assign p-label          = "Время выполнения заказа"            p-type           = 'C':U             p-format         = "99:99"            p-fillin_width   = 6            p-fillin_height  = 1            p-label          = "Время выполнения заказа"            p-user-can-edit  = true            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when '4dchek':U then do:     assign p-label          = "Дата чека предоплаты"            p-type           = 'T':U             p-format         = "99/99/9999"            p-fillin_width   = 11            p-fillin_height  = 1            p-label          = "Дата чека предоплаты"            p-user-can-edit  = true            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when '2befpay':U then do:     assign p-label          = "Сумма предоплаты"            p-type           = 'D':U             p-format         = "->,>>>,>>>,>>>,>>9.99"            p-fillin_width   = 22            p-fillin_height  = 1            p-label          = "Сумма предоплаты"            p-user-can-edit  = true            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when '3ord_Nchek':U then do:     assign p-label          = "№ чека предоплаты"            p-type           = 'C':U             p-format         = "x(70)"            p-fillin_width   = 70            p-fillin_height  = 1            p-label          = "№ чека предоплаты"            p-user-can-edit  = true            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when '5deliv':U then do:     assign p-label          = "Сумма доставки (баз.вал.)"            p-type           = 'D':U             p-format         = "->,>>>,>>>,>>>,>>9.99"            p-fillin_width   = 22            p-fillin_height  = 1            p-label          = "Сумма доставки (баз.вал.)"            p-user-can-edit  = true            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when '6sumwrk':U then do:     assign p-label          = "Наценка за работу,%"            p-type           = 'D':U             p-format         = "->,>>>,>>>,>>>,>>9.99"            p-fillin_width   = 22            p-fillin_height  = 1            p-label          = "Наценка за работу,%"            p-user-can-edit  = true            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when '7sumsrk':U then do:     assign p-label          = "Наценка за срочность,%"            p-type           = 'D':U             p-format         = "->,>>>,>>>,>>>,>>9.99"            p-fillin_width   = 22            p-fillin_height  = 1            p-label          = "Наценка за срочность,%"            p-user-can-edit  = true            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when '8ord_adr':U then do:     assign p-label          = "Адрес доставки"            p-type           = 'C':U             p-format         = "x(255)"            p-fillin_width   = 70            p-fillin_height  = 1            p-label          = "Адрес доставки"            p-user-can-edit  = true            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when '9ord_hwo':U then do:     assign p-label          = "Кому"            p-type           = 'C':U             p-format         = "x(255)"            p-fillin_width   = 70            p-fillin_height  = 1            p-label          = "Кому"            p-user-can-edit  = true            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when 'fbroperator':U then do:     assign p-label          = "Код оператора документа производства"            p-type           = 'I':U             p-format         = "->>>>>>>>9"            p-fillin_width   = 10            p-fillin_height  = 1            p-label          = "Код оператора документа производства"            p-user-can-edit  = false            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when 'fbrauto':U then do:     assign p-label          = "Документ создан автоматически"            p-type           = 'L':U             p-format         = "yes/no"            p-fillin_width   = 4            p-fillin_height  = 1            p-label          = "Документ создан автоматически"            p-user-can-edit  = false            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when 'rsrv-doc-list':U then do:     assign p-label          = "Список документов по которым производилось резервирование"            p-type           = 'C':U             p-format         = "X(40)"            p-fillin_width   = 42            p-fillin_height  = 1            p-label          = "Список документов по которым производилось резервирование"            p-user-can-edit  = false            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when '3postdchek':U then do:     assign p-label          = "Дата чека доплаты"            p-type           = 'T':U             p-format         = "99/99/9999"            p-fillin_width   = 14            p-fillin_height  = 1            p-label          = "Дата чека доплаты"            p-user-can-edit  = true            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = 'nws,postdchek':u . end.
            when '1postpay':U then do:     assign p-label          = "Сумма доплаты"            p-type           = 'D':U             p-format         = "->,>>>,>>>,>>>,>>9.99"            p-fillin_width   = 22            p-fillin_height  = 1            p-label          = "Сумма доплаты"            p-user-can-edit  = true            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = 'nws':u . end.
            when '2postNchek':U then do:     assign p-label          = "№ чека доплаты"            p-type           = 'C':U             p-format         = "x(70)"            p-fillin_width   = 70            p-fillin_height  = 1            p-label          = "№ чека доплаты"            p-user-can-edit  = true            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = 'nws':u . end.
            when '0rsrv-date':U then do:     assign p-label          = "Дата выполнения "            p-type           = 'T':U             p-format         = "99/99/9999"            p-fillin_width   = 11            p-fillin_height  = 1            p-label          = "Дата выполнения "            p-user-can-edit  = true            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = 'rsrv-date':u . end.
            when '21ord_phone':U then do:     assign p-label          = "Контактный телефон"            p-type           = 'C':U             p-format         = "x(255)"            p-fillin_width   = 70            p-fillin_height  = 1            p-label          = "Контактный телефон"            p-user-can-edit  = true            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when '4ord_dl':U then do:     assign p-label          = "Требуется доставка"            p-type           = 'L':U             p-format         = "yes/no"            p-fillin_width   = 3            p-fillin_height  = 1            p-label          = "Требуется доставка"            p-user-can-edit  = true            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when '22ord_contact':U then do:     assign p-label          = "Контактное лицо"            p-type           = 'C':U             p-format         = "x(255)"            p-fillin_width   = 70            p-fillin_height  = 1            p-label          = "Контактное лицо"            p-user-can-edit  = true            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when 'm_inc':U then do:     assign p-label          = "Метод включения транспортных и пр расходов в ПН"            p-type           = 'I':U             p-format         = "99"            p-fillin_width   = 3            p-fillin_height  = 1            p-label          = "Метод включения транспортных и пр расходов в ПН"            p-user-can-edit  = no            p-output-display = no            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when 'QntyPlace':U then do:     assign p-label          = "Количество мест"            p-type           = 'I':U             p-format         = ">>>>>>9"            p-fillin_width   = 9            p-fillin_height  = 1            p-label          = "Количество мест"            p-user-can-edit  = true            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = 'nws':u . end.
            when 'discnt-stop':U then do:     assign p-label          = "Сумма итого со скидкой наценкой и доставкой"            p-type           = 'D':U             p-format         = "->>>>>>>>>>>>9.99"            p-fillin_width   = 3            p-fillin_height  = 1            p-label          = "Сумма итого со скидкой наценкой и доставкой"            p-user-can-edit  = false            p-output-display = false            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when 'discnt-other':U then do:     assign p-label          = "Перерассчитывать скидку по документу удалив доставку "            p-type           = 'L':U             p-format         = "yes/no"            p-fillin_width   = 3            p-fillin_height  = 1            p-label          = "Перерассчитывать скидку по документу удалив доставку "            p-user-can-edit  = false            p-output-display = false            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when 'DFinDoc':U then do:     assign p-label          = "Расчетный документ: Дата"            p-type           = 'T':U             p-format         = "99/99/9999"            p-fillin_width   = 11            p-fillin_height  = 1            p-label          = "Расчетный документ: Дата"            p-user-can-edit  = true            p-output-display = true            p-sort           = 60            p-proc-attr      = ''            p-other          = 'nws':u . end.
            when 'NFinDoc':U then do:     assign p-label          = "Расчетный документ: Номер"            p-type           = 'C':U             p-format         = "x(70)"            p-fillin_width   = 71            p-fillin_height  = 1            p-label          = "Расчетный документ: Номер"            p-user-can-edit  = true            p-output-display = true            p-sort           = 65            p-proc-attr      = ''            p-other          = 'nws':u . end.
            when 'PlaceStorage':U then do:     assign p-label          = "Место хранения "            p-type           = 'C':U             p-format         = "x(255)"            p-fillin_width   = 70            p-fillin_height  = 1            p-label          = "Место хранения "            p-user-can-edit  = true            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = 'nws':u . end.
            when 'Packer':U then do:     assign p-label          = "Упаковщик"            p-type           = 'C':U             p-format         = "x(255)"            p-fillin_width   = 70            p-fillin_height  = 1            p-label          = "Упаковщик"            p-user-can-edit  = true            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = 'nws':u . end.
            when 'Dispath':U then do:     assign p-label          = "Способ отгрузки"            p-type           = 'C':U             p-format         = "x(255)"            p-fillin_width   = 70            p-fillin_height  = 1            p-label          = "Способ отгрузки"            p-user-can-edit  = true            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = 'nws':u . end.
            when 'price-target':U then do:     assign p-label          = "Внутренний расход по цене приемника"            p-type           = 'L':U             p-format         = "yes/no"            p-fillin_width   = 4            p-fillin_height  = 1            p-label          = "Внутренний расход по цене приемника"            p-user-can-edit  = false            p-output-display = false            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when 'edi':U then do:     assign p-label          = "Статус EDI"            p-type           = 'C':U             p-format         = "x(11)"            p-fillin_width   = 10            p-fillin_height  = 1            p-label          = "Статус EDI"            p-user-can-edit  = false            p-output-display = false            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when 'ddov':U then do:     assign p-label          = "Доверенность: Дата"            p-type           = 'T':U             p-format         = "99/99/9999"            p-fillin_width   = 11            p-fillin_height  = 1            p-label          = "Доверенность: Дата"            p-user-can-edit  = true            p-output-display = true            p-sort           = 45            p-proc-attr      = ''            p-other          = 'nws':u . end.
            when 'ndov':U then do:     assign p-label          = "Доверенность: Номер"            p-type           = 'C':U             p-format         = "x(70)"            p-fillin_width   = 71            p-fillin_height  = 1            p-label          = "Доверенность: Номер"            p-user-can-edit  = true            p-output-display = true            p-sort           = 50            p-proc-attr      = ''            p-other          = 'nws':u . end.
            when 'Recipient':U then do:     assign p-label          = "Грузополучатель"            p-type           = 'C':U             p-format         = "x(255)"            p-fillin_width   = 71            p-fillin_height  = 1            p-label          = "Грузополучатель"            p-user-can-edit  = true            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = 'nws':u . p-proc-attr = "win=str/gp-updtr.w,func=funcgrzp"  .  end.
            when 'Shipper':U then do:     assign p-label          = "Грузоотправитель"            p-type           = 'C':U             p-format         = "x(255)"            p-fillin_width   = 71            p-fillin_height  = 1            p-label          = "Грузоотправитель"            p-user-can-edit  = true            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = 'nws':u . p-proc-attr = "win=str/go-updtr.w,func=funcgrzp"  .  end.
            when 'Auto':U then do:     assign p-label          = "Автомобиль: Марка, Номер"            p-type           = 'C':U             p-format         = "x(255)"            p-fillin_width   = 71            p-fillin_height  = 1            p-label          = "Автомобиль: Марка, Номер"            p-user-can-edit  = true            p-output-display = true            p-sort           = 10            p-proc-attr      = ''            p-other          = 'nws':u . p-proc-attr = "win=str/trdcauto.w,func=funcgrzp"  .  end.
            when 'Driver':U then do:     assign p-label          = "Автомобиль: Водитель"            p-type           = 'C':U             p-format         = "x(255)"            p-fillin_width   = 71            p-fillin_height  = 1            p-label          = "Автомобиль: Водитель"            p-user-can-edit  = true            p-output-display = true            p-sort           = 20            p-proc-attr      = ''            p-other          = 'nws':u . end.
            when 'print-num':U then do:     assign p-label          = "Номер документа для печати"            p-type           = 'C':U             p-format         = "X(70)"            p-fillin_width   = 71            p-fillin_height  = 1            p-label          = "Номер документа для печати"            p-user-can-edit  = true            p-output-display = true            p-sort           = 120            p-proc-attr      = ''            p-other          = 'nws':u . end.
            when 'idCountryContr':U then do:     assign p-label          = "Идентификатор государственного контракта"            p-type           = 'C':U             p-format         = "X(70)"            p-fillin_width   = 71            p-fillin_height  = 1            p-label          = "Идентификатор государственного контракта"            p-user-can-edit  = true            p-output-display = true            p-sort           = 120            p-proc-attr      = ''            p-other          = 'nws':u . end.
            when 'olsuppcntr':U then do:     assign p-label          = "Документ пересортицы делается по тем же контрагентам и договорам"            p-type           = 'L':U             p-format         = "yes/no"            p-fillin_width   = 3            p-fillin_height  = 1            p-label          = "Документ пересортицы делается по тем же контрагентам и договорам"            p-user-can-edit  = false            p-output-display = false            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when 'car-time':U then do:     assign p-label          = "Время прихода машины"            p-type           = 'C':U             p-format         = "X(5)"            p-fillin_width   = 71            p-fillin_height  = 1            p-label          = "Время прихода машины"            p-user-can-edit  = true            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = 'nws':u . end.
            when 't_pass-fname':U then do:     assign p-label          = "Сдал /Расшифровка/"            p-type           = 'C':U             p-format         = "X(70)"            p-fillin_width   = 70            p-fillin_height  = 1            p-label          = "Сдал /Расшифровка/"            p-user-can-edit  = true            p-output-display = true            p-sort           = 92            p-proc-attr      = ''            p-other          = 'nws':u . p-proc-attr = "''"  .  end.
            when 't_pass-position':U then do:     assign p-label          = "Сдал /Должность/"            p-type           = 'C':U             p-format         = "X(70)"            p-fillin_width   = 70            p-fillin_height  = 1            p-label          = "Сдал /Должность/"            p-user-can-edit  = true            p-output-display = true            p-sort           = 94            p-proc-attr      = ''            p-other          = 'nws':u . p-proc-attr = "''"  .  end.
            when 't_accept-fname':U then do:     assign p-label          = "Принял /Расшифровка/"            p-type           = 'C':U             p-format         = "X(70)"            p-fillin_width   = 70            p-fillin_height  = 1            p-label          = "Принял /Расшифровка/"            p-user-can-edit  = true            p-output-display = true            p-sort           = 80            p-proc-attr      = ''            p-other          = 'nws':u . p-proc-attr = "''"  .  end.
            when 't_accept-position':U then do:     assign p-label          = "Принял /Должность/"            p-type           = 'C':U             p-format         = "X(70)"            p-fillin_width   = 70            p-fillin_height  = 1            p-label          = "Принял /Должность/"            p-user-can-edit  = true            p-output-display = true            p-sort           = 90            p-proc-attr      = ''            p-other          = 'nws':u . p-proc-attr = "''"  .  end.
            when 'ndovwho':U then do:     assign p-label          = "Доверенность: Кем и кому выдана"            p-type           = 'C':U             p-format         = "X(70)"            p-fillin_width   = 70            p-fillin_height  = 1            p-label          = "Доверенность: Кем и кому выдана"            p-user-can-edit  = true            p-output-display = true            p-sort           = 55            p-proc-attr      = ''            p-other          = 'nws':u . p-proc-attr = "''"  .  end.
            when 'nosn':U then do:     assign p-label          = "Документ-основание. Наименование"            p-type           = 'C':U             p-format         = "X(70)"            p-fillin_width   = 70            p-fillin_height  = 1            p-label          = "Документ-основание. Наименование"            p-user-can-edit  = true            p-output-display = true            p-sort           = 110            p-proc-attr      = ''            p-other          = 'nws':u . p-proc-attr = "''"  .  end.
            when 'first-price':U then do:     assign p-label          = "Первая переоценка"            p-type           = 'L':U             p-format         = "yes/no"            p-fillin_width   = 3            p-fillin_height  = 1            p-label          = "Первая переоценка"            p-user-can-edit  = false            p-output-display = false            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when 'relprpdf':U then do:     assign p-label          = "Связка Переоценки"            p-type           = 'C':U             p-format         = "X(70)"            p-fillin_width   = 22            p-fillin_height  = 1            p-label          = "Связка Переоценки"            p-user-can-edit  = false            p-output-display = false            p-sort           = 100            p-proc-attr      = ''            p-other          = 'nws':u . end.
            when 'ora-exp-seq-num':U then do:     assign p-label          = "Номер выгрузки в Oracle Retail"            p-type           = 'I':U             p-format         = "999999999"            p-fillin_width   = 22            p-fillin_height  = 1            p-label          = "Номер выгрузки в Oracle Retail"            p-user-can-edit  = false            p-output-display = false            p-sort           = 130            p-proc-attr      = ''            p-other          = 'nws':u . end.
            when 'need-saledc':U then do:     assign p-label          = "Требуется расчет данных по ДК"            p-type           = 'I':U             p-format         = "-9"            p-fillin_width   = 3            p-fillin_height  = 1            p-label          = "Требуется расчет данных по ДК"            p-user-can-edit  = false            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when 'dateinv':U then do:     assign p-label          = "Дата планируемого закрытия инвентаризации"            p-type           = 'T':U             p-format         = "99/99/9999"            p-fillin_width   = 11            p-fillin_height  = 1            p-label          = "Дата планируемого закрытия инвентаризации"            p-user-can-edit  = false            p-output-display = false            p-sort           = 100            p-proc-attr      = ''            p-other          = 'nws':u . end.
            when 'ser_on_pack':U then do:     assign p-label          = "Серия по фасовочному журналу"            p-type           = 'C':U             p-format         = "X(70)"            p-fillin_width   = 70            p-fillin_height  = 1            p-label          = "Серия по фасовочному журналу"            p-user-can-edit  = true            p-output-display = true            p-sort           = 121            p-proc-attr      = ''            p-other          = 'nws':u . p-proc-attr = "''"  .  end.
            when 'cargo-desc':U then do:     assign p-label          = "Описание груза"            p-type           = 'C':U             p-format         = "X(255)"            p-fillin_width   = 70            p-fillin_height  = 1            p-label          = "Описание груза"            p-user-can-edit  = true            p-output-display = true            p-sort           = 150            p-proc-attr      = ''            p-other          = 'nws':u . p-proc-attr = "win=str/trdcdesc.w,func=funcgrzp"  .  end.
            when 'carry-type':U then do:     assign p-label          = "Вид перевозки"            p-type           = 'C':U             p-format         = "X(70)"            p-fillin_width   = 70            p-fillin_height  = 1            p-label          = "Вид перевозки"            p-user-can-edit  = true            p-output-display = true            p-sort           = 130            p-proc-attr      = ''            p-other          = 'nws':u . p-proc-attr = "''"  .  end.
            when 'cargo-mass':U then do:     assign p-label          = "Масса груза, кг"            p-type           = 'C':U             p-format         = "x(70)"            p-fillin_width   = 70            p-fillin_height  = 1            p-label          = "Масса груза, кг"            p-user-can-edit  = true            p-output-display = true            p-sort           = 140            p-proc-attr      = ''            p-other          = 'nws':u . p-proc-attr = "win=str/trdcmass.w,func=funcgrzp"  .  end.
            when 'exp-trans':U then do:     assign p-label          = "Складские/транспортные расходы"            p-type           = 'D':U             p-format         = "->,>>>,>>>,>>9.99"            p-fillin_width   = 18            p-fillin_height  = 1            p-label          = "Складские/транспортные расходы"            p-user-can-edit  = true            p-output-display = true            p-sort           = 160            p-proc-attr      = ''            p-other          = 'nws':u . p-proc-attr = "''"  .  end.
            when 'zakaz-date':U then do:     assign p-label          = "Дата заказа"            p-type           = 'T':U             p-format         = "99/99/9999"            p-fillin_width   = 11            p-fillin_height  = 1            p-label          = "Дата заказа"            p-user-can-edit  = true            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = 'nws':u . end.
            when 'zakaz-number':U then do:     assign p-label          = "Номер заказа"            p-type           = 'C':U             p-format         = "x(70)"            p-fillin_width   = 18            p-fillin_height  = 1            p-label          = "Номер заказа"            p-user-can-edit  = true            p-output-display = true            p-sort           = 180            p-proc-attr      = ''            p-other          = 'nws':u . p-proc-attr = "''"  .  end.
            when 'delivery-date':U then do:     assign p-label          = "Дата доставки"            p-type           = 'T':U             p-format         = "99/99/9999"            p-fillin_width   = 11            p-fillin_height  = 1            p-label          = "Дата доставки"            p-user-can-edit  = true            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = 'nws':u . end.
            when 'delivery-time':U then do:     assign p-label          = "Время доставки (период)"            p-type           = 'C':U             p-format         = "99:99-99:99"            p-fillin_width   = 14            p-fillin_height  = 1            p-label          = "Время доставки (период)"            p-user-can-edit  = true            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when 'ptbobj':U then do:     assign p-label          = "Нефтебаза/ГНС"            p-type           = 'C':U             p-format         = "X(20)"            p-fillin_width   = 20            p-fillin_height  = 1            p-label          = "Нефтебаза/ГНС"            p-user-can-edit  = true            p-output-display = true            p-sort           = 190            p-proc-attr      = ''            p-other          = '':u . end.
            when 'ptb-item-pour':U then do:     assign p-label          = "Примечание к нефтебазе"            p-type           = 'C':U             p-format         = "X(100)"            p-fillin_width   = 20            p-fillin_height  = 1            p-label          = "Примечание к нефтебазе"            p-user-can-edit  = true            p-output-display = true            p-sort           = 190            p-proc-attr      = ''            p-other          = '':u . end.
            when 'autoent':U then do:     assign p-label          = "Автопредприятие"            p-type           = 'C':U             p-format         = "X(20)"            p-fillin_width   = 20            p-fillin_height  = 1            p-label          = "Автопредприятие"            p-user-can-edit  = true            p-output-display = true            p-sort           = 190            p-proc-attr      = ''            p-other          = '':u . end.
            when 'car-num':U then do:     assign p-label          = "Гос. № автоцистерны"            p-type           = 'C':U             p-format         = "X(20)"            p-fillin_width   = 20            p-fillin_height  = 1            p-label          = "Гос. № автоцистерны"            p-user-can-edit  = true            p-output-display = true            p-sort           = 190            p-proc-attr      = ''            p-other          = '':u . end.
            when 'fio-driver':U then do:     assign p-label          = "Ф.И.О. водителя-экспедитора"            p-type           = 'C':U             p-format         = "X(20)"            p-fillin_width   = 20            p-fillin_height  = 1            p-label          = "Ф.И.О. водителя-экспедитора"            p-user-can-edit  = true            p-output-display = true            p-sort           = 190            p-proc-attr      = ''            p-other          = '':u . end.
            when 'time-income':U then do:     assign p-label          = "Время прибытия на АЗС"            p-type           = 'C':U             p-format         = "X(20)"            p-fillin_width   = 20            p-fillin_height  = 1            p-label          = "Время прибытия на АЗС"            p-user-can-edit  = true            p-output-display = true            p-sort           = 190            p-proc-attr      = ''            p-other          = '':u . end.
            when 'time-pour':U then do:     assign p-label          = "Время налива"            p-type           = 'C':U             p-format         = "X(20)"            p-fillin_width   = 20            p-fillin_height  = 1            p-label          = "Время налива"            p-user-can-edit  = true            p-output-display = true            p-sort           = 190            p-proc-attr      = ''            p-other          = '':u . end.
            when 'time-start':U then do:     assign p-label          = "Время начала слива"            p-type           = 'C':U             p-format         = "X(20)"            p-fillin_width   = 20            p-fillin_height  = 1            p-label          = "Время начала слива"            p-user-can-edit  = true            p-output-display = true            p-sort           = 190            p-proc-attr      = ''            p-other          = '':u . end.
            when 'time-end':U then do:     assign p-label          = "Время конца слива"            p-type           = 'C':U             p-format         = "X(20)"            p-fillin_width   = 20            p-fillin_height  = 1            p-label          = "Время конца слива"            p-user-can-edit  = true            p-output-display = true            p-sort           = 190            p-proc-attr      = ''            p-other          = '':u . end.
            when 'date-pour':U then do:     assign p-label          = "Дата налива"            p-type           = 'T':U             p-format         = "99/99/9999"            p-fillin_width   = 11            p-fillin_height  = 1            p-label          = "Дата налива"            p-user-can-edit  = true            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when 'inspection-cert':U then do:     assign p-label          = "Свидетельство о поверке"            p-type           = 'C':U             p-format         = "X(20)"            p-fillin_width   = 20            p-fillin_height  = 1            p-label          = "Свидетельство о поверке"            p-user-can-edit  = true            p-output-display = true            p-sort           = 190            p-proc-attr      = ''            p-other          = '':u . end.
            when 'date-cert':U then do:     assign p-label          = "Дата свидетельства о поверке"            p-type           = 'T':U             p-format         = "99/99/9999"            p-fillin_width   = 11            p-fillin_height  = 1            p-label          = "Дата свидетельства о поверке"            p-user-can-edit  = true            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when 'condition':U then do:     assign p-label          = "Техническое состояние"            p-type           = 'C':U             p-format         = "X(20)"            p-fillin_width   = 20            p-fillin_height  = 1            p-label          = "Техническое состояние"            p-user-can-edit  = true            p-output-display = true            p-sort           = 190            p-proc-attr      = ''            p-other          = '':u . end.
            when 'seals-condition':U then do:     assign p-label          = "Пломбы и их состояние"            p-type           = 'C':U             p-format         = "X(20)"            p-fillin_width   = 20            p-fillin_height  = 1            p-label          = "Пломбы и их состояние"            p-user-can-edit  = true            p-output-display = true            p-sort           = 190            p-proc-attr      = ''            p-other          = '':u . end.
            when 'doc-not':U then do:     assign p-label          = "Документы НЕ предоставлены"            p-type           = 'L':U             p-format         = "yes/no"            p-fillin_width   = 4            p-fillin_height  = 1            p-label          = "Документы НЕ предоставлены"            p-user-can-edit  = true            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when 'spisok-not-doc':U then do:     assign p-label          = "Список не предоставленных документов"            p-type           = 'C':U             p-format         = "X(100)"            p-fillin_width   = 20            p-fillin_height  = 1            p-label          = "Список не предоставленных документов"            p-user-can-edit  = true            p-output-display = true            p-sort           = 190            p-proc-attr      = ''            p-other          = '':u . end.
            when 'acc-ship':U then do:     assign p-label          = "Допустимый % погрешности поставщика"            p-type           = 'D':U             p-format         = ">>9.99"            p-fillin_width   = 20            p-fillin_height  = 1            p-label          = "Допустимый % погрешности поставщика"            p-user-can-edit  = true            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = 'nws':u . end.
            when 'is-fuel':U then do:     assign p-label          = "Признак топливной накладной"            p-type           = 'L':U             p-format         = "yes/no"            p-fillin_width   = 3            p-fillin_height  = 1            p-label          = "Признак топливной накладной"            p-user-can-edit  = false            p-output-display = false            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when 'techpass':U then do:     assign p-label          = "Признак топливной накладной"            p-type           = 'L':U             p-format         = "yes/no"            p-fillin_width   = 3            p-fillin_height  = 1            p-label          = "Признак топливной накладной"            p-user-can-edit  = false            p-output-display = false            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when 'othermoves':U then do:     assign p-label          = "Прочие перемещения НП"            p-type           = 'L':U             p-format         = "yes/no"            p-fillin_width   = 3            p-fillin_height  = 1            p-label          = "Прочие перемещения НП"            p-user-can-edit  = true            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when 'is-auto-trn':U then do:     assign p-label          = "Признак накладной сформированной автоматически"            p-type           = 'L':U             p-format         = "yes/no"            p-fillin_width   = 3            p-fillin_height  = 1            p-label          = "Признак накладной сформированной автоматически"            p-user-can-edit  = false            p-output-display = false            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when 'is-lgas':U then do:     assign p-label          = "Документ прихода СУГ"            p-type           = 'L':U             p-format         = "yes/no"            p-fillin_width   = 3            p-fillin_height  = 1            p-label          = "Документ прихода СУГ"            p-user-can-edit  = false            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when 'is-lgas-corr':U then do:     assign p-label          = "Документ корректировки СУГ"            p-type           = 'L':U             p-format         = "yes/no"            p-fillin_width   = 3            p-fillin_height  = 1            p-label          = "Документ корректировки СУГ"            p-user-can-edit  = false            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when 'trn-lgas-corr':U then do:     assign p-label          = "Документ источник для корр. СУГ"            p-type           = 'C':U             p-format         = "X(20)"            p-fillin_width   = 3            p-fillin_height  = 1            p-label          = "Документ источник для корр. СУГ"            p-user-can-edit  = false            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when 'is-return':U then do:     assign p-label          = "Расход внешний как Возврат поставщику"            p-type           = 'L':U             p-format         = "yes/no"            p-fillin_width   = 3            p-fillin_height  = 1            p-label          = "Расход внешний как Возврат поставщику"            p-user-can-edit  = false            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when 'edo-return':U then do:     assign p-label          = "Расход внешний как Возврат поставщику через ЭДО"            p-type           = 'L':U             p-format         = "yes/no"            p-fillin_width   = 3            p-fillin_height  = 1            p-label          = "Расход внешний как Возврат поставщику через ЭДО"            p-user-can-edit  = false            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when 'trdcattr-date-start':U then do:     assign p-label          = "Дата начала слива"            p-type           = 'T':U             p-format         = "99/99/9999"            p-fillin_width   = 11            p-fillin_height  = 1            p-label          = "Дата начала слива"            p-user-can-edit  = true            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = 'nws':u . end.
            when 'trdcattr-date-end':U then do:     assign p-label          = "Дата конца слива"            p-type           = 'T':U             p-format         = "99/99/9999"            p-fillin_width   = 11            p-fillin_height  = 1            p-label          = "Дата конца слива"            p-user-can-edit  = true            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = 'nws':u . end.
            when 'trdcattr-inv-introduce':U then do:     assign p-label          = "Документ инвентаризации с первоначальным вводом марок"            p-type           = 'L':U             p-format         = "yes/no"            p-fillin_width   = 11            p-fillin_height  = 1            p-label          = "Документ инвентаризации с первоначальным вводом марок"            p-user-can-edit  = false            p-output-display = false            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when 'clear-ac':U then do:     assign p-label          = "Произведена зачистка АЦ перед наполнением на ГНС"            p-type           = 'L':U             p-format         = "yes/no"            p-fillin_width   = 4            p-fillin_height  = 1            p-label          = "Произведена зачистка АЦ перед наполнением на ГНС"            p-user-can-edit  = true            p-output-display = true            p-sort           = 200            p-proc-attr      = ''            p-other          = '':u . end.
            when 'trdcattr-is-not-close-fact-news':U then do:     assign p-label          = ""            p-type           = 'L':U             p-format         = "yes/no"            p-fillin_width   = 3            p-fillin_height  = 1            p-label          = ""            p-user-can-edit  = false            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when 'trdcattr-prikaz-number':U then do:     assign p-label          = "Приказ: Номер"            p-type           = 'C':U             p-format         = "X(70)"            p-fillin_width   = 70            p-fillin_height  = 1            p-label          = "Приказ: Номер"            p-user-can-edit  = true            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when 'trdcattr-prikaz-date':U then do:     assign p-label          = "Приказ: Дата"            p-type           = 'T':U             p-format         = "99.99.9999"            p-fillin_width   = 11            p-fillin_height  = 1            p-label          = "Приказ: Дата"            p-user-can-edit  = true            p-output-display = true            p-sort           = 102            p-proc-attr      = ''            p-other          = '':u . end.
            when 'trdcattr-inv-date':U then do:     assign p-label          = "Инвентаризация: Дата фактического начала"            p-type           = 'T':U             p-format         = "99.99.9999"            p-fillin_width   = 11            p-fillin_height  = 1            p-label          = "Инвентаризация: Дата фактического начала"            p-user-can-edit  = true            p-output-display = true            p-sort           = 104            p-proc-attr      = ''            p-other          = '':u . end.
            when 'trdcattr-fio-agent':U then do:     assign p-label          = "ФИО председателя комиссии"            p-type           = 'C':U             p-format         = "X(70)"            p-fillin_width   = 70            p-fillin_height  = 1            p-label          = "ФИО председателя комиссии"            p-user-can-edit  = true            p-output-display = true            p-sort           = 106            p-proc-attr      = ''            p-other          = 'nws':u . p-proc-attr = "''"  .  end.
            when 'trdcattr-pos-agent':U then do:     assign p-label          = "Должность председателя комиссии"            p-type           = 'C':U             p-format         = "X(70)"            p-fillin_width   = 70            p-fillin_height  = 1            p-label          = "Должность председателя комиссии"            p-user-can-edit  = false            p-output-display = false            p-sort           = 108            p-proc-attr      = ''            p-other          = 'nws':u . p-proc-attr = "''"  .  end.
            when 'trdcattr-fio-player1':U then do:     assign p-label          = "ФИО участника комиссии"            p-type           = 'C':U             p-format         = "X(70)"            p-fillin_width   = 70            p-fillin_height  = 1            p-label          = "ФИО участника комиссии"            p-user-can-edit  = true            p-output-display = true            p-sort           = 110            p-proc-attr      = ''            p-other          = 'nws':u . p-proc-attr = "''"  .  end.
            when 'trdcattr-pos-player1':U then do:     assign p-label          = "Должность участника комиссии"            p-type           = 'C':U             p-format         = "X(70)"            p-fillin_width   = 70            p-fillin_height  = 1            p-label          = "Должность участника комиссии"            p-user-can-edit  = false            p-output-display = false            p-sort           = 112            p-proc-attr      = ''            p-other          = 'nws':u . p-proc-attr = "''"  .  end.
            when 'trdcattr-fio-player2':U then do:     assign p-label          = "ФИО участника комиссии"            p-type           = 'C':U             p-format         = "X(70)"            p-fillin_width   = 70            p-fillin_height  = 1            p-label          = "ФИО участника комиссии"            p-user-can-edit  = true            p-output-display = true            p-sort           = 114            p-proc-attr      = ''            p-other          = 'nws':u . p-proc-attr = "''"  .  end.
            when 'trdcattr-pos-player2':U then do:     assign p-label          = "Должность участника комиссии"            p-type           = 'C':U             p-format         = "X(70)"            p-fillin_width   = 70            p-fillin_height  = 1            p-label          = "Должность участника комиссии"            p-user-can-edit  = false            p-output-display = false            p-sort           = 116            p-proc-attr      = ''            p-other          = 'nws':u . p-proc-attr = "''"  .  end.
            when 'trdcattr-fio-player3':U then do:     assign p-label          = "ФИО участника комиссии"            p-type           = 'C':U             p-format         = "X(70)"            p-fillin_width   = 70            p-fillin_height  = 1            p-label          = "ФИО участника комиссии"            p-user-can-edit  = true            p-output-display = true            p-sort           = 118            p-proc-attr      = ''            p-other          = 'nws':u . p-proc-attr = "''"  .  end.
            when 'trdcattr-pos-player3':U then do:     assign p-label          = "Должность участника комиссии"            p-type           = 'C':U             p-format         = "X(70)"            p-fillin_width   = 70            p-fillin_height  = 1            p-label          = "Должность участника комиссии"            p-user-can-edit  = false            p-output-display = false            p-sort           = 120            p-proc-attr      = ''            p-other          = 'nws':u . p-proc-attr = "''"  .  end.
            when 'sugtpattr-massa-sug':U then do:     assign p-label          = "Масса слитого СУГ на промежуточных станциях АГЗС, кг"            p-type           = 'D':U             p-format         = "->,>>>,>>>,>>9.999"            p-fillin_width   = 20            p-fillin_height  = 1            p-label          = "Масса слитого СУГ на промежуточных станциях АГЗС, кг"            p-user-can-edit  = true            p-output-display = true            p-sort           = 130            p-proc-attr      = ''            p-other          = 'nws':u . end.
            when 'sugtpattr-teh-loss':U then do:     assign p-label          = "Технологические потери предыдущих станций, кг"            p-type           = 'D':U             p-format         = "->,>>>,>>>,>>9.999"            p-fillin_width   = 20            p-fillin_height  = 1            p-label          = "Технологические потери предыдущих станций, кг"            p-user-can-edit  = true            p-output-display = true            p-sort           = 131            p-proc-attr      = ''            p-other          = 'nws':u . end.
            when 'sugtpattr-err-allow':U then do:     assign p-label          = "Допустимые погрешности предыдущих станций, кг"            p-type           = 'D':U             p-format         = "->,>>>,>>>,>>9.999"            p-fillin_width   = 20            p-fillin_height  = 1            p-label          = "Допустимые погрешности предыдущих станций, кг"            p-user-can-edit  = true            p-output-display = true            p-sort           = 132            p-proc-attr      = ''            p-other          = 'nws':u . end.
            when 'date-income':U then do:     assign p-label          = "Дата прибытия на АЗС"            p-type           = 'T':U             p-format         = "99/99/9999"            p-fillin_width   = 11            p-fillin_height  = 1            p-label          = "Дата прибытия на АЗС"            p-user-can-edit  = true            p-output-display = true            p-sort           = 180            p-proc-attr      = ''            p-other          = '':u . end.
            when 'date-pasport':U then do:     assign p-label          = "Паспорт качества дата"            p-type           = 'T':U             p-format         = "99/99/9999"            p-fillin_width   = 11            p-fillin_height  = 1            p-label          = "Паспорт качества дата"            p-user-can-edit  = true            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when 'num-pasport':U then do:     assign p-label          = "Паспорт качества номер"            p-type           = 'C':U             p-format         = "X(20)"            p-fillin_width   = 20            p-fillin_height  = 1            p-label          = "Паспорт качества номер"            p-user-can-edit  = true            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
      otherwise do:
        undo, return error substitute( 'неизвестный атрибут документа "&1"', p-code ).
      end.
    end case.
  end.
end procedure.
procedure trdcalib_tdatinv-cod :
  define  input parameter p-code           as character no-undo.
  define output parameter p-type           as character no-undo.
  define output parameter p-format         as character no-undo.
  define output parameter p-fillin_width   as integer   no-undo.
  define output parameter p-fillin_height  as integer   no-undo.
  define output parameter p-label          as character no-undo.
  define output parameter p-user-can-edit  as logical   no-undo.
  define output parameter p-output-display as logical   no-undo.
  define output parameter p-other          as character no-undo.
  define output parameter p-proc-attr       as character no-undo.
  define output parameter p-full-screen-val as character no-undo.
  define output parameter p-sort as integer   no-undo .
  do on error undo, return error return-value :
    case p-code :
            when 'trdcattr-prikaz-number':U then do:     assign p-label          = "Приказ: Номер"            p-type           = 'C':U             p-format         = "X(70)"            p-fillin_width   = 70            p-fillin_height  = 1            p-label          = "Приказ: Номер"            p-user-can-edit  = true            p-output-display = true            p-sort           = 100            p-proc-attr      = ''            p-other          = '':u . end.
            when 'trdcattr-prikaz-date':U then do:     assign p-label          = "Приказ: Дата"            p-type           = 'T':U             p-format         = "99.99.9999"            p-fillin_width   = 11            p-fillin_height  = 1            p-label          = "Приказ: Дата"            p-user-can-edit  = true            p-output-display = true            p-sort           = 102            p-proc-attr      = ''            p-other          = '':u . end.
            when 'trdcattr-inv-date':U then do:     assign p-label          = "Инвентаризация: Дата фактического начала"            p-type           = 'T':U             p-format         = "99.99.9999"            p-fillin_width   = 11            p-fillin_height  = 1            p-label          = "Инвентаризация: Дата фактического начала"            p-user-can-edit  = true            p-output-display = true            p-sort           = 104            p-proc-attr      = ''            p-other          = '':u . end.
            when 'trdcattr-fio-agent':U then do:     assign p-label          = "ФИО председателя комиссии"            p-type           = 'C':U             p-format         = "X(70)"            p-fillin_width   = 70            p-fillin_height  = 1            p-label          = "ФИО председателя комиссии"            p-user-can-edit  = true            p-output-display = true            p-sort           = 106            p-proc-attr      = ''            p-other          = 'nws':u . p-proc-attr = "''"  .  end.
            when 'trdcattr-pos-agent':U then do:     assign p-label          = "Должность председателя комиссии"            p-type           = 'C':U             p-format         = "X(70)"            p-fillin_width   = 70            p-fillin_height  = 1            p-label          = "Должность председателя комиссии"            p-user-can-edit  = false            p-output-display = false            p-sort           = 108            p-proc-attr      = ''            p-other          = 'nws':u . p-proc-attr = "''"  .  end.
            when 'trdcattr-fio-player1':U then do:     assign p-label          = "ФИО участника комиссии"            p-type           = 'C':U             p-format         = "X(70)"            p-fillin_width   = 70            p-fillin_height  = 1            p-label          = "ФИО участника комиссии"            p-user-can-edit  = true            p-output-display = true            p-sort           = 110            p-proc-attr      = ''            p-other          = 'nws':u . p-proc-attr = "''"  .  end.
            when 'trdcattr-pos-player1':U then do:     assign p-label          = "Должность участника комиссии"            p-type           = 'C':U             p-format         = "X(70)"            p-fillin_width   = 70            p-fillin_height  = 1            p-label          = "Должность участника комиссии"            p-user-can-edit  = false            p-output-display = false            p-sort           = 112            p-proc-attr      = ''            p-other          = 'nws':u . p-proc-attr = "''"  .  end.
            when 'trdcattr-fio-player2':U then do:     assign p-label          = "ФИО участника комиссии"            p-type           = 'C':U             p-format         = "X(70)"            p-fillin_width   = 70            p-fillin_height  = 1            p-label          = "ФИО участника комиссии"            p-user-can-edit  = true            p-output-display = true            p-sort           = 114            p-proc-attr      = ''            p-other          = 'nws':u . p-proc-attr = "''"  .  end.
            when 'trdcattr-pos-player2':U then do:     assign p-label          = "Должность участника комиссии"            p-type           = 'C':U             p-format         = "X(70)"            p-fillin_width   = 70            p-fillin_height  = 1            p-label          = "Должность участника комиссии"            p-user-can-edit  = false            p-output-display = false            p-sort           = 116            p-proc-attr      = ''            p-other          = 'nws':u . p-proc-attr = "''"  .  end.
            when 'trdcattr-fio-player3':U then do:     assign p-label          = "ФИО участника комиссии"            p-type           = 'C':U             p-format         = "X(70)"            p-fillin_width   = 70            p-fillin_height  = 1            p-label          = "ФИО участника комиссии"            p-user-can-edit  = true            p-output-display = true            p-sort           = 118            p-proc-attr      = ''            p-other          = 'nws':u . p-proc-attr = "''"  .  end.
            when 'trdcattr-pos-player3':U then do:     assign p-label          = "Должность участника комиссии"            p-type           = 'C':U             p-format         = "X(70)"            p-fillin_width   = 70            p-fillin_height  = 1            p-label          = "Должность участника комиссии"            p-user-can-edit  = false            p-output-display = false            p-sort           = 120            p-proc-attr      = ''            p-other          = 'nws':u . p-proc-attr = "''"  .  end.
      otherwise do:
        undo, return error substitute( 'неизвестный атрибут документа "&1"', p-code ).
      end.
    end case.
  end.
end procedure.
procedure trdcalib_tdat-oth :
  define input parameter p-doc-code as character no-undo.
  define input parameter p-code     as character no-undo.
  define input parameter p-value    as character no-undo.
  define variable v-type           as character no-undo.
  define variable v-format         as character no-undo.
  define variable v-fillin_width   as integer   no-undo.
  define variable v-fillin_height  as integer   no-undo.
  define variable v-label          as character no-undo.
  define variable v-user-can-edit  as logical   no-undo.
  define variable v-output-display as logical   no-undo.
  define variable v-other          as character no-undo.
  define variable v-proc-attr       as character no-undo .
  define variable v-full-screen-val as character no-undo .
  define variable v-sort as integer   no-undo .
  define buffer buf_doc-attr for ub.doc-attr.
  define buffer nakl_trn-doc for ub.trn-doc.
  define buffer bf_trn-doc   for ub.trn-doc.
  do on error undo, return error return-value :
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input p-code ,
                       output v-type ,
                       output v-format ,
                       output v-fillin_width ,
                       output v-fillin_height ,
                       output v-label ,
                       output v-user-can-edit ,
                       output v-output-display ,
                       output v-other  ,
                       output v-proc-attr ,
                       output v-full-screen-val ,
                       output v-sort
                       ) no-error .
    if lookup( 'rsrv-date':u, v-other ) > 0 and p-value <> "":U then do:
       find first bf_trn-doc exclusive-lock where
                  bf_trn-doc.doc-code = p-doc-code.
       assign bf_trn-doc.flora-order-date = date( p-value ).
       find first nakl_trn-doc exclusive-lock where
                  nakl_trn-doc.doc-code = bf_trn-doc.out-code no-error.
        if not error-status :error then do:
          assign nakl_trn-doc.flora-order-date = date( p-value ).
        end.
    end.
    if lookup( "postdchek":U, v-other ) > 0 and p-value <> "":U then do:
      find first bf_trn-doc exclusive-lock where
                 bf_trn-doc.doc-code = p-doc-code.
      assign bf_trn-doc.flora-pay-date = date( p-value ).
      find first nakl_trn-doc exclusive-lock where
                 nakl_trn-doc.doc-code = bf_trn-doc.out-code no-error.
      if not error-status :error then do:
        assign nakl_trn-doc.flora-pay-date  = date( p-value ).
      end.
    end.
    if lookup( "nws":U, v-other ) > 0 then do:
      find first bf_trn-doc no-lock where
                 bf_trn-doc.doc-code = p-doc-code  no-error.
      if available bf_trn-doc then do:
        find first buf_doc-attr no-lock where
                   buf_doc-attr.doc-code  = p-doc-code and
                   buf_doc-attr.attr-code = p-code     no-error.
        run str/callnews.p ( input "doc-attr", input ( buffer buf_doc-attr :handle ) ) no-error.
        if error-status :error then do:
          message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
                  "Невозможно маршрутизировать doc-attr для отправки в новости" skip( 0 )
                  "Документ:" '"' + bf_trn-doc.doc-code    + '"' skip( 0 )
                  "Атрибут:"  '"' + buf_doc-attr.attr-code + '"' skip( 0 )
                  error-status :get-message( 1 ) skip( 0 )
                  error-status :get-message( 2 ) skip( 0 )
                  error-status :get-message( 3 ) skip( 0 )
                  "return-value = " return-value skip( 0 )
          view-as alert-box error.
          undo, return error return-value.
        end.
      end.
      define buffer bf_price-doc for ub.price-doc  .
      find first bf_price-doc no-lock where
                 bf_price-doc.doc-num = p-doc-code
                 no-error.
      if available bf_price-doc then do:
        find first buf_doc-attr no-lock where
                   buf_doc-attr.doc-code  = p-doc-code and
                   buf_doc-attr.attr-code = p-code     no-error.
        run str/callnews.p ( input "doc-attr", input ( buffer buf_doc-attr :handle ) ) no-error.
        if error-status :error then do:
          message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
                  "Невозможно маршрутизировать doc-attr для отправки в новости" skip( 0 )
                  "Переоценка:" '"' + bf_price-doc.doc-num    + '"' skip( 0 )
                  "Атрибут:"  '"' + buf_doc-attr.attr-code + '"' skip( 0 )
                  error-status :get-message( 1 ) skip( 0 )
                  error-status :get-message( 2 ) skip( 0 )
                  error-status :get-message( 3 ) skip( 0 )
                  "return-value = " return-value skip( 0 )
          view-as alert-box error.
          undo, return error return-value.
        end.
      end.
    end.
  end.
end procedure.
procedure trdcalib_tdatinv-oth :
  define input parameter p-doc-code as character no-undo.
  define input parameter p-code     as character no-undo.
  define input parameter p-value    as character no-undo.
  define variable v-type           as character no-undo.
  define variable v-format         as character no-undo.
  define variable v-fillin_width   as integer   no-undo.
  define variable v-fillin_height  as integer   no-undo.
  define variable v-label          as character no-undo.
  define variable v-user-can-edit  as logical   no-undo.
  define variable v-output-display as logical   no-undo.
  define variable v-other          as character no-undo.
  define variable v-proc-attr       as character no-undo .
  define variable v-full-screen-val as character no-undo .
  define variable v-sort as integer   no-undo .
  define buffer buf_doc-attr for ub.inv-doc-attr.
  define buffer nakl_trn-doc for ub.trn-doc.
  define buffer bf_trn-doc   for ub.trn-doc.
  do on error undo, return error return-value :
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-cod in g#trdcalib (  input p-code ,
                       output v-type ,
                       output v-format ,
                       output v-fillin_width ,
                       output v-fillin_height ,
                       output v-label ,
                       output v-user-can-edit ,
                       output v-output-display ,
                       output v-other  ,
                       output v-proc-attr ,
                       output v-full-screen-val ,
                       output v-sort
                       ) no-error .
    if lookup( "nws":U, v-other ) > 0 then do:
      find first bf_trn-doc no-lock where
                 bf_trn-doc.doc-code = p-doc-code  no-error.
      if available bf_trn-doc then do:
        find first buf_doc-attr no-lock where
                   buf_doc-attr.doc-code  = p-doc-code and
                   buf_doc-attr.attr-code = p-code     no-error.
        run str/callnews.p ( input "doc-attr", input ( buffer buf_doc-attr :handle ) ) no-error.
        if error-status :error then do:
          message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
                  "Невозможно маршрутизировать doc-attr для отправки в новости" skip( 0 )
                  "Документ:" '"' + bf_trn-doc.doc-code    + '"' skip( 0 )
                  "Атрибут:"  '"' + buf_doc-attr.attr-code + '"' skip( 0 )
                  error-status :get-message( 1 ) skip( 0 )
                  error-status :get-message( 2 ) skip( 0 )
                  error-status :get-message( 3 ) skip( 0 )
                  "return-value = " return-value skip( 0 )
          view-as alert-box error.
          undo, return error return-value.
        end.
      end.
      define buffer bf_price-doc for ub.price-doc  .
      find first bf_price-doc no-lock where
                 bf_price-doc.doc-num = p-doc-code
                 no-error.
      if available bf_price-doc then do:
        find first buf_doc-attr no-lock where
                   buf_doc-attr.doc-code  = p-doc-code and
                   buf_doc-attr.attr-code = p-code     no-error.
        run str/callnews.p ( input "doc-attr", input ( buffer buf_doc-attr :handle ) ) no-error.
        if error-status :error then do:
          message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
                  "Невозможно маршрутизировать doc-attr для отправки в новости" skip( 0 )
                  "Переоценка:" '"' + bf_price-doc.doc-num    + '"' skip( 0 )
                  "Атрибут:"  '"' + buf_doc-attr.attr-code + '"' skip( 0 )
                  error-status :get-message( 1 ) skip( 0 )
                  error-status :get-message( 2 ) skip( 0 )
                  error-status :get-message( 3 ) skip( 0 )
                  "return-value = " return-value skip( 0 )
          view-as alert-box error.
          undo, return error return-value.
        end.
      end.
    end.
  end.
end procedure.
procedure trdcalib_tdatothn :
  define input parameter p-doc-code as character no-undo.
  define input parameter p-code     as character no-undo.
  define variable v-type           as character no-undo.
  define variable v-format         as character no-undo.
  define variable v-fillin_width   as integer   no-undo.
  define variable v-fillin_height  as integer   no-undo.
  define variable v-label          as character no-undo.
  define variable v-user-can-edit  as logical   no-undo.
  define variable v-output-display as logical   no-undo.
  define variable v-other          as character no-undo.
  define variable v-proc-attr       as character no-undo .
  define variable v-full-screen-val as character no-undo .
  define variable v-sort as integer   no-undo .
  define buffer buf_doc-attr for ub.doc-attr.
  define buffer nakl_trn-doc for ub.trn-doc.
  define buffer bf_trn-doc   for ub.trn-doc.
  do on error undo, return error return-value :
      define buffer bf_price-doc for ub.price-doc  .
      find first bf_price-doc no-lock where
                 bf_price-doc.doc-num = p-doc-code
                 no-error.
      if available bf_price-doc then do:
        find first buf_doc-attr no-lock where
                   buf_doc-attr.doc-code  = p-doc-code and
                   buf_doc-attr.attr-code = p-code     no-error.
        run str/callnews.p ( input "doc-attr", input ( buffer buf_doc-attr :handle ) ) no-error.
        if error-status :error then do:
          message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
                  "Невозможно маршрутизировать doc-attr для отправки в новости" skip( 0 )
                  "Переоценка:" '"' + bf_price-doc.doc-num    + '"' skip( 0 )
                  "Атрибут:"  '"' + buf_doc-attr.attr-code + '"' skip( 0 )
                  error-status :get-message( 1 ) skip( 0 )
                  error-status :get-message( 2 ) skip( 0 )
                  error-status :get-message( 3 ) skip( 0 )
                  "return-value = " return-value skip( 0 )
          view-as alert-box error.
          undo, return error return-value.
        end.
      end.
  end.
end procedure.
