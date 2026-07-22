/*

$revision: 1770 $
$author: pkhnykin $
$date: 2009-02-03 19:26:09 +0300 (Р’С‚, 03 С„РµРІ 2009) $
$workfile: r-ptlbal.i $
$archive: /ver15_1/rep/r-ptlbal.i $

Оперативный балансовый отчет движения нефтепродуктов

Автор: Уханов Дмитрий Юрьевич
Дата создания: 09/07/09
Author: Dmitry Ukhanov
Creation date: 09/07/09

author1: alexey suslov
creation date1: 03/27/06

*/

if first-of (buf_trn-doc.shift-num) then do:
  find first bef-rvs-doc no-lock
    where bef-rvs-doc.obj-type   = parobj-type
      and bef-rvs-doc.obj-code    = parobj-code
      and ( (bef-rvs-doc.shift-date = buf_trn-doc.shift-date
             and bef-rvs-doc.shift-num  <  buf_trn-doc.shift-num
            )
            or bef-rvs-doc.shift-date <  buf_trn-doc.shift-date
          )
      and bef-rvs-doc.status_     = {&fact}
      and bef-rvs-doc.rvs-type    = {&rvs-shift}
    no-error.

  assign
    bef-rvs-doc-rec = (if available bef-rvs-doc then recid(bef-rvs-doc) else ?)
  .

  find first buf_rvs-doc no-lock
    where buf_rvs-doc.obj-type    = parobj-type
      and buf_rvs-doc.obj-code    = parobj-code
      and buf_rvs-doc.shift-date  = buf_trn-doc.shift-date
      and buf_rvs-doc.shift-num   = buf_trn-doc.shift-num
      and buf_rvs-doc.status_     = {&fact}
      and buf_rvs-doc.rvs-type    = {&rvs-shift}
    no-error.

  assign
    rvs-doc-rec = (if available buf_rvs-doc then recid(buf_rvs-doc) else ?)
  .
  assign
    vardate-shift = string(buf_trn-doc.shift-name,"x(2)") + " " + string(buf_trn-doc.shift-date, "99/99/99")
  .

  display stream prnlibstream
    sym01 vardate-shift
    with frame doc-line-frm.

  {&putexcel}
  vardate-shift
  .

end.

if first-of (buf_trn-doc.shift-date) then do:
  if p-tog-shift = true then do:
    find first start-date-rvs-doc no-lock
      where start-date-rvs-doc.obj-type         = parobj-type
        and start-date-rvs-doc.obj-code         = parobj-code
        and ( (start-date-rvs-doc.shift-date    = buf_trn-doc.shift-date
              and start-date-rvs-doc.shift-num  <  buf_trn-doc.shift-num
              )
              or start-date-rvs-doc.shift-date  <  buf_trn-doc.shift-date
            )
        and start-date-rvs-doc.status_          = {&fact}
        and start-date-rvs-doc.rvs-type         = {&rvs-shift}
      no-error.
  end.
  else do:
    find first start-date-rvs-doc no-lock
      where start-date-rvs-doc.obj-type   = parobj-type
        and start-date-rvs-doc.obj-code   = parobj-code
        and start-date-rvs-doc.shift-date < buf_trn-doc.shift-date
        and start-date-rvs-doc.status_    = {&fact}
        and start-date-rvs-doc.rvs-type   = {&rvs-shift}
      no-error.
  end.
  assign start-date-rvs-doc-rec = (if available start-date-rvs-doc then recid(start-date-rvs-doc) else ?).
  find first end-date-rvs-doc no-lock
    where end-date-rvs-doc.obj-type     = parobj-type
      and end-date-rvs-doc.obj-code     = parobj-code
      and end-date-rvs-doc.shift-date   = buf_trn-doc.shift-date
      and end-date-rvs-doc.status_      = {&fact}
      and end-date-rvs-doc.rvs-type     = {&rvs-shift}
    no-error.
  assign end-date-rvs-doc-rec = (if available end-date-rvs-doc then recid(end-date-rvs-doc) else ?).
end.

