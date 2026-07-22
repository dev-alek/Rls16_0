block-level on error undo, throw.
define input parameter p-tax-code  like ub.c-tax-hist.tax-code no-undo .
define input parameter p-rate-code like ub.c-tax-hist.rate-code no-undo .
define input parameter p-corr-user-db-num  like ub.c-tax-hist.corr-user-db-num no-undo .
define input parameter p-chip-num  like ub.c-tax-hist.chip-num no-undo .
define input parameter p-host-code like ub.c-tax-hist.host-code no-undo .
define input parameter p-obj-type like ub.c-tax-hist.obj-type no-undo .
define input parameter p-obj-code like ub.c-tax-hist.obj-code no-undo .
define input parameter p-subject like ub.c-tax-hist.subject no-undo .
define input parameter p-action   like ub.c-tax-hist.action no-undo .
define input parameter p-silent  as logical no-undo .
define output parameter p-description as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ctaxhisv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/ctaxhisv.p $":U .
define variable vss-description as character no-undo init "Заполнение временной таблицы для показа изменений по таблицам истории налогов".
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
define variable v-chg-fields as character no-undo.
define variable v-old-fields as character no-undo.
define variable v-new-fields as character no-undo.
define variable ii as integer no-undo.
define variable v-mess as character no-undo .
define buffer buf_c-tax-hist for ub.c-tax-hist.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
if p-action = integer('99':U) then return.
find first buf_c-tax-hist no-lock where
          buf_c-tax-hist.tax-code = p-tax-code
      AND buf_c-tax-hist.rate-code = p-rate-code
      AND buf_c-tax-hist.chip-num = p-chip-num
      AND buf_c-tax-hist.corr-user-db-num = p-corr-user-db-num
      AND buf_c-tax-hist.host-code = p-host-code
      AND buf_c-tax-hist.obj-type = p-obj-type
      AND buf_c-tax-hist.obj-code = p-obj-code
      AND buf_c-tax-hist.subject  = p-subject no-error .
if not available buf_c-tax-hist then do:
  return error .
end.
CASE p-subject:
  when 'tax':U then do:
    run tax-proc in this-procedure(output p-description) no-error .
  end.
  when 'tax-rate':U then do:
    run tax-rate-proc in this-procedure(output p-description) no-error .
  end.
  when 'tax-rate-value':U then do:
    run tax-rate-value-proc in this-procedure(output p-description) no-error .
  end.
  when 'tax-units':U then do:
    run tax-units-proc in this-procedure(output p-description) no-error .
  end.
END CASE.
if error-status:error then do:
  return error .
end.
procedure tax-proc :
define output parameter p-description as character no-undo .
define buffer current_c-tax for ub.c-tax  .
  do
  on error undo, return error
  :
    find first current_c-tax no-lock where
               current_c-tax.tax-code = p-tax-code
           AND current_c-tax.chip-num = p-chip-num
           AND current_c-tax.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail current_c-tax then do:
       v-mess = "Неверная ссылка на c-tax в таблице c-tax-hist".
       run err-mess in this-procedure ( input-output v-mess ).
       return error (if p-silent then v-mess else '':U).
    end.
define variable v-label-param as character no-undo .
v-label-param =
  "individual" + chr(4) + "Индивидуальный" + chr(4) + "" + chr(8)
 + "status_" + chr(4) + "Статус" + chr(4) + "" + chr(8)
 + "tax-code" + chr(4) + "Код" + chr(4) + "" + chr(8)
 + "tax-name" + chr(4) + "Название" + chr(4) + "" + chr(8)
 + "tax-type" + chr(4) + "Тип" + chr(4) + "" + chr(8)
 + "to-cashdesk" + chr(4) + "Посылать ли на кассу" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-tax-hist.action = integer('1':U))
                                            ,input  (buf_c-tax-hist.action = integer('99':U))
                                            ,input  buffer current_c-tax:handle
                                            ,input  'tax':U
                                            ,input  "individual,status_,tax-code,tax-name,tax-type,to-cashdesk"
                                            ,input  v-label-param).
end.
end procedure.
procedure tax-rate-value-proc :
define output parameter p-description as character no-undo .
define variable v-first as logical no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define variable v-is-created as logical no-undo .
define variable v-old-rate-value like ub.tax-rate-value.rate-value no-undo .
define variable v-new-rate-value like ub.tax-rate-value.rate-value no-undo .
define variable v-field-name as character no-undo .
define variable v-field-function as character no-undo .
define variable jj as integer no-undo .
define variable v-field-label  as character no-undo .
define variable v-field-list as character no-undo .
define buffer curr_c-tax-rate-value for ub.tax-rate-value  .
define buffer prev_c-tax-rate-value for ub.tax-rate-value.
define buffer buf_tax for ub.tax.
  do
  on error undo, return error
  :
    find first buf_tax no-lock where buf_tax.tax-code = p-tax-code .
    assign
    p-description = substitute("&1, ставка &2", buf_tax.tax-name, p-rate-code)
    .
    find first curr_c-tax-rate-value no-lock where
              curr_c-tax-rate-value.tax-code =  p-tax-code
           AND curr_c-tax-rate-value.rate-code = p-rate-code
           AND curr_c-tax-rate-value.host-code = p-host-code
           AND curr_c-tax-rate-value.obj-type = p-obj-type
           AND curr_c-tax-rate-value.obj-code  = p-obj-code
           AND curr_c-tax-rate-value.chip-num = p-chip-num
           AND curr_c-tax-rate-value.corr-user-db-num = p-corr-user-db-num
           no-error .
    if available curr_c-tax-rate-value then do:
      find last prev_c-tax-rate-value no-lock where
                  prev_c-tax-rate-value.tax-code = p-rate-code
              AND prev_c-tax-rate-value.rate-code = p-rate-code
              AND prev_c-tax-rate-value.host-code = p-host-code
              AND prev_c-tax-rate-value.obj-type = p-obj-type
              AND prev_c-tax-rate-value.obj-code  = p-obj-code
              AND prev_c-tax-rate-value.fact-order < curr_c-tax-rate-value.fact-order
              no-error.
      if not avail prev_c-tax-rate-value then do:
        assign
        v-first = yes
        .
      end.
    end.
    if available curr_c-tax-rate-value
    and available prev_c-tax-rate-value then do:
      buffer-compare curr_c-tax-rate-value except chip-num corr-date corr-time corr-user-name corr-user-db-num corr-time
      to prev_c-tax-rate-value
      save result in v-chg-fields.
    end.
    else do:
      assign
      v-chg-fields =  "rate-value,fact-date" .
    end.
