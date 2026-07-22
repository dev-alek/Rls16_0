define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input parameter p-caller as character no-undo .
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
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Автоматизированное формирование списка разнообразнейших бар-кодов".
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
define new shared variable body-handle as handle no-undo.
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
DEFine new shared VARiable RS-list-method AS CHARACTER.
define variable lns-ignore as integer no-undo .
define variable v-seq as integer no-undo .
define variable v-no-hist as integer no-undo init -1.
define variable lns-cnt as integer no-undo .
define variable v-num-add          as integer no-undo .
define variable v-num-ignored      as integer no-undo .
define variable v-no-obj as logical no-undo .
define variable v-rid-list as character no-undo .
define variable g#report-num as integer no-undo .
define buffer buf_clients for ub.clients.
define variable v-user-select as logical no-undo .
define variable v-sel-obj-type like ub.clients.obj-type no-undo .
define variable v-sel-obj-code like ub.clients.obj-code no-undo .
define buffer buf_user-obj for ub.user-obj.
define variable varscales-pref as character no-undo .
define variable varpgscales-pref as character no-undo .
define variable v-notcd as logical no-undo init yes.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def shared temp-table scnblist no-undo like ub.goods
  field b-code as integer
  field b-str  as character
  field f-name like ub.gds-prt.f-name
  field bc-cli-base-rate like ub.bar-code.cli-base-rate
  field bc-cr-db-num     like ub.bar-code.cr-db-num
  field in-code       like ub.bar-code.in-code
  field node-code     like ub.bar-code.node-code
  field part-code     like ub.bar-code.part-code
  field stts_         like ub.bar-code.stts_
  field bc-unit-cli      like ub.bar-code.unit-cli
  field bc-on-type    like ub.prod-bc.bc-on-type
  field bc-on         like ub.prod-bc.bc-on
  field pbc-cr-db-num     like ub.prod-bc.cr-db-num
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field loc-ean as logical
  index pi  is primary unique b-code b-str
  index art artic prod-type prod-code
  index code gds-code
  index oi order-num
  index ibc-on-type bc-on-type
  index iprt
  gds-code
  node-code
  part-code
  in-code
  unit-cli
  b-str
  index iprt2
  gds-code
  node-code
  unit-cli
  part-code
  in-code
  b-str
  .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared  temp-table scnblist-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table gds-list no-undo like ub.goods
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field promo-code as character
  field ActionId  as int64
  field db-num as integer
  index art  is primary unique artic prod-type prod-code
  index code is         unique gds-code
  index oi order-num
  index isel to-sel
  .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table gds-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
def new shared var bc-frmt as character no-undo .
def new shared var bc-pfx  as character no-undo .
def var bc-par-type as character no-undo .
    run gbl/conf-rd.p ("bc-frmt", "", "", 0, "", "", "",  no , output bc-frmt, output bc-par-type) no-error.
    if "new" = "bc" AND ( error-status:error OR bc-par-type <> "C":U OR not can-do ("EAN8,EAN13", bc-frmt) ) then
        do:
            message "Не задан или не верно задан ТИП собственного бар-кода!"
                view-as alert-box ERROR TITLE "".
            return error.
        end.
    run gbl/conf-rd.p ("bc-pfx", "", "", 0, "", "", "",  no , output bc-pfx, output bc-par-type) no-error.
    if "new" = "bc" AND ( error-status:error OR bc-par-type <> "C":U ) then
        do:
            message "Не задан или не верно задан ПРЕФИКС бар-кода складского места!"
                view-as alert-box ERROR TITLE "".
            return error.
        end.
PROCEDURE gen-bc:
  def input  parameter internal-b-code like ub.bar-code.b-code no-undo .
  def output parameter full-b-code     as character init ""    no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable tmp-str4  as character no-undo.
  define variable tmp-num4  as character no-undo.
  define variable i4        as integer   no-undo.
  define variable sum4      as integer   no-undo.
  define variable len-code4 as integer   no-undo.
  define variable varcont4  as logical   initial yes no-undo.
  CASE bc-frmt :
    WHEN "EAN13" THEN do:
      assign
        tmp-str4 = string( internal-b-code, "999999999999" )
      .
    end.
    WHEN "EAN8" THEN do:
      assign
        tmp-str4 = string( internal-b-code, "9999999" )
      .
    end.
    OTHERWISE DO:
        message "Неизвестный тип генерации бар-кода процедурой bc-gnrti.i: " bc-frmt " ."
        view-as alert-box error.
        return error.
    END.
  END CASE.
  if varcont4 = yes then do:
    if integer( substring( tmp-str4, 1, length( bc-pfx ) ) ) <> 0
    then do:
      message
        "Невозможно сформировать бар-код" SKIP
        "для товара с кодом: " internal-b-code
        view-as alert-box error title "подрезание кода".
      return error.
    end.
    else do:
      assign
        full-b-code = bc-pfx + substring( tmp-str4, length( bc-pfx ) + 1, length( tmp-str4 ) - length( bc-pfx ) )
        len-code4    = length( full-b-code )
      .
      define variable v-sum-char4 as character no-undo .
      assign
        sum4 = 0
      .
      do i4 = 1 to len-code4 by 2
      :
        assign
          v-sum-char4 = substr(full-b-code, len-code4 - i4 + 1, 1)
        .
        if v-sum-char4 < "0"
        or v-sum-char4 > "9"
        then do:
          message
            "Невозможно сформировать бар-код" skip
            "для товара с кодом: " internal-b-code skip
            view-as alert-box error title "подсчет контрольной суммы".
          return error.
        end.
        assign
          sum4 = sum4 + integer(v-sum-char4)
        .
      end.
      if varcont4 = yes then do:
        assign
          sum4 = sum4 * 3
        .
        do i4 = 2 to len-code4 by 2
        :
          assign
            v-sum-char4 = substr(full-b-code, len-code4 - i4 + 1, 1)
          .
          if v-sum-char4 < "0"
          or v-sum-char4 > "9"
          then do:
            message
              "Невозможно сформировать бар-код" skip
              "для товара с кодом: " internal-b-code skip
              view-as alert-box error title "подсчет контрольной суммы".
            return error.
          end.
          assign
            sum4 = sum4 + integer(v-sum-char4)
          .
        end.
        if varcont4 = yes then do:
           if sum4 mod 10 = 0 then do:
             assign
               full-b-code = full-b-code + '0'
             .
           end.
           else do:
             assign
               full-b-code = full-b-code + string(10 - sum4 mod 10)
             .
           end.
        end.
      end.
    end.
  end.
END PROCEDURE.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-key-rec :
  define input  parameter p-tbl-name    as character no-undo.
  define input  parameter p-bh_tbl-name as handle    no-undo.
  define output parameter p-key-rec     as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-rec). endkey", vss-workfile )
  :
    define variable fh               as handle    no-undo .
    define variable v-ok             as logical   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    if p-tbl-name = ?
      or p-tbl-name = "":U
    then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info6 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info6, p-tbl-name ).
    end.
    assign
      p-key-rec = p-tbl-name
      v-inform  = p-bh_tbl-name:index-information(1)
      v-ind     = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = p-bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info6, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info6, v-inform, p-tbl-name ).
      end.
      do v-ind = 1 to v-idx-field-qnty by 2
      on error undo, return error
      :
        assign
          fh = p-bh_tbl-name:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) ).
          p-key-rec = p-key-rec + chr(3) + substitute("&1", replace(fh:buffer-value(),chr(3),chr(2) + chr(9) + chr (2)))
        .
      end.
    end.
    if p-key-rec = ? then do:
      assign
        p-key-rec = "":U
      .
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info6, p-tbl-name ).
    end.
  end.
  return.
end procedure.
procedure gen-where-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character  no-undo.
  define input  parameter p-key-rec    as character  no-undo.
  define input  parameter p-key-handle as handle     no-undo .
  define input  parameter p-db-name    as character  no-undo .
  define input  parameter p-tt-handle  as handle     no-undo .
  define output parameter o-Where      as character  no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable fh_key           as handle    no-undo .
    define variable fh_search        as handle    no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-field-name     as character no-undo .
    define variable v-field-val      as character no-undo .
    define variable v-word-link      as character no-undo .
    define variable vTable           as character no-undo.
    define variable bh_tbl-key       as handle    no-undo .
    assign
      p-key-rec = trim( p-key-rec )
    .
    if p-key-handle <> ? then do:
      if not valid-handle(p-key-handle)
         or p-key-handle:type <> "buffer"
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info6 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info6, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info6 ).
      end.
    end.
    assign
      vTable = entry( 1 , p-key-rec, chr(3) )
    .
    if p-tt-handle <> ?
      and ( not valid-handle(p-tt-handle)
            or p-tt-handle:type <> "buffer"
          )
    then do:
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info6, vTable, chr(10) ).
    end.
    if p-tt-handle = ? then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    else do:
      create buffer bh_tbl-name for table p-tt-handle:table-handle .
    end.
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info6, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info6, v-inform, vTable ).
    end.
    assign
      o-where     = "where":U
      v-word-link = "":U
      v-field-num = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld = 0
    .
    if i-tablekey ne "" and i-tablekey ne ?
    then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tablekey )
      .
      create buffer bh_tbl-key for table v-full-tbl-name .
    end.
    if i-tableSerach ne "" and i-tableSerach ne ?
    then do:
      delete object bh_tbl-name no-error.
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if p-key-handle = ?
        and v-count-fld > v-field-num
      then do:
        leave block_where.
      end.
      define variable VfieldKeyTable as handle no-undo.
      assign
        v-field-name = entry( 4 + v-ind, v-inform, ",":U )
        fh_search    = bh_tbl-name:buffer-field( v-field-name )
      .
      if     bh_tbl-key ne ?
      then do:
         VfieldKeyTable = bh_tbl-key:buffer-field( v-field-name ) no-error.
         if VfieldKeyTable eq ?
         then next block_where.
      end.
      if v-full-tbl-name ne "" and v-full-tbl-name ne ?
      then
         o-where = substitute( "&1 &2 &3.&4 =", o-where, v-word-link,v-full-tbl-name, v-field-name ).
      else
         o-where = substitute( "&1 &2 &3 =", o-where, v-word-link, v-field-name ).
      if p-key-handle = ? then do:
        assign
          v-field-val = replace (entry( v-count-fld + 1 , p-key-rec, chr(3) ),chr(2) + chr(9) + chr (2),chr(3))
        .
      end.
      else do:
        assign
          fh_key = p-key-handle:buffer-field( v-field-name )
        .
        if fh_key = ?
          or not valid-handle( fh_key )
        then do:
          delete object bh_tbl-name.
          if     bh_tbl-key ne ?
          then
             delete object bh_tbl-key.
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info6, p-key-handle:name, v-field-name ).
        end.
        assign
          v-field-val = fh_key:buffer-value
        .
      end.
      if fh_search:data-type ="character":U then do:
        assign
          v-field-val = replace( v-field-val, '~~':U, '~~~~':U )
          v-field-val = replace( v-field-val, '"':U, '~~"':U )
          v-field-val = replace( v-field-val, "'":U, "~~'":U )
          v-field-val = replace( v-field-val, '~{':U, '~~~{':U )
          v-field-val = replace( v-field-val, '~}':U, '~~~}':U )
          v-field-val = replace( v-field-val, '~\':U, '~~~\':U )
          v-field-val = replace( v-field-val, chr(10), '~~n':U )
          v-field-val = replace( v-field-val, chr(9), '~~t':U )
          v-field-val = replace( v-field-val, chr(13), '~~r':U )
          v-field-val = replace( v-field-val, chr(27), '~~E':U )
          v-field-val = replace( v-field-val, chr(8), '~~b':U )
          v-field-val = replace( v-field-val, chr(12), '~~f':U )
          v-field-val = substitute( '"&1"', v-field-val )
        .
      end.
      assign
        o-where = substitute( "&1 &2", o-where, v-field-val )
      .
      if v-word-link = "":U then do:
        assign
          v-word-link = "and":U
        .
      end.
    end.
    delete object bh_tbl-name.
    if     bh_tbl-key ne ?
    then
       delete object bh_tbl-key.
    if p-key-handle = ?
      and v-count-fld <> v-field-num
    then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info6, vTable ).
    end.
  end.
end procedure.
procedure gen-hn-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character no-undo.
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  define variable v-full-tbl-name as character no-undo.
  define variable v-where         as character no-undo.
  define variable bh_tbl-name     as handle    no-undo.
  define variable vTable          as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile ):
      run gen-where-keyr-tab(i-tableSerach,
                             i-tablekey,
                             p-key-rec,
                             p-key-handle,
                             p-db-name,
                             p-tt-handle,
                             output v-where).
      if i-tableSerach ne "" and i-tableSerach ne ?
      then do:
         v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach ).
         create buffer bh_tbl-name for table v-full-tbl-name .
      end.
      else do:
         if p-tt-handle = ? then do:
            assign
               vTable = entry( 1 , p-key-rec, chr(3) )
            .
            v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable ).
            create buffer bh_tbl-name for table v-full-tbl-name .
         end.
         else do:
            create buffer bh_tbl-name for table p-tt-handle:table-handle .
         end.
      end.
      if p-tt-handle = ? then do:
         bh_tbl-name:find-first( v-where, p-stts-lock ) no-error .
      end.
      else do:
         bh_tbl-name:find-first( v-where ) no-error .
      end.
      o-hn = bh_tbl-name.
   end.
end procedure.
procedure gen-hn-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output o-hn).
end.
procedure gen-row-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter p-tbl-row    as rowid     no-undo.
  define output parameter p-tbl-name   as character no-undo.
  define variable vHn as handle no-undo.
    run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output vHn).
    p-tbl-row = if vHn:available then vHn:rowid else ?.
    p-tbl-name =  vHn:table.
    delete object vHn no-error.
  if p-tbl-row = ? then do:
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info6, p-tbl-name, p-key-rec ).
  end.
  else do:
    return.
  end.
end procedure.
procedure gen-key-fv :
  define input  parameter p-key-rec    as character no-undo .
  define output parameter p-field-list as character no-undo .
  define output parameter p-value-list as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info6 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info6 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info6, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info6, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      p-value-list = "":U
      v-delim-key  = "":U
      v-field-num  = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.
      assign
        p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U )
        p-value-list = p-value-list + v-delim-key + entry( v-count-fld + 1 , p-key-rec, chr(3) )
      .
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info6, v-tbl-name ).
    end.
  end.
end procedure.
procedure gen-key-field :
  define input  parameter p-table      as character no-undo .
  define output parameter p-field-list as character no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-table = ?
      or p-table = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info6 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info6 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info6, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info6, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      v-delim-key  = "":U
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U ).
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
  end.
end procedure.
procedure create-scnblist-hist :
define input parameter p-mode as character no-undo .
define input-output parameter p-seq as integer no-undo .
define input parameter p-line as integer no-undo .
define variable p-list-table as character no-undo .
define input parameter p-hist-mode as character no-undo .
define input parameter p-des as character no-undo .
define input parameter p-num-recs as integer no-undo .
define input parameter p-option as character no-undo .
define input parameter p-status_ as character no-undo .
define input parameter p-item as character no-undo .
define input parameter p-tbl-name as character no-undo .
define input parameter p-bh_tbl-name as handle no-undo .
define variable v-num-add as integer no-undo .
define variable v-num-ignored as integer no-undo .
define buffer buf_scnblist-hist for scnblist-hist.
  do
  on error undo, return error
  :
    CASE p-mode:
      when 'title' then do:
        find first buf_scnblist-hist where
                   buf_scnblist-hist.id = 0   no-error.
        if not available buf_scnblist-hist then do:
          create buf_scnblist-hist.
          assign
          buf_scnblist-hist.id = 0
          buf_scnblist-hist.line = 0
          buf_scnblist-hist.list-table = '':U
          .
        end.
        assign
        buf_scnblist-hist.des =  p-des
        buf_scnblist-hist.num-recs = p-num-recs
        buf_scnblist-hist.option_  = p-option
        buf_scnblist-hist.item_ = p-item
        .
      end.
      when 'ДОБАВЛЕНИЕ':U then do:
        if p-option begins 'single' then do:
          CASE p-hist-mode:
            when '+':U then do:
              assign
              v-num-add = 1
              v-num-ignored  = 0
              .
            end.
            when '-':U then do:
              assign
              v-num-add = 1
              v-num-ignored  = 0
              .
            end.
            when '*':U then do:
              assign
              v-num-add = p-num-recs - 1
              p-num-recs = 1
              v-num-ignored  = 0
              .
            end.
          END CASE.
        end.
        create buf_scnblist-hist.
        assign
        buf_scnblist-hist.id = p-seq
        buf_scnblist-hist.list-table = p-list-table
         p-seq = (if p-line = 0 then (p-seq + 1) else p-seq)
        buf_scnblist-hist.des =  p-des
        buf_scnblist-hist.line = p-line
        buf_scnblist-hist.num-recs = p-num-recs
        buf_scnblist-hist.option_  = p-option
        buf_scnblist-hist.item_ = p-item
        buf_scnblist-hist.hist-mode =  p-hist-mode
        buf_scnblist-hist.status_ =  p-status_
        buf_scnblist-hist.num-add = v-num-add
        buf_scnblist-hist.num-ignored = v-num-ignored
        .
      end.
      when 'ИЗМЕНЕНИЕ':U + chr(4) + 'des' then do:
        find first buf_scnblist-hist where
                  buf_scnblist-hist.id = p-seq
              and buf_scnblist-hist.line = p-line no-error .
        if  available buf_scnblist-hist then do:
          assign
          buf_scnblist-hist.des =  p-des
          buf_scnblist-hist.num-recs = p-num-recs
          buf_scnblist-hist.option_  = p-option
          buf_scnblist-hist.item_ = p-item
          buf_scnblist-hist.list-table = (if p-list-table <> '':U and p-list-table <> ?
                                     then p-list-table
                                     else buf_scnblist-hist.list-table)
          .
        end.
      end.
      when 'ИЗМЕНЕНИЕ':U + chr(4) + 'mode' then do:
        find first buf_scnblist-hist where
                  buf_scnblist-hist.id = p-seq
              and buf_scnblist-hist.line = p-line  no-error .
        if available buf_scnblist-hist then do:
          assign
          buf_scnblist-hist.hist-mode =  p-hist-mode
          buf_scnblist-hist.num-recs  = (if buf_scnblist-hist.line = 0 then p-num-recs else buf_scnblist-hist.num-recs)
          buf_scnblist-hist.list-table = (if p-list-table <> '':U and p-list-table <> ?
                                     then p-list-table
                                     else buf_scnblist-hist.list-table)
          .
        end.
      end.
    END CASE.
    if p-tbl-name <> "":U
    and valid-handle(p-bh_tbl-name)
    then do:
      run gen-key-rec  in this-procedure (
                                            input  p-tbl-name
                                           ,input  p-bh_tbl-name
                                           ,output p-item) no-error .
      if not error-status:error then do:
        assign
        buf_scnblist-hist.item_ = p-item
        .
      end.
      else do:
        assign
        buf_scnblist-hist.item_ = "!ERROR"
        .
      end.
    end.
  end.
end procedure.
FUNCTION get-line-mode returns character(input p-hist-mode as character):
case p-hist-mode:
  when '+':U then
    return  'ДОБАВЛЕНИЕ':U.
  when '-':U then
    return  'удаление':U.
  when '*':U then
    return  'ОСТАВИТЬ':U.
end CASE.
END FUNCTION.
FUNCTION get-hist-mode returns character(input p-line-mode as character):
case p-line-mode:
  when 'ДОБАВЛЕНИЕ':U then
    return  "+".
  when 'удаление':U then
    return  "-".
  when 'ОСТАВИТЬ':U then
    return  "*".
end CASE.
END FUNCTION.
procedure proc-write-filter-expression :
define input parameter p-filter-expression as character no-undo .
define variable v-ii as integer no-undo .
output to value(string(g#report-num) + ".whr").
put .
if num-entries(p-filter-expression) > 0 then do:
   put unformatted 'and ('.
   do v-ii = 1 to num-entries(p-filter-expression):
     put unformatted entry(v-ii, p-filter-expression) skip.
   end.
   put unformatted ')'.
end.
output close.
end procedure.
procedure proc-write-filter-expression-var :
define input parameter p-filter-expression as character no-undo .
define output parameter p-string as character no-undo .
define variable v-ii as integer no-undo .
if num-entries(p-filter-expression) > 0 then do:
   p-string = 'and ('.
   do v-ii = 1 to num-entries(p-filter-expression):
     p-string = p-string + entry(v-ii, p-filter-expression) + chr(10).
   end.
   p-string = p-string + ')'.
end.
end procedure.
define new global shared variable g#libbcrcn as handle no-undo .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-waitfram-action01         as character   no-undo .
define variable v-waitfram-action02         as character   no-undo .
define variable v-waitfram-action03         as character   no-undo .
define variable mWaitFramTextBeg            as character   no-undo.
define variable mWaitFramTextEnd            as character   no-undo.
define variable mWaitFramView               as logical     no-undo.
define variable mWaitProcEvent              as logical     no-undo init yes.
define variable mWaitFramInterval           as integer     no-undo init 1 .
define variable mWaitFramStop               as logical     no-undo.
define variable mWaitFramStopUser           as logical     no-undo.
define variable mWaitFramStopTimeOut        as logical     no-undo.
define variable mWaitFramStartProc          as datetime-tz no-undo.
define variable mWaitFramTimeOut            as decimal     no-undo init ?.
define button B-WaitFramStop auto-end-key
     label "Стоп"
     size 10 by 1 tooltip "Остоновить процесс".
define button B-viewProcInfo
     label "Информация"
     size 15 by 1 tooltip "Информация о процесс".
define frame waitfram
  v-waitfram-action01 format "x(72)" no-label skip
  v-waitfram-action02 format "x(72)" no-label skip
  v-waitfram-action03 format "x(72)" no-label skip
  B-viewProcInfo
  B-WaitFramStop at row 4 col 30
  with view-as dialog-box side-labels three-d cancel-button B-WaitFramStop
  .
define new global shared variable mBatchMode as logical no-undo init ?.
define variable mFramBachModHandle as handle no-undo.
mFramBachModHandle = frame waitfram:handle.
define variable mFameOldVis as logical no-undo.
define variable mVisCUrentVin as logical no-undo.
if session:batch-mode
then
   mBatchMode = yes.
if mBatchMode = ? then do:
  mVisCUrentVin = current-window:visible.
  mFameOldVis = mFramBachModHandle:visible.
  mFramBachModHandle:visible  = yes.
  mBatchMode = mFramBachModHandle:visible ne yes.
  mFramBachModHandle:visible = mFameOldVis.
  current-window:visible = mVisCUrentVin.
end.
 if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramBachModHandle:visible), "frameRepError").
  end.
on choose of B-WaitFramStop in frame waitfram
do:
  mWaitFramStop = yes.
  mWaitFramStopUser = yes.
end.
function waitfram-check-timeout returns logical():
   define variable vtime as int64 no-undo.
   if mWaitFramStopTimeOut
   then
      return yes.
   vtime = ( now - mWaitFramStartProc ) / 1000 .
   if     mWaitFramTimeOut ne ?
      and mWaitFramTimeOut ne 0
      and mWaitFramTimeOut lt vtime
   then do:
      mWaitFramStopTimeOut = yes.
   end.
   return mWaitFramStopTimeOut.
end.
procedure waitfram-hide :
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    pause 0 before-hide .
    if not mBatchMode then
      hide frame waitfram .
  if     not mWaitFramView
     and mWaitProcEvent
  then
    process events .
  end.
end procedure.
procedure waitfram-show :
  define input  parameter p-message as character no-undo .
  define variable v-left-margin as integer   no-undo .
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    if length(p-message) <= 70 then do:
      assign
        v-left-margin = integer((70 - length(p-message)) / 2)
      .
      assign
        v-left-margin = max(0, v-left-margin - (v-left-margin mod 5))
      .
      assign
        v-waitfram-action01 = " "
        v-waitfram-action02 = " "
                                 + fill(" ", v-left-margin)
                                 + p-message
        v-waitfram-action03 = " "
      .
    end.
    else do:
      define variable vRindex1 as integer no-undo.
      define variable vRindex2 as integer no-undo.
      vRindex1 = r-index(p-message," ",70).
      if vRindex1 = 0
      then
         vRindex1 = 70.
      if length(p-message)  <= vRindex1 + 70 then do:
        assign
          v-waitfram-action01 = " "
          v-waitfram-action02 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action03 = " " + substring(p-message,  vRindex1 + 1, 70      )
        .
      end.
      else do:
        vRindex2 = r-index(p-message," ",vRindex1 + 70).
        if vRindex2 <= vRindex1
        then
           vRindex2 = vRindex1 + 70.
        assign
          v-waitfram-action01 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action02 = " " + substring(p-message,  vRindex1 + 1, vRindex2 - vRindex1 )
          v-waitfram-action03 = " " + substring(p-message,  vRindex2 + 1, 70)
        .
      end.
    end.
    B-viewProcInfo:visible   in frame waitfram = no.
    B-viewProcInfo:sensitive in frame waitfram = no.
    B-WaitFramStop:visible   in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    B-WaitFramStop:sensitive in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    if  (   mWaitFramView
       or  mWaitProcEvent)
       and not mBatchMode
    then
       display
          v-waitfram-action01 skip
          v-waitfram-action02 skip
          v-waitfram-action03 skip
       with frame waitfram .
    if     mWaitFramView
       then do:
          if     mWaitFramInterval ne ?
             and not mBatchMode
          then
             wait-for go of frame waitfram pause mWaitFramInterval.
       end.
       else
          if     mWaitProcEvent
             and not mBatchMode
          then
             process events .
  end.
end procedure.
   procedure waitfram-show-this:
      define input  parameter iInterval as int64 no-undo.
      define variable vtime as int64 no-undo.
      vtime = ( now - mWaitFramStartProc  ) / 1000 .
      mWaitFramInterval = iInterval.
      run waitfram-show (substitute("&1&2 &3&4" ,
                                    mWaitFramTextBeg ,
                                    if vtime eq ? then "" else substitute (" Прошло: &1 сек" , string( vtime)),
                                    if mWaitFramTimeOut ne 0 and mWaitFramTimeOut ne ? then " из " + string(mWaitFramTimeOut) + " сек. " else "",
                                    mWaitFramTextEnd
                                   )
                        ).
   end.
   procedure WaitFramRunPause:
      define input  parameter iInterval as dec no-undo.
      define variable vStart  as datetime-tz no-undo.
      define variable vend    as datetime-tz no-undo.
      define variable vint as int64 no-undo.
      define variable vOk as logical no-undo.
      vStart = now.
      vend   = vStart.
      publish "WaitFramPause" (iInterval,output vOk).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and (   vint > 0
              or (    not vOk
                  and iInterval eq ?
                  )
              )
      then
         run waitfram-show-this (iInterval).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and vint > 0
      then do:
         run gbl/pause.p (vint * 1000).
      end.
      if iInterval ne ?
      then
         publish "WaitFramStop".
      waitfram-check-timeout().
   end.
   procedure WaitFramWaitFor:
      define input  parameter iInterval as dec no-undo.
      assign
         mWaitFramStartProc   = now
         mWaitFramStopUser    = no
         mWaitFramStopTimeOut = no
      .
      block-wait:
      do while not mWaitFramStop:
         run WaitFramRunPause (iInterval).
         if  waitfram-check-timeout()
         then do:
            leave block-wait.
         end.
      end.
      run waitfram-hide.
   end.
procedure waitfram-join :
  define input  parameter p-line-1  as character no-undo .
  define input  parameter p-line-2  as character no-undo .
  define input  parameter p-line-3  as character no-undo .
  define output parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-message = substring(p-line-1 + fill(' ', 70), 1, 70)
                + substring(p-line-2 + fill(' ', 70), 1, 70)
                + substring(p-line-3 + fill(' ', 70), 1, 70)
    .
  end.
end procedure.
function waitfram-join-function returns character
  (input p-line-1 as character
  ,input p-line-2 as character
  ,input p-line-3 as character
  ).
  define variable v-message as character no-undo .
  run waitfram-join in this-procedure
    (input  p-line-1
    ,input  p-line-2
    ,input  p-line-3
    ,output v-message
    ) .
  return v-message .
end function .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cur-time :
   define output parameter p-today as date      no-undo .
   define output parameter p-time  as integer   no-undo .
  do
  on error undo, return error
  :
    define variable v-date1 as date      no-undo .
    define variable v-date2 as date      no-undo .
    define variable v-time  as integer   no-undo .
    assign
      v-date1 = today
      v-time  = time
      v-date2 = today
    .
    if v-date1 <> v-date2
    then do:
      assign
        v-date1 = today
        v-time  = v-time
      .
    end.
    assign
      p-today = v-date1
      p-time  = v-time
    .
  end.
end.
function cur-time-date returns character
:
  return string(today, '99/99/9999':U) .
end.
function cur-time-mjd returns decimal
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return integer(v-date) - 2400002 + (v-time / 86400) .
end.
function cur-time-get-ending-index returns integer
(input p-number as integer
)
:
  if p-number < 0
  or p-number = ?
  then do:
    return 1 .
  end.
  define variable v-rest as integer   no-undo .
  assign
    p-number = p-number modulo 100
  .
  if p-number < 20
  then do:
    assign
      v-rest = p-number
    .
  end.
  else do:
    assign
      v-rest = p-number modulo 10
    .
  end.
  case v-rest :
    when 1
    then do:
      return 2 .
    end.
    when 2 or
    when 3 or
    when 4
    then do:
      return 3 .
    end.
    otherwise do:
      return 1 .
    end.
  end case .
end.
procedure cur-time-mjd-to-date :
   define input  parameter i-mjd-diff as decimal no-undo.
   define output parameter o-Date     as date    no-undo.
   define output parameter o-Time     as integer no-undo.
   define variable v-day-number as integer   no-undo .
   if    i-mjd-diff < 0
      or i-mjd-diff = ?
   then do:
      return "?" .
   end.
   assign
      v-day-number = truncate(i-mjd-diff,0).
      o-Date = date(v-day-number + 2400002).
      o-Time = truncate((i-mjd-diff - v-day-number) * 86400, 0)
  .
end.
function cur-time-mjd-to-string returns character
(input p-mjd-diff as decimal
)
:
  define variable v-day-number as integer   no-undo .
  define variable v-seconds    as integer   no-undo .
  define variable v-hour       as integer   no-undo .
  define variable v-min        as integer   no-undo .
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дня" ] .
  define variable v-hour-name   as character no-undo extent 3 initial [  "часов",     "час",    "часа" ] .
  define variable v-min-name    as character no-undo extent 3 initial [  "минут",  "минута",  "минуты" ] .
  define variable v-second-name as character no-undo extent 3 initial [ "секунд", "секунда", "секунды" ] .
  if p-mjd-diff < 0
  or p-mjd-diff = ?
  then do:
    return "?" .
  end.
  assign
    v-day-number = integer(truncate(p-mjd-diff,0))
    v-seconds    = truncate((p-mjd-diff - v-day-number) * 86400, 0)
  .
  if v-seconds > 86400
  then do:
    assign
      v-seconds = 86400 - 1
    .
  end.
  if v-seconds < 0
  then do:
    assign
      v-seconds = 0
    .
  end.
  assign
    v-hour = truncate(v-seconds / 3600, 0)
  .
  assign
    v-seconds = v-seconds modulo 3600
  .
  assign
    v-min = truncate(v-seconds / 60, 0)
  .
  assign
    v-seconds = v-seconds modulo 60
  .
  return
      (if v-day-number <> 0
        then string(v-day-number) + " " + v-day-name[cur-time-get-ending-index(v-day-number)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0
        then string(v-hour) + " " + v-hour-name[cur-time-get-ending-index(v-hour)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0 or v-min <> 0
        then string(v-min) + " " + v-min-name[cur-time-get-ending-index(v-min)] + " "
        else ""
      )
    + string(v-seconds) + " " + v-second-name[cur-time-get-ending-index(v-seconds)]
    .
end.
function cur-time-string returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.
function cur-time-string-sec returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .
end.
function cur-time-custom  returns character
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return
    p-prefix
    + string(v-date, p-date-format)
    + p-delimiter
    + string(v-time, p-time-format)
    + p-suffix
    .
end.
function cur-time-print  returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
end.
function cur-time-datetime returns datetime
:
  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.
end.
function cur-time-string-msec returns character
:
  define variable v-date as datetime  no-undo .
  v-date = now.
  return string(v-date) .
end.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  stream PrnLibStream.
procedure prn-lib-prn-file :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-DIsabledoptions as integer no-undo .
  define variable v-report-name as character no-undo .
  define variable v-user-action as character no-undo .
  define variable v-printed     as logical   no-undo .
  define variable v-exist       as logical   no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run filenmln in g#library
  (input  v-report-name
  ,input  2
  ,output v-exist
  )  .
    if NOT v-exist then
    DO:
      Message
        "Нет заданий на печать ! "
        view-as alert-box .
      Return  .
    End.
    run gbl/prnfilen.w
      (input  ""
      ,input  p-DisabledOptions
      ,input  string(v-report-name )
      ,input  7
      ,output v-user-action
      ,output v-printed
      ) .
    if v-printed then
    do:
      return "YES" .
    end.
    else
    do:
      return "NO" .
    end.
  end.
end procedure.
procedure prn-lib-open-stream :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-page-size    as integer no-undo .
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-append       as logical no-undo .
  define variable v-report-name as character no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
    if p-is-stream then
    do:
      if p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
    if not p-is-stream then
    do:
      if p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
  end.
end procedure.
procedure prn-lib-open-exp :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-is-append    as logical no-undo .
  define output parameter p-ReportFileName as char init "report" no-undo.
  define output parameter p-process as logical no-undo .
  define variable glog as logical no-undo .
  do
    on error undo, return error
    :
    SYSTEM-DIALOG GET-FILE p-ReportFileName
      TITLE      "Укажите путь"
      FILTERS "Текстовый файл (*.txt)"   "*.txt"
      ASK-OVERWRITE
      CREATE-TEST-FILE
      SAVE-AS
      USE-FILENAME
      DEFAULT-EXTENSION "txt"
      UPDATE glog
      .
    if not glog then  return.
    p-ReportFileName = trim( string( p-ReportFileName ) ) .
    if p-is-stream then
    do:
      if p-is-append then
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    else
    do:
      if p-is-append then
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    p-process = yes.
  end.
end procedure.
procedure prn-lib-get-report-name :
  define input parameter parParentProc  as widget-handle no-undo.
  define output parameter p-report-name as character no-undo .
  p-report-name = ibs.th.gbl.gbl-inipar:prn-lib-get-report-name("rpt").
end procedure.
procedure prn-lib-reportviewer-report-name :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer-report-name(p-report-name-html) no-error.
end procedure.
procedure prn-lib-reportviewer :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  define input parameter p-param        as character no-undo .
  define variable v-excel           as character no-undo init 'TRUE' .
  define variable v-value-character as character no-undo .
  define variable v-value-integer   as character no-undo .
  define variable v-value-date      as date      no-undo .
  define variable v-value-decimal   as decimal   no-undo .
  define variable rep-excel         as logical   no-undo .
  define variable excel-string      as character no-undo .
  define variable v-param-type      as character no-undo .
  define variable v-tth             as handle    no-undo .
  run adm/shattri.p (
    input "get":U
    ,input  ""
    ,input  0
    ,input  'report-glob':U
    ,input  'rep-excel':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output rep-excel
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    )  .
  if rep-excel then v-excel = "TRUE" .
  else v-excel = "FALSE" .
  if p-param eq ""
  then
     p-param = "EXCEL:" + v-excel.
  else
     p-param = p-param + chr(4) + "EXCEL:" + v-excel .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer(p-report-name-html, p-param).
end procedure.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table t-f no-undo
field table-name as character
field field-name as character
field field-name-0 as character
field field-format as character
field field-type as character
field field-size as character
field field-size-min as character
field field-csize as character
field field-label as character
field field-clabel as character
field field-spr as character
field field-delim as character
field field-table-order as integer
field field-order as integer
index pi is unique primary
table-name
field-name
index iorder
field-order
index itorder
table-name
field-table-order
.
define  temp-table temp-shop no-undo
like ub.shop.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table userobjs_temp-user-obj no-undo
  field obj-type as character
  field obj-code as integer
  index xpk is primary unique obj-type obj-code
  .
procedure userobjs_clear :
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      delete buf_userobjs_temp-user-obj .
    end.
  end.
end .
procedure userobjs_object-count :
  define output parameter p-total-count as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    assign
      p-total-count = 0
    .
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      assign
        p-total-count = p-total-count + 1
      .
    end.
  end.
end.
procedure userobjs_append :
   define input  parameter p-obj-type as character no-undo .
   define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      where buf_userobjs_temp-user-obj.obj-type = p-obj-type
        and buf_userobjs_temp-user-obj.obj-code = p-obj-code
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      create buf_userobjs_temp-user-obj .
      assign
        buf_userobjs_temp-user-obj.obj-type = p-obj-type
        buf_userobjs_temp-user-obj.obj-code = p-obj-code
      .
    end.
  end.
end.
procedure userobjs_object-exist :
  define output parameter p-object-exist as logical   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      assign
        p-object-exist = false
      .
    end.
    else do:
      assign
        p-object-exist = true
      .
    end.
  end.
end.
procedure userobjs_transfer :
  define input  parameter p-callback-handle as handle no-undo .
  define variable vss-description as character no-undo init "userobjs_transfer: Передача списка объектов".
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    if valid-handle(p-callback-handle) <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Неизвестный указатель на процедуру" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-callback-handle :get-signature("userobjs_append") = ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        substitute("В процедуре &1 не найдена внутренняя процедура userobjs_append"
                  ,p-callback-handle :file-name
                  ) skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      run userobjs_append in p-callback-handle
        (input  buf_userobjs_temp-user-obj.obj-type
        ,input  buf_userobjs_temp-user-obj.obj-code
        ) .
    end.
  end.
end procedure.
procedure userobjs_select-one :
   define input  parameter parparentproc     as widget-handle no-undo .
   define input  parameter p-db-num          as integer   no-undo .
   define input  parameter p-user-id         as character no-undo .
   define input  parameter p-host-code-obj   as integer   no-undo .
   define input  parameter p-obj-type        as character no-undo .
   define input  parameter p-obj-code        as integer   no-undo .
   define output parameter p-user-select     as logical   no-undo .
   define output parameter p-select-obj-type as character no-undo .
   define output parameter p-select-obj-code as character no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel"
      ,output p-user-select
      ,output p-select-obj-type
      ,output p-select-obj-code
      ) .
  end.
end.
procedure userobjs_select-many :
  define input  parameter parparentproc   as widget-handle no-undo .
  define input  parameter p-db-num        as integer   no-undo .
  define input  parameter p-user-id       as character no-undo .
  define input  parameter p-host-code-obj as integer   no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define output parameter p-user-select   as logical   no-undo .
  define variable v-select-obj-type as character no-undo .
  define variable v-select-obj-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel,b-mark"
      ,output p-user-select
      ,output v-select-obj-type
      ,output v-select-obj-code
      ) .
  end.
