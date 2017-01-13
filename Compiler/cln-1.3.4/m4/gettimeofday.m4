dnl -*- Autoconf -*-
dnl Copyright (C) 1993-2003, 2006 Free Software Foundation, Inc.
dnl This file is free software, distributed under the terms of the GNU
dnl General Public License.  As a special exception to the GNU General
dnl Public License, this file may be distributed as part of a program
dnl that contains a configuration script generated by Autoconf, under
dnl the same distribution terms as the rest of that program.

dnl From Bruno Haible, Marcus Daniels, Sam Steingold.

AC_PREREQ(2.57)

AC_DEFUN([CL_GETTIMEOFDAY],
[AC_BEFORE([$0], [CL_TIMES_CLOCK])
AC_CHECK_FUNCS(gettimeofday)dnl
if test $ac_cv_func_gettimeofday = yes; then
dnl HAVE_GETTIMEOFDAY is defined
CL_PROTO([gettimeofday], [
CL_PROTO_TRY([
#include <sys/types.h>
#include <sys/time.h>
], [int gettimeofday (struct timeval * tp, struct timezone * tzp);],
[int gettimeofday();],
cl_cv_proto_gettimeofday_dots=no
cl_cv_proto_gettimeofday_arg2="struct timezone *", [
CL_PROTO_TRY([
#include <sys/types.h>
#include <sys/time.h>
], [int gettimeofday (struct timeval * tp, void * tzp);],
[int gettimeofday();],
cl_cv_proto_gettimeofday_dots=no
cl_cv_proto_gettimeofday_arg2="void *",
cl_cv_proto_gettimeofday_dots=yes
cl_cv_proto_gettimeofday_arg2="...")])
], [extern int gettimeofday (struct timeval *, $cl_cv_proto_gettimeofday_arg2);])
if test $cl_cv_proto_gettimeofday_dots = yes; then
AC_DEFINE(GETTIMEOFDAY_DOTS,,[declaration of gettimeofday() needs dots])
else
AC_DEFINE_UNQUOTED(GETTIMEOFDAY_TZP_T,$cl_cv_proto_gettimeofday_arg2,[type of `tzp' in gettimeofday() declaration])
fi
fi
])
