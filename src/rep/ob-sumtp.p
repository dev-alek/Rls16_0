block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ob-sumtp.p $
$Archive: rep/ob-sumtp.p $

вспомогательная процедура для оборотки

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 02/19/03 12:57

*/
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: ob-sumtp.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/ob-sumtp.p $":U .
def var vss-description as character no-undo init "    ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
define temp-table temp#sum-type no-undo
    FIELD sum-type as char
    FIELD xi as int.

define output PARAMETER TABLE FOR temp#sum-type .

/* 0 */
create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Pri_Vnesh         } temp#sum-type.xi = 1 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Ras_Vnesh         } temp#sum-type.xi = 2 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_RAS_Vnesh_VP      } temp#sum-type.xi = 3 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Ras_Vnesh_Kass    } temp#sum-type.xi = 4 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Vozvrat_Vnesh     } temp#sum-type.xi = 5 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Vozvrat_Vnesh_Kass} temp#sum-type.xi = 6 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Spi_Vnesh         } temp#sum-type.xi = 7 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Inv               } temp#sum-type.xi = 8 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Pri_Perem         } temp#sum-type.xi = 9 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Ras_Perem         } temp#sum-type.xi = 10. create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Vozvrat_Perem     } temp#sum-type.xi = 11. create temp#sum-type.

assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Ras_Prvo          } temp#sum-type.xi = 12. create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Spi_Prvo          } temp#sum-type.xi = 12. create temp#sum-type.

assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Pri_Prvo          } temp#sum-type.xi = 13. create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Overturn          } temp#sum-type.xi = 14.
create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Corr_Acc_Price         } temp#sum-type.xi = 15 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Chg_Purch_Code   } temp#sum-type.xi = 16 .

/* 100  crsa */
create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Pri_Vnesh         } temp#sum-type.xi = 101 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Ras_Vnesh         } temp#sum-type.xi = 102 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_RAS_Vnesh_VP      } temp#sum-type.xi = 103 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Ras_Vnesh_Kass    } temp#sum-type.xi = 104 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Vozvrat_Vnesh     } temp#sum-type.xi = 105 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Vozvrat_Vnesh_Kass} temp#sum-type.xi = 106 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Spi_Vnesh         } temp#sum-type.xi = 107 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Inv               } temp#sum-type.xi = 108 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Pri_Perem         } temp#sum-type.xi = 109 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Ras_Perem         } temp#sum-type.xi = 110. create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Vozvrat_Perem     } temp#sum-type.xi = 111. create temp#sum-type.

assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Ras_Prvo          } temp#sum-type.xi = 112. create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Spi_Prvo          } temp#sum-type.xi = 112. create temp#sum-type.

assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Pri_Prvo          } temp#sum-type.xi = 113. create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Overturn          } temp#sum-type.xi = 114.

create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Corr_Acc_Price         } temp#sum-type.xi = 115 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Chg_Purch_Code   } temp#sum-type.xi = 116 .

/* 200 sale */
create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Pri_Vnesh         } temp#sum-type.xi = 201 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Ras_Vnesh         } temp#sum-type.xi = 202 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_RAS_Vnesh_VP      } temp#sum-type.xi = 203 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Ras_Vnesh_Kass    } temp#sum-type.xi = 204 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Vozvrat_Vnesh     } temp#sum-type.xi = 205 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Vozvrat_Vnesh_Kass} temp#sum-type.xi = 206 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Spi_Vnesh         } temp#sum-type.xi = 207 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Inv               } temp#sum-type.xi = 208 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Pri_Perem         } temp#sum-type.xi = 209 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Ras_Perem         } temp#sum-type.xi = 210. create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Vozvrat_Perem     } temp#sum-type.xi = 211. create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Ras_Prvo          } temp#sum-type.xi = 212. create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Spi_Prvo          } temp#sum-type.xi = 212. create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Pri_Prvo          } temp#sum-type.xi = 213. create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Overturn          } temp#sum-type.xi = 214.
create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Corr_Acc_Price         } temp#sum-type.xi = 215 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Chg_Purch_Code   } temp#sum-type.xi = 216 .

return .