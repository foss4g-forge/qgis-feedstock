# QGIS Initialization scripts

This folder contains a simple implementation of initialization scripts that
can be used to perform customization in the QGIS user's environment.

QGIS has the ability to run a specified Python script when it starts, 
by loading an init script that will in turn load and run all the scripts in
a given directory, the init script can be used to configure QGIS any time
it starts.

## Usage

Run the script launching QGIS with `qgis --code <path_to_init_scripts.py>`.

The init script will look for other scripts into a directory
that can be specified by the env var `QGIS_INIT_SCRIPTS_DIRECTORY`
or by default will be set as `QgsApplication.pkgDataPath()` + `/init_scripts`,
for example on Linux it would be `/usr/share/qgis/init_scripts`, on Windows
e.g. `C:\OSGeo4W64\apps\qgis\init_scripts`.

Scripts are alphabetically sorted before they are imported (and run).

## Examples

In the examples folder there are some scripts to illustrate a few common
customization tasks.

In order to run the examples, you can set `QGIS_INIT_SCRIPTS_DIRECTORY` 
environment variable to point to the examples directory before launching 
QGIS as specified above.

A sample run command can be found in the`run_examples.sh` bash script.
