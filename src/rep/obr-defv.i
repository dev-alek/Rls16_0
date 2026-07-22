/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

для детал оборотки

Автор: Кочетков Михаил Юрьевич
Дата создания: 03/22/06
Author: Michael Kochetkov
Creation date: 03/22/06

*/

DEFINE temp-table gds-prop no-undo
    /* остатки */
    field   StartWay-Qnty    as  decimal
    field   StartWay-CostSum as  decimal
    field   StartWay-SaleSum as  decimal
    field   EndWay-Qnty      as  decimal
    field   EndWay-CostSum   as  decimal
    field   EndWay-SaleSum   as  decimal

    field   Free-Qnty      as  decimal
    field   Free-CostSum   as  decimal
    field   Free-SaleSum   as  decimal
    field   Res-Qnty       as  decimal
    field   Res-CostSum    as  decimal
    field   Res-DocSum     as  decimal
    field   Res-SaleSum    as  decimal
    field   Res-DiscntSum  as  decimal

    /* обороты */
    field   InExt-Qnty       as  decimal
    field   InExt-CostSum    as  decimal
    field   RetPost-Qnty     as  decimal
    field   RetPost-CostSum  as  decimal

    field   OutExt-Qnty      as  decimal
    field   OutExt-CostSum   as  decimal
    field   OutExt-DocSum   as  decimal
    field   OutExt-SaleSum   as  decimal
    field   OutExt-DiscntSum as  decimal
    field   RetOut-Qnty      as  decimal
    field   RetOut-CostSum   as  decimal
    field   RetOut-DocSum   as  decimal
    field   RetOut-SaleSum   as  decimal
    field   RetOut-DiscntSum as  decimal

    field   OutExtKass-Qnty      as  decimal
    field   OutExtKass-CostSum   as  decimal
    field   OutExtKass-SaleSum   as  decimal
    field   OutExtKass-DocSum   as  decimal
    field   OutExtKass-DiscntSum as  decimal
    field   RetOutKass-Qnty      as  decimal
    field   RetOutKass-CostSum   as  decimal
    field   RetOutKass-DocSum   as  decimal
    field   RetOutKass-SaleSum   as  decimal
    field   RetOutKass-DiscntSum as  decimal

    field   InInt-Qnty       as  decimal
    field   InInt-CostSum    as  decimal
    field   InInt-SaleSum    as  decimal
    field   OutInt-Qnty      as  decimal
    field   OutInt-CostSum   as  decimal
    field   OutInt-SaleSum   as  decimal
    field   RetInt-Qnty      as  decimal
    field   RetInt-CostSum   as  decimal
    field   RetInt-SaleSum   as  decimal

    field   Inv-Qnty         as  decimal
    field   Inv-CostSum      as  decimal
    field   Inv-SaleSum      as  decimal

    field   Spi-Qnty         as  decimal
    field   Spi-CostSum      as  decimal
    field   Spi-SaleSum      as  decimal

    field   InProiz-Qnty       as  decimal
    field   InProiz-CostSum    as  decimal
    field   InProiz-SaleSum    as  decimal
    field   OutProiz-Qnty      as  decimal
    field   OutProiz-CostSum   as  decimal
    field   OutProiz-SaleSum   as  decimal

    field   Per-SaleSum      as  decimal

    /* цены */
    field   Avrg-Sale-Price  as decimal
    field   Last-Sale-Price  as decimal
    field   Cost-Price       as  decimal
    field   Up-Plan          as  decimal
    field   Effect-Value     as  decimal
    field   Up-Fact          as  decimal

    field   LastPer-Date     as  date
    field   LastPer-Num      as  char
    field   Alt-RestEnd-Qnty as  decimal

    /* хар-ки */
    field   obj-type         as  char
    field   obj-code         as  integer
    field   obj-name         as  char
    field   prod-type        as  char
    field   prod-code        as  integer
    field   prod-name        as  char
    field   artic            as  char
    field   gds-name         as  char
    field   gds-name1        as  char
    field   grp-name         as  char
    field   unit-base        as  char
    field   b-code           as  integer
    field   grp-code         as  integer
    field   vat-pc           as  decimal
    INDEX pi  IS PRIMARY   obj-type obj-code artic  prod-type prod-code
    INDEX pi1              obj-type obj-code b-code prod-type prod-code
    INDEX pi2              artic  prod-type prod-code
    INDEX pi3              prod-name
    INDEX pi4              grp-code
    INDEX pi5              vat-pc
.

