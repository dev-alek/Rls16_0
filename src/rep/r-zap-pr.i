/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

ОТЧЕТ О СОСТОЯНИИ ЗАПАСА И ПРОДАЖАХ

Автор: Демин Алексей Сергеевич
Дата создания: 03/23/06
Author: Alexey Demin
Creation date: 03/23/06

*/

/* Parameters Definitions ---                                           */
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/r-page1.i }
{ cmp/r-pril.i }
{ rep/r-sym.i }
/*{ rep/r-gl.i }*/
{ cmp/str-glbl.i }
{ trg/factord.i }
  { rep/rep-bt.i }

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

define input parameter classify     as character no-undo.
define input parameter ShowPrice    as integer no-undo .
define input parameter ShowZero1    as logical no-undo .
define input parameter ShowZero2    as logical no-undo .

define buffer buf_clients   for clients .
define buffer buf_ot-line   for ot-line .
define buffer buf_gds-obj   for gds-obj .
define buffer buf_goods     for goods   .
define buffer buf_stk-line  for stk-line .

define var f-end-cost  as decimal no-undo.
define var f-beg-qnty  as decimal no-undo.
define var f-sale-qnty as decimal no-undo.
define var f-end-qnty  as decimal no-undo.
define var f-end-sum   as decimal no-undo.

define var n-nm        as integer init 0 no-undo .

define var Ostat       as   logical no-undo.
define var Oborot      as   logical no-undo.

define var var-client   as character no-undo .

define var    v-fact-order-start     as decimal   no-undo .
define var    v-fact-order-end       as decimal   no-undo .

define temp-table temp-goods no-undo  /* для списка товаров */
  field gds-code  like goods.gds-code
  field artic     like goods.artic
  field cli       like clients.obj-name
  field grp-name  like goods.grp-name
  field prod-code like goods.prod-code
  field prod-type like goods.prod-type
  field prt-root  like goods.prt-root
  field gds-name  like goods.gds-name
  field full-id   as character
  INDEX pi  IS PRIMARY full-id
  INDEX pi1  prod-type prod-code artic
  INDEX pi2  grp-name
  INDEX pi3  cli
  INDEX pi4  artic
  INDEX pi5  gds-code
.

define temp-table Temp-b no-undo  /* для подсчета сумм по группе или произв-лю */
  field grp          as character
  field obj-code     like obj-list.obj-code
  field obj-TYPE     like obj-list.obj-TYPE
  field b-beg-qnty   as decimal
  field b-sale-qnty  as decimal
  field b-end-qnty   as decimal
  field b-end-sum    as decimal
  index PI IS PRIMARY grp obj-code  obj-type
.

define temp-table Temp-i no-undo   /* для подсчета итоговых сумм */
  field obj-code     like obj-list.obj-code
  field obj-type     like obj-list.obj-type
  field i-beg-qnty   as decimal
  field i-sale-qnty  as decimal
  field i-end-qnty   as decimal
  field i-end-sum    as decimal
  index PI IS PRIMARY obj-code  obj-type
.

define temp-table Temp-line no-undo  /* сбор данных по строке - для учета 0 остатков или оборотов */
  field obj-code     like obj-list.obj-code
  field obj-type     like obj-list.obj-type
  field l-end-cost   as decimal
  field l-beg-qnty   as decimal
  field l-sale-qnty  as decimal
  field l-end-qnty   as decimal
  field l-end-sum    as decimal
  index PI is primary obj-code  obj-type
.

/*===================================================================================================================*/
{ rep/repfrm.i def } /* Показать окно информации о текущем процессе */

Run report-execute in this-procedure.

/*-----------------------------------------------------------------------------------------------------------------------------*/
{ rep/f-fdec.i }  /* Функции для форматирования полей для передачи в EXcel         */
{ gbl/dtm.i }     /* Стандартные функции для экранирования неопределенных значений */

