block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: impegais.p $
$Archive: utl/impegais.p $

Импорт кодов ЕГАИС

Автор: Хныкин Павел Андреевич
Дата создания: 12/13/07
Author: Pavel Khnykin
Creation date: 12/13/07

*/
using Ibs.Th.Gbl.ProgressBar.

define input  parameter parparentproc         as handle    no-undo .
define input  parameter p-alc-codes-filename  as character no-undo .
define input  parameter p-sup-codes-filename  as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: impegais.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/impegais.p $":U .
define variable vss-description as character no-undo init "Импорт кодов ЕГАИС".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/xmlchar.i  }
{ rep/prg-bar.i def }
{ rep/prg-bar.i run }
{ str/xmllib.i   }
{ gbl/waitfram.i }
{ rep/repfrm.i def   }

define variable v-i           as integer   no-undo .
define variable v-is-error    as logical   no-undo .
define variable v-err-count   as integer   no-undo .
define variable v-frame-label as character no-undo .
define variable v-today       as date      no-undo .
define variable v-time        as integer   no-undo .
define variable v-time-start  as integer   no-undo .
define variable v-time-finish as integer   no-undo .

define variable v-alc-count-l as integer format ">>>,>>>,>>>,>>9" no-undo .
define variable v-alc-count-t as integer format ">>>,>>>,>>>,>>9" no-undo .
define variable v-alc-count-b as integer format ">>>,>>>,>>>,>>9" no-undo .
define variable v-sup-count-l as integer format ">>>,>>>,>>>,>>9" no-undo .
define variable v-sup-count-t as integer format ">>>,>>>,>>>,>>9" no-undo .
define variable v-sup-count-b as integer format ">>>,>>>,>>>,>>9" no-undo .


function get-date return date (input p-str as character) forward.


define stream sinp.
define stream serr.

define temp-table tt-alc-container no-undo
 field kcont_id          as decimal
 field kcont_code        as character
 field kcont_name        as character
 field rcont_date_bg_nw  as date
 field rcont_date_end_nw as date
 field rcont_date_nw     as date
 field rcont_aktl        as decimal
index pi is primary unique
  kcont_id
.

define temp-table tt-alc-volume no-undo
  field volf_id         as decimal
  field volf_code       as character
  field volf_volume     as decimal
  field vlf_date_bg_nw  as date
  field vlf_date_end_nw as date
  field vlf_date_nw     as date
  field vlf_aktl        as decimal
index pi is primary unique
  volf_id
.

define temp-table tt-territory no-undo
  field terr_id           as decimal
  field terr_code         as character
  field terr_name         as character
  field terr_date_bg_nw   as date
  field terr_date_end_nw  as date
  field terr_date_nw      as date
  field terr_countr       as decimal
index pi is primary unique
  terr_id
.

define temp-table tt-alc-manufacturer no-undo
  field manf_id          as decimal
  field manf_name        as character
  field manf_address     as character
  field manf_egais       as character
  field manf_inn         as character
  field manf_date_bg_nw  as date
  field manf_date_end_nw as date
  field manf_aktl        as decimal
  field manf_date_nw     as date
index pi is primary unique
  manf_id
.

define temp-table tt-alc-products no-undo
  field alpr_id        as decimal
  field kalpr_id       as decimal
  field kcont_id       as decimal
  field volf_id        as decimal
  field manf_id        as decimal
  field alpr_egais     as character
  field alpr_code      as character
  field alpr_name      as character
  field alpr_scan_code as character
  field alpr_frtr      as decimal
  field alpr_status    as character
index pi is primary unique
  alpr_id
.

define temp-table tt-alc-supplier no-undo
  field supp_id               as decimal
  field supp_name             as character
  field supp_adr_ur           as character
  field supp_head_fio         as character
  field supp_inn              as character
  field supp_code_reas_state  as character
  field supp_code_egais       as character
  field supp_date_bg_nw       as date
  field supp_date_end_nw      as date
  field supp_date_nw          as date
  field supp_prz_aktl         as decimal
index pi is primary unique
  supp_id
.

define temp-table tt-countries no-undo
  field country-code as character
  field short-name   as character
  field full-name    as character
index pi is primary unique
  country-code
.

do on error undo, return error return-value
:
  { gbl/getcntxt.i get }
  run clear-tt in this-procedure .

  assign
    v-time-start = time
  .
  run xmllib-set-prg-bar-handle in this-procedure ( input this-procedure ) .
  run load-xml-alcohol in this-procedure .
  run proc-xml-alcohol in this-procedure .
  run load-xml-supplier in this-procedure .
  run proc-xml-supplier in this-procedure .
  run fill-alcohol in this-procedure .
  run fill-suppliers in this-procedure .
  run clear-tt in this-procedure .
  run xmllib-clear-parse-data in this-procedure.

  assign
    v-time-finish = time - v-time-start
  .
  run calc-egais-gds in this-procedure ( output v-alc-count-b ) .
  run calc-egais-clients in this-procedure ( output v-sup-count-b ) .


  message
    "Импорт завершен!":U skip
    "Время импорта: ":U string( v-time-finish , "HH:MM:SS" ) skip(2)
    "Разобрано записей алкогольной продукции: ":U  v-alc-count-t skip
    "Загружено новых записей: ":U v-alc-count-l skip
    "Записей в БД: ":U v-alc-count-b skip(1)
    "Разобрано записей поставщиков: ":U  v-sup-count-t skip
    "Загружено новых записей: ":U v-sup-count-l skip
    "Записей в БД: ":U v-sup-count-b
  view-as alert-box information.


  if v-is-error = yes then do:
    message
      "Во время импорта были обнаружены ошибки." skip
      "Количество ошибок: " v-err-count skip
      "Отчет выведен в файл impegais.err"
    view-as alert-box warning.
  end.

