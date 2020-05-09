# duplicate-assassin
Script that hunts down duplicate files without mercy

NOTES:

- Program Does Not Support Nested Folders
- File Names MUST NOT contain spaces (If this is an issue, batch rename the files replacing spaces with other unique characters and then undo it after you use the program)

Modules:

- Blank-Hunter
  - Finds blank files that are all zeros in the hex
- Size-Date-Duplicate-Hunter
  - Finds duplicate files by searching for files with the same size and date
- Meta-Hash-Duplicate-Hunter
  - Finds duplicate files (photos/videos) that are particularly evasive
  - The module uses exiftool (must already be installed) to create hashes of metadata and
  find files matches. This works well with images that have camera and exposure info in them
- Similar-Names (Beta)
  - Finds duplicate files that have names extended from other files
  - Ex. (cat.jpg -> cat1.jpg or cat(1).jpg)
  - WARNING: THIS MODULE MUST BE RUN INSIDE THE TARGET DIRECTORY AND
  FILENAMES MUST HAVE SPACES CHANGED TO "~x~"
- Reset-Dates
  - This module uses exiftool (must be already installed) to reset the date metadata
  - A file may say created today but actually have the true date hidden inside
  - This module pulls out the actual date (if it exists) and resets the files dates
