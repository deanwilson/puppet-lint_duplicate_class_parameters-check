# Changelog


## [1.0.3] - 2017-11-16  Dean Wilson <dean.wilson@gmail.com>

###  Changed
- Handle class params that have a duplicated right hand side.
  Many thanks to the eagle eyed @stefanandres for reporting a bug where
  the check didn't report the correct values when one or more class
  parameters had the same value on the right hand side. This issue also
  caused issues when using the same value on both left and right side.
  But don't do that as it's undefined behaviour.

