/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определения для таможенного отчета

Автор: Суслов Алексей Юрьевич
Дата создания: 09/19/05
Author: Alexey Suslov
Creation date: 09/19/05

*/


DEFINE {1} SHARED TEMP-TABLE gds-brutto NO-UNDO
    FIELD artic          LIKE ub.goods.artic
    FIELD prod-type      LIKE ub.parts.prod-type
    FIELD prod-code      LIKE ub.parts.prod-code
    FIELD cst-code       LIKE ub.parts.cst-code
    FIELD gds-name       LIKE ub.goods.gds-name
    FIELD unit           LIKE ub.goods.unit-base
    FIELD in-qnty        LIKE ub.parts.fact-qnty
    FIELD in-wt-brutto   LIKE ub.doc-line.wt-brutto
    FIELD in-fact-place  LIKE ub.doc-line.num-place
    FIELD out-qnty       LIKE ub.parts.fact-qnty
    FIELD out-wt-brutto  LIKE ub.doc-line.wt-brutto
    FIELD out-fact-place LIKE ub.doc-line.num-place
    INDEX art IS PRIMARY artic cst-code ASCENDING
    .
DEFINE {1} SHARED TEMP-TABLE parts-brutto    NO-UNDO
    FIELD in-code       LIKE ub.parts.in-code
    FIELD out-code      LIKE ub.parts.out-code
    FIELD part-code     LIKE ub.parts.part-code
    FIELD part-type     AS   CHARACTER
    FIELD obj-code      LIKE ub.parts.obj-code
    FIELD obj-type      LIKE ub.parts.obj-type
    FIELD host-code     LIKE ub.parts.host-code
    FIELD artic         LIKE ub.parts.artic
    FIELD prod-type     LIKE ub.parts.prod-type
    FIELD prod-code     LIKE ub.parts.prod-code
    FIELD gds-name      LIKE ub.goods.gds-name
    FIELD tnved         LIKE tt-tnved.tnved
    FIELD nationality   LIKE ub.goods.nationality
    FIELD unit          LIKE ub.goods.unit-base
    FIELD fact-date     LIKE ub.parts.fact-date
    FIELD fact-num      LIKE ub.parts.fact-num
    FIELD cst-code      LIKE ub.parts.cst-code
    FIELD fact-qnty     LIKE ub.parts.fact-qnty
    FIELD qnty-up       LIKE ub.parts.fact-qnty
    FIELD down-qnty     LIKE ub.parts.fact-qnty
    FIELD fact-brutto   LIKE ub.doc-line.wt-brutto
    FIELD fact-place    LIKE ub.doc-line.num-place
    INDEX atom IS PRIMARY
                  part-type
                  host-code
                  obj-code
                  obj-type
                  artic
                  prod-type
                  prod-code
                  cst-code
    INDEX fact-num fact-num  ASCENDING.
DEFINE BUFFER bf-parts-brutto  FOR parts-brutto.
DEFINE BUFFER out-parts-brutto FOR parts-brutto.
DEFINE BUFFER in-parts-brutto FOR parts-brutto.
DEFINE {1} SHARED TEMP-TABLE prt-parts-brutto    NO-UNDO
    FIELD in-date        AS   CHARACTER
    FIELD cst-code       LIKE ub.parts.cst-code
    FIELD artic          LIKE ub.goods.artic
    FIELD prod-code      LIKE ub.goods.prod-code
    FIELD prod-type      LIKE ub.goods.prod-type
    FIELD obj-code       LIKE ub.parts.obj-code
    FIELD obj-type       LIKE ub.parts.obj-type
    FIELD host-code      LIKE ub.parts.host-code
    FIELD in-num         LIKE ub.parts.fact-num
    FIELD out-num        LIKE ub.parts.fact-num
    FIELD tnved          LIKE tt-tnved.tnved
    FIELD gds-name       LIKE ub.goods.gds-name
    FIELD nationality    LIKE ub.goods.nationality
    FIELD unit           LIKE ub.goods.unit-base
    FIELD in-qnty        AS   CHARACTER
    FIELD in-qnty-up     AS   CHARACTER
    FIELD in-wt-brutto   AS   CHARACTER
    FIELD in-fact-place  AS   CHARACTER
    FIELD out-date       AS   CHARACTER
    FIELD out-qnty       AS   CHARACTER
    FIELD out-qnty-up    AS   CHARACTER
    FIELD out-wt-brutto  AS   CHARACTER
    FIELD out-fact-place AS   CHARACTER
    FIELD des            AS   CHARACTER
    INDEX in-out IS PRIMARY cst-code in-num out-num ASCENDING .