if first-of(buf_doc-pl.gds-code) then do:
  assign
    varrest_start_measure   = 0
    varrest_start_book      = 0
    varwayb                 = 0
    varwayb_measure         = 0
    varwayb_fact            = 0
    varwayb_difference      = 0
    varexp_kass             = 0
    varwrite-off            = 0
    varinvent               = 0
    varexp_gross            = 0
    varret_supp             = 0
    varanother              = 0
    varrest_end_measure     = 0
    varrest_end_book        = 0
    varrest_end_balans      = 0
  .
  if bef-rvs-doc-rec <> ? then do:
    find first bef-rvs-doc no-lock
      where recid(bef-rvs-doc) = bef-rvs-doc-rec
      no-error.
    find first bef-rvs-line no-lock
      where bef-rvs-line.rvs-code = bef-rvs-doc.rvs-code
        and bef-rvs-line.obj-type = bef-rvs-doc.obj-type
        and bef-rvs-line.obj-code = bef-rvs-doc.obj-code
        and bef-rvs-line.pl-code  = buf_doc-pl.pl-code
        and bef-rvs-line.gds-code = buf_doc-pl.gds-code
      no-error.
  end.
  if rvs-doc-rec <> ? then do:
  find first buf_rvs-doc no-lock
    where recid(buf_rvs-doc) = rvs-doc-rec
    .
  find first buf_rvs-line no-lock
    where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
      and buf_rvs-line.obj-type = buf_rvs-doc.obj-type
      and buf_rvs-line.obj-code = buf_rvs-doc.obj-code
      and buf_rvs-line.pl-code  = buf_doc-pl.pl-code
      and buf_rvs-line.gds-code = buf_doc-pl.gds-code
    no-error.
  end.
  assign
    varrest_start_measure = ?
    varrest_start_book    = ?
    varrest_end_measure   = ?
    varrest_end_book      = ?
    varrest_end_balans    = ?
  .

  if p-tog-weight = true then do:
    if available bef-rvs-line then do:
      assign
        varrest_start_measure = bef-rvs-line.state-measure-cli-qnty + bef-rvs-line.state-add-qnty * bef-rvs-line.state-density
        varrest_start_book    = bef-rvs-line.system-cli-qnty
      .
    end.
    if available buf_rvs-line then do:
      assign
        varrest_end_measure   = buf_rvs-line.state-measure-cli-qnty + buf_rvs-line.state-add-qnty * buf_rvs-line.state-density
        varrest_end_book      = buf_rvs-line.system-cli-qnty
        varrest_end_balans    = varrest_end_measure - varrest_end_book
      .
    end.
  end.
  else do:
    if available bef-rvs-line then do:
      assign
        varrest_start_measure = bef-rvs-line.state-measure-qnty + bef-rvs-line.state-add-qnty
        varrest_start_book    = bef-rvs-line.system-qnty
      .
    end.
    if available buf_rvs-line then do:
      assign
        varrest_end_measure   = buf_rvs-line.state-measure-qnty + buf_rvs-line.state-add-qnty
        varrest_end_book      = buf_rvs-line.system-qnty
        varrest_end_balans    = varrest_end_measure - varrest_end_book
      .
    end.
  end.
end.

assign
  varrev = (if p-tog-weight = true then buf_doc-pl.cli-fact-qnty else buf_doc-pl.fact-qnty)
