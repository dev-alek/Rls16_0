define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Автоматизированное формирование списка товаров".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE VARIABLE v-S_CONTRACT               AS CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE v-S_CODE_LAST_MASTER_NUM   AS CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE v-DELIM_CHR_3              AS CHARACTER NO-UNDO INITIAL "".
ASSIGN
   v-S_CONTRACT                = "Contract":U
   v-S_CODE_LAST_MASTER_NUM    = "LastMasterNum":U
   v-DELIM_CHR_3               = ","
   .
DEFINE VARIABLE i-gl-Host-Code      AS INTEGER NO-UNDO INITIAL 0.
DEFINE VARIABLE i-gl-Contract-Code  AS INTEGER NO-UNDO INITIAL 0.
DEFINE VARIABLE i-gl-Extent3        AS INTEGER NO-UNDO INITIAL 0 EXTENT 3.
FUNCTION Can-Find-Spec RETURN LOGICAL (
   INPUT iHost-Code    AS INTEGER,
   INPUT iContract-Num AS INTEGER,
   INPUT iGds-Code     AS INTEGER ):
   DEFINE BUFFER buf_Spec FOR ub.Contract-Specif.
   DEFINE VARIABLE iTmp-Host-Code     AS INTEGER NO-UNDO INITIAL 0.
   DEFINE VARIABLE iTmp-Contract-Num  AS INTEGER NO-UNDO INITIAL 0.
   DEFINE VARIABLE iTmp-Extent3       AS INTEGER NO-UNDO INITIAL 0 EXTENT 3.
   DEFINE VARIABLE lRet               AS LOGICAL NO-UNDO INITIAL FALSE.
   RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
       INPUT  iHost-Code,
       INPUT  iContract-Num,
       OUTPUT iTmp-Extent3
       ).
   IF iTmp-Extent3[1] = 2 THEN DO:
      ASSIGN
         iTmp-Host-Code      = iTmp-Extent3[2]
         iTmp-Contract-Num   = iTmp-Extent3[3]
         .
   END. ELSE DO:
      ASSIGN
         iTmp-Host-Code      = iHost-Code
         iTmp-Contract-Num   = iContract-Num
         .
   END.
   IF iGds-Code = ? THEN DO:
      ASSIGN
         lRet = CAN-FIND(FIRST buf_Spec NO-LOCK WHERE
                               buf_Spec.Host-Code     = iTmp-Host-Code
                           AND buf_Spec.Contract-Num  = iTmp-Contract-Num
                        ).
   END. ELSE DO:
         lRet = CAN-FIND(FIRST buf_Spec NO-LOCK WHERE
                               buf_Spec.Host-Code     = iTmp-Host-Code
                           AND buf_Spec.Contract-Num  = iTmp-Contract-Num
                           AND buf_Spec.Gds-Code      = iGds-Code
                         ).
   END.
   RETURN (lRet).
END FUNCTION.
PROCEDURE MS-Contract-EXTENT-3:
   DEFINE INPUT  PARAMETER i-Host-Code     AS INTEGER NO-UNDO.
   DEFINE INPUT  PARAMETER i-Contract-Code AS INTEGER NO-UNDO.
   DEFINE OUTPUT PARAMETER i-Ret           AS INTEGER NO-UNDO EXTENT 3 INITIAL 0.
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-Classif.
   DEFINE BUFFER buf_Cont        FOR ub.Contract.
   DEFINE BUFFER buf_Cont-2      FOR ub.Contract.
   FIND FIRST buf_Cont-2 WHERE
              buf_Cont-2.Host-Code      = i-Host-Code
          AND buf_Cont-2.Contract-Code  = i-Contract-Code
        NO-LOCK NO-ERROR.
   IF NOT AVAILABLE buf_Cont-2 THEN DO:
      RETURN.
   END.
   FOR FIRST buf_Ext-Classif WHERE
             buf_Ext-Classif.Classif-name = v-S_CONTRACT
        AND  buf_Ext-Classif.CharKey_One  = STRING(i-Host-code) + v-DELIM_CHR_3 +
                                            STRING(i-Contract-code)
        AND  buf_Ext-classif.db-num       = buf_Cont-2.Db-num
       NO-LOCK,
       EACH buf_Cont WHERE
            buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3 ))
        AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
       NO-LOCK:
       ASSIGN
          i-Ret[1] = 1
          i-Ret[2] = buf_Cont.Host-code
          i-Ret[3] = buf_Cont.Contract-code
          .
       LEAVE.
   END.
   IF i-Ret[1] <> 1 THEN DO:
      FOR FIRST buf_Ext-Classif WHERE
                buf_Ext-Classif.Classif-name = v-S_CONTRACT
           AND  buf_Ext-Classif.CharKey_Two  = STRING(i-Host-code) + v-DELIM_CHR_3 +
                                               STRING(i-Contract-code)
           AND  buf_Ext-classif.db-num       = buf_Cont-2.Db-num
          NO-LOCK,
          EACH buf_Cont WHERE
               buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
           AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
          NO-LOCK:
          ASSIGN
             i-Ret[1] = 2
             i-Ret[2] = buf_Cont.Host-code
             i-Ret[3] = buf_Cont.Contract-code
             .
          LEAVE.
      END.
   END.
   RETURN.
END PROCEDURE.
define new shared variable body-handle as handle no-undo.
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION get-region RETURNS CHARACTER
  ( input parhost-code as integer, input parobj-type as character, input parobj-code as integer ) :
  define variable par-region as character no-undo.
  if parhost-code = 0 and
       parobj-type = "":U and
       parobj-code = 0 then do:
       par-region = "Глобально".
       return par-region.
    end.
    if parobj-type = 'орг':U then do:
       par-region = fill(chr(32), 2) + "Фирма" + chr(32) + string(parhost-code).
       return par-region.
    end.
    if parobj-type = 'регион':U
    then do:
       par-region = fill(chr(32), 2) + "Регион" + chr(32) + string(parobj-code).
       return par-region.
    end.
    par-region = fill(chr(32), 4) + parobj-type + chr(32) + string(parobj-code).
    return par-region.
END FUNCTION.
FUNCTION get-objregion RETURNS CHARACTER
  (  input parobj-type as character, input parobj-code as integer ) :
  define variable par-region as character no-undo.
  if  parobj-type = "":U and
      parobj-code = 0
  then do:
     par-region = "Глобально".
  end.
  else if parobj-type = 'орг':U
  then do:
     par-region = fill(chr(32), 2) + "Фирма" + chr(32) + string(parobj-code).
  end.
  else if parobj-type = 'регион':U
  then do:
     par-region = fill(chr(32), 2) + "Регион" + chr(32) + string(parobj-code).
  end.
  else
     par-region = fill(chr(32), 4) + parobj-type + chr(32) + string(parobj-code).
  return par-region.
