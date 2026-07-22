
/*------------------------------------------------------------------------
    File        : prep1C-status-cal-tbl.p
    Purpose     : 

    Syntax      :

    Description : Подготовка данных по cтатусам градуировочных таблиц (резервуаров, поясной вместимости) и выгрузка в 1С

    Author(s)   : SlivenkoSA
    Created     : May 19 2025
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

block-level on error undo, throw.

define input parameter p-table-version like ub.place-imp.table-version no-undo .
define input parameter p-tank-code like ub.place-imp.pl-code no-undo .
define input parameter p-status-date like ub.place-imp.corr-date no-undo .
define input parameter p-status-time like ub.place-imp.corr-time no-undo .
define input parameter p-status_ like ub.place-imp.status_ no-undo .

define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }


define variable expData as memptr no-undo .
define variable log-file-name as character no-undo initial "status-cal-tbl.log" .
define variable v-pid as int64 no-undo .

{ gbl/cur-time.i }

/* ***************************  Main Block  *************************** */

run create-esys-data .
run exp1C .

procedure create-esys-data :
  define variable sw as handle no-undo.
  
  create sax-writer sw.
  sw:set-output-destination ("memptr", expData).
  sw:encoding = "UTF-8".
  sw:fragment = true .
  sw:formatted = true .
  sw:start-document () .
    sw:start-element ("status-cal-tbl") .
      sw:write-data-element ("table-version", string(p-table-version)).
      sw:write-data-element ("tank-code", string(p-tank-code)).
      sw:write-data-element ("status-date", iso-date(p-status-date)).
      sw:write-data-element ("status-time", string (p-status-time, "HH:MM:SS")).
      sw:write-data-element ("status", string(p-status_)).
    sw:end-element ("status-cal-tbl") .
  sw:end-document () .
end procedure .

procedure exp1C :
  run str/send1C-some-data.p (input ?,
                              input this-procedure,
                              input this-procedure,
                              input expData,
                              input "status-cal-tbls") 
                              no-error .
  if error-status:error
  then do :
    run write-to-log( "Ошибка при отправке в 1С. " + return-value ).
  end .
end procedure .

procedure write-to-log :
  define input param p-str as character no-undo .
  
  assign
    p-str = substitute( "&3&1&3&2&3", cur-time-string(), p-str, {&new-line} )
  .
  output to value(log-file-name) append .
  put unformatted p-str .
  output close .
  
end procedure .

procedure write-log-and-file :
  define input parameter p-tab-position   as integer   no-undo.
  define input parameter p-file-name      as character no-undo .
  define input parameter p-log-level      as integer   no-undo .
  define input parameter p-log-string     AS CHARacter NO-UNDO.
  define variable v-jj as integer   no-undo .
  run write-to-log (input p-log-string) .
end procedure .
