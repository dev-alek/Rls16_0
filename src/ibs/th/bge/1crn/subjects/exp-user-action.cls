/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Экспорт сообщения с чеком в 1С ERPRN check

Автор: Молотков Сергей Михайлович
Дата создания: 03/11/17
Author: Molotkov Sergey
Creation date: 03/11/17

*/

using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
block-level on error undo, throw.

class ibs.th.bge.1crn.subjects.exp-user-action inherits ibs.th.gbl.sys.objth implements iexpsubject:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Выгрузка действий пользователя" get.
 
  { cmp/str-glbl.i class }
  { utl/gtin.i class}

  define property Msg as character no-undo
    get:
      return trim (Msg, {&new-line}).
    end.
    private set (inArg as char):
      Msg = Msg + {&new-line} + inArg.
    end.

  /* 16/VIII-2018 надо вокруг чеков сделать еще одну секцию с номером смены.
     Связано это с тем, что если в пакет попадает несколько раз одна и таже смена,
     1С уже не понимает какой набор чеков был последний, т.к. они все валятся в один раздел.
  */
  define property InitSecTag as character no-undo init 'user-actions':U
    get.

  define public property sendTableName as character no-undo init "c-user-log"
    get.
   
  define public property sendOldRowid as rowid  no-undo
    get.
    set.

  define public property sendNewRowid as rowid  no-undo
    get.
    set.

  define property BufHandle as handle no-undo
    get.
    set.

  
  constructor public exp-user-action ():
  end constructor.
  