.
case buf_trn-doc.doc-type:
  when {&income} then do:
    if not buf_trn-doc.internal then do:
      assign
        varwayb      = varwayb      + (if p-tog-weight = true then buf_doc-pl.cli-doc-qnty  else buf_doc-pl.doc-qnty )
        varwayb_fact = varwayb_fact + varrev
      .

      find first bef-doc-rvs-doc no-lock
        where bef-doc-rvs-doc.out-code = buf_trn-doc.doc-code
          and bef-doc-rvs-doc.rvs-type = {&rvs-before-doc}
        no-error.
      find first aft-doc-rvs-doc no-lock
        where aft-doc-rvs-doc.out-code = buf_trn-doc.doc-code
          and aft-doc-rvs-doc.rvs-type = {&rvs-after-doc}
        no-error.
      if available bef-doc-rvs-doc
        and available aft-doc-rvs-doc
      then do:
        find first bef-doc-rvs-line no-lock
          where bef-doc-rvs-line.rvs-code = bef-doc-rvs-doc.rvs-code
            and bef-doc-rvs-line.obj-type = bef-doc-rvs-doc.obj-type
            and bef-doc-rvs-line.obj-code = bef-doc-rvs-doc.obj-code
            and bef-doc-rvs-line.pl-code  = buf_doc-pl.pl-code
            and bef-doc-rvs-line.gds-code = buf_doc-pl.gds-code
            no-error .
        find first aft-doc-rvs-line no-lock
          where aft-doc-rvs-line.rvs-code = aft-doc-rvs-doc.rvs-code
            and aft-doc-rvs-line.obj-type = aft-doc-rvs-doc.obj-type
            and aft-doc-rvs-line.obj-code = aft-doc-rvs-doc.obj-code
            and aft-doc-rvs-line.pl-code  = buf_doc-pl.pl-code
            and aft-doc-rvs-line.gds-code = buf_doc-pl.gds-code
            no-error .
      if available bef-doc-rvs-line   and available aft-doc-rvs-line
      then do: 
        assign
          varwayb_measure    = varwayb_measure + (if p-tog-weight = true then aft-doc-rvs-line.measure-cli-qnty - bef-doc-rvs-line.measure-cli-qnty else aft-doc-rvs-line.measure-qnty - bef-doc-rvs-line.measure-qnty)
          varwayb_difference = varwayb - varwayb_measure
        .
       end.

      /*else do:                  
    message '*'  {&income} buf_trn-doc.doc-code   view-as alert-box.
        assign                  
          varwayb_measure    = ?
          varwayb_difference = ?
        .                       
      end.                      */

      end.
    end.
    else do:
      assign
        varanother = varanother + varrev
      .
    end.
  end.
  when {&expense} then do:
    if not buf_trn-doc.internal then do:
      if buf_trn-doc.discnt-type = {&cash-desk} then do:
        assign
          varexp_kass = varexp_kass + varrev
        .
      end.
      else do:
        if buf_trn-doc.ext-doc-type = {&tdedt_ras_vnesh_vp} then do:
          assign
            varret_supp  = varret_supp + varrev
          .
        end.
        else do:
          assign
            varexp_gross = varexp_gross + varrev
          .
        end.
        end.
      end.
    else do:
      assign
        varanother = varanother + varrev
      .
    end.
  end.
  when {&return} then do:
    if not buf_trn-doc.internal then do:
      if buf_trn-doc.discnt-type = {&cash-desk} then do:
        assign
          varexp_kass = varexp_kass - varrev
        .
      end.
      else do:
        if buf_trn-doc.ext-doc-type = {&tdedt_ras_vnesh_vp} then do:
          assign
            varret_supp = varret_supp - varrev
          .
        end.
        else do:
          assign
            varexp_gross = varexp_gross - varrev
          .
        end.
        end.
      end.
    else do:
      assign
        varanother = varanother - varrev
      .
    end.
  end.
  when {&write-off} then do:
    assign
      varwrite-off = varwrite-off + varrev
    .
  end.
  when {&inventory} then do:
    assign
      varinvent = varinvent + varrev
    .
  end.
  otherwise do:
    assign
      varanother = varanother + varrev
    .
  end.
end case.

