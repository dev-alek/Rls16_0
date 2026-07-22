block-level on error undo, throw.
define input parameter    p-mode            AS   character NO-UNDO.
define input PARAMETER    p-obj-type        LIKE ub.wth-parts.obj-type.
define input PARAMETER    p-obj-code        LIKE ub.wth-parts.obj-code.
define input parameter    p-w-p-code        LIKE ub.wth-parts.w-p-code.
define input parameter    p-wth-code        LIKE ub.wth-parts.wth-code.
define input parameter    p-par-code        LIKE ub.wth-parts.par-code.
define input parameter    p-in-code         LIKE ub.wth-parts.in-code .
define input parameter    p-out-code        LIKE ub.wth-parts.out-code.
define input parameter    p-ser-code        LIKE ub.wth-parts.ser-code.
define input parameter    p-db-num          LIKE ub.wth-parts.db-num  .
define input parameter    p-Fact-RangeFrom  LIKE ub.wth-parts.Fact-RangeFrom.
define input parameter    p-Fact-RangeTo    LIKE ub.wth-parts.Fact-RangeTo.
define input parameter    p-Doc-RangeFrom   LIKE ub.wth-parts.doc-RangeFrom.
define input parameter    p-Doc-RangeTo     LIKE ub.wth-parts.doc-RangeTo.
define input parameter    p-host-code       LIKE ub.wth-parts.host-code  .
define input parameter    p-contract-code   LIKE ub.wth-parts.contract-code.
define input parameter    p-price-rubl      LIKE ub.wth-parts.price-rubl .
define input parameter    p-price-base      LIKE ub.wth-parts.price-base .
define input parameter    p-supp-type       LIKE ub.wth-parts.supp-type  .
define input parameter    p-supp-code       LIKE ub.wth-parts.supp-code  .
define input parameter    p-in-obj-type     LIKE ub.wth-parts.in-obj-type.
define input parameter    p-in-obj-code     LIKE ub.wth-parts.in-obj-code.
define input parameter    p-ext-doc-type    LIKE ub.wth-parts.ext-doc-type.
define input parameter    p-gds-code        LIKE ub.wth-parts.gds-code   .
define input parameter    p-stts            LIKE ub.wth-parts.stts       .
define input parameter    p-beg-dt          LIKE ub.wth-parts.beg-dt     .
define input parameter    p-end-dt          LIKE ub.wth-parts.end-dt     .
define input parameter    p-vat-pc          LIKE ub.wth-parts.vat-pc     .
define input parameter    p-cli-code        LIKE ub.wth-parts.cli-code   .
define input parameter    p-cli-type        LIKE ub.wth-parts.cli-type   .
define input parameter    p-out-obj-code    LIKE ub.wth-parts.out-obj-code.
define input parameter    p-out-obj-type    LIKE ub.wth-parts.out-obj-type.
define input parameter    p-sale-obj-code   LIKE ub.wth-parts.sale-obj-code.
define input parameter    p-sale-obj-type   LIKE ub.wth-parts.sale-obj-type.
define input parameter    p-doc-code        LIKE ub.wth-parts.doc-code.
define input parameter    p-silent          as logical   no-undo .
define input parameter    p-type            LIKE ub.wth-parts.type.
define input-output parameter p-rec         as recid     no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: wthpartp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/wthpartp.p $":U .
define variable vss-description as character no-undo init "Сохранение партии МЦ".
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
DEFINE BUFFER buf_wth-parts FOR ub.wth-parts.
define buffer buf_wealth    for ub.wealth.
define buffer buf_wth-par   for ub.wth-par.
define buffer buf_wth-doc   for ub.wth-doc.
define buffer buf_wth-gds   for ub.wth-gds.
define buffer b_wth-parts   for ub.wth-parts.
define variable v-mess    as character    no-undo.
if p-mode  = 'ДОБАВЛЕНИЕ':U then p-rec = ?.
  if p-wth-code > 0 then.
  else do:
      v-mess =  "Не указан код МЦ" .
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'wth-code':U).
  end.
  if p-doc-RangeTo - p-doc-RangeFrom + 1 > 0 THEN.
  else do:
        v-mess =  "Некорректно указаны фактические границы диапазона" .
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'doc-RangeFrom':U).
  end.
  if p-fact-RangeTo - p-fact-RangeFrom + 1 > 0 THEN.
  else do:
        v-mess =  "Некорректно указаны границы диапазона" .
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'fact-RangeFrom':U).
  end.
  if p-doc-rangeFrom > p-fact-rangeFrom
      or p-doc-rangeTo   < p-fact-rangeTo  then do:
    v-mess =  substitute('Нельзя увеличивать границы диапазона.&1Диапазон партии &2-&3.',chr(10),p-doc-rangeFrom,p-doc-rangeTo).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'fact-RangeFrom':U).
  end.
  if p-ser-code > 0 then.
  else do:
          v-mess =  "Не указана серия МЦ" .
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'ser-code':U).
  end.
  find first buf_wealth no-lock where
          buf_wealth.wth-code = p-wth-code no-error .
  if not available buf_wealth then do:
        v-mess = substitute("Не найдена МЦ &1!",p-wth-code).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'wth-code':U).
  end.
  if p-par-code > 0 then.
  else do:
          v-mess =  "Не указан код номинала МЦ" .
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'par-code':U).
  end.
  find first buf_wth-par no-lock where
          buf_wth-par.par-code = p-par-code
          and buf_wth-par.wth-code = p-wth-code no-error .
  if not available buf_wth-par then do:
    v-mess =   substitute("Не найден номинал МЦ с кодом &1 и кодом МЦ &2!",p-par-code,p-wth-code).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'par-code':U).
  end.
  IF LOOKUP(p-out-code, 'free-zone,out-zone,cli-zone,фальшивый,put-zone':u) = 0 THEN DO:
      find first buf_wth-doc no-lock where
              buf_wth-doc.doc-code = p-out-code no-error .
      if not available buf_wth-doc then do:
        v-mess =  substitute("Не найден Документ МЦ с кодом &1 !",p-out-code).
        run err-mess in this-procedure ( input-output v-mess).
        return error (if p-silent = yes then v-mess else 'out-code':U).
      end.
  END.
  else do:
      find first buf_wth-doc no-lock where
              buf_wth-doc.doc-code = p-doc-code no-error .
  end.
  find first buf_wth-gds no-lock where
          buf_wth-gds.wth-code = p-wth-code
      and buf_wth-gds.gds-code = p-gds-code no-error .
  if not available buf_wth-gds then do:
        v-mess =  substitute("Не найдена Связка товара &2 c МЦ с кодом &1 !",p-wth-code,p-gds-code).
        run err-mess in this-procedure ( input-output v-mess).
        return error (if p-silent = yes then v-mess else 'gds-code':U).
  end.
  if p-beg-dt <> ? and p-end-dt <> ? and p-beg-dt > p-end-dt then do:
        v-mess =  substitute('Неверно указан срок действия партии: &1 - &2!',p-beg-dt,p-end-dt).
        run err-mess in this-procedure ( input-output v-mess).
        return error (if p-silent = yes then v-mess else 'beg-dt':U).
  end.
 if p-mode = 'ИЗМЕНЕНИЕ':U
 then do:
    FIND FIRST buf_wth-parts no-LOCK WHERE recid(buf_wth-parts) = p-rec  no-error.
    if not available buf_wth-parts then return error substitute('Неверно указаны параметры. Не найдена партия с recid &1',p-rec).
    if buf_wth-parts.ser-code = p-ser-code and buf_wth-parts.db-num = p-db-num then.
    else do:
            v-mess =  substitute("Нельзя изменить код Серии или № БД в партии МЦ &1" +
                               "старый код серии - &2 № БД - &3"
                               ,chr(10)
                               , buf_wth-parts.ser-code
                               , buf_wth-parts.db-num).
