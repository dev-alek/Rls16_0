/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Реестр документов

Автор: Демин Алексей Сергеевич
Дата создания: 11/27/08
Author: Alexey Demin
Creation date: 11/27/08

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

define temp-table tt-goods no-undo like ub.goods.
define variable v-gds-counter            as integer   no-undo .

/* ==================================================================================================================== */
procedure create-tt-goods :

  define buffer buf_goods   for ub.goods.
  define buffer buf_cli-gds for ub.cli-gds.
  define buffer buf_tax-rate-gds for tax-rate-gds.

  define variable v-curr-grp-name as character            no-undo .
  define variable v-host-code     like clients.host-code  no-undo .

do
on error undo, return error return-value
:
  empty temp-table tt-goods.
  case x-SelectGood :
    /* все товары */
   /* when {&g-all} then do:
      for each buf_goods no-lock
        where buf_goods.stts = 0
      :
        create tt-goods.
        buffer-copy buf_goods to tt-goods.
        assign
          v-gds-counter = v-gds-counter + 1
        .
      end.
    end.  */
    when {&g-grp} then do: /* товары по группам  */
      for each tmp#grp no-lock
      :
        run grplib-get-full-name in this-procedure( input tmp#grp.node-code, output v-curr-grp-name ) .
        for each buf_goods no-lock
              where buf_goods.grp-name begins v-curr-grp-name
        :
          find first tt-goods no-lock
            where tt-goods.artic     = buf_goods.artic
              and tt-goods.prod-type = buf_goods.prod-type
              and tt-goods.prod-code = buf_goods.prod-code
            no-error .
          if not available tt-goods then do:
            create tt-goods.
            buffer-copy buf_goods to tt-goods.
            assign
              v-gds-counter = v-gds-counter + 1
            .
          end.
        end.
      end.
    end.
    when {&g-prod} then do: /* товары по производителю */
      for each buf_goods no-lock
        where buf_goods.stts = 0 ,
          each buf_cli-gds no-lock
            where buf_cli-gds.prod-type = buf_goods.prod-type
              and buf_cli-gds.prod-code = buf_goods.prod-code
              and buf_cli-gds.artic     = buf_goods.artic ,
          first g#cli
            where g#cli.obj-type = buf_cli-gds.cli-type
              and g#cli.obj-code = buf_cli-gds.cli-code
      :
        find first tt-goods no-lock
          where tt-goods.prod-type = buf_goods.prod-type
            and tt-goods.prod-code = buf_goods.prod-code
            and tt-goods.artic     = buf_goods.artic
        no-error.
        if not available tt-goods then do:
          create tt-goods.
          buffer-copy buf_goods to tt-goods no-error.
          assign
            v-gds-counter = v-gds-counter + 1
          .
        end.
      end.
    end.
    when {&g-choice} or when {&g-one} then do: /* товары выборочно */
      for each gds-list :
        find first buf_goods no-lock
          where buf_goods.gds-code = gds-list.gds-code
        no-error .
        if available buf_goods then do:
          create tt-goods.
          buffer-copy buf_goods to tt-goods.
          assign
            v-gds-counter = v-gds-counter + 1
          .
        end.
      end.
    end.
    when {&g-grp-prod} then do: /* группа и производитель */
      for each tmp#grp no-lock
      :
        run grplib-get-full-name in this-procedure( input tmp#grp.node-code, output v-curr-grp-name ) .
        for each buf_goods no-lock
              where buf_goods.grp-name begins v-curr-grp-name
        :
          find first tt-goods no-lock
            where tt-goods.artic     = buf_goods.artic
              and tt-goods.prod-type = buf_goods.prod-type
              and tt-goods.prod-code = buf_goods.prod-code
            no-error .
          if not available tt-goods then do:
            create tt-goods.
            buffer-copy buf_goods to tt-goods no-error.
            assign
              v-gds-counter = v-gds-counter + 1
            .
          end.
        end.
      end.
      for each buf_goods no-lock
        where buf_goods.stts = 0 ,
          each buf_cli-gds no-lock
            where buf_cli-gds.prod-type = buf_goods.prod-type
              and buf_cli-gds.prod-code = buf_goods.prod-code
              and buf_cli-gds.artic     = buf_goods.artic ,
          first g#cli
            where g#cli.obj-type = buf_cli-gds.cli-type
              and g#cli.obj-code = buf_cli-gds.cli-code
      :
        find first tt-goods no-lock
          where tt-goods.prod-type = buf_goods.prod-type
            and tt-goods.prod-code = buf_goods.prod-code
            and tt-goods.artic     = buf_goods.artic
        no-error.
        if not available tt-goods then do:
          create tt-goods.
          buffer-copy buf_goods to tt-goods no-error.
          assign
            v-gds-counter = v-gds-counter + 1
          .
        end.
      end.
    end.
  end case.
  for each tt-goods no-lock
  :
  message
   "X" tt-goods.gds-code
   skip
  view-as alert-box information.
  end.
 /* run waitfram-hide in this-procedure . */
end.
end procedure. /* create-tt-goods */
/*==========================================================================*/
procedure creat-favour :  /*по услугам*/
 define buffer buf_goods   for ub.goods.
  define buffer buf_cli-gds for ub.cli-gds.
  define buffer buf_tax-rate-gds for tax-rate-gds.

  define variable v-curr-grp-name as character            no-undo .
  define variable v-host-code     like clients.host-code  no-undo .

do
on error undo, return error return-value
:
  empty temp-table tt-goods.
  case x-SelectGood :
    when {&g-grp} then do: /* товары по группам  */
      for each tmp#grp no-lock
      :
        run grplib-get-full-name in this-procedure( input tmp#grp.node-code, output v-curr-grp-name ) .
        for each buf_goods no-lock
        where buf_goods.grp-name begins v-curr-grp-name
        and   buf_goods.gds-type = {&gds-office}

        :
          find first tt-goods no-lock
            where tt-goods.artic     = buf_goods.artic
              and tt-goods.prod-type = buf_goods.prod-type
              and tt-goods.prod-code = buf_goods.prod-code
            no-error .
          if not available tt-goods then do:
            create tt-goods.
            buffer-copy buf_goods to tt-goods.
            assign
              v-gds-counter = v-gds-counter + 1
            .
          end.
        end.
      end.
    end.
    when {&g-prod} then do: /* товары по производителю */
      for each buf_goods no-lock
        where buf_goods.stts = 0
        and   buf_goods.gds-type = {&gds-office},
          each buf_cli-gds no-lock
            where buf_cli-gds.prod-type = buf_goods.prod-type
              and buf_cli-gds.prod-code = buf_goods.prod-code
              and buf_cli-gds.artic     = buf_goods.artic ,
          first g#cli
            where g#cli.obj-type = buf_cli-gds.cli-type
              and g#cli.obj-code = buf_cli-gds.cli-code
      :
        find first tt-goods no-lock
          where tt-goods.prod-type = buf_goods.prod-type
            and tt-goods.prod-code = buf_goods.prod-code
            and tt-goods.artic     = buf_goods.artic
        no-error.
        if not available tt-goods then do:
          create tt-goods.
          buffer-copy buf_goods to tt-goods no-error.
          assign
            v-gds-counter = v-gds-counter + 1
          .
        end.
      end.
    end.
    when {&g-choice} or when {&g-one} then do: /* товары выборочно */
      for each gds-list :
        find first buf_goods no-lock
          where buf_goods.gds-code = gds-list.gds-code
          and   buf_goods.gds-type = {&gds-office}
        no-error .
        if available buf_goods then do:
          create tt-goods.
          buffer-copy buf_goods to tt-goods.
          assign
            v-gds-counter = v-gds-counter + 1
          .
        end.
      end.
    end.
    when {&g-grp-prod} then do: /* группа и производитель */
      for each tmp#grp no-lock
      :
        run grplib-get-full-name in this-procedure( input tmp#grp.node-code, output v-curr-grp-name ) .
        for each buf_goods no-lock
        where    buf_goods.grp-name begins v-curr-grp-name
        and      buf_goods.gds-type = {&gds-office}
        :
          find first tt-goods no-lock
            where tt-goods.artic     = buf_goods.artic
              and tt-goods.prod-type = buf_goods.prod-type
              and tt-goods.prod-code = buf_goods.prod-code
            no-error .
          if not available tt-goods then do:
            create tt-goods.
            buffer-copy buf_goods to tt-goods no-error.
            assign
              v-gds-counter = v-gds-counter + 1
            .
          end.
        end.
      end.
      for each buf_goods no-lock
        where buf_goods.stts = 0
        and   buf_goods.gds-type = {&gds-office},
          each buf_cli-gds no-lock
            where buf_cli-gds.prod-type = buf_goods.prod-type
              and buf_cli-gds.prod-code = buf_goods.prod-code
              and buf_cli-gds.artic     = buf_goods.artic ,
          first g#cli
            where g#cli.obj-type = buf_cli-gds.cli-type
              and g#cli.obj-code = buf_cli-gds.cli-code
      :
        find first tt-goods no-lock
          where tt-goods.prod-type = buf_goods.prod-type
            and tt-goods.prod-code = buf_goods.prod-code
            and tt-goods.artic     = buf_goods.artic
        no-error.
        if not available tt-goods then do:
          create tt-goods.
          buffer-copy buf_goods to tt-goods no-error.
          assign
            v-gds-counter = v-gds-counter + 1
          .
        end.
      end.
    end.
  end case.
    for each tt-goods no-lock

    :
  message
   "услугиииX" tt-goods.gds-code
   skip
  view-as alert-box information.
  end.

 /* run waitfram-hide in this-procedure . */
end.
end procedure. /* favour */


/* $Workfile$ e n d */