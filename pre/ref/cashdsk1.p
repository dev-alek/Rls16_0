block-level on error undo, throw.
define input-output parameter p-doc-rec      as recid no-undo.
define input parameter p-mode                as character no-undo .
define input parameter p-db-num              like ub.cash-desk.db-num             no-undo .
define input parameter p-obj-code            like ub.cash-desk.obj-code           no-undo .
define input parameter p-pos-type            like ub.cash-desk.pos-type           no-undo .
define input parameter p-cash-num            like ub.cash-desk.cash-num           no-undo .
define input parameter p-autonomy            like ub.cash-desk.autonomy           no-undo .
define input parameter p-addr-path           like ub.cash-desk.addr-path          no-undo .
define input parameter p-cash-on             like ub.cash-desk.cash-on            no-undo .
define input parameter p-cash-os             like ub.cash-desk.cash-os            no-undo .
define input parameter p-is-del              like ub.cash-desk.is-del             no-undo .
define input parameter p-remote              like ub.cash-desk.remote             no-undo .
define input parameter p-version             like ub.cash-desk.version            no-undo .
define input parameter p-registration-code   like ub.cash-desk.registration-code  no-undo .
define input parameter p-serial-code         like ub.cash-desk.serial-code        no-undo .
define input parameter p-fr-type             as character no-undo .
define input parameter p-device-kind         as integer no-undo .
define variable vss-revision    as character no-undo init "$Revision: f3ea8f4d0bae, 3346, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2023/05/19 13:37:10 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cashdsk1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/cashdsk1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке кассы".
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
def var vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure is-tpsi-object :
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define output parameter p-is-tpsi-object as logical no-undo .
define variable vss-description as character no-undo init "is-tpsi-object-01: получение признака объекта - участвует в TPSI".
define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable v-attr-value as character no-undo .
define variable v-attr-type as character no-undo .
define variable v-is-tpsi-object as logical no-undo .
define buffer buf_clients for ub.clients.
  do
  on error undo, return error
  :
    find first buf_clients no-lock where
              buf_clients.obj-type = p-obj-type
          AND buf_clients.obj-code = p-obj-code no-error .
    if not available buf_clients then do:
      return error substitute("&1 &2&3 не найден объект", vss-description, p-obj-type, p-obj-code).
    end.
    if not (buf_clients.db-num = g#db-num  or g#db-num = 0) then do:
      return error substitute("&1 &2&3 нельзя определить значение свойства УЧАСТВУЕТ В ТСПИ не в ГБД и не в свое УБД", vss-description, p-obj-type, p-obj-code).
    end.
    run clntattr-value  in this-procedure (
          input  'орг':U
        ,input   buf_clients.host-code
        ,input   'als-gds':U
        ,output v-attr-value
        ,output v-attr-type
                                            ) no-error .
    if not error-status:error
    and logical (v-attr-value) = yes then do:
      assign
      v-is-tpsi-object = yes
      .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'tpsi'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output conf-par
  ,output par-type
  ) no-error .
      if not error-status:error
      and v-is-tpsi-object
      and (conf-par = "yes") then do:
        assign
        p-is-tpsi-object = yes
        .
      end.
    end.
  end.
end procedure.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
procedure thbjattr_code :
   define input  parameter p-upper-code     as character no-undo .
   define input  parameter p-code           as character no-undo .
   define output parameter p-label          as character no-undo .
   define output parameter p-user-can-edit  as logical   no-undo .
   define output parameter p-output-display as logical   no-undo .
   define output parameter p-other          as character no-undo .
   define output parameter p-prop-list      as character no-undo .
   define output parameter p-prop-type-list as character no-undo .
   define output parameter p-prop-label-list as character no-undo .
   define output parameter p-global          as logical no-undo .
   define output parameter p-host           as logical no-undo .
   define output parameter p-shop           as logical no-undo .
   define output parameter p-store          as logical no-undo .
   define output parameter p-db             as logical no-undo .
   define variable p-region as logical no-undo.
   run thbjattr_code_reg in this-procedure (
                                            p-upper-code,
                                            p-code,
                                            output p-label,
                                            output p-user-can-edit,
                                            output p-output-display,
                                            output p-other,
                                            output p-prop-list,
                                            output p-prop-type-list,
                                            output p-prop-label-list,
                                            output p-global,
                                            output p-host,
                                            output p-shop,
                                            output p-store,
                                            output p-db,
                                            output p-region
                                            ).
end procedure.
procedure thbjattr_code_reg :
define input  parameter p-upper-code     as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-label          as character no-undo .
define output parameter p-user-can-edit  as logical   no-undo .
define output parameter p-output-display as logical   no-undo .
define output parameter p-other          as character no-undo .
define output parameter p-prop-list      as character no-undo .
define output parameter p-prop-type-list as character no-undo .
define output parameter p-prop-label-list as character no-undo .
define output parameter p-global          as logical no-undo .
define output parameter p-host           as logical no-undo .
define output parameter p-shop           as logical no-undo .
define output parameter p-store          as logical no-undo .
define output parameter p-db             as logical no-undo .
define output parameter p-region         as logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_code in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-label
    ,output p-user-can-edit
    ,output p-output-display
    ,output p-other
    ,output p-prop-list
    ,output p-prop-type-list
    ,output p-prop-label-list
    ,output p-global
    ,output p-host
    ,output p-shop
    ,output p-store
    ,output p-db
    ,output p-region
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info2, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_tooltip :
define input  parameter p-upper-code  as character no-undo .
define input  parameter p-code      as character no-undo .
define output parameter p-tooltip   as character no-undo .
define output parameter p-label     as character no-undo .
define output parameter p-tooltip-code as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_tooltip in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-tooltip
    ,output p-label
    ,output p-tooltip-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_legacy :