_ii:
  do ii = 1 to num-entries(v-chg-fields):
    assign
    v-field-name = entry(ii, v-chg-fields)
    jj = lookup(v-field-name, "rate-value,fact-date,status_").
    if jj = 0 then next _ii.
    assign
    v-field-label = entry(jj, "Значение,Дата включения,Статус")
    v-field-function = entry(jj, ",,")
    .
    create temp-changes.
    assign
    temp-changes.f_name = v-field-name
    temp-changes.l_name = v-field-label
    temp-changes.v_old =  (if (v-first or temp-changes.f_name  <> "rate-value")
                           then '':U
                          else  (if temp-changes.f_name = "rate-value":U
                                 then string(v-old-rate-value)
                                 else  string(buffer prev_c-tax-rate-value:buffer-field(v-field-name):buffer-value)
                                 )
                          )
    temp-changes.v_new =  if available curr_c-tax-rate-value
                          then string(buffer curr_c-tax-rate-value:buffer-field(v-field-name):buffer-value)
                          else chr(63)
    .
    if v-field-function <> '':U then do:
      assign
      temp-changes.v_old = DYNAMIC-function(v-field-function, temp-changes.v_old)
      temp-changes.v_new = DYNAMIC-function(v-field-function, temp-changes.v_new)
      .
    end.
  end.
end.
end procedure.
procedure tax-rate-proc :
define output parameter p-description as character no-undo .
define buffer current_c-tax-rate for ub.c-tax-rate  .
define buffer buf_tax for ub.tax.
  do
  on error undo, return error
  :
    find first buf_tax no-lock where buf_tax.tax-code = p-tax-code .
    assign
    p-description = substitute("&1, ставка &2", buf_tax.tax-name, p-rate-code)
    .
    find first current_c-tax-rate no-lock where
               current_c-tax-rate.tax-code = p-tax-code
           AND current_c-tax-rate.rate-code = p-rate-code
           AND current_c-tax-rate.chip-num = p-chip-num
           AND current_c-tax-rate.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail current_c-tax-rate then do:
       v-mess = "Неверная ссылка на c-tax-rate в таблице c-tax-hist".
       run err-mess in this-procedure ( input-output v-mess ).
       return error (if p-silent then v-mess else '':U).
    end.
define variable v-label-param as character no-undo .
v-label-param =
  "rate-code" + chr(4) + "Код ставки" + chr(4) + "" + chr(8)
 + "rate-name" + chr(4) + "Название" + chr(4) + "" + chr(8)
 + "status_" + chr(4) + "Статус" + chr(4) + "" + chr(8)
 + "tax-code" + chr(4) + "Код налога" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-tax-hist.action = integer('1':U))
                                            ,input  (buf_c-tax-hist.action = integer('99':U))
                                            ,input  buffer current_c-tax-rate:handle
                                            ,input  'tax-rate':U
                                            ,input  "rate-code,rate-name,status_,tax-code"
                                            ,input  v-label-param).
end.
end procedure.
procedure tax-units-proc :
define output parameter p-description as character no-undo .
define buffer current_c-tax-units for ub.c-tax-units  .
  do
  on error undo, return error
  :
    find first current_c-tax-units no-lock where
               current_c-tax-units.tax-code = p-tax-code
           AND current_c-tax-units.TYPE = buf_c-tax-hist.type
           AND current_c-tax-units.chip-num = p-chip-num
           AND current_c-tax-units.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail current_c-tax-units then do:
       v-mess = "Неверная ссылка на c-tax-units в таблице c-tax-hist".
       run err-mess in this-procedure ( input-output v-mess).
       return error (if p-silent then v-mess else '':U).
    end.
define variable v-label-param as character no-undo .
v-label-param =
  "type" + chr(4) + "Тип" + chr(4) + "" + chr(8)
 + "tax-code" + chr(4) + "Код налога" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-tax-hist.action = integer('1':U))
                                            ,input  (buf_c-tax-hist.action = integer('99':U))
                                            ,input  buffer current_c-tax-units:handle
                                            ,input  'tax-units':U
                                            ,input  "type,tax-code"
                                            ,input  v-label-param).
end.
end procedure.
PROCEDURE err-mess:
  DEFINE INPUT-output PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess =
      substitute("История налога &1 ставка &2: щепка &3 БД:&4 фирма: &5 объект &6&7 Предмет изменений &8",
                 p-tax-code, p-rate-code,  p-chip-num, p-corr-user-db-num, p-host-code, p-obj-type, p-obj-code, p-subject) +
                 chr(10) + p-mess.
    end.
    otherwise do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.