END FUNCTION.
define variable rs-list-method as character no-undo .
define variable lns-ignore as integer no-undo .
define variable notes as character no-undo .
define variable v-seq as integer no-undo .
define variable v-no-hist as integer no-undo init -1.
define variable lns-cnt as integer no-undo .
define variable line-mode as character no-undo .
define variable line-rec as recid no-undo .
define variable v-num-add          as integer no-undo .
define variable v-num-ignored      as integer no-undo .
define variable g#report-num as integer no-undo .
define variable v-no-obj as logical no-undo .
define variable v-rid-list as character no-undo .
define buffer buf_clients for ub.clients.
define variable v-user-select as logical no-undo .
define variable v-sel-obj-type like ub.clients.obj-type no-undo .
define variable v-sel-obj-code like ub.clients.obj-code no-undo .
define variable varscales-pref as character no-undo .
define variable varpgscales-pref as character no-undo .
define variable macro-play-option as character no-undo .
define variable v-docs-all as logical no-undo .
define variable v-docs-cmp as logical no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define shared temp-table gds-list-flt no-undo like ub.goods
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared  temp-table gds-list-flt-hist no-undo
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
procedure create-gds-list-flt-hist :
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
define buffer buf_gds-list-flt-hist for gds-list-flt-hist.
  do
  on error undo, return error
  :
    CASE p-mode:
      when 'title' then do:
        find first buf_gds-list-flt-hist where
                   buf_gds-list-flt-hist.id = 0   no-error.
        if not available buf_gds-list-flt-hist then do:
          create buf_gds-list-flt-hist.
          assign
          buf_gds-list-flt-hist.id = 0
          buf_gds-list-flt-hist.line = 0
          buf_gds-list-flt-hist.list-table = '':U
          .
        end.
        assign
        buf_gds-list-flt-hist.des =  p-des
        buf_gds-list-flt-hist.num-recs = p-num-recs
        buf_gds-list-flt-hist.option_  = p-option
        buf_gds-list-flt-hist.item_ = p-item
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
        create buf_gds-list-flt-hist.
        assign
        buf_gds-list-flt-hist.id = p-seq
        buf_gds-list-flt-hist.list-table = p-list-table
         p-seq = (if p-line = 0 then (p-seq + 1) else p-seq)
        buf_gds-list-flt-hist.des =  p-des
        buf_gds-list-flt-hist.line = p-line
        buf_gds-list-flt-hist.num-recs = p-num-recs
        buf_gds-list-flt-hist.option_  = p-option
        buf_gds-list-flt-hist.item_ = p-item
        buf_gds-list-flt-hist.hist-mode =  p-hist-mode
        buf_gds-list-flt-hist.status_ =  p-status_
        buf_gds-list-flt-hist.num-add = v-num-add
        buf_gds-list-flt-hist.num-ignored = v-num-ignored
        .
      end.
      when 'ИЗМЕНЕНИЕ':U + chr(4) + 'des' then do:
        find first buf_gds-list-flt-hist where
                  buf_gds-list-flt-hist.id = p-seq
              and buf_gds-list-flt-hist.line = p-line no-error .
        if  available buf_gds-list-flt-hist then do:
          assign
          buf_gds-list-flt-hist.des =  p-des
          buf_gds-list-flt-hist.num-recs = p-num-recs
          buf_gds-list-flt-hist.option_  = p-option
          buf_gds-list-flt-hist.item_ = p-item
          buf_gds-list-flt-hist.list-table = (if p-list-table <> '':U and p-list-table <> ?
                                     then p-list-table
                                     else buf_gds-list-flt-hist.list-table)
          .
        end.
      end.
      when 'ИЗМЕНЕНИЕ':U + chr(4) + 'mode' then do:
        find first buf_gds-list-flt-hist where
                  buf_gds-list-flt-hist.id = p-seq
              and buf_gds-list-flt-hist.line = p-line  no-error .
        if available buf_gds-list-flt-hist then do:
          assign
          buf_gds-list-flt-hist.hist-mode =  p-hist-mode
          buf_gds-list-flt-hist.num-recs  = (if buf_gds-list-flt-hist.line = 0 then p-num-recs else buf_gds-list-flt-hist.num-recs)
          buf_gds-list-flt-hist.list-table = (if p-list-table <> '':U and p-list-table <> ?
                                     then p-list-table
                                     else buf_gds-list-flt-hist.list-table)
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
        buf_gds-list-flt-hist.item_ = p-item
        .
      end.
      else do:
        assign
        buf_gds-list-flt-hist.item_ = "!ERROR"
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
def var vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable list-abcxyz          as character           no-undo .
define buffer l-gds-list-flt for gds-list-flt.
define stream sout.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table tt-goods no-undo like ub.goods.
define new shared temp-table tt-clients no-undo like ub.clients.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure gdsoattr-name :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-name in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-value :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-value in g#attr-lib
      (input  p-code
      ,input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-gds-code :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-gds-code in g#attr-lib
      (input  p-code
      ,input  p-value
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-gds-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-write :
  define input parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-write in g#attr-lib
      (input p-gds-code
      ,input p-obj-type
      ,input p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-exist :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-delete :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-doc-tickets :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-doc-tickets in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-dop-alt-name :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-dop-alt-name in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-gds-margins :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-gds-margins in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-normal-wastage :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-normal-wastage in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr-margin-value :
  define input  parameter p-gds-code         as integer   no-undo .
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define output parameter p-min-value        as decimal   no-undo initial ? .
  define output parameter p-max-value        as decimal   no-undo initial ? .
  define output parameter p-increase-pc      as decimal   no-undo initial ? .
  define output parameter p-rmethod          as character no-undo initial '':U .
  define output parameter p-base             as decimal   no-undo initial ? .
  define output parameter p-range-margin     as integer   no-undo .
  define output parameter p-exists-margin    as logical   no-undo .
  define output parameter p-range-increase   as integer   no-undo .
  define output parameter p-exists-increase  as logical   no-undo .
  define output parameter p-range-rmethod    as integer   no-undo .
  define output parameter p-exists-rmethod   as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-margin-value in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-min-value
      ,output p-max-value
      ,output p-increase-pc
      ,output p-rmethod
      ,output p-base
      ,output p-range-margin
      ,output p-exists-margin
      ,output p-range-increase
      ,output p-exists-increase
      ,output p-range-rmethod
      ,output p-exists-rmethod
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-o-normal-wastage-value :
  define input-output parameter objNormWast as class ibs.th.ref.normwastsub no-undo.
do
on error undo, return error
:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-o-normal-wastage-value in g#attr-lib
      (input-output objNormWast
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr_check-code-dt-seasons :
  define input  parameter p-code     like ub.goods.gds-code   no-undo .
  define input  parameter p-obj-type like ub.clients.obj-type no-undo .
  define input  parameter p-obj-code like ub.clients.obj-code no-undo .
  define output parameter p-gds-code like ub.goods.gds-code   no-undo .
  define output parameter p-dt-code  as   integer             no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-code-dt-seasons in g#attr-lib
      (input p-code
      ,input p-obj-type
      ,input p-obj-code
      ,output p-gds-code
      ,output p-dt-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-manual-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-batch-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-sum-grps :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-sum-grps in g#attr-lib
      (input parparentproc
      ,input p-gds-code
      ,input p-obj-type
      ,input p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-init-increase-pc :
  define input  parameter p-gds-code like ub.goods.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj.obj-type no-undo .
  define input  parameter p-obj-code like ub.gds-obj.obj-code no-undo .
  define output parameter p-value    as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-init-increase-pc in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-round-method :
  define input parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
  define input parameter p-obj-type like ub.gds-obj-attr.obj-type no-undo .
  define input parameter p-obj-code like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-round-method in g#attr-lib
      (input p-gds-code
      ,input p-obj-type
      ,input p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-taracode :
  define input parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
  define input parameter p-obj-type like ub.gds-obj-attr.obj-type no-undo .
  define input parameter p-obj-code like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-taracode in g#attr-lib
      (input parparentproc
      ,input p-gds-code
      ,input p-obj-type
      ,input p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-attr_check-ptrl-divis :
  define input  parameter p-gds-code like ub.goods.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj.obj-type no-undo .
  define input  parameter p-obj-code like ub.gds-obj.obj-code no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical   no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-attr_check-ptrl-divis in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-dt-seasons :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-dt-seasons in g#attr-lib
      (input parparentproc
      ,input p-gds-code
      ,input p-obj-type
      ,input p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gds-attr-name :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-name in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-value :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define output parameter p-value    as character no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-write :
  define input parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define input parameter p-value    like ub.goods-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-write in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-exist :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-delete :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy-to :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy-to in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-ptrl-divis :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-ptrl-divis in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-glob-sum-grps :
  define input  parameter p-mode        as character no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
  define input-output parameter p-value as integer no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-glob-sum-grps in g#attr-lib
      (input p-mode
      ,input p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-ptrl-densities :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-ptrl-densities in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-CommodityCode :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-CommodityCode in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-office-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-office-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-mark-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-mark-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-emrc-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-emrc-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-group-np :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-group-np in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-item-matter-mark :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-item-matter-mark in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-type-method-calc :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-type-method-calc in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-is-loyalty-payment :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-is-loyalty-payment in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-15x80 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-15x80 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-8x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-8x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-6x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-6x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-manual-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-batch-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-energy-value :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-energy-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-set-dt-seasons :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-can-set  as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-set-dt-seasons in g#attr-lib
      (input  p-gds-code
      ,output p-can-set
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isExemplarGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isExemplarGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isVolumArticGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isVolumArticGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gdshattr-name :
define input  parameter p-code           as character no-undo .
define output parameter p-type           as character no-undo .
define output parameter p-format         as character no-undo .
define output parameter p-label          as character no-undo .
define output parameter p-user-can-edit  as logical   no-undo .
define output parameter p-output-display as logical   no-undo .
define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdshattr-name in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gdshattr-tooltip :
define input  parameter p-code    as character no-undo .
define output parameter p-tooltip as character no-undo .
define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdshattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gdshattr-value :
define input  parameter p-code as character no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as int no-undo .
define input  parameter p-gds-code as int no-undo .
define output parameter p-value as character no-undo .
define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdshattr-value in g#attr-lib
    (input  p-code
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  p-gds-code
    ,output p-value
    ,output p-type
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure gdshattr-h-value :
define input  parameter p-code as character no-undo .
define input  parameter p-host-code as integer no-undo .
define input  parameter p-gds-code as int no-undo .
define output parameter p-value as character no-undo .
define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdshattr-h-value in g#attr-lib
    (input  p-code
    ,input  p-host-code
    ,input  p-gds-code
    ,output p-value
    ,output p-type
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure gdshattr-write :
define input parameter p-gds-code like ub.gds-host-attr.gds-code   no-undo .
define input parameter p-obj-type like ub.clients.obj-type   no-undo .
define input parameter p-obj-code like ub.clients.obj-code   no-undo .
define input parameter p-code     like ub.gds-host-attr.attr-code  no-undo .
define input parameter p-value    like ub.gds-host-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdshattr-write in g#attr-lib
      (input p-gds-code
      ,input p-obj-type
      ,input p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gdshattr-EXIST :
define input parameter p-gds-code like ub.gds-host-attr.gds-code   no-undo .
define input parameter p-obj-type like ub.clients.obj-type   no-undo .
define input parameter p-obj-code like ub.clients.obj-code   no-undo .
define input parameter p-code     like ub.gds-host-attr.attr-code  no-undo .
define OUTPUT parameter p-EXIST   AS LOGICAL no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdshattr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gdshattr-DELETE :
define input parameter p-gds-code like ub.gds-host-attr.gds-code   no-undo .
define input parameter p-obj-type like ub.clients.obj-type   no-undo .
define input parameter p-obj-code like ub.clients.obj-code   no-undo .
define input parameter p-code     like ub.gds-host-attr.attr-code  no-undo .
define output parameter p-DELETED  AS LOGICAL no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdshattr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gdshattr-news :
define input  parameter p-code           as character no-undo .
define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdshattr-news in g#attr-lib
      (
       input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gdshattr-copy :
define input  parameter p-code           as character no-undo .
define output parameter p-copy           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdshattr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gdshattr-manual-edit :
define input  parameter p-code           as character no-undo .
define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdshattr-manual-edit in g#attr-lib
    (input  p-code
    ,output p-section-num
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
  end.
end procedure.
procedure gdshattr-batch-edit :
define input  parameter p-code           as character no-undo .
define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdshattr-batch-edit in g#attr-lib
    (input  p-code
    ,output p-section-num
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
  end.
end procedure.
define variable vss-include-info22 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure grplib-get-full-name :
   define input parameter p-node-code  as integer      no-undo.
   define output parameter p-full-name as character    no-undo.
   do
on error undo, return error
:
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_upper_gds-grp for ub.gds-grp.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-full-name  = ""
        v-upper-code = 1
    .
    do while buf_gds-grp.upper-code <> 0
    on error undo, return error "grplib-get-full-name: Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = buf_gds-grp.node-name
                         + (if p-full-name <> "" then chr(47) else "")
                         + p-full-name
            v-upper-code = buf_gds-grp.upper-code
        .
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
    assign
    p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
    .
end.
end .
procedure grplib-get-node-from-full-name :
define input parameter p-full-name as character no-undo .
define output parameter p-node-code as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-upper-code as integer no-undo .
define variable v-root-code as integer no-undo .
define variable v-entry as character no-undo .
define buffer buf_gds-grp       for ub.gds-grp.
do
on error undo, return error
:
  find first buf_gds-grp no-lock
      where buf_gds-grp.upper-code = 0
  no-error .
  if not available buf_gds-grp
  then do:
      undo, return error substitute("Не найдена корневая группа товаров (upper-code = 0)").
  end.
  else do:
    assign
    v-root-code = buf_gds-grp.node-code
    .
  end.
  v-upper-code = v-root-code.
  do v-ii = 1 to num-entries(p-full-name, chr(47)):
    assign
    v-entry = entry(v-ii, p-full-name, chr(47)).
    if v-entry = '' then leave.
    find first buf_gds-grp no-lock where
              buf_gds-grp.node-name = v-entry
          and buf_gds-grp.upper-code = v-upper-code
          no-error.
    if not available buf_gds-grp then do:
      undo, return error substitute("Не найдена подгруппа &1 в группе с вн. кодом &2", v-entry, v-upper-code).
    end.
    else do:
      p-node-code = buf_gds-grp.node-code.
      v-upper-code = buf_gds-grp.node-code.
    end.
  end.
end.
end .
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cli-grplib-get-full-name :
   define input parameter  p-node-code  as integer      no-undo.
   define output parameter p-full-name as character    no-undo.
do
on error undo, return error
:
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_cli-grp       for ub.cli-grp.
    define buffer buf_upper_cli-grp for ub.cli-grp.
    find first buf_cli-grp no-lock
         where buf_cli-grp.node-code = p-node-code
    no-error.
    if not available buf_cli-grp
    then do:
        undo, return error "cli-grplib-get-full-name: Не найдена группа клиентов с кодом " + string( p-node-code ).
    end.
    assign
        p-full-name  = ""
        v-upper-code = 1
    .
    do while buf_cli-grp.upper-code <> 0
    on error undo, return error "grplib-get-full-name: Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = buf_cli-grp.node-name
                         + (if p-full-name <> "" then chr(47) else "")
                         + p-full-name
            v-upper-code = buf_cli-grp.upper-code
        .
        find first buf_cli-grp no-lock
             where buf_cli-grp.node-code = v-upper-code
        no-error.
        if not available buf_cli-grp
        then do:
            undo, return error "cli-grplib-get-full-name: Не найдена группа клиентов с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
    assign
    p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
    .
end.
end .
procedure cgrplib-get-node-from-full-name :
define input parameter p-full-name as character no-undo .
define output parameter p-node-code as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-upper-code as integer no-undo .
define variable v-root-code as integer no-undo .
define variable v-entry as character no-undo .
define buffer buf_cli-grp       for ub.cli-grp.
do
on error undo, return error
:
  find first buf_cli-grp no-lock
      where buf_cli-grp.upper-code = 0
  no-error .
  if not available buf_cli-grp
  then do:
      undo, return error substitute("Не найдена корневая группа клиентов (upper-code = 0)").
  end.
  else do:
    assign
    v-root-code = buf_cli-grp.node-code
    .
  end.
  v-upper-code = v-root-code.
  do v-ii = 1 to num-entries(p-full-name, chr(47)):
    assign
    v-entry = entry(v-ii, p-full-name, chr(47)).
    if v-entry = '' then leave.
    find first buf_cli-grp no-lock where
              buf_cli-grp.node-name = v-entry
          and buf_cli-grp.upper-code = v-upper-code
          no-error.
    if not available buf_cli-grp then do:
      undo, return error substitute("Не найдена подгруппа &1 в группе с вн. кодом &2", v-entry, v-upper-code).
    end.
    else do:
      p-node-code = buf_cli-grp.node-code.
      v-upper-code = buf_cli-grp.node-code.
    end.
  end.
end.
end .
FUNCTION stat-line RETURNS CHARACTER
  (input p-status-chr as character )  FORWARD.
DEFINE MENU m-save
      MENU-ITEM m-gds-save      LABEL "Файл списка товаров"
      MENU-ITEM m-scn-save      LABEL "Файл ТСД"
      MENU-ITEM m-xls-save      LABEL "Таблица EXCEL"
      MENU-ITEM m-title-save    LABEL "Имя Списка"
      MENU-ITEM m-macros-save   LABEL "Макрос формирования списка"
      MENU-ITEM m-gds-save-db   LABEL "Хранимый в БД список товаров"
      MENU-ITEM m-macros-save-db   LABEL "Хранимый в БД макрос формирования списка"
      RULE
      MENU-ITEM m-rum           LABEL "Операции над списком"
      .
DEFINE MENU m-play
      MENU-ITEM m-macro-file    LABEL "Сохраненный в файле макрос формирования списка товаров"
      MENU-ITEM m-macro-lob     LABEL "Сохраненный в БД макрос формирования списка товаров"
      .
DEFINE BUTTON B-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "B-obj"
     SIZE 3 BY 1.
DEFINE BUTTON b-save
    LABEL "&Эксп./Вып.":L
    SIZE 10 BY 1
    tooltip "Сохр. список тов. в текст. файле, файле сканера, EXCEL; операции над списком".
DEFINE BUTTON b-add
    LABEL "&+Доб. строку":L
    SIZE 15 BY 1
    tooltip "Добавить в список товаров 1 строку".
DEFINE BUTTON b-del
    LABEL "&-Удал. строку":L
    SIZE 15 BY 1
    tooltip "Удалить из списка товаров текущую строки".
DEFINE BUTTON b-rest
    LABEL "&*Остав. строку":L
    SIZE 15 BY 1
    tooltip "Оставить в списке только текущую строку".
DEFINE BUTTON b-ext
    LABEL "":L
    SIZE 12 BY 1
    tooltip "Запустить внешнюю процедуру".
DEFINE BUTTON b-exit AUTO-GO
    LABEL "&Выход ":L
    SIZE 10 BY 1
    tooltip "Выход из списка товаров (передача списка другой программе)".
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
    tooltip "Печать списка товаров".
DEFINE BUTTON b-lkp
    LABEL "&Просмотр":L
    SIZE 10 BY 1
    tooltip "Просмотр описания текущего товара".
DEFINE BUTTON b-clr
    LABEL "&Oчистить":L
    SIZE 10 BY 1
    tooltip "Удалить из списка все товары (строки)".
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
DEFINE BUTTON b-arch
    LABEL "А&рхив":L
    SIZE 10 BY 1
    tooltip "Расчет итоговой информации по всему списку товаров".
DEFINE BUTTON B-sel
     LABEL "Вы&бор"
     SIZE 10 BY 1.
DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.
DEFINE VARIABLE dsp-rs AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
    SIZE 80 BY 1
    tooltip "Строка текущего состояния списка"
    FGCOLOR 4
    no-undo.
DEFINE VARIABLE f-tot-lns AS integer FORMAT ">>>>>>>>9":U
      VIEW-AS TEXT
    SIZE 10 BY 0.70
    tooltip "Кол. строк"
    FGCOLOR 4
    no-undo.
DEFINE VARIABLE RS-status AS character
    VIEW-AS RADIO-SET HORIZONTAL
    RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2",
"Item 3", "3"
    SIZE 34.75 BY 1 NO-UNDO.
DEF VAR loc-art AS CHAR VIEW-AS fill-in size 14 by 1
    tooltip "Начало артикула для поиска строки"
    fgcolor 12 no-undo.
DEF VAR loc-name AS CHAR VIEW-AS fill-in size 20 by 1
    tooltip "Начало названия товара для поиска строки"
    fgcolor 12 no-undo.
DEF VAR loc-code AS CHAR VIEW-AS fill-in size 20 by 1
    tooltip "Код (бар-код) для поиска строки"
    fgcolor 12 no-undo.
DEF VAR a-n-c AS CHAR VIEW-AS RADIO-SET horizontal  RADIO-BUTTONS
"&А","art",
"&Н","name",
"&К","code"
SIZE 12 BY 1
    tooltip "Выбор режима поиска: А - артикул, Н - начало названия, К - код (бар-код)"
    no-undo.
define variable v-obj-type as character view-as fill-in size  4 by 1 fgcolor 12 no-undo.
define variable v-obj-code as integer   view-as fill-in size  6 by 1 fgcolor 12 no-undo.
define variable v-obj-name as character view-as fill-in size 30 by 1 fgcolor 12 no-undo format "x(30)":U.
DEFINE QUERY BR-option FOR
      temp-list SCROLLING.
DEFINE BROWSE BR-option QUERY BR-option
DISPLAY
temp-list.fname format "X(255)"  width 60
WITH NO-LABELS SIZE 25 BY 22 ROW-HEIGHT-CHARS .57  separators
tooltip "Условие для выбора товаров, которые будут добавлены / удалены / оставлены в списке"
.
DEFINE QUERY br-list FOR gds-list-flt SCROLLING.
DEFINE BROWSE br-list QUERY br-list NO-LOCK DISPLAY
      gds-list-flt.to-sel  format "+/" column-label "*"
      gds-list-flt.gds-code FORMAT "99999999999":U
      gds-list-flt.artic
      gds-list-flt.gds-name
      gds-list-flt.unit-base column-label "Изм" format "x(3)"
      (if gds-list-flt.stts = 0 then no else yes) column-label "-" format "-/ "
      gds-list-flt.grp-name
      (gds-list-flt.prod-type + " " + string (gds-list-flt.prod-code, ">>>>>>>>>9") ) column-label "Производитель" format "x(9)"
      WITH SIZE 74 BY 16 separators.
DEFINE FRAME Dialog-Frame
    dsp-rs  AT ROW 1 COL 1 NO-LABEL
    b-help  AT ROW 1 COL 61
    br-option AT ROW 2 COL 75
    b-exit  AT ROW 2 COL 1
    b-save  AT ROW 2 COL 11
    b-print AT ROW 2 COL 21
    b-arch  AT ROW 2 COL 31
    b-hist  AT ROW 2 COL 41
    b-lkp   AT ROW 2 COL 51
    b-clr   AT ROW 2 COL 61
    b-mark  AT ROW 3 COL 1
    b-sel   AT ROW 3 COL 4
    a-n-c   at row 3 col 2 no-label
    b-add   AT ROW 3 COL 16
    b-del   AT ROW 3 COL 31
    b-rest  AT ROW 3 COL 46
    b-ext   AT ROW 3 COL 61
    v-obj-type at row 4 col 2 No-LABEL
    v-obj-code at row 4 col 6 No-LABEL
    b-obj at row 4 col 12
    v-obj-name at row 4 col 15 No-LABEL
    loc-art  AT ROW 4 COL 50 COLON-ALIGNED label "Начало артикула"
    loc-name AT ROW 4 COL 50 COLON-ALIGNED label "Начало названия" format "x(40)"
    loc-code AT ROW 4 COL 50 COLON-ALIGNED label "Бар-код (весь)" format "x(13)"
    b-macro AT ROW 4 col 68
    b-record AT ROW 4 col 71
    b-stop   AT ROW 4 col 71
    b-clear-macro AT ROW 4 col 71
    RS-status at row 5 col 2 no-label
    f-tot-lns AT ROW 5.25 col 65 no-label
    br-list  AT ROW 6 COL 1
    ub.clients.obj-name  at row 22 col 6 colon-aligned label "Пр-ль" fgcolor 4
    ub.gds-prt.node-name at row 22 col 40 colon-aligned label "Шкала" fgcolor 4
    ub.bar-code.b-code   at row 22 col 60 colon-aligned label "Код" format "9999999999" fgcolor 4
    SPACE(0) SKIP(0)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
        SIDE-LABELS NO-UNDERLINE THREE-D SCROLLABLE
        TITLE "СПИСОК  ТОВАРОВ":L
        DEFAULT-BUTTON b-exit.
ASSIGN
  b-save:POPUP-MENU IN FRAME Dialog-Frame = MENU m-save:HANDLE
  b-macro:POPUP-MENU IN FRAME Dialog-Frame = MENU m-play:HANDLE
  FRAME Dialog-Frame:SCROLLABLE = FALSE
  b-save:MENU-MOUSE = 1
  b-macro:menu-mouse = 1
  .
on
  return of
  br-list in frame Dialog-Frame do:
  apply "choose" to b-lkp in frame Dialog-Frame.
  return no-apply.
end.
on GO of frame Dialog-Frame do:
define variable glog as logical no-undo .
end.
on choose of b-obj in frame Dialog-Frame do:
  run proc-b-obj in this-procedure ( input "change":U ).
end.
ON CHOOSE OF b-save DO:
  run gbl/pop-up.p ( input self :handle, input no ) no-error.
  if error-status :error then do: return no-apply. end.
end.
ON CHOOSE OF MENU-ITEM m-title-save  DO:
define variable v-value as character no-undo .
  run gbl/d-prompt.w (
      'title=':u + "Введите ИМЯ СПИСКА ТОВАРОВ" + '\':u
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
run create-gds-list-flt-hist in this-procedure (input 'title'
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
frame Dialog-Frame:title = substitute("СПИСОК  ТОВАРОВ &1", v-value).
END.
ON CHOOSE OF MENU-ITEM m-gds-save  DO:
define variable glog as logical no-undo .
define variable vss-include-info24 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    f-name = "default.gds"
    glog = yes
    .
  system-dialog get-file f-name
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
  output to value (f-name).
  for each gds-list-flt:
    export gds-list-flt.prod-type
          gds-list-flt.prod-code
          gds-list-flt.artic
          gds-list-flt.qnty
          .
  end.
  output close.
END.
ON CHOOSE OF MENU-ITEM m-gds-save-db  DO:
define variable v-rid-list as character no-undo .
define variable vss-include-info25 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
run m-gds-save-db-proc in this-procedure .
END.
ON CHOOSE OF MENU-ITEM m-scn-save  DO:
define variable vss-include-info26 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info27 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
ON CHOOSE OF MENU-ITEM m-macros-save-db  DO:
define variable vss-include-info28 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
run m-macros-save-db-proc in this-procedure .
END.
ON CHOOSE OF MENU-ITEM m-xls-save  DO:
define variable glog as logical no-undo .
define variable vss-include-info29 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run str/gdsl-xls.p (parparentproc, p-curr-obj-type, p-curr-obj-code) no-error.
  run waitfram-hide in this-procedure .
end.
END.
ON CHOOSE OF MENU-ITEM m-rum  DO:
define variable glog as logical no-undo .
define variable vss-include-info30 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
run str/diallog.w (
      input parParentProc
    , input this-procedure
    , input "utl/thbjrumr.w":U
    , input 'goods':U + chr(4) +
            ('batchwork-export':U + chr(44) + 'batchwork-routing':U)
    , input no
    , input "&Стоп"
    , input substitute("Операции на списком товаров") ) .
END.
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref31 as character no-undo .
define variable varpgscales-pref31 as character no-undo.
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref-type32 as character no-undo.
varscales-pref31  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'sclspref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varscales-pref31
  ,output varscales-pref-type32
  ) no-error .
if varscales-pref31 = ? then do:
  assign
  varscales-pref31 = '21,23,25':U.
end.
define variable varpgscales-pref-type32 as character no-undo.
varpgscales-pref31  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'scpgpref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varpgscales-pref31
  ,output varpgscales-pref-type32
  ) no-error .
if varpgscales-pref31 = ? then do:
  assign
  varpgscales-pref31 = '24IIIIIQQ000C,28IIIIIQQQ00C':U.
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
ON return, Ctrl-J OF loc-name IN FRAME Dialog-Frame do:
  run proc-mouse-dbl-click-loc-name in this-procedure   no-error.
  return no-apply.
end.
PROCEDURE proc-valchg-a-n-c:
  case input frame Dialog-Frame a-n-c :
    when "art" then do:
      apply "entry" to br-list in frame Dialog-Frame.
      hide loc-name loc-code
      in frame Dialog-Frame.
      loc-art = "".
    end.
    when "name" then do:
      enable loc-name with frame Dialog-Frame.
      disp loc-name with frame Dialog-Frame.
      hide loc-art loc-code
      in frame Dialog-Frame.
      apply "entry" to loc-name in frame Dialog-Frame.
    end.
    when "code"
 or when "DataMatrix" then
    do:
      enable loc-code with frame Dialog-Frame.
      disp loc-code with frame Dialog-Frame.
      hide loc-art loc-name
      in frame Dialog-Frame.
      apply "entry" to loc-code in frame Dialog-Frame.
    end.
  end CASE.
END PROCEDURE.
PROCEDURE proc-any-printable-br-list :
  if input frame Dialog-Frame a-n-c = "art" then do:
    if last-event:label = " " and
       loc-art = "" then
    return error.
    find first l-gds-list-flt where
                l-gds-list-flt.artic begins (loc-art + last-event:label)
               no-lock no-error.
    if available l-gds-list-flt then do:
      loc-art = loc-art + last-event:label.
      disp loc-art with frame Dialog-Frame.
      line-rec = recid (l-gds-list-flt).
      reposition br-list to recid line-rec no-error.
    end.
  end.
END PROCEDURE.
PROCEDURE proc-backspace-br-list:
  if input frame Dialog-Frame a-n-c = "art" then do:
    if loc-art = "" then
      return error.
    loc-art = substr (loc-art, 1, length (loc-art) - 1).
    find first l-gds-list-flt where
                l-gds-list-flt.artic begins loc-art
               no-lock.
    disp loc-art with frame Dialog-Frame.
    line-rec = recid (l-gds-list-flt).
    reposition br-list to recid line-rec no-error.
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
  assign
  frame Dialog-Frame
  loc-code
  a-n-c.
  if a-n-c = "datamatrix"
  then do:
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_dm-rcnz in g#libbcrcn
(
 input  parparentproc
,input  loc-code
,input  ?
,input  p-curr-obj-type
,input  p-curr-obj-code
,input  yes
,input  no
,input  varscales-pref31
,input  varpgscales-pref31
,output varresult
,output vartype-bc
,output varweight
,buffer buf_bar-code
,buffer buf_prod-bc
,buffer buf_place
) no-error.
     if varresult eq "prod-bc"
     then
        loc-code:screen-value in frame Dialog-Frame = buf_prod-bc.b-str.
  end.
  else do:
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_bc-rcnz in g#libbcrcn
(
 input  parparentproc
,input  loc-code
,input  ?
,input  p-curr-obj-type
,input  p-curr-obj-code
,input  yes
,input  no
,input  varscales-pref31
,input  varpgscales-pref31
,output varresult
,output vartype-bc
,output varweight
,buffer buf_bar-code
,buffer buf_prod-bc
,buffer buf_place
) no-error.
end.
  if available buf_bar-code then do:
        find first l-goods where
                  l-goods.gds-code =
  buf_bar-code.gds-code No-LOCK.
        find first l-gds-list-flt where
                  l-gds-list-flt.artic = l-goods.artic AND
                  l-gds-list-flt.prod-type = l-goods.prod-type AND
                  l-gds-list-flt.prod-code = l-goods.prod-code no-lock no-error.
    if available l-gds-list-flt then do:
      line-rec = recid (l-gds-list-flt).
      reposition br-list to recid line-rec no-error.
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
PROCEDURE  proc-mouse-dbl-click-loc-name:
  assign
  frame Dialog-Frame
  loc-name.
    if last-event:label = "Ctrl-J" then
      find next l-gds-list-flt where
                can-find (ub.goods where ub.goods.artic = l-gds-list-flt.artic and
                ub.goods.prod-type = l-gds-list-flt.prod-type and
                ub.goods.prod-code = l-gds-list-flt.prod-code and
                ub.goods.gds-name begins loc-name no-lock) no-lock no-error.
    else
      find first l-gds-list-flt where
                can-find (ub.goods where ub.goods.artic = l-gds-list-flt.artic and
                ub.goods.prod-type = l-gds-list-flt.prod-type and
                ub.goods.prod-code = l-gds-list-flt.prod-code and
                ub.goods.gds-name begins loc-name no-lock) no-lock no-error.
    if available l-gds-list-flt then do:
      line-rec = recid (l-gds-list-flt).
      reposition br-list to recid line-rec no-error.
    end.
    else do:
      message "Строка не найдена."
              view-as alert-box error.
    end.
  apply "entry" to loc-name in frame Dialog-Frame.
END PROCEDURE.
on value-changed of br-list in frame Dialog-Frame do:
if not available gds-list-flt or recid (gds-list-flt) <> line-rec then do:
    hide loc-art in frame Dialog-Frame.
    loc-art = "".
end.
if available gds-list-flt then do:     find ub.clients where ub.clients.obj-type = gds-list-flt.prod-type                    and ub.clients.obj-code = gds-list-flt.prod-code no-lock.     find ub.gds-prt where ub.gds-prt.upper-code = gds-list-flt.prt-root no-lock.     find ub.bar-code where ub.bar-code.gds-code  = gds-list-flt.gds-code                     and ub.bar-code.node-code = ub.gds-prt.node-code                     and ub.bar-code.unit-cli  = gds-list-flt.unit-base                     and ub.bar-code.in-code   = ""                     and ub.bar-code.part-code = "" no-lock.     disp ub.clients.obj-name ub.gds-prt.node-name ub.bar-code.b-code tot-lns @ f-tot-lns with frame Dialog-Frame.   end.   else display f-tot-lns with frame Dialog-Frame.
end.
ON CHOOSE OF b-print IN FRAME Dialog-Frame DO:
run rep/pri-lst.w (
                input parparentproc
              , input p-curr-obj-type
              , input p-curr-obj-code
              , input "ALL"
              , input "gds-list"
              ).
apply "entry" to br-list in frame Dialog-Frame.
END.
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame DO:
if not available gds-list-flt then do:
  message "Неправильно выбран товар."
          view-as alert-box error.
  return no-apply.
end.
find ub.goods where gds-list-flt.artic = ub.goods.artic
            and gds-list-flt.prod-type = ub.goods.prod-type
            and gds-list-flt.prod-code = ub.goods.prod-code no-lock.
run str/showgds.p (input parparentproc
                  ,input this-procedure:handle
                  ,input ub.goods.gds-code
                  ,input 'ПРОСМОТР':U).
apply "entry" to br-list in frame Dialog-Frame.
END.
ON CHOOSE OF b-hist IN FRAME Dialog-Frame DO:
define buffer buf_gds-list-flt-hist for gds-list-flt-hist.
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input 43
                                            ,input yes
                                            ,input no
                                            ).
find first buf_gds-list-flt-hist no-lock where buf_gds-list-flt-hist.id = 0 no-error .
PUT  STREAM PrnLibStream unformatted
SPACE(25) "История создания списка товаров "
(if available buf_gds-list-flt-hist
then buf_gds-list-flt-hist.des
else "БЕЗЫМЯННЫЙ") skip(0)
space(25) cur-time-print() skip(1)
.
put stream PrnLibStream unformatted
string("№", "X(9)") chr(32)
string("Действие", "X(9)") chr(32)
string("записей", "X(9)") chr(32)
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
for each buf_gds-list-flt-hist where buf_gds-list-flt-hist.id > 0
by buf_gds-list-flt-hist.id
:
  put stream PrnLibStream unformatted
  (if buf_gds-list-flt-hist.line = 0
   then string(buf_gds-list-flt-hist.id, ">>>>>>>>9")
   else fill(chr(32) , 9)
  )  chr(32)
  (if buf_gds-list-flt-hist.item_ <> '':U
   then string(buf_gds-list-flt-hist.hist-mode, "X(8)")
   else fill( chr(32), 8)) chr(32)
  string(buf_gds-list-flt-hist.num-add, ">>>>>>>>9") chr(32) chr(32) chr(32) chr(32)
  string(buf_gds-list-flt-hist.num-recs, ">>>>>>>>9")  chr(32)
  string(buf_gds-list-flt-hist.des, "X(155)") skip.
end.
output stream prnlibstream close.
  run prn-lib-prn-file in this-procedure (
                                            input parParentProc
                                            ,input 8
                                            ).
  apply "entry" to br-list in frame Dialog-Frame.
END.
ON CHOOSE OF b-ext IN FRAME Dialog-Frame DO:
    define buffer buf_goods     for ub.goods.
    define buffer buf_gds-list-flt       for gds-list-flt.
    define variable v-goods-recid     as recid         no-undo.
    for each temp_recid-list
    :
        delete temp_recid-list.
    end.
    if available gds-list-flt
    then do:
        find first buf_goods no-lock
            where buf_goods.gds-code     = gds-list-flt.gds-code
        .
        v-goods-recid = recid( buf_goods ).
        for each buf_gds-list-flt
        :
            find first buf_goods no-lock
                where buf_goods.gds-code = buf_gds-list-flt.gds-code
            .
            create temp_recid-list .
            assign
                temp_recid-list.string-goods-recid = string( recid( buf_goods ) )
            .
        end.
    end.
    else do:
        assign
            v-goods-recid = 0
        .
    end.
    run str/run-ext.p ( input v-goods-recid
                  , input table temp_recid-list
                  , input 'ТОВАР':U
                  , input ""
                  , output v-ext-button-label
                  ) no-error.
    if error-status :error
    then do:
        return no-apply .
    end.
END.
ON CHOOSE OF b-arch IN FRAME Dialog-Frame DO:
run list_inf-local in this-procedure .
apply "entry" to br-list in frame Dialog-Frame.
END.
ON CHOOSE OF b-clr IN FRAME Dialog-Frame  DO:
define variable glog as logical no-undo .
define buffer buf-gds-list-flt-hist for gds-list-flt-hist.
glog = no.
message "Удаление всех строк списка. Вы уверены ?"
        view-as alert-box question buttons OK-Cancel update glog.
if not glog then return no-apply.
if session:set-wait-state( "COMPILER" )  then .
for each gds-list-flt:
  delete gds-list-flt.
end.
if session:set-wait-state( "" )  then .
tot-lns = 0.
v-seq = 1.
for each buf-gds-list-flt-hist:
  delete buf-gds-list-flt-hist.
end.
run create-gds-list-flt-hist in this-procedure (input 'ДОБАВЛЕНИЕ':U
                                     , input-output v-seq
                                     , input 0
                                     , input '0':U
                                     , input "# Список товаров очищен."
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
run UI-on in this-procedure .
END.
ON VALUE-CHANGED OF RS-Status IN FRAME Dialog-Frame DO:
  assign
  RS-status.
END.
define variable vss-include-info33 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-P, CTRL-З of frame Dialog-Frame anywhere do:
  if b-print :sensitive then DO: apply "CHOOSE":U to b-print in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info34 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F3 of frame Dialog-Frame anywhere do:
  if b-lkp :sensitive then DO: apply "CHOOSE":U to b-lkp in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info35 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-N, CTRL-Т of frame Dialog-Frame anywhere do:
  if b-add :sensitive then DO: apply "CHOOSE":U to b-add in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info36 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F8 of frame Dialog-Frame anywhere do:
  if b-del :sensitive then DO: apply "CHOOSE":U to b-del in frame Dialog-Frame. END.
  return no-apply.
end.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
def var vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define buffer buf-gds-list-flt-hist for gds-list-flt-hist.
define buffer buf_macro-list-hist for macro-list-hist.
define buffer buf_keep-macro-list-hist for keep-macro-list-hist.
 if p-keep-query then do:
    glog = no.
    message "Реинициализация списка. Вы уверены ?"
            view-as alert-box question buttons OK-Cancel update glog.
    if not glog then return no-apply.
    if session:set-wait-state( "COMPILER" )  then .
    for each gds-list-flt:
      delete gds-list-flt.
    end.
    if session:set-wait-state( "" )  then .
    tot-lns = 0.
    v-seq = 1.
    for each buf-gds-list-flt-hist:
      delete buf-gds-list-flt-hist.
    end.
   for each buf_keep-macro-list-hist:
     create buf_macro-list-hist.
   end.
   run proc-macro-play in this-procedure ( input 0, input yes, input 0).
   run create-gds-list-flt-hist in this-procedure (
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
    ? @ ub.clients.obj-name
    ? @ ub.gds-prt.node-name
    ? @ ub.bar-code.b-code
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
  if not available gds-list-flt then return no-apply.
  assign rs-list-method = "single".
    run proc-b-del in this-procedure(
                                               input no
                                              ,input ?
                                              ,input rs-list-method
                                              ,input rs-status) no-error .
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-rest IN FRAME Dialog-Frame
DO:
if not available gds-list-flt then return no-apply.
  assign rs-list-method = "single".
 run proc-b-rest in this-procedure(
                                                input no
                                               ,input ?
                                               ,input rs-list-method
                                               ,input rs-status) no-error .
  if error-status:error then return no-apply.
END.
on choose of MENU-ITEM m-macro-file in menu m-play DO:
  assign
  macro-play-option = 'file':U.
  APPLY "CHOOSE" to b-macro in frame Dialog-Frame.
end.
on choose of MENU-ITEM m-macro-lob in menu m-play DO:
  assign
  macro-play-option = 'lob':U.
  APPLY "CHOOSE" to b-macro in frame Dialog-Frame.
end.
ON CHOOSE OF B-macro IN FRAME Dialog-Frame
DO:
if macro-play-option = '':U then do:
      run gbl/pop-up.p ( input self:handle, input no) no-error.
end.
if macro-play-option = '':U then return no-apply.
run proc-b-macro in this-procedure ( input macro-play-option) no-error .
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
  menu-item m-macro-file:label in menu m-play = "Ранее записанный макрос формирования списка товаров".
  menu-item m-macro-lob:sensitive in menu m-play = no.
disable
b-record with frame Dialog-Frame .
hide
b-record
b-macro
in frame Dialog-Frame .
enable
b-stop with frame Dialog-Frame .
run create-gds-list-flt-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
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
define buffer buf_gds-list-flt-hist for gds-list-flt-hist.
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
run create-gds-list-flt-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
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
for each buf_gds-list-flt-hist where
        buf_gds-list-flt-hist.id >=  an-listp-start-macro-id
  and  buf_gds-list-flt-hist.id <=  an-listp-end-macro-id:
  create macro-list-hist.
  buffer-copy buf_gds-list-flt-hist
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
menu-item m-macro-lob:sensitive in menu m-play = yes.
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
      v-num-entries-options = num-entries("Текущая строка,single,                           Товар,goods,                                      Товар ТСД,tsd,                                      Товар-объект,gds-obj,                             Товар-объект-факт,gds-obj-fact,                   Товар-объект-своб,gds-obj-free,                   Файл,file,                                        Хранимый в БД список,clob-data,                     Фильтр,filter,                                    Все,all,                                          Группа товаров,gds-grp,                           Производитель,producer,                           Группа пр-лей,grp-prod,                           Поставщик,supplier,                               Группа пост-ков,grp-supp,                         Объект,object,                                    В наличии,available,                              Переоценка,overvalue,                             ДНЦ,pdf,                                          Документ,waybill,                                 Производство,manufacture,                         Товары Рецепта,recipe,                            Рецепта,self-recipe,                              Контрагент,client,                                Консигнант,consignee,                             Договор,contract,                                 Отриц. остатки,neg-rest,                          Отриц. партии все,neg-part,                       Отриц. партии своб.,neg-part-free,                Отриц. признаки,neg-prt,                          Нулев. остатки,nul-rest,                          Топливо,is-ptrl,                                  Услуга,gds-office,                                С типом скидки,dis-gds-rule,                      Правило скидки = ,dis-gds-rule-num,               Имеют Атрибут РЕСТОРАНА на объ.,fbr-gds-obj,      Атрибут РЕСТОРАНА на объ.=,fbr-gds-obj-val,       С атриб. на объекте,gds-obj-attr,                 Атрибут на объ.= ,gds-obj-attr-val,               С атриб. на фирме,gds-host-attr,                  Атрибут на фирме= ,gds-host-attr-val,             С глоб. атрибутом,goods-attr,                     Глобальный атрибут= ,goods-attr-val,              Налог= у всех тов.,tax-rate-value,                Налог= у тов.объ.,tax-rate-value-obj,             Проходившие,input,                                С ценами>0,with-price,                            Треб. переоценки,ov-req,                          Треб. инвентар-и,inv-req,                         Мобильн. сканер,scaner,                           Цены эталона,etalon,                              Товары на весах,scales-gds,                       Товары на весах №,scales-gds-num,                 Просроч.партии своб.зоны,parts-last-date,         ФиБ партии своб.зоны,parts-fib,         Товары с продажей по партиям, cashparts,          Список док-тов,doc-list,                          Список произ-лей,prod-list,                       Список пост-ков,supp-list,                        Список контр-тов,cli-list,                        Ассорт.Матрицы,ass-matr,                          Ассорт.Минимумы,ass-min,                          ИЖТ на объ.,izt,                                  ABC-анализы,abc-analysis,                         XYZ-анализы,xyz-analysis,                         ABC-XYZ-анализы,abcxyz,                           Коллекции,collection,                             Нет ингредиентов рецептов,no-recipe-gds,           Неактивные,deleted,                                Виды алкогольной продукции,choose-alc-prod,        С движением за период с:,move-date")
    .
    do v-index = 1 to v-num-entries-options by 2
    :
      create temp-list.
      assign
        temp-list.fname  = trim(entry(v-index
                                     ,"Текущая строка,single,                           Товар,goods,                                      Товар ТСД,tsd,                                      Товар-объект,gds-obj,                             Товар-объект-факт,gds-obj-fact,                   Товар-объект-своб,gds-obj-free,                   Файл,file,                                        Хранимый в БД список,clob-data,                     Фильтр,filter,                                    Все,all,                                          Группа товаров,gds-grp,                           Производитель,producer,                           Группа пр-лей,grp-prod,                           Поставщик,supplier,                               Группа пост-ков,grp-supp,                         Объект,object,                                    В наличии,available,                              Переоценка,overvalue,                             ДНЦ,pdf,                                          Документ,waybill,                                 Производство,manufacture,                         Товары Рецепта,recipe,                            Рецепта,self-recipe,                              Контрагент,client,                                Консигнант,consignee,                             Договор,contract,                                 Отриц. остатки,neg-rest,                          Отриц. партии все,neg-part,                       Отриц. партии своб.,neg-part-free,                Отриц. признаки,neg-prt,                          Нулев. остатки,nul-rest,                          Топливо,is-ptrl,                                  Услуга,gds-office,                                С типом скидки,dis-gds-rule,                      Правило скидки = ,dis-gds-rule-num,               Имеют Атрибут РЕСТОРАНА на объ.,fbr-gds-obj,      Атрибут РЕСТОРАНА на объ.=,fbr-gds-obj-val,       С атриб. на объекте,gds-obj-attr,                 Атрибут на объ.= ,gds-obj-attr-val,               С атриб. на фирме,gds-host-attr,                  Атрибут на фирме= ,gds-host-attr-val,             С глоб. атрибутом,goods-attr,                     Глобальный атрибут= ,goods-attr-val,              Налог= у всех тов.,tax-rate-value,                Налог= у тов.объ.,tax-rate-value-obj,             Проходившие,input,                                С ценами>0,with-price,                            Треб. переоценки,ov-req,                          Треб. инвентар-и,inv-req,                         Мобильн. сканер,scaner,                           Цены эталона,etalon,                              Товары на весах,scales-gds,                       Товары на весах №,scales-gds-num,                 Просроч.партии своб.зоны,parts-last-date,         ФиБ партии своб.зоны,parts-fib,         Товары с продажей по партиям, cashparts,          Список док-тов,doc-list,                          Список произ-лей,prod-list,                       Список пост-ков,supp-list,                        Список контр-тов,cli-list,                        Ассорт.Матрицы,ass-matr,                          Ассорт.Минимумы,ass-min,                          ИЖТ на объ.,izt,                                  ABC-анализы,abc-analysis,                         XYZ-анализы,xyz-analysis,                         ABC-XYZ-анализы,abcxyz,                           Коллекции,collection,                             Нет ингредиентов рецептов,no-recipe-gds,           Неактивные,deleted,                                Виды алкогольной продукции,choose-alc-prod,        С движением за период с:,move-date"
                                     )
                               ,chr(32)
                               )
        temp-list.fvalue = trim(entry(v-index + 1
                                     ,"Текущая строка,single,                           Товар,goods,                                      Товар ТСД,tsd,                                      Товар-объект,gds-obj,                             Товар-объект-факт,gds-obj-fact,                   Товар-объект-своб,gds-obj-free,                   Файл,file,                                        Хранимый в БД список,clob-data,                     Фильтр,filter,                                    Все,all,                                          Группа товаров,gds-grp,                           Производитель,producer,                           Группа пр-лей,grp-prod,                           Поставщик,supplier,                               Группа пост-ков,grp-supp,                         Объект,object,                                    В наличии,available,                              Переоценка,overvalue,                             ДНЦ,pdf,                                          Документ,waybill,                                 Производство,manufacture,                         Товары Рецепта,recipe,                            Рецепта,self-recipe,                              Контрагент,client,                                Консигнант,consignee,                             Договор,contract,                                 Отриц. остатки,neg-rest,                          Отриц. партии все,neg-part,                       Отриц. партии своб.,neg-part-free,                Отриц. признаки,neg-prt,                          Нулев. остатки,nul-rest,                          Топливо,is-ptrl,                                  Услуга,gds-office,                                С типом скидки,dis-gds-rule,                      Правило скидки = ,dis-gds-rule-num,               Имеют Атрибут РЕСТОРАНА на объ.,fbr-gds-obj,      Атрибут РЕСТОРАНА на объ.=,fbr-gds-obj-val,       С атриб. на объекте,gds-obj-attr,                 Атрибут на объ.= ,gds-obj-attr-val,               С атриб. на фирме,gds-host-attr,                  Атрибут на фирме= ,gds-host-attr-val,             С глоб. атрибутом,goods-attr,                     Глобальный атрибут= ,goods-attr-val,              Налог= у всех тов.,tax-rate-value,                Налог= у тов.объ.,tax-rate-value-obj,             Проходившие,input,                                С ценами>0,with-price,                            Треб. переоценки,ov-req,                          Треб. инвентар-и,inv-req,                         Мобильн. сканер,scaner,                           Цены эталона,etalon,                              Товары на весах,scales-gds,                       Товары на весах №,scales-gds-num,                 Просроч.партии своб.зоны,parts-last-date,         ФиБ партии своб.зоны,parts-fib,         Товары с продажей по партиям, cashparts,          Список док-тов,doc-list,                          Список произ-лей,prod-list,                       Список пост-ков,supp-list,                        Список контр-тов,cli-list,                        Ассорт.Матрицы,ass-matr,                          Ассорт.Минимумы,ass-min,                          ИЖТ на объ.,izt,                                  ABC-анализы,abc-analysis,                         XYZ-анализы,xyz-analysis,                         ABC-XYZ-анализы,abcxyz,                           Коллекции,collection,                             Нет ингредиентов рецептов,no-recipe-gds,           Неактивные,deleted,                                Виды алкогольной продукции,choose-alc-prod,        С движением за период с:,move-date"
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
define buffer buf_gds-list-flt-hist for gds-list-flt-hist.
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
        for each buf_gds-list-flt-hist where
                buf_gds-list-flt-hist.id >=  an-listp-start-macro-id
          and  buf_gds-list-flt-hist.id <=  an-listp-end-macro-id:
          create macro-list-hist.
          buffer-copy buf_gds-list-flt-hist
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
        filters "Макрос формирования списка *.gdm" "*.gdm"
        title "Выберите файл макроса"
        INITIAL-DIR "."
        return-to-start-dir
        must-exist
        update glog
        default-extension "gdm".
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
                              ,input 'gds-list'
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
    run create-gds-list-flt-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
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
                ,input "Макрос формирования списка товаров" + chr(4) + "gdm"
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
    menu-item m-macro-file:label in menu m-play = "Сохраненный в файле макрос формирования списка товаров".
    menu-item m-macro-lob:sensitive in menu m-play = yes.
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
    run create-gds-list-flt-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
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
define  buffer buf_gds-list-flt-hist for gds-list-flt-hist.
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
        for each gds-list-flt:
          delete gds-list-flt.
        end.
        for each gds-list-flt-hist where gds-list-flt-hist.id > an-listp-macros-label-id:
          delete gds-list-flt-hist.
        end.
        tot-lns = 0.
        v-seq = an-listp-macros-label-id + 1.
        v-no-hist = 0.
        create buf_gds-list-flt-hist.
        buffer-copy macro-list-hist
        to buf_gds-list-flt-hist
        assign buf_gds-list-flt-hist.id = v-seq
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
          find first  buf_gds-list-flt-hist where
                  buf_gds-list-flt-hist.id = v-seq - 1 no-error .
          if available buf_gds-list-flt-hist then
          assign
          macro-list-hist.num-recs = buf_gds-list-flt-hist.num-recs
          macro-list-hist.num-add = buf_gds-list-flt-hist.num-add
          macro-list-hist.num-ignored = buf_gds-list-flt-hist.num-ignored
          .
        end.
        else do:
          return ("error" + chr(4) + return-value).
        end.
      end.
      otherwise do:
        if can-find(first temp-list where temp-list.fvalue = macro-list-hist.option_)
        or lookup(macro-list-hist.option_, '':U) > 0
        then do:
          if macro-list-hist.line = 0 then do:
            v-no-hist = 0.
            for each buf_macro-list-hist where
                    buf_macro-list-hist.id = v-id:
              create buf_gds-list-flt-hist.
              buffer-copy buf_macro-list-hist
              except id  num-recs num-add num-ignored done
              to buf_gds-list-flt-hist
              assign
              buf_gds-list-flt-hist.id = (if buf_macro-list-hist.line =0 then v-seq else v-temp-seq)
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
            for each buf_gds-list-flt-hist where
                    buf_gds-list-flt-hist.id = v-temp-seq,
               first buf_macro-list-hist where
                    buf_macro-list-hist.id = v-id
                AND buf_macro-list-hist.line = buf_gds-list-flt-hist.line:
               assign
               buf_macro-list-hist.num-recs = buf_gds-list-flt-hist.num-recs
               buf_macro-list-hist.num-add = buf_gds-list-flt-hist.num-add
               buf_macro-list-hist.num-ignored = buf_gds-list-flt-hist.num-ignored
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
    for each gds-list-flt:
      if gds-list-flt.to-del = ? then do:
        assign
        gds-list-flt.to-del = no
        .
      end.
      else do:
        delete gds-list-flt.
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
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
DO:
define variable glog as logical no-undo .
define buffer buf_gds-list-flt for gds-list-flt.
if available gds-list-flt then   do:
  find first buf_gds-list-flt where
           recid(buf_gds-list-flt) = recid(gds-list-flt).
  assign
  buf_gds-list-flt.to-sel = not (buf_gds-list-flt.to-sel).
  glog = br-list:refresh().
  if LOOKUP(last-event:function,  "MOUSE-SELECT-DBLCLICK,RETURN":U) = 0  then  do:
     glog = br-list:select-next-row ().
     APPLY "VALUE-CHANGED" to br-list.
  end.
end.
APPLY "ENTRY" to br-list in frame Dialog-Frame .
END.
ON CHOOSE OF B-sel IN FRAME Dialog-Frame
DO:
define buffer buf_gds-list-flt for gds-list-flt.
if not available gds-list-flt then return no-apply.
find first buf_gds-list-flt where
          recid(buf_gds-list-flt) = recid(gds-list-flt).
assign
buf_gds-list-flt.to-sel = not (buf_gds-list-flt.to-sel)
.
APPLY "CHOOSE" to b-exit.
END.
if lookup(bttns, "hide") = 0 then do:
  run diasize_add_browse in this-procedure
    (input  'height':u
    ,input  browse BR-option :handle
    ) .
  run diasize_init in this-procedure .
end.
define variable v-ok as logical   no-undo .
assign
  v-ok = br-list :set-repositioned-row(5, 'conditional':u)
.
ON WINDOW-CLOSE OF FRAME Dialog-Frame APPLY "END-ERROR":U TO SELF.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref-type43 as character no-undo.
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
  ,output varscales-pref-type43
  ) no-error .
if varscales-pref = ? then do:
  assign
  varscales-pref = '21,23,25':U.
end.
define variable varpgscales-pref-type43 as character no-undo.
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
  ,output varpgscales-pref-type43
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
  if g#auto then do:
    v-no-context = yes.
  end.
  else do:
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  end.
  run get-report-num in parparentproc ( output g#report-num ).
  if p-curr-obj-type = '':U
  and p-curr-obj-code = 0 then do:
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      find first buf_clients no-lock where
                buf_clients.obj-type = v-sel-obj-type
            and buf_clients.obj-code = v-sel-obj-code no-error.
      if not available buf_clients then return error.
      assign
      p-curr-obj-type = buf_clients.obj-type
      p-curr-obj-code = buf_clients.obj-code
      p-curr-host-code = buf_clients.host-code
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
      or buf_clients.host-code <> p-curr-host-code
      )
    then do:
      assign
      p-curr-obj-type = '':U
      p-curr-obj-code = 0
      p-curr-host-code = 0
      .
      message
      vss-workfile vss-revision vss-description skip
      "Неверно заданы входные параметры p-curr-host-code и/или p-curr-obj-type и/или p-curr-obj-code"
      p-curr-host-code p-curr-obj-type p-curr-obj-code
      view-as alert-box error .
      undo main-block, return error.
    end.
  end.
define variable vss-include-info46 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_documents_all':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-docs-all
    )  .
end.
define variable vss-include-info47 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_documents_company':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-docs-cmp
    )  .
end.
  assign
  br-option:column-scrolling in frame Dialog-Frame  = no
  gds-list-flt.gds-name:resizable in browse br-list = true
  gds-list-flt.grp-name:resizable in browse br-list = true
  RS-status:radio-buttons = "Текущие&+" + chr(44) + 'текущие':U + chr(44) +
                            "Все!" + chr(44) + 'все':U + chr(44) +
                            "Неактивные-" + chr(44) + 'удаленные':U
  RS-status = 'текущие':U
  .
    run proc-fill-temp-list in this-procedure .
  if v-no-obj
  or v-cntxt-level <> 'object':U then do:
    if v-obj-name = "":U then do:
      run proc-b-obj in this-procedure ( input "":U ).
    end.
    if lookup(bttns, "hide") = 0 then do:
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
  end.
  if lookup(bttns, "hide") > 0 then do:
    return.
  end.
  run UI-on in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame focus br-list.
END.
HIDE FRAME Dialog-Frame.
PROCEDURE UI-on:
define variable v-recid0 as recid no-undo.
define variable v-start as logical no-undo .
define buffer buf_temp-list for temp-list.
define buffer buf_gds-list-flt-hist for gds-list-flt-hist.
  find first buf_gds-list-flt-hist where buf_gds-list-flt-hist.id = 0 no-error.
  if available buf_gds-list-flt-hist then
  assign
  frame Dialog-Frame:title = substitute("СПИСОК  ТОВАРОВ &1",  string(buf_gds-list-flt-hist.des, "X(60)"))
  .
  if tot-lns = ? then do:
    v-start = yes.
    for each l-gds-list-flt :
      accumulate l-gds-list-flt.artic (count).
    end.
    tot-lns = (accum count l-gds-list-flt.artic).
    if tot-lns > 0 then do:
      find last  buf_gds-list-flt-hist no-error .
      v-seq = (if available buf_gds-list-flt-hist then buf_gds-list-flt-hist.id else 0)  + 1.
      run create-gds-list-flt-hist in this-procedure (input 'ДОБАВЛЕНИЕ':U
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
      for each buf_gds-list-flt-hist:
        delete buf_gds-list-flt-hist.
      end.
      v-seq = 1.
      run create-gds-list-flt-hist in this-procedure (input 'ДОБАВЛЕНИЕ':U
                                           , input-output v-seq
                                           , input 0
                                           , input '':U
                                           , input "# Исходный список товаров пуст."
                                           , input tot-lns
                                           , input 'start':U
                                           , input '':U
                                           , input '':U
                                           , input '':U
                                           , input ?
                                           ).
    end.
  end.
  hide loc-art in frame Dialog-Frame loc-name loc-code in frame Dialog-Frame.
  assign
  loc-art = ""
  RS-list-method = "single"
  .
  find first buf_temp-list no-lock where
             buf_temp-list.fvalue = rs-list-method.
  assign
  v-recid0 = recid(buf_temp-list).
  open query br-option for each temp-list no-lock .
  if v-seq > 1 then
  find last buf_gds-list-flt-hist no-lock where
            buf_gds-list-flt-hist.id = (v-seq - 1)
       and  buf_gds-list-flt-hist.line = 0 no-error .
  DISPLAY br-option
  (if available buf_gds-list-flt-hist
  then buf_gds-list-flt-hist.des
  else '') @ dsp-rs
  RS-Status WITH FRAME Dialog-Frame.
  ENABLE
  b-macro  when v-start
  b-record when v-start
  b-exit b-add b-hist b-help br-option br-list RS-Status WITH FRAME Dialog-Frame.
  if v-start then do:
    hide
    b-sel
    b-mark
    b-stop
    b-clear-macro
    in frame Dialog-Frame.
    if lookup("b-sel", bttns) > 0
    or lookup("b-mark", bttns) > 0
    then do:
      gds-list-flt.to-sel:visible in browse br-list = yes.
    end.
    else do:
      gds-list-flt.to-sel:visible in browse br-list = no.
    end.
    if bttns <> '':U then do:
      run proc-expand in this-procedure ( input 1, input b-sel:row, input br-list:row, input "b-sel,b-mark").
    end.
  end.
  v-start = no.
  if is-tsd = no then do:
    menu-item m-scn-save:sensitive in menu m-save = no.
  end.
  reposition br-option to recid v-recid0.
  if tot-lns > 0 then do:
    Enable b-print b-arch b-rest b-save b-del b-lkp b-clr a-n-c
    b-mark when lookup("b-mark", bttns) > 0
    b-sel  when lookup("b-sel", bttns) > 0
    WITH FRAME Dialog-Frame.
  end.
  else do:
    DISABLE b-print b-arch b-rest b-save b-del b-lkp b-clr a-n-c
    b-mark b-sel
    WITH FRAME Dialog-Frame.
  end.
  open query br-list for each gds-list-flt no-lock indexed-reposition.
  if line-rec <> ? then
    reposition br-list to recid line-rec no-error.
  apply "entry" to br-list in frame Dialog-Frame.
  if available gds-list-flt then do:     find ub.clients where ub.clients.obj-type = gds-list-flt.prod-type                    and ub.clients.obj-code = gds-list-flt.prod-code no-lock.     find ub.gds-prt where ub.gds-prt.upper-code = gds-list-flt.prt-root no-lock.     find ub.bar-code where ub.bar-code.gds-code  = gds-list-flt.gds-code                     and ub.bar-code.node-code = ub.gds-prt.node-code                     and ub.bar-code.unit-cli  = gds-list-flt.unit-base                     and ub.bar-code.in-code   = ""                     and ub.bar-code.part-code = "" no-lock.     disp ub.clients.obj-name ub.gds-prt.node-name ub.bar-code.b-code tot-lns @ f-tot-lns with frame Dialog-Frame.   end.   else display f-tot-lns with frame Dialog-Frame.
END PROCEDURE.
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE ex-gds :
    define parameter buffer buf_goods for ub.goods.
    define input parameter rs-list-method as character no-undo .
    define input parameter rs-status as character no-undo .
    define input parameter line-mode as character no-undo .
    if rs-list-method = "single":U or
        (buf_goods.stts = 0  and rs-status <> 'удаленные':U) or
        (buf_goods.stts <> 0 and rs-status <> 'текущие':U) then
    do:
        if line-mode = 'удаление':U or line-mode = 'ОСТАВИТЬ':U then
        do:
            if rs-list-method = "tsd":U then
            do:
                for first ub.Code no-lock where ub.Code.parent = "TiketPrint" and
                    ub.code.status_ = 0 and ub.Code.code = string(buf_goods.gds-code):
                    find first gds-list-flt where gds-list-flt.artic = buf_goods.artic
                        and gds-list-flt.prod-type = buf_goods.prod-type
                        and gds-list-flt.prod-code = buf_goods.prod-code no-error.
                    if available gds-list-flt then
                    do:
                        if line-mode = 'удаление':U then
                        do:
                            lns-cnt = lns-cnt + 1.
                            delete gds-list-flt.
                        end.
                        else
                        do:
                            if gds-list-flt.to-del = ? then.
                            else
                            do:
                                lns-cnt = lns-cnt + 1.
                                gds-list-flt.to-del = ?.
                            end.
                        end.
                    end.
                end.
            end.
            else
            do:
                find first gds-list-flt where gds-list-flt.artic = buf_goods.artic
                    and gds-list-flt.prod-type = buf_goods.prod-type
                    and gds-list-flt.prod-code = buf_goods.prod-code no-error.
                if available gds-list-flt then
                do:
                    if line-mode = 'удаление':U then
                    do:
                        lns-cnt = lns-cnt + 1.
                        delete gds-list-flt.
                    end.
                    else
                    do:
                        if gds-list-flt.to-del = ? then.
                        else
                        do:
                            lns-cnt = lns-cnt + 1.
                            gds-list-flt.to-del = ?.
                        end.
                    end.
                end.
            end.
        end.
        else
            if line-mode = 'ДОБАВЛЕНИЕ':U then
            do:
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find gds-list-flt
  where gds-list-flt.prod-type = buf_goods.prod-type
    and gds-list-flt.prod-code = buf_goods.prod-code
    and gds-list-flt.artic     = buf_goods.artic
  no-error .
if available gds-list-flt then do:
  assign
    gds-list-flt.to-del = no
  .
end.
else do:
  define variable v-last49 as integer no-undo .
  find last gds-list-flt use-index oi no-error.
  if available gds-list-flt then do:
    v-last49 = gds-list-flt.order-num .
  end.
  else do:
    v-last49 = 0 .
  end.
  create gds-list-flt .
  buffer-copy buf_goods to gds-list-flt
  assign
    gds-list-flt.to-del = no
    gds-list-flt.order-num = v-last49 + 1
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (gds-list-flt)
  .
end.
                if rs-list-method = "tsd":U  then
                do:
                    for first ub.Code no-lock where ub.Code.parent = "TiketPrint" and
                        ub.code.status_ = 0 and ub.Code.code = string(buf_goods.gds-code):
                        find first gds-list-flt where gds-list-flt.gds-code = buf_goods.gds-code no-error.
                        if available gds-list-flt then
                        do:
                            gds-list-flt.qnty = decimal(ub.Code.CodeValue) .
                        end.
                    end.
                end.
            end.
        if lns-cnt modulo 25 = 0 then
            disp "ЖДИТЕ...    Обработано товаров :" + string (lns-cnt) @ dsp-rs with frame Dialog-Frame.
    end.
    else
        assign
            lns-ignore = lns-ignore + 1
            .
end.
PROCEDURE rs-do:
define input parameter p-from-macro as logical no-undo .
define input parameter p-step as logical no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
define input parameter line-mode as character no-undo .
define input parameter p-id      as integer no-undo .
define variable grp-path like ub.goods.grp-name no-undo.
define variable another-price like ub.price-list.price-sale no-undo.
define variable var-root-code like ub.gds-prt.node-code no-undo .
define variable v-rowid   as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-discnt-role as character no-undo .
define variable v-nonunique as character no-undo .
define variable vvalue-int as integer no-undo .
define variable glog as logical no-undo .
define variable v-date-chr as character no-undo .
define variable v-date as date no-undo .
define buffer buf_gds-list-flt-hist for gds-list-flt-hist.
define buffer buf_user-obj for ub.user-obj.
define buffer buf_units for ub.units.
define buffer buf_parts for ub.parts.
do
on error undo, return error return-value
:
assign
lns-cnt = 0
lns-ignore = 0
v-num-add     = 0
v-num-ignored = 0
tot-lns = (if line-mode = 'ОСТАВИТЬ':U then 0 else tot-lns)
.
run write-hist in this-procedure ( input p-from-macro
                                  ,input rs-list-method
                                  ,input rs-status
                                  ,input line-mode).
if session:set-wait-state( "COMPILER" )  then .
dsp-rs:fgcolor in frame Dialog-Frame = 12.
case rs-list-method:
  when "all" then do:
    find first buf_gds-list-flt-hist where
               buf_gds-list-flt-hist.id = p-id .
    for each ub.goods no-lock:
      run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
    end.
    assign                                                           buf_gds-list-flt-hist.num-add  = lns-cnt - v-num-add                       buf_gds-list-flt-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_gds-list-flt-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_gds-list-flt-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
  end.
  when "gds-grp" then do:
    for each buf_gds-list-flt-hist where
             buf_gds-list-flt-hist.id = p-id
        and  buf_gds-list-flt-hist.item_ <> '':U:
      run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_gds-list-flt-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then  next.
      grp-path = "".
      find first ub.gds-grp no-lock where rowid(ub.gds-grp) = v-rowid.
      run grplib-get-full-name in this-procedure (ub.gds-grp.node-code, output grp-path).
      for each ub.goods where ub.goods.grp-name begins grp-path no-lock:
        run ex-gds  in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      end.
      assign                                                           buf_gds-list-flt-hist.num-add  = lns-cnt - v-num-add                       buf_gds-list-flt-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_gds-list-flt-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_gds-list-flt-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "goods" or
  when "gds-obj":U  or
  when "gds-obj-fact":U  or
  when "gds-obj-free":U  or
  when "tsd" then do:
    for each buf_gds-list-flt-hist where
             buf_gds-list-flt-hist.id = p-id
        and  buf_gds-list-flt-hist.item_ <> '':U:
      run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_gds-list-flt-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then next.
      find ub.goods where rowid (goods) = v-rowid no-lock.
      run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      assign                                                           buf_gds-list-flt-hist.num-add  = lns-cnt - v-num-add                       buf_gds-list-flt-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_gds-list-flt-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_gds-list-flt-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "grp-prod"
  or
  when "grp-supp"
  then do:
    for each buf_gds-list-flt-hist where
             buf_gds-list-flt-hist.id = p-id
        and  buf_gds-list-flt-hist.item_  <> '':U:
      run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_gds-list-flt-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then next.
      find ub.cli-grp where rowid (ub.cli-grp) = v-rowid no-lock.
      grp-path = "".
      run cli-grplib-get-full-name in this-procedure (ub.cli-grp.node-code, output grp-path).
      for each ub.clients where ub.clients.grp-name begins grp-path no-lock:
        if rs-list-method = "grp-prod" then do:
        for each ub.goods where ub.goods.prod-type = ub.clients.obj-type
                        and ub.goods.prod-code = ub.clients.obj-code no-lock:
          run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
        end.
        end.
        if rs-list-method = "grp-supp" then do:
          for each ub.cli-gds where ub.cli-gds.cli-type = ub.clients.obj-type
                            and ub.cli-gds.cli-code = ub.clients.obj-code
                            and ub.cli-gds.host-code = p-curr-host-code no-lock,
              each ub.goods where goods.artic = ub.cli-gds.artic
                            and ub.goods.prod-type = ub.cli-gds.prod-type
                            and ub.goods.prod-code = ub.cli-gds.prod-code no-lock:
            run ex-gds in this-procedure ( buffer goods, input rs-list-method, input rs-status, input line-mode).
          end.
        end.
      end.
      assign                                                           buf_gds-list-flt-hist.num-add  = lns-cnt - v-num-add                       buf_gds-list-flt-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_gds-list-flt-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_gds-list-flt-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "producer"
  or
  when "supplier"
  then do:
    for each buf_gds-list-flt-hist where
             buf_gds-list-flt-hist.id = p-id
        and  buf_gds-list-flt-hist.item_  <> '':U:
      run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_gds-list-flt-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then next.
      find clients where rowid (clients) = v-rowid no-lock.
      if rs-list-method = "producer" then do:
        for each ub.goods where ub.goods.prod-type = ub.clients.obj-type
                        and ub.goods.prod-code = ub.clients.obj-code no-lock:
          run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
        end.
      end.
      if rs-list-method = "supplier" then do:
        for each ub.cli-gds where ub.cli-gds.cli-type = ub.clients.obj-type
                          and ub.cli-gds.cli-code = ub.clients.obj-code
                          and ub.cli-gds.host-code = p-curr-host-code
                          and ub.cli-gds.in-qnty <> 0 no-lock,
            first ub.goods where ub.goods.artic = ub.cli-gds.artic
                        and ub.goods.prod-type = ub.cli-gds.prod-type
                        and ub.goods.prod-code = ub.cli-gds.prod-code no-lock:
          run ex-gds  in this-procedure( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
        end.
      end.
      assign                                                           buf_gds-list-flt-hist.num-add  = lns-cnt - v-num-add                       buf_gds-list-flt-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_gds-list-flt-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_gds-list-flt-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "choose-alc-prod"
  then do:
    for each buf_gds-list-flt-hist where
             buf_gds-list-flt-hist.id = p-id
        and  buf_gds-list-flt-hist.item_  <> '':U:
      run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_gds-list-flt-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then next.
      find alc-type where rowid (alc-type) = v-rowid no-lock.
      if rs-list-method = "choose-alc-prod" then do:
        for each alc-type-gds where alc-type-gds.alc-type-inner-code = alc-type.alc-type-inner-code no-lock,
            first goods where goods.gds-code = alc-type-gds.gds-code no-lock:
          run ex-gds  in this-procedure( buffer goods, input rs-list-method, input rs-status, input line-mode).
        end.
      end.
      assign                                                           buf_gds-list-flt-hist.num-add  = lns-cnt - v-num-add                       buf_gds-list-flt-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_gds-list-flt-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_gds-list-flt-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "object" then do:
    find first buf_gds-list-flt-hist where
             buf_gds-list-flt-hist.id = p-id
        and  buf_gds-list-flt-hist.item_  <> '':U.
    run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_gds-list-flt-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then do: end. else do:
     run find-user-obj-rowid in this-procedure ( input v-rowid, input v-no-context, output v-user-obj-type, output v-user-obj-code ).
      for each ub.gds-obj where ub.gds-obj.obj-type = v-user-obj-type
                        and ub.gds-obj.obj-code = v-user-obj-code no-lock,
          first ub.goods where ub.goods.prod-type = ub.gds-obj.prod-type
                      and ub.goods.prod-code = ub.gds-obj.prod-code
                      and ub.goods.artic = ub.gds-obj.artic no-lock:
        run ex-gds in this-procedure( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      end.
      assign                                                           buf_gds-list-flt-hist.num-add  = lns-cnt - v-num-add                       buf_gds-list-flt-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_gds-list-flt-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_gds-list-flt-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "etalon" then do:
    find first buf_gds-list-flt-hist where
             buf_gds-list-flt-hist.id = p-id
        and  buf_gds-list-flt-hist.item_  <> '':U.
    run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_gds-list-flt-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then do: end. else do:
      run find-user-obj-rowid in this-procedure ( input v-rowid, input v-no-context, output v-user-obj-type, output v-user-obj-code ).
      for each ub.gds-obj where
            ub.gds-obj.obj-type = p-curr-obj-type and
            ub.gds-obj.obj-code = p-curr-obj-code no-lock,
        first ub.goods where
            ub.goods.prod-type = ub.gds-obj.prod-type and
            ub.goods.prod-code = ub.gds-obj.prod-code and
            ub.goods.artic     = ub.gds-obj.artic no-lock,
        each ub.gds-prt where
            ub.gds-prt.upper-code = ub.goods.prt-root no-lock,
        each ub.bar-code where
            ub.bar-code.gds-code  = ub.goods.gds-code and
            ub.bar-code.node-code = ub.gds-prt.node-code and
            ub.bar-code.unit-cli  = ub.goods.unit-base and
            ub.bar-code.in-code   = "" and
            ub.bar-code.part-code = "" no-lock:
        find last ub.price-list where
                  ub.price-list.obj-type  = p-curr-obj-type and
                  ub.price-list.obj-code  = p-curr-obj-code and
                  ub.price-list.b-code    = ub.bar-code.b-code and
                  ub.price-list.price-type = ""
                  use-index fact-close no-lock no-error.
        if available ub.price-list and
          ub.price-list.fact-order <> 0 then do:
          another-price = ub.price-list.price-sale.
          find last ub.price-list where ub.price-list.obj-type  = v-user-obj-type
                                and ub.price-list.obj-code  = v-user-obj-code
                                and ub.price-list.b-code    = bar-code.b-code
                                use-index fact-close no-lock no-error.
          if available ub.price-list and
            ub.price-list.fact-order <> 0 and
            ub.price-list.price-sale <> another-price then
            run ex-gds  in this-procedure( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
        end.
      end.
    end.
    assign                                                           buf_gds-list-flt-hist.num-add  = lns-cnt - v-num-add                       buf_gds-list-flt-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_gds-list-flt-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_gds-list-flt-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
  end.
  when "waybill" then do:
    glog = no.
    _ii:
    for each buf_gds-list-flt-hist where
             buf_gds-list-flt-hist.id = p-id
        and  buf_gds-list-flt-hist.item_  <> '':U:
      run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_gds-list-flt-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then next _ii.
      find first ub.trn-doc no-lock where
              rowid(ub.trn-doc) = v-rowid no-error.
      if not avail ub.trn-doc then next _ii.
      for each ub.doc-line where ub.doc-line.doc-code = ub.trn-doc.doc-code no-lock,
          first ub.goods where ub.goods.artic     = ub.doc-line.artic
                        and ub.goods.prod-type = ub.doc-line.prod-type
                        and ub.goods.prod-code = ub.doc-line.prod-code no-lock:
        run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
        if glog and
            available gds-list-flt and
            gds-list-flt.artic = ub.goods.artic and
            gds-list-flt.prod-type = ub.goods.prod-type and
            gds-list-flt.prod-code = ub.goods.prod-code then do:
          gds-list-flt.qnty = if can-do ('рас,спи':U, ub.trn-doc.doc-type) then
                      gds-list-flt.qnty - ub.doc-line.fact-qnty
                    else
                      gds-list-flt.qnty + ub.doc-line.fact-qnty.
          if gds-list-flt.qnty < 0 then do:
            if not p-from-macro or p-step then
            message "Артикул:" ub.doc-line.artic skip
                    "Количество в накладной:" ub.doc-line.fact-qnty skip
                    "Итоговое количество в списке:" gds-list-flt.qnty skip (2)
                    "Заменено на 0."
                    view-as alert-box .
            gds-list-flt.qnty = 0.
          end.
        end.
      end.
      assign                                                           buf_gds-list-flt-hist.num-add  = lns-cnt - v-num-add                       buf_gds-list-flt-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_gds-list-flt-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_gds-list-flt-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "manufacture" then do:
    for each buf_gds-list-flt-hist where
             buf_gds-list-flt-hist.id = p-id
        and  buf_gds-list-flt-hist.item_  <> '':U:
      run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_gds-list-flt-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then next.
      find first ub.fbr-doc no-lock where
                rowid(ub.fbr-doc) = v-rowid.
      for each ub.fbr-line where ub.fbr-line.doc-code = ub.fbr-doc.doc-code no-lock,
          first ub.goods where ub.goods.artic = ub.fbr-line.artic
                      and ub.goods.prod-type = ub.fbr-line.prod-type
                      and ub.goods.prod-code = ub.fbr-line.prod-code no-lock:
        run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      end.
      assign                                                           buf_gds-list-flt-hist.num-add  = lns-cnt - v-num-add                       buf_gds-list-flt-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_gds-list-flt-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_gds-list-flt-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "recipe" then do:
    for each buf_gds-list-flt-hist where
             buf_gds-list-flt-hist.id = p-id
        and  buf_gds-list-flt-hist.item_  <> '':U:
      run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_gds-list-flt-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then next.
      find first ub.recipe no-lock where rowid(recipe) = v-rowid.
      for each ub.recipe-gds where ub.recipe-gds.recipe-code = recipe.recipe-code no-lock,
          first ub.goods where ub.goods.artic = ub.recipe-gds.artic
                      and ub.goods.prod-type = ub.recipe-gds.prod-type
                      and ub.goods.prod-code = ub.recipe-gds.prod-code no-lock:
        run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      end.
      assign                                                           buf_gds-list-flt-hist.num-add  = lns-cnt - v-num-add                       buf_gds-list-flt-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_gds-list-flt-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_gds-list-flt-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "self-recipe" then do:
    for each buf_gds-list-flt-hist where
             buf_gds-list-flt-hist.id = p-id
        and  buf_gds-list-flt-hist.item_  <> '':U:
      run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_gds-list-flt-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then next.
      find first ub.recipe no-lock where rowid(ub.recipe) = v-rowid.
      find first ub.goods where goods.artic = ub.recipe.artic
                  and ub.goods.prod-type = ub.recipe.prod-type
                  and ub.goods.prod-code = ub.recipe.prod-code no-lock no-error.
      if available ub.goods then do:
        run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      end.
      assign                                                           buf_gds-list-flt-hist.num-add  = lns-cnt - v-num-add                       buf_gds-list-flt-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_gds-list-flt-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_gds-list-flt-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "contract" then do:
    for each buf_gds-list-flt-hist where
             buf_gds-list-flt-hist.id = p-id
        and  buf_gds-list-flt-hist.item_  <> '':U:
      run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_gds-list-flt-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then next.
      find first ub.contract no-lock  where rowid(ub.contract) = v-rowid.
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  ub.contract.host-code,
    INPUT  ub.contract.contract-code,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = ub.contract.host-code
      i-gl-Contract-Code  = ub.contract.contract-code
      .
END.
FOR EACH
    ub.contract-specif
     NO-LOCK
     WHERE
         ub.contract-specif.Host-code    = i-gl-Host-Code
     AND ub.contract-specif.Contract-num = i-gl-Contract-Code
          ,
           first ub.goods where ub.goods.gds-code = contract-specif.gds-code no-lock :
        run ex-gds in this-procedure( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      end.
      assign                                                           buf_gds-list-flt-hist.num-add  = lns-cnt - v-num-add                       buf_gds-list-flt-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_gds-list-flt-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_gds-list-flt-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "client" then do:
    find first buf_gds-list-flt-hist where
             buf_gds-list-flt-hist.id = p-id
         AND buf_gds-list-flt-hist.item_  <> '':U .
    run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_gds-list-flt-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then do: end. else do:
      find first ub.clients no-lock where rowid(ub.clients) = v-rowid.
      for each ub.trn-doc where ub.trn-doc.cli-type = ub.clients.obj-type
                        and ub.trn-doc.cli-code = ub.clients.obj-code no-lock:
        for each ub.doc-line where doc-line.doc-code = trn-doc.doc-code no-lock,
            first ub.goods where ub.goods.artic = ub.doc-line.artic
                          and ub.goods.prod-type = ub.doc-line.prod-type
                          and ub.goods.prod-code = ub.doc-line.prod-code no-lock:
          run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
        end.
      end.
      assign                                                           buf_gds-list-flt-hist.num-add  = lns-cnt - v-num-add                       buf_gds-list-flt-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_gds-list-flt-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_gds-list-flt-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "consignee" then do:
    find first buf_gds-list-flt-hist where
             buf_gds-list-flt-hist.id = p-id
         AND buf_gds-list-flt-hist.item_  <> '':U .
    run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_gds-list-flt-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then do: end. else do:
      find first ub.clients no-lock where rowid(clients) = v-rowid.
      for each ub.cli-gds where ub.cli-gds.cli-type = ub.clients.obj-type
                        and ub.cli-gds.cli-code = ub.clients.obj-code
                        and ub.cli-gds.out-qnty > ub.cli-gds.ret-qnty no-lock,
          first ub.goods where ub.goods.artic = ub.cli-gds.artic
                      and ub.goods.prod-type = ub.cli-gds.prod-type
                      and ub.goods.prod-code = ub.cli-gds.prod-code no-lock:
        run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      end.
      assign                                                           buf_gds-list-flt-hist.num-add  = lns-cnt - v-num-add                       buf_gds-list-flt-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_gds-list-flt-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_gds-list-flt-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "overvalue" then do:
    glog = no.
    _jj:
    for each buf_gds-list-flt-hist where
             buf_gds-list-flt-hist.id = p-id
        and  buf_gds-list-flt-hist.item_  <> '':U:
      run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_gds-list-flt-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then next _jj.
      find first ub.price-doc no-lock where
                rowid(ub.price-doc) = v-rowid no-error.
      if not avail ub.price-doc then next _jj.
      for each ub.price-list where ub.price-list.doc-num = ub.price-doc.doc-num no-lock,
          first ub.goods where ub.goods.prod-type = ub.price-list.prod-type
                        and ub.goods.prod-code = ub.price-list.prod-code
                        and ub.goods.artic = ub.price-list.artic no-lock:
        run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      end.
      assign                                                           buf_gds-list-flt-hist.num-add  = lns-cnt - v-num-add                       buf_gds-list-flt-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_gds-list-flt-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_gds-list-flt-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "pdf" then do:
    glog = no.
    _jj:
    for each buf_gds-list-flt-hist where
             buf_gds-list-flt-hist.id = p-id
        and  buf_gds-list-flt-hist.item_  <> '':U:
      run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_gds-list-flt-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then next _jj.
      find first ub.price-doc-forming no-lock where
                rowid(ub.price-doc-forming) = v-rowid no-error.
      if not avail ub.price-doc-forming then next _jj.
      for each ub.price-doc-forming-gds where
              ub.price-doc-forming-gds.plt-db-num = ub.price-doc-forming.plt-db-num
          and ub.price-doc-forming-gds.plt-id = ub.price-doc-forming.plt-id
          and ub.price-doc-forming-gds.pdf-db = ub.price-doc-forming.pdf-db
          and ub.price-doc-forming-gds.pdf-id = ub.price-doc-forming.pdf-id
      no-lock,
          first ub.goods where ub.goods.prod-type = ub.price-doc-forming-gds.prod-type
                        and ub.goods.prod-code = ub.price-doc-forming-gds.prod-code
                        and ub.goods.artic = ub.price-doc-forming-gds.artic no-lock:
        run ex-gds in this-procedure ( buffer goods, input rs-list-method, input rs-status, input line-mode).
      end.
      assign                                                           buf_gds-list-flt-hist.num-add  = lns-cnt - v-num-add                       buf_gds-list-flt-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_gds-list-flt-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_gds-list-flt-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
    when "collection" then do:
        run str/any-li01.p (
                         input parparentproc
                        ,input this-procedure:handle
                        ,input "collection"
                        ,input p-from-macro
                        ,input rs-list-method
                        ,input rs-status
                        ,input line-mode
                        ,input p-id
                        ,INPUT-OUTPUT table buf_gds-list-flt-hist
                        ) no-error .
  end.
  when "abcxyz"
  or
  when "abc-analysis"
  or
  when "xyz-analysis" then do:
    run str/any-li01.p ( input parparentproc
                    ,input this-procedure:handle
                    ,input "analysis-do"
                    ,input p-from-macro
                    ,input rs-list-method
                    ,input rs-status
                    ,input line-mode
                    ,input p-id
                    ,INPUT-OUTPUT table buf_gds-list-flt-hist
                    ) no-error .
  end.
  when "ass-matr"
  or
  when "ass-min" then do:
    run str/any-li01.p ( input parparentproc
                    ,input this-procedure:handle
                    ,input rs-list-method
                    ,input p-from-macro
                    ,input rs-list-method
                    ,input rs-status
                    ,input line-mode
                    ,input p-id
                    ,INPUT-OUTPUT table buf_gds-list-flt-hist
                    ) no-error .
  end.
  when "izt" then do:
    for each buf_gds-list-flt-hist where
             buf_gds-list-flt-hist.id = p-id
        and  buf_gds-list-flt-hist.item_  <> '':U:
      assign
      v-attr-code  = entry(1, buf_gds-list-flt-hist.item_, chr(3))
      v-obj-type = entry(2, buf_gds-list-flt-hist.item_, chr(3))
      v-obj-code = integer(entry(3, buf_gds-list-flt-hist.item_, chr(3)))
      .
      for each ub.gds-obj-prop no-lock where
             ub.gds-obj-prop.obj-type  = v-obj-type
         and ub.gds-obj-prop.obj-code  = v-obj-code
         and lookup (ub.gds-obj-prop.gdop-igt , v-attr-code ) > 0 ,
          first ub.goods no-lock where
               ub.goods.gds-code = ub.gds-obj-prop.gds-code:
        run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      end.
      if v-attr-code = 'Пусто':U then do:
        for each ub.gds-obj no-lock where
                ub.gds-obj.obj-type  = v-obj-type
            and ub.gds-obj.obj-code  = v-obj-code:
          if not can-find ( first ub.gds-obj-prop where
                                 ub.gds-obj-prop.obj-type  = v-obj-type
                             and ub.gds-obj-prop.obj-code  = v-obj-code
                             and ub.gds-obj-prop.gds-code = ub.gds-obj.gds-code ) then   do:
            find first ub.goods no-lock  where
                      ub.goods.gds-code = ub.gds-obj.gds-code no-error .
            if available goods then
            run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
          end.
        end.
      end.
    end.
  end.
  when "input" or when "with-price" then do:
    find first buf_gds-list-flt-hist where
             buf_gds-list-flt-hist.id = p-id
         AND buf_gds-list-flt-hist.item_  <> '':U .
    run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_gds-list-flt-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then do: end. else do:
      run find-user-obj-rowid in this-procedure ( input v-rowid, input v-no-context, output v-user-obj-type, output v-user-obj-code ).
      for each ub.gds-obj where
              ub.gds-obj.obj-type = v-user-obj-type
          and ub.gds-obj.obj-code = v-user-obj-code no-lock,
          first ub.goods where
                ub.goods.gds-code = ub.gds-obj.gds-code:
        if rs-list-method = "with-price" then do:
          if ub.gds-obj.price-sale > 0
          AND ub.gds-obj.last-doc <> ? then do:
            run ex-gds  in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
          end.
        end.
        if rs-list-method = "input" then do:
          find first ub.parts no-lock where
                    ub.parts.obj-type  = ub.gds-obj.obj-type
                AND ub.parts.obj-code  = ub.gds-obj.obj-code
                AND ub.parts.artic = ub.gds-obj.artic
                AND ub.parts.prod-type = ub.gds-obj.prod-type
                AND ub.parts.prod-code = ub.gds-obj.prod-code no-error.
          if available ub.parts then do:
            run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
          end.
        end.
      end.
      assign                                                           buf_gds-list-flt-hist.num-add  = lns-cnt - v-num-add                       buf_gds-list-flt-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_gds-list-flt-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_gds-list-flt-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "available" then do:
    find first buf_gds-list-flt-hist where
             buf_gds-list-flt-hist.id = p-id
         AND buf_gds-list-flt-hist.item_  <> '':U .
    run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_gds-list-flt-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then do: end. else do:
      run find-user-obj-rowid in this-procedure ( input v-rowid, input v-no-context, output v-user-obj-type, output v-user-obj-code ).
      for each ub.gds-obj where
              ub.gds-obj.obj-type = v-user-obj-type
          and ub.gds-obj.obj-code = v-user-obj-code
          and ub.gds-obj.fact-qnty > 0 no-lock,
          first ub.goods where
              ub.goods.gds-code = ub.gds-obj.gds-code no-lock:
        run ex-gds in this-procedure ( buffer goods, input rs-list-method, input rs-status, input line-mode).
      end.
      assign                                                           buf_gds-list-flt-hist.num-add  = lns-cnt - v-num-add                       buf_gds-list-flt-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_gds-list-flt-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_gds-list-flt-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "neg-part" or
  when "neg-part-free" then do:
    find first buf_gds-list-flt-hist where
             buf_gds-list-flt-hist.id = p-id
         AND buf_gds-list-flt-hist.item_  <> '':U .
    run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_gds-list-flt-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then do: end. else do:
      run find-user-obj-rowid in this-procedure ( input v-rowid, input v-no-context, output v-user-obj-type, output v-user-obj-code ).
      for each ub.parts where ub.parts.obj-type = v-user-obj-type
                      and ub.parts.obj-code = v-user-obj-code
                      and ub.parts.out-code = 'free-zone':U
                      and ub.parts.fact-qnty < 0 no-lock,
          first ub.goods where ub.goods.prod-type = ub.parts.prod-type
                        and ub.goods.prod-code = ub.parts.prod-code
                        and ub.goods.artic = ub.parts.artic no-lock:
        run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      end.
      if rs-list-method <> "neg-part-free" then do:
        for each ub.parts where ub.parts.obj-type = v-user-obj-type
                      and ub.parts.obj-code = v-user-obj-code
                      and ub.parts.out-code = 'out-zone':U
                      and ub.parts.fact-qnty < 0 no-lock,
          first ub.goods where ub.goods.prod-type = ub.parts.prod-type
                        and ub.goods.prod-code = ub.parts.prod-code
                        and ub.goods.artic = ub.parts.artic no-lock:
        run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
        end.
      end.
      assign                                                           buf_gds-list-flt-hist.num-add  = lns-cnt - v-num-add                       buf_gds-list-flt-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_gds-list-flt-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_gds-list-flt-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "neg-rest" then do:
    find first buf_gds-list-flt-hist where
             buf_gds-list-flt-hist.id = p-id
         AND buf_gds-list-flt-hist.item_  <> '':U .
    run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_gds-list-flt-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then do: end. else do:
      run find-user-obj-rowid in this-procedure ( input v-rowid, input v-no-context, output v-user-obj-type, output v-user-obj-code ).
      for each ub.gds-obj where ub.gds-obj.obj-type = v-user-obj-type
                        and ub.gds-obj.obj-code = v-user-obj-code
                        and ub.gds-obj.fact-qnty < 0 no-lock,
          first ub.goods where ub.goods.prod-type = ub.gds-obj.prod-type
                      and ub.goods.prod-code = ub.gds-obj.prod-code
                      and ub.goods.artic = ub.gds-obj.artic no-lock:
        run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      end.
      assign                                                           buf_gds-list-flt-hist.num-add  = lns-cnt - v-num-add                       buf_gds-list-flt-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_gds-list-flt-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_gds-list-flt-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "neg-prt" then do:
    find first buf_gds-list-flt-hist where
             buf_gds-list-flt-hist.id = p-id
         AND buf_gds-list-flt-hist.item_  <> '':U .
    run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_gds-list-flt-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then do: end. else do:
      run find-user-obj-rowid in this-procedure ( input v-rowid, input v-no-context, output v-user-obj-type, output v-user-obj-code ).
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run emptyscl in g#library
  (output var-root-code
  ) no-error .
      find first ub.gds-prt no-lock where
                ub.gds-prt.node-code = var-root-code no-error .
        _neg-prt-obj:
      for each ub.prt-obj no-lock where
              ub.prt-obj.obj-type = v-user-obj-type
          and ub.prt-obj.obj-code = v-user-obj-code,
          first ub.goods no-lock where
                ub.goods.prod-type = ub.prt-obj.prod-type
            and ub.goods.prod-code = ub.prt-obj.prod-code
            and ub.goods.artic = ub.prt-obj.artic:
        if ub.goods.prt-root = ub.gds-prt.upper-code then NEXT _neg-prt-obj.
        if NOT (ub.prt-obj.fact-qnty < 0) then next _neg-prt-obj.
        run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      end.
      assign                                                           buf_gds-list-flt-hist.num-add  = lns-cnt - v-num-add                       buf_gds-list-flt-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_gds-list-flt-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_gds-list-flt-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "is-ptrl" then do:
    find first buf_gds-list-flt-hist where
             buf_gds-list-flt-hist.id = p-id  no-error .
    if error-status:error then do: end. else do:
      for each buf_units no-lock where
              lookup( 'топ':U, buf_units.type) > 0,
          each ub.goods no-lock where
                ub.goods.unit-base = buf_units.unit-name:
        run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      end.
      assign                                                           buf_gds-list-flt-hist.num-add  = lns-cnt - v-num-add                       buf_gds-list-flt-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_gds-list-flt-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_gds-list-flt-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "gds-office" then do:
    find first buf_gds-list-flt-hist where
             buf_gds-list-flt-hist.id = p-id  no-error .
    if error-status:error then do: end. else do:
      for each ub.goods no-lock:
        if ub.goods.gds-type = 'у':U then do:
          run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
        end.
      end.
      assign                                                           buf_gds-list-flt-hist.num-add  = lns-cnt - v-num-add                       buf_gds-list-flt-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_gds-list-flt-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_gds-list-flt-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "nul-rest" then do:
    find first buf_gds-list-flt-hist where
             buf_gds-list-flt-hist.id = p-id
         AND buf_gds-list-flt-hist.item_  <> '':U .
    run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_gds-list-flt-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then do: end. else do:
      run find-user-obj-rowid in this-procedure ( input v-rowid, input v-no-context, output v-user-obj-type, output v-user-obj-code ).
      for each ub.gds-obj where ub.gds-obj.obj-type = v-user-obj-type
                        and ub.gds-obj.obj-code = v-user-obj-code
                        and ub.gds-obj.fact-qnty = 0 no-lock,
          first ub.goods where ub.goods.prod-type = ub.gds-obj.prod-type
                        and ub.goods.prod-code = ub.gds-obj.prod-code
                        and ub.goods.artic         = ub.gds-obj.artic no-lock:
        run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      end.
      assign                                                           buf_gds-list-flt-hist.num-add  = lns-cnt - v-num-add                       buf_gds-list-flt-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_gds-list-flt-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_gds-list-flt-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "fbr-gds-obj-val"
  or when "fbr-gds-obj"
  then do:
    find first buf_gds-list-flt-hist where
             buf_gds-list-flt-hist.id = p-id
         AND buf_gds-list-flt-hist.item_ <> '':U .
    assign
    v-obj-type = entry(1, buf_gds-list-flt-hist.item_, chr(3))
    v-obj-code = integer(entry(2, buf_gds-list-flt-hist.item_, chr(3)))
    v-attr-code  = (if rs-list-method = "fbr-gds-obj-val"
                    then entry(3, buf_gds-list-flt-hist.item_, chr(3))
                    else '':U)
    vvalue = (if rs-list-method = "fbr-gds-obj-val"
              then entry(4, buf_gds-list-flt-hist.item_, chr(3))
              else '':U)
    no-error
    .
    if error-status:error then do: end. else do:
      for each ub.fbr-gds-obj no-lock where
              ub.fbr-gds-obj.obj-type = v-obj-type
          and ub.fbr-gds-obj.obj-code = v-obj-code,
          first ub.goods no-lock where
                ub.goods.gds-code = ub.fbr-gds-obj.gds-code:
        if rs-list-method = "fbr-gds-obj-val" then do:
          CASE v-attr-code:
            when "is-cd":U then do:
              if string(ub.fbr-gds-obj.is-cd, "yes/no":U)  <> vvalue then NEXT.
            end.
            when "is-menu":U then do:
              if string(ub.fbr-gds-obj.is-menu, "yes/no":U)  <> vvalue then NEXT.
            end.
            when "is-null-price":U then do:
              if string(ub.fbr-gds-obj.is-null-price, "yes/no":U)  <> vvalue then NEXT.
            end.
            when "is-modificator":U  then do:
              if string(ub.fbr-gds-obj.is-modificator, "yes/no":U)  <> vvalue then NEXT.
            end.
            when "is-season":U then do:
              if string(ub.fbr-gds-obj.is-season, "yes/no":U)  <> vvalue then NEXT.
            end.
            when "is-semi-finished":U then do:
              if string(ub.fbr-gds-obj.is-semi-finished, "yes/no":U)  <> vvalue then NEXT.
            end.
            when "fbr-grp-code":u then do:
              if string(ub.fbr-gds-obj.fbr-grp-code)  <> vvalue then NEXT.
            end.
            when "fbr-obj-code":u then do:
              if string(ub.fbr-gds-obj.fbr-obj-code)  <> vvalue then NEXT.
            end.
          END CASE.
        end.
        run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      end.
      assign                                                           buf_gds-list-flt-hist.num-add  = lns-cnt - v-num-add                       buf_gds-list-flt-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_gds-list-flt-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_gds-list-flt-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "dis-gds-rule" or when "dis-gds-rule-num"  then do:
    find first buf_gds-list-flt-hist where
             buf_gds-list-flt-hist.id = p-id
         AND buf_gds-list-flt-hist.item_ <> '':U no-error .
    assign
    v-obj-type = entry(1, buf_gds-list-flt-hist.item_, chr(3))
    v-obj-code = integer(entry(2, buf_gds-list-flt-hist.item_, chr(3)))
    v-discnt-role = entry(3, buf_gds-list-flt-hist.item_, chr(3))
    vvalue-int = (if rs-list-method = "dis-gds-rule" then 0 else integer(entry(4, buf_gds-list-flt-hist.item_, chr(3))))
    no-error
    .
    if error-status:error then do: end. else do:
      for each ub.dis-gds-rule no-lock where
              ub.dis-gds-rule.discnt-role = v-discnt-role
          and ub.dis-gds-rule.obj-type = v-obj-type
          and ub.dis-gds-rule.obj-code = v-obj-code,
          first ub.goods no-lock where
                ub.goods.gds-code = ub.dis-gds-rule.gds-code:
        if rs-list-method = "dis-gds-rule-num" then do:
          if ub.dis-gds-rule.rule-num <> vvalue-int then NEXT.
        end.
        run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      end.
      assign                                                           buf_gds-list-flt-hist.num-add  = lns-cnt - v-num-add                       buf_gds-list-flt-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_gds-list-flt-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_gds-list-flt-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "gds-obj-attr" or when "gds-obj-attr-val"  then do:
    find first buf_gds-list-flt-hist where
             buf_gds-list-flt-hist.id = p-id
         AND buf_gds-list-flt-hist.item_ <> '':U no-error .
    assign
    v-obj-type = entry(1, buf_gds-list-flt-hist.item_, chr(3))
    v-obj-code = integer(entry(2, buf_gds-list-flt-hist.item_, chr(3)))
    v-attr-code = entry(3, buf_gds-list-flt-hist.item_, chr(3))
    vvalue = (if rs-list-method = "gds-obj-attr" then '':U else entry(4, buf_gds-list-flt-hist.item_, chr(3)))
    no-error
    .
    if error-status:error then do: end. else do:
      for each ub.gds-obj-attr no-lock where
              ub.gds-obj-attr.obj-type = v-obj-type
            and ub.gds-obj-attr.obj-code = v-obj-code
            and ub.gds-obj-attr.attr-code = v-attr-code,
          first ub.goods no-lock where
                ub.goods.gds-code = ub.gds-obj-attr.gds-code:
        if rs-list-method = "gds-obj-attr-val" then do:
          run gdsoattr-value  in this-procedure (
                                                 input v-attr-code
                                                ,input gds-obj-attr.gds-code
                                                ,input gds-obj-attr.obj-type
                                                ,input gds-obj-attr.obj-code
                                                ,output vvalue1
                                                ,output vtype).
          if vvalue1 <> vvalue then NEXT.
        end.
        run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      end.
      assign                                                           buf_gds-list-flt-hist.num-add  = lns-cnt - v-num-add                       buf_gds-list-flt-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_gds-list-flt-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_gds-list-flt-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "gds-host-attr"
  or
  when "gds-host-attr-val" then do:
    find first buf_gds-list-flt-hist where
             buf_gds-list-flt-hist.id = p-id
         AND buf_gds-list-flt-hist.item_ <> '':U .
    assign
    v-host-code = integer(entry(1, buf_gds-list-flt-hist.item_, chr(3)))
    v-attr-code = entry(2, buf_gds-list-flt-hist.item_, chr(3))
    vvalue = (if rs-list-method = "gds-host-attr" then '':U else entry(3, buf_gds-list-flt-hist.item_, chr(3)))
    no-error
    .
    if error-status:error then do: end. else do:
      for each  ub.gds-host-attr no-lock where
              ub.gds-host-attr.host-code = v-host-code:
        if ub.gds-host-attr.attr-code <> v-attr-code then NEXT.
        find first ub.goods no-lock where
                  ub.goods.gds-code = ub.gds-host-attr.gds-code no-error .
        if available ub.goods then do:
          if rs-list-method = "gds-host-attr-val" then do:
            run gdshattr-h-value  in this-procedure(
                                                    input v-attr-code
                                                    ,input v-host-code
                                                    ,input ub.gds-host-attr.gds-code
                                                    ,output vvalue1
                                                    ,output vtype).
            if vvalue1 <> vvalue then NEXT.
          end.
          run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
        end.
      end.
      assign                                                           buf_gds-list-flt-hist.num-add  = lns-cnt - v-num-add                       buf_gds-list-flt-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_gds-list-flt-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_gds-list-flt-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "goods-attr"
  or
  when "goods-attr-val"
  then do:
    find first buf_gds-list-flt-hist where
             buf_gds-list-flt-hist.id = p-id
         AND buf_gds-list-flt-hist.item_ <> '':U .
    assign
    v-attr-code = entry(1, buf_gds-list-flt-hist.item_, chr(3))
    vvalue = (if rs-list-method = "goods-attr" then '':U else entry(2, buf_gds-list-flt-hist.item_, chr(3)))
    no-error
    .
    if error-status:error then do: end. else do:
      for each  ub.goods-attr no-lock where
              ub.goods-attr.attr-code = v-attr-code,
          first ub.goods no-lock where
                  ub.goods.gds-code = ub.goods-attr.gds-code:
        if rs-list-method = "goods-attr-val" then do:
          run gds-attr-value in this-procedure (
                               input ub.goods-attr.gds-code
                              ,input v-attr-code
                              ,output vvalue1
                              ,output vtype).
          if vvalue1 <> vvalue then NEXT.
        end.
        run ex-gds  in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      end.
      assign                                                           buf_gds-list-flt-hist.num-add  = lns-cnt - v-num-add                       buf_gds-list-flt-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_gds-list-flt-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_gds-list-flt-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "tax-rate-value" then do:
    find first buf_gds-list-flt-hist where
             buf_gds-list-flt-hist.id = p-id
         AND buf_gds-list-flt-hist.item_ <> '':U .
    assign
    v-obj-type = entry(1, buf_gds-list-flt-hist.item_, chr(3))
    v-obj-code = integer(entry(2, buf_gds-list-flt-hist.item_, chr(3)))
    v-date = date(entry(3, buf_gds-list-flt-hist.item_, chr(3)))
    v-attr-code = entry(4, buf_gds-list-flt-hist.item_, chr(3))
    vvalue = entry(5, buf_gds-list-flt-hist.item_, chr(3))
    no-error
    .
    if error-status:error then do: end. else do:
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-obj-type
  ,input  v-obj-code
  ,output v-host-code
  )  .
      for each ub.goods no-lock:
        if lookup('1':U, v-attr-code, chr(4)) > 0 then do:
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  ub.goods.gds-code
  ,input  '1':U
  ,input  v-date
  ,input  v-host-code
  ,input  v-obj-type
  ,input  v-obj-code
  ,output vvaluedec
  ) no-error .
          if vvaluedec <> decimal(entry(lookup('1':U, v-attr-code, chr(4)), vvalue, chr(4))) then NEXT.
        end.
        if lookup('2':U, v-attr-code, chr(4)) > 0 then do:
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  ub.goods.gds-code
  ,input  '2':U
  ,input  v-date
  ,input  v-host-code
  ,input  v-obj-type
  ,input  v-obj-code
  ,output vvaluedec
  ) no-error .
          if vvaluedec <> decimal(entry(lookup('2':U, v-attr-code, chr(4)), vvalue, chr(4))) then NEXT.
        end.
        run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      end.
      assign                                                           buf_gds-list-flt-hist.num-add  = lns-cnt - v-num-add                       buf_gds-list-flt-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_gds-list-flt-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_gds-list-flt-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "tax-rate-value-obj" then do:
    find first buf_gds-list-flt-hist where
             buf_gds-list-flt-hist.id = p-id
         AND buf_gds-list-flt-hist.item_ <> '':U .
    assign
    v-obj-type = entry(1, buf_gds-list-flt-hist.item_, chr(3))
    v-obj-code = integer(entry(2, buf_gds-list-flt-hist.item_, chr(3)))
    v-date = date(entry(3, buf_gds-list-flt-hist.item_, chr(3)))
    v-attr-code = entry(4, buf_gds-list-flt-hist.item_, chr(3))
    vvalue = entry(5, buf_gds-list-flt-hist.item_, chr(3))
    no-error
    .
    if error-status:error then do: end. else do:
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-obj-type
  ,input  v-obj-code
  ,output v-host-code
  )  .
      for each ub.gds-obj no-lock where
                  ub.gds-obj.obj-type = v-obj-type
              AND ub.gds-obj.obj-code = v-obj-code,
              first ub.goods no-lock where
                    ub.goods.gds-code = ub.gds-obj.gds-code:
        if lookup('1':U, v-attr-code, chr(4)) > 0 then do:
define variable vss-include-info56 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  ub.goods.gds-code
  ,input  '1':U
  ,input  v-date
  ,input  v-host-code
  ,input  v-obj-type
  ,input  v-obj-code
  ,output vvaluedec
  ) no-error .
          if vvaluedec <> decimal(entry(lookup('1':U, v-attr-code, chr(4)), vvalue, chr(4))) then NEXT.
        end.
        if lookup('2':U, v-attr-code, chr(4)) > 0 then do:
define variable vss-include-info57 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  ub.goods.gds-code
  ,input  '2':U
  ,input  v-date
  ,input  v-host-code
  ,input  v-obj-type
  ,input  v-obj-code
  ,output vvaluedec
  ) no-error .
          if vvaluedec <> decimal(entry(lookup('2':U, v-attr-code, chr(4)), vvalue, chr(4))) then NEXT.
        end.
        run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      end.
      assign                                                           buf_gds-list-flt-hist.num-add  = lns-cnt - v-num-add                       buf_gds-list-flt-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_gds-list-flt-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_gds-list-flt-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "ov-req" then do:
    find first buf_gds-list-flt-hist where
             buf_gds-list-flt-hist.id = p-id
         AND buf_gds-list-flt-hist.item_ <> '':U .
    run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_gds-list-flt-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then do: end. else do:
      run find-user-obj-rowid in this-procedure ( input v-rowid, input v-no-context, output v-user-obj-type, output v-user-obj-code ).
      for each ub.gds-obj no-lock
        where ub.gds-obj.obj-type = v-user-obj-type
          and ub.gds-obj.obj-code = v-user-obj-code
          and ub.gds-obj.in-ov    = yes,
          first ub.goods no-lock
        where ub.goods.prod-type = ub.gds-obj.prod-type
          and ub.goods.prod-code = ub.gds-obj.prod-code
          and ub.goods.artic     = ub.gds-obj.artic:
        run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      end.
      assign                                                           buf_gds-list-flt-hist.num-add  = lns-cnt - v-num-add                       buf_gds-list-flt-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_gds-list-flt-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_gds-list-flt-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "inv-req" then do:
    find first buf_gds-list-flt-hist where
             buf_gds-list-flt-hist.id = p-id
         AND buf_gds-list-flt-hist.item_ <> '':U .
    run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_gds-list-flt-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then do: end. else do:
      run find-user-obj-rowid in this-procedure ( input v-rowid, input v-no-context, output v-user-obj-type, output v-user-obj-code ).
      for each ub.gds-obj where ub.gds-obj.obj-type = v-user-obj-type
                        and ub.gds-obj.obj-code = v-user-obj-code no-lock,
          first ub.goods where ub.goods.prod-type = ub.gds-obj.prod-type
                        and ub.goods.prod-code = ub.gds-obj.prod-code
                        and ub.goods.artic = ub.gds-obj.artic no-lock:
        find last ub.doc-line where ub.doc-line.prod-type = goods.prod-type
                            and ub.doc-line.prod-code = goods.prod-code
                            and ub.doc-line.artic = goods.artic
                            and ub.doc-line.obj-type = v-user-obj-type
                            and ub.doc-line.obj-code = v-user-obj-code
                            and ub.doc-line.status_ = 'факт':U
                            use-index fact-order no-lock no-error.
        if available ub.doc-line and
          can-find (ub.trn-doc where ub.trn-doc.doc-code = ub.doc-line.doc-code and ub.trn-doc.doc-type <> 'инв':U no-lock) then
          run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      end.
      assign                                                           buf_gds-list-flt-hist.num-add  = lns-cnt - v-num-add                       buf_gds-list-flt-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_gds-list-flt-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_gds-list-flt-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "scales-gds" or when "scales-gds-num"  then do:
    find first buf_gds-list-flt-hist where
             buf_gds-list-flt-hist.id = p-id
         AND buf_gds-list-flt-hist.item_ <> '':U no-error .
    assign
    v-obj-type = entry(1, buf_gds-list-flt-hist.item_, chr(3))
    v-obj-code = integer(entry(2, buf_gds-list-flt-hist.item_, chr(3)))
    vvalue = (if rs-list-method = "scales-gds" then '':U else entry(3, buf_gds-list-flt-hist.item_, chr(3)))
    no-error
    .
    if error-status:error then do: end. else do:
      for each ub.scales-gds no-lock where
              ub.scales-gds.obj-type = v-obj-type
            and ub.scales-gds.obj-code = v-obj-code,
          first ub.bar-code no-lock where
                ub.bar-code.b-code = ub.scales-gds.b-code,
          first ub.goods no-lock where
                ub.goods.gds-code = bar-code.b-code:
        if rs-list-method = "scales-gds-num" then do:
          if ub.scales-gds.scales-num <> integer( vvalue) then NEXT.
        end.
        run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      end.
      assign                                                           buf_gds-list-flt-hist.num-add  = lns-cnt - v-num-add                       buf_gds-list-flt-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_gds-list-flt-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_gds-list-flt-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
    end.
  end.
  when "parts-last-date" then do:
    find first buf_gds-list-flt-hist where
             buf_gds-list-flt-hist.id = p-id
         AND buf_gds-list-flt-hist.item_ <> '':U no-error .
    assign
    v-obj-type = entry(1, buf_gds-list-flt-hist.item_, chr(3))
    v-obj-code = integer(entry(2, buf_gds-list-flt-hist.item_, chr(3)))
    vvalue-int = integer(entry(3, buf_gds-list-flt-hist.item_, chr(3)))
    no-error
    .
    if error-status:error then do: end. else do:
      for each buf_parts no-lock where
              buf_parts.obj-type = v-obj-type
            and buf_parts.obj-code = v-obj-code
            and buf_parts.out-code  = 'free-zone':U
            and buf_parts.status_   = false:
        if buf_parts.last-date <> ?
        and (buf_parts.last-date - today) < vvalue-int then do:
          find first goods no-lock where
                goods.artic = buf_parts.artic
            and goods.prod-type = buf_parts.prod-type
            and goods.prod-code = buf_parts.prod-code no-error.
          if available goods then do:
            run ex-gds in this-procedure ( buffer goods, input rs-list-method, input rs-status, input line-mode).
            assign                                                           buf_gds-list-flt-hist.num-add  = lns-cnt - v-num-add                       buf_gds-list-flt-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_gds-list-flt-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_gds-list-flt-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
          end.
        end.
      end.
    end.
  end.
  when "parts-fib" then do:
    find first buf_gds-list-flt-hist where
             buf_gds-list-flt-hist.id = p-id
         AND buf_gds-list-flt-hist.item_ <> '':U no-error .
    assign
    v-obj-type = entry(1, buf_gds-list-flt-hist.item_, chr(3))
    v-obj-code = integer(entry(2, buf_gds-list-flt-hist.item_, chr(3)))
    no-error
    .
    if error-status:error then do: end. else do:
      for each buf_parts no-lock where
              buf_parts.obj-type = v-obj-type
            and buf_parts.obj-code = v-obj-code
            and buf_parts.out-code  = 'free-zone':U
            and buf_parts.status_   = false:
        if buf_parts.defect = logical('yes':U) then do:
          find first goods no-lock where
                goods.artic = buf_parts.artic
            and goods.prod-type = buf_parts.prod-type
            and goods.prod-code = buf_parts.prod-code no-error.
          if available goods then do:
            run ex-gds in this-procedure ( buffer goods, input rs-list-method, input rs-status, input line-mode).
            assign                                                           buf_gds-list-flt-hist.num-add  = lns-cnt - v-num-add                       buf_gds-list-flt-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_gds-list-flt-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_gds-list-flt-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
          end.
        end.
      end.
    end.
  end.
  when "cashparts":U  then do:
    find first buf_gds-list-flt-hist where
             buf_gds-list-flt-hist.id = p-id
         AND buf_gds-list-flt-hist.item_ <> '':U no-error .
    assign
    v-obj-type = entry(1, buf_gds-list-flt-hist.item_, chr(3))
    v-obj-code = integer(entry(2, buf_gds-list-flt-hist.item_, chr(3)))
    no-error
    .
    if error-status:error then do: end. else do:
      for each ub.gds-obj no-lock where
              ub.gds-obj.obj-type = v-obj-type
            and ub.gds-obj.obj-code = v-obj-code
            and ub.gds-obj.cash-parts:
        find first goods no-lock where
              goods.artic = ub.gds-obj.artic
          and goods.prod-type = ub.gds-obj.prod-type
          and goods.prod-code = ub.gds-obj.prod-code no-error.
        if available goods then do:
          run ex-gds in this-procedure ( buffer goods, input rs-list-method, input rs-status, input line-mode).
          assign                                                           buf_gds-list-flt-hist.num-add  = lns-cnt - v-num-add                       buf_gds-list-flt-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_gds-list-flt-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_gds-list-flt-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
        end.
      end.
    end.
  end.
  when "doc-list"
  or
  when "prod-list"
  or
  when "supp-list"
  or
  when "cli-list"
  or
  when "scaner"
  or
  when "file"
  or
  when "clob-data"
  then do:
    run proc-file-list-methods in this-procedure(input p-from-macro, input rs-list-method, input rs-status, input line-mode, input p-id). .
  end.
  when "deleted" then do:
    find first buf_gds-list-flt-hist where
              buf_gds-list-flt-hist.id = p-id.
    for each ub.goods where ub.goods.stts > 0 no-lock:
      run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
    end.
    assign                                                           buf_gds-list-flt-hist.num-add  = lns-cnt - v-num-add                       buf_gds-list-flt-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_gds-list-flt-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_gds-list-flt-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
  end.
  when "filter" then do:
    define variable v-filter-var as character no-undo .
    find first buf_gds-list-flt-hist where
             buf_gds-list-flt-hist.id = p-id
         AND buf_gds-list-flt-hist.item_ <> '':U .
    run proc-write-filter-expression-var in this-procedure ( input buf_gds-list-flt-hist.item_, output v-filter-var ).
      run gbl/gdf-fill.p (
                     input "Формирование списка по фильтру (без учета сортировки)"
                   , input rs-list-method
                   , input rs-status
                   , input line-mode
                   , input v-filter-var
                   , output lns-cnt
                   , output line-rec
                   ) .
     assign                                                           buf_gds-list-flt-hist.num-add  = lns-cnt - v-num-add                       buf_gds-list-flt-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_gds-list-flt-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_gds-list-flt-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
  end.
    when "no-recipe-gds":U then do:
     for each buf_gds-list-flt-hist where
             buf_gds-list-flt-hist.id = p-id
        and  buf_gds-list-flt-hist.item_ <> '':U:
      run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_gds-list-flt-hist.item_, v-no-context)                                                        ,input ?                                                                          ,input 'ub'                                                                       ,input ?                                                                          ,input no-lock                                                                    ,output v-rowid                                                                  ,output v-tbl-name) no-error .                  if error-status:error then  next.
      grp-path = "".
      find first gds-grp no-lock where rowid(gds-grp) = v-rowid.
      run grplib-get-full-name in this-procedure (gds-grp.node-code, output grp-path).
      goods:
      for each goods where goods.grp-name begins grp-path no-lock,
          each recipe no-lock where recipe.artic = ub.goods.artic
                        and recipe.prod-type = ub.goods.prod-type
                        and recipe.prod-code = ub.goods.prod-code :
          for each recipe-gds where recipe-gds.recipe-code = recipe.recipe-code no-lock:
          if can-find(first gds-obj no-lock where gds-obj.obj-type = v-cntxt-obj-type
                                  and gds-obj.obj-code = v-cntxt-obj-code
                                  and gds-obj.gds-code = recipe-gds.gds-code
                                  and gds-obj.fact-qnty > 0) then.
          else do:
                run ex-gds  in this-procedure ( buffer goods, input rs-list-method, input rs-status, input line-mode).
                next goods.
            end.
          end.
      end.
      assign                                                           buf_gds-list-flt-hist.num-add  = lns-cnt - v-num-add                       buf_gds-list-flt-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_gds-list-flt-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_gds-list-flt-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
     end.
  end.
  when "move-date":U then do:
      find first buf_gds-list-flt-hist where
          buf_gds-list-flt-hist.id = p-id
      AND buf_gds-list-flt-hist.item_ <> '':U .
      for each gds-obj  no-lock where gds-obj.obj-type = v-cntxt-obj-type
                                  and gds-obj.obj-code = v-cntxt-obj-code
                                  and gds-obj.last-doc >= date(buf_gds-list-flt-hist.item_):
          for first goods no-lock where
                goods.artic = ub.gds-obj.artic
            and goods.prod-type = ub.gds-obj.prod-type
            and goods.prod-code = ub.gds-obj.prod-code:
            run ex-gds in this-procedure ( buffer goods, input rs-list-method, input rs-status, input line-mode).
            assign                                                           buf_gds-list-flt-hist.num-add  = lns-cnt - v-num-add                       buf_gds-list-flt-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_gds-list-flt-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_gds-list-flt-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
          end.
      end.
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
if line-mode <> 'ОСТАВИТЬ':U then  run UI-on in this-procedure.
end.
END PROCEDURE.
PROCEDURE write-hist :
define input parameter p-from-macro as logical no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
define input parameter line-mode as character no-undo .
define variable v-ii as integer no-undo .
define variable v-temp-seq as integer no-undo .
if rs-list-method = "single" then do:
  if v-no-hist < 0 then do:
    run create-gds-list-flt-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                        , input-output v-seq
                                        , input 0
                                        , input get-hist-mode(line-mode)
                                        , input substitute("ТОВАР код &1 &2 &3&4 &5", gds-list-flt.gds-code, gds-list-flt.artic, gds-list-flt.prod-type, gds-list-flt.prod-code, gds-list-flt.gds-name)
                                        , input tot-lns
                                        , input rs-list-method
                                        , input rs-status
                                        , input ('goods':U + chr(3) + string(gds-list-flt.gds-code))
                                        , input '':U
                                        , input ?
                                        ).
  end.
  else do:
    v-temp-seq = v-seq - 1.
    do v-ii = 0 to v-no-hist:
      run create-gds-list-flt-hist in this-procedure(input ('ИЗМЕНЕНИЕ':U + chr(4) + 'mode':U)
                                          , input-output v-temp-seq
                                          , input v-ii
                                          , input get-hist-mode(line-mode)
                                          , input substitute("ТОВАР код &1 &2 &3&4 &5", gds-list-flt.gds-code, gds-list-flt.artic, gds-list-flt.prod-type, gds-list-flt.prod-code, gds-list-flt.gds-name)
                                          , input tot-lns
                                          , input '':U
                                          , input '':U
                                          , input ('goods':U + chr(3) + string(gds-list-flt.gds-code))
                                          , input '':U
                                          , input ?
                                          ).
    end.
  end.
end.
else do:
  v-temp-seq = v-seq - 1.
  do v-ii = 0 to v-no-hist:
    run create-gds-list-flt-hist in this-procedure(input ('ИЗМЕНЕНИЕ':U + chr(4) + 'mode':U)
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
END PROCEDURE.
procedure list_inf-local:
define variable glog as logical no-undo .
for each tt-goods:
  delete tt-goods.
end.
for each tt-clients:
  delete tt-clients.
end.
for each gds-list-flt:
find ub.goods where ub.goods.artic     = gds-list-flt.artic     and
                ub.goods.prod-type = gds-list-flt.prod-type and
                ub.goods.prod-code = gds-list-flt.prod-code no-lock.
    create tt-goods.
    buffer-copy ub.goods to tt-goods.
end.
create tt-clients.
assign tt-clients.obj-type = p-curr-obj-type
      tt-clients.obj-code = p-curr-obj-code.
define variable vss-include-info58 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reference_archive':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
if glog then run arc/gds_inf.w
(input  parparentproc
,input  v-cntxt-obj-type
,input  v-cntxt-obj-code ).
end procedure.
FUNCTION stat-line RETURNS CHARACTER(input p-status-chr as character):
DEFINE VARIABLE var-stat-line as character no-undo .
CASE p-status-chr:
  when 'все':U then do:
    assign
    var-stat-line = "(текущие и неактивные товары)"
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
define variable glog as logical no-undo .
define variable ii as integer no-undo .
define variable v-recs as integer no-undo .
define variable v-line as integer no-undo .
define variable v-item as character no-undo .
define variable v-tbl-name as character no-undo .
define variable v-bh as handle no-undo .
define variable v-tot-lns as integer no-undo .
define variable v-grp-rec as recid no-undo .
define variable v-ref-rec as recid no-undo .
define variable v-dopstr as character no-undo .
define variable v-input-output as character no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-temp-seq as integer no-undo .
define variable v-message as character no-undo .
define variable grp-path as character no-undo .
define variable v-rid-list as character no-undo .
define variable v-uniq-key-rec as character no-undo .
define buffer buf_gds-list-flt-hist for gds-list-flt-hist.
define buffer buf_clob-bind for ub.clob-bind.
do
on error undo, return error
:
  v-no-hist = - 1.
  if temp-list.fvalue = "single" then
  run UI-on in this-procedure.
  else do:
    v-no-hist = 0.
    case rs-list-method:
      when "all" then do:
        glog = yes.
        message "Все товары из справочника товаров"
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run UI-on in this-procedure.
          return error .
        end.
        v-no-hist = 1.
        run create-gds-list-flt-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                            , input-output v-seq
                                            , input 0
                                            , input '':U
                                            , input substitute('Все товары &1', stat-line(rs-status))
                                            , input tot-lns
                                            , input rs-list-method
                                            , input rs-status
                                            , input 'all':U
                                            , input '':U
                                            , input ?
                                            ).
      end.
      when "gds-grp" or
      when "goods" or
      when "gds-obj":U or
      when "gds-obj-fact":U or
      when "gds-obj-free":U or
      when "no-recipe-gds":U
      then do:
        if rs-list-method = "gds-grp" or rs-list-method = "no-recipe-gds" then do:
          glog = yes.
          message "1 или несколько групп товаров"
          skip stat-line(rs-status)
          view-as alert-box question buttons OK-Cancel update glog.
          if not glog then do:
            run UI-on in this-procedure.
            return error.
          end.
          grp-list = "".
          ref-list = "".
          run ref/gds-grp.w (input parparentproc
                        ,input "b-sel,b-mark"
                        ,input p-curr-obj-type
                        ,input p-curr-obj-code
                        ,input-output grp-list).
        end.
        else do:
          glog = yes.
          message "1 или несколько произвольных товаров из справочника."
          skip stat-line(rs-status)
          view-as alert-box question buttons OK-Cancel update glog.
          if not glog then do:
            run UI-on in this-procedure.
            return error.
          end.
          run ref/gds-ref.p ( parparentproc
                          ,"b-sel,b-mark,b-add"
                          ,?
                          ,?
                          ,(if rs-list-method = "goods"
                            then 'все':U
                            else (if rs-list-method = "gds-obj":U
                                  then 'объект':U
                                  else (if rs-list-method = "gds-obj-fact":U
                                        then 'факт':U
                                        else (if rs-list-method = "gds-obj-free":U
                                              then 'свободно':U
                                              else ?
                                              )
                                        )
                                  )
                          )
                          ,?
                          ,?
                          ,?
                          ,?
                          ,p-curr-obj-type
                          ,p-curr-obj-code
                          ,?
                          , output ref-list).
          grp-list = ?.
        end.
        if grp-list <> ? and
        grp-list <> "" then do:
          v-recs = num-entries (grp-list).
          do num-rec = 0 to v-recs:
            if v-recs = 1 then do:
              num-rec = 1 .
            end.
            if num-rec > 0 then do:
              v-grp-rec = integer (entry (num-rec, grp-list)).
              find ub.gds-grp where recid (ub.gds-grp) = v-grp-rec no-lock.
              run grplib-get-full-name in this-procedure (ub.gds-grp.node-code, output grp-path).
            end.
            if v-recs = 1 then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("Группа : &1 &3", grp-path, stat-line(rs-status))
              v-item     = '':U
              v-tbl-name = 'gds-grp':U
              v-bh       = buffer ub.gds-grp:handle
              v-tot-lns = tot-lns
              .
            end.
            else do:
              if num-rec = 0 then do:
                assign
                v-temp-seq = v-seq
                v-line     = 0
                dsp-rs = substitute("Группы : &1", stat-line(rs-status))
                v-item     = '':U
                v-tbl-name = '':U
                v-bh       = ?
                v-tot-lns = tot-lns
                .
              end.
              else do:
                assign
                v-temp-seq = v-seq - 1
                v-line     = num-rec
                dsp-rs = substitute("&1", grp-path)
                v-item     = '':U
                v-tbl-name = 'gds-grp':U
                v-bh       = buffer ub.gds-grp:handle
                v-tot-lns = tot-lns + num-rec
                .
              end.
            end.
            v-no-hist = (if num-rec = 1 then 0 else num-rec).
            run create-gds-list-flt-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                                , input-output v-temp-seq
                                                , input v-line
                                                , input '':U
                                                , input dsp-rs
                                                , input v-tot-lns
                                                , input rs-list-method
                                                , input rs-status
                                                , input v-item
                                                , input v-tbl-name
                                                , input v-bh
                                                ).
            if num-rec = 0 or v-recs = 1 then v-seq  = v-temp-seq.
          end.
        end.
        else if ref-list <> "" then do:
          v-recs = num-entries (ref-list).
          do num-rec = 0 to v-recs:
            if v-recs = 1 then do:
              num-rec = 1 .
            end.
            if num-rec > 0 then do:
              v-ref-rec = integer (entry (num-rec, ref-list)).
              find ub.goods where recid (ub.goods) = v-ref-rec no-lock.
            end.
            if v-recs = 1 then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("Товар :&1 &2", ub.goods.gds-name, stat-line(rs-status))
              v-item     = '':U
              v-tbl-name = 'goods':U
              v-bh       = buffer goods:handle
              v-tot-lns = tot-lns
              .
            end.
            else do:
              if num-rec = 0 then do:
                assign
                v-temp-seq = v-seq
                v-line     = 0
                dsp-rs = substitute("Товары : &1", stat-line(rs-status))
                v-item     = '':U
                v-tbl-name = '':U
                v-bh       = ?
                v-tot-lns = tot-lns
                .
              end.
              else do:
                assign
                v-temp-seq = v-seq - 1
                v-line     = num-rec
                dsp-rs = substitute("код &1 &2 &3&4 &5", goods.gds-code, goods.artic, goods.prod-type, goods.prod-code, goods.gds-name)
                v-item     = '':U
                v-tbl-name = 'goods':U
                v-bh       = buffer ub.goods:handle
                v-tot-lns = tot-lns + num-rec
                .
              end.
            end.
            v-no-hist = (if num-rec = 1 then 0 else num-rec).
            run create-gds-list-flt-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                                , input-output v-temp-seq
                                                , input v-line
                                                , input '':U
                                                , input dsp-rs
                                                , input v-tot-lns
                                                , input rs-list-method
                                                , input rs-status
                                                , input v-item
                                                , input v-tbl-name
                                                , input v-bh
                                                ).
            if num-rec = 0 or v-recs = 1 then v-seq  = v-temp-seq.
          end.
        end.
        else do:
          run UI-on in this-procedure.
          return error.
        end.
      end.
      when "grp-prod" or
      when "producer" then do:
        if rs-list-method = "grp-prod" then do:
          glog = yes.
          message "товары по производителям из 1 или нескольких групп."
          skip stat-line(rs-status)
          view-as alert-box question buttons OK-Cancel update glog.
          if not glog then do:
            run UI-on in this-procedure.
            return error.
          end.
          grp-list = "".
          ref-list = "".
          run ref/cli-grps.w ( input parparentproc
                              ,input "b-sel,b-mark"
                              ,input-output grp-list).
        end.
        else do:
          glog = yes.
          message "товары по 1 или нескольким производителям из справочника."
          skip stat-line(rs-status)
          view-as alert-box question buttons OK-Cancel update glog.
          if not glog then do:
            run UI-on in this-procedure.
            return error.
          end.
          grp-list = "".
          run ref/cli-all.w ( parparentproc
                        ,"b-sel,b-mark"
                        , ?
                        , ?
                        , ?
                        , ?
                        , ?
                        , ?
                        , output ref-list) .
        end.
        if grp-list <> ? and
        grp-list <> "" then do:
          v-recs = num-entries (grp-list).
          do num-rec = 0 to v-recs:
            if v-recs = 1 then do:
              num-rec = 1 .
            end.
            if num-rec > 0 then do:
              v-grp-rec = integer (entry (num-rec, grp-list)).
              find ub.cli-grp where recid (ub.cli-grp) = v-grp-rec no-lock.
              run cli-grplib-get-full-name in this-procedure (ub.cli-grp.node-code, output grp-path).
            end.
            if v-recs = 1 then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("Группа пр-лей: &1 &2", grp-path, stat-line(rs-status))
              v-item     = '':U
              v-tbl-name = 'cli-grp':U
              v-bh       = buffer cli-grp:handle
              v-tot-lns = tot-lns
              .
            end.
            else do:
              if num-rec = 0 then do:
                assign
                v-temp-seq = v-seq
                v-line     = 0
                dsp-rs = substitute("Группы пр-лей: &1", stat-line(rs-status))
                v-item     = '':U
                v-tbl-name = '':U
                v-bh       = ?
                v-tot-lns = tot-lns
                .
              end.
              else do:
                assign
                v-temp-seq = v-seq - 1
                v-line     = num-rec
                dsp-rs = substitute("&1", grp-path)
                v-item     = '':U
                v-tbl-name = 'cli-grp':U
                v-bh       = buffer cli-grp:handle
                v-tot-lns = tot-lns + num-rec
                .
              end.
            end.
            v-no-hist = (if num-rec = 1 then 0 else num-rec).
            run create-gds-list-flt-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                                , input-output v-temp-seq
                                                , input v-line
                                                , input '':U
                                                , input dsp-rs
                                                , input v-tot-lns
                                                , input rs-list-method
                                                , input rs-status
                                                , input v-item
                                                , input v-tbl-name
                                                , input v-bh
                                                ).
            if num-rec = 0 or v-recs = 1 then v-seq  = v-temp-seq.
          end.
        end.
        else if ref-list <> "" and  ref-list <> ? then do:
          v-recs = num-entries (ref-list) .
          do num-rec = 0 to v-recs:
            if v-recs = 1 then do:
              num-rec = 1 .
            end.
            if num-rec > 0 then do:
              v-ref-rec = integer (entry (num-rec, ref-list)).
              find ub.clients where recid (ub.clients) = v-ref-rec no-lock.
            end.
            if v-recs = 1 then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("Производитель :&1 &2", clients.obj-name, stat-line(rs-status))
              v-item     = '':U
              v-tbl-name = 'clients':U
              v-bh       = buffer ub.clients:handle
              v-tot-lns = tot-lns
              .
            end.
            else do:
              if num-rec = 0 then do:
                assign
                v-temp-seq = v-seq
                v-line     = 0
                dsp-rs = substitute("Производитель : &1", stat-line(rs-status))
                v-item     = '':U
                v-tbl-name = '':U
                v-bh       = ?
                v-tot-lns = tot-lns
                .
              end.
              else do:
                assign
                v-temp-seq = v-seq - 1
                v-line     = num-rec
                dsp-rs = substitute("&1", clients.obj-name)
                v-item     = '':U
                v-tbl-name = 'clients':U
                v-bh       = buffer ub.clients:handle
                v-tot-lns = tot-lns + num-rec
                .
              end.
            end.
            v-no-hist = (if num-rec = 1 then 0 else num-rec).
            run create-gds-list-flt-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                                , input-output v-temp-seq
                                                , input v-line
                                                , input '':U
                                                , input dsp-rs
                                                , input v-tot-lns
                                                , input rs-list-method
                                                , input rs-status
                                                , input v-item
                                                , input v-tbl-name
                                                , input v-bh
                                                ).
            if num-rec = 0 or v-recs = 1 then v-seq  = v-temp-seq.
          end.
        end.
        else do:
          run UI-on in this-procedure.
          return error.
        end.
      end.
      when "choose-alc-prod" then do:
          grp-list = "".
          run ref/alc-type.w ( input parparentproc
                              ,input "b-sel,b-mark"
                              ,input-output grp-list
                              ,output v-ok ).
        if grp-list <> ? and
        grp-list <> "" then do:
          v-recs = num-entries (grp-list).
          do num-rec = 0 to v-recs:
            if v-recs = 1 then do:
              num-rec = 1 .
            end.
            if num-rec > 0 then do:
              v-grp-rec = integer (entry (num-rec, grp-list)).
              find ub.alc-type where recid (ub.alc-type) = v-grp-rec no-lock.
              run grplib-get-full-name-alc-type in this-procedure (ub.alc-type.alc-type-inner-code, output grp-path).
            end.
            if v-recs = 1 then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("Вид алкогольной продукции: &1 &2", grp-path, stat-line(rs-status))
              v-item     = '':U
              v-tbl-name = 'alc-type':U
              v-bh       = buffer ub.alc-type:handle
              v-tot-lns = tot-lns
              .
            end.
            else do:
              if num-rec = 0 then do:
                assign
                v-temp-seq = v-seq
                v-line     = 0
                dsp-rs = substitute("Виды алкогольной продукции: &1", stat-line(rs-status))
                v-item     = '':U
                v-tbl-name = '':U
                v-bh       = ?
                v-tot-lns = tot-lns
                .
              end.
              else do:
                assign
                v-temp-seq = v-seq - 1
                v-line     = num-rec
                dsp-rs = substitute("&1", grp-path)
                v-item     = '':U
                v-tbl-name = 'alc-type':U
                v-bh       = buffer alc-type:handle
                v-tot-lns = tot-lns + num-rec
                .
              end.
            end.
            v-no-hist = (if num-rec = 1 then 0 else num-rec).
            run create-gds-list-flt-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                                , input-output v-temp-seq
                                                , input v-line
                                                , input '':U
                                                , input dsp-rs
                                                , input v-tot-lns
                                                , input rs-list-method
                                                , input rs-status
                                                , input v-item
                                                , input v-tbl-name
                                                , input v-bh
                                                ).
            if num-rec = 0 or v-recs = 1 then v-seq  = v-temp-seq.
          end.
        end.
      end.
      when "grp-supp" or
      when "supplier" then do:
        if rs-list-method = "grp-supp" then do:
          glog = yes.
          message "товары по поставщикам из 1 или нескольких групп."
          skip stat-line(rs-status)
          view-as alert-box question buttons OK-Cancel update glog.
          if not glog then do:
            run UI-on in this-procedure.
            return error.
          end.
          grp-list = "".
          ref-list = "".
          run ref/cli-grps.w ( input parparentproc
                              ,input "b-sel,b-mark"
                              ,input-output grp-list).
        end.
        else do:
          glog = yes.
          message "товары по 1 или нескольким поставщикам из справочника."
          skip stat-line(rs-status)
          view-as alert-box question buttons OK-Cancel update glog.
          if not glog then do:
            run UI-on in this-procedure.
            return error.
          end.
          grp-list = "".
          run ref/cli-all.w (parparentproc
                        , "b-sel,b-mark"
                        , ?
                        , ?
                        , ?
                        , ?
                        , ?
                        , ?
                        , output ref-list) .
        end.
        if grp-list <> ? and
        grp-list <> "" then do:
          v-recs = num-entries (grp-list).
          do num-rec = 0 to v-recs:
            if v-recs = 1 then do:
              num-rec = 1 .
            end.
            if num-rec > 0 then do:
              v-grp-rec = integer (entry (num-rec, grp-list)).
              find cli-grp where recid (cli-grp) = v-grp-rec no-lock.
              run cli-grplib-get-full-name in this-procedure (cli-grp.node-code, output grp-path).
            end.
            if v-recs = 1 then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("Группа поставщиков: &1 &2", grp-path, stat-line(rs-status))
              v-item     = '':U
              v-tbl-name = 'cli-grp':U
              v-bh       = buffer cli-grp:handle
              v-tot-lns = tot-lns
              .
            end.
            else do:
              if num-rec = 0 then do:
                assign
                v-temp-seq = v-seq
                v-line     = 0
                dsp-rs = substitute("Группы поставщиков: &1", stat-line(rs-status))
                v-item     = '':U
                v-tbl-name = '':U
                v-bh       = ?
                v-tot-lns = tot-lns
                .
              end.
              else do:
                assign
                v-temp-seq = v-seq - 1
                v-line     = num-rec
                dsp-rs = substitute("&1", grp-path)
                v-item     = '':U
                v-tbl-name = 'cli-grp':U
                v-bh       = buffer cli-grp:handle
                v-tot-lns = tot-lns + num-rec
                .
              end.
            end.
            v-no-hist = (if num-rec = 1 then 0 else num-rec).
            run create-gds-list-flt-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                                , input-output v-temp-seq
                                                , input v-line
                                                , input '':U
                                                , input dsp-rs
                                                , input v-tot-lns
                                                , input rs-list-method
                                                , input rs-status
                                                , input v-item
                                                , input v-tbl-name
                                                , input v-bh
                                                ).
            if num-rec = 0 or v-recs = 1 then v-seq  = v-temp-seq.
          end.
        end.
        else if ref-list <> "" and ref-list <> ? then do:
          v-recs = num-entries (ref-list).
          do num-rec = 0 to v-recs:
            if v-recs = 1 then do:
              num-rec = 1 .
            end.
            if num-rec > 0 then do:
              v-ref-rec = integer (entry (num-rec, ref-list)).
              find clients where recid (clients) = v-ref-rec no-lock.
            end.
            if v-recs = 1 then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("Поставщик :&1 &2", clients.obj-name, stat-line(rs-status))
              v-item     = '':U
              v-tbl-name = 'clients':U
              v-bh       = buffer clients:handle
              v-tot-lns = tot-lns
              .
            end.
            else do:
              if num-rec = 0 then do:
                assign
                v-temp-seq = v-seq
                v-line     = 0
                dsp-rs = substitute("Поставщики : &1", stat-line(rs-status))
                v-item     = '':U
                v-tbl-name = '':U
                v-bh       = ?
                v-tot-lns = tot-lns
                .
              end.
              else do:
                assign
                v-temp-seq = v-seq - 1
                v-line     = num-rec
                dsp-rs = substitute("&1", clients.obj-name)
                v-item     = '':U
                v-tbl-name = 'clients':U
                v-bh       = buffer clients:handle
                v-tot-lns = tot-lns + num-rec
                .
              end.
            end.
            v-no-hist = (if num-rec = 1 then 0 else num-rec).
            run create-gds-list-flt-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                                , input-output v-temp-seq
                                                , input v-line
                                                , input '':U
                                                , input dsp-rs
                                                , input v-tot-lns
                                                , input rs-list-method
                                                , input rs-status
                                                , input v-item
                                                , input v-tbl-name
                                                , input v-bh
                                                ).
            if num-rec = 0 or v-recs = 1 then v-seq  = v-temp-seq.
          end.
        end.
        else do:
          run UI-on in this-procedure.
          return error.
        end.
      end.
      when "waybill" then do:
        glog = yes.
        message "Все товары из документов (накладных)."
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run UI-on in this-procedure.
          return error.
        end.
        run str/all-docs.w (input parparentproc
                      ,input (if v-docs-all
                             then ?
                             else v-cntxt-host-code-obj)
                      ,input (if v-docs-all
                             then ?
                             else v-cntxt-obj-type)
                      ,input (if v-docs-all
                             then ?
                             else v-cntxt-obj-code)
                      ,input (if v-docs-all
                              then 'работа':U
                              else (if v-docs-cmp
                                   then 'фирма':U
                                   else 'объект':U)
                              )
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input 'b-sel,b-mark':U
                      ,input '':U
                      ,input ?
                      ,input ?
                      ,output ref-list
                      ) no-error .
        if ref-list = "" then do:
          run UI-on in this-procedure.
          return error.
        end.
        v-recs = num-entries(ref-list).
        do num-rec = 0 to v-recs:
          if v-recs = 1 then do:
            num-rec = 1 .
          end.
          if num-rec > 0 then do:
            v-ref-rec = integer (entry (num-rec, ref-list)).
            find ub.trn-doc where recid (ub.trn-doc) = v-ref-rec no-lock.
          end.
          if v-recs = 1 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Документ : &1 &2 &3 &4 № &5 от &6 &7"
                                , ub.trn-doc.doc-type
                                , ub.trn-doc.status_
                                , ub.trn-doc.obj-type
                                , ub.trn-doc.obj-code
                                , ub.trn-doc.doc-code
                                , string (ub.trn-doc.doc-date, '99/99/9999')
                                , stat-line(rs-status)
                                )
            v-item     = '':U
            v-tbl-name = 'trn-doc':U
            v-bh       = buffer ub.trn-doc:handle
            v-tot-lns = tot-lns
            .
          end.
          else do:
            if num-rec = 0 then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("Документы : &1", stat-line(rs-status))
              v-item     = '':U
              v-tbl-name = '':U
              v-bh       = ?
              v-tot-lns = tot-lns
              .
            end.
            else do:
              assign
              v-temp-seq = v-seq - 1
              v-line     = num-rec
              dsp-rs = substitute("&1 &2 &3 &4 № &5 от &6"
                                  , ub.trn-doc.doc-type
                                  , ub.trn-doc.status_
                                  , ub.trn-doc.obj-type
                                  , ub.trn-doc.obj-code
                                  , ub.trn-doc.doc-code
                                  , string (ub.trn-doc.doc-date, '99/99/9999')
                                  )
              v-item     = '':U
              v-tbl-name = 'trn-doc':U
              v-bh       = buffer ub.trn-doc:handle
              v-tot-lns = tot-lns + num-rec
              .
            end.
          end.
          v-no-hist = (if num-rec = 1 then 0 else num-rec).
          run create-gds-list-flt-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                              , input-output v-temp-seq
                                              , input v-line
                                              , input '':U
                                              , input dsp-rs
                                              , input v-tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input v-item
                                              , input v-tbl-name
                                              , input v-bh
                                              ).
          if num-rec = 0 or v-recs = 1 then v-seq  = v-temp-seq.
        end.
      end.
      when "manufacture" then do:
        glog = yes.
        message "Все товары из 1 документа производства."
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run UI-on in this-procedure.
          return error.
        end.
        ref-list = '':U.
        run str/fbr-docs.w ( input parparentproc
                            ,input  ?
                            ,input (if v-docs-all
                                    then 'работа':U
                                    else 'объект':U
                                    )
                           ,input-output ref-list).
        if ref-list = '':u then do:
          run UI-on in this-procedure.
          return error.
        end.
        v-doc-rec = integer(entry(1, ref-list)).
        if v-doc-rec = ? then do:
          run UI-on in this-procedure.
          return error.
        end.
        find ub.fbr-doc where recid (ub.fbr-doc) = v-doc-rec no-lock.
          run create-gds-list-flt-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                              , input-output v-seq
                                              , input 0
                                              , input '':U
                                              , input  substitute("Производство : &1 &2 &3 № &4 от &5 &7"
                                                                  ,fbr-doc.status_
                                                                  ,fbr-doc.obj-type
                                                                  ,fbr-doc.obj-code
                                                                  ,fbr-doc.doc-code
                                                                  ,string (fbr-doc.doc-date, '99/99/9999')
                                                                  , stat-line(rs-status)
                                                                  )
                                              , input tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input '':U
                                              , input 'fbr-doc':U
                                              , input buffer ub.fbr-doc:handle
                                              ).
      end.
      when "recipe" then do:
        glog = yes.
        message "Все товары из 1 рецепта."
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run UI-on in this-procedure.
          return error.
        end.
        run ref/rcp-all.w (
            input parparentproc
          , input "b-sel"
          , input 'все':U
          , input ?
          , input p-curr-obj-type
          , input p-curr-obj-code
          , output ref-list
        ).
        if ref-list = "" then do:
          run UI-on in this-procedure.
          return error.
        end.
        find ub.recipe where recid (ub.recipe) = integer (ref-list) no-lock.
        run create-gds-list-flt-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                            , input-output v-seq
                                            , input 0
                                            , input '':U
                                            , input substitute("Товары рецепта : &1 &2 Артикул &3 &4"
                                                              , ub.recipe.recipe-code
                                                              , ub.recipe.recipe-name
                                                              , ub.recipe.artic
                                                              , stat-line(rs-status)
                                                              )
                                            , input tot-lns
                                            , input rs-list-method
                                            , input rs-status
                                            , input '':U
                                            , input 'recipe':U
                                            , input buffer ub.recipe:handle
                                            ).
      end.
      when "self-recipe" then do:
        glog = yes.
        message "Товар с рецептом."
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run UI-on in this-procedure.
          return error.
        end.
        run ref/rcp-all.w (
            input parparentproc
          , input "b-sel"
          , input 'все':U
          , input ?
          , input p-curr-obj-type
          , input p-curr-obj-code
          , output ref-list
        ).
        if ref-list = "" then do:
          run UI-on in this-procedure.
          return error.
        end.
        find ub.recipe where recid (ub.recipe) = integer (ref-list) no-lock.
        run create-gds-list-flt-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                            , input-output v-seq
                                            , input 0
                                            , input '':U
                                            , input substitute("Рецепт : &1 &2 Артикул &3 &4"
                                                              , ub.recipe.recipe-code
                                                              , ub.recipe.recipe-name
                                                              , ub.recipe.artic
                                                              , stat-line(rs-status)
                                                              )
                                            , input tot-lns
                                            , input rs-list-method
                                            , input rs-status
                                            , input '':U
                                            , input 'recipe':U
                                            , input buffer ub.recipe:handle
                                            ).
      end.
      when "contract" then do:
        glog = yes.
        message "Все товары из спецификаций договоров."
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run UI-on in this-procedure.
          return error.
        end.
        ref-list = '' .
        run str/cont-all.w (
            input parparentproc
          , input p-curr-host-code
          , input "b-sel,b-mark"
          , input 'все':U
          , input ?
          , input ?
          , input ?
          , input ?
          , input "current":U
          , input "all":U
          , input-output ref-list ) .
        if ref-list = "" then do:
          run UI-on in this-procedure.
          return error.
        end.
        v-recs = num-entries(ref-list).
        do num-rec = 0 to v-recs:
          if v-recs = 1 then do:
            num-rec = 1 .
          end.
          if num-rec > 0 then do:
            v-ref-rec = integer (entry (num-rec, ref-list)).
            find ub.contract where recid (ub.contract) = v-ref-rec no-lock.
          end.
          if v-recs = 1 then do:
            assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("Договор : &1 (&2) &3",
                                   ub.contract.contract-code
                                   ,ub.contract.contract-prn-code
                                   , stat-line(rs-status) )
              v-item     = '':U
              v-tbl-name = 'contract':U
              v-bh       = buffer ub.contract:handle
              v-tot-lns = tot-lns
            .
          end.
          else do:
            if num-rec = 0 then do:
              assign
                v-temp-seq = v-seq
                v-line     = 0
                dsp-rs = substitute("Договоры : &1", stat-line(rs-status))
                v-item     = '':U
                v-tbl-name = '':U
                v-bh       = ?
                v-tot-lns = tot-lns
              .
            end.
            else do:
              assign
                v-temp-seq = v-seq - 1
                v-line     = num-rec
                dsp-rs = substitute("&1 (&2) &3"
                                     ,ub.contract.contract-code
                                     ,ub.contract.contract-prn-code
                                     , stat-line(rs-status) )
                v-item     = '':U
                v-tbl-name = 'contract':U
                v-bh       = buffer ub.contract:handle
                v-tot-lns = tot-lns + num-rec
              .
            end.
          end.
          v-no-hist = (if num-rec = 1 then 0 else num-rec).
          run create-gds-list-flt-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                              , input-output v-temp-seq
                                              , input v-line
                                              , input '':U
                                              , input dsp-rs
                                              , input v-tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input v-item
                                              , input v-tbl-name
                                              , input v-bh
                                              ).
          if num-rec = 0 or v-recs = 1 then v-seq  = v-temp-seq.
        end.
      end.
      when "overvalue" then do:
        glog = yes.
        message "Все товары из выбранных переоценок (акта или приказа)."
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run UI-on in this-procedure.
          return error.
        end.
        run str/pr-docs.w (
           input parparentproc
          ,input "b-sel,b-mark":U
          ,input (if v-docs-all
                then 'работа':U
                else (if v-docs-cmp
                      then 'фирма':U
                      else 'объект':U
                      )
                )
          ,input ""
          ,input p-curr-obj-type
          ,input p-curr-obj-code
          ,input ""
          ,output ref-list
          ).
        if ref-list = "" then do:
          run UI-on in this-procedure.
          return error.
        end.
        v-recs = num-entries(ref-list).
        do num-rec = 0 to v-recs:
          if v-recs = 1 then do:
            num-rec = 1 .
          end.
          if num-rec > 0 then do:
            v-ref-rec = integer (entry (num-rec, ref-list)).
            find ub.price-doc where recid (ub.price-doc) = v-ref-rec no-lock.
          end.
          if v-recs = 1 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Переоценка : &1 &2 &3 № &4 от &5 &6"
                                , ub.price-doc.status_
                                , ub.price-doc.obj-type
                                , ub.price-doc.obj-code
                                , ub.price-doc.doc-num
                                , string(ub.price-doc.doc-date, '99/99/9999')
                                , stat-line(rs-status)
                                )
            v-item     = '':U
            v-tbl-name = 'price-doc':U
            v-bh       = buffer ub.price-doc:handle
            v-tot-lns = tot-lns
            .
          end.
          else do:
            if num-rec = 0 then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("Переоценки : &1", stat-line(rs-status))
              v-item     = '':U
              v-tbl-name = '':U
              v-bh       = ?
              v-tot-lns = tot-lns
              .
            end.
            else do:
              assign
              v-temp-seq = v-seq - 1
              v-line     = num-rec
              dsp-rs = substitute("&1 &2 &3 № &4 от &5"
                                  , ub.price-doc.status_
                                  , ub.price-doc.obj-type
                                  , ub.price-doc.obj-code
                                  , ub.price-doc.doc-num
                                  , string(ub.price-doc.doc-date, '99/99/9999')
                                  )
              v-item     = '':U
              v-tbl-name = 'price-doc':U
              v-bh       = buffer ub.price-doc:handle
              v-tot-lns = tot-lns + num-rec
              .
            end.
          end.
          v-no-hist = (if num-rec = 1 then 0 else num-rec).
          run create-gds-list-flt-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                              , input-output v-temp-seq
                                              , input v-line
                                              , input '':U
                                              , input dsp-rs
                                              , input v-tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input v-item
                                              , input v-tbl-name
                                              , input v-bh
                                              ).
          if num-rec = 0 or v-recs = 1 then v-seq  = v-temp-seq.
        end.
      end.
      when "pdf" then do:
        glog = yes.
        message "Все товары из выбранных ДНЦ."
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run UI-on in this-procedure.
          return error.
        end.
        if v-docs-all then do:
          run str/docsprls.w ( input parparentproc
                            , input  "all"
                            , input ?
                            , input ?
                            , input "b-sel,b-mark"
                            , input-output ref-list) .
        end.
        else do:
          run str/pdfobj.w (  input parparentproc
                             ,input  "all"
                             ,input  v-cntxt-obj-type
                             ,input  v-cntxt-obj-code
                             ,input ?
                             ,input ?
                             ,input "b-sel"
                             ,input-output ref-list) .
        end.
        if ref-list = "" then do:
          run UI-on in this-procedure.
          return error.
        end.
        v-recs = num-entries(ref-list).
        do num-rec = 0 to v-recs:
          if v-recs = 1 then do:
            num-rec = 1 .
          end.
          if num-rec > 0 then do:
            v-ref-rec = integer (entry (num-rec, ref-list)).
            find ub.price-doc-forming where recid (ub.price-doc-forming) = v-ref-rec no-lock.
          end.
          if v-recs = 1 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("ДНЦ : ТПЛ &1 (БД &2) № &3 (БД &4) &5"
                                , ub.price-doc-forming.plt-db-num
                                , ub.price-doc-forming.plt-id
                                , ub.price-doc-forming.pdf-db
                                , ub.price-doc-forming.pdf-id
                                , stat-line(rs-status)
                                )
            v-item     = '':U
            v-tbl-name = 'price-doc-forming':U
            v-bh       = buffer ub.price-doc-forming:handle
            v-tot-lns = tot-lns
            .
          end.
          else do:
            if num-rec = 0 then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("ДНЦ : &1", stat-line(rs-status))
              v-item     = '':U
              v-tbl-name = '':U
              v-bh       = ?
              v-tot-lns = tot-lns
              .
            end.
            else do:
              assign
              v-temp-seq = v-seq - 1
              v-line     = num-rec
              dsp-rs = substitute("ДНЦ : ТПЛ &1 (БД &2) № &3 (БД &4) &5"
                                  , ub.price-doc-forming.plt-db-num
                                  , ub.price-doc-forming.plt-id
                                  , ub.price-doc-forming.pdf-db
                                  , ub.price-doc-forming.pdf-id
                                  , stat-line(rs-status)
                                  )
              v-item     = '':U
              v-tbl-name = 'price-doc-forming':U
              v-bh       = buffer ub.price-doc-forming:handle
              v-tot-lns = tot-lns + num-rec
              .
            end.
          end.
          v-no-hist = (if num-rec = 1 then 0 else num-rec).
          run create-gds-list-flt-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                              , input-output v-temp-seq
                                              , input v-line
                                              , input '':U
                                              , input dsp-rs
                                              , input v-tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input v-item
                                              , input v-tbl-name
                                              , input v-bh
                                              ).
          if num-rec = 0 or v-recs = 1 then v-seq  = v-temp-seq.
        end.
      end.
      when "abcxyz"
      or
      when "abc-analysis"
      or
      when "xyz-analysis"
      then do:
        run analysis in this-procedure (input rs-list-method) no-error.
        if error-status:error then do:
          run Ui-on in this-procedure.
          return no-apply.
        end.
      end.
      when "collection" then do:
        run collection in this-procedure (input rs-list-method) no-error.
        if error-status:error then do:
          run Ui-on.
          return error.
        end.
      end.
        when "tsd" then
            do:
                define buffer buf_Code for ub.Code .
                glog = yes.
                message "Загрузить список товаров с ТСД?"
                    skip stat-line(rs-status)
                    view-as alert-box question buttons OK-Cancel update glog.
                if not glog then
                do:
                    run UI-on in this-procedure.
                    return error.
                end.
                ref-list = "" .
                grp-list = "".
                ref-list = "".
                num-rec = 0 .
                for each buf_Code no-lock where buf_Code.parent = "TiketPrint" and
                    buf_code.status_ = 0:
                    find first ub.goods no-lock where ub.goods.gds-code = integer(buf_code.code) no-error .
                    if available (ub.goods) then
                    do:
                        num-rec = num-rec + 1 .
                        if v-recs = 1 then
                        do:
                            assign
                                v-temp-seq = v-seq
                                v-line     = 0
                                dsp-rs     = substitute("Товар :&1 &2", ub.goods.gds-name, stat-line(rs-status))
                                v-item     = '':U
                                v-tbl-name = 'goods':U
                                v-bh       = buffer goods:handle
                                v-tot-lns  = tot-lns
                                .
                        end.
                        else
                        do:
                            if num-rec = 0 then
                            do:
                                assign
                                    v-temp-seq = v-seq
                                    v-line     = 0
                                    dsp-rs     = substitute("Товары : &1", stat-line(rs-status))
                                    v-item     = '':U
                                    v-tbl-name = '':U
                                    v-bh       = ?
                                    v-tot-lns  = tot-lns
                                    .
                            end.
                            else
                            do:
                                assign
                                    v-temp-seq = v-seq - 1
                                    v-line     = num-rec
                                    dsp-rs     = substitute("код &1 &2 &3&4 &5", goods.gds-code, goods.artic, goods.prod-type, goods.prod-code, goods.gds-name)
                                    v-item     = '':U
                                    v-tbl-name = 'goods':U
                                    v-bh       = buffer ub.goods:handle
                                    v-tot-lns  = tot-lns + num-rec
                                    .
                            end.
                        end.
                        v-no-hist = (if num-rec = 1 then 0 else num-rec).
                        run create-gds-list-flt-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                            , input-output v-temp-seq
                            , input v-line
                            , input '':U
                            , input dsp-rs
                            , input v-tot-lns
                            , input rs-list-method
                            , input rs-status
                            , input v-item
                            , input v-tbl-name
                            , input v-bh
                            ).
                        if num-rec = 0 or v-recs = 1 then v-seq  = v-temp-seq.
                    end.
                end.
            end.
      when "ass-matr" then do:
        glog = yes.
        message
        "Товары из выбранной ассортиментной матрицы."
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run UI-on in this-procedure.
          return error.
        end.
        ref-list = '' .
        run ref/assmatr.w (input parparentproc
                    ,input "b-sel":U
                    ,input p-curr-obj-type
                    ,input p-curr-obj-code
                    ,input ""
                    ,input 0
                    ,input-output ref-list).
        if ref-list = "" then do:
          run UI-on in this-procedure.
          return error.
        end.
        if num-entries(ref-list) = 1 then do:
          find ub.assortment-matrix where recid (ub.assortment-matrix) = integer(entry(1, ref-list)) no-lock.
          run create-gds-list-flt-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                              , input-output v-seq
                                              , input 0
                                              , input '':U
                                              , input  substitute("Ассортиментная матрица : &1 &2"
                                                                  ,ub.assortment-matrix.asmt-name
                                                                  , stat-line(rs-status)
                                                                  )
                                              , input tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input '':U
                                              , input 'assortment-matrix':U
                                              , input buffer ub.assortment-matrix:handle
                                              ).
        end.
      end.
      when "izt" then do:
        glog = yes.
        message
        "Товары по выбранным ИЖТ."
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run UI-on in this-procedure.
          return error.
        end.
        v-sel-obj-type =  p-curr-obj-type .
        v-sel-obj-code =  p-curr-obj-code .
