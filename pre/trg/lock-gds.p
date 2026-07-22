block-level on error undo, throw.
define input parameter v-trn-doc-doc-code like ub.trn-doc.doc-code no-undo .
define input parameter p-check-inv        as logical no-undo .
define input parameter p-check-inv-rasr-minus as logical no-undo .
define input parameter p-document-fact-order like ub.trn-doc.fact-order no-undo .
 define input parameter p-document-fact-order-price like ub.trn-doc.fact-order no-undo.
define input parameter p-fact-close       as logical no-undo .
define input parameter p-is-news          as logical no-undo .
define variable vss-revision    as character no-undo initial "$Revision: f4eb1c45dbd4, 240, rls $":U .
define variable vss-author      as character no-undo initial "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Aug 31 16:26:51 2015 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: lock-gds.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: trg/lock-gds.p $":U .
define variable vss-description as character no-undo initial "Блокировка товаров по документу":U .
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
      p-vss-parameters = substitute('&1|&2|&3|&4|&5|&6|&7',v-trn-doc-doc-code,p-check-inv,p-check-inv-rasr-minus,p-document-fact-order,p-document-fact-order-price,p-fact-close,p-is-news)
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define buffer buf_trn-doc  for ub.trn-doc .
define buffer buf_doc-line for ub.doc-line .
define buffer buf_gds-obj  for ub.gds-obj .
define buffer buf_goods    for ub.goods .
define buffer inv_doc-line for ub.doc-line .
define buffer inv_trn-doc  for ub.trn-doc .
define buffer buf_doc-pl   for ub.doc-pl .
define buffer buf_rvs-doc  for ub.rvs-doc .
define variable l-reserv-pl-code         as logical no-undo .
define variable can-process              as logical no-undo .
define variable v-rvs-list               as character no-undo .
define variable vErrorMessage            as character no-undo .
define variable num_rec       as integer   no-undo initial 0 .
define variable start_time    as integer   no-undo .
define variable curr_time     as integer   no-undo .
main-block :
do transaction
on error undo main-block, return error
:
  find first buf_trn-doc no-lock
    where buf_trn-doc.doc-code = v-trn-doc-doc-code
    no-error .
  if not available buf_trn-doc then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден документ" skip
      "Документ" v-trn-doc-doc-code skip
      view-as alert-box error .
    undo main-block, return error .
  end.
  if p-document-fact-order = ? then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Документ" v-trn-doc-doc-code skip
      "Логический номер закрываемого документа" p-document-fact-order skip
      view-as alert-box error .
    undo main-block, return error .
  end.
 find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
 ub.inv-doc-attr.attr-code = "invMultDevice" and
 ub.inv-doc-attr.attr-value = string(true) no-error .
 if available(ub.inv-doc-attr) then return .
 find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
 ub.inv-doc-attr.attr-code = "correctItogInv" and
 ub.inv-doc-attr.attr-value = string(true) no-error .
 if available(ub.inv-doc-attr) then return .
  def frame a
    "Блокировка товаров на объекте." skip
    num_rec           format ">>>>>>>9"   label "Обработано артикулов" skip
    buf_doc-line.artic format "x(15)"      label "Текущий артикул" skip
    curr_time         format "->>>>>>>>9" label "Время" skip
    with view-as dialog-box side-labels three-d
    title "Документ " + v-trn-doc-doc-code .
  assign
    start_time = time
  .
  view frame a.
  for each buf_doc-line no-lock
    where buf_doc-line.doc-code = v-trn-doc-doc-code
  on error undo main-block, return error
  :
    find first buf_goods no-lock
      where buf_goods.artic     = buf_doc-line.artic
        and buf_goods.prod-type = buf_doc-line.prod-type
        and buf_goods.prod-code = buf_doc-line.prod-code
      no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "Документ" buf_doc-line.doc-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
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
        num_rec buf_doc-line.artic curr_time
        with frame a.
    end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  buf_doc-line.obj-type
  ,input  buf_doc-line.obj-code
  ,input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,buffer buf_gds-obj
  ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Невозможно найти gds-obj" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo main-block, return error .
    end.
    find current buf_gds-obj exclusive-lock .
    release buf_gds-obj .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscheck in g#library
  (input buf_doc-line.obj-type
  ,input buf_doc-line.obj-code
  ,input buf_doc-line.artic
  ,input buf_doc-line.prod-type
  ,input buf_doc-line.prod-code
  ,input ?
  ,input ''
  ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при проверке целостности товара" skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        error-status :get-message(1) skip
        view-as alert-box .
      undo main-block, return error .
    end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn4) <> true) then do:   run str/lib-trn4.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn4) <> true) then do:     message       "Error starting lib-trn4.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn4_gdnorsrv in g#lib-trn4
  (  input buf_doc-line.artic
  ,  input buf_doc-line.prod-type
  ,  input buf_doc-line.prod-code
  ,  input buf_doc-line.doc-code
  , output can-process
  )        no-error .
    if ( error-status :error
         or can-process <> yes
       )
      and p-fact-close = true
      and p-is-news    = false
    then do:
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  buf_doc-line.obj-type
  ,input  buf_doc-line.obj-code
  ,input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,input  'place-rsrv=request'
  ,output l-reserv-pl-code
  ) no-error .
      if l-reserv-pl-code = yes then do:
        assign
          v-rvs-list = "":U
        .
        if buf_trn-doc.doc-type = 'при':U then do:
          for each buf_rvs-doc no-lock
            where buf_rvs-doc.out-code = buf_trn-doc.doc-code
          on error undo, return error return-value
          :
            if v-rvs-list <> "":U then do:
              assign
                v-rvs-list = v-rvs-list + chr(44)
              .
            end.
            assign
              v-rvs-list = v-rvs-list + substitute( "&1", buf_rvs-doc.rvs-code )
            .
          end.
        end.
        for each buf_doc-pl no-lock
          where buf_doc-pl.obj-type = buf_doc-line.obj-type
            and buf_doc-pl.obj-code = buf_doc-line.obj-code
            and buf_doc-pl.out-code = buf_doc-line.doc-code
            and buf_doc-pl.gds-code = buf_goods.gds-code
        on error undo, return error return-value
        :
          run trg/lockplgd.p
            ( input buf_doc-line.obj-type
            , input buf_doc-line.obj-code
            , input buf_doc-pl.pl-code
            , input buf_goods.gds-code
            , input "check-rvs-on=false"
            , input v-rvs-list
            , input false
            ) no-error .
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              "Товар заблокирован на складском месте" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo main-block, return error .
          end.
        end.
      end.
    end.
    if p-check-inv = yes then do:
      define variable l-inv-on as logical no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  buf_doc-line.obj-type
  ,input  buf_doc-line.obj-code
  ,input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,input  'inv-on=request'
  ,output l-inv-on
  ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка получения признака товара на объекте" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo main-block, return no-apply .
      end.
      if l-inv-on then do:
        define variable v-doc-with-inv as logical no-undo .
        assign
          v-doc-with-inv = false
        .
        for each inv_doc-line no-lock
          where ( inv_doc-line.obj-type      = buf_doc-line.obj-type
                  and inv_doc-line.obj-code  = buf_doc-line.obj-code
                  and inv_doc-line.artic     = buf_doc-line.artic
                  and inv_doc-line.prod-type = buf_doc-line.prod-type
                  and inv_doc-line.prod-code = buf_doc-line.prod-code
                  and inv_doc-line.status_   = 'разрешен':U
                )
             or ( inv_doc-line.obj-type      = buf_doc-line.obj-type
                  and inv_doc-line.obj-code  = buf_doc-line.obj-code
                  and inv_doc-line.artic     = buf_doc-line.artic
                  and inv_doc-line.prod-type = buf_doc-line.prod-type
                  and inv_doc-line.prod-code = buf_doc-line.prod-code
                  and inv_doc-line.status_   = 'нередакт':U
                )
        ,first inv_trn-doc no-lock
          where inv_trn-doc.doc-code     = inv_doc-line.doc-code
        on error undo main-block, return error
        :
          if inv_trn-doc.doc-type     = 'инв':U
            and ( inv_trn-doc.status_    = 'разрешен':U
                  or inv_trn-doc.status_ = 'нередакт':U
                )
            and inv_trn-doc.flag_        = true
            and inv_trn-doc.ext-doc-type = 'vt':U
          then do:
            if inv_trn-doc.doc-code = buf_trn-doc.out-code
            then do:
              assign
                v-doc-with-inv = true
              .
            end.
            else do:
              find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = 'invMultDevice' and
              ub.inv-doc-attr.doc-code = inv_trn-doc.doc-code and
              ub.inv-doc-attr.attr-value = string(true) no-error .
              if not available(ub.inv-doc-attr) then do:
              vErrorMessage = substitute(
                "Товар: &1 &2 &3~n&4~nна объекте &5 &6~nсейчас в инвентаризации (Документ № &7).",
                buf_goods.artic,
                buf_goods.prod-type,
                buf_goods.prod-code,
                buf_goods.gds-name,
                inv_doc-line.obj-type,
                inv_doc-line.obj-code,
                inv_doc-line.doc-code
              ).
              if not g#esys then
                message vErrorMessage view-as alert-box information .
              undo main-block, return error vErrorMessage.
            end.
          end.
        end.
                end.
        for each inv_doc-line no-lock
          where inv_doc-line.obj-type  = buf_doc-line.obj-type
            and inv_doc-line.obj-code  = buf_doc-line.obj-code
            and inv_doc-line.artic     = buf_doc-line.artic
            and inv_doc-line.prod-type = buf_doc-line.prod-type
            and inv_doc-line.prod-code = buf_doc-line.prod-code
            and inv_doc-line.status_   = 'накл':U
        ,first inv_trn-doc no-lock
          where inv_trn-doc.doc-code     = inv_doc-line.doc-code
            and inv_trn-doc.doc-type     = 'инв':U
            and inv_trn-doc.status_      = 'накл':U
            and inv_trn-doc.flag_        = false
            and inv_trn-doc.ext-doc-type = 'ap':U
        on error undo main-block, return error
        :
          vErrorMessage = substitute(
                "Товар: &1 &2 &3~n&4~nна объекте &5 &6~nсейчас в коррекции учетных цен (Документ № &7).",
                buf_goods.artic,
                buf_goods.prod-type,
                buf_goods.prod-code,
                buf_goods.gds-name,
                inv_doc-line.obj-type,
                inv_doc-line.obj-code,
                inv_doc-line.doc-code
              ).
          if not g#esys then
            message vErrorMessage view-as alert-box information .
          undo main-block, return error vErrorMessage.
        end.
        for each inv_doc-line no-lock
          where inv_doc-line.obj-type  = buf_doc-line.obj-type
            and inv_doc-line.obj-code  = buf_doc-line.obj-code
            and inv_doc-line.artic     = buf_doc-line.artic
            and inv_doc-line.prod-type = buf_doc-line.prod-type
            and inv_doc-line.prod-code = buf_doc-line.prod-code
            and inv_doc-line.status_   = 'накл':U
        ,first inv_trn-doc no-lock
          where inv_trn-doc.doc-code     = inv_doc-line.doc-code
            and inv_trn-doc.doc-type     = 'инв':U
            and inv_trn-doc.status_      = 'накл':U
            and inv_trn-doc.flag_        = false
            and inv_trn-doc.ext-doc-type = 'vp':U
        on error undo main-block, return error
        :
          vErrorMessage = substitute(
            "Товар :&1 &2 &3~n&4~nна объекте &5 &6~nсейчас в пересортице (Документ № &7).",
            buf_goods.artic,
            buf_goods.prod-type,
            buf_goods.prod-code,
            buf_goods.gds-name,
            inv_doc-line.obj-type,
            inv_doc-line.obj-code,
            inv_doc-line.doc-code).
          if not g#esys then
              message vErrorMessage view-as alert-box information .
          undo main-block, return error vErrorMessage.
        end.
        if v-doc-with-inv = false then do:
          vErrorMessage = substitute(
                "Товар: &1 &2 &3~nна объекте &4 &5~nотмечен, как принадлежащий документу с типом инвентаризация~n~
Документ коррекции учетных цен не найден.",
                buf_goods.artic,
                buf_goods.prod-type,
                buf_goods.prod-code,
                inv_doc-line.obj-type,
                inv_doc-line.obj-code
              ).
          if not g#esys then
            message vErrorMessage view-as alert-box information .
          undo main-block, return error vErrorMessage.
        end.
      end.
    end.
    if false  then do:
      for each inv_doc-line no-lock
        where inv_doc-line.obj-type     = buf_doc-line.obj-type
          and inv_doc-line.obj-code     = buf_doc-line.obj-code
          and inv_doc-line.artic        = buf_doc-line.artic
          and inv_doc-line.prod-type    = buf_doc-line.prod-type
          and inv_doc-line.prod-code    = buf_doc-line.prod-code
          and inv_doc-line.ext-doc-type = 'vt':U
          and inv_doc-line.status_      = 'разрешен':U
          and inv_doc-line.doc-code     <> v-trn-doc-doc-code
      ,first ub.trn-doc no-lock
        where ub.trn-doc.doc-code       = inv_doc-line.doc-code
          and ub.trn-doc.flag_          = no
      on error undo main-block, return error
      :
        vErrorMessage = substitute(
          "На объекте &1 &2~nсуществует инвентаризация (Документ №&3) по товару~n&4 &5 &6~n&7~nНаходящаяся в статусе ~"&8&9~".",
          inv_doc-line.obj-type,
          inv_doc-line.obj-code,
          inv_doc-line.doc-code,
          buf_goods.artic,
          buf_goods.prod-type,
          buf_goods.prod-code,
          buf_goods.gds-name,
          STRING(ub.trn-doc.status_),
          STRING(ub.trn-doc.flag_, "+/-")
        ).
        if not g#esys then
            message vErrorMessage view-as alert-box information .
        undo main-block, return error vErrorMessage.
      end.
    end.
    if p-document-fact-order <> 0 then do:
      for each inv_doc-line no-lock
        where inv_doc-line.obj-type     = buf_doc-line.obj-type
          and inv_doc-line.obj-code     = buf_doc-line.obj-code
          and inv_doc-line.artic        = buf_doc-line.artic
          and inv_doc-line.prod-type    = buf_doc-line.prod-type
          and inv_doc-line.prod-code    = buf_doc-line.prod-code
          and inv_doc-line.ext-doc-type = 'vp':U
          and inv_doc-line.status_      = 'факт':U
          and inv_doc-line.fact-order   > p-document-fact-order
      on error undo main-block, return error
      :
        vErrorMessage = substitute(
          "На объекте &1 &2~nсуществует инвентаризация (Документ №&3) по товару~n&4 &5 &6~n&7~nс большим логическим номером &8.~n&9.",
          inv_doc-line.obj-type,
          inv_doc-line.obj-code,
          inv_doc-line.doc-code,
          buf_goods.artic,
          buf_goods.prod-type,
          buf_goods.prod-code,
          buf_goods.gds-name,
          inv_doc-line.fact-order,
          substitute("Невозможно закрыть документ &1 с логическим номером &2.",
                     buf_doc-line.doc-code,
                     p-document-fact-order)
        ).
        if not g#esys then
            message vErrorMessage view-as alert-box information .
        undo main-block, return error vErrorMessage.
      end.
    end.
    if p-document-fact-order-price <> 0 then do:
      define variable v-root-b-code like ub.bar-code.b-code no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output v-root-b-code
  ) no-error .
      if error-status :error then do:
        vErrorMessage = substitute(
          "Ошибка при поиске корневого бар-кода~nДокумент &1~nАртикул &2 &3 &4~n&5~n&6.",
          buf_doc-line.doc-code,
          buf_goods.artic,
          buf_goods.prod-type,
          buf_goods.prod-cod,
          error-status :get-message(1),
          return-value
        ).
        if not g#esys then
          message vErrorMessage view-as alert-box information .
        undo main-block, return error vErrorMessage.
      end.
      find last ub.price-list no-lock
        where ub.price-list.obj-type   = buf_doc-line.obj-type
          and ub.price-list.obj-code   = buf_doc-line.obj-code
          and ub.price-list.b-code     = v-root-b-code
          and ub.price-list.price-type = ""
        use-index fact-close
        no-error .
      if available ub.price-list
      and ub.price-list.fact-order > p-document-fact-order
      then do:
        vErrorMessage = substitute(
          "На объекте &1 &2~nсуществует переоценка (Документ №&3) по товару~n&4 &5 &6~n&7~nс более высоким логическим номером &8.~n~
Невозможно закрыть документ с логическим номером &9.",
          buf_doc-line.obj-type,
          buf_doc-line.obj-code,
          ub.price-list.doc-num,
          buf_goods.artic,
          buf_goods.prod-type,
          buf_goods.prod-code,
          buf_goods.gds-name,
          ub.price-list.fact-order,
          p-document-fact-order
        ).
        if not g#esys then
            message vErrorMessage view-as alert-box information .
        undo main-block, return error vErrorMessage.
      end.
    end.
  end.
end.