end.
procedure thobjs :
   define input        parameter parparentproc     as widget-handle no-undo .
   define input        parameter i-bttns           as character     no-undo .
   define input        parameter i-list-mode       as character     no-undo.
   define input        parameter i-obj-type        as character     no-undo.
   define input        parameter i-db-num          as integer       no-undo.
   define input        parameter i-host-code       as integer       no-undo.
   define input-output parameter p-rid-list        as character     no-undo .
run ref/thobjs.p
        ( input parparentproc
         ,input  this-procedure :handle
        , input i-bttns
        , input i-list-mode
        , input i-obj-type
        , input i-db-num
        , input i-host-code
        , input-output p-rid-list ) no-error .
end.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def new shared temp-table pbc-list no-undo like ub.prod-bc
                        field rc as recid
                        field del as  logical
                        index rci is unique rc del
                        index gds-code-i b-code del
                        index ibc-on-type bc-on-type
                        .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def new shared temp-table bc-list no-undo like ub.bar-code
                        field del as  logical
                        index bc is unique b-code del
                        index gds-code-i gds-code del.
define temp-table temp_recid-list no-undo
    field string-goods-recid as character
    index pi is primary unique string-goods-recid
.
define temp-table temp-list no-undo
field fname as character format "X(30)"
field fvalue as character
field id as integer
index pi is primary unique
id
index ifvalue fvalue
.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table macro-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
define variable f-name as char init "default.gds" no-undo.
define variable f-gds-name as char init "default.gds" no-undo.
define variable f-cli-name as char init "default.cli" no-undo.
define variable f-doc-name as char init "default.trn" no-undo.
define variable conf-par             as character           no-undo.
define variable par-type             as character           no-undo.
define variable grp-list             as character           no-undo.
define variable ref-list             as character           no-undo.
define variable num-rec              as integer     init 0  no-undo.
define variable tot-lns              as integer     init ?  no-undo.
define variable v-ext-button-label   as character           no-undo.
DEFINE VARIABLE v-attr-code          as character           no-undo .
DEFINE VARIABLE vvalue               as character           no-undo .
DEFINE VARIABLE vvalue1              as character           no-undo .
define variable vvaluedec            as decimal             no-undo .
DEFINE VARIABLE vtype                as character           no-undo .
DEFINE VARIABLE v-host-code          like ub.sysconf.host-code no-undo .
define variable v-date               as date                no-undo .
define variable is-tsd               as logical             no-undo .
define variable v-notes as character no-undo .
define variable v-ref-rec as recid no-undo .
define variable line-mode as character no-undo .
define variable line-rec as recid no-undo .
define variable contin as logical init no.
define variable glog                as logical             no-undo .
define variable g#log                as logical             no-undo .
define variable main-b-code like ub.bar-code.b-code no-undo .
define variable action as character no-undo init "U":U.
DEFINE VARIABLE petrol-trk                   as logical          no-undo .
DEFINE VARIABLE cashparts                    like ub.gds-obj.cash-parts no-undo .
define variable v-is-restaurant              as logical no-undo .
define variable v-is-null-price              like ub.fbr-gds-obj.is-null-price  no-undo .
define buffer l-scnblist for scnblist.
define variable l-empty-scale as logical no-undo .
DEFINE VARIABLE for-fact-qnty                like ub.gds-obj.fact-qnty no-undo .
define variable new-good                     as logical no-undo .
define variable v-chk-date as date no-undo .
define variable v-chk-date-chr as character no-undo .
define variable i-obj-type as character no-undo .
define variable i-obj-code like ub.clients.obj-code no-undo .
define variable v-doc-prt as logical no-undo .
define variable v-pos-type like ub.cash-desk.pos-type no-undo .
define variable v-cash-num like ub.cash-desk.cash-num no-undo .
define variable v-cash-desk-obj-code like ub.cash-desk.obj-code no-undo .
define variable optimize-option as character no-undo.
define variable optimize-label  as character no-undo.
define variable v-curr-obj-type like ub.clients.obj-type no-undo .
define variable v-curr-obj-code like ub.clients.obj-code no-undo .
define stream slog.
define buffer buf_fbr-gds-obj for ub.fbr-gds-obj.
define stream sout.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure fltfield-clear :
  define output parameter loc-fld as character no-undo.
  define output parameter loc-lab as character no-undo .
  define output parameter loc-spr as character no-undo .
  define output parameter loc-dim as character no-undo .
  assign
    loc-fld = ""
    loc-lab = ""
    loc-spr = ""
    loc-dim = "0"
  .
end procedure .
procedure fltfield-add :
  define input        parameter par-fld as character no-undo.
  define input        parameter par-lab as character no-undo .
  define input        parameter par-spr as character no-undo .
  define input-output parameter loc-fld as character no-undo.
  define input-output parameter loc-lab as character no-undo .
  define input-output parameter loc-spr as character no-undo .
  define input-output parameter loc-dim as character no-undo .
  do
  on error undo, return error
  :
    assign
    loc-fld = if loc-dim = '0'
              then par-fld
              else (loc-fld + chr(44) + par-fld)
    loc-lab = if loc-dim = '0'
              then par-lab
              else (loc-lab + chr(44) + par-lab)
    loc-spr = if loc-dim = '0'
              then par-spr
              else (loc-spr + chr(44) + par-spr)
    loc-dim = (if num-entries(loc-dim) > 1 then (entry(1, loc-dim) + chr(44)) else "") +
              string(integer(if num-entries(loc-dim) > 1
                            then entry(2, loc-dim)
                            else entry(1, loc-dim)
                            ) + 1)
    no-error
    .
  end.
end procedure.
FUNCTION stat-line RETURNS CHARACTER
  (input p-status-chr as character )  FORWARD.
DEFINE MENU m-save
      MENU-ITEM m-gds-save       LABEL "Файл списка товаров"
      MENU-ITEM m-bb-save       LABEL "Файл списка кодов"
      MENU-ITEM m-scn-save      LABEL "Файл мобильного сканера"
      MENU-ITEM m-xls-save      LABEL "Таблица EXCEL"
      MENU-ITEM m-title-save    LABEL "Имя Списка"
      MENU-ITEM m-macros-save   LABEL "Макрос формирования списка"
      RULE
      MENU-ITEM m-cd            LABEL "Передача на кассу"
      .
DEFINE MENU m-optimize
      MENU-ITEM m-repnprod-bc  LABEL "Замена локальных кодов на ДопБК (если они есть в системе)"
      MENU-ITEM m-delnprod-bc  LABEL "Удаление локальных кодов, которые имеют ДопБК в ЭТОМ списке" .
DEFINE BUTTON b-save
    LABEL "&Эксп./Вып.":L
    SIZE 10 BY 1
    tooltip "Сохранить список кодов в текстовом файле, файле сканера, EXCEL".
DEFINE BUTTON B-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "B-obj"
     SIZE 3 BY 1.
DEFINE BUTTON b-add
    LABEL "&+Доб. строку":L
    SIZE 14 BY 1
    tooltip "Добавить в список кодов 1 строку".
DEFINE BUTTON b-del
    LABEL "&-Удал. строку":L
    SIZE 14 BY 1
    tooltip "Удалить из списка кодов текущую строки".
DEFINE BUTTON b-rest
    LABEL "&*Остав. строку":L
    SIZE 14 BY 1
    tooltip "Оставить в списке только текущую строку".
DEFINE BUTTON b-exit AUTO-GO
    LABEL "&Выход ":L
    SIZE 10 BY 1
    tooltip "Выход из списка кодов(передача списка другой программе)".
DEFINE BUTTON b-help
    LABEL "Помо&щь":L
    SIZE 9 BY 1
    tooltip "Помощь".
DEFINE BUTTON b-hist
    LABEL "Ис&тория":L
    SIZE 10 BY 1
    tooltip "Последовательность шагов, приведшая к заполнению данного списка".
DEFINE BUTTON b-print
    LABEL "Пе&чать":L
    SIZE 10 BY 1
    tooltip "Печать списка кодов".
DEFINE BUTTON b-lkp
    LABEL "&Просмотр":L
    SIZE 10 BY 1
    tooltip "Просмотр описания текущего товара".
DEFINE BUTTON b-clr
    LABEL "Очи&стить":L
    SIZE 10 BY 1
    tooltip "Удалить из списка все коды (строки)".
DEFINE BUTTON b-macro
    IMAGE-UP FILE "cmp/run.bmp":U
    IMAGE-DOWN FILE "cmp/runi.bmp":U
    IMAGE-INSENSITIVE FILE "cmp/runi.bmp":U
    LABEL '&>':L
    SIZE 4 BY 1.25
    tooltip "Выполнение макроса формирования истории".
DEFINE BUTTON b-record
    IMAGE-UP FILE "cmp/record.bmp":U
    IMAGE-DOWN FILE "cmp/recordi.bmp":U
    IMAGE-INSENSITIVE FILE "cmp/recordi.bmp":U
    LABEL '&o':L
    SIZE 4 BY 1.25
    tooltip "Запись макроса формирования истории".
DEFINE BUTTON b-clear-macro
    IMAGE-UP FILE "cmp/fstop.bmp":U
    IMAGE-DOWN FILE "cmp/fstopi.bmp":U
    IMAGE-INSENSITIVE FILE "cmp/fstopi.bmp":U
    LABEL "&[ ]":L
    SIZE 4 BY 1.25
    tooltip "Удаление макроса формирования истории из памяти".
DEFINE BUTTON b-stop
    IMAGE-UP FILE "cmp/stop.bmp":U
    IMAGE-DOWN FILE "cmp/stopi.bmp":U
    IMAGE-INSENSITIVE FILE "cmp/stopi.bmp":U
    LABEL "&[ ]":L
    SIZE 4 BY 1.25
    tooltip "Конец записи макроса формирования истории".
DEFINE BUTTON b-pause
    IMAGE-UP FILE "cmp/pause.bmp":U
    IMAGE-DOWN FILE "cmp/pausei.bmp":U
    IMAGE-INSENSITIVE FILE "cmp/pausei.bmp":U
    LABEL "&||":L
    SIZE 4 BY 1.25
    tooltip "Сброс макроса формирования истории".
DEFINE BUTTON b-optimize
    LABEL "Оптими&з.":L
    SIZE 10 BY 1
    tooltip "Оптимизация списка".
DEFINE VARIABLE dsp-rs AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
    SIZE 98.5 BY 1
    tooltip "Строка текущего состояния списка"
    FGCOLOR 4
    no-undo.
DEFINE VARIABLE f-tot-lns AS integer FORMAT ">>>>>>>>9":U
      VIEW-AS TEXT
    SIZE 9 BY 0.70
    tooltip "Кол. строк"
    FGCOLOR 4
    no-undo.
DEFINE VARIABLE RS-status AS character
    VIEW-AS RADIO-SET HORIZONTAL
    RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2",
"Item 3", "3"
    SIZE 32 BY 1 NO-UNDO.
define variable loc-art AS CHAR VIEW-AS fill-in size 14 by 1
    tooltip "Начало артикула для поиска строки"
    fgcolor 12 no-undo.
define variable loc-name AS CHAR VIEW-AS fill-in size 20 by 1
    tooltip "Начало названия товара для поиска строки"
    fgcolor 12 no-undo.
define variable loc-code AS CHAR VIEW-AS fill-in size 20 by 1
    tooltip "Код (бар-код) для поиска строки"
    fgcolor 12 no-undo.
define variable loc-b-str AS CHAR VIEW-AS fill-in size 20 by 1
    tooltip "ДопБК для поиска строки"
    fgcolor 12 no-undo.
define variable a-n-c AS CHAR VIEW-AS RADIO-SET horizontal  RADIO-BUTTONS
"&А","art",
"&Н","name",
"&К","code",
"&ДБК","b-str"
SIZE 18 BY 1
    tooltip "Выбор режима поиска: А - артикул, Н - начало названия, К - код (бар-код), ДБК - ДопБК"
    no-undo.
DEFINE VARIABLE T-all-prt AS LOGICAL INITIAL no
     LABEL "ВСЕ коды призн."
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .79 NO-UNDO.
DEFINE VARIABLE T-bc-alt AS LOGICAL INITIAL no
     LABEL "неосновн. (EAN)"
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .79 NO-UNDO.
DEFINE VARIABLE T-bc-base AS LOGICAL INITIAL no
     LABEL "основн.  (EAN)"
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .79 NO-UNDO.
DEFINE VARIABLE T-loc-alt AS LOGICAL INITIAL no
     LABEL "неосновн. коды"
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .79 NO-UNDO.
DEFINE VARIABLE T-loc-base AS LOGICAL INITIAL no
     LABEL "основн. коды"
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .79 NO-UNDO.
DEFINE VARIABLE T-parts-all AS LOGICAL INITIAL no
     LABEL "на все партии"
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .79 NO-UNDO.
DEFINE VARIABLE T-parts-not-blank AS LOGICAL INITIAL no
     LABEL "с непуст. N парт."
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .79 NO-UNDO.
DEFINE VARIABLE T-parts-ser AS LOGICAL INITIAL no
     LABEL "на сер. товар"
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .79 NO-UNDO.
DEFINE VARIABLE T-pb-alt AS LOGICAL INITIAL no
     LABEL "ДопБК неосн.ед.изм"
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .79 NO-UNDO.
DEFINE VARIABLE T-pb-base AS LOGICAL INITIAL no
     LABEL "ДопБК осн.ед.изм"
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .79 NO-UNDO.
DEFINE VARIABLE T-sc-base AS LOGICAL INITIAL no
     LABEL "весов и топл."
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .79 NO-UNDO.
define variable v-obj-type as character view-as fill-in size  4 by 1 fgcolor 12 no-undo.
define variable v-obj-code as integer   view-as fill-in size  6 by 1 fgcolor 12 no-undo.
define variable v-obj-name as character view-as fill-in size 30 by 1 fgcolor 12 no-undo format "x(30)":U.
DEFINE QUERY BR-option FOR
      temp-list SCROLLING.
DEFINE BUTTON b-cd
    LABEL "По &умолч":L
    SIZE 10 BY 1
    tooltip "Опции кодов установить в соответствии с настройками магазина-передача на кассу".
DEFINE BROWSE BR-option QUERY BR-option
DISPLAY
temp-list.fname format "X(255)" width 60 COLUMN-FONT 2
WITH NO-LABELS SIZE 30 BY 13 separators
tooltip "Условие для выбора кодов, которые будут добавлены / удалены / оставлены в списке"
.
DEFINE QUERY br-list FOR scnblist SCROLLING.
DEFINE BROWSE br-list QUERY br-list NO-LOCK DISPLAY
      scnblist.gds-code
      scnblist.b-code   format ">>>>>>>>9" column-label "Бар-код"
      scnblist.b-str    format "X(17)" column-label "ДопБК/лок.ЕАН"
      scnblist.bc-on    format "+/" column-label "В!к!л"
      scnblist.artic
      scnblist.gds-name format "x(25)"
      scnblist.qnty column-label "Количество" format "->>>,>>9.999"
      scnblist.f-name
      scnblist.unit-base column-label "Осн!Ед!Изм" format "x(3)"
      scnblist.bc-unit-cli column-label "Ед!Изм!кода" format "x(3)"
      scnblist.bc-cli-base-rate column-label "кратность" format ">>,>>9.999"
      (if scnblist.stts = 0 then no else yes) column-label "-" format "-/ "
      scnblist.in-code column-label "№ ПН" format  "X(18)" width 16
      scnblist.part-code column-label "№ Партии" format  "X(255)" width 10
      scnblist.grp-name
      (scnblist.prod-type + string (scnblist.prod-code, ">>>>>>>>>9") ) column-label "Производитель" format "x(13)"
      enable scnblist.qnty
      WITH SIZE 68.5 BY 16 separators FONT 2.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE term-prt.
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
define input parameter line-mode as character no-undo .
define input parameter c-root like ub.gds-prt.prt-root no-undo.
define input parameter c-node like ub.gds-prt.node-code no-undo.
define buffer b-g-p for ub.gds-prt.
define buffer pr-bc for ub.bar-code .
define buffer b-bc for ub.bar-code .
define buffer p-bar-code for ub.bar-code .
define buffer b-units for ub.units.
define variable pusto as char init "" no-undo.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  ub.goods.gds-code
  ,input  ?
  ,output main-b-code
  ) no-error .
  if LOOKUP('топ':U, ub.units.type) > 0 and
      LOOKUP('дро':U, ub.units.type) > 0 AND
      ub.goods.gds-type = 'т':U
  then do:
        petrol-trk = yes.
  end.
  else petrol-trk = no.
  _b-g-p:
   FOR EACH ub.bar-code NO-LOCK where
            ub.bar-code.gds-code = ub.goods.gds-code,
      FIRST b-g-p NO-LOCK WHERE
            b-g-p.node-code = ub.bar-code.node-code
       AND  b-g-p.prt-root = c-root
       AND  b-g-p.is-term = yes
     :
     if ub.bar-code.part-code <> ""
     OR ub.bar-code.in-code <> ""
     OR ub.bar-code.unit-cli <> ub.goods.unit-base then NEXT _b-g-p.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FIND FIRST ub.prt-obj WHERE
        ub.prt-obj.obj-type = p-curr-obj-type AND
        ub.prt-obj.obj-code = p-curr-obj-code AND
        ub.prt-obj.prod-type = ub.goods.prod-type AND
        ub.prt-obj.prod-code = ub.goods.prod-code AND
        ub.prt-obj.artic = ub.goods.artic AND
        ub.prt-obj.prt-code = b-g-p.node-code NO-LOCK NO-ERROR .
if v-is-restaurant and v-is-null-price then.
else do:
if (NOT temp-shop.all-prt )
    AND  ub.goods.gds-type = 'т':U
    AND  NOT l-empty-scale then do:
  if not available ub.prt-obj then do:
    if temp-shop.sub-store-on then do:
      if NOT can-find( first ub.gds-dtl where
                          ub.gds-dtl.artic = ub.goods.artic AND
                          ub.gds-dtl.prod-type = ub.goods.prod-type AND
                          ub.gds-dtl.prod-code = ub.goods.prod-code AND
                          ub.gds-dtl.prt-code = b-g-p.node-code AND
                          ub.gds-dtl.obj-type =  temp-shop.sub-store-type AND
                          ub.gds-dtl.obj-code = temp-shop.sub-store-code) then
                  NEXT _b-g-p.
    end.
    else do:
                  NEXT _b-g-p.
    end.
  end.
end.
end.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  if ((LOOKUP('сер':U, ub.units.type) = 0  and not cashparts) OR
      (LOOKUP('сер':U, ub.units.type) > 0 and NOT temp-shop.cd-parts-ser)
     )
    then do:
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FIND FIRST b-units No-LOCK WHERE
           b-units.unit-name = ub.bar-code.unit-cli No-ERROR.
if (temp-shop.cd-bc-base or temp-shop.cd-loc-base) and (NOT petrol-trk
or v-notcd
)
then do:
      run asc-gds in this-procedure (
      input rs-list-method,
      input rs-status,
      input line-mode,
      buffer ub.goods,
      buffer ub.bar-code,
      buffer ub.gds-prt,
      buffer ub.gds-obj,
      buffer ub.price-list,
      buffer ub.units,
      buffer b-g-p,
      input ?,
      input '',
      input (if avail b-units then b-units.type else ub.units.type),
      input (if avail b-units then b-units.okei else ub.units.okei),
      input ub.sysconf.host-code,
      input p-curr-obj-type,
      input p-curr-obj-code
      )  no-error .
     if error-status:error then return error.
end.
if temp-shop.cd-pb-base or temp-shop.cd-pb-alt or temp-shop.cd-sc-base OR petrol-trk then do:
  FOR EACH ub.prod-bc NO-LOCK WHERE
           ub.prod-bc.b-code = ub.bar-code.b-code
              :
      if  ub.prod-bc.b-str = string( ub.bar-code.b-code )
          AND
          (
          (ub.goods.unit-base = ub.bar-code.unit-cli AND temp-shop.cd-loc-base) OR
          (NOT ub.goods.unit-base = ub.bar-code.unit-cli AND temp-shop.cd-loc-alt)
          ) AND
          (NOT petrol-trk
          or v-notcd
          )
          then NEXT.
    if temp-shop.cd-sc-base AND
    (LOOKUP('вес':U, ub.units.type) > 0
    or
    LOOKUP('топ':U, ub.units.type) > 0
    or
    ub.prod-bc.bc-on-type = 'pglc':U
    )
    and
    ub.bar-code.unit-cli = ub.goods.unit-base then do:
      if not ub.prod-bc.bc-on-type = 'pglc':U then do:
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer ub.prod-bc
  ,input  (if LOOKUP('вес':U, ub.units.type) > 0 then 'weight=request':U  else 'petrolium=request':U )
  ,output g#log
  ) no-error .
        if error-status:error or not g#log then NEXT.
      end.
      run asc-gds in this-procedure (
        input rs-list-method,
        input rs-status,
        input line-mode,
        buffer ub.goods,
        buffer ub.bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input p-curr-obj-type,
        input p-curr-obj-code
        ) no-error.
      if error-status:error then return error.
      NEXT.
    end.
    if ((temp-shop.cd-pb-base AND ub.bar-code.unit-cli = ub.goods.unit-base
    AND LOOKUP('вес':U, units.type) = 0
    and ub.prod-bc.bc-on-type <> 'pglc':U
    ) OR
        (temp-shop.cd-pb-alt AND ub.bar-code.unit-cli <> ub.goods.unit-base)) then do:
      run asc-gds in this-procedure (
        input rs-list-method,
        input rs-status,
        input line-mode,
        buffer ub.goods,
        buffer ub.bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input p-curr-obj-type,
        input p-curr-obj-code
        ) no-error.
     if error-status:error then return error.
    end.
  END.
end.
if NOT petrol-trk
or v-notcd
then do:
  FOR EACH b-bc WHERE
            b-bc.gds-code = ub.goods.gds-code AND
            b-bc.node-code = ub.bar-code.node-code AND
            b-bc.part-code = pusto AND
            b-bc.in-code = pusto NO-LOCK :
    if  b-bc.unit-cli <> ub.goods.unit-base then do:
    FIND FIRST b-units No-LOCK WHERE
               b-units.unit-name = b-bc.unit-cli NO-ERROR.
    if temp-shop.cd-bc-alt or temp-shop.cd-loc-alt then do:
          run asc-gds in this-procedure (
            input rs-list-method,
            input rs-status,
            input line-mode,
            buffer ub.goods,
            buffer b-bc,
            buffer ub.gds-prt,
            buffer ub.gds-obj,
            buffer ub.price-list,
            buffer ub.units,
            buffer b-g-p,
            input ?,
            input '',
            input (if avail b-units then b-units.type else ub.units.type),
            input (if avail b-units then b-units.okei else ub.units.okei),
            input ub.sysconf.host-code,
            input p-curr-obj-type,
            input p-curr-obj-code
            ) no-error.
     if error-status:error then return error.
     end.
     if temp-shop.cd-pb-alt then do:
       FOR EACH ub.prod-bc NO-LOCK WHERE
                ub.prod-bc.b-code = b-bc.b-code
               :
        if ub.prod-bc.b-str = string( b-bc.b-code ) AND temp-shop.cd-loc-alt then NEXT.
        run asc-gds in this-procedure (
          input rs-list-method,
          input rs-status,
          input line-mode,
          buffer ub.goods,
          buffer b-bc,
          buffer ub.gds-prt,
          buffer ub.gds-obj,
          buffer ub.price-list,
          buffer ub.units,
          buffer b-g-p,
          input ub.prod-bc.b-str,
          input ub.prod-bc.bc-on-type,
          input (if avail b-units then b-units.type else ub.units.type),
          input (if avail b-units then b-units.okei else ub.units.okei),
          input ub.sysconf.host-code,
          input p-curr-obj-type,
          input p-curr-obj-code
          ) no-error.
        if error-status:error then return error.
      END.
    end.
    end.
  END.
end.
  end.
  if petrol-trk then return.
  if temp-shop.doc-prt AND b-g-p.node-name <> '_Пустая шкала':U then NEXT _b-g-p.
  if temp-shop.cd-parts-all or (cashparts AND LOOKUP('сер':U, units.type) = 0) then do:
    if action = "D":U then do:
      for each p-bar-code No-LOCK WHERE
               p-bar-code.gds-code = ub.goods.gds-code
           AND p-bar-code.node-code = ub.bar-code.node-code,
          FIRST ub.parts No-LOCK WHERE
                ub.parts.obj-type  = p-curr-obj-type
            AND ub.parts.obj-code  = p-curr-obj-code
            AND ub.parts.artic     = ub.goods.artic
            AND ub.parts.prod-type = ub.goods.prod-type
            AND ub.parts.prod-code = ub.goods.prod-code
            AND ub.parts.in-code   = p-bar-code.in-code
            AND ub.parts.part-code =  p-bar-code.part-code
      break
      by p-bar-code.in-code
      by p-bar-code.part-code:
      IF p-bar-code.unit-cli <> ub.goods.unit-base then next.
      IF FIRST-OF(p-bar-code.part-code) then do:
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FIND FIRST b-units No-LOCK WHERE
           b-units.unit-name = p-bar-code.unit-cli No-ERROR.
if (temp-shop.cd-bc-base or temp-shop.cd-loc-base) and (NOT petrol-trk
or v-notcd
)
then do:
      run asc-gds in this-procedure (
      input rs-list-method,
      input rs-status,
      input line-mode,
      buffer ub.goods,
      buffer p-bar-code,
      buffer ub.gds-prt,
      buffer ub.gds-obj,
      buffer ub.price-list,
      buffer ub.units,
      buffer b-g-p,
      input ?,
      input '',
      input (if avail b-units then b-units.type else ub.units.type),
      input (if avail b-units then b-units.okei else ub.units.okei),
      input ub.sysconf.host-code,
      input p-curr-obj-type,
      input p-curr-obj-code
      )  no-error .
     if error-status:error then return error.
end.
if temp-shop.cd-pb-base or temp-shop.cd-pb-alt or temp-shop.cd-sc-base OR petrol-trk then do:
  FOR EACH ub.prod-bc NO-LOCK WHERE
           ub.prod-bc.b-code = p-bar-code.b-code
              :
      if  ub.prod-bc.b-str = string( p-bar-code.b-code )
          AND
          (
          (ub.goods.unit-base = p-bar-code.unit-cli AND temp-shop.cd-loc-base) OR
          (NOT ub.goods.unit-base = p-bar-code.unit-cli AND temp-shop.cd-loc-alt)
          ) AND
          (NOT petrol-trk
          or v-notcd
          )
          then NEXT.
    if temp-shop.cd-sc-base AND
    (LOOKUP('вес':U, ub.units.type) > 0
    or
    LOOKUP('топ':U, ub.units.type) > 0
    or
    ub.prod-bc.bc-on-type = 'pglc':U
    )
    and
    p-bar-code.unit-cli = ub.goods.unit-base then do:
      if not ub.prod-bc.bc-on-type = 'pglc':U then do:
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer ub.prod-bc
  ,input  (if LOOKUP('вес':U, ub.units.type) > 0 then 'weight=request':U  else 'petrolium=request':U )
  ,output g#log
  ) no-error .
        if error-status:error or not g#log then NEXT.
      end.
      run asc-gds in this-procedure (
        input rs-list-method,
        input rs-status,
        input line-mode,
        buffer ub.goods,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input p-curr-obj-type,
        input p-curr-obj-code
        ) no-error.
      if error-status:error then return error.
      NEXT.
    end.
    if ((temp-shop.cd-pb-base AND p-bar-code.unit-cli = ub.goods.unit-base
    AND LOOKUP('вес':U, units.type) = 0
    and ub.prod-bc.bc-on-type <> 'pglc':U
    ) OR
        (temp-shop.cd-pb-alt AND p-bar-code.unit-cli <> ub.goods.unit-base)) then do:
      run asc-gds in this-procedure (
        input rs-list-method,
        input rs-status,
        input line-mode,
        buffer ub.goods,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input p-curr-obj-type,
        input p-curr-obj-code
        ) no-error.
     if error-status:error then return error.
    end.
  END.
end.
if NOT petrol-trk
or v-notcd
then do:
  FOR EACH b-bc WHERE
            b-bc.gds-code = ub.goods.gds-code AND
            b-bc.node-code = p-bar-code.node-code AND
            b-bc.part-code = ub.parts.part-code AND
            b-bc.in-code = ub.parts.in-code NO-LOCK :
    if  b-bc.unit-cli <> ub.goods.unit-base then do:
    FIND FIRST b-units No-LOCK WHERE
               b-units.unit-name = b-bc.unit-cli NO-ERROR.
    if temp-shop.cd-bc-alt or temp-shop.cd-loc-alt then do:
          run asc-gds in this-procedure (
            input rs-list-method,
            input rs-status,
            input line-mode,
            buffer ub.goods,
            buffer b-bc,
            buffer ub.gds-prt,
            buffer ub.gds-obj,
            buffer ub.price-list,
            buffer ub.units,
            buffer b-g-p,
            input ?,
            input '',
            input (if avail b-units then b-units.type else ub.units.type),
            input (if avail b-units then b-units.okei else ub.units.okei),
            input ub.sysconf.host-code,
            input p-curr-obj-type,
            input p-curr-obj-code
            ) no-error.
     if error-status:error then return error.
     end.
     if temp-shop.cd-pb-alt then do:
       FOR EACH ub.prod-bc NO-LOCK WHERE
                ub.prod-bc.b-code = b-bc.b-code
               :
        if ub.prod-bc.b-str = string( b-bc.b-code ) AND temp-shop.cd-loc-alt then NEXT.
        run asc-gds in this-procedure (
          input rs-list-method,
          input rs-status,
          input line-mode,
          buffer ub.goods,
          buffer b-bc,
          buffer ub.gds-prt,
          buffer ub.gds-obj,
          buffer ub.price-list,
          buffer ub.units,
          buffer b-g-p,
          input ub.prod-bc.b-str,
          input ub.prod-bc.bc-on-type,
          input (if avail b-units then b-units.type else ub.units.type),
          input (if avail b-units then b-units.okei else ub.units.okei),
          input ub.sysconf.host-code,
          input p-curr-obj-type,
          input p-curr-obj-code
          ) no-error.
        if error-status:error then return error.
      END.
    end.
    end.
  END.
end.
      end.
    end.
   end.
   else do:
      FOR EACH ub.parts NO-LOCK WHERE
                ub.parts.obj-type  = p-curr-obj-type AND
                ub.parts.obj-code  = p-curr-obj-code AND
                ub.parts.artic     = ub.goods.artic AND
                ub.parts.prod-type = ub.goods.prod-type AND
                ub.parts.prod-code = ub.goods.prod-code AND
                ub.parts.rsrv-free = yes AND
                ub.parts.status_ = no
      break
      by ub.parts.in-code
      by ub.parts.part-code:
        IF FIRST-OF(ub.parts.part-code) then
        FOR EACH p-bar-code NO-LOCK WHERE
                p-bar-code.gds-code = ub.goods.gds-code AND
                p-bar-code.in-code = ub.parts.in-code AND
                p-bar-code.part-code = ub.parts.part-code AND
                p-bar-code.node-code = ub.bar-code.node-code AND
                p-bar-code.unit-cli = ub.goods.unit-base:
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FIND FIRST b-units No-LOCK WHERE
           b-units.unit-name = p-bar-code.unit-cli No-ERROR.
if (temp-shop.cd-bc-base or temp-shop.cd-loc-base) and (NOT petrol-trk
or v-notcd
)
then do:
      run asc-gds in this-procedure (
      input rs-list-method,
      input rs-status,
      input line-mode,
      buffer ub.goods,
      buffer p-bar-code,
      buffer ub.gds-prt,
      buffer ub.gds-obj,
      buffer ub.price-list,
      buffer ub.units,
      buffer b-g-p,
      input ?,
      input '',
      input (if avail b-units then b-units.type else ub.units.type),
      input (if avail b-units then b-units.okei else ub.units.okei),
      input ub.sysconf.host-code,
      input p-curr-obj-type,
      input p-curr-obj-code
      )  no-error .
     if error-status:error then return error.
end.
if temp-shop.cd-pb-base or temp-shop.cd-pb-alt or temp-shop.cd-sc-base OR petrol-trk then do:
  FOR EACH ub.prod-bc NO-LOCK WHERE
           ub.prod-bc.b-code = p-bar-code.b-code
              :
      if  ub.prod-bc.b-str = string( p-bar-code.b-code )
          AND
          (
          (ub.goods.unit-base = p-bar-code.unit-cli AND temp-shop.cd-loc-base) OR
          (NOT ub.goods.unit-base = p-bar-code.unit-cli AND temp-shop.cd-loc-alt)
          ) AND
          (NOT petrol-trk
          or v-notcd
          )
          then NEXT.
    if temp-shop.cd-sc-base AND
    (LOOKUP('вес':U, ub.units.type) > 0
    or
    LOOKUP('топ':U, ub.units.type) > 0
    or
    ub.prod-bc.bc-on-type = 'pglc':U
    )
    and
    p-bar-code.unit-cli = ub.goods.unit-base then do:
      if not ub.prod-bc.bc-on-type = 'pglc':U then do:
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer ub.prod-bc
  ,input  (if LOOKUP('вес':U, ub.units.type) > 0 then 'weight=request':U  else 'petrolium=request':U )
  ,output g#log
  ) no-error .
        if error-status:error or not g#log then NEXT.
      end.
      run asc-gds in this-procedure (
        input rs-list-method,
        input rs-status,
        input line-mode,
        buffer ub.goods,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input p-curr-obj-type,
        input p-curr-obj-code
        ) no-error.
      if error-status:error then return error.
      NEXT.
    end.
    if ((temp-shop.cd-pb-base AND p-bar-code.unit-cli = ub.goods.unit-base
    AND LOOKUP('вес':U, units.type) = 0
    and ub.prod-bc.bc-on-type <> 'pglc':U
    ) OR
        (temp-shop.cd-pb-alt AND p-bar-code.unit-cli <> ub.goods.unit-base)) then do:
      run asc-gds in this-procedure (
        input rs-list-method,
        input rs-status,
        input line-mode,
        buffer ub.goods,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input p-curr-obj-type,
        input p-curr-obj-code
        ) no-error.
     if error-status:error then return error.
    end.
  END.
end.
if NOT petrol-trk
or v-notcd
then do:
  FOR EACH b-bc WHERE
            b-bc.gds-code = ub.goods.gds-code AND
            b-bc.node-code = p-bar-code.node-code AND
            b-bc.part-code = ub.parts.part-code AND
            b-bc.in-code = ub.parts.in-code NO-LOCK :
    if  b-bc.unit-cli <> ub.goods.unit-base then do:
    FIND FIRST b-units No-LOCK WHERE
               b-units.unit-name = b-bc.unit-cli NO-ERROR.
    if temp-shop.cd-bc-alt or temp-shop.cd-loc-alt then do:
          run asc-gds in this-procedure (
            input rs-list-method,
            input rs-status,
            input line-mode,
            buffer ub.goods,
            buffer b-bc,
            buffer ub.gds-prt,
            buffer ub.gds-obj,
            buffer ub.price-list,
            buffer ub.units,
            buffer b-g-p,
            input ?,
            input '',
            input (if avail b-units then b-units.type else ub.units.type),
            input (if avail b-units then b-units.okei else ub.units.okei),
            input ub.sysconf.host-code,
            input p-curr-obj-type,
            input p-curr-obj-code
            ) no-error.
     if error-status:error then return error.
     end.
     if temp-shop.cd-pb-alt then do:
       FOR EACH ub.prod-bc NO-LOCK WHERE
                ub.prod-bc.b-code = b-bc.b-code
               :
        if ub.prod-bc.b-str = string( b-bc.b-code ) AND temp-shop.cd-loc-alt then NEXT.
        run asc-gds in this-procedure (
          input rs-list-method,
          input rs-status,
          input line-mode,
          buffer ub.goods,
          buffer b-bc,
          buffer ub.gds-prt,
          buffer ub.gds-obj,
          buffer ub.price-list,
          buffer ub.units,
          buffer b-g-p,
          input ub.prod-bc.b-str,
          input ub.prod-bc.bc-on-type,
          input (if avail b-units then b-units.type else ub.units.type),
          input (if avail b-units then b-units.okei else ub.units.okei),
          input ub.sysconf.host-code,
          input p-curr-obj-type,
          input p-curr-obj-code
          ) no-error.
        if error-status:error then return error.
      END.
    end.
    end.
  END.
end.
        END.
      END.
    end.
    return.
  end.
  if temp-shop.cd-parts-not-blank or (cashparts AND LOOKUP('сер':U, units.type) = 0) then do:
    if action = "D":U then do:
      for each p-bar-code No-LOCK WHERE
               p-bar-code.gds-code = ub.goods.gds-code
           AND p-bar-code.node-code = ub.bar-code.node-code,
          EACH ub.parts No-LOCK WHERE
               ub.parts.obj-type  = p-curr-obj-type
            AND ub.parts.obj-code  = p-curr-obj-code
            AND ub.parts.artic     = ub.goods.artic
            AND ub.parts.prod-type = ub.goods.prod-type
            AND ub.parts.prod-code = ub.goods.prod-code
            AND ub.parts.in-code   = p-bar-code.in-code
            AND ub.parts.part-code =  p-bar-code.part-code
      break
      by p-bar-code.in-code
      by p-bar-code.part-code:
        if p-bar-code.part-code = "":U then NEXT.
        if p-bar-code.unit-cli <> ub.goods.unit-base then NEXT.
        IF FIRST-OF(p-bar-code.part-code) then do:
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FIND FIRST b-units No-LOCK WHERE
           b-units.unit-name = p-bar-code.unit-cli No-ERROR.
if (temp-shop.cd-bc-base or temp-shop.cd-loc-base) and (NOT petrol-trk
or v-notcd
)
then do:
      run asc-gds in this-procedure (
      input rs-list-method,
      input rs-status,
      input line-mode,
      buffer ub.goods,
      buffer p-bar-code,
      buffer ub.gds-prt,
      buffer ub.gds-obj,
      buffer ub.price-list,
      buffer ub.units,
      buffer b-g-p,
      input ?,
      input '',
      input (if avail b-units then b-units.type else ub.units.type),
      input (if avail b-units then b-units.okei else ub.units.okei),
      input ub.sysconf.host-code,
      input p-curr-obj-type,
      input p-curr-obj-code
      )  no-error .
     if error-status:error then return error.
