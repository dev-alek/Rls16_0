/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Поиск товара в справочнике

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

  case g-list :
    when {&all} then do:
      &if "{1}" = "goo-doc" &then
        &scop w-cond true
        { ref/gds-find.i {1} {2} }
      &else
      case g-cond :
        when {&g___object} then do:
          &scop w-cond l-{1}.obj-type = p-obj-type ~
                                 and l-{1}.obj-code = p-obj-code
          { ref/gds-find.i {1} {2} }
        end.
        when {&fact} then do:
          &scop w-cond l-{1}.obj-type    = p-obj-type ~
                                 and l-{1}.obj-code   = p-obj-code ~
                                 and l-{1}.fact-qnty > 0
          { ref/gds-find.i {1} {2} }
        end.
        when {&free} then do:
          &scop w-cond l-{1}.obj-type    = p-obj-type ~
                                 and l-{1}.obj-code   = p-obj-code ~
                                 and l-{1}.free-qnty > 0
          { ref/gds-find.i {1} {2} }
        end.
      end.
      &endif
    end.
    when {&producer} then do:
      &if "{1}" = "goo-doc" &then
        &scop w-cond l-{1}.prod-type = g-producer.obj-type ~
                               and l-{1}.prod-code = g-producer.obj-code
        { ref/gds-find.i {1} {2} }
      &else
      case g-cond :
        when {&g___object} then do:
          &scop w-cond l-{1}.prod-type = g-producer.obj-type ~
                                 and l-{1}.prod-code = g-producer.obj-code ~
                                 and l-{1}.obj-type    = p-obj-type ~
                                 and l-{1}.obj-code   = p-obj-code
          { ref/gds-find.i {1} {2} }
        end.
        when {&fact} then do:
          &scop w-cond l-{1}.prod-type = g-producer.obj-type ~
                                 and l-{1}.prod-code = g-producer.obj-code ~
                                 and l-{1}.obj-type    = p-obj-type ~
                                 and l-{1}.obj-code   = p-obj-code ~
                                 and l-{1}.fact-qnty > 0
          { ref/gds-find.i {1} {2} }
        end.
        when {&free} then do:
          &scop w-cond l-{1}.prod-type = g-producer.obj-type ~
                                 and l-{1}.prod-code = g-producer.obj-code ~
                                 and l-{1}.obj-type    = p-obj-type ~
                                 and l-{1}.obj-code   = p-obj-code ~
                                 and l-{1}.free-qnty > 0
          { ref/gds-find.i {1} {2} }
        end.
      end.
      &endif
    end.
    when {&group} then do:
      &if "{1}" = "goo-doc" &then
        &scop w-cond l-{1}.grp-name begins g-grp
        { ref/gds-find.i {1} {2} }
      &else
      case g-cond :
        when {&g___object} then do:
          &scop w-cond l-{1}.grp-name begins g-grp ~
                                 and l-{1}.obj-type    = p-obj-type ~
                                 and l-{1}.obj-code   = p-obj-code
          { ref/gds-find.i {1} {2} }
        end.
        when {&fact} then do:
          &scop w-cond l-{1}.grp-name begins g-grp ~
                                 and l-{1}.obj-type    = p-obj-type ~
                                 and l-{1}.obj-code   = p-obj-code ~
                                 and l-{1}.fact-qnty > 0
          { ref/gds-find.i {1} {2} }
        end.
        when {&free} then do:
          &scop w-cond l-{1}.grp-name begins g-grp ~
                                 and l-{1}.obj-type    = p-obj-type ~
                                 and l-{1}.obj-code   = p-obj-code ~
                                 and l-{1}.free-qnty > 0
          { ref/gds-find.i {1} {2} }
        end.
      end.
      &endif
    end.
  end.

/* $Workfile$ e n d */