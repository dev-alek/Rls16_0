block-level on error undo, throw.
block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: a47b2aad5f12, 1943, rls $":U .
define variable vss-author      as character no-undo init "$Author: druban $":U .
define variable vss-date        as character no-undo init "$Date: Wed Jul 17 14:42:22 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: send-cli.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/send-cli.p $":U .
define variable vss-description as character no-undo init "Пересылка клиентов на кассу".
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
define variable i-obj-code like ub.clients.obj-code no-undo.
define variable action as character no-undo.
define variable multiple-shops as logical no-undo.
define variable p-batch as logical no-undo .
define variable p-other as character no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE SHARED TEMP-TABLE cash-cli no-undo
FIELD cli-type          like ub.clients.obj-type
FIELD cli-code          like ub.clients.obj-code
FIELD cli-name          like ub.clients.obj-name
FIELD obj-name          like ub.clients.obj-name
FIELD cli-name2         like ub.person.name1
FIELD cli-name3         like ub.person.name2
FIELD cli-adr           like ub.firm.addres1
FIELD cli-adr2          like ub.firm.addres2
FIELD director          like ub.firm.director
FIELD e-mail            like ub.firm.e-mail
FIELD engl-name         like ub.firm.engl-name
FIELD is-pboul          like ub.firm.is-pboul
FIELD okonh             like ub.firm.okonh
FIELD okpo              like ub.firm.okpo
FIELD cli-city          like ub.firm.city
FIELD cli-ind           like ub.firm.ind
FIELD cli-inn           like ub.firm.inn
FIELD cli-phone         like ub.firm.phone
FIELD fax               like ub.firm.fax
FIELD telex             like ub.firm.telex
FIELD phone1-note       like ub.firm.phone1-note
FIELD post-addr1        like ub.firm.post-addr1
FIELD post-addr2        like ub.firm.post-addr2
FIELD position          like ub.firm.head-position
FIELD post-box          like ub.person.post-box
FIELD h-ka              as integer
FIELD kpp               like ub.person.kpp
FIELD justface          as integer
FIELD kat-pcnt          as integer
FIELD d-card            like ub.dis-card.d-card
FIELD lim-kr            like ub.clients.lim-kr
FIELD current-saldo     as decimal
FIELD current-saldo-rubl as decimal
FIELD current-saldo-base as decimal
FIELD d-pcnt            like ub.dis-card.d-pcnt
FIELD cash-d-pcnt       like ub.dis-card.cash-d-pcnt
FIELD d-pcnt-method     like ub.dis-card.d-pcnt-method
FIELD cli-status_       like ub.clients.stts
FIELD status_           as character
FIELD issue-code        like ub.dis-card.issue-code
FIELD issue-date        like ub.dis-card.issue-date
FIELD type              like ub.dis-card.type
FIELD emitent-host-code like ub.dis-card-type.emitent-host-code
FIELD d-pcnt-byshop     like ub.dis-card-type.d-pcnt-byshop
FIELD card-media        like ub.dis-card-type.card-media
FIELD credit-card       like ub.dis-card.credit-card
FIELD debet-card        like ub.dis-card.debet-card
FIELD staff-card        like ub.dis-card.staff-card
FIELD cli-message       like ub.dis-card.cli-message
FIELD fiscal-pay        like ub.dis-card-type.fiscal-pay
FIELD given-by          like ub.person.given-by
FIELD passport          as character
FIELD pay-code          like ub.dis-card-type.pay-code
FIELD mixed-pay         like ub.dis-card-type.mixed-pay
FIELD sourced-card      like ub.dis-card.sourced-card
FIELD mask-card         like ub.dis-card.mask-card
FIELD valid-date        as date initial 12/31/9999
FIELD property-value-chr as character extent 4
field dcr-pcnt            as integer
field dcr-abs             as integer
field dcr-pcnt-qnty       as integer
field dcr-pcnt-tot        as integer
field dcr-debet-pay       as integer
field dcr-credit-pay      as integer
field has-attrs           as logical
field has-attrs-lim       as logical
field ef-access-key       as character
field ef-format           as integer
FIELD crf as integer
FIELD rc as recid
index pi is unique primary crf
index icli cli-type cli-code
index idcard d-card
.
define SHARED temp-table cash-cli-attr no-undo
field d-card             like ub.dis-card.d-card
field dc-petrol-code      as integer
field cdpay-code          as integer
field curr-code           as integer
field dc-car-brand        as character
field dc-car-reg-number   as character
field dc-limit-type       as character
field dc-limit            as decimal
field dc-limit-l          as decimal
field account-type        as integer
field dc-sum-id           as character
field dc-minnum           as decimal
field dc-maxnum           as decimal
field caller_id           as character
index pi is unique primary
d-card
dc-petrol-code
dc-sum-id
caller_id
.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define shared temp-table dc-list no-undo like ub.dis-card
  field to-del as logical
  field order-num as integer
  field fdec as decimal
  field fint as integer
  field flog as logical
  field fchar as character
  index pi  is primary unique d-card
  index cn      card-num
  index cli cli-type cli-code
  index host-dscnt  emitent-host-code status_ d-pcnt
  index host-type  emitent-host-code type d-pcnt
  index oi order-num
  .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared  temp-table dc-list-hist no-undo
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-disprop-menu-section-num as integer no-undo .
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-nws as handle no-undo .
procedure disproph_write-dis-card-property-proc  :
define parameter buffer buf_dis-card-property for ub.dis-card-property .
define parameter buffer buf_dis-card for ub.dis-card.
define input parameter p-d-card      like ub.dis-card-property.d-card no-undo .
define input parameter p-dt-code      like ub.dis-card-property.dt-code no-undo .
define input parameter p-host-code   like ub.dis-card-property.host-code no-undo .
define input parameter p-obj-type    like ub.dis-card-property.obj-type no-undo .
define input parameter p-obj-code    like ub.dis-card-property.obj-code no-undo .
define input parameter p-dtm-code    like ub.dis-card-property.dtm-code no-undo .
define input parameter p-card-num    like ub.dis-card-property.card-num  no-undo .
define input parameter p-main-card   like ub.dis-card-property.main-card  no-undo .
define input parameter p-first-card  like ub.dis-card-property.first-card  no-undo .
define input parameter p-first-main-card  like ub.dis-card-property.first-main-card  no-undo .
define input parameter p-node-code   like ub.dis-card-property.node-code no-undo .
define input parameter p-action      as integer no-undo .
define input parameter p-source-type like ub.c-dc-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-dc-hist.source-ref no-undo .
define input-output parameter p-chip-num as integer no-undo .
define input-output parameter p-corr-date as date no-undo .
define input-output parameter p-corr-time as integer no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-uniq-key-rec as character no-undo .
define variable v-send as integer no-undo .
define buffer buf_c-dc-hist for ub.c-dc-hist.
define buffer buf_c-dis-card-property for ub.c-dis-card-property.
  main-block:
  do
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    if not available buf_dis-card-property and not p-action = integer('1':U) then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не определена запись СВОЙСТВА ДК" skip
        view-as alert-box error .
      undo, return error .
    end.
  v-send = integer('0':U).
  if not p-action = integer('1':U) then do:
    if available buf_dis-card then do:
      if g#news then do:
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option in g#lib-nws
  (input  g#db-num
  ,input  'dis-card-property':U
  ,input  0
  ,input  '':U
  ,input  0
  ,input  buf_dis-card.type
  ,input  '':U
  ,input  '':U
  ,input  buf_dis-card.emitent-host-code
  ,input  (if buf_Dis-card-property.dt-code > 0 then 0 else -1)
  ,input  0
  ,input  'nws-to-hist'
  ,output v-send
  ) no-error .
      end.
      else do:
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option in g#lib-nws
  (input  g#db-num
  ,input  'dis-card-property':U
  ,input  0
  ,input  '':U
  ,input  0
  ,input  buf_dis-card.type
  ,input  '':U
  ,input  '':U
  ,input  buf_dis-card.emitent-host-code
  ,input  (if buf_Dis-card-property.dt-code > 0 then 0 else -1)
  ,input  0
  ,input  'hist-from-prim'
  ,output v-send
  ) no-error .
      end.
    end.
  end.
  if v-send >= 0 then do:
    run cur-time in this-procedure(output v-date, output v-time).
    if p-action = integer('1':U) then do:
      create buf_c-dis-card-property.
      assign
      buf_c-dis-card-property.d-card            = p-d-card
      buf_c-dis-card-property.card-num          = p-card-num
      buf_c-dis-card-property.host-code         = p-host-code
      buf_c-dis-card-property.obj-type          = p-obj-type
      buf_c-dis-card-property.obj-code          = p-obj-code
      buf_c-dis-card-property.dt-code           = p-dt-code
      buf_c-dis-card-property.node-code         = p-node-code
      buf_c-dis-card-property.dtm-code         = p-dtm-code
      buf_c-dis-card-property.main-card         = p-main-card
      buf_c-dis-card-property.first-main-card   = p-first-main-card
      buf_c-dis-card-property.first-card        = p-first-card
      buf_c-dis-card-property.chip-num          = (if p-chip-num = 0
                                                   then next-value (s-dc-chip, ub)
                                                   else p-chip-num)
      buf_c-dis-card-property.corr-time         = (if p-corr-time = ?
                                                   then v-time
                                                   else p-corr-time)
      buf_c-dis-card-property.corr-user-db-num  = g#db-num
      buf_c-dis-card-property.corr-user-name    = if g#news then (chr(4) +  'СПН':U) else g#userid
      buf_c-dis-card-property.corr-date         = (if p-corr-date = ?
                                                   then v-date
                                                   else p-corr-date)
      .
    end.
    else do:
      create buf_c-dis-card-property.
      buffer-copy buf_dis-card-property to buf_c-dis-card-property
      assign
      buf_c-dis-card-property.d-card             = buf_dis-card-property.d-card
      buf_c-dis-card-property.card-num           = buf_dis-card-property.card-num
      buf_c-dis-card-property.dt-code             = buf_dis-card-property.dt-code
      buf_c-dis-card-property.main-card          = buf_dis-card-property.main-card
      buf_c-dis-card-property.first-main-card    = buf_dis-card-property.first-main-card
      buf_c-dis-card-property.first-card         = buf_dis-card-property.first-card
      buf_c-dis-card-property.host-code          = buf_dis-card-property.host-code
      buf_c-dis-card-property.obj-type          = p-obj-type
      buf_c-dis-card-property.obj-code          = p-obj-code
      buf_c-dis-card-property.node-code         = p-node-code
      buf_c-dis-card-property.dtm-code         = p-dtm-code
      buf_c-dis-card-property.chip-num           = (if p-chip-num = 0
                                                    then next-value (s-dc-chip, ub)
                                                    else p-chip-num)
      buf_c-dis-card-property.corr-time          = (if p-corr-time = ?
                                                    then v-time
                                                    else p-corr-time)
      buf_c-dis-card-property.corr-user-db-num   = g#db-num
            buf_c-dis-card-property.corr-user-name    = (if g#news
                                                   then (chr(4) +  'СПН':U)
                                                   else (if g#esys
                                                         then (chr(4) +  'ВС':U)
                                                         else g#userid
                                                         )
                                                   )
      buf_c-dis-card-property.corr-date          = (if p-corr-date = ?
                                                    then v-date
                                                    else p-corr-date)
      .
      run gen-key-rec in this-procedure (
                                          input 'dis-card-property':U
                                        ,input buffer buf_dis-card-property:handle
                                        ,output v-uniq-key-rec).
    end.
    if p-chip-num = 0   then do:
      create buf_c-dc-hist.
      buffer-copy buf_c-dis-card-property to buf_c-dc-hist
      assign
      buf_c-dc-hist.action =  p-action
      buf_c-dc-hist.subject = 'dis-card-property':U
      buf_c-dc-hist.is-news = g#news
      buf_c-dc-hist.source-type = p-source-type
      buf_c-dc-hist.source-ref = p-source-ref
      buf_c-dc-hist.uniq-key-rec = v-uniq-key-rec
      .
    end.
    assign
    p-chip-num = buf_c-dis-card-property.chip-num
    p-corr-date = buf_c-dis-card-property.corr-date
    p-corr-time = buf_c-dis-card-property.corr-time
    .
    run disproph_send-nws in this-procedure (
                                              buffer buf_c-dis-card-property
                                             ,buffer buf_c-dc-hist
                                             ,buffer buf_dis-card
                                              ).
    end.
  end.
end procedure.
procedure disproph_send-nws :
define parameter buffer buf_c-dis-card-property for ub.c-dis-card-property.
define parameter buffer buf_c-dc-hist for ub.c-dc-hist.
define parameter buffer buf_Dis-card for ub.dis-card.
define variable v-dh-hn as integer no-undo .
main-block:
do
on error undo, return error return-value
:
  if g#news
  and g#db-num > 0
  and buf_c-dis-card-property.corr-user-db-num <> g#db-num
  then return.
  if g#db-num = 0
  or (g#news
      and g#db-num > 0
      and buf_c-dis-card-property.corr-user-name = (chr(4) +  'СПН':U)
      )
  then do:
    if not available buf_dis-card then do:
      find first buf_dis-card no-lock where
                buf_Dis-card.d-card = buf_c-dis-card-property.d-card no-error.
    end.
    if not available buf_dis-card then do:
      assign
      v-dh-hn = integer('0':U).
    end.
    else do:
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option in g#lib-nws
  (input  g#db-num
  ,input  'dis-card-property':U
  ,input  0
  ,input  '':U
  ,input  0
  ,input  buf_dis-card.type
  ,input  '':U
  ,input  '':U
  ,input  buf_dis-card.emitent-host-code
  ,input  (if buf_c-dis-card-property.dt-code > 0 then 0 else -1)
  ,input  0
  ,input  'hist-to-nws'
  ,output v-dh-hn
  ) no-error .
    end.
    if v-dh-hn >= 0 then do:
      run str/callnews.p (
        input 'c-dis-card-property':U
        ,input (buffer buf_c-dis-card-property:handle)
        ) no-error .
      if error-status:error then do:
        undo main-block,  return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1) ).
      end.
      if available buf_c-dc-hist then do:
        run str/callnews.p (
          input 'c-dc-hist':U
          ,input (buffer buf_c-dc-hist:handle)
          ) no-error .
        if error-status:error then do:
          undo main-block,  return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1) ).
        end.
      end.
    end.
  end.
end.
end procedure.
procedure discprop-node-code :
define input parameter p-dtm-code as integer no-undo .
define input parameter p-node-code as integer no-undo .
define output parameter p-data-type as character no-undo .
define output parameter p-format as character no-undo .
define output parameter p-label as character no-undo .
define output parameter p-range as integer no-undo .
define output parameter p-rw-option as character no-undo .
define buffer buf_prop-map for ub.prop-map.
define buffer buf_prop-head for ub.prop-head.
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
find first buf_prop-head no-lock where
          buf_prop-head.dtm-code = p-dtm-code no-error .
if available buf_prop-head then do:
  if p-node-code > 0 then do:
    find first buf_prop-map no-lock where
              buf_prop-map.dtm-code = p-dtm-code
          and buf_prop-map.node-code = p-node-code no-error .
    if available buf_prop-map then do:
      assign
      p-data-type = buf_prop-map.node-value-type
      p-format = buf_prop-map.node-format
      p-label = buf_prop-map.node-label
      p-rw-option = buf_prop-map.rw-option
      .
    end.
  end.
  if buf_prop-head.storage-place  = "":U
  and buf_prop-head.storage-place-host  > "":U
  and buf_prop-head.storage-place-obj  > "":U then do:
    p-range =  12.
  end.
  if buf_prop-head.storage-place  > "":U
  and buf_prop-head.storage-place-host  > "":U
  and buf_prop-head.storage-place-obj  > "":U then do:
    p-range =  3.
  end.
  if buf_prop-head.storage-place  > "":U
  and buf_prop-head.storage-place-host  > "":U
  and buf_prop-head.storage-place-obj  = "":U then do:
    p-range =  2.
  end.
  if buf_prop-head.storage-place  = "":U
  and buf_prop-head.storage-place-host  > "":U
  and buf_prop-head.storage-place-obj  = "":U then do:
    p-range =  1.
  end.
  if buf_prop-head.storage-place  > "":U
  and buf_prop-head.storage-place-host  = "":U
  and buf_prop-head.storage-place-obj  = "":U then do:
    p-range =  0.
  end.
end.
end.
end procedure.
procedure discprop-initial:
define input parameter p-dtm-code as integer no-undo .
define input parameter p-node-code as integer no-undo .
define output parameter p-init-value-character as character no-undo .
define output parameter p-init-value-date as date no-undo .
define output parameter p-init-value-decimal as decimal no-undo .
define output parameter p-init-value-integer as integer no-undo .
define output parameter p-init-value-logical as logical no-undo .
define buffer buf_prop-map for ub.prop-map.
find first buf_prop-map no-lock where
          buf_prop-map.dtm-code = p-dtm-code
      and buf_prop-map.node-code = p-node-code no-error.
if not available buf_prop-map then return error substitute("Не найдено свойство &1 для объекта &2"
                                                            , p-node-code
                                                            , p-dtm-code).
assign
p-init-value-character = buf_prop-map.init-value-character
p-init-value-date = buf_prop-map.init-value-date
p-init-value-decimal = buf_prop-map.init-value-decimal
p-init-value-integer = buf_prop-map.init-value-integer
p-init-value-logical = buf_prop-map.init-value-logical
.
end procedure.
Function discprop-usercanedit returns logical (  input p-dtm-code as integer, input p-db-num as integer):
define buffer buf_attr-prop for ub.attr-prop.
find first buf_attr-prop no-lock where
          buf_attr-prop.table-name = 'dis-card-property':U
      and buf_attr-prop.templ-rl-root = p-dtm-code
      and buf_attr-prop.upper-prop-code = "UserCanEdit"
      and buf_attr-prop.prop-code = (if p-db-num = 0 then 'DB0' else 'DBR':U) no-error.
if not available buf_attr-prop
or logical(buf_attr-prop.property-value) = no then do:
  return no.
end.
return yes.
end function.
procedure discprop-edit :
define input parameter p-dtm-code-node-name as character no-undo .
define output parameter p-edit-menu-section-num as integer no-undo .
define buffer buf_attr-prop for ub.attr-prop.
do
on error undo, return error return-value
:
  find first buf_attr-prop no-lock where
          buf_attr-prop.table-name = 'dis-card-property':U
     and  buf_attr-prop.templ-rl-root = integer(entry(1, p-dtm-code-node-name, chr(4)))
     and  buf_attr-prop.upper-prop-code = "ManualEdit":U
     and  buf_attr-prop.prop-code = "SectionNum":U no-error .
  if available buf_attr-prop then do:
    assign
    p-edit-menu-section-num = integer(buf_attr-prop.property-value).
  end.
end.
end procedure.
procedure discprop-node-name :
define input parameter p-dtm-code-node-name as character no-undo .
define output parameter p-tool-tip as character no-undo .
define output parameter p-node-label as character no-undo .
define buffer buf_prop-map for ub.prop-map.
define buffer buf_prop-head for ub.prop-head.
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  find first buf_prop-head no-lock where
            buf_prop-head.dtm-code = integer(entry(1, p-dtm-code-node-name, chr(4) )) no-error .
  assign
  p-tool-tip   = if available buf_prop-head
                 then buf_prop-head.prop-des
                 else entry(1, p-dtm-code-node-name, chr(4) )
  p-node-label = (if available buf_prop-head
                  then buf_prop-head.prop-label
                  else '':U)
  .
  if entry(2, p-dtm-code-node-name, chr(4) ) <> "" then do:
    find first buf_prop-map no-lock where
              buf_prop-map.dtm-code = integer(entry(1, p-dtm-code-node-name, chr(4) ))
        and  buf_prop-map.node-code = integer(entry(2, p-dtm-code-node-name, chr(4) )) no-error.
    if available buf_prop-map then do:
      assign
      p-tool-tip   = buf_prop-map.node-description
      p-node-label = (if available buf_prop-head
                      then buf_prop-head.prop-label
                      else '':U) + ":" + buf_prop-map.node-label
      .
    end.
  end.
