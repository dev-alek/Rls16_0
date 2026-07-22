block-level on error undo, throw.
define input parameter p-d-card                 like ub.dis-card.d-card no-undo .
define input parameter p-type                   like ub.dis-card.type no-undo .
define input parameter p-emitent-host-code      like ub.dis-card.emitent-host-code no-undo .
define input parameter p-issue-code             like ub.dis-card.issue-code no-undo .
define output parameter p-cli-mask              like ub.dis-card-mask.cli-mask no-undo .
define output parameter p-full-number           like ub.dis-card.d-card no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dcard05.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/dcard05.p $":U .
define variable vss-description as character no-undo init "Определение полного номера карты по первой подходящей маске для данной карты".
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
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-descr     as character no-undo .
define variable v-is-correct as logical no-undo .
define variable v-found      as logical no-undo .
define variable v-type       as character no-undo .
define variable v-d-str   as character no-undo .
define variable ii as integer no-undo .
define variable v-cli-mask as character no-undo .
define variable v-full-number as character no-undo .
define buffer buf_dis-card-mask for ub.dis-card-mask.
do
on error undo, return error substitute("&1 &2 &3:&4&5 &6"
                                        , vss-workfile
                                        , vss-revision
                                        , vss-description
                                        , chr(10)
                                        , error-status:get-message(1)
                                        , return-value )
:
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  'маг':U
  ,input  p-issue-code
  ,output v-host-code
  )  .
  _maska:
  for each buf_dis-card-mask no-lock where
          buf_dis-card-mask.emitent-host-code = p-emitent-host-code
      AND buf_dis-card-mask.type              = p-type
      AND buf_Dis-card-mask.stts              = integer('0':U)
  by buf_Dis-card-mask.host-code
  by buf_Dis-card-mask.obj-type
  by buf_Dis-card-mask.obj-code
  by buf_Dis-card-mask.rank:
    if index(buf_Dis-card-mask.cli-mask, 'D':U) = 0 then next.
    if index(buf_Dis-card-mask.cli-mask, chr(63)) > 0 then next.
    if buf_dis-card-mask.host-code <> 0
    And buf_dis-card-mask.host-code <> v-host-code then next.
    if
    buf_dis-card-mask.obj-type <> "":U
    AND
       (buf_dis-card-mask.obj-type <> 'маг':U
    or buf_dis-card-mask.obj-code <> p-issue-code) then NEXT.
    if buf_Dis-card-mask.use-on = integer('2':U) then NEXT.
    assign
    v-found = yes
    v-descr = "":U
    .
    assign
    v-cli-mask =  buf_dis-card-mask.cli-mask
    v-is-correct = ((num-entries(v-cli-mask, 'D') - 1) = length(p-d-card))
    no-error
    .
    if v-is-correct then do:
      assign
      v-full-number = v-cli-mask
      .
      do ii = 1 to length(p-d-card):
        substring(v-full-number, index(v-full-number, 'D'), 1)  =  substring(p-d-card, ii, 1).
      end.
      if index(v-full-number, 'C') > 0 then do:
        case buf_dis-card-mask.cc-run:
          when integer('1':U) then do:
            run gbl/pluhnalg.p ( input v-full-number, output p-full-number) no-error .
            if error-status:error then do:
              undo, return error substitute("Ошибка при определении КЦ полного номера карты &1 по маске &2:&3&4&3&5"
                                              , p-d-card
                                              , v-cli-mask
                                              , chr(10)
                                              , error-status:get-message(1)
                                              , return-value ).
            end.
          end.
          otherwise do:
            undo, return error substitute("Ошибка при определении полного номера карты &1 по маске &2:&3" +
                                        "Не задан алгоритм расчета КЦ"
                                        , p-d-card
                                        , v-cli-mask
                                        , chr(10)
                                        ).
          end.
        end case.
      end.
      else do:
        p-full-number = v-full-number.
      end.
      p-cli-mask = v-cli-mask.
      return .
    end.
  end.
  if not v-found then do:
    return substitute("Не удалось определить ПОЛНЫЙ номер ДК&5Для карты &1 (тип &2 эмитент &3) не определено ни одной действующей маски, для объекта выдачи карты маг&4"
                                  , p-d-card
                                  , p-type
                                  , p-emitent-host-code
                                  , p-issue-code
                                  , chr(10)
                                  ).
  end.
  else do:
    return substitute("Не удалось определить ПОЛНЫЙ номер ДК&5Карта &1 (тип &2 эмитент &3) не соответствует ни одной действующей маске, для объекта выдачи карты маг&4"
                                  , p-d-card
                                  , p-type
                                  , p-emitent-host-code
                                  , p-issue-code
                                  , chr(10)
                                  ).
  end.
end.
