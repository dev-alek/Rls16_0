block-level on error undo, throw.
define parameter buffer buf_wth-doc for ub.wth-doc.
define parameter buffer buf_out_wth-doc for ub.wth-doc.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: wth-out.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/wth-out.p $":U .
define variable vss-description as character no-undo init "Создание документов внутреннего перемещения".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable same_db as logical   no-undo initial no .
define variable v-base-code         like ub.currency.curr-code no-undo .
DEFINE VARIABLE vardoc-rec as recid no-undo .
DEFINE VARIABLE varline-rec as recid no-undo .
DEFINE VARIABLE vardtl-rec as recid no-undo .
DEFINE VARIABLE varparts-rec as recid no-undo .
DEFINE VARIABLE f-date     AS DATE NO-UNDO.
DEFINE VARIABLE f-time     AS INT  NO-UNDO.
DEFINE VARIABLE s-date     AS DATE NO-UNDO.
DEFINE VARIABLE s-num      AS INT  NO-UNDO.
DEFINE VARIABLE s-name     AS CHAR NO-UNDO.
DEFINE VARIABLE is-parts   AS log  NO-UNDO.
DEFINE VARIABLE is-dtl     AS log  NO-UNDO.
define buffer doc-obj      for ub.clients .
define buffer buf_cliobj   for ub.clients .
define buffer buf_wth-line for ub.wth-line.
define buffer buf_wth-dtl  for ub.wth-dtl.
define buffer buf_wth-parts   for ub.wth-parts.
define buffer buf_out_wth-line for ub.wth-line.
define buffer buf_out_wth-dtl  for ub.wth-dtl.
define buffer buf_wth-par      for ub.wth-par.
define temp-table tt-par-dtl  no-undo like ub.wth-par
FIELD q-ty-doc     AS   DEC FORM     ">,>>>,>>>,>>>":U    COLUMN-LABEL "Кол-во по!документу"
FIELD q-ty-fact    AS   DEC FORM     ">,>>>,>>>,>>>":U    COLUMN-LABEL "Количество!факт"
FIELD doc-sum      like ub.wth-line.doc-sum FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма по!документу"
FIELD fact-sum     like ub.wth-line.doc-sum FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма!факт"
FIELD sum-gds-rubl like ub.wth-line.sum-gds-rubl  FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма по связ.!товарам (рубл)"
FIELD sum-gds-base like ub.wth-line.sum-gds-base  FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма по связ.!товарам (баз.вал.)"
FIELD price-rubl   like ub.wth-line.price-rubl  FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Цена товара!(рубл)"
FIELD price-base   like ub.wth-line.price-base  FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Цена товара!(баз.вал.)"
FIELD w-p-code     like ub.wth-dtl.w-p-code
FIELD doc-code     like ub.wth-dtl.doc-code
FIELD gds-code     like ub.wth-gds.gds-code
INDEX tt-pi    IS   PRIMARY UNIQUE par-code  w-p-code doc-code  wth-code
INDEX tt-i1                        par-feat par-unit par-val
INDEX tt-i2                        doc-sum  q-ty-doc
.
define temp-table tt-wth-line no-undo like ub.wth-line.
define temp-table tt-wth-parts no-undo like ub.wth-parts.
define variable v-ext-type as char no-undo.
define variable v-doc-code as char no-undo.
define variable v-today    as date no-undo.
_main:
do on error undo _main, return error return-value
   on stop undo _main, return error:
  find current buf_wth-doc  no-error .
  if not available buf_wth-doc then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден документ" skip
      view-as alert-box .
    undo, return error .
  end.
  define variable v-host-code like buf_wth-doc.host-code no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_wth-doc.obj-type
  ,input  buf_wth-doc.obj-code
  ,output v-host-code
  ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении кода фирмы для объекта с которого происходит перемещение" skip
      "Документ внутреннего перемещения" buf_wth-doc.doc-code skip
      "Объект" buf_wth-doc.obj-type buf_wth-doc.obj-code skip
      view-as alert-box error .
    undo, return error .
  end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-host-code
  ,output v-base-code
  ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении кода базовой валюты для фирмы" skip
      "Документ внутреннего перемещения" buf_wth-doc.doc-code skip
      "Объект" buf_wth-doc.obj-type buf_wth-doc.obj-code skip
      view-as alert-box error .
    undo, return error .
  end.
  define variable v-cli-host-code like buf_wth-doc.host-code no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_wth-doc.cli-type
  ,input  buf_wth-doc.cli-code
  ,output v-cli-host-code
  ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении кода фирмы для объекта на который происходит перемещение" skip
      "Документ внутреннего перемещения" buf_wth-doc.doc-code skip
      "Объект" buf_wth-doc.cli-type buf_wth-doc.cli-code skip
      view-as alert-box error .
    undo, return error .
  end.
  if v-cli-host-code <> v-host-code then do:
    message
      vss-workfile vss-revision vss-description skip
      "Документ " buf_wth-doc.doc-code skip
      "Фирма объекта откуда происходит перемещение" skip
      "не совпадает с фирмой, куда происходит перемещение" skip
      "v-host-code"     v-host-code     skip
      "v-cli-host-code" v-cli-host-code skip
      "Закрытие документа невозможно" skip
      view-as alert-box error .
    undo, return error .
  end.
  find ub.clients no-lock
    where ub.clients.obj-type = buf_wth-doc.cli-type
      and ub.clients.obj-code = buf_wth-doc.cli-code
    no-error .
  if not available ub.clients then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестный клиент" skip
      "Документ " buf_wth-doc.doc-code skip
      "Объект" buf_wth-doc.obj-type buf_wth-doc.obj-code skip
      "Клиент" buf_wth-doc.cli-code buf_wth-doc.cli-type skip
      view-as alert-box .
    undo, return error .
  end.
  if  buf_wth-doc.cli-type <> 'скл':U
  and buf_wth-doc.cli-type <> 'маг':U
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Клиент документа внутреннего перемещения не является объектом"
      "Документ " buf_wth-doc.doc-code skip
      "Объект" buf_wth-doc.obj-type buf_wth-doc.obj-code skip
      "Клиент" buf_wth-doc.cli-code buf_wth-doc.cli-type skip
      view-as alert-box error .
    undo, return error .
  end.
  find doc-obj no-lock
    where doc-obj.obj-type = buf_wth-doc.obj-type
      and doc-obj.obj-code = buf_wth-doc.obj-code
    no-error .
  if not available doc-obj then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестный объект" skip
      "Документ " buf_wth-doc.doc-code skip
      "Объект" buf_wth-doc.obj-type buf_wth-doc.obj-code skip
      "Клиент" buf_wth-doc.cli-code buf_wth-doc.cli-type skip
      view-as alert-box .
    undo, return error .
  end.
  if  buf_wth-doc.obj-type <> 'скл':U
  and buf_wth-doc.obj-type <> 'маг':U
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Объект документа внутреннего перемещения не является объектом"
      "Документ " buf_wth-doc.doc-code skip
      "Объект" buf_wth-doc.obj-type buf_wth-doc.obj-code skip
      "Клиент" buf_wth-doc.cli-code buf_wth-doc.cli-type skip
      view-as alert-box error .
    undo, return error .
  end.
  if doc-obj.db-num = clients.db-num
  and clients.db-num > 0 then do:
    assign
      same_db = yes
    .
  end.
  if (doc-obj.db-num > 0 and g#db-num = 0 and same_db = no )
  or (doc-obj.db-num = 0 and g#db-num = 0)
  or (g#db-num > 0 and same_db = yes)
  then do:
  end.
  else do:
    return.
  end.
if buf_wth-doc.doc-type = 'при':U and not buf_wth-doc.exter and not buf_wth-doc.inter then do:
  if can-find(first buf_wth-parts where
              buf_wth-parts.out-code = buf_wth-doc.doc-code
              and (buf_wth-parts.fact-rangeFrom <> buf_wth-parts.doc-rangeFrom or
                   buf_wth-parts.fact-rangeTo <> buf_wth-parts.doc-rangeTo or buf_wth-parts.stts = 1 )
              )
  or can-find(first buf_wth-line where
              buf_wth-line.doc-code = buf_wth-doc.doc-code
              and buf_wth-line.doc-sum <> buf_wth-line.fact-sum)
  then.
  else return.
end.
if buf_wth-doc.ext-doc-type = 'pc':U then do:
  run str/wth-inc1.p ( input yes,
                  input-output vardoc-rec,
                  input        'ДОБАВЛЕНИЕ':U,
                  input "":U ,
                  input buf_wth-doc.host-code,
                  input buf_wth-doc.obj-type,
                  input buf_wth-doc.obj-code,
                  input "":U,
                  input 0 ,
                  input buf_wth-doc.doc-date,
                  input buf_wth-doc.fact-date,
                  input buf_wth-doc.shift-date,
                  input buf_wth-doc.shift-num,
                  input buf_wth-doc.shift-name,
                  input buf_wth-doc.operator,
                  input buf_wth-doc.deliver,
                  input buf_wth-doc.receiver,
                  input 'рас':U,
                  input buf_wth-doc.auto-fill,
                  input buf_wth-doc.exter_,
                  input buf_wth-doc.inter_,
                  input buf_wth-doc.doc-code,
                  input 'док.МЦ':U,
                  input yes,
                  input 0,
                  input 0,
                  input buf_wth-doc.PS,
                  input 'накл':U,
                  input no  ,
                  'ep':U) .
end.
else  if buf_wth-doc.obj-type = buf_wth-doc.cli-type and
           buf_wth-doc.obj-code = buf_wth-doc.cli-code and
           buf_wth-doc.inter_ = yes
then do:
  if  buf_wth-doc.ext-doc-type = 'ej':U then v-ext-type = 'ij':U.
  else if  buf_wth-doc.ext-doc-type = 'ij':U then v-ext-type = 'ej':U.
  else if  buf_wth-doc.ext-doc-type = 'oj':U then v-ext-type = 'pj':U.
  else if  buf_wth-doc.ext-doc-type = 'jj':U then v-ext-type = 'fj':U.
     run str/wth-inc1.p ( input yes,
                  input-output vardoc-rec,
                  input        'ДОБАВЛЕНИЕ':U,
                  input replace(buf_wth-doc.doc-code, "-", "=") ,
                  input buf_wth-doc.host-code,
                  input buf_wth-doc.obj-type,
                  input buf_wth-doc.obj-code,
                  input buf_wth-doc.cli-type,
                  input buf_wth-doc.cli-code,
                  input buf_wth-doc.doc-date,
                  input buf_wth-doc.fact-date,
                  input buf_wth-doc.shift-date,
                  input buf_wth-doc.shift-num,
                  input buf_wth-doc.shift-name,
                  input buf_wth-doc.operator,
                  input buf_wth-doc.deliver,
                  input buf_wth-doc.receiver,
                  input (if buf_wth-doc.doc-type = 'при':U then 'рас':U else 'при':U),
                  input buf_wth-doc.auto-fill,
                  input buf_wth-doc.exter_,
                  input buf_wth-doc.inter_,
                  input buf_wth-doc.doc-code,
                  input 'док.МЦ':U,
                  input yes,
                  input 0,
                  input 0,
                  input buf_wth-doc.PS,
                  input 'накл':U,
                  input no ,
                  input v-ext-type ) no-error .
end.
else do:
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  buf_wth-doc.cli-type
  ,input  buf_wth-doc.cli-code
  ,output v-today
  )  .
  assign f-date = v-today.
  run gbl/factdate.p (
                     INPUT        buf_wth-doc.cli-type
                    ,INPUT        buf_wth-doc.cli-code
                    ,INPUT-OUTPUT f-date
                    ,INPUT-OUTPUT f-time
                    ,INPUT-OUTPUT s-date
                    ,INPUT-OUTPUT s-num
                    ,INPUT-OUTPUT s-name
                    ,INPUT        YES
                      ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
    return error return-value.
  END.
  if  buf_wth-doc.ext-doc-type = 'ep':U then v-ext-type = 'ip':U.
  else if  buf_wth-doc.ext-doc-type = 'ip':U  then v-ext-type = 'rp':U.
  else if  buf_wth-doc.ext-doc-type = 'ef':U then v-ext-type = 'ff':U.
  else if  buf_wth-doc.ext-doc-type = 'ff':U then v-ext-type = 'rf':U.
  else if  buf_wth-doc.ext-doc-type = 'ii':U then v-ext-type = 'rj':U.
  else if  buf_wth-doc.ext-doc-type = 'ei':U then v-ext-type = 'ii':U.
  if buf_wth-doc.doc-type = 'рас':U     then v-doc-code = replace(buf_wth-doc.doc-code, "-", "=").
  else if buf_wth-doc.doc-type = 'при':U then v-doc-code = replace(buf_wth-doc.doc-code, "=", "*").
  run str/wth-inc1.p ( input yes,
                  input-output vardoc-rec,
                  input 'ДОБАВЛЕНИЕ':U,
                  input v-doc-code,
                  input buf_wth-doc.host-code,
                  input buf_wth-doc.cli-type,
                  input buf_wth-doc.cli-code,
                  input buf_wth-doc.obj-type,
                  input buf_wth-doc.obj-code,
                  input buf_wth-doc.doc-date,
                  input f-date,
                  input s-date,
                  input s-num,
                  input s-name,
                  input buf_wth-doc.operator,
                  input buf_wth-doc.deliver,
                  input buf_wth-doc.receiver,
                  input (if buf_wth-doc.doc-type = 'при':U then 'возврат':U else 'при':U),
                  input buf_wth-doc.auto-fill,
                  input buf_wth-doc.exter_,
                  input buf_wth-doc.inter_,
                  input buf_wth-doc.doc-code,
                  input 'док.МЦ':U,
                  input yes,
                  input 0,
                  input 0,
                  input buf_wth-doc.PS,
                  input 'накл':U,
                  input no,
                  input v-ext-type) no-error .
end.
  if error-status:error then do:
    undo _main, return error return-value + chr(10) + error-status:get-message(1) .
  end.
  FIND FIRST buf_out_wth-doc where
            recid(buf_out_wth-doc) = vardoc-rec No-ERROR.
  if not avail buf_out_wth-doc then do:
    undo _main, return error.
  end.
  for each buf_wth-line No-LOCK WHERE
          buf_wth-line.doc-code = buf_wth-doc.doc-code:
    for each tt-par-dtl:
      delete tt-par-dtl.
    end.
    is-parts = no.
    is-dtl   = no.
    for each buf_wth-dtl no-lock where
            buf_wth-dtl.doc-code = buf_wth-doc.doc-code AND
            buf_wth-dtl.wth-code = buf_wth-line.wth-code AND
            buf_wth-dtl.w-p-code = buf_wth-line.w-p-code
            , first buf_wth-par no-lock where
                    buf_wth-par.wth-code = buf_wth-dtl.wth-code
                and buf_wth-par.par-code = buf_wth-dtl.par-code
                   :
      for each buf_wth-parts no-lock where
        buf_wth-parts.out-code = buf_wth-line.doc-code and
        buf_wth-parts.wth-code = buf_wth-line.wth-code and
        buf_wth-parts.w-p-code = buf_wth-line.w-p-code  and
        buf_wth-parts.par-code = buf_wth-dtl.par-code
        :
        if buf_out_wth-doc.doc-type = 'возврат':U
          and buf_wth-parts.fact-rangeFrom = buf_wth-parts.doc-rangeFrom
          and buf_wth-parts.fact-rangeTo = buf_wth-parts.doc-rangeTo
          and buf_wth-parts.stts = 0
        then next.
        if (buf_out_wth-doc.doc-type = 'возврат':U and (buf_wth-parts.doc-rangeFrom <> buf_wth-parts.fact-rangeFrom  or buf_wth-parts.stts = 1))
          or buf_out_wth-doc.doc-type <> 'возврат':U then do:
             run str/wthpartp.p (  'ДОБАВЛЕНИЕ':U,
                       buf_out_wth-doc.obj-type    ,
                       buf_out_wth-doc.obj-code    ,
                       buf_wth-line.out-code       ,
                       buf_wth-parts.wth-code      ,
                       buf_wth-parts.par-code      ,
                       buf_wth-parts.in-code       ,
                       buf_out_wth-doc.doc-code ,
                       buf_wth-parts.ser-code      ,
                       buf_wth-parts.db-num        ,
                       buf_wth-parts.doc-rangeFrom,
                       ( if buf_wth-doc.doc-type = 'возврат':U and buf_wth-parts.stts = 0 then buf_wth-parts.fact-rangeFrom - 1 else buf_wth-parts.fact-RangeTo ) ,
                       buf_wth-parts.doc-rangeFrom,
                       ( if buf_wth-doc.doc-type = 'возврат':U and buf_wth-parts.stts = 0 then buf_wth-parts.fact-rangeFrom - 1 else buf_wth-parts.fact-RangeTo ) ,
                       buf_out_wth-doc.host-code     ,
                       buf_out_wth-doc.contract-code     ,
                       buf_wth-parts.price-rubl   ,
                       buf_wth-parts.price-base   ,
                       buf_wth-parts.supp-type    ,
                       buf_wth-parts.supp-code    ,
                       buf_wth-parts.in-obj-type    ,
                       buf_wth-parts.in-obj-code    ,
                       buf_out_wth-doc.ext-doc-type     ,
                       buf_wth-parts.gds-code    ,
                       0,
                       buf_wth-parts.beg-dt     ,
                       buf_wth-parts.end-dt     ,
                       buf_wth-parts.vat-pc     ,
                       buf_wth-parts.cli-code    ,
                       buf_wth-parts.cli-type    ,
                       buf_wth-parts.out-obj-code    ,
                       buf_wth-parts.out-obj-type    ,
                       buf_wth-parts.sale-obj-code   ,
                       buf_wth-parts.sale-obj-type   ,
                       buf_out_wth-doc.doc-code ,
                       yes,
                       buf_out_wth-doc.doc-type ,
                      input-output varparts-rec
                    ) no-error.
          if error-status:error then do:
            undo _main, return error "Ошибка при создании партии. " + return-value + chr(10) + error-status:get-message(1).
          end.
        end.
        else if (buf_out_wth-doc.doc-type = 'возврат':U and buf_wth-parts.doc-rangeTo <> buf_wth-parts.fact-rangeTo)
        then do:
             run str/wthpartp.p (  'ДОБАВЛЕНИЕ':U ,
                       buf_out_wth-doc.obj-type      ,
                       buf_out_wth-doc.obj-code      ,
                       buf_wth-line.out-code       ,
                       buf_wth-parts.wth-code      ,
                       buf_wth-parts.par-code      ,
                       buf_wth-parts.in-code        ,
                       buf_out_wth-doc.doc-code ,
                       buf_wth-parts.ser-code      ,
                       buf_wth-parts.db-num        ,
                       buf_wth-parts.fact-rangeTo + 1,
                       buf_wth-parts.doc-rangeTo  ,
                       buf_wth-parts.fact-rangeTo + 1,
                       buf_wth-parts.doc-rangeTo  ,
                       buf_out_wth-doc.host-code     ,
                       buf_out_wth-doc.contract-code     ,
                       buf_wth-parts.price-rubl    ,
                       buf_wth-parts.price-base    ,
                       buf_wth-parts.supp-type    ,
                       buf_wth-parts.supp-code    ,
                       buf_wth-parts.in-obj-type    ,
                       buf_wth-parts.in-obj-code    ,
                       buf_out_wth-doc.ext-doc-type     ,
                       buf_wth-parts.gds-code    ,
                       0,
                       buf_wth-parts.beg-dt   ,
                       buf_wth-parts.end-dt   ,
                       buf_wth-parts.vat-pc   ,
                       buf_wth-parts.cli-code  ,
                       buf_wth-parts.cli-type  ,
                       buf_wth-parts.out-obj-code  ,
                       buf_wth-parts.out-obj-type  ,
                       buf_wth-parts.sale-obj-code ,
                       buf_wth-parts.sale-obj-type ,
                       buf_out_wth-doc.doc-code ,
                       yes,
                       buf_out_wth-doc.doc-type ,
                      input-output varparts-rec
                    ) no-error.
          if error-status:error then do:
            undo _main, return error return-value + chr(10) + error-status:get-message(1).
          end.
        end.
        is-parts = yes.
      end.
      create tt-par-dtl.
      buffer-copy buf_wth-dtl to tt-par-dtl.
      assign
          tt-par-dtl.doc-code = buf_out_wth-doc.doc-code
          tt-par-dtl.w-p-code = buf_wth-line.out-code
          tt-par-dtl.par-rate = buf_wth-par.par-rate
      .
      if is-parts then do:
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
tt-par-dtl.q-ty-doc  = 0
tt-par-dtl.q-ty-fact = 0
tt-par-dtl.doc-sum   = 0
tt-par-dtl.fact-sum  = 0
tt-par-dtl.sum-gds-rubl = 0
tt-par-dtl.sum-gds-base = 0
.
for each buf_wth-parts no-lock where buf_wth-parts.w-p-code = tt-par-dtl.w-p-code
                       and buf_wth-parts.wth-code = tt-par-dtl.wth-code
                       and buf_wth-parts.par-code = tt-par-dtl.par-code
                       and buf_wth-parts.out-code = tt-par-dtl.doc-code
                       and buf_wth-parts.stts = 0 :
   assign
  tt-par-dtl.q-ty-doc     =  tt-par-dtl.q-ty-doc  + buf_wth-parts.qnty-doc
  tt-par-dtl.q-ty-fact    =  tt-par-dtl.q-ty-fact + buf_wth-parts.fact-qnty
  tt-par-dtl.sum-gds-rubl =  tt-par-dtl.sum-gds-rubl + buf_wth-parts.price-rubl * buf_wth-parts.fact-qnty
  tt-par-dtl.sum-gds-base =  tt-par-dtl.sum-gds-base + buf_wth-parts.price-base * buf_wth-parts.fact-qnty
  no-error
  .
end.
assign
  tt-par-dtl.doc-sum     =  tt-par-dtl.q-ty-doc  * tt-par-dtl.par-rate
  tt-par-dtl.fact-sum    =  tt-par-dtl.q-ty-fact * tt-par-dtl.par-rate
  no-error
  .
      end.
      else if buf_out_wth-doc.doc-type = 'возврат':U then do:
        tt-par-dtl.doc-sum = tt-par-dtl.doc-sum - tt-par-dtl.fact-sum.
        tt-par-dtl.fact-sum = tt-par-dtl.doc-sum.
      end.
      is-dtl = yes.
    end.
    create tt-wth-line.
    buffer-copy buf_wth-line to tt-wth-line.
    assign
      tt-wth-line.doc-code = buf_out_wth-doc.doc-code
      tt-wth-line.w-p-code = buf_wth-line.out-code
      tt-wth-line.out-code = buf_wth-line.w-p-code
      .
      if is-dtl then do:
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
tt-wth-line.doc-sum   = 0
tt-wth-line.fact-sum  = 0
tt-wth-line.sum-gds-rubl = 0
tt-wth-line.sum-gds-base = 0
tt-wth-line.price-rubl   = 0
tt-wth-line.price-base   = 0.
for each tt-par-dtl no-lock where tt-par-dtl.w-p-code = tt-wth-line.w-p-code
                       and tt-par-dtl.wth-code = tt-wth-line.wth-code
                       and tt-par-dtl.doc-code = tt-wth-line.doc-code
                       :
  assign
  tt-wth-line.doc-sum      =  tt-wth-line.doc-sum  + tt-par-dtl.doc-sum
  tt-wth-line.fact-sum     =  tt-wth-line.fact-sum + tt-par-dtl.fact-sum
  tt-wth-line.sum-gds-rubl =  tt-wth-line.sum-gds-rubl + tt-par-dtl.sum-gds-rubl
  tt-wth-line.sum-gds-base =  tt-wth-line.sum-gds-base + tt-par-dtl.sum-gds-base
  .
end.
assign
  tt-wth-line.price-rubl  =  tt-wth-line.sum-gds-rubl / tt-wth-line.fact-sum
  tt-wth-line.price-base  =  tt-wth-line.sum-gds-base / tt-wth-line.fact-sum
  .
      end.
      else if buf_out_wth-doc.doc-type = 'возврат':U then do:
        tt-wth-line.doc-sum = tt-wth-line.doc-sum - tt-wth-line.fact-sum.
        tt-wth-line.fact-sum = tt-wth-line.doc-sum  .
      end.
     run str/wth-lnc1.p (input-output varline-rec,
                  input  'ДОБАВЛЕНИЕ':U,
                  no,
                  buf_out_wth-doc.doc-code,
                  buf_wth-line.wth-code,
                  buf_wth-line.out-code,
                  buf_wth-line.w-p-code,
                  tt-wth-line.doc-sum,
                  tt-wth-line.fact-sum,
                  input table tt-par-dtl,
                  no  ,
                  buf_wth-line.ext-doc-type,
                  input tt-wth-line.sum-gds-rubl,
                  input tt-wth-line.sum-gds-base
                  ) no-error .
    if error-status:error then dO:
      undo _main, return error 'Ошибка при создании линии  ' + return-value + chr(10) + error-status:get-message(1) .
    end.
  END.
end.