end.
if temp-shop.cd-pb-base or temp-shop.cd-pb-alt or temp-shop.cd-sc-base OR petrol-trk then do:
  FOR EACH ub.prod-bc NO-LOCK WHERE
           ub.prod-bc.b-code = p-bar-code.b-code
              :
      if  ub.prod-bc.b-str = string( p-bar-code.b-code )
          AND
          (
          (ub.goods.unit-base = p-bar-code.unit-cli AND temp-shop.cd-loc-base) OR
          (NOT ub.goods.unit-base = p-bar-code.unit-cli AND temp-shop.cd-loc-alt)
          ) AND
          (NOT petrol-trk
          or v-notcd
          )
          then NEXT.
    if temp-shop.cd-sc-base AND
    (LOOKUP('вес':U, ub.units.type) > 0
    or
    LOOKUP('топ':U, ub.units.type) > 0
    or
    ub.prod-bc.bc-on-type = 'pglc':U
    )
    and
    p-bar-code.unit-cli = ub.goods.unit-base then do:
      if not ub.prod-bc.bc-on-type = 'pglc':U then do:
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer ub.prod-bc
  ,input  (if LOOKUP('вес':U, ub.units.type) > 0 then 'weight=request':U  else 'petrolium=request':U )
  ,output g#log
  ) no-error .
        if error-status:error or not g#log then NEXT.
      end.
      run asc-gds in this-procedure (
        input rs-list-method,
        input rs-status,
        input line-mode,
        buffer ub.goods,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input p-curr-obj-type,
        input p-curr-obj-code
        ) no-error.
      if error-status:error then return error.
      NEXT.
    end.
    if ((temp-shop.cd-pb-base AND p-bar-code.unit-cli = ub.goods.unit-base
    AND LOOKUP('вес':U, units.type) = 0
    and ub.prod-bc.bc-on-type <> 'pglc':U
    ) OR
        (temp-shop.cd-pb-alt AND p-bar-code.unit-cli <> ub.goods.unit-base)) then do:
      run asc-gds in this-procedure (
        input rs-list-method,
        input rs-status,
        input line-mode,
        buffer ub.goods,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input p-curr-obj-type,
        input p-curr-obj-code
        ) no-error.
     if error-status:error then return error.
    end.
  END.
end.
if NOT petrol-trk
or v-notcd
then do:
  FOR EACH b-bc WHERE
            b-bc.gds-code = ub.goods.gds-code AND
            b-bc.node-code = p-bar-code.node-code AND
            b-bc.part-code = ub.parts.part-code AND
            b-bc.in-code = ub.parts.in-code NO-LOCK :
    if  b-bc.unit-cli <> ub.goods.unit-base then do:
    FIND FIRST b-units No-LOCK WHERE
               b-units.unit-name = b-bc.unit-cli NO-ERROR.
    if temp-shop.cd-bc-alt or temp-shop.cd-loc-alt then do:
          run asc-gds in this-procedure (
            input rs-list-method,
            input rs-status,
            input line-mode,
            buffer ub.goods,
            buffer b-bc,
            buffer ub.gds-prt,
            buffer ub.gds-obj,
            buffer ub.price-list,
            buffer ub.units,
            buffer b-g-p,
            input ?,
            input '',
            input (if avail b-units then b-units.type else ub.units.type),
            input (if avail b-units then b-units.okei else ub.units.okei),
            input ub.sysconf.host-code,
            input p-curr-obj-type,
            input p-curr-obj-code
            ) no-error.
     if error-status:error then return error.
     end.
     if temp-shop.cd-pb-alt then do:
       FOR EACH ub.prod-bc NO-LOCK WHERE
                ub.prod-bc.b-code = b-bc.b-code
               :
        if ub.prod-bc.b-str = string( b-bc.b-code ) AND temp-shop.cd-loc-alt then NEXT.
        run asc-gds in this-procedure (
          input rs-list-method,
          input rs-status,
          input line-mode,
          buffer ub.goods,
          buffer b-bc,
          buffer ub.gds-prt,
          buffer ub.gds-obj,
          buffer ub.price-list,
          buffer ub.units,
          buffer b-g-p,
          input ub.prod-bc.b-str,
          input ub.prod-bc.bc-on-type,
          input (if avail b-units then b-units.type else ub.units.type),
          input (if avail b-units then b-units.okei else ub.units.okei),
          input ub.sysconf.host-code,
          input p-curr-obj-type,
          input p-curr-obj-code
          ) no-error.
        if error-status:error then return error.
      END.
    end.
    end.
  END.
end.
        end.
      end.
    end.
    else do:
      FOR EACH ub.parts NO-LOCK  WHERE
                ub.parts.obj-type  = p-curr-obj-type AND
                ub.parts.obj-code  = p-curr-obj-code AND
                ub.parts.artic     = ub.goods.artic AND
                ub.parts.prod-type = ub.goods.prod-type AND
                ub.parts.prod-code = ub.goods.prod-code AND
                ub.parts.rsrv-free = yes AND
                ub.parts.status_ = no AND
                ub.parts.part-code <> ""
      break
      by ub.parts.in-code
      by ub.parts.part-code:
        IF FIRST-OF(ub.parts.part-code) then
        FOR   EACH p-bar-code NO-LOCK WHERE
                    p-bar-code.gds-code = ub.goods.gds-code AND
                    p-bar-code.in-code = ub.parts.in-code AND
                    p-bar-code.part-code = ub.parts.part-code AND
                    p-bar-code.node-code = ub.bar-code.node-code AND
                    p-bar-code.unit-cli = ub.goods.unit-base:
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FIND FIRST b-units No-LOCK WHERE
           b-units.unit-name = p-bar-code.unit-cli No-ERROR.
if (temp-shop.cd-bc-base or temp-shop.cd-loc-base) and (NOT petrol-trk
or v-notcd
)
then do:
      run asc-gds in this-procedure (
      input rs-list-method,
      input rs-status,
      input line-mode,
      buffer ub.goods,
      buffer p-bar-code,
      buffer ub.gds-prt,
      buffer ub.gds-obj,
      buffer ub.price-list,
      buffer ub.units,
      buffer b-g-p,
      input ?,
      input '',
      input (if avail b-units then b-units.type else ub.units.type),
      input (if avail b-units then b-units.okei else ub.units.okei),
      input ub.sysconf.host-code,
      input p-curr-obj-type,
      input p-curr-obj-code
      )  no-error .
     if error-status:error then return error.
end.
if temp-shop.cd-pb-base or temp-shop.cd-pb-alt or temp-shop.cd-sc-base OR petrol-trk then do:
  FOR EACH ub.prod-bc NO-LOCK WHERE
           ub.prod-bc.b-code = p-bar-code.b-code
              :
      if  ub.prod-bc.b-str = string( p-bar-code.b-code )
          AND
          (
          (ub.goods.unit-base = p-bar-code.unit-cli AND temp-shop.cd-loc-base) OR
          (NOT ub.goods.unit-base = p-bar-code.unit-cli AND temp-shop.cd-loc-alt)
          ) AND
          (NOT petrol-trk
          or v-notcd
          )
          then NEXT.
    if temp-shop.cd-sc-base AND
    (LOOKUP('вес':U, ub.units.type) > 0
    or
    LOOKUP('топ':U, ub.units.type) > 0
    or
    ub.prod-bc.bc-on-type = 'pglc':U
    )
    and
    p-bar-code.unit-cli = ub.goods.unit-base then do:
      if not ub.prod-bc.bc-on-type = 'pglc':U then do:
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer ub.prod-bc
  ,input  (if LOOKUP('вес':U, ub.units.type) > 0 then 'weight=request':U  else 'petrolium=request':U )
  ,output g#log
  ) no-error .
        if error-status:error or not g#log then NEXT.
      end.
      run asc-gds in this-procedure (
        input rs-list-method,
        input rs-status,
        input line-mode,
        buffer ub.goods,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input p-curr-obj-type,
        input p-curr-obj-code
        ) no-error.
      if error-status:error then return error.
      NEXT.
    end.
    if ((temp-shop.cd-pb-base AND p-bar-code.unit-cli = ub.goods.unit-base
    AND LOOKUP('вес':U, units.type) = 0
    and ub.prod-bc.bc-on-type <> 'pglc':U
    ) OR
        (temp-shop.cd-pb-alt AND p-bar-code.unit-cli <> ub.goods.unit-base)) then do:
      run asc-gds in this-procedure (
        input rs-list-method,
        input rs-status,
        input line-mode,
        buffer ub.goods,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input p-curr-obj-type,
        input p-curr-obj-code
        ) no-error.
     if error-status:error then return error.
    end.
  END.
end.
if NOT petrol-trk
or v-notcd
then do:
  FOR EACH b-bc WHERE
            b-bc.gds-code = ub.goods.gds-code AND
            b-bc.node-code = p-bar-code.node-code AND
            b-bc.part-code = ub.parts.part-code AND
            b-bc.in-code = ub.parts.in-code NO-LOCK :
    if  b-bc.unit-cli <> ub.goods.unit-base then do:
    FIND FIRST b-units No-LOCK WHERE
               b-units.unit-name = b-bc.unit-cli NO-ERROR.
    if temp-shop.cd-bc-alt or temp-shop.cd-loc-alt then do:
          run asc-gds in this-procedure (
            input rs-list-method,
            input rs-status,
            input line-mode,
            buffer ub.goods,
            buffer b-bc,
            buffer ub.gds-prt,
            buffer ub.gds-obj,
            buffer ub.price-list,
            buffer ub.units,
            buffer b-g-p,
            input ?,
            input '',
            input (if avail b-units then b-units.type else ub.units.type),
            input (if avail b-units then b-units.okei else ub.units.okei),
            input ub.sysconf.host-code,
            input p-curr-obj-type,
            input p-curr-obj-code
            ) no-error.
     if error-status:error then return error.
     end.
     if temp-shop.cd-pb-alt then do:
       FOR EACH ub.prod-bc NO-LOCK WHERE
                ub.prod-bc.b-code = b-bc.b-code
               :
        if ub.prod-bc.b-str = string( b-bc.b-code ) AND temp-shop.cd-loc-alt then NEXT.
        run asc-gds in this-procedure (
          input rs-list-method,
          input rs-status,
          input line-mode,
          buffer ub.goods,
          buffer b-bc,
          buffer ub.gds-prt,
          buffer ub.gds-obj,
          buffer ub.price-list,
          buffer ub.units,
          buffer b-g-p,
          input ub.prod-bc.b-str,
          input ub.prod-bc.bc-on-type,
          input (if avail b-units then b-units.type else ub.units.type),
          input (if avail b-units then b-units.okei else ub.units.okei),
          input ub.sysconf.host-code,
          input p-curr-obj-type,
          input p-curr-obj-code
          ) no-error.
        if error-status:error then return error.
      END.
    end.
    end.
  END.
end.
        END.
      END.
    end.
  end.
  if LOOKUP('сер':U, units.type) > 0 AND temp-shop.cd-parts-ser then do:
    if action = "D":U then do:
      for each p-bar-code No-LOCK WHERE
               p-bar-code.gds-code = ub.goods.gds-code
           AND p-bar-code.node-code = ub.bar-code.node-code,
          EACH ub.parts No-LOCK WHERE
               ub.parts.obj-type  = p-curr-obj-type
            AND ub.parts.obj-code  = p-curr-obj-code
            AND ub.parts.artic     = ub.goods.artic
            AND ub.parts.prod-type = ub.goods.prod-type
            AND ub.parts.prod-code = ub.goods.prod-code
            AND ub.parts.in-code   = p-bar-code.in-code
            AND ub.parts.part-code =  p-bar-code.part-code
      break
      by p-bar-code.in-code
      by p-bar-code.part-code:
        if p-bar-code.unit-cli <> ub.goods.unit-base then NEXT.
        if ub.parts.part-code <> "" and  temp-shop.cd-parts-not-blank then NEXT.
        IF FIRST-OF(p-bar-code.part-code) then do:
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FIND FIRST b-units No-LOCK WHERE
           b-units.unit-name = p-bar-code.unit-cli No-ERROR.
if (temp-shop.cd-bc-base or temp-shop.cd-loc-base) and (NOT petrol-trk
or v-notcd
)
then do:
      run asc-gds in this-procedure (
      input rs-list-method,
      input rs-status,
      input line-mode,
      buffer ub.goods,
      buffer p-bar-code,
      buffer ub.gds-prt,
      buffer ub.gds-obj,
      buffer ub.price-list,
      buffer ub.units,
      buffer b-g-p,
      input ?,
      input '',
      input (if avail b-units then b-units.type else ub.units.type),
      input (if avail b-units then b-units.okei else ub.units.okei),
      input ub.sysconf.host-code,
      input p-curr-obj-type,
      input p-curr-obj-code
      )  no-error .
     if error-status:error then return error.
end.
if temp-shop.cd-pb-base or temp-shop.cd-pb-alt or temp-shop.cd-sc-base OR petrol-trk then do:
  FOR EACH ub.prod-bc NO-LOCK WHERE
           ub.prod-bc.b-code = p-bar-code.b-code
              :
      if  ub.prod-bc.b-str = string( p-bar-code.b-code )
          AND
          (
          (ub.goods.unit-base = p-bar-code.unit-cli AND temp-shop.cd-loc-base) OR
          (NOT ub.goods.unit-base = p-bar-code.unit-cli AND temp-shop.cd-loc-alt)
          ) AND
          (NOT petrol-trk
          or v-notcd
          )
          then NEXT.
    if temp-shop.cd-sc-base AND
    (LOOKUP('вес':U, ub.units.type) > 0
    or
    LOOKUP('топ':U, ub.units.type) > 0
    or
    ub.prod-bc.bc-on-type = 'pglc':U
    )
    and
    p-bar-code.unit-cli = ub.goods.unit-base then do:
      if not ub.prod-bc.bc-on-type = 'pglc':U then do:
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer ub.prod-bc
  ,input  (if LOOKUP('вес':U, ub.units.type) > 0 then 'weight=request':U  else 'petrolium=request':U )
  ,output g#log
  ) no-error .
        if error-status:error or not g#log then NEXT.
      end.
      run asc-gds in this-procedure (
        input rs-list-method,
        input rs-status,
        input line-mode,
        buffer ub.goods,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input p-curr-obj-type,
        input p-curr-obj-code
        ) no-error.
      if error-status:error then return error.
      NEXT.
    end.
    if ((temp-shop.cd-pb-base AND p-bar-code.unit-cli = ub.goods.unit-base
    AND LOOKUP('вес':U, units.type) = 0
    and ub.prod-bc.bc-on-type <> 'pglc':U
    ) OR
        (temp-shop.cd-pb-alt AND p-bar-code.unit-cli <> ub.goods.unit-base)) then do:
      run asc-gds in this-procedure (
        input rs-list-method,
        input rs-status,
        input line-mode,
        buffer ub.goods,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input p-curr-obj-type,
        input p-curr-obj-code
        ) no-error.
     if error-status:error then return error.
    end.
  END.
end.
if NOT petrol-trk
or v-notcd
then do:
  FOR EACH b-bc WHERE
            b-bc.gds-code = ub.goods.gds-code AND
            b-bc.node-code = p-bar-code.node-code AND
            b-bc.part-code = ub.parts.part-code AND
            b-bc.in-code = ub.parts.in-code NO-LOCK :
    if  b-bc.unit-cli <> ub.goods.unit-base then do:
    FIND FIRST b-units No-LOCK WHERE
               b-units.unit-name = b-bc.unit-cli NO-ERROR.
    if temp-shop.cd-bc-alt or temp-shop.cd-loc-alt then do:
          run asc-gds in this-procedure (
            input rs-list-method,
            input rs-status,
            input line-mode,
            buffer ub.goods,
            buffer b-bc,
            buffer ub.gds-prt,
            buffer ub.gds-obj,
            buffer ub.price-list,
            buffer ub.units,
            buffer b-g-p,
            input ?,
            input '',
            input (if avail b-units then b-units.type else ub.units.type),
            input (if avail b-units then b-units.okei else ub.units.okei),
            input ub.sysconf.host-code,
            input p-curr-obj-type,
            input p-curr-obj-code
            ) no-error.
     if error-status:error then return error.
     end.
     if temp-shop.cd-pb-alt then do:
       FOR EACH ub.prod-bc NO-LOCK WHERE
                ub.prod-bc.b-code = b-bc.b-code
               :
        if ub.prod-bc.b-str = string( b-bc.b-code ) AND temp-shop.cd-loc-alt then NEXT.
        run asc-gds in this-procedure (
          input rs-list-method,
          input rs-status,
          input line-mode,
          buffer ub.goods,
          buffer b-bc,
          buffer ub.gds-prt,
          buffer ub.gds-obj,
          buffer ub.price-list,
          buffer ub.units,
          buffer b-g-p,
          input ub.prod-bc.b-str,
          input ub.prod-bc.bc-on-type,
          input (if avail b-units then b-units.type else ub.units.type),
          input (if avail b-units then b-units.okei else ub.units.okei),
          input ub.sysconf.host-code,
          input p-curr-obj-type,
          input p-curr-obj-code
          ) no-error.
        if error-status:error then return error.
      END.
    end.
    end.
  END.
end.
        end.
      end.
    end.
    else do:
      FOR EACH ub.parts NO-LOCK  WHERE
                ub.parts.obj-type  = p-curr-obj-type AND
                ub.parts.obj-code  = p-curr-obj-code AND
                ub.parts.artic     = ub.goods.artic AND
                ub.parts.prod-type = ub.goods.prod-type AND
                ub.parts.prod-code = ub.goods.prod-code AND
                ub.parts.rsrv-free = yes AND
                ub.parts.status_ = no AND
                ub.parts.part-code <> ""
      break
      by ub.parts.in-code
      by ub.parts.part-code:
        IF FIRST-OF(ub.parts.part-code) then do:
          if ub.parts.part-code <> "" and  temp-shop.cd-parts-not-blank then NEXT.
          FOR EACH p-bar-code NO-LOCK WHERE
                    p-bar-code.gds-code = ub.goods.gds-code AND
                    p-bar-code.in-code = ub.parts.in-code AND
                    p-bar-code.part-code = ub.parts.part-code AND
                    p-bar-code.node-code = ub.bar-code.node-code AND
                    p-bar-code.unit-cli = ub.goods.unit-base:
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FIND FIRST b-units No-LOCK WHERE
           b-units.unit-name = p-bar-code.unit-cli No-ERROR.
if (temp-shop.cd-bc-base or temp-shop.cd-loc-base) and (NOT petrol-trk
or v-notcd
)
then do:
      run asc-gds in this-procedure (
      input rs-list-method,
      input rs-status,
      input line-mode,
      buffer ub.goods,
      buffer p-bar-code,
      buffer ub.gds-prt,
      buffer ub.gds-obj,
      buffer ub.price-list,
      buffer ub.units,
      buffer b-g-p,
      input ?,
      input '',
      input (if avail b-units then b-units.type else ub.units.type),
      input (if avail b-units then b-units.okei else ub.units.okei),
      input ub.sysconf.host-code,
      input p-curr-obj-type,
      input p-curr-obj-code
      )  no-error .
     if error-status:error then return error.
end.
if temp-shop.cd-pb-base or temp-shop.cd-pb-alt or temp-shop.cd-sc-base OR petrol-trk then do:
  FOR EACH ub.prod-bc NO-LOCK WHERE
           ub.prod-bc.b-code = p-bar-code.b-code
              :
      if  ub.prod-bc.b-str = string( p-bar-code.b-code )
          AND
          (
          (ub.goods.unit-base = p-bar-code.unit-cli AND temp-shop.cd-loc-base) OR
          (NOT ub.goods.unit-base = p-bar-code.unit-cli AND temp-shop.cd-loc-alt)
          ) AND
          (NOT petrol-trk
          or v-notcd
          )
          then NEXT.
    if temp-shop.cd-sc-base AND
    (LOOKUP('вес':U, ub.units.type) > 0
    or
    LOOKUP('топ':U, ub.units.type) > 0
    or
    ub.prod-bc.bc-on-type = 'pglc':U
    )
    and
    p-bar-code.unit-cli = ub.goods.unit-base then do:
      if not ub.prod-bc.bc-on-type = 'pglc':U then do:
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer ub.prod-bc
  ,input  (if LOOKUP('вес':U, ub.units.type) > 0 then 'weight=request':U  else 'petrolium=request':U )
  ,output g#log
  ) no-error .
        if error-status:error or not g#log then NEXT.
      end.
      run asc-gds in this-procedure (
        input rs-list-method,
        input rs-status,
        input line-mode,
        buffer ub.goods,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input p-curr-obj-type,
        input p-curr-obj-code
        ) no-error.
      if error-status:error then return error.
      NEXT.
    end.
    if ((temp-shop.cd-pb-base AND p-bar-code.unit-cli = ub.goods.unit-base
    AND LOOKUP('вес':U, units.type) = 0
    and ub.prod-bc.bc-on-type <> 'pglc':U
    ) OR
        (temp-shop.cd-pb-alt AND p-bar-code.unit-cli <> ub.goods.unit-base)) then do:
      run asc-gds in this-procedure (
        input rs-list-method,
        input rs-status,
        input line-mode,
        buffer ub.goods,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input p-curr-obj-type,
        input p-curr-obj-code
        ) no-error.
     if error-status:error then return error.
    end.
  END.
end.
if NOT petrol-trk
or v-notcd
then do:
  FOR EACH b-bc WHERE
            b-bc.gds-code = ub.goods.gds-code AND
            b-bc.node-code = p-bar-code.node-code AND
            b-bc.part-code = ub.parts.part-code AND
            b-bc.in-code = ub.parts.in-code NO-LOCK :
    if  b-bc.unit-cli <> ub.goods.unit-base then do:
    FIND FIRST b-units No-LOCK WHERE
               b-units.unit-name = b-bc.unit-cli NO-ERROR.
    if temp-shop.cd-bc-alt or temp-shop.cd-loc-alt then do:
          run asc-gds in this-procedure (
            input rs-list-method,
            input rs-status,
            input line-mode,
            buffer ub.goods,
            buffer b-bc,
            buffer ub.gds-prt,
            buffer ub.gds-obj,
            buffer ub.price-list,
            buffer ub.units,
            buffer b-g-p,
            input ?,
            input '',
            input (if avail b-units then b-units.type else ub.units.type),
            input (if avail b-units then b-units.okei else ub.units.okei),
            input ub.sysconf.host-code,
            input p-curr-obj-type,
            input p-curr-obj-code
            ) no-error.
     if error-status:error then return error.
     end.
     if temp-shop.cd-pb-alt then do:
       FOR EACH ub.prod-bc NO-LOCK WHERE
                ub.prod-bc.b-code = b-bc.b-code
               :
        if ub.prod-bc.b-str = string( b-bc.b-code ) AND temp-shop.cd-loc-alt then NEXT.
        run asc-gds in this-procedure (
          input rs-list-method,
          input rs-status,
          input line-mode,
          buffer ub.goods,
          buffer b-bc,
          buffer ub.gds-prt,
          buffer ub.gds-obj,
          buffer ub.price-list,
          buffer ub.units,
          buffer b-g-p,
          input ub.prod-bc.b-str,
          input ub.prod-bc.bc-on-type,
          input (if avail b-units then b-units.type else ub.units.type),
          input (if avail b-units then b-units.okei else ub.units.okei),
          input ub.sysconf.host-code,
          input p-curr-obj-type,
          input p-curr-obj-code
          ) no-error.
        if error-status:error then return error.
      END.
    end.
    end.
  END.
end.
          END.
        END.
      END.
    end.
  end.
  end.
END PROCEDURE .
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure asc-gds :
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
define input parameter line-mode as character no-undo .
DEFINE parameter buffer loc-goods for ub.goods.
DEFINE parameter buffer loc-bar-code for ub.bar-code.
DEFINE parameter buffer loc-gds-prt-root for ub.gds-prt.
DEFINE parameter buffer loc-gds-obj for ub.gds-obj.
DEFINE parameter buffer loc-price-list for ub.price-list.
DEFINE parameter buffer loc-units for ub.units.
DEFINE parameter buffer loc-gds-prt-term for ub.gds-prt.
DEFINE input parameter loc-prod-bc like ub.prod-bc.b-str.
DEFINE input parameter loc-bc-on-type like ub.prod-bc.bc-on-type.
DEFINE input parameter loc-bc-units-cli-type like ub.units.type.
DEFINE input parameter loc-bc-units-okei like ub.units.okei.
define input parameter parhost-code like ub.sysconf.host-code no-undo .
define input parameter parobj-type like ub.clients.obj-type no-undo .
define input parameter parobj-code like ub.clients.obj-code no-undo .
define variable IBM-good-code as character no-undo .
define variable bar_code as character no-undo .
define buffer buf_prod-bc for ub.prod-bc.
  do
  on error undo, return error
  :
    if loc-prod-bc <> "":U and loc-prod-bc <> ? then do:
      find first buf_prod-bc no-lock where
                buf_prod-bc.b-code = loc-bar-code.b-code
           and  buf_prod-bc.b-str = loc-prod-bc no-error.
      run ex-bbc in this-procedure ( input rs-list-method
                                    ,input rs-status
                                    ,input line-mode
                                    ,input l-empty-scale
                                    ,input loc-prod-bc
                                    ,input no
                                    ,buffer loc-bar-code
                                    ,buffer buf_prod-bc).
    end.
    else do:
      if  (LOOKUP( 'вес':U, loc-units.type ) = 0 or v-notcd)
      or loc-goods.unit-base <> loc-bar-code.unit-cli then do:
        if (temp-shop.cd-loc-base and loc-bar-code.unit-cli = loc-goods.unit-base)
        or (temp-shop.cd-loc-alt  and loc-bar-code.unit-cli <> loc-goods.unit-base)
        then
        run ex-bbc in this-procedure ( input rs-list-method
                                      ,input rs-status
                                      ,input line-mode
                                      ,input l-empty-scale
                                      ,input "":U
                                      ,input no
                                      ,buffer loc-bar-code
                                      ,buffer buf_prod-bc).
        if temp-shop.cd-bc-base
        and loc-bar-code.unit-cli = loc-goods.unit-base then do:
          RUN gen-bc( input loc-bar-code.b-code, output bar_code ).
          IBM-good-code  = trim( bar_code ) .
          run ex-bbc in this-procedure ( input rs-list-method
                                        ,input rs-status
                                        ,input line-mode
                                        ,input l-empty-scale
                                        ,input IBM-good-code
                                        ,input yes
                                        ,buffer loc-bar-code
                                        ,buffer buf_prod-bc).
        end.
        if temp-shop.cd-bc-alt
        and loc-bar-code.unit-cli <> loc-goods.unit-base
        then  do:
          RUN gen-bc( input loc-bar-code.b-code, output bar_code ).
          IBM-good-code  = trim( bar_code ) .
          run ex-bbc in this-procedure ( input rs-list-method
                                        ,input rs-status
                                        ,input line-mode
                                        ,input l-empty-scale
                                        ,input IBM-good-code
                                        ,input yes
                                        ,buffer loc-bar-code
                                        ,buffer buf_prod-bc).
        end.
      end.
    end.
  end.
end procedure.
DEFINE FRAME Dialog-Frame
    dsp-rs  AT ROW 1 COL 1 NO-LABEL
    b-exit  AT ROW 2 COL 1
    b-save  AT ROW 2 COL 11
    b-print AT ROW 2 COL 21
    b-hist  AT ROW 2 COL 31
    b-lkp   AT ROW 2 COL 41
    b-clr   AT ROW 2 COL 51
    b-help  AT ROW 2 COL 61
    b-cd    AT ROW 2 COL 81
    b-add   AT ROW 3 COL 19
    b-del   AT ROW 3 COL 33
    b-rest  AT ROW 3 COL 47
    v-obj-type at row 4 col 2 No-LABEL
    v-obj-code at row 4 col 6 No-LABEL
    b-obj at row 4 col 12
    v-obj-name at row 4 col 15 No-LABEL
    loc-art  AT ROW 4 COL 27 COLON-ALIGNED label "Начало артикула"
    loc-name AT ROW 4 COL 27 COLON-ALIGNED label "Начало названия" format "x(40)"
    loc-code AT ROW 4 COL 27 COLON-ALIGNED label "Бар-код (весь)" format "x(13)"
    loc-b-str AT ROW 4 COL 27 COLON-ALIGNED label "ДопБК" format "x(13)"
    a-n-c    at row 3 col 1 no-label
    T-loc-base AT ROW 3  COL 61
    T-pb-base  AT ROW 3  COL 80
    T-loc-alt  AT ROW 3.75 COL 61
    T-pb-alt   AT ROW 3.75 COL 80
    T-bc-base  AT ROW 4.5  COL 61
    T-sc-base  AT ROW 4.5  COL 80
    T-bc-alt   AT ROW 5.25  COL 61
    T-all-prt  AT ROW 5.25  COL 80
    T-parts-ser AT ROW 6 COL 80
    T-parts-not-blank AT ROW 6.75 COL 80
    T-parts-all AT ROW 7.5 COL 80
    RS-status at row 5 col 2 no-label
    b-macro AT ROW 4.7 col 44
    b-record AT ROW 4.7 col 47
    b-stop   AT ROW 4.7 col 47
    b-clear-macro AT ROW 4.7 col 47
    b-optimize AT ROW 5 COL 34
    f-tot-lns AT ROW 5 col 52 no-label
    br-list  AT ROW 6 COL 1
    br-option AT ROW 8.5 COL 70
    ub.clients.obj-name  at row 22 col 6 colon-aligned label "Пр-ль" fgcolor 4
    ub.gds-prt.node-name at row 22 col 45 colon-aligned label "Шкала" fgcolor 4
    ub.bar-code.b-code   at row 22 col 67 colon-aligned label "Код" format "9999999999" fgcolor 4
    SPACE(0) SKIP(0)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
        SIDE-LABELS NO-UNDERLINE THREE-D SCROLLABLE
        TITLE "СПИСОК  КОДОВ":L
        DEFAULT-BUTTON b-exit.
ASSIGN
  b-save:POPUP-MENU IN FRAME Dialog-Frame = MENU m-save:HANDLE
  FRAME Dialog-Frame:SCROLLABLE = FALSE
  b-save:MENU-MOUSE = 1
  b-optimize:POPUP-MENU IN FRAME Dialog-Frame = MENU m-optimize:HANDLE
  b-optimize:MENU-MOUSE = 1
  .
on
  return of
  scnblist.qnty in browse br-list,
  br-list in frame Dialog-Frame do:
  apply "choose" to b-lkp in frame Dialog-Frame.
  return no-apply.
end.
on choose of b-obj in frame Dialog-Frame do:
  run proc-b-obj in this-procedure ( input "change":U ).
