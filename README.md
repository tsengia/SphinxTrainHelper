# Sphinx Training Helper
A Bash script designed to make training sphinx4 and pocketsphinx acoustic libraries faster and easier.

This script is not created by the authors of Sphinx CMU or related software and assets.

# Installation
Sphinx Training Helper uses the ```arecord``` command during Readings Mode. Please ensure that ALSA is installed on your machine and configured properly in order to use Readings.  

The Sphinx CMU toolkit should be downloaded and installed on your machine. This includes: sphinxbase, pocketsphinx, and sphinx_train.  

In order to train/update the acoustic model, this script will need the following programs in the same directory: 
bw, map_adapt, mllr_solve, mllr_transform, mk_s2sendump, word_align.pl  

These programs/binaries can be found where you installed sphinx_train (on Linux this should be `/usr/local/libexec/sphinxtrain`, for more information, see the tutorial on CMU Sphinx's website. Simply copy the needed executables from that directory to the same directory as the Sphinx Training Helper.
However, there is also a simple bash script (`copy-training-programs.sh`) that is included that can be used to copy the needed programs into the directory.

Additionally, the `word_align.pl` script is needed to test the effectiveness of the acoustic model adaptation. You will need to copy it from your `sphinx_train/scripts/decode` directory.

# Instructions
          Usage: trainer [OPTIONS] --type TYPE input_model output_model
        	input_model : The directory/filename of acoustic model to create the trained acoustic model off of.
        	output_model : The desired name of the trained acoustic model that will be created using this script.
        
        TYPE may be any of:
            p   PTM
            c   continuous
            s   semi-continuous
                
            
        OPTIONS may be any of:
        	-h	--help			Displays this help text and exits.
        	-r	--readings {yes|no}	Enable or disable sentence reading. Disabling sentence reading means that the audio files in the working directory (as referenced by the fileids) will be used to train.
        	-s	--sample_rate {int}	Specify the sample rate for the audio files. Expand the value (ie 16kHz should be 16000). Default is 16000.
        		--map {yes|no}		Enable or disable MAP weight updating. Supported in pocketsphinx and shpinx4. Default is yes.
        		--mllr {yes|no}		Enable or disable MLLR weight updating. Currently only supported in pocketsphinx Default is yes.
        		--transcript {file}	Specify the transcript file for readings. (default: arctic20.transcription)
        		--type    TYPE        Specify what TYPE of acoustic model is being trained. See above for valid identifiers.
        	-f	--fileids {file}	Specify the fileids file for readings. (default: acrtic20.fileids)
        	-p	--pocketsphinx {yes|no} Specfiy whether or not you are training the model for pocket sphinx. Specifying yes will add optimizations. Default is yes. Set to "no" if using for Sphinx4 (Java).
                -d  --dict                      Specify the path to the dictionary to use. Default is "cmudict-en-us.dict"
            
# Readings Mode
The so called "Readings Mode" in this script is a simple command line interface that allows the user to read the entire transcript file line by line while recording. If readings mode is enabled, the user will be displayed a line from the transcript file that should be read aloud. When the user is done reading the line, they can press any key to stop recording. The user is then prompted to either user the recording or redo the recording. Once all lines from the transcript are read, the script will begin adapting the acoustic model.  

The purpose of Readings Mode is to make recording quick, simple, and painless for the user. No need to open up Audacity or a recording program and splice audio recordings, just read and press the enter key.

# Transcription File and File IDs File
The CMU Sphinx website provides examples for writing transcript and file IDs files, but here are the formats anyways.

### Transcription File
A text file containing the words that will be/are spoken in an audio file.  
The words should be grouped into sentences as marked by an XML-like `<s> Your words go here </s>` tag.
Following the `<s>` tag should be a space and a set of parenthesis with the audio file name inside (without the extension).  
For example:  

    <s> hello world this is an example transcription file </s> (audiofile_0001)
    <s> this is the second sentence in the transcription file </s> (audiofile_0002)
    <s> we can even add a third sentence </s> (audiofile_0003)
    <s> just remember to increment the file id in the parenthesises </s> (audiofile_0004)
    
### File IDs File
The File IDs file is simply a text file where each line contains the file name of an audio file (do not include the extension).  
The file names should be listed in the same order as the transcription file.  
Remember to increment any numbers identifying the audio files.
Example File IDs file:
    audiofile_0001
    audiofile_0002
    audiofile_0003
    audiofile_0004
    audiofile_0005
    
