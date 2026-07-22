block-level on error undo, throw.
define input parameter p-obj-type like ub.c-pmp-hist.obj-type no-undo .
define input parameter p-obj-code like ub.c-pmp-hist.obj-code no-undo .
define input parameter p-pump-code like ub.c-pmp-hist.pl-code no-undo .
define input parameter p-chip-num like ub.c-pmp-hist.chip-num no-undo .
define input parameter p-corr-user-db-num like ub.c-pmp-hist.corr-user-db-num no-undo .
define input parameter p-subject like ub.c-pmp-hist.subject no-undo .
define input parameter p-action   like ub.c-pmp-hist.action no-undo .
define input parameter p-silent  as logical no-undo .
define output parameter p-description as character no-undo .
define variable  vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable  vss-author      as character no-undo init "$Author: expertek $":U .
define variable  vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable  vss-workfile    as character no-undo init "$Workfile: cpmphisv.p $":U .
define variable  vss-archive     as character no-undo init "$Archive: ref/cpmphisv.p $":U .
define variable  vss-description as character no-undo init "Заполнение временной таблицы для показа изменений по таблицам истории ТРК".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure pumpattr-name :
do
  on error undo, return error
  :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
    case p-code :
            when 'net-address':U then do:     assign     p-label = "Сетевой адрес КТРК"     p-type = 'C':U      p-format = "X(15)"     p-label = "Сетевой адрес КТРК"     p-user-can-edit  = false     p-output-display = false     p-other = ""      .   end.
            when 'protocol-id':U then do:     assign     p-label = "Идентификатор протокола КТРК"     p-type = 'I':U      p-format = "99999"     p-label = "Идентификатор протокола КТРК"     p-user-can-edit  = false     p-output-display = false     p-other = ""      .   end.
            when 'UART-channel-no':U then do:     assign     p-label = "№ канала UART"     p-type = 'I':U      p-format = "9"     p-label = "№ канала UART"     p-user-can-edit  = false     p-output-display = false     p-other = ""      .   end.
            when 'no-overr-cnt-use':U then do:     assign     p-label = "Признак исп-я необнуляемых счетчиков"     p-type = 'L':U      p-format = "yes/no"     p-label = "Признак исп-я необнуляемых счетчиков"     p-user-can-edit  = false     p-output-display = false     p-other = ""      .   end.
            when 'tech-refuell-calc-use':U then do:     assign     p-label = "Признак расчета аварийного пролива"     p-type = 'L':U      p-format = "yes/no"     p-label = "Признак расчета аварийного пролива"     p-user-can-edit  = false     p-output-display = false     p-other = ""      .   end.
            when 'velocity-id':U then do:     assign     p-label = "Идентификатор скорости"     p-type = 'I':U      p-format = "99999"     p-label = "Идентификатор скорости"     p-user-can-edit  = false     p-output-display = false     p-other = ""      .   end.
      otherwise do:
        undo, return error "неизвестный атрибут ТРК" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure pumpattr-tooltip :
do
  on error undo, return error
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    case p-code :
            when 'net-address':U then do:     assign     p-tooltip = "Сетевой адрес КТРК"     p-label = "Сетевой адрес КТРК" .   end.
            when 'protocol-id':U then do:     assign     p-tooltip = "Идентификатор протокола КТРК"     p-label = "Идентификатор протокола КТРК" .   end.
            when 'UART-channel-no':U then do:     assign     p-tooltip = "№ канала UART"     p-label = "№ канала UART" .   end.
            when 'no-overr-cnt-use':U then do:     assign     p-tooltip = "Признак исп-я необнуляемых счетчиков"     p-label = "Признак исп-я необнуляемых счетчиков" .   end.
            when 'tech-refuell-calc-use':U then do:     assign     p-tooltip = "Признак расчета аварийного пролива"     p-label = "Признак расчета аварийного пролива" .   end.
            when 'velocity-id':U then do:     assign     p-tooltip = "Идентификатор скорости"     p-label = "Идентификатор скорости" .   end.
      otherwise do:
        undo, return error "Неизвестный атрибут ТРК" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure pumpattr-value :
 do
  on error undo, return error
  :
    define input  parameter p-code     like ub.pump-attr.attr-code  no-undo .
    define input  parameter p-obj-type like ub.pump-attr.obj-type   no-undo .
    define input  parameter p-obj-code like ub.pump-attr.obj-code   no-undo .
    define input  parameter p-pump-code like ub.pump-attr.pump-code   no-undo .
    define output parameter p-value    like ub.pump-attr.attr-value no-undo .
    define output parameter p-type     as character no-undo .
    define buffer buf_pump-attr for ub.pump-attr .
    def var v-format         as character no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run pumpattr-name in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_pump-attr no-lock where
               buf_pump-attr.obj-type  = p-obj-type
           AND buf_pump-attr.obj-code  = p-obj-code
           AND buf_pump-attr.pump-code  = p-pump-code
           AND buf_pump-attr.attr-code = p-code
      no-error .
    if avail buf_pump-attr then do:
      assign
        p-value =  buf_pump-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = 'L':U then "no":U else ""
      .
    end.
  end.
