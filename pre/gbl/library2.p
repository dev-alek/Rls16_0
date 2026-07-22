block-level on error undo, throw.
using ibs.th.gbl.*.
using ibs.th.gbl.gbl-var.
define variable vss-revision    as character no-undo initial "$Revision: e16321fb6673, 2638, rls $":U .
define variable vss-author      as character no-undo initial "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo initial "$Date: Пн окт 19 09:22:03 2020 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: library2.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: gbl/library2.p $":U .
define variable vss-description as character no-undo initial "Библиотека  процедур".
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
define temp-table x_obj-group no-undo like ub.clients  .
define temp-table x_grp-obj-price no-undo like ub.grp-obj-price .
procedure metod-gop-obj :
  do
  on error undo, return error return-value
  :
define input  parameter p-cntxt-db-num as integer   no-undo .
define input  parameter p-gop-id       as integer   no-undo .
define input  parameter p-gop-db-num   as integer   no-undo .
define buffer buf1_clients for ub.clients  .
define buffer buf_db-grp-obj-price   for ub.db-grp-obj-price  .
define buffer buf_host-grp-obj-price for ub.host-grp-obj-price  .
define buffer buf_obj-grp-obj-price  for ub.obj-grp-obj-price  .
for each  x_obj-group : delete x_obj-group. end.
if p-gop-id = 0 or p-gop-id = ?  then do:
   if p-cntxt-db-num = 0  then do:
        for each buf1_clients no-lock where
                (buf1_clients.obj-type = 'маг':U  or
                 buf1_clients.obj-type = 'скл':U  )
                and
                buf1_clients.db-num >= 0  and
                buf1_clients.stts = 0
                :
          create x_obj-group .
          assign
            x_obj-group.obj-code   = buf1_clients.obj-code
            x_obj-group.obj-type   = buf1_clients.obj-type
            x_obj-group.obj-name   = buf1_clients.obj-name
            x_obj-group.db-num     = buf1_clients.db-num
          .
        end.
   end.
   else do:
        for each buf1_clients no-lock where
                (buf1_clients.obj-type = 'маг':U  or
                 buf1_clients.obj-type = 'скл':U  ) and
                 buf1_clients.db-num = p-cntxt-db-num  and
                 buf1_clients.stts = 0
                :
          create x_obj-group .
          assign
            x_obj-group.obj-code   = buf1_clients.obj-code
            x_obj-group.obj-type   = buf1_clients.obj-type
            x_obj-group.obj-name   = buf1_clients.obj-name
            x_obj-group.db-num     = buf1_clients.db-num
          .
        end.
   end.
end.
else do:
      for each buf_db-grp-obj-price  where
              buf_db-grp-obj-price.gop-id     = p-gop-id and
              buf_db-grp-obj-price.gop-db-num = p-gop-db-num and
              buf_db-grp-obj-price.stts = 0  no-lock :
        for each buf1_clients no-lock where
               (buf1_clients.obj-type = 'маг':U  or
                buf1_clients.obj-type = 'скл':U  ) and
                buf1_clients.db-num = buf_db-grp-obj-price.dgo-db-num  and
                buf1_clients.stts = 0
                :
          create x_obj-group .
          assign
            x_obj-group.obj-code   = buf1_clients.obj-code
            x_obj-group.obj-type   = buf1_clients.obj-type
            x_obj-group.obj-name   = buf1_clients.obj-name
            x_obj-group.db-num     = buf1_clients.db-num
          .
        end.
      end.
    for each buf_host-grp-obj-price where
            buf_host-grp-obj-price.gop-id     = p-gop-id and
            buf_host-grp-obj-price.gop-db-num = p-gop-db-num and
            buf_host-grp-obj-price.stts = 0
            no-lock :
      for each buf1_clients no-lock where
             (buf1_clients.obj-type = 'маг':U  or
              buf1_clients.obj-type = 'скл':U  ) and
              buf1_clients.host-code = buf_host-grp-obj-price.host-code and
              buf1_clients.stts = 0
              :
          find first x_obj-group no-lock  where
                    x_obj-group.obj-code   = buf1_clients.obj-code and
                    x_obj-group.obj-type   = buf1_clients.obj-type no-error .
          if not available  x_obj-group then   create x_obj-group .
          assign
            x_obj-group.obj-code   = buf1_clients.obj-code
            x_obj-group.obj-type   = buf1_clients.obj-type
            x_obj-group.obj-name   = buf1_clients.obj-name
            x_obj-group.db-num     = buf1_clients.db-num
          .
      end.
    end.
    for each buf_obj-grp-obj-price where
            buf_obj-grp-obj-price.gop-id     = p-gop-id and
            buf_obj-grp-obj-price.gop-db-num = p-gop-db-num and
            buf_obj-grp-obj-price.stts = 0
            no-lock :
      for each buf1_clients no-lock where
                buf1_clients.obj-type = buf_obj-grp-obj-price.obj-type and
                buf1_clients.obj-code = buf_obj-grp-obj-price.obj-code and
                buf1_clients.stts     = 0
                :
          find first  x_obj-group no-lock  where
                      x_obj-group.obj-code   = buf1_clients.obj-code and
                      x_obj-group.obj-type   = buf1_clients.obj-type no-error .
          if not available  x_obj-group then   create x_obj-group .
          assign
            x_obj-group.obj-code   = buf1_clients.obj-code
            x_obj-group.obj-type   = buf1_clients.obj-type
            x_obj-group.obj-name   = buf1_clients.obj-name
            x_obj-group.db-num     = buf1_clients.db-num
          .
      end.
    end.
end.
end.
end procedure.
procedure metod-obj-in-gop :
define input  parameter p-curr-db-num as integer   no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define buffer buf_grp-obj-price for ub.grp-obj-price  .
  do
  on error undo, return error return-value
  :
    empty temp-table x_grp-obj-price.
    for each buf_grp-obj-price where
             buf_grp-obj-price.stts = 0
             no-lock :
               run metod-gop-obj (p-curr-db-num , buf_grp-obj-price.gop-id ,buf_grp-obj-price.gop-db-num) .
               for each x_obj-group where
                        x_obj-group.obj-type = p-obj-type and
                        x_obj-group.obj-code = p-obj-code :
                    create  x_grp-obj-price.
                    buffer-copy buf_grp-obj-price to x_grp-obj-price .
               end.
    end.
  end.
end procedure.
procedure metod-delobj-usr :
define input  parameter p-pdf-id  as integer   no-undo .
define input  parameter p-pdf-db  as integer   no-undo .
define input  parameter p-plt-id  as integer   no-undo .
define input  parameter p-plt-db-num as integer   no-undo .
define buffer buf_price-doc-forming-attr for ub.price-doc-forming-attr  .
  do
  on error undo, return error return-value
  :
for each buf_price-doc-forming-attr no-lock  where
         buf_price-doc-forming-attr.pdf-id =     p-pdf-id and
         buf_price-doc-forming-attr.pdf-db =     p-pdf-db and
         buf_price-doc-forming-attr.plt-id =     p-plt-id and
         buf_price-doc-forming-attr.plt-db-num = p-plt-db-num and
         buf_price-doc-forming-attr.attr-code begins "obj" :
   for each x_obj-group  where
            x_obj-group.obj-type = substring(buf_price-doc-forming-attr.attr-code,4,3) and
            x_obj-group.obj-code = int(substring(buf_price-doc-forming-attr.attr-code,7,20)) :
     delete x_obj-group.
   end.
end.
  if not can-find (first x_obj-group) then do:
     return "nullobj" .
  end.
end.
end procedure.
procedure metod-obj-pdf :
define input  parameter p-cntxt-db-num as integer   no-undo .
define input  parameter p-pdf-id     like ub.price-doc-forming.pdf-id   no-undo .
define input  parameter p-pdf-db-num like ub.price-doc-forming.pdf-db   no-undo .
define input  parameter p-plt-id     like ub.price-doc-forming.plt-id   no-undo .
define input  parameter p-plt-db-num like ub.price-doc-forming.plt-db-num  no-undo .
define buffer buf_price-list-type for ub.price-list-type  .
define buffer buf_price-doc-forming for ub.price-doc-forming  .
  do
  on error undo, return error return-value
  :
 for each  x_obj-group : delete x_obj-group. end.
 find first buf_price-list-type no-lock where
            buf_price-list-type.plt-id = p-plt-id and
            buf_price-list-type.plt-db-num = p-plt-db-num no-error .
if error-status :error then return error return-value .
 find first buf_price-doc-forming no-lock where
            buf_price-doc-forming.plt-id     = p-plt-id and
            buf_price-doc-forming.plt-db-num = p-plt-db-num and
            buf_price-doc-forming.pdf-id     = p-pdf-id and
            buf_price-doc-forming.pdf-db     = p-pdf-db-num
            no-error .
if error-status :error then return error return-value .
  run metod-gop-obj in this-procedure (
      p-cntxt-db-num,
      buf_price-list-type.gop-id ,
      buf_price-list-type.gop-db-num
      ) no-error .
  run metod-delobj-usr in this-procedure (
    buf_price-doc-forming.pdf-id ,
    buf_price-doc-forming.pdf-db ,
    buf_price-doc-forming.plt-id ,
    buf_price-doc-forming.plt-db-num
    ) no-error .
  end.