.
        run err-mess in this-procedure ( input-output v-mess).
        return error (if p-silent = yes then v-mess else 'gds-code':U).
    end.
 end.
 find first b_wth-parts no-lock where
                 b_wth-parts.obj-type = p-obj-type
             and b_wth-parts.obj-code = p-obj-code
             and b_wth-parts.w-p-code = p-w-p-code
             and b_wth-parts.wth-code = p-wth-code
             and b_wth-parts.par-code = p-par-code
             and ((buf_wth-doc.ext-doc-type <> 'ie':U and b_wth-parts.in-code  = p-in-code)
                  or   buf_wth-doc.ext-doc-type = 'ie':U)
             and b_wth-parts.out-code = p-out-code
             and b_wth-parts.ser-code = p-ser-code
             and b_wth-parts.db-num   = p-db-num
             and ((b_wth-parts.fact-rangeFrom <= p-fact-rangeFrom
                     and b_wth-parts.fact-rangeTo >= p-fact-rangeFrom )
                  or (b_wth-parts.fact-rangeFrom <= p-fact-rangeTo
                      and b_wth-parts.fact-rangeTo >= p-fact-rangeTo )
                  or (b_wth-parts.fact-rangeFrom >= p-fact-rangeFrom
                      and b_wth-parts.fact-rangeTo <= p-fact-rangeTo )
                  )
             and recid(b_wth-parts) <> p-rec
             no-error.
   if available b_wth-parts then do:
    if g#news  then  do:
    p-in-code = p-in-code + 'фальшивый':U.
    end.
    else do:
        v-mess =  substitute('Существует партия с пересекающимся диапазоном. &1 Указанный диапазон: &2 - &3&1Диапазон существующей партии: &4 - &5&1
                             документ порождения - &6 &1
                             документ/зона - &7' ,
                            chr(10)
                            ,p-fact-rangeFrom
                            ,p-fact-rangeTo
                            ,b_wth-parts.fact-rangeFrom
                            ,b_wth-parts.fact-rangeTo
                            ,p-in-code
                            ,p-out-code) .
        run err-mess in this-procedure ( input-output v-mess).
        return error (if p-silent = yes then v-mess else 'fact-rangeFrom':U).
    end.
   end.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