end procedure.
procedure pumpattr-write :
  do
  on error undo, return error
  :
    define input parameter p-obj-type like ub.pump-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.pump-attr.obj-code   no-undo .
    define input parameter p-pump-code like ub.pump-attr.pump-code   no-undo .
    define input parameter p-code     like ub.pump-attr.attr-code  no-undo .
    define input parameter p-value    like ub.pump-attr.attr-value no-undo .
    define buffer buf_pump-attr for ub.pump-attr .
    define buffer lock_pump-attr for ub.pump-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run pumpattr-name in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_pump-attr exclusive-lock where
               buf_pump-attr.obj-type  = p-obj-type
           AND buf_pump-attr.obj-code  = p-obj-code
           AND buf_pump-attr.pump-code  = p-pump-code
           AND buf_pump-attr.attr-code = p-code no-error .
    if not available buf_pump-attr then do:
      create buf_pump-attr .
      assign
        buf_pump-attr.pump-code  = p-pump-code
        buf_pump-attr.obj-type  = p-obj-type
        buf_pump-attr.obj-code  = p-obj-code
        buf_pump-attr.attr-code = p-code
        buf_pump-attr.attr-value = p-value no-error
      .
    end.
    ELSE
    ASSIGN
    buf_pump-attr.attr-value = p-value no-error.
  end.
end procedure.
procedure pumpattr-exist :
  do
  on error undo, return error
  :
    define input parameter p-obj-type like ub.pump-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.pump-attr.obj-code   no-undo .
    define input parameter p-pump-code like ub.pump-attr.pump-code   no-undo .
    define input parameter p-code     like ub.pump-attr.attr-code  no-undo .
    define output parameter p-exist    as logical no-undo .
    define buffer buf_pump-attr for ub.pump-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run pumpattr-name in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_pump-attr no-lock where
               buf_pump-attr.obj-type  = p-obj-type
           AND buf_pump-attr.obj-code  = p-obj-code
           AND buf_pump-attr.pump-code  = p-pump-code
           AND buf_pump-attr.attr-code = p-code no-error .
    if available buf_pump-attr then do:
      P-EXIST = YES.
    end.
  end.
end procedure.
procedure pumpattr-delete :
  do
  on error undo, return error
  :
    define input parameter p-obj-type like ub.pump-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.pump-attr.obj-code   no-undo .
    define input parameter p-pump-code like ub.pump-attr.pump-code   no-undo .
    define input parameter p-code     like ub.pump-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo .
    define buffer buf_pump-attr for ub.pump-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run pumpattr-name in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_pump-attr exclusive-lock where
               buf_pump-attr.obj-type  = p-obj-type
           AND buf_pump-attr.obj-code  = p-obj-code
           AND buf_pump-attr.pump-code  = p-pump-code
           AND buf_pump-attr.attr-code = p-code no-error .
    if not available buf_pump-attr then do:
      P-DELETED = NO.
    end.
    ELSE DO:
       delete buf_pump-attr.
       P-DELETED = YES.
    END.
  end.