end.


/* ============================================================= */
procedure put-error :

define input  parameter p-message as character no-undo .
do
on error undo, return error return-value
:
  assign
    v-is-error  = yes
    v-err-count = v-err-count + 1
  .

  output stream serr to "impegais.err" append.
  put stream serr unformatted string( today , "99/99/99") + " " + string( time , "hh:mm:ss") + " " + p-message + {&new-line} .
  output stream serr close.

end.

end procedure. /* put-error */

/* ============================================================= */
procedure clear-tt :

do
on error undo, return error return-value
:
  empty temp-table tt-alc-container .
  empty temp-table tt-alc-volume .
  empty temp-table tt-territory .
  empty temp-table tt-alc-manufacturer .
  empty temp-table tt-alc-products .
  empty temp-table tt-alc-supplier .

end.

end procedure. /* clear-tt */

/* ============================================================= */
procedure find-client :
define input  parameter p-inn as character no-undo .
define output parameter p-obj-type  like ub.clients.obj-type no-undo .
define output parameter p-obj-code  like ub.clients.obj-code no-undo .

do
on error undo, return error return-value
:
  define buffer buf_firm    for ub.firm.
  define buffer buf_person  for ub.person.

  find first buf_firm no-lock
    where buf_firm.inn = p-inn
  no-error .
  if available buf_firm then do:
    assign
      p-obj-type = {&cmp}
      p-obj-code = buf_firm.firm-code
    .
    return.
  end.

  find first buf_person no-lock
    where buf_person.inn = p-inn
  no-error .
  if available buf_person then do:
    assign
      p-obj-type = {&prs}
      p-obj-code = buf_person.psn-code
    .
    return.
  end.


end.

end procedure. /* find-client */

/* ============================================================= */
procedure load-xml-alcohol :

do
on error undo, return error return-value
:
  define variable v-full-filename as character  no-undo.

  define buffer buf_rec-fld      for temp_xmllib_rec-fld.
  define buffer buf_rec          for temp_xmllib_rec.

do
for buf_rec-fld
  , buf_rec
on error undo, return error
:
    assign
        v-full-filename   = search( p-alc-codes-filename )
    .
    if v-full-filename <> ?
    then do:
        run xmllib-clear-parse-data in this-procedure.

        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_MANUFACTURER":U, input "MANF_ID":U           ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_MANUFACTURER":U, input "MANF_NAME":U         ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_MANUFACTURER":U, input "MANF_ADDRESS":U      ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_MANUFACTURER":U, input "MANF_EGAIS":U        ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_MANUFACTURER":U, input "MANF_INN":U          ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_MANUFACTURER":U, input "MANF_DATE_BG_NW":U   ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_MANUFACTURER":U, input "MANF_DATE_END_NW":U  ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_MANUFACTURER":U, input "MANF_AKTL":U         ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_MANUFACTURER":U, input "MANF_DATE_NW":U      ) .


        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_PRODUCT":U, input "ALPR_ID":U        ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_PRODUCT":U, input "KALPR_ID":U       ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_PRODUCT":U, input "KCONT_ID":U       ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_PRODUCT":U, input "VOLF_ID":U        ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_PRODUCT":U, input "MANF_ID":U        ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_PRODUCT":U, input "ALPR_EGAIS":U     ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_PRODUCT":U, input "ALPR_CODE":U      ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_PRODUCT":U, input "ALPR_NAME":U      ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_PRODUCT":U, input "ALPR_SCAN_CODE":U ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_PRODUCT":U, input "ALPR_FRTR":U      ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_PRODUCT":U, input "ALPR_STATUS":U    ) .


        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_CONTAINER":U, input "KCONT_ID":U           ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_CONTAINER":U, input "KCONT_CODE":U         ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_CONTAINER":U, input "KCONT_NAME":U         ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_CONTAINER":U, input "RCONT_DATE_BG_NW":U   ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_CONTAINER":U, input "RCONT_DATE_END_NW":U  ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_CONTAINER":U, input "RCONT_DATE_NW":U      ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_CONTAINER":U, input "RCONT_AKTL":U         ) .


        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_VOLUME":U, input "VOLF_ID":U         ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_VOLUME":U, input "VOLF_CODE":U       ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_VOLUME":U, input "VOLF_VOLUME":U     ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_VOLUME":U, input "VLF_DATE_BG_NW":U  ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_VOLUME":U, input "VLF_DATE_END_NW":U ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_VOLUME":U, input "VLF_DATE_NW":U     ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_VOLUME":U, input "VLF_AKTL":U        ) .

        run xmllib-add-rec-fld in this-procedure ( input "MD_TERRITORY":U, input "TERR_ID":U          ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_TERRITORY":U, input "TERR_CODE":U        ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_TERRITORY":U, input "TERR_NAME":U        ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_TERRITORY":U, input "TERR_DATE_BG_NW":U  ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_TERRITORY":U, input "TERR_DATE_END_NW":U ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_TERRITORY":U, input "TERR_DATE_NW":U     ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_TERRITORY":U, input "TERR_COUNTR":U      ) .

        run xmllib-parse-file in this-procedure (
            input v-full-filename
        ) no-error.
        if error-status :error
        then do:
            message
                     vss-workfile vss-revision vss-description
                skip(1)
                skip substitute( "Ошибка разбора файла &1", v-full-filename )
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.
    end.