if last-of(buf_doc-pl.gds-code) then do:
  assign
    vargoods-name = buf_goods.gds-name
    varpl-code    = buf_doc-pl.pl-code
  .
  display stream prnlibstream
    sym01
    sym02 varpl-code
    sym03 vargoods-name
    sym04 varrest_start_measure
    sym05 varrest_start_book format "->>>>>>>9.<<<"
    sym06 varwayb
    sym07 varwayb_measure
    sym08 varwayb_fact
    sym09 varwayb_difference
    sym10 varexp_kass
    sym11 varwrite-off
    sym12 varinvent
    sym13 varexp_gross
    sym14 varret_supp
    sym15 varanother
    sym16 varrest_end_measure
    sym17 varrest_end_book format "->>>>>>>>9.<<<"
    sym18 varrest_end_balans
    sym19
   with frame doc-line-frm.
   down stream prnlibstream with frame doc-line-frm.

  {&putexcel}
  {&tabulation}
  varpl-code            {&tabulation}
  vargoods-name         {&tabulation}
  varrest_start_measure {&tabulation}
  varrest_start_book    {&tabulation}
  varwayb               {&tabulation}
  varwayb_measure       {&tabulation}
  varwayb_fact          {&tabulation}
  varwayb_difference    {&tabulation}
  varexp_kass           {&tabulation}
  varwrite-off          {&tabulation}
  varinvent             {&tabulation}
  varexp_gross          {&tabulation}
  varret_supp           {&tabulation}
  varanother            {&tabulation}
  varrest_end_measure   {&tabulation}
  varrest_end_book      {&tabulation}
  varrest_end_balans    {&new-line}
  .

  find first tt-rev-day
    where tt-rev-day.shift-date = buf_trn-doc.shift-date
      and tt-rev-day.pl-code    = buf_doc-pl.pl-code
      and tt-rev-day.gds-code   = buf_doc-pl.gds-code
    no-error.
  if not available tt-rev-day then do:
    create tt-rev-day.
    assign
      tt-rev-day.shift-date = buf_trn-doc.shift-date
      tt-rev-day.pl-code    = buf_doc-pl.pl-code
      tt-rev-day.gds-code   = buf_doc-pl.gds-code
    .
    if start-date-rvs-doc-rec <> ? then do:
      find first start-date-rvs-doc no-lock
        where recid(start-date-rvs-doc) = start-date-rvs-doc-rec.
      find first start-date-rvs-line no-lock
        where start-date-rvs-line.rvs-code = start-date-rvs-doc.rvs-code
          and start-date-rvs-line.obj-type = start-date-rvs-doc.obj-type
          and start-date-rvs-line.obj-code = start-date-rvs-doc.obj-code
          and start-date-rvs-line.pl-code  = buf_doc-pl.pl-code
          and start-date-rvs-line.gds-code = buf_doc-pl.gds-code
        no-error.
    end.
    if end-date-rvs-doc-rec <> ? then do:
      find first end-date-rvs-doc no-lock
        where recid(end-date-rvs-doc) = end-date-rvs-doc-rec
        .
      find first end-date-rvs-line no-lock
        where end-date-rvs-line.rvs-code = end-date-rvs-doc.rvs-code
          and end-date-rvs-line.obj-type = end-date-rvs-doc.obj-type
          and end-date-rvs-line.obj-code = end-date-rvs-doc.obj-code
          and end-date-rvs-line.pl-code  = buf_doc-pl.pl-code
          and end-date-rvs-line.gds-code = buf_doc-pl.gds-code
        no-error.
    end.
    assign
      tt-rev-day.rest_start_measure = ?
      tt-rev-day.rest_start_book    = ?
      tt-rev-day.rest_end_measure   = ?
      tt-rev-day.rest_end_book      = ?
      tt-rev-day.rest_end_balans    = ?
    .

    if p-tog-weight = true then do:
      if available start-date-rvs-line then do:
        assign
          tt-rev-day.rest_start_measure = start-date-rvs-line.state-measure-cli-qnty + start-date-rvs-line.state-add-qnty * start-date-rvs-line.state-density
          tt-rev-day.rest_start_book    = start-date-rvs-line.system-cli-qnty
        .
      end.
      if available end-date-rvs-line then do:
        assign
          tt-rev-day.rest_end_measure   = end-date-rvs-line.state-measure-cli-qnty + end-date-rvs-line.state-add-qnty * end-date-rvs-line.state-density
          tt-rev-day.rest_end_book      = end-date-rvs-line.system-cli-qnty
          tt-rev-day.rest_end_balans    = varrest_end_measure - varrest_end_book
        .
      end.
    end.
    else do:
      if available start-date-rvs-line then do:
        assign
          tt-rev-day.rest_start_measure = start-date-rvs-line.state-measure-qnty + start-date-rvs-line.state-add-qnty
          tt-rev-day.rest_start_book    = start-date-rvs-line.system-qnty
        .
      end.
      if available end-date-rvs-line then do:
        assign
          tt-rev-day.rest_end_measure   = end-date-rvs-line.state-measure-qnty + end-date-rvs-line.state-add-qnty
          tt-rev-day.rest_end_book      = end-date-rvs-line.system-qnty
          tt-rev-day.rest_end_balans    = tt-rev-day.rest_end_measure - tt-rev-day.rest_end_book
        .
      end.
    end.
  end.
  assign
    tt-rev-day.goods-name           = buf_goods.gds-name
    tt-rev-day.wayb                 = tt-rev-day.wayb                + varwayb
    tt-rev-day.wayb_measure         = tt-rev-day.wayb_measure        + varwayb_measure
    tt-rev-day.wayb_fact            = tt-rev-day.wayb_fact           + varwayb_fact
    tt-rev-day.wayb_difference      = tt-rev-day.wayb_difference     + varwayb_difference
    tt-rev-day.exp_kass             = tt-rev-day.exp_kass            + varexp_kass
    tt-rev-day.write-off            = tt-rev-day.write-off           + varwrite-off
    tt-rev-day.invent               = tt-rev-day.invent              + varinvent
    tt-rev-day.exp_gross            = tt-rev-day.exp_gross           + varexp_gross
    tt-rev-day.ret_supp             = tt-rev-day.ret_supp            + varret_supp
    tt-rev-day.another              = tt-rev-day.another             + varanother
  .
end.

