&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile: cshpattr.i $ $Revision: 1b25beb36074, 2902, rls $".

if not available tb-cash-pay-attr then do:
  create tb-cash-pay-attr.
  assign compare-log = no.
end.
else do:
  buffer-compare tb-cash-pay-attr TO wt-cash-pay-attr case-sensitive save result in compare-log no-error.
end.
if not compare-log then do:
  buffer-copy wt-cash-pay-attr TO tb-cash-pay-attr.
  run fill-cash-pay in p-imp-handle (input tb-cash-pay-attr.cdpay-code
                                    ,input tb-cash-pay-attr.curr-code
                                     ).
end.

/* $Workfile: cshpattr.i $ e n d */