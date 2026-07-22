block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Посылка всей информации на все магазины БД из новостей".
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
define variable p-db-num like ub.db.db-num no-undo .
define  shared variable himp2Cd as handle no-undo.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared temp-table gds-list no-undo like ub.goods
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define   shared  temp-table gds-list-hist no-undo
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
define   shared  temp-table dc-list no-undo like ub.dis-card
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define    shared   temp-table dc-list-hist no-undo
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
define  shared temp-table dc-dis-card-mask no-undo like ub.dis-card-mask.
define  shared temp-table dc-dis-card-mask-attr no-undo like ub.dis-card-mask-attr.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def   shared  temp-table dcp-list no-undo like ub.dis-card-property
                        field rc as recid
                        field to-del as  logical
                        field order-num as integer
                        index rci is unique rc to-del
                        index d-card-i is primary d-card host-code obj-type obj-code dt-code node-code to-del
                        index iobj obj-type obj-code
                        index io order-num
                        .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def   shared  temp-table stpl-list no-undo like ub.stop-list
                        field rc as recid
                        field to-del as  logical
                        field order-num as integer
                        index rci is unique rc to-del
                        index pi is primary classif-type stop-list-code to-del
                        index iobj obj-type obj-code
                        index io order-num
                        .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def  shared temp-table pbc-list no-undo like ub.prod-bc
                        field rc as recid
                        field del as  logical
                        index rci is unique rc del
                        index gds-code-i b-code del
                        index ibc-on-type bc-on-type
                        .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def  shared temp-table bc-list no-undo like ub.bar-code
                        field del as  logical
                        index bc is unique b-code del
                        index gds-code-i gds-code del.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared temp-table gdsolist no-undo like ub.goods
field qnty   as decimal
field to-del as logical
field order-num as integer
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
index art  is primary unique artic prod-type prod-code obj-type obj-code
index code is         unique gds-code obj-type obj-code
index oi order-num
index iobj obj-type obj-code gds-code
.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE  shared TEMP-TABLE cash-txn no-undo
FIELD tax-code like ub.tax.tax-code
FIELD tax-name like ub.tax.tax-name
FIELD news-action as logical
index pi IS UNIQUE PRIMARY tax-code.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared temp-table cash-txr no-undo
  field tax-code    like ub.tax.tax-code
  field rate-code   like ub.tax-rate.rate-code
  field host-code   like ub.sysconf.host-code
  field obj-type    like ub.clients.obj-type
  field obj-code    like ub.clients.obj-code
  field tax-type    like ub.tax.tax-type
  field status_     like ub.tax-rate-value.status_
  field rate-value  as decimal
  field rc          as recid
  field crf         as integer
  field news-action as logical
  index pi is unique primary tax-code host-code obj-type obj-code status_ rc
  index crf-i  crf host-code obj-type obj-code rc
.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared temp-table pdf-list no-undo like ub.price-doc-forming
field to-del     as logical
field order-num  as integer
index pi  is primary unique plt-id plt-db-num pdf-id pdf-db
index oi order-num
.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE  shared TEMP-TABLE cash-pay-list no-undo
FIELD cdpay-code as integer
FIELD curr-code as integer
index pi IS PRIMARY unique cdpay-code curr-code
.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE  shared TEMP-TABLE ext-classif-list no-undo
   FIELD db-num as integer
   field Key#One as integer
   field Key#Two as integer
   field CharKey_One as character
index pi IS PRIMARY unique db-num Key#Two Key#One CharKey_One
.
DEFINE  shared TEMP-TABLE c-ext-classif-list no-undo
   FIELD db-num as integer
   field Key#One as integer
   field Key#Two as integer
   field CharKey_One as character
   field chip-num as integer