end procedure.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
if valid-handle (g#library2)
and g#library2 <> this-procedure :handle
and g#library2 :get-signature('library2_testproc':u) <> ""
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Попытка повторной загрузки библиотеки" skip
    g#library2 skip
    g#library2 :type skip
    g#library2 :file-name skip
    valid-handle(g#library2) skip
    this-procedure :handle skip
    this-procedure :type skip
    this-procedure :file-name skip
    valid-handle(this-procedure) skip
    view-as alert-box error .
  undo, return error .
end.
else do:
  assign
    g#library2 = this-procedure :handle
  .
  def var gbl-hndllibObj as class gbl-hndllib no-undo.
  gbl-hndllibObj = new gbl-hndllib ().
  gbl-hndllibObj:InitHndl("g#library2", g#library2).
  delete object gbl-hndllibObj.
end.
if this-procedure :persistent <> true
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка запуска библиотеки" program-name(1) skip
    "Попытка запустить ее как обычную процедуру" skip
    view-as alert-box error .
end.
on delete of this-procedure do:
  assign
    g#library2 = ?
  .
  def var gbl-hndllibObj as class gbl-hndllib no-undo.
  gbl-hndllibObj = new gbl-hndllib ().
  gbl-hndllibObj:InitHndl("g#library2", g#library2).
  delete object gbl-hndllibObj.
end.
define stream sout .
procedure library2_testproc :
end.
procedure bc-mpl :
define input parameter  v-gop-id     as integer   no-undo .
define input parameter  v-gop-db-num as integer   no-undo .
define input parameter  v-b-code      like ub.bar-code.b-code       no-undo .
define input parameter  v-root-b-code like ub.bar-code.b-code       no-undo .
define input parameter  v-fact-order  like ub.price-doc.fact-order  no-undo .
define output parameter v-recid       as recid no-undo .
define output parameter v-price-sale  like ub.price-doc-forming-gds.price-sale-doc no-undo .
define output parameter v-road-tax    like ub.price-doc-forming-gds.road-tax-doc   no-undo .
define output parameter v-excise      like ub.price-doc-forming-gds.excise-doc     no-undo .
define variable v-price-list-recid as recid no-undo .
define variable v-cli-base-rate    like ub.bar-code.cli-base-rate no-undo .
define variable vss-description as character no-undo initial "bc-mpl: получение продажной цены товара (признака)".
define buffer buf_price-doc-forming       for ub.price-doc-forming  .
define buffer buf_price-doc-forming-gds   for ub.price-doc-forming-gds .
define buffer buf_price-all               for ub.price-all  .
  do
  on error undo, return error
  :
    run library2_private_bcmplgds in this-procedure
      (input  v-gop-id
      ,input  v-gop-db-num
      ,input  v-b-code
      ,input  v-root-b-code
      ,input  v-fact-order
      ,output v-price-list-recid
      ,output v-cli-base-rate
      ).
    if v-price-list-recid = ?
    then do:
      assign
        v-recid      = ?
        v-price-sale = ?
        v-road-tax   = ?
        v-excise     = ?
      .
    end.
    else do:
      assign
        v-recid      = ?
        v-price-sale = ?
        v-road-tax   = ?
        v-excise     = ?
      .
      find first buf_price-all no-lock where
           recid(buf_price-all) = v-price-list-recid
           no-error .
      if not error-status :error then do:
            find first buf_price-doc-forming-gds no-lock where
                       buf_price-doc-forming-gds.plt-id     = buf_price-all.plt-id   and
                       buf_price-doc-forming-gds.plt-db-num = buf_price-all.plt-db-num and
                       buf_price-doc-forming-gds.pdf-id     = buf_price-all.pdf-id   and
                       buf_price-doc-forming-gds.pdf-db     = buf_price-all.pdf-db   and
                       buf_price-doc-forming-gds.b-code     = buf_price-all.b-code
                      no-error .
            if available buf_price-doc-forming-gds then do:
                find first buf_price-doc-forming no-lock where
                          buf_price-doc-forming.pdf-id = buf_price-doc-forming-gds.pdf-id   and
                          buf_price-doc-forming.plt-id = buf_price-doc-forming-gds.plt-id   and
                          buf_price-doc-forming.pdf-db = buf_price-doc-forming-gds.pdf-db   and
                          buf_price-doc-forming.plt-db-num = buf_price-doc-forming-gds.plt-db-num no-error .
                          if not error-status :error then do:
                              assign
                                v-recid      = recid (buf_price-doc-forming)
                                v-price-sale = buf_price-doc-forming-gds.price-sale-doc * v-cli-base-rate
                                v-road-tax   = buf_price-doc-forming-gds.road-tax-doc   * v-cli-base-rate
                                v-excise     = buf_price-doc-forming-gds.excise-doc     * v-cli-base-rate
                              .
                        end.
           end.
      end.
    end.
  end.
end procedure.
procedure library2_private_bcmplgds :
  define input  parameter v-gop-id           as   integer                   no-undo .
  define input  parameter v-gop-db-num       as   integer                   no-undo .
  define input  parameter v-b-code           like ub.bar-code.b-code        no-undo .
  define input  parameter v-root-b-code      like ub.bar-code.b-code        no-undo .
  define input  parameter v-fact-order       as   decimal                   no-undo .
  define output parameter v-recid-price-all  as   recid                     no-undo .
  define output parameter v-cli-base-rate    like ub.bar-code.cli-base-rate no-undo .
  define variable vss-description as character no-undo initial "library2_private_bcmplgds-01: записи продажной цены признака".
  define buffer buf_root_bar-code   for ub.bar-code   .
  define buffer buf_bar-code        for ub.bar-code   .
  define buffer buf_root_price-all  for ub.price-all  .
  define buffer buf_price-all       for ub.price-all  .
  define buffer buf_main_bar-code   for ub.bar-code   .
  do
  on error undo, return error
  :
    find first buf_bar-code no-lock
      where buf_bar-code.b-code = v-b-code
      no-error .
    if not available buf_bar-code
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при задании входных параметров" skip
        "Не найден бар-код" v-b-code skip
        view-as alert-box error .
      undo, return error .
    end.
    assign
      v-cli-base-rate = buf_bar-code.cli-base-rate
    .
    if v-fact-order = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при задании входных параметров" skip
        "Должен быть задан порядковый номер документа" skip
        "Для определения текущей цены он должен быть равен 0" skip
        "Порядковый номер документа" v-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
    if v-root-b-code = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при задании входных параметров" skip
        "Должен быть задан бар-код корневого признака" skip
        "Или он должен быть равено 0" skip
        "Бар-код корневого признака" v-root-b-code skip
        view-as alert-box error .
      undo, return error .
    end.
    if v-root-b-code = 0
    then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_bar-code.gds-code
  ,input  ?
  ,output v-root-b-code
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении корневого бар-кода для товара" skip
          "Код товара"  buf_bar-code.gds-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
    else do:
      define variable v-check-root-b-code like ub.bar-code.b-code no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_bar-code.gds-code
  ,input  ?
  ,output v-check-root-b-code
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении корневого бар-кода для товара" skip
          "Код товара"  buf_bar-code.gds-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      if v-root-b-code <> v-check-root-b-code
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания входных параметров" skip
          "Код товара" buf_bar-code.gds-code skip
          "Основной бар-код товара" v-check-root-b-code skip
          "В качестве параметра передано" v-root-b-code skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
    find first buf_root_bar-code no-lock
      where buf_root_bar-code.b-code = v-root-b-code
      no-error .
    if not available buf_root_bar-code
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден бар-код корневого признака" skip
        "Код товара" buf_bar-code.gds-code skip
        "Бар-код" v-root-b-code skip
        view-as alert-box error .
      undo, return error .
    end.
    if buf_root_bar-code.gds-code <> buf_bar-code.gds-code
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "В качеcтве параметров указаны бар-коды разных товаров" skip
        "Бар-код" buf_bar-code.b-code skip
        "Код товара" buf_bar-code.gds-code skip
        "Бар-код корневого признака" buf_root_bar-code.b-code skip
        "Код товара в бар-коде корневого признака" buf_root_bar-code.gds-code skip
        view-as alert-box error .
      undo, return error .
    end.
    for each x_obj-group
    on error undo, return error return-value
    :
      delete x_obj-group .
    end.
    define variable v-cur-db-num as integer   no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-cur-db-num
  )  .
    run metod-gop-obj in this-procedure (v-cur-db-num , v-gop-id , v-gop-db-num) no-error .
define variable root_pdf-id as integer   no-undo .
define variable root_pdf-db as integer   no-undo .
define variable root_plt-id as integer   no-undo .
define variable root_plt-db as integer   no-undo .
define variable root_fact-order as decimal   no-undo .
root_fact-order = 0 .
    if v-fact-order = 0
    then do:
      for each x_obj-group
      on error undo, return error return-value
      :
           for each   buf_root_price-all no-lock
            where buf_root_price-all.obj-type   = x_obj-group.obj-type
              and buf_root_price-all.obj-code   = x_obj-group.obj-code
              and buf_root_price-all.b-code     = v-root-b-code
              and buf_root_price-all.status_    = 'акт':U   use-index by_fact-order
           on error undo, return error return-value
           :
              if root_fact-order < buf_root_price-all.fact-order then
              assign
                root_pdf-id = buf_root_price-all.pdf-id
                root_pdf-db = buf_root_price-all.pdf-db
                root_plt-id = buf_root_price-all.plt-id
                root_plt-db = buf_root_price-all.plt-db-num
                root_fact-order = buf_root_price-all.fact-order
              .
              leave.
           end.
      end.
    end.
    else do:
      for each x_obj-group ,
          each buf_root_price-all no-lock
            where buf_root_price-all.obj-type   = x_obj-group.obj-type
              and buf_root_price-all.obj-code   = x_obj-group.obj-code
              and buf_root_price-all.b-code     = v-root-b-code
              and buf_root_price-all.status_    = 'акт':U
              and buf_root_price-all.fact-order < v-fact-order use-index by_fact-order
      on error undo, return error return-value
      :
              if root_fact-order < buf_root_price-all.fact-order then
              assign
                root_pdf-id = buf_root_price-all.pdf-id
                root_pdf-db = buf_root_price-all.pdf-db
                root_plt-id = buf_root_price-all.plt-id
                root_plt-db = buf_root_price-all.plt-db-num
                root_fact-order = buf_root_price-all.fact-order
              .
              leave.
      end.
    end.
    find first buf_root_price-all no-lock where
               buf_root_price-all.b-code     = v-root-b-code and
               buf_root_price-all.pdf-id     = root_pdf-id and
               buf_root_price-all.pdf-db     = root_pdf-db and
               buf_root_price-all.plt-id     = root_plt-id and
               buf_root_price-all.plt-db-num = root_plt-db no-error .
    if  available buf_root_price-all
    then do:
      if v-b-code = v-root-b-code
      then do:
        assign
          v-recid-price-all = recid(buf_root_price-all)
          v-cli-base-rate    = 1
        .
        return .
      end.
      else do:
        find first buf_price-all no-lock
          where
                buf_price-all.pdf-id     = buf_root_price-all.pdf-id and
                buf_price-all.pdf-db     = buf_root_price-all.pdf-db and
                buf_price-all.plt-id     = buf_root_price-all.plt-id and
                buf_price-all.plt-db-num = buf_root_price-all.plt-db-num  and
                buf_price-all.b-code     = v-b-code
          no-error.
        if available buf_price-all
        then do:
          assign
            v-recid-price-all = recid(buf_price-all)
            v-cli-base-rate    = 1
          .
          return .
        end.
        if buf_bar-code.unit-cli = buf_root_bar-code.unit-cli
        then do:
          assign
            v-recid-price-all = recid(buf_root_price-all)
            v-cli-base-rate    = 1
          .
          return .
        end.
        else do:
          define variable v-is-new as logical no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run barcodcr in g#library
  (input  buf_bar-code.gds-code
  ,input  buf_bar-code.node-code
  ,input  buf_bar-code.part-code
  ,input  buf_bar-code.in-code
  ,input  buf_root_bar-code.unit-cli
  ,input  1
  ,output v-is-new
  ,buffer buf_main_bar-code
  ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при поиске бар-кода" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error .
          end.
          find first buf_price-all no-lock
            where
                buf_price-all.pdf-id     = buf_root_price-all.pdf-id and
                buf_price-all.pdf-db     = buf_root_price-all.pdf-db and
                buf_price-all.plt-id     = buf_root_price-all.plt-id and
                buf_price-all.plt-db-num = buf_root_price-all.plt-db-num  and
                buf_price-all.b-code     = buf_main_bar-code.b-code
                no-error.
          if available buf_price-all
          then do:
            assign
              v-recid-price-all = recid(buf_price-all)
            .
            return .
          end.
          else do:
            assign
              v-recid-price-all = recid(buf_root_price-all)
            .
            return .
          end.
        end.
      end.
    end.
    else do:
      assign
        v-recid-price-all = ?
        v-cli-base-rate    = ?
      .
      return .
    end.
    message
      vss-workfile vss-revision vss-description skip
      "Внутренняя ошибка при определении цены бар-кода" skip
      "Бар-код"    buf_bar-code.b-code skip
      "Код товара" buf_bar-code.gds-code skip
      "recid(root_price-all)" recid(buf_root_price-all) skip
      "recid(price-all)"      recid(buf_price-all) skip
      view-as alert-box error .
    undo, return error .
  end.
end procedure.
procedure gtplobj :
define input  parameter p-handle     as handle    no-undo .
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define input  parameter p-auto       as logical   no-undo .
define output parameter p-plt-id     as integer   no-undo .
define output parameter p-plt-db-num as integer   no-undo .
define buffer main_price-list-type for ub.price-list-type  .
  do
  on error undo, return error return-value
  :
p-plt-id     = 0.
p-plt-db-num = 0.
define variable v-cur-db-num like ub.db.db-num no-undo .
define variable v-db-num like ub.db.db-num no-undo .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-cur-db-num
  )  .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-db-num
  )  .
define variable v-col as integer   no-undo .
define variable v-str as character no-undo .
define variable vv-obj-db-num as integer   no-undo .
define variable i as integer   no-undo .
v-col = 0 .
v-str = "" .
if p-auto = yes then do:
  for each main_price-list-type no-lock where
           main_price-list-type.only-gbd = 1 and
           main_price-list-type.main = true and
           main_price-list-type.stts = integer('0':U)
  on error undo, return error return-value
  :
    if main_price-list-type.gop-id <> 0  then do:
        run metod-gop-obj in this-procedure ( v-cur-db-num , main_price-list-type.gop-id , main_price-list-type.gop-db-num) .
        if can-find (first x_obj-group where x_obj-group.obj-type = p-obj-type and x_obj-group.obj-code = p-obj-code )
            then do:
              v-col = v-col + 1 .
              p-plt-id     = main_price-list-type.plt-id     .
              p-plt-db-num = main_price-list-type.plt-db-num .
              v-str = v-str + main_price-list-type.name + "," .
            end.
    end.
    else do:
        v-col = v-col + 1 .
        p-plt-id     = main_price-list-type.plt-id     .
        p-plt-db-num = main_price-list-type.plt-db-num .
        v-str = v-str + main_price-list-type.name + "," .
    end.
  end.
  if v-col = 0 then do:
    message
      "Для объекта не найден ГТПЛ для автопереоценок" skip
       v-str skip
      "Тип" p-obj-type skip
      "Код" p-obj-code skip
      view-as alert-box error .
    undo, return error .
   end.
   if v-col > 1 then do:
        message
          "Для объекта "  p-obj-type  p-obj-code skip
          "найдено несколько ГТПЛ для автопереоценок : " skip
          v-col "шт." skip
          v-str skip
          "На объекте ГТПЛ для автопереоценок должен быть один. " skip
          view-as alert-box error .
          p-plt-id     = 0.
          p-plt-db-num = 0.
        undo, return error .
    end.
end.
else do:
for each main_price-list-type no-lock where
         main_price-list-type.main = true and
         main_price-list-type.stts = integer('0':U)
on error undo, return error return-value
:
   if main_price-list-type.gop-id <> 0  then do:
      run metod-gop-obj in this-procedure ( v-cur-db-num , main_price-list-type.gop-id , main_price-list-type.gop-db-num) .
   if can-find (first x_obj-group where x_obj-group.obj-type = p-obj-type and x_obj-group.obj-code = p-obj-code )
      then do:
        v-col = v-col + 1 .
        p-plt-id     = main_price-list-type.plt-id     .
        p-plt-db-num = main_price-list-type.plt-db-num .
        v-str = v-str + main_price-list-type.name + "," .
      end.
   end.
   else do:
      v-col = v-col + 1 .
      p-plt-id     = main_price-list-type.plt-id     .
      p-plt-db-num = main_price-list-type.plt-db-num .
      v-str = v-str + main_price-list-type.name + "," .
   end.
end.
if v-col = 0 then do:
    message
      "Для объекта не найден главных типов прайс-листов" skip
       v-str skip
      "Тип" p-obj-type skip
      "Код" p-obj-code skip
      view-as alert-box error .
    undo, return error .
 end.
 if v-col > 1 then do:
    message
      "Для объекта "   skip
      "Тип" p-obj-type skip
      "Код" p-obj-code skip
      "найдено несколько ГТПЛ для автопереоценок. " skip
       v-col skip
       v-str skip
      "Нужно выбрать ГТПЛ !" skip
      view-as alert-box information .
      define variable v-recid as character no-undo .
      define buffer buf1_price-list-type for ub.price-list-type  .
      run ref/typepric.w (
          input p-handle   ,
          input "b-sel"           ,
          input-output v-recid
          ) no-error .
      find first buf1_price-list-type no-lock where recid(buf1_price-list-type) = int(v-recid) no-error .
      if available buf1_price-list-type then
      assign
        p-plt-id     = buf1_price-list-type.plt-id
        p-plt-db-num = buf1_price-list-type.plt-db-num
      .
      else
      assign
        p-plt-id     = 0
        p-plt-db-num = 0
      .
  end.
end.
end.
end procedure.
procedure usercred :
  define input  parameter p-db-num              as integer   no-undo .
  define input  parameter p-user-id             as character no-undo .
  define output parameter p-check-db-num        as integer   no-undo .
  define output parameter p-check-user-id       as character no-undo .
  define output parameter p-check-administrator as logical   no-undo .
  define buffer buf_user-login        for ub.user-login .
  define buffer buf_parent_user-login for ub.user-login .
  do
  on error undo, return error return-value
  :
    find first buf_user-login no-lock
      where buf_user-login.db-num  = p-db-num
        and buf_user-login.user-id = p-user-id
      no-error .
    if not available buf_user-login
    then do:
      undo, return error substitute('Не найден логин пользователя для базы данных &1. Идентификатор пользователя &2~nПока не будет заведен логин, доступ к данным этой БД будет закрыт.'
                                    ,p-db-num
                                    ,p-user-id
                                    ) .
    end.
    assign
      p-check-db-num        = buf_user-login.db-num
      p-check-user-id       = buf_user-login.user-id
      p-check-administrator = buf_user-login.user-administrator
    .
    if buf_user-login.action-check-parent = true
    then do:
      find first buf_parent_user-login no-lock
        where buf_parent_user-login.db-num  = buf_user-login.parent-db-num
          and buf_parent_user-login.user-id = buf_user-login.parent-user-id
        no-error .
      if not available buf_parent_user-login
      then do:
        undo, return error substitute('Не найден родительский логин пользователя. База данных &1. Идентификатор пользователя &2'
                                      ,buf_user-login.parent-db-num
                                      ,buf_user-login.parent-user-id
                                      ) .
      end.
      assign
        p-check-db-num        = buf_parent_user-login.db-num
        p-check-user-id       = buf_parent_user-login.user-id
        p-check-administrator = buf_parent_user-login.user-administrator
      .
    end.
  end.
end procedure.
procedure ushstava :
  define input  parameter p-db-num           as integer   no-undo .
  define input  parameter p-action-head-code as integer   no-undo .
  define input  parameter p-user-id          as character no-undo .
  define input  parameter p-host-code        as integer   no-undo .
  define output parameter p-host-available   as logical   no-undo .
  define variable vss-description as character no-undo initial "ushstava-01: определить, что пользователю доступна фирма".
  define variable v-check-db-num        as integer   no-undo .
  define variable v-check-user-id       as character no-undo .
  define variable v-check-administrator as logical   no-undo .
  define buffer buf_sysconf                for ub.sysconf .
  define buffer buf_user-host              for ub.user-host .
  define buffer buf_action-post-host       for ub.action-post-host .
  define buffer buf_action-post-user-login for ub.action-post-user-login .
  do
  on error undo, return error return-value
  :
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usercred in g#library2
  (input  p-db-num
  ,input  p-user-id
  ,output v-check-db-num
  ,output v-check-user-id
  ,output v-check-administrator
  ) no-error .
    if error-status :error
    then do:
      undo, return error substitute("&1. Ошибка при вызове процедуры usercred.i. &2 &3"
                                   ,vss-description
                                   ,error-status :get-message(1)
                                   ,return-value
                                   ) .
    end.
    find first buf_sysconf no-lock
      where buf_sysconf.host-code = p-host-code
      no-error .
    if not available buf_sysconf
    then do:
      undo, return error substitute("&1. Ошибка задания входных параметров. Не найдена фирма &2"
                                   ,vss-description
                                   ,p-host-code
                                   ) .
    end.
    assign
      p-host-available = false
    .
    if v-check-administrator = true
    then do:
      assign
        p-host-available = true
      .
      return .
    end.
    find first buf_user-host no-lock
      where buf_user-host.db-num    = p-db-num
        and buf_user-host.user-id   = p-user-id
        and buf_user-host.host-code = p-host-code
      no-error .
    if available buf_user-host
    then do:
      assign
        p-host-available = true
      .
      return .
    end.
    for each buf_action-post-user-login no-lock
      where buf_action-post-user-login.db-num           = p-db-num
        and buf_action-post-user-login.action-head-code = p-action-head-code
        and buf_action-post-user-login.user-id          = p-user-id
    on error undo, return error return-value
    :
      find first buf_action-post-host no-lock
        where buf_action-post-host.db-num           = p-db-num
          and buf_action-post-host.action-head-code = buf_action-post-user-login.action-head-code
          and buf_action-post-host.action-post-code = buf_action-post-user-login.action-post-code
          and buf_action-post-host.host-code        = p-host-code
        no-error .
      if available buf_action-post-host
      then do:
        assign
          p-host-available = true
        .
        return .
      end.
    end.
  end.
end procedure.
procedure usobjava :
  define input  parameter p-db-num           as integer   no-undo .
  define input  parameter p-action-head-code as integer   no-undo .
  define input  parameter p-user-id          as character no-undo .
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define output parameter p-obj-available    as logical   no-undo .
  define variable vss-description as character no-undo initial "usobjava-01: определить, что пользователю доступен объект".
  define variable v-object-exist        as logical   no-undo .
  define variable v-check-db-num        as integer   no-undo .
  define buffer buf_user-obj               for ub.user-obj .
  define buffer buf_action-post-user-login for ub.action-post-user-login .
  define buffer buf_action-post-obj        for ub.action-post-obj .
  do
  on error undo, return error return-value
  :
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'check-exist':U
  ,output v-object-exist
  ) no-error .
    if error-status :error
    then do:
      undo, return error substitute("&1. Ошибка при вызове процедуры objat.i. &2 &3"
                                   ,vss-description
                                   ,error-status :get-message(1)
                                   ,return-value
                                   ) .
    end.
    assign
      p-obj-available = false
    .
    find first buf_user-obj no-lock
      where buf_user-obj.db-num   = p-db-num
        and buf_user-obj.user-id  = p-user-id
        and buf_user-obj.obj-type = p-obj-type
        and buf_user-obj.obj-code = p-obj-code
      no-error .
    if available buf_user-obj
    then do:
      assign
        p-obj-available = true
      .
      return .
    end.
    for each buf_action-post-user-login no-lock
      where buf_action-post-user-login.db-num           = p-db-num
        and buf_action-post-user-login.action-head-code = p-action-head-code
        and buf_action-post-user-login.user-id          = p-user-id
    on error undo, return error return-value
    :
      find first buf_action-post-obj no-lock
        where buf_action-post-obj.db-num           = p-db-num
          and buf_action-post-obj.action-head-code = buf_action-post-user-login.action-head-code
          and buf_action-post-obj.action-post-code = buf_action-post-user-login.action-post-code
          and buf_action-post-obj.obj-type         = p-obj-type
          and buf_action-post-obj.obj-code         = p-obj-code
        no-error .
      if available buf_action-post-obj
      then do:
        assign
          p-obj-available = true
        .
        return .
      end.
    end.
  end.
end procedure.
procedure usobjany :
  define input  parameter p-db-num           as integer   no-undo .
  define input  parameter p-action-head-code as integer   no-undo .
  define input  parameter p-user-id          as character no-undo .
  define output parameter p-obj-type         as character no-undo .
  define output parameter p-obj-code         as integer   no-undo .
  define output parameter p-obj-available    as logical   no-undo .
  define variable v-check-db-num        as integer   no-undo .
  define variable v-check-user-id       as character no-undo .
  define variable v-check-administrator as logical   no-undo .
  define buffer buf_user-obj               for ub.user-obj .
  define buffer buf_action-post-user-login for ub.action-post-user-login .
  define buffer buf_action-post-obj        for ub.action-post-obj .
  do
  on error undo, return error return-value
  :
define variable vss-include-info9 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usercred in g#library2
  (input  p-db-num
  ,input  p-user-id
  ,output v-check-db-num
  ,output v-check-user-id
  ,output v-check-administrator
  ) no-error .
    if error-status :error
    then do:
      undo, return error substitute("&1. Ошибка при вызове процедуры usercred.i. &2 &3"
                                   ,vss-description
                                   ,error-status :get-message(1)
                                   ,return-value
                                   ) .
    end.
    find first buf_user-obj no-lock
      where buf_user-obj.db-num  = v-check-db-num
        and buf_user-obj.user-id = v-check-user-id
      no-error .
    if available buf_user-obj
    then do:
      assign
        p-obj-type      = buf_user-obj.obj-type
        p-obj-code      = buf_user-obj.obj-code
        p-obj-available = true
      .
      return .
    end.
    for each buf_action-post-user-login no-lock
      where buf_action-post-user-login.db-num           = p-db-num
        and buf_action-post-user-login.action-head-code = p-action-head-code
        and buf_action-post-user-login.user-id          = p-user-id
    on error undo, return error return-value
    :
      find first buf_action-post-obj no-lock
        where buf_action-post-obj.db-num           = p-db-num
          and buf_action-post-obj.action-head-code = buf_action-post-user-login.action-head-code
          and buf_action-post-obj.action-post-code = buf_action-post-user-login.action-post-code
        no-error .
      if available buf_action-post-obj
      then do:
        assign
          p-obj-type      = buf_user-obj.obj-type
          p-obj-code      = buf_user-obj.obj-code
          p-obj-available = true
        .
        return .
      end.
    end.
  end.
end procedure.
procedure usmgrava :
  define input  parameter p-db-num               as integer   no-undo .
  define input  parameter p-action-head-code     as integer   no-undo .
  define input  parameter p-user-id              as character no-undo .
  define input  parameter p-menu-code            as integer   no-undo .
  define input  parameter p-menu-group-code      as integer   no-undo .
  define input  parameter p-cntxt-level          as character no-undo .
  define input  parameter p-cntxt-host-code-obj  as integer   no-undo .
  define input  parameter p-cntxt-obj-type       as character no-undo .
  define input  parameter p-cntxt-obj-code       as integer   no-undo .
  define output parameter p-menu-group-available as logical   no-undo .
  define variable v-full-user-name      as character no-undo .
  define variable v-check-db-num        as integer   no-undo .
  define variable v-check-user-id       as character no-undo .
  define variable v-check-administrator as logical   no-undo .
  define variable v-visibility          as logical   no-undo .
  define buffer buf_user-account           for ub.user-account .
  define buffer buf_user-menu-group        for ub.user-menu-group .
  define buffer buf_menu-group             for ub.menu-group .
  define buffer buf_action-post-user-login for ub.action-post-user-login .
  define buffer buf_action-post-menu-group for ub.action-post-menu-group .
  do
  on error undo, return error return-value
  :
    check_block:
    do
    on error undo, leave
    :
      find first buf_user-account no-lock
        where buf_user-account.user-id = p-user-id
        no-error .
      if not available buf_user-account
      then do:
        assign
          p-menu-group-available = false
        .
        leave check_block .
      end.
define variable vss-include-info10 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrfulnm in g#library
  (input  p-user-id
  ,output v-full-user-name
  ) no-error .
      if error-status :error
      then do:
        assign
          p-menu-group-available = false
        .
        leave check_block .
      end.
define variable vss-include-info11 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usercred in g#library2
  (input  p-db-num
  ,input  p-user-id
  ,output v-check-db-num
  ,output v-check-user-id
  ,output v-check-administrator
  ) no-error .
      if error-status :error
      then do:
        assign
          p-menu-group-available = false
        .
        leave check_block .
      end.
      find first buf_menu-group no-lock
        where buf_menu-group.menu-code          = p-menu-code
          and buf_menu-group.menu-group-code    = p-menu-group-code
        no-error .
      if available buf_menu-group then do:
define variable vss-include-info12 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chkmngr in g#library2
  (input  buf_menu-group.menu-group-id
  ,input  p-cntxt-level
  ,input  p-cntxt-obj-type
  ,input  p-cntxt-obj-code
  ,input  v-check-db-num
  ,output v-visibility
  ) no-error .
         if error-status :error
         then do:
            assign
               p-menu-group-available = false
            .
            leave check_block .
         end.
         if v-visibility = FALSE
         then do:
            assign
               p-menu-group-available = false
            .
            leave check_block .
         end.
      end.
      else do:
        assign
          p-menu-group-available = false
        .
        leave check_block .
      end.
      if v-check-administrator = true
      then do:
        assign
          p-menu-group-available = true
        .
        leave check_block .
      end.
      find first buf_user-menu-group no-lock
        where buf_user-menu-group.db-num             = v-check-db-num
          and buf_user-menu-group.user-id            = v-check-user-id
          and buf_user-menu-group.menu-code          = p-menu-code
          and buf_user-menu-group.menu-group-code    = p-menu-group-code
          and buf_user-menu-group.menu-group-context = p-cntxt-level
          and buf_user-menu-group.host-code          = p-cntxt-host-code-obj
          and buf_user-menu-group.obj-type           = p-cntxt-obj-type
          and buf_user-menu-group.obj-code           = p-cntxt-obj-code
        no-error .
      if available buf_user-menu-group
      then do:
        assign
          p-menu-group-available = true
        .
        leave check_block .
      end.
      for each buf_action-post-user-login
        where buf_action-post-user-login.db-num           = v-check-db-num
          and buf_action-post-user-login.action-head-code = p-action-head-code
          and buf_action-post-user-login.user-id          = v-check-user-id
      on error undo, return error return-value
      :
        find first buf_action-post-menu-group no-lock
          where buf_action-post-menu-group.db-num             = v-check-db-num
            and buf_action-post-menu-group.action-head-code   = buf_action-post-user-login.action-head-code
            and buf_action-post-menu-group.action-post-code   = buf_action-post-user-login.action-post-code
            and buf_action-post-menu-group.menu-code          = p-menu-code
            and buf_action-post-menu-group.menu-group-code    = p-menu-group-code
            and buf_action-post-menu-group.menu-group-context = p-cntxt-level
            and buf_action-post-menu-group.host-code          = p-cntxt-host-code-obj
            and buf_action-post-menu-group.obj-type           = p-cntxt-obj-type
            and buf_action-post-menu-group.obj-code           = p-cntxt-obj-code
          no-error .
        if available buf_user-menu-group
        then do:
          assign
            p-menu-group-available = true
          .
          leave check_block .
        end.
      end.
      assign
        p-menu-group-available = false
      .
      leave check_block .
    end.
  end.
end procedure.
PROCEDURE chkmngr :
define input  parameter p-menu-group-id       as character no-undo .
define input  parameter p-context             as character no-undo .
define input  parameter p-cntxt-obj-type      as character no-undo .
define input  parameter p-cntxt-obj-code      as integer no-undo .
define input  parameter p-cntxt-db-num        as integer no-undo .
define output parameter p-ok                  as logical no-undo.
define buffer buf_clients     for ub.clients.
check_block_:
do
on error undo, return error
:
   assign
      p-ok = TRUE
   .
   CASE p-context :
      WHEN 'global':U
      THEN DO:
            IF p-menu-group-id = "str"
            OR p-menu-group-id = "shp"
            OR p-menu-group-id = "res"
            OR p-menu-group-id = "fin"
            OR p-menu-group-id = "bge"
            OR p-menu-group-id = "mmr"
            THEN DO:
               ASSIGN
                  p-ok = FALSE
               .
               leave check_block_ .
            END.
      END.
      WHEN 'firm':U THEN DO:
            IF p-menu-group-id = "str"
            OR p-menu-group-id = "shp"
            OR p-menu-group-id = "res"
            OR p-menu-group-id = "bge"
            OR p-menu-group-id = "off"
            OR p-menu-group-id = "mmr"
            THEN DO:
               ASSIGN
                  p-ok = FALSE
               .
               leave check_block_ .
            END.
      END.
      WHEN 'object':U THEN DO:
         find first buf_clients
              where buf_clients.obj-type = p-cntxt-obj-type
                and buf_clients.obj-code = p-cntxt-obj-code
              no-lock
              .
         IF (  p-menu-group-id = "str"
            OR p-menu-group-id = "shp"
            OR p-menu-group-id = "res"
            )
            AND buf_clients.db-num <> p-cntxt-db-num
         THEN DO:
            ASSIGN
               p-ok = FALSE
            .
            leave check_block_ .
         END.
      END.
      OTHERWISE  DO:
         ASSIGN
            p-ok = FALSE
         .
      END.
   END CASE.
   IF p-cntxt-db-num <> 0
   AND p-menu-group-id = "off":U
   THEN DO:
         ASSIGN
            p-ok = FALSE
         .
         leave check_block_ .
   END.
   IF p-menu-group-id = "all":U
   THEN DO:
         ASSIGN
            p-ok = FALSE
         .
         leave check_block_ .
   END.
end.
end procedure.
procedure chk-actg :
  define input  parameter p-db-num           as integer   no-undo .
  define input  parameter p-user-id          as character no-undo .
  define input  parameter p-action-head-code as integer   no-undo .
  define input  parameter p-action-item-id   as character no-undo .
  define input  parameter p-action-context   as character no-undo .
  define input  parameter p-host-code        as integer   no-undo .
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define input  parameter p-cli-grp-code     as integer   no-undo .
  define input  parameter p-gds-grp-code     as integer   no-undo .
  define input  parameter p-gds-code         as integer   no-undo .
  define input  parameter p-show-message     as logical   no-undo .
  define output parameter p-ok               as logical   no-undo .
  define variable vss-description as character no-undo initial "chk-actg-01: проверка прав доступа для пользователя".
  define buffer buf_user-account             for ub.user-account .
  define buffer buf_action-item              for ub.action-item .
  define buffer buf_action-item-attr         for ub.action-item-attr .
  define buffer buf_user-login-action-role   for ub.user-login-action-role .
  define buffer buf_user-login-action-item   for ub.user-login-action-item .
  define buffer buf_action-role-item         for ub.action-role-item .
  define buffer buf_action-role-item-gds     for ub.action-role-item-gds .
  define buffer buf_action-role-item-gds-grp for ub.action-role-item-gds-grp .
  define buffer buf_action-post-user-login   for ub.action-post-user-login .
  define buffer buf_goods                    for ub.goods .
  define buffer buf_gds-grp                  for ub.gds-grp .
  define variable v-gds-grp-code    as integer      no-undo.
  define variable v-ok    as logical      no-undo.
  define variable v-on-gds    as logical      no-undo.
  define variable v-on-grp    as logical      no-undo.
  define variable v-on-gbl    as logical      no-undo.
  define variable v-full-user-name      as character no-undo .
  define variable v-error-message       as character no-undo .
  define variable v-check-db-num        as integer   no-undo .
  define variable v-check-user-id       as character no-undo .
  define variable v-check-administrator as logical   no-undo .
  define variable v-action-item-id      as character no-undo .
  define variable v-action-item-description as character no-undo .
  define variable v-context             as character    no-undo.
  define variable v-chk-news            as logical   no-undo initial no .
  do
  on error undo, return error return-value
  :
    if num-entries(p-user-id, chr(4)) = 2
    then do :
      v-chk-news = logical(entry(2, p-user-id, chr(4))) no-error.
      p-user-id = entry(1, p-user-id, chr(4)).
    end.
    case p-action-context:
      when 'firm':U then do:
         assign
           v-context = substitute(" к фирме &1", p-host-code)
         .
      end.
      when 'object':U then do:
         assign
           v-context = substitute(" к объекту &1 &2", p-obj-type, p-obj-code)
         .
      end.
      otherwise do:
         assign
           v-context = " (без привязки)"
         .
      end.
    end case.
define variable vss-include-info13 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run actn-grp in g#library2
    ( output v-on-grp
    ) no-error .
end.
    check_block:
    do
    on error undo, leave
    :
if not v-chk-news
then do :
  run gbl\get-gbl2.p (output p-ok ) no-error.
  if p-ok then leave check_block .
end.
      if not can-find(first buf_user-account no-lock
        where buf_user-account.user-id = p-user-id
                      )
      then do:
        assign
          p-ok            = false
          v-error-message = substitute('Не найден пользователь. Идентификатор пользователя &1'
                                      ,p-user-id
                                      )
        .
        leave check_block .
      end.
define variable vss-include-info14 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrfulnm in g#library
  (input  p-user-id
  ,output v-full-user-name
  ) no-error .
      if error-status :error
      then do:
        assign
          p-ok            = false
          v-error-message = substitute('Ошибка при определении имени пользователя. Идентификатор пользователя &1. &2 &3'
                                      ,p-user-id
                                      ,error-status :get-message(1)
                                      ,return-value
                                      )
        .
        leave check_block .
      end.
      find first buf_action-item no-lock
        where buf_action-item.action-head-code = p-action-head-code
          and buf_action-item.action-item-id   = p-action-item-id
        no-error .
      if not available buf_action-item
      then do:
        assign
          p-ok            = false
          v-error-message = substitute('Запрошена проверка права &1, которое отсутствует в текущей конфигурации.'
                                      ,p-action-item-id
                                      )
        .
        leave check_block .
      end.
      assign
         v-action-item-id      =  buf_action-item.action-item-id
         v-action-item-description = SUBSTITUTE("Название права: &1~nОписание: &2", buf_action-item.action-item-name, buf_action-item.action-item-description)
      .
define variable vss-include-info15 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usercred in g#library2
  (input  p-db-num
  ,input  p-user-id
  ,output v-check-db-num
  ,output v-check-user-id
  ,output v-check-administrator
  ) no-error .
      if error-status :error
      then do:
        assign
          p-ok            = false
          v-error-message = substitute('Ошибка при вызове процедуры usercred. &1 &2'
                                      ,error-status :get-message(1)
                                      ,return-value
                                      )
        .
        leave check_block .
      end.
define variable vss-include-info16 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run actn-gbl in g#library2
    ( output v-on-gbl
    ) no-error .
end.
      if v-on-grp then do:
       find first buf_action-item-attr no-lock
          where buf_action-item-attr.action-head-code =  buf_action-item.action-head-code
          and buf_action-item-attr.action-item-code =  buf_action-item.action-item-code
          and buf_action-item-attr.attr-code    =  "Linking":U no-error.
        if not available buf_action-item-attr
        then v-on-grp = no.
        else
          if lookup( buf_action-item-attr.attr-value , "gds-grp" ) = 0
          then v-on-grp = no.
          else
            if p-gds-grp-code = 0 or p-gds-grp-code = ?
            then do:
              assign
                      p-ok            = false
                      v-error-message = substitute  ( 'Включен контроль прав по группам товаров. Запрошена проверка права &1 без указания кода группы товара.'
                                                    , p-action-item-id
                                                    )
                  .
              leave check_block .
            end.
      end.
      if v-check-administrator = true
      then do:
        assign
          p-ok = true
        .
        leave check_block .
      end.
      case p-action-context
      :
        when 'global':U
        then do:
          for each buf_user-login-action-role no-lock
            where buf_user-login-action-role.db-num              = v-check-db-num
              and buf_user-login-action-role.action-head-code    = 0
              and buf_user-login-action-role.user-id             = v-check-user-id
              and buf_user-login-action-role.action-role-context = 'global':U
          on error undo, return error return-value
          :
            if can-find( first buf_action-role-item no-lock
              where buf_action-role-item.db-num           = (if v-on-gbl then 0 else v-check-db-num)
                and buf_action-role-item.action-head-code = p-action-head-code
                and buf_action-role-item.action-role-code = buf_user-login-action-role.action-role-code
                and buf_action-role-item.action-item-code = buf_action-item.action-item-code)
            then do:
              v-gds-grp-code = p-gds-grp-code.
              if v-on-grp and buf_user-login-action-role.gds-grp-code = ? then next.
              if v-on-grp  then do while v-gds-grp-code <> 0 :
                if buf_user-login-action-role.gds-grp-code = v-gds-grp-code then do:
                    assign
                          p-ok            = true
                          v-error-message = '':U
                    .
                    leave check_block .
                end.
                FIND FIRST buf_gds-grp
                      WHERE buf_gds-grp.node-code = v-gds-grp-code
                      no-lock
                      no-error
                      .
                IF NOT AVAILABLE buf_gds-grp
                THEN DO:
                  assign
                      p-ok            = FALSE
                      v-error-message = substitute  ( 'Для пользователя &1 (&2)~n недоступно право &3 ~n&4 ~nпривязка &5~nгруппа товара &6'
                                                    , p-user-id
                                                    , v-full-user-name
                                                    , v-action-item-id
                                                    , v-action-item-description
                                                    , v-context
                                                    , p-gds-grp-code
                                                    )
                  .
                  leave check_block .
                END.
                assign
                  v-gds-grp-code = buf_gds-grp.upper-code
                .
              END.
              else do:
                assign
                  p-ok            = true
                  v-error-message = '':U
                .
                leave check_block .
              end.
            end.
          end.
          assign
            p-ok            = false
            v-error-message = substitute('Для пользователя &1 (&2) недоступно право &3 &4 ~n(без привязки)~n&5'
                                        ,p-user-id
                                        ,v-full-user-name
                                        ,v-action-item-id
                                        ,v-action-item-description
                                        , if v-on-grp then "Группа товаров:" + string(p-gds-grp-code)  else ""
                                        )
          .
          leave check_block .
        end.
        when 'firm':U
        then do:
          for each buf_user-login-action-role no-lock
            where buf_user-login-action-role.db-num              = v-check-db-num
              and buf_user-login-action-role.action-head-code    = 0
              and buf_user-login-action-role.user-id             = v-check-user-id
              and buf_user-login-action-role.action-role-context = 'firm':U
              and buf_user-login-action-role.host-code           = p-host-code
          on error undo, return error return-value
          :
            if can-find( first buf_action-role-item no-lock
              where buf_action-role-item.db-num           = (if v-on-gbl then 0 else v-check-db-num)
                and buf_action-role-item.action-head-code = p-action-head-code
                and buf_action-role-item.action-role-code = buf_user-login-action-role.action-role-code
                and buf_action-role-item.action-item-code = buf_action-item.action-item-code)
            then do:
              v-gds-grp-code = p-gds-grp-code.
              if v-on-grp and buf_user-login-action-role.gds-grp-code = ? then next.
              if v-on-grp  then do while v-gds-grp-code <> 0 :
                if buf_user-login-action-role.gds-grp-code = v-gds-grp-code then do:
                    assign
                          p-ok            = true
                          v-error-message = '':U
                    .
                    leave check_block .
                end.
                FIND FIRST buf_gds-grp
                      WHERE buf_gds-grp.node-code = v-gds-grp-code
                      no-lock
                      no-error
                      .
                IF NOT AVAILABLE buf_gds-grp
                THEN DO:
                  assign
                      p-ok            = FALSE
                      v-error-message = substitute  ( 'Для пользователя &1 (&2)~n недоступно право &3 ~n&4 ~nпривязка &5~nгруппа товара &6'
                                                    , p-user-id
                                                    , v-full-user-name
                                                    , v-action-item-id
                                                    , v-action-item-description
                                                    , v-context
                                                    , p-gds-grp-code
                                                    )
                  .
                  leave check_block .
                END.
                assign
                  v-gds-grp-code = buf_gds-grp.upper-code
                .
              END.
              else do:
                assign
                  p-ok            = true
                  v-error-message = '':U
                .
                leave check_block .
              end.
            end.
          end.
          for each buf_user-login-action-role no-lock
            where buf_user-login-action-role.db-num              = v-check-db-num
              and buf_user-login-action-role.action-head-code    = 0
              and buf_user-login-action-role.user-id             = v-check-user-id
              and buf_user-login-action-role.action-role-context = 'global':U
          on error undo, return error return-value
          :
            if can-find( first buf_action-role-item no-lock
              where buf_action-role-item.db-num           = (if v-on-gbl then 0 else v-check-db-num)
                and buf_action-role-item.action-head-code = p-action-head-code
                and buf_action-role-item.action-role-code = buf_user-login-action-role.action-role-code
                and buf_action-role-item.action-item-code = buf_action-item.action-item-code)
            then do:
              v-gds-grp-code = p-gds-grp-code.
              if v-on-grp and buf_user-login-action-role.gds-grp-code = ? then next.
              if v-on-grp  then do while v-gds-grp-code <> 0 :
                if buf_user-login-action-role.gds-grp-code = v-gds-grp-code then do:
                    assign
                          p-ok            = true
                          v-error-message = '':U
                    .
                    leave check_block .
                end.
                FIND FIRST buf_gds-grp
                      WHERE buf_gds-grp.node-code = v-gds-grp-code
                      no-lock
                      no-error
                      .
                IF NOT AVAILABLE buf_gds-grp
                THEN DO:
                  assign
                      p-ok            = FALSE
                      v-error-message = substitute  ( 'Для пользователя &1 (&2)~n недоступно право &3 ~n&4 ~nпривязка &5~nгруппа товара &6'
                                                    , p-user-id
                                                    , v-full-user-name
                                                    , v-action-item-id
                                                    , v-action-item-description
                                                    , v-context
                                                    , p-gds-grp-code
                                                    )
                  .
                  leave check_block .
                END.
                assign
                  v-gds-grp-code = buf_gds-grp.upper-code
                .
              END.
              else do:
                assign
                  p-ok            = true
                  v-error-message = '':U
                .
                leave check_block .
              end.
            end.
          end.
          assign
            p-ok            = false
            v-error-message = substitute('Для пользователя &1 (&2) недоступно право &3 &4 ~nпривязка &5~n&6'
                                        , p-user-id
                                        , v-full-user-name
                                        , v-action-item-id
                                        , v-action-item-description
                                        , v-context
                                        , if v-on-grp then "Группа товаров:" + string(p-gds-grp-code)  else ""
                                        )
          .
          leave check_block .
        end.
        when 'object':U
        then do:
          for each buf_user-login-action-role no-lock
            where buf_user-login-action-role.db-num              = v-check-db-num
              and buf_user-login-action-role.action-head-code    = 0
              and buf_user-login-action-role.user-id             = v-check-user-id
              and buf_user-login-action-role.action-role-context = 'object':U
              and buf_user-login-action-role.obj-type            = p-obj-type
              and buf_user-login-action-role.obj-code            = p-obj-code
          on error undo, return error return-value
          :
            if can-find( first buf_action-role-item no-lock
              where buf_action-role-item.db-num           = (if v-on-gbl then 0 else v-check-db-num)
                and buf_action-role-item.action-head-code = p-action-head-code
                and buf_action-role-item.action-role-code = buf_user-login-action-role.action-role-code
                and buf_action-role-item.action-item-code = buf_action-item.action-item-code)
            then do:
              v-gds-grp-code = p-gds-grp-code.
              if v-on-grp and buf_user-login-action-role.gds-grp-code = ? then next.
              if v-on-grp  then do while v-gds-grp-code <> 0 :
                if buf_user-login-action-role.gds-grp-code = v-gds-grp-code then do:
                    assign
                          p-ok            = true
                          v-error-message = '':U
                    .
                    leave check_block .
                end.
                FIND FIRST buf_gds-grp
                      WHERE buf_gds-grp.node-code = v-gds-grp-code
                      no-lock
                      no-error
                      .
                IF NOT AVAILABLE buf_gds-grp
                THEN DO:
                  assign
                      p-ok            = FALSE
                      v-error-message = substitute  ( 'Для пользователя &1 (&2)~n недоступно право &3 ~n&4 ~nпривязка &5~nгруппа товара &6'
                                                    , p-user-id
                                                    , v-full-user-name
                                                    , v-action-item-id
                                                    , v-action-item-description
                                                    , v-context
                                                    , p-gds-grp-code
                                                    )
                  .
                  leave check_block .
                END.
                assign
                  v-gds-grp-code = buf_gds-grp.upper-code
                .
              END.
              else do:
                assign
                  p-ok            = true
                  v-error-message = '':U
                .
                leave check_block .
              end.
            end.
          end.
          for each buf_user-login-action-role no-lock
            where buf_user-login-action-role.db-num              = v-check-db-num
              and buf_user-login-action-role.action-head-code    = 0
              and buf_user-login-action-role.user-id             = v-check-user-id
              and buf_user-login-action-role.action-role-context = 'firm':U
              and buf_user-login-action-role.host-code           = p-host-code
          on error undo, return error return-value
          :
            if can-find( first buf_action-role-item no-lock
              where buf_action-role-item.db-num           = (if v-on-gbl then 0 else v-check-db-num)
                and buf_action-role-item.action-head-code = p-action-head-code
                and buf_action-role-item.action-role-code = buf_user-login-action-role.action-role-code
                and buf_action-role-item.action-item-code = buf_action-item.action-item-code)
            then do:
              v-gds-grp-code = p-gds-grp-code.
              if v-on-grp and buf_user-login-action-role.gds-grp-code = ? then next.
              if v-on-grp  then do while v-gds-grp-code <> 0 :
                if buf_user-login-action-role.gds-grp-code = v-gds-grp-code then do:
                    assign
                          p-ok            = true
                          v-error-message = '':U
                    .
                    leave check_block .
                end.
                FIND FIRST buf_gds-grp
                      WHERE buf_gds-grp.node-code = v-gds-grp-code
                      no-lock
                      no-error
                      .
                IF NOT AVAILABLE buf_gds-grp
                THEN DO:
                  assign
                      p-ok            = FALSE
                      v-error-message = substitute  ( 'Для пользователя &1 (&2)~n недоступно право &3 ~n&4 ~nпривязка &5~nгруппа товара &6'
                                                    , p-user-id
                                                    , v-full-user-name
                                                    , v-action-item-id
                                                    , v-action-item-description
                                                    , v-context
                                                    , p-gds-grp-code
                                                    )
                  .
                  leave check_block .
                END.
                assign
                  v-gds-grp-code = buf_gds-grp.upper-code
                .
              END.
              else do:
                assign
                  p-ok            = true
                  v-error-message = '':U
                .
                leave check_block .
              end.
            end.
          end.
          for each buf_user-login-action-role no-lock
            where buf_user-login-action-role.db-num              = v-check-db-num
              and buf_user-login-action-role.action-head-code    = 0
              and buf_user-login-action-role.user-id             = v-check-user-id
              and buf_user-login-action-role.action-role-context = 'global':U
          on error undo, return error return-value
          :
            if can-find( first buf_action-role-item no-lock
              where buf_action-role-item.db-num           = (if v-on-gbl then 0 else v-check-db-num)
                and buf_action-role-item.action-head-code = p-action-head-code
                and buf_action-role-item.action-role-code = buf_user-login-action-role.action-role-code
                and buf_action-role-item.action-item-code = buf_action-item.action-item-code)
            then do:
              v-gds-grp-code = p-gds-grp-code.
              if v-on-grp and buf_user-login-action-role.gds-grp-code = ? then next.
              if v-on-grp  then do while v-gds-grp-code <> 0 :
                if buf_user-login-action-role.gds-grp-code = v-gds-grp-code then do:
                    assign
                          p-ok            = true
                          v-error-message = '':U
                    .
                    leave check_block .
                end.
                FIND FIRST buf_gds-grp
                      WHERE buf_gds-grp.node-code = v-gds-grp-code
                      no-lock
                      no-error
                      .
                IF NOT AVAILABLE buf_gds-grp
                THEN DO:
                  assign
                      p-ok            = FALSE
                      v-error-message = substitute  ( 'Для пользователя &1 (&2)~n недоступно право &3 ~n&4 ~nпривязка &5~nгруппа товара &6'
                                                    , p-user-id
                                                    , v-full-user-name
                                                    , v-action-item-id
                                                    , v-action-item-description
                                                    , v-context
                                                    , p-gds-grp-code
                                                    )
                  .
                  leave check_block .
                END.
                assign
                  v-gds-grp-code = buf_gds-grp.upper-code
                .
              END.
              else do:
                assign
                  p-ok            = true
                  v-error-message = '':U
                .
                leave check_block .
              end.
            end.
          end.
          assign
            p-ok            = false
            v-error-message = substitute('Для пользователя &1 (&2) недоступно право &3 &4 ~nпривязка &5~n&6'
                                        , p-user-id
                                        , v-full-user-name
                                        , v-action-item-id
                                        , v-action-item-description
                                        , v-context
                                        , if v-on-grp then "Группа товаров:" + string(p-gds-grp-code)  else ""
                                        )
          .
          leave check_block .
        end.
        otherwise do:
          assign
            p-ok            = false
            v-error-message = substitute('Внутренняя ошибка. Неизвестное значение контекста &1'
                                        ,p-action-context
                                        )
          .
          leave check_block .
        end.
      end case.
    end.
    if  p-ok = false
    and p-show-message = true
    then do:
      if v-error-message = '':U
      then do:
        assign
          v-error-message = 'Неизвестная ошибка при проверке прав доступа'
        .
      end.
      message
        v-error-message
      view-as alert-box error .
    end.
    return v-error-message .
  end.
end procedure.
procedure chk-acps :
  define input  parameter p-db-num           as integer   no-undo .
  define input  parameter p-action-head-code as integer   no-undo .
  define input  parameter p-action-post-code as integer   no-undo .
  define input  parameter p-action-item-id   as character no-undo .
  define input  parameter p-action-context   as character no-undo .
  define input  parameter p-host-code        as integer   no-undo .
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define input  parameter p-cli-grp-code     as integer   no-undo .
  define input  parameter p-gds-grp-code     as integer   no-undo .
  define input  parameter p-gds-code         as integer   no-undo .
  define input  parameter p-show-message     as logical   no-undo .
  define output parameter p-ok               as logical   no-undo .
  define variable vss-description as character no-undo initial "chk-acps-01: проверка прав доступа для роли".
  define buffer buf_action-post            for ub.action-post .
  define buffer buf_action-post-role       for ub.action-post-role .
  define buffer buf_action-item            for ub.action-item .
  define buffer buf_action-role-item       for ub.action-role-item .
  define variable v-error-message       as character no-undo .
  do
  on error undo, return error return-value
  :
    check_block:
    do
    on error undo, leave
    :
      run gbl\get-gbl2.p (output p-ok ) no-error.
      if p-ok then return.
      find first buf_action-post no-lock
        where buf_action-post.db-num           = p-db-num
          and buf_action-post.action-head-code = p-action-head-code
          and buf_action-post.action-post-code = p-action-post-code
        no-error .
      if not available buf_action-post
      then do:
        assign
          p-ok            = false
          v-error-message = substitute('Не найдена должность. Идентификатор должности &1 &2 &3'
                                      ,p-db-num
                                      ,p-action-head-code
                                      ,p-action-post-code
                                      )
        .
        leave check_block .
      end.
      find first buf_action-item no-lock
        where buf_action-item.action-head-code = p-action-head-code
          and buf_action-item.action-item-id   = p-action-item-id
        no-error .
      if not available buf_action-item
      then do:
        assign
          p-ok            = false
          v-error-message = substitute('Запрошена проверка права &1, которое отсутствует в текущей конфигурации.'
                                      ,p-action-item-id
                                      )
        .
        leave check_block .
      end.
      case p-action-context
      :
        when 'global':U
        then do:
          for each buf_action-post-role no-lock
            where buf_action-post-role.db-num              = p-db-num
              and buf_action-post-role.action-head-code    = p-action-head-code
              and buf_action-post-role.action-post-code    = p-action-post-code
              and buf_action-post-role.action-role-context = 'global':U
          on error undo, return error return-value
          :
            find first buf_action-role-item no-lock
              where buf_action-role-item.db-num           = p-db-num
                and buf_action-role-item.action-head-code = p-action-head-code
                and buf_action-role-item.action-role-code = buf_action-post-role.action-role-code
                and buf_action-role-item.action-item-code = buf_action-item.action-item-code
              no-error .
            if available buf_action-role-item
            then do:
              assign
                p-ok            = true
                v-error-message = '':U
              .
              leave check_block .
            end.
          end.
          assign
            p-ok            = false
            v-error-message = substitute('Для роли &1 &2 &3 (&4 &5) недоступно право &6 &7 (без привязки)'
                                        ,p-db-num
                                        ,p-action-head-code
                                        ,p-action-post-code
                                        ,buf_action-post.action-post-name
                                        ,buf_action-post.action-post-description
                                        ,buf_action-item.action-item-id
                                        ,buf_action-item.action-item-description
                                        )
          .
          leave check_block .
        end.
        when 'firm':U
        then do:
          for each buf_action-post-role no-lock
            where buf_action-post-role.db-num              = p-db-num
              and buf_action-post-role.action-head-code    = p-action-head-code
              and buf_action-post-role.action-post-code    = p-action-post-code
              and buf_action-post-role.action-role-context = 'firm':U
              and buf_action-post-role.host-code           = p-host-code
          on error undo, return error return-value
          :
            find first buf_action-role-item no-lock
              where buf_action-role-item.db-num           = p-db-num
                and buf_action-role-item.action-head-code = p-action-head-code
                and buf_action-role-item.action-role-code = buf_action-post-role.action-role-code
                and buf_action-role-item.action-item-code = buf_action-item.action-item-code
              no-error .
            if available buf_action-role-item
            then do:
              assign
                p-ok            = true
                v-error-message = '':U
              .
              leave check_block .
            end.
          end.
          for each buf_action-post-role no-lock
            where buf_action-post-role.db-num              = p-db-num
              and buf_action-post-role.action-head-code    = p-action-head-code
              and buf_action-post-role.action-post-code    = p-action-post-code
              and buf_action-post-role.action-role-context = 'global':U
          on error undo, return error return-value
          :
            find first buf_action-role-item no-lock
              where buf_action-role-item.db-num           = p-db-num
                and buf_action-role-item.action-head-code = p-action-head-code
                and buf_action-role-item.action-role-code = buf_action-post-role.action-role-code
                and buf_action-role-item.action-item-code = buf_action-item.action-item-code
              no-error .
            if available buf_action-role-item
            then do:
              assign
                p-ok            = true
                v-error-message = '':U
              .
              leave check_block .
            end.
          end.
          assign
            p-ok            = false
            v-error-message = substitute('Для роли &1 &2 &3 (&4 &5) недоступно право &6 &7'
                                        ,p-db-num
                                        ,p-action-head-code
                                        ,p-action-post-code
                                        ,buf_action-post.action-post-name
                                        ,buf_action-post.action-post-description
                                        ,buf_action-item.action-item-id
                                        ,buf_action-item.action-item-description
                                        )
          .
          leave check_block .
        end.
        when 'object':U
        then do:
          for each buf_action-post-role no-lock
            where buf_action-post-role.db-num              = p-db-num
              and buf_action-post-role.action-head-code    = p-action-head-code
              and buf_action-post-role.action-post-code    = p-action-post-code
              and buf_action-post-role.action-role-context = 'object':U
              and buf_action-post-role.obj-type            = p-obj-type
              and buf_action-post-role.obj-code            = p-obj-code
          on error undo, return error return-value
          :
            find first buf_action-role-item no-lock
              where buf_action-role-item.db-num           = p-db-num
                and buf_action-role-item.action-head-code = p-action-head-code
                and buf_action-role-item.action-role-code = buf_action-post-role.action-role-code
                and buf_action-role-item.action-item-code = buf_action-item.action-item-code
              no-error .
            if available buf_action-role-item
            then do:
              assign
                p-ok            = true
                v-error-message = '':U
              .
              leave check_block .
            end.
          end.
          for each buf_action-post-role no-lock
            where buf_action-post-role.db-num              = p-db-num
              and buf_action-post-role.action-head-code    = p-action-head-code
              and buf_action-post-role.action-post-code    = p-action-post-code
              and buf_action-post-role.action-role-context = 'firm':U
              and buf_action-post-role.host-code           = p-host-code
          on error undo, return error return-value
          :
            find first buf_action-role-item no-lock
              where buf_action-role-item.db-num           = p-db-num
                and buf_action-role-item.action-head-code = p-action-head-code
                and buf_action-role-item.action-role-code = buf_action-post-role.action-role-code
                and buf_action-role-item.action-item-code = buf_action-item.action-item-code
              no-error .
            if available buf_action-role-item
            then do:
              assign
                p-ok            = true
                v-error-message = '':U
              .
              leave check_block .
            end.
          end.
          for each buf_action-post-role no-lock
            where buf_action-post-role.db-num              = p-db-num
              and buf_action-post-role.action-head-code    = p-action-head-code
              and buf_action-post-role.action-post-code    = p-action-post-code
              and buf_action-post-role.action-role-context = 'global':U
          on error undo, return error return-value
          :
            find first buf_action-role-item no-lock
              where buf_action-role-item.db-num           = p-db-num
                and buf_action-role-item.action-head-code = p-action-head-code
                and buf_action-role-item.action-role-code = buf_action-post-role.action-role-code
                and buf_action-role-item.action-item-code = buf_action-item.action-item-code
              no-error .
            if available buf_action-role-item
            then do:
              assign
                p-ok            = true
                v-error-message = '':U
              .
              leave check_block .
            end.
          end.
          assign
            p-ok            = false
            v-error-message = substitute('Для роли &1 &2 &3 (&4 &5) недоступно право &6 &7  (без привязки)'
                                        ,p-db-num
                                        ,p-action-head-code
                                        ,p-action-post-code
                                        ,buf_action-post.action-post-name
                                        ,buf_action-post.action-post-description
                                        ,buf_action-item.action-item-id
                                        ,buf_action-item.action-item-description
                                        )
          .
          leave check_block .
        end.
        otherwise do:
          assign
            p-ok            = false
            v-error-message = substitute('Внутренняя ошибка. Неизвестное значение привязки &1'
                                        ,p-action-context
                                        )
          .
          leave check_block .
        end.
      end.
      assign
        p-ok            = false
        v-error-message = substitute('Для роли &1 &2 &3 (&4 &5) недоступно право &6 &7'
                                    ,p-db-num
                                    ,p-action-head-code
                                    ,p-action-post-code
                                    ,buf_action-post.action-post-name
                                    ,buf_action-post.action-post-description
                                    ,buf_action-item.action-item-id
                                    ,buf_action-item.action-item-description
                                    )
      .
      leave check_block .
    end.
    if  p-ok = false
    and p-show-message = true
    then do:
      if v-error-message = '':U
      then do:
        assign
          v-error-message = 'Неизвестная ошибка при проверке прав доступа'
        .
      end.
      message
        v-error-message
        view-as alert-box error .
    end.
    output stream sout to value('chk-acps.log':U) append .
    put stream sout unformatted
      'chk-acps':U
      string(today, '99/99/9999':U) ' ':U string(time,  'HH:MM:SS':U) ' ':U 'p-ok ':U p-ok chr(10)
      '  p-db-num           ':U p-db-num           chr(10)
      '  p-action-head-code ':U p-action-head-code chr(10)
      '  p-action-post-code ':U p-action-post-code chr(10)
      '  p-action-item-id   ':U p-action-item-id   chr(10)
      '  p-action-context   ':U p-action-context   chr(10)
      '  p-host-code        ':U p-host-code        chr(10)
      '  p-obj-type         ':U p-obj-type         chr(10)
      '  p-obj-code         ':U p-obj-code         chr(10)
      '  p-cli-grp-code     ':U p-cli-grp-code     chr(10)
      '  p-gds-grp-code     ':U p-gds-grp-code     chr(10)
      '  p-gds-code         ':U p-gds-code         chr(10)
      '  p-show-message     ':U p-show-message     chr(10)
      '  v-error-message    ':U v-error-message    chr(10)
      '  p-name-01          ':U program-name(3)    chr(10)
      '  p-name-02          ':U program-name(4)    chr(10)
      '  p-name-03          ':U program-name(5)    chr(10)
      .
    output stream sout close .
    return v-error-message .
  end.
end procedure.
procedure getcurus :
  define output parameter p-db-num  as integer   no-undo .
  define output parameter p-user-id as character no-undo .
  define buffer buf_user-login for ub.user-login .
  define variable v-user-login as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output p-db-num
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при опрелении номера базы данных" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    assign
      v-user-login = userid('ub':u)
    .
    find buf_user-login no-lock
      where buf_user-login.db-num     = p-db-num
        and buf_user-login.status_    = 0
        and buf_user-login.user-login = v-user-login
      no-error no-wait .
    if not available buf_user-login
    then do:
      undo, return error substitute("Не найден пользователь БД: &1, логин: &2"
                                   ,p-db-num
                                   ,v-user-login
                                   ) .
    end.
    assign
      p-user-id = buf_user-login.user-id
    .
  end.
end procedure.
procedure user-adm :
  define input  parameter p-db-num     as integer   no-undo .
  define input  parameter p-user-id    as character no-undo .
  define output parameter p-user-admin as logical   no-undo .
  define variable v-check-db-num        as integer   no-undo .
  define variable v-check-user-id       as character no-undo .
  define variable v-check-administrator as logical   no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info18 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usercred in g#library2
  (input  p-db-num
  ,input  p-user-id
  ,output v-check-db-num
  ,output v-check-user-id
  ,output v-check-administrator
  )  .
    assign
      p-user-admin = v-check-administrator
    .
  end.
end procedure.
procedure goassizt :
define input  parameter p-event-code as character no-undo .
define input  parameter p-gds-code as integer   no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define input  parameter p-ask      as logical   no-undo .
define output parameter p-Ok       as logical   no-undo .
define output parameter p-mess     as character no-undo .
define variable v-event-fullname as character no-undo .
define variable v-izt-new    as logical   no-undo .
define variable v-izt-com    as logical   no-undo .
define variable v-izt-del    as logical   no-undo .
define variable v-izt-spec   as logical   no-undo .
define variable v-izt-empty  as logical   no-undo .
define buffer buf_assortment-matrix-goods for ub.assortment-matrix-goods  .
define buffer buf_assortment-matrix       for ub.assortment-matrix .
define buffer buf_gds-obj for ub.gds-obj  .
define variable return-AssMin   as logical   no-undo .
define variable return-igt      as character no-undo .
define variable gdop-min-stock  as decimal   no-undo .
define variable grop-max-stock  as decimal   no-undo .
define variable grop-level-always-presence  as decimal   no-undo .
define variable grop-min-order as decimal   no-undo .
define variable loc-ok as logical   no-undo .
define variable v-mess as character no-undo .
  do
  on error undo, return error return-value
  :
  run gbl\get-gbl2.p (output p-Ok ) no-error.
  if p-Ok then return.
  p-Ok = true .
  p-mess = "".
  find first ub.goods no-lock where ub.goods.gds-code = p-gds-code no-error .
  if error-status :error then return error.
  if ub.goods.stts <> 0 then do:
              find first buf_gds-obj no-lock where
                         buf_gds-obj.obj-type = p-obj-type and
                         buf_gds-obj.obj-code = p-obj-code and
                         buf_gds-obj.gds-code = p-gds-code no-error .
      if not available buf_gds-obj or buf_gds-obj.fact-qnty = 0 then do:
      p-Ok = false  .
      p-mess = "Товар "+ ub.goods.artic + " "  + ub.goods.gds-name + " Удален и нет остатков ! " .
      return .
     end.
  end.
    find first buf_assortment-matrix no-lock where
                buf_assortment-matrix.obj-code = p-obj-code and
                buf_assortment-matrix.obj-type = p-obj-type and
                buf_assortment-matrix.asmt-status = integer ('0':U) no-error .
                if available buf_assortment-matrix then do:
                    find first buf_assortment-matrix-goods no-lock
                        where buf_assortment-matrix-goods.asmg-status = integer ('0':U)  and
                              buf_assortment-matrix-goods.asmt-id     = buf_assortment-matrix.asmt-id and
                              buf_assortment-matrix-goods.db-num      = buf_assortment-matrix.db-num  and
                              buf_assortment-matrix-goods.gds-code    = p-gds-code  no-error .
                        if not available buf_assortment-matrix-goods then do:
                            p-Ok = false  .
                            p-mess = "Товар "+ ub.goods.artic + " "  + ub.goods.gds-name +
                                " На объекте:" + p-obj-type + string(p-obj-code) +
                                " не входит в Ассортиментную матрицу " +
                                  buf_assortment-matrix.asmt-name   +
                                " в статусе текущий ." .
                             return .
                        end.
                end.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjpr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  ?
  ,input  ?
  ,input  ?
  ,input  p-gds-code
  ,output return-AssMin
  ,output return-igt
  ,output gdop-min-stock
  ,output grop-max-stock
  ,output grop-level-always-presence
  ,output grop-min-order
  )  .
          define variable v-rest as character no-undo .
          find first buf_gds-obj no-lock where
                     buf_gds-obj.obj-type = p-obj-type and
                     buf_gds-obj.obj-code = p-obj-code and
                     buf_gds-obj.gds-code = p-gds-code no-error .
          if not available buf_gds-obj or buf_gds-obj.fact-qnty = 0 then do:
            v-rest = "norest" .
            v-mess = "".
          end.
          else do:
            v-rest = "rest" .
              if available buf_gds-obj and buf_gds-obj.fact-qnty <> 0 then do:
                v-mess = ( if buf_gds-obj.fact-qnty < 0 then "есть отрицательный остаток " + string(buf_gds-obj.fact-qnty)  else "есть остаток " + string(buf_gds-obj.fact-qnty) ) .
              end.
          end.
          p-event-code = entry (1, p-event-code, "-" ) + "-" + v-rest .
          v-event-fullname = entry(lookup(p-event-code,'ie-rest,ie-norest,iv-rest,iv-norest,mf_ie-rest,mf_ie-norest,ee-rest,ee-norest,ev-rest,ev-norest,cli_ev-rest,cli_ev-norest,mf_ee-rest,mf_ee-norest,cli_mf_ee-rest,cli_mf_ee-norest,ОП-rest,ОП-norest,ОР-rest,ОР-norest,cli_ОР-rest,cli_ОР-norest,ОО-rest,ОО-norest,cli_ОО-rest,cli_ОО-norest,ОФ-rest,ОФ-norest,ПО-rest,ПО-norest,rcv-rest,rcv-norest,cli_rcv-rest,cli_rcv-norest,scu-grp-matr,scu-grp-specif,delete-matr-rest,delete-matr-norest,ФП-rest,ФП-norest':U),'Внешний приход: остатки на объекте есть,Внешний приход: остатков нет,Внутрений приход: остатки на объекте есть,Внутренний приход: остатков нет,Межфирменный приход: остатки на объекте есть,Межфирменный приход: остатков нет,Внешний расход: остатки  есть,Внешний расход: остатков нет,Внутрений расход: остатки на объекте есть,Внутренний расход: остатков нет,Внутрений расход: остатки на объекте приемнике есть,Внутренний расход: остатков на объекте приемнике нет,Межфирменный расход: остатки на объекте есть,Межфирменный расход: остатков нет,Межфирменный расход: остатки на приемнике есть,Межфирменный расход: остатков на приемнике нет,Заказ ОП: остатки на объекте есть,Заказ ОП: остатков нет,Заказ ОРЦ: остатки на объекте есть,Заказ ОРЦ: остатков на объекте нет,Заказ ОРЦ: остатки на объекте приемнике есть,Заказ ОРЦ: остатков на объекте приемнике нет,Заказ ОO: остатки на объекте есть,Заказ ОO: остатков на объекте нет,Заказ ОO: остатки на объекте приемнике есть,Заказ ОO: остатков на объекте приемнике нет,Заказ ОФ: остатки на объекте есть,Заказ ОФ: остатков нет,Заказ Покупателя: остатки на объекте есть,Заказ Покупателя: остатков нет,Поставка (закрытие): остатки на объекте есть,Поставка (закрытие): остатков нет,Поставка (закрытие): остатки на объекте приемнике есть,Поставка (закрытие): остатков на объекте приемнике нет,Подсчет SCU по группам в Ассортиментной матрице,Подсчет SCU по группам в Спецификации,Удаление товара из матрицы: остатки на объекте есть,Удаление товара из матрицы: остатков на объекте нет,Заказ ФП: остатки на объекте есть,Заказ ФП: остатков нет':U) no-error .
          if error-status :error then do:
             p-Ok = true .
          end.
          else do:
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run iztrul in g#library2
  (input  p-event-code
  ,output v-izt-new
  ,output v-izt-com
  ,output v-izt-del
  ,output v-izt-spec
  ,output v-izt-empty
  )  .
        if ( return-igt = 'Новинка':U  and  v-izt-new = false ) or
          ( return-igt = 'Основная группа':U   and  v-izt-com = false ) or
          ( return-igt = 'На вывод из ассортимента':U   and  v-izt-del = false ) or
          ( return-igt = 'Нештатный':U  and  v-izt-spec = false ) or
          ( return-igt = 'Пусто':U and  v-izt-empty = false ) then do:
                p-Ok = false  .
                p-mess = substitute(
                      "ИЖТ Товара &1 &2 - &3&6 На объекте: &4&5 &8&6 Событие: &7"
                      ,ub.goods.artic,ub.goods.gds-name,return-igt,p-obj-type,p-obj-code,
                      chr(10),v-event-fullname,v-mess) .
        end.
        end.
   end.
