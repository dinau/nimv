<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Nimv](#nimv)
  - [Simple CUI wrapper for Choosenim command](#simple-cui-wrapper-for-choosenim-command)
    - [Install](#install)
    - [Key operation menu](#key-operation-menu)
      - [Top menu](#top-menu)
      - [Selecting other Nim version](#selecting-other-nim-version)
      - [Install other Nim versions](#install-other-nim-versions)
      - [Remove nim versions](#remove-nim-versions)
      - [Other key operation](#other-key-operation)
      - [Selecting a version on command line](#selecting-a-version-on-command-line)
      - [Transparently throwing commands to choosenim](#transparently-throwing-commands-to-choosenim)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Nimv

![alt](img/topMenu.png)

## Simple CUI wrapper for Choosenim command

### Install 

---

1.
   Confirm nim version info (at this time) [Nim language](https://nim-lang.org),

   ```sh
   $ nim --version

    Nim Compiler Version 1.6.10
    Compiled at 2022-11-21
    Copyright (c) 2006-2021 by Andreas Rumpf
   ```

1. Install **choosenim** command  
   Refer to [https://github.com/dom96/choosenim](https://github.com/dom96/choosenim)

1. Confirm execution path in PATH variable,  
   - Windows10
      - `c:\Users\%USERNAME%\.nimble\bin`
   - Linux OS
       - `~/.nimble/bin`

1. Install **Nimv** command,

   ```sh
   nimble install https://github.com/dinau/nimv@#head
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

#### Install other Nim versions

---

1. Press `'L'` key to list up installable nim versions.

   ![alt](img/listMenu.png)

1. You can **install other nim version** by pressing key `'0' or '1' or '2'`  
    at above situation.
1. You can then go back to top menu by pressing key `'M' or 'R'`.

#### Remove nim versions

---

1. Press `'R'` key on top menu to remove nim version.

   ![alt](img/removeMenu.png)

1. You can remove **nim-1.6.8** by pressing key `'0'`(zero).

#### Other key operation

---

1. Press `'U'` key to update to stable version.
1. Press `'P'` key to install devel version (**nim-#devel**).
  ![alt](img/topMenu.png)

#### Selecting a version on command line

---

![alt](img/topMenu.png)

1. Start Nimv and get the number of **nim-1.6.10** then **exit Nimv**.
1. You can select **nim-1.6.10** by specifying the number `1` on command line as follows,

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

```sh
$ nimv --version
nimv 1.3.0 (2023/01): Simple CUI wrapper for Choosenim command.
              from 2021/10 by audin
Usage:
    nimv [option]
       option:
            None : Show simple CUI for Choosenim.
            -h, /?, /h, -v, --version: Show this page.
            -d: Start nimv with debug mode. Shown choosenim command.
    .nimv.json: List of old nim versions and configration to nimv.
                It can be set show/hide to list up the specified nim version.
                This file can be placed in user home folder.``