if last-of(buf_trn-doc.shift-date) then do:

  if p-tog-with-tot-day = true
    and p-tog-shift = false
  then do:
    assign
      vardate-shift = "За сутки"
    .
    display stream prnlibstream
      vardate-shift
      with frame doc-line-frm.

    {&putexcel}
    vardate-shift
    .
  end.

  for each tt-rev-day
    where tt-rev-day.shift-date = buf_trn-doc.shift-date
  :
    if p-tog-with-tot-day = true
      and p-tog-shift = false
    then do:
      display stream prnlibstream
        sym01
        sym02 tt-rev-day.pl-code            @ varpl-code
        sym03 tt-rev-day.goods-name         @ vargoods-name
        sym04 tt-rev-day.rest_start_measure @ varrest_start_measure
        sym05 tt-rev-day.rest_start_book    @ varrest_start_book
        sym06 tt-rev-day.wayb               @ varwayb
        sym07 tt-rev-day.wayb_measure       @ varwayb_measure
        sym08 tt-rev-day.wayb_fact          @ varwayb_fact
        sym09 tt-rev-day.wayb_difference    @ varwayb_difference
        sym10 tt-rev-day.exp_kass           @ varexp_kass
        sym11 tt-rev-day.write-off          @ varwrite-off
        sym12 tt-rev-day.invent             @ varinvent
        sym13 tt-rev-day.exp_gross          @ varexp_gross
        sym14 tt-rev-day.ret_supp           @ varret_supp
        sym15 tt-rev-day.another            @ varanother
        sym16 tt-rev-day.rest_end_measure   @ varrest_end_measure
        sym17 tt-rev-day.rest_end_book      @ varrest_end_book
        sym18 tt-rev-day.rest_end_balans    @ varrest_end_balans
        sym19
      with frame doc-line-frm.
      down stream prnlibstream with frame doc-line-frm.

      {&putexcel}
      {&tabulation}
      tt-rev-day.pl-code            {&tabulation}
      tt-rev-day.goods-name         {&tabulation}
      tt-rev-day.rest_start_measure {&tabulation}
      tt-rev-day.rest_start_book    {&tabulation}
      tt-rev-day.wayb               {&tabulation}
      tt-rev-day.wayb_measure       {&tabulation}
      tt-rev-day.wayb_fact          {&tabulation}
      tt-rev-day.wayb_difference    {&tabulation}
      tt-rev-day.exp_kass           {&tabulation}
      tt-rev-day.write-off          {&tabulation}
      tt-rev-day.invent             {&tabulation}
      tt-rev-day.exp_gross          {&tabulation}
      tt-rev-day.ret_supp           {&tabulation}
      tt-rev-day.another            {&tabulation}
      tt-rev-day.rest_end_measure   {&tabulation}
      tt-rev-day.rest_end_book      {&tabulation}
      tt-rev-day.rest_end_balans    {&new-line}
      .
    end.

    find first tt-rev-gds
      where tt-rev-gds.pl-code  = tt-rev-day.pl-code
        and tt-rev-gds.gds-code = tt-rev-day.gds-code
      no-error .
    if not available tt-rev-gds then do:
      create tt-rev-gds.
      buffer-copy tt-rev-day to tt-rev-gds.
    end.
    else do:
      assign
        tt-rev-gds.wayb               =  tt-rev-gds.wayb               +  tt-rev-day.wayb
        tt-rev-gds.wayb_measure       =  tt-rev-gds.wayb_measure       +  tt-rev-day.wayb_measure
        tt-rev-gds.wayb_fact          =  tt-rev-gds.wayb_fact          +  tt-rev-day.wayb_fact
        tt-rev-gds.wayb_difference    =  tt-rev-gds.wayb_difference    +  tt-rev-day.wayb_difference
        tt-rev-gds.exp_kass           =  tt-rev-gds.exp_kass           +  tt-rev-day.exp_kass
        tt-rev-gds.write-off          =  tt-rev-gds.write-off          +  tt-rev-day.write-off
        tt-rev-gds.invent             =  tt-rev-gds.invent             +  tt-rev-day.invent
        tt-rev-gds.exp_gross          =  tt-rev-gds.exp_gross          +  tt-rev-day.exp_gross
        tt-rev-gds.ret_supp           =  tt-rev-gds.ret_supp           +  tt-rev-day.ret_supp
        tt-rev-gds.another            =  tt-rev-gds.another            +  tt-rev-day.another
        tt-rev-gds.rest_end_measure   =  tt-rev-day.rest_end_measure
        tt-rev-gds.rest_end_book      =  tt-rev-day.rest_end_book
        tt-rev-gds.rest_end_balans    =  tt-rev-day.rest_end_balans
      .
    end.
  end.
end.

/* $workfile: r-ptlbal.i $ e n d */