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
search and replace
```bash
pere -name "pattern*" --search "file" --replace "new_file" 
```

numbering
```bash
pere -name "pattern*" --num 1 --text "new_file_{num}"
```

numbering and using old name
```bash
pere -name "pattern*" --num 1 --text "{old}_{num}"
```

numbering from one number to another 
```bash
pere -name "pattern*" --num 1 6 --text "new_file_{num}"
```
> This will rename only first 6 files

reverting the rename via logfile
```bash
pere -rev "pere_logfile"
```
## Available options
**-name** or **--name=STR**    specify pattern to find files  
**-iname** or **--name=STR**    specify pattern to find files (case insensitive)  
**-n** or **--num=INT**    specify start and ending (optional) numbering  
**-s** or **--search=INT**    specify search keyword (required with replace)  
**-r** or **--replace=INT**    specify replace keyword (required with search)  
**-dry** or **--dry-run**    show what will happen without actually arranging  
**-v** or **--verbose**    info while renaming  
**-rev** or **--revert**    revert the rename (require a logfile)  
**-log** or **--logfile=STR**    specify logfile (required for reverting)  
**-no-log**    dont save log  
**-h** or **--help**    show this help message  