end procedure.
procedure goassmat :
define input  parameter p-gds-code as integer   no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define input  parameter p-ask      as logical   no-undo .
define output parameter p-Ok       as logical   no-undo .
define output parameter p-mess     as character no-undo .
define buffer buf_assortment-matrix-goods for ub.assortment-matrix-goods  .
define buffer buf_assortment-matrix       for ub.assortment-matrix .
  do
  on error undo, return error return-value
  :
  p-Ok = true .
  p-mess = "" .
  find first ub.goods no-lock where ub.goods.gds-code = p-gds-code no-error .
  if error-status :error then return error.
  if ub.goods.stts <> 0 then do:
      p-Ok = false  .
      p-mess = "Товар "+ ub.goods.artic + " "  + ub.goods.gds-name + " Удален ! " .
  end.
    find first buf_assortment-matrix no-lock where
               buf_assortment-matrix.obj-code = p-obj-code and
               buf_assortment-matrix.obj-type = p-obj-type and
               buf_assortment-matrix.asmt-status = integer ('0':U) no-error .
               if available buf_assortment-matrix then do:
                    find first buf_assortment-matrix-goods no-lock
                        where buf_assortment-matrix-goods.asmg-status = integer ('0':U)  and
                              buf_assortment-matrix-goods.asmt-id     = buf_assortment-matrix.asmt-id and
                              buf_assortment-matrix-goods.db-num      = buf_assortment-matrix.db-num  and
                              buf_assortment-matrix-goods.gds-code    = p-gds-code  no-error .
                        if not available buf_assortment-matrix-goods then do:
                            p-Ok = false  .
                            p-mess = "Товар " + ub.goods.artic + " "  + ub.goods.gds-name +
                                " На объекте:" + p-obj-type + string(p-obj-code) +
                                " не входит в Ассортиментную матрицу " +
                                  buf_assortment-matrix.asmt-name   +
                                " в статусе текущий ." .
                        end.
                end.
  end.
