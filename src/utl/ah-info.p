block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ah-info.p $
$Archive: utl/ah-info.p $

Текущее состояние складского архива

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 11/08/01

*/

{ utl/ah-info.i  }
define output parameter table for temp-obj-arh .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ah-info.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/ah-info.p $":U .
define variable vss-description as character no-undo init "Текущее состояние складского архива".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/clntattr.i }
{ gbl/waitfram.i }


do
on error undo, return error return-value
:
  run init-temp-obj-arh in this-procedure .

  run scan-lock-prc in this-procedure .

  run waitfram-hide in this-procedure .
end.


procedure init-temp-obj-arh :

  define variable v-attr-value as character no-undo .
  define variable v-attr-type  as character no-undo .

  define buffer buf_temp-obj-arh for temp-obj-arh .
  define buffer buf_db for ub.db .
  define buffer buf_clients for ub.clients .
  define buffer buf_batchprocess for ub.batchprocess .

  define variable v-obj-deleted as logical   no-undo .

  do
  on error undo, return error return-value
  :
    for each buf_temp-obj-arh
    on error undo, return error return-value
    :
      delete buf_temp-obj-arh .
    end.

    define buffer buf_sys-ctrl for ub.sys-ctrl .
    find first buf_sys-ctrl no-lock .

    /* в ГБД просматриваем все объекты */
    /* в УБД просматриваем только объекты текущей БД */
    for each buf_db no-lock
      where (buf_sys-ctrl.db-num = 0
            or (buf_sys-ctrl.db-num <> 0
               and buf_db.db-num = buf_sys-ctrl.db-num
               )
            )
    ,each buf_clients no-lock
      where buf_clients.db-num = buf_db.db-num
    on error undo, return error return-value
    :
      run waitfram-show in this-procedure
        (input substitute("Запрос информации о складских архивах БД &1, объект &2 &3"
                         ,buf_db.db-num
                         ,buf_clients.obj-type
                         ,buf_clients.obj-code
                         )
        ) .

      assign
        v-obj-deleted = (buf_clients.stts <> 0)
      .

      create buf_temp-obj-arh .
      assign
        buf_temp-obj-arh.obj-type     = buf_clients.obj-type
        buf_temp-obj-arh.obj-code     = buf_clients.obj-code
        buf_temp-obj-arh.db-num       = buf_clients.db-num
        buf_temp-obj-arh.archive-type = {&btpr-type-arh}
        buf_temp-obj-arh.sort-code    = 1
        buf_temp-obj-arh.obj-deleted  = v-obj-deleted
      .

      /* заполняем информацию по складскому архиву по товарам */
      run clntattr-value in this-procedure
        (input  buf_temp-obj-arh.obj-type /* p-obj-type */
        ,input  buf_temp-obj-arh.obj-code /* p-obj-code */
        ,input  {&attr-arh-calc}          /* p-code     */
        ,output v-attr-value              /* p-value    */
        ,output v-attr-type               /* p-type     */
        ) .
      assign
        buf_temp-obj-arh.archive-calc = (lookup(v-attr-value, "yes,true") > 0)
      .

      run clntattr-value in this-procedure
        (input  buf_temp-obj-arh.obj-type /* p-obj-type */
        ,input  buf_temp-obj-arh.obj-code /* p-obj-code */
        ,input  {&attr-arh-del}           /* p-code     */
        ,output v-attr-value              /* p-value    */
        ,output v-attr-type               /* p-type     */
        ) .
      assign
        buf_temp-obj-arh.archive-del = (lookup(v-attr-value, "yes,true") > 0)
      .

      run clntattr-value in this-procedure
        (input  buf_temp-obj-arh.obj-type /* p-obj-type */
        ,input  buf_temp-obj-arh.obj-code /* p-obj-code */
        ,input  {&attr-arh-disable}       /* p-code     */
        ,output v-attr-value              /* p-value    */
        ,output v-attr-type               /* p-type     */
        ) .
      assign
        buf_temp-obj-arh.archive-disable = (lookup(v-attr-value, "yes,true") > 0)
      .

      run clntattr-value in this-procedure
        (input  buf_temp-obj-arh.obj-type /* p-obj-type */
        ,input  buf_temp-obj-arh.obj-code /* p-obj-code */
        ,input  {&attr-arh-rest}          /* p-code     */
        ,output v-attr-value              /* p-value    */
        ,output v-attr-type               /* p-type     */
        ) .
      assign
        buf_temp-obj-arh.archive-rest = (lookup(v-attr-value, "yes,true") > 0)
      .

      find first buf_batchprocess no-lock
        where buf_batchprocess.bp_type       = {&btpr-type-arh}
          and buf_batchprocess.bp_status     = {&btpr-normal}
          and buf_batchprocess.CharKey_Three = buf_temp-obj-arh.obj-type
          and buf_batchprocess.Key#_One      = buf_temp-obj-arh.obj-code
        no-error .
      if available buf_batchprocess
      then do:
        assign
          buf_temp-obj-arh.archive-bpexist = true
        .
      end.

      run clntattr-value in this-procedure
        (input  buf_temp-obj-arh.obj-type /* p-obj-type */
        ,input  buf_temp-obj-arh.obj-code /* p-obj-code */
        ,input  {&attr-arh-detail-date}   /* p-code     */
        ,output v-attr-value              /* p-value    */
        ,output v-attr-type               /* p-type     */
        ) .
      assign
        buf_temp-obj-arh.archive-detail-date = date(v-attr-value)
      .

      run clntattr-value in this-procedure
        (input  buf_temp-obj-arh.obj-type /* p-obj-type */
        ,input  buf_temp-obj-arh.obj-code /* p-obj-code */
        ,input  {&attr-arh-start-date}    /* p-code     */
        ,output v-attr-value              /* p-value    */
        ,output v-attr-type               /* p-type     */
        ) .
      assign
        buf_temp-obj-arh.archive-start-date = date(v-attr-value)
      .

      run clntattr-value in this-procedure
        (input  buf_temp-obj-arh.obj-type  /* p-obj-type */
        ,input  buf_temp-obj-arh.obj-code  /* p-obj-code */
        ,input  {&attr-arh-recalc-date}    /* p-code     */
        ,output v-attr-value               /* p-value    */
        ,output v-attr-type                /* p-type     */
        ) .
      assign
        buf_temp-obj-arh.archive-recalc-date = date(v-attr-value)
      .

      create buf_temp-obj-arh .
      assign
        buf_temp-obj-arh.obj-type     = buf_clients.obj-type
        buf_temp-obj-arh.obj-code     = buf_clients.obj-code
        buf_temp-obj-arh.db-num       = buf_clients.db-num
        buf_temp-obj-arh.archive-type = {&btpr-type-ahsp}
        buf_temp-obj-arh.sort-code    = 2
        buf_temp-obj-arh.obj-deleted  = v-obj-deleted
      .

      /* заполняем информацию по складскому архиву по поставщикам */
      run clntattr-value in this-procedure
        (input  buf_temp-obj-arh.obj-type /* p-obj-type */
        ,input  buf_temp-obj-arh.obj-code /* p-obj-code */
        ,input  {&attr-ahsp-calc}         /* p-code     */
        ,output v-attr-value              /* p-value    */
        ,output v-attr-type               /* p-type     */
        ) .
      assign
        buf_temp-obj-arh.archive-calc = (lookup(v-attr-value, "yes,true") > 0)
      .

      run clntattr-value in this-procedure
        (input  buf_temp-obj-arh.obj-type /* p-obj-type */
        ,input  buf_temp-obj-arh.obj-code /* p-obj-code */
        ,input  {&attr-ahsp-del}          /* p-code     */
        ,output v-attr-value              /* p-value    */
        ,output v-attr-type               /* p-type     */
        ) .
      assign
        buf_temp-obj-arh.archive-del = (lookup(v-attr-value, "yes,true") > 0)
      .

      run clntattr-value in this-procedure
        (input  buf_temp-obj-arh.obj-type /* p-obj-type */
        ,input  buf_temp-obj-arh.obj-code /* p-obj-code */
        ,input  {&attr-ahsp-disable}      /* p-code     */
        ,output v-attr-value              /* p-value    */
        ,output v-attr-type               /* p-type     */
        ) .
      assign
        buf_temp-obj-arh.archive-disable = (lookup(v-attr-value, "yes,true") > 0)
      .

      run clntattr-value in this-procedure
        (input  buf_temp-obj-arh.obj-type /* p-obj-type */
        ,input  buf_temp-obj-arh.obj-code /* p-obj-code */
        ,input  {&attr-ahsp-rest}          /* p-code     */
        ,output v-attr-value              /* p-value    */
        ,output v-attr-type               /* p-type     */
        ) .
      assign
        buf_temp-obj-arh.archive-rest = (lookup(v-attr-value, "yes,true") > 0)
      .

      find first buf_batchprocess no-lock
        where buf_batchprocess.bp_type       = {&btpr-type-ahsp}
          and buf_batchprocess.bp_status     = {&btpr-normal}
          and buf_batchprocess.CharKey_Three = buf_temp-obj-arh.obj-type
          and buf_batchprocess.Key#_One      = buf_temp-obj-arh.obj-code
        no-error .
      if available buf_batchprocess
      then do:
        assign
          buf_temp-obj-arh.archive-bpexist = true
        .
      end.

      run clntattr-value in this-procedure
        (input  buf_temp-obj-arh.obj-type /* p-obj-type */
        ,input  buf_temp-obj-arh.obj-code /* p-obj-code */
        ,input  {&attr-ahsp-detail-date}  /* p-code     */
        ,output v-attr-value              /* p-value    */
        ,output v-attr-type               /* p-type     */
        ) .
      assign
        buf_temp-obj-arh.archive-detail-date = date(v-attr-value)
      .

      run clntattr-value in this-procedure
        (input  buf_temp-obj-arh.obj-type /* p-obj-type */
        ,input  buf_temp-obj-arh.obj-code /* p-obj-code */
        ,input  {&attr-ahsp-start-date}   /* p-code     */
        ,output v-attr-value              /* p-value    */
        ,output v-attr-type               /* p-type     */
        ) .
      assign
        buf_temp-obj-arh.archive-start-date = date(v-attr-value)
      .

      run clntattr-value in this-procedure
        (input  buf_temp-obj-arh.obj-type /* p-obj-type */
        ,input  buf_temp-obj-arh.obj-code /* p-obj-code */
        ,input  {&attr-ahsp-recalc-date}  /* p-code     */
        ,output v-attr-value              /* p-value    */
        ,output v-attr-type               /* p-type     */
        ) .
      assign
        buf_temp-obj-arh.archive-recalc-date = date(v-attr-value)
      .

      create buf_temp-obj-arh .
      assign
        buf_temp-obj-arh.obj-type     = buf_clients.obj-type
        buf_temp-obj-arh.obj-code     = buf_clients.obj-code
        buf_temp-obj-arh.db-num       = buf_clients.db-num
        buf_temp-obj-arh.archive-type = {&btpr-type-aht}
        buf_temp-obj-arh.sort-code    = 3
        buf_temp-obj-arh.obj-deleted  = v-obj-deleted
      .

      /* заполняем информацию по складскому архиву по типам приобретения */
      run clntattr-value in this-procedure
        (input  buf_temp-obj-arh.obj-type /* p-obj-type */
        ,input  buf_temp-obj-arh.obj-code /* p-obj-code */
        ,input  {&attr-aht-calc}          /* p-code     */
        ,output v-attr-value              /* p-value    */
        ,output v-attr-type               /* p-type     */
        ) .
      assign
        buf_temp-obj-arh.archive-calc = (lookup(v-attr-value, "yes,true") > 0)
      .

      run clntattr-value in this-procedure
        (input  buf_temp-obj-arh.obj-type /* p-obj-type */
        ,input  buf_temp-obj-arh.obj-code /* p-obj-code */
        ,input  {&attr-aht-del}           /* p-code     */
        ,output v-attr-value              /* p-value    */
        ,output v-attr-type               /* p-type     */
        ) .
      assign
        buf_temp-obj-arh.archive-del = (lookup(v-attr-value, "yes,true") > 0)
      .

      run clntattr-value in this-procedure
        (input  buf_temp-obj-arh.obj-type /* p-obj-type */
        ,input  buf_temp-obj-arh.obj-code /* p-obj-code */
        ,input  {&attr-aht-disable}       /* p-code     */
        ,output v-attr-value              /* p-value    */
        ,output v-attr-type               /* p-type     */
        ) .
      assign
        buf_temp-obj-arh.archive-disable = (lookup(v-attr-value, "yes,true") > 0)
      .

      run clntattr-value in this-procedure
        (input  buf_temp-obj-arh.obj-type /* p-obj-type */
        ,input  buf_temp-obj-arh.obj-code /* p-obj-code */
        ,input  {&attr-aht-rest}           /* p-code     */
        ,output v-attr-value              /* p-value    */
        ,output v-attr-type               /* p-type     */
        ) .
      assign
        buf_temp-obj-arh.archive-rest = (lookup(v-attr-value, "yes,true") > 0)
      .

      find first buf_batchprocess no-lock
        where buf_batchprocess.bp_type       = {&btpr-type-aht}
          and buf_batchprocess.bp_status     = {&btpr-normal}
          and buf_batchprocess.CharKey_Three = buf_temp-obj-arh.obj-type
          and buf_batchprocess.Key#_One      = buf_temp-obj-arh.obj-code
        no-error .
      if available buf_batchprocess
      then do:
        assign
          buf_temp-obj-arh.archive-bpexist = true
        .
      end.

      run clntattr-value in this-procedure
        (input  buf_temp-obj-arh.obj-type /* p-obj-type */
        ,input  buf_temp-obj-arh.obj-code /* p-obj-code */
        ,input  {&attr-aht-detail-date}   /* p-code     */
        ,output v-attr-value              /* p-value    */
        ,output v-attr-type               /* p-type     */
        ) .
      assign
        buf_temp-obj-arh.archive-detail-date = date(v-attr-value)
      .

      run clntattr-value in this-procedure
        (input  buf_temp-obj-arh.obj-type /* p-obj-type */
        ,input  buf_temp-obj-arh.obj-code /* p-obj-code */
        ,input  {&attr-aht-start-date}    /* p-code     */
        ,output v-attr-value              /* p-value    */
        ,output v-attr-type               /* p-type     */
        ) .
      assign
        buf_temp-obj-arh.archive-start-date = date(v-attr-value)
      .

      run clntattr-value in this-procedure
        (input  buf_temp-obj-arh.obj-type /* p-obj-type */
        ,input  buf_temp-obj-arh.obj-code /* p-obj-code */
        ,input  {&attr-aht-recalc-date}   /* p-code     */
        ,output v-attr-value              /* p-value    */
        ,output v-attr-type               /* p-type     */
        ) .
      assign
        buf_temp-obj-arh.archive-recalc-date = date(v-attr-value)
      .
    end.
  end.