DEFINE temp-table gds-sum no-undo
field  StartWay-Qnty        as  decimal
field  StartWay-CostSum     as  decimal
field  StartWay-SaleSum     as  decimal
field  EndWay-Qnty          as  decimal
field  EndWay-CostSum       as  decimal
field  EndWay-SaleSum       as  decimal
field   Free-Qnty      as  decimal
field   Free-CostSum   as  decimal
field   Free-SaleSum   as  decimal
field   Res-Qnty       as  decimal
field   Res-CostSum    as  decimal
field   Res-DocSum     as  decimal
field   Res-SaleSum    as  decimal
field   Res-DiscntSum  as  decimal
field  InExt-Qnty           as  decimal
field  InExt-CostSum        as  decimal
field  RetPost-Qnty         as  decimal
field  RetPost-CostSum      as  decimal
field  OutExt-Qnty          as  decimal
field  OutExt-CostSum       as  decimal
field  OutExt-SaleSum       as  decimal
field  OutExt-DiscntSum     as  decimal
field  RetOut-Qnty          as  decimal
field  RetOut-CostSum       as  decimal
field  RetOut-SaleSum       as  decimal
field  RetOut-DiscntSum     as  decimal
field  OutExtKass-Qnty      as  decimal
field  OutExtKass-CostSum   as  decimal
field  OutExtKass-SaleSum   as  decimal
field  OutExtKass-DiscntSum as  decimal
field  RetOutKass-Qnty      as  decimal
field  RetOutKass-CostSum   as  decimal
field  RetOutKass-SaleSum   as  decimal
field  RetOutKass-DiscntSum as  decimal
field  InInt-Qnty           as  decimal
field  InInt-CostSum        as  decimal
field  InInt-SaleSum        as  decimal
field  OutInt-Qnty          as  decimal
field  OutInt-CostSum       as  decimal
field  OutInt-SaleSum       as  decimal
field  RetInt-Qnty          as  decimal
field  RetInt-CostSum       as  decimal
field  RetInt-SaleSum       as  decimal
field  Inv-Qnty             as  decimal
field  Inv-CostSum          as  decimal
field  Inv-SaleSum          as  decimal
field  Spi-Qnty             as  decimal
field  Spi-CostSum          as  decimal
field  Spi-SaleSum          as  decimal
field  InProiz-Qnty         as  decimal
field  InProiz-CostSum      as  decimal
field  InProiz-SaleSum      as  decimal
field  OutProiz-Qnty        as  decimal
field  OutProiz-CostSum     as  decimal
field  OutProiz-SaleSum     as  decimal
field  Per-SaleSum          as  decimal

field   Effect-Value        as  decimal
field   Alt-RestEnd-Qnty    as  decimal

field  num                  as integer
INDEX pi  IS PRIMARY unique num
.

DEFINE temp-table line-frm no-undo
  field  num          as  integer
  field  beg          as  integer
  field  titul        as character
  field  titul1       as character
  field  titul2       as character
  field  frmt         as character
  field  frm          as character
  field  sum          as decimal
  INDEX pi  IS PRIMARY unique num
.

DEFINE temp-table tt-grp-tree no-undo
  field  num          as  integer
  field  full         as character
  field  name         as character
  INDEX pi  IS PRIMARY unique full
  INDEX pi1 num
.

define temp-table o_temp-parts no-undo like ub.parts
/* количества*/
field Pri_Vnesh          as decimal init 0
field Ras_Vnesh          as decimal init 0
field Ras_Vnesh_VP       as decimal init 0
field Ras_Vnesh_Kass     as decimal init 0
field Vozvrat_Vnesh      as decimal init 0
field Vozvrat_Vnesh_Kass as decimal init 0
field Spi_Vnesh          as decimal init 0
field Pri_Perem          as decimal init 0
field Ras_Perem          as decimal init 0
field Vozvrat_Perem      as decimal init 0
field Ras_Prvo           as decimal init 0
field Pri_Prvo           as decimal init 0
field Inv                as decimal init 0
/* учетные суммы rubl*/
field rPri_Vnesh          as decimal init 0
field rRas_Vnesh          as decimal init 0
field rRas_Vnesh_VP       as decimal init 0
field rRas_Vnesh_Kass     as decimal init 0
field rVozvrat_Vnesh      as decimal init 0
field rVozvrat_Vnesh_Kass as decimal init 0
field rSpi_Vnesh          as decimal init 0
field rPri_Perem          as decimal init 0
field rRas_Perem          as decimal init 0
field rVozvrat_Perem      as decimal init 0
field rRas_Prvo           as decimal init 0
field rPri_Prvo           as decimal init 0
field rInv                as decimal init 0
/* учетные суммы base */
field bPri_Vnesh          as decimal init 0
field bRas_Vnesh          as decimal init 0
field bRas_Vnesh_VP       as decimal init 0
field bRas_Vnesh_Kass     as decimal init 0
field bVozvrat_Vnesh      as decimal init 0
field bVozvrat_Vnesh_Kass as decimal init 0
field bSpi_Vnesh          as decimal init 0
field bPri_Perem          as decimal init 0
field bRas_Perem          as decimal init 0
field bVozvrat_Perem      as decimal init 0
field bRas_Prvo           as decimal init 0
field bPri_Prvo           as decimal init 0
field bInv                as decimal init 0
field Ovr                 as decimal init 0
field ostatok-start       as decimal init 0
field ostatok-end         as decimal init 0
/* хар-ки */
field   obj-name         as  char
field   prod-name        as  char
field   gds-name         as  char
field   gds-name1        as  char
field   grp-name         as  char
field   unit-base        as  char
field   b-code           as  integer
field   grp-code         as  integer