end.
run waitfram-hide in this-procedure .
end.

end procedure. /* load-xml-alcohol */

/* ============================================================= */
procedure load-xml-supplier :

do
on error undo, return error return-value
:
  define variable v-full-filename as character  no-undo.

  define buffer buf_rec-fld      for temp_xmllib_rec-fld.
  define buffer buf_rec          for temp_xmllib_rec.

do
for buf_rec-fld
  , buf_rec
on error undo, return error
:
    assign
        v-full-filename   = search( p-sup-codes-filename )
    .
    if v-full-filename <> ?
    then do:
        run xmllib-clear-parse-data in this-procedure.

        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_SUPPLIER":U, input "SUPP_ID":U               ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_SUPPLIER":U, input "SUPP_NAME":U             ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_SUPPLIER":U, input "SUPP_ADR_UR":U           ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_SUPPLIER":U, input "SUPP_HEAD_FIO":U         ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_SUPPLIER":U, input "SUPP_INN":U              ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_SUPPLIER":U, input "SUPP_CODE_REAS_STATE":U  ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_SUPPLIER":U, input "SUPP_CODE_EGAIS":U       ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_SUPPLIER":U, input "SUPP_DATE_BG_NW":U       ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_SUPPLIER":U, input "SUPP_DATE_END_NW":U      ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_SUPPLIER":U, input "SUPP_DATE_NW":U          ) .
        run xmllib-add-rec-fld in this-procedure ( input "MD_ALC_SUPPLIER":U, input "SUPP_PRZ_AKTL":U         ) .

        run xmllib-parse-file in this-procedure (
            input v-full-filename
        ) no-error.
        if error-status :error
        then do:
            message
                     vss-workfile vss-revision vss-description
                skip(1)
                skip substitute( "Ошибка разбора файла &1", v-full-filename )
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.
    end.
end.
run waitfram-hide in this-procedure .

end.

end procedure. /* load-xml-supplier */

/* ============================================================= */
procedure proc-xml-alcohol :

    define buffer buf_rec          for temp_xmllib_rec.
    define buffer buf_rec-fld      for temp_xmllib_rec-fld.
do
on error undo, return error return-value
:

  run waitfram-show in this-procedure ( "Разбор товаров...":U ) .

  for each buf_rec
  on error undo, return error
  :

    case buf_rec.recName :
      when "MD_ALC_CONTAINER":U then do:
        run parse-alc-containers in this-procedure ( input buf_rec.rec-key ) .
      end. /* when "MD_ALC_CONTAINER":U then do: */
      when "MD_ALC_VOLUME":U then do:
        run parse-alc-volumes in this-procedure ( input buf_rec.rec-key ) .
      end. /* when "MD_ALC_VOLUME":U then do: */
      when "MD_TERRITORY":U then do:
        run parse-territorys in this-procedure ( input buf_rec.rec-key ) .
      end. /* when "MD_TERRITORY":U then do: */
      when "MD_ALC_MANUFACTURER":U then do:
        run parse-alc-manufacturers in this-procedure ( input buf_rec.rec-key ) .
      end. /* when "MD_ALC_MANUFACTURER":U then do: */
      when "MD_ALC_PRODUCT":U then do:
        run parse-alc-products in this-procedure ( input buf_rec.rec-key) .
      end. /* when "MD_ALC_PRODUCT":U then do: */
    end case.

  end.

  run waitfram-hide in this-procedure .
end.

end procedure. /* proc-xml-alcohol */


/* ============================================================= */
procedure proc-xml-supplier :

    define buffer buf_rec          for temp_xmllib_rec.
    define buffer buf_rec-fld      for temp_xmllib_rec-fld.

do
on error undo, return error return-value
:

  run waitfram-show in this-procedure ( "Разбор поставщиков...":U ) .

  for each buf_rec
  on error undo, return error
  :

    case buf_rec.recName :
      when "MD_ALC_SUPPLIER":U then do:
        run parse-alc-suppliers in this-procedure ( input buf_rec.rec-key ) .
      end.
    end case.
  end.
  run waitfram-hide in this-procedure .
end.
end procedure. /* proc-xml-supplier */



/* ============================================================= */
procedure parse-alc-containers :
  define input  parameter p-rec-key as integer   no-undo .

  define buffer buf_rec-fld      for temp_xmllib_rec-fld.

  define variable v-kcont_id          as decimal   no-undo .
  define variable v-kcont_code        as character no-undo .
  define variable v-kcont_name        as character no-undo .
  define variable v-rcont_date_bg_nw  as date      no-undo .
  define variable v-rcont_date_end_nw as date      no-undo .
  define variable v-rcont_date_nw     as date      no-undo .
  define variable v-rcont_aktl        as decimal   no-undo .