end procedure.
procedure frmdbnum :
  define input  parameter p-host-code as integer no-undo .
  define output parameter p-firm-db-num   as integer   no-undo .
  define variable vss-description as character no-undo initial "frmdbnum-01: Определить главную базу данных фирмы".
  define buffer buf_sysconf for ub.sysconf .
  do
  on error undo, return error return-value
  :
    find first buf_sysconf no-lock
      where buf_sysconf.host-code = p-host-code
      no-error .
    if not available buf_sysconf
    then do:
      undo, return error substitute( "Ошибка задания входных параметров. Не найдена фирма &1", p-host-code) .
    end.
    assign
      p-firm-db-num = buf_sysconf.firm-db-num
    .
  end.
end procedure.
define variable vss-include-info21 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure pdecrypt :
     define input  parameter ip-value-to-dec as character no-undo.
     define output parameter op-char-value   as character no-undo.
  define variable decrypt-value          as raw       no-undo.
  define variable long-char-value        as longchar  no-undo.
  do
  on error undo, return error return-value
  :
   assign
      long-char-value = ip-value-to-dec
      op-char-value   = get-string(decrypt(base64-decode(long-char-value)),1)
      long-char-value = ""
   no-error.
   if error-status:error then op-char-value = ? .
   end.
end procedure.
define variable vss-include-info22 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure pencrypt :
       define input parameter ip-value-to-enc as character no-undo.
       define output parameter op-char-value  as character no-undo.
  define variable crypto-value           as raw       no-undo.
  do
  on error undo, return error return-value
  :
   assign
      crypto-value  = encrypt(ip-value-to-enc)
      op-char-value = base64-encode(crypto-value)
   no-error.
   if error-status:error then op-char-value = ? .
   end.