end.
ON CHOOSE OF MENU-ITEM m-cd  DO:
define variable vss-include-info39 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(b-save :type in frame Dialog-Frame
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name in frame Dialog-Frame skip
    "Тип" self :type in frame Dialog-Frame skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to b-save in frame Dialog-Frame .
  if focus :handle <> b-save :handle in frame Dialog-Frame then do:
    return no-apply .
  end.
end.
run proc-cd in this-procedure no-error.
end.
ON CHOOSE OF MENU-ITEM m-title-save  DO:
define variable v-value as character no-undo .
  run gbl/d-prompt.w (
      'title=':u + "Введите ИМЯ СПИСКА КОДОВ" + '\':u
    + 'format=' + "X(60)" + '\':u
    + 'type=' + 'C':U + '\':u
    + 'fillin_row=2\':u
    + 'fillin_col=4\':u
    + 'fillin_width=60\':u
    + 'fillin_height=1\':u
    + 'max-chars=60\':u
    + 'readonly=no\':u
    , input-output v-value
    ).
if return-value = 'false':u then return NO-apply.
run create-scnblist-hist in this-procedure (input 'title'
                                     , input-output v-seq
                                     , input 0
                                     , input 'N':U
                                     , input v-value
                                     , input tot-lns
                                     , input "title"
                                     , input '':U
                                     , input '':U
                                     , input '':U
                                     , input ?
                                     ).
assign
frame Dialog-Frame:title = substitute("СПИСОК  КОДОВ &1", v-value).
END.
ON CHOOSE OF MENU-ITEM m-gds-save  DO:
define variable vss-include-info40 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(b-save :type in frame Dialog-Frame
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name in frame Dialog-Frame skip
    "Тип" self :type in frame Dialog-Frame skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to b-save in frame Dialog-Frame .
  if focus :handle <> b-save :handle in frame Dialog-Frame then do:
    return no-apply .
  end.
end.
  assign
    f-gds-name = "default.gds"
    glog = yes
    .
  system-dialog get-file f-gds-name
    filters "Списки товаров *.gds" "*.gds"
    ask-overwrite
    save-as
    use-filename
    update glog
    default-extension "gds".
  if not glog then do:
    apply "entry" to br-list in frame Dialog-Frame.
    return no-apply.
  end.
  output to value (f-gds-name).
  for each scnblist
  break by scnblist.gds-code
  :
    if first-of(scnblist.gds-code) then
    export scnblist.prod-type
          scnblist.prod-code
          scnblist.artic
          .
  end.
  output close.
END.
ON CHOOSE OF MENU-ITEM m-bb-save  DO:
define variable vss-include-info41 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(b-save :type in frame Dialog-Frame
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name in frame Dialog-Frame skip
    "Тип" self :type in frame Dialog-Frame skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to b-save in frame Dialog-Frame .
  if focus :handle <> b-save :handle in frame Dialog-Frame then do:
    return no-apply .
  end.
end.
  assign
    f-gds-name = "default.bb"
    glog = yes
    .
  system-dialog get-file f-gds-name
    filters "Списки кодов *.bb" "*.bb"
    ask-overwrite
    save-as
    use-filename
    update glog
    default-extension "bb".
  if not glog then do:
    apply "entry" to br-list in frame Dialog-Frame.
    return no-apply.
  end.
  output to value (f-gds-name).
  for each scnblist
  break by scnblist.gds-code
  :
    export
    scnblist.b-code
    scnblist.b-str
    scnblist.prod-type
    scnblist.prod-code
    scnblist.artic
    .
  end.
  output close.
END.
ON CHOOSE OF MENU-ITEM m-scn-save  DO:
define variable vss-include-info42 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(b-save :type in frame Dialog-Frame
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name in frame Dialog-Frame skip
    "Тип" self :type in frame Dialog-Frame skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to b-save in frame Dialog-Frame .
  if focus :handle <> b-save :handle in frame Dialog-Frame then do:
    return no-apply .
  end.
end.
run proc-scn-tsd in this-procedure no-error .
if error-status:error then return no-apply.
END.
ON CHOOSE OF MENU-ITEM m-macros-save  DO:
define variable vss-include-info43 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(b-save :type in frame Dialog-Frame
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name in frame Dialog-Frame skip
    "Тип" self :type in frame Dialog-Frame skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to b-save in frame Dialog-Frame .
  if focus :handle <> b-save :handle in frame Dialog-Frame then do:
    return no-apply .
  end.
end.
run proc-macros in this-procedure no-error .
if error-status:error then return no-apply.
END.
ON CHOOSE OF MENU-ITEM m-xls-save  DO:
define variable vss-include-info44 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(b-save :type in frame Dialog-Frame
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name in frame Dialog-Frame skip
    "Тип" self :type in frame Dialog-Frame skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to b-save in frame Dialog-Frame .
  if focus :handle <> b-save :handle in frame Dialog-Frame then do:
    return no-apply .
  end.
end.
do on stop  undo, return no-apply
  on error undo, return no-apply
  on quit  undo, return no-apply
:
  run str/scnlbxls.p (
                 input parparentproc
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                )
    no-error.
  run waitfram-hide in this-procedure .
end.
END.
ON CHOOSE OF MENU-ITEM m-delnprod-bc
DO:
    optimize-option = "delnprod-bc":U.
    optimize-label = self:label.
    dsp-rs = menu-ITEM m-delnprod-bc:label in menu m-optimize.
    apply "choose" to b-optimize in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m-repnprod-bc
DO:
    optimize-option = "repnprod-bc":U.
    optimize-label = self:label.
    dsp-rs = menu-ITEM m-repnprod-bc:label in menu m-optimize.
    apply "choose" to b-optimize in frame Dialog-Frame.
END.
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref45 as character no-undo .
define variable varpgscales-pref45 as character no-undo.
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref-type46 as character no-undo.
varscales-pref45  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'sclspref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varscales-pref45
  ,output varscales-pref-type46
  ) no-error .
if varscales-pref45 = ? then do:
  assign
  varscales-pref45 = '21,23,25':U.
end.
define variable varpgscales-pref-type46 as character no-undo.
varpgscales-pref45  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'scpgpref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varpgscales-pref45
  ,output varpgscales-pref-type46
  ) no-error .
if varpgscales-pref45 = ? then do:
  assign
  varpgscales-pref45 = '24IIIIIQQ000C,28IIIIIQQQ00C':U.
end.
on value-changed of a-n-c in frame Dialog-Frame do:
  run proc-valchg-a-n-c in this-procedure  no-error.
  return no-apply.
end.
on any-printable of br-list in frame Dialog-Frame do:
  run proc-any-printable-br-list in this-procedure   no-error.
  return no-apply.
end.
on backspace of br-list in frame Dialog-Frame do:
  run proc-backspace-br-list in this-procedure   no-error.
  return no-apply.
end.
ON return OF loc-code IN FRAME Dialog-Frame do:
  run proc-mouse-dbl-click-loc-code in this-procedure   no-error.
  return no-apply.
end.
ON return, Ctrl-J OF loc-b-str IN FRAME Dialog-Frame do:
  run proc-mouse-dbl-click-loc-b-str in this-procedure   no-error.
  return no-apply.
end.
ON return, Ctrl-J OF loc-name IN FRAME Dialog-Frame do:
  run proc-mouse-dbl-click-loc-name in this-procedure   no-error.
  return no-apply.
end.
PROCEDURE proc-valchg-a-n-c:
  case input frame Dialog-Frame a-n-c :
    when "art" then do:
      apply "entry" to br-list in frame Dialog-Frame.
      hide loc-name loc-code
     loc-b-str
      in frame Dialog-Frame.
      loc-art = "".
    end.
    when "name" then do:
      enable loc-name with frame Dialog-Frame.
      disp loc-name with frame Dialog-Frame.
      hide loc-art loc-code
     loc-b-str
      in frame Dialog-Frame.
      apply "entry" to loc-name in frame Dialog-Frame.
    end.
    when "code"
 or when "DataMatrix" then
    do:
      enable loc-code with frame Dialog-Frame.
      disp loc-code with frame Dialog-Frame.
      hide loc-art loc-name
     loc-b-str
      in frame Dialog-Frame.
      apply "entry" to loc-code in frame Dialog-Frame.
    end.
    when "b-str" then do:
      enable loc-b-str with frame Dialog-Frame.
      disp loc-b-str with frame Dialog-Frame.
      hide loc-art loc-name loc-code in frame Dialog-Frame.
      apply "entry" to loc-b-str in frame Dialog-Frame.
    end.
  end CASE.
END PROCEDURE.
PROCEDURE proc-any-printable-br-list :
  if input frame Dialog-Frame a-n-c = "art" then do:
    if last-event:label = " " and
       loc-art = "" then
    return error.
    find first l-scnblist where
                l-scnblist.artic begins (loc-art + last-event:label)
               no-lock no-error.
    if available l-scnblist then do:
      loc-art = loc-art + last-event:label.
      disp loc-art with frame Dialog-Frame.
      line-rec = recid (l-scnblist).
      reposition br-list to recid line-rec no-error.
      apply "value-changed" to br-list in frame Dialog-Frame.
    end.
  end.
END PROCEDURE.
PROCEDURE proc-backspace-br-list:
  if input frame Dialog-Frame a-n-c = "art" then do:
    if loc-art = "" then
      return error.
    loc-art = substr (loc-art, 1, length (loc-art) - 1).
    find first l-scnblist where
                l-scnblist.artic begins loc-art
               no-lock.
    disp loc-art with frame Dialog-Frame.
    line-rec = recid (l-scnblist).
    reposition br-list to recid line-rec no-error.
    apply "value-changed" to br-list in frame Dialog-Frame.
  end.
END PROCEDURE.
PROCEDURE proc-mouse-dbl-click-loc-code:
def var str-code as integer no-undo.
define variable varresult   as character         no-undo.
define variable vartype-bc  as character         no-undo.
define variable varweight   as decimal           no-undo.
define buffer l-goods for ub.goods.
define buffer l-bar-code for ub.bar-code.
define buffer buf_bar-code for ub.bar-code .
define buffer buf_prod-bc for ub.prod-bc.
define buffer buf_place for ub.place.
  if
  frame Dialog-Frame
  loc-code <> loc-code:screen-value OR
     last-event:label = "Ctrl-J" then
    contin = no.
  assign
  frame Dialog-Frame
  loc-code
  a-n-c.
    find first l-bar-code no-lock where
          l-bar-code.b-code = integer(loc-code) no-error.
  if available l-bar-code then do:
      if last-event:label = "Ctrl-J" then
        find next l-scnblist where
                 l-scnblist.gds-code = l-bar-code.gds-code
                          and l-scnblist.b-code   = l-bar-code.b-code
                no-lock no-error.
      else
        find first l-scnblist where
                 l-scnblist.gds-code = l-bar-code.gds-code
                          and l-scnblist.b-code   = l-bar-code.b-code
                no-lock no-error.
    if available l-scnblist then do:
      line-rec = recid (l-scnblist).
      reposition br-list to recid line-rec no-error.
      apply "value-changed" to br-list in frame Dialog-Frame.
    end.
    else do:
      message "Строка не найдена."
              view-as alert-box error.
    end.
  end.
  else
    message "Бар-код не найден."
            view-as alert-box error.
  apply "entry" to loc-code in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-mouse-dbl-click-loc-b-str:
def var str-code as integer no-undo.
define variable varresult   as character         no-undo.
define variable vartype-bc  as character         no-undo.
define variable varweight   as decimal           no-undo.
define buffer l-prod-bc for ub.prod-bc.
define buffer l-bar-code for ub.bar-code.
define buffer buf_bar-code for ub.bar-code .
define buffer buf_prod-bc for ub.prod-bc.
define buffer buf_place for ub.place.
  assign
  frame Dialog-Frame
  loc-b-str.
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_bc-rcnz in g#libbcrcn
(
 input  parparentproc
,input  loc-b-str
,input  ?
,input  p-curr-obj-type
,input  p-curr-obj-code
,input  yes
,input  no
,input  varscales-pref45
,input  varpgscales-pref45
,output varresult
,output vartype-bc
,output varweight
,buffer buf_bar-code
,buffer buf_prod-bc
,buffer buf_place
) no-error.
  if available buf_prod-bc then do:
    find first l-prod-bc where
                l-prod-bc.b-str = buf_prod-bc.b-str
            AND l-prod-bc.b-code = buf_bar-code.b-code No-LOCK.
    find first l-scnblist where
                l-scnblist.gds-code = buf_bar-code.gds-code AND
                l-scnblist.b-code = buf_bar-code.b-code AND
                l-scnblist.b-str = buf_prod-bc.b-str no-lock no-error.
    if available l-scnblist then do:
      line-rec = recid (l-scnblist).
      reposition br-list to recid line-rec no-error.
      apply "value-changed" to br-list in frame Dialog-Frame.
    end.
    else
      message "Строка не найдена."
              view-as alert-box error.
  end.
  else do:
    if available buf_bar-code then do:
      find first l-bar-code where
                  l-bar-code.b-code = buf_bar-code.b-code No-LOCK.
      find first l-scnblist where
                  l-scnblist.gds-code = buf_bar-code.gds-code AND
                  l-scnblist.b-code = buf_bar-code.b-code AND
                  l-scnblist.b-str = loc-b-str no-lock no-error.
      if available l-scnblist then do:
        line-rec = recid (l-scnblist).
        reposition br-list to recid line-rec no-error.
        apply "value-changed" to br-list in frame Dialog-Frame.
      end.
      else
        message "Строка не найдена."
                view-as alert-box error.
    end.
    else
      message "ДопБК не найден."
              view-as alert-box error.
  end.
  apply "entry" to loc-b-str in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE  proc-mouse-dbl-click-loc-name:
  assign
  frame Dialog-Frame
  loc-name.
    if last-event:label = "Ctrl-J" then
      find next l-scnblist where
                can-find (ub.goods where ub.goods.artic = l-scnblist.artic and
                ub.goods.prod-type = l-scnblist.prod-type and
                ub.goods.prod-code = l-scnblist.prod-code and
                ub.goods.gds-name begins loc-name no-lock) no-lock no-error.
    else
      find first l-scnblist where
                can-find (ub.goods where ub.goods.artic = l-scnblist.artic and
                ub.goods.prod-type = l-scnblist.prod-type and
                ub.goods.prod-code = l-scnblist.prod-code and
                ub.goods.gds-name begins loc-name no-lock) no-lock no-error.
    if available l-scnblist then do:
      line-rec = recid (l-scnblist).
      reposition br-list to recid line-rec no-error.
         apply "value-changed" to br-list in frame Dialog-Frame.
    end.
    else do:
      message "Строка не найдена."
              view-as alert-box error.
    end.
  apply "entry" to loc-name in frame Dialog-Frame.
END PROCEDURE.
on value-changed of br-list in frame Dialog-Frame do:
if not available scnblist or recid (scnblist) <> line-rec then do:
    hide loc-art in frame Dialog-Frame.
    loc-art = "".
end.
if available scnblist then do:     find ub.clients where ub.clients.obj-type = scnblist.prod-type                    and ub.clients.obj-code = scnblist.prod-code no-lock.     find ub.gds-prt where ub.gds-prt.upper-code = scnblist.prt-root no-lock.     find ub.bar-code where ub.bar-code.gds-code  = scnblist.gds-code                     and ub.bar-code.node-code = ub.gds-prt.node-code                     and ub.bar-code.unit-cli  = scnblist.unit-base                     and ub.bar-code.in-code   = ""                     and ub.bar-code.part-code = "" no-lock.     disp ub.clients.obj-name ub.gds-prt.node-name ub.bar-code.b-code tot-lns @ f-tot-lns with frame Dialog-Frame.   end.   disp tot-lns @ f-tot-lns with frame Dialog-Frame.
end.
ON CHOOSE OF b-print IN FRAME Dialog-Frame DO:
run rep/pri-lst.w (
               input parparentproc
             , input p-curr-obj-type
             , input p-curr-obj-code
             , input "LIST"
             , input "bb-list").
apply "entry" to br-list in frame Dialog-Frame.
END.
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame DO:
if not available scnblist then do:
  message "Неправильно выбран товар."
          view-as alert-box error.
  return no-apply.
end.
find ub.goods where scnblist.artic = ub.goods.artic
            and scnblist.prod-type = ub.goods.prod-type
            and scnblist.prod-code = ub.goods.prod-code no-lock.
run str/showgds.p ( input parparentproc
                   ,input this-procedure:handle
                   ,input  goods.gds-code
                   ,input 'ПРОСМОТР':U).
apply "entry" to br-list in frame Dialog-Frame.
END.
ON CHOOSE OF b-hist IN FRAME Dialog-Frame DO:
define buffer buf_scnblist-hist for scnblist-hist.
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input 43
                                            ,input yes
                                            ,input no
                                            ).
find first buf_scnblist-hist no-lock where buf_scnblist-hist.id = 0 no-error .
PUT  STREAM PrnLibStream unformatted
SPACE(25) "История создания списка кодов "
(if available buf_scnblist-hist
then buf_scnblist-hist.des
else "БЕЗЫМЯННЫЙ") skip(0)
space(25) cur-time-print() skip(1)
.
put stream PrnLibStream unformatted
string("№", "X(9)") chr(32)
string("Действие", "X(9)") chr(32)
string("записей", "X(10)") chr(32)
string(" = итого", "X(12)") chr(32)
string("Множество", "X(155)")
skip(0)
fill('-':U, 9) chr(32)
fill('-':U, 9) chr(32)
fill('-':U, 9) chr(32)
fill('-':U, 12) chr(32)
fill('-':U, 155)
skip(0)
.
for each buf_scnblist-hist where buf_scnblist-hist.id > 0
by buf_scnblist-hist.id
:
  put stream PrnLibStream unformatted
  (if buf_scnblist-hist.line = 0
   then string(buf_scnblist-hist.id, ">>>>>>>>9")
   else fill(chr(32) , 9)
  )  chr(32)
  (if buf_scnblist-hist.item_ <> '':U
   then string(buf_scnblist-hist.hist-mode, "X(8)")
   else fill( chr(32), 8)) chr(32)
  string(buf_scnblist-hist.num-add, "->>>>>>>>9") chr(32) chr(32) chr(32) chr(32)
  string(buf_scnblist-hist.num-recs, ">>>>>>>>9")  chr(32)
  string(buf_scnblist-hist.des, "X(155)") skip.
end.
output stream prnlibstream close.
  run prn-lib-prn-file in this-procedure (
                                            input parParentProc
                                            ,input 8
                                            ).
  apply "entry" to br-list in frame Dialog-Frame.
END.
ON CHOOSE OF b-clr IN FRAME Dialog-Frame  DO:
define variable glog as logical no-undo .
define buffer buf-scnblist-hist for scnblist-hist.
glog = no.
message "Удаление всех строк списка. Вы уверены ?"
        view-as alert-box question buttons OK-Cancel update glog.
if not glog then return no-apply.
if session:set-wait-state( "COMPILER" )  then .
for each scnblist:
  delete scnblist.
end.
if session:set-wait-state( "" )  then .
tot-lns = 0.
v-seq = 1.
for each buf-scnblist-hist:
  delete buf-scnblist-hist.
end.
run create-scnblist-hist in this-procedure (input 'ДОБАВЛЕНИЕ':U
                                     , input-output v-seq
                                     , input 0
                                     , input '0':U
                                     , input "# Список кодов очищен."
                                     , input 0
                                     , input "clear"
                                     , input '':U
                                     , input '':U
                                     , input '':U
                                     , input ?
                                     ).
display
tot-lns @ f-tot-lns
? @ ub.clients.obj-name
? @ ub.gds-prt.node-name
? @ ub.bar-code.b-code with frame Dialog-Frame.
run UI-on.
END.
ON VALUE-CHANGED OF RS-Status IN FRAME Dialog-Frame DO:
  assign
  RS-status.
END.
ON CHOOSE OF b-cd IN FRAME Dialog-Frame DO:
run proc-b-cd in this-procedure  ( input no) no-error.
if error-status:error then return no-apply.
apply "entry" to br-list in frame Dialog-Frame.
END.
ON CHOOSE OF b-optimize IN FRAME Dialog-Frame DO:
if optimize-option = "" then do:
  run gbl/pop-up.p (self:handle, no) no-error.
end.
if optimize-option = "" then do:
  return no-apply.
end.
run create-scnblist-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                    , input-output v-seq
                                    , input 0
                                    , input '~~':U
                                    , input substitute('Оптимизация списка &1 - &2'
                                                  , stat-line(rs-status)
                                                  , optimize-label)
                                    , input tot-lns
                                    , input 'optimize'
                                    , input rs-status
                                    , input optimize-option
                                    , input '':U
                                    , input ?
                                    ).
run rs-do in this-procedure ( input no, input no, input 'optimize', input rs-status, input 'ДОБАВЛЕНИЕ':U, input (v-seq - 1)) no-error .
if error-status:error then do:
  optimize-option = "".
  optimize-label = '':U.
  return no-apply.
end.
apply "entry" to br-list in frame Dialog-Frame.
END.
ON RETURN of scnblist.qnty in browse br-list do:
  APPLY "LEAVE" to self.
END.
define variable vss-include-info47 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-P, CTRL-З of frame Dialog-Frame anywhere do:
  if b-print :sensitive then DO: apply "CHOOSE":U to b-print in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info48 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F3 of frame Dialog-Frame anywhere do:
  if b-lkp :sensitive then DO: apply "CHOOSE":U to b-lkp in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info49 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-N, CTRL-Т of frame Dialog-Frame anywhere do:
  if b-add :sensitive then DO: apply "CHOOSE":U to b-add in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info50 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F8 of frame Dialog-Frame anywhere do:
  if b-del :sensitive then DO: apply "CHOOSE":U to b-del in frame Dialog-Frame. END.
  return no-apply.
end.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame Dialog-Frame :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame Dialog-Frame
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse br-list :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
run diasize_init in this-procedure .
def var vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-no-context as logical no-undo .
define variable v-user-obj-type as character no-undo .
define variable v-user-obj-code as integer no-undo .
FUNCTION prepare-rowid returns character ( input p-uniq-key-rec as character
                                         , input p-no-context as logical ):
define variable v-uniq-key-rec as character no-undo .
if p-no-context and p-uniq-key-rec begins 'user-obj':U then do:
  v-uniq-key-rec = 'clients':U + chr(3) +
                  entry(4, p-uniq-key-rec, chr(3)) + chr(3) +
                  entry(5, p-uniq-key-rec, chr(3)).
end.
else do:
  v-uniq-key-rec = p-uniq-key-rec.
  case entry(1, p-uniq-key-rec, chr(3)):
     when 'user-obj':U then do:
       entry(lookup("user-id", buffer ub.user-obj:handle:keys) + 1, v-uniq-key-rec, chr(3)) = v-cntxt-userid.
       entry(lookup("db-num", buffer ub.user-obj:handle:keys) + 1, v-uniq-key-rec, chr(3)) = string(v-cntxt-db-num).
     end.
  end case.
end.
return v-uniq-key-rec.
end function.
procedure find-user-obj-rowid :
define input parameter p-rowid as rowid no-undo .
define input parameter p-no-context as logical no-undo .
define output parameter p-user-obj-type as character no-undo .
define output parameter p-user-obj-code as integer no-undo .
define buffer user-obj_clients for ub.clients.
define buffer user-obj_user-obj for ub.user-obj .
if p-no-context then do:
  find first user-obj_clients no-lock where rowid(user-obj_clients) = p-rowid.
  assign
  p-user-obj-type = user-obj_clients.obj-type
  p-user-obj-code = user-obj_clients.obj-code.
end.
else do:
  find first user-obj_user-obj no-lock where rowid(user-obj_user-obj) = p-rowid no-error.
  if not available user-obj_user-obj then do:
    undo, return error substitute("Не удалось выполнить в данной БД записанные действия пользователя").
  end.
  assign
  p-user-obj-type = user-obj_user-obj.obj-type
  p-user-obj-code = user-obj_user-obj.obj-code.
end.
end procedure.
define variable an-listp-start-macro-id as integer no-undo init ?.
define variable an-listp-end-macro-id as integer no-undo  init ?.
define variable an-listp-macros-label-id as integer   no-undo .
define variable v-macro-is-running as logical no-undo .
define variable v-current-step as integer no-undo .
define variable v-expand as logical no-undo .
define variable v-downed as character no-undo .
define variable p-title as character no-undo .
define variable bttns as character no-undo .
define variable p-keep-query as logical no-undo .
define variable vss-include-info56 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define     temp-table keep-macro-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
procedure assign-nums :
define input-output parameter p-num-add as integer no-undo .
define input-output parameter p-num-rec as integer no-undo .
define input-output parameter p-num-ignored as integer no-undo .
define input parameter p-line-mode as character no-undo .
assign
p-num-add  = lns-cnt - v-num-add
p-num-rec = (if line-mode = 'ОСТАВИТЬ':U
                          then (tot-lns + p-num-add)
                          else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))
tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)
p-num-ignored = lns-ignore  - v-num-ignored
v-num-add             = lns-cnt
v-num-ignored         = lns-ignore
.
END PROCEDURE.
ON CHOOSE OF B-add IN FRAME Dialog-Frame
or INSERT-MODE of br-list
DO:
define variable glog as logical no-undo .
define buffer buf-scnblist-hist for scnblist-hist.
define buffer buf_macro-list-hist for macro-list-hist.
define buffer buf_keep-macro-list-hist for keep-macro-list-hist.
 if p-keep-query then do:
    glog = no.
    message "Реинициализация списка. Вы уверены ?"
            view-as alert-box question buttons OK-Cancel update glog.
    if not glog then return no-apply.
    if session:set-wait-state( "COMPILER" )  then .
    for each scnblist:
      delete scnblist.
    end.
    if session:set-wait-state( "" )  then .
    tot-lns = 0.
    v-seq = 1.
    for each buf-scnblist-hist:
      delete buf-scnblist-hist.
    end.
   for each buf_keep-macro-list-hist:
     create buf_macro-list-hist.
   end.
   run proc-macro-play in this-procedure ( input 0, input yes, input 0).
   run create-scnblist-hist in this-procedure (
                                          input 'ДОБАВЛЕНИЕ':U
                                        , input-output v-seq
                                        , input 0
                                        , input '0':U
                                        , input "# Реинициализация списка."
                                        , input 0
                                        , input "init"
                                        , input '':U
                                        , input '':U
                                        , input '':U
                                        , input ?
                                        ).
    display
    tot-lns @ f-tot-lns
    with frame Dialog-Frame.
    run ui-on in this-procedure .
 end.
 else do:
   assign rs-list-method = "single".
   run proc-b-add in this-procedure(input no
                                  ,input ?
                                  ,input rs-list-method
                                  ,input rs-status)  no-error .
  if error-status:error then return no-apply.
end.
END.
ON CHOOSE OF B-del IN FRAME Dialog-Frame
or DELETE-CHARACTER of br-list
DO:
  if not available scnblist then return no-apply.
  assign rs-list-method = "single".
  run proc-b-del in this-procedure(no, ?, (rs-list-method + chr(4) +
                                           (if scnblist.b-str <> '':U and not scnblist.loc-ean
                                           then 'prod-bc':U
                                           else (if scnblist.loc-ean
                                                 then 'loc-ean':U
                                                 else 'bar-code':U)
                                           )
                                           )
  , rs-status) no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-rest IN FRAME Dialog-Frame
DO:
if not available scnblist then return no-apply.
  assign rs-list-method = "single".
  run proc-b-rest in this-procedure(no, ?, (rs-list-method + chr(4) +
                                           (if scnblist.b-str <> '':U and not scnblist.loc-ean
                                           then 'prod-bc':U
                                           else (if scnblist.loc-ean
                                                 then 'loc-ean':U
                                                 else 'bar-code':U)
                                           )
                                           )
  , rs-status) no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-macro IN FRAME Dialog-Frame
DO:
run proc-b-macro in this-procedure ( input 'file') no-error .
if error-status:error then return no-apply.
END.
ON CHOOSE OF B-record IN FRAME Dialog-Frame
DO:
define variable glog as logical no-undo .
message
"Начать запись макроса формирования списка?"
view-as alert-box QUESTION buttons yes-no update glog.
if not glog then return no-apply.
assign
an-listp-start-macro-id = v-seq
an-listp-end-macro-id = ?
.
disable
b-record with frame Dialog-Frame .
hide
b-record
b-macro
in frame Dialog-Frame .
enable
b-stop with frame Dialog-Frame .
run create-scnblist-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                    , input-output v-seq
                                    , input 0
                                    , input 'o':U
                                    , input "Начата запись макроса формирования списка"
                                    , input tot-lns
                                    , input 'macro':U
                                    , input '':U
                                    , input '':U
                                    , input '':U
                                    , input ?
                                    ).
END.
ON CHOOSE OF B-stop IN FRAME Dialog-Frame
DO:
define variable glog as logical no-undo .
define variable v-id as integer no-undo .
define buffer buf_scnblist-hist for scnblist-hist.
message
"Закончить запись макроса формирования списка?"
view-as alert-box QUESTION buttons yes-no update glog.
if not glog then return no-apply.
assign
an-listp-end-macro-id = v-seq.
disable
b-stop with frame Dialog-Frame .
hide
b-stop in frame Dialog-Frame .
enable
b-record
b-macro
with frame Dialog-Frame .
run create-scnblist-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                    , input-output v-seq
                                    , input 0
                                    , input '[]':U
                                    , input "Закончена запись макроса формирования списка"
                                    , input tot-lns
                                    , input 'macro':U
                                    , input '':U
                                    , input '':U
                                    , input '':U
                                    , input ?
                                    ).
for each macro-list-hist:
  delete macro-list-hist.
end.
for each buf_scnblist-hist where
        buf_scnblist-hist.id >=  an-listp-start-macro-id
  and  buf_scnblist-hist.id <=  an-listp-end-macro-id:
  create macro-list-hist.
  buffer-copy buf_scnblist-hist
  except id num-recs num-add num-ignored
  to macro-list-hist
  assign
  macro-list-hist.id = (if macro-list-hist.line = 0 then v-id + 1 else v-id)
  v-id = (if macro-list-hist.line = 0 then v-id + 1 else v-id)
  .
end.
END.
ON CHOOSE OF b-clear-macro IN FRAME Dialog-Frame
DO:
disable
b-clear-macro with frame Dialog-Frame .
assign
an-listp-start-macro-id = ?
an-listp-end-macro-id = ?
an-listp-macros-label-id = 0
.
for each macro-list-hist:
  delete macro-list-hist.
end.
hide
b-clear-macro in frame Dialog-Frame .
enable
b-record
b-macro
with frame Dialog-Frame .
END.
ON VALUE-CHANGED OF br-option IN FRAME Dialog-Frame
DO:
  assign
  Rs-list-method = temp-list.fvalue
  .
  run proc-cd2 in this-procedure.
  run proc-vc-rs-list-method in this-procedure no-error .
  if error-status:error then return no-apply.
END.
PROCEDURE get-operation :
define input parameter p-message as character no-undo .
define output parameter p-operation as integer no-undo .
  do
  on error undo, return error
  :
    run gbl/d-askw.w (
                  input "Выбор операции над заданным списком"
                 ,input (p-message + chr(10) +
                         "Выберите операцию, которую Вы хотите применить к полученному списку" +  chr(10) )
                 ,input "|"
                ,input  ("Добавить" + (if p-keep-query then "^disable" else '':U) + "|" +
                         "Удалить" + "|" +
                         "Оставить" + "|" +
                         "Отказ")
                 ,input ("Добавить полученный список к уже имеющемуся" + "|" +
                        "Удалить полученный список из уже имеющегося" + "|" +
                        "Оставить в уже имеющемся списке только элементы полученного списка" +  "|" +
                        "Ничего не делать")
                 ,input  (if p-keep-query then 2 else 1)
                 ,input  4
                 ,output p-operation).
   if p-operation = 4 then do:
      return error .
   end.
  end.
END PROCEDURE.
PROCEDURE proc-fill-temp-list :
  define variable v-index               as integer   no-undo .
  define variable v-num-entries-options as integer   no-undo .
  do
  on error undo, return error
  :
    assign
      v-num-entries-options = num-entries("Текущая строка,single,                           Товары-коды по типам,goods,                       Товар-лок.код,goods-b-code,                       Товар-лок.код(EAN),goods-b-code-ean,              Товар-Доп.БК,goods-b-str,                         Бар-код в чеке-последний чек,last-check,           Все выключенные ДопБк,prod-bc-off,                Коды на кассе,cd-codes,                           Лок.коды просроч.партий своб.зоны,parts-last-date,         Лок.коды просроч.зарезерв. партий,parts-rsrv-last-date,    Лок.коды(EAN) просроч.партий своб.зоны,parts-ean-last-date,         Лок.коды(EAN) просроч.зарезерв. партий,parts-ean-rsrv-last-date,    Лок.коды ФиБ партий своб.зоны,parts-fib,         Лок.коды зарезерв ФиБ партий,parts-rsrv-fib,    Лок.коды(EAN) ФиБ партий своб.зоны,parts-ean-fib,         Лок.коды(EAN) зарезерв. ФиБ партий,parts-ean-rsrv-fib,    Лок.коды товаров с продажей по партиям,parts-cashparts,         Лок.коды (EAN)товаров с продажей по партиям,parts-ean-cashparts,         Лок.коды законч.на объ.партий,parts-end-date-obj,         Лок.коды(EAN) законч.на объ.партий,parts-ean-end-date-obj,         Лок.весовые коды в БД,loc-sc-codes,          Лок.штучные коды для весов в БД,loc-pg-codes,          Глоб.весовые коды,gbl-sc-codes,          Файл списка товаров,file-gds,                     Фильтр баркодов,filter,                           Все,all,                                          Список товаров,gds-list,                          Мобильн. сканер,scaner")
    .
    do v-index = 1 to v-num-entries-options by 2
    :
      create temp-list.
      assign
        temp-list.fname  = trim(entry(v-index
                                     ,"Текущая строка,single,                           Товары-коды по типам,goods,                       Товар-лок.код,goods-b-code,                       Товар-лок.код(EAN),goods-b-code-ean,              Товар-Доп.БК,goods-b-str,                         Бар-код в чеке-последний чек,last-check,           Все выключенные ДопБк,prod-bc-off,                Коды на кассе,cd-codes,                           Лок.коды просроч.партий своб.зоны,parts-last-date,         Лок.коды просроч.зарезерв. партий,parts-rsrv-last-date,    Лок.коды(EAN) просроч.партий своб.зоны,parts-ean-last-date,         Лок.коды(EAN) просроч.зарезерв. партий,parts-ean-rsrv-last-date,    Лок.коды ФиБ партий своб.зоны,parts-fib,         Лок.коды зарезерв ФиБ партий,parts-rsrv-fib,    Лок.коды(EAN) ФиБ партий своб.зоны,parts-ean-fib,         Лок.коды(EAN) зарезерв. ФиБ партий,parts-ean-rsrv-fib,    Лок.коды товаров с продажей по партиям,parts-cashparts,         Лок.коды (EAN)товаров с продажей по партиям,parts-ean-cashparts,         Лок.коды законч.на объ.партий,parts-end-date-obj,         Лок.коды(EAN) законч.на объ.партий,parts-ean-end-date-obj,         Лок.весовые коды в БД,loc-sc-codes,          Лок.штучные коды для весов в БД,loc-pg-codes,          Глоб.весовые коды,gbl-sc-codes,          Файл списка товаров,file-gds,                     Фильтр баркодов,filter,                           Все,all,                                          Список товаров,gds-list,                          Мобильн. сканер,scaner"
                                     )
                               ,chr(32)
                               )
        temp-list.fvalue = trim(entry(v-index + 1
                                     ,"Текущая строка,single,                           Товары-коды по типам,goods,                       Товар-лок.код,goods-b-code,                       Товар-лок.код(EAN),goods-b-code-ean,              Товар-Доп.БК,goods-b-str,                         Бар-код в чеке-последний чек,last-check,           Все выключенные ДопБк,prod-bc-off,                Коды на кассе,cd-codes,                           Лок.коды просроч.партий своб.зоны,parts-last-date,         Лок.коды просроч.зарезерв. партий,parts-rsrv-last-date,    Лок.коды(EAN) просроч.партий своб.зоны,parts-ean-last-date,         Лок.коды(EAN) просроч.зарезерв. партий,parts-ean-rsrv-last-date,    Лок.коды ФиБ партий своб.зоны,parts-fib,         Лок.коды зарезерв ФиБ партий,parts-rsrv-fib,    Лок.коды(EAN) ФиБ партий своб.зоны,parts-ean-fib,         Лок.коды(EAN) зарезерв. ФиБ партий,parts-ean-rsrv-fib,    Лок.коды товаров с продажей по партиям,parts-cashparts,         Лок.коды (EAN)товаров с продажей по партиям,parts-ean-cashparts,         Лок.коды законч.на объ.партий,parts-end-date-obj,         Лок.коды(EAN) законч.на объ.партий,parts-ean-end-date-obj,         Лок.весовые коды в БД,loc-sc-codes,          Лок.штучные коды для весов в БД,loc-pg-codes,          Глоб.весовые коды,gbl-sc-codes,          Файл списка товаров,file-gds,                     Фильтр баркодов,filter,                           Все,all,                                          Список товаров,gds-list,                          Мобильн. сканер,scaner"
                                     )
                               ,chr(32)
                               )
        temp-list.id     = v-index
      .
    end.
  end.
END PROCEDURE.
procedure proc-b-macro :
define input parameter p-option as character no-undo .
define variable glog as logical no-undo .
define variable v-id as integer no-undo .
define variable v-result as character no-undo .
define variable v-des as character no-undo .
define variable v-hist-mode as character no-undo .
define variable v-file as logical no-undo .
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
define variable v-rid-list as character no-undo .
define variable v-ok as logical no-undo .
define buffer buf_scnblist-hist for scnblist-hist.
define buffer buf_clob-bind for ub.clob-bind.
define buffer buf_clob-data for ub.clob-data.
do
on error undo, return error
:
  if v-macro-is-running then do:
  end.
  else do:
    glog = yes.
    if an-listp-start-macro-id >= 1 then do:
      case p-option:
        when "file" then do:
      message
      "Согласно командам формирования списка из записанного макроса"
      view-as alert-box question buttons OK-Cancel update glog.
        end.
        when "lob" then do:
          message
          "Нелья!"
          view-as alert-box question buttons OK-Cancel update glog.
          run ui-on in this-procedure .
          return error.
        end.
      end case.
      if not glog then do:
        run ui-on in this-procedure .
        return error.
      end.
      if an-listp-end-macro-id = ? then do:
        assign
        an-listp-end-macro-id  = v-seq.
        for each macro-list-hist:
          delete macro-list-hist.
        end.
        for each buf_scnblist-hist where
                buf_scnblist-hist.id >=  an-listp-start-macro-id
          and  buf_scnblist-hist.id <=  an-listp-end-macro-id:
          create macro-list-hist.
          buffer-copy buf_scnblist-hist
          except id num-recs num-add num-ignored
          to macro-list-hist
          assign
          macro-list-hist.id = (if macro-list-hist.line = 0 then v-id + 1 else v-id)
          v-id = (if macro-list-hist.line = 0 then v-id + 1 else v-id)
          macro-list-hist.done = no
          .
        end.
      end.
      else do:
        find last macro-list-hist no-error.
        if available macro-list-hist then do:
          v-id = macro-list-hist.id.
        end.
      end.
    end.
    else do:
      case p-option:
        when "file" then do:
      message
      "Согласно командам формирования списка из ранее сохраненного в файле макроса"
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run ui-on in this-procedure .
        return error.
      end.
      system-dialog get-file f-name
        filters "Макрос формирования списка *.bbm" "*.bbm"
        title "Выберите файл макроса"
        INITIAL-DIR "."
        return-to-start-dir
        must-exist
        update glog
        default-extension "bbm".
      if not glog then do:
        run ui-on in this-procedure .
        return error.
      end.
        end.
        when "lob" then do:
          message
          "Согласно командам формирования списка из макроса, сохраненного в БД"
          view-as alert-box question buttons OK-Cancel update glog.
          if not glog then do:
            run ui-on in this-procedure .
            return error.
          end.
          run ref/clobbnds.w ( input parparentproc
                              ,input this-procedure:handle
                              ,input 'b-sel'
                              ,input "uniq-key-rec"
                              ,input ""
                              ,input 'list-macro':U
                              ,input 'bb-list'
                              ,input -1
                              ,input-output v-rid-list) no-error.
          if v-rid-list = '' then do:
            run ui-on in this-procedure.
            return error.
          end.
          find first buf_clob-bind no-lock where
                    recid(buf_clob-bind) = integer(v-rid-list) no-error.
          if not available buf_clob-bind then do:
            message
            "Не найдена ссылка на макрос, сохраненный в БД!"
            view-as alert-box error .
            run ui-on in this-procedure .
            return error.
          end.
          find first buf_clob-data no-lock where
                    buf_clob-data.db-num = buf_clob-bind.db-num
                and buf_clob-data.int64-id = buf_clob-bind.int64-id no-error.
          if not available buf_clob-data then do:
            message
            "Не найдена ссылка на макрос, сохраненный в БД!"
            view-as alert-box error .
            run ui-on in this-procedure .
            return error.
          end.
          if buf_clob-data.db-num <> v-cntxt-db-num then do:
            message
            substitute("Возможно, не все действия пользователя БД &1 удастся воспроизвести!&2Продолжить?"
                      , buf_clob-data.db-num
                      , chr(10))
           view-as alert-box question buttons yes-no update v-ok.
           if not v-ok then do:
              run ui-on in this-procedure .
              return error.
           end.
          end.
          run gbl/_tmpfile.p ( input ""
                        ,input "tmp"
                        ,output v-file-name) .
          copy-lob from object buf_clob-data.cdata
          to file f-name.
          run gbl/filename.p
            (input  v-file-name
            ,output f-name
            ,output v-path
            ,output v-file-name
            ,output v-file-name-no-ext
            ,output v-file-name-ext
            ) no-error .
          if error-status:error then do:
          end.
        end.
      end case.
      for each macro-list-hist:
        delete macro-list-hist.
      end.
      input stream sout from value (f-name).
      _macro:
      repeat:
        create macro-list-hist.
        import stream sout macro-list-hist no-error.
        if error-status:error then do:
            undo _macro, next _macro.
        end.
        assign
        macro-list-hist.num-rec = 0
        macro-list-hist.num-add = 0
        macro-list-hist.num-ignored = 0
        v-id = (if macro-list-hist.line = 0 then v-id + 1 else v-id)
        macro-list-hist.done = no
        .
      end.
      find first macro-list-hist where
              macro-list-hist.id = 0.
      delete macro-list-hist.
      input stream sout close.
      If p-option = "lob" then do:
       os-delete value(f-name).
      end.
      v-file = yes.
    end.
    an-listp-macros-label-id = v-seq.
    run create-scnblist-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                        , input-output v-seq
                                        , input 0
                                        , input '>':U
                                        , input (if v-file
                                                then substitute("Файл макроса : &1", f-name)
                                                else substitute("Записанный макрос")
                                                )
                                        , input tot-lns
                                        , input 'macro':U
                                        , input '':U
                                        , input (if v-file then f-name else '':U)
                                        , input '':U
                                        , input ?
                                        ).
  end.
  disable
  b-record
  b-macro
  with frame Dialog-Frame .
  hide
  b-record in frame Dialog-Frame .
  enable
  b-clear-macro with frame Dialog-Frame .
  v-macro-is-running = yes.
  run str/listmcro.w (input parparentproc
                ,input this-procedure:handle
               ,input "Макрос формирования списка кодов" + chr(4) + "bbm"
                ,input "b-play,b-step"
                ,input-output v-current-step
                ,input v-id
                ,output v-result) no-error .
  if error-status:error
  or v-result = "b-stop"
  or v-result = 'end':U
  then do:
    for each macro-list-hist:
      delete macro-list-hist.
    end.
    assign
    an-listp-start-macro-id = ?
    an-listp-end-macro-id = ?
    an-listp-macros-label-id = 0
    .
    if v-result = 'b-stop' then do:
      assign
      v-hist-mode = '[]':U
      v-des = "Выполнение макроса прекращено пользователем"
      .
      hide
      b-clear-macro
      b-stop
      in frame Dialog-Frame .
      enable
      b-record
      with frame Dialog-Frame .
    end.
    if v-result = 'end' then do:
      assign
      v-hist-mode = '<':U
      v-des = "Выполнение макроса завершено"
      .
      hide
      b-clear-macro
      b-stop
      in frame Dialog-Frame .
      enable
      b-record
      with frame Dialog-Frame .
    end.
    if error-status:error then do:
      assign
      v-hist-mode = 'E':U
      v-des = "Выполнение макроса прекращено из-за ошибки"
      .
    end.
    run create-scnblist-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                        , input-output v-seq
                                        , input 0
                                        , input v-hist-mode
                                        , input v-des
                                        , input tot-lns
                                        , input 'macro':U
                                        , input '':U
                                        , input f-name
                                        , input '':U
                                        , input ?
                                        ) no-error .
    assign
    v-macro-is-running = no
    v-current-step = 0
    .
  end.
  enable
  b-macro
  with frame Dialog-Frame .
end.
end procedure.
procedure proc-create-macro-list-hist :
define input parameter p-list-table as character no-undo .
define input parameter p-id as integer           no-undo .
define input parameter p-line as integer         no-undo .
define input parameter p-hist-mode as character  no-undo .
define input parameter p-des as character        no-undo .
define input parameter p-option_ as character    no-undo .
define input parameter p-item_ as character      no-undo .
define input parameter p-status_ as character    no-undo .
define buffer buf_macro-list-hist for macro-list-hist.
define buffer buf_keep-macro-list-hist for keep-macro-list-hist.
  do
  on error undo, return error return-value
  :
    create buf_macro-list-hist.
    assign
    buf_macro-list-hist.list-table = p-list-table
    buf_macro-list-hist.id         = p-id
    buf_macro-list-hist.line       = p-line
    buf_macro-list-hist.hist-mode  = p-hist-mode
    buf_macro-list-hist.des        = p-des
    buf_macro-list-hist.option_    = p-option_
    buf_macro-list-hist.item_      = p-item_
    buf_macro-list-hist.status_    = p-status_
    .
    if p-keep-query then do:
      create buf_keep-macro-list-hist.
      buffer-copy buf_macro-list-hist to buf_keep-macro-list-hist.
    end.
  end.