do
on error undo, return error return-value
:
  for each buf_rec-fld
      where buf_rec-fld.rec-key = p-rec-key
  on error undo, return error
  :
    case buf_rec-fld.fldName :
      when "KCONT_ID":U then do:
        assign
          v-kcont_id = decimal(buf_rec-fld.fldValue)
        no-error .
      end.
      when "KCONT_CODE":U then do:
        assign
          v-kcont_code = buf_rec-fld.fldValue
        .
      end.
      when "KCONT_NAME":U then do:
        assign
          v-kcont_name = buf_rec-fld.fldValue
        .
      end.
      when "RCONT_DATE_BG_NW":U then do:
        assign
          v-rcont_date_bg_nw = get-date( buf_rec-fld.fldValue )
        no-error .
      end.
      when "RCONT_DATE_END_NW":U then do:
        assign
          v-rcont_date_end_nw = get-date( buf_rec-fld.fldValue )
        no-error .
      end.
      when "RCONT_DATE_NW":U then do:
        assign
          v-rcont_date_nw = get-date( buf_rec-fld.fldValue )
        no-error .
      end.
      when "RCONT_AKTL":U then do:
        assign
          v-rcont_aktl = decimal( buf_rec-fld.fldValue )
        no-error .
      end.
    end case.
  end.

  if v-kcont_id = ? then return.

  find first tt-alc-container
    where tt-alc-container.kcont_id = v-kcont_id
  no-error .
  if not available tt-alc-container then do:
    create tt-alc-container.
    assign
      tt-alc-container.kcont_id           = v-kcont_id
      tt-alc-container.kcont_code         = v-kcont_code
      tt-alc-container.kcont_name         = v-kcont_name
      tt-alc-container.rcont_date_bg_nw   = v-rcont_date_bg_nw
      tt-alc-container.rcont_date_end_nw  = v-rcont_date_end_nw
      tt-alc-container.rcont_date_nw      = v-rcont_date_nw
      tt-alc-container.rcont_aktl         = v-rcont_aktl
    .
  end.

end.

end procedure. /* parse-alc-containers */


/* ============================================================= */
procedure parse-alc-volumes :
  define input  parameter p-rec-key as integer   no-undo .

  define buffer buf_rec-fld      for temp_xmllib_rec-fld.

  define variable v-volf_id         as decimal    no-undo .
  define variable v-volf_code       as character  no-undo .
  define variable v-volf_volume     as decimal    no-undo .
  define variable v-vlf_date_bg_nw  as date       no-undo .
  define variable v-vlf_date_end_nw as date       no-undo .
  define variable v-vlf_date_nw     as date       no-undo .
  define variable v-vlf_aktl        as decimal    no-undo .

do
on error undo, return error return-value
:
  for each buf_rec-fld
      where buf_rec-fld.rec-key = p-rec-key
  on error undo, return error
  :
    case buf_rec-fld.fldName :
      when "VOLF_ID":U        then do:
        assign
          v-volf_id = decimal( buf_rec-fld.fldValue )
        no-error .
      end.
      when "VOLF_CODE":U      then do:
        assign
          v-volf_code = buf_rec-fld.fldValue
        .
      end.
      when "VOLF_VOLUME":U    then do:
        assign
          v-volf_volume = decimal( buf_rec-fld.fldValue )
        no-error .
      end.
      when "VLF_DATE_BG_NW":U then do:
        assign
          v-vlf_date_bg_nw = get-date( buf_rec-fld.fldValue )
        no-error .
      end.
      when "VLF_DATE_END_NW":U then do:
        assign
          v-vlf_date_end_nw = get-date( buf_rec-fld.fldValue )
        no-error .
      end.
      when "VLF_DATE_NW":U    then do:
        assign
          v-vlf_date_nw = get-date( buf_rec-fld.fldValue )
        no-error .
      end.
      when "VLF_AKTL":U       then do:
        assign
          v-vlf_aktl = decimal( buf_rec-fld.fldValue )
        no-error .
      end.

    end case.
  end.

  if v-volf_id = ? then return.

  find first tt-alc-volume
    where tt-alc-volume.volf_id = v-volf_id
  no-error .
  if not available tt-alc-volume then do:
    create tt-alc-volume.
    assign
      tt-alc-volume.volf_id         = v-volf_id
      tt-alc-volume.volf_code       = v-volf_code
      tt-alc-volume.volf_volume     = v-volf_volume
      tt-alc-volume.vlf_date_bg_nw  = v-vlf_date_bg_nw
      tt-alc-volume.vlf_date_end_nw = v-vlf_date_end_nw
      tt-alc-volume.vlf_date_nw     = v-vlf_date_nw
      tt-alc-volume.vlf_aktl        = v-vlf_aktl
    .
  end.

end.

end procedure. /* parse-alc-volumes */

/* ============================================================= */
procedure parse-territorys :
  define input  parameter p-rec-key as integer   no-undo .

  define buffer buf_rec-fld      for temp_xmllib_rec-fld.

  define variable v-terr_id           as decimal    no-undo .
  define variable v-terr_code         as character  no-undo .
  define variable v-terr_name         as character  no-undo .
  define variable v-terr_date_bg_nw   as date       no-undo .
  define variable v-terr_date_end_nw  as date       no-undo .
  define variable v-terr_date_nw      as date       no-undo .
  define variable v-terr_countr       as decimal    no-undo .