end.
end procedure.
procedure discprop-write :
define input parameter p-d-card          like ub.dis-card-property.d-card     no-undo .
define input parameter p-host-code       like ub.dis-card-property.host-code  no-undo .
define input parameter p-obj-type        like ub.dis-card-property.obj-type   no-undo .
define input parameter p-obj-code        like ub.dis-card-property.obj-code   no-undo .
define input parameter p-dtm-code        like ub.dis-card-property.dtm-code   no-undo .
define input parameter p-node-code       like ub.dis-card-property.node-code  no-undo .
define input parameter p-dt-code         like ub.dis-card-property.dt-code    no-undo .
define input parameter p-sum-id          like ub.dis-card-property.sum-id     no-undo .
define input parameter p-value-character like ub.dis-card-property.property-value-character no-undo .
define input parameter p-value-date      like ub.dis-card-property.property-value-date no-undo .
define input parameter p-value-decimal   like ub.dis-card-property.property-value-decimal no-undo .
define input parameter p-value-integer   like ub.dis-card-property.property-value-integer no-undo .
define input parameter p-value-logical   like ub.dis-card-property.property-value-logical no-undo .
define input parameter p-source-type     as character no-undo .
define input parameter p-source-ref      as character no-undo .
define input-output parameter p-chip-num as integer no-undo .
define input-output parameter p-corr-date as date no-undo .
define input-output parameter p-corr-time as integer no-undo .
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  define buffer buf_dis-card-property for ub.dis-card-property .
  define buffer buf_dis-card for ub.dis-card.
  define buffer buf_prop-ref for ub.prop-ref.
  define variable v-data-type      as character no-undo .
  define variable v-data-type-1    as character no-undo .
  define variable v-format         as character no-undo .
  define variable v-label          as character no-undo .
  define variable v-range          as integer   no-undo .
  define variable v-rw-option      as character no-undo .
  run discprop-node-code in this-procedure
    (
     input  p-dtm-code
    ,input  p-node-code
    ,output v-data-type
    ,output v-format
    ,output v-label
    ,output v-range
    ,output v-rw-option
    ) no-error .
  if error-status :error then do:
    undo, return error return-value .
  end.
  v-data-type-1 = entry(1, v-data-type).
  if p-dt-code = ? then do:
    find buf_prop-ref no-lock where
        buf_prop-ref.dtm-code = p-dtm-code
    and buf_prop-ref.sum-id = p-sum-id no-error.
    if not available buf_prop-ref then do:
      undo, return error substitute("Неопределен или неоднозначен ИТОГ/СРЕЗ для объекта-операнда &1 &2"
                                    ,p-dtm-code
                                    ,p-sum-id).
    end.
    assign
    p-dt-code = buf_prop-ref.dt-code.
  end.
  if discprop-usercanedit ( input p-dtm-code, input g#db-num)  = no then do:
    undo, return error "Нельзя редактировать свойство в данной БД".
  end.
  run discprop-check in this-procedure (
                                          input v-range
                                        ,input p-d-card
                                        ,input p-host-code
                                        ,input p-obj-type
                                        ,input p-obj-code
                                        ,input p-dtm-code
                                        ,input p-node-code
                                        ,input p-dt-code
                                      ) no-error .
  if error-status:error then undo,  return error return-value .
  find first buf_dis-card-property exclusive-lock
    where buf_dis-card-property.d-card    = p-d-card
      and buf_dis-card-property.host-code = p-host-code
      and buf_dis-card-property.obj-type  = p-obj-type
      and buf_dis-card-property.obj-code  = p-obj-code
      and buf_dis-card-property.dt-code = p-dt-code
      and buf_dis-card-property.node-code = p-node-code
    no-error .
    find first buf_dis-card no-lock where
                buf_dis-card.d-card = p-d-card.
  if not available buf_dis-card-property then do:
    create buf_dis-card-property .
    assign
      buf_dis-card-property.d-card    = p-d-card
      buf_dis-card-property.host-code = p-host-code
      buf_dis-card-property.obj-type  = p-obj-type
      buf_dis-card-property.obj-code  = p-obj-code
      buf_dis-card-property.dt-code = p-dt-code
      buf_dis-card-property.node-code = p-node-code
      buf_dis-card-property.dtm-code = p-dtm-code
      buf_dis-card-property.sum-id   = p-sum-id
      buf_dis-card-property.card-num  = buf_dis-card.card-num
      buf_dis-card-property.main-card  = buf_dis-card.main-card
      buf_dis-card-property.first-card  = buf_dis-card.first-card
      buf_dis-card-property.first-main-card  = buf_dis-card.first-main-card
    .
  end.
  else do:
    if (v-data-type-1 = 'character':U
    and buf_dis-card-property.property-value-character = p-value-character)
    or  (v-data-type-1 = 'date':U
        and buf_dis-card-property.property-value-date = p-value-date)
    or  (v-data-type-1 = 'decimal':U
        and buf_dis-card-property.property-value-decimal = p-value-decimal)
    or  (v-data-type-1 = 'integer':U
        and buf_dis-card-property.property-value-integer = p-value-integer)
    or  (v-data-type-1 = 'logical':U
        and buf_dis-card-property.property-value-logical = p-value-logical)
    then return.
  end.
  run disproph_write-dis-card-property-proc  in this-procedure (
          buffer buf_dis-card-property
          ,buffer Buf_dis-card
          ,input p-d-card
          ,input p-dt-code
          ,input p-host-code
          ,input p-obj-type
          ,input p-obj-code
          ,input p-dtm-code
          ,input buf_dis-card.card-num
          ,input buf_dis-card.main-card
          ,input buf_dis-card.first-card
          ,input buf_dis-card.first-main-card
          ,input p-node-code
          ,input (if new(buf_dis-card-property) then integer('1':U) else integer('2':U))
          ,input p-source-type
          ,input p-source-ref
          ,input-output p-chip-num
          ,input-output p-corr-date
          ,input-output p-corr-time
          ).
  assign
  buf_dis-card-property.property-value-character = (if v-data-type-1 = 'character':U
                                                    then p-value-character
                                                    else buf_dis-card-property.property-value-character)
  buf_dis-card-property.property-value-date      = (if v-data-type-1 = 'date':U
                                                    then p-value-date
                                                    else buf_dis-card-property.property-value-date)
  buf_dis-card-property.property-value-decimal   = (if v-data-type-1 = 'decimal':U
                                                    then p-value-decimal
                                                    else buf_dis-card-property.property-value-decimal)
  buf_dis-card-property.property-value-integer   = (if v-data-type-1 = 'integer':U
                                                    then p-value-integer
                                                    else buf_dis-card-property.property-value-integer)
  buf_dis-card-property.property-value-logical   = (if v-data-type-1 = 'logical':U
                                                    then p-value-logical
                                                    else buf_dis-card-property.property-value-logical)
  buf_dis-card-property.trg-param = (if p-source-type = '':U then '':U else 'no-hist':U)
  .
  release buf_dis-card-property no-error .
  if error-status:error then do:
    return error return-value .
  end.
end.
end procedure.
procedure discprop-delete :
define input parameter p-d-card    like ub.dis-card-property.d-card     no-undo .
define input parameter p-host-code like ub.dis-card-property.host-code  no-undo .
define input parameter p-obj-type  like ub.dis-card-property.obj-type   no-undo .
define input parameter p-obj-code  like ub.dis-card-property.obj-code   no-undo .
define input parameter p-dtm-code  like ub.dis-card-property.dtm-code   no-undo .
define input parameter p-node-code like ub.dis-card-property.node-code  no-undo .
define input parameter p-dt-code   like ub.dis-card-property.dt-code    no-undo .
define input parameter p-source-type as character no-undo .
define input parameter p-source-ref as character no-undo .
define output parameter p-deleted  as logical no-undo.
define input-output parameter p-chip-num as integer no-undo .
define input-output parameter p-corr-date as date no-undo .
define input-output parameter p-corr-time as integer no-undo .
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
define buffer buf_dis-card-property for ub.dis-card-property .
define buffer buf_dis-card for ub.dis-card.
define variable v-data-type      as character no-undo .
define variable v-format         as character no-undo .
define variable v-label          as character no-undo .
define variable v-range          as integer   no-undo .
define variable v-rw-option      as character   no-undo .
  run discprop-node-code in this-procedure
    (input  p-dtm-code
    ,input  p-node-code
    ,output v-data-type
    ,output v-format
    ,output v-label
    ,output v-range
    ,output v-rw-option
    ) no-error .
  if error-status :error then do:
    undo, return error return-value .
  end.
  find first buf_dis-card-property exclusive-lock
    where buf_dis-card-property.d-card    = p-d-card
      and buf_dis-card-property.host-code = p-host-code
      and buf_dis-card-property.obj-type  = p-obj-type
      and buf_dis-card-property.obj-code  = p-obj-code
      and buf_dis-card-property.dt-code = p-dt-code
      and buf_dis-card-property.node-code = p-node-code
    no-error NO-WAIT.
  if not available buf_dis-card-property then do:
    p-deleted = no.
  end.
  else do:
    run disproph_write-dis-card-property-proc  in this-procedure (
         buffer buf_dis-card-property
        ,buffer buf_dis-card
        ,input buf_dis-card-property.d-card
        ,input buf_dis-card-property.dt-code
        ,input buf_dis-card-property.host-code
        ,input buf_dis-card-property.obj-type
        ,input buf_dis-card-property.obj-code
        ,input buf_dis-card-property.dtm-code
        ,input buf_dis-card-property.card-num
        ,input buf_dis-card-property.main-card
        ,input buf_dis-card-property.first-card
        ,input buf_dis-card-property.first-main-card
        ,input buf_dis-card-property.node-code
        ,input integer('99':U)
        ,input p-source-type
        ,input p-source-ref
        ,input-output p-chip-num
        ,input-output p-corr-date
        ,input-output p-corr-time
         ).
    buf_dis-card-property.trg-param = (if p-source-type = '':U then '':U else 'no-hist':U).
    delete buf_dis-card-property no-error .
    if error-status:error then do:
      return error return-value.
    end.
    p-deleted = yes.
  end.
end.
end procedure.
procedure discprop-check :
define input parameter p-range  as integer no-undo .
define input parameter p-d-card like ub.dis-card-property.d-card no-undo .
define input parameter p-host-code like ub.dis-card-property.host-code no-undo .
define input parameter p-obj-type like ub.dis-card-property.obj-type no-undo .
define input parameter p-obj-code like ub.dis-card-property.obj-code no-undo .
define input parameter p-dtm-code like ub.dis-card-property.dtm-code no-undo .
define input parameter p-node-code like ub.dis-card-property.node-code no-undo .
define input parameter p-dt-code like ub.dis-card-property.dt-code no-undo .
define variable v-message as character no-undo .
define buffer buf_sysconf for ub.sysconf.
define buffer buf_clients for ub.clients.
define buffer buf_dis-card for ub.dis-card.
define buffer buf_attr-prop for ub.attr-prop.
do
on error undo, return error return-value
:
  if p-host-code > 0 then do:
    FIND FIRST buf_sysconf No-LOCK WHERE
              buf_sysconf.host-code = p-host-code No-ERROR.
    IF NOT AVAIL buf_sysconf THEN DO:
      v-message = substitute("Не найдена фирма &1", p-host-code).
      RETURN ERROR v-message.
    END.
  end.
  if p-obj-type <> "":U or
      p-obj-code <> 0 then do:
    find first buf_clients No-LOCK WHERE
              buf_clients.obj-type = p-obj-type AND
              buf_clients.obj-code = p-obj-code no-error .
    if not available buf_clients then do:
      v-message = substitute("Не найден объект &1&2", p-obj-type, p-obj-code).
      RETURN ERROR v-message.
    end.
  end.
  else if NOT (p-obj-type = "":U and p-obj-code = 0) then do:
    v-message = substitute("Неверные значения параметров p-obj-type/p-obj-code и/или p-host-code: &1&2 &3"
                            , p-obj-type
                            , p-obj-code
                            , p-host-code).
    RETURN ERROR v-message.
  end.
  if p-d-card <> "":U then do:
    find first buf_dis-card No-LOCK WHERE
                buf_dis-card.d-card = p-d-card No-ERROR.
    if not avail buf_dis-card then do:
      v-message =substitute("Не найдена ДК").
      return error  v-message.
    end.
    if buf_dis-card.emitent-host-code <> 0
    and p-host-code <> buf_dis-card.emitent-host-code then do:
      v-message = substitute("Для фирменной карты свойство можно ввести только с привязкой к фирме-эмитенту").
      return error v-message.
    end.
    if buf_dis-card.emitent-host-code = 0
    and p-range = 1
    and p-host-code <> 0 then do:
      v-message = substitute("Для свойство с ОБЛАСТЬЮ ДЕЙСТВИЯ СОГЛАСНО КОДУ ЭМИТЕНТА&1" +
                            "для ГЛОБАЛЬНОЙ карты можно ввести только ГЛОБАЛЬНОЕ свойство"
                              , chr(10)
                            ).
      return error v-message.
    end.
  end.
end.
end procedure.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable dcard-algo-field-name as character no-undo extent 3 init [
 'd-pcnt':U
,'cash-d-pcnt':U
,'pcnt-kat':U].
define variable algo-field-abbr as character no-undo extent 3 init [
 'ITEM%':U
,'TOTAL%':U
,'CATEG':U].
FUNCTION dct-algo-Date-to-String returns character(input  p-date as date):
define variable v-date-str as character no-undo .
assign
v-date-str = string(YEAR(p-date), "9999":U) + chr(47) +
             string(Month(p-date), "99":U) + chr(47) +
             string(DAY(p-date), "99":U).
return v-date-str.
END FUNCTION.
function dct-algo-string-to-date returns date ( input p-string  as character):
  define variable v-date as date no-undo .
  assign
  v-date = date(integer(substring(p-string, 6, 2))
                ,integer(substring(p-string, 9, 2))
                ,integer(substring(p-string, 1, 4))
               ) no-error .
  if error-status:error then return ?.
  return v-date.
END FUNCTION.
FUNCTION dct-algo-get-sum-id-from-DT-CODE returns character ( input p-DT-CODE as integer):
define buffer buf_prop-ref for ub.prop-ref.
find first buf_prop-ref no-lock where
          buf_prop-ref.DT-CODE = p-DT-CODE no-error.
if not available buf_prop-ref then do:
  return chr(63).
end.
return buf_prop-ref.sum-id.
END FUNCTION.
FUNCTION dct-algo-get-description-sum-id returns character ( input p-dt-code as integer):
define variable v-des as character no-undo .
define buffer buf_prop-ref for ub.prop-ref.
define buffer buf_prop-head for ub.prop-head.
find first buf_prop-ref no-lock where
          buf_prop-ref.dt-code = p-dt-code no-error.
if not available buf_prop-ref then do:
  return substitute("Срез/итог по ДК c кодом &1 - срез не найден", p-dt-code).
end.
find first buf_prop-head no-lock where
        buf_prop-head.dtm-code = buf_prop-ref.dtm-code no-error.
if not available buf_prop-head then do:
  return substitute("Срез/итог по ДК &1 c кодом &2 - неизвестное", p-dt-code, buf_prop-ref.dtm-code).
end.
assign
v-des = substitute("&1  &2 &3"
                  , buf_prop-head.prop-name
                  , buf_prop-ref.sum-id
                  , buf_prop-ref.caller_id).
return v-des.
end FUNCTION.
FUNCTION dct-algo-get-description-node-code returns character ( input p-dtm-code as integer
                                                            ,input p-dt-code as integer
                                                            ,input p-node-code as integer
                                                            ):
define variable v-des as character no-undo .
define buffer buf_prop-ref for ub.prop-ref.
define buffer buf_prop-head for ub.prop-head.
define buffer buf_prop-map for ub.prop-map.
find first buf_prop-ref no-lock where
          buf_prop-ref.dt-code = p-dt-code no-error.
if not available buf_prop-ref then do:
  return substitute("Срез/итог по ДК c кодом &1 - срез не найден", p-dt-code).
end.
find first buf_prop-head no-lock where
        buf_prop-head.dtm-code = p-dtm-code no-error.
if not available buf_prop-head then do:
  return substitute("Срез/итог по ДК &1 c кодом &2 - неизвестное", p-dt-code, p-dtm-code).
end.
find first buf_prop-map no-lock where
        buf_prop-map.dtm-code = p-dtm-code
    and buf_prop-map.node-code = p-node-code no-error .
if not available buf_prop-map then do:
  return substitute("Срез/итог по ДК &1, &2.&3 - неизвестно"
                    , p-dt-code
                    , buf_prop-head.prop-label
                    , p-node-code).
end.
assign
v-des = substitute("&1.&2 &3 &4"
                  , buf_prop-head.prop-label
                  , buf_prop-map.node-label
                  , buf_prop-ref.sum-id
                  , buf_prop-ref.caller_id).
return v-des.
end FUNCTION.
function dct-algo-get-prev-sum-id RETURNS integer (
                                                    input p-dt-code as integer
                                                   ):
define variable v-dtm-code as integer no-undo .
define variable v-sum-id as character no-undo .
define variable v-caller-id as character no-undo .
define buffer buf_prop-ref for ub.prop-ref.
find first buf_prop-ref no-lock where
        buf_prop-ref.dt-code = p-dt-code no-error.
if not available buf_prop-ref then return ?.
assign
v-dtm-code = buf_prop-ref.dtm-code
v-sum-id = buf_prop-ref.sum-id.
v-caller-id = buf_prop-ref.caller_id.
find last buf_prop-ref no-lock where
          buf_prop-ref.dtm-code = v-dtm-code
     and  buf_prop-ref.sum-id < v-sum-id
     and  buf_prop-ref.caller_id = v-caller-id
     no-error.
if available buf_prop-ref then return buf_prop-ref.dt-code.
return -1 .
END FUNCTION.
FUNCTION dct-algo-get_dcproperty-value returns logical (
                                                          input p-prop-name as character
                                                        , input p-d-card    as character
                                                        , input p-host-code as integer
                                                        , input p-obj-type  as character
                                                        , input p-obj-code  as integer
                                                        , output p-value-character as character
                                                        , output p-value-date   as date
                                                        , output p-value-integer as integer
                                                        , output p-value-decimal as decimal
                                                        , output p-value-logical as logical):
  return no.
END FUNCTION.
FUNCTION dct-algo-get_dcproperty-value-chr returns logical (
                                                          input p-d-card    as character
                                                        , input p-emitent-host-code as integer
                                                        , input p-type as character
                                                        , input p-host-code as integer
                                                        , input p-obj-type  as character
                                                        , input p-obj-code  as integer
                                                        , output p-value-chr as character):
define variable v-dt-code as integer no-undo .
define variable v-node-code as integer no-undo .
define variable v-field-name as character no-undo .
define variable v-storage-place as character no-undo .
define variable v-sum-id-value as character no-undo .
define variable v-sum-id-output as logical no-undo .
define variable v-value-chr as character no-undo .
define variable v-ii as integer no-undo .
define buffer buf_dis-card-property for ub.dis-card-property.
define buffer buf_dis-host for ub.dis-host.
define buffer buf_dis-obj for ub.dis-obj.
run get-cd-sumid in this-procedure (
                                      input p-emitent-host-code
                                     ,input p-type
                                     ,input p-host-code
                                     ,input p-obj-type
                                     ,input p-obj-code
                                     ,output v-sum-id-value
                                     ,output v-sum-id-output
                                    ) no-error.
if not v-sum-id-output then do:
  return no.
end.
do v-ii = 1 to num-entries(v-sum-id-value):
  assign
  v-storage-place = entry(1, entry(v-ii, v-sum-id-value), chr(4))
  v-dt-code = integer(entry(2, entry(v-ii, v-sum-id-value), chr(4)))
  v-node-code = integer(entry(3, entry(v-ii, v-sum-id-value), chr(4)))
  v-field-name = entry(4, entry(v-ii, v-sum-id-value), chr(4))
  no-error .
  if not error-status:error then do:
    case v-storage-place:
      when 'dis-card-property':U then do:
        find first buf_dis-card-property no-lock where
                  buf_dis-card-property.d-card = p-d-card
            and  buf_dis-card-property.host-code = p-host-code
            and  buf_dis-card-property.obj-type = p-obj-type
            and  buf_dis-card-property.obj-code = p-obj-code
            and  buf_dis-card-property.dt-code = v-dt-code
            and  buf_dis-card-property.node-code = v-node-code no-error .
        if available buf_dis-card-property then do:
          v-value-chr = buffer buf_dis-card-property:handle:buffer-field(v-field-name):string-value.
        end.
        else do:
          v-value-chr = chr(63).
        end.
      end.
      when 'dis-obj':U then do:
        find first buf_dis-obj no-lock where
                  buf_dis-obj.d-card = p-d-card
            and  buf_dis-obj.obj-type = p-obj-type
            and  buf_dis-obj.obj-code = p-obj-code
            and  buf_dis-obj.dt-code = v-dt-code no-error .
        if available buf_dis-obj then do:
          v-value-chr = buffer buf_dis-obj:handle:buffer-field(v-field-name):string-value.
        end.
        else do:
          v-value-chr = chr(63).
        end.
      end.
      when 'dis-host':U then do:
        find first buf_dis-host no-lock where
                  buf_dis-host.d-card = p-d-card
            and  buf_dis-host.host-code = p-host-code
            and  buf_dis-host.dt-code = v-dt-code no-error .
        if available buf_dis-host then do:
          v-value-chr = buffer buf_dis-host:handle:buffer-field(v-field-name):string-value.
        end.
        else do:
          v-value-chr = chr(63).
        end.
      end.
    end.
  end.
  p-value-chr = p-value-chr + (if v-ii = 1 then '':U else chr(44)) + v-value-chr.
end.
END FUNCTION.
FUNCTION dct-algo_custom-sent-description RETURNS CHARACTER
  ( INPUT p-custom-sent as character ) :
DEFINE VARIABLE v-storage-place AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-dtm-code AS integer NO-UNDO.
DEFINE VARIABLE v-sum-id AS character NO-UNDO.
DEFINE VARIABLE v-caller-id AS character NO-UNDO.
DEFINE VARIABLE v-node-code AS INTEGER NO-UNDO.
DEFINE VARIABLE v-sum-id-description AS CHARACTER.
DEFINE BUFFER buf_prop-ref FOR ub.prop-ref.
IF p-custom-sent = chr(63) THEN RETURN "Не отсылать".
assign
v-storage-place = entry(1, p-custom-sent, chr(4))
v-dtm-code = integer(entry(2, p-custom-sent, chr(4)))
v-sum-id   = entry(3, p-custom-sent, chr(4))
v-caller-id = entry(4, p-custom-sent, chr(4))
v-node-code = integer(entry(5, p-custom-sent, chr(4)))
no-error .
IF ERROR-STATUS:ERROR THEN DO:
  MESSAGE
  "Не могу разобрать строку, описывающую итог"
   VIEW-AS ALERT-BOX WARNING.
  RETURN chr(63).
END.
FIND FIRST buf_prop-ref NO-LOCK WHERE
          buf_prop-ref.dtm-code = v-dtm-code
     AND  buf_prop-ref.sum-id = v-sum-id
     AND  buf_prop-ref.caller_id = v-caller-id NO-ERROR.
IF NOT AVAILABLE buf_prop-ref THEN DO:
  FIND FIRST buf_prop-ref NO-LOCK WHERE
            buf_prop-ref.dtm-code = v-dtm-code
      AND  buf_prop-ref.caller_id = v-caller-id NO-ERROR.
  IF NOT AVAILABLE buf_prop-ref THEN DO:
      MESSAGE
      "Не могу разобрать строку, описывающую итог"
       VIEW-AS ALERT-BOX WARNING.
      RETURN chr(63).
   end.
end.
ASSIGN
v-sum-id-description =  dct-algo-get-description-node-code ( v-dtm-code
                                                       ,buf_prop-ref.dt-code
                                                       ,v-node-code).
RETURN v-sum-id-description.
END FUNCTION.
define variable vss-include-info12 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable v-bgelib-bgefmt        as character         no-undo.
define variable v-bgelib-bgeflold      as character         no-undo.
define stream stmXMLOut.
define stream stmXMLLog.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure xmlchar-test :
define input parameter p-in-string          as character        no-undo.
define output parameter p-out-string-enc    as character        no-undo.
define output parameter p-out-string-dec    as character        no-undo.
do
on error undo, return error
:
       run xmlchar-encode in this-procedure
    (
          input p-in-string
        , output p-out-string-enc
    ).
       run xmlchar-decode in this-procedure
    (
          input p-out-string-enc
        , output p-out-string-dec
    ).
end.
end .
procedure xmlchar-encode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        when "?":U
        then do:
            assign
                p-out-string = "&#63;":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when "&":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&amp;":U
                        .
                    end.
                    when ">":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&gt;":U
                        .
                    end.
                    when "<":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&lt;":U
                        .
                    end.
                    when "'":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&apos;":U
                        .
                    end.
                    when '"':U
                    then do:
                        assign
                            p-out-string = p-out-string + "&quot;":U
                        .
                    end.
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#10;":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#13;":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-encode-1c :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-decode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-last-position as integer      no-undo.
    define variable v-temp-integer  as integer      no-undo.
    define variable v-current-char  as character    no-undo.
    define variable v-next-char     as character    no-undo.
    define variable v-success       as logical      no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
        v-position   = 0
    .
    replace-cycle:
    do while yes
    on error undo, return error
    :
        assign
            v-last-position = index( p-in-string, "&":U, v-position + 1 )
        .
        if v-last-position <= v-position
        then do:
            if v-position = 0
            then do:
                assign
                    p-out-string = p-in-string
                .
            end.
            else do:
                assign
                    p-out-string = p-out-string + substring( p-in-string, v-position + 1 )
                .
            end.
            leave replace-cycle.
        end.
        else do:
            assign
                p-out-string    = p-out-string + substring( p-in-string, v-position + 1, v-last-position - v-position - 1 )
                v-position      = v-last-position
                v-current-char  = substring( p-in-string, v-position + 1, 1 )
            .
            if v-current-char = "#":U
            then do:
                assign
                    v-last-position = index( p-in-string, ";":U, v-position + 2 )
                .
                if v-last-position > 0
                then do:
                    run xmlchar-read-integer in this-procedure
                     (
                          input substring( p-in-string, v-position + 2, v-last-position - v-position - 2 )
                        , output v-temp-integer
                        , output v-success
                    ).
                    if v-success = yes
                    and v-temp-integer >= 1
                    and v-temp-integer <= 255
                    then do:
                        assign
                            p-out-string = p-out-string + chr( v-temp-integer )
                            v-position   = v-last-position + 1
                        .
                    end.
                    else do:
                        assign
                            p-out-string = p-out-string + "&":U
                            v-position   = v-position   + 1
                        .
                    end.
                end.
                else do:
                    assign
                        p-out-string = p-out-string + "&":U
                        v-position   = v-position   + 1
                    .
                end.
            end.
            else do:
                case substring( p-in-string, v-position + 1, 3 )
                :
                    when "lt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + "<":U
                            v-position   = v-position   + 3
                        .
                    end.
                    when "gt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + ">":U
                            v-position   = v-position   + 3
                        .
                    end.
                    otherwise do:
                        if substring( p-in-string, v-position + 1, 4 ) = "amp;":U
                        then do:
                            assign
                                p-out-string = p-out-string + "&":U
                                v-position   = v-position   + 4
                            .
                        end.
                        else do:
                            case substring( p-in-string, v-position + 1, 5 )
                            :
                                when "quot;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + '"':U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                when "apos;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + "'":U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                otherwise do:
                                    assign
                                        p-out-string = p-out-string + "&":U
                                    .
                                end.
                            end case.
                        end.
                    end.
                end case.
            end.
        end.
    end.
end.
end .
procedure xmlchar-read-integer :
define input parameter p-input-string      as character        no-undo.
define output parameter p-output-integer   as integer          no-undo.
define output parameter p-success       as logical          no-undo.
do
on error undo, return error
:
    assign
        p-output-integer = integer( p-input-string )
    no-error.
    if error-status :error
    then do:
        assign
            p-success           = no
            p-output-integer    = 0
        .
    end.
    else do:
        assign
            p-success           = yes
        .
    end.
end.
end.
define variable v-bgelib-bgeclall           as logical      no-undo.
define variable v-bgelib-bgedict            as logical      no-undo.
define temp-table temp_ext-doc-type no-undo
    field edt-key               as integer
    field ext-doc-type          as character
    field ext-doc-type-label    as character
    index pi is primary unique
        edt-key
.
define temp-table temp_bgelib_goods no-undo
    field gds-code as integer
    index pi is primary unique
        gds-code
.
define temp-table temp_bgelib_clients no-undo
    field obj-type as character
    field obj-code as integer
    index pi is primary unique
        obj-type
        obj-code
.
define temp-table temp_bgelib_dis-card no-undo
    field d-card as character
    index pi is primary unique
        d-card
.
define temp-table temp_bgelib_trn-doc no-undo
    field doc-code as integer
.
procedure bgelib-tag-open:
do
on error undo, return error
:
define input parameter v-tag-level  as integer      no-undo.
define input parameter v-tag-name   as character    no-undo.
define input parameter v-tag-value  as character    no-undo.
    put stream stmXMLOut unformatted
        chr(10)
        + fill(" ", 4 * v-tag-level)
        + "<" + v-tag-name
        + ( if v-tag-value = "" or v-tag-value = ? then "" else " " )
        + v-tag-value + ">"
    .
end.
end procedure.
procedure bgelib-tag-put:
do
on error undo, return error
:
define input parameter v-tag-level      as integer      no-undo.
define input parameter v-tag-name       as character    no-undo.
define input parameter v-tag-value      as character    no-undo.
define input parameter v-empty-mode     as integer      no-undo.
    v-tag-name = trim(v-tag-name).
    if  v-empty-mode = 1
    or (v-empty-mode = 0 and (v-tag-value <> "" and v-tag-value <> ?) )
    or (v-empty-mode = 2 and (v-tag-value <> "" and v-tag-value <> ? and v-tag-value <> "0"))
    or (v-empty-mode = 3 and (v-tag-value <> "" and v-tag-value <> ? and caps(v-tag-value) <> "no"))
    then do:
        run xmlchar-encode in this-procedure (
              input v-tag-value
            , output v-tag-value
        ).
        put stream stmXMLOut unformatted
            chr(10) + fill(" ", 4 * v-tag-level)
                        + '<' + v-tag-name + '>'
                        + v-tag-value
                        + '</' + v-tag-name + '>'
        .
    end.
end.
end procedure.
procedure bgelib-tag-close:
do
on error undo, return error
:
define input parameter v-tag-level as integer      no-undo.
define input parameter v-tag-name  as character    no-undo.
    put stream stmXMLOut unformatted
        chr(10)
        + fill( " ", 4 * v-tag-level)
        + '</' + v-tag-name + '>'
    .
end.
end procedure.
procedure bgelib-write-log:
do
on error undo, return error
:
define input parameter v-filename   as character    no-undo.
define input parameter v-log-level  as integer      no-undo.
define input parameter v-out-string as character    no-undo.
    output stream stmXMLLog to value( v-filename ) append.
    put stream stmXMLLog unformatted
        chr(10)
    .
    put stream stmXMLLog unformatted
        ( if v-log-level = 0
          or v-out-string = "&DLine"
          or v-out-string = "&Line"
          then ""
          else cur-time-string-sec() + " " )
    .
    put stream stmXMLLog unformatted
        ( if v-out-string = "&Line"
          then fill( "-", 80 )
          else if v-out-string = "&DLine"
               then fill( "=", 80 )
               else v-out-string )
    .
    output stream stmXMLLog close.
end.
end procedure.
procedure bgelib-write-edt:
do
on error undo, return error
:
define input parameter v-editor-handle    as handle       no-undo.
define input parameter v-log-level        as integer      no-undo.
define input parameter v-out-string       as character    no-undo.
    if valid-handle ( v-editor-handle )
    then do:
        v-editor-handle :move-to-eof().
        v-editor-handle :insert-string( ( if v-log-level = 0
                                          or v-out-string = "&DLine"
                                          or v-out-string = "&Line"
                                          then ""
                                          else cur-time-string-sec() + " "
                                      ) ).
        v-editor-handle :insert-string( ( if v-out-string = "&Line"
                                          then fill( "-", 80 )
                                          else if v-out-string = "&DLine" then fill("=", 80)
                                          else fill( " ", v-log-level) + v-out-string
                                      ) ).
        v-editor-handle :insert-string( chr(10) ).
    end.
    process events.
    output to 'bgescn.txt' append.
        put unformatted
            chr(10)
            string( ( if v-log-level = 0
                      or v-out-string = "&DLine"
                      or v-out-string = "&Line"
                      then ""
                      else string( today ) + " " + string( time, "hh:mm:ss" ) + " "
                  ) )
            string( ( if v-out-string = "&Line"
                      then fill( "-", 80 )
                      else if v-out-string = "&DLine"
                           then fill( "=", 80 )
                           else fill( " ", v-log-level ) + v-out-string
                  ) )
        .
    output close.
end.
end procedure.
procedure bgelib-show-cnt:
do
on error undo, return error
:
define input parameter v-fillin-handle     as handle   no-undo.
    if valid-handle( v-fillin-handle )
    then do:
        assign
            v-fillin-handle :visible = true
        .
    end.
end.
end procedure.
procedure bgelib-hide-cnt:
do
on error undo, return error
:
define input parameter v-fillin-handle     as handle   no-undo.
    if valid-handle( v-fillin-handle )
    then do:
        assign v-fillin-handle :visible = false.
    end.
end.
end procedure.
procedure bgelib-write-cnt:
do
on error undo, return error
:
define input parameter v-fillin-handle    as handle       no-undo.
define input parameter v-fillin-string    as character    no-undo.
    if valid-handle( v-fillin-handle )
    then do:
        assign
            v-fillin-handle :SCREEN-value = v-fillin-string
        .
    end.
end.
end procedure.
procedure bgelib-write-header:
do
on error undo, return error
:
define input parameter p-first-file     as logical      no-undo.
define input parameter p-xml-file-name  as character    no-undo.
define input parameter p-list-file-name as character    no-undo.
define input parameter p-file-number    as integer      no-undo.
define input parameter p-have-prev      as logical      no-undo.
define input parameter p-prev-filename  as character    no-undo.
define input parameter p-obj-list       as character    no-undo.
define input parameter p-doc-type-list  as character    no-undo.
define input parameter p-parameter-list as character    no-undo.
    define variable v-counter    as integer        no-undo.
    output stream stmXMLOut to value( p-xml-file-name + "tmp" ) convert target "1251" append.
    put stream stmXMLOut unformatted
        "<?xml version='1.0' encoding='windows-1251'?>"
    .
    run bgelib-tag-open( input 0, input "root"  , input "" ).
    run bgelib-tag-open( input 0, input "header", input "" ).
    run bgelib-tag-put( input 1, input "fileName"       , input p-xml-file-name + "xml":U  , input 0 ).
    run bgelib-tag-put( input 1, input "fileNumber"     , input string( p-file-number     ), input 0 ).
    run bgelib-tag-put( input 1, input "havePrev"       , input string( p-have-prev       ), input 3 ).
    run bgelib-tag-put( input 1, input "prevFileName"   , input p-prev-filename            , input 0 ).
    run bgelib-tag-put( input 1, input "objList"        , input p-obj-list                 , input 0 ).
    run bgelib-tag-put( input 1, input "docTypeList"    , input p-doc-type-list            , input 0 ).
    do v-counter = 1 to integer( entry( 1, p-parameter-list ) )
    :
        run bgelib-tag-put(
              input 1
            , input entry( 2 * v-counter, p-parameter-list )
            , input entry( 2 * v-counter + 1, p-parameter-list )
            , input 0
        ).
    end.
    run bgelib-tag-close( input 0, input "header" ).
    output stream stmXMLOut close.
    output stream stmXMLOut to value( p-list-file-name + "tmp" ) convert target "1251" append.
    if p-first-file = yes
    then do:
        put stream stmXMLOut unformatted
            "<?xml version='1.0' encoding='windows-1251'?>"
        .
        run bgelib-tag-open( input 0, input "export", input "" ).
    end.
    run bgelib-tag-open( input 1, input "file", input "" ).
    run bgelib-tag-put( input 2, input "fileName"       , input p-xml-file-name + "xml":U  , input 0 ).
    run bgelib-tag-put( input 2, input "fileNumber"     , input string( p-file-number     ), input 0 ).
    run bgelib-tag-put( input 2, input "havePrev"       , input string( p-have-prev       ), input 3 ).
    run bgelib-tag-put( input 2, input "prevFileName"   , input p-prev-filename            , input 0 ).
    run bgelib-tag-put( input 2, input "objList"        , input p-obj-list                 , input 0 ).
    run bgelib-tag-put( input 2, input "docTypeList"    , input p-doc-type-list            , input 0 ).
    do v-counter = 1 to integer( entry( 1, p-parameter-list ) )
    :
        run bgelib-tag-put(
              input 2
            , input trim(entry( 2 * v-counter, p-parameter-list ))
            , input trim(entry( 2 * v-counter + 1, p-parameter-list ))
            , input 0
        ).
    end.
    run bgelib-tag-close( input 1, input "file" ).
    output stream stmXMLOut close.
end.
end procedure.
procedure bgelib-write-footer:
do
on error undo, return error
:
define input parameter p-last-file      as logical      no-undo.
define input parameter p-xml-file-name  as character    no-undo.
define input parameter p-list-file-name as character    no-undo.
define input parameter p-have-next      as logical      no-undo.
define input parameter p-next-file-name as character    no-undo.
    define variable v-error-num     as integer           no-undo.
    output stream stmXMLOut to value( p-xml-file-name + "tmp" ) convert target "1251" append.
    if p-have-next = yes
    then do:
        run bgelib-tag-open( input 0, input "footer", "" ).
        run bgelib-tag-put( input 1, input "haveNext"       , string( p-have-next ) , 3 ).
        run bgelib-tag-put( input 1, input "nextFileName"   , p-next-file-name      , 0 ).
        run bgelib-tag-close( input 0, input "footer" ).
    end.
    run bgelib-tag-close( input 0, input "root" ).
    output stream stmXMLOut close.
    run bge/os_copy.p (
          input "M"
        , input p-xml-file-name + "tmp"
        , input p-xml-file-name + "xml"
        , output v-error-num
    ).
    if p-last-file = yes
    then do:
        output stream stmXMLOut to value( p-list-file-name + "tmp" ) convert target "1251" append.
            run bgelib-tag-close( input 0, input "export" ).
        output stream stmXMLOut close.
        run bge/os_copy.p (
              input "M"
            , input p-list-file-name + "tmp"
            , input p-list-file-name + "xml"
            , output v-error-num
        ).
    end.
end.
end procedure.
procedure bgelib-filename :
do
on error undo, return error
:
define input parameter p-prefix             as character    no-undo.
define output parameter p-xml-file-name     as character    no-undo.
define output parameter p-log-file-name     as character    no-undo.
define output parameter p-list-file-name    as character    no-undo.
    define variable v-home-dir  as character    no-undo.
    define variable v-error-num as integer      no-undo.
    get-key-value section "BGE" key "outdir" value v-home-dir.
    if v-home-dir = ?
    then do:
        message
          skip "Не найден параметр ini-файла, определяющий каталог экспорта."
          skip(1)
          skip "Обратитесь к администратору."
        view-as alert-box error.
        undo, return error .
    end.
    run gbl/dir-cre.p (
        input v-home-dir
    ) no-error.
    if error-status :error
    then do:
        message
          skip "Неверно задан каталог экспорта."
          skip(1)
          skip "Обратитесь к администратору."
        view-as alert-box error.
        undo, return error .
    end.
    run bge/genfname.p (
          input v-home-dir
        , input p-prefix
        , input ""
        , input "xml"
        , input "tmp"
        , output p-xml-file-name
    ).
    assign
        p-xml-file-name     = substring( p-xml-file-name, 1, length( p-xml-file-name ) - 3 )
        p-log-file-name     = v-home-dir + chr(92) + "actions.log"
        p-list-file-name    = v-home-dir + chr(92) + "lst":U + substring( p-xml-file-name, length( p-xml-file-name ) - 5, 5 ) + ".":U
    .
end.
end procedure.
procedure bgelib-read-config :
do
on error undo, return error
:
define variable v-par-type as character     no-undo.
  define variable v-param-type      as character  no-undo .
  define variable v-value-character as character  no-undo .
  define variable v-value-date      as date       no-undo .
  define variable v-value-decimal   as decimal    no-undo .
  define variable v-value-integer   as integer    no-undo .
  define variable v-value-logical   as logical    no-undo .
  define variable v-tth             as handle     no-undo .
    assign
        v-bgelib-bgeclall = no
        v-bgelib-bgedict  = no
    .
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  'bge-export':U
                      , input  'bgeclall':U
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-bgelib-bgeclall = no
      .
    end.
    else do:
      assign
        v-bgelib-bgeclall = v-value-logical
      .
    end.
    delete object v-tth.
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  'bge-export':U
                      , input  'bgedict':U
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-bgelib-bgedict = no
      .
    end.
    else do:
      assign
        v-bgelib-bgedict = v-value-logical
      .
    end.
    delete object v-tth.
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  'bge-export':U
                      , input  'bgefmt':U
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-bgelib-bgefmt  = "xml":U
      .
    end.
    else do:
      assign
        v-bgelib-bgefmt  = v-value-character
      .
    end.
    delete object v-tth.
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  'bge-export':U
                      , input  'bgeflold':U
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-bgelib-bgeflold  = "old":U
      .
    end.
    else do:
      assign
        v-bgelib-bgeflold  = v-value-character
      .
    end.
    delete object v-tth.
end.
end procedure.
procedure bgelib-check-file-size :
do
on error undo, return error
:
define input parameter p-out-filename   as character    no-undo.
define output parameter p-is-big        as logical      no-undo.
    define variable v-current-position    as integer        no-undo.
    assign
        v-current-position = seek( stmXMLOut )
    .
    if v-current-position / 1024 / 1024  >= 100
    then do:
        assign
            p-is-big = yes
        .
    end.
end.
end procedure.
procedure bgelib-init-ext-doc-type :
    define variable v-counter    as integer      no-undo.
    define buffer buf_temp_ext-doc-type     for temp_ext-doc-type.
do
for buf_temp_ext-doc-type
on error undo, return error
:
    empty temp-table buf_temp_ext-doc-type.
    do v-counter = 1 to num-entries( 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U )
    :
        create buf_temp_ext-doc-type.
        assign
            buf_temp_ext-doc-type.edt-key               = v-counter
            buf_temp_ext-doc-type.ext-doc-type          = entry( v-counter, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U )
            buf_temp_ext-doc-type.ext-doc-type-label    = entry( v-counter, 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U )
        .
    end.
end.
end procedure.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-xml-file-name     as character            no-undo.
define variable v-xml-file-name-path as character            no-undo.
define variable v-log-file-name     as character            no-undo.
define variable v-locked            as logical              no-undo.
define variable v-log-string        as character            no-undo.
define variable v-oper-num          as integer              no-undo.
define variable v-obj-list          as character            no-undo.
DEF VAR strDummy    AS CHAR view-as editor size 50 by 4 NO-UNDO.
DEF VAR intRep      AS INT NO-UNDO.
define variable hEDT             AS HANDLE NO-UNDO.
define variable hCNT             AS HANDLE NO-UNDO.
procedure xml-cd-write-header:
do
on error undo, return error
:
define input parameter p-xml-file-name       as character    no-undo.
define input parameter p-xml-file-name-path  as character    no-undo.
define input parameter p-doc-name            as character    no-undo.
define input parameter p-version             as character    no-undo.
define input parameter p-obj-list            as character    no-undo.
define input parameter p-correspondent       as character    no-undo .
define input parameter p-write-header        as logical      no-undo .
define variable OS-time as character no-undo .
define variable id as character no-undo .
define buffer buf_db for ub.db.
output stream stmXMLOut to value( p-xml-file-name-path + "xm1":U ) convert target "1251" append.
put stream stmXMLOut unformatted "<?xml version='1.0' encoding='windows-1251'?>".
assign
OS-time =  string( ( today - date( "01/01/1996" ) ) * 24 * 3600 + time, ">>>>>>>>9" )
.
run bgelib-tag-open in this-procedure (
                                     1
                                    ,p-doc-name
                                    ,substitute("type='REQUEST' id='&1' from='&2' to='&3' tstamp='&4'", p-xml-file-name, p-obj-list, p-correspondent, OS-time )
                                      ).
if p-write-header then do:
  run bgelib-tag-open(2, "Header","").
  run bgelib-tag-put( 3, "DocumentName", p-doc-name, 1).
  run bgelib-tag-put( 3, "DateFormat", "DD.MM.YYYY":U, 1).
  run bgelib-tag-put( 3, "DocumentVersion", "1.02":U, 1).
  run bgelib-tag-put( 3, "DocumentVersionDate", "09.09.2004":U, 1).
  run bgelib-tag-put( 3, "ExportDate", string(today, "99.99.9999":U), 1).
  run bgelib-tag-put( 3, "ExportTime", string(time, "hh:mm:ss":U), 1).
  run bgelib-tag-put( 3, "objList",             p-obj-list                    , 1).
  find first buf_db where buf_db.db-num = g#db-num no-lock.
  run bgelib-tag-put( 3, "dbEncKey",            buf_db.db-key-enc, 1).
  run bgelib-tag-close( 2, "Header" ).
end.
output stream stmXMLOut close.
end.
end procedure.
procedure xml-cd-write-footer:
do
on error undo, return error
:
define input parameter p-pos-type      like ub.cash-desk.pos-type no-undo .
define input parameter p-xml-file-name as character    no-undo.
define input parameter p-doc-name      as character    no-undo .
define variable v-error-num     as integer           no-undo.
define variable v-md5-signature as character no-undo .
output stream stmXMLOut to value( p-xml-file-name + "xm1" ) convert target "1251" append.
run bgelib-tag-close( 0, p-doc-name ).
put stream stmXMLOut unformatted skip.
output stream stmXMLOut close.
run bge/os_copy.p ("M", p-xml-file-name + "xm1", p-xml-file-name + "xml", output v-error-num ).
if v-error-num > 0
then do:
   return error.
end.
if opsys = "unix"
then do:
    os-command silent chmod 666 value (p-xml-file-name + "xml") 2>/dev/null.
end.
end.
end procedure.
procedure xml-cd-filename :
do
on error undo, return error
:
define input parameter  p-out               as character no-undo .
define output parameter p-xml-file-name     as character    no-undo.
define output parameter p-xml-file-name-path   as character    no-undo.
define output parameter p-log-file-name     as character    no-undo.
define output parameter p-locked            as logical      no-undo.
define variable v-out as character     no-undo.
define variable loc#log as logical no-undo .
define variable BadFlag as logical no-undo .
define variable fq as integer no-undo .
define variable v-remote as character no-undo .
assign
p-xml-file-name = substring( string( next-value( s-spool, ub), '99999999999999999999'), 13, 8 )
p-xml-file-name-path = p-out + p-xml-file-name + ".":U
p-log-file-name = p-out + "actions.log"
p-locked = ( search ( p-xml-file-name-path + "lk" ) <> ? )
.
end.
end procedure.
FUNCTION Xml-CD-DatetoString returns character(input  p-date as date):
define variable v-date-str as character no-undo .
assign
v-date-str = string(YEAR(p-date), "9999":U) + "-":U +
             string(Month(p-date), "99":U) + "-":U +
             string(DAY(p-date), "99":U).
return v-date-str.
END FUNCTION.
FUNCTION Xml-CD-DateTimetoString returns character (input  p-date as date, p-time as integer):
define variable v-date-str as character no-undo .
assign
v-date-str = string(YEAR(p-date), "9999":U) + "-":U +
             string(Month(p-date), "99":U) + "-":U +
             string(DAY(p-date), "99":U) + chr(32) +
             string(p-time, "HH:MM:SS").
return v-date-str.
END FUNCTION.
function string-to-date returns date ( input p-string  as character):
  define variable v-date as date no-undo .
  assign
  v-date = date(integer(substring(p-string, 4, 2))
                ,integer(substring(p-string, 1, 2))
                ,integer(substring(p-string, 7, 4))
               ) no-error .
  if error-status:error then return ?.
  return v-date.
END FUNCTION.
FUNCTION string-IS0-8601-to-sec returns integer (input p-string-iso-8601 as character ):
define variable v-time as integer no-undo init ?.
define variable v-dop1 as character no-undo .
define variable v-dop2 as character no-undo .
assign
v-dop1 = entry(1, p-string-iso-8601, chr(32) )
v-dop2 = entry(2, p-string-iso-8601, chr(32) )
no-error .
if error-status:error then return ?.
assign
v-time =  integer(entry(1, v-dop2, ";":U)) * 3600 +
          integer(entry(2, v-dop2, ";":U)) * 60 +
          integer(entry(3, v-dop2, ";":U)) no-error .
return v-time.
END FUNCTION.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable fname                        as character      no-undo .
define variable out                          as character      no-undo .
define variable out2                          as character      no-undo .
DEFINE VARIABLE in_                          as character      no-undo .
DEFINE VARIABLE spl                          as character      no-undo .
DEFINE VARIABLE sav                          as character      no-undo .
DEFINE VARIABLE v-remote                     as character      no-undo .
DEFINE VARIABLE start-paket                  as logical init yes no-undo .
define variable cr as integer no-undo.
define variable Cash-OS2                    as logical        no-undo .
define variable Cash-DOS                     as logical        no-undo .
define variable BadFlag                      as logical        no-undo .
define variable os-er                        as integer        no-undo .
DEFINE VARIABLE OS2-time                     as character      no-undo .
define variable glog as logical no-undo .
define variable log-file-name                as character      no-undo init "send-cd.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable v-md5-signature              as character      no-undo .
define variable v-cd-list-update             as character no-undo .
define variable v-cd-list-delete             as character no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
define stream   IBMStream .
define temp-table temp-cd no-undo like ub.cash-desk .
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure alienini-getkey :
define input parameter i-filename as char.
define input parameter i-section as char.
define input parameter i-key as char.
define output parameter o-value as char.
define variable EntryPointer as integer no-undo.
define variable mem1 as memptr no-undo.
define variable mem2 as memptr no-undo.
define variable mem1size as integer no-undo.
define variable mem2size as integer no-undo.
define variable ii       as integer    no-undo.
define variable cbReturnSize  as integer    no-undo.
assign
set-size(mem1)  = 4000
mem1size = 4000.
if i-key = "" then EntryPointer = 0.
else do:
  assign
  set-size(mem2) = 128
  mem2size = 128
  EntryPointer = get-pointer-value(mem2)
  put-string(mem2, 1) = i-key.
end.
run getprivateprofilestringA
                              (i-section,
                               EntryPointer,
                               "",
                               get-pointer-value(mem1),
                               input mem1size,
                               i-filename,
                               output cbReturnSize).
do ii = 1 to cbReturnSize:
  o-value = if (get-byte(mem1, ii) = 0 and ii ne cbReturnSize)
               then o-value + ","
               else o-value + chr(get-byte(mem1, ii)).
end.
  set-size(mem1) = 0.
  set-size(mem2) = 0.
end procedure.
procedure alienini-putkey :
define input parameter i-filename as char.
define input parameter i-section as char.
define input parameter i-key as char.
define input parameter i-value as char.
define variable cbReturnSize as integer.
run writeprivateprofilestringA
                               (i-section,
                                i-key,
                                i-value,
                                i-filename,
                                output cbReturnSize ).
end procedure.
PROCEDURE GetPrivateProfileStringA EXTERNAL "kernel32" :
  DEFINE INPUT  PARAMETER lpszSection     AS CHAR.
  DEFINE INPUT  PARAMETER lpszEntry       AS LONG.
  DEFINE INPUT  PARAMETER lpszDefault     AS CHAR.
  DEFINE INPUT  PARAMETER memBuffer       AS LONG.
  DEFINE INPUT  PARAMETER cbReturnBuffer  AS LONG.
  DEFINE INPUT  PARAMETER lpszFilename    AS CHAR.
  DEFINE RETURN PARAMETER cbReturnedChars AS LONG.
END PROCEDURE.
PROCEDURE WritePrivateProfileStringA EXTERNAL "kernel32" :
  DEFINE INPUT  PARAMETER lpszSection  AS CHAR.
  DEFINE INPUT  PARAMETER lpszEntry    AS CHAR.
  DEFINE INPUT  PARAMETER lpszString   AS CHAR.
  DEFINE INPUT  PARAMETER lpszFilename AS CHAR.
  DEFINE RETURN PARAMETER lpszValue    AS LONG.
END PROCEDURE.
define   temp-table temp-tekka-tsk no-undo
field filename      as character
field obj-num       as integer
field obj-name      as character
field num-records   as integer
field max-records   as integer
field min-plu       as integer
field max-plu       as integer
field num-fields    as integer
field task-num      as character
field by-record     as logical
field send-get      as character
field cash-num      as integer
field cash-num-char as character
field port-num      as character
field way           as character
field is-script     as logical
field pswd          as character
field waiting-sek   as integer
field other-info    as character
field order-num     as integer
field secondary     as integer
field shift-fields  as integer
field binary        as logical
field range         as integer
index pi is unique primary
filename
range
index lpi
filename
min-plu
index gpi
filename
max-plu
index iorder
order-num
.
define   temp-table temp-tekka-schema no-undo
field obj-num as integer
field obj-name as character
field field-num as integer
field field-name as character
field num-records as integer
field size_ as integer
field host as character
field progress-type as character
field custom-type as character
field start-pos as integer
field end-pos as integer
field bin-group as character
index pi is unique primary
host obj-num field-num
.
define temp-table temp-tekka-record no-undo
field obj-num as integer
field plu as integer
field body as character
field shift as integer
index pi is unique primary obj-num plu.
FUNCTION tekka-is-closed-shift-journal returns integer ( input p-journal-num as integer ):
define variable v-is-closed-shift-journal as integer no-undo .
assign
v-is-closed-shift-journal = (if lookup( string( p-journal-num), '30,31,32,33':U) > 0 then 1 else 0)
                            +
                            (if lookup( string( p-journal-num),  '43':U) > 0 then 1 else 0)
                            +
                            (if lookup( string( p-journal-num),  '17':U) > 0 then 1 else 0)
.
return v-is-closed-shift-journal.
END FUNCTION.
FUNCTION tekka-is-first-journal returns logical ( input p-journal-num as integer ) :
define variable v-is-first-journal as logical no-undo .
assign
v-is-first-journal = (p-journal-num =  integer(entry(1, '30,31,32,33':U)))
                  or (p-journal-num = integer(entry(1, '26,27,28,29':U)))
                  or (p-journal-num =  integer(entry(1, '17':U)))
                  or (p-journal-num = integer(entry(1, '16':U)))
.
return v-is-first-journal.
END FUNCTION.
FUNCTION tekka-is-petrol-journal returns logical ( input p-journal-num as integer ) :
define variable v-is-petrol-journal as logical no-undo .
assign
v-is-petrol-journal = lookup(string(p-journal-num), '26,27,28,29,30,31,32,33':U) > 0.
return v-is-petrol-journal.
END FUNCTION.
FUNCTION tekka-get-max-journal-record-num returns integer ( input p-journal-num as integer ) :
define variable v-max-record-num as integer no-undo .
assign
v-max-record-num = (if lookup(string(p-journal-num), '26,27,28,29,30,31,32,33':U) > 0
                    then 1489
                    else 2340).
return v-max-record-num.
END FUNCTION.
FUNCTION tekka-get-max-record-num returns integer ( input p-journal-num as integer ) :
define variable v-max-record-num as integer no-undo .
assign
v-max-record-num = (if lookup(string(p-journal-num), '26,27,28,29,30,31,32,33':U) > 0
                    then 1489 * num-entries('30,31,32,33':U)
                    else 2340 * num-entries('17':U)).
return v-max-record-num.
END FUNCTION.
FUNCTION tekka-num-recs returns integer( input p-journal-num as integer
                                        ,input p-rec-no as integer):
define variable v-num-recs as integer no-undo .
if tekka-is-petrol-journal (p-journal-num) then do:
  if tekka-is-closed-shift-journal(p-journal-num) = 1 then do:
    assign
    v-num-recs = (p-journal-num - integer(entry(1, '30,31,32,33':U))) * 1489 + p-rec-no
    .
  end.
  else do:
    assign
    v-num-recs = (p-journal-num - integer(entry(1, '26,27,28,29':U)) ) * 1489 + p-rec-no
    .
  end.
end.
else do:
  if lookup(string(p-journal-num), '16,17':U) > 0 then do:
    if tekka-is-closed-shift-journal(p-journal-num) > 0 then do:
      assign
      v-num-recs = (p-journal-num - integer(entry(1, '17':U))) * 2340 + p-rec-no
      .
    end.
    else do:
      assign
      v-num-recs = (p-journal-num - integer(entry(1, '16':U)) ) * 2340 + p-rec-no
      .
    end.
  end.
  else do:
    if tekka-is-closed-shift-journal(p-journal-num) > 0 then do:
      assign
      v-num-recs = (p-journal-num - integer(entry(1, '43':U))) * 2978 + p-rec-no
      .
    end.
    else do:
      assign
      v-num-recs = (p-journal-num - integer(entry(1, '42':U)) ) * 2978 + p-rec-no
      .
    end.
  end.
end.
return v-num-recs.
END FUNCTION.
FUNCTION tekka-get-obj-num returns integer( input p-num-recs as decimal
                                           ,input p-is-petrol as logical
                                           ,input p-is-current as logical
                                           ,output p-rec-no as decimal
                                           ):
define variable v-obj-num0 as integer no-undo .
define variable v-obj-num as integer no-undo .
define variable v-obj-num2 as integer no-undo .
define variable p-num-recs2 as integer no-undo .
define variable p-rec-no2 as integer no-undo .
if p-is-petrol then do:
  assign
  v-obj-num0 = trunc(p-num-recs / 1489, 0)
  .
  if p-is-current and num-entries('26,27,28,29':U) >= v-obj-num0 + 1
  then
  assign
  v-obj-num = integer(entry(v-obj-num0 + 1, '26,27,28,29':U))
  p-rec-no = p-num-recs modulo 1489
  .
  if not p-is-current and num-entries('30,31,32,33':U) >= v-obj-num0 + 1
  then
  assign
  v-obj-num = integer(entry(v-obj-num0 + 1, '30,31,32,33':U))
  p-rec-no = p-num-recs modulo 1489
  .
end.
else do:
  assign
  p-num-recs2 = (p-num-recs - trunc(p-num-recs, 0)) * 10000
  p-num-recs = trunc(p-num-recs, 0)
  v-obj-num0 = trunc(p-num-recs / 2340, 0)
  v-obj-num2 = trunc(p-num-recs2 / 2978, 0)
  .
  if p-is-current and num-entries('16':U) >= v-obj-num0 + 1
  then
  assign
  v-obj-num = integer(entry(v-obj-num0 + 1, '16':U))
  p-rec-no = p-num-recs modulo 2340
  .
  if not p-is-current and num-entries('17':U) >= v-obj-num0 + 1
  then
  assign
  v-obj-num = integer(entry(v-obj-num0 + 1, '17':U))
  p-rec-no = p-num-recs modulo 2340
  .
  if p-is-current and num-entries('42':U) >= v-obj-num2 + 1
  then
  assign
  v-obj-num2 = integer(entry(v-obj-num2 + 1, '42':U))
  p-rec-no2 = p-num-recs2 modulo 2978
  .
  if not p-is-current and num-entries('43':U) >= v-obj-num2 + 1
  then
  assign
  v-obj-num2 = integer(entry(v-obj-num2 + 1, '43':U))
  p-rec-no2 = p-num-recs2 modulo 2978
  .
  assign
  p-rec-no = p-rec-no + p-rec-no2 / 10000
  .
end.
if v-obj-num = 0 then v-obj-num = 100.
return v-obj-num.
END FUNCTION.
FUNCTION tekka-get-next-obj-num returns integer ( input p-obj-num as integer, input p-is-ptrl as logical):
if lookup (string(p-obj-num), '30,31,32,33':U) > 0 then return integer(entry(1, '17':U)).
if lookup (string(p-obj-num), '17':U) > 0 then do:
   if p-is-ptrl then
   return integer(entry(1, '26,27,28,29':U)).
   if not p-is-ptrl then
   return integer(entry(1, '16':U)).
end.
if lookup (string(p-obj-num), '26,27,28,29':U) > 0 then return integer(entry(1, '16':U)).
if lookup (string(p-obj-num), '16':U) > 0 then return 100.
return 0.
END FUNCTION.
FUNCTION tekka-get-next-current-obj-num returns integer ( input p-obj-num as integer, input p-is-ptrl as logical ):
if lookup (string(p-obj-num), '30,31,32,33':U) > 0 then return integer(entry(1, '26,27,28,29':U)).
if lookup (string(p-obj-num), '17':U) > 0 then do:
  if p-is-ptrl then
  return integer(entry(1, '26,27,28,29':U)).
  if not p-is-ptrl then
  return integer(entry(1, '16':U)).
end.
if lookup (string(p-obj-num), '26,27,28,29':U) > 0 then return integer(entry(1, '16':U)).
if lookup (string(p-obj-num), '16':U) > 0 then return 100.
return 0.
END FUNCTION.
PROCEDURE maria-put:
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-out    as character no-undo .
define input parameter p-fname as character no-undo .
define input parameter p-by-record as logical no-undo .
define input parameter p-shift-fields as integer no-undo .
define input parameter p-binary as logical no-undo .
define input parameter p-obj-num as integer no-undo .
define input parameter p-max-records as integer no-undo .
define input parameter p-plu as integer no-undo .
define input parameter p-value as character no-undo .
define variable v-file-name as character no-undo .
define variable v-create as logical no-undo .
define buffer buf_temp-tekka-tsk for temp-tekka-tsk.
v-file-name =  p-out + p-fname + '.' + string(p-obj-num,  '999') .
output stream IBMSTREAM
to value(v-file-name) append .
Put  stream IBMSTREAM unformatted
p-plu
chr(3)
p-value
skip.
output stream IBMSTREAM
close.
if not p-by-record then do:
  find first buf_temp-tekka-tsk where
            buf_temp-tekka-tsk.filename  = v-file-name no-error .
  if not available buf_temp-tekka-tsk then do:
    v-create = yes.
  end.
end.
else do:
  find first buf_temp-tekka-tsk where
            buf_temp-tekka-tsk.filename  = v-file-name
        and buf_temp-tekka-tsk.max-plu = (p-plu - 1) use-index gpi no-error .
  if not available buf_temp-tekka-tsk
  then do:
    find first buf_temp-tekka-tsk where
              buf_temp-tekka-tsk.filename  = v-file-name
          and buf_temp-tekka-tsk.min-plu = (p-plu + 1) use-index lpi no-error .
    if not available buf_temp-tekka-tsk
    then do:
      v-create = yes.
    end.
  end.
end.
if v-create then do:
  create buf_temp-tekka-tsk.
  assign
  buf_temp-tekka-tsk.filename = v-file-name
  buf_temp-tekka-tsk.range    = p-plu
  buf_temp-tekka-tsk.obj-num = p-obj-num
  buf_temp-tekka-tsk.obj-name = '':U
  buf_temp-tekka-tsk.num-records = 0
  buf_temp-tekka-tsk.max-records = p-max-records
  buf_temp-tekka-tsk.num-fields = num-entries(p-value, chr(4) )
  buf_temp-tekka-tsk.task-num = p-fname
  buf_temp-tekka-tsk.by-record = p-by-record
  buf_temp-tekka-tsk.shift-fields = p-shift-fields
  buf_temp-tekka-tsk.binary = p-binary
  buf_temp-tekka-tsk.send-get = 'send'
  buf_temp-tekka-tsk.cash-num = BUF_CASH-DESK.cash-num
  buf_temp-tekka-tsk.cash-num-char = entry(3, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.port-num = entry(2, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.way = if entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'remote'
                        then entry(2, entry(2, BUF_CASH-DESK.addr-path, chr(4)), '+')
                        else (if entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'shared'
                              then 'local'
                              else entry(1, BUF_CASH-DESK.addr-path, chr(4)))
  buf_temp-tekka-tsk.is-script = (entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'shared')
  buf_temp-tekka-tsk.pswd = entry(4, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.waiting-sek = 30
  buf_temp-tekka-tsk.min-plu     = p-plu
  buf_temp-tekka-tsk.max-plu     = p-plu
  .
end.
assign
buf_temp-tekka-tsk.num-records = buf_temp-tekka-tsk.num-records + 1
buf_temp-tekka-tsk.min-plu     = minimum(buf_temp-tekka-tsk.min-plu, p-plu)
buf_temp-tekka-tsk.max-plu     = maximum(buf_temp-tekka-tsk.max-plu, p-plu)
.
END PROCEDURE.
PROCEDURE maria-get:
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-out    as character no-undo .
define input parameter p-fname as character no-undo .
define input parameter p-by-record as logical no-undo .
define input parameter p-obj-num as integer no-undo .
define input parameter p-num-fields as integer no-undo .
define input parameter p-max-records as integer no-undo .
define input parameter p-min-plu as integer no-undo .
define input parameter p-max-plu as integer no-undo .
define input parameter p-other as character no-undo .
define input parameter p-order-num as integer no-undo .
define variable v-file-name as character no-undo .
define variable v-secondary-obj-num as character no-undo .
define buffer buf_temp-tekka-tsk for temp-tekka-tsk.
if p-by-record then do:
  v-file-name =  p-out + p-fname + '-' + string(buf_cash-desk.cash-num) + '.' + string(p-obj-num,  '999') .
end.
else do:
  v-file-name =  p-out + p-fname + '-' + string(buf_cash-desk.cash-num) + '_html.' + string(p-obj-num,  '999').
end.
find first buf_temp-tekka-tsk where
          buf_temp-tekka-tsk.filename  = v-file-name no-error .
if not available buf_temp-tekka-tsk then do:
  create buf_temp-tekka-tsk.
  assign
  buf_temp-tekka-tsk.filename = v-file-name
  buf_temp-tekka-tsk.obj-num = p-obj-num
  buf_temp-tekka-tsk.obj-name = '':U
  buf_temp-tekka-tsk.max-records = p-max-records
  buf_temp-tekka-tsk.num-fields = p-num-fields
  buf_temp-tekka-tsk.task-num = p-fname
  buf_temp-tekka-tsk.by-record = p-by-record
  buf_temp-tekka-tsk.send-get = 'get'
  buf_temp-tekka-tsk.cash-num = BUF_CASH-DESK.cash-num
  buf_temp-tekka-tsk.cash-num-char = entry(3, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.port-num = entry(2, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.way = if entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'remote'
                          then entry(2, entry(2, BUF_CASH-DESK.addr-path, chr(4)), '+')
                          else (if entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'shared'
                                then 'local'
                                else entry(1, BUF_CASH-DESK.addr-path, chr(4)))
  buf_temp-tekka-tsk.is-script = (entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'shared')
  buf_temp-tekka-tsk.pswd = entry(4, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.waiting-sek = 30
  buf_temp-tekka-tsk.min-plu     = p-min-plu
  buf_temp-tekka-tsk.max-plu     = p-max-plu
  buf_temp-tekka-tsk.num-records = (if p-min-plu <> ?
                                    and p-max-plu <> ?
                                    then p-max-plu - p-min-plu + 1
                                    else 0)
  buf_temp-tekka-tsk.other-info = p-other
  buf_temp-tekka-tsk.order-num = p-order-num
  .
  if index('16-42,17-43,':U, string(buf_temp-tekka-tsk.obj-num) + '-') > 0 then do:
    assign
    v-secondary-obj-num =  substring('16-42,17-43,':U, index('16-42,17-43,':U, string(buf_temp-tekka-tsk.obj-num) + '-'))
    v-secondary-obj-num = entry(2, v-secondary-obj-num, '-':U)
    v-secondary-obj-num = entry(1, v-secondary-obj-num)
    no-error
    .
    buf_temp-tekka-tsk.secondary = integer(v-secondary-obj-num).
  end.
end.
END PROCEDURE.
PROCEDURE maria-task:
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-fname as character no-undo .
define input parameter p-obj-num-list as character no-undo .
define input parameter p-parameters as character no-undo .
define buffer buf_temp-tekka-tsk for temp-tekka-tsk.
find first buf_temp-tekka-tsk where
          buf_temp-tekka-tsk.task-num  = p-fname no-error .
if not available buf_temp-tekka-tsk then do:
  create buf_temp-tekka-tsk.
  assign
  buf_temp-tekka-tsk.filename = ''
  buf_temp-tekka-tsk.range = 1
  buf_temp-tekka-tsk.obj-num = 0
  buf_temp-tekka-tsk.obj-name = p-obj-num-list
  buf_temp-tekka-tsk.task-num = p-fname
  buf_temp-tekka-tsk.by-record = no
  buf_temp-tekka-tsk.send-get = 'task'
  buf_temp-tekka-tsk.cash-num = BUF_CASH-DESK.cash-num
  buf_temp-tekka-tsk.cash-num-char = entry(3, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.port-num = entry(2, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.way = if entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'remote'
                          then entry(2, entry(2, BUF_CASH-DESK.addr-path, chr(4)), '+')
                          else (if entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'shared'
                                then 'local'
                                else entry(1, BUF_CASH-DESK.addr-path, chr(4)))
  buf_temp-tekka-tsk.is-script = (entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'shared')
  buf_temp-tekka-tsk.pswd = entry(4, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.waiting-sek = 30
  buf_temp-tekka-tsk.other-info = p-parameters
  buf_temp-tekka-tsk.order-num = 0
  .
end.
END PROCEDURE.
procedure tekkatsk-verify-schema :
define input parameter p-obj-list as character no-undo .
define input parameter p-dir-path as character no-undo .
define variable v-obj-num as integer no-undo .
define variable v-obj-name as character no-undo .
define variable v-num-records as integer no-undo .
define variable v-size_ as integer no-undo .
define variable v-value as character no-undo .
define variable ii as integer no-undo .
define variable jj as integer no-undo .
define variable ii-ibs as integer no-undo .
define variable ii-tekka as integer no-undo .
define variable v-result as character no-undo .
define buffer buf_temp-tekka-schema for temp-tekka-schema.
define buffer buf2_temp-tekka-schema for temp-tekka-schema.
  do
  on error undo, return error
  :
     for each buf_temp-tekka-schema:
       delete buf_temp-tekka-schema.
     end.
     input from value('tekkasch.d').
     repeat :
       create buf_temp-tekka-schema.
       import buf_temp-tekka-schema.
       assign
       buf_temp-tekka-schema.host = 'IBS'
       ii = ii + 1.
       .
     end.
     input close.
     ii-ibs = ii.
      _ii:
      do ii = 1 to 256:
        if p-obj-list = "ALL"
        or lookup(string(ii), p-obj-list) > 0 then do:
          assign
          v-obj-num = 0
          v-obj-name = ''
          v-num-records = 0
          v-size_ = 0
          .
          run alienini-getkey in this-procedure (
                                                   input (trim(p-dir-path, chr(92)) + chr(92) + 'datastru.ini')
                                                  ,input ('obj' + string(ii, '999'))
                                                  ,input 'oname'
                                                  ,output v-value) no-error .
          if v-value = ? then next _ii.
          assign
          v-obj-num = ii
          v-obj-name = v-value
          .
          run alienini-getkey in this-procedure (
                                                   input (trim(p-dir-path, chr(92)) + chr(92) + 'datastru.ini')
                                                  ,input ('obj' + string(ii, '999'))
                                                  ,input 'size'
                                                  ,output v-value) no-error .
          assign
          v-num-records = integer(v-value) no-error  .
          if error-status:error
          or v-num-records = 0 then next _ii.
          run alienini-getkey in this-procedure (
                                                   input  (trim(p-dir-path, chr(92)) + chr(92) + 'datastru.ini')
                                                  ,input 'obj' + string(ii, '999')
                                                  ,input 'f000'
                                                  ,output v-value) no-error .
          assign
          v-size_ = integer(v-value) no-error  .
          if error-status:error
          or v-size_ = 0 then next _ii.
          _jj:
          do jj = 1 to 256:
            run alienini-getkey in this-procedure (
                                                     input (trim(p-dir-path, chr(92)) + chr(92) + 'datastru.ini')
                                                    ,input 'obj' + string(ii, '999')
                                                    ,input 'f' + string(jj, '999')
                                                    ,output v-value) no-error .
            if v-value = ? then next _ii.
            create buf_temp-tekka-schema.
            assign
            buf_temp-tekka-schema.host = 'tekka'
            buf_temp-tekka-schema.obj-num = v-obj-num
            buf_temp-tekka-schema.obj-name = v-obj-name
            buf_temp-tekka-schema.num-records = v-num-records
            buf_temp-tekka-schema.size_ = v-size_
            buf_temp-tekka-schema.field-num = jj
            buf_temp-tekka-schema.custom-type = entry(1, entry(2, v-value, '#'), ':')
            buf_temp-tekka-schema.bin-group = (if num-entries(entry(2, v-value, '#'), ':') > 1
                                               then entry(2, entry(2, v-value, '#'), ':')
                                               else '':U)
            buf_temp-tekka-schema.start-pos = integer(entry(1, entry(1, v-value, '#'), '-'))
            buf_temp-tekka-schema.end-pos = integer(entry(2, entry(1, v-value, '#'), '-'))
            buf_temp-tekka-schema.progress-type = entry( LOOKUP(buf_temp-tekka-schema.custom-type, 'Sx,B,BF,BN,UI,UL,FL,SL,VL':U)
                                                        , 'C,I,I,I,D,D,D,D,D':U)
            no-error
            .
            if error-status:error then do:
              delete buf_temp-tekka-schema.
              next _jj.
            end.
            run alienini-getkey in this-procedure (
                                                    input (trim(p-dir-path, chr(92)) + chr(92) + 'datastru.ini')
                                                    ,input 'obj' + string(ii, '999') + 'name'
                                                    ,input 'n' + string(jj, '999')
                                                    ,output v-value) no-error .
            if v-value <> ? then
            buf_temp-tekka-schema.field-name = v-value.
          end.
        end.
      end.
      ii-tekka = ii - 1.
     if p-obj-list <> 'ALL' then do:
      if ii-tekka <> ii-ibs then do:
        return error substitute("Несовпадание структур данных для ТЭККА:&1по данным IBS &1 объектов&1по даным OLE-сервера &2"
                                , ii-ibs
                                , ii-tekka).
      end.
     end.
     for each buf_temp-tekka-schema where
            buf_temp-tekka-schema.host = 'tekka':
       find first buf2_temp-tekka-schema where
                 buf2_temp-tekka-schema.obj-num = buf_temp-tekka-schema.obj-num
             AND buf2_temp-tekka-schema.host = 'ibs'
             AND buf2_temp-tekka-schema.field-num = buf_temp-tekka-schema.field-num no-error .
       if not available buf2_temp-tekka-schema then do:
        return error substitute("Несовпадание структур данных для ТЭККА:&1по данным IBS нет поля &1 для объекта &2"
                                , buf_temp-tekka-schema.field-num
                                , buf_temp-tekka-schema.obj-num).
       end.
       buffer-compare buf_temp-tekka-schema
       to buf2_temp-tekka-schema
       save result in v-result.
       if v-result <> '':U then do:
        return error substitute("Несовпадание структур данных для ТЭККА:&1по данным IBS для поля &1 объекта &2"
                                , buf_temp-tekka-schema.field-num
                                , buf_temp-tekka-schema.obj-num).
       end.
     end.
  end.
end procedure.
FUNCTION set-Sx returns character (input p-string as character):
return p-string.
END FUNCTION.
FUNCTION get-Sx returns character (input p-string  as character):
return p-string.
END FUNCTION.
FUNCTION set-B returns character (input p-string  as character):
return chr(integer(p-string)).
END FUNCTION.
FUNCTION get-B returns character (input p-string  as character):
return string(asc(p-string)).
END FUNCTION.
FUNCTION set-BF returns character (input p-string  as character):
define variable v-dopi as integer no-undo .
define variable ii as integer no-undo .
do ii = 1 to 8:
  put-bits(v-dopi, ii, 1) = integer(substring(p-string, 8 - ii + 1, 1)).
end.
return chr(v-dopi).
END FUNCTION.
FUNCTION get-BF returns character (input p-string  as character):
define variable v-dopi as integer no-undo .
define variable v-dops as character no-undo .
define variable ii as integer no-undo .
v-dopi = asc(p-string).
do ii = 8 to 1 BY -1:
  v-dops = v-dops + string(get-bits(v-dopi, ii, 1) ).
end.
return v-dops.
END FUNCTION.
FUNCTION set-BN returns character (input p-string  as character
                                  ,input p-bin-group as character):
define variable v-dopi as integer no-undo .
define variable ii as integer no-undo .
define variable jj as integer no-undo .
define variable v-grp-nums as integer no-undo .
define variable v-dopi2 as integer no-undo .
v-grp-nums = num-entries(p-bin-group).
do jj = 0 to v-grp-nums - 1:
  v-dopi2 = integer(substring(p-string, jj + 1, 3)).
  do ii = 1 to 8:
    put-bits(v-dopi, ii, 1) = integer(substring(p-string, 8 - ii + 1, 1)).
  end.
end.
return chr(v-dopi).
END FUNCTION.
FUNCTION get-BN returns character (input p-string  as character
                                  ,input p-bin-group as character):
define variable v-dopi as integer no-undo .
define variable v-dops as character no-undo .
define variable v-grp-nums as integer no-undo .
define variable ii as integer no-undo .
define variable jj as integer no-undo .
v-dopi = asc(p-string).
v-grp-nums = num-entries(p-bin-group).
do jj = 1 to v-grp-nums:
do ii = 8 to 1 BY -1:
  v-dops = v-dops + string(get-bits(v-dopi, ii, 1) ).
end.
end.
return v-dops.
END FUNCTION.
procedure fill-temp-cd :
define input parameter p-db-num   like ub.cash-desk.db-num no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-clear-table as logical no-undo .
define buffer buf_temp-cd for temp-cd.
define buffer buf_cash-desk for ub.cash-desk.
  do
  on error undo, return error
  :
     if p-clear-table  then do:
       for each buf_temp-cd:
         delete buf_temp-cd.
       end.
     end.
     for each buf_cash-desk no-lock where
            buf_cash-desk.db-num = p-db-num
        AND buf_cash-desk.obj-code = p-obj-code
        and buf_cash-desk.cash-on  = yes
     BREAK by buf_cash-desk.pos-type:
       if first-of(buf_cash-desk.pos-type) then do:
         create buf_temp-cd.
         buffer-copy buf_cash-desk to buf_temp-cd.
       end.
     end.
  end.
end procedure.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function windows-date-format returns character ( input p-date  as date, input p-format as character ):
define variable v-string-date as character no-undo .
CASE p-format:
  when "dd.mm.yyyy":U
  or
  when "dd.mm.yy":U
  or
  when "dd/mm/yy":U
  then do:
    assign
    p-format = replace(p-format, "dd", "99")
    p-format = replace(p-format, "mm", "99")
    p-format = replace(p-format, "yy", "99")
    v-string-date = string(p-date, p-format)
    .
  end.
  when "d.m.yy":U then do:
    ASSIGN
    v-string-date = string(day(p-date), ">9") + string(month(p-date), ">9") +
                    substring(string(p-date, "99/99/99"), 7, 2)
    .
  end.
  when "yyyy-mm-dd":U then do:
    ASSIGN
    v-string-date = string(year(p-date), "9999") + "-":U + string(month(p-date), "99") + string(day(p-date), "99")
    .
  end.
END CASE.
return v-string-date.
END FUNCTION.
def var vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure clntattr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-code in g#attr-lib
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
procedure clntattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-tooltip in g#attr-lib
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
procedure clntattr-value :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-value    like ub.clients-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-value in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
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
procedure clntattr-write :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.clients-attr.attr-value no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-write in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-exist :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-exist in g#attr-lib
      (input  p-obj-type
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
procedure clntattr-delete :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-delete in g#attr-lib
      (input  p-obj-type
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
procedure clntattr-copy-to :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-copy-to in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-auto-author-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-auto-author-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-by-type :
  define input  parameter p-archive-type      as character no-undo .
  define output parameter p-archive-attr-list as character no-undo .
  define variable vss-description as character no-undo initial "clntattr-get-archive-by-type-01: возвращает список атрибутов для складского архива".
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-by-type in g#attr-lib
      (input  p-archive-type
      ,output p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-vat-register :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-vat-register in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-requisite-alc-decl :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-requisite-alc-decl in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$".
define variable v-sum-id-c as character no-undo .
define variable v-sum-id as character no-undo .
define variable iid as integer no-undo .
define variable v-num-entries as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-sum-id-value as character no-undo .
define variable v-sum-id-output as logical no-undo .
define variable  v-property-value-chr as character no-undo .
define variable v-d-pcnt as decimal no-undo .
define variable v-cash-d-pcnt as decimal no-undo .
define variable v-categ as integer no-undo .
define variable v-d-pcnt0 as decimal no-undo .
define variable v-cash-d-pcnt0 as decimal no-undo .
define variable v-categ0 as integer no-undo .
define variable v-gds-code as integer no-undo .
define variable v-b-code as integer no-undo .
define temp-table temp-cd-clu no-undo like ub.cd-clu.
define buffer buf_dis-card-property for ub.dis-card-property.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cd-attr-code :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  define output parameter p-prop-list      as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-code in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ,output p-prop-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-tooltip :
  define input  parameter p-ucode   as character no-undo .
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-tooltip in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-value :
  define input  parameter p-db-num    like ub.cash-desk-attr.db-num        no-undo .
  define input  parameter p-obj-code  like ub.cash-desk-attr.obj-code      no-undo .
  define input  parameter p-pos-type  like ub.cash-desk-attr.pos-type      no-undo .
  define input  parameter p-cash-num  like ub.cash-desk-attr.cash-num      no-undo .
  define input  parameter p-ucode     like ub.cash-desk-attr.upper-attr-code      no-undo .
  define input  parameter p-code      like ub.cash-desk-attr.attr-code      no-undo .
  define output parameter p-character like ub.cash-desk-attr.attr-value-character    no-undo .
  define output parameter p-date      like ub.cash-desk-attr.attr-value-date         no-undo .
  define output parameter p-decimal   like ub.cash-desk-attr.attr-value-decimal      no-undo .
  define output parameter p-integer   like ub.cash-desk-attr.attr-value-integer      no-undo .
  define output parameter p-logical   like ub.cash-desk-attr.attr-value-logical      no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-value in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
      ,input  p-code
      ,output p-character
      ,output p-date
      ,output p-decimal
      ,output p-integer
      ,output p-logical
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-write :
  define input parameter p-db-num    like ub.cash-desk-attr.db-num     no-undo .
  define input parameter p-obj-code  like ub.cash-desk-attr.obj-code   no-undo .
  define input parameter p-pos-type  like ub.cash-desk-attr.pos-type   no-undo .
  define input parameter p-cash-num  like ub.cash-desk-attr.cash-num   no-undo .
  define input parameter p-ucode     like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input parameter p-code      like ub.cash-desk-attr.attr-code  no-undo .
  define input parameter p-character like ub.cash-desk-attr.attr-value-character no-undo .
  define input parameter p-date      like ub.cash-desk-attr.attr-value-date      no-undo .
  define input parameter p-decimal   like ub.cash-desk-attr.attr-value-decimal   no-undo .
  define input parameter p-integer   like ub.cash-desk-attr.attr-value-integer   no-undo .
  define input parameter p-logical   like ub.cash-desk-attr.attr-value-logical   no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-write in g#attr-lib
      (input p-db-num
      ,input p-obj-code
      ,input p-pos-type
      ,input p-cash-num
      ,input p-ucode
      ,input p-code
      ,input p-character
      ,input p-date
      ,input p-decimal
      ,input p-integer
      ,input p-logical
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-exist :
  define input  parameter p-db-num   like ub.cash-desk-attr.db-num     no-undo .
  define input  parameter p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
  define input  parameter p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
  define input  parameter p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
  define input  parameter p-ucode    like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input  parameter p-code     like ub.cash-desk-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-exist in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-delete :
  define input parameter  p-db-num   like ub.cash-desk-attr.db-num     no-undo .
  define input parameter  p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
  define input parameter  p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
  define input parameter  p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
  define input parameter  p-ucode     like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input parameter  p-code     like ub.cash-desk-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-delete in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-news :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  define output parameter p-from-gbd       as logical   no-undo .
  define output parameter p-from-ubd       as logical   no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-news in g#attr-lib
      (
       input  p-ucode
      ,input  p-code
      ,output p-news
      ,output p-from-gbd
      ,output p-from-ubd
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-hist :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-hist           as logical   no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-hist in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-hist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
function cd-attr-parse-date-time returns date
(input  p-string as character
,output p-time   as integer
):
  define variable v-return-value as date      no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-parse-date-time-proc in g#attr-lib
    (input  p-string
    ,output p-time
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    return ? .
  end.
  return v-return-value .
end function.
procedure last-check-date-time :
  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run last-check-date-time in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
function cd-attr-cd-datetostring returns character
(input  p-date as date
):
  define variable v-return-value as character no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-cd-datetostring-proc in g#attr-lib
    (input  p-date
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    return ? .
  end.
  return v-return-value .
end function.
procedure cd-attr-last-report-params :
  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-last-report-params in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-last-check-params :
  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-last-check-params in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-last-check-date-time :
  define input parameter parparentproc as widget-handle no-undo .
  define input  parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input  parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input  parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input  parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-last-check-maria in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-periodic-tasks :
define input  parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
define input  parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
define input  parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
define input  parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-periodic-tasks in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
function cd-attr_get-attr-int returns integer
(buffer buf_cash-desk for ub.cash-desk
,input p-upper-attr-code as character
,input p-attr-code as character
,output p-mes as character
):
  define variable v-return-value as integer   no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr_get-attr-int-proc in g#attr-lib
    (buffer buf_cash-desk
    ,input  p-upper-attr-code
    ,input  p-attr-code
    ,output p-mes
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    assign
      p-mes = substitute("Неизвестная ошибка при вызове процедуры cd-attr_get-attr-int-proc &1 &2"
                        ,error-status :get-message(1)
                        ,return-value
                        )
    .
    return ? .
  end.
  return v-return-value .
end function.
function cd-attr_get-attr-log returns logical
(buffer buf_cash-desk for ub.cash-desk
,input p-upper-attr-code as character
,input p-attr-code as character
,output p-mes as character
):
  define variable v-return-value as logical   no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr_get-attr-log-proc in g#attr-lib
    (buffer buf_cash-desk
    ,input  p-upper-attr-code
    ,input  p-attr-code
    ,output p-mes
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    assign
      p-mes = substitute("Неизвестная ошибка при вызове процедуры cd-attr_get-attr-log-proc &1 &2"
                        ,error-status :get-message(1)
                        ,return-value
                        )
    .
    return ? .
  end.
  return v-return-value .
end function.
procedure cd-attr_check-marketer :
  define input parameter p-db-num   like ub.cash-desk-attr.db-num     no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
  define input parameter p-ucode     like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input parameter p-code     like ub.cash-desk-attr.attr-code  no-undo .
  define input parameter p-value as character no-undo .
  define input parameter p-mode  as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr_check-marketer in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
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
procedure cd-attr-manual-edit :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-manual-edit in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-batch-edit :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-batch-edit in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-send-param :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-send-param     as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-send-param in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-send-param
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE cd-mrkt_plu-marketer :
define input parameter p-silence as logical no-undo .
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-id as character no-undo .
define input parameter p-b-code like ub.bar-code.b-code no-undo .
define input parameter p-b-str like ub.prod-bc.b-str no-undo .
define input parameter p-loc-ean as logical no-undo .
define input parameter p-is-petrolium as logical no-undo .
define input parameter p-extra as character no-undo .
define variable v-tot-gds as integer no-undo .
define variable v-max-gds as integer no-undo .
define variable v-petrol-start as integer no-undo .
define variable v-petrol-range as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-plu-type as character no-undo .
define variable v-int as integer no-undo .
define buffer  buf_cd-plu for ub.cd-plu.
define buffer  loc_cd-plu for ub.cd-plu.
define variable  ii as integer no-undo.
define variable v-mes as character no-undo .
_main:
DO ON ERROR undo, leave on stop undo, leave:
  if buf_cash-desk.pos-type <> 'MARIA':U
  or buf_cash-desk.cash-num <> 0 then do:
    assign
    v-mes =
    substitute("Товары на кассах можно определять только для кассовых менеджеров (номер кассы = 0) для типов касс &1"
              , buf_cash-desk.pos-type).
    if not p-silence then
    message
    v-mes
    view-as alert-box error .
    return error v-mes.
  end.
  v-tot-gds = cd-attr_get-attr-int(buffer buf_cash-desk
                                  ,input 'MARIA_operative':U
                                  ,input (if buf_cash-desk.pos-type = 'MARIA':U
                                        and p-is-petrolium
                                        then 'tot-petrol':U
                                        else 'tot-gds':U)
                                  , output v-mes).
  if v-tot-gds = ? then undo _main, return error v-mes.
  v-max-gds = cd-attr_get-attr-int(buffer buf_cash-desk
                                  ,input 'MARIA_general':U
                                  ,input 'max-gds':U
                                  ,output v-mes).
  if v-max-gds = ? then undo _main, return error v-mes.
  v-petrol-range = cd-attr_get-attr-int(buffer buf_cash-desk
                                       ,input 'petrolium-range':U
                                       ,input 'petrolium-range':U
                                       ,output v-mes).
  if v-petrol-range = ? then undo _main, return error v-mes.
  if buf_cash-desk.pos-type = 'MARIA':U then do:
    assign
    v-petrol-start = 1
    v-max-gds = (if p-is-petrolium
                 then v-petrol-range
                 else v-max-gds)
    v-plu-type = (if p-is-petrolium
               then 'топ':U
               else '':U)
    .
    if p-is-petrolium then do:
      if p-id = '':U then do:
        v-mes = substitute( "Топливо с кодом &1 не привязано к складскому месту&2" +
                            "Невозможно привязать к кассе типа &3"
                            , p-b-str
                            , chr(10)
                            , 'MARIA':U).
        if not p-silence then
        message
        v-mes
        view-as alert-box error .
        return error v-mes.
      end.
      assign
      v-int = integer(p-id)
      no-error
      .
      if error-status:error
      or v-int > v-petrol-range then do:
        v-mes = substitute( "№ резервуара &1 для топлива с кодом &1 не укладывается&3" +
                            "в диапазоны номеров резервуаров для кассы типа &4"
                            , p-id
                            , p-b-str
                            , chr(10)
                            , 'MARIA':U).
        if not p-silence then
        message
        v-mes
        view-as alert-box error .
        return error v-mes.
      end.
    end.
  end.
  if buf_cash-desk.pos-type = 'MARIA':U
  and p-is-petrolium then do:
    find first loc_cd-plu where
             loc_cd-plu.obj-type = 'маг':U
         and loc_cd-plu.obj-code = buf_cash-desk.obj-code
         and loc_cd-plu.pos-type = buf_cash-desk.pos-type
         and loc_cd-plu.plu-type = 'топ':U
   no-error .
   if available loc_cd-plu then do:
     if loc_cd-plu.b-code = p-b-code
     and loc_cd-plu.b-str = p-b-str then do:
        v-mes = substitute( "№ резервуара &1 на кассе УЖЕ привязан к топливу с кодом &1,&3"
                            , p-id
                            , p-b-str
                            , chr(10)
                            ).
        if not p-silence then
        message
        v-mes
        view-as alert-box WARNING .
        return v-mes.
     end.
     else do:
        v-mes = substitute( "№ резервуара &1 на кассе привязан к топливу с кодом &1,&3" +
                            "нельзя его привязать к топливу &2&3"
                            , p-id
                            , loc_cd-plu.b-str
                            , chr(10)
                            , p-b-str).
        if not p-silence then
        message
        v-mes
        view-as alert-box error .
        return error v-mes.
     end.
   end.
   ii = v-int.
  end.
  else do:
    DO ii = (if p-is-petrolium
            then v-petrol-start
            else (if buf_cash-desk.pos-type = 'MARIA':U
                 then 1
                 else (if v-petrol-start = 1
                        then (v-petrol-range + 1)
                        else 1)
                )
            )
      to v-max-gds :
      if not can-find (loc_cd-plu where
                      loc_cd-plu.obj-type = 'маг':U
                   and loc_cd-plu.obj-code =  buf_Cash-desk.obj-code
                   and loc_cd-plu.pos-type = buf_Cash-desk.pos-type
                   and loc_cd-plu.plu-type = v-plu-type
                   and loc_cd-plu.plu-code = ii
                    )
      then LEAVE .
    END .
  end.
  if ii > v-max-gds then do:
      if not p-silence then
      message
      substitute("Превышено максимально допустимое количество &5 &1" +
                "для касс &2 &3&4"
                , chr(10)
                , v-max-gds
                , 'маг':U
                , buf_cash-desk.obj-code
                , (if p-is-petrolium then "топлив" else "товаров")
                )
      view-as alert-box ERROR .
      undo, return error "max-gds":U.
  end.
  DO ii = (if p-is-petrolium
           then v-petrol-start
           else (if v-petrol-start = 1
                 then (v-petrol-range + 1)
                 else 1)
           )
     to v-max-gds :
    if not can-find (loc_cd-plu where
                      loc_cd-plu.obj-type = 'маг':U
                   and loc_cd-plu.obj-code =  buf_Cash-desk.obj-code
                   and loc_cd-plu.pos-type = buf_Cash-desk.pos-type
                   and loc_cd-plu.plu-type = v-plu-type
                   and loc_cd-plu.plu-code = ii
                   )
    then LEAVE .
  END .
  if ii > v-max-gds then do:
      if not p-silence then
      message
      substitute("Превышено максимально допустимое количество &5 &1" +
                "для касс &2 &3&4"
                , chr(10)
                , v-max-gds
                , 'маг':U
                , buf_cash-desk.obj-code
                , (if p-is-petrolium then "топлив" else "товаров")
                )
      view-as alert-box ERROR .
      undo, return error "max-gds":U.
  end.
  run cur-time in this-procedure ( output v-today, output v-time).
  create buf_cd-plu.
  assign
  buf_cd-plu.b-code = p-b-code
  buf_cd-plu.b-str = p-b-str
  buf_cd-plu.charkey_two = (if buf_cash-desk.pos-type = 'MARIA':U
                                      then buf_cash-desk.addr-path
                                      else "U":U)
  buf_cd-plu.to-send = yes
  buf_cd-plu.charkey_one = "":U
  buf_cd-plu.to-del = no
  buf_cd-plu.plu-code = ii
  buf_cd-plu.obj-type = 'маг':U
  buf_cd-plu.obj-code = buf_cash-desk.obj-code
  buf_cd-plu.pos-type = buf_cash-desk.pos-type
  buf_cd-plu.plu-type = v-plu-type
  buf_cd-plu.logkey_one = p-loc-ean
  buf_cd-plu.key#_one = integer(p-extra)
  .
  run cd-attr-write  in this-procedure (
                                        input   buf_cash-desk.db-num
                                        ,input  buf_cash-desk.obj-code
                                        ,input  buf_cash-desk.pos-type
                                        ,input  buf_cash-desk.cash-num
                                        ,input  substitute("&1_operative", buf_cash-desk.pos-type)
                                        ,input (if buf_cash-desk.pos-type = 'MARIA':U
                                              and p-is-petrolium
                                              then 'tot-petrol':U
                                              else 'tot-gds':U)
                                        ,input ''
                                        ,input ?
                                        ,input 0.0
                                        ,input  (v-tot-gds + 1)
                                        ,input no
                                       ) no-error .
  if error-status:error then do:
    v-mes = substitute("Ошибка при записи <текущее количество товаров на кассе> для кассы &1 &2&3:&4&5 &6"
                       ,buf_cash-desk.cash-num
                       , 'маг':U
                       ,buf_cash-desk.obj-code
                       , chr(10)
                       , error-status:get-message(1)
                       , return-value
                       ).
    if not p-silence then
    message
    v-mes
    view-as alert-box error .
    undo _main, return error v-mes.
  end.
  run cd-attr-write  in this-procedure (
                                        input   buf_cash-desk.db-num
                                        ,input  buf_cash-desk.obj-code
                                        ,input  buf_cash-desk.pos-type
                                        ,input  buf_cash-desk.cash-num
                                        ,input  'MARIA_operative':U
                                        ,input  'to-send':U
                                        ,input ''
                                        ,input ?
                                        ,input 0.0
                                        ,input 0
                                        ,input yes
                                       ) no-error .
  if error-status:error then do:
    v-mes = substitute("Ошибка при записи <Есть коды товаров, не отправленные на кассу> для кассы &1 &2&3:&4&5 &6"
                       ,buf_cash-desk.cash-num
                       , 'маг':U
                       ,buf_cash-desk.obj-code
                       , chr(10)
                       , error-status:get-message(1)
                       , return-value
                       ).
    if not p-silence then
    message
    v-mes
    view-as alert-box error .
    undo _main, return error v-mes.
  end.
  return "":U.
end.
END PROCEDURE.
procedure cd-mrkt_update-marketer :
define input parameter p-db-num   like ub.cash-desk-attr.db-num     no-undo .
define input parameter p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
define input parameter p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
define input parameter p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
define input parameter p-is-petrolium as logical no-undo .
define variable v-to-send as logical no-undo .
define variable v-tot-gds as integer no-undo .
define variable v-max-plu as integer no-undo .
define buffer buf_cd-plu for ub.cd-plu.
define variable v-plu-type as character no-undo .
  do
  on error undo, return error
  :
    v-to-send = no.
    v-tot-gds = 0.
    assign
    v-plu-type = (if p-is-petrolium
                  then  'топ':U
                  else '':U
              )
    .
    FOR EACH buf_cd-plu WHERE
           buf_cd-plu.obj-type = 'маг':U
      and  buf_cd-plu.obj-code = p-obj-code
      and  buf_cd-plu.pos-type = p-pos-type
      and  buf_cd-plu.plu-type = v-plu-type
          :
      if  buf_cd-plu.to-del
      or  buf_cd-plu.to-send then do:
        assign
        v-to-send = yes.
      end.
      assign
      v-tot-gds = v-tot-gds + 1.
    end.
    run cd-attr-write  in this-procedure (
                                            input   p-db-num
                                            ,input  p-obj-code
                                            ,input  p-pos-type
                                            ,input  p-cash-num
                                            ,input  'MARIA_operative':U
                                            ,input  (if p-pos-type = 'MARIA':U
                                                     and p-is-petrolium
                                                     then  'tot-petrol':U
                                                     else 'tot-gds':U)
                                            ,input ''
                                            ,input ?
                                            ,input 0.0
                                            ,input v-tot-gds
                                            ,input no
                                                                                        ) no-error .
    if error-status:error then do:
        UNDO, RETURN ERROR RETURN-VALUE.
    END.
    run cd-attr-write  in this-procedure (
                                            input   p-db-num
                                            ,input  p-obj-code
                                            ,input  p-pos-type
                                            ,input  p-cash-num
                                            ,input  'MARIA_operative':U
                                            ,input  (if p-pos-type = 'MARIA':U
                                                     and p-is-petrolium
                                                     then  'petrol-to-send':U
                                                     else 'to-send':U)
                                            ,input ''
                                            ,input ?
                                            ,input 0.0
                                            ,input 0
                                            ,input v-to-send
                                            ) no-error .
    if error-status:error then do:
        UNDO, RETURN ERROR RETURN-VALUE.
    END.
    FIND LAST buf_cd-plu NO-LOCK  WHERE
             buf_cd-plu.obj-type = 'маг':U
         and buf_cd-plu.obj-code = p-obj-code
         and buf_cd-plu.pos-type = p-pos-type
         and buf_cd-plu.plu-type = v-plu-type  use-index pi no-error .
    if available buf_cd-plu then do:
      if v-max-plu < buf_cd-plu.plu-code
      then
      v-max-plu = buf_cd-plu.plu-code .
    end.
    else do:
      v-max-plu = 0.
    end.
    run cd-attr-write  in this-procedure (
                                          input   p-db-num
                                          ,input  p-obj-code
                                          ,input  p-pos-type
                                          ,input  p-cash-num
                                          ,input  'MARIA_operative':U
                                          ,input  (if p-pos-type = 'MARIA':U
                                                  and p-is-petrolium
                                                  then 'max-petrol-plu':U
                                                  else 'max-plu':U)
                                            ,input ''
                                            ,input ?
                                            ,input 0.0
                                            ,input v-max-plu
                                            ,input no
                                          ) no-error .
    if error-status:error then do:
        UNDO, RETURN ERROR RETURN-VALUE.
    END.
  end.
end procedure.
PROCEDURE cd-mrkt_clu-marketer :
define input parameter p-silence as logical no-undo .
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define variable v-tot-cli as integer no-undo .
define variable v-max-cli as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer  buf_cd-clu for ub.cd-clu.
define buffer  loc_cd-clu for ub.cd-clu.
define variable  ii as integer no-undo.
define variable v-mes as character no-undo .
_main:
DO ON ERROR undo, leave on stop undo, leave:
  if buf_cash-desk.pos-type <> 'MARIA':U
  or buf_cash-desk.cash-num <> 0 then do:
    assign
    v-mes =
    substitute("Клиенты на кассах можно определять только для кассовых менеджеров (номер кассы = 0) для типов касс &1"
              , buf_cash-desk.pos-type).
    if not p-silence then
    message
    v-mes
    view-as alert-box error .
    return error v-mes.
  end.
  v-tot-cli = cd-attr_get-attr-int(buffer buf_cash-desk
                                  ,input 'MARIA_operative':U
                                  ,input 'tot-cli':U
                                  ,output v-mes).
  if v-tot-cli = ? then undo _main, return error v-mes.
  v-max-cli = cd-attr_get-attr-int(buffer buf_cash-desk
                                  ,input 'MARIA_general':U
                                  ,input 'max-cli':U
                                  , output v-mes).
  if v-max-cli = ? then undo _main, return error v-mes.
  DO ii = 1
     to v-max-cli :
    if not can-find (loc_cd-clu where
                    loc_cd-clu.obj-type = 'маг':U
                and loc_cd-clu.obj-code = buf_cash-desk.obj-code
                and loc_cd-clu.pos-type = buf_cash-desk.pos-type
                and loc_cd-clu.clu-type = '':U
                and loc_cd-clu.clu-code = ii
                   )
    then LEAVE .
  END .
  if ii > v-max-cli then do:
      if not p-silence then
      message
      substitute("Превышено максимально допустимое количество клиентов &1" +
                "для касс &2 &3&4"
                , chr(10)
                , v-max-cli
                , 'маг':U
                , buf_cash-desk.obj-code
                )
      view-as alert-box ERROR .
      undo, return error "max-cli":U.
  end.
  run cur-time in this-procedure ( output v-today, output v-time).
  create buf_cd-clu.
  assign
  buf_cd-clu.cli-code = p-obj-code
  buf_cd-clu.cli-type = p-obj-type
  buf_cd-clu.obj-type = 'маг':U
  buf_cd-clu.obj-code = buf_Cash-desk.obj-code
  buf_cd-clu.pos-type = buf_cash-desk.pos-type
  buf_cd-clu.clu-type = '':U
  buf_cd-clu.to-send = yes
  buf_cd-clu.charkey_two = (if buf_cash-desk.pos-type = 'MARIA':U
                            then buf_cash-desk.addr-path
                            else "U":U)
  buf_cd-clu.clu-code = ii
  .
  run cd-attr-write  in this-procedure (
                                        input   buf_cash-desk.db-num
                                        ,input  buf_cash-desk.obj-code
                                        ,input  buf_cash-desk.pos-type
                                        ,input  buf_cash-desk.cash-num
                                        ,input  'MARIA_operative':U
                                        ,input  'tot-cli':U
                                        ,input ''
                                        ,input ?
                                        ,input 0.0
                                        ,input  (v-tot-cli + 1)
                                        ,input no
                                       ) no-error .
  if error-status:error then do:
    v-mes = substitute("Ошибка при записи <текущее количество клиентов на кассе> для кассы &1 &2&3:&4&5 &6"
                       ,buf_cash-desk.cash-num
                       , 'маг':U
                       ,buf_cash-desk.obj-code
                       , chr(10)
                       , error-status:get-message(1)
                       , return-value
                       ).
    if not p-silence then
    message
    v-mes
    view-as alert-box error .
    undo _main, return error v-mes.
  end.
  run cd-attr-write  in this-procedure (
                                        input   buf_cash-desk.db-num
                                        ,input  buf_cash-desk.obj-code
                                        ,input  buf_cash-desk.pos-type
                                        ,input  buf_cash-desk.cash-num
                                        ,input  'MARIA_operative':U
                                        ,input  'cli-to-send':U
                                        ,input ''
                                        ,input ?
                                        ,input 0.0
                                        ,input 0
                                        ,input yes
                                       ) no-error .
  if error-status:error then do:
    v-mes = substitute("Ошибка при записи <Есть коды клиентов, не отправленные на кассу> для кассы &1 &2&3:&4&5 &6"
                       ,buf_cash-desk.cash-num
                       , 'маг':U
                       ,buf_cash-desk.obj-code
                       , chr(10)
                       , error-status:get-message(1)
                       , return-value
                       ).
    if not p-silence then
    message
    v-mes
    view-as alert-box error .
    undo _main, return error v-mes.
  end.
  return "":U.
end.
END PROCEDURE.
procedure cd-mrkt_update-marketer-cli :
define input parameter p-db-num   like ub.cash-desk-attr.db-num     no-undo .
define input parameter p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
define input parameter p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
define input parameter p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
define variable v-cli-to-send as logical no-undo .
define variable v-tot-cli as integer no-undo .
define variable v-max-clu as integer no-undo .
define buffer buf_cd-clu for ub.cd-clu.
do
on error undo, return error return-value
:
  v-cli-to-send = no.
  v-tot-cli = 0.
  FOR EACH buf_cd-clu WHERE
        buf_cd-clu.obj-type = 'маг':U
    and buf_cd-clu.obj-code =  p-obj-code
    and buf_cd-clu.pos-type =  p-pos-type
    and buf_cd-clu.clu-type =  '':U
    :
    if buf_cd-clu.to-del = yes then do:
      assign
      v-cli-to-send = yes.
    end.
    assign
    v-tot-cli = v-tot-cli + 1.
  end.
  run cd-attr-write  in this-procedure (
                                          input   p-db-num
                                          ,input  p-obj-code
                                          ,input  p-pos-type
                                          ,input  p-cash-num
                                          ,input  'MARIA_operative':U
                                          ,input  'tot-cli':U
                                          ,input ''
                                          ,input ?
                                          ,input 0.0
                                          ,input v-tot-cli
                                          ,input no
                                          ) no-error .
  if error-status:error then do:
      UNDO, RETURN ERROR RETURN-VALUE.
  END.
  run cd-attr-write  in this-procedure (
                                          input   p-db-num
                                          ,input  p-obj-code
                                          ,input  p-pos-type
                                          ,input  p-cash-num
                                          ,input  'MARIA_operative':U
                                          ,input  'cli-to-send':U
                                          ,input ''
                                          ,input ?
                                          ,input 0.0
                                          ,input 0
                                          ,input v-cli-to-send
                                          ) no-error .
  if error-status:error then do:
      UNDO, RETURN ERROR RETURN-VALUE.
  END.
  FIND LAST buf_cd-clu WHERE
          buf_cd-clu.obj-type = 'маг':U
      and buf_cd-clu.obj-code = p-obj-code
      and buf_cd-clu.pos-type = p-pos-type
      and buf_cd-clu.clu-type = '':U
      NO-LOCK use-index pi no-error .
  if available buf_cd-clu then do:
    if v-max-clu < buf_cd-clu.clu-code
    then
    v-max-clu = buf_cd-clu.clu-code.
  end.
  else do:
    v-max-clu = 0.
  end.
  run cd-attr-write  in this-procedure (
                                        input   p-db-num
                                        ,input  p-obj-code
                                        ,input  p-pos-type
                                        ,input  p-cash-num
                                        ,input  'MARIA_operative':U
                                        ,input  'max-clu':U
                                        ,input ''
                                        ,input ?
                                        ,input 0.0
                                        ,input v-max-clu
                                        ,input no
                                        ) no-error .
  if error-status:error then do:
      UNDO, RETURN ERROR RETURN-VALUE.
  END.
end.
end procedure.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-dis-card-type no-undo like ub.dis-card-type.
procedure get-cd-sumid :
define input parameter p-emitent-host-code as integer no-undo .
define input parameter p-type as character no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-host-code as integer no-undo .
define output parameter p-sum-id-value as character no-undo .
define output parameter p-sum-id-output as logical no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
define variable v-dt-code as integer no-undo .
define variable v-dtm-code as integer no-undo .
define variable v-caller-id as character no-undo .
define variable v-node-code as integer no-undo .
define variable v-node-value-type as character no-undo .
define variable v-value-field-name as character no-undo .
define variable v-storage-place as character no-undo .
define variable v-current-sum-id1 as character no-undo .
define variable v-current-sum-id2 as character no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-ii as integer no-undo .
define buffer buf_prop-ref for ub.prop-ref.
define buffer buf_prop-map for ub.prop-map.
define buffer buf_temp-dis-card-type for temp-dis-card-type.
define buffer buf_dis-card-type for ub.dis-card-type.
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  find first buf_temp-dis-card-type no-lock where
            buf_temp-dis-card-type.emitent-host-code = p-emitent-host-code
        and buf_temp-dis-card-type.type = p-type
        and buf_temp-dis-card-type.obj-type = p-obj-type
        and buf_temp-dis-card-type.obj-code = p-obj-code no-error .
  if not available buf_temp-dis-card-type then do:
    find first buf_dis-card-type no-lock where
              buf_dis-card-type.emitent-host-code = p-emitent-host-code
          and buf_dis-card-type.type = p-type
          and buf_dis-card-type.obj-type = p-obj-type
          and buf_dis-card-type.obj-code = p-obj-code no-error .
    if not available buf_Dis-card-type then do:
      find first buf_dis-card-type no-lock where
                buf_dis-card-type.emitent-host-code = p-emitent-host-code
            and buf_dis-card-type.type = p-type
            and buf_dis-card-type.host-code = p-host-code no-error .
      if not available buf_Dis-card-type
      and p-emitent-host-code = 0 then do:
        find first buf_dis-card-type no-lock where
                  buf_dis-card-type.emitent-host-code = p-emitent-host-code
              and buf_dis-card-type.type = p-type
              and buf_dis-card-type.host-code = 0 no-error .
      end.
    end.
    if available buf_dis-card-type then do:
      find first buf_temp-dis-card-type where
                  buf_temp-dis-card-type.emitent-host-code = p-emitent-host-code
              and buf_temp-dis-card-type.type = p-type
              and buf_temp-dis-card-type.host-code = 0 no-error .
      if not available buf_temp-dis-card-type then do:
        create buf_temp-dis-card-type.
        buffer-copy buf_dis-card-type to
        buf_temp-dis-card-type.
      end.
    end.
  end.
  if available buf_temp-dis-card-type then do:
    assign
    v-sum-id-value = buf_temp-dis-card-type.custom-sent
    p-sum-id-output = not (v-sum-id-value = fill(chr(63), num-entries(v-sum-id-value)))
    .
  end.
  if p-sum-id-output then do:
    do v-ii = 1 to num-entries(v-sum-id-value):
      assign
      v-value-character = entry(v-ii, v-sum-id-value)
      v-storage-place = entry(1, v-value-character, chr(4))
      v-dtm-code = integer(entry(2, v-value-character, chr(4)))
      v-sum-id   = entry(3, v-value-character, chr(4))
      v-caller-id = entry(4, v-value-character, chr(4))
      v-node-code = integer(entry(5, v-value-character, chr(4)))
      no-error .
      if error-status:error then do:
        assign
        p-sum-id-value = chr(63)
        p-sum-id-output = no
        .
        return.
      end.
      else do:
        run cur-time in this-procedure ( output v-today, output v-time).
        _prop-ref:
        for each buf_prop-ref no-lock where
                buf_prop-ref.dtm-code = v-dtm-code
            and buf_prop-ref.caller_id = v-caller-id,
            first buf_prop-map no-lock where
                  buf_prop-map.dtm-code = v-dtm-code
              and buf_prop-map.node-code = v-node-code
        by buf_prop-ref.dtm-code
        by buf_prop-ref.sum-id:
          assign
          p-sum-id-value = substitute("&2&1&3&1&4&1&5"
                                      , chr(4)
                                      ,v-storage-place
                                      ,buf_prop-ref.dt-code
                                      ,v-node-code
                                      ,buf_prop-map.node-name).
          if buf_prop-ref.ref-type = 'period':U then do:
            v-current-sum-id1 = entry(1, buf_prop-ref.sum-id, "-":U) + "-" + dct-algo-Date-to-String(v-today).
            v-current-sum-id2 = dct-algo-Date-to-String(v-today) + "-" + entry(2, buf_prop-ref.sum-id, "-":U).
            if v-current-sum-id1 <= buf_prop-ref.sum-id
            and v-current-sum-id2 >= buf_prop-ref.sum-id
            then do:
              leave _prop-ref.
            end.
          end.
          else do:
            if buf_prop-ref.sum-id = v-sum-id then leave _prop-ref.
          end.
        end.
        if not available buf_prop-ref then do:
          assign
          p-sum-id-value = chr(63)
          p-sum-id-output = no
          .
        end.
      end.
    end.
  end.
end.
end procedure.
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION propreft-Date-to-String returns character(input  p-date as date):
define variable v-date-str as character no-undo .
assign
v-date-str = string(YEAR(p-date), "9999":U) + chr(47) +
             string(Month(p-date), "99":U) + chr(47) +
             string(DAY(p-date), "99":U).
return v-date-str.
END FUNCTION.
function propreft-string-to-date returns date ( input p-string  as character):
  define variable v-date as date no-undo .
  assign
  v-date = date(integer(substring(p-string, 6, 2))
                ,integer(substring(p-string, 9, 2))
                ,integer(substring(p-string, 1, 4))
               ) no-error .
  if error-status:error then return ?.
  return v-date.
END FUNCTION.
FUNCTION propreft-petrol-to-String returns character(input  p-gds-code as integer):
define variable v-date-str as character no-undo .
assign
v-date-str = substitute("petrol-&1", p-gds-code).
return v-date-str.
END FUNCTION.
FUNCTION propreft-string-to-petrol returns integer(input  p-string as character):
define variable v-gds-code as integer no-undo .
assign
v-gds-code = integer(entry(2, p-string, "-")) no-error.
return v-gds-code.
END FUNCTION.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION get-dpcn RETURNS CHARACTER (
     input p-d-card as character
    ,input p-emitent-host-code as integer
    ,input p-type as character
    ,input parhost-code as integer
    ,input parobj-type as character
    ,input parobj-code as integer
    ,input p-node-code as integer
    ,input p-d-pcnt as decimal
    ,input p-cash-d-pcnt as decimal
    ,input p-category as integer
    ) :
define buffer buf_dis-card-type for ub.dis-card-type.
define variable loc-d-v as decimal no-undo init ?.
define variable v-discnt-role as character no-undo .
define buffer buf_dis-card-property for ub.dis-card-property.
find first buf_dis-card-type no-lock where
          buf_dis-card-type.type = p-type
      and buf_dis-card-type.emitent-host-code = p-emitent-host-code
      and buf_dis-card-type.host-code = 0
      and buf_dis-card-type.obj-type = '':U
      and buf_dis-card-type.obj-code = 0 no-error.
if available buf_dis-card-type then do:
  case p-node-code:
    when 1 then do:
      assign
      v-discnt-role = 'def-pcnt':U .
    end.
    when 2 then do:
      assign
      v-discnt-role = 'def-cash-pcnt':U.
    end.
    when 3 then do:
      assign
      v-discnt-role = 'def-categ':U.
    end.
  end case.
  if buf_dis-card-type.d-pcnt-byshop then do:
   find first buf_dis-card-property no-lock where
             buf_dis-card-property.d-card = p-d-card
         and buf_dis-card-property.dtm-code = 26
         and buf_dis-card-property.host-code = parhost-code
         and buf_dis-card-property.obj-type = parobj-type
         and buf_dis-card-property.obj-code = parobj-code
         and buf_dis-card-property.node-code = p-node-code no-error.
   if available buf_dis-card-property then do:
     if v-discnt-role = 'def-categ':U then do:
       assign
       loc-d-v = buf_dis-card-property.property-value-integer.
     end.
     else do:
       assign
       loc-d-v = buf_dis-card-property.property-value-decimal.
     end.
   end.
   if loc-d-v = ? then do:
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdpcnt in g#library
  (
   input  p-type
  ,input  p-emitent-host-code
  ,input  parhost-code
  ,input  parobj-type
  ,input  parobj-code
  ,input  v-discnt-role
  ,output loc-d-v
  ) no-error .
    end.
    if loc-d-v = ? then do:
      find first buf_dis-card-property no-lock where
                buf_dis-card-property.d-card = p-d-card
            and buf_dis-card-property.dtm-code = 26
            and buf_dis-card-property.host-code = parhost-code
            and buf_dis-card-property.obj-type = ''
            and buf_dis-card-property.obj-code = 0
            and buf_dis-card-property.node-code = p-node-code no-error.
      if available buf_dis-card-property then do:
        if v-discnt-role = 'def-categ':U then do:
          assign
          loc-d-v = buf_dis-card-property.property-value-integer.
        end.
        else do:
          assign
          loc-d-v = buf_dis-card-property.property-value-decimal.
        end.
      end.
    end.
    if loc-d-v = ? then do:
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdpcnt in g#library
  (
   input  p-type
  ,input  p-emitent-host-code
  ,input  parhost-code
  ,input  ''
  ,input  0
  ,input  v-discnt-role
  ,output loc-d-v
  ) no-error .
    end.
    if loc-d-v = ? then do:
      case v-discnt-role:
        when 'def-categ':U then do:
          loc-d-v = p-category.
        end.
        when 'def-pcnt':U then do:
          loc-d-v = p-d-pcnt.
        end.
        when 'def-cash-pcnt':U then do:
          loc-d-v = p-cash-d-pcnt.
        end.
      end case.
    end.
    if v-discnt-role = 'def-categ':U then do:
      return substitute("(i) &1", string(loc-d-v, ">>>9")).
    end.
    else do:
      return substitute("(i) &1", string(loc-d-v, "->9.99%")).
    end.
  end.
end.
else do:
 return "ОШИБКА-НЕТ ТИПА".
end.
case v-discnt-role:
  when 'def-categ':U then do:
     loc-d-v = p-category.
     return string(loc-d-v, ">>>9").
  end.
  when 'def-pcnt':U then do:
    loc-d-v = p-d-pcnt.
    return string(loc-d-v, "->9.99%").
  end.
  when 'def-cash-pcnt':U then do:
    loc-d-v = p-cash-d-pcnt.
    return string(loc-d-v, "->9.99%").
  end.
end case.
END FUNCTION.
define buffer buf_dis-thbj-rule for ub.dis-thbj-rule.
def var vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-drt-prop no-undo like ub.drt-prop.
procedure disrules-fill-properties:
define input  parameter p-templ-rl-root as integer   no-undo .
define buffer buf_drt-prop for ub.drt-prop.
define buffer buf_temp-drt-prop for temp-drt-prop.
do
on error undo, return error return-value
:
  for each buf_temp-drt-prop:
    delete buf_temp-drt-prop.
  end.
  for each buf_drt-prop where buf_drt-prop.templ-rl-root = p-templ-rl-root:
    create buf_temp-drt-prop.
    buffer-copy buf_drt-prop to buf_temp-drt-prop.
  end.
end.
end procedure.
define temp-table cash-dis-rule no-undo like ub.dis-rule.
define temp-table cash-dis-time-rule no-undo like ub.dis-time-rule.
procedure create-dis-rule :
define input parameter p-rule-num like ub.dis-rule.rule-num no-undo .
define input parameter p-tree as logical no-undo .
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_dis-time-rule for ub.dis-time-rule.
define buffer term_dis-rule for ub.dis-rule.
define buffer term_dis-time-rule for ub.dis-time-rule.
define buffer root_cash-dis-rule for cash-dis-rule.
define buffer root_cash-dis-time-rule for cash-dis-time-rule.
define buffer term_cash-dis-rule for cash-dis-rule.
define buffer term_cash-dis-time-rule for cash-dis-time-rule.
  do
  on error undo, return error
  :
    find first root_cash-dis-rule no-lock where                                                         ~
              root_cash-dis-rule.rule-num = p-rule-num no-error.
    if not available root_cash-dis-rule then do:
      find first buf_dis-rule no-lock where
                buf_dis-rule.rule-num = p-rule-num no-error.
      if available buf_dis-rule then do:
        if buf_dis-rule.time-rule-num <> 0 then do:
          find first buf_dis-time-rule no-lock where
                    buf_dis-time-rule.time-rule-num = buf_dis-rule.time-rule-num no-error.
        end.
        create root_cash-dis-rule.
        buffer-copy buf_dis-rule to root_cash-dis-rule.
        if available buf_dis-time-rule then do:
          find first root_cash-dis-time-rule no-lock where
                    root_cash-dis-time-rule.time-rule-num = buf_dis-rule.time-rule-num no-error.
          if not available root_cash-dis-time-rule then do:
            create root_cash-dis-time-rule.
            buffer-copy buf_dis-time-rule to root_cash-dis-time-rule.
          end.
        end.
        else do:
          assign
          root_cash-dis-rule.time-rule-num = 0.
        end.
        if buf_dis-rule.uniq-field <> "":U then do:
          for each term_dis-rule no-lock where
                  term_dis-rule.upper-rule-num =  buf_dis-rule.rule-num:
            if term_dis-rule.time-rule-num <> 0 then do:
              find first term_dis-time-rule no-lock where
                        term_dis-time-rule.time-rule-num = term_dis-rule.time-rule-num no-error.
            end.
            create term_cash-dis-rule.
            buffer-copy term_dis-rule to term_cash-dis-rule.
            if term_dis-rule.time-rule-num = 0
            or available term_dis-time-rule
            or root_cash-dis-rule.time-rule-num = 0
            then do:
              if available term_dis-time-rule then do:
                find first term_cash-dis-time-rule no-lock where
                          term_cash-dis-time-rule.time-rule-num = term_dis-rule.time-rule-num no-error.
                if not available term_cash-dis-time-rule then do:
                  create term_cash-dis-time-rule.
                  buffer-copy term_dis-time-rule to term_cash-dis-time-rule.
                end.
              end.
            end.
          end.
        end.
      end.
    end.
  end.
end procedure.
define shared temp-table dc-dis-card-mask no-undo like ub.dis-card-mask.
define shared temp-table dc-dis-card-mask-attr no-undo like ub.dis-card-mask-attr.
define variable ii as integer no-undo.
define variable conf-attr as character no-undo.
define variable conf-par as character no-undo.
define variable par-type as character no-undo.
DEFINE VARIABLE ind as integer no-undo .
DEFINE VARIABLE v-type as character no-undo .
define variable alllstcs as logical no-undo init no.
define variable v-curr-r-b as character no-undo .
define variable v-date-format as character no-undo .
define variable v-del-mrkt-cli as logical        no-undo .
define variable v-record as character no-undo .
define variable dr-list as character no-undo .
define variable drdcrank as character no-undo .
define variable v-magia-kat-codes-rule as integer no-undo .
define buffer for-shop for ub.shop.
define buffer for-clients for ub.clients.
define buffer lock-batchprocess for ub.batchprocess .
define buffer buf_cash-desk for ub.cash-desk.
define variable run-from as char no-undo.
define variable v-num as integer no-undo.
DEFINE VARIABLE var-report-num as integer no-undo .
DEFINE VARIABLE v-date as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
assign
i-obj-code = integer(entry(1, p-parameter, chr(4)))
action = entry(2, p-parameter, chr(4))
multiple-shops = (if entry(3, p-parameter, chr(4)) = "yes":U
                 then yes
                 else (if entry(3, p-parameter, chr(4)) = "no":U
                       then no
                       else ?)
                 )
p-batch = (if entry(4, p-parameter, chr(4)) = "yes":U
                 then yes
                 else (if entry(4, p-parameter, chr(4)) = "no":U
                       then no
                       else ?)
                 )
p-other = (if num-entries(p-parameter, chr(4)) >= 5
          then entry(5, p-parameter, chr(4))
          else '':U)
no-error
.
if error-status:error
or multiple-shops = ?
or p-batch = ?
then
return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
assign
v-del-mrkt-cli = lookup("del-mrkt-cli":U, p-other) > 0
.
run fill-temp-cd in this-procedure ( input g#db-num, input 'маг':U, input i-obj-code, input yes).
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type35 as character no-undo .
define variable v-value-character35 as date no-undo .
define variable v-value-date35 as date no-undo .
define variable v-value-decimal35 as decimal no-undo .
define variable v-value-integer35 as INTEGER no-undo .
define variable v-value-logical35 AS LOGICAL no-undo .
define variable v-tth35 as handle no-undo .
define variable cdpcknum as integer no-undo init 200.
run adm/shattri.p (
    input "get":U
    ,input  'маг':U
    ,input  i-obj-code
    ,input  'cd-sending':U
    ,input  'cdpcknum':U
    ,output v-value-character35
    ,output v-value-date35
    ,output v-value-decimal35
    ,output cdpcknum
    ,output v-value-logical35
    ,output v-param-type35
    ,INPUT-OUTPUT table-handle v-tth35
    )  .
delete object v-tth35.
define variable p-obj-type as character no-undo.
p-obj-type = 'маг':U.
run adm/shattri.p (
    input "get":U
    ,input  'маг':U
    ,input  i-obj-code
    ,input  'cd-sending':U
    ,input  'alllstcs':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
IF not error-status:error
then do:
  delete object v-tth.
  alllstcs = v-value-logical.
end.
else do:
  delete object v-tth.
  return error return-value .
end.
assign
var-report-num = dynamic-next-value( "next-report":U, "ubflt":U)
.
FIND ub.shop WHERE ub.shop.obj-code = i-obj-code NO-LOCK .
FIND ub.sysconf WHERE ub.sysconf.host-code = ub.shop.host-code NO-LOCK .
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
if action = "S":U then
assign
run-from = "S":U
action = "U":U.
if action = "O":U then
assign
run-from = "O":U
action = "U":U.
if action = "E":U then
assign
run-from = "E":U
action = "U":U.
if can-find(first cash-desk No-LOCK WHERE
                  cash-desk.db-num = g#db-num and
                  cash-desk.obj-code = i-obj-code AND
                  cash-desk.cash-on = yes AND
                  cash-desk.pos-type = 'IPC-Servis+':U) then do:
  _lock-cli:
  DO while ind < 100 :
  run gbl/lock-prc.p
      (input 'pcd2':U
      ,input i-obj-code
      ,input 0
      ,input 0
      ,input 'маг':U
      ,input ""
      ,input ""
      ,input (
              "Код объекта" + ",,," +
              "Тип объекта" +  ",,,Передача диск. карт"
            )
      ,input no
      ,buffer lock-batchprocess
      ) no-error .
    if not error-status:error then do:
      leave _lock-cli.
    end.
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "Объект &1: Файл для выгрузки данных ЗАНЯТ - Ждите", i-obj-code
                        )
                                        ).
    pause 1.
  end.
end.
if can-find(first cash-desk No-LOCK WHERE
                  cash-desk.db-num = g#db-num and
                  cash-desk.obj-code = i-obj-code AND
                  cash-desk.cash-on = yes AND
                  cash-desk.pos-type = 'MAGIA-XML':U) then do:
  find first buf_dis-thbj-rule no-lock where
            buf_dis-thbj-rule.obj-type = ''
         and buf_dis-thbj-rule.obj-code = 0
         and buf_dis-thbj-rule.pos-type = 'MAGIA-XML':U
         and buf_dis-thbj-rule.discnt-role = 'kateg-codes':U no-error .
  if available buf_dis-thbj-rule then do:
    v-magia-kat-codes-rule = buf_dis-thbj-rule.rule-num.
    run create-dis-rule in this-procedure ( input buf_dis-thbj-rule.rule-num, yes) no-error .
  end.
end.
if v-del-mrkt-cli then do:
  for each cash-cli:
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$".
define buffer buf_dis-dc-rule for ub.dis-dc-rule.
IF can-find( first temp-cd where temp-cd.pos-type = 'MARIA':U) then do:
  for each buf_dis-dc-rule no-lock where
            buf_dis-dc-rule.d-card = cash-cli.d-card
        and buf_dis-dc-rule.host-code = ub.sysconf.host-code
        and buf_dis-dc-rule.obj-type = 'маг':U
        and buf_dis-dc-rule.obj-code = i-obj-code:
    if buf_dis-dc-rule.discnt-role = 'debet-pay-pcnt-disc':U
    or buf_dis-dc-rule.discnt-role = 'debet-pay-abs-disc':U
    or buf_dis-dc-rule.discnt-role = 'debet-pay-qnty-disc':U
    or buf_dis-dc-rule.discnt-role = 'debet-pay-sum-disc':U
    or buf_dis-dc-rule.discnt-role = 'debet-pay-free-disc':U  then do:
      assign
      cash-cli.dcr-debet-pay = buf_dis-dc-rule.rule-num
      no-error
      .
      leave.
    end.
  end.
  for each buf_dis-dc-rule no-lock where
            buf_dis-dc-rule.d-card = cash-cli.d-card
        and buf_dis-dc-rule.host-code = ub.sysconf.host-code
        and buf_dis-dc-rule.obj-type = 'маг':U
        and buf_dis-dc-rule.obj-code = i-obj-code:
    if buf_dis-dc-rule.discnt-role = 'credit-pay-pcnt-disc':U
    or buf_dis-dc-rule.discnt-role = 'credit-pay-abs-disc':U
    or buf_dis-dc-rule.discnt-role = 'credit-pay-qnty-disc':U
    or buf_dis-dc-rule.discnt-role = 'credit-pay-sum-disc':U
    or buf_dis-dc-rule.discnt-role = 'credit-pay-free-disc':U  then do:
      assign
      cash-cli.dcr-credit-pay = buf_dis-dc-rule.rule-num
      no-error
      .
    end.
  end.
end.
  end.
  find last cash-cli use-index pi no-error .
  if available cash-cli then do:
    cr = cash-cli.crf + 1.
  end.
end.
if g#news
or g#esys
OR run-from = "S":U
or run-from = "O":U
or run-from = "E":U
then do:
  FOR EACH dc-list NO-LOCK,
      FIRST dis-card no-lock where
            dis-card.d-card = dc-list.d-card,
      first clients no-lock where
            clients.obj-type = dis-card.cli-type
        AND  clients.obj-code = dis-card.cli-code,
      FIRST ub.dis-card-type No-LOCK WHERE
            ub.dis-card-type.type = dis-card.type AND
            ub.dis-card-type.emitent-host-code = dis-card.emitent-host-code AND
            ub.dis-card-type.host-code = 0 AND
            ub.dis-card-type.obj-type = "":U AND
            ub.dis-card-type.obj-code = 0 :
    if dis-card.emitent-host-code <> 0 and
      dis-card.emitent-host-code <> ub.shop.host-code then NEXT.
    ii = ii + 1.
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$".
FIND FIRST cash-cli where cash-cli.crf = (cr + 1) No-ERROR.
start-paket = no.
if not avail cash-cli then
create cash-cli.
else do:
  assign
  cash-cli.cli-adr   = ""
  cash-cli.cli-adr2  = ""
  cash-cli.director  = ""
  cash-cli.engl-name = ""
  cash-cli.telex     = "":U
  cash-cli.phone1-note  = "":U
  cash-cli.post-addr1 = "":U
  cash-cli.post-addr2 = "":U
  cash-cli.phone1  = "":U
  cash-cli.post-box  = ""
  cash-cli.valid-date = 12/31/9999
  cash-cli.property-value-chr[1] = '':U
  cash-cli.property-value-chr[2] = '':U
  cash-cli.property-value-chr[3] = '':U
  cash-cli.property-value-chr[4] = '':U
  cash-cli.dcr-pcnt        = 0
  cash-cli.dcr-abs         = 0
  cash-cli.dcr-pcnt-qnty   = 0
  cash-cli.dcr-pcnt-tot    = 0
  cash-cli.ef-format       = 0
  cash-cli.ef-access-key   = ""
  cash-cli.has-attrs       = no
  cash-cli.has-attrs-lim   = no
  .
end.
error-status:error = false.
cash-cli.crf = cr + 1.
cr = cr + 1.
if ub.clients.obj-type = 'орг':U then do:
  FIND ub.firm WHERE ub.firm.firm-code = ub.clients.obj-code .
  assign
  cash-cli.cli-type = 'орг':U
  cash-cli.cli-code = ub.clients.obj-code
  cash-cli.cli-city = ub.firm.city
  cash-cli.cli-adr = trim( ub.firm.addres1 )
  cash-cli.cli-adr2 = trim( ub.firm.addres2 )
  cash-cli.director = trim( ub.firm.director )
  cash-cli.e-mail = trim( ub.firm.e-mail )
  cash-cli.engl-name = trim( ub.firm.engl-name)
  cash-cli.fax     = trim( ub.firm.fax)
  cash-cli.telex     = trim( ub.firm.telex)
  cash-cli.position  = trim( ub.firm.head-position)
  cash-cli.is-pboul  = ub.firm.is-pboul
  cash-cli.okonh     = trim(ub.firm.okonh)
  cash-cli.okpo      = trim(ub.firm.okpo)
  cash-cli.phone1-note  = trim(ub.firm.phone1-note)
  cash-cli.post-addr1 = trim( ub.firm.post-addr1 )
  cash-cli.post-addr2 = trim( ub.firm.post-addr2 )
  cash-cli.cli-inn = trim(ub.firm.inn)
  cash-cli.cli-phone = trim(ub.firm.phone)
  cash-cli.cli-ind = ub.firm.ind
  cash-cli.justface = 1
  cash-cli.kpp     = ub.firm.kpp
  .
end.
else do:
  if ub.clients.obj-type = 'чел':U then do:
    FIND ub.person WHERE ub.person.psn-code = ub.clients.obj-code .
    assign
    cash-cli.cli-type = 'чел':U
    cash-cli.cli-code = ub.clients.obj-code
    cash-cli.cli-city = ub.person.city
    cash-cli.cli-adr = trim( ub.person.address )
    cash-cli.cli-inn = trim(ub.person.inn)
    cash-cli.cli-phone = trim(ub.person.phone1)
    cash-cli.cli-ind = ub.person.ind
    cash-cli.phone1  = trim(ub.person.phone1)
    cash-cli.e-mail = trim( ub.person.e-mail )
    cash-cli.fax     = trim( ub.person.fax)
    cash-cli.position  = trim( ub.person.position)
    cash-cli.is-pboul  = ub.person.is-pboul
    cash-cli.okonh     = trim(ub.person.okonh)
    cash-cli.okpo      = trim(ub.person.okpo)
    cash-cli.post-box  = trim(ub.person.post-box)
    cash-cli.justface = 0
    cash-cli.kpp     = ub.person.kpp
    .
  end.
  else do:
    NEXT .
  end.
end.
assign
cash-cli.mask-card     = ub.dis-card.mask-card
cash-cli.current-saldo =  (if ub.dis-card.credit-card = yes
                            then (if v-curr-r-b = 'base':U
                                  then ub.dis-card.saldo-base
                                  else ub.dis-card.saldo-rubl)
                            else 0)
cash-cli.current-saldo-rubl = ub.dis-card.saldo-rubl
cash-cli.current-saldo-base = ub.dis-card.saldo-base
cash-cli.lim-kr = (if ub.dis-card.credit-card = yes
                    then ub.dis-card.lim-kr
                    else 0)
cash-cli.d-pcnt = ub.dis-card.d-pcnt
cash-cli.kat-pcnt = ub.dis-card.category
cash-cli.h-ka = (if ub.dis-card.category > 0 then 2 else 0)
cash-cli.cash-d-pcnt = ub.dis-card.cash-d-pcnt
cash-cli.d-pcnt-method = ub.dis-card.d-pcnt-method
cash-cli.status_ = ub.dis-card.status_
cash-cli.d-card = ub.dis-card.d-card
cash-cli.issue-code = ub.dis-card.issue-code
cash-cli.issue-date = ub.dis-card.issue-date
cash-cli.type = ub.dis-card.type
cash-cli.emitent-host-code = ub.dis-card.emitent-host-code
cash-cli.d-pcnt-byshop = ub.dis-card-type.d-pcnt-byshop
cash-cli.cli-status_ = ub.clients.stts
cash-cli.card-media = ub.dis-card-type.card-media
cash-cli.credit-card = ub.dis-card.credit-card
cash-cli.debet-card = ub.dis-card.debet-card
cash-cli.staff-card = ub.dis-card.staff-card
cash-cli.cli-message = ub.dis-card.cli-message
cash-cli.fiscal-pay = (if cash-cli.debet-card
                        or cash-cli.credit-card
                        then  ub.dis-card-type.fiscal-pay
                        else no)
cash-cli.pay-code = ub.dis-card-type.pay-code
cash-cli.mixed-pay =  ub.dis-card-type.mixed-pay
cash-cli.sourced-card = ub.dis-card.sourced-card
cash-cli.valid-date  = (if ub.dis-card.valid-date <> ?
                        then ub.dis-card.valid-date
                        else cash-cli.valid-date)
.
if cash-cli.card-media = integer('5':U) then do:
  find first buf_Dis-card-property no-lock where
            buf_Dis-card-property.d-card = cash-cli.d-card
       and buf_Dis-card-property.dtm-code = integer(25)
       and buf_Dis-card-property.node-code = integer(4)
       and buf_Dis-card-property.host-code = 0
       and buf_Dis-card-property.obj-type = ''
       and buf_Dis-card-property.obj-code = 0 no-error.
  if available buf_dis-card-property then
  cash-cli.ef-access-key = buf_Dis-card-property.property-value-character.
  find first buf_Dis-card-property no-lock where
            buf_Dis-card-property.d-card = cash-cli.d-card
       and buf_Dis-card-property.dtm-code = integer(25)
       and buf_Dis-card-property.node-code = integer(3)
       and buf_Dis-card-property.host-code = 0
       and buf_Dis-card-property.obj-type = ''
       and buf_Dis-card-property.obj-code = 0 no-error.
  if available buf_dis-card-property then
  cash-cli.ef-format = buf_Dis-card-property.property-value-integer.
end.
CASE ub.dis-card-type.cardname-sent:
  when "card" then do:
    assign
    cash-cli.cli-name = dis-card.d-card
    cash-cli.obj-name = ub.clients.obj-name
    cash-cli.cli-name2 = "":U
    cash-cli.cli-name3 = "":U
    cash-cli.given-by = "":U
    cash-cli.passport = "":U
    .
  end.
  otherwise do:
    if cash-cli.cli-type = 'орг':U then do:
      assign
      cash-cli.cli-name = right-trim( ub.clients.obj-name )
      cash-cli.cli-name2 = "":U
      cash-cli.cli-name3 = "":U
      .
    end.
    else do:
      assign
      cash-cli.obj-name = ub.clients.obj-name
      cash-cli.cli-name = right-trim( ub.clients.obj-name ) + chr(4) +
                          (
                          if ub.person.name1 <> "":U
                          and ub.person.name1 <> ?
                          then (substr(trim( ub.person.name1 ),1,1) + ".")
                          else "":U
                          ) + chr(4) +
                          (if ub.person.name2 <> "":U
                          and ub.person.name2 <> ?
                          then  (substr(trim( ub.person.name2 ),1,1) + ".")
                          else "":U
                          )
      cash-cli.cli-name2 = ub.person.name1
      cash-cli.cli-name3 = ub.person.name2
      cash-cli.given-by = ub.person.given-by
      cash-cli.passport = ub.person.passp-ser + chr(4) + ub.person.passp-num
      .
    end.
    .
  end.
END CASE.
assign
cash-cli.cli-name = replace(cash-cli.cli-name, chr(34), "":U)
cash-cli.cli-city = replace(cash-cli.cli-city, chr(34), "":U)
cash-cli.cli-adr = replace(cash-cli.cli-adr, chr(34), "":U)
.
for each buf_dis-card-property no-lock where
          buf_dis-card-property.dtm-code = 18
     and  buf_dis-card-property.d-card = cash-cli.d-card
     AND  buf_dis-card-property.HOST-CODE = 0
     AND  buf_dis-card-property.obj-type = '':U
     AND  buf_dis-card-property.obj-code = 0
  break
  by buf_dis-card-property.dt-code:
  if first-of(buf_dis-card-property.dt-code) then do:
    v-gds-code = -1.
    v-gds-code =  propreft-string-to-petrol(buf_dis-card-property.sum-id) no-error .
    if not error-status:error
    and v-gds-code <> 0 then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  v-gds-code
  ,input  ?
  ,output v-b-code
  ) no-error .
    end.
  end.
  if v-gds-code = -1 then next.
  find first cash-cli-attr no-lock where
            cash-cli-attr.d-card = ub.dis-card.d-card
        and cash-cli-attr.dc-petrol-code = v-b-code no-error .
  if not available cash-cli-attr then do:
    create cash-cli-attr.
    assign
    cash-cli-attr.d-card = ub.dis-card.d-card
    cash-cli-attr.dc-petrol-code = v-b-code
    .
  end.
  case buf_dis-card-property.node-code:
    when 1  then do:
      assign
      cash-cli-attr.dc-car-reg-number = buf_dis-card-property.property-value-character
      .
    end.
    when 2 then do:
      assign
      cash-cli-attr.dc-car-brand = buf_dis-card-property.property-value-character
      .
    end.
    when 8 then do:
      cash-cli-attr.account-type = buf_dis-card-property.property-value-integer.
    end.
    when  3 then do:
      cash-cli-attr.dc-limit-type = buf_dis-card-property.property-value-character.
    end.
    when 4 then do:
      assign
      cash-cli-attr.dc-limit =  buf_dis-card-property.property-value-decimal
      .
    end.
    when 5 then do:
      assign
      cash-cli-attr.dc-limit-l =  buf_dis-card-property.property-value-decimal   .
    end.
    when 6 then do:
    end.
    when 7 then do:
    end.
    when 9 then do:
      assign
      cash-cli-attr.cdpay-code =  buf_dis-card-property.property-value-integer
      cash-cli-attr.curr-code = 0
      .
    end.
  end case.
  if first-of(buf_dis-card-property.dt-code) then do:
    release cash-cli-attr.
    cash-cli.has-attrs = yes.
  end.
end.
for each ub.dis-card-property no-lock where
          ub.dis-card-property.dtm-code = 27
     and  ub.dis-card-property.d-card = cash-cli.d-card
     AND  ub.dis-card-property.HOST-CODE = 0
     AND  ub.dis-card-property.obj-type = '':U
     AND  ub.dis-card-property.obj-code = 0
  break
  by ub.dis-card-property.dt-code:
  for each ub.prop-ref where ub.prop-ref.dtm-code = ub.dis-card-property.dtm-code and ub.prop-ref.sum-id = ub.dis-card-property.sum-id:
  find first cash-cli-attr no-lock where
            cash-cli-attr.d-card = ub.dis-card.d-card and cash-cli-attr.dc-sum-id = ub.dis-card-property.sum-id
                                                      and cash-cli-attr.caller_id = ub.prop-ref.Caller_id no-error .
  if not available cash-cli-attr then do:
    create cash-cli-attr.
    assign
    cash-cli-attr.d-card = ub.dis-card.d-card
    cash-cli-attr.dc-sum-id = ub.dis-card-property.sum-id
    cash-cli-attr.caller_id = ub.prop-ref.Caller_id
    .
  end.
  case ub.dis-card-property.node-code:
    when 1  then do:
      assign
      cash-cli-attr.dc-minnum = ub.dis-card-property.property-value-decimal
      .
    end.
    when 2 then do:
      assign
      cash-cli-attr.dc-maxnum = ub.dis-card-property.property-value-decimal
      .
    end.
  end case.
  end.
  if last-of(ub.dis-card-property.dt-code) then do:
    cash-cli.has-attrs-lim = yes.
  end.
end.
    if dc-list.flog = yes then delete dc-list.
    if ( ii  > cdpcknum)   and NOT alllstcs  then do:
      if cr > 0 then do:
        if g#news
        or g#esys
        then do:
          FOR EACH for-shop NO-LOCK where
                  for-shop.host-code = ub.shop.host-code,
              FIRST for-clients No-LOCK WHERE
                    for-clients.obj-type = 'маг':U
                AND for-clients.obj-code = for-shop.obj-code
                AND for-clients.db-num = g#db-num:
            FIND ub.sysconf WHERE
                ub.sysconf.host-code = ub.shop.host-code NO-LOCK.
            assign
            i-obj-code = for-shop.obj-code
            .
            RUN SENDING in this-procedure no-error.
            if error-status:error then do:                                                                            run write-log-and-file in p-log-handle (                                                                      input 1                                                                                               , input log-file-name                                                                                   , input 1                                                                                               , input substitute("&1 &2", error-status:get-message(1), return-value)                                                                      ).                                                              assign                                                                                                  v-view-log = yes                                                                                        .                                                                                                     end.
          END.
        end.
        else
        RUN SENDING in this-procedure no-error.
        if error-status:error then do:                                                                            run write-log-and-file in p-log-handle (                                                                      input 1                                                                                               , input log-file-name                                                                                   , input 1                                                                                               , input substitute("&1 &2", error-status:get-message(1), return-value)                                                                      ).                                                              assign                                                                                                  v-view-log = yes                                                                                        .                                                                                                     end.
      end.
      assign
      start-paket = yes
      cr = 0
      ii = 0
      .
    end.
  END.
end.
if (cr > 0 AND (g#news
                or g#esys
                or run-from = "S":U
                or run-from = "O":U
                or run-from = "E":U
                )
   )
or
   (NOT (g#news
         or g#esys
         OR run-from = "S"
         or run-from = "O":U
         or run-from = "E":U)
         AND can-find(first cash-cli)
    ) then do:
  if (g#news or g#esys OR multiple-shops) then do:
    FOR EACH for-shop NO-LOCK where for-shop.host-code = ub.shop.host-code,
            FIRST for-clients No-LOCK WHERE
                  for-clients.obj-type = 'маг':U AND
                  for-clients.obj-code = for-shop.obj-code AND
                  for-clients.db-num = g#db-num,
      first buf_cash-desk no-lock where
           buf_cash-desk.db-num = g#db-num
       AND buf_cash-desk.obj-code = for-clients.obj-code
       AND buf_cash-desk.cash-on = yes   :
      FIND ub.sysconf WHERE
          ub.sysconf.host-code = ub.shop.host-code NO-LOCK.
      assign
      i-obj-code = for-shop.obj-code
      .
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("Пересылка на кассы &1&2 информации о дисконтных картах", 'маг':U, i-obj-code)
                                                ).
      RUN SENDING in this-procedure no-error.
      if error-status:error then do:                                                                            run write-log-and-file in p-log-handle (                                                                      input 1                                                                                               , input log-file-name                                                                                   , input 1                                                                                               , input substitute("&1 &2", error-status:get-message(1), return-value)                                                                      ).                                                              assign                                                                                                  v-view-log = yes                                                                                        .                                                                                                     end.
    END.
  end.
  else do:
    run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Пересылка на кассы &1&2 информации о дисконтных картах", 'маг':U, i-obj-code)
                                                  ).
    RUN SENDING in this-procedure no-error.
    if error-status:error then do:                                                                            run write-log-and-file in p-log-handle (                                                                      input 1                                                                                               , input log-file-name                                                                                   , input 1                                                                                               , input substitute("&1 &2", error-status:get-message(1), return-value)                                                                      ).                                                              assign                                                                                                  v-view-log = yes                                                                                        .                                                                                                     end.
  end.
end.
for each cash-cli:
    delete cash-cli.
end.
if p-batch then do:
  if v-view-log then
  run set-view-log in p-log-handle(yes).
end.
else do:
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При отсылке информации на кассы произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action40   as character no-undo .
  define variable v-printed40       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При отсылке информации на кассы произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + log-file-name)
    ,input  7
    ,output v-user-action40
    ,output v-printed40
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + log-file-name).
end.
end.
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE putc-2.
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter pos-type   as character no-undo.
define input parameter p-version  as character no-undo .
define input parameter p-send-cli as logical no-undo .
define variable v-magia-card-operation as integer no-undo .
define variable v-magia-curr-code as integer no-undo .
define variable v-r-b-code like ub.currency.curr-code.
define variable v-version-dec as decimal no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-full-number like ub.dis-card.d-card no-undo .
define variable v-cli-mask like ub.dis-card-mask.cli-mask no-undo .
define variable v-versiond as decimal no-undo .
define variable v-clu as integer no-undo .
define variable v-marketer-action as character no-undo .
define variable v-maria-discnt-value as character no-undo .
define variable v-ii as integer no-undo .
define variable v-dop as character no-undo .
define variable v-dc-rule-num as integer no-undo .
define variable v-maria-rule-num as integer no-undo .
define variable v-magia-kat-pcnt as integer no-undo .
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_currency for ub.currency.
define buffer buf_cd-clu for ub.cd-clu.
define buffer buf_dis-rule for ub.dis-rule.
define buffer root_cash-dis-rule for cash-dis-rule.
if cash-cli.d-pcnt >= 100  then do:
  return error
  substitute("Карта &1:неверный процент скидки по карте &2"
              ,  cash-cli.d-card
              , cash-cli.d-pcnt
              ).
end.
if cash-cli.d-pcnt-byshop then do:
  v-d-pcnt = decimal(trim(get-dpcn ( input cash-cli.d-card
                     , input cash-cli.emitent-host-code
                     , input cash-cli.type
                     , input ub.sysconf.host-code
                     , input 'маг':U
                     , input (if g#news
                              or g#esys
                              then buf_cash-desk.obj-code
                              else i-obj-code)
                     , input 1
                     , input cash-cli.d-pcnt
                     , input cash-cli.cash-d-pcnt
                     , input cash-cli.kat-pcnt), "%)(i ")).
  v-cash-d-pcnt = decimal(trim(get-dpcn ( input cash-cli.d-card
                     , input cash-cli.emitent-host-code
                     , input cash-cli.type
                     , input ub.sysconf.host-code
                     , input 'маг':U
                     , input (if g#news
                              or g#esys
                              then buf_cash-desk.obj-code
                              else i-obj-code)
                     , input 1
                     , input cash-cli.d-pcnt
                     , input cash-cli.cash-d-pcnt
                     , input cash-cli.kat-pcnt), "%)(i ")).
  v-categ = integer(trim(get-dpcn ( input cash-cli.d-card
                     , input cash-cli.emitent-host-code
                     , input cash-cli.type
                     , input ub.sysconf.host-code
                     , input 'маг':U
                     , input (if g#news
                              or g#esys
                              then buf_cash-desk.obj-code
                              else i-obj-code)
                     , input 1
                     , input cash-cli.d-pcnt
                     , input cash-cli.cash-d-pcnt
                     , input cash-cli.kat-pcnt), "%)(i ")).
end.
CASE pos-type:
  when 'IBM':U
  or
  when 'Emulator-NKT-IBM':U
  then do:
    if pos-type = 'Emulator-NKT-IBM':U then
    v-version-dec = 0.
    else
    assign
    v-version-dec = decimal(p-version) no-error .
    if v-version-dec >= 4.4
    then do:
      PUT stream IBMstream unformatted
      '19' chr(32)
      '"'  (if g#news or g#esys or run-from = "O":U or run-from = "E":U
              then
              (if cash-cli.cli-status_  = 0 then "U":U
              else "D":U)
              else string( action, "x(1)" )
              ) '"' chr(32)
      chr(34)
      string( fill( chr(32) , 16 - length( trim(string((if cash-cli.cli-type = 'орг':U then 1 else 0) * 1000000000 + cash-cli.cli-code ) ) ) )
            + string((if cash-cli.cli-type = 'орг':U then 1 else 0) * 1000000000 + cash-cli.cli-code)
            )
      chr(34)
      chr(32)
      chr(34) caps( string( entry(1, cash-cli.cli-name, chr(4)), "x(40)" ) )   chr(34)   chr(32)
      chr(34) caps( string( cash-cli.cli-city , "x(20)" ) )   chr(34)  chr(32)
      chr(34) caps( string( cash-cli.cli-adr , "x(40)" ) ) chr(34) chr(32)
       string( cash-cli.kat-pcnt, ">>>9" ) chr(32)
      chr(34) string(cash-cli.cli-inn, "X(20)") chr(34) chr(32)
      chr(34) string(cash-cli.kpp, "X(25)") chr(34) chr(32)
      string(cash-cli.h-ka, ">>>>>9") chr(32)
      (if  cash-cli.mask-card
      then string( cash-cli.lim-kr, ">>>>>>>>9.99" )
      else string( 0, ">>>>>>>>9.99" )
      ) chr(32)
     (if  cash-cli.mask-card
      then string(cash-cli.current-saldo, "->>>>>>>>9.99" )
      else string( 0 , "->>>>>>>>9.99" )
      ) chr(32)
      (if cash-cli.mask-card
      then string( if cash-cli.d-pcnt-byshop
                  then (- v-d-pcnt)
                  else ( - cash-cli.d-pcnt ) , "->>9.99" )
      else string( 0 , "->>9.99" )
      )
      chr(32)
      Os2-time
      chr(10).
      if not cash-cli.mask-card then do:
        PUT stream IBMstream unformatted
        '21' chr(32)
        '"'  (if g#news or g#esys or run-from = "O":U or run-from = "E":U
                then
                (if lookup('тек':U, cash-cli.status_ ) > 0 then "U":U
                else "D":U)
                else string( action, "x(1)" )
                ) '"' chr(32)
        chr(34)
        string( fill( " ", 19 - length( trim( cash-cli.d-card ) ) ) + trim( cash-cli.d-card ) )
        chr(34)
        chr(32)
        chr(34)
        string( fill( chr(32) , 16 - length( trim(string((if cash-cli.cli-type = 'орг':U then 1 else 0) * 1000000000 + cash-cli.cli-code ) ) ) )
              + string((if cash-cli.cli-type = 'орг':U then 1 else 0) * 1000000000 + cash-cli.cli-code)
             )
        chr(34)
        chr(32)
        string( if cash-cli.d-pcnt-byshop
                then (- v-d-pcnt)
                else ( - cash-cli.d-pcnt ) , "->>9.99" ) chr(32)
        string( cash-cli.kat-pcnt, ">>>9" ) chr(32)
        string( cash-cli.lim-kr, ">>>>>>>>9.99" ) chr(32)
        (if cash-cli.property-value-chr[1] <> '':U
          then cash-cli.property-value-chr[1]
          else string( cash-cli.current-saldo , "->>>>>>>>9.99" )
        )
        chr(32)
        Os2-time
        chr(10).
      end.
    end.
    else do:
      if not cash-cli.mask-card then do:
        PUT stream IBMstream unformatted
        '2 "' (if g#news or g#esys or run-from = "O":U or run-from = "E":U then
                (if lookup('тек':U, cash-cli.status_ ) > 0 then "U":U
                else "D":U)
                else string( action, "x(1)" )
                ) '" '
        string( fill( chr(32), 16 - length( trim( cash-cli.d-card ) ) ) + trim( cash-cli.d-card ) ) ' "'
        caps( string( entry(1, cash-cli.cli-name, chr(4)), "x(40)" ) ) '" "'
        caps( string( cash-cli.cli-city , "x(20)" ) )  '" "'
        caps( string( cash-cli.cli-adr , "x(40)" ) )  '" '
        string( cash-cli.kat-pcnt, ">>>>>9" ) ' "'
        string(cash-cli.cli-inn, "X(20)")   '" "'
        string(cash-cli.kpp, "X(25)")  '" '
        string(cash-cli.h-ka, ">>>>>9") " "
        string( cash-cli.lim-kr, ">>>>>>>>9.99" ) " "
       (if cash-cli.property-value-chr[1] <> '':U
        then cash-cli.property-value-chr[1]
        else string( cash-cli.current-saldo , "->>>>>>>>9.99" )
       )
        chr(32)
        string( if cash-cli.d-pcnt-byshop
                then (- v-d-pcnt)
                else ( - cash-cli.d-pcnt ) , "->>9.99" )
        " "
        Os2-time
        chr(10).
      end.
    end.
  end.
  when 'IBM-XML':U
  then do:
    assign
    v-version-dec = decimal(p-version)
    no-error .
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run bgelib-tag-open in this-procedure ( input 2, input "Client"
                                      , input substitute("ctrl='&1' tms='&2' code='&3'"
                                      , if cash-cli.cli-code ne ?
                                        then 'ADD':U
                                        else if action = "U"
                                        then 'ADD':U
                                        else "DEL":U
                                      , OS2-time, if cash-cli.cli-code eq ?
                                                  then "*"
                                                  else string(cash-cli.cli-code + 1000000000 * cash-cli.justface))).
run bgelib-tag-put in this-procedure ( input 3, input "ClientName"       , input entry(1, cash-cli.cli-name, chr(4)), input 1 ).
run bgelib-tag-put in this-procedure ( input 3, input "ClientCity"       , input cash-cli.cli-city, input 1 ).
run bgelib-tag-put in this-procedure ( input 3, input "ClientAddress"    , input cash-cli.cli-adr, input 1 ).
if cash-cli.cli-type = 'орг':U then
run bgelib-tag-put in this-procedure ( input 3, input "ClientAddress2"   , input cash-cli.post-addr1,  input 1 ).
run bgelib-tag-put in this-procedure ( input 3, input "ClientIndex"      , input string(cash-cli.cli-ind), input 1 ).
run bgelib-tag-put in this-procedure ( input 3, input "ClientPhone"      , input cash-cli.cli-phone, input 1 ).
run bgelib-tag-put in this-procedure ( input 3, input "ClientINN"        , input cash-cli.cli-inn, input 1 ).
run bgelib-tag-put in this-procedure ( input 3, input "ClientKPP"        , input cash-cli.kpp, input 1 ).
run bgelib-tag-put in this-procedure ( input 3, input "ClientJustFace"   , input string(cash-cli.justface), input 1 ).
run bgelib-tag-put in this-procedure ( input 3, input "ClientLock"       ,
                                      input  string(if cash-cli.cli-status_ = 0 then 0 else 1), input 0 ).
run bgelib-tag-close in this-procedure ( input 2, input "Client").
  run bgelib-tag-open in this-procedure ( input 2, input "DiscountCard"
                                        , input substitute("ctrl='&1' tms='&2' code='&3'"
                                                           ,(if g#news or run-from = "O":U or run-from = "E":U
                                                             then
                                                                (if lookup('тек':U, cash-cli.status_ ) > 0
                                                                 then "ADD":U
                                                                 else "DEL":U
                                                                 )
                                                             else (if action = "U"
                                                                   then (if lookup('тек':U, cash-cli.status_ ) > 0
                                                                         then "ADD":U
                                                                         else "DEL":U)
                                                                   else "DEL":U
                                                                  )
                                                             )
                                                           , OS2-time
                                                           , (if cash-cli.d-card eq ?
                                                              then "*"
                                                              else string(cash-cli.d-card)))).
  run bgelib-tag-put in this-procedure ( input 3, input "DCClient"
                                        , input (cash-cli.cli-code + 1000000000 * cash-cli.justface)
                                        , input 0 ).
  run bgelib-tag-put in this-procedure ( input 3, input "DCSaldo"
                                                 , input  (if cash-cli.property-value-chr[1] <> '':U
                                                            then cash-cli.property-value-chr[1]
                                                            else string(cash-cli.current-saldo)
                                                          )
                                                  , input 0 ).
  run bgelib-tag-put in this-procedure ( input 3, input "DCLimit"     , input cash-cli.lim-kr, input 0 ).
  run bgelib-tag-put in this-procedure ( input 3, input "DCDisCat"     , input string(cash-cli.kat-pcnt), input 0 ).
  run bgelib-tag-put in this-procedure ( input 3, input "DCSaldo"     , input cash-cli.current-saldo, input 0 ).
  run bgelib-tag-put in this-procedure ( input 3, input "DCDisc"       ,
                                        input   string( if cash-cli.d-pcnt-byshop
                                                then (- v-d-pcnt)
                                                else ( - cash-cli.d-pcnt ) , "->>9.99" ) , input 0 ).
  if cash-cli.cli-message <> "":u
  and cash-cli.cli-message <> ?
  then
  run bgelib-tag-put in this-procedure ( input 3, input "DCMessage"     , input string(cash-cli.cli-message), input 1 ).
  if cash-cli.has-attrs = yes
  and v-version-dec >= 1.07
  then do:
    for each cash-cli-attr where
            cash-cli-attr.d-card = cash-cli.d-card:
      run bgelib-tag-open in this-procedure ( input 3
                                            , input "DCRestriction"
                                            , input '':U).
      run bgelib-tag-put in this-procedure ( input 4, input "DCRObjAttr"
                                            ,  input cash-cli-attr.dc-car-reg-number
                                            , input 0 ).
      run bgelib-tag-put in this-procedure ( input 4, input "DCRObjName"
                                            ,  input cash-cli-attr.dc-car-brand
                                            , input 0 ).
      run bgelib-tag-put in this-procedure ( input 4, input "DCRUnitCode"
                                            ,  input (if cash-cli-attr.dc-petrol-code > 0
                                                      then string(cash-cli-attr.dc-petrol-code)
                                                      else '')
                                            , input 0 ).
      run bgelib-tag-put in this-procedure ( input 4, input "DCRLimitType"
                                            ,  input (if cash-cli-attr.dc-limit-type = "sum"
                                                      then 2
                                                      else 1)
                                            , input 0 ).
      if cash-cli-attr.dc-limit-type = "sum" then do:
        run bgelib-tag-put in this-procedure ( input 4, input "DCRLimitValue"
                                              ,  input cash-cli-attr.dc-limit
                                              , input 0 ).
      end.
      else do:
        run bgelib-tag-put in this-procedure ( input 4, input "DCRLimitValue"
                                              ,  input cash-cli-attr.dc-limit-l
                                              , input 0 ).
      end.
      run bgelib-tag-close in this-procedure ( input 3, input "DCRestriction").
    end.
  end.
  run bgelib-tag-close in this-procedure ( input 2, input "DiscountCard").
  if v-version-dec >= 1.11
  and cash-cli.card-media = integer('5':U) then do:
    run bgelib-tag-open in this-procedure ( input 2
                                          , input "ACWhiteList"
                                          , input substitute("ctrl='&1' tms='&2' code='&3'"
                                                              ,(if action = "U"
                                                                then 'ADD':U
                                                                else "DEL":U
                                                                )
                                                              ,OS2-time
                                                              ,if cash-cli.d-card eq ?
                                                               then "*"
                                                               else string(cash-cli.d-card)
                                                              )).
    run bgelib-tag-put in this-procedure ( input 3, input "ACWLCardVer"
                                          ,input cash-cli.ef-format
                                          ,input 0 ).
    run bgelib-tag-put in this-procedure ( input 3, input "ACWLCardKey"
                                          ,input string(cash-cli.ef-access-key, "X(8)")
                                          ,input 0 ).
    define buffer buf_stop-list for ub.stop-list.
    define buffer buf_stop-list-line for ub.stop-list-line.
    for last buf_stop-list share-lock where
            buf_stop-list.classif-type = 'dis-card':U
         and buf_stop-list.status_ = 'факт':U
         use-index fact-order
        ,first buf_stop-list-line no-lock where
            buf_stop-list-line.classif-type =  'dis-card':U
        and buf_stop-list-line.stop-list-code = buf_stop-list.stop-list-code
        and buf_stop-list-line.charkey_one = cash-cli.d-card
        :
      leave.
    end.
    run bgelib-tag-put in this-procedure ( input 3, input "ACWLCardStop"
                                          ,input (if available buf_stop-list-line then
                                                  string("yes")
                                                  else string("no"))
                                          ,input 0 ).
    run bgelib-tag-put in this-procedure ( input 3, input "ACWLCardAStop"
                                          ,input string("no")
                                          ,input 0 ).
    run bgelib-tag-close in this-procedure ( input 2, input "ACWhiteList").
  end.
if cash-cli.has-attrs-lim = yes
    then
  do:
  define variable ii        as integer    no-undo .
  define variable v-sum-id  as character  no-undo .
  define variable v-group   as integer    no-undo .
    for each cash-cli-attr where
      cash-cli-attr.d-card = cash-cli.d-card and cash-cli-attr.dc-sum-id <> "" and cash-cli-attr.caller_id <> "":
             ii = 0 .
      run bgelib-tag-open in this-procedure ( input 2, input "CardClass"
                                            , input substitute("ctrl='&1' code='&2' tms='&3'"
                                            ,'ADD', cash-cli-attr.caller_id, OS2-time)
                                            ).
          run bgelib-tag-put in this-procedure ( input 3, input "CCRBegin"
                                                ,  input cash-cli-attr.dc-minnum
                                                , input 0 ).
          run bgelib-tag-put in this-procedure ( input 3, input "CCREnd"
                                                ,  input cash-cli-attr.dc-maxnum
                                                , input 0 ).
          run bgelib-tag-put in this-procedure ( input 3, input "CCNoUse"
                                                ,  input 0
                                                , input 0 ).
          run bgelib-tag-put in this-procedure ( input 3, input "CCClassCode"
                                                ,  input 0
                                                , input 0 ).
          run bgelib-tag-put in this-procedure ( input 3, input "CCClassNum"
                                                ,  input cash-cli-attr.caller_id
                                                , input 0 ).
          run bgelib-tag-put in this-procedure ( input 3, input "CCClassLen"
                                                ,  input 1
                                                , input 0 ).
      run bgelib-tag-close in this-procedure ( input 2, input "CardClass").
      run bgelib-tag-open in this-procedure ( input 2, input "ClassApproved"
                                            , input substitute("ctrl='&1' code='&2' tms='&3'"
                                            ,'ADD' , cash-cli-attr.caller_id, OS2-time )).
      do ii = 1 to num-entries(cash-cli-attr.dc-sum-id):
        assign
          v-sum-id = ""
          v-group = 0
          .
          v-sum-id = entry(ii, cash-cli-attr.dc-sum-id) no-error.
          if ii = 1 then do: v-group = integer(entry(2,v-sum-id,"-")) no-error. end. else v-group = integer(v-sum-id).
          run bgelib-tag-open in this-procedure ( input 3, input "CAGroup", input ""
                                                 ).
                run bgelib-tag-put in this-procedure ( input 4, input "CAGNumber"
                                                      ,  input v-group
                                                      , input 0 ).
          run bgelib-tag-close in this-procedure ( input 3, input "CAGroup").
      end.
      run bgelib-tag-close in this-procedure ( input 2, input "ClassApproved").
    end.
  end.
  end.
  when 'MAGIA-XML':U then do:
    if not cash-cli.mask-card then do:
      run ref/dcard05.p (
                       input cash-cli.d-card
                      ,input cash-cli.type
                      ,input cash-cli.emitent-host-code
                      ,input i-obj-code
                      ,output v-cli-mask
                      ,output v-full-number
                      ) no-error .
      if error-status:error
      or
      v-full-number = '':U
      then do:
        return error
        substitute("&1&2&3"
                    , error-status:get-message(1)
                    , chr(10)
                    , return-value
                    ).
      end.
      v-magia-kat-pcnt = cash-cli.kat-pcnt.
      find first root_cash-dis-rule where
               root_cash-dis-rule.rule-num = v-magia-kat-codes-rule no-error.
      if available root_cash-dis-rule then do:
        case root_cash-dis-rule.templ-rl-root:
          when 79 then do:
      find first cash-dis-rule where
                      cash-dis-rule.templ-rl-root = root_cash-dis-rule.templ-rl-root
                  and cash-dis-rule.rl-root = root_cash-dis-rule.rule-num
            and cash-dis-rule.dis-kat = cash-cli.kat-pcnt no-error.
      if available cash-dis-rule then do:
         v-magia-kat-pcnt = cash-dis-rule.key#_one.
      end.
          end.
          when 80 then do:
            for each cash-dis-rule where
                      cash-dis-rule.templ-rl-root = root_cash-dis-rule.templ-rl-root
                  and cash-dis-rule.rl-root = root_cash-dis-rule.rule-num
            by cash-dis-rule.discnt-value descending:
              if cash-dis-rule.discnt-value <= cash-cli.d-pcnt then do:
                v-magia-kat-pcnt = cash-dis-rule.dis-kat.
                leave.
              end.
            end.
          end.
        end case.
      end.
      else do:
         v-magia-kat-pcnt = cash-cli.kat-pcnt.
      end.
      if v-magia-kat-pcnt > 15 then do:
        return error
        substitute("Нельзя переслать на кассу &1 карту с категорией MAGIA > 15:&2Карта &3 категория IBS TH &4, категория MAGIA &5"
                   , 'MAGIA-XML':U
                   , chr(10)
                   , cash-cli.d-card
                   , cash-cli.kat-pcnt
                   , v-magia-kat-pcnt).
      end.
      run bgelib-tag-open in this-procedure ( input 2, input "Card",
                                            input substitute("ctrl='&1' tms='&2'"
                                          , (if g#news or g#esys or run-from = "O":U or run-from = "E":U
                                              then
                                                (if lookup('тек':U, cash-cli.status_ ) > 0
                                                then "ADD":U
                                                else "DEL":U
                                                )
                                              else (if action = "U"
                                                    then 'ADD':U
                                                    else "DEL":U
                                                    )
                                            )
                                          , OS2-time
                                          )).
        run bgelib-tag-put in this-procedure ( input 3, input "ClientName"       , input entry(1, cash-cli.cli-name, chr(4))
                                              , input 1 ).
        if cash-cli.cli-name2 <> "":u then
        run bgelib-tag-put in this-procedure ( input 3, input "ClientName2"       , input  cash-cli.cli-name2, input 1 ).
        if cash-cli.cli-name3 <> "":u then
        run bgelib-tag-put in this-procedure ( input 3, input "ClientName3"       , input  cash-cli.cli-name3, input 1 ).
        if cash-cli.cli-city <> "":u then
        run bgelib-tag-put in this-procedure ( input 3, input "ClientCity"       , input cash-cli.cli-city, input 1 ).
        if cash-cli.cli-adr <> "":u then
        run bgelib-tag-put in this-procedure ( input 3, input "ClientAddress"    , input cash-cli.cli-adr, input 1 ).
        if string(cash-cli.cli-ind) <> "":u then
        run bgelib-tag-put in this-procedure ( input 3, input "ClientIndex"      , input string(cash-cli.cli-ind), input 1 ).
        if cash-cli.cli-phone <> "":u then
        run bgelib-tag-put in this-procedure ( input 3, input "ClientPhone"      , input cash-cli.cli-phone, input 1 ).
        if cash-cli.cli-INN <> "":u then
        run bgelib-tag-put in this-procedure ( input 3, input "ClientINN"        , input cash-cli.cli-inn, input 1 ).
        run bgelib-tag-put in this-procedure ( input 3, input "ClientJustFace"   , input string(cash-cli.justface), input 1 ).
        if cash-cli.passport <> "":u
        and cash-cli.passport <> chr(4)
        then
        run bgelib-tag-put in this-procedure ( input 3, input "ClientPassport"    ,
                                                        input replace(cash-cli.passport, chr(4), chr(32)) , input 1 ).
        if cash-cli.given-by <> "":u then
        run bgelib-tag-put in this-procedure ( input 3, input "ClientPassportPlace" , input cash-cli.given-by, input 1 ).
      if cash-cli.emitent-host-code = 0 then  do:
        assign
        v-r-b-code = 0
        no-error
        .
      end.
      else do:
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run r-b-curr in g#library
  (input  ub.shop.host-code
  ,output v-r-b-code
  )  .
      end.
      if error-status:error then do:
        return error
        substitute("Карта &1:не удалось определить код валюты продажи для типа карт &2: код эмитента &3"
                  ,  cash-cli.d-card
                  , cash-cli.type
                  ,  cash-cli.emitent-host-code
                  ).
      end.
      else do:
        if cash-cli.pay-code <> 0 then do:
          find first buf_cash-pay no-lock where
                    buf_cash-pay.cdpay-code = cash-cli.pay-code
                AND buf_cash-pay.curr-code = v-r-b-code no-error .
          if error-status:error then do:
            return error
            substitute("Карта &1:не найден тип кассового платежа для типа карт &2: код платежа &3, код валюты &4"
                      ,  cash-cli.d-card
                      , cash-cli.type
                      ,  cash-cli.pay-code
                      , v-r-b-code).
          end.
          find first buf_currency no-lock where
                    buf_Currency.curr-code = v-r-b-code no-error .
          if error-status:error then do:
            return error
          substitute("Карта &1:не найдена валюта для типа кассового платежа для типа карт &2: код платежа &3, код валюты &4"
                    ,  cash-cli.d-card
                    , cash-cli.type
                    ,  cash-cli.pay-code
                    , v-r-b-code).
          end.
        end.
      end.
      assign
      v-magia-card-operation = if cash-cli.credit-card then 1
                                else (if cash-cli.staff-card
                                      then 3
                                      else ( if cash-cli.debet-card
                                            then 2
                                            else 0
                                            )
                                    )
      v-magia-curr-code = (if available buf_cash-pay
                          then (if buf_cash-pay.is-cash
                                  then (if buf_currency.curr-code = 0 then 1 else buf_currency.okv-code)
                                  else (10000 + cash-cli.pay-code)
                                  )
                          else ?)
      .
      run bgelib-tag-put in this-procedure ( input 3, input "ClientCode"       , input string(cash-cli.cli-code + 1000000000 * cash-cli.justface), input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "CardDisCat"       , input string(v-magia-kat-pcnt), input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "CardType"        , input string(cash-cli.card-media), input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "CardOperation"   , input string(v-magia-card-operation), input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "CardNumber"      , input v-full-number, input 1 ).
      if cash-cli.cli-message <> ?
      then
      run bgelib-tag-put in this-procedure ( input 3, input "CardMessage"     , input string(cash-cli.cli-message), input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "CardFiscal"      ,  input string(if cash-cli.fiscal-pay then 1 else 0), input 1 ).
      if v-magia-curr-code <> ? then
      run bgelib-tag-put in this-procedure ( input 3, input "CardCurrCode"    ,  input string(v-magia-curr-code), input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "CardMixedPay"    ,  input string(if cash-cli.mixed-pay then 1 else 0), input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "CardSaldo"        , input string(cash-cli.current-saldo), input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "CardLimit"        , input string(- cash-cli.lim-kr), input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "CardLock"         ,
                                          input string(if lookup('тек':U, cash-cli.status_ ) > 0
                                                              then 0
                                                              else 1
                                                      )
                                                      , input 1 ).
      run bgelib-tag-close in this-procedure ( input 2, input "Card").
    end.
  end.
  when 'IPC-Servis+':U then  do:
    FIND FIRST ub.dis-card-type No-LOCK WHERE
                ub.dis-card-type.type = cash-cli.type AND
                ub.dis-card-type.emitent-host-code = cash-cli.emitent-host-code AND
                ub.dis-card-type.host-code = 0 AND
                ub.dis-card-type.obj-type = "":U AND
                ub.dis-card-type.obj-code = 0 No-ERROR.
    if not cash-cli.mask-card then do:
      PUT UNFORMATTED
      (ub.dis-card-type.dc-pfx + cash-cli.d-card) ","
      '"' caps( string( entry(1, cash-cli.cli-name, chr(4)), "x(20)")) '"' ","
      string( if cash-cli.d-pcnt-byshop
            then (v-d-pcnt)
            else ( cash-cli.d-pcnt ) , "->>9.99" ) ","
      string( 0, ">>>>>>>>9")
      SKIP.
    end.
  end.
  when 'OMRON':U then do:
    if not cash-cli.mask-card then do:
      PUT unformatted
      string( fill( " ", 12 - length( trim( cash-cli.d-card ) ) ) + trim( cash-cli.d-card ))
      "000000000000"
      caps( string( entry(1, cash-cli.cli-name, chr(4)), "x(20)" ) )
      fill( " ", 20)
      caps( string( cash-cli.cli-adr , "x(25)" ) )
      caps( string( cash-cli.cli-city , "x(20)" ) )
      string( cash-cli.cli-ind, ">>>>>9" )
      fill(" ", 14)
      fill(" ", 14)
      string(today, "999999")
      (if g#news or g#esys or run-from = "O":U or run-from = "E":U then
              (if lookup('тек':U, cash-cli.status_ ) > 0 then "U":U
              else "D":U)
              else string( action, "x(1)" )
              )
      string( if cash-cli.d-pcnt-byshop
              then ( round(v-d-pcnt, 2) * 100 )
              else ( round(cash-cli.d-pcnt, 2) * 100 )
            , "9999" )
      SKIP
      .
    end.
  end.
  when 'OMRON-NEW':U then  do:
    if not cash-cli.mask-card then do:
      assign
      v-versiond = decimal(p-version)
      no-error .
      if v-versiond >= 33.0 then do:
        PUT unformatted
        string( fill( "0", 12 - length( trim( cash-cli.d-card ) ) ) + trim( cash-cli.d-card ))
        "000000000000"
        caps( string( entry(1, cash-cli.cli-name, chr(4)), "x(20)" ) )
        fill( " ", 20)
        caps( string( cash-cli.cli-adr , "x(25)" ) )
        caps( string( cash-cli.cli-city , "x(20)" ) )
        string( cash-cli.cli-ind, ">>>>>9" )
        fill(" ", 14)
        fill(" ", 14)
        string(today, "999999")
        (if g#news or g#esys or run-from = "O":U or run-from = "E":U then
                (if lookup('тек':U, cash-cli.status_ ) > 0 then "U":U
                else "D":U)
                else string( action, "x(1)" )
                )
        string( if cash-cli.d-pcnt-byshop
                then ( round(v-d-pcnt, 2) * 100 )
                else ( round(cash-cli.d-pcnt, 2) * 100 )
              , "9999" )
        replace(string(today, "99/99/9999"), chr(47), "":U)
        '00':U
        '000':U
        fill( chr(32) , 31)
        SKIP.
      end.
      else do:
        PUT unformatted
        string( fill( " ", 12 - length( trim( cash-cli.d-card ) ) ) + trim( cash-cli.d-card ))
        "000000000000"
        caps( string( entry(1, cash-cli.cli-name, chr(4)), "x(20)" ) )
        fill( " ", 20)
        caps( string( cash-cli.cli-adr , "x(25)" ) )
        caps( string( cash-cli.cli-city , "x(20)" ) )
        string( cash-cli.cli-ind, ">>>>>9" )
        fill(" ", 14)
        fill(" ", 14)
        string(today, "999999")
        (if g#news or g#esys or run-from = "O":U or run-from = "E":U then
                (if lookup('тек':U, cash-cli.status_ ) > 0 then "U":U
                else "D":U)
                else string( action, "x(1)" )
                )
        string( if cash-cli.d-pcnt-byshop
                then ( round(v-d-pcnt, 2) * 100 )
                else ( round(cash-cli.d-pcnt, 2) * 100 )
              , "9999" )
        SKIP
        .
      end.
    end.
  end.
  when 'NCR-GM':U
  or when 'NCR-AS@R':U
  then do:
    if length(cash-cli.d-card) > (if pos-type = 'NCR-GM':U then 10 else 12) then do:
      if not (g#news or g#esys) then  do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("!Ошибка при пересылке на кассу: Данные по дисконтной карте &1 не могут быть переданы на кассу NCR"
                   , cash-cli.d-card )
                                              ).
      end.
      return .
    end.
    if cash-cli.kat-pcnt <> 0
    AND (cash-cli.kat-pcnt < 10
    or cash-cli.kat-pcnt > 99)
    then do:
      if not (g#news or g#esys) then  do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("!Ошибка при пересылке на кассу:&2Данные по дисконтной карте &1 не могут быть переданы на кассу NCR&2" +
                               "Неверное значение категории карты: &3"
                               , cash-cli.d-card
                               , chr(10)
                               , cash-cli.kat-pcnt
                               )
                                              ).
      end.
      return .
    end.
    if not cash-cli.mask-card then do:
      if (g#news or g#esys or run-from = "O":U or run-from = "E":U ) and
          lookup('тек':U, cash-cli.status_ ) = 0  or
          action = "D":U then do:
        PUT stream IBMstream unformatted
        "C1":U
        fill(chr(32), (if pos-type = 'NCR-GM':U then 4 else 2))
        string( fill( chr(32), (if pos-type = 'NCR-GM':U then 10 else 12) - length( trim( cash-cli.d-card ) ) ) + trim( cash-cli.d-card ) )
        "-":U
        fill("-":U, 61)
        chr(10)
        "C2":U
        fill(chr(32), (if pos-type = 'NCR-GM':U then 4 else 2))
        string( fill( chr(32), (if pos-type = 'NCR-GM':U then 10 else 12) - length( trim( cash-cli.d-card ) ) ) + trim( cash-cli.d-card ) )
        "-":U
        fill("-":U, 61)
        chr(10)
        .
      end.
      else do:
        PUT stream IBMstream unformatted
        "C1":U
        fill(chr(32), (if pos-type = 'NCR-GM':U then 4 else 2))
        string( fill( chr(32), (if pos-type = 'NCR-GM':U then 10 else 12) - length( trim( cash-cli.d-card ) ) ) + trim( cash-cli.d-card ) )
        "00":U
        string(cash-cli.kat-pcnt, "99")
        replace(string((if cash-cli.d-pcnt-method = integer('1':U)
                      or cash-cli.d-pcnt-method = integer('3':U)
                      then cash-cli.d-pcnt
                      else 0), "999.9":U ), ".":U, "")
        replace(string((if cash-cli.d-pcnt-method = integer('2':U)
                      or cash-cli.d-pcnt-method = integer('3':U)
                      then cash-cli.cash-d-pcnt
                      else 0), "999.9":U ), ".":U, "")
        "0000":U
        "00000000":U
        replace(string(cash-cli.lim-kr, "999999.99":U ), ".":U, "":U)
        caps( string( entry(1, cash-cli.cli-name, chr(4)), "x(30)" ) )
        chr(10)
        "C2":U
        fill(chr(32), (if pos-type = 'NCR-GM':U then 4 else 2))
        string( fill( chr(32), (if pos-type = 'NCR-GM':U then 10 else 12) - length( trim( cash-cli.d-card ) ) ) + trim( cash-cli.d-card ) )
        fill(chr(32), 2)
        caps( string( cash-cli.cli-adr , "x(30)" ) )
        (if cash-cli.property-value-chr[1] <> '':U
        then (cash-cli.property-value-chr[1] + chr(32) + cash-cli.property-value-chr[2])
        else
        (string( cash-cli.cli-ind, ">>>>>9" ) + chr(32) + caps( string( cash-cli.cli-city , "x(23)" ) ))
        )
        chr(10)
        .
      end.
    end.
  end.
  when 'r-keeper':U then do:
    if g#news
    or g#esys
    or action <> "D"
    and not cash-cli.mask-card
    then do:
      if length(cash-cli.d-card) > 9 then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("!Невозможно переслать на кассу типа &1 карту &2: слишком длинный номер карты"
                              , cash-cli.d-card
                              , 'r-keeper':U
                              )
                                              ).
      end.
      put stream IBMStream unformatted
      cash-cli.d-card chr(44)
      windows-date-format(if cash-cli.valid-date = 12/31/9999
             then (today + 36500)
             else cash-cli.valid-date, v-date-format) chr(44)
      chr(44)
      chr(44)
      chr(44)
      entry(1, cash-cli.cli-name, chr(4)) chr(44)
      (if not cash-cli.credit-card
      then 0
      else 4
      )  chr(44)
    cash-cli.lim-kr
      skip.
    end.
  end.
  when 'MARIA':U then do:
    if p-send-cli then do:
      find first buf_cd-clu EXCLUSIVE-LOCK where
                buf_cd-clu.obj-type = 'маг':U
            and buf_cd-clu.obj-code = abs((if g#news or g#esys then buf_cash-desk.obj-code else i-obj-code))
            and buf_cd-clu.pos-type = 'MARIA':U
            and buf_cd-clu.clu-type = '':U
            AND buf_cd-clu.cli-type = cash-cli.cli-type
            AND buf_cd-clu.cli-code = cash-cli.cli-code  NO-ERROR.
      if not available buf_cd-clu then do:
        if v-del-mrkt-cli = no then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("!!!Клиент &1&2 &3 не включен в число КЛИЕНТОВ НА КАССЕ &4 &5&6&7" +
                                  "пропускается...."
                                  , cash-cli.cli-type
                                  , cash-cli.cli-code
                                  , cash-cli.obj-name
                                  , pos-type
                                  , 'маг':U
                                  , (if g#news or g#esys then buf_cash-desk.obj-code else i-obj-code)
                                  , chr(10)
                                  )
                                    ).
        end.
      end.
      assign
      v-clu = buf_cd-clu.clu-code.
      if (buf_cd-clu.to-del and v-del-mrkt-cli)
      or action = "D" then do:
        assign
        v-marketer-action = "D":U.
        if v-del-mrkt-cli then do:
          create temp-cd-clu.
          buffer-copy buf_cd-clu
          to temp-cd-clu
          assign
          buf_cd-clu.charkey_one = v-cd-list-delete
          .
        end.
        else do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("!!!Клиент &1&2 &3 может быть удален с кассы типа &4 ТОЛЬКО при удалении из числа КЛИЕНТОВ НА КАССЕ &4 &5&6&7" +
                                  "пропускается...."
                                  , cash-cli.cli-type
                                  , cash-cli.cli-code
                                  , cash-cli.obj-name
                                  , pos-type
                                  , 'маг':U
                                  , (if g#news or g#esys then buf_cash-desk.obj-code else i-obj-code)
                                  , chr(10)
                                  )
                                    ).
          v-view-log = yes.
        end.
      end.
      else do:
        assign
        v-marketer-action = action.
        if buf_cd-clu.to-send then do:
          create temp-cd-clu.
          buffer-copy buf_cd-clu
          to temp-cd-clu
          assign
          temp-cd-clu.charkey_two = ""
          temp-cd-clu.to-send = no
          .
        end.
      end.
      run maria-put in this-procedure (
                                      buffer buf_cash-desk
                                    , input out
                                    , input fname
                                    , input yes
                                    , input 0
                                    , input no
                                    , input 1
                                    , input 200
                                    , input string(v-clu)
                                    , input (if v-marketer-action = 'd' then '':U else string(cash-cli.obj-name, "X(18)"))).
      v-maria-discnt-value = string(0, '999').
      if action <> 'D':U  then do:
        _do:
        do v-ii = 1 to 2:
          if v-ii = 1 then
          assign
          v-dc-rule-num = buffer cash-cli:buffer-field("dcr-debet-pay"):buffer-value.
          if v-ii = 2 then
          assign
          v-dc-rule-num = buffer cash-cli:buffer-field("dcr-credit-pay"):buffer-value.
          find first buf_dis-rule no-lock where
            buf_dis-rule.obj-type = 'маг':U
                AND buf_dis-rule.obj-code = i-obj-code
                AND buf_dis-rule.rule-num = v-dc-rule-num
                AND buf_dis-rule.sts = integer('0':U) no-error .
          if available buf_dis-rule then do:
            if buf_dis-rule.discnt-type = integer('13':U) then do:
              assign
              v-maria-discnt-value = string('003')
              .
            end.
            else do:
              if index(dr-list, string(buf_dis-rule.rule-num) + '-') > 0 then do:
                assign
                v-dop = substring(dr-list, index(dr-list, string(buf_dis-rule.rule-num) + '-':U))
                v-dop = substring(v-dop, 1, index(v-dop, chr(44)) - 1)
                v-maria-rule-num = integer(entry(2, v-dop, '-':U)) - 1
                v-maria-discnt-value = string(v-maria-rule-num * 8 + 2, '999')
                .
              end.
            end.
          end.
          else do:
          end.
          entry(v-clu + (v-ii - 1) * 200, v-record, chr(4)) = v-maria-discnt-value.
        end.
      end.
      else do:
        do v-ii = 1 to 2:
          entry(v-clu + (v-ii - 1) * 200, v-record, chr(4)) = v-maria-discnt-value.
        end.
      end.
    end.
  end.
END CASE .
END PROCEDURE .
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE putc-dis-card-mask.
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-pos-type as character no-undo.
define input parameter p-version as character no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-version-dec as decimal no-undo .
define variable v-reg-cahs  as integer  no-undo .
define buffer dis-card for dc-list.
define buffer buf_dis-card-mask for dc-dis-card-mask.
define buffer buf_dis-card-mask-attr  for dc-dis-card-mask-attr.
define buffer buf_dis-card-type for ub.dis-card-type.
define buffer bf_dis-card-type for ub.dis-card-type.
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  i-obj-code
  ,output v-host-code
  )  .
assign
v-version-dec = decimal(p-version) no-error .
_mask:
for each buf_dis-card-mask no-lock where
      buf_dis-card-mask.host-code = 0
    OR (buf_dis-card-mask.host-code = v-host-code
        AND buf_dis-card-mask.obj-code = 0)
    or (buf_dis-card-mask.obj-type = p-obj-type
        AND
        buf_dis-card-mask.obj-code = i-obj-code)
  :
  if buf_dis-card-mask.use-on = integer('2':U) then next.
  find first buf_dis-card-mask-attr no-lock where buf_dis-card-mask-attr.attr-code = "reg-cash" and buf_dis-card-mask-attr.mask-num = buf_dis-card-mask.mask-num no-error .
  if available (buf_dis-card-mask-attr) then do:
   if buf_dis-card-mask-attr.attr-value = "yes" then v-reg-cahs = 1 .
   else v-reg-cahs = 0 .
  end.
  else do:
  find first dis-card-mask-attr no-lock where dis-card-mask-attr.attr-code = "reg-cash" and dis-card-mask-attr.mask-num = buf_dis-card-mask.mask-num no-error .
  if available (dis-card-mask-attr) then do:
   if dis-card-mask-attr.attr-value = "yes" then v-reg-cahs = 1 .
   else v-reg-cahs = 0 .
  end.
  else v-reg-cahs = 0 .
  end.
  find first dis-card no-lock where
             dis-card.d-card = buf_dis-card-mask.mask no-error .
  if available dis-card and
  buf_dis-card-mask.cli-code <> 0 then do:
    find first ub.clients no-lock where
              ub.clients.obj-type = buf_dis-card-mask.cli-type
        AND  ub.clients.obj-code = buf_dis-card-mask.cli-code no-error .
    if not available ub.clients then next _mask.
    find first ub.dis-card-type no-lock where
              ub.dis-card-type.type = buf_dis-card-mask.type
          AND ub.dis-card-type.emitent-host-code = buf_dis-card-mask.emitent-host-code
                no-error .
    if buf_dis-card-mask.cli-code  = 0 then do:
      find first cash-cli no-lock where
                cash-cli.cli-type = buf_dis-card-mask.cli-type
            AND cash-cli.cli-code = buf_dis-card-mask.cli-code no-error .
    end.
    else do:
      find first cash-cli no-lock where
                cash-cli.d-card = buf_dis-card-mask.mask
             no-error .
    end.
  end.
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdpcnt in g#library
  (
   input  buf_dis-card-mask.type
  ,input  buf_dis-card-mask.emitent-host-code
  ,input  0
  ,input  '':U
  ,input  0
  ,input  'def-pcnt':U
  ,output v-d-pcnt0
  )  .
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdpcnt in g#library
  (
   input  buf_dis-card-mask.type
  ,input  buf_dis-card-mask.emitent-host-code
  ,input  0
  ,input  '':U
  ,input  0
  ,input  'def-pcnt':U
  ,output v-cash-d-pcnt0
  )  .
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdpcnt in g#library
  (
   input  buf_dis-card-mask.type
  ,input  buf_dis-card-mask.emitent-host-code
  ,input  0
  ,input  '':U
  ,input  0
  ,input  'def-categ':U
  ,output v-categ0
  )  .
  if v-d-pcnt0 = ? then do:
    v-d-pcnt0 = 0.
  end.
  if v-cash-d-pcnt0 = ? then do:
    v-cash-d-pcnt0 = 0.
  end.
  if v-categ0 = ? then do:
    v-categ0 = 0.
  end.
  CASE p-pos-type:
    when 'IBM':U then do:
      put stream IBMStream unformatted
      '20' chr(32)
      chr(34) string( action, "x(1)" ) chr(34) chr(32)
      string(buf_Dis-card-mask.rank) chr(32)
      chr(34)
      string( fill( chr(32) , 19 - length(trim(string(BUF_DIS-CARD-MASK.mask)))
                  ) + buf_dis-card-mask.mask
            )
      chr(34) chr(32)
      (if v-version-dec >= 4.54
      then 5
      else (if buf_dis-card-mask.cli-code <> 0
            then 2
            else 1)
      ) chr(32)
      chr(34)
      (if buf_dis-card-mask.cli-mask <> '':U
      then replace(buf_dis-card-mask.cli-mask, 'C', chr(63))
      else string(fill( chr(32), 19)))  chr(34)  chr(32)
      chr(34)
      (if buf_dis-card-mask.cli-code <> 0
      then string( fill( chr(32) , 16 - length( trim(string((if BUF_DIS-CARD-MASK.cli-type = 'орг':U then 1 else 0) * 1000000000 + BUF_DIS-CARD-MASK.cli-code ) ) ) )
            + string((if BUF_DIS-CARD-MASK.cli-type = 'орг':U then 1 else 0) * 1000000000 + BUF_DIS-CARD-MASK.cli-code)
            )
      else string(fill( chr(32), 15) + "0":U)
      )  chr(34)  chr(32)
      (if available cash-cli
      then string( if cash-cli.d-pcnt-byshop and avail bf_dis-card-type
              then (- v-d-pcnt)
              else ( - cash-cli.d-pcnt ) , "->>9.99" )
      else string(- v-d-pcnt0, "->>9.99")
      )  chr(32)
      (if available cash-cli
      then  string( cash-cli.kat-pcnt, ">>>9" )
      else  string(v-categ)
      )  chr(32)
      Os2-time
      chr(10).
    end.
    when 'IBM-XML':U then do:
      run bgelib-tag-open in this-procedure ( input 2, input "MaskCard"
                                            , input substitute("code='&1' ctrl='&2' tms='&3'", buf_dis-card-mask.rank
                                            ,(if action = "U":U then if buf_dis-card-mask.stts eq 0
                                                                     then 'ADD'
                                                                     else 'DEL'
                                              else 'DEL')
                                            ,OS2-time)).
      run bgelib-tag-put in this-procedure ( input 3, input "MCCard", input buf_dis-card-mask.mask, input 1 ).
      if v-version-dec >= 1.05 then do:
        run bgelib-tag-put in this-procedure ( input 3, input "MCType", input string(5), input 1 ).
      end.
      else do:
        if buf_dis-card-mask.cli-code  = 0
        then
        run bgelib-tag-put in this-procedure ( input 3, input "MCType", input string(1), input 1 ).
        else
        run bgelib-tag-put in this-procedure ( input 3, input "MCType", input string(2), input 1 ).
      end.
      if buf_dis-card-mask.cli-mask <> '':U
      then
      run bgelib-tag-put in this-procedure ( input 3, input "MCRule"
                                            , input  replace(buf_dis-card-mask.cli-mask, 'C', chr(63))
                                            , input 1 ).
      if buf_dis-card-mask.cli-code <> 0
      then
      run bgelib-tag-put in this-procedure ( input 3, input "MCClient"
                                            , input  string((if buf_dis-card-mask.cli-type = 'орг':U then 1 else 0) * 1000000000 + buf_dis-card-mask.cli-code)
                                            , input 1 ).
      if available cash-cli
      then
      run bgelib-tag-put in this-procedure ( input 3, input "MCValue"
                                           , input  string( if cash-cli.d-pcnt-byshop and avail bf_dis-card-type
                                                            then (- v-d-pcnt)
                                                            else ( - cash-cli.d-pcnt ) , "->>9.99" )
                                           , input 1 ).
      else
      run bgelib-tag-put in this-procedure ( input 3, input "MCValue", input string(- v-d-pcnt0, "->>9.99"), input 1 ).
      if available cash-cli
      then
      run bgelib-tag-put in this-procedure ( input 3, input "MCCat", input string( cash-cli.kat-pcnt, ">>>9" ), input 1 ).
      else
      run bgelib-tag-put in this-procedure ( input 3, input "MCCat", input string(v-categ0), input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "MCLock"
                                          , input string(0), input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "MCBarRead", input string(v-reg-cahs), input 1 ).
      run bgelib-tag-close in this-procedure ( input 2, input "MaskCard").
    end.
  END CASE .
END.
END PROCEDURE .
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE   for-cash-cycle:
DEFINE VARIABLE fname-list as character no-undo .
DEFINE VARIABLE out-list as character no-undo .
DEFINE VARIABLE var-file-num as integer no-undo .
DEFINE VARIABLE v-dir-remote as character no-undo .
DEFINE VARIABLE v-dir-remote-tmp as character no-undo .
define variable v-versiond as decimal no-undo .
define variable v-clu as character no-undo .
define variable v-dc-host-code like ub.sysconf.host-code no-undo .
define variable v-type              as character no-undo .
define buffer for-cash-desk for ub.cash-desk.
define buffer buf_cd-clu for ub.cd-clu.
FOR EACH for-cash-desk NO-LOCK WHERE
        for-cash-desk.db-num = g#db-num AND
        for-cash-desk.pos-type = ub.cash-desk.pos-type AND
        for-cash-desk.obj-code = i-obj-code AND
        for-cash-desk.cash-on  = yes
BREAK
BY for-cash-desk.db-num
BY for-cash-desk.obj-code
BY for-cash-desk.pos-type
BY for-cash-desk.cash-on
BY for-cash-desk.cash-num:
   IF (LOOKUP(ub.cash-desk.pos-type,
              ('NCR-GM':U + chr(44) +
               'IBM-XML':U + chr(44) +
               'MAGIA-XML':U + chr(44) +
               'NCR-AS@R':U )) > 0
     and for-cash-desk.autonomy = integer('1':U)) then NEXT.
  if run-from = "E":U then NEXT.
  if LOOKUP(ub.cash-desk.pos-type,
            'MARIA':U
               ) > 0 then do:
    if for-cash-desk.autonomy = integer('2':U) then do:
      if v-del-mrkt-cli = no then next.
      assign
      v-cd-list-update = for-cash-desk.addr-path
      v-cd-list-delete = for-cash-desk.addr-path
      .
      NEXT.
    end.
    else do:
      if v-cd-list-update = '':U then nExt.
    end.
  end.
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "Пересылка - касса &1", for-cash-desk.cash-num
                        )
                                        ).
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
case for-cash-desk.pos-type:
    when 'IBM-XML':U or when 'Autotank':U
  then do:
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run xml-cd-filename in this-procedure (
      input out
    , output v-xml-file-name
    , output v-xml-file-name-path
    , output v-log-file-name
    , output v-locked
).
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( ("'Пересылка дисконтных карт/клиентов)'" + " &1")
                            , replace( v-xml-file-name-path, "/", "\" ) + "xm1"
                      )
                                      ).
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( "................с параметрами: ... магазин: &1", i-obj-code )
                                      ).
assign
v-obj-list = 'маг':U + string(i-obj-code)
.
run xml-cd-write-header in this-procedure (
      input v-xml-file-name
    , input v-xml-file-name-path
    , input 'data'
    , input "14.0 " + replace( vss-revision + vss-date, "$", " " )
    , input v-obj-list
    , input (
              (IF for-cash-desk.pos-type = 'IBM-XML':U
                then (if for-cash-desk.autonomy = integer('0':U)
                      then  ("маг" + string(for-cash-desk.obj-code) + "_касса" + string(for-cash-desk.cash-num))
                      else ("КМ"   )
                      )
                else ("маг" + string(for-cash-desk.obj-code) +  "_касса" + string(for-cash-desk.cash-num))
                )
            )
    , input (if for-cash-desk.autonomy = integer('0':U) then no else yes)
).
output stream stmxmlout to value( v-xml-file-name-path + "xm1" ) convert target "1251" append.
OS2-time =  string( ( today - date( "01/01/1996" ) ) * 24 * 3600 + time, ">>>>>>>>9").
  end.
  when 'MAGIA-XML':U then do:
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run xml-cd-filename in this-procedure (
      input out
    , output v-xml-file-name
    , output v-xml-file-name-path
    , output v-log-file-name
    , output v-locked
).
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( ("'Пересылка дисконтных карт/клиентов)'" + " &1")
                            , replace( v-xml-file-name-path, "/", "\" ) + "xm1"
                      )
                                      ).
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( "................с параметрами: ... магазин: &1", i-obj-code )
                                      ).
assign
v-obj-list = 'маг':U + string(i-obj-code)
.
run xml-cd-write-header in this-procedure (
      input v-xml-file-name
    , input v-xml-file-name-path
    , input 'data'
    , input "14.0 " + replace( vss-revision + vss-date, "$", " " )
    , input v-obj-list
    , input (
              (IF for-cash-desk.pos-type = 'IBM-XML':U
                then (if for-cash-desk.autonomy = integer('0':U)
                      then  ("маг" + string(for-cash-desk.obj-code) + "_касса" + string(for-cash-desk.cash-num))
                      else ("КМ"   )
                      )
                else ("маг" + string(for-cash-desk.obj-code) +  "_касса" + string(for-cash-desk.cash-num))
                )
            )
    , input (if for-cash-desk.autonomy = integer('0':U) then no else yes)
).
output stream stmxmlout to value( v-xml-file-name-path + "xm1" ) convert target "1251" append.
OS2-time =  string( ( today - date( "01/01/1996" ) ) * 24 * 3600 + time, ">>>>>>>>9").
  end.
  when 'IBM':U
  or
  when 'Emulator-NKT-IBM':U
  then do:
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if for-cash-desk.cash-os = ""
AND for-cash-desk.pos-type <> 'Emulator-NKT-IBM':U
then NEXT.
assign
Cash-OS2 = (for-cash-desk.cash-os = "OS/2":U) OR (for-cash-desk.cash-os = "LINUX":U)
            AND for-cash-desk.pos-type <> 'Emulator-NKT-IBM':U
Cash-DOS = NOT CASH-OS2
fname = substring( string( next-value( s-spool, ub ), '99999999999999999999'), 13, 8 )
v-dir-remote-tmp = v-remote + "tmp":U
v-dir-remote = v-remote + "out":U + string(for-cash-desk.obj-code, "99999") + "-" + string(for-cash-desk.cash-num, "999")
.
if for-cash-desk.remote = 1 then do:
  run gbl/dir-cre.p ( input v-dir-remote-tmp) no-error .
    if error-status:error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("!!!Каталог &1  для отсылки запроса на удаленную кассу &2 не найден&3" +
                            "и/или попытка его создания не удалась"
                            ,v-dir-remote-tmp
                            ,for-cash-desk.cash-num
                            ,chr(10)
                            )
                                            ).
      NEXT.
  end.
  run gbl/dir-cre.p ( input v-dir-remote ) no-error .
    if error-status:error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("!!!Каталог &1  для отсылки запроса на удаленную кассу &2 не найден&3" +
                            "и/или попытка его создания не удалась"
                            ,v-dir-remote
                            ,for-cash-desk.cash-num
                            ,chr(10)
                            )
                                            ).
      NEXT.
    end.
end.
output stream IBMStream
to value( (if for-cash-desk.remote = 1
            then (v-dir-remote-tmp + chr(47) + "fl":U)
            else out) + fname + '.dat' ) convert target "ibm866".
OS2-time =       ( if Cash-OS2 then
                                    string( ( today - date( "01/01/1996" ) ) * 24 * 3600 + time, ">>>>>>>>9" )
                      else "" )
.
  end.
  when 'OMRON-NEW':U then do:
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
v-versiond = decimal(for-cash-desk.version)
no-error .
if error-status:error
or v-versiond < 0 then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input  substitute("Неверное значение поля <ВЕРСИЯ> &1 для кассы типа &2 № &3 в справочнике касс&4" +
              "Значение версии может быть только десятичным числом > 0"
              ,for-cash-desk.version
              ,for-cash-desk.pos-type
              ,for-cash-desk.cash-num
              ,chr(10)
              ) ).
  return error .
end.
  assign
  out = (for-cash-desk.addr-path + "out\":U )
  fname = 'client'.
  output to value( out + fname + '.dat':U ) convert target "ibm866".
  end.
  when 'IPC-Servis+':U then do:
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  assign
  out = for-cash-desk.addr-path + "in\":U
  fname = "disccli":U
  .
  output to value(
  string( session:temp-directory + "cli":U + string( var-report-num ) ) + '.cli':U
        )
  convert target "ibm866".
  end.
  when 'NCR-GM':U then do:
define variable vss-include-info56 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  fname = substring( string( next-value( s-spool, ub ), '99999999999999999999'), 13, 8 ).
  output stream IBMStream
  to value( out + fname + '.dat' ) convert target "ibm866".
  .
  end.
  when 'NCR-AS@R':U then do:
define variable vss-include-info57 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  fname = substring( string( next-value( s-spool, ub ), '99999999999999999999'), 13, 8 ).
  output stream IBMStream
  to value( out + fname + '.dat' ) convert target "ibm866".
  .
  end.
  when 'r-keeper':U then do:
define variable vss-include-info58 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
fname = substring( string( next-value( s-spool, ub), '99999999999999999999'), 13, 8 )
.
output stream IBMStream
to value( out + fname + '.txt' ) convert target "1251".
  end.
  when 'MARIA':U then do:
define variable vss-include-info59 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
fname = substring( string( next-value( s-spool, ub ), '99999999999999999999'), 13, 8 ).
   v-record = fill( chr(63) + chr(4), 400).
  end.
END CASE.
  _cash-cli:
  FOR EACH cash-cli
  where ((NOT (g#news or g#esys OR run-from = "S":U or run-from = "O":U))  OR (cash-cli.crf <= cr))
  NO-LOCK
  BREAK
  by cash-cli.cli-type
  by cash-cli.cli-code
  :
    if cash-cli.cli-code eq ?
    then do:
    end.
    else if for-cash-desk.pos-type = 'MARIA':U then do:
    end.
    else do:
      FIND FIRST ub.dis-card-type No-LOCK WHERE
                  ub.dis-card-type.type = cash-cli.type and
                  ub.dis-card-type.emitent-host-code = cash-cli.emitent-host-code AND
                  ub.dis-card-type.host-code = 0 AND
                  ub.dis-card-type.obj-type = "":U AND
                  ub.dis-card-type.obj-code = 0 NO-ERROR.
      if not avail ub.dis-card-type then NEXT _cash-cli.
      if LOOKUP(string(i-obj-code), ub.dis-card-type.dcbyshop) > 0 AND (cash-cli.issue-code <> i-obj-code) then
      NEXT _cash-cli.
    end.
    if first-of(for-cash-desk.obj-code) then do:
      glog = dct-algo-get_dcproperty-value-chr (
                                      input cash-cli.d-card
                                    , input cash-cli.emitent-host-code
                                    , input cash-cli.type
                                    , input 0
                                    , input '':U
                                    , input 0
                                    , output v-property-value-chr
                                      ).
      do v-ii = 1 to min(num-entries(v-property-value-chr), 4):
        if entry(v-ii, v-property-value-chr)  <> chr(63) then do:
          assign
          cash-cli.property-value-chr[v-ii] = v-property-value-chr
          .
        end.
        else do:
          assign
          cash-cli.property-value-chr[v-ii] = '':U
          .
        end.
      end.
    end.
    RUN putc-2 in this-procedure (
                 buffer for-cash-desk
                ,input for-cash-desk.pos-type
                ,input for-cash-desk.version
                ,input first-of(cash-cli.cli-code) ) no-error .
    if error-status:error then do:
      assign
      v-view-log = yes.
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input "!Ошибка при пересылке на кассу: " + (if return-value <> "":U then return-value else "":U)
                                            ).
    end.
  end.
  RUN putc-dis-card-mask ( buffer for-cash-desk
                          ,input for-cash-desk.pos-type
                          ,input for-cash-desk.version ).
define variable vss-include-info60 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
case for-cash-desk.pos-type:
    when 'IBM-XML':U or when 'Autotank':U
  then do:
define variable vss-include-info61 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
output stream stmxmlout close.
run xml-cd-write-footer in this-procedure ( input for-cash-desk.pos-type, input v-xml-file-name-path
    , input 'data'
).
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( "Данные выгружены в файл &1"
                            , replace( v-xml-file-name-path, "/", "\" ) + "xml"
                      )
                                       ).
if (
not (g#news or g#auto or g#esys )
or
(
for-cash-desk.pos-type = 'MAGIA-XML':U
or
  (for-cash-desk.pos-type = 'IBM-XML':U
or (for-cash-desk.pos-type = 'Autotank':U
  and
  for-cash-desk.autonomy = integer('2':U))
  )))
then do:
  if for-cash-desk.pos-type = 'MAGIA-XML':U then do:
    run str/waitpxml.w ( replace( v-xml-file-name-path, "/", "\" ) + "xml",
                (replace(in_ + spl + "/" + v-xml-file-name, "/", "\" ) + ".xml"),
                ( if action = 'U'
                  then ('Ждите - ' + 'добавление дисконтных карт/клиентов')
                  else ('Ждите - ' + 'удаление дисконтных карт/клиентов') ) +
                  substitute("Маг&1 касса&2", for-cash-desk.obj-code, for-cash-desk.cash-num),
                  ' Подождите 15 сек ',
                  'Касса не ответила. Если Вы уверены, что с ней нет связи нажмите кнопку!',
                  'Подождите: касса обрабатывает запрос',
                  15 ) no-error.
    if error-status:error then do:
      os-delete value( replace( v-xml-file-name-path, "/", "\" ) + "xml" ) .
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Прерван обмен информацией с кассой &1, на кассе осталась устаревшая информация",
                                for-cash-desk.cash-num
                            )
                                            ).
      assign
      v-view-log = yes
      .
      return "error":U.
    end.
  end.
  if (for-cash-desk.pos-type = 'IBM-XML':U
  and for-cash-desk.autonomy = integer('0':U))
  or (for-cash-desk.pos-type = 'Autotank':U
  and for-cash-desk.autonomy = integer('2':U))
  then do:
    run str/post-xml.p
      (
       input parparentproc
      ,input p-parent-handle
      ,input p-log-handle
      ,input g#news or g#esys
      ,input g#auto
      ,input 'send'
      ,input log-file-name
      ,input (entry(1, for-cash-desk.addr-path, chr(4)) + '://' + entry(2, for-cash-desk.addr-path, chr(4)))
      ,input (replace( v-xml-file-name-path, "/", "\" ) + "xml")
      ,input (replace(in_ + spl + "/" + v-xml-file-name, "/", "\" ) + ".xml")
      ,input 30
      ,input   ( if action = 'U'
                  then ('Ждите - ' + 'добавление дисконтных карт/клиентов')
                  else ('Ждите - ' + 'удаление дисконтных карт/клиентов') ) +
                  substitute("Маг&1 касса&2", for-cash-desk.obj-code, for-cash-desk.cash-num)
      ) no-error .
    if error-status:error
    or return-value = "error" then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Не удалось получить ответ с маг&1 касса &2 об успешной доставке данных:&3&4 &5"
                                ,for-cash-desk.obj-code
                                ,for-cash-desk.cash-num
                                , chr(10)
                                , error-status:get-message(1)
                                , return-value
                            )
                                            ).
      assign
      v-view-log = yes
      .
    end.
  end.
  if not available ub.shop then do:
    find first ub.shop no-lock where
              ub.shop.obj-code = for-cash-desk.obj-code.
  end.
  if
  not (g#news or g#esys)
  then do:
    run str/getxibmf.p (
                    input parparentproc
                  ,input p-log-handle
                  ,input 'маг':U
                  ,input for-cash-desk.obj-code
                  ,input ub.shop.host-code
                  ,input in_
                  ,input spl
                  ,input (in_ + sav)
                  ,input for-cash-desk.pos-type
                  ,input (if (for-cash-desk.pos-type = 'IBM-XML':U
                          and for-cash-desk.autonomy = integer('0':U))
                          or (for-cash-desk.pos-type = 'Autotank':U
                          and for-cash-desk.autonomy = integer('2':U))
                          then "utf-8":U
                          else "windows-1251")
                  ,input log-file-name
                  ,input "data":U
                  ,input v-xml-file-name
                  ,input-output v-view-log
                  ) no-error .
    if error-status:error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Не удалось получить ответ с маг&1 касса &2 об успешной доставке данных"
                                ,for-cash-desk.obj-code
                                ,for-cash-desk.cash-num
                            )
                                            ).
      assign
      v-view-log = yes
      .
    end.
  end.
end.
if g#news
or g#auto
or g#esys
and for-cash-desk.pos-type = 'MAGIA-XML':U
then do:
end.
  end.
  when 'MAGIA-XML':U then do:
define variable vss-include-info62 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
output stream stmxmlout close.
run xml-cd-write-footer in this-procedure ( input for-cash-desk.pos-type, input v-xml-file-name-path
    , input 'data'
).
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( "Данные выгружены в файл &1"
                            , replace( v-xml-file-name-path, "/", "\" ) + "xml"
                      )
                                       ).
if (
not (g#news or g#auto or g#esys )
or
(
for-cash-desk.pos-type = 'MAGIA-XML':U
or
  (for-cash-desk.pos-type = 'IBM-XML':U
or (for-cash-desk.pos-type = 'Autotank':U
  and
  for-cash-desk.autonomy = integer('2':U))
  )))
then do:
  if for-cash-desk.pos-type = 'MAGIA-XML':U then do:
    run str/waitpxml.w ( replace( v-xml-file-name-path, "/", "\" ) + "xml",
                (replace(in_ + spl + "/" + v-xml-file-name, "/", "\" ) + ".xml"),
                ( if action = 'U'
                  then ('Ждите - ' + 'добавление дисконтных карт/клиентов')
                  else ('Ждите - ' + 'удаление дисконтных карт/клиентов') ) +
                  substitute("Маг&1 касса&2", for-cash-desk.obj-code, for-cash-desk.cash-num),
                  ' Подождите 15 сек ',
                  'Касса не ответила. Если Вы уверены, что с ней нет связи нажмите кнопку!',
                  'Подождите: касса обрабатывает запрос',
                  15 ) no-error.
    if error-status:error then do:
      os-delete value( replace( v-xml-file-name-path, "/", "\" ) + "xml" ) .
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Прерван обмен информацией с кассой &1, на кассе осталась устаревшая информация",
                                for-cash-desk.cash-num
                            )
                                            ).
      assign
      v-view-log = yes
      .
      return "error":U.
    end.
  end.
  if (for-cash-desk.pos-type = 'IBM-XML':U
  and for-cash-desk.autonomy = integer('0':U))
  or (for-cash-desk.pos-type = 'Autotank':U
  and for-cash-desk.autonomy = integer('2':U))
  then do:
    run str/post-xml.p
      (
       input parparentproc
      ,input p-parent-handle
      ,input p-log-handle
      ,input g#news or g#esys
      ,input g#auto
      ,input 'send'
      ,input log-file-name
      ,input (entry(1, for-cash-desk.addr-path, chr(4)) + '://' + entry(2, for-cash-desk.addr-path, chr(4)))
      ,input (replace( v-xml-file-name-path, "/", "\" ) + "xml")
      ,input (replace(in_ + spl + "/" + v-xml-file-name, "/", "\" ) + ".xml")
      ,input 30
      ,input   ( if action = 'U'
                  then ('Ждите - ' + 'добавление дисконтных карт/клиентов')
                  else ('Ждите - ' + 'удаление дисконтных карт/клиентов') ) +
                  substitute("Маг&1 касса&2", for-cash-desk.obj-code, for-cash-desk.cash-num)
      ) no-error .
    if error-status:error
    or return-value = "error" then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Не удалось получить ответ с маг&1 касса &2 об успешной доставке данных:&3&4 &5"
                                ,for-cash-desk.obj-code
                                ,for-cash-desk.cash-num
                                , chr(10)
                                , error-status:get-message(1)
                                , return-value
                            )
                                            ).
      assign
      v-view-log = yes
      .
    end.
  end.
  if not available ub.shop then do:
    find first ub.shop no-lock where
              ub.shop.obj-code = for-cash-desk.obj-code.
  end.
  if
  not (g#news or g#esys)
  then do:
    run str/getxibmf.p (
                    input parparentproc
                  ,input p-log-handle
                  ,input 'маг':U
                  ,input for-cash-desk.obj-code
                  ,input ub.shop.host-code
                  ,input in_
                  ,input spl
                  ,input (in_ + sav)
                  ,input for-cash-desk.pos-type
                  ,input (if (for-cash-desk.pos-type = 'IBM-XML':U
                          and for-cash-desk.autonomy = integer('0':U))
                          or (for-cash-desk.pos-type = 'Autotank':U
                          and for-cash-desk.autonomy = integer('2':U))
                          then "utf-8":U
                          else "windows-1251")
                  ,input log-file-name
                  ,input "data":U
                  ,input v-xml-file-name
                  ,input-output v-view-log
                  ) no-error .
    if error-status:error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Не удалось получить ответ с маг&1 касса &2 об успешной доставке данных"
                                ,for-cash-desk.obj-code
                                ,for-cash-desk.cash-num
                            )
                                            ).
      assign
      v-view-log = yes
      .
    end.
  end.
end.
if g#news
or g#auto
or g#esys
and for-cash-desk.pos-type = 'MAGIA-XML':U
then do:
end.
  end.
  when 'IBM':U
  or
  when 'Emulator-NKT-IBM':U
  then do:
define variable vss-include-info63 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
output stream IBMStream close.
output stream IBMStream
to value( (if for-cash-desk.remote = 1
            then (v-dir-remote-tmp + chr(47) + "fl":U)
            else out) + fname + '.ad0' ) convert target "ibm866".
put stream IBMStream ' ' skip(1).
 put stream IBMStream unformatted '  ' for-cash-desk.addr-path ' plu' skip.
output stream IBMStream close.
OS-RENAME
VALUE((if for-cash-desk.remote = 1
        then (v-dir-remote-tmp + chr(47) + "fl":U)
        else out) + fname + '.ad0')
VALUE((if for-cash-desk.remote = 1
        then (v-dir-remote + chr(47) + "fl":U)
        else out) + fname + '.adr').
os-er = OS-ERROR.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( "Данные выгружены в файл &1, файл адреса &2"
                        , ((if for-cash-desk.remote = 1
                            then (v-dir-remote + chr(47) + "fl":U)
                            else out) + fname + '.dat')
                        , ((if for-cash-desk.remote = 1
                            then (v-dir-remote + chr(47) + "fl":U)
                            else out) + fname + '.adr')
                        )
                                       ).
if os-er <> 0 then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!Ошибки в работе локальной сети или нарушение прав доступа при обмене информацией с кассой &1",
                            for-cash-desk.cash-num
                        )
                                        ).
      assign
      v-view-log = yes
      .
      return "error":U.
end.
if for-cash-desk.remote = 1 then do:
  OS-RENAME
  VALUE(v-dir-remote-tmp + chr(47) + "fl":U + fname + '.dat')
  VALUE(v-dir-remote  + chr(47) + "fl":U + fname + '.dat').
  os-er = OS-ERROR.
  if os-er <> 0 then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Ошибки в работе локальной сети или нарушение прав доступа при обмене информацией с кассой &1",
                                for-cash-desk.cash-num
                            )
                                            ).
      assign
      v-view-log = yes
      .
      return "error":U.
  end.
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "Данные выгружены в файл &1",
                            (v-dir-remote  + chr(47) + "fl":U + fname + '.dat')
                        )
                                        ).
end.
else do:
  if not g#news
  and not g#auto
  and not g#esys
  then do:
      run str/waitp.w ( out + fname + '.dat',
                  ( if action = 'U'
                    then ('Ждите - ' + 'добавление дисконтных карт/клиентов')
                    else ('Ждите - ' + 'удаление дисконтных карт/клиентов') ) +
                    for-cash-desk.addr-path,
                    ' Подождите 15 сек ',
                    'Касса не ответила. Если Вы уверены, что с ней нет связи нажмите кнопку!',
                    15 ) no-error.
    if error-status:error then do:
      os-delete value( out + fname + '.adr' ) .
      os-delete value( out + fname + '.ad0' ) .
      os-delete value( out + fname + '.dat' ) .
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Прерван обмен информацией с кассой &1, на кассе осталась устаревшая информация",
                                for-cash-desk.cash-num
                            )
                                            ).
      assign
      v-view-log = yes
      .
      return "error":U.
    end.
  end.
end.
  end.
  when 'OMRON-NEW':U then do:
define variable vss-include-info64 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  output close.
  output to value(out  + 'client.adr') convert target "ibm866".
  if v-versiond >= 33.0 then do:
    put unformatted "OK" skip.
  end.
  output close.
  run str/waitp.w (out + 'client.adr',
                        ( if action = 'U'
                          then 'Ждите - идет добавление клиентов на кассу '
                          else 'Ждите - идет удаление клиентов с кассы ' ) + out,
                        ' Подождите 15 сек ',
                        'Касса не ответила. Если Вы уверены, что с ней нет связи нажмите кнопку!',
                        15 ) no-error.
  if error-status:error then return error.
  end.
  when 'IPC-Servis+':U then do:
define variable vss-include-info65 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  output close.
  assign
  out-list = out-list + (if out-list = '':U then '':U else chr(44)) + out
  fname-list = fname-list + (if fname-list = '':U then '':U else chr(44)) + fname.
  os-append
  value( string( session:temp-directory + "cli" + string( var-report-num ) ) + '.cli' )
  value( out + fname + (if action = "U" then '.udc' else 'cdc')).
  end.
  when 'NCR-GM':U
  then do:
define variable vss-include-info66 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  output stream IBMStream close.
  end.
  when 'NCR-AS@R':U
  then do:
define variable vss-include-info67 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
output stream IBMStream close.
  end.
  when 'r-keeper':U then do:
define variable vss-include-info68 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
output stream IBMStream close.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( "Данные выгружены в файл &1", (out + fname + '.txt')
                        )
                                       ).
  end.
  when 'MARIA':U then do:
define variable vss-include-info69 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-found69 as logical no-undo .
define variable v-is-script69 as logical no-undo.
define variable v-fields-shift69 as integer no-undo .
   if can-find(temp-tekka-tsk where temp-tekka-tsk.task-num = fname and temp-tekka-tsk.obj-num = 1 ) then do:
    v-fields-shift69 = 13.
if v-record <> '':U then
    run maria-put in this-procedure (
                                    buffer for-cash-desk
                                  , input out
                                  , input fname
                                  , input yes
                                  , input v-fields-shift69
                                  , input yes
                                  , input 24
                                  , input 1
                                  , input string(1)
                                  , input v-record
                                    ).
   end.
find first temp-tekka-tsk no-error.
if available temp-tekka-tsk then do:
   v-found69 = yes.
end.
if v-found69 = yes then do:
output stream IBmSTREAM to VALUE(out + fname + '.tsk').
v-is-script69 = no.
for each temp-tekka-tsk:
  if (temp-tekka-tsk.num-rec > 0
  or temp-tekka-tsk.send-get = 'task')
  and temp-tekka-tsk.task-num = fname then do:
    export stream IBmSTREAM temp-tekka-tsk.
    v-found69 = yes.
  end.
  if temp-tekka-tsk.is-script then do:
    v-is-script69 = yes.
  end.
  delete temp-tekka-tsk.
end.
output stream IBMStream
close.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( "Данные выгружены в файлы &1(..),&2файл задания &3"
                        , (out + fname)
                        , chr(10)
                        , (out + fname + '.tsk')
                        )
                                       ).
run str/runtekka.p (
                     input parparentproc
                    ,input p-parent-handle
                    ,input p-log-handle
                    ,input out
                    ,input out
                    ,input fname
                    ,input v-remote
                    ,input v-is-script69
                    ) no-error .
if error-status:error then do:
  for each temp-tekka-tsk:
    os-delete value( temp-tekka-tsk.filename) .
    delete temp-tekka-tsk.
  end.
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!Прерван обмен информацией с кассой &1,&2&3&2на кассе осталась устаревшая информация"
                           ,for-cash-desk.cash-num
                           ,chr(10)
                           ,return-value
                        )
                                        ).
  assign
  v-view-log = yes
  .
    for each temp-cd-clu:
      delete temp-cd-clu.
    end.
  return "error":U.
end.
else do:
  for each temp-cd-clu,
      first buf_cd-clu where
            buf_cd-clu.obj-type = temp-cd-clu.obj-type
       and  buf_cd-clu.obj-code = temp-cd-clu.obj-code
       and  buf_cd-clu.pos-type = temp-cd-clu.pos-type
       and  buf_cd-clu.clu-type = '':U
            :
    if temp-cd-clu.to-del <> yes
    and v-del-mrkt-cli
    then do:
      if lookup(string(for-cash-desk.cash-num), buf_cd-clu.charkey_one) > 0 then do:
        entry(lookup(string(for-cash-desk.cash-num), buf_cd-clu.charkey_one)  ,  buf_cd-clu.charkey_one) = '':U.
        assign
        buf_cd-clu.charkey_one = replace(buf_cd-clu.charkey_one, chr(44) + chr(44), chr(44))
        .
      end.
      if buf_cd-clu.charkey_one = '':U then do:
        delete buf_cd-clu.
        NEXT.
      end.
    end.
    if temp-cd-clu.charkey_two = "":U
    then
    assign
    buf_cd-clu.charkey_two = "":U
    buf_cd-clu.to-send = no
    .
    delete temp-cd-clu.
  end.
end.
end.
run cd-mrkt_update-marketer-cli in this-procedure (
                                                input for-cash-desk.db-num
                                                ,input for-cash-desk.obj-code
                                                ,input for-cash-desk.pos-type
                                                ,input for-cash-desk.cash-num
                                              )  .
    if
 v-del-mrkt-cli
    then do:
define variable vss-include-info70 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info71 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
fname = substring( string( next-value( s-spool, ub ), '99999999999999999999'), 13, 8 ).
   v-record = fill( chr(63) + chr(4), 400).
define variable v-marketer-action as character no-undo .
FOR EACH buf_cd-clu where
        buf_cd-clu.obj-type = 'маг':U
    and buf_cd-clu.obj-code = abs(i-obj-code)
    and buf_cd-clu.pos-type = 'MARIA':U
    and buf_cd-clu.clu-type = '':U
        :
  if buf_cd-clu.to-del then do:
    create temp-cd-clu.
    buffer-copy buf_cd-clu
    to temp-cd-clu
    .
    assign
    v-marketer-action = 'd'
    .
    run maria-put in this-procedure (
                                    buffer buf_cash-desk
                                  , input out
                                  , input fname
                                  , input yes
                                  , input 0
                                  , input no
                                  , input 1
                                  , input 200
                                  , input buf_cd-clu.clu-code
                                  , input '':U).
  end.
END .
define variable vss-include-info72 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-found72 as logical no-undo .
define variable v-is-script72 as logical no-undo.
define variable v-fields-shift72 as integer no-undo .
   if can-find(temp-tekka-tsk where temp-tekka-tsk.task-num = fname and temp-tekka-tsk.obj-num = 1 ) then do:
    v-fields-shift72 = 13.
if v-record <> '':U then
    run maria-put in this-procedure (
                                    buffer for-cash-desk
                                  , input out
                                  , input fname
                                  , input yes
                                  , input v-fields-shift72
                                  , input yes
                                  , input 24
                                  , input 1
                                  , input string(1)
                                  , input v-record
                                    ).
   end.
find first temp-tekka-tsk no-error.
if available temp-tekka-tsk then do:
   v-found72 = yes.
end.
if v-found72 = yes then do:
output stream IBmSTREAM to VALUE(out + fname + '.tsk').
v-is-script72 = no.
for each temp-tekka-tsk:
  if (temp-tekka-tsk.num-rec > 0
  or temp-tekka-tsk.send-get = 'task')
  and temp-tekka-tsk.task-num = fname then do:
    export stream IBmSTREAM temp-tekka-tsk.
    v-found72 = yes.
  end.
  if temp-tekka-tsk.is-script then do:
    v-is-script72 = yes.
  end.
  delete temp-tekka-tsk.
end.
output stream IBMStream
close.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( "Данные выгружены в файлы &1(..),&2файл задания &3"
                        , (out + fname)
                        , chr(10)
                        , (out + fname + '.tsk')
                        )
                                       ).
run str/runtekka.p (
                     input parparentproc
                    ,input p-parent-handle
                    ,input p-log-handle
                    ,input out
                    ,input out
                    ,input fname
                    ,input v-remote
                    ,input v-is-script72
                    ) no-error .
if error-status:error then do:
  for each temp-tekka-tsk:
    os-delete value( temp-tekka-tsk.filename) .
    delete temp-tekka-tsk.
  end.
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!Прерван обмен информацией с кассой &1,&2&3&2на кассе осталась устаревшая информация"
                           ,for-cash-desk.cash-num
                           ,chr(10)
                           ,return-value
                        )
                                        ).
  assign
  v-view-log = yes
  .
    for each temp-cd-clu:
      delete temp-cd-clu.
    end.
  return "error":U.
end.
else do:
  for each temp-cd-clu,
      first buf_cd-clu where
            buf_cd-clu.obj-type = temp-cd-clu.obj-type
       and  buf_cd-clu.obj-code = temp-cd-clu.obj-code
       and  buf_cd-clu.pos-type = temp-cd-clu.pos-type
       and  buf_cd-clu.clu-type = '':U
            :
    if temp-cd-clu.to-del <> yes
    and v-del-mrkt-cli
    then do:
      if lookup(string(for-cash-desk.cash-num), buf_cd-clu.charkey_one) > 0 then do:
        entry(lookup(string(for-cash-desk.cash-num), buf_cd-clu.charkey_one)  ,  buf_cd-clu.charkey_one) = '':U.
        assign
        buf_cd-clu.charkey_one = replace(buf_cd-clu.charkey_one, chr(44) + chr(44), chr(44))
        .
      end.
      if buf_cd-clu.charkey_one = '':U then do:
        delete buf_cd-clu.
        NEXT.
      end.
    end.
    if temp-cd-clu.charkey_two = "":U
    then
    assign
    buf_cd-clu.charkey_two = "":U
    buf_cd-clu.to-send = no
    .
    delete temp-cd-clu.
  end.
end.
end.
run cd-mrkt_update-marketer-cli in this-procedure (
                                                input for-cash-desk.db-num
                                                ,input for-cash-desk.obj-code
                                                ,input for-cash-desk.pos-type
                                                ,input for-cash-desk.cash-num
                                              )  .
    end.
  end.
END CASE.
END .
END PROCEDURE.
define variable vss-include-info73 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE SENDING:
DEFINE VARIABLE fq as integer no-undo .
define variable glog as logical no-undo .
if can-find(first cash-desk No-LOCK WHERE
                  cash-desk.db-num = g#db-num and
                  cash-desk.obj-code = i-obj-code AND
                  cash-desk.cash-on = yes AND
                  cash-desk.pos-type = 'MAGIA-XML':U) then do:
  find first buf_dis-thbj-rule no-lock where
            buf_dis-thbj-rule.obj-type = ''
         and buf_dis-thbj-rule.obj-code = 0
         and buf_dis-thbj-rule.pos-type = 'MAGIA-XML':U
         and buf_dis-thbj-rule.discnt-role = 'kateg-codes':U no-error .
  if available buf_dis-thbj-rule then do:
    v-magia-kat-codes-rule = buf_dis-thbj-rule.rule-num.
    run create-dis-rule in this-procedure ( input buf_dis-thbj-rule.rule-num, yes) no-error .
  end.
end.
FOR EACH ub.cash-desk NO-LOCK WHERE
        ub.cash-desk.db-num = g#db-num AND
         ub.cash-desk.obj-code = i-obj-code AND
        ub.cash-desk.cash-on
BREAK
By ub.cash-desk.pos-type :
  IF FIRST-OF(ub.cash-desk.pos-type) then do:
define variable vss-include-info74 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable dflt-cd74 as character no-undo .
define variable vss-include-info75 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type75 as character no-undo .
define variable v-value-date75 as date no-undo .
define variable v-value-decimal75 as decimal no-undo .
define variable v-value-integer75 as INTEGER no-undo .
define variable v-value-logical75 AS LOGICAL no-undo .
define variable v-tth75 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  'маг':U
    ,input  ub.cash-desk.obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output dflt-cd74
    ,output v-value-date75
    ,output v-value-decimal75
    ,output v-value-integer75
    ,output v-value-logical75
    ,output v-param-type75
    ,INPUT-OUTPUT table-handle v-tth75
    ) no-error .
delete object v-tth75 no-error.
case ub.cash-desk.pos-type:
    when 'IBM-XML':U or when 'Autotank':U
      or
    when 'MAGIA-XML':U
  then do:
define variable vss-include-info76 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run str/get-inis.p (
                input 'маг':U
              , input ub.cash-desk.obj-code
              , input ub.cash-desk.pos-type
              , input cash-desk.remote
              , input "send":U
              , output out
              , output out2
              , output in_
              , output spl
              , output sav
              , output v-remote
              )  no-error .
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("!!!Не удалось получить настройки для  POS типа &1 для маг&2 из ini-файла:&3&4 &5"
                          , ub.cash-desk.pos-type
                          , ub.cash-desk.obj-code
                          , chr(10)
                          , error-status:get-message(1)
                          , return-value )).
  assign
  v-view-log = yes.
  return error.
end.
if ub.cash-desk.pos-type = 'IBM-XML':U
or ub.cash-desk.pos-type = 'Autotank':U
then do:
  file-info:file-name = (out  + "undelivered").
  if file-info:FULL-PATHNAME <> ? then do:
    run str/rsndxibm.p ( input parparentproc
                        ,input p-parent-handle
                        ,input p-log-handle
                        ,input out  + "undelivered" ) no-error.
  end.
end.
  end.
  when 'IBM':U
  or
  when 'Emulator-NKT-IBM':U
  then do:
define variable vss-include-info77 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run str/get-inis.p (
                input 'маг':U
              , input ub.cash-desk.obj-code
              , input ub.cash-desk.pos-type
              , input cash-desk.remote
              , input "send":U
              , output out
              , output out2
              , output in_
              , output spl
              , output sav
              , output v-remote
              )  no-error .
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("!!!Не удалось получить настройки для  POS типа &1 для маг&2 из ini-файла:&3&4 &5"
                          , ub.cash-desk.pos-type
                          , ub.cash-desk.obj-code
                          , chr(10)
                          , error-status:get-message(1)
                          , return-value )).
  assign
  v-view-log = yes.
  return error.
end.
  end.
  when 'OMRON-NEW':U then do:
define variable vss-include-info78 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  end.
  when 'IPC-Servis+':U then do:
define variable vss-include-info79 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  end.
  when 'NCR-GM':U then do:
define variable vss-include-info80 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run str/get-inis.p (
                input 'маг':U
              , input ub.cash-desk.obj-code
              , input ub.cash-desk.pos-type
              , input cash-desk.remote
              , input "send":U
              , output out
              , output out2
              , output in_
              , output spl
              , output sav
              , output v-remote
              )  no-error .
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("!!!Не удалось получить настройки для  POS типа &1 для маг&2 из ini-файла:&3&4 &5"
                          , ub.cash-desk.pos-type
                          , ub.cash-desk.obj-code
                          , chr(10)
                          , error-status:get-message(1)
                          , return-value )).
  assign
  v-view-log = yes.
  return error.