index pi IS PRIMARY unique db-num Key#Two Key#One CharKey_One chip-num
.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE  shared TEMP-TABLE PromoAction-list no-undo
FIELD ID as int64
FIELD db-num as integer
FIELD del_ as logical
index pi IS PRIMARY unique ID db-num
.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE  shared TEMP-TABLE thbjattr-list no-undo like ub.thbj-attr .
define  shared var sendEMRC   as logical no-undo.
define  shared var settingUpd as logical no-undo.
define  shared var sendMarkType as logical no-undo.
define  shared var sendGisMt as logical no-undo.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE new shared TEMP-TABLE cash-cli no-undo
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
define new shared temp-table cash-cli-attr no-undo
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
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
define stream   IBMStream .
define temp-table temp-cd no-undo like ub.cash-desk .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define buffer buf_clients for ub.clients.
define buffer buf_shop for ub.shop.
define buffer buf_cash-desk for ub.cash-desk.
assign
p-db-num = integer(entry(1, p-parameter, chr(4)))
no-error
.
if error-status:error then return error.
define variable vrec-cur      as character no-undo.
define variable vrec-del      as character no-undo.
for each cash-pay-list no-lock:
   find first cash-pay where cash-pay.cdpay-code eq cash-pay-list.cdpay-code
                         and cash-pay.curr-code  eq cash-pay-list.curr-code
   no-lock no-error.
   if available cash-pay
   then do:
      if      cash-pay.status_ eq 'тек':U
      then
         vrec-cur = vrec-cur + "," + string(recid(cash-pay)).
      else if cash-pay.status_ eq 'удал':U
      then
         vrec-del = vrec-del + "," + string(recid(cash-pay)).
   end.
end.
vrec-cur = trim(vrec-cur,",").
vrec-del = trim(vrec-del,",").
for each buf_clients no-lock
      where buf_clients.obj-type = 'маг':U
        and buf_clients.db-num   = g#db-num,
      first buf_cash-desk no-lock where
           buf_cash-desk.db-num = p-db-num
       AND buf_cash-desk.obj-code = buf_clients.obj-code
       AND buf_cash-desk.cash-on = yes
  on error undo, return error
  :
   if  vrec-cur ne ""
   then
      run str/send-pay.p (
                       input parparentproc
                      ,input p-parent-handle
                      ,input p-log-handle
                      ,input buf_clients.obj-code
                      ,input "U"
                      ,input 1
                     , input vrec-cur
                     , input log-file-name
                     , input-output v-view-log
                     ) no-error .
   if  vrec-del ne ""
   then
      run str/send-pay.p (
                       input parparentproc
                      ,input p-parent-handle
                      ,input p-log-handle
                      ,input buf_clients.obj-code
                      ,input "U"
                      ,input 1
                     , input vrec-del
                     , input log-file-name
                     , input-output v-view-log
                     ) no-error .
end.
define variable v-promo-actions-upd as class ibs.th.ref.promo.promoactionsubs no-undo .
define variable v-promo-actions-del as class ibs.th.ref.promo.promoactionsubs no-undo .
define variable v-promo-stor as class ibs.th.gbl.storage.promoactionstorage no-undo .
v-promo-stor = new ibs.th.gbl.storage.promoactionstorage().
for each PromoAction-list no-lock:
   find first ub.PromoAction where ub.PromoAction.id = PromoAction-list.id
                         and ub.PromoAction.db-num = PromoAction-list.db-num
   no-lock no-error.
   if available ub.PromoAction
   then do:
     if ub.PromoAction.Status_ = 2 or ub.PromoAction.changeDate < today then
      v-promo-stor:getpromoactionsubs(input-output v-promo-actions-del,PromoAction-list.db-num,PromoAction-list.id).
     else  v-promo-stor:getpromoactionsubs(input-output v-promo-actions-upd,PromoAction-list.db-num,PromoAction-list.id).
   end.