PROCEDURE report-execute :

  { rep/repfrm.i on 10 } /* Показать окно информации о текущем процессе */

  run day-begin-fact-order in this-procedure ( input x-date-start, output v-fact-order-start ). /*Поиск нач fact-order*/
  run day-begin-fact-order in this-procedure ( input ( x-date-end + 1 ),   output v-fact-order-end ). /*Поиск посл fact-order*/

  run rep/extitle.p (1) .   /* Печать шапки */

  run prep-file    in this-procedure.   /* заполняем список наименований и артикулов */

  case classify:
    when "no-classify":u    then do:
      run foreach1 in this-procedure.    /* Без классификации */
    end.
    when "prod":u then do:
      Run Foreach2 in this-procedure.    /* По производителю */
    end.
    when "grp-goods":u then do:
      Run Foreach3 in this-procedure.    /* по группам */
    end.
 end case.

 {&CloseExcel}

  { rep/repfrm.i off } /* Показать окно информации о текущем процессе */

 run rep/runexcel.p (string( session:temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt").

END PROCEDURE.


PROCEDURE foreach1 :  /*  Без классификации */

  for each temp-goods  no-lock
    break by temp-goods.full-id
          by temp-goods.prod-type By temp-goods.prod-code by temp-goods.artic
         with FRAME Zapas :

    if last-of(temp-goods.artic) then do:
      n-nm = n-nm + 1.
      { rep/repfrm.i disp n-nm }

      assign
        Ostat       = no
        Oborot      = no
      .

      for each obj-list no-lock :

        { rep/r-zap-p.i {1} } /* тут  все расчеты остатков и расходов */

      end. /* OBJ-LIST */

      /* вывод в Excel */
      Run PrintLine in this-procedure.

    End. /* if last-of artic */
  End. /*for each temp-goods */

  Run PrintItogAll in this-procedure.

END PROCEDURE.

PROCEDURE foreach2 : /* По производителю----------- */
  for each temp-goods  no-lock
     break by temp-goods.cli
           by temp-goods.full-id
           by temp-goods.artic
         with FRAME Zapas :

    if first-of(temp-goods.cli) then do:
      assign
        var-client = temp-goods.cli
      .
      {&PutExcel} var-client {&new-line} .
    End.

    if last-of(temp-goods.artic) then do:
      n-nm = n-nm + 1.
      { rep/repfrm.i disp n-nm }

      assign
        Ostat       = no
        Oborot      = no
      .

      for each obj-list no-lock :

        { rep/r-zap-p.i {1} } /* тут  все расчеты остатков и расходов */

        /* сумма по группе или произв-лю */
        find first Temp-b share-lock
          where Temp-b.obj-code  = obj-list.obj-code
            and Temp-b.obj-type  = obj-list.obj-type  no-error .
        if not avail Temp-b Then  create Temp-b no-error .

        assign
          Temp-b.grp          = STRING(temp-goods.cli)
          Temp-b.obj-code     = obj-list.obj-code
          Temp-b.obj-type     = obj-list.obj-type
          Temp-b.b-beg-qnty   = Temp-b.b-beg-qnty   + f-beg-qnty
          Temp-b.b-sale-qnty  = Temp-b.b-sale-qnty  + f-sale-qnty
          Temp-b.b-end-qnty   = Temp-b.b-end-qnty   + f-end-qnty
          Temp-b.b-end-sum    = Temp-b.b-end-sum    + f-end-sum
        .

      end. /* OBJ-LIST */

      /* вывод в Excel */
      Run PrintLine in this-procedure.

    End. /* if last-of artic */

    if last-of(temp-goods.cli)  then do :
      {&PutExcel}
        "Итого"                 {&tabulation}
        "по произв. "
        var-client              {&tabulation}
      .
      for each obj-list no-lock :
        find first Temp-b no-lock
             where Temp-b.obj-code  = obj-list.obj-code
               and Temp-b.obj-type  = obj-list.obj-type
               and Temp-b.grp = STRING(temp-goods.cli) no-error .
        if avail  Temp-b then do:
          {&PutExcel}                          {&tabulation}
            excel-qnty ( Temp-b.b-beg-qnty  )  {&tabulation}
            excel-qnty ( Temp-b.b-sale-qnty )  {&tabulation}
            excel-qnty ( Temp-b.b-end-qnty  )  {&tabulation}
            excel-sum  ( Temp-b.b-end-sum   )  {&tabulation}
          .
        end.
        else do:
          {&PutExcel}  {&tabulation}
            0          {&tabulation}
            0          {&tabulation}
            0          {&tabulation}
            0          {&tabulation}
          .
        end.

        find current  Temp-b share-lock.
          assign
            Temp-b.b-beg-qnty  = 0
            Temp-b.b-sale-qnty = 0
            Temp-b.b-end-qnty  = 0
            Temp-b.b-end-sum   = 0
          .
          find current  Temp-b no-lock.

      End.

      {&PutExcel} {&new-line} .

    End.  /*if last temp-goods.cli */

  End. /*for each temp-goods */

  Run PrintItogAll in this-procedure.

END PROCEDURE.

PROCEDURE foreach3 :      /* по группе */
  for each temp-goods  no-lock
    break by temp-goods.grp-name
          by temp-goods.full-id
          by temp-goods.artic
    with FRAME Zapas :

    if first-of(temp-goods.grp-name) then do:
      assign
        var-client = temp-goods.grp-name
      .
      {&PutExcel} var-client {&new-line} .
    End.

    if last-of(temp-goods.artic) then do:
      n-nm = n-nm + 1.
      { rep/repfrm.i disp n-nm }

      assign
        Ostat       = no
        Oborot      = no
      .

      for each obj-list no-lock :

        { rep/r-zap-p.i {1} } /* тут  все расчеты остатков и расходов */

        /* сумма по группе или произв-лю */
        find first Temp-b share-lock
          where Temp-b.obj-code  = obj-list.obj-code
            and Temp-b.obj-type  = obj-list.obj-type  no-error .
        if not avail Temp-b Then  create Temp-b no-error .

        assign
          Temp-b.grp          = STRING(temp-goods.grp-name)
          Temp-b.obj-code     = obj-list.obj-code
          Temp-b.obj-type     = obj-list.obj-type
          Temp-b.b-beg-qnty   = Temp-b.b-beg-qnty   + f-beg-qnty
          Temp-b.b-sale-qnty  = Temp-b.b-sale-qnty  + f-sale-qnty
          Temp-b.b-end-qnty   = Temp-b.b-end-qnty   + f-end-qnty
          Temp-b.b-end-sum    = Temp-b.b-end-sum    + f-end-sum
        .

      end. /* OBJ-LIST */

      /* вывод в Excel */
      Run PrintLine in this-procedure.

    End. /* if last-of artic */

    if last-of(temp-goods.grp-name)  then do :
      {&PutExcel}
        "Итого"                 {&tabulation}
        "по группе "
        var-client              {&tabulation}
      .
      for each obj-list no-lock :
        find first Temp-b no-lock
             where Temp-b.obj-code  = obj-list.obj-code
               and Temp-b.obj-type  = obj-list.obj-type
               and Temp-b.grp = STRING(temp-goods.grp-name) no-error .
        if avail  Temp-b then do:
          {&PutExcel}                          {&tabulation}
            excel-qnty ( Temp-b.b-beg-qnty  )  {&tabulation}
            excel-qnty ( Temp-b.b-sale-qnty )  {&tabulation}
            excel-qnty ( Temp-b.b-end-qnty  )  {&tabulation}
            excel-sum  ( Temp-b.b-end-sum   )  {&tabulation}
          .
        end.
        else do:
          {&PutExcel}  {&tabulation}
            0          {&tabulation}
            0          {&tabulation}
            0          {&tabulation}
            0          {&tabulation}
          .
        end.

        find current  Temp-b share-lock.
          assign
            Temp-b.b-beg-qnty  = 0
            Temp-b.b-sale-qnty = 0
            Temp-b.b-end-qnty  = 0
            Temp-b.b-end-sum   = 0
          .
          find current  Temp-b no-lock.

      End.

      {&PutExcel} {&new-line} .

    End.  /*if last temp-goods.cli */

  End. /*for each temp-goods */

  Run PrintItogAll in this-procedure.

END PROCEDURE.


PROCEDURE PrintLine : /* вывод строки */

  if ShowZero1 = yes or Ostat = yes or Oborot = yes
  then do:
    if ShowZero2 = yes or Oborot = yes
    then do:
      {&PutExcel}
        format-excel-text(temp-goods.artic)    {&tabulation}
        temp-goods.gds-name                    {&tabulation}
      .
      for each obj-list no-lock :
        find first Temp-line no-lock
             where Temp-line.obj-code  = obj-list.obj-code
               and Temp-line.obj-type  = obj-list.obj-type   no-error .
          {&PutExcel}
            excel-sum  ( Temp-line.l-end-cost )  {&tabulation}
            excel-qnty ( Temp-line.l-beg-qnty )  {&tabulation}
            excel-qnty ( Temp-line.l-sale-qnty ) {&tabulation}
            excel-qnty ( Temp-line.l-end-qnty )  {&tabulation}
            excel-sum  ( Temp-line.l-end-sum )   {&tabulation}
          .
        End.
        {&PutExcel}  {&new-line} .
    End.
  End.
END PROCEDURE.


PROCEDURE PrintItogAll : /* вывод итоговых сумм */

  {&PutExcel}
    "ИТОГО"                            {&tabulation}
    "по объектам"                      {&tabulation}
  .

  for each obj-list no-lock :
    find first Temp-i no-lock
         where Temp-i.obj-code  = obj-list.obj-code
           and Temp-i.obj-type  = obj-list.obj-type   no-error .
    if available Temp-i then do:
      {&PutExcel}                         {&tabulation}
       excel-qnty ( Temp-i.i-beg-qnty  )  {&tabulation}
       excel-qnty ( Temp-i.i-sale-qnty )  {&tabulation}
       excel-qnty ( Temp-i.i-end-qnty  )  {&tabulation}
       excel-sum  ( Temp-i.i-end-sum   )  {&tabulation}
      .
    end.
    else do:
      {&PutExcel}  {&tabulation}
        0          {&tabulation}
        0          {&tabulation}
        0          {&tabulation}
        0          {&tabulation}
      .
    end.
  End.

  {&PutExcel} {&new-line} .

END PROCEDURE.


PROCEDURE prep-file : /* заполняем список наименований и артикулов */
  for each obj-list no-lock :
    for each buf_gds-obj
       where buf_gds-obj.obj-code  = obj-list.obj-code
         and buf_gds-obj.obj-type  = obj-list.obj-type
/*         and buf_gds-obj.last-doc <> ?*/
/*         and buf_gds-obj.last-doc  <= x-date-end*/
     /*( buf_gds-obj.last-doc <> 0 or buf_gds-obj.avrg-qnty <> 0 ) */
      no-lock

      &if '{2}' = 'gds-list'  &then
        , first gds-list where  buf_gds-obj.prod-type = gds-list.prod-type and
                                buf_gds-obj.prod-code = gds-list.prod-code and
                                buf_gds-obj.artic     = gds-list.artic no-lock
      &Endif

      :
        if buf_gds-obj.last-doc = ? then next .
        if buf_gds-obj.first-doc > x-date-end then next .


        find first buf_goods
             where buf_goods.gds-code = buf_gds-obj.gds-code no-lock no-error .
        find first buf_clients
             where buf_clients.obj-code = buf_gds-obj.prod-code
               and buf_clients.obj-type = buf_gds-obj.prod-type no-lock no-error .
        if avail buf_goods and
           avail buf_clients and
           not can-find (temp-goods where temp-goods.gds-code = buf_gds-obj.gds-code no-lock )
        then do:
          create temp-goods.
          assign
            temp-goods.gds-code  = buf_goods.gds-code
            temp-goods.artic     = buf_goods.artic
            temp-goods.cli       = buf_clients.obj-name
            temp-goods.grp-name  = buf_goods.grp-name
            temp-goods.prod-code = buf_goods.prod-code
            temp-goods.prod-type = buf_goods.prod-type
            temp-goods.prt-root  = buf_goods.prt-root
            temp-goods.gds-name  = buf_goods.gds-name
            temp-goods.full-id   = buf_goods.artic + buf_goods.prod-type + string ( buf_goods.prod-code )
          .
        End.
     End.
  End.

END PROCEDURE.


/* $Workfile$ e n d */