end procedure.
define variable v-chg-fields as character no-undo.
define variable v-old-fields as character no-undo.
define variable v-new-fields as character no-undo.
define variable ii as integer no-undo.
define variable v-mess as character no-undo .
define buffer buf_c-pmp-hist for ub.c-pmp-hist.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define SHARED temp-table temp-changes no-undo
field f_name as character
field l_name as character
field v_old as character
field v_new as character
field t_name as character
field num_ as integer
field uniq-key-rec as character
field action as integer
field fNotChange as logical
index pi is unique primary
num_
t_name
f_name
index
Chan
fnotChange
t_name
f_name
index imain uniq-key-rec
.
FUNCTION get-all-fields returns character (p-file-name as character ):
define variable v-dop as character no-undo .
  find first _file no-lock where _file._file-name = p-file-name no-error .
  if not available _file then return "":U.
  for each _field no-lock where
           _field._file-recid = recid(_file) :
    assign
    v-dop = v-dop + _field._field-name + chr(44)
    .
  end.
  return trim(v-dop).
END FUNCTION.
PROCEDURE proc-full-temp-changes :
  define input  parameter p-act-create as logical   no-undo .
  define input  parameter p-act-delete as logical   no-undo .
  define input  parameter p-hst-handle as handle    no-undo .
  define input  parameter p-main-table as character no-undo .
  define input  parameter p-field-list as character no-undo .
  define input  parameter p-label-form as character no-undo .
  define variable h-new-buf         as handle    no-undo .
  define variable h-main-buf        as handle    no-undo .
  define variable h-for-comp        as handle    no-undo .
  define variable v-inform          as character no-undo .
  define variable v-ind             as integer   no-undo .
  define variable v-idx-field-qnty  as integer   no-undo .
  define variable v-num-entries     as integer   no-undo .
  define variable fh                as handle    no-undo .
  define variable fh-main           as handle    no-undo .
  define variable fh-old            as handle    no-undo .
  define variable fh-new            as handle    no-undo .
  define variable v-field-name      as character no-undo .
  define variable v-field-lvl       as character no-undo .
  define variable v-field-form      as character no-undo .
  define variable v-search-exp      as character no-undo .
  define variable v-srch-main       as character no-undo .
  define variable v-word-link       as character no-undo .
  define variable v-av-chip-num     as logical   no-undo .
  define variable v-main-pi-fld-lst as character no-undo .
  define variable v-main-fld-lst    as character no-undo .
  define variable v-delim-list      as character no-undo .
  define variable v-label           as character no-undo .
  define variable v-old-value       as character no-undo case-sensitive.
  define variable v-new-value       as character no-undo case-sensitive.
  define variable v-chg-fields as character no-undo.
  for each temp-changes:
    delete temp-changes.
  end.
  if not p-hst-handle:available then do:
    return .
  end.
  create buffer h-new-buf  for table p-hst-handle .
  create buffer h-main-buf for table p-main-table .
  assign
    v-inform = h-main-buf:index-information(1)
    v-ind    = 2
  .
  do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
  on error undo, return error
  :
    assign
      v-inform = h-main-buf:index-information( v-ind )
      v-ind    = v-ind + 1
    .
  end.
  if v-inform = ?
    or LC( entry( 1, v-inform, ",":U ) ) = "default":U
    or entry( 3, v-inform, ",":U ) <> "1":U
  then do:
    return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-workfile, h-main-buf:name ).
  end.
  assign
    v-idx-field-qnty = num-entries( v-inform ) - 4
  .
  if v-idx-field-qnty < 2 then do:
    return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-workfile, v-inform, h-main-buf:name ).
  end.
  assign
    v-srch-main   = "where":U
    v-word-link   = "":U
    v-av-chip-num = false
    v-delim-list  = "":U
  .
  do v-ind = 1 to v-idx-field-qnty by 2
  on error undo, return error
  :
    assign
      v-field-name      = entry( 4 + v-ind, v-inform, ",":U )
      fh                = p-hst-handle:buffer-field( v-field-name )
      fh-main           = h-main-buf:buffer-field( v-field-name )
      v-srch-main       = substitute( "&1 &2 &3.&4 =", v-srch-main, v-word-link, fh-main:table, v-field-name )
      v-main-pi-fld-lst = v-main-pi-fld-lst + v-delim-list + v-field-name
    .
    if fh:data-type ="character":U then do:
      assign
        v-srch-main = substitute( '&1 "&2"', v-srch-main, replace( replace( fh:buffer-value(), '"':U, '""':U ), '~~':U, '~~~~':U ) )
      .
    end.
    else do:
      assign
        v-srch-main = substitute( "&1 &2", v-srch-main, fh:buffer-value() )
      .
    end.
    if v-delim-list = "":U then do:
      assign
        v-delim-list = ",":U
      .
    end.
    if v-word-link = "":U then do:
      assign
        v-word-link = "and":U
      .
    end.
  end.
  assign
    v-delim-list  = "":U
  .
  do v-ind = 1 to h-main-buf:num-fields
  on error undo, return error
  :
    assign
      fh-main      = h-main-buf:buffer-field( v-ind )
      v-field-name = fh-main:name
    .
      assign
        v-main-fld-lst = v-main-fld-lst + v-delim-list + v-field-name
      .
      if v-delim-list = "":U then do:
        assign
          v-delim-list = ",":U
        .
      end.
  end.
  assign
    v-inform = p-hst-handle:index-information(1)
    v-ind    = 2
  .
  do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
  on error undo, return error
  :
    assign
      v-inform = p-hst-handle:index-information( v-ind )
      v-ind    = v-ind + 1
    .
  end.
  if v-inform = ?
    or LC( entry( 1, v-inform, ",":U ) ) = "default":U
    or entry( 3, v-inform, ",":U ) <> "1":U
  then do:
    return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-workfile, p-hst-handle:name ).
  end.
  assign
    v-idx-field-qnty = num-entries( v-inform ) - 4
  .
  if v-idx-field-qnty < 2 then do:
    return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-workfile, v-inform, p-hst-handle:name ).
  end.
  assign
    v-search-exp  = "where":U
    v-word-link   = "":U
    v-av-chip-num = false
  .
  do v-ind = 1 to v-idx-field-qnty by 2
  on error undo, return error
  :
    assign
      v-field-name = entry( 4 + v-ind, v-inform, ",":U )
      fh           = p-hst-handle:buffer-field( v-field-name )
      v-search-exp = substitute( "&1 &2 &3.&4", v-search-exp, v-word-link, fh:table, v-field-name )
    .
    if v-field-name = "chip-num":U then do:
      assign
        v-search-exp  = substitute( "&1 >", v-search-exp )
        v-av-chip-num = true
      .
    end.
    else do:
      assign
        v-search-exp = substitute( "&1 =", v-search-exp )
      .
    end.
    if fh:data-type ="character":U then do:
      assign
        v-search-exp = substitute( '&1 "&2"', v-search-exp, replace( replace( fh:buffer-value(), '"':U, '""':U ), '~~':U, '~~~~':U ) )
      .
    end.
    else do:
      assign
        v-search-exp = substitute( '&1 &2', v-search-exp, fh:buffer-value() )
      .
    end.
    if v-word-link = "":U then do:
      assign
        v-word-link = "and":U
      .
    end.
  end.
  if v-av-chip-num = false then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Таблица &2 не содержит поля chip-num.", vss-workfile, p-hst-handle:name ) skip
      "Использование данной процедуры невозможно!" skip
      view-as alert-box error .
    return error .
  end.
  h-new-buf:find-first( v-search-exp, no-lock ) no-error .
  if not h-new-buf:available then do:
    h-main-buf:find-first( v-srch-main, no-lock ) no-error .
    if not h-main-buf:available then do:
      assign
        h-for-comp = ?
      .
    end.
    else do:
      assign
        h-for-comp = h-main-buf
      .
    end.
  end.
  else do:
    assign
      h-for-comp = h-new-buf
    .
  end.
  assign
    v-num-entries = num-entries( v-main-fld-lst, ",":U )
  .
  do v-ind = 1 to v-num-entries
  on error undo, return error return-value
  :
    assign
      v-field-name = entry( v-ind, v-main-fld-lst )
      fh-old       = p-hst-handle:buffer-field( v-field-name )
      v-old-value  = fh-old:buffer-value()
      v-label      = trim( fh-old:label )
    .
    if ( trim( p-field-list ) <> "":U
         and lookup( v-field-name, p-field-list ) > 0
       )
       or trim( p-field-list ) = "":U
    then do:
      if h-for-comp <> ? then do:
        assign
          fh-new      = h-for-comp:buffer-field( v-field-name )
          v-new-value = fh-new:buffer-value()
        .
      end.
      else do:
        assign
          v-new-value = "":U
        .
      end.
        if p-act-create = true then do:
          assign
            v-old-value = "":U
          .
        end.
        if p-act-delete = true then do:
          assign
            v-new-value = "":U
          .
        end.
      if v-old-value <> v-new-value
      then do:
        create temp-changes.
        assign
          temp-changes.t_name = p-main-table
          temp-changes.f_name = v-field-name
          temp-changes.l_name = replace( v-label, "&":U, "":U )
          temp-changes.v_old  = trim( v-old-value )
          temp-changes.v_new  = trim( v-new-value )
          temp-changes.num_   = 0
          temp-changes.fNotChange = v-old-value eq v-new-value
        .
      end.
    end.
  end.
  assign
    v-num-entries = num-entries( p-label-form, chr(8) )
  .
  do v-ind = 1 to v-num-entries
  on error undo, return error return-value
  :
    if num-entries( entry( v-ind, p-label-form, chr(8) ), chr(4) ) = 3 then do:
      assign
        v-field-name = entry( 1, entry( v-ind, p-label-form, chr(8) ), chr(4) )
        v-field-lvl  = entry( 2, entry( v-ind, p-label-form, chr(8) ), chr(4) )
        v-field-form = entry( 3, entry( v-ind, p-label-form, chr(8) ), chr(4) )
      .
      find first temp-changes
        where temp-changes.f_name = v-field-name
        no-error .
      if available temp-changes then do:
        if trim( v-field-lvl ) <> "":U then do:
          assign
            temp-changes.l_name = v-field-lvl
          .
        end.
        if trim( v-field-form ) <> "":U then do:
          assign
            temp-changes.v_old = dynamic-function( v-field-form, temp-changes.v_old )
          .
          if h-for-comp <> ? then do:
            assign
              temp-changes.v_new = dynamic-function( v-field-form, temp-changes.v_new )
            .
          end.
        end.
      end.
    end.
    else do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка! Список должен содержать три поля с разделителем delim-par!" skip
        substitute( "список для поля '&1': '&2'"
                    ,entry( 1, entry( v-ind, p-label-form, chr(8) ), chr(4) )
                    ,entry( v-ind, p-label-form, chr(8) )
                  ) skip
        substitute( "полный список: &2", p-label-form ) skip
        view-as alert-box error .
    end.
  end.
  delete object h-new-buf .
  delete object h-main-buf .
