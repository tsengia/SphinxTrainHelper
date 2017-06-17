# Sphinx Training Helper
A Bash script designed to make training sphinx4 and pocketsphinx acoustic libraries faster and easier

This script is not created by the authors of Sphinx CMU or related software and assets.

# Installation
Sphinx Training Helper uses the ```arecord``` command during Readings Mode. Please ensure that ALSA is installed on your machine and configured properly in order to use Readings.  

The Sphinx CMU toolkit should be downloaded and installed on your machine. This includes: sphinxbase, pocketsphinx, and sphinx_train.  

# Instructions
    
    Usage: trainer [OPTIONS] input_model output_model
            input_model : The directory/filename of acoustic model to create the trained acoustic model off of.
            output_model : The desired name of the trained acoustic model that will be created using this script.
    OPTIONS may be any of:
    	-h	--help			Displays this help text and exits.
    	-r	--readings {yes|no}	Enable or disable sentence reading. Disabling sentence reading means that the audio files in the working directory will be used to train.
    	-s	--sample_rate {int}	Specify the sample rate for the audio files. Expand the value (ie 16kHz should be 16000). Default is 16000.
    		--map {yes|no}		Enable or disable MAP weight updating. Default is yes.
    		--mllr {yes|no}		Enable or disable MLLR weight updating. Default is yes.
    		--convert-mdef {yes|no}	Specify whether or not to convert the mdef file in the acoustic model to text format. If it is already in text format, save yourself some time by disabling it. Default is no.
    	-l	--lines {int}		Specify the number of lines/sentences to be read in the transcript file.
    	-t	--transcript {file}	Specify the transcript file for readings.
    	-f	--fileids {file}	Specify the fileids file for readings.
    	-p	--pocketsphinx {yes|no} Specfiy whether or not you are training the model for pocket sphinx. Specifying yes will add optimizations. Default is yes. Set to "no" if using for Sphinx4 (Java).

    