end.
delete object v-promo-stor.
if valid-Object(v-promo-actions-upd)
then do:
   for each buf_clients no-lock
         where buf_clients.obj-type = 'маг':U
           and buf_clients.db-num   = g#db-num,
         first buf_cash-desk no-lock where
              buf_cash-desk.db-num = p-db-num
          AND buf_cash-desk.obj-code = buf_clients.obj-code
          AND buf_cash-desk.cash-on = yes
     on error undo, return error
     :
      run str/send-promo.p (
                       input parparentproc
                      ,input p-parent-handle
                      ,input p-log-handle
                      ,input buf_cash-desk.obj-code
                      ,input "U"
                      ,input (if not valid-object (v-promo-actions-upd)
                              then 0
                              else 1)
                     , input v-promo-actions-upd
                     , input log-file-name
                     , input-output v-view-log
                     ) no-error .
   end.
end.
if valid-Object(v-promo-actions-del)
then do:
   for each buf_clients no-lock
         where buf_clients.obj-type = 'маг':U
           and buf_clients.db-num   = g#db-num,
         first buf_cash-desk no-lock where
              buf_cash-desk.db-num = p-db-num
          AND buf_cash-desk.obj-code = buf_clients.obj-code
          AND buf_cash-desk.cash-on = yes
     on error undo, return error
     :
      run str/send-promo.p (
                       input parparentproc
                      ,input p-parent-handle
                      ,input p-log-handle
                      ,input buf_cash-desk.obj-code
                      ,input "D"
                      ,input (if not valid-object (v-promo-actions-del)
                              then 0
                              else 1)
                     , input v-promo-actions-del
                     , input log-file-name
                     , input-output v-view-log
                     ) no-error .
   end.
end.
assign
   vrec-cur = ""
   vrec-del = ""
   .
for each buf_clients no-lock
      where buf_clients.obj-type = 'маг':U
        and buf_clients.db-num   = g#db-num,
      first buf_cash-desk no-lock where
           buf_cash-desk.db-num = p-db-num
       AND buf_cash-desk.obj-code = buf_clients.obj-code
       AND buf_cash-desk.cash-on = yes
  on error undo, return error
  :
for each c-ext-classif-list no-lock:
   find first c-ext-classif where c-ext-classif.db-num = c-ext-classif-list.db-num and
                                c-ext-classif.Key#_One = c-ext-classif-list.Key#One and
                                c-ext-classif.Key#_Two = c-ext-classif-list.Key#Two and
                                c-ext-classif.CharKey_One = c-ext-classif-list.CharKey_One and
                                c-ext-classif.chip-num = c-ext-classif-list.chip-num and
                                c-ext-classif.classif-subject = 'goods':U and
                                c-ext-classif.classif-name = 'exp-esys-gds-code':U
   no-lock no-error.
   if available c-ext-classif
   then do:
      find first ext-classif where ext-classif.db-num = c-ext-classif-list.db-num and
                                ext-classif.Key#_One = c-ext-classif-list.Key#One and
                                ext-classif.Key#_Two = c-ext-classif-list.Key#Two and
                                ext-classif.CharKey_One = c-ext-classif-list.CharKey_One and
                                ext-classif.classif-subject = 'goods':U and
                                ext-classif.classif-name = 'exp-esys-gds-code':U no-error .
                if not available ext-classif then
   vrec-del = vrec-del + "," + string(recid(c-ext-classif)).
   end.
end.
   if  vrec-del ne ""
   then
       run str/send-petrol.p (
                    input parparentproc
                   ,input p-parent-handle
                   ,input p-log-handle
                   ,input buf_clients.obj-code
                   ,input buf_clients.obj-type
                   ,input "D"
                   ,input 0
                  , input vrec-del
                  , input log-file-name
                  , input-output v-view-log
                  ) no-error .