end.
  end.
  when 'NCR-AS@R':U then do:
define variable vss-include-info81 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run str/get-inis.p (
                input 'маг':U
              , input ub.cash-desk.obj-code
              , input ub.cash-desk.pos-type
              , input cash-desk.remote
              , input "send":U
              , output out
              , output out2
              , output in_
              , output spl
              , output sav
              , output v-remote
              )  no-error .
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("!!!Не удалось получить настройки для  POS типа &1 для маг&2 из ini-файла:&3&4 &5"
                          , ub.cash-desk.pos-type
                          , ub.cash-desk.obj-code
                          , chr(10)
                          , error-status:get-message(1)
                          , return-value )).
  assign
  v-view-log = yes.
  return error.
end.
  end.
  when 'r-keeper':U then do:
define variable vss-include-info82 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run str/get-inis.p (
                input 'маг':U
              , input ub.cash-desk.obj-code
              , input 'r-keeper':U
              , input cash-desk.remote
              , input "send":U
              , output out
              , output out2
              , output in_
              , output spl
              , output sav
              , output v-remote
              )  no-error .
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("!!!Не удалось получить настройки для  POS типа &1 для маг&2 из ini-файла:&3&4 &5"
                          , ub.cash-desk.pos-type
                          , ub.cash-desk.obj-code
                          , chr(10)
                          , error-status:get-message(1)
                          , return-value )).
  assign
  v-view-log = yes.
  return error return-value .