end procedure.
procedure proc-macro-play :
define input parameter p-id as integer no-undo .
define input parameter p-step as logical no-undo .
define input parameter p-max-id as integer no-undo .
define variable v-id as integer no-undo .
define variable v-rowid   as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-old-seq as integer no-undo .
define variable v-current-id as integer no-undo .
define variable v-temp-seq as integer no-undo .
define variable v-rs-do-error as logical no-undo .
define  buffer buf_macro-list-hist for macro-list-hist.
define  buffer buf_scnblist-hist for scnblist-hist.
do
on error undo, return error return-value
:
  for each macro-list-hist where (p-id = 0 or macro-list-hist.id = p-id):
    assign
    v-current-id = v-current-id + 1
    v-id = macro-list-hist.id.
    CASE entry(1, macro-list-hist.option_, chr(4)):
      when 'macro':U
      or
      when 'title':U
      or
      when 'start':U
      then do:
      end.
      when 'clear':U then do:
        for each scnblist:
          delete scnblist.
        end.
        for each scnblist-hist where scnblist-hist.id > an-listp-macros-label-id:
          delete scnblist-hist.
        end.
        tot-lns = 0.
        v-seq = an-listp-macros-label-id + 1.
        v-no-hist = 0.
        create buf_scnblist-hist.
        buffer-copy macro-list-hist
        to buf_scnblist-hist
        assign buf_scnblist-hist.id = v-seq
        v-temp-seq = v-seq
        v-seq = v-seq + 1
        v-no-hist = v-no-hist + 1
        .
        run ui-on in this-procedure .
      end.
      when 'single' then do:
         run gen-row-keyr  in this-procedure (  input  macro-list-hist.item_
                                              ,input ?
                                              ,input 'ub'
                                              ,input ?
                                              ,input no-lock
                                              ,output v-rowid
                                              ,output v-tbl-name) no-error .
        if not error-status:error then do:
          CASE macro-list-hist.hist-mode:
            when '+':U then do:
              run proc-b-add in this-procedure(input yes
                                              ,input v-rowid
                                              ,input macro-list-hist.option_
                                              ,input macro-list-hist.status_) no-error .
            end.
            when '-':U then do:
              run proc-b-del in this-procedure(input yes
                                              ,input v-rowid
                                              ,input macro-list-hist.option_
                                              ,input macro-list-hist.status_) no-error .
            end.
            when '*':U then do:
              run proc-b-rest in this-procedure(input yes
                                               ,input v-rowid
                                               ,input macro-list-hist.option_
                                               ,input macro-list-hist.status_) no-error .
            end.
          END.
          if error-status:error then do:
              return ("error" + chr(4) + return-value) .
          end.
          find first  buf_scnblist-hist where
                  buf_scnblist-hist.id = v-seq - 1 no-error .
          if available buf_scnblist-hist then
          assign
          macro-list-hist.num-recs = buf_scnblist-hist.num-recs
          macro-list-hist.num-add = buf_scnblist-hist.num-add
          macro-list-hist.num-ignored = buf_scnblist-hist.num-ignored
          .
        end.
        else do:
          return ("error" + chr(4) + return-value).
        end.
      end.
      otherwise do:
        if can-find(first temp-list where temp-list.fvalue = macro-list-hist.option_)
        or lookup(macro-list-hist.option_, 'optimize':U) > 0
        then do:
          if macro-list-hist.line = 0 then do:
            v-no-hist = 0.
            for each buf_macro-list-hist where
                    buf_macro-list-hist.id = v-id:
              create buf_scnblist-hist.
              buffer-copy buf_macro-list-hist
              except id  num-recs num-add num-ignored done
              to buf_scnblist-hist
              assign
              buf_scnblist-hist.id = (if buf_macro-list-hist.line =0 then v-seq else v-temp-seq)
              v-temp-seq = (if buf_macro-list-hist.line = 0 then v-seq else v-temp-seq )
              v-seq = (if buf_macro-list-hist.line = 0
                      then (v-seq + 1)
                      else v-seq)
              v-no-hist = v-no-hist + 1
              .
            end.
            if v-no-hist = 1 then v-no-hist = 0.
            run rs-do in this-procedure (input yes
                                      , input p-step
                                      , input macro-list-hist.option_
                                      , input macro-list-hist.status_
                                      , input get-line-mode(macro-list-hist.hist-mode)
                                      , input v-temp-seq
                                      ) no-error .
            if error-status:error then do:
              assign
              v-rs-do-error = yes.
            end.
            if get-line-mode(macro-list-hist.hist-mode) = 'ОСТАВИТЬ':U then do:
              run proc-b-rest-2 in this-procedure .
              run ui-on in this-procedure .
            end.
            for each buf_scnblist-hist where
                    buf_scnblist-hist.id = v-temp-seq,
               first buf_macro-list-hist where
                    buf_macro-list-hist.id = v-id
                AND buf_macro-list-hist.line = buf_scnblist-hist.line:
               assign
               buf_macro-list-hist.num-recs = buf_scnblist-hist.num-recs
               buf_macro-list-hist.num-add = buf_scnblist-hist.num-add
               buf_macro-list-hist.num-ignored = buf_scnblist-hist.num-ignored
               .
            end.
            if v-rs-do-error then do:
              run ui-on in this-procedure .
              return ("error" + chr(4) + return-value).
            end.
            v-id = macro-list-hist.id.
          end.
        end.
      end.
    END CASE.
  end.
end.
end procedure.
procedure proc-b-rest-2 :
  do
  on error undo, return error
  :
    for each scnblist:
      if scnblist.to-del = ? then do:
        assign
        scnblist.to-del = no
        .
      end.
      else do:
        delete scnblist.
      end.
    end.
    tot-lns = lns-cnt.
  end.
end procedure.
PROCEDURE proc-expand :
define input parameter p-shift as integer no-undo .
define input parameter p-from as integer no-undo .
define input parameter p-to as integer no-undo .
define input parameter p-forcer-name as character no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable lh as widget-handle no-undo .
define variable ii as INTEGER no-undo .
ASSIGN
fh = frame Dialog-Frame:first-child
hh = fh:first-child
.
CASE v-expand:
  WHEN YES THEN DO:
    ASSIGN
    v-expand = NO.
    DO ii = 1 TO NUM-ENTRIES(v-downed):
      ASSIGN
      hh              = WIDGET-HANDLE(ENTRY(ii, v-downed))
      hh:ROW          = (hh:ROW - p-shift).
      hh:height-chars = (if hh:type = "browse" then (hh:height-chars + p-shift) else hh:height-chars).
    END.
  END.
  WHEN NO THEN DO:
    v-expand = YES.
    v-downed = ''.
    _do:
    do while valid-handle(hh):
      IF lookup(hh:type, "radio-set,browse,button,fill-in,literal,text,rectangle") > 0
       AND hh:ROW >= p-from
       AND hh:ROW <= p-to
       and lookup(hh:name, p-forcer-name) = 0
       THEN DO:
        hh:height-chars = (if hh:type = "browse" then (hh:height-chars - p-shift) else hh:height-chars).
        hh:ROW          = (hh:ROW + p-shift).
        ASSIGN
        v-downed = v-downed + chr(44) + STRING(hh).
        IF hh:TYPE = "fill-in"
        AND valid-handle(hh:side-label-handle) THEN dO:
          assign
          lh = hh:SIDE-LABEL-HANDLE
          lh:ROW = lh:ROW + p-shift
          v-downed = v-downed + chr(44) + STRING(lh)
          .
         END.
       END.
       hh = hh:next-sibling.
    END.
    v-downed = trim(v-downed, chr(44)).
  END.
END CASE.
END PROCEDURE.
define variable v-ok as logical   no-undo .
assign
  v-ok = br-list :set-repositioned-row(5, 'conditional':u)
.
ON WINDOW-CLOSE OF FRAME Dialog-Frame APPLY "END-ERROR":U TO SELF.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON stop UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info57 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info58 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref-type58 as character no-undo.
varscales-pref  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'sclspref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varscales-pref
  ,output varscales-pref-type58
  ) no-error .
if varscales-pref = ? then do:
  assign
  varscales-pref = '21,23,25':U.
end.
define variable varpgscales-pref-type58 as character no-undo.
varpgscales-pref  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'scpgpref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varpgscales-pref
  ,output varpgscales-pref-type58
  ) no-error .
if varpgscales-pref = ? then do:
  assign
  varpgscales-pref = '24IIIIIQQ000C,28IIIIIQQQ00C':U.
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-tsd'
  ,input  0
  ,input  '':U
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output conf-par
  ,output par-type
  ) no-error .
  assign
  is-tsd = (if conf-par = "yes" then yes else no)
  .
define variable vss-include-info59 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
  if p-curr-obj-type = '':U
  and p-curr-obj-code = 0 then do:
define variable vss-include-info60 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-one in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-user-select
  ,output v-sel-obj-type
  ,output v-sel-obj-code
  )  .
    if v-user-select then do: ~
      FIND FIRST buf_user-obj no-lock where
              buf_user-obj.obj-type = v-sel-obj-type
          and buf_user-obj.obj-code = v-sel-obj-code  No-ERROR.
      if not avail buf_user-obj then return no-apply.
      find first buf_clients no-lock where
                buf_clients.obj-type = buf_user-obj.obj-type
            and buf_clients.obj-code = buf_user-obj.obj-code no-error.
      if not available buf_clients then return error.
      assign
      p-curr-obj-type = buf_clients.obj-type
      p-curr-obj-code = buf_clients.obj-code
      v-host-code = buf_clients.host-code
      v-no-obj = yes
      .
    end.
    else do:
      message
      "Текущий объект не может быть установлен" skip
      view-as alert-box error .
      undo, return error.
    end.
  end.
  if not (p-curr-obj-type = '':U
          and
          p-curr-obj-code = 0) then do:
    find first buf_clients no-lock
        where buf_clients.obj-type = p-curr-obj-type
        AND    buf_clients.obj-code = p-curr-obj-code no-error.
    if not available buf_clients
    or not (buf_clients.obj-type = 'маг':U
      or
      buf_clients.obj-type = 'скл':U
      )
    then do:
      assign
      p-curr-obj-type = '':U
      p-curr-obj-code = 0
      .
      message
      vss-workfile vss-revision vss-description skip
      "Неверно заданы входные параметры p-curr-obj-type и/или p-curr-obj-code"
      p-curr-obj-type p-curr-obj-code
      view-as alert-box error .
      undo main-block, return error.
    end.
  end.
  assign
  line-rec = ?
  .
  assign
  br-option:column-scrolling in frame Dialog-Frame  = no
  RS-status:radio-buttons = "Текущие&+" + chr(44) + 'текущие':U + chr(44) +
                            "Все!" + chr(44) + 'все':U + chr(44) +
                            "Неактивные-" + chr(44) + 'удаленные':U
  RS-status = 'текущие':U
  .
  if v-no-obj
  or v-cntxt-level <>  'object':U then do:
    if v-obj-name = "":U then do:
      run proc-b-obj in this-procedure ( input "":U ).
    end.
    display
      b-obj
      v-obj-type
      v-obj-code
      v-obj-name
    with frame Dialog-Frame .
    enable
      b-obj
    with frame Dialog-Frame .
  end.
  else do:
    assign
    v-obj-type  = p-curr-obj-type
    v-obj-code  = p-curr-obj-code
    .
    if v-obj-type = 'маг':U then do:
      find first ub.shop no-lock where
                ub.shop.obj-code = v-obj-code.
      find first sysconf no-lock where
                sysconf.host-code = shop.host-code .
      assign
      v-is-restaurant = ub.shop.is-catering
      v-doc-prt = ub.shop.doc-prt.
      .
    end.
    else do:
      find first ub.store no-lock where
                ub.store.obj-code = p-curr-obj-code.
      find first sysconf no-lock where
                sysconf.host-code = store.host-code .
      v-doc-prt = ub.store.doc-prt.
    end.
    run proc-fill-temp-list in this-procedure .
    for each temp-shop:
      delete temp-shop.
    end.
    create temp-shop.
    run proc-b-cd in this-procedure  ( input yes).
  end.
  run UI-on.
  WAIT-FOR GO OF FRAME Dialog-Frame focus br-list.
END.
HIDE FRAME Dialog-Frame.
PROCEDURE UI-on:
define variable v-recid0 as recid no-undo.
define variable v-start as logical no-undo .
define buffer buf_temp-list for temp-list.
define buffer buf_scnblist-hist for scnblist-hist.
scnblist.part-code:resizable in browse br-list = yes.
scnblist.in-code:resizable in browse br-list = yes.
if v-cntxt-level <> 'object':U
or v-cntxt-obj-type <> 'маг':U then do:
  assign
  MENU-ITEM m-cd:sensitive in menu m-save = no.
end.
  find first buf_scnblist-hist where buf_scnblist-hist.id = 0 no-error.
  if available buf_scnblist-hist then
  assign
  frame Dialog-Frame:title = substitute("СПИСОК  КОДОВ &1",  string(buf_scnblist-hist.des, "X(60)"))
  .
  if tot-lns = ? then do:
    v-start = yes.
    for each l-scnblist :
      accumulate l-scnblist.artic (count).
    end.
    tot-lns = (accum count l-scnblist.artic).
    if tot-lns > 0 then do:
      find last  buf_scnblist-hist no-error .
      if available buf_scnblist-hist and buf_scnblist-hist.id = 1 and v-start then delete buf_scnblist-hist.
      v-seq = (if available buf_scnblist-hist then buf_scnblist-hist.id else 0)  + 1.
      run create-scnblist-hist in this-procedure (input 'ДОБАВЛЕНИЕ':U
                                           , input-output v-seq
                                           , input 0
                                           , input 'S':U
                                           , input substitute("# Исходный список: &1 строк", tot-lns)
                                           , input tot-lns
                                           , input "start":U
                                           , input '':U
                                           , input '':U
                                           , input '':U
                                           , input ?
                                           ).
    end.
    else do:
      line-mode = 'ДОБАВЛЕНИЕ':U.
      for each buf_scnblist-hist:
        delete buf_scnblist-hist.
      end.
      v-seq = 1.
      run create-scnblist-hist in this-procedure (input 'ДОБАВЛЕНИЕ':U
                                           , input-output v-seq
                                           , input 0
                                           , input '':U
                                           , input "# Исходный список кодов пуст."
                                           , input tot-lns
                                           , input 'start':U
                                           , input '':U
                                           , input '':U
                                           , input '':U
                                           , input ?
                                           ).
    end.
  end.
  hide loc-art in frame Dialog-Frame loc-name loc-code loc-b-str in frame Dialog-Frame.
  assign
    loc-art = ""
    RS-list-method = "single"
    dsp-rs = "Всего строк в списке кодов : " + string (tot-lns).
  find first buf_temp-list no-lock where
             buf_temp-list.fvalue = rs-list-method.
  assign
  v-recid0 = recid(buf_temp-list).
  open query br-option for each temp-list no-lock .
  DISPLAY br-option dsp-rs RS-Status WITH FRAME Dialog-Frame.
  ENABLE
  b-exit b-add b-hist b-help br-option br-list RS-Status b-cd
  T-loc-base
  T-loc-alt
  T-bc-base
  T-bc-alt
  T-all-prt
  T-parts-ser
  T-parts-not-blank
  T-parts-all
  T-pb-base
  T-pb-alt
  T-sc-base
  WITH FRAME Dialog-Frame.
  reposition br-option to recid v-recid0.
  if tot-lns > 0 then
    ENABLE b-print b-rest b-save b-del b-lkp b-clr a-n-c b-optimize WITH FRAME Dialog-Frame.
  else do:
    DISABLE b-print b-rest b-save b-del b-lkp b-clr a-n-c b-optimize WITH FRAME Dialog-Frame.
  end.
  open query br-list for each scnblist no-lock indexed-reposition.
 if v-seq > 1 then
  find last buf_scnblist-hist no-lock where
            buf_scnblist-hist.id = (v-seq - 1)
       and  buf_scnblist-hist.line = 0 no-error .
  DISPLAY br-option
  (if available buf_scnblist-hist
  then buf_scnblist-hist.des
  else '') @ dsp-rs
  RS-Status WITH FRAME Dialog-Frame.
  ENABLE
  b-macro  when v-start
  b-record when v-start
  b-exit b-add b-hist b-help br-option br-list RS-Status WITH FRAME Dialog-Frame.
  if v-start then do:
    hide
    b-stop
    b-clear-macro
    in frame Dialog-Frame.
  end.
  v-start = no.
  if line-rec <> ? then
    reposition br-list to recid line-rec no-error.
  if available scnblist then do:     find ub.clients where ub.clients.obj-type = scnblist.prod-type                    and ub.clients.obj-code = scnblist.prod-code no-lock.     find ub.gds-prt where ub.gds-prt.upper-code = scnblist.prt-root no-lock.     find ub.bar-code where ub.bar-code.gds-code  = scnblist.gds-code                     and ub.bar-code.node-code = ub.gds-prt.node-code                     and ub.bar-code.unit-cli  = scnblist.unit-base                     and ub.bar-code.in-code   = ""                     and ub.bar-code.part-code = "" no-lock.     disp ub.clients.obj-name ub.gds-prt.node-name ub.bar-code.b-code tot-lns @ f-tot-lns with frame Dialog-Frame.   end.   disp tot-lns @ f-tot-lns with frame Dialog-Frame.
END PROCEDURE.
define variable vss-include-info61 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE ex-bbc :
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
define input parameter line-mode as character no-undo .
define input parameter p-empty-scale as logical no-undo .
define input parameter p-b-str as character no-undo .
define input parameter p-is-loc-ean as logical no-undo .
define parameter buffer buf_bar-code for ub.bar-code.
define parameter buffer buf_prod-bc for ub.prod-bc.
define variable v-f-name like ub.gds-prt.f-name no-undo .
define buffer buf_gds-prt for ub.gds-prt.
if available buf_prod-bc then
p-b-str = buf_prod-bc.b-str.
if rs-list-method begins "single":U or
  (ub.goods.stts = 0  and rs-status <> 'удаленные':U) or
  (ub.goods.stts <> 0 and rs-status <> 'текущие':U) then do:
  if line-mode = 'удаление':U or line-mode = 'ОСТАВИТЬ':U then do:
    find first scnblist where scnblist.gds-code  = ub.goods.gds-code
                     and scnblist.b-code    = buf_bar-code.b-code
                     and scnblist.b-str     = p-b-str  no-error.
    if available scnblist then do:
      if line-mode = 'удаление':U then do:
        lns-cnt = lns-cnt + 1.
        delete scnblist.
      end.
      else do:
        if scnblist.to-del = ? then.
        else do:
          lns-cnt = lns-cnt + 1.
          scnblist.to-del = ?.
        end.
      end.
    end.
  end.
  else
    if line-mode = 'ДОБАВЛЕНИЕ':U then do:
      if p-empty-scale then  do:
      end.
      else do:
        find first buf_gds-prt no-lock where
                  buf_gds-prt.node-code = buf_bar-code.node-code no-error.
        if not available buf_gds-prt then v-f-name = "!!!Неизвестный признак шкалы".
        else v-f-name = buf_gds-prt.f-name.
      end.
define variable vss-include-info62 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find first scnblist
  where scnblist.gds-code = buf_bar-code.gds-code
    and scnblist.b-code   = buf_bar-code.b-code
    and scnblist.b-str    = p-b-str
  no-error .
if available scnblist then do:
  assign
    scnblist.to-del = no
  .
end.
else do:
  define variable v-last62 as integer no-undo .
  find last scnblist use-index oi no-error.
  if available scnblist then do:
    v-last62 = scnblist.order-num .
  end.
  else do:
    v-last62 = 0 .
  end.
  create scnblist .
  buffer-copy ub.goods to scnblist
  assign
    scnblist.to-del = no
    scnblist.order-num = v-last62 + 1
    scnblist.b-code = buf_bar-code.b-code
    scnblist.bc-cli-base-rate = buf_bar-code.cli-base-rate
    scnblist.bc-cr-db-num     = buf_bar-code.cr-db-num
    scnblist.in-code       = buf_bar-code.in-code
    scnblist.node-code     = buf_bar-code.node-code
    scnblist.part-code     = buf_bar-code.part-code
    scnblist.stts_         = buf_bar-code.stts_
    scnblist.bc-unit-cli   = buf_bar-code.unit-cli
    scnblist.b-str         = p-b-str
    scnblist.f-name        = v-f-name
    scnblist.loc-ean       = p-is-loc-ean
    .
    if available buf_prod-bc
    then
    assign
    scnblist.bc-on-type    = buf_prod-bc.bc-on-type
    scnblist.bc-on         = buf_prod-bc.bc-on
    scnblist.pbc-cr-db-num = buf_prod-bc.cr-db-num
    .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (scnblist)
  .
end.
    end.
  if lns-cnt modulo 25 = 0 then
  disp "ЖДИТЕ...    Обработано кодов :" + string (lns-cnt) @ dsp-rs with frame Dialog-Frame.
end.
else
assign
lns-ignore = lns-ignore + 1
.
end.
PROCEDURE rs-do :
define input parameter p-from-macro as logical no-undo .
define input parameter p-step as logical no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
define input parameter line-mode as character no-undo .
define input parameter p-id      as integer no-undo .
define variable v-rowid   as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable glog as logical no-undo .
define buffer buf_scnblist-hist for scnblist-hist.
define variable another-price like ub.price-list.price-sale no-undo.
define variable scan-qnty as dec no-undo.
define variable bc-qnty as dec no-undo.
define variable var-root-code like ub.gds-prt.node-code no-undo .
define variable varresult   as character         no-undo.
define variable vartype-bc  as character         no-undo.
define variable varweight   as decimal           no-undo.
define variable v-value-integer as integer   no-undo .
define variable v-db-num as integer no-undo .
define variable l-prod-bc-weight as logical no-undo .
define variable l-prod-bc-pgweight as logical no-undo .
define variable l-prod-bc-glob as logical no-undo .
define variable v-is-weight as logical no-undo .
define variable IBM-good-code as character no-undo .
define variable bar_code as character no-undo .
define variable v-prev-b-code as integer no-undo .
define variable v-b-code as integer   no-undo .
define variable v-from-date as date no-undo .
define variable v-to-date as date no-undo .
define variable v-from-date-str as character no-undo .
define variable v-to-date-str as character no-undo .
define variable v-using as character no-undo .
define buffer buf_prod-bc for ub.prod-bc.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_cd-plu for ub.cd-plu.
define buffer buf_parts for ub.parts.
define buffer buf_gds-obj for ub.gds-obj.
define buffer buf_parts-obj-attr for ub.parts-obj-attr.
define buffer buf_code-range for ub.code-range.
define buffer buf_prod-bc-db for ub.prod-bc-db.
define buffer buf_gds-obj-attr for ub.gds-obj-attr.
define buffer buf_scales-gds for ub.scales-gds.
do
on error undo, return error return-value
:
if p-from-macro then do:
end.
else do:
  assign
  frame Dialog-Frame
  T-all-prt
  T-bc-alt
  T-bc-base
  T-loc-alt
  T-loc-base
  T-parts-all
  T-parts-not-blank
  T-parts-ser
  T-pb-alt
  T-pb-base
  T-sc-base
  .
  if (
  T-all-prt or
  T-bc-alt  or
  T-bc-base or
  T-loc-alt or
  T-loc-base  or
  T-parts-all  or
  T-parts-not-blank or
  T-parts-ser or
  T-pb-alt    or
  T-pb-base   or
  T-sc-base) = no then do:
    message
    "Не выбран ни один тип кодов!"
    view-as alert-box error .
    undo, return error .
  end.
  assign
  temp-shop.obj-code = p-curr-obj-code
  temp-shop.all-prt = T-all-prt
  temp-shop.cd-bc-alt = T-bc-alt
  temp-shop.cd-bc-base = T-bc-base
  temp-shop.cd-loc-alt = T-loc-alt
  temp-shop.cd-loc-base = T-loc-base
  temp-shop.cd-parts-all = T-parts-all
  temp-shop.cd-parts-not-blank = T-parts-not-blank
  temp-shop.cd-parts-ser = T-parts-ser
  temp-shop.cd-pb-alt = T-pb-alt
  temp-shop.cd-pb-base = T-pb-base
  temp-shop.cd-sc-base = T-sc-base
  .
end.
assign
lns-cnt = 0
lns-ignore = 0
v-num-add  = 0
v-num-ignored = 0
tot-lns = (if line-mode = 'ОСТАВИТЬ':U then 0 else tot-lns)
.
run write-hist(p-from-macro, rs-list-method, rs-status, line-mode, buffer ub.goods).
if session:set-wait-state( "COMPILER" )  then .
dsp-rs:fgcolor in frame Dialog-Frame = 12.
case rs-list-method:
  when "optimize"  then do:
    find first buf_scnblist-hist where
               buf_scnblist-hist.id = p-id .
    run proc-b-optimize(input p-from-macro
                      , input rs-list-method
                      , input rs-status
                      , input buf_scnblist-hist.item_
                      ) no-error .
    assign                                                           buf_scnblist-hist.num-add  = lns-cnt - v-num-add                       buf_scnblist-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_scnblist-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_scnblist-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
  end.
  when "all" then do:
    find first buf_scnblist-hist where
               buf_scnblist-hist.id = p-id .
    if p-from-macro then run restore-codes in this-procedure (input buf_scnblist-hist.item_, p-curr-obj-type, p-curr-obj-code).
    for each goods no-lock:
      assign                 new-good = yes                 petrol-trk = no                 cashparts = no                 main-b-code = 0                 .
      run process-one-good in this-procedure (input rs-list-method, input rs-status, input line-mode, buffer goods) no-error .
    end.
    assign                                                           buf_scnblist-hist.num-add  = lns-cnt - v-num-add                       buf_scnblist-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_scnblist-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_scnblist-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
  end.
  when "goods" then do:
    for each buf_scnblist-hist where
             buf_scnblist-hist.id = p-id:
      if buf_scnblist-hist.line = 0
      and p-from-macro then run restore-codes in this-procedure (input buf_scnblist-hist.item_, p-curr-obj-type, p-curr-obj-code).
      if buf_scnblist-hist.line <> 0 then do:
        run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_scnblist-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then next.
        assign                 new-good = yes                 petrol-trk = no                 cashparts = no                 main-b-code = 0                 .
        find goods where rowid (goods) = v-rowid no-lock.
        run process-one-good in this-procedure (input rs-list-method, input rs-status, input line-mode ,buffer goods) no-error .
        assign                                                           buf_scnblist-hist.num-add  = lns-cnt - v-num-add                       buf_scnblist-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_scnblist-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_scnblist-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
      end.
    end.
  end.
  when "goods-b-code"
  or
  when "goods-b-code-ean"
  then do:
    for each buf_scnblist-hist where
             buf_scnblist-hist.id = p-id
        and  buf_scnblist-hist.item_ <> '':U:
      run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_scnblist-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then next.
      find first buf_bar-code no-lock where
                rowid(buf_bar-code) = v-rowid no-error.
      if available buf_bar-code then do:
        run get-prt-and-unit in this-procedure (
                                                input goods.prt-root
                                                ,input goods.unit-base
                                                ,output l-empty-scale
                                                ) .
        if rs-list-method = "goods-b-code":U then
        run ex-bbc in this-procedure (input rs-list-method, input rs-status, input line-mode , input no, input "":U, input no, buffer buf_bar-code, buffer buf_prod-bc).
        if rs-list-method = "goods-b-code-ean":U then do:
          RUN gen-bc( input buf_bar-code.b-code, output bar_code ).
          IBM-good-code  = trim( bar_code ) .
          run ex-bbc in this-procedure (input rs-list-method, input rs-status, input line-mode , input no, input IBM-good-code, input yes, buffer buf_bar-code, buffer buf_prod-bc).
        end.
        assign                                                           buf_scnblist-hist.num-add  = lns-cnt - v-num-add                       buf_scnblist-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_scnblist-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_scnblist-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
      end.
    end.
  end.
  when "goods-b-str" then do:
    for each buf_scnblist-hist where
             buf_scnblist-hist.id = p-id
        and  buf_scnblist-hist.item_ <> '':U:
      run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_scnblist-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then next.
      find first buf_prod-bc no-lock where
              rowid(buf_prod-bc) = v-rowid no-error.
      if available buf_prod-bc then do:
        find first buf_bar-code no-lock where
                  buf_bar-code.b-code = buf_prod-bc.b-code no-error.
        if available buf_prod-bc then do:
          run get-prt-and-unit in this-procedure (
                                                  input goods.prt-root
                                                  ,input goods.unit-base
                                                  ,output l-empty-scale
                                                  ) .
          run ex-bbc in this-procedure (input rs-list-method, input rs-status, input line-mode ,  input l-empty-scale, input "":U, input no, buffer buf_bar-code, buffer buf_prod-bc).
        end.
      end.
    end.
  end.
  when "gds-list"  then do:
    for each buf_scnblist-hist where
             buf_scnblist-hist.id = p-id:
      if buf_scnblist-hist.line = 0
      and p-from-macro then run restore-codes in this-procedure (input buf_scnblist-hist.item_, p-curr-obj-type, p-curr-obj-code).
      if buf_scnblist-hist.line <> 0 then do:
        run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_scnblist-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then next.
        find first goods no-lock where rowid(goods) = v-rowid.
        assign                 new-good = yes                 petrol-trk = no                 cashparts = no                 main-b-code = 0                 .
        run process-one-good in this-procedure (input rs-list-method, input rs-status, input line-mode,buffer goods) no-error .
        assign                                                           buf_scnblist-hist.num-add  = lns-cnt - v-num-add                       buf_scnblist-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_scnblist-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_scnblist-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
      end.
    end.
  end.
  when "file-gds"
  or
  when "scaner"
  then do:
    run proc-file-list-methods in this-procedure(input p-from-macro, input rs-list-method, input rs-status, input line-mode, input p-id). .
  end.
  when "last-check":U then do:
    find first buf_scnblist-hist where
             buf_scnblist-hist.id = p-id
         AND buf_scnblist-hist.item_ <> '':U .
    assign
    v-curr-obj-type = entry(1, buf_scnblist-hist.item_, chr(3))
    v-curr-obj-code = integer(entry(2, buf_scnblist-hist.item_, chr(3)))
    v-chk-date-chr = entry(3, buf_scnblist-hist.item_, chr(3))
    v-chk-date = date(integer(substring(v-chk-date-chr, 4, 2)),
                  integer(substring(v-chk-date-chr, 1, 2)),
                  integer(substring(v-chk-date-chr, 7, 4)))
    no-error
    .
    if error-status:error then do: end. else do:
      for each ub.chk-doc no-lock where
              ub.chk-doc.obj-type = v-curr-obj-type
          AND ub.chk-doc.obj-code = v-curr-obj-code
          and ub.chk-doc.chk-date <= v-chk-date,
          each ub.chk-gds no-lock where
              ub.chk-gds.doc-code = ub.chk-doc.doc-code:
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_bc-rcnz in g#libbcrcn
(
 input  parparentproc
,input  entry(1, chk-gds.src-code, chr(4))
,input  ?
,input  v-curr-obj-type
,input  v-curr-obj-code
,input  yes
,input  no
,input  varscales-pref
,input  varpgscales-pref
,output varresult
,output vartype-bc
,output varweight
,buffer ub.bar-code
,buffer ub.prod-bc
,buffer ub.place
) no-error.
        if not available ub.bar-code then next.
        assign                 new-good = yes                 petrol-trk = no                 cashparts = no                 main-b-code = 0                 .
        find ub.goods where ub.goods.gds-code = ub.bar-code.gds-code NO-LOCK no-error.
        if available goods then do:
          run get-prt-and-unit in this-procedure (
                                                  input ub.goods.prt-root
                                                  ,input ub.goods.unit-base
                                                  ,output l-empty-scale
                                                  ) .
          run ex-bbc in this-procedure (input rs-list-method, input rs-status, input line-mode , input no, input "":U, input (not available prod-bc), buffer bar-code, buffer prod-bc).
        end.
      end.
      assign                                                           buf_scnblist-hist.num-add  = lns-cnt - v-num-add                       buf_scnblist-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_scnblist-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_scnblist-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "prod-bc-off" then do:
    find first buf_scnblist-hist where
               buf_scnblist-hist.id = p-id .
    if p-from-macro then run restore-codes in this-procedure (input buf_scnblist-hist.item_, p-curr-obj-type, p-curr-obj-code).
    for each ub.prod-bc no-lock
    by ub.prod-bc.b-code
    :
      if ub.prod-bc.bc-on = no then do:
        if ub.prod-bc.b-code <> v-prev-b-code then do:
          find first ub.bar-code no-lock where ub.bar-code.b-code = ub.prod-bc.b-code no-error.
          assign                 new-good = yes                 petrol-trk = no                 cashparts = no                 main-b-code = 0                 .
          if available ub.bar-code then do:
            find first ub.goods no-lock where ub.goods.gds-code = ub.bar-code.gds-code no-error.
          end.
        end.
        if available ub.bar-code
        and available ub.goods then do:
          run ex-bbc in this-procedure (input rs-list-method, input rs-status, input line-mode , input ?, input ub.prod-bc.b-str, input no, buffer bar-code, buffer prod-bc).
          assign                                                           buf_scnblist-hist.num-add  = lns-cnt - v-num-add                       buf_scnblist-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_scnblist-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_scnblist-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
          v-prev-b-code = ub.prod-bc.b-code.
        end.
      end.
    end.
  end.
  when "cd-codes":U then do:
    for each buf_scnblist-hist where
            buf_scnblist-hist.id = p-id
        and  buf_scnblist-hist.item_ <> '':U:
      assign
      v-curr-obj-type = entry(1, buf_scnblist-hist.item_, chr(3))
      v-curr-obj-code = integer(entry(2, buf_scnblist-hist.item_, chr(3)))
      v-pos-type = entry(3, buf_scnblist-hist.item_, chr(3))
      no-error
      .
      if error-status:error then do: end. else do:
        find first buf_user-obj no-lock where
                  buf_user-obj.obj-type = v-curr-obj-type
              AND buf_user-obj.obj-code = v-curr-obj-code
              AND buf_user-obj.db-num = v-cntxt-db-num
              AND buf_user-obj.user-id = v-cntxt-userid
              no-error .
        if available buf_user-obj then do:
          CASE v-pos-type:
            when 'r-keeper':U then do:
              for each buf_cd-plu where
                      buf_cd-plu.obj-type = 'маг':U
                  and buf_cd-plu.obj-code = buf_user-obj.obj-code
                  and buf_cd-plu.pos-type = 'r-keeper':U:
                release prod-bc.
                find first ub.bar-code no-lock where
                          ub.bar-code.b-code = buf_cd-plu.b-code no-error.
                if not available ub.bar-code then next.
                if available goods then do:
                  run get-prt-and-unit in this-procedure (
                                                                input ub.goods.prt-root
                                                                ,input ub.goods.unit-base
                                                                ,output l-empty-scale
                                                      ) .
                  run ex-bbc in this-procedure (input rs-list-method, input rs-status, input line-mode ,input no, input "":U, input no, buffer bar-code, buffer prod-bc).
                end.
              end.
            end.
          end case.
        end.
      end.
      assign                                                           buf_scnblist-hist.num-add  = lns-cnt - v-num-add                       buf_scnblist-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_scnblist-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_scnblist-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "parts-cashparts":U
  or
  when "parts-ean-cashparts":U
    then do:
      for each buf_scnblist-hist where
              buf_scnblist-hist.id = p-id
          and  buf_scnblist-hist.item_ <> '':U:
        assign
        v-curr-obj-type = entry(1, buf_scnblist-hist.item_, chr(3))
        v-curr-obj-code = integer(entry(2, buf_scnblist-hist.item_, chr(3)))
        no-error
        .
        if error-status:error then do: end. else do:
          find first buf_user-obj no-lock where
                    buf_user-obj.obj-type = v-curr-obj-type
                AND buf_user-obj.obj-code = v-curr-obj-code
                AND buf_user-obj.db-num = v-cntxt-db-num
                AND buf_user-obj.user-id = v-cntxt-userid
                no-error .
          if available buf_user-obj then do:
            for each buf_gds-obj no-lock where
                    buf_gds-obj.obj-type = v-curr-obj-type
                and buf_gds-obj.obj-code = v-curr-obj-code,
                  each buf_parts no-lock where
                    buf_parts.artic = buf_gds-obj.artic
                 and buf_parts.prod-type = buf_gds-obj.prod-type
                 and buf_parts.prod-code = buf_gds-obj.prod-code
                 and buf_parts.obj-type = v-curr-obj-type
                  and buf_parts.obj-code = v-curr-obj-code
                  and buf_parts.out-code  = 'free-zone':U
                  and buf_parts.status_   = false:
                if buf_gds-obj.cash-parts = false then next.
                v-b-code = 0.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run partbcod in g#library
  (buffer buf_parts
  ,output v-b-code
  ) no-error .
               if v-b-code > 0 then do:
                find first ub.goods no-lock where
                        ub.goods.gds-code = buf_gds-obj.gds-code no-error.
                find first buf_bar-code no-lock where
                          buf_bar-code.b-code = v-b-code no-error.
                if available ub.goods
                and available buf_bar-code
                then do:
                  run get-prt-and-unit in this-procedure (
                                                                input goods.prt-root
                                                                ,input goods.unit-base
                                                                ,output l-empty-scale
                                                      ) .
                  if rs-list-method = "parts-cashparts" then do:
                    run ex-bbc in this-procedure (input rs-list-method, input rs-status, input line-mode ,input no, input "":U, input no, buffer buf_bar-code, buffer prod-bc).
                  end.
                  if rs-list-method = "parts-ean-cashparts" then do:
                    RUN gen-bc( input buf_bar-code.b-code, output bar_code ).
                    IBM-good-code  = trim( bar_code ) .
                    run ex-bbc in this-procedure (input rs-list-method, input rs-status, input line-mode , input no, input IBM-good-code, input yes, buffer buf_bar-code, buffer buf_prod-bc).
                  end.
                end.
              end.
            end.
          end.
        end.
        assign                                                           buf_scnblist-hist.num-add  = lns-cnt - v-num-add                       buf_scnblist-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_scnblist-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_scnblist-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
      end.
    end.
  when "parts-last-date":U
  or
  when "parts-ean-last-date":U
  then do:
    for each buf_scnblist-hist where
            buf_scnblist-hist.id = p-id
        and  buf_scnblist-hist.item_ <> '':U:
      assign
      v-curr-obj-type = entry(1, buf_scnblist-hist.item_, chr(3))
      v-curr-obj-code = integer(entry(2, buf_scnblist-hist.item_, chr(3)))
      v-value-integer = integer(entry(3, buf_scnblist-hist.item_, chr(3)))
      no-error
      .
      if error-status:error then do: end. else do:
        find first buf_user-obj no-lock where
                  buf_user-obj.obj-type = v-curr-obj-type
              AND buf_user-obj.obj-code = v-curr-obj-code
              AND buf_user-obj.db-num = v-cntxt-db-num
              AND buf_user-obj.user-id = v-cntxt-userid
              no-error .
        if available buf_user-obj then do:
          for each buf_parts no-lock where
                  buf_parts.obj-type = v-curr-obj-type
                and buf_parts.obj-code = v-curr-obj-code
                and buf_parts.out-code  = 'free-zone':U
                and buf_parts.status_   = false:
            if buf_parts.last-date <> ?
            and (buf_parts.last-date - today) < v-value-integer then do:
              v-b-code = 0.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run partbcod in g#library
  (buffer buf_parts
  ,output v-b-code
  ) no-error .
              if v-b-code > 0 then do:
                find first buf_bar-code no-lock where
                          buf_bar-code.b-code = v-b-code no-error.
                if available buf_bar-code then do:
                  find first ub.goods no-lock where
                            ub.goods.gds-code = buf_bar-code.gds-code no-error.
                  if available ub.goods then do:
                    run get-prt-and-unit in this-procedure (
                                                                  input goods.prt-root
                                                                  ,input goods.unit-base
                                                                  ,output l-empty-scale
                                                        ) .
                    if rs-list-method = "parts-last-date" then do:
                      run ex-bbc in this-procedure (input rs-list-method, input rs-status, input line-mode ,input no, input "":U, input no, buffer buf_bar-code, buffer prod-bc).
                    end.
                    if rs-list-method = "parts-ean-last-date" then do:
                      RUN gen-bc( input buf_bar-code.b-code, output bar_code ).
                      IBM-good-code  = trim( bar_code ) .
                      run ex-bbc in this-procedure (input rs-list-method, input rs-status, input line-mode , input no, input IBM-good-code, input yes, buffer buf_bar-code, buffer buf_prod-bc).
                    end.
                  end.
                end.
              end.
            end.
          end.
        end.
      end.
      assign                                                           buf_scnblist-hist.num-add  = lns-cnt - v-num-add                       buf_scnblist-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_scnblist-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_scnblist-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "parts-rsrv-last-date":U
  or
  when "parts-ean-rsrv-last-date":U
  then do:
    for each buf_scnblist-hist where
            buf_scnblist-hist.id = p-id
        and  buf_scnblist-hist.item_ <> '':U:
      assign
      v-curr-obj-type = entry(1, buf_scnblist-hist.item_, chr(3))
      v-curr-obj-code = integer(entry(2, buf_scnblist-hist.item_, chr(3)))
      v-value-integer = integer(entry(3, buf_scnblist-hist.item_, chr(3)))
      no-error
      .
      if error-status:error then do: end. else do:
        find first buf_user-obj no-lock where
                  buf_user-obj.obj-type = v-curr-obj-type
              AND buf_user-obj.obj-code = v-curr-obj-code
              AND buf_user-obj.db-num = v-cntxt-db-num
              AND buf_user-obj.user-id = v-cntxt-userid
              no-error .
        if available buf_user-obj then do:
          for each buf_parts no-lock where
                  buf_parts.obj-type = v-curr-obj-type
                and buf_parts.obj-code = v-curr-obj-code
                and buf_parts.rsrv-free = true
                and buf_parts.status_   = false
                and buf_parts.out-code  <> 'free-zone':U
                :
            if buf_parts.last-date <> ?
            and (buf_parts.last-date - today) < v-value-integer then do:
              v-b-code = 0.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run partbcod in g#library
  (buffer buf_parts
  ,output v-b-code
  ) no-error .
              if v-b-code > 0 then do:
                find first buf_bar-code no-lock where
                          buf_bar-code.b-code = v-b-code no-error.
                if available buf_bar-code then do:
                  find first ub.goods no-lock where
                            ub.goods.gds-code = buf_bar-code.gds-code no-error.
                  if available ub.goods then do:
                    run get-prt-and-unit in this-procedure (
                                                                  input goods.prt-root
                                                                  ,input goods.unit-base
                                                                  ,output l-empty-scale
                                                        ) .
                    if rs-list-method = "parts-rsrv-last-date" then do:
                      run ex-bbc in this-procedure (input rs-list-method, input rs-status, input line-mode ,input no, input "":U, input no, buffer buf_bar-code, buffer prod-bc).
                    end.
                    if rs-list-method = "parts-ean-rsrv-last-date" then do:
                      RUN gen-bc( input buf_bar-code.b-code, output bar_code ).
                      IBM-good-code  = trim( bar_code ) .
                      run ex-bbc in this-procedure (input rs-list-method, input rs-status, input line-mode , input no, input IBM-good-code, input yes, buffer buf_bar-code, buffer buf_prod-bc).
                    end.
                  end.
                end.
              end.
            end.
          end.
        end.
      end.
      assign                                                           buf_scnblist-hist.num-add  = lns-cnt - v-num-add                       buf_scnblist-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_scnblist-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_scnblist-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "parts-fib":U
  or
  when "parts-ean-fib":U
  then do:
    for each buf_scnblist-hist where
            buf_scnblist-hist.id = p-id
        and  buf_scnblist-hist.item_ <> '':U:
      assign
      v-curr-obj-type = entry(1, buf_scnblist-hist.item_, chr(3))
      v-curr-obj-code = integer(entry(2, buf_scnblist-hist.item_, chr(3)))
      no-error
      .
      if error-status:error then do: end. else do:
        find first buf_user-obj no-lock where
                  buf_user-obj.obj-type = v-curr-obj-type
              AND buf_user-obj.obj-code = v-curr-obj-code
              AND buf_user-obj.db-num = v-cntxt-db-num
              AND buf_user-obj.user-id = v-cntxt-userid
              no-error .
        if available buf_user-obj then do:
          for each buf_parts no-lock where
                  buf_parts.obj-type = v-obj-type
                and buf_parts.obj-code = v-obj-code
                and buf_parts.out-code  = 'free-zone':U
                and buf_parts.status_   = false:
            if buf_parts.defect  = logical('yes':U) then do:
              v-b-code = 0.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run partbcod in g#library
  (buffer buf_parts
  ,output v-b-code
  ) no-error .
              if v-b-code > 0 then do:
                find first buf_bar-code no-lock where
                          buf_bar-code.b-code = v-b-code no-error.
                if available buf_bar-code then do:
                  find first ub.goods no-lock where
                            ub.goods.gds-code = buf_bar-code.gds-code no-error.
                  if available ub.goods then do:
                    run get-prt-and-unit in this-procedure (
                                                                  input goods.prt-root
                                                                  ,input goods.unit-base
                                                                  ,output l-empty-scale
                                                        ) .
                    if rs-list-method = "parts-fib" then do:
                      run ex-bbc in this-procedure (input rs-list-method, input rs-status, input line-mode ,input no, input "":U, input no, buffer buf_bar-code, buffer prod-bc).
  end.
                    if rs-list-method = "parts-ean-fib" then do:
                      RUN gen-bc( input buf_bar-code.b-code, output bar_code ).
                      IBM-good-code  = trim( bar_code ) .
                      run ex-bbc in this-procedure (input rs-list-method, input rs-status, input line-mode , input no, input IBM-good-code, input yes, buffer buf_bar-code, buffer buf_prod-bc).
                    end.
                  end.
                end.
              end.
            end.
          end.
        end.
      end.
      assign                                                           buf_scnblist-hist.num-add  = lns-cnt - v-num-add                       buf_scnblist-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_scnblist-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_scnblist-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "parts-rsrv-fib":U
  or
  when "parts-ean-rsrv-fib":U
  then do:
    for each buf_scnblist-hist where
            buf_scnblist-hist.id = p-id
        and  buf_scnblist-hist.item_ <> '':U:
      assign
      v-curr-obj-type = entry(1, buf_scnblist-hist.item_, chr(3))
      v-curr-obj-code = integer(entry(2, buf_scnblist-hist.item_, chr(3)))
      no-error
      .
      if error-status:error then do: end. else do:
        find first buf_user-obj no-lock where
                  buf_user-obj.obj-type = v-curr-obj-type
              AND buf_user-obj.obj-code = v-curr-obj-code
              AND buf_user-obj.db-num = v-cntxt-db-num
              AND buf_user-obj.user-id = v-cntxt-userid
              no-error .
        if available buf_user-obj then do:
          for each buf_parts no-lock where
                  buf_parts.obj-type = v-obj-type
                and buf_parts.obj-code = v-obj-code
                and buf_parts.rsrv-free = true
                and buf_parts.status_   = false
                and buf_parts.out-code  <> 'free-zone':U
                :
            if buf_parts.defect = logical('yes':U) then do:
              v-b-code = 0.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run partbcod in g#library
  (buffer buf_parts
  ,output v-b-code
  ) no-error .
              if v-b-code > 0 then do:
                find first buf_bar-code no-lock where
                          buf_bar-code.b-code = v-b-code no-error.
                if available buf_bar-code then do:
                  find first ub.goods no-lock where
                            ub.goods.gds-code = buf_bar-code.gds-code no-error.
                  if available ub.goods then do:
                    run get-prt-and-unit in this-procedure (
                                                                  input goods.prt-root
                                                                  ,input goods.unit-base
                                                                  ,output l-empty-scale
                                                        ) .
                    if rs-list-method = "parts-rsrv-fib" then do:
                      run ex-bbc in this-procedure (input rs-list-method, input rs-status, input line-mode ,input no, input "":U, input no, buffer buf_bar-code, buffer prod-bc).
                    end.
                    if rs-list-method = "parts-ean-rsrv-fib" then do:
                      RUN gen-bc( input buf_bar-code.b-code, output bar_code ).
                      IBM-good-code  = trim( bar_code ) .
                      run ex-bbc in this-procedure (input rs-list-method, input rs-status, input line-mode , input no, input IBM-good-code, input yes, buffer buf_bar-code, buffer buf_prod-bc).
                    end.
                  end.
                end.
              end.
            end.
          end.
        end.
      end.
      assign                                                           buf_scnblist-hist.num-add  = lns-cnt - v-num-add                       buf_scnblist-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_scnblist-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_scnblist-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "parts-end-date-obj":U
  or
  when "parts-ean-end-date-obj":U
  then do:
     for each buf_scnblist-hist where
            buf_scnblist-hist.id = p-id
        and  buf_scnblist-hist.item_ <> '':U:
      assign
      v-curr-obj-type = entry(1, buf_scnblist-hist.item_, chr(3))
      v-curr-obj-code = integer(entry(2, buf_scnblist-hist.item_, chr(3)))
      v-from-date =     date(entry(3, buf_scnblist-hist.item_, chr(3)))
      v-to-date = date(entry(4, buf_scnblist-hist.item_, chr(3)))
      v-from-date-str = substitute("&1-&2-&3", string(year(v-from-date), "9999")
                                             , string(month(v-from-date), "99")
                                             , string(day(v-from-date), "99"))
      v-to-date-str   = substitute("&1-&2-&3", string(year(v-to-date), "9999")
                                              ,string(month(v-to-date), "99")
                                              ,string(day(v-to-date), "99"))
      no-error
      .
      if error-status:error then do: end. else do:
        find first buf_user-obj no-lock where
                  buf_user-obj.obj-type = v-curr-obj-type
              AND buf_user-obj.obj-code = v-curr-obj-code
              AND buf_user-obj.db-num = v-cntxt-db-num
              AND buf_user-obj.user-id = v-cntxt-userid
              no-error .
        if available buf_user-obj then do:
          for each buf_parts-obj-attr no-lock where
                  buf_parts-obj-attr.obj-type = v-curr-obj-type
              and buf_parts-obj-attr.obj-code = v-curr-obj-code
              and buf_parts-obj-attr.attr-code = 'parts-end':U
              and buf_parts-obj-attr.attr-value >= v-from-date-str
              and buf_parts-obj-attr.attr-value < v-to-date-str:
            find first ub.goods no-lock where
                      ub.goods.gds-code = buf_parts-obj-attr.gds-code no-error.
            if available ub.goods then do:
              find first buf_bar-code no-lock where
                   buf_bar-code.gds-code = buf_parts-obj-attr.gds-code
               and buf_bar-code.in-code = buf_parts-obj-attr.in-code
               and buf_bar-code.part-code = buf_parts-obj-attr.part-code
               and buf_bar-code.unit-cli = ub.goods.unit-base
                   no-error.
              if available buf_bar-code then do:
                run get-prt-and-unit in this-procedure (
                                                              input goods.prt-root
                                                              ,input goods.unit-base
                                                              ,output l-empty-scale
                                                    ) .
                if rs-list-method = "parts-end-date-obj" then do:
                  run ex-bbc in this-procedure (input rs-list-method, input rs-status, input line-mode ,input no, input "":U, input no, buffer buf_bar-code, buffer prod-bc).
                end.
                if rs-list-method = "parts-ean-end-date-obj" then do:
                  RUN gen-bc( input buf_bar-code.b-code, output bar_code ).
                  IBM-good-code  = trim( bar_code ) .
                  run ex-bbc in this-procedure (input rs-list-method, input rs-status, input line-mode , input no, input IBM-good-code, input yes, buffer buf_bar-code, buffer buf_prod-bc).
                end.
              end.
            end.
          end.
        end.
      end.
      assign                                                           buf_scnblist-hist.num-add  = lns-cnt - v-num-add                       buf_scnblist-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_scnblist-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_scnblist-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "loc-sc-codes":U
  or when "loc-pg-codes":U
  then do:
    for each buf_scnblist-hist where
            buf_scnblist-hist.id = p-id
        and  buf_scnblist-hist.item_ <> '':U:
      assign
      v-db-num = integer(entry(1, buf_scnblist-hist.item_, chr(3)))
      v-using = (entry(2, buf_scnblist-hist.item_, chr(3)))
      no-error
      .
      if error-status:error then do:
      end.
      else do:
        for each buf_code-range no-lock where
                buf_code-range.range-type = (if rs-list-method = "loc-sc-codes"
                                             then 'sclc':U
                                             else 'pglc':U):
          if v-db-num = g#db-num then do:
            _prod-bc:
            for each buf_prod-bc no-lock where
                    buf_prod-bc.b-str >= string(buf_code-range.first-code, "99999")
              and  buf_prod-bc.b-str <= string(buf_code-range.last-code, "99999")
            on error undo, return error
            :
              if length( buf_prod-bc.b-str ) < 6 then do:
                assign
                l-prod-bc-weight   = no
                l-prod-bc-pgweight = no
                .
                if buf_code-range.range-type = 'sclc':U then do:
