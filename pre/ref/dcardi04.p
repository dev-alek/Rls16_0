block-level on error undo, throw.
define input parameter p-d-card                 like ub.dis-card.d-card no-undo .
define input parameter p-type                   like ub.dis-card.type no-undo .
define input parameter p-emitent-host-code      like ub.dis-card.emitent-host-code no-undo .
define input parameter p-issue-code             like ub.dis-card.issue-code no-undo .
define output parameter p-can-issue              as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dcardi04.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/dcardi04.p $":U .
define variable vss-description as character no-undo init "Проверка возможности ввода ДК, по соответствующей маске и коду объекта выдачи".
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
      p-vss-parameters = substitute('&1|&2|&3|&4':u,p-d-card,p-type,p-emitent-host-code,p-issue-code)
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function check-by-mask returns logical (
  input p-mask  as character
  ,input p-str as character
   ,output p-descr as character
  ).
define variable ii as integer no-undo .
define variable v-max as integer no-undo .
define variable v-mask-char as character no-undo .
assign
v-max = length (p-mask).
_do:
do ii = 1 to v-max:
  assign
  v-mask-char = substring(p-mask, ii, 1).
  if v-mask-char = chr(63) then NEXT _do.
  if v-mask-char = "*":U then do:
    if ii < v-max then do:
      assign
      p-descr = substitute("неверная маска &1: звездочка может быть только последним символом маски").
      return no .
    end.
    return yes.
  end.
  else do:
    if v-mask-char <> substring(p-str, ii, 1) then do:
      assign
      p-descr = substitute("№ ДК &1 не соответствует МАСКЕ &2", p-str, p-mask).
      return no.
    end.
    next _do.
  end.
end.
if v-mask-char = chr(63) and v-max = length(p-str) then return yes.
end function.
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-descr     as character no-undo .
define variable v-is-correct as logical no-undo .
define variable v-found      as logical no-undo .
define variable v-type       as character no-undo .
define buffer buf_dis-card-mask for ub.dis-card-mask.
define buffer buf_dis-card-type for ub.dis-card-type .
do
on error undo, return error substitute("&1 &2 &3:&4&5 &6"
                                        , vss-workfile
                                        , vss-revision
                                        , vss-description
                                        , chr(10)
                                        , error-status:get-message(1)
                                        , return-value )
:
  if p-issue-code = ?
  or p-issue-code = 0 then do:
     undo, return error substitute( "Не опеределен код магазина, выдавшего карту").
  end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  'маг':U
  ,input  p-issue-code
  ,output v-host-code
  )  .
  find first buf_dis-card-type share-lock where
            buf_dis-card-type.emitent-host-code = p-emitent-host-code
        and buf_dis-card-type.type = p-type
        and buf_dis-card-type.host-code = 0
        and buf_dis-card-type.obj-type = '':U
        and buf_dis-card-type.obj-code = 0 .
  if buf_dis-card-type.check-by-mask = 0 then do:
    assign
    p-can-issue = yes.
    return.
  end.
  _maska:
  for each buf_dis-card-mask no-lock where
          buf_dis-card-mask.emitent-host-code = p-emitent-host-code
      AND buf_dis-card-mask.type              = p-type
      AND buf_Dis-card-mask.stts              = integer('0':U)
  by buf_Dis-card-mask.host-code
  by buf_Dis-card-mask.obj-type
  by buf_Dis-card-mask.obj-code
  by buf_Dis-card-mask.rank:
    if buf_dis-card-type.ho-join = 1
    and
    buf_dis-card-mask.host-code <> 0
    And buf_dis-card-mask.host-code <> v-host-code then next.
    if buf_dis-card-type.ho-join = 1
    and
    buf_dis-card-mask.obj-type <> "":U
    AND
       (buf_dis-card-mask.obj-type <> 'маг':U
    or buf_dis-card-mask.obj-code <> p-issue-code) then NEXT.
    if buf_dis-card-mask.use-on = integer('1':U) then NEXT.
    assign
    v-found = yes
    v-descr = "":U
    .
    assign
    v-is-correct = check-by-mask (buf_dis-card-mask.mask,  p-d-card, output v-descr)
    no-error
    .
    if error-status:error then undo, return error v-descr.
    if v-is-correct then do:
      assign
      p-can-issue = yes.
      return .
    end.
  end.
  if not v-found then do:
    return substitute("Для карты &1 (тип &2 эмитент &3) не определено ни одной действующей маски, для объекта выдачи карты маг&4"
                                  , p-d-card
                                  , p-type
                                  , p-emitent-host-code
                                  , p-issue-code).
  end.
  else do:
    return substitute("Карта &1 (тип &2 эмитент &3) не соответствует ни одной действующей маски, для объекта выдачи карты маг&4"
                                  , p-d-card
                                  , p-type
                                  , p-emitent-host-code
                                  , p-issue-code).
  end.
end.