end.
run adm/shattri.p (
        input "get":U
        ,input  'маг':U
        ,input  ub.cash-desk.obj-code
        ,input  'cd-type-r-keeper':U
        ,input  'date-format':U
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
  IF not error-status:error then do:
    delete object v-tth.
    v-date-format = v-value-character.
  end.
  else do:
    delete object v-tth.
    return error return-value .
  end.
  end.
END CASE.
    RUN for-cash-cycle no-error.
  END.
  IF LAST-OF(ub.cash-desk.pos-type) then do:
define variable vss-include-info83 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
case ub.cash-desk.pos-type:
  when 'IPC-Servis+':U then do:
define variable vss-include-info84 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  end.
  when 'NCR-GM':U
  then do:
define variable vss-include-info85 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  _lock-gds:
  DO while ind < 100 :
    run gbl/lock-prc.p (
         input 'pncr':U
        ,input i-obj-code
        ,input 0
        ,input 0
        ,input 'маг':U
        ,input "":U
        ,input "":U
        ,input ("Код объекта" + ",,,":U +
                "Тип объекта" +  ",,,":U + 'Пересылка дисконтных карт')
        ,input no
        ,buffer lock-batchprocess
        ) no-error .
    if not error-status:error then do:
      leave _lock-gds.
    end.
    run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "Объект &1: Файл для выгрузки данных ЗАНЯТ - Ждите", i-obj-code
                        )
                                        ).
    pause 1.
  end.
    OS-append
    value( out + fname + '.dat':U )
    value( out + "gmrecmnt.dat":U).
    if search(out + 'debug.flg') = ? then do:
      OS-delete value( out + fname + '.dat':U ).
    end.
    if ub.cash-desk.pos-type = 'NCR-AS@R':U then do:
      output stream ibmstream to value( out + "gmrecmnt.ctl":U).
      put unformatted skip.
      output stream ibmstream close.
    end.
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "Данные выгружены в файл &1"
                            ,( out + "gmrecmnt.dat":U)
                          )
                                         ).
    if g#news
    or g#auto
    or g#esys
    then do:
      run str/waitpn.w (
                   input (out + "gmrecmnt.dat":U)
                  ,input ( if action = 'U'
                            then ('Ждите - ' + 'добавление дисконтных карт')
                            else ('Ждите - ' + 'удаление дисконтных карт') )
                  ,input ' Подождите 15 сек '
                  ,input 15
                  ) no-error.
    end.
    else do:
      run str/waitp.w (
                   input (out + "gmrecmnt.dat":U)
                  ,input ( if action = 'U'
                            then ('Ждите - ' + 'добавление дисконтных карт')
                            else ('Ждите - ' + 'удаление дисконтных карт') )
                  ,input ' Подождите 15 сек '
                  ,input 'Касса не ответила. Если Вы уверены, что с ней нет связи нажмите кнопку!'
                  ,input 15
                  )
                  no-error.
    end.
    if error-status:error then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "!!!Прерван обмен информацией с кассой, на кассе осталась устаревшая информация"
                              )
                                              ).
        os-delete value( out + "gmrecmnt.dat":U).
        assign
        v-view-log = yes
        .
        return "error":U.
    end.
  end.
  when 'NCR-AS@R':U
  then do:
