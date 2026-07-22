block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Запись в БД информацию об размере областей БД, и отправка ее по новостям в ГБД

Автор: Румянцев Юрий Александрович
Дата создания: 19/01/06
Author: Yuri Rumyantsev
Creation date: 19/01/06

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Запись в БД информацию об размере областей БД, и отправка ее по новостям в ГБД".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/waitfram.i }

define variable vdelimiter  as character no-undo initial "~\".
define variable sizearea    as decimal   no-undo.
define variable sizetom     as decimal   no-undo.
define variable percenttom  as decimal   no-undo .
define variable v-today     as date      no-undo .
define variable v-time      as integer   no-undo .

define variable v-infodb-date as date      no-undo .

define buffer buf_sys-ctrl for ub.sys-ctrl .
define buffer buf_db-info for ub.db-info.

find first buf_sys-ctrl no-lock .

assign
  v-infodb-date = ?
.
find last buf_db-info no-lock where
        buf_db-info.db-num = buf_sys-ctrl.db-num use-index  pi no-error.
if available buf_db-info then do:
  assign
  v-infodb-date = buf_db-info.date-info.
end.

if v-infodb-date <> ?
  and v-infodb-date >= today
then do:
  return .
end.  
 
run waitfram-show in this-procedure ("Сбор информации о БД").

do transaction
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:

  for each ub._areastatus no-lock
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :

    if ub._areastatus._areastatus-areanum = 1
      or ub._areastatus._areastatus-areaname begins "primary recovery"
      or ub._areastatus._areastatus-areaname begins "after image"
    then do:
      next.
    end.

    assign
      v-today = today
      v-time  = time
    .

    find first ub._area no-lock
      where ub._area._area-num = ub._areastatus._areastatus-areanum
     .

    assign
      SizeArea = 0
    .
    for each ub._areaextent no-lock
      where ub._areaextent._area-recid = recid(ub._area)
    on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo, return error substitute( "&1. stop", vss-workfile )
    on endkey undo, return error substitute( "&1. endkey", vss-workfile )
    :
        find ub._filelist no-lock
          where entry(num-entries(ub._filelist._filelist-name, vdelimiter), ub._filelist._filelist-name, vdelimiter)
                = entry(num-entries(ub._areaextent._extent-path, vdelimiter), ub._areaextent._extent-path, vdelimiter)
          .

        if ub._filelist._filelist-name = ub._areastatus._areastatus-lastextent then do:
          if ub._filelist._filelist-openmode = "BOTHIO":U
            and ub._areaextent._extent-type < 32
          then do:
            assign
              sizetom = decimal(ub._filelist._filelist-size)
              percenttom = sizetom * 100 / 2048000
            .
          end.
          else do:
            assign
              sizetom    = decimal(decimal(ub._areastatus._areastatus-hiwater) * decimal(ub._area._area-blocksize) - sizearea)
              percenttom = ( sizetom  / decimal(ub._filelist._filelist-size * 1024) ) * 100
            .
          end.
        end.
        else do:
          assign
            sizearea   = sizearea +  decimal(ub._filelist._filelist-size * 1024)
            sizetom    = 0
            percenttom = ?
          .
        end.
        
        find first ub.db-info exclusive-lock
          where ub.db-info.db-num     = buf_sys-ctrl.db-num                 /* Номер БД  */
            and ub.db-info.date-info  = v-today                             /* Дата      */
            and ub.db-info.area-ID    = ub._areastatus._AreaStatus-Id       /* Номер области */
            and ub.db-info.volume-num = ub._AreaStatus._AreaStatus-Areanum  /* Номер тома области  */
          no-error.

        if not available ub.db-info then do:
           create ub.db-info.
           assign
             ub.db-info.db-num      = buf_sys-ctrl.db-num                   /* Номер БД            */
             ub.db-info.date-info   = v-today                               /* Дата                */
             ub.db-info.area-id     = ub._areastatus._areastatus-id         /* Номер области       */
             ub.db-info.area-name   = ub._areastatus._areastatus-areaname   /* Имя области         */
             ub.db-info.volume-num  = ub._areastatus._areastatus-areanum    /* Номер тома области  */
             ub.db-info.volume-name = ub._filelist._filelist-name           /* Имя тома области    */
           .
        end.
        
        assign
          ub.db-info.time-info               = v-time                      /* Время                              */
          ub.db-info.volume-size             = ub._FileList._FileList-Size /* Размер тома области                */
          ub.db-info.volume-hiwater          = sizetom                     /* Заполненность тома области         */
          ub.db-info.volume-percent-hiwater  = percenttom                  /* Процент заполненности тома области */
          ub.db-info.volume-name = ub._filelist._filelist-name           /* Имя тома области    */
        .

    end. /* for each _areaextent */
  end. /* for each _areastatus no-lock */
end. /* do transaction:  */

run waitfram-hide in this-procedure .