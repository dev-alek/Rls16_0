block-level on error undo, throw.
TRIGGER PROCEDURE FOR WRITE OF ub.c-s-coeff.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Òğèããåğ íà çàïèñü èñòîğèè ÑÅÇÎÍÍÛÕ ÊÎİÔÔÈÖÈÅÍÒÎÂ".
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
    assign
      p-vss-parameters = substitute('&1|&2|&3|&4|&5|&6|&7'
                         , ub.c-s-coeff.gds-code
                         , ub.c-s-coeff.host-code
                         , ub.c-s-coeff.obj-type
                         , ub.c-s-coeff.obj-code
                         , ub.c-s-coeff.s-date
                         , ub.c-s-coeff.corr-user-db-num
                         , ub.c-s-coeff.chip-num
                         )
    .
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
define variable v-db-num like ub.db.db-num no-undo .
define buffer buf_s-coeff for ub.s-coeff.
define buffer buf_c-gds-hist for ub.c-gds-hist.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if not g#news then do:
    find first buf_c-gds-hist no-lock where
              buf_c-gds-hist.gds-code = c-s-coeff.gds-code
           AND buf_c-gds-hist.obj-type = c-s-coeff.obj-type
           AND buf_c-gds-hist.obj-code = c-s-coeff.obj-code
           AND buf_c-gds-hist.host-code = c-s-coeff.host-code
           AND buf_c-gds-hist.chip-num = c-s-coeff.chip-num
           AND buf_c-gds-hist.corr-user-db-num = c-s-coeff.corr-user-db-num no-error .
    if buf_c-gds-hist.action <> integer('99':U) then do:
      find first buf_s-coeff no-lock where
                buf_s-coeff.obj-type = c-s-coeff.obj-type
            AND buf_s-coeff.obj-code = c-s-coeff.obj-code
            AND buf_s-coeff.host-code = c-s-coeff.host-code
            AND buf_s-coeff.gds-code = c-s-coeff.gds-code
            AND buf_s-coeff.s-date = c-s-coeff.s-date
                no-error .
      if not available buf_s-coeff then do:
        message
        vss-workfile vss-revision vss-description skip
        "Íåïğàâèëüíàÿ ññûëêà íà ÑÅÇÎÍÍÛÉ ÊÎİÔÔÈÖÈÅÍÒ ÒÎÂÀĞÀ" skip
        "Ôèğìà" c-s-coeff.host-code
        "îáúåêò" c-s-coeff.obj-type  c-s-coeff.obj-code
        "Òîâàğ" c-s-coeff.gds-code
        "Äàòà" c-s-coeff.s-date
        view-as alert-box error .
        undo main-block, return error.
      end.
    end.
  end.
  if NOT (c-s-coeff.obj-type  = "":U
          AND c-s-coeff.obj-code = 0) then do:
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  ub.c-s-coeff.obj-type
  ,input  ub.c-s-coeff.obj-code
  ,output v-db-num
  )  .
   if not g#news and g#db-num <> v-db-num and g#db-num <> 0 then do:
      message
      vss-workfile vss-revision vss-description skip
      "Íåëüçÿ èçìåíÿòü çàïèñü ÈÑÒÎĞÈÈ ÑÅÇÎÍÍÎÃÎ ÊÎİÔÔÈÖÈÅÍÒÀ ÒÎÂÀĞÀ ÍÀ ÎÁÚÅÊÒÅ â ÁÄ, îòëè÷íîé îò ÁÄ îáúåêòà, åñëè îíà íå ÃÁÄ" skip
      "Íîìåğ òåêóùåé ÁÄ" g#db-num "Íîìåğ ÁÄ îáúåêòà" v-db-num
      view-as alert-box error .
      undo, return error .
    end.
  end.
 if
  not g#news
  OR (g#news
      and not ( g#db-num > 0 )
      and ub.c-s-coeff.corr-user-name <> (chr(4) +  'ÑÏÍ':U)
      )
  or (g#news
      and ( g#db-num > 0 )
      and ub.c-s-coeff.corr-user-name = (chr(4) +  'ÑÏÍ':U)
      )
  then do:
    run str/callnews.p
      (input "c-s-coeff"
      ,input (buffer ub.c-s-coeff:handle)
      ).
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input 'update':U
        , input 'c-s-coeff':U
        , input ( buffer ub.c-s-coeff:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Îøèáêà ïğè îòïğàâêå çàïèñè â ñèñòåìó OpenXML&1&3&1&4"
                             , chr(10)
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
end.
