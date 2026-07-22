/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Временная таблица, описывающая header для OpenXML

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/15/08
Author: Bakhtadze Natalya
Creation date: 01/15/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if defined(tmpcxmlh_i) = 0 &then

&glob tmpcxmlh_i

&if defined(tmpcxmlh-htable_i) = 0 and "{1}" = "table" &then

&glob tmpcxmlh-htable_i

define temp-table THheader
field THfilename as character
field THfilenumber as integer
field THformat_ as character
field THversion_ as character
field THrevision as character
&if "{2}" <> "file" &then
field THesysname as character
&endif
field THcurrentDbNum as integer
&if "{2}" <> "file" &then
field THpack-num as integer
&endif
field THschema-name as character
&if "{2}" <> "file" &then
field THexport-esys-id as integer
field THimport-esys-id as integer
&endif
field THtotal-recs as integer
&if "{2}" <> "file"  &then
field THprev-crc as character
&endif
index pi is unique primary
THfilename
THfilenumber
.

define temp-table header_
field to_ as character
field from_ as character
field obj-type as character
field obj-code as decimal xml-data-type "positiveInteger"
/*не найдо удивояться!!!!*/
field name as character
/*
field date_from_dt as datetime XML-NODE-TYPE "HIDDEN"
field date_to_dt as datetime XML-NODE-TYPE "HIDDEN"
*/
field xsd as character
field date-from as character
field date-to as character
index pi is unique primary
name
.
&endif

&global-define thpck-sent_esys-pck-sent_fields "~
THfilename,custom-pack-name~
,THcrc-pack,esps-crc-pack~
,THcredate,esps-credate~
,THcrenum,esps-crenum~
,THcretimeint,esps-cretimeint~
,THcretime,esps-cretime~
,THrcvddate,esps-rcvddate~
,THpack-num,esps-pack-num~
,THrcvdtimeint,esps-rcvdtimeint~
,THrcvdtime,esps-rcvdtime~
,THrcvd,esps-rcvd~
,THsendtxtdate,esps-sendtxtdate~
,THsendtxttimeint,esps-sendtxttimeint~
,THsendtxttime,esps-sendtxttime~
,THtotal-recs,esps-total-recs~
,THesys-id,esys-id"



&scoped-define thpck-sent_fields ~
field THfilename as character ~
field THcrc-pack as character ~
field THcredate as date ~
field THcrenum as integer  ~
field THcretimeint as integer ~
field THcretime as character   ~
field THrcvddate  as date ~
field THpack-num  as integer  ~
field THrcvdtimeint as integer ~
field THrcvdtime  as character   ~
field THrcvd  as logical      ~
field THsendtxtdate as date ~
field THsendtxttimeint as integer ~
field THsendtxttime as character  ~
field THtotal-recs  as integer  ~
field THesys-id  as integer     ~
index pi is unique primary ~
THesys-id                  ~
THpack-num                 ~
index ircvd                ~
THesys-id                  ~
THrcvd                     ~


define temp-table THpck-sent no-undo
{&thpck-sent_fields}
.

define temp-table THcurr-pack no-undo
{&thpck-sent_fields}
.

define temp-table THpck-rcvd no-undo
field THfilename as character
field THesys-id  as integer
field THcrc-pack as character
field THpack-num  as integer
field THrcvd-recs  as integer
field THrcvd as logical
field THtotal-recs  as integer
field THrcvddate  as date
field THrcvdtimeint as integer
field THrcvdtime  as character
index pi is unique primary
THesys-id
THpack-num
index rcvd
THesys-id
THrcvd
.

&global-define thpck-rcvd_esys-pck-rcvd_fields "~
THfilename,custom-pack-name~
,THesys-id,esys-id~
,THcrc-pack,espr-crc-pack~
,THpack-num,espr-pack-num~
,THrcvd-recs,espr-rcvd-recs~
,THrcvd,espr-rcvd~
,THtotal-recs,total-recs~
"

procedure get-header-by-rec :
define input  parameter p-gate-rec as character no-undo .
define output parameter p-tth as handle no-undo .

define variable v-ii as integer   no-undo .
define variable glog as logical   no-undo .
define variable v-rowid as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-longchar as longchar no-undo .
define variable v-txmlh as handle no-undo .

define buffer buf_clob-data for ub.clob-data.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info{&vssseq} )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info{&vssseq} )
:


  run gen-row-keyr in  this-procedure  (
                                        input  p-gate-rec
                                        ,input  ?
                                        ,input  "ub"
                                        ,input  ?
                                        ,input  NO-LOCK
                                        ,output v-rowid
                                        ,output v-tbl-name   ) no-error.
    find first buf_clob-data no-lock where
              rowid(buf_clob-data) = v-rowid  no-error.
    if not available buf_clob-data then do:
      undo, return error substitute("Не найден CLOB  &1"
                                      , p-gate-rec
                                      ).

    end.
    assign
    v-longchar = buf_clob-data.cdata
    .
    run fix-schemalocation in this-procedure ( input-output v-longchar) no-error.
    if error-status :error then do:
      undo, return error substitute("Не удалось определить расположение составных частей схемы &1 (&2) из БД&3&4&3&5", p-gate-rec, buf_clob-data.file-name_, {&new-line}, error-status:get-message(1) , return-value ).
    end.
    create temp-table p-tth .
    glog = p-tth:READ-XMLSCHEMA( "LONGCHAR" /*cSourceType*/
                                  , v-longchar
                                  , ? /*lOverrideDefaultMapping*/
                                  , ? /*cFieldTypeMapping*/
                                  , ? /*cVerifySchemaMode*/
                                  ) no-error.
    v-longchar = '':U.
    define variable v-esm as character no-undo .
    v-esm = error-status:get-message(1).
    if error-status :error
    or not glog
    then do:
      delete object p-tth no-error.
      undo, return error substitute("Не удалось прочитать XML-схему &1 (&2) из БД&3&4"
                                 , p-gate-rec
                                 , buf_clob-data.file-name_
                                 , {&new-line}
                                 , v-esm
                                  ).
    end.
end.

end procedure. /* get-header-by-rec */

&endif


/* $Workfile$ e n d */