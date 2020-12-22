# SortedSet Changelog

## 1.0.0 (unreleased)

This is the first release of sorted_set as a gem.  Here lists the changes since the version bundled with Ruby 2.7.

* Breaking Changes
  * The pure-ruby fallback implementation has been removed.  It now requires an RBTree library (rbtree for CRuby, rbtree-jruby for JRuby) to install and run.
