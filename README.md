
After cloning the pd-for-ios repository, please make sure to cd into the
pd-for-ios folder and say

    git submodule init
	git submodule update --init --recursive

These two commands install the dependencies from libpd.  After the initial
setup, say

    git pull
	git submodule update --recursive

whenever you want to sync with the GitHub repositories.
