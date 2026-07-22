block-level on error undo, throw.
define input parameter p-doc-code       as character        no-undo.
define input parameter p-attr-code      as character        no-undo.
define output parameter p-attr-value    as character        no-undo.
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: fbrattrv.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/fbrattrv.p $":U .
define variable vss-description as character no-undo initial "Чтение атрибута документа производства":U .
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
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info1 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure fbrattr-write :
  define input parameter p-doc-type       as character        no-undo.
  define input parameter p-doc-code       as character        no-undo.
  define input parameter p-attr-code      as character        no-undo.
  define input parameter p-attr-value     as character        no-undo.
  do
  on error undo, return error
  :
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input substitute('&1-&2',p-doc-type,p-doc-code) ,
                       input p-attr-code ,
                       input p-attr-value )  .
  end.
end procedure.
procedure fbrattr-value :
  define  input parameter p-doc-type      as character        no-undo.
  define  input parameter p-doc-code      as character        no-undo.
  define  input parameter p-attr-code     as character        no-undo.
  define output parameter p-attr-value    as character        no-undo.
  define variable v-par-value     as character    no-undo.
  define variable v-par-type      as character    no-undo.
  define buffer buf_clients       for ub.clients.
  do
  for buf_clients
  on error undo, return error
  :
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input substitute('&1-&2',p-doc-type,p-doc-code) ,
                        input p-attr-code ,
                       output p-attr-value ,
                       output v-par-type )  .
  end.
end procedure.
    define variable v-attr-type    as character    no-undo.
do
on error undo, return error
:
    run fbrattr-value in this-procedure (
          input 'fbr-doc':U
        , input p-doc-code
        , input p-attr-code
        , output p-attr-value
    ) no-error.
    if error-status :error
    then do:
        message
            vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка вычисления атрибута документа производства."
            skip(1)
            skip "Номер документа:" p-doc-code
            skip "Код атрибута:" p-attr-code
            skip(1)
            skip return-value
            skip trim( error-status :get-message( 1 ) )
                    trim( error-status :get-message( 2 ) )
                    trim( error-status :get-message( 3 ) )
        view-as alert-box error.
        undo, return error.
    end.
end.