define variable vss-include-info59 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
        run gbl/d-list.w (
            INPUT "b-sel,b-mark":U,
            INPUT "ИЖТ",
            INPUT 'Новинка,Основная группа,Нештатный,На вывод из ассортимента,Пусто':U,
            INPUT 'Новинка,Основная группа,Нештатный,На вывод из ассортимента,Пусто':U ,
            INPUT  ","          ,
            INPUT  ""           ,
            OUTPUT list-abcxyz  ).
        if list-abcxyz = "" then do:
          run UI-on in this-procedure.
          return error.
        end.
        assign
        dsp-rs = substitute ("Индикаторы жизнедеятельности товара : &1 &2&3 &4&5"
                           , list-abcxyz
                           , v-sel-obj-type
                           , v-sel-obj-code
                           , chr(10)
                           , stat-line(rs-status))
        v-item = list-abcxyz + chr(3) + v-sel-obj-type + chr(3) + string(v-sel-obj-code) + chr(3)
        .
        run create-gds-list-flt-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
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
      end.
      when "ass-min" then do:
        glog = yes.
        message
        "Товары из ассортиментного минимума по объекту."
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run UI-on in this-procedure.
          return error.
        end.
        v-sel-obj-type =  p-curr-obj-type .
        v-sel-obj-code =  p-curr-obj-code .
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
          if not v-user-select then do:
            return error.
          end.
        assign
        dsp-rs = substitute("Ассортиментный минимум на объекте : &1&2 &4"
                           ,v-sel-obj-type
                           ,v-sel-obj-code
                           ,stat-line(rs-status))
        v-item = v-sel-obj-type + chr(3) + string(v-sel-obj-code) + chr(3)
        .
        run create-gds-list-flt-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
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
      end.
      when "client" then do:
        glog = yes.
        message "Все товары из всех документов (накладных) по контрагенту" skip
                "(по всем объектам за все время работы программы)."
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run UI-on in this-procedure.
          return error.
        end.
        run ref/cli-all.w ( parparentproc
                        , "b-sel"
                        , ?
                        , ?
                        , ?
                        , ?
                        , ?
                        , ?
                        , output ref-list) .
        if ref-list = "" then do:
          v-ref-rec = ?.
          run UI-on in this-procedure.
          return error.
        end.
        v-ref-rec = integer (ref-list).
        find clients where recid (clients) = v-ref-rec no-lock.
        run create-gds-list-flt-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                            , input-output v-seq
                                            , input 0
                                            , input '':U
                                            , input substitute("Контрагент : &1 &2", clients.obj-name, stat-line(rs-status))
                                            , input tot-lns
                                            , input rs-list-method
                                            , input rs-status
                                            , input '':U
                                            , input 'clients':U
                                            , input buffer clients:handle
                                            ).
      end.
      when "consignee" then do:
        glog = yes.
        message "Товары, которых данный контрагент получил больше, чем вернул" skip
                "(по всем объектам за все время работы программы)."
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run UI-on in this-procedure.
          return error.
        end.
        run ref/cli-all.w ( parparentproc
                        , "b-sel"
                        , ?
                        , ?
                        , ?
                        , ?
                        , ?
                        , ?
                        , output ref-list) .
        if ref-list = "" then do:
          v-ref-rec = ?.
          run UI-on in this-procedure.
          return error.
        end.
        v-ref-rec = integer (ref-list).
        find clients where recid (clients) = v-ref-rec no-lock.
        run create-gds-list-flt-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                            , input-output v-seq
                                            , input 0
                                            , input '':U
                                            , input substitute("Консигнант : &1 &2", clients.obj-name, stat-line(rs-status))
                                            , input tot-lns
                                            , input rs-list-method
                                            , input rs-status
                                            , input '':U
                                            , input 'clients':U
                                            , input buffer clients:handle
                                            ).
      end.
      when "object"
      or
      when "available"
      or
      when "neg-rest"
      or
      when "neg-part"
      or
      when "neg-part-free"
      or
      when "neg-prt"
      or
      when "nul-rest"
      or
      when "with-price"
      or
      when "ov-req"
      or
      when "inv-req"
      or
      when "input"
      or
      when "etalon"
      then do:
        run object-options in this-procedure (input rs-list-method).
      end.
      when "fbr-gds-obj" or when "fbr-gds-obj-val" then do:
        run trig-fbr in this-procedure (input rs-list-method) no-error.
        if error-status:error then do:
          run Ui-on in this-procedure.
          return no-apply.
        end.
      end.
      when "dis-gds-rule" or when "dis-gds-rule-num" then do:
        run trig-dis-gds-rule in this-procedure no-error.
        if error-status:error then do:
          run Ui-on in this-procedure.
          return no-apply.
        end.
      end.
      when "gds-obj-attr" or when "gds-obj-attr-val" then do:
        run trig-attr in this-procedure ( input "gds-obj-attr", input 'scales-code,fbr-cost-rubl,gds-margins,free-price,sum-grp,increase-pc,round-method,petrol-purse,min-zapas,need-auth,proprietor,no-income-goods,taracode,calories-o,protein-o,fat-o,carbohydrate-o,doc-tickets,normal-wastage-o,dop-alt-name-o,dt-seasons,change-dt-seasons,mark-collect-type':u) no-error.
        if error-status:error then do:
          run Ui-on in this-procedure.
          return no-apply.
        end.
      end.
      when "gds-host-attr" or when "gds-host-attr-val" then do:
        run trig-attr in this-procedure ( input "gds-host-attr", input 'no-envd,':u ) no-error.
        if error-status:error then do:
          run Ui-on in this-procedure.
          return no-apply.
        end.
      end.
      when "goods-attr" or when "goods-attr-val" then do:
        run trig-attr in this-procedure ( input "goods-attr" , input 'alcohol-prod,egais-name,is-gas,ptrl-without-rvs,office-type,mark-type,emrc-type,IS18Plus,loyalty-gift,item-matter-mark,type-method-calc,group-np,fuel-type,is-loyalty-payment,ban-bonus,null-price,fasovka,time-coock,mark,sum-grp-gl,min-zapas,mercur_FGIS,perishable,production-only,15x80,8x50,6x50,calories,protein,fat,carbohydrate,calc-cal-rec,cash-parts,ptrl-as-good,dflt-insalepr,gds-ptrl-densities,gds-CommodityCode,gds-code-AIS,length-of,width-of,height-of,qnty-in-box,weight-box,qnty-on-pallet,weight-of-pallet,image-list,MercUnits,weighed-gds':U) no-error.
        if error-status:error then do:
          run Ui-on.
          return no-apply.
        end.
      end.
      when "tax-rate-value":U
      or
      when "tax-rate-value-obj":U
      then do:
        run trig-tax-rate-value(input rs-list-method, output v-date) no-error.
        if error-status:error then do:
          run Ui-on in this-procedure.
          return no-apply.
        end.
      end.
      when "scales-gds" or when "scales-gds-num" then do:
        run proc-scales-gds(rs-list-method) no-error.
        if error-status:error then do:
          run Ui-on in this-procedure.
          return no-apply.
        end.
      end.
      when "parts-last-date" then do:
        run proc-parts-last-date(rs-list-method) no-error.
        if error-status:error then do:
          run Ui-on in this-procedure.
          return no-apply.
        end.
      end.
      when "parts-last-date" then do:
        run proc-parts-fib(rs-list-method) no-error.
        if error-status:error then do:
          run Ui-on in this-procedure.
          return no-apply.
        end.
      end.
      when "cashparts" then do:
        glog = yes.
        message
        "Товары с продажей по партиям."
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run UI-on in this-procedure.
          return error.
        end.
        v-sel-obj-type =  p-curr-obj-type .
        v-sel-obj-code =  p-curr-obj-code .
