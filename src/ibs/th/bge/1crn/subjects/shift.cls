/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Экспорт сообщения с личным составом смены в 1С ERPRN shift

Автор: Молотков Сергей Михайлович
Дата создания: 02/11/17
Author: Molotkov Sergey
Creation date: 02/11/17

*/

using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
block-level on error undo, throw.


class ibs.th.bge.1crn.subjects.shift implements iexpsubject:

  { cmp/str-glbl.i class }
    define stream sinp .
    { gbl/binfileclass.i  &stream-name=sinp class }
  define property Msg as character no-undo
    get.
    private set.

  &scop tag-interface 'shifts':U
  define property InitSecTag as character no-undo init {&tag-interface}
    get.
    
  define public property sendTableName as character no-undo init "shift-obj"
    get.
   
  define public property sendOldRowid as rowid  no-undo
    get.
    set.

  define public property sendNewRowid as rowid  no-undo
    get.
    set.

  define property KeyRowid as rowid no-undo
    get.
    set.
    
  &scop tag-message   'shift':U
  &scop tag-section1  'personal':U
  &scop tag-item1     'cashier':U
  
  /*------------------------------------------------------------------------------
   Purpose: выгружает состав сущности в контекст контейнера SAX-writer
   Notes:   обязательный метод
   Param:   insw = create sax-writer
  ------------------------------------------------------------------------------*/
  method public void CrContentToSW (insw as handle):
    define buffer buf_shift-obj   for ub.shift-obj .
    define buffer buf_shift-staff for ub.shift-staff .
    define variable v-dt-shift-start as datetime no-undo .
    define variable v-dt-shift-end   as datetime no-undo .
    
    Msg = "" .
    find first buf_shift-obj no-lock where rowid(buf_shift-obj) = KeyRowid no-error .
    if not available buf_shift-obj then undo, throw new Progress.Lang.AppError(
      substitute("Не найдена запись СМЕНА shift-obj rowid [&1]", KeyRowid)
    ) .
    
    sendOldRowid  = KeyRowid.
    insw:start-element ({&tag-message}) .

    
    if buf_shift-obj.shift-date = ? then insw:write-empty-element( "shift-date":U ). /* Дата смены (Дата) */
    else insw:write-data-element (  "shift-date":U,  iso-date(buf_shift-obj.shift-date)  ).
    
    insw:write-data-element (  "shift-num":U,  string(buf_shift-obj.shift-num)  ). /* Номер смены (Число) */
    insw:write-data-element (  "shift-number":U,  string(buf_shift-obj.shift-name)  ). /* Номер смены (Число) */
    
    assign
      v-dt-shift-start = datetime(buf_shift-obj.open-date, buf_shift-obj.open-time * 1000)
      /* 16/XI-2017: по закрытию смены выгружать shift-end, по открытию смены выгружать пустое поле */
      v-dt-shift-end   = if (buf_shift-obj.status_ = {&sht-closed}) then
                         datetime(buf_shift-obj.close-date, buf_shift-obj.close-time * 1000)
                         else ?
    .
    if v-dt-shift-start = ? then insw:write-empty-element ( "shift-start":U ) . /* Дата и время открытия смены (Дата/Время) */
    else insw:write-data-element (  "shift-start":U,  iso-date(v-dt-shift-start)  ) . 
    
    if v-dt-shift-end   = ? then insw:write-empty-element ( "shift-end":U   ) . /* Дата и время закрытия смены (Дата/Время) */
    else insw:write-data-element (  "shift-end":U,    iso-date(v-dt-shift-end)    ) . 


    /* 06/XII-2017 Если нет совсем в смене персонала, то секцию personal не формировать. */
    if can-find (first buf_shift-staff
                 where buf_shift-staff.obj-type   = buf_shift-obj.obj-type
                   and buf_shift-staff.obj-code   = buf_shift-obj.obj-code
                   and buf_shift-staff.shift-date = buf_shift-obj.shift-date
                   and buf_shift-staff.shift-num  = buf_shift-obj.shift-num
                   and buf_shift-staff.next-shift = false) then do:
      insw:start-element ({&tag-section1}) .
      for each buf_shift-staff no-lock
         where buf_shift-staff.obj-type   = buf_shift-obj.obj-type
           and buf_shift-staff.obj-code   = buf_shift-obj.obj-code
           and buf_shift-staff.shift-date = buf_shift-obj.shift-date
           and buf_shift-staff.shift-num  = buf_shift-obj.shift-num
           and buf_shift-staff.next-shift = false :
        insw:start-element ({&tag-item1}) .
        
        if buf_shift-staff.psn-code > 0 then
        insw:write-data-element (  "cashier-code",  string(buf_shift-staff.psn-code)                 ) . /* Код кассира (Строка) - 16/XI-2017: выгружать код физ.лица */
        else
        insw:write-data-element (  "cashier-code",  "0"                 ) . /* Код кассира (Строка) - 16/XI-2017: выгружать код физ.лица */
        
        insw:write-data-element (  "main-cashier",  if buf_shift-staff.staff-role then "1" else "0"  ) . /* Признак старшего смены (Число (1,0)) */
        insw:end-element ({&tag-item1}) .
      end .
      insw:end-element ({&tag-section1}) .
    end.

      if v-dt-shift-end <> ? then 
      do:
          define buffer buf_reportShift for ub.reportShift .
          define variable mypar      as character no-undo .
          define variable check-html as character no-undo .
          define variable v-ras      as logical   no-undo .
          define variable report-html1      as longchar no-undo .
          define buffer buf_temp-ext-file-line for temp-ext-file-line .

          find first buf_reportShift exclusive-lock where
              buf_reportShift.obj-code  = buf_shift-obj.obj-code
              and buf_reportShift.obj-type = buf_shift-obj.obj-type
              and buf_reportShift.shift-date = buf_shift-obj.shift-date
              and buf_reportShift.shift-num  = buf_shift-obj.shift-num
              and buf_reportShift.report-type  = 0 no-error .
          if not avail buf_reportShift then
          do:
              Msg = substitute("Чек лист за смену &1 &2 не найден.", buf_shift-obj.shift-date, buf_shift-obj.shift-num).
              return error.
          end.
          mypar =
              "X-DATE-START = " + string(buf_reportShift.shift-date, "99/99/9999") + {&comma-char} +
              "X-SHIFT-START = " + string(buf_reportShift.shift-num) + {&comma-char} +
              "X-OBJ-CODE = " + string(buf_reportShift.obj-code) + {&comma-char} +
              "X-OBJ-TYPE = " + string(buf_reportShift.obj-type) .


          if can-find (first shift-param where shift-param.obj-code = buf_reportShift.obj-code and
              shift-param.obj-type = buf_reportShift.obj-type and
              shift-param.shift-date = buf_reportShift.shift-date and
              shift-param.shift-num = buf_reportShift.shift-num and
              (shift-param.error-mass or shift-param.error-paid-trans)) then v-ras = true .