define input  parameter p-upper-code     as character no-undo .
define output parameter p-level-way      as character no-undo .
define output parameter p-up-way         as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_legacy in g#attr-lib
    (input  p-upper-code
    ,output p-level-way
    ,output p-up-way
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info2, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_value :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define output parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define output parameter p-value-date    like ub.thbj-attr.property-value-date no-undo .
define output parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define output parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define output parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
define output parameter p-type     as character no-undo .
define output parameter p-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_value in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-value-character
    ,output p-value-date
    ,output p-value-decimal
    ,output p-value-integer
    ,output p-value-logical
    ,output p-type
    ,output p-found
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_get-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-param-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-mode as character no-undo .
define input-output parameter table-handle p-tth.
define output parameter p-all-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_get-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-param-code
    ,input  p-mode
    ,input-output table-handle p-tth
    ,output p-all-found
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_write :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define input  parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define input  parameter p-value-date like ub.thbj-attr.property-value-date no-undo .
define input  parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define input  parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define input  parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_write in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,input  p-value-character
    ,input  p-value-date
    ,input  p-value-decimal
    ,input  p-value-integer
    ,input  p-value-logical
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_set-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter table-handle p-tth.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_set-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  table-handle p-tth
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_delete :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code       like ub.thbj-attr.prop-code  no-undo .
define output parameter p-deleted  as logical no-undo.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-deleted
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_delete-section :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_manual-edit :
define input  parameter p-ucode          as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-section-num    as integer no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_manual-edit in g#attr-lib
    (input  p-ucode
    ,input  p-code
    ,output  p-section-num
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cd-attr-code :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  define output parameter p-prop-list      as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-code in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ,output p-prop-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-tooltip :
  define input  parameter p-ucode   as character no-undo .
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-tooltip in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-value :
  define input  parameter p-db-num    like ub.cash-desk-attr.db-num        no-undo .
  define input  parameter p-obj-code  like ub.cash-desk-attr.obj-code      no-undo .
  define input  parameter p-pos-type  like ub.cash-desk-attr.pos-type      no-undo .
  define input  parameter p-cash-num  like ub.cash-desk-attr.cash-num      no-undo .
  define input  parameter p-ucode     like ub.cash-desk-attr.upper-attr-code      no-undo .
  define input  parameter p-code      like ub.cash-desk-attr.attr-code      no-undo .
  define output parameter p-character like ub.cash-desk-attr.attr-value-character    no-undo .
  define output parameter p-date      like ub.cash-desk-attr.attr-value-date         no-undo .
  define output parameter p-decimal   like ub.cash-desk-attr.attr-value-decimal      no-undo .
  define output parameter p-integer   like ub.cash-desk-attr.attr-value-integer      no-undo .
  define output parameter p-logical   like ub.cash-desk-attr.attr-value-logical      no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-value in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
      ,input  p-code
      ,output p-character
      ,output p-date
      ,output p-decimal
      ,output p-integer
      ,output p-logical
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-write :
  define input parameter p-db-num    like ub.cash-desk-attr.db-num     no-undo .
  define input parameter p-obj-code  like ub.cash-desk-attr.obj-code   no-undo .
  define input parameter p-pos-type  like ub.cash-desk-attr.pos-type   no-undo .
  define input parameter p-cash-num  like ub.cash-desk-attr.cash-num   no-undo .
  define input parameter p-ucode     like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input parameter p-code      like ub.cash-desk-attr.attr-code  no-undo .
  define input parameter p-character like ub.cash-desk-attr.attr-value-character no-undo .
  define input parameter p-date      like ub.cash-desk-attr.attr-value-date      no-undo .
  define input parameter p-decimal   like ub.cash-desk-attr.attr-value-decimal   no-undo .
  define input parameter p-integer   like ub.cash-desk-attr.attr-value-integer   no-undo .
  define input parameter p-logical   like ub.cash-desk-attr.attr-value-logical   no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-write in g#attr-lib
      (input p-db-num
      ,input p-obj-code
      ,input p-pos-type
      ,input p-cash-num
      ,input p-ucode
      ,input p-code
      ,input p-character
      ,input p-date
      ,input p-decimal
      ,input p-integer
      ,input p-logical
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-exist :
  define input  parameter p-db-num   like ub.cash-desk-attr.db-num     no-undo .
  define input  parameter p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
  define input  parameter p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
  define input  parameter p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
  define input  parameter p-ucode    like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input  parameter p-code     like ub.cash-desk-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-exist in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-delete :
  define input parameter  p-db-num   like ub.cash-desk-attr.db-num     no-undo .
  define input parameter  p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
  define input parameter  p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
  define input parameter  p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
  define input parameter  p-ucode     like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input parameter  p-code     like ub.cash-desk-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-delete in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-news :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  define output parameter p-from-gbd       as logical   no-undo .
  define output parameter p-from-ubd       as logical   no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-news in g#attr-lib
      (
       input  p-ucode
      ,input  p-code
      ,output p-news
      ,output p-from-gbd
      ,output p-from-ubd
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-hist :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-hist           as logical   no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-hist in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-hist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
function cd-attr-parse-date-time returns date
(input  p-string as character
,output p-time   as integer
):
  define variable v-return-value as date      no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-parse-date-time-proc in g#attr-lib
    (input  p-string
    ,output p-time
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    return ? .
  end.
  return v-return-value .
end function.
procedure last-check-date-time :
  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run last-check-date-time in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
function cd-attr-cd-datetostring returns character
(input  p-date as date
):
  define variable v-return-value as character no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-cd-datetostring-proc in g#attr-lib
    (input  p-date
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    return ? .
  end.
  return v-return-value .
end function.
procedure cd-attr-last-report-params :
  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-last-report-params in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-last-check-params :
  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-last-check-params in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-last-check-date-time :
  define input parameter parparentproc as widget-handle no-undo .
  define input  parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input  parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input  parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input  parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-last-check-maria in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-periodic-tasks :
define input  parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
define input  parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
define input  parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
define input  parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-periodic-tasks in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
function cd-attr_get-attr-int returns integer
(buffer buf_cash-desk for ub.cash-desk
,input p-upper-attr-code as character
,input p-attr-code as character
,output p-mes as character
):
  define variable v-return-value as integer   no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr_get-attr-int-proc in g#attr-lib
    (buffer buf_cash-desk
    ,input  p-upper-attr-code
    ,input  p-attr-code
    ,output p-mes
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    assign
      p-mes = substitute("Неизвестная ошибка при вызове процедуры cd-attr_get-attr-int-proc &1 &2"
                        ,error-status :get-message(1)
                        ,return-value
                        )
    .
    return ? .
  end.
  return v-return-value .
end function.
function cd-attr_get-attr-log returns logical
(buffer buf_cash-desk for ub.cash-desk
,input p-upper-attr-code as character
,input p-attr-code as character
,output p-mes as character
):
  define variable v-return-value as logical   no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr_get-attr-log-proc in g#attr-lib
    (buffer buf_cash-desk
    ,input  p-upper-attr-code
    ,input  p-attr-code
    ,output p-mes
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    assign
      p-mes = substitute("Неизвестная ошибка при вызове процедуры cd-attr_get-attr-log-proc &1 &2"
                        ,error-status :get-message(1)
                        ,return-value
                        )
    .
    return ? .
  end.
  return v-return-value .
end function.
procedure cd-attr_check-marketer :
  define input parameter p-db-num   like ub.cash-desk-attr.db-num     no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
  define input parameter p-ucode     like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input parameter p-code     like ub.cash-desk-attr.attr-code  no-undo .
  define input parameter p-value as character no-undo .
  define input parameter p-mode  as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr_check-marketer in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-manual-edit :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-manual-edit in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-batch-edit :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-batch-edit in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-send-param :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-send-param     as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-send-param in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-send-param
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable v-db-num like ub.db.db-num no-undo .
define variable l-shift-on as logical no-undo .
define variable ans as logical no-undo .
define variable hnum as logical no-undo .
define variable b-hnum as logical no-undo .
define variable dflt-cd       as character      no-undo.
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
define variable conf-attr as character no-undo .
define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable num-cd as integer no-undo .
define variable ii-num-cd as integer no-undo .
define variable v-dopd as decimal no-undo  .
define variable v-dop-path as character no-undo .
define variable v-cd-list as character no-undo .
define variable v-is-tpsi-obj as logical no-undo .
define variable is-thpos as logical no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle
.
define buffer buf_cash-desk for ub.cash-desk.
define buffer buf_shop  for ub.shop.
define buffer buf_clients for ub.clients.
define buffer other_cash-desk for ub.cash-desk.
define buffer man_cash-desk for ub.cash-desk .
define buffer mar_cash-desk for ub.cash-desk.
define temp-table temp-cash-desk no-undo like ub.cash-desk
field tpsi-obj as logical
iNDEX pi is UNIQUE PRIMARY
db-num
obj-code
pos-type
cash-num
INDEX db-stat-type
db-num
cash-on
pos-type
INDEX i-auto
db-num
pos-type
autonomy
INDEX i-del
db-num
is-del
INDEX i-stat is UNIQUE
db-num
obj-code
pos-type
cash-on
cash-num
index iaddr
db-num
tpsi-obj
obj-code
addr-path
index iaddr2
addr-path
.
if p-mode <> 'ДОБАВЛЕНИЕ':U
AND p-mode <> 'ИЗМЕНЕНИЕ':U then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр p-mode" p-mode
  view-as alert-box error .
  return error '':u.
end.
if LOOKUP(p-pos-type, 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,InfoKiosk,pricecheck-Servis+,Emulator-NKT-IBM,MARIA,-,bo,Autotank':U) = 0 then do:
  message
  "Неверный тип кассы" p-pos-type
  view-as alert-box error .
  return error "pos-type":U.
end.
 v-db-num = ibs.th.gbl.gbl-var:g#db-num .
find first buf_clients no-lock where
          buf_clients.obj-code = p-obj-code
      AND buf_clients.obj-type = 'маг':U  no-error .
if not avail buf_clients then dO:
  message
  "Не найден магазин с кодом" p-obj-code
  view-as alert-box error .
  return error "obj-code":U.
end.
if buf_clients.db-num <> v-db-num
or
v-db-num <> p-db-num
then do:
  message
  "Нельзя изменять запись КАССЫ в чужой БД" skip
  "Номер текущей БД" v-db-num "Номер БД кассы" p-db-num "Номер БД магазина" buf_clients.db-num
  view-as alert-box ERROR.
  undo, return error "db-num":U.
end.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  'маг':U
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  )  .
if not p-is-del then do:
  if l-shift-on
  and lookup(p-pos-type, 'IBM':U + chr(44) +
                          'IBM-XML':U + chr(44) +
                          'MARIA':U + chr(44) +
                          'InfoKiosk':U + chr(44) +
                          'Emulator-NKT-IBM':U + chr(44) +
                          'pricecheck-Servis+':U + chr(44) +
                          'Autotank':U + chr(44) +
                          'IBS-TH':U
                          ) = 0 then do:
    message
    substitute("Внимание! На объекте &1 требуется использование смен&2" +
               "эту опцию данный тип кассы &3 не поддерживает.&2&2"
               ,p-obj-code
               ,chr(10)
               ,p-pos-type )
    view-as alert-box ERROR.
    undo, return error "pos-type":U.
  end.
  if p-remote = 1 and
  lookup(p-pos-type, 'IBM':U + chr(44) +
                     'IBM-XML':U + chr(44) +
                     'MARIA':U
                     ) = 0 then do:
    message
    substitute("УДАЛЕННОЙ кассой может быть только касса типа &1 &2 &3 &4"
               ,'IBM':U
               ,'IBM-XML':U
               ,'MARIA':U
               )
    view-as alert-box error .
    undo, return error "remote":U.
  end.
    if entry (lookup (string(p-autonomy), '0,1,2':U), 'Автономная касса,Подчиненная касса,Кассовый менеджер':U) = "":U then  do:
    message
    "Неверное значение АВТОНОМНОСТИ для кассы" p-autonomy
    view-as alert-box error .
    undo, return error "autonomy":U.
  end.
  if NOT (p-pos-type = 'IBM-XML':U
         OR
         p-pos-type = 'NCR-GM':U
         OR
         p-pos-type = 'NCR-AS@R':U
         OR
         p-pos-type = 'MAGIA-XML':U
         OR
         p-pos-type = 'MARIA':U
         OR
         p-pos-type = 'Autotank':U
         )
  and p-autonomy = integer('2':U) then do:
    message
    substitute("В настоящее время поддерживается работа с кассовым менеджером только для касс типа&1&2 &3 &4 &5 &6"
               , chr(10)
               , 'IBM-XML':U
               , 'NCR-GM':U
               , 'NCR-AS@R':U
               , 'MAGIA-XML':U
               , 'MARIA':U
               , 'Autotank':U
               )
    view-as alert-box error .
    undo, return error "autonomy":U.
  end.
  if p-pos-type <> 'IBM-XML':U
  and p-pos-type <> 'NCR-GM':U
  and p-pos-type <> 'NCR-AS@R':U
  and p-pos-type <> 'MAGIA-XML':U
  and p-pos-type <> 'MARIA':U
  and p-pos-type <> 'Autotank':U
  and p-autonomy = integer('1':U) then do:
    message
    substitute("В настоящее время поддерживается работа с подчиненными кассами только типа&1&2 &3 &4 &5 &6"
               ,chr(10)
               ,'IBM-XML':U
               ,'NCR-GM':U
               ,'NCR-AS@R':U
               ,'MAGIA-XML':U
               ,'MARIA':U
               ,'Autotank':U )
    view-as alert-box error .
    undo, return error "autonomy":U.
  end.
  if p-pos-type = 'IBM-XML':U then do:
    CASE p-autonomy:
      when integer('0':U) then do:
        find first other_cash-desk no-lock where
                  other_cash-desk.db-num = p-db-num
              AND other_cash-desk.obj-code = p-obj-code
              AND other_cash-desk.pos-type = p-pos-type
              AND other_cash-desk.autonomy <> integer('0':U)
              and other_cash-desk.is-del = no
              no-error .
      end.
      otherwise do:
        find first other_cash-desk no-lock where
                  other_cash-desk.db-num = p-db-num
              AND other_cash-desk.obj-code = p-obj-code
              AND other_cash-desk.pos-type = p-pos-type
              AND other_cash-desk.autonomy = integer('0':U)
              and other_cash-desk.is-del = no
              no-error .
      end.
    END CASE.
    if available other_cash-desk then do:
      message
      substitute("На одном объекте не могут одновременно существовать кассы типа &1 автономные и подчиненные(под управлением кассового менеджера)"
                ,'IBM-XML':U)
      view-as alert-box error .
      undo, return error "autonomy":U.
    end.
  end.
  if (p-pos-type = 'MAGIA-XML':U
  or p-pos-type = 'NCR-GM':U
  or p-pos-type = 'MARIA':U
  or p-pos-type = 'Autotank':U
  )
  AND p-autonomy = integer('0':U) then do:
    message
    substitute("В настоящее время  работа с автономными кассами типа&1&2 &3 &4 &5&1" +
               "не поддерживается"
               ,chr(10)
               ,'NCR-GM':U
               ,'MAGIA-XML':U
               ,'MARIA':U
               ,'Autotank':U)
    view-as alert-box error .
    undo, return error "autonomy":U.
  end.
  if p-pos-type = 'InfoKiosk':U
  or p-pos-type = 'pricecheck-Servis+':U
  then do:
    find first buf_cash-desk no-lock where
              buf_cash-desk.db-num = p-db-num
          AND buf_cash-desk.obj-code = p-obj-code
          AND buf_cash-desk.pos-type = p-pos-type no-error .
    if available buf_cash-desk
    and p-mode = 'ДОБАВЛЕНИЕ':U
    then do:
      message
      substitute("В магазине может быть только одна касса типа &1",  p-pos-type)
      view-as alert-box error .
      undo, return error "pos-type":U.
    end.
  end.
  if p-addr-path = ""
  and
  ( p-autonomy <> integer('2':U)
    and p-pos-type <> 'InfoKiosk':U
    and p-pos-type <> 'pricecheck-Servis+':U
    and p-pos-type <> 'r-keeper':U
    and p-pos-type <> 'IBS-TH':U
    and p-pos-type <> 'IBS-TH-MOB':U
    and p-pos-type <> 'Autotank':U
  )
  then do:
    message
    "Не введен адрес-путь к КАССЕ"
    view-as alert-box ERROR .
    undo, return error "addr-path":U.
  end.
  if p-addr-path <> ""
  and (
     p-pos-type = 'r-keeper':U
  or p-pos-type = 'InfoKiosk':U
  or p-pos-type = 'pricecheck-Servis+':U
  or p-pos-type = 'IBS-TH':U
  or p-pos-type = 'IBS-TH-MOB':U
  or (p-pos-type = 'Autotank':U and p-autonomy = integer('1':U))
  )
  then do:
    message
    substitute("Не надо вводить адрес-путь к КАССЕ типа &1&2все настройки задаются в ini-файле", p-pos-type, chr(10))
    view-as alert-box ERROR .
    undo, return error "addr-path":U.
  end.
  if p-pos-type = 'IBS-TH':U then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-thpos'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  '':U
  ,input  yes
  ,output conf-par
  ,output par-type
  ) no-error .
    if error-status:error then do:
      message
      substitute("Ошибка при чтении параметра is-thpos:&1&2&1&3"
                  , chr(10)
                  , error-status:get-message(1)
                  , return-value )
      view-as alert-box error .
      undo, return error "pos-type":U.
    end.
    if par-type <> "L" then do:
      message
      "Неправильный тип параметра is-thpos (должно быть logical)."
      view-as alert-box error.
      undo, return error "pos-type":U.
    end.
    if conf-par <> string(yes) then do:
      message
      substitute("В данной БД не разрешена работа с кассами типа &1&2" +
                 "см параметр is-thpos"
                 , 'IBS-TH':U
                 , chr(10))
      view-as alert-box error .
      undo, return error "pos-type":U.
    end.
  end.
  define variable l-ipaddr as character no-undo .
  CASE p-pos-type:
    when 'NCR-GM':U or
    when 'MAGIA-XML':U then .
    when 'IBM':U or
    when 'OMRON':U or
    when 'Emulator-NKT-IBM':U then do:
    end.
    when 'IBM-XML':U then do:
      if p-autonomy = integer('2':U)
      then do:
        if p-addr-path <> "":U then do:
          message
          "Для кассы типа" p-pos-type "являющейся кассовым менеджером" skip
          "не надо вводить ПУТЬ(АДРЕС) и протокол работы с кассой"
          view-as alert-box ERROR .
          undo, return error "addr-path":U.
       end.
      end.
      else do:
        if p-autonomy = integer('1':U) then do:
          if LOOKUP(entry(1, p-addr-path, chr(4)), "http,ftp,samba,SMTP":U) = 0 then do:
            message
            "Для подчиненной кассы типа" p-pos-type
            "надо ввести протокол работы с кассой - http,ftp,samba,SMTP!"
            view-as alert-box ERROR .
            undo, return error "addr-path":U.
          end.
        end.
        if p-autonomy = integer('0':U) then do:
          if entry(1, p-addr-path, chr(4)) <>  "http":U then do:
            message
            "Для автономной кассы типа" p-pos-type
            "можно ввести только один протокол работы с кассой - http!"
            view-as alert-box ERROR .
            undo, return error "addr-path":U.
          end.
        end.
        l-ipaddr = entry(2, p-addr-path, chr(4)) .
        if num-entries(l-ipaddr, ":") <> 2 then do:
          message
          "Для автономной кассы типа" p-pos-type
          "надо указать IP адрес и порт в формате NNN.NNN.NNN.NNN:PPPP или DNS-имя кассы и порт в формате DNS:PPPP"
          view-as alert-box ERROR .
          undo, return error "addr-path":U.
        end.
        integer(  entry(2, l-ipaddr, ":")  ) no-error .
        if error-status:error then do:
          message
          "Для автономной кассы типа" p-pos-type
          "порт в IP адресе кассы должен быть цифровым!"
          view-as alert-box ERROR .
          undo, return error "addr-path":U.
        end.
      end.
    end.
    when 'Autotank':U then do:
      if p-autonomy = integer('1':U)
      then do:
        if p-addr-path <> "":U then do:
          message
          "Для подчиненной кассы типа" p-pos-type skip
          "не надо вводить ПУТЬ(АДРЕС) и протокол работы с кассой"
          view-as alert-box ERROR .
          undo, return error "addr-path":U.
       end.
      end.
      else do:
        if p-autonomy = integer('2':U) then do:
          if LOOKUP(entry(1, p-addr-path, chr(4)), "http,ftp,samba,SMTP":U) = 0 then do:
            message
            "Для кассового менеджера типа" p-pos-type
            "надо ввести протокол работы с кассой - http!"
            view-as alert-box ERROR .
            undo, return error "addr-path":U.
          end.
        end.
        l-ipaddr = entry(2, p-addr-path, chr(4)) .
        if num-entries(l-ipaddr, ":") <> 2
        then do:
          message
          "Для кассового менеджера типа" p-pos-type
          "надо указать IP адрес и порт в формате NNN.NNN.NNN.NNN:PPPP или DNS-имя кассы и порт в формате DNS:PPPP"
          view-as alert-box ERROR .
          undo, return error "addr-path":U.
        end.
        integer(  entry(2, l-ipaddr, ":")  ) no-error .
        if error-status:error then do:
          message
          "Для кассового менеджера типа" p-pos-type
          "порт в IP адресе кассы должен быть цифровым"
          view-as alert-box ERROR .
          undo, return error "addr-path":U.
        end.
      end.
    end.
    when 'IPC-Servis+':U
    or
    when 'OMRON-NEW':U then do:
      IF substr(p-addr-path, 2,2) <> ":\" then do:
        message
        "Для кассы типа" p-pos-type
        "надо ввести путь к кассе в формате X:\XXXXXX.... !"
        view-as alert-box ERROR .
        undo, return error "addr-path":U.
      end.
    end.
    when 'MARIA':U then do:
      if p-autonomy = integer('1':U) then do:
        if not can-find(first ub.cash-desk where
                            ub.cash-desk.obj-code = p-obj-code
                        and ub.cash-desk.pos-type  = p-pos-type
                        and ub.cash-desk.autonomy  = integer('2':U)
                        and ub.cash-desk.is-del  = no
                        ) then do:
          message
          substitute("Нельзя добавить/изменить подчиненную кассу типа &1&2" +
                     "На объекте не определен кассовый менеджер этого типа"
                     , 'MARIA':U
                     , chr(10))
          view-as alert-box error .
          undo, return error ''.
        end.
        if LOOKUP(entry(1, p-addr-path, chr(4)), "shared,local,remote,ftp":U) = 0 then do:
          message
          "Для кассы типа" p-pos-type
          "надо ввести протокол работы с кассой - shared,local,remote,ftp!"
          view-as alert-box ERROR .
          undo, return error "addr-path":U.
        end.
        assign
        v-dop-path = entry(2, p-addr-path, chr(4))
        .
        assign
        v-dopd = decimal(entry(3, p-addr-path, chr(4) ))
        no-error .
        if error-status:error
        or v-dopd <> round(v-dopd, 0)
        or v-dopd <= 0
        or string(v-dopd, '9999999999') <> entry(3, p-addr-path, chr(4))
        then do:
          message
          substitute("Для подчиненной кассы типа &1 заводской № кассы должен быть 10-значным числом с лидирующими нулями"
                    ,p-pos-type
                    ,chr(10)
                    )
          view-as alert-box ERROR .
          undo, return error "cash-num":U.
        end.
        v-dopd = 0.
        if p-cash-num <> integer(substring(entry(3, p-addr-path, chr(4)), 7, 10)) then do:
            message
            substitute("Для подчиненной кассы типа &1, № кассы в IBS TH&2должен быть равен 4-ем последним цифрам заводского номера ЭККА"
                      ,p-pos-type
                      ,chr(10)
                      )
            view-as alert-box ERROR .
            undo, return error "cash-num":U.
        end.
        CASE entry(1, p-addr-path, chr(4)):
          when 'local' then do:
            if not v-dop-path begins 'COM' then do:
              message
              substitute("Для кассы типа &1, работающей по протоколу &2&3" +
                        "адрес должен представлять из себя номер COM-порта!"
                        ,p-pos-type
                        ,entry(1, p-addr-path, chr(4))
                        , chr(10)
                        )
              view-as alert-box ERROR .
              undo, return error "addr-path":U.
            end.
            for each other_cash-desk no-lock where
                    other_cash-desk.db-num = p-db-num
                and other_cash-desk.obj-code = p-obj-code
                and other_cash-desk.pos-type = p-pos-type:
              if p-mode <> 'ДОБАВЛЕНИЕ':U
              and p-cash-num = other_cash-desk.cash-num then do:
                next.
              end.
              if other_cash-desk.autonomy = integer('2':U) then do:
                next.
              end.
              if entry(1, other_cash-desk.addr-path) = 'shared' then do:
                message
                substitute("На одном объекте не могут одновременно существовать кассы типа &1 подключенные как <LOCAL>  и <SHARED>"
                          ,'MARIA':U)
                view-as alert-box error .
                undo, return error "addr-path":U.
              end.
            end.
            integer(trim (v-dop-path, 'COM')) no-error .
            if error-status:error
            then do:
              message
              substitute("Для кассы типа &1, работающей по протоколу &2&3" +
                        "адрес должен представлять из себя номер COM-порта, записанный в виде COM[n],&3" +
                        "где n - номер порта"
                        ,p-pos-type
                        ,entry(1, p-addr-path, chr(4))
                        , chr(10)
                        )
              view-as alert-box ERROR .
              undo, return error "addr-path":U.
            end.
          end.
          when 'remote' then do:
            if not v-dop-path begins 'COM' then do:
              message
              substitute("Для кассы типа &1, работающей по протоколу &2&3" +
                        "адрес должен начинаться с номера COM-порта!"
                        ,p-pos-type
                        ,entry(1, p-addr-path, chr(4))
                        , chr(10)
                        )
              view-as alert-box ERROR .
              undo, return error "addr-path":U.
            end.
            integer(trim (entry(1, v-dop-path, '+'), 'COM1')) no-error .
            if error-status:error
            then do:
              message
              substitute("Для кассы типа &1, работающей по протоколу &2&3" +
                        "адрес должен начинаться с номера COM-порта, записанного в виде COM[n],&3" +
                        "где n - номер порта"
                        ,p-pos-type
                        ,entry(1, p-addr-path, chr(4))
                        , chr(10)
                        )
              view-as alert-box ERROR .
              undo, return error "addr-path":U.
            end.
            if num-entries(v-dop-path, '+') <> 2 then do:
              message
              substitute("Для кассы типа &1, работающей по протоколу &2&3" +
                        "адрес должен включать номер модема, записанный в международном формате!"
                        ,p-pos-type
                        ,entry(1, p-addr-path, chr(4))
                        , chr(10)
                        )
              view-as alert-box ERROR .
              undo, return error "addr-path":U.
            end.
            assign
            v-dopd = decimal(entry(2, v-dop-path, '+'))
            no-error .
            if error-status:error
            or v-dopd <> round(v-dopd, 0)
            or v-dopd <= 0 then do:
              message
              substitute("Для кассы типа &1, работающей по протоколу &2&3" +
                        "адрес должен включать номер модема, записанный в международном формате&3" +
                        " - знак '+' а далее только цифры!"
                        ,p-pos-type
                        ,entry(1, p-addr-path, chr(4))
                        , chr(10)
                        )
              view-as alert-box ERROR .
              undo, return error "addr-path":U.
            end.
          end.
          when 'ftp' then do:
          end.
          when 'shared' then do:
            for each other_cash-desk no-lock where
                    other_cash-desk.db-num = p-db-num
                and other_cash-desk.obj-code = p-obj-code
                and other_cash-desk.pos-type = p-pos-type:
              if p-mode <> 'ДОБАВЛЕНИЕ':U
              and p-cash-num = other_cash-desk.cash-num then do:
                next.
              end.
              if other_cash-desk.autonomy = integer('2':U) then do:
                next.
              end.
              if entry(1, other_cash-desk.addr-path) = 'local' then do:
                message
                substitute("На одном объекте не могут одновременно существовать кассы типа &1 подключенные как <LOCAL>  и <SHARED>"
                          ,'MARIA':U)
                view-as alert-box error .
                undo, return error "addr-path":U.
              end.
            end.
          end.
        END CASE.
      end.
      if p-autonomy = integer('2':U) then do:
        if p-addr-path <> '':U then do:
          message substitute("Для кассового менеджера типа &1 НЕ НУЖНО ВВОДИТЬ АДРЕС-ПУТЬ И/ИЛИ ЗАВОДСКОЙ # И/ИЛИ ПАРОЛЬ И/ИЛИ ПРОТОКОЛ", p-pos-type)
          view-as alert-box error .
          undo, return error "addr-path":U.
        end.
      end.
    end.
  end CASE.
  if (p-pos-type = 'IBM':U or
      p-pos-type = 'IBM-XML':U)
    and p-cash-os = "" then do:
    message
    "Неверный тип ОС кассы типа IBM!"
    view-as alert-box ERROR .
    undo, return error "cash-os":U.
  end.
  if (p-pos-type = 'IBS-TH':U
      or
      p-pos-type = 'IBS-TH-MOB':U)
  and p-cash-os <> "WINDOWS" then do:
    message
    substitute("Неверный тип ОС кассы типа &1!", p-pos-type)
    view-as alert-box ERROR .
    undo, return error "cash-os":U.
  end.
  if (( p-cash-num <= 0 ) OR ( p-cash-num = ? ) )
  and p-autonomy <> integer('2':U)
  then do:
    message
    "Номер кассы должен быть больше 0 !"
    view-as alert-box ERROR .
    undo, return error "cash-num":U.
  end.
  if (( p-cash-num <> 0 ) OR ( p-cash-num = ? ) )
  and p-autonomy = integer('2':U)
  then do:
    message
    "Номер кассового менеджера должен = 0 !"
    view-as alert-box ERROR .
    undo, return error "cash-num":U.
  end.
  if p-cash-num > 999 and
  LOOKUP(p-pos-type, 'IBM':U + chr(44) + 'IBM-XML':U) > 0 then do:
    message
    substitute("Номер кассы типа &1 должен быть меньше < 999 ! ", p-pos-type)
    view-as alert-box ERROR .
    undo, return error "cash-num":U.
  end.
  if can-find( FIRST buf_cash-desk WHERE
                    buf_cash-desk.obj-code = p-obj-code
                AND buf_cash-desk.cash-num = p-cash-num
                AND (p-mode = 'ДОБАВЛЕНИЕ':U or
                    recid(buf_cash-desk ) <> p-doc-rec )
              ) then do:
    message
    "В магазине с номером" p-obj-code skip
    "уже есть касса с номером" p-cash-num
    view-as alert-box ERROR .
    undo, return error "cash-num":U.
  end.
  if p-cash-num <> 0 then do:
    FIND FIRST buf_cash-desk WHERE
              buf_cash-desk.cash-num = p-cash-num
          AND buf_cash-desk.db-num = v-db-num
          AND (recid( buf_cash-desk ) <> p-doc-rec
          or
              p-mode = 'ДОБАВЛЕНИЕ':U) NO-LOCK NO-ERROR.
    if available buf_cash-desk then do:
      message
      "Уже имеется касса с номером" buf_cash-desk.cash-num skip
      "в магазине" buf_cash-desk.obj-code skip
      "БД" v-db-num skip(1)
      "Продолжать ?"
      view-as alert-box WARNING buttons yes-no update ans .
      if NOT ans then do:
        undo, return error "":U.
      end.
    end.
  end.
  if p-addr-path <> "":U then do:
    find FIRST buf_cash-desk WHERE
              buf_cash-desk.addr-path = p-addr-path
          AND buf_cash-desk.db-num = p-db-num
          AND buf_cash-desk.is-del = no
          AND (p-mode = 'ДОБАВЛЕНИЕ':U
              or
              recid( buf_cash-desk ) <> p-doc-rec) NO-LOCK NO-ERROR.
    IF AVAIL buf_cash-desk then do:
      ans = FALSE .
      message
      "Уже имеется касса с адресом " p-addr-path
      "Касса номер" buf_cash-desk.cash-num SKIP
      "магазин" buf_cash-desk.obj-code skip
      "БД" buf_cash-desk.db-num skip(1)
      "Продолжать ?"
      view-as alert-box WARNING buttons yes-no update ans .
      if NOT ans then do:
        undo, return error "":U.
      end.
      else do:
        if LOOKUP(p-pos-type, 'IBM':U + chr(44) + 'IBM-XML':U + chr(44) + 'Autotank':U) > 0
        or
        LOOKUP(buf_cash-desk.pos-type, 'IBM':U + chr(44) + 'IBM-XML':U + chr(44) + 'Autotank':U) > 0
        then do:
          FIND FIRST buf_shop NO-LOCK WHERE
                    buf_shop.obj-code = p-obj-code NO-ERROR.
          run adm/shattri.p (
              input "get":U
              ,input  'орг':U
              ,input  buf_shop.host-code
              ,input  'get-chk':U
              ,input  'hnum':U
              ,output v-value-character
              ,output v-value-date
              ,output v-value-decimal
              ,output v-value-integer
              ,output v-value-logical
              ,output v-param-type
              ,INPUT-OUTPUT table-handle v-tth
              ) no-error .
          IF error-status:error then do:
            delete object v-tth.
            message
            substitute("Ошибка при получении опций закачки чеков НА ОБЪЕКТЕ &1&2:&3&4 &5"
                      , 'орг':U
                      , buf_shop.host-code
                      , chr(10)
                      , error-status:get-message(1)
                      , return-value )
            view-as alert-box error .
            return error.
          end.
          delete object v-tth.
          hnum = v-value-logical.
          FIND FIRST buf_shop NO-LOCK WHERE
                  buf_shop.obj-code = buf_cash-desk.obj-code NO-ERROR.
          run adm/shattri.p (
              input "get":U
              ,input  'орг':U
              ,input  buf_shop.host-code
              ,input  'get-chk':U
              ,input  'hnum':U
              ,output v-value-character
              ,output v-value-date
              ,output v-value-decimal
              ,output v-value-integer
              ,output v-value-logical
              ,output v-param-type
              ,INPUT-OUTPUT table-handle v-tth
              ) no-error .
          IF error-status:error then do:
            delete object v-tth.
            message
            substitute("Ошибка при получении опций закачки чеков НА ОБЪЕКТЕ &1&2:&3&4 &5"
                      , 'орг':U
                      , buf_shop.host-code
                      , chr(10)
                      , error-status:get-message(1)
                      , return-value )
            view-as alert-box error .
            return error.
          end.
          delete object v-tth.
          b-hnum = v-value-logical.
          if (hnum or b-hnum) AND (p-obj-code > 999 OR  buf_cash-desk.obj-code > 999) then do:
            message
            "Касса типа IBM c адресом " buf_cash-desk.addr-path skip
            "не может работать  с магазинами, у которых номер больше 999!" skip
            "(параметр НОМЕР МАГАЗИНА ДЛЯ ЧЕКОВ БРАТЬ ИЗ СПУЛОВ для фирмы этого магазина установлен в YES)"
            view-as alert-box ERROR.
            undo, return error "add-path":U.
          end.
          if NOT hnum or not b-hnum then do:
            message
            substitute("Касса типа &1 c адресом &2 не может работать с магазином,&3" +
                      "пока параметр НОМЕР МАГАЗИНА ДЛЯ ЧЕКОВ БРАТЬ ИЗ СПУЛОВ для фирмы магазина &4 не установлен в YES!"
                      , p-pos-type
                      , buf_cash-desk.addr-path
                      , chr(10)
                      , (if not hnum then p-obj-code else buf_cash-desk.obj-code)
                      )
            view-as alert-box ERROR.
            undo, return error "addr-path":U.
          end.
        end.
      end.
    end.
  end.
end.
_MAIN:
DO ON ERROR UNDO, RETURN ERROR return-value
ON STOP UNDO, RETURN ERROR return-value :
  if p-autonomy <> integer('2':U)
  and (p-mode = 'ДОБАВЛЕНИЕ':U or p-is-del = no)
  then  do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'num-cd'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  '':U
  ,input  yes
  ,output conf-par
  ,output par-type
  ) no-error .
    if error-status:error then undo _main, return error return-value .
    if par-type <> "I" then do:
      message
      "Неправильный тип параметра num-cd (должно быть integer)."
      view-as alert-box error.
      undo _main, return error "":U.
    end.
    assign
    num-cd = integer(conf-par)
    no-error .
    if error-status:error then do:
      message
      substitute("Неправильное значение параметра num-cd:&1 (должно быть integer).", conf-par)
      view-as alert-box error.
      undo _main, return error "":U.
    end.
    for each buf_cash-desk no-lock where
            buf_cash-desk.db-num = v-db-num:
      if buf_cash-desk.autonomy = integer('2':U)
      or buf_cash-desk.is-del = yes
      or buf_cash-desk.pos-type = 'InfoKiosk':U
      or buf_cash-desk.pos-type = 'pricecheck-Servis+':U
      then next.
      find first temp-cash-desk where
               temp-cash-desk.db-num = buf_cash-desk.db-num
           and temp-cash-desk.obj-code = buf_cash-desk.obj-code
           and temp-cash-desk.cash-num = buf_cash-desk.cash-num
           and temp-cash-desk.pos-type = buf_cash-desk.pos-type no-error .
      if not available temp-cash-desk then do:
        create temp-cash-desk.
        buffer-copy
        buf_cash-desk to temp-cash-desk
        .
       if buf_cash-desk.pos-type = 'NCR-GM':U
        or buf_cash-desk.pos-type = 'NCR-AS@R':U then do:
          assign
          temp-cash-desk.addr-path = string(buf_cash-desk.cash-num).
        end.
      end.
        if temp-cash-desk.cash-on then do:
        assign
        ii-num-cd = ii-num-cd + 1
        .
        end.
    end.
    if p-mode = 'ДОБАВЛЕНИЕ':U then do:
      if not p-is-del then do:
        create temp-cash-desk.
        assign
        temp-cash-desk.db-num = p-db-num
        temp-cash-desk.obj-code = p-obj-code
        temp-cash-desk.cash-num = p-cash-num
        temp-cash-desk.pos-type  = p-pos-type
        temp-cash-desk.addr-path = p-addr-path
        temp-cash-desk.cash-on   = p-cash-on
        temp-cash-desk.cash-os   = p-cash-os
        temp-cash-desk.remote    = p-remote
        temp-cash-desk.version   = p-version
        temp-cash-desk.autonomy  = p-autonomy
        temp-cash-desk.is-del    = p-is-del
        .
        if temp-cash-desk.cash-on then do:
        assign
        ii-num-cd = ii-num-cd + 1
        .
        end.
      end.
    end.
    for each temp-cash-desk
    where temp-cash-desk.db-num  = v-db-num
    break
    by temp-cash-desk.obj-code:
      if first-of(temp-cash-desk.obj-code) then do:
        v-is-tpsi-obj = no.
        run is-tpsi-object in this-procedure (
                                              input 'маг':U
                                            ,input temp-cash-desk.obj-code
                                            ,output v-is-tpsi-obj ).
      end.
      if v-is-tpsi-obj then
      temp-cash-desk.tpsi-obj = yes.
    end.
    for each temp-cash-desk where
    temp-cash-desk.db-num  = v-db-num
    and  temp-cash-desk.tpsi-obj = yes
    break
    by temp-cash-desk.addr-path
    :
      if temp-cash-desk.addr-path <> '':U then do:
        if first-of(temp-cash-desk.addr-path) then do:
        end.
        else do:
          ii-num-cd = ii-num-cd - 1.
        end.
      end.
    end.
    if ii-num-cd > num-cd
    then do:
      message
      substitute("Превышено максимальное количество включенных касс в БД: &1", num-cd)
      view-as alert-box error .
      undo _main, return error substitute("Превышено максимальное количество включенных касс в БД: &1", num-cd).
    end.
  end.
  if p-pos-type = 'MARIA':U
  then do:
    if p-autonomy = integer('1':U) then
    find first man_cash-desk exclusive-lock where
              man_cash-desk.obj-code = p-obj-code
          and man_cash-desk.pos-type = p-pos-type
          and man_cash-desk.autonomy = integer('2':U) .
    for each mar_cash-desk where
             mar_cash-desk.obj-code = p-obj-code
          and mar_cash-desk.pos-type = p-pos-type
          and mar_cash-desk.autonomy = integer('1':U)
          and mar_cash-desk.is-del   = no:
      if mar_cash-desk.cash-num = p-cash-num then next.
      assign
      v-cd-list = v-cd-list + (if v-cd-list = '':U then '':U else chr(44)) + string(mar_cash-desk.cash-num).
    end.
  end.
  if p-pos-type = 'IBS-TH':U then do:
    if p-fr-type = ''
    or p-fr-type = ?
    or lookup(p-fr-type, 'shtrih-fr-k-01,prim08tk':U) = 0 then do:
      message
      "Не задан или неверный тип ФР"
      view-as alert-box error .
      undo, return error 'fr-type'.
    end.
    if p-serial-code = "" then do:
      message
      "Не задан серийный номер"
      view-as alert-box error .
      undo, return error 'serial-code'.
    end.
    if trim(p-serial-code, "0123456789") <> '' then do:
      message
      "Серийный номер может включать только цифры!"
      view-as alert-box error .
      undo, return error 'serial-code'.
    end.
  end.
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    create ub.cash-desk.
    assign
    ub.cash-desk.db-num = p-db-num
    ub.cash-desk.obj-code = p-obj-code
    ub.cash-desk.cash-num = p-cash-num
    ub.cash-desk.pos-type = p-pos-type
    p-doc-rec = recid(ub.cash-desk)
    .
  end.
  else do:
    FIND FIRST ub.cash-desk where
              recid(ub.cash-desk) = p-doc-rec No-ERROR.
    if not available ub.cash-desk then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись КАССА - p-doc-rec" p-doc-rec
      view-as alert-box error .
      undo, return error '':u.
    end.
    if ub.cash-desk.db-num <> p-db-num
    OR ub.cash-desk.obj-code <> p-obj-code
    OR ub.cash-desk.cash-num <> p-cash-num
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Для уже имеющейся записи нельзя изменить"
      "номер БД, номер магазина, номер кассы" skip
      view-as alert-box ERROR.
      undo, return error '':U.
    end.
    else if ub.cash-desk.pos-type <> p-pos-type
    then do:
       define buffer buf_cash-desk-attr for ub.cash-desk-attr.
       for each buf_cash-desk-attr where buf_cash-desk-attr.db-num   eq ub.cash-desk.db-num
                                     and buf_cash-desk-attr.obj-code eq ub.cash-desk.obj-code
                                     and buf_cash-desk-attr.cash-num eq ub.cash-desk.cash-num
                                     and buf_cash-desk-attr.pos-type eq ub.cash-desk.pos-type
       exclusive-lock:
          buf_cash-desk-attr.pos-type = p-pos-type.
       end.
       ub.cash-desk.pos-type = p-pos-type.
    end.
  end.
  assign
  ub.cash-desk.addr-path = p-addr-path
  ub.cash-desk.cash-on   = (if p-is-del then no else p-cash-on)
  ub.cash-desk.cash-os   = p-cash-os
  ub.cash-desk.remote    = p-remote
  ub.cash-desk.version   = p-version
  ub.cash-desk.autonomy  = p-autonomy
  ub.cash-desk.is-del    = (if p-is-del then not ub.cash-desk.is-del else no)
  ub.cash-desk.registration-code = p-registration-code
  ub.cash-desk.serial-code = p-serial-code
  ub.cash-desk.fr-type = p-fr-type
  ub.cash-desk.device-kind = p-device-kind
  .
  if p-is-del = no
  then
  assign
  v-cd-list = v-cd-list + (if v-cd-list = '':U then '':U else chr(44)) +
             string(ub.cash-desk.cash-num).
  if p-pos-type = 'MARIA':U then do:
    if p-autonomy = integer('2':U) then do:
      ub.cash-desk.addr-path = v-cd-list.
    end.
    else do:
      man_cash-desk.addr-path = v-cd-list.
    end.
  end.
  release ub.cash-desk no-error.
  if error-status:error then do:
    message
    vss-workfile vss-revision vss-description skip
    "Ошибка при сохранении записи КАССЫ" skip
    ERROR-STATUS:GET-NUMBER(1) skip
    view-as alert-box .
    undo, return error "":U.
  end.
  if p-pos-type = 'IBS-TH':U
  and p-mode = 'ДОБАВЛЕНИЕ':U
  then do:
    FOR EACH thbjattr_thbj-attr:
      delete thbjattr_thbj-attr.
    end.
    run adm/shattri.p (
                  input "init":U
                , input 'маг':U
                , input p-obj-code
                , input 'cd-type-IBS-TH':U
                , input "":U
                , output v-value-character
                , output v-value-date
                , output v-value-decimal
                , output v-value-integer
                , output v-value-logical
                , output v-param-type
                , INPUT-OUTPUT TABLE-handle v-tth
                ) no-error .
   if error-status:error then do:
     message
     vss-workfile vss-revision vss-description skip
     "Ошибка при получении настроек кассы по умолчанию"
     error-status:get-message(1) skip
     return-value
     view-as alert-box .
     undo, return error ''.
   end.
    for each thbjattr_thbj-attr
    break
    by thbjattr_thbj-attr.upper-prop-code
    on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
    :
     if thbjattr_thbj-attr.upper-prop-code <> 'cd-type-IBS-TH':U
     then do:
       run update-cda in this-procedure ( buffer thbjattr_thbj-attr) no-error .
       if error-status:error then do:
          message
          vss-workfile vss-revision vss-description skip
          "Ошибка при записи настроек кассы по умолчанию"
          error-status:get-message(1) skip
          return-value
          view-as alert-box .
          undo, return error ''.
       end.
     end.
    end.
  end.
end.
procedure update-cda :
define parameter buffer buf_thbjattr_thbj-attr for thbjattr_thbj-attr.
define buffer buf_cash-desk-attr for ub.cash-desk-attr.
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  find first   buf_cash-desk-attr share-lock where
        buf_cash-desk-attr.db-num = p-db-num
    and buf_cash-desk-attr.obj-code = p-obj-code
    and buf_cash-desk-attr.pos-type = p-pos-type
    and buf_cash-desk-attr.cash-num = p-cash-num
    and buf_cash-desk-attr.upper-attr-code = buf_thbjattr_thbj-attr.upper-prop-code
  and buf_cash-desk-attr.attr-code = buf_thbjattr_thbj-attr.prop-code
  no-error.
  if not available buf_Cash-desk-attr then do:
    create buf_cash-desk-attr.
    assign
    buf_cash-desk-attr.db-num = p-db-num
    buf_cash-desk-attr.obj-code = p-obj-code
    buf_cash-desk-attr.pos-type = p-pos-type
    buf_cash-desk-attr.cash-num = p-cash-num
    buf_cash-desk-attr.upper-attr-code = buf_thbjattr_thbj-attr.upper-prop-code
    buf_cash-desk-attr.attr-code = buf_thbjattr_thbj-attr.prop-code
    .
  end.
  assign
  buf_cash-desk-attr.attr-value-character = buf_thbjattr_thbj-attr.property-value-character
  buf_cash-desk-attr.attr-value-date = buf_thbjattr_thbj-attr.property-value-date
  buf_cash-desk-attr.attr-value-decimal = buf_thbjattr_thbj-attr.property-value-decimal
  buf_cash-desk-attr.attr-value-integer = buf_thbjattr_thbj-attr.property-value-integer
  buf_cash-desk-attr.attr-value-logical = buf_thbjattr_thbj-attr.property-value-logical
  buf_cash-desk-attr.attr-value-type = buf_thbjattr_thbj-attr.prop-value-type
  .
  release buf_cash-desk-attr no-error.
  if error-status:error then do:
    undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
