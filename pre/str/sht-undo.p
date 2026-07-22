block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define variable vss-revision    as character no-undo init "$Revision: f9f9d1396dd0, 1038, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Fri Oct 06 18:30:18 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sht-undo.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/sht-undo.p $":U .
define variable vss-description as character no-undo init "Отмена смены".
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable s-date                  as date         no-undo.
define variable s-num                   as integer      no-undo.
define variable s-name                  as character    no-undo.
define variable is-super                as logical      no-undo.
define variable is-closed               as logical      no-undo.
define variable v-have-docs             as logical      no-undo.
define variable v-doc-type              as character    no-undo.
define variable v-doc-code              as character    no-undo.
define variable v-comment               as character    no-undo.
define variable glog                    as logical      no-undo .
define variable v-cur-date-error-code   as integer      no-undo.
define buffer buf_shift-obj for ub.shift-obj .
define variable v-vid-action        as integer no-undo .
define variable v-vid-ok            as logical  no-undo .
define variable v-vid-mes           as character no-undo .
define variable v-vid-param         as longchar no-undo .
define variable v-shift-staff-list  as character no-undo .
define variable v-shift-manager     as character no-undo .
define buffer buf_rvs-doc       for ub.rvs-doc.
define buffer buf_shift-period  for ub.shift-period .
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,input  'shift-on=request'
  ,output glog
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при запуске процедуры objat" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  return.
end.
if not glog then do:
  message
    vss-workfile vss-revision vss-description skip
    "На объекте выключены смены." skip
    "Работа со сменами невозможна." skip
    "Объект:" p-curr-obj-type p-curr-obj-code skip
    view-as alert-box error .
  return.
end.
assign
  is-super = no
.
define variable v-chk-act-host-code as integer   no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,output v-chk-act-host-code
  )  .
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_shift_super':U
    ,input  'object':U
    ,input  v-chk-act-host-code
    ,input  p-curr-obj-type
    ,input  p-curr-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output glog
    )  .
end.
if glog then do:
  assign
    is-super = yes
  .
end.
else do:
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_shift_regular':U
    ,input  'object':U
    ,input  v-chk-act-host-code
    ,input  p-curr-obj-type
    ,input  p-curr-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output glog
    )  .
end.
end.
if not glog then do:
  message
    "Вы не имеете прав для работы со сменами." skip
    "Объект:" p-curr-obj-type p-curr-obj-code
    view-as alert-box.
  return.
end.
if not is-super then do:
  message
    "Отменить смену может только менеджер." skip
    "Объект:" p-curr-obj-type p-curr-obj-code
    view-as alert-box.
  return.
end.
else do:
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_shift_cancel':U
    ,input  'object':U
    ,input  v-chk-act-host-code
    ,input  p-curr-obj-type
    ,input  p-curr-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output glog
    )  .
end.
end.
if not glog then do:
  message
    "Вы не имеете право для отмены смены." skip
    "Объект:" p-curr-obj-type p-curr-obj-code
    view-as alert-box.
  return.
end.
find first buf_shift-obj where
           buf_shift-obj.obj-type = p-curr-obj-type and
           buf_shift-obj.obj-code = p-curr-obj-code and
           buf_shift-obj.status_ = 'тек':U
           use-index pi no-error.
if available buf_shift-obj then
  is-closed = no.
else do:
  find last buf_shift-obj where
            buf_shift-obj.obj-type = p-curr-obj-type and
            buf_shift-obj.obj-code = p-curr-obj-code and
            buf_shift-obj.status_ = 'зкр':U
            use-index pi no-error.
  if available buf_shift-obj then
    is-closed = yes.
  else do:
    message
      "На текущем объекте не найдено ни одной смены." skip
      "Нечего отменять."
      view-as alert-box.
    return.
  end.
end.
assign
  s-date = buf_shift-obj.shift-date
  s-num  = buf_shift-obj.shift-num
  s-name = buf_shift-obj.shift-name