end procedure.
procedure gtplobjq :
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define output parameter p-plt-id     as integer   no-undo .
define output parameter p-plt-db-num as integer   no-undo .
define output parameter p-col as integer   no-undo .
define buffer main_price-list-type for ub.price-list-type  .
  do
  on error undo, return error return-value
  :
p-plt-id     = 0.
p-plt-db-num = 0.
define variable v-cur-db-num like ub.db.db-num no-undo .
define variable v-db-num like ub.db.db-num no-undo .
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-cur-db-num
  )  .
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-db-num
  )  .
define variable v-col as integer   no-undo .
define variable v-str as character no-undo .
v-col = 0 .
v-str = "" .
for each main_price-list-type no-lock where
         main_price-list-type.main = true and
         main_price-list-type.only-gbd = 1 and
         main_price-list-type.stts = integer('0':U)
on error undo, return error return-value
:
   if main_price-list-type.gop-id <> 0  then do:
      run metod-gop-obj in this-procedure ( v-cur-db-num , main_price-list-type.gop-id , main_price-list-type.gop-db-num) .
   if can-find (first x_obj-group where x_obj-group.obj-type = p-obj-type and x_obj-group.obj-code = p-obj-code )
      then do:
        v-col = v-col + 1 .
        p-plt-id     = main_price-list-type.plt-id     .
        p-plt-db-num = main_price-list-type.plt-db-num .
        v-str = v-str + main_price-list-type.name + "," .
      end.
   end.
   else do:
      v-col = v-col + 1 .
      p-plt-id     = main_price-list-type.plt-id     .
      p-plt-db-num = main_price-list-type.plt-db-num .
      v-str = v-str + main_price-list-type.name + "," .
   end.
