block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00217000.p $
$Archive: cut/00217000.p $

Файл пирога обрезания. Относится к категории 217/

Обработка таблиц:

arh-wth-cli
arh-wth-cli-attr
arh-wth-cli-doc
arh-wth-cli-doc-attr
arh-wth-cli-tot
arh-wth-cli-tot-attr
arh-wth-tot
arh-wth-tot-attr
arh-wth-w-p
arh-wth-w-p-attr


Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/07/09
Author: Bakhtadze Natalya
Creation date: 09/07/09

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00217000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00217000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 217.".
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ trg/factord.i  }

define buffer old-arh-wth-cli              for src.arh-wth-cli.
define buffer bf_arh-wth-cli               for src.arh-wth-cli.
define buffer new-arh-wth-cli              for dst.arh-wth-cli.
define buffer old-arh-wth-cli-attr         for src.arh-wth-cli-attr.
define buffer new-arh-wth-cli-attr         for dst.arh-wth-cli-attr.
define buffer old-arh-wth-cli-doc          for src.arh-wth-cli-doc.
define buffer bf_arh-wth-cli-doc           for src.arh-wth-cli-doc.
define buffer new-arh-wth-cli-doc          for dst.arh-wth-cli-doc.
define buffer old-arh-wth-cli-doc-attr     for src.arh-wth-cli-doc-attr.
define buffer new-arh-wth-cli-doc-attr     for dst.arh-wth-cli-doc-attr.
define buffer old-arh-wth-cli-tot          for src.arh-wth-cli-tot.
define buffer bf_arh-wth-cli-tot           for src.arh-wth-cli-tot.
define buffer new-arh-wth-cli-tot          for dst.arh-wth-cli-tot.
define buffer old-arh-wth-cli-tot-attr     for src.arh-wth-cli-tot-attr.
define buffer new-arh-wth-cli-tot-attr     for dst.arh-wth-cli-tot-attr.
define buffer old-arh-wth-tot              for src.arh-wth-tot.
define buffer bf_arh-wth-tot               for src.arh-wth-tot.
define buffer new-arh-wth-tot              for dst.arh-wth-tot.
define buffer old-arh-wth-tot-attr         for src.arh-wth-tot-attr.
define buffer new-arh-wth-tot-attr         for dst.arh-wth-tot-attr.
define buffer old-arh-wth-w-p              for src.arh-wth-w-p.
define buffer bf_arh-wth-w-p               for src.arh-wth-w-p.
define buffer new-arh-wth-w-p              for dst.arh-wth-w-p.
define buffer old-arh-wth-w-p-attr         for src.arh-wth-w-p-attr.
define buffer new-arh-wth-w-p-attr         for dst.arh-wth-w-p-attr.





define variable var-fact-order-docs as decimal no-undo.
on WRITE of dst.arh-wth-cli               override do: end.
on WRITE of dst.arh-wth-cli-attr          override do: end.
on WRITE of dst.arh-wth-cli-doc           override do: end.
on WRITE of dst.arh-wth-cli-doc-attr      override do: end.
on WRITE of dst.arh-wth-cli-tot           override do: end.
on WRITE of dst.arh-wth-cli-tot-attr      override do: end.
on WRITE of dst.arh-wth-tot               override do: end.
on WRITE of dst.arh-wth-tot-attr          override do: end.
on WRITE of dst.arh-wth-w-p               override do: end.
on WRITE of dst.arh-wth-w-p-attr          override do: end.


do
on error undo, return error return-value
:
  { utl/00000001.i }
run factord-end-day in this-procedure ( vardate-actual-docs - 1, output var-fact-order-docs).