define variable vss-include-info61 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
        assign
        dsp-rs = substitute("Товары с продажей по партиям на объекте : &1&2 &4"
                           ,v-sel-obj-type
                           ,v-sel-obj-code
                           ,stat-line(rs-status))
        v-item = v-sel-obj-type + chr(3) + string(v-sel-obj-code)
        .
        run create-gds-list-flt-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
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
      end.
      when "is-ptrl"
      or when "gds-office"
      then do:
        run proc-simple(rs-list-method) no-error.
        if error-status:error then do:
          run Ui-on in this-procedure.
          return no-apply.
        end.
      end.
      when "doc-list" then do:
        glog = yes.
        message "Все товары по документам из ранее сохраненного в файле списка документов"
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run UI-on in this-procedure.
          return error.
        end.
        system-dialog get-file f-doc-name
          filters "Списки документов *.trn" "*.trn"
          title "Выберите файл списка"
          INITIAL-DIR "."
          return-to-start-dir
          must-exist
          update glog
          default-extension "trn".
        if not glog then do:
          run UI-on in this-procedure.
          return error.
        end.
        run create-gds-list-flt-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                            , input-output v-seq
                                            , input 0
                                            , input '':U
                                            , input substitute("Файл списка документов: &1 &2", f-doc-name, stat-line(rs-status))
                                            , input tot-lns
                                            , input rs-list-method
                                            , input rs-status
                                            , input f-doc-name
                                            , input '':U
                                            , input ?
                                            ).
      end.
      when "prod-list"
      or
      when "supp-list"
      or
      when "cli-list" then do:
        glog = yes.
        if rs-list-method = "prod-list" then do:
          assign
          v-message = substitute("Все товары производителей из ранее сохраненного в файле списка клиентов&1&2"
                                  , chr(10)
                                  , stat-line(rs-status))
          dsp-rs = substitute("Файл списка производителей: &1", f-cli-name, stat-line(rs-status))
          .
        end.
        if rs-list-method = "supp-list" then do:
          assign
          v-message = substitute("Все товары поставщиков из ранее сохраненного в файле списка клиентов&1&2"
                                  , chr(10)
                                  , stat-line(rs-status))
          dsp-rs = substitute("Файл списка поставщиков: &1 &2", f-cli-name, stat-line(rs-status))
          .
        end.
        if rs-list-method = "cli-list" then do:
          assign
          v-message = substitute("Все товары из всех документов (накладных) по контрагентам&1" +
                                "из ранее сохраненного в файле списка клиентов&1"  +
                                "(по всем объектам за все время работы программы&1&1"
                                  , chr(10)
                                  , stat-line(rs-status))
          dsp-rs = substitute("Файл списка контрагентов: &1 &2", f-cli-name, stat-line(rs-status))
          .
        end.
        message
        v-message
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run UI-on in this-procedure.
          return error.
        end.
        system-dialog get-file f-cli-name
          filters "Списки клиентов *.cli" "*.cli"
          title "Выберите файл списка"
          INITIAL-DIR "."
          return-to-start-dir
          must-exist
          update glog
          default-extension "cli".
        if not glog then do:
          run UI-on in this-procedure.
          return error.
        end.
        run create-gds-list-flt-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                            , input-output v-seq
                                            , input 0
                                            , input '':U
                                            , input dsp-rs
                                            , input tot-lns
                                            , input rs-list-method
                                            , input rs-status
                                            , input f-cli-name
                                            , input '':U
                                            , input ?
                                            ).
      end.
      when "deleted" then do:
        if RS-status = 'текущие':U then do:
          message
          "Переключатель <СТАТУС> стоит в положениии <Текущие>" skip
          "Вы не cможете выбрать ни одного товара"
          view-as alert-box error .
          run UI-on in this-procedure.
          return error.
        end.
        glog = yes.
        message "Все неактивные товары."
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run UI-on in this-procedure.
          return error.
        end.
        run create-gds-list-flt-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                            , input-output v-seq
                                            , input 0
                                            , input '':U
                                            , input substitute("ВСЕ неактивные товары &1", stat-line(rs-status))
                                            , input tot-lns
                                            , input rs-list-method
                                            , input rs-status
                                            , input 'deleted':U
                                            , input '':U
                                            , input ?
                                            ).
      end.
      when "file" then do:
        glog = yes.
        message "Все товары из ранее сохраненного в файле списка"
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run UI-on in this-procedure.
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
          run UI-on in this-procedure.
          return error.
        end.
        run create-gds-list-flt-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                            , input-output v-seq
                                            , input 0
                                            , input '':U
                                            , input substitute("Файл списка : &1 &2", f-name, stat-line(rs-status))
                                            , input tot-lns
                                            , input rs-list-method
                                            , input rs-status
                                            , input f-name
                                            , input '':U
                                            , input ?
                                            ).
      end.
      when "clob-data" then do:
        glog = yes.
        message "Все товары из ранее сохраненного в БД списка"
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run UI-on in this-procedure.
          return error.
        end.
        run ref/clobbnds.w ( input parparentproc
                            ,input this-procedure:handle
                            ,input 'b-sel'
                            ,input "uniq-key-rec"
                            ,input ""
                            ,input 'list':U
                            ,input 'gds-list'
                            ,input -1
                            ,input-output v-rid-list) no-error.
        if v-rid-list = '' then do:
          run UI-on in this-procedure.
          return error.
        end.
        find first buf_clob-bind no-lock where
                  recid(buf_clob-bind) = integer(v-rid-list) .
        run gen-key-rec in this-procedure ( input 'clob-bind':U
                                           ,input (buffer buf_clob-bind:handle)
                                           ,output v-uniq-key-rec).
        run create-gds-list-flt-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                            , input-output v-seq
                                            , input 0
                                            , input '':U
                                            , input substitute("Хранимый Файл списка : &1 &2", buf_clob-bind.field-name, stat-line(rs-status))
                                            , input tot-lns
                                            , input rs-list-method
                                            , input rs-status
                                            , input v-uniq-key-rec
                                            , input '':U
                                            , input ?
                                            ).
      end.
      when "scaner" then do:
        glog = yes.
        message "Все товары из файла, полученного с мобильного сканера."
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run UI-on in this-procedure.
          return error.
        end.
        system-dialog get-file f-name
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
          run UI-on in this-procedure.
          return error.
        end.
        run create-gds-list-flt-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                            , input-output v-seq
                                            , input 0
                                            , input '':U
                                            , input substitute("Файл сканера : &1 &2", f-name, stat-line(rs-status))
                                            , input tot-lns
                                            , input rs-list-method
                                            , input rs-status
                                            , input f-name
                                            , input '':U
                                            , input ?
                                            ).
      end.
      when "filter" then do:
        glog = yes.
        message "Все товары, выбранные в соответствии с заданным фильтром (без учета сортировки)."
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run UI-on in this-procedure.
          return error.
        end.
        assign
        tbl = 'goods,clients'
        join-tbl = ','
        fld = ""
        lab = ""
        spr = ""
        dim = '0'
        c-point = "gds-list" + chr(4) + "Список товаров" + chr(4) + "no"
        .
        define variable v-flt-rec as recid no-undo .
        define variable v-filter-name as character no-undo .
        define variable where-phrase as character no-undo .
        define variable sort-phrase as character no-undo .
        define variable where-phrase-rus as character no-undo .
        define variable sort-phrase-rus as character no-undo .
        run fltfield-add in this-procedure('artic', '', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('gds-name', '', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('engl-name', 'Название по-английски', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('chk-name', 'Название на чеке', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('prod-type*prod-code', 'Производитель', 'cli',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('unit-base', '', 'unit',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('unit-cli', '', 'unit',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('grp-name', '', 'gdsgrp',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('prt-root', 'Шкала', 'prt',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('increase-pc', '', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('calc-method', 'Метод наценки', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('qnty-cart', '', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('okdp', '', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('destin', '', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('sert', '', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('struct', '', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('sort', '', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('deadline', '', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('negative-rest', '', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('cost-calc', '', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('gds-type', 'Услуга-товар', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('tnved', 'Код ТНВЭД', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('nationality', '', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('unit-cst', 'Таможенная единица', 'unit',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('alpha1', 'Код страны изготовления', 'country',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('normal-wastage', 'Норма естест.убыли', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('normal-waste', 'Норма отходов', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('min-rate', 'Min кол-во в штуке', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('max-rate', 'Max кол-во в штуке', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('ms-base', 'Объем штуки', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('ms-cart', 'Объем упаковки', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('wt-base', 'Все штуки', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('wt-cart', 'Веc упаковки', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('cond-keep-code', 'Условия хранения', 'cond-keep',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        assign
        fld = fld
        lab = lab
        dim = dim + chr(44)
        .
        run fltfield-add in this-procedure('obj-name', 'Название производителя', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('grp-name', 'Группа производителей', '',
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
          run create-gds-list-flt-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
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
      when "move-date" then do:
       define variable v-date-chr       as character           no-undo .
       define variable v-date       as date           no-undo .
        run gbl/d-prompt.w (
          'title=':u + "Введите дату начала периода движения товара" + '\':u
        + 'text1=':u + "Дата" + '\':u
        + 'format=' + "99/99/9999" + '\':u
        + 'type=' + 'T':U + '\':u
        + 'fillin_row=2\':u
        + 'fillin_col=4\':u
        + 'fillin_width=20\':u
        + 'fillin_height=1\':u
        + 'max-chars=70\':u
        + 'readonly=no' + '\':u
        , input-output v-date-chr
        ).
        if return-value = 'false':u then return error.
        assign
        v-date = date( integer(substr(v-date-chr, 4, 2))
                      ,integer(substr(v-date-chr, 1, 2))
                      ,integer(substr(v-date-chr, 7, 4))
                     )
        no-error .
        if error-status:error then return error.
        run create-gds-list-flt-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                            , input-output v-seq
                                            , input 0
                                            , input '':U
                                            , input substitute("Дата начала периода: &1", v-date)
                                            , input tot-lns
                                            , input rs-list-method
                                            , input rs-status
                                            , input v-date
                                            , input '':U
                                            , input ?
                                            ).
      end.
    end.
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
          run UI-on in this-procedure.
          return error.
        end.
      END CASE.
      if error-status:error then do:
        run UI-on in this-procedure.
        return error return-value .
      end.
    end.
    assign
    rs-list-method = temp-list.fvalue
    .
    find last buf_gds-list-flt-hist no-lock where
              buf_gds-list-flt-hist.id = (v-seq - 1)
        and  buf_gds-list-flt-hist.line = 0 no-error .
    DISPLAY
    (if available buf_gds-list-flt-hist
    then buf_gds-list-flt-hist.des
    else '') @ dsp-rs
    with frame Dialog-Frame.
    if tot-lns = 0
    and not p-keep-query
    then do:
      run proc-b-add in this-procedure(no, ?, rs-list-method, rs-status)  .
    end.
  end.
end.
end procedure.
PROCEDURE trig-attr :
define input parameter p-attr-table as character no-undo .
define input parameter p-list       as character no-undo .
DEFINE VARIABLE ii as integer no-undo .
DEFINE VARIABLE vattr-codes          as character           no-undo.
DEFINE VARIABLE vattr-labels         as character           no-undo.
DEFINE VARIABLE vtooltip             as character           no-undo.
DEFINE VARIABLE vlabel               as character           no-undo .
DEFINE VARIABLE vtype                as character           no-undo .
DEFINE VARIABLE vformat              as character           no-undo .
DEFINE VARIABLE vuser-can-edit       as logical             no-undo .
DEFINE VARIABLE voutput-display      as logical             no-undo .
DEFINE VARIABLE vother               as character           no-undo .
DEFINE VARIABLE v-ref-list           as character           no-undo .
DEFINE VARIABLE jj                   as integer             no-undo .
DEFINE VARIABLE v-spr                as character           no-undo .
DEFINE VARIABLE v-spr-param          as character           no-undo .
DEFINE VARIABLE v-setted             as logical             no-undo .
define variable v-init               as character           no-undo .
define variable v-item               as character           no-undo .
define variable glog as logical no-undo .
define variable v-list               as character           no-undo .
assign
v-attr-code = ""
vattr-codes = ""
vattr-labels = ""
vvalue = ""
.
DO ii = 1 to num-entries ( p-list):
    CASE p-attr-table:
      when "gds-obj-attr" then do:
        run gdsoattr-name  in this-procedure (
                                              input entry(ii, p-list)
                                              ,output vtype
                                              ,output vformat
                                              ,output vlabel
                                              ,output vuser-can-edit
                                              ,output voutput-display
                                              ,output vother) no-error.
      end.
      when "gds-host-attr" then do:
        v-list = 'no-envd,':u.
        run gdshattr-name in this-procedure (
                                              input entry(ii, p-list)
                                            ,output vtype
                                            ,output vformat
                                            ,output vlabel
                                            ,output vuser-can-edit
                                            ,output voutput-display
                                            ,output vother) no-error.
      end.
      WHEN "goods-attr" then do:
        run gds-attr-name in this-procedure (
                                              input entry(ii, p-list)
                                              ,output vtype
                                              ,output vformat
                                              ,output vlabel
                                              ,output vuser-can-edit
                                              ,output voutput-display
                                              ,output vother) no-error.
      end.
    END CASE.
    if NOT error-status:error anD VOUTPUT-DISPLAY = yes then do:
        assign
        vattr-codes = vattr-codes + chr(4) + entry(ii, p-list)
        vattr-labels = vattr-labels + chr(4) + vlabel
        .
    end.
end.
run gbl/d-list.w ( input "b-sel":U
                  ,input "Выберите атрибут"
                  ,input vattr-codes
                  ,input vattr-labels
                  ,input chr(4)
                  ,input "":U
                  ,output v-attr-code).
if v-attr-code = "" then do:
  return error.
end.
glog = yes.
CASE rs-list-method:
  when "gds-obj-attr":U then do:
    run gdsoattr-tooltip  in this-procedure( input v-attr-code,
                         output vtooltip,
                         output vlabel).
    message
    "Все товары с установленным атрибутом на объекте" vlabel skip
    stat-line(rs-status)
    view-as alert-box question buttons OK-Cancel update glog.
    if not glog then do:
      return error.
    end.
define variable vss-include-info62 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    assign
    dsp-rs = substitute("ВСЕ товары с установленным атрибутом на объекте &1 &2", vlabel, stat-line(rs-status))
    v-item = v-sel-obj-type + chr(3) + string(v-sel-obj-code) + chr(3) + v-attr-code
    .
  end.
  when "gds-obj-attr-val":U then do:
    run gdsoattr-name  in this-procedure (
                         input v-attr-code,
                         output vtype,
                         output vformat,
                         output vlabel,
                         output vuser-can-edit,
                         output voutput-display,
                         output vother).
    do jj = 1 to num-entries(vother, chr(47)):
      if entry(1, entry(jj, vother, chr(47)), "=":U) = "init":U then do:
        assign
        v-init = string(entry(2, entry(jj, vother, chr(47)), "=":U))
        .
      end.
    end.
    do jj = 1 to num-entries(vother, chr(47)):
      if entry(1, entry(jj, vother, chr(47)), "=":U) = "spr":U then do:
        assign
        v-spr = entry(2, entry(jj, vother, chr(47)), "=":U)
        .
      end.
      if entry(1, entry(jj, vother, chr(47)), "=":U) = "spr-param":U then do:
        assign
        v-spr-param = entry(2, entry(jj, vother, chr(47)), "=":U)
        .
      end.
    end.
define variable vss-include-info63 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    if  v-init <> "":U then do:
        run  value(v-init)
                    in this-procedure (
                                         input 0
                                       , input v-sel-obj-type
                                       , input v-sel-obj-code
                                       , output vvalue) no-error .
          if error-status:error then do:
              assign
              vvalue = "":U
              .
          end.
    end.
    CASE vtype:
      when 'L':U then do:
        assign
        vvalue = "yes":U
        .
      end.
      when 'I':U or when 'D':U then do:
        assign
        vvalue = if v-init <> "":U
                      then vvalue
                      else string(0)
        .
      end.
      when 'T':U then do:
        assign
        vvalue = ?
        .
      end.
      when 'C':U then do:
        assign
        vvalue = if v-init <> "":U
                      then vvalue
                      else "":U
        .
      end.
    END CASE.
    if v-spr = "":U then do:
      run gbl/d-prompt.w (
        'title=':u + "Значение атрибута товара на объекте" + '\':u
      + 'text1=':u + vlabel + '\':u
      + 'format=' + (if vtype = 'L':U then "yes/no" else vformat) + '\':u
      + 'type=' + vtype + '\':u
      + 'fillin_row=2\':u
      + 'fillin_col=4\':u
      + 'fillin_width=20\':u
      + 'fillin_height=1\':u
      + 'max-chars=70\':u
      + 'readonly=no\':u
      , input-output vvalue
      ).
      if return-value = 'false':U then do:
        return error.
      end.
    end.
    else do:
      if v-spr-param = "":U then do:
        run  value(v-spr)
                      in this-procedure (
                                        input 0
                                        ,input v-sel-obj-type
                                        ,input v-sel-obj-code
                                        ,input-output vvalue
                                        ,output v-setted) no-error .
      end.
      else do:
        run  value(v-spr)
                      in this-procedure (
                                        input 0
                                        ,input v-sel-obj-type
                                        ,input v-sel-obj-code
                                        ,input v-spr-param
                                        ,input-output vvalue
                                        ,output v-setted) no-error .
      end.
      if not v-setted then do:
        return error.
      end.
    end.
    message
    ("Все товары с атрибутом товара на объекте" + chr(32) + vlabel + " = ":U + vvalue) skip
    stat-line(rs-status)
    view-as alert-box question buttons OK-Cancel update glog.
    if not glog then do:
      return error.
    end.
    assign
    dsp-rs = substitute("ВСЕ товары с атрибутом товара на объекте &1 =&2 &3", vlabel, vvalue, stat-line(rs-status))
    v-item = v-sel-obj-type + chr(3) + string(v-sel-obj-code) + chr(3) + v-attr-code + chr(3) + vvalue
    .
  end.
  when "gds-host-attr":U then do:
    run gdshattr-tooltip  in this-procedure
                         (input v-attr-code,
                         output vtooltip,
                         output vlabel).
    message "Все товары с установленным атрибутом на фирме" vlabel skip
    stat-line(rs-status)
    view-as alert-box question buttons OK-Cancel update glog.
    if not glog then do:
      return error.
    end.
define variable vss-include-info64 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                          if not v-user-select then do:     run UI-on in this-procedure .     return error.    end.
define variable vss-include-info65 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-sel-obj-type
  ,input  v-sel-obj-code
  ,output v-host-code
  ) no-error .
     if error-status:error then do:  run UI-on in this-procedure.   return error.  end.
    assign
    dsp-rs  = substitute("ВСЕ товары с установленным атрибутом на фирме &1 &2", vlabel, stat-line(rs-status))
    v-item = string(v-host-code) + chr(3) + v-attr-code
    .
  end.
  when "gds-host-attr-val" then do:
    run gdshattr-name   in this-procedure
                       ( input v-attr-code,
                         output vtype,
                         output vformat,
                         output vlabel,
                         output vuser-can-edit,
                         output voutput-display,
                         output vother).
    run gbl/d-prompt.w (
      'title=':u + "Значение атрибута товара на фирме" + '\':u
    + 'text1=':u + vlabel + '\':u
    + 'format=' + (if vtype = 'L':U then "yes/no" else vformat) + '\':u
    + 'type=' + vtype + '\':u
    + 'fillin_row=2\':u
    + 'fillin_col=4\':u
    + 'fillin_width=20\':u
    + 'fillin_height=1\':u
    + 'max-chars=70\':u
    + 'readonly=no\':u
    , input-output vvalue
    ).
    if return-value = 'false':U then do:
      return error.
    end.
    message ("Все товары с атрибутом товара на фирме" + chr(32) + vlabel + " = ":U + vvalue) skip
    stat-line(rs-status)
    view-as alert-box question buttons OK-Cancel update glog.
    if not glog then do:
      return error.
    end.
define variable vss-include-info66 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                          if not v-user-select then do:     run UI-on in this-procedure .     return error.    end.
define variable vss-include-info67 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-sel-obj-type
  ,input  v-sel-obj-code
  ,output v-host-code
  ) no-error .
     if error-status:error then do:  run UI-on in this-procedure.   return error.  end.
    assign
    dsp-rs = substitute("ВСЕ товары с атрибутом товара на фирме &1 = &2 &3", vlabel, vvalue, stat-line(rs-status))
    v-item  = string(v-host-code) + chr(3) + v-attr-code + chr(3) + vvalue
    .
  end.
  when "goods-attr":U then do:
    run gds-attr-tooltip in this-procedure (
                                              input v-attr-code,
                                              output vtooltip,
                                              output vlabel).
    message "Все товары с установленным глобальным атрибутом" vlabel skip
    stat-line(rs-status)
    view-as alert-box question buttons OK-Cancel update glog.
    if not glog then do:
      return error.
    end.
    assign
    dsp-rs  = substitute("ВСЕ товары с установленным глобальным атрибутом &1 &2", vlabel, stat-line(rs-status))
    v-item = v-attr-code
    .
  end.
  when "goods-attr-val" then do:
    run gds-attr-name(   input v-attr-code,
                         output vtype,
                         output vformat,
                         output vlabel,
                         output vuser-can-edit,
                         output voutput-display,
                         output vother).
    run gbl/d-prompt.w (
      'title=':u + "Значение глобального атрибута товара " + '\':u
    + 'text1=':u + vlabel + '\':u
    + 'format=' + (if vtype = 'L':U then "yes/no" else vformat) + '\':u
    + 'type=' + vtype + '\':u
    + 'fillin_row=2\':u
    + 'fillin_col=4\':u
    + 'fillin_width=20\':u
    + 'fillin_height=1\':u
    + 'max-chars=70\':u
    + 'readonly=no\':u
    , input-output vvalue
    ).
    if return-value = 'false':U then do:
      return error.
    end.
    message substitute("Все товары с глобальным атрибутом товара &1 = &2&3&4"
                        ,vlabel
                        ,vvalue
                        ,chr(10)
                        ,stat-line(rs-status))
    view-as alert-box question buttons OK-Cancel update glog.
    if not glog then do:
      return error.
    end.
    assign
    dsp-rs = substitute("ВСЕ товары с глобальным атрибутом товара &1 = &2 &3", vlabel, vvalue, stat-line(rs-status))
    v-item  = v-attr-code + chr(3) + vvalue
    .
  end.
END CASE.
v-no-hist = 0.
run create-gds-list-flt-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
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
PROCEDURE trig-fbr :
define input parameter p-method as character no-undo .
DEFINE VARIABLE vattr-codes          as character           no-undo.
DEFINE VARIABLE vattr-labels         as character           no-undo.
DEFINE VARIABLE vlabel               as character           no-undo .
DEFINE VARIABLE v-ref-list           as character           no-undo .
DEFINE VARIABLE v-fbr-list           as character           no-undo .
define variable v-grp-recid          as recid               no-undo .
define variable v-grp-code like ub.fbr-gds-obj.fbr-grp-code no-undo.
define variable glog as logical no-undo .
define variable v-item               as character           no-undo .
define variable v-fbr-obj-type       like ub.fbr-gds-obj.obj-type no-undo .
define variable v-fbr-obj-code       like ub.fbr-gds-obj.obj-code no-undo .
define buffer buf_fbr-gds-grp for ub.fbr-gds-grp.
if p-method = "fbr-gds-obj-val" then do:
  assign
  v-attr-code = ""
  vattr-codes = "is-cd,is-menu,is-null-price,is-modificator,is-season,is-semi-finished,fbr-grp-code,fbr-obj-code"
  vattr-labels = "Отправлять на кассу РЕСТОРАНА,Является блюдом меню,Без цены,Модификатор блюда,Применять сезонный коэффициент," +
                "Является полуфабрикатом,Группа меню,Кухня"
  vvalue = ""
  .
  run gbl/d-list.w ( input "b-sel":U
                    ,input "Выберите атрибут"
                    ,input vattr-codes
                    ,input vattr-labels
                    ,input chr(44)
                    ,input "":U
                    ,output v-attr-code).
  if v-attr-code = "" then do:
    return error.
  end.
  assign
  vlabel =  entry(lookup(v-attr-code, vattr-codes) ,vattr-labels)
  glog = yes.
end.
define variable vss-include-info68 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
if p-method = "fbr-gds-obj-val" then do:
  CASE v-attr-code:
    when "fbr-grp-code" then do:
        run ref/fbrggrp.w (
                input ?
              ,input v-sel-obj-type
              ,input v-sel-obj-code
              ,input "b-sel"
              ,input-output v-grp-recid
          ).
      if v-grp-recid = ? then return error.
      FIND FIRST buf_fbr-gds-grp no-lock where
              recid(buf_fbr-gds-grp) = v-grp-recid No-ERROR.
      if not avail buf_fbr-gds-grp then return error.
      assign
      vvalue = string(buf_fbr-gds-grp.node-code)
      vlabel = vlabel + " = ":U + buf_fbr-gds-grp.node-name
      .
    end.
    when "fbr-obj-code" then do:
      message
      "Выберите объект-КУХНЮ для товара объекта" v-sel-obj-type v-sel-obj-code
      view-as alert-box.
define variable vss-include-info69 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-one in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-user-select
  ,output v-fbr-obj-type
  ,output v-fbr-obj-code
  )  .
      assign
      vvalue = string(v-fbr-obj-code)
      .
    end.
    otherwise do:
      assign
      vvalue = "yes":U
      .
      run gbl/d-prompt.w (
        'title=':u + "Значение атрибута товара на объекте" + '\':u
      + 'text1=':u + vlabel + '\':u
      + 'format=yes/no' + '\':u
      + 'type=logical' + '\':u
      + 'fillin_row=2\':u
      + 'fillin_col=4\':u
      + 'fillin_width=20\':u
      + 'fillin_height=1\':u
      + 'max-chars=70\':u
      + 'readonly=no\':u
      , input-output vvalue
      ).
      if return-value = 'false':U then do:
        return error.
      end.
    end.
  END CASE.
  assign
  dsp-rs = substitute("Товары объекта &1&2 с атрибутом РЕСТОРАН &3 =&4&5&5"
                       ,  v-sel-obj-type, v-sel-obj-code, vlabel, vvalue
                       , chr(10)
                       , stat-line(rs-status)
                       )
  v-item = v-sel-obj-type + chr(3) + string(v-sel-obj-code) + chr(3) + v-attr-code + chr(3) + vvalue
  .
end.
else do:
  assign
  dsp-rs = substitute("Товары объекта &1&2, имеющие атрибут РЕСТОРАН&3&4"
                     ,  v-sel-obj-type
                      , v-sel-obj-code
                       , chr(10)
                       , stat-line(rs-status)
                     )
   v-item = v-sel-obj-type + chr(3) + string(v-sel-obj-code) + chr(3)
   .
end.
  message
  dsp-rs skip
  view-as alert-box question buttons OK-Cancel update glog.
if not glog then do:
  return error.
end.
run create-gds-list-flt-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
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
PROCEDURE proc-scales-gds :
define input parameter rs-list-method as character no-undo .
define variable v-ref-list as character no-undo .
define variable v-rid-list as character no-undo .
define variable glog as logical no-undo .
define variable v-message as character no-undo .
define variable v-item as character no-undo .
define buffer buf_scales for ub.scales.
glog = yes.
CASE rs-list-method:
  when "scales-gds":U then do:
    assign
    v-message = substitute("Все товары на весах на объекте&1&2", chr(10), stat-line(rs-status))
    .
  end.
  when "scales-gds-num":U then do:
    assign
    v-message = substitute("Товары на одних весах на объекте &1&2", chr(10), stat-line(rs-status))
    .
  end.
END CASE.
message
v-message
view-as alert-box question buttons OK-Cancel update glog.
if not glog then do:
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
if not v-user-select then do:
  return error.
end.
if rs-list-method = "scales-gds-num" then do:
  run ref/scales.w ( input parparentproc
                    ,input v-sel-obj-type
                    ,input v-sel-obj-code
                    ,input "b-sel"
                    ,input 'db':U
                    ,output v-rid-list).
  if v-rid-list = '':U then do:
    return error.
  end.
  find first buf_scales no-lock where
            recid(buf_scales) = integer(v-rid-list).
end.
CASE rs-list-method:
  when "scales-gds":U then do:
    assign
    dsp-rs = substitute("ВСЕ товары на весах на объекте &1&2 &3", v-sel-obj-type, v-sel-obj-code, stat-line(rs-status))
    v-item = v-sel-obj-type + chr(3) + string(v-sel-obj-code)
    .
  end.
  when "scales-gds-num":U then do:
    assign
    dsp-rs = substitute("Товары на весах &1 на объекте &2&3 &4", buf_scales.scales-num, v-sel-obj-type, v-sel-obj-code, stat-line(rs-status))
    v-item = v-sel-obj-type + chr(3) + string(v-sel-obj-code)  + chr(3) + string(buf_scales.scales-num)
    .
  end.
END CASE.
v-no-hist = 0.
run create-gds-list-flt-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
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
glog = yes.
CASE rs-list-method:
  when "parts-last-date":U then do:
    assign
    v-message = substitute("Партии свободной зоны на &1&2 с истекающим сроком хранения", chr(10), stat-line(rs-status))
    .
  end.
END CASE.
message
v-message
view-as alert-box question buttons OK-Cancel update glog.
if not glog then do:
  return error.
end.
define variable vss-include-info71 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      'title=':u + substitute("Введите кол-во дней в течение которых истекает срок хранения") + '\':u
    + 'text1=':u + "Кол-во дней" + '\':u
    + 'format=' + ">>9" + '\':u
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
    dsp-rs = substitute("Партии свободной зоны на &1&2 со сроком хранения, истекающим через &3 дн.  и ранее &4", v-sel-obj-type, v-sel-obj-code, v-value-integer, stat-line(rs-status))
    v-item = v-sel-obj-type + chr(3) + string(v-sel-obj-code)  + chr(3) + string(v-value-integer)
    .
  end.
END CASE.
v-no-hist = 0.
run create-gds-list-flt-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
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
glog = yes.
CASE rs-list-method:
  when "parts-last-date":U then do:
    assign
    v-message = substitute("ФиБ партии свободной зоны на &1&2", chr(10), stat-line(rs-status))
    .
  end.
END CASE.
message
v-message
view-as alert-box question buttons OK-Cancel update glog.
if not glog then do:
  return error.
end.
define variable vss-include-info72 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    dsp-rs = substitute("ФиБ партии свободной зоны на &1&2 &4", v-sel-obj-type, v-sel-obj-code, stat-line(rs-status))
    v-item = v-sel-obj-type + chr(3) + string(v-sel-obj-code)
    .
  end.
END CASE.
v-no-hist = 0.
run create-gds-list-flt-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
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
PROCEDURE proc-simple :
define input parameter rs-list-method as character no-undo .
define variable v-ref-list as character no-undo .
define variable v-rid-list as character no-undo .
define variable glog as logical no-undo .
define variable v-message as character no-undo .
define variable v-item as character no-undo .
define buffer buf_scales for ub.scales.
glog = yes.
CASE rs-list-method:
  when "is-ptrl":U then do:
    assign
    v-message = substitute("Все топлива&1&2", chr(10), stat-line(rs-status))
    .
  end.
  when "gds-office":U then do:
    assign
    v-message = substitute("Все услуги&1&2", chr(10), stat-line(rs-status))
    .
  end.
END CASE.
message
v-message
view-as alert-box question buttons OK-Cancel update glog.
if not glog then do:
  return error.
end.
CASE rs-list-method:
  when "is-ptrl":U then do:
    assign
    dsp-rs = substitute("ВСЕ топлива &1", v-sel-obj-type, v-sel-obj-code, stat-line(rs-status))
    v-item = '':U
    .
  end.
  when "gds-office":U then do:
    assign
    dsp-rs = substitute("ВСЕ услуги &1", v-sel-obj-type, v-sel-obj-code, stat-line(rs-status))
    v-item = '':U
    .
  end.
END CASE.
v-no-hist = 0.
run create-gds-list-flt-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
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
PROCEDURE trig-dis-gds-rule :
define variable v-rid-list as character no-undo .
define variable v-pos-type as character no-undo .
define variable v-templ-rl-root as integer no-undo .
define variable v-time-templ-rl-root as integer no-undo .
define variable v-cfg-nonunique as character no-undo .
define variable v-nonunique as character no-undo .
define variable v-discnt-role as character no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
define variable r-b-code as integer no-undo .
define variable v-sts as integer no-undo .
define variable glog as logical no-undo .
define variable v-mode as character no-undo .
define variable v-item as character no-undo .
define variable v-rule-num as integer no-undo .
define variable dflt-cd as character no-undo .
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
define buffer buf_dis-rule for ub.dis-rule.
if v-cntxt-obj-type = 'скл':U then do:
  dflt-cd = '-':U.
end.
else do:
define variable vss-include-info73 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type73 as character no-undo .
define variable v-value-date73 as date no-undo .
define variable v-value-decimal73 as decimal no-undo .
define variable v-value-integer73 as INTEGER no-undo .
define variable v-value-logical73 AS LOGICAL no-undo .
define variable v-tth73 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output dflt-cd
    ,output v-value-date73
    ,output v-value-decimal73
    ,output v-value-integer73
    ,output v-value-logical73
    ,output v-param-type73
    ,INPUT-OUTPUT table-handle v-tth73
    )  .
delete object v-tth73 no-error.
  assign
  v-pos-type = dflt-cd + chr(44) + '-':U + chr(44) + 'bo':U.
end.
run ref/dis-pos.w ( INPUT parparentproc
                    ,INPUT "b-sel":U
                    ,INPUT (if rs-list-method = "dis-gds-rule"
                           then "cd-type-list-without-template-pos"
                           else "cd-type-list")
                    ,INPUT 1
                    ,INPUT 1
                    ,INPUT 1
                    ,input 'dis-gds-rule':U
                    ,input '':U
                    ,input ?
                    ,INPUT v-pos-type
                    ,input '':U
                    ,INPUT-OUTPUT v-rid-list) NO-ERROR.
IF ERROR-STATUS:ERROR
OR v-rid-list = '':U THEN DO:
  RETURN.
END.
FIND FIRST buf_dis-cfg-rule NO-LOCK where
          recid(buf_dis-cfg-rule) = INTEGER(v-rid-list).
assign
v-templ-rl-root = buf_dis-cfg-rule.templ-rl-root
v-time-templ-rl-root = buf_dis-cfg-rule.time-templ-rl-root
V-cfg-NONUNIQUE = buf_dis-cfg-rule.nonunique
v-discnt-role = buf_dis-cfg-rule.discnt-role
.
if rs-list-method = "dis-gds-rule" then do:
  message
  "Все товары со скидкой типа" entry (lookup (buf_dis-cfg-rule.discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u) skip
  stat-line(rs-status)
  view-as alert-box question buttons OK-Cancel update glog.
end.
else do:
  message
  "Все товары со скидкой типа" entry (lookup (buf_dis-cfg-rule.discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u) "и определенным номером правила скидки" skip
  stat-line(rs-status)
  view-as alert-box question buttons OK-Cancel update glog.
end.
if not glog then do:
  return error.
end.
if (buf_dis-cfg-rule.has-global +
    buf_dis-cfg-rule.has-host +
    buf_dis-cfg-rule.has-obj) > 1 then do:
  define variable v-sel-vals as character no-undo .
  define variable v-sel-labels as character no-undo .
  define variable var-region as character no-undo .
  assign
  v-sel-vals = v-sel-vals +
                (if buf_dis-cfg-rule.has-global = 1
                then (fill(chr(32), 3)  + string(0) + chr(4) )
                else "":U)
  v-sel-labels = v-sel-labels +
                (if buf_dis-cfg-rule.has-global  = 1
                then ("Глобально" + chr(4) )
                else "":U)
  .
  assign
  v-sel-vals = v-sel-vals +
                (if buf_dis-cfg-rule.has-host = 1
                then ('орг':U  + string(v-cntxt-host-code-obj)  + chr(4) )
                else "":U)
  v-sel-labels = v-sel-labels +
                (if buf_dis-cfg-rule.has-host = 1
                then ("Фирма"  + string(v-cntxt-host-code-obj) + chr(4) )
                else "":U)
  .
  assign
  v-sel-vals = v-sel-vals +
                (if buf_dis-cfg-rule.has-obj = 1
                then (v-cntxt-obj-type  + string(v-cntxt-obj-code)  + chr(4) )
                else "":U)
  v-sel-labels = v-sel-labels +
                (if buf_dis-cfg-rule.has-obj = 1
                then (v-cntxt-obj-type  + string(v-cntxt-obj-code)  + chr(4) )
                else "":U)
  .
  run gbl/d-list.w (
                      input "b-sel":U
                      ,input "Выберите область действия"
                      ,input v-sel-vals
                      ,input v-sel-labels
                      ,input chr(4)
                      ,input "":U
                      ,output var-region) no-error.
  if error-status:error then do:
    return error.
  end.
  assign
  v-obj-type = substring(var-region, 1, 3)
  v-obj-code = integer(substring(var-region, 4))
  v-sel-obj-type = v-obj-type
  v-sel-obj-code = v-obj-code
  .
end.
else do:
  if buf_dis-cfg-rule.has-obj = 1 then do:
define variable vss-include-info74 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    assign
    v-obj-type = v-sel-obj-type
    v-obj-code = v-sel-obj-code
    .
  end.
  if buf_dis-cfg-rule.has-host = 1 then do:
    define variable v-host-code as integer no-undo .
    assign
    v-obj-type = 'орг':U
    v-obj-code = v-cntxt-host-code-obj
    .
  end.
  if buf_dis-cfg-rule.has-glob = 1 then do:
    assign
    v-obj-type = '':U
    v-obj-code = 0
    .
  end.
end.
if rs-list-method = "dis-gds-rule" then do:
  assign
  dsp-rs = substitute("ВСЕ товары с установленным типом скидки &1 &2"
                    , get-objregion(v-obj-type, v-obj-code), stat-line(rs-status))
  v-item = v-sel-obj-type + chr(3) + string(v-sel-obj-code) + chr(3) + v-discnt-role   .
end.
else do:
  v-mode = (if v-obj-type = 'маг':U
            or v-obj-type = 'скл':U
            then "upper-rule-num-object":u
            else ('dis-gds-rule':U + "=" + v-discnt-role)).
  run ref/dis-ruls.w (
               input parparentproc
              ,input 0
              ,input v-obj-type
              ,input v-obj-code
              ,input "b-add,b-sel":U
              ,input v-mode
              ,input v-templ-rl-root
              ,input v-time-templ-rl-root
              ,input r-b-code
              ,input-output v-sts
              ,input-output v-rid-list ) no-error .
  if v-rid-list = '':u then do:
    return error.
  end.
  find first buf_dis-rule no-lock where
           recid(buf_dis-rule) = integer(v-rid-list) no-error.
  if available buf_dis-rule then do:
  assign
  dsp-rs = substitute("ВСЕ товары с установленным типом скидки: &1, № правила &2 &3"
                      ,get-objregion(v-obj-type, v-obj-code)
                      ,v-rule-num
                      ,stat-line(rs-status))
  v-item = v-sel-obj-type + chr(3) +
            string(v-sel-obj-code) + chr(3) +
              v-discnt-role + chr(3) + string(buf_dis-rule.rule-num)
  .
end.
  else do:
    message
    substitute("Не найдено провило скидки с recid &1", v-rid-list)
    view-as alert-box error .
    return error.
  end.
end.
v-no-hist = 0.
run create-gds-list-flt-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
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
procedure proc-scn-tsd :
define variable glog as logical no-undo .
define buffer buf_gds-list-flt-hist for gds-list-flt-hist.
  do
  on error undo, return error
  :
  run str/diallog.w (parparentproc
              , this-procedure
              , 'str/rsendtsd.p':U
              , (p-curr-obj-type + chr(4) + string(p-curr-obj-code))
              , no
              , '':U
              , 'Пересылка товаров на ТСД') no-error .
  end.
end procedure.
procedure proc-macros :
define variable glog as logical no-undo .
define variable v-option as integer no-undo .
define buffer buf_gds-list-flt-hist for gds-list-flt-hist.
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
    f-name = "default.gdm"
    glog = yes
    .
  system-dialog get-file f-name
    filters "Макрос создания списка товара *.gdm" "*.gdm"
    ask-overwrite
    save-as
    use-filename
    update glog
    default-extension "gdm".
  if not glog then do:
    apply "entry" to br-list in frame Dialog-Frame.
    return no-apply.
  end.
  run waitfram-show in this-procedure ("Сохранение макроса формирования списка товара.    ЖДИТЕ...").
  output stream PrnLibStream to value (f-name).
  case v-option:
    when 1 then do:
      for each buf_macro-list-hist:
        export stream PrnLibStream
        buf_macro-list-hist.
      end.
    end.
    when 2 then do:
  for each buf_gds-list-flt-hist:
      export stream PrnLibStream
      buf_gds-list-flt-hist.
  end.
    end.
  end case.
  output stream PrnLibStream close.
  run waitfram-hide in this-procedure .
  end.
end procedure.
PROCEDURE trig-tax-rate-value :
define input parameter p-rs-list-method as character no-undo .
define output parameter p-date as date no-undo .
DEFINE VARIABLE v-codes          as character           no-undo.
DEFINE VARIABLE v-labels         as character           no-undo.
DEFINE VARIABLE v-type           as character           no-undo.
DEFINE VARIABLE v-format         as character           no-undo.
DEFINE VARIABLE v-values         as character           no-undo.
DEFINE VARIABLE v-code-output    as character           no-undo.
DEFINE VARIABLE v-value-output   as character           no-undo.
define variable vlabel           as character           no-undo .
define variable v-date-chr       as character           no-undo .
DEFINE VARIABLE v-time           as integer             no-undo .
DEFINE VARIABLE v-ref-list           as character           no-undo .
DEFINE VARIABLE jj                   as integer             no-undo .
define variable glog as logical no-undo .
assign
v-attr-code = ""
vvalue = ""
v-codes = '1':U + chr(4) + '2':U
v-labels = "НДС" + chr(4) +  "НП"
v-values = "0" + chr(4) + "0"
v-format = ">9.99":U + chr(4) + ">9.99":U
v-type = 'D':U + chr(4) + 'D':U
.
run gbl/d-listv.w (
               "b-mark,b-sel":U
              ,"Выберите налоги"
              , v-codes
              , v-labels
              , v-values
              , v-format
              , v-type
              , chr(4)
              , "":U
              , output v-attr-code
              , output vvalue
              ).
if v-attr-code = "" then do:
  return error.
end.
do jj = 1 to num-entries(v-attr-code, chr(4)):
  assign
  vlabel = vlabel + entry(LOOKUP(entry(jj, v-attr-code, chr(4)), v-codes, chr(4)), v-labels, chr(4)) + "=":U + entry(jj, vvalue, chr(4)) + chr(10)
  .
end.
run cur-time in this-procedure(output p-date, output v-time).
assign
v-date-chr = string(p-date, "99/99/9999":U)
.
run gbl/d-prompt.w (
  'title=':u + "Введите дату значения налогов" + '\':u
+ 'text1=':u + "Дата" + '\':u
+ 'format=' + "99/99/9999" + '\':u
+ 'type=' + 'T':U + '\':u
+ 'fillin_row=2\':u
+ 'fillin_col=4\':u
+ 'fillin_width=20\':u
+ 'fillin_height=1\':u
+ 'max-chars=70\':u
+ 'readonly=no' + '\':u
, input-output v-date-chr
).
if return-value = 'false':u then return error.
assign
p-date = date( integer(substr(v-date-chr, 4, 2))
              ,integer(substr(v-date-chr, 1, 2))
              ,integer(substr(v-date-chr, 7, 4))
             )
no-error .
if error-status:error then return error.
define variable vss-include-info75 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
glog = yes.
if p-rs-list-method = "tax-rate-value":U then do:
  message
  "Все товары с заданными значениями налогов на объекте на дату" v-date-chr skip
  vlabel skip
  stat-line(rs-status)
  view-as alert-box question buttons OK-Cancel update glog.
end.
if p-rs-list-method = "tax-rate-value-obj":U then do:
  message
  "Товары объекта с заданными значениями налогов на объекте на дату" v-date-chr skip
  vlabel skip
  stat-line(rs-status)
  view-as alert-box question buttons OK-Cancel update glog.
end.
if not glog then do:
  return error.
end.
if p-rs-list-method = "tax-rate-value":U then do:
  dsp-rs = substitute("ВСЕ товары с заданными значениями налогов на объекте &1 на дату &2 &3", vlabel, p-date, stat-line(rs-status)).
end.
if p-rs-list-method = "tax-rate-value-obj":U then do:
  dsp-rs = substitute("Товары объекта &1 с заданными значениями налогов на объекте &2 на дату &3 &4", vlabel, vlabel, p-date, stat-line(rs-status)).
end.
run create-gds-list-flt-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                    , input-output v-seq
                                    , input 0
                                    , input '':U
                                    , input dsp-rs
                                    , input tot-lns
                                    , input rs-list-method
                                    , input rs-status
                                    , input v-sel-obj-type + chr(3) + string(v-sel-obj-code) + chr(3) +
                                            string(p-date, "99/99/9999") + chr(3) + v-attr-code + chr(3) + vvalue
                                    , input '':U
                                    , input ?
                                    ).
END PROCEDURE.
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
      find ub.goods where rowid(ub.goods) = p-rowid no-lock no-error .
    end.
    else do:
      run ref/gds-ref.p ( parparentproc
                      ,"b-sel,b-add"
                      ,?
                      ,?
                      ,?
                      ,?
                      ,?
                      ,?
                      ,?
                      ,p-curr-obj-type
                      ,p-curr-obj-code
                      ,?
                      , output ref-list).
      apply "entry" to br-list in frame Dialog-Frame.
      if ref-list = "" then
        return no-apply.
      find ub.goods where recid (ub.goods) = integer (ref-list) no-lock.
    end.
    if available goods then do:
      run ex-gds  in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      tot-lns = tot-lns + 1.
      run write-hist in this-procedure ( p-from-macro, rs-list-method, rs-status, line-mode).
    end.
    else do:
      return error "Нет в БД такого товара".
    end.
    run UI-on  in this-procedure.
  end.
  else
    run rs-do  in this-procedure( no, no, rs-list-method, rs-status, line-mode, v-seq - 1).
  end.
end procedure.
procedure proc-b-del :
define input parameter p-from-macro as logical no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
define variable v-rep-rec as recid no-undo .
define variable glog as logical no-undo .
  do
  on error undo, return error
  :
    line-mode = 'удаление':U.
    if rs-list-method = "single" then do:
      v-no-hist = - 1.
      if p-from-macro then do:
        find first ub.goods where rowid(ub.goods) = p-rowid no-error.
        if not available ub.goods then return error "Нет в БД такого товара".
        find first gds-list-flt where gds-list-flt.gds-code = ub.goods.gds-code no-error.
      end.
      if available gds-list-flt then do:
        line-rec = recid (gds-list-flt).
        get next br-list.
        if available gds-list-flt then v-rep-rec = recid (gds-list-flt).
        else do:
          reposition br-list to recid line-rec no-error.
          get prev br-list.
          if available gds-list-flt then v-rep-rec = recid (gds-list-flt).
        end.
        reposition br-list to recid line-rec no-error.
        tot-lns = tot-lns - 1.
        run write-hist in this-procedure ( p-from-macro, rs-list-method, rs-status, line-mode).
        delete gds-list-flt.
        line-rec = v-rep-rec.
        run UI-on in this-procedure.
      end.
      else do:
        return error "Нет в списке товаров такого товара".
      end.
    end.
    else do:
      glog = no.
      message "Удалить товары ПО заданному УСЛОВИЮ ?   Вы уверены ?"
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then
        return no-apply.
      run rs-do  in this-procedure( no, no, rs-list-method, rs-status, line-mode, v-seq - 1).
    end.
  end.
end procedure.
procedure proc-b-rest :
define input parameter p-from-macro as logical no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
define buffer buf_gds-list-flt-hist for gds-list-flt-hist.
define variable glog as logical no-undo .
  do
  on error undo, return error
  :
    line-mode = 'ОСТАВИТЬ':U.
    if rs-list-method = "single" then do:
      v-no-hist = - 1.
      if p-from-macro then do:
        find first ub.goods where rowid(ub.goods) = p-rowid no-error.
        if not available ub.goods then return error substitute("Нет в БД такого товара").
        find first gds-list-flt where gds-list-flt.gds-code = ub.goods.gds-code no-error.
      end.
      if available gds-list-flt then do:
        if p-from-macro then do:
          glog = yes.
        end.
        else do:
          glog = no.
          message "Оставить отмеченную строку и УДАЛИТЬ ВСЕ ОСТАЛЬНЫЕ ?   Вы уверены ?"
          view-as alert-box question buttons OK-Cancel update glog.
          if not glog then return error.
        end.
        line-rec = recid (gds-list-flt).
        v-seq = 1.
        for each buf_gds-list-flt-hist:
          delete buf_gds-list-flt-hist.
        end.
        run write-hist  in this-procedure ( p-from-macro, rs-list-method, rs-status, line-mode).
        for each gds-list-flt:
          if line-rec <> recid (gds-list-flt) then delete gds-list-flt.
        end.
        assign
        tot-lns = 1
        .
        run UI-on  in this-procedure.
      end.
      else do:
        return error substitute("Нет в списке такого товара").
      end.
    end.
    else do:
      glog = no.
      if not p-from-macro then do:
        message "Оставить товары ПО заданному УСЛОВИЮ и УДАЛИТЬ ВСЕ ОСТАЛЬНЫЕ ?   Вы уверены ?"
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then
          return no-apply.
      end.
      assign
      lns-cnt = 0
      lns-ignore = 0
      .
      run rs-do  in this-procedure ( no, no, rs-list-method, rs-status, line-mode, v-seq - 1).
      for each gds-list-flt:
        if gds-list-flt.to-del = ? then do:
          assign
          gds-list-flt.to-del = no
          .
        end.
        else do:
          delete gds-list-flt.
        end.
      end.
      tot-lns = lns-cnt.
      run UI-on  in this-procedure.
      message
      "Оставлено строк :" lns-cnt skip(0)
      string(if lns-ignore <> 0
      then ("Проигнорировано строк :" + string(lns-ignore))
      else "":U)
      .
    end.
  end.
end procedure.
procedure proc-b-obj :
  define input parameter p-mode as character no-undo .
  define buffer buf_clients  for ub.clients.
  do
  on error undo, return error
  :
    if p-mode = "change":U then do:
define variable vss-include-info76 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    end.
    if v-user-select then do:
      find first buf_clients no-lock where
                 buf_clients.obj-type = v-sel-obj-type
             and buf_clients.obj-code = v-sel-obj-code no-error.
      if not available buf_clients then do: return error. end.
      assign
        p-curr-obj-type = buf_clients.obj-type
        p-curr-obj-code = buf_clients.obj-code
        p-curr-host-code = buf_clients.host-code
        v-obj-type = buf_clients.obj-type
        v-obj-code = buf_clients.obj-code
        v-obj-name = buf_clients.obj-name
      .
      if lookup(bttns, "hide") = 0 then do:
        display
        v-obj-name
        v-obj-type
        v-obj-code
        with frame Dialog-Frame.
      end.
    end.
  end.
end procedure.
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
define variable v-num-add          as integer no-undo .
define variable v-num-ignored      as integer no-undo .
define variable v-tbl-row          as rowid no-undo .
define variable v-tbl-name         as character no-undo .
define buffer buf_gds-list-flt-hist for gds-list-flt-hist.
define buffer buf_clob-data for ub.clob-data.
define buffer buf_clob-bind for ub.clob-bind.
do
on error undo, return error
:
find first buf_gds-list-flt-hist where
          buf_gds-list-flt-hist.id = p-id
      AND buf_gds-list-flt-hist.item_ <> '':U .
if rs-list-method = "clob-data" then do:
  run gen-row-keyr in this-procedure (
   input  buf_gds-list-flt-hist.item_
  ,input  ?
  ,input  "ub"
  ,input  ?
  ,input NO-LOCK
  ,output v-tbl-row
  ,output v-tbl-name  ) no-error.
  if error-status :error then do:
    message
    "Ошибка при поиске хранимого файла"
    view-as alert-box error.
    return error.
  end.
  find first buf_clob-bind no-lock where
            rowid(buf_clob-bind) = v-tbl-row .
  find first buf_clob-data no-lock where
            buf_clob-data.db-num = buf_clob-bind.db-num
        and buf_clob-data.int64-id = buf_clob-bind.int64-id no-error.
  if error-status :error then do:
    message
    "Ошибка при пополучении хранимого файла"
    view-as alert-box error.
    return error.
  end.
  run gbl/_tmpfile.p ( input ""
                ,input "tmp"
                ,output v-file-name) .
  copy-lob from object buf_clob-data.cdata
  to file v-file-name.
end.
run gbl/filename.p
    (input  (if rs-list-method = "clob-data" then v-file-name else buf_gds-list-flt-hist.item_  )
  ,output v-full-path
  ,output v-path
  ,output v-file-name
  ,output v-file-name-no-ext
  ,output v-file-name-ext
  ) no-error .
  if error-status:error then do: end. else do:
  input stream sout from value (v-full-path).
  CASE rs-list-method:
    when "doc-list" then do:
      repeat:
        import stream sout imp-doc-code imp-doc-type no-error.
        if imp-doc-type = 'переоценка':U then do:
          find first ub.price-doc No-LOCK WHERE
                    ub.price-doc.doc-num = imp-doc-code No-ERROR.
          if avail(ub.price-doc) then do:
            FOR EACH ub.price-list No-LOCK WHERE
                    ub.price-list.doc-num = ub.price-doc.doc-num,
                FIRST ub.goods No-LOCK WHERE
                      ub.goods.artic = ub.price-list.artic AND
                      ub.goods.prod-type = ub.price-list.prod-type AND
                      ub.goods.prod-code = ub.price-list.prod-code:
              run ex-gds  in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
              if available gds-list-flt and
                gds-list-flt.artic = ub.goods.artic and
                gds-list-flt.prod-type = ub.goods.prod-type and
                gds-list-flt.prod-code = ub.goods.prod-code then
                gds-list-flt.qnty = scan-qnty.
            END.
          end.
        end.
        else do:
          find first ub.trn-doc NO-LOCK where
                    ub.trn-doc.doc-code = imp-doc-code No-ERROR.
          if avail(ub.trn-doc) then do:
            FOR EACH ub.doc-line NO-LOCK where
                    ub.doc-line.doc-code = ub.trn-doc.doc-code,
                FIRST ub.goods where ub.goods.artic = ub.doc-line.artic
                            and ub.goods.prod-type = ub.doc-line.prod-type
                            and ub.goods.prod-code = ub.doc-line.prod-code NO-LOCK:
              run ex-gds  in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
              if available gds-list-flt and
                gds-list-flt.artic = ub.goods.artic and
                gds-list-flt.prod-type = ub.goods.prod-type and
                gds-list-flt.prod-code = ub.goods.prod-code then
                gds-list-flt.qnty = scan-qnty.
            end.
          end.
        end.
      end.
    end.
    when "prod-list" then do:
      repeat:
        import stream sout imp-type imp-code no-error.
        for each ub.goods where ub.goods.prod-type = imp-type
                    and ub.goods.prod-code = imp-code no-lock:
          run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
        end.
      end.
    end.
    when "supp-list" then do:
      repeat:
        import stream sout imp-type imp-code no-error.
        for each ub.cli-gds where ub.cli-gds.cli-type = imp-type
                            and ub.cli-gds.cli-code = imp-code
                            and ub.cli-gds.host-code = p-curr-host-code no-lock,
              first ub.goods where ub.goods.artic = ub.cli-gds.artic
                          and ub.goods.prod-type = ub.cli-gds.prod-type
                          and ub.goods.prod-code = ub.cli-gds.prod-code no-lock:
          run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
        end.
      end.
    end.
    when "cli-list" then do:
      input stream sout from value (f-cli-name).
      repeat:
        import stream sout imp-type imp-code no-error.
        for each ub.trn-doc where ub.trn-doc.cli-type = imp-type
                          and ub.trn-doc.cli-code = imp-code no-lock:
          for each ub.doc-line where ub.doc-line.doc-code = ub.trn-doc.doc-code no-lock,
              first ub.goods where ub.goods.artic = ub.doc-line.artic
                            and ub.goods.prod-type = ub.doc-line.prod-type
                            and ub.goods.prod-code = ub.doc-line.prod-code no-lock:
            run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
          end.
        end.
      end.
    end.
    when "file"
    or when "clob-data"
    then do:
      repeat:
        import stream sout imp-type imp-code imp-art scan-qnty no-error.
        find ub.goods where ub.goods.prod-type = imp-type
                    and ub.goods.prod-code = imp-code
                    and ub.goods.artic     = imp-art no-lock no-error.
        if available ub.goods then run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
        if available ub.goods and  available gds-list-flt and
          gds-list-flt.artic = ub.goods.artic and
          gds-list-flt.prod-type = ub.goods.prod-type and
          gds-list-flt.prod-code = ub.goods.prod-code then
          gds-list-flt.qnty = scan-qnty.
      end.
      if rs-list-method = "clob-data" then do:
        os-delete value(v-full-path) .
      end.
    end.
    when "scaner" then do:
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
,input  p-curr-obj-code
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
        find ub.goods where ub.goods.gds-code = ub.bar-code.gds-code NO-LOCK.
        run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
        if available gds-list-flt and
          gds-list-flt.artic = ub.goods.artic and
          gds-list-flt.prod-type = ub.goods.prod-type and
          gds-list-flt.prod-code = ub.goods.prod-code then
          gds-list-flt.qnty = gds-list-flt.qnty + scan-qnty * bc-qnty.
      end.
    end.
  END CASE.
  input stream sout close.
  assign                                                           buf_gds-list-flt-hist.num-add  = lns-cnt - v-num-add                       buf_gds-list-flt-hist.num-recs = (if line-mode = 'ОСТАВИТЬ':U                                            then (tot-lns + buf_gds-list-flt-hist.num-add)                                            else (tot-lns + (if line-mode = 'ДОБАВЛЕНИЕ':U then 1 else - 1) * lns-cnt))                   tot-lns               = (if line-mode = 'ОСТАВИТЬ':U then lns-cnt else tot-lns)                     buf_gds-list-flt-hist.num-ignored = lns-ignore  - v-num-ignored                    v-num-add             = lns-cnt                                   v-num-ignored         = lns-ignore.
  end.
end.
end procedure.
procedure analysis:
define input  parameter p-method as character no-undo .
define variable glog as logical   no-undo .
define variable v-run as character no-undo .
define variable an-option as character no-undo .
define variable v-tbl-name as character no-undo .
define variable v-bh as handle no-undo .
define variable v-recs as integer   no-undo .
define variable v-temp-seq as integer   no-undo .
define variable v-line as integer   no-undo .
define variable v-item as character no-undo .
define variable v-tot-lns as integer   no-undo .
do
on error undo, return error return-value
:
  glog = yes.
  CASE p-method:
    when "abcxyz":U then do:
      assign
      dsp-rs = substitute("Товары ABC/XYZ анализа.&1&2",  stat-line(rs-status))
      v-run = 'ref/abcxyzv.w':U
      an-option = "abcxyz"
      v-tbl-name = 'abcxyz-analysis':U
      v-bh       = buffer ub.abcxyz-analysis:handle
      .
    end.
    when "abc-analysis":U then do:
      assign
      dsp-rs = substitute("Товары ABC анализа.&1&2",  stat-line(rs-status))
      v-run = 'ref/abcanal.w':U
      an-option = "abc"
      v-tbl-name = 'abc-analysis':U
      v-bh       = buffer ub.abc-analysis:Handle
      .
    end.
    when "xyz-analysis":U then do:
      assign
      dsp-rs = substitute("Товары XYZ анализа.&1&2",  stat-line(rs-status))
      v-run = 'ref/xyzanal.w':U
      an-option = "xyz"
      v-tbl-name = 'xyz-analysis':U
      v-bh       = buffer ub.xyz-analysis:Handle
      .
    end.
  END CASE.
  message
  dsp-rs
  view-as alert-box question buttons OK-Cancel update glog.
  if not glog then do:
    run UI-on  in this-procedure.
    return error.
  end.
  run value(v-run)(parparentproc,"b-sel":U, output ref-list).
  if ref-list <> "" then run ref/togabc.w (input an-option, output list-abcxyz).
  if ref-list = "" or list-abcxyz = "" then do:
    run UI-on in this-procedure.
    return error.
  end.
  if num-entries(ref-list) = 1 then do:
    CASE rs-list-method:
      when "abcxyz":U then do:
        find abcxyz-analysis where recid (abcxyz-analysis) = integer(entry(1, ref-list)) no-lock.
        dsp-rs = substitute("ABCXYZ Анализ : &1&2&3"
                            ,abcxyz-analysis.abcx-name
                            , chr(10)
                            , stat-line(rs-status)
                            ).
      end.
      when "abc-analysis":U then do:
        find abc-analysis where recid (abc-analysis) = integer(entry(1, ref-list)) no-lock.
        dsp-rs = substitute("ABC Анализ : &1&2&3"
                            ,abc-analysis.abc-name
                            , chr(10)
                            , stat-line(rs-status)
                            ).
      end.
      when "xyz-analysis":U then do:
        find xyz-analysis where recid (xyz-analysis) = integer(entry(1, ref-list)) no-lock.
        dsp-rs = substitute("XYZ Анализ : &1&2&3"
                            ,xyz-analysis.xyz-name
                            ,chr(10)
                            ,stat-line(rs-status)
                            ).
      end.
    end CASE.
    v-recs = num-entries(list-abcxyz).
    do num-rec = 0 to v-recs:
      if num-rec = 0 then do:
        assign
        v-temp-seq = v-seq
        v-line     = 0
        v-item     = '':U
        v-tot-lns = tot-lns
        .
      end.
      else do:
        assign
        v-temp-seq = v-seq - 1
        v-line     = num-rec
        dsp-rs = substitute("Группа &1", entry(num-rec, list-abcxyz))
        v-item     = entry(num-rec, list-abcxyz)
        v-tbl-name = '':U
        v-bh       = ?
        v-tot-lns = tot-lns + num-rec
        .
      end.
      v-no-hist = (if num-rec = 1 then 0 else num-rec).
      run create-gds-list-flt-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                          , input-output v-temp-seq
                                          , input v-line
                                          , input '':U
                                          , input dsp-rs
                                          , input v-tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input v-item
                                          , input v-tbl-name
                                          , input v-bh
                                          ).
      if num-rec = 0 then v-seq  = v-temp-seq.
    end.
  end.
end.
end procedure.
procedure collection :
define input  parameter p-method as character no-undo .
define variable glog as logical   no-undo .
define variable v-run as character no-undo .
define variable an-option as character no-undo .
define variable v-tbl-name as character no-undo .
define variable v-bh as handle no-undo .
define variable v-recs as integer   no-undo .
define variable v-temp-seq as integer   no-undo .
define variable v-line as integer   no-undo .
define variable v-item as character no-undo .
define variable v-tot-lns as integer   no-undo .
do
on error undo, return error return-value
:
  glog = yes.
  CASE p-method:
    when "collection":U then do:
      assign
      dsp-rs = substitute("Товары по коллекции.&1&2",  stat-line(rs-status))
      v-run = 'ref/collec.w':U
      an-option = "sea"
      v-tbl-name = 'season'
      v-bh       = buffer ub.season:Handle
      .
    end.
  END CASE.
  message
  dsp-rs
  view-as alert-box question buttons OK-Cancel update glog.
  if not glog then do:
    run UI-on.
    return error.
  end.
  run value(v-run) (parParentProc, "b-sel":U, output ref-list).
  if ref-list = "" then do:
    run UI-on.
    return error.
  end.
  if num-entries(ref-list) = 1 then do:
    CASE rs-list-method:
      when "collection":U then do:
        find ub.season where recid (ub.season) = integer(entry(1, ref-list)) no-lock.
        dsp-rs = substitute("Коллекция : &1&2&3"
                            ,ub.season.sea-name
                            , chr(10)
                            , stat-line(rs-status)
                            ).
      end.
    end CASE.
    v-recs = num-entries(ref-list).
    do num-rec = 0 to v-recs:
      if num-rec = 0 then do:
        assign
        v-temp-seq = v-seq
        v-line     = 0
        v-item     = '':U
        v-tot-lns = tot-lns
        .
      end.
      else do:
        assign
        v-temp-seq = v-seq - 1
        v-line     = num-rec
        v-item     = entry(num-rec, ref-list)
        v-tbl-name = '':U
        v-bh       = ?
        v-tot-lns = tot-lns + num-rec
        .
      end.
      v-no-hist = (if num-rec = 1 then 0 else num-rec).
      run create-gds-list-flt-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                          , input-output v-temp-seq
                                          , input v-line
                                          , input '':U
                                          , input dsp-rs
                                          , input v-tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input v-item
                                          , input v-tbl-name
                                          , input v-bh
                                          ).
      if num-rec = 0 then v-seq  = v-temp-seq.
    end.
  end.
end.
end procedure.
procedure object-options :
define input  parameter p-method as character no-undo .
define variable glog as logical   no-undo .
define variable v-message as character no-undo .
define buffer buf_gds-list-flt-hist for gds-list-flt-hist.
define buffer buf_user-obj for ub.user-obj.
do
on error undo, return error return-value
:
  glog = yes.
  case p-method:
    when "object" then do:
      assign
      v-message = substitute("Все товары из справочника товаров по объекту.&1&2"
                              , chr(10)
                              , stat-line(rs-status))
      dsp-rs    = "Все товары по объекту : &1 &2"
      .
    end.
    when "available"  then do:
        assign
        v-message = substitute("Все товары, остаток которых на объекте > 0.&1&2"
                              , chr(10)
                              , stat-line(rs-status))
        dsp-rs =   "ВСЕ товары, имеющиеся в наличии на/в &1 &2"
        .
    end.
    when "neg-rest" then do:
        assign
        v-message = substitute("Все товары с отрицательными остатками на объекте.&1&2"
                              , chr(10)
                              , stat-line(rs-status))
        dsp-rs     = "ВСЕ товары с отрицательными остатками на/в &1 &2"
        .
    end.
    when "neg-part" then do:
        assign
        v-message = substitute("Все товары, имеющие отрицательные партии на объекте (остаток при этом может быть любым).&1&2"
                              , chr(10)
                              , stat-line(rs-status))
        dsp-rs    = "ВСЕ товары с отрицательными партиями на/в &1 &2"
        .
    end.
    when "neg-part-free" then do:
        assign
        v-message = substitute("Все товары, имеющие отрицательные партии в свободной зоне на объекте (остаток при этом может быть любым).&1&2"
                              , chr(10)
                              , stat-line(rs-status))
        dsp-rs    = "ВСЕ товары с отрицательными партиями в свободной зоне на/в &1 &2"
        .
    end.
    when "neg-prt" then do:
        assign
        v-message = substitute("Все товары с признаками с отрицательными остатками по признакам на объекте.&1&2"
                              , chr(10)
                              , stat-line(rs-status))
        dsp-rs    =  "ВСЕ товары с признаками с отриц. ост. по признаку на/в &1 &2"
        .
    end.
    when "nul-rest" then do:
        assign
        v-message = substitute("Все товары с нулевыми остатками на объекте.&1&2"
                              , chr(10)
                              , stat-line(rs-status))
        dsp-rs     = "ВСЕ товары с нулевыми остатками на/в &1 &2"
        .
    end.
    when  "input" then do:
      assign
      v-message = substitute("Все товары, когда либо бывшие (или имеющиеся сейчас) на объекте.&1&2"
                              , chr(10)
                              , stat-line(rs-status))
      dsp-rs = "ВСЕ товары, проходившие когда-либо по &1 &2"
      .
    end.
    when "with-price" then do:
      assign
      v-message = substitute("Все товары на объекте, имеющие продажную цену > 0 .&1&2"
                              , chr(10)
                              , stat-line(rs-status))
      dsp-rs     = "ВСЕ товары, имеющие цену > 0 по &1 &2"
      .
    end.
    when "ov-req" then do:
      assign
      v-message = substitute("Товары, которые нельзя расходовать с объекта без переоценки&1" +
                            "(попадающие под действие настройки, требующей переоценки после&1" +
                            "любого прихода на объект).&1&2"
                              , chr(10)
                              , stat-line(rs-status))
      dsp-rs = "Товары, по которым требуется переоценка после ПРИХОДА на/в &1 &2 "
      .
    end.
    WHEN "inv-req" then do:
      assign
      v-message = substitute("Товары, количество по которым изменялось со времени последней&1" +
                              "инвентаризации на объекте (своей для каждого товара).&1&2"
                              , chr(10)
                              , stat-line(rs-status))
      dsp-rs = "Товары, по которым были ОБОРОТЫ после ИНВЕНТАРИЗАЦИИ на/в &1 &2"
      .
    end.
    when "etalon" then do:
      ASSIGN
      v-message = substitute("Все товары из справочника товаров по ТЕКУЩЕМУ объекту, цены по которым&1" +
                              "НЕ совпадают с ценами на выбранном ЭТАЛОННОМ объекте&1" +
                              "(только при условии, что цена есть на том и другом объектах).&1&2"
                              , chr(10)
                              , stat-line(rs-status))
      dsp-rs = "Цены на/в &1 &2, не совпадающие с ценами на &3 &4"
      .
    end.
  END CASE.
  message v-message
  view-as alert-box question buttons OK-Cancel update glog.
  if not glog then do:
    run UI-on  in this-procedure.
    return error.
  end.
    ref-list = "":U.
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
                         if not v-user-select then do:     run UI-on in this-procedure .     return no-apply.   end.
    find first buf_user-obj no-lock where
              buf_user-obj.obj-type = v-sel-obj-type
          and buf_user-obj.obj-code = v-sel-obj-code
          AND buf_user-obj.db-num = v-cntxt-db-num
          AND buf_user-obj.user-id = v-cntxt-userid  no-error .
    if not available buf_user-obj then do:
      run ui-on in this-procedure .
      return error.
    end.
    if p-method = "etalon"
    and p-curr-obj-type = v-sel-obj-type
    and p-curr-obj-code = v-sel-obj-code then do:
      message "Бессмысленно сравнивать цены для одного и того же объекта.".
      run UI-on  in this-procedure.
      return error.
    end.
    if p-method = "etalon":U then do:
      assign
      dsp-rs = replace(dsp-rs, "&1", p-curr-obj-type)
      dsp-rs = replace(dsp-rs, "&2", string(p-curr-obj-code))
      dsp-rs = replace(dsp-rs, "&3", v-sel-obj-type)
      dsp-rs = replace(dsp-rs, "&4", string(v-sel-obj-code))
      dsp-rs = substitute("&1 &2", dsp-rs, stat-line(rs-status))
      .
    end.
    else do:
      assign
      dsp-rs = replace(dsp-rs, "&1", v-sel-obj-type)
      dsp-rs = replace(dsp-rs, "&2", string(v-sel-obj-code))
      dsp-rs = substitute("&1 &2", dsp-rs, stat-line(rs-status))
      .
    end.
    run create-gds-list-flt-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                                        , input-output v-seq
                                        , input 0
                                        , input '':U
                                        , input dsp-rs
                                        , input tot-lns
                                        , input p-method
                                        , input rs-status
                                        , input '':U
                                        , input 'user-obj':U
                                        , input buffer buf_user-obj:handle
                                        ).
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
    if not available gds-list-flt then do:
      message
      "Это первый товар списка"
      view-as alert-box.
    end.
  end.
  when "next":U
  then do:
    get next br-list.
    if not available gds-list-flt then do:
      message
      "Это последний товар списка"
      view-as alert-box.
    end.
  end.
end case .
find first buf_goods no-lock where
        buf_goods.gds-code = gds-list-flt.gds-code no-error.
if available gds-list-flt then do:
  assign
  p-recid = recid(buf_goods)
  .
end.
run reposition-query in this-procedure
  (input recid(gds-list-flt)
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
procedure cb_fill-lob-res-list :
define input  parameter p-full-path as character no-undo .
output to value (p-full-path).
for each gds-list-flt:
  export gds-list-flt.prod-type
        gds-list-flt.prod-code
        gds-list-flt.artic
        gds-list-flt.qnty
        .
end.
output close.
end procedure.
procedure cb_fill-lob-res-list-macro :
define input  parameter p-full-path as character no-undo .
define buffer buf_gds-list-flt-hist for gds-list-flt-hist.
output to value (p-full-path).
for each buf_gds-list-flt-hist:
    export
    buf_gds-list-flt-hist.
end.
output close.
end procedure.
procedure cb_get-next-gds-by-gds-code :
define input parameter p-gds-code as integer no-undo .
define input parameter p-bh as handle no-undo .
define buffer buf_gds-list for gds-list-flt.
find first buf_gds-list no-lock where
          buf_gds-list.gds-code > p-gds-code no-error.
if available buf_gds-list then do:
  p-bh:buffer-create().
  p-bh:buffer-copy(buffer buf_gds-list:handle).
end.
else do:
end.
end procedure.
procedure m-gds-save-db-proc :
define variable v-rid-list as character no-undo .
run ref/clobbnds.w ( input parparentproc
                    ,input this-procedure:handle
                    ,input 'b-add'
                    ,input "uniq-key-rec"
                    ,input 'ИЗМЕНЕНИЕ':U
                    ,input 'list':U
                    ,input 'gds-list'
                    ,input -1
                    ,input-output v-rid-list) no-error.
end procedure.
procedure m-macros-save-db-proc :
define variable v-rid-list as character no-undo .
run ref/clobbnds.w ( input parparentproc
                    ,input this-procedure:handle
                    ,input 'b-add'
                    ,input "uniq-key-rec"
                    ,input 'ИЗМЕНЕНИЕ':U
                    ,input 'list-macro':U
                    ,input 'gds-list'
                    ,input -1
                    ,input-output v-rid-list) no-error.
end procedure.
procedure grplib-get-full-name-alc-type :
do
on error undo, return error
:
define input parameter p-node-code  as integer      no-undo.
define output parameter p-full-name as character    no-undo.
    define buffer buf_alc-type       for ub.alc-type.
    find first buf_alc-type no-lock
         where buf_alc-type.alc-type-inner-code = p-node-code
    no-error.
    if not available buf_alc-type
    then do:
        undo, return error "grplib-get-full-name-alc-type: Не найден вид алкогольной продукции с кодом " + string( p-node-code ).
    end.
    assign
    p-full-name = buf_alc-type.alc-type-name
    .
end.
end procedure.
