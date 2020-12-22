# SortedSet Changelog

## 1.0.1 (2020-12-22)

* Enhancements
  * Be a no-op library for JRuby, as it has its own version of Set and SortedSet.

## 1.0.0 (2020-12-22)

This is the first release of sorted_set as a gem.  Here lists the changes since the version bundled with Ruby 2.7.

* Breaking Changes
  * The pure-ruby fallback implementation has been removed.  It now requires an RBTree library (rbtree) to install and run.
