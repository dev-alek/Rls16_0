/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Файл для формирования case с различными способами вычисления цены продажи

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

6 - точка вызова: pr-doc - интерфейс переоценки
                  in-pr  - переоценка по приходу
1 - процент наценки (поле или переменная)
2 - буфер price-doc
3 - буфер price-list
4 - буфер goods
5 - буфер bar-code

требуется наличие буферов {3}, {4}, {5}
*/
/*--Накладная без налога  --------------------------------------------------------------------------------------------*/
   when {&pr-calc-wbill-novat}  then do:
      &if "{6}" = "pr-doc" &then
      /* при вызове из интерфейса переоценки нужно искать исходную цену */
      if available ub.trn-doc then do:
        if ub.trn-doc.doc-type = {&income} and
         ( ub.trn-doc.ext-doc-type = {&tdedt_pri_vnesh} /* or
           ub.trn-doc.ext-doc-type = {&tdedt_pri_prvo} */ ) then do:

          /* при внешнем приходе и производстве считаем от учетных цен */
          find ub.doc-line where ub.doc-line.doc-code = doc-code
                          and ub.doc-line.artic     = {3}.artic
                          and ub.doc-line.prod-type = {3}.prod-type
                          and ub.doc-line.prod-code = {3}.prod-code no-lock no-error.
          if available ub.doc-line then DO:
              run str/gdsnovat.p
                 ({&pr-calc-wbill-novat},
                  {3}.obj-type          ,
                  {3}.obj-code          ,
                  {2}.host-code         ,
                  {3}.artic             ,
                  {3}.prod-type         ,
                  {3}.prod-code         ,
                  {1}                   ,
                  doc-code              ,
                  input p-doc-price-rubl-novat   ,
                  input p-doc-price-base-novat   ,
                  output cost-base      ,
                  output cost-rubl      ,
                  output v-price-base   ,
                  output v-price-rubl   ,
                  output cur-rt-base    ,
                  output cur-rt-rubl   )
                  .
              assign
                cur-rt =  if var-pr-r-b = "rubl" then cur-rt-rubl else cur-rt-base
                {3}.calc-method = {&pr-calc-wbill-novat} + " " + doc-code
                {3}.price-calc  =  if var-pr-r-b = "rubl" then  ub.doc-line.price-rubl  else ub.doc-line.price-base
                {3}.price-sale  =  if var-pr-r-b = "rubl" then  v-price-rubl         else  v-price-base
                {3}.road-tax    = cur-rt
                tt-price-sale   =  if var-pr-r-b = "rubl" then  v-price-rubl         else  v-price-base
                .
              End.
          else
            message "Нет строки в накладной :" doc-code "для товара :" {3}.artic {4}.gds-name
                    "- расчет невозможен."
                    view-as alert-box question buttons OK-Cancel update g#log.
        end.
        else do:
          /* при остальных */
          find ub.doc-line where ub.doc-line.doc-code = doc-code
                          and ub.doc-line.artic     = {3}.artic
                          and ub.doc-line.prod-type = {3}.prod-type
                          and ub.doc-line.prod-code = {3}.prod-code no-lock no-error.
          if available ub.doc-line then DO:
              run str/gdsnovat.p ({&pr-calc-wbill-novat} + "Other":U ,
                            {3}.obj-type,
                            {3}.obj-code,
                            {2}.host-code,
                            {3}.artic,
                            {3}.prod-type,
                            {3}.prod-code,
                            {1},
                            doc-code,
                            input p-doc-price-rubl-novat   ,
                            input p-doc-price-base-novat   ,
                            output cost-base   ,
                            output cost-rubl   ,
                            output v-price-base  ,
                            output v-price-rubl  ,
                            output cur-rt-base ,
                            output cur-rt-rubl ).
              assign
                cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
                {3}.calc-method = {&pr-calc-wbill-novat} + " " + doc-code
                {3}.price-calc  =  if var-pr-r-b = "rubl" then ub.doc-line.price-rubl else ub.doc-line.price-base
                {3}.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                {3}.road-tax    = cur-rt
                tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                .
              End.
          else
            message "Нет строки в накладной :" doc-code "для товара :" {3}.artic {4}.gds-name
                    "- расчет невозможен."
                    view-as alert-box question buttons OK-Cancel update g#log.
        end.
      end.
      else
        message "Не прочитана накладная с номером" doc-code
                "- расчет невозможен."
                view-as alert-box question buttons OK-Cancel update g#log.
      &else

      /* при вызове из автомат переоценки (in-pr.p) все исходные цены должны быть */
      if ub.trn-doc.doc-type = {&income} and
         ( ub.trn-doc.ext-doc-type = {&tdedt_pri_vnesh} /* or
           ub.trn-doc.ext-doc-type = {&tdedt_pri_prvo} */ ) then do:
        /* при внешнем приходе и производстве считаем от учетных цен */
              run str/gdsnovat.p ({&pr-calc-wbill-novat},
                      {3}.obj-type,
                      {3}.obj-code,
                      {2}.host-code,
                      {3}.artic,
                      {3}.prod-type,
                      {3}.prod-code,
                      {1},
                      doc-code,
                      input p-doc-price-rubl-novat   ,
                      input p-doc-price-base-novat   ,
                      output cost-base   ,
                      output cost-rubl   ,
                      output v-price-base  ,
                      output v-price-rubl  ,
                      output cur-rt-base ,
                      output cur-rt-rubl )
                      .
                      if available ub.doc-line then do:
                          assign
                            cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
                            {3}.calc-method = {&pr-calc-wbill-novat} + " " + doc-code
                            {3}.price-calc  =  if var-pr-r-b = "rubl" then ub.doc-line.price-rubl else ub.doc-line.price-base
                            {3}.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                            {3}.road-tax    = cur-rt
                            tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                          .
                      end.
                      else do:
                          assign
                            cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
                            {3}.calc-method = {&pr-calc-wbill-novat} + " " + doc-code
                            {3}.price-calc  =  if var-pr-r-b = "rubl" then p-doc-price-rubl-novat else p-doc-price-base-novat
                            {3}.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                            {3}.road-tax    = cur-rt
                            tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                          .
                      end.
                End.
      else do:
          run str/gdsnovat.p ({&pr-calc-wbill-novat} + "Other":U ,
              {3}.obj-type,
              {3}.obj-code,
              {2}.host-code,
              {3}.artic,
              {3}.prod-type,
              {3}.prod-code,
              {1},
              doc-code,
              input p-doc-price-rubl-novat   ,
              input p-doc-price-base-novat   ,
              output cost-base   ,
              output cost-rubl   ,
              output v-price-base  ,
              output v-price-rubl  ,
              output cur-rt-base ,
              output cur-rt-rubl ).
              if available ub.doc-line then do:
                  assign
                    cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
                    {3}.calc-method = {&pr-calc-wbill-novat} + " " + doc-code
                    {3}.price-calc  =  if var-pr-r-b = "rubl" then ub.doc-line.price-rubl else ub.doc-line.price-base
                    {3}.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                    {3}.road-tax    = cur-rt
                    tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                  .
              end.
              else do:
                  assign
                    cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl             else cur-rt-base
                    {3}.calc-method = {&pr-calc-wbill-novat} + " " + doc-code
                    {3}.price-calc  =  if var-pr-r-b = "rubl" then p-doc-price-rubl-novat else p-doc-price-base-novat
                    {3}.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl           else v-price-base
                    {3}.road-tax    = cur-rt
                    tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl            else v-price-base
                  .
              end.
          End.
      &endif
    end.
