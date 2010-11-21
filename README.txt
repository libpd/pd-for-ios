!!!!! WARNING !!!!!

The current version of pd-for-ios is BROKEN and needs immediate attention from
someone who's set up to do iOS development.  It should be fairly
straightforward to fix --- just take the existing Xcode project and adjust the
paths to reflect the new layout of the libpd repository.

After cloning the pd-for-ios repository, please make sure to cd into the
pd-for-ios folder and say
  git submodule init
  git submodule update
These two commands install the dependencies from libpd.
