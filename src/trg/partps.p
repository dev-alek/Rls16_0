block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Изменение описания для партии приходной накладной
и для всех партий, которые были получены из этой партии

Автор: Хныкин Павел Андреевич
Дата создания: 07/03/07
Author: Pavel Khnykin
Creation date: 07/03/07

Автор1: Степанов Федор Владимирович
Дата создания: 02/03/06

Используется для корректировки атрибутов алкогольной продукции
(хранятся в описании партии).
Реализована передача команды на обновление по новостям
*/

define input parameter p-gds-code                  as integer                             no-undo .
define input parameter p-in-code                   as character                           no-undo .
define input parameter p-out-code                  as character                           no-undo . /*если ? то для всех партий, которые были получены из этой партии, в противном случае только для конкретной партии*/
define input parameter p-part-code                 as character                           no-undo .
define input parameter p-mark-db-num               like ub.parts.mark-db-num              no-undo .
define input parameter p-mark-code                 like ub.parts.mark-code                no-undo .
define input parameter p-alc-bottling-date         like ub.parts.alc-bottling-date        no-undo .
define input parameter p-alc-ref-ab-path           like ub.parts.alc-ref-ab-path          no-undo .
define input parameter p-alc-quality-certif-path   like ub.parts.alc-quality-certif-path  no-undo .
define input parameter p-alc-certif-path           like ub.parts.alc-certif-path          no-undo .
define input parameter p-alc-imp-type              like ub.parts.alc-imp-type             no-undo .
define input parameter p-alc-imp-code              like ub.parts.alc-imp-code             no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Изменение описания для партии приходной накладной и для всех партий, которые были получены из этой партии".
{ cmp/vssrevis.i }
{ cmp/library.i  }
{ cmp/trg-def.i  }
{ gbl/check-av.i }

define variable v-gds-code       as integer   no-undo .
define variable v-artic          as character no-undo .
define variable v-prod-type      as character no-undo .
define variable v-prod-code      as integer   no-undo .
define variable iCounter         as integer   no-undo .
define variable v-send-db-list   as character no-undo .
define variable v-remote-db-list as character no-undo .
define variable v-cmd            as character no-undo .
define variable v-msg-text       as character no-undo .

define buffer buf_goods      for ub.goods .
define buffer buf_gds-obj    for ub.gds-obj .
define buffer buf_parts      for ub.parts .
define buffer buf_parts-attr for ub.parts-attr .
define buffer buf_db         for ub.db .