end.
define variable vv-obj-db-num as integer   no-undo .
define variable i as integer   no-undo .
   p-col = v-col .
    if v-col > 1 then do:
       p-col = v-col .
       p-plt-id     = 0.
       p-plt-db-num = 0.
       undo, return error .
    end.
  end.
end procedure.
procedure actn-gds :
define output parameter p-on as logical          no-undo.
define buffer buf_global-state             for ub.global-state .
define buffer buf_global-state-attr        for ub.global-state-attr .
do
on error undo, return error
:
   FIND FIRST buf_global-state
         NO-LOCK
         .
   FIND FIRST buf_global-state-attr
         WHERE buf_global-state-attr.gls-id    = buf_global-state.gls-id
            AND buf_global-state-attr.attr-code = "action-goods"
         NO-LOCK
         NO-error
         .
   IF  AVAILABLE buf_global-state-attr
   AND LOGICAL(buf_global-state-attr.attr-value)
   THEN DO:
      assign
         p-on = TRUE
      .
   END.
   ELSE DO:
      assign
         p-on = FALSE
      .
   END.
end.
end procedure.
procedure actn-grp :
define output parameter p-on as logical          no-undo.
define buffer buf_global-state             for ub.global-state .
define buffer buf_global-state-attr        for ub.global-state-attr .
do
on error undo, return error
:
   FIND FIRST buf_global-state
        NO-LOCK
        .
   FIND FIRST buf_global-state-attr
        WHERE buf_global-state-attr.gls-id    = buf_global-state.gls-id
          AND buf_global-state-attr.attr-code = "action-gds-groups"
        NO-LOCK
        NO-error
        .
   IF  AVAILABLE buf_global-state-attr
   AND LOGICAL(buf_global-state-attr.attr-value)
   THEN DO:
      assign
         p-on = TRUE
      .
   END.
   ELSE DO:
      assign
         p-on = FALSE
      .
   END.
end.
end procedure.
procedure actn-gbl :
define output parameter p-on as logical          no-undo.
define buffer buf_global-state             for ub.global-state .
define buffer buf_global-state-attr        for ub.global-state-attr .
do
on error undo, return error
:
   FIND FIRST buf_global-state
        NO-LOCK
        .
   FIND FIRST buf_global-state-attr
        WHERE buf_global-state-attr.gls-id    = buf_global-state.gls-id
          AND buf_global-state-attr.attr-code = "action-gbl"
        NO-LOCK
        NO-error
        .
   IF  AVAILABLE buf_global-state-attr
   AND LOGICAL(buf_global-state-attr.attr-value)
   THEN DO:
      assign
         p-on = TRUE
      .
   END.
   ELSE DO:
      assign
         p-on = FALSE
      .
   END.
end.
end procedure.
procedure actgrpcd :
define input         parameter p-db-num             as integer   no-undo .
define input         parameter p-user-id            as character no-undo .
define input         parameter p-action-head-code   as integer   no-undo .
define input         parameter p-action-item-id     as character no-undo .
define input         parameter p-obj-type           as character no-undo .
define input         parameter p-obj-code           as integer   no-undo .
define input-output  parameter p-gds-grp-code-list  as character no-undo .
define output        parameter p-not-list           as character no-undo .
define output        parameter p-ok                 as logical   no-undo .
define variable v-count             as integer     no-undo .
define variable v-ok                as logical     no-undo .
define variable v-out-code-list     as character   no-undo .
define variable v-err-str           as character    no-undo.
define buffer buf_gds-grp       for ub.gds-grp .
do
on error undo, return error
:
   _add-gds-grp:
   DO v-count = 1 TO NUM-ENTRIES(p-gds-grp-code-list)
   on error undo, next
   :
      find first buf_gds-grp
         where buf_gds-grp.node-code = INTEGER(ENTRY(v-count, p-gds-grp-code-list))
         NO-LOCK
         no-error.
      IF AVAILABLE buf_gds-grp THEN DO:
define variable vss-include-info25 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  p-db-num
    ,input  p-user-id
    ,input  p-action-head-code
    ,input  p-action-item-id
    ,input  'object':U
    ,input  0
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  0
    ,input  buf_gds-grp.node-code
    ,input  0
    ,input  FALSE
    ,output v-ok
    )  .
