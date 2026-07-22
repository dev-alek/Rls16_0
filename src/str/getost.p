block-level on error undo, throw.

/*define variable iobj-type as character no-undo init "маг".
define variable iobj-code as integer   no-undo init 38.
define variable igds-code as integer   no-undo init "100027".
define variable idoc-code as character no-undo init "9969-38м".*/
define input  parameter iobj-type as character no-undo.
define input  parameter iobj-code as integer no-undo.
define input  parameter igds-code as integer no-undo.
define input  parameter idoc-code as character no-undo.
define output parameter oquantity as decimal no-undo.
define variable vss-revision    as character no-undo init "$Revision: c16f204c84f9, 2642, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: Пт окт 23 21:03:38 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: getost.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/getost.p $":U .
define variable vss-description as character no-undo init "Остаток наначало смены".

{cmp\str-glbl.i }
{ cmp/library.i  }
{ trg/factord.i  }
{ cmp/obj-list.i local }
define variable quantity as decimal no-undo.
define variable coast_r  as decimal no-undo.
define variable coast_v  as decimal no-undo.
define variable vat_r    as decimal no-undo.
define variable vat_v    as decimal no-undo.
define variable slt_r    as decimal no-undo.
define variable slt_v    as decimal no-undo.
{ rep/ost-line.i}

{ rep/ostatok.i}
create obj-list.
assign
   obj-list.obj-type = iobj-type
   obj-list.obj-code = iobj-code
   obj-list.obj-id   = iobj-code
   obj-list.obj-name = string(iobj-code) + iobj-type
   .

find first trn-doc where trn-doc.doc-code eq idoc-code no-lock no-error.
if available trn-doc
then do:
 
   find first shift-obj where shift-obj.obj-type   eq iobj-type
                          and shift-obj.obj-code   eq iobj-code
                          and shift-obj.shift-date eq trn-doc.shift-date 
                          and shift-obj.shift-num  eq trn-doc.shift-num
   no-lock no-error.
   if available shift-obj
   then do:
/*ищим дату предыдущей смены*/
       define variable v-fact-order-1           as decimal no-undo .
       run ostatok (
        input shift-obj.obj-code  ,
        input shift-obj.obj-type  , 
        input yes,
        input shift-obj.shift-date - 1 ,
        input date('')      ,  shift-obj.shift-num,shift-obj.shift-num,
        input {&arh-crsa}   ,
        input {&root-cat-id},
        input yes ,

        output  Quantity  ,
        output  Coast_R   ,
        output  Coast_V   ,
        output  VAT_R     ,
        output  VAT_V     ,
        output  v-Fact-order-1 ). 
        define variable v-date-start as date no-undo.
        define variable v-date-end as date no-undo.
        v-date-start = shift-obj.shift-date.
        v-date-end = shift-obj.shift-date.
        define variable v-archive-ok as logical no-undo.
        define variable v-comment    as character no-undo.
        define variable v-can-print  as logical no-undo.
      run rep/chk-ahz.p 
        (input        shift-obj.obj-type /* p-obj-type          */
        ,input        shift-obj.obj-code /* p-obj-code          */
        ,input        no     /* p-verify-detail     */
        ,input        yes    /* p-verify-arh        */
        ,input        no   /* p-verify-ahsp       */
        ,input        no    /* p-verify-aht        */
        ,input        no              /* p-check-act         */
        ,input        ibs.th.gbl.gbl-var:g#db-num    /* p-check-act-db-num  */
        ,input        ibs.th.gbl.gbl-var:g#userid    /* p-check-act-user-id */
        ,input-output v-date-start      /* p-date-start        */
        ,input-output v-date-end        /* p-date-end          */
        ,output       v-archive-ok      /* p-archive-ok        */
        ,output       v-comment         /* p-comment           */
        ,output       v-can-print       /* p-can-print         */
        ) .
      if v-archive-ok = false
      then do:
        if v-can-print = false
        then do:
          message
            "ВНИМАНИЕ !!!" skip
            "Отчет не может быть сформирован!" skip
            "На запрошенную дату нет архивов или они сжаты" skip
            v-comment skip
            view-as alert-box information .
        end.
      end.
      find first goods where goods.gds-code eq igds-code
      no-lock no-error.
      if available goods 
      then do:
/*получим остаток на конец предыдущкей /на на чало текушей смены */
         run ost-line (
                              input   iobj-code
                             ,input   iobj-type
                             ,input   goods.artic
                             ,input   goods.prod-code
                             ,input   goods.prod-type
                             ,input   true
                             ,input   v-fact-order-1
                             ,input   {&arh-cost}
                             ,input   {&root-cat-id}
                             ,input   true
                             ,output  quantity
                             ,output  coast_r
                             ,output  coast_v
                             ,output  vat_r
                             ,output  vat_v
                             ,output  slt_r
                             ,output  slt_v
                             ).
      end.
   end.
end.
oquantity = quantity.