/* Откат цен ------------------------------------------------------------------------------------------------------------*/
  &if "{6}" = "pr-doc" &then
  when {&pr-calc-undo} then do:
    run str/gdsnovat.p
      ( {&pr-calc-undo},
        {3}.obj-type,
        {3}.obj-code,
        {2}.host-code,
        {3}.artic,
        {3}.prod-type,
        {3}.prod-code,
        {1},
        "",
        input p-doc-price-rubl-novat ,
        input p-doc-price-base-novat ,
        output cost-base   ,
        output cost-rubl   ,
        output v-price-base  ,
        output v-price-rubl  ,
        output cur-rt-base ,
        output cur-rt-rubl
        ).
      assign
        cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
        {3}.calc-method = {&pr-calc-undo}
        {3}.price-calc  =  if var-pr-r-b = "rubl" then cost-rubl           else cost-base
        {3}.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
        {3}.road-tax    = cur-rt
        tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
      .
  end.
  &endif
/*--Продажная без налога по старой переоценке --------------------------------------------------------------------------*/
    &if "{6}" = "pr-doc" &then
    when {&pr-calc-old-novat} then do:
      run str/gdsnovat.p ( {&pr-calc-old-novat},
          {3}.obj-type,
          {3}.obj-code,
          {2}.host-code,
          {3}.artic,
          {3}.prod-type,
          {3}.prod-code,
          {1},
          "" ,
          input p-doc-price-rubl-novat ,
          input p-doc-price-base-novat ,
          output cost-base   ,
          output cost-rubl   ,
          output v-price-base  ,
          output v-price-rubl  ,
          output cur-rt-base ,
          output cur-rt-rubl ).
        assign
          cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
          {3}.calc-method = {&pr-calc-old-novat}
          {3}.price-calc  =  if var-pr-r-b = "rubl" then cost-rubl           else cost-base
          {3}.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
          {3}.road-tax    = cur-rt
          tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
        .
    end.
    &endif
    when {&pr-calc-slt} then do:
      run str/gdsnovat.p ( {&pr-calc-slt},
          {3}.obj-type,
          {3}.obj-code,
          {2}.host-code,
          {3}.artic,
          {3}.prod-type,
          {3}.prod-code,
          {1},
          "",
          input p-doc-price-rubl-novat ,
          input p-doc-price-base-novat ,
          output cost-base   ,
          output cost-rubl   ,
          output v-price-base  ,
          output v-price-rubl  ,
          output cur-rt-base ,
          output cur-rt-rubl ).
        assign
          cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
          {3}.calc-method = {&pr-calc-slt}
          {3}.price-calc  =  if var-pr-r-b = "rubl" then cost-rubl           else cost-base
          {3}.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
          {3}.road-tax    = cur-rt
          tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
        .
    end.