do
on error undo, return error return-value
:

  for each buf_rec-fld
      where buf_rec-fld.rec-key = p-rec-key
  on error undo, return error
  :
    case buf_rec-fld.fldName :
      when "TERR_ID":U         then do:
        assign
          v-terr_id = decimal( buf_rec-fld.fldValue )
        no-error .
      end.
      when "TERR_CODE":U       then do:
        assign
          v-terr_code = buf_rec-fld.fldValue
        .
      end.
      when "TERR_NAME":U       then do:
        assign
          v-terr_name = buf_rec-fld.fldValue
        .
      end.
      when "TERR_DATE_BG_NW":U then do:
        assign
          v-terr_date_bg_nw = get-date( buf_rec-fld.fldValue )
        no-error .
      end.
      when "TERR_DATE_END_NW":U then do:
        assign
          v-terr_date_end_nw = get-date( buf_rec-fld.fldValue )
        no-error .
      end.
      when "TERR_DATE_NW":U    then do:
        assign
          v-terr_date_nw = get-date( buf_rec-fld.fldValue )
        no-error .
      end.
      when "TERR_COUNTR":U     then do:
        assign
          v-terr_countr = decimal( buf_rec-fld.fldValue )
        no-error .
      end.
    end case.
  end.

  if v-terr_id = ? then return .

  find first tt-territory
    where tt-territory.terr_id = v-terr_id
  no-error .
  if not available tt-territory then do:
    create tt-territory.
    assign
      tt-territory.terr_id          = v-terr_id
      tt-territory.terr_code        = v-terr_code
      tt-territory.terr_name        = v-terr_name
      tt-territory.terr_date_bg_nw  = v-terr_date_bg_nw
      tt-territory.terr_date_end_nw = v-terr_date_end_nw
      tt-territory.terr_date_nw     = v-terr_date_nw
      tt-territory.terr_countr      = v-terr_countr
    .
  end.

end.

end procedure. /* parse-territorys */

/* ============================================================= */
procedure parse-alc-manufacturers :
  define input  parameter p-rec-key as integer   no-undo .

  define buffer buf_rec-fld      for temp_xmllib_rec-fld.

  define variable v-manf_id          as decimal    no-undo .
  define variable v-manf_name        as character  no-undo .
  define variable v-manf_address     as character  no-undo .
  define variable v-manf_egais       as character  no-undo .
  define variable v-manf_inn         as character  no-undo .
  define variable v-manf_date_bg_nw  as date       no-undo .
  define variable v-manf_date_end_nw as date       no-undo .
  define variable v-manf_aktl        as decimal    no-undo .
  define variable v-manf_date_nw     as date       no-undo .

do
on error undo, return error return-value
:
  for each buf_rec-fld
      where buf_rec-fld.rec-key = p-rec-key
  on error undo, return error
  :
    case buf_rec-fld.fldName :
      when "MANF_ID":U         then do:
        assign
          v-manf_id = decimal(buf_rec-fld.fldValue)
        no-error .
      end. /*"MANF_ID":U           */
      when "MANF_NAME":U       then do:
        assign
          v-manf_name = buf_rec-fld.fldValue
        .
      end. /*"MANF_NAME":U         */
      when "MANF_ADDRESS":U    then do:
        assign
          v-manf_address = buf_rec-fld.fldValue
        .

      end. /*"MANF_ADDRESS":U      */
      when "MANF_EGAIS":U      then do:
        assign
          v-manf_egais = buf_rec-fld.fldValue
        .

      end. /*"MANF_EGAIS":U        */
      when "MANF_INN":U        then do:
        assign
          v-manf_inn =  buf_rec-fld.fldValue
        no-error .

      end. /*"MANF_INN":U          */
      when "MANF_DATE_BG_NW":U then do:
        assign
          v-manf_date_bg_nw = get-date( buf_rec-fld.fldValue )
        no-error .

      end. /*"MANF_DATE_BG_NW":U   */
      when "MANF_DATE_END_NW":U then do:
        assign
          v-manf_date_end_nw = get-date( buf_rec-fld.fldValue )
        no-error .

      end. /*"MANF_DATE_END_NW":U  */
      when "MANF_AKTL":U       then do:
        assign
          v-manf_aktl = decimal(buf_rec-fld.fldValue)
        no-error .

      end. /*"MANF_AKTL":U         */
      when "MANF_DATE_NW":U    then do:
        assign
          v-manf_date_nw = get-date( buf_rec-fld.fldValue )
        no-error .
      end. /*"MANF_DATE_NW":U      */
    end case.
  end.
  if v-manf_id = ? then return .
  find first tt-alc-manufacturer
    where tt-alc-manufacturer.manf_id = v-manf_id
  no-error .
  if not available tt-alc-manufacturer then do:
    create tt-alc-manufacturer.
    assign
      tt-alc-manufacturer.manf_id          = v-manf_id
      tt-alc-manufacturer.manf_name        = v-manf_name
      tt-alc-manufacturer.manf_address     = v-manf_address
      tt-alc-manufacturer.manf_egais       = v-manf_egais
      tt-alc-manufacturer.manf_inn         = v-manf_inn
      tt-alc-manufacturer.manf_date_bg_nw  = v-manf_date_bg_nw
      tt-alc-manufacturer.manf_date_end_nw = v-manf_date_end_nw
      tt-alc-manufacturer.manf_aktl        = v-manf_aktl
      tt-alc-manufacturer.manf_date_nw     = v-manf_date_nw
    .
  end.

end.

end procedure. /* parse-alc-manufacturers */

/* ============================================================= */
procedure parse-alc-products :
  define input  parameter p-rec-key as integer   no-undo .

  define buffer buf_rec-fld      for temp_xmllib_rec-fld.

  define variable v-alpr_id        as decimal   no-undo .
  define variable v-kalpr_id       as decimal   no-undo .
  define variable v-kcont_id       as decimal   no-undo .
  define variable v-volf_id        as decimal   no-undo .
  define variable v-manf_id        as decimal   no-undo .
  define variable v-alpr_egais     as character no-undo .
  define variable v-alpr_code      as character no-undo .
  define variable v-alpr_name      as character no-undo .
  define variable v-alpr_scan_code as character no-undo .
  define variable v-alpr_frtr      as decimal   no-undo .
  define variable v-alpr_status    as character no-undo .