&scop remove-table ~
  for each old-~{&arh-table-name~} no-lock on error undo, return error return-value : ~
    if old-~{&arh-table-name~}.fact-order > var-fact-order-docs then do:            ~
      create new-~{&arh-table-name~}.                                                 ~
      buffer-copy old-~{&arh-table-name~} to new-~{&arh-table-name~}.                 ~
    end.                                                                              ~
    else do:                                                                          ~
      find first bf_~{&arh-table-name~} where ~{&find-where~} no-error.               ~
      if not available bf_~{&arh-table-name~} then do:                                ~
        create new-~{&arh-table-name~}.                                               ~
        buffer-copy old-~{&arh-table-name~} to new-~{&arh-table-name~}.               ~
      end.                                                                            ~
    end.                                                                              ~
  end.
  &scop arh-table-name arh-wth-cli
  &scop find-where     bf_~{&arh-table-name~}.cli-type          = old-~{&arh-table-name~}.cli-type                and ~
                       bf_~{&arh-table-name~}.cli-code          = old-~{&arh-table-name~}.cli-code                and ~
                       bf_~{&arh-table-name~}.ext-doc-type      = old-~{&arh-table-name~}.ext-doc-type            and ~
                       bf_~{&arh-table-name~}.wth-code          = old-~{&arh-table-name~}.wth-code                and ~
                       bf_~{&arh-table-name~}.par-code          = old-~{&arh-table-name~}.par-code                and ~
                       bf_~{&arh-table-name~}.ser-code          = old-~{&arh-table-name~}.ser-code                and ~
                       bf_~{&arh-table-name~}.db-num            = old-~{&arh-table-name~}.db-num                  and ~
                       bf_~{&arh-table-name~}.gds-code          = old-~{&arh-table-name~}.gds-code                and ~
                       bf_~{&arh-table-name~}.obj-type          = old-~{&arh-table-name~}.obj-type                and ~
                       bf_~{&arh-table-name~}.obj-code          = old-~{&arh-table-name~}.obj-code                and ~
                       bf_~{&arh-table-name~}.sum-type          = old-~{&arh-table-name~}.sum-type                and ~
                       bf_~{&arh-table-name~}.fact-order        > old-~{&arh-table-name~}.fact-order              and ~
                       bf_~{&arh-table-name~}.fact-order       <= var-fact-order-docs
  {&remove-table}

  { utl/00000002.i arh-wth-cli-attr    "  no-lock , first new-arh-wth-cli where ~
  new-arh-wth-cli.cli-type          = old-arh-wth-cli-attr.cli-type                and ~
  new-arh-wth-cli.cli-code          = old-arh-wth-cli-attr.cli-code                and ~
  new-arh-wth-cli.ext-doc-type      = old-arh-wth-cli-attr.ext-doc-type            and ~
  new-arh-wth-cli.wth-code          = old-arh-wth-cli-attr.wth-code                and ~
  new-arh-wth-cli.par-code          = old-arh-wth-cli-attr.par-code                and ~
  new-arh-wth-cli.ser-code          = old-arh-wth-cli-attr.ser-code                and ~
  new-arh-wth-cli.db-num            = old-arh-wth-cli-attr.db-num                  and ~
  new-arh-wth-cli.gds-code          = old-arh-wth-cli-attr.gds-code                and ~
  new-arh-wth-cli.obj-type          = old-arh-wth-cli-attr.obj-type                and ~
  new-arh-wth-cli.obj-code          = old-arh-wth-cli-attr.obj-code                and ~
  new-arh-wth-cli.sum-type          = old-arh-wth-cli-attr.sum-type                and ~
  new-arh-wth-cli.fact-order        = old-arh-wth-cli-attr.fact-order         " }

  &scop arh-table-name arh-wth-cli-doc
  &scop find-where     bf_~{&arh-table-name~}.cli-type          = old-~{&arh-table-name~}.cli-type                and ~
                       bf_~{&arh-table-name~}.cli-code          = old-~{&arh-table-name~}.cli-code                and ~
                       bf_~{&arh-table-name~}.wth-code          = old-~{&arh-table-name~}.wth-code                and ~
                       bf_~{&arh-table-name~}.par-code          = old-~{&arh-table-name~}.par-code                and ~
                       bf_~{&arh-table-name~}.host-code         = old-~{&arh-table-name~}.host-code               and ~
                       bf_~{&arh-table-name~}.contract-code     = old-~{&arh-table-name~}.contract-code           and ~
                       bf_~{&arh-table-name~}.gds-code          = old-~{&arh-table-name~}.gds-code                and ~
                       bf_~{&arh-table-name~}.obj-type          = old-~{&arh-table-name~}.obj-type                and ~
                       bf_~{&arh-table-name~}.obj-code          = old-~{&arh-table-name~}.obj-code                and ~
                       bf_~{&arh-table-name~}.w-p-code          = old-~{&arh-table-name~}.w-p-code                and ~
                       bf_~{&arh-table-name~}.ext-doc-type      = old-~{&arh-table-name~}.ext-doc-type            and ~
                       bf_~{&arh-table-name~}.sum-type          = old-~{&arh-table-name~}.sum-type                and ~
                       bf_~{&arh-table-name~}.fact-order        > old-~{&arh-table-name~}.fact-order              and ~
                       bf_~{&arh-table-name~}.fact-order       <= var-fact-order-docs
  {&remove-table}




  { utl/00000002.i arh-wth-cli-doc-attr    "  no-lock , first new-arh-wth-cli-doc where ~
  new-arh-wth-cli-doc.cli-type          = old-arh-wth-cli-doc-attr.cli-type                and ~
  new-arh-wth-cli-doc.cli-code          = old-arh-wth-cli-doc-attr.cli-code                and ~
  new-arh-wth-cli-doc.wth-code          = old-arh-wth-cli-doc-attr.wth-code                and ~
  new-arh-wth-cli-doc.par-code          = old-arh-wth-cli-doc-attr.par-code                and ~
  new-arh-wth-cli-doc.host-code         = old-arh-wth-cli-doc-attr.host-code               and ~
  new-arh-wth-cli-doc.contract-code     = old-arh-wth-cli-doc-attr.contract-code           and ~
  new-arh-wth-cli-doc.gds-code          = old-arh-wth-cli-doc-attr.gds-code                and ~
  new-arh-wth-cli-doc.obj-type          = old-arh-wth-cli-doc-attr.obj-type                and ~
  new-arh-wth-cli-doc.obj-code          = old-arh-wth-cli-doc-attr.obj-code                and ~
  new-arh-wth-cli-doc.w-p-code          = old-arh-wth-cli-doc-attr.w-p-code                and ~
  new-arh-wth-cli-doc.ext-doc-type      = old-arh-wth-cli-doc-attr.ext-doc-type            and ~
  new-arh-wth-cli-doc.sum-type          = old-arh-wth-cli-doc-attr.sum-type                and ~
  new-arh-wth-cli-doc.fact-order        = old-arh-wth-cli-doc-attr.fact-order         " }




  &scop arh-table-name arh-wth-cli-tot
  &scop find-where     bf_~{&arh-table-name~}.cli-type          = old-~{&arh-table-name~}.cli-type                and ~
                       bf_~{&arh-table-name~}.cli-code          = old-~{&arh-table-name~}.cli-code                and ~
                       bf_~{&arh-table-name~}.obj-type          = old-~{&arh-table-name~}.obj-type                and ~
                       bf_~{&arh-table-name~}.obj-code          = old-~{&arh-table-name~}.obj-code                and ~
                       bf_~{&arh-table-name~}.ext-doc-type      = old-~{&arh-table-name~}.ext-doc-type            and ~
                       bf_~{&arh-table-name~}.sum-type          = old-~{&arh-table-name~}.sum-type                and ~
                       bf_~{&arh-table-name~}.fact-order        > old-~{&arh-table-name~}.fact-order              and ~
                       bf_~{&arh-table-name~}.fact-order       <= var-fact-order-docs
  {&remove-table}


  { utl/00000002.i arh-wth-cli-tot-attr    "  no-lock , first new-arh-wth-cli-tot where ~
  new-arh-wth-cli-tot.cli-type          = old-arh-wth-cli-tot-attr.cli-type                and ~
  new-arh-wth-cli-tot.cli-code          = old-arh-wth-cli-tot-attr.cli-code                and ~
  new-arh-wth-cli-tot.obj-type          = old-arh-wth-cli-tot-attr.obj-type                and ~
  new-arh-wth-cli-tot.obj-code          = old-arh-wth-cli-tot-attr.obj-code                and ~
  new-arh-wth-cli-tot.ext-doc-type      = old-arh-wth-cli-tot-attr.ext-doc-type            and ~
  new-arh-wth-cli-tot.sum-type          = old-arh-wth-cli-tot-attr.sum-type                and ~
  new-arh-wth-cli-tot.fact-order        = old-arh-wth-cli-tot-attr.fact-order         " }


  &scop arh-table-name arh-wth-tot
  &scop find-where     bf_~{&arh-table-name~}.obj-type          = old-~{&arh-table-name~}.obj-type                and ~
                       bf_~{&arh-table-name~}.obj-code          = old-~{&arh-table-name~}.obj-code                and ~
                       bf_~{&arh-table-name~}.wth-code          = old-~{&arh-table-name~}.wth-code                and ~
                       bf_~{&arh-table-name~}.par-code          = old-~{&arh-table-name~}.par-code                and ~
                       bf_~{&arh-table-name~}.ext-doc-type      = old-~{&arh-table-name~}.ext-doc-type            and ~
                       bf_~{&arh-table-name~}.sum-type          = old-~{&arh-table-name~}.sum-type                and ~
                       bf_~{&arh-table-name~}.fact-order        > old-~{&arh-table-name~}.fact-order              and ~
                       bf_~{&arh-table-name~}.fact-order       <= var-fact-order-docs
  {&remove-table}


  { utl/00000002.i arh-wth-tot-attr    "  no-lock , first new-arh-wth-tot where ~
  new-arh-wth-tot.obj-type          = old-arh-wth-tot-attr.obj-type                and ~
  new-arh-wth-tot.obj-code          = old-arh-wth-tot-attr.obj-code                and ~
  new-arh-wth-tot.wth-code          = old-arh-wth-tot-attr.wth-code                and ~
  new-arh-wth-tot.par-code          = old-arh-wth-tot-attr.par-code                and ~
  new-arh-wth-tot.ext-doc-type      = old-arh-wth-tot-attr.ext-doc-type            and ~
  new-arh-wth-tot.sum-type          = old-arh-wth-tot-attr.sum-type                and ~
  new-arh-wth-tot.fact-order        = old-arh-wth-tot-attr.fact-order         " }


  &scop arh-table-name arh-wth-w-p
  &scop find-where     bf_~{&arh-table-name~}.obj-type          = old-~{&arh-table-name~}.obj-type                and ~
                       bf_~{&arh-table-name~}.obj-code          = old-~{&arh-table-name~}.obj-code                and ~
                       bf_~{&arh-table-name~}.w-p-code          = old-~{&arh-table-name~}.w-p-code                and ~
                       bf_~{&arh-table-name~}.wth-code          = old-~{&arh-table-name~}.wth-code                and ~
                       bf_~{&arh-table-name~}.par-code          = old-~{&arh-table-name~}.par-code                and ~
                       bf_~{&arh-table-name~}.out-code          = old-~{&arh-table-name~}.out-code                and ~
                       bf_~{&arh-table-name~}.sum-type          = old-~{&arh-table-name~}.sum-type                and ~
                       bf_~{&arh-table-name~}.fact-order        > old-~{&arh-table-name~}.fact-order              and ~
                       bf_~{&arh-table-name~}.fact-order       <= var-fact-order-docs
  {&remove-table}



  { utl/00000002.i arh-wth-w-p-attr    "  no-lock , first new-arh-wth-w-p where ~
  new-arh-wth-w-p.obj-type          = old-arh-wth-w-p-attr.obj-type                and ~
  new-arh-wth-w-p.obj-code          = old-arh-wth-w-p-attr.obj-code                and ~
  new-arh-wth-w-p.w-p-code          = old-arh-wth-w-p-attr.w-p-code                and ~
  new-arh-wth-w-p.wth-code          = old-arh-wth-w-p-attr.wth-code                and ~
  new-arh-wth-w-p.par-code          = old-arh-wth-w-p-attr.par-code                and ~
  new-arh-wth-w-p.out-code          = old-arh-wth-w-p-attr.out-code                and ~
  new-arh-wth-w-p.sum-type          = old-arh-wth-w-p-attr.sum-type                and ~
  new-arh-wth-w-p.fact-order        = old-arh-wth-w-p-attr.fact-order         " }

output stream str-gen close.
  return "Произведен экспорт таблиц:  arh-wth-cli arh-wth-cli-attr arh-wth-cli-doc arh-wth-cli-doc-attr arh-wth-cli-tot arh-wth-cli-tot-attr ~
arh-wth-tot arh-wth-tot-attr arh-wth-w-p arh-wth-w-p-attr .".
end.