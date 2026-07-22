/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Формирование для ВС имён директорий для обмена файлами

Автор: Молотков Сергей
Дата создания: 01/03/19
Author: Molotkov Sergey
Creation date: 01/03/19

01/III-2019, пользуясь остановкой xml-обмена в Туле, этот кусок был вынесен из состава bge/espcknum.p,
             чтобы хоть как-то уменьшить неуправляемость логики последнего.
*/
block-level on error undo, throw.

define input        parameter p-action         as   character    no-undo .
define input        parameter p-esys-id        like ub.ext-system.esys-id no-undo .
define input        parameter p-db-num         like ub.ext-system.db-num no-undo .
define input        parameter p-delivery-method as integer   no-undo .
define input        parameter oxml-exch-dir    as character no-undo .
define input        parameter oxml-heap-dir    as character no-undo .
define output       parameter p-source-dir     as   character    no-undo .
define output       parameter p-target-dir     as   character    no-undo .
define output       parameter p-temp-dir       as   character    no-undo .
define output       parameter p-log-file-name  as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Формирование для ВС имён директорий для обмена файлами".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i } /* &back-slash-char, &esys-dm-oracle-retail */

function esys-id-format returns character ( input p-esys-id as integer):
  return string(p-esys-id, "99999").
end.

FUNCTION nws-db-format returns character ( input p-db-num as integer):
  define variable v-nws-db-format as character no-undo .
  assign
    v-nws-db-format = string( p-db-num,  (if p-db-num > 999 then "99999":U else "999":U ) )
  .
  return v-nws-db-format.
END FUNCTION.


  define variable v-esysid-str as character no-undo .
  define variable v-dbnum-str  as character no-undo .
  define variable v-work-dir   as character no-undo .


  assign
    v-esysid-str = esys-id-format( p-esys-id )
    v-dbnum-str  = nws-db-format( ibs.th.gbl.gbl-var:g#db-num )
  .
  
  case p-action :
    when "get":U
    or
    when "fget":U
    then do:
      assign
        v-work-dir   = "ES" + v-esysid-str + "-":U + v-dbnum-str
        p-temp-dir   = oxml-exch-dir + {&back-slash-char} + v-work-dir + ".":U + v-esysid-str
        p-source-dir = oxml-exch-dir + {&back-slash-char} + v-work-dir
        p-target-dir = oxml-heap-dir + {&back-slash-char} + v-work-dir
        p-log-file-name  =  (if p-delivery-method = integer({&esys-dm-oracle-retail})
                            then (oxml-heap-dir + {&back-slash-char} + v-dbnum-str + "-":U + "ES" + v-esysid-str)
                            else (oxml-heap-dir + {&back-slash-char} + "actions.log")
                            )
      .
    end.
    when "put":U
    or
    when "fput"
    then do:
      assign
        v-work-dir   = v-dbnum-str + "-":U + "ES" + v-esysid-str
        p-temp-dir   = oxml-exch-dir + {&back-slash-char} + v-work-dir + ".":U + v-dbnum-str
        p-source-dir = oxml-heap-dir + {&back-slash-char} + v-work-dir
        p-target-dir = oxml-exch-dir + {&back-slash-char} + v-work-dir
        p-log-file-name  =  oxml-heap-dir + {&back-slash-char} + "actions.log"
      .
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Не предусмотрена операция" p-action "для" vss-workfile
        view-as alert-box error.
      return error.
    end.
  end case.


/* $Workfile$ end */