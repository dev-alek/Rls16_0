/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Временная таблица для показа истории по разным таблицам
Заполнение этой временной таблицы в динамике для "плоских" исторических таблиц

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/26/03
Author: Bakhtadze Natalya
Creation date: 11/26/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{2}" = "" &then
&scop tt_name temp-changes
&else
&scop tt_name {2}
&endif


define {1} temp-table {&tt_name} no-undo
field f_name as character
field l_name as character
field v_old as character
field v_new as character
field t_name as character
field num_ as integer
field uniq-key-rec as character
field action as integer
field fNotChange as logical 
&if "{3}" = "update" &then
field f_update as logical
field f_can_update as logical
field f_parent as character
field f_visible as logical
field f_root as character
index iu f_update
index ivisible  f_visible
index iparent f_root f_parent
&endif
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

&if defined(tmpchgs_i-function) = 0 &then

&glob tmpchgs_i-function

FUNCTION get-all-fields returns character (p-file-name as character ):
define variable v-dop as character no-undo .
  find first _file no-lock where _file._file-name = p-file-name no-error .
  if not available _file then return "":U.
  for each _field no-lock where
           _field._file-recid = recid(_file) :
    assign
    v-dop = v-dop + _field._field-name + {&comma-char}
    .
  end.
  return trim(v-dop).

END FUNCTION.

&endif

&if defined(tmpchgs_i-proc) = 0 and "{3}" = "update" &then

&glob tmpchgs_i-proc

procedure tempchgs-create-lable-record :
define input parameter p-t_name as character no-undo .
define input parameter p-f_name as character no-undo .
define input parameter p-l_name as character no-undo .
define input parameter p-f_update as logical no-undo .
define input parameter p-f_parent as character no-undo .
define input parameter p-f_visible as logical no-undo .
define buffer buf_{2} for {2}.

  do
  on error undo, return error
  :
     find first buf_{2} where
              buf_{2}.t_name = p-t_name
          and buf_{2}.f_name = p-f_name no-error.
     if not available buf_{2} then do:
      create buf_{2}.
      assign
      buf_{2}.t_name = p-t_name
      buf_{2}.f_name = p-f_name
      buf_{2}.l_name = p-l_name
      .
     end.
     assign
     buf_{2}.f_can_update = p-f_update
     buf_{2}.f_parent = p-f_parent
     buf_{2}.f_visible = p-f_visible
     buf_{2}.f_root = (if p-f_parent = '':U then p-f_name else p-f_parent)
     buf_{2}.num_ = 0

     .
  end.

end procedure. /* tempchgs-create-lable-record */


&endif

&if "{3}" <> "update" &then
PROCEDURE proc-full-temp-changes :

  &if "{3}" = "with-action" &then
  define input  parameter p-act-create as logical   no-undo .
  define input  parameter p-act-delete as logical   no-undo .
  &endif
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

  for each {&tt_name}:
    delete {&tt_name}.
  end.

  if not p-hst-handle:available then do:
    return .
  end.

  create buffer h-new-buf  for table p-hst-handle .
  create buffer h-main-buf for table p-main-table .

  /* проход по основной таблице с целью создания списка                      */
  /* полей первичного индекса, оставшихся полей и запроса к основной таблице */
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
      fh                = p-hst-handle:buffer-field( v-field-name ) /* значения для выборки берем из записи истории */
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
/*    if lookup( v-field-name, v-main-pi-fld-lst, ",":U ) = 0 then do:*/
      assign
        v-main-fld-lst = v-main-fld-lst + v-delim-list + v-field-name
      .
      if v-delim-list = "":U then do:
        assign
          v-delim-list = ",":U
        .
      end.
/*    end.*/
  end.
  /* это проход по исторической таблице для создания запроса */
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
      &if "{3}" = "with-action" &then
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
      &endif

      if v-old-value <> v-new-value
        &if defined(VisibleKeyField) ne 0
        &then
        or lookup(v-field-name,v-main-pi-fld-lst) ne 0
        &endif 
      then do:
        create {&tt_name}.
        assign
          {&tt_name}.t_name = p-main-table
          {&tt_name}.f_name = v-field-name
          {&tt_name}.l_name = replace( v-label, "&":U, "":U )
          {&tt_name}.v_old  = trim( v-old-value )
          {&tt_name}.v_new  = trim( v-new-value )
          {&tt_name}.num_   = 0
          {&tt_name}.fNotChange = v-old-value eq v-new-value
        .
      end.
    end.
  end.

  assign
    v-num-entries = num-entries( p-label-form, {&delim-flf} )
  .
  &if defined( myChangeAdd) ne 0
  &then
      run {&myChangeAdd} (if p-act-create = true then ? else p-hst-handle,
                          if p-act-delete = true then ? else h-for-comp).
  &endif
  do v-ind = 1 to v-num-entries
  on error undo, return error return-value
  :
    if num-entries( entry( v-ind, p-label-form, {&delim-flf} ), {&delim-par} ) = 3 then do:
      assign
        v-field-name = entry( 1, entry( v-ind, p-label-form, {&delim-flf} ), {&delim-par} )
        v-field-lvl  = entry( 2, entry( v-ind, p-label-form, {&delim-flf} ), {&delim-par} )
        v-field-form = entry( 3, entry( v-ind, p-label-form, {&delim-flf} ), {&delim-par} )
      .
      find first {&tt_name}
        where {&tt_name}.f_name = v-field-name
        no-error .
      if available {&tt_name} then do:
        if trim( v-field-lvl ) <> "":U then do:
          assign
            {&tt_name}.l_name = v-field-lvl
          .
        end.
        if trim( v-field-form ) <> "":U then do:
          assign
            {&tt_name}.v_old = dynamic-function( v-field-form, {&tt_name}.v_old )
          .
          if h-for-comp <> ? then do:
            assign
              {&tt_name}.v_new = dynamic-function( v-field-form, {&tt_name}.v_new )
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
                    ,entry( 1, entry( v-ind, p-label-form, {&delim-flf} ), {&delim-par} )
                    ,entry( v-ind, p-label-form, {&delim-flf} )
                  ) skip
        substitute( "полный список: &2", p-label-form ) skip
        view-as alert-box error .
    end.
  end.

  delete object h-new-buf .
  delete object h-main-buf .

END PROCEDURE. /* proc-full-temp-changes */

&endif

/* $Workfile$ e n d */