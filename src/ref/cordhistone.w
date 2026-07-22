&glob param_1 p-db-num-order
define input  parameter {&Param_1} as int64 no-undo.
&glob param_2 p-doc-code-order
define input  parameter {&Param_2} as int64 no-undo.
 
define variable orderStatus  as class ibs.th.str.order.sts.order no-undo .
orderStatus =  new ibs.th.str.order.sts.order().
 
{ gbl/objsrv.i }

define variable vLabel as character no-undo.

&glob proc_nextlevel ref/cordhistone.w 
&glob buf_obj-hist c-order-head
&Glob VisibleKeyField yes
vLabel = "История по Заказу " + string({&Param_2}) + " по ДБ " + string({&Param_1}).
{ref/brwhist.i 
  &objhead = yes 
  &lable = vLabel 
  &objtt = yes
  &addFields = "use-index chip-num use-index corr-user-db-num use-index user-name use-index sub
                field line-num like ub.order-line.line-num
                field attr-code like ub.order-doc-attr.attr-code
                index pi-2 is primary unique
                  db-num asc
                  doc-code asc 
                  line-num asc
                  attr-code asc
                  corr-user-db-num asc 
                  chip-num asc
                  subject asc"
}

{ ref/cordhist.i}
