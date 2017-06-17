#!/bin/bash
################################################################################################
#	Sphinx Acoustic Model Trainer script
# This script is to assist in training an acoustic model for
# pocketsphinx and sphinx4. Continuous or batch models may be made.
# Different training methods may be used.
# Use trainer.sh --help for more information.
#
# This script is not associated with, or created by the creators of Sphinx CMU.
# This author of this script/program/file is Tyler Sengia.
# 
# Any damage, modifications, errors, side effects, etc that this script/program/file causes
# is at the liability of the user and not the author.
# By downloading/installing/running this script you agree to these terms.
#
###############################################################################################

#Variables and their default values
lineCount=21 # Number of lines to be read for the readings
PROMPT_FOR_READINGS="yes"
DO_READINGS="yes"
transcriptionFile="arctic20.transcription"
fileidsFile="arctic20.fileids"
CREATE_SENDUMP="no"
CONVERT_MDEF="yes"
DO_MAP="yes"
DO_MLLR="yes"
SAMPLE_RATE=16000
LANGUAGE_MODEL="en-us.lm.bin"
DICTIONARY_FILE="cmudict-en-us.dict"
HELP="no"
POCKET_SPHINX="yes"

confirm() {
    # call with a prompt string or use a default
    read -r -p "${1:-Would you like to keep this recording? (No will start the recording over again.) [y/N]} " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

doReadings() {
echo "Sphinx 4 Acoustic Library Auto Trainer"
echo "--------------------------------------"
echo "INSTRUCTIONS"
echo "A series of text will be displayed. Please recite the sentences to the best of your ability."
echo "When you are finished reciting the sentence, press the space bar."
echo "Continue reading the sentences until you have gone through all of them."
echo "Once all the sentences have been read, please wait a few moments for the trainer to run."
echo ""
sed -r "s/<s>/ /g; s/<\/s>/ /g; s/\(.+\)/ /g" $transcriptionFile > transcription.txt
echo "There are $lineCount sentences to be read."

for ((i=1; i < lineCount; i++))
do
readSentence
clear
mv output.wav `sed -n "$i{p;q}" $fileidsFile`.wav
done
}

askForReadings() {
    # call with a prompt string or use a default
    read -r -p "${1:-Would you like to use the current audio files? (No will start the process of making new recordings.) [y/N]} " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            DO_READINGS="no"
            ;;
        *)
            DO_READINGS="yes"
            ;;
    esac
}

readSentence() {
	echo "Sentence $i"
	echo "Press ENTER when ready...."
	echo " "
	read
	sed -n "$i{p;q}" transcription.txt
	sleep 0.2
	arecord -c 1 -V mono -r $SAMPLE_RATE -f S16_LE output.wav &
	childId=$!
	read
	pkill -TERM -P $childId
	sleep 0.5
	if  confirm ; then
		return 1
	else 
		clear
		readSentence
	fi
}

observationCounts() {
echo "Accumulating observation counts..."
./bw -hmmdir $OUTPUT_MODEL \
 -moddeffn $OUTPUT_MODEL/mdef.txt \
 -ts2cbfn .ptm. \
 -feat 1s_c_d_dd \
 -svspec 0-12/13-25/26-38 \
 -cmn current \
 -agc none \
 -dictfn $DICTIONARY_FILE \
 -ctlfn $fileidsFile \
 -lsnfn $transcriptionFile \
 -accumdir .

echo " "
echo "Done accumulting observation counts."
}

makesendump() {
echo "Creating sendump file..."
./mk_s2sendump \
    -pocketsphinx $POCKET_SPHINX \
    -moddeffn $OUTPUT_MODEL/mdef.txt \
    -mixwfn $OUTPUT_MODEL/mixture_weights \
    -sendumpfn $OUTPUT_MODEL/sendump
echo " "
echo "Done creating sendump file."
}

