block-level on error undo, throw.
define input  parameter parparentproc as handle no-undo.
define input  parameter t-rid         as recid  no-undo .
define input  parameter parline-rec   as recid  no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: trn-lkp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/trn-lkp.p $":U .
define variable vss-description as character no-undo init "Ïğîñìîòğ ñêëàäñêîãî äîêóìåíòà".
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
define variable varnext-prev as logical no-undo.
define variable br-handle    as handle  no-undo.
define variable bf-handle    as handle  no-undo.
define variable varvalue-oldsuppcntr as character no-undo .
define variable vartype-oldsuppcntr  as character no-undo .
do
on error undo, return error return-value
:
define new shared buffer t-doc for ub.trn-doc.
  open query br-docs for each t-doc where recid (t-doc) = t-rid no-lock.
  get first br-docs .
  case t-doc.doc-type :
    when 'ïğè':U then do:
      if t-doc.internal = yes then do:
        run str/out-doc.w (input parparentproc, input-output t-rid, input 'ÏĞÎÑÌÎÒĞ':U, input ?, input 'ïğè':U, input yes, input-output varnext-prev, input t-doc.ext-doc-type, input ?, input-output parline-rec, input br-handle, input bf-handle, input t-doc.status_).
      end.
      else do:
        run str/in-doc.w  (input parparentproc, input-output t-rid, input 'ÏĞÎÑÌÎÒĞ':U, input 'èíâ':U, input no, input-output varnext-prev, input t-doc.ext-doc-type, input ?, input-output parline-rec, input br-handle , input bf-handle, input t-doc.status_).
      end.
    end.
    when 'ñïè':U or
    when 'âîçâğàò':U    or
    when 'ğàñ':U   then do:
      run str/out-doc.w (input parparentproc, input-output t-rid, input 'ÏĞÎÑÌÎÒĞ':U, input ?, input t-doc.doc-type, input t-doc.internal, input-output varnext-prev, input t-doc.ext-doc-type, input ?, input-output parline-rec, input br-handle, input bf-handle , input t-doc.status_).
    end.
    when 'èíâ':U then do:
      if t-doc.ext-doc-type = 'vt':U then do:
        run str/inv-doc.w (input parparentproc, input-output t-rid, input 'ÏĞÎÑÌÎÒĞ':U, input 'èíâ':U, input no, input-output varnext-prev, input ?, input ?, input-output parline-rec, input br-handle , input bf-handle) .
      end.
      else do:
        if t-doc.ext-doc-type = 'vp':U then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-doc.doc-code ,
                        input 'olsuppcntr':U ,
                       output varvalue-oldsuppcntr ,
                       output vartype-oldsuppcntr ) no-error .
           run str/peresort.w
                  (input        parparentproc,
                  input-output t-rid,
                  input        'ÏĞÎÑÌÎÒĞ':U,
                  input        'vp':U,
                  input-output varnext-prev,
                  input-output parline-rec,
                  input        br-handle,
                  input        bf-handle,
                  input        t-doc.obj-type,
                  input        t-doc.obj-code,
                  input        t-doc.cli-type,
                  input        t-doc.cli-code,
                  input        (if varvalue-oldsuppcntr = "yes":u then yes else no),
                  input        t-doc.contract-code    ) .
        end.
        else do:
          run str/corparts.w (input parparentproc, input-output t-rid, input 'ÏĞÎÑÌÎÒĞ':U, input t-doc.ext-doc-type, input ?, input-output varnext-prev, input-output parline-rec, input br-handle , input bf-handle).
        end.
      end.
    end.
  end.
end.