/*-- Учетная без налога--------------------------------------------------------------------------------------------------*/
    when {&pr-calc-cost-novat} then do:
      run str/gdsnovat.p ({&pr-calc-cost-novat},
          {3}.obj-type,
          {3}.obj-code,
          {2}.host-code,
          {3}.artic,
          {3}.prod-type,
          {3}.prod-code,
          {1},
          doc-code,
          input p-doc-price-rubl-novat ,
          input p-doc-price-base-novat ,
          output cost-base   ,
          output cost-rubl   ,
          output v-price-base  ,
          output v-price-rubl  ,
          output cur-rt-base ,
          output cur-rt-rubl ).
        assign
          cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
          {3}.calc-method = {&pr-calc-cost-novat}
          {3}.price-calc  =  if var-pr-r-b = "rubl" then cost-rubl           else cost-base
          {3}.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
          {3}.road-tax    = cur-rt
          tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
        .
    end.
/*-- Учетная + накладная --------------------------------------------------------------------------------------------------*/
    when {&pr-calc-cost-wbill} then do:
      run str/gdsnovat.p
         (input {&pr-calc-cost-wbill},
          input {3}.obj-type,
          input {3}.obj-code,
          input {2}.host-code,
          input {3}.artic,
          input {3}.prod-type,
          input {3}.prod-code,
          input {1},
          input doc-code,
          input p-doc-price-rubl-novat ,
          input p-doc-price-base-novat ,
          output cost-base   ,
          output cost-rubl   ,
          output v-price-base  ,
          output v-price-rubl  ,
          output cur-rt-base ,
          output cur-rt-rubl ).
        assign
          cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
          {3}.calc-method = {&pr-calc-cost-wbill}
          {3}.price-calc  =  if var-pr-r-b = "rubl" then cost-rubl           else cost-base
          {3}.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
          {3}.road-tax    = cur-rt
          tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
        .
    end.
    when {&pr-calc-cost-wbill-novat} then do:
      run str/gdsnovat.p ({&pr-calc-cost-wbill-novat},
          {3}.obj-type,
          {3}.obj-code,
          {2}.host-code,
          {3}.artic,
          {3}.prod-type,
          {3}.prod-code,
          {1},
          doc-code,
          input p-doc-price-rubl-novat ,
          input p-doc-price-base-novat ,
          output cost-base   ,
          output cost-rubl   ,
          output v-price-base  ,
          output v-price-rubl  ,
          output cur-rt-base ,
          output cur-rt-rubl )
          .

        assign
          cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
          {3}.calc-method =  {&pr-calc-cost-wbill-novat}  + " " + doc-code
          {3}.price-calc  =  if var-pr-r-b = "rubl" then cost-rubl           else cost-base
          {3}.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
          {3}.road-tax    = cur-rt
          tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
        .
    end.
    when {&pr-calc-cost} then do:
      run trg/gdsavrg.p ({&pr-calc-cost},
                     {3}.obj-type,
                     {3}.obj-code,
                     {2}.host-code,
                     {3}.artic,
                     {3}.prod-type,
                     {3}.prod-code,
                     output cost-base,
                     output cost-rubl,
                     output cur-rt-base ,
                     output cur-rt-rubl ).
        assign
          {3}.calc-method =  {&pr-calc-cost}
          {3}.price-calc  =  if var-pr-r-b = "rubl" then   cost-rubl                   else  cost-base
          {3}.price-sale  =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + {1} / 100) else  cost-base * (1 + {1} / 100)
          tt-price-sale   =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + {1} / 100) else  cost-base * (1 + {1} / 100)
          {3}.road-tax    =  if var-pr-r-b = "rubl" then cur-rt-rubl                   else  cur-rt-base
          .


    end.