do
on error undo, return error return-value
:
  for each buf_rec-fld
      where buf_rec-fld.rec-key = p-rec-key
  on error undo, return error
  :
    case buf_rec-fld.fldName :
      when "ALPR_ID":U       then do:
        assign
          v-alpr_id =  decimal( buf_rec-fld.fldValue )
        no-error .
      end.
      when "KALPR_ID":U      then do:
        assign
          v-kalpr_id = decimal( buf_rec-fld.fldValue )
        no-error .
      end.
      when "KCONT_ID":U      then do:
        assign
          v-kcont_id = decimal( buf_rec-fld.fldValue )
        no-error .
      end.
      when "VOLF_ID":U       then do:
        assign
          v-volf_id =  decimal( buf_rec-fld.fldValue )
        no-error .
      end.
      when "MANF_ID":U       then do:
        assign
          v-manf_id = decimal( buf_rec-fld.fldValue )
        no-error .
      end.
      when "ALPR_EGAIS":U    then do:
        assign
          v-alpr_egais =  buf_rec-fld.fldValue
        .
      end.
      when "ALPR_CODE":U     then do:
        assign
          v-alpr_code =  buf_rec-fld.fldValue
        .
      end.
      when "ALPR_NAME":U     then do:
        assign
          v-alpr_name =  buf_rec-fld.fldValue
        .
      end.
      when "ALPR_SCAN_CODE":U then do:
        assign
          v-alpr_scan_code =  buf_rec-fld.fldValue
        .
      end.
      when "ALPR_FRTR":U     then do:
        assign
          v-alpr_frtr = decimal( buf_rec-fld.fldValue )
        no-error .
      end.
      when "ALPR_STATUS":U   then do:
        assign
          v-alpr_status = buf_rec-fld.fldValue
        no-error .
      end.
    end case.
  end.

  if v-alpr_id = ? then return .

  find first tt-alc-products
    where tt-alc-products.alpr_id = v-alpr_id
  no-error .
  if not available tt-alc-products then do:
    create tt-alc-products .
    assign
      tt-alc-products.alpr_id         = v-alpr_id
      tt-alc-products.kalpr_id        = v-kalpr_id
      tt-alc-products.kcont_id        = v-kcont_id
      tt-alc-products.volf_id         = v-volf_id
      tt-alc-products.manf_id         = v-manf_id
      tt-alc-products.alpr_egais      = v-alpr_egais
      tt-alc-products.alpr_code       = v-alpr_code
      tt-alc-products.alpr_name       = v-alpr_name
      tt-alc-products.alpr_scan_code  = v-alpr_scan_code
      tt-alc-products.alpr_frtr       = v-alpr_frtr
      tt-alc-products.alpr_status     = v-alpr_status
    .
  end.

end.

end procedure. /* parse-alc-products */

/* ============================================================= */
procedure parse-alc-suppliers :
  define input  parameter p-rec-key as integer   no-undo .

  define buffer buf_rec-fld      for temp_xmllib_rec-fld.

  define variable v-supp_id               as decimal    no-undo .
  define variable v-supp_name             as character  no-undo .
  define variable v-supp_adr_ur           as character  no-undo .
  define variable v-supp_head_fio         as character  no-undo .
  define variable v-supp_inn              as character  no-undo .
  define variable v-supp_code_reas_state  as character  no-undo .
  define variable v-supp_code_egais       as character  no-undo .
  define variable v-supp_date_bg_nw       as date       no-undo .
  define variable v-supp_date_end_nw      as date       no-undo .
  define variable v-supp_date_nw          as date       no-undo .
  define variable v-supp_prz_aktl         as decimal    no-undo .