END PROCEDURE.
find first buf_c-pmp-hist no-lock where
          buf_c-pmp-hist.obj-type = p-obj-type
      AND buf_c-pmp-hist.obj-code = p-obj-code
      AND buf_c-pmp-hist.pump-code = p-pump-code
      AND buf_c-pmp-hist.chip-num = p-chip-num
      AND buf_c-pmp-hist.corr-user-db-num = p-corr-user-db-num
      AND buf_c-pmp-hist.subject  = p-subject no-error .
if not available buf_c-pmp-hist then do:
  return error .
end.
CASE p-subject:
  when 'pump':U then do:
    run pump-proc in this-procedure(output p-description) no-error  .
  end.
  when 'pump-nozzle':U then do:
    run pump-nozzle-proc in this-procedure(output p-description) no-error  .
  end.
  when 'pl-gds-pump':U then do:
    run pl-gds-pump-proc in this-procedure(output p-description) no-error  .
  end.
  when 'pl-pump':U then do:
    run pl-pump-proc in this-procedure(output p-description) no-error  .
  end.
  when 'pl-pump-nozzle':U then do:
    run pl-pump-nozzle-proc in this-procedure(output p-description) no-error  .
  end.
  when 'pump-attr':U then do:
    run pump-attr-proc in this-procedure(output p-description) no-error  .
  end.
