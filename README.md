# XDG Specification

This GitHub action will:

1. Create all the personal directories specified through the [XDG] base
   directory specification.
2. Arrange for all their corresponding environment variables to be present, as
   long as the directories were created, or existed prior to running the action.
3. Add the default directory for user-specific executable files to the `PATH`
   variable.

  [XDG]: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html