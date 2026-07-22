block-level on error undo, throw.
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U.
define variable vss-author      as character no-undo initial "$Author: expertek $":U.
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U.
define variable vss-workfile    as character no-undo initial "$Workfile: partolib.p $":U.
define variable vss-archive     as character no-undo initial "$Archive: str/partolib.p $":U.
define variable vss-description as character no-undo initial "Библиотека процедур для работы с атрибутами партии на объекте":U.
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
 define new global shared variable g#partolib as handle no-undo.
if valid-handle( g#partolib ) and g#partolib <> this-procedure :handle then do:
  message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 0 ) vss-description skip( 1 )
          "partolib.p: попытка повторной загрузки библиотеки" skip( 1 )
          g#partolib                     skip( 0 )
          g#partolib     :type           skip( 0 )
          g#partolib     :file-name      skip( 0 )
          valid-handle( g#partolib     ) skip( 0 )
          this-procedure :handle         skip( 0 )
          this-procedure :type           skip( 0 )
          this-procedure :file-name      skip( 0 )
          valid-handle( this-procedure ) skip( 0 )
  view-as alert-box error title " О Ш И Б К А  ! ! ! ".
  undo, return error "partolib.p: попытка повторной загрузки библиотеки".
end.
else do:
  assign
    g#partolib = this-procedure :handle
  .
end.
on delete of this-procedure do:
  assign
    g#partolib = ?
  .
end.
procedure partolib_partoval :
  define  input parameter p-obj-type as character no-undo .
  define  input parameter p-obj-code as integer no-undo .
  define  input parameter p-gds-code as integer no-undo .
  define  input parameter p-prt-code as integer no-undo .
  define  input parameter p-in-code as character no-undo .
  define  input parameter p-out-code as character no-undo .
  define  input parameter p-part-code as character no-undo .
  define  input parameter p-code     like ub.parts-obj-attr.attr-code  no-undo.
  define output parameter p-value    like ub.parts-obj-attr.attr-value no-undo.
  define output parameter p-type     as   character              no-undo.
  define buffer buf_parts-obj-attr for ub.parts-obj-attr.
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
if valid-handle( g#partolib ) <> yes then do:       run str/partolib.p persistent no-error.       if error-status :error or valid-handle( g#partolib ) <> yes then do:         message "Error starting partolib.p"    skip( 0 )                 g#partolib                     skip( 0 )                 g#partolib   :type             skip( 0 )                 g#partolib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run partolib_partocod in g#partolib (  input p-code ,
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
    find first buf_parts-obj-attr no-lock where
               buf_parts-obj-attr.obj-type  = p-obj-type
           and buf_parts-obj-attr.obj-code  = p-obj-code
           and buf_parts-obj-attr.gds-code  = p-gds-code
           and buf_parts-obj-attr.prt-code  = p-prt-code
           and buf_parts-obj-attr.in-code  = p-in-code
           and buf_parts-obj-attr.out-code  = p-out-code
           and buf_parts-obj-attr.part-code  = p-part-code
           and buf_parts-obj-attr.attr-code = p-code     no-error.
    assign p-value = ( if available buf_parts-obj-attr then buf_parts-obj-attr.attr-value else
                     ( if p-type = 'L':U then "no":U else "":U ) ).
  end.
end procedure.
procedure partolib_partowrt :
  define input parameter p-obj-type as character no-undo .
  define input parameter p-obj-code as integer no-undo .
  define input parameter p-gds-code as integer no-undo .
  define input parameter p-prt-code as integer no-undo .
  define input parameter p-in-code as character no-undo .
  define input parameter p-out-code as character no-undo .
  define input parameter p-part-code as character no-undo .
  define input parameter p-code     like ub.parts-obj-attr.attr-code  no-undo.
  define input parameter p-value    like ub.parts-obj-attr.attr-value no-undo.
  define buffer buf_parts-obj-attr for ub.parts-obj-attr.
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
if valid-handle( g#partolib ) <> yes then do:       run str/partolib.p persistent no-error.       if error-status :error or valid-handle( g#partolib ) <> yes then do:         message "Error starting partolib.p"    skip( 0 )                 g#partolib                     skip( 0 )                 g#partolib   :type             skip( 0 )                 g#partolib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run partolib_partocod in g#partolib (  input p-code ,
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
    find first buf_parts-obj-attr exclusive-lock where
               buf_parts-obj-attr.obj-type  = p-obj-type
           and buf_parts-obj-attr.obj-code  = p-obj-code
           and buf_parts-obj-attr.gds-code  = p-gds-code
           and buf_parts-obj-attr.prt-code  = p-prt-code
           and buf_parts-obj-attr.in-code  = p-in-code
           and buf_parts-obj-attr.out-code  = p-out-code
           and buf_parts-obj-attr.part-code  = p-part-code
           and buf_parts-obj-attr.attr-code = p-code     no-error.
    if not available buf_parts-obj-attr then do:
      create buf_parts-obj-attr.
      assign
      buf_parts-obj-attr.obj-type  = p-obj-type
      buf_parts-obj-attr.obj-code  = p-obj-code
      buf_parts-obj-attr.gds-code  = p-gds-code
      buf_parts-obj-attr.prt-code  = p-prt-code
      buf_parts-obj-attr.in-code  = p-in-code
      buf_parts-obj-attr.out-code  = p-out-code
      buf_parts-obj-attr.part-code  = p-part-code
      buf_parts-obj-attr.attr-code = p-code.
    end.
    assign buf_parts-obj-attr.attr-value = p-value.
  end.
end procedure.
procedure partolib_partoxst :
  define input parameter p-obj-type as character no-undo .
  define input parameter p-obj-code as integer no-undo .
  define input parameter p-gds-code as integer no-undo .
  define input parameter p-prt-code as integer no-undo .
  define input parameter p-in-code as character no-undo .
  define input parameter p-out-code as character no-undo .
  define input parameter p-part-code as character no-undo .
  define input parameter p-code     like ub.parts-obj-attr.attr-code no-undo.
  define output parameter p-exist    as   logical               no-undo.
  define buffer buf_parts-obj-attr for ub.parts-obj-attr.
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
if valid-handle( g#partolib ) <> yes then do:       run str/partolib.p persistent no-error.       if error-status :error or valid-handle( g#partolib ) <> yes then do:         message "Error starting partolib.p"    skip( 0 )                 g#partolib                     skip( 0 )                 g#partolib   :type             skip( 0 )                 g#partolib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run partolib_partocod in g#partolib (  input p-code ,
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
    find first buf_parts-obj-attr no-lock where
               buf_parts-obj-attr.obj-type  = p-obj-type
           and buf_parts-obj-attr.obj-code  = p-obj-code
           and buf_parts-obj-attr.gds-code  = p-gds-code
           and buf_parts-obj-attr.prt-code  = p-prt-code
           and buf_parts-obj-attr.in-code  = p-in-code
           and buf_parts-obj-attr.out-code  = p-out-code
           and buf_parts-obj-attr.part-code  = p-part-code
           and buf_parts-obj-attr.attr-code = p-code     no-error.
    if available buf_parts-obj-attr then do: p-exist = yes. end.
  end.
end procedure.
procedure partolib_partodel :
  define input parameter p-obj-type as character no-undo .
  define input parameter p-obj-code as integer no-undo .
  define input parameter p-gds-code as integer no-undo .
  define input parameter p-prt-code as integer no-undo .
  define input parameter p-in-code as character no-undo .
  define input parameter p-out-code as character no-undo .
  define input parameter p-part-code as character no-undo .
  define  input parameter p-code     like ub.parts-obj-attr.attr-code no-undo.
  define output parameter p-deleted  as   logical               no-undo.
  define buffer buf_parts-obj-attr for ub.parts-obj-attr.
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
if valid-handle( g#partolib ) <> yes then do:       run str/partolib.p persistent no-error.       if error-status :error or valid-handle( g#partolib ) <> yes then do:         message "Error starting partolib.p"    skip( 0 )                 g#partolib                     skip( 0 )                 g#partolib   :type             skip( 0 )                 g#partolib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run partolib_partocod in g#partolib (  input p-code ,
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
    find first buf_parts-obj-attr exclusive-lock where
               buf_parts-obj-attr.obj-type  = p-obj-type
           and buf_parts-obj-attr.obj-code  = p-obj-code
           and buf_parts-obj-attr.gds-code  = p-gds-code
           and buf_parts-obj-attr.prt-code  = p-prt-code
           and buf_parts-obj-attr.in-code  = p-in-code
           and buf_parts-obj-attr.out-code  = p-out-code
           and buf_parts-obj-attr.part-code  = p-part-code
           and buf_parts-obj-attr.attr-code = p-code     no-error no-wait.
    if not available buf_parts-obj-attr then do:
      assign p-deleted = no.
    end.
    else do:
      delete buf_parts-obj-attr.
      assign p-deleted = yes.
    end.
  end.
end procedure.
procedure partolib_partocod :
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
            when 'parts-end':U then do:     assign p-label          = "Дата исчерпания своб зоны"            p-type           = 'C':U             p-format         = "x(10)"            p-fillin_width   = 10            p-fillin_height  = 3            p-label          = "Дата исчерпания своб зоны"            p-user-can-edit  = false            p-output-display = true            p-sort           = 45            p-proc-attr      = ''            p-other          = '':u . end.
      otherwise do:
        undo, return error substitute( 'неизвестный атрибут документа "&1"', p-code ).
      end.
    end case.
  end.
end procedure.
procedure partolib_tdat-oth :
  define input parameter p-obj-type as character no-undo .
  define input parameter p-obj-code as integer no-undo .
  define input parameter p-gds-code as integer no-undo .
  define input parameter p-prt-code as integer no-undo .
  define input parameter p-in-code as character no-undo .
  define input parameter p-out-code as character no-undo .
  define input parameter p-part-code as character no-undo .
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
  define buffer buf_parts-obj-attr for ub.parts-obj-attr.
  do on error undo, return error return-value :
if valid-handle( g#partolib ) <> yes then do:       run str/partolib.p persistent no-error.       if error-status :error or valid-handle( g#partolib ) <> yes then do:         message "Error starting partolib.p"    skip( 0 )                 g#partolib                     skip( 0 )                 g#partolib   :type             skip( 0 )                 g#partolib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run partolib_partocod in g#partolib (  input p-code ,
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
    end.
  end.
end procedure.
procedure partolib_tdatothn :
  define input parameter p-obj-type as character no-undo .
  define input parameter p-obj-code as integer no-undo .
  define input parameter p-gds-code as integer no-undo .
  define input parameter p-prt-code as integer no-undo .
  define input parameter p-in-code as character no-undo .
  define input parameter p-out-code as character no-undo .
  define input parameter p-part-code as character no-undo .
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
  define buffer buf_parts-obj-attr for ub.parts-obj-attr.
  do on error undo, return error return-value :
    find first buf_parts-obj-attr no-lock where
               buf_parts-obj-attr.obj-type  = p-obj-type
           and buf_parts-obj-attr.obj-code  = p-obj-code
           and buf_parts-obj-attr.gds-code  = p-gds-code
           and buf_parts-obj-attr.prt-code  = p-prt-code
           and buf_parts-obj-attr.in-code  = p-in-code
           and buf_parts-obj-attr.out-code  = p-out-code
           and buf_parts-obj-attr.part-code  = p-part-code
           and buf_parts-obj-attr.attr-code = p-code     no-error no-wait.
    run str/callnews.p ( input 'parts-obj-attr':U
                       , input ( buffer buf_parts-obj-attr :handle ) ) no-error.
    if error-status :error then do:
      message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
              "Невозможно маршрутизировать part-obj-attr для отправки в новости" skip( 0 )
              "Атрибут:"  '"' + buf_parts-obj-attr.attr-code + '"' skip( 0 )
              error-status :get-message( 1 ) skip( 0 )
              error-status :get-message( 2 ) skip( 0 )
              error-status :get-message( 3 ) skip( 0 )
              "return-value = " return-value skip( 0 )
      view-as alert-box error.
      undo, return error return-value.
    end.
  end.
end procedure.