end.
         IF NOT v-ok
         THEN DO:
            assign
               p-not-list = IF p-not-list = "":U THEN SUBSTITUTE("не добавлена группа товаров &1 &2", buf_gds-grp.node-code, buf_gds-grp.node-name)
                                                 ELSE p-not-list + chr(10) + SUBSTITUTE("не добавлена группа товаров &1 &2", buf_gds-grp.node-code, buf_gds-grp.node-name)
            .
            NEXT _add-gds-grp.
         end.
         assign
            v-out-code-list = IF v-out-code-list = "":U THEN string( buf_gds-grp.node-code )
                                                        ELSE v-out-code-list + chr(44) + string( buf_gds-grp.node-code )
         .
      end.
   end.
   IF  p-not-list <> "":U
   THEN DO:
      assign
         v-err-str = substring(p-not-list, 1, R-INDEX(p-not-list,chr(10), 400) - 1)
      .
      message
              "В выбранном списке есть товары, на которые у Вас отсутствуют права."
         skip "Такие товары не будут добавлены:"
         skip(1)  v-err-str
         SKIP(1)  IF LENGTH(p-not-list) > 400 THEN "и т.д." ELSE "":U
      view-as alert-box information.
   END.
   assign
      p-gds-grp-code-list = v-out-code-list
      p-ok = TRUE
   .
end.
end procedure.
procedure actgrprc :
define input         parameter p-db-num             as integer   no-undo .
define input         parameter p-user-id            as character no-undo .
define input         parameter p-action-head-code   as integer   no-undo .
define input         parameter p-action-item-id     as character no-undo .
define input         parameter p-obj-type           as character no-undo .
define input         parameter p-obj-code           as integer   no-undo .
define input-output  parameter p-gds-grp-recid-list as character no-undo .
define output        parameter p-not-list           as character no-undo .
define output        parameter p-ok                 as logical   no-undo .
define variable v-count             as integer     no-undo .
define variable v-ok                as logical     no-undo .
define variable v-out-recid-list     as character   no-undo .
define variable v-err-str           as character    no-undo.
define buffer buf_gds-grp       for ub.gds-grp .
do
on error undo, return error
:
   _add-gds-grp:
   DO v-count = 1 TO NUM-ENTRIES(p-gds-grp-recid-list)
   on error undo, next
   :
      find first buf_gds-grp
         where recid( buf_gds-grp ) = INTEGER(ENTRY(v-count, p-gds-grp-recid-list))
         NO-LOCK
         no-error.
      IF AVAILABLE buf_gds-grp THEN DO:
define variable vss-include-info26 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  p-db-num
    ,input  p-user-id
    ,input  p-action-head-code
    ,input  p-action-item-id
    ,input  'object':U
    ,input  0
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  0
    ,input  buf_gds-grp.node-code
    ,input  0
    ,input  FALSE
    ,output v-ok
    )  .
end.
         IF NOT v-ok
         THEN DO:
            assign
               p-not-list = IF p-not-list = "":U THEN SUBSTITUTE("не добавлена группа товаров &1 &2", buf_gds-grp.node-code, buf_gds-grp.node-name)
                                                 ELSE p-not-list + chr(10) + SUBSTITUTE("не добавлена группа товаров &1 &2", buf_gds-grp.node-code, buf_gds-grp.node-name)
            .
            NEXT _add-gds-grp.
         end.
         assign
            v-out-recid-list = IF v-out-recid-list = "":U THEN string( recid( buf_gds-grp) )
                                                          ELSE v-out-recid-list + chr(44) + string( recid( buf_gds-grp) )
         .
      end.
   end.
   IF  p-not-list <> "":U
   THEN DO:
      assign
         v-err-str = substring(p-not-list, 1, R-INDEX(p-not-list,chr(10), 400) - 1)
      .
      message
              "В выбранном списке есть товары, на которые у Вас отсутствуют права."
         skip "Такие товары не будут добавлены:"
         skip(1)  v-err-str
         SKIP(1)  IF LENGTH(p-not-list) > 400 THEN "и т.д." ELSE "":U
      view-as alert-box information.
   END.
   assign
      p-gds-grp-recid-list = v-out-recid-list
      p-ok = TRUE
   .
end.
end procedure.
procedure actgdscd :
define input         parameter p-db-num           as integer   no-undo .
define input         parameter p-user-id          as character no-undo .
define input         parameter p-action-head-code as integer   no-undo .
define input         parameter p-action-item-id   as character no-undo .
define input         parameter p-obj-type         as character no-undo .
define input         parameter p-obj-code         as integer   no-undo .
define input-output  parameter p-gds-code-list    as character no-undo .
define output        parameter p-not-list         as character FORMAT "x(100)" no-undo .
define output        parameter p-ok               as logical   no-undo .
define variable v-count             as integer     no-undo .
define variable v-ok                as logical     no-undo .
define variable v-out-code-list     as character   no-undo .
define variable v-err-str           as character    no-undo.
define buffer buf_goods       for ub.goods .
do
on error undo, return error
:
   _add-goods:
   DO v-count = 1 TO NUM-ENTRIES(p-gds-code-list)
   on error undo, next
   :
      find first buf_goods
         where buf_goods.gds-code = INTEGER(ENTRY(v-count, p-gds-code-list))
         NO-LOCK
         no-error.
      IF AVAILABLE buf_goods THEN DO:
define variable vss-include-info27 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  p-db-num
    ,input  p-user-id
    ,input  p-action-head-code
    ,input  p-action-item-id
    ,input  'object':U
    ,input  0
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  0
    ,input  0
    ,input  buf_goods.gds-code
    ,input  FALSE
    ,output v-ok
    )  .
end.
         IF NOT v-ok
         THEN DO:
            assign
               p-not-list = IF p-not-list = "":U THEN SUBSTITUTE("не добавлен товар &1 &2", buf_goods.gds-code, buf_goods.gds-name)
                                                 ELSE p-not-list + chr(10) + SUBSTITUTE("не добавлен товар &1 &2", buf_goods.gds-code, buf_goods.gds-name)
            .
            NEXT _add-goods.
         END.
         assign
            v-out-code-list = IF v-out-code-list = "":U THEN string( buf_goods.gds-code )
                                                         ELSE v-out-code-list + chr(44) + string( buf_goods.gds-code )
            .
      end.
   end.
   IF  p-not-list <> "":U
   THEN DO:
      assign
         v-err-str = substring(p-not-list, 1, R-INDEX(p-not-list,chr(10), 400) - 1)
      .
      message
              "В выбранном списке есть товары, на которые у Вас отсутствуют права."
         skip "Такие товары не будут добавлены:"
         skip(1)  v-err-str
         SKIP(1)  IF LENGTH(p-not-list) > 400 THEN "и т.д." ELSE "":U
      view-as alert-box information.
   END.
   assign
      p-gds-code-list = v-out-code-list
      p-ok = TRUE
   .
end.
end procedure.
procedure actgdsrc :
define input         parameter p-db-num           as integer   no-undo .
define input         parameter p-user-id          as character no-undo .
define input         parameter p-action-head-code as integer   no-undo .
define input         parameter p-action-item-id   as character no-undo .
define input         parameter p-obj-type         as character no-undo .
define input         parameter p-obj-code         as integer   no-undo .
define input-output  parameter p-gds-recid-list   as character no-undo .
define output        parameter p-not-list         as character no-undo .
define output        parameter p-ok               as logical   no-undo .
define variable v-count             as integer     no-undo .
define variable v-ok                as logical     no-undo .
define variable v-first             as logical     no-undo .
define variable v-out-recid-list    as character   no-undo .
define variable v-err-str           as character    no-undo.
define buffer buf_goods       for ub.goods .
DO
on error undo, next
:
   _add-goods:
   DO v-count = 1 TO NUM-ENTRIES(p-gds-recid-list)
   on error undo, next
   :
      find first buf_goods
         where recid( buf_goods ) = INTEGER(ENTRY(v-count, p-gds-recid-list))
         NO-LOCK
         no-error.
      IF AVAILABLE buf_goods THEN DO:
define variable vss-include-info28 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  p-db-num
    ,input  p-user-id
    ,input  p-action-head-code
    ,input  p-action-item-id
    ,input  'object':U
    ,input  0
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  0
    ,input  0
    ,input  buf_goods.gds-code
    ,input  FALSE
    ,output v-ok
    )  .
end.
         IF NOT v-ok
         THEN DO:
            assign
               p-not-list = IF p-not-list = "":U THEN SUBSTITUTE("не добавлен товар &1 &2", buf_goods.gds-code, buf_goods.gds-name)
                                                 ELSE p-not-list + chr(10) + SUBSTITUTE("не добавлен товар &1 &2", buf_goods.gds-code, buf_goods.gds-name)
            .
            NEXT _add-goods.
         END.
         assign
            v-out-recid-list = IF v-out-recid-list = "":U THEN string( recid( buf_goods) )
                                                            ELSE v-out-recid-list + chr(44) + string( recid( buf_goods) )
         .
      end.
   end.
   IF  p-not-list <> "":U
   THEN DO:
      IF LENGTH(p-not-list) > 400
      THEN DO:
         assign
            v-err-str = substring(p-not-list, 1, R-INDEX(p-not-list,chr(10), 400) - 1)
         .
      END.
      ELSE DO:
         assign
            v-err-str = p-not-list
         .
      END.
      message
              "В выбранном списке есть товары, на которые у Вас отсутствуют права."
         skip "Такие товары не будут добавлены:"
         skip(1)  v-err-str
         SKIP(1)  IF LENGTH(p-not-list) > 400 THEN "и т.д." ELSE "":U
      view-as alert-box information.
   END.
   assign
      p-gds-recid-list = v-out-recid-list
      p-ok = TRUE
   .
end.
end procedure.
procedure actgdsar :
define input         parameter p-db-num           as integer   no-undo .
define input         parameter p-user-id          as character no-undo .
define input         parameter p-action-head-code as integer   no-undo .
define input         parameter p-action-item-id   as character no-undo .
define input         parameter p-obj-type         as character no-undo .
define input         parameter p-obj-code         as integer   no-undo .
define input         parameter p-artic            as character no-undo .
define input         parameter p-prod-type        as character no-undo .
define input         parameter p-prod-code        as integer   no-undo .
define input         parameter p-message          as logical   no-undo .
define output        parameter p-ok               as logical   no-undo .
define variable v-count             as integer     no-undo .
define variable v-ok                as logical     no-undo .
define variable v-first             as logical     no-undo .
define variable v-out-recid-list    as character   no-undo .
define variable v-err-str           as character    no-undo.
define buffer buf_goods       for ub.goods .
DO
on error undo, next
:
      find first buf_goods
           where buf_goods.artic  = p-artic
             and buf_goods.prod-type  = p-prod-type
             and buf_goods.prod-code  = p-prod-code
         NO-LOCK
         no-error.
      IF AVAILABLE buf_goods
      THEN DO:
define variable vss-include-info29 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  p-db-num
    ,input  p-user-id
    ,input  p-action-head-code
    ,input  p-action-item-id
    ,input  'object':U
    ,input  0
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  0
    ,input  0
    ,input  buf_goods.gds-code
    ,input  p-message
    ,output p-ok
    )  .
end.
      end.
end.
end procedure.
procedure actgdsbc :
define input         parameter p-db-num           as integer   no-undo .
define input         parameter p-user-id          as character no-undo .
define input         parameter p-action-head-code as integer   no-undo .
define input         parameter p-action-item-id   as character no-undo .
define input         parameter p-obj-type         as character no-undo .
define input         parameter p-obj-code         as integer   no-undo .
define input         parameter p-barcode          as integer   no-undo .
define input         parameter p-message          as logical   no-undo .
define output        parameter p-ok               as logical   no-undo .
define variable v-count             as integer     no-undo .
define variable v-ok                as logical     no-undo .
define variable v-first             as logical     no-undo .
define variable v-out-recid-list    as character   no-undo .
define variable v-err-str           as character    no-undo.
define buffer buf_goods       for ub.goods .
define buffer buf_bar-code    for ub.bar-code .
DO
on error undo, next
:
      find FIRST buf_bar-code
           where BUF_bar-code.b-code = p-barcode
           no-lock
           NO-ERROR
           .
      find first buf_goods
           where buf_goods.gds-code  = buf_bar-code.gds-code
           NO-LOCK
           no-error
           .
      IF AVAILABLE buf_goods
      THEN DO:
define variable vss-include-info30 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  p-db-num
    ,input  p-user-id
    ,input  p-action-head-code
    ,input  p-action-item-id
    ,input  'object':U
    ,input  0
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  0
    ,input  0
    ,input  buf_goods.gds-code
    ,input  p-message
    ,output p-ok
    )  .
end.
      end.
end.
end procedure.
procedure gtplmrgn :
define input  parameter parparentproc     as handle    no-undo .
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define output parameter p-mrgn-ie    as character no-undo .
define output parameter p-mrgn-iv    as character no-undo .
define output parameter p-mrgn-im    as character no-undo .
define buffer buf_price-list-type      for ub.price-list-type       .
define buffer buf_price-list-type-attr for ub.price-list-type-attr  .
define variable   v-plt-id     as integer   no-undo .
define variable   v-plt-db-num as integer   no-undo .
do
on error undo, return error return-value
:
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gtplobj in g#library2
  (input  parparentproc
  ,input  p-obj-type
  ,input  p-obj-code
  ,input  yes
  ,output v-plt-id
  ,output v-plt-db-num
  ) no-error .
  if error-status :error then do:
    message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    "Поиск ГТПЛ для переоценок"
    view-as alert-box error
    .
    return error.
  end.
  find first buf_price-list-type no-lock where
             buf_price-list-type.stts = integer('0':U) and
             buf_price-list-type.main = true  and
             buf_price-list-type.plt-id     = v-plt-id     and
             buf_price-list-type.plt-db-num = v-plt-db-num no-error .
  if not available buf_price-list-type then do:
    return error substitute ( "Не найден главный тип прайс-листа  &1 &2" ,v-plt-id ,v-plt-db-num ) .
  end.
  find first buf_price-list-type-attr no-lock where
             buf_price-list-type-attr.plt-id     = v-plt-id     and
             buf_price-list-type-attr.plt-db-num = v-plt-db-num and
             buf_price-list-type-attr.attr-code  = 'ie-gen-marg':U
             no-error .
  if available buf_price-list-type-attr then do:
    p-mrgn-ie = buf_price-list-type-attr.attr-value.
  end.
  else do:
    p-mrgn-ie = 'no-margin':U.
  end.
  find first buf_price-list-type-attr no-lock where
             buf_price-list-type-attr.plt-id     = v-plt-id     and
             buf_price-list-type-attr.plt-db-num = v-plt-db-num and
             buf_price-list-type-attr.attr-code  = 'iv-gen-marg':U
             no-error .
  if available buf_price-list-type-attr then do:
    p-mrgn-iv = buf_price-list-type-attr.attr-value.
  end.
  else do:
    p-mrgn-iv = 'no-margin':U.
  end.
  find first buf_price-list-type-attr no-lock where
             buf_price-list-type-attr.plt-id     = v-plt-id     and
             buf_price-list-type-attr.plt-db-num = v-plt-db-num and
             buf_price-list-type-attr.attr-code  = 'im-gen-marg':U
             no-error .
  if available buf_price-list-type-attr then do:
     p-mrgn-im = buf_price-list-type-attr.attr-value.
  end.
  else do:
    p-mrgn-im = 'no-margin':U.
  end.