IF p-mode = 'ДОБАВЛЕНИЕ':U THEN DO:
    create buf_wth-parts.
END.
ELSE DO:
    FIND FIRST buf_wth-parts WHERE recid(buf_wth-parts) = p-rec EXCLUSIVE-LOCK.
END.
    assign
        buf_wth-parts.obj-type        =   p-obj-type
        buf_wth-parts.obj-code        =   p-obj-code
        buf_wth-parts.w-p-code        =   p-w-p-code
        buf_wth-parts.wth-code        =   p-wth-code
        buf_wth-parts.par-code        =   p-par-code
        buf_wth-parts.in-code         =   p-in-code
        buf_wth-parts.out-code        =   p-out-code
        buf_wth-parts.ser-code        =   p-ser-code
        buf_wth-parts.db-num          =   p-db-num
        buf_wth-parts.Fact-RangeFrom  =   p-Fact-RangeFrom
        buf_wth-parts.Fact-RangeTo    =   p-Fact-RangeTo
        buf_wth-parts.doc-RangeFrom   =   p-Doc-RangeFrom
        buf_wth-parts.doc-RangeTo     =   p-Doc-RangeTo
        buf_wth-parts.host-code       =   p-host-code
        buf_wth-parts.contract-code   =   p-contract-code
        buf_wth-parts.price-rubl      =   IF p-price-rubl = ? THEN 0 ELSE p-price-rubl
        buf_wth-parts.price-base      =   IF p-price-base = ? THEN 0 ELSE p-price-base
        buf_wth-parts.supp-type       =   p-supp-type
        buf_wth-parts.supp-code       =   p-supp-code
        buf_wth-parts.in-obj-type     =   p-in-obj-type
        buf_wth-parts.in-obj-code     =   p-in-obj-code
        buf_wth-parts.ext-doc-type    =   p-ext-doc-type
        buf_wth-parts.gds-code        =   p-gds-code
        buf_wth-parts.stts            =   p-stts
        buf_wth-parts.beg-dt          =   p-beg-dt
        buf_wth-parts.end-dt          =   p-end-dt
        buf_wth-parts.vat-pc          =   p-vat-pc
        buf_wth-parts.cli-code        =   p-cli-code
        buf_wth-parts.cli-type        =   p-cli-type
        buf_wth-parts.out-obj-code    =   p-out-obj-code
        buf_wth-parts.out-obj-type    =   p-out-obj-type
        buf_wth-parts.sale-obj-code   =   p-sale-obj-code
        buf_wth-parts.sale-obj-type   =   p-sale-obj-type
        buf_wth-parts.doc-code        =   p-doc-code
        buf_wth-parts.type            =   p-type
       .
        if available buf_wth-doc then do:
        assign
          buf_wth-parts.fact-date       =   buf_wth-doc.fact-date
          buf_wth-parts.fact-num        =   buf_wth-doc.fact-num
          buf_wth-parts.fact-order      =   buf_wth-doc.fact-order
          buf_wth-parts.shift-num       =   buf_wth-doc.shift-num
          buf_wth-parts.shift-date      =   buf_wth-doc.shift-date
          buf_wth-parts.ext-doc-type    =   buf_wth-doc.ext-doc-type
        .
        IF LOOKUP(p-out-code, 'free-zone,out-zone,cli-zone,фальшивый,put-zone':u) = 0 THEN
        case buf_wth-doc.ext-doc-type:
          when 'ie':U then assign
                                    buf_wth-parts.in-obj-type     =   buf_wth-doc.obj-type
                                    buf_wth-parts.in-obj-code     =   buf_wth-doc.obj-code
                                    buf_wth-parts.supp-type       =   buf_wth-doc.cli-type
                                    buf_wth-parts.supp-code       =   buf_wth-doc.cli-code
                                    buf_wth-parts.in-code         =   buf_wth-doc.doc-code
                                           .
          when 'ee':U then assign
                  buf_wth-parts.cli-code        =   buf_wth-doc.cli-code
                  buf_wth-parts.cli-type        =   buf_wth-doc.cli-type
                  buf_wth-parts.sale-obj-code   =   buf_wth-doc.obj-code
                  buf_wth-parts.sale-obj-type   =   buf_wth-doc.obj-type
                 .
          when 'pc':U or when 'pz':U then assign
                  buf_wth-parts.out-obj-code   =   buf_wth-doc.obj-code
                  buf_wth-parts.out-obj-type   =   buf_wth-doc.obj-type
                 .
          when 'ps':U then assign
                  buf_wth-parts.out-obj-code   =   buf_wth-doc.cli-code
                  buf_wth-parts.out-obj-type   =   buf_wth-doc.cli-type
                 .
          when 'xc':U  then do:
             if buf_wth-parts.type = 'при':U then assign
                  buf_wth-parts.out-obj-code   =   buf_wth-doc.obj-code
                  buf_wth-parts.out-obj-type   =   buf_wth-doc.obj-type
                 .
             else assign
                  buf_wth-parts.cli-code        =   buf_wth-doc.cli-code
                  buf_wth-parts.cli-type        =   buf_wth-doc.cli-type
                  buf_wth-parts.sale-obj-code   =   buf_wth-doc.obj-code
                  buf_wth-parts.sale-obj-type   =   buf_wth-doc.obj-type
                 .
          end.
        end case.
      end.
      case buf_wth-parts.out-code:
        when 'free-zone':U then assign
                  buf_wth-parts.cli-code        =   0
                  buf_wth-parts.cli-type        =   '':U
                  buf_wth-parts.sale-obj-code   =   0
                  buf_wth-parts.sale-obj-type   =   '':U
                  buf_wth-parts.out-obj-code    =   0
                  buf_wth-parts.out-obj-type    =   '':U
                  buf_wth-parts.beg-dt          = ?
                  buf_wth-parts.end-dt          = ?
                  buf_wth-parts.price-rubl      = 0
                  buf_wth-parts.price-base      = 0
                  .
        when 'cli-zone':U then assign
                  buf_wth-parts.out-obj-code    =   0
                  buf_wth-parts.out-obj-type    =   '':U
                  buf_wth-parts.obj-code        = buf_wth-parts.cli-code
                  buf_wth-parts.obj-type        = buf_wth-parts.cli-type
                  buf_wth-parts.w-p-code        = 0
           .
      end case.
      find first b_wth-parts no-lock where
                 b_wth-parts.obj-type = buf_wth-parts.obj-type
             and b_wth-parts.obj-code = buf_wth-parts.obj-code
             and b_wth-parts.w-p-code = buf_wth-parts.w-p-code
             and b_wth-parts.wth-code = buf_wth-parts.wth-code
             and b_wth-parts.par-code = buf_wth-parts.par-code
             and b_wth-parts.in-code  = buf_wth-parts.in-code
             and b_wth-parts.out-code = buf_wth-parts.out-code
             and b_wth-parts.ser-code = buf_wth-parts.ser-code
             and b_wth-parts.db-num   = buf_wth-parts.db-num
             and b_wth-parts.stts   = buf_wth-parts.stts
             and b_wth-parts.fact-rangeTo = buf_wth-parts.fact-rangeFrom - 1
              and b_wth-parts.doc-code = buf_wth-parts.doc-code
                                    no-error.
      if available b_wth-parts then do:
        find current b_wth-parts exclusive-lock.
        assign
        buf_wth-parts.fact-rangeFrom =  b_wth-parts.fact-rangeFrom
        buf_wth-parts.doc-rangeFrom =  b_wth-parts.doc-rangeFrom
        .
        delete b_wth-parts no-error.
        if error-status:error then undo, return error return-value.
      end.
      find first b_wth-parts exclusive-lock where
                 b_wth-parts.obj-type = buf_wth-parts.obj-type
             and b_wth-parts.obj-code = buf_wth-parts.obj-code
             and b_wth-parts.w-p-code = buf_wth-parts.w-p-code
             and b_wth-parts.wth-code = buf_wth-parts.wth-code
             and b_wth-parts.par-code = buf_wth-parts.par-code
             and b_wth-parts.in-code  = buf_wth-parts.in-code
             and b_wth-parts.out-code = buf_wth-parts.out-code
             and b_wth-parts.doc-code = buf_wth-parts.doc-code
             and b_wth-parts.ser-code = buf_wth-parts.ser-code
             and b_wth-parts.db-num   = buf_wth-parts.db-num
             and b_wth-parts.stts   = buf_wth-parts.stts
             and b_wth-parts.fact-rangeFrom = buf_wth-parts.fact-rangeTo + 1
             and b_wth-parts.fact-rangeTo >= buf_wth-parts.fact-rangeTo + 1
             no-error.
      if available b_wth-parts then do:
      assign
        buf_wth-parts.fact-rangeTo =  b_wth-parts.fact-rangeTo
        buf_wth-parts.doc-rangeTo =  b_wth-parts.doc-rangeTo
        .
        delete b_wth-parts no-error.
        if error-status:error then undo, return error return-value.
      end.
    assign
     buf_wth-parts.fact-qnty       =  buf_wth-parts.fact-rangeTo - buf_wth-parts.fact-RangeFrom + 1
     buf_wth-parts.qnty-doc        =  buf_wth-parts.doc-rangeTo  - buf_wth-parts.doc-RangeFrom  + 1
     .
    p-rec = RECID (buf_wth-parts).
end.
PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Партия МЦ: Код серии &1-&2 Код МЦ &4 Диапазон &5 - &6&3&7"
                         , p-ser-code
                         , p-db-num
                         , chr(10)
                         , p-wth-code
                         , p-Fact-RangeFrom
                         , p-Fact-RangeTo
                         , p-mess)
      .
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.
