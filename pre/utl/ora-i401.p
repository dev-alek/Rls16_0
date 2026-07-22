block-level on error undo, throw.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp_ord-doc no-undo
field line-num as integer
field doc-code as character
field doc-date as date
field ext-doc-type as character
field cli-type as character
field cli-code as integer
field obj-type as character
field obj-code as integer
field wrkr  as integer
field agnt  as integer
field boss  as integer
field creid as character
field ps    as character
field host-code     as integer
field contract-code as integer
field pay-code   as integer
field exch-code  as integer
field exch-rate  as decimal
field exch-scale as integer
field corr-doc-code as character
field status_       as character
field ship-date as date
index pi
line-num
doc-code
.
define temp-table temp_ord-line no-undo
field line-num as integer
field doc-code    as character
field artic       as character
field prod-type   as character
field prod-code   as integer
field gds-code    as integer
field fact-qnty   as decimal
field price-rubl  as decimal
field price-cli   as decimal
field vat-pc      as decimal
index pi
doc-code
line-num
gds-code
.
define input  parameter parparentproc as widget-handle no-undo .
define input  parameter p-log-handle  as handle no-undo .
define input  PARAMETER TABLE FOR  temp_ord-doc.
define input  PARAMETER TABLE FOR  temp_ord-line.
define output parameter p-ok-doc as integer   no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ora-i401.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/ora-i401.p $":U .
define variable vss-description as character no-undo init "Импорт Заказа из временной таблицы".
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure proc-ord-code :
define input  parameter  p-type as character no-undo .
define input  parameter  v-cntxt-db-num   as integer   no-undo .
define input  parameter  v-cntxt-obj-type as character no-undo .
define input  parameter  v-cntxt-obj-code as integer   no-undo .
define input  parameter  p-i-doc    as character no-undo .
define output parameter  p-ord-doc  as character no-undo .
define variable          v-idop     as character no-undo .
  do
  on error undo, return error return-value
  :
