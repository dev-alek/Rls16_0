/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Simpleproc для журнала продаж

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

if SHRs-sort = "Article":U then do:
  if SHBySalers then do:

      FOR EACH sj-goods NO-LOCK,
          EACH sj-adv NO-LOCK WHERE
                sj-adv.obj-attr = sj-goods.obj-attr AND
                sj-adv.b-code = sj-goods.b-code AND
                sj-adv.saleman = sj-goods.saleman
          BREAK BY sj-goods.obj-attr
                BY sj-goods.saleman
                BY sj-goods.artic
                BY sj-goods.b-code
                BY sj-adv.price
&if "{1}" = "sj-adv.discnt" &then
                BY sj-adv.discnt
&endif
                :
          { rep/e-sjobs.i {2} {3} {4}}
          { rep/e-sjsmp.i sj-goods.artic sj-goods.saleman {1} {2} {3} {4}}
      END .
  end. /*BySalers*/
  else do:
      FOR EACH sj-goods NO-LOCK,
        EACH sj-adv NO-LOCK WHERE
              sj-adv.obj-attr = sj-goods.obj-attr AND
              sj-adv.b-code = sj-goods.b-code AND
              sj-adv.saleman = sj-goods.saleman
        BREAK BY sj-goods.obj-attr
              BY sj-goods.artic
              BY sj-goods.b-code
              BY sj-adv.price
&if "{1}" = "sj-adv.discnt" &then
              BY sj-adv.discnt
&endif
              BY sj-goods.saleman :
        { rep/e-sjobs.i {2} {3} {4}}
        { rep/e-sjsmp.i sj-goods.artic sj-goods.saleman {1} {2} {3} {4}}
    END .
  end. /*not BySalers*/
end. /*Rs-sort = "Article":U*/
else do:
  if SHBySalers then do:
    FOR EACH sj-goods NO-LOCK,
        EACH sj-adv NO-LOCK WHERE
              sj-adv.obj-attr = sj-goods.obj-attr AND
              sj-adv.b-code = sj-goods.b-code AND
              sj-adv.saleman = sj-goods.saleman
        BREAK BY sj-goods.obj-attr
              BY sj-goods.saleman
              BY sj-goods.b-code
              BY sj-adv.price
&if "{1}" = "sj-adv.discnt" &then
              BY sj-adv.discnt
&endif
              :
        { rep/e-sjobs.i {2} {3} {4}}
        { rep/e-sjsmp.i sj-goods.b-code sj-goods.saleman {1} {2} {3} {4}}
    END .
  end. /*if BySalers*/
  else do: /*not BYSalers*/
    FOR EACH sj-goods NO-LOCK,
        EACH sj-adv NO-LOCK WHERE
             sj-adv.obj-attr = sj-goods.obj-attr AND
             sj-adv.b-code = sj-goods.b-code AND
             sj-adv.saleman = sj-goods.saleman
        BREAK BY sj-goods.obj-attr
              BY sj-goods.b-code
              BY sj-adv.price
&if "{1}" = "sj-adv.discnt" &then
              BY sj-adv.discnt
&endif
              BY sj-goods.saleman :
        { rep/e-sjobs.i {2} {3} {4}}
        { rep/e-sjsmp.i sj-goods.b-code sj-goods.saleman {1} {2} {3} {4}}
    END .
  end.
end. /*not Rs-sort = "Article":U*/


/* $Workfile$ e n d */