END CASE.
if error-status:error then do:
  return error .
end.
procedure pump-proc :
define output parameter p-description as character no-undo .
define buffer curr_c-pump for ub.c-pump  .
  do
  on error undo, return error
  :
    find first curr_c-pump no-lock where
               curr_c-pump.obj-type = p-obj-type
           AND curr_c-pump.obj-code = p-obj-code
           AND curr_c-pump.pump-code = buf_c-pmp-hist.pump-code
           AND curr_c-pump.chip-num = p-chip-num
           AND curr_c-pump.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail curr_c-pump then do:
      v-mess = "Неверная ссылка на c-pump в таблице c-pmp-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
define variable v-label-param as character no-undo .
v-label-param =
  "pump-code" + chr(4) + "№ ТРК" + chr(4) + "" + chr(8)
 + "obj-code" + chr(4) + "Код объекта" + chr(4) + "" + chr(8)
 + "obj-type" + chr(4) + "Тип объекта" + chr(4) + "" + chr(8)
 + "PS" + chr(4) + "Описание" + chr(4) + "" + chr(8)
 + "status_" + chr(4) + "Статус" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-pmp-hist.action = integer('1':U))
                                            ,input  (buf_c-pmp-hist.action = integer('99':U))
                                            ,input  buffer curr_c-pump:handle
                                            ,input  'pump':U
                                            ,input  "pump-code,obj-code,obj-type,PS,status_"
                                            ,input  v-label-param).