for each ext-classif-list no-lock:
   find first ext-classif where ext-classif.db-num = ext-classif-list.db-num and
                                ext-classif.Key#_One = ext-classif-list.Key#One and
                                ext-classif.Key#_Two = ext-classif-list.Key#Two and
                                ext-classif.CharKey_One = ext-classif-list.CharKey_One and
                                ext-classif.classif-subject = 'goods':U and
                                ext-classif.classif-name = 'exp-esys-gds-code':U
   no-lock no-error.
   if available ext-classif
   then vrec-cur = vrec-cur + "," + string(recid(ext-classif)).
end.
vrec-cur = trim(vrec-cur,",").
   if  vrec-cur ne ""
   then
    run str/send-petrol.p (
                    input parparentproc
                   ,input p-parent-handle
                   ,input p-log-handle
                   ,input buf_clients.obj-code
                   ,input buf_clients.obj-type
                   ,input "U"
                   ,input 0
                  , input vrec-cur
                  , input log-file-name
                  , input-output v-view-log
                  ) no-error .
end.
if can-find(first gds-list no-lock)
or can-find(first gdsolist no-lock) then do:
  for each buf_clients no-lock
      where buf_clients.obj-type = 'маг':U
        and buf_clients.db-num   = p-db-num,
      first buf_cash-desk no-lock where
           buf_cash-desk.db-num = p-db-num
       AND buf_cash-desk.obj-code = buf_clients.obj-code
       AND buf_cash-desk.cash-on = yes
  on error undo, return error
  :
    for each gdsolist no-lock where
            gdsolist.obj-type = buf_clients.obj-type
        and gdsolist.obj-code = buf_clients.obj-code:
        find first gds-list where
                  gds-list.gds-code = gdsolist.gds-code no-error .
        if avail gds-list then NEXT.
        if not avail gds-list then do:
          find first goods no-lock where
                    goods.gds-code = gdsolist.gds-code no-error .
          create gds-list.
          buffer-copy goods to gds-list.
        end.
        if avail gds-list then
        assign
        gds-list.qnty = -1
        .
    END.
    run set-title in p-log-handle (
          input "Отправка товаров на кассу"
                                   ).
     run str/send-gds.p (
        input parparentproc
        ,input p-parent-handle
        ,input p-log-handle
        ,input (string(buf_clients.obj-code) + chr(4) + "no":U)
        ) no-error .
    if error-status:error then
    return error substitute( "ошибка при отправке товаров на кассу по магазину &1&2&3&2&4"
                            , buf_clients.obj-code
                            , chr(10)
                            , error-status:get-message(1)
                            , return-value
                            ).
  end.
end.
if can-find(first bc-list no-lock) then do:
  for each buf_clients no-lock
      where buf_clients.obj-type = 'маг':U
        and buf_clients.db-num   = g#db-num,
      first buf_cash-desk no-lock where
           buf_cash-desk.db-num = p-db-num
       AND buf_cash-desk.obj-code = buf_clients.obj-code
       AND buf_cash-desk.cash-on = yes
  on error undo, return error
  :
    run set-title in p-log-handle (
         input 'Удаление бар-кодов с кассы'
                                   ).
    run str/send-bcn.p (
                    input parparentproc
                   ,input p-parent-handle
                  ,input p-log-handle
                  ,input (string(buf_clients.obj-code) + chr(4) + "D":U)
                    ) no-error .
    if error-status:error then do:
      return error substitute( "ошибка при удалении бар-кодов с кассы магазина &1&2&3&2&4"
                            , buf_clients.obj-code
                            , chr(10)
                            , error-status:get-message(1)
                            , return-value
      ).
    end.
    run set-title in p-log-handle (
         input 'Отправка бар-кодов на кассу'
                                   ).
    run str/send-bcn.p (
                    input parparentproc
                  ,input p-parent-handle
                  ,input p-log-handle
                  ,input (string(buf_clients.obj-code) + chr(4) + "U":U)
                    ) no-error .
    if error-status:error then do:
      return error substitute( "ошибка при отправке бар-кодов на кассы магазина &1&2&3&2&4"
                            , buf_clients.obj-code
                            , chr(10)
                            , error-status:get-message(1)
                            , return-value
        ).
    end.
  end.
