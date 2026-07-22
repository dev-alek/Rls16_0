/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Формирование временной таблицы по товарам для работы в smart objects

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&IF "{1}" = "def" &then
define new shared temp-table tt-goods no-undo like ub.goods.
define new shared temp-table tt-clients no-undo like ub.clients.
&else
procedure local-gds_inf :
  for each tt-goods
  :
    delete tt-goods.
  end.
  for each tt-clients
  :
    delete tt-clients.
  end.
  create tt-goods.
  buffer-copy {2} to tt-goods.
  create tt-clients.
&if "{3}" = "" &then
  assign
    tt-clients.obj-type = store-type
    tt-clients.obj-code = store-code
  .
&else
  assign
    tt-clients.obj-type = {3}
    tt-clients.obj-code = {4}
  .
&Endif

  {&net-proc}

  define variable v-ok as logical   no-undo .

  define variable v-chk-act-host-code as integer   no-undo .
  { gbl/hostcode.i
    tt-clients.obj-type
    tt-clients.obj-code
    v-chk-act-host-code
  }

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_reference_archive':U
    {&cntxt-firm}
    v-chk-act-host-code
    '':U
    0
    0
    0
    0
    true
    v-ok
  }

  if v-ok then do:
    run arc/gds_inf.w (parparentproc, tt-clients.obj-type, tt-clients.obj-code).
  end.
end procedure.
&endif
/* $Workfile$ e n d */