end.
end procedure.
procedure pump-nozzle-proc :
define output parameter p-description as character no-undo .
define buffer curr_c-pump-nozzle for ub.c-pump-nozzle  .
  do
  on error undo, return error
  :
    find first curr_c-pump-nozzle no-lock where
               curr_c-pump-nozzle.pump-code = buf_c-pmp-hist.pump-code
           AND curr_c-pump-nozzle.obj-type = p-obj-type
           AND curr_c-pump-nozzle.obj-code = p-obj-code
           AND curr_c-pump-nozzle.nozzle-code = buf_c-pmp-hist.nozzle-code
           AND curr_c-pump-nozzle.chip-num = p-chip-num
           AND curr_c-pump-nozzle.corr-user-db-num = p-corr-user-db-num  no-error .
    if not avail curr_c-pump-nozzle then do:
      v-mess = "Неверная ссылка на c-pump-nozzle в таблице c-pmp-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
define variable v-label-param as character no-undo .
v-label-param =
  "nozzle-code" + chr(4) + "№ пистолета" + chr(4) + "" + chr(8)
 + "pump-code" + chr(4) + "№ ТРК" + chr(4) + "" + chr(8)
 + "is-meas" + chr(4) + "Измеряется приборами" + chr(4) + "" + chr(8)
 + "obj-code" + chr(4) + "Код объекта" + chr(4) + "" + chr(8)
 + "obj-type" + chr(4) + "Тип объекта" + chr(4) + "" + chr(8)
 + "PS" + chr(4) + "Примечание" + chr(4) + "" + chr(8)
 + "status_" + chr(4) + "Статус" + chr(4) + ""  + chr(8)
 + "ef-nid" + chr(4) + "Идентификатор EasyFuel" + chr(4) + ""
   .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-pmp-hist.action = integer('1':U))
                                            ,input  (buf_c-pmp-hist.action = integer('99':U))
                                            ,input  buffer curr_c-pump-nozzle:handle
                                            ,input  'pump-nozzle':U
                                            ,input  "nozzle-code,pump-code,is-meas,obj-code,obj-type,PS,status_"
                                            ,input  v-label-param).
end.
end procedure.
procedure pl-gds-pump-proc :
define output parameter p-description as character no-undo .
define buffer buf_c-table-bind for ub.c-table-bind.
define buffer curr_c-pl-gds-pump for ub.c-pl-gds-pump  .
  do
  on error undo, return error
  :
    find first buf_c-table-bind no-lock where
              buf_c-table-bind.corr-user-db-num = buf_c-pmp-hist.corr-user-db-num
          AND buf_c-table-bind.tbl-name-rec     = 'c-pmp-hist':U
          AND buf_c-table-bind.chip-num-rec     = buf_c-pmp-hist.chip-num no-error .
    if not available buf_c-table-bind then do:
      v-mess = "Неверная ссылка на c-table-bind в таблице c-pmp-hist".
      run err-mess in this-procedure ( input-output v-mess ).
      return error v-mess .
    end.
    find first curr_c-pl-gds-pump no-lock where
               curr_c-pl-gds-pump.obj-type = buf_c-pmp-hist.obj-type
           AND curr_c-pl-gds-pump.obj-code = buf_c-pmp-hist.obj-code
           AND curr_c-pl-gds-pump.pump-code = buf_c-pmp-hist.pump-code
           AND curr_c-pl-gds-pump.chip-num = buf_c-table-bind.chip-num-src
           AND curr_c-pl-gds-pump.corr-user-db-num = buf_c-table-bind.corr-user-db-num no-error .
    if not avail curr_c-pl-gds-pump then do:
      v-mess = "Неверная ссылка на c-pl-gds-pump в таблице c-table-bind".
      run err-mess in this-procedure ( input-output v-mess ).
      return error v-mess .
    end.