end.
if can-find(first pbc-list no-lock) then do:
    for each buf_clients no-lock
      where buf_clients.obj-type = 'маг':U
        and buf_clients.db-num   = p-db-num,
      first buf_cash-desk no-lock where
           buf_cash-desk.db-num = p-db-num
       AND buf_cash-desk.obj-code = buf_clients.obj-code
       AND buf_cash-desk.cash-on = yes
  on error undo, return error
  :
    run set-title in p-log-handle (
          input 'Удаление ДопБК с кассы'
                                    ).
    run str/s-prdbcn.p (
                    input parparentproc
                  ,input p-parent-handle
                  ,input p-log-handle
                  ,input (string(buf_clients.obj-code) + chr(4) + "D":U)
                    ) no-error .
    if error-status:error then do:
      return error substitute( "ошибка при удалении ДопБК с кассы магазина &1&2&3&2&4"
                            , buf_clients.obj-code
                            , chr(10)
                            , error-status:get-message(1)
                            , return-value
         ).
    end.
    run str/s-prdbcn.p (
                    input parparentproc
                  ,input p-parent-handle
                  ,input p-log-handle
                  ,input (string(buf_clients.obj-code) + chr(4) + "U":U)
                    ) no-error .
    if error-status:error then do:
      return error substitute( "ошибка при отправке ДопБК на кассы магазина &1&2&3&2&4"
                            , buf_clients.obj-code
                            , chr(10)
                            , error-status:get-message(1)
                            , return-value
         ).
    end.
  end.
end.
if can-find(first cash-txn no-lock)
  or can-find(first cash-txr no-lock)
then do:
    run set-title in p-log-handle (
          input 'Отправка налогов на кассу'
                                    ).
  for each buf_clients no-lock
      where buf_clients.obj-type = 'маг':U
        and buf_clients.db-num   = p-db-num,
      first buf_cash-desk no-lock where
           buf_cash-desk.db-num = p-db-num
       AND buf_cash-desk.obj-code = buf_clients.obj-code
       AND buf_cash-desk.cash-on = yes
  on error undo, return error
  :
    run str/sendtaxn.p (
                    input parparentproc
                  ,input p-parent-handle
                  ,input p-log-handle
                  ,input (string(buf_clients.obj-code) + chr(4) + "U":U)
                  ) no-error.
    if error-status:error then do:
      return error substitute( "ошибка при отправке налогов на кассы магазина &1&2&3&2&4"
                            , buf_clients.obj-code
                            , chr(10)
                            , error-status:get-message(1)
                            , return-value
         ).
    end.
  end.
end.
if    can-find(first dc-list no-lock)
   or can-find(first dc-dis-card-mask no-lock)
   then do:
    run set-title in p-log-handle (
          input 'Отправка информации по клиентским картам на кассу'
                                    ).
    for each buf_clients no-lock
      where buf_clients.obj-type = 'маг':U
        and buf_clients.db-num = p-db-num
  ,each buf_shop no-lock
      where buf_shop.obj-code = buf_clients.obj-code
    break by buf_shop.host-code
  on error undo, return error
  :
    if first-of(buf_shop.host-code) then do:
      run str/send-cli-news.p (
                    input parparentproc
                   ,input p-parent-handle
                   ,input p-log-handle
                   ,input (string(buf_clients.obj-code) + chr(4) + "U":U +
                           chr(4) + "no":U + chr(4) + "no":U )
                     ) no-error .
      if error-status:error then do:
        return error substitute( "ошибка при отправке информации по клиентским картам на кассы магазина &1&2&3&2&4"
                            , buf_clients.obj-code
                            , chr(10)
                            , error-status:get-message(1)
                            , return-value
           ).
      end.
    end.
  end.