/*-----------------------------------------------------------------------------------------------------------------------*/
    when {&pr-calc-costobj} then do:
      run trg/gdsavrg.p ({&pr-calc-costobj},
                     {3}.obj-type,
                     {3}.obj-code,
                     {2}.host-code,
                     {3}.artic,
                     {3}.prod-type,
                     {3}.prod-code,
                     output cost-base,
                     output cost-rubl,
                     output cur-rt-base ,
                     output cur-rt-rubl ).

      assign
        {3}.calc-method = {&pr-calc-costobj}
        {3}.price-calc  =  if var-pr-r-b = "rubl" then   cost-rubl                   else  cost-base
        {3}.price-sale  =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + {1} / 100) else  cost-base * (1 + {1} / 100)
        tt-price-sale   =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + {1} / 100) else  cost-base * (1 + {1} / 100)
        {3}.road-tax    =  if var-pr-r-b = "rubl" then cur-rt-rubl                   else  cur-rt-base
        .
    end.
/*-----------------------------------------------------------------------------------------------------------------------*/
    when {&pr-calc-rsrv} then do:
      run trg/gdsavrg.p
        ({&pr-calc-rsrv},
          {3}.obj-type,
          {3}.obj-code,
          {2}.host-code,
          {3}.artic,
          {3}.prod-type,
          {3}.prod-code,
          output cost-base,
          output cost-rubl,
          output cur-rt-base ,
          output cur-rt-rubl
          ).
      assign
        {3}.calc-method = {&pr-calc-rsrv}
        {3}.price-calc  =  if var-pr-r-b = "rubl" then   cost-rubl                   else  cost-base
        {3}.price-sale  =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + {1} / 100) else  cost-base * (1 + {1} / 100)
        tt-price-sale   =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + {1} / 100) else  cost-base * (1 + {1} / 100)
        {3}.road-tax    =  if var-pr-r-b = "rubl" then cur-rt-rubl                   else  cur-rt-base

        .
    end.

    when {&pr-calc-last} then do:
      run trg/gdsavrg.p ({&pr-calc-last},
                     {3}.obj-type,
                     {3}.obj-code,
                     {2}.host-code,
                     {3}.artic,
                     {3}.prod-type,
                     {3}.prod-code,
                     output cost-base,
                     output cost-rubl,
                     output cur-rt-base ,
                     output cur-rt-rubl ).
      if
        ( var-pr-r-b = "rubl" and
         (
         cost-rubl = 0
      or cost-rubl = ? ))
      or
        ( var-pr-r-b = "base" and
         (
         cost-base = 0
      or cost-base = ? ))

      then do:
        message "Нет ПН для товара :" {3}.artic {4}.gds-name
                "- расчет от последней приходной цены невозможен."
                view-as alert-box question buttons OK-Cancel update g#log.
      end.
      else do:
        assign
        {3}.calc-method = {&pr-calc-last}
        {3}.price-calc  =  if var-pr-r-b = "rubl" then   cost-rubl                   else  cost-base
        {3}.price-sale  =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + {1} / 100) else  cost-base * (1 + {1} / 100)
        tt-price-sale   =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + {1} / 100) else  cost-base * (1 + {1} / 100)
        {3}.road-tax    =  if var-pr-r-b = "rubl" then cur-rt-rubl                   else  cur-rt-base

          .
      end.
    end.

    when {&pr-calc-lastobj} then do:
      run trg/gdsavrg.p ({&pr-calc-lastobj},
                     {3}.obj-type,
                     {3}.obj-code,
                     {2}.host-code,
                     {3}.artic,
                     {3}.prod-type,
                     {3}.prod-code,
                     output cost-base,
                     output cost-rubl,
                     output cur-rt-base ,
                     output cur-rt-rubl ).

      if
        ( var-pr-r-b = "rubl" and
         (
         cost-rubl = 0
      or cost-rubl = ? ))
      or
        ( var-pr-r-b = "base" and
         (
         cost-base = 0
      or cost-base = ? ))   then do:

        message "Нет ПН для товара :" {3}.artic {4}.gds-name
                "- расчет от последней приходной цены невозможен."
                view-as alert-box question buttons OK-Cancel update g#log.
      end.
      else do:
        assign
          {3}.calc-method = {&pr-calc-lastobj}
          {3}.price-calc  =  if var-pr-r-b = "rubl" then   cost-rubl                   else  cost-base
          {3}.price-sale  =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + {1} / 100) else  cost-base * (1 + {1} / 100)
          tt-price-sale   =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + {1} / 100) else  cost-base * (1 + {1} / 100)
          {3}.road-tax    =  if var-pr-r-b = "rubl" then cur-rt-rubl                   else  cur-rt-base

          .
      end.
    end.
    when {&pr-calc-prod} then do:
    { gbl/proprice.i
      {3}.b-code
      {3}.obj-type
      {3}.obj-code
      tt-price-prodwihvat
      cost-rubl
      tt-prod-vat
      v-str
      v-str
    }

      if cost-rubl = 0 or cost-rubl = ?  then do:
        message "Нет ПН для товара :" {3}.artic {4}.gds-name
                "- расчет по производителю от последней приходной накладной невозможен."
                view-as alert-box question buttons OK-Cancel title "#1" update g#log .
      end.
      else do:
        assign
          {3}.calc-method = {&pr-calc-prod}
          {3}.price-calc  =  cost-rubl
          {3}.price-sale  =  cost-rubl * (1 + {1} / 100)
          tt-price-sale   =  cost-rubl * (1 + {1} / 100)
          {3}.road-tax    = 0
          .
      end.
    end.

    when {&pr-calc-level-prod} then do:
          run calc-price-levelprod (
            input 2            , /* 1- цены с НДС; 2 - цены без ндс */
            input var-pr-r-b   ,
            input {3}.b-code     ,
            input {3}.obj-type ,
            input {3}.obj-code ,
            output cost-rubl ,
            output v-str
          ) .
      if cost-rubl = 0 or cost-rubl = ?  then do:
        message "Нет ПН для товара :" {3}.artic {4}.gds-name
                "- расчет по производителю от последней приходной накладной невозможен."
                view-as alert-box .
      end.
      else do:
          {3}.price-calc = cost-rubl .
          {3}.calc-method = {&pr-calc-level-prod} + {&delim-par} + v-str.
          {3}.road-tax    = 0 .
          {3}.price-sale  =  cost-rubl * (1 + {3}.vat-pc / 100) .
          tt-price-sale   =  cost-rubl * (1 + {3}.vat-pc / 100) .
      end.

    end.
    when {&pr-calc-level-prod-vat} then do:
          run calc-price-levelprod (
            input 1            , /* 1- цены с НДС; 2 - цены без ндс */
            input var-pr-r-b   ,
            input {3}.b-code     ,
            input {3}.obj-type ,
            input {3}.obj-code ,
            output cost-rubl,
            output v-str
          ) .
      if cost-rubl = 0 or cost-rubl = ?  then do:
        message "Нет ПН для товара :" {3}.artic {4}.gds-name
                "- расчет по производителю от последней приходной накладной невозможен."
                view-as alert-box .
      end.
      else do:
          {3}.price-calc = cost-rubl .
          {3}.calc-method = {&pr-calc-level-prod-vat} + {&delim-par} + v-str.
          {3}.road-tax    = 0 .
          {3}.price-sale  =  cost-rubl  .
          tt-price-sale   =  cost-rubl  .
      end.
    end.


    when {&pr-calc-prod-vat} then do:
    { gbl/proprice.i
      {3}.b-code
      {3}.obj-type
      {3}.obj-code
      cost-rubl
      tt-price-prodwihvat
      tt-prod-vat
      v-str
      v-str
    }
      if cost-rubl = 0 or cost-rubl = ?  then do:
        message "Нет ПН для товара :" {3}.artic {4}.gds-name
                "- расчет по производителю от последней приходной накладной невозможен."
                view-as alert-box question buttons OK-Cancel title "#1" update g#log .
      end.
      else do:
        assign
          {3}.calc-method = {&pr-calc-prod-vat}
          {3}.price-calc  = cost-rubl
          {3}.price-sale  =  cost-rubl * (1 + {1} / 100)
                                       * (1 + {3}.vat-pc / 100 )
          tt-price-sale   =  cost-rubl * (1 + {1} / 100)
                                       * (1 + {3}.vat-pc / 100 )
          {3}.road-tax    = 0
          .
      end.
    end.

    when {&pr-calc-new} then
      if {3}.price-sale = ? then
        message "Неизвестна новая цена для товара :"
                {3}.artic {4}.gds-name
                "- расчет невозможен."
                view-as alert-box question buttons OK-Cancel update g#log.
      else
        assign
          {3}.calc-method = {&pr-calc-new}
          {3}.price-calc = {3}.price-sale
          {3}.price-sale = {3}.price-sale * (1 + {1} / 100)
          tt-price-sale = {3}.price-sale * (1 + {1} / 100)

          .

    &if "{6}" = "pr-doc" &then
    when {&pr-calc-old} then do:
      /* ищем предыдущий прайс-лист для этого объекта */
      { gbl/bcodeprc.i
        {3}.obj-type
        {3}.obj-code
        {3}.b-code
        0
        0
        cur-dn
        cur-pr
        cur-rt
        cur-ex }
      if cur-pr = ? then
        message "Нет Акта переоценки для товара :" {3}.artic {4}.gds-name
                "- расчет от старой цены продажи невозможен."
                view-as alert-box question buttons OK-Cancel update g#log.
      else
        assign
          {3}.calc-method = {&pr-calc-old}
          {3}.price-calc  = cur-pr
          {3}.road-tax    = cur-rt
          {3}.excise      = cur-ex
          {3}.price-sale  = cur-pr * (1 + {1} / 100)
          tt-price-sale  = cur-pr * (1 + {1} / 100)
          .
    end.
    &endif

    &if "{6}" = "pr-doc" &then
    when {&pr-calc-obj} then do:
      /* ищем предыдущий прайс-лист для ВЫБРАННОГО объекта */
      { gbl/bcodeprc.i
        copy-type
        copy-code
        {3}.b-code
        0
        0
        cur-dn
        cur-pr
        cur-rt
        cur-ex }
      if cur-pr = ? then
        message "Нет Акта переоценки для товара :" {3}.artic {4}.gds-name
                "по" input frame {&frame-name} copy-type
                input frame {&frame-name} copy-code "расчет невозможен."
                view-as alert-box question buttons OK-Cancel update g#log.
      else
        assign
          {3}.calc-method = {&pr-calc-obj} + " " + copy-type + " " + string (copy-code, "99999")
          {3}.price-calc  = cur-pr
          {3}.road-tax    = cur-rt
          {3}.excise      = cur-ex
          {3}.price-sale  = cur-pr * (1 + {1} / 100)
          tt-price-sale  = cur-pr * (1 + {1} / 100)
          .
    end.
    &endif