main-block:
do transaction
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, "~n", error-status :get-message ( error-status :num-messages ) )
on stop   undo main-block, return error substitute( "&1. stop"  , vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  assign
    v-gds-code = p-gds-code
  .
  if p-alc-imp-code = ? 
  then do:
    assign
      p-alc-imp-code = 0
      p-mark-code = 0
    .
  end.
  if p-out-code = ?
  then do:
    p-out-code = "".
  end. 
  find first buf_goods no-lock
    where buf_goods.gds-code = v-gds-code no-error.
  if not available buf_goods then do:
    if g#news then do:
      /* Возможно, код товара был изменен. Пытаемся определить новый код */
      run check-avail-gds-code in this-procedure (input-output v-gds-code).
      find first buf_goods no-lock
        where buf_goods.gds-code = v-gds-code no-error.
      if not available buf_goods then do:
        assign
          v-msg-text = substitute("&1. Не найден товар с кодом &2.", vss-workfile, v-gds-code)
                     + {&new-line}
                     + substitute("Первоначальный поиск производился для товара с кодом &1", p-gds-code)
        .
        return error v-msg-text.
      end.
    end.
    else do:
      assign
        v-msg-text = substitute("Не найден товар с кодом &1", v-gds-code)
      .
      return error v-msg-text.
    end.
  end.

  /* блокируем товар на всех объектах */
  for each ub.gds-obj share-lock
    where ub.gds-obj.gds-code = v-gds-code
  on error undo main-block, return error
  :
    find first buf_gds-obj exclusive-lock
      where recid(buf_gds-obj) = recid(ub.gds-obj)
      .
  end.

  { gbl/arptpc.i
    v-gds-code
    v-artic
    v-prod-type
    v-prod-code
  }

  /* обновляем описание партии в атрибуте исходной партии */
  find first buf_parts-attr exclusive-lock
    where buf_parts-attr.in-code   = p-in-code
      and buf_parts-attr.gds-code  = v-gds-code
      and buf_parts-attr.part-code = p-part-code
    no-error .
  if available buf_parts-attr
  then do:
    assign
      buf_parts-attr.alc-bottling-date        = p-alc-bottling-date
      buf_parts-attr.alc-certif-path          = p-alc-certif-path
      buf_parts-attr.alc-imp-type             = p-alc-imp-type
      buf_parts-attr.alc-imp-code             = p-alc-imp-code
      buf_parts-attr.alc-quality-certif-path  = p-alc-quality-certif-path
      buf_parts-attr.alc-ref-ab-path          = p-alc-ref-ab-path
      buf_parts-attr.mark-code                = p-mark-code
      buf_parts-attr.mark-db-num              = p-mark-db-num
    .
  end.

  /* просматривается исходная партия и все партии, которые были получены из нее */
  for each ub.parts share-lock
    where ub.parts.in-code   = p-in-code
      and ub.parts.artic     = v-artic
      and ub.parts.prod-type = v-prod-type
      and ub.parts.prod-code = v-prod-code
      and ub.parts.part-code = p-part-code
      and (p-out-code = "" or ub.parts.out-code = p-out-code)
  on error undo main-block, return error
  :
    if ( ub.parts.alc-bottling-date       <> p-alc-bottling-date       )  or
       ( ub.parts.alc-certif-path         <> p-alc-certif-path         )  or
       ( ub.parts.alc-imp-type            <> p-alc-imp-type            )  or
       ( ub.parts.alc-imp-code            <> p-alc-imp-code            )  or
       ( ub.parts.alc-quality-certif-path <> p-alc-quality-certif-path )  or
       ( ub.parts.alc-ref-ab-path         <> p-alc-ref-ab-path         )  or
       ( ub.parts.mark-code               <> p-mark-code               )  or
       ( ub.parts.mark-db-num             <> p-mark-db-num             )
    then do:
      find first buf_parts exclusive-lock
        where recid(buf_parts) = recid(ub.parts)
        .
      assign
        buf_parts.alc-bottling-date        = p-alc-bottling-date
        buf_parts.alc-certif-path          = p-alc-certif-path
        buf_parts.alc-imp-type             = p-alc-imp-type
        buf_parts.alc-imp-code             = p-alc-imp-code
        buf_parts.alc-quality-certif-path  = p-alc-quality-certif-path
        buf_parts.alc-ref-ab-path          = p-alc-ref-ab-path
        buf_parts.mark-code                = p-mark-code
        buf_parts.mark-db-num              = p-mark-db-num
        iCounter                           = iCounter + 1
      .
    end.
  end.

  /* Отправляем команду на изменение по новостям */
  if iCounter > 0 then do:
    v-remote-db-list = "":U .
    for each buf_db where buf_db.db-num > 0 no-lock :
      assign
        v-remote-db-list = (if v-remote-db-list <> "":U then v-remote-db-list + {&delim-nws}
                                                        else ""
                           ) + string(buf_db.db-num)
      .
    end.

    /* Если БД центральная, то разослать во все удаленные базы */
    if g#db-num = 0 then do:
      assign
        v-send-db-list = v-remote-db-list
      .
    end.
    /* Если БД не центральная и не новости (новости сами пришли из ГБД), послать в ГБД  */
    if g#db-num <> 0 and not g#news then do:
      assign
        v-send-db-list = "0":U
      .
    end.
    /* Если БД не центральная и не новости (новости сами пришли из ГБД), послать в ГБД  */
    if v-send-db-list <> "":U then do:
      assign
        v-cmd = "command":U                 + {&delim-nws}
              + "parts":U                   + {&delim-nws}
              + "alc-attr":U                + {&delim-nws}
              + string(v-gds-code)          + {&delim-nws}
              + p-in-code                   + {&delim-nws}
              + p-part-code                 + {&delim-nws}
              + string(p-mark-db-num)       + {&delim-nws}
              + (if p-mark-code = ? then "0" else string(p-mark-code)) + {&delim-nws}
              + (if p-alc-bottling-date = ? then "?" else string(p-alc-bottling-date)) + {&delim-nws}
              + p-alc-ref-ab-path           + {&delim-nws}
              + p-alc-quality-certif-path   + {&delim-nws}
              + p-alc-certif-path           + {&delim-nws}
              + p-alc-imp-type              + {&delim-nws}
              + (if p-alc-imp-code = ? then "0" else STRING(p-alc-imp-code)) + {&delim-nws}
              + p-out-code
      .
      if v-cmd = ? 
      then do:
        message substitute ('Ошибка генерации комманды - "&1"', ('command|parts|alc-attr'
          + "|" + string(v-gds-code) + "|" + p-in-code + "|" + p-part-code))
        view-as alert-box.
        return error substitute ('Ошибка генерации комманды - "&1"', ('command|parts|alc-attr'
          + "|" + string(v-gds-code) + "|" + p-in-code + "|" + p-part-code)).
      end.
      run nws/cr-route.p
        (input  {&send-cmd}
        ,input  v-cmd
        ,input  ?
        ,input  v-send-db-list
        ).
    end.
  end.
end.