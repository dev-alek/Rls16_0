block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-in-ob.p $
$Archive: rep/r-in-ob.p $



Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 04/14/03 1:49

*/

{ cmp/trg-def.i  }
{ cmp/r-page1.i  }
{ cmp/r-pril.i   }
{ rep/r-sym.i    }
{ rep/r-gl.i  {3} }
{ gbl/cur-time.i  }
&scop e-col     12
&scop l-frame   340
&scop l-frame-1 319
&glob bef-Disc disc
&glob bef-eff  eff
&glob bef-prc  prc
&glob bef-r-v  r-v
&glob bef-sum-cost sum-cost
&glob bef-sum-crsa sum-crsa
&glob bef-sum-sale sum-sale

define stream  OutStream.
define input   parameter       x-base-type                                 like ub.currency.curr-abbr no-undo.
define input   parameter       x-base-code                                 like ub.currency.curr-code no-undo.
define input   parameter       tprintrubl                                  as   log no-undo.
define input-output  parameter c-s-bar-code                                as   widget-handle  no-undo.
define input-output  parameter c-gds-zap-artic                             as   widget-handle  no-undo.
define input-output  parameter c-gds-zap-gds-name                          as   widget-handle  no-undo.
define input-output  parameter c-gds-zap-unit-base                         as   widget-handle  no-undo.
define input-output  parameter c-gds-type                                  as   widget-handle  no-undo.
define input-output  parameter c-ostatok-start                             as   widget-handle  no-undo.
define input-output  parameter c-ostatok-end                               as   widget-handle  no-undo.
define input-output  parameter c-oborot-{&bef-tdedt_pri_vnesh            } as   widget-handle  no-undo.
define input-output  parameter c-oborot-{&bef-tdedt_ras_vnesh            } as   widget-handle  no-undo.
define input-output  parameter c-oborot-{&bef-tdedt_ras_vnesh_vp         } as   widget-handle  no-undo.
define input-output  parameter c-oborot-{&bef-tdedt_ras_vnesh_kass       } as   widget-handle  no-undo.
define input-output  parameter c-oborot-{&bef-tdedt_vozvrat_vnesh        } as   widget-handle  no-undo.
define input-output  parameter c-oborot-{&bef-tdedt_vozvrat_vnesh_kass   } as   widget-handle  no-undo.
define input-output  parameter c-oborot-{&bef-tdedt_spi_vnesh            } as   widget-handle  no-undo.
define input-output  parameter c-oborot-{&bef-tdedt_inv                  } as   widget-handle  no-undo.
define input-output  parameter c-oborot-{&bef-tdedt_pri_perem            } as   widget-handle  no-undo.
define input-output  parameter c-oborot-{&bef-tdedt_ras_perem            } as   widget-handle  no-undo.
define input-output  parameter c-oborot-{&bef-tdedt_vozvrat_perem        } as   widget-handle  no-undo.
define input-output  parameter c-oborot-{&bef-tdedt_ras_prvo             } as   widget-handle  no-undo.
define input-output  parameter c-oborot-{&bef-tdedt_spi_prvo             } as   widget-handle  no-undo.
define input-output  parameter c-oborot-{&bef-tdedt_pri_prvo             } as   widget-handle  no-undo.
define input-output  parameter c-oborot-{&bef-tdedt_overturn             } as   widget-handle  no-undo.
define input-output  parameter c-oborot-{&bef-tdedt_chg_purch_code       } as   widget-handle  no-undo.
define input-output  parameter c-oborot-{&bef-tdedt_corr_acc_price       } as   widget-handle  no-undo.
define input-output  parameter c-oborot-{&bef-disc                       } as   widget-handle  no-undo.
define input-output  parameter c-oborot-{&bef-eff                        } as   widget-handle  no-undo.
define input-output  parameter c-oborot-{&bef-prc                        } as   widget-handle  no-undo.
define input-output  parameter c-oborot-{&bef-r-v                        } as   widget-handle  no-undo.
define input-output  parameter c-str-num                                   as   widget-handle  no-undo.
define input-output  parameter l-col-type                                  as   character no-undo .
define input-output  parameter l-col-pos                                   as   integer no-undo .
define input-output  parameter l-col-len                                   as   integer no-undo .
define input-output  parameter l-col-format                                as   character no-undo .
define input-output  parameter l-col-lable                                 as   character no-undo .



