block-level on error undo, throw.

/*------------------------------------------------------------------------
    File        : send2c.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : 
    Created     : Thu Apr 24 18:52:18 MSK 2018
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO .


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */


{ cmp/trg-def.i  }
{ cmp/library.i  }
{ gbl/objsrv.i }
{ str/trdcalib.i }

if not valid-handle (ibs.th.gbl.gbl-hndllib:g#lib-trn)
    then run str/lib-trn.p persistent no-error .
if not valid-handle (ibs.th.gbl.gbl-hndllib:g#lib-trn2)
    then run str/lib-trn2.p persistent no-error .
if not valid-handle (ibs.th.gbl.gbl-hndllib:g#lib-trn3)
    then run str/lib-trn3.p persistent no-error .
if not valid-handle (ibs.th.gbl.gbl-hndllib:g#lib-trn4)
    then run str/lib-trn4.p persistent no-error .
if not valid-handle (ibs.th.gbl.gbl-hndllib:g#trdcalib)
    then run str/trdcalib.p persistent no-error .


define buffer buf_shift-obj for ub.shift-obj .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer   no-undo .
define variable v-sht-date as date      no-undo .
define variable v-sht-num  as integer   no-undo .
define variable varvalue   as character no-undo .
define variable vartype    as character no-undo .

define button btnOk auto-go label "Ok" .
define button btnCancel auto-endkey label "Cancel".

define temp-table tt-shift like ub.shift-obj .
define temp-table tt-trn like ub.trn-doc.
define temp-table tt-price-doc like ub.price-doc.
define temp-table tt-rvs like ub.rvs-doc.
define temp-table tt-fbr like ub.fbr-doc.
define temp-table tt-fin like ub.fin-doc.
define temp-table tt-utd like ub.utd .

DEFINE FRAME frame1
    skip
    v-obj-code format ">>>>>>>>9"  label "Код магазина"
    skip    space(2) v-sht-date format "99/99/9999" label "Дата смены"
    space(2) v-sht-num                      label "Порядок смены"
    skip(1) space(2) btnOk
    space(2) btnCancel
    with
    side-labels
    default-button btnOk
    cancel-button btnCancel
    view-as dialog-box
    title "Введите номер код магазина, дату и номер смены"
    .

update v-obj-code v-sht-date v-sht-num btnOk btnCancel with frame frame1.

find first buf_shift-obj no-lock
    where buf_shift-obj.obj-type = 'маг'
    and buf_shift-obj.obj-code = v-obj-code
    and buf_shift-obj.shift-date = v-sht-date
    and buf_shift-obj.shift-num  = v-sht-num no-error .
if not available (buf_shift-obj) then 
do:
    message substitute("Отсутствует смена №&1 от &2 в магазине &3",
        v-sht-num, v-sht-date, v-obj-code) view-as alert-box.
    return.
end.

buffer-copy buf_shift-obj except buf_shift-obj.status_ to tt-shift  assign tt-shift.status_ = "накл". /* для имитации изменения статуса на факт */

for each ub.trn-doc no-lock where ub.trn-doc.obj-type = buf_shift-obj.obj-type
    and ub.trn-doc.obj-code = buf_shift-obj.obj-code
    and ub.trn-doc.shift-date = buf_shift-obj.shift-date
    and ub.trn-doc.shift-num = buf_shift-obj.shift-num :
    
    buffer-copy ub.trn-doc except ub.trn-doc.status_ to tt-trn  assign 
        tt-trn.status_ = "накл". /* для имитации изменения статуса на факт */
{ gbl/rum-runa.i
  ?
  this-procedure:handle
  ?
  {&edoc-proc_event_trn-doc}
  " buffer tt-trn:handle "
  " buffer ub.trn-doc:handle "  ''
  ''
  no-error
}
if error-status:error 
then do:
  message return-value view-as alert-box.
end.
{ str/tdat-val.i
     ub.trn-doc.doc-code
     {&trdcattr-is-lgas}
     varvalue
     vartype
     no-error
   }
   
  if varvalue = "yes" then 
  do:
    run bge\send1cerp.p (?,
      this-procedure,
      this-procedure,
      "techlosses",
      (buffer ub.trn-doc:handle),
      ?,
      ?) no-error.
    if error-status:error 
      then 
    do:
      message return-value view-as alert-box.
    end.
  end.

for each tt-trn:
    delete tt-trn .
end.    
end.

for each ub.price-doc no-lock where ub.price-doc.obj-code = buf_shift-obj.obj-code and
    ub.price-doc.obj-type = buf_shift-obj.obj-type and
    ub.price-doc.shift-date = buf_shift-obj.shift-date and
    ub.price-doc.shift-num = buf_shift-obj.shift-num :

    buffer-copy ub.price-doc except ub.price-doc.status_ to tt-price-doc  assign 
        tt-price-doc.status_ = "приказ". /* для имитации изменения статуса на акт */
        /*Выгрузка переоценок*/
{ gbl/rum-runa.i
  ?
  this-procedure:handle
  ?
  {&edoc-proc_event_price-doc}
  " buffer tt-price-doc:handle "
  " buffer ub.price-doc:handle "  ''
  ''
  no-error
}
if error-status:error 
    then 
do:
    message return-value view-as alert-box.
end.
for each tt-price-doc:
    delete tt-price-doc .
end.    

end.

for each ub.rvs-doc no-lock where ub.rvs-doc.obj-code = buf_shift-obj.obj-code and
    ub.rvs-doc.obj-type = buf_shift-obj.obj-type and
    ub.rvs-doc.shift-date = buf_shift-obj.shift-date and
    ub.rvs-doc.shift-num = buf_shift-obj.shift-num:

    buffer-copy rvs-doc except rvs-doc.status_ to tt-rvs  assign 
        tt-rvs.status_ = "накл". /* для имитации изменения статуса на факт */
/*Выгрузка сверок*/
{ gbl/rum-runa.i
  ?
  this-procedure:handle
  ?
  {&edoc-proc_event_rvs-doc}
  " buffer tt-rvs:handle "
  " buffer ub.rvs-doc:handle "  ''
  ''
  no-error
}
if error-status:error 
    then 
do:
    message return-value view-as alert-box.
end.
for each tt-rvs:
    delete tt-rvs .
end.    
end.

for each ub.fbr-doc no-lock where ub.fbr-doc.obj-code = buf_shift-obj.obj-code and
    ub.fbr-doc.obj-type = buf_shift-obj.obj-type and
    ub.fbr-doc.shift-date = buf_shift-obj.shift-date and
    ub.fbr-doc.shift-num = buf_shift-obj.shift-num:

    buffer-copy fbr-doc except fbr-doc.status_ to tt-fbr  assign 
        tt-fbr.status_ = "накл". /* для имитации изменения статуса на факт */
/*Выгрузка сверок*/
{ gbl/rum-runa.i
  ?
  this-procedure:handle
  ?
  {&edoc-proc_event_fbr-doc}
  " buffer tt-fbr:handle "
  " buffer ub.fbr-doc:handle "  ''
  ''
  no-error
}
if error-status:error 
    then 
do:
    message return-value view-as alert-box.
end.
for each tt-fbr:
    delete tt-fbr .
end.    
end.

for each ub.fin-doc no-lock where ub.fin-doc.obj-code = buf_shift-obj.obj-code and
    ub.fin-doc.obj-type = buf_shift-obj.obj-type and 
    ub.fin-doc.shift-date = buf_shift-obj.shift-date and
    ub.fin-doc.shift-num = buf_shift-obj.shift-num:

    buffer-copy fin-doc except fin-doc.status_ to tt-fin  assign 
        tt-fin.status_ = "накл". /* для имитации изменения статуса на факт */
        /*Выгрузка ПКО РКО*/
{ gbl/rum-runa.i
      ?
      this-procedure:handle
      ?
      {&edoc-proc_event_fin-doc}
      " buffer tt-fin:handle "
      " buffer ub.fin-doc:handle "
      ''
      ''
      no-error
    }
if error-status:error 
    then 
do:
    message return-value view-as alert-box.
end.
for each tt-fin:
    delete tt-fin .
end.    
end.

/*выгрузка Контрольной плотности НП*/
run str/prep1C-shift-period.p (input ?,
                               input buf_shift-obj.obj-type,
                               input buf_shift-obj.obj-code,
                               input buf_shift-obj.shift-date,
                               input buf_shift-obj.shift-num)
                               no-error .
if error-status:error 
then do:
  message return-value view-as alert-box.
end.

/*выгрузка УПД*/
/*   EXPSD-8344                                                                                                                                                                      */
/*for each ub.utd no-lock where ub.utd.obj-code = buf_shift-obj.obj-code and                                                                                               */
/*                              ub.utd.obj-type = buf_shift-obj.obj-type and                                                                                               */
/*                              (ub.utd.DocumentDate >= buf_shift-obj.shift-date and (if buf_shift-obj.close-date <> ? then ub.utd.DocumentDate <= buf_shift-obj.close-date*/
/*                              else ub.utd.DocumentDate <= today)):                                                                                                       */
/*   if ub.utd.sts <> ObjSrv:Env:Utd:Sts:TH:AwaitingDelivery:KeyIntDB then                                                                                                 */
/*   do:                                                                                                                                                                   */
/*      find last ub.c-utd no-lock where ub.c-utd.doc-code = ub.utd.doc-code                                                                                               */
/*                                   and ub.c-utd.db-num = ub.c-utd.db-num no-error .                                                                                      */
/*      buffer-copy ub.utd except ub.utd.sts ub.utd.sts-edi to tt-utd  .                                                                                                   */
/*      if available (ub.c-utd) then do:                                                                                                                                   */
/*         assign                                                                                                                                                          */
/*                 tt-utd.sts = ub.c-utd.sts                                                                                                                               */
/*                 tt-utd.sts-edi = ub.c-utd.sts-edi                                                                                                                       */
/*         . /* для имитации изменения статуса на факт */                                                                                                                  */
/*      end.                                                                                                                                                               */
/*      run bge\send1cerp.p (?,                                                                                                                                            */
/*        this-procedure,                                                                                                                                                  */
/*        this-procedure,                                                                                                                                                  */
/*        "edi-doc",                                                                                                                                                       */
/*        (buffer tt-utd:handle),                                                                                                                                          */
/*        (buffer ub.utd:handle),                                                                                                                                          */
/*        ?) no-error.                                                                                                                                                     */
/*      if error-status:error                                                                                                                                              */
/*          then                                                                                                                                                           */
/*      do:                                                                                                                                                                */
/*          message return-value view-as alert-box.                                                                                                                        */
/*      end.                                                                                                                                                               */
/*      for each tt-utd:                                                                                                                                                   */
/*          delete tt-utd .                                                                                                                                                */
/*      end.                                                                                                                                                               */
/*   end.                                                                                                                                                                  */
/*end.                                                                                                                                                                     */
/*Выгрузка смены*/
{ gbl/rum-runa.i
  ?
  this-procedure:handle
  ?
  {&edoc-proc_event_shift}
  " buffer tt-shift:handle "
  " buffer buf_shift-obj:handle "
  ''
  ''
  no-error
}
if error-status:error then 
do :
    message "Ошибка маршрутизации записи в машину правил" skip return-value skip error-status:get-message(1) view-as alert-box.
end.
else 
do:
    /* сменный отчет */
    define buffer buf_reportShift for ub.reportShift .

    find first buf_reportShift exclusive-lock where buf_reportShift.shift-date = buf_shift-obj.shift-date and
        buf_reportShift.shift-num = buf_shift-obj.shift-num and buf_reportShift.obj-code = buf_shift-obj.obj-code and
        buf_reportShift.obj-type = buf_shift-obj.obj-type and buf_reportShift.report-type = 1 no-error .
    if available (buf_reportShift) then 
    do:      
        run bge\send1cerp.p (parparentproc,
            this-procedure,
            this-procedure,
            "reportShift",
            (buffer buf_reportShift:handle),
            ?,                       
            ?) no-error.
        if  error-status:error then 
        do: 
            message return-value
                view-as alert-box.  
            return .
        end.
    end.
    
    message substitute("Cмена №&1 от &2 в магазине &3 отправлена",
        v-sht-num, v-sht-date, v-obj-code) view-as alert-box.
end.