method public void CrContentToSW (insw as handle):

  define variable v-shift-num as integer no-undo .
  define variable v-shift-date as date no-undo .
  define variable v-pl-code   as integer no-undo .
  define variable v-rvd-reason-code as character no-undo .
  define variable v-RVD-on    as logical no-undo .
  define variable v-RVD-params as character no-undo .
  define variable v-RVD-dens  as logical no-undo .
  define variable v-RVD-temp  as logical no-undo .
  define variable v-RVD-level as logical no-undo .
  define variable v-is-meas as logical no-undo .
  define variable v-ITSM-num as character no-undo .
  define variable v-operator as character no-undo .
  define variable v-db-num-char as character no-undo .
  define variable v-rvs-code as character no-undo .
  define variable v-main-mi-old as character no-undo .
  define variable v-main-mi-new as character no-undo .
  define variable v-dnst-mi-old as character no-undo .
  define variable v-dnst-mi-new as character no-undo .
  define variable v-lvl-mi-old  as character no-undo .
  define variable v-lvl-mi-new  as character no-undo .
  define variable v-tmp-mi-old  as character no-undo .
  define variable v-tmp-mi-new  as character no-undo .
  
  define buffer buf_user-account for ub.user-account .

  Msg = "" .
  if not valid-handle(BufHandle) then undo, throw new Progress.Lang.AppError("Отсутствует запись Электронного документа") .
   
  define variable v-db-num as integer no-undo .
  define variable v-cusr-id as int64 no-undo .
  
  v-db-num = int(BufHandle:buffer-field( "corr-user-db-num":U  ):buffer-value ). 
  v-cusr-id = int64(BufHandle:buffer-field( "cusr-id":U  ):buffer-value ) .
   
  find first c-user-log where c-user-log.corr-user-db-num = v-db-num
                          and c-user-log.cusr-id = v-cusr-id
                          no-lock no-error.
  if available c-user-log
  then do:
    sendOldRowid = rowid(c-user-log).
    
    case c-user-log.head-table :
      when "rvd-reasons"
      then do :
        v-shift-date = date(entry(3, c-user-log.head-table-key, {&delim-cmd})) .
        v-shift-num = integer(entry(4, c-user-log.head-table-key, {&delim-cmd})) .
        v-pl-code = integer(entry(5, c-user-log.head-table-key, {&delim-cmd})) .
        v-RVD-params = entry(6, c-user-log.head-table-key, {&delim-cmd}) .
        v-RVD-on = logical(entry(7, c-user-log.head-table-key, {&delim-cmd})) .
        v-rvd-reason-code = entry(8, c-user-log.head-table-key, {&delim-cmd}) .
        v-ITSM-num = entry(9, c-user-log.head-table-key, {&delim-cmd}) .
        v-operator = entry(10, c-user-log.head-table-key, {&delim-cmd}) .
        v-RVD-temp = logical(entry(11, c-user-log.head-table-key, {&delim-cmd})) .
        v-RVD-dens = logical(entry(12, c-user-log.head-table-key, {&delim-cmd})) .
        v-RVD-level = logical(entry(13, c-user-log.head-table-key, {&delim-cmd})) .
        
        if num-entries(c-user-log.head-table-key, {&delim-cmd}) > 13
        then
          v-is-meas = logical(entry(14, c-user-log.head-table-key, {&delim-cmd})) .
          
        if num-entries(c-user-log.head-table-key, {&delim-cmd}) > 14
        then do :
          v-rvs-code = entry(15, c-user-log.head-table-key, {&delim-cmd}) .
          v-main-mi-old = entry(16, c-user-log.head-table-key, {&delim-cmd}) .
          v-main-mi-new = entry(17, c-user-log.head-table-key, {&delim-cmd}) .
          v-dnst-mi-old = entry(18, c-user-log.head-table-key, {&delim-cmd}) .
          v-dnst-mi-new = entry(19, c-user-log.head-table-key, {&delim-cmd}) .
          v-lvl-mi-old  = entry(20, c-user-log.head-table-key, {&delim-cmd}) .
          v-lvl-mi-new  = entry(21, c-user-log.head-table-key, {&delim-cmd}) .
          v-tmp-mi-old  = entry(22, c-user-log.head-table-key, {&delim-cmd}) .
          v-tmp-mi-new  = entry(23, c-user-log.head-table-key, {&delim-cmd}) .
        end .  
        
        if v-main-mi-old = "" then v-main-mi-old = "0" .
        if v-main-mi-new = "" then v-main-mi-new = "0" .
        if v-dnst-mi-old = "" then v-dnst-mi-old = "0" .
        if v-dnst-mi-new = "" then v-dnst-mi-new = "0" .
        if v-lvl-mi-old  = "" then v-lvl-mi-old  = "0" .
        if v-lvl-mi-new  = "" then v-lvl-mi-new  = "0" .
        if v-tmp-mi-old  = "" then v-tmp-mi-old  = "0" .
        if v-tmp-mi-new  = "" then v-tmp-mi-new  = "0" .
        
        insw:start-element ("user-action") .
          insw:write-data-element ("date", iso-date(datetime(c-user-log.corr-date, (c-user-log.corr-time * 1000 )))).
          insw:write-data-element ("shift-date", iso-date(v-shift-date) ).
          insw:write-data-element ("shift-num", string(v-shift-num) ).
          insw:write-data-element ("usr-id", c-user-log.corr-user-name ).
          for first buf_user-account no-lock where buf_user-account.user-id = c-user-log.corr-user-name :
            insw:write-data-element ("usr-nik", buf_user-account.nik ) .
          end .
          if v-rvs-code > "" then insw:write-data-element ("doc-num", v-rvs-code ).
          insw:start-element ("tank-actions") .
            insw:start-element ("tank-action") .
              insw:write-data-element ("tank-code", string(v-pl-code) ).
              if can-do(v-RVD-params, 'p')
              then do :
                insw:write-data-element ("rvd-dnsty", if v-RVD-dens then "1" else "0" ).
              end .
              if can-do(v-RVD-params, 'l')
              then do :
                insw:write-data-element ("rvd-lvl", if v-RVD-level then "1" else "0" ).
              end .
              if can-do(v-RVD-params, 'T')
              then do :
                insw:write-data-element ("rvd-tmp", if v-RVD-temp then "1" else "0" ).
              end .
              if can-do(v-RVD-params, 'F')
              then do :
                insw:write-data-element ("rvd-full", if v-is-meas then "1" else "0" ).
              end .
              insw:write-data-element ("rvd-reason", v-rvd-reason-code ).
              insw:write-data-element ("itsm-num", v-ITSM-num ).
              insw:write-data-element ("operator", v-operator ).
              if v-main-mi-old <> v-main-mi-new
              then do :
                insw:write-data-element ("main-mi-old", v-main-mi-old ).
                insw:write-data-element ("main-mi-new", v-main-mi-new ).
              end .
              if v-dnst-mi-old <> v-dnst-mi-new
              then do :
                insw:write-data-element ("dnst-mi-old", v-dnst-mi-old ).
                insw:write-data-element ("dnst-mi-new", v-dnst-mi-new ).
              end .
              if v-lvl-mi-old <> v-lvl-mi-new
              then do :
                insw:write-data-element ("lvl-mi-old", v-lvl-mi-old ).
                insw:write-data-element ("lvl-mi-new", v-lvl-mi-new ).
              end .
              if v-tmp-mi-old <> v-tmp-mi-new
              then do :
                insw:write-data-element ("tmp-mi-old", v-tmp-mi-old ).
                insw:write-data-element ("tmp-mi-new", v-tmp-mi-new ).
              end .
            insw:end-element ("tank-action") .
          insw:end-element ("tank-actions") .
        insw:end-element ("user-action") .
      end . /* rvd-reasons */
      when "mi-change-1C"
      then do :
        v-shift-date = date(entry(3, c-user-log.head-table-key, {&delim-cmd})) .
        v-shift-num = integer(entry(4, c-user-log.head-table-key, {&delim-cmd})) .
        v-pl-code = integer(entry(5, c-user-log.head-table-key, {&delim-cmd})) .
        v-main-mi-old = entry(9, c-user-log.head-table-key, {&delim-cmd}) .
        v-main-mi-new = entry(10, c-user-log.head-table-key, {&delim-cmd}) .
        v-dnst-mi-old = entry(11, c-user-log.head-table-key, {&delim-cmd}) .
        v-dnst-mi-new = entry(12, c-user-log.head-table-key, {&delim-cmd}) .
        v-lvl-mi-old  = entry(13, c-user-log.head-table-key, {&delim-cmd}) .
        v-lvl-mi-new  = entry(14, c-user-log.head-table-key, {&delim-cmd}) .
        v-tmp-mi-old  = entry(15, c-user-log.head-table-key, {&delim-cmd}) .
        v-tmp-mi-new  = entry(16, c-user-log.head-table-key, {&delim-cmd}) .
        
        if v-main-mi-old = "" then v-main-mi-old = "0" .
        if v-main-mi-new = "" then v-main-mi-new = "0" .
        if v-dnst-mi-old = "" then v-dnst-mi-old = "0" .
        if v-dnst-mi-new = "" then v-dnst-mi-new = "0" .
        if v-lvl-mi-old  = "" then v-lvl-mi-old  = "0" .
        if v-lvl-mi-new  = "" then v-lvl-mi-new  = "0" .
        if v-tmp-mi-old  = "" then v-tmp-mi-old  = "0" .
        if v-tmp-mi-new  = "" then v-tmp-mi-new  = "0" .
        
        insw:start-element ("user-action") .
          insw:write-data-element ("date", iso-date(datetime(c-user-log.corr-date, (c-user-log.corr-time * 1000 )))).
          insw:write-data-element ("shift-date", iso-date(v-shift-date) ).
          insw:write-data-element ("shift-num", string(v-shift-num) ).
          insw:write-data-element ("usr-id", c-user-log.corr-user-name ).
          for first buf_user-account no-lock where buf_user-account.user-id = c-user-log.corr-user-name :
            insw:write-data-element ("usr-nik", buf_user-account.nik ) .
          end .
          insw:start-element ("tank-actions") .
            insw:start-element ("tank-action") .
              insw:write-data-element ("tank-code", string(v-pl-code) ).
              if v-main-mi-old <> v-main-mi-new
              then do :
                insw:write-data-element ("main-mi-old", v-main-mi-old ).
                insw:write-data-element ("main-mi-new", v-main-mi-new ).
              end .
              if v-dnst-mi-old <> v-dnst-mi-new
              then do :
                insw:write-data-element ("dnst-mi-old", v-dnst-mi-old ).
                insw:write-data-element ("dnst-mi-new", v-dnst-mi-new ).
              end .
              if v-lvl-mi-old <> v-lvl-mi-new
              then do :
                insw:write-data-element ("lvl-mi-old", v-lvl-mi-old ).
                insw:write-data-element ("lvl-mi-new", v-lvl-mi-new ).
              end .
              if v-tmp-mi-old <> v-tmp-mi-new
              then do :
                insw:write-data-element ("tmp-mi-old", v-tmp-mi-old ).
                insw:write-data-element ("tmp-mi-new", v-tmp-mi-new ).
              end .
            insw:end-element ("tank-action") .
          insw:end-element ("tank-actions") .
        insw:end-element ("user-action") .
      end .
      when "schedule"
      then do :
        v-shift-date = date(entry(3, c-user-log.head-table-key, {&delim-cmd})) .
        v-shift-num = integer(entry(4, c-user-log.head-table-key, {&delim-cmd})) .
        if num-entries(c-user-log.head-table-key, {&delim-cmd}) >= 16
        then
          v-db-num-char = entry(16, c-user-log.head-table-key, {&delim-cmd}) .
        else
          v-db-num-char = string(v-db-num) no-error .

        insw:start-element ("user-action") .
          insw:write-data-element ("date", iso-date(datetime(c-user-log.corr-date, (c-user-log.corr-time * 1000 )))).
          insw:write-data-element ("shift-date", iso-date(v-shift-date) ).
          insw:write-data-element ("shift-num", string(v-shift-num) ).
          insw:write-data-element ("usr-id", c-user-log.corr-user-name ).
          for first buf_user-account no-lock where buf_user-account.user-id = c-user-log.corr-user-name :
            insw:write-data-element ("usr-nik", buf_user-account.nik ) .
          end .
          insw:start-element ("schdl-actions") .
            insw:start-element ("schdl-action") .
              insw:write-data-element ("task-type", entry(5, c-user-log.head-table-key, {&delim-cmd}) ).
              insw:write-data-element ("schd-free-id", entry(6, c-user-log.head-table-key, {&delim-cmd}) ).
              insw:write-data-element ("task-num", entry(7, c-user-log.head-table-key, {&delim-cmd}) ).
              insw:write-data-element ("db-num", v-db-num-char ).
              insw:write-data-element ("del-l", "0" ).
              insw:write-data-element ("del-f", (if entry(15, c-user-log.head-table-key, {&delim-cmd}) = "del" then "1" else "0") ).
              insw:write-data-element ("task-active", entry(8, c-user-log.head-table-key, {&delim-cmd}) ).
              insw:write-data-element ("task-year", entry(9, c-user-log.head-table-key, {&delim-cmd}) ).
              insw:write-data-element ("task-month", entry(10, c-user-log.head-table-key, {&delim-cmd}) ).
              insw:write-data-element ("task-day", entry(11, c-user-log.head-table-key, {&delim-cmd}) ).
              insw:write-data-element ("task-weekday", entry(12, c-user-log.head-table-key, {&delim-cmd}) ).
              insw:write-data-element ("task-hour", entry(13, c-user-log.head-table-key, {&delim-cmd}) ).
              insw:write-data-element ("task-minute", entry(14, c-user-log.head-table-key, {&delim-cmd}) ).
            insw:end-element ("schdl-action") .
          insw:end-element ("schdl-actions") .
        insw:end-element ("user-action") .
      end . /* schedule */
    end case .
  end.
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
    