DEFINE shared VARIABLE t-1 AS CHARACTER INITIAL "|||"
     VIEW-AS EDITOR
     SIZE 1 BY 4 NO-UNDO.


DEFINE shared FRAME top-frame
    t-1       AT ROW 1 COL 1 no-label
    HEADER
     cur-time-print() AT 5 format "X(35)"
        "Цены указаны в" (if tPrintRubl then "{&abbr_rub_allshift}" else x-base-type )
        string( "Страница " + string( PAGE-NUMBER( OutStream ), ">>>>>>9") ) AT 110 format "X(16)" SKIP
     WITH {&l-frame} DOWN stream-io
         NO-UNDERLINE use-text NO-BOX no-label
         AT COL 1 ROW 1
         SIZE {&l-frame} BY 35  .


DEFINE shared FRAME zapas
   with width {&l-frame} down stream-io use-text NO-BOX no-label.

{ rep/r-ob1cr.i def 1     s-bar-code                            "shared" }
{ rep/r-ob1cr.i def  2    gds-zap-artic                         "shared"  }
{ rep/r-ob1cr.i def  3    gds-zap-gds-name                      "shared"  }
{ rep/r-ob1cr.i def  4    gds-zap-unit-base                     "shared"  }
{ rep/r-ob1cr.i def  5    gds-type                              "shared"  }
{ rep/r-ob1cr.i def  6    ostatok-start                         "shared"  }
{ rep/r-ob1cr.i def  7    oborot-{&bef-TDEDT_Pri_Vnesh}         "shared"  }
{ rep/r-ob1cr.i def  8    oborot-{&bef-TDEDT_Pri_Perem}         "shared"  }
{ rep/r-ob1cr.i def  9    oborot-{&bef-TDEDT_Pri_Prvo}          "shared" }
{ rep/r-ob1cr.i def  10   oborot-{&bef-TDEDT_Ras_Vnesh}         "shared" }
{ rep/r-ob1cr.i def  11   oborot-{&bef-TDEDT_Ras_Perem}         "shared" }
{ rep/r-ob1cr.i def  12   oborot-{&bef-TDEDT_Ras_Prvo}          "shared" }
{ rep/r-ob1cr.i def  13   oborot-{&bef-TDEDT_Spi_Vnesh}         "shared" }
{ rep/r-ob1cr.i def  14   oborot-{&bef-TDEDT_Ras_Vnesh_Kass}    "shared" }
{ rep/r-ob1cr.i def  15   oborot-{&bef-TDEDT_Vozvrat_Vnesh_Kass} "shared" }
{ rep/r-ob1cr.i def  16   oborot-{&bef-TDEDT_Vozvrat_Vnesh}     "shared" }
{ rep/r-ob1cr.i def  17   oborot-{&bef-TDEDT_RAS_Vnesh_VP}      "shared" }
{ rep/r-ob1cr.i def  18   oborot-{&bef-TDEDT_Vozvrat_Perem}     "shared" }
{ rep/r-ob1cr.i def  19   oborot-{&bef-TDEDT_Inv}               "shared" }
{ rep/r-ob1cr.i def  20   oborot-{&bef-TDEDT_Overturn}          "shared" }
{ rep/r-ob1cr.i def  21   oborot-{&bef-disc}                    "shared" }
{ rep/r-ob1cr.i def  22   ostatok-end                           "shared" }
{ rep/r-ob1cr.i def  23   oborot-{&bef-eff}                     "shared" }
{ rep/r-ob1cr.i def  24   oborot-{&bef-prc}                     "shared" }
{ rep/r-ob1cr.i def  25   oborot-{&bef-TDEDT_Corr_Acc_Price}    "shared" }
{ rep/r-ob1cr.i def  26   oborot-{&bef-TDEDT_Chg_Purch_Code}    "shared" }
{ rep/r-ob1cr.i def  27   oborot-r-v                            "shared"  }
{ rep/r-ob1cr.i def  28   str-num                               "shared"  }

  CREATE WIDGET-POOL "My-pool" PERSISTENT no-error .
  l-col-pos = 1.
  Assign l-col-type="CHARACTER" l-col-len=9  l-col-format="X(9)"        l-col-lable="№ строки"        .                     { rep/r-ob1cr.i cr2 28    str-num                    }
  Assign l-col-type="CHARACTER" l-col-len=9  l-col-format="X(9)"        l-col-lable="Код"             .                     { rep/r-ob1cr.i cr2 1     s-bar-code                 }
  Assign l-col-type="CHARACTER" l-col-len=16 l-col-format= "X(16)"      l-col-lable="Артикул"         .                     { rep/r-ob1cr.i cr2  2    gds-zap-artic              }
  Assign l-col-type="CHARACTER" l-col-len=38 l-col-format= "X(38)"      l-col-lable="Название товара" .                     { rep/r-ob1cr.i cr2  3    gds-zap-gds-name           }
  Assign l-col-type="CHARACTER" l-col-len=3  l-col-format= "X(3)"       l-col-lable="Ед. изм"         .                     { rep/r-ob1cr.i cr2  4    gds-zap-unit-base          }
  Assign l-col-type="CHARACTER" l-col-len=9  l-col-format= "X(9)"       l-col-lable="Тип данных"      .                     { rep/r-ob1cr.i cr2  5    gds-type                   }
  Assign l-col-type="DECIMAL" l-col-len=14 l-col-format="->>>>>>>>>>>9.<<<"  l-col-lable="Остаток на начало"         .  { rep/r-ob1cr.i cr2  6    ostatok-start              }
  Assign l-col-type="DECIMAL" l-col-len=14 l-col-format="->>>>>>>>>>>9.<<<"  l-col-lable="Оборот приход внешний"     .  { rep/r-ob1cr.i cr2  7    oborot-{&bef-TDEDT_Pri_Vnesh} }
  Assign l-col-type="DECIMAL" l-col-len=14 l-col-format="->>>>>>>>>>>9.<<<"  l-col-lable="Оборот приход перемещение" .  { rep/r-ob1cr.i cr2  8    oborot-{&bef-TDEDT_Pri_Perem} }
  Assign l-col-type="DECIMAL" l-col-len=14 l-col-format="->>>>>>>>>>>9.<<<"  l-col-lable="Оборот приход производство".  { rep/r-ob1cr.i cr2  9    oborot-{&bef-TDEDT_Pri_Prvo}  }
  Assign l-col-type="DECIMAL" l-col-len=14 l-col-format="->>>>>>>>>>>9.<<<"  l-col-lable="Оборот расход внешний"     .  { rep/r-ob1cr.i cr2  10   oborot-{&bef-TDEDT_Ras_Vnesh} }
  Assign l-col-type="DECIMAL" l-col-len=14 l-col-format="->>>>>>>>>>>9.<<<"  l-col-lable="Оборот расход перемещение" .  { rep/r-ob1cr.i cr2  11   oborot-{&bef-TDEDT_Ras_Perem} }
  Assign l-col-type="DECIMAL" l-col-len=14 l-col-format="->>>>>>>>>>>9.<<<"  l-col-lable="Оборот расход производство".  { rep/r-ob1cr.i cr2  12   oborot-{&bef-TDEDT_Ras_Prvo}  }
  Assign l-col-type="DECIMAL" l-col-len=14 l-col-format="->>>>>>>>>>>9.<<<"  l-col-lable="Оборот списание"           .  { rep/r-ob1cr.i cr2  13   oborot-{&bef-TDEDT_Spi_Vnesh} }
  Assign l-col-type="DECIMAL" l-col-len=14 l-col-format="->>>>>>>>>>>9.<<<"  l-col-lable="Оборот касса продажа"      .  { rep/r-ob1cr.i cr2  14   oborot-{&bef-TDEDT_Ras_Vnesh_Kass}    }
  Assign l-col-type="DECIMAL" l-col-len=14 l-col-format="->>>>>>>>>>>9.<<<"  l-col-lable="Оборот касса возврат"      .  { rep/r-ob1cr.i cr2  15   oborot-{&bef-TDEDT_Vozvrat_Vnesh_Kass}}
  Assign l-col-type="DECIMAL" l-col-len=14 l-col-format="->>>>>>>>>>>9.<<<"  l-col-lable="Оборот возврат внешний"    .  { rep/r-ob1cr.i cr2  16   oborot-{&bef-TDEDT_Vozvrat_Vnesh}     }
  Assign l-col-type="DECIMAL" l-col-len=14 l-col-format="->>>>>>>>>>>9.<<<"  l-col-lable="Оборот возврат поставщику" .  { rep/r-ob1cr.i cr2  17   oborot-{&bef-TDEDT_RAS_Vnesh_VP}      }
  Assign l-col-type="DECIMAL" l-col-len=14 l-col-format="->>>>>>>>>>>9.<<<"  l-col-lable="Оборот возврат перемещение".  { rep/r-ob1cr.i cr2  18   oborot-{&bef-TDEDT_Vozvrat_Perem}     }
  Assign l-col-type="DECIMAL" l-col-len=14 l-col-format="->>>>>>>>>>>9.<<<"  l-col-lable="Оборот инвентаризация"     .  { rep/r-ob1cr.i cr2  19   oborot-{&bef-TDEDT_Inv}               }
  Assign l-col-type="DECIMAL" l-col-len=14 l-col-format="->>>>>>>>>>>9.<<<"  l-col-lable="Оборот переоценка"         .  { rep/r-ob1cr.i cr2  20   oborot-{&bef-TDEDT_Overturn}          }
  Assign l-col-type="DECIMAL" l-col-len=14 l-col-format="->>>>>>>>>>>9.<<<"  l-col-lable="Скидка в ценах докум."     .  { rep/r-ob1cr.i cr2  21   oborot-{&bef-disc}                    }
  Assign l-col-type="DECIMAL" l-col-len=14 l-col-format="->>>>>>>>>>>9.<<<"  l-col-lable="Остаток на конец"          .  { rep/r-ob1cr.i cr2  22   ostatok-end                           }
  Assign l-col-type="DECIMAL" l-col-len=14 l-col-format="->>>>>>>>>>>9.<<<"  l-col-lable="Эффективность"             .  { rep/r-ob1cr.i cr2  23   oborot-{&bef-eff}                     }
  Assign l-col-type="DECIMAL" l-col-len=14 l-col-format="->>>>>>>>>>>9.<<<"  l-col-lable="% наценки"                 .  { rep/r-ob1cr.i cr2  24   oborot-{&bef-prc}                     }
  Assign l-col-type="DECIMAL" l-col-len=14 l-col-format="->>>>>>>>>>>9.<<<"  l-col-lable={&TDEDT_Corr_Acc_Price-full}.  { rep/r-ob1cr.i cr2  25   oborot-{&bef-TDEDT_Corr_Acc_Price}    }
  Assign l-col-type="DECIMAL" l-col-len=14 l-col-format="->>>>>>>>>>>9.<<<"  l-col-lable={&TDEDT_Chg_Purch_Code-full}.  { rep/r-ob1cr.i cr2  26   oborot-{&bef-TDEDT_Chg_Purch_Code}    }
  Assign l-col-type="DECIMAL" l-col-len=14 l-col-format="->>>>>>>>>>>9.<<<"  l-col-lable="Расход-Возврат"            .  { rep/r-ob1cr.i cr2  27   oborot-r-v }

  /* $Workfile: r-in-ob.p $ e n d */