domapupdate() {
echo "Updating acoustic model files with MAP..."
./map_adapt \
    -moddeffn $OUTPUT_MODEL/mdef.txt \
    -ts2cbfn .ptm. \
    -meanfn $OUTPUT_MODEL/means \
    -varfn $OUTPUT_MODEL/variances \
    -mixwfn $OUTPUT_MODEL/mixture_weights \
    -tmatfn $OUTPUT_MODEL/transition_matrices \
    -accumdir . \
    -mapmeanfn $OUTPUT_MODEL/means \
    -mapvarfn $OUTPUT_MODEL/variances \
    -mapmixwfn $OUTPUT_MODEL/mixture_weights \
    -maptmatfn $OUTPUT_MODEL/transition_matrices
echo " "
echo "Done updating with MAP."
}

domllrupdate() {
echo "Updating acoustic model with MLLR..."
./mllr_solve \
    -meanfn $OUTPUT_MODEL/means \
    -varfn $OUTPUT_MODEL/variances \
    -outmllrfn mllr_matrix -accumdir .
echo ""
echo "Done updating with MLLR."
}

convertmdef() {
echo "Converting mdef into text format..."
pocketsphinx_mdef_convert -text $OUTPUT_MODEL/mdef $OUTPUT_MODEL/mdef.txt
echo " "
echo "Done converting mdef."
}

createAcousticFeatures() {
echo " "
echo "Creating acoustic feature files..."
sphinx_fe -argfile $OUTPUT_MODEL/feat.params -samprate $SAMPLE_RATE -c $fileidsFile -di . -do . -ei wav -eo mfc -mswav yes
echo "Done creating acoustic feature files."
echo " "
}

packageforpocket() {
makesendump
rm $OUTPUT_MODEL/mdef.txt
rm $OUTPUT_MODEL/mixtue_weights
echo "Packaged for pocket sphinx."
}

displayHelp() {
cat << EOF
Spinx Auto Trainer Script						

Author: tylersengia@gmail.com

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
EOF
read
}

#Parsing arguments
while [[ $# -gt 1 ]]
do
key="$1"

case $key in
    -r|--readings)
    PROMPT_FOR_READINGS="no"
    READINGS_ENABLED="$2"
    shift # past argument
    ;;
    --map)
    DO_MAP="$2"
    shift
    ;;
    --mllr)
    DO_MLLR="$2"
    shift
    ;;
    -s|--sample-rate)
    SAMPLE_RATE="$2"
    shift
    ;;
    -h|--help)
    HELP="yes"
    ;;
    --covert-mdef)
    CONVERT_MDEF="$2"
    shift
    ;;
    -d|--dict)
    DICTIONARY_FILE="$2"
    shift
    ;;
    -t|--transcript)
    transcriptionFile="$2"
    shift
    ;;
    -f|--fileids)
    fileidsFile="$2"
    shift
    ;;
    -p|--pocketsphinx)
    POCKET_SPHINX="$2"
    shift
    ;;
    -l|--lines)
    lineCount="$2"
    shift
    ;;
    *)
    INPUT_MODEL="$1"
    OUTPUT_MODEL="$2"
    break
    ;;
esac
shift # past argument or value
done

test $HELP == "yes" && (displayHelp)
if [ HELP == "yes" ]; then
exit
fi

echo "Loading...."
rm -rf recordings
rm transcription.txt
mkdir recordings

test $OUTPUT_MODEL != $INPUT_MODEL && (cp -a $INPUT_MODEL $OUTPUT_MODEL) # Test to make sure these aren't the same directory. If they are, that means the user simply wants to not make a separate copy, so don't make a copy.

#cp -a /usr/local/share/pocketsphinx/model/en-us/en-us .
#cp -a /usr/local/share/pocketsphinx/model/en-us/cmudict-en-us.dict .
#cp -a /usr/local/share/pocketsphinx/model/en-us/en-us.lm.bin .
clear


test $PROMPT_FOR_READINGS == "yes" && (askForReadings)
test $DO_READINGS == "yes" && (doReadings)

createAcousticFeatures
test $CONVERT_MDEF == "yes" && (convertmdef)
observationCounts
test $DO_MAP == "yes" && (domapupdate)
test $DO_MLLR == "yes" && (domllrupdate)
test $CREATE_SENDUMP == "yes" && (makesendump)
test $POCKET_SPHINX == "yes" && (packageforpocket)

echo "DONE TRAINING."