define variable vss-include-info63 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer buf_prod-bc
  ,input  'weight=request':u
  ,output l-prod-bc-weight
  ) no-error .
                  if not l-prod-bc-weight then next _prod-bc.
                end.
                else do:
define variable vss-include-info64 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer buf_prod-bc
  ,input  'pgweight=request':u
  ,output l-prod-bc-pgweight
  ) no-error .
                  if not l-prod-bc-pgweight then next _prod-bc.
                end.
                find first buf_bar-code no-lock
                  where buf_bar-code.b-code = buf_prod-bc.b-code
                .
                if available buf_bar-code then do:
                  find first ub.goods no-lock
                    where ub.goods.gds-code = buf_bar-code.gds-code
                    no-error
                  .
                  case v-using:
                    when "all" then do:
                    end.
                    otherwise do:
                      _gds-obj-attr:
                      for each buf_clients no-lock where
                              buf_clients.db-num = v-db-num,
                          each buf_gds-obj-attr no-lock where
                              buf_gds-obj-attr.obj-type = buf_clients.obj-type
                         and  buf_gds-obj-attr.obj-code = buf_clients.obj-code
                         and  buf_gds-obj-attr.gds-code = ub.goods.gds-code :
                        if buf_gds-obj-attr.attr-value = buf_prod-bc.b-str
                        and v-using = "nonusing" then do:
                          find first buf_scales-gds no-lock where
                                  buf_scales-gds.db-num = v-db-num
                              and buf_scales-gds.obj-type = buf_clients.obj-type
                              and buf_scales-gds.obj-code = buf_clients.obj-code
                              and buf_scales-gds.b-code = buf_bar-code.b-code no-error.
                          if available buf_scales-gds then do:
                            next _prod-bc.
                          end.
                        end.
                        if buf_gds-obj-attr.attr-value = buf_prod-bc.b-str
                        and v-using = "using" then do:
                          leave _gds-obj-attr.
                        end.
                      end.
                      if v-using = "using"
                      and not available buf_gds-obj-attr then next _prod-bc.
                    end.
                  end case.
                  run get-prt-and-unit in this-procedure (
                                                           input ub.goods.prt-root
                                                          ,input ub.goods.unit-base
                                                          ,output l-empty-scale
                                                          ) .
                  run ex-bbc in this-procedure (input rs-list-method, input rs-status, input line-mode ,  input l-empty-scale, input buf_prod-bc.b-str, input no, buffer buf_bar-code, buffer buf_prod-bc).
                end.
              end.
            end.
          end.
          else do:
            if g#db-num = 0 then do:
              _prod-bc-db:
              for each buf_prod-bc-db no-lock where
                      buf_prod-bc-db.b-str >= string(buf_code-range.first-code, "99999")
                and  buf_prod-bc-db.b-str <= string(buf_code-range.last-code, "99999")
                and buf_prod-bc-db.db-num = v-db-num
              on error undo, return error
              :
                if length( buf_prod-bc-db.b-str ) < 6 then do:
                  find first buf_bar-code no-lock
                    where buf_bar-code.b-code = buf_prod-bc-db.b-code
                  .
                  if available buf_bar-code then do:
                    find first ub.goods no-lock
                      where ub.goods.gds-code = buf_bar-code.gds-code
                      no-error
                    .
                    if buf_code-range.range-type = 'sclc':U then do:
define variable vss-include-info65 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbctv in g#library
  (input buf_prod-bc-db.b-str
  ,input  buf_bar-code.unit-cli
  ,input  ub.goods.unit-base
  ,input  'weight=request':U
  ,output l-prod-bc-weight
  ) no-error .
                      if not l-prod-bc-weight then next _prod-bc-db.
                    end.
                    else do:
define variable vss-include-info66 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbctv in g#library
  (input buf_prod-bc-db.b-str
  ,input  buf_bar-code.unit-cli
  ,input  ub.goods.unit-base
  ,input  'weight=request':U
  ,output l-prod-bc-pgweight
  ) no-error .
                      if not l-prod-bc-pgweight then next _prod-bc-db.
                    end.
                    case v-using:
                      when "all" then do:
                      end.
                      otherwise do:
                        _gds-obj-attr:
                        for each buf_clients no-lock where
                                buf_clients.db-num = v-db-num,
                            each buf_gds-obj-attr no-lock where
                                buf_gds-obj-attr.obj-type = buf_clients.obj-type
                          and  buf_gds-obj-attr.obj-code = buf_clients.obj-code
                          and  buf_gds-obj-attr.gds-code = ub.goods.gds-code :
                          if buf_gds-obj-attr.attr-value = buf_prod-bc-db.b-str
                          and v-using = "nonusing" then do:
                            find first buf_scales-gds no-lock where
                                    buf_scales-gds.db-num = v-db-num
                                and buf_scales-gds.obj-type = buf_clients.obj-type
                                and buf_scales-gds.obj-code = buf_clients.obj-code
                                and buf_scales-gds.b-code = buf_bar-code.b-code no-error.
                            if available buf_scales-gds then do:
                              next _prod-bc-db.
                            end.
                          end.
                          if buf_gds-obj-attr.attr-value = buf_prod-bc-db.b-str
                          and v-using = "using" then do:
                            leave _gds-obj-attr.
                          end.
                        end.
                        if v-using = "using"
                        and not available buf_gds-obj-attr then next _prod-bc-db.
                      end.
                    end case.
                    run get-prt-and-unit in this-procedure (
                                                            input ub.goods.prt-root
                                                            ,input ub.goods.unit-base
                                                            ,output l-empty-scale
                                                            ) .
                    run ex-bbc in this-procedure (input rs-list-method, input rs-status, input line-mode ,  input l-empty-scale, input buf_prod-bc-db.b-str, input no, buffer buf_bar-code, buffer buf_prod-bc).
                  end.
                end.
              end.
            end.
          end.
        end.
      end.
      assign                                                           buf_scnblist-hist.num-add  = lns-cnt - v-num-add                       buf_scnblist-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_scnblist-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_scnblist-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "gbl-sc-codes":U
  then do:
    for each buf_scnblist-hist where
            buf_scnblist-hist.id = p-id
        and  buf_scnblist-hist.item_ <> '':U:
      assign
      v-db-num = integer(entry(1, buf_scnblist-hist.item_, chr(3)))
      v-using = (entry(2, buf_scnblist-hist.item_, chr(3)))
      no-error
      .
      if error-status:error then do:
      end.
      else do:
        for each buf_code-range no-lock where
                buf_code-range.range-type = 'scgb':U
            and buf_code-range.db-num = v-db-num     :
          _prod-bc:
          for each buf_prod-bc no-lock where
                  buf_prod-bc.b-str >= string(buf_code-range.first-code, "99999")
            and  buf_prod-bc.b-str <= string(buf_code-range.last-code, "99999")
          on error undo, return error
          :
            if length( buf_prod-bc.b-str ) < 6 then do:
              assign
              l-prod-bc-weight   = no
              l-prod-bc-glob = no
              .
define variable vss-include-info67 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer buf_prod-bc
  ,input  'weight=request':u
  ,output l-prod-bc-weight
  ) no-error .
              if not l-prod-bc-weight then next _prod-bc.
define variable vss-include-info68 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer buf_prod-bc
  ,input  'global=request':u
  ,output l-prod-bc-glob
  ) no-error .
              if not l-prod-bc-glob then next _prod-bc.
              find first buf_bar-code no-lock
                where buf_bar-code.b-code = buf_prod-bc.b-code
              .
              if available buf_bar-code then do:
                find first ub.goods no-lock
                  where ub.goods.gds-code = buf_bar-code.gds-code
                  no-error
                .
                case v-using:
                  when "all" then do:
                  end.
                  otherwise do:
                    _gds-obj-attr:
                    for each buf_clients no-lock where
                            buf_clients.db-num = v-db-num,
                        each buf_gds-obj-attr no-lock where
                            buf_gds-obj-attr.obj-type = buf_clients.obj-type
                        and  buf_gds-obj-attr.obj-code = buf_clients.obj-code
                        and  buf_gds-obj-attr.gds-code = ub.goods.gds-code :
                      if buf_gds-obj-attr.attr-value = buf_prod-bc.b-str
                      and v-using = "nonusing" then do:
                        find first buf_scales-gds no-lock where
                                buf_scales-gds.db-num = v-db-num
                            and buf_scales-gds.obj-type = buf_clients.obj-type
                            and buf_scales-gds.obj-code = buf_clients.obj-code
                            and buf_scales-gds.b-code = buf_bar-code.b-code no-error.
                        if available buf_scales-gds then do:
                          next _prod-bc.
                        end.
                      end.
                      if buf_gds-obj-attr.attr-value = buf_prod-bc.b-str
                      and v-using = "using" then do:
                        leave _gds-obj-attr.
                      end.
                    end.
                    if v-using = "using"
                    and not available buf_gds-obj-attr then next _prod-bc.
                  end.
                end case.
                run get-prt-and-unit in this-procedure (
                                                          input ub.goods.prt-root
                                                        ,input ub.goods.unit-base
                                                        ,output l-empty-scale
                                                        ) .
                run ex-bbc in this-procedure (input rs-list-method, input rs-status, input line-mode ,  input l-empty-scale, input buf_prod-bc.b-str, input no, buffer buf_bar-code, buffer buf_prod-bc).
              end.
            end.
          end.
        end.
      end.
      assign                                                           buf_scnblist-hist.num-add  = lns-cnt - v-num-add                       buf_scnblist-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_scnblist-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_scnblist-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "filter" then do:
    define variable v-filter-var as character no-undo .
    find first buf_scnblist-hist where
            buf_scnblist-hist.id = p-id
        AND buf_scnblist-hist.item_ <> '':U .
    run proc-write-filter-expression-var in this-procedure ( input buf_scnblist-hist.item_, output v-filter-var ).
    run gbl/scnbfill.p (
                    input "Формирование списка по фильтру (без учета сортировки)"
                  , input rs-list-method
                  , input rs-status
                  , input line-mode
                  , input v-filter-var
                  , output lns-cnt
                  , output line-rec
                  ) .
    assign                                                           buf_scnblist-hist.num-add  = lns-cnt - v-num-add                       buf_scnblist-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_scnblist-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_scnblist-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
  end.
end.
dsp-rs:fgcolor in frame Dialog-Frame = 4.
if session:set-wait-state( "" )  then .
case line-mode :
  when 'ДОБАВЛЕНИЕ':U then do:
    tot-lns = tot-lns + lns-cnt.
    if not p-from-macro or p-step then
    message
    "Добавлено строк :" lns-cnt skip(0)
    string(if lns-ignore <> 0
    then ("Проигнорировано строк :" + string(lns-ignore))
    else "":U)
    .
  end.
  when 'удаление':U then do:
    tot-lns = tot-lns - lns-cnt.
    if not p-from-macro or p-step then
    message
    "Удалено строк :" lns-cnt skip(0)
    string(if lns-ignore <> 0
    then ("Проигнорировано строк :" + string(lns-ignore))
    else "":U)
    .
  end.
end.
if line-mode <> 'ОСТАВИТЬ':U then  run UI-on.
end.
END PROCEDURE.
procedure proc-file-list-methods :
define input parameter p-from-macro as logical no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
define input parameter line-mode as character no-undo .
define input parameter p-id      as integer no-undo .
define variable ss as character no-undo .
define variable b-c as integer no-undo.
define variable imp-type like ub.goods.prod-type no-undo.
define variable imp-code like ub.goods.prod-code no-undo.
define variable imp-art like ub.goods.artic no-undo.
define variable imp-doc-code like ub.trn-doc.doc-code no-undo.
define variable imp-doc-type as character no-undo.
define variable scan-qnty as dec no-undo.
define variable bc-qnty as dec no-undo.
define variable varresult   as character         no-undo.
define variable vartype-bc  as character         no-undo.
define variable varweight   as decimal           no-undo.
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
define buffer buf_scnblist-hist for scnblist-hist.
do
on error undo, return error
:
find first buf_scnblist-hist where
          buf_scnblist-hist.id = p-id
      AND buf_scnblist-hist.item_ <> '':U .
run gbl/filename.p
  (input  entry(1, buf_scnblist-hist.item_, chr(4) )
  ,output v-full-path
  ,output v-path
  ,output v-file-name
  ,output v-file-name-no-ext
  ,output v-file-name-ext
  ) no-error .
  if error-status:error then do: end. else do:
  input stream sout from value (v-full-path).
  CASE rs-list-method:
    when "file-gds" then do:
      if p-from-macro then
      run restore-codes in this-procedure (input entry(2, buf_scnblist-hist.item, chr(4)), input p-curr-obj-type, input p-curr-obj-code).
      repeat:
          import stream sout imp-type imp-code imp-art scan-qnty no-error.
          find ub.goods where ub.goods.prod-type = imp-type
                      and ub.goods.prod-code = imp-code
                      and ub.goods.artic     = imp-art no-lock no-error.
          if available ub.goods then do:
            assign                 new-good = yes                 petrol-trk = no                 cashparts = no                 main-b-code = 0                 .
            run process-one-good in this-procedure (input rs-list-method, input rs-status, input line-mode ,buffer goods) no-error .
          end.
        end.
    end.
    when "scaner" then do:
      message "При чтении из файла количеств они будут прибавлены к количествам в списке.".
       repeat:
        import stream sout unformatted ss.
        ss = trim (ss).
        if ss = "" then next.
        if substr (ss, 1, 1) < "0" or substr (ss, 1, 1) > "9" then
          if substr (ss, 1, 4) = "data" then ss = entry (2, ss, ":").
          else next.
          assign
          scan-qnty = dec (entry (2, ss))
          ss = trim (entry (1, ss)).
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_bc-rcnz in g#libbcrcn
(
 input  parparentproc
,input  ss
,input  ?
,input  p-curr-obj-type
,input  p-curr-obj-type
,input  yes
,input  no
,input  varscales-pref
,input  varpgscales-pref
,output varresult
,output vartype-bc
,output varweight
,buffer ub.bar-code
,buffer ub.prod-bc
,buffer ub.place
) no-error.
        if not available ub.bar-code then next.
        bc-qnty = ub.bar-code.cli-base-rate.
        assign                 new-good = yes                 petrol-trk = no                 cashparts = no                 main-b-code = 0                 .
        find ub.goods where ub.goods.gds-code = ub.bar-code.gds-code NO-LOCK no-error.
        if available ub.goods then do:
          run get-prt-and-unit in this-procedure (
                                                  input ub.goods.prt-root
                                                  ,input ub.goods.unit-base
                                                  ,output l-empty-scale
                                                  ) .
          run ex-bbc in this-procedure (input rs-list-method, input rs-status, input line-mode , input no, input "":U, input (not available prod-bc), buffer bar-code, buffer prod-bc).
          if available scnblist and
            scnblist.artic = ub.goods.artic and
            scnblist.prod-type = ub.goods.prod-type and
            scnblist.prod-code = ub.goods.prod-code then
            scnblist.qnty = scnblist.qnty + scan-qnty * bc-qnty.
        end.
      end.
    end.
  END CASE.
  input stream sout close.
  assign                                                           buf_scnblist-hist.num-add  = lns-cnt - v-num-add                       buf_scnblist-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_scnblist-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_scnblist-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
  end.
end.
END PROCEDURE.
PROCEDURE write-hist :
define input parameter p-from-macro as logical no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
define input parameter line-mode as character no-undo .
define parameter buffer buf_goods for ub.goods.
define variable v-ii as integer no-undo .
define variable v-temp-seq as integer no-undo .
if rs-list-method begins "single" then do:
  if v-no-hist < 0 then do:
    run create-scnblist-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                        , input-output v-seq
                                        , input 0
                                        , input get-hist-mode(line-mode)
                                        , input (if line-mode = 'ДОБАВЛЕНИЕ':U
                                                then (substitute("Коды по ТОВАРУ c гл.кодом &1 &2 &3&4 &5 -"
                                                          , buf_goods.gds-code
                                                          , buf_goods.artic
                                                          , buf_goods.prod-type
                                                          , buf_goods.prod-code
                                                          , buf_goods.gds-name) +
                                                       (if t-loc-base then 'основн.'  else '':U) + chr(32) +                           (if t-bc-base  then 'основн.EAN'  else '':U) + chr(32) +                        (if t-bc-alt then 'неосновн.EAN'  else '':U) + chr(32) +                           (if t-loc-alt  then 'неосновн.'  else '':U) + chr(32) +                      (if t-pb-base then 'ДопБК основн.'  else '':U) + chr(32) +                      (if t-pb-alt then 'ДопБК неосновн.'  else '':U) + chr(32) +                     (if t-sc-base then 'весов. и топл.'  else '':U) + chr(32) +                     (if t-all-prt then 'все признаки'  else '':U) + chr(32) +                       (if t-parts-ser then 'на сер. товар'  else '':U) + chr(32) +                    (if t-parts-not-blank then 'на непуст. № парт.'  else '':U) + chr(32) +         (if t-parts-all then 'все партии'  else '':U))
                                                else substitute("КОД &1 товар c гл.кодом &2 &3 &4&5 &6"
                                                          , (if scnblist.b-str <> '':U then scnblist.b-str else string(scnblist.b-code))
                                                          , scnblist.gds-code
                                                          , scnblist.artic
                                                          , scnblist.prod-type
                                                          , scnblist.prod-code
                                                          , scnblist.gds-name)
                                                )
                                        , input tot-lns
                                        , input (rs-list-method + (if line-mode = 'ДОБАВЛЕНИЕ':U
                                                                  then '':U
                                                                  else (chr(4) + (if scnblist.b-str <> '':U
                                                                                        then 'prod-bc':U
                                                                                        else (if scnblist.loc-ean
                                                                                              then 'loc-ean':U
                                                                                              else 'bar-code':U)
                                                                                        )
                                                                        )
                                                                  )
                                                )
                                        , input rs-status
                                        , input (if line-mode = 'ДОБАВЛЕНИЕ':U
                                                 then ('goods':U + chr(3) + string(buf_goods.gds-code) + chr(4) +
                                                       (if t-loc-base then 'loc-base':U  else '':U) + chr(32) +                        (if t-bc-base  then 'bc-base':U  else '':U) + chr(32) +                         (if t-bc-alt then 'bc-alt':U  else '':U) + chr(32) +                            (if t-loc-alt  then 'loc-alt':U  else '':U) + chr(32) +                         (if t-pb-base then 'pb-base':U  else '':U) + chr(32) +                          (if t-pb-alt then 'pb-alt':U  else '':U) + chr(32) +                            (if t-sc-base then 'sc-base'  else '':U) + chr(32) +                            (if t-all-prt then 'all-prt'  else '':U) + chr(32) +                            (if t-parts-ser then 'parts-ser':U  else '':U) + chr(32) +                      (if t-parts-not-blank then 'parts-not-blank'  else '':U) + chr(32) +            (if t-parts-all then 'parts-all'  else '':U))
                                                 else (if scnblist.b-str <> '':u and scnblist.loc-ean = no
                                                      then ('prod-bc':U + chr(3) + scnblist.b-str)
                                                      else ('bar-code':U + chr(3) + string(scnblist.b-code))
                                                      )
                                                 )
                                        , input '':U
                                        , input ?
                                        ).
  end.
  else do:
    v-temp-seq = v-seq - 1.
    do v-ii = 0 to v-no-hist:
      run create-scnblist-hist in this-procedure(input ('ИЗМЕНЕНИЕ':U + chr(4) + 'mode':U)
                                          , input-output v-temp-seq
                                          , input v-ii
                                          , input get-hist-mode(line-mode)
                                          , input (substitute("Коды по ТОВАРУ c гл.кодом &1 &2 &3&4 &5 -"
                                                            , scnblist.gds-code
                                                            , scnblist.artic
                                                            , scnblist.prod-type
                                                            , scnblist.prod-code
                                                            , scnblist.gds-name) +
                                                   (if t-loc-base then 'основн.'  else '':U) + chr(32) +                           (if t-bc-base  then 'основн.EAN'  else '':U) + chr(32) +                        (if t-bc-alt then 'неосновн.EAN'  else '':U) + chr(32) +                           (if t-loc-alt  then 'неосновн.'  else '':U) + chr(32) +                      (if t-pb-base then 'ДопБК основн.'  else '':U) + chr(32) +                      (if t-pb-alt then 'ДопБК неосновн.'  else '':U) + chr(32) +                     (if t-sc-base then 'весов. и топл.'  else '':U) + chr(32) +                     (if t-all-prt then 'все признаки'  else '':U) + chr(32) +                       (if t-parts-ser then 'на сер. товар'  else '':U) + chr(32) +                    (if t-parts-not-blank then 'на непуст. № парт.'  else '':U) + chr(32) +         (if t-parts-all then 'все партии'  else '':U))
                                          , input tot-lns
                                          , input '':U
                                          , input '':U
                                          , input ('goods':U + chr(3) + string(scnblist.gds-code) +
                                                  (if t-loc-base then 'loc-base':U  else '':U) + chr(32) +                        (if t-bc-base  then 'bc-base':U  else '':U) + chr(32) +                         (if t-bc-alt then 'bc-alt':U  else '':U) + chr(32) +                            (if t-loc-alt  then 'loc-alt':U  else '':U) + chr(32) +                         (if t-pb-base then 'pb-base':U  else '':U) + chr(32) +                          (if t-pb-alt then 'pb-alt':U  else '':U) + chr(32) +                            (if t-sc-base then 'sc-base'  else '':U) + chr(32) +                            (if t-all-prt then 'all-prt'  else '':U) + chr(32) +                            (if t-parts-ser then 'parts-ser':U  else '':U) + chr(32) +                      (if t-parts-not-blank then 'parts-not-blank'  else '':U) + chr(32) +            (if t-parts-all then 'parts-all'  else '':U))
                                          , input '':U
                                          , input ?
                                          ).
    end.
  end.
end.
else do:
  v-temp-seq = v-seq - 1.
  do v-ii = 0 to v-no-hist:
    run create-scnblist-hist in this-procedure(input ('ИЗМЕНЕНИЕ':U + chr(4) + 'mode':U)
                                        , input-output  v-temp-seq
                                        , input v-ii
                                        , input get-hist-mode(line-mode)
                                        , input '':U
                                        , input tot-lns
                                        , input rs-list-method
                                        , input '':U
                                        , input '':U
                                        , input '':U
                                        , input ?
                                        ).
  end.
end.
END.
FUNCTION stat-line RETURNS CHARACTER(input p-status-chr as character):
DEFINE VARIABLE var-stat-line as character no-undo .
CASE p-status-chr:
  when 'все':U then do:
    assign
    var-stat-line = "(текущие и удаленные товары)"
    .
  end.
  when 'текущие':U then do:
    assign
    var-stat-line = "(текущие товары)"
    .
  end.
  when 'удаленные':U then do:
    assign
    var-stat-line = "(неактивные товары)"
    .
  end.
