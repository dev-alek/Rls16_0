block-level on error undo, throw.
define input  parameter parparentproc  as widget-handle no-undo.
define input  parameter p-action       as character no-undo .
define input  parameter p-type         as character no-undo .
define output parameter p-doc-rec      as recid no-undo .
define input-output parameter  br-handle    as handle   no-undo .
define input-output parameter  bf-handle    as handle   no-undo .
define input-output parameter  next-prev    as logical  no-undo .
define shared buffer shar-buf_ord-doc for ub.ord-doc  .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ord-zakz.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/ord-zakz.p $":U .
define variable vss-description as character no-undo init "Èçìåíèòü, äîáàâèòü , ñêîïèğîâàòü , ïğîñìîòğåòü çàêàç".
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable g#host-code  as integer   no-undo .
define variable store-type   as character no-undo .
define variable store-code   as integer   no-undo .
define variable doc-mode    as character no-undo .
define variable line-mode   as character no-undo .
define variable line-rec    as recid no-undo .
define variable gds-rec     as recid no-undo .
define variable prt-rec     as recid no-undo .
define variable g#log      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
assign
  store-type    = v-cntxt-obj-type
  store-code    = v-cntxt-obj-code
  g#host-code   = v-cntxt-host-code-obj
.
define new shared variable rep-rec   as recid no-undo .
define new shared variable list-mode as character no-undo .
define new shared variable doc-rec   as recid no-undo .
define buffer buf_clients for ub.clients  .
define variable ri-list       as character no-undo .
define variable rr            as recid no-undo .
define variable v-par-prt     as logical no-undo .
define variable g-log         as logical no-undo .
list-mode     = 'Êîíòğàãåíò,Îáîğîòû':U .
if p-action <> 'ÏĞÎÑÌÎÒĞ':U then do:
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  store-type
  ,input  store-code
  ,input  'doc-prt=request'
  ,output v-par-prt
  )  .
end.
  assign
    rep-rec = ?
    doc-rec = ?
  .
  if available shar-buf_ord-doc then do:
    find first buf_clients no-lock where
        buf_clients.obj-code = shar-buf_ord-doc.cli-code  and
        buf_clients.obj-type = shar-buf_ord-doc.cli-type
    no-error.
    if available buf_clients then  rep-rec = recid ( buf_clients ) .
    doc-rec = recid ( shar-buf_ord-doc ).
  end.
  case p-action :
      when 'ÈÇÌÅÍÅÍÈÅ':U then do:
          case shar-buf_ord-doc.doc-type :
          when  'ÎÎ':U
          then do:
            case p-action
            :
              when 'ÄÎÁÀÂËÅÍÈÅ':U
              then do:
define variable vss-include-info3 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_o-o_add-def':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
              end.
              when 'óäàëåíèå':U
              then do:
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_o-o_deletion':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
              end.
              when 'ÈÇÌÅÍÅÍÈÅ':U
              then do:
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_o-o_update':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
              end.
              otherwise do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Íåèçâåñòíûé òèï äåéñòâèÿ" skip
                  "p-action" p-action skip
                  view-as alert-box error .
                undo, return error return-value .
              end.
            end case .
            if not g-log then  return .
            rr =  recid(shar-buf_ord-doc).
            run cus/ord-oou.w (
                input parParentProc ,
                input p-action ,
                input-output rr  ,
                input-output br-handle ,
                input-output next-prev )
                no-error .
          end.
          when  'ÎĞ':U
          then do:
            case p-action
            :
              when 'ÄÎÁÀÂËÅÍÈÅ':U
              then do:
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_o-r_add-def':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
              end.
              when 'óäàëåíèå':U
              then do:
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_o-r_deletion':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
              end.
              when 'ÈÇÌÅÍÅÍÈÅ':U
              then do:
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_o-r_update':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
              end.
              otherwise do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Íåèçâåñòíûé òèï äåéñòâèÿ" skip
                  "p-action" p-action skip
                  view-as alert-box error .
                undo, return error return-value .
              end.
            end case .
            if not g-log then  return .
            rr =  recid(shar-buf_ord-doc).
            run cus/ord-oru.w
              ( parParentProc ,
                input-output rr  ,
                p-action ,
                input-output br-handle ,
                input-output next-prev
                ) no-error .
          end.
          otherwise do:
             run cus/cli-zakz.w ( ParParentProc, "chg":U ,p-type) no-error.
          end.
          end case.
      end.
      when  'ÄÎÁÀÂËÅÍÈÅ':U then do:
          assign
            rep-rec = 0
            doc-rec = 0
          .
           run cus/cli-zakz.w ( ParParentProc , "add":U , p-type) no-error.
      end.
      when  "copy":u  then do:
          run cus/cli-zakz.w ( ParParentProc , p-action , p-type) no-error.
      end.
      when  'ÏĞÎÑÌÎÒĞ':U  then do:
            case shar-buf_ord-doc.doc-type :
            when 'ÎÎ':U   then do:
            rr = recid(shar-buf_ord-doc) .
            run cus/ord-oou.w (
                input parParentProc ,
                input 'ÏĞÎÑÌÎÒĞ':U ,
                input-output rr  ,
                input-output br-handle ,
                input-output next-prev )
                no-error .
            end.
            when 'ÎĞ':U   then do:
            rr = recid(shar-buf_ord-doc) .
            run cus/ord-oru.w (
                input parParentProc ,
                input-output rr  ,
                input 'ÏĞÎÑÌÎÒĞ':U ,
                input-output br-handle ,
                input-output next-prev )
                no-error .
            end.
            otherwise do:
                run cus/lkp-zakz.w
                  ( input parparentproc ,
                    input-output br-handle ,
                    input-output bf-handle ,
                    input-output next-prev
                    ) no-error .
            end.
            end case.
            if error-status :error then message
              vss-workfile vss-revision vss-description skip
              error-status :get-message(1) skip
              return-value skip
              ""
              view-as alert-box error
            .
      end.
  end case.
  if error-status :error then message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    "Îøèáêà " p-action
    view-as alert-box error
  .
  P-DOC-REC = doc-rec .
