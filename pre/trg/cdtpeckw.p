block-level on error undo, throw.
TRIGGER PROCEDURE FOR WRITE OF ub.c-deliv-type-cond-keep.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Òğèããåğ íà óäàëåíèå â òàáëèöå ÈÑÒÎĞÈß ÂÎÇÌÎÆÍÎÑÒÅÉ ÄÎÑÒÀÂÊÈ ÏÎ ÓÑËÎÂÈßÌ ÕĞÀÍÅÍÈß".
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
      p-vss-parameters = substitute('&1|&2|&3|&4'
                        , ub.c-deliv-type-cond-keep.deliv-type-code
                        , ub.c-deliv-type-cond-keep.cond-keep-code
                        , ub.c-deliv-type-cond-keep.corr-user-db-num
                        , ub.c-deliv-type-cond-keep.chip-num
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
define buffer buf_delivery-type for ub.delivery-type.
define buffer buf_condition-keeping for ub.condition-keeping.
define buffer buf_deliv-type-cond-keep for ub.deliv-type-cond-keep.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if not g#news then do:
    find first buf_delivery-type no-lock where
               buf_delivery-type.deliv-type-code = c-deliv-type-cond-keep.deliv-type-code  no-error .
    if not available buf_delivery-type then do:
      message
      vss-workfile vss-revision vss-description skip
      "Íåïğàâèëüíàÿ ññûëêà íà ÒÈÏ ÄÎÑÒÀÂÊÈ" skip
      "êîä" c-deliv-type-cond-keep.deliv-type-code skip
       view-as alert-box error .
      undo main-block, return error.
    end.
    find first buf_condition-keeping no-lock where
               buf_condition-keeping.cond-keep-code = c-deliv-type-cond-keep.cond-keep-code  no-error .
    if not available buf_condition-keeping then do:
      message
      vss-workfile vss-revision vss-description skip
      "Íåïğàâèëüíàÿ ññûëêà íà ÓÑËÎÂÈß ÕĞÀÍÅÍÈß" skip
      "êîä" c-deliv-type-cond-keep.cond-keep-code skip
       view-as alert-box error .
      undo main-block, return error.
    end.
    find first buf_deliv-type-cond-keep no-lock where
               buf_deliv-type-cond-keep.deliv-type-code = c-deliv-type-cond-keep.deliv-type-code
           AND buf_deliv-type-cond-keep.cond-keep-code = c-deliv-type-cond-keep.cond-keep-code
               no-error .
    if not available buf_deliv-type-cond-keep then do:
      message
      vss-workfile vss-revision vss-description skip
      "Íåïğàâèëüíàÿ ññûëêà íà ÂÎÕÌÎÆÍÎÑÒÜ ÄÎÑÒÀÂÊÈ ÏÎ ÓÑËÎÂÈßÌ ÕĞÀÍÅÍÈß" skip
      "êîä òèïà äîñòàâêè" c-deliv-type-cond-keep.deliv-type-code skip
      "êîä óñëîâèé õğàíåíèÿ" c-deliv-type-cond-keep.cond-keep-code skip
       view-as alert-box error .
      undo main-block, return error.
    end.
  end.
  if not g#news then do:
    if ( g#db-num > 0 ) then do:
      message
      vss-workfile vss-revision vss-description skip
      "Íåëüçÿ ñîçäàâàòü çàïèñè èñòîğèè ÂÎÇÌÎÆÍÎÑÒÈ ÄÎÑÒÀÂÊÈ ÏÎ ÓÑËÎÂÈßÌ ÕĞÀÍÅÍÈß â ÓÁÄ" skip
      view-as alert-box error .
      undo main-block, return error.
    end.
  end.
  run str/callnews.p
    (input "c-deliv-type-cond-keep"
    ,input (buffer ub.c-deliv-type-cond-keep:handle)
    ).
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input 'update':U
        , input 'c-deliv-type-cond-keep':U
        , input ( buffer ub.c-deliv-type-cond-keep:handle )
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