END CASE.
return var-stat-line .
END.
procedure proc-vc-rs-list-method :
define variable v-operation as integer no-undo .
define variable main-code like ub.bar-code.b-code no-undo .
define variable v-chk-date-chr as character no-undo .
define variable dsp-rs-option as character no-undo .
define variable v-curr-host-code like ub.sysconf.host-code no-undo .
define variable v-item_ as character no-undo .
define variable v-tbl-name as character no-undo .
define variable v-bh as handle no-undo .
define variable v-recs as integer   no-undo .
define variable v-temp-seq as integer   no-undo .
define variable v-line as integer   no-undo .
define variable v-tot-lns as integer   no-undo .
define variable f-name as character no-undo .
define variable rid-list as character no-undo .
define variable bar_code as character no-undo .
define variable v-jj as integer no-undo .
define variable v-rid as recid no-undo .
define buffer buf_scnblist-hist for scnblist-hist.
define buffer buf_prod-bc for ub.prod-bc.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_cash-desk for ub.cash-desk.
define buffer buf_db for ub.db.
  do
  on error undo, return error
  :
  assign
  frame Dialog-Frame
  T-all-prt
  T-bc-alt
  T-bc-base
  T-loc-alt
  T-loc-base
  T-parts-all
  T-parts-not-blank
  T-parts-ser
  T-pb-alt
  T-pb-base
  T-sc-base
  .
  if (
  T-all-prt or
  T-bc-alt  or
  T-bc-base or
  T-loc-alt or
  T-loc-base  or
  T-parts-all  or
  T-parts-not-blank or
  T-parts-ser or
  T-pb-alt    or
  T-pb-base   or
  T-sc-base) = no then do:
    message
    "Не выбран ни один тип кодов!"
    view-as alert-box error .
    undo, return error .
  end.
  assign
  temp-shop.obj-code = p-curr-obj-code
  temp-shop.all-prt = T-all-prt
  temp-shop.cd-bc-alt = T-bc-alt
  temp-shop.cd-bc-base = T-bc-base
  temp-shop.cd-loc-alt = T-loc-alt
  temp-shop.cd-loc-base = T-loc-base
  temp-shop.cd-parts-all = T-parts-all
  temp-shop.cd-parts-not-blank = T-parts-not-blank
  temp-shop.cd-parts-ser = T-parts-ser
  temp-shop.cd-pb-alt = T-pb-alt
  temp-shop.cd-pb-base = T-pb-base
  temp-shop.cd-sc-base = T-sc-base
  .
    v-no-hist = - 1.
    if temp-list.fvalue = "single" then
      run UI-on.
    else do:
      v-no-hist = 0.
      case rs-list-method:
        when "all" then do:
          glog = yes.
          message "Коды выбранных типов для всех товаров из справочника товаров"
          skip stat-line(rs-status)
          view-as alert-box question buttons OK-Cancel update glog.
          if not glog then do:
            run UI-on.
            return error .
          end.
          v-no-hist = 1.
          run create-scnblist-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                              , input-output v-seq
                                              , input 0
                                              , input '':U
                                              , input (substitute('Коды всех товаров &1 - ', stat-line(rs-status)) +
                                                     (if t-loc-base then 'основн.'  else '':U) + chr(32) +                           (if t-bc-base  then 'основн.EAN'  else '':U) + chr(32) +                        (if t-bc-alt then 'неосновн.EAN'  else '':U) + chr(32) +                           (if t-loc-alt  then 'неосновн.'  else '':U) + chr(32) +                      (if t-pb-base then 'ДопБК основн.'  else '':U) + chr(32) +                      (if t-pb-alt then 'ДопБК неосновн.'  else '':U) + chr(32) +                     (if t-sc-base then 'весов. и топл.'  else '':U) + chr(32) +                     (if t-all-prt then 'все признаки'  else '':U) + chr(32) +                       (if t-parts-ser then 'на сер. товар'  else '':U) + chr(32) +                    (if t-parts-not-blank then 'на непуст. № парт.'  else '':U) + chr(32) +         (if t-parts-all then 'все партии'  else '':U))
                                              , input tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input (if t-loc-base then 'loc-base':U  else '':U) + chr(32) +                        (if t-bc-base  then 'bc-base':U  else '':U) + chr(32) +                         (if t-bc-alt then 'bc-alt':U  else '':U) + chr(32) +                            (if t-loc-alt  then 'loc-alt':U  else '':U) + chr(32) +                         (if t-pb-base then 'pb-base':U  else '':U) + chr(32) +                          (if t-pb-alt then 'pb-alt':U  else '':U) + chr(32) +                            (if t-sc-base then 'sc-base'  else '':U) + chr(32) +                            (if t-all-prt then 'all-prt'  else '':U) + chr(32) +                            (if t-parts-ser then 'parts-ser':U  else '':U) + chr(32) +                      (if t-parts-not-blank then 'parts-not-blank'  else '':U) + chr(32) +            (if t-parts-all then 'parts-all'  else '':U)
                                              , input '':U
                                              , input ?
                                              ).
        end.
        when "goods"
        or
        when "goods-b-code"
        or
        when "goods-b-code-ean"
        or
        when "goods-b-str"
        then do:
          glog = yes.
          case rs-list-method:
            when "goods" then do:
              assign
              dsp-rs-option = substitute("Заданные типы кодов для товаров: &1", stat-line(rs-status)) +
                              (if t-loc-base then 'основн.'  else '':U) + chr(32) +                           (if t-bc-base  then 'основн.EAN'  else '':U) + chr(32) +                        (if t-bc-alt then 'неосновн.EAN'  else '':U) + chr(32) +                           (if t-loc-alt  then 'неосновн.'  else '':U) + chr(32) +                      (if t-pb-base then 'ДопБК основн.'  else '':U) + chr(32) +                      (if t-pb-alt then 'ДопБК неосновн.'  else '':U) + chr(32) +                     (if t-sc-base then 'весов. и топл.'  else '':U) + chr(32) +                     (if t-all-prt then 'все признаки'  else '':U) + chr(32) +                       (if t-parts-ser then 'на сер. товар'  else '':U) + chr(32) +                    (if t-parts-not-blank then 'на непуст. № парт.'  else '':U) + chr(32) +         (if t-parts-all then 'все партии'  else '':U)
              v-item_ = (if t-loc-base then 'loc-base':U  else '':U) + chr(32) +                        (if t-bc-base  then 'bc-base':U  else '':U) + chr(32) +                         (if t-bc-alt then 'bc-alt':U  else '':U) + chr(32) +                            (if t-loc-alt  then 'loc-alt':U  else '':U) + chr(32) +                         (if t-pb-base then 'pb-base':U  else '':U) + chr(32) +                          (if t-pb-alt then 'pb-alt':U  else '':U) + chr(32) +                            (if t-sc-base then 'sc-base'  else '':U) + chr(32) +                            (if t-all-prt then 'all-prt'  else '':U) + chr(32) +                            (if t-parts-ser then 'parts-ser':U  else '':U) + chr(32) +                      (if t-parts-not-blank then 'parts-not-blank'  else '':U) + chr(32) +            (if t-parts-all then 'parts-all'  else '':U)
            .
            end.
            when "goods-b-code" then do:
              assign
              dsp-rs-option = substitute("Основн. и неосновн. лок.коды для товара: &1", stat-line(rs-status))
              v-tbl-name = 'bar-code':U
              v-bh       = buffer ub.goods:handle
             .
            end.
            when "goods-b-code-ean" then do:
              assign
              dsp-rs-option = substitute("Основн. и неосновн. лок.коды EAN для товара: &1", stat-line(rs-status))
              v-tbl-name = 'bar-code':U
              v-bh       = buffer buf_bar-code:handle
             .
            end.
            when "goods-b-str" then do:
              assign
              dsp-rs-option = substitute("Основн. и неосновн. Доп.БК для товара: &1", stat-line(rs-status))
              v-tbl-name = 'prod-bc':U
              v-bh       = buffer buf_prod-bc:handle
             .
            end.
          END CASE.
          if not glog then do:
            run UI-on.
            return error.
          end.
          run ref/gds-ref.p (  input parparentproc
                          ,input (if rs-list-method = "goods":U
                                  then "b-sel,b-mark,b-add"
                                  else "b-sel,b-add")
                          ,input ?
                          ,input ?
                          ,input  'объект':U
                          ,input ?
                          ,input ?
                          ,input ?
                          ,input ?
                          ,input p-curr-obj-type
                          ,input p-curr-obj-code
                          ,input ?
                          ,output ref-list).
          if ref-list <> "" then do:
            if rs-list-method = "goods-b-code":U
            or rs-list-method = "goods-b-code-ean":U
            then do:
              v-ref-rec = integer (entry (1, ref-list)).
              find ub.goods where recid (ub.goods) = v-ref-rec no-lock.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  ub.goods.gds-code
  ,input  ?
  ,output main-code
  ) no-error .
              if error-status:error then do:
                run UI-on.
                return error.
              end.
              run ref/alt-cds.w (input parparentproc
                            ,input p-curr-obj-type
                            ,input p-curr-obj-code
                            ,input "all-no-part"
                            ,input ub.goods.gds-code
                            ,input main-code
                            ,output rid-list) no-error .
              if error-status:error or rid-list = "" then do:
                run UI-on.
                return error.
              end.
            end.
            if rs-list-method = "goods-b-str":U
            then do:
              v-ref-rec = integer (entry (1, ref-list)).
              find ub.goods where recid (ub.goods) = v-ref-rec no-lock.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  ub.goods.gds-code
  ,input  ?
  ,output main-code
  ) no-error .
              if error-status:error then do:
                run UI-on.
                return error.
              end.
              run ref/prod-cds.w (
                              input parparentproc
                            , input p-curr-obj-type
                            , input p-curr-obj-code
                            , input "all-no-part"
                            , input goods.gds-code
                            , input main-code
                            , output rid-list) no-error .
              if error-status:error or rid-list = "" then do:
                run UI-on.
                return error.
              end.
            end.
            v-recs = num-entries (ref-list).
            if rs-list-method = 'goods' then do:
              do num-rec = 0 to v-recs:
                if num-rec > 0
                then do:
                  v-ref-rec = integer (entry (num-rec, ref-list)).
                  find goods where recid (goods) = v-ref-rec no-lock.
                end.
                if num-rec = 0 then do:
                  assign
                  v-temp-seq = v-seq
                  v-line     = 0
                  dsp-rs = dsp-rs-option
                  v-item_     = (if t-loc-base then 'loc-base':U  else '':U) + chr(32) +                        (if t-bc-base  then 'bc-base':U  else '':U) + chr(32) +                         (if t-bc-alt then 'bc-alt':U  else '':U) + chr(32) +                            (if t-loc-alt  then 'loc-alt':U  else '':U) + chr(32) +                         (if t-pb-base then 'pb-base':U  else '':U) + chr(32) +                          (if t-pb-alt then 'pb-alt':U  else '':U) + chr(32) +                            (if t-sc-base then 'sc-base'  else '':U) + chr(32) +                            (if t-all-prt then 'all-prt'  else '':U) + chr(32) +                            (if t-parts-ser then 'parts-ser':U  else '':U) + chr(32) +                      (if t-parts-not-blank then 'parts-not-blank'  else '':U) + chr(32) +            (if t-parts-all then 'parts-all'  else '':U)
                  v-tbl-name = '':U
                  v-bh       = ?
                  v-tot-lns = tot-lns
                  .
                end.
                else do:
                  assign
                  v-temp-seq = v-seq - 1
                  v-line     = num-rec
                  dsp-rs =  substitute("     гл. код &1 &2 &3&4 &5", goods.gds-code, goods.artic, goods.prod-type, goods.prod-code, goods.gds-name)
                  v-item_     = '':U
                  v-tbl-name = 'goods':U
                  v-bh       = buffer goods:handle
                  v-tot-lns = tot-lns + num-rec
                  .
                end.
                v-no-hist = num-rec.
                run create-scnblist-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                                    , input-output v-temp-seq
                                                    , input v-line
                                                    , input '':U
                                                    , input dsp-rs
                                                    , input v-tot-lns
                                                    , input rs-list-method
                                                    , input rs-status
                                                    , input v-item_
                                                    , input v-tbl-name
                                                    , input v-bh
                                                    ).
                if num-rec = 0 then v-seq  = v-temp-seq.
              end.
            end.
            else do:
              do num-rec = 0 to v-recs:
                do v-jj = 1 to num-entries(rid-list):
                  if num-rec = 0
                  and v-jj = 1
                  then do:
              v-ref-rec = integer (entry (1, ref-list)).
              find goods where recid (goods) = v-ref-rec no-lock.
              assign
                  v-temp-seq = v-seq
                  v-line     = 0
                  dsp-rs = dsp-rs-option
                  v-item_     = '':U
                  v-tbl-name = '':U
                  v-bh       = ?
                  v-tot-lns = tot-lns
                  .
                end.
                else do:
                  if rs-list-method = "goods-b-code":U
                  or rs-list-method = "goods-b-code-ean":U then do:
                    find first buf_bar-code no-lock where
                              recid(buf_bar-code) = integer(entry(v-jj, rid-list)) no-error .
                    if rs-list-method = "goods-b-code" then
                    bar_code = string(buf_bar-code.b-code).
                    else
                    RUN gen-bc in this-procedure ( input main-b-code, output bar_code ).
                  end.
                  else do:
                    find first buf_prod-bc no-lock where
                                recid(buf_prod-bc) = integer(entry(v-jj, rid-list)) no-error .
                    bar_code = buf_prod-bc.b-str.
                  end.
                  assign
                  v-temp-seq = v-seq - 1
                  v-line     = num-rec
              dsp-rs = dsp-rs-option + chr(32) +
                       substitute("Код &1 гл. код &2 &3 &4&5 &6"
                                 , bar_code
                                 , goods.gds-code
                                 , goods.artic
                                 , goods.prod-type
                                 , goods.prod-code
                                 , goods.gds-name)
                  v-item_     = '':u
                  v-tbl-name = if rs-list-method = "goods-b-code":U
                               or rs-list-method = "goods-b-code-ean":U
                               then 'bar-code':U
                               else 'prod-bc':U
                  v-bh       = if rs-list-method = "goods-b-code":U
                               or rs-list-method = "goods-b-code-ean":U
                               then buffer buf_bar-code:handle
                               else buffer buf_prod-bc:handle
                  v-tot-lns = tot-lns + num-rec
              .
                end.
                v-no-hist = num-rec.
              run create-scnblist-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                                  , input-output v-temp-seq
                                                  , input v-line
                                                  , input '':U
                                                  , input dsp-rs
                                                  , input v-tot-lns
                                                  , input rs-list-method
                                                  , input rs-status
                                                  , input v-item_
                                                  , input v-tbl-name
                                                  , input v-bh
                                                  ).
                if num-rec = 0 then v-seq  = v-temp-seq.
                end.
            end.
            end.
          end.
          else do:
            run UI-on.
            return error.
          end.
        end.
        when "gds-list":U then do:
          glog = yes.
          message "Коды выбранных типов для товаров, выбранных в список"
          skip stat-line(rs-status)
          view-as alert-box question buttons OK-Cancel update glog.
          if not glog then do:
            run UI-on.
            return error.
          end.
          for each gds-list:
            delete gds-list.
          end.
          v-recs = 0.
          num-rec = 0.
define variable vss-include-info69 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,output v-curr-host-code
  )  .
          run str/gds-list.w (input parparentproc, input v-curr-host-code, input p-curr-obj-type, input p-curr-obj-code).
          for each gds-list,
            first goods no-lock where goods.gds-code = gds-list.gds-code:
            if num-rec = 0 then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs-option = substitute("Коды выбранных типов товаров по списку: &1 - &2", rs-status, (if t-loc-base then 'основн.'  else '':U) + chr(32) +                           (if t-bc-base  then 'основн.EAN'  else '':U) + chr(32) +                        (if t-bc-alt then 'неосновн.EAN'  else '':U) + chr(32) +                           (if t-loc-alt  then 'неосновн.'  else '':U) + chr(32) +                      (if t-pb-base then 'ДопБК основн.'  else '':U) + chr(32) +                      (if t-pb-alt then 'ДопБК неосновн.'  else '':U) + chr(32) +                     (if t-sc-base then 'весов. и топл.'  else '':U) + chr(32) +                     (if t-all-prt then 'все признаки'  else '':U) + chr(32) +                       (if t-parts-ser then 'на сер. товар'  else '':U) + chr(32) +                    (if t-parts-not-blank then 'на непуст. № парт.'  else '':U) + chr(32) +         (if t-parts-all then 'все партии'  else '':U))
              v-item_     = (if t-loc-base then 'loc-base':U  else '':U) + chr(32) +                        (if t-bc-base  then 'bc-base':U  else '':U) + chr(32) +                         (if t-bc-alt then 'bc-alt':U  else '':U) + chr(32) +                            (if t-loc-alt  then 'loc-alt':U  else '':U) + chr(32) +                         (if t-pb-base then 'pb-base':U  else '':U) + chr(32) +                          (if t-pb-alt then 'pb-alt':U  else '':U) + chr(32) +                            (if t-sc-base then 'sc-base'  else '':U) + chr(32) +                            (if t-all-prt then 'all-prt'  else '':U) + chr(32) +                            (if t-parts-ser then 'parts-ser':U  else '':U) + chr(32) +                      (if t-parts-not-blank then 'parts-not-blank'  else '':U) + chr(32) +            (if t-parts-all then 'parts-all'  else '':U)
              v-tbl-name = '':U
              v-bh       = ?
              v-tot-lns = tot-lns
              .
              run create-scnblist-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                                  , input-output v-temp-seq
                                                  , input v-line
                                                  , input '':U
                                                  , input dsp-rs-option
                                                  , input v-tot-lns
                                                  , input rs-list-method
                                                  , input rs-status
                                                  , input v-item_
                                                  , input v-tbl-name
                                                  , input v-bh
                                                  ).
              num-rec = 1.
              v-seq  = v-temp-seq.
              v-temp-seq = v-temp-seq - 1.
            end.
            if num-rec <> 0 then do:
              assign
              v-line     = num-rec
              dsp-rs = substitute("гл. код &1 &2 &3&4 &5", goods.gds-code, goods.artic, goods.prod-type, goods.prod-code, goods.gds-name)
              v-item_     = '':U
              v-tbl-name = 'goods':U
              v-bh       = buffer goods:handle
              v-tot-lns = tot-lns + num-rec
              .
              run create-scnblist-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                                  , input-output v-temp-seq
                                                  , input v-line
                                                  , input '':U
                                                  , input dsp-rs-option + chr(32) + dsp-rs
                                                  , input v-tot-lns
                                                  , input rs-list-method
                                                  , input rs-status
                                                  , input v-item_
                                                  , input v-tbl-name
                                                  , input v-bh
                                                  ).
            end.
            v-no-hist = (if num-rec = 1 then 0 else num-rec).
            num-rec =  num-rec + 1.
            delete gds-list.
            end.
        end.
        when "file-gds" then do:
          glog = yes.
          message "Коды выбранных типов для товаров из ранее сохраненного в файле списка"
          skip stat-line(rs-status)
          view-as alert-box question buttons OK-Cancel update glog.
          if not glog then do:
            run UI-on.
            return error.
          end.
          system-dialog get-file f-name
          filters "Списки товаров *.gds" "*.gds"
          title "Выберите файл списка"
          INITIAL-DIR "."
          return-to-start-dir
          must-exist
          update glog
          default-extension "gds".
          if not glog then do:
            run UI-on.
            return error.
          end.
          run create-scnblist-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                              , input-output v-seq
                                              , input 0
                                              , input '':U
                                              , input substitute("Файл списка : &1 &2", f-name, stat-line(rs-status)) + chr(32) +
                                                      (if t-loc-base then 'основн.'  else '':U) + chr(32) +                           (if t-bc-base  then 'основн.EAN'  else '':U) + chr(32) +                        (if t-bc-alt then 'неосновн.EAN'  else '':U) + chr(32) +                           (if t-loc-alt  then 'неосновн.'  else '':U) + chr(32) +                      (if t-pb-base then 'ДопБК основн.'  else '':U) + chr(32) +                      (if t-pb-alt then 'ДопБК неосновн.'  else '':U) + chr(32) +                     (if t-sc-base then 'весов. и топл.'  else '':U) + chr(32) +                     (if t-all-prt then 'все признаки'  else '':U) + chr(32) +                       (if t-parts-ser then 'на сер. товар'  else '':U) + chr(32) +                    (if t-parts-not-blank then 'на непуст. № парт.'  else '':U) + chr(32) +         (if t-parts-all then 'все партии'  else '':U)
                                              , input tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input f-name + chr(4) + (if t-loc-base then 'loc-base':U  else '':U) + chr(32) +                        (if t-bc-base  then 'bc-base':U  else '':U) + chr(32) +                         (if t-bc-alt then 'bc-alt':U  else '':U) + chr(32) +                            (if t-loc-alt  then 'loc-alt':U  else '':U) + chr(32) +                         (if t-pb-base then 'pb-base':U  else '':U) + chr(32) +                          (if t-pb-alt then 'pb-alt':U  else '':U) + chr(32) +                            (if t-sc-base then 'sc-base'  else '':U) + chr(32) +                            (if t-all-prt then 'all-prt'  else '':U) + chr(32) +                            (if t-parts-ser then 'parts-ser':U  else '':U) + chr(32) +                      (if t-parts-not-blank then 'parts-not-blank'  else '':U) + chr(32) +            (if t-parts-all then 'parts-all'  else '':U)
                                              , input '':U
                                              , input ?
                                              ).
        end.
        when "last-check":U then do:
          glog = yes.
          message "Коды продажи для бар-кода в чеках, пробитых не позже выбранной даты"
          skip stat-line(rs-status)
          view-as alert-box question buttons OK-Cancel update glog.
          if not glog then do:
            run UI-on.
            return error.
          end.
define variable vss-include-info70 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-one in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-user-select
  ,output v-sel-obj-type
  ,output v-sel-obj-code
  )  .
                          if not v-user-select then do:     run UI-on.     return no-apply.   end.
          run gbl/d-prompt.w
            ( 'title=Введите дату\'
            + 'format=99/99/9999\'
            + 'type=date\'
            ,input-output v-chk-date-chr
            ).
          if return-value = 'false':u then do:
            run UI-on.
            return error.
          end.
          run create-scnblist-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                              , input-output v-seq
                                              , input 0
                                              , input '':U
                                              , input substitute("ВСЕ коды продажи для бар-кода в чеках &1&2, пробитых не позже &3 "
                                                                 , v-sel-obj-type
                                                                 , v-sel-obj-code
                                                                 , v-chk-date-chr)
                                              , input tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input v-sel-obj-type + chr(3) + string(v-sel-obj-code) + chr(3) + v-chk-date-chr
                                              , input '':U
                                              , input ?
                                              ).
        end.
        when "cd-codes":U then do:
          glog = yes.
          message "Коды продажи, привязанные к кассам"
          skip stat-line(rs-status)
          view-as alert-box question buttons OK-Cancel update glog.
          if not glog then do:
            run UI-on.
            return error.
          end.
          run ref/cashlist.w (
                          input parparentproc
                         ,input "b-sel"
                         ,input "db":U
                         ,input g#db-num
                         ,input 0
                         ,input p-curr-obj-type
                         ,input p-curr-obj-code
                         ,input ?
                         ,output ref-list) no-error .
          if error-status:error or ref-list = "":u then do:
            run UI-on.
            return error.
          end.
          find first buf_cash-desk no-lock where
                    recid(buf_cash-desk) = integer(ref-list) no-error .
          if not available buf_cash-desk then do:
            run UI-on.
            return error.
          end.
          if buf_cash-desk.pos-type <> 'r-keeper':U then do:
            message
            substitute("Коды продажи на кассе определены только для кассы типа &1"
                      , 'r-keeper':U)
            view-as alert-box error .
            run UI-on.
            return error.
          end.
          assign
          v-cash-num = buf_Cash-desk.cash-num
          v-pos-type = buf_Cash-desk.pos-type
          v-cash-desk-obj-code = buf_Cash-desk.obj-code
          .
          run create-scnblist-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                              , input-output v-seq
                                              , input 0
                                              , input '':U
                                              , input substitute("Коды продажи для кассы &1 &2 &3&4"
                                                     , v-pos-type, v-cash-num, 'маг':U, v-cash-desk-obj-code)
                                              , input tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input ('маг':U + chr(3) + string(v-cash-desk-obj-code) + chr(3) +
                                                      v-pos-type + chr(3) + string(v-cash-num))
                                              , input '':U
                                              , input ?
                                              ).
        end.
        when "parts-cashparts":U
        or
        when "parts-ean-cashparts"
        then do:
          run proc-parts-cashparts ( input rs-list-method) no-error.
          if error-status:error then do:
            run Ui-on in this-procedure.
            return no-apply.
          end.
        end.
        when "parts-last-date":U
        or
        when "parts-rsrv-last-date"
        or
        when "parts-ean-last-date":U
        or
        when "parts-ean-rsrv-last-date"
        then do:
          run proc-parts-last-date(rs-list-method) no-error.
          if error-status:error then do:
            run Ui-on in this-procedure.
            return no-apply.
          end.
        end.
        when "parts-fib":U
        or
        when "parts-rsrv-fib"
        or
        when "parts-ean-fib":U
        or
        when "parts-ean-rsrv-fib"
        then do:
          run proc-parts-fib(rs-list-method) no-error.
          if error-status:error then do:
            run Ui-on in this-procedure.
            return no-apply.
          end.
        end.
        when "parts-end-date-obj":U
        or
        when "parts-ean-end-date-obj"
        then do:
          run proc-parts-end(rs-list-method) no-error.
          if error-status:error then do:
            run Ui-on in this-procedure.
            return no-apply.
          end.
        end.
        when "loc-sc-codes"
        or
        when "loc-pg-codes"
        or
        when "gbl-sc-codes"
        then do:
          glog = yes.
          if rs-list-method = "loc-sc-codes" then do:
             if g#db-num = 0 then do:
               dsp-rs-option = substitute("Локальные весовые коды на выбранной БД: &1", stat-line(rs-status)).
             end.
          end.
          if rs-list-method = "gbl-sc-codes" then do:
             if g#db-num = 0 then do:
               dsp-rs-option = substitute("Глобальные весовые коды на выбранной БД: &1", stat-line(rs-status)).
             end.
          end.
          if rs-list-method = "loc-pg-codes" then do:
             if g#db-num = 0 then do:
               dsp-rs-option = substitute("Штучные коды для весов коды на выбранной БД: &1", stat-line(rs-status)).
             end.
          end.
          message dsp-rs-option
          view-as alert-box question buttons OK-Cancel update glog.
          if not glog then do:
            run UI-on.
            return error.
          end.
          if g#db-num = 0 then do:
            run adm/dbs.w ( INPUT parparentproc
                            ,INPUT 'ПРОСМОТР':U
                            ,OUTPUT v-rid) NO-ERROR.
            if error-status:error or v-rid = ? then do:
              run UI-on.
              return error.
            end.
          end.
          else do:
             find first buf_db no-lock where buf_db.db-num = g#db-num.
             v-rid = recid(buf_db).
          end.
          define variable choice as integer no-undo .
          run gbl/d-askw.w (input "Вопрос",
                                input  ("На каждом объекте весовые товары взвешиваются" + chr(10)
                                        + "с ипользованием определенного кода" + chr(10)
                                        + "(Атрибут товара на объекте ВЕСОВОЙ КОД)" + chr(10)
                                        + "Определите какие коды включать в выборку"
                                        ),
                                input "|",
                                input "Все|Используемые|НЕиспользуемые|Отменить",
                                input "Все|Взвешиваются c этим кодом|НЕ взвешиваются c этим кодом|Отменить",
                                input 1,
                                input 4,
                                output choice).
          if choice = 4
          then do:
            run UI-on.
            return error.
          end.
          v-recs = num-entries (string(v-rid)).
          do num-rec = 0 to v-recs:
            if num-rec > 0
            then do:
              v-ref-rec = integer (entry (num-rec, string(v-rid))).
              find buf_db where recid (buf_db) = integer(entry(num-rec, string(v-rid))) no-lock.
            end.
            if num-rec = 0 then do:
              case choice:
                when 1 then do:
                  assign
                  dsp-rs = dsp-rs-option
                  .
                end.
                when 2 then do:
                  assign
                  dsp-rs = substitute("&1 используемые для взвешивания", dsp-rs-option)
                  .
                end.
                when 3 then do:
                  assign
                  v-item_    = substitute("&1 НЕиспользуемые для взвешивания", dsp-rs-option)
                  .
                end.
              end case.
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = dsp-rs-option
              v-item_     = ""
              v-tbl-name = '':U
              v-bh       = ?
              v-tot-lns = tot-lns
              .
            end.
            else do:
              case choice:
                when 1 then do:
                  assign
                  v-item_    = string(buf_db.db-num) + chr(3) + "all"
                  .
                end.
                when 2 then do:
                  assign
                  v-item_    = string(buf_db.db-num) + chr(3) + "using"
                  .
                end.
                when 3 then do:
                  assign
                  v-item_    = string(buf_db.db-num) + chr(3) + "nonusing"
                  .
                end.
              end case.
              assign
              v-temp-seq = v-seq - 1
              v-line     = num-rec
              dsp-rs =  substitute("     БД &1", buf_db.db-num)
              v-tbl-name =  ''
              v-bh       = ?
              v-tot-lns = tot-lns + num-rec
              .
            end.
            v-no-hist = num-rec.
            run create-scnblist-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                                , input-output v-temp-seq
                                                , input v-line
                                                , input '':U
                                                , input dsp-rs
                                                , input v-tot-lns
                                                , input rs-list-method
                                                , input rs-status
                                                , input v-item_
                                                , input v-tbl-name
                                                , input v-bh
                                                ).
            if num-rec = 0 then v-seq  = v-temp-seq.
          end.
        end.
        when "prod-bc-off":U then do:
          glog = yes.
          message "Все выключенные ДопБк"
          skip stat-line(rs-status)
          view-as alert-box question buttons OK-Cancel update glog.
          if not glog then do:
            run UI-on.
            return error.
          end.
          run create-scnblist-hist in this-procedure (
                                                input 'ДОБАВЛЕНИЕ':U
                                              , input-output v-seq
                                              , input 0
                                              , input '':U
                                              , input substitute("Все выключенные ДопБК")
                                              , input tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input 'prod-bc-off':U
                                              , input '':U
                                              , input ?
                                              ).
        end.
        when "scaner" then do:
          glog = yes.
          message "Все коды из файла, полученного с мобильного сканера."
          skip stat-line(rs-status)
          view-as alert-box question buttons OK-Cancel update glog.
          if not glog then do:
            run UI-on.
            return error.
          end.
          system-dialog get-file f-gds-name
          title "Выберите файл со сканера"
          filters "WorkAbout MS15  *.dbs" "*.dbs",
                  "WorkAbout  *.imp" "*.imp",
                  "Инвентаризация касса  *.inv" "*.inv",
                  "Все файлы  *.*" "*.*"
            INITIAL-DIR "."
            return-to-start-dir
            must-exist
            update glog
            default-extension "dbs".
          if not glog then do:
            run UI-on.
            return error.
          end.
          run create-scnblist-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                                , input-output v-seq
                                                , input 0
                                                , input '':U
                                                , input substitute("Файл сканера : &1 &2", f-name, stat-line(rs-status))
                                                , input tot-lns
                                                , input rs-list-method
                                                , input rs-status
                                                , input f-gds-name
                                                , input '':U
                                                , input ?
                                                ).
        end.
      when "filter" then do:
        glog = yes.
        message "Все баркоды, выбранные в соответствии с заданным фильтром (без учета сортировки)."
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run UI-on in this-procedure.
          return error.
        end.
        assign
        tbl = 'bar-code'
        join-tbl = ','
        fld = ""
        lab = ""
        spr = ""
        dim = '0'
        c-point = "bb-list" + chr(4) + "Список кодов" + chr(4) + "no"
        .
        define variable v-flt-rec as recid no-undo .
        define variable v-filter-name as character no-undo .
        define variable where-phrase as character no-undo .
        define variable sort-phrase as character no-undo .
        define variable where-phrase-rus as character no-undo .
        define variable sort-phrase-rus as character no-undo .
        run fltfield-add in this-procedure('part-code', '№ партии', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('in-code', '№ ПН', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('cli-base-rate', 'Коэфф', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('unit-cli', 'Ед.изм.', 'unit',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run gbl/filter.w ( input parparentproc
                          ,input c-point
                          ,input tbl
                          ,input join-tbl
                          ,input fld
                          ,input lab
                          ,input spr
                          ,input dim).
        run gbl/flt-get.p (
                         input  c-point
                        ,output v-flt-rec
                        ,output v-filter-name
                        ,output where-phrase
                        ,output sort-phrase
                        ,output where-phrase-rus
                        ,output sort-phrase-rus  ).
        if v-flt-rec = ? then do:
          run UI-on in this-procedure.
          return error.
        end.
        else do:
          find ubflt.filter where recid (ubflt.filter) = v-flt-rec no-lock.
          run create-scnblist-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                              , input-output v-seq
                                              , input 0
                                              , input '':U
                                              , input substitute("Фильтр : &1 &2 &3", ubflt.filter.naim, ubflt.filter.where-ysl-rus, stat-line(rs-status))
                                              , input tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input ubflt.filter.where-ysl
                                              , input '':U
                                              , input ?
                                              ).
        end.
      end.
      otherwise do:
        message "Неизвестный" rs-list-method view-as alert-box .
      end.
     end CASE.
    if tot-lns <> 0 then do:
      run get-operation in this-procedure (input dsp-rs, output v-operation) no-error .
      CASE v-operation:
        when 1 then do:
          run proc-b-add in this-procedure(no, ?, rs-list-method, rs-status) no-error  .
        end.
        when 2 then do:
          run proc-b-del in this-procedure(no, ?, rs-list-method, rs-status ) no-error  .
        end.
        when 3 then do:
          run proc-b-rest in this-procedure(no, ?, rs-list-method, rs-status) no-error  .
        end.
        otherwise do:
          assign
          dsp-rs = "":U.
          run UI-on.
          return error.
        end.
      END CASE.
      if error-status:error then do:
        run UI-on.
        return error return-value .
      end.
    end.
    assign
    rs-list-method = temp-list.fvalue
    .
    find last buf_scnblist-hist no-lock where
              buf_scnblist-hist.id = (v-seq - 1)
        and  buf_scnblist-hist.line = 0 no-error .
    DISPLAY
    (if available buf_scnblist-hist
    then buf_scnblist-hist.des
    else '') @ dsp-rs
    with frame Dialog-Frame.
    if tot-lns = 0
    then do:
      run proc-b-add in this-procedure(no, ?, rs-list-method, rs-status)  .
    end.
  end.
end.
end procedure.
procedure proc-scn-tsd :
  do
  on error undo, return error
  :
  assign
    f-name = "default.inv"
    glog = yes
    .
  system-dialog get-file f-name
    filters "Инвентаризация касса *.inv" "*.inv"
    ask-overwrite
    save-as
    use-filename
    update glog
    default-extension "inv".
  if not glog then do:
    apply "entry" to br-list in frame Dialog-Frame.
    return no-apply.
  end.
  run waitfram-show in this-procedure ("Сохранение в формате мобильного сканера.    ЖДИТЕ...").
  output to value (f-name).
  for each scnblist:
    if scnblist.in-code = ""
    and ub.bar-code.part-code = "" then do:
      if scnblist.qnty <> 0 then
      put unformatted string (ub.bar-code.b-code) + "," + string (scnblist.qnty) skip.
    end.
  end.
  output close.
  run waitfram-hide in this-procedure .
  end.
end procedure.
procedure proc-b-add :
define input parameter p-from-macro as logical no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
  do
  on error undo, return error
  :
  line-mode = 'ДОБАВЛЕНИЕ':U.
  if rs-list-method = "single" then do:
     v-no-hist = - 1.
    if p-from-macro then do:
    end.
    else do:
      assign
      frame Dialog-Frame
      T-all-prt
      T-bc-alt
      T-bc-base
      T-loc-alt
      T-loc-base
      T-parts-all
      T-parts-not-blank
      T-parts-ser
      T-pb-alt
      T-pb-base
      T-sc-base
      .
      if (
      T-all-prt or
      T-bc-alt  or
      T-bc-base or
      T-loc-alt or
      T-loc-base  or
      T-parts-all  or
      T-parts-not-blank or
      T-parts-ser or
      T-pb-alt    or
      T-pb-base   or
      T-sc-base) = no then do:
        message
        "Не выбран ни один тип кодов!"
        view-as alert-box error .
        undo, return error .
      end.
      assign
      temp-shop.obj-code = p-curr-obj-code
      temp-shop.all-prt = T-all-prt
      temp-shop.cd-bc-alt = T-bc-alt
      temp-shop.cd-bc-base = T-bc-base
      temp-shop.cd-loc-alt = T-loc-alt
      temp-shop.cd-loc-base = T-loc-base
      temp-shop.cd-parts-all = T-parts-all
      temp-shop.cd-parts-not-blank = T-parts-not-blank
      temp-shop.cd-parts-ser = T-parts-ser
      temp-shop.cd-pb-alt = T-pb-alt
      temp-shop.cd-pb-base = T-pb-base
      temp-shop.cd-sc-base = T-sc-base
      .
    end.
    if p-from-macro then do:
      find ub.goods where rowid(ub.goods) = p-rowid no-lock no-error .
    end.
    else do:
      run ref/gds-ref.p ( input parparentproc
                      ,input "b-sel,b-add"
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input p-curr-obj-type
                      ,input p-curr-obj-code
                      ,input ?
                      ,output ref-list).
      apply "entry" to br-list in frame Dialog-Frame.
      if ref-list = "" then
        return no-apply.
      find goods where recid (goods) = integer (ref-list) no-lock no-error.
    end.
    if available goods then do:
      run process-one-good in this-procedure (input rs-list-method, input rs-status, input line-mode ,buffer goods) no-error .
      tot-lns = tot-lns + lns-cnt.
      run write-hist(p-from-macro, rs-list-method, rs-status, line-mode, buffer goods).
    end.
    else do:
      return error "Нет в БД такого товара".
    end.
    run UI-on.
  end.
  else
    run rs-do(no, no, rs-list-method, rs-status, line-mode, v-seq - 1).
  end.
end procedure.
procedure proc-b-del :
define input parameter p-from-macro as logical no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
define variable v-rep-rec as recid no-undo .
define buffer buf_prod-bc for ub.prod-bc.
define buffer buf_bar-code for ub.bar-code.
  do
  on error undo, return error
  :
    line-mode = 'удаление':U.
    if rs-list-method begins "single" then do:
     v-no-hist = - 1.
      if p-from-macro then do:
        CASE entry(2, rs-list-method, chr(4) ):
          when 'prod-bc':U then do:
            find first buf_prod-bc where rowid(buf_prod-bc) = p-rowid no-error.
            if not available buf_prod-bc then return error "Нет в БД такого ДопБК".
            find first scnblist where
                       scnblist.b-code = buf_prod-bc.b-code
                   AND scnblist.b-str = buf_prod-bc.b-str no-error.
          end.
          when 'bar-code':U
          or
          when 'loc-ean':U then do:
            find first buf_bar-code where rowid(buf_bar-code) = p-rowid no-error.
            if not available buf_bar-code then return error "Нет в БД такого кода".
            find first scnblist where
                       scnblist.b-code = buf_bar-code.b-code
                   AND scnblist.loc-ean = (if entry(2, rs-list-method, chr(4)) = 'bar-code':U then no else yes) no-error.
          end.
        END CASE.
      end.
      if available scnblist then do:
        line-rec = recid (scnblist).
        get next br-list.
        if available scnblist then v-rep-rec = recid (scnblist).
        else do:
          reposition br-list to recid line-rec no-error.
          get prev br-list.
          if available scnblist then v-rep-rec = recid (scnblist).
        end.
        reposition br-list to recid line-rec no-error.
        tot-lns = tot-lns - 1.
        run write-hist(p-from-macro, rs-list-method, rs-status, line-mode, buffer ub.goods).
        delete scnblist.
        line-rec = v-rep-rec.
        run UI-on.
      end.
      else do:
        return error "Нет в списке кодов такого кода".
      end.
    end.
    else do:
      glog = no.
      message "Удалить коды ПО заданному УСЛОВИЮ ?   Вы уверены ?"
              view-as alert-box question buttons OK-Cancel update glog.
      if not glog then  return error.
      run rs-do(no, no, rs-list-method, rs-status, line-mode, v-seq - 1).
    end.
  end.
end procedure.
procedure proc-b-rest :
define input parameter p-from-macro as logical no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
define buffer buf_scnblist-hist for scnblist-hist.
define buffer buf_prod-bc for ub.prod-bc.
define buffer buf_bar-code for ub.bar-code.
  do
  on error undo, return error
  :
    line-mode = 'ОСТАВИТЬ':U.
    if rs-list-method begins "single" then do:
      v-no-hist = - 1.
      if p-from-macro then do:
        CASE entry(2, rs-list-method, chr(4) ):
          when 'prod-bc':U then do:
            find first buf_prod-bc where rowid(buf_prod-bc) = p-rowid no-error.
            if not available buf_prod-bc then return error "Нет в БД такого ДопБК".
            find first scnblist where
                       scnblist.b-code = buf_prod-bc.b-code
                   AND scnblist.b-str = buf_prod-bc.b-str no-error.
          end.
          when 'bar-code':U
          or
          when 'loc-ean':U  then do:
            find first buf_bar-code where rowid(buf_bar-code) = p-rowid no-error.
            if not available buf_bar-code then return error "Нет в БД такого кода".
            find first scnblist where
                       scnblist.b-code = buf_bar-code.b-code
                   AND scnblist.loc-ean = (if entry(2, rs-list-method, chr(4)) = 'bar-code':U then no else yes) no-error.
          end.
        END CASE.
      end.
      if available scnblist then do:
      if p-from-macro then do:
          glog = yes.
        end.
        else do:
          glog = no.
          message "Оставить отмеченную строку и УДАЛИТЬ ВСЕ ОСТАЛЬНЫЕ ?   Вы уверены ?"
                  view-as alert-box question buttons OK-Cancel update glog.
          if not glog then return error.
        end.
        line-rec = recid (scnblist).
        v-seq = 1.
        for each buf_scnblist-hist:
          delete buf_scnblist-hist.
        end.
        run write-hist(p-from-macro, rs-list-method, rs-status, line-mode, buffer ub.goods).
        for each scnblist:
          if line-rec <> recid (scnblist) then delete scnblist.
        end.
        tot-lns = 1.
        run UI-on.
      end.
    end.
    else do:
      glog = no.
      if not p-from-macro then do:
      message "Оставить коды ПО заданному УСЛОВИЮ и УДАЛИТЬ ВСЕ ОСТАЛЬНЫЕ ?   Вы уверены ?"
              view-as alert-box question buttons OK-Cancel update glog.
        if not glog then
        return no-apply.
      end.
      assign
      lns-cnt = 0
      lns-ignore = 0
      .
      run rs-do(no, no, rs-list-method, rs-status, line-mode, v-seq - 1).
      for each scnblist:
        if scnblist.to-del = ? then do:
          assign
          scnblist.to-del = no
          .
        end.
        else do:
          delete scnblist.
        end.
      end.
      tot-lns = lns-cnt.
      run UI-on.
      message
      "Оставлено строк :" lns-cnt skip(0)
      string(if lns-ignore <> 0
      then ("Проигнорировано строк :" + string(lns-ignore))
      else "":U)
      .
    end.
  end.
end procedure.
procedure process-one-good :
define input  parameter rs-list-method as character no-undo .
define input  parameter rs-status as character no-undo .
define input  parameter line-mode as character no-undo .
define parameter buffer goods for ub.goods.
  do
  on error undo, return error
  :
      assign                 new-good = yes                 petrol-trk = no                 cashparts = no                 main-b-code = 0                 .
      run get-prt-and-unit in this-procedure (
                                               input ub.goods.prt-root
                                              ,input ub.goods.unit-base
                                              ,output l-empty-scale
                                              ) .
      FIND FIRST ub.gds-obj WHERE
                ub.gds-obj.obj-type = p-curr-obj-type AND
                ub.gds-obj.obj-code = p-curr-obj-code AND
                ub.gds-obj.artic = ub.goods.artic AND
                ub.gds-obj.prod-type = ub.goods.prod-type AND
                ub.gds-obj.prod-code = ub.goods.prod-code nO-LOCK NO-ERROR.
      if v-is-restaurant then do:
        find first buf_fbr-gds-obj no-lock where
                  buf_fbr-gds-obj.obj-type = p-curr-obj-type
              AND buf_fbr-gds-obj.obj-code = p-curr-obj-code
              AND buf_fbr-gds-obj.gds-code = ub.goods.gds-code no-error .
        if    available buf_fbr-gds-obj
          and not buf_fbr-gds-obj.is-cd
        then
           NEXT.
      end.
      run get-gds-obj-fields in this-procedure(
                                                 buffer ub.gds-obj
                                                ,input no
                                                ,input ub.goods.gds-code
                                                ,input p-curr-obj-code
                                                ,input p-curr-obj-type
                                                ,output for-fact-qnty
                                                ,output cashparts
                                                ,output v-is-null-price
                                                ) no-error .
    RUN term-prt in this-procedure (
                  input rs-list-method
                , input rs-status
                , input line-mode
                , input ub.gds-prt.prt-root
                , input ?) no-error.
  end.
end procedure.
procedure get-gds-obj-fields :
define parameter buffer buf_gds-obj for ub.gds-obj .
define input parameter par-find-buffer as logical no-undo .
define input parameter par-gds-code like ub.goods.gds-code no-undo .
define input parameter par-obj-code like ub.clients.obj-code no-undo .
define input parameter par-obj-type like ub.clients.obj-type no-undo .
define output parameter par-fact-qnty like ub.gds-obj.fact-qnty no-undo .
define output parameter par-cash-parts as logical no-undo .
define output parameter p-is-null-price like ub.fbr-gds-obj.is-null-price  no-undo .
  do
  on error undo, return error
  :
    if par-find-buffer then do:
      find first buf_gds-obj no-lock where
                buf_gds-obj.gds-code = par-gds-code AND
                buf_gds-obj.obj-type = par-obj-type AND
                buf_gds-obj.obj-code = par-obj-code no-error .
    end.
    if not avail buf_gds-obj
    and (p-curr-obj-type = 'маг':U and ub.shop.is-catering = no)
    then do:
      return.
    end.
    assign
    par-fact-qnty = (if available buf_gds-obj
                     then buf_gds-obj.fact-qnty
                     else 0)
    .
    assign
    par-cash-parts = (if available buf_gds-obj
                      then buf_gds-obj.cash-parts
                      else no)
    .
    if available buf_fbr-gds-obj then do:
      assign
      p-is-null-price     =  buf_fbr-gds-obj.is-null-price
      .
    end.
  end.
end procedure.
procedure get-prt-and-unit :
define input parameter par-prt-root like ub.goods.prt-root no-undo .
define input parameter par-unit-base like ub.goods.unit-base no-undo .
define output parameter par-empty-scale as logical no-undo .
  do
  on error undo, return error
  :
    FIND FIRST ub.gds-prt where
               ub.gds-prt.upper-code = par-prt-root NO-LOCK .
    assign
    par-empty-scale =  NOT (v-doc-prt AND ( ub.gds-prt.node-name <> '_Пустая шкала':U))
    .
    FIND FIRST ub.units WHERE
               ub.units.unit-name = par-unit-base NO-LOCK .
  end.
end procedure.
procedure proc-b-cd :
define input parameter p-fill-temp-shop as logical no-undo .
  do
  on error undo, return error
  :
  if available ub.shop then do:
    assign
    temp-shop.obj-code =    ub.shop.obj-code
    t-all-prt         =    ub.shop.all-prt
    t-bc-alt          =    ub.shop.cd-bc-alt
    t-bc-base         =    ub.shop.cd-bc-base
    t-loc-alt         =    ub.shop.cd-loc-alt
    t-loc-base        =    ub.shop.cd-loc-base
    t-parts-all       =    ub.shop.cd-parts-all
    t-parts-not-blank =    ub.shop.cd-parts-not-blank
    t-parts-ser       =    ub.shop.cd-parts-ser
    t-pb-alt          =    ub.shop.cd-pb-alt
    t-pb-base         =    ub.shop.cd-pb-base
    t-sc-base         =    ub.shop.cd-sc-base
    .
    if (t-all-prt or
    t-bc-alt     or
    t-bc-base    or
    t-loc-alt    or
    t-loc-base   or
    t-parts-all  or
    t-parts-not-blank or
    t-parts-ser       or
    t-pb-alt          or
    t-pb-base         or
    t-sc-base ) = no then do:
      message
      substitute("Для магазина &1 не выбран ни один тип кодов, выбираем основные локальные&2"  +
                 "Иначе список формировать бесполезно"
                 , shop.obj-code
                 , chr(10))
      view-as alert-box warning.
      t-loc-base = yes.
    end.
    if p-fill-temp-shop then do:
      assign
      temp-shop.obj-code = p-curr-obj-code
      temp-shop.all-prt = T-all-prt
      temp-shop.cd-bc-alt = T-bc-alt
      temp-shop.cd-bc-base = T-bc-base
      temp-shop.cd-loc-alt = T-loc-alt
      temp-shop.cd-loc-base = T-loc-base
      temp-shop.cd-parts-all = T-parts-all
      temp-shop.cd-parts-not-blank = T-parts-not-blank
      temp-shop.cd-parts-ser = T-parts-ser
      temp-shop.cd-pb-alt = T-pb-alt
      temp-shop.cd-pb-base = T-pb-base
      temp-shop.cd-sc-base = T-sc-base
      .
    end.
  end.
  else do:
    assign
    temp-shop.obj-code =  ub.store.obj-code
    t-loc-base         =   yes
    t-all-prt          = no
    t-bc-alt           = no
    t-bc-base          = no
    t-loc-alt          = no
    t-parts-all        = no
    t-parts-not-blank  = no
    t-parts-ser        = no
    t-pb-alt           = no
    t-pb-base          = no
    t-sc-base          = no
    .
    if p-fill-temp-shop then do:
      assign
      temp-shop.obj-code = p-curr-obj-code
      temp-shop.all-prt = T-all-prt
      temp-shop.cd-bc-alt = T-bc-alt
      temp-shop.cd-bc-base = T-bc-base
      temp-shop.cd-loc-alt = T-loc-alt
      temp-shop.cd-loc-base = T-loc-base
      temp-shop.cd-parts-all = T-parts-all
      temp-shop.cd-parts-not-blank = T-parts-not-blank
      temp-shop.cd-parts-ser = T-parts-ser
      temp-shop.cd-pb-alt = T-pb-alt
      temp-shop.cd-pb-base = T-pb-base
      temp-shop.cd-sc-base = T-sc-base
      .
    end.
  end.
    display
    T-loc-base
    T-pb-base
    T-loc-alt
    T-pb-alt
    T-bc-base
    T-sc-base
    T-bc-alt
    T-all-prt
    T-parts-ser
    T-parts-not-blank
    T-parts-all
    with frame Dialog-Frame.
  run proc-cd2 in this-procedure .
  end.
end procedure.
procedure proc-cd2 :
define variable v-fvalue as character no-undo .
  do
  on error undo, return error
  :
    if available temp-list then v-fvalue = temp-list.fvalue.
    CASE v-fvalue:
      when "all"
      or
      when "goods"
      or
      when "gds-list"
      or
      when "file-gds" then do:
        ENABLE
        T-loc-base
        T-loc-alt
        T-bc-base
        T-bc-alt
        T-all-prt
        T-parts-ser
        T-parts-not-blank
        T-parts-all
        T-pb-base
        T-pb-alt
        T-sc-base
        WITH FRAME Dialog-Frame.
      end.
      otherwise do:
        disable
        T-loc-base
        T-loc-alt
        T-bc-base
        T-bc-alt
        T-all-prt
        T-parts-ser
        T-parts-not-blank
        T-parts-all
        T-pb-base
        T-pb-alt
        T-sc-base
        WITH FRAME Dialog-Frame.
      end.
    END CASE.
  end.
end procedure.
procedure proc-b-optimize :
define input  parameter p-from-macro as logical   no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
define input parameter p-option as character no-undo .
define variable v-cnt as integer   no-undo .
define variable v-temp-seq as integer   no-undo .
define variable l-prod-bc-petrolium as logical no-undo .
define variable l-prod-bc-weight as logical no-undo .
define buffer b-str_bb-list for scnblist.
define buffer b-code_bb-list for scnblist.
define buffer buf_prod-bc for ub.prod-bc.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_goods for ub.goods.
define buffer buf_scnblist-hist for scnblist-hist.
  do
  on error undo, return error
  :
    case p-option:
      when "delnprod-bc" then  do:
        for each b-str_bb-list no-lock :
          if b-str_bb-list.b-str <> "":U
          and b-str_bb-list.loc-ean  = no
          then do:
            for each b-code_bb-list where
                       b-code_bb-list.b-code = b-str_bb-list.b-code
                  AND  (b-code_bb-list.b-str = "":U
                        or
                        b-code_bb-list.loc-ean = yes)
                  :
              delete b-code_bb-list.
              v-cnt = v-cnt + 1.
            end.
          end.
        end.
      end.
      when "repnprod-bc" then  do:
        for each b-code_bb-list :
          if b-code_bb-list.b-str =  '':U
          or b-code_bb-list.loc-ean = yes then do:
            find first buf_prod-bc no-lock where
                      buf_prod-bc.b-code = b-code_bb-list.b-code
                  AND buf_prod-bc.bc-on = yes no-error.
            if available buf_prod-bc then do:
              find first b-str_bb-list no-lock where
                         b-str_bb-list.b-code = buf_prod-bc.b-code
                    AND  b-str_bb-list.b-str = buf_prod-bc.b-str no-error .
              if available b-str_bb-list then next.
              assign
              l-prod-bc-petrolium = no
              l-prod-bc-weight = no
              .
define variable vss-include-info71 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer buf_prod-bc
  ,input  'weight=request':u
  ,output l-prod-bc-weight
  ) no-error .
              if error-status:error
              or l-prod-bc-weight then next.
define variable vss-include-info72 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer buf_prod-bc
  ,input  'petrolium=request':u
  ,output l-prod-bc-petrolium
  ) no-error .
              if error-status:error
              or l-prod-bc-petrolium then next.
              find first buf_bar-code no-lock where
                          buf_bar-code.b-code = buf_prod-bc.b-code no-error.
              if available buf_bar-code then do:
                find first ub.goods no-lock where
                          ub.goods.gds-code = buf_bar-code.gds-code no-error.
                if available goods then do:
                  run get-prt-and-unit in this-procedure (
                                                          input ub.goods.prt-root
                                                          ,input ub.goods.unit-base
                                                          ,output l-empty-scale
                                                          ) .
                  delete b-code_bb-list.
                  v-cnt = v-cnt + 1.
                  run ex-bbc in this-procedure (input rs-list-method, input rs-status, input line-mode , input no, input "":U, input no, buffer buf_bar-code, buffer buf_prod-bc).
                end.
              end.
            end.
          end.
        end.
      end.
    end case.
    lns-cnt = lns-cnt - v-cnt.
  end.
end procedure.
procedure proc-b-obj :
  define input parameter p-mode as character no-undo .
  define variable v-rid-list as character no-undo .
  define buffer buf_clients  for ub.clients.
  define buffer buf_user-obj for ub.user-obj.
  do
  on error undo, return error
  :
    find first buf_user-obj no-lock where
               buf_user-obj.user-id = v-cntxt-userid
           and buf_user-obj.db-num = v-cntxt-db-num
           and buf_user-obj.obj-type  = p-curr-obj-type
           and buf_user-obj.obj-code  = p-curr-obj-code no-error .
    assign
      v-rid-list = ( if available buf_user-obj then string( recid( buf_user-obj ) ) else "":U )
    .
    if p-mode = "change":U then do:
define variable vss-include-info73 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-one in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-user-select
  ,output v-sel-obj-type
  ,output v-sel-obj-code
  )  .
      if v-user-select then do:
        FIND FIRST buf_user-obj NO-LOCK WHERE
                  buf_user-obj.obj-type = buf_user-obj.obj-type
            and buf_user-obj.obj-code = buf_user-obj.obj-code
            and buf_user-obj.db-num = v-cntxt-db-num
            and buf_user-obj.user-id = v-cntxt-userid    NO-ERROR.
        if not available buf_user-obj then do: return no-apply. end.
        find first buf_clients no-lock where
                  buf_clients.obj-type = buf_user-obj.obj-type
              and buf_clients.obj-code = buf_user-obj.obj-code no-error.
        if not available buf_clients then do: return error. end.
        assign
          p-curr-obj-type = buf_clients.obj-type
          p-curr-obj-code = buf_clients.obj-code
          v-host-code = buf_clients.host-code
          v-obj-type = buf_clients.obj-type
          v-obj-code = buf_clients.obj-code
          v-obj-name = buf_clients.obj-name
        .
        display
        v-obj-name
        v-obj-type
        v-obj-code
        with frame Dialog-Frame.
      end.
    end.
  end.