/*--------------------------------------------------------------------------------------------*/
    when {&pr-calc-wbill} then do:
        run str/pr-wbil.p
        ( input "{6}"              ,
          input {&pr-calc-wbill}   ,
          input recid(ub.trn-doc)     ,
          input recid(ub.doc-line)    ,
          input recid( ub.gds-dtl)     ,
          input doc-code           ,
          input {4}.gds-name       ,
          input {4}.gds-code       ,
          input {3}.artic          ,
          input {3}.prod-type      ,
          input {3}.prod-code      ,
          input {5}.node-code      ,
          input {1}                ,
          input p-doc-price-rubl   ,
          input p-doc-price-base   ,
          output v-price-base      ,
          output v-price-rubl
          ) no-error  .
      if not error-status :error then do:
          assign
            {3}.calc-method = {&pr-calc-wbill} + " " + doc-code
            {3}.price-calc  = v-price-base
            {3}.price-sale  = v-price-rubl
            tt-price-sale   = v-price-rubl
        .
      end.
      else do:
         message
           vss-workfile vss-revision vss-description skip
           error-status :get-message(1) skip
           return-value skip
           "444"
           view-as alert-box error
         .
      end.
    end.
/*--------------------------------------------------------------------------------------------*/
    when {&pr-calc-slt-wbill} then do:
        run str/pr-wbil.p
        ( input "{6}"                ,
          input {&pr-calc-slt-wbill} ,
          input recid(ub.trn-doc)       ,
          input recid(ub.doc-line)    ,
          input recid( ub.gds-dtl)     ,
          input doc-code             ,
          input {4}.gds-name         ,
          input {4}.gds-code         ,
          input {3}.artic            ,
          input {3}.prod-type        ,
          input {3}.prod-code        ,
          input {5}.node-code        ,
          input 0                    ,
          input p-doc-price-rubl     ,
          input p-doc-price-base     ,
          output v-price-base        ,
          output v-price-rubl
          ) no-error  .
      if not error-status :error then
          assign
            {3}.calc-method = {&pr-calc-slt-wbill} + " " + doc-code
            {3}.price-calc  = v-price-base
            {3}.price-sale  = v-price-rubl
            tt-price-sale   = v-price-rubl
        .
    end.