.
If not is-closed then do:
    run check-opened-docs in this-procedure (
          input v-cntxt-db-num
        , input buf_shift-obj.obj-type
        , input buf_shift-obj.obj-code
        , input buf_shift-obj.shift-date
        , input buf_shift-obj.shift-num
        , output v-have-docs
        , output v-doc-type
        , output v-doc-code
        , output v-comment
    ).
    if v-have-docs = yes
    then do:
        for each ub.shift-staff no-lock where ub.shift-staff.obj-type = buf_shift-obj.obj-type
                                          and ub.shift-staff.obj-code = buf_shift-obj.obj-code
                                          and ub.shift-staff.shift-num = buf_shift-obj.shift-num
                                          and ub.shift-staff.shift-date = buf_shift-obj.shift-date
                                          and ub.shift-staff.next-shift = no :
            if ub.shift-staff.staff-role
            then
            assign
                v-shift-manager = ub.shift-staff.name
            .
            else
            assign
                v-shift-staff-list = v-shift-staff-list + (if v-shift-staff-list = "" then "" else ", ") + ub.shift-staff.name
            .
        end.
        v-vid-action = 53 .
        v-vid-param = "SHOP_NUM=" + string(buf_shift-obj.obj-code) + chr(4) +
                      "SHIFT_NUM=" + string(buf_shift-obj.shift-num) + string(buf_shift-obj.shift-date, "99999999") + chr(4) +
                      "ShiftManager=" + v-shift-manager + chr(4) +
                      "ShiftStaff=" + v-shift-staff-list + chr(4) +
                      "RESULT=1" + chr(4) +
                      "Description=Нельзя отменить смену. На объекте есть  документы.".
        run trg/userlog.p (
              input 'update_err':U
            , input 'shift-obj':U
            , input ( buffer buf_shift-obj :handle )
            , input v-vid-action
            , input v-vid-param
        ) no-error.
        if error-status :error
        then do:
            undo, return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
                                , chr(10)
                                , vss-workfile
                                , return-value
                                , error-status :get-message ( 1 ) ).
        end.
        message
            "Нельзя отменить смену. На объекте есть  документы."
            skip (1)
            skip "Объект:" p-curr-obj-type p-curr-obj-code
            skip "Тип документов:   " v-doc-type
            skip "Номера документов:" v-doc-code
            skip v-comment
            skip 'Смена ' buf_shift-obj.shift-num 'от' buf_shift-obj.shift-date
        view-as alert-box error
        title "Отмена текущей смены".
        return.
end.
end.
glog = no.
message
  "Отменить смену по" p-curr-obj-type p-curr-obj-code skip
  "Дата начала смены:" s-date skip
  "Номер смены:" s-name skip
  "Порядок смены:" s-num  "?"
  view-as alert-box question buttons OK-Cancel update glog.
if not glog then
  return.
if is-closed then do:
  undo-closed:
  do transaction on error undo undo-closed, return on stop undo undo-closed, return:
    find first buf_rvs-doc exclusive-lock
         where buf_rvs-doc.obj-type   = buf_shift-obj.obj-type
           and buf_rvs-doc.obj-code   = buf_shift-obj.obj-code
           and buf_rvs-doc.shift-date = buf_shift-obj.shift-date
           and buf_rvs-doc.shift-num  = buf_shift-obj.shift-num
           and buf_rvs-doc.status_    = 'факт':U
           and buf_rvs-doc.rvs-type   = 'смена':U
    no-error.
    if available buf_rvs-doc then do:
        assign
        buf_rvs-doc.rvs-type   = 'контроль':U
        buf_rvs-doc.is-full = yes
        .
        release buf_rvs-doc.
    end.
    else if locked(buf_rvs-doc) then do:
        message "Сменная сверка заблокирована!" view-as alert-box.
        return.
    end.
    buf_shift-obj.status_ = 'тек':U.
    for each ub.shift-staff no-lock where ub.shift-staff.obj-type = buf_shift-obj.obj-type
                                      and ub.shift-staff.obj-code = buf_shift-obj.obj-code
                                      and ub.shift-staff.shift-num = buf_shift-obj.shift-num
                                      and ub.shift-staff.shift-date = buf_shift-obj.shift-date
                                      and ub.shift-staff.next-shift = no :
        if ub.shift-staff.staff-role
        then
        assign
            v-shift-manager = ub.shift-staff.name
        .
        else
        assign
            v-shift-staff-list = v-shift-staff-list + (if v-shift-staff-list = "" then "" else ", ") + ub.shift-staff.name
        .
    end.
    for each buf_shift-period exclusive-lock where buf_shift-period.obj-type = buf_shift-obj.obj-type
                                               and buf_shift-period.obj-code = buf_shift-obj.obj-code
                                               and buf_shift-period.shift-num = buf_shift-obj.shift-num
                                               and buf_shift-period.shift-date = buf_shift-obj.shift-date
    :
      delete buf_shift-period .
    end .
      define buffer buf_reportShift for ub.reportShift .
      for each buf_reportShift exclusive-lock where buf_reportShift.shift-date = buf_shift-obj.shift-date and
          buf_reportShift.shift-num = buf_shift-obj.shift-num and buf_reportShift.obj-code = buf_shift-obj.obj-code and
          buf_reportShift.obj-type = buf_shift-obj.obj-type:
          delete buf_reportShift .
      end.
    release buf_shift-obj no-error.
    if error-status:error
    then do :
        v-vid-action = 53 .
        v-vid-param = "SHOP_NUM=" + string(buf_shift-obj.obj-code) + chr(4) +
                      "SHIFT_NUM=" + string(buf_shift-obj.shift-num) + string(buf_shift-obj.shift-date, "99999999") + chr(4) +
                      "ShiftManager=" + v-shift-manager + chr(4) +
                      "ShiftStaff=" + v-shift-staff-list + chr(4) +
                      "RESULT=1" + chr(4) +
                      "Description=" + error-status :get-message(1) .
        run trg/userlog.p (
              input 'update_err':U
            , input 'shift-obj':U
            , input ( buffer buf_shift-obj :handle )
            , input v-vid-action
            , input v-vid-param
        ) no-error.
        if error-status :error
        then do:
            undo, return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
                                , chr(10)
                                , vss-workfile
                                , return-value
                                , error-status :get-message ( 1 ) ).
        end.
    end.
  end.