end procedure.
procedure restore-codes :
define input  parameter p-codes as character no-undo .
define input  parameter p-obj-type like ub.clients.obj-type no-undo .
define input  parameter p-obj-code like ub.clients.obj-code no-undo .
  do
  on error undo, return error return-value
  :
    if p-obj-type = 'маг':U then do:
    assign
    temp-shop.obj-code =   p-obj-code
    t-all-prt         =    lookup('all-prt':U, p-codes, chr(32) ) > 0
    t-bc-alt          =    lookup('bc-alt':U, p-codes, chr(32) ) > 0
    t-bc-base         =    lookup('bc-base':U, p-codes, chr(32) ) > 0
    t-loc-alt         =    lookup('loc-alt':U, p-codes, chr(32) ) > 0
    t-loc-base        =    lookup('loc-base':U, p-codes, chr(32) ) > 0
    t-parts-all       =    lookup('parts-all':U, p-codes, chr(32) ) > 0
    t-parts-not-blank =    lookup('parts-not-blank':U, p-codes, chr(32) ) > 0
    t-parts-ser       =    lookup('parts-ser':U, p-codes, chr(32) ) > 0
    t-pb-alt          =    lookup('pb-alt':U, p-codes, chr(32) ) > 0
    t-pb-base         =    lookup('pb-base':U, p-codes, chr(32) ) > 0
    t-sc-base         =    lookup('sc-base':U, p-codes, chr(32) ) > 0
    temp-shop.all-prt         =    lookup('all-prt':U, p-codes, chr(32) ) > 0
    temp-shop.cd-bc-alt          =    lookup('bc-alt':U, p-codes, chr(32) ) > 0
    temp-shop.cd-bc-base         =    lookup('bc-base':U, p-codes, chr(32) ) > 0
    temp-shop.cd-loc-alt         =    lookup('loc-alt':U, p-codes, chr(32) ) > 0
    temp-shop.cd-loc-base        =    lookup('loc-base':U, p-codes, chr(32) ) > 0
    temp-shop.cd-parts-all       =    lookup('parts-all':U, p-codes, chr(32) ) > 0
    temp-shop.cd-parts-not-blank =    lookup('parts-not-blank':U, p-codes, chr(32) ) > 0
    temp-shop.cd-parts-ser       =    lookup('parts-ser':U, p-codes, chr(32) ) > 0
    temp-shop.cd-pb-alt          =    lookup('pb-alt':U, p-codes, chr(32) ) > 0
    temp-shop.cd-pb-base         =    lookup('pb-base':U, p-codes, chr(32) ) > 0
    temp-shop.cd-sc-base         =    lookup('sc-base':U, p-codes, chr(32) ) > 0
    .
    display
    T-loc-base
    T-pb-base
    T-loc-alt
    T-pb-alt
    T-bc-base
    T-sc-base
    T-bc-alt
    T-all-prt
    T-parts-ser
    T-parts-not-blank
    T-parts-all
    with frame Dialog-Frame.
  end.
  run proc-cd2 in this-procedure .
  end.
end procedure.
procedure proc-macros :
define variable glog as logical no-undo .
define variable v-option as integer no-undo .
define buffer buf_scnblist-hist for scnblist-hist.
define buffer buf_macro-list-hist for macro-list-hist.
if can-find(first macro-list-hist) then do:
  run gbl/d-askw.w ( input "Сохранение макроса"
                ,input "Выберите какие действия по формированию списка Вы хотите сохранить"
                ,input "|"
                ,input "Посл.ЗАПИСЬ|Все|Отказ"
                ,input "Действия при нажатой кнопке ЗАПИСЬ|ВСЯ последовательность действий|Отказ"
                ,input 1
                ,input 3
                ,output v-option).
  if v-option = 3 then return no-apply.
  v-option = 1.
end.
else do:
  message
  "Будет сохранена в файл ВСЯ последовательность действий по формированию списка" skip
  view-as alert-box question buttons yes-no update glog.
  v-option = 2.
  if not glog then do:
    return no-apply.
  end.
end.
  do
  on error undo, return error
  :
  assign
    f-name = "default.bbm"
    glog = yes
    .
  system-dialog get-file f-name
    filters "Макрос создания списка кодов *.bbm" "*.bbm"
    ask-overwrite
    save-as
    use-filename
    update glog
    default-extension "bbm".
  if not glog then do:
    apply "entry" to br-list in frame Dialog-Frame.
    return no-apply.
  end.
  run waitfram-show in this-procedure ("Сохранение макроса формирования списка кодов.    ЖДИТЕ...").
  output stream PrnLibStream to value (f-name).
  case v-option:
    when 1 then do:
      for each buf_macro-list-hist:
        export stream PrnLibStream
        buf_macro-list-hist.
      end.
    end.
    when 2 then do:
  for each buf_scnblist-hist:
      export stream PrnLibStream
      buf_scnblist-hist.
  end.
    end.
  end case.
  output stream PrnLibStream close.
  run waitfram-hide in this-procedure .
  end.
end procedure.
PROCEDURE reposition-goods :
define input  parameter p-direction   as character no-undo .
define output parameter p-recid as recid no-undo .
define buffer buf_goods for ub.goods.
case p-direction :
  when "first":U
  then do:
    get first br-list.
  end.
  when "last":U
  then do:
    get last br-list.
  end.
  when "prev":U
  then do:
    get prev br-list.
    if not available scnblist then do:
      message
      "Это первый товар списка"
      view-as alert-box.
    end.
  end.
  when "next":U
  then do:
    get next br-list.
    if not available scnblist then do:
      message
      "Это последний товар списка"
      view-as alert-box.
    end.
  end.
end case .
find first buf_goods no-lock where
        buf_goods.gds-code = scnblist.gds-code no-error.
if available scnblist then do:
  assign
  p-recid = recid(buf_goods)
  .
end.
run reposition-query in this-procedure
  (input recid(scnblist)
  ).
END PROCEDURE.
PROCEDURE reposition-query :
define input parameter p-recid as recid no-undo .
if p-recid <> ?
then do:
  reposition br-list to recid p-recid no-error.
end.
do with frame Dialog-Frame:
  apply "entry":u to browse br-list .
  apply "VALUE-CHANGED":u to browse br-list .
end.
END PROCEDURE.
procedure proc-cd :
define variable v-num as integer no-undo .
define variable v-action as character no-undo .
define buffer buf_bb-list for scnblist.
if p-curr-obj-type <> 'маг':U then return.
run gbl/d-askw.w (
                  input "Отослать на кассы"
                 ,input "Передача/удаление списка кодов на кассу/с кассы"
                 ,input "|"
                 ,input "Передача|Удаление|Отмена"
                 ,input "Передача на кассу|Удаление с кассы|Отмена"
                 ,input 1
                 ,input 3
                 ,output v-num).
if v-num = 3 then return.
v-action = (if v-num = 1 then "U":U else "D").
define variable v-chk-act-host-code as integer   no-undo .
define variable v-ok as logical no-undo .
define variable vss-include-info74 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  'маг':U
  ,input  abs(p-curr-obj-code)
  ,output v-chk-act-host-code
  )  .
if v-action = "U" then do:
define variable vss-include-info75 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_cashdesk-goods_add-def':U
    ,input  'object':U
    ,input  v-chk-act-host-code
    ,input  'маг':U
    ,input  abs(p-curr-obj-code)
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-ok
    )  .
end.
end.
else do:
define variable vss-include-info76 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_cashdesk-goods_deletion':U
    ,input  'object':U
    ,input  v-chk-act-host-code
    ,input  'маг':U
    ,input  abs(p-curr-obj-code)
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-ok
    )  .
end.
end.
if NOT v-ok then return .
for each bc-list:
  delete bc-list.
end.
for each pbc-list:
  delete pbc-list.
end.
for each buf_bb-list:
  if buf_bb-list.b-str <> ""
  and buf_bb-list.loc-ean = no
  then do:
    create pbc-list.
    buffer-copy buf_bb-list to pbc-list.
    if v-action = "D" then do:
      assign
      pbc-list.del = yes.
    end.
    release pbc-list.
  end.
  else do:
    find first bc-list where
              bc-list.b-code = buf_bb-list.b-code no-error.
    if not available bc-list then do:
    create bc-list.
    buffer-copy buf_bb-list to bc-list.
      if v-action = "D" then do:
        assign
        bc-list.del = yes.
      end.
    release bc-list.
    end.
  end.
end.
if can-find(first bc-list no-lock) then do:
    run str/diallog.w ( input parparentproc
                  , input this-procedure
                  , input 'str/send-bcn.p':U
                  , input (string(p-curr-obj-code) + chr(4) + v-action)
                  , input (if can-find(first pbc-list no-lock)
                           then yes
                           else no)
                  , input 'Прервать'
                  , input (if v-action = "U"
                           then 'Отсылка бар-кодов на кассу'
                           else 'Удаление бар-кодов c кассы'
                           )) no-error .
end.
if can-find(first pbc-list no-lock) then do:
    run str/diallog.w ( input parparentproc
                  , input this-procedure
                  , input 'str/s-prdbcn.p':U
                  , input (string(p-curr-obj-code) + chr(4) + v-action)
                  , input no
                  , input 'Прервать'
                  , input (if v-action = "U"
                           then 'Отсылка ДопБК на кассу'
                           else 'Удаление ДопБК с кассы'
                           )) no-error .
end.
end procedure.
PROCEDURE proc-parts-cashparts :
define input parameter rs-list-method as character no-undo .
define variable v-value-integer as integer   no-undo .
define variable glog as logical no-undo .
define variable v-message as character no-undo .
define variable v-item as character no-undo .
assign
frame Dialog-Frame
t-parts-not-blank
t-parts-all
.
if not (t-parts-not-blank or t-parts-all ) then do:
  message
  "У Вас не включен флаг <на непуст. № парт.> ИЛИ <все партии>" skip
  "Вы уверены, что Вам нужны коды ПАРТИЙ?"
  view-as alert-box question buttons yes-no update glog.
  if not glog then do:
    undo, return error .
  end.
end.
glog = yes.
CASE rs-list-method:
  when "parts-cashparts":U then do:
    assign
    v-message = substitute("Лок.коды партий свободной зоны &1&2 для товаров с продажей по партиям", chr(10), stat-line(rs-status))
    .
  end.
  when "parts-ean-cashparts":U then do:
    assign
    v-message = substitute("Лок.коды (EAN) партий свободной зоны &1&2 для товаров с продажей по партиям", chr(10), stat-line(rs-status))
    .
  end.
END CASE.
message
v-message
view-as alert-box question buttons OK-Cancel update glog.
if not glog then do:
  return error.
end.
define variable vss-include-info77 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-one in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-user-select
  ,output v-sel-obj-type
  ,output v-sel-obj-code
  )  .
if not v-user-select then do:
  return error.
end.
CASE rs-list-method:
  when "parts-cashparts":U then do:
    assign
    dsp-rs = substitute("Лок.коды партий свободной зоны на &1&2 для товаров с продажей по партиям &3", v-sel-obj-type, v-sel-obj-code, stat-line(rs-status))
    v-item = v-sel-obj-type + chr(3) + string(v-sel-obj-code)
    .
  end.
  when "parts-ean-cashparts":U then do:
    assign
    dsp-rs = substitute("Лок.коды (EAN) партий свободной зоны на &1&2 для товаров с продажей по партиям &3", v-sel-obj-type, v-sel-obj-code, stat-line(rs-status))
    v-item = v-sel-obj-type + chr(3) + string(v-sel-obj-code)
    .
  end.
END CASE.
v-no-hist = 0.
run create-scnblist-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                    , input-output v-seq
                                    , input 0
                                    , input '':U
                                    , input dsp-rs
                                    , input tot-lns
                                    , input rs-list-method
                                    , input rs-status
                                    , input v-item
                                    , input '':U
                                    , input ?
                                    ).
END PROCEDURE.
PROCEDURE proc-parts-last-date :
define input parameter rs-list-method as character no-undo .
define variable v-value-integer as integer   no-undo .
define variable glog as logical no-undo .
define variable v-message as character no-undo .
define variable v-item as character no-undo .
assign
frame Dialog-Frame
t-parts-not-blank
t-parts-all
.
if not (t-parts-not-blank or t-parts-all ) then do:
  message
  "У Вас не включен флаг <на непуст. № парт.> ИЛИ <все партии>" skip
  "Вы уверены, что Вам нужны коды ПАРТИЙ?"
  view-as alert-box question buttons yes-no update glog.
  if not glog then do:
    undo, return error .
  end.
end.
glog = yes.
CASE rs-list-method:
  when "parts-last-date":U then do:
    assign
    v-message = substitute("Лок.коды партий свободной зоны &1&2 с истекающим сроком хранения", chr(10), stat-line(rs-status))
    .
  end.
  when "parts-rsrv-last-date":U then do:
    assign
    v-message = substitute("Лок.коды зарезерв.партий &1&2 с истекающим сроком хранения", chr(10), stat-line(rs-status))
    .
  end.
  when "parts-ean-last-date":U then do:
    assign
    v-message = substitute("Лок.коды (EAN) партий свободной зоны &1&2 с истекающим сроком хранения", chr(10), stat-line(rs-status))
    .
  end.
  when "parts-ean-rsrv-last-date":U then do:
    assign
    v-message = substitute("Лок.коды (EAN) зарезерв.партий &1&2 с истекающим сроком хранения", chr(10), stat-line(rs-status))
    .
  end.
END CASE.
message
v-message
view-as alert-box question buttons OK-Cancel update glog.
if not glog then do:
  return error.
end.
define variable vss-include-info78 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-one in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-user-select
  ,output v-sel-obj-type
  ,output v-sel-obj-code
  )  .
if not v-user-select then do:
  return error.
end.
run gbl/d-integer.w (
        input ?
      ,input (
      'title=':u + substitute("Введите кол-во дней, в течение которых истекает срок хранения") + '\':u
    + 'text1=':u + "Кол-во дней" + '\':u
    + 'format=' + "->>9" + '\':u
    + 'fillin_row=3\':u
    + 'fillin_col=4\':u
    + 'fillin_width=20\':u
    + 'fillin_height=1\':u
    + 'max-chars=70\':u
    + 'readonly=' +  'no':u + '\':u)
    , input-output v-value-integer
    , output v-ok
        ).
if not v-ok then return error.
CASE rs-list-method:
  when "parts-last-date":U then do:
    assign
    dsp-rs = substitute("Лок.коды партий свободной зоны на &1&2 со сроком хранения, истекающим через &3 дн.  и ранее &4", v-sel-obj-type, v-sel-obj-code, v-value-integer, stat-line(rs-status))
    v-item = v-sel-obj-type + chr(3) + string(v-sel-obj-code)  + chr(3) + string(v-value-integer)
    .
  end.
  when "parts-rsrv-last-date":U then do:
    assign
    dsp-rs = substitute("Лок.коды зарезерв. партий на &1&2 со сроком хранения, истекающим через &3 дн.  и ранее &4", v-sel-obj-type, v-sel-obj-code, v-value-integer, stat-line(rs-status))
    v-item = v-sel-obj-type + chr(3) + string(v-sel-obj-code)  + chr(3) + string(v-value-integer)
    .
  end.
  when "parts-ean-last-date":U then do:
    assign
    dsp-rs = substitute("Лок.коды (EAN) партий свободной зоны на &1&2 со сроком хранения, истекающим через &3 дн.  и ранее &4", v-sel-obj-type, v-sel-obj-code, v-value-integer, stat-line(rs-status))
    v-item = v-sel-obj-type + chr(3) + string(v-sel-obj-code)  + chr(3) + string(v-value-integer)
    .
  end.
  when "parts-ean-rsrv-last-date":U then do:
    assign
    dsp-rs = substitute("Лок.коды (EAN) зарезерв. партий на &1&2 со сроком хранения, истекающим через &3 дн.  и ранее &4", v-sel-obj-type, v-sel-obj-code, v-value-integer, stat-line(rs-status))
    v-item = v-sel-obj-type + chr(3) + string(v-sel-obj-code)  + chr(3) + string(v-value-integer)
    .
  end.
END CASE.
v-no-hist = 0.
run create-scnblist-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                    , input-output v-seq
                                    , input 0
                                    , input '':U
                                    , input dsp-rs
                                    , input tot-lns
                                    , input rs-list-method
                                    , input rs-status
                                    , input v-item
                                    , input '':U
                                    , input ?
                                    ).
END PROCEDURE.
PROCEDURE proc-parts-fib :
define input parameter rs-list-method as character no-undo .
define variable v-value-integer as integer   no-undo .
define variable glog as logical no-undo .
define variable v-message as character no-undo .
define variable v-item as character no-undo .
assign
frame Dialog-Frame
t-parts-not-blank
t-parts-all
.
if not (t-parts-not-blank or t-parts-all ) then do:
  message
  "У Вас не включен флаг <на непуст. № парт.> ИЛИ <все партии>" skip
  "Вы уверены, что Вам нужны коды ПАРТИЙ?"
  view-as alert-box question buttons yes-no update glog.
  if not glog then do:
    undo, return error .
  end.
end.
glog = yes.
CASE rs-list-method:
  when "parts-fib":U then do:
    assign
    v-message = substitute("Лок.коды ФиБ партий свободной зоны &1&2", chr(10), stat-line(rs-status))
    .
  end.
  when "parts-rsrv-fib":U then do:
    assign
    v-message = substitute("Лок.коды зарезерв. ФиБ партий &1&2", chr(10), stat-line(rs-status))
    .
  end.
  when "parts-ean-fib":U then do:
    assign
    v-message = substitute("Лок.коды (EAN) ФиБ партий свободной зоны &1&2", chr(10), stat-line(rs-status))
    .
  end.
  when "parts-ean-rsrv-fib":U then do:
    assign
    v-message = substitute("Лок.коды (EAN) зарезерв.ФиБ партий &1&2", chr(10), stat-line(rs-status))
    .
  end.
END CASE.
message
v-message
view-as alert-box question buttons OK-Cancel update glog.
if not glog then do:
  return error.
end.
define variable vss-include-info79 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-one in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-user-select
  ,output v-sel-obj-type
  ,output v-sel-obj-code
  )  .
if not v-user-select then do:
  return error.
end.
CASE rs-list-method:
  when "parts-fib":U then do:
    assign
    dsp-rs = substitute("Лок.коды ФиБ партий свободной зоны на &1&2 &3", v-sel-obj-type, v-sel-obj-code, stat-line(rs-status))
    v-item = v-sel-obj-type + chr(3) + string(v-sel-obj-code)
    .
  end.
  when "parts-rsrv-fib":U then do:
    assign
    dsp-rs = substitute("Лок.коды зарезерв. ФиБ партий на &1&2 &3", v-sel-obj-type, v-sel-obj-code, stat-line(rs-status))
    v-item = v-sel-obj-type + chr(3) + string(v-sel-obj-code)
    .
  end.
  when "parts-ean-fib":U then do:
    assign
    dsp-rs = substitute("Лок.коды (EAN) ФиБ партий свободной зоны на &1&2 &4", v-sel-obj-type, v-sel-obj-code, stat-line(rs-status))
    v-item = v-sel-obj-type + chr(3) + string(v-sel-obj-code)
    .
  end.
  when "parts-ean-rsrv-fib":U then do:
    assign
    dsp-rs = substitute("Лок.коды (EAN) зарезерв. ФиБ партий на &1&2 &4", v-sel-obj-type, v-sel-obj-code, stat-line(rs-status))
    v-item = v-sel-obj-type + chr(3) + string(v-sel-obj-code)
    .
  end.
END CASE.
v-no-hist = 0.
run create-scnblist-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                    , input-output v-seq
                                    , input 0
                                    , input '':U
                                    , input dsp-rs
                                    , input tot-lns
                                    , input rs-list-method
                                    , input rs-status
                                    , input v-item
                                    , input '':U
                                    , input ?
                                    ).
END PROCEDURE.
PROCEDURE proc-parts-end :
define input parameter rs-list-method as character no-undo .
define variable v-value-integer as integer   no-undo .
define variable glog as logical no-undo .
define variable v-message as character no-undo .
define variable v-item as character no-undo .
define variable v-from-date as date no-undo .
define variable v-to-date as date no-undo .
define buffer buf_rp-by-call for ub.rp-by-call.
find first buf_rp-by-call no-lock where
          buf_rp-by-call.profile_id = 62 no-error.
if not available buf_rp-by-call then do:
  message
  "В вашей системе НЕ ВКЛЮЧЕН профайл установки флагов на закончившиеся партии" skip
  "Отбор невозможен"
  view-as alert-box error .
  return error.
end.
assign
frame Dialog-Frame
t-parts-not-blank
t-parts-all
.
if not (t-parts-not-blank or t-parts-all ) then do:
  message
  "У Вас не включен флаг <на непуст. № парт.> ИЛИ <все партии>" skip
  "Вы уверены, что Вам нужны коды ПАРТИЙ?"
  view-as alert-box question buttons yes-no update glog.
  if not glog then do:
    undo, return error .
  end.
end.
glog = yes.
CASE rs-list-method:
  when "parts-end-date-obj":U then do:
    assign
    v-message = substitute("Лок.коды закончившихся партий по объекту &1&2", chr(10), stat-line(rs-status))
    .
  end.
  when "parts-ean-end-date-obj":U then do:
    assign
    v-message = substitute("Лок.коды (EAN) закончившихся партий по объекту &1&2", chr(10), stat-line(rs-status))
    .
  end.
END CASE.
message
v-message
view-as alert-box question buttons OK-Cancel update glog.
if not glog then do:
  return error.
end.
define variable vss-include-info80 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-one in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-user-select
  ,output v-sel-obj-type
  ,output v-sel-obj-code
  )  .
if not v-user-select then do:
  return error.
end.
message
"Выберите начальную и конечную даты, между которыми было обнаружено, что партия закончилась"
view-as alert-box.
run gbl/get-per.w ( output glog
                   ,input-output v-from-date
                   ,input-output v-to-date
                   ) no-error.
CASE rs-list-method:
  when "parts-end-date-obj":U then do:
    assign
    dsp-rs = substitute("Лок.коды закончившихся партий на &1&2 &3", v-sel-obj-type, v-sel-obj-code, stat-line(rs-status))
    v-item = v-sel-obj-type + chr(3) +
             string(v-sel-obj-code) + chr(3) +
             string(v-from-date, "99/99/9999") + chr(3) +
             string(v-to-date, "99/99/9999")
    .
  end.
  when "parts-ean-end-date-obj":U then do:
    assign
    dsp-rs = substitute("Лок.коды (EAN) закончившихся партий на &1&2 &3", v-sel-obj-type, v-sel-obj-code, stat-line(rs-status))
    v-item = v-sel-obj-type + chr(3) +
             string(v-sel-obj-code) + chr(3) +
             string(v-from-date, "99/99/9999") + chr(3) +
             string(v-to-date, "99/99/9999")
    .
  end.
END CASE.
v-no-hist = 0.
run create-scnblist-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                    , input-output v-seq
                                    , input 0
                                    , input '':U
                                    , input dsp-rs
                                    , input tot-lns
                                    , input rs-list-method
                                    , input rs-status
                                    , input v-item
                                    , input '':U
                                    , input ?
                                    ).
END PROCEDURE.
