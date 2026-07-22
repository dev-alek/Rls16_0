block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: invlui2p.p $
$Archive: rep/invlui2p.p $


Автор: Суслов Алексей Юрьевич
Дата создания: 09/08/05
Author: Alexey Suslov
Creation date: 09/08/05

*/

DEFINE TEMP-TABLE tt-result NO-UNDO
FIELD artic LIKE ub.goods.artic
FIELD prod-type LIKE ub.goods.prod-type
FIELD prod-code LIKE ub.goods.prod-code
FIELD node-code  LIKE ub.gds-prt.node-code
FIELD gds-name  LIKE ub.goods.gds-name
FIELD b-code    LIKE ub.bar-code.b-code
FIELD scan-1 AS DECIMAL INITIAL ?
FIELD scan-2 AS DECIMAL INITIAL ?
FIELD diff-1-2 AS CHARACTER
FIELD scan-3 AS CHARACTER INITIAL "":u
FIELD itog AS DECIMAL INITIAL ?
INDEX pi IS UNIQUE PRIMARY artic prod-type prod-code node-code
INDEX artic artic
INDEX itog itog.

define input  parameter parParentProc  as widget-handle no-undo.
define input parameter table for tt-result.

define variable g#report-num as integer   no-undo .

{ cmp/str-glbl.i     }
{ cmp/library.i     }
{ cmp/r-pril.i NEW  }
{ cmp/r-page1.i NEW }
{ gbl/cur-time.i    }
{ rep/par-actu.i    }
{ rep/opclexcl.i    }

run get-report-num  in parParentProc ( output g#report-num ).
assign
  make-excel = yes.
run openforexcel in this-procedure .
run rep/invluipr.p (parParentProc , input table tt-result).
run closeforexcel in this-procedure .