/* суммы */
field  StartWay-Qnty        as  decimal    init 0
field  StartWay-CostSum     as  decimal    init 0
field  StartWay-SaleSum     as  decimal    init 0
field  EndWay-Qnty          as  decimal    init 0
field  EndWay-CostSum       as  decimal    init 0
field  EndWay-SaleSum       as  decimal    init 0
field   Free-Qnty      as  decimal         init 0
field   Free-CostSum   as  decimal         init 0
field   Free-SaleSum   as  decimal         init 0
field   Res-Qnty       as  decimal         init 0
field   Res-CostSum    as  decimal         init 0
field   Res-DocSum     as  decimal         init 0
field   Res-SaleSum    as  decimal         init 0
field   Res-DiscntSum  as  decimal         init 0
field  InExt-Qnty           as  decimal    init 0
field  InExt-CostSum        as  decimal    init 0
field  RetPost-Qnty         as  decimal    init 0
field  RetPost-CostSum      as  decimal    init 0
field  OutExt-Qnty          as  decimal    init 0
field  OutExt-CostSum       as  decimal    init 0
field  OutExt-SaleSum       as  decimal    init 0
field  OutExt-DiscntSum     as  decimal    init 0
field  RetOut-Qnty          as  decimal    init 0
field  RetOut-CostSum       as  decimal    init 0
field  RetOut-SaleSum       as  decimal    init 0
field  RetOut-DiscntSum     as  decimal    init 0
field  OutExtKass-Qnty      as  decimal    init 0
field  OutExtKass-CostSum   as  decimal    init 0
field  OutExtKass-SaleSum   as  decimal    init 0
field  OutExtKass-DiscntSum as  decimal    init 0
field  RetOutKass-Qnty      as  decimal    init 0
field  RetOutKass-CostSum   as  decimal    init 0
field  RetOutKass-SaleSum   as  decimal    init 0
field  RetOutKass-DiscntSum as  decimal    init 0
field  InInt-Qnty           as  decimal    init 0
field  InInt-CostSum        as  decimal    init 0
field  InInt-SaleSum        as  decimal    init 0
field  OutInt-Qnty          as  decimal    init 0
field  OutInt-CostSum       as  decimal    init 0
field  OutInt-SaleSum       as  decimal    init 0
field  RetInt-Qnty          as  decimal    init 0
field  RetInt-CostSum       as  decimal    init 0
field  RetInt-SaleSum       as  decimal    init 0
field  Inv-Qnty             as  decimal    init 0
field  Inv-CostSum          as  decimal    init 0
field  Inv-SaleSum          as  decimal    init 0
field  Spi-Qnty             as  decimal    init 0
field  Spi-CostSum          as  decimal    init 0
field  Spi-SaleSum          as  decimal    init 0
field  InProiz-Qnty         as  decimal    init 0
field  InProiz-CostSum      as  decimal    init 0
field  InProiz-SaleSum      as  decimal    init 0
field  OutProiz-Qnty        as  decimal    init 0
field  OutProiz-CostSum     as  decimal    init 0
field  OutProiz-SaleSum     as  decimal    init 0
field  Per-SaleSum          as  decimal    init 0
field  Effect-Value         as  decimal    init 0
field  Alt-RestEnd-Qnty     as  decimal    init 0
field  Avrg-Sale-Price      as  decimal    init 0
field  Last-Sale-Price      as  decimal    init 0
field  Cost-Price           as  decimal    init 0
field  Up-Plan              as  decimal    init 0
field  Up-Fact              as  decimal    init 0
field  LastPer-Date         as  date
field  LastPer-Num          as  character


field   price-prodwithvat    as  decimal    init 0
field   prod-vat             as  decimal    init 0
field   prod-vat-prc         as  decimal    init 0
field   price-supp           as  decimal    init 0
field   price-suppvat        as  decimal    init 0
field   suppvat              as  decimal    init 0
field   suppvat-prc          as  decimal    init 0
field   dis-1                as  decimal    init 0
field   dis-1-prc            as  decimal    init 0
field   prod-crsa            as  decimal    init 0
field   prod-crsavat         as  decimal    init 0
field   vat-crsa             as  decimal    init 0
field   vat-crsa-prc         as  decimal    init 0
field   dis-2                as  decimal    init 0
field   dis-2-prc            as  decimal    init 0
field   dis-3                as  decimal    init 0
field   dis-3-prc            as  decimal    init 0
field   dis-2vat             as  decimal    init 0
field   dis-2-prcvat         as  decimal    init 0
field   dis-3vat             as  decimal    init 0
field   dis-3-prcvat         as  decimal    init 0


field   prc_supp            as  decimal    init 0


index pii
  artic
  prod-type
  prod-code
  obj-type
  obj-code
.

/* $Workfile$   E n d */


