case p-type :
    when "main-no-ver" then do:
      if  (v-cntxt-db-num <> 0) then
        p-ord-doc = trim (string (next-value (s-ord-doc, ub), ">>>>>>>>>9")) + "-" + trim (string (v-cntxt-obj-code, ">>>>9")) + substring (v-cntxt-obj-type, (if g#language = "RUS" then 1 else 2), 1).
      else
        p-ord-doc = trim (string (next-value (s-ord-doc, ub), ">>>>>>>>>9")) + "-".
    end.
    when "main" then do:
          do while true:
          if  (v-cntxt-db-num <> 0) then
            p-ord-doc = trim (string (next-value (s-ord-doc, ub), ">>>>>>>>>9")) + "-" + trim (string (v-cntxt-obj-code, ">>>>9")) + substring (v-cntxt-obj-type, (if g#language = "RUS" then 1 else 2), 1).
          else
            p-ord-doc = trim (string (next-value (s-ord-doc, ub), ">>>>>>>>>9")) + "-".
          if not can-find (ub.ord-doc where ub.ord-doc.doc-code = p-ord-doc no-lock) then leave.
          End.
    end.
    when "chip" then do:
      assign
        v-idop = p-i-doc .
      do while true :
        if index (v-idop , ".") = 0 then
          v-idop  = replace (v-idop , "-", "-1.").
        else
          v-idop  =
          substring (v-idop , 1, index (v-idop, "-")) +
          string (integer (substring (v-idop, index (v-idop, "-") + 1, index (v-idop, ".") - index (v-idop, "-") - 1)) + 1) +
          substring (v-idop, index (v-idop, ".")).
        if not can-find (ub.ord-doc where ub.ord-doc.doc-code = v-idop no-lock) then leave.
      end.
      assign
        p-ord-doc = v-idop.
    end.
end case.
  end.
end procedure.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable to-day       as date no-undo .
define variable  ora-icli_ver-stts-client as logical   no-undo  init true .
procedure who-cli-ora :
define input  parameter p-cli-code-ora as integer   no-undo .
define output parameter p-cli-type as character no-undo .
define output parameter p-cli-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
  if length (string(p-cli-code-ora))  <> 9 then do:
     return error substitute ("Не верный формат кода КОНТРАГЕНТА: &1" , p-cli-code-ora ) .
  end.
  if string(p-cli-code-ora) begins "1" or
     string(p-cli-code-ora) begins "2" or
     string(p-cli-code-ora) begins "4" then do:
      p-cli-type = 'орг':U .
      p-cli-code = p-cli-code-ora  .
  end.
  else do:
    if string(p-cli-code-ora) begins "3" then do:
      p-cli-type = 'чел':U .
      p-cli-code = p-cli-code-ora  .
    end.
    else do:
       return error substitute ("Не верный формат кода КОНТРАГЕНТА: &1 ( первый код )" , p-cli-code-ora ) .
    end.
  end.
  define buffer buf_clients for ub.clients  .
  find first buf_clients no-lock where
             buf_clients.obj-type = p-cli-type and
             buf_clients.obj-code = p-cli-code
             no-error .
      if error-status :error then do:
          return error substitute
          ( "Нет такого контрагента: &1 ( &2 &3 )" ,
              p-cli-code-ora ,
              p-cli-type ,
              p-cli-code ) .
      end.
      if ora-icli_ver-stts-client then do:
          if buf_clients.stts > 0 then do:
              return error substitute
              ( "Контрагент: &1 ( &2 &3 ) СТАТУС неактивный !!!" ,
                  p-cli-code-ora ,
                  p-cli-type ,
                  p-cli-code ) .
          end.
      end.
  end.
end procedure.
procedure ora-ver-goods :
define input  parameter p-gds-code as integer   no-undo .
define buffer buf_goods for ub.goods  .
define variable my-message as character no-undo .
  do
  on error undo, return error return-value
  :
        find first buf_goods no-lock where
                   buf_goods.gds-code = p-gds-code no-error .
            if error-status :error then do:
                my-message = substitute("Нет товара с кодом &1" ,  p-gds-code) .
                undo, return error my-message.
            end.
          if buf_goods.stts > 0 then do:
            assign
              my-message =  substitute(" Товара &1 УДАЛЕН" , buf_goods.gds-code  ) .
              undo, return error my-message.
          end.
  end.
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable v-base-rate  as decimal   no-undo .
define variable v-base-scale as decimal   no-undo .
define variable v-out-pay    as integer   no-undo .
define buffer   buf_clients  for ub.clients.
define buffer   buf_goods    for ub.goods  .
define variable v-i-doc      as character no-undo .
define variable v-doc-code   as character no-undo .
define variable k as integer   no-undo .
define variable v-end-message as character no-undo .
define variable v-host-code as integer   no-undo .
define buffer buf_contract for ub.contract  .
define buffer bufo_clients for ub.clients  .
define variable v-specif as logical   no-undo .
define variable v-typevat as character no-undo .
define variable vv-kol      as decimal   no-undo .
define variable vv-kolcli   as decimal   no-undo .
define variable vv-sumkolr  as decimal   no-undo .
define variable vv-sumkolv  as decimal   no-undo .
define variable vv-sumkolc  as decimal   no-undo .
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   for each  temp_ord-doc :
       for each temp_ord-line where
                temp_ord-line.line-num = temp_ord-doc.line-num :
           if temp_ord-line.doc-code <> temp_ord-doc.doc-code then do:
              assign
                  v-end-message =  substitute("Не верно указан doc-num &1 &2  товар &3" ,
                  temp_ord-line.doc-code ,
                  temp_ord-doc.doc-code ,
                  temp_ord-line.gds-code
                  ).
              run pcall-log-file in p-log-handle (input v-end-message) .
              undo, return error v-end-message.
           end.
       end.
   end.
run get-db-num in parparentproc ( output v-cntxt-db-num ) .
run get-userid in parparentproc ( output v-cntxt-userid ) .
p-ok-doc = 0 .
   _temp-ord-doc:
   for each temp_ord-doc
   :
   k = 0 .
  case temp_ord-doc.status_ :
  when 'N'
  or
  when 'U'
  or
  when 'D' then do:
    if temp_ord-doc.status_ = 'D' then do:
      find first ub.ord-doc exclusive-lock where
                 ub.ord-doc.doc-code =  trim(temp_ord-doc.corr-doc-code) no-error .
      if error-status :error then do:
      v-end-message =  substitute(" Заказ: &1 не найден " ,
                                    temp_ord-doc.corr-doc-code
                                    ).
      run pcall-log-file in p-log-handle (input v-end-message) .
      undo, return error v-end-message.
      end.
      assign
        ub.ord-doc.fact-date  = today
        ub.ord-doc.fact-order = decimal(today)
        ub.ord-doc.status_    = 'отказ':U
        ub.ord-doc.cons-code  = ""
        temp_ord-doc.pay-code = ub.ord-doc.pay-code
        .
      ub.ord-doc.ps = "ОТКАЗ из внешней ситемы " + ub.ord-doc.ps + " №:" + temp_ord-doc.doc-code +
                    " от " + string ( temp_ord-doc.doc-date , "99/99/9999") .
      v-end-message =  substitute(" ОТКАЗ &3&4 Заказ: &1  товаров: &2" ,
                                    temp_ord-doc.doc-code    ,
                                    k ,
                                    temp_ord-doc.obj-type ,
                                    temp_ord-doc.obj-code
                                    ).
      run pcall-log-file in p-log-handle (input v-end-message) .
      next _temp-ord-doc.
  end.
  else do :
     if temp_ord-doc.corr-doc-code <> "" then do:
      find first ub.ord-doc exclusive-lock where
                 ub.ord-doc.doc-code =  trim(temp_ord-doc.corr-doc-code) no-error .
      if error-status :error then do:
      v-end-message =  substitute(" Заказ: &1 не найден " ,
                                    temp_ord-doc.corr-doc-code
                                    ).
      run pcall-log-file in p-log-handle (input v-end-message) .
      undo, return error v-end-message.
      end.
      assign
        ub.ord-doc.fact-date  = today
        ub.ord-doc.fact-order = decimal(today)
        ub.ord-doc.status_    = 'факт':U
        ub.ord-doc.cons-code  = ""
        temp_ord-doc.pay-code = ub.ord-doc.pay-code
        .
      v-end-message = "Закрыт заказом из внешней ситемы  №:" + temp_ord-doc.doc-code +
                    " от " + string ( temp_ord-doc.doc-date , "99/99/9999") .
      ub.ord-doc.ps = v-end-message.
      run pcall-log-file in p-log-handle (input v-end-message) .
    end.
    else do:
      v-end-message = "Заказ от внешней системы  №:" + temp_ord-doc.doc-code +
                    " от " + string ( temp_ord-doc.doc-date , "99/99/9999") + " Пришел без ссылки на заказ ТН." .
      run pcall-log-file in p-log-handle (input v-end-message) .
    end.
  end.
  find first bufo_clients no-lock where
             bufo_clients.obj-type  = temp_ord-doc.obj-type  and
             bufo_clients.obj-code  = temp_ord-doc.obj-code  no-error .
      if error-status :error then do:
              assign
              v-end-message =  substitute(" Не найден объект &1 &2 &3 &4" , temp_ord-doc.obj-type , temp_ord-doc.obj-code , error-status :get-message(1) , return-value )
              .
              run pcall-log-file in p-log-handle (input v-end-message) .
              undo, return error v-end-message.
      end.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  temp_ord-doc.obj-type
  ,input  temp_ord-doc.obj-code
  ,output v-host-code
  ) no-error .
      if error-status :error then do:
        assign
            v-end-message =  substitute("Не верно указан объект &1 &2 " ,
            temp_ord-doc.obj-type ,
            temp_ord-doc.obj-code ).
        run pcall-log-file in p-log-handle (input v-end-message) .
        undo, return error v-end-message.
      end.
      temp_ord-doc.host-code = v-host-code .
    find first buf_contract no-lock where
               buf_contract.contract-code =  temp_ord-doc.cli-code and
               buf_contract.host-code     =  temp_ord-doc.host-code no-error .
   if not available  buf_contract then do:
      temp_ord-doc.contract-code =  0.
   end.
   else do:
      temp_ord-doc.contract-code =  buf_contract.contract-code .
   end.
      v-specif = false .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input temp_ord-doc.obj-type
  ,input temp_ord-doc.obj-code
  ,input 'nakl_par':U
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
        if thbjattr_thbj-attr.prop-code = 'type-vat' then v-value-integer = thbjattr_thbj-attr.property-value-integer.
      end.
          case v-value-integer:
          when 1 or when ? then do:
            assign
              v-typevat = 'в т. ч.':U.
          end.
          when 2 then do:
            assign
              v-typevat = 'нет':U.
          end.
          when 3 then do:
            assign
              v-typevat = 'без':U.
          end.
          otherwise do:
              v-end-message =  substitute(" Не верно задан атрибут 'Тип заведения НДС' (type-vat). &1 &2 &3 &4 &5" , temp_ord-doc.obj-type , temp_ord-doc.obj-code , error-status :get-message(1) , return-value , v-value-integer ) .
              run pcall-log-file in p-log-handle (input v-end-message) .
              undo, return error v-end-message.
          end.
          end case.
   if temp_ord-doc.contract-code  > 0 then do:
     find first  ub.contract-specif no-lock where
      ub.contract-specif.contract-num = temp_ord-doc.contract-code and
      ub.contract-specif.host-code    = temp_ord-doc.host-code  no-error .
      if available ub.contract-specif then
         assign
           v-typevat  = ub.contract-specif.VAT-type
           v-specif = true .
         .
   end.
   if buf_contract.curr-code <> temp_ord-doc.exch-code then do:
                v-end-message =  substitute("По договору &3   ожидалась валюта &1  пришла &2 " ,
                buf_contract.curr-code,
                temp_ord-doc.exch-code,
                temp_ord-doc.contract-code ) .
                run pcall-log-file in p-log-handle (input v-end-message) .
                undo, return error v-end-message.
   end.
      run who-cli-ora in this-procedure (
          input  temp_ord-doc.cli-code ,
          output temp_ord-doc.cli-type ,
          output temp_ord-doc.cli-code
          ) no-error .
          if error-status :error then return error return-value .
      v-cntxt-obj-code      =  temp_ord-doc.obj-code .
      v-cntxt-obj-type      =  temp_ord-doc.obj-type .
      v-cntxt-host-code-obj =  v-host-code .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run proc-ord-code in this-procedure
 (input   'main' ,
  input   v-cntxt-db-num ,
  input   temp_ord-doc.obj-type ,
  input   temp_ord-doc.obj-code ,
  input   v-i-doc ,
  output  v-doc-code
 ) .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  temp_ord-doc.obj-type
  ,input  temp_ord-doc.obj-code
  ,output to-day
  )  .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  v-host-code
  ,input  to-day
  ,output v-base-rate
  ,output v-base-scale
  )  .
  define buffer buf_sysconf for ub.sysconf  .
  find first buf_sysconf no-lock where buf_sysconf.host-code = v-host-code .
   if temp_ord-doc.pay-code = 0 then do:
   v-out-pay = buf_sysconf.out-pay.
   temp_ord-doc.pay-code = v-out-pay .
   end.
   else do:
      v-out-pay = temp_ord-doc.pay-code .
   end.
  if temp_ord-doc.exch-code = ? then do:
      assign
        temp_ord-doc.exch-code = 0
        temp_ord-doc.exch-rate  = 1
        temp_ord-doc.exch-scale = 1
      .
      v-end-message =  substitute("Предупреждение !!! Не верно введена валюта ПОСТАВЩИКА код &1 , меняю на национальную " ,              temp_ord-doc.exch-code   ) .
      run pcall-log-file in p-log-handle (input v-end-message) .
  end.
  if temp_ord-doc.exch-code = 0 then do:
      assign
        temp_ord-doc.exch-code = 0
        temp_ord-doc.exch-rate  = 1
        temp_ord-doc.exch-scale = 1
      .
  end.
  if temp_ord-doc.exch-rate  = 0 or
        temp_ord-doc.exch-rate  = ? then do:
          assign
            temp_ord-doc.exch-code = 0
            temp_ord-doc.exch-rate  = 1
            temp_ord-doc.exch-scale = 1
          .
      v-end-message =  substitute("Предупреждение !!! Не верно введен курс = &2 валюты ПОСТВЩИКА код &1 , меняю на национальную " ,              temp_ord-doc.exch-code , temp_ord-doc.exch-rate ) .
      run pcall-log-file in p-log-handle (input v-end-message) .
  end.
  if temp_ord-doc.exch-scale  = 0 or
        temp_ord-doc.exch-scale  = ? then do:
          assign
            temp_ord-doc.exch-code = 0
            temp_ord-doc.exch-rate  = 1
            temp_ord-doc.exch-scale = 1
          .
      v-end-message =  substitute("Предупреждение !!! Не верно введен масштаб = &2 валюты ПОСТВЩИКА код &1 , меняю на национальную " ,              temp_ord-doc.exch-code , temp_ord-doc.exch-scale ) .
      run pcall-log-file in p-log-handle (input v-end-message) .
  end.
    find first ub.currency where ub.currency.curr-code = temp_ord-doc.exch-code no-error .
    if error-status :error then do:
              v-end-message =  substitute("Нет валюты с кодом &1  (&2)" ,
              temp_ord-doc.exch-code , error-status :get-message(1)   ) .
            run pcall-log-file in p-log-handle (input v-end-message) .
            undo, return error v-end-message.
        end.
       k = 0 .
       vv-kol       = 0 .
       vv-kolcli    = 0 .
       vv-sumkolr   = 0 .
       vv-sumkolv   = 0 .
       vv-sumkolc   = 0 .
       for each temp_ord-line where
                temp_ord-line.doc-code = temp_ord-doc.doc-code
       :
            run ora-ver-goods ( temp_ord-line.gds-code )  no-error .
              if error-status :error then do:
                  v-end-message = return-value .
                  run pcall-log-file in p-log-handle ( input v-end-message ) .
                  undo, return error v-end-message.
              end.
            if temp_ord-doc.exch-code <> 0 and
               ( temp_ord-line.price-cli = 0 or
                 temp_ord-line.price-cli = ? ) then do:
                  v-end-message =  substitute("Не задана цена товара &1 в валюте поставщика " ,
                  temp_ord-line.gds-code  ) .
                run pcall-log-file in p-log-handle (input v-end-message) .
                undo, return error v-end-message.
             end.
            if temp_ord-doc.exch-code = 0 and
               temp_ord-line.price-rubl <> 0 and
               temp_ord-line.price-rubl <> ?
            then temp_ord-line.price-cli = temp_ord-line.price-rubl  .
           find first ub.goods no-lock  where
                ub.goods.gds-code = temp_ord-line.gds-code  no-error.
           if available ub.goods then do:
           if v-specif = true then do:
              find first ub.contract-specif no-lock where
                         ub.contract-specif.gds-code      = ub.goods.gds-code and
                         ub.contract-specif.contract-num  = temp_ord-doc.contract-code and
                         ub.contract-specif.host-code     = temp_ord-doc.host-code no-error .
              if not available ub.contract-specif then do:
                v-end-message =  substitute(" Товара &1 &2 нет в спецификации &3" , ub.goods.gds-code,
                ub.goods.gds-name, temp_ord-doc.contract-code ) .
                run pcall-log-file in p-log-handle (input v-end-message) .
                undo, return error v-end-message.
              end.
              else do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_ckcntspc in g#lib-trn3
( input temp_ord-doc.host-code
 ,input temp_ord-doc.contract-code
 ,input ub.goods.gds-code
 ,input temp_ord-line.price-cli
 ,input ub.contract-specif.VAT-type
 ,input temp_ord-line.VAT-pc
) no-error .
                if error-status :error then do:
                      v-end-message =  substitute(" У Товара &1 &2 в спецификации &3  &4 " , ub.goods.gds-code,
                      ub.goods.gds-name, temp_ord-doc.contract-code , return-value ) .
                      run pcall-log-file in p-log-handle (input v-end-message) .
                      undo, return error v-end-message.
                end.
               end.
           end.
               assign
                 k = k + 1
                 temp_ord-line.artic    = ub.goods.artic
                 temp_ord-line.prod-type= ub.goods.prod-type
                 temp_ord-line.prod-code= ub.goods.prod-code
                .
            end.
            else do:
                assign
                  v-end-message =  substitute(" Нет товара &1 " ,
                  temp_ord-line.gds-code  ) .
                run pcall-log-file in p-log-handle (input v-end-message) .
                undo, return error v-end-message.
            end.
            create ub.ord-line no-error.
                assign
                  ub.ord-line.doc-code        = v-doc-code
                  ub.ord-line.prod-type       = ub.goods.prod-type
                  ub.ord-line.prod-code       = ub.goods.prod-code
                  ub.ord-line.artic           = ub.goods.artic
                  ub.ord-line.gds-code        = ub.goods.gds-code
                  ub.ord-line.qnty            = temp_ord-line.fact-qnty
                  ub.ord-line.initial-qnty    = temp_ord-line.fact-qnt
                  ub.ord-line.cli-qnty        = temp_ord-line.fact-qnty
                  ub.ord-line.price-cli       = temp_ord-line.price-cli
                  ub.ord-line.sum-cli         = ub.ord-line.price-cli * ub.ord-line.cli-qnty
                  ub.ord-line.price-rubl      = ub.ord-line.price-cli * temp_ord-doc.exch-rate / temp_ord-doc.exch-scale
                  ub.ord-line.price-base      = ( temp_ord-line.price-rubl ) / v-base-rate * v-base-scale
                  ub.ord-line.ord-dec1        = ub.ord-line.price-rubl
                  ub.ord-line.sum-rubl        = ub.ord-line.price-rubl * ub.ord-line.qnty
                  ub.ord-line.sum-base        = ub.ord-line.price-base * ub.ord-line.qnty
                  ub.ord-line.unit-cli        = ub.goods.unit-cli
                  ub.ord-line.line-num        = k
                  ub.ord-line.vat-pc          = temp_ord-line.vat-pc
                  vv-kol                      = vv-kol + ub.ord-line.qnty
                  vv-kolcli                   = vv-kolcli + ub.ord-line.cli-qnty
                  vv-sumkolr                  = vv-sumkolr + ( ub.ord-line.qnty * ub.ord-line.price-rubl )
                  vv-sumkolv                  = vv-sumkolv + ( ub.ord-line.qnty * ub.ord-line.price-base )
                  vv-sumkolc                  = vv-sumkolc + ( ub.ord-line.cli-qnty * ub.ord-line.price-cli  )
                  .
                  find first ub.ext-artic no-lock  where
                              ub.ext-artic.cli-type = temp_ord-doc.cli-type
                          and ub.ext-artic.cli-code = temp_ord-doc.cli-code
                          and ub.ext-artic.gds-code = ub.goods.gds-code
                          and ub.ext-artic.status_  = 'тек':U
                          no-error .
                  if available ub.ext-artic then do:
                     ub.ord-line.cli-art = ub.ext-artic.ext-artic .
                  end.
                  else do:
                    ub.ord-line.cli-art = '' .
                  end.
          end .
          find first buf_clients no-lock where
                     buf_clients.obj-type = temp_ord-doc.cli-type and
                     buf_clients.obj-code = temp_ord-doc.cli-code
                     no-error.
              if not available buf_clients then do:
                v-end-message =  return-value .
                run pcall-log-file in p-log-handle (input v-end-message) .
                undo, return error v-end-message.
              end.
          run ver-contract  ( temp_ord-doc.contract-code, temp_ord-doc.host-code , v-doc-code) no-error .
          if error-status :error then do:
              undo, return error .
          end.
          create ub.ord-doc.
          buffer-copy temp_ord-doc to ub.ord-doc
          assign
              ub.ord-doc.doc-code     = v-doc-code
              ub.ord-doc.cli-out-doc  = temp_ord-doc.doc-code
              ub.ord-doc.doc-date     = to-day
              ub.ord-doc.cli-code     = buf_clients.obj-code
              ub.ord-doc.cli-name     = buf_clients.obj-name
              ub.ord-doc.cli-type     = buf_clients.obj-type
              ub.ord-doc.creid        = v-cntxt-userid
              ub.ord-doc.fact-date    = ?
              ub.ord-doc.pay-code     = v-out-pay
              ub.ord-doc.ship-date    = temp_ord-doc.ship-date
              ub.ord-doc.sum-service  = 0
              ub.ord-doc.sum-ship     = 0
              ub.ord-doc.flag_        = true
              ub.ord-doc.status_      = 'поставка':U
              ub.ord-doc.host-code    = temp_ord-doc.host-code
              ub.ord-doc.doc-type     = 'ОП':U
              ub.ord-doc.tot-lines    = k
              ub.ord-doc.order-type   = 0
              ub.ord-doc.cycle-day    = 0
              ub.ord-doc.start-date   = temp_ord-doc.doc-date
              ub.ord-doc.end-date     = temp_ord-doc.doc-date
              ub.ord-doc.date-sale-1  = temp_ord-doc.doc-date
              ub.ord-doc.date-sale-2  = temp_ord-doc.doc-date
              ub.ord-doc.pay-day      = 0
              ub.ord-doc.obj-code     = temp_ord-doc.obj-code
              ub.ord-doc.obj-type     = temp_ord-doc.obj-type
              ub.ord-doc.slt-type     = 'без':U
              ub.ord-doc.vat-type     = v-typevat
              ub.ord-doc.exch-date    = to-day
              ub.ord-doc.e-method     = ""
              ub.ord-doc.sum-rubl     = vv-sumkolr
              ub.ord-doc.sum-base     = vv-sumkolv
              ub.ord-doc.sum-cli      = vv-sumkolc
              ub.ord-doc.qnty         = vv-kol
              ub.ord-doc.cli-qnty     = vv-kolcli
              no-error .
                 if error-status :error then do:
                    v-end-message =  substitute(" Заказ: &1   &2 &3" ,
                                                  temp_ord-doc.doc-code    ,
                                                  return-value ,
                                                  error-status :get-message(1)  ).
                    run pcall-log-file in p-log-handle (input v-end-message) .
                    undo, return error v-end-message.
                 end.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  ub.ord-doc.host-code
  ,input  ub.ord-doc.exch-date
  ,output ub.ord-doc.base-rate
  ,output ub.ord-doc.base-scale
  )  .
                ub.ord-doc.cons-code  = temp_ord-doc.doc-code .
                ub.ord-doc.ps = ub.ord-doc.ps + " " + temp_ord-doc.doc-code +
                           " от " + string ( temp_ord-doc.doc-date , "99/99/9999") .
              v-end-message =  substitute(" &3&4 Заказ: &1  товаров: &2 " ,
                                            temp_ord-doc.doc-code    ,
                                            k ,
                                            temp_ord-doc.obj-type ,
                                            temp_ord-doc.obj-code
                                            ).
              run pcall-log-file in p-log-handle (input v-end-message) .
              p-ok-doc = p-ok-doc + 1 .
  end.
  otherwise do:
      v-end-message =  substitute(" Заказ: &1  не верный статус: &2" ,
                                    temp_ord-doc.doc-code    ,
                                    temp_ord-doc.status_
                                    ).
      run pcall-log-file in p-log-handle (input v-end-message) .
      undo, return error v-end-message.
  end.
  end case.
   end.
