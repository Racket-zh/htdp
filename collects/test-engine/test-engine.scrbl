#lang scribble/doc
@(require scribble/manual
          (for-label scheme/base
                     test-engine/scheme-tests
                     (prefix-in gui: test-engine/scheme-gui)))

@title{Test Support}

@author["Kathryn Gray"]

@table-of-contents[]

@; ----------------------------------------------------------------------

@section{Using Check Forms}

@defmodule[test-engine/scheme-tests]

This module provides test forms for use in Scheme programs, as well
as parameters to configure the behavior of test reports.

Each check form may only occur at the top-level or within the
definitions of a local declaration; results are collected and reported
by the test function.

@defproc[(check-expect (test any/c) (expected any/c)) void?]{

Accepts two value-producing expressions and structurally compares the
resulting values.

It is an error to produce a function value or an inexact number.}


@defproc[(check-within (test any/c) (expected any/c) (delta number?)) void?]{

Like @scheme[check-expect], but with an extra expression that produces
a number delta. Every number in the first expression must be within
delta of the cooresponding number in the second expression.

It is an error to produce a function value.}


@defproc[(check-error (test any/c) (msg string?)) void?]{

Checks that evaluating the first expression signals an error, where
the error message matches the string.}

@defproc[(test) void?]{

Runs all of the tests specified by check forms in the current module
and reports the results.  When using the gui module, the results are
provided in a separate window, otherwise the results are printed to
the current output port.}

@defparam[test-format format (any/c . -> . string?)]{

A parameter that stores the formatting function for the values tested
by the check forms.}


@defboolparam[test-silence silence?]{

A parameter that stores a boolean, defaults to #f, that can be used to
suppress the printed summary from test.}


@defboolparam[test-execute execute?]{

A parameter that stores a boolean, defaults to #t, that can be used to
suppress evaluation of test expressions.
}

@section{GUI Interface}

@defmodule[test-engine/scheme-gui]

@; FIXME: need to actually list the bindings here, so they're found in
@; the index

This module requires MrEd and produces an independent window when
displaying test results.  It provides the same bindings as
@scheme[test-engine/scheme-tests].

@section{Integrating languages with Test Engine}

@italic{(To be written.)}