do
on error undo, return error return-value
:
  for each buf_rec-fld
      where buf_rec-fld.rec-key = p-rec-key
  on error undo, return error
  :
    case buf_rec-fld.fldName :
      when "SUPP_ID":U              then do:
        assign
          v-supp_id = decimal( buf_rec-fld.fldValue )
        no-error .
      end.
      when "SUPP_NAME":U            then do:
        assign
          v-supp_name = buf_rec-fld.fldValue
        .
      end.
      when "SUPP_ADR_UR":U          then do:
        assign
          v-supp_adr_ur = buf_rec-fld.fldValue
        .
      end.
      when "SUPP_HEAD_FIO":U        then do:
        assign
          v-supp_head_fio = buf_rec-fld.fldValue
        .
      end.
      when "SUPP_INN":U             then do:
        assign
          v-supp_inn = buf_rec-fld.fldValue
        .
      end.
      when "SUPP_CODE_REAS_STATE":U then do:
        assign
          v-supp_code_reas_state = buf_rec-fld.fldValue
        .
      end.
      when "SUPP_CODE_EGAIS":U      then do:
        assign
          v-supp_code_egais = buf_rec-fld.fldValue
        .
      end.
      when "SUPP_DATE_BG_NW":U      then do:
        assign
          v-supp_date_bg_nw = get-date( buf_rec-fld.fldValue )
        no-error .
      end.
      when "SUPP_DATE_END_NW":U     then do:
        assign
          v-supp_date_end_nw = get-date( buf_rec-fld.fldValue )
        no-error .
      end.
      when "SUPP_DATE_NW":U         then do:
        assign
          v-supp_date_nw = get-date( buf_rec-fld.fldValue )
        no-error .
      end.
      when "SUPP_PRZ_AKTL":U        then do:
        assign
          v-supp_prz_aktl = decimal( buf_rec-fld.fldValue )
        no-error .
      end.
    end case.
  end.

  if v-supp_id = ? then return .

  find first tt-alc-supplier
    where tt-alc-supplier.supp_id = v-supp_id
  no-error .
  if not available tt-alc-supplier then do:
    create tt-alc-supplier.
    assign
      tt-alc-supplier.supp_id               = v-supp_id
      tt-alc-supplier.supp_name             = v-supp_name
      tt-alc-supplier.supp_adr_ur           = v-supp_adr_ur
      tt-alc-supplier.supp_head_fio         = v-supp_head_fio
      tt-alc-supplier.supp_inn              = v-supp_inn
      tt-alc-supplier.supp_code_reas_state  = v-supp_code_reas_state
      tt-alc-supplier.supp_code_egais       = v-supp_code_egais
      tt-alc-supplier.supp_date_bg_nw       = v-supp_date_bg_nw
      tt-alc-supplier.supp_date_end_nw      = v-supp_date_end_nw
      tt-alc-supplier.supp_date_nw          = v-supp_date_nw
      tt-alc-supplier.supp_prz_aktl         = v-supp_prz_aktl
    .
  end.

end.

end procedure. /* parse-alc-suppliers */

/* ============================================================= */
procedure fill-alcohol :

  define buffer buf_egais-gds for ub.egais-gds.

do
on error undo, return error return-value
:
  { rep/repfrm.i on 100 }
  assign
    v-i = 0
  .
  _alc-product:
  for each tt-alc-products :
    assign
      v-i = v-i + 1
      v-alc-count-t = v-alc-count-t + 1
    .

    { rep/repfrm.i disp v-i "'Запись в БД алкогольных товаров...'" }

    find first tt-alc-container
      where tt-alc-container.kcont_id = tt-alc-products.kcont_id
    no-error .

    if not available tt-alc-container then do:
      run put-error in this-procedure ( substitute( "В записи товара &1 неизвестный код тары &2 . Товар не импортирован."
                                                  , tt-alc-products.alpr_id
                                                  , tt-alc-products.kcont_id
                                                  )
                                      ) .
      next _alc-product.
    end.
    find first tt-alc-volume
      where tt-alc-volume.volf_id = tt-alc-products.volf_id
    no-error .
    if not available tt-alc-volume then do :
      run put-error in this-procedure ( substitute( "В записи товара &1 неизвестный код объема &2 . Товар не импортирован."
                                                  , tt-alc-products.alpr_id
                                                  , tt-alc-products.volf_id
                                                  )
                                      ) .
      next _alc-product.
    end.

    find first tt-alc-manufacturer
      where tt-alc-manufacturer.manf_id = tt-alc-products.manf_id
    no-error .
    if not available tt-alc-manufacturer then do:
      run put-error in this-procedure ( substitute( "В записи товара &1 неизвестный код производителя &2 . Товар не импортирован."
                                                  , tt-alc-products.alpr_id
                                                  , tt-alc-products.manf_id
                                                  )
                                      ) .
      next _alc-product.
    end.

    find first buf_egais-gds no-lock
      where buf_egais-gds.alpr-id = tt-alc-products.alpr_id
    no-error .
    if not available buf_egais-gds
    then do:
      run cur-time in this-procedure ( output v-today
                                     , output v-time
                                     ).
      create buf_egais-gds.
      assign
        buf_egais-gds.alpr-id         = tt-alc-products.alpr_id
        buf_egais-gds.alpr-code-egais = tt-alc-products.alpr_egais
        buf_egais-gds.alpr-code       = tt-alc-products.alpr_code
        buf_egais-gds.alpr-frtr       = tt-alc-products.alpr_frtr
        buf_egais-gds.alpr-name       = tt-alc-products.alpr_name
        buf_egais-gds.alpr-scan-code  = tt-alc-products.alpr_scan_code
        buf_egais-gds.alpr-status     = tt-alc-products.alpr_status
        buf_egais-gds.kalpr-id        = tt-alc-products.kalpr_id
        buf_egais-gds.kcont-id        = tt-alc-products.kcont_id
        buf_egais-gds.manf-id         = tt-alc-products.manf_id
        buf_egais-gds.producer-name   = tt-alc-manufacturer.manf_name
        buf_egais-gds.tare            = tt-alc-container.kcont_name
        buf_egais-gds.volf-id         = tt-alc-products.volf_id
        buf_egais-gds.volume          = tt-alc-volume.volf_volume
        buf_egais-gds.imp-date        = v-today
        buf_egais-gds.imp-time        = v-time
        buf_egais-gds.imp-user-id     = v-cntxt-userid
      .
      release buf_egais-gds no-error .
      if error-status :error
      then do:
        run put-error in this-procedure ( substitute( "Ошибка записи в БД товара с кодом : &1 - &2. Товар не импортирован. &3&4&3&5&3&6"
                                                    , tt-alc-products.alpr_id
                                                    , tt-alc-products.alpr_name
                                                    , {&new-line}
                                                    , error-status :get-message(1)
                                                    , error-status :get-message(2)
                                                    , error-status :get-message(3)
                                                    )
                                        ) .
        next _alc-product.
      end.
      else do:
         assign
           v-alc-count-l = v-alc-count-l + 1
         .
      end.
    end.
    else do:
      run put-error in this-procedure ( substitute( "Уже есть запись товара с кодом : &1 - &2. Товар не импортирован. "
                                                  , tt-alc-products.alpr_id
                                                  , tt-alc-products.alpr_name
                                                  )
                                      ) .
    end.
  end.

  { rep/repfrm.i off}