define variable v-label-param as character no-undo .
v-label-param =
  "gds-code" + chr(4) + "Код товара" + chr(4) + "" + chr(8)
 + "pl-code" + chr(4) + "Код складского места" + chr(4) + "" + chr(8)
 + "pump-code" + chr(4) + "№ ТРК" + chr(4) + "" + chr(8)
 + "obj-code" + chr(4) + "Код объекта" + chr(4) + "" + chr(8)
 + "obj-type" + chr(4) + "Тип объекта" + chr(4) + "" + chr(8)
 + "PS" + chr(4) + "Примечание" + chr(4) + "" + chr(8)
 + "status_" + chr(4) + "Статус" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-pmp-hist.action = integer('1':U))
                                            ,input  (buf_c-pmp-hist.action = integer('99':U))
                                            ,input  buffer curr_c-pl-gds-pump:handle
                                            ,input  'pl-gds-pump':U
                                            ,input  "gds-code,pl-code,pump-code,obj-code,obj-type,PS,status_"
                                            ,input  v-label-param).
end.
end procedure.
procedure pl-pump-nozzle-proc :
define output parameter p-description as character no-undo .
define buffer buf_c-table-bind for ub.c-table-bind.
define buffer curr_c-pl-pump-nozzle for ub.c-pl-pump-nozzle  .
  do
  on error undo, return error
  :
    find first buf_c-table-bind no-lock where
              buf_c-table-bind.corr-user-db-num = buf_c-pmp-hist.corr-user-db-num
          AND buf_c-table-bind.tbl-name-rec     = 'c-pmp-hist':U
          AND buf_c-table-bind.chip-num-rec     = buf_c-pmp-hist.chip-num no-error .
    if not available buf_c-table-bind then do:
      v-mess = "Неверная ссылка на c-table-bind в таблице c-pmp-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
    find first curr_c-pl-pump-nozzle no-lock where
               curr_c-pl-pump-nozzle.obj-type = buf_c-pmp-hist.obj-type
           AND curr_c-pl-pump-nozzle.obj-code = buf_c-pmp-hist.obj-code
           AND curr_c-pl-pump-nozzle.pump-code = buf_c-pmp-hist.pump-code
           AND curr_c-pl-pump-nozzle.chip-num = buf_c-table-bind.chip-num-src
           AND curr_c-pl-pump-nozzle.corr-user-db-num = buf_c-table-bind.corr-user-db-num   no-error .
    if not avail curr_c-pl-pump-nozzle then do:
      v-mess = "Неверная ссылка на c-pl-pump-nozzle в таблице c-table-bind".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
define variable v-label-param as character no-undo .
v-label-param =
  "nozzle-code" + chr(4) + "№ пистолета" + chr(4) + "" + chr(8)
 + "pl-code" + chr(4) + "Код складского места" + chr(4) + "" + chr(8)
 + "pump-code" + chr(4) + "№ ТРК" + chr(4) + "" + chr(8)
 + "obj-code" + chr(4) + "Код объекта" + chr(4) + "" + chr(8)
 + "obj-type" + chr(4) + "Тип объекта" + chr(4) + "" + chr(8)
 + "PS" + chr(4) + "Примечание" + chr(4) + "" + chr(8)
 + "status_" + chr(4) + "Статус" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-pmp-hist.action = integer('1':U))
                                            ,input  (buf_c-pmp-hist.action = integer('99':U))
                                            ,input  buffer curr_c-pl-pump-nozzle:handle
                                            ,input  'pl-pump-nozzle':U
                                            ,input  "nozzle-code,pl-code,pump-code,obj-code,obj-type,PS,status_"
                                            ,input  v-label-param).