end.
else do:
  undo-current:
  do transaction on error undo undo-current, return on stop undo undo-current, return:
    buf_shift-obj.status_ = 'ожд':U.
  end.
end.
run mainmenu-disp-mutable in parparentproc (
    output v-cur-date-error-code
).
message
  "Смена отменена." skip
  "Дата начала смены:" s-date skip
  "Номер смены:" s-name skip
  "Порядок смены:" s-num
  view-as alert-box.
procedure check-opened-docs :
define input parameter p-db-num     as integer          no-undo.
define input parameter p-obj-type   as character        no-undo.
define input parameter p-obj-code   as integer          no-undo.
define input parameter p-shift-date as date             no-undo.
define input parameter p-shift-num  as integer          no-undo.
define output parameter p-have-docs as logical          no-undo.
define output parameter p-doc-type  as character        no-undo.
define output parameter p-doc-code  as character        no-undo.
define output parameter p-comment   as character        no-undo.
    define variable v-host-code    as integer      no-undo.
    define buffer buf_inkas         for ub.inkas.
    define buffer buf_rvs-doc       for ub.rvs-doc.
    define buffer buf_trn-doc       for ub.trn-doc.
    define buffer buf_price-doc     for ub.price-doc.
    define buffer buf_fbr-doc       for ub.fbr-doc.
    define buffer buf_chk-doc       for ub.chk-doc.
    define buffer buf_icnt-doc      for ub.icnt-doc.
    define buffer buf_wth-doc       for ub.wth-doc.
    define buffer buf_ord-doc-rcv   for ub.ord-doc-rcv.
    define buffer buf_cash-desk     for ub.cash-desk.
    define buffer buf_ord-doc       for ub.ord-doc.
do
for buf_inkas
  , buf_rvs-doc
  , buf_trn-doc
  , buf_price-doc
  , buf_fbr-doc
  , buf_chk-doc
  , buf_icnt-doc
  , buf_wth-doc
  , buf_ord-doc-rcv
  , buf_cash-desk
  , buf_ord-doc