/*define variable v-print as logical no-undo .*/
/*if (buf_shift-obj.close-date = today and buf_shift-obj.close-time < (time - 400)) or*/
/*buf_shift-obj.close-date < today then v-print = false .                             */
/*else v-print = true .                                                               */

          run rep/r-shiftClose.p
              (input buf_shift-obj.host-code
              ,input mypar
              ,input yes
              ,input v-ras
              ,input false
              ,output check-html
              ) .
          buf_reportShift.report-html = check-html .

          if search(buf_reportShift.report-html) <> ? then 
          do:

              binfile_read(input  0
                  ,input  1
                  ,input  1
                  ,input  buf_reportShift.report-html
                  ) .

              for each buf_temp-ext-file-line
                  where buf_temp-ext-file-line.db-num   = 0
                  and buf_temp-ext-file-line.from-db-num = 1
                  and buf_temp-ext-file-line.file-num = 1
                  on error undo, return error return-value
                  :
                  report-html1 = report-html1 + buf_temp-ext-file-line.line-text .
              end.
          end.
          insw:start-element ("checklist") .
          insw:write-data-element (  "id":U,   string(buf_reportShift.id)    ).
          insw:write-data-element (  "generation":U,   if buf_reportShift.date = ? then "" else iso-date (datetime (buf_reportShift.date, buf_reportShift.time_ * 1000))).
/*          insw:write-data-element (  "shift":U, iso-date(buf_reportShift.shift-date) ) .         */
/*          insw:write-data-element (  "shift-num":U,   string(buf_reportShift.shift-num)    ).    */
/*          insw:write-data-element (  "shift-number":U,   string(buf_reportShift.shift-name)    ).*/
          insw:write-data-element (  "checklist-html":U,  report-html1 ).
          insw:write-data-element (  "suspicious-chk":U,  if buf_reportShift.flag then "1" else "0" ).
          insw:write-data-element (  "operator":U,  string(buf_reportShift.fio) ).
          insw:write-data-element (  "id-user":U,   entry(2,buf_reportShift.user-id,"-")  ).
          insw:end-element ("checklist") .

      end.
    insw:end-element ({&tag-message}) .
    

    catch exAppErrors as class Progress.Lang.AppError :
      Msg = exAppErrors:ReturnValue .
      if Msg = "" then Msg = exAppErrors:GetMessage(1) .
      undo, throw exAppErrors .
    end catch .
    catch exProErrors as class Progress.Lang.ProError :
      Msg = exProErrors:GetMessage(1) . 
      undo, throw exProErrors .
    end catch .
    catch exAnyErrors as class Progress.Lang.Error:
      Msg = "Unexpected error occurred..." .
      undo, throw exAnyErrors .
    end catch .
    finally :
    end finally .
  end method . /* end_of CrContentToSW */

  
  /* Формат даты ДД.ММ.ГГГГ
    <doc-date>01.01.2017</doc-date>
    <created-date>23.10.2017 12:08:15</created-date>
    28/XI-2017 - не используются: все даты в формате ISO
  */
  method private character dtimeFormat (p-date as date, p-time as integer) :
    define variable v-dt-format as character initial "99.99.9999" no-undo .
    define variable v-tm-format as character initial "hh:mm:ss" no-undo .
    define variable v-str-dtime as character no-undo . /* возвратное значение */
    
    if (p-date = ?) then v-str-dtime = "" .
    else assign
       v-str-dtime = string(p-date, v-dt-format)
       v-str-dtime  = v-str-dtime  + " " + string(p-time, v-tm-format) when (p-time >= 0)
    .
    
    return v-str-dtime .
  end method .
  method private character dateFormat (p-date as date) :
    define variable v-dt-format as character initial "99.99.9999" no-undo .
    return if (p-date = ?) then "" else string(p-date, v-dt-format) .
  end method .


end class.