end method . /* end_of CrContentToSW */




  /* Формат даты ДД.ММ.ГГГГ
    <doc-date>01.01.2017</doc-date>
    <created-date>23.10.2017 12:08:15</created-date>
    28/XI-2017 - dataFormat() не используется: все даты в формате ISO
  */
  method private character timeFormat (p-time as integer) :
    define variable v-tm-format as character initial "hh:mm:ss" no-undo .
    return if (p-time >= 0) then string(p-time, v-tm-format) else "" .
  end method .
  method private character dateFormat (p-date as date) :
    define variable v-dt-format as character initial "99.99.9999" no-undo .
    return if (p-date = ?) then "" else string(p-date, v-dt-format) .
  end method .

  
  method private character base64-enc ( input v-string as character ) :
    
    define variable v-base64-encode as character no-undo .
    
    
    do
    on error undo, return error return-value
    :
      define variable v-raw     as raw       no-undo .
      define variable v-raw-str as character no-undo .
    
      if v-string = ?
      then do:
        undo, return error "base64-encode: строка имеет неопределенное значение" .
        end.
    
        assign
          length(v-raw) = length(v-string) + 1
        .
        assign
          put-string(v-raw, 1) = v-string
        .
        assign
          v-raw-str = string(v-raw)
        .
        assign
          length(v-raw) = 0
        .
        assign
          v-base64-encode = substring(v-raw-str, 7)
        .
    end.
    
    return v-base64-encode .
  end.

  
end class.