end .
end procedure.
procedure partmrgn :
define input  parameter parparentproc     as handle    no-undo .
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define output parameter p-mrgn-ie    as character no-undo .
define output parameter p-mrgn-iv    as character no-undo .
define output parameter p-mrgn-im    as character no-undo .
define buffer buf_price-list-type      for ub.price-list-type       .
define buffer buf_price-list-type-attr for ub.price-list-type-attr  .
define variable   v-plt-id     as integer   no-undo .
define variable   v-plt-db-num as integer   no-undo .
do
on error undo, return error return-value
:
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gtplobj in g#library2
  (input  parparentproc
  ,input  p-obj-type
  ,input  p-obj-code
  ,input  yes
  ,output v-plt-id
  ,output v-plt-db-num
  ) no-error .
  if error-status :error then do:
    message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    "Поиск ГТПЛ для переоценок"
    view-as alert-box error
    .
    return error.
  end.
  find first buf_price-list-type no-lock where
             buf_price-list-type.stts = integer('0':U) and
             buf_price-list-type.main = true  and
             buf_price-list-type.plt-id     = v-plt-id     and
             buf_price-list-type.plt-db-num = v-plt-db-num no-error .
  if not available buf_price-list-type then do:
    return error substitute ( "Не найден главный тип прайс-листа  &1 &2" ,v-plt-id ,v-plt-db-num ) .
  end.
  find first buf_price-list-type-attr no-lock where
             buf_price-list-type-attr.plt-id     = v-plt-id     and
             buf_price-list-type-attr.plt-db-num = v-plt-db-num and
             buf_price-list-type-attr.attr-code  = 'ie-gen-marg-parts':U
             no-error .
  if available buf_price-list-type-attr then do:
    p-mrgn-ie = buf_price-list-type-attr.attr-value.
  end.
  else do:
    p-mrgn-ie = 'no-margin':U.
  end.
  find first buf_price-list-type-attr no-lock where
             buf_price-list-type-attr.plt-id     = v-plt-id     and
             buf_price-list-type-attr.plt-db-num = v-plt-db-num and
             buf_price-list-type-attr.attr-code  = 'iv-gen-marg-parts':U
             no-error .
  if available buf_price-list-type-attr then do:
    p-mrgn-iv = buf_price-list-type-attr.attr-value.
  end.
  else do:
    p-mrgn-iv = 'no-margin':U.
  end.
  find first buf_price-list-type-attr no-lock where
             buf_price-list-type-attr.plt-id     = v-plt-id     and
             buf_price-list-type-attr.plt-db-num = v-plt-db-num and
             buf_price-list-type-attr.attr-code  = 'im-gen-marg-parts':U
             no-error .
  if available buf_price-list-type-attr then do:
    p-mrgn-im = buf_price-list-type-attr.attr-value.
  end.
  else do:
    p-mrgn-im = 'no-margin':U.
  end.
end .
end procedure.
procedure gtplpnakl :
define input  parameter parparentproc     as handle    no-undo .
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define output parameter p-nakl-ie    as logical   no-undo .
define output parameter p-nakl-iv    as logical   no-undo .
define output parameter p-nakl-im    as logical   no-undo .
define buffer buf_price-list-type      for ub.price-list-type       .
define buffer buf_price-list-type-attr for ub.price-list-type-attr  .
define variable   v-plt-id     as integer   no-undo .
define variable   v-plt-db-num as integer   no-undo .
do
on error undo, return error return-value
:
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gtplobj in g#library2
  (input  parparentproc
  ,input  p-obj-type
  ,input  p-obj-code
  ,input  yes
  ,output v-plt-id
  ,output v-plt-db-num
  ) no-error .
  if error-status :error then do:
    message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    "Поиск ГТПЛ для переоценок"
    view-as alert-box error
    .
    return error.
  end.
  find first buf_price-list-type no-lock where
             buf_price-list-type.stts = integer('0':U) and
             buf_price-list-type.main = true  and
             buf_price-list-type.plt-id     = v-plt-id     and
             buf_price-list-type.plt-db-num = v-plt-db-num no-error .
  if not available buf_price-list-type then return error substitute ( "Не найден главный тип прайс-листа  &1 &2" ,v-plt-id ,v-plt-db-num ) .
  find first buf_price-list-type-attr no-lock where
             buf_price-list-type-attr.plt-id     = v-plt-id     and
             buf_price-list-type-attr.plt-db-num = v-plt-db-num and
             buf_price-list-type-attr.attr-code  = 'ie-pr-nakl':U
             no-error .
   if available buf_price-list-type-attr then p-nakl-ie = if buf_price-list-type-attr.attr-value = 'yes' then true else false .
      else p-nakl-ie = false        .
  find first buf_price-list-type-attr no-lock where
             buf_price-list-type-attr.plt-id     = v-plt-id     and
             buf_price-list-type-attr.plt-db-num = v-plt-db-num and
             buf_price-list-type-attr.attr-code  = 'iv-pr-nakl':U
             no-error .
   if available buf_price-list-type-attr then p-nakl-iv = if buf_price-list-type-attr.attr-value = 'yes' then true else false .
      else p-nakl-iv = false .
  find first buf_price-list-type-attr no-lock where
             buf_price-list-type-attr.plt-id     = v-plt-id     and
             buf_price-list-type-attr.plt-db-num = v-plt-db-num and
             buf_price-list-type-attr.attr-code  = 'im-pr-nakl':U
             no-error .
   if available buf_price-list-type-attr then p-nakl-im = if buf_price-list-type-attr.attr-value = 'yes' then true else false .
      else p-nakl-im = false .
end .
end procedure.
procedure gtpl-fs :
define input  parameter parparentproc as handle    no-undo .
define input  parameter p-obj-type    as character no-undo .
define input  parameter p-obj-code    as integer   no-undo .
define output parameter p-first-ie    as integer   no-undo .
define output parameter p-first-iv    as integer   no-undo .
define output parameter p-first-im    as integer   no-undo .
define output parameter p-second-ie   as integer   no-undo .
define output parameter p-second-iv   as integer   no-undo .
define output parameter p-second-im   as integer   no-undo .
define buffer buf_price-list-type      for ub.price-list-type       .
define buffer buf_price-list-type-attr for ub.price-list-type-attr  .
define variable   v-plt-id     as integer   no-undo .
define variable   v-plt-db-num as integer   no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gtplobj in g#library2
  (input  parparentproc
  ,input  p-obj-type
  ,input  p-obj-code
  ,input  yes
  ,output v-plt-id
  ,output v-plt-db-num
  ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "Поиск ГТПЛ для переоценок"
      view-as alert-box error
    .
    return error.
  end.
  find first buf_price-list-type no-lock where
             buf_price-list-type.stts = integer('0':U) and
             buf_price-list-type.main = true  and
             buf_price-list-type.plt-id     = v-plt-id     and
             buf_price-list-type.plt-db-num = v-plt-db-num no-error .
  if not available buf_price-list-type then return error substitute ( "Не найден главный тип прайс-листа  &1 &2" ,v-plt-id ,v-plt-db-num ) .
  find first buf_price-list-type-attr no-lock where
             buf_price-list-type-attr.plt-id     = v-plt-id     and
             buf_price-list-type-attr.plt-db-num = v-plt-db-num and
             buf_price-list-type-attr.attr-code  = 'ie-objfirst':U
             no-error .
   if available buf_price-list-type-attr then p-first-ie = int( buf_price-list-type-attr.attr-value ) .
      else p-first-ie = 0       .
  find first buf_price-list-type-attr no-lock where
             buf_price-list-type-attr.plt-id     = v-plt-id     and
             buf_price-list-type-attr.plt-db-num = v-plt-db-num and
             buf_price-list-type-attr.attr-code  = 'iv-objfirst':U
             no-error .
   if available buf_price-list-type-attr then p-first-iv = int( buf_price-list-type-attr.attr-value ) .
      else p-first-iv = 0 .
  find first buf_price-list-type-attr no-lock where
             buf_price-list-type-attr.plt-id     = v-plt-id     and
             buf_price-list-type-attr.plt-db-num = v-plt-db-num and
             buf_price-list-type-attr.attr-code  = 'im-objfirst':U
             no-error .
   if available buf_price-list-type-attr then p-first-im = int( buf_price-list-type-attr.attr-value ) .
      else p-first-im = 0 .
  find first buf_price-list-type-attr no-lock where
             buf_price-list-type-attr.plt-id     = v-plt-id     and
             buf_price-list-type-attr.plt-db-num = v-plt-db-num and
             buf_price-list-type-attr.attr-code  = 'ie-objsecond':U
             no-error .
   if available buf_price-list-type-attr then p-second-ie = int( buf_price-list-type-attr.attr-value ) .
      else p-second-ie = 1        .
  find first buf_price-list-type-attr no-lock where
             buf_price-list-type-attr.plt-id     = v-plt-id     and
             buf_price-list-type-attr.plt-db-num = v-plt-db-num and
             buf_price-list-type-attr.attr-code  = 'iv-objsecond':U
             no-error .
   if available buf_price-list-type-attr then p-second-iv = int( buf_price-list-type-attr.attr-value ) .
      else p-second-iv = 1 .
  find first buf_price-list-type-attr no-lock where
             buf_price-list-type-attr.plt-id     = v-plt-id     and
             buf_price-list-type-attr.plt-db-num = v-plt-db-num and
             buf_price-list-type-attr.attr-code  = 'im-objsecond':U
             no-error .
   if available buf_price-list-type-attr then p-second-im = int( buf_price-list-type-attr.attr-value ) .
      else p-second-im = 1 .
end .
end procedure.
procedure a-nwspdf :
define input  parameter p-plt-id      as integer   no-undo .
define input  parameter p-plt-db-num  as integer   no-undo .
define input  parameter p-pdf-id      as integer   no-undo .
define input  parameter p-pdf-db-num  as integer   no-undo .
define output parameter p-ask as logical   no-undo .
define buffer buf_price-doc-forming for ub.price-doc-forming  .
define buffer buf_price-list-type   for ub.price-list-type    .
  do
  on error undo, return error return-value
  :
    p-ask = false .
    find first buf_price-list-type no-lock where
            buf_price-list-type.plt-id = p-plt-id and
            buf_price-list-type.plt-db-num = p-plt-db-num no-error .
    if error-status :error then return error substitute ("Не найден ТПЛ &1 &2 &3 &4" , p-plt-id , p-plt-db-num , error-status :get-message(1) , return-value ) .
    find first buf_price-doc-forming no-lock where
                buf_price-doc-forming.plt-id     = p-plt-id     and
                buf_price-doc-forming.plt-db-num = p-plt-db-num and
                buf_price-doc-forming.pdf-id     = p-pdf-id     and
                buf_price-doc-forming.pdf-db     = p-pdf-db-num
                no-error .
    if error-status :error then return error  substitute ("Не найден ДНЦ &1 &2 &3 &4" , p-plt-id , p-plt-db-num ,p-pdf-id , p-pdf-db-num , error-status :get-message(1) , return-value ) .
      if buf_price-doc-forming.stts = integer('3':U) or buf_price-doc-forming.stts = integer('1':U)
      then do:
        if buf_price-list-type.ban-discnt > 0 then p-ask = true .
      end.
  end.
end procedure.
define temp-table temp-izt-rul no-undo
field event-code  as character
field izd-new     as logical
field izd-com     as logical
field izd-del     as logical
field izd-spec    as logical
field izd-empty   as logical
index pi event-code
.
procedure iztrul :
define input  parameter p-event-code as character no-undo .
define output parameter p-izd-new   as logical   no-undo .
define output parameter p-izd-com   as logical   no-undo .
define output parameter p-izd-del   as logical   no-undo .
define output parameter p-izd-spec  as logical   no-undo .
define output parameter p-izd-empty as logical   no-undo .
define variable v-i as integer   no-undo .
  do
  on error undo, return error return-value
  :
   v-i = 0 .
   for each  temp-izt-rul no-lock   :
       v-i = v-i + 1 .
   end.
   if v-i <> num-entries('ie-rest,ie-norest,iv-rest,iv-norest,mf_ie-rest,mf_ie-norest,ee-rest,ee-norest,ev-rest,ev-norest,cli_ev-rest,cli_ev-norest,mf_ee-rest,mf_ee-norest,cli_mf_ee-rest,cli_mf_ee-norest,ОП-rest,ОП-norest,ОР-rest,ОР-norest,cli_ОР-rest,cli_ОР-norest,ОО-rest,ОО-norest,cli_ОО-rest,cli_ОО-norest,ОФ-rest,ОФ-norest,ПО-rest,ПО-norest,rcv-rest,rcv-norest,cli_rcv-rest,cli_rcv-norest,scu-grp-matr,scu-grp-specif,delete-matr-rest,delete-matr-norest,ФП-rest,ФП-norest':U) then run get-temp-izt-rul in this-procedure .
   find first temp-izt-rul no-lock where
              temp-izt-rul.event-code = p-event-code no-error .
              if error-status :error then do:
                 return error substitute("Не верно задан event-code =  &1" , p-event-code) .
              end.
    assign
        p-izd-new  =    temp-izt-rul.izd-new
        p-izd-com  =    temp-izt-rul.izd-com
        p-izd-del  =    temp-izt-rul.izd-del
        p-izd-spec =    temp-izt-rul.izd-spec
        p-izd-empty =   temp-izt-rul.izd-empty
    .
    release temp-izt-rul.
  end.
end procedure.
procedure get-temp-izt-rul :
define variable v-str      as character no-undo .
define variable i    as integer   no-undo .
define variable v-n1 as integer   no-undo .
define variable v-strevent as character no-undo .
  do
  on error undo, return error return-value
  :
  for each temp-izt-rul :
    delete temp-izt-rul.
  end.
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input ''
  ,input 0
  ,input 'izt-rul':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = 'izt-rul'  then v-str = thbjattr_thbj-attr.property-value-character .
  end.
  v-n1 = num-entries (v-str, ";") .
    do i = 1 to v-n1 :
      v-strevent = entry(i, v-str, ";") .
      if num-entries(v-strevent) <> 6 then return error "Не верно заданы правила работы ИЖТ" .
      create temp-izt-rul.
      assign
        temp-izt-rul.event-code  = entry( 1 , v-strevent )
        temp-izt-rul.izd-new     = logical( entry( 2 , v-strevent ) )
        temp-izt-rul.izd-com     = logical( entry( 3 , v-strevent ) )
        temp-izt-rul.izd-del     = logical( entry( 4 , v-strevent ) )
        temp-izt-rul.izd-spec    = logical( entry( 5 , v-strevent ) )
        temp-izt-rul.izd-empty   = logical( entry( 6 , v-strevent ) )
      .
    end.
  end.
end procedure.
procedure ichprise :
  do
  on error undo, return error return-value
  :
define input  parameter p-b-code as integer   no-undo .
define input  parameter p-doc-num as character no-undo .
define output parameter p-is-ok as logical   no-undo .
define buffer buf_price-doc for ub.price-doc  .
define buffer buf_price-list for ub.price-list  .
define variable v-doc-num    as character no-undo .
define variable v-price-sale  as decimal   no-undo .
define variable v-road-tax   as decimal   no-undo .
define variable v-excise     as decimal   no-undo .
  do
  on error undo, return error return-value
  :
  p-is-ok = false .
find first buf_price-doc no-lock where buf_price-doc.doc-num = p-doc-num no-error .
find first buf_price-list no-lock where
           buf_price-list.doc-num = p-doc-num and
           buf_price-list.price-type = "" and
           buf_price-list.b-code = p-b-code no-error .
if error-status :error then return .
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  buf_price-doc.obj-type
  ,input  buf_price-doc.obj-code
  ,input  p-b-code
  ,input  0
  ,input  buf_price-doc.fact-order
  ,output v-doc-num
  ,output v-price-sale
  ,output v-road-tax
  ,output v-excise
  )  .
    if v-price-sale  <>  buf_price-list.price-sale  then do:
       p-is-ok = true .
    end.
  end.
  end.
end procedure.
