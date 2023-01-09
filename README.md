<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Nimv](#nimv)
  - [Simple CUI wrapper for Choosenim command](#simple-cui-wrapper-for-choosenim-command)
    - [Install](#install)
    - [Nimv key operation menu](#nimv-key-operation-menu)
      - [Top menu](#top-menu)
      - [Select other Nim mversion](#select-other-nim-version)
      - [List up installable versions](#list-up-installable-versions)
      - [Remove nim versions](#remove-nim-versions)
      - [Other key operation](#other-key-operation)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Nimv

![alt](img/topMenu.png)

## Simple CUI wrapper for Choosenim command

### Install 

---

1. First install [Nim language](https://nim-lang.org)  
   Confirm nim version info (at this time),
   ```sh
   $ nim --version

    Nim Compiler Version 1.6.10
    Compiled at 2022-11-21
    Copyright (c) 2006-2021 by Andreas Rumpf
   ```

1. Install **choosenim** command,

   ```sh
   nimble install choosenim
   ```

1. Install **Nimv** command,

   ```sh
   nimble install https://github.com/dinau/nimv
   ```

1. Install anyway other Nim version,

   ```sh
   choosenim 1.6.8
   ```

1. Run **Nimv** command in MS-DOS Window or terminal window etc,

   ```sh
   nimv
   ```

### Key operation menu

#### Top menu

---

![alt](img/topMenu.png)

#### Selecting other Nim version

---

Press `'1'`(one) key to select **nim-1.6.10**.

![alt](img/selected1.png)

Activated **nim-1.6.10**.

#### List up installable versions

---

Press `'L'` key to list up installable nim versions.

![alt](img/listMenu.png)

You can **install other nim version** by pressing key `'0' or '1' or '2'` at above situation  
and can then go back to top menu by pressing key `'M' or 'R'`.

#### Remove nim versions

---

Press `'R'` key to remove nim version.

![alt](img/removeMenu.png)

You can remove **nim-1.6.8** by pressing key `'0'`.

#### Other key operation

---

1. Press `'U'` key to update to stable version.
1. Press `'P'` key to install devel version (**nim-#devel**).
  ![alt](img/topMenu.png)

#### Selecting a version on command line

---

![alt](img/topMenu.png)

1. Start Nimv and get the number of **nim-1.6.10** then exit Nimv.
1. You can select **nim-1.6.10** by specifying the number on command line as follows,

   ```sh
   nimv 1
   ```

#### Transparently throwing commands to choosenim

---

For instance on command line,

```sh
nimv 1.4.0
nimv versions
nimv show
nimv remove 1.6.8
...
```

are same as

```sh
choosenim 1.4.0
choosenim versions
choosenim show
choosenim remove 1.6.8
...
```

except `nimv --version`.