define variable vss-include-info86 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  _lock-gds:
  DO while ind < 100 :
    run gbl/lock-prc.p (
         input 'pncr':U
        ,input i-obj-code
        ,input 0
        ,input 0
        ,input 'маг':U
        ,input "":U
        ,input "":U
        ,input ("Код объекта" + ",,,":U +
                "Тип объекта" +  ",,,":U + 'Пересылка дисконтных карт')
        ,input no
        ,buffer lock-batchprocess
        ) no-error .
    if not error-status:error then do:
      leave _lock-gds.
    end.
    run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "Объект &1: Файл для выгрузки данных ЗАНЯТ - Ждите", i-obj-code
                        )
                                        ).
    pause 1.
  end.
    OS-append
    value( out + fname + '.dat':U )
    value( out + "gmrecmnt.dat":U).
    if search(out + 'debug.flg') = ? then do:
      OS-delete value( out + fname + '.dat':U ).
    end.
    if ub.cash-desk.pos-type = 'NCR-AS@R':U then do:
      output stream ibmstream to value( out + "gmrecmnt.ctl":U).
      put unformatted skip.
      output stream ibmstream close.
    end.
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "Данные выгружены в файл &1"
                            ,( out + "gmrecmnt.dat":U)
                          )
                                         ).
    if g#news
    or g#auto
    or g#esys
    then do:
      run str/waitpn.w (
                   input (out + "gmrecmnt.dat":U)
                  ,input ( if action = 'U'
                            then ('Ждите - ' + 'добавление дисконтных карт')
                            else ('Ждите - ' + 'удаление дисконтных карт') )
                  ,input ' Подождите 15 сек '
                  ,input 15
                  ) no-error.
    end.
    else do:
      run str/waitp.w (
                   input (out + "gmrecmnt.dat":U)
                  ,input ( if action = 'U'
                            then ('Ждите - ' + 'добавление дисконтных карт')
                            else ('Ждите - ' + 'удаление дисконтных карт') )
                  ,input ' Подождите 15 сек '
                  ,input 'Касса не ответила. Если Вы уверены, что с ней нет связи нажмите кнопку!'
                  ,input 15
                  )
                  no-error.
    end.
    if error-status:error then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "!!!Прерван обмен информацией с кассой, на кассе осталась устаревшая информация"
                              )
                                              ).
        os-delete value( out + "gmrecmnt.dat":U).
        assign
        v-view-log = yes
        .
        return "error":U.
    end.
  end.
END CASE.
  END.
END.
END PROCEDURE.