end.
if can-find(first stpl-list no-lock where stpl-list.classif-type = 'dis-card':U) then do:
  for each stpl-list no-lock where
          stpl-list.classif-type = 'dis-card':U:
    run str/snd-stpl.p (
                      input parparentproc
                      ,input p-parent-handle
                      ,input p-log-handle
                      ,input stpl-list.stop-list-code
                      ) no-error .
    if error-status:error then do:
      return error substitute( "ошибка при отправке информации по стоплистам на кассы &1&2&1&3"
                          , chr(10)
                          , error-status:get-message(1)
                          , return-value
          ).
    end.
  end.
end.
if can-find (first  pdf-list ) then do:
  run str/sendpdfr.p (
                       input parparentproc
                      ,input this-procedure:handle
                      ,input p-log-handle
                      ,input "N"
                      ) no-error.
end.
if sendEMRC or sendMarkType or sendGisMt then do:
for each buf_clients no-lock
      where buf_clients.obj-type = 'маг':U
        and buf_clients.db-num   = p-db-num,
      first buf_cash-desk no-lock where
           buf_cash-desk.db-num = p-db-num
       AND buf_cash-desk.obj-code = buf_clients.obj-code
       AND buf_cash-desk.cash-on = yes
  on error undo, return error
  :
   if sendEMRC then
   do:
       run str/send-all.p (
                           input parparentproc
                          ,input this-procedure:handle
                          ,input p-log-handle
                          ,input buf_clients.obj-type + chr(4) + string(buf_clients.obj-code) + chr(4) + 'D':U + chr(4) + 'emrc':U + chr(4) + 'Передача справочника ЕМЦ':U
                          ) no-error.
       run str/send-all.p (
                           input parparentproc
                          ,input this-procedure:handle
                          ,input p-log-handle
                          ,input buf_clients.obj-type + chr(4) + string(buf_clients.obj-code) + chr(4) + 'U':U + chr(4) + 'emrc':U + chr(4) + 'Передача справочника ЕМЦ':U
                          ) no-error.
   end.
   if sendMarkType then
   do:
       run str/send-all.p (
                           input parparentproc
                          ,input this-procedure:handle
                          ,input p-log-handle
                          ,input buf_clients.obj-type + chr(4) + string(buf_clients.obj-code) + chr(4) + 'U':U + chr(4) + 'MarkType':U + chr(4) + 'Передача типов маркировки':U
                          ) no-error.
   end.
   if sendGisMt then
   do:
       run str/send-all.p (
                           input parparentproc
                          ,input this-procedure:handle
                          ,input p-log-handle
                          ,input buf_clients.obj-type + chr(4) + string(buf_clients.obj-code) + chr(4) + 'U':U + chr(4) + 'gismt':U + chr(4) + 'Передача параметров работы с ТСПИоТ':U
                          ) no-error.
   end.
end.
end.
if settingUpd then do:
   find first sys-ctrl exclusive-lock.
   if     available sys-ctrl
   then do:
      sys-ctrl.whole-send-news = sys-ctrl.whole-send-news + 1.
      if sys-ctrl.whole-send-news > 1000
      then
         sys-ctrl.whole-send-news = 1.
   end.
   release sys-ctrl.
end.
procedure sendnall_get-pdf :
define input-output parameter p-ii as integer no-undo .
define output parameter p-plt-id as integer no-undo .
define output parameter p-plt-db-num as integer no-undo .
define output parameter p-pdf-id as integer no-undo .
define output parameter p-pdf-db-num as integer no-undo .
define output parameter p-del as logical no-undo .
find first pdf-list where
          pdf-list.order-num > p-ii no-error.
if available pdf-list then do:
   assign
   p-plt-id = pdf-list.plt-id
   p-plt-db-num = pdf-list.plt-db-num
   p-pdf-id = pdf-list.pdf-id
   p-pdf-db-num = pdf-list.pdf-db
   p-ii = pdf-list.order-num
   p-del = pdf-list.to-del
   .
end.
end procedure.