end.
end procedure.
procedure pl-pump-proc :
define output parameter p-description as character no-undo .
define buffer buf_c-table-bind for ub.c-table-bind.
define buffer curr_c-pl-pump for ub.c-pl-pump  .
  do
  on error undo, return error
  :
    find first buf_c-table-bind no-lock where
              buf_c-table-bind.corr-user-db-num = buf_c-pmp-hist.corr-user-db-num
          AND buf_c-table-bind.tbl-name-rec     = 'c-pmp-hist':U
          AND buf_c-table-bind.chip-num-rec     = buf_c-pmp-hist.chip-num no-error .
    if not available buf_c-table-bind then do:
      v-mess = "Неверная ссылка на c-table-bind в таблице c-pmp-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
    find first curr_c-pl-pump no-lock where
               curr_c-pl-pump.obj-type = buf_c-pmp-hist.obj-type
           AND curr_c-pl-pump.obj-code = buf_c-pmp-hist.obj-code
           AND curr_c-pl-pump.pump-code = buf_c-pmp-hist.pump-code
           AND curr_c-pl-pump.chip-num = buf_c-table-bind.chip-num-src
           AND curr_c-pl-pump.corr-user-db-num = buf_c-table-bind.corr-user-db-num   no-error .
    if not avail curr_c-pl-pump then do:
      v-mess = "Неверная ссылка на c-pl-pump в таблице c-table-bind".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
define variable v-label-param as character no-undo .
v-label-param =
  "pl-code" + chr(4) + "Код складского места" + chr(4) + "" + chr(8)
 + "pump-code" + chr(4) + "№ ТРК" + chr(4) + "" + chr(8)
 + "obj-code" + chr(4) + "Код объекта" + chr(4) + "" + chr(8)
 + "obj-type" + chr(4) + "Тип объекта" + chr(4) + "" + chr(8)
 + "PS" + chr(4) + "Примечание" + chr(4) + "" + chr(8)
 + "status_" + chr(4) + "Статус" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-pmp-hist.action = integer('1':U))
                                            ,input  (buf_c-pmp-hist.action = integer('99':U))
                                            ,input  buffer curr_c-pl-pump:handle
                                            ,input  'pl-pump':U
                                            ,input  "pl-code,pump-code,obj-code,obj-type,PS,status_"
                                            ,input  v-label-param).
end.
end procedure.
procedure pump-attr-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define buffer current_c-pump-attr for ub.c-pump-attr  .
  do
  on error undo, return error
  :
    find first current_c-pump-attr no-lock where
               current_c-pump-attr.chip-num = p-chip-num
           AND current_c-pump-attr.corr-user-db-num = p-corr-user-db-num
           AND current_c-pump-attr.obj-type = p-obj-type
           AND current_c-pump-attr.obj-code = p-obj-code
           AND current_c-pump-attr.pump-code = p-pump-code  no-error .
    if not avail current_c-pump-attr then do:
      v-mess = "Неверная ссылка на c-pump-attr в таблице c-pmp-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
    run pumpattr-tooltip in this-procedure (
                input  current_c-pump-attr.attr-code
                ,output v-tooltip
                ,output v-label
                ) no-error .
    assign
    p-description = "Атрибут" + chr(32) + v-label
    .
define variable v-label-param as character no-undo .
v-label-param =
  "attr-value" + chr(4) + "Значение атрибута" + chr(4) + "" + chr(8)
 + "pump-code" + chr(4) + "№ ТРК" + chr(4) + "" + chr(8)
 + "obj-code" + chr(4) + "Код объекта" + chr(4) + "" + chr(8)
 + "obj-type" + chr(4) + "Тип объекта" + chr(4) + "" + chr(8)
 + "PS" + chr(4) + "Примечание" + chr(4) + "" + chr(8)
 + "status_" + chr(4) + "Статус" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-pmp-hist.action = integer('1':U))
                                            ,input  (buf_c-pmp-hist.action = integer('99':U))
                                            ,input  buffer current_c-pump-attr:handle
                                            ,input  'pump-attr':U
                                            ,input  "attr-value,pump-code,obj-code,obj-type,PS,status_"
                                            ,input  v-label-param).
end.
end procedure.
PROCEDURE err-mess:
  DEFINE INPUT-output PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      p-mess =
      substitute("История ТРК &1 на &2&3: щепка &4 БД:&5  Предмет изменений &6&7&8"
                  ,p-pump-code
                  , p-obj-type
                  , p-obj-code
                  , p-chip-num
                  , p-corr-user-db-num
                  , p-subject
                  , chr(10)
                  , p-mess
                  ).
    end.
    otherwise do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.
