# Contributing
First off, thank you for considering contributing to the project. The tools I've built have been mostly for my personal use so they can be rough.

## IMPORTANT
+ Changes to the custom connector necessitate changes to the WiX project to indicate a new version is available. These may not get updated except on larger releases.
+ The `UpgradeCode` in the `.wxs` file should never be changed. The `Id` may change for upgrades. I've avoided `Id=*` to protect me from me, but let me know if you think this needs to change.

## Submitting Changes
### Versioning
I tend to follow [Semanitic Versioning] (https://semver.org/) as introduced by [Hadley Wickham](http://r-pkgs.had.co.nz/description.html#version) using three (3) number separated by a period.
 + MAJOR: Generally includes significant new features and/or breaking changes to the code.
 + MINOR: Generally includes new features, but can also be a push of a number of bug fixes (or a mix). Only backward compatible feautres and fixes can be included here, with few exceptions (i.e. deprication without removal).
 + PATCH: Fixing a bug without adding new features. Only backwards compatible fixes may be included here.
 
*All suggestions are welcome. Naming conventions, or whitespace, or more performant code--doesn't matter.*

**This section is in development as tools enter different stages.**
### Major Release Submissions
Submit a pull request. For major release changes, I expect to leave the topic open for discussion and testing for some time before making the change. 

### Minor Release Submissions
Submit a pull request. For minor release changes, I expect to leave the topic open long enough to have a healthy discussion, but expect them to be added somewhat quickly.

### Patch Submissions
Submit a pull request. For patches (and suggested improvements), if nobody can give a reason why it is a bad move, I'll likely make the change right away.