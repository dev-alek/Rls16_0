block-level on error undo, throw.
define input parameter v-wth-doc-doc-code like ub.wth-doc.doc-code no-undo .
define input parameter p-check-inv        as logical no-undo .
define input parameter p-document-fact-order like ub.wth-doc.fact-order no-undo .
define input parameter p-fact-close       as logical no-undo .
define input parameter p-is-news          as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Блокировка МЦ по документу".
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
define temp-table temp-wth-pl no-undo
  field w-p-code like ub.wth-place.w-p-code
  index xpk is primary w-p-code
.
define buffer buf_wth-doc  for ub.wth-doc .
define buffer buf_wth-line for ub.wth-line .
define buffer buf_wth-obj  for ub.wth-obj .
define buffer buf_wealth   for ub.wealth .
define buffer inv_wth-line for ub.wth-line .
define buffer inv_wth-doc  for ub.wth-doc .
define variable l-reserv-pl-code         as logical no-undo .
define variable num_rec       as integer   no-undo initial 0 .
define variable start_time    as integer   no-undo .
define variable curr_time     as integer   no-undo .
main-block:
do transaction
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  find first buf_wth-doc no-lock
    where buf_wth-doc.doc-code = v-wth-doc-doc-code
    no-error .
  if not available buf_wth-doc then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден документ" skip
      "Документ" v-wth-doc-doc-code skip
      view-as alert-box error .
    undo main-block, return error .
  end.
  if p-document-fact-order = ? then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Документ" v-wth-doc-doc-code skip
      "Логический номер закрываемого документа" p-document-fact-order skip
      view-as alert-box error .
    undo main-block, return error .
  end.
  def frame a
    "Блокировка МЦ на объекте." skip
    num_rec           format ">>>>>>>9"   label "Обработано МЦ" skip
    buf_wth-line.wth-code format ">>>>>>>>9"      label "Текущая МЦ" skip
    curr_time         format "->>>>>>>>9" label "Время" skip
    with view-as dialog-box side-labels three-d
    title "Документ " + v-wth-doc-doc-code .
  assign
    start_time = time
  .
  view frame a.
  for each buf_wth-line no-lock
    where buf_wth-line.doc-code = v-wth-doc-doc-code
    break by
    buf_wth-line.wth-code
  on error undo main-block, return error
  :
    find first buf_wealth no-lock
      where buf_wealth.wth-code = buf_wth-line.wth-code
      no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена МЦ" skip
        "Документ" buf_wth-line.doc-code skip
        "Код МЦ" buf_wealth.wth-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo main-block, return error .
    end.
    assign
      num_rec   = num_rec + 1
    .
    if num_rec mod 10 = 0 then do:
      assign
        curr_time = time - start_time
      .
      display
        num_rec buf_wth-line.wth-code curr_time
        with frame a.
      process events .
    end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run wthobjcr in g#library
  (input  buf_wth-line.obj-type
  ,input  buf_wth-line.obj-code
  ,input  buf_wth-line.wth-code
  ,buffer buf_wth-obj
  ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Невозможно найти wth-obj" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo main-block, return error .
    end.
        DEFINE VARIABLE my-rec as recid no-undo .
    my-rec = recid(buf_wth-obj).
    find first buf_wth-obj exclusive-lock where
              recid(buf_wth-obj) = my-rec.
    release buf_wth-obj .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run wthcheck in g#library
  (input buf_wth-line.obj-type
  ,input buf_wth-line.obj-code
  ,input buf_wth-line.wth-code
  ,input ''
  ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при проверке целостности товара" skip
        "Объект" buf_wth-line.obj-type buf_wth-line.obj-code skip
        "Код МЦ" buf_wth-line.wth-code skip
        error-status :get-message(1) skip
        view-as alert-box .
      undo main-block, return error .
    end.
    if  p-fact-close = true
    and p-is-news    = false
    and buf_wth-doc.ext-doc-type <> 'dc':U
    then do:
      if first-of(buf_wth-line.wth-code) then do:
        for each temp-wth-pl
        on error undo main-block, return error
        :
          delete temp-wth-pl .
        end.
      end.
        find first temp-wth-pl
          where temp-wth-pl.w-p-code = buf_wth-line.w-p-code
          no-error .
        if not available temp-wth-pl then do:
          create temp-wth-pl .
          assign
            temp-wth-pl.w-p-code = buf_wth-line.w-p-code
          .
        end.
        if buf_wth-doc.inter_ then do:
          find first temp-wth-pl
            where temp-wth-pl.w-p-code = buf_wth-line.out-code
            no-error .
          if not available temp-wth-pl then do:
            create temp-wth-pl .
            assign
              temp-wth-pl.w-p-code = buf_wth-line.out-code
            .
           end.
         end.
          if last-of(buf_wth-line.wth-code) then do:
            for each temp-wth-pl
            on error undo main-block, return error
            :
              run trg/lockplgw.p
                (input buf_wth-line.obj-type
                ,input buf_wth-line.obj-code
                ,input buf_wealth.wth-code
                ,input temp-wth-pl.w-p-code
                ,input "check-doc-on=false"
                ,input ""
                ) no-error .
              if error-status :error then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "МЦ заблокирована на МХ" skip
                  "Объект" buf_wth-line.obj-type buf_wth-line.obj-code skip
                  "МХ" temp-wth-pl.w-p-code skip
                  "Код МЦ" buf_wealth.wth-code skip
                  error-status :get-message(1) skip
                  return-value skip
                  view-as alert-box error .
                undo main-block, return error .
              end.
            end.
          end.
    end.
    if p-check-inv then do:
      define variable l-inv-on as logical no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run wthobjat in g#library
  (input  buf_wth-line.obj-type
  ,input  buf_wth-line.obj-code
  ,input  buf_wth-line.wth-code
  ,input  'inv-on=request'
  ,output l-inv-on
  ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка получения признака МЦ на объекте" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo main-block, return no-apply .
      end.
      if l-inv-on then do:
        for each inv_wth-line no-lock
          where inv_wth-line.obj-type  = buf_wth-line.obj-type
            and inv_wth-line.obj-code  = buf_wth-line.obj-code
            and inv_wth-line.wth-code  = buf_wth-line.wth-code
            and inv_wth-line.status_   = 'разрешен':U
        ,first inv_wth-doc no-lock
          where inv_wth-doc.doc-code = inv_wth-line.doc-code
            and inv_wth-doc.doc-type = 'инв':U
            and inv_wth-doc.status_  = 'разрешен':U
        on error undo main-block, return error
        :
          message
            "МЦ :" buf_wealth.wth-code skip
            buf_wealth.wth-name skip
            "на объекте" inv_wth-line.obj-type inv_wth-line.obj-code skip
            "сейчас в инвентаризации (Документ №" inv_wth-line.doc-code ")." skip
            view-as alert-box information .
          undo main-block, return error .
        end.
        message
          "МЦ :" buf_wth-line.wth-code skip
          "на объекте" buf_wth-line.obj-type buf_wth-line.obj-code skip
          "Отмечен, как принадлежащий инвентризации" skip
          "Документ инвентаризации не найден" skip
          view-as alert-box information .
        undo main-block, return error .
      end.
    end.
    if false  then do:
      for each inv_wth-line no-lock
        where inv_wth-line.obj-type     = buf_wth-line.obj-type
          and inv_wth-line.obj-code     = buf_wth-line.obj-code
          and inv_wth-line.wth-code     = buf_wth-line.wth-code
          and inv_wth-line.ext-doc-type = 'iy':U
          and inv_wth-line.status_      = 'разрешен':U
          and inv_wth-line.doc-code     <> v-wth-doc-doc-code
      ,first ub.wth-doc no-lock
        where ub.wth-doc.doc-code       = inv_wth-line.doc-code
      on error undo main-block, return error
      :
        message
          "На объекте" inv_wth-line.obj-type inv_wth-line.obj-code skip
          "существует инвентаризация (Документ №" inv_wth-line.doc-code ") по МЦ" skip
          buf_wealth.wth-code skip
          buf_wealth.wth-name skip
          "Находящаяся в статусе '" STRING(ub.wth-doc.status_) "'." skip
          view-as alert-box information .
        undo main-block, return error .
      end.
    end.
    if p-document-fact-order <> 0 then do:
      for each inv_wth-line no-lock
        where inv_wth-line.obj-type     = buf_wth-line.obj-type
          and inv_wth-line.obj-code     = buf_wth-line.obj-code
          and inv_wth-line.wth-code     = buf_wth-line.wth-code
          and inv_wth-line.ext-doc-type = 'iy':U
          and inv_wth-line.status_      = 'факт':U
          and inv_wth-line.fact-order   > p-document-fact-order
      on error undo main-block, return error
      :
        message
          "На объекте" inv_wth-line.obj-type inv_wth-line.obj-code skip
          "существует инвентаризация (Документ №" inv_wth-line.doc-code ") по МЦ" skip
          buf_wealth.wth-code skip
          buf_wealth.wth-name skip
          "с большим логическим номером " inv_wth-line.fact-order "." skip
          "Невозможно закрыть документ с логическим номером" p-document-fact-order "." skip
          view-as alert-box information .
        undo main-block, return error .
      end.
    end.
  end.
end.