end.

end procedure. /* fill-alcohol */

/* ============================================================= */
procedure fill-suppliers :

  define buffer buf_egais-clients for ub.egais-clients.

  define variable v-obj-type like ub.clients.obj-type no-undo .
  define variable v-obj-code like ub.clients.obj-code no-undo .

do
on error undo, return error return-value
:
  { rep/repfrm.i on 100 }
  assign
    v-i = 0
  .

  _alc-supplier :
  for each tt-alc-supplier :

    assign
      v-obj-type  = "":U
      v-obj-code  = 0
      v-i           = v-i + 1
      v-sup-count-t = v-sup-count-t + 1
    .
    { rep/repfrm.i disp v-i "'Запись в БД поставщиков...'" }
    find first buf_egais-clients no-lock
      where buf_egais-clients.supp-id = tt-alc-supplier.supp_id
    no-error .
    if not available buf_egais-clients
    then do:
      if tt-alc-supplier.supp_inn <> "":U then do :
        run find-client in this-procedure ( input tt-alc-supplier.supp_inn
                                          , output v-obj-type
                                          , output v-obj-code
                                          ) .
      end.
      run cur-time in this-procedure ( output v-today
                                     , output v-time
                                     ) .
      create buf_egais-clients.
      assign
        buf_egais-clients.supp-id               = tt-alc-supplier.supp_id
        buf_egais-clients.obj-code              = v-obj-code
        buf_egais-clients.obj-type              = v-obj-type
        buf_egais-clients.supp-adr-ur           = tt-alc-supplier.supp_adr_ur
        buf_egais-clients.supp-code-egais       = tt-alc-supplier.supp_code_egais
        buf_egais-clients.supp-code-reas-state  = tt-alc-supplier.supp_code_reas_state
        buf_egais-clients.supp-head-fio         = tt-alc-supplier.supp_head_fio
        buf_egais-clients.supp-inn              = tt-alc-supplier.supp_inn
        buf_egais-clients.supp-name             = tt-alc-supplier.supp_name
        buf_egais-clients.imp-date              = v-today
        buf_egais-clients.imp-time              = v-time
        buf_egais-clients.imp-user-id           = v-cntxt-userid
      .
      release buf_egais-clients no-error .
      if error-status :error
      then do:
        run put-error in this-procedure ( substitute( "Ошибка при записи в БД поставщика с кодом : &1  - &2. Поставщик не импортирован. &3&4&3&5&3&6"
                                                    , tt-alc-supplier.supp_id
                                                    , tt-alc-supplier.supp_name
                                                    , {&new-line}
                                                    , error-status :get-message(1)
                                                    , error-status :get-message(2)
                                                    , error-status :get-message(3)
                                                    )
                                        ) .
        next _alc-supplier.
      end.
      else do:
         assign
           v-sup-count-l = v-sup-count-l + 1
         .
      end.
    end.
    else do:
      run put-error in this-procedure ( substitute( "Уже есть запись поставщика с кодом : &1  - &2. Поставщик не импортирован. "
                                                  , tt-alc-supplier.supp_id
                                                  , tt-alc-supplier.supp_name
                                                  )
                                      ) .
    end.
  end.

  { rep/repfrm.i off}
end.

end procedure. /* fill-suppliers */

/* ============================================================= */
procedure calc-egais-gds :
  define output parameter p-tot-records as integer   no-undo .

  define buffer buf_egais-gds for ub.egais-gds.

  define variable v-i as integer   no-undo .
do
on error undo, return error return-value
:
  for each buf_egais-gds no-lock
  :
    assign
      v-i = v-i + 1
    .
  end.

  assign
    p-tot-records = v-i
  .
end.

end procedure. /* calc-egais-gds */

/* ============================================================= */
procedure calc-egais-clients :
  define output parameter p-tot-records as integer   no-undo .

  define buffer buf_egais-clients for ub.egais-clients.

  define variable v-i as integer   no-undo .
do
on error undo, return error return-value
:
  for each buf_egais-clients no-lock
  :
    assign
      v-i = v-i + 1
    .
  end.

  assign
    p-tot-records = v-i
  .

end.

end procedure. /* calc-egais-clients */

/* ============================================================= */
function get-date return date (input p-str as character) .
  define variable v-year  as integer   no-undo .
  define variable v-month as integer   no-undo .
  define variable v-day   as integer   no-undo .
  define variable v-date  as date      no-undo .
  define variable v-count as integer   no-undo .

  assign
    v-count = num-entries( p-str , '-' )
  .
  if v-count <> 3 then return ?.

  assign
    v-year  = integer( entry( 1 , p-str , '-' ) )
    v-month = integer( entry( 2 , p-str , '-' ) )
    v-day   = integer( entry( 3 , p-str , '-' ) )
    v-date  = date( v-month , v-day , v-year )
  no-error
  .
  return v-date.
end function.