end.
procedure ver-contract :
define input  parameter p-contract-code as integer   no-undo .
define input  parameter p-host-code     as integer   no-undo .
define input  parameter p-doc-code      as character no-undo .
define buffer bf_contract-specif for ub.contract-specif  .
  do
  on error undo, return error return-value
  :
      if p-contract-code > 0  then do:
          find first bf_contract-specif where bf_contract-specif.host-code    = p-host-code     and
                                              bf_contract-specif.contract-num = p-contract-code no-lock no-error.
          if available bf_contract-specif then do:
             for each ub.ord-line no-lock where
                      ub.ord-line.doc-code = p-doc-code :
                if not can-find (first bf_contract-specif no-lock where
                                       bf_contract-specif.host-code    = p-host-code and
                                       bf_contract-specif.contract-num = p-contract-code and
                                       bf_contract-specif.gds-code     = ub.ord-line.gds-code   ) then do:
                    v-end-message =  substitute(
                      "Выбран Договор со спецификацией. Несоответствие списка товаров заказа и спецификации&1Заказ      :&2&1код товара :&3&1артикл     :&4&1 ",
                      ub.ord-line.doc-code,
                      ub.ord-line.gds-code,
                      ub.ord-line.artic ).
                    run pcall-log-file in p-log-handle (input v-end-message) .
                    undo, return error v-end-message.
                end.
             end.
          end.
        end.
  end.
end procedure.
