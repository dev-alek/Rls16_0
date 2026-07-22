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
{ utl/tt-test-1c.i}


if not valid-handle (ibs.th.gbl.gbl-hndllib:g#lib-trn)
    then run str/lib-trn.p persistent no-error .
if not valid-handle (ibs.th.gbl.gbl-hndllib:g#lib-trn2)
    then run str/lib-trn2.p persistent no-error .
if not valid-handle (ibs.th.gbl.gbl-hndllib:g#lib-trn3)
    then run str/lib-trn3.p persistent no-error .
if not valid-handle (ibs.th.gbl.gbl-hndllib:g#lib-trn4)
    then run str/lib-trn4.p persistent no-error .


// define temp-table tt-trn like ub.shift-obj .
define buffer buf_shift-obj for ub.shift-obj .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
define variable v-sht-date as date no-undo .
define variable v-sht-num  as integer no-undo .
define button btnOk auto-go label "Ok" .
define button btnCancel auto-endkey label "Cancel".

if testId ne ? then
do:
  find first buf_shift-obj where rowid(buf_shift-obj) = testId no-lock no-error.
  if not avail buf_shift-obj then return.  
end.
else
do:
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
end.

if not available (buf_shift-obj) then do:
    message substitute("Отсутствует смена №&1 от &2 в магазине &3",
                       v-sht-num, v-sht-date, v-obj-code) view-as alert-box.
    return.
end.


// buffer-copy trn-doc except trn-doc.status_ to tt-trn  assign tt-trn.status_ = "накл". /* для имитации изменения статуса на факт */

{ gbl/rum-runa.i
  ?
  this-procedure:handle
  ?
  {&edoc-proc_event_shift}
  " buffer buf_shift-obj:handle "
  " buffer buf_shift-obj:handle "
  ''
  ''
  no-error
}
if error-status:error then do :
  message "Ошибка маршрутизации записи в машину правил" skip return-value skip error-status:get-message(1) view-as alert-box.
end.
else do:
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
  if testId <> ? then
    put stream vProtTest unformatted 
      substitute("Cмена №&1 от &2 в магазине &3 отправлена",
                 buf_shift-obj.shift-num, buf_shift-obj.shift-date, buf_shift-obj.obj-code)
      skip. 
  else
    message substitute("Cмена №&1 от &2 в магазине &3 отправлена",
                     v-sht-num, v-sht-date, v-obj-code) view-as alert-box.
end.