end procedure. /* init-temp-obj-arh */


procedure scan-lock-prc :

  do
  on error undo, return error return-value
  :
    /* проверяем, по каким объектам происходит расчет в данное время объекты */
    define buffer buf_batchprocess  for ub.batchprocess .
    define buffer lock_batchprocess for ub.batchprocess .
    define buffer buf_temp-obj-arh      for temp-obj-arh .

    for each buf_batchprocess no-lock
      where buf_batchprocess.bp_type   = "lock" + {&lock-prc-calc-arh}
        and buf_batchprocess.bp_status = {&btpr-normal}
    on error undo, return error return-value
    :
      find first lock_batchprocess exclusive-lock
        where recid(lock_batchprocess) = recid(buf_batchprocess)
        no-wait no-error .
      if locked(lock_batchprocess)
      then do:
        find first buf_temp-obj-arh no-lock
          where buf_temp-obj-arh.obj-type     = buf_batchprocess.charkey_one
            and buf_temp-obj-arh.obj-code     = buf_batchprocess.key#_one
            and buf_temp-obj-arh.archive-type = {&btpr-type-arh}
          no-error .
        if available buf_temp-obj-arh
        then do:
          assign
            buf_temp-obj-arh.archive-lock-prc    = true
            buf_temp-obj-arh.archive-execuser    = buf_batchprocess.bp_execuser_id
            buf_temp-obj-arh.archive-execsysdate = buf_batchprocess.bp_execsysdate
            buf_temp-obj-arh.archive-execsystime = buf_batchprocess.bp_execsystime
          .
        end.
      end.
    end.

    for each buf_batchprocess no-lock
      where buf_batchprocess.bp_type   = "lock" + {&lock-prc-calc-supp-arh}
        and buf_batchprocess.bp_status = {&btpr-normal}
    on error undo, return error return-value
    :
      find first lock_batchprocess exclusive-lock
        where recid(lock_batchprocess) = recid(buf_batchprocess)
        no-wait no-error .
      if locked(lock_batchprocess)
      then do:
        find first buf_temp-obj-arh no-lock
          where buf_temp-obj-arh.obj-type     = buf_batchprocess.charkey_one
            and buf_temp-obj-arh.obj-code     = buf_batchprocess.key#_one
            and buf_temp-obj-arh.archive-type = {&btpr-type-ahsp}
          no-error .
        if available buf_temp-obj-arh
        then do:
          assign
            buf_temp-obj-arh.archive-lock-prc    = true
            buf_temp-obj-arh.archive-execuser    = buf_batchprocess.bp_execuser_id
            buf_temp-obj-arh.archive-execsysdate = buf_batchprocess.bp_execsysdate
            buf_temp-obj-arh.archive-execsystime = buf_batchprocess.bp_execsystime
          .
        end.
      end.
    end.

    for each buf_batchprocess no-lock
      where buf_batchprocess.bp_type   = "lock" + {&lock-prc-calc-aht}
        and buf_batchprocess.bp_status = {&btpr-normal}
    on error undo, return error return-value
    :
      find first lock_batchprocess exclusive-lock
        where recid(lock_batchprocess) = recid(buf_batchprocess)
        no-wait no-error .
      if locked(lock_batchprocess)
      then do:
        find first buf_temp-obj-arh no-lock
          where buf_temp-obj-arh.obj-type     = buf_batchprocess.charkey_one
            and buf_temp-obj-arh.obj-code     = buf_batchprocess.key#_one
            and buf_temp-obj-arh.archive-type = {&btpr-type-aht}
          no-error .
        if available buf_temp-obj-arh
        then do:
          assign
            buf_temp-obj-arh.archive-lock-prc    = true
            buf_temp-obj-arh.archive-execuser    = buf_batchprocess.bp_execuser_id
            buf_temp-obj-arh.archive-execsysdate = buf_batchprocess.bp_execsysdate
            buf_temp-obj-arh.archive-execsystime = buf_batchprocess.bp_execsystime
          .
        end.
      end.
    end.

    for each buf_batchprocess no-lock
      where buf_batchprocess.bp_type   = "lock" + {&lock-prc-restore-arh}
        and buf_batchprocess.bp_status = {&btpr-normal}
    on error undo, return error return-value
    :
      find first lock_batchprocess exclusive-lock
        where recid(lock_batchprocess) = recid(buf_batchprocess)
        no-wait no-error .
      if locked(lock_batchprocess)
      then do:
        find first buf_temp-obj-arh no-lock
          where buf_temp-obj-arh.obj-type     = buf_batchprocess.charkey_one
            and buf_temp-obj-arh.obj-code     = buf_batchprocess.key#_one
            and buf_temp-obj-arh.archive-type = {&btpr-type-arh}
          no-error .
        if available buf_temp-obj-arh
        then do:
          assign
            buf_temp-obj-arh.archive-rest-lock-prc    = true
            buf_temp-obj-arh.archive-rest-execuser    = buf_batchprocess.bp_execuser_id
            buf_temp-obj-arh.archive-rest-execsysdate = buf_batchprocess.bp_execsysdate
            buf_temp-obj-arh.archive-rest-execsystime = buf_batchprocess.bp_execsystime
          .
        end.
      end.
    end.

    for each buf_batchprocess no-lock
      where buf_batchprocess.bp_type   = "lock" + {&lock-prc-restore-ahsp}
        and buf_batchprocess.bp_status = {&btpr-normal}
    on error undo, return error return-value
    :
      find first lock_batchprocess exclusive-lock
        where recid(lock_batchprocess) = recid(buf_batchprocess)
        no-wait no-error .
      if locked(lock_batchprocess)
      then do:
        find first buf_temp-obj-arh no-lock
          where buf_temp-obj-arh.obj-type     = buf_batchprocess.charkey_one
            and buf_temp-obj-arh.obj-code     = buf_batchprocess.key#_one
            and buf_temp-obj-arh.archive-type = {&btpr-type-ahsp}
          no-error .
        if available buf_temp-obj-arh
        then do:
          assign
            buf_temp-obj-arh.archive-rest-lock-prc    = true
            buf_temp-obj-arh.archive-rest-execuser    = buf_batchprocess.bp_execuser_id
            buf_temp-obj-arh.archive-rest-execsysdate = buf_batchprocess.bp_execsysdate
            buf_temp-obj-arh.archive-rest-execsystime = buf_batchprocess.bp_execsystime
          .
        end.
      end.
    end.

    for each buf_batchprocess no-lock
      where buf_batchprocess.bp_type   = "lock" + {&lock-prc-restore-aht}
        and buf_batchprocess.bp_status = {&btpr-normal}
    on error undo, return error return-value
    :
      find first lock_batchprocess exclusive-lock
        where recid(lock_batchprocess) = recid(buf_batchprocess)
        no-wait no-error .
      if locked(lock_batchprocess)
      then do:
        find first buf_temp-obj-arh no-lock
          where buf_temp-obj-arh.obj-type     = buf_batchprocess.charkey_one
            and buf_temp-obj-arh.obj-code     = buf_batchprocess.key#_one
            and buf_temp-obj-arh.archive-type = {&btpr-type-aht}
          no-error .
        if available buf_temp-obj-arh
        then do:
          assign
            buf_temp-obj-arh.archive-rest-lock-prc    = true
            buf_temp-obj-arh.archive-rest-execuser    = buf_batchprocess.bp_execuser_id
            buf_temp-obj-arh.archive-rest-execsysdate = buf_batchprocess.bp_execsysdate
            buf_temp-obj-arh.archive-rest-execsystime = buf_batchprocess.bp_execsystime
          .
        end.
      end.
    end.
  end.

end procedure. /* scan-lock-prc */