on error undo, return error
:
    assign
        p-have-docs = no
        p-doc-type = "":U
        p-doc-code = "":U
    .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
    find first buf_rvs-doc no-lock
         where buf_rvs-doc.obj-type   = p-obj-type
           and buf_rvs-doc.obj-code   = p-obj-code
           and buf_rvs-doc.shift-date = p-shift-date
           and buf_rvs-doc.shift-num  = p-shift-num
           and buf_rvs-doc.status_    = 'факт':U
    no-error.
    if available buf_rvs-doc
    then do:
        assign
            p-have-docs = yes
            p-doc-type  = ( if p-doc-type = "":U then "":U else ",":U ) + "закрытая сверка"
            p-doc-code  = ( if p-doc-code = "":U then "":U else ",":U ) + buf_rvs-doc.rvs-code
        .
    end.
    find first buf_inkas no-lock
         where buf_inkas.host-code  = v-host-code
           and buf_inkas.obj-type   = p-obj-type
           and buf_inkas.obj-code   = p-obj-code
           and buf_inkas.shift-date = p-shift-date
           and buf_inkas.shift-num  = p-shift-num
    no-error.
    if available buf_inkas
    then do:
        assign
            p-have-docs = yes
            p-doc-type  = ( if p-doc-type = "":U then "":U else ",":U ) + "продажа"
            p-doc-code  = ( if p-doc-code = "":U then "":U else ",":U ) + buf_inkas.inkas-code
        .
    end.
    find first buf_trn-doc no-lock
         where buf_trn-doc.obj-type   = p-obj-type
           and buf_trn-doc.obj-code   = p-obj-code
           and buf_trn-doc.shift-date = p-shift-date
           and buf_trn-doc.shift-num  = p-shift-num
    no-error.
    if available buf_trn-doc
    then do:
        assign
            p-have-docs = yes
            p-doc-type  = ( if p-doc-type = "":U then "":U else ",":U ) + "складской"
            p-doc-code  = ( if p-doc-code = "":U then "":U else ",":U ) + buf_trn-doc.doc-code
        .
    end.
    find first buf_price-doc no-lock
         where buf_price-doc.obj-type   = p-obj-type
           and buf_price-doc.obj-code   = p-obj-code
           and buf_price-doc.shift-date = p-shift-date
           and buf_price-doc.shift-num  = p-shift-num
    no-error.
    if available buf_price-doc
    then do:
        assign
            p-have-docs = yes
            p-doc-type  = ( if p-doc-type = "":U then "":U else ",":U ) + "переоценка"
            p-doc-code  = ( if p-doc-code = "":U then "":U else ",":U ) + buf_price-doc.doc-num
        .
    end.
    find first buf_fbr-doc no-lock
         where buf_fbr-doc.obj-type   = p-obj-type
           and buf_fbr-doc.obj-code   = p-obj-code
           and buf_fbr-doc.shift-date = p-shift-date
           and buf_fbr-doc.shift-num  = p-shift-num
    no-error.
    if available buf_fbr-doc
    then do:
        assign
            p-have-docs = yes
            p-doc-type  = ( if p-doc-type = "":U then "":U else ",":U ) + "производство"
            p-doc-code  = ( if p-doc-code = "":U then "":U else ",":U ) + buf_fbr-doc.doc-code
        .
    end.
    find first buf_chk-doc no-lock
         where buf_chk-doc.obj-type   = p-obj-type
           and buf_chk-doc.obj-code   = p-obj-code
           and buf_chk-doc.shift-date = p-shift-date
           and buf_chk-doc.shift-num  = p-shift-num
    no-error.
    if available buf_chk-doc
    then do:
        assign
            p-have-docs = yes
            p-doc-type  = ( if p-doc-type = "":U then "":U else ",":U ) + "чек"
            p-doc-code  = ( if p-doc-code = "":U then "":U else ",":U ) + buf_chk-doc.doc-code
        .
    end.
    find first buf_icnt-doc no-lock
         where buf_icnt-doc.obj-type   = p-obj-type
           and buf_icnt-doc.obj-code   = p-obj-code
           and buf_icnt-doc.shift-date = p-shift-date
           and buf_icnt-doc.shift-num  = p-shift-num
    no-error.
    if available buf_icnt-doc
    then do:
        assign
            p-have-docs = yes
            p-doc-type  = ( if p-doc-type = "":U then "":U else ",":U ) + "инв.счетчик ТРК"
            p-doc-code  = ( if p-doc-code = "":U then "":U else ",":U ) + buf_icnt-doc.doc-code
        .
    end.
    find first buf_wth-doc no-lock
         where buf_wth-doc.obj-type   = p-obj-type
           and buf_wth-doc.obj-code   = p-obj-code
           and buf_wth-doc.shift-date = p-shift-date
           and buf_wth-doc.shift-num  = p-shift-num
    no-error.
    if available buf_wth-doc
    then do:
        assign
            p-have-docs = yes
            p-doc-type  = ( if p-doc-type = "":U then "":U else ",":U ) + "перем.матценн."
            p-doc-code  = ( if p-doc-code = "":U then "":U else ",":U ) + buf_wth-doc.doc-code
        .
    end.
    find first buf_ord-doc-rcv no-lock
         where buf_ord-doc-rcv.obj-type   = p-obj-type
           and buf_ord-doc-rcv.obj-code   = p-obj-code
           and buf_ord-doc-rcv.shift-date = p-shift-date
           and buf_ord-doc-rcv.shift-num  = p-shift-num
    no-error.
    if available buf_ord-doc-rcv
    then do:
        assign
            p-have-docs = yes
            p-doc-type  = ( if p-doc-type = "":U then "":U else ",":U ) + "Поставка по заказам"
            p-doc-code  = ( if p-doc-code = "":U then "":U else ",":U ) + buf_ord-doc-rcv.doc-code
        .
    end.
    find first buf_ord-doc no-lock
         where buf_ord-doc.obj-type   = p-obj-type
           and buf_ord-doc.obj-code   = p-obj-code
           and buf_ord-doc.shift-date = p-shift-date
           and buf_ord-doc.shift-num  = p-shift-num
    no-error.
    if available buf_ord-doc
    then do:
        assign
            p-have-docs = yes
            p-doc-type  = ( if p-doc-type = "":U then "":U else ",":U ) + "заказ"
            p-doc-code  = ( if p-doc-code = "":U then "":U else ",":U ) + buf_ord-doc.doc-code
        .
    end.
end.
end procedure.
