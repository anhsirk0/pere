<h1 align="center"><code>Pere</code></h1>
<p align="center">Simple <strong>Bulk</strong> file renamer</p>

## About
Pere is a bulk file renamer written in Perl.

## Features
Pere can
 - rename files by patterns
 - add numbering to filenames
 - search and replace text from filenames
 - save logs of what exactly happened
 - revert the rename using logfile

## Installation
Its just a perl script
download it make it executable and put somewhere in your $PATH

## Manually
with wget
``` bash
wget https://raw.githubusercontent.com/anhsirk0/pere/master/pere.pl -O pere
```
### or
with curl
``` bash
curl https://raw.githubusercontent.com/anhsirk0/pere/master/pere.pl --output pere
```
making it executable
```bash
chmod +x pere
```
copying it to $PATH (~/.local/bin/ , this step is optional)
```bash
cp pere ~/.local/bin/
```

## Usage

