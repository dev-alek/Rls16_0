
/*------------------------------------------------------------------------
    File        : prep1C-shift-period.p
    Purpose     : 

    Syntax      :

    Description : Подготовка данных по контролю плотности НП по периодам и выгрузка в 1С

    Author(s)   : SlivenkoSA
    Created     : Mon Mar 24 15:32:47 MSK 2025
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

block-level on error undo, throw.

define temp-table tt-pl-gds no-undo
  field pl-code like ub.place.pl-code
  field loc1 like ub.place.loc1
  field gds-code like ub.goods.gds-code
  field num-pri-periods as integer
.

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-obj-type like ub.shift-obj.obj-type no-undo .
define input parameter p-obj-code like ub.shift-obj.obj-code no-undo .
define input parameter p-shift-date like ub.shift-obj.shift-date no-undo .
define input parameter p-shift-num like ub.shift-obj.shift-num no-undo .

define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }

define buffer buf_place for ub.place .
define buffer buf_shift-obj for ub.shift-obj .
define buffer buf_shift-period for ub.shift-period .

define variable expData as memptr no-undo .
define variable log-file-name as character no-undo initial "shift-period.log" .
define variable v-pid as int64 no-undo .

{ gbl/cur-time.i }

function string-mth returns character
  (inValue as decimal)
:
  
  def var v-str as character no-undo.
  def var v-stt as decimal   no-undo.
   
  if inValue = ?  then v-str = "0".
  if inValue < 0 then 
  do:
    v-stt = inValue .
    inValue = abs(v-stt).
  end.
  if string (inValue) begins "."
    then v-str = "0" + string (inValue).
  else v-str = string (inValue).
  if v-stt <> 0 then v-str = "-" + v-str.
  return v-str.
  
end.


/* ***************************  Main Block  *************************** */

find first buf_shift-obj no-lock where buf_shift-obj.obj-type = p-obj-type
                                   and buf_shift-obj.obj-code = p-obj-code
                                   and buf_shift-obj.shift-date = p-shift-date
                                   and buf_shift-obj.shift-num = p-shift-num
                                   no-error .
if not available buf_shift-obj
then do :
  return .
end .

for each buf_shift-period no-lock where buf_shift-period.obj-type = buf_shift-obj.obj-type
                                    and buf_shift-period.obj-code = buf_shift-obj.obj-code
                                    and buf_shift-period.shift-date = buf_shift-obj.shift-date
                                    and buf_shift-period.shift-num = buf_shift-obj.shift-num,
  first buf_place no-lock where buf_place.pl-code = buf_shift-period.pl-code
:
  find first tt-pl-gds where tt-pl-gds.pl-code = buf_shift-period.pl-code 
                         and tt-pl-gds.gds-code = buf_shift-period.gds-code
                         no-error .
  if not available tt-pl-gds
  then do :
    create tt-pl-gds .
    assign
      tt-pl-gds.pl-code = buf_shift-period.pl-code
      tt-pl-gds.loc1 = buf_place.loc1
      tt-pl-gds.gds-code = buf_shift-period.gds-code
      tt-pl-gds.num-pri-periods = 0
    .
  end .
  if buf_shift-period.period-type = 4
  then do :
    assign tt-pl-gds.num-pri-periods = tt-pl-gds.num-pri-periods + 1 .
  end .
end .

run create-esys-data .
run exp1C .

procedure create-esys-data :
  define variable sw as handle no-undo.
  define variable ii as integer no-undo .
  define variable v-num-pri-periods as integer no-undo .
  define variable v-period as character no-undo .
  define variable v-doc-code as character no-undo .
  
  create sax-writer sw.
  sw:set-output-destination ("memptr", expData).
  sw:encoding = "UTF-8".
  sw:fragment = true .
  sw:formatted = true .
  sw:start-document () .
    sw:start-element ("shift-period") .
      sw:write-data-element ("shift-date", iso-date(buf_shift-obj.shift-date)).
      sw:write-data-element ("shift-num", string(buf_shift-obj.shift-num)).
      sw:start-element ("tanks") .
        for each tt-pl-gds :
          assign v-num-pri-periods = 0 .
          sw:start-element ("tank") .
            sw:write-data-element ("tank-num", string(tt-pl-gds.loc1)) .
            sw:write-data-element ("gd-code", string(tt-pl-gds.gds-code)) .
            sw:start-element ("section-periods") .
              for each buf_shift-period no-lock where buf_shift-period.obj-type = buf_shift-obj.obj-type
                                                  and buf_shift-period.obj-code = buf_shift-obj.obj-code
                                                  and buf_shift-period.shift-date = buf_shift-obj.shift-date
                                                  and buf_shift-period.shift-num = buf_shift-obj.shift-num
                                                  and buf_shift-period.gds-code = tt-pl-gds.gds-code
                                                  and buf_shift-period.pl-code = tt-pl-gds.pl-code
                                                  by buf_shift-period.period-num
              :
                sw:start-element ("section-period") .
                  assign v-period = string(buf_shift-period.period-type) .
                  if buf_shift-period.period-type = 4
                  and tt-pl-gds.num-pri-periods > 1
                  then do :
                    assign
                      v-num-pri-periods = v-num-pri-periods + 1
                      v-period = string(buf_shift-period.period-type) + "." + string(v-num-pri-periods)
                    .
                  end .
                  sw:write-data-element ("period", v-period) .
                  if buf_shift-period.period-type = 0
                  or buf_shift-period.period-type = 1
                  then do :
                    sw:write-data-element ("initializ", string(1)) .
                  end .
                  if buf_shift-period.period-type = 1
                  or buf_shift-period.period-type = 3
                  then do :
                    assign
                      v-doc-code = entry(2, buf_shift-period.period-name, "№")
                      v-doc-code = entry(1, v-doc-code, ")")
                    .
                    sw:write-data-element ("before-invoice", v-doc-code) .
                  end .
                  if buf_shift-period.period-type = 4
                  then do :
                    assign
                      v-doc-code = entry(2, buf_shift-period.period-name, "№")
                      v-doc-code = entry(1, v-doc-code, ")")
                    .
                    sw:write-data-element ("from-invoice", v-doc-code) .
                    assign
                      v-doc-code = entry(3, buf_shift-period.period-name, "№")
                      v-doc-code = entry(1, v-doc-code, ")")
                    .
                    sw:write-data-element ("before-invoice", v-doc-code) .
                  end .
                  if buf_shift-period.period-type = 5
                  then do :
                    assign
                      v-doc-code = entry(2, buf_shift-period.period-name, "№")
                      v-doc-code = entry(1, v-doc-code, ")")
                    .
                    sw:write-data-element ("from-invoice", v-doc-code) .
                  end .
                  sw:write-data-element ("contrl-dnst", string-mth(round(buf_shift-period.control-density, 4))) .
                  sw:write-data-element ("implem15-dnst", string-mth(round(buf_shift-period.sales-density15, 4))) .
                  sw:write-data-element ("delta-dnst", string-mth(round(buf_shift-period.delta-density, 4))) .
                sw:end-element ("section-period") .
              end .
            sw:end-element ("section-periods") .
          sw:end-element ("tank") .
        end .
      sw:end-element ("tanks") .
    sw:end-element ("shift-period") .
  sw:end-document () .
end procedure .

procedure exp1C :
  run str/send1C-some-data.p (input parparentproc,
                              input this-procedure,
                              input this-procedure,
                              input expData,
                              input "shift-periods" + {&delim-par} + substitute("shift-obj&1&2",{&delim-key},string(rowid(buf_shift-obj))) ) 
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
