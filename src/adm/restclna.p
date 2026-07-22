block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: restclna.p $
$Archive: adm/restclna.p $

Выгрузка атрибутов в УБД

Автор: Перваков Михаил Сергеевич
Дата создания: 07/28/04
Author: Mikhail Pervakov
Creation date: 07/28/04

*/


define input  parameter p-db-num    as integer   no-undo .
define input  parameter p-copy-arh  as logical   no-undo .
define input  parameter p-copy-ahsp as logical   no-undo .
define input  parameter p-copy-aht  as logical   no-undo .

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: restclna.p $":U .
def var vss-archive     as character no-undo init "$Archive: adm/restclna.p $":U .
def var vss-description as character no-undo init "Выгрузка атрибутов в УБД".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/clntattr.i }

/*on write of dst.clients-attr override do: end.*/

do
on error undo, return error return-value
:

  run copy-clients-attr in this-procedure .

  for each ub.clients no-lock
    where ub.clients.db-num = p-db-num
  on error undo, return error
  :
    run copy-archive-attr in this-procedure
      (input  ub.clients.obj-type /* p-obj-type  */
      ,input  ub.clients.obj-code /* p-obj-code  */
      ,input  p-copy-arh          /* p-copy-arh  */
      ,input  p-copy-ahsp         /* p-copy-ahsp */
      ,input  p-copy-aht          /* p-copy-aht  */
      ) .
  end.
end.

procedure copy-clients-attr :

  define variable v-filter-reject     as character no-undo .

  do
  on error undo, return error return-value
  :
    run clntattr-get-archive-attr in this-procedure
      (output v-filter-reject
      ) .

    /* скопировать все атрибуты клиентов, которые не имеют отношения к архивам */
    for each ub.clients-attr
    on error undo, return error return-value
    :
      if lookup(ub.clients-attr.attr-code, v-filter-reject) > 0
      then do:
        /* пропускаем атрибуты клиентов, имеющие отношение к архивам */
        next . /* --->>>--- */
      end.

      create dst.clients-attr .
      buffer-copy ub.clients-attr to dst.clients-attr .
    end.
  end.

end procedure. /* copy-clients-attr */


procedure copy-archive-attr :

  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-copy-arh  as logical   no-undo .
  define input  parameter p-copy-ahsp as logical   no-undo .
  define input  parameter p-copy-aht  as logical   no-undo .

  define variable v-copy-arh-list  as character no-undo .
  define variable v-copy-ahsp-list as character no-undo .
  define variable v-copy-aht-list  as character no-undo .
  define variable v-copy-list      as character no-undo .

  do
  on error undo, return error return-value
  :
    run clntattr-get-archive-by-type in this-procedure
      (input  {&btpr-type-arh}
      ,output v-copy-arh-list
      ) .

    run clntattr-get-archive-by-type in this-procedure
      (input  {&btpr-type-ahsp}
      ,output v-copy-ahsp-list
      ) .

    run clntattr-get-archive-by-type in this-procedure
      (input  {&btpr-type-aht}
      ,output v-copy-aht-list
      ) .

    assign
      v-copy-list = ""
    .

    if p-copy-arh = true
    then do:
      assign
        v-copy-list = v-copy-list
                    + (if v-copy-list <> '':u then ',':u else '':u)
                    + v-copy-arh-list
      .
    end.

    if p-copy-ahsp = true
    then do:
      assign
        v-copy-list = v-copy-list
                    + (if v-copy-list <> '':u then ',':u else '':u)
                    + v-copy-ahsp-list
      .
    end.

    if p-copy-aht = true
    then do:
      assign
        v-copy-list = v-copy-list
                    + (if v-copy-list <> '':u then ',':u else '':u)
                    + v-copy-aht-list
      .
    end.

    for each ub.clients-attr
      where ub.clients-attr.obj-type = p-obj-type
        and ub.clients-attr.obj-code = p-obj-code
    on error undo, return error return-value
    :
      if lookup(ub.clients-attr.attr-code, v-copy-list) > 0
      then do:
        /* копируем атрибуты, имеющие отношение к архивам */
        create dst.clients-attr .
        buffer-copy ub.clients-attr to dst.clients-attr .
      end.
    end.

  end.

end procedure. /* copy-archive-attr */