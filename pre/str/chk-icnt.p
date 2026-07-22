block-level on error undo, throw.
define input parameter parrecid as recid no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chk-icnt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/chk-icnt.p $":U .
define variable vss-description as character no-undo init "Проверка документов счетчиков ТРК".
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
define buffer buf_icnt-doc for ub.icnt-doc.
define buffer buf_icnt-line for ub.icnt-line.
define buffer aft_icnt-doc for ub.icnt-doc.
tr:
do transaction on error   undo tr, return error
               on end-key undo tr, return error
               on stop    undo tr, return error:
find buf_icnt-doc where recid(buf_icnt-doc) = parrecid exclusive no-error.
if not available buf_icnt-doc then undo tr, return error "Ошибка при поиске документа инвентаризации счетчиков ТРК (файл chk-icnt.p)".
if buf_icnt-doc.doc-type = 'инв-сч-трк':U then do:
  find first aft_icnt-doc where aft_icnt-doc.obj-type   = buf_icnt-doc.obj-type       and
                                aft_icnt-doc.obj-code   = buf_icnt-doc.obj-code       and
                                aft_icnt-doc.doc-type   = 'инв-сч-трк':U                 and
                              (aft_icnt-doc.shift-date > buf_icnt-doc.shift-date or
                                aft_icnt-doc.shift-date = buf_icnt-doc.shift-date and
                                aft_icnt-doc.shift-num  > buf_icnt-doc.shift-num    ) and
                                aft_icnt-doc.status_     = 'факт':U           no-lock no-error.
  if available aft_icnt-doc then undo tr, return error "Уже имеется более поздний документ инвентаризации счетчиков ТРК: " + aft_icnt-doc.doc-code +  " Смена: " + string(aft_icnt-doc.shift-date) + " " + string(aft_icnt-doc.shift-num).
end.
if buf_icnt-doc.status_ = 'факт':U then do:
   for each buf_icnt-line where buf_icnt-line.doc-code = buf_icnt-doc.doc-code no-lock:
       if buf_icnt-line.state-el-cnt = ? then do:
         if buf_icnt-doc.doc-type = 'инв-сч-трк':U then do:
            undo tr, return error substitute("Не задано количество по электронному счетчику ТРК: &1 пистолет &2."
                                            ,buf_icnt-line.pump-code
                                            ,buf_icnt-line.nozzle-code).
         end.
         if buf_icnt-doc.doc-type = 'сч-трк-погр':U then do:
            undo tr, return error substitute("Не задано количество по счетчику ТРК: &1 пистолет &2."
                                            ,buf_icnt-line.pump-code
                                            ,buf_icnt-line.nozzle-code).
         end.
       end.
       if buf_icnt-line.state-mh-cnt = ? then do:
         if buf_icnt-doc.doc-type = 'инв-сч-трк':U then do:
           undo tr, return error substitute("Не задано количество по механическому счетчику ТРК: &1 пистолет &2."
                                            ,buf_icnt-line.pump-code
                                            ,buf_icnt-line.nozzle-code) .
         end.
         if buf_icnt-doc.doc-type = 'сч-трк-погр':U then do:
           undo tr, return error substitute("Не задано количество по мернику для ТРК: &1 пистолет &2."
                                            ,buf_icnt-line.pump-code
                                            ,buf_icnt-line.nozzle-code) .
         end.
       end.
   end.
   run gbl/chk-date.p
     (input buf_icnt-doc.obj-type
     ,input buf_icnt-doc.obj-code
     ,input buf_icnt-doc.fact-date
     ,input buf_icnt-doc.fact-time
     ,input buf_icnt-doc.shift-date
     ,input buf_icnt-doc.shift-num
     ,input true
     ) no-error .
   if error-status:error then undo tr, return error
    substitute("Неверная дата и время в документе счетчиков ТРК:&1"  +
               "fact-date=&2 fact-time = &3 shift-date=&4 shift-num=&5"
               ,chr(10)
               ,buf_icnt-doc.fact-date
               ,buf_icnt-doc.fact-time
               ,buf_icnt-doc.shift-date
               ,buf_icnt-doc.shift-num)
   .
  end.
end.