/*------------------------------------------------------------*/

    &if "{6}" = "pr-doc" &then
    when {&pr-calc-ov} then do:
      find prev-list where
           prev-list.b-code     = {3}.b-code and
           prev-list.price-type = "" and
           prev-list.doc-num    = doc-code no-lock no-error.
      if available prev-list then
        assign
          {3}.calc-method = {&pr-calc-ov} + " " + doc-code
          {3}.price-calc = prev-list.price-sale
          {3}.road-tax = prev-list.road-tax
          {3}.excise = prev-list.excise
          {3}.price-sale = prev-list.price-sale * (1 + {1} / 100)
          tt-price-sale = prev-list.price-sale * (1 + {1} / 100)
          .
      else
        message "Нет строки в переоценке :" doc-code "для товара :" {3}.artic {4}.gds-name
                "- расчет невозможен."
                view-as alert-box question buttons OK-Cancel update g#log.
    end.
    &endif

    when {&pr-calc-no} then do:
      if {3}.price-sale = ? then do:
        /* по первому разу после добавления инициируем цену */
        { gbl/bcodeprc.i
          {3}.obj-type
          {3}.obj-code
          {3}.b-code
          0
          0
          cur-dn
          cur-pr
          cur-rt
          cur-ex }
        if cur-pr <> ? then
          assign
            {3}.calc-method = {&pr-calc-no}
            {3}.price-calc  = cur-pr
            {3}.price-sale  = cur-pr
            tt-price-sale   = cur-pr
            {3}.road-tax    = cur-rt
            {3}.excise      = cur-ex
            .
      end.
      line-rec = recid ({3}).
    end.

    when {&pr-calc-fix} then do:
      /* цена не пересчитывается при расчете от товаров */
      if {3}.price-sale = ? then do:
        assign
          {3}.calc-method = {&pr-calc-fix}
          {3}.price-calc = ?
          /* {3}.price-sale = ? - чтоб не ломала ручную, а из ПН ставила ? */
          .
      end.
      line-rec = recid ({3}).
    end.
    &if "{6}" = "pr-doc" &then
    when {&pr-common} then do:
        assign
          {3}.calc-method = {&pr-common}
          {3}.price-sale = common-price
          tt-price-sale = common-price
          .
    end.
    &endif

    when {&pr-calc-specif} then do:
      if available ub.trn-doc
      then do:
        if ub.trn-doc.contract-code <> 0 then do:
          find first buf_contract no-lock
          where buf_contract.host-code     = {2}.host-code
            and buf_contract.contract-code = ub.trn-doc.contract-code
          no-error.
          if available buf_contract then do:

            {str/cont-slave-inc.i
                &FOR_ = YES
                &EACH_ = YES
                &BUFFER_SPECIF   =  buf_contract-specif
                &P_HOST_CODE     =  v-cntxt-host-code-obj
                &P_CONTRACT_NUM  =  buf_contract.contract-code
                &NO_LOCK=YES
                &NO_END=YES
            }
            :
              if buf_contract-specif.gds-code     = {4}.gds-code then do:
                run read-bonus (
                    input  buf_contract-specif.contract-num  ,
                    input  buf_contract-specif.host-code     ,
                    input  buf_contract-specif.gds-code      ,
                    output v-bonus  ) .

                if v-bonus <> ? and v-bonus <> 0 then do:
                  assign
                    {3}.calc-method = {&pr-calc-specif}
                    {3}.price-calc  = buf_contract-specif.price-cli + ( buf_contract-specif.price-cli * v-bonus / 100 )
                    {3}.price-sale = (buf_contract-specif.price-cli + ( buf_contract-specif.price-cli * v-bonus / 100 )) * (1 + {1} / 100)
                    tt-price-sale  = (buf_contract-specif.price-cli + ( buf_contract-specif.price-cli * v-bonus / 100 )) * (1 + {1} / 100)
                  .
                end.
                else do:
                  assign
                    {3}.calc-method = {&pr-calc-specif}
                    {3}.price-calc  = buf_contract-specif.price-cli
                    {3}.price-sale  = buf_contract-specif.price-cli * (1 + {1} / 100)
                    tt-price-sale   = buf_contract-specif.price-cli * (1 + {1} / 100)
                  .
                end.
              end.
            end.
          end.
          else do:
            message "Не найден договор с кодом :"
                    ub.trn-doc.contract-code
                    "- расчет невозможен."
                    view-as alert-box question buttons OK-Cancel update g#log.
          end.
        end.
        else do:
          find first buf_contract no-lock
          where buf_contract.host-code     = {2}.host-code
            and buf_contract.cli-type      = ub.trn-doc.cli-type
            and buf_contract.cli-code      = ub.trn-doc.cli-code
            and buf_contract.status_       = {&current-contr}
            and buf_contract.contract-date-beg   <= ub.trn-doc.doc-date
            and ( buf_contract.contract-date-end >= ub.trn-doc.doc-date
              or buf_contract.contract-date-end   = date('') )
          no-error.
          if available buf_contract then do:
            {str/cont-slave-inc.i
                &FOR_ = YES
                &EACH_ = YES
                &BUFFER_SPECIF   =  buf_contract-specif
                &P_HOST_CODE     =  v-cntxt-host-code-obj
                &P_CONTRACT_NUM  =  buf_contract.contract-code
                &NO_LOCK=YES
                &NO_END=YES
            }
            :
              if buf_contract-specif.gds-code     = {4}.gds-code then do:
                run read-bonus (
                    input  buf_contract-specif.contract-num  ,
                    input  buf_contract-specif.host-code     ,
                    input  buf_contract-specif.gds-code      ,
                    output v-bonus  ) .

                if v-bonus <> ? and v-bonus <> 0 then do:
                  assign
                    {3}.calc-method = {&pr-calc-specif}
                    {3}.price-calc  = buf_contract-specif.price-cli + ( buf_contract-specif.price-cli * v-bonus / 100 )
                    {3}.price-sale = (buf_contract-specif.price-cli + ( buf_contract-specif.price-cli * v-bonus / 100 )) * (1 + {1} / 100)
                    tt-price-sale  = (buf_contract-specif.price-cli + ( buf_contract-specif.price-cli * v-bonus / 100 )) * (1 + {1} / 100)
                  .
                end.
                else do:
                  assign
                    {3}.calc-method = {&pr-calc-specif}
                    {3}.price-calc  = buf_contract-specif.price-cli
                    {3}.price-sale  = buf_contract-specif.price-cli * (1 + {1} / 100)
                    tt-price-sale   = buf_contract-specif.price-cli * (1 + {1} / 100)
                  .
                end.
              end.
            end.
          end.
          else do:
            message "Не найден ни один текущий договор для поставщика:"
                    ub.trn-doc.cli-type ub.trn-doc.cli-code
                    "- расчет невозможен."
                    view-as alert-box question buttons OK-Cancel update g#log.

          end.
        end.
      end.
    end.

    otherwise do:
      message "Не задан способ вычисления цены : " skip
              "Артикул:" {3}.artic {4}.gds-name skip
              "{6}"
              view-as alert-box error.
      g#log = no.
      return error .
    end.


/